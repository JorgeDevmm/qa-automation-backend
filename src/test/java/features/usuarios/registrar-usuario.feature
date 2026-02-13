Feature: Registrar nuevo usuario en ServeRest
  # Este feature prueba el endpoint POST /usuarios
  # Valida la creación de usuarios con datos válidos e inválidos
  # Incluye validación completa de esquemas JSON

  Background:
    # Configuración base para todos los escenarios
    * url baseUrl
    * path '/usuarios'
    # Función para generar timestamp único
    * def timestamp = function(){ return java.lang.System.currentTimeMillis() }
    # Email único para cada ejecución
    * def randomEmail = 'usuario' + timestamp() + '@qa.com'

  @smoke @critical @positive
  Scenario: Registrar usuario válido exitosamente con validación de esquema
    # Verifica que se puede crear un usuario con todos los datos correctos
    # Valida el esquema JSON de la respuesta
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
    # Validar esquema JSON completo de la respuesta de creación
    And match response ==
    """
    {
      message: '#string',
      _id: '#string'
    }
    """
    And match response.message == 'Cadastro realizado com sucesso'
    And match response._id == '#notnull'
    And match response._id == '#string'
    # Validar que el ID no está vacío
    And assert response._id.length > 0

    # Limpiar: eliminar el usuario creado
    * def usuarioId = response._id
    Given path '/usuarios', usuarioId
    When method DELETE
    Then status 200

  @negative
  Scenario: Fallar al registrar usuario con email duplicado
    # Verifica que el sistema no permite emails duplicados
    # Valida el esquema JSON de respuesta de error
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
    # Validar esquema de respuesta de error
    And match response == { message: '#string' }
    And match response.message == 'Este email já está sendo usado'

  @negative
  Scenario Outline: Validar campos obligatorios con esquema de error
    # Verifica que todos los campos requeridos son validados
    # Valida el esquema JSON de mensajes de error
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
    # Validar que la respuesta tiene estructura de error
    And match response contains { <campo>: '#string' }

    Examples:
      | nome      | email       | password | administrador | campo         |
      |           | test@qa.com | senha123 | true          | nome          |
      | Test User |             | senha123 | true          | email         |
      | Test User | test@qa.com |          | true          | password      |
      | Test User | test@qa.com | senha123 |               | administrador |

  @negative
  Scenario: Validar formato de email inválido
    # Verifica que el sistema valida el formato del email
    # Valida el esquema JSON de error de validación
    * def emailInvalido = 'emailsinformato'
    Given request
      """
      {
      "nome": "Usuario Test Email",
      "email": "#(emailInvalido)",
      "password": "senha123",
      "administrador": "true"
      }
      """
    When method POST
    Then status 400
    # Validar esquema de error de validación
    And match response contains { email: '#string' }
    And match response.email == 'email deve ser um email válido'

  @positive
  Scenario: Registrar usuario administrador y validar estructura
    # Verifica que se puede crear un usuario con rol de administrador
    # Valida el esquema JSON y verifica el usuario creado
    * def emailAdmin = 'admin.' + timestamp() + '@qa.com'
    Given request
      """
      {
      "nome": "Admin Test",
      "email": "#(emailAdmin)",
      "password": "adminpass123",
      "administrador": "true"
      }
      """
    When method POST
    Then status 201
    # Validar esquema de respuesta
    And match response == { message: '#string', _id: '#string' }
    And match response.message == 'Cadastro realizado com sucesso'
    * def adminId = response._id

    # Verificar que el usuario fue creado correctamente
    Given path '/usuarios', adminId
    When method GET
    Then status 200
    # Validar esquema del usuario
    And match response ==
    """
    {
      _id: '#string',
      nome: '#string',
      email: '#string',
      password: '#string',
      administrador: '#string'
    }
    """
    And match response.administrador == 'true'
    And match response.email == emailAdmin

    # Limpiar
    Given path '/usuarios', adminId
    When method DELETE

  @positive
  Scenario: Registrar usuario no administrador y validar estructura
    # Verifica que se puede crear un usuario sin privilegios de admin
    # Valida el esquema JSON y verifica el usuario creado
    * def emailUser = 'user.' + timestamp() + '@qa.com'
    Given request
      """
      {
      "nome": "Usuario Normal",
      "email": "#(emailUser)",
      "password": "userpass123",
      "administrador": "false"
      }
      """
    When method POST
    Then status 201
    # Validar esquema de respuesta
    And match response == { message: '#string', _id: '#string' }
    * def userId = response._id

    # Verificar que el usuario fue creado correctamente
    Given path '/usuarios', userId
    When method GET
    Then status 200
    And match response.administrador == 'false'
    And match response.email == emailUser

    # Limpiar
    Given path '/usuarios', userId
    When method DELETE
