Feature: Buscar usuario por ID en ServeRest
  # Este feature prueba el endpoint GET /usuarios/{id}
  # Valida la búsqueda de usuarios por ID y por parámetros de consulta

  Background:
    # Configuración base para todos los escenarios
    * url baseUrl
    # Función para generar timestamp único
    * def timestamp = function(){ return java.lang.System.currentTimeMillis() }
    # Email único para cada ejecución
    * def randomEmail = 'buscar' + timestamp() + '@qa.com'

    # Crear usuario de prueba para las búsquedas
    * path '/usuarios'
    * request { "nome": "Usuario Buscar", "email": "#(randomEmail)", "password": "senha123", "administrador": "true" }
    * method POST
    * status 201
    * def usuarioId = response._id

  @smoke
  Scenario: Buscar usuario existente por ID
    # Verifica que se puede obtener un usuario específico por su ID
    # Debe retornar status 200 con todos los datos del usuario
    Given path '/usuarios', usuarioId
    When method GET
    Then status 200
    And match response._id == usuarioId
    And match response.nome == 'Usuario Buscar'
    And match response.email == randomEmail

  @negative
  Scenario: Buscar usuario con ID inexistente
    # Verifica que el sistema maneja correctamente IDs que no existen
    # Debe retornar status 400 con mensaje específico
    Given path '/usuarios/idInexistente123'
    When method GET
    Then status 400
    And match response.message == 'Usuário não encontrado'

  @regression
  Scenario: Buscar usuario por nombre usando query params
    # Verifica que se pueden buscar usuarios por nombre usando parámetros de consulta
    # Debe retornar status 200 con la lista de usuarios que coinciden
    Given path '/usuarios'
    And param nome = 'Usuario Buscar'
    When method GET
    Then status 200
    And match response.usuarios[0].nome contains 'Usuario Buscar'
