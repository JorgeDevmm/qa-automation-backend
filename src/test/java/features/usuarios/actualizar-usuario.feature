Feature: Actualizar datos de usuario en ServeRest
  # Este feature prueba el endpoint PUT /usuarios/{id}
  # Valida la actualización de usuarios existentes

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

  @smoke @critical
  Scenario: Actualizar usuario existente exitosamente
    # Verifica que se pueden actualizar todos los campos de un usuario
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
    And match response.message == 'Registro alterado com sucesso'

  @negative
  Scenario: Fallar al actualizar con email duplicado
    # Verifica que no se puede actualizar un usuario con un email ya existente
    # Debe retornar status 400 con mensaje específico

    # Crear segundo usuario con email diferente
    * def emailDuplicado = 'duplicado' + timestamp() + '@qa.com'
    * path '/usuarios'
    * request { "nome": "Usuario Duplicado", "email": "#(emailDuplicado)", "password": "senha123", "administrador": "true" }
    * method POST
    * status 201

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
    And match response.message == 'Este email já está sendo usado'
