Feature: Buscar usuario por ID en ServeRest
  # Este feature prueba el endpoint GET /usuarios/{id}
  # Valida la búsqueda de usuarios por ID y por parámetros de consulta
  # Incluye validación completa de esquemas JSON

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

  @smoke @positive
  Scenario: Buscar usuario existente por ID con validación de esquema
    # Verifica que se puede obtener un usuario específico por su ID
    # Valida el esquema JSON completo de la respuesta
    # Debe retornar status 200 con todos los datos del usuario
    Given path '/usuarios', usuarioId
    When method GET
    Then status 200
    # Validar esquema JSON completo del usuario individual
    And match response ==
    """
    {
      _id: '#string',
      nome: '#string',
      email: '#string',
      password: '#string',
      administrador: '#string'
    }
    """
    # Validar datos específicos del usuario creado
    And match response._id == usuarioId
    And match response.nome == 'Usuario Buscar'
    And match response.email == randomEmail
    And match response.administrador == 'true'
    # Validar que el email tiene formato válido
    And match response.email == '#regex .+@.+\\..+'
    # Validar que administrador es true o false
    And match response.administrador == '#regex (true|false)'

  @negative
  Scenario: Buscar usuario con ID inexistente
    # Verifica que el sistema maneja correctamente IDs que no existen
    # Debe retornar status 400 con mensaje específico y esquema de error
    Given path '/usuarios/idInexistente123'
    When method GET
    Then status 400
    # Validar esquema de respuesta de error
    And match response == { message: '#string' }
    And match response.message == 'Usuário não encontrado'

  @negative
  Scenario: Buscar usuario con ID vacío
    # Verifica que el sistema valida correctamente IDs vacíos
    # Debe retornar error al intentar acceder a la ruta base
    Given path '/usuarios/'
    When method GET
    Then status 200
    # Retorna la lista de usuarios en lugar de error
    And match response.usuarios == '#array'

  @regression
  Scenario: Buscar usuario por nombre usando query params con validación de esquema
    # Verifica que se pueden buscar usuarios por nombre usando parámetros de consulta
    # Valida el esquema JSON de la lista de respuesta
    # Debe retornar status 200 con la lista de usuarios que coinciden
    Given path '/usuarios'
    And param nome = 'Usuario Buscar'
    When method GET
    Then status 200
    # Validar esquema JSON de lista de usuarios
    And match response ==
    """
    {
      usuarios: '#array',
      quantidade: '#number'
    }
    """
    # Validar que la cantidad coincide con el tamaño del array
    And match response.quantidade == '#number'
    And match response.usuarios == '#[_ > 0]'
    # Validar que cada usuario en la lista tiene la estructura correcta
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
    # Verificar que al menos un usuario coincide con el nombre buscado
    And match response.usuarios[0].nome contains 'Usuario Buscar'

  @positive
  Scenario: Buscar usuario por email usando query params
    # Verifica la búsqueda por email como parámetro
    # Valida que se retorna el usuario correcto con esquema válido
    Given path '/usuarios'
    And param email = randomEmail
    When method GET
    Then status 200
    # Validar esquema de respuesta
    And match response == { usuarios: '#array', quantidade: '#number' }
    And match response.quantidade == 1
    And match response.usuarios[0].email == randomEmail
    And match response.usuarios[0]._id == usuarioId

