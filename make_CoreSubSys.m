%%  Making a sub-system and moving to Subsystem
disp(['### 5. Copying the created core subsystem contents to a new simulink Model']);

new_system(sysDynCore)
open_system(sysDynCore);
subSysPosInit = [1240 20 1670 numel(inputSigList)*10];
add_block('built-in/Subsystem', [sysDynCore '/CORE'], 'Position', subSysPosInit);
Simulink.BlockDiagram.copyContentsToSubSystem(newMdlName, [sysDynCore '/CORE']);
% Get position and IO list for the created subsystem
subSysPosActual = get_param([sysDynCore '/CORE'],'Position');
coreInpPortHandles = find_system([sysDynCore '/CORE'],'SearchDepth',1,'BlockType','Inport');
coreInpPortList = cellfun(@(x) get_param(x, 'Name'), coreInpPortHandles,'UniformOutput',0);
coreOutPortHandles = find_system([sysDynCore '/CORE'],'SearchDepth',1,'BlockType','Outport');
coreOutPortList = cellfun(@(x) get_param(x, 'Name'), coreOutPortHandles,'UniformOutput',0);
% add From blocks and connect them to the inputs of the subsystem
startPosFromBlks = [1100 380 1200 400];
disp('### Connecting "From" blocks  to the inputs of the CORE subsystem... ');
for i = 1:numel(coreInpPortList)
    add_block('built-in/From',[sysDynCore '/From_' coreInpPortList{i,1}], 'GotoTag', coreInpPortList{i,1}, 'ShowName', 'off', 'Position', startPosFromBlks + [0 (i-1)*10 0 (i-1)*10]);
    add_line(sysDynCore,['From_' coreInpPortList{i,1} '/1'], ['CORE/' num2str(i)], 'autorouting', 'on');
end
% add Outport blocks and connect the outputs of the subsystem to them
disp('### Connecting "Outport" blocks to the inputs of the CORE subsystem... ');
startPosOutBlks = [subSysPosActual(3)+200 subSysPosActual(2)+50 subSysPosActual(3)+300 subSysPosActual(2)+70];
for i = 1:numel(coreOutPortList)
    add_block('built-in/Goto',[sysDynCore '/Goto_' coreOutPortList{i,1}], 'GotoTag', coreOutPortList{i,1}, 'ShowName', 'off', 'Position', startPosOutBlks + [0 (i-1)*40 0 (i-1)*40]);
    add_line(sysDynCore,['CORE/' num2str(i)],['Goto_' coreOutPortList{i,1} '/1'], 'autorouting', 'on');
end

save_system(newMdlName, [cd '\Results\' newMdlName]);
close_system(newMdlName);
save_system(sysDynCore, [cd '\Results\' sysDynCore]);