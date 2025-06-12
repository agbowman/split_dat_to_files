CREATE PROGRAM bhs_rpt_last_run_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 FREE RECORD m_rec
 RECORD m_rec(
   1 prg[*]
     2 s_obj_name = vc
     2 s_obj_ty = vc
     2 s_status = vc
     2 s_params = vc
     2 s_elapsed = vc
     2 s_beg_dt_tm = vc
     2 s_end_dt_tm = vc
     2 s_user = vc
     2 s_app_nbr = vc
     2 s_app_desc = vc
     2 s_recs = vc
     2 s_output = vc
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ms_filepath = vc WITH protect, noconstant(logical("bhscust"))
 DECLARE ms_filename = vc WITH protect, noconstant(concat("bhs_rpt_last_run_audit_",trim(format(
     sysdate,"mmddyyhhmm;;d"),3),".csv"))
 CALL echo(concat(ms_filepath,"/",ms_filename))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 SELECT INTO "nl:"
  pl_elapsed_sec = datetimediff(c.end_dt_tm,c.begin_dt_tm,5), user = substring(1,30,p
   .name_full_formatted), c.application_nbr,
  c.records_cnt"#####", c.output_device, c.tempfile,
  c.active_ind, c.updt_dt_tm"@MEDIUMDATETIME"
  FROM ccl_report_audit c,
   person p,
   application a
  PLAN (c
   WHERE c.request_nbr=3050002
    AND c.application_nbr=3070000)
   JOIN (p
   WHERE p.person_id=c.updt_id)
   JOIN (a
   WHERE c.application_nbr=a.application_number)
  ORDER BY c.object_name, c.updt_dt_tm DESC
  HEAD REPORT
   pl_cnt = 0
  HEAD c.object_name
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->prg,5))
    CALL alterlist(m_rec->prg,(pl_cnt+ 100))
   ENDIF
   m_rec->prg[pl_cnt].s_obj_name = trim(c.object_name,3), m_rec->prg[pl_cnt].s_obj_ty = trim(c
    .object_type,3), m_rec->prg[pl_cnt].s_status = trim(c.status,3),
   m_rec->prg[pl_cnt].s_params = trim(c.object_params,3)
   IF (c.status="ACTIVE")
    m_rec->prg[pl_cnt].s_elapsed = "In Progress"
   ELSEIF (pl_elapsed_sec=0)
    m_rec->prg[pl_cnt].s_elapsed = "< 1 Second"
   ELSEIF (pl_elapsed_sec < 60)
    m_rec->prg[pl_cnt].s_elapsed = concat(trim(cnvtstring(pl_elapsed_sec),3)," Seconds")
   ELSE
    m_rec->prg[pl_cnt].s_elapsed = concat(trim(cnvtstring(datetimediff(c.end_dt_tm,c.begin_dt_tm,4)),
      3)," Minutes")
   ENDIF
   m_rec->prg[pl_cnt].s_beg_dt_tm = trim(format(c.begin_dt_tm,"mm/dd/yy hh:mm;;d"),3), m_rec->prg[
   pl_cnt].s_end_dt_tm = trim(format(c.end_dt_tm,"mm/dd/yy hh:mm;;d"),3), m_rec->prg[pl_cnt].s_user
    = trim(p.name_full_formatted,3),
   m_rec->prg[pl_cnt].s_app_nbr = trim(cnvtstring(c.application_nbr),3), m_rec->prg[pl_cnt].
   s_app_desc = trim(a.description,3), m_rec->prg[pl_cnt].s_recs = trim(cnvtstring(c.records_cnt),3),
   m_rec->prg[pl_cnt].s_output = trim(c.output_device,3)
  FOOT REPORT
   CALL alterlist(m_rec->prg,pl_cnt)
  WITH nocounter
 ;end select
 CALL echo("CCLIO")
 IF (size(m_rec->prg,5) > 0)
  SET frec->file_buf = "w"
  SET frec->file_name = concat(ms_filepath,"/",ms_filename)
  SET stat = cclio("OPEN",frec)
  SET ms_tmp = concat(
   '"OBJECT_NAME","OBJECT_TYPE","STATUS","PARAMS","ELAPSED","BEG_DT_TM","END_DT_TM","USER",',
   '"APP_NBR","APP_DESC","RECORDS","OUTPUT"',char(10))
  SET frec->file_buf = ms_tmp
  SET stat = cclio("WRITE",frec)
  FOR (ml_loop = 1 TO size(m_rec->prg,5))
    SET m_rec->prg[ml_loop].s_params = replace(m_rec->prg[ml_loop].s_params,'"',"|")
    SET ms_tmp = concat('"',m_rec->prg[ml_loop].s_obj_name,'",','"',m_rec->prg[ml_loop].s_obj_ty,
     '",','"',m_rec->prg[ml_loop].s_status,'",','"',
     m_rec->prg[ml_loop].s_params,'",','"',m_rec->prg[ml_loop].s_elapsed,'",',
     '"',m_rec->prg[ml_loop].s_beg_dt_tm,'",','"',m_rec->prg[ml_loop].s_end_dt_tm,
     '",','"',m_rec->prg[ml_loop].s_user,'",','"',
     m_rec->prg[ml_loop].s_app_nbr,'",','"',m_rec->prg[ml_loop].s_app_desc,'",',
     '"',m_rec->prg[ml_loop].s_recs,'",','"',m_rec->prg[ml_loop].s_output,
     '"',char(10))
    SET frec->file_buf = ms_tmp
    SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
 ENDIF
 IF (findfile(concat(ms_filepath,"/",ms_filename))=1)
  SET ms_tmp = concat("CCL ExplorerMenu Last Run Audit - ",trim(format(sysdate,"mm/dd/yy hh:mm;;d"),3
    ))
  IF (size(m_rec->prg,5)=0)
   SET ms_tmp = concat(ms_tmp,"No Records Found")
  ENDIF
  EXECUTE bhs_ma_email_file
  CALL emailfile(value(concat(ms_filepath,"/",ms_filename)),concat(ms_filepath,"/",ms_filename),
   "joe.echols@baystatehealth.org",ms_tmp,1)
 ENDIF
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
