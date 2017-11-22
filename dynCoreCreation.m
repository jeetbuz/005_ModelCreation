function [dynCoreInpList, dynCoreOutList, ioPortCount, dynMdlCount] = dynCoreCreation_300(sysDynCore, sysDynMdlSilver, coreInpPortList, coreOutPortList, fileNames)
disp(['### 6.1 Now executing dynCoreCreation_v2']);
disp('### Loading the dynamic model library and create the list of dynamic models present');
[dynLibFileNameExt, ~] = uigetfile('*.mdl','Please select the simulink library containing the Dynamic Models');
load_system(dynLibFileNameExt);
dynLibFileName = dynLibFileNameExt(1:end-4);
dynModelsPresent = find_system(dynLibFileName,'SearchDepth',1,'BlockType','SubSystem');
dynModelsAvlblList = {};
%% Get the list of all available dynamic models
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
    sigName = {}; sigType = {}; sigValue = {};
    [r, c] = size(inpData);
    for i = 1:c
        if strcmp(inpData{1,i}, 'Name')
            sigName = inpData(2:end, i);
        elseif strcmp(inpData{1,i}, 'Type')
            sigType = inpData(2:end, i);
        elseif strcmp(inpData{1,i}, 'Value')
            sigValue = inpData(2:end, i);
        else
            %
        end
    end
    for sigCount = 1:r-1
       if strcmp(strtrim(sigType{sigCount,1}),'Dynamic') || strcmp(strtrim(sigType{sigCount,1}),'DynConst')
         temp = [temp;sigName{sigCount,1}];
       end
    end
end
dynModelsList = unique(temp);
disp(['### List of dynamic models required obtained from the analysis sheets']);
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
        add_block([dynLibFileName '/DM_' dynModelsList{i,1}],[sysDynCore '/DM_' dynModelsList{i,1}],'Position', dynMdlPos);
        % create a .mdl parallely for Silver integration
        add_block([dynLibFileName '/DM_' dynModelsList{i,1}],[sysDynMdlSilver '/DM_' dynModelsList{i,1}],'Position', dynMdlPos);
        inpPortInitPos = [dynMdlPos(1)-50 dynMdlPos(2)+10 dynMdlPos(1)-25 dynMdlPos(2)+20];
        for j = 1:numel(inpPortList)
            add_block('built-in/From',[sysDynCore '/DynFrom_' dynModelsList{i,1} '_' inpPortList{j,1}], 'GotoTag',inpPortList{j,1}, 'ShowName', 'off', 'Position', inpPortInitPos + [0 (j-1)*20 0 (j-1)*20]);
            add_line(sysDynCore,['DynFrom_' dynModelsList{i,1} '_' inpPortList{j,1} '/1'],['DM_' dynModelsList{i,1} '/' num2str(j)]);
            % create a .mdl parallely for Silver integration
            add_block('built-in/From',[sysDynMdlSilver '/DynFrom_' dynModelsList{i,1} '_' inpPortList{j,1}], 'GotoTag',inpPortList{j,1}, 'ShowName', 'off', 'Position', inpPortInitPos + [0 (j-1)*20 0 (j-1)*20]);
            add_line(sysDynMdlSilver,['DynFrom_' dynModelsList{i,1} '_' inpPortList{j,1} '/1'],['DM_' dynModelsList{i,1} '/' num2str(j)]);
        end
        outPortInitPos = [dynMdlPos(3)+30 dynMdlPos(2)+10 dynMdlPos(3)+50 dynMdlPos(2)+20];
        for j = 1:numel(outPortList)
            add_block('built-in/Goto',[sysDynCore '/DynGoto_' dynModelsList{i,1} '_' outPortList{j,1}], 'GotoTag',outPortList{j,1}, 'ShowName', 'off', 'Position', outPortInitPos + [0 (j-1)*20 0 (j-1)*20]);
            add_line(sysDynCore,['DM_' dynModelsList{i,1} '/' num2str(j)],['DynGoto_' dynModelsList{i,1} '_' outPortList{j,1} '/1']);
            % create a .mdl parallely for Silver integration
            add_block('built-in/Goto',[sysDynMdlSilver '/DynGoto_' dynModelsList{i,1} '_' outPortList{j,1}], 'GotoTag',outPortList{j,1}, 'ShowName', 'off', 'Position', outPortInitPos + [0 (j-1)*20 0 (j-1)*20]);
            add_line(sysDynMdlSilver,['DM_' dynModelsList{i,1} '/' num2str(j)],['DynGoto_' dynModelsList{i,1} '_' outPortList{j,1} '/1']);
        end
        dynMdlCount = dynMdlCount + 1;
    else
        % Place an IO port
        disp(['### ' dynModelsList{i,1} ' : Dynamic model missing']);
%         ioPortPos = [60 20+(ioPortCount-1)*30 80 40+(ioPortCount-1)*30];
%         add_block('built-in/Inport',[sysDynCore '/' coreInpPortList{i,1}], 'ShowName','on','Name',coreInpPortList{i,1},'Position',ioPortPos);
%         add_block('built-in/Goto',[sysDynCore '/Goto_' coreInpPortList{i,1}], 'GotoTag', coreInpPortList{i,1}, 'Position',ioPortPos + [100 0 100 0], 'ShowName','off');
%         add_line(sysDynCore,[coreInpPortList{i,1} '/1'], ['Goto_' coreInpPortList{i,1} '/1'], 'autorouting','on');
%         ioPortCount = ioPortCount + 1;
    end
end

% To add additional model signals required by dynamic models
% total from blocks = from blocks of core subsys + from blocks for each
% dynModel
fromBlkHandles = find_system(sysDynCore,'SearchDepth',1,'BlockType','From');
fromBlkList = cellfun(@(x) get_param(x, 'GotoTag'), fromBlkHandles,'UniformOutput',0);
fromBlkNames = unique(fromBlkList);
% Exclude the dynamic signals calculated from the input list for dynamic
% core
frmBlksWODynSgnls = fromBlkNames(~ismember(fromBlkNames,dynModelsList));
% Also exclude the signals being routed back; for actuator feedback dynamic
% models. we route these signals back here itself, instead of going out to
% GT and coming back
frmBlksWODynSgnlsWOactrFdbkSgnls = frmBlksWODynSgnls(~ismember(frmBlksWODynSgnls,coreOutPortList));

% extraInputs = extraInputs_1(~ismember(extraInputs_1, gotoBlkNames));
%% Get the list of additional inputs as a consequence of dynamic models.
for i = 1:numel(frmBlksWODynSgnlsWOactrFdbkSgnls)
    ioPortPos = [60 20+(ioPortCount-1)*30 80 40+(ioPortCount-1)*30];
    add_block('built-in/Inport',[sysDynCore '/' frmBlksWODynSgnlsWOactrFdbkSgnls{i,1}], 'ShowName','on','Name',frmBlksWODynSgnlsWOactrFdbkSgnls{i,1},'Position',ioPortPos);
    add_block('built-in/Goto',[sysDynCore '/Goto_' frmBlksWODynSgnlsWOactrFdbkSgnls{i,1}], 'GotoTag', frmBlksWODynSgnlsWOactrFdbkSgnls{i,1}, 'Position',ioPortPos + [100 0 100 0], 'ShowName','off');
    add_line(sysDynCore,[frmBlksWODynSgnlsWOactrFdbkSgnls{i,1} '/1'], ['Goto_' frmBlksWODynSgnlsWOactrFdbkSgnls{i,1} '/1'], 'autorouting','on');
    ioPortCount = ioPortCount + 1;
end
ioPortCount = 1;
% In silver the actuator feedback signals will be coming out of the DLL and
% will not be a part of the dynamic model being generated. therefore they
% have to be included in the list of inputs
for i = 1:numel(frmBlksWODynSgnls)
        % create a .mdl parallely for Silver integration
    ioPortPos = [60 20+(ioPortCount-1)*30 80 40+(ioPortCount-1)*30];
    add_block('built-in/Inport',[sysDynMdlSilver '/' frmBlksWODynSgnls{i,1}], 'ShowName','on','Name',frmBlksWODynSgnls{i,1},'Position',ioPortPos);
    add_block('built-in/Goto',[sysDynMdlSilver '/Goto_' frmBlksWODynSgnls{i,1}], 'GotoTag', frmBlksWODynSgnls{i,1}, 'Position',ioPortPos + [100 0 100 0], 'ShowName','off');
    add_line(sysDynMdlSilver,[frmBlksWODynSgnls{i,1} '/1'], ['Goto_' frmBlksWODynSgnls{i,1} '/1'], 'autorouting','on');
    ioPortCount = ioPortCount + 1;
end

%%
disp('### Dynamic Core Created...');
disp(['### ' num2str(ioPortCount) ' input ports and ' num2str(dynMdlCount) ' dynamic models added.']);
disp('### List of Dynamic Models not used:');
disp(dynModelsAvlblList(~ismember(dynModelsAvlblList,dynModelsList)));
%% added on 28 february
for i = 1:numel(coreOutPortList)
   outPortPos = [2200 30+(i-1)*40 2220  50+(i-1)*40];
   add_block('built-in/From',[sysDynCore '/From_'  coreOutPortList{i,1}], 'GotoTag',  coreOutPortList{i,1}, 'Position',outPortPos + [100 0 200 0], 'ShowName','off');
   add_block('built-in/Outport',[sysDynCore '/' coreOutPortList{i,1}], 'ShowName','on','Name',coreOutPortList{i,1},'Position',outPortPos + [500 0 520 0]);
   add_line(sysDynCore,['From_'  coreOutPortList{i,1} '/1'],[coreOutPortList{i,1} '/1'], 'autorouting','on'); 
end

%% Adding output ports for mdl created for Silver integration
gotoBlkHandles = find_system(sysDynMdlSilver,'SearchDepth',1,'BlockType','Goto');
gotoBlkList = cellfun(@(x) get_param(x, 'GotoTag'), gotoBlkHandles,'UniformOutput',0);
gotoBlkNames = unique(gotoBlkList);
for i = 1:numel(gotoBlkNames)
   outPortPos = [2200 30+(i-1)*40 2220  50+(i-1)*40];
   add_block('built-in/From',[sysDynMdlSilver '/From_'  gotoBlkNames{i,1}], 'GotoTag',  gotoBlkNames{i,1}, 'Position',outPortPos + [100 0 200 0], 'ShowName','off');
   add_block('built-in/Outport',[sysDynMdlSilver '/Dyn_' gotoBlkNames{i,1}], 'ShowName','on','Name',['Dyn_' gotoBlkNames{i,1}],'Position',outPortPos + [500 0 520 0]);
   add_line(sysDynMdlSilver,['From_'  gotoBlkNames{i,1} '/1'],['Dyn_' gotoBlkNames{i,1} '/1'], 'autorouting','on'); 
end

inpPortHandles = find_system(sysDynCore,'SearchDepth',1,'BlockType','Inport');
dynCoreInpList = cellfun(@(x) get_param(x, 'Name'), inpPortHandles,'UniformOutput',0);
outPortHandles = find_system(sysDynCore,'SearchDepth',1,'BlockType','Outport');
dynCoreOutList = cellfun(@(x) get_param(x, 'Name'), outPortHandles,'UniformOutput',0);