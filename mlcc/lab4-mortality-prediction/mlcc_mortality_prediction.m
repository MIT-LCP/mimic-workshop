%% Build a better mortality prediction model

password = ''; % ask a demonstrator for the password to the instance


% Tell Matlab where the driver is
javaclasspath('postgresql-9.4.1207.jar') % note we are using a postgres driver
%% Initiate our database connection with Amazon
% Connect to the Database
conn = database('MIMIC','workshop',password,...
    'Vendor','PostgreSQL',...
    'Server','<xxxxx>.amazonaws.com',...
    'PortNumber',5432);

if isempty(conn.Message)
    % nothing went wrong hurray
    fprintf('Connected to the database!\n');
else
    switch conn.Message
        case 'Unable to find JDBC driver.'
            error('You do not have the JDBC driver installed. Please ensure MATLAB can find the .jar file.');
        case 'The server requested password-based authentication, but no password was provided.'
            error('Please enter the password provided to you in the password variable at the top of the script.');
        otherwise
            error(conn.Message)
    end
end

% NOTE: below is how we used to connect to the local sqlite file
%   javaclasspath('sqlite-jdbc-3.8.11.2.jar') % use this for SQLite
%   conn = database('','','',...
%     'org.sqlite.JDBC',['jdbc:sqlite:' pwd filesep 'data' filesep 'mimiciii_v1_3_demo.sqlite']);

% it's convenient to have our database connection return "dataset" data
% we can extract header information from dataset outputs
setdbprefs('DataReturnFormat','dataset')

%% Extract the patient data using the query
% *Highly advised* to not extract your data all at once in one query
% That way if you find a typo, you only need to re-run a subcomponent,
% not the entire data extraction process!

% read the text from the file
query = makeQuery('mlcc-extract-data.sql');

% run the query on the database connection
tic;
data = fetch(conn,query);
toc;

%% (Optional) convert the data from a dataset to an X design matrix
% first convert data to a cell array
data = dataset2cell(data);

% we can get the column names from the first row of the 'data' variable
header = data(1,:);
header = regexprep(header,'_',''); % remove underscores

% remove the header row from the data cell
data = data(2:end,:);

% MATLAB sometimes reads 'null' sometimes instead of NaN
data(cellfun(@isstr, data) & cellfun(@(x) strcmp(x,'null'), data)) = {NaN};

% MATLAB sometimes has blank cells which should be NaN
data(cellfun(@isempty, data)) = {NaN};

% Convert the data into a matrix of numbers
% This is a MATLAB data type thing - we can't do math with cell arrays
data = cell2mat(data);


X_id = data(:, strcmp(header,'ICUSTAYID'));
y = data(:, strcmp(header,'OUTCOME'));

X = data(:, ~ismember( header, {'ICUSTAYID','OUTCOME'}) );
X_header = header(~ismember( header, {'ICUSTAYID','OUTCOME'}));

%% Print out the first 5 rows of the data
W = 5; % the maximum number of columns to print at one time
% can set this wider for wider monitors
for o=1:floor(size(X,2)/W)
    idxColumn = (o-1)*W + 1 : o*W;
    if idxColumn(end) > size(X,2)
        idxColumn = idxColumn(1):size(X,2);
    end

    fprintf('%12s\t',X_header{idxColumn});
    fprintf('\n');
    for n=1:5
        for m=idxColumn
            fprintf('%12g\t',X(n, m));
        end
        fprintf('\n');
    end
    fprintf('\n');
end


%% Inspect the data
figure(1); clf; hold all;

% Box-plots are very useful for quickly looking for outliers, etc
boxplot(X,'plotstyle','compact','labels',X_header);

%% Perform data preprocessing
% correct ages, remove outliers, etc.


%% Sub-sample the frequent class to balance the number in each class
% This is not always needed - but some models do better with it
% Alternatively, you could up-sample the infrequent class
balanceData = false;

% optionally, we can balance the subsets
if balanceData == true
    N0 = sum(y_train==0);
    N1 = sum(y_train==1);

    [~,idxRandomize] = sort(rand(N0,1));
    idxKeep = find(y_train==0); % find all the negative outcomes
    idxKeep = idxKeep(idxRandomize(1:N1)); % pick a random N1 negative outcomes
    idxKeep = [find(y_train==1);idxKeep]; % add in the positive outcomes
    idxKeep = sort(idxKeep); % probably not needed but it's cleaner
else
    idxKeep = true(size(X,1),1);
end

X_train = X(idxKeep,:);
y_train = y(idxKeep);

%% Create cross-fold validation indices
K = 5; % how many folds

[~,idxK] = sort(rand(size(X_train,1),1));
idxK = mod(idxK,K) + 1;

%% Train a classifier
% Here is an example using logistic regression

auroc = zeros(1,K);

for k=1:K
    idxDevelop  = idxK ~= k;
    idxValidate = idxK == k;

    X_develop = X_train(idxDevelop,:);
    y_develop = y_train(idxDevelop,:);

    X_validate = X_train(idxValidate,:);
    y_validate = y_train(idxValidate,:);

    % Normalize and impute means for the data before training

    % Normalize the data
    mu = nanmean(X_develop, 1);
    sigma = nanstd(X_develop, [], 1);
    X_develop = bsxfun(@minus, X_develop, mu);
    X_develop = bsxfun(@rdivide, X_develop, sigma);

    X_validate = bsxfun(@minus, X_validate, mu);
    X_validate = bsxfun(@rdivide, X_validate, sigma);

    % Impute the mean (equal to 0 since we normalized the mean to be 0)
    X_develop(isnan(X_develop)) = 0;
    X_validate(isnan(X_validate)) = 0;


    % (Option 1). A logistic regression
    model = glmfit(X_develop, y_develop, 'binomial');
    y_hat = glmval(model, X_validate, 'logit');

    % (Option 2). An SVM
    % model = svmtrain(y_develop, X_develop, '-q -t 2');
    % [pred,~,y_hat] = svmpredict(y_validate, X_validate, model);

    % if (pred(1) == 0 && y_hat(1) > 0) || (pred(1) == 1 && y_hat(1) < 0)
    %     % flip the sign of dist to ensure that the AUROC is calculated properly
    %     % the AUROC expects predictions of 1 to be assigned increasing distances
    %     y_hat = -y_hat;
    % end

    % Calculate our performance metric: the AUROC.
    [~, ~, auroc(k)] = calcRoc(y_hat, y_validate);
end

fprintf('Mean AUROC across %d folds: %4.4f.\n',K, mean(auroc));
