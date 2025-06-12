CREATE PROGRAM bhs_rpt_oral_chemo:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Location" = 0
  WITH outdev, ms_start_date, ms_end_date,
  ms_loc
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE mf_pharmacy_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE mf_begin_dt_tm = f8 WITH protect, constant(cnvtdatetime(cnvtdate2( $MS_START_DATE,
    "DD-MMM-YYYY"),0))
 DECLARE mf_end_dt_tm = f8 WITH protect, constant(cnvtdatetime(cnvtdate2( $MS_END_DATE,"DD-MMM-YYYY"),
   235959))
 DECLARE ms_loc_ind = c1 WITH protect, constant(substring(1,1,reflect(parameter(4,0))))
 DECLARE mf_ea_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_ea_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 FREE RECORD ocat
 RECORD ocat(
   1 l_cnt = i4
   1 qual[*]
     2 f_catalog_cd = f8
     2 s_primary_mnemonic = vc
 ) WITH protect
 FREE RECORD presc
 RECORD presc(
   1 l_cnt = i4
   1 qual[*]
     2 f_order_id = f8
     2 s_person_name_full = vc
     2 s_person_dob = vc
     2 s_mrn = vc
     2 s_fin = vc
     2 s_facility = vc
     2 s_ord_provider_name = vc
     2 s_medication = vc
     2 s_order_date = vc
     2 s_route = vc
     2 s_ord_status = vc
 ) WITH protect
 FREE RECORD locs
 RECORD locs(
   1 l_cnt = i4
   1 qual[*]
     2 f_code_value = f8
     2 s_description = vc
 ) WITH protect
 IF (ms_loc_ind="C")
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=220
     AND cv.active_ind=1
     AND cv.cdf_meaning="FACILITY"
     AND cv.display_key IN ("CTRCACARE", "BMC", "BFMC", "BMLH", "BWH"))
   ORDER BY cv.display
   HEAD REPORT
    locs->l_cnt = 0
   DETAIL
    locs->l_cnt += 1, stat = alterlist(locs->qual,locs->l_cnt), locs->qual[locs->l_cnt].f_code_value
     = cv.code_value,
    locs->qual[locs->l_cnt].s_description = cv.description
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE (cv.code_value= $MS_LOC)
    AND cv.code_set=220
    AND cv.active_ind=1
   ORDER BY cv.display
   HEAD REPORT
    locs->l_cnt = 0
   DETAIL
    locs->l_cnt += 1, stat = alterlist(locs->qual,locs->l_cnt), locs->qual[locs->l_cnt].f_code_value
     = cv.code_value,
    locs->qual[locs->l_cnt].s_description = cv.description
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv,
   order_catalog oc
  PLAN (cv
   WHERE cv.display_key IN ("ABIRATERONE", "AFATINIB", "ANASTROZOLE", "AXITINIB", "BOSUTINIB",
   "CABOZANTINIB", "CAPECITABINE", "CRIZOTINIB", "DABRAFENIB", "DASATINIB",
   "ENZALUTAMIDE", "ERLOTINIB", "EVEROLIMUS", "EXEMESTANE", "IBRUTINIB",
   "IDELALISIB", "IMATINIB", "LAPATINIB", "LENALIDOMIDE", "LETROZOLE",
   "NILOTINIB", "OSIMERTINIB", "PALBOCICLIB", "PAZOPANIB", "POMALIDOMIDE",
   "REGORAFENIB", "RUXOLITINIB", "SORAFENIB", "SUNITINIB", "TAMOXIFEN",
   "TEMOZOLOMIDE", "THALIDOMIDE", "TRAMETINIB", "VEMURAFENIB")
    AND cv.code_set=200
    AND cv.active_ind=1)
   JOIN (oc
   WHERE oc.catalog_cd=cv.code_value
    AND oc.catalog_type_cd=mf_pharmacy_cd)
  ORDER BY oc.primary_mnemonic
  HEAD REPORT
   ocat->l_cnt = 0
  DETAIL
   ocat->l_cnt += 1, stat = alterlist(ocat->qual,ocat->l_cnt), ocat->qual[ocat->l_cnt].f_catalog_cd
    = oc.catalog_cd,
   ocat->qual[ocat->l_cnt].s_primary_mnemonic = oc.primary_mnemonic
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM orders o,
   encounter e,
   person p,
   encntr_alias ea1,
   encntr_alias ea2,
   order_action oa,
   prsnl pr,
   order_detail od
  PLAN (o
   WHERE o.order_status_cd=mf_ordered_cd
    AND o.template_order_flag=0
    AND o.orig_ord_as_flag=1
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND expand(ml_idx1,1,ocat->l_cnt,o.catalog_cd,ocat->qual[ml_idx1].f_catalog_cd))
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND expand(ml_idx2,1,locs->l_cnt,e.loc_facility_cd,locs->qual[ml_idx2].f_code_value))
   JOIN (ea1
   WHERE (ea1.encntr_id= Outerjoin(e.encntr_id))
    AND (ea1.encntr_alias_type_cd= Outerjoin(mf_ea_mrn_cd))
    AND (ea1.active_ind= Outerjoin(1))
    AND (ea1.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))) )
   JOIN (ea2
   WHERE (ea2.encntr_id= Outerjoin(e.encntr_id))
    AND (ea2.encntr_alias_type_cd= Outerjoin(mf_ea_fin_cd))
    AND (ea2.active_ind= Outerjoin(1))
    AND (ea2.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))) )
   JOIN (oa
   WHERE (oa.order_id= Outerjoin(o.order_id))
    AND (oa.action_sequence= Outerjoin(1)) )
   JOIN (pr
   WHERE (pr.person_id= Outerjoin(oa.order_provider_id)) )
   JOIN (od
   WHERE (od.order_id= Outerjoin(o.order_id))
    AND (od.oe_field_meaning= Outerjoin("RXROUTE")) )
  ORDER BY p.name_last_key, p.name_first_key, o.order_id,
   od.action_sequence DESC
  HEAD REPORT
   presc->l_cnt = 0
  HEAD o.order_id
   presc->l_cnt += 1, stat = alterlist(presc->qual,presc->l_cnt), presc->qual[presc->l_cnt].
   f_order_id = o.order_id,
   presc->qual[presc->l_cnt].s_facility = trim(uar_get_code_description(e.loc_facility_cd),3), presc
   ->qual[presc->l_cnt].s_fin = trim(ea2.alias,3), presc->qual[presc->l_cnt].s_medication = trim(o
    .hna_order_mnemonic,3),
   presc->qual[presc->l_cnt].s_mrn = trim(ea1.alias,3), presc->qual[presc->l_cnt].s_ord_provider_name
    = trim(pr.name_full_formatted,3), presc->qual[presc->l_cnt].s_ord_status = "Prescribed",
   presc->qual[presc->l_cnt].s_order_date = format(o.orig_order_dt_tm,"MM/DD/YYYY;;q"), presc->qual[
   presc->l_cnt].s_person_dob = format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),
    "MM/DD/YYYY;;q"), presc->qual[presc->l_cnt].s_person_name_full = trim(p.name_full_formatted,3)
  HEAD od.action_sequence
   presc->qual[presc->l_cnt].s_route = trim(od.oe_field_display_value,3)
  WITH nocounter
 ;end select
 CALL echorecord(presc)
 IF ((presc->l_cnt > 0))
  SELECT INTO  $OUTDEV
   patient_name = trim(substring(1,100,presc->qual[d.seq].s_person_name_full)), dob = trim(substring(
     1,100,presc->qual[d.seq].s_person_dob)), mrn = trim(substring(1,100,presc->qual[d.seq].s_mrn)),
   fin = trim(substring(1,100,presc->qual[d.seq].s_fin)), facility = trim(substring(1,100,presc->
     qual[d.seq].s_facility)), provider = trim(substring(1,100,presc->qual[d.seq].s_ord_provider_name
     )),
   medication = trim(substring(1,100,presc->qual[d.seq].s_medication)), date_prescribed = trim(
    substring(1,100,presc->qual[d.seq].s_order_date)), route_of_administration = trim(substring(1,100,
     presc->qual[d.seq].s_route)),
   order_status = trim(substring(1,100,presc->qual[d.seq].s_ord_status))
   FROM (dummyt d  WITH seq = presc->l_cnt)
   PLAN (d
    WHERE d.seq > 0)
   ORDER BY facility, patient_name
   WITH nocounter, maxcol = 1100, format,
    separator = " ", memsort
  ;end select
 ELSE
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Report finished successfully. No data qualified.", col 0,
    "{PS/792 0 translate 90 rotate/}",
    y_pos = 18, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1
   WITH dio = 08
  ;end select
 ENDIF
#exit_script
END GO
