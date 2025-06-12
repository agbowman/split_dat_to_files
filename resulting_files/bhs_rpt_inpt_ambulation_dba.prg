CREATE PROGRAM bhs_rpt_inpt_ambulation:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility" = 673936.00,
  "Nurse Unit" = value(634529558.00),
  "Begin dt/tm" = "SYSDATE",
  "End dt/tm" = "SYSDATE",
  "Recipients" = ""
  WITH outdev, f_facility_cd, f_nurse_unit_cd,
  s_begin_date, s_end_date, s_recipients
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  ) WITH protect
 ENDIF
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
 )
 RECORD m_rec(
   1 pats[*]
     2 f_encntr_id = f8
     2 s_name = vc
     2 s_dob = vc
     2 s_age = vc
     2 s_fin = vc
     2 s_admit_dt_tm = vc
     2 s_admitted_from = vc
     2 s_disch_dt_tm = vc
     2 s_disch_disposition = vc
     2 amb[*]
       3 f_ambulation_dt_tm = f8
       3 s_location = vc
       3 s_bed = vc
       3 s_amb_distance = vc
       3 s_activity_assist = vc
       3 s_amb_devices_needed = vc
       3 s_daily_mob_score = vc
       3 s_amb_charted_by = vc
 ) WITH protect
 DECLARE mf_begin_dt_tm = f8 WITH protect, constant(cnvtdatetime( $S_BEGIN_DATE))
 DECLARE mf_end_dt_tm = f8 WITH protect, constant(cnvtdatetime( $S_END_DATE))
 DECLARE mf_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE mf_observation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION")
  )
 DECLARE mf_emergency_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY"))
 DECLARE mf_disches_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHES"))
 DECLARE mf_dischobv_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHOBV"))
 DECLARE mf_dischip_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHIP"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_authverified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_inprogress_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"IN PROGRESS"))
 DECLARE mf_admit_from_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ADMITFROM"))
 DECLARE mf_daily_mob_score_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DAILYMOBILITYSCORE"))
 DECLARE mf_amb_devices_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "AMBULATORYDEVICESNEEDED"))
 DECLARE mf_amb_distance_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "AMBULATIONDISTANCEFT"))
 DECLARE mf_disch_disp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DISCHARGELEVELOFCAREATDISCHARGE"))
 DECLARE mf_activity_assist_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",72,
   "Activity Assistance"))
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_num = i4 WITH protect, noconstant(0)
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_RECIPIENTS))
 DECLARE ms_error = vc WITH protect, noconstant("")
 DECLARE ms_subject = vc WITH protect, noconstant("")
 DECLARE ms_item_list = vc WITH protect, noconstant("")
 DECLARE ms_nurse_unit_p = vc WITH protect, noconstant("")
 IF (validate(request->batch_selection))
  SET mn_ops = 1
  SET reply->status_data[1].status = "F"
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="BHS_RPT_INPT_AMBULATION"
    AND di.info_char="EMAIL"
   ORDER BY di.info_name
   DETAIL
    IF (textlen(trim(ms_recipients,3)) < 1)
     ms_recipients = trim(di.info_name,3)
    ELSE
     ms_recipients = concat(ms_recipients,",",trim(di.info_name,3))
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (cnvtdatetime(mf_begin_dt_tm) > cnvtdatetime(mf_end_dt_tm))
  SET ms_error = "Start date must be less than end date."
  GO TO exit_script
 ELSEIF (datetimediff(cnvtdatetime(mf_end_dt_tm),cnvtdatetime(mf_begin_dt_tm)) > 92)
  SET ms_error = "Date range exceeds 3 months."
  GO TO exit_script
 ELSEIF (findstring("@",ms_recipients)=0
  AND textlen(ms_recipients) > 0)
  SET ms_error = "Recipient email is invalid."
  GO TO exit_script
 ENDIF
 SET ms_item_list = reflect(parameter(3,0))
 IF (( $F_NURSE_UNIT_CD=999999))
  SET ms_nurse_unit_p = "1=1"
 ELSEIF (substring(1,1,ms_item_list)="L")
  SET ms_nurse_unit_p = "e.loc_nurse_unit_cd in ("
  SET ml_cnt = cnvtint(substring(2,(textlen(ms_item_list) - 1),ms_item_list))
  FOR (i = 1 TO ml_cnt)
    SET ms_nurse_unit_p = concat(ms_nurse_unit_p,cnvtstring(parameter(3,i)),",")
  ENDFOR
  SET ms_nurse_unit_p = concat(substring(1,(textlen(ms_nurse_unit_p) - 1),ms_nurse_unit_p),")")
 ELSE
  SET ms_nurse_unit_p = concat("e.loc_nurse_unit_cd = ",cnvtstring( $F_NURSE_UNIT_CD))
 ENDIF
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   encntr_alias ea
  PLAN (e
   WHERE (e.loc_facility_cd= $F_FACILITY_CD)
    AND parser(ms_nurse_unit_p)
    AND e.reg_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND e.encntr_type_cd IN (mf_inpatient_cd, mf_observation_cd, mf_emergency_cd, mf_dischip_cd,
   mf_dischobv_cd,
   mf_disches_cd)
    AND e.active_ind=1
    AND e.end_effective_dt_tm > sysdate)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_fin_cd
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate)
  ORDER BY p.name_last
  HEAD REPORT
   ml_cnt = 0
  HEAD e.encntr_id
   ml_cnt += 1
   IF (ml_cnt > size(m_rec->pats,5))
    CALL alterlist(m_rec->pats,(ml_cnt+ 100))
   ENDIF
   m_rec->pats[ml_cnt].f_encntr_id = e.encntr_id, m_rec->pats[ml_cnt].s_name = p.name_full_formatted,
   m_rec->pats[ml_cnt].s_dob = format(p.birth_dt_tm,"mm/dd/yyyy;;d"),
   m_rec->pats[ml_cnt].s_age =
   IF (cnvtage(p.birth_dt_tm,e.reg_dt_tm,0)="00:00 Hours") "  0"
   ELSE substring(1,3,cnvtage(p.birth_dt_tm,e.reg_dt_tm,0))
   ENDIF
   , m_rec->pats[ml_cnt].s_admit_dt_tm = format(e.reg_dt_tm,"mm/dd/yyyy;;d"), m_rec->pats[ml_cnt].
   s_disch_dt_tm = format(e.disch_dt_tm,"mm/dd/yyyy;;d"),
   m_rec->pats[ml_cnt].s_fin = ea.alias
  FOOT REPORT
   CALL alterlist(m_rec->pats,ml_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ms_error = "No data found."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE expand(ml_num,1,size(m_rec->pats,5),ce.encntr_id,m_rec->pats[ml_num].f_encntr_id)
    AND ce.event_cd IN (mf_admit_from_cd, mf_disch_disp_cd)
    AND ce.valid_until_dt_tm > sysdate
    AND ce.result_status_cd IN (mf_authverified_cd, mf_modified_cd, mf_inprogress_cd)
    AND ce.view_level=1)
  ORDER BY ce.event_end_dt_tm DESC
  HEAD ce.event_id
   ml_idx = locateval(ml_num,1,size(m_rec->pats,5),ce.encntr_id,m_rec->pats[ml_num].f_encntr_id)
   CASE (ce.event_cd)
    OF mf_admit_from_cd:
     IF (textlen(m_rec->pats[ml_idx].s_admitted_from)=0)
      m_rec->pats[ml_idx].s_admitted_from = ce.event_tag
     ENDIF
    OF mf_disch_disp_cd:
     IF (textlen(m_rec->pats[ml_idx].s_disch_disposition)=0)
      m_rec->pats[ml_idx].s_disch_disposition = ce.event_tag
     ENDIF
   ENDCASE
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce,
   encntr_loc_hist elh,
   prsnl p
  PLAN (ce
   WHERE expand(ml_num,1,size(m_rec->pats,5),ce.encntr_id,m_rec->pats[ml_num].f_encntr_id)
    AND ce.event_cd IN (mf_daily_mob_score_cd, mf_amb_devices_cd, mf_activity_assist_cd,
   mf_amb_distance_cd)
    AND ce.valid_until_dt_tm > sysdate)
   JOIN (elh
   WHERE elh.encntr_id=ce.encntr_id
    AND elh.beg_effective_dt_tm <= ce.event_end_dt_tm
    AND elh.end_effective_dt_tm >= ce.event_end_dt_tm
    AND elh.active_ind=1
    AND elh.end_effective_dt_tm > sysdate)
   JOIN (p
   WHERE p.person_id=ce.performed_prsnl_id)
  ORDER BY ce.encntr_id, ce.event_end_dt_tm, ce.clinsig_updt_dt_tm DESC
  HEAD ce.encntr_id
   ml_cnt = 0, ml_idx = locateval(ml_num,1,size(m_rec->pats,5),ce.encntr_id,m_rec->pats[ml_num].
    f_encntr_id)
  HEAD ce.event_id
   ml_idx2 = locateval(ml_num,1,size(m_rec->pats[ml_idx].amb,5),ce.event_end_dt_tm,m_rec->pats[ml_idx
    ].amb[ml_num].f_ambulation_dt_tm)
   IF (ml_idx2=0)
    ml_cnt += 1, ml_idx2 = ml_cnt,
    CALL alterlist(m_rec->pats[ml_idx].amb,ml_cnt),
    m_rec->pats[ml_idx].amb[ml_idx2].f_ambulation_dt_tm = ce.event_end_dt_tm, m_rec->pats[ml_idx].
    amb[ml_idx2].s_bed = uar_get_code_display(elh.loc_bed_cd), m_rec->pats[ml_idx].amb[ml_idx2].
    s_location = concat(trim(uar_get_code_display(elh.loc_facility_cd),3)," ",trim(
      uar_get_code_display(elh.loc_nurse_unit_cd),3)," ",uar_get_code_display(elh.loc_room_cd))
   ENDIF
   CASE (ce.event_cd)
    OF mf_daily_mob_score_cd:
     IF (textlen(m_rec->pats[ml_idx].amb[ml_idx2].s_daily_mob_score)=0)
      m_rec->pats[ml_idx].amb[ml_idx2].s_daily_mob_score = ce.event_tag
     ENDIF
    OF mf_amb_devices_cd:
     IF (textlen(m_rec->pats[ml_idx].amb[ml_idx2].s_amb_devices_needed)=0)
      m_rec->pats[ml_idx].amb[ml_idx2].s_amb_devices_needed = ce.event_tag
     ENDIF
    OF mf_activity_assist_cd:
     IF (textlen(m_rec->pats[ml_idx].amb[ml_idx2].s_activity_assist)=0)
      m_rec->pats[ml_idx].amb[ml_idx2].s_activity_assist = ce.event_tag
     ENDIF
    OF mf_amb_distance_cd:
     IF (textlen(m_rec->pats[ml_idx].amb[ml_idx2].s_amb_distance)=0)
      m_rec->pats[ml_idx].amb[ml_idx2].s_amb_distance = ce.event_tag, m_rec->pats[ml_idx].amb[ml_idx2
      ].s_amb_charted_by = p.name_full_formatted
     ENDIF
   ENDCASE
  WITH nocounter, expand = 1
 ;end select
 IF (((mn_ops=1) OR (textlen(trim( $S_RECIPIENTS,3)) > 1)) )
  SET frec->file_name = build("bhs_rpt_inpt_ambulation_",trim(format(mf_begin_dt_tm,"mm_dd_yy ;;d"),3
    ),"_to_",trim(format(mf_end_dt_tm,"mm_dd_yy ;;q"),3),".csv")
  SET ms_subject = build2("Inpatient Ambulation Report ",trim(format(mf_begin_dt_tm,
     "mmm-dd-yyyy hh:mm ;;d"),3)," to ",trim(format(mf_end_dt_tm,"mmm-dd-yyyy hh:mm ;;d"),3))
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"PATIENT NAME",','"DATE OF BIRTH",','"AGE",','"ENCOUNTER ACC #",',
   '"ADMISSION DATE",',
   '"ADMITTED FROM",','"UNIT LOCATION",','"BED",','"AMBULATION DT TM",','"AMBULATION DISTANCE (FT)",',
   '"AMBULATION DISTANCE CHARTED BY",','"ACTIVITY ASSISTANCE",','"AMBULATORY DEVICES NEEDED",',
   '"DAILY MOBILITY SCORE",','"DISCHARGE DATE",',
   '"DISCHARGE DISPOSITION",',char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_idx = 1 TO size(m_rec->pats,5))
    IF (size(m_rec->pats[ml_idx].amb,5) > 0)
     FOR (ml_idx2 = 1 TO size(m_rec->pats[ml_idx].amb,5))
      SET frec->file_buf = build('"',trim(m_rec->pats[ml_idx].s_name,3),'","',trim(m_rec->pats[ml_idx
        ].s_dob,3),'","',
       trim(m_rec->pats[ml_idx].s_age,3),'","',trim(m_rec->pats[ml_idx].s_fin,3),'","',trim(m_rec->
        pats[ml_idx].s_admit_dt_tm,3),
       '","',trim(m_rec->pats[ml_idx].s_admitted_from,3),'","',trim(m_rec->pats[ml_idx].amb[ml_idx2].
        s_location,3),'","',
       trim(m_rec->pats[ml_idx].amb[ml_idx2].s_bed,3),'","',trim(format(m_rec->pats[ml_idx].amb[
         ml_idx2].f_ambulation_dt_tm,"mm/dd/yyyy hh:mm;;d"),3),'","',trim(m_rec->pats[ml_idx].amb[
        ml_idx2].s_amb_distance,3),
       '","',trim(m_rec->pats[ml_idx].amb[ml_idx2].s_amb_charted_by,3),'","',trim(m_rec->pats[ml_idx]
        .amb[ml_idx2].s_activity_assist,3),'","',
       trim(m_rec->pats[ml_idx].amb[ml_idx2].s_amb_devices_needed,3),'","',trim(m_rec->pats[ml_idx].
        amb[ml_idx2].s_daily_mob_score,3),'","',trim(m_rec->pats[ml_idx].s_disch_dt_tm,3),
       '","',trim(m_rec->pats[ml_idx].s_disch_disposition,3),'"',char(13))
      SET stat = cclio("WRITE",frec)
     ENDFOR
    ELSE
     SET frec->file_buf = build('"',trim(m_rec->pats[ml_idx].s_name,3),'","',trim(m_rec->pats[ml_idx]
       .s_dob,3),'","',
      trim(m_rec->pats[ml_idx].s_age,3),'","',trim(m_rec->pats[ml_idx].s_fin,3),'","',trim(m_rec->
       pats[ml_idx].s_admit_dt_tm,3),
      '","',trim(m_rec->pats[ml_idx].s_admitted_from,3),'","','","','","',
      '","','","','","','","','","',
      trim(m_rec->pats[ml_idx].s_disch_dt_tm,3),'","',trim(m_rec->pats[ml_idx].s_disch_disposition,3),
      '"',char(13))
     SET stat = cclio("WRITE",frec)
    ENDIF
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  EXECUTE bhs_ma_email_file
  CALL emailfile(value(frec->file_name),frec->file_name,concat('"',ms_recipients,'"'),ms_subject,1)
 ELSE
  SELECT INTO value( $OUTDEV)
   patient_name = substring(1,50,m_rec->pats[d.seq].s_name), date_of_birth = substring(1,50,m_rec->
    pats[d.seq].s_dob), age = substring(1,50,m_rec->pats[d.seq].s_age),
   encounter_acc_# = substring(1,50,m_rec->pats[d.seq].s_fin), admission_date = substring(1,50,m_rec
    ->pats[d.seq].s_admit_dt_tm), admitted_from = substring(1,50,m_rec->pats[d.seq].s_admitted_from),
   unit_location = substring(1,50,m_rec->pats[d.seq].amb[d2.seq].s_location), bed = substring(1,50,
    m_rec->pats[d.seq].amb[d2.seq].s_bed), ambulation_dt_tm = format(m_rec->pats[d.seq].amb[d2.seq].
    f_ambulation_dt_tm,"mm/dd/yyyy hh:mm;;d"),
   ambulation_distance_ft = substring(1,50,m_rec->pats[d.seq].amb[d2.seq].s_amb_distance),
   ambulation_distance_charted_by = substring(1,50,m_rec->pats[d.seq].amb[d2.seq].s_amb_charted_by),
   activity_assistance = substring(1,50,m_rec->pats[d.seq].amb[d2.seq].s_activity_assist),
   ambulatory_devices_needed = substring(1,50,m_rec->pats[d.seq].amb[d2.seq].s_amb_devices_needed),
   daily_mobility_score = substring(1,50,m_rec->pats[d.seq].amb[d2.seq].s_daily_mob_score),
   discharge_date = substring(1,50,m_rec->pats[d.seq].s_disch_dt_tm),
   discharge_disposition = substring(1,50,m_rec->pats[d.seq].s_disch_disposition)
   FROM (dummyt d  WITH seq = value(size(m_rec->pats,5))),
    dummyt d2
   PLAN (d
    WHERE maxrec(d2,size(m_rec->pats[d.seq].amb,5)))
    JOIN (d2)
   ORDER BY patient_name, ambulation_dt_tm
   WITH nocounter, format, separator = " ",
    outerjoin = d
  ;end select
 ENDIF
#exit_script
 IF (mn_ops=1)
  SET reply->status_data[1].status = "S"
 ELSEIF (textlen(trim( $S_RECIPIENTS,3)) > 1
  AND textlen(trim(ms_error,3))=0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = "Report has been sent to:", msg2 = build2("     ", $S_RECIPIENTS),
    CALL print(calcpos(36,18)),
    msg1, row + 2, msg2
   WITH dio = 08
  ;end select
 ELSEIF (textlen(trim(ms_error,3)) != 0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = ms_error, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(26,18)), msg1
   WITH dio = 08
  ;end select
 ENDIF
END GO
