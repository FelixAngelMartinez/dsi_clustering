# DSI_Clustering
Proyecto para la asignatura del Máster en Ingeniería Informática llamada Desarrollo de Sistemas Inteligentes, en la cual, se empleará R para realizar un análisis de los datos de ventas de un mayorista para determinar los grupos de clientes que tiene empleando la técnica Mapas Auto-organizados.
Como hemos mencionado con anterioridad se ha empleado el algoritmo asignado por los profesores, SOM, del inglés Self-organizing maps.

## Elementos
En dicho repositorio nos encontramos una carpeta /src la cual contiene los archivos en R para ejecutar dicho algoritmo sobre los datos en /src/data .
También tenemos la carpeta /documentation donde encontraremos la documentación resultante de dicho trabajo, la cual está escrita en formato ACM junto con el enunciado de la práctica.

## Análisis
### Análisis de variables
El documento Wholesale customers data.csv está formado por un total de 8 atributos y 440 regsitros de clientes.
A: Tipo de cliente
B: Región
C: Gasto anual en productos frescos.
D: Gasto anual en productos lácteos.
E: Gasto anual en productos de ultramarinos.
F: Gasto anual en productos congelados.
G: Gasto anual en detergentes y productos de papelería.
H: Gasto anual en productos delicatessen.

Los 2 primeros atributos se descartan ya que son el tipo de cliente y región, dichos atributos no muestran una relación entre el número que possen y el significado de la misma, por lo que estropearian nuestro análisis si no realizamos antes pasos previos con ellos, como sería convertirlas en variables "dummies".

### PCA
Se ha aplicado un análisis PCA para reducir las componentes y poder tener una visión global de los posibles grupos y detectar outliers.

### Detección de Outliers
Para la detección de valores fuera de lo común, o también conocido como "outliers" se ha empleado la técnica de "Jack-knife" la cual mediante una variación de +-3 detectará aquellos valores fuera de lo común.

### Grado de homogeneidad
Se ha medido el grado de homogeneidad empleando BIC, esto ayudará a saber cuantos grupos son necesarios implementar en nuestro algoritmo SOM.


### Escalado de los datos
No se ha procedido a un escalado de los datos dado que al aplicar un escalado, un mismo valor en diferentes columnas puede tener valores distintos, por lo que no sería lógico que por ejemplo tengamos que un cliente gasta 100€ en X y los mismo 100€ en Y valgan distinto. También al escalar los datos perdemos información semántica.

## Ejecución
Para ejecutar dicho programa lo que debemos tener instalado es RStudio, ya que será el IDE desde donde ejecutaremos nuestro código.
Para que el código se pueda ejecutar es necesario tener instaladas las librerias que aparecen al principio, para ello nos vamos a Tools -> Install Package , y ponemos el nombre de dichas librerias.

