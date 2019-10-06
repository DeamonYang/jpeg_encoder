fd_gps_20p3m = fopen('pic_data_gray.data');
DATA_WID = 64;
DATA_HIG = 64;
datas = [];

for i = 1:DATA_HIG
   for j = 1:DATA_WID
        datas(i,j) = fread(fd_gps_20p3m,1 ,'uint8');
   end
end
datas_uint8 = uint8(datas);
[data cnt]= fread(fd_gps_20p3m,[DATA_WID DATA_HIG ],'uint8');

data_uint8 = uint8(data);


