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
figure(1);
plot(t,x) 
title('Original signal');

%3) Delete spectrum > 4K
freq=fft(x); 
freq=fftshift(freq);
freq(f>4000) = 0;
freq(f<-4000) = 0;

%4) Return signal to time domain
inverse=ifft(ifftshift(freq));
ft = real(inverse);
figure(2);
plot(t,ft);

%5) Calculate average error
error = mean((x - ft).^2);
fprintf('avg error: %f\n',error);

%6) AM Modulation
fc=1000000;
nf=1+0.5*ft; %assume M=0.5<1 
cosine=permute(cos(2*pi*fc*t), [2,1]); 
z=nf.*cosine; 
figure(3)
plot(t,z); 

%**************************************

%demodulation with envelope
[up,lo] = envelope(z); 
d=up;
figure(7)
plot(t,d)

%*************************************

error=mean(( d-ft).^2); 
fprintf('error after envelope: %f\n',error);
sound(d,Fs);

%************************************

%add noise then do modulation again
repeat6 = awgn(ft,10); %add noise with 10 db 
figure(8)
plot(t,repeat6);
nf6=1+0.5*repeat6;
%modulation with noise
z6=nf6.*cosine;
figure(9)
plot(t,z6);

%*******************************************
[up,lo] = envelope(z6);
d6=up;
figure(10)
plot(t,d6)
error=mean(( d6- repeat6).^2);
fprintf('error after envelope with noise: %f\n',error);
sound(d6,Fs);
%****************************************
coherent = z6.*cosine;
figure(11)
plot(t,coherent)
error=mean(( coherent- repeat6).^2);
fprintf('error after coherent detection with noise: %f\n',error);
%********************************************
fc2=1001000;
cosine2=permute(cos(2*pi*fc2*t), [2,1]);
coherent = z6.*cosine2;
figure(12)
plot(t,coherent)
%*******************************************
phase=10*pi/180;
cosine3=permute(cos(2*pi*fc*t+ phase), [2,1]);
coherent = z6.*cosine3;
figure(13)
plot(t,coherent)