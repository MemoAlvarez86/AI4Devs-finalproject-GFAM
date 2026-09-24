# Monolito modular con Blazor Web App (Interactive Server en intranet, Static SSR en sitio público)

## Estado

Aceptado — 2026-07-23. Complementado el 2026-08 por la excepción "un solo proyecto" (`docs/EstructuraProyecto.md` §18).

## Contexto y problema

El colegio necesita un sitio comercial público y una intranet administrativa con datos sensibles (CURP y datos de menores, cobranza). Hay una sola institución y el volumen esperado es de cientos a miles de alumnos. Lo desarrolla y opera un equipo de 1–2 personas y el hosting es compartido (Windows/IIS en Plesk). Se busca desplegar sin complicaciones, exponer lo mínimo en el navegador y avanzar rápido con asistentes de IA.

## Opciones consideradas

* **A. Monolito modular ASP.NET Core 10 + Blazor Web App** (Static SSR en el sitio público, Interactive Server en la intranet)
* **B. SPA (React/Angular) + API REST ASP.NET Core** en dos despliegues
* **C. Blazor WebAssembly + API REST**
* **D. Microservicios por dominio** (alumnos, cobranza, seguridad)

## Decisión

Se elige **A**, con las capas separadas por carpetas y namespaces dentro de **un solo proyecto** (`Components`, `Application`, `Domain`, `Data`, `Infrastructure`, `Shared`), porque:

* Es un solo despliegue por Web Deploy a IIS, compatible con el hosting disponible.
* Interactive Server mantiene la lógica y el acceso a datos en el servidor: el navegador solo recibe diffs de UI por SignalR.
* No hace falta diseñar, versionar ni asegurar una API REST para la intranet: los componentes invocan los servicios de aplicación en proceso.
* Static SSR da al sitio público rendimiento y SEO sin coste de interactividad.
* Es el stack .NET del proveedor (Imbitsoft) y los asistentes de IA lo conocen bien; la documentación normativa del repositorio compensa lo que .NET 10 tiene de reciente.

## Consecuencias

* ✅ Menos código (sin DTOs de transporte HTTP ni cliente API) y menos superficie de ataque.
* ✅ Un solo pipeline de build y despliegue.
* ⚠️ Cada usuario conectado mantiene un circuito SignalR con estado en memoria. Escalar a varias instancias exigirá sesiones persistentes o un backplane (Redis), o migrar la intranet a WebAssembly.
* ⚠️ Con capas por carpetas, el compilador no impide que la UI use `DbContext`. Se mitiga con la regla de oro documentada, las reglas de Cursor siempre activas y el checklist §17.
* ⚠️ Una pérdida de conexión interrumpe la interacción (modal de reconexión `ReconnectModal`).
* 🔜 El futuro portal de padres podrá exponer endpoints propios que reutilicen los mismos servicios de aplicación.
