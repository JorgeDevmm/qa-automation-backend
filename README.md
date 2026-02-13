# 🚀 Automatización de Pruebas para API ServeRest

¡Bienvenido! Este proyecto contiene pruebas automatizadas para el API de gestión de usuarios
de [ServeRest](https://serverest.dev/).

Aquí probamos que todo funcione correctamente: desde crear un usuario nuevo, hasta buscarlo, actualizarlo y eliminarlo.

---

## 📋 ¿Qué encontrarás aquí?

Este proyecto automatiza las pruebas de los **5 endpoints principales** del API de usuarios:

- 📄 **Listar usuarios** - Ver todos los usuarios registrados
- ➕ **Crear usuario** - Registrar un nuevo usuario
- 🔍 **Buscar usuario** - Encontrar un usuario específico por su ID
- ✏️ **Actualizar usuario** - Modificar la información de un usuario
- 🗑️ **Eliminar usuario** - Borrar un usuario del sistema

Cada endpoint tiene pruebas que verifican que funcione bien (casos positivos) y que detecte errores correctamente (casos
negativos).

---

## 🛠️ ¿Qué necesitas para empezar?

### Requisitos previos

Antes de ejecutar las pruebas, asegúrate de tener instalado:

1. **Java JDK 11 o superior**
    - [Descargar Java](https://www.oracle.com/java/technologies/downloads/)
    - Para verificar si ya lo tienes: abre una terminal y escribe `java -version`

2. **Maven 3.6 o superior**
    - [Descargar Maven](https://maven.apache.org/download.cgi)
    - Para verificar si ya lo tienes: escribe `mvn -version`

3. **Internet**
    - Las pruebas se conectan al API en https://serverest.dev/

### ¿Cómo sé si tengo todo instalado?

Abre una terminal (CMD, PowerShell o Git Bash) y ejecuta:

```bash
java -version
mvn -version
```

Si ves información de las versiones, ¡estás listo! Si no, instala lo que te falte.

---

## 📥 Descargar el proyecto

### Opción 1: Clonar con Git

```bash
git clone https://github.com/tu-usuario/qa-automation-backend.git
cd qa-automation-backend
```

### Opción 2: Descargar ZIP

1. Haz clic en el botón verde "Code" en GitHub
2. Selecciona "Download ZIP"
3. Extrae el archivo
4. Abre la carpeta en tu terminal

---

## ▶️ ¿Cómo ejecutar las pruebas?

### 🎯 Ejecutar TODAS las pruebas

Este comando ejecuta todos los tests de una vez:

```bash
mvn clean test
```

**¿Qué hace este comando?**

- `clean` - Limpia resultados de ejecuciones anteriores
- `test` - Ejecuta todas las pruebas

Verás en la consola cómo se van ejecutando las pruebas una por una. Al final, te dirá cuántas pasaron ✅ y cuántas
fallaron ❌.

### 🏷️ Ejecutar solo las pruebas importantes (smoke tests)

Si tienes poco tiempo y solo quieres verificar lo básico:

```bash
mvn test -Dkarate.options="--tags @smoke"
```

Esto ejecuta solo las pruebas marcadas como `@smoke` (las más importantes).

### 🔄 Ejecutar pruebas de regresión completa

Para ejecutar todas las pruebas de regresión:

```bash
mvn test -Dkarate.options="--tags @regression"
```

### 🚨 Ejecutar solo pruebas críticas

Para ejecutar únicamente las pruebas críticas del sistema:

```bash
mvn test -Dkarate.options="--tags @critical"
```

### 📝 Ejecutar un archivo específico

Si solo quieres probar un endpoint en particular:

**Listar usuarios:**

```bash
mvn test -Dkarate.options="classpath:features/usuarios/listar-usuarios.feature"
```

**Crear usuario:**

```bash
mvn test -Dkarate.options="classpath:features/usuarios/registrar-usuario.feature"
```

**Buscar usuario:**

```bash
mvn test -Dkarate.options="classpath:features/usuarios/buscar-usuario.feature"
```

**Actualizar usuario:**

```bash
mvn test -Dkarate.options="classpath:features/usuarios/actualizar-usuario.feature"
```

**Eliminar usuario:**

```bash
mvn test -Dkarate.options="classpath:features/usuarios/eliminar-usuario.feature"
```

---

## 📊 Ver los resultados

### Resultados en la consola

Después de ejecutar las pruebas, verás algo como esto:

```
Tests run: 32, Failures: 0, Errors: 0, Skipped: 0
```

- ✅ **Tests run** - Total de pruebas ejecutadas
- ❌ **Failures** - Pruebas que fallaron
- 🚫 **Errors** - Pruebas con errores técnicos
- ⏭️ **Skipped** - Pruebas omitidas

### Reportes HTML (¡más bonitos!)

Karate genera reportes visuales muy útiles. Después de ejecutar las pruebas:

1. Ve a la carpeta: `target/karate-reports/`
2. Abre el archivo `karate-summary.html` en tu navegador

Aquí verás:

- 📊 Gráficos de resultados
- ⏱️ Tiempo de ejecución de cada prueba
- 📸 Capturas de las respuestas del API
- 🔍 Detalles de cada paso ejecutado

**Atajos rápidos:**

En Windows:

```bash
start target/karate-reports/karate-summary.html
```

En Mac:

```bash
open target/karate-reports/karate-summary.html
```

En Linux:

```bash
xdg-open target/karate-reports/karate-summary.html
```

---

## 📁 Estructura del proyecto

Aquí te explico qué hay en cada carpeta:

```
qa-automation-backend/
├── 📄 pom.xml                          # Configuración de Maven (dependencias)
├── 📖 README.md                        # Este archivo que estás leyendo
├── 📊 VERIFICACION_CUMPLIMIENTO.md    # Análisis completo del proyecto
│
└── src/test/java/
    ├── ⚙️ karate-config.js            # Configuración global (URL base, etc.)
    │
    └── features/usuarios/
        ├── 📝 listar-usuarios.feature      # Pruebas de GET /usuarios
        ├── 📝 registrar-usuario.feature    # Pruebas de POST /usuarios
        ├── 📝 buscar-usuario.feature       # Pruebas de GET /usuarios/{id}
        ├── 📝 actualizar-usuario.feature   # Pruebas de PUT /usuarios/{id}
        ├── 📝 eliminar-usuario.feature     # Pruebas de DELETE /usuarios/{id}
        │
        ├── 🏃 UsersTest.java              # Ejecutor de pruebas de usuarios
        │
        └── helpers/                        # Utilidades reutilizables
            ├── schema-validators.feature   # Validadores de esquemas JSON
            └── user-data-generator.feature # Generadores de datos de prueba
```

---

## 🎯 ¿Qué hace cada archivo de pruebas?

### 📝 listar-usuarios.feature

**Endpoint:** `GET /usuarios`

Prueba que puedas ver la lista de todos los usuarios. Verifica:

- ✅ Que la lista se reciba correctamente
- ✅ Que cada usuario tenga todos sus datos (nombre, email, etc.)
- ✅ Que funcione la paginación (mostrar 5 usuarios por página, por ejemplo)
- ✅ Que puedas buscar usuarios por email
- ❌ Que maneje bien parámetros incorrectos

**Total:** 8 escenarios de prueba

### 📝 registrar-usuario.feature

**Endpoint:** `POST /usuarios`

Prueba que puedas crear nuevos usuarios. Verifica:

- ✅ Que se cree un usuario con datos válidos
- ✅ Que se pueda crear tanto administradores como usuarios normales
- ❌ Que no permita emails duplicados
- ❌ Que exija todos los campos obligatorios
- ❌ Que valide el formato del email

**Total:** 6 escenarios de prueba

### 📝 buscar-usuario.feature

**Endpoint:** `GET /usuarios/{id}`

Prueba que puedas buscar un usuario específico. Verifica:

- ✅ Que encuentre un usuario por su ID
- ✅ Que puedas buscar por email
- ✅ Que puedas buscar por nombre
- ❌ Que informe cuando un usuario no existe

**Total:** 5 escenarios de prueba

### 📝 actualizar-usuario.feature

**Endpoint:** `PUT /usuarios/{id}`

Prueba que puedas modificar usuarios existentes. Verifica:

- ✅ Que actualice correctamente todos los datos
- ✅ Que puedas cambiar el rol (admin/usuario normal)
- ✅ Que puedas actualizar solo algunos campos
- ❌ Que no permita usar un email ya registrado
- ❌ Que valide todos los campos obligatorios

**Total:** 7 escenarios de prueba

### 📝 eliminar-usuario.feature

**Endpoint:** `DELETE /usuarios/{id}`

Prueba que puedas borrar usuarios. Verifica:

- ✅ Que elimine un usuario correctamente
- ✅ Que el usuario ya no aparezca en la lista
- ✅ Que se puedan eliminar varios usuarios seguidos
- ❌ Que informe cuando intentas eliminar un usuario que no existe
- ❌ Que no permita eliminar el mismo usuario dos veces

**Total:** 6 escenarios de prueba

---

## 🏷️ Tags de las pruebas

Los tests están organizados con etiquetas para que puedas ejecutar grupos específicos:

| Tag           | ¿Qué significa?                | Cuándo usarlo                         |
|---------------|--------------------------------|---------------------------------------|
| `@smoke`      | Pruebas básicas y rápidas      | Para verificaciones rápidas (5 min)   |
| `@regression` | Pruebas completas de regresión | Antes de subir cambios importantes    |
| `@positive`   | Pruebas de casos exitosos      | Para verificar funcionalidad correcta |
| `@negative`   | Pruebas de casos de error      | Para verificar manejo de errores      |
| `@critical`   | Pruebas críticas del sistema   | Las que no pueden fallar nunca        |

**Ejemplos de uso:**

```bash
# Solo pruebas rápidas (5 minutos aprox)
mvn test -Dkarate.options="--tags @smoke"

# Solo casos de error
mvn test -Dkarate.options="--tags @negative"

# Pruebas críticas + smoke
mvn test -Dkarate.options="--tags @critical,@smoke"
```

---

## 🔧 Tecnologías utilizadas

Este proyecto usa las siguientes herramientas:

- **[Karate DSL](https://github.com/karatelabs/karate)** - Framework para pruebas de API (fácil de leer y escribir)
- **[JUnit 5](https://junit.org/junit5/)** - Para ejecutar las pruebas
- **[Maven](https://maven.apache.org/)** - Para gestionar dependencias y compilar
- **Java 11+** - Lenguaje de programación base

### ¿Por qué Karate?

Karate es genial porque:

- ✅ No necesitas saber mucho código
- ✅ Se lee como lenguaje humano (Gherkin)
- ✅ Valida JSON automáticamente
- ✅ Genera reportes visuales hermosos
- ✅ No necesita configuración compleja

---

## 🐛 ¿Problemas comunes?

### "mvn: command not found"

**Problema:** Maven no está instalado o no está en el PATH.

**Solución:**

1. Instala Maven desde https://maven.apache.org/download.cgi
2. Añade Maven al PATH de tu sistema
3. Reinicia la terminal

### "JAVA_HOME not set"

**Problema:** Java no está configurado correctamente.

**Solución:**

1. Verifica que Java esté instalado: `java -version`
2. Configura la variable JAVA_HOME:
    - Windows: `setx JAVA_HOME "C:\Program Files\Java\jdk-11"`
    - Mac/Linux: `export JAVA_HOME=/path/to/java`

### Las pruebas fallan con "Connection refused"

**Problema:** No hay conexión a internet o el API está caído.

**Solución:**

1. Verifica tu conexión a internet
2. Intenta abrir https://serverest.dev/ en tu navegador
3. Si el sitio no carga, espera unos minutos y reintenta

### Error: "Test failures exist"

**Problema:** Algunas pruebas fallaron.

**Solución:**

1. Revisa el reporte HTML en `target/karate-reports/karate-summary.html`
2. Busca los tests marcados en rojo
3. Lee el mensaje de error para entender qué salió mal
4. Puede ser un problema temporal del API - intenta ejecutar de nuevo

---

## 📚 ¿Quieres aprender más?

### Documentación útil

- **[API ServeRest](https://serverest.dev/)** - Documentación del API que estamos probando
- **[Karate DSL](https://github.com/karatelabs/karate)** - Documentación oficial de Karate
- **[Maven](https://maven.apache.org/guides/getting-started/)** - Guía de Maven para principiantes

### Ver ejemplos de código

Todos los archivos `.feature` tienen comentarios explicando qué hace cada parte. ¡Ábrelos y explora!

Empieza por el más simple:

- `src/test/java/features/usuarios/listar-usuarios.feature`

---

## 📊 Estadísticas del proyecto

- **Total de pruebas:** 32 escenarios
- **Endpoints cubiertos:** 5 (GET, POST, PUT, DELETE)
- **Casos positivos:** 20 (62.5%)
- **Casos negativos:** 12 (37.5%)
- **Validación de esquemas JSON:** ✅ 100%
- **Helpers reutilizables:** 2

---

## 🤝 Contribuir

¿Quieres agregar más pruebas o mejorar las existentes?

1. Haz un fork del proyecto
2. Crea una rama para tu feature: `git checkout -b feature/nueva-prueba`
3. Haz tus cambios y commit: `git commit -m "Agregar prueba de X"`
4. Push a tu rama: `git push origin feature/nueva-prueba`
5. Abre un Pull Request

---

## 📞 ¿Necesitas ayuda?

Si tienes problemas o preguntas:

1. Revisa la sección "Problemas comunes" arriba
2. Mira el archivo `VERIFICACION_CUMPLIMIENTO.md` para detalles técnicos
3. Abre un issue en GitHub con tu pregunta

---

## ✅ Checklist rápido

Antes de entregar o presentar, verifica:

- [ ] Las pruebas se ejecutan sin errores: `mvn clean test`
- [ ] Los reportes se generan correctamente
- [ ] Todos los features tienen comentarios claros
- [ ] El código está subido a GitHub
- [ ] Este README está actualizado




