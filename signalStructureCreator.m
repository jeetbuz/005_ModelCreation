disp('### Now executing "signalStructureCreator.m"');
InputSignals = [];
OutputSignals = [];
for fileNum = 1:numel(fileNames)
    inpData = {}; outData = {};
    [~,inpData] = xlsread(fileNames{fileNum},'InputsAnalysis');
    [~,outData] = xlsread(fileNames{fileNum},'OutputsAnalysis');
    [rI, cI] = size(inpData);
    sigName = {};sigType = {};sigValue = {};sigUnit = {}; sigGTUnit = {};sigGTName = {};
    for j = 1:cI
        %disp(inpData{1,j});
        if strcmpi(inpData{1,j}, 'Name')
            sigName = inpData(2:end, j);
        elseif strcmpi(inpData{1,j}, 'Type')
            sigType = inpData(2:end, j);
        elseif strcmpi(inpData{1,j}, 'Value')
            sigValue = inpData(2:end, j);
        elseif strcmpi(inpData{1,j}, 'Unit')
            sigUnit = inpData(2:end, j);
        elseif strcmpi(inpData{1,j}, 'GT_Vehement Unit')
            sigGTUnit = inpData(2:end, j);
        elseif strcmpi(inpData{1,j}, 'GT_Vehement Name')
            sigGTName = inpData(2:end, j);
        else
            %FU
        end
    end
    
    for k = 1:rI-1
        eval(['InputSignals.', sigName{k}, ' = [];']);
        eval(['InputSignals.', sigName{k}, '.Type =  sigType{k};']);
        eval(['InputSignals.', sigName{k}, '.Unit =  sigUnit{k};']);
        eval(['InputSignals.', sigName{k}, '.GTUnit =  sigGTUnit{k};']);
        eval(['InputSignals.', sigName{k}, '.GTName =  sigGTName{k};']);
    end
    
    [rO, cO] = size(outData);
    sigName = {};sigType = {};sigValue = {};sigUnit = {}; sigGTUnit = {};sigGTName = {};
    for j = 1:cO
        %disp(outData{1,j});
        if strcmpi(outData{1,j}, 'Name')
            sigName = outData(2:end, j);
        elseif strcmpi(outData{1,j}, 'Type')
            sigType = outData(2:end, j);
        elseif strcmpi(outData{1,j}, 'Value')
            sigValue = outData(2:end, j);
        elseif strcmpi(outData{1,j}, 'Unit')
            sigUnit = outData(2:end, j);
        elseif strcmpi(outData{1,j}, 'GT_Vehement Unit')
            sigGTUnit = outData(2:end, j);
        elseif strcmpi(outData{1,j}, 'GT_Vehement Name')
            sigGTName = outData(2:end, j);
        else
            %FU
        end
    end
    sigName = cellfun(@(x) strrep(x,'[','_'),sigName,'UniformOutput', false);
    sigName = cellfun(@(x) strrep(x,']','_'),sigName,'UniformOutput', false);
    for k = 1:rO-1
        eval(['OutputSignals.', sigName{k}, ' = [];']);
        eval(['OutputSignals.', sigName{k}, '.Type =  sigType{k};']);
        eval(['OutputSignals.', sigName{k}, '.Unit =  sigUnit{k};']);
        eval(['OutputSignals.', sigName{k}, '.GTUnit =  sigGTUnit{k};']);
        eval(['OutputSignals.', sigName{k}, '.GTName =  sigGTName{k};']);
    end
    
end
%%
[fileName,~] = uigetfile('*.xlsx','Select the AGK to GT mapping file');

    inpData = {}; outData = {};
    [~,inpData] = xlsread(fileName,'InputsAnalysis');
    [~,outData] = xlsread(fileName,'OutputsAnalysis');
    [rI, cI] = size(inpData);
    sigName = {};sigType = {};sigValue = {};sigUnit = {}; sigGTUnit = {};sigGTName = {};
    for j = 1:cI
        %disp(inpData{1,j});
        if strcmpi(inpData{1,j}, 'Name')
            sigName = inpData(2:end, j);
        elseif strcmpi(inpData{1,j}, 'Type')
            sigType = inpData(2:end, j);
        elseif strcmpi(inpData{1,j}, 'Value')
            sigValue = inpData(2:end, j);
        elseif strcmpi(inpData{1,j}, 'Unit')
            sigUnit = inpData(2:end, j);
        elseif strcmpi(inpData{1,j}, 'GT_Vehement Unit')
            sigGTUnit = inpData(2:end, j);
        elseif strcmpi(inpData{1,j}, 'GT_Vehement Name')
            sigGTName = inpData(2:end, j);
        else
            %FU
        end
    end
    
    for k = 1:rI-1
        %eval(['InputSignals.', sigName{k}, ' = [];']);
        eval(['InputSignals.', sigName{k}, '.Type =  sigType{k};']);
        eval(['InputSignals.', sigName{k}, '.Unit =  sigUnit{k};']);
        eval(['InputSignals.', sigName{k}, '.GTUnit =  sigGTUnit{k};']);
        eval(['InputSignals.', sigName{k}, '.GTName =  sigGTName{k};']);
    end
    
    [rO, cO] = size(outData);
    sigName = {};sigType = {};sigValue = {};sigUnit = {}; sigGTUnit = {};sigGTName = {};
    for j = 1:cO
        %disp(outData{1,j});
        if strcmpi(outData{1,j}, 'Name')
            sigName = outData(2:end, j);
        elseif strcmpi(outData{1,j}, 'Type')
            sigType = outData(2:end, j);
        elseif strcmpi(outData{1,j}, 'Value')
            sigValue = outData(2:end, j);
        elseif strcmpi(outData{1,j}, 'Unit')
            sigUnit = outData(2:end, j);
        elseif strcmpi(outData{1,j}, 'GT_Vehement Unit')
            sigGTUnit = outData(2:end, j);
        elseif strcmpi(outData{1,j}, 'GT_Vehement Name')
            sigGTName = outData(2:end, j);
        else
            %FU
        end
    end
    sigName = cellfun(@(x) strrep(x,'[','_'),sigName,'UniformOutput', false);
    sigName = cellfun(@(x) strrep(x,']','_'),sigName,'UniformOutput', false);
    for k = 1:rO-1
        %eval(['OutputSignals.', sigName{k}, ' = [];']);
        eval(['OutputSignals.', sigName{k}, '.Type =  sigType{k};']);
        eval(['OutputSignals.', sigName{k}, '.Unit =  sigUnit{k};']);
        eval(['OutputSignals.', sigName{k}, '.GTUnit =  sigGTUnit{k};']);
        eval(['OutputSignals.', sigName{k}, '.GTName =  sigGTName{k};']);
    end