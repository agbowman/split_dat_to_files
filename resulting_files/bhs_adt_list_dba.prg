CREATE PROGRAM bhs_adt_list:dba
 FREE RECORD m_rec2
 RECORD m_rec2(
   1 ord[*]
     2 f_order_id = f8
 )
 FREE RECORD m_rec
 RECORD m_rec(
   1 adt[*]
     2 f_code_value = f8
     2 f_disp_key = vc
     2 f_mnem_key = vc
   1 nurs[*]
     2 f_nurse_unit_cd = f8
     2 s_disp = vc
   1 pat[*]
     2 f_person_id = f8
     2 s_pat_name = vc
     2 f_encntr_id = f8
     2 s_mrn = vc
     2 s_fin = vc
     2 n_orders = i2
     2 n_incl = i2
     2 dx[*]
       3 f_dx_id = f8
       3 s_source_str = vc
     2 ord[*]
       3 f_order_id = f8
       3 s_mnemonic = vc
       3 s_start_dt_tm = vc
       3 s_stop_dt_tm = vc
       3 s_orig_dt_tm = vc
       3 s_updt_dt_tm = vc
 ) WITH protect
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(concat("31-AUG-2011 17:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat("01-SEP-2011 03:00:00"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_inpt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE mf_route_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "ROUTEOFADMINISTRATION"))
 DECLARE mf_freq_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"FREQUENCY"))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE mf_facility_cd = f8 WITH protect, noconstant(673936)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 CALL echo(build2("beg: ",ms_beg_dt_tm))
 CALL echo(build2("end: ",ms_end_dt_tm))
 CALL echo(build2("facility: ",mf_facility_cd))
 CALL echo(build2("inpt cd: ",mf_inpt_cd))
 SELECT INTO "nl:"
  lg2.child_loc_cd, ps_disp = uar_get_code_display(lg2.child_loc_cd)
  FROM location_group lg1,
   location_group lg2,
   code_value cv
  PLAN (lg1
   WHERE lg1.parent_loc_cd IN (673936, 679549)
    AND lg1.root_loc_cd=0
    AND lg1.active_ind=1)
   JOIN (lg2
   WHERE lg2.parent_loc_cd=lg1.child_loc_cd
    AND lg2.root_loc_cd=0
    AND lg2.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=lg2.child_loc_cd
    AND cv.cdf_meaning="NURSEUNIT"
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > sysdate)
  ORDER BY ps_disp
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->nurs,pl_cnt), m_rec->nurs[pl_cnt].f_nurse_unit_cd =
   cv.code_value,
   m_rec->nurs[pl_cnt].s_disp = trim(cv.display)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_catalog_synonym ocs,
   code_value cv
  PLAN (ocs
   WHERE ocs.mnemonic IN ("Attending MD", "Isolation", "Status Change Patient Type to",
   "Status Daystay Patient", "Status Inpatient",
   "Status Observation Patient", "Teaching Coverage", "Transfer to", "Change Attending MD",
   "Change Primary Care Provider",
   "Admit Medicine to Inpt Service/Status", "Assign Medical Admit Observation Status",
   "Reassign Pt Status - Inpt to Observation", "Reassign Pt Status - Observation to Inpt",
   "Admit Inpatient Service",
   "Assign Observation  Status", "Select Admit Inpatient Service", "Select Observation Status",
   "Assign Daystay Status", "Select Daystay Status")
    AND ocs.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=ocs.catalog_cd
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > sysdate)
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->adt,pl_cnt), m_rec->adt[pl_cnt].f_code_value = ocs
   .catalog_cd,
   m_rec->adt[pl_cnt].f_disp_key = trim(cv.display_key), m_rec->adt[pl_cnt].f_mnem_key = trim(ocs
    .mnemonic_key_cap)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encntr_alias ea1,
   encntr_alias ea2,
   encntr_domain ed,
   encntr_loc_hist elh,
   encounter e,
   person p
  PLAN (ed
   WHERE ((ed.loc_facility_cd+ 0) IN (673936, 679549))
    AND expand(ml_cnt,1,size(m_rec->nurs,5),ed.loc_nurse_unit_cd,m_rec->nurs[ml_cnt].f_nurse_unit_cd)
    AND ((ed.active_ind+ 0)=1)
    AND ed.beg_effective_dt_tm < cnvtdatetime(ms_end_dt_tm)
    AND ed.end_effective_dt_tm > cnvtdatetime(ms_beg_dt_tm))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.encntr_type_cd=mf_inpt_cd
    AND e.disch_dt_tm=null
    AND e.active_ind=1)
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND ((elh.active_ind+ 0)=1)
    AND ((elh.loc_nurse_unit_cd+ 0)=ed.loc_nurse_unit_cd)
    AND elh.beg_effective_dt_tm <= cnvtdatetime(ms_end_dt_tm))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (ea1
   WHERE ea1.encntr_id=outerjoin(e.encntr_id)
    AND ea1.active_ind=outerjoin(1)
    AND ea1.encntr_alias_type_cd=outerjoin(mf_fin_cd))
   JOIN (ea2
   WHERE ea2.encntr_id=outerjoin(e.encntr_id)
    AND ea2.active_ind=outerjoin(1)
    AND ea2.encntr_alias_type_cd=outerjoin(mf_mrn_cd))
  ORDER BY ed.loc_nurse_unit_cd, p.name_last_key
  HEAD REPORT
   pl_cnt = 0
  HEAD e.encntr_id
   pl_cnt = (pl_cnt+ 1)
   IF (pl_cnt > size(m_rec->pat,5))
    stat = alterlist(m_rec->pat,(pl_cnt+ 10))
   ENDIF
   m_rec->pat[pl_cnt].f_person_id = p.person_id, m_rec->pat[pl_cnt].s_pat_name = trim(p
    .name_full_formatted), m_rec->pat[pl_cnt].f_encntr_id = e.encntr_id,
   m_rec->pat[pl_cnt].s_fin = trim(ea1.alias), m_rec->pat[pl_cnt].s_mrn = trim(ea2.alias)
  FOOT REPORT
   stat = alterlist(m_rec->pat,pl_cnt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  GO TO exit_script
 ENDIF
 DECLARE ml_ord_cnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  o.encntr_id, o.current_start_dt_tm
  FROM (dummyt d  WITH seq = value(size(m_rec->pat,5))),
   orders o
  PLAN (d)
   JOIN (o
   WHERE (o.person_id=m_rec->pat[d.seq].f_person_id)
    AND expand(ml_cnt,1,size(m_rec->adt,5),o.catalog_cd,m_rec->adt[ml_cnt].f_code_value)
    AND ((o.encntr_id+ 0)=m_rec->pat[d.seq].f_encntr_id)
    AND ((o.active_ind+ 0)=1)
    AND o.template_order_id=0
    AND o.orig_ord_as_flag=0
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm))
  ORDER BY o.encntr_id, o.current_start_dt_tm
  HEAD REPORT
   pl_cnt = 0, pl_ord_cnt = 0
  HEAD o.encntr_id
   pl_cnt = 0
  HEAD o.order_id
   pl_ord_cnt = (pl_ord_cnt+ 1), stat = alterlist(m_rec2->ord,(pl_ord_cnt+ 1)), m_rec2->ord[
   pl_ord_cnt].f_order_id = o.order_id,
   pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->pat[d.seq].ord,pl_cnt), m_rec->pat[d.seq].n_orders
    = 1,
   m_rec->pat[d.seq].ord[pl_cnt].f_order_id = o.order_id, m_rec->pat[d.seq].ord[pl_cnt].s_start_dt_tm
    = trim(format(o.current_start_dt_tm,"dd-mmm-yyyy hh:mm;;d")), m_rec->pat[d.seq].ord[pl_cnt].
   s_stop_dt_tm = trim(format(o.projected_stop_dt_tm,"dd-mmm-yyyy hh:mm;;d")),
   m_rec->pat[d.seq].ord[pl_cnt].s_orig_dt_tm = trim(format(o.orig_order_dt_tm,"dd-mmm-yyyy hh:mm;;d"
     )), m_rec->pat[d.seq].ord[pl_cnt].s_updt_dt_tm = trim(format(o.updt_dt_tm,"dd-mmm-yyyy hh:mm;;d"
     )), m_rec->pat[d.seq].ord[pl_cnt].s_mnemonic = trim(o.order_mnemonic)
  FOOT  o.order_id
   null
  FOOT  o.encntr_id
   ml_ord_cnt = (ml_ord_cnt+ pl_cnt)
  WITH nocounter
 ;end select
#exit_script
 CALL echorecord(m_rec2)
 FREE RECORD m_rec
 CALL echo(build("order cnt: ",ml_ord_cnt))
END GO
