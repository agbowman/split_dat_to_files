CREATE PROGRAM bhs_rpt_rxauditor_360_by_fac:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date" = "CURDATE",
  "End Date" = "CURDATE",
  "Facility:" = ""
  WITH outdev, s_beg_dt, s_end_dt,
  s_fac
 EXECUTE bhs_check_domain
 FREE RECORD m_rec
 RECORD m_rec(
   1 rx[*]
     2 f_encntr_id = f8
     2 f_event_id = f8
     2 s_admin_user_name = vc
     2 s_admin_user_id = vc
     2 s_admin_user_role = vc
     2 s_pat_name = vc
     2 s_mrn = vc
     2 s_fin = vc
     2 s_nurse_unit = vc
     2 s_nurse_unit_cd = vc
     2 f_order_id = f8
     2 s_admin_dt_tm = vc
     2 s_drug_mnemonic = vc
     2 s_pyxis_id = vc
     2 s_med_qty = vc
     2 s_med_dose = vc
     2 s_med_unit = vc
     2 s_med_strength = vc
     2 s_med_vol = vc
     2 s_med_vol_unit = vc
     2 s_med_form = vc
     2 n_beg_bag_ind = i2
     2 s_bag_nbr = vc
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 FREE RECORD m_fac
 RECORD m_fac(
   1 l_cnt = i4
   1 qual[*]
     2 f_fac_cd = f8
 ) WITH protect
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  )
 ENDIF
 SET reply->status_data[1].status = "F"
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_mod_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_alter_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_administered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4000040,
   "ADMINISTERED"))
 DECLARE mf_generic_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",72,"DCPGENERIC"))
 DECLARE mf_beg_bag_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",180,"BEGINBAG"))
 DECLARE mf_admin_info_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ADMINISTRATIONINFORMATION"))
 DECLARE ms_loc_dir = vc WITH protect, constant(build(logical("bhscust"),
   "/ftp/bhs_rpt_rxauditor_360_by_fac/"))
 DECLARE ms_rem_dir = vc WITH protect, noconstant("CISCORE/MEDACIST")
 DECLARE ms_file_name = vc WITH protect, noconstant(concat("rxauditor360_",trim(format(sysdate,
     "mmddyyhhmmss;;d"),3),".csv"))
 DECLARE mf_vol_dose_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"VOLUMEDOSE"))
 DECLARE mf_vol_dose_unit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "VOLUMEDOSEUNIT"))
 DECLARE mf_str_dose_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"STRENGTHDOSE"
   ))
 DECLARE mf_str_dose_unit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "STRENGTHDOSEUNIT"))
 DECLARE mf_disp_qty_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "DISPENSEQUANTITY"))
 DECLARE mf_drug_form_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"DRUG FORM"))
 DECLARE mf_pyxis_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",11000,
   "PYXISINTERFACEID"))
 CALL echo(build2("mf_VOL_DOSE_CD: ",mf_vol_dose_cd))
 CALL echo(build2("mf_VOL_DOSE_UNIT_CD: ",mf_vol_dose_unit_cd))
 CALL echo(build2("mf_STR_DOSE_CD: ",mf_str_dose_cd))
 CALL echo(build2("mf_STR_DOSE_UNIT_CD: ",mf_str_dose_unit_cd))
 CALL echo(build2("mf_DISP_QTY_CD: ",mf_disp_qty_cd))
 CALL echo(build2("mf_DRUG_FORM_CD: ",mf_drug_form_cd))
 CALL echo(build2("mf_PYXIS_CD: ",mf_pyxis_cd))
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ms_dcl = vc WITH protect, noconstant(" ")
 DECLARE mn_dcl_stat = i4 WITH protect, noconstant(0)
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
 IF (cnvtupper(trim( $S_FAC,3))="BMC")
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=220
     AND cv.active_ind=1
     AND cv.display_key IN ("BMCINPTPSYCH", "BMC")
     AND cv.cdf_meaning="FACILITY")
   DETAIL
    m_fac->l_cnt += 1, stat = alterlist(m_fac->qual,m_fac->l_cnt), m_fac->qual[m_fac->l_cnt].f_fac_cd
     = cv.code_value
   WITH nocounter
  ;end select
  SET ms_file_name = concat("bmc_",ms_file_name)
  SET ms_rem_dir = concat(ms_rem_dir,"/bmc")
 ELSEIF (cnvtupper(trim( $S_FAC,3))="BFMC")
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=220
     AND cv.active_ind=1
     AND cv.display_key IN ("BFMCINPTPSYCH", "BFMC")
     AND cv.cdf_meaning="FACILITY")
   DETAIL
    m_fac->l_cnt += 1, stat = alterlist(m_fac->qual,m_fac->l_cnt), m_fac->qual[m_fac->l_cnt].f_fac_cd
     = cv.code_value
   WITH nocounter
  ;end select
  SET ms_file_name = concat("bfmc_",ms_file_name)
  SET ms_rem_dir = concat(ms_rem_dir,"/bfmc")
 ELSEIF (cnvtupper(trim( $S_FAC,3))="BNH")
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=220
     AND cv.active_ind=1
     AND cv.display_key IN ("BNHINPTPSYCH", "BNHREHAB", "BNH")
     AND cv.cdf_meaning="FACILITY")
   DETAIL
    m_fac->l_cnt += 1, stat = alterlist(m_fac->qual,m_fac->l_cnt), m_fac->qual[m_fac->l_cnt].f_fac_cd
     = cv.code_value
   WITH nocounter
  ;end select
  SET ms_file_name = concat("bnh_",ms_file_name)
  SET ms_rem_dir = concat(ms_rem_dir,"/bnh")
 ELSEIF (cnvtupper(trim( $S_FAC,3))="BWH")
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=220
     AND cv.active_ind=1
     AND cv.display_key IN ("BWHINPTPSYCH", "BWH")
     AND cv.cdf_meaning="FACILITY")
   DETAIL
    m_fac->l_cnt += 1, stat = alterlist(m_fac->qual,m_fac->l_cnt), m_fac->qual[m_fac->l_cnt].f_fac_cd
     = cv.code_value
   WITH nocounter
  ;end select
  SET ms_file_name = concat("bwh_",ms_file_name)
  SET ms_rem_dir = concat(ms_rem_dir,"/bwh")
 ENDIF
 SET ms_file_name = concat(ms_loc_dir,ms_file_name)
 SELECT INTO "nl:"
  FROM med_admin_event mae,
   clinical_event ce,
   ce_med_result cmr,
   orders o,
   encounter e,
   encntr_alias ea1,
   encntr_alias ea2,
   person p,
   prsnl pr,
   order_detail od,
   order_product op,
   med_identifier mi
  PLAN (mae
   WHERE mae.beg_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND mae.event_type_cd=mf_administered_cd)
   JOIN (ce
   WHERE ce.event_id=mae.event_id
    AND ce.result_status_cd IN (mf_auth_cd, mf_mod_cd, mf_alter_cd)
    AND ce.event_cd != mf_generic_cd)
   JOIN (o
   WHERE ((o.order_id=mae.order_id) OR (o.order_id=mae.template_order_id)) )
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.active_ind=1
    AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND e.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND expand(ml_idx,1,m_fac->l_cnt,e.loc_facility_cd,m_fac->qual[ml_idx].f_fac_cd))
   JOIN (ea1
   WHERE ea1.encntr_id=e.encntr_id
    AND ea1.encntr_alias_type_cd=mf_mrn_cd
    AND ea1.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea1.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.encntr_alias_type_cd=mf_fin_cd
    AND ea2.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea2.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (pr
   WHERE pr.person_id=mae.prsnl_id)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_id IN (mf_vol_dose_cd, mf_vol_dose_unit_cd, mf_str_dose_cd, mf_str_dose_unit_cd,
   mf_disp_qty_cd,
   mf_drug_form_cd))
   JOIN (cmr
   WHERE (cmr.event_id= Outerjoin(mae.event_id)) )
   JOIN (op
   WHERE op.order_id=o.order_id
    AND (op.action_sequence=
   (SELECT
    max(op1.action_sequence)
    FROM order_product op1
    WHERE op1.order_id=op.order_id)))
   JOIN (mi
   WHERE (mi.item_id= Outerjoin(op.item_id))
    AND (mi.active_ind= Outerjoin(1))
    AND (mi.med_identifier_type_cd= Outerjoin(mf_pyxis_cd)) )
  ORDER BY mae.med_admin_event_id, o.order_id, od.detail_sequence
  HEAD REPORT
   pl_cnt = 0
  HEAD mae.med_admin_event_id
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->rx,5))
    CALL alterlist(m_rec->rx,(pl_cnt+ 1000))
   ENDIF
   m_rec->rx[pl_cnt].f_encntr_id = e.encntr_id, m_rec->rx[pl_cnt].f_event_id = mae.event_id, m_rec->
   rx[pl_cnt].f_order_id = o.order_id,
   m_rec->rx[pl_cnt].s_admin_user_name = trim(pr.name_full_formatted,3), m_rec->rx[pl_cnt].
   s_admin_user_id = trim(pr.username,3), m_rec->rx[pl_cnt].s_admin_user_role = trim(
    uar_get_code_display(pr.position_cd),3),
   m_rec->rx[pl_cnt].s_pat_name = trim(p.name_full_formatted,3), m_rec->rx[pl_cnt].s_mrn = trim(ea1
    .alias,3), m_rec->rx[pl_cnt].s_fin = format(trim(ea2.alias,3),"##########;P0"),
   m_rec->rx[pl_cnt].s_nurse_unit = trim(uar_get_code_display(mae.nurse_unit_cd),3), m_rec->rx[pl_cnt
   ].s_nurse_unit_cd = trim(cnvtstring(mae.nurse_unit_cd),3), m_rec->rx[pl_cnt].s_pyxis_id = trim(mi
    .value,3),
   m_rec->rx[pl_cnt].s_drug_mnemonic = trim(o.order_mnemonic,3), m_rec->rx[pl_cnt].s_admin_dt_tm =
   trim(format(mae.beg_dt_tm,"mm/dd/yyyy hh:mm;;d"),3), m_rec->rx[pl_cnt].s_med_dose = trim(ce
    .result_val,3),
   m_rec->rx[pl_cnt].s_med_unit = trim(uar_get_code_display(ce.result_units_cd),3)
   IF (cmr.event_id > 0.0)
    m_rec->rx[pl_cnt].n_beg_bag_ind = 1, m_rec->rx[pl_cnt].s_bag_nbr = trim(cmr.substance_lot_number,
     3)
   ENDIF
   m_rec->rx[pl_cnt].s_med_qty = trim(cnvtstring(op.dose_quantity),3), m_rec->rx[pl_cnt].
   s_med_strength = concat(trim(cnvtstring(cmr.admin_strength),3)," ",trim(uar_get_code_display(cmr
      .admin_strength_unit_cd),3)), m_rec->rx[pl_cnt].s_med_form = trim(uar_get_code_display(cmr
     .medication_form_cd),3)
  DETAIL
   CASE (od.oe_field_id)
    OF mf_vol_dose_cd:
     m_rec->rx[pl_cnt].s_med_vol = trim(od.oe_field_display_value,3)
    OF mf_vol_dose_unit_cd:
     m_rec->rx[pl_cnt].s_med_vol_unit = trim(od.oe_field_display_value,3)
    OF mf_drug_form_cd:
     m_rec->rx[pl_cnt].s_med_form = trim(od.oe_field_display_value,3)
   ENDCASE
  FOOT REPORT
   CALL alterlist(m_rec->rx,pl_cnt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM charge c,
   interface_charge ic
  PLAN (c
   WHERE expand(ml_exp,1,size(m_rec->rx,5),c.encntr_id,m_rec->rx[ml_exp].f_encntr_id,
    c.order_id,m_rec->rx[ml_exp].f_order_id))
   JOIN (ic
   WHERE ic.charge_item_id=c.charge_item_id)
  ORDER BY c.order_id
  HEAD c.order_id
   ml_idx = locateval(ml_loc,1,size(m_rec->rx,5),c.order_id,m_rec->rx[ml_loc].f_order_id), m_rec->rx[
   ml_idx].s_drug_mnemonic = trim(ic.prim_cdm_desc,3)
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM order_ingredient oi
  PLAN (oi
   WHERE expand(ml_exp,1,size(m_rec->rx,5),oi.order_id,m_rec->rx[ml_exp].f_order_id))
  ORDER BY oi.order_id
  HEAD oi.order_id
   ml_idx = locateval(ml_loc,1,size(m_rec->rx,5),oi.order_id,m_rec->rx[ml_loc].f_order_id), m_rec->
   rx[ml_idx].s_med_strength = concat(trim(cnvtstring(oi.strength,5,3),3)," ",trim(
     uar_get_code_display(oi.strength_unit),3))
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  pf_bag_event_id = m_rec->rx[d.seq].f_event_id
  FROM (dummyt d  WITH seq = value(size(m_rec->rx,5))),
   clinical_event ce,
   ce_med_result cmr
  PLAN (d
   WHERE (m_rec->rx[d.seq].n_beg_bag_ind=1))
   JOIN (ce
   WHERE (ce.order_id=m_rec->rx[d.seq].f_order_id)
    AND ce.event_cd=mf_admin_info_cd
    AND ce.result_status_cd IN (mf_auth_cd, mf_mod_cd, mf_alter_cd))
   JOIN (cmr
   WHERE cmr.event_id=ce.event_id
    AND (cmr.substance_lot_number=m_rec->rx[d.seq].s_bag_nbr))
  ORDER BY d.seq, ce.order_id, pf_bag_event_id,
   cmr.substance_lot_number
  HEAD REPORT
   pf_tot_vol = 0.0
  HEAD cmr.substance_lot_number
   pf_tot_vol = 0.0
  DETAIL
   pf_tot_vol += cnvtreal(ce.result_val)
  FOOT  cmr.substance_lot_number
   m_rec->rx[d.seq].s_med_unit = trim(cnvtstring(pf_tot_vol),3)
  WITH nocounter
 ;end select
 IF (size(m_rec->rx,5) > 0)
  SET frec->file_name = ms_file_name
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = concat('"EMP_NAME",','"USER_ID",','"USER_ROLE",','"PAT_NAME",','"PAT_MRN_ID",',
   '"PAT_ENC_CSN_ID",','"DEPARTMENT_NAME",','"DEPARTMENT_ID",','"REV_LOC_NAME",','"REV_LOC_ID",',
   '"ORDER_MED_ID",','"ADMIN_TAKEN_TIME",','"MED_NAME",','"ADS_MED_ID",','"ADMIN_QTY",',
   '"ADMIN_DOSE",','"MED_UNIT_NAME",','"MED_STRENGTH",','"MED_VOLUME",','"MED_VOLUME_UNIT",',
   '"MED_FORM"',char(10))
  SET stat = cclio("WRITE",frec)
  FOR (ml_loop = 1 TO size(m_rec->rx,5))
    SET ms_tmp = concat('"',m_rec->rx[ml_loop].s_admin_user_name,'",','"',m_rec->rx[ml_loop].
     s_admin_user_id,
     '",','"',m_rec->rx[ml_loop].s_admin_user_role,'",','"',
     m_rec->rx[ml_loop].s_pat_name,'",','"',m_rec->rx[ml_loop].s_mrn,'",',
     '"',m_rec->rx[ml_loop].s_fin,'",','"',m_rec->rx[ml_loop].s_nurse_unit,
     '",','"',m_rec->rx[ml_loop].s_nurse_unit_cd,'",','"",',
     '"",','"',trim(cnvtstring(m_rec->rx[ml_loop].f_order_id),3),'",','"',
     m_rec->rx[ml_loop].s_admin_dt_tm,'",','"',m_rec->rx[ml_loop].s_drug_mnemonic,'",',
     '"',m_rec->rx[ml_loop].s_pyxis_id,'",','"',m_rec->rx[ml_loop].s_med_qty,
     '",','"',m_rec->rx[ml_loop].s_med_dose,'",','"',
     m_rec->rx[ml_loop].s_med_unit,'",','"',m_rec->rx[ml_loop].s_med_strength,'",',
     '"',m_rec->rx[ml_loop].s_med_vol,'",','"',m_rec->rx[ml_loop].s_med_vol_unit,
     '",','"',m_rec->rx[ml_loop].s_med_form,'"',char(10))
    SET frec->file_buf = ms_tmp
    SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
 ENDIF
 SET reply->status_data[1].status = "S"
#exit_script
 FREE RECORD m_rec
END GO
