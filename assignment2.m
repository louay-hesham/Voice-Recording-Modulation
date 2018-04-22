Fs=48000;
%record
recObj = audiorecorder
disp('Start speaking.')
recordblocking(recObj,5);
disp('End of Recording.');
%playback
play(recObj);
x = getaudiodata(recObj);
%plot
t=linspace(0,10,length(x));
figure(1);
plot(t,x)

%**************************************************************

%fourier
freq=fft(x);
%plot
f=linspace(-24000,24000,length(freq));
figure(2);
plot(f,real(freq))
%shift
freq=fftshift(freq);
%plot
figure(3);
plot(f,real(freq))

%**************************************************************

%delete>4k
freq(f>4000) = 0;
freq(f<-4000) = 0;
%plot
figure(4);
plot(f,real(freq))

%*******************************************************

%inverse
inverse=ifft(ifftshift(freq));
ft = real(inverse);
%plot
figure(5);
plot(t,ft);
% sound(ft,Fs);

%*************************************************************

%error
error=mean(( x- ft).^2);
fprintf("error after cutting: %f\n",error);

%************************************************************

%modulation"carrier"
fc=1000000; 
carrier = cos(2*pi*fc*t);
carrier=permute(carrier,[2,1]);
modulateDSB=ft.*carrier; 
figure(6)
plot(t,modulateDSB); 

%*************************************************************

%ssb
d=hilbert(modulateDSB); 
d=real(d);
freq6=fft(d);
figure(7)
plot(f,real(freq6));
freq7=fftshift(freq6);
figure(8);
plot(f,real(freq7))

%****************************************************************
decoherent = modulateDSB.*carrier;
figure(9)
plot(t,decoherent)
error=mean(( ft- decoherent).^2);
fprintf("error after coherent: %f\n",error);
sound(decoherent);

%*********************************************************************
 Wn=[3000 6000]/(Fs/2);
[b,a]=butter(3,Wn);
afterfilter=filter(b,a,modulateDSB);
figure(10);
plot(t,afterfilter);

%***********************************************

%add noise 
repeat6 = awgn(ft,10); 
figure(11)
plot(t,repeat6);
%modulation with noise
z6=repeat6.*carrier;
figure(12)
plot(t,z6);

coherent = z6.*carrier;
figure(13)
plot(t,coherent)
error=mean(( coherent- repeat6).^2);
fprintf("error after coherent with noise %f\n",error);

%**************************************************************

noisefilter=filter(b,a,z6);
figure(14);
plot(t,noisefilter);

%******************************************************
fcnew=100100;
newcarrier=permute(cos(2*pi*fcnew*t),[2,1]);
cohfreq=repeat6.*newcarrier;
figure(15)
plot(t,cohfreq)
error=mean(( cohfreq- repeat6).^2);
fprintf("error new freq %f\n",error);

%***************************************************

