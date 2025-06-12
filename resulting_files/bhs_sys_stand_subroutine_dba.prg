CREATE PROGRAM bhs_sys_stand_subroutine:dba
 CALL echo("EmailFile subroutine")
 DECLARE emailfile(filenamein=vc,filenameout=vc,eaddress=vc,emailsubject=vc,removefile=i2) = i2 WITH
 copy
 SUBROUTINE emailfile(filenamein,filenameout,emailaddress,emailsubject,removefileind)
   CALL echo("Emailing the file")
   IF (value(filenamein) != value(filenameout))
    SET ms_dclcom_rename = build2("mv -v ",filenamein," ",filenameout)
    CALL echo(ms_dclcom_rename)
    SET len = size(trim(ms_dclcom_rename))
    SET status = 0
    SET stat = dcl(ms_dclcom_rename,len,status)
    CALL echo(build("file rename status: ",stat))
   ENDIF
   CALL echo(filenameout)
   SET ms_dclcom_email = build2('echo ""',' | mailx -s "',emailsubject,'" -a "',filenameout,
    '" ',emailaddress)
   CALL echo(ms_dclcom_email)
   SET len = size(trim(ms_dclcom_email))
   SET status = 0
   SET stat = dcl(ms_dclcom_email,len,status)
   CALL echo(build("Status: ",stat))
   IF (removefileind=1)
    SET ms_dcl_remove = build2("rm ",trim(filenameout))
    SET len = size(trim(ms_dcl_remove))
    SET status = 0
    SET stat = dcl(ms_dcl_remove,len,status)
    IF (stat=0)
     CALL echo("File could not be removed")
    ELSE
     CALL echo("File was removed")
    ENDIF
   ENDIF
 END ;Subroutine
 CALL echo("validateCodeValue subroutine")
 DECLARE validatecodevalue(type=vc,codeset=i4,val=vc) = f8 WITH copy
 SUBROUTINE validatecodevalue(type,codeset,val)
   SET codeval = 0.0
   SET codeval = uar_get_code_by(value(type),codeset,value(val))
   IF (codeval <= 0)
    SET errmsg = concat("failed finding code_val - type: ",type," codeset:",build(codeset)," val:",
     val)
    SET esubject = concat(trim(curprog,3)," Code Value Error")
    CALL echo(concat("subject: ",esubject," msg: ",errmsg))
    CALL senderrmessage(esubject,errmsg)
   ELSE
    CALL echo(concat("type: ",type," codeset:",build(codeset)," val:",
      val," Code_value=",cnvtstring(codeval)))
   ENDIF
   RETURN(codeval)
 END ;Subroutine
 CALL echo("Send ErrMessages to CORE inbox for investigation")
 DECLARE senderrmessage(esubject=vc,errmsg=vc) = i2 WITH copy
 SUBROUTINE senderrmessage(esubject,errmsg)
   IF (validate(reqinfo->updt_id) > 0
    AND (reqinfo->updt_id > 0))
    SET euser = build(reqinfo->updt_id)
   ELSE
    SET euser = curuser
   ENDIF
   SET tempmsg = check(concat(errmsg,char(13),char(13),trim(curnode,3)," - ",
     trim(curprog,3),"- userID:",trim(euser,3)))
   CALL uar_send_mail("CISCore@bhs.org",esubject,tempmsg,"discernCCL@bhs.org",5,
    "IPM.NOTE")
 END ;Subroutine
 CALL echo("FTP a file ")
 DECLARE ftpfile(filenamein=vc,filenameout=vc,ipaddress=vc,folderdir=vc,username=vc,
  password=vc) = i2 WITH copy
 SUBROUTINE ftpfile(filenamein,filenameout,ipaddress,dir,username,password)
   CALL echo("FTPFile subroutine")
   DECLARE dclcom = vc WITH noconstant(" ")
   SET dclcom = concat("mv ",value(filenamein)," ",value(filenameout))
   CALL echo(dclcom)
   SET status = 0
   SET len = size(trim(dclcom))
   CALL dcl(dclcom,len,status)
   CALL echo("status:",status)
   SET dclcom = concat("$cust_script/bhs_ftp_file.ksh ",filenameout," ",ipaddress," ",
    username," ",password," ",folderdir)
   SET status = 0
   SET len = size(trim(dclcom))
   CALL echo(dclcom)
   CALL dcl(dclcom,len,status)
   CALL echo(build("status: ",status))
 END ;Subroutine
 CALL echo("SFTP a file ")
 DECLARE sftpfile(s_type=vc,s_file_name_in=vc,s_file_name_out=vc,s_user_name=vc,s_server_name=vc,
  s_local_dir=vc,s_back_dir=vc) = i2 WITH copy
 SUBROUTINE sftpfile(s_type,s_file_name_in,s_file_name_out,s_user_name,s_server_name,s_local_dir,
  s_back_dir)
   DECLARE ms_dcl = vc WITH protect, noconstant(" ")
   DECLARE ml_length = i4 WITH protect, noconstant(0)
   DECLARE mn_status = i2 WITH protect, noconstant(0)
   DECLARE ml_dcl_status = i4 WITH protect, noconstant(0)
   DECLARE ms_parameters = vc WITH protect, noconstant("")
   IF (s_user_name="")
    SET ms_parameters = s_server_name
   ELSE
    SET ms_parameters = concat(value(s_user_name),"@",value(s_server_name))
   ENDIF
   CALL echo("SFTPFile subroutine")
   IF (s_type="SENT FILE")
    SET ms_dcl = concat("cd ",value(s_local_dir))
    SET mn_status = 0
    SET ml_length = size(trim(ms_dcl))
    CALL echo(ms_dcl)
    SET ml_dcl_status = dcl(ms_dcl,ml_length,mn_status)
    CALL echo("Status (1 - Success): ",mn_status)
    IF (ml_dcl_status > 0)
     CALL echo("Error Number: ",(ml_dcl_status/ 256))
    ENDIF
    SET ms_dcl = concat("mv ",value(s_file_name_in)," ",value(s_file_name_out))
    SET mn_status = 0
    SET ml_length = size(trim(ms_dcl))
    CALL echo(ms_dcl)
    SET ml_dcl_status = dcl(ms_dcl,ml_length,mn_status)
    CALL echo("Status (1 - Success): ",mn_status)
    IF (ml_dcl_status > 0)
     CALL echo("Error Number: ",(ml_dcl_status/ 256))
    ENDIF
    SET ms_dcl = concat("$cust_script/bhs_sftp_file.ksh ",value(ms_parameters),":",value(s_back_dir),
     " ",
     value(s_file_name_out))
    SET mn_status = 0
    SET ml_length = size(trim(ms_dcl))
    CALL echo(ms_dcl)
    SET ml_dcl_status = dcl(ms_dcl,ml_length,mn_status)
    CALL echo("Status (1 - Success): ",mn_status)
    IF (ml_dcl_status > 0)
     CALL echo("Error Number: ",(ml_dcl_status/ 256))
    ENDIF
   ELSE
    SET ms_dcl = concat("cd ",value(s_local_dir))
    SET mn_status = 0
    SET ml_length = size(trim(ms_dcl))
    CALL echo(ms_dcl)
    SET ml_dcl_status = dcl(ms_dcl,ml_length,mn_status)
    CALL echo("Status (1 - Success): ",mn_status)
    IF (ml_dcl_status > 0)
     CALL echo("Error Number: ",(ml_dcl_status/ 256))
    ENDIF
    SET ms_dcl = concat("$cust_script/bhs_sftp_file_get.ksh ",value(ms_parameters)," :",value(
      s_back_dir),"/ ",
     value(s_file_name_in)," ",value(s_local_dir))
    SET mn_status = 0
    SET ml_length = size(trim(ms_dcl))
    CALL echo(ms_dcl)
    SET ml_dcl_status = dcl(ms_dcl,ml_length,mn_status)
    CALL echo("Status (1 - Success): ",mn_status)
    IF (ml_dcl_status > 0)
     CALL echo("Error Number: ",(ml_dcl_status/ 256))
    ENDIF
    SET ms_dcl = concat("mv ",value(s_file_name_in)," ",value(s_file_name_out))
    SET mn_status = 0
    SET ml_length = size(trim(ms_dcl))
    CALL echo(ms_dcl)
    SET ml_dcl_status = dcl(ms_dcl,ml_length,mn_status)
    CALL echo("Status (1 - Success): ",mn_status)
    IF (ml_dcl_status > 0)
     CALL echo("Error Number: ",(ml_dcl_status/ 256))
    ENDIF
   ENDIF
 END ;Subroutine
END GO
