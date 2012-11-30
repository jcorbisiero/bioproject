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

end

% normalize the data received
function normMat = normalizeData(mat)
%{
TODO:
Normalize data -> mat will be some column vector
1. take the mean of the column vector
2. take each entry in the column vector and do
(mean(column vector)-entry)/stddev(column vector)
3. return a normalized column vector normMat
%}

end


