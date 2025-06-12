CREATE PROGRAM bhs_rpt_nicu_picu_vent_data:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "SYSDATE",
  "End Date" = "SYSDATE",
  "Email Operations" = 0,
  "Enter Emails" = ""
  WITH outdev, s_start_date, s_end_date,
  f_email_ops, s_emails
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs72_dragerventilatormode = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "DRAGERVENTILATORMODE")), protect
 DECLARE mf_cs72_ventilatormode = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"VENTILATORMODE")),
 protect
 DECLARE mf_cs72_trachtubeinsertdatetime = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TRACHTUBEINSERTDATETIME")), protect
 DECLARE mf_cs72_datetimeextubated = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "DATETIMEEXTUBATED")), protect
 DECLARE mf_cs72_datereintubated = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"DATEREINTUBATED"
   )), protect
 DECLARE mf_cs72_datetimeintubated = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "DATETIMEINTUBATED")), protect
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
 DECLARE mf_cs200_bipap = f8 WITH protect, constant(uar_get_code_by_cki("CKI.ORD!5091"))
 CALL echo(build2("mf_CS200_BIPAP: ",mf_cs200_bipap))
 DECLARE mf_cs200_vent_assist = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "VENTILATORASSISTCONTROL"))
 DECLARE mf_cs200_vent_cpap = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "VENTILATORCPAP"))
 DECLARE mf_cs200_vent_pres_psv = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "VENTILATORPRESSURECONTROLWITHPSV"))
 DECLARE mf_cs200_vent_pres_ctr = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "VENTILATORPRESSURECONTROL"))
 DECLARE mf_cs200_vent_pres_sup = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "VENTILATORPRESSURESUPPORT"))
 DECLARE mf_cs200_vent_prvc = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "VENTILATORPRVC"))
 DECLARE mf_cs200_vent_simv = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "VENTILATORSIMV"))
 DECLARE mf_cs200_vent_neo = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "VENTILATORNEONATE"))
 DECLARE mf_cs16449_nicu_vent_mode = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "NICUVENTMODE"))
 DECLARE mf_cs69_inpat = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!17006"))
 DECLARE mf_cs69_obs = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!73451"))
 DECLARE mf_cs6004_order = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3102"))
 DECLARE mf_cs220_infch = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cs220_nccn = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cs220_nicu = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cs220_picu = f8 WITH protect, noconstant(0.0)
 DECLARE ms_start_date = vc WITH noconstant( $S_START_DATE), protect
 DECLARE ms_end_date = vc WITH noconstant( $S_END_DATE), protect
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_prev = i4 WITH protect, noconstant(0)
 DECLARE ml_next = i4 WITH protect, noconstant(0)
 DECLARE ml_last = i4 WITH protect, noconstant(0)
 DECLARE ml_start = i4 WITH protect, noconstant(0)
 DECLARE ml_floop = i4 WITH protect, noconstant(0)
 DECLARE ml_ops = i4 WITH protect, noconstant(0)
 DECLARE hispanic_ind = vc WITH protect, noconstant(" ")
 DECLARE ventilator_mode = vc WITH protect, noconstant("              ")
 DECLARE trach_tube_insert_date = vc WITH protect, noconstant("              ")
 DECLARE date_extubated = vc WITH protect, noconstant("              ")
 DECLARE date_reintubated = vc WITH protect, noconstant("              ")
 DECLARE date_intubated = vc WITH protect, noconstant("              ")
 DECLARE location = vc WITH protect, noconstant("              ")
 DECLARE patient_name = vc WITH protect, noconstant("              ")
 DECLARE account_num = vc WITH protect, noconstant("              ")
 DECLARE ms_error = vc WITH protect, noconstant("              ")
 DECLARE ms_subject = vc WITH protect, noconstant("              ")
 DECLARE ms_filename = vc WITH noconstant(concat("bhs_vent_safety_")), protect
 DECLARE ms_output_file = vc WITH noconstant(build(trim(ms_filename,3),format(sysdate,"MMDDYYYY;;q"),
   ".csv")), protect
 IF (( $F_EMAIL_OPS=1))
  SET ms_start_date = format(datetimefind(cnvtlookbehind("1,M",cnvtdatetime(curdate,0)),"M","B","B"),
   "MM/DD/YYYY;;D")
  SET ms_start_date = format(cnvtdatetime(cnvtdate2(ms_start_date,"MM/DD/YYYY"),0),";;Q")
  SET ms_end_date = format(datetimefind(cnvtlookbehind("1,M",cnvtdatetime(curdate,0)),"M","E","E"),
   "MM/DD/YYYY;;D")
  SET ms_end_date = format(cnvtdatetime(cnvtdate2(ms_end_date,"MM/DD/YYYY"),235959),";;Q")
 ENDIF
 CALL echo(build("ms_start_date = ",ms_start_date,"ms_end_date = ",ms_end_date))
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.display_key IN ("PICU", "INFCH", "NICU", "NCCN")
   AND cv.cdf_meaning="NURSEUNIT"
   AND cv.active_ind=1
   AND cv.end_effective_dt_tm > sysdate
  ORDER BY cv.code_value
  HEAD cv.code_value
   IF (cv.display_key="NICU")
    mf_cs220_nicu = cv.code_value
   ELSEIF (cv.display_key="PICU")
    mf_cs220_picu = cv.code_value
   ELSEIF (cv.display_key="INFCH")
    mf_cs220_infch = cv.code_value
   ELSEIF (cv.display_key="NCCN")
    mf_cs220_nccn = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = w8
   1 file_offset = i4
   1 file_dir = i4
 )
 FREE RECORD pedivent
 RECORD pedivent(
   1 l_ecnt = i4
   1 elst[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_fin = vc
     2 s_patient_name = vc
     2 s_location = vc
     2 s_race = vc
     2 s_ethnicity = vc
     2 s_ethnicity_2nd = vc
     2 s_race_2nd = vc
     2 s_hispanic_ind = vc
     2 f_ce_order_id = f8
     2 s_dragerventilatormode = vc
     2 s_ordered_vent_mode = vc
     2 s_ventilatormode = vc
     2 s_trachtubeinsertdatetime = vc
     2 s_datetimeextubated = vc
     2 s_datereintubated = vc
     2 s_datetimeintubated = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM clinical_event ce,
   encounter e,
   encntr_alias fin,
   ce_date_result cdr,
   person p
  PLAN (ce
   WHERE ce.event_cd IN (mf_cs72_dragerventilatormode, mf_cs72_ventilatormode,
   mf_cs72_trachtubeinsertdatetime, mf_cs72_datetimeextubated, mf_cs72_datereintubated,
   mf_cs72_datetimeintubated)
    AND ce.view_level=1
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(ms_start_date) AND cnvtdatetime(ms_end_date)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.result_status_cd IN (mf_cs8_auth_cd, mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_active)
   )
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND e.person_id=ce.person_id
    AND e.loc_nurse_unit_cd IN (mf_cs220_nicu, mf_cs220_picu, mf_cs220_infch, mf_cs220_nccn)
    AND e.active_ind=1
    AND e.active_status_cd=mf_cs48_active
    AND e.encntr_type_class_cd IN (mf_cs69_inpat, mf_cs69_obs)
    AND e.disch_dt_tm=null)
   JOIN (fin
   WHERE fin.encntr_id=e.encntr_id
    AND fin.active_status_cd=mf_cs48_active
    AND fin.encntr_alias_type_cd=mf_cs319_fin_cd
    AND fin.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND fin.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND fin.active_ind=1)
   JOIN (cdr
   WHERE (cdr.event_id= Outerjoin(ce.event_id)) )
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
  ORDER BY ce.person_id, ce.encntr_id, ce.event_cd,
   ce.event_end_dt_tm DESC
  HEAD REPORT
   stat = alterlist(pedivent->elst,10)
  HEAD ce.encntr_id
   pedivent->l_ecnt += 1
   IF (mod(pedivent->l_ecnt,10)=1
    AND (pedivent->l_ecnt > 1))
    stat = alterlist(pedivent->elst,(pedivent->l_ecnt+ 9))
   ENDIF
   pedivent->elst[pedivent->l_ecnt].s_patient_name = trim(p.name_full_formatted,3), pedivent->elst[
   pedivent->l_ecnt].s_fin = trim(fin.alias,3), pedivent->elst[pedivent->l_ecnt].s_location = trim(
    uar_get_code_display(e.loc_nurse_unit_cd),3),
   pedivent->elst[pedivent->l_ecnt].f_encntr_id = ce.encntr_id, pedivent->elst[pedivent->l_ecnt].
   f_person_id = ce.person_id,
   CALL echo(build2("encntrid: ",ce.encntr_id))
  HEAD ce.event_cd
   IF (ce.event_cd=mf_cs72_dragerventilatormode)
    pedivent->elst[pedivent->l_ecnt].s_dragerventilatormode = trim(ce.result_val,3)
   ELSEIF (ce.event_cd=mf_cs72_ventilatormode)
    pedivent->elst[pedivent->l_ecnt].s_ventilatormode = trim(ce.result_val,3)
   ELSEIF (ce.event_cd=mf_cs72_trachtubeinsertdatetime
    AND cdr.result_dt_tm != null)
    pedivent->elst[pedivent->l_ecnt].s_trachtubeinsertdatetime = trim(format(cdr.result_dt_tm,
      "MM/DD/YYYY hh:mm;;D"),3)
   ELSEIF (ce.event_cd=mf_cs72_datetimeextubated
    AND cdr.result_dt_tm != null)
    pedivent->elst[pedivent->l_ecnt].s_datetimeextubated = trim(format(cdr.result_dt_tm,
      "MM/DD/YYYY hh:mm;;D"),3)
   ELSEIF (ce.event_cd=mf_cs72_datereintubated
    AND cdr.result_dt_tm != null)
    pedivent->elst[pedivent->l_ecnt].s_datereintubated = trim(format(cdr.result_dt_tm,
      "MM/DD/YYYY hh:mm;;D"),3)
   ELSEIF (ce.event_cd=mf_cs72_datetimeintubated
    AND cdr.result_dt_tm != null)
    pedivent->elst[pedivent->l_ecnt].s_datetimeintubated = trim(format(cdr.result_dt_tm,
      "MM/DD/YYYY hh:mm;;D"),3)
   ENDIF
  FOOT REPORT
   stat = alterlist(pedivent->elst,pedivent->l_ecnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(pedivent->elst,5))),
   orders o,
   order_detail od
  PLAN (d)
   JOIN (o
   WHERE (o.encntr_id=pedivent->elst[d.seq].f_encntr_id)
    AND o.catalog_cd IN (mf_cs200_vent_assist, mf_cs200_vent_cpap, mf_cs200_vent_pres_psv,
   mf_cs200_vent_pres_ctr, mf_cs200_vent_pres_sup,
   mf_cs200_vent_prvc, mf_cs200_vent_simv, mf_cs200_vent_neo)
    AND o.order_status_cd=mf_cs6004_order)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_id=mf_cs16449_nicu_vent_mode)
  ORDER BY d.seq, o.orig_order_dt_tm DESC
  HEAD d.seq
   pedivent->elst[d.seq].s_ordered_vent_mode = trim(od.oe_field_display_value,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pl_sort =
  IF (pi.info_sub_type_cd=mf_cs356_race1) 1
  ELSEIF (pi.info_sub_type_cd=mf_cs356_race2) 2
  ELSEIF (pi.info_sub_type_cd=mf_cs356_race3) 3
  ELSEIF (pi.info_sub_type_cd=mf_cs356_race4) 4
  ELSEIF (pi.info_sub_type_cd=mf_cs356_race5) 5
  ENDIF
  FROM person_info pi
  PLAN (pi
   WHERE expand(ml_idx,1,size(pedivent->elst,5),pi.person_id,pedivent->elst[ml_idx].f_person_id)
    AND pi.active_ind=1
    AND pi.end_effective_dt_tm > sysdate
    AND pi.info_type_cd=mf_cs355_user_def_cd
    AND pi.info_sub_type_cd IN (mf_cs356_race1, mf_cs356_race2, mf_cs356_race3, mf_cs356_race4,
   mf_cs356_race5))
  ORDER BY pi.person_id, pl_sort
  DETAIL
   ml_start = locatevalsort(ml_idx,1,size(pedivent->elst,5),pi.person_id,pedivent->elst[ml_idx].
    f_person_id), ml_last = ml_start, ml_prev = (ml_start - 1),
   ml_next = (ml_start+ 1)
   IF (ml_next <= size(pedivent->elst,5))
    WHILE (ml_next <= size(pedivent->elst,5)
     AND (pedivent->elst[ml_start].f_person_id=pedivent->elst[ml_next].f_person_id))
     CALL echo(ml_next),ml_next += 1
    ENDWHILE
   ENDIF
   ml_last = (ml_next - 1)
   WHILE ((pedivent->elst[ml_start].f_person_id=pedivent->elst[ml_prev].f_person_id)
    AND ml_prev != 0)
    CALL echo(ml_prev),ml_prev -= 1
   ENDWHILE
   ml_first = (ml_prev+ 1)
   FOR (ml_floop = ml_first TO ml_last)
     IF (textlen(trim(pedivent->elst[ml_floop].s_race,3))=0)
      pedivent->elst[ml_floop].s_race = trim(uar_get_code_display(pi.value_cd),3)
     ELSEIF (pi.value_cd > 0.0)
      pedivent->elst[ml_floop].s_race = concat(pedivent->elst[ml_floop].s_race,", ",trim(
        uar_get_code_display(pi.value_cd),3))
      IF (pi.info_sub_type_cd=mf_cs356_race2)
       pedivent->elst[ml_floop].s_race_2nd = trim(uar_get_code_display(pi.value_cd),3)
      ENDIF
     ENDIF
   ENDFOR
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  pl_sort =
  IF (trim(bd.description,3)="ethnicity 1") 1
  ELSE 2
  ENDIF
  FROM bhs_demographics bd
  PLAN (bd
   WHERE expand(ml_idx,1,size(pedivent->elst,5),bd.person_id,pedivent->elst[ml_idx].f_person_id)
    AND bd.active_ind=1
    AND bd.end_effective_dt_tm > sysdate)
  ORDER BY bd.person_id, pl_sort
  DETAIL
   ml_start = locatevalsort(ml_idx,1,size(pedivent->elst,5),bd.person_id,pedivent->elst[ml_idx].
    f_person_id), ml_last = ml_start, ml_prev = (ml_start - 1),
   ml_next = (ml_start+ 1)
   IF (ml_next <= size(pedivent->elst,5))
    WHILE (ml_next <= size(pedivent->elst,5)
     AND (pedivent->elst[ml_start].f_person_id=pedivent->elst[ml_next].f_person_id))
     CALL echo(ml_next),ml_next += 1
    ENDWHILE
   ENDIF
   ml_last = (ml_next - 1)
   WHILE ((pedivent->elst[ml_start].f_person_id=pedivent->elst[ml_prev].f_person_id)
    AND ml_prev != 0)
    CALL echo(ml_prev),ml_prev -= 1
   ENDWHILE
   ml_first = (ml_prev+ 1)
   FOR (ml_floop = ml_first TO ml_last)
     IF (trim(bd.description,3)="ethnicity 1")
      pedivent->elst[ml_floop].s_ethnicity = trim(uar_get_code_display(bd.code_value),3)
     ELSEIF (trim(bd.description,3)="ethnicity 2")
      IF (textlen(trim(pedivent->elst[ml_floop].s_ethnicity,3))=0)
       pedivent->elst[ml_floop].s_ethnicity = trim(uar_get_code_display(bd.code_value),3), pedivent->
       elst[ml_floop].s_ethnicity_2nd = trim(uar_get_code_display(bd.code_value),3)
      ELSE
       pedivent->elst[ml_floop].s_ethnicity = concat(pedivent->elst[ml_floop].s_ethnicity,", ",trim(
         uar_get_code_display(bd.code_value),3)), pedivent->elst[ml_floop].s_ethnicity_2nd = trim(
        uar_get_code_display(bd.code_value),3)
      ENDIF
     ELSEIF (trim(bd.description,3)="hispanic ind")
      pedivent->elst[ml_floop].s_hispanic_ind = trim(bd.display,3)
     ENDIF
   ENDFOR
  WITH nocounter, expand = 1
 ;end select
 IF (( $F_EMAIL_OPS=0))
  SELECT INTO  $OUTDEV
   patient_name = substring(1,100,pedivent->elst[d1.seq].s_patient_name), account_number = substring(
    1,30,pedivent->elst[d1.seq].s_fin), unit = substring(1,10,pedivent->elst[d1.seq].s_location),
   date_intubated = substring(1,20,pedivent->elst[d1.seq].s_datetimeintubated), date_reintubated =
   substring(1,20,pedivent->elst[d1.seq].s_datereintubated), date_extubated = substring(1,20,pedivent
    ->elst[d1.seq].s_datetimeextubated),
   trach_tube_insert_date = substring(1,20,pedivent->elst[d1.seq].s_trachtubeinsertdatetime),
   ordered_vent_mode = substring(1,20,pedivent->elst[d1.seq].s_ordered_vent_mode), ventilator_mode =
   substring(1,50,pedivent->elst[d1.seq].s_ventilatormode),
   drager_ventilator_mode = substring(1,50,pedivent->elst[d1.seq].s_dragerventilatormode), race =
   substring(1,30,pedivent->elst[d1.seq].s_race), secondary_race = substring(1,30,pedivent->elst[d1
    .seq].s_race_2nd),
   ethnicity = substring(1,30,pedivent->elst[d1.seq].s_ethnicity), secondary_ethnicity = substring(1,
    30,pedivent->elst[d1.seq].s_ethnicity_2nd), hispanic_ind = substring(1,30,pedivent->elst[d1.seq].
    s_hispanic_ind)
   FROM (dummyt d1  WITH seq = size(pedivent->elst,5))
   PLAN (d1)
   ORDER BY unit
   WITH nocounter, separator = " ", format
  ;end select
 ELSEIF (( $F_EMAIL_OPS=1))
  SET frec->file_name = ms_output_file
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"PATIENT NAME",','"ACCOUNT NUMBER",','"Unit",','"Date Intubated ",',
   '"Fate Reintubated",',
   '"Trach Tube Insert Date",','"Ventilator Mode",','"Drager Ventilator Mode",','"Race",',
   '"Secondary Race",',
   '"Ethnicity",','"Secondary Ethnicity",','"Hispanic Indicator",',char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_cnt = 1 TO size(pedivent->elst,5))
   SET frec->file_buf = build('"',trim(pedivent->elst[ml_cnt].s_patient_name,3),'","',trim(pedivent->
     elst[ml_cnt].s_fin,3),'","',
    trim(pedivent->elst[ml_cnt].s_location,3),'","',trim(pedivent->elst[ml_cnt].s_datetimeintubated,3
     ),'","',trim(pedivent->elst[ml_cnt].s_datereintubated,3),
    '","',trim(pedivent->elst[ml_cnt].s_trachtubeinsertdatetime,3),'","',trim(pedivent->elst[ml_cnt].
     s_ventilatormode,3),'","',
    trim(pedivent->elst[ml_cnt].s_dragerventilatormode,3),'","',trim(pedivent->elst[ml_cnt].s_race,3),
    '","',trim(pedivent->elst[ml_cnt].s_race_2nd,3),
    '","',trim(pedivent->elst[ml_cnt].s_ethnicity,3),'","',trim(pedivent->elst[ml_cnt].
     s_ethnicity_2nd,3),'","',
    trim(pedivent->elst[ml_cnt].s_hispanic_ind,3),'"',char(13))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  EXECUTE bhs_ma_email_file
  SET ms_subject = build2("PICU NICU Vent Safety Report ",trim(format(cnvtdatetime(ms_start_date),
     "mmm-dd-yyyy hh:mm ;;d"),3)," to ",trim(format(cnvtdatetime(ms_end_date),"mmm-dd-yyyy hh:mm;;d"),
    3))
  CALL emailfile(frec->file_name,frec->file_name, $S_EMAILS,ms_subject,1)
 ENDIF
END GO
