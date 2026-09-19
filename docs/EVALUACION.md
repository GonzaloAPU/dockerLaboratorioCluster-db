# Recorrido breve para evaluar el proyecto

1. **Configuración:** [Compose](../docker-compose.yml), [Patroni](../config/patroni/patroni.yml) y [HAProxy](../config/haproxy/haproxy.cfg).
2. **Evidencia:** [tabla de 15 corridas](RESULTADOS.md), con enlaces a las salidas originales de pgbench.
3. **Reproducción:** seguir el inicio rápido del [README](../README.md), configurar `.env` e inicializar los usuarios explícitamente.
4. **Automatización:** revisar [el workflow](../.github/workflows/validate.yml) y su ejecución en la pestaña Actions. Valida configuración y construcción, sin despliegue ni pruebas automáticas de failover.
5. **Presentación:** el [guion de demo](PRESENTACION.md) explica decisiones, comandos y límites del laboratorio.

## Qué revisar durante la demo

- Un primario y dos réplicas visibles en Patroni.
- Conexión por 5000 al primario y por 5001 a una réplica.
- Elección de un nuevo líder después de detener el anterior y recuperación de una nueva conexión.
- Reintegración del nodo al finalizar.
- Métricas visibles y explicación de los resultados de carga.

## Límites declarados

El despliegue usa un único host y un solo HAProxy. No incluye dashboards provisionados, alertas con notificaciones ni despliegue automático. El failover y las pruebas de permisos deben repetirse en el entorno de demo. Los benchmarks son históricos y no establecen un SLA ni una capacidad de producción.
