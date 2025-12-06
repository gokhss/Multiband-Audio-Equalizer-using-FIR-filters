<img width="2876" height="1670" alt="Screenshot 2025-11-16 165633" src="https://github.com/user-attachments/assets/a5ee5a01-c01d-466a-a4b8-f24d67124b2b" />
🎧 Multiband Audio Equalizer using FIR Filters

This project is a MATLAB-based multiband audio equalizer that uses FIR filters to adjust different frequency bands of an audio signal in real time. 
It includes a simple, interactive GUI for loading audio, adjusting gains, selecting presets, and visualizing results.

⭐ Features
🔊 FIR-Based Multiband Equalizer

Separate control for bass, mid, treble, and intermediate frequency bands

FIR filters ensure linear phase and high audio quality

🖥 MATLAB GUI for:

Loading and playing audio files

Adjusting gain of each band via sliders

Selecting presets: Classical, Jazz, Bass Boosted, Electronic, Bright

📊 Real-Time Visualization

Time-domain waveforms of input and output

Frequency spectrum and magnitude response

🧰 FIR Filter Design

Window-based FIR filter design (Signal Processing Toolbox)

📁 Project Structure

Adjust filenames based on your repository if needed:

main.m               → Launches the equalizer GUI  
equalizer_gui.m/.fig → GUI logic and layout  
design_filters.m     → FIR filter design for each band  
apply_equalizer.m    → Splits audio into bands, applies gains, reconstructs output  
presets.m            → Preset definitions (Classical, Jazz, Bass Boosted, etc.)  
test_signals/        → Optional audio files for testing  

✅ Requirements
Software
MATLAB R20xx or later
Required Toolbox:
Signal Processing Toolbox
(Optional) Audio Toolbox

Input
WAV audio file (mono or stereo)

🚀 How to Run
1. Clone repository:
git clone https://github.com/gokhss/Multiband-Audio-Equalizer-using-FIR-filters.git

3. Open MATLAB and set folder as working directory.
4. Run: main
5. Use GUI to load audio, adjust gains, choose presets, and visualize output.

HOW IT WORKS
- Audio is filtered using a bank of FIR bandpass filters.
- Each band’s gain is adjusted via sliders or presets.
- Adjusted bands are summed to form the equalized audio.
- FIR filters ensure linear phase and high-quality output.


Why FIR filters?
Guaranteed stability
Nearly linear phase → waveform preserved
Ideal for high-quality audio equalization
