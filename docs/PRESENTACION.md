# PostgreSQL con recuperación automática y monitoreo

Guion para una presentación técnica de 6 minutos orientada a Infra / Platform.
Guion basado en el laboratorio original y sus resultados históricos.

## Apertura · 0:00–0:35

«Soy Gonzalo. Para aprender infraestructura armé un laboratorio de PostgreSQL con Docker Compose. Quería entender cómo recuperar el servicio cuando falla el nodo principal y cómo observar lo que ocurre. El proyecto nació como un TP y lo usé para practicar replicación, pruebas de carga y permisos de usuarios.»

Mostrar el repositorio y el archivo Compose. Explicar brevemente qué partes configuraste personalmente y qué ayuda recibiste de documentación o IA, según tu experiencia real.

## Arquitectura · 0:35–1:20

Mostrar un esquema de arquitectura o las configuraciones, sin leer el YAML completo.

| Componente | Función en este proyecto |
| --- | --- |
| Tres PostgreSQL con Patroni | Mantener un primario y réplicas, administrar roles y recuperación |
| Tres etcd | Almacenar el estado de coordinación utilizado por Patroni |
| HAProxy | Consultar la API de Patroni y dirigir conexiones al primario en 5000 y a réplicas en 5001 |
| Exporters y Prometheus | Obtener métricas de PostgreSQL y recolectarlas |
| Grafana | Visualizar las métricas |
| cAdvisor | Obtener métricas de contenedores |
| Cliente PostgreSQL | Ejecutar consultas y pruebas |

«Compose describe 14 servicios. Cada nodo de base de datos tiene su volumen. En HAProxy, el chequeo del puerto 8008 determina el rol del nodo y la conexión de datos usa el 5432.»

Al describir el alcance: «Este laboratorio corre en un solo host. La demo aborda la caída de un nodo del clúster. Para tolerar la caída del host necesitaría distribuir la infraestructura y revisar también el punto de entrada.»

## Demo · 1:20–3:30

Preparar el entorno antes del Meet. Usar exclusivamente el laboratorio y confirmar que no atienda otro trabajo. No construir imágenes ni descargar dependencias durante la presentación.

### Estado inicial

Desde la carpeta del proyecto:

```powershell
docker compose ps
docker compose exec db-node1 patronictl -c /etc/patroni/patroni.yml list
```

Mostrar un líder y dos réplicas. El líder puede ser cualquiera de los tres. Evitar memorizar un nombre.

Comprobar que `POSTGRES_SUPERUSER` es `postgres` antes de usar los siguientes comandos. El cliente actual recibe `PGPASSWORD` desde Compose. Si el usuario es otro, adaptar `-U`. No mostrar `.env` en pantalla.

```powershell
docker compose exec client psql -h haproxy -p 5000 -U postgres -d postgres -c "SELECT inet_server_addr(), pg_is_in_recovery();"
docker compose exec client psql -h haproxy -p 5001 -U postgres -d postgres -c "SELECT inet_server_addr(), pg_is_in_recovery();"
```

Resultado esperado: `false` por 5000, `true` por 5001. Es un chequeo con el usuario administrativo del laboratorio. La demostración de permisos utiliza `app_user` por separado.

### Caída y recuperación

Elegir el líder observado. El siguiente ejemplo SOLO corresponde si `db-node3` es el líder:

```powershell
docker compose stop db-node3
docker compose exec db-node1 patronictl -c /etc/patroni/patroni.yml list
docker compose exec client psql -h haproxy -p 5000 -U postgres -d postgres -c "SELECT inet_server_addr(), pg_is_in_recovery();"
docker compose start db-node3
```

Si el líder era otro, adaptar tanto el nodo detenido como el nodo desde el cual se consulta Patroni. Esperar y repetir la consulta de estado durante la elección. Medir el tiempo observado, sin prometer un tiempo de recuperación todavía no registrado.

«Después de la elección, pruebo una nueva conexión al mismo endpoint y verifico que llega al nuevo primario.»

Esta consulta confirma enrutamiento y rol. Para demostrar recuperación de escrituras, ensayar además una inserción antes y después en una tabla de demo con `app_user`. No afirmar continuidad de una conexión existente ni ausencia de pérdida de datos a partir de esta consulta.

Al terminar, comprobar que el nodo recuperado vuelve como réplica. Si la recuperación tarda, mostrar una grabación del ensayo con fecha y resultados, identificándola como tal.

## Evidencia de carga · 3:30–4:20

Hay 15 archivos en `resultados`, tres por nivel de concurrencia. Los rangos siguientes salen directamente de esos archivos.

| Clientes | TPS observados en tres corridas | Latencia media de cada corrida |
| ---: | ---: | ---: |
| 10 | 942–1.138 | 8,8–10,6 ms |
| 25 | 1.013–1.964 | 12,7–24,7 ms |
| 50 | 1.934–2.171 | 23,0–25,8 ms |
| 100 | 1.394–1.983 | 50,3–70,5 ms |
| 200 | 1.442–1.797 | 111,1–134,7 ms |

Las 15 salidas reportan cero transacciones fallidas. La salida inspeccionada de 50 clientes, prueba 3, identifica pgbench 17.11, carga integrada TPC-B (sort of), escala 20, cuatro threads y duración configurada de 60 segundos. Completar hardware, versión del entorno y comando exacto de cada serie antes de publicar una comparación reproducible.

«En estas corridas, aumentar a 200 clientes no mejoró el rendimiento frente a 50 y sí aumentó la latencia. Aprendí a medir antes de aumentar conexiones. Estos números corresponden a mi laboratorio y a esta carga.»

Los archivos no documentan por sí solos el endpoint empleado, todas las condiciones de ejecución ni el historial de cambios de `max_connections`. No atribuir el comportamiento a una causa única sin medirla.

## Monitoreo y seguridad · 4:20–5:15

Mostrar un dashboard real con datos actuales, un target de Prometheus y una prueba de permisos. El historial del TP contiene pruebas en las que `app_user` pudo insertar y consultar, pero PostgreSQL rechazó crear roles y bases. Repetirlas en el ensayo antes de presentarlas como estado actual.

«Separé usuarios de aplicación y monitorización de las tareas administrativas y comprobé los permisos con operaciones permitidas y rechazadas.»

Prometheus tiene configurada recolección de métricas, pero no reglas de alertas ni un receptor. El repositorio de presentación agrega un workflow de CI para validar configuraciones y construir la imagen. Mostrar su resultado en GitHub Actions solamente después de comprobar la ejecución. El despliegue automatizado y las alertas permanecen como próximos pasos.

## Cierre · 5:15–6:00

«Lo que más aprendí fue a comprobar cada capa: estado del clúster, enrutamiento, permisos y comportamiento bajo carga. Mi próximo paso es automatizar las validaciones y una alerta de caída con su recuperación. Me interesa Infra / Platform porque disfruto construir entornos reproducibles y entender por qué fallan.»

## Preguntas para ensayar

- ¿Por qué Patroni y etcd? Explicar la administración del clúster y su coordinación. Diferenciar el estado de coordinación de los datos SQL.
- ¿Qué ocurre si cae la computadora? Todos estos servicios dependen del mismo host. Separar tolerancia a un proceso o contenedor de tolerancia al host.
- ¿Qué ocurre con una conexión existente durante el failover? Explicar que la aplicación debe gestionar desconexiones y reintentos. Probar una nueva conexión no demuestra continuidad de una transacción.
- ¿La replicación es un backup? Explicar cómo se recuperarían datos borrados o dañados y mostrar una restauración probada si existe.
- ¿Qué significan los 200 clientes? Son clientes de pgbench bajo una carga concreta. No equivalen automáticamente a usuarios reales de una aplicación.
- ¿Cómo sabés que recuperó? Mostrar rol del nuevo primario, consulta por el endpoint, escritura probada y reintegración del nodo anterior.
- ¿Qué falta para producción? Distribución entre hosts, disponibilidad del proxy, restauraciones probadas, seguridad de comunicaciones y secretos, alertas y procedimientos de operación.
- ¿Qué hiciste con IA? Responder con ejemplos reales de ayuda recibida, errores detectados y verificaciones propias.

## Preparación antes de compartir el proyecto

1. La copia pública parametriza la contraseña de Grafana. Cambiar credenciales del laboratorio si se compartieron anteriormente.
2. El repositorio incluye `.env.example` e instrucciones para ejecutar explícitamente el SQL de inicialización una sola vez.
3. Los resultados históricos están incluidos con su tabla y limitaciones metodológicas.
4. Completar los recursos del equipo y el comando de cada benchmark. Registrar las versiones efectivas de dependencias, incluido Patroni.
5. Revisar la ejecución del workflow en GitHub Actions. Llamarlo CI hasta que exista y se haya probado un despliegue automatizado.
6. Agregar y probar una alerta con activación y recuperación. Distinguir un exporter inaccesible de una base de datos caída.
7. Ensayar la demo completa, registrar el tiempo de recuperación y preparar un video breve como respaldo.

## Estado de esta preparación

Se inspeccionaron Compose, Dockerfile, Patroni, HAProxy, Prometheus y los resultados de carga. Compose y las configuraciones de HAProxy y Prometheus pasaron sus validadores al preparar la copia pública. El failover, los dashboards y el estado actual del clúster requieren una comprobación durante el ensayo.
