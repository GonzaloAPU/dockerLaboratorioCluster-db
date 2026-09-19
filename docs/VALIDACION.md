# Validación de la copia publicada

Comprobaciones realizadas el 19 de septiembre de 2026:

| Comprobación | Resultado |
| --- | --- |
| `docker compose --env-file .env.example config --quiet` | Correcto |
| `promtool check config` con Prometheus v3.5.0 | Correcto |
| `haproxy -c` con HAProxy 3.2 Alpine y resolución de nombres de prueba | Correcto |
| Construcción de `db-node1` | Correcta, usando caché local de las capas |
| Ejecución de `scripts/01-users.sql` en PostgreSQL 17 temporal | Correcta |
| Tabla creada como `cluster_admin`, INSERT y SELECT como `app_user` | Correctos |
| Atributos de `app_user` y `monitor_user` | Sin superusuario, CREATEDB ni CREATEROLE |
| Membresía de `monitor_user` en `pg_monitor` | Verdadera |
| Comparación de archivos con contraseñas del laboratorio original | Sin coincidencias |

El PostgreSQL de prueba estaba aislado de la red y se eliminó al finalizar. Estas pruebas no levantaron el clúster completo ni midieron failover. La construcción local usó caché y no verifica una instalación nueva de todas las dependencias. El resultado remoto del workflow debe consultarse en GitHub Actions.
