Feature: Registrar nuevo usuario en ServeRest

  Background:
    * url baseUrl
    * path '/usuarios'
    * def timestamp = function(){ return java.lang.System.currentTimeMillis() }
    * def randomEmail = 'usuario' + timestamp() + '@qa.com'

  @smoke @critical
  Scenario: Registrar usuario válido exitosamente
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