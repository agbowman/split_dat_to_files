CREATE PROGRAM discern_core_readme:dba
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
 CALL echo("Invoking Discern_core_readme via readme 3618 is obsolete")
 SUBROUTINE (execsyscommand(execcmd=vc,cmdstat=i2(ref),logtext=vc) =i2)
   SET lencmd = size(trim(execcmd))
   SET status = 0
   SET readme_data->message = concat(logtext," CCL component: Command=",execcmd)
   EXECUTE dm_readme_status
   IF (install_test=1)
    SET cmdstat = 1
    CALL echo(concat("Sys command= ",execcmd))
    RETURN(1)
   ENDIF
   CALL dcl(execcmd,lencmd,status)
   IF (status=1)
    SET cmdstat = 1
   ELSE
    SET readme_data->message = concat("ERROR! Failed to ",logtext," component. Command= ",execcmd)
    SET cmdstat = 0
   ENDIF
   RETURN(cmdstat)
 END ;Subroutine
 DECLARE proccmd = vc
 DECLARE copycmd1 = vc
 DECLARE copycmd2 = vc
 DECLARE lencmd = i4
 DECLARE status = i4
 DECLARE logicaltest = vc
 DECLARE rdbmsver = c5
 DECLARE rdbmsproductver = vc
 DECLARE displayver = vc
 DECLARE releasever = vc
 DECLARE ocdnum = i4
 DECLARE ocdstr = vc
 DECLARE ocdbackupdir = vc
 DECLARE rdbstr = vc
 DECLARE cmdstat1 = i2
 DECLARE cmdstat2 = i2
 DECLARE installdomain = vc
 DECLARE installsuccess = i2
 SET installsuccess = 1
 DECLARE install_test = i2 WITH public
 SET install_test = 0
 IF (validate(discern_core_test,0) != 0)
  SET install_test = 1
  CALL echo("Discern_core_install: test mode set")
 ENDIF
 SET ocdnum = 0
 IF (currev=7)
  SET ocdnum = readme_data->ocd
  SET ocdstr = format(trim(cnvtstring(ocdnum)),"######;lp0")
  IF (cursys="AXP")
   SET ocdbackupdir = concat("cer_ocd:[",ocdstr,".backup]")
  ELSE
   SET ocdbackupdir = concat("$cer_ocd/",ocdstr,"/backup/")
  ENDIF
 ENDIF
 SET installdomain = cnvtupper(logical("ENVIRONMENT"))
 SET rdbstr = trim(cnvtupper(currdb))
 IF (rdbstr="ORACLE")
  IF (installdomain="ADMIN")
   SET readme_data->message = concat("Update of CCL images not attempted for Admin domain")
   SET installsuccess = 2
   GO TO exit_readme
  ENDIF
  SELECT INTO "NL:"
   p.product, p.version
   FROM product_component_version p
   WHERE cnvtupper(substring(1,6,p.product))="ORACLE"
   DETAIL
    rdbmsproductver = cnvtupper(substring(1,7,p.product)), displayver = substring(1,5,p.version),
    releasever = substring(1,3,p.version)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET readme_data->message = "ERROR! Failed to read Oracle version from PRODUCT_COMPONENT_VERSION."
   SET installsuccess = 0
   GO TO exit_readme
  ELSE
   SET readme_data->message = concat("Oracle version ",displayver," is installed in this domain.")
   EXECUTE dm_readme_status
  ENDIF
 ELSE
  SET rdbmsproductver = rdbstr
 ENDIF
 IF (cursys="AXP")
  GO TO install_axp
 ENDIF
#install_aix
 SET readme_data->message = concat("AIX installation for current RDBMS= ",rdbstr)
 EXECUTE dm_readme_status
 IF (currev >= 8)
  SET copycmd1 = concat("cp -p $cer_exe/libcclora.a $cer_exe/libcclora_bak.a")
  SET copycmd2 = concat("cp -p $cer_exe/libcclsqloci.a $cer_exe/libcclsqloci_bak.a")
  CALL execsyscommand(copycmd1,cmdstat1,"Backup")
  IF (cmdstat1=0)
   SET readme_data->message = concat("Failed to backup file: Command=",copycmd1)
   EXECUTE dm_readme_status
  ENDIF
  CALL execsyscommand(copycmd2,cmdstat2,"Backup")
  IF (cmdstat2=0)
   SET readme_data->message = concat("Failed to backup file: Command=",copycmd2)
   EXECUTE dm_readme_status
  ENDIF
  IF (rdbstr="ORACLE")
   IF (rdbmsproductver="ORACLE8")
    SET copycmd1 = "cp -f -p $cer_exe/libcclora_81.a $cer_exe/libcclora.a"
    SET copycmd2 = "cp -f -p $cer_exe/libcclsqloci_81.a $cer_exe/libcclsqloci.a"
   ELSEIF (rdbmsproductver="ORACLE9")
    SET copycmd1 = "cp -f -p $cer_exe/libcclora_92.a $cer_exe/libcclora.a"
    SET copycmd2 = "cp -f -p $cer_exe/libcclsqloci_92.a $cer_exe/libcclsqloci.a"
   ELSEIF (rdbmsproductver="ORACLE"
    AND cnvtint(substring(1,2,releasever))=10)
    SET copycmd1 = "cp -f -p $cer_exe/libcclora_92.a $cer_exe/libcclora.a"
    SET copycmd2 = "cp -f -p $cer_exe/libcclsqloci_92.a $cer_exe/libcclsqloci.a"
   ELSE
    SET readme_data->message = concat("ERROR! RDBMS version not supported= ",rdmsproductver)
    GO TO exit_readme
   ENDIF
  ELSEIF (((rdbstr="DB2") OR (rdbstr="DB2UDB")) )
   SET copycmd1 = "cp -f -p $cer_exe/libccldb2.a $cer_exe/libcclora.a"
   SET copycmd2 = "cp -f -p $cer_exe/libcclsqlocidb2.a $cer_exe/libcclsqloci.a"
  ENDIF
  CALL execsyscommand(copycmd1,cmdstat1,"Install")
  IF (cmdstat1=0)
   GO TO exit_readme
  ENDIF
  CALL execsyscommand(copycmd2,cmdstat2,"Install")
  IF (cmdstat2=0)
   GO TO exit_readme
  ENDIF
 ELSE
  SET copycmd1 = concat("cp -f $cer_exe/libdb.a ","$cer_ocd/",ocdstr,"/backup/libdb.a")
  CALL execsyscommand(copycmd1,cmdstat1,"Backup")
  SET copycmd2 = concat("cp -f $cer_ocd/",ocdstr,"/exe/libdb.a $cer_exe/libdb.a")
  CALL execsyscommand(copycmd2,cmdstat2,"Install")
  IF (((cmdstat1=0) OR (cmdstat2=0)) )
   GO TO exit_readme
  ENDIF
 ENDIF
 SET installsuccess = 1
 GO TO exit_readme
#install_axp
 IF (rdbstr="ORACLE")
  SET readme_data->message = concat(
   "Components SHRCCLORA.EXE and SHRCCLSQLOCI.EXE will be installed for Oracle version: ",displayver)
  EXECUTE dm_readme_status
  SET copycmd1 = concat(
   "BACKUP /NEW CER_WH1:[VMSALPHA]SHRCCLORA.EXE; CER_WH1:[VMSALPHA]SHRCCLORA.EXE_BAK;")
  SET copycmd2 = concat(
   "BACKUP /NEW CER_WH1:[VMSALPHA]SHRCCLSQLOCI.EXE; CER_WH1:[VMSALPHA]SHRCCLSQLOCI.EXE_BAK;")
  CALL execsyscommand(copycmd1,cmdstat1,"Backup")
  IF (cmdstat1=0)
   SET readme_data->message = concat("Failed to backup file: Command=",copycmd1)
   EXECUTE dm_readme_status
  ENDIF
  CALL execsyscommand(copycmd2,cmdstat2,"Backup")
  IF (cmdstat2=0)
   SET readme_data->message = concat("Failed to backup file: Command=",copycmd2)
   EXECUTE dm_readme_status
  ENDIF
  IF (rdbmsproductver="ORACLE8")
   SET copycmd1 = "BACKUP /NEW CER_WH1:[VMSALPHA]SHRCCLORA_81.EXE; CER_WH1:[VMSALPHA]SHRCCLORA.EXE"
   SET copycmd2 =
   "BACKUP /NEW CER_WH1:[VMSALPHA]SHRCCLSQLOCI_81.EXE; CER_WH1:[VMSALPHA]SHRCCLSQLOCI.EXE"
  ELSEIF (rdbmsproductver="ORACLE9")
   SET copycmd1 = "BACKUP /NEW CER_WH1:[VMSALPHA]SHRCCLORA_92.EXE; CER_WH1:[VMSALPHA]SHRCCLORA.EXE"
   SET copycmd2 =
   "BACKUP /NEW CER_WH1:[VMSALPHA]SHRCCLSQLOCI_92.EXE; CER_WH1:[VMSALPHA]SHRCCLSQLOCI.EXE"
  ELSEIF (rdbmsproductver="ORACLE"
   AND cnvtint(substring(1,2,releasever))=10)
   SET copycmd1 = "BACKUP /NEW CER_WH1:[VMSALPHA]SHRCCLORA_92.EXE; CER_WH1:[VMSALPHA]SHRCCLORA.EXE"
   SET copycmd2 =
   "BACKUP /NEW CER_WH1:[VMSALPHA]SHRCCLSQLOCI_92.EXE; CER_WH1:[VMSALPHA]SHRCCLSQLOCI.EXE"
  ELSEIF (rdbmsproductver="ORACLE7"
   AND currev=7)
   SET copycmd1 = "BACKUP /NEW CER_WH1:[VMSALPHA]SHRCCLORA_73.EXE; CER_WH1:[VMSALPHA]SHRCCLORA.EXE"
   SET copycmd2 =
   "BACKUP /NEW CER_WH1:[VMSALPHA]SHRCCLSQLOCI_73.EXE; CER_WH1:[VMSALPHA]SHRCCLSQLOCI.EXE"
  ELSE
   SET readme_data->message = concat("ERROR! RDBMS version not supported= ",rdmsproductver)
   GO TO exit_readme
  ENDIF
  CALL execsyscommand(copycmd1,cmdstat1,"Install")
  IF (cmdstat1=0)
   GO TO exit_readme
  ENDIF
  CALL execsyscommand(copycmd2,cmdstat2,"Install")
  IF (cmdstat2=0)
   GO TO exit_readme
  ENDIF
  SET installcmd1 = "INSTALL REPLACE /OPEN/SHARED/HEADER SHRCCLORA"
  SET installcmd2 = "INSTALL REPLACE /OPEN/SHARED/HEADER SHRCCLSQLOCI"
  CALL execsyscommand(installcmd1,cmdstat1,"Install")
  IF (cmdstat1=0)
   GO TO exit_readme
  ENDIF
  CALL execsyscommand(installcmd2,cmdstat2,"Install")
  IF (cmdstat2=0)
   GO TO exit_readme
  ENDIF
 ELSE
  SET readme_data->message = concat("Install failed! Unsupoorted RDBMS version= ",rdbstr)
  SET installsuccess = 0
  GO TO exit_readme
 ENDIF
#define_cclsqloci
 SET logicaltest = cnvtupper(logical("SHRCCLSQLOCI"))
 IF (logicaltest != "CER_EXE:SHRCCLSQLOCI.EXE"
  AND logicaltest != "CER_EXE:SHRCCLSQLOCI")
  SET readme_data->message =
  "Calling @CER_INSTALL:INSTALL_DISCERN LOGICALDEF to add logical to registry. Required privs= CMKRNL,GRPNAM,SYSLCK"
  EXECUTE dm_readme_status
  SET proccmd = "@CER_INSTALL:INSTALL_DISCERN LOGICALDEF"
  SET lencmd = size(trim(proccmd))
  SET status = 0
  CALL dcl(proccmd,lencmd,status)
  IF (status=0)
   SET readme_data->message =
   "ERROR creating logical. Command=@CER_INSTALL:INSTALL_DISCERN LOGICALDEF. Required privs= CMKRNL,GRPNAM,SYSLCK"
   SET installsuccess = 0
   GO TO exit_readme
  ENDIF
  SET readme_data->message = "Defining group level logical for SHRCCLSQLOCI..."
  EXECUTE dm_readme_status
  SET proccmd = "define /group shrcclsqloci cer_exe:shrcclsqloci.exe"
  SET lencmd = size(trim(proccmd))
  SET status = 0
  CALL dcl(proccmd,lencmd,status)
  SET logicaltest = cnvtupper(logical("SHRCCLSQLOCI"))
  IF (logicaltest != "CER_EXE:SHRCCLSQLOCI.EXE")
   SET readme_data->message =
   "ERROR!  Failed to define group level logical for SHRCCLSQLOCI.  Required privs= CMKRNL,GRPNAM,SYSLCK"
   EXECUTE dm_readme_status
   SET installsuccess = 0
  ENDIF
 ENDIF
#exit_readme
 IF (installsuccess=1)
  IF (install_test=1)
   SET readme_data->message = concat("Discern Core readme success. Images installed for RDBMS= ",
    concat(rdbmsproductver)," (test mode only)")
  ELSE
   SET readme_data->message = concat("Discern Core readme success. Images installed for RDBMS= ",
    concat(rdbmsproductver))
  ENDIF
  SET readme_data->status = "S"
 ELSEIF (installsuccess=2)
  SET readme_data->status = "S"
 ELSE
  SET readme_data->status = "F"
 ENDIF
 EXECUTE dm_readme_status
END GO
