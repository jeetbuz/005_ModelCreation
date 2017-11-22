disp('### 10. Moving Unit Conversion core subsystem to a new model ...')
%open_system(hNewFile);
dateVar = num2cell(clock);
%level3Subsys=['Model_L3_' num2str(dateVar{1}) num2str(dateVar{2}) num2str(dateVar{3}) '_' num2str(dateVar{4}) num2str(dateVar{5})];
%open_system(hNewFile);
new_system(level3Subsys)
open_system(level3Subsys);
unitConvCorePosInit = [1240 25 1670 (inpPortCountUnitCore+1)*10];
add_block('built-in/Subsystem', [level3Subsys '/UnitConvCore']);
Simulink.BlockDiagram.copyContentsToSubSystem(sysUnitConvCore, [level3Subsys '/UnitConvCore']);
set_param([level3Subsys '/UnitConvCore'], 'Position', unitConvCorePosInit);

%close_system(sysTopLevelCore);
save_system(sysUnitConvCore, [cd '\Results\' sysUnitConvCore]);
close_system(sysUnitConvCore);

unitConvCorePosActual = get_param([level3Subsys '/UnitConvCore'],'Position');
unitConvCoreInpPortHandles = find_system([level3Subsys '/UnitConvCore'],'SearchDepth',1,'BlockType','Inport');
unitConvCoreInpPortList = cellfun(@(x) get_param(x, 'Name'), unitConvCoreInpPortHandles,'UniformOutput',0);
unitConvCoreOutPortHandles = find_system([level3Subsys '/UnitConvCore'],'SearchDepth',1,'BlockType','Outport');
unitConvCoreOutPortList = cellfun(@(x) get_param(x, 'Name'), unitConvCoreOutPortHandles,'UniformOutput',0);
% add From blocks and connect them to the inputs of the subsystem
startPosFromBlks = [unitConvCorePosActual(1)-200 unitConvCorePosActual(2)+50 unitConvCorePosActual(1)-180 unitConvCorePosActual(2)+70];
disp('### Connecting "From" blocks  to the inputs of the UnitConvCore subsystem... ');
for i = 1:numel(unitConvCoreInpPortList)
    add_block('built-in/From',[level3Subsys '/From_' unitConvCoreInpPortList{i,1}], 'GotoTag', unitConvCoreInpPortList{i,1}, 'ShowName', 'off', 'Position', startPosFromBlks + [0 (i-1)*10 0 (i-1)*10]);
    add_line(level3Subsys,['From_' unitConvCoreInpPortList{i,1} '/1'], ['UnitConvCore/' num2str(i)], 'autorouting', 'on');
end
% add Outport blocks and connect the outputs of the subsystem to them
disp('### Connecting "Goto" blocks to the outputs of the UnitConvCore subsystem... ');
startPosOutBlks = [unitConvCorePosActual(3)+200 unitConvCorePosActual(2)+50 unitConvCorePosActual(3)+300 unitConvCorePosActual(2)+70];
for i = 1:numel(unitConvCoreOutPortList)
    add_block('built-in/Goto',[level3Subsys '/Goto_' unitConvCoreOutPortList{i,1}], 'GotoTag', unitConvCoreOutPortList{i,1}, 'ShowName', 'off', 'Position', startPosOutBlks + [0 (i-1)*40 0 (i-1)*40]);
    add_line(level3Subsys,['UnitConvCore/' num2str(i)],['Goto_' unitConvCoreOutPortList{i,1} '/1'], 'autorouting', 'on');
end
save_system(level3Subsys, [cd '\Results\' level3Subsys]);
%close_system(level3Subsys);