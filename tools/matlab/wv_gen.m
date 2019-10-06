Fs = 47e3;
Fc = 1e3;
len = 1000;
t = 0:1/Fs:(len)/Fs;
ph = 2*pi*Fc./Fs*(0:1:len-1) + pi/3;
y = sin(ph);
max(y)