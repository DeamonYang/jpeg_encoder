clc;
clear;
close all;
%pic_name = 'blk8x8.png';
pic_name = 'test1.png';
CELL_SIZE = 8;
img = imread(pic_name);
gray_img = rgb2gray(img);
gray_img_uint = gray_img;
% imshow(gray_img_uint);
gray_imgd = double(gray_img_uint) - 128;
y_image = gray_imgd;

%??????????????????
repeat_height = round(size(gray_img, 1)/CELL_SIZE);
repeat_width  = round(size(gray_img, 2)/CELL_SIZE);


%dct ????
y_dct_image = zeros(repeat_height*CELL_SIZE,repeat_width*CELL_SIZE);
A = double(int32(dctmtx(8)*2^8));
for i = 1:8:repeat_height*CELL_SIZE
	for j = 1:8:repeat_width*  CELL_SIZE
		y_dct_image(i:i+7, j:j+7) = A * y_image(i:i+7, j:j+7) * A';
	end
end

%??????????????
lum_tab = [
	16 11 10 16 24 40 51 61 	;
	12 12 14 19 26 58 60 55 	;
	14 13 16 24 40 57 69 56 	;
	14 17 22 29 51 87 80 62 	;
	18 22 37 56 68 109 103 77 	;
	24 35 55 64 81 104 113 92 	;
	49 64 78 87 103 121 120 101 ; 
	72 92 95 98 112 100 103 99];
%??????????????
chrom_tab = [
	17 18 24 47 99 99 99 99 ; 
	18 21 26 66 99 99 99 99 ; 
	24 26 56 99 99 99 99 99 ; 
	47 66 99 99 99 99 99 99 ; 
	99 99 99 99 99 99 99 99 ; 
	99 99 99 99 99 99 99 99 ; 
	99 99 99 99 99 99 99 99 ; 
	99 99 99 99 99 99 99 99];
%????
for i = 1:8:repeat_height*CELL_SIZE
	for j = 1:8:repeat_width*CELL_SIZE
		y_qua_image(i:i+7, j:j+7) = y_dct_image(i:i+7, j:j+7)./lum_tab;

	end
end
%????
y_qua_int_image = double(int16(round(y_qua_image)/(2^16)));

%zigzag
% zigzagorder = [
% 	1 9  2  3  10 17 25 18 11 4  5  12 19 26 33  ...
% 	41 34 27 20 13 6  7  14 21 28 35 42 49 57 50 ...  
% 	43 36 29 22 15 8  16 23 30 37 44 51 58 59 52 ...  
% 	45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 ...  
% 	62 63 56 64];
 zigzagorder = [
	 0  1  8 16  9  2  3 10 ...
	17 24 32 25 18 11  4  5 ...
	12 19 26 33 40 48 41 34 ...
	27 20 13  6  7 14 21 28 ...
	35 42 49 56 57 50 43 36 ...
	29 22 15 23 30 37 44 51 ...
	58 59 52 45 38 31 39 46 ...
	53 60 61 54 47 55 62 63];



y_zigzag_image = zeros(1,repeat_height*repeat_width*CELL_SIZE*CELL_SIZE);


%????????????
for i = 1:8:repeat_height*CELL_SIZE
	for j = 1:8:repeat_width*CELL_SIZE
        x = round(i/8);
        y = round(j/8);
		st = (x*repeat_width + y )*64 + 1;
        temp = reshape(y_qua_int_image(i:i+7, j:j+7)',[1 64 ]);
		y_zigzag_image(st : st + 63) = temp(zigzagorder + 1);
	end
end

%????????????
for i = 1:1:length(y_zigzag_image)/64
	y_dc(i) = y_zigzag_image((i -1)*64 + 1);

end

y_det_dc(1) = y_dc(1);

%????????????
for i = 2:1:length(y_zigzag_image)/64
	y_det_dc(i) = y_dc(i) - y_dc(i - 1);
end

%????????????
for i = 1:1:length(y_zigzag_image)/64
	y_zigzag_image((i -1)*64 + 1) = y_det_dc(i);
end
 

yzz = y_zigzag_image;
%????
ff = [];
ImageSeq=[];
ImageLen=[];
hexres_tot = [];
data_test = [-6,-11,21,15,-24,19,1,-1,7,4,4,3,0,-2,2,0,-1,5,-3,2,3,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
y_zigzag_image = [data_test, data_test];

y_zigzag_image(65) = 0;
y_zigzag_image = data_test;
%y_zigzag_image = data_test;
for i = 1:1:length(y_zigzag_image)/64
    st = (i -1)*64 + 1;
	y_data = y_zigzag_image(st : st + 63);
	
    %????????????????????????
	y_idx = 1;
    
	for j = 64:-1:1
		if y_data(j) ~= 0
			y_idx = j;
			break;
		end
    end
    
    ecd = y_data(1:y_idx);
    
	[DC_seq,DC_len] = DCEncoding(y_data(1));
    ff(i,2) = DC_len;
    
	%zerolen????0????0????????amplitude????0??????0??????????end=1010(????????EOB
    end_seq=dec2bin(10,4);
    AC_seq=[];
    blockbit_seq=[];
    zrl_seq=[];
    trt_seq=[];
    zerolen=0;
    zeronumber=0;
    
   
    
    %????????????????DC??????0??????0??AC????????0??????
	if numel(ecd)==1
	AC_seq=[];
	%blockbit_seq=[DC_seq,end_seq];%??????????????????????????
	blockbit_len=length(blockbit_seq);
	else 
	for i=2:y_idx
		if ( ecd(i)==0 & zeronumber<16)
			zeronumber=zeronumber+1;
			%16????0??????
		elseif (ecd(i)==0 & zeronumber==16); 
			bit_seq=dec2bin(2041,11);
			zeronumber=1;
			AC_seq=[AC_seq,bit_seq];
		elseif (ecd(i)~=0 & zeronumber==16)
			zrl_seq=dec2bin(2041,11);
			amplitude=ecd(i);
			trt_seq=ACEncoding(0,amplitude);
			bit_seq=[zrl_seq,trt_seq];
			AC_seq=[AC_seq,bit_seq];
			zeronumber=0;
		elseif(ecd(i))
			zerolen=zeronumber;          
			amplitude=ecd(i); 
			zeronumber=0;
			bit_seq=ACEncoding(zerolen,amplitude);
			AC_seq=[AC_seq,bit_seq];
		end
	end
	end                 
	blockbit_seq=[DC_seq,AC_seq,end_seq];
	blockbit_len=length(blockbit_seq);
	
	%blockbit_seq????????????????????blockbit_len??????????????????
	blockbit_seq;
	blockbit_len;
	ImageSeq=[ImageSeq,blockbit_seq];
	ImageLen=numel(ImageSeq);
    
    
    for i = 1 :(blockbit_len + 7)/8
        st = (i-1)*8 +  1;
        if (st + 7) <= blockbit_len
            res(i) = bin2dec(blockbit_seq(st:st + 7));
        else
            res(i) = bin2dec(blockbit_seq(st:blockbit_len));
        end
    end
    
    hexres = dec2hex(res)
    %hexres_tot = [hexres_tot,hexres']
end


























