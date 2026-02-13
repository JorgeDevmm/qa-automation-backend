Feature: Listar usuarios del API ServeRest
  # Este feature prueba el endpoint GET /usuarios
  # Valida la lista de usuarios, paginación y filtros

  Background:
    # Configuración base para todos los escenarios
    * url baseUrl
    * path '/usuarios'

  @smoke @regression
  Scenario: Listar todos los usuarios exitosamente
    # Verifica que el endpoint retorna la lista completa de usuarios
    # con la estructura esperada
    When method GET
    Then status 200
    And match response.usuarios == '#array'
    And match response.quantidade == '#number'
    And match each response.usuarios contains { _id: '#string', nome: '#string', email: '#string' }

  @smoke
  Scenario: Validar estructura completa de cada usuario en la lista
    # Verifica que cada usuario en la lista tiene todos los campos requeridos
    # con los tipos de datos correctos
    When method GET
    Then status 200
    And match each response.usuarios ==
    """
    {
      _id: '#string',
      nome: '#string',
      email: '#string',
      password: '#string',
      administrador: '#string'
    }
    """

  @regression
  Scenario: Validar paginación de usuarios con límite de 5
    # Prueba la funcionalidad de paginación limitando los resultados a 5
    Given param _limit = 5
    And param _page = 1
    When method GET
    Then status 200
    And match response.quantidade == '#number'
    And match response.usuarios == '#[_ <= 5]'

  @regression
  Scenario: Validar paginación en segunda página
    # Verifica que la paginación funciona correctamente en páginas subsecuentes
    Given param _limit = 3
    And param _page = 2
    When method GET
    Then status 200
    And match response.usuarios == '#array'

  @negative
  Scenario: Intentar listar con parámetros inválidos
    # Verifica que el API maneja correctamente parámetros inválidos
    # El API debe responder sin errores aunque el parámetro sea negativo
    Given param _limit = -1
    When method GET
    Then status 200
    And match response.usuarios == '#array'

  @smoke
  Scenario: Validar que la lista no esté vacía
    # Verifica que existen usuarios registrados en el sistema
    When method GET
    Then status 200
    And assert response.quantidade > 0

  @regression
  Scenario: Buscar usuario específico por email
    # Crea un usuario, lo busca por email y luego lo elimina
    # para mantener limpia la base de datos de prueba

    # Generar datos únicos para el usuario de prueba
    * def timestamp = function(){ return java.lang.System.currentTimeMillis() }
    * def uniqueEmail = 'test.listar.' + timestamp() + '@qa.com'
    * def testUser =
    """
    {
      "nome": "Usuario Test Listar",
      "email": "#(uniqueEmail)",
      "password": "senha123",
      "administrador": "true"
    }
    """

    # Crear usuario de prueba
    Given url baseUrl
    And path '/usuarios'
    And request testUser
    When method POST
    Then status 201
    * def createdUserId = response._id

    # Buscar el usuario creado por email
    Given url baseUrl
    And path '/usuarios'
    And param email = uniqueEmail
    When method GET
    Then status 200
    And match response.usuarios[0].email == uniqueEmail
    And match response.usuarios[0]._id == createdUserId

    # Limpiar: eliminar el usuario creado
    Given url baseUrl
    And path '/usuarios', createdUserId
    When method DELETE
    Then status 200
    And match response.message == 'Registro excluído com sucesso'
