CREATE PROGRAM bhs_rpt_surg_order_aging:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Sched Location:" = value(0.0),
  "Look for Orders Greater than 340 days" = 340
  WITH outdev, mf_sched_loc_cd, mf_days
 DECLARE mf_cs14281_onhold = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!11558")), protect
 DECLARE mf_cs4_cmrn = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4,"CORPORATEMEDICALRECORDNUMBER"
   )), protect
 DECLARE mf_cs6004_future = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"FUTURE")), protect
 DECLARE mf_cs6000_surgery = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,"SURGERY")), protect
 DECLARE ms_opr_var = vc WITH protect
 DECLARE ms_lcheck = vc WITH protect
 DECLARE ml_gcnt = i4 WITH noconstant(0), protect
 RECORD grec1(
   1 list[*]
     2 mf_cv = f8
     2 ms_disp = c15
 )
 IF (ms_lcheck="L")
  SET ms_opr_var = "IN"
  WHILE (ms_lcheck > " ")
    SET ml_gcnt += 1
    SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $MF_SCHED_LOC_CD),ml_gcnt)))
    CALL echo(ms_lcheck)
    IF (ms_lcheck > " ")
     IF (mod(ml_gcnt,5)=1)
      SET stat = alterlist(grec1->list,(ml_gcnt+ 4))
     ENDIF
     SET grec1->list[ml_gcnt].mf_cv = cnvtint(parameter(parameter2( $MF_SCHED_LOC_CD),ml_gcnt))
     SET grec1->list[ml_gcnt].ms_disp = uar_get_code_display(parameter(parameter2( $MF_SCHED_LOC_CD),
       ml_gcnt))
    ENDIF
  ENDWHILE
  SET ml_gcnt -= 1
  SET stat = alterlist(grec1->list,ml_gcnt)
 ELSE
  SET stat = alterlist(grec1->list,1)
  SET ml_gcnt = 1
  SET grec1->list[1].mf_cv =  $MF_SCHED_LOC_CD
  IF ((grec1->list[1].mf_cv=0.0))
   SET grec1->list[1].ms_disp = "All Locations"
   SET ms_opr_var = "!="
  ELSE
   SET grec1->list[1].ms_disp = uar_get_code_display(grec1->list[1].mf_cv)
   SET ms_opr_var = "="
  ENDIF
 ENDIF
 SELECT INTO  $OUTDEV
  patient_name = substring(1,100,p.name_full_formatted), scheduled_appt_date = format(sa.beg_dt_tm,
   ";;D"), appointment_type = substring(1,30,uar_get_code_display(se.appt_type_cd)),
  cmrn = pa.alias, order_name = substring(1,100,o.hna_order_mnemonic), order_date = format(o
   .orig_order_dt_tm,";;D"),
  order_age_days = datetimediff(cnvtdatetime(sysdate),o.orig_order_dt_tm,1), surgical_case_number =
  substring(1,30,sc.surg_case_nbr_formatted), appointment_location_ = substring(1,30,
   uar_get_code_display(sa.appt_location_cd)),
  surgeon = substring(1,100,uar_get_code_display(sa1.resource_cd))
  FROM orders o,
   person p,
   person_alias pa,
   sch_event_attach sea,
   surgical_case sc,
   sch_appt sa,
   sch_appt sa1,
   sch_event se
  PLAN (o
   WHERE o.catalog_type_cd=mf_cs6000_surgery
    AND o.order_status_cd=mf_cs6004_future
    AND o.orig_order_dt_tm < cnvtdatetime((curdate -  $MF_DAYS),curtime3)
    AND o.dept_status_cd=mf_cs14281_onhold
    AND o.active_ind=1)
   JOIN (p
   WHERE p.person_id=o.person_id
    AND p.active_ind=1
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (pa
   WHERE pa.person_id=o.person_id
    AND pa.person_alias_type_cd=mf_cs4_cmrn
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate))
   JOIN (sea
   WHERE sea.order_id=o.order_id
    AND sea.active_ind=1)
   JOIN (sc
   WHERE sc.sch_event_id=sea.sch_event_id
    AND sc.checkin_dt_tm=null
    AND sc.active_ind=1)
   JOIN (se
   WHERE se.sch_event_id=sc.sch_event_id)
   JOIN (sa
   WHERE sa.sch_event_id=se.sch_event_id
    AND sa.primary_role_ind=1
    AND sa.state_meaning="CONFIRMED"
    AND sa.active_ind=1
    AND operator(sa.appt_location_cd,ms_opr_var, $MF_SCHED_LOC_CD)
    AND sa.beg_dt_tm >= cnvtdatetime(sysdate)
    AND sa.role_meaning="SURGOP")
   JOIN (sa1
   WHERE (sa1.sch_event_id= Outerjoin(se.sch_event_id))
    AND (sa1.active_ind= Outerjoin(1))
    AND (sa1.role_meaning= Outerjoin("SURGEON1"))
    AND (sa1.state_meaning= Outerjoin("CONFIRMED")) )
  ORDER BY scheduled_appt_date DESC, o.orig_order_dt_tm DESC, o.order_id
  WITH nocounter, format, separator = " "
 ;end select
END GO
