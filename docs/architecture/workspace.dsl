/*
 * JFH School — modelo C4 (Structurizr DSL)
 * Renderizar localmente:
 *   docker run -it --rm -p 8080:8080 -v "$(pwd)/docs/architecture:/usr/local/structurizr" structurizr/lite
 *   y abrir http://localhost:8080
 */
workspace "JFH School" "ERP web de administración escolar y cobranza del colegio Jean Frederic Herbart" {

    model {
        visitante = person "Visitante" "Familia interesada en el colegio (anónimo)"
        personal = person "Personal administrativo" "Dirección, Control Escolar, Cobranza y Consulta"

        smtp = softwareSystem "Servidor SMTP" "Correo del hosting (recuperación de contraseña)" "Externo"

        jfh = softwareSystem "JFH School" "Sitio comercial + intranet de alumnos, académico, cobranza, becas y reportes" {

            web = container "Aplicación web" "Monolito modular. Static SSR (público) + Interactive Server (intranet) + Minimal APIs" "ASP.NET Core 10 / Blazor Web App / C#" {
                publico = component "Sitio público" "Home, oferta por plantel, contacto con rate limiting" "Blazor Static SSR"
                intranet = component "Intranet" "Pantallas por módulo; solo usa servicios y DTOs" "Blazor Interactive Server"
                account = component "Account" "Login, lockout, recuperación de contraseña, 2FA" "ASP.NET Core Identity"
                endpoints = component "Minimal APIs" "Fotos de alumnos y exportaciones Excel/PDF" "ASP.NET Core Endpoints"
                rbac = component "RBAC dinámico" "PermisoPolicyProvider + PermisoAuthorizationHandler (Permiso:{modulo}:{accion})" "ASP.NET Core Authorization"
                alumnoSvc = component "AlumnoService" "Expediente, contactos e inscripciones" "C# / ServicioBase"
                cobranzaSvc = component "CobranzaService" "Conceptos, esquemas, generación de cargos, pagos, estado de cuenta, recálculo" "C# / ServicioBase"
                becasSvc = component "BecasService" "Beneficios con recálculo y bitácora" "C# / ServicioBase"
                reportesSvc = component "ReportesService / DashboardService" "KPIs y exportaciones" "C# / ClosedXML / QuestPDF"
                importacionSvc = component "ImportacionService" "Plantilla, validación y alta masiva por Excel" "C# / ClosedXML"
                seguridadSvc = component "SeguridadService" "Usuarios, roles, matriz de permisos, protección del último admin" "C# / Identity"
                calculo = component "CobranzaCalculo" "Espejo testeable de reglas §8 (monto por fecha, descuentos, saldo, estatus)" "C#"
                datos = component "ApplicationDbContext" "EF Core con DbContextFactory, filtro global de soft-delete, Identity" "EF Core 10"
            }

            db = container "Base de datos" "Esquemas seg, asp, esc, cob, web, dbo. Vistas vs*, SP sp*, funciones fn*" "SQL Server" "Database"
            archivos = container "Almacenamiento de fotos" "uploads/alumnos/{AlumnoID}/ fuera de wwwroot" "Sistema de archivos" "Database"
        }

        visitante -> publico "Navega y envía mensajes" "HTTPS"
        personal -> account "Inicia sesión" "HTTPS"
        personal -> intranet "Opera los módulos" "HTTPS + WebSocket (SignalR)"
        personal -> endpoints "Descarga reportes y fotos" "HTTPS"

        intranet -> rbac "Autoriza página y acciones"
        endpoints -> rbac "RequireAuthorization(policy)"
        intranet -> alumnoSvc "Invoca en proceso"
        intranet -> cobranzaSvc "Invoca en proceso"
        intranet -> becasSvc "Invoca en proceso"
        intranet -> reportesSvc "Invoca en proceso"
        intranet -> importacionSvc "Invoca en proceso"
        intranet -> seguridadSvc "Invoca en proceso"
        endpoints -> reportesSvc "Exporta"
        endpoints -> alumnoSvc "Lee/guarda foto (AlumnoFotoService)"
        becasSvc -> cobranzaSvc "RecalcularCargosAlumnoAsync"
        cobranzaSvc -> calculo "Reglas de negocio (espejo)"
        rbac -> datos "Consulta seg.Permiso (contexto de vida corta)"
        alumnoSvc -> datos "LINQ / EXEC esc.sp*"
        cobranzaSvc -> datos "LINQ / EXEC cob.spGenerarCargo, cob.spInsertarPago"
        becasSvc -> datos "EF + dbo.Bitacora"
        reportesSvc -> datos "Vista cob.vsCobranzaResumen"
        importacionSvc -> datos "Alta transaccional"
        seguridadSvc -> datos "Identity + seg.Permiso"
        publico -> datos "Guarda web.MensajeContacto (ContactoService)"
        datos -> db "SQL" "TDS"
        alumnoSvc -> archivos "Lee/escribe JPG/PNG"
        account -> smtp "Envía correo de recuperación" "SMTP/TLS (MailKit)"

        produccion = deploymentEnvironment "Producción" {
            deploymentNode "Hosting Imbitbox (Plesk)" "Windows Server" {
                deploymentNode "IIS" "jfhschool.com · ASPNETCORE_ENVIRONMENT=Production" {
                    containerInstance web
                    containerInstance archivos
                }
                deploymentNode "SQL Server" "BD de producción" {
                    containerInstance db
                }
            }
        }
    }

    views {
        systemContext jfh "Contexto" {
            include *
            autolayout lr
        }
        container jfh "Contenedores" {
            include *
            autolayout lr
        }
        component web "Componentes" {
            include *
            autolayout lr
        }
        deployment jfh "Producción" "Despliegue" {
            include *
            autolayout lr
        }
        styles {
            element "Person" {
                shape person
                background #242F9B
                color #ffffff
            }
            element "Software System" {
                background #242F9B
                color #ffffff
            }
            element "Externo" {
                background #999999
            }
            element "Container" {
                background #3D4FBF
                color #ffffff
            }
            element "Component" {
                background #C8CDEF
                color #1A2277
            }
            element "Database" {
                shape cylinder
            }
        }
    }
}
