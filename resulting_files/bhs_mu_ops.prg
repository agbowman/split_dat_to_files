CREATE PROGRAM bhs_mu_ops
 EXECUTE bhs_hlp_ftp
 EXECUTE bhs_hlp_err
 EXECUTE bhs_hlp_lock
 DECLARE ms_dir_loc_mu_in = vc WITH protect, constant(build(logical("bhscust"),"/mu/in/"))
 DECLARE ms_dir_loc_mu_out = vc WITH protect, constant(build(logical("bhscust"),"/mu/out/"))
 DECLARE ms_dir_rem_mu_in = vc WITH protect, constant("/ciscoremuin/")
 DECLARE ms_dir_rem_mu_out = vc WITH protect, constant("/ciscoremuout/")
 DECLARE ms_ftp_host = vc WITH protect, constant("transfer.baystatehealth.org")
 DECLARE ms_ftp_username = vc WITH protect, constant('"bhs\cisftp"')
 DECLARE ms_ftp_password = vc WITH protect, constant("C!sftp01")
 DECLARE ms_mu_file_in_ls = vc WITH protect, constant("bhs_mu_in_ls.txt")
 DECLARE ms_lock_mu_domain = vc WITH protect, constant("BHS MU Locks")
 DECLARE ms_lock_mu_name = vc WITH protect, constant("Meaningful Use CIS Lock")
 DECLARE ml_debug_flag = i4 WITH protect, constant(validate(bhs_debug_flag,0))
 DECLARE mn_unknown = i4 WITH protect, constant(0)
 DECLARE mn_rpt_inpatient = i4 WITH protect, constant(1)
 DECLARE mn_rpt_ambulatory = i4 WITH protect, constant(2)
 DECLARE mn_rpt_sms = i4 WITH protect, constant(3)
 DECLARE mn_rpt_wnerta = i4 WITH protect, constant(4)
 DECLARE mn_rpt_recurring = i4 WITH protect, constant(5)
 DECLARE ms_tempstring = vc WITH protect, noconstant(" ")
 DECLARE ms_dclcom = vc WITH protect, noconstant(" ")
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 DECLARE ms_file_out = vc WITH protect, noconstant(" ")
 DECLARE ms_ftp_cmd = vc WITH protect, noconstant(" ")
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_rpt_type = i4 WITH protect, noconstant(0)
 DECLARE ml_lock_status = i4 WITH protect, noconstant(rl_lock_status_unknown)
 IF (validate(reply->c_status)=0)
  RECORD reply(
    1 c_status = c1
  )
 ENDIF
 SET reply->c_status = "F"
 FREE RECORD bme_reply
 RECORD bme_reply(
   1 c_status = c1
 )
 SET bme_reply->c_status = "Z"
 FREE RECORD bmr_reply
 RECORD bmr_reply(
   1 c_status = c1
 )
 SET bmr_reply->c_status = "Z"
 FREE RECORD mu_in
 RECORD mu_in(
   1 qual[*]
     2 s_filename = vc
 )
 IF (ml_debug_flag >= 1)
  CALL echo(concat("Starting script script ",curprog))
 ENDIF
 IF (bhs_lock(ms_lock_mu_domain,ms_lock_mu_name,1,0,ml_lock_status)=0)
  CALL echo("There is already an instance of this script running.  Exiting...")
  IF (bhs_last_locked(ms_lock_mu_domain,ms_lock_mu_name,rl_lock_success,ms_line)=1)
   CALL echo(ms_line)
  ENDIF
  GO TO exit_script
 ENDIF
 SET ms_dclcom = concat("rm -f ",ms_dir_loc_mu_in,"*")
 CALL echo(build("DCL:",ms_dclcom))
 CALL dcl(ms_dclcom,size(trim(ms_dclcom)),stat)
 SET ms_dclcom = concat("rm -f ",ms_dir_loc_mu_out,"*")
 CALL echo(build("DCL:",ms_dclcom))
 CALL dcl(ms_dclcom,size(trim(ms_dclcom)),stat)
 SET ms_ftp_cmd = "mget *.*"
 SET stat = bhs_ftp_command(ms_ftp_cmd,ms_ftp_host,ms_ftp_username,ms_ftp_password,ms_dir_loc_mu_in,
  ms_dir_rem_mu_in,"/dev/null"," ")
 SET ms_dclcom = concat("ls -l ",ms_dir_loc_mu_in," > ",ms_dir_loc_mu_out,ms_mu_file_in_ls)
 CALL echo(build("DCL:",ms_dclcom))
 CALL dcl(ms_dclcom,size(trim(ms_dclcom)),stat)
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while preparing input files.  Exiting.")
  GO TO exit_script
 ENDIF
 SET logical mu_in_ls value(build(ms_dir_loc_mu_out,ms_mu_file_in_ls))
 CALL echo(build("LOGICAL mu_in_ls:",logical("mu_in_ls")))
 FREE DEFINE rtl2
 DEFINE rtl2 "mu_in_ls"
 SELECT INTO "nl:"
  FROM rtl2t r
  WHERE  NOT (r.line IN ("", " ", null))
   AND r.line != "total *"
   AND r.line != "d*"
  HEAD REPORT
   mn_cnt = 0,
   CALL echo("Meaningful Use input files to process:")
  DETAIL
   ms_line = trim(r.line,3), ml_cnt += 1, stat = alterlist(mu_in->qual,ml_cnt),
   ml_idx = findstring(" ",ms_line,1,1), mu_in->qual[ml_cnt].s_filename = substring((ml_idx+ 1),(
    textlen(ms_line) - ml_idx),ms_line), mu_in->qual[ml_cnt].s_filename = mu_in->qual[ml_cnt].
   s_filename,
   CALL echo(concat("  ",mu_in->qual[ml_cnt].s_filename))
  FOOT REPORT
   CALL echo(build("Number of files to process:",size(mu_in->qual,5)))
  WITH nocounter
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo(concat("Error thrown while reading ",ms_mu_file_in_ls,".  Exiting."))
  GO TO exit_script
 ENDIF
 FOR (ml_cnt = 1 TO size(mu_in->qual,5))
   IF ((((mu_in->qual[ml_cnt].s_filename="BFMC_Meaningful*.txt")) OR ((((mu_in->qual[ml_cnt].
   s_filename="BMC_Meaningful*.txt")) OR ((((mu_in->qual[ml_cnt].s_filename="BLH_Meaningful*.txt"))
    OR ((((mu_in->qual[ml_cnt].s_filename="mu_inpt_*.txt")) OR ((mu_in->qual[ml_cnt].s_filename=
   "mu_inpt_*.csv"))) )) )) )) )
    SET ml_rpt_type = mn_rpt_inpatient
   ELSEIF (((cnvtlower(mu_in->qual[ml_cnt].s_filename)="mu_amb_*.csv") OR ((((mu_in->qual[ml_cnt].
   s_filename="Fill in later*.txt")) OR ((mu_in->qual[ml_cnt].s_filename=
   "Hopefully pretty generic*.txt"))) )) )
    SET ml_rpt_type = mn_rpt_ambulatory
   ELSEIF ((mu_in->qual[ml_cnt].s_filename="mu_sms_*.csv"))
    SET ml_rpt_type = mn_rpt_sms
   ELSEIF ((mu_in->qual[ml_cnt].s_filename="mu_wnerta_*.csv"))
    SET ml_rpt_type = mn_rpt_wnerta
   ELSEIF ((mu_in->qual[ml_cnt].s_filename="mu_recur_*.csv"))
    SET ml_rpt_type = mn_rpt_recurring
   ELSE
    SET ml_rpt_type = mn_unknown
    CALL echo(build("Input file does not match any known pattern:",mu_in->qual[ml_cnt].s_filename))
    SET bmr_reply->c_status = "Z"
   ENDIF
   CALL echo(concat("Processing input file [",trim(cnvtstring(ml_cnt)),"/",trim(cnvtstring(size(mu_in
        ->qual,5))),"] type[",
     trim(build(ml_rpt_type)),"] ",mu_in->qual[ml_cnt].s_filename))
   IF (ml_rpt_type IN (mn_rpt_inpatient, mn_rpt_ambulatory, mn_rpt_sms, mn_rpt_wnerta,
   mn_rpt_recurring))
    CALL echo(concat("Executing encounter-based report for ",mu_in->qual[ml_cnt].s_filename,"[",build
      (ml_rpt_type),"]"))
    SET ml_idx = findstring(".",mu_in->qual[ml_cnt].s_filename)
    IF (substring(1,(ml_idx - 1),mu_in->qual[ml_cnt].s_filename)="*_in")
     SET ms_file_out = build(substring(1,(ml_idx - 4),mu_in->qual[ml_cnt].s_filename),"_out_enc.csv")
    ELSE
     SET ms_file_out = build(substring(1,(ml_idx - 1),mu_in->qual[ml_cnt].s_filename),"_out_enc.csv")
    ENDIF
    SET stat = bhs_clear_error(0)
    SET ms_tempstring = build(ms_dir_loc_mu_in,mu_in->qual[ml_cnt].s_filename)
    EXECUTE bhs_mu_encounter "nl:", ms_tempstring, build(ms_dir_loc_mu_out,ms_file_out),
    ml_rpt_type WITH replace("REPLY","BME_REPLY")
    IF ((bme_reply->c_status="S"))
     SET ms_ftp_cmd = concat("put ",ms_file_out)
     SET stat = bhs_ftp_command(ms_ftp_cmd,ms_ftp_host,ms_ftp_username,ms_ftp_password,
      ms_dir_loc_mu_out,
      ms_dir_rem_mu_out,"/dev/null"," ")
     IF (bhs_ftp_findfile(ms_ftp_host,ms_ftp_username,ms_ftp_password,ms_dir_rem_mu_out,ms_file_out)=
     1)
      SET ms_dclcom = concat("rm -f ",ms_dir_loc_mu_out,ms_file_out)
      CALL echo(build("DCL:",ms_dclcom))
      CALL dcl(ms_dclcom,size(trim(ms_dclcom)),stat)
     ENDIF
    ELSE
     CALL echo(concat("Encounter-based report for ",mu_in->qual[ml_cnt].s_filename,"[",build(
        ml_rpt_type),"] failed."))
     SET bmr_reply->c_status = "Z"
    ENDIF
   ENDIF
   SET ms_dclcom = concat("rm -f ",ms_dir_loc_mu_in,mu_in->qual[ml_cnt].s_filename)
   CALL echo(build("DCL:",ms_dclcom))
   CALL dcl(ms_dclcom,size(trim(ms_dclcom)),stat)
   IF (ml_rpt_type != mn_unknown
    AND ml_debug_flag=0)
    SET ms_file_out = mu_in->qual[ml_cnt].s_filename
    IF (cnvtlower(ms_file_out) != "*_in.*")
     SET ml_idx = findstring(".",ms_file_out)
     SET ms_file_out = concat(substring(1,(ml_idx - 1),ms_file_out),"_in.",substring((ml_idx+ 1),(
       textlen(ms_file_out) - ml_idx),ms_file_out))
    ENDIF
    SET ms_ftp_cmd = concat("rename ",ms_dir_rem_mu_in,mu_in->qual[ml_cnt].s_filename," ",
     ms_dir_rem_mu_out,
     ms_file_out)
    SET stat = bhs_ftp_command(ms_ftp_cmd,ms_ftp_host,ms_ftp_username,ms_ftp_password," ",
     " ","/dev/null"," ")
   ELSEIF (ml_rpt_type != mn_unknown)
    CALL echo(concat("The remote source file [",mu_in->qual[ml_cnt].s_filename,
      "] will not be moved due to an unknown file type."))
   ELSEIF (ml_debug_flag > 0)
    CALL echo(concat("The remote source file [",mu_in->qual[ml_cnt].s_filename,
      "] will not be moved due to debug mode."))
   ENDIF
 ENDFOR
 IF ((reply->c_status != "Z"))
  SET reply->c_status = "S"
 ENDIF
#exit_script
 ROLLBACK
 SET stat = bhs_clear_error(0)
 IF (ml_debug_flag >= 1)
  CALL echo(concat("Exiting script ",curprog," with status ",reply->c_status))
 ELSE
  FREE RECORD mu_in
 ENDIF
END GO
