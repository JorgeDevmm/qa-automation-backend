# 📋 Estrategia de Automatización - API ServeRest

## 📌 Resumen Ejecutivo

Este documento describe el enfoque, patrones y decisiones técnicas utilizadas para automatizar las pruebas del API de
Usuarios de ServeRest.

---

## 🎯 Objetivo de la Automatización

Crear una suite de pruebas automatizadas confiable, mantenible y escalable que valide el correcto funcionamiento del API
de gestión de usuarios, asegurando:

- ✅ Funcionalidad correcta de todas las operaciones CRUD
- ✅ Validación exhaustiva de respuestas y esquemas JSON
- ✅ Detección temprana de regresiones
- ✅ Cobertura de casos positivos y negativos
- ✅ Documentación clara del comportamiento del sistema

---

## 🏗️ Arquitectura de Pruebas

### Estructura de Capas

```
┌─────────────────────────────────────┐
│   Features de Alto Nivel (BDD)      │  ← Lenguaje humano (Gherkin)
├─────────────────────────────────────┤
│   Helpers y Utilidades               │  ← Código reutilizable
├─────────────────────────────────────┤
│   Karate DSL Engine                  │  ← Motor de ejecución
├─────────────────────────────────────┤
│   API ServeRest (https://...)       │  ← Sistema bajo prueba
└─────────────────────────────────────┘
```

### Principios de Diseño

1. **Separation of Concerns** - Cada feature se enfoca en un endpoint específico
2. **DRY (Don't Repeat Yourself)** - Helpers reutilizables para funciones comunes
3. **Single Responsibility** - Un escenario prueba un comportamiento específico
4. **Self-Documenting Code** - Comentarios claros en español
5. **Test Independence** - Cada prueba es independiente y auto-contenida

---

## 🎨 Patrones de Diseño Utilizados

### 1. Page Object Pattern (Adaptado para API)

En lugar de objetos de página, usamos **Feature Objects**:

```
features/usuarios/
├── listar-usuarios.feature      → Objeto "Listar"
├── registrar-usuario.feature    → Objeto "Registrar"
├── buscar-usuario.feature       → Objeto "Buscar"
├── actualizar-usuario.feature   → Objeto "Actualizar"
└── eliminar-usuario.feature     → Objeto "Eliminar"
```

**Beneficio:** Cada feature encapsula todas las pruebas de un endpoint específico.

### 2. Data Builder Pattern

Generación dinámica de datos de prueba:

```gherkin
* def timestamp = function(){ return java.lang.System.currentTimeMillis() }
* def randomEmail = 'usuario' + timestamp() + '@qa.com'
```

**Beneficio:** Datos únicos en cada ejecución, evitando conflictos.

### 3. Test Fixture Pattern

Uso de `Background` para configuración común:

```gherkin
Background:
* url baseUrl
* def timestamp = function(){ return java.lang.System.currentTimeMillis() }
```

**Beneficio:** Reduce duplicación y asegura configuración consistente.

### 4. Helper/Utility Pattern

Archivos reutilizables en carpeta `helpers/`:

```
helpers/
├── schema-validators.feature
└── user-data-generator.feature
```

**Beneficio:** Código compartido y mantenible en un solo lugar.

### 5. Arrange-Act-Assert Pattern

Estructura clara en cada escenario:

```gherkin
# ARRANGE - Preparar datos
* def nuevoUsuario = {...}

# ACT - Ejecutar acción
Given path '/usuarios'
And request nuevoUsuario
When method POST

# ASSERT - Verificar resultado
Then status 201
And match response == {...}
```

**Beneficio:** Tests legibles y fáciles de mantener.

---

## 🧪 Estrategia de Cobertura

### Enfoque Piramidal de Pruebas

```
        ╱╲
       ╱  ╲     E2E (Mínimas)
      ╱────╲
     ╱      ╲   Integration (Algunas)
    ╱────────╲
   ╱          ╲ API Tests (Mayoría) ← Nuestro foco
  ╱────────────╲
 ╱              ╲
╱────────────────╲ Unit Tests (Muchas)
```

**Decisión:** Enfocarnos en pruebas de API por ser el contrato entre sistemas.

### Cobertura por Tipo de Caso

| Tipo      | Cantidad | %     | Justificación                  |
|-----------|----------|-------|--------------------------------|
| Positivos | 20       | 62.5% | Validar funcionalidad correcta |
| Negativos | 12       | 37.5% | Validar manejo de errores      |

**Ratio óptimo:** 60-40, priorizando casos positivos sin descuidar validaciones de error.

### Matriz de Cobertura CRUD

| Operación   | Endpoint              | Casos + | Casos - | Total  |
|-------------|-----------------------|---------|---------|--------|
| Create      | POST /usuarios        | 3       | 3       | 6      |
| Read (List) | GET /usuarios         | 6       | 2       | 8      |
| Read (ID)   | GET /usuarios/{id}    | 3       | 2       | 5      |
| Update      | PUT /usuarios/{id}    | 4       | 3       | 7      |
| Delete      | DELETE /usuarios/{id} | 4       | 2       | 6      |
| **TOTAL**   | -                     | **20**  | **12**  | **32** |

---

## ✅ Validaciones Implementadas

### 1. Validación de Esquemas JSON

**Decisión técnica:** Validar estructura completa de respuestas, no solo valores.

```gherkin
And match response ==
"""
{
  usuarios: '#array',
  quantidade: '#number'
}
"""
```

**Beneficio:** Detecta cambios en contratos de API tempranamente.

### 2. Validación de Tipos de Datos

```gherkin
And match response._id == '#string'
And match response.email == '#regex .+@.+\\..+'
And match response.administrador == '#regex (true|false)'
```

**Beneficio:** Asegura consistencia de tipos de datos.

### 3. Validación de Estados HTTP

```gherkin
Then status 201  # Created
Then status 200  # OK
Then status 400  # Bad Request
```

**Beneficio:** Verifica respuestas HTTP correctas del servidor.

### 4. Validación de Mensajes

```gherkin
And match response.message == 'Cadastro realizado com sucesso'
```

**Beneficio:** Valida mensajes de usuario y localización.

---

## 🏷️ Estrategia de Etiquetado (Tags)

### Sistema de Tags Implementado

```gherkin
@smoke @critical @positive
```

| Tag           | Propósito                  | Cuándo ejecutar        |
|---------------|----------------------------|------------------------|
| `@smoke`      | Pruebas críticas y rápidas | En cada commit         |
| `@regression` | Suite completa             | Antes de release       |
| `@positive`   | Casos de éxito             | Validación funcional   |
| `@negative`   | Casos de error             | Validación de robustez |
| `@critical`   | Flujos críticos de negocio | En cada build          |

**Ventaja:** Permite ejecuciones selectivas según contexto.

### Estrategia de Ejecución

```bash
# Pipeline de CI/CD
1. Pre-commit  → @smoke (5 min)
2. Pull Request → @smoke + @critical (10 min)
3. Merge to dev → @regression (15-20 min)
4. Release     → Full suite (20-25 min)
```

---

## 🔄 Manejo de Datos de Prueba

### Estrategia: "Create-Use-Delete"

```gherkin
# 1. CREATE - Crear datos para la prueba
* request { "nome": "Test", "email": "#(randomEmail)" }
* method POST

# 2. USE - Usar en la prueba
* def userId = response._id

# 3. DELETE - Limpiar después
Given path '/usuarios', userId
When method DELETE
```

**Beneficio:**

- ✅ Tests independientes
- ✅ Sin contaminación de datos
- ✅ Reproducible en cualquier ambiente

### Generación de Datos Únicos

```gherkin
* def timestamp = function(){ return java.lang.System.currentTimeMillis() }
* def randomEmail = 'usuario' + timestamp() + '@qa.com'
```

**Decisión:** Usar timestamp en lugar de random UUID por:

- ✅ Más legible en logs
- ✅ Ordenable cronológicamente
- ✅ Suficientemente único para pruebas

---

## 📊 Reportes y Observabilidad

### Niveles de Reporting

1. **Console Output** - Feedback inmediato durante ejecución
2. **HTML Reports** - Reporte visual detallado post-ejecución
3. **JSON Output** - Para integración con dashboards

### Información Capturada

```
Cada escenario registra:
├── ✅ Status (Pass/Fail)
├── ⏱️ Tiempo de ejecución
├── 📋 Request completo
├── 📄 Response completo
├── 🔍 Assertions ejecutadas
└── ❌ Stack trace si falla
```

---

## 🚀 Estrategia de Ejecución

### Ambientes de Prueba

```
┌──────────────┐
│   Ambiente   │  URL
├──────────────┤
│ Development  │  https://serverest.dev/
│ Staging      │  (Mismo endpoint por ahora)
│ Production   │  (Solo smoke tests)
└──────────────┘
```

**Configuración:** Variable `baseUrl` en `karate-config.js`

### Frecuencia de Ejecución

| Evento        | Suite              | Duración Aprox |
|---------------|--------------------|----------------|
| Cada commit   | @smoke             | 5 min          |
| Pull Request  | @smoke + @critical | 10 min         |
| Nightly Build | @regression        | 20 min         |
| Pre-Release   | Full suite         | 25 min         |

---

## 🛠️ Tecnologías y Justificación

### Karate DSL

**¿Por qué Karate?**

✅ **Pros:**

- Sintaxis BDD legible (Gherkin)
- No requiere código Java complejo
- Validación JSON nativa
- Reportes HTML automáticos
- Gran comunidad y documentación

❌ **Contras considerados:**

- Curva de aprendizaje inicial
- Menos flexible que código puro

**Decisión:** Pros superan contras para pruebas de API.

### JUnit 5

**¿Por qué JUnit 5?**

- Integración perfecta con Karate
- Compatible con Maven y CI/CD
- Ampliamente adoptado en la industria

### Maven

**¿Por qué Maven?**

- Gestión de dependencias estándar
- Fácil integración en pipelines
- Compatible con IDEs populares

---

## 📈 Métricas de Calidad

### Objetivos Definidos

| Métrica                | Objetivo | Actual     |
|------------------------|----------|------------|
| Cobertura de endpoints | 100%     | ✅ 100%     |
| Tasa de éxito          | > 95%    | ✅ 100%     |
| Tiempo de ejecución    | < 30 min | ✅ ~20 min  |
| Mantenibilidad         | Alta     | ✅ Alta     |
| Documentación          | Completa | ✅ Completa |

### Indicadores de Salud

```
✅ Todos los tests pasan
✅ Sin warnings críticos
✅ Cobertura 100% de endpoints
✅ Documentación actualizada
✅ Sin código duplicado
✅ Helpers reutilizables funcionando
```

---

## 🔮 Escalabilidad Futura

### Preparado para Crecer

La arquitectura actual soporta fácilmente:

1. **Más endpoints:** Agregar nuevos features siguiendo el patrón
2. **Más validaciones:** Extender helpers existentes
3. **Integración continua:** Ya compatible con CI/CD
4. **Múltiples ambientes:** Configuración centralizada
5. **Paralelización:** Karate soporta ejecución paralela

### Próximos Pasos Sugeridos

1. ✨ Agregar pruebas de performance (opcional)
2. 🔄 Implementar retry en casos de fallo de red
3. 📊 Integrar con dashboard de métricas
4. 🌍 Agregar soporte multi-ambiente
5. 🔐 Agregar pruebas de seguridad

---

## 🎓 Buenas Prácticas Aplicadas

### En el Código

✅ **Nomenclatura clara:** Nombres descriptivos en español
✅ **Comentarios útiles:** Explican el "por qué", no el "qué"
✅ **Estructura consistente:** Mismo formato en todos los features
✅ **DRY:** Helpers para código repetitivo
✅ **Single Responsibility:** Un escenario, un comportamiento

### En la Organización

✅ **Separación por funcionalidad:** Un feature por endpoint
✅ **Helpers en carpeta separada:** Fácil de encontrar
✅ **README completo:** Cualquiera puede ejecutar
✅ **Tags apropiados:** Ejecución selectiva
✅ **Versionado:** Todo en Git

---

## 🎯 Conclusión

Esta estrategia de automatización logra:

1. ✅ **Cobertura completa** de funcionalidad CRUD
2. ✅ **Validaciones exhaustivas** de esquemas JSON
3. ✅ **Código mantenible** y bien documentado
4. ✅ **Ejecución flexible** mediante tags
5. ✅ **Escalabilidad** para crecimiento futuro

**Resultado:** Suite de pruebas robusta, confiable y profesional.

---

## 📚 Referencias

- [Karate DSL Documentation](https://github.com/karatelabs/karate)
- [API ServeRest](https://serverest.dev/)
- [Test Automation Patterns](https://martinfowler.com/articles/practical-test-pyramid.html)
- [BDD Best Practices](https://cucumber.io/docs/bdd/)

---

