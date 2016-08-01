% Tell Matlab where the driver is
javaclasspath('postgresql-9.4.1207.jar') % note we are using a postgres driver


%% Initiate our database connection with Amazon
username = '';
password = '';

% Connect to the Database
conn = database('mimic',username,password,...
    'Vendor','PostgreSQL',...
    'Server','localhost',...
    'PortNumber',5432);


%% create and run a query
query = 'select * from patients limit 10';
data = fetch(conn,query);

%% close the connection
close(conn);