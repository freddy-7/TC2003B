#Importamos Librerias
import pandas as pd
import statsmodels.formula.api as smf
import matplotlib.pyplot as plt
import numpy as np


#Leemos data frame

df=pd.read_csv('car_crashes.csv')
print(df.head(5))

#Definimos la función del modelo de predicción

model=smf.ols(formula="total~alcohol", data=df).fit()
#print(model.params)


#Agregamos la columna de predicción al dataframe
Form= 5.3857776 + 2.032506*df["alcohol"]
df.insert(loc=0, column='Predicciones', value=Form)
#print (df)

#Graficamos los valores predecidos y los valores reales

df.plot(kind="scatter", x="alcohol", y="total")
plt.plot(pd.DataFrame(df["alcohol"]), pd.DataFrame(df["Predicciones"]), c='orange')
#plt.show()

#Calculamos el coeficiente de Determinación R cuadrado
#print(model.summary())

#Calculamos el coeficiente de correlación R 
correlacion= np.sqrt(0.727)
#print (correlacion)

