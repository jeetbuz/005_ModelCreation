%%
% Author: Khasnabish, Neilay RD I/CEP
%%
function placeIoPorts_300(inputFbList, inputSigList, modelName, Pos_SBlock, fileNames, numOfFiles, dateSuffix)
%%
%Initialise for the Inports
xSig_top=40;
ySig_top=10;
xSig_bot=120;
ySig_bot=40; 
shiftBlockIp=6;
Pos=100*ones(1,4);

%Get system info
sys = modelName; %Name of the complete space

disp('### Routing the Inports ...')
%Put input ports for outer connection
disp('### Creating dynToDlls_Modifier ...')
fid_dynToDlls = fopen(['dynToDlls_Modifier_' dateSuffix '.txt'], 'w+');
for i=1:length(inputSigList)
    
     sigName=inputSigList(i);
     
     %To check if sigName is not in inputFbList
     flag=1; %Not an Interconnect
     for k=1:length(inputFbList)
        sigFBName=inputFbList(k);
        if strcmp(num2str(sigFBName{1,1}), num2str(sigName{1,1}))
            flag=0; %Present
            break;
        else
        end
     end

     if (flag==1) %Not an Interconnect

        %Position for Inport
        xSig_top=xSig_top;
        ySig_top=ySig_top+10*shiftBlockIp;
        xSig_bot=xSig_bot;
        ySig_bot=ySig_bot+10*shiftBlockIp;  
        Pos=[xSig_top, ySig_top, xSig_bot, ySig_bot];

        %Add Inport block
        add_block('built-in/Inport',[sys '/' num2str(sigName{1,1})], 'ShowName','on','Name',num2str(sigName{1,1}),'Position',Pos);
        %display('PLACED INPORT')
        
        % Write modifier file
        fprintf(fid_dynToDlls,[['ECM_' sigName{1,1}] ' = ' ['Dyn_' sigName{1,1}] ';\n']);
        fprintf(fid_dynToDlls,[['CPC_' sigName{1,1}] ' = ' ['Dyn_' sigName{1,1}] ';\n']);
        %Position for Goto block
        xGoto_top=xSig_top+200;
        yGoto_top=ySig_top;
        xGoto_bot=xSig_bot+200;
        yGoto_bot=ySig_bot;  
        Pos=[xGoto_top, yGoto_top, xGoto_bot, yGoto_bot];

        
        %Add Goto block
        add_block('built-in/Goto',[sys '/' 'Goto_' num2str(sigName{1,1})],'Name',['Goto_' num2str(sigName{1,1})],'ShowName','on','GotoTag',['Label_' num2str(sigName{1,1})],'Position',Pos);
        %display('PLACED GOTO')  
        
        %Connect wire between Inport and Goto block
        add_line(sys, [num2str(sigName{1,1}) '/1'],['Goto_' num2str(sigName{1,1}) '/1'],'autorouting','on');
        
     end
end
fclose(fid_dynToDlls);
%%
%##########################CONNECTING-FROM-BLOCKS#####################################

% %Finding the number of blocks
display('### Connecting the S-Functions to inports ...')
sFunctions = find_system(modelName,'SearchDepth',1,'BlockType','SubSystem'); %Number of SFunctions
posLen=0;
%Placing port for each function
for i = 1:length(sFunctions)
    
    sysSF = sFunctions{i}; %Sfunction block address
   
    %Finding inport block for each SFunction
    inport_blocks = find_system(sysSF,'SearchDepth',1,'BlockType','Inport');
    
    %Initialise for each SFunction block
    len_SF=abs(Pos_SBlock(i,2)-Pos_SBlock(i,4));
    numOfPortsSF=abs(length(inport_blocks));
    yAxisOffset=round(len_SF/numOfPortsSF);
    
    ySig_top=abs(Pos_SBlock(i,2));
    ySig_bot=ySig_top+yAxisOffset; %??????????????????????????????????
    
    xSig_bot=abs(Pos_SBlock(i,1)-80);
    xSig_top=abs(xSig_bot-260);
       
    shiftBlockIp=6;
    Pos=100*ones(1,4);
    
    posLen=posLen+1;
    
    for j=1:length(inport_blocks) %For each Input port
        
        sigName2 = get_param(inport_blocks{j},'Name');
        
        flag=1; %Not interconnected path
        for k=1:length(inputFbList)
            sigFBName=inputFbList(k);
            if strcmp((sigFBName), num2str(sigName2))
                flag=0; %Interconnected path
                break;
            else
            end
        end
        
            
        %If Input signal is not an interconect
        if(flag==1)
            
            %Position of the componenet
            ySig_top=ySig_top+yAxisOffset; %?????????????????
            ySig_bot=ySig_bot+yAxisOffset;
            yAdjust=abs(ySig_bot-ySig_top)/4;
            
            %Positioning           
            Pos=[xSig_top, abs(ySig_top+yAdjust), xSig_bot, abs(ySig_bot-yAdjust)];
         
            %Place a From block
            add_block('built-in/From',[sys '/' 'From_' num2str(sigName2) '_SF_' num2str(i)],'Name',['From_' num2str(sigName2) '_SF_' num2str(i)],'ShowName','off','GotoTag',['Label_' num2str(sigName2)],'Position',Pos);
            %display('PLACED FROM')
            
            %Add wire
            src1=['From_' num2str(sigName2) '_SF_' num2str(i) '/1'];  %i >> no of SF
            
            %Splitting words
            t_ind=1;
            for t=1:length(sysSF)
                if sysSF(t_ind)=='/'
                    t_ind=t_ind+1;
                    break;
                else
                    t_ind=t_ind+1;
                end
            end
            lastNameSF=sysSF(t_ind:end);
            dst1=[lastNameSF '/' num2str(j)];
            
            add_line(sys,src1, dst1, 'autorouting','on');
            %add_line(sys,src1, dst1);

        end 
  
    end  
    
end    
 

%########################^^^OUTPUT-PORT^^^#############################

%Getting output list
disp('### Reading OutputAnalysis sheet ...');
opSigName = {}; 
opSigType = {}; 
outCount=1;
outSignalList={}; %outsignal list
termSignalList={}; %terminated signal list
kIndex1=1;


for fCount=1:numOfFiles
    [~,~,opData] = xlsread(num2str((fileNames{fCount})),'OutputsAnalysis');
    opSigName = opData(2:end,1); 
    opSigType = opData(2:end,2); 
    for outCount=1:length(opSigName)
        if strcmp(num2str((opSigType{outCount})),'ReqdOutput')
            outSignalList{kIndex1}=num2str(opSigName{outCount});
            kIndex1=kIndex1+1;
        end
    end
end

% fid_outputSelection = fopen('outputSelection_Modifier.txt', 'w+');
% %outSignalList %Total list of output signals
% for outNum = 1:(kIndex1 - 1)
%     sigName = outSignalList(kIndex1,1){4:end};
%     fprintf(
% end
% %Finding the number of blocks
disp('### Routing the Outports ...')
sFunctions = find_system(modelName,'SearchDepth',1,'BlockType','SubSystem'); %Number of SFunctions
%posLen=0;
%Placing port for each function
for i = 1:length(sFunctions)
    
    sysSF = sFunctions{i}; %Sfunction block address
   
    %Finding inport block for each SFunction
    outport_blocks = find_system(sysSF,'SearchDepth',1,'BlockType','Outport');
    
    %Initialise for each SFunction block
    len_SF=abs(Pos_SBlock(i,2)-Pos_SBlock(i,4));
    numOfPortsSF=abs(length(outport_blocks));
    yAxisOffset=round(len_SF/numOfPortsSF);
    
    ySig_top=abs(Pos_SBlock(i,2));
    ySig_bot=ySig_top+yAxisOffset; %??????????????????????????????????
    
    xSig_top=abs(Pos_SBlock(i,3)+40);
    xSig_bot=abs(xSig_top+120);
       
    %shiftBlockIp=6;
    Pos=100*ones(1,4);
    
    %posLen=posLen+1;
    
    for j=1:length(outport_blocks) %For each Input port
        
        sigName2 = get_param(outport_blocks{j},'Name');
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        flagOp=0;
        for kIndex2=1:(kIndex1-1)
            if strcmp(['out_' sigName2],(outSignalList{1,kIndex2}))
                flagOp=1; %this op is required
                %display('Matched')
                break;
            end
        end
        
        
        if flagOp==1
            
            %Position of the componenet
            if (j~=1)
                ySig_top=ySig_top+yAxisOffset; %?????????????????
                ySig_bot=ySig_bot+yAxisOffset;  
            end
            
            yAdjust=abs(ySig_bot-ySig_top)/4;
            
            %Positioning           
            Pos=[abs(xSig_top), abs(ySig_top+yAdjust), abs(xSig_bot), abs(ySig_bot-yAdjust)];
            %Pos=[1840 1188 1870 1202];
            %Pos=[100, 200, 300, 400];
         
            %Add Outport block
            add_block('built-in/Outport',[sys '/' num2str(sigName2)], 'ShowName','on','Name',[num2str(sigName2)],'Position',Pos);
            %display('PLACED INPORT')
            
            %Add wire
            dst1=[num2str(sigName2) '/1'];  %i >> no of SF
            
            %Splitting words
            t_ind=1;
            for t=1:length(sysSF)
                if sysSF(t_ind)=='/'
                    t_ind=t_ind+1;
                    break;
                else
                    t_ind=t_ind+1;
                end
            end
            lastNameSF=sysSF(t_ind:end);
            src1=[lastNameSF '/' num2str(j)];
            
            add_line(sys,src1, dst1, 'autorouting','on');
            %add_line(sys,src1, dst1);

        end
         
  
    end  
    
end  



return;
end %End of main function
