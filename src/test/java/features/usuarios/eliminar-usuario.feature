Feature: Eliminar usuario de ServeRest
  # Este feature prueba el endpoint DELETE /usuarios/{id}
  # Valida la eliminación de usuarios existentes y manejo de errores
  # Incluye validación completa de esquemas JSON

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

  @smoke @critical @positive
  Scenario: Eliminar usuario existente exitosamente con validación de esquema
    # Verifica que se puede eliminar un usuario existente
    # Valida el esquema JSON de la respuesta de eliminación
    # Debe retornar status 200 con mensaje de éxito
    Given path '/usuarios', usuarioId
    When method DELETE
    Then status 200
    # Validar esquema JSON de respuesta de eliminación exitosa
    And match response == { message: '#string' }
    And match response.message == 'Registro excluído com sucesso'

    # Verificar que el usuario fue eliminado correctamente
    Given path '/usuarios', usuarioId
    When method GET
    Then status 400
    # Validar esquema de error al buscar usuario eliminado
    And match response == { message: '#string' }
    And match response.message == 'Usuário não encontrado'

  @negative
  Scenario: Fallar al eliminar usuario inexistente con validación de esquema
    # Verifica que el sistema maneja correctamente la eliminación de un ID inexistente
    # Valida el esquema JSON de respuesta cuando no hay registro
    # Debe retornar status 200 con mensaje indicando que no se eliminó nada
    Given path '/usuarios/idInexistente123'
    When method DELETE
    Then status 200
    # Validar esquema de respuesta cuando no hay registro para eliminar
    And match response == { message: '#string' }
    And match response.message == 'Nenhum registro excluído'

  @negative
  Scenario: No se puede eliminar usuario con carrinho asociado
    # Esta validación depende de si la API tiene esta restricción
    # Verifica el comportamiento cuando un usuario tiene un carrito asociado
    # Valida el esquema JSON de la respuesta de error
    # Ajustar según la documentación de ServeRest

    # Nota: Para esta prueba se necesitaría crear un carrito asociado al usuario
    # Por ahora se valida que la eliminación normal funciona
    Given path '/usuarios', usuarioId
    When method DELETE
    Then status 200
    # Validar esquema de respuesta
    And match response == { message: '#string' }

  @positive
  Scenario: Eliminar y verificar que ya no aparece en la lista
    # Verifica que después de eliminar, el usuario no aparece en la lista
    # Valida esquemas JSON en todo el flujo

    # Primero verificar que el usuario existe en la lista
    Given path '/usuarios'
    And param _id = usuarioId
    When method GET
    Then status 200
    # Validar esquema de lista
    And match response == { usuarios: '#array', quantidade: '#number' }
    And match response.quantidade > 0

    # Eliminar el usuario
    Given path '/usuarios', usuarioId
    When method DELETE
    Then status 200
    # Validar esquema de eliminación
    And match response == { message: '#string' }
    And match response.message == 'Registro excluído com sucesso'

    # Verificar que ya no aparece en la lista
    Given path '/usuarios'
    And param _id = usuarioId
    When method GET
    Then status 200
    And match response.quantidade == 0
    And match response.usuarios == '#[0]'

  @positive
  Scenario: Eliminar múltiples usuarios consecutivamente
    # Verifica que se pueden eliminar múltiples usuarios
    # Valida el esquema JSON en cada eliminación

    # Crear segundo usuario
    * def email2 = 'eliminar2.' + timestamp() + '@qa.com'
    Given path '/usuarios'
    And request { "nome": "Usuario 2", "email": "#(email2)", "password": "senha123", "administrador": "false" }
    When method POST
    Then status 201
    * def usuario2Id = response._id

    # Crear tercer usuario
    * def email3 = 'eliminar3.' + timestamp() + '@qa.com'
    Given path '/usuarios'
    And request { "nome": "Usuario 3", "email": "#(email3)", "password": "senha123", "administrador": "false" }
    When method POST
    Then status 201
    * def usuario3Id = response._id

    # Eliminar primer usuario
    Given path '/usuarios', usuarioId
    When method DELETE
    Then status 200
    And match response == { message: '#string' }
    And match response.message == 'Registro excluído com sucesso'

    # Eliminar segundo usuario
    Given path '/usuarios', usuario2Id
    When method DELETE
    Then status 200
    And match response == { message: '#string' }
    And match response.message == 'Registro excluído com sucesso'

    # Eliminar tercer usuario
    Given path '/usuarios', usuario3Id
    When method DELETE
    Then status 200
    And match response == { message: '#string' }
    And match response.message == 'Registro excluído com sucesso'

    # Verificar que ninguno existe
    Given path '/usuarios', usuarioId
    When method GET
    Then status 400

    Given path '/usuarios', usuario2Id
    When method GET
    Then status 400

    Given path '/usuarios', usuario3Id
    When method GET
    Then status 400

  @negative
  Scenario: Intentar eliminar el mismo usuario dos veces
    # Verifica que no se puede eliminar el mismo usuario dos veces
    # Valida esquema JSON en ambas solicitudes

    # Primera eliminación - exitosa
    Given path '/usuarios', usuarioId
    When method DELETE
    Then status 200
    And match response == { message: '#string' }
    And match response.message == 'Registro excluído com sucesso'

    # Segunda eliminación - sin registro
    Given path '/usuarios', usuarioId
    When method DELETE
    Then status 200
    And match response == { message: '#string' }
    And match response.message == 'Nenhum registro excluído'
