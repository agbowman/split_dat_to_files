CREATE PROGRAM bhs_mp_hospitalist_tracker:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "",
  "End Date" = "",
  "Group" = "ALL",
  "Report Type" = 1,
  "Email Recipients (Only for detailed report,  separate emails with a comma)" = ""
  WITH outdev, s_start_date, s_end_date,
  s_group_type, n_report_type, s_recipients
 FREE RECORD log_data
 RECORD log_data(
   1 patients[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_loc = vc
     2 s_ap_resident = vc
     2 f_update_time = f8
     2 f_arrival_time = f8
     2 s_pending_arrival = vc
     2 f_attending_preceptor_id = f8
 ) WITH protect
 FREE RECORD credit
 RECORD credit(
   1 patients[*]
     2 f_preceptor_id = f8
     2 f_person_id = f8
     2 n_precept_ind = i2
     2 n_resident_ind = i2
     2 s_resident = vc
 ) WITH protect
 FREE RECORD pending
 RECORD pending(
   1 patients[*]
     2 f_person_id = f8
     2 f_arrival_time = f8
     2 n_arrival_ind = i2
 ) WITH protect
 FREE RECORD data
 RECORD data(
   1 l_patient_total = i4
   1 l_claimed_total = i4
   1 l_unclaimed_total = i4
   1 l_total_consults = i4
   1 l_total_inpatients = i4
   1 l_total_observation = i4
   1 l_total_inter = i4
   1 l_total_unspecified = i4
   1 l_total_attending_preceptors = i4
   1 l_total_ap_residents = i4
   1 l_total_prsnl = i4
   1 claimed_patients[*]
     2 f_patient_id = f8
   1 temp_unclaimed[*]
     2 s_patient_name = vc
     2 f_patient_id = f8
     2 f_encntr_id = f8
     2 s_loc = vc
     2 f_patient_dob = f8
     2 f_arrival_time = f8
     2 s_patient_location = vc
     2 s_mrn = vc
   1 unclaimed_patients[*]
     2 s_patient_name = vc
     2 f_patient_id = f8
     2 f_encntr_id = f8
     2 s_loc = vc
     2 f_patient_dob = f8
     2 f_arrival_time = f8
     2 s_patient_location = vc
     2 s_mrn = vc
   1 ap_resident[*]
     2 s_prsnl_name = vc
   1 personnel[*]
     2 s_prsnl_type = vc
     2 s_prsnl_name = vc
     2 f_prsnl_id = f8
     2 l_pat_cnt = i4
     2 s_pat_cnt = vc
     2 patients[*]
       3 s_patient_name = vc
       3 f_claim_time = f8
       3 f_arrival_time = f8
       3 l_wait_time = i4
       3 f_patient_id = f8
       3 f_encntr_id = f8
       3 s_loc = vc
       3 f_patient_dob = f8
       3 s_patient_location = vc
       3 s_mrn = vc
 ) WITH protect
 FREE RECORD display
 RECORD display(
   1 info[*]
     2 s_prsnl_type = vc
     2 s_prsnl_name = vc
     2 l_pat_cnt = i4
     2 f_patient_id = f8
     2 s_patient_name = vc
     2 f_claim_time = f8
     2 f_encntr_id = f8
     2 s_patient_mrn = vc
     2 f_patient_dob = f8
     2 f_arrival_time = f8
     2 s_patient_location = vc
     2 s_loc = vc
     2 l_wait_time = i4
 ) WITH protect
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  ) WITH protect
 ENDIF
 EXECUTE bhs_check_domain:dba
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt2 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx3 = i4 WITH protect, noconstant(0)
 DECLARE ml_cred_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_patrecsize = i4 WITH protect, noconstant(0)
 DECLARE ml_unclaimed_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_pat_cnt = i4 WITH protect, noconstant(0)
 DECLARE mf_start = f8 WITH protect, noconstant(cnvtdatetime( $S_START_DATE))
 DECLARE mf_end = f8 WITH protect, noconstant(cnvtdatetime( $S_END_DATE))
 DECLARE ms_error = vc WITH protect, noconstant(" ")
 DECLARE ms_temp = vc WITH protect, noconstant(" ")
 DECLARE ms_group_key = vc WITH protect, noconstant(" ")
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_RECIPIENTS))
 DECLARE ms_recipients2 = vc WITH protect, noconstant(" ")
 DECLARE ms_recipients3 = vc WITH protect, noconstant(" ")
 DECLARE ms_recipients4 = vc WITH protect, noconstant(" ")
 DECLARE ms_file_name = vc WITH protect, noconstant(" ")
 DECLARE ms_subject = vc WITH protect, noconstant(" ")
 IF (validate(request->batch_selection))
  SET mn_ops = 1
  SET reply->status_data[1].status = "F"
  SET mf_start = cnvtdatetime((curdate - 1),070000)
  SET mf_end = cnvtdatetime(curdate,070000)
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="BHS_MP_HOSPITALIST_TRACKER*"
    AND di.info_char=trim( $S_GROUP_TYPE,3)
   ORDER BY di.info_name
   DETAIL
    IF (textlen(trim(ms_recipients,3)) < 325)
     IF (textlen(trim(ms_recipients,3)) < 1)
      ms_recipients = trim(di.info_name,3)
     ELSE
      ms_recipients = concat(ms_recipients,",",trim(di.info_name,3))
     ENDIF
    ELSEIF (textlen(trim(ms_recipients2,3)) < 325)
     IF (textlen(trim(ms_recipients2,3)) < 1)
      ms_recipients2 = trim(di.info_name,3)
     ELSE
      ms_recipients2 = concat(ms_recipients2,",",trim(di.info_name,3))
     ENDIF
    ELSEIF (textlen(trim(ms_recipients3,3)) < 325)
     IF (textlen(trim(ms_recipients3,3)) < 1)
      ms_recipients3 = trim(di.info_name,3)
     ELSE
      ms_recipients3 = concat(ms_recipients3,",",trim(di.info_name,3))
     ENDIF
    ELSE
     IF (textlen(trim(ms_recipients4,3)) < 1)
      ms_recipients4 = trim(di.info_name,3)
     ELSE
      ms_recipients4 = concat(ms_recipients4,",",trim(di.info_name,3))
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (mf_start > mf_end)
  SET ms_error = "Start Date must be less than End Date."
  GO TO exit_program
 ELSEIF (datetimediff(cnvtdatetime(curdate,curtime),mf_start) >= 90)
  SET ms_error = "Start date exceeds 90 days"
  GO TO exit_program
 ELSEIF (findstring("@",ms_recipients)=0
  AND textlen(ms_recipients) > 0)
  SET ms_error = "Recipient email is invalid"
  GO TO exit_program
 ENDIF
 IF (( $S_GROUP_TYPE="ALL"))
  SET ms_group_key = "1=1"
 ELSE
  SET ms_group_key = concat('bd.description = "',trim( $S_GROUP_TYPE,3),'"')
 ENDIF
 SELECT INTO "nl:"
  FROM bhs_log b,
   bhs_log_detail bd,
   bhs_log_detail bd2
  PLAN (b
   WHERE b.object_name IN ("BHS_MP_HOSPITALIST", "BHS_MP_HOSPITALIST_V2")
    AND b.updt_dt_tm BETWEEN cnvtdatetime(mf_start) AND cnvtdatetime(mf_end)
    AND b.msg="P627")
   JOIN (bd
   WHERE bd.bhs_log_id=b.bhs_log_id
    AND bd.parent_entity_name="prsnl_id"
    AND parser(ms_group_key))
   JOIN (bd2
   WHERE bd2.bhs_log_id=bd.bhs_log_id
    AND bd2.detail_group=bd.detail_group
    AND bd2.parent_entity_name="person_id")
  ORDER BY bd2.parent_entity_id, bd.updt_dt_tm DESC
  HEAD REPORT
   ml_cnt = 0
  HEAD bd2.parent_entity_id
   ml_cnt += 1
   IF (ml_cnt > size(credit->patients,5))
    CALL alterlist(credit->patients,(ml_cnt+ 9))
   ENDIF
   credit->patients[ml_cnt].f_person_id = bd2.parent_entity_id
   IF (bd.parent_entity_id != 0.00)
    credit->patients[ml_cnt].f_preceptor_id = bd.parent_entity_id
   ENDIF
   IF (textlen(trim(bd.msg,3)) != 0)
    credit->patients[ml_cnt].s_resident = trim(bd.msg,3)
   ENDIF
  FOOT REPORT
   CALL alterlist(credit->patients,ml_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM bhs_log b,
   bhs_log_detail bd
  PLAN (b
   WHERE b.object_name IN ("BHS_MP_HOSPITALIST", "BHS_MP_HOSPITALIST_V2")
    AND b.updt_dt_tm BETWEEN datetimeadd(cnvtdatetime(mf_start),- ((1080/ 1440))) AND cnvtdatetime(
    mf_end)
    AND b.msg="P627")
   JOIN (bd
   WHERE bd.bhs_log_id=b.bhs_log_id
    AND parser(ms_group_key))
  ORDER BY bd.bhs_log_id, bd.detail_group, bd.detail_seq
  HEAD REPORT
   ml_idx = 1, ml_cnt = 0
  DETAIL
   IF (ml_idx > size(log_data->patients,5))
    CALL alterlist(log_data->patients,(ml_idx+ 9))
   ENDIF
   IF (bd.parent_entity_name="person_id")
    log_data->patients[ml_idx].f_person_id = bd.parent_entity_id, ml_idx2 = locateval(ml_cnt,1,size(
      pending->patients,5),bd.parent_entity_id,pending->patients[ml_cnt].f_person_id)
    IF (trim(bd.msg,3)="1"
     AND ml_idx2=0)
     CALL alterlist(pending->patients,(size(pending->patients,5)+ 1)), pending->patients[size(pending
      ->patients,5)].f_person_id = bd.parent_entity_id
    ELSEIF (trim(bd.msg,3)="0"
     AND ml_idx2 > 0
     AND (pending->patients[ml_idx2].n_arrival_ind != 1))
     pending->patients[ml_idx2].n_arrival_ind = 1, pending->patients[ml_idx2].f_arrival_time = bd
     .updt_dt_tm
    ENDIF
   ELSEIF (bd.parent_entity_name="encntr_id")
    log_data->patients[ml_idx].f_encntr_id = bd.parent_entity_id, log_data->patients[ml_idx].s_loc =
    bd.msg
   ELSEIF (bd.parent_entity_name="prsnl_id")
    log_data->patients[ml_idx].f_attending_preceptor_id = bd.parent_entity_id, log_data->patients[
    ml_idx].s_ap_resident = bd.msg
   ELSEIF (bd.parent_entity_name="arrival_date")
    log_data->patients[ml_idx].f_arrival_time = bd.parent_entity_id, log_data->patients[ml_idx].
    f_update_time = bd.updt_dt_tm, ml_idx += 1
   ENDIF
  FOOT REPORT
   stat = alterlist(log_data->patients,(ml_idx - 1))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  update_tm = log_data->patients[d.seq].f_update_time
  FROM (dummyt d  WITH seq = value(size(log_data->patients,5))),
   prsnl p,
   person pp,
   encounter e,
   encntr_alias ea
  PLAN (d)
   JOIN (p
   WHERE (p.person_id= Outerjoin(log_data->patients[d.seq].f_attending_preceptor_id)) )
   JOIN (pp
   WHERE (pp.person_id= Outerjoin(log_data->patients[d.seq].f_person_id)) )
   JOIN (e
   WHERE (e.encntr_id= Outerjoin(log_data->patients[d.seq].f_encntr_id))
    AND (e.active_ind= Outerjoin(1))
    AND (e.end_effective_dt_tm> Outerjoin(sysdate)) )
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(e.encntr_id))
    AND (ea.active_ind= Outerjoin(1))
    AND (ea.end_effective_dt_tm> Outerjoin(sysdate))
    AND (ea.encntr_alias_type_cd= Outerjoin(mf_mrn_cd)) )
  ORDER BY d.seq
  HEAD REPORT
   ml_idx = 0, ml_idx2 = 0, ml_idx3 = 0,
   ml_cnt = 0, ml_cred_idx = 0, ml_patrecsize = 0,
   ml_unclaimed_cnt = 0, ml_pat_cnt = size(credit->patients,5)
  DETAIL
   ml_cred_idx = locateval(ml_cnt,1,size(credit->patients,5),log_data->patients[d.seq].f_person_id,
    credit->patients[ml_cnt].f_person_id)
   IF (ml_cred_idx=0)
    ml_pat_cnt += 1
    IF (size(credit->patients,5) < ml_pat_cnt)
     CALL alterlist(credit->patients,(ml_pat_cnt+ 10))
    ENDIF
    credit->patients[ml_pat_cnt].f_person_id = pp.person_id
    IF ((log_data->patients[d.seq].f_attending_preceptor_id != 0.00)
     AND cnvtdatetime(update_tm) < cnvtdatetime(mf_start))
     credit->patients[ml_pat_cnt].n_precept_ind = 1
    ENDIF
    IF (textlen(trim(log_data->patients[d.seq].s_ap_resident,3)) != 0
     AND cnvtdatetime(update_tm) < cnvtdatetime(mf_start))
     credit->patients[ml_pat_cnt].n_resident_ind = 1
    ENDIF
   ELSEIF (ml_cred_idx > 0)
    IF ((log_data->patients[d.seq].f_attending_preceptor_id != 0.00)
     AND cnvtdatetime(update_tm) < cnvtdatetime(mf_start))
     credit->patients[ml_cred_idx].n_precept_ind = 1
    ENDIF
    IF (textlen(trim(log_data->patients[d.seq].s_ap_resident,3)) != 0
     AND cnvtdatetime(update_tm) < cnvtdatetime(mf_start))
     credit->patients[ml_cred_idx].n_resident_ind = 1
    ENDIF
   ENDIF
   IF (cnvtdatetime(update_tm) >= cnvtdatetime(mf_start))
    ml_idx = locateval(ml_cnt,1,size(data->claimed_patients,5),log_data->patients[d.seq].f_person_id,
     data->claimed_patients[ml_cnt].f_patient_id)
    IF (ml_idx=0
     AND (((log_data->patients[d.seq].f_attending_preceptor_id != 0.00)) OR (textlen(trim(log_data->
      patients[d.seq].s_ap_resident,3)) != 0)) )
     CALL alterlist(data->claimed_patients,(size(data->claimed_patients,5)+ 1)), data->
     claimed_patients[size(data->claimed_patients,5)].f_patient_id = pp.person_id
     IF ((log_data->patients[d.seq].s_loc="Consult*"))
      data->l_total_consults += 1
     ELSEIF ((log_data->patients[d.seq].s_loc="Inp*"))
      data->l_total_inpatients += 1
     ELSEIF ((log_data->patients[d.seq].s_loc="Obs*"))
      data->l_total_observation += 1
     ELSEIF ((log_data->patients[d.seq].s_loc="Inter*"))
      data->l_total_inter += 1
     ELSE
      data->l_total_unspecified += 1
     ENDIF
    ENDIF
    IF (ml_idx=0
     AND (log_data->patients[d.seq].f_attending_preceptor_id=0.00)
     AND textlen(trim(log_data->patients[d.seq].s_ap_resident,3))=0)
     ml_idx2 = locateval(ml_cnt,1,size(data->temp_unclaimed,5),pp.person_id,data->temp_unclaimed[
      ml_cnt].f_patient_id)
     IF (ml_idx2=0)
      CALL alterlist(data->temp_unclaimed,(size(data->temp_unclaimed,5)+ 1)), data->temp_unclaimed[
      size(data->temp_unclaimed,5)].f_patient_id = pp.person_id, data->temp_unclaimed[size(data->
       temp_unclaimed,5)].f_encntr_id = e.encntr_id,
      data->temp_unclaimed[size(data->temp_unclaimed,5)].s_patient_name = pp.name_full_formatted,
      data->temp_unclaimed[size(data->temp_unclaimed,5)].s_loc = log_data->patients[d.seq].s_loc
      IF ((log_data->patients[d.seq].s_loc=" "))
       data->temp_unclaimed[size(data->temp_unclaimed,5)].s_loc = "Unspecified"
      ENDIF
      data->temp_unclaimed[size(data->temp_unclaimed,5)].f_patient_dob = pp.birth_dt_tm, data->
      temp_unclaimed[size(data->temp_unclaimed,5)].f_arrival_time = log_data->patients[d.seq].
      f_arrival_time, data->temp_unclaimed[size(data->temp_unclaimed,5)].s_mrn = trim(ea.alias),
      data->temp_unclaimed[size(data->temp_unclaimed,5)].s_patient_location = build(
       uar_get_code_display(e.loc_facility_cd),"/",uar_get_code_display(e.loc_nurse_unit_cd),"/",
       uar_get_code_display(e.loc_room_cd),
       "/",uar_get_code_display(e.loc_bed_cd))
     ENDIF
    ENDIF
    ml_idx = locateval(ml_cnt,1,size(data->personnel,5),log_data->patients[d.seq].
     f_attending_preceptor_id,data->personnel[ml_cnt].f_prsnl_id)
    IF (ml_idx=0
     AND (log_data->patients[d.seq].f_attending_preceptor_id != 0.00))
     CALL alterlist(data->personnel,(size(data->personnel,5)+ 1)), data->personnel[size(data->
      personnel,5)].s_prsnl_type = "Attending Preceptor", data->personnel[size(data->personnel,5)].
     f_prsnl_id = p.person_id,
     data->personnel[size(data->personnel,5)].s_prsnl_name = p.name_full_formatted, data->
     l_total_attending_preceptors += 1
    ENDIF
    ml_cred_idx = locateval(ml_cnt,1,size(credit->patients,5),pp.person_id,credit->patients[ml_cnt].
     f_person_id)
    IF (ml_cred_idx > 0
     AND (credit->patients[ml_cred_idx].n_precept_ind != 1)
     AND (credit->patients[ml_cred_idx].f_preceptor_id=log_data->patients[d.seq].
    f_attending_preceptor_id))
     ml_idx = locateval(ml_cnt,1,size(data->personnel,5),log_data->patients[d.seq].
      f_attending_preceptor_id,data->personnel[ml_cnt].f_prsnl_id), ml_idx2 = locateval(ml_cnt,1,size
      (data->personnel[ml_idx].patients,5),pp.person_id,data->personnel[ml_idx].patients[ml_cnt].
      f_patient_id)
     IF (ml_idx2=0
      AND (log_data->patients[d.seq].f_attending_preceptor_id != 0.00))
      CALL alterlist(data->personnel[ml_idx].patients,(size(data->personnel[ml_idx].patients,5)+ 1)),
      ml_patrecsize = size(data->personnel[ml_idx].patients,5), data->personnel[ml_idx].patients[
      ml_patrecsize].f_patient_id = pp.person_id,
      data->personnel[ml_idx].patients[ml_patrecsize].s_patient_name = pp.name_full_formatted, data->
      personnel[ml_idx].patients[ml_patrecsize].f_encntr_id = e.encntr_id, data->personnel[ml_idx].
      patients[ml_patrecsize].f_claim_time = log_data->patients[d.seq].f_update_time,
      ml_idx3 = locateval(ml_cnt,1,size(pending->patients,5),pp.person_id,pending->patients[ml_cnt].
       f_person_id)
      IF (ml_idx3 > 0)
       data->personnel[ml_idx].patients[ml_patrecsize].f_arrival_time = pending->patients[ml_idx3].
       f_arrival_time
      ELSE
       data->personnel[ml_idx].patients[ml_patrecsize].f_arrival_time = log_data->patients[d.seq].
       f_arrival_time
      ENDIF
      data->personnel[ml_idx].patients[ml_patrecsize].l_wait_time = datetimediff(log_data->patients[d
       .seq].f_update_time,data->personnel[ml_idx].patients[ml_patrecsize].f_arrival_time,4), data->
      personnel[ml_idx].patients[ml_patrecsize].s_loc = log_data->patients[d.seq].s_loc
      IF ((log_data->patients[d.seq].s_loc=" "))
       data->personnel[ml_idx].patients[ml_patrecsize].s_loc = "Unspecified"
      ENDIF
      data->personnel[ml_idx].patients[ml_patrecsize].f_patient_dob = pp.birth_dt_tm, data->
      personnel[ml_idx].patients[ml_patrecsize].s_mrn = trim(ea.alias), data->personnel[ml_idx].
      patients[ml_patrecsize].s_patient_location = build(uar_get_code_display(e.loc_facility_cd),"/",
       uar_get_code_display(e.loc_nurse_unit_cd),"/",uar_get_code_display(e.loc_room_cd),
       "/",uar_get_code_display(e.loc_bed_cd)),
      data->personnel[ml_idx].l_pat_cnt += 1, data->personnel[ml_idx].s_pat_cnt = cnvtstring(data->
       personnel[ml_idx].l_pat_cnt), credit->patients[ml_cred_idx].n_precept_ind = 1
     ENDIF
    ENDIF
    ml_idx = locateval(ml_cnt,1,size(data->ap_resident,5),log_data->patients[d.seq].s_ap_resident,
     data->ap_resident[ml_cnt].s_prsnl_name)
    IF (ml_idx=0
     AND textlen(trim(log_data->patients[d.seq].s_ap_resident,3)) != 0)
     CALL alterlist(data->ap_resident,(size(data->ap_resident,5)+ 1)), data->ap_resident[size(data->
      ap_resident,5)].s_prsnl_name = log_data->patients[d.seq].s_ap_resident,
     CALL alterlist(data->personnel,(size(data->personnel,5)+ 1)),
     data->personnel[size(data->personnel,5)].s_prsnl_name = log_data->patients[d.seq].s_ap_resident,
     data->personnel[size(data->personnel,5)].s_prsnl_type = "AP/Resident", data->
     l_total_ap_residents += 1
    ENDIF
    IF (ml_cred_idx > 0
     AND (credit->patients[ml_cred_idx].n_resident_ind != 1)
     AND trim(credit->patients[ml_cred_idx].s_resident,3)=trim(log_data->patients[d.seq].
     s_ap_resident,3))
     FOR (i = 1 TO size(data->personnel,5))
       IF ((data->personnel[i].s_prsnl_name=log_data->patients[d.seq].s_ap_resident)
        AND (data->personnel[i].s_prsnl_type="AP/Resident"))
        ml_idx = locateval(ml_cnt,1,size(data->personnel[i].patients,5),log_data->patients[d.seq].
         f_person_id,data->personnel[i].patients[ml_cnt].f_patient_id)
        IF (ml_idx=0
         AND textlen(trim(log_data->patients[d.seq].s_ap_resident,3)) != 0)
         CALL alterlist(data->personnel[i].patients,(size(data->personnel[i].patients,5)+ 1)), data->
         personnel[i].patients[size(data->personnel[i].patients,5)].f_patient_id = pp.person_id, data
         ->personnel[i].patients[size(data->personnel[i].patients,5)].f_encntr_id = e.encntr_id,
         data->personnel[i].patients[size(data->personnel[i].patients,5)].s_patient_name = pp
         .name_full_formatted, data->personnel[i].patients[size(data->personnel[i].patients,5)].
         f_claim_time = log_data->patients[d.seq].f_update_time, ml_idx3 = locateval(ml_cnt,1,size(
           pending->patients,5),pp.person_id,pending->patients[ml_cnt].f_person_id)
         IF (ml_idx3 > 0)
          data->personnel[i].patients[size(data->personnel[i].patients,5)].f_arrival_time = pending->
          patients[ml_idx3].f_arrival_time
         ELSE
          data->personnel[i].patients[size(data->personnel[i].patients,5)].f_arrival_time = log_data
          ->patients[d.seq].f_arrival_time
         ENDIF
         data->personnel[i].patients[size(data->personnel[i].patients,5)].l_wait_time = datetimediff(
          log_data->patients[d.seq].f_update_time,data->personnel[i].patients[size(data->personnel[i]
           .patients,5)].f_arrival_time,4), data->personnel[i].patients[size(data->personnel[i].
          patients,5)].s_loc = log_data->patients[d.seq].s_loc
         IF (textlen(trim(log_data->patients[d.seq].s_loc,3))=0)
          data->personnel[i].patients[size(data->personnel[i].patients,5)].s_loc = "Unspecified"
         ENDIF
         data->personnel[i].patients[size(data->personnel[i].patients,5)].f_patient_dob = pp
         .birth_dt_tm, data->personnel[i].patients[size(data->personnel[i].patients,5)].s_mrn = trim(
          ea.alias), data->personnel[i].patients[size(data->personnel[i].patients,5)].
         s_patient_location = build(uar_get_code_display(e.loc_facility_cd),"/",uar_get_code_display(
           e.loc_nurse_unit_cd),"/",uar_get_code_display(e.loc_room_cd),
          "/",uar_get_code_display(e.loc_bed_cd)),
         data->personnel[i].l_pat_cnt += 1, data->personnel[i].s_pat_cnt = cnvtstring(data->
          personnel[i].l_pat_cnt), credit->patients[ml_cred_idx].n_resident_ind = 1
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
  FOOT REPORT
   CALL alterlist(credit->patients,ml_pat_cnt)
   FOR (i = 1 TO size(data->temp_unclaimed,5))
    ml_idx = locateval(ml_cnt,1,size(data->claimed_patients,5),data->temp_unclaimed[i].f_patient_id,
     data->claimed_patients[ml_cnt].f_patient_id),
    IF (ml_idx=0)
     ml_unclaimed_cnt += 1
     IF (size(data->unclaimed_patients,5) < ml_unclaimed_cnt)
      CALL alterlist(data->unclaimed_patients,(ml_unclaimed_cnt+ 9))
     ENDIF
     data->unclaimed_patients[ml_unclaimed_cnt].f_patient_id = data->temp_unclaimed[i].f_patient_id,
     data->unclaimed_patients[ml_unclaimed_cnt].f_encntr_id = data->temp_unclaimed[i].f_encntr_id,
     data->unclaimed_patients[ml_unclaimed_cnt].s_loc = data->temp_unclaimed[i].s_loc,
     data->unclaimed_patients[ml_unclaimed_cnt].s_patient_name = data->temp_unclaimed[i].
     s_patient_name, data->unclaimed_patients[ml_unclaimed_cnt].s_patient_location = data->
     temp_unclaimed[i].s_patient_location, data->unclaimed_patients[ml_unclaimed_cnt].f_patient_dob
      = data->temp_unclaimed[i].f_patient_dob,
     ml_idx3 = locateval(ml_cnt,1,size(pending->patients,5),data->temp_unclaimed[i].f_patient_id,
      pending->patients[ml_cnt].f_person_id)
     IF (ml_idx3 > 0)
      data->unclaimed_patients[ml_unclaimed_cnt].f_arrival_time = pending->patients[ml_idx3].
      f_arrival_time
     ELSE
      data->unclaimed_patients[ml_unclaimed_cnt].f_arrival_time = data->temp_unclaimed[i].
      f_arrival_time
     ENDIF
     data->unclaimed_patients[ml_unclaimed_cnt].s_mrn = data->temp_unclaimed[i].s_mrn
    ENDIF
   ENDFOR
   CALL alterlist(data->unclaimed_patients,ml_unclaimed_cnt)
   FOR (i = 1 TO size(data->unclaimed_patients,5))
     IF ((data->unclaimed_patients[i].s_loc="Consult*"))
      data->l_total_consults += 1
     ELSEIF ((data->unclaimed_patients[i].s_loc="Inp*"))
      data->l_total_inpatients += 1
     ELSEIF ((data->unclaimed_patients[i].s_loc="Obs*"))
      data->l_total_observation += 1
     ELSEIF ((data->unclaimed_patients[i].s_loc="Inter*"))
      data->l_total_inter += 1
     ELSE
      data->l_total_unspecified += 1
     ENDIF
   ENDFOR
   data->l_claimed_total = size(data->claimed_patients,5), data->l_unclaimed_total = size(data->
    unclaimed_patients,5), data->l_patient_total = (data->l_claimed_total+ data->l_unclaimed_total),
   data->l_total_prsnl = size(data->personnel,5)
  WITH nocounter
 ;end select
 IF ((data->l_patient_total=0))
  IF (mn_ops=1
   AND gl_bhs_prod_flag=1)
   CALL uar_send_mail(nullterm("CIScore@bhs.org"),nullterm("BHS_MP_HOSPITALIST_TRACKER OPS Job"),
    nullterm("Ops Job Executed - No Data Was Found"),nullterm("OPS JOB"),1,
    nullterm(""))
  ENDIF
  SET ms_error = "No patients were found."
  GO TO exit_program
 ENDIF
 IF (( $N_REPORT_TYPE=0))
  CALL alterlist(data->personnel,(size(data->personnel,5)+ 14))
  SET data->personnel[(data->l_total_prsnl+ 1)].s_prsnl_name = ""
  SET data->personnel[(data->l_total_prsnl+ 2)].s_prsnl_name = ""
  SET data->personnel[(data->l_total_prsnl+ 3)].s_prsnl_name = build2(format(cnvtdatetime(mf_start),
    "mm/dd HH:mm ;;d")," -",format(cnvtdatetime(mf_end),"mm/dd HH:mm ;;d"))
  SET data->personnel[(data->l_total_prsnl+ 3)].s_pat_cnt = "Date Range"
  SET data->personnel[(data->l_total_prsnl+ 4)].s_prsnl_name = "Total Attending Preceptors:"
  SET data->personnel[(data->l_total_prsnl+ 4)].s_pat_cnt = cnvtstring(data->
   l_total_attending_preceptors)
  SET data->personnel[(data->l_total_prsnl+ 5)].s_prsnl_name = "Total AP/Residents:"
  SET data->personnel[(data->l_total_prsnl+ 5)].s_pat_cnt = cnvtstring(data->l_total_ap_residents)
  SET data->personnel[(data->l_total_prsnl+ 6)].s_prsnl_name = "Total Patients:"
  SET data->personnel[(data->l_total_prsnl+ 6)].s_pat_cnt = cnvtstring(data->l_patient_total)
  SET data->personnel[(data->l_total_prsnl+ 7)].s_prsnl_name = "Total Claimed Patients:"
  SET data->personnel[(data->l_total_prsnl+ 7)].s_pat_cnt = cnvtstring(data->l_claimed_total)
  SET data->personnel[(data->l_total_prsnl+ 8)].s_prsnl_name = "Total Unclaimed Patients:"
  SET data->personnel[(data->l_total_prsnl+ 8)].s_pat_cnt = cnvtstring(data->l_unclaimed_total)
  SET data->personnel[(data->l_total_prsnl+ 9)].s_prsnl_name = ""
  SET data->personnel[(data->l_total_prsnl+ 10)].s_prsnl_name = "Total Consults:"
  SET data->personnel[(data->l_total_prsnl+ 10)].s_pat_cnt = cnvtstring(data->l_total_consults)
  SET data->personnel[(data->l_total_prsnl+ 11)].s_prsnl_name = "Total Inpatients:"
  SET data->personnel[(data->l_total_prsnl+ 11)].s_pat_cnt = cnvtstring(data->l_total_inpatients)
  SET data->personnel[(data->l_total_prsnl+ 12)].s_prsnl_name = "Total Observation Patients:"
  SET data->personnel[(data->l_total_prsnl+ 12)].s_pat_cnt = cnvtstring(data->l_total_observation)
  SET data->personnel[(data->l_total_prsnl+ 13)].s_prsnl_name = "Total Inter Patients:"
  SET data->personnel[(data->l_total_prsnl+ 13)].s_pat_cnt = cnvtstring(data->l_total_inter)
  SET data->personnel[(data->l_total_prsnl+ 14)].s_prsnl_name = "Total Unspecified:"
  SET data->personnel[(data->l_total_prsnl+ 14)].s_pat_cnt = cnvtstring(data->l_total_unspecified)
  SELECT INTO value( $OUTDEV)
   personnel_type = data->personnel[d.seq].s_prsnl_type, personnel_full_name_formatted = data->
   personnel[d.seq].s_prsnl_name, patients_claimed = data->personnel[d.seq].s_pat_cnt
   FROM (dummyt d  WITH seq = size(data->personnel,5))
   PLAN (d)
   ORDER BY personnel_type DESC
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (( $N_REPORT_TYPE=1))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(data->personnel,5)))
   PLAN (d)
   ORDER BY d.seq
   HEAD REPORT
    CALL alterlist(display->info,1), ml_idx = 1, ml_size = 1
   DETAIL
    FOR (i = 1 TO data->personnel[ml_idx].l_pat_cnt)
      display->info[ml_size].l_pat_cnt = data->personnel[ml_idx].l_pat_cnt, display->info[ml_size].
      s_prsnl_name = data->personnel[ml_idx].s_prsnl_name, display->info[ml_size].s_prsnl_type = data
      ->personnel[ml_idx].s_prsnl_type,
      display->info[ml_size].s_patient_name = data->personnel[ml_idx].patients[i].s_patient_name,
      display->info[ml_size].f_patient_id = data->personnel[ml_idx].patients[i].f_patient_id, display
      ->info[ml_size].f_claim_time = data->personnel[ml_idx].patients[i].f_claim_time,
      display->info[ml_size].f_arrival_time = data->personnel[ml_idx].patients[i].f_arrival_time,
      display->info[ml_size].l_wait_time = data->personnel[ml_idx].patients[i].l_wait_time, display->
      info[ml_size].f_patient_dob = data->personnel[ml_idx].patients[i].f_patient_dob,
      display->info[ml_size].s_patient_location = data->personnel[ml_idx].patients[i].
      s_patient_location, display->info[ml_size].s_loc = data->personnel[ml_idx].patients[i].s_loc,
      display->info[ml_size].s_patient_mrn = data->personnel[ml_idx].patients[i].s_mrn,
      ml_size += 1
      IF (size(display->info,5) < ml_size)
       CALL alterlist(display->info,(ml_size+ 9))
      ENDIF
    ENDFOR
    ml_idx += 1
   FOOT REPORT
    CALL alterlist(display->info,ml_size)
   WITH nocounter, separator = " ", format
  ;end select
  IF (size(data->unclaimed_patients,5) > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(data->unclaimed_patients,5)))
    PLAN (d)
    ORDER BY d.seq
    HEAD REPORT
     ml_idx = size(display->info,5)
    DETAIL
     display->info[ml_idx].s_prsnl_type = "Unclaimed/Not Found", display->info[ml_idx].s_prsnl_name
      = "Unclaimed/Not Found", display->info[ml_idx].s_patient_name = data->unclaimed_patients[d.seq]
     .s_patient_name,
     display->info[ml_idx].f_patient_id = data->unclaimed_patients[d.seq].f_patient_id, display->
     info[ml_idx].f_patient_dob = data->unclaimed_patients[d.seq].f_patient_dob, display->info[ml_idx
     ].f_arrival_time = data->unclaimed_patients[d.seq].f_arrival_time,
     display->info[ml_idx].s_patient_location = data->unclaimed_patients[d.seq].s_patient_location,
     display->info[ml_idx].l_pat_cnt = data->l_unclaimed_total, display->info[ml_idx].s_loc = data->
     unclaimed_patients[d.seq].s_loc,
     display->info[ml_idx].f_encntr_id = data->unclaimed_patients[d.seq].f_encntr_id, display->info[
     ml_idx].s_patient_mrn = data->unclaimed_patients[d.seq].s_mrn, ml_idx += 1
     IF (size(display->info,5) < ml_idx)
      CALL alterlist(display->info,(ml_idx+ 9))
     ENDIF
    FOOT REPORT
     CALL alterlist(display->info,ml_idx)
    WITH nocounter, separator = " ", format
   ;end select
  ENDIF
  CALL alterlist(display->info,(size(display->info,5) - 1))
  IF (((textlen( $S_RECIPIENTS) > 1) OR (mn_ops=1)) )
   IF (( $S_GROUP_TYPE="ALL"))
    SET ms_file_name = build("hospitalist_mpage_data",format(mf_start,"mm/dd/yy ;;d"),"_to",format(
      mf_end,"mm/dd/yy ;;d"),".csv")
   ELSE
    SET ms_file_name = build("hospitalist_mpage_data_",cnvtlower(trim( $S_GROUP_TYPE,3)),format(
      mf_start,"mm/dd/yy ;;d"),"_to",format(mf_end,"mm/dd/yy ;;d"),
     ".csv")
   ENDIF
   SET ms_file_name = replace(ms_file_name,"/","_",0)
   SET ms_file_name = replace(ms_file_name," ","_",0)
   SET ms_subject = build2("Hospitalist mPage Data ",trim(format(mf_start,"mmm-dd-yyyy hh:mm;;d")),
    " to ",trim(format(mf_end,"mmm-dd-yyyy hh:mm;;d")))
   SELECT INTO value(ms_file_name)
    personnel_type = substring(0,50,display->info[d.seq].s_prsnl_type), personnel_full_name =
    substring(0,50,display->info[d.seq].s_prsnl_name), arrival_time = substring(0,50,format(display->
      info[d.seq].f_arrival_time,"mm/dd/yyyy hh:mm:ss ;;d"))
    FROM (dummyt d  WITH seq = value(size(display->info,5)))
    PLAN (d)
    ORDER BY personnel_type DESC, personnel_full_name, arrival_time
    HEAD REPORT
     ms_temp = concat(
      "PERSONNEL_TYPE,PERSONNEL_FULL_NAME,PATIENT_COUNT,PATIENT_FULL_NAME,ARRIVAL_TIME,CLAIMED_TIME",
      ",MINUTES_WAITED,PATIENT_TYPE,PATIENT_DOB,PATIENT_MRN,PATIENT_LOCATION_FACILITY/NURSE_UNIT/ROOM/BED"
      ), col 0, ms_temp
    DETAIL
     row + 1, ms_temp = build('"',trim(display->info[d.seq].s_prsnl_type),'",','"',trim(display->
       info[d.seq].s_prsnl_name),
      '",','"',trim(cnvtstring(display->info[d.seq].l_pat_cnt)),'",','"',
      trim(display->info[d.seq].s_patient_name),'",','"',trim(format(display->info[d.seq].
        f_arrival_time,"mm/dd/yyyy hh:mm:ss ;;d")),'",',
      '"',trim(format(display->info[d.seq].f_claim_time,"mm/dd/yyyy hh:mm:ss ;;d")),'",','"',trim(
       evaluate(cnvtstring(display->info[d.seq].l_wait_time),"0","",cnvtstring(display->info[d.seq].
         l_wait_time))),
      '",','"',trim(display->info[d.seq].s_loc),'",','"',
      trim(format(display->info[d.seq].f_patient_dob,"mm/dd/yyyy ;;d")),'",','"',trim(display->info[d
       .seq].s_patient_mrn),'",',
      '"',trim(display->info[d.seq].s_patient_location),'"'), col 0,
     ms_temp
    WITH nocounter, format = variable, formfeed = none,
     maxcol = 5000
   ;end select
   EXECUTE bhs_ma_email_file
   IF (textlen(trim(ms_recipients4,3)) > 0)
    CALL emailfile(value(ms_file_name),ms_file_name,concat('"',ms_recipients,'"'),ms_subject,0)
    CALL emailfile(value(ms_file_name),ms_file_name,concat('"',ms_recipients2,'"'),ms_subject,0)
    CALL emailfile(value(ms_file_name),ms_file_name,concat('"',ms_recipients3,'"'),ms_subject,0)
    CALL emailfile(value(ms_file_name),ms_file_name,concat('"',ms_recipients4,'"'),ms_subject,1)
   ELSEIF (textlen(trim(ms_recipients3,3)) > 0)
    CALL emailfile(value(ms_file_name),ms_file_name,concat('"',ms_recipients,'"'),ms_subject,0)
    CALL emailfile(value(ms_file_name),ms_file_name,concat('"',ms_recipients2,'"'),ms_subject,0)
    CALL emailfile(value(ms_file_name),ms_file_name,concat('"',ms_recipients3,'"'),ms_subject,1)
   ELSEIF (textlen(trim(ms_recipients2,3)) > 0)
    CALL emailfile(value(ms_file_name),ms_file_name,concat('"',ms_recipients,'"'),ms_subject,0)
    CALL emailfile(value(ms_file_name),ms_file_name,concat('"',ms_recipients2,'"'),ms_subject,1)
   ELSE
    CALL emailfile(value(ms_file_name),ms_file_name,concat('"',ms_recipients,'"'),ms_subject,1)
   ENDIF
  ELSE
   SELECT INTO value( $OUTDEV)
    personnel_type = substring(0,50,display->info[d.seq].s_prsnl_type), personnel_full_name =
    substring(0,50,display->info[d.seq].s_prsnl_name), pat_count = display->info[d.seq].l_pat_cnt,
    patient_full_name = substring(0,50,display->info[d.seq].s_patient_name), arrival_time = substring
    (0,50,format(display->info[d.seq].f_arrival_time,"mm/dd/yyyy hh:mm:ss ;;d")), claimed_time =
    substring(0,50,format(display->info[d.seq].f_claim_time,"mm/dd/yyyy hh:mm:ss ;;d")),
    minutes_waited = evaluate(cnvtstring(display->info[d.seq].l_wait_time),"0","",cnvtstring(display
      ->info[d.seq].l_wait_time)), patient_type = substring(0,50,display->info[d.seq].s_loc),
    patient_dob = substring(0,50,format(display->info[d.seq].f_patient_dob,"mm/dd/yyyy ;;d")),
    patient_mrn = substring(0,50,display->info[d.seq].s_patient_mrn), patient_location = substring(0,
     100,display->info[d.seq].s_patient_location)
    FROM (dummyt d  WITH seq = size(display->info,5))
    PLAN (d)
    ORDER BY personnel_type DESC, personnel_full_name, arrival_time
    WITH nocounter, format, separator = " "
   ;end select
  ENDIF
 ENDIF
#exit_program
 IF (mn_ops=1)
  SET reply->status_data[1].status = "S"
 ELSEIF (textlen( $S_RECIPIENTS) > 1
  AND ( $N_REPORT_TYPE=1)
  AND textlen(trim(ms_error,3))=0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = "An email of the detailed report has been sent to:", msg2 = build2("     ", $S_RECIPIENTS),
    CALL print(calcpos(36,18)),
    msg1, row + 2, msg2
   WITH dio = 08
  ;end select
 ELSEIF (textlen(trim(ms_error,3)) != 0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = ms_error, msg2 = "  Please try again.", row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,18)), msg1,
    row + 2, msg2
   WITH dio = 08
  ;end select
 ENDIF
END GO
