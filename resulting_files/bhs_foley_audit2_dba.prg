CREATE PROGRAM bhs_foley_audit2:dba
 DECLARE mf_phys_notif_cath_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PHYSICIANNOTIFIEDOFCATHETERREMOVAL"))
 DECLARE mf_cath_indication_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INDICATIONFORURINARYCATHETER"))
 DECLARE mf_cath_remove_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "REMOVECATHETER"))
 DECLARE mf_cath_remove_dt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "REMOVECATHETERDATETIME"))
 DECLARE mf_cath_insert_dt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INSERTCATHETERDATETIME"))
 DECLARE mf_date_of_ins_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DATEOFINSERTION"))
 DECLARE mf_foley_cath_ind_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "FOLEYCATHINDICATIONS"))
 DECLARE mf_urin_cath_ind_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "INDICATIONURINARYCATH"))
 DECLARE mf_fin = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_order_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER"))
 DECLARE ml_debug_flag = i4 WITH protect, constant(validate(bhs_debug_flag,0))
 DECLARE mf_cs200_cathcomp = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CATHETERCOMPARTMENTSYNDROME"))
 DECLARE mf_cs200_cathtemp = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CATHETERCORETEMPERATUREMONITORING"))
 DECLARE mf_cs200_cathcoude = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CATHETERCOUDE"))
 DECLARE mf_cs200_cathsingl = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CATHETERSINGLELUMENINDWELLINGURINARY"))
 DECLARE mf_cs200_cathtripl = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CATHETERTRIPLELUMENINDWELLINGURINARY"))
 DECLARE mf_cs200_ins_fol = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "INSERTCATHETERFOLEY"))
 DECLARE mf_cs6004_ordered = f8 WITH protect, noconstant(uar_get_code_by_cki("CKI.CODEVALUE!3102"))
 DECLARE ms_parse_fac = vc WITH protect, noconstant(" ")
 DECLARE ms_parse_nu = vc WITH protect, noconstant(" ")
 SET reply_foley->c_status = "F"
 IF (((validate(request_foley->f_facility_cd)=0) OR (validate(reply_foley->c_status)=0)) )
  SET ms_error = concat(ms_error,"Foley Request/Reply structures not found. ")
  GO TO exit_script
 ENDIF
 IF ((((request_foley->d_start_dt_tm=0)) OR ((((request_foley->d_end_dt_tm=0)) OR ((request_foley->
 d_start_dt_tm > request_foley->d_end_dt_tm))) )) )
  SET ms_error = concat(ms_error,"Invalid date range in the child script. ")
  GO TO exit_script
 ENDIF
 IF ((request_foley->f_facility_cd=0.0))
  SET ms_parse_fac = " 1=1 "
 ELSE
  SET ms_parse_fac = build2(" ed.loc_facility_cd = ",request_foley->f_facility_cd)
 ENDIF
 IF ((request_foley->f_nurse_unit_cd=0.0))
  SET ms_parse_nu = " 1=1 "
 ELSE
  SET ms_parse_nu = build2(" ed.loc_nurse_unit_cd = ",request_foley->f_nurse_unit_cd)
 ENDIF
 SELECT INTO "nl:"
  FROM encntr_domain ed,
   encounter e,
   orders o,
   order_detail od,
   order_detail od2,
   order_action oa,
   person p2,
   encntr_alias ea,
   person p
  PLAN (ed
   WHERE ed.active_ind=1
    AND parser(ms_parse_fac)
    AND parser(ms_parse_nu))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.active_ind=1
    AND e.reg_dt_tm < cnvtdatetime(request_foley->d_end_dt_tm)
    AND ((e.disch_dt_tm=null) OR (e.disch_dt_tm > cnvtdatetime(request_foley->d_start_dt_tm))) )
   JOIN (o
   WHERE o.encntr_id=e.encntr_id
    AND o.active_ind=1
    AND o.orig_order_dt_tm BETWEEN e.reg_dt_tm AND sysdate
    AND o.order_status_cd=mf_cs6004_ordered
    AND o.catalog_cd IN (mf_cs200_cathcomp, mf_cs200_cathtemp, mf_cs200_cathcoude, mf_cs200_cathsingl,
   mf_cs200_cathtripl,
   mf_cs200_ins_fol))
   JOIN (od
   WHERE (od.order_id= Outerjoin(o.order_id))
    AND (od.oe_field_id= Outerjoin(mf_foley_cath_ind_cd)) )
   JOIN (od2
   WHERE (od2.order_id= Outerjoin(o.order_id))
    AND (od2.oe_field_id= Outerjoin(mf_urin_cath_ind_cd)) )
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_type_cd=mf_order_cd)
   JOIN (p2
   WHERE (p2.person_id= Outerjoin(oa.order_provider_id)) )
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(e.encntr_id))
    AND (ea.encntr_alias_type_cd= Outerjoin(mf_fin)) )
   JOIN (p
   WHERE p.person_id=e.person_id)
  ORDER BY p.name_full_formatted, o.catalog_cd, e.encntr_id
  HEAD REPORT
   CALL echo("head report")
  DETAIL
   reply_foley->cath_cnt += 1
   IF (mod(reply_foley->cath_cnt,100)=1)
    CALL alterlist(reply_foley->caths,(reply_foley->cath_cnt+ 99))
   ENDIF
   reply_foley->caths[reply_foley->cath_cnt].person_id = e.person_id, reply_foley->caths[reply_foley
   ->cath_cnt].encntr_id = e.encntr_id, reply_foley->caths[reply_foley->cath_cnt].admit_dt_tm = e
   .reg_dt_tm,
   reply_foley->caths[reply_foley->cath_cnt].loc_nurse_unit = trim(uar_get_code_display(e
     .loc_nurse_unit_cd),3), reply_foley->caths[reply_foley->cath_cnt].name_full_formatted = trim(p
    .name_full_formatted,3), reply_foley->caths[reply_foley->cath_cnt].fin = trim(ea.alias,3),
   reply_foley->caths[reply_foley->cath_cnt].cath_type_str = trim(uar_get_code_display(o.catalog_cd),
    3), reply_foley->caths[reply_foley->cath_cnt].cath_order_dt_tm = o.orig_order_dt_tm, reply_foley
   ->caths[reply_foley->cath_cnt].ordering_provider_name = trim(p2.name_full_formatted,3)
   IF (od.oe_field_id > 0.00)
    reply_foley->caths[reply_foley->cath_cnt].order_indication_str = trim(od.oe_field_display_value,3
     )
   ELSE
    reply_foley->caths[reply_foley->cath_cnt].order_indication_str = trim(od2.oe_field_display_value,
     3)
   ENDIF
  FOOT REPORT
   CALL alterlist(reply_foley->caths,reply_foley->cath_cnt)
  WITH nocounter
 ;end select
 IF ((reply_foley->cath_cnt <= 0))
  SET ms_error = concat(ms_error,"No foley catheter orders found from ",ms_time,
   " in the child script. ")
  GO TO exit_script
 ELSE
  CALL echorecord(reply_foley)
 ENDIF
 CALL echorecord(request_foley)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(reply_foley->cath_cnt)),
   encntr_loc_hist elh,
   code_value cv
  PLAN (d)
   JOIN (elh
   WHERE (elh.encntr_id=reply_foley->caths[d.seq].encntr_id)
    AND elh.beg_effective_dt_tm <= cnvtdatetime(reply_foley->caths[d.seq].cath_order_dt_tm)
    AND elh.end_effective_dt_tm >= cnvtdatetime(reply_foley->caths[d.seq].cath_order_dt_tm))
   JOIN (cv
   WHERE cv.code_value=elh.loc_nurse_unit_cd)
  DETAIL
   reply_foley->caths[d.seq].loc_when_cath_ordered = trim(cv.display)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = reply_foley->cath_cnt),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.encntr_id=reply_foley->caths[d.seq].encntr_id)
    AND (ce.person_id=reply_foley->caths[d.seq].person_id)
    AND ce.event_cd IN (mf_phys_notif_cath_cd, mf_cath_indication_cd, mf_cath_remove_cd,
   mf_cath_remove_dt_cd, mf_cath_insert_dt_cd,
   mf_date_of_ins_cd))
  ORDER BY ce.clinsig_updt_dt_tm
  DETAIL
   CASE (ce.event_cd)
    OF mf_phys_notif_cath_cd:
     reply_foley->caths[d.seq].physician_notified_name = trim(ce.result_val)
    OF mf_cath_indication_cd:
     reply_foley->caths[d.seq].cath_indication_str = trim(ce.result_val)
    OF mf_cath_remove_cd:
     IF (cnvtupper(ce.result_val) IN ("YES", "NO"))
      reply_foley->caths[d.seq].cath_remove_ind = trim(ce.result_val)
     ENDIF
    OF mf_cath_remove_dt_cd:
     IF (((ce.result_val="0:*") OR (ce.result_val="1:*")) )
      reply_foley->caths[d.seq].cath_removal_dt_tm = cnvtdatetime(cnvtdate2(substring(3,8,ce
         .result_val),"yyyymmdd"),cnvttime2(substring(11,6,ce.result_val),"HHMMSS"))
     ENDIF
    OF mf_date_of_ins_cd:
    OF mf_cath_insert_dt_cd:
     IF (((ce.result_val="0:*") OR (ce.result_val="1:*")) )
      reply_foley->caths[d.seq].cath_insertion_dt_tm = cnvtdatetime(cnvtdate2(substring(3,8,ce
         .result_val),"yyyymmdd"),cnvttime2(substring(11,6,ce.result_val),"HHMMSS"))
     ENDIF
   ENDCASE
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET ms_error = concat(ms_error,"No Location found for encounters in child script. ")
  GO TO exit_script
 ENDIF
 SET reply_foley->c_status = "S"
#exit_script
 IF (ml_debug_flag > 0)
  CALL echorecord(reply_foley)
  CALL echorecord(request_foley)
 ENDIF
END GO
