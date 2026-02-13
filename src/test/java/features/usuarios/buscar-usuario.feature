Feature: Buscar usuario por ID en ServeRest

  Background:
    * url baseUrl
    * def timestamp = function(){ return java.lang.System.currentTimeMillis() }
    * def randomEmail = 'buscar' + timestamp() + '@qa.com'

    # Crear usuario para las pruebas
    * path '/usuarios'
    * request { "nome": "Usuario Buscar", "email": "#(randomEmail)", "password": "senha123", "administrador": "true" }
    * method POST
    * status 201
    * def usuarioId = response._id

  @smoke
  Scenario: Buscar usuario existente por ID
    Given path '/usuarios', usuarioId
    When method GET
    Then status 200
    And match response._id == usuarioId
    And match response.nome == 'Usuario Buscar'
    And match response.email == randomEmail

  @negative
  Scenario: Buscar usuario con ID inexistente
    Given path '/usuarios/idInexistente123'
    When method GET
    Then status 400
    And match response.message == 'Usuário não encontrado'

  @regression
  Scenario: Buscar usuario por nombre usando query params
    Given path '/usuarios'
    And param nome = 'Usuario Buscar'
    When method GET
    Then status 200
    And match response.usuarios[0].nome contains 'Usuario Buscar'
