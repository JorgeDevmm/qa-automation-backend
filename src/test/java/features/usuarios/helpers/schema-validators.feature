Feature: Validadores de esquema para las respuestas del API
  # Este feature contiene los esquemas de validación reutilizables
  # para verificar la estructura de las respuestas del API ServeRest

  @userListSchema
  Scenario: Esquema de validación para lista de usuarios
    # Define el esquema esperado para la respuesta al listar usuarios
    * def userListSchema =
    """
    {
      usuarios: '#array',
      quantidade: '#number'
    }
    """

  @userSchema
  Scenario: Esquema de validación para un usuario individual
    # Define el esquema esperado para un usuario individual
    * def userSchema =
    """
    {
      _id: '#string',
      nome: '#string',
      email: '#string',
      password: '#string',
      administrador: '#string'
    }
    """

  @createUserResponseSchema
  Scenario: Esquema de validación para respuesta de creación de usuario
    # Define el esquema esperado al crear un usuario exitosamente
    * def createUserResponseSchema =
    """
    {
      message: '#string',
      _id: '#string'
    }
    """

  @updateUserResponseSchema
  Scenario: Esquema de validación para respuesta de actualización de usuario
    # Define el esquema esperado al actualizar un usuario
    * def updateUserResponseSchema =
    """
    {
      message: '#string'
    }
    """

  @deleteUserResponseSchema
  Scenario: Esquema de validación para respuesta de eliminación de usuario
    # Define el esquema esperado al eliminar un usuario
    * def deleteUserResponseSchema =
    """
    {
      message: '#string'
    }
    """

  @errorResponseSchema
  Scenario: Esquema de validación para respuestas de error
    # Define el esquema esperado para mensajes de error
    * def errorResponseSchema =
    """
    {
      message: '#string'
    }
    """
