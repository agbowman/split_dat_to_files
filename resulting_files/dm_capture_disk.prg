CREATE PROGRAM dm_capture_disk
 PAINT
 SET width = 132
 IF (cursys != "AIX")
  CALL text(18,1,"Program is in process, Please wait......")
  SET dclcom = "@cer_install:dm_capture_disk_com.com"
  SET len = size(trim(dclcom))
  SET status = 0
  SET width = 132
  CALL dcl(dclcom,len,status)
 ELSE
  CALL clear(1,1)
  CALL text(18,1,"Program is in process, Please wait......")
  SET dclcom = "chmod 755 $cer_install/dm_capture_disk_ksh.ksh"
  SET len = size(trim(dclcom))
  SET status = 0
  CALL dcl(dclcom,len,status)
  SET dclcom = "$cer_install/dm_capture_disk_ksh.ksh"
  SET len = size(trim(dclcom))
  SET status = 0
  CALL dcl(dclcom,len,status)
 ENDIF
 SET message = nowindow
 CALL compile("dm_insert_disk.ccl","dm_insert_disk_error.dat")
 COMMIT
END GO
