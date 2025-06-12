CREATE PROGRAM discern_reginit:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 DECLARE syscmd = vc
 DECLARE error_str = vc
 DECLARE dclstat = i4
 DECLARE dclstat2 = i4
 DECLARE s_ccldir = vc
 DECLARE s_ccldir1 = vc
 DECLARE s_ccldiraccess = vc
 DECLARE aix_priverr = i4 WITH constant(32256), protect
 DECLARE aix_nofile = i4 WITH constant(32512), protect
 DECLARE vms_nofile = i4 WITH constant(98962), protect
 SET dclstat = 0
 SET dclstat2 = 0
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failure. Starting discern_reginit.prg"
 SET s_ccldiraccess = cnvtupper(trim(logical("CCLDIRACCESS")))
 SET s_ccldir = trim(logical("CCLDIR"))
 SET s_ccldir1 = trim(logical("CCLDIR1"))
 IF (s_ccldiraccess IN ("1READ*", "1WRITE*", "2READ*", "2WRITE*"))
  SET readme_data->status = "S"
  SET readme_data->message = concat("Readme success. CCLDIRACCESS already defined= ",s_ccldiraccess,
   ", CCLDIR1= ",s_ccldir1)
  GO TO endscript
 ENDIF
 IF (cursys="AIX")
  SET syscmd = "$cer_install/cclreginit.ksh"
 ELSEIF (cursys="AXP")
  SET syscmd = "@cer_install:cclreginit"
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = concat("No registry updates performed for CURSYS= ",trim(cursys))
  GO TO endscript
 ENDIF
 SET cmdlen = size(trim(syscmd))
 SET status = 0
 SET dclstat = dcl(syscmd,cmdlen,status)
 CALL echo(concat("Command= ",syscmd,", dclstat= ",build(dclstat),", status= ",
   build(status)))
 IF (status=0
  AND ((dclstat=aix_nofile) OR (dclstat=vms_nofile)) )
  IF (cursys="AIX"
   AND dclstat=aix_nofile)
   SET syscmd = "$cer_proc/cclreginit.ksh"
  ELSEIF (cursys="AXP"
   AND dclstat=vms_nofile)
   SET syscmd = "@cer_proc:cclreginit"
  ENDIF
  SET cmdlen = size(trim(syscmd))
  SET status = 0
  SET dclstat2 = dcl(syscmd,cmdlen,status)
  CALL echo(concat("Command= ",syscmd,", dclstat2= ",build(dclstat2),", status= ",
    build(status)))
  IF (cursys="AIX"
   AND dclstat2=aix_nofile)
   SET syscmd = "$cer_install/cclreginit.ksh"
  ELSEIF (cursys="AXP"
   AND dclstat2=vms_nofile)
   SET syscmd = "@cer_install:cclreginit"
  ENDIF
  SET dclstat = dclstat2
 ENDIF
 IF (status != 0)
  SET s_ccldir1 = trim(logical("CCLDIR1"))
  CALL echo(concat("Value of CCLDIR1=",s_ccldir1))
  SET readme_data->status = "S"
  SET readme_data->message = concat("Discern Registry updates successful, Command= ",syscmd,
   ", CCLDIR1=",trim(s_ccldir1))
  CALL echo(readme_data->message)
 ELSE
  SET readme_data->status = "F"
  IF (cursys="AIX")
   IF (dclstat=aix_nofile)
    SET error_str = " (cclreginit.ksh NOT FOUND)"
   ELSEIF (dclstat=aix_priverr)
    SET error_str = " (cclreginit.ksh EXECUTE PERMISSION DENIED)"
   ELSE
    SET error_str = " (REGISTRY UPDATE FAILED)"
   ENDIF
  ELSEIF (cursys="AXP")
   IF (dclstat=vms_nofile)
    SET error_str = " (cclreginit.com NOT FOUND)"
   ELSE
    SET error_str = " (REGISTRY UPDATE FAILED)"
   ENDIF
  ENDIF
  SET readme_data->message = concat("Failed to execute: ",syscmd,", error code= ",build(dclstat),
   error_str)
  CALL echo(readme_data->message)
 ENDIF
#endscript
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
