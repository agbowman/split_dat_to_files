CREATE PROGRAM bhs_rpt_orders_day_of_disch:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Facility" = 0,
  "Unit" = value(0.0),
  "Enter Emails" = "",
  "Start Discharge date" = "SYSDATE",
  "End Discharge Date" = "SYSDATE"
  WITH outdev, f_fname, f_unit,
  s_emails, s_start_date, s_end_date
 DECLARE mf_cs333_attendingphysician = f8 WITH constant(uar_get_code_by("DISPLAYKEY",333,
   "ATTENDINGPHYSICIAN")), protect
 DECLARE mf_cs69_observation = f8 WITH constant(uar_get_code_by("MEANING",69,"OBSERVATION")), protect
 DECLARE mf_cs69_inpatient = f8 WITH constant(uar_get_code_by("DISPLAYKEY",69,"INPATIENT")), protect
 DECLARE mf_cs6000_laboratory = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,"LABORATORY")),
 protect
 DECLARE mf_cs6004_ordered = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED")), protect
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
 DECLARE ms_opr_var1 = vc WITH protect
 DECLARE ms_lcheck = vc WITH protect
 DECLARE ml_gcnt = i4 WITH noconstant(0), protect
 DECLARE ms_sender = vc WITH protect
 DECLARE ms_msgcls = vc WITH protect
 DECLARE ms_sendto = vc WITH protect
 DECLARE ms_subject = vc WITH protect
 DECLARE ml_msgpriority = i4 WITH protect
 RECORD restraints(
   1 l_cnt_ord = i4
   1 pats[*]
     2 s_patname = vc
     2 s_facility = vc
     2 s_unit = vc
     2 s_mrn = vc
     2 s_fin = vc
     2 s_order_name = vc
     2 s_type = vc
     2 s_reason = vc
     2 s_mode = vc
     2 s_status = vc
     2 f_order_id = f8
     2 s_order_dt = vc
 )
 FREE RECORD grec
 RECORD grec(
   1 list[*]
     2 f_cv = f8
     2 s_disp = c15
 )
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = w8
   1 file_offset = i4
   1 file_dir = i4
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
      SET stat = alterlist(grec->list,(ml_gcnt+ 4))
     ENDIF
     SET grec->list[ml_gcnt].f_cv = cnvtint(parameter(parameter2( $F_UNIT),ml_gcnt))
     SET grec->list[ml_gcnt].s_disp = uar_get_code_display(parameter(parameter2( $F_UNIT),ml_gcnt))
    ENDIF
  ENDWHILE
  SET ml_gcnt -= 1
  SET stat = alterlist(grec->list,ml_gcnt)
 ELSE
  SET stat = alterlist(grec->list,1)
  SET ml_gcnt = 1
  SET grec->list[1].f_cv =  $F_UNIT
  IF ((grec->list[1].f_cv=0.0))
   SET grec->list[1].s_disp = "All Units"
   SET ms_opr_var1 = "!="
  ELSE
   SET grec->list[1].s_disp = uar_get_code_display(grec->list[1].f_cv)
   SET ms_opr_var1 = "="
  ENDIF
 ENDIF
 SELECT INTO  $OUTDEV
  facility = uar_get_code_display(e.loc_facility_cd), fin = trim(fin.alias,3), mrn = trim(mrn.alias,3
   ),
  encounter_type = uar_get_code_display(e.encntr_type_cd), discharge_date = e.disch_dt_tm, order_date
   = o.orig_order_dt_tm,
  order_name = uar_get_code_display(o.catalog_cd), order_type = uar_get_code_display(o
   .catalog_type_cd), order_status = uar_get_code_display(o.order_status_cd),
  attending_physician = substring(1,100,pr.name_full_formatted)
  FROM encounter e,
   orders o,
   dummyt d1,
   encntr_alias mrn,
   encntr_alias fin,
   encounter e,
   person p,
   encntr_prsnl_reltn epr,
   prsnl pr
  PLAN (e
   WHERE e.disch_dt_tm BETWEEN cnvtdatetime( $S_START_DATE) AND cnvtdatetime( $S_END_DATE)
    AND e.encntr_type_class_cd IN (mf_cs69_observation, mf_cs69_inpatient)
    AND (e.loc_facility_cd= $F_FNAME)
    AND operator(e.loc_nurse_unit_cd,ms_opr_var1, $F_UNIT))
   JOIN (epr
   WHERE (epr.beg_effective_dt_tm<= Outerjoin(sysdate))
    AND (epr.end_effective_dt_tm>= Outerjoin(sysdate))
    AND (epr.encntr_id= Outerjoin(e.encntr_id))
    AND (epr.active_ind= Outerjoin(1))
    AND (epr.encntr_prsnl_r_cd= Outerjoin(mf_cs333_attendingphysician)) )
   JOIN (pr
   WHERE (pr.person_id= Outerjoin(epr.prsnl_person_id))
    AND (pr.active_ind= Outerjoin(1)) )
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
   JOIN (o
   WHERE o.encntr_id=e.encntr_id
    AND o.person_id=e.person_id
    AND o.template_order_flag IN (1, 0)
    AND o.catalog_type_cd=mf_cs6000_laboratory)
   JOIN (d1
   WHERE o.orig_order_dt_tm BETWEEN datetimefind(e.disch_dt_tm,"D","B","B") AND datetimefind(e
    .disch_dt_tm,"D","E","E"))
  ORDER BY e.encntr_id, o.orig_order_dt_tm
  WITH nocounter, format, separator = " ",
   format(date,";;Q")
 ;end select
END GO
