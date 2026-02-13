package features.usuarios;

import com.intuit.karate.junit5.Karate;

public class UsersTest {

    /**
     * Ejecuta todos los features del módulo de usuarios
     *
     * @return Configuración de Karate para ejecutar los tests
     */
    @Karate.Test
    Karate testAll() {
        return Karate.run("classpath:features/usuarios")
                .relativeTo(getClass());
    }

    /**
     * Ejecuta solo los tests marcados con @smoke
     * Útil para validaciones rápidas
     *
     * @return Configuración de Karate para ejecutar tests smoke
     */
    @Karate.Test
    Karate testSmoke() {
        return Karate.run("classpath:features/usuarios")
                .tags("@smoke")
                .relativeTo(getClass());
    }
}
