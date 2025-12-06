%% Step 1.3: Basic Audio Processing with Real Audio Files
% Load the bass filter from Step 1.2
clear; clc; close all;

% Load filter coefficients
load('bass_filter.mat');
fprintf('=== Loading Bass Filter ===\n');
fprintf('Filter loaded: %d coefficients\n', length(h_bass));
fprintf('Sample Rate: %d Hz\n', fs);

%% Option 1: Create a test audio file (if you don't have one)
% Generate a longer, more complex test signal
duration = 10;  % 10 seconds
t = (0:1/fs:duration-1/fs)';

% Create music-like signal with multiple instruments
bass_drum = sin(2*pi*60*t) .* exp(-mod(t,1)*5);     % Bass drum
snare = sin(2*pi*200*t) .* exp(-mod(t-0.5,1)*8);   % Snare
melody = sin(2*pi*440*t + sin(2*pi*2*t)) * 0.5;     % Melody with vibrato
harmony = sin(2*pi*660*t) * 0.3;                    % Harmony

test_audio = bass_drum + snare + melody + harmony;
test_audio = test_audio / max(abs(test_audio)) * 0.8; % Normalize

% Save test audio
audiowrite('../AudioFiles/test_music.wav', test_audio, fs);
fprintf('Test audio created: test_music.wav\n');

%% Load and Process Audio File
try
    % Try to load the test file we just created
    [audio_original, fs_file] = audioread('../AudioFiles/test_music.wav');
    fprintf('Audio loaded successfully!\n');
    fprintf('Duration: %.2f seconds\n', length(audio_original)/fs_file);
    fprintf('Sample rate: %d Hz\n', fs_file);
    
    % Check if sample rates match
    if fs_file ~= fs
        fprintf('Warning: Resampling from %d to %d Hz\n', fs_file, fs);
        audio_original = resample(audio_original, fs, fs_file);
    end
    
catch
    fprintf('Could not load audio file. Using generated test signal.\n');
    audio_original = test_audio;
end

%% Apply Bass Filter to Real Audio
fprintf('\n=== Processing Audio ===\n');
tic; % Start timer
audio_bass_only = filter(h_bass, 1, audio_original);
processing_time = toc;

fprintf('Processing complete in %.3f seconds\n', processing_time);
fprintf('Original audio: Min=%.3f, Max=%.3f\n', min(audio_original), max(audio_original));
fprintf('Filtered audio: Min=%.3f, Max=%.3f\n', min(audio_bass_only), max(audio_bass_only));

%% Analyze Frequency Content
% Calculate FFT of original and filtered signals
N_fft = 2048;
f_fft = (0:N_fft-1) * fs / N_fft;

% Take FFT of first 2 seconds
samples_to_analyze = min(2*fs, length(audio_original));
original_fft = fft(audio_original(1:samples_to_analyze), N_fft);
filtered_fft = fft(audio_bass_only(1:samples_to_analyze), N_fft);

% Plot frequency analysis
figure('Name', 'Real Audio Analysis');
subplot(3,1,1);
plot(f_fft(1:N_fft/2), 20*log10(abs(original_fft(1:N_fft/2))), 'b-', 'LineWidth', 1.5);
hold on;
plot(f_fft(1:N_fft/2), 20*log10(abs(filtered_fft(1:N_fft/2))), 'r-', 'LineWidth', 1.5);
grid on; xlim([0 2000]); xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
title('Frequency Content Comparison');
legend('Original', 'Bass Filtered', 'Location', 'northeast');

% Plot time domain comparison
subplot(3,1,2);
time_plot = (0:length(audio_original)-1) / fs;
plot(time_plot(1:fs), audio_original(1:fs), 'b-', 'LineWidth', 1);
hold on;
plot(time_plot(1:fs), audio_bass_only(1:fs), 'r-', 'LineWidth', 1);
grid on; xlabel('Time (s)'); ylabel('Amplitude');
title('Time Domain Comparison (First 1 Second)');
legend('Original', 'Bass Filtered');

% Plot spectrogram
subplot(3,1,3);
spectrogram(audio_original(1:samples_to_analyze), 256, 128, 256, fs, 'yaxis');
title('Original Audio Spectrogram');
ylim([0 2]);
%% Save Processed Audio Files
audiowrite('../AudioFiles/bass_filtered_output.wav', audio_bass_only, fs);
fprintf('\n=== Files Saved ===\n');
fprintf('Original: test_music.wav\n');
fprintf('Processed: bass_filtered_output.wav\n');

%% Audio Playback Test (Uncomment to hear)
 %%fprintf('Playing original audio...\n');
 %%sound(audio_original * 0.5, fs);
 %%pause(3);
 fprintf('Playing bass-filtered audio...\n'); 
 sound(audio_bass_only * 0.5, fs);

fprintf('\n=== Step 1.3 Complete! ===\n');
fprintf('✓ Real audio processing working\n');
fprintf('✓ Bass filter applied successfully\n');
fprintf('✓ Analysis plots generated\n');
fprintf('✓ Audio files saved\n');
fprintf('\n Ready for Day 2: Multi-band Filter Implementation!\n');

