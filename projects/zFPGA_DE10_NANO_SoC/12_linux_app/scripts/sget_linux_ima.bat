set /p rootip=please input linux host ip address: 
echo the host ip is : %rootip%  
::set rootip=192.168.1.7
pscp root@%rootip%:/home/root/original_bits.ima .\original_bits.ima
::pause