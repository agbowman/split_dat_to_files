CREATE PROGRAM bhs_rpt_pharm_abx_deesc:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Start Date:" = "CURDATE",
  "Enter End Date:" = "CURDATE",
  "Choose Facility:" = 0,
  "Choose Nurse Unit(s):" = 0,
  "Enter Medication Name:" = "",
  "Choose Medication(s);" = 0
  WITH outdev, s_beg_dt, s_end_dt,
  f_facility_cd, f_nurse_unit, s_med_search_str,
  f_med_cat_cd
 FREE RECORD m_info
 RECORD m_info(
   1 encntrs[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 s_pat_name = vc
     2 s_fin = vc
     2 s_location = vc
     2 n_include = i2
     2 ords[*]
       3 n_incl_ord = i2
       3 f_order_id = f8
       3 s_mnemonic = vc
       3 s_dose = vc
       3 s_freq = vc
       3 s_route = vc
     2 cultures[*]
       3 f_order_id = f8
       3 s_specimen_type = vc
       3 s_start_dt_tm = vc
       3 s_blob = vc
 )
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE ms_beg_dt = vc WITH protect, constant( $S_BEG_DT)
 DECLARE ms_end_dt = vc WITH protect, constant( $S_END_DT)
 DECLARE mf_facility_cd = f8 WITH protect, constant( $F_FACILITY_CD)
 DECLARE mn_nurse_unit_param = i2 WITH protect, constant(5)
 DECLARE mf_pharm_cat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY"))
 DECLARE mf_pharm_act_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"PHARMACY"))
 DECLARE mf_lab_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,"LABORATORY"))
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE mf_pend_complete_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,
   "PENDINGCOMPLETE"))
 DECLARE mf_completed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"COMPLETED"))
 DECLARE mf_specimen_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"SPECIMENTYPE"
   ))
 DECLARE mf_start_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "REQUESTED START DATE/TIME"))
 DECLARE mf_dose_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"STRENGTHDOSE"))
 DECLARE mf_dose_unit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "STRENGTHDOSEUNIT"))
 DECLARE mf_vol_dose_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"VOLUMEDOSE"))
 DECLARE mf_vol_dose_unit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "VOLUMEDOSEUNIT"))
 DECLARE mf_freq_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"FREQUENCY"))
 DECLARE mf_route_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "ROUTEOFADMINISTRATION"))
 DECLARE mf_micro_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"MICRO"))
 DECLARE mf_doc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",53,"DOC"))
 DECLARE mf_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 DECLARE mf_no_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"NOCOMP"))
 DECLARE mf_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE mf_active_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE"))
 DECLARE ms_output = vc WITH protect, noconstant( $OUTDEV)
 DECLARE ms_data_type = vc WITH protect, noconstant(" ")
 DECLARE ms_nurse_unit = vc WITH protect, noconstant(" ")
 DECLARE ms_meds = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt2 = i4 WITH protect, noconstant(0)
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_max_cultures = i4 WITH protect, noconstant(0)
 DECLARE ms_blob_out = vc WITH protect, noconstant(" ")
 DECLARE ms_blob_comp_trim = vc WITH protect, noconstant(" ")
 DECLARE ml_blob_ret_len = i4 WITH protect, noconstant(0)
 DECLARE ml_blob_ret_len2 = i4 WITH protect, noconstant(0)
 CALL echo("verify dates")
 IF (cnvtdatetime(ms_beg_dt) > cnvtdatetime(ms_end_dt))
  SET ms_log = "Begin date must come BEFORE end date"
  GO TO exit_script
 ELSEIF (datetimediff(cnvtdatetime(ms_end_dt),cnvtdatetime(ms_beg_dt)) > 31)
  SET ms_log = "Time interval is greater than 31 days.  Please choose a smaller date range"
  GO TO exit_script
 ENDIF
 CALL echo("get nurse unit cds")
 SET ms_data_type = reflect(parameter(mn_nurse_unit_param,0))
 IF (substring(1,1,ms_data_type)="C")
  SET ms_nurse_unit = parameter(mn_nurse_unit_param,1)
  IF (ms_nurse_unit=char(42))
   SET ms_nurse_unit = " ed.loc_nurse_unit_cd > 0"
  ENDIF
 ELSEIF (substring(1,1,ms_data_type) IN ("I", "F"))
  SET ms_nurse_unit = trim(cnvtstring(parameter(mn_nurse_unit_param,1)))
  IF ( NOT (trim(ms_nurse_unit) IN (null, "", " ", "0")))
   SET ms_nurse_unit = concat(" ed.loc_nurse_unit_cd = ",trim(ms_nurse_unit))
  ELSE
   SET ms_log = "No nurse unit chosen"
   GO TO exit_script
  ENDIF
 ELSEIF (substring(1,1,ms_data_type)="L")
  FOR (ml_cnt = 1 TO cnvtint(substring(2,(size(ms_data_type) - 1),ms_data_type)))
   SET ms_tmp = trim(cnvtstring(parameter(mn_nurse_unit_param,ml_cnt)))
   IF (ml_cnt=1)
    SET ms_nurse_unit = concat(" ed.loc_nurse_unit_cd in (",trim(ms_tmp))
   ELSE
    SET ms_nurse_unit = concat(ms_nurse_unit,", ",trim(ms_tmp))
   ENDIF
  ENDFOR
  SET ms_nurse_unit = concat(ms_nurse_unit,")")
 ENDIF
 CALL echo("create meds string")
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE (cv.code_value= $F_MED_CAT_CD)
    AND cv.code_value > 0
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > sysdate)
  ORDER BY cv.display
  HEAD cv.display
   IF (trim(ms_meds) <= " ")
    ms_meds = trim(cv.display)
   ELSE
    ms_meds = concat(ms_meds,", ",trim(cv.display))
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ms_log = "No medications chosen"
  GO TO exit_script
 ENDIF
 CALL echo("get encounters")
 SELECT INTO "nl:"
  FROM encntr_domain ed,
   encounter e
  PLAN (ed
   WHERE ed.active_ind=1
    AND ed.loc_facility_cd=mf_facility_cd
    AND parser(ms_nurse_unit)
    AND ed.active_status_cd=mf_active_cd
    AND ed.end_effective_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.encntr_type_cd=mf_inpatient_cd
    AND ((e.disch_dt_tm >= cnvtdatetime(ms_beg_dt)
    AND e.disch_dt_tm <= cnvtdatetime(ms_end_dt)) OR (e.disch_dt_tm = null
    AND e.reg_dt_tm <= cnvtdatetime(ms_end_dt))) )
  ORDER BY ed.encntr_id
  HEAD REPORT
   pl_enc_cnt = 0, pl_ord_cnt = 0
  HEAD ed.encntr_id
   pl_enc_cnt = (pl_enc_cnt+ 1)
   IF (pl_enc_cnt > size(m_info->encntrs,5))
    stat = alterlist(m_info->encntrs,(pl_enc_cnt+ 10))
   ENDIF
   m_info->encntrs[pl_enc_cnt].f_encntr_id = ed.encntr_id, m_info->encntrs[pl_enc_cnt].f_person_id =
   ed.person_id, m_info->encntrs[pl_enc_cnt].s_location = trim(uar_get_code_display(ed
     .loc_nurse_unit_cd)),
   pl_ord_cnt = 0
  FOOT REPORT
   stat = alterlist(m_info->encntrs,pl_enc_cnt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ms_log = "No encounters found"
  GO TO exit_script
 ENDIF
 CALL echo("get orders")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_info->encntrs,5))),
   orders o,
   order_detail od
  PLAN (d)
   JOIN (o
   WHERE (o.encntr_id=m_info->encntrs[d.seq].f_encntr_id)
    AND (o.catalog_cd= $F_MED_CAT_CD)
    AND o.activity_type_cd=mf_pharm_act_cd
    AND o.catalog_type_cd=mf_pharm_cat_cd
    AND o.order_status_cd=mf_ordered_cd
    AND o.template_order_id=0)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_id IN (mf_dose_cd, mf_dose_unit_cd, mf_vol_dose_cd, mf_vol_dose_unit_cd,
   mf_freq_cd,
   mf_route_cd))
  ORDER BY o.encntr_id
  HEAD REPORT
   pl_ord_cnt = 0
  HEAD o.encntr_id
   pl_ord_cnt = 0
  HEAD o.order_id
   m_info->encntrs[d.seq].n_include = 1, pl_ord_cnt = (pl_ord_cnt+ 1)
   IF (pl_ord_cnt > size(m_info->encntrs[d.seq].ords,5))
    stat = alterlist(m_info->encntrs[d.seq].ords,(pl_ord_cnt+ 10))
   ENDIF
   m_info->encntrs[d.seq].ords[pl_ord_cnt].f_order_id = o.order_id, m_info->encntrs[d.seq].ords[
   pl_ord_cnt].s_mnemonic = trim(o.order_mnemonic)
  DETAIL
   CASE (od.oe_field_id)
    OF mf_dose_cd:
     m_info->encntrs[d.seq].ords[pl_ord_cnt].s_dose = trim(od.oe_field_display_value)
    OF mf_dose_unit_cd:
     ms_tmp = trim(od.oe_field_display_value)
    OF mf_vol_dose_cd:
     IF (trim(m_info->encntrs[d.seq].ords[pl_ord_cnt].s_dose) < " ")
      m_info->encntrs[d.seq].ords[pl_ord_cnt].s_dose = trim(od.oe_field_display_value)
     ENDIF
    OF mf_vol_dose_unit_cd:
     IF (trim(ms_tmp) < " ")
      ms_tmp = trim(od.oe_field_display_value)
     ENDIF
    OF mf_freq_cd:
     m_info->encntrs[d.seq].ords[pl_ord_cnt].s_freq = trim(od.oe_field_display_value)
    OF mf_route_cd:
     m_info->encntrs[d.seq].ords[pl_ord_cnt].s_route = trim(od.oe_field_display_value)
   ENDCASE
  FOOT  o.order_id
   m_info->encntrs[d.seq].ords[pl_ord_cnt].s_dose = concat(m_info->encntrs[d.seq].ords[pl_ord_cnt].
    s_dose," ",trim(ms_tmp))
  FOOT  o.encntr_id
   stat = alterlist(m_info->encntrs[d.seq].ords,pl_ord_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.person_id
  FROM (dummyt d  WITH seq = value(size(m_info->encntrs,5))),
   person p
  PLAN (d
   WHERE (m_info->encntrs[d.seq].n_include=1))
   JOIN (p
   WHERE (p.person_id=m_info->encntrs[d.seq].f_person_id)
    AND p.active_ind=1
    AND p.end_effective_dt_tm >= sysdate)
  HEAD p.person_id
   m_info->encntrs[d.seq].s_pat_name = trim(p.name_full_formatted)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_info->encntrs,5))),
   encntr_alias ea
  PLAN (d
   WHERE (m_info->encntrs[d.seq].n_include=1))
   JOIN (ea
   WHERE (ea.encntr_id=m_info->encntrs[d.seq].f_encntr_id)
    AND ea.active_ind=1
    AND ea.encntr_alias_type_cd=mf_fin_cd)
  DETAIL
   m_info->encntrs[d.seq].s_fin = trim(ea.alias)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pf_encntr_id = m_info->encntrs[d.seq].f_encntr_id, od2.oe_field_dt_tm_value
  FROM (dummyt d  WITH seq = value(size(m_info->encntrs,5))),
   orders o,
   order_detail od1,
   order_detail od2
  PLAN (d
   WHERE (m_info->encntrs[d.seq].n_include=1))
   JOIN (o
   WHERE (o.encntr_id=m_info->encntrs[d.seq].f_encntr_id)
    AND o.catalog_type_cd=mf_lab_cd
    AND o.template_order_id=0
    AND o.activity_type_cd=mf_micro_cd
    AND o.order_status_cd IN (mf_pend_complete_cd, mf_completed_cd)
    AND o.orig_order_dt_tm BETWEEN cnvtlookbehind("3,D",cnvtdatetime(ms_beg_dt)) AND datetimeadd(
    cnvtdatetime(ms_end_dt),3)
    AND  EXISTS (
   (SELECT
    od.order_id
    FROM order_detail od
    WHERE od.order_id=o.order_id
     AND od.oe_field_id=12584)))
   JOIN (od1
   WHERE od1.order_id=o.order_id
    AND od1.oe_field_id=mf_specimen_cd)
   JOIN (od2
   WHERE od2.order_id=od1.order_id
    AND od2.oe_field_id=mf_start_cd
    AND od2.action_sequence=od1.action_sequence)
  ORDER BY pf_encntr_id, o.order_id, od2.oe_field_dt_tm_value DESC
  HEAD d.seq
   pl_cnt = 0
  HEAD o.order_id
   IF (pl_cnt < 3)
    pl_cnt = (pl_cnt+ 1)
    IF (pl_cnt > size(m_info->encntrs[d.seq].cultures,5))
     stat = alterlist(m_info->encntrs[d.seq].cultures,(pl_cnt+ 10))
    ENDIF
    m_info->encntrs[d.seq].cultures[pl_cnt].f_order_id = o.order_id, m_info->encntrs[d.seq].cultures[
    pl_cnt].s_specimen_type = trim(od1.oe_field_display_value), m_info->encntrs[d.seq].cultures[
    pl_cnt].s_start_dt_tm = trim(od2.oe_field_display_value)
   ENDIF
  FOOT  d.seq
   stat = alterlist(m_info->encntrs[d.seq].cultures,pl_cnt)
   IF (pl_cnt > ml_max_cultures)
    ml_max_cultures = pl_cnt
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ms_log = "No cultures found"
  GO TO exit_script
 ENDIF
 IF (ml_max_cultures > 3)
  SET ml_max_cultures = 3
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(m_info->encntrs,5))),
   dummyt d2,
   clinical_event ce,
   ce_blob cb
  PLAN (d1
   WHERE maxrec(d2,size(m_info->encntrs[d1.seq].cultures,5))
    AND (m_info->encntrs[d1.seq].n_include=1))
   JOIN (d2)
   JOIN (ce
   WHERE (ce.order_id=m_info->encntrs[d1.seq].cultures[d2.seq].f_order_id)
    AND ce.event_class_cd=mf_doc_cd
    AND ce.event_tag != "In Error"
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (cb
   WHERE cb.event_id=ce.event_id)
  DETAIL
   ps_blob_uncomp = fillstring(64000," "), ps_blob_rtf = fillstring(64000," ")
   IF (cb.compression_cd=mf_comp_cd)
    ms_blob_comp_trim = trim(cb.blob_contents),
    CALL uar_ocf_uncompress(ms_blob_comp_trim,size(ms_blob_comp_trim),ps_blob_uncomp,size(
     ps_blob_uncomp),ml_blob_ret_len),
    CALL uar_rtf2(ps_blob_uncomp,ml_blob_ret_len,ps_blob_rtf,size(ps_blob_rtf),ml_blob_ret_len2,1),
    ms_blob_out = trim(ps_blob_rtf,3), ms_blob_out = replace(ms_blob_out,char(10)," ")
   ELSEIF (cb.compression_cd=mf_no_comp_cd)
    ms_blob_out = trim(cb.blob_contents)
    IF (findstring("rtf",ms_blob_out) > 0)
     CALL uar_rtf2(ms_blob_out,textlen(ms_blob_out),ps_blob_rtf,size(ps_blob_rtf),ml_blob_ret_len2,1),
     ms_blob_out = trim(ps_blob_rtf,3)
    ENDIF
    IF (findstring("ocf_blob",ms_blob_out) > 0)
     ms_blob_out = replace(ms_blob_out,"ocf_blob","")
    ENDIF
    ms_blob_out = replace(ms_blob_out,char(10)," ")
   ENDIF
   m_info->encntrs[d1.seq].cultures[d2.seq].s_blob = trim(ms_blob_out,3)
  WITH nocounter
 ;end select
 FOR (ml_cnt = 1 TO size(m_info->encntrs,5))
   SELECT DISTINCT INTO "nl:"
    ps_mnemonic = m_info->encntrs[ml_cnt].ords[d.seq].s_mnemonic, ps_dose = m_info->encntrs[ml_cnt].
    ords[d.seq].s_dose, ps_freq = m_info->encntrs[ml_cnt].ords[d.seq].s_freq,
    ps_route = m_info->encntrs[ml_cnt].ords[d.seq].s_route
    FROM (dummyt d  WITH seq = value(size(m_info->encntrs[ml_cnt].ords,5)))
    PLAN (d
     WHERE (m_info->encntrs[ml_cnt].n_include=1))
    ORDER BY ps_mnemonic, ps_dose, ps_freq,
     ps_route
    DETAIL
     m_info->encntrs[ml_cnt].ords[d.seq].n_incl_ord = 1
    WITH nocounter
   ;end select
 ENDFOR
 SELECT INTO value(ms_output)
  pf_encntr_id = m_info->encntrs[d.seq].f_encntr_id
  FROM (dummyt d  WITH seq = value(size(m_info->encntrs,5)))
  PLAN (d
   WHERE (m_info->encntrs[d.seq].n_include=1))
  HEAD REPORT
   pl_col = 0, pl_cults = 0, col pl_col,
   "Patient_Name", pl_col = (pl_col+ 50), col pl_col,
   "FIN", pl_col = (pl_col+ 50), col pl_col,
   "Location", pl_col = (pl_col+ 50), col pl_col,
   "Trigger_Drug", pl_col = (pl_col+ 50), col pl_col,
   "Trigger_Dose", pl_col = (pl_col+ 50), col pl_col,
   "Trigger_Freq", pl_col = (pl_col+ 50), col pl_col,
   "Trigger_Route", pl_col = (pl_col+ 50)
   FOR (ml_cnt = 1 TO ml_max_cultures)
     ms_tmp = concat("Culture_",trim(cnvtstring(ml_cnt))), col pl_col, ms_tmp,
     pl_col = (pl_col+ 50), ms_tmp = concat("Culture_",trim(cnvtstring(ml_cnt)),"_Start_Dt_Tm"), col
     pl_col,
     ms_tmp, pl_col = (pl_col+ 50), ms_tmp = concat("Culture_",trim(cnvtstring(ml_cnt)),"_Details"),
     col pl_col, ms_tmp, pl_col = (pl_col+ 5000)
   ENDFOR
  HEAD pf_encntr_id
   pl_cults = size(m_info->encntrs[d.seq].cultures,5)
   IF (pl_cults > 0)
    FOR (ml_cnt = 1 TO size(m_info->encntrs[d.seq].ords,5))
      IF ((m_info->encntrs[d.seq].ords[ml_cnt].n_incl_ord=1))
       row + 1, pl_col = 0, col pl_col,
       m_info->encntrs[d.seq].s_pat_name, pl_col = (pl_col+ 50), col pl_col,
       m_info->encntrs[d.seq].s_fin, pl_col = (pl_col+ 50), col pl_col,
       m_info->encntrs[d.seq].s_location, pl_col = (pl_col+ 50), col pl_col,
       m_info->encntrs[d.seq].ords[ml_cnt].s_mnemonic, pl_col = (pl_col+ 50), col pl_col,
       m_info->encntrs[d.seq].ords[ml_cnt].s_dose, pl_col = (pl_col+ 50), col pl_col,
       m_info->encntrs[d.seq].ords[ml_cnt].s_freq, pl_col = (pl_col+ 50), col pl_col,
       m_info->encntrs[d.seq].ords[ml_cnt].s_route, pl_col = (pl_col+ 50)
       IF (pl_cults > ml_max_cultures)
        pl_cults = ml_max_cultures
       ENDIF
       FOR (ml_cnt2 = 1 TO pl_cults)
         col pl_col, m_info->encntrs[d.seq].cultures[ml_cnt2].s_specimen_type, pl_col = (pl_col+ 50),
         col pl_col, m_info->encntrs[d.seq].cultures[ml_cnt2].s_start_dt_tm, pl_col = (pl_col+ 50),
         col pl_col, m_info->encntrs[d.seq].cultures[ml_cnt2].s_blob, pl_col = (pl_col+ 5000)
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
  WITH nocounter, maxcol = 20000, format,
   separator = " "
 ;end select
 SELECT INTO "nl:"
  DETAIL
   row + 0
  WITH skipreport = value(1)
 ;end select
 SET ms_log = ""
 CALL echorecord(m_info)
#exit_script
 IF (trim(ms_log) > " ")
  CALL echo(ms_log)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   DETAIL
    ms_tmp = build2("size: ",size(m_info->encntrs,5)), col 0, ms_tmp,
    ms_tmp = build2("med list: ",ms_meds), col 0, row + 1,
    ms_tmp, col 0, row + 1,
    ms_log
   WITH nocounter
  ;end select
 ENDIF
 FREE RECORD m_info
END GO
