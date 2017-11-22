%% Code to create the complete framework model for co-simulation with GT
% Inputs: 1. Qtronic exported S-Function .mdl files
%         2. Inputs-Outputs analysis excel file for each S-Function
%         3. TM_DynamicModel_Library
%         4. UnitConverter_Library
%         5. Function: delete_unconnected_lines
% Outputs: Complete framework model
% Authors: Padmaji, Vinayak and Khasnabish, Neilay. RD I/CEP
% Date: 20.02.2017

%%  Start   
clear
clc;
clc;
disp(['Run started at:']); disp([datetime('now')]);
tstart = tic;
bdclose all;
dateVar = num2cell(clock);
dateSuffix = [num2str(dateVar{1}) num2str(dateVar{2}) num2str(dateVar{3}) '_' num2str(dateVar{4}) num2str(dateVar{5})];
diary(['BuildLog_' dateSuffix '.txt']);
disp(['### Date and Time: ' dateSuffix]);
disp('### 1. Clear screen, Workspace and close any open simulink models');
% Delete earlier created models
delete('CoreSubSys.mdl'); delete('DynCoreSubSys.mdl'); delete('UnitConvCoreSubSys.mdl');
delete('CoreSubSys.slx'); delete('DynCoreSubSys.slx'); delete('UnitConvCoreSubSys.slx');

%%  Select all the S-Function model files exported from Qtronic Silver
disp('### 2. Please select the preprocessed model files ending with _RestBus')
[modelNames, ~] =  uigetfile('*.mdl','MultiSelect','on','Select preprocessed Simulink model files');
if iscell(modelNames)
    numOfFiles = length(modelNames);
else
    numOfFiles = 1;
end

%%  Select the analysis sheets for the corresponding controller model files
disp('### 3. Select the analysis sheets for corresponding controller models');
fileNames={}; %stores the xlsx filenames and subsystem names for use later
for i = 1:numOfFiles
    if iscell(modelNames)
        modelName = modelNames{1,i};
    else
        modelName = modelNames;
    end
    open_system(modelName);
    display(['### For Model: ' modelName]);
    sFunction = find_system(modelName(1:end-4),'BlockType','SubSystem');
    display(['### Pick analysis sheet for: ' modelName]);
    [analysisFile, xcelFilePath] =  uigetfile('*.xlsx','MultiSelect','on',['Pick analysis sheet for: ' modelName]);
    addpath(xcelFilePath);
    fileNames{i}=analysisFile;
    close_system(modelName);
end

%%  Creating the Core model
disp('### 4. Copy the models into a single simulink model');
newMdlName='CoreSubSys';
creatingCoreSubsystem

%%  Making Core subsystem
sysDynCore='DynCoreSubSys';
make_CoreSubSys;

%% Creating the dynamic core
disp(['### 6. Create the dynamic core subsystem']);
sysDynMdlSilver = ['DynMdlSilver_' dateSuffix];
new_system(sysDynMdlSilver);
open_system(sysDynMdlSilver);

[dynCoreInpList, dynCoreOutList, ioPortCount, dynMdlCount] = dynCoreCreation(sysDynCore, sysDynMdlSilver, coreInpPortList, coreOutPortList, fileNames);

save_system(sysDynCore, [cd '\Results\' sysDynCore]);
save_system(sysDynMdlSilver, [cd '\Results\' sysDynMdlSilver]);

%% Make Dynamic Subsystem
sysUnitConvCore='UnitConvCoreSubSys';
make_DynSubSys;

%% Creating the Unit Conversion and nomenclature Core
% Read the excel files and analyse the signals. This is done to help in the
% creation of the unit conversion core.
disp('## 8. Create a structure for AGK and GT signals which will make easy the implementation of unit conversion core');
signalStructureCreator
InputSignalList = fieldnames(InputSignals);
OutputSignalList = fieldnames(OutputSignals);

% Create the contents of Unit Convertion and Nomenclature core
disp('### 9. Creating the Unit Conversion core subsystem')
[inpPortCountUnitCore, outPortCountUnitCore, unitCoreInpList, unitCoreOutList] = createUnitConvCore(dynCoreInpList, dynCoreOutList, dynCorePosInit, sysUnitConvCore, InputSignals, OutputSignals, dateSuffix); 

%% Make Unit Conversion subsystem
level3Subsys=['Model_L3_' num2str(dateVar{1}) num2str(dateVar{2}) num2str(dateVar{3}) '_' num2str(dateVar{4}) num2str(dateVar{5})];
make_UnitConvSubsys

%% Create Vehement Core
sysVehDynMdlSilver = ['VehDynMdlSilver_' dateSuffix];
new_system(sysVehDynMdlSilver);
open_system(sysVehDynMdlSilver);
[vehCoreInpList, vehCoreOutList, ioPortCountVehCore, dynMdlCount] = vehementCoreCreation(level3Subsys,sysVehDynMdlSilver, strtrim(unitCoreInpList), strtrim(unitCoreOutList), fileNames, dateSuffix);
save_system(sysVehDynMdlSilver);
%% Make Vehement Core Subsystem
make_GT_Standalone_SubSys
pause(5);
%%  THE END
disp('### 12. The onion model is ready')
diary OFF

%%
telapsed = toc(tstart);
disp(['Run completed at:']); disp([datetime('now')]);
disp(['taking: ' num2str(telapsed) ' seconds']);
