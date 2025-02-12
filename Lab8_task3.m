% initalization
Fs=1e6;               % sampling frequency
Fcutoff = 25e3;       % cutoff frequency of low pass filter 
Fc=1e5;               % carrier frequency for message 1
Fc2=Fc+2*Fcutoff;     % carrier frequency for message 2

SPB=20;               % samples per bit     
Ts = 1/Fs;            % sample period

textmsg1 = sprintf('%s\n%s\n%s',...
'It was the best of times, it was the worst of times',...
'it was the age of wisdom, it was the age of foolishness,',...
'it was the epoch of belief,');

textmsg2 = sprintf('%s\n%s\n%s',...
'it was the season of Light, it was the season of Darkness,',...
'it was the spring of hope, it was the winter of despair,',...
'we had everything before us');

% Transmitters

% BPSK transmitter for MSG 1
% I Channel in QPSK transmitter
tx_wave1 = tx_BPSK(textmsg1, Fs, Fc, SPB, Fcutoff);

% BPSK transmitter for MSG 2
% Q channel in QPSK transmitter

% % % % Revise the following  % % % % 

%Create a bitstream from the input text message
bs = text2bitseq(textmsg2);
% frame the bitstream and add the training sequence
wave2 = format_bitseq(bs,SPB);
% change waveform from varying between 0 and 1 to -1 and 1
wave2 = 2*wave2 - 1;

% % % % Revise the following % % % %

wave2 = lowpass (wave2, Fs, Fcutoff);

% % % % Do not change the code below % % % %

% create vector of sample times
t = Ts * [0:(length(wave2)-1)];
% modulate the waveform
tx_wave2 = wave2.*sin(2*pi*Fc*t);

% % % % Do not change the code below % % % %

% Channel
tx_wave = tx_wave1+tx_wave2;
rx_wave = txrx(tx_wave,1,'ideal');

% Receivers

% Receiver for MSG1
% I channel for QPSK receiver
% create vector of sample times
t = Ts * [0:(length(rx_wave)-1)];
% mix with cosinusoidal carrier
wave_r1 = rx_wave.*cos(2*pi*Fc*t); 
% low pass filter
wave_r1 = lowpass(wave_r1, Fs,Fcutoff);
% decode waveform to text message
msg_r1 = waveform2text(wave_r1,SPB);

% Receiver for MSG2
% Q channel for QPSK receiver

% % % % Revise the following  % % % % 

% mix with cosinusoidal carrier with frequency Fc2
wave_r2 = rx_wave.*sin(2*pi*Fc*t);

% % % % Do not change the code below % % % % 

wave_r2 = lowpass(wave_r2, Fs, Fcutoff);
msg_r2 = waveform2text(wave_r2,SPB);

% compare the messages
fprintf('Original Message  1: \n%s\n',  textmsg1 );
% filter non-printing characters
filtmsg =filter_text(msg_r1);
fprintf('Recovered Message 1: \n%s\n',  filtmsg );
display(['Num of Bit-Error: '  num2str(sum(textmsg1~=msg_r1(1:length(textmsg1)))) ]);
disp(' ');
fprintf('Original Message  2: \n%s\n',  textmsg2 );
% filter non-printing characters
filtmsg =filter_text(msg_r2);
fprintf('Recovered Message 2: \n%s\n',  filtmsg );
display(['Num of Bit-Error: '  num2str(sum(textmsg2~=msg_r2(1:length(textmsg2)))) ]);

% generate plots of the amplitude spectra
figure(1); clf;
subplot(3,1,1);
plotAmplitudeSpectrum(tx_wave1,Fs,'Amplitude Spectrum of the Transmitted Signal 1');
subplot(3,1,2);
plotAmplitudeSpectrum(tx_wave2,Fs,'Amplitude Spectrum of the Transmitted Signal 2');
subplot(3,1,3);
plotAmplitudeSpectrum(rx_wave,Fs,'Amplitude Spectrum of Received Signals (1 and 2)');
