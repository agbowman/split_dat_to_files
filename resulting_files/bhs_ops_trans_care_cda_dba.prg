CREATE PROGRAM bhs_ops_trans_care_cda:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Beg Date Time:" = "SYSDATE",
  "End Date Time:" = "SYSDATE",
  "Email to:" = ""
  WITH outdev, s_beg_dt_tm, s_end_dt_tm,
  s_email_to
 EXECUTE bhs_check_domain:dba
 EXECUTE bhs_hlp_ccl
 EXECUTE bhs_hlp_ftp
 FREE RECORD m_rec
 RECORD m_rec(
   1 cda[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 s_cmrn = vc
     2 s_fin = vc
     2 s_disch_dt_tm = vc
     2 c_status = c1
 ) WITH protect
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
      2 subeventstatus[1]
        3 operationname = vc
        3 operationstatus = vc
        3 targetobjectname = vc
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 DECLARE ms_output = vc WITH protect, constant(trim( $OUTDEV))
 DECLARE ms_dm_info_domain = vc WITH protect, constant("BHS_OPS_TRANS_CARE_CDA")
 DECLARE ms_dm_info_name = vc WITH protect, constant("OPS_STOP_DT_TM")
 DECLARE ms_ftp_host = vc WITH protect, constant("transfer.baystatehealth.org")
 DECLARE ms_ftp_username = vc WITH protect, constant("CernerFTP")
 DECLARE ms_ftp_password = vc WITH protect, constant("gJeZD64")
 DECLARE ms_loc_dir = vc WITH protect, constant(logical("ccluserdir"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE ml_job_max_gap = i4 WITH protect, constant(48)
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_EMAIL_TO))
 DECLARE ms_filename = vc WITH protect, noconstant(concat("bhs_ops_trans_care_",trim(format(sysdate,
     "mmddyyhhmmss;;d")),".csv"))
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_template_param = vc WITH protect, noconstant(" ")
 DECLARE ml_fail_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_prod_ind = i4 WITH protect, noconstant(0)
 DECLARE ms_ftp_path = vc WITH protect, noconstant(" ")
 DECLARE ms_ftp_cmd = vc WITH protect, noconstant(" ")
 DECLARE ms_dcl = vc WITH protect, noconstant(" ")
 DECLARE mn_dcl_stat = i4 WITH protect, noconstant(0)
 SET reply->status_data[1].status = "F"
 CALL bhs_sbr_log("start","",0,"",0.0,
  "","Begin Script","")
 IF (gl_bhs_prod_flag=0)
  SET ms_template_param = "T:569732517.00;O:0.00;C:437720951.00;D:1;L:22;PI:1;A:0"
 ELSE
  SET ml_prod_ind = 1
  SET ms_template_param = "T:572564578.00;O:0.00;C:437720951.00;D:1;L:22;PI:1;A:0"
 ENDIF
 IF (((validate(request->batch_selection)) OR (mn_ops=1)) )
  SET mn_ops = 1
  SET ms_beg_dt_tm = bhs_sbr_get_dm_info_dt(ms_dm_info_domain,ms_dm_info_name)
  IF (textlen(trim(ms_beg_dt_tm))=0)
   SET ms_log = "001 - DM_INFO row not found"
   GO TO send_page
  ENDIF
  IF (datetimediff(sysdate,cnvtdatetime(ms_beg_dt_tm),3) > ml_job_max_gap)
   SET ms_log = concat("002 - Last job ended over ",trim(cnvtstring(ml_job_max_gap))," hrs ago")
   GO TO send_page
  ENDIF
  SET ms_end_dt_tm = trim(format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d"))
 ELSE
  SET ms_beg_dt_tm = trim( $S_BEG_DT_TM)
  SET ms_end_dt_tm = trim( $S_END_DT_TM)
  IF (((textlen(ms_beg_dt_tm)=0) OR (textlen(ms_end_dt_tm)=0)) )
   SET ms_log = "Must populate both beg and end dates"
   GO TO exit_script
  ELSEIF (cnvtdatetime(ms_beg_dt_tm) > cnvtdatetime(ms_end_dt_tm))
   SET ms_log = "Beg date must be < end date"
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_alias ea,
   person_alias pa
  PLAN (e
   WHERE e.disch_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND e.disch_dt_tm != null)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=mf_fin_cd)
   JOIN (pa
   WHERE pa.person_id=e.person_id
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate
    AND pa.person_alias_type_cd=mf_cmrn_cd)
  ORDER BY e.disch_dt_tm, e.encntr_id
  HEAD REPORT
   pl_cnt = 0
  HEAD e.disch_dt_tm
   null
  HEAD e.encntr_id
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->cda,5))
    stat = alterlist(m_rec->cda,(pl_cnt+ 10))
   ENDIF
   m_rec->cda[pl_cnt].f_encntr_id = e.encntr_id, m_rec->cda[pl_cnt].f_person_id = e.person_id, m_rec
   ->cda[pl_cnt].s_disch_dt_tm = trim(format(e.disch_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")),
   m_rec->cda[pl_cnt].s_fin = trim(ea.alias), m_rec->cda[pl_cnt].s_cmrn = trim(pa.alias)
  FOOT REPORT
   stat = alterlist(m_rec->cda,pl_cnt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ms_log = "No records found for CDA out"
  SET ms_tmp = trim(format(cnvtlookahead("1, S",sysdate),"dd-mmm-yyyy hh:mm:ss;;d"))
  SET stat = bhs_sbr_upd_dm_info_dt(ms_dm_info_domain,ms_dm_info_name,ms_tmp)
  IF (stat=1)
   CALL echo("DM_INFO row updated")
  ELSE
   CALL echo("DM_INFO row not updated")
  ENDIF
 ELSE
  FOR (ml_loop = 1 TO size(m_rec->cda,5))
    IF (validate(reply2))
     SET stat = initrec(reply2)
    ELSE
     RECORD reply2(
       1 status_data[1]
         2 status = c1
     )
    ENDIF
    SET trace = recpersist
    EXECUTE bhs_si_ccd_trigger 0, ms_template_param, m_rec->cda[ml_loop].f_person_id,
    m_rec->cda[ml_loop].f_encntr_id, "" WITH replace("REPLY","REPLY2")
    IF ((reply2->status_data[1].status != "S"))
     CALL echo("reply 2 status failed")
     SET ml_fail_cnt += 1
     SET m_rec->cda[ml_loop].c_status = "F"
    ELSE
     SET m_rec->cda[ml_loop].c_status = "S"
    ENDIF
    SET trace = norecpersist
    CALL bhs_sbr_log("log","",0,"ENCNTR_ID",m_rec->cda[ml_loop].f_encntr_id,
     "",trim(concat("CDA: ",trim(cnvtstring(ml_loop))," of ",trim(cnvtstring(size(m_rec->cda,5))))),
     m_rec->cda[ml_loop].c_status)
    SET ms_tmp = concat("latest CDA-",trim(cnvtstring(ml_loop))," of ",trim(cnvtstring(size(m_rec->
        cda,5))),": ",
     trim(m_rec->cda[ml_loop].s_disch_dt_tm)," EncntrID: ",trim(cnvtstring(m_rec->cda[ml_loop].
       f_encntr_id)))
    CALL bhs_sbr_log("stop","",0,"",0.0,
     "",ms_tmp,"R")
    IF (mn_ops=1)
     SET ms_tmp = trim(format(cnvtlookahead("1, S",cnvtdatetime(m_rec->cda[ml_loop].s_disch_dt_tm)),
       "dd-mmm-yyyy hh:mm:ss;;d"))
     SET stat = bhs_sbr_upd_dm_info_dt(ms_dm_info_domain,ms_dm_info_name,ms_tmp)
     IF (stat=1)
      CALL echo("DM_INFO row updated")
     ELSE
      CALL echo("DM_INFO row not updated")
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 SET ms_tmp = trim(concat("CDAs found: ",trim(cnvtstring(size(m_rec->cda,5))),"; success: ",trim(
    cnvtstring((size(m_rec->cda,5) - ml_fail_cnt))),"; failed: ",
   trim(cnvtstring(ml_fail_cnt))))
 CALL bhs_sbr_log("log","",0,"CDA",0.0,
  "",ms_tmp,"S")
 IF (((trim(cnvtupper(ms_recipients))="FTP") OR (findstring("@",ms_recipients) > 0)) )
  CALL echo("create the file")
  IF (size(m_rec->cda,5) > 0)
   SELECT INTO value(ms_filename)
    FROM (dummyt d  WITH seq = value(size(m_rec->cda,5)))
    PLAN (d)
    HEAD REPORT
     ms_tmp = "encntr_id,person_id,fin,cmrn,disch_dt_tm,status", col 0, ms_tmp
    DETAIL
     row + 1, ms_tmp = concat('"',trim(cnvtstring(m_rec->cda[d.seq].f_encntr_id)),'",','"',trim(
       cnvtstring(m_rec->cda[d.seq].f_person_id)),
      '",','"',m_rec->cda[d.seq].s_fin,'",','"',
      m_rec->cda[d.seq].s_cmrn,'",','"',m_rec->cda[d.seq].s_disch_dt_tm,'",',
      '"',m_rec->cda[d.seq].c_status,'"'), col 0,
     ms_tmp
    WITH nocounter, maxrow = 1
   ;end select
   CALL bhs_sbr_log("log","",0,"CDA",0.0,
    "",concat("CDA csv file generated: ",ms_filename),"R")
  ELSE
   SET ms_filename = replace(ms_filename,".csv",".txt")
   SELECT INTO value(ms_filename)
    FROM dummyt d
    HEAD REPORT
     col 0, "No data found"
    WITH nocounter
   ;end select
  ENDIF
  IF (findstring("@",ms_recipients) > 0
   AND size(m_rec->cda,5) > 0)
   CALL echo("email csv file")
   SET ms_tmp = concat("Transition of Care CDA job: ",ms_beg_dt_tm," - ",ms_end_dt_tm)
   EXECUTE bhs_ma_email_file
   CALL emailfile(value(ms_filename),ms_filename,ms_recipients,concat("Transition of Care CDA Job: ",
     ms_beg_dt_tm," - ",ms_end_dt_tm),1)
   SET reply->status_data[1].subeventstatus[1].operationname = "EMAIL"
   SET reply->status_data[1].subeventstatus[1].operationstatus = concat("File sent: ",ms_filename,
    " To: ",ms_recipients)
  ELSEIF (findstring("@",ms_recipients) > 0)
   CALL echo("email no data found")
   CALL uar_send_mail(nullterm("ciscore@bhs.org"),nullterm(ms_tmp),nullterm("No CDAs found - no FTP"),
    nullterm("Trans Care CDA job"),1,
    nullterm("IPM.NOTE"))
   CALL uar_send_mail(nullterm("ciscore@bhs.org"),nullterm(ms_tmp),nullterm("No CDAs found - no FTP"),
    nullterm("Trans Care CDA job"),1,
    nullterm("IPM.NOTE"))
   SET reply->status_data[1].subeventstatus[1].operationname = "EMAIL"
   SET reply->status_data[1].subeventstatus[1].operationstatus = concat("No Recs Msg To: ",
    ms_recipients)
  ELSEIF (trim(cnvtupper(ms_recipients))="FTP")
   CALL echo("ftp file to share")
   IF (ml_prod_ind=1)
    SET ms_ftp_path = '"ciscore/HIE/PROD/Transition of Care CDA"'
   ELSE
    SET ms_ftp_path = '"ciscore/HIE/NONPROD/Transition of Care CDA"'
   ENDIF
   SET ms_ftp_cmd = concat("put ",ms_filename)
   SET stat = bhs_ftp_cmd(ms_ftp_cmd,ms_ftp_host,ms_ftp_username,ms_ftp_password,ms_loc_dir,
    ms_ftp_path)
   CALL pause(1)
   SET ms_dcl = concat("rm -f ",ms_filename)
   CALL dcl(ms_dcl,size(ms_dcl),mn_dcl_stat)
   CALL echo(build2("dcl stat: ",mn_dcl_stat))
   SET reply->status_data[1].subeventstatus[1].operationname = "FTP"
   SET reply->status_data[1].subeventstatus[1].operationstatus = concat("File FTP: ",ms_filename,
    " To: ciscore\HIE\Transition of Care CDA")
  ENDIF
 ENDIF
 SET reply->status_data[1].status = "S"
 SET reply->status_data[1].subeventstatus[1].targetobjectname = "Log Msg"
 SET reply->status_data[1].subeventstatus[1].targetobjectvalue = ms_tmp
 GO TO exit_script
#send_page
 SET ms_tmp = concat("*** Transition of Care CDA Ops Job FAILURE ***",char(13),
  "Job Name: Transition of Care CDA",char(13),"Job Run Date: ",
  trim(format(sysdate,"mm/dd/yy hh:mm;;d")),char(13),"Error: ",ms_log,char(13),
  char(13))
 IF (ms_log="001*")
  SET ms_tmp = concat(ms_tmp,
   "Please ensure that the DM_INFO row for BHS_OPS_TRANS_CARE_CDA has been inserted",char(13),
   "and dm_info.info_dt_tm has been set appropriately.",char(13),
   char(13),"Once the appropriate start_dt_tm for the job has been determined, use the program at ",
   "ExplorerMenu->CIS Core Programs->DM_INFO Maint to insert the row",char(13),
   "Use the following values: ",
   char(13),"Info Domain = ",ms_dm_info_domain,char(13),"Info Name = ",
   ms_dm_info_name,char(13))
 ELSEIF (ms_log="002*")
  SET ms_tmp = concat(ms_tmp,
   "The time gap since the last CDA ops job ran is greater than the max allowed gap of ",trim(
    cnvtstring(ml_job_max_gap))," hrs.",char(13),
   "Please run jobs in increments of 4 hours to cover the time gap, using ",
   "ExplorerMenu->CIS Core Programs->Transition of Care CDA Job.",char(13),
   "Once complete, update the dm_info row to an appropriate time for the next job to start ",
   "using ExplorerMenu->CIS Core Programs->DM_INFO Maint. ",
   char(13),"Update the row with info_domain = ",ms_dm_info_domain," and info_name = ",
   ms_dm_info_name,
   char(13))
 ENDIF
 SET reply->status_data[1].subeventstatus[1].targetobjectname = "Log Msg"
 SET reply->status_data[1].subeventstatus[1].targetobjectvalue = ms_log
 SET reply->status_data[1].subeventstatus[1].operationname = "SEND PAGE"
 IF (ml_prod_ind=1)
  CALL echo("send email/page")
  CALL uar_send_mail(nullterm("ciscore@bhs.org"),nullterm(concat(
     "Transition of Care CDA Ops Failed: ",trim(format(sysdate,"mm/dd/yy hh:mm;;d")))),nullterm(
    ms_tmp),nullterm("Trans Care CDA Ops"),1,
   nullterm("IPM.NOTE"))
  CALL uar_send_mail(nullterm("94556@epage.bhs.org"),nullterm("Trans Care CDA Ops Fail"),nullterm(
    concat("Transition of Care CDA Ops Fail - see Core inbox ",ms_end_dt_tm)),nullterm(
    "Trans Care CDA Ops"),1,
   nullterm("IPM.NOTE"))
  SET reply->status_data[1].subeventstatus[1].operationstatus = "EMAILED/PAGED Core"
 ELSEIF (ml_prod_ind=0
  AND findstring("@",ms_recipients) > 0)
  CALL uar_send_mail(nullterm(ms_recipients),nullterm(concat("Transition of Care CDA Ops Failed: ",
     trim(format(sysdate,"mm/dd/yy hh:mm;;d")))),nullterm(ms_tmp),nullterm("Trans Care CDA Ops"),1,
   nullterm("IPM.NOTE"))
  SET reply->status_data[1].subeventstatus[1].operationstatus = "EMAILED JE"
 ENDIF
#exit_script
 IF ((reply->status_data[1].status="S"))
  CALL bhs_sbr_log("stop","",0,"",0.0,
   trim(build2("CDAs found and sent successfully: ","; success: ",trim(cnvtstring((size(m_rec->cda,5)
        - ml_fail_cnt))),"; failed: ",trim(cnvtstring(ml_fail_cnt)))),"End Time","S")
 ELSE
  CALL bhs_sbr_log("stop","",0,"",0.0,
   trim(build2("Failed: ",ms_log)),"End Time","F")
 ENDIF
 IF (mn_ops=0
  AND textlen(trim(ms_output)) > 0)
  SELECT INTO value(ms_output)
   FROM dummyt d
   HEAD REPORT
    ms_tmp = concat("CDAs for this range: ",ms_beg_dt_tm," to ",ms_end_dt_tm), col 0, ms_tmp
    IF ((reply->status_data[1].status="F"))
     col 0, row + 1, "Script failed"
    ELSE
     ms_tmp = concat("CDAs found: ",trim(cnvtstring(size(m_rec->cda,5))),"; success: ",trim(
       cnvtstring((size(m_rec->cda,5) - ml_fail_cnt))),"; failed: ",
      trim(cnvtstring(ml_fail_cnt))), col 0, row + 1,
     ms_tmp
    ENDIF
    col 0, row + 1, ms_log
   WITH nocounter
  ;end select
 ELSE
  CALL echo(ms_log)
 ENDIF
 CALL echorecord(m_rec)
 CALL echorecord(reply)
 FREE RECORD m_rec
END GO
