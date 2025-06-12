CREATE PROGRAM bhs_rpt_c19_vax:dba
 PROMPT
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE"
  WITH s_beg_dt, s_end_dt
 FREE RECORD m_rec
 RECORD m_rec(
   1 ord[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 f_order_id = f8
     2 s_cmrn = vc
     2 s_fin = vc
     2 s_mrn = vc
     2 s_pat_name = vc
     2 s_pat_dob = vc
     2 s_pat_sex = vc
     2 s_order_dt_tm = vc
     2 s_order_code = vc
     2 s_order_desc = vc
     2 s_dose_nbr = vc
     2 s_event_end_dt_tm = vc
     2 s_event_result = vc
     2 s_lot_number = vc
     2 s_encntr_type = vc
     2 s_reg_dt_tm = vc
     2 s_disch_dt_tm = vc
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
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  )
 ENDIF
 SET reply->status_data[1].status = "F"
 DECLARE mf_cs4_cmrn = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2621"))
 DECLARE mf_cs8_auth = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2628"))
 DECLARE mf_cs8_mod = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2636"))
 DECLARE mf_cs8_alter = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!16901"))
 DECLARE mf_cs72_pfizer = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SARSCOV2COVID19MRNABNT162B2VAC"))
 DECLARE mf_cs72_moderna = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SARSCOV2COVID19MRNA1273VACCINE"))
 DECLARE mf_cs319_fin = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs319_mrn = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8021"))
 CALL echo(build2("mf_CS72_PFIZER: ",mf_cs72_pfizer))
 CALL echo(build2("mf_CS72_MODERNA: ",mf_cs72_moderna))
 DECLARE ms_loc_dir = vc WITH protect, constant("$CCLUSERDIR")
 DECLARE ms_rem_dir = vc WITH protect, constant("CISCORE/pvix/covid_vax_orders")
 DECLARE ms_ftp_host = vc WITH protect, constant("transfer.baystatehealth.org")
 DECLARE ms_ftp_user = vc WITH protect, constant("CernerFTP")
 DECLARE ms_ftp_pass = vc WITH protect, constant("gJeZD64")
 DECLARE ms_file_name = vc WITH protect, constant(concat("bhs_rpt_c19_vax_",trim(format(sysdate,
     "mmddyyhhmm;;d"),3),".csv"))
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ms_dcl = vc WITH protect, noconstant(" ")
 DECLARE mn_dcl_stat = i4 WITH protect, noconstant(0)
 EXECUTE bhs_hlp_ftp
 EXECUTE bhs_check_domain
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
  SET ms_beg_dt_tm = "01-JAN-2021 00:00"
  SET ms_end_dt_tm = trim(format(sysdate,"dd-mmm-yyyy hh:mm;;d"),3)
 ENDIF
 CALL echo(build2("beg dt: ",ms_beg_dt_tm," end dt: ",ms_end_dt_tm))
 SELECT INTO "nl:"
  FROM clinical_event ce,
   encounter e,
   orders o,
   order_detail od,
   oe_format_fields oef,
   person p,
   person_name pn,
   person_alias pa,
   encntr_alias ea1,
   encntr_alias ea2,
   ce_med_result cmr
  PLAN (ce
   WHERE ce.event_end_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND ce.result_status_cd IN (mf_cs8_auth, mf_cs8_mod, mf_cs8_alter)
    AND ce.valid_until_dt_tm > sysdate
    AND ce.event_cd IN (mf_cs72_pfizer, mf_cs72_moderna))
   JOIN (e
   WHERE (e.encntr_id= Outerjoin(ce.encntr_id)) )
   JOIN (o
   WHERE o.order_id=ce.order_id)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_meaning="OTHER")
   JOIN (oef
   WHERE oef.oe_format_id=o.oe_format_id
    AND oef.oe_field_id=od.oe_field_id
    AND oef.clin_line_ind=1
    AND oef.label_text="Series Schedule")
   JOIN (p
   WHERE p.person_id=ce.person_id)
   JOIN (pn
   WHERE pn.person_id=p.person_id
    AND pn.active_ind=1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate
    AND pa.person_alias_type_cd=mf_cs4_cmrn)
   JOIN (ea1
   WHERE ea1.encntr_id=ce.encntr_id
    AND ea1.active_ind=1
    AND ea1.end_effective_dt_tm > sysdate
    AND ea1.encntr_alias_type_cd=mf_cs319_fin)
   JOIN (ea2
   WHERE ea2.encntr_id=ce.encntr_id
    AND ea2.active_ind=1
    AND ea2.end_effective_dt_tm > sysdate
    AND ea2.encntr_alias_type_cd=mf_cs319_mrn)
   JOIN (cmr
   WHERE (cmr.event_id= Outerjoin(ce.event_id)) )
  ORDER BY ce.event_end_dt_tm DESC
  HEAD REPORT
   pl_cnt = 0
  HEAD p.person_id
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->ord,5))
    CALL alterlist(m_rec->ord,(pl_cnt+ 10))
   ENDIF
   m_rec->ord[pl_cnt].f_person_id = ce.person_id, m_rec->ord[pl_cnt].f_encntr_id = ce.encntr_id,
   m_rec->ord[pl_cnt].f_order_id = o.order_id,
   m_rec->ord[pl_cnt].s_cmrn = trim(pa.alias,3), m_rec->ord[pl_cnt].s_fin = trim(ea1.alias,3), m_rec
   ->ord[pl_cnt].s_mrn = trim(ea2.alias,3),
   m_rec->ord[pl_cnt].s_pat_name = trim(p.name_full_formatted,3), m_rec->ord[pl_cnt].s_pat_dob = trim
   (format(p.birth_dt_tm,"YYYY-MM-DD;;d"),3), m_rec->ord[pl_cnt].s_pat_sex = substring(1,1,
    uar_get_code_display(p.sex_cd)),
   m_rec->ord[pl_cnt].s_order_dt_tm = trim(format(o.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;d"),3), m_rec
   ->ord[pl_cnt].s_order_code = trim(cnvtstring(o.catalog_cd),3), m_rec->ord[pl_cnt].s_order_desc =
   trim(uar_get_code_display(o.catalog_cd),3),
   m_rec->ord[pl_cnt].s_dose_nbr = trim(od.oe_field_display_value,3), m_rec->ord[pl_cnt].
   s_event_end_dt_tm = trim(format(ce.event_end_dt_tm,"mm/dd/yyyy hh:mm;;d"),3), m_rec->ord[pl_cnt].
   s_event_result = concat(trim(ce.result_val,3)," ",trim(uar_get_code_display(ce.result_units_cd),3)
    ),
   m_rec->ord[pl_cnt].s_lot_number = trim(cmr.substance_lot_number,3), m_rec->ord[pl_cnt].
   s_encntr_type = trim(uar_get_code_display(e.encntr_type_cd),3), m_rec->ord[pl_cnt].s_reg_dt_tm =
   trim(format(e.reg_dt_tm,"mm/dd/yy hh:mm;;d"),3),
   m_rec->ord[pl_cnt].s_disch_dt_tm = trim(format(e.disch_dt_tm,"mm/dd/yy hh:mm;;d"),3)
  FOOT REPORT
   CALL alterlist(m_rec->ord,pl_cnt)
  WITH nocounter
 ;end select
 CALL echo(build2("size: ",size(m_rec->ord,5)))
 CALL echo("CCLIO")
 IF (size(m_rec->ord,5) > 0)
  SET frec->file_name = concat(ms_file_name)
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = concat(
   '"PERSON_ID","ENCNTR_ID","ORDER_ID","CMRN","FIN","MRN","PATIENT_NAME","PATIENT_DOB","PATIENT_SEX",',
   '"ORDER_DT_TM","ORDER_CATALOG_CODE","ORDER_DESCRIPTION","DOSE_NUMBER","LOT_NUMBER",',
   '"EVENT_END_DT_TM","EVENT_RESULT","ENCNTR_TYPE","REG_DT_TM","DISCH_DT_TM"',char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_loop = 1 TO size(m_rec->ord,5))
   SET frec->file_buf = concat('"',trim(cnvtstring(m_rec->ord[ml_loop].f_person_id),3),'",','"',trim(
     cnvtstring(m_rec->ord[ml_loop].f_encntr_id),3),
    '",','"',trim(cnvtstring(m_rec->ord[ml_loop].f_order_id),3),'",','"',
    m_rec->ord[ml_loop].s_cmrn,'",','"',m_rec->ord[ml_loop].s_fin,'",',
    '"',m_rec->ord[ml_loop].s_mrn,'",','"',m_rec->ord[ml_loop].s_pat_name,
    '",','"',m_rec->ord[ml_loop].s_pat_dob,'",','"',
    m_rec->ord[ml_loop].s_pat_sex,'",','"',m_rec->ord[ml_loop].s_order_dt_tm,'",',
    '"',m_rec->ord[ml_loop].s_order_code,'",','"',m_rec->ord[ml_loop].s_order_desc,
    '",','"',m_rec->ord[ml_loop].s_dose_nbr,'",','"',
    m_rec->ord[ml_loop].s_lot_number,'",','"',m_rec->ord[ml_loop].s_event_end_dt_tm,'",',
    '"',m_rec->ord[ml_loop].s_event_result,'",','"',m_rec->ord[ml_loop].s_encntr_type,
    '",','"',m_rec->ord[ml_loop].s_reg_dt_tm,'",','"',
    m_rec->ord[ml_loop].s_disch_dt_tm,'"',char(13))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  SET stat = bhs_ftp_cmd(concat("put ",ms_file_name),ms_ftp_host,ms_ftp_user,ms_ftp_pass,ms_loc_dir,
   ms_rem_dir)
  IF (stat=0
   AND gl_bhs_prod_flag=1)
   SET ms_dcl = concat("mv ",ms_file_name," ",trim(logical("bhscust"),3),"/ftp_backup/")
   CALL dcl(ms_dcl,size(ms_dcl),mn_dcl_stat)
   CALL uar_send_mail("joe.echols@bhs.org",build2(curprog," - FTP Fail Backup"),build2(ms_file_name,
     " has been moved into 'bhscust/ftp_backup'.  The intended destination was ",ms_rem_dir),
    "FTP_FAIL",1,
    "IPM.NOTE")
   CALL pause(5)
   SET ms_dcl = concat("rm -f ",build(substring(1,(size(ms_file_name) - 4),ms_file_name),"*"))
   CALL dcl(ms_dcl,size(ms_dcl),mn_dcl_stat)
  ENDIF
 ENDIF
 UPDATE  FROM dm_info d
  SET d.info_date = cnvtlookahead("1,S",cnvtdatetime(ms_end_dt_tm)), d.updt_dt_tm = sysdate, d
   .updt_id = reqinfo->updt_id
  WHERE d.info_domain="BHS_RPT_C19_VAX"
   AND d.info_name="LAST_STOP_DT_TM"
  WITH nocounter
 ;end update
 COMMIT
 SET reply->status_data[1].status = "S"
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
