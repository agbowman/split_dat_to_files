CREATE PROGRAM bhs_rpt_surg_order:dba
 FREE RECORD m_rec
 RECORD m_rec(
   1 proc[*]
     2 s_catalog_type = vc
     2 f_cd = f8
     2 s_proc_name = vc
     2 s_outbound_alias = vc
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 SET frec->file_buf = "w"
 DECLARE mf_cs6000_surg = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3084"))
 CALL echo(build2("mf_CS6000_SURG: ",mf_cs6000_surg))
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(" ")
 IF (validate(request->batch_selection)=0)
  IF (((textlen(trim( $S_BEG_DT,3))=0) OR (textlen(trim( $S_END_DT,3))=0)) )
   SET ms_log = "Both dates must be filled out"
   GO TO exit_script
  ENDIF
  IF (cnvtdatetime( $S_BEG_DT) > cnvtdatetime( $S_END_DT))
   SET ms_log = "End date must be greater than Beg date"
   GO TO exit_script
  ENDIF
  SET ms_beg_dt_tm = concat(trim( $S_BEG_DT,3)," 00:00:00")
  SET ms_end_dt_tm = concat(trim( $S_END_DT,3)," 23:59:59")
 ELSE
  SET ms_beg_dt_tm = trim(format(datetimefind(cnvtlookbehind("1,D",sysdate),"D","B","B"),
    "dd-mmm-yyyy hh:mm:ss;;d"),3)
  SET ms_end_dt_tm = trim(format(datetimefind(cnvtlookbehind("1,D",sysdate),"D","E","E"),
    "dd-mmm-yyyy hh:mm:ss;;d"),3)
 ENDIF
 CALL echo(build2("beg dt: ",ms_beg_dt_tm," end dt: ",ms_end_dt_tm))
 SELECT
  *
  FROM code_value cv
  WHERE cv.code_value=2519
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv,
   code_value_alias cvo,
   order_catalog oc
  PLAN (cv
   WHERE cv.code_set=200
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > sysdate)
   JOIN (cvo
   WHERE cvo.code_value=cv.code_value)
   JOIN (oc
   WHERE oc.catalog_cd=cv.code_value
    AND oc.catalog_type_cd=mf_cs6000_surg
    AND oc.active_ind=1)
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt += 1,
   CALL alterlist(m_rec->proc,(pl_cnt+ 100)), m_rec->proc[pl_cnt].s_catalog_type = trim(
    uar_get_code_display(oc.catalog_type_cd),3),
   m_rec->proc[pl_cnt].f_cd = cv.code_value, m_rec->proc[pl_cnt].s_proc_name = trim(cv.description,3),
   m_rec->proc[pl_cnt].s_outbound_alias = trim(cvo.alias,3)
  FOOT REPORT
   CALL alterlist(m_rec->proc,pl_cnt)
  WITH nocounter
 ;end select
 CALL echo("CCLIO")
 IF (size(m_rec->proc,5) > 0)
  SET frec->file_name = concat(ms_file_name)
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = '"CATALOG_TYPE","CODESET200_CV","PROCEDURE_NAME","OUTBOUND_ALIAS"'
  SET stat = cclio("WRITE",frec)
  FOR (ml_loop = 1 TO size(m_rec->proc,5))
   SET frec->file_buf = concat('"',m_rec->proc[ml_loop].s_catalog_type,'",','"',trim(cnvtstring(m_rec
      ->proc[ml_loop].f_cd),3),
    '",','"',m_rec->proc[ml_loop].s_proc_name,'",','"',
    m_rec->proc[ml_loop].s_outbound_alias,'"',char(10))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
 ENDIF
 SET reply->status_data[1].status = "S"
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
