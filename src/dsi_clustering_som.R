# Cargamos la biblioteca Kohonen
library("kohonen") # Biblioteca para utilizar SOM
library(rstudioapi) # Biblioteca para coger el directorio actual
library(cluster) # Biblioteca encargada de ejecutar Silhouette
# Limpiamos entorno de trabajo
cat("\014")

# Cargamos y NO escalamos los datos
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()
customers_data <- read.csv("data/wholesale_customers_data.csv", header = T)

# Data file analysis
# Columns= 1.Channel; 2.Region; 3.Fresh; 4.Milk; 5.Grocery; 6.Frozen; 7.Detergents_Paper; 8.Delicassen
str(customers_data)
summary(customers_data)
head(customers_data)

# Vamos a ignorar las columnas 1 y 2, ya que los valores que dan no tienen relaciÛn directa con el significado sem·ntico de Èste.
data <- customers_data[,3:8]
str(data)
summary(data)
head(data)

# --------------------------------------------------------------------------------
# PCA
# Calcular varianza entre variables de columnas
apply(data, 2, var)

acp <- prcomp(data,
              center= TRUE,
              scale = TRUE)
print(acp)
plot(acp, type = "l") #Varianzas
summary(acp) # Ver la proporciÛn acumulativa
biplot(acp, scale = 0)

pc1 <- apply(acp$rotation[,1]*data, 1, sum)
pc2 <- apply(acp$rotation[,2]*data, 1, sum)

pca <- data # Hacemos una copia
pca$pc1 <- pc1 
pca$pc2 <- pc2

pca <- pca[,7:8]
plot(pca, main = "PCA")

# --------------------------------------------------------------------------------
# PARETO
# Bubble Sort Function
sort.b <- function(x)
{
  if(!is.unsorted(x)) {stop("Vector is already sorted")}
  if(length(x)<2){stop("vector is not long enough") } 
  if ( !is.vector(x) )  { stop("parameter must be a vector") }
  if ( !is.numeric(x) ) { stop("parameter must be numeric") }
  
  n = length(x)
  v = x
  
  for(j in 1:(n-1))
  {
    for(i in 1:(n-j))
    {
      if(v[i+1]<v[i])
      {
        t = v[i+1]
        v[i+1] = v[i]
        v[i] = t    
      }
    }
  }
  print(v)
  x = v
}

# Ventas totales por cliente
total_ventas<-c()
for (i in 1:nrow(data)) {
  total_ventas_i <- as.numeric(sum(data[i,]))
  total_ventas[i] <- as.numeric(total_ventas_i)
}

# Ordenar las ventas totales
ordenados <- sort.b(total_ventas)

# Calculo de la suma total del 20% de los clientes constituyen el 80% de los ingresos
calculoSuma <- sum(ordenados[352:440])/sum(ordenados)
print(calculoSuma)
# Conocer cual realmente cual serÌa el porcentaje que nos da el 80% de las ventas
calculoSuma <- 0
i <- 0
while (calculoSuma<0.80) {
  calculoSuma <- sum(ordenados[(440-i):440])/sum(ordenados)
  print(calculoSuma)
  i <- i+1
}
print(i)
print((440-i)/440)

# --------------------------------------------------------------------------------
# SOM -> https://cran.r-project.org/web/packages/kohonen/kohonen.pdf
# Definimos primero los par√°metros de la funci√≥n som
grid <- somgrid(5, 4, "hexagonal")
rlen <- 10000

data <- as.matrix(data)
#customer.som <- som(data = wines.sc, grid = somgrid(5, 4, "hexagonal"))
customer.som <- som(data, grid, rlen)

# Resultados de customer.som interesantes
#customer.som[5] #codes
#customer.som[6] #changes

#
plot(customer.som, type = "changes", main = "Customer data: SOM")
#
plot(customer.som, main = "Customer data")
# plot the quantity of samples
plot(customer.som, type = "count", main = "Customer data: count")
# plot the distance matrix
plot(customer.som, type="quality")
# plot the codebooks vectors
plot(customer.som, type="codes")
# plot the mapping
#plot(customer.som, type="mapping", main = "Customer data: mapping", labels = as.integer(data), col = as.integer(data))
plot(customer.som, type="mapping", main = "Customer data: mapping")
# plot the distances
plot(customer.som, type="dist.neighbours", main = "Customer data: distances")

# --------------------------------------------------------------------------------
# silhouette -> https://stackoverflow.com/questions/33999224/silhouette-plot-in-r
# InterpretaciÛn: -1 si es un mal agrupamiento, 0 si es indiferente, 1 si es un buen agrupamiento

maxrow <- 5
maxcol <- 5
for (row in 2:maxrow) {
  for (col in 2:maxcol) {
    customer.som <- som(data, somgrid(row, col, "hexagonal"),10000)
    dis <- dist(customer.som$distances)
    sil <- silhouette (customer.som$unit.classif, dis)
    print(row)
    print(col)
    print(mean(sil[,3]))
    windows()
    plot(sil, col=1:(row*col), border=NA)
  }
}

