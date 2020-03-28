library(rstudioapi) # Biblioteca para coger el directorio actual
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