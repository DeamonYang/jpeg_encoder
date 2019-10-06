pic_name = 'sample2.bmp';
CELL_SIZE = 8;
img = imread(pic_name);
yuv_img = rgb2ycbcr(img);

y_image = yuv_img(:, :, 1);
u_image = yuv_img(:, :, 2);
v_image = yuv_img(:, :, 3);


y_image = double(y_image);
u_image = double(u_image);
v_image = double(v_image);


repeat_height = size(y_image, 1)/CELL_SIZE;
repeat_width  = size(y_image, 2)/CELL_SIZE;


%dct
y_dct_image = zeros(repeat_height*CELL_SIZE,repeat_width*CELL_SIZE);
u_dct_image = zeros(repeat_height*CELL_SIZE,repeat_width*CELL_SIZE);
v_dct_image = zeros(repeat_height*CELL_SIZE,repeat_width*CELL_SIZE);
A = dctmtx(8);
for i = 1:8:repeat_height*CELL_SIZE
	for j = 1:8:repeat_width*CELL_SIZE
		y_dct_image(i:i+7, j:j+7) = A * y_image(i:i+7, j:j+7) * A';
		u_dct_image(i:i+7, j:j+7) = A * u_image(i:i+7, j:j+7) * A';
		v_dct_image(i:i+7, j:j+7) = A * v_image(i:i+7, j:j+7) * A';
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
		u_qua_image(i:i+7, j:j+7) = u_dct_image(i:i+7, j:j+7)./chrom_tab;
		v_qua_image(i:i+7, j:j+7) = v_dct_image(i:i+7, j:j+7)./chrom_tab;
	end
end
%????
y_qua_int_image = round(y_qua_image);
u_qua_int_image = round(u_qua_image);
v_qua_int_image = round(v_qua_image);

%zigzag
zigzagorder = [
	1 9  2  3  10 17 25 18 11 4  5  12 19 26 33  ...
	41 34 27 20 13 6  7  14 21 28 35 42 49 57 50 ...  
	43 36 29 22 15 8  16 23 30 37 44 51 58 59 52 ...  
	45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 ...  
	62 63 56 64];

y_zigzag_image = zeros(1,repeat_height*repeat_width*CELL_SIZE*CELL_SIZE);
u_zigzag_image = zeros(1,repeat_height*repeat_width*CELL_SIZE*CELL_SIZE);
v_zigzag_image = zeros(1,repeat_height*repeat_width*CELL_SIZE*CELL_SIZE);

%????????????
for i = 1:8:repeat_height*CELL_SIZE
	for j = 1:8:repeat_width*CELL_SIZE
        x = round(i/8);
        y = round(j/8);
		st = (x*repeat_width + y )*64 + 1;	
		y_zigzag_image(st + zigzagorder -1) = reshape(y_qua_int_image(i:i+7, j:j+7),[1 64 ]);
		u_zigzag_image(st + zigzagorder -1) = reshape(u_qua_int_image(i:i+7, j:j+7),[1 64 ]);
		v_zigzag_image(st + zigzagorder -1) = reshape(v_qua_int_image(i:i+7, j:j+7),[1 64 ]);
	end
end

%????????????
for i = 1:1:length(y_zigzag_image)/64
	y_dc(i) = y_zigzag_image((i -1)*64 + 1);
	u_dc(i) = u_zigzag_image((i -1)*64 + 1);
	v_dc(i) = v_zigzag_image((i -1)*64 + 1);
end

y_det_dc(1) = y_dc(1);
u_det_dc(1) = u_dc(1);
v_det_dc(1) = v_dc(1);
%????????????
for i = 2:1:length(y_zigzag_image)/64
	y_det_dc(i) = y_dc(i) - y_dc(i - 1);
	u_det_dc(i) = u_dc(i) - u_dc(i - 1);
	v_det_dc(i) = v_dc(i) - v_dc(i - 1);
end

%????????????
for i = 1:1:length(y_zigzag_image)/64
	y_zigzag_image((i -1)*64 + 1) = y_det_dc(i);
	u_zigzag_image((i -1)*64 + 1) = u_det_dc(i);
	v_zigzag_image((i -1)*64 + 1) = v_det_dc(i);
end



%????
for i = 1:1:length(y_zigzag_image)/64
    st = (i -1)*64 + 1;
	y_data = y_zigzag_image(st : st + 63);
	u_data = u_zigzag_image(st : st + 63);
	v_data = v_zigzag_image(st : st + 63);
	
    %????????????????????????
	y_idx = 1;
	u_idx = 1;
	v_idx = 1;
    
	for j = 64:-1:1
		if y_data(j) ~= 0
			y_idx = j;
			break;
		end
    end
    
	for j = 64:-1:1
		if u_data(j) ~= 0
			u_idx = j;
			break;
		end
    end
    
	for j = 64:-1:1
		if v_data(j) ~= 0
			v_idx = j;
			break;
		end
	end	
	
	
	
end

























