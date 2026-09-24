# Esquema de negocio *scripts-first* con procedimientos almacenados para escrituras críticas

## Estado

Aceptado — 2026-07-23.

## Contexto y problema

El proveedor (Imbitsoft) tiene un **Estándar de Programación y Nomenclatura para Base de Datos (v1.2)** obligatorio: nombres en español, esquemas por dominio, restricciones con nombre explícito, soft-delete con `EsEliminado`, 6 campos de auditoría y acceso por vistas `vs*` y procedimientos `sp*`. Las reglas de cobranza (monto por fecha, beneficios, distribución de pagos y saldos) deben ser transaccionales y consistentes aunque se invoquen desde distintos puntos. Las migraciones autogeneradas de EF Core no producen objetos que cumplan ese estándar.

## Opciones consideradas

* **A. Scripts SQL versionados en `db/` + SP/funciones para escrituras y reglas; EF Core para mapeo y lecturas**
* **B. EF Core *code-first* con migraciones y toda la lógica en C#**
* **C. Dapper + SQL embebido en C#**

## Decisión

Se elige **A**:

* Los scripts en `db/` son la **fuente de verdad** del esquema de negocio y se revisan como código. Los cambios posteriores van a `db/alteraciones/YYYY-MM-DD_*.sql` (idempotentes) y se verifican con `db/verificacion/01_auditoria_despliegue.sql`.
* Las escrituras con reglas de negocio (`cob.spGenerarCargo`, `cob.spInsertarPago`, `esc.spInsertarAlumno`…) se ejecutan en el motor con `SET XACT_ABORT ON` y transacciones. Los `RAISERROR` se traducen a mensajes de negocio en `ServicioBase`.
* Las reglas de monto y descuento viven en funciones (`cob.fnCalcularMontoCargo`, `cob.fnCalcularDescuentoBeneficio`) que reutilizan la generación y el recálculo.
* EF Core queda para mapeo, lecturas LINQ con `AsNoTracking` y el modelo de Identity. Las migraciones EF se limitan a los esquemas `seg`/`asp` de Identity (excepción documentada).

## Consecuencias

* ✅ Cumplimiento del estándar del proveedor e integridad garantizada por el motor (índices únicos filtrados como garantía de idempotencia).
* ✅ Los scripts se leen y revisan fácil, también por agentes de IA.
* ⚠️ Las reglas en SQL son más difíciles de probar con tests unitarios. Se creó `Application/Cobranza/CobranzaCalculo.cs` como espejo testeable (14 pruebas), con riesgo de que se desincronice del SQL. Los tests de integración contra SQL Server real (TK-QA-01) cierran ese hueco.
* ⚠️ Hay dos mecanismos de esquema (scripts + migraciones de Identity), con límites documentados en `docs/EstructuraProyecto.md` §10.5.
* ⚠️ SQL Server crea un SP aunque falten las funciones que invoca: el error aparece hasta ejecutarlo. **Lección real:** faltaba `dbo.fnAhora()` y fallaba toda alta de alumno con "Error interno". Desde entonces, cada alteración verifica también los objetos dependientes.
