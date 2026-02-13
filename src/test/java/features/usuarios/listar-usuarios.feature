Feature: Listar usuarios del API ServeRest

  Background:
    * url baseUrl
    * path '/usuarios'
    # Cargar esquemas de validación
    * def schemas = call read('helpers/schema-validators.feature@userListSchema')

  @smoke @regression
  Scenario: Listar todos los usuarios exitosamente
    When method GET
    Then status 200
    And match response.usuarios == '#array'
    And match response.quantidade == '#number'
    And match response == schemas.userListSchema
    And match each response.usuarios contains { _id: '#string', nome: '#string', email: '#string' }

  @smoke
  Scenario: Validar estructura de cada usuario en la lista
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
    Given param _limit = 5
    And param _page = 1
    When method GET
    Then status 200
    And match response.quantidade == '#number'
    And match response.usuarios == '#[_ <= 5]'

  @regression
  Scenario: Validar paginación en segunda página
    Given param _limit = 3
    And param _page = 2
    When method GET
    Then status 200
    And match response.usuarios == '#array'

  @negative
  Scenario: Intentar listar con parámetros inválidos
    Given param _limit = -1
    When method GET
    Then status 200
    And match response.usuarios == '#array'

  @smoke
  Scenario: Validar que la lista no esté vacía
    When method GET
    Then status 200
    And assert response.quantidade > 0

  @regression
  Scenario: Buscar usuario por email existente
    # Primero crear un usuario para garantizar que existe
    * def testUser = call read('helpers/user-data-generator.feature@Generar datos de usuario válido')
    Given url baseUrl
    And path '/usuarios'
    And request testUser.userData
    When method POST
    Then status 201
    * def createdUserId = response._id

    # Buscar ese usuario en la lista
    Given url baseUrl
    And path '/usuarios'
    And param email = testUser.userData.email
    When method GET
    Then status 200
    And match response.usuarios[0].email == testUser.userData.email

    # Limpiar el usuario creado
    Given url baseUrl
    And path '/usuarios', createdUserId
    When method DELETE
    Then status 200
