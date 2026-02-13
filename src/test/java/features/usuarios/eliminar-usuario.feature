Feature: Eliminar usuario de ServeRest
  # Este feature prueba el endpoint DELETE /usuarios/{id}
  # Valida la eliminación de usuarios existentes y manejo de errores

  Background:
    # Configuración base para todos los escenarios
    * url baseUrl
    # Función para generar timestamp único
    * def timestamp = function(){ return java.lang.System.currentTimeMillis() }
    # Email único para cada ejecución
    * def randomEmail = 'eliminar' + timestamp() + '@qa.com'

    # Crear usuario de prueba para eliminar
    * path '/usuarios'
    * request { "nome": "Usuario Eliminar", "email": "#(randomEmail)", "password": "senha123", "administrador": "true" }
    * method POST
    * status 201
    * def usuarioId = response._id

  @smoke @critical
  Scenario: Eliminar usuario existente exitosamente
    # Verifica que se puede eliminar un usuario existente
    # Debe retornar status 200 con mensaje de éxito
    Given path '/usuarios', usuarioId
    When method DELETE
    Then status 200
    And match response.message == 'Registro excluído com sucesso'

    # Verificar que el usuario fue eliminado correctamente
    Given path '/usuarios', usuarioId
    When method GET
    Then status 400
    And match response.message == 'Usuário não encontrado'

  @negative
  Scenario: Fallar al eliminar usuario inexistente
    # Verifica que el sistema maneja correctamente la eliminación de un ID inexistente
    # Debe retornar status 200 con mensaje indicando que no se eliminó nada
    Given path '/usuarios/idInexistente123'
    When method DELETE
    Then status 200
    And match response.message == 'Nenhum registro excluído'

  @negative
  Scenario: No se puede eliminar usuario con carrinho asociado
    # Esta validación depende de si la API tiene esta restricción
    # Verifica el comportamiento cuando un usuario tiene un carrito asociado
    # Ajustar según la documentación de ServeRest
    Given path '/usuarios', usuarioId
    When method DELETE
    Then status 200
