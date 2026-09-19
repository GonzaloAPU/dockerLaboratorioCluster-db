# Resultados de pgbench

Evidencia histórica del laboratorio. No se volvieron a ejecutar estas cargas al preparar el repositorio. Cada enlace conserva la salida original de la corrida.

| Clientes | Archivo | TPS | Latencia media (ms) | Fallidas |
| ---: | --- | ---: | ---: | ---: |
| 10 | [10clientes_prueba_1.txt](../resultados/10clientes_prueba_1.txt) | 941.70 | 10.612 | 0 |
| 10 | [10clientes_prueba_2.txt](../resultados/10clientes_prueba_2.txt) | 1097.01 | 9.109 | 0 |
| 10 | [10clientes_prueba_3.txt](../resultados/10clientes_prueba_3.txt) | 1137.89 | 8.782 | 0 |
| 25 | [25clientes_prueba_1.txt](../resultados/25clientes_prueba_1.txt) | 1837.74 | 13.589 | 0 |
| 25 | [25clientes_prueba_2.txt](../resultados/25clientes_prueba_2.txt) | 1964.18 | 12.714 | 0 |
| 25 | [25clientes_prueba_3.txt](../resultados/25clientes_prueba_3.txt) | 1013.15 | 24.658 | 0 |
| 50 | [50clientes_prueba_1.txt](../resultados/50clientes_prueba_1.txt) | 1997.95 | 23.880 | 0 |
| 50 | [50clientes_prueba_2.txt](../resultados/50clientes_prueba_2.txt) | 1934.03 | 25.823 | 0 |
| 50 | [50clientes_prueba_3.txt](../resultados/50clientes_prueba_3.txt) | 2170.69 | 23.007 | 0 |
| 100 | [100clientes_prueba_1.txt](../resultados/100clientes_prueba_1.txt) | 1983.45 | 50.347 | 0 |
| 100 | [100clientes_prueba_2.txt](../resultados/100clientes_prueba_2.txt) | 1838.58 | 54.290 | 0 |
| 100 | [100clientes_prueba_3.txt](../resultados/100clientes_prueba_3.txt) | 1393.88 | 70.535 | 0 |
| 200 | [200clientes_prueba_1.txt](../resultados/200clientes_prueba_1.txt) | 1796.86 | 111.093 | 0 |
| 200 | [200clientes_prueba_2.txt](../resultados/200clientes_prueba_2.txt) | 1701.73 | 117.248 | 0 |
| 200 | [200clientes_prueba_3.txt](../resultados/200clientes_prueba_3.txt) | 1441.53 | 134.717 | 0 |

## Condiciones registradas

Las 15 salidas indican escala 20, cuatro threads y una duración configurada de 60 segundos. El workload es el integrado TPC-B (sort of), en modo simple. TPS excluye el tiempo de conexión inicial.

Los archivos no registran el hardware, endpoint de conexión, comando completo ni todos los cambios de configuración entre corridas. Por eso los resultados describen este laboratorio y no sirven como una capacidad garantizada para producción.

## Lectura de los resultados

Las corridas de 50 clientes registraron entre 1934 y 2171 TPS. Las de 200 clientes registraron entre 1442 y 1797 TPS, con latencias medias de 111 a 135 ms. La variabilidad de las corridas requiere repetir pruebas controlando entorno y carga antes de atribuir causas. Cero transacciones fallidas en estas corridas no demuestra ausencia de pérdida de datos durante un failover.
