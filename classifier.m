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
OpenParenL	OpenParenR OpenParenOpp	CloseParenL	CloseParenR CloseParenOpp
%}

global NUM_LINES_INDEX;
global ASSIGNMENTS_INDEX;
global EQUALITY_INDEX;
global EQUALITYOPP_INDEX;
global OPEN_PARENL_INDEX;
global OPEN_PARENR_INDEX;
global OPEN_PARENOPP_INDEX;
global CLOSE_PARENL_INDEX;
global CLOSE_PARENR_INDEX;
global CLOSE_PARENOPP_INDEX;

NUM_LINES_INDEX     = 3;
ASSIGNMENTS_INDEX   = 10;
EQUALITY_INDEX      = 12;
EQUALITYOPP_INDEX   = 13;
OPEN_PARENL_INDEX   = 14;
OPEN_PARENR_INDEX   = 15;
OPEN_PARENOPP_INDEX = 16;
CLOSE_PARENL_INDEX  = 17;
CLOSE_PARENR_INDEX  = 18;
CLOSE_PARENOPP_INDEX = 19;

C = textscan(fTrainIn, '%s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');
fclose(fTrainIn);

trainLabels = C{1};
trainFeats = cell2mat(C(2:end));

trainSampleCount = size(trainFeats, 1);
featCount = size(trainFeats, 2);

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
testSampleCount = size(testFeats, 1);
testFeatCount = size(testFeats, 2);
%fprintf('Size of testFeats: %d x %d\n', testSampleCount, testFeatCount);
%fprintf('The first sample is %s.  Its third feature value is %f.\n', ...
%    testLabels{1}, testFeats(1,3));
%testSampleCount = size(testLabels, 1);
testOutLabels = cell(testSampleCount, 1);
%}

%{
FLOAT MAY BE A CLOSER APPROXIMATION?

The following normalizes each feature of each class based on the number of
lines/100 in a class's programs code.

For example:
Number of comments: 67
Number of lines: 233
Normalize by: 233/100 = 2
After normalization, number of comments: = 34
%}
    
    normFeatures = normalizeByLines(trainFeats,1,ASSIGNMENTS_INDEX - 1);
    normFeatures = normalizeByOpp(normFeatures,[EQUALITY_INDEX],EQUALITYOPP_INDEX);
    normFeatures = normalizeByOpp(normFeatures,...
                    [OPEN_PARENL_INDEX OPEN_PARENR_INDEX],OPEN_PARENOPP_INDEX);
    normFeatures = normalizeByOpp(normFeatures,...
                    [CLOSE_PARENL_INDEX CLOSE_PARENR_INDEX],CLOSE_PARENOPP_INDEX);
    
    normFeatures
    
    normed = normalizeData(normFeatures);

%{
Begin k nearest neighbors
for i = 1:testSampleCount
    n1 = intmax;
    for j = 1:trainSampleCount
        % Get the distance
        % Fill in what features we plan to look at
        % TODO:
        % FILL IN FEATURES NEEDED TO FIND EUCLIDEAN DISTANCE
        % ALSO GRAPH STUFF
        % distance = sqrt();
        
        
        % Compare newest distance to the current max dist
        if(distance < n1)
            n1 = distance;
            testLabels{i} = trainLabels{j};
        end
    end
end
%}
end

function normLines = normalizeByLines(features,fromIndex,upUntilIndex)

    global NUM_LINES_INDEX;

    normLines = features;
    
    for i = 1:size(features,1)
        normFactor = features(i,3)/100.0;
        if(normFactor == 0)
            continue;
        end
        for j = fromIndex:upUntilIndex
            if(j == NUM_LINES_INDEX )
                continue;
            end
            normLines(i,j) = features(i,j)/normFactor;
        end
    end
end

function normOpp = normalizeByOpp(features,indices,oppIndex)

    normOpp = features;
    
    for i = 1:size(features,1)
        for j = 1:size(indices,2)
            index = indices(j);
            oppValue = features(i,oppIndex);
            if( oppValue == 0 )
                continue;
            end
            fprintf('Index: %d, OppIndex: %d, OppValue: %f\n',index,oppIndex,oppValue);
            normOpp(i,index) = features(i,index)/oppValue;
        end
    end
end

% normalize the data received
function normMat = normalizeData(mat)
%{
Normalize data -> mat will be some column vector
1. take the mean of the column vector
2. take each entry in the column vector and do
(mean(column vector)-entry)/stddev(column vector)
3. return a normalized matrix normMat
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
        x = (mat(j,i)-m)/s;
        fprintf('Index(%d,%d) from %f to %f  avg=%f, std=%f\n', j,i,mat(j,i),x,m,s);
        normMat(j,i) = x;
        if(isinf(x) || isnan(x))
            fprintf('BIG PROBLEM');
        end
    end
end

end
