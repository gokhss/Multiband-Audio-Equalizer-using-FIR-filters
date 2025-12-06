%% Day 3: Complete Audio Equalizer GUI - Final Version
function step3_final_complete_gui()
    % Load filter bank from Day 2
    try
        load('../Day2_MultiBand/multiband_filters.mat');
    catch
        uialert([], 'Cannot load filters. Run Day 2 scripts first!', 'Error');
        return;
    end
    
    % Create main GUI
    fig = createCompleteGUI();
    
    % Initialize all data in figure UserData
    fig.UserData.audioData = [];
    fig.UserData.processedAudio = [];
    fig.UserData.fs = 44100;
    fig.UserData.h_bass = h_bass;
    fig.UserData.h_mid = h_mid;
    fig.UserData.h_treble = h_treble;
    
    % Initialize EQ gains
    fig.UserData.bassGain = 0;
    fig.UserData.midGain = 0;
    fig.UserData.trebleGain = 0;
    
    fprintf('=== Audio Equalizer GUI Ready! ===\n');
    fprintf('✓ Load audio files with the Load Audio button\n');
    fprintf('✓ Adjust EQ with Bass/Mid/Treble sliders\n');
    fprintf('✓ Try different presets from the dropdown\n');
    fprintf('✓ Play and compare original vs EQ audio\n');
    fprintf('✓ Save your processed audio files\n');
end

function fig = createCompleteGUI()
    fig = uifigure('Name', 'Audio Equalizer - Complete', 'Position', [100 50 920 750]);
    fig.Color = [0.15 0.15 0.15];
    
    % Title
    uilabel(fig, 'Position', [310 710 300 25], 'Text', 'Audio Equalizer v1.0', ...
        'FontSize', 20, 'FontWeight', 'bold', 'FontColor', 'white', ...
        'HorizontalAlignment', 'center');
    
    % Audio Control Panel
    audioPanel = uipanel(fig, 'Position', [20 500 880 140], ...
        'Title', 'Audio Controls', 'FontSize', 14, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.2 0.2 0.2], 'ForegroundColor', 'white');
    
    % EQ Control Panel
    eqPanel = uipanel(fig, 'Position', [20 280 880 210], ...
        'Title', 'Equalizer Controls', 'FontSize', 14, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.2 0.2 0.2], 'ForegroundColor', 'white');
    
    % Visualization Panel
    vizPanel = uipanel(fig, 'Position', [20 20 880 250], ...
        'Title', 'Audio Visualization', 'FontSize', 14, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.2 0.2 0.2], 'ForegroundColor', 'white');
    
    % Create all components
    createAudioControls(audioPanel, fig);
    createEQControls(eqPanel, fig);
    createVisualization(vizPanel, fig);
end

function createAudioControls(panel, fig)
    % Load Audio Button
    loadBtn = uibutton(panel, 'Position', [20 80 120 35], 'Text', 'Load Audio', ...
        'FontSize', 12, 'BackgroundColor', [0.3 0.6 0.9], 'FontWeight', 'bold');
    loadBtn.ButtonPushedFcn = @(btn, event) loadAudioFile(fig);
    
    % Play Original Button
    playOrigBtn = uibutton(panel, 'Position', [160 80 100 35], 'Text', 'Play Original', ...
        'FontSize', 11, 'BackgroundColor', [0.2 0.8 0.2], 'Enable', 'off');
    playOrigBtn.ButtonPushedFcn = @(btn, event) playOriginalAudio(fig);
    
    % Play EQ Button
    playEQBtn = uibutton(panel, 'Position', [280 80 100 35], 'Text', 'Play EQ', ...
        'FontSize', 11, 'BackgroundColor', [0.8 0.6 0.2], 'Enable', 'off');
    playEQBtn.ButtonPushedFcn = @(btn, event) playProcessedAudio(fig);
    
    % Stop Button
    stopBtn = uibutton(panel, 'Position', [400 80 80 35], 'Text', 'Stop', ...
        'FontSize', 11, 'BackgroundColor', [0.8 0.2 0.2], 'Enable', 'off');
    stopBtn.ButtonPushedFcn = @(btn, event) stopAudio();
    
    % Save Button
    saveBtn = uibutton(panel, 'Position', [500 80 120 35], 'Text', 'Save EQ Audio', ...
        'FontSize', 11, 'BackgroundColor', [0.8 0.2 0.6], 'Enable', 'off');
    saveBtn.ButtonPushedFcn = @(btn, event) saveProcessedAudio(fig);
    
    % Sample Audio Buttons
    uibutton(panel, 'Position', [650 80 100 35], 'Text', 'Load Handel', ...
        'FontSize', 10, 'BackgroundColor', [0.5 0.5 0.8], ...
        'ButtonPushedFcn', @(btn, event) loadSampleAudio(fig));
    
    % Audio Info Display
    infoLabel = uilabel(panel, 'Position', [20 40 700 25], 'Text', 'No audio loaded', ...
        'FontSize', 12, 'FontColor', 'white');
    
    % Store references
    fig.UserData.loadBtn = loadBtn;
    fig.UserData.playOrigBtn = playOrigBtn;
    fig.UserData.playEQBtn = playEQBtn;
    fig.UserData.stopBtn = stopBtn;
    fig.UserData.saveBtn = saveBtn;
    fig.UserData.infoLabel = infoLabel;
end

function createEQControls(panel, fig)
    % Bass Control
    uilabel(panel, 'Position', [80 170 60 20], 'Text', 'BASS', ...
        'FontSize', 14, 'FontWeight', 'bold', 'FontColor', 'cyan', ...
        'HorizontalAlignment', 'center');
    uilabel(panel, 'Position', [65 150 90 20], 'Text', '20-250 Hz', ...
        'FontSize', 10, 'FontColor', 'white', 'HorizontalAlignment', 'center');
    
    bassSlider = uislider(panel, 'Position', [50 130 120 3], 'Limits', [-12 12], ...
        'Value', 0, 'MajorTicks', [-12 -6 0 6 12]);
    bassSlider.ValueChangedFcn = @(slider, event) updateEQ(fig, 'bass', slider.Value);
    
    bassLabel = uilabel(panel, 'Position', [75 110 70 20], 'Text', '0.0 dB', ...
        'FontSize', 11, 'FontColor', 'white', 'HorizontalAlignment', 'center', ...
        'FontWeight', 'bold');
    
    % Mid Control
    uilabel(panel, 'Position', [250 170 60 20], 'Text', 'MID', ...
        'FontSize', 14, 'FontWeight', 'bold', 'FontColor', 'yellow', ...
        'HorizontalAlignment', 'center');
    uilabel(panel, 'Position', [235 150 90 20], 'Text', '250-4000 Hz', ...
        'FontSize', 10, 'FontColor', 'white', 'HorizontalAlignment', 'center');
    
    midSlider = uislider(panel, 'Position', [220 130 120 3], 'Limits', [-12 12], ...
        'Value', 0, 'MajorTicks', [-12 -6 0 6 12]);
    midSlider.ValueChangedFcn = @(slider, event) updateEQ(fig, 'mid', slider.Value);
    
    midLabel = uilabel(panel, 'Position', [245 110 70 20], 'Text', '0.0 dB', ...
        'FontSize', 11, 'FontColor', 'white', 'HorizontalAlignment', 'center', ...
        'FontWeight', 'bold');
    
    % Treble Control
    uilabel(panel, 'Position', [420 170 60 20], 'Text', 'TREBLE', ...
        'FontSize', 14, 'FontWeight', 'bold', 'FontColor', 'magenta', ...
        'HorizontalAlignment', 'center');
    uilabel(panel, 'Position', [400 150 100 20], 'Text', '4000-20000 Hz', ...
        'FontSize', 10, 'FontColor', 'white', 'HorizontalAlignment', 'center');
    
    trebleSlider = uislider(panel, 'Position', [390 130 120 3], 'Limits', [-12 12], ...
        'Value', 0, 'MajorTicks', [-12 -6 0 6 12]);
    trebleSlider.ValueChangedFcn = @(slider, event) updateEQ(fig, 'treble', slider.Value);
    
    trebleLabel = uilabel(panel, 'Position', [415 110 70 20], 'Text', '0.0 dB', ...
        'FontSize', 11, 'FontColor', 'white', 'HorizontalAlignment', 'center', ...
        'FontWeight', 'bold');
    
    % EQ Presets
    uilabel(panel, 'Position', [580 170 100 20], 'Text', 'EQ Presets:', ...
        'FontSize', 12, 'FontWeight', 'bold', 'FontColor', 'white');
    
    presetDropdown = uidropdown(panel, 'Position', [580 140 150 25], ...
        'Items', {'Custom', 'Flat', 'Pop/Rock', 'Vocal', 'V-Shape', 'Bright', 'Bass Boost'}, ...
        'Value', 'Flat', 'FontSize', 11);
    presetDropdown.ValueChangedFcn = @(dropdown, event) applyPreset(fig, dropdown.Value);
    
    % Reset Button
    resetBtn = uibutton(panel, 'Position', [750 140 80 25], 'Text', 'Reset', ...
        'FontSize', 11, 'BackgroundColor', [0.6 0.6 0.6]);
    resetBtn.ButtonPushedFcn = @(btn, event) resetEQ(fig);
    
    % Store references
    fig.UserData.bassSlider = bassSlider;
    fig.UserData.midSlider = midSlider;
    fig.UserData.trebleSlider = trebleSlider;
    fig.UserData.bassLabel = bassLabel;
    fig.UserData.midLabel = midLabel;
    fig.UserData.trebleLabel = trebleLabel;
    fig.UserData.presetDropdown = presetDropdown;
end

function createVisualization(panel, fig)
    % Create axes for frequency response
    ax = uiaxes(panel, 'Position', [30 20 820 200]);
    ax.BackgroundColor = [0.1 0.1 0.1];
    ax.XColor = 'white';
    ax.YColor = 'white';
    ax.GridColor = [0.3 0.3 0.3];
    
    % Initial flat response
    f = logspace(1.3, 4.3, 200); % 20 Hz to 20 kHz
    response = zeros(size(f));
    
    plot(ax, f, response, 'w-', 'LineWidth', 3);
    ax.XScale = 'log';
    ax.XLim = [20 20000];
    ax.YLim = [-15 15];
    ax.XLabel.String = 'Frequency (Hz)';
    ax.YLabel.String = 'Gain (dB)';
    ax.Title.String = 'Real-time EQ Frequency Response';
    ax.Title.Color = 'white';
    ax.Title.FontSize = 14;
    grid(ax, 'on');
    
    % Add frequency band markers
    hold(ax, 'on');
    xline(ax, 250, '--', 'Bass|Mid', 'Color', 'cyan', 'LineWidth', 1.5, 'FontSize', 10);
    xline(ax, 4000, '--', 'Mid|Treble', 'Color', 'yellow', 'LineWidth', 1.5, 'FontSize', 10);
    
    fig.UserData.eqAxes = ax;
end

function loadAudioFile(fig)
    [filename, pathname] = uigetfile({'*.wav;*.mp3;*.m4a', 'Audio Files'}, 'Select Audio File');
    
    if filename ~= 0
        try
            filepath = fullfile(pathname, filename);
            [audioData, fs] = audioread(filepath);
            
            % Convert to mono if stereo
            if size(audioData, 2) > 1
                audioData = audioData(:, 1);
            end
            
            % Normalize
            audioData = audioData / max(abs(audioData));
            
            % Store in GUI
            fig.UserData.audioData = audioData;
            fig.UserData.fs = fs;
            
            % Update info display
            duration = length(audioData) / fs;
            infoText = sprintf('Loaded: %s | Duration: %.2f sec | Sample Rate: %d Hz', ...
                filename, duration, fs);
            fig.UserData.infoLabel.Text = infoText;
            
            % Enable buttons
            fig.UserData.playOrigBtn.Enable = 'on';
            fig.UserData.stopBtn.Enable = 'on';
            
            % Process with current EQ settings
            processAudioWithEQ(fig);
            
            fprintf('Audio loaded successfully: %s\n', filename);
            
        catch ME
            uialert(fig, sprintf('Error loading audio: %s', ME.message), 'Error');
        end
    end
end

function loadSampleAudio(fig)
    try
        load handel;
        audioData = y / max(abs(y));
        
        % Store in GUI
        fig.UserData.audioData = audioData;
        fig.UserData.fs = Fs;
        
        % Update info display
        duration = length(audioData) / Fs;
        infoText = sprintf('Loaded: Handel Sample | Duration: %.2f sec | Sample Rate: %d Hz', ...
            duration, Fs);
        fig.UserData.infoLabel.Text = infoText;
        
        % Enable buttons
        fig.UserData.playOrigBtn.Enable = 'on';
        fig.UserData.stopBtn.Enable = 'on';
        
        % Process with current EQ settings
        processAudioWithEQ(fig);
        
        fprintf('Handel sample audio loaded successfully\n');
        
    catch ME
        uialert(fig, sprintf('Error loading sample audio: %s', ME.message), 'Error');
    end
end

function updateEQ(fig, band, value)
    % Update label
    labelText = sprintf('%.1f dB', value);
    
    switch band
        case 'bass'
            fig.UserData.bassLabel.Text = labelText;
            fig.UserData.bassGain = value;
        case 'mid'
            fig.UserData.midLabel.Text = labelText;
            fig.UserData.midGain = value;
        case 'treble'
            fig.UserData.trebleLabel.Text = labelText;
            fig.UserData.trebleGain = value;
    end
    
    % Set preset to "Custom"
    fig.UserData.presetDropdown.Value = 'Custom';
    
    % Process audio if loaded
    if ~isempty(fig.UserData.audioData)
        processAudioWithEQ(fig);
        updateVisualization(fig);
    end
    
    fprintf('%s: %.1f dB\n', upper(band), value);
end

function processAudioWithEQ(fig)
    if isempty(fig.UserData.audioData)
        return;
    end
    
    % Get current gains (with default values if not set)
    if ~isfield(fig.UserData, 'bassGain'), fig.UserData.bassGain = 0; end
    if ~isfield(fig.UserData, 'midGain'), fig.UserData.midGain = 0; end
    if ~isfield(fig.UserData, 'trebleGain'), fig.UserData.trebleGain = 0; end
    
    bassGain = fig.UserData.bassGain;
    midGain = fig.UserData.midGain;
    trebleGain = fig.UserData.trebleGain;
    
    % Convert to linear
    gains_linear = 10.^([bassGain midGain trebleGain]/20);
    
    % Apply EQ processing (inline)
    bass_out = gains_linear(1) * filter(fig.UserData.h_bass, 1, fig.UserData.audioData);
    mid_out = gains_linear(2) * filter(fig.UserData.h_mid, 1, fig.UserData.audioData);
    treble_out = gains_linear(3) * filter(fig.UserData.h_treble, 1, fig.UserData.audioData);
    
    fig.UserData.processedAudio = bass_out + mid_out + treble_out;
    
    % Enable buttons
    fig.UserData.playEQBtn.Enable = 'on';
    fig.UserData.saveBtn.Enable = 'on';
end

function applyPreset(fig, presetName)
    presets = containers.Map({...
        'Flat', 'Pop/Rock', 'Vocal', 'V-Shape', 'Bright', 'Bass Boost'}, {...
        [0 0 0], [6 -2 3], [-3 4 2], [8 -4 6], [-6 0 8], [8 0 0]});
    
    if strcmp(presetName, 'Custom')
        return;
    end
    
    if isKey(presets, presetName)
        gains = presets(presetName);
        
        % Update sliders
        fig.UserData.bassSlider.Value = gains(1);
        fig.UserData.midSlider.Value = gains(2);
        fig.UserData.trebleSlider.Value = gains(3);
        
        % Update gains and labels
        fig.UserData.bassGain = gains(1);
        fig.UserData.midGain = gains(2);
        fig.UserData.trebleGain = gains(3);
        
        fig.UserData.bassLabel.Text = sprintf('%.1f dB', gains(1));
        fig.UserData.midLabel.Text = sprintf('%.1f dB', gains(2));
        fig.UserData.trebleLabel.Text = sprintf('%.1f dB', gains(3));
        
        % Process audio
        if ~isempty(fig.UserData.audioData)
            processAudioWithEQ(fig);
            updateVisualization(fig);
        end
        
        fprintf('Applied preset: %s\n', presetName);
    end
end

function resetEQ(fig)
    % Reset all sliders to 0
    fig.UserData.bassSlider.Value = 0;
    fig.UserData.midSlider.Value = 0;
    fig.UserData.trebleSlider.Value = 0;
    
    % Reset gains
    fig.UserData.bassGain = 0;
    fig.UserData.midGain = 0;
    fig.UserData.trebleGain = 0;
    
    % Reset labels
    fig.UserData.bassLabel.Text = '0.0 dB';
    fig.UserData.midLabel.Text = '0.0 dB';
    fig.UserData.trebleLabel.Text = '0.0 dB';
    
    % Set preset to Flat
    fig.UserData.presetDropdown.Value = 'Flat';
    
    % Process audio
    if ~isempty(fig.UserData.audioData)
        processAudioWithEQ(fig);
        updateVisualization(fig);
    end
    
    fprintf('EQ reset to flat response\n');
end

function updateVisualization(fig)
    if isfield(fig.UserData, 'eqAxes')
        ax = fig.UserData.eqAxes;
        
        % Get current gains (with defaults)
        bassGain = getfield(fig.UserData, 'bassGain', 0);
        midGain = getfield(fig.UserData, 'midGain', 0);
        trebleGain = getfield(fig.UserData, 'trebleGain', 0);
        
        % Create frequency response curve
        f = logspace(1.3, 4.3, 200);
        response = zeros(size(f));
        
        % Apply gains to frequency ranges
        bass_idx = f <= 250;
        mid_idx = f > 250 & f <= 4000;
        treble_idx = f > 4000;
        
        response(bass_idx) = bassGain;
        response(mid_idx) = midGain;  
        response(treble_idx) = trebleGain;
        
        % Smooth transitions
        response = smoothdata(response, 'gaussian', 20);
        
        % Update plot
        cla(ax);
        plot(ax, f, response, 'Color', [0.2 0.8 0.9], 'LineWidth', 3);
        
        % Add zero line
        hold(ax, 'on');
        plot(ax, [20 20000], [0 0], 'w--', 'LineWidth', 1, 'Alpha', 0.5);
        
        % Add frequency band markers
        xline(ax, 250, '--', 'Bass|Mid', 'Color', 'cyan', 'LineWidth', 1.5);
        xline(ax, 4000, '--', 'Mid|Treble', 'Color', 'yellow', 'LineWidth', 1.5);
        
        % Color fill under curve
        if any(response > 0)
            fill(ax, [f fliplr(f)], [max(response, 0) zeros(size(response))], ...
                'g', 'Alpha', 0.2, 'EdgeColor', 'none');
        end
        if any(response < 0)
            fill(ax, [f fliplr(f)], [min(response, 0) zeros(size(response))], ...
                'r', 'Alpha', 0.2, 'EdgeColor', 'none');
        end
    end
end

function playOriginalAudio(fig)
    if ~isempty(fig.UserData.audioData)
        sound(fig.UserData.audioData * 0.7, fig.UserData.fs);
        fprintf('Playing original audio...\n');
    end
end

function playProcessedAudio(fig)
    if ~isempty(fig.UserData.processedAudio)
        sound(fig.UserData.processedAudio * 0.7, fig.UserData.fs);
        fprintf('Playing processed audio...\n');
    end
end

function stopAudio()
    clear sound;
    fprintf('Audio playback stopped.\n');
end

function saveProcessedAudio(fig)
    if ~isempty(fig.UserData.processedAudio)
        [filename, pathname] = uiputfile('*.wav', 'Save Processed Audio');
        if filename ~= 0
            filepath = fullfile(pathname, filename);
            audiowrite(filepath, fig.UserData.processedAudio, fig.UserData.fs);
            fprintf('Processed audio saved: %s\n', filename);
        end
    end
end

function value = getfield(struct, fieldname, defaultValue)
    if isfield(struct, fieldname)
        value = struct.(fieldname);
    else
        value = defaultValue;
    end
end

% Run the complete GUI
step3_final_complete_gui();
