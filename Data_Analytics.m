%---------Identificación de Nulos---------

%Identificamos la matriz de datos faltantes del DataFrame
Matriz_Null= ismissing(carcrashes);

%Identificamos la cantidad de datos faltantes por Columna
Column_Null= sum(Matriz_Null);

%Identificamos la cantidad de datos faltantes por DataFrame
DataFrame_Null= sum(Column_Null);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------Sustitución de Nulos---------

%Rellenamos datos faltantes por DataFrame usando un método
DataFrame_Fill_1 = fillmissing(carcrashes,'previous');

%Rellenamos datos faltantes por DataFrame usando diferentes métodos
DataFrame_Fill_2 = fillmissing(carcrashes,'next','DataVariables',{'total','speeding'});
DataFrame_Fill_3 = fillmissing(DataFrame_Fill_2,'movmean', 50,'DataVariable',{'not_distracted'});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------Identificación de Outliers---------


%Identificamos Matriz de outliers mediante método de quartiles
Outliers1 = isoutlier(DataFrame_Fill_3,'quartiles','DataVariables',{'total','speeding','alcohol','not_distracted','no_previous','ins_premium','ins_losses'});
%Identificamos la cantidad de outliers por Columna
Column_outliers1= sum(Outliers1);
%Identificamos la cantidad de datos faltantes por DataFrame
DataFrame_outliers_quartiles= sum(Column_outliers1);

%Identificamos Matriz de outliers mediante método de grubbs
Outliers2 = isoutlier(DataFrame_Fill_3,'grubbs','DataVariables',{'total','speeding','alcohol','not_distracted','no_previous','ins_premium','ins_losses'});
%Identificamos la cantidad de outliers por Columna
Column_outliers2= sum(Outliers2);
%Identificamos la cantidad de datos faltantes por DataFrame
DataFrame_outliers_grubbs= sum(Column_outliers2);

%Identificamos Matriz de outliers mediante método de desviación estándar
Outliers3 = isoutlier(DataFrame_Fill_3,'mean','DataVariables',{'total','speeding','alcohol','not_distracted','no_previous','ins_premium','ins_losses'});
%Identificamos la cantidad de outliers por Columna
Column_outliers3= sum(Outliers3);
%Identificamos la cantidad de datos faltantes por DataFrame
DataFrame_outliers_desviacion= sum(Column_outliers3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------Sustitución de Outliers---------

%Rellenamos Outliers por DataFrame usando un método
DataFrame_Filloutliers_1 = filloutliers(DataFrame_Fill_3,'linear','DataVariables',{'total','speeding','alcohol','not_distracted','no_previous','ins_premium','ins_losses'});

%Rellenamos Outliers por DataFrame usando varios métodos
DataFrame_Filloutliers_2 = filloutliers(DataFrame_Fill_3,'next','DataVariables',{'total','speeding'});
%Rellenamos Outliers por DataFrame usando varios métodos
DataFrame_Filloutliers_3 = filloutliers(DataFrame_Filloutliers_2,'center','DataVariable',{'no_previous'});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------Filtros de Datos---------

%Filtro de variables tipo numérico
%Comparación
Filtro1 = groupfilter(DataFrame_Filloutliers_3,"abbrev",@(x) x>=21, "total");
%Igualdad
Filtro2 = groupfilter(DataFrame_Filloutliers_3,"abbrev",@(x) x== 7.175, "alcohol");
%Conector Lógico y
Filtro3 = groupfilter(DataFrame_Filloutliers_3,"abbrev",@(x) (x>800) && (x<900) , "ins_premium");
%Conector Lógico o
Filtro4 = groupfilter(DataFrame_Filloutliers_3,"abbrev",@(x) (x>20) || (x<10) , "total");
%Conector Lógico not
Filtro5 = groupfilter(DataFrame_Filloutliers_3,"abbrev",@(x)  ~(x<5) , "speeding");

%variables tipo string
%String
Filtro6 = groupfilter(DataFrame_Filloutliers_3,"abbrev",@(x) x=="DC", "abbrev");

%Filtro por filas
Filtro7= DataFrame_Filloutliers_3(1:35,:);

%Filtro por columnas
Filtro8= DataFrame_Filloutliers_3(:,1:7);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------Correlación de datos---------

%Matriz de correlaciones del Dataframe
Matriz=table2array(Filtro8); %esta línea convierte la tabla en matriz
Mat_Corr=corrcoef(Matriz); %Matriz de correlaciones

%Crear mapa de calor
%h = heatmap(Mat_Corr);

%Crear mapa de calor desde la tabla con variables
%h1 = heatmap(Filtro8, "total","alcohol");
%h2 = heatmap(Filtro8, "total","speeding");


%---------Regresión lineal-------------
%Variable alcohol
x1=Matriz(:,3);
%Variable no_previous
x2=Matriz(:,5);
%Variable total
y=Matriz(:,1);


%Variables independientes
X= [x1 x2];
%Variable dependiente
y= [y];
[b,~,~,~,stats] = regress(y,X);

%---------Predicción----------------

%Calcular predicción de columna total
total_Pred= b(1)*x1 + b(2)*x2;
%Agregar columna a tabla 
Tabla_Final= addvars(DataFrame_Filloutliers_3,total_Pred,'Before',"total");


%---------Visualización-------------

%Scatter plot de 3 variables 
figure(1)
scatter3(x1,x2,y,'filled');
hold on;
x1fit = min(x1):0.5:max(x1);
x2fit = min(x2):0.5:max(x2);
[X1FIT,X2FIT] = meshgrid(x1fit,x2fit);
YFIT = b(1)*X1FIT + b(2)*X2FIT;
mesh(X1FIT,X2FIT,YFIT);
xlabel('alcohol');
ylabel('no previous');
zlabel('Total');
view(30,10);
hold off


%Geobubble: Visualiza valores de datos en ubicaciones geográficas específicas
figure(2)
geobubble(Mexico,'latitude','longitude','SizeVariable','number_of_reviews','ColorVariable','room_type','Basemap','streets')
title 'México'

figure(3)
geobubble(Barcelona,'latitude','longitude','SizeVariable','number_of_reviews','ColorVariable','room_type','Basemap','streets')
title 'Barcelona';

figure(4)
geobubble(Mexico,'latitude','longitude','SizeVariable','price','ColorVariable','neighbourhood','Basemap','satellite')
title 'México'

figure(5)
geobubble(Barcelona,'latitude','longitude','SizeVariable','price','ColorVariable','neighbourhood','Basemap','satellite')
title 'Barcelona'


%Barras paralelas: Visualiza la relación entre 2 o mas variables
Mex_vars= Mexico(:,[9, 10, 12]);
figure(6)
parallelplot(Mex_vars,'GroupVariable','room_type')
title 'Mexico'

Barc_vars= Barcelona(:,[9, 10, 12]);
figure(7)
parallelplot(Barc_vars,'GroupVariable','room_type')
title 'Barcelona'

