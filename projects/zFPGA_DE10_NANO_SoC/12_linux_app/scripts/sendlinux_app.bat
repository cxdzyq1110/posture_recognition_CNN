set /p rootip=please input linux host ip address: 
echo the host ip is : %rootip%  
::set rootip=192.168.1.7
pscp ..\make\my_first_hps-fpga root@%rootip%:/home/root
pause