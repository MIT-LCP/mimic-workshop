%% Run the following to connect to the database

% STEP 1: Tell Matlab where the driver is
javaclasspath('sqlite-jdbc-3.8.11.2.jar') % use this for SQLite

% STEP 2: Connect to the Database
conn = database('','','',...
    'org.sqlite.JDBC',['jdbc:sqlite:' pwd filesep 'data' filesep 'mimiciii_v1_3_mini.sqlite']);

%% Take a look at "mlcc-query-1.sql" - this extracts a single value for each patient
% More specifically, it extracts the highest heart rate
query = makeQuery('mlcc-query-1.sql');
data = fetch(conn,query);

%% Plot a histogram of the highest heart rate values


%% Plot the highest heart rate against the highest respiratory rate


%% See if you can add in the highest GCS
% Then, run the query here to get the results.
query = makeQuery(''); % put the filename here
data = fetch(conn,query);


%% Plot the highest heart rate against the highest respiratory rate, colouring by outcome
% The patient outcome is stored in "HOSPITAL_EXPIRE_FLAG" - the 4th column


%% Plot the highest heart rate against the highest GCS, colouring by outcome
% Which variable do you feel discriminates mortality better?


%% What other variables could you add which might help?


%% Build a logistic regression to classify mortality
% This is equivalent to drawing a line of separation

% See: glmfit
% e.g. b = glmfit(X,y,'binomial')

