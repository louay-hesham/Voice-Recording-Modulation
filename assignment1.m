%1) Recording
Fs=48000;
recObj = audiorecorder;
disp('Start speaking.')
recordblocking(recObj,5); %recording
disp('End of Recording.');
play(recObj); %playingback
x = getaudiodata(recObj);

%2) Plotting Original Signal
t=linspace(0,10,length(x));
% figure(1);
subplot(3,3,1)
plot(t,x) 
title('Original signal');

%3) Delete spectrum > 4K
freq=fft(x); 
freq=fftshift(freq);
freq(freq>4000) = 0;
freq(freq<-4000) = 0;

%4) Return signal to time domain
inverse=ifft(ifftshift(freq));
ft = real(inverse);
% figure(2);
subplot(3,3,2)
plot(t,ft);
title('Signal after removing > 4K frequencies');

%5) Calculate average error
error = mean((x - ft).^2);
fprintf('avg error: %f\n',error);

%6) AM Modulation
fc=1000000;
nf=1+0.5*ft; %assume M=0.5<1 
cosine=permute(cos(2*pi*fc*t), [2,1]); 
z=nf.*cosine; 
% figure(3)
subplot(3,3,3)
plot(t,z); 
title('AM modulation spectrum (no noise)');

% 7) Envolope detector
[up,lo] = envelope(z); 
d=up;
% figure(4)
subplot(3,3,4)
plot(t,d)
title('Envelope detector (no noise)');

% 8) Find error between received and transmitted signals
error=mean(( d-ft).^2); 
fprintf('error after envelope: %f\n',error);
sound(d,Fs);

% 9) Repeat with SNR = 10 dB
repeat6 = awgn(ft,10); %add noise with 10 db 
nf6=1+0.5*repeat6;
%modulation with noise
z6=nf6.*cosine;
% figure(5)
subplot(3,3,5)
plot(t,z6);
title('AM modulation spectrum (SNR = 10 dB)');
[up,lo] = envelope(z6);
d6=up;
% figure(6)
subplot(3,3,6)
plot(t,d6)
title('Envelope detector (SNR = 10 dB)');
error=mean(( d6- repeat6).^2);
fprintf('error after envelope with noise: %f\n',error);
sound(d6,Fs);

% 10) Using coherent detection
coherent = z6.*cosine;
% figure(7)
subplot(3,3,7)
plot(t,coherent)
title('Using coherent detection')
error=mean(( coherent- repeat6).^2);
fprintf('error after coherent detection with noise: %f\n',error);

% 11) Carrier frequency = 1.001 MHz
fc2=1001000;
cosine2=permute(cos(2*pi*fc2*t), [2,1]);
coherent = z6.*cosine2;
% figure(7)
subplot(3,3,8)
plot(t,coherent)
title('Using coherent detection with fc = 1.001 MHz')
error=mean(( coherent - repeat6).^2);
fprintf('error after coherent detection with noise and fc = 1.001 MHz: %f\n',error);

% 12)  With phase error
phase=10*pi/180;
cosine3=permute(cos(2*pi*fc*t+ phase), [2,1]);
coherent = z6.*cosine3;
% figure(8)
subplot(3,3,9)
plot(t,coherent)
title('Using coherent detection with phase error')
error=mean(( coherent- repeat6).^2);
fprintf('error after coherent detection with noise and phase error: %f\n',error);