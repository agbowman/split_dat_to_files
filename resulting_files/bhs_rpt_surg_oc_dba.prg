CREATE PROGRAM bhs_rpt_surg_oc:dba
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
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  )
 ENDIF
 SET frec->file_buf = "w"
 DECLARE ms_file_name = vc WITH protect, constant(concat("bhs_rpt_surg_oc_",trim(format(sysdate,
     "mmddyyhhmm;;d"),3),".csv"))
 DECLARE mf_cs6000_surg = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3084"))
 SELECT
  *
  FROM order_catalog oc,
   code_value_outbound cvo
  PLAN (oc
   WHERE oc.catalog_type_cd=mf_cs6000_surg)
   JOIN (cvo
   WHERE (cvo.code_value= Outerjoin(oc.catalog_cd)) )
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->proc,5))
    CALL alterlist(m_rec->proc,(pl_cnt+ 100))
   ENDIF
   m_rec->proc[pl_cnt].s_catalog_type = trim(uar_get_code_display(oc.catalog_type_cd),3), m_rec->
   proc[pl_cnt].f_cd = oc.catalog_cd, m_rec->proc[pl_cnt].s_proc_name = trim(oc.description,3),
   m_rec->proc[pl_cnt].s_outbound_alias = trim(cvo.alias,3)
  FOOT REPORT
   CALL alterlist(m_rec->proc,pl_cnt)
  WITH nocounter
 ;end select
 CALL echo("CCLIO")
 IF (size(m_rec->proc,5) > 0)
  SET frec->file_name = concat(ms_file_name)
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = concat('"CATALOG_TYPE","CODESET200_CV","PROCEDURE_NAME","OUTBOUND_ALIAS"',char
   (10))
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
 IF (findfile(ms_file_name))
  EXECUTE bhs_ma_email_file
  CALL emailfile(ms_file_name,ms_file_name,"elimuhelp@baystatehealth.org","surgery oc",1)
 ENDIF
 SET reply->status_data[1].status = "S"
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
