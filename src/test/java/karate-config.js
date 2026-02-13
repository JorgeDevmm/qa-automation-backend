function fn() {
    var env = karate.env; // Obtiene la variable de entorno 'karate.env'
    karate.log('karate.env system property was:', env);

    // Si no se especifica entorno, usar 'dev' por defecto
    if (!env) {
        env = 'dev';
    }
    var config = {
        env: env,
        baseUrl: 'https://serverest.dev', // URL base de la API ServeRest

        // Headers HTTP comunes que se usarán en todas las peticiones
        headers: {
            'Content-Type': 'application/json', // Indica que enviamos JSON
            'Accept': 'application/json'        // Indica que esperamos recibir JSON
        },

        // Códigos de estado HTTP como variables reutilizables
        assertions: {
            statusOk: 200,           // Petición exitosa
            statusCreated: 201,      // Recurso creado exitosamente
            statusBadRequest: 400,   // Error en la petición
            statusNotFound: 404      // Recurso no encontrado
        },

        // Tiempo máximo de espera para las peticiones (en milisegundos)
        timeout: 10000  // 10 segundos
    };


    return config; // Retorna la configuración para ser usada en los features
}