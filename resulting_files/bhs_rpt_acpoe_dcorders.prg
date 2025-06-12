CREATE PROGRAM bhs_rpt_acpoe_dcorders
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Location" = 0
  WITH outdev, s_beg_date, s_end_date,
  f_location
 FREE RECORD m_info
 RECORD m_info(
   1 s_facility_name = vc
   1 orders[*]
     2 f_encntr_id = f8
     2 s_fin = vc
     2 s_mrn = vc
     2 f_person_id = f8
     2 s_pat_name = vc
     2 f_order_id = f8
     2 s_order_name = vc
     2 s_order_det = vc
     2 s_ord_provider = vc
     2 s_loc = vc
     2 s_orig_ord_dt_tm = vc
     2 s_task_desc = vc
     2 s_ord_desc = vc
 ) WITH protect
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(trim(concat( $S_BEG_DATE," 00:00:00")))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(trim(concat( $S_END_DATE," 23:59:59")))
 DECLARE mf_facility_cd = f8 WITH protect, constant(cnvtreal( $F_LOCATION))
 DECLARE mf_void_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"VOIDEDWITHRESULTS"
   ))
 DECLARE mf_del_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"DELETED"))
 DECLARE mf_canceled_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"CANCELED"))
 DECLARE mf_discont_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"DISCONTINUED"))
 DECLARE mf_incompl_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"INCOMPLETE"))
 DECLARE mf_disch_discont_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4038,
   "SYSTEMDCONDISCHARGE"))
 DECLARE mf_discont_cd1 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6003,"DISCONTINUE"))
 DECLARE mf_ptcare_cat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,
   "PATIENTCAREOP"))
 DECLARE mf_anc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"ANCILLARYOP"))
 DECLARE mf_card_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"CARDIOLOGYOP"))
 DECLARE mf_consult_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"CONSULTOP"))
 DECLARE mf_ctscan_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"CTSCANOP"))
 DECLARE mf_labinoff_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"LABINOFFICEOP")
  )
 DECLARE mf_lab_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"LABORATORYOP"))
 DECLARE mf_mra_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"MRAOP"))
 DECLARE mf_mri_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"MRIOP"))
 DECLARE mf_neuro_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"NEUROOP"))
 DECLARE mf_ptcare_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"PATIENTCAREOP"))
 DECLARE mf_proc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"PROCEDUREOP"))
 DECLARE mf_pulm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"PULMONARYOP"))
 DECLARE mf_rad_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"RADIOLOGYOP"))
 DECLARE mf_surg_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"SURGICALOP"))
 DECLARE mf_ther_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"THERAPYOP"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_req_order_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16389,
   "REQUESTORDERS"))
 DECLARE mf_page_size = f8 WITH protect, constant(10.25)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE ms_output = vc WITH protect, noconstant( $OUTDEV)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE mf_rem_space = f8 WITH protect, noconstant(0)
 DECLARE ml_cont_ind = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 EXECUTE reportrtl
 SET m_info->s_facility_name = trim(uar_get_code_display(mf_facility_cd))
 SELECT INTO "nl:"
  ps_activity_type = trim(uar_get_code_display(o.active_status_cd)), uar_get_code_display(oa
   .action_type_cd), oa.updt_id,
  ot.task_description, o.order_id, o.encntr_id,
  ta.task_id, ps_order_name = trim(uar_get_code_display(o.catalog_cd))
  FROM orders o,
   encntr_domain ed,
   person p,
   prsnl pr,
   order_action oa,
   task_activity ta,
   order_task ot
  PLAN (o
   WHERE o.catalog_type_cd=mf_ptcare_cat_cd
    AND o.activity_type_cd IN (mf_anc_cd, mf_card_cd, mf_consult_cd, mf_ctscan_cd, mf_labinoff_cd,
   mf_lab_cd, mf_mra_cd, mf_mri_cd, mf_neuro_cd, mf_ptcare_cd,
   mf_proc_cd, mf_pulm_cd, mf_rad_cd, mf_surg_cd, mf_ther_cd)
    AND o.dcp_clin_cat_cd=mf_req_order_cd
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm))
   JOIN (ed
   WHERE ed.encntr_id=o.encntr_id
    AND ed.loc_facility_cd=mf_facility_cd)
   JOIN (p
   WHERE p.person_id=o.person_id
    AND p.active_ind=1
    AND p.end_effective_dt_tm >= sysdate)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND (oa.action_sequence=
   (SELECT
    max(oa1.action_sequence)
    FROM order_action oa1
    WHERE oa1.order_id=oa.order_id))
    AND oa.updt_id=1
    AND oa.action_type_cd=mf_discont_cd1)
   JOIN (pr
   WHERE pr.person_id=oa.order_provider_id
    AND p.active_ind=1)
   JOIN (ta
   WHERE (ta.order_id= Outerjoin(o.order_id)) )
   JOIN (ot
   WHERE (ot.reference_task_id= Outerjoin(ta.task_id)) )
  ORDER BY p.name_full_formatted, ps_order_name
  HEAD REPORT
   pl_ord_cnt = 0
  HEAD o.order_id
   pl_ord_cnt += 1
   IF (pl_ord_cnt > size(m_info->orders,5))
    stat = alterlist(m_info->orders,(pl_ord_cnt+ 10))
   ENDIF
   m_info->orders[pl_ord_cnt].f_encntr_id = o.encntr_id, m_info->orders[pl_ord_cnt].f_order_id = o
   .order_id, m_info->orders[pl_ord_cnt].f_person_id = o.person_id,
   m_info->orders[pl_ord_cnt].s_order_name = trim(uar_get_code_display(o.catalog_cd)), m_info->
   orders[pl_ord_cnt].s_order_det = trim(o.clinical_display_line), m_info->orders[pl_ord_cnt].
   s_pat_name = trim(p.name_full_formatted),
   m_info->orders[pl_ord_cnt].s_ord_provider = trim(pr.name_full_formatted), m_info->orders[
   pl_ord_cnt].s_loc = trim(uar_get_code_display(ed.loc_nurse_unit_cd)), m_info->orders[pl_ord_cnt].
   s_orig_ord_dt_tm = format(o.orig_order_dt_tm,"@SHORTDATETIME"),
   m_info->orders[pl_ord_cnt].s_task_desc = trim(ot.task_description), m_info->orders[pl_ord_cnt].
   s_ord_desc = trim(o.order_detail_display_line)
  FOOT REPORT
   stat = alterlist(m_info->orders,pl_ord_cnt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ms_log = "No records found"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_info->orders,5))),
   encntr_alias ea1,
   encntr_alias ea2
  PLAN (d)
   JOIN (ea1
   WHERE (ea1.encntr_id=m_info->orders[d.seq].f_encntr_id)
    AND ea1.active_ind=1
    AND ea1.encntr_alias_type_cd=mf_fin_cd)
   JOIN (ea2
   WHERE (ea2.encntr_id= Outerjoin(m_info->orders[d.seq].f_encntr_id))
    AND (ea2.active_ind= Outerjoin(1))
    AND (ea2.encntr_alias_type_cd= Outerjoin(mf_mrn_cd)) )
  DETAIL
   m_info->orders[d.seq].s_fin = cnvtalias(ea1.alias,ea1.encntr_alias_type_cd), m_info->orders[d.seq]
   .s_mrn = cnvtalias(ea2.alias,ea2.encntr_alias_type_cd)
  WITH nocounter
 ;end select
 SELECT INTO  $OUTDEV
  pt_name = substring(1,25,m_info->orders[d.seq].s_pat_name), fin = m_info->orders[d.seq].s_fin,
  location = m_info->orders[d.seq].s_loc,
  original_ord_dt_tm = substring(1,20,m_info->orders[d.seq].s_orig_ord_dt_tm), order_desc = trim(
   substring(1,1000,concat(m_info->orders[d.seq].s_order_name,": ",m_info->orders[d.seq].s_ord_desc)),
   3)
  FROM (dummyt d  WITH seq = value(size(m_info->orders,5)))
  PLAN (d)
  WITH separator = " ", format, skipreport = 1
 ;end select
#exit_script
END GO
