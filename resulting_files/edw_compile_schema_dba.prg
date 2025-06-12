CREATE PROGRAM edw_compile_schema:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD inputdata
 RECORD inputdata(
   1 file = vc
   1 com_file = vc
   1 new_file = vc
   1 logical_file = vc
 )
 FREE RECORD db_connect
 RECORD db_connect(
   1 connect_string = vc
   1 username = vc
   1 password = vc
   1 db_name = vc
 )
 DECLARE cmd_run(r_command=vc) = i2
 DECLARE create_compile_files(file_name=vc) = i2
 DECLARE error_msg = vc
 DECLARE connect_string = vc
 DECLARE parse_ind = i2
 DECLARE db = vc
 DECLARE cmp_stmt_str = vc
 DECLARE file_fix(f_vms=vc(value),f_aix=vc(value)) = i2 WITH protect
 DECLARE compile_objects(file_name=vc) = i2 WITH protect
 SET reply->status_data.status = "F"
 IF (reflect(parameter(1,0)) > " ")
  SET inputdata->file = parameter(1,0)
  SET inputdata->file = trim(inputdata->file,3)
  IF ((inputdata->file=" "))
   SET error_msg = "No SQL File passed in."
   GO TO exit_script
  ENDIF
 ELSE
  SET error_msg = "No SQL File passed in."
  GO TO exit_script
 ENDIF
 IF (reflect(parameter(2,0)) > " ")
  SET connect_string = parameter(2,0)
 ENDIF
 IF (size(trim(connect_string)) > 0)
  SET db_connect->connect_string = parameter(2,0)
  IF (cursys IN ("AIX", "AXP"))
   SET db_connect->connect_string = trim(cnvtupper(db_connect->connect_string))
  ELSE
   SET db_connect->username = "V500"
   SET db_connect->password = "V500"
   SET db_connect->db_name = trim(cnvtupper(db_connect->connect_string))
  ENDIF
 ELSE
  CALL echo("The connect string does not exist")
  GO TO exit_script
 ENDIF
 IF (reflect(parameter(3,0)) > " ")
  SET parse_ind = parameter(3,0)
 ENDIF
 IF (parse_ind=0)
  IF (cursys="AIX")
   CALL file_fix("cclsource:","$CCLSOURCE/")
   CALL file_fix("cer_install:","$cer_install/")
   CALL file_fix("ccluserdir:","$CCLUSERDIR/")
  ENDIF
  IF (currdb="ORACLE")
   IF ( NOT (create_compile_files(inputdata->file)))
    GO TO exit_script
   ENDIF
  ENDIF
  IF (cursys="AXP")
   CALL compile_objects(inputdata->com_file)
  ELSE
   CALL compile_objects(inputdata->file)
  ENDIF
 ELSE
  SET db = parameter(4,0)
  SET cmp_stmt_str = concat("OSQL -U ",db_connect->username," -P ",db_connect->password," -D ",
   db_connect->db_name," -Q ",'"',
   "if exists (select * from dbo.sysobjects where id = object_id(N'[V500].[",trim(cnvtupper(inputdata
     ->file)),
   "]') and OBJECTPROPERTY(id, N'IsView')=1) DROP VIEW [V500].[",trim(cnvtupper(inputdata->file)),"]"
   )
  CALL cmd_run(trim(cmp_stmt_str))
  SET cmp_stmt_str = concat("OSQL -U ",db_connect->username," -P ",db_connect->password," -D ",
   db_connect->db_name," -Q ",'"',"CREATE VIEW [V500].[",trim(cnvtupper(inputdata->file)),
   "]"," AS SELECT * FROM ",db,".",db,
   ".V500.",trim(cnvtupper(inputdata->file)),'"')
  CALL cmd_run(trim(cmp_stmt_str))
 ENDIF
 SET reply->status_data.status = "S"
 GO TO exit_script
 SUBROUTINE cmd_run(r_command)
   SET r_flag = 0
   SET r_len = size(r_command)
   CALL dcl(r_command,r_len,r_flag)
   RETURN(r_flag)
 END ;Subroutine
 SUBROUTINE file_fix(f_vms,f_aix)
   IF (findstring(f_vms,inputdata->file))
    SET inputdata->file = replace(inputdata->file,f_vms,f_aix,1)
   ENDIF
 END ;Subroutine
 SUBROUTINE create_compile_files(file_name)
   CALL echo("creating compile files")
   DECLARE com_found = i4
   IF (cursys="AXP")
    SET inputdata->com_file = concat("ccluserdir:pi",format(curtime3,"hhmmsscc;3;m"),".com")
    SELECT INTO value(inputdata->com_file)
     FROM (dummyt d  WITH seq = 1)
     PLAN (d)
     DETAIL
      IF (findfile("oracle_home:orauser.com"))
       CALL print("$@oracle_home:orauser"), row + 1, com_found = 1
      ELSEIF (findfile("ora_util:orauser.com"))
       CALL print("$@ora_util:orauser"), row + 1, com_found = 1
      ELSE
       CALL echo("orauser.com not found"), com_found = 0
      ENDIF
      CALL print(concat("$sqlplus ",db_connect->connect_string," @",file_name))
     WITH nocounter, format = variable, maxrow = 1,
      noformfeed, maxcol = 500
    ;end select
    IF (com_found=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (cursys="AIX")
    SET inputdata->new_file = concat("pi",format(curtime3,"hhmmsscc;3;m"),".sql")
    SET inputdata->logical_file = concat("ccluserdir:",inputdata->new_file)
    SET inputdata->new_file = concat("$CCLUSERDIR/",inputdata->new_file)
    IF (findstring(".sql",file_name) > 0)
     CALL cmd_run(concat("cp ",file_name," ",inputdata->new_file))
     CALL cmd_run(concat("chmod 777 ",inputdata->new_file))
     IF (findfile(inputdata->logical_file))
      SET inputdata->file = inputdata->new_file
     ELSE
      SET error_msg = "Unable to compile SQL file.  Temporary copy process failed."
      RETURN(0)
     ENDIF
    ENDIF
    IF (findstring(".sql",inputdata->file) > 0)
     SELECT INTO value(inputdata->logical_file)
      FROM (dummyt d  WITH seq = 1)
      PLAN (d)
      DETAIL
       row + 2, "exit;", row + 1
      WITH nocounter, append, noformfeed,
       format = variable, maxrow = 1
     ;end select
    ELSE
     SELECT INTO value(inputdata->logical_file)
      FROM (dummyt d  WITH seq = 1)
      PLAN (d)
      DETAIL
       col 0, "@", col + 0,
       inputdata->file, row + 1, "exit;",
       row + 1
      WITH nocounter, noformfeed, format = variable
     ;end select
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE compile_objects(file_name)
   IF (cursys="AIX")
    IF (findstring(".sql",inputdata->file) > 0)
     CALL cmd_run(concat("$ORACLE_HOME/bin/sqlplus ",db_connect->connect_string," @",file_name))
    ELSE
     CALL cmd_run(concat("$ORACLE_HOME/bin/sqlplus ",db_connect->connect_string," <",file_name))
    ENDIF
   ELSEIF (cursys="AXP")
    CALL cmd_run(concat("@",file_name))
   ELSEIF (cursys="WIN")
    CALL cmd_run(concat("OSQL -U ",db_connect->username," -P ",db_connect->password," -D ",
      db_connect->db_name," -i ",file_name))
   ELSE
    CALL cmd_run(concat("@",inputdata->com_file))
   ENDIF
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status="F"))
  CALL echo(concat("ERROR (",trim(inputdata->file),"):  ",trim(error_msg)))
 ELSE
  CALL echo(concat("SUCCESSFUL:  ",trim(inputdata->file)))
 ENDIF
 SET script_version = "000 01/19/06 YC3429"
END GO
