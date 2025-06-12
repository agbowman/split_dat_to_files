CREATE PROGRAM bhs_hlp_ftp:dba
 EXECUTE bhs_hlp_err
 IF (validate(rl_debug_flag)=0)
  DECLARE rl_debug_flag = i4 WITH persistscript, constant(validate(bhs_debug_flag,0))
 ENDIF
 IF (rl_debug_flag >= 10)
  CALL echo(concat(curprog," helper script executed."))
  IF (rl_debug_flag >= 50)
   CALL echo("  Subroutine bhs_ftp_command declared.")
  ENDIF
 ENDIF
 DECLARE bhs_ftp_command(p_ftp_cmd=vc,p_rem_host=vc,p_user=vc,p_pass=vc,p_loc_dir=vc,
  p_rem_dir=vc,p_stdout=vc,p_stderr=vc) = i2 WITH persistscript
 SUBROUTINE bhs_ftp_command(p_ftp_cmd,p_rem_host,p_user,p_pass,p_loc_dir,p_rem_dir,p_stdout,p_stderr)
   DECLARE ms_ftp_cmd = vc WITH protect, noconstant(trim(p_ftp_cmd,3))
   DECLARE ms_rem_host = vc WITH protect, noconstant(trim(p_rem_host,3))
   DECLARE ms_user = vc WITH protect, noconstant(trim(p_user,3))
   DECLARE ms_pass = vc WITH protect, noconstant(trim(p_pass,3))
   DECLARE ms_loc_dir = vc WITH protect, noconstant(trim(p_loc_dir,3))
   DECLARE ms_rem_dir = vc WITH protect, noconstant(trim(p_rem_dir,3))
   DECLARE ms_stdout = vc WITH protect, noconstant(trim(p_stdout,3))
   DECLARE ms_stderr = vc WITH protect, noconstant(trim(p_stderr,3))
   DECLARE ms_dclcom = vc WITH protect, noconstant(" ")
   DECLARE ml_dclcom_len = i4 WITH protect, noconstant(0)
   DECLARE mn_status_ind = i2 WITH protect, noconstant(0)
   IF (((ms_ftp_cmd IN ("", " ", null)) OR (((ms_rem_host IN ("", " ", null)) OR (((ms_user IN ("",
   " ", null)) OR (ms_pass IN ("", " ", null))) )) )) )
    IF (rl_debug_flag >= 60)
     CALL echo("Missing required fields for bhs_ftp_command")
    ENDIF
    RETURN(0)
   ENDIF
   IF (ms_loc_dir IN ("", " ", null))
    SET ms_loc_dir = "./"
   ELSEIF (ms_loc_dir != "*/")
    SET ms_loc_dir = concat(ms_loc_dir,"/")
   ENDIF
   IF (ms_rem_dir IN ("", " ", null))
    SET ms_rem_dir = "./"
   ELSEIF (ms_rem_dir != "*/")
    SET ms_rem_dir = concat(ms_rem_dir,"/")
   ENDIF
   IF (ms_stdout IN ("", " ", null))
    SET ms_stdout = "&1"
   ENDIF
   IF (ms_stderr IN ("", " ", null))
    SET ms_stderr = "&2"
   ENDIF
   SET ms_dclcom = concat("cd ",ms_loc_dir,";",char(10),"`ftp -vin <<- END_INPUT 1>",
    ms_stdout," 2>",ms_stderr,char(10),"open ",
    ms_rem_host,char(10),"user ",ms_user," ",
    ms_pass,char(10),"cd ",ms_rem_dir,char(10),
    ms_ftp_cmd,char(10),"END_INPUT`")
   SET ml_dclcom_len = size(trim(ms_dclcom))
   SET mn_status_ind = 0
   IF (rl_debug_flag >= 90)
    CALL echo(concat("bhs_ftp_command ms_dclcom: ",ms_dclcom))
   ENDIF
   CALL dcl(ms_dclcom,ml_dclcom_len,mn_status_ind)
   IF (rl_debug_flag >= 80)
    CALL echo(concat("bhs_ftp_command status: ",cnvtstring(mn_status_ind)))
   ENDIF
   RETURN(mn_status_ind)
 END ;Subroutine
 DECLARE bhs_ftp_findfile(p_rem_host=vc,p_user=vc,p_pass=vc,p_rem_dir=vc,p_rem_file=vc) = i2 WITH
 persistscript
 SUBROUTINE bhs_ftp_findfile(p_rem_host,p_user,p_pass,p_rem_dir,p_rem_file)
   DECLARE ms_ftp_cmd = vc WITH protect, noconstant(concat('ls "',trim(p_rem_file,3),'"'))
   DECLARE ms_ftp_ls_file = vc WITH protect, noconstant(" ")
   DECLARE ms_dclcom = vc WITH protect, noconstant(" ")
   DECLARE ml_dclcom_len = i4 WITH protect, noconstant(0)
   DECLARE mn_status_ind = i2 WITH protect, noconstant(0)
   DECLARE mn_conn_open_ind = i2 WITH protect, noconstant(0)
   DECLARE mn_not_found_ind = i2 WITH protect, noconstant(0)
   SET ms_ftp_ls_file = concat("ftp_find_",build(currdbhandle),".txt")
   IF (bhs_ftp_command(ms_ftp_cmd,p_rem_host,p_user,p_pass,".",
    p_rem_dir,ms_ftp_ls_file," ")=0)
    IF (rl_debug_flag >= 99)
     CALL echo(concat("[POTENTIAL FALSE NEGATIVE]dcl for FTP ls command failed for file[",p_rem_file,
       "] ls[",ms_ftp_ls_file,"]"))
    ENDIF
   ENDIF
   IF (findfile(ms_ftp_ls_file)=0)
    IF (rl_debug_flag >= 50)
     CALL echo(concat("FTP ls file not found for file[",p_rem_file,"] ls[",ms_ftp_ls_file,"]"))
    ENDIF
    RETURN(0)
   ENDIF
   FREE DEFINE rtl2
   DEFINE rtl2 ms_ftp_ls_file
   SELECT INTO "nl:"
    FROM rtl2t r
    WHERE r.line > " "
     AND r.line != "*<DIR>*"
    DETAIL
     IF (r.line="*150*Opening ASCII mode data connection for*")
      mn_conn_open_ind = 1
     ELSE
      IF (r.line="*550*The system cannot find the file specified*")
       mn_not_found_ind = 1
      ELSEIF (r.line="*226*Transfer complete"
       AND mn_conn_open_ind=1)
       mn_not_found_ind = 1
      ENDIF
      mn_conn_open_ind = 0
     ENDIF
    WITH nocounter
   ;end select
   IF (bhs_error_thrown(0)=1)
    IF (rl_debug_flag >= 50)
     CALL echo(concat("Error encountered while checking reading FTP ls file for file[",p_rem_file,
       "] ls[",ms_ftp_ls_file,"]"))
    ENDIF
    RETURN(0)
   ENDIF
   IF (mn_not_found_ind=1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE bhs_ftp_cmd(p_ftp_cmd=vc,p_rem_host=vc,p_user=vc,p_pass=vc,p_loc_dir=vc,
  p_rem_dir=vc) = i2 WITH persistscript
 SUBROUTINE bhs_ftp_cmd(p_ftp_cmd,p_rem_host,p_user,p_pass,p_loc_dir,p_rem_dir)
   DECLARE ms_email = vc WITH protect, constant("CIScore@bhs.org")
   DECLARE ms_log_file_name = vc WITH protect, constant(trim(build2(cnvtlower(curprog),"_ftp_log_",
      rand(0),"_",format(cnvtdatetime(curdate,curtime3),"MMDDYYYYHHMMSS;;D")),8))
   DECLARE ms_ftp_cmd = vc WITH protect, noconstant(trim(p_ftp_cmd,3))
   DECLARE ms_rem_host = vc WITH protect, noconstant(trim(p_rem_host,3))
   DECLARE ms_user = vc WITH protect, noconstant(trim(p_user,3))
   DECLARE ms_pass = vc WITH protect, noconstant(trim(p_pass,3))
   DECLARE ms_loc_dir = vc WITH protect, noconstant(trim(p_loc_dir,3))
   DECLARE ms_rem_dir = vc WITH protect, noconstant(trim(p_rem_dir,3))
   DECLARE ms_stdout = vc WITH protect, noconstant(" ")
   DECLARE ms_stderr = vc WITH protect, noconstant(" ")
   DECLARE ms_dclcom = vc WITH protect, noconstant(" ")
   DECLARE ml_dclcom_len = i4 WITH protect, noconstant(0)
   DECLARE mn_status_ind = i2 WITH protect, noconstant(0)
   DECLARE mn_success_ind = i2 WITH protect, noconstant(0)
   DECLARE ms_tmp = vc WITH protect, noconstant(" ")
   IF (((ms_ftp_cmd IN ("", " ", null)) OR (((ms_rem_host IN ("", " ", null)) OR (((ms_user IN ("",
   " ", null)) OR (((ms_pass IN ("", " ", null)) OR (((ms_rem_dir IN ("", " ", null)) OR (ms_loc_dir
    IN ("", " ", null))) )) )) )) )) )
    IF (rl_debug_flag >= 60)
     CALL echo("Missing required fields for bhs_ftp_cmd")
    ENDIF
    RETURN(0)
   ENDIF
   IF (ms_loc_dir != "*/")
    SET ms_loc_dir = concat(ms_loc_dir,"/")
   ENDIF
   IF (ms_rem_dir != "*/")
    SET ms_rem_dir = concat(ms_rem_dir,"/")
   ENDIF
   SET ms_stdout = build2(ms_log_file_name,".out")
   SET ms_stderr = build2(ms_log_file_name,".err")
   SET ms_dclcom = concat("cd ",ms_loc_dir,";",char(10),"`ftp -vin <<- END_INPUT 1>",
    ms_stdout," 2>",ms_stderr,char(10),"open ",
    ms_rem_host,char(10),"user ",ms_user," ",
    ms_pass,char(10),"cd ",ms_rem_dir,char(10),
    ms_ftp_cmd,char(10),"END_INPUT`")
   SET ml_dclcom_len = size(trim(ms_dclcom))
   SET mn_status_ind = 0
   IF (rl_debug_flag >= 90)
    CALL echo(concat("bhs_ftp_cmd ms_dclcom: ",ms_dclcom))
   ENDIF
   CALL dcl(ms_dclcom,ml_dclcom_len,mn_status_ind)
   IF (rl_debug_flag >= 80)
    CALL echo(concat("bhs_ftp_cmd status: ",cnvtstring(mn_status_ind)))
   ENDIF
   FREE DEFINE rtl2
   DEFINE rtl2 ms_stdout
   SELECT INTO "nl:"
    FROM rtl2t r
    WHERE r.line > " "
    HEAD REPORT
     ms_tmp = build2(ms_tmp,"FTP Error Log for - ",curprog,char(13)), ms_tmp = build2(ms_tmp,value(
       ms_stdout),char(13),"*** begin of .out file",char(13))
    DETAIL
     CALL echo(r.line), ms_tmp = concat(ms_tmp,"   ",r.line,char(13))
     IF (r.line IN ("*226*Transfer complete*", "*250*DELE command successful*"))
      mn_success_ind = 1, mn_status_ind = 1
     ENDIF
    FOOT REPORT
     ms_tmp = build2(ms_tmp,"*** end of .out file",char(13),char(13))
    WITH nocounter
   ;end select
   IF (bhs_error_thrown(0)=1)
    IF (rl_debug_flag >= 50)
     CALL echo(concat("Error encountered while reading FTP log file [",ms_ftp_cmd,"]"))
    ENDIF
    RETURN(0)
   ENDIF
   IF (mn_success_ind=0)
    SET mn_status_ind = 0
    FREE DEFINE rtl2
    DEFINE rtl2 ms_stderr
    SELECT INTO "nl:"
     FROM rtl2t r
     WHERE r.line > " "
     HEAD REPORT
      ms_tmp = build2(ms_tmp,value(ms_stderr),char(13),"*** begin of .err file",char(13))
     DETAIL
      CALL echo(r.line), ms_tmp = concat(ms_tmp,"   ",r.line,char(13))
     FOOT REPORT
      ms_tmp = build2(ms_tmp,"*** end of .err file",char(13))
     WITH nocounter
    ;end select
    CALL echo("**** emailing logs..")
    CALL uar_send_mail(nullterm(ms_email),nullterm(build(logical("environment")," FTP Fail Log - ",
       curprog)),nullterm(ms_tmp),nullterm(logical("environment")),1,
     nullterm("IPM.NOTE"))
   ENDIF
   CALL pause(2)
   CALL echo("deleting email file")
   SET stat = remove(ms_stdout)
   IF (((stat=0) OR (findfile(ms_stdout)=1)) )
    CALL echo(build("unable to delete file: ",ms_stdout))
   ELSE
    CALL echo("file deleted")
   ENDIF
   SET stat = remove(ms_stderr)
   IF (((stat=0) OR (findfile(ms_stderr)=1)) )
    CALL echo(build("unable to delete file: ",ms_stderr))
   ELSE
    CALL echo("file deleted")
   ENDIF
   RETURN(mn_status_ind)
 END ;Subroutine
END GO
