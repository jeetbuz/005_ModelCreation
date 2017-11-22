function [vehCoreInpList, vehCoreOutList, ioPortCount, dynMdlCount] = vehementCoreCreation_300(sysUnitConvCore,sysVehDynMdlSilver, unitCoreInpPortList, unitCoreOutPortList, fileNames, dateSuffix)
disp('### Loading the dynamic model library and create the list of dynamic models present');
[dynLibFileNameExt, ~] = uigetfile('*.mdl','Please select the simulink library containing the Dynamic Models for Vehement Core');
load_system(dynLibFileNameExt);
dynLibFileName = dynLibFileNameExt(1:end-4);
dynModelsPresent = find_system(dynLibFileName,'SearchDepth',1,'BlockType','SubSystem');
dynModelsAvlblList = {};

fid_VhmntDynMdlModifier = fopen(['VhmntDynMdlModifier_' dateSuffix '.txt'],'w+');

% Get the list of all available dynamic models
for i = 1:numel(dynModelsPresent)
    [~,remain] = strtok(strrep(dynModelsPresent{i,1},'/',' '));
    dynModelsAvlblList{i,1} = remain(5:end);
end
ioPortCount = 1;
dynMdlCount = 1;
dynModelsList = {}; temp = {};

for fileNum = 1:numel(fileNames)
    disp(['### Reading InputAnalysis sheet ... ' fileNames{fileNum}]);
    [~,~,inpData] = xlsread(fileNames{fileNum},'InputsAnalysis');
    sigName = {}; sigAgkName = {}; sigValue = {}; sigEnv = {};
    [r, c] = size(inpData);
    for i = 1:c
        if strcmpi(inpData{1,i}, 'GT_Vehement Name')
            sigName = inpData(2:end, i);
        elseif strcmpi(inpData{1,i}, 'Name')
            sigAgkName = inpData(2:end, i);
        elseif strcmpi(inpData{1,i}, 'Value')
            sigValue = inpData(2:end, i);
        elseif strcmpi(inpData{1,i}, 'Environment')
            sigEnv = inpData(2:end, i);
        else
            %
        end
    end
    %disp(sigEnv);
    for sigCount = 1:r-1
       if strcmpi(sigEnv{sigCount,1},'Vehement')
         %disp([sigAgkName{sigCount,1} ' ' sigEnv{sigCount,1}]);
         temp = [temp;sigName{sigCount,1}];
       end
    end
    %disp(temp);
end

dynModelsList = strtrim(unique(temp));
%disp(dynModelsList);
%disp(num2str(numel(dynModelsList)));
clear temp;
%% Place the dynamic models from the library into the simulink model 
for i = 1:numel(dynModelsList)
    if ismember(dynModelsList{i,1},dynModelsAvlblList)
        % Place the dynamic model
        dynMdlDmnsn = get_param([dynLibFileName '/DM_' dynModelsList{i,1}], 'Position');
        dynMdlWidth = dynMdlDmnsn(3) - dynMdlDmnsn(1);
        dynMdlHeight = dynMdlDmnsn(4) - dynMdlDmnsn(2);
        inpPortHandles = find_system([dynLibFileName '/DM_' dynModelsList{i,1}],'SearchDepth',1,'BlockType','Inport');
        outPortHandles = find_system([dynLibFileName '/DM_' dynModelsList{i,1}],'SearchDepth',1,'BlockType','Outport');
        inpPortList = cellfun(@(x) get_param(x, 'Name'), inpPortHandles,'UniformOutput',0);
        outPortList = cellfun(@(x) get_param(x, 'Name'), outPortHandles,'UniformOutput',0);
        dynMdlPos = [600 20+(dynMdlCount-1)*100 600+dynMdlWidth 20+(dynMdlCount-1)*100+dynMdlHeight];
        add_block([dynLibFileName '/DM_' dynModelsList{i,1}],[sysUnitConvCore '/DM_' dynModelsList{i,1}],'Position', dynMdlPos);
        % create a .mdl parallely for Silver integration
        add_block([dynLibFileName '/DM_' dynModelsList{i,1}],[sysVehDynMdlSilver '/DM_' dynModelsList{i,1}],'Position', dynMdlPos);
        inpPortInitPos = [dynMdlPos(1)-50 dynMdlPos(2)+10 dynMdlPos(1)-25 dynMdlPos(2)+20];
        for j = 1:numel(inpPortList)
            add_block('built-in/From',[sysUnitConvCore '/DynFrom_' dynModelsList{i,1} '_' inpPortList{j,1}], 'GotoTag',inpPortList{j,1}, 'ShowName', 'off', 'Position', inpPortInitPos + [0 (j-1)*20 0 (j-1)*20]);
            add_line(sysUnitConvCore,['DynFrom_' dynModelsList{i,1} '_' inpPortList{j,1} '/1'],['DM_' dynModelsList{i,1} '/' num2str(j)]);
            % create a .mdl parallely for Silver integration
            add_block('built-in/From',[sysVehDynMdlSilver '/DynFrom_' dynModelsList{i,1} '_' inpPortList{j,1}], 'GotoTag',inpPortList{j,1}, 'ShowName', 'off', 'Position', inpPortInitPos + [0 (j-1)*20 0 (j-1)*20]);
            add_line(sysVehDynMdlSilver,['DynFrom_' dynModelsList{i,1} '_' inpPortList{j,1} '/1'],['DM_' dynModelsList{i,1} '/' num2str(j)]);
        end
        outPortInitPos = [dynMdlPos(3)+30 dynMdlPos(2)+10 dynMdlPos(3)+50 dynMdlPos(2)+20];
        for j = 1:numel(outPortList)
            add_block('built-in/Goto',[sysUnitConvCore '/DynGoto_' dynModelsList{i,1} '_' outPortList{j,1}], 'GotoTag',outPortList{j,1}, 'ShowName', 'off', 'Position', outPortInitPos + [0 (j-1)*20 0 (j-1)*20]);
            add_line(sysUnitConvCore,['DM_' dynModelsList{i,1} '/' num2str(j)],['DynGoto_' dynModelsList{i,1} '_' outPortList{j,1} '/1']);
            % create a .mdl parallely for Silver integration
            add_block('built-in/Goto',[sysVehDynMdlSilver '/DynGoto_' dynModelsList{i,1} '_' outPortList{j,1}], 'GotoTag',outPortList{j,1}, 'ShowName', 'off', 'Position', outPortInitPos + [0 (j-1)*20 0 (j-1)*20]);
            add_line(sysVehDynMdlSilver,['DM_' dynModelsList{i,1} '/' num2str(j)],['DynGoto_' dynModelsList{i,1} '_' outPortList{j,1} '/1']);
        end
        dynMdlCount = dynMdlCount + 1;
    else
        % Place an IO port
        disp([dynModelsList{i,1} ' : Dynamic model missing']);
    end
end

% To add additional model signals required by dynamic models
fromBlkHandles = find_system(sysUnitConvCore,'SearchDepth',1,'BlockType','From');
fromBlkList = cellfun(@(x) get_param(x, 'GotoTag'), fromBlkHandles,'UniformOutput',0);
fromBlkNames = unique(fromBlkList);
extraSignalTemp = fromBlkNames(~ismember(fromBlkNames,dynModelsList));
extraInputs = extraSignalTemp(~ismember(extraSignalTemp,unitCoreOutPortList));

% extraInputs = extraInputs_1(~ismember(extraInputs_1, gotoBlkNames));
%% Get the list of additional inputs as a consequence of dynamic models.
for i = 1:numel(extraInputs)
    ioPortPos = [60 20+(ioPortCount-1)*30 80 40+(ioPortCount-1)*30];
    add_block('built-in/Inport',[sysUnitConvCore '/' extraInputs{i,1}], 'ShowName','on','Name',extraInputs{i,1},'Position',ioPortPos);
    add_block('built-in/Goto',[sysUnitConvCore '/Goto_' extraInputs{i,1}], 'GotoTag', extraInputs{i,1}, 'Position',ioPortPos + [100 0 100 0], 'ShowName','off');
    add_line(sysUnitConvCore,[extraInputs{i,1} '/1'], ['Goto_' extraInputs{i,1} '/1'], 'autorouting','on');
    ioPortCount = ioPortCount + 1;
end
ioPortCount = 1;
for i = 1:numel(extraSignalTemp)
    ioPortPos = [60 20+(ioPortCount-1)*30 80 40+(ioPortCount-1)*30];
    % create a .mdl parallely for Silver integration
    add_block('built-in/Inport',[sysVehDynMdlSilver '/' extraSignalTemp{i,1}], 'ShowName','on','Name',extraSignalTemp{i,1},'Position',ioPortPos);
    add_block('built-in/Goto',[sysVehDynMdlSilver '/Goto_' extraSignalTemp{i,1}], 'GotoTag', extraSignalTemp{i,1}, 'Position',ioPortPos + [100 0 100 0], 'ShowName','off');
    add_line(sysVehDynMdlSilver,[extraSignalTemp{i,1} '/1'], ['Goto_' extraSignalTemp{i,1} '/1'], 'autorouting','on');
    ioPortCount = ioPortCount + 1;
end
%%
disp('### Standalone Core Created...');
disp(['### ' num2str(ioPortCount) ' input ports and ' num2str(dynMdlCount) ' dynamic models added.']);
disp('### List of Standalone Dynamic Models not used:');
disp(dynModelsAvlblList(~ismember(dynModelsAvlblList,dynModelsList)));
%% added on 28 february
for i = 1:numel(unitCoreOutPortList)
   outPortPos = [2200 30+(i-1)*40 2220  50+(i-1)*40];
   add_block('built-in/From',[sysUnitConvCore '/From_'  unitCoreOutPortList{i,1}], 'GotoTag',  unitCoreOutPortList{i,1}, 'Position',outPortPos + [100 0 200 0], 'ShowName','off');
   add_block('built-in/Outport',[sysUnitConvCore '/' unitCoreOutPortList{i,1}], 'ShowName','on','Name',unitCoreOutPortList{i,1},'Position',outPortPos + [500 0 520 0]);
   add_line(sysUnitConvCore,['From_'  unitCoreOutPortList{i,1} '/1'],[unitCoreOutPortList{i,1} '/1'], 'autorouting','on'); 
end
%% Adding output ports for mdl created for Silver integration
gotoBlkHandles = find_system(sysVehDynMdlSilver,'SearchDepth',1,'BlockType','Goto');
gotoBlkList = cellfun(@(x) get_param(x, 'GotoTag'), gotoBlkHandles,'UniformOutput',0);
gotoBlkNames = unique(gotoBlkList);
for i = 1:numel(gotoBlkNames)
   outPortPos = [2200 30+(i-1)*40 2220  50+(i-1)*40];
   add_block('built-in/From',[sysVehDynMdlSilver '/From_'  gotoBlkNames{i,1}], 'GotoTag',  gotoBlkNames{i,1}, 'Position',outPortPos + [100 0 200 0], 'ShowName','off');
   add_block('built-in/Outport',[sysVehDynMdlSilver '/Vhmnt_' gotoBlkNames{i,1}], 'ShowName','on','Name',['Vhmnt_' gotoBlkNames{i,1}],'Position',outPortPos + [500 0 520 0]);
   add_line(sysVehDynMdlSilver,['From_'  gotoBlkNames{i,1} '/1'],['Vhmnt_' gotoBlkNames{i,1} '/1'], 'autorouting','on'); 
  
   fprintf(fid_VhmntDynMdlModifier, [gotoBlkNames{i,1} ' = Vhmnt_' gotoBlkNames{i,1} ';\n']);
end

inpPortHandles = find_system(sysUnitConvCore,'SearchDepth',1,'BlockType','Inport');
vehCoreInpList = cellfun(@(x) get_param(x, 'Name'), inpPortHandles,'UniformOutput',0);
outPortHandles = find_system(sysUnitConvCore,'SearchDepth',1,'BlockType','Outport');
vehCoreOutList = cellfun(@(x) get_param(x, 'Name'), outPortHandles,'UniformOutput',0);

fclose(fid_VhmntDynMdlModifier);