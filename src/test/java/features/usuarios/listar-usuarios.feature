Feature: Listar usuarios del API ServeRest
  # Este feature prueba el endpoint GET /usuarios
  # Valida la lista de usuarios, paginación y filtros
  # Incluye validación completa de esquemas JSON

  Background:
    # Configuración base para todos los escenarios
    * url baseUrl
    * path '/usuarios'
    # Cargar esquemas de validación desde el helper
    * def esquemaLista = call read('helpers/schema-validators.feature@userListSchema')
    * def esquemaUsuario = call read('helpers/schema-validators.feature@userSchema')

  @smoke @regression @positive
  Scenario: Listar todos los usuarios exitosamente con validación de esquema
    # Verifica que el endpoint retorna la lista completa de usuarios
    # Valida el esquema JSON usando helper para mantener consistencia
    When method GET
    Then status 200
    # Validar esquema JSON usando el helper de validación
    And match response == esquemaLista.userListSchema
    # Validar que la cantidad es un número positivo
    And assert response.quantidade >= 0
    # Validar que cada usuario tiene la estructura correcta usando helper
    And match each response.usuarios == esquemaUsuario.userSchema
    # Validar formato de email y valor de administrador
    And match each response.usuarios contains { email: '#regex .+@.+\\..+' }
    And match each response.usuarios contains { administrador: '#regex (true|false)' }

  @smoke @positive
  Scenario: Validar estructura completa de cada usuario en la lista
    # Verifica que cada usuario en la lista tiene todos los campos requeridos
    # Usa esquemas del helper para garantizar consistencia en las validaciones
    When method GET
    Then status 200
    # Validar esquema principal usando helper
    And match response == esquemaLista.userListSchema
    # Validar estructura detallada de cada usuario usando helper
    And match each response.usuarios == esquemaUsuario.userSchema
    # Validar que todos los campos son not null
    And match each response.usuarios contains { _id: '#notnull' }
    And match each response.usuarios contains { nome: '#notnull' }
    And match each response.usuarios contains { email: '#notnull' }
    And match each response.usuarios contains { password: '#notnull' }
    And match each response.usuarios contains { administrador: '#notnull' }

  @regression @positive
  Scenario: Validar paginación de usuarios con límite de 5
    # Prueba la funcionalidad de paginación limitando los resultados a 5
    # Valida que el esquema JSON se mantiene con paginación
    Given param _limit = 5
    And param _page = 1
    When method GET
    Then status 200
    # Validar esquema JSON
    And match response == { usuarios: '#array', quantidade: '#number' }
    And match response.quantidade == '#number'
    # Validar que no retorna más de 5 usuarios
    And match response.usuarios == '#[_ <= 5]'
    # Validar estructura de cada usuario en la página
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

  @regression @positive
  Scenario: Validar paginación en segunda página
    # Verifica que la paginación funciona correctamente en páginas subsecuentes
    # Valida el esquema JSON en páginas diferentes
    Given param _limit = 3
    And param _page = 2
    When method GET
    Then status 200
    # Validar esquema JSON
    And match response == { usuarios: '#array', quantidade: '#number' }
    And match response.usuarios == '#array'
    # Si hay resultados, validar su estructura
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

  @negative
  Scenario: Intentar listar con parámetros inválidos
    # Verifica que el API maneja correctamente parámetros inválidos
    # El API debe responder sin errores aunque el parámetro sea negativo
    # Valida que el esquema JSON se mantiene correcto
    Given param _limit = -1
    When method GET
    Then status 200
    # Validar que el esquema sigue siendo válido
    And match response == { usuarios: '#array', quantidade: '#number' }
    And match response.usuarios == '#array'

  @smoke @positive
  Scenario: Validar que la lista no esté vacía
    # Verifica que existen usuarios registrados en el sistema
    # Valida el esquema JSON y que hay datos
    When method GET
    Then status 200
    # Validar esquema
    And match response == { usuarios: '#array', quantidade: '#number' }
    # Validar que hay al menos un usuario
    And assert response.quantidade > 0
    And match response.usuarios == '#[_ > 0]'

  @regression @positive
  Scenario: Buscar usuario específico por email con validación completa
    # Crea un usuario, lo busca por email y luego lo elimina
    # para mantener limpia la base de datos de prueba
    # Valida esquemas JSON en todo el flujo

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
    # Validar esquema de respuesta de creación
    And match response ==
    """
    {
      message: '#string',
      _id: '#string'
    }
    """
    And match response.message == 'Cadastro realizado com sucesso'
    * def createdUserId = response._id

    # Buscar el usuario creado por email
    Given url baseUrl
    And path '/usuarios'
    And param email = uniqueEmail
    When method GET
    Then status 200
    # Validar esquema de respuesta de búsqueda
    And match response == { usuarios: '#array', quantidade: '#number' }
    And match response.quantidade == 1
    # Validar estructura del usuario encontrado
    And match response.usuarios[0] ==
    """
    {
      _id: '#string',
      nome: '#string',
      email: '#string',
      password: '#string',
      administrador: '#string'
    }
    """
    And match response.usuarios[0].email == uniqueEmail
    And match response.usuarios[0]._id == createdUserId

    # Limpiar: eliminar el usuario creado
    Given url baseUrl
    And path '/usuarios', createdUserId
    When method DELETE
    Then status 200
    # Validar esquema de respuesta de eliminación
    And match response == { message: '#string' }
    And match response.message == 'Registro excluído com sucesso'

  @negative
  Scenario: Buscar usuario con filtro que no existe
    # Verifica que al buscar con filtro inexistente retorna lista vacía
    # Valida el esquema JSON con resultado vacío
    Given path '/usuarios'
    And param email = 'noexiste' + java.lang.System.currentTimeMillis() + '@test.com'
    When method GET
    Then status 200
    # Validar esquema con lista vacía
    And match response == { usuarios: '#array', quantidade: '#number' }
    And match response.quantidade == 0
    And match response.usuarios == '#[0]'

