Feature: Actualizar datos de usuario en ServeRest
  # Este feature prueba el endpoint PUT /usuarios/{id}
  # Valida la actualización de usuarios existentes
  # Incluye validación completa de esquemas JSON

  Background:
    # Configuración base para todos los escenarios
    * url baseUrl
    # Función para generar timestamp único
    * def timestamp = function(){ return java.lang.System.currentTimeMillis() }
    # Email único para cada ejecución
    * def randomEmail = 'actualizar' + timestamp() + '@qa.com'

    # Crear usuario para actualizar en las pruebas
    * path '/usuarios'
    * request { "nome": "Usuario Original", "email": "#(randomEmail)", "password": "senha123", "administrador": "true" }
    * method POST
    * status 201
    * def usuarioId = response._id

  @smoke @critical @positive
  Scenario: Actualizar usuario existente exitosamente con validación de esquema
    # Verifica que se pueden actualizar todos los campos de un usuario
    # Valida el esquema JSON de la respuesta de actualización
    # Debe retornar status 200 con mensaje de éxito
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
    # Validar esquema JSON de respuesta de actualización
    And match response == { message: '#string' }
    And match response.message == 'Registro alterado com sucesso'

    # Verificar que los cambios se aplicaron correctamente
    Given path '/usuarios', usuarioId
    When method GET
    Then status 200
    # Validar esquema del usuario actualizado
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
    And match response._id == usuarioId
    And match response.nome == nuevoNombre
    And match response.email == nuevoEmail
    And match response.administrador == 'false'

  @negative
  Scenario: Fallar al actualizar con email duplicado
    # Verifica que no se puede actualizar un usuario con un email ya existente
    # Valida el esquema JSON de respuesta de error
    # Debe retornar status 400 con mensaje específico

    # Crear segundo usuario con email diferente
    * def emailDuplicado = 'duplicado' + timestamp() + '@qa.com'
    * path '/usuarios'
    * request { "nome": "Usuario Duplicado", "email": "#(emailDuplicado)", "password": "senha123", "administrador": "true" }
    * method POST
    * status 201
    * def usuario2Id = response._id

    # Intentar actualizar el primer usuario con el email del segundo
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
    # Validar esquema de error
    And match response == { message: '#string' }
    And match response.message == 'Este email já está sendo usado'

    # Limpiar segundo usuario
    Given path '/usuarios', usuario2Id
    When method DELETE

  @negative
  Scenario: Intentar actualizar usuario inexistente (crea uno nuevo)
    # Verifica el comportamiento al actualizar un ID inexistente
    # La API de ServeRest crea un nuevo usuario en este caso
    # Valida el esquema JSON de respuesta
    * def idInexistente = 'idquenoexiste' + timestamp()
    * def nuevoEmail = 'nuevo.' + timestamp() + '@qa.com'

    Given path '/usuarios', idInexistente
    And request
      """
      {
        "nome": "Usuario Nuevo",
        "email": "#(nuevoEmail)",
        "password": "senha123",
        "administrador": "false"
      }
      """
    When method PUT
    Then status 201
    # Validar esquema de respuesta de creación
    And match response == { message: '#string', _id: '#string' }
    And match response.message == 'Cadastro realizado com sucesso'
    And match response._id != idInexistente

    # Limpiar usuario creado
    Given path '/usuarios', response._id
    When method DELETE

  @positive
  Scenario: Actualizar solo el nombre del usuario
    # Verifica que se puede actualizar parcialmente un usuario
    # Valida el esquema JSON y que solo cambia el campo modificado
    * def nuevoNombreSolo = 'Solo Nombre Actualizado'

    Given path '/usuarios', usuarioId
    And request
      """
      {
        "nome": "#(nuevoNombreSolo)",
        "email": "#(randomEmail)",
        "password": "senha123",
        "administrador": "true"
      }
      """
    When method PUT
    Then status 200
    # Validar esquema de respuesta
    And match response == { message: '#string' }
    And match response.message == 'Registro alterado com sucesso'

    # Verificar que solo el nombre cambió
    Given path '/usuarios', usuarioId
    When method GET
    Then status 200
    And match response.nome == nuevoNombreSolo
    And match response.email == randomEmail
    And match response.administrador == 'true'

  @positive
  Scenario: Cambiar usuario de administrador a no administrador
    # Verifica que se puede cambiar el rol de administrador
    # Valida el esquema JSON y el cambio de rol
    Given path '/usuarios', usuarioId
    And request
      """
      {
        "nome": "Usuario Original",
        "email": "#(randomEmail)",
        "password": "senha123",
        "administrador": "false"
      }
      """
    When method PUT
    Then status 200
    # Validar esquema
    And match response == { message: '#string' }

    # Verificar el cambio de rol
    Given path '/usuarios', usuarioId
    When method GET
    Then status 200
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
    And match response.administrador == 'false'

  @negative
  Scenario Outline: Validar campos obligatorios en actualización
    # Verifica que los campos obligatorios se validan en actualización
    # Valida el esquema JSON de errores de validación
    Given path '/usuarios', usuarioId
    And request <datos>
    When method PUT
    Then status 400
    # Validar que hay un error de validación
    And match response contains { <campo>: '#string' }

    Examples:
      | datos                                                                    | campo         |
      | { "email": "test@test.com", "password": "123", "administrador": "true" } | nome          |
      | { "nome": "Test", "password": "123", "administrador": "true" }           | email         |
      | { "nome": "Test", "email": "test@test.com", "administrador": "true" }    | password      |
      | { "nome": "Test", "email": "test@test.com", "password": "123" }          | administrador |

