% Beginning of k-neareast-neighbor classifier
% Inputs: train data, test data
% Outputs: train out data(maybe not needed for this since we are concerned 
% with test data), test out data
function classifier(train_in, test_in, train_out, test_out)
%{
TODO:
1. Make sure we have a data file and a test file
2. Read in the data in whatever format it is in
3. Use Euclidean distance for finding neareast neighbor
4. Select entry from the test file and see which data entry it is closest to
5. Try 3 nearest neighbors and nearest neighbor and see which is better
6. Depending on which is better we may have to check for 3-way tie or take
majority of classes it is closest to
%}
fTrainIn = fopen(train_in, 'r');

%{
Features in the following order:
Class	Comments	BComments	NumOfLines	WhileCount	ForCount	IfCondCount	
BracketCount	AllSpaces	CSS	 Assignment	  AssignOpp	  Equality	EqualityOpp	
OpenParenL	OpenParenR	CloseParenL	CloseParenR
%}
C = textscan(fTrainIn, '%s %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d');
fclose(fTrainIn);
fprintf('Size of C: %d x %d\n', size(C));
disp(C{2});
trainLabels = C{1};

fprintf('Size of trainLabels: %d x %d\n', size(trainLabels));
fprintf('First training label: %s\n', trainLabels{1});

trainFeats = cell2mat(C(2:end));

trainSampleCount = size(trainFeats, 1);
featCount = size(trainFeats, 2);
fprintf('Size of trainFeats: %d x %d\n', trainSampleCount, featCount);

fprintf('The first sample is %s.  Its third feature value is %d.\n', ...
    trainLabels{1}, trainFeats(1,3));

trainSampleCount = size(trainLabels, 1);
trainOutLabels = cell(trainSampleCount, 1);

%{
fTestIn = fopen(testpath, 'r');
TEST_IN = textscan(fTestIn, '%s %f %f %f %f %f %f %f %f %f %f %f %f %f %f');
fclose(fTestIn);
%fprintf('Size of TEST_IN: %d x %d\n', size(TEST_IN));
testLabels = TEST_IN{1};
%fprintf('size of testLabels: %d x %d\n', size(testLabels));
%fprintf('First testing label: %s\n', testLabels{1});
testFeats = cell2mat(TEST_IN(2:end));
%testSampleCount = size(testFeats, 1);
%testFeatCount = size(testFeats, 2);
%fprintf('Size of testFeats: %d x %d\n', testSampleCount, testFeatCount);
%fprintf('The first sample is %s.  Its third feature value is %f.\n', ...
%    testLabels{1}, testFeats(1,3));
testSampleCount = size(testLabels, 1);
testOutLabels = cell(testSampleCount, 1);
%}

%{
The following normalizes each feature of each class based on the number of
lines/100 in a class's programs code.

For example:
Number of comments: 67
Number of lines: 233
Normalize by: 233/100 = 2
After normalization, number of comments: = 34
%}
for i = 1:trainSampleCount
fprintf('Number of lines: %d\n', trainFeats(i,3));
normByLines = trainFeats(i,3)/100;
fprintf('norm by: %d\n', normByLines);
    for j = 1:featCount
        if(j == 3)
            fprintf('%d\t', trainFeats(i,j));
            continue;
        end
        trainFeats(i,j) = trainFeats(i,j)/normByLines;
        fprintf('%d\t', trainFeats(i,j));
    end
    fprintf('\n');
end

normalizeData(trainFeats);
end

% normalize the data received
function normMat = normalizeData(mat)
%{
Normalize data -> mat will be some column vector
1. take the mean of the column vector
2. take each entry in the column vector and do
(mean(column vector)-entry)/stddev(column vector)
3. return a normalized column vector normMat
%}
row = size(mat,1); 
fprintf('rows: %d\n', row);
col = size(mat,2); 
fprintf('col: %d\n', col);

for i = 1:col
    m = mean(mat(:,i));
    s = std(double(mat(:,i))) + eps;
    fprintf('mean: %d\n', m);
    fprintf('std: %d\n', s);
    %fprintf('entry: %d\n', mat(1,i));
    %fprintf('result: %d\n', (m-mat(1,i))/s);
    
    for j = 1:row
        x = (m-mat(j,i))/s;
        normMat(j,i) = x;
        if(isinf(x) || isnan(x))
           fprintf('BIG PROBLEM');
        end
        fprintf('%d\n', x);
    end
end

end
