CREATE PROGRAM bhs_rpt_init_soc_wrk_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Facility" = 0,
  "Unit" = value(0.0),
  "Start date" = "CURDATE",
  "End Date" = "CURDATE"
  WITH outdev, f_fname, f_unit,
  s_start_date, s_end_date
 FREE RECORD pats
 RECORD pats(
   1 cnt_pt = i4
   1 list[*]
     2 s_patname = vc
     2 s_age = vc
     2 s_ethnic = vc
     2 s_fin = vc
     2 s_facility = vc
     2 s_unit_bed = vc
     2 s_audit_score = vc
     2 s_sw_consult = vc
     2 f_person_id = f8
     2 s_race = vc
     2 f_orderid = f8
     2 f_updateid = f8
     2 s_comment = vc
 )
 FREE RECORD grec1
 RECORD grec1(
   1 list[*]
     2 f_cv = f8
     2 s_disp = c15
 )
 DECLARE mf_cs53_num = f8 WITH constant(uar_get_code_by("DISPLAYKEY",53,"NUM")), protect
 DECLARE mf_cs72_auditassessmentform = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "AUDITASSESSMENTFORM")), protect
 DECLARE mf_cs72_auditscore = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"AUDITSCORE")),
 protect
 DECLARE mf_cs200_initialswconsult = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "INITIALSWCONSULT")), protect
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE mf_cs319_mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN")), protect
 DECLARE mf_cs8_altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE mf_cs8_modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE mf_cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE mf_cs8_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"ACTIVE")), protect
 DECLARE mf_cs355_user_def_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",355,
   "USERDEFINED"))
 DECLARE mf_cs356_race1 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE1"))
 DECLARE mf_cs356_race2 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE2"))
 DECLARE mf_cs356_race3 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE3"))
 DECLARE mf_cs356_race4 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE4"))
 DECLARE mf_cs356_race5 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE5"))
 DECLARE mf_cs6003_order = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER"))
 DECLARE ms_start_date = vc WITH noconstant( $S_START_DATE), protect
 DECLARE ms_end_date = vc WITH noconstant( $S_END_DATE), protect
 DECLARE location = vc WITH protect, noconstant("              ")
 DECLARE patient_name = vc WITH protect, noconstant("              ")
 DECLARE mrn = vc WITH protect, noconstant("              ")
 DECLARE ms_error = vc WITH protect, noconstant("              ")
 DECLARE ms_subject = vc WITH protect, noconstant("              ")
 DECLARE ml_cnt2 = i4 WITH noconstant(0), protect
 DECLARE ml_cnt = i4 WITH noconstant(0), protect
 DECLARE ms_opr_var = vc WITH protect
 DECLARE ms_lcheck = vc WITH protect
 DECLARE ml_gcnt = i4 WITH noconstant(0), protect
 DECLARE ms_filename = vc WITH noconstant(concat("bhs_transfusion_review_")), protect
 DECLARE ms_output_file = vc WITH noconstant(build(trim(ms_filename,3),format(sysdate,"MMDDYYYY;;q"),
   ".csv")), protect
 IF (datetimediff(cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959),cnvtdatetime(cnvtdate2(
    ms_start_date,"DD-MMM-YYYY"),0)) >= 60)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = "Max Run days is 60 you ran ", msg2 = build2(trim(cnvtstring(datetimediff(cnvtdatetime(
         cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959),cnvtdatetime(cnvtdate2(ms_start_date,
          "DD-MMM-YYYY"),0)),0),3)," Days Please try again"),
    CALL print(calcpos(36,18)),
    msg1, msg2
   WITH dio = 08
  ;end select
  GO TO exit_script
 ENDIF
 SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $F_UNIT),0)))
 IF (ms_lcheck="L")
  SET ms_opr_var = "IN"
  WHILE (ms_lcheck > " ")
    SET ml_gcnt += 1
    SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $F_UNIT),ml_gcnt)))
    CALL echo(ms_lcheck)
    IF (ms_lcheck > " ")
     IF (mod(ml_gcnt,5)=1)
      SET stat = alterlist(grec1->list,(ml_gcnt+ 4))
     ENDIF
     SET grec1->list[ml_gcnt].f_cv = cnvtint(parameter(parameter2( $F_UNIT),ml_gcnt))
     SET grec1->list[ml_gcnt].s_disp = uar_get_code_display(parameter(parameter2( $F_UNIT),ml_gcnt))
    ENDIF
  ENDWHILE
  SET ml_gcnt -= 1
  SET stat = alterlist(grec1->list,ml_gcnt)
 ELSE
  SET stat = alterlist(grec1->list,1)
  SET ml_gcnt = 1
  SET grec1->list[1].f_cv =  $F_UNIT
  IF ((grec1->list[1].f_cv=0.0))
   SET grec1->list[1].s_disp = "All Units"
   SET ms_opr_var = "!="
  ELSE
   SET grec1->list[1].s_disp = uar_get_code_display(grec1->list[1].f_cv)
   SET ms_opr_var = "="
  ENDIF
 ENDIF
 SELECT INTO "NL:"
  result = cnvtreal(ce.result_val)
  FROM orders o,
   order_comment oc,
   long_text lt,
   encounter e,
   person p,
   encntr_alias fin,
   clinical_event ce,
   bhs_demographics bd
  PLAN (ce
   WHERE ce.event_cd=mf_cs72_auditscore
    AND ce.result_status_cd IN (mf_cs8_auth_cd, mf_cs8_altered_cd, mf_cs8_modified_cd)
    AND ce.valid_until_dt_tm > sysdate
    AND ce.view_level=1
    AND ce.event_class_cd=mf_cs53_num
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0) AND
   cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959))
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND e.person_id=ce.person_id
    AND (e.loc_facility_cd= $F_FNAME)
    AND operator(e.loc_nurse_unit_cd,ms_opr_var, $F_UNIT)
    AND e.active_ind=1
    AND e.active_status_cd=mf_cs48_active)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1
    AND p.active_status_cd=mf_cs48_active)
   JOIN (fin
   WHERE fin.encntr_id=e.encntr_id
    AND fin.active_ind=1
    AND fin.encntr_alias_type_cd=mf_cs319_fin_cd
    AND sysdate BETWEEN fin.beg_effective_dt_tm AND fin.end_effective_dt_tm)
   JOIN (o
   WHERE (o.encntr_id= Outerjoin(ce.encntr_id))
    AND (o.person_id= Outerjoin(ce.person_id))
    AND (o.catalog_cd= Outerjoin(mf_cs200_initialswconsult)) )
   JOIN (oc
   WHERE (oc.order_id= Outerjoin(o.order_id)) )
   JOIN (lt
   WHERE (lt.long_text_id= Outerjoin(oc.long_text_id))
    AND (cnvtupper(lt.long_text)= Outerjoin("*AUDIT SCORE*")) )
   JOIN (bd
   WHERE (bd.person_id= Outerjoin(ce.person_id))
    AND (bd.active_ind= Outerjoin(1))
    AND (bd.end_effective_dt_tm> Outerjoin(sysdate)) )
  ORDER BY e.loc_facility_cd, e.loc_nurse_unit_cd, p.name_last_key,
   e.encntr_id
  HEAD REPORT
   stat = alterlist(pats->list,10)
  HEAD e.encntr_id
   pats->cnt_pt += 1
   IF (mod(pats->cnt_pt,10)=1
    AND (pats->cnt_pt > 1))
    stat = alterlist(pats->list,(pats->cnt_pt+ 9))
   ENDIF
   pats->list[pats->cnt_pt].f_person_id = e.person_id, pats->list[pats->cnt_pt].s_patname = concat(
    trim(p.name_last,3),",",trim(p.name_first,3)), pats->list[pats->cnt_pt].s_age = cnvtage(p
    .birth_dt_tm),
   pats->list[pats->cnt_pt].f_orderid = o.order_id, pats->list[pats->cnt_pt].s_comment = trim(lt
    .long_text,3), pats->list[pats->cnt_pt].s_fin = trim(fin.alias,3),
   pats->list[pats->cnt_pt].s_facility = trim(uar_get_code_display(e.loc_facility_cd),3), pats->list[
   pats->cnt_pt].s_unit_bed = concat(trim(uar_get_code_display(e.loc_nurse_unit_cd),3),";",trim(
     uar_get_code_display(e.loc_room_cd),3)," ",trim(uar_get_code_display(e.loc_bed_cd),3)), pats->
   list[pats->cnt_pt].s_audit_score = trim(ce.result_val,3)
   IF (lt.long_text_id=null)
    pats->list[pats->cnt_pt].s_sw_consult = "No"
   ELSE
    pats->list[pats->cnt_pt].s_sw_consult = "Yes"
   ENDIF
  DETAIL
   IF (trim(bd.description,3)="ethnicity 1")
    pats->list[pats->cnt_pt].s_ethnic = trim(uar_get_code_display(bd.code_value),3)
   ELSEIF (trim(bd.description,3)="ethnicity 2")
    IF (textlen(trim(pats->list[pats->cnt_pt].s_ethnic,3))=0)
     pats->list[pats->cnt_pt].s_ethnic = trim(uar_get_code_display(bd.code_value),3)
    ELSE
     pats->list[pats->cnt_pt].s_ethnic = concat(pats->list[pats->cnt_pt].s_ethnic,", ",trim(
       uar_get_code_display(bd.code_value),3))
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(pats->list,pats->cnt_pt)
  WITH nocounter
 ;end select
 SELECT INTO "nl"
  pl_sort =
  IF (pi.info_sub_type_cd=mf_cs356_race1) 1
  ELSEIF (pi.info_sub_type_cd=mf_cs356_race2) 2
  ELSEIF (pi.info_sub_type_cd=mf_cs356_race3) 3
  ELSEIF (pi.info_sub_type_cd=mf_cs356_race4) 4
  ELSEIF (pi.info_sub_type_cd=mf_cs356_race5) 5
  ENDIF
  FROM (dummyt d1  WITH seq = size(pats->list,5)),
   person_info pi
  PLAN (d1)
   JOIN (pi
   WHERE (pi.person_id=pats->list[d1.seq].f_person_id)
    AND pi.active_ind=1
    AND pi.end_effective_dt_tm > sysdate
    AND pi.info_type_cd=mf_cs355_user_def_cd
    AND pi.info_sub_type_cd IN (mf_cs356_race1, mf_cs356_race2, mf_cs356_race3, mf_cs356_race4,
   mf_cs356_race5))
  ORDER BY d1.seq, pl_sort
  DETAIL
   IF (textlen(trim(pats->list[d1.seq].s_race,3))=0)
    pats->list[d1.seq].s_race = trim(uar_get_code_display(pi.value_cd),3)
   ELSEIF (pi.value_cd > 0.0)
    pats->list[d1.seq].s_race = concat(pats->list[d1.seq].s_race,", ",trim(uar_get_code_display(pi
       .value_cd),3))
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO  $OUTDEV
  patient_name = substring(1,100,pats->list[d1.seq].s_patname), age = substring(1,30,pats->list[d1
   .seq].s_age), ethnicity = substring(1,100,pats->list[d1.seq].s_ethnic),
  race = substring(1,100,pats->list[d1.seq].s_race), account_num = substring(1,30,pats->list[d1.seq].
   s_fin), facility = substring(1,30,pats->list[d1.seq].s_facility),
  unit_bed = substring(1,30,pats->list[d1.seq].s_unit_bed), audit_score = substring(1,30,pats->list[
   d1.seq].s_audit_score), sw_consult_generated = substring(1,200,pats->list[d1.seq].s_sw_consult)
  FROM (dummyt d1  WITH seq = size(pats->list,5))
  PLAN (d1)
  WITH nocounter, separator = " ", format
 ;end select
#exit_script
END GO
