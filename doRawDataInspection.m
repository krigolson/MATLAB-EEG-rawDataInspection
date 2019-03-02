function doRawDataInspection(EEG)

    global fig1
    global fig2
    global OUTEEG
    global f1
    global f2
    global f3
    global f4
    global f5
    global message1
    global message2
    global message3
    global message4
    global message5
    global message6
    global message7
    global message8
    global txt1
    global txt2
    global txt3
    global txt4
    global txt5
    global txt6
    global txt7  
    global txt8
    global scales
    global scalesCounter
    
    EEG.originalData = EEG.data;
    EEG.originalChanlocs = EEG.chanlocs;

    EEG.filterParameters.fitlerLow = 0;
    EEG.filterParameters.fitlerHigh = 0;
    EEG.filterParameters.fitlerNotch = 0;
    EEG.channelsRemoved = {};
    EEG.referenceChannels = {};
    
    EEG.currentEpoch = [-0.5 1.5];
    EEG.artifactCriteriaDifference = 100;
    EEG.artifactCriteriaGradient = 10;
    scales = [(EEG.srate/10) (EEG.srate/5) (EEG.srate/2) (EEG.srate) (EEG.srate*2) (EEG.srate*5) (EEG.srate*10)];
    scalesCounter = 4;

    % clean up EEG markers
    [markerData EEG] = cleanMarkers(EEG);
    [count,markers]=hist(markerData(:,1),unique(markerData(:,1)));
    count = count';
    EEG.markersAvailable = markers;
    EEG.markersCount = count;
    EEG.currentMarkers = markers;
    EEG.currentCount = count;
    EEG.epochMarkers = num2cell(EEG.currentMarkers);
    listboxAllMarkers = EEG.epochMarkers;
    EEG.t1 = 1;
    EEG.t2 = EEG.srate;
    EEG.currentScale = EEG.srate;
    EEG.indexes = [1:1:10];
    
    scrsz = get(groot,'ScreenSize');

    fig1 = figure(1);

    bottom = 50;
    
    btn1 = uicontrol('Style','pushbutton', 'String', 'Quit','Position',[scrsz(3)-200 bottom 100 20],'Callback',@quitLoop);
    %btn2 = uicontrol('Style','pushbutton', 'String', 'Save Data','Position',[scrsz(3)-200 bottom+25 100 20],'Callback',@saveData);
    %btn3 = uicontrol('Style','pushbutton', 'String', 'Delete Channel','Position',[scrsz(3)-200 bottom+50 100 20],'Callback',@deleteChannel);
    btn4 = uicontrol('Style','togglebutton', 'String', 'Rereference Data','Position',[scrsz(3)-200 bottom+125 100 20],'Callback',@rereferenceData);
    btn5 = uicontrol('Style','togglebutton', 'String', 'Filter Data','Position',[scrsz(3)-200 bottom+150 100 20],'Callback',@filterData);
    btn7 = uicontrol('Style','pushbutton', 'String', 'Epoch Window','Position',[scrsz(3)-200 bottom+75 100 20],'Callback',@setEpochWindow);
    btn8 = uicontrol('Style','pushbutton', 'String', 'Artifact Criteria','Position',[scrsz(3)-200 bottom+100 100 20],'Callback',@setArtifactCriteria);
    %btn9 = uicontrol('Style','togglebutton', 'String', 'ICA','Position',[scrsz(3)-200 bottom+175 100 20],'Callback',@doICA);
    
    
    btn6 = uicontrol('Style', 'listbox','Position',[scrsz(3)-600 bottom 100 100],'string',listboxAllMarkers,'Max',length(listboxAllMarkers),'Min',1,'Callback',@selectMarkers);

    txt1 = uicontrol('Style','text','Position',[scrsz(3)-425 bottom 200 20],'String',message1,'HorizontalAlignment','left');
    %txt2 = uicontrol('Style','text','Position',[scrsz(3)-425 bottom+20 200 20],'String',message2,'HorizontalAlignment','left');
    %txt3 = uicontrol('Style','text','Position',[scrsz(3)-425 bottom+40 200 20],'String',message3,'HorizontalAlignment','left');
    txt4 = uicontrol('Style','text','Position',[scrsz(3)-425 bottom+60 200 20],'String',message4,'HorizontalAlignment','left');
    txt5 = uicontrol('Style','text','Position',[scrsz(3)-425 bottom+80 200 20],'String',message5,'HorizontalAlignment','left');
    txt6 = uicontrol('Style','text','Position',[scrsz(3)-425 bottom+100 200 20],'String',message6,'HorizontalAlignment','left');
    txt7 = uicontrol('Style','text','Position',[scrsz(3)-425 bottom+120 200 20],'String',message7,'HorizontalAlignment','left');
    txt8 = uicontrol('Style','text','Position',[scrsz(3)-425 bottom+140 200 20],'String',message8,'HorizontalAlignment','left');
    %txt9 = uicontrol('Style','text','Position',[scrsz(3)-600 bottom+120 100 20],'String','Selected Markers','HorizontalAlignment','left');
    
    redoMath;
    drawPlots;
    
    fig2 = figure(2);
    set(fig2,'KeyPressFcn',@keyboardFun);
    
    drawEEG;
    
    function drawPlots(source,event)

        % draw the variance per channel plot
        
        figure(1);
        
        delete(f1);
        delete(f2);
        delete(f3);
        delete(f4);
        delete(f5);

        f1 = subplot_tight(3,2,1,[0.05 0.05],'Parent',fig1);
        cla(f1);
        barwitherr(EEG.CIs(:,3),EEG.meanVariances);
        xlim([0.5 length(EEG.chanlocs)+0.5]);
        xticks([1:1:length(EEG.chanlocs)]);
        xtickangle(90);
        EEG.labels = {};
        for counter = 1:length(EEG.chanlocs)
            EEG.labels{counter} = EEG.chanlocs(counter).labels;
        end
        set(f1,'xticklabel',EEG.labels);
        title('Variance Per Second');

        % draw the artifact plot
        f2 = subplot_tight(3,2,2,[0.05 0.05],'Parent',fig1);
        cla(f2);
        bar(EEG.artifactBarInfo);
        xlim([0.5 length(EEG.chanlocs)+0.5]);
        ylim([0 100]);
        xticks([1:1:length(EEG.chanlocs)]);
        xtickangle(90);
        set(f2,'xticklabel',EEG.labels);
        title('Artifact Percentages');

        % imagesc plots of artifacts
        f3 = subplot_tight(3,2,3,[0.05 0.05],'Parent',fig1);
        cla(f3);
        imagesc(OUTEEG.artifactGradientSize',[0 EEG.artifactCriteriaGradient]);
        xticks([1:1:length(EEG.chanlocs)]);
        xtickangle(90);
        set(f3,'xticklabel',EEG.labels);
        title('Gradient Artifacts by Channel and Trial');
        ylabel('Epochs');

        % imagesc plots of artifacts
        f4 = subplot_tight(3,2,4,[0.05 0.05],'Parent',fig1);
        cla(f4);
        imagesc(OUTEEG.artifactDifferenceSize',[0 EEG.artifactCriteriaDifference]);
        xticks([1:1:length(EEG.chanlocs)]);
        xtickangle(90);
        set(f4,'xticklabel',EEG.labels);
        title('Difference Artifacts by Channel and Trial');
        ylabel('Epochs');

        % code to get marker count for each marker
        f5 = subplot_tight(3,2,5,[0.05 0.05],'Parent',fig1);
        cla(f5);
        bar(EEG.currentCount);
        xticks([1:1:length(EEG.barLabels)]);
        xtickangle(90);
        set(f5,'xticklabel',EEG.barLabels);
        title('Marker Counts');

    end

    function drawEEG(source,event)
        
        figure(2);
        for i = 1:10
            subplot(5,2,i);
            plotData = squeeze(EEG.data(EEG.indexes(i),EEG.t1:EEG.t2));
            plot([EEG.t1:1:EEG.t2],plotData);
            title({['Channel: ' EEG.chanlocs(EEG.indexes(i)).labels];'Use up and down arrows to change channel channels'});
            xlabel({['Current Scale: ' num2str(EEG.currentScale)];'Use left and right arrows to scroll through time';'Use s to change the scale'});
            xlim([EEG.t1 EEG.t2]);
        end
        
    end 
    
    function quitLoop(source,event)

        close all;

    end

    function doICA(source,event)
        
        button_state = get(source,'Value');
        
        % need to remove reference channels
        
        if button_state == get(source,'Max')
            prompt = {'Use continuous data (1) or epoched data (2)'};
            dlg_title = 'ICA';
            num_lines = 1;
            defaultans = {'1'};
            answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
            icaType = str2num(answer{1});
            if icaType == 1
                EEG = pop_runica(EEG, 'extended',1);
                EEG.icaOn = 'Continuous';
            end
            if icaType == 2
                OUTEEG = pop_runica(OUTEEG, 'extended',1);
                EEG.icaact = [];
                EEG.icawinv = OUTEEG.icawinv;
                EEG.icasphere = OUTEEG.icasphere;
                EEG.icaweights = OUTEEG.icaweights;
                EEG.icachansind = OUTEEG.icachansind;
                EEG.icaOn = 'Epochs';
            end

            uiwait(msgbox('ICA is completed','DONE!!!','modal'));
            
            redoMath;
            drawPlots;
        
        elseif button_state == get(source,'Min')

        end        
     
    end

    function redoMath

        % determine artifacts for each marker
        OUTEEG = [];
        OUTEEG = pop_epoch(EEG,EEG.epochMarkers,EEG.currentEpoch);
        EEG.totalMarkers = size(OUTEEG.data,3);
        OUTEEG = artifactRejectionDifference(OUTEEG,EEG.artifactCriteriaDifference);
        OUTEEG = artifactRejectionGradient(OUTEEG,EEG.artifactCriteriaGradient);
        EEG.percentDifference = sum(OUTEEG.artifactDifference,2)/EEG.totalMarkers*100;
        EEG.percentGradient = sum(OUTEEG.artifactGradient,2)/EEG.totalMarkers*100;
        EEG.rejectedDifference = max(sum(OUTEEG.artifactDifference,2));
        EEG.rejectedGradient = max(sum(OUTEEG.artifactGradient,2));
        EEG.artifactBarInfo = [EEG.percentDifference EEG.percentGradient];

        % code to generate variance per second and plot
        x1 = 1;
        x2 = EEG.srate;
        variances = [];
        allVariances = [];
        while 1   
            temp = [];
            temp = EEG.data(:,x1:x2);
            variances = var(temp,'',2);
            allVariances = [allVariances variances];
            x1 = x2 + 1;
            x2 = x2 + EEG.srate;
            if x2 > length(EEG.data)
                break
            end
        end
        EEG.CIs = [];
        for counter = 1:size(EEG.data,1) 
            EEG.CIs(counter,:) = makeCIs(allVariances(counter,:));
        end
        EEG.meanVariances = [];
        EEG.meanVariances = mean(allVariances,2);

        % code to get marker count for each marker
        EEG.barLabels = [];
        for counter = 1:length(EEG.currentMarkers)
            EEG.barLabels{counter} = [num2str(EEG.currentMarkers(counter)) ' : ' num2str(EEG.currentCount(counter))];
        end
        
        message1 = ['Total Markers: ' num2str(EEG.totalMarkers)];
        message2 = ['Markers Lost Difference:  ' num2str(EEG.rejectedDifference)];
        message3 = ['Markers Lost Gradient: ' num2str(EEG.rejectedGradient)];
        message4 = ['Percent Lost Difference: ' num2str(max(EEG.percentDifference)) '%'];
        message5 = ['Percent Lost Gradient: ' num2str(max(EEG.percentGradient)) '%'];
        message6 = ['Difference Criteria (blue): ' num2str(EEG.artifactCriteriaDifference)];
        message7 = ['Gradient Criteria (red): ' num2str(EEG.artifactCriteriaGradient)];
        message8 = ['Current Epoch: ' num2str(EEG.currentEpoch(1)) ' to ' num2str(EEG.currentEpoch(2))];
        
        set(txt1, 'String', message1);
        set(txt2, 'String', message2);
        set(txt3, 'String', message3);
        set(txt4, 'String', message4);
        set(txt5, 'String', message5);
        set(txt6, 'String', message6);
        set(txt7, 'String', message7);
        set(txt8, 'String', message8);
        
    end

    function filterData(source,event)
        
        button_state = get(source,'Value');
        
        if button_state == get(source,'Max')
            prompt = {'Enter the low cuttoff','Enter the high cutoff','Enter the notch filter value (0 = no notch):'};
            dlg_title = 'Filter Data';
            num_lines = 3;
            defaultans = {'0.1','30','60'};
            answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
            filterLow = str2num(answer{1});
            filterHigh = str2num(answer{2});
            filterNotch = str2num(answer{3});
            filterOrder = 2;
            % do the low and high cuttoff
            [b,a] = butter(filterOrder,[filterLow filterHigh]/(EEG.srate/2)); % define Butterworth filter
            for counter = 1:size(EEG.data,1) % filter data by channel and sample
                EEG.data(counter,:) = filtfilt(b,a,double(EEG.data(counter,:)));  
            end
            % do the notch filter
            if filterNotch ~= 0
                Qfactor = 35; % need to learn more about what this does
                wo = filterNotch/(EEG.srate/2);  bw = wo/Qfactor;
                [b,a] = iirnotch(wo,bw);
                for counter = 1:size(EEG.data,1) % filter data by channel and sample
                    EEG.data(counter,:) = filtfilt(b,a,double(EEG.data(counter,:)));  
                end
            end

            EEG.filterParameters.fitlerLow = filterLow;
            EEG.filterParameters.fitlerHigh = filterHigh;
            EEG.filterParameters.fitlerNotch = filterNotch;
  
            redoMath;
            drawPlots;
            
            uiwait(msgbox('Filtering is completed','DONE!!!','modal'));
            
        elseif button_state == get(source,'Min')
            
            EEG.data = EEG.originalData; 
            EEG.originalChanlocs = EEG.chanlocs;
            EEG.filterParameters.fitlerLow = 0;
            EEG.filterParameters.fitlerHigh = 0;
            EEG.filterParameters.fitlerNotch = 0;
            EEG.channelsRemoved = {};
            EEG.referenceChannels = {};
            EEG.nbchan = size(EEG.data,1);
            
            redoMath;
            drawPlots;
            
            uiwait(msgbox('Filtering undone. Date is returned to ORIGINAL STATE!','DONE!!!','modal'));
            
        end

    end

    function saveData(source,event)
        
        if EEG.filterParameters.fitlerLow ~= 0.1
            uiwait(msgbox('Low Pass Filter of 0.1Hz Not Applied!','WARNING!!!','modal'));
        end
        if EEG.filterParameters.fitlerHigh ~= 30
            uiwait(msgbox('High Pass Filter of 30Hz Not Applied!','WARNING!!!','modal'));
        end
        if EEG.filterParameters.fitlerNotch ~= 60
            uiwait(msgbox('Notch Filter of 60Hz Not Applied!','WARNING!!!','modal'));
        end
        checkChannels = {'TP9';'TP10'};
        if isequal(checkChannels,EEG.referenceChannels) == 0
            uiwait(msgbox('Standard Reference Channels of TP9 and TP10 Not Used!','WARNING!!!','modal'));
        end
        
        prompt = {'Enter the filename:'};
        dlg_title = 'Save Data';
        num_lines = 1;
        defaultans = {filename};
        answer{1} = 0;
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        if answer{1} ~= 0
            EEG.originalData = [];
            EEG.originalChanlocs = 0;
            save(answer{1},'EEG');
            uiwait(msgbox('Data Saved.','DONE!','modal'));
        end
        
    end

    function deleteChannel(source,event)
        % get user input or quit
        prompt = {'Enter the channel to remove:'};
        dlg_title = 'Delete Channel';
        num_lines = 1;
        defaultans = {'0'};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        for counter = 1:length(EEG.chanlocs)
            if strcmp(EEG.chanlocs(counter).labels,answer)
                EEG = pop_select(EEG, 'nochannel', counter);
                EEG.channelsRemoved = [EEG.channelsRemoved answer];
                break
            end
        end
        
        redoMath;
        drawPlots;
        
    end

    function rereferenceData(source,event)
        
        button_state = get(source,'Value');
        
        if button_state == get(source,'Max')
            
            prompt = {'Enter the first reference channel:','Enter the second reference channel (0) if none:'};
            dlg_title = 'Reference Data';
            num_lines = 2;
            defaultans = {'TP9','TP10'};
            answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

            if strcmp(answer{2},'0')
                for counter1 = 1:length(EEG.chanlocs)
                    if strcmp(EEG.chanlocs(counter1).labels,answer{1})
                        referenceChannel = EEG.data(counter1,:);
                        break
                    end
                end          
            else
                for counter1 = 1:length(EEG.chanlocs)
                    if strcmp(EEG.chanlocs(counter1).labels,answer{1})
                        referenceChannel1 = EEG.data(counter1,:);
                        break
                    end
                end
                for counter2 = 1:length(EEG.chanlocs)
                    if strcmp(EEG.chanlocs(counter2).labels,answer{2})
                        referenceChannel2 = EEG.data(counter2,:);
                        break
                    end
                end
                referenceChannel = (referenceChannel1 + referenceChannel2)/2;
            end

            EEG.data = EEG.data - referenceChannel;
            EEG.referenceChannels = answer;
            
            % remove reference channels from the data
            for i = 1:size(EEG.referenceChannels,1)
                for k = 1:length(EEG.chanlocs)
                    if strcmp(EEG.chanlocs(k).labels,EEG.referenceChannels{i,1})
                        EEG = pop_select(EEG, 'nochannel', k);
                         break
                    end
                end 
            end

            redoMath;
            drawPlots;
            
            uiwait(msgbox('Rereferencing is completed','DONE!!!','modal'));
        
        elseif button_state == get(source,'Min')
            
            EEG.data = EEG.originalData; 
            EEG.originalChanlocs = EEG.chanlocs;
            EEG.filterParameters.fitlerLow = 0;
            EEG.filterParameters.fitlerHigh = 0;
            EEG.filterParameters.fitlerNotch = 0;
            EEG.channelsRemoved = {};
            EEG.referenceChannels = {};
            EEG.nbchan = size(EEG.data,1);
            
            redoMath;
            drawPlots;
            
            uiwait(msgbox('Rereferencing undone. Date is returned to ORIGINAL STATE!','DONE!!!','modal'));
            
        end

    end

        %---------------add your function---------------------
    function selectMarkers(source,event)
    
        EEG.selectedMarkers = get(source,'value');
        EEG.currentMarkers = EEG.markersAvailable(EEG.selectedMarkers);
        EEG.currentCount = EEG.markersCount(EEG.selectedMarkers);
        EEG.epochMarkers = num2cell(EEG.markersAvailable(EEG.selectedMarkers));
        
        redoMath;
        drawPlots;

    end

    function setEpochWindow(source,event)
        
        prompt = {'Enter the start time','Enter the end time'};
        dlg_title = 'Set Epoch Length';
        num_lines = 2;
        defaultans = {'-0.5','1.5'};
        answer{1} = 0;
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        
        if answer{1} ~= 0
            EEG.currentEpoch(1,1) = str2num(answer{1})
            EEG.currentEpoch(1,2) = str2num(answer{2})

            redoMath;
            drawPlots;
        end

    end

    function setArtifactCriteria(source,event)

        prompt = {'Enter the gradient criteria','Enter the difference criteria'};
        dlg_title = 'Set Artifact Criteria';
        num_lines = 2;
        defaultans = {'10','100'};
        answer{1} = 0;
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

        if answer{1} ~= 0
            EEG.artifactCriteriaGradient = str2num(answer{1})
            EEG.artifactCriteriaDifference = str2num(answer{2})
            redoMath;
            drawPlots;
        end
        
    end

    function keyboardFun(source,event)
        
        if strcmp(event.Key,'rightarrow')
            EEG.t1 = EEG.t1 + EEG.currentScale;
            EEG.t2 = EEG.t2 + EEG.currentScale;
            
            if EEG.t2 > size(EEG.data,2)
                EEG.t1 = 1;
                EEG.t2 = EEG.currentScale;
            end
        end
        if strcmp(event.Key,'leftarrow')
            EEG.t1 = EEG.t1 - EEG.currentScale;
            EEG.t2 = EEG.t2 - EEG.currentScale;
            
            if EEG.t1 < 1
                EEG.t1 = size(EEG.data,2) - EEG.currentScale;
                EEG.t2 = size(EEG.data,2);
            end
        end
        if strcmp(event.Key,'uparrow')
            if max(EEG.indexes) < size(EEG.data,1)
                EEG.indexes = EEG.indexes + 1;
            end
        end
        if strcmp(event.Key,'downarrow')
            if min(EEG.indexes) > 1
                EEG.indexes = EEG.indexes - 1;
            end
        end        
        if strcmp(event.Key,'s')       
            scalesCounter = scalesCounter + 1;
            if scalesCounter > length(scales)
                scalesCounter = 1;
                EEG.t2 = EEG.t1 + EEG.currentScale;
            else
                EEG.currentScale = scales(scalesCounter);
                EEG.t2 = EEG.t1 + EEG.currentScale;
            end
        end
        drawEEG;
        
    end

end




