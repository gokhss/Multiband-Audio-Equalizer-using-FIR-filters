%% Step 2.1: Multi-band Filter Design
% Design Mid and Treble FIR filters to complete the equalizer
clear; clc; close all;

% Load bass filter from Day 1
load('../Day1_FilterDesign/bass_filter.mat');
fprintf('=== Multi-band Equalizer Design ===\n');
fprintf('Bass filter loaded: %d coefficients\n', length(h_bass));

% Audio parameters (consistent with Day 1)
fs = 44100;        % Sample rate
N = 128;           % Filter order (same for all bands)

% Frequency band specifications
fc_low = 250;      % Bass-Mid boundary
fc_high = 4000;    % Mid-Treble boundary

% Normalized frequencies
fc_low_norm = fc_low / (fs/2);
fc_high_norm = fc_high / (fs/2);

fprintf('\nFrequency Bands:\n');
fprintf('Bass:   20 Hz - %d Hz\n', fc_low);
fprintf('Mid:    %d Hz - %d Hz\n', fc_low, fc_high);
fprintf('Treble: %d Hz - 20000 Hz\n', fc_high);

%% Design All Three Filters
fprintf('\n=== Designing Filter Bank ===\n');

% Bass filter (already have from Day 1)
% h_bass = fir1(N, fc_low_norm, 'low', hamming(N+1));

% Mid-band filter (bandpass)
h_mid = fir1(N, [fc_low_norm fc_high_norm], 'bandpass', hamming(N+1));

% Treble filter (highpass)  
h_treble = fir1(N, fc_high_norm, 'high', hamming(N+1));

fprintf('Bass filter:   %d coefficients (loaded)\n', length(h_bass));
fprintf('Mid filter:    %d coefficients (designed)\n', length(h_mid));
fprintf('Treble filter: %d coefficients (designed)\n', length(h_treble));

% Save all filter coefficients
save('multiband_filters.mat', 'h_bass', 'h_mid', 'h_treble', 'fs', 'N', ...
     'fc_low', 'fc_high', 'fc_low_norm', 'fc_high_norm');

fprintf('All filters saved to multiband_filters.mat\n');
%% Analyze All Filter Responses
[H_bass, f] = freqz(h_bass, 1, 1024, fs);
[H_mid, ~] = freqz(h_mid, 1, 1024, fs);
[H_treble, ~] = freqz(h_treble, 1, 1024, fs);

% Plot all filter responses
figure('Name', 'Complete Filter Bank Analysis', 'Position', [100 100 1200 800]);

% Magnitude responses
subplot(2,2,1);
plot(f, 20*log10(abs(H_bass)), 'b-', 'LineWidth', 2); hold on;
plot(f, 20*log10(abs(H_mid)), 'g-', 'LineWidth', 2);
plot(f, 20*log10(abs(H_treble)), 'r-', 'LineWidth', 2);
grid on;
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
title('Filter Bank - Individual Responses');
legend('Bass', 'Mid', 'Treble', 'Location', 'best');
xlim([20 20000]); ylim([-60 5]);
set(gca, 'XScale', 'log');

% Combined response (sum of all filters)
H_combined = abs(H_bass) + abs(H_mid) + abs(H_treble);
subplot(2,2,2);
plot(f, 20*log10(H_combined), 'k-', 'LineWidth', 2);
grid on;
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
title('Combined Filter Response');
xlim([20 20000]); ylim([-3 3]);
set(gca, 'XScale', 'log');
line([20 20000], [0 0], 'Color', 'r', 'LineStyle', '--');

% Phase responses
subplot(2,2,3);
plot(f, angle(H_bass)*180/pi, 'b-', 'LineWidth', 1.5); hold on;
plot(f, angle(H_mid)*180/pi, 'g-', 'LineWidth', 1.5);
plot(f, angle(H_treble)*180/pi, 'r-', 'LineWidth', 1.5);
grid on;
xlabel('Frequency (Hz)'); ylabel('Phase (degrees)');
title('Filter Bank - Phase Responses');
legend('Bass', 'Mid', 'Treble');
xlim([20 20000]);
set(gca, 'XScale', 'log');

% Filter coefficients comparison
subplot(2,2,4);
plot(h_bass, 'b-', 'LineWidth', 1.5); hold on;
plot(h_mid, 'g-', 'LineWidth', 1.5);
plot(h_treble, 'r-', 'LineWidth', 1.5);
grid on;
xlabel('Sample Index'); ylabel('Amplitude');
title('Filter Coefficients');
legend('Bass', 'Mid', 'Treble');

fprintf('\n=== Filter Analysis Complete ===\n');
fprintf('Bass peak response:   %.2f dB at %d Hz\n', ...
    max(20*log10(abs(H_bass(1:100)))), 50);
fprintf('Mid peak response:    %.2f dB at %d Hz\n', ...
    max(20*log10(abs(H_mid))), f(find(abs(H_mid)==max(abs(H_mid)), 1)));
fprintf('Treble peak response: %.2f dB at %d Hz\n', ...
    max(20*log10(abs(H_treble(end-100:end)))), 10000);
