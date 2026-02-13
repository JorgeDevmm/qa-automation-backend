Feature: Registrar nuevo usuario en ServeRest
  # Este feature prueba el endpoint POST /usuarios
  # Valida la creación de usuarios con datos válidos e inválidos

  Background:
    # Configuración base para todos los escenarios
    * url baseUrl
    * path '/usuarios'
    # Función para generar timestamp único
    * def timestamp = function(){ return java.lang.System.currentTimeMillis() }
    # Email único para cada ejecución
    * def randomEmail = 'usuario' + timestamp() + '@qa.com'

  @smoke @critical
  Scenario: Registrar usuario válido exitosamente
    # Verifica que se puede crear un usuario con todos los datos correctos
    # Debe retornar status 201 y un ID de usuario
    Given request
     """
      {
      "nome": "Usuario Test",
      "email": "#(randomEmail)",
      "password": "senha123",
      "administrador": "true"
      }
      """
    When method POST
    Then status 201
    And match response.message == 'Cadastro realizado com sucesso'
    And match response._id == '#string'
    And match response._id == '#notnull'

  @negative
  Scenario: Fallar al registrar usuario con email duplicado
    # Verifica que el sistema no permite emails duplicados
    # Debe retornar status 400 con mensaje específico
    * def emailDuplicado = 'fulano@qa.com'
    Given request
      """
      {
      "nome": "Usuario Duplicado",
      "email": "#(emailDuplicado)",
      "password": "senha123",
      "administrador": "true"
      }
      """
    When method POST
    Then status 400
    And match response.message == 'Este email já está sendo usado'

  @negative
  Scenario Outline: Validar campos obligatorios
    # Verifica que todos los campos requeridos son validados
    # Debe retornar status 400 cuando faltan campos obligatorios
    Given request
      """
      {
      "nome": "<nome>",
      "email": "<email>",
      "password": "<password>",
      "administrador": "<administrador>"
      }
      """
    When method POST
    Then status 400
    And match response.message contains '<mensajeError>'

    Examples:
      | nome      | email       | password | administrador | mensajeError         |
      |           | test@qa.com | senha123 | true          | nome não pode ficar  |
      | Test User |             | senha123 | true          | email não pode ficar |
      | Test User | test@qa.com |          | true          | password não pode    |
      | Test User | test@qa.com | senha123 |               | AD+