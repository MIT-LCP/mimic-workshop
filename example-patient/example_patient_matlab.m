
%% Load chartevents for the patient
% load the various files
fp = fopen('example-patient-chartevents.csv');
header_ce = fgetl(fp);

% convert header from a string to a cell array of strings
header_ce = regexp(header_ce,',','split');

frmt = '%f%f%f%s%f%q%q';
data_ce = textscan(fp,frmt,'delimiter',',');
fclose(fp);

% Let's extract the numeric data only into data_ce - and put string data into data_ce_str
idxNumeric = cellfun(@isnumeric, data_ce);
data_ce_str = [data_ce{~idxNumeric}];
header_ce_str = header_ce(~idxNumeric);
data_ce = [data_ce{idxNumeric}];
header_ce = header_ce(idxNumeric);

% here's a preview of the string data
header_ce_str
data_ce_str(1:5,:)

% here's a preview of the numeric data ('\t' is a tab)
fprintf('%8s\t',header_ce{:});
fprintf('\n')

frmt = '%8g\t%8.2f\t%8g\t%8.2f';
for n=1:5
    fprintf(frmt,data_ce(n,:));
    fprintf('\n');
end

%% Load the other events tables
% Time to load in the rest of the data!
% LAB DATA
frmt = '%f%f%f%s%f%q%q';

fp = fopen('example-patient-labevents.csv');
header_le = fgetl(fp);
header_le = regexp(header_le,',','split');
data_le = textscan(fp,frmt,'delimiter',',');
fclose(fp);
idxNumeric = cellfun(@isnumeric, data_le);
data_le_str = [data_le{~idxNumeric}];
header_le_str = header_le(~idxNumeric);
data_le = [data_le{idxNumeric}];
header_le = header_le(idxNumeric);

% INPUT DATA
frmt = '%f%f%f%f%f%q%f%q%f%q';

fp = fopen('example-patient-inputevents.csv');
header_ie = fgetl(fp);
header_ie = regexp(header_ie,',','split');
data_ie = textscan(fp,frmt,'delimiter',',');
fclose(fp);
idxNumeric = cellfun(@isnumeric, data_ie);
data_ie_str = [data_ie{~idxNumeric}];
header_ie_str = header_ie(~idxNumeric);
data_ie = [data_ie{idxNumeric}];
header_ie = header_ie(idxNumeric);


% OUTPUT DATA
frmt = '%f%f%f%f%q%q';

fp = fopen('example-patient-outputevents.csv');
header_oe = fgetl(fp);
header_oe = regexp(header_oe,',','split');
data_oe = textscan(fp,frmt,'delimiter',',');
fclose(fp);
idxNumeric = cellfun(@isnumeric, data_oe);
data_oe_str = [data_oe{~idxNumeric}];
header_oe_str = header_oe(~idxNumeric);
data_oe = [data_oe{idxNumeric}];
header_oe = header_oe(idxNumeric);

% PROCEDURE DATA
frmt = '%f%f%f%f%f%q%f%q';

fp = fopen('example-patient-procedureevents.csv');
header_pe = fgetl(fp);
header_pe = regexp(header_pe,',','split');
data_pe = textscan(fp,frmt,'delimiter',',');
fclose(fp);
idxNumeric = cellfun(@isnumeric, data_pe);
data_pe_str = [data_pe{~idxNumeric}];
header_pe_str = header_pe(~idxNumeric);
data_pe = [data_pe{idxNumeric}];
header_pe = header_pe(idxNumeric);

%% Initialize some plotting variables
% Some variables used to make pretty plots
col = [0.9047    0.1918    0.1988
    0.2941    0.5447    0.7494
    0.3718    0.7176    0.3612
    1.0000    0.5482    0.1000
    0.4550    0.4946    0.4722
    0.6859    0.4035    0.2412
    0.9718    0.5553    0.7741
    0.5313    0.3359    0.6523];
marker = {'d','+','o','x','>','s','<','+','^'};
ms = repmat(8,1,numel(marker));
savefigflag=0;
%% Plot the vital signs
figure(1); clf; hold all;
example_patient_matlab_ce;

%% Plot the labs
figure(1); clf; hold all;
example_patient_matlab_le;

%% add in IOEVENTS
figure(1); clf; hold all;
example_patient_matlab_ie;

%% putting it all together
figure(1); clf;

subplot(3,1,1); hold all;
example_patient_matlab_ce;
subplot(3,1,2); hold all;
example_patient_matlab_le;
subplot(3,1,3); hold all;
example_patient_matlab_ie;
P_PrettyFigure(1);

if savefigflag==1
export_fig(1,'exampledata10.png','-transparent');
end
