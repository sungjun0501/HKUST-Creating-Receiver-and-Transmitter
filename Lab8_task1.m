% initalization
Fs=1e6; %sampling frequency
Fcutoff = 25e3; %cutoff frequency of low pass filter
Fc=1e5; %carrier frequency for message 1
Fc2=Fc + 2*Fcutoff; %carrier frequency for message 2

SPB=20; % samples per bit
Ts = 1/Fs; % sample period

textmsg1 = sprintf('%s\n%s\n%s',...
'It was the best of times, it was the worst of times',...
'it was the age of wisdom, it was the age of foolishness,',...
'it was the epoch of belief,');

textmsg2 = sprintf('%s\n%s\n%s',...
'it was the season of Light, it was the season of Darkness,',...
'it was the spring of hope, it was the winter of despair,',...
'we had everything before us');

% % % % % % % % % % % %
% BPSK Transmitter 1 %
% % % % % % % % % % % %
%Create a bitstream from the input text message
bs1 = text2bitseq(textmsg1);
% frame the bitstream and add the training sequence
wave1 = format_bitseq(bs1,SPB);
% change waveform from varying between 0 and 1 to -1 and 1
wave1 = 2*wave1 - 1;

% % % % Revise the following % % % %

wave1 = lowpass(wave1,Fs,Fcutoff);


% % % % Do not change the code below % % % %

% create vector of sample times
t = Ts * [0:(length(wave1)-1)];
% modulate the waveform
tx_wave1 = wave1.*cos(2*pi*Fc*t);

% % % % % % % % % % % %
% BPSK Transmitter 2 %
% % % % % % % % % % % %
% The operation for message 2 is similar, but packaged in a function
tx_wave2 = tx_BPSK(textmsg2, Fs, Fc2, SPB, Fcutoff);

% % % % % %
% Channel %
% % % % % %
tx_wave = tx_wave1 + tx_wave2;
rx_wave = txrx(tx_wave,1,'ideal');

% % % % % % % % % % % % % %
% Receiver Message for 1  %
% % % % % % % % % % % % % %
[msg_r1, wave_r1] = rx_BPSK(rx_wave, Fs, Fc, SPB, Fcutoff);

% % % % % % % % % % % % % %
% Receiver for Message 2  %
% % % % % % % % % % % % % %
[msg_r2, wave_r2] = rx_BPSK(rx_wave, Fs, Fc2, SPB, Fcutoff);

% compare the messages
% disp('Message 1:');
disp('Original Message 1:');
disp(textmsg1);
disp('Recovered Message 1:');
% filter non-printing characters
filtmsg = filter_text(msg_r1);
disp(filtmsg);
disp(['Number of Bit Errors: '  num2str(sum(textmsg1~=msg_r1(1:length(textmsg1)))) ]);
disp(' ')

% disp('Message 2:');
disp('Original Message 2:');
disp(textmsg2);
disp('Recovered Message 2:');
% filter non-printing characters
filtmsg = filter_text(msg_r2);
disp(filtmsg);
disp(['Number of Bit Errors: '  num2str(sum(textmsg2~=msg_r2(1:length(textmsg2)))) ]);

% generate plots of amplitude spectra
figure(1);clf;
subplot(4,1,1);
plotAmplitudeSpectrum(wave1,Fs,'Amplitude Spectrum of the Waveform 1');
subplot(4,1,2);
plotAmplitudeSpectrum(tx_wave1,Fs,'Amplitude Spectrum of the Modulated Signal 1');
subplot(4,1,3);
plotAmplitudeSpectrum(tx_wave2,Fs,'Amplitude Spectrum of the Modulated Signal 2');
subplot(4,1,4);
plotAmplitudeSpectrum(tx_wave,Fs,'Amplitude Spectrum of the Transmitted Signal');

