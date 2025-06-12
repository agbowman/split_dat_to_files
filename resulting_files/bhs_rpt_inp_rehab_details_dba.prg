CREATE PROGRAM bhs_rpt_inp_rehab_details:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Facility" = 673936.00,
  "Unit" = 0.0,
  "Enter Emails" = "",
  "Start Orders Date" = "SYSDATE",
  "End Orders Date" = "SYSDATE"
  WITH outdev, f_fname, f_unit,
  s_emails, s_start_date, s_end_date
 DECLARE mf_cs69_emergency = f8 WITH constant(uar_get_code_by("DISPLAYKEY",69,"EMERGENCY")), protect
 DECLARE mf_cs69_observation = f8 WITH constant(uar_get_code_by("DISPLAYKEY",69,"OBSERVATION")),
 protect
 DECLARE mf_cs69_inpatient = f8 WITH constant(uar_get_code_by("DISPLAYKEY",69,"INPATIENT")), protect
 DECLARE mf_cs200_discharge = f8 WITH constant(uar_get_code_by_cki("CKI.ORD!2702")), protect
 DECLARE mf_cs333_attendingphysician = f8 WITH constant(uar_get_code_by("DISPLAYKEY",333,
   "ATTENDINGPHYSICIAN")), protect
 DECLARE mf_cs6000_physicaltherapy = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,
   "PHYSICALTHERAPY")), protect
 DECLARE mf_cs6000_occupationaltherapy = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,
   "OCCUPATIONALTHERAPY")), protect
 DECLARE mf_cs6000_speechtherapy = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,"SPEECHTHERAPY"
   )), protect
 DECLARE mf_cs200_st_eval_pedi = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "STEVALTREATSPEECHLANGUAGEPEDI")), protect
 DECLARE mf_cs200_st_eval_treat = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "STEVALTREATSPEECHLANGUAGE")), protect
 DECLARE mf_cs200_st_eval_treat_cog = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "STEVALTREATSPEECHLANGUAGECOGNITIVE")), protect
 DECLARE mf_cs200_ot_eval_treat = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"OTEVALTREAT")),
 protect
 DECLARE mf_cs200_ot_eval_treat_pedi = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "OTEVALTREATPEDI")), protect
 DECLARE mf_cs200_pt_eval_treat_pedi = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "PTEVALTREATPEDI")), protect
 DECLARE mf_cs200_pt_eval_treat = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"PTEVALTREAT")),
 protect
 DECLARE mf_cs6004_ordered = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED")), protect
 DECLARE mf_cs6004_completed = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"COMPLETED")),
 protect
 DECLARE mf_cs6003_complete = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"COMPLETE")),
 protect
 DECLARE mf_cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE mf_cs319_mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN")), protect
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE ms_filename = vc WITH noconstant(concat("det_active_restraint_orders_")), protect
 DECLARE ms_output_file = vc WITH noconstant(build(trim(ms_filename,3),format(sysdate,"MMDDYYYY;;q"),
   ".csv")), protect
 DECLARE ml_attloc = i4 WITH protect
 DECLARE ml_num = i4 WITH protect
 DECLARE ml_loc = i4 WITH protect
 DECLARE ml_numres = i4 WITH protect
 DECLARE ml_time = i4 WITH noconstant(0), protect
 DECLARE ml_ops_ind = i4 WITH noconstant(0), protect
 DECLARE order_name = vc WITH noconstant("                                                    "),
 protect
 DECLARE ms_opr_var1 = vc WITH protect
 DECLARE ms_lcheck = vc WITH protect
 DECLARE ml_gcnt = i4 WITH noconstant(0), protect
 DECLARE ms_sender = vc WITH protect
 DECLARE ms_msgcls = vc WITH protect
 DECLARE ms_sendto = vc WITH protect
 DECLARE ms_subject = vc WITH protect
 DECLARE ml_msgpriority = i4 WITH protect
 FREE RECORD grec2
 RECORD grec2(
   1 list[*]
     2 f_cv = f8
     2 s_disp = c15
 )
 SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $F_UNIT),0)))
 SET ml_gcnt = 0
 IF (ms_lcheck="L")
  SET ms_opr_var1 = "IN"
  WHILE (ms_lcheck > " ")
    SET ml_gcnt += 1
    SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $F_UNIT),ml_gcnt)))
    CALL echo(ms_lcheck)
    IF (ms_lcheck > " ")
     IF (mod(ml_gcnt,5)=1)
      SET stat = alterlist(grec2->list,(ml_gcnt+ 4))
     ENDIF
     SET grec2->list[ml_gcnt].f_cv = cnvtint(parameter(parameter2( $F_UNIT),ml_gcnt))
     SET grec2->list[ml_gcnt].s_disp = uar_get_code_display(parameter(parameter2( $F_UNIT),ml_gcnt))
    ENDIF
  ENDWHILE
  SET ml_gcnt -= 1
  SET stat = alterlist(grec2->list,ml_gcnt)
 ELSE
  SET stat = alterlist(grec2->list,1)
  SET ml_gcnt = 1
  SET grec2->list[1].f_cv =  $F_UNIT
  IF ((grec2->list[1].f_cv=0.0))
   SET grec2->list[1].s_disp = "All Units"
   SET ms_opr_var1 = "!="
  ELSE
   SET grec2->list[1].s_disp = uar_get_code_display(grec2->list[1].f_cv)
   SET ms_opr_var1 = "="
  ENDIF
 ENDIF
 RECORD rehab(
   1 cnt_ord = i4
   1 ords[*]
     2 facility = vc
     2 unit = vc
     2 patient_name = vc
     2 mrn = vc
     2 account_number = vc
     2 attending_physician = vc
     2 order_name = vc
     2 order_date = vc
     2 disch_date_time = cv
     2 completion_date_time = cv
 )
 SELECT INTO "nl:"
  facility = uar_get_code_display(e.loc_facility_cd), unit = uar_get_code_display(e.loc_nurse_unit_cd
   ), patient_name = substring(1,100,p.name_full_formatted),
  mrn = substring(1,30,mrn.alias), account_number = substring(1,30,fin.alias), attending_physician =
  substring(1,100,pr.name_full_formatted),
  order_name = substring(1,100,o.ordered_as_mnemonic), order_date = format(o.orig_order_dt_tm,
   "mm/dd/yyyy hh:mm;;Q"), discharge_order_date = format(disch.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;Q"
   ),
  completion_date = format(oa.action_dt_tm,"mm/dd/yyyy hh:mm;;Q")
  FROM orders o,
   encntr_alias mrn,
   encntr_alias fin,
   encounter e,
   person p,
   order_action oa,
   encntr_prsnl_reltn epr,
   prsnl pr,
   orders disch
  PLAN (e
   WHERE e.encntr_id=e.encntr_id
    AND e.active_status_cd=mf_cs48_active
    AND (e.loc_facility_cd= $F_FNAME)
    AND operator(e.loc_nurse_unit_cd,ms_opr_var1, $F_UNIT)
    AND e.encntr_type_class_cd IN (mf_cs69_observation, mf_cs69_inpatient, mf_cs69_emergency))
   JOIN (epr
   WHERE (epr.encntr_prsnl_r_cd= Outerjoin(mf_cs333_attendingphysician))
    AND (epr.active_ind= Outerjoin(1))
    AND (epr.beg_effective_dt_tm<= Outerjoin(sysdate))
    AND (epr.end_effective_dt_tm>= Outerjoin(sysdate))
    AND (epr.encntr_id= Outerjoin(e.encntr_id)) )
   JOIN (disch
   WHERE (disch.person_id= Outerjoin(e.person_id))
    AND (disch.encntr_id= Outerjoin(e.encntr_id))
    AND (disch.active_ind= Outerjoin(1))
    AND (disch.catalog_cd= Outerjoin(mf_cs200_discharge)) )
   JOIN (pr
   WHERE (pr.person_id= Outerjoin(epr.prsnl_person_id)) )
   JOIN (o
   WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime( $S_START_DATE) AND cnvtdatetime( $S_END_DATE)
    AND o.order_status_cd IN (mf_cs6004_ordered, mf_cs6004_completed)
    AND o.encntr_id=e.encntr_id
    AND o.person_id=e.person_id
    AND o.catalog_cd IN (mf_cs200_st_eval_pedi, mf_cs200_st_eval_treat, mf_cs200_st_eval_treat_cog,
   mf_cs200_ot_eval_treat, mf_cs200_ot_eval_treat_pedi,
   mf_cs200_pt_eval_treat_pedi, mf_cs200_pt_eval_treat))
   JOIN (oa
   WHERE (oa.order_id= Outerjoin(o.order_id))
    AND (oa.action_type_cd= Outerjoin(mf_cs6003_complete)) )
   JOIN (fin
   WHERE fin.encntr_id=e.encntr_id
    AND fin.active_ind=1
    AND fin.encntr_alias_type_cd=mf_cs319_fin_cd
    AND sysdate BETWEEN fin.beg_effective_dt_tm AND fin.end_effective_dt_tm)
   JOIN (mrn
   WHERE mrn.encntr_id=e.encntr_id
    AND mrn.active_ind=1
    AND mrn.encntr_alias_type_cd=mf_cs319_mrn_cd
    AND sysdate BETWEEN mrn.beg_effective_dt_tm AND mrn.end_effective_dt_tm)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_status_cd=mf_cs48_active
    AND p.active_ind=1)
  ORDER BY e.loc_nurse_unit_cd, p.name_full_formatted, o.order_id,
   disch.orig_order_dt_tm DESC
  HEAD REPORT
   stat = alterlist(rehab->ords,10)
  HEAD o.order_id
   rehab->cnt_ord += 1
   IF (mod(rehab->cnt_ord,10)=1
    AND (rehab->cnt_ord > 1))
    stat = alterlist(rehab->ords,(rehab->cnt_ord+ 9))
   ENDIF
   rehab->ords[rehab->cnt_ord].facility = uar_get_code_display(e.loc_facility_cd), rehab->ords[rehab
   ->cnt_ord].unit = uar_get_code_display(e.loc_nurse_unit_cd), rehab->ords[rehab->cnt_ord].
   patient_name = substring(1,100,p.name_full_formatted),
   rehab->ords[rehab->cnt_ord].mrn = substring(1,30,mrn.alias), rehab->ords[rehab->cnt_ord].
   account_number = substring(1,30,fin.alias), rehab->ords[rehab->cnt_ord].attending_physician =
   substring(1,100,pr.name_full_formatted),
   rehab->ords[rehab->cnt_ord].order_name = substring(1,100,o.ordered_as_mnemonic), rehab->ords[rehab
   ->cnt_ord].order_date = format(o.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;Q"), rehab->ords[rehab->
   cnt_ord].disch_date_time = format(disch.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;Q"),
   rehab->ords[rehab->cnt_ord].completion_date_time = format(oa.action_dt_tm,"mm/dd/yyyy hh:mm;;Q")
  FOOT REPORT
   stat = alterlist(rehab->ords,rehab->cnt_ord)
  WITH nocounter
 ;end select
 IF (size(rehab->ords,5) > 0)
  SELECT INTO  $OUTDEV
   facility = substring(1,30,rehab->ords[d1.seq].facility), unit = substring(1,30,rehab->ords[d1.seq]
    .unit), patient_name = substring(1,100,rehab->ords[d1.seq].patient_name),
   account_number = substring(1,30,rehab->ords[d1.seq].account_number), attending_physician =
   substring(1,30,rehab->ords[d1.seq].attending_physician), order_name = substring(1,30,rehab->ords[
    d1.seq].order_name),
   order_date = substring(1,30,rehab->ords[d1.seq].order_date), discharge_order_date = substring(1,30,
    rehab->ords[d1.seq].disch_date_time), completion_date = substring(1,30,rehab->ords[d1.seq].
    completion_date_time)
   FROM (dummyt d1  WITH seq = size(rehab->ords,5))
   PLAN (d1)
   WITH nocounter, separator = " ", format
  ;end select
 ENDIF
END GO
