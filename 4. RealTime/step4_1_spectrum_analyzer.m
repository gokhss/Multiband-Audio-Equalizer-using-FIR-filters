% Signal Processing BEVD203L project - Audio Equalizer
function step4_complete_advanced_equalizer()
    fprintf('=== Starting Advanced Audio Equalizer v2.0 ===\n');
    
    % Load filter bank
    try
        load('../Day2_MultiBand/multiband_filters.mat');
        fprintf('✓ Filters loaded successfully\n');
    catch
        uialert([], 'Cannot load filters. Run Day 2 scripts first!', 'Error');
        return;
    end
    
    % Create complete advanced GUI
    fig = createAdvancedGUI();
    
    % Initialize all data
    initializeAdvancedData(fig, h_bass, h_mid, h_treble);
    
end

function initializeAdvancedData(fig, h_bass, h_mid, h_treble)
    % Core audio data
    fig.UserData.audioData = [];
    fig.UserData.processedAudio = [];
    fig.UserData.fs = 44100;
    
    % Filter coefficients
    fig.UserData.h_bass = h_bass;
    fig.UserData.h_mid = h_mid;
    fig.UserData.h_treble = h_treble;
    
    % EQ settings
    fig.UserData.bassGain = 0;
    fig.UserData.midGain = 0;
    fig.UserData.trebleGain = 0;
    
    % System state
    fig.UserData.currentVolume = 0.7;
    fig.UserData.isPlaying = false;
    fig.UserData.realtimeEnabled = true;
    
    fprintf('✓ Data structures initialized\n');
end

function fig = createAdvancedGUI()
    fig = uifigure('Name', 'Audio Equalizer', 'Position', [50 30 1200 900]);
    fig.Color = [0.15 0.15 0.15];
    
    % Main title
    uilabel(fig, 'Position', [450 860 300 30], 'Text', 'BECE203L PROJECT', ...
        'FontSize', 24, 'FontWeight', 'bold', 'FontColor', 'white', ...
        'FontName', 'Arial', 'HorizontalAlignment', 'center');
    
    % Create all panels
    audioPanel = uipanel(fig, 'Position', [20 720 1160 130], ...
        'Title', 'Audio Controls', 'FontSize', 14, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.2 0.2 0.2], 'ForegroundColor', 'white', ...
        'FontName', 'Arial');
    
    eqPanel = uipanel(fig, 'Position', [20 520 1160 190], ...
        'Title', 'Equalizer Controls', 'FontSize', 14, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.2 0.2 0.2], 'ForegroundColor', 'white', ...
        'FontName', 'Arial');
    
    eqVizPanel = uipanel(fig, 'Position', [20 300 580 210], ...
        'Title', 'EQ Frequency Response', 'FontSize', 12, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.2 0.2 0.2], 'ForegroundColor', 'white', ...
        'FontName', 'Arial');
    
    spectrumPanel = uipanel(fig, 'Position', [620 300 560 210], ...
        'Title', 'Live Spectrum Analyzer', 'FontSize', 12, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.2 0.2 0.2], 'ForegroundColor', 'white', ...
        'FontName', 'Arial');
    
    perfPanel = uipanel(fig, 'Position', [20 150 1160 140], ...
        'Title', 'Performance Monitor', 'FontSize', 12, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.2 0.2 0.2], 'ForegroundColor', 'white', ...
        'FontName', 'Arial');
    
    testPanel = uipanel(fig, 'Position', [20 20 1160 120], ...
        'Title', 'Testing & Analysis', 'FontSize', 12, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.2 0.2 0.2], 'ForegroundColor', 'white', ...
        'FontName', 'Arial');
    
    % Create all components
    createAdvancedAudioControls(audioPanel, fig);
    createAdvancedEQControls(eqPanel, fig);
    createEQVisualization(eqVizPanel, fig);
    createSpectrumAnalyzer(spectrumPanel, fig);
    createPerformanceMonitor(perfPanel, fig);
    createTestingControls(testPanel, fig);
end

function createAdvancedAudioControls(panel, fig)
    % File operations
    uibutton(panel, 'Position', [20 70 100 30], 'Text', 'Load Audio', ...
        'FontSize', 10, 'BackgroundColor', [0.3 0.6 0.9], 'FontWeight', 'bold', ...
        'FontName', 'Arial', 'ButtonPushedFcn', @(btn, event) loadAudioFile(fig));
    
    uibutton(panel, 'Position', [140 70 100 30], 'Text', 'Save EQ Audio', ...
        'FontSize', 10, 'BackgroundColor', [0.8 0.2 0.6], 'FontName', 'Arial', ...
        'ButtonPushedFcn', @(btn, event) saveProcessedAudio(fig));
    
    uibutton(panel, 'Position', [260 70 100 30], 'Text', 'Load Handel', ...
        'FontSize', 10, 'BackgroundColor', [0.5 0.5 0.8], 'FontName', 'Arial', ...
        'ButtonPushedFcn', @(btn, event) loadSampleAudio(fig));
    
    % Playback controls
    playOrigBtn = uibutton(panel, 'Position', [20 30 80 30], 'Text', 'Play Original', ...
        'FontSize', 9, 'BackgroundColor', [0.2 0.8 0.2], 'Enable', 'off', ...
        'FontName', 'Arial', 'ButtonPushedFcn', @(btn, event) playOriginalAudio(fig));
    
    playEQBtn = uibutton(panel, 'Position', [110 30 80 30], 'Text', 'Play EQ', ...
        'FontSize', 9, 'BackgroundColor', [0.8 0.6 0.2], 'Enable', 'off', ...
        'FontName', 'Arial', 'ButtonPushedFcn', @(btn, event) playProcessedAudio(fig));
    
    uibutton(panel, 'Position', [200 30 60 30], 'Text', 'Stop', ...
        'FontSize', 9, 'BackgroundColor', [0.8 0.2 0.2], 'FontName', 'Arial', ...
        'ButtonPushedFcn', @(btn, event) stopAudio());
    
    % Volume control
    uilabel(panel, 'Position', [380 80 60 20], 'Text', 'Volume:', ...
        'FontSize', 11, 'FontColor', 'white', 'FontWeight', 'bold', 'FontName', 'Arial');
    
    volumeSlider = uislider(panel, 'Position', [380 60 150 3], 'Limits', [0 1], ...
        'Value', 0.7, 'MajorTicks', [0 0.25 0.5 0.75 1]);
    volumeSlider.ValueChangedFcn = @(slider, event) updateVolume(fig, slider.Value);
    
    volumeLabel = uilabel(panel, 'Position', [380 40 60 20], 'Text', '70%', ...
        'FontSize', 10, 'FontColor', 'white', 'HorizontalAlignment', 'center', ...
        'FontName', 'Arial');
    
    % Audio info display
    infoLabel = uilabel(panel, 'Position', [570 40 570 50], ...
        'Text', 'No audio loaded', 'FontSize', 11, 'FontColor', 'white', ...
        'FontName', 'Arial');
    
    % Store references
    fig.UserData.playOrigBtn = playOrigBtn;
    fig.UserData.playEQBtn = playEQBtn;
    fig.UserData.infoLabel = infoLabel;
    fig.UserData.volumeSlider = volumeSlider;
    fig.UserData.volumeLabel = volumeLabel;
end

function createAdvancedEQControls(panel, fig)
    % Bass Control
    uilabel(panel, 'Position', [80 170 60 20], 'Text', 'BASS', ...
        'FontSize', 14, 'FontWeight', 'bold', 'FontColor', 'cyan', ...
        'HorizontalAlignment', 'center', 'FontName', 'Arial');
    uilabel(panel, 'Position', [65 150 90 20], 'Text', '20-250 Hz', ...
        'FontSize', 10, 'FontColor', 'white', 'HorizontalAlignment', 'center', ...
        'FontName', 'Arial');
    
    bassSlider = uislider(panel, 'Position', [50 130 120 3], 'Limits', [-12 12], ...
        'Value', 0, 'MajorTicks', [-12 -6 0 6 12]);
    bassSlider.ValueChangedFcn = @(slider, event) updateEQ(fig, 'bass', slider.Value);
    
    bassLabel = uilabel(panel, 'Position', [75 110 70 20], 'Text', '0.0 dB', ...
        'FontSize', 11, 'FontColor', 'white', 'HorizontalAlignment', 'center', ...
        'FontName', 'Arial');
    
    % Mid Control
    uilabel(panel, 'Position', [250 170 60 20], 'Text', 'MID', ...
        'FontSize', 14, 'FontWeight', 'bold', 'FontColor', 'yellow', ...
        'HorizontalAlignment', 'center', 'FontName', 'Arial');
    uilabel(panel, 'Position', [235 150 90 20], 'Text', '250-4000 Hz', ...
        'FontSize', 10, 'FontColor', 'white', 'HorizontalAlignment', 'center', ...
        'FontName', 'Arial');
    
    midSlider = uislider(panel, 'Position', [220 130 120 3], 'Limits', [-12 12], ...
        'Value', 0, 'MajorTicks', [-12 -6 0 6 12]);
    midSlider.ValueChangedFcn = @(slider, event) updateEQ(fig, 'mid', slider.Value);
    
    midLabel = uilabel(panel, 'Position', [245 110 70 20], 'Text', '0.0 dB', ...
        'FontSize', 11, 'FontColor', 'white', 'HorizontalAlignment', 'center', ...
        'FontName', 'Arial');
    
    % Treble Control
    uilabel(panel, 'Position', [420 170 60 20], 'Text', 'TREBLE', ...
        'FontSize', 14, 'FontWeight', 'bold', 'FontColor', 'magenta', ...
        'HorizontalAlignment', 'center', 'FontName', 'Arial');
    uilabel(panel, 'Position', [400 150 100 20], 'Text', '4000-20000 Hz', ...
        'FontSize', 10, 'FontColor', 'white', 'HorizontalAlignment', 'center', ...
        'FontName', 'Arial');
    
    trebleSlider = uislider(panel, 'Position', [390 130 120 3], 'Limits', [-12 12], ...
        'Value', 0, 'MajorTicks', [-12 -6 0 6 12]);
    trebleSlider.ValueChangedFcn = @(slider, event) updateEQ(fig, 'treble', slider.Value);
    
    trebleLabel = uilabel(panel, 'Position', [415 110 70 20], 'Text', '0.0 dB', ...
        'FontSize', 11, 'FontColor', 'white', 'HorizontalAlignment', 'center', ...
        'FontName', 'Arial');
    
    % Advanced Presets
    uilabel(panel, 'Position', [580 170 100 20], 'Text', 'EQ Presets:', ...
        'FontSize', 12, 'FontWeight', 'bold', 'FontColor', 'white', 'FontName', 'Arial');
    
    presetDropdown = uidropdown(panel, 'Position', [580 140 150 25], ...
        'Items', {'Custom', 'Flat', 'Pop/Rock', 'Vocal', 'V-Shape', 'Bright', ...
                  'Bass Boost', 'Classical', 'Electronic', 'Jazz', 'Speech'}, ...
        'Value', 'Flat', 'FontSize', 11, 'FontName', 'Arial');
    presetDropdown.ValueChangedFcn = @(dropdown, event) applyAdvancedPreset(fig, dropdown.Value);
    
    % Preset management buttons
    uibutton(panel, 'Position', [750 140 80 25], 'Text', 'Save Preset', ...
        'FontSize', 10, 'BackgroundColor', [0.4 0.8 0.4], 'FontName', 'Arial', ...
        'ButtonPushedFcn', @(btn, event) saveCustomPreset(fig));
    
    uibutton(panel, 'Position', [850 140 80 25], 'Text', 'Load Preset', ...
        'FontSize', 10, 'BackgroundColor', [0.8 0.4 0.4], 'FontName', 'Arial', ...
        'ButtonPushedFcn', @(btn, event) loadCustomPreset(fig));
    
    uibutton(panel, 'Position', [750 110 80 25], 'Text', 'Reset', ...
        'FontSize', 10, 'BackgroundColor', [0.6 0.6 0.6], 'FontName', 'Arial', ...
        'ButtonPushedFcn', @(btn, event) resetEQ(fig));
    
    % Store references
    fig.UserData.bassSlider = bassSlider;
    fig.UserData.midSlider = midSlider;
    fig.UserData.trebleSlider = trebleSlider;
    fig.UserData.bassLabel = bassLabel;
    fig.UserData.midLabel = midLabel;
    fig.UserData.trebleLabel = trebleLabel;
    fig.UserData.presetDropdown = presetDropdown;
end

function createEQVisualization(panel, fig)
    ax = uiaxes(panel, 'Position', [20 20 540 170]);
    ax.BackgroundColor = [0.1 0.1 0.1];
    ax.XColor = 'white';
    ax.YColor = 'white';
    ax.GridColor = [0.3 0.3 0.3];
    ax.FontName = 'Arial';
    ax.FontSize = 10;
    
    f = logspace(1.3, 4.3, 200);
    plot(ax, f, zeros(size(f)), 'w-', 'LineWidth', 3);
    ax.XScale = 'log';
    ax.XLim = [20 20000];
    ax.YLim = [-15 15];
    ax.XLabel.String = 'Frequency (Hz)';
    ax.YLabel.String = 'Gain (dB)';
    ax.Title.String = 'EQ Response';
    ax.Title.Color = 'white';
    grid(ax, 'on');
    
    hold(ax, 'on');
    xline(ax, 250, '--', 'Color', 'cyan', 'LineWidth', 1.5);
    xline(ax, 4000, '--', 'Color', 'yellow', 'LineWidth', 1.5);
    
    fig.UserData.eqAxes = ax;
end

function createSpectrumAnalyzer(panel, fig)
    ax = uiaxes(panel, 'Position', [20 20 520 170]);
    ax.BackgroundColor = [0.05 0.05 0.05];
    ax.XColor = 'white';
    ax.YColor = 'white';
    ax.GridColor = [0.3 0.3 0.3];
    ax.FontName = 'Arial';
    ax.FontSize = 10;
    
    f_spectrum = linspace(20, 20000, 256);
    spectrum_data = -80 * ones(size(f_spectrum));
    
    bar(ax, f_spectrum, spectrum_data, 'FaceColor', [0.2 0.8 0.9], 'EdgeColor', 'none');
    ax.XScale = 'log';
    ax.XLim = [20 20000];
    ax.YLim = [-80 0];
    ax.XLabel.String = 'Frequency (Hz)';
    ax.YLabel.String = 'Magnitude (dB)';
    ax.Title.String = 'Live Spectrum';
    ax.Title.Color = 'white';
    grid(ax, 'on');
    
    hold(ax, 'on');
    xline(ax, 250, '--', 'Color', 'cyan', 'LineWidth', 1);
    xline(ax, 4000, '--', 'Color', 'yellow', 'LineWidth', 1);
    
    fig.UserData.spectrumAxes = ax;
end

function createPerformanceMonitor(panel, fig)
    % Performance displays
    uilabel(panel, 'Position', [20 90 120 20], 'Text', 'Processing Time:', ...
        'FontSize', 11, 'FontColor', 'white', 'FontWeight', 'bold', 'FontName', 'Arial');
    
    processingLabel = uilabel(panel, 'Position', [20 70 120 20], 'Text', '0.000 ms', ...
        'FontSize', 11, 'FontColor', 'cyan', 'FontName', 'Arial');
    
    uilabel(panel, 'Position', [180 90 100 20], 'Text', 'Memory Usage:', ...
        'FontSize', 11, 'FontColor', 'white', 'FontWeight', 'bold', 'FontName', 'Arial');
    
    memoryLabel = uilabel(panel, 'Position', [180 70 100 20], 'Text', '0 MB', ...
        'FontSize', 11, 'FontColor', 'yellow', 'FontName', 'Arial');
    
    uilabel(panel, 'Position', [320 90 80 20], 'Text', 'CPU Load:', ...
        'FontSize', 11, 'FontColor', 'white', 'FontWeight', 'bold', 'FontName', 'Arial');
    
    cpuLabel = uilabel(panel, 'Position', [320 70 80 20], 'Text', 'Low', ...
        'FontSize', 11, 'FontColor', 'green', 'FontName', 'Arial');
    
    uilabel(panel, 'Position', [440 90 100 20], 'Text', 'Audio Quality:', ...
        'FontSize', 11, 'FontColor', 'white', 'FontWeight', 'bold', 'FontName', 'Arial');
    
    qualityLabel = uilabel(panel, 'Position', [440 70 100 20], 'Text', 'Good', ...
        'FontSize', 11, 'FontColor', 'green', 'FontName', 'Arial');
    
    realtimeToggle = uicheckbox(panel, 'Position', [580 75 150 20], ...
        'Text', 'Real-time Updates', 'FontColor', 'white', 'Value', true, 'FontName', 'Arial');
    realtimeToggle.ValueChangedFcn = @(cb, event) toggleRealTimeUpdates(fig, cb.Value);
    
    % Store references
    fig.UserData.processingLabel = processingLabel;
    fig.UserData.memoryLabel = memoryLabel;
    fig.UserData.cpuLabel = cpuLabel;
    fig.UserData.qualityLabel = qualityLabel;
    fig.UserData.realtimeToggle = realtimeToggle;
end

function createTestingControls(panel, fig)
    % Test signal generators
    uibutton(panel, 'Position', [20 50 100 25], 'Text', 'Sine Wave', ...
        'FontSize', 10, 'BackgroundColor', [0.6 0.4 0.8], 'FontName', 'Arial', ...
        'ButtonPushedFcn', @(btn, event) generateTestSignal(fig, 'sine'));
    
    uibutton(panel, 'Position', [140 50 100 25], 'Text', 'White Noise', ...
        'FontSize', 10, 'BackgroundColor', [0.6 0.4 0.8], 'FontName', 'Arial', ...
        'ButtonPushedFcn', @(btn, event) generateTestSignal(fig, 'noise'));
    
    uibutton(panel, 'Position', [260 50 100 25], 'Text', 'Freq Sweep', ...
        'FontSize', 10, 'BackgroundColor', [0.6 0.4 0.8], 'FontName', 'Arial', ...
        'ButtonPushedFcn', @(btn, event) generateTestSignal(fig, 'sweep'));
    
    % Analysis tools
    uibutton(panel, 'Position', [380 50 100 25], 'Text', 'THD Analysis', ...
        'FontSize', 10, 'BackgroundColor', [0.8 0.6 0.4], 'FontName', 'Arial', ...
        'ButtonPushedFcn', @(btn, event) analyzeTHD(fig));
    
    uibutton(panel, 'Position', [500 50 100 25], 'Text', 'Filter Test', ...
        'FontSize', 10, 'BackgroundColor', [0.8 0.6 0.4], 'FontName', 'Arial', ...
        'ButtonPushedFcn', @(btn, event) testFilterResponse(fig));
    
    uibutton(panel, 'Position', [620 50 100 25], 'Text', 'Export Report', ...
        'FontSize', 10, 'BackgroundColor', [0.4 0.8 0.6], 'FontName', 'Arial', ...
        'ButtonPushedFcn', @(btn, event) exportTestReport(fig));
    
    % Test results display
    uilabel(panel, 'Position', [20 20 80 20], 'Text', 'Test Results:', ...
        'FontSize', 10, 'FontColor', 'white', 'FontWeight', 'bold', 'FontName', 'Arial');
    
    testResultsLabel = uilabel(panel, 'Position', [100 20 700 20], ...
        'Text', 'Ready for testing...', 'FontSize', 10, 'FontColor', 'cyan', ...
        'FontName', 'Arial');
    
    fig.UserData.testResultsLabel = testResultsLabel;
end

% Audio Processing Functions
function loadSampleAudio(fig)
    try
        load handel;
        fig.UserData.audioData = y / max(abs(y));
        fig.UserData.fs = Fs;
        fig.UserData.infoLabel.Text = sprintf('Loaded: Handel Sample | Duration: %.2f sec', length(y)/Fs);
        fig.UserData.playOrigBtn.Enable = 'on';
        processAudioWithEQ(fig);
        updatePerformanceMonitor(fig);
    catch ME
        uialert(fig, sprintf('Error loading sample: %s', ME.message), 'Error');
    end
end

function loadAudioFile(fig)
    [filename, pathname] = uigetfile({'*.wav;*.mp3;*.m4a', 'Audio Files'}, 'Select Audio File');
    
    if filename ~= 0
        try
            filepath = fullfile(pathname, filename);
            [audioData, fs] = audioread(filepath);
            
            if size(audioData, 2) > 1
                audioData = audioData(:, 1);
            end
            
            audioData = audioData / max(abs(audioData));
            fig.UserData.audioData = audioData;
            fig.UserData.fs = fs;
            
            duration = length(audioData) / fs;
            fig.UserData.infoLabel.Text = sprintf('Loaded: %s | Duration: %.2f sec | %d Hz', ...
                filename, duration, fs);
            fig.UserData.playOrigBtn.Enable = 'on';
            
            processAudioWithEQ(fig);
            updatePerformanceMonitor(fig);
            
        catch ME
            uialert(fig, sprintf('Error loading audio: %s', ME.message), 'Error');
        end
    end
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
    
    fig.UserData.presetDropdown.Value = 'Custom';
    
    if ~isempty(fig.UserData.audioData)
        processAudioWithEQ(fig);
        updateEQVisualization(fig);
        updatePerformanceMonitor(fig);
    end
end

function processAudioWithEQ(fig)
    if isempty(fig.UserData.audioData)
        return;
    end
    
    % Get gains with defaults
    bassGain = getFieldOrDefault(fig.UserData, 'bassGain', 0);
    midGain = getFieldOrDefault(fig.UserData, 'midGain', 0);
    trebleGain = getFieldOrDefault(fig.UserData, 'trebleGain', 0);
    
    gains_linear = 10.^([bassGain midGain trebleGain]/20);
    
    bass_out = gains_linear(1) * filter(fig.UserData.h_bass, 1, fig.UserData.audioData);
    mid_out = gains_linear(2) * filter(fig.UserData.h_mid, 1, fig.UserData.audioData);
    treble_out = gains_linear(3) * filter(fig.UserData.h_treble, 1, fig.UserData.audioData);
    
    fig.UserData.processedAudio = bass_out + mid_out + treble_out;
    fig.UserData.playEQBtn.Enable = 'on';
end

% FIXED FUNCTION: Changed 'Alpha' to 'FaceAlpha'
function updateEQVisualization(fig)
    if isfield(fig.UserData, 'eqAxes')
        ax = fig.UserData.eqAxes;
        
        bassGain = getFieldOrDefault(fig.UserData, 'bassGain', 0);
        midGain = getFieldOrDefault(fig.UserData, 'midGain', 0);
        trebleGain = getFieldOrDefault(fig.UserData, 'trebleGain', 0);
        
        f = logspace(1.3, 4.3, 200);
        response = zeros(size(f));
        
        bass_idx = f <= 250;
        mid_idx = f > 250 & f <= 4000;
        treble_idx = f > 4000;
        
        response(bass_idx) = bassGain;
        response(mid_idx) = midGain;
        response(treble_idx) = trebleGain;
        
        response = smoothdata(response, 'gaussian', 20);
        
        cla(ax);
        plot(ax, f, response, 'Color', [0.2 0.8 0.9], 'LineWidth', 3);
        hold(ax, 'on');
        plot(ax, [20 20000], [0 0], 'w--', 'LineWidth', 1);
        xline(ax, 250, '--', 'Color', 'cyan', 'LineWidth', 1.5);
        xline(ax, 4000, '--', 'Color', 'yellow', 'LineWidth', 1.5);
        
        % FIXED: Changed 'Alpha' to 'FaceAlpha'
        if any(response > 0)
            fill(ax, [f fliplr(f)], [max(response, 0) zeros(size(response))], ...
                'g', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
        end
        if any(response < 0)
            fill(ax, [f fliplr(f)], [min(response, 0) zeros(size(response))], ...
                'r', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
        end
    end
end

function updateSpectrumAnalyzer(fig)
    if fig.UserData.realtimeToggle.Value && ~isempty(fig.UserData.processedAudio)
        try
            audioData = fig.UserData.processedAudio;
            fs = fig.UserData.fs;
            
            N_fft = 512;
            if length(audioData) >= N_fft
                window = hamming(N_fft);
                audio_segment = audioData(1:N_fft) .* window;
                Y = fft(audio_segment, N_fft);
                
                magnitude = 20*log10(abs(Y(1:N_fft/2)) + eps);
                f = (0:N_fft/2-1) * fs / N_fft;
                
                ax = fig.UserData.spectrumAxes;
                cla(ax);
                bar(ax, f, magnitude, 'FaceColor', [0.2 0.8 0.9], 'EdgeColor', 'none');
                
                ax.XScale = 'log';
                ax.XLim = [20 20000];
                ax.YLim = [-80 0];
                grid(ax, 'on');
                
                hold(ax, 'on');
                xline(ax, 250, '--', 'Color', 'cyan', 'LineWidth', 1);
                xline(ax, 4000, '--', 'Color', 'yellow', 'LineWidth', 1);
            end
        catch ME
            fprintf('Spectrum analyzer error: %s\n', ME.message);
        end
    end
end

function updatePerformanceMonitor(fig)
    try
        tic;
        if ~isempty(fig.UserData.audioData)
            processAudioWithEQ(fig);
        end
        processingTime = toc * 1000;
        
        fig.UserData.processingLabel.Text = sprintf('%.3f ms', processingTime);
        
        audioSize = numel(fig.UserData.audioData) * 8 / 1024 / 1024;
        fig.UserData.memoryLabel.Text = sprintf('%.1f MB', audioSize);
        
        if processingTime < 10
            fig.UserData.cpuLabel.Text = 'Low';
            fig.UserData.cpuLabel.FontColor = 'green';
        elseif processingTime < 50
            fig.UserData.cpuLabel.Text = 'Medium';
            fig.UserData.cpuLabel.FontColor = 'yellow';
        else
            fig.UserData.cpuLabel.Text = 'High';
            fig.UserData.cpuLabel.FontColor = 'red';
        end
        
        updateSpectrumAnalyzer(fig);
    catch ME
        fprintf('Performance monitor error: %s\n', ME.message);
    end
end

% Advanced Preset Management
function applyAdvancedPreset(fig, presetName)
    presets = containers.Map({...
        'Flat', 'Pop/Rock', 'Vocal', 'V-Shape', 'Bright', 'Bass Boost', ...
        'Classical', 'Electronic', 'Jazz', 'Speech'}, {...
        [0 0 0], [6 -2 3], [-3 4 2], [8 -4 6], [-6 0 8], [8 0 0], ...
        [3 2 4], [4 0 8], [4 2 -2], [-6 6 -3]});
    
    if strcmp(presetName, 'Custom')
        return;
    end
    
    if isKey(presets, presetName)
        gains = presets(presetName);
        
        fig.UserData.bassSlider.Value = gains(1);
        fig.UserData.midSlider.Value = gains(2);
        fig.UserData.trebleSlider.Value = gains(3);
        
        fig.UserData.bassGain = gains(1);
        fig.UserData.midGain = gains(2);
        fig.UserData.trebleGain = gains(3);
        
        fig.UserData.bassLabel.Text = sprintf('%.1f dB', gains(1));
        fig.UserData.midLabel.Text = sprintf('%.1f dB', gains(2));
        fig.UserData.trebleLabel.Text = sprintf('%.1f dB', gains(3));
        
        if ~isempty(fig.UserData.audioData)
            processAudioWithEQ(fig);
            updateEQVisualization(fig);
            updatePerformanceMonitor(fig);
        end
        
        fprintf('Applied preset: %s\n', presetName);
    end
end

function saveCustomPreset(fig)
    bassGain = getFieldOrDefault(fig.UserData, 'bassGain', 0);
    midGain = getFieldOrDefault(fig.UserData, 'midGain', 0);
    trebleGain = getFieldOrDefault(fig.UserData, 'trebleGain', 0);
    
    answer = inputdlg('Enter preset name:', 'Save Custom Preset', 1, {'My Preset'});
    
    if ~isempty(answer)
        presetName = answer{1};
        customPresets = [];
        presetFile = 'custom_presets.mat';
        
        if exist(presetFile, 'file')
            load(presetFile, 'customPresets');
        end
        
        customPresets.(matlab.lang.makeValidName(presetName)) = [bassGain midGain trebleGain];
        save(presetFile, 'customPresets');
        
        fig.UserData.testResultsLabel.Text = sprintf('Saved preset: %s', presetName);
    end
end

function loadCustomPreset(fig)
    presetFile = 'custom_presets.mat';
    
    if exist(presetFile, 'file')
        load(presetFile, 'customPresets');
        presetNames = fieldnames(customPresets);
        
        if ~isempty(presetNames)
            [selection, ok] = listdlg('PromptString', 'Select preset to load:', ...
                'SelectionMode', 'single', 'ListString', presetNames);
            
            if ok
                selectedPreset = presetNames{selection};
                gains = customPresets.(selectedPreset);
                
                fig.UserData.bassSlider.Value = gains(1);
                fig.UserData.midSlider.Value = gains(2);
                fig.UserData.trebleSlider.Value = gains(3);
                
                fig.UserData.bassGain = gains(1);
                fig.UserData.midGain = gains(2);
                fig.UserData.trebleGain = gains(3);
                
                fig.UserData.bassLabel.Text = sprintf('%.1f dB', gains(1));
                fig.UserData.midLabel.Text = sprintf('%.1f dB', gains(2));
                fig.UserData.trebleLabel.Text = sprintf('%.1f dB', gains(3));
                
                fig.UserData.presetDropdown.Value = 'Custom';
                
                if ~isempty(fig.UserData.audioData)
                    processAudioWithEQ(fig);
                    updateEQVisualization(fig);
                end
            end
        else
            uialert(fig, 'No custom presets found!', 'Load Preset');
        end
    else
        uialert(fig, 'No custom presets file found!', 'Load Preset');
    end
end

function resetEQ(fig)
    fig.UserData.bassSlider.Value = 0;
    fig.UserData.midSlider.Value = 0;
    fig.UserData.trebleSlider.Value = 0;
    
    fig.UserData.bassGain = 0;
    fig.UserData.midGain = 0;
    fig.UserData.trebleGain = 0;
    
    fig.UserData.bassLabel.Text = '0.0 dB';
    fig.UserData.midLabel.Text = '0.0 dB';
    fig.UserData.trebleLabel.Text = '0.0 dB';
    
    fig.UserData.presetDropdown.Value = 'Flat';
    
    if ~isempty(fig.UserData.audioData)
        processAudioWithEQ(fig);
        updateEQVisualization(fig);
    end
end

% Testing Functions
function generateTestSignal(fig, signalType)
    fs = fig.UserData.fs;
    duration = 5;
    t = (0:1/fs:duration-1/fs)';
    
    switch signalType
        case 'sine'
            signal = sin(2*pi*1000*t);
            fig.UserData.testResultsLabel.Text = 'Generated 1kHz sine wave';
        case 'noise'
            signal = 0.1 * randn(size(t));
            fig.UserData.testResultsLabel.Text = 'Generated white noise';
        case 'sweep'
            signal = chirp(t, 20, duration, 20000, 'logarithmic');
            fig.UserData.testResultsLabel.Text = 'Generated frequency sweep';
    end
    
    fig.UserData.audioData = signal / max(abs(signal));
    fig.UserData.infoLabel.Text = sprintf('Test Signal: %s', signalType);
    fig.UserData.playOrigBtn.Enable = 'on';
    
    processAudioWithEQ(fig);
    updatePerformanceMonitor(fig);
end

function analyzeTHD(fig)
    if isempty(fig.UserData.audioData)
        fig.UserData.testResultsLabel.Text = 'No audio for THD analysis';
        return;
    end
    
    try
        fs = fig.UserData.fs;
        duration = 2;
        t = (0:1/fs:duration-1/fs)';
        f0 = 1000;
        
        input_signal = sin(2*pi*f0*t);
        fig.UserData.audioData = input_signal;
        
        processAudioWithEQ(fig);
        output_signal = fig.UserData.processedAudio;
        
        N_fft = 2048;
        if length(output_signal) >= N_fft
            Y = fft(output_signal(1:N_fft), N_fft);
            f = (0:N_fft/2-1) * fs / N_fft;
            magnitude = abs(Y(1:N_fft/2));
            
            [~, fund_idx] = min(abs(f - f0));
            fund_power = magnitude(fund_idx)^2;
            
            harmonic_power = 0;
            for h = 2:5
                [~, harm_idx] = min(abs(f - h*f0));
                if harm_idx <= length(magnitude)
                    harmonic_power = harmonic_power + magnitude(harm_idx)^2;
                end
            end
            
            thd_percent = sqrt(harmonic_power / fund_power) * 100;
            
            fig.UserData.testResultsLabel.Text = sprintf('THD: %.3f%%', thd_percent);
            
            if thd_percent < 0.1
                fig.UserData.qualityLabel.Text = 'Excellent';
                fig.UserData.qualityLabel.FontColor = 'green';
            elseif thd_percent < 1
                fig.UserData.qualityLabel.Text = 'Good';
                fig.UserData.qualityLabel.FontColor = 'yellow';
            else
                fig.UserData.qualityLabel.Text = 'Poor';
                fig.UserData.qualityLabel.FontColor = 'red';
            end
        end
    catch ME
        fig.UserData.testResultsLabel.Text = sprintf('THD Error: %s', ME.message);
    end
end

function testFilterResponse(fig)
    try
        fs = fig.UserData.fs;
        test_freqs = [50, 100, 250, 1000, 4000, 8000, 16000];
        results = zeros(size(test_freqs));
        
        for i = 1:length(test_freqs)
            freq = test_freqs(i);
            t = (0:1/fs:1-1/fs)';
            test_signal = sin(2*pi*freq*t);
            
            gains = 10.^([fig.UserData.bassGain fig.UserData.midGain fig.UserData.trebleGain]/20);
            
            bass_out = gains(1) * filter(fig.UserData.h_bass, 1, test_signal);
            mid_out = gains(2) * filter(fig.UserData.h_mid, 1, test_signal);
            treble_out = gains(3) * filter(fig.UserData.h_treble, 1, test_signal);
            
            filtered_signal = bass_out + mid_out + treble_out;
            
            gain_db = 20 * log10(rms(filtered_signal) / rms(test_signal));
            results(i) = gain_db;
        end
        
        result_str = '';
        for i = 1:length(test_freqs)
            result_str = [result_str sprintf('%dHz:%.1fdB ', test_freqs(i), results(i))];
        end
        
        fig.UserData.testResultsLabel.Text = result_str;
    catch ME
        fig.UserData.testResultsLabel.Text = sprintf('Filter Test Error: %s', ME.message);
    end
end

function exportTestReport(fig)
    try
        report = {};
        report{end+1} = '=== Audio Equalizer Test Report ===';
        report{end+1} = sprintf('Generated on: %s', datestr(now));
        report{end+1} = '';
        report{end+1} = '--- System Configuration ---';
        report{end+1} = sprintf('Sample Rate: %d Hz', fig.UserData.fs);
        report{end+1} = '';
        report{end+1} = '--- Current EQ Settings ---';
        report{end+1} = sprintf('Bass Gain: %.1f dB', getFieldOrDefault(fig.UserData, 'bassGain', 0));
        report{end+1} = sprintf('Mid Gain: %.1f dB', getFieldOrDefault(fig.UserData, 'midGain', 0));
        report{end+1} = sprintf('Treble Gain: %.1f dB', getFieldOrDefault(fig.UserData, 'trebleGain', 0));
        report{end+1} = '';
        report{end+1} = '--- Performance Metrics ---';
        report{end+1} = sprintf('Processing Time: %s', fig.UserData.processingLabel.Text);
        report{end+1} = sprintf('Memory Usage: %s', fig.UserData.memoryLabel.Text);
        report{end+1} = sprintf('CPU Load: %s', fig.UserData.cpuLabel.Text);
        
        reportFile = sprintf('EQ_Test_Report_%s.txt', datestr(now, 'yyyymmdd_HHMMSS'));
        fid = fopen(reportFile, 'w');
        for i = 1:length(report)
            fprintf(fid, '%s\n', report{i});
        end
        fclose(fid);
        
        fig.UserData.testResultsLabel.Text = sprintf('Report saved: %s', reportFile);
    catch ME
        fig.UserData.testResultsLabel.Text = sprintf('Export Error: %s', ME.message);
    end
end

% Utility Functions
function playOriginalAudio(fig)
    if ~isempty(fig.UserData.audioData)
        volume = getFieldOrDefault(fig.UserData, 'currentVolume', 0.7);
        sound(fig.UserData.audioData * volume, fig.UserData.fs);
    end
end

function playProcessedAudio(fig)
    if ~isempty(fig.UserData.processedAudio)
        volume = getFieldOrDefault(fig.UserData, 'currentVolume', 0.7);
        sound(fig.UserData.processedAudio * volume, fig.UserData.fs);
    end
end

function stopAudio()
    clear sound;
end

function saveProcessedAudio(fig)
    if ~isempty(fig.UserData.processedAudio)
        [filename, pathname] = uiputfile('*.wav', 'Save Processed Audio');
        if filename ~= 0
            filepath = fullfile(pathname, filename);
            audiowrite(filepath, fig.UserData.processedAudio, fig.UserData.fs);
            fig.UserData.testResultsLabel.Text = sprintf('Audio saved: %s', filename);
        end
    end
end

function updateVolume(fig, value)
    fig.UserData.currentVolume = value;
    fig.UserData.volumeLabel.Text = sprintf('%.0f%%', value*100);
end

function toggleRealTimeUpdates(fig, enabled)
    fig.UserData.realtimeEnabled = enabled;
    if enabled
        updatePerformanceMonitor(fig);
    end
end

function value = getFieldOrDefault(struct, fieldname, defaultValue)
    if isfield(struct, fieldname)
        value = struct.(fieldname);
    else
        value = defaultValue;
    end
end

% Run the complete application
step4_complete_advanced_equalizer();
