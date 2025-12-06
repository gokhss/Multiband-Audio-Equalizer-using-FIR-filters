%% Step 3.1: Basic Audio Equalizer GUI Layout
function step3_1basic_gui()
    % Create main figure window
    fig = uifigure('Name', 'Audio Equalizer', 'Position', [100 100 800 600]);
    fig.Color = [0.15 0.15 0.15]; % Dark theme
    
    % Title
    uilabel(fig, 'Position', [300 550 200 30], 'Text', 'Audio Equalizer', ...
        'FontSize', 20, 'FontWeight', 'bold', 'FontColor', 'white', ...
        'HorizontalAlignment', 'center');
    
    % Create main panels
    createMainPanels(fig);
    fprintf('Basic GUI window created successfully!\n');
end

function createMainPanels(fig)
    % Audio Control Panel
    audioPanel = uipanel(fig, 'Position', [20 400 760 140], ...
        'Title', 'Audio Controls', 'FontSize', 14, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.2 0.2 0.2], 'ForegroundColor', 'white');
    
    % EQ Control Panel  
    eqPanel = uipanel(fig, 'Position', [20 200 760 190], ...
        'Title', 'Equalizer Controls', 'FontSize', 14, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.2 0.2 0.2], 'ForegroundColor', 'white');
    
    % Visualization Panel
    vizPanel = uipanel(fig, 'Position', [20 20 760 170], ...
        'Title', 'Audio Visualization', 'FontSize', 14, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.2 0.2 0.2], 'ForegroundColor', 'white');
    
    % Add placeholder components
    addAudioControls(audioPanel);
    addEQControls(eqPanel);
    addVisualization(vizPanel);
end

function addAudioControls(panel)
    % Load Audio Button
    uibutton(panel, 'Position', [20 80 120 30], 'Text', 'Load Audio', ...
        'FontSize', 12, 'BackgroundColor', [0.3 0.6 0.9]);
    
    % Play/Stop Buttons
    uibutton(panel, 'Position', [160 80 80 30], 'Text', 'Play Original', ...
        'FontSize', 10, 'BackgroundColor', [0.2 0.8 0.2]);
    
    uibutton(panel, 'Position', [250 80 80 30], 'Text', 'Play EQ', ...
        'FontSize', 10, 'BackgroundColor', [0.8 0.6 0.2]);
    
    % Save Button
    uibutton(panel, 'Position', [350 80 100 30], 'Text', 'Save EQ Audio', ...
        'FontSize', 10, 'BackgroundColor', [0.8 0.2 0.6]);
    
    % Audio Info Display
    uilabel(panel, 'Position', [20 40 400 25], 'Text', 'No audio loaded', ...
        'FontSize', 11, 'FontColor', 'white');
end

function addEQControls(panel)
    % Bass Control
    uilabel(panel, 'Position', [50 140 50 20], 'Text', 'BASS', ...
        'FontSize', 12, 'FontWeight', 'bold', 'FontColor', 'cyan', ...
        'HorizontalAlignment', 'center');
    
    uislider(panel, 'Position', [20 120 110 3], 'Limits', [-12 12], ...
        'Value', 0, 'MajorTicks', [-12 -6 0 6 12]);
    
    uilabel(panel, 'Position', [45 100 60 20], 'Text', '0.0 dB', ...
        'FontSize', 10, 'FontColor', 'white', 'HorizontalAlignment', 'center');
    
    % Mid Control
    uilabel(panel, 'Position', [200 140 50 20], 'Text', 'MID', ...
        'FontSize', 12, 'FontWeight', 'bold', 'FontColor', 'yellow', ...
        'HorizontalAlignment', 'center');
    
    uislider(panel, 'Position', [170 120 110 3], 'Limits', [-12 12], ...
        'Value', 0, 'MajorTicks', [-12 -6 0 6 12]);
    
    uilabel(panel, 'Position', [195 100 60 20], 'Text', '0.0 dB', ...
        'FontSize', 10, 'FontColor', 'white', 'HorizontalAlignment', 'center');
    
    % Treble Control
    uilabel(panel, 'Position', [350 140 50 20], 'Text', 'TREBLE', ...
        'FontSize', 12, 'FontWeight', 'bold', 'FontColor', 'magenta', ...
        'HorizontalAlignment', 'center');
    
    uislider(panel, 'Position', [320 120 110 3], 'Limits', [-12 12], ...
        'Value', 0, 'MajorTicks', [-12 -6 0 6 12]);
    
    uilabel(panel, 'Position', [345 100 60 20], 'Text', '0.0 dB', ...
        'FontSize', 10, 'FontColor', 'white', 'HorizontalAlignment', 'center');
    
    % Preset Dropdown
    uilabel(panel, 'Position', [500 140 80 20], 'Text', 'EQ Presets:', ...
        'FontSize', 12, 'FontWeight', 'bold', 'FontColor', 'white');
    
    uidropdown(panel, 'Position', [500 110 120 25], ...
        'Items', {'Flat', 'Pop/Rock', 'Vocal', 'V-Shape', 'Bright', 'Bass Boost'}, ...
        'Value', 'Flat', 'FontSize', 10);
    
    % Reset Button
    uibutton(panel, 'Position', [640 110 80 25], 'Text', 'Reset', ...
        'FontSize', 10, 'BackgroundColor', [0.6 0.6 0.6]);
end

function addVisualization(panel)
    % Placeholder for frequency response plot
    ax = uiaxes(panel, 'Position', [20 20 700 120]);
    ax.BackgroundColor = [0.1 0.1 0.1];
    ax.XColor = 'white';
    ax.YColor = 'white';
    
    % Sample frequency response plot
    f = logspace(1, 4.3, 100);
    plot(ax, f, zeros(size(f)), 'w-', 'LineWidth', 2);
    ax.XScale = 'log';
    ax.XLim = [20 20000];
    ax.YLim = [-15 15];
    ax.XLabel.String = 'Frequency (Hz)';
    ax.YLabel.String = 'Gain (dB)';
    ax.Title.String = 'EQ Frequency Response';
    ax.Title.Color = 'white';
    grid(ax, 'on');
    ax.GridColor = [0.3 0.3 0.3];
end

% Run the GUI
step3_1basic_gui();
