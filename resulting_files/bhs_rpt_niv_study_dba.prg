CREATE PROGRAM bhs_rpt_niv_study:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date" = "CURDATE",
  "End Date" = "CURDATE",
  "Email Recipient:" = ""
  WITH outdev, s_beg_dt, s_end_dt,
  s_email
 FREE RECORD m_rec
 RECORD m_rec(
   1 enc[*]
     2 f_person_id = f8
     2 s_pat_name = vc
     2 s_mrn = vc
     2 s_loc_cur = vc
     2 s_loc = vc
     2 s_bipap_in_pres = vc
     2 s_bipap_ex_pres = vc
     2 s_bipap_fio2 = vc
     2 s_bipap_freq = vc
     2 s_cpap_mode = vc
     2 s_cpap_pres = vc
     2 s_cpap_fio2 = vc
     2 s_cpap_freq = vc
     2 s_hfnc_reason = vc
     2 s_hfnc_ther_obj = vc
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
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_inpat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_cs6000_resp_ther_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,
   "RESPIRATORYTHERAPY"))
 DECLARE mf_cs200_bipap_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"BIPAP"))
 DECLARE mf_cs200_cpap_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"CPAP"))
 DECLARE mf_cs200_hf_cann_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HIGHFLOWNASALCANNULA"))
 DECLARE mf_cs6004_ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"
   ))
 DECLARE mf_cs16449_fio2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "LITERFLOWFIO2"))
 DECLARE mf_cs16449_in_pos_air_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "INSPPOSITIVEAIRWAYPRESSURE"))
 DECLARE mf_cs16449_ex_pos_air_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "EXPPOSITIVEAIRWAYPRESSURE"))
 DECLARE mf_cs16449_bipap_freq_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "BIPAPFREQUENCY"))
 DECLARE mf_cs16449_noninv_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "NONINVASIVEVENTMODE"))
 DECLARE mf_cs16449_cpap_prs_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "CPAPPRESSURE"))
 DECLARE mf_cs16449_hf_ind_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "HIGHFLOWINDICATIONS"))
 DECLARE mf_cs16449_hf_obj_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "HIGHFLOWOBJECTIVE"))
 DECLARE ms_email = vc WITH protect, noconstant(trim(cnvtlower( $S_EMAIL),3))
 DECLARE ms_filename = vc WITH protect, noconstant(concat("bhs_rpt_niv_study_",trim(format(sysdate,
     "mmddyyhhmmss;;d"),3),".csv"))
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(concat(trim( $S_BEG_DT,3)," 00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(concat(trim( $S_END_DT,3)," 23:59"))
 DECLARE mf_bhs_fac_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 IF (validate(request->batch_selection)=1)
  SET ms_email = "mark.tidswell@baystatehealth.org"
 ELSE
  IF (((findstring("@",ms_email)=0) OR (((textlen(ms_email)=0) OR (findstring(".",ms_email)=0)) )) )
   SELECT INTO value( $OUTDEV)
    FROM dummyt d
    HEAD REPORT
     col 0, "Invalid Email"
    WITH nocounter
   ;end select
   GO TO exit_script
  ENDIF
 ENDIF
 IF (textlen(trim( $S_BEG_DT,3))=0)
  SET ms_beg_dt_tm = format(datetimefind(cnvtlookbehind("1,D",sysdate),"D","B","B"),
   "dd-mmm-yyyy hh:mm;;d")
  SET ms_end_dt_tm = format(datetimefind(cnvtlookbehind("1,D",sysdate),"D","E","E"),
   "dd-mmm-yyyy hh:mm;;d")
 ENDIF
 CALL echo(concat("ms_beg_dt_tm: ",ms_beg_dt_tm))
 CALL echo(concat("ms_end_dt_tm: ",ms_end_dt_tm))
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.active_ind=1
   AND cv.end_effective_dt_tm > sysdate
   AND cv.display_key="BMC"
   AND cv.cdf_meaning="FACILITY"
  HEAD REPORT
   mf_bhs_fac_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encntr_domain ed,
   encounter e,
   person p,
   orders o,
   order_detail od,
   encntr_alias ea
  PLAN (ed
   WHERE ed.active_ind=1
    AND ed.loc_facility_cd=mf_bhs_fac_cd)
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.active_ind=1
    AND e.encntr_type_cd=mf_inpat_cd
    AND e.loc_facility_cd=mf_bhs_fac_cd)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.birth_dt_tm < cnvtlookbehind("21,Y",sysdate))
   JOIN (o
   WHERE o.encntr_id=e.encntr_id
    AND o.person_id=e.person_id
    AND o.catalog_type_cd=mf_cs6000_resp_ther_cd
    AND o.catalog_cd IN (mf_cs200_bipap_cd, mf_cs200_cpap_cd, mf_cs200_hf_cann_cd)
    AND o.order_status_cd=mf_cs6004_ordered_cd
    AND o.active_ind=1
    AND o.template_order_flag=0)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_id IN (mf_cs16449_fio2_cd, mf_cs16449_in_pos_air_cd, mf_cs16449_ex_pos_air_cd,
   mf_cs16449_bipap_freq_cd, mf_cs16449_noninv_cd,
   mf_cs16449_cpap_prs_cd, mf_cs16449_hf_ind_cd, mf_cs16449_hf_obj_cd))
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=mf_mrn_cd)
  ORDER BY e.encntr_id, o.order_id, od.oe_field_id,
   od.updt_dt_tm DESC
  HEAD REPORT
   pl_cnt = 0
  HEAD e.encntr_id
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->enc,5))
    CALL alterlist(m_rec->enc,(pl_cnt+ 10))
   ENDIF
   m_rec->enc[pl_cnt].f_person_id = e.encntr_id, m_rec->enc[pl_cnt].s_pat_name = trim(p
    .name_full_formatted,3), m_rec->enc[pl_cnt].s_mrn = trim(ea.alias,3),
   m_rec->enc[pl_cnt].s_loc_cur = trim(uar_get_code_display(e.loc_nurse_unit_cd),3), m_rec->enc[
   pl_cnt].s_loc = concat(trim(uar_get_code_display(e.loc_nurse_unit_cd),3)," ",trim(
     uar_get_code_display(e.loc_room_cd),3))
  HEAD od.oe_field_id
   CASE (od.oe_field_id)
    OF mf_cs16449_fio2_cd:
     IF (o.catalog_cd=mf_cs200_bipap_cd)
      m_rec->enc[pl_cnt].s_bipap_fio2 = trim(od.oe_field_display_value,3)
     ELSEIF (o.catalog_cd=mf_cs200_cpap_cd)
      m_rec->enc[pl_cnt].s_cpap_fio2 = trim(od.oe_field_display_value,3)
     ENDIF
    OF mf_cs16449_in_pos_air_cd:
     m_rec->enc[pl_cnt].s_bipap_in_pres = trim(od.oe_field_display_value,3)
    OF mf_cs16449_ex_pos_air_cd:
     m_rec->enc[pl_cnt].s_bipap_ex_pres = trim(od.oe_field_display_value,3)
    OF mf_cs16449_bipap_freq_cd:
     IF (o.catalog_cd=mf_cs200_bipap_cd)
      m_rec->enc[pl_cnt].s_bipap_freq = trim(od.oe_field_display_value,3)
     ELSEIF (o.catalog_cd=mf_cs200_cpap_cd)
      m_rec->enc[pl_cnt].s_cpap_freq = trim(od.oe_field_display_value,3)
     ENDIF
    OF mf_cs16449_noninv_cd:
     m_rec->enc[pl_cnt].s_cpap_mode = trim(od.oe_field_display_value,3)
    OF mf_cs16449_cpap_prs_cd:
     m_rec->enc[pl_cnt].s_cpap_pres = trim(od.oe_field_display_value,3)
    OF mf_cs16449_hf_ind_cd:
     m_rec->enc[pl_cnt].s_hfnc_reason = trim(od.oe_field_display_value,3)
    OF mf_cs16449_hf_obj_cd:
     m_rec->enc[pl_cnt].s_hfnc_ther_obj = trim(od.oe_field_display_value,3)
   ENDCASE
  FOOT REPORT
   CALL alterlist(m_rec->enc,pl_cnt)
  WITH nocounter
 ;end select
 CALL echo("CCLIO")
 IF (size(m_rec->enc,5) > 0)
  SET frec->file_name = concat(ms_filename)
  CALL echo(build2("path/file: ",frec->file_name))
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = concat(
   '"PATIENT_NAME","MRN","CURRENT_LOCATION","LOCATION","BIPAP_INSP_POS_AIRWAY_PRESSURE",',
   '"BIPAP_EXP_POS_AIRWAY_PRESSURE","BIPAP_FIO2","BIPAP_FREQUENCY","CPAP_MODE","CPAP_PRESSURE",',
   '"CPAP_FIO2","CPAP_FREQ","HFNC_REASON","HFNC_THERAPEUTIC_OBJECTIVE"',char(13),char(10))
  SET stat = cclio("WRITE",frec)
  FOR (ml_loop = 1 TO size(m_rec->enc,5))
   SET frec->file_buf = concat('"',m_rec->enc[ml_loop].s_pat_name,'",','"',m_rec->enc[ml_loop].s_mrn,
    '",','"',m_rec->enc[ml_loop].s_loc_cur,'",','"',
    m_rec->enc[ml_loop].s_loc,'",','"',m_rec->enc[ml_loop].s_bipap_in_pres,'",',
    '"',m_rec->enc[ml_loop].s_bipap_ex_pres,'",','"',m_rec->enc[ml_loop].s_bipap_fio2,
    '",','"',m_rec->enc[ml_loop].s_bipap_freq,'",','"',
    m_rec->enc[ml_loop].s_cpap_mode,'",','"',m_rec->enc[ml_loop].s_cpap_pres,'",',
    '"',m_rec->enc[ml_loop].s_cpap_fio2,'",','"',m_rec->enc[ml_loop].s_cpap_freq,
    '",','"',m_rec->enc[ml_loop].s_hfnc_reason,'",','"',
    m_rec->enc[ml_loop].s_hfnc_ther_obj,'"',char(13),char(10))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  EXECUTE bhs_ma_email_file
  SET ms_tmp = concat("NIV Study: ",format(sysdate,"mm/dd/yy hh:mm;;d"))
  CALL emailfile(value(frec->file_name),frec->file_name,ms_email,ms_tmp,1)
 ENDIF
 SET reply->status_data[1].status = "S"
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
