Instructions file for using the model creation scripts.
This implementation uses functions in versions of  MATLAB more than 2011B. 
I have checked the excecution of this code with R2016B and all is fine.
If you require it for running in R2011B, or face any problems, please contact me.

Padmaji, Vinayak (padmaji.vinayak@daimler.com)
RD I/ CEP, MBRDI


% Inputs: 1. Qtronic exported S-Function .mdl files
%         2. Inputs-Outputs analysis excel file for each S-Function
%         3. TM_DynamicModel_Library
%         4. UnitConverter_Library
%         5. Function: delete_unconnected_lines
%		  6. AGK-GT Nomenclature-unit mapping excel Sheet

% Outputs:1. Complete framework model for GT(L4_***.mdl) and Vehement(L3_***.mdl) integration
%		  2. Modifier files for Silver Integration
%		  3. Build Log

Steps to run:
1. Execute the file "modelCreation_main.m"
2. Select the pre-processed _stubbed model files and corresponding analysis sheets
3. After the core subsytem is created, will be asked to provide Dynamic model library. Select the file "TM_DynamicModel_Library.mdl"
4. Will be asked to select AGK-GT mapping excel file. It is required to create the unit-conversion and mapping subsystem
5. Next, select the library "TM_Standalone_Library.mdl". This has the dynamic models for signals expected from vehement.
6. That is all.
7. Created models can be found in the "Results" folder.
