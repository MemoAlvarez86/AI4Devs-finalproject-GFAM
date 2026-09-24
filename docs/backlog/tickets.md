# Tickets de trabajo — JFH School

**Versión:** 1.0 (Entrega 1) · **Fecha:** 2026-09-24

> Los tickets **TK-DB-01**, **TK-BE-01** y **TK-FE-01** están detallados en el [readme §6](../../readme.md#6-tickets-de-trabajo). Este documento contiene el desglose completo del MVP (retro-documentado), la DoD por tipo y los tickets **planificados** para las Entregas 2 y 3.

## 1. Convenciones

| Elemento | Convención |
|----------|------------|
| ID | `TK-{AREA}-{NN}`. Áreas: `DB` base de datos, `BE` backend, `FE` frontend, `QA` pruebas, `OPS` operación/CI, `SEC` seguridad, `DOC` documentación, `REPO` repositorio |
| Estimación | Story points en Fibonacci (1, 2, 3, 5, 8, 13). **Nunca decimales**: la IA propone el valor como *peer* y el autor lo confirma o lo corrige |
| Etiqueta de origen (M4 §4.5) | `human`, `human+copilot`, `agent`, `agent+human-review`. Permite medir más adelante la calidad según el origen del trabajo |
| Granularidad | Un ticket equivale a un PR revisable. Si supera 8 SP, se divide |
| Estructura mínima | Descripción → pasos concretos (archivo o script) → criterios de aceptación → **non-goals** → DoD → contexto técnico |
| Flujo SDD | Todo ticket que cruce capas o toque reglas de negocio empieza con `/opsx-propose` (OpenSpec). El agente implementa contra `tasks.md` en el orden §16 de `docs/EstructuraProyecto.md` |

## 2. Definition of Done por tipo

<a id="dod-feature"></a>**Feature nueva**

- [ ] La implementación cubre todos los escenarios Given/When/Then de la historia
- [ ] Al menos una prueba por escenario (unitaria o de integración)
- [ ] La UI no usa `DbContext`. El servicio hereda de `ServicioBase` y las escrituras de negocio van por SP
- [ ] El permiso se revalida en el servicio (defensa en profundidad)
- [ ] Mensajes al usuario en español; estados de carga, vacío y error visibles
- [ ] Documentación actualizada en el mismo PR: diccionario (si toca BD), `EstructuraProyecto.md` (si toca patrones), `ROADMAP_DESARROLLO.md`
- [ ] Change de OpenSpec archivado (`/opsx-archive`) si se usó SDD
- [ ] PR con la etiqueta de origen y revisión de al menos una persona (no solo agentes)

**Base de datos**

- [ ] Cumple el checklist §16 del Estándar de BD (nomenclatura, prefijos `@i/@s/@x/@d/@dt/@b`, esquema explícito, sin `SELECT *`)
- [ ] Script idempotente en `db/alteraciones/YYYY-MM-DD_*.sql`, con cabecera Autor/Fecha/Descripción
- [ ] Toda tabla nueva lleva `EsEliminado` y los 6 campos de auditoría. Los índices únicos filtran `EsEliminado = 0`
- [ ] Aplicado en Staging y `db/verificacion/01_auditoria_despliegue.sql` devuelve `TotalPendientes = 0`
- [ ] Se redesplegaron los objetos dependientes (SQL Server resuelve nombres hasta la ejecución)

**Bug fix**

- [ ] Prueba que reproduce el bug, en un commit anterior al fix
- [ ] Fix mínimo y enfocado, sin refactors ajenos
- [ ] La prueba ahora pasa
- [ ] Análisis breve de 5 porqués en el ticket: por qué se introdujo y si CI pudo detectarlo

**Refactor**

- [ ] La cobertura del módulo no baja
- [ ] El comportamiento observable no cambia (mismos contratos, SP y rutas)
- [ ] No se mezcla con cambios de feature

**Documentación**

- [ ] Revisada por el autor (no solo por la IA)
- [ ] Los fragmentos de código existen en el repositorio y los mensajes citados coinciden con el código
- [ ] Enlaces internos sin romper; Mermaid se renderiza en GitHub

## 3. Desglose del MVP (retro-documentado)

| ID | Historia | Tipo | Título | SP | Origen |
|----|----------|------|--------|----|--------|
| TK-DB-03 | HU-01 | DB | Alteración `2026-09-09_unificar_contactos_alumno.sql` (`esc.Tutor` → `esc.AlumnoContacto` + bits de rol + migración de emergencia) | 3 | agent+human-review |
| TK-DB-04 | HU-01 | DB | `esc.spInsertarParentescoTipo` idempotente (trim, sin distinguir mayúsculas, reactiva eliminados) | 2 | agent+human-review |
| TK-BE-03 | HU-01 | BE | `AlumnoService`: alta/edición de alumno + contactos en una transacción, soft-delete de retirados | 3 | agent+human-review |
| TK-FE-03 | HU-01 | FE | `Formulario.razor`: tarjetas de contacto agregables, validación en línea, insignia Guardado/Sin guardar | 3 | agent+human-review |
| TK-BE-04 | HU-02 | BE | `AlumnoService.InscribirAlumnosAsync`: cupo, ciclo cerrado, grupo/ciclo y duplicidad | 3 | agent+human-review |
| TK-FE-04 | HU-02 | FE | `Inscripciones.razor`: destino + búsqueda + selección múltiple + resumen + confirmación | 3 | agent+human-review |
| TK-DB-05 | HU-03 | DB | Funciones `cob.fnCalcularMontoCargo` (escalones) y `cob.fnCalcularDescuentoBeneficio` (precedencia) | 3 | agent+human-review |
| **TK-DB-01** | HU-03 | DB | **`cob.spGenerarCargo` idempotente** ([readme](../../readme.md#tk-db-01--procedimiento-cobspgenerarcargo-idempotente-con-reglas-de-monto-y-beneficio)) | 5 | agent+human-review |
| TK-BE-05 | HU-03 | BE | `CobranzaService`: CRUD de conceptos y esquemas (fijo y escalones) + vista previa y generación | 5 | agent+human-review |
| TK-FE-05 | HU-03 | FE | Pestañas *Conceptos y esquemas* y *Generar cargos* con máscara de periodo `AAAA-MM` | 5 | agent+human-review |
| TK-DB-02 | HU-04 | DB | `cob.spInsertarPago` transaccional (`OPENJSON`, `Pago` + `PagoCargo` + saldo/estatus) | 3 | agent+human-review |
| **TK-BE-01** | HU-04 | BE | **`CobranzaService.InsertarPagoAsync`** ([readme](../../readme.md#tk-be-01--cobranzaserviceinsertarpagoasync-con-distribución-validada-y-transacción-en-cobspinsertarpago)) | 5 | agent+human-review |
| **TK-FE-01** | HU-04 | FE | **Pestaña *Registrar pago*** ([readme](../../readme.md#tk-fe-01--pestaña-registrar-pago-con-búsqueda-de-alumno-y-distribución-manual-o-automática)) | 5 | agent+human-review |
| TK-BE-06 | HU-05 | BE | `BecasService` + `CobranzaService.RecalcularCargosAlumnoAsync` + bitácora `BECAS` | 5 | agent+human-review |
| TK-FE-06 | HU-05 | FE | `/intranet/becas`: pestañas Beneficios (modal) y Alumnos becados | 3 | agent+human-review |
| TK-QA-00 | HU-03/04/05 | QA | `CobranzaCalculo.cs` (espejo de §8) + 14 pruebas `CobranzaCalculoTests` | 3 | agent+human-review |
| TK-BE-07 | HU-06 | BE | `ImportacionService` + validador puro + plantilla con ejemplos (ClosedXML) | 5 | agent+human-review |
| TK-BE-08 | HU-07 | BE | `DashboardService` (vista `cob.vsCobranzaResumen`) + `ReportesService` + endpoints de exportación | 5 | agent+human-review |

**Total del MVP retro-documentado:** 69 SP.

## 4. Plan de Entregas 2 y 3

**Objetivo de la Entrega 2 (sprint goal):** *"El código del MVP vive en el repositorio de entrega sin secretos, compila y pasa las pruebas en CI en cada PR."*

**Objetivo de la Entrega 3:** *"El flujo principal (generar cargo → registrar pago → estado de cuenta en cero) está verificado por pruebas de integración y un test E2E, con evidencia de despliegue."*

### Capacidad con buffer AI-aware (M4 §4.3)

```text
Capacidad bruta estimada (1 persona, ~30 h del Proyecto Final):   ~30 SP
Buffer AI-aware 30 % (verification tax, tooling churn, modelos):  −9 SP
Compromiso:                                                        21 SP
```

| ID | Entrega | Título | SP | Compromiso |
|----|---------|--------|----|------------|
| <a id="tk-repo-01"></a>TK-REPO-01 | 2 | Referenciar el código desde el repositorio de entrega (ver nota) | 2 | ✅ |
| <a id="tk-sec-01"></a>TK-SEC-01 | 2 | Externalizar secretos y endurecer el seed del administrador | 3 | ✅ |
| <a id="tk-ops-01"></a>TK-OPS-01 | 2 | Pipeline de CI en GitHub Actions: `dotnet build` + `dotnet test` en cada PR | 3 | ✅ |
| <a id="tk-qa-01"></a>TK-QA-01 | 3 | Pruebas de integración de `cob.spGenerarCargo` y `cob.spInsertarPago` contra SQL Server en contenedor | 8 | ✅ |
| <a id="tk-qa-02"></a>TK-QA-02 | 3 | Test E2E Playwright del flujo principal | 5 | ✅ |
| TK-QA-03 | 3 | Pruebas bUnit del formulario de pago | 3 | Stretch |
| TK-DOC-01 | 3 | Evidencia de despliegue (capturas + video de 2–3 min) y cierre de `prompts.md` | 2 | Stretch |

**Comprometido:** 21 SP · **Stretch:** 5 SP.

> **Estrategia de TK-REPO-01:** el fork del repositorio oficial es público y el repositorio de código es privado. El código se mantiene privado con acceso para el TA (Opción A del Proyecto Final) y se referencia desde el fork. Si se publica una copia en el fork, será después de TK-SEC-01 y de limpiar el historial de Git.

---

### TK-SEC-01 · Externalizar secretos y endurecer el seed del administrador

| Campo | Valor |
|-------|-------|
| Tipo | Seguridad |
| Estimación | 3 SP |
| Etiquetas | `security`, `ops` |
| Prioridad | Bloqueante para TK-REPO-01 (opción a) |

**Descripción.** Hoy la cadena de conexión y la configuración SMTP viven en `appsettings.{Environment}.json`, y el seed de `Program.cs` crea el usuario `admin` con una contraseña inicial fija.

**Pasos**

1. Quitar `ConnectionStrings` y `Smtp:Password` de todos los `appsettings*.json` versionados. Dejar marcadores vacíos y documentarlos.
2. Development: `dotnet user-secrets`. Staging/Producción: variables de entorno en `web.config` generado en el publish (fuera de Git) o en el panel del hosting.
3. Seed del administrador: leer la contraseña inicial de configuración (`Seed:AdminPasswordInicial`); si falta, no crear el usuario y registrar un *warning*. Eliminar el bloque temporal `Seed:AdminPasswordReset`.
4. Rotar las credenciales de SQL y SMTP que estuvieron versionadas.
5. Añadir un escaneo de secretos (`gitleaks`) al pipeline de TK-OPS-01.

**Criterios de aceptación**

```gherkin
Scenario: Repositorio sin secretos
  When se ejecuta gitleaks sobre el árbol de trabajo
  Then no se reporta ningún secreto

Scenario: Arranque sin configuración de seed
  Given no existe Seed:AdminPasswordInicial
  When arranca la aplicación con una base vacía
  Then no se crea el usuario admin y el log muestra una advertencia
```

**Non-goals:** no migra a Azure Key Vault; no cambia el proveedor de hosting.

**DoD:** DoD de refactor + `EstructuraProyecto.md` §15 actualizado + credenciales rotadas.

---

### TK-OPS-01 · Pipeline de CI en GitHub Actions

**Pasos:** crear `.github/workflows/ci.yml` con `actions/setup-dotnet@v4` (10.0.x) → `dotnet restore` → `dotnet build --no-restore -warnaserror` → `dotnet test tests/JFH_School.UnitTests --logger trx` → publicar resultados. Activar en `pull_request` y `push` a `main`. Añadir `gitleaks` (TK-SEC-01) y `markdownlint-cli2` sobre `docs/` y `readme.md` (M5 §5.4).

**AC:** un PR con una prueba rota queda en rojo; un PR que solo cambia docs ejecuta markdownlint.

**Non-goals:** no hay despliegue continuo a IIS (el despliegue sigue con Web Deploy manual en esta fase).

---

### TK-QA-01 · Pruebas de integración de la cobranza contra SQL Server

**Pasos**

1. Proyecto `tests/JFH_School.IntegrationTests` (xUnit + FluentAssertions + `Testcontainers.MsSql`).
2. *Fixture*: levanta SQL Server 2022, crea la base, ejecuta `db/00_MASTER_deploy.sql` y aplica las migraciones de Identity.
3. `WebApplicationFactory<Program>` con la cadena de conexión del contenedor.
4. Casos: idempotencia de `spGenerarCargo` (dos ejecuciones ⇒ `TotalOmitidos = N`); beca 100 % ⇒ estatus Pagado; escalón por fecha de emisión; `spInsertarPago` con distribución parcial ⇒ saldos esperados; rechazo de un cargo ajeno ⇒ `RAISERROR` y sin cambios (rollback); usuario sin `cobranza:Crear` ⇒ `Falla`.

**AC:** los 6 casos pasan en CI (el runner de Linux admite contenedores); tiempo total menor a 3 min.

**Non-goals:** no prueba la UI; no hay pruebas de rendimiento.

---

### TK-QA-02 · Test E2E del flujo principal (Playwright)

**Escenario único (Given/When/Then):**

```gherkin
Scenario: Cobrar la colegiatura de un alumno de punta a punta
  Given una base sembrada con un ciclo vigente, un grupo, un alumno inscrito y el esquema fijo de $2,500
  And un usuario de prueba con rol "Cobranza"
  When inicia sesión
  And genera el cargo de "Colegiatura" del periodo actual para el grupo
  And registra un pago en efectivo de $2,500 con distribución automática
  Then el estado de cuenta del alumno muestra el cargo "Pagado" y saldo $0.00
```

**Pasos:** `Microsoft.Playwright` + xUnit; la app arranca contra la base del *fixture* de TK-QA-01; selectores por rol y etiqueta accesible (`GetByRole`, `GetByLabel`), sin selectores CSS frágiles; *trace* guardado como artefacto de CI si falla.

**Non-goals:** no cubre todos los módulos; un solo navegador (Chromium).
