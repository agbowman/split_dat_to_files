CREATE PROGRAM bhs_l_login_id_status_csv:dba
 PROMPT
  "Output to File/Printer/MINE" = "David.Hounshell@bhs.org"
  WITH outdev
 EXECUTE bhs_hlp_ftp
 EXECUTE bhs_hlp_err
 EXECUTE bhs_hlp_lock
 DECLARE ms_files_loc_dir = vc WITH protect, constant(logical("ccluserdir"))
 DECLARE ms_files_rem_dir = vc WITH protect, constant('"/AD Import"')
 DECLARE ms_ftp_host = vc WITH protect, constant("bhsftp01")
 DECLARE ms_ftp_username = vc WITH protect, constant('"bhs\cisftp"')
 DECLARE ms_ftp_password = vc WITH protect, constant("C!sftp01")
 DECLARE mf_active_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE"))
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE ml_email_ind = i4 WITH protect, noconstant(0)
 DECLARE ml_ftp_ind = i4 WITH protect, noconstant(0)
 DECLARE ml_lncnt = i4 WITH protect, noconstant(0)
 DECLARE ms_output_string = vc WITH protect, noconstant(" ")
 DECLARE ms_colstring_label = vc WITH protect, noconstant(" ")
 DECLARE ms_dclcom = vc WITH protect, noconstant(" ")
 DECLARE ms_ftp_cmd = vc WITH protect, noconstant(" ")
 DECLARE ms_filename_out = vc WITH protect, noconstant(" ")
 DECLARE ms_subject_line = vc WITH protect, noconstant(" ")
 DECLARE ms_output_dest = vc WITH protect, noconstant(" ")
 DECLARE ms_user_name = vc WITH protect, noconstant(" ")
 IF (validate(reply->status_data[1].status)=0)
  FREE RECORD reply
  RECORD reply(
    1 status_data[1]
      2 status = c1
  )
 ENDIF
 SET reply->status_data[1].status = "F"
 IF (findstring("@", $1) > 0)
  SET ms_output_dest = build(format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHHMMSS;;D"))
  SET ml_email_ind = 1
 ELSEIF (findstring("FTP", $1) > 0)
  SET ms_filename_out = concat(trim(format(curdate,"YYYYMMDD;;D")),"_active_users",".csv")
  SET ms_output_dest = ms_filename_out
  SET ml_ftp_ind = 1
 ELSE
  SET ms_output_dest =  $1
 ENDIF
 SELECT INTO value(ms_output_dest)
  FROM prsnl p
  ORDER BY p.username
  HEAD REPORT
   IF (ml_ftp_ind=1)
    ms_colstring_label = build(char(09),"Login",char(09),"Full Name"), col + 1, ms_colstring_label
   ELSE
    "Ln#,", "Stat Desc,", "Login,",
    "Phys,", "Full Name,", "Person_ID,",
    "Position Description,", "Begin DateTm,", "End DateTm,",
    "UpDate DateTm,", "UpDate ID,", "ActInd,",
    "Position CD,", "StatCD,"
   ENDIF
  HEAD p.name_full_formatted
   xp_active_status_disp = uar_get_code_display(p.active_status_cd), xstat_desp =
   IF (p.active_status_cd=194) "SPNDED"
   ELSEIF (p.active_status_cd=192) "InAct"
   ELSEIF (p.active_status_cd=189) "COMB"
   ELSE uar_get_code_display(p.active_status_cd)
   ENDIF
   , xp_position_disp = uar_get_code_display(p.position_cd),
   xbegdttm = format(p.beg_effective_dt_tm,"yyyy-mm-dd hh:mm:ss"), xenddttm = format(p
    .end_effective_dt_tm,"yyyy-mm-dd hh:mm:ss"), xupdtdttm = format(p.updt_dt_tm,
    "yyyy-mm-dd hh:mm:ss"),
   xphysflag =
   IF (p.physician_ind=1) "*"
   ELSE " "
   ENDIF
   IF ( NOT (trim(p.username) IN ("", " ", null)))
    ms_user_name = p.username
   ELSE
    ms_user_name = "NONE"
   ENDIF
   ml_lncnt = (ml_lncnt+ 1)
   IF (ml_ftp_ind=1)
    IF (p.active_status_cd=mf_active_cd)
     ms_output_string = build(char(09),'"',ms_user_name,'"',char(09),
      '"',p.name_full_formatted,'"'), row + 1, ms_output_string
    ENDIF
   ELSE
    ms_output_string = build(ml_lncnt,',"',xstat_desp,'"',',"',
     p.username,'"',',"',xphysflag,'"',
     ',"',p.name_full_formatted,'"',",",p.person_id,
     ',"',xp_position_disp,'"',",",xbegdttm,
     ",",xenddttm,",",xupdtdttm,",",
     p.updt_id,",",p.active_ind,",",p.position_cd,
     ",",p.active_status_cd), row + 1, ms_output_string
   ENDIF
  WITH format = variable, formfeed = none, maxcol = 2000
 ;end select
 IF (ml_email_ind=1)
  SET filename_in = trim(concat(ms_output_dest,".dat"))
  SET ms_filename_out = concat(format(curdate,"YYYY-MM-DD ;;D"),"_daily_status",".csv")
  SET ms_subject_line = concat(curprog,"-V5.2 - Daily ID Status ",curnode)
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,ms_filename_out, $1,ms_subject_line,1)
 ENDIF
 IF (ml_ftp_ind=1)
  SET ms_ftp_cmd = concat("put ",ms_filename_out)
  SET stat = bhs_ftp_command(ms_ftp_cmd,ms_ftp_host,ms_ftp_username,ms_ftp_password,ms_files_loc_dir,
   ms_files_rem_dir,"/dev/null"," ")
  IF (bhs_ftp_findfile(ms_ftp_host,ms_ftp_username,ms_ftp_password,ms_files_rem_dir,ms_filename_out)=
  1)
   SET ms_dclcom = concat("rm -f ",ms_files_loc_dir,"/",ms_filename_out)
   CALL echo(build("DCL:",ms_dclcom))
   CALL dcl(ms_dclcom,size(trim(ms_dclcom)),stat)
  ELSE
   CALL echo("Error: FTP has failed to transfer the file properly")
   GO TO end_prog
  ENDIF
 ENDIF
 SET reply->status_data[1].status = "S"
#end_prog
END GO
