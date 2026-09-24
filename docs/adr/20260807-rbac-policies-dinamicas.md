# RBAC configurable con policies dinámicas `Permiso:{modulo}:{accion}`

## Estado

Aceptado — 2026-08-07.

## Contexto y problema

Los perfiles del colegio (Dirección, Control Escolar, Cobranza, Consulta) no son fijos: la dirección quiere ajustar qué puede ver, crear, editar o eliminar cada perfil en cada módulo sin pedir un cambio de código. Los roles fijos de ASP.NET Core (`[Authorize(Roles = "...")]`) obligarían a recompilar con cada ajuste.

## Opciones consideradas

* **A. Matriz `seg.Permiso` (rol × módulo × Ver/Crear/Editar/Eliminar) + `IAuthorizationPolicyProvider` que genera policies bajo demanda**
* **B. Roles fijos en atributos**
* **C. Claims por permiso emitidos en el login**

## Decisión

Se elige **A**:

* `PermisoPolicyProvider` resuelve cualquier policy con el formato `Permiso:{modulo}:{accion}`, y `PermisoAuthorizationHandler` la evalúa contra `seg.Permiso`. Un rol con `EsAdmin = 1` tiene acceso total.
* Páginas: `[AuthorizePermiso(ModuloClaves.X, PermisoAcciones.Ver)]`. Endpoints: `RequireAuthorization(PermisoPolicyProvider.Nombre(...))`.
* **Defensa en profundidad:** la UI oculta acciones según `PermisosEfectivosDto` y cada servicio revalida con `ExigirPermisoAsync` antes de escribir.
* La sección de usuarios y permisos usa una policy aparte, `EsAdmin`, con protección del último administrador.
* Los permisos se consultan con un contexto de vida corta (`IDbContextFactory`), no con `UserManager`, porque layout, handler y página los evalúan en paralelo.

## Consecuencias

* ✅ Cambiar un permiso tiene efecto inmediato, sin redeploy ni nuevo login (a diferencia de la opción C).
* ✅ Se agregan módulos con una clave en `ModuloClaves` y una fila en `seg.Modulo`.
* ⚠️ Cada evaluación consulta la base; con el volumen actual es aceptable, y hay espacio para una caché por circuito si hiciera falta.
* ⚠️ **Lección real:** la primera versión usaba `UserManager`/`DbContext` *scoped* y lanzaba `InvalidOperationException` ("a second operation was started on this context") al abrir Alumnos. Se corrigió con contextos de vida corta y quedó documentado en `EstructuraProyecto.md` §13.4.1.
