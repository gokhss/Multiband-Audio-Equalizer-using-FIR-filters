%% Complete Audio Equalizer GUI - Day 3 Final (FIXED)
function complete_audio_equalizer_gui()  % Fixed function name
    % Load filter bank
    try
        load('../Day2_MultiBand/multiband_filters.mat');
    catch
        uialert([], 'Cannot load filters. Run Day 2 scripts first!', 'Error');
        return;
    end
    
    % Create main GUI
    fig = createCompleteGUI();
    
    % Initialize data
    fig.UserData.audioData = [];
    fig.UserData.processedAudio = [];
    fig.UserData.fs = 44100;
    fig.UserData.h_bass = h_bass;
    fig.UserData.h_mid = h_mid;
    fig.UserData.h_treble = h_treble;
    fig.UserData.bassGain = 0;
    fig.UserData.midGain = 0;
    fig.UserData.trebleGain = 0;
    
    fprintf('=== Audio Equalizer GUI Ready! ===\n');
end

function fig = createCompleteGUI()
    fig = uifigure('Name', 'Audio Equalizer - Complete', 'Position', [100 50 920 750]);
    fig.Color = [0.15 0.15 0.15];
    
    % Title
    uilabel(fig, 'Position', [310 710 300 25], 'Text', 'Audio Equalizer v1.0', ...
        'FontSize', 20, 'FontWeight', 'bold', 'FontColor', 'white', ...
        'HorizontalAlignment', 'center');
    
    % Create panels
    audioPanel = uipanel(fig, 'Position', [20 500 880 140], ...
        'Title', 'Audio Controls', 'FontSize', 14, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.2 0.2 0.2], 'ForegroundColor', 'white');
    
    eqPanel = uipanel(fig, 'Position', [20 280 880 210], ...
        'Title', 'Equalizer Controls', 'FontSize', 14, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.2 0.2 0.2], 'ForegroundColor', 'white');
    
    vizPanel = uipanel(fig, 'Position', [20 20 880 250], ...
        'Title', 'Audio Visualization', 'FontSize', 14, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.2 0.2 0.2], 'ForegroundColor', 'white');
    
    % CORRECT function calls
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
    
    % Sample Audio Button
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
    
    bassSlider = uislider(panel, 'Position', [50 130 120 3], 'Limits', [-12 12], ...
        'Value', 0, 'MajorTicks', [-12 -6 0 6 12]);
    bassSlider.ValueChangedFcn = @(slider, event) updateEQ(fig, 'bass', slider.Value);
    
    bassLabel = uilabel(panel, 'Position', [75 110 70 20], 'Text', '0.0 dB', ...
        'FontSize', 11, 'FontColor', 'white', 'HorizontalAlignment', 'center');
    
    % Mid Control
    uilabel(panel, 'Position', [250 170 60 20], 'Text', 'MID', ...
        'FontSize', 14, 'FontWeight', 'bold', 'FontColor', 'yellow', ...
        'HorizontalAlignment', 'center');
    
    midSlider = uislider(panel, 'Position', [220 130 120 3], 'Limits', [-12 12], ...
        'Value', 0, 'MajorTicks', [-12 -6 0 6 12]);
    midSlider.ValueChangedFcn = @(slider, event) updateEQ(fig, 'mid', slider.Value);
    
    midLabel = uilabel(panel, 'Position', [245 110 70 20], 'Text', '0.0 dB', ...
        'FontSize', 11, 'FontColor', 'white', 'HorizontalAlignment', 'center');
    
    % Treble Control
    uilabel(panel, 'Position', [420 170 60 20], 'Text', 'TREBLE', ...
        'FontSize', 14, 'FontWeight', 'bold', 'FontColor', 'magenta', ...
        'HorizontalAlignment', 'center');
    
    trebleSlider = uislider(panel, 'Position', [390 130 120 3], 'Limits', [-12 12], ...
        'Value', 0, 'MajorTicks', [-12 -6 0 6 12]);
    trebleSlider.ValueChangedFcn = @(slider, event) updateEQ(fig, 'treble', slider.Value);
    
    trebleLabel = uilabel(panel, 'Position', [415 110 70 20], 'Text', '0.0 dB', ...
        'FontSize', 11, 'FontColor', 'white', 'HorizontalAlignment', 'center');
    
    % EQ Presets
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
    ax = uiaxes(panel, 'Position', [30 20 820 200]);
    ax.BackgroundColor = [0.1 0.1 0.1];
    ax.XColor = 'white';
    ax.YColor = 'white';
    
    f = logspace(1.3, 4.3, 200);
    plot(ax, f, zeros(size(f)), 'w-', 'LineWidth', 3);
    ax.XScale = 'log';
    ax.XLim = [20 20000];
    ax.YLim = [-15 15];
    ax.XLabel.String = 'Frequency (Hz)';
    ax.YLabel.String = 'Gain (dB)';
    ax.Title.String = 'EQ Frequency Response';
    ax.Title.Color = 'white';
    grid(ax, 'on');
    
    fig.UserData.eqAxes = ax;
end

% Audio Functions
function loadSampleAudio(fig)
    load handel;
    fig.UserData.audioData = y / max(abs(y));
    fig.UserData.fs = Fs;
    fig.UserData.infoLabel.Text = 'Loaded: Handel Sample';
    fig.UserData.playOrigBtn.Enable = 'on';
    processAudioWithEQ(fig);
end

function updateEQ(fig, band, value)
    switch band
        case 'bass'
            fig.UserData.bassGain = value;
            fig.UserData.bassLabel.Text = sprintf('%.1f dB', value);
        case 'mid'
            fig.UserData.midGain = value;
            fig.UserData.midLabel.Text = sprintf('%.1f dB', value);
        case 'treble'
            fig.UserData.trebleGain = value;
            fig.UserData.trebleLabel.Text = sprintf('%.1f dB', value);
    end
    
    if ~isempty(fig.UserData.audioData)
        processAudioWithEQ(fig);
    end
end

function processAudioWithEQ(fig)
    if isempty(fig.UserData.audioData), return; end
    
    gains = 10.^([fig.UserData.bassGain fig.UserData.midGain fig.UserData.trebleGain]/20);
    
    bass_out = gains(1) * filter(fig.UserData.h_bass, 1, fig.UserData.audioData);
    mid_out = gains(2) * filter(fig.UserData.h_mid, 1, fig.UserData.audioData);
    treble_out = gains(3) * filter(fig.UserData.h_treble, 1, fig.UserData.audioData);
    
    fig.UserData.processedAudio = bass_out + mid_out + treble_out;
    fig.UserData.playEQBtn.Enable = 'on';
    fig.UserData.saveBtn.Enable = 'on';
end

function playOriginalAudio(fig)
    if ~isempty(fig.UserData.audioData)
        sound(fig.UserData.audioData * 0.7, fig.UserData.fs);
    end
end

function playProcessedAudio(fig)
    if ~isempty(fig.UserData.processedAudio)
        sound(fig.UserData.processedAudio * 0.7, fig.UserData.fs);
    end
end

function stopAudio()
    clear sound;
end

% Placeholder implementations for other functions  
function loadAudioFile(fig), end
function applyPreset(fig, preset), end  
function resetEQ(fig), end
function saveProcessedAudio(fig), end

% NO FUNCTION CALL AT THE END - Let MATLAB run it automatically

