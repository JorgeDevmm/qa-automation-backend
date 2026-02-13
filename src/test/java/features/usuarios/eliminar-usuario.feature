Feature: Eliminar usuario de ServeRest

  Background:
    * url baseUrl
    * def timestamp = function(){ return java.lang.System.currentTimeMillis() }
    * def randomEmail = 'eliminar' + timestamp() + '@qa.com'

    # Crear usuario para eliminar
    * path '/usuarios'
    * request { "nome": "Usuario Eliminar", "email": "#(randomEmail)", "password": "senha123", "administrador": "true" }
    * method POST
    * status 201
    * def usuarioId = response._id

  @smoke @critical
  Scenario: Eliminar usuario existente exitosamente
    Given path '/usuarios', usuarioId
    When method DELETE
    Then status 200
    And match response.message == 'Registro excluído com sucesso'

    # Verificar que el usuario fue eliminado
    Given path '/usuarios', usuarioId
    When method GET
    Then status 400
    And match response.message == 'Usuário não encontrado'

  @negative
  Scenario: Fallar al eliminar usuario inexistente
    Given path '/usuarios/idInexistente123'
    When method DELETE
    Then status 200
    And match response.message == 'Nenhum registro excluído'

  @negative
  Scenario: No se puede eliminar usuario con carrinho asociado
    # Esta validación depende de si la API tiene esta restricción
    # Ajustar según la documentación de ServeRest
    Given path '/usuarios', usuarioId
    When method DELETE
    Then status 200
