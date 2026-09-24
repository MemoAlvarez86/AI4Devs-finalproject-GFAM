# Backlog del MVP — Historias de usuario

**Proyecto:** JFH School · **Autor:** Guillermo Alvarez · **Versión:** 1.0 (Entrega 1) · **Fecha:** 2026-09-24

Este backlog sigue la pirámide **PRD → Épica → Historia → Tarea → Criterios de aceptación** del módulo 4 y está escrito para que lo lean tanto personas como agentes de IA.

## Cómo se escribieron estas historias

| Práctica (M4) | Cómo se aplicó |
|---------------|----------------|
| **INVEST como filtro de entrada** | Cada historia incluye su evaluación. Si falla 2 o más criterios, vuelve a refinamiento |
| **AC en Given/When/Then** | Se traducen directo a pruebas (xUnit, integración, Playwright) |
| **Verificación contra el sistema real** (antídoto de la *false completeness*) | Claude Code redactó los escenarios a partir de las reglas §8 del documento técnico y **verificó cada uno contra el código** (servicios, SP, índices). Los mensajes entre comillas son los que devuelve el sistema hoy. No se incluyó ningún escenario que no pudiera verificarse. El autor revisa y aprueba el backlog |
| **Clasificación de complejidad antes de estimar** | Buckets Baja / Media / Alta, para evitar la homogeneización de historias |
| **Estimación en Fibonacci** | La IA propone el valor como *peer* de planning poker y el autor lo confirma o lo corrige. No se usan decimales |
| **Contexto técnico al final** | El agente entiende primero el producto y después la técnica |
| **Non-goals explícitos** | Acotan el tamaño del PR generado por el agente |
| **DoD por tipo de trabajo** | Ver [tickets.md §2](tickets.md#2-definition-of-done-por-tipo) |

## Épicas

| Épica | Hipótesis de producto | Historias |
|-------|-----------------------|-----------|
| **E1 · Expediente y matrícula** | Si el expediente y la inscripción están digitalizados, la cobranza puede calcularse sin capturas duplicadas | HU-01, HU-02, HU-06 |
| **E2 · Cobranza** | Si los montos, cargos y pagos siguen reglas automáticas, se eliminan errores de cálculo y el estado de cuenta es inmediato | HU-03, HU-04 |
| **E3 · Becas y descuentos** | Si los beneficios recalculan los cargos solos, se aplican siempre igual y quedan auditados | HU-05 |
| **E4 · Visibilidad** | Si la dirección ve KPIs y deudores al momento, puede actuar sobre la cartera vencida | HU-07 |

## Resumen priorizado (MoSCoW)

| ID | Historia | Prioridad | Complejidad | SP | Estado |
|----|----------|-----------|-------------|----|--------|
| HU-01 | Registrar expediente de alumno con contactos | **Must** | Media | 5 | ✅ |
| HU-02 | Inscribir alumnos a un grupo del ciclo vigente | **Must** | Media | 5 | ✅ |
| HU-03 | Generar cargos a partir de un esquema de cobro | **Must** | Alta | 8 | ✅ |
| HU-04 | Registrar un pago y consultar el estado de cuenta | **Must** | Alta | 8 | ✅ |
| HU-05 | Asignar beca o descuento con recálculo automático | **Must** | Media | 5 | ✅ |
| HU-06 | Importar alumnos desde Excel con vista previa | Should | Media | 5 | ✅ |
| HU-07 | Dashboard de cobranza y reportes exportables | Should | Media | 5 | ✅ |
| — | Portal de padres/tutores | Won't (fase futura) | — | L | — |
| — | Pago electrónico bancario (`IPasarelaPago`) | Won't (fase futura) | — | XL | — |

> HU-03, HU-04 y HU-05 se documentan completas en el [readme §5](../../readme.md#5-historias-de-usuario) para no duplicar contenido. Aquí están las demás.

---

## HU-01 · Registrar expediente de alumno con contactos

| Campo | Valor |
|-------|-------|
| Épica | E1 · Expediente y matrícula |
| Prioridad | **Must** |
| Complejidad / SP | Media / **5 SP** |
| Rol | Control Escolar |

**Como** responsable de control escolar,
**quiero** dar de alta el expediente de un alumno con sus datos personales, domicilio y uno o varios contactos con roles (tutor, emergencia, responsable de pago),
**para** tener en un solo lugar la información para inscribirlo y saber a quién cobrarle o llamar.

**INVEST:** ✅ I · ✅ N · ✅ V · ✅ E · ✅ S · ✅ T

### Criterios de aceptación

```gherkin
Feature: Expediente del alumno

  Background:
    Given el usuario tiene el permiso "alumnos:Crear"

  Scenario: Alta con dos contactos
    When captura CURP válida, nombres, apellido paterno, fecha de nacimiento, sexo y fecha de ingreso
    And agrega a la madre como tutor y responsable de pago y al abuelo como contacto de emergencia
    And guarda
    Then el alumno y sus 2 contactos se guardan en una sola transacción
    And el formulario se recarga con los identificadores reales y las tarjetas muestran "Guardado"

  Scenario: CURP con formato inválido
    When captura la CURP "ABC123"
    Then ve "Formato de CURP inválido." junto al campo y no se guarda nada

  Scenario: CURP duplicada
    Given ya existe un alumno con la CURP "LOPA180305MJCPNN09"
    When intenta registrar otro alumno con esa CURP
    Then ve "Ya existe un alumno con ese CURP."

  Scenario: Contacto sin rol
    When agrega un contacto sin marcar tutor, emergencia ni responsable de pago
    Then ve "Marca si el contacto es tutor, de emergencia o responsable de pago."

  Scenario: Dos responsables de pago
    When marca a dos contactos como responsables de pago
    Then ve "Solo un contacto puede marcarse como responsable de pago."

  Scenario: Alta rápida de parentesco sin duplicados
    When escribe el parentesco "abuela" y ya existe "Abuela"
    Then se reutiliza el valor existente (comparación sin mayúsculas) y no se duplica el catálogo

  Scenario: Retirar un contacto al editar
    Given el alumno tiene 2 contactos
    When elimina uno y guarda
    Then el contacto retirado recibe borrado lógico con auditoría

  Scenario: Baja de alumno inscrito
    Given el alumno tiene una inscripción activa
    When intenta eliminarlo
    Then ve "El alumno tiene inscripciones activas y no puede eliminarse."
```

**Non-goals:** no comparte un mismo contacto entre hermanos; no hay CRUD general de catálogos; no exige tener al menos un tutor.

**Contexto técnico (para el agente):** `Components/Intranet/Alumnos/Formulario.razor` y `Detalle.razor` → `AlumnoService.InsertarAsync` / `ActualizarAsync` / `AgregarParentescoAsync` → `esc.spInsertarAlumno`, `esc.spActualizarAlumno`, `esc.spInsertarParentescoTipo`. Validación CURP en `Shared/CurpHelper.cs`. Spec vigente: `openspec/specs/alumnos-contactos/spec.md` (nació del change SDD `2026-09-09-unificar-contactos-alumno`).

---

## HU-02 · Inscribir alumnos a un grupo del ciclo vigente

| Campo | Valor |
|-------|-------|
| Épica | E1 · Expediente y matrícula |
| Prioridad | **Must** |
| Complejidad / SP | Media / **5 SP** |
| Rol | Control Escolar |

**Como** responsable de control escolar,
**quiero** inscribir a uno o varios alumnos a un grupo del ciclo escolar en una sola operación,
**para** preparar el inicio de ciclo rápido y dejar lista la base sobre la que se generan los cargos.

**INVEST:** ✅ I · ✅ N · ✅ V · ✅ E · ✅ S · ✅ T

### Criterios de aceptación

```gherkin
Feature: Inscripción

  Background:
    Given el usuario tiene el permiso "alumnos:Crear"
    And el ciclo "2026-2027" está "Vigente" y el grupo "1°A" tiene cupo 25 con 22 inscritos

  Scenario: Ciclo vigente por defecto
    When abre /intranet/alumnos/inscripciones
    Then el combo de ciclo muestra "2026-2027" preseleccionado

  Scenario: Inscripción masiva con resumen
    When selecciona "1°A", busca y marca 3 alumnos sin inscripción activa
    Then ve un resumen persistente con el grupo destino y los 3 alumnos
    When confirma
    Then se crean 3 inscripciones con estatus "Activa" y fecha de hoy

  Scenario: Cupo insuficiente
    When intenta inscribir 4 alumnos
    Then ve "El grupo solo tiene 3 lugar(es) disponible(s)." y no se inscribe a nadie

  Scenario: Alumno ya inscrito en el ciclo
    Given uno de los alumnos seleccionados ya tiene inscripción activa en "2026-2027"
    When confirma
    Then ve "1 alumno(s) ya tienen inscripción activa en el ciclo."

  Scenario: Ciclo cerrado
    When intenta inscribir en un ciclo "Cerrado"
    Then ve "No se permiten inscripciones en un ciclo cerrado."

  Scenario: Grupo de otro ciclo
    When el grupo no pertenece al ciclo seleccionado
    Then ve "El grupo no pertenece al ciclo seleccionado."
```

**Non-goals:** no hay cambio de grupo ni baja de inscripción desde esta pantalla; no hay promoción automática de ciclo.

**Contexto técnico (para el agente):** `Components/Intranet/Alumnos/Inscripciones.razor` (acepta `?alumnoId=` para el caso individual) → `AlumnoService.InscribirAlumnosAsync`. Garantía en el motor: `UI_Inscripcion_AlumnoID_CicloEscolarID` filtrado a `EstatusInscripcionTipoID = 1 AND EsEliminado = 0`. Helper `CicloEscolarHelper.IdVigente`.

---

## HU-06 · Importar alumnos desde Excel con vista previa *(Should)*

| Campo | Valor |
|-------|-------|
| Épica | E1 · Expediente y matrícula |
| Prioridad | Should |
| Complejidad / SP | Media / **5 SP** |
| Rol | Control Escolar |

**Como** responsable de control escolar,
**quiero** cargar un Excel con muchos alumnos, ver qué filas tienen errores antes de guardar y confirmar solo las válidas,
**para** migrar la matrícula existente al inicio del ciclo sin capturar a mano cientos de expedientes.

**INVEST:** ✅ I · ✅ N · ✅ V · ✅ E · ✅ S · ✅ T

### Criterios de aceptación

```gherkin
Feature: Importación de alumnos

  Scenario: Plantilla con ejemplos válidos
    When descarga la plantilla
    Then obtiene un .xlsx con la hoja "Alumnos", encabezados fijos y 2 filas de ejemplo
    And las filas de ejemplo pasan la validación del sistema

  Scenario: Vista previa con errores por fila
    Given un archivo con 10 filas, 2 con CURP inválida y 1 con grupo inexistente
    When lo valida
    Then ve 7 filas "OK" y 3 con su motivo, por ejemplo "Formato de CURP inválido."
    And "No se encontró el grupo '1°Z' en Primaria / 1° / ciclo 2026-2027."

  Scenario: Confirmación transaccional
    When confirma
    Then se insertan las 7 filas válidas con alumno, contacto (tres roles) e inscripción
    And ve el resumen "insertados / rechazados"

  Scenario: Duplicados en el archivo o en la base
    Then una CURP repetida en el archivo o existente en la base marca "Ya existe un alumno con esa CURP."

  Scenario: Archivo no válido
    When sube un .csv o un archivo sin filas
    Then ve "Solo se admiten archivos .xlsx." o "El archivo no contiene filas de datos."

  Scenario: Límites
    Then se rechazan archivos de más de 5 MB o más de 2 000 filas
```

**Non-goals:** no actualiza alumnos existentes (solo altas); acepta un contacto por fila.

**Contexto técnico (para el agente):** `Components/Intranet/Alumnos/Importar.razor` → `ImportacionService.GenerarPlantillaAsync` / `ValidarAsync` / `ConfirmarAsync` → reglas puras en `Application/Importacion/ImportacionAlumnoValidador.cs` (probadas en `ImportacionAlumnoValidadorTests`). Límites en `AppSettings:ImportacionExcelMaxFilas` y `ImportacionExcelMaxMB`.

---

## HU-07 · Dashboard de cobranza y reportes exportables *(Should)*

| Campo | Valor |
|-------|-------|
| Épica | E4 · Visibilidad |
| Prioridad | Should |
| Complejidad / SP | Media / **5 SP** |
| Rol | Dirección / Cobranza |

**Como** directora,
**quiero** ver al entrar los indicadores de cobranza del ciclo vigente y descargar la lista de deudores y los estados de cuenta,
**para** decidir a quién dar seguimiento y responder a las familias con un documento formal.

**INVEST:** ✅ I · ✅ N · ✅ V · ✅ E · ✅ S · ✅ T

### Criterios de aceptación

```gherkin
Feature: Dashboard y reportes

  Scenario: KPIs del ciclo vigente
    Given hay cargos emitidos en el ciclo vigente
    When entra a /intranet
    Then ve total facturado, cobrado, pendiente y vencido de ese ciclo (vista cob.vsCobranzaResumen)
    And ve alumnos activos por sección y los últimos mensajes sin atender

  Scenario: Reporte de deudores en Excel
    Given el usuario tiene "reportes:Ver"
    When exporta deudores filtrando por sección "Primaria"
    Then descarga deudores_yyyyMMdd_HHmm.xlsx solo con cargos vencidos con saldo de esa sección

  Scenario: Estado de cuenta en PDF
    When exporta el estado de cuenta de un alumno con format=pdf
    Then el PDF muestra logo, «Jean Frederic Herbart», título «Estado de cuenta», cargos, pagos y saldo

  Scenario: Sin permiso
    Given el usuario no tiene "reportes:Ver"
    Then no ve el menú Reportes y los endpoints /intranet/reportes/export/* responden 403
```

**Non-goals:** no hay reportes programados por correo ni gráficas históricas multiciclo.

**Contexto técnico (para el agente):** `Components/Intranet/Dashboard.razor` → `DashboardService` (entidad keyless `VsCobranzaResumen`). `Components/Intranet/Reportes/Index.razor` → `ReportesService` (ClosedXML, QuestPDF) → `Infrastructure/Endpoints/ReportesEndpoints.cs`.

---

## Anexo — Prompt *poke-holes* para refinar historias nuevas

```text
Dado este user story y estos criterios de aceptación (happy path), lista:
1) edge cases, 2) supuestos implícitos, 3) escenarios faltantes, 4) dependencias o riesgos no mencionados.
Contexto: docs/Documento_Tecnico_ERP_Colegio.md §8 (reglas de cobranza) y
Application/Services/CobranzaService.cs. Marca como "(asumido)" todo lo que no puedas
verificar en el código. No escribas código.

<historia HU-04 + 2 escenarios happy path>
```

Uso previsto (flujo continuo del M4): el autor escribe el *happy path* de cada historia nueva (por ejemplo, las del portal de padres), ejecuta este prompt, se queda con los 3–5 casos reales de los 10–15 que propone la IA y los verifica contra el código antes de pasarlos a `/opsx-propose`.
