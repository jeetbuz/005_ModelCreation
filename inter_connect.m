%%
% Author: Khasnabish, Neilay RD I/CEP
%%
function [inputInterconnectList, inputInterconnectSigList]=inter_connect_300(newMdlName, subSysNames, fileNames, dateSuffix)

%% Reading SFunction blocks
%sFunctions = find_system(newMdlName,'BlockType','SubSystem');
%To sort FB inputs

intrcnnct_src = {};
intrcnnct_dst = {};
inportBlocks = {};

outportBlocks = {};
fid_intrcnnctModifier = fopen(['intrcnnct_Modifier_' dateSuffix '.txt'], 'w+');

for fileNum = 1:length(fileNames)
    excelFile = fileNames{1,fileNum};
    disp(['### Read the excel file to extract data about interconnections: ' excelFile]);
    [~,~,inpData] = xlsread(excelFile,'InputsAnalysis');
    sigName = {}; sigType = {}; sigValue = {};
    [~, c] = size(inpData);
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
    count = 1;
    disp('### Create source and destination ports. Also create modifier simultaneously');
    for sigNum = 1:length(sigName)
        if strcmp(sigType{sigNum},'CPC')
            intrcnnct_src{count, fileNum} = sigValue{sigNum,1};
            intrcnnct_dst{count, fileNum} = sigName{sigNum,1};
            fprintf(fid_intrcnnctModifier,[['ECM_' sigName{sigNum,1}] ' = ' ['CPC_' sigValue{sigNum,1}] ';\n']);
            count = count + 1;
        elseif strcmp(sigType{sigNum},'MSG')
            intrcnnct_src{count, fileNum} = sigValue{sigNum,1};
            intrcnnct_dst{count, fileNum} = sigName{sigNum,1};
            fprintf(fid_intrcnnctModifier,[['CPC_' sigName{sigNum,1}] ' = ' ['ECM_' sigValue{sigNum,1}] ';\n']);
            count = count + 1;
        end
    end
    numOfIntrcnnct(fileNum, 1) = count-1;
    inpPortHandles = {}; inpPortList = {};
    disp(['### Get the list of inputs and outputs for the subsystem: ' subSysNames{fileNum,1}]);
    inpPortHandles = find_system([newMdlName '/' subSysNames{fileNum,1}],'SearchDepth',1, 'BlockType', 'Inport');
    inpPortList = cellfun(@(x) get_param(x, 'Name'), inpPortHandles,'UniformOutput',0);
    numOfInputs(fileNum,1) = length(inpPortList);
    inportBlocks(1:numOfInputs(fileNum,1),fileNum) = inpPortList;
    outPortHandles = find_system([newMdlName '/' subSysNames{fileNum,1}],'SearchDepth',1, 'BlockType', 'Outport');
    outPortList = cellfun(@(x) get_param(x, 'Name'), outPortHandles,'UniformOutput',0);
    numOfOutputs(fileNum,1) = length(outPortList);
    outportBlocks(1:numOfOutputs(fileNum,1), fileNum) = outPortList;
end
fclose(fid_intrcnnctModifier);
%%
%Matching outputs and inputs
disp('### Connecting the source and destination ports');
clear srcList dstList count
[r_src, c_src] = size(intrcnnct_src);
[r_dst, c_dst] = size(intrcnnct_dst);
for sysSrc = 1:length(subSysNames) %For output
    % Create source ports list
    srcList = {};
    dstList = {};
    count = 1;
    for sysDst = 1:length(subSysNames)
        tempInList = {};
        tempOutList = {};
        if sysSrc ~= sysDst
            for l = 1:r_src
                if ~isempty(intrcnnct_src(l,sysSrc))
                    %disp(['                 Select source port list']);
                    srcList{count,1} = intrcnnct_src{l,sysDst};
                    % Create destination ports list
                    %disp(['                 Select destination port list']);
                    dstList{count,1} = intrcnnct_dst{l,sysDst};
                    count = count+1;
                end
            end
            clear temp
            tempInList = inportBlocks(1:numOfInputs(sysDst), sysDst);
            tempOutList = outportBlocks(1:numOfOutputs(sysSrc),sysSrc);
            for sigNum = 1:numOfIntrcnnct(sysDst, 1)
                %disp(['Destination Signal: ' dstList{sigNum,1}]);
                temp = ismember(tempInList, dstList{sigNum,1});
                dstIndx(sigNum,1) = find(temp);
                %disp(['                 find the port number for destination port']);
                clear temp
                
               % disp(['Source Signal: ' srcList{sigNum,1}]);
                temp = ismember(tempOutList, srcList{sigNum,1});
                srcIndx(sigNum,1) = find(temp);
                %disp(['                 find the port number of source port']);
                add_line(newMdlName, [subSysNames{sysSrc,1} '/' num2str(srcIndx(sigNum,1))], [subSysNames{sysDst,1} '/' num2str(dstIndx(sigNum,1))]);%, 'autorouting', 'on');
                %disp(['### connected port ' num2str(srcIndx(sigNum,1)) ' of ' subSysNames{sysSrc,1} ' to port ' num2str(dstIndx(sigNum,1)) ' of ' subSysNames{sysDst,1}]);
            end
        end
    end
    
end
%%
inputFbList = [];
inputSigList_0 = [];
for i = 1:length(numOfIntrcnnct)
    inputFbList = [inputFbList; intrcnnct_dst(1:numOfIntrcnnct(i),i)];%[intrcnnct_dst(1:numOfIntrcnnct(1),1);intrcnnct_dst(1:numOfIntrcnnct(2),2)];
    inputSigList_0 = [inputSigList_0; inportBlocks(1:numOfInputs(i),i)];%[inportBlocks(1:numOfInputs(1),1);inportBlocks(1:numOfInputs(2),2)];
end
inputSigList = inputSigList_0(~ismember(inputSigList_0, inputFbList));
inputInterconnectSigList = unique((inputSigList)); %inputSigList is Array, NO MORE CELL
inputInterconnectList = unique((inputFbList)); %inputFbList is Array, NO MORE CELL

end %End of main function

