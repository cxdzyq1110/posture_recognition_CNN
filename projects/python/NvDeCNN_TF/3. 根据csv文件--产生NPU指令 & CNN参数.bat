python .\generate_npu_inst.py > npu_inst.txt
cd .\c_api
.\mainb.exe
.\change_crlf.exe inst.txt
.\change_crlf.exe para.txt
cd ..
pause