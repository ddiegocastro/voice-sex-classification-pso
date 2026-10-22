% PSO feature selection + SVM / Random Forest evaluation.
% Plain-text export of live_scripts/*.mlx (code cells only).

% Cargar coeficientes de Hombres y Mujeres.
coeffH = coefficientsHombre;
coeffM = coefficientsMujer;

% Crear labels para género. 
coeffH.gender = ones(height(coeffH),1);
coeffM.gender = zeros(height(coeffM),1);

% Eliminar genderH y genderM respectivamente.
coeffH = removevars(coeffH, 'genderH');
coeffM = removevars(coeffM, 'genderM');

% Crear labels para cada vocal. 
% Hombres
coeffH.vowelLabel = zeros(height(coeffH),1);

coeffH.vowelLabel(coeffH.vowelH == "A") = 1;
coeffH.vowelLabel(coeffH.vowelH == "E") = 2;
coeffH.vowelLabel(coeffH.vowelH == "I") = 3;
coeffH.vowelLabel(coeffH.vowelH == "O") = 4;
coeffH.vowelLabel(coeffH.vowelH == "U") = 5;

% Mujer
coeffM.vowelLabel = zeros(height(coeffM),1);

coeffM.vowelLabel(coeffM.vowelM == "A") = 1;
coeffM.vowelLabel(coeffM.vowelM == "E") = 2;
coeffM.vowelLabel(coeffM.vowelM == "I") = 3;
coeffM.vowelLabel(coeffM.vowelM == "O") = 4;
coeffM.vowelLabel(coeffM.vowelM == "U") = 5;

% Borrar la columna vowelM y vowelH, respectivamente.
coeffM = removevars(coeffM, "vowelM");
coeffH = removevars(coeffH, "vowelH");

% Cambiar orden de columnas de manera que Gender y VowelLabel sean las
% primeras
coeffM = coeffM(:, {'gender', 'vowelLabel', coeffM.Properties.VariableNames{1:end-2}})
coeffH = coeffH(:, {'gender', 'vowelLabel', coeffH.Properties.VariableNames{1:end-2}})

% Convertir de table a array. 
M_coeffM = table2array(coeffM);
M_coeffH = table2array(coeffH);

% Features
X_M = M_coeffM(:,3:end);
X_H = M_coeffH(:,3:end);
X = [X_M; X_H];

% Target
y_M = M_coeffM(:,1);
y_H = M_coeffH(:,1);
y = [y_M; y_H];

% CREAR TABLA DE DATOS COMPLETOS. 
M_complete = [X y]
T_complete = array2table(M_complete)

% Número de columnas MFCC
nMFCC = 14;

% Crear nombres nuevos para MFCC1...MFCC14
mfccNames = "MFCC" + string(1:nMFCC);

% Asignar último nombre como Gender
newNames = [mfccNames, "Gender"];

T_complete.Properties.VariableNames = newNames
writetable(T_complete, "Gender_Voice_FullFeatures.csv")

% Semilla
rng(42);

% Shuffle para evitar bias 
idx = randperm(size(X,1));
X = X(idx,:);
y = y(idx);

% Partición de datos
% Train/Test 80-20
cv = cvpartition(y, 'HoldOut', 0.20);

X_train = X(training(cv), :);
y_train = y(training(cv));

X_test  = X(test(cv), :);
y_test  = y(test(cv));

% Normalización de datos. 
[X_train_norm, mu, sigma] = zscore(X_train);
X_test_norm = (X_test-mu) ./ sigma;

nFeatures = size(X_train_norm,2);
nParticles = 20; % Arbitrario 

lb = zeros(1, nFeatures);
ub = ones(1, nFeatures);
alpha = 0.9;

fitnessFcn = @(p) fitnessFS(p,X_train_norm,y_train, alpha);

options = optimoptions('particleswarm', ...
    'SwarmSize', nParticles, ...
    'MaxIterations', 100, ...
    'Display', 'iter', ...
    'HybridFcn', @fmincon);

tic()
[bestParticle, bestCost] = particleswarm(fitnessFcn, nFeatures, lb, ub, options);
toc()

% Redondear para decidir qué features usar
bestFeatures = bestParticle > 0.5;
disp('Features seleccionados:');
disp(bestFeatures);
disp('Accuracy estimado:');
disp(1 - bestCost);

% Entrenar el modelo final con features seleccionadas 
X_train_sel = X_train_norm(:, bestFeatures);
modelo_final = fitcsvm(X_train_sel, y_train, 'KernelFunction','rbf');

% Evaluar modelo 
X_test_sel = X_test_norm(:, bestFeatures);
y_pred = predict(modelo_final, X_test_sel);

accuracy_test = mean(y_pred == y_test);
disp('Accuracy en TEST:');
disp(accuracy_test);

% Obtener las features obtenidas para pasar a Python. 
idx_features = find(bestFeatures == 1);
X_sel = X(:,bestFeatures);
data_final = [X_sel y];
varNames = ["Coeff" + string(idx_features) "Gender"];

T_features = array2table(data_final, 'VariableNames',varNames);
writetable(T_features, 'Gender_Voice_Featuring.csv');

nFeatures = size(X_train_norm,2);
nParticles = 20; % Arbitrario 

lb = zeros(1, nFeatures);
ub = ones(1, nFeatures);
alpha = 0.9;

fitnessFcn_RFC = @(p) fitnessFS_RFC(p,X_train_norm,y_train,alpha);

options = optimoptions('particleswarm', ...
    'SwarmSize', nParticles, ...
    'MaxIterations', 50, ...
    'Display', 'iter', ...
    'HybridFcn', @fmincon);


tic()
[bestParticle, bestCost] = particleswarm(fitnessFcn_RFC, nFeatures, lb, ub, options);
toc()

% Redondear para decidir qué features usar
bestFeatures = bestParticle > 0.5;
disp('Features seleccionados:');
disp(bestFeatures);
disp('Accuracy estimado:');
disp(1 - bestCost);

% Entrenar el modelo final con features seleccionadas 
X_train_sel = X_train_norm(:, bestFeatures);
modelo_final = TreeBagger(100, X_train_sel, y_train, ...
    'Method', 'classification', ...
    'OOBPrediction', 'on');

% Evaluar modelo 
X_test_sel = X_test_norm(:, bestFeatures);
y_pred = predict(modelo_final, X_test_sel);
y_pred = str2double(y_pred)

accuracy_test = mean(y_pred == y_test);
disp('Accuracy en TEST:');
disp(accuracy_test);

function cost = fitnessFS(particle, X, y, alpha)
    
    particle = particle > 0.5;
    
    num_feat = sum(particle);
    max_feat = length(particle);

    % Penalizar si no selecciona ninguna
    if num_feat == 0
        cost = 999;
        return
    end

    % Subconjunto seleccionado
    Xsel = X(:, particle);

    try
        modelo = fitcsvm(Xsel, y, 'KernelFunction','rbf');
        CV = crossval(modelo,'KFold',5);
        acc = 1 - kfoldLoss(CV);
    catch
        acc = 0; % Error => accuracy 0
    end
    % Nueva función objetivo
    cost = alpha * (1 - acc) + (1 - alpha) * (num_feat / max_feat);
end


function cost = fitnessFS_RFC(particle, X, y, alpha)

    particle = particle > 0.5;

    num_feat = sum(particle);
    max_feat = length(particle);

    if num_feat == 0
        cost = 999;
        return
    end

    Xsel = X(:, particle);

    try
        nTrees = 100;
        cv = cvpartition(y, 'KFold', 5);
        accFold = zeros(cv.NumTestSets, 1);

        for i = 1:cv.NumTestSets
            idxTrain = training(cv, i);
            idxTest = test(cv, i);

            Xtrain = Xsel(idxTrain, :);
            ytrain = y(idxTrain);
            Xtest = Xsel(idxTest, :);
            ytest = y(idxTest);

            modelo = TreeBagger(nTrees, Xtrain, ytrain, ...
                                'Method', 'classification', ...
                                'NumPredictorsToSample', floor(sqrt(num_feat)), ...
                                'OOBPrediction', 'off');

            % Convertir predicciones a double
            pred = str2double(predict(modelo, Xtest));

            accFold(i) = mean(pred == ytest);
        end

        acc = mean(accFold);

    catch
        acc = 0;
    end

    cost = alpha * (1 - acc) + (1 - alpha) * (num_feat / max_feat);
end


