Feature: Generador de datos de prueba para usuarios
  # Este feature proporciona funciones reutilizables para generar
  # datos de usuario válidos e inválidos para las pruebas

  @Generar datos de usuario válido

  Scenario: Generar datos de usuario válido
    # Genera un objeto con datos de usuario válido usando timestamp para email único
    * def timestamp = function(){ return java.lang.System.currentTimeMillis() }
    * def userData =
    """
    {
      "nome": "Usuario Test Auto",
      "email": "usuario.test.#(timestamp())@qa.com",
      "password": "senhaSegura123",
      "administrador": "true"
    }
    """

  @Generar datos de usuario administrador

  Scenario: Generar datos de usuario administrador
    # Genera un usuario con privilegios de administrador
    * def timestamp = function(){ return java.lang.System.currentTimeMillis() }
    * def userData =
    """
    {
      "nome": "Admin Test",
      "email": "admin.test.#(timestamp())@qa.com",
      "password": "adminPassword123",
      "administrador": "true"
    }
    """

  @Generar datos de usuario no administrador

  Scenario: Generar datos de usuario no administrador
    # Genera un usuario sin privilegios de administrador
    * def timestamp = function(){ return java.lang.System.currentTimeMillis() }
    * def userData =
    """
    {
      "nome": "Usuario Normal",
      "email": "usuario.normal.#(timestamp())@qa.com",
      "password": "userPassword123",
      "administrador": "false"
    }
    """

  @Generar datos de usuario con email específico

  Scenario: Generar datos de usuario con email específico
    # Genera un usuario con un email específico proporcionado
    * def generateUserWithEmail =
    """
    function(email) {
      return {
        nome: "Usuario Especifico",
        email: email,
        password: "senha123",
        administrador: "true"
      }
    }
    """

  @Generar email único

  Scenario: Generar email único
    # Genera un email único usando timestamp
    * def timestamp = function(){ return java.lang.System.currentTimeMillis() }
    * def uniqueEmail = 'usuario.' + timestamp() + '@qa.com'
