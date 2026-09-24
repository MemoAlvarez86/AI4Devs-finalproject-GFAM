# Spec-Driven Development con OpenSpec para cambios medianos en un proyecto brownfield

## Estado

Aceptado — 2026-09-09.

## Contexto y problema

Con los 14 módulos ya construidos con asistentes de IA, los cambios nuevos cruzan varias capas (SQL + dominio + servicio + Blazor + permisos + docs). Con *vibe coding* el riesgo es obtener PRs grandes, decisiones técnicas implícitas y documentación que se queda atrás (la regla `documentacion-obligatoria.mdc` ya existía para contener lo último). Hacía falta que el agente acordara el **qué** y el **cómo** antes de escribir código, sin tener que especificar todo el sistema retroactivamente.

## Opciones consideradas

* **A. OpenSpec (`@fission-ai/openspec`) con specs delta por change y `docs/` como constitución**
* **B. Seguir con prompts directos + reglas de Cursor**
* **C. Especificar el sistema completo (ingeniería inversa de los 14 módulos) antes de continuar**

## Decisión

Se elige **A**:

* `docs/` sigue siendo la **constitución** (arquitectura, estándar de BD, diccionario, estructura). OpenSpec guarda solo el **delta** de cada cambio.
* Ciclo: `/opsx-explore` (opcional) → `/opsx-propose` (proposal con non-goals, specs delta en GWT, design, tasks) → revisión humana → `/opsx-apply` → `/opsx-archive`.
* `openspec/config.yaml` inyecta el contexto y las reglas: proposal de menos de 600 palabras con *non-goals*, tasks en el orden §16 de `EstructuraProyecto.md`, tarea final de documentación.
* Criterio de uso (regla de Cursor `sdd-openspec.mdc`): cambios que cruzan capas o tocan reglas de negocio. Un typo, CSS aislado o un bug de una línea se quedan en *vibe coding*.

## Consecuencias

* ✅ El primer change (`2026-09-09-unificar-contactos-alumno`) tocó BD, SP, entidades, DTOs, servicio, importación, pruebas, UI y 4 documentos con 16 tareas verificables, y generó las specs vigentes `alumnos-contactos` y `catalogo-parentesco`.
* ✅ El segundo change (`2026-09-11-sitio-publico-dos-planteles`) generó la spec `sitio-publico-comercial`.
* ✅ Los *non-goals* acotan el alcance del agente y las specs en GWT se traducen a pruebas.
* ⚠️ Añade una ceremonia por cambio; no compensa en cambios triviales (de ahí el criterio de uso).
* ⚠️ Las specs cubren solo los slices tocados desde septiembre de 2026, no todo el sistema. Es una decisión consciente.
