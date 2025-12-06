%% Step 2.2: Multi-band Equalizer Function
% Create a complete equalizer system with gain controls
clear; clc; close all;

% Load filter bank
load('multiband_filters.mat');
fprintf('=== Multi-band Equalizer Function ===\n');

%% Define Equalizer Function
function [output, bass_out, mid_out, treble_out] = multiband_equalizer(input_audio, gains)
    % Multi-band equalizer function
    % Inputs:
    %   input_audio - input signal vector
    %   gains - [bass_gain, mid_gain, treble_gain] in dB or linear
    % Outputs:
    %   output - processed audio signal
    %   bass_out, mid_out, treble_out - individual band outputs
    
    % Load filters (assumes multiband_filters.mat is in current directory)
    persistent h_bass h_mid h_treble
    if isempty(h_bass)
        load('multiband_filters.mat', 'h_bass', 'h_mid', 'h_treble');
    end
    
    % Convert dB gains to linear if needed
    if max(abs(gains)) > 5  % Assume dB if large values
        gains_linear = 10.^(gains/20);
    else
        gains_linear = gains;  % Already linear
    end
    
    % Apply filters and gains
    bass_out = gains_linear(1) * filter(h_bass, 1, input_audio);
    mid_out = gains_linear(2) * filter(h_mid, 1, input_audio);
    treble_out = gains_linear(3) * filter(h_treble, 1, input_audio);
    
    % Combine all bands
    output = bass_out + mid_out + treble_out;
end

%% Test Equalizer with Different Gain Settings
% Create test signal with content in all frequency bands
duration = 5; % 5 seconds
t = (0:1/fs:duration-1/fs)';

% Multi-frequency test signal
bass_tone = sin(2*pi*80*t);           % 80 Hz bass
mid_tone = sin(2*pi*1000*t);          % 1 kHz mid
treble_tone = sin(2*pi*8000*t);       % 8 kHz treble
white_noise = 0.1 * randn(size(t));   % Background noise

test_signal = 0.3*(bass_tone + mid_tone + treble_tone) + white_noise;
test_signal = test_signal / max(abs(test_signal)) * 0.8;

fprintf('Test signal created: %.1f seconds\n', duration);
fprintf('Frequencies: 80Hz (bass), 1000Hz (mid), 8000Hz (treble)\n');

%% Test Different EQ Settings
eq_settings = [
    0,  0,  0;    % Flat (no boost/cut)
    6, -3, -3;    % Bass boost
    -3, 6, -3;    % Mid boost  
    -3, -3, 6;    % Treble boost
    3,  0,  3;    % V-shaped (bass + treble)
    -6, 0,  0;    % Bass cut
];

setting_names = {'Flat', 'Bass Boost', 'Mid Boost', 'Treble Boost', 'V-Shape', 'Bass Cut'};

fprintf('\n=== Testing EQ Settings ===\n');

% Process with each setting
processed_signals = zeros(length(test_signal), size(eq_settings, 1));

for i = 1:size(eq_settings, 1)
    gains_db = eq_settings(i, :);
    [processed, ~, ~, ~] = multiband_equalizer(test_signal, gains_db);
    processed_signals(:, i) = processed;
    
    fprintf('%s: Bass=%+.1fdB, Mid=%+.1fdB, Treble=%+.1fdB\n', ...
        setting_names{i}, gains_db(1), gains_db(2), gains_db(3));
end

% Save processed signals for listening tests
save('eq_test_results.mat', 'test_signal', 'processed_signals', 'eq_settings', 'setting_names', 'fs');
%% Visualize EQ Effects
figure('Name', 'Equalizer Settings Comparison', 'Position', [100 100 1400 900]);

% Plot time domain for first few settings
for i = 1:4
    subplot(3, 4, i);
    plot(t(1:fs/2), test_signal(1:fs/2), 'k--', 'LineWidth', 1); hold on;
    plot(t(1:fs/2), processed_signals(1:fs/2, i), 'b-', 'LineWidth', 1.5);
    grid on;
    title(sprintf('%s (%.1fs)', setting_names{i}, 0.5));
    xlabel('Time (s)'); ylabel('Amplitude');
    if i == 1, legend('Original', 'Processed'); end
end

% Frequency domain comparison
N_fft = 2048;
f_fft = (0:N_fft/2-1) * fs / N_fft;

for i = 1:4
    subplot(3, 4, i+4);
    
    % FFT of original and processed
    orig_fft = fft(test_signal(1:N_fft), N_fft);
    proc_fft = fft(processed_signals(1:N_fft, i), N_fft);
    
    plot(f_fft, 20*log10(abs(orig_fft(1:N_fft/2))), 'k--', 'LineWidth', 1); hold on;
    plot(f_fft, 20*log10(abs(proc_fft(1:N_fft/2))), 'b-', 'LineWidth', 1.5);
    grid on;
    title(sprintf('%s - Frequency', setting_names{i}));
    xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
    xlim([20 20000]); set(gca, 'XScale', 'log');
    if i == 1, legend('Original', 'Processed'); end
end

% EQ settings visualization
subplot(3, 4, [9 10 11 12]);
bar(eq_settings');
grid on;
xlabel('EQ Setting'); ylabel('Gain (dB)');
title('Equalizer Gain Settings');
legend('Bass', 'Mid', 'Treble');
set(gca, 'XTickLabel', setting_names);
xtickangle(45);

fprintf('\n=== Visualization Complete ===\n');
