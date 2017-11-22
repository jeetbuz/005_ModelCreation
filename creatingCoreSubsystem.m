%% Takes the two subsystems and connects them as per excel sheet info
% Author: Khasnabish, Neilay RD I/CEP
%%
disp('### 4.1 Now executing "creatingCoreSubsystem.m"');
%newMdlName='CoreSubSys'; %TestModelSpace.mdl is the new filename; <Changed name to CoreSubSys:VGP,4/4/17>
disp(['### Creating new model: ' newMdlName]);
new_system(newMdlName);
save_system(newMdlName);
open_system(newMdlName);
%Copying each model to this new
shiftBlock=0;
Pos_SBlock= zeros(numOfFiles,4);

for i = 1:numOfFiles %i is the number of files
    if iscell(modelNames)
        sfModelFile = modelNames{1,i};
    else
        sfModelFile = modelNames;
    end
    %sfModelFile = modelNames{1,i};
    sfModelFile = sfModelFile(1:end-4);
    open_system(sfModelFile);
    sys_1=gcb; %get address
    sFunctionName = find_system(sfModelFile,'SearchDepth',1,'BlockType','SubSystem');

    [mdlName, subsysName]=strtok(strrep(cell2mat(sFunctionName), '/', ' '));
    subsysName = strtrim(subsysName);
    subSysNames{i,1} = subsysName;
    %get position
    if (shiftBlock==0)
        t=get(gcbh);
        pos=t.Position; %pos = [x y x+w y+h]
        posFinal=zeros(1,4);
        posFinal = pos;
%         posFinal(1,1)=pos(1,1);%+1000; Offset commented out by Vinayak
%         posFinal(1,2)=pos(1,2)+4520*shiftBlock;
%         posFinal(1,3)=pos(1,3);%+1000; Offset commented out by Vinayak
%         posFinal(1,4)=pos(1,4)+4520*shiftBlock;
    else
        sfLength = pos(1,4) - pos(1,2);
        sfWidth = pos(1,3) - pos(1,1);
        posFinal(1,1)=pos(1,1);%+1000; Offset commented out by Vinayak
        posFinal(1,2)=pos(1,4)+ sfLength*shiftBlock;
        posFinal(1,3)=pos(1,3);%+1000; Offset commented out by Vinayak
        posFinal(1,4)=posFinal(1,2)+sfLength;
    end
    
    add_block(sys_1,[newMdlName '/' subsysName],'Position',posFinal);
    
    Pos_SBlock(i,:)= posFinal; %Saving the locations of S-Blocks
    
    close_system(sfModelFile);
    shiftBlock=shiftBlock+1.5;
end
save_system(newMdlName);


%%  Interconnecting the feedback connections
disp('### 4.2 Interconnecting the subsystems');
%open_system(hNewFile);
%inputFbList is the array of Feedback input signals
%inputSigList is the array of unique inut signals
[inputFbList, inputSigList] = inter_connect(newMdlName, subSysNames, fileNames, dateSuffix);
save_system(newMdlName);

%%  Placing Input Ports
%clc
disp('### 4.3 Placing input ports combined for remaining inputs of the interconnected subsystems');
placeIoPorts(inputFbList, inputSigList, newMdlName, Pos_SBlock, fileNames, numOfFiles, dateSuffix);
save_system(newMdlName);

