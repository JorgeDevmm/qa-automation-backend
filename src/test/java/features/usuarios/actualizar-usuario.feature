Feature: Actualizar datos de usuario en ServeRest

  Background:
    * url baseUrl
    * def timestamp = function(){ return java.lang.System.currentTimeMillis() }
    * def randomEmail = 'actualizar' + timestamp() + '@qa.com'

    # Crear usuario para actualizar
    * path '/usuarios'
    * request { "nome": "Usuario Original", "email": "#(randomEmail)", "password": "senha123", "administrador": "true" }
    * method POST
    * status 201
    * def usuarioId = response._id

  @smoke @critical
  Scenario: Actualizar usuario existente exitosamente
    * def nuevoNombre = 'Usuario Actualizado'
    * def nuevoEmail = 'actualizado' + timestamp() + '@qa.com'

    Given path '/usuarios', usuarioId
    And request
      """
      {
        "nome": "#(nuevoNombre)",
        "email": "#(nuevoEmail)",
        "password": "novasenha123",
        "administrador": "false"
      }
      """
    When method PUT
    Then status 200
    And match response.message == 'Registro alterado com sucesso'

  @negative
  Scenario: Fallar al actualizar con email duplicado
    # Crear segundo usuario
    * def emailDuplicado = 'duplicado' + timestamp() + '@qa.com'
    * path '/usuarios'
    * request { "nome": "Usuario Duplicado", "email": "#(emailDuplicado)", "password": "senha123", "administrador": "true" }
    * method POST
    * status 201
    Given path '/usuarios', usuarioId
    And request
      """
      {
        "nome": "Usuario Test",
        "email": "#(emailDuplicado)",
        "password": "senha123",
        "administrador": "true"
      }
      """
    When method PUT
    Then status 400
    And match response.message == 'Este email já está sendo usado'
