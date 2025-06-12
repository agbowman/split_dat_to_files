CREATE PROGRAM bhs_rpt_hist_pha_billingjw
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 IF (( $OUTDEV != "MINE"))
  SET var_output = "bhs_bhs_rpt_hist"
  SET filedelimiter1 = '"'
  SET filedelimiter2 = ","
 ELSE
  SET var_output =  $OUTDEV
  SET email_ind = 0
  SET filedelimiter1 = ""
  SET filedelimiter2 = ""
 ENDIF
 FREE RECORD pat
 RECORD pat(
   1 pt_qual[*]
     2 encntr_id = f8
 )
 FREE RECORD pha_info
 RECORD pha_info(
   1 ent_qual[*]
     2 f_person_id = f8
     2 s_patient_name = vc
     2 s_dob = vc
     2 s_age = vc
     2 s_sex = vc
     2 s_mrn = vc
     2 s_pcp = vc
     2 s_payor = vc
     2 s_city = vc
     2 f_encntr_id = f8
     2 s_fin = vc
     2 s_dischg_dt_tm = vc
     2 s_ent_status = vc
     2 s_loc = vc
     2 s_ent_type = vc
     2 s_ent_type_class = vc
     2 med_qual[*]
       3 f_order_id = f8
       3 s_order_dt_tm = vc
       3 s_order_status = vc
       3 s_med_name = vc
       3 s_med_ndc = vc
       3 s_med_quantity = vc
       3 s_med_refill = vc
       3 ord_phys_name = vc
       3 phys_npi = vc
       3 o_encntr_id = f8
 ) WITH protect
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE mf_pcp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",331,"PCP"))
 DECLARE mf_inpt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"INPATIENT"))
 DECLARE mf_outpt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"OUTPATIENT"))
 DECLARE mf_pharm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY"))
 DECLARE home_addr_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",212,"HOME"))
 DECLARE disp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"DISPENSEQUANTITY"))
 DECLARE disp_unit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "DISPENSE QUANTITY UNIT"))
 DECLARE mf_npi_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",320,
   "NATIONALPROVIDERIDENTIFIER"))
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE num = i4 WITH public, noconstant(0)
 DECLARE mp_cnt = i4 WITH public, noconstant(0)
 DECLARE me_cnt = i4 WITH public, noconstant(0)
 CALL echo("Gathering inpatient encntr_id...")
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE e.disch_dt_tm BETWEEN cnvtdatetime("01-OCT-2010") AND cnvtdatetime("02-OCT-2010")
    AND e.encntr_type_class_cd=mf_inpt_cd
    AND e.end_effective_dt_tm > sysdate)
  ORDER BY e.encntr_id
  HEAD REPORT
   mp_cnt = 0
  HEAD e.encntr_id
   mp_cnt = (mp_cnt+ 1), stat = alterlist(pat->pt_qual,mp_cnt), pat->pt_qual[mp_cnt].encntr_id = e
   .encntr_id
  WITH nocounter
 ;end select
 CALL echo("Gathering outpatient encntr_id...")
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE e.reg_dt_tm BETWEEN cnvtdatetime("01-OCT-2010") AND cnvtdatetime("02-OCT-2010")
    AND e.encntr_type_class_cd=mf_outpt_cd
    AND e.end_effective_dt_tm > sysdate)
  ORDER BY e.encntr_id
  HEAD e.encntr_id
   mp_cnt = (mp_cnt+ 1), stat = alterlist(pat->pt_qual,mp_cnt), pat->pt_qual[mp_cnt].encntr_id = e
   .encntr_id
  WITH nocounter
 ;end select
 CALL echo(build("mp_cnt = ",mp_cnt))
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   address a,
   person_prsnl_reltn ppr,
   person pr
  PLAN (e
   WHERE expand(num,1,size(pat->pt_qual,5),e.encntr_id,pat->pt_qual[num].encntr_id))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (a
   WHERE p.person_id=a.parent_entity_id
    AND a.parent_entity_name="PERSON"
    AND a.address_type_cd=home_addr_cd
    AND a.active_ind=1
    AND a.end_effective_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (ppr
   WHERE ppr.person_id=outerjoin(p.person_id)
    AND ppr.person_prsnl_r_cd=outerjoin(mf_pcp_cd)
    AND ppr.active_ind=outerjoin(1)
    AND ppr.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100")))
   JOIN (pr
   WHERE outerjoin(ppr.prsnl_person_id)=pr.person_id
    AND pr.active_ind=outerjoin(1)
    AND pr.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100")))
  ORDER BY e.encntr_type_class_cd, p.name_full_formatted, e.encntr_id
  HEAD REPORT
   me_cnt = 0
  HEAD e.encntr_id
   me_cnt = (me_cnt+ 1), stat = alterlist(pha_info->ent_qual,me_cnt), pha_info->ent_qual[me_cnt].
   f_encntr_id = e.encntr_id,
   pha_info->ent_qual[me_cnt].f_person_id = p.person_id, pha_info->ent_qual[me_cnt].s_age = cnvtage(p
    .birth_dt_tm)
   IF (e.encntr_type_class_cd=mf_inpt_cd)
    pha_info->ent_qual[me_cnt].s_dischg_dt_tm = format(e.disch_dt_tm,"@SHORTDATETIME")
   ENDIF
   IF (e.encntr_type_class_cd=mf_outpt_cd)
    pha_info->ent_qual[me_cnt].s_dischg_dt_tm = format(e.reg_dt_tm,"@SHORTDATETIME")
   ENDIF
   pha_info->ent_qual[me_cnt].s_dob = format(p.birth_dt_tm,"@SHORTDATETIME"), pha_info->ent_qual[
   me_cnt].s_ent_status = uar_get_code_display(e.encntr_status_cd), pha_info->ent_qual[me_cnt].s_loc
    = uar_get_code_display(e.loc_nurse_unit_cd),
   pha_info->ent_qual[me_cnt].s_patient_name = trim(p.name_full_formatted), pha_info->ent_qual[me_cnt
   ].s_sex = uar_get_code_display(p.sex_cd), pha_info->ent_qual[me_cnt].s_ent_type =
   uar_get_code_display(e.encntr_type_cd),
   pha_info->ent_qual[me_cnt].s_pcp = trim(pr.name_full_formatted), pha_info->ent_qual[me_cnt].s_city
    = trim(a.city), pha_info->ent_qual[me_cnt].s_ent_type_class = uar_get_code_display(e
    .encntr_type_class_cd)
  WITH expand = 1, nocounter, maxrec = 10
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(pha_info->ent_qual,5))),
   encntr_alias ea1,
   encntr_alias ea2
  PLAN (d
   WHERE d.seq <= size(pha_info->ent_qual,5))
   JOIN (ea1
   WHERE (ea1.encntr_id=pha_info->ent_qual[d.seq].f_encntr_id)
    AND ea1.active_ind=1
    AND ea1.encntr_alias_type_cd=mf_fin_cd)
   JOIN (ea2
   WHERE ea2.encntr_id=outerjoin(pha_info->ent_qual[d.seq].f_encntr_id)
    AND ea2.active_ind=outerjoin(1)
    AND ea2.encntr_alias_type_cd=outerjoin(mf_mrn_cd))
  DETAIL
   pha_info->ent_qual[d.seq].s_fin = cnvtalias(ea1.alias,ea1.alias_pool_cd), pha_info->ent_qual[d.seq
   ].s_mrn = cnvtalias(ea2.alias,ea2.alias_pool_cd)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(pha_info->ent_qual,5))),
   encntr_plan_reltn e,
   health_plan h
  PLAN (d
   WHERE d.seq <= size(pha_info->ent_qual,5))
   JOIN (e
   WHERE (e.encntr_id=pha_info->ent_qual[d.seq].f_encntr_id)
    AND e.active_ind=1
    AND e.end_effective_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (h
   WHERE h.health_plan_id=e.health_plan_id
    AND h.active_ind=1)
  DETAIL
   IF (e.priority_seq=1)
    pha_info->ent_qual[d.seq].s_payor = trim(h.plan_name)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(pha_info->ent_qual,5))),
   orders o,
   order_action oa,
   order_detail od,
   person p,
   prsnl_alias pa
  PLAN (d
   WHERE d.seq <= size(pha_info->ent_qual,5))
   JOIN (o
   WHERE (o.encntr_id=pha_info->ent_qual[d.seq].f_encntr_id)
    AND o.catalog_type_cd=mf_pharm_cd
    AND o.orig_ord_as_flag IN (1)
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime("01-OCT-2010") AND cnvtdatetime("02-OCT-2010"))
   JOIN (od
   WHERE od.order_id=o.order_id)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=1)
   JOIN (p
   WHERE p.person_id=oa.order_provider_id)
   JOIN (pa
   WHERE outerjoin(p.person_id)=pa.person_id
    AND pa.prsnl_alias_type_cd=outerjoin(mf_npi_cd))
  ORDER BY o.encntr_id, o.order_id
  HEAD o.encntr_id
   mo_cnt = 0, s_tmp1 = fillstring(10," "), s_tmp2 = fillstring(10," ")
  HEAD o.order_id
   mo_cnt = (mo_cnt+ 1), stat = alterlist(pha_info->ent_qual[d.seq].med_qual,mo_cnt), pha_info->
   ent_qual[d.seq].med_qual[mo_cnt].f_order_id = o.order_id,
   pha_info->ent_qual[d.seq].med_qual[mo_cnt].ord_phys_name = trim(p.name_full_formatted), pha_info->
   ent_qual[d.seq].med_qual[mo_cnt].s_order_dt_tm = format(o.orig_order_dt_tm,"@SHORTDATETIME"),
   pha_info->ent_qual[d.seq].med_qual[mo_cnt].s_med_name = trim(o.ordered_as_mnemonic),
   pha_info->ent_qual[d.seq].med_qual[mo_cnt].phys_npi = trim(pa.alias), pha_info->ent_qual[d.seq].
   med_qual[mo_cnt].s_order_status = uar_get_code_display(o.order_status_cd), pha_info->ent_qual[d
   .seq].med_qual[mo_cnt].o_encntr_id = o.encntr_id
  DETAIL
   IF (od.oe_field_id=disp_cd)
    s_tmp1 = trim(od.oe_field_display_value)
   ENDIF
   IF (od.oe_field_id=disp_unit_cd)
    s_tmp2 = trim(od.oe_field_display_value)
   ENDIF
   pha_info->ent_qual[d.seq].med_qual[mo_cnt].s_med_quantity = concat(trim(s_tmp1)," ",trim(s_tmp2))
  WITH nocounter
 ;end select
 SELECT INTO var_output
  pt_name = substring(1,50,pha_info->ent_qual[d.seq].s_patient_name), pt_age = substring(1,10,
   pha_info->ent_qual[d.seq].s_age), pt_sex = substring(1,10,pha_info->ent_qual[d.seq].s_sex),
  pt_dob = substring(1,20,pha_info->ent_qual[d.seq].s_dob), pt_city = substring(1,25,pha_info->
   ent_qual[d.seq].s_city), pt_mrn = substring(1,15,pha_info->ent_qual[d.seq].s_mrn),
  pt_fin = substring(1,20,pha_info->ent_qual[d.seq].s_fin), pt_location = substring(1,30,pha_info->
   ent_qual[d.seq].s_loc), pt_encounter_type = substring(1,20,pha_info->ent_qual[d.seq].s_ent_type),
  pt_encounter_type_class = substring(1,20,pha_info->ent_qual[d.seq].s_ent_type_class),
  pt_encounter_status = substring(1,15,pha_info->ent_qual[d.seq].s_ent_status),
  pt_encoutner_dischg_dt_tm = substring(1,20,pha_info->ent_qual[d.seq].s_dischg_dt_tm),
  pt_pcp = substring(1,30,pha_info->ent_qual[d.seq].s_pcp), pt_insurance_info = substring(1,30,
   pha_info->ent_qual[d.seq].s_payor), med_name = substring(1,50,pha_info->ent_qual[d.seq].med_qual[
   d1.seq].s_med_name),
  med_quantity = substring(1,20,pha_info->ent_qual[d.seq].med_qual[d1.seq].s_med_quantity),
  med_ord_dt_tm = substring(1,20,pha_info->ent_qual[d.seq].med_qual[d1.seq].s_order_dt_tm),
  med_ord_status = substring(1,15,pha_info->ent_qual[d.seq].med_qual[d1.seq].s_order_status),
  med_ord_phys_name = substring(1,30,pha_info->ent_qual[d.seq].med_qual[d1.seq].ord_phys_name),
  med_ord_phys_npi = substring(1,10,pha_info->ent_qual[d.seq].med_qual[d1.seq].phys_npi), ord_id =
  pha_info->ent_qual[d.seq].med_qual[d1.seq].f_order_id,
  p_encntr_id = pha_info->ent_qual[d.seq].f_encntr_id, o_encntr_id = pha_info->ent_qual[d.seq].
  med_qual[d1.seq].o_encntr_id
  FROM (dummyt d  WITH seq = value(size(pha_info->ent_qual,5))),
   dummyt d1
  PLAN (d
   WHERE maxrec(d1,size(pha_info->ent_qual[d.seq].med_qual,5)))
   JOIN (d1)
  ORDER BY pt_encounter_type_class, pt_name
  WITH nocounter, format, pcformat(value(filedelimiter1),value(filedelimiter2)),
   maxrec = 10
 ;end select
END GO
