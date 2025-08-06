function TESTHybrid(trainInputs, trainTargets, valInputs, valTargets, testInputs, testTargets, net)

% Choose Input and Output Pre/Post-Processing Functions
net.inputs{1}.processFcns = {'removeconstantrows','mapminmax'};
net.outputs{2}.processFcns = {'removeconstantrows','mapminmax'};

% Setup Division of Data - Use specified datasets
net.divideFcn = 'divideind';  % Use index division
net.divideMode = 'sample';

% Combine all data
allInputs = [trainInputs, valInputs, testInputs];
allTargets = [trainTargets, valTargets, testTargets];

% Create indices
numTrain = size(trainInputs, 2);
numVal = size(valInputs, 2);
numTest = size(testInputs, 2);

trainInd = 1:numTrain;
valInd = (numTrain + 1):(numTrain + numVal);
testInd = (numTrain + numVal + 1):(numTrain + numVal + numTest);

% Set division parameters
net.divideParam.trainInd = trainInd;
net.divideParam.valInd = valInd;
net.divideParam.testInd = testInd;

net.trainFcn = 'trainlm';  % Levenberg-Marquardt
% Choose a Performance Function
net.performFcn = 'mse';  % Mean squared error
% Choose Plot Functions
net.trainParam.showWindow = false;
net.trainParam.showCommandLine = false;
net.trainParam.show = 1;
net.trainParam.epochs = 100;
net.trainParam.goal = 1e-8;
net.trainParam.max_fail = 20;

%% Start
% Train the Network
[net, tr] = train(net, allInputs, allTargets);

% Test the Network
outputs = net(allInputs);
errors = gsubtract(allTargets, outputs);
performance = perform(net, allTargets, outputs);

%% Calculate Performance for each dataset
trainOutputs = outputs(:, trainInd);
trainErrors = trainTargets - trainOutputs;
trainPerformance = perform(net, trainTargets, trainOutputs);

valOutputs = outputs(:, valInd);
valErrors = valTargets - valOutputs;
valPerformance = perform(net, valTargets, valOutputs);

testOutputs = outputs(:, testInd);
testErrors = testTargets - testOutputs;
testPerformance = perform(net, testTargets, testOutputs);

%% Plot regression graphs
figure;
set(gcf, 'color', 'white');

% Plot training set regression
subplot(2, 2, 1);
scatter(trainTargets, trainOutputs, 40, 'o', 'MarkerEdgeColor', 'k');
hold on;
p_train = polyfit(trainTargets, trainOutputs, 1);
yfit_train = polyval(p_train, trainTargets);
plot(trainTargets, yfit_train, 'b-', 'LineWidth', 2);
plot([min(trainTargets), max(trainTargets)], [min(trainTargets), max(trainTargets)], 'k--');
R_train = corrcoef(trainTargets, trainOutputs);
text(min(trainTargets), max(trainOutputs), sprintf('Training: R=%.5f', R_train(2,1)), 'FontSize', 10, 'FontWeight', 'bold');
eqn_train = sprintf('%.2f*Target%+.4f', p_train(1), p_train(2));
ylabel(['Output = ' eqn_train]);
xlabel('Target');
legend('Data', 'Fit', 'Y=T', 'Location', 'best');
title(['Training: R=' num2str(R_train(2,1), '%.5f')]);
box on

% Plot validation set regression
subplot(2, 2, 2);
scatter(valTargets, valOutputs, 40, 'o', 'MarkerEdgeColor', 'k');
hold on;
p_val = polyfit(valTargets, valOutputs, 1);
yfit_val = polyval(p_val, valTargets);
plot(valTargets, yfit_val, 'g-', 'LineWidth', 2);
plot([min(valTargets), max(valTargets)], [min(valTargets), max(valTargets)], 'k--');
R_val = corrcoef(valTargets, valOutputs);
text(min(valTargets), max(valOutputs), sprintf('Validation: R=%.5f', R_val(2,1)), 'FontSize', 10, 'FontWeight', 'bold');
eqn_val = sprintf('%.2f*Target%+.4f', p_val(1), p_val(2));
ylabel(['Output = ' eqn_val]);
xlabel('Target');
legend('Data', 'Fit', 'Y=T', 'Location', 'best');
title(['Validation: R=' num2str(R_val(2,1), '%.5f')]);
box on

% Plot test set regression
subplot(2, 2, 3);
scatter(testTargets, testOutputs, 40, 'o', 'MarkerEdgeColor', 'k');
hold on;
p_test = polyfit(testTargets, testOutputs, 1);
yfit_test = polyval(p_test, testTargets);
plot(testTargets, yfit_test, 'r-', 'LineWidth', 2);
plot([min(testTargets), max(testTargets)], [min(testTargets), max(testTargets)], 'k--');
R_test = corrcoef(testTargets, testOutputs);
text(min(testTargets), max(testOutputs), sprintf('Test: R=%.5f', R_test(2,1)), 'FontSize', 10, 'FontWeight', 'bold');
eqn_test = sprintf('%.2f*Target%+.4f', p_test(1), p_test(2));
ylabel(['Output = ' eqn_test]);
xlabel('Target');
legend('Data', 'Fit', 'Y=T', 'Location', 'best');
title(['Test: R=' num2str(R_test(2,1), '%.5f')]);
box on

% Plot all data regression
subplot(2, 2, 4);
scatter(allTargets, outputs, 40, 'o', 'MarkerEdgeColor', 'k');
hold on;
p_all = polyfit(allTargets, outputs, 1);
yfit_all = polyval(p_all, allTargets);
plot(allTargets, yfit_all, 'k-', 'LineWidth', 2);
plot([min(allTargets), max(allTargets)], [min(allTargets), max(allTargets)], 'k--');
R_all = corrcoef(allTargets, outputs);
text(min(allTargets), max(outputs), sprintf('All: R=%.5f', R_all(2,1)), 'FontSize', 10, 'FontWeight', 'bold');
eqn_all = sprintf('%.2f*Target%+.4f', p_all(1), p_all(2));
ylabel(['Output = ' eqn_all]);
xlabel('Target');
legend('Data', 'Fit', 'Y=T', 'Location', 'best');
title(['All: R=' num2str(R_all(2,1), '%.5f')]);
box on

set(gcf, 'Position', [100 100 900 700]);

%% Plot learning curves
figure;
plot(tr.epoch, tr.perf); % Training performance
hold on;
plot(tr.epoch, tr.vperf); % Validation performance
plot(tr.epoch, tr.tperf); % Test performance
legend('Training Performance', 'Validation Performance', 'Test Performance');
xlabel('Epochs');
ylabel('Performance (MSE)');
title('Learning Curves');
grid on;
set(gcf, 'color', 'white');

%% Display performance results
fprintf('Training Performance: %.6f\n', trainPerformance);
fprintf('Validation Performance: %.6f\n', valPerformance);
fprintf('Test Performance: %.6f\n', testPerformance);

end