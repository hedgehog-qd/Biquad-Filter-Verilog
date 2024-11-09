% Parameters
fs = 44100;          % Sampling rate
f_signal = 100;     % frequency of main signal to show
f_noise = 2500;     % frequency of noise (will be filtered)
Q = 0.7071;         % Q
Gain = 6;           % gain
duration = 1;       % total time of simulation signal (here we set to 1s)

% time
t = 0:1/fs:duration;

% sine wave of main signal to show
signal_wave = 0.5 * sin(2 * pi * f_signal * t);

% sine wave of noise signal
noise_wave = 0.25 * sin(2 * pi * f_noise * t);

% mix the main signal and noise signal
input_signal = signal_wave + noise_wave;

% convert to 24 bit integer (as simulation input)
input_signal_quantized = round(input_signal * (2^(23) - 1));

% write to file
fileID = fopen('input_signal.txt', 'w');

% convert to hex, so we can use Verilog to read directly
for i = 1:length(input_signal_quantized)
    fprintf(fileID, '%s\n', dec2hex(input_signal_quantized(i)));
end

% close file
fclose(fileID);

disp('Test signal saved as: input_signal.txt');


% draw the generated signal
figure; % create window
plot(t(1:length(input_signal_quantized)), input_signal_quantized);
xlabel('Time (s)');
ylabel('Amplitude');
title('Waveform of Generated Signal');
grid on; % show the grid
