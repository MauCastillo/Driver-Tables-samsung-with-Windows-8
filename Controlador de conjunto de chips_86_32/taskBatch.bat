SamsungConfiguration -Install -u
reg delete HKLM\Software\Samsung\SamsungConfiguration /v ErrorCode /f

reg add HKLM\Software\Samsung\SamsungConfiguration /v ErrorCode /t REG_SZ /d "43 10"
mkdir "C:\Programdata\Samsung\Service"
