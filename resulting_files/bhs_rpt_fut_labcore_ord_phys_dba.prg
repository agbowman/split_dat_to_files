CREATE PROGRAM bhs_rpt_fut_labcore_ord_phys:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Physician Last Name" = "",
  "Select Physician" = 0
  WITH outdev, s_phys_search, f_phys_prsnl_id
 DECLARE mf_prov_id = f8 WITH protect, constant(cnvtreal( $F_PHYS_PRSNL_ID))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE mf_future_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"FUTURE"))
 DECLARE mf_cs6004_ordered_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3102"))
 DECLARE mf_cs4_cmrn_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2621"))
 DECLARE mf_cs319_fin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs16449_perfloc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "PERFORMINGLOCATIONAMBULATORY"))
 DECLARE mf_cs6000_lab_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3081"))
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_order_id = f8
     2 s_pat_name = vc
     2 s_dob = vc
     2 s_cmrn = vc
     2 s_fin = vc
     2 s_order_name = vc
     2 s_order_provider = vc
     2 s_order_location = vc
     2 s_encntr_type = vc
     2 s_originating_fin = vc
     2 s_order_status = vc
 ) WITH protect
 IF (mf_prov_id <= 0.0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    col 0, "Provider is required"
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM orders o,
   prsnl pr,
   person p,
   person_alias pa,
   encounter e,
   encntr_alias ea
  PLAN (o
   WHERE o.encntr_id=0.0
    AND o.order_status_cd=mf_future_cd
    AND o.active_ind=1
    AND o.last_update_provider_id=mf_prov_id)
   JOIN (pr
   WHERE pr.person_id=o.last_update_provider_id)
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (pa
   WHERE pa.person_id=o.person_id
    AND pa.active_ind=1
    AND pa.person_alias_type_cd=mf_cs4_cmrn_cd
    AND pa.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (e
   WHERE e.encntr_id=o.originating_encntr_id)
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(e.encntr_id))
    AND (ea.active_ind= Outerjoin(1))
    AND (ea.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
    AND (ea.encntr_alias_type_cd= Outerjoin(mf_cs319_fin_cd)) )
  ORDER BY o.order_id, pa.beg_effective_dt_tm
  HEAD o.order_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_order_id = o.order_id,
   m_rec->qual[m_rec->l_cnt].s_pat_name = trim(p.name_full_formatted,3), m_rec->qual[m_rec->l_cnt].
   s_dob = trim(format(p.birth_dt_tm,"MM/DD/YYYY;;q"),3), m_rec->qual[m_rec->l_cnt].s_order_name =
   trim(uar_get_code_display(o.catalog_cd),3),
   m_rec->qual[m_rec->l_cnt].s_order_provider = trim(pr.name_full_formatted,3), m_rec->qual[m_rec->
   l_cnt].s_order_location = trim(uar_get_code_display(e.loc_nurse_unit_cd)), m_rec->qual[m_rec->
   l_cnt].s_cmrn = trim(pa.alias,3),
   m_rec->qual[m_rec->l_cnt].s_encntr_type = trim(uar_get_code_display(e.encntr_type_cd),3), m_rec->
   qual[m_rec->l_cnt].s_originating_fin = trim(ea.alias,3), m_rec->qual[m_rec->l_cnt].s_order_status
    = trim(uar_get_code_display(o.order_status_cd,3),3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM orders o,
   order_detail od,
   code_value cv,
   prsnl pr,
   person p,
   person_alias pa,
   encounter e,
   encntr_alias ea
  PLAN (o
   WHERE o.order_status_cd=mf_cs6004_ordered_cd
    AND o.active_ind=1
    AND o.catalog_type_cd=mf_cs6000_lab_cd
    AND o.last_update_provider_id=mf_prov_id)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_id=mf_cs16449_perfloc_cd)
   JOIN (cv
   WHERE cv.code_value=od.oe_field_value
    AND cv.display_key="LABCORP")
   JOIN (pr
   WHERE pr.person_id=o.last_update_provider_id)
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (pa
   WHERE pa.person_id=o.person_id
    AND pa.active_ind=1
    AND pa.person_alias_type_cd=mf_cs4_cmrn_cd
    AND pa.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (e
   WHERE e.encntr_id=o.encntr_id)
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(e.encntr_id))
    AND (ea.active_ind= Outerjoin(1))
    AND (ea.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
    AND (ea.encntr_alias_type_cd= Outerjoin(mf_cs319_fin_cd)) )
  ORDER BY o.order_id, pa.beg_effective_dt_tm
  HEAD o.order_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_order_id = o.order_id,
   m_rec->qual[m_rec->l_cnt].s_pat_name = trim(p.name_full_formatted,3), m_rec->qual[m_rec->l_cnt].
   s_dob = trim(format(p.birth_dt_tm,"MM/DD/YYYY;;q"),3), m_rec->qual[m_rec->l_cnt].s_order_name =
   trim(uar_get_code_display(o.catalog_cd),3),
   m_rec->qual[m_rec->l_cnt].s_order_provider = trim(pr.name_full_formatted,3), m_rec->qual[m_rec->
   l_cnt].s_order_location = trim(uar_get_code_display(e.loc_nurse_unit_cd)), m_rec->qual[m_rec->
   l_cnt].s_cmrn = trim(pa.alias,3),
   m_rec->qual[m_rec->l_cnt].s_encntr_type = trim(uar_get_code_display(e.encntr_type_cd),3), m_rec->
   qual[m_rec->l_cnt].s_fin = trim(ea.alias,3), m_rec->qual[m_rec->l_cnt].s_order_status = trim(
    uar_get_code_display(o.order_status_cd,3),3)
  WITH nocounter
 ;end select
 SELECT INTO  $OUTDEV
  patient_name = trim(substring(1,200,m_rec->qual[d1.seq].s_pat_name),3), dob = trim(substring(1,20,
    m_rec->qual[d1.seq].s_dob),3), cmrn = trim(substring(1,20,m_rec->qual[d1.seq].s_cmrn),3),
  fin = trim(substring(1,20,m_rec->qual[d1.seq].s_fin),3), encntr_type = trim(substring(1,50,m_rec->
    qual[d1.seq].s_encntr_type),3), originating_fin = trim(substring(1,20,m_rec->qual[d1.seq].
    s_originating_fin),3),
  order_name = trim(substring(1,200,m_rec->qual[d1.seq].s_order_name),3), ordering_provider = trim(
   substring(1,200,m_rec->qual[d1.seq].s_order_provider),3), ordering_location = trim(substring(1,120,
    m_rec->qual[d1.seq].s_order_location),3),
  order_status = trim(substring(1,120,m_rec->qual[d1.seq].s_order_status),3), order_id = m_rec->qual[
  d1.seq].f_order_id
  FROM (dummyt d1  WITH seq = m_rec->l_cnt)
  PLAN (d1)
  ORDER BY patient_name
  WITH nocounter, heading, maxrow = 1,
   formfeed = none, format, separator = " "
 ;end select
#exit_script
END GO
