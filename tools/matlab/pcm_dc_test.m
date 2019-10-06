dc_in = [22 29 37 46 56 67 79 92 106 121];
len = length(dc_in);
pcm_dc = dc_in;
pcm_dc(2:len) = dc_in(2:len)-dc_in(1:len-1);

for i = 1:len
    DCEncoding(pcm_dc(i))
end