function [inpPortCountUnitCore, outPortCountUnitCore, unitCoreInpList, unitCoreOutList] = createUnitConvCore_300(dynCoreInpList, dynCoreOutList, dynCorePosInit, sysUnitConvCore, InputSignals, OutputSignals, dateSuffix)
disp('### NOW EXECUTING "createUnitConvCore.m"');
load_system unitConverter_Lib;
% add From blocks and connect them to the inputs of the subsystem
GTInpList = {};
fid_inputUnitConversion = fopen(['inputUnitConversion_modifier_' dateSuffix '.txt'],'w+');
startPosFromBlks = [dynCorePosInit(1) - 200 dynCorePosInit(2) dynCorePosInit(1) - 150 dynCorePosInit(2) + 20];
unitConvBlkCount = 1;
%% Get the available conversions
unitConvBlkHndl = find_system('unitConverter_Lib','SearchDepth',1,'BlockType','SubSystem');
unitConvBlkParam = get_param(unitConvBlkHndl,'DialogParameters');
avlblConvrsns =  unitConvBlkParam{1,1}.Selection.Enum';
for inpPortCountUnitCore = 1:numel(dynCoreInpList)
    % the dynamic core inputs has AGK names
    agkName = dynCoreInpList{inpPortCountUnitCore,1};
    % By using the structure created using signalStructureCreator we get
    % the corresponding GT name
    eval(['GTName = InputSignals.', agkName, '.GTName;']);
    if isempty(GTName)
        GTName = [agkName];
    end
    % Multiple AGK signals are mapped to a single GT signal. We want to add
    % only one inport and unit conversion for every GT. So we create a list
    % as we add unit conversion blocks and skip a GT signal is it has
    % already been placed.
    if ~ismember(GTName, GTInpList)
        GTInpList = [GTInpList; GTName];
        eval(['Unit1 = InputSignals.', agkName, '.GTUnit;']);
        eval(['Unit2 = InputSignals.', agkName, '.Unit;']);
        %display(['Unit1: ' Unit1 '. Unit2: ' Unit2]);
        if strcmpi(strtrim(Unit1), strtrim(Unit2))
            reqdConversion = 'NoConversionReqd';
        elseif isempty(Unit1) || isempty(Unit2)
            reqdConversion = 'Others';
        elseif ~ismember(strcat(Unit1,'_to_',Unit2), avlblConvrsns)
            disp(['For ' GTName]);
            disp([strcat(Unit1,'_to_',Unit2) ' conversion not present in the library']);
            disp(['Setting the conversion to Others']);
            reqdConversion = 'Others';
        else
            reqdConversion = strcat(Unit1,'_to_',Unit2);
        end
        
%         if ~ismember(strcat(Unit1,'_to_',Unit2), avlblConvrsns)
%             disp(['For ' GTName]);
%             disp([strcat(Unit1,'_to_',Unit2) ' conversion not present in the library']);
%             disp(['Setting the conversion to Others']);
%             reqdConversion = 'Others';
%         end
        %disp(reqdConversion);
        inpPortPos = [130 30+(unitConvBlkCount-1)*40 150 50+(unitConvBlkCount-1)*40];
        add_block('built-in/Inport',[sysUnitConvCore '/' GTName], 'ShowName','on','Name',GTName,'Position',inpPortPos);
        add_block('unitConverter_Lib/UnitConversion',[sysUnitConvCore '/Conv_' GTName], 'Selection', reqdConversion, 'Position',inpPortPos + [100 -10 300 10], 'ShowName','off');
        
        % Create modifier file for unit conversion
        [modif_offset, modif_gain] = unitConversion(reqdConversion, agkName, GTName);
        fprintf(fid_inputUnitConversion, [agkName '=' num2str(modif_gain) ' * ' GTName ' + ' num2str(modif_offset) ';\n']);
        
        add_line(sysUnitConvCore,[GTName '/1'], ['Conv_' GTName '/1'], 'autorouting','on');
        add_block('built-in/Goto',[sysUnitConvCore '/Goto_' GTName], 'GotoTag', GTName, 'Position',inpPortPos + [400 0 450 0], 'ShowName','off');
        add_line(sysUnitConvCore,['Conv_' GTName '/1'],['Goto_' GTName '/1'], 'autorouting','on');
        unitConvBlkCount = unitConvBlkCount + 1;
    % the else condition below was added only to assist in creating the
    % modifier file for silver integration. We have to create separate unit
    % conversion entry for each AGK signal irrespective of whether the GT
    % signal was already used or not
    else
        eval(['Unit1 = InputSignals.', agkName, '.GTUnit;']);
        eval(['Unit2 = InputSignals.', agkName, '.Unit;']);
        %display(['Unit1: ' Unit1 '. Unit2: ' Unit2]);
        if strcmpi(strtrim(Unit1), strtrim(Unit2));
            reqdConversion = 'NoConversionReqd';
        elseif isempty(Unit1) || isempty(Unit2)
            reqdConversion = 'Others';
        else
            reqdConversion = strcat(Unit1,'_to_',Unit2);
        end
        % Create modifier file for unit conversion
        [modif_offset, modif_gain] = unitConversion(reqdConversion, agkName, GTName);
        fprintf(fid_inputUnitConversion, [agkName '=' num2str(modif_gain) ' * ' GTName ' + ' num2str(modif_offset) ';\n']);
    end
    %disp('Connecting "From" blocks  to the inputs of the CORE subsystem... ');
    add_block('built-in/From',[sysUnitConvCore '/From_' dynCoreInpList{inpPortCountUnitCore,1}], 'GotoTag', GTName, 'ShowName', 'off', 'Position', startPosFromBlks + [0 (inpPortCountUnitCore-1)*10 0 (inpPortCountUnitCore-1)*10]);
    add_line(sysUnitConvCore,['From_' dynCoreInpList{inpPortCountUnitCore,1} '/1'], ['DynamicCore/' num2str(inpPortCountUnitCore)], 'autorouting', 'on');
end
fclose(fid_inputUnitConversion);

%%
GTOutList = {};
fid_outputUnitConversion = fopen(['outputUnitConversion_modifier_' dateSuffix '.txt'],'w+');
for outPortCountUnitCore = 1:numel(dynCoreOutList)
    agkName = dynCoreOutList{outPortCountUnitCore,1};
    eval(['GTName = OutputSignals.out_', agkName, '.GTName;']);
    if isempty(GTName)
        GTName = [agkName];
    end
    if ~ismember(GTName, GTOutList)
        GTOutList = [GTOutList; GTName];
        eval(['Unit1 = OutputSignals.out_', agkName, '.Unit;']);
        eval(['Unit2 = OutputSignals.out_', agkName, '.GTUnit;']);
        %display(['Unit1: ' Unit1 '. Unit2: ' Unit2]);
        if strcmpi(strtrim(Unit1), strtrim(Unit2));
            reqdConversion = 'NoConversionReqd';
        elseif isempty(Unit1) || isempty(Unit2)
            reqdConversion = 'Others';
        else
            reqdConversion = strcat(Unit1,'_to_',Unit2);
        end
        %disp(reqdConversion);
        outPortPos = [dynCorePosInit(3)+600 30+(outPortCountUnitCore-1)*40 dynCorePosInit(3)+620  50+(outPortCountUnitCore-1)*40];
        add_block('built-in/From',[sysUnitConvCore '/From_' agkName], 'GotoTag', agkName, 'Position',outPortPos + [100 0 200 0], 'ShowName','off');
        add_block('unitConverter_Lib/UnitConversion',[sysUnitConvCore '/Conv_' GTName], 'Selection', reqdConversion, 'Position',outPortPos + [300 -10 400 10], 'ShowName','off');
        
        % Create modifier file for unit conversion
        [modif_offset, modif_gain] = unitConversion(reqdConversion, agkName, GTName);
        fprintf(fid_outputUnitConversion, [GTName '=' num2str(modif_gain) ' * ' agkName ' + ' num2str(modif_offset) ';\n']);
        
        add_line(sysUnitConvCore,['From_' agkName '/1'], ['Conv_' GTName '/1'], 'autorouting','on');
        add_block('built-in/Outport',[sysUnitConvCore '/' GTName], 'ShowName','on','Name',GTName,'Position',outPortPos + [500 0 520 0]);
        add_line(sysUnitConvCore,['Conv_' GTName '/1'],[GTName '/1'], 'autorouting','on');
    end
end
close_system unitConverter_Lib;
fclose(fid_outputUnitConversion);
%%
inpPortHandles = find_system(sysUnitConvCore,'SearchDepth',1,'BlockType','Inport');
unitCoreInpList = cellfun(@(x) get_param(x, 'Name'), inpPortHandles,'UniformOutput',0);
outPortHandles = find_system(sysUnitConvCore,'SearchDepth',1,'BlockType','Outport');
unitCoreOutList = cellfun(@(x) get_param(x, 'Name'), outPortHandles,'UniformOutput',0);