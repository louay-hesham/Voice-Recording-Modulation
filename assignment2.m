% 1) Record
Fs=48000;
recObj = audiorecorder;
disp('Start speaking.')
recordblocking(recObj,5);
disp('End of Recording.');
play(recObj); %Playback
x = getaudiodata(recObj);

% 2) Plot original signal
t=linspace(0,10,length(x));
figure(1);
plot(t,x)
title('Original Signal');

% 3) Delete frequencies > 4KHz
freq=fft(x);
f=linspace(-24000,24000,length(freq));
freq=fftshift(freq);
freq(f>4000) = 0;
freq(f<-4000) = 0;

% 4) Convert back to time domain
inverse=ifft(ifftshift(freq));
ft = real(inverse);
figure(2);
plot(t,ft);
title('Signal after removing > 4K frequencies');

% 5) Calculate the error
error=mean(( x- ft).^2);
fprintf('error after cutting: %f\n',error);

% 6) DSB Modulation
fc=1000000; 
carrier = cos(2*pi*fc*t);
carrier=permute(carrier,[2,1]);
modulateDSB=ft.*carrier; 
figure(3)
plot(t,modulateDSB); 
title('DSB modulated signal');

% 7) SSB Modulation
d=hilbert(modulateDSB); 
d=real(d);
freq6=fft(d);
figure(4)
plot(f,real(freq6));
title('SSB spectrum before shift');
freq7=fftshift(freq6);
figure(5);
plot(f,real(freq7))
title('SSB spectrum after shift');

% 8) Find error between received and coherent signals
decoherent = modulateDSB.*carrier;
error=mean(( ft- decoherent).^2);
fprintf('error after coherent: %f\n',error);
sound(decoherent);

% 9) Repeat with real band pass filter
 Wn=[3000 6000]/(Fs/2);
[b,a]=butter(3,Wn);
afterfilter=filter(b,a,modulateDSB);
figure(6);
plot(t,afterfilter);
title('Using band pass filter');

% 10) Repeat with coherent and real filter with SNR = 10 dB
repeat6 = awgn(ft,10); 
figure(7)
plot(t,repeat6);
title('Signal with noise');
% Modulation with noise
z6=repeat6.*carrier;
figure(8)
plot(t,z6);
title('Modulated signal with noise');
coherent = z6.*carrier;
figure(9)
plot(t,coherent)
title('Coherent signal with noise');
error=mean(( coherent- repeat6).^2);
fprintf('error after coherent with noise %f\n',error);

% 11) Repeat step 10 with fc = 1.001 MHz
noisefilter=filter(b,a,z6);
fcnew=100100;
newcarrier=permute(cos(2*pi*fcnew*t),[2,1]);
cohfreq=repeat6.*newcarrier;
figure(15)
plot(t,cohfreq)
title('Signal with noise and fc=1.001 MHz');
error=mean(( cohfreq- repeat6).^2);
fprintf('error new freq %f\n',error);
