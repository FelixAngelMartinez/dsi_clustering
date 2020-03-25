# Cargamos la biblioteca Kohonen
library("kohonen") # Biblioteca para utilizar SOM
library(rstudioapi) # Biblioteca para coger el directorio actual
library(cluster) # Biblioteca encargada de ejecutar Silhouette
# Limpiamos entorno de trabajo
cat("\014")

# Cargamos y NO escalamos los datos
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()
customers_data <-
  read.csv("data/wholesale_customers_data.csv", header = T)

# Data file analysis
# Columns= 1.Channel; 2.Region; 3.Fresh; 4.Milk; 5.Grocery; 6.Frozen; 7.Detergents_Paper; 8.Delicassen
str(customers_data)
summary(customers_data)
head(customers_data)

# Vamos a ignorar las columnas 1 y 2, ya que los valores que dan no tienen relación directa con el significado semántico de éste.
data <- customers_data[, 3:8]
str(data)
summary(data)
head(data)

# --------------------------------------------------------------------------------
# PCA
# Calcular varianza entre variables de columnas
apply(data, 2, var)

acp <- prcomp(data,
              center = TRUE,
              scale = TRUE)
print(acp)
png('images/pca_variances.png')
plot(acp, type = "l", main = "PCA Variances") #Varianzas
dev.off()
summary(acp) # Ver la proporción acumulativa
png('images/pca_directionsofprincipalcomponents.png')
biplot(acp, scale = 0)
dev.off()

pc1 <- apply(acp$rotation[, 1] * data, 1, sum)
pc2 <- apply(acp$rotation[, 2] * data, 1, sum)

pca <- data # Hacemos una copia
pca$pc1 <- pc1
pca$pc2 <- pc2

pca <- pca[, 7:8]
png('images/pca_pc1pc2.png')
plot(pca, main = "PCA PC1 & PC2")
dev.off()

write.csv(pca, file = "data/pca_pc1pc2.csv", row.names = TRUE)

# --------------------------------------------------------------------------------
# Eliminar outliers
outliers_cols <-
  as.data.frame(read.csv("data/outliers.csv", header = F))
outliers_rows <- t(outliers_cols)
only_outliers <- data.frame()
for (i in nrow(outliers_rows):1) {
  print(i)
  print(outliers_rows[i])
  only_outliers <- rbind(only_outliers,data[outliers_rows[i],])
  data_without_outliers <- data[-outliers_rows[i], ]
}

write.csv(only_outliers, file = "data/data_outliers.csv", row.names = TRUE)
# --------------------------------------------------------------------------------
# PARETO
# Bubble Sort Function
sort.b <- function(x)
{
  if (!is.unsorted(x)) {
    stop("Vector is already sorted")
  }
  if (length(x) < 2) {
    stop("vector is not long enough")
  }
  if (!is.vector(x))  {
    stop("parameter must be a vector")
  }
  if (!is.numeric(x)) {
    stop("parameter must be numeric")
  }
  
  n = length(x)
  v = x
  
  for (j in 1:(n - 1))
  {
    for (i in 1:(n - j))
    {
      if (v[i + 1] < v[i])
      {
        t = v[i + 1]
        v[i + 1] = v[i]
        v[i] = t
      }
    }
  }
  print(v)
  x = v
}

# Ventas totales por cliente
total_ventas <- c()
for (i in 1:nrow(data)) {
  total_ventas_i <- as.numeric(sum(data[i,]))
  total_ventas[i] <- as.numeric(total_ventas_i)
}

# Ordenar las ventas totales
ordenados <- sort.b(total_ventas)

# Calculo de la suma total del 20% de los clientes constituyen el 80% de los ingresos
calculoSuma <-
  sum(ordenados[trunc(0.8 * (nrow(data))):nrow(data)]) / sum(ordenados)
#print(calculoSuma)
# Conocer cual realmente cual sería el porcentaje que nos da el 80% de las ventas
calculoSuma <- 0
i <- 0
while (calculoSuma < 0.80) {
  calculoSuma <-
    sum(ordenados[(nrow(data) - i):nrow(data)]) / sum(ordenados)
  #print(calculoSuma)
  i <- i + 1
}
#print(i)
#print((nrow(data) - i) / nrow(data)) # Porcentaje necesario del conjunto de daots que cumpla el 80% de los ingresos

# --------------------------------------------------------------------------------
# SOM -> https://cran.r-project.org/web/packages/kohonen/kohonen.pdf https://www.rdocumentation.org/packages/kohonen/versions/2.0.19/topics/som
# --------------------------------------------------------------------------------
# silhouette -> https://stackoverflow.com/questions/33999224/silhouette-plot-in-r
# Interpretación: -1 si es un mal agrupamiento, 0 si es indiferente, 1 si es un buen agrupamiento
data <- as.matrix(data_without_outliers)
types <- 2
maxrow <- 5
maxcol <- 5
# <- array(rep(0, types*maxrow*maxcol),c(types, maxrow, maxcol));
#means = sample(types:maxrow,maxcol,replace = TRUE)
topmean <- -1
toptype <- 0
toprow <- 0
topcol <- 0
for (i in 1:types) {
  if (i == 1) {
    type <- "rectangular"
  } else if (i == 2) {
    type <- "hexagonal"
  }
  #Comprobación de las dos primeras combinaciones
  
  for (row in 1:maxrow) {
    for (col in 1:maxcol) {
      if (row == 1 && col == 1) {
        
      } else{
        customer.som <- som(data, somgrid(row, col, type), 10000)
        dis <- dist(customer.som$distances)
        sil <- silhouette (customer.som$unit.classif, dis)
        print(type)
        print(row)
        print(col)
        mean <- mean(sil[, 3])
        print(mean)
        ##windows()
        #plot(sil, col = 1:(row * col), border = NA, main = "Silhouette")
        if (mean > topmean) {
          topmean <- mean
          toptype <- i
          toprow <- row
          topcol <- col
          topcustomer.som <- customer.som
        }
      }
    }
  }
}
print(topmean)
print(toptype)
print(toprow)
print(topcol)

# Plot factor de Silhouette
sil <- silhouette (topcustomer.som$unit.classif, dis)
png('images/silhouette.png')
plot(sil,
     col = 1:(toprow * topcol),
     border = NA,
     main = "Silhouette")
dev.off()

#Plots
#windows()
# plot the changes
png('images/som_changes.png')
plot(topcustomer.som, type = "changes", main = "Changes")
dev.off()
# plot the customer data
png('images/som_data.png')
plot(topcustomer.som, main = "Data")
dev.off()
# plot the quantity of samples
png('images/som_count.png')
plot(topcustomer.som, type = "count", main = "Count")
dev.off()
# plot the distance matrix
png('images/som_quality.png')
plot(topcustomer.som, type = "quality", main = "Quality")
dev.off()
# plot the codebooks vectors
png('images/som_codes.png')
plot(topcustomer.som, type = "codes", main = "Codes")
dev.off()
# plot the mapping
png('images/som_mapping.png')
plot(topcustomer.som, type = "mapping", main = "Mapping")
dev.off()
# plot the distances
#png('images/som_distances.png')
#plot(topcustomer.som, type = "dist.neighbours", main = "Distances")
#dev.off()

# Calculo de los representantes de los grupos
data <- cbind(data, Grupo = topcustomer.som$unit.classif)

# Calcular media del grupo 1 en frescos
suma <- 0
contador <- 0
medias <- matrix(nrow=max(data[, 7]), ncol=ncol(data - 1))

#Grupos, Variables, Filas
for (grupo in 1:max(data[, 7])) {
  for (variable in 1:ncol(data)) {
    for (row in 1:nrow(data)) {
      if (data[row, 7] == grupo) {
        suma <- suma + data[row, variable]
        contador <- contador + 1
      }
    }
    medias[grupo, variable] <- suma / contador
    print(medias[grupo, variable])
    suma <- 0
    contador <- 0
  }
}
print(medias)


# Exportar datos
write.csv(data, file = "data/data_groups.csv", row.names = TRUE)
