%% Run the following to connect to the database

% STEP 1: Tell Matlab where the driver is
javaclasspath('sqlite-jdbc-3.8.11.2.jar') % use this for SQLite

% STEP 2: Connect to the Database
conn = database('','','',...
    'org.sqlite.JDBC',['jdbc:sqlite:' pwd filesep 'data' filesep 'mimicdata.sqlite']);

%% Take a look at "mlcc-query-1.sql" - this extracts a single value for each patient
% More specifically, it extracts the highest heart rate
% See if you can add in the highest respiratory rate and highest GCS
% Then, run the query here to get the results.

%% Plot the highest heart rate against the highest respiratory rate



%% Plot the highest heart rate against the highest respiratory rate, colouring by outcome
% The patient outcome is stored in "HOSPITAL_EXPIRE_FLAG" - the 5th column



%% Box-plot the heart rate and respiratory rates
% How could you modify "mlcc-query-1.sql" to prevent outliers?


%% Plot the highest heart rate against the highest GCS, colouring by outcome
% Which variable do you feel discriminates mortality better?


%% Build a logistic regression to classify mortality
% This is equivalent to drawing a line of separation

% See: glmfit
% e.g. b = glmfit(X,y,'binomial')

