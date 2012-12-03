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

allLabels = C{1};
trainFeats = cell2mat(C(2:end));

trainSampleCount = size(trainFeats, 1);
featCount = size(trainFeats, 2);

trainOutLabels = cell(trainSampleCount, 1);

featuresUsing = [1 2 4 5 6 7 10 12 14 15];

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
    


%Begin k nearest neighbors
FOLDS = 5;
total_correct = 0;
for i = 1:FOLDS
    
    % Get test data
    testRows = [];
    cursor = i;
    for j = 1:trainSampleCount/FOLDS
        testRows(j,:) = trainFeats(cursor,:);
        testLabels{j} = allLabels{cursor};
        cursor = cursor + FOLDS;
    end  
    % Normalize test data
    testNormalized = doAllNormalization(testRows);
   
    
    % Get train data
    trainRows = [];
    cursorToSkip = i;
    counter = 1;
    for j = 1:trainSampleCount
        
        if( j == cursorToSkip )
            cursorToSkip = cursorToSkip + FOLDS;
            continue;
        end
        
        trainRows(counter,:) = trainFeats(j,:);
        trainLabels{counter} = allLabels{j};
        counter = counter + 1;
    end
    % Normalize train data
    trainNormalized = doAllNormalization(trainRows);
        
    
    % Get distance
    counter = 0;
    for j = 1:size(testNormalized,1)
        
        min_index = -1;
        min_dist = 100000;
        
        for k = 1: size(trainNormalized,1)
            distance = dist( testNormalized(j,:), trainNormalized(k,:), featuresUsing);
            % Compare newest distance to the current max dist
            if(distance < min_dist)
                min_dist = distance;
                min_index = k;
            end
        end
        
        %fprintf('Checking %s(%d). Classified as %s(%d). Min Dist: %d\n',...
         %       testLabels{j},j,trainLabels{min_index},min_index,min_dist);
        if( strcmp(testLabels{j},trainLabels{min_index}) == 1 )
            counter = counter + 1;
        end
    end
    
    fprintf('Correct: %d/%d - %f\n',counter,size(testRows,1), counter/size(testRows,1));
    total_correct = total_correct + counter;
    
end

fprintf('Avg: %f\n', total_correct/(size(testRows,1)*FOLDS));

end

function normFeatures = doAllNormalization(features)

    global ASSIGNMENTS_INDEX;
    global EQUALITY_INDEX;
    global EQUALITYOPP_INDEX;
    global OPEN_PARENL_INDEX;
    global OPEN_PARENR_INDEX;
    global OPEN_PARENOPP_INDEX;
    global CLOSE_PARENL_INDEX;
    global CLOSE_PARENR_INDEX;
    global CLOSE_PARENOPP_INDEX;

    normFeatures = normalizeByLines(features,1,ASSIGNMENTS_INDEX - 1);
    normFeatures = normalizeByOpp(normFeatures,[EQUALITY_INDEX],EQUALITYOPP_INDEX);
    normFeatures = normalizeByOpp(normFeatures,...
                    [OPEN_PARENL_INDEX OPEN_PARENR_INDEX],OPEN_PARENOPP_INDEX);
    normFeatures = normalizeByOpp(normFeatures,...
                    [CLOSE_PARENL_INDEX CLOSE_PARENR_INDEX],CLOSE_PARENOPP_INDEX);
                
    normFeatures = normalizeData(normFeatures);

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
            %fprintf('Index: %d, OppIndex: %d, OppValue: %f\n',index,oppIndex,oppValue);
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
%fprintf('rows: %d\n', row);
col = size(mat,2);
%fprintf('col: %d\n', col);

for i = 1:col
    m = mean(mat(:,i));
    s = std(double(mat(:,i))) + eps;
    %fprintf('mean: %d\n', m);
    %fprintf('std: %d\n', s);
    %fprintf('entry: %d\n', mat(1,i));
    %fprintf('result: %d\n', (m-mat(1,i))/s);
    
    for j = 1:row
        x = (mat(j,i)-m)/s;
        %fprintf('Index(%d,%d) from %f to %f  avg=%f, std=%f\n', j,i,mat(j,i),x,m,s);
        normMat(j,i) = x;
        if(isinf(x) || isnan(x))
            fprintf('BIG PROBLEM');
        end
    end
end
end

function distance = dist(testFeat, trainFeat, featIndex)
sum = 0;
MAX = size(featIndex,2);

for i = 1:MAX
    sum = sum + (testFeat(featIndex(i)) - trainFeat((featIndex(i))))^2;
    %fprintf('FeatIndex %d was %d which has value in testFeat %d\n',...
     %           i,featIndex(i), testFeat(featIndex(i)));
                    
end

distance = sqrt(sum);
end
