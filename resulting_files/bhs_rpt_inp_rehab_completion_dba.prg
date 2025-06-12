CREATE PROGRAM bhs_rpt_inp_rehab_completion:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Facility" = 673936.00,
  "Unit" = 0.0,
  "Start Orders Date" = "SYSDATE",
  "End Orders Date" = "SYSDATE"
  WITH outdev, f_fname, f_unit,
  s_start_date, s_end_date
 DECLARE mf_cs69_emergency = f8 WITH constant(uar_get_code_by("DISPLAYKEY",69,"EMERGENCY")), protect
 DECLARE mf_cs69_observation = f8 WITH constant(uar_get_code_by("DISPLAYKEY",69,"OBSERVATION")),
 protect
 DECLARE mf_cs69_inpatient = f8 WITH constant(uar_get_code_by("DISPLAYKEY",69,"INPATIENT")), protect
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
 DECLARE mf_cs8_altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE mf_cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE ms_filename = vc WITH noconstant(concat("active_restraint_orders_")), protect
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
 DECLARE ml_order = i4 WITH noconstant(0), protect
 DECLARE ml_ord_cat = i4 WITH noconstant(0), protect
 DECLARE ms_opr_var1 = vc WITH protect
 DECLARE ms_lcheck = vc WITH protect
 DECLARE ml_gcnt = i4 WITH noconstant(0), protect
 DECLARE ms_sender = vc WITH protect
 DECLARE ms_msgcls = vc WITH protect
 DECLARE ms_sendto = vc WITH protect
 DECLARE ms_subject = vc WITH protect
 DECLARE ml_msgpriority = i4 WITH protect
 RECORD therapy(
   1 tot_order = i4
   1 o_comp = i4
   1 o_not_done = i4
   1 cnt_days = i4
   1 date[*]
     2 tot_orders = i4
     2 order_date = vc
     2 location = vc
     2 ther[*]
       3 order_type = vc
       3 tot_orders = i4
       3 tot_complete = i4
       3 tot_comp_same_day = i4
       3 tot_9am = i4
       3 comp_9am_same_day = i4
       3 comp_9am = i4
       3 cnt_ord_tp = i4
 )
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
 SELECT INTO "nl:"
  orderdatenbr = cnvtdate(o.orig_order_dt_tm), complete_date_nbr = cnvtdate(oa.action_dt_tm)
  FROM orders o,
   encntr_alias mrn,
   encntr_alias fin,
   encounter e,
   person p,
   order_action oa
  PLAN (e
   WHERE e.encntr_id=e.encntr_id
    AND e.active_status_cd=mf_cs48_active
    AND (e.loc_facility_cd= $F_FNAME)
    AND operator(e.loc_nurse_unit_cd,ms_opr_var1, $F_UNIT)
    AND e.encntr_type_class_cd IN (mf_cs69_observation, mf_cs69_inpatient, mf_cs69_emergency))
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
  ORDER BY orderdatenbr, o.catalog_type_cd, complete_date_nbr
  HEAD REPORT
   stat = alterlist(therapy->date,10)
  HEAD orderdatenbr
   therapy->cnt_days += 1
   IF (mod(therapy->cnt_days,10)=1
    AND (therapy->cnt_days > 1))
    stat = alterlist(therapy->date,(therapy->cnt_days+ 9))
   ENDIF
   therapy->date[therapy->cnt_days].order_date = format(o.orig_order_dt_tm,"@SHORTDATE4YR"), stat =
   alterlist(therapy->date[therapy->cnt_days].ther,10)
   IF (( $F_UNIT=0))
    therapy->date[therapy->cnt_days].location = concat(trim(uar_get_code_display( $F_FNAME),3),"-",
     "All units")
   ELSE
    therapy->date[therapy->cnt_days].location = concat(trim(uar_get_code_display( $F_FNAME),3),"-",
     trim(uar_get_code_display( $F_UNIT),3))
   ENDIF
  HEAD o.catalog_type_cd
   ml_ord_cat += 1
   IF (mod(ml_ord_cat,10)=1
    AND ml_ord_cat < 1)
    stat = alterlist(therapy->date[therapy->cnt_days].ther,(ml_ord_cat+ 9))
   ENDIF
  DETAIL
   therapy->date[therapy->cnt_days].ther[ml_ord_cat].order_type = uar_get_code_display(o
    .catalog_type_cd)
   IF (cnvttime(o.orig_order_dt_tm) <= 900)
    therapy->date[therapy->cnt_days].ther[ml_ord_cat].tot_9am += 1
    IF (oa.action_type_cd=mf_cs6003_complete
     AND cnvtdate(o.orig_order_dt_tm)=cnvtdate(oa.action_dt_tm))
     therapy->date[therapy->cnt_days].ther[ml_ord_cat].comp_9am_same_day += 1
    ENDIF
    therapy->date[therapy->cnt_days].ther[ml_ord_cat].comp_9am += 1
   ENDIF
   therapy->date[therapy->cnt_days].ther[ml_ord_cat].tot_orders += 1
   IF (oa.action_type_cd=mf_cs6003_complete
    AND cnvtdate(o.orig_order_dt_tm)=cnvtdate(oa.action_dt_tm))
    therapy->date[therapy->cnt_days].ther[ml_ord_cat].tot_comp_same_day += 1
   ENDIF
   therapy->date[therapy->cnt_days].ther[ml_ord_cat].tot_complete += 1, therapy->date[therapy->
   cnt_days].tot_orders += 1
  FOOT  o.catalog_type_cd
   null
  FOOT  orderdatenbr
   stat = alterlist(therapy->date[therapy->cnt_days].ther,ml_ord_cat), ml_ord_cat = 0, null
  FOOT REPORT
   stat = alterlist(therapy->date,therapy->cnt_days)
  WITH nocounter
 ;end select
 SELECT INTO  $OUTDEV
  location = substring(1,30,therapy->date[d1.seq].location), order_date = substring(1,30,therapy->
   date[d1.seq].order_date), order_type = substring(1,30,therapy->date[d1.seq].ther[d2.seq].
   order_type),
  total_ordered_by_9am = therapy->date[d1.seq].ther[d2.seq].tot_9am, total_complete_9am_same_day =
  therapy->date[d1.seq].ther[d2.seq].comp_9am_same_day, percent_done_9am_same_day = ((cnvtreal(
   therapy->date[d1.seq].ther[d2.seq].comp_9am_same_day)/ cnvtreal(therapy->date[d1.seq].ther[d2.seq]
   .tot_9am)) * 100),
  total_orders = therapy->date[d1.seq].ther[d2.seq].tot_orders, total_complete_same_day = therapy->
  date[d1.seq].ther[d2.seq].tot_comp_same_day, percent_complete_same_day = ((cnvtreal(therapy->date[
   d1.seq].ther[d2.seq].tot_comp_same_day)/ cnvtreal(therapy->date[d1.seq].ther[d2.seq].tot_orders))
   * 100),
  total_complete_all_orders = therapy->date[d1.seq].ther[d2.seq].tot_complete,
  percent_complete_all_orders = ((cnvtreal(therapy->date[d1.seq].ther[d2.seq].tot_complete)/ cnvtreal
  (therapy->date[d1.seq].ther[d2.seq].tot_orders)) * 100)
  FROM (dummyt d1  WITH seq = size(therapy->date,5)),
   (dummyt d2  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,size(therapy->date[d1.seq].ther,5)))
   JOIN (d2)
  WITH nocounter, format, separator = " "
 ;end select
END GO
