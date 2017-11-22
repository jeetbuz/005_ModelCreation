disp('### 11. Creating the Vehement core subsystem and moving it to a new model ...')
%open_system(hNewFile);
dateVar = num2cell(clock);
level4Subsys=['Model_L4_' num2str(dateVar{1}) num2str(dateVar{2}) num2str(dateVar{3}) '_' num2str(dateVar{4}) num2str(dateVar{5})];
%open_system(hNewFile);
new_system(level4Subsys)
open_system(level4Subsys);
vehConvCorePosInit = [1240 25 1670 (ioPortCountVehCore+1)*15];
add_block('built-in/Subsystem', [level4Subsys '/GT_StandaloneCore']);
Simulink.BlockDiagram.copyContentsToSubSystem(level3Subsys, [level4Subsys '/GT_StandaloneCore']);
set_param([level4Subsys '/GT_StandaloneCore'], 'Position', vehConvCorePosInit);
save_system(level4Subsys, [cd '\Results\' level4Subsys]);
save_system(level3Subsys, [cd '\Results\' level3Subsys]);
close_system(level3Subsys);
%close_system(sysTopLevelCore);