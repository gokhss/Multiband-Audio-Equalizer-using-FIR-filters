%% Step 2.3: Real Audio Multi-band Processing (FIXED)
% Apply complete equalizer to real audio files
clear; clc; close all;

% Load filter bank
load('multiband_filters.mat');
fprintf('=== Real Audio Multi-band Processing ===\n');

%% Load Real Audio File
try
    % Try to load audio from Day 1
    [audio_original, fs_file] = audioread('../../AudioFiles/test_music.wav');
    fprintf('Audio loaded: test_music.wav\n');
catch
    try
        % Try built-in MATLAB audio
        load handel
        audio_original = y;
        fs_file = Fs;
        clear y Fs;
        fprintf('Audio loaded: Handel (built-in)\n');
    catch
        % Generate synthetic audio if no files available
        duration = 10;
        t = (0:1/fs:duration-1/fs)';
        audio_original = sin(2*pi*220*t) + 0.5*sin(2*pi*880*t) + 0.3*sin(2*pi*3520*t);
        fs_file = fs;
        fprintf('Audio generated: synthetic multi-tone\n');
    end
end

% Resample if necessary
if fs_file ~= fs
    audio_original = resample(audio_original, fs, fs_file);
end

% Use mono audio
if size(audio_original, 2) > 1
    audio_original = audio_original(:, 1);
end

fprintf('Audio duration: %.2f seconds\n', length(audio_original)/fs);
fprintf('Sample rate: %d Hz\n', fs);

%% Apply Multiple EQ Presets to Real Audio
eq_presets = [
    0,   0,   0;     % Flat
    6,  -2,   3;     % Pop/Rock  
    -3,   4,   2;     % Vocal boost
    8,  -4,   6;     % V-shape (bass + treble)
    -6,   0,   8;     % Brightness
    4,   4,   4;     % Full boost
];

preset_names = {'Flat', 'Pop/Rock', 'Vocal', 'V-Shape', 'Bright', 'Full Boost'};
fprintf('\n=== Processing Real Audio ===\n');

% Process audio with each preset (INLINE EQUALIZER - NO FUNCTION NEEDED)
processed_audio = cell(length(preset_names), 1);
individual_bands = cell(length(preset_names), 3);

for i = 1:length(preset_names)
    tic;
    
    % Get gains for this preset
    gains_db = eq_presets(i, :);
    gains_linear = 10.^(gains_db/20);  % Convert dB to linear
    
    % Apply equalizer inline (no function call)
    bass = gains_linear(1) * filter(h_bass, 1, audio_original);
    mid = gains_linear(2) * filter(h_mid, 1, audio_original);  
    treble = gains_linear(3) * filter(h_treble, 1, audio_original);
    output = bass + mid + treble;
    
    % Store results
    processed_audio{i} = output;
    individual_bands{i, 1} = bass;
    individual_bands{i, 2} = mid;
    individual_bands{i, 3} = treble;
    
    processing_time = toc;
    fprintf('%s: Bass=%+.1fdB, Mid=%+.1fdB, Treble=%+.1fdB - Processed in %.3f seconds\n', ...
        preset_names{i}, gains_db(1), gains_db(2), gains_db(3), processing_time);
end

%% Save Processed Audio Files
fprintf('\n=== Saving Audio Files ===\n');

% Create output directory if it doesn't exist
if ~exist('../../AudioFiles/Day2_Output', 'dir')
    mkdir('../../AudioFiles/Day2_Output');
end

% Save original
audiowrite('../../AudioFiles/Day2_Output/original.wav', audio_original, fs);

% Save each preset
for i = 1:length(preset_names)
    filename = sprintf('../../AudioFiles/Day2_Output/%s.wav', lower(strrep(preset_names{i}, '/', '_')));
    audiowrite(filename, processed_audio{i}, fs);
    fprintf('Saved: %s\n', filename);
end

%% Visualization (Optional)
fprintf('\n=== Creating Comparison Plot ===\n');

% Plot frequency response comparison for first few presets
figure('Name', 'EQ Presets Comparison', 'Position', [100 100 1200 600]);

N_fft = 2048;
f_fft = (0:N_fft/2-1) * fs / N_fft;

for i = 1:min(4, length(preset_names))
    subplot(2, 2, i);
    
    % FFT of original and processed
    orig_fft = fft(audio_original(1:N_fft), N_fft);
    proc_fft = fft(processed_audio{i}(1:N_fft), N_fft);
    
    plot(f_fft, 20*log10(abs(orig_fft(1:N_fft/2))), 'k--', 'LineWidth', 1); 
    hold on;
    plot(f_fft, 20*log10(abs(proc_fft(1:N_fft/2))), 'b-', 'LineWidth', 1.5);
    
    grid on;
    xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
    title(sprintf('%s EQ', preset_names{i}));
    legend('Original', 'EQ Output', 'Location', 'best');
    xlim([20 20000]); set(gca, 'XScale', 'log');
end

%% Audio Listening Test (Interactive)
fprintf('\n=== Interactive Listening Test ===\n');
fprintf('Uncomment the following section to listen to different presets:\n');

% Uncomment this section for audio playback testing:
%{
for i = 1:length(preset_names)
    fprintf('\n--- %s EQ Setting ---\n', preset_names{i});
    fprintf('Bass: %+.1fdB, Mid: %+.1fdB, Treble: %+.1fdB\n', eq_presets(i, :));
    fprintf('Press Enter to play...\n'); pause;
    
    sound(processed_audio{i} * 0.6, fs);
    pause(3); % Play for 3 seconds
    
    fprintf('Press Enter to continue to next preset...\n'); pause;
end
%}

fprintf('\n=== Day 2 Multi-band Implementation Complete! ===\n');
fprintf('✓ Mid and Treble filters designed and loaded\n');
fprintf('✓ Complete 3-band equalizer implemented inline\n');  
fprintf('✓ Multiple EQ presets tested on real audio\n');
fprintf('✓ Real audio processed with all presets\n');
fprintf('✓ Audio files saved for demonstration\n');
fprintf('✓ Comparison plots generated\n');
fprintf('\n🎉 Ready for Day 3: GUI Development! 🎉\n');
