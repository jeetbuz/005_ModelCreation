%% Copying the contents into a new subsystem
disp('###7. Move the created dynamic core subsystem to a new simulink model')
%open_system(hNewFile);
sysUnitConvCore='UnitConvCoreSubSys';
%open_system(hNewFile);
new_system(sysUnitConvCore)
open_system(sysUnitConvCore);
dynCorePosInit = [1240 25 1670 (ioPortCount+1)*10];
add_block('built-in/Subsystem', [sysUnitConvCore '/DynamicCore']);
Simulink.BlockDiagram.copyContentsToSubSystem(sysDynCore, [sysUnitConvCore '/DynamicCore']);
set_param([sysUnitConvCore '/DynamicCore'], 'Position', dynCorePosInit);
close_system(sysDynCore);
% add Outport blocks and connect the outputs of the subsystem to them
disp('### Adding Goto blocks to the output of the Dynamic Core subsystem');
startPosOutGotoBlks = [dynCorePosInit(3)+200 dynCorePosInit(2)+50 dynCorePosInit(3)+220 dynCorePosInit(2)+70];
for i = 1:numel(dynCoreOutList)
    add_block('built-in/Goto',[sysUnitConvCore '/Goto_' dynCoreOutList{i,1}], 'GotoTag', dynCoreOutList{i,1}, 'ShowName', 'on', 'Position', startPosOutGotoBlks + [0 (i-1)*40 0 (i-1)*40]);
    add_line(sysUnitConvCore,['DynamicCore/' num2str(i)],['Goto_' dynCoreOutList{i,1} '/1'], 'autorouting', 'on');
end
%save_system(sysUnitConvCore, [cd '\Results\' sysUnitConvCore]);