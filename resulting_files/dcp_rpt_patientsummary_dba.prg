CREATE PROGRAM dcp_rpt_patientsummary:dba
 IF (validate(reply,"-1") != "-1")
  CALL echo("Reply is already defined.")
 ELSE
  RECORD reply(
    1 text = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 RECORD temp(
   1 patient[*]
     2 info_dt_tm = vc
     2 look_back_dt_tm = vc
     2 demographics
       3 person_id = f8
       3 primary_encntr_id = f8
       3 name_full_formatted = vc
       3 mrn = vc
       3 facility = vc
       3 nurse_unit = vc
       3 room = vc
       3 bed = vc
       3 room_bed = vc
       3 reason_for_visit = vc
       3 reason_ln_cnt = i2
       3 reason_tag[*]
         4 reason_line = vc
       3 dayofstay = vc
       3 gender = vc
       3 age = vc
       3 address1 = vc
       3 address2 = vc
       3 address3 = vc
       3 address4 = vc
       3 phone = vc
       3 emergency_contact = vc
       3 emergency_contact_phone = vc
       3 referring_doc = vc
       3 attending_doc = vc
       3 admitting_doc = vc
       3 insurance = vc
       3 allergies = vc
       3 all_ln_cnt = i2
       3 all_tag[*]
         4 all_line = vc
       3 problems = vc
       3 prob_ln_cnt = i2
       3 prob_tag[*]
         4 prob_line = vc
     2 encntr_cnt = i2
     2 encntr[*]
       3 encntr_id = f8
     2 lr_cnt = i2
     2 lab_result_dt_grp[*]
       3 lab_result_first_idx = i4
       3 lab_result_last_idx = i4
       3 lr_tot_odd_line_cnt = i4
       3 lr_tot_even_line_cnt = i4
       3 lr_high_line_cnt = i4
       3 lr_left_index = i4
     2 lab_result[*]
       3 event_cd = f8
       3 encntr_id = f8
       3 lr_line_cnt = i4
       3 event_name = vc
       3 en_cnt = i2
       3 en_tag[*]
         4 en_line = vc
       3 result_value = vc
       3 rv_cnt = i2
       3 rv_tag[*]
         4 rv_line = vc
       3 order_id = f8
       3 verify_dt_tm = vc
       3 event_end_dt_tm = vc
       3 lab_result_dt_grp_id = i4
       3 normalcy_disp = vc
       3 ref_range = vc
       3 rr_cnt = i2
       3 rr_tag[*]
         4 rr_line = vc
       3 note = vc
     2 mo_cnt = i2
     2 med_order[*]
       3 catalog_cd = f8
       3 encntr_id = f8
       3 catalog_type_cd = f8
       3 activity_type_cd = f8
       3 order_id = f8
       3 mnemonic = vc
       3 mnem_cnt = i2
       3 mnem_tag[*]
         4 mnem_line = vc
       3 frequency = vc
       3 dose = vc
       3 doseunit = vc
       3 route = vc
       3 display_line = vc
       3 dl_cnt = i2
       3 dl_tag[*]
         4 dl_line = vc
       3 dnum = vc
       3 iv_ind = i2
       3 prn_ind = i2
     2 rd_cnt = i2
     2 radiology_doc[*]
       3 event_cd = f8
       3 event_cd_seq = i2
       3 encntr_id = f8
       3 doc_name = vc
       3 blob = vc
       3 event_end_dt_tm = vc
       3 author = vc
       3 rd_cnt = i2
       3 rd_tag[*]
         4 rd_line = vc
       3 sort_by_dt_tm = vc
     2 pn_cnt = i2
     2 progress_note[*]
       3 event_cd = f8
       3 event_cd_seq = i2
       3 encntr_id = f8
       3 doc_name = vc
       3 blob = vc
       3 event_end_dt_tm = vc
       3 author = vc
       3 pn_cnt = i2
       3 pn_tag[*]
         4 pn_line = vc
       3 sort_by_dt_tm = vc
     2 od_cnt = i2
     2 other_doc[*]
       3 event_cd = f8
       3 event_cd_seq = i2
       3 encntr_id = f8
       3 doc_name = vc
       3 blob = vc
       3 event_end_dt_tm = vc
       3 author = vc
       3 od_cnt = i2
       3 od_tag[*]
         4 od_line = vc
       3 sort_by_dt_tm = vc
     2 pcr_cnt = i2
     2 patient_care_result[*]
       3 event_cd = f8
       3 encntr_id = f8
       3 event_name = vc
       3 en_cnt = i2
       3 en_tag[*]
         4 en_line = vc
       3 result_value = vc
       3 rv_cnt = i2
       3 rv_tag[*]
         4 rv_line = vc
       3 order_id = f8
       3 verify_dt_tm = vc
       3 event_end_dt_tm = vc
       3 normalcy_disp = vc
       3 ref_range = vc
       3 rr_cnt = i2
       3 rr_tag[*]
         4 rr_line = vc
       3 note = vc
     2 po_cnt = i2
     2 pending_order[*]
       3 catalog_cd = f8
       3 encntr_id = f8
       3 catalog_type_cd = f8
       3 activity_type_cd = f8
       3 order_id = f8
       3 mnemonic = vc
       3 display_line = vc
       3 dl_cnt = i2
       3 dl_tag[*]
         4 dl_line = vc
     2 ao_cnt = i2
     2 active_order[*]
       3 catalog_cd = f8
       3 encntr_id = f8
       3 catalog_type_cd = f8
       3 activity_type_cd = f8
       3 order_id = f8
       3 mnemonic = vc
       3 display_line = vc
       3 dl_cnt = i2
       3 dl_tag[*]
         4 dl_line = vc
     2 height = vc
     2 height_dt_tm = vc
     2 weight = vc
     2 weight_dt_tm = vc
     2 vital_sign[*]
       3 vital_sign_dt_tm = vc
       3 temperature = vc
       3 pulse = vc
       3 respiratory = vc
       3 blood_pressure = vc
     2 resource_cd = f8
     2 appointments[*]
       3 beg_dt_tm = vc
       3 end_dt_tm = vc
       3 state_meaning = vc
       3 appt_location_disp = vc
       3 appt_type_desc = vc
       3 appt_reason_free = vc
       3 appt_synonym_free = vc
       3 req_prsnl_name = vc
       3 primary_resource_mnem = vc
     2 sn_cnt = i2
     2 sticky_note[*]
       3 note = vc
       3 note_cnt = i2
       3 note_tag[*]
         4 note_line = vc
     2 io_cnt = i2
     2 io[*]
       3 io_dt_tm = vc
       3 intake = f8
       3 output = f8
       3 balance = f8
 )
 RECORD temp2(
   1 lrec_cnt = i2
   1 lrec[*]
     2 lr_event_cd = f8
   1 nrec_cnt = i2
   1 nrec[*]
     2 nr_event_cd = f8
   1 rad_cnt = i2
   1 rad[*]
     2 rad_event_cd = f8
     2 rad_event_set_cd = f8
   1 pro_cnt = i2
   1 pro[*]
     2 pro_event_cd = f8
     2 pro_event_set_cd = f8
   1 doc_cnt = i2
   1 doc[*]
     2 doc_event_cd = f8
     2 doc_event_set_cd = f8
   1 aoct_cnt = i2
   1 aoct[*]
     2 ao_catalog_type = f8
   1 poct_cnt = i2
   1 poct[*]
     2 po_catalog_type = f8
   1 oe_cnt = i2
   1 oe[*]
     2 oe_type_flag = c1
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 activity_type_cd = f8
   1 re_cnt = i2
   1 re[*]
     2 re_type_flag = i2
     2 event_cd = f8
 )
 RECORD hold(
   1 o_cnt = i2
   1 o[*]
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 activity_type_cd = f8
     2 order_id = f8
     2 mnemonic = vc
     2 display_line = vc
     2 frequency = vc
     2 dose = vc
     2 route = vc
     2 doseunit = vc
     2 dnum = vc
   1 r_cnt = i2
   1 r[*]
     2 event_cd = f8
     2 event_name = vc
     2 result_value = vc
     2 order_id = f8
     2 verify_dt_tm = vc
     2 event_end_dt_tm = vc
     2 normalcy_disp = vc
     2 ref_range = vc
     2 note = vc
     2 doc_name = vc
     2 doc_blob = vc
     2 doc_author = vc
 )
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 RECORD lr_dt_tm(
   1 event_dt_arr[*]
     2 nbr_events = i2
 )
 SET reply->status_data.status = "S"
 SET patient_cnt = size(request->visit,5)
 IF (patient_cnt=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET info_dt_tm = format(cnvtdatetime(curdate,curtime),"ddmmmyyyy hh:mm;;d")
 SET stat = alterlist(temp->patient,patient_cnt)
 SET ecnt = 0
 FOR (x = 1 TO patient_cnt)
  SET temp->patient[x].info_dt_tm = info_dt_tm
  SET temp->patient[x].demographics.primary_encntr_id = request->visit[x].encntr_id
 ENDFOR
 SET temp2->lrec_cnt = 0
 SET temp2->doc_cnt = 0
 SET temp2->rad_cnt = 0
 SET temp2->pro_cnt = 0
 SET temp2->nrec_cnt = 0
 SET temp2->aoct_cnt = 0
 SET temp2->poct_cnt = 0
 SET call_echo_ind = 1
 SET cnt = 0
 SET hold_days_back = 0
 SET tempday = 0.0
 SET lf = char(10)
 SET t_index = 0
 SET beg_ind = 0
 SET end_ind = 0
 SET beg_dt_tm = cnvtdatetime((curdate - 1),curtime)
 SET end_dt_tm = cnvtdatetime(curdate,curtime)
 SET x2 = "  "
 SET x3 = "   "
 SET abc = fillstring(25," ")
 SET xyz = "  -   -       :  :  "
 DECLARE critical_cd = f8 WITH noconstant(0.0)
 DECLARE extremehi_cd = f8 WITH noconstant(0.0)
 DECLARE extremelo_cd = f8 WITH noconstant(0.0)
 DECLARE panichi_cd = f8 WITH noconstant(0.0)
 DECLARE paniclo_cd = f8 WITH noconstant(0.0)
 DECLARE vabnormal_cd = f8 WITH noconstant(0.0)
 DECLARE positive_cd = f8 WITH noconstant(0.0)
 FOR (x = 1 TO request->nv_cnt)
   IF ((request->nv[x].pvc_name="BEG_DT_TM"))
    SET beg_ind = 1
    SET abc = trim(request->nv[x].pvc_value)
    SET stat = movestring(abc,7,xyz,1,2)
    SET x2 = substring(5,2,abc)
    IF (x2="01")
     SET x3 = "JAN"
    ELSEIF (x2="02")
     SET x3 = "FEB"
    ELSEIF (x2="03")
     SET x3 = "MAR"
    ELSEIF (x2="04")
     SET x3 = "APR"
    ELSEIF (x2="05")
     SET x3 = "MAY"
    ELSEIF (x2="06")
     SET x3 = "JUN"
    ELSEIF (x2="07")
     SET x3 = "JUL"
    ELSEIF (x2="08")
     SET x3 = "AUG"
    ELSEIF (x2="09")
     SET x3 = "SEP"
    ELSEIF (x2="10")
     SET x3 = "OCT"
    ELSEIF (x2="11")
     SET x3 = "NOV"
    ELSEIF (x2="12")
     SET x3 = "DEC"
    ENDIF
    SET stat = movestring(x3,1,xyz,4,3)
    SET stat = movestring(abc,1,xyz,8,4)
    SET stat = movestring(abc,9,xyz,13,2)
    SET stat = movestring(abc,11,xyz,16,2)
    SET stat = movestring(abc,13,xyz,19,2)
    SET beg_dt_tm = cnvtdatetime(xyz)
   ELSEIF ((request->nv[x].pvc_name="END_DT_TM"))
    SET end_ind = 1
    SET abc = trim(request->nv[x].pvc_value)
    SET stat = movestring(abc,7,xyz,1,2)
    SET x2 = substring(5,2,abc)
    IF (x2="01")
     SET x3 = "JAN"
    ELSEIF (x2="02")
     SET x3 = "FEB"
    ELSEIF (x2="03")
     SET x3 = "MAR"
    ELSEIF (x2="04")
     SET x3 = "APR"
    ELSEIF (x2="05")
     SET x3 = "MAY"
    ELSEIF (x2="06")
     SET x3 = "JUN"
    ELSEIF (x2="07")
     SET x3 = "JUL"
    ELSEIF (x2="08")
     SET x3 = "AUG"
    ELSEIF (x2="09")
     SET x3 = "SEP"
    ELSEIF (x2="10")
     SET x3 = "OCT"
    ELSEIF (x2="11")
     SET x3 = "NOV"
    ELSEIF (x2="12")
     SET x3 = "DEC"
    ENDIF
    SET stat = movestring(x3,1,xyz,4,3)
    SET stat = movestring(abc,1,xyz,8,4)
    SET stat = movestring(abc,9,xyz,13,2)
    SET stat = movestring(abc,11,xyz,16,2)
    SET stat = movestring(abc,13,xyz,19,2)
    SET end_dt_tm = cnvtdatetime(xyz)
   ENDIF
 ENDFOR
 IF (cnvtdatetime(beg_dt_tm) < cnvtdatetime((curdate - 30),curtime))
  SET beg_dt_tm = cnvtdatetime((curdate - 30),curtime)
 ENDIF
 SET lab_result_ind = 0
 SET nurse_result_ind = 0
 SET med_order_ind = 0
 SET vitals_ind = 0
 SET documents_ind = 0
 SET radiology_ind = 0
 SET progress_note_ind = 0
 SET pending_order_ind = 0
 SET active_order_ind = 0
 SET io_ind = 0
 SET appointments_ind = - (1)
 SET prsnl_customize_ind = 0
 SET temp_cd = - (1)
 SET resp_cd = - (1)
 SET pulse_cd = - (1)
 SET sys_cd = - (1)
 SET dia_cd = - (1)
 SET hgt_cd = - (1)
 SET wgt_cd = - (1)
 SELECT INTO "nl:"
  FROM detail_prefs d,
   name_value_prefs n
  PLAN (d
   WHERE d.application_number=1400000
    AND d.position_cd=0
    AND d.prsnl_id=0
    AND d.person_id=0
    AND d.view_name="RL_PALM"
    AND d.view_seq=1
    AND d.comp_name="RL_PALM"
    AND d.comp_seq=1
    AND d.active_ind=1)
   JOIN (n
   WHERE n.parent_entity_id=d.detail_prefs_id
    AND n.parent_entity_name="DETAIL_PREFS"
    AND n.active_ind=1
    AND n.pvc_name IN ("RL_MO", "RL_LR", "RL_VS", "RL_OTHER_DOC", "RL_PND_ORDER",
   "RL_ACT_ORDER", "RL_PC", "RL_RAD_DOC", "RL_NOTE_DOC", "RL_CUSTOMIZE",
   "RL_INO")
    AND n.pvc_value IN ("1", "0"))
  DETAIL
   IF (n.pvc_name="RL_LR")
    lab_result_ind = cnvtint(substring(1,1,n.pvc_value))
   ELSEIF (n.pvc_name="RL_MO")
    med_order_ind = cnvtint(substring(1,1,n.pvc_value))
   ELSEIF (n.pvc_name="RL_VS")
    vitals_ind = cnvtint(substring(1,1,n.pvc_value))
   ELSEIF (n.pvc_name="RL_OTHER_DOC")
    documents_ind = cnvtint(substring(1,1,n.pvc_value))
   ELSEIF (n.pvc_name="RL_PND_ORDER")
    pending_order_ind = cnvtint(substring(1,1,n.pvc_value))
   ELSEIF (n.pvc_name="RL_ACT_ORDER")
    active_order_ind = cnvtint(substring(1,1,n.pvc_value))
   ELSEIF (n.pvc_name="RL_RAD_DOC")
    radiology_ind = cnvtint(substring(1,1,n.pvc_value))
   ELSEIF (n.pvc_name="RL_NOTE_DOC")
    progress_note_ind = cnvtint(substring(1,1,n.pvc_value))
   ELSEIF (n.pvc_name="RL_PC")
    nurse_result_ind = cnvtint(substring(1,1,n.pvc_value)),
    CALL echo(build("RL_PC Value: ",nurse_result_ind))
   ELSEIF (n.pvc_name="RL_CUSTOMIZE")
    prsnl_customize_ind = cnvtint(substring(1,1,n.pvc_value))
   ELSEIF (n.pvc_name="RL_INO")
    io_ind = cnvtint(substring(1,1,n.pvc_value)),
    CALL echo(build("RL_INO Value: ",io_ind))
   ENDIF
  WITH nocounter
 ;end select
 IF (lab_result_ind=1)
  IF (prsnl_customize_ind=1)
   SELECT INTO "nl:"
    FROM detail_prefs d,
     name_value_prefs n
    PLAN (d
     WHERE d.application_number=1400000
      AND d.position_cd=0
      AND (d.prsnl_id=reqinfo->updt_id)
      AND d.person_id=0
      AND d.view_name="RL_PALM"
      AND d.view_seq=1
      AND d.comp_name="RL_PALM"
      AND d.comp_seq=1
      AND d.active_ind=1)
     JOIN (n
     WHERE n.parent_entity_id=d.detail_prefs_id
      AND n.parent_entity_name="DETAIL_PREFS"
      AND n.active_ind=1
      AND n.pvc_name="RL_LR_EC"
      AND n.merge_name="V500_EVENT_CODE"
      AND n.merge_id > 0)
    ORDER BY n.sequence, n.merge_id
    HEAD REPORT
     cnt = 0
    HEAD n.merge_id
     cnt = (cnt+ 1), stat = alterlist(temp2->lrec,cnt), temp2->lrec[cnt].lr_event_cd = n.merge_id
    FOOT REPORT
     temp2->lrec_cnt = cnt
    WITH nocounter
   ;end select
  ENDIF
  IF ((temp2->lrec_cnt=0))
   SELECT INTO "nl:"
    FROM detail_prefs d,
     name_value_prefs n
    PLAN (d
     WHERE d.application_number=1400000
      AND d.position_cd=0
      AND d.prsnl_id=0
      AND d.person_id=0
      AND d.view_name="RL_PALM"
      AND d.view_seq=1
      AND d.comp_name="RL_PALM"
      AND d.comp_seq=1
      AND d.active_ind=1)
     JOIN (n
     WHERE n.parent_entity_id=d.detail_prefs_id
      AND n.parent_entity_name="DETAIL_PREFS"
      AND n.active_ind=1
      AND n.pvc_name="RL_LR_EC"
      AND n.merge_name="V500_EVENT_CODE"
      AND n.merge_id > 0)
    ORDER BY n.sequence, n.merge_id
    HEAD REPORT
     cnt = 0
    HEAD n.merge_id
     cnt = (cnt+ 1), stat = alterlist(temp2->lrec,cnt), temp2->lrec[cnt].lr_event_cd = n.merge_id
    FOOT REPORT
     temp2->lrec_cnt = cnt
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (nurse_result_ind=1)
  IF (prsnl_customize_ind=1)
   SELECT INTO "nl:"
    FROM detail_prefs d,
     name_value_prefs n
    PLAN (d
     WHERE d.application_number=1400000
      AND d.position_cd=0
      AND (d.prsnl_id=reqinfo->updt_id)
      AND d.person_id=0
      AND d.view_name="RL_PALM"
      AND d.view_seq=1
      AND d.comp_name="RL_PALM"
      AND d.comp_seq=1
      AND d.active_ind=1)
     JOIN (n
     WHERE n.parent_entity_id=d.detail_prefs_id
      AND n.parent_entity_name="DETAIL_PREFS"
      AND n.active_ind=1
      AND n.pvc_name="RL_PCR_EC"
      AND n.merge_name="V500_EVENT_CODE"
      AND n.merge_id > 0)
    ORDER BY n.sequence, n.merge_id
    HEAD REPORT
     cnt = 0
    HEAD n.merge_id
     cnt = (cnt+ 1), stat = alterlist(temp2->nrec,cnt), temp2->nrec[cnt].nr_event_cd = n.merge_id
    FOOT REPORT
     temp2->nrec_cnt = cnt
    WITH nocounter
   ;end select
  ENDIF
  IF ((temp2->nrec_cnt=0))
   SELECT INTO "nl:"
    FROM detail_prefs d,
     name_value_prefs n
    PLAN (d
     WHERE d.application_number=1400000
      AND d.position_cd=0
      AND d.prsnl_id=0
      AND d.person_id=0
      AND d.view_name="RL_PALM"
      AND d.view_seq=1
      AND d.comp_name="RL_PALM"
      AND d.comp_seq=1
      AND d.active_ind=1)
     JOIN (n
     WHERE n.parent_entity_id=d.detail_prefs_id
      AND n.parent_entity_name="DETAIL_PREFS"
      AND n.active_ind=1
      AND n.pvc_name="RL_PCR_EC"
      AND n.merge_name="V500_EVENT_CODE"
      AND n.merge_id > 0)
    ORDER BY n.sequence, n.merge_id
    HEAD REPORT
     cnt = 0
    HEAD n.merge_id
     cnt = (cnt+ 1), stat = alterlist(temp2->nrec,cnt), temp2->nrec[cnt].nr_event_cd = n.merge_id
    FOOT REPORT
     temp2->nrec_cnt = cnt
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (radiology_ind=1)
  IF (prsnl_customize_ind=1)
   SELECT INTO "nl:"
    FROM detail_prefs d,
     name_value_prefs n
    PLAN (d
     WHERE d.application_number=1400000
      AND d.position_cd=0
      AND (d.prsnl_id=reqinfo->updt_id)
      AND d.person_id=0
      AND d.view_name="RL_PALM"
      AND d.view_seq=1
      AND d.comp_name="RL_PALM"
      AND d.comp_seq=1
      AND d.active_ind=1)
     JOIN (n
     WHERE n.parent_entity_id=d.detail_prefs_id
      AND n.parent_entity_name="DETAIL_PREFS"
      AND n.active_ind=1
      AND n.pvc_name="RL_RAD_DOC_EC"
      AND n.merge_name="V500_EVENT_CODE"
      AND n.merge_id > 0)
    ORDER BY n.sequence, n.merge_id
    HEAD REPORT
     cnt = 0
    HEAD n.merge_id
     cnt = (cnt+ 1), stat = alterlist(temp2->rad,cnt), temp2->rad[cnt].rad_event_cd = n.merge_id
    FOOT REPORT
     temp2->rad_cnt = cnt
    WITH nocounter
   ;end select
  ENDIF
  IF ((temp2->rad_cnt=0))
   SELECT INTO "nl:"
    FROM detail_prefs d,
     name_value_prefs n
    PLAN (d
     WHERE d.application_number=1400000
      AND d.position_cd=0
      AND d.prsnl_id=0
      AND d.person_id=0
      AND d.view_name="RL_PALM"
      AND d.view_seq=1
      AND d.comp_name="RL_PALM"
      AND d.comp_seq=1
      AND d.active_ind=1)
     JOIN (n
     WHERE n.parent_entity_id=d.detail_prefs_id
      AND n.parent_entity_name="DETAIL_PREFS"
      AND n.active_ind=1
      AND n.pvc_name="RL_RAD_DOC_EC"
      AND n.merge_name="V500_EVENT_CODE"
      AND n.merge_id > 0)
    ORDER BY n.sequence, n.merge_id
    HEAD REPORT
     cnt = 0
    HEAD n.merge_id
     cnt = (cnt+ 1), stat = alterlist(temp2->rad,cnt), temp2->rad[cnt].rad_event_cd = n.merge_id
    FOOT REPORT
     temp2->rad_cnt = cnt
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (progress_note_ind=1)
  IF (prsnl_customize_ind=1)
   SELECT INTO "nl:"
    FROM detail_prefs d,
     name_value_prefs n
    PLAN (d
     WHERE d.application_number=1400000
      AND d.position_cd=0
      AND (d.prsnl_id=reqinfo->updt_id)
      AND d.person_id=0
      AND d.view_name="RL_PALM"
      AND d.view_seq=1
      AND d.comp_name="RL_PALM"
      AND d.comp_seq=1
      AND d.active_ind=1)
     JOIN (n
     WHERE n.parent_entity_id=d.detail_prefs_id
      AND n.parent_entity_name="DETAIL_PREFS"
      AND n.active_ind=1
      AND n.pvc_name="RL_NOTE_DOC_EC"
      AND n.merge_name="V500_EVENT_CODE"
      AND n.merge_id > 0)
    ORDER BY n.sequence, n.merge_id
    HEAD REPORT
     cnt = 0
    HEAD n.merge_id
     cnt = (cnt+ 1), stat = alterlist(temp2->pro,cnt), temp2->pro[cnt].pro_event_cd = n.merge_id
    FOOT REPORT
     temp2->pro_cnt = cnt
    WITH nocounter
   ;end select
  ENDIF
  IF ((temp2->pro_cnt=0))
   SELECT INTO "nl:"
    FROM detail_prefs d,
     name_value_prefs n
    PLAN (d
     WHERE d.application_number=1400000
      AND d.position_cd=0
      AND d.prsnl_id=0
      AND d.person_id=0
      AND d.view_name="RL_PALM"
      AND d.view_seq=1
      AND d.comp_name="RL_PALM"
      AND d.comp_seq=1
      AND d.active_ind=1)
     JOIN (n
     WHERE n.parent_entity_id=d.detail_prefs_id
      AND n.parent_entity_name="DETAIL_PREFS"
      AND n.active_ind=1
      AND n.pvc_name="RL_NOTE_DOC_EC"
      AND n.merge_name="V500_EVENT_CODE"
      AND n.merge_id > 0)
    ORDER BY n.sequence, n.merge_id
    HEAD REPORT
     cnt = 0
    HEAD n.merge_id
     cnt = (cnt+ 1), stat = alterlist(temp2->pro,cnt), temp2->pro[cnt].pro_event_cd = n.merge_id
    FOOT REPORT
     temp2->pro_cnt = cnt
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (documents_ind=1)
  IF (prsnl_customize_ind=1)
   SELECT INTO "nl:"
    FROM detail_prefs d,
     name_value_prefs n
    PLAN (d
     WHERE d.application_number=1400000
      AND d.position_cd=0
      AND (d.prsnl_id=reqinfo->updt_id)
      AND d.person_id=0
      AND d.view_name="RL_PALM"
      AND d.view_seq=1
      AND d.comp_name="RL_PALM"
      AND d.comp_seq=1
      AND d.active_ind=1)
     JOIN (n
     WHERE n.parent_entity_id=d.detail_prefs_id
      AND n.parent_entity_name="DETAIL_PREFS"
      AND n.active_ind=1
      AND n.pvc_name="RL_OTHER_DOC_EC"
      AND n.merge_name="V500_EVENT_CODE"
      AND n.merge_id > 0)
    ORDER BY n.sequence, n.merge_id
    HEAD REPORT
     cnt = 0
    HEAD n.merge_id
     cnt = (cnt+ 1), stat = alterlist(temp2->doc,cnt), temp2->doc[cnt].doc_event_cd = n.merge_id
    FOOT REPORT
     temp2->doc_cnt = cnt
    WITH nocounter
   ;end select
  ENDIF
  IF ((temp2->doc_cnt=0))
   SELECT INTO "nl:"
    FROM detail_prefs d,
     name_value_prefs n
    PLAN (d
     WHERE d.application_number=1400000
      AND d.position_cd=0
      AND d.prsnl_id=0
      AND d.person_id=0
      AND d.view_name="RL_PALM"
      AND d.view_seq=1
      AND d.comp_name="RL_PALM"
      AND d.comp_seq=1
      AND d.active_ind=1)
     JOIN (n
     WHERE n.parent_entity_id=d.detail_prefs_id
      AND n.parent_entity_name="DETAIL_PREFS"
      AND n.active_ind=1
      AND n.pvc_name="RL_OTHER_DOC_EC"
      AND n.merge_name="V500_EVENT_CODE"
      AND n.merge_id > 0)
    ORDER BY n.sequence, n.merge_id
    HEAD REPORT
     cnt = 0
    HEAD n.merge_id
     cnt = (cnt+ 1), stat = alterlist(temp2->doc,cnt), temp2->doc[cnt].doc_event_cd = n.merge_id
    FOOT REPORT
     temp2->doc_cnt = cnt
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (active_order_ind=1)
  IF (prsnl_customize_ind=1)
   SELECT INTO "nl:"
    FROM detail_prefs d,
     name_value_prefs n
    PLAN (d
     WHERE d.application_number=1400000
      AND d.position_cd=0
      AND (d.prsnl_id=reqinfo->updt_id)
      AND d.person_id=0
      AND d.view_name="RL_PALM"
      AND d.view_seq=1
      AND d.comp_name="RL_PALM"
      AND d.comp_seq=1
      AND d.active_ind=1)
     JOIN (n
     WHERE n.parent_entity_id=d.detail_prefs_id
      AND n.parent_entity_name="DETAIL_PREFS"
      AND n.active_ind=1
      AND n.pvc_name="RL_ACT_ORDER_CD"
      AND n.merge_name="CODE_VALUE"
      AND n.merge_id > 0)
    ORDER BY n.sequence, n.merge_id
    HEAD REPORT
     cnt = 0
    HEAD n.merge_id
     cnt = (cnt+ 1), stat = alterlist(temp2->aoct,cnt), temp2->aoct[cnt].ao_catalog_type = n.merge_id
    FOOT REPORT
     temp2->aoct_cnt = cnt
    WITH nocounter
   ;end select
  ENDIF
  IF ((temp2->aoct_cnt=0))
   SELECT INTO "nl:"
    FROM detail_prefs d,
     name_value_prefs n
    PLAN (d
     WHERE d.application_number=1400000
      AND d.position_cd=0
      AND d.prsnl_id=0
      AND d.person_id=0
      AND d.view_name="RL_PALM"
      AND d.view_seq=1
      AND d.comp_name="RL_PALM"
      AND d.comp_seq=1
      AND d.active_ind=1)
     JOIN (n
     WHERE n.parent_entity_id=d.detail_prefs_id
      AND n.parent_entity_name="DETAIL_PREFS"
      AND n.active_ind=1
      AND n.pvc_name="RL_ACT_ORDER_CD"
      AND n.merge_name="CODE_VALUE"
      AND n.merge_id > 0)
    ORDER BY n.sequence, n.merge_id
    HEAD REPORT
     cnt = 0
    HEAD n.merge_id
     cnt = (cnt+ 1), stat = alterlist(temp2->aoct,cnt), temp2->aoct[cnt].ao_catalog_type = n.merge_id
    FOOT REPORT
     temp2->aoct_cnt = cnt
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (pending_order_ind=1)
  IF (prsnl_customize_ind=1)
   SELECT INTO "nl:"
    FROM detail_prefs d,
     name_value_prefs n
    PLAN (d
     WHERE d.application_number=1400000
      AND d.position_cd=0
      AND (d.prsnl_id=reqinfo->updt_id)
      AND d.person_id=0
      AND d.view_name="RL_PALM"
      AND d.view_seq=1
      AND d.comp_name="RL_PALM"
      AND d.comp_seq=1
      AND d.active_ind=1)
     JOIN (n
     WHERE n.parent_entity_id=d.detail_prefs_id
      AND n.parent_entity_name="DETAIL_PREFS"
      AND n.active_ind=1
      AND n.pvc_name="RL_PND_ORDER_CD"
      AND n.merge_name="CODE_VALUE"
      AND n.merge_id > 0)
    ORDER BY n.sequence, n.merge_id
    HEAD REPORT
     cnt = 0
    HEAD n.merge_id
     cnt = (cnt+ 1), stat = alterlist(temp2->poct,cnt), temp2->poct[cnt].po_catalog_type = n.merge_id
    FOOT REPORT
     temp2->poct_cnt = cnt
    WITH nocounter
   ;end select
  ENDIF
  IF ((temp2->poct_cnt=0))
   SELECT INTO "nl:"
    FROM detail_prefs d,
     name_value_prefs n
    PLAN (d
     WHERE d.application_number=1400000
      AND d.position_cd=0
      AND d.prsnl_id=0
      AND d.person_id=0
      AND d.view_name="RL_PALM"
      AND d.view_seq=1
      AND d.comp_name="RL_PALM"
      AND d.comp_seq=1
      AND d.active_ind=1)
     JOIN (n
     WHERE n.parent_entity_id=d.detail_prefs_id
      AND n.parent_entity_name="DETAIL_PREFS"
      AND n.active_ind=1
      AND n.pvc_name="RL_PND_ORDER_CD"
      AND n.merge_name="CODE_VALUE"
      AND n.merge_id > 0)
    ORDER BY n.sequence, n.merge_id
    HEAD REPORT
     cnt = 0
    HEAD n.merge_id
     cnt = (cnt+ 1), stat = alterlist(temp2->poct,cnt), temp2->poct[cnt].po_catalog_type = n.merge_id
    FOOT REPORT
     temp2->poct_cnt = cnt
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (vitals_ind=1)
  SELECT INTO "nl:"
   FROM detail_prefs d,
    name_value_prefs n
   PLAN (d
    WHERE d.application_number=1400000
     AND d.position_cd=0
     AND d.prsnl_id=0
     AND d.person_id=0
     AND d.view_name="RL_PALM"
     AND d.view_seq=1
     AND d.comp_name="RL_PALM"
     AND d.comp_seq=1
     AND d.active_ind=1)
    JOIN (n
    WHERE n.parent_entity_id=d.detail_prefs_id
     AND n.parent_entity_name="DETAIL_PREFS"
     AND n.active_ind=1
     AND n.pvc_name IN ("RL_VS_TEMP_CD", "RL_VS_REP_CD", "RL_VS_PULSE_CD", "RL_VS_SYS_CD",
    "RL_VS_DIA_CD",
    "RL_VS_HGT_CD", "RL_VS_WGT_CD")
     AND n.merge_name="V500_EVENT_CODE"
     AND n.merge_id > 0)
   DETAIL
    IF (n.pvc_name="RL_VS_TEMP_CD")
     temp_cd = n.merge_id
    ELSEIF (n.pvc_name="RL_VS_REP_CD")
     resp_cd = n.merge_id
    ELSEIF (n.pvc_name="RL_VS_PULSE_CD")
     pulse_cd = n.merge_id
    ELSEIF (n.pvc_name="RL_VS_SYS_CD")
     sys_cd = n.merge_id
    ELSEIF (n.pvc_name="RL_VS_DIA_CD")
     dia_cd = n.merge_id
    ELSEIF (n.pvc_name="RL_VS_HGT_CD")
     hgt_cd = n.merge_id
    ELSEIF (n.pvc_name="RL_VS_WGT_CD")
     wgt_cd = n.merge_id
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 4
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_cd = code_value
 SET code_set = 339
 SET cdf_meaning = "CENSUS"
 EXECUTE cpm_get_cd_for_cdf
 SET census_cd = code_value
 SET code_set = 43
 SET cdf_meaning = "HOME"
 EXECUTE cpm_get_cd_for_cdf
 SET home_phone_cd = code_value
 SET code_set = 212
 SET cdf_meaning = "HOME"
 EXECUTE cpm_get_cd_for_cdf
 SET home_address_cd = code_value
 SET code_set = 351
 SET cdf_meaning = "EMC"
 EXECUTE cpm_get_cd_for_cdf
 SET emc_cd = code_value
 SET code_set = 333
 SET cdf_meaning = "REFERDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET refer_cd = code_value
 SET code_set = 333
 SET cdf_meaning = "ADMITDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET admit_cd = code_value
 SET code_set = 333
 SET cdf_meaning = "ATTENDDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET attend_cd = code_value
 SET code_set = 6000
 SET cdf_meaning = "PHARMACY"
 EXECUTE cpm_get_cd_for_cdf
 SET pharmacy_cd = code_value
 SET code_set = 6000
 SET cdf_meaning = "NURS"
 EXECUTE cpm_get_cd_for_cdf
 SET nurs_cd = code_value
 SET code_set = 6000
 SET cdf_meaning = "RADIOLOGY"
 EXECUTE cpm_get_cd_for_cdf
 SET rad_cd = code_value
 SET code_set = 6000
 SET cdf_meaning = "GENERAL LAB"
 EXECUTE cpm_get_cd_for_cdf
 SET lab_cd = code_value
 SET code_set = 106
 SET cdf_meaning = "GLB"
 EXECUTE cpm_get_cd_for_cdf
 SET genlab_cd = code_value
 SET code_set = 53
 SET cdf_meaning = "NUM"
 EXECUTE cpm_get_cd_for_cdf
 SET num_cd = code_value
 SET code_set = 53
 SET cdf_meaning = "TXT"
 EXECUTE cpm_get_cd_for_cdf
 SET txt_cd = code_value
 SET code_set = 53
 SET cdf_meaning = "RAD"
 EXECUTE cpm_get_cd_for_cdf
 SET rad_doc_cd = code_value
 SET code_set = 53
 SET cdf_meaning = "DOC"
 EXECUTE cpm_get_cd_for_cdf
 SET doc_cd = code_value
 SET code_set = 53
 SET cdf_meaning = "MDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET mdoc_cd = code_value
 SET code_set = 53
 SET cdf_meaning = "DATE"
 EXECUTE cpm_get_cd_for_cdf
 SET date_cd = code_value
 SET code_set = 53
 SET cdf_meaning = "MED"
 EXECUTE cpm_get_cd_for_cdf
 SET med_cd = code_value
 SET code_set = 54
 SET cdf_meaning = "ML"
 EXECUTE cpm_get_cd_for_cdf
 SET ml_cd = code_value
 SET code_set = 54
 SET cdf_meaning = "CC"
 EXECUTE cpm_get_cd_for_cdf
 SET cc_cd = code_value
 SET code_set = 6004
 SET cdf_meaning = "ORDERED"
 EXECUTE cpm_get_cd_for_cdf
 SET ordered_cd = code_value
 SET code_set = 6004
 SET cdf_meaning = "INPROCESS"
 EXECUTE cpm_get_cd_for_cdf
 SET inproc_cd = code_value
 SET code_set = 6004
 SET cdf_meaning = "PENDING REV"
 EXECUTE cpm_get_cd_for_cdf
 SET pendrev_cd = code_value
 SET code_set = 12025
 SET cdf_meaning = "CANCELED"
 EXECUTE cpm_get_cd_for_cdf
 SET canceled_cd = code_value
 SET code_set = 8
 SET cdf_meaning = "INERROR"
 EXECUTE cpm_get_cd_for_cdf
 SET inerror_cd = code_value
 SET code_set = 120
 SET cdf_meaning = "OCFCOMP"
 EXECUTE cpm_get_cd_for_cdf
 SET ocfcomp_cd = code_value
 SET code_set = 6016
 SET cdf_meaning = "VIEWORDER"
 EXECUTE cpm_get_cd_for_cdf
 SET vieworders_cd = code_value
 SET code_set = 6016
 SET cdf_meaning = "VIEWRSLTS"
 EXECUTE cpm_get_cd_for_cdf
 SET viewresults_cd = code_value
 SET code_set = 6017
 SET cdf_meaning = "EXCLUDE"
 EXECUTE cpm_get_cd_for_cdf
 SET exclude_cd = code_value
 SET code_set = 6017
 SET cdf_meaning = "INCLUDE"
 EXECUTE cpm_get_cd_for_cdf
 SET include_cd = code_value
 SET code_set = 6017
 SET cdf_meaning = "NO"
 EXECUTE cpm_get_cd_for_cdf
 SET no_cd = code_value
 SET code_set = 6017
 SET cdf_meaning = "YES"
 EXECUTE cpm_get_cd_for_cdf
 SET yes_cd = code_value
 SET code_set = 104
 SET cdf_meaning = "PALMREPORT"
 EXECUTE cpm_get_cd_for_cdf
 SET ppa_type_cd = code_value
 SET code_set = 14122
 SET cdf_meaning = "POWERCHART"
 EXECUTE cpm_get_cd_for_cdf
 SET sticky_note_type_cd = code_value
 SET code_set = 52
 SET cdf_meaning = "CRITICAL"
 EXECUTE cpm_get_cd_for_cdf
 SET critical_cd = code_value
 SET code_set = 52
 SET cdf_meaning = "EXTREMEHIGH"
 EXECUTE cpm_get_cd_for_cdf
 SET extremehi_cd = code_value
 SET code_set = 52
 SET cdf_meaning = "EXTREMELOW"
 EXECUTE cpm_get_cd_for_cdf
 SET extremelo_cd = code_value
 SET code_set = 52
 SET cdf_meaning = "PANICHIGH"
 EXECUTE cpm_get_cd_for_cdf
 SET panichi_cd = code_value
 SET code_set = 52
 SET cdf_meaning = "PANICLOW"
 EXECUTE cpm_get_cd_for_cdf
 SET paniclo_cd = code_value
 SET code_set = 52
 SET cdf_meaning = "VABNORMAL"
 EXECUTE cpm_get_cd_for_cdf
 SET vabnormal_cd = code_value
 SET code_set = 52
 SET cdf_meaning = "POSITIVE"
 EXECUTE cpm_get_cd_for_cdf
 SET positive_cd = code_value
 SET vieworder_secur_id = 0
 SET viewresult_secur_id = 0
 SET vieworder_secur_cd = 0
 SET viewresult_secur_cd = 0
 SELECT INTO "nl:"
  FROM priv_loc_reltn plr,
   privilege p
  PLAN (plr
   WHERE (plr.position_cd=reqinfo->position_cd))
   JOIN (p
   WHERE p.priv_loc_reltn_id=plr.priv_loc_reltn_id
    AND p.privilege_cd IN (vieworders_cd, viewresults_cd)
    AND p.priv_value_cd != yes_cd)
  DETAIL
   IF (p.privilege_cd=vieworders_cd)
    vieworder_secur_cd = p.priv_value_cd, vieworder_secur_id = p.privilege_id
   ELSEIF (p.privilege_cd=viewresults_cd)
    viewresult_secur_cd = p.priv_value_cd, viewresult_secur_id = p.privilege_id
   ENDIF
  WITH nocounter
 ;end select
 IF (vieworder_secur_cd=no_cd)
  SET pending_order_ind = 0
  SET active_order_ind = 0
  SET med_order_ind = 0
 ENDIF
 IF (viewresult_secur_cd=no_cd)
  SET lab_result_ind = 0
  SET nurse_result_ind = 0
  SET radiology_ind = 0
  SET progress_note_ind = 0
  SET documents_ind = 0
  SET vitals_ind = 0
 ENDIF
 IF (patient_cnt > 0)
  SELECT INTO "nl:"
   dob_null = nullind(p.birth_dt_tm), deceased_null = nullind(p.deceased_dt_tm)
   FROM (dummyt d  WITH seq = value(patient_cnt)),
    person p,
    encounter e
   PLAN (d)
    JOIN (e
    WHERE (e.encntr_id=temp->patient[d.seq].demographics.primary_encntr_id))
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.name_full_formatted > " ")
   HEAD REPORT
    tempsex = fillstring(12," "), tempage = fillstring(20," ")
   DETAIL
    temp->patient[d.seq].demographics.person_id = e.person_id, temp->patient[d.seq].demographics.
    name_full_formatted = p.name_full_formatted, tempsex = trim(uar_get_code_display(p.sex_cd)),
    temp->patient[d.seq].demographics.gender = substring(1,1,tempsex)
    IF (dob_null=0
     AND p.birth_dt_tm > 0)
     IF (deceased_null=0
      AND p.deceased_dt_tm > 0)
      tempage = trim(cnvtage(cnvtdate2(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),"mm/dd/yyyy"),cnvtint(
         format(p.birth_dt_tm,"hhmm;;m")),cnvtdate2(format(p.deceased_dt_tm,"mm/dd/yyyy;;d"),
         "mm/dd/yyyy"),cnvtint(format(p.deceased_dt_tm,"hhmm;;m"))))
     ELSE
      tempage = trim(cnvtage(cnvtdate2(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),"mm/dd/yyyy"),cnvtint(
         format(p.birth_dt_tm,"hhmm;;m"))))
     ENDIF
    ELSE
     temp->patient[d.seq].demographics.age = " "
    ENDIF
    IF (tempage > " ")
     a = findstring(" ",tempage,3)
     IF (a > 3)
      temp->patient[d.seq].demographics.age = trim(build(substring(1,(a - 1),tempage),substring((a+ 1
         ),1,tempage)))
     ELSE
      temp->patient[d.seq].demographics.age = tempage
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET max_enc_cnt = 0
 SET encntr_org_sec_ind = 0
 SET confid_ind = 0
 SET count = 0
 RECORD temp1(
   1 org_cnt = i2
   1 orglist[*]
     2 org_id = f8
     2 confid_level = i4
 )
 SELECT INTO "nl:"
  FROM dm_info di
  PLAN (di
   WHERE di.info_domain="SECURITY"
    AND di.info_name IN ("SEC_ORG_RELTN", "SEC_CONFID"))
  DETAIL
   IF (di.info_name="SEC_ORG_RELTN"
    AND di.info_number=1)
    encntr_org_sec_ind = 1
   ELSEIF (di.info_name="SEC_CONFID"
    AND di.info_number=1)
    confid_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (((encntr_org_sec_ind=1) OR (confid_ind=1)) )
  DECLARE col_seq = i4
  SET col_seq = 0
  SET temp1->org_cnt = 0
  SELECT INTO "nl:"
   FROM prsnl_org_reltn por
   WHERE (por.person_id=reqinfo->updt_id)
   HEAD REPORT
    count = 0
   DETAIL
    count = (count+ 1), stat = alterlist(temp1->orglist,count), temp1->orglist[count].org_id = por
    .organization_id,
    col_seq = uar_get_collation_seq(por.confid_level_cd)
    IF (col_seq > 0)
     temp1->orglist[count].confid_level = col_seq
    ELSE
     temp1->orglist[count].confid_level = 0
    ENDIF
   FOOT REPORT
    temp1->org_cnt = count
   WITH nocounter
  ;end select
  IF (count > 0)
   SELECT INTO "nl:"
    e.person_id
    FROM (dummyt d  WITH seq = value(patient_cnt)),
     encounter e
    PLAN (d)
     JOIN (e
     WHERE (e.person_id=temp->patient[d.seq].demographics.person_id)
      AND e.active_ind=1)
    HEAD d.seq
     count1 = 0
    DETAIL
     FOR (x = 1 TO temp1->org_cnt)
       IF ((temp1->orglist[x].org_id=e.organization_id))
        IF (((confid_ind=1
         AND (uar_get_collation_seq(e.confid_level_cd) <= temp1->orglist[x].confid_level)) OR (
        confid_ind=0)) )
         count1 = (count1+ 1), stat = alterlist(temp->patient[d.seq].encntr,count1), temp->patient[d
         .seq].encntr[count1].encntr_id = e.encntr_id
        ENDIF
        x = temp1->org_cnt
       ENDIF
     ENDFOR
    FOOT  d.seq
     temp->patient[d.seq].encntr_cnt = count1
     IF (count1 > max_enc_cnt)
      max_enc_cnt = count1
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  SELECT INTO "nl:"
   e.person_id
   FROM (dummyt d  WITH seq = value(patient_cnt)),
    encounter e
   PLAN (d)
    JOIN (e
    WHERE (e.person_id=temp->patient[d.seq].demographics.person_id)
     AND e.active_ind=1)
   HEAD d.seq
    count1 = 0, pri_found = 0
   DETAIL
    count1 = (count1+ 1), stat = alterlist(temp->patient[d.seq].encntr,count1), temp->patient[d.seq].
    encntr[count1].encntr_id = e.encntr_id
    IF ((e.encntr_id=temp->patient[d.seq].demographics.primary_encntr_id))
     pri_found = 1
    ENDIF
   FOOT  d.seq
    IF (pri_found=0)
     count1 = (count1+ 1), stat = alterlist(temp->patient[d.seq].encntr,count1), temp->patient[d.seq]
     .encntr[count1].encntr_id = temp->patient[d.seq].demographics.primary_encntr_id
    ENDIF
    temp->patient[d.seq].encntr_cnt = count1
    IF (count1 > max_enc_cnt)
     max_enc_cnt = count1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 FOR (x = 1 TO patient_cnt)
   IF ((temp->patient[x].encntr_cnt > 0))
    SET cnt = cnt
   ELSE
    SET temp->patient[x].encntr_cnt = 1
    SET stat = alterlist(temp->patient[x].encntr,1)
    SET temp->patient[x].encntr[1].encntr_id = temp->patient[x].demographics.primary_encntr_id
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(patient_cnt)),
   person_alias pa
  PLAN (d)
   JOIN (pa
   WHERE (pa.person_id=temp->patient[d.seq].demographics.person_id)
    AND pa.person_alias_type_cd=mrn_alias_cd
    AND pa.active_ind=1)
  DETAIL
   temp->patient[d.seq].demographics.mrn = trim(cnvtalias(pa.alias,pa.alias_pool_cd))
  WITH nocounter
 ;end select
 CALL echo(build("Primary Encntr_id = ",temp->patient[1].demographics.primary_encntr_id))
 SELECT INTO "nl:"
  disch_null = nullind(e.disch_dt_tm), reg_null = nullind(e.reg_dt_tm), facil = trim(
   uar_get_code_display(e.loc_facility_cd))
  FROM (dummyt d  WITH seq = value(patient_cnt)),
   encounter e
  PLAN (d)
   JOIN (e
   WHERE (e.encntr_id=temp->patient[d.seq].demographics.primary_encntr_id))
  HEAD REPORT
   temproom = fillstring(12," "), tempbed = fillstring(12," "), a = 0
  DETAIL
   temp->patient[d.seq].demographics.facility = trim(uar_get_code_display(e.loc_facility_cd)), temp->
   patient[d.seq].demographics.nurse_unit = trim(uar_get_code_display(e.loc_nurse_unit_cd)), temp->
   patient[d.seq].demographics.room = trim(uar_get_code_display(e.loc_room_cd)),
   temp->patient[d.seq].demographics.bed = trim(uar_get_code_display(e.loc_bed_cd)), temproom =
   uar_get_code_display(e.loc_room_cd), tempbed = uar_get_code_display(e.loc_bed_cd)
   IF (temproom > " ")
    IF (tempbed > " ")
     temp->patient[d.seq].demographics.room_bed = build(temproom,".",tempbed)
    ELSE
     temp->patient[d.seq].demographics.room_bed = trim(temproom)
    ENDIF
   ENDIF
   temp->patient[d.seq].demographics.reason_for_visit = e.reason_for_visit,
   CALL echo(build("Reason for Visit = ",temp->patient[d.seq].demographics.reason_for_visit))
   IF (reg_null=0)
    IF (disch_null=0)
     tempday = datetimediff(e.disch_dt_tm,e.reg_dt_tm), temp->patient[d.seq].demographics.dayofstay
      = format(tempday,"###.#")
    ELSE
     tempday = datetimediff(cnvtdatetime(curdate,curtime3),e.reg_dt_tm), temp->patient[d.seq].
     demographics.dayofstay = format(tempday,"###.#")
    ENDIF
   ELSE
    temp->patient[d.seq].demographics.dayofstay = " "
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(patient_cnt)),
   encntr_prsnl_reltn epr,
   prsnl p
  PLAN (d)
   JOIN (epr
   WHERE (epr.encntr_id=temp->patient[d.seq].demographics.primary_encntr_id)
    AND epr.active_ind=1
    AND epr.expiration_ind != 1
    AND epr.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
    AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (p
   WHERE p.person_id=epr.prsnl_person_id)
  DETAIL
   IF (epr.encntr_prsnl_r_cd=refer_cd)
    IF (p.name_full_formatted > " ")
     temp->patient[d.seq].demographics.referring_doc = substring(1,30,p.name_full_formatted)
    ELSE
     temp->patient[d.seq].demographics.referring_doc = epr.ft_prsnl_name
    ENDIF
   ELSEIF (epr.encntr_prsnl_r_cd=attend_cd)
    IF (p.name_full_formatted > " ")
     temp->patient[d.seq].demographics.attending_doc = substring(1,30,p.name_full_formatted)
    ELSE
     temp->patient[d.seq].demographics.attending_doc = epr.ft_prsnl_name
    ENDIF
   ELSEIF (epr.encntr_prsnl_r_cd=admit_cd)
    IF (p.name_full_formatted > " ")
     temp->patient[d.seq].demographics.admitting_doc = substring(1,30,p.name_full_formatted)
    ELSE
     temp->patient[d.seq].demographics.admitting_doc = epr.ft_prsnl_name
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(patient_cnt)),
   phone ph
  PLAN (d)
   JOIN (ph
   WHERE ph.parent_entity_name="PERSON"
    AND (ph.parent_entity_id=temp->patient[d.seq].demographics.person_id)
    AND ph.phone_type_cd=home_phone_cd
    AND ph.active_ind=1
    AND ph.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
    AND ph.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
  HEAD REPORT
   tempphone = fillstring(22," "), fmtphone = fillstring(22," ")
  DETAIL
   tempphone = fillstring(22," "), tempphone = cnvtalphanum(ph.phone_num)
   IF (tempphone != ph.phone_num)
    fmtphone = ph.phone_num
   ELSE
    IF (ph.phone_format_cd > 0)
     fmtphone = cnvtphone(trim(ph.phone_num),ph.phone_format_cd)
    ELSEIF (size(tempphone) < 8)
     fmtphone = format(trim(ph.phone_num),"###-####")
    ELSE
     fmtphone = format(trim(ph.phone_num),"(###) ###-####")
    ENDIF
   ENDIF
   IF (fmtphone <= " ")
    fmtphone = ph.phone_num
   ENDIF
   IF (ph.extension > " ")
    fmtphone = concat(trim(fmtphone)," x",ph.extension)
   ENDIF
   temp->patient[d.seq].demographics.phone = fmtphone
  WITH nocounter
 ;end select
 CALL echo(build("Demog person id = ",temp->patient[1].demographics.person_id))
 CALL echo(build("Home Address Cd = ",home_address_cd))
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(patient_cnt)),
   address a
  PLAN (d)
   JOIN (a
   WHERE a.parent_entity_name="PERSON"
    AND (a.parent_entity_id=temp->patient[d.seq].demographics.person_id)
    AND a.address_type_cd=home_address_cd
    AND a.active_ind=1
    AND a.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
    AND a.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
  HEAD REPORT
   tempstate = fillstring(10," "), tempaddr = fillstring(100," ")
  DETAIL
   IF (a.state_cd > 0)
    tempstate = uar_get_code_display(a.state_cd)
   ELSE
    tempstate = a.state
   ENDIF
   tempaddr = concat(trim(a.street_addr2)," ",trim(a.street_addr3)," ",trim(a.street_addr4)), temp->
   patient[d.seq].demographics.address1 = trim(a.street_addr), temp->patient[d.seq].demographics.
   address2 = trim(tempaddr),
   temp->patient[d.seq].demographics.address3 = concat(trim(a.city),",",trim(tempstate)," ",trim(a
     .zipcode))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  checkp = decode(p.seq,1,0), checkph = decode(ph.seq,1,0)
  FROM (dummyt d  WITH seq = value(patient_cnt)),
   encntr_person_reltn epr,
   (dummyt d1  WITH seq = 1),
   person p,
   (dummyt d2  WITH seq = 1),
   phone ph
  PLAN (d)
   JOIN (epr
   WHERE (epr.encntr_id=temp->patient[d.seq].demographics.primary_encntr_id)
    AND epr.person_reltn_type_cd=emc_cd
    AND epr.active_ind=1
    AND epr.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
    AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (d1)
   JOIN (p
   WHERE p.person_id=epr.related_person_id)
   JOIN (d2)
   JOIN (ph
   WHERE ph.parent_entity_name="PERSON"
    AND ph.parent_entity_id=epr.related_person_id
    AND ph.phone_type_cd=home_phone_cd
    AND ph.active_ind=1
    AND ph.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
    AND ph.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
  HEAD REPORT
   tempemc = fillstring(25," "), tempphone = fillstring(22," "), fmtphone = fillstring(22," ")
  DETAIL
   IF (checkp=1)
    tempemc = p.name_full_formatted
   ELSE
    tempemc = epr.ft_rel_person_name
   ENDIF
   IF (checkph=1)
    tempphone = fillstring(22," "), tempphone = cnvtalphanum(ph.phone_num)
    IF (tempphone != ph.phone_num)
     fmtphone = ph.phone_num
    ELSE
     IF (ph.phone_format_cd > 0)
      fmtphone = cnvtphone(trim(ph.phone_num),ph.phone_format_cd)
     ELSEIF (size(tempphone) < 8)
      fmtphone = format(trim(ph.phone_num),"###-####")
     ELSE
      fmtphone = format(trim(ph.phone_num),"(###) ###-####")
     ENDIF
    ENDIF
    IF (fmtphone <= " ")
     fmtphone = ph.phone_num
    ENDIF
    IF (ph.extension > " ")
     fmtphone = concat(trim(fmtphone)," x",ph.extension)
    ENDIF
   ENDIF
   temp->patient[d.seq].demographics.emergency_contact = trim(tempemc), temp->patient[d.seq].
   demographics.emergency_contact_phone = trim(fmtphone)
  WITH nocounter, outerjoin = d1, outerjoin = d2
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(patient_cnt)),
   encntr_plan_reltn epr,
   organization o
  PLAN (d)
   JOIN (epr
   WHERE (epr.encntr_id=temp->patient[d.seq].demographics.primary_encntr_id)
    AND epr.priority_seq IN (1, 99)
    AND epr.active_ind=1
    AND epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (o
   WHERE o.organization_id=epr.organization_id)
  ORDER BY d.seq, epr.priority_seq DESC
  DETAIL
   temp->patient[d.seq].demographics.insurance = trim(o.org_name)
  WITH nocounter
 ;end select
 IF (pending_order_ind=1)
  SET ocnt = 0
  IF ((temp2->poct_cnt > 0))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(max_enc_cnt)),
     (dummyt d2  WITH seq = value(temp2->poct_cnt)),
     (dummyt d3  WITH seq = value(patient_cnt)),
     orders o
    PLAN (d3
     WHERE maxrec(d,temp->patient[d3.seq].encntr_cnt) > 0)
     JOIN (d)
     JOIN (d2)
     JOIN (o
     WHERE (o.encntr_id=temp->patient[d3.seq].encntr[d.seq].encntr_id)
      AND (o.person_id=temp->patient[d3.seq].demographics.person_id)
      AND (o.catalog_type_cd=temp2->poct[d2.seq].po_catalog_type)
      AND o.catalog_type_cd != pharmacy_cd
      AND o.order_status_cd IN (ordered_cd, pendrev_cd, inproc_cd)
      AND o.projected_stop_dt_tm < cnvtdatetime(curdate,curtime))
    ORDER BY o.person_id, d2.seq, o.hna_order_mnemonic
    HEAD o.person_id
     ocnt = 0
    DETAIL
     ocnt = (ocnt+ 1), stat = alterlist(temp->patient[d3.seq].pending_order,ocnt), temp->patient[d3
     .seq].pending_order[ocnt].order_id = o.order_id,
     temp->patient[d3.seq].pending_order[ocnt].encntr_id = o.encntr_id, temp->patient[d3.seq].
     pending_order[ocnt].catalog_cd = o.catalog_cd, temp->patient[d3.seq].pending_order[ocnt].
     catalog_type_cd = o.catalog_type_cd,
     temp->patient[d3.seq].pending_order[ocnt].activity_type_cd = o.activity_type_cd, temp->patient[
     d3.seq].pending_order[ocnt].mnemonic = trim(o.hna_order_mnemonic), temp->patient[d3.seq].
     pending_order[ocnt].display_line = trim(o.clinical_display_line)
    FOOT  o.person_id
     temp->patient[d3.seq].po_cnt = ocnt
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(max_enc_cnt)),
     (dummyt d3  WITH seq = value(patient_cnt)),
     orders o
    PLAN (d3
     WHERE maxrec(d,temp->patient[d3.seq].encntr_cnt) > 0)
     JOIN (d)
     JOIN (o
     WHERE (o.encntr_id=temp->patient[d3.seq].encntr[d.seq].encntr_id)
      AND (o.person_id=temp->patient[d3.seq].demographics.person_id)
      AND o.catalog_type_cd != pharmacy_cd
      AND o.catalog_type_cd != nurs_cd
      AND o.order_status_cd IN (ordered_cd, pendrev_cd, inproc_cd)
      AND o.projected_stop_dt_tm < cnvtdatetime(curdate,curtime))
    ORDER BY o.person_id, o.hna_order_mnemonic
    HEAD o.person_id
     ocnt = 0
    DETAIL
     ocnt = (ocnt+ 1), stat = alterlist(temp->patient[d3.seq].pending_order,ocnt), temp->patient[d3
     .seq].pending_order[ocnt].order_id = o.order_id,
     temp->patient[d3.seq].pending_order[ocnt].encntr_id = o.encntr_id, temp->patient[d3.seq].
     pending_order[ocnt].catalog_cd = o.catalog_cd, temp->patient[d3.seq].pending_order[ocnt].
     catalog_type_cd = o.catalog_type_cd,
     temp->patient[d3.seq].pending_order[ocnt].activity_type_cd = o.activity_type_cd, temp->patient[
     d3.seq].pending_order[ocnt].mnemonic = trim(o.hna_order_mnemonic), temp->patient[d3.seq].
     pending_order[ocnt].display_line = trim(o.clinical_display_line)
    FOOT  o.person_id
     temp->patient[d3.seq].po_cnt = ocnt
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (active_order_ind=1)
  SET ocnt = 0
  IF ((temp2->aoct_cnt > 0))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(max_enc_cnt)),
     (dummyt d2  WITH seq = value(temp2->aoct_cnt)),
     (dummyt d3  WITH seq = value(patient_cnt)),
     orders o
    PLAN (d3
     WHERE maxrec(d,temp->patient[d3.seq].encntr_cnt) > 0)
     JOIN (d)
     JOIN (d2)
     JOIN (o
     WHERE (o.encntr_id=temp->patient[d3.seq].encntr[d.seq].encntr_id)
      AND (o.person_id=temp->patient[d3.seq].demographics.person_id)
      AND (o.catalog_type_cd=temp2->aoct[d2.seq].ao_catalog_type)
      AND o.order_status_cd IN (ordered_cd, pendrev_cd, inproc_cd)
      AND ((o.projected_stop_dt_tm > cnvtdatetime(curdate,curtime)) OR (nullind(o
      .projected_stop_dt_tm)=1)) )
    ORDER BY o.person_id, d2.seq, o.hna_order_mnemonic
    HEAD o.person_id
     ocnt = 0
    DETAIL
     ocnt = (ocnt+ 1), stat = alterlist(temp->patient[d3.seq].active_order,ocnt), temp->patient[d3
     .seq].active_order[ocnt].order_id = o.order_id,
     temp->patient[d3.seq].active_order[ocnt].encntr_id = o.encntr_id, temp->patient[d3.seq].
     active_order[ocnt].catalog_cd = o.catalog_cd, temp->patient[d3.seq].active_order[ocnt].
     catalog_type_cd = o.catalog_type_cd,
     temp->patient[d3.seq].active_order[ocnt].activity_type_cd = o.activity_type_cd, temp->patient[d3
     .seq].active_order[ocnt].mnemonic = trim(o.hna_order_mnemonic), temp->patient[d3.seq].
     active_order[ocnt].display_line = trim(o.clinical_display_line)
    FOOT  o.person_id
     temp->patient[d3.seq].ao_cnt = ocnt
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(max_enc_cnt)),
     (dummyt d3  WITH seq = value(patient_cnt)),
     orders o
    PLAN (d3
     WHERE maxrec(d,temp->patient[d3.seq].encntr_cnt) > 0)
     JOIN (d)
     JOIN (o
     WHERE (o.encntr_id=temp->patient[d3.seq].encntr[d.seq].encntr_id)
      AND (o.person_id=temp->patient[d3.seq].demographics.person_id)
      AND o.catalog_type_cd != pharmacy_cd
      AND o.catalog_type_cd != nurs_cd
      AND o.order_status_cd IN (ordered_cd, pendrev_cd, inproc_cd)
      AND ((o.projected_stop_dt_tm > cnvtdatetime(curdate,curtime)) OR (nullind(o
      .projected_stop_dt_tm)=1)) )
    ORDER BY o.person_id, o.hna_order_mnemonic
    HEAD o.person_id
     ocnt = 0
    DETAIL
     ocnt = (ocnt+ 1), stat = alterlist(temp->patient[d3.seq].active_order,ocnt), temp->patient[d3
     .seq].active_order[ocnt].order_id = o.order_id,
     temp->patient[d3.seq].active_order[ocnt].encntr_id = o.encntr_id, temp->patient[d3.seq].
     active_order[ocnt].catalog_cd = o.catalog_cd, temp->patient[d3.seq].active_order[ocnt].
     catalog_type_cd = o.catalog_type_cd,
     temp->patient[d3.seq].active_order[ocnt].activity_type_cd = o.activity_type_cd, temp->patient[d3
     .seq].active_order[ocnt].mnemonic = trim(o.hna_order_mnemonic), temp->patient[d3.seq].
     active_order[ocnt].display_line = trim(o.clinical_display_line)
    FOOT  o.person_id
     temp->patient[d3.seq].ao_cnt = ocnt
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (med_order_ind=1)
  SET ocnt = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(max_enc_cnt)),
    (dummyt d3  WITH seq = value(patient_cnt)),
    orders o,
    order_detail od
   PLAN (d3
    WHERE maxrec(d,temp->patient[d3.seq].encntr_cnt) > 0)
    JOIN (d)
    JOIN (o
    WHERE (o.encntr_id=temp->patient[d3.seq].encntr[d.seq].encntr_id)
     AND (o.person_id=temp->patient[d3.seq].demographics.person_id)
     AND o.catalog_type_cd=pharmacy_cd
     AND o.order_status_cd IN (ordered_cd, pendrev_cd, inproc_cd)
     AND o.template_order_flag IN (0, 1))
    JOIN (od
    WHERE od.order_id=o.order_id
     AND od.oe_field_meaning IN ("FREQ", "FREETXTDOSE", "STRENGTHDOSE", "STRENGTHDOSEUNIT", "RXROUTE"
    ))
   ORDER BY o.person_id, o.hna_order_mnemonic, o.order_id,
    od.action_sequence
   HEAD o.person_id
    ocnt = 0
   HEAD o.order_id
    ocnt = (ocnt+ 1), stat = alterlist(temp->patient[d3.seq].med_order,ocnt), temp->patient[d3.seq].
    med_order[ocnt].order_id = o.order_id,
    temp->patient[d3.seq].med_order[ocnt].encntr_id = o.encntr_id, temp->patient[d3.seq].med_order[
    ocnt].catalog_cd = o.catalog_cd, temp->patient[d3.seq].med_order[ocnt].catalog_type_cd = o
    .catalog_type_cd,
    temp->patient[d3.seq].med_order[ocnt].activity_type_cd = o.activity_type_cd, temp->patient[d3.seq
    ].med_order[ocnt].mnemonic = trim(o.hna_order_mnemonic), temp->patient[d3.seq].med_order[ocnt].
    display_line = trim(o.clinical_display_line),
    temp->patient[d3.seq].med_order[ocnt].iv_ind = o.iv_ind, temp->patient[d3.seq].med_order[ocnt].
    prn_ind = o.prn_ind
    IF (o.cki="MUL.ORD!*")
     temp->patient[d3.seq].med_order[ocnt].dnum = trim(substring(9,25,o.cki))
    ELSE
     temp->patient[d3.seq].med_order[ocnt].dnum = " "
    ENDIF
   DETAIL
    IF (od.oe_field_meaning="FREQ")
     temp->patient[d3.seq].med_order[ocnt].frequency = od.oe_field_display_value
    ELSEIF (((od.oe_field_meaning="FREETXTDOSE") OR (od.oe_field_meaning="STRENGTHDOSE")) )
     temp->patient[d3.seq].med_order[ocnt].dose = od.oe_field_display_value
    ELSEIF (od.oe_field_meaning="STRENGTHDOSEUNIT")
     temp->patient[d3.seq].med_order[ocnt].doseunit = od.oe_field_display_value
    ELSEIF (od.oe_field_meaning="RXROUTE")
     temp->patient[d3.seq].med_order[ocnt].route = od.oe_field_display_value
    ENDIF
   FOOT  o.order_id
    IF ((temp->patient[d3.seq].med_order[ocnt].dose > " ")
     AND (temp->patient[d3.seq].med_order[ocnt].doseunit > " "))
     temp->patient[d3.seq].med_order[ocnt].dose = concat(trim(temp->patient[d3.seq].med_order[ocnt].
       dose),trim(temp->patient[d3.seq].med_order[ocnt].doseunit))
    ENDIF
   FOOT  o.person_id
    temp->patient[d3.seq].mo_cnt = ocnt
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  checkn = decode(n.seq,1,0)
  FROM (dummyt d  WITH seq = value(patient_cnt)),
   allergy a,
   nomenclature n
  PLAN (d)
   JOIN (a
   WHERE (a.person_id=temp->patient[d.seq].demographics.person_id)
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (a.end_effective_dt_tm=null))
    AND a.reaction_status_cd != canceled_cd)
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(a.substance_nom_id))
  ORDER BY d.seq, a.onset_dt_tm
  HEAD d.seq
   tempall = fillstring(100," ")
  DETAIL
   IF (checkn=1)
    tempall = n.source_string
   ELSE
    tempall = a.substance_ftdesc
   ENDIF
   IF ((temp->patient[d.seq].demographics.allergies > " "))
    temp->patient[d.seq].demographics.allergies = concat(temp->patient[d.seq].demographics.allergies,
     ",",tempall)
   ELSE
    temp->patient[d.seq].demographics.allergies = tempall
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  checkn = decode(n.seq,1,0)
  FROM (dummyt d  WITH seq = value(patient_cnt)),
   problem p,
   nomenclature n
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=temp->patient[d.seq].demographics.person_id)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (p.end_effective_dt_tm=null)) )
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(p.nomenclature_id))
  ORDER BY d.seq, p.onset_dt_tm
  HEAD d.seq
   tempprob = fillstring(100," ")
  DETAIL
   IF (checkn=1)
    tempprob = n.source_string
   ELSE
    tempprob = p.problem_ftdesc
   ENDIF
   IF ((temp->patient[d.seq].demographics.problems > " "))
    temp->patient[d.seq].demographics.problems = concat(temp->patient[d.seq].demographics.problems,
     ",",tempprob)
   ELSE
    temp->patient[d.seq].demographics.problems = tempprob
   ENDIF
  WITH nocounter
 ;end select
 SET checklt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(patient_cnt)),
   sticky_note sn,
   long_text lt
  PLAN (d)
   JOIN (sn
   WHERE sn.sticky_note_type_cd=sticky_note_type_cd
    AND (sn.parent_entity_id=temp->patient[d.seq].demographics.person_id)
    AND sn.parent_entity_name="PERSON"
    AND sn.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND sn.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
    AND sn.parent_entity_id != 0)
   JOIN (lt
   WHERE lt.long_text_id=outerjoin(sn.long_text_id)
    AND lt.long_text_id != outerjoin(0))
  ORDER BY d.seq, sn.updt_dt_tm
  HEAD d.seq
   note_cnt = 0
  DETAIL
   note_cnt = (note_cnt+ 1), stat = alterlist(temp->patient[d.seq].sticky_note,note_cnt), checklt =
   sn.long_text_id
   IF (checklt > 0)
    temp->patient[d.seq].sticky_note[note_cnt].note = lt.long_text,
    CALL echo(build("Long Note Text = ",temp->patient[d.seq].sticky_note[note_cnt].note))
   ELSE
    temp->patient[d.seq].sticky_note[note_cnt].note = sn.sticky_note_text,
    CALL echo(build("Sticky Note Text = ",temp->patient[d.seq].sticky_note[note_cnt].note))
   ENDIF
  FOOT  d.seq
   temp->patient[d.seq].sn_cnt = note_cnt
  WITH nocounter
 ;end select
 IF (lab_result_ind=1
  AND (temp2->lrec_cnt=0))
  SET lcnt = 0
  SELECT INTO "nl:"
   notefound = decode(lb.seq,1,0), tl = textlen(lb.long_blob)
   FROM (dummyt d  WITH seq = value(max_enc_cnt)),
    (dummyt d3  WITH seq = value(patient_cnt)),
    orders o,
    clinical_event ce,
    (dummyt d2  WITH seq = 1),
    ce_event_note cen,
    long_blob lb
   PLAN (d3
    WHERE maxrec(d,temp->patient[d3.seq].encntr_cnt) > 0)
    JOIN (d)
    JOIN (o
    WHERE (o.encntr_id=temp->patient[d3.seq].encntr[d.seq].encntr_id)
     AND (o.person_id=temp->patient[d3.seq].demographics.person_id)
     AND o.catalog_type_cd=lab_cd
     AND o.activity_type_cd=genlab_cd
     AND o.template_order_flag IN (0, 2))
    JOIN (ce
    WHERE ce.order_id=o.order_id
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.updt_dt_tm >= cnvtdatetime(beg_dt_tm)
     AND ce.updt_dt_tm <= cnvtdatetime(end_dt_tm)
     AND ce.result_status_cd != inerror_cd
     AND ce.event_class_cd != doc_cd
     AND ce.event_class_cd != mdoc_cd)
    JOIN (d2)
    JOIN (cen
    WHERE ce.event_id=cen.event_id)
    JOIN (lb
    WHERE lb.parent_entity_id=cen.ce_event_note_id
     AND lb.parent_entity_name="CE_EVENT_NOTE")
   ORDER BY o.person_id, o.hna_order_mnemonic, cnvtdatetime(ce.event_end_dt_tm) DESC
   HEAD o.person_id
    lcnt = 0, dcnt = 0
   HEAD ce.event_end_dt_tm
    first_dt_grp_lr_knt = 0, dcnt = (dcnt+ 1), stat = alterlist(temp->patient[d3.seq].
     lab_result_dt_grp,dcnt)
   DETAIL
    lcnt = (lcnt+ 1)
    IF (first_lr_knt < 1)
     first_dt_grp_lr_knt = lcnt
    ENDIF
    stat = alterlist(temp->patient[d3.seq].lab_result,lcnt), temp->patient[d3.seq].lab_result[lcnt].
    lab_result_dt_grp_id = dcnt, temp->patient[d3.seq].lab_result[lcnt].event_cd = ce.event_cd,
    temp->patient[d3.seq].lab_result[lcnt].event_name = trim(uar_get_code_display(ce.event_cd)), temp
    ->patient[d3.seq].lab_result[lcnt].normalcy_disp = substring(1,1,trim(uar_get_code_display(ce
       .normalcy_cd)))
    IF (ce.event_class_cd IN (txt_cd, num_cd, date_cd))
     IF (((ce.normalcy_cd=critical_cd) OR (((ce.normalcy_cd=extremehi_cd) OR (((ce.normalcy_cd=
     extremelo_cd) OR (((ce.normalcy_cd=panichi_cd) OR (((ce.normalcy_cd=paniclo_cd) OR (((ce
     .normalcy_cd=vabnormal_cd) OR (ce.normalcy_cd=positive_cd)) )) )) )) )) )) )
      temp->patient[d3.seq].lab_result[lcnt].result_value = concat(trim(ce.event_tag)," ",temp->
       patient[d3.seq].lab_result[lcnt].normalcy_disp)
     ELSE
      temp->patient[d3.seq].lab_result[lcnt].result_value = trim(ce.event_tag)
     ENDIF
    ELSE
     temp->patient[d3.seq].lab_result[lcnt].result_value = "See PowerChart"
    ENDIF
    temp->patient[d3.seq].lab_result[lcnt].order_id = ce.order_id, temp->patient[d3.seq].lab_result[
    lcnt].verify_dt_tm = format(ce.verified_dt_tm,"mm/dd hh:mm;;d"), temp->patient[d3.seq].
    lab_result[lcnt].event_end_dt_tm = format(ce.event_end_dt_tm,"mm/dd hh:mm;;d"),
    temp->patient[d3.seq].lab_result[lcnt].lab_result_dt_grp_id = dcnt, temp->patient[d3.seq].
    lab_result[lcnt].ref_range = concat("( ",trim(ce.normal_low)," - ",trim(ce.normal_high)," )")
    IF (notefound=1)
     IF (cen.compression_cd=ocfcomp_cd)
      blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," "), blob_out3 = fillstring(
       32000," "),
      blob_ret_len = 0,
      CALL uar_ocf_uncompress(lb.long_blob,tl,blob_out,32000,blob_ret_len)
     ELSE
      blob_out = fillstring(32000," "), y1 = size(trim(lb.long_blob)), blob_out = substring(1,(y1 - 8
       ),lb.long_blob)
     ENDIF
     CALL uar_rtf2(blob_out,textlen(blob_out),blob_out2,32000,32000,0), blob_out = blob_out2, temp->
     patient[d3.seq].lab_result[lcnt].note = blob_out
    ENDIF
   FOOT  ce.event_end_dt_tm
    temp->patient[d3.seq].lab_result_dt_grp[dcnt].lab_result_last_idx = lcnt, temp->patient[d3.seq].
    lab_result_dt_grp[dcnt].lab_result_first_idx = first_dt_grp_lr_knt
   FOOT  o.person_id
    temp->patient[d3.seq].lr_cnt = lcnt
   WITH nocounter, memsort, outerjoin = d2
  ;end select
 ENDIF
 IF (lab_result_ind=1
  AND (temp2->lrec_cnt > 0))
  SET lcnt = 0
  SELECT INTO "nl:"
   notefound = decode(lb.seq,1,0), tl = textlen(lb.long_blob)
   FROM (dummyt d  WITH seq = value(max_enc_cnt)),
    (dummyt d2  WITH seq = value(temp2->lrec_cnt)),
    (dummyt d3  WITH seq = value(patient_cnt)),
    clinical_event ce,
    (dummyt d4  WITH seq = 1),
    ce_event_note cen,
    long_blob lb
   PLAN (d3
    WHERE maxrec(d,temp->patient[d3.seq].encntr_cnt) > 0)
    JOIN (ce
    WHERE (ce.person_id=temp->patient[d3.seq].demographics.person_id)
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.updt_dt_tm >= cnvtdatetime(beg_dt_tm)
     AND ce.updt_dt_tm <= cnvtdatetime(end_dt_tm)
     AND ce.result_status_cd != inerror_cd
     AND ce.event_class_cd != doc_cd
     AND ce.event_class_cd != mdoc_cd)
    JOIN (d
    WHERE (ce.encntr_id=temp->patient[d3.seq].encntr[d.seq].encntr_id))
    JOIN (d2
    WHERE (ce.event_cd=temp2->lrec[d2.seq].lr_event_cd))
    JOIN (d4)
    JOIN (cen
    WHERE ce.event_id=cen.event_id)
    JOIN (lb
    WHERE lb.parent_entity_id=cen.ce_event_note_id
     AND lb.parent_entity_name="CE_EVENT_NOTE")
   ORDER BY ce.person_id, cnvtdatetime(ce.event_end_dt_tm) DESC, d2.seq
   HEAD ce.person_id
    lcnt = 0
   DETAIL
    lcnt = (lcnt+ 1), stat = alterlist(temp->patient[d3.seq].lab_result,lcnt), temp->patient[d3.seq].
    lab_result[lcnt].event_cd = ce.event_cd,
    temp->patient[d3.seq].lab_result[lcnt].event_name = trim(uar_get_code_display(ce.event_cd)), temp
    ->patient[d3.seq].lab_result[lcnt].normalcy_disp = substring(1,1,trim(uar_get_code_display(ce
       .normalcy_cd)))
    IF (ce.event_class_cd IN (txt_cd, num_cd, date_cd))
     IF (((ce.normalcy_cd=critical_cd) OR (((ce.normalcy_cd=extremehi_cd) OR (((ce.normalcy_cd=
     extremelo_cd) OR (((ce.normalcy_cd=panichi_cd) OR (((ce.normalcy_cd=paniclo_cd) OR (((ce
     .normalcy_cd=vabnormal_cd) OR (ce.normalcy_cd=positive_cd)) )) )) )) )) )) )
      temp->patient[d3.seq].lab_result[lcnt].result_value = concat(trim(ce.event_tag)," ",temp->
       patient[d3.seq].lab_result[lcnt].normalcy_disp)
     ELSE
      temp->patient[d3.seq].lab_result[lcnt].result_value = trim(ce.event_tag)
     ENDIF
    ELSE
     temp->patient[d3.seq].lab_result[lcnt].result_value = "See PowerChart"
    ENDIF
    temp->patient[d3.seq].lab_result[lcnt].order_id = ce.order_id, temp->patient[d3.seq].lab_result[
    lcnt].verify_dt_tm = format(ce.verified_dt_tm,"mm/dd hh:mm;;d"), temp->patient[d3.seq].
    lab_result[lcnt].event_end_dt_tm = format(ce.event_end_dt_tm,"mm/dd hh:mm;;d"),
    temp->patient[d3.seq].lab_result[lcnt].ref_range = concat("( ",trim(ce.normal_low)," - ",trim(ce
      .normal_high)," )")
    IF (notefound=1)
     IF (cen.compression_cd=ocfcomp_cd)
      blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," "), blob_out3 = fillstring(
       32000," "),
      blob_ret_len = 0,
      CALL uar_ocf_uncompress(lb.long_blob,tl,blob_out,32000,blob_ret_len)
     ELSE
      blob_out = fillstring(32000," "), y1 = size(trim(lb.long_blob)), blob_out = substring(1,(y1 - 8
       ),lb.long_blob)
     ENDIF
     CALL uar_rtf2(blob_out,textlen(blob_out),blob_out2,32000,32000,0), blob_out = blob_out2, temp->
     patient[d3.seq].lab_result[lcnt].note = blob_out
    ENDIF
   FOOT  ce.person_id
    temp->patient[d3.seq].lr_cnt = lcnt
   WITH nocounter, memsort, outerjoin = d4
  ;end select
 ENDIF
 IF (nurse_result_ind=1
  AND (temp2->nrec_cnt=0))
  SET ncnt = 0
  SELECT INTO "nl:"
   notefound = decode(lb.seq,1,0), tl = textlen(lb.long_blob)
   FROM (dummyt d  WITH seq = value(max_enc_cnt)),
    (dummyt d3  WITH seq = value(patient_cnt)),
    orders o,
    clinical_event ce,
    (dummyt d2  WITH seq = 1),
    ce_event_note cen,
    long_blob lb
   PLAN (d3
    WHERE maxrec(d,temp->patient[d3.seq].encntr_cnt) > 0)
    JOIN (d)
    JOIN (o
    WHERE (o.encntr_id=temp->patient[d3.seq].encntr[d.seq].encntr_id)
     AND (o.person_id=temp->patient[d3.seq].demographics.person_id)
     AND o.catalog_type_cd=nurs_cd
     AND o.template_order_flag IN (0, 2))
    JOIN (ce
    WHERE ce.order_id=o.order_id
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.updt_dt_tm >= cnvtdatetime(beg_dt_tm)
     AND ce.updt_dt_tm <= cnvtdatetime(end_dt_tm)
     AND ce.result_status_cd != inerror_cd
     AND ce.event_class_cd != doc_cd
     AND ce.event_class_cd != mdoc_cd)
    JOIN (d2)
    JOIN (cen
    WHERE ce.event_id=cen.event_id)
    JOIN (lb
    WHERE lb.parent_entity_id=cen.ce_event_note_id
     AND lb.parent_entity_name="CE_EVENT_NOTE")
   ORDER BY o.person_id, o.hna_order_mnemonic, cnvtdatetime(ce.event_end_dt_tm) DESC
   HEAD o.person_id
    ncnt = 0
   DETAIL
    ncnt = (ncnt+ 1), stat = alterlist(temp->patient[d3.seq].patient_care_result,ncnt), temp->
    patient[d3.seq].patient_care_result[ncnt].event_cd = ce.event_cd,
    temp->patient[d3.seq].patient_care_result[ncnt].event_name = trim(uar_get_code_display(ce
      .event_cd))
    IF (ce.event_class_cd IN (txt_cd, num_cd, date_cd))
     temp->patient[d3.seq].patient_care_result[ncnt].result_value = trim(ce.event_tag)
    ELSE
     temp->patient[d3.seq].patient_care_result[ncnt].result_value = "See PowerChart"
    ENDIF
    temp->patient[d3.seq].patient_care_result[ncnt].order_id = ce.order_id, temp->patient[d3.seq].
    patient_care_result[ncnt].verify_dt_tm = format(ce.verified_dt_tm,"mm/dd hh:mm;;d"), temp->
    patient[d3.seq].patient_care_result[ncnt].event_end_dt_tm = format(ce.event_end_dt_tm,
     "mm/dd hh:mm;;d"),
    temp->patient[d3.seq].patient_care_result[ncnt].normalcy_disp = trim(uar_get_code_display(ce
      .normalcy_cd)), temp->patient[d3.seq].lab_result[lcnt].ref_range = concat("( ",trim(ce
      .normal_low)," - ",trim(ce.normal_high)," )")
    IF (notefound=1)
     IF (cen.compression_cd=ocfcomp_cd)
      blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," "), blob_out3 = fillstring(
       32000," "),
      blob_ret_len = 0,
      CALL uar_ocf_uncompress(lb.long_blob,tl,blob_out,32000,blob_ret_len)
     ELSE
      blob_out = fillstring(32000," "), y1 = size(trim(lb.long_blob)), blob_out = substring(1,(y1 - 8
       ),lb.long_blob)
     ENDIF
     CALL uar_rtf2(blob_out,textlen(blob_out),blob_out2,32000,32000,0), blob_out = blob_out2, temp->
     patient[d3.seq].patient_care_result[ncnt].note = blob_out
    ENDIF
   FOOT  o.person_id
    temp->patient[d3.seq].pcr_cnt = ncnt
   WITH nocounter, memsort, outerjoin = d2
  ;end select
 ENDIF
 IF (nurse_result_ind=1
  AND (temp2->nrec_cnt > 0))
  SET ncnt = 0
  SELECT INTO "nl:"
   notefound = decode(lb.seq,1,0), tl = textlen(lb.long_blob)
   FROM (dummyt d  WITH seq = value(max_enc_cnt)),
    (dummyt d2  WITH seq = value(temp2->nrec_cnt)),
    (dummyt d3  WITH seq = value(patient_cnt)),
    clinical_event ce,
    (dummyt d4  WITH seq = 1),
    ce_event_note cen,
    long_blob lb
   PLAN (d3
    WHERE maxrec(d,temp->patient[d3.seq].encntr_cnt) > 0)
    JOIN (ce
    WHERE (ce.person_id=temp->patient[d3.seq].demographics.person_id)
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.updt_dt_tm >= cnvtdatetime(beg_dt_tm)
     AND ce.updt_dt_tm <= cnvtdatetime(end_dt_tm)
     AND ce.result_status_cd != inerror_cd
     AND ce.event_class_cd != doc_cd
     AND ce.event_class_cd != mdoc_cd)
    JOIN (d
    WHERE (ce.encntr_id=temp->patient[d3.seq].encntr[d.seq].encntr_id))
    JOIN (d2
    WHERE (ce.event_cd=temp2->nrec[d2.seq].nr_event_cd))
    JOIN (d4)
    JOIN (cen
    WHERE ce.event_id=cen.event_id)
    JOIN (lb
    WHERE lb.parent_entity_id=cen.ce_event_note_id
     AND lb.parent_entity_name="CE_EVENT_NOTE")
   ORDER BY ce.person_id, cnvtdatetime(ce.event_end_dt_tm) DESC, d2.seq
   HEAD ce.person_id
    ncnt = 0
   DETAIL
    ncnt = (ncnt+ 1), stat = alterlist(temp->patient[d3.seq].patient_care_result,ncnt), temp->
    patient[d3.seq].patient_care_result[ncnt].event_cd = ce.event_cd,
    temp->patient[d3.seq].patient_care_result[ncnt].event_name = trim(uar_get_code_display(ce
      .event_cd))
    IF (ce.event_class_cd IN (txt_cd, num_cd, date_cd))
     temp->patient[d3.seq].patient_care_result[ncnt].result_value = trim(ce.event_tag)
    ELSE
     temp->patient[d3.seq].patient_care_result[ncnt].result_value = "See PowerChart"
    ENDIF
    temp->patient[d3.seq].patient_care_result[ncnt].order_id = ce.order_id, temp->patient[d3.seq].
    patient_care_result[ncnt].verify_dt_tm = format(ce.verified_dt_tm,"mm/dd hh:mm;;d"), temp->
    patient[d3.seq].patient_care_result[ncnt].event_end_dt_tm = format(ce.event_end_dt_tm,
     "mm/dd hh:mm;;d"),
    temp->patient[d3.seq].patient_care_result[ncnt].normalcy_disp = trim(uar_get_code_display(ce
      .normalcy_cd)), temp->patient[d3.seq].lab_result[lcnt].ref_range = concat("( ",trim(ce
      .normal_low)," - ",trim(ce.normal_high)," )")
    IF (notefound=1)
     IF (cen.compression_cd=ocfcomp_cd)
      blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," "), blob_out3 = fillstring(
       32000," "),
      blob_ret_len = 0,
      CALL uar_ocf_uncompress(lb.long_blob,tl,blob_out,32000,blob_ret_len)
     ELSE
      blob_out = fillstring(32000," "), y1 = size(trim(lb.long_blob)), blob_out = substring(1,(y1 - 8
       ),lb.long_blob)
     ENDIF
     CALL uar_rtf2(blob_out,textlen(blob_out),blob_out2,32000,32000,0), blob_out = blob_out2, temp->
     patient[d3.seq].patient_care_result[ncnt].note = blob_out
    ENDIF
   FOOT  ce.person_id
    temp->patient[d3.seq].pcr_cnt = ncnt
   WITH nocounter, memsort, outerjoin = d4
  ;end select
 ENDIF
 IF (vitals_ind=1)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(max_enc_cnt)),
    (dummyt d3  WITH seq = value(patient_cnt)),
    clinical_event ce
   PLAN (d3
    WHERE maxrec(d,temp->patient[d3.seq].encntr_cnt) > 0)
    JOIN (ce
    WHERE (ce.person_id=temp->patient[d3.seq].demographics.person_id)
     AND ce.event_cd IN (temp_cd, resp_cd, pulse_cd, sys_cd, dia_cd)
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.event_end_dt_tm >= cnvtdatetime(beg_dt_tm)
     AND ce.result_status_cd != inerror_cd)
    JOIN (d
    WHERE (ce.encntr_id=temp->patient[d3.seq].encntr[d.seq].encntr_id))
   ORDER BY ce.person_id, cnvtdatetime(ce.event_end_dt_tm)
   HEAD ce.person_id
    cnt = 0, tempdia = "      ", tempsys = "      ",
    stat = alterlist(temp->patient[d3.seq].vital_sign,5)
   HEAD ce.event_end_dt_tm
    tempdia = "      ", tempsys = "      ", cnt = (cnt+ 1)
   DETAIL
    IF (cnt < 6)
     IF (ce.event_cd=temp_cd)
      temp->patient[d3.seq].vital_sign[cnt].temperature = trim(ce.event_tag)
     ELSEIF (ce.event_cd=resp_cd)
      temp->patient[d3.seq].vital_sign[cnt].respiratory = trim(ce.event_tag)
     ELSEIF (ce.event_cd=pulse_cd)
      temp->patient[d3.seq].vital_sign[cnt].pulse = trim(ce.event_tag)
     ELSEIF (ce.event_cd=sys_cd)
      tempsys = trim(ce.event_tag)
     ELSEIF (ce.event_cd=dia_cd)
      tempdia = trim(ce.event_tag)
     ENDIF
    ENDIF
   FOOT  ce.event_end_dt_tm
    IF (cnt < 6)
     IF (tempsys > " "
      AND tempdia > " ")
      temp->patient[d3.seq].vital_sign[cnt].blood_pressure = build(trim(tempsys),"/",trim(tempdia))
     ENDIF
     temp->patient[d3.seq].vital_sign[cnt].vital_sign_dt_tm = format(ce.event_end_dt_tm,
      "mm/dd hh:mm;;d")
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(max_enc_cnt)),
    (dummyt d3  WITH seq = value(patient_cnt)),
    clinical_event ce
   PLAN (d3
    WHERE maxrec(d,temp->patient[d3.seq].encntr_cnt) > 0)
    JOIN (ce
    WHERE (ce.person_id=temp->patient[d3.seq].demographics.person_id)
     AND ce.event_cd IN (hgt_cd, wgt_cd)
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.event_end_dt_tm <= cnvtdatetime(curdate,curtime)
     AND ce.result_status_cd != inerror_cd)
    JOIN (d
    WHERE (ce.encntr_id=temp->patient[d3.seq].encntr[d.seq].encntr_id))
   ORDER BY ce.person_id, cnvtdatetime(ce.event_end_dt_tm)
   DETAIL
    IF (ce.event_cd=hgt_cd)
     temp->patient[d3.seq].height = trim(ce.event_tag), temp->patient[d3.seq].height_dt_tm = format(
      ce.event_end_dt_tm,"mm/dd hh:mm;;d")
    ELSEIF (ce.event_cd=wgt_cd)
     temp->patient[d3.seq].weight = trim(ce.event_tag), temp->patient[d3.seq].weight_dt_tm = format(
      ce.event_end_dt_tm,"mm/dd hh:mm;;d")
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (documents_ind=1
  AND (temp2->doc_cnt > 0))
  SET cnt = 0
  SELECT INTO "nl:"
   sze = textlen(cb.blob_contents)
   FROM (dummyt d  WITH seq = value(max_enc_cnt)),
    (dummyt d2  WITH seq = value(temp2->doc_cnt)),
    (dummyt d3  WITH seq = value(patient_cnt)),
    clinical_event ce,
    clinical_event ce2,
    ce_blob_result cbr,
    ce_blob cb,
    prsnl pl,
    v500_event_code vec
   PLAN (d3
    WHERE maxrec(d,temp->patient[d3.seq].encntr_cnt) > 0)
    JOIN (ce
    WHERE (ce.person_id=temp->patient[d3.seq].demographics.person_id)
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.updt_dt_tm >= cnvtdatetime(beg_dt_tm)
     AND ce.updt_dt_tm <= cnvtdatetime(end_dt_tm)
     AND ce.result_status_cd != inerror_cd
     AND ce.event_class_cd IN (doc_cd, mdoc_cd))
    JOIN (d
    WHERE (ce.encntr_id=temp->patient[d3.seq].encntr[d.seq].encntr_id))
    JOIN (d2
    WHERE (ce.event_cd=temp2->doc[d2.seq].doc_event_cd))
    JOIN (ce2
    WHERE ce2.parent_event_id=ce.event_id
     AND ce2.view_level=0
     AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00")
     AND ce2.publish_flag=1)
    JOIN (cbr
    WHERE cbr.event_id=ce2.event_id
     AND cbr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
    JOIN (cb
    WHERE cb.event_id=ce2.event_id
     AND cb.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
    JOIN (pl
    WHERE pl.person_id=ce.performed_prsnl_id)
    JOIN (vec
    WHERE vec.event_cd=ce.event_cd)
   ORDER BY ce.person_id, cnvtdatetime(ce.event_end_dt_tm) DESC, d2.seq,
    ce2.parent_event_id
   HEAD ce.person_id
    hold_event_id = 0, cnt = 0
   DETAIL
    IF (ce2.parent_event_id=hold_event_id)
     blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," "), blob_out3 = fillstring(
      32000," ")
     IF (cb.compression_cd=ocfcomp_cd)
      blob_out = fillstring(32000," "), blob_ret_len = 0,
      CALL uar_ocf_uncompress(cb.blob_contents,sze,blob_out,32000,blob_ret_len)
     ELSE
      blob_out = fillstring(32000," "), y1 = size(trim(cb.blob_contents)), blob_out = substring(1,(y1
        - 8),cb.blob_contents)
     ENDIF
     CALL uar_rtf2(blob_out,textlen(blob_out),blob_out2,32000,32000,0), temp->patient[d3.seq].
     other_doc[cnt].blob = concat(temp->patient[d3.seq].other_doc[cnt].blob," | ",trim(blob_out2))
    ELSE
     cnt = (cnt+ 1), stat = alterlist(temp->patient[d3.seq].other_doc,cnt), blob_out = fillstring(
      32000," "),
     blob_out2 = fillstring(32000," "), blob_out3 = fillstring(32000," ")
     IF (cb.compression_cd=ocfcomp_cd)
      blob_out = fillstring(32000," "), blob_ret_len = 0,
      CALL uar_ocf_uncompress(cb.blob_contents,sze,blob_out,32000,blob_ret_len)
     ELSE
      blob_out = fillstring(32000," "), y1 = size(trim(cb.blob_contents)), blob_out = substring(1,(y1
        - 8),cb.blob_contents)
     ENDIF
     temp->patient[d3.seq].other_doc[cnt].event_end_dt_tm = format(ce.event_end_dt_tm,
      "mm/dd hh:mm;;d"), temp->patient[d3.seq].other_doc[cnt].author = concat(trim(pl
       .name_full_formatted)), temp->patient[d3.seq].other_doc[cnt].doc_name = trim(vec
      .event_set_name),
     CALL uar_rtf2(blob_out,textlen(blob_out),blob_out2,32000,32000,0), temp->patient[d3.seq].
     other_doc[cnt].blob = trim(blob_out2), temp->patient[d3.seq].other_doc[cnt].event_cd = ce
     .event_cd,
     temp->patient[d3.seq].other_doc[cnt].event_cd_seq = d2.seq, temp->patient[d3.seq].other_doc[cnt]
     .sort_by_dt_tm = format(ce.event_end_dt_tm,"yy/mm/dd hh:mm;;d"), hold_event_id = ce.event_id
    ENDIF
   FOOT  ce.person_id
    temp->patient[d3.seq].od_cnt = cnt
   WITH nocounter, memsort
  ;end select
  DECLARE doc_foreign_ind = i2 WITH noconstant(0)
  SELECT INTO "nl:"
   sze = textlen(cb.blob_contents)
   FROM (dummyt d  WITH seq = value(max_enc_cnt)),
    (dummyt d2  WITH seq = value(temp2->doc_cnt)),
    (dummyt d3  WITH seq = value(patient_cnt)),
    clinical_event ce,
    ce_blob_result cbr,
    ce_blob cb,
    prsnl pl,
    v500_event_code vec
   PLAN (d3
    WHERE maxrec(d,temp->patient[d3.seq].encntr_cnt) > 0)
    JOIN (ce
    WHERE (ce.person_id=temp->patient[d3.seq].demographics.person_id)
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.updt_dt_tm >= cnvtdatetime(beg_dt_tm)
     AND ce.updt_dt_tm <= cnvtdatetime(end_dt_tm)
     AND ce.result_status_cd != inerror_cd
     AND ce.event_class_cd IN (doc_cd, mdoc_cd))
    JOIN (d
    WHERE (ce.encntr_id=temp->patient[d3.seq].encntr[d.seq].encntr_id))
    JOIN (d2
    WHERE (ce.event_cd=temp2->doc[d2.seq].doc_event_cd))
    JOIN (cbr
    WHERE cbr.event_id=ce.event_id
     AND cbr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
    JOIN (cb
    WHERE cb.event_id=ce.event_id
     AND cb.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
    JOIN (pl
    WHERE pl.person_id=ce.performed_prsnl_id)
    JOIN (vec
    WHERE vec.event_cd=ce.event_cd)
   ORDER BY d3.seq, cnvtdatetime(ce.event_end_dt_tm) DESC, d2.seq
   HEAD d3.seq
    hold_event_id = 0
    IF ((temp->patient[d3.seq].od_cnt > 0))
     cnt = temp->patient[d3.seq].od_cnt
    ELSE
     cnt = 0
    ENDIF
   DETAIL
    IF (ce.parent_event_id=hold_event_id)
     blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," "), blob_out3 = fillstring(
      32000," ")
     IF (cb.compression_cd=ocfcomp_cd)
      blob_out = fillstring(32000," "), blob_ret_len = 0,
      CALL uar_ocf_uncompress(cb.blob_contents,sze,blob_out,32000,blob_ret_len)
     ELSE
      blob_out = fillstring(32000," "), y1 = size(trim(cb.blob_contents)), blob_out = substring(1,(y1
        - 8),cb.blob_contents)
     ENDIF
     CALL uar_rtf2(blob_out,textlen(blob_out),blob_out2,32000,32000,0), temp->patient[d3.seq].
     other_doc[cnt].blob = concat(temp->patient[d3.seq].other_doc[cnt].blob," | ",trim(blob_out2))
    ELSE
     cnt = (cnt+ 1), doc_foreign_ind = 1, stat = alterlist(temp->patient[d3.seq].other_doc,cnt),
     blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," "), blob_out3 = fillstring(
      32000," ")
     IF (cb.compression_cd=ocfcomp_cd)
      blob_out = fillstring(32000," "), blob_ret_len = 0,
      CALL uar_ocf_uncompress(cb.blob_contents,sze,blob_out,32000,blob_ret_len)
     ELSE
      blob_out = fillstring(32000," "), y1 = size(trim(cb.blob_contents)), blob_out = substring(1,(y1
        - 8),cb.blob_contents)
     ENDIF
     temp->patient[d3.seq].other_doc[cnt].event_end_dt_tm = format(ce.event_end_dt_tm,
      "mm/dd hh:mm;;d"), temp->patient[d3.seq].other_doc[cnt].author = concat(trim(pl
       .name_full_formatted)), temp->patient[d3.seq].other_doc[cnt].doc_name = trim(vec
      .event_set_name),
     CALL uar_rtf2(blob_out,textlen(blob_out),blob_out2,32000,32000,0), temp->patient[d3.seq].
     other_doc[cnt].blob = trim(blob_out2), temp->patient[d3.seq].other_doc[cnt].event_cd = ce
     .event_cd,
     temp->patient[d3.seq].other_doc[cnt].event_cd_seq = d2.seq, temp->patient[d3.seq].other_doc[cnt]
     .sort_by_dt_tm = format(ce.event_end_dt_tm,"yy/mm/dd hh:mm;;d"), hold_event_id = ce.event_id
    ENDIF
   FOOT  d3.seq
    temp->patient[d3.seq].od_cnt = cnt
   WITH nocounter, memsort
  ;end select
  IF (doc_foreign_ind=1)
   DECLARE od_event_cd = f8
   DECLARE od_event_cd_seq = i2
   DECLARE od_encntr_id = f8
   DECLARE od_doc_name = vc
   DECLARE od_blob = vc
   DECLARE od_event_end_dt_tm = vc
   DECLARE od_author = vc
   DECLARE od_cnt = i2
   DECLARE od_sort_by_dt_tm = vc
   FOR (c = 1 TO patient_cnt)
    SET size_array = temp->patient[c].od_cnt
    FOR (y = 1 TO (size_array - 1))
      FOR (x = 1 TO (size_array - y))
       SET skipswap = 0
       IF ((temp->patient[c].other_doc[x].sort_by_dt_tm <= temp->patient[c].other_doc[(x+ 1)].
       sort_by_dt_tm))
        IF ((temp->patient[c].other_doc[x].event_end_dt_tm=temp->patient[c].other_doc[(x+ 1)].
        event_end_dt_tm))
         IF ((temp->patient[c].other_doc[x].event_cd_seq < temp->patient[c].other_doc[(x+ 1)].
         event_cd_seq))
          SET skipswap = 1
         ENDIF
        ENDIF
        IF (skipswap=0)
         SET od_event_cd = temp->patient[c].other_doc[x].event_cd
         SET temp->patient[c].other_doc[x].event_cd = temp->patient[c].other_doc[(x+ 1)].event_cd
         SET temp->patient[c].other_doc[(x+ 1)].event_cd = od_event_cd
         SET od_encntr_id = temp->patient[c].other_doc[x].encntr_id
         SET temp->patient[c].other_doc[x].encntr_id = temp->patient[c].other_doc[(x+ 1)].encntr_id
         SET temp->patient[c].other_doc[(x+ 1)].encntr_id = od_encntr_id
         SET od_doc_name = temp->patient[c].other_doc[x].doc_name
         SET temp->patient[c].other_doc[x].doc_name = temp->patient[c].other_doc[(x+ 1)].doc_name
         SET temp->patient[c].other_doc[(x+ 1)].doc_name = od_doc_name
         SET od_blob = temp->patient[c].other_doc[x].blob
         SET temp->patient[c].other_doc[x].blob = temp->patient[c].other_doc[(x+ 1)].blob
         SET temp->patient[c].other_doc[(x+ 1)].blob = od_blob
         SET od_event_end_dt_tm = temp->patient[c].other_doc[x].event_end_dt_tm
         SET temp->patient[c].other_doc[x].event_end_dt_tm = temp->patient[c].other_doc[(x+ 1)].
         event_end_dt_tm
         SET temp->patient[c].other_doc[(x+ 1)].event_end_dt_tm = od_event_end_dt_tm
         SET od_author = temp->patient[c].other_doc[x].author
         SET temp->patient[c].other_doc[x].author = temp->patient[c].other_doc[(x+ 1)].author
         SET temp->patient[c].other_doc[(x+ 1)].author = od_author
         SET od_cnt = temp->patient[c].other_doc[x].od_cnt
         SET temp->patient[c].other_doc[x].od_cnt = temp->patient[c].other_doc[(x+ 1)].od_cnt
         SET temp->patient[c].other_doc[(x+ 1)].od_cnt = od_cnt
         SET od_event_cd_seq = temp->patient[c].other_doc[x].event_cd_seq
         SET temp->patient[c].other_doc[x].event_cd_seq = temp->patient[c].other_doc[(x+ 1)].
         event_cd_seq
         SET temp->patient[c].other_doc[(x+ 1)].event_cd_seq = od_event_cd_seq
         SET od_sort_by_dt_tm = temp->patient[c].other_doc[x].sort_by_dt_tm
         SET temp->patient[c].other_doc[x].sort_by_dt_tm = temp->patient[c].other_doc[(x+ 1)].
         sort_by_dt_tm
         SET temp->patient[c].other_doc[(x+ 1)].sort_by_dt_tm = od_sort_by_dt_tm
        ENDIF
       ENDIF
      ENDFOR
    ENDFOR
   ENDFOR
  ENDIF
 ENDIF
 IF (documents_ind=1
  AND (temp2->doc_cnt=0))
  SET cnt = 0
  SELECT INTO "nl:"
   sze = textlen(cb.blob_contents)
   FROM (dummyt d  WITH seq = value(max_enc_cnt)),
    (dummyt d3  WITH seq = value(patient_cnt)),
    orders o,
    clinical_event ce,
    clinical_event ce2,
    ce_blob_result cbr,
    ce_blob cb,
    prsnl pl,
    v500_event_code vec
   PLAN (d3
    WHERE maxrec(d,temp->patient[d3.seq].encntr_cnt) > 0)
    JOIN (d)
    JOIN (o
    WHERE (o.encntr_id=temp->patient[d3.seq].encntr[d.seq].encntr_id)
     AND (o.person_id=temp->patient[d3.seq].demographics.person_id)
     AND o.catalog_type_cd != rad_cd
     AND o.template_order_flag IN (0, 2))
    JOIN (ce
    WHERE ce.order_id=o.order_id
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.updt_dt_tm >= cnvtdatetime(beg_dt_tm)
     AND ce.updt_dt_tm <= cnvtdatetime(end_dt_tm)
     AND ce.result_status_cd != inerror_cd
     AND ce.event_class_cd IN (doc_cd, mdoc_cd))
    JOIN (ce2
    WHERE ce2.parent_event_id=ce.event_id
     AND ce2.view_level=0
     AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00")
     AND ce2.publish_flag=1)
    JOIN (cbr
    WHERE cbr.event_id=ce2.event_id
     AND cbr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
    JOIN (cb
    WHERE cb.event_id=ce2.event_id
     AND cb.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
    JOIN (pl
    WHERE pl.person_id=ce.performed_prsnl_id)
    JOIN (vec
    WHERE vec.event_cd=ce.event_cd)
   ORDER BY ce.person_id, cnvtdatetime(ce.event_end_dt_tm) DESC, ce.event_cd,
    ce2.parent_event_id
   HEAD ce.person_id
    hold_event_id = 0, cnt = 0
   DETAIL
    IF (ce2.parent_event_id=hold_event_id)
     blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," "), blob_out3 = fillstring(
      32000," ")
     IF (cb.compression_cd=ocfcomp_cd)
      blob_out = fillstring(32000," "), blob_ret_len = 0,
      CALL uar_ocf_uncompress(cb.blob_contents,sze,blob_out,32000,blob_ret_len)
     ELSE
      blob_out = fillstring(32000," "), y1 = size(trim(cb.blob_contents)), blob_out = substring(1,(y1
        - 8),cb.blob_contents)
     ENDIF
     CALL uar_rtf2(blob_out,textlen(blob_out),blob_out2,32000,32000,0), temp->patient[d3.seq].
     other_doc[cnt].blob = concat(temp->patient[d3.seq].other_doc[cnt].blob," | ",trim(blob_out2))
    ELSE
     cnt = (cnt+ 1), stat = alterlist(temp->patient[d3.seq].other_doc,cnt), blob_out = fillstring(
      32000," "),
     blob_out2 = fillstring(32000," "), blob_out3 = fillstring(32000," ")
     IF (cb.compression_cd=ocfcomp_cd)
      blob_out = fillstring(32000," "), blob_ret_len = 0,
      CALL uar_ocf_uncompress(cb.blob_contents,sze,blob_out,32000,blob_ret_len)
     ELSE
      blob_out = fillstring(32000," "), y1 = size(trim(cb.blob_contents)), blob_out = substring(1,(y1
        - 8),cb.blob_contents)
     ENDIF
     temp->patient[d3.seq].other_doc[cnt].event_end_dt_tm = format(ce.event_end_dt_tm,
      "mm/dd hh:mm;;d"), temp->patient[d3.seq].other_doc[cnt].author = concat(trim(pl
       .name_full_formatted)), temp->patient[d3.seq].other_doc[cnt].doc_name = trim(vec
      .event_set_name),
     CALL uar_rtf2(blob_out,textlen(blob_out),blob_out2,32000,32000,0), temp->patient[d3.seq].
     other_doc[cnt].blob = trim(blob_out2), temp->patient[d3.seq].other_doc[cnt].event_cd = ce
     .event_cd,
     hold_event_id = ce.event_id
    ENDIF
   FOOT  ce.person_id
    temp->patient[d3.seq].od_cnt = cnt
   WITH nocounter, memsort
  ;end select
 ENDIF
 IF (radiology_ind=1
  AND (temp2->rad_cnt > 0))
  SET cnt = 0
  SELECT INTO "nl:"
   sze = textlen(cb.blob_contents)
   FROM (dummyt d  WITH seq = value(max_enc_cnt)),
    (dummyt d2  WITH seq = value(temp2->rad_cnt)),
    (dummyt d3  WITH seq = value(patient_cnt)),
    clinical_event rad,
    ce_linked_result clr,
    clinical_event ce,
    clinical_event ce2,
    ce_blob_result cbr,
    ce_blob cb,
    prsnl pl,
    v500_event_code vec
   PLAN (d3
    WHERE maxrec(d,temp->patient[d3.seq].encntr_cnt) > 0)
    JOIN (rad
    WHERE (rad.person_id=temp->patient[d3.seq].demographics.person_id)
     AND rad.publish_flag=1
     AND rad.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND rad.updt_dt_tm >= cnvtdatetime(beg_dt_tm)
     AND rad.updt_dt_tm <= cnvtdatetime(end_dt_tm)
     AND rad.result_status_cd != inerror_cd
     AND rad.event_class_cd=rad_doc_cd)
    JOIN (d
    WHERE (rad.encntr_id=temp->patient[d3.seq].encntr[d.seq].encntr_id))
    JOIN (d2
    WHERE (rad.event_cd=temp2->rad[d2.seq].rad_event_cd))
    JOIN (clr
    WHERE clr.event_id=rad.event_id
     AND clr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
    JOIN (ce
    WHERE ce.event_id=clr.linked_event_id
     AND ce.publish_flag=1
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.event_end_dt_tm >= cnvtdatetime(beg_dt_tm)
     AND ce.event_end_dt_tm <= cnvtdatetime(end_dt_tm)
     AND ce.result_status_cd != inerror_cd
     AND ce.event_class_cd IN (doc_cd, mdoc_cd))
    JOIN (ce2
    WHERE ce2.parent_event_id=ce.event_id
     AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00")
     AND ce2.publish_flag=1)
    JOIN (cbr
    WHERE cbr.event_id=ce2.event_id
     AND cbr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
    JOIN (cb
    WHERE cb.event_id=ce2.event_id
     AND cb.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
    JOIN (pl
    WHERE pl.person_id=rad.verified_prsnl_id)
    JOIN (vec
    WHERE vec.event_cd=rad.event_cd)
   ORDER BY rad.person_id, cnvtdatetime(ce.event_end_dt_tm) DESC, d2.seq,
    ce2.parent_event_id
   HEAD rad.person_id
    hold_event_id = 0, cnt = 0
   DETAIL
    IF (ce2.parent_event_id=hold_event_id)
     blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," "), blob_out3 = fillstring(
      32000," ")
     IF (cb.compression_cd=ocfcomp_cd)
      blob_out = fillstring(32000," "), blob_ret_len = 0,
      CALL uar_ocf_uncompress(cb.blob_contents,sze,blob_out,32000,blob_ret_len)
     ELSE
      blob_out = fillstring(32000," "), y1 = size(trim(cb.blob_contents)), blob_out = substring(1,(y1
        - 8),cb.blob_contents)
     ENDIF
     CALL uar_rtf2(blob_out,textlen(blob_out),blob_out2,32000,32000,0), temp->patient[d3.seq].
     radiology_doc[cnt].blob = concat(temp->patient[d3.seq].radiology_doc[cnt].blob," | ",trim(
       blob_out2))
    ELSE
     cnt = (cnt+ 1), stat = alterlist(temp->patient[d3.seq].radiology_doc,cnt), blob_out = fillstring
     (32000," "),
     blob_out2 = fillstring(32000," "), blob_out3 = fillstring(32000," ")
     IF (cb.compression_cd=ocfcomp_cd)
      blob_out = fillstring(32000," "), blob_ret_len = 0,
      CALL uar_ocf_uncompress(cb.blob_contents,sze,blob_out,32000,blob_ret_len)
     ELSE
      blob_out = fillstring(32000," "), y1 = size(trim(cb.blob_contents)), blob_out = substring(1,(y1
        - 8),cb.blob_contents)
     ENDIF
     temp->patient[d3.seq].radiology_doc[cnt].event_end_dt_tm = format(rad.event_end_dt_tm,
      "mm/dd hh:mm;;d"), temp->patient[d3.seq].radiology_doc[cnt].author = concat(trim(pl
       .name_full_formatted)), temp->patient[d3.seq].radiology_doc[cnt].doc_name = trim(vec
      .event_set_name),
     CALL uar_rtf2(blob_out,textlen(blob_out),blob_out2,32000,32000,0), temp->patient[d3.seq].
     radiology_doc[cnt].blob = trim(blob_out2), temp->patient[d3.seq].radiology_doc[cnt].event_cd =
     rad.event_cd,
     temp->patient[d3.seq].radiology_doc[cnt].event_cd_seq = d2.seq, temp->patient[d3.seq].
     radiology_doc[cnt].sort_by_dt_tm = format(rad.event_end_dt_tm,"yy/mm/dd hh:mm;;d"),
     hold_event_id = ce.event_id
    ENDIF
   FOOT  rad.person_id
    temp->patient[d3.seq].rd_cnt = cnt
   WITH nocounter, memsort
  ;end select
  DECLARE rad_foreign_ind = i2 WITH noconstant(0)
  SELECT INTO "nl:"
   sze = textlen(cb.blob_contents)
   FROM (dummyt d  WITH seq = value(max_enc_cnt)),
    (dummyt d2  WITH seq = value(temp2->rad_cnt)),
    (dummyt d3  WITH seq = value(patient_cnt)),
    clinical_event ce,
    ce_blob_result cbr,
    ce_blob cb,
    prsnl pl,
    v500_event_code vec
   PLAN (d3
    WHERE maxrec(d,temp->patient[d3.seq].encntr_cnt) > 0)
    JOIN (ce
    WHERE (ce.person_id=temp->patient[d3.seq].demographics.person_id)
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.updt_dt_tm >= cnvtdatetime(beg_dt_tm)
     AND ce.updt_dt_tm <= cnvtdatetime(end_dt_tm)
     AND ce.result_status_cd != inerror_cd
     AND ce.event_class_cd IN (doc_cd, mdoc_cd))
    JOIN (d
    WHERE (ce.encntr_id=temp->patient[d3.seq].encntr[d.seq].encntr_id))
    JOIN (d2
    WHERE (ce.event_cd=temp2->rad[d2.seq].rad_event_cd))
    JOIN (cbr
    WHERE cbr.event_id=ce.event_id
     AND cbr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
    JOIN (cb
    WHERE cb.event_id=ce.event_id
     AND cb.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
    JOIN (pl
    WHERE pl.person_id=ce.verified_prsnl_id)
    JOIN (vec
    WHERE vec.event_cd=ce.event_cd)
   ORDER BY d3.seq, cnvtdatetime(ce.event_end_dt_tm) DESC, d2.seq
   HEAD d3.seq
    hold_event_id = 0
    IF ((temp->patient[d3.seq].rd_cnt > 0))
     cnt = temp->patient[d3.seq].rd_cnt
    ELSE
     cnt = 0
    ENDIF
   DETAIL
    IF (ce.parent_event_id=hold_event_id)
     blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," "), blob_out3 = fillstring(
      32000," ")
     IF (cb.compression_cd=ocfcomp_cd)
      blob_out = fillstring(32000," "), blob_ret_len = 0,
      CALL uar_ocf_uncompress(cb.blob_contents,sze,blob_out,32000,blob_ret_len)
     ELSE
      blob_out = fillstring(32000," "), y1 = size(trim(cb.blob_contents)), blob_out = substring(1,(y1
        - 8),cb.blob_contents)
     ENDIF
     CALL uar_rtf2(blob_out,textlen(blob_out),blob_out2,32000,32000,0), temp->patient[d3.seq].
     radiology_doc[cnt].blob = concat(temp->patient[d3.seq].radiology_doc[cnt].blob," | ",trim(
       blob_out2))
    ELSE
     cnt = (cnt+ 1), rad_foreign_ind = 1, stat = alterlist(temp->patient[d3.seq].radiology_doc,cnt),
     blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," "), blob_out3 = fillstring(
      32000," ")
     IF (cb.compression_cd=ocfcomp_cd)
      blob_out = fillstring(32000," "), blob_ret_len = 0,
      CALL uar_ocf_uncompress(cb.blob_contents,sze,blob_out,32000,blob_ret_len)
     ELSE
      blob_out = fillstring(32000," "), y1 = size(trim(cb.blob_contents)), blob_out = substring(1,(y1
        - 8),cb.blob_contents)
     ENDIF
     temp->patient[d3.seq].radiology_doc[cnt].event_end_dt_tm = format(ce.event_end_dt_tm,
      "mm/dd hh:mm;;d"), temp->patient[d3.seq].radiology_doc[cnt].author = concat(trim(pl
       .name_full_formatted)), temp->patient[d3.seq].radiology_doc[cnt].doc_name = trim(vec
      .event_set_name),
     CALL uar_rtf2(blob_out,textlen(blob_out),blob_out2,32000,32000,0), temp->patient[d3.seq].
     radiology_doc[cnt].blob = trim(blob_out2), temp->patient[d3.seq].radiology_doc[cnt].event_cd =
     ce.event_cd,
     temp->patient[d3.seq].radiology_doc[cnt].event_cd_seq = d2.seq, temp->patient[d3.seq].
     radiology_doc[cnt].sort_by_dt_tm = format(ce.event_end_dt_tm,"yy/mm/dd hh:mm;;d"), hold_event_id
      = ce.event_id
    ENDIF
   FOOT  d3.seq
    temp->patient[d3.seq].rd_cnt = cnt
   WITH nocounter, memsort
  ;end select
  IF (rad_foreign_ind=1)
   DECLARE rd_event_cd = f8
   DECLARE rd_event_cd_seq = i2
   DECLARE rd_encntr_id = f8
   DECLARE rd_doc_name = vc
   DECLARE rd_blob = vc
   DECLARE rd_event_end_dt_tm = vc
   DECLARE rd_author = vc
   DECLARE rd_cnt = i2
   DECLARE rd_sort_by_dt_tm = vc
   FOR (c = 1 TO patient_cnt)
    SET size_array = temp->patient[c].rd_cnt
    FOR (y = 1 TO (size_array - 1))
      FOR (x = 1 TO (size_array - y))
       SET skipswap = 0
       IF ((temp->patient[c].radiology_doc[x].sort_by_dt_tm <= temp->patient[c].radiology_doc[(x+ 1)]
       .sort_by_dt_tm))
        IF ((temp->patient[c].radiology_doc[x].event_end_dt_tm=temp->patient[c].radiology_doc[(x+ 1)]
        .event_end_dt_tm))
         IF ((temp->patient[c].radiology_doc[x].event_cd_seq < temp->patient[c].radiology_doc[(x+ 1)]
         .event_cd_seq))
          SET skipswap = 1
         ENDIF
        ENDIF
        IF (skipswap=0)
         SET rd_event_cd = temp->patient[c].radiology_doc[x].event_cd
         SET temp->patient[c].radiology_doc[x].event_cd = temp->patient[c].radiology_doc[(x+ 1)].
         event_cd
         SET temp->patient[c].radiology_doc[(x+ 1)].event_cd = rd_event_cd
         SET rd_encntr_id = temp->patient[c].radiology_doc[x].encntr_id
         SET temp->patient[c].radiology_doc[x].encntr_id = temp->patient[c].radiology_doc[(x+ 1)].
         encntr_id
         SET temp->patient[c].radiology_doc[(x+ 1)].encntr_id = rd_encntr_id
         SET rd_doc_name = temp->patient[c].radiology_doc[x].doc_name
         SET temp->patient[c].radiology_doc[x].doc_name = temp->patient[c].radiology_doc[(x+ 1)].
         doc_name
         SET temp->patient[c].radiology_doc[(x+ 1)].doc_name = rd_doc_name
         SET rd_blob = temp->patient[c].radiology_doc[x].blob
         SET temp->patient[c].radiology_doc[x].blob = temp->patient[c].radiology_doc[(x+ 1)].blob
         SET temp->patient[c].radiology_doc[(x+ 1)].blob = rd_blob
         SET rd_event_end_dt_tm = temp->patient[c].radiology_doc[x].event_end_dt_tm
         SET temp->patient[c].radiology_doc[x].event_end_dt_tm = temp->patient[c].radiology_doc[(x+ 1
         )].event_end_dt_tm
         SET temp->patient[c].radiology_doc[(x+ 1)].event_end_dt_tm = rd_event_end_dt_tm
         SET rd_author = temp->patient[c].radiology_doc[x].author
         SET temp->patient[c].radiology_doc[x].author = temp->patient[c].radiology_doc[(x+ 1)].author
         SET temp->patient[c].radiology_doc[(x+ 1)].author = rd_author
         SET rd_cnt = temp->patient[c].radiology_doc[x].rd_cnt
         SET temp->patient[c].radiology_doc[x].rd_cnt = temp->patient[c].radiology_doc[(x+ 1)].rd_cnt
         SET temp->patient[c].radiology_doc[(x+ 1)].rd_cnt = rd_cnt
         SET rd_event_cd_seq = temp->patient[c].radiology_doc[x].event_cd_seq
         SET temp->patient[c].radiology_doc[x].event_cd_seq = temp->patient[c].radiology_doc[(x+ 1)].
         event_cd_seq
         SET temp->patient[c].radiology_doc[(x+ 1)].event_cd_seq = rd_event_cd_seq
         SET rd_sort_by_dt_tm = temp->patient[c].radiology_doc[x].sort_by_dt_tm
         SET temp->patient[c].radiology_doc[x].sort_by_dt_tm = temp->patient[c].radiology_doc[(x+ 1)]
         .sort_by_dt_tm
         SET temp->patient[c].radiology_doc[(x+ 1)].sort_by_dt_tm = rd_sort_by_dt_tm
        ENDIF
       ENDIF
      ENDFOR
    ENDFOR
   ENDFOR
  ENDIF
 ENDIF
 IF (radiology_ind=1
  AND (temp2->rad_cnt=0))
  SET cnt = 0
  SELECT INTO "nl:"
   sze = textlen(cb.blob_contents)
   FROM (dummyt d  WITH seq = value(max_enc_cnt)),
    (dummyt d3  WITH seq = value(patient_cnt)),
    orders o,
    clinical_event rad,
    ce_linked_result clr,
    clinical_event ce,
    clinical_event ce2,
    ce_blob_result cbr,
    ce_blob cb,
    prsnl pl,
    v500_event_code vec
   PLAN (d3
    WHERE maxrec(d,temp->patient[d3.seq].encntr_cnt) > 0)
    JOIN (d)
    JOIN (o
    WHERE (o.encntr_id=temp->patient[d3.seq].encntr[d.seq].encntr_id)
     AND (o.person_id=temp->patient[d3.seq].demographics.person_id)
     AND o.catalog_type_cd=rad_cd
     AND o.template_order_flag IN (0, 2))
    JOIN (rad
    WHERE rad.order_id=o.order_id
     AND rad.publish_flag=1
     AND rad.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND rad.updt_dt_tm >= cnvtdatetime(beg_dt_tm)
     AND rad.updt_dt_tm <= cnvtdatetime(end_dt_tm)
     AND rad.result_status_cd != inerror_cd
     AND rad.event_class_cd=rad_doc_cd)
    JOIN (clr
    WHERE clr.event_id=rad.event_id
     AND clr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
    JOIN (ce
    WHERE ce.event_id=clr.linked_event_id
     AND ce.publish_flag=1
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.event_end_dt_tm >= cnvtdatetime(beg_dt_tm)
     AND ce.event_end_dt_tm <= cnvtdatetime(end_dt_tm)
     AND ce.result_status_cd != inerror_cd
     AND ce.event_class_cd IN (doc_cd, mdoc_cd))
    JOIN (ce2
    WHERE ce2.parent_event_id=ce.event_id
     AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00")
     AND ce2.publish_flag=1)
    JOIN (cbr
    WHERE cbr.event_id=ce2.event_id
     AND cbr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
    JOIN (cb
    WHERE cb.event_id=ce2.event_id
     AND cb.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
    JOIN (pl
    WHERE pl.person_id=rad.verified_prsnl_id)
    JOIN (vec
    WHERE vec.event_cd=rad.event_cd)
   ORDER BY o.person_id, cnvtdatetime(rad.event_end_dt_tm) DESC, ce.event_cd,
    ce2.parent_event_id
   HEAD o.person_id
    hold_event_id = 0, cnt = 0
   DETAIL
    IF (ce2.parent_event_id=hold_event_id)
     blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," "), blob_out3 = fillstring(
      32000," ")
     IF (cb.compression_cd=ocfcomp_cd)
      blob_out = fillstring(32000," "), blob_ret_len = 0,
      CALL uar_ocf_uncompress(cb.blob_contents,sze,blob_out,32000,blob_ret_len)
     ELSE
      blob_out = fillstring(32000," "), y1 = size(trim(cb.blob_contents)), blob_out = substring(1,(y1
        - 8),cb.blob_contents)
     ENDIF
     CALL uar_rtf2(blob_out,textlen(blob_out),blob_out2,32000,32000,0), temp->patient[d3.seq].
     radiology_doc[cnt].blob = concat(temp->patient[d3.seq].radiology_doc[cnt].blob," | ",trim(
       blob_out2))
    ELSE
     cnt = (cnt+ 1), stat = alterlist(temp->patient[d3.seq].radiology_doc,cnt), blob_out = fillstring
     (32000," "),
     blob_out2 = fillstring(32000," "), blob_out3 = fillstring(32000," ")
     IF (cb.compression_cd=ocfcomp_cd)
      blob_out = fillstring(32000," "), blob_ret_len = 0,
      CALL uar_ocf_uncompress(cb.blob_contents,sze,blob_out,32000,blob_ret_len)
     ELSE
      blob_out = fillstring(32000," "), y1 = size(trim(cb.blob_contents)), blob_out = substring(1,(y1
        - 8),cb.blob_contents)
     ENDIF
     temp->patient[d3.seq].radiology_doc[cnt].event_end_dt_tm = format(rad.event_end_dt_tm,
      "mm/dd hh:mm;;d"), temp->patient[d3.seq].radiology_doc[cnt].author = concat(trim(pl
       .name_full_formatted)), temp->patient[d3.seq].radiology_doc[cnt].doc_name = trim(vec
      .event_set_name),
     CALL uar_rtf2(blob_out,textlen(blob_out),blob_out2,32000,32000,0), temp->patient[d3.seq].
     radiology_doc[cnt].blob = trim(blob_out2), temp->patient[d3.seq].radiology_doc[cnt].event_cd =
     rad.event_cd,
     hold_event_id = ce.event_id
    ENDIF
   FOOT  o.person_id
    temp->patient[d3.seq].rd_cnt = cnt
   WITH nocounter, memsort
  ;end select
 ENDIF
 IF (progress_note_ind=1
  AND (temp2->pro_cnt > 0))
  CALL echo("Prog notes")
  SET cnt = 0
  SELECT INTO "nl:"
   sze = textlen(cb.blob_contents)
   FROM (dummyt d  WITH seq = value(max_enc_cnt)),
    (dummyt d2  WITH seq = value(temp2->pro_cnt)),
    (dummyt d3  WITH seq = value(patient_cnt)),
    clinical_event ce,
    clinical_event ce2,
    ce_blob_result cbr,
    ce_blob cb,
    prsnl pl,
    v500_event_code vec
   PLAN (d3
    WHERE maxrec(d,temp->patient[d3.seq].encntr_cnt) > 0)
    JOIN (ce
    WHERE (ce.person_id=temp->patient[d3.seq].demographics.person_id)
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.updt_dt_tm >= cnvtdatetime(beg_dt_tm)
     AND ce.updt_dt_tm <= cnvtdatetime(end_dt_tm)
     AND ce.result_status_cd != inerror_cd
     AND ce.event_class_cd IN (doc_cd, mdoc_cd))
    JOIN (d
    WHERE (ce.encntr_id=temp->patient[d3.seq].encntr[d.seq].encntr_id))
    JOIN (d2
    WHERE (ce.event_cd=temp2->pro[d2.seq].pro_event_cd))
    JOIN (ce2
    WHERE ce2.parent_event_id=ce.event_id
     AND ce2.view_level=0
     AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00")
     AND ce2.publish_flag=1)
    JOIN (cbr
    WHERE cbr.event_id=ce2.event_id
     AND cbr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
    JOIN (cb
    WHERE cb.event_id=ce2.event_id
     AND cb.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
    JOIN (pl
    WHERE pl.person_id=ce.performed_prsnl_id)
    JOIN (vec
    WHERE vec.event_cd=ce.event_cd)
   ORDER BY ce.person_id, cnvtdatetime(ce.event_end_dt_tm) DESC, d2.seq,
    ce2.parent_event_id
   HEAD ce.person_id
    hold_event_id = 0, cnt = 0
   DETAIL
    IF (ce2.parent_event_id=hold_event_id)
     blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," "), blob_out3 = fillstring(
      32000," ")
     IF (cb.compression_cd=ocfcomp_cd)
      blob_out = fillstring(32000," "), blob_ret_len = 0,
      CALL uar_ocf_uncompress(cb.blob_contents,sze,blob_out,32000,blob_ret_len)
     ELSE
      blob_out = fillstring(32000," "), y1 = size(trim(cb.blob_contents)), blob_out = substring(1,(y1
        - 8),cb.blob_contents)
     ENDIF
     CALL uar_rtf2(blob_out,textlen(blob_out),blob_out2,32000,32000,0), temp->patient[d3.seq].
     progress_note[cnt].blob = concat(temp->patient[d3.seq].progress_note[cnt].blob," | ",trim(
       blob_out2))
    ELSE
     cnt = (cnt+ 1), stat = alterlist(temp->patient[d3.seq].progress_note,cnt), blob_out = fillstring
     (32000," "),
     blob_out2 = fillstring(32000," "), blob_out3 = fillstring(32000," ")
     IF (cb.compression_cd=ocfcomp_cd)
      blob_out = fillstring(32000," "), blob_ret_len = 0,
      CALL uar_ocf_uncompress(cb.blob_contents,sze,blob_out,32000,blob_ret_len)
     ELSE
      blob_out = fillstring(32000," "), y1 = size(trim(cb.blob_contents)), blob_out = substring(1,(y1
        - 8),cb.blob_contents)
     ENDIF
     temp->patient[d3.seq].progress_note[cnt].event_end_dt_tm = format(ce.event_end_dt_tm,
      "mm/dd hh:mm;;d"), temp->patient[d3.seq].progress_note[cnt].author = concat(trim(pl
       .name_full_formatted)), temp->patient[d3.seq].progress_note[cnt].doc_name = trim(vec
      .event_set_name),
     CALL uar_rtf2(blob_out,textlen(blob_out),blob_out2,32000,32000,0), temp->patient[d3.seq].
     progress_note[cnt].blob = trim(blob_out2), temp->patient[d3.seq].progress_note[cnt].event_cd =
     ce.event_cd,
     temp->patient[d3.seq].progress_note[cnt].event_cd_seq = d2.seq, temp->patient[d3.seq].
     progress_note[cnt].sort_by_dt_tm = format(ce.event_end_dt_tm,"yy/mm/dd hh:mm;;d"), hold_event_id
      = ce.event_id
    ENDIF
   FOOT  ce.person_id
    temp->patient[d3.seq].pn_cnt = cnt
   WITH nocounter, memsort
  ;end select
  DECLARE pro_foreign_ind = i2 WITH noconstant(0)
  SELECT INTO "nl:"
   sze = textlen(cb.blob_contents)
   FROM (dummyt d  WITH seq = value(max_enc_cnt)),
    (dummyt d2  WITH seq = value(temp2->pro_cnt)),
    (dummyt d3  WITH seq = value(patient_cnt)),
    clinical_event ce,
    ce_blob_result cbr,
    ce_blob cb,
    prsnl pl,
    v500_event_code vec
   PLAN (d3
    WHERE maxrec(d,temp->patient[d3.seq].encntr_cnt) > 0)
    JOIN (ce
    WHERE (ce.person_id=temp->patient[d3.seq].demographics.person_id)
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.updt_dt_tm >= cnvtdatetime(beg_dt_tm)
     AND ce.updt_dt_tm <= cnvtdatetime(end_dt_tm)
     AND ce.result_status_cd != inerror_cd
     AND ce.event_class_cd IN (doc_cd, mdoc_cd))
    JOIN (d
    WHERE (ce.encntr_id=temp->patient[d3.seq].encntr[d.seq].encntr_id))
    JOIN (d2
    WHERE (ce.event_cd=temp2->pro[d2.seq].pro_event_cd))
    JOIN (cbr
    WHERE cbr.event_id=ce.event_id
     AND cbr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
    JOIN (cb
    WHERE cb.event_id=ce.event_id
     AND cb.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
    JOIN (pl
    WHERE pl.person_id=ce.performed_prsnl_id)
    JOIN (vec
    WHERE vec.event_cd=ce.event_cd)
   ORDER BY d3.seq, cnvtdatetime(ce.event_end_dt_tm) DESC, d2.seq
   HEAD d3.seq
    hold_event_id = 0
    IF ((temp->patient[d3.seq].pn_cnt > 0))
     cnt = temp->patient[d3.seq].pn_cnt
    ELSE
     cnt = 0
    ENDIF
   DETAIL
    IF (ce.parent_event_id=hold_event_id)
     blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," "), blob_out3 = fillstring(
      32000," ")
     IF (cb.compression_cd=ocfcomp_cd)
      blob_out = fillstring(32000," "), blob_ret_len = 0,
      CALL uar_ocf_uncompress(cb.blob_contents,sze,blob_out,32000,blob_ret_len)
     ELSE
      blob_out = fillstring(32000," "), y1 = size(trim(cb.blob_contents)), blob_out = substring(1,(y1
        - 8),cb.blob_contents)
     ENDIF
     CALL uar_rtf2(blob_out,textlen(blob_out),blob_out2,32000,32000,0), temp->patient[d3.seq].
     progress_note[cnt].blob = concat(temp->patient[d3.seq].progress_note[cnt].blob," | ",trim(
       blob_out2))
    ELSE
     cnt = (cnt+ 1), pro_foreign_ind = 1, stat = alterlist(temp->patient[d3.seq].progress_note,cnt),
     blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," "), blob_out3 = fillstring(
      32000," ")
     IF (cb.compression_cd=ocfcomp_cd)
      blob_out = fillstring(32000," "), blob_ret_len = 0,
      CALL uar_ocf_uncompress(cb.blob_contents,sze,blob_out,32000,blob_ret_len)
     ELSE
      blob_out = fillstring(32000," "), y1 = size(trim(cb.blob_contents)), blob_out = substring(1,(y1
        - 8),cb.blob_contents)
     ENDIF
     temp->patient[d3.seq].progress_note[cnt].event_end_dt_tm = format(ce.event_end_dt_tm,
      "mm/dd hh:mm;;d"), temp->patient[d3.seq].progress_note[cnt].author = concat(trim(pl
       .name_full_formatted)), temp->patient[d3.seq].progress_note[cnt].doc_name = trim(vec
      .event_set_name),
     CALL uar_rtf2(blob_out,textlen(blob_out),blob_out2,32000,32000,0), temp->patient[d3.seq].
     progress_note[cnt].blob = trim(blob_out2), temp->patient[d3.seq].progress_note[cnt].event_cd =
     ce.event_cd,
     temp->patient[d3.seq].progress_note[cnt].event_cd_seq = d2.seq, temp->patient[d3.seq].
     progress_note[cnt].sort_by_dt_tm = format(ce.event_end_dt_tm,"yy/mm/dd hh:mm;;d"), hold_event_id
      = ce.event_id
    ENDIF
   FOOT  d3.seq
    temp->patient[d3.seq].pn_cnt = cnt
   WITH nocounter, memsort
  ;end select
  IF (pro_foreign_ind=1)
   DECLARE pn_event_cd = f8
   DECLARE pn_event_cd_seq = i2
   DECLARE pn_encntr_id = f8
   DECLARE pn_doc_name = vc
   DECLARE pn_blob = vc
   DECLARE pn_event_end_dt_tm = vc
   DECLARE pn_author = vc
   DECLARE pn_cnt = i2
   DECLARE pn_sort_by_dt_tm = vc
   FOR (c = 1 TO patient_cnt)
    SET size_array = temp->patient[c].pn_cnt
    FOR (y = 1 TO (size_array - 1))
      FOR (x = 1 TO (size_array - y))
       SET skipswap = 0
       IF ((temp->patient[c].progress_note[x].sort_by_dt_tm <= temp->patient[c].progress_note[(x+ 1)]
       .sort_by_dt_tm))
        IF ((temp->patient[c].progress_note[x].event_end_dt_tm=temp->patient[c].progress_note[(x+ 1)]
        .event_end_dt_tm))
         IF ((temp->patient[c].progress_note[x].event_cd_seq < temp->patient[c].progress_note[(x+ 1)]
         .event_cd_seq))
          SET skipswap = 1
         ENDIF
        ENDIF
        IF (skipswap=0)
         SET pn_event_cd = temp->patient[c].progress_note[x].event_cd
         SET temp->patient[c].progress_note[x].event_cd = temp->patient[c].progress_note[(x+ 1)].
         event_cd
         SET temp->patient[c].progress_note[(x+ 1)].event_cd = pn_event_cd
         SET pn_encntr_id = temp->patient[c].progress_note[x].encntr_id
         SET temp->patient[c].progress_note[x].encntr_id = temp->patient[c].progress_note[(x+ 1)].
         encntr_id
         SET temp->patient[c].progress_note[(x+ 1)].encntr_id = pn_encntr_id
         SET pn_doc_name = temp->patient[c].progress_note[x].doc_name
         SET temp->patient[c].progress_note[x].doc_name = temp->patient[c].progress_note[(x+ 1)].
         doc_name
         SET temp->patient[c].progress_note[(x+ 1)].doc_name = pn_doc_name
         SET pn_blob = temp->patient[c].progress_note[x].blob
         SET temp->patient[c].progress_note[x].blob = temp->patient[c].progress_note[(x+ 1)].blob
         SET temp->patient[c].progress_note[(x+ 1)].blob = pn_blob
         SET pn_event_end_dt_tm = temp->patient[c].progress_note[x].event_end_dt_tm
         SET temp->patient[c].progress_note[x].event_end_dt_tm = temp->patient[c].progress_note[(x+ 1
         )].event_end_dt_tm
         SET temp->patient[c].progress_note[(x+ 1)].event_end_dt_tm = pn_event_end_dt_tm
         SET pn_author = temp->patient[c].progress_note[x].author
         SET temp->patient[c].progress_note[x].author = temp->patient[c].progress_note[(x+ 1)].author
         SET temp->patient[c].progress_note[(x+ 1)].author = pn_author
         SET pn_cnt = temp->patient[c].progress_note[x].pn_cnt
         SET temp->patient[c].progress_note[x].pn_cnt = temp->patient[c].progress_note[(x+ 1)].pn_cnt
         SET temp->patient[c].progress_note[(x+ 1)].pn_cnt = pn_cnt
         SET pn_event_cd_seq = temp->patient[c].progress_note[x].event_cd_seq
         SET temp->patient[c].progress_note[x].event_cd_seq = temp->patient[c].progress_note[(x+ 1)].
         event_cd_seq
         SET temp->patient[c].progress_note[(x+ 1)].event_cd_seq = pn_event_cd_seq
         SET pn_sort_by_dt_tm = temp->patient[c].progress_note[x].sort_by_dt_tm
         SET temp->patient[c].progress_note[x].sort_by_dt_tm = temp->patient[c].progress_note[(x+ 1)]
         .sort_by_dt_tm
         SET temp->patient[c].progress_note[(x+ 1)].sort_by_dt_tm = pn_sort_by_dt_tm
        ENDIF
       ENDIF
      ENDFOR
    ENDFOR
   ENDFOR
  ENDIF
 ENDIF
 IF (io_ind)
  DECLARE root_event_set_cd = f8 WITH public, noconstant(0.0)
  SELECT INTO "nl:"
   FROM name_value_prefs nvp,
    v500_event_set_code vesc
   PLAN (nvp
    WHERE nvp.pvc_name="I_EVENT_SET_NAME")
    JOIN (vesc
    WHERE nvp.pvc_value=vesc.event_set_name)
   DETAIL
    root_event_set_cd = vesc.event_set_cd
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   weekday = weekday(c.event_end_dt_tm)
   FROM (dummyt d3  WITH seq = value(patient_cnt)),
    v500_event_set_canon vesc,
    v500_event_set_canon vesc2,
    v500_event_set_canon vesc3,
    v500_event_set_explode vese,
    v500_event_code vec,
    v500_event_set_code ves,
    clinical_event c,
    person p,
    ce_med_result cemr
   PLAN (d3)
    JOIN (vesc
    WHERE vesc.parent_event_set_cd=root_event_set_cd)
    JOIN (vesc2
    WHERE vesc2.parent_event_set_cd=vesc.event_set_cd)
    JOIN (vesc3
    WHERE vesc2.event_set_cd=vesc3.parent_event_set_cd)
    JOIN (vese
    WHERE vesc3.event_set_cd=vese.event_set_cd)
    JOIN (vec
    WHERE vec.event_cd=vese.event_cd)
    JOIN (ves
    WHERE ves.event_set_cd=vese.event_set_cd
     AND ves.accumulation_ind=1)
    JOIN (c
    WHERE (c.person_id=temp->patient[d3.seq].demographics.person_id)
     AND c.view_level=1
     AND c.publish_flag=1
     AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND c.updt_dt_tm >= cnvtdatetime(beg_dt_tm)
     AND c.updt_dt_tm < cnvtdatetime(end_dt_tm)
     AND c.result_status_cd != inerror_cd
     AND c.event_cd=vese.event_cd)
    JOIN (cemr
    WHERE outerjoin(c.event_id)=cemr.event_id)
    JOIN (p
    WHERE c.person_id=p.person_id)
   ORDER BY c.person_id, cnvtdatetime(c.event_end_dt_tm) DESC
   HEAD c.person_id
    cnt = 0, temp->patient[d3.seq].io_cnt = 0, stat = alterlist(temp->patient[d3.seq].io,7)
   HEAD weekday
    IF (cnt < 7)
     cnt = (cnt+ 1), temp->patient[d3.seq].io_cnt = (temp->patient[d3.seq].io_cnt+ 1), temp->patient[
     d3.seq].io[cnt].intake = 0.00,
     temp->patient[d3.seq].io[cnt].output = 0.00, temp->patient[d3.seq].io[cnt].balance = 0.00
    ENDIF
   DETAIL
    IF (cnt < 8)
     temp->patient[d3.seq].io[cnt].io_dt_tm = format(c.event_end_dt_tm,"mm/dd;r;d")
     IF (vesc.event_set_collating_seq=1)
      IF (c.event_class_cd=med_cd)
       IF (cemr.admin_dosage > 0
        AND ((cemr.dosage_unit_cd=ml_cd) OR (cemr.dosage_unit_cd=cc_cd)) )
        temp->patient[d3.seq].io[cnt].intake = (temp->patient[d3.seq].io[cnt].intake+ cemr
        .admin_dosage)
       ELSEIF (cemr.infused_volume > 0
        AND ((cemr.infused_volume_unit_cd=ml_cd) OR (cemr.infused_volume_unit_cd=cc_cd)) )
        temp->patient[d3.seq].io[cnt].intake = (temp->patient[d3.seq].io[cnt].intake+ cemr
        .infused_volume)
       ENDIF
      ELSE
       temp->patient[d3.seq].io[cnt].intake = (temp->patient[d3.seq].io[cnt].intake+ cnvtreal(trim(c
         .event_tag,3)))
      ENDIF
     ENDIF
     IF (vesc.event_set_collating_seq=2)
      temp->patient[d3.seq].io[cnt].output = (temp->patient[d3.seq].io[cnt].output+ cnvtreal(trim(c
        .event_tag,3)))
     ENDIF
     temp->patient[d3.seq].io[cnt].balance = (temp->patient[d3.seq].io[cnt].intake - temp->patient[d3
     .seq].io[cnt].output)
    ENDIF
  ;end select
 ENDIF
 IF (lab_result_ind=0
  AND nurse_result_ind=0
  AND med_order_ind=0
  AND pending_order_ind=0
  AND active_order_ind=0
  AND documents_ind=0
  AND radiology_ind=0
  AND progress_note_ind=0)
  GO TO print_report
 ENDIF
 IF (vieworder_secur_cd=0
  AND viewresult_secur_cd=0)
  GO TO print_report
 ENDIF
#order_viewing_privs
 IF (((vieworder_secur_cd=0) OR (med_order_ind=0
  AND pending_order_ind=0
  AND active_order_ind=0)) )
  GO TO result_viewing_privs
 ENDIF
 SET temp2->oe_cnt = 0
 SELECT INTO "nl:"
  FROM privilege_exception p
  PLAN (p
   WHERE p.privilege_id=vieworder_secur_id
    AND p.exception_id > 0
    AND p.exception_entity_name IN ("ORDER CATALOG", "CATALOG TYPE", "ACTIVITY TYPE")
    AND p.active_ind=1)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp2->oe,cnt)
   IF (p.exception_entity_name="ORDER CATALOG")
    temp2->oe[cnt].oe_type_flag = "O", temp2->oe[cnt].catalog_cd = p.exception_id
   ELSEIF (p.exception_entity_name="CATALOG TYPE")
    temp2->oe[cnt].oe_type_flag = "C", temp2->oe[cnt].catalog_type_cd = p.exception_id
   ELSE
    temp2->oe[cnt].oe_type_flag = "A", temp2->oe[cnt].activity_type_cd = p.exception_id
   ENDIF
  FOOT REPORT
   temp2->oe_cnt = cnt
  WITH nocounter
 ;end select
 FOR (x = 1 TO patient_cnt)
   IF (pending_order_ind=1)
    SET hold->o_cnt = 0
    SET q = temp->patient[x].po_cnt
    FOR (y = 1 TO q)
      SET match_found = "N"
      FOR (z = 1 TO temp2->oe_cnt)
        IF ((((temp2->oe[z].oe_type_flag="O")
         AND (temp2->oe[z].catalog_cd=temp->patient[x].pending_order[y].catalog_cd)) OR ((((temp2->
        oe[z].oe_type_flag="C")
         AND (temp2->oe[z].catalog_type_cd=temp->patient[x].pending_order[y].catalog_type_cd)) OR ((
        temp2->oe[z].oe_type_flag="A")
         AND (temp2->oe[z].activity_type_cd=temp->patient[x].pending_order[y].activity_type_cd))) ))
        )
         SET match_found = "Y"
         SET z = temp2->oe_cnt
        ENDIF
      ENDFOR
      IF (((vieworder_secur_cd=include_cd
       AND match_found="Y") OR (vieworder_secur_cd=exclude_cd
       AND match_found="N")) )
       SET hold->o_cnt = (hold->o_cnt+ 1)
       SET stat = alterlist(hold->o,hold->o_cnt)
       SET hold->o[hold->o_cnt].catalog_cd = temp->patient[x].pending_order[y].catalog_cd
       SET hold->o[hold->o_cnt].catalog_type_cd = temp->patient[x].pending_order[y].catalog_type_cd
       SET hold->o[hold->o_cnt].activity_type_cd = temp->patient[x].pending_order[y].activity_type_cd
       SET hold->o[hold->o_cnt].order_id = temp->patient[x].pending_order[y].order_id
       SET hold->o[hold->o_cnt].mnemonic = temp->patient[x].pending_order[y].mnemonic
       SET hold->o[hold->o_cnt].display_line = temp->patient[x].pending_order[y].display_line
      ENDIF
    ENDFOR
    IF ((hold->o_cnt != q))
     SET stat = alterlist(temp->patient[x].pending_order,hold->o_cnt)
     SET temp->patient[x].po_cnt = hold->o_cnt
     FOR (y = 1 TO hold->o_cnt)
       SET temp->patient[x].pending_order[y].catalog_cd = hold->o[y].catalog_cd
       SET temp->patient[x].pending_order[y].catalog_type_cd = hold->o[y].catalog_type_cd
       SET temp->patient[x].pending_order[y].activity_type_cd = hold->o[y].activity_type_cd
       SET temp->patient[x].pending_order[y].order_id = hold->o[y].order_id
       SET temp->patient[x].pending_order[y].mnemonic = hold->o[y].mnemonic
       SET temp->patient[x].pending_order[y].display_line = hold->o[y].display_line
     ENDFOR
    ENDIF
   ENDIF
   IF (active_order_ind=1)
    SET hold->o_cnt = 0
    SET q = temp->patient[x].ao_cnt
    FOR (y = 1 TO q)
      SET match_found = "N"
      FOR (z = 1 TO temp2->oe_cnt)
        IF ((((temp2->oe[z].oe_type_flag="O")
         AND (temp2->oe[z].catalog_cd=temp->patient[x].active_order[y].catalog_cd)) OR ((((temp2->oe[
        z].oe_type_flag="C")
         AND (temp2->oe[z].catalog_type_cd=temp->patient[x].active_order[y].catalog_type_cd)) OR ((
        temp2->oe[z].oe_type_flag="A")
         AND (temp2->oe[z].activity_type_cd=temp->patient[x].active_order[y].activity_type_cd))) )) )
         SET match_found = "Y"
         SET z = temp2->oe_cnt
        ENDIF
      ENDFOR
      IF (((vieworder_secur_cd=include_cd
       AND match_found="Y") OR (vieworder_secur_cd=exclude_cd
       AND match_found="N")) )
       SET hold->o_cnt = (hold->o_cnt+ 1)
       SET stat = alterlist(hold->o,hold->o_cnt)
       SET hold->o[hold->o_cnt].catalog_cd = temp->patient[x].active_order[y].catalog_cd
       SET hold->o[hold->o_cnt].catalog_type_cd = temp->patient[x].active_order[y].catalog_type_cd
       SET hold->o[hold->o_cnt].activity_type_cd = temp->patient[x].active_order[y].activity_type_cd
       SET hold->o[hold->o_cnt].order_id = temp->patient[x].active_order[y].order_id
       SET hold->o[hold->o_cnt].mnemonic = temp->patient[x].active_order[y].mnemonic
       SET hold->o[hold->o_cnt].display_line = temp->patient[x].active_order[y].display_line
      ENDIF
    ENDFOR
    IF ((hold->o_cnt != q))
     SET stat = alterlist(temp->patient[x].active_order,hold->o_cnt)
     SET temp->patient[x].ao_cnt = hold->o_cnt
     FOR (y = 1 TO hold->o_cnt)
       SET temp->patient[x].active_order[y].catalog_cd = hold->o[y].catalog_cd
       SET temp->patient[x].active_order[y].catalog_type_cd = hold->o[y].catalog_type_cd
       SET temp->patient[x].active_order[y].activity_type_cd = hold->o[y].activity_type_cd
       SET temp->patient[x].active_order[y].order_id = hold->o[y].order_id
       SET temp->patient[x].active_order[y].mnemonic = hold->o[y].mnemonic
       SET temp->patient[x].active_order[y].display_line = hold->o[y].display_line
     ENDFOR
    ENDIF
   ENDIF
   IF (med_order_ind=1)
    SET hold->o_cnt = 0
    SET q = temp->patient[x].mo_cnt
    FOR (y = 1 TO q)
      SET match_found = "N"
      FOR (z = 1 TO temp2->oe_cnt)
        IF ((((temp2->oe[z].oe_type_flag="O")
         AND (temp2->oe[z].catalog_cd=temp->patient[x].med_order[y].catalog_cd)) OR ((((temp2->oe[z].
        oe_type_flag="C")
         AND (temp2->oe[z].catalog_type_cd=temp->patient[x].med_order[y].catalog_type_cd)) OR ((temp2
        ->oe[z].oe_type_flag="A")
         AND (temp2->oe[z].activity_type_cd=temp->patient[x].med_order[y].activity_type_cd))) )) )
         SET match_found = "Y"
         SET z = temp2->oe_cnt
        ENDIF
      ENDFOR
      IF (((vieworder_secur_cd=include_cd
       AND match_found="Y") OR (vieworder_secur_cd=exclude_cd
       AND match_found="N")) )
       SET hold->o_cnt = (hold->o_cnt+ 1)
       SET stat = alterlist(hold->o,hold->o_cnt)
       SET hold->o[hold->o_cnt].catalog_cd = temp->patient[x].med_order[y].catalog_cd
       SET hold->o[hold->o_cnt].catalog_type_cd = temp->patient[x].med_order[y].catalog_type_cd
       SET hold->o[hold->o_cnt].activity_type_cd = temp->patient[x].med_order[y].activity_type_cd
       SET hold->o[hold->o_cnt].order_id = temp->patient[x].med_order[y].order_id
       SET hold->o[hold->o_cnt].mnemonic = temp->patient[x].med_order[y].mnemonic
       SET hold->o[hold->o_cnt].display_line = temp->patient[x].med_order[y].display_line
       SET hold->o[hold->o_cnt].route = temp->patient[x].med_order[y].route
       SET hold->o[hold->o_cnt].dose = temp->patient[x].med_order[y].dose
       SET hold->o[hold->o_cnt].doseunit = temp->patient[x].med_order[y].doseunit
       SET hold->o[hold->o_cnt].frequency = temp->patient[x].med_order[y].frequency
       SET hold->o[hold->o_cnt].dnum = temp->patient[x].med_order[y].dnum
      ENDIF
    ENDFOR
    IF ((hold->o_cnt != q))
     SET stat = alterlist(temp->patient[x].med_order,hold->o_cnt)
     SET temp->patient[x].mo_cnt = hold->o_cnt
     FOR (y = 1 TO hold->o_cnt)
       SET temp->patient[x].med_order[y].catalog_cd = hold->o[y].catalog_cd
       SET temp->patient[x].med_order[y].catalog_type_cd = hold->o[y].catalog_type_cd
       SET temp->patient[x].med_order[y].activity_type_cd = hold->o[y].activity_type_cd
       SET temp->patient[x].med_order[y].order_id = hold->o[y].order_id
       SET temp->patient[x].med_order[y].mnemonic = hold->o[y].mnemonic
       SET temp->patient[x].med_order[y].display_line = hold->o[y].display_line
       SET temp->patient[x].med_order[y].route = hold->o[y].route
       SET temp->patient[x].med_order[y].dose = hold->o[y].dose
       SET temp->patient[x].med_order[y].doseunit = hold->o[y].doseunit
       SET temp->patient[x].med_order[y].frequency = hold->o[y].frequency
       SET temp->patient[x].med_order[y].dnum = hold->o[y].dnum
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
#result_viewing_privs
 IF (((viewresult_secur_cd=0) OR (lab_result_ind=0
  AND nurse_result_ind=0
  AND radiology_ind=0
  AND progress_note_ind=0
  AND documents_ind=0)) )
  GO TO print_report
 ENDIF
 SET temp2->re_cnt = 0
 SELECT INTO "nl:"
  FROM privilege_exception p
  PLAN (p
   WHERE p.privilege_id=viewresult_secur_id
    AND p.exception_id > 0
    AND p.exception_entity_name="V500_EVENT_CODE"
    AND p.active_ind=1)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp2->re,cnt), temp2->re[cnt].event_cd = p.exception_id
  FOOT REPORT
   temp2->re_cnt = cnt
  WITH nocounter
 ;end select
 SET esm = fillstring(100," ")
 SELECT INTO "nl:"
  FROM privilege_exception p,
   (dummyt d  WITH seq = 1),
   code_value c,
   v500_event_set_canon vesc,
   v500_event_set_explode vese
  PLAN (p
   WHERE p.privilege_id=viewresult_secur_id
    AND p.event_set_name > " "
    AND p.exception_entity_name="V500_EVENT_SET_CODE"
    AND p.active_ind=1)
   JOIN (d
   WHERE assign(esm,cnvtalphanum(p.event_set_name)))
   JOIN (c
   WHERE c.code_set=93
    AND trim(c.display_key)=trim(cnvtupper(esm))
    AND c.active_ind=1)
   JOIN (vesc
   WHERE vesc.parent_event_set_cd=c.code_value)
   JOIN (vese
   WHERE vese.event_set_cd=vesc.event_set_cd)
  HEAD REPORT
   cnt = temp2->re_cnt
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp2->re,cnt), temp2->re[cnt].event_cd = vese.event_cd
  FOOT REPORT
   temp2->re_cnt = cnt
  WITH nocounter
 ;end select
 FOR (x = 1 TO patient_cnt)
   IF (lab_result_ind=1)
    SET hold->r_cnt = 0
    SET q = temp->patient[x].lr_cnt
    FOR (y = 1 TO q)
      SET match_found = "N"
      FOR (z = 1 TO temp2->re_cnt)
        IF ((temp2->re[z].event_cd=temp->patient[x].lab_result[y].event_cd))
         SET match_found = "Y"
         SET z = temp2->re_cnt
        ENDIF
      ENDFOR
      IF (((viewresult_secur_cd=include_cd
       AND match_found="Y") OR (viewresult_secur_cd=exclude_cd
       AND match_found="N")) )
       SET hold->r_cnt = (hold->r_cnt+ 1)
       SET stat = alterlist(hold->r,hold->r_cnt)
       SET hold->r[hold->r_cnt].event_cd = temp->patient[x].lab_result[y].event_cd
       SET hold->r[hold->r_cnt].event_name = temp->patient[x].lab_result[y].event_name
       SET hold->r[hold->r_cnt].result_value = temp->patient[x].lab_result[y].result_value
       SET hold->r[hold->r_cnt].order_id = temp->patient[x].lab_result[y].order_id
       SET hold->r[hold->r_cnt].verify_dt_tm = temp->patient[x].lab_result[y].verify_dt_tm
       SET hold->r[hold->r_cnt].event_end_dt_tm = temp->patient[x].lab_result[y].event_end_dt_tm
       SET hold->r[hold->r_cnt].normalcy_disp = temp->patient[x].lab_result[y].normalcy_disp
       SET hold->r[hold->r_cnt].ref_range = temp->patient[x].lab_result[y].ref_range
       SET hold->r[hold->r_cnt].note = temp->patient[x].lab_result[y].note
      ENDIF
    ENDFOR
    IF ((hold->r_cnt != q))
     SET stat = alterlist(temp->patient[x].lab_result,hold->r_cnt)
     SET temp->patient[x].lr_cnt = hold->o_cnt
     FOR (y = 1 TO hold->r_cnt)
       SET temp->patient[x].lab_result[y].event_cd = hold->r[y].event_cd
       SET temp->patient[x].lab_result[y].event_name = hold->r[y].event_name
       SET temp->patient[x].lab_result[y].result_value = hold->r[y].result_value
       SET temp->patient[x].lab_result[y].order_id = hold->r[y].order_id
       SET temp->patient[x].lab_result[y].verify_dt_tm = hold->r[y].verify_dt_tm
       SET temp->patient[x].lab_result[y].event_end_dt_tm = hold->r[y].event_end_dt_tm
       SET temp->patient[x].lab_result[y].normalcy_disp = hold->r[y].normalcy_disp
       SET temp->patient[x].lab_result[y].ref_range = hold->r[y].ref_range
       SET temp->patient[x].lab_result[y].note = hold->r[y].note
     ENDFOR
    ENDIF
   ENDIF
   IF (nurse_result_ind=1)
    SET hold->r_cnt = 0
    SET q = temp->patient[x].pcr_cnt
    FOR (y = 1 TO q)
      SET match_found = "N"
      FOR (z = 1 TO temp2->re_cnt)
        IF ((temp2->re[z].event_cd=temp->patient[x].patient_care_result[y].event_cd))
         SET match_found = "Y"
         SET z = temp2->re_cnt
        ENDIF
      ENDFOR
      IF (((viewresult_secur_cd=include_cd
       AND match_found="Y") OR (viewresult_secur_cd=exclude_cd
       AND match_found="N")) )
       SET hold->r_cnt = (hold->r_cnt+ 1)
       SET stat = alterlist(hold->r,hold->r_cnt)
       SET hold->r[hold->r_cnt].event_cd = temp->patient[x].patient_care_result[y].event_cd
       SET hold->r[hold->r_cnt].event_name = temp->patient[x].patient_care_result[y].event_name
       SET hold->r[hold->r_cnt].result_val = temp->patient[x].patient_care_result[y].result_value
       SET hold->r[hold->r_cnt].order_id = temp->patient[x].patient_care_result[y].order_id
       SET hold->r[hold->r_cnt].verify_dt_tm = temp->patient[x].patient_care_result[y].verify_dt_tm
       SET hold->r[hold->r_cnt].event_end_dt_tm = temp->patient[x].patient_care_result[y].
       event_end_dt_tm
       SET hold->r[hold->r_cnt].normalcy_disp = temp->patient[x].patient_care_result[y].normalcy_disp
       SET hold->r[hold->r_cnt].ref_range = temp->patient[x].patient_care_result[y].ref_range
       SET hold->r[hold->r_cnt].note = temp->patient[x].patient_care_result[y].note
      ENDIF
    ENDFOR
    IF ((hold->r_cnt != q))
     SET stat = alterlist(temp->patient[x].patient_care_result,hold->r_cnt)
     SET temp->patient[x].pcr_cnt = hold->o_cnt
     FOR (y = 1 TO hold->r_cnt)
       SET temp->patient[x].patient_care_result[y].event_cd = hold->r[y].event_cd
       SET temp->patient[x].patient_care_result[y].event_name = hold->r[y].event_name
       SET temp->patient[x].patient_care_result[y].result_value = hold->r[y].result_value
       SET temp->patient[x].patient_care_result[y].order_id = hold->r[y].order_id
       SET temp->patient[x].patient_care_result[y].verify_dt_tm = hold->r[y].verify_dt_tm
       SET temp->patient[x].patient_care_result[y].event_end_dt_tm = hold->r[y].event_end_dt_tm
       SET temp->patient[x].patient_care_result[y].normalcy_disp = hold->r[y].normalcy_disp
       SET temp->patient[x].patient_care_result[y].ref_range = hold->r[y].ref_range
       SET temp->patient[x].patient_care_result[y].note = hold->r[y].note
     ENDFOR
    ENDIF
   ENDIF
   IF (documents_ind=1)
    SET hold->r_cnt = 0
    SET q = temp->patient[x].od_cnt
    FOR (y = 1 TO q)
      SET match_found = "N"
      FOR (z = 1 TO temp2->re_cnt)
        IF ((temp2->re[z].event_cd=temp->patient[x].other_doc[y].event_cd))
         SET match_found = "Y"
         SET z = temp2->re_cnt
        ENDIF
      ENDFOR
      IF (((viewresult_secur_cd=include_cd
       AND match_found="Y") OR (viewresult_secur_cd=exclude_cd
       AND match_found="N")) )
       SET hold->r_cnt = (hold->r_cnt+ 1)
       SET stat = alterlist(hold->r,hold->r_cnt)
       SET hold->r[hold->r_cnt].event_cd = temp->patient[x].other_doc[y].event_cd
       SET hold->r[hold->r_cnt].doc_name = temp->patient[x].other_doc[y].doc_name
       SET hold->r[hold->r_cnt].doc_blob = temp->patient[x].other_doc[y].blob
       SET hold->r[hold->r_cnt].event_end_dt_tm = temp->patient[x].other_doc[y].event_end_dt_tm
       SET hold->r[hold->r_cnt].doc_author = temp->patient[x].other_doc[y].author
      ENDIF
    ENDFOR
    IF ((hold->r_cnt != q))
     SET stat = alterlist(temp->patient[x].other_doc,hold->r_cnt)
     SET temp->patient[x].od_cnt = hold->o_cnt
     FOR (y = 1 TO hold->r_cnt)
       SET temp->patient[x].other_doc[y].event_cd = hold->r[y].event_cd
       SET temp->patient[x].other_doc[y].doc_name = hold->r[y].doc_name
       SET temp->patient[x].other_doc[y].blob = hold->r[y].doc_blob
       SET temp->patient[x].other_doc[y].event_end_dt_tm = hold->r[y].event_end_dt_tm
       SET temp->patient[x].other_doc[y].author = hold->r[y].doc_author
     ENDFOR
    ENDIF
   ENDIF
   IF (radiology_ind=1)
    SET hold->r_cnt = 0
    SET q = temp->patient[x].rd_cnt
    FOR (y = 1 TO q)
      SET match_found = "N"
      FOR (z = 1 TO temp2->re_cnt)
        IF ((temp2->re[z].event_cd=temp->patient[x].radiology_doc[y].event_cd))
         SET match_found = "Y"
         SET z = temp2->re_cnt
        ENDIF
      ENDFOR
      IF (((viewresult_secur_cd=include_cd
       AND match_found="Y") OR (viewresult_secur_cd=exclude_cd
       AND match_found="N")) )
       SET hold->r_cnt = (hold->r_cnt+ 1)
       SET stat = alterlist(hold->r,hold->r_cnt)
       SET hold->r[hold->r_cnt].event_cd = temp->patient[x].radiology_doc[y].event_cd
       SET hold->r[hold->r_cnt].doc_name = temp->patient[x].radiology_doc[y].doc_name
       SET hold->r[hold->r_cnt].doc_blob = temp->patient[x].radiology_doc[y].blob
       SET hold->r[hold->r_cnt].event_end_dt_tm = temp->patient[x].radiology_doc[y].event_end_dt_tm
       SET hold->r[hold->r_cnt].doc_author = temp->patient[x].radiology_doc[y].author
      ENDIF
    ENDFOR
    IF ((hold->r_cnt != q))
     SET stat = alterlist(temp->patient[x].radiology_doc,hold->r_cnt)
     SET temp->patient[x].rd_cnt = hold->o_cnt
     FOR (y = 1 TO hold->r_cnt)
       SET temp->patient[x].radiology_doc[y].event_cd = hold->r[y].event_cd
       SET temp->patient[x].radiology_doc[y].doc_name = hold->r[y].doc_name
       SET temp->patient[x].radiology_doc[y].blob = hold->r[y].doc_blob
       SET temp->patient[x].radiology_doc[y].event_end_dt_tm = hold->r[y].event_end_dt_tm
       SET temp->patient[x].radiology_doc[y].author = hold->r[y].doc_author
     ENDFOR
    ENDIF
   ENDIF
   IF (progress_note_ind=1)
    SET hold->r_cnt = 0
    SET q = temp->patient[x].pn_cnt
    FOR (y = 1 TO q)
      SET match_found = "N"
      FOR (z = 1 TO temp2->re_cnt)
        IF ((temp2->re[z].event_cd=temp->patient[x].progress_note[y].event_cd))
         SET match_found = "Y"
         SET z = temp2->re_cnt
        ENDIF
      ENDFOR
      IF (((viewresult_secur_cd=include_cd
       AND match_found="Y") OR (viewresult_secur_cd=exclude_cd
       AND match_found="N")) )
       SET hold->r_cnt = (hold->r_cnt+ 1)
       SET stat = alterlist(hold->r,hold->r_cnt)
       SET hold->r[hold->r_cnt].event_cd = temp->patient[x].progress_note[y].event_cd
       SET hold->r[hold->r_cnt].doc_name = temp->patient[x].progress_note[y].doc_name
       SET hold->r[hold->r_cnt].doc_blob = temp->patient[x].progress_note[y].blob
       SET hold->r[hold->r_cnt].event_end_dt_tm = temp->patient[x].progress_note[y].event_end_dt_tm
       SET hold->r[hold->r_cnt].doc_author = temp->patient[x].progress_note[y].author
      ENDIF
    ENDFOR
    IF ((hold->r_cnt != q))
     SET stat = alterlist(temp->patient[x].progress_note,hold->r_cnt)
     SET temp->patient[x].pn_cnt = hold->o_cnt
     FOR (y = 1 TO hold->r_cnt)
       SET temp->patient[x].progress_note[y].event_cd = hold->r[y].event_cd
       SET temp->patient[x].progress_note[y].doc_name = hold->r[y].doc_name
       SET temp->patient[x].progress_note[y].blob = hold->r[y].doc_blob
       SET temp->patient[x].progress_note[y].event_end_dt_tm = hold->r[y].event_end_dt_tm
       SET temp->patient[x].progress_note[y].author = hold->r[y].doc_author
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
#print_report
 FOR (x = 1 TO patient_cnt)
   IF ((temp->patient[x].demographics.allergies > " "))
    IF (substring(40,20,temp->patient[x].demographics.allergies) > " ")
     SET pt->line_cnt = 0
     SET max_length = 40
     EXECUTE dcp_parse_text value(temp->patient[x].demographics.allergies), value(max_length)
     SET stat = alterlist(temp->patient[x].demographics.all_tag,pt->line_cnt)
     SET temp->patient[x].demographics.all_ln_cnt = pt->line_cnt
     FOR (w = 1 TO pt->line_cnt)
       SET temp->patient[x].demographics.all_tag[w].all_line = pt->lns[w].line
     ENDFOR
    ELSE
     SET stat = alterlist(temp->patient[x].demographics.all_tag,1)
     SET temp->patient[x].demographics.all_ln_cnt = 1
     SET temp->patient[x].demographics.all_tag[1].all_line = temp->patient[x].demographics.allergies
    ENDIF
   ENDIF
   IF ((temp->patient[x].demographics.problems > " "))
    IF (substring(40,20,temp->patient[x].demographics.problems) > " ")
     SET pt->line_cnt = 0
     SET max_length = 40
     EXECUTE dcp_parse_text value(temp->patient[x].demographics.problems), value(max_length)
     SET stat = alterlist(temp->patient[x].demographics.prob_tag,pt->line_cnt)
     SET temp->patient[x].demographics.prob_ln_cnt = pt->line_cnt
     FOR (w = 1 TO pt->line_cnt)
       SET temp->patient[x].demographics.prob_tag[w].prob_line = pt->lns[w].line
     ENDFOR
    ELSE
     SET stat = alterlist(temp->patient[x].demographics.prob_tag,1)
     SET temp->patient[x].demographics.prob_ln_cnt = 1
     SET temp->patient[x].demographics.prob_tag[1].prob_line = temp->patient[x].demographics.problems
    ENDIF
   ENDIF
   IF ((temp->patient[x].demographics.reason_for_visit > " "))
    IF (substring(33,20,temp->patient[x].demographics.reason_for_visit) > " ")
     SET pt->line_cnt = 0
     SET max_length = 33
     EXECUTE dcp_parse_text value(temp->patient[x].demographics.reason_for_visit), value(max_length)
     SET stat = alterlist(temp->patient[x].demographics.reason_tag,pt->line_cnt)
     SET temp->patient[x].demographics.reason_ln_cnt = pt->line_cnt
     FOR (w = 1 TO pt->line_cnt)
       SET temp->patient[x].demographics.reason_tag[w].reason_line = pt->lns[w].line
     ENDFOR
    ELSE
     SET stat = alterlist(temp->patient[x].demographics.reason_tag,1)
     SET temp->patient[x].demographics.reason_ln_cnt = 1
     SET temp->patient[x].demographics.reason_tag[1].reason_line = temp->patient[x].demographics.
     reason_for_visit
    ENDIF
   ENDIF
   FOR (y = 1 TO temp->patient[x].lr_cnt)
     SET max_length = 17
     IF (textlen(temp->patient[x].lab_result[y].event_name) > max_length)
      SET pt->line_cnt = 0
      EXECUTE dcp_parse_text value(temp->patient[x].lab_result[y].event_name), value(max_length)
      SET stat = alterlist(temp->patient[x].lab_result[y].en_tag,pt->line_cnt)
      SET temp->patient[x].lab_result[y].en_cnt = pt->line_cnt
      FOR (w = 1 TO pt->line_cnt)
        SET temp->patient[x].lab_result[y].en_tag[w].en_line = pt->lns[w].line
      ENDFOR
     ELSE
      SET stat = alterlist(temp->patient[x].lab_result[y].en_tag,1)
      SET temp->patient[x].lab_result[y].en_cnt = 1
      SET temp->patient[x].lab_result[y].en_tag[1].en_line = temp->patient[x].lab_result[y].
      event_name
     ENDIF
     IF (textlen(temp->patient[x].lab_result[y].result_value) > max_length)
      SET pt->line_cnt = 0
      EXECUTE dcp_parse_text value(temp->patient[x].lab_result[y].result_value), value(max_length)
      SET stat = alterlist(temp->patient[x].lab_result[y].rv_tag,pt->line_cnt)
      SET temp->patient[x].lab_result[y].rv_cnt = pt->line_cnt
      FOR (w = 1 TO pt->line_cnt)
        SET temp->patient[x].lab_result[y].rv_tag[w].rv_line = pt->lns[w].line
      ENDFOR
     ELSE
      SET stat = alterlist(temp->patient[x].lab_result[y].rv_tag,1)
      SET temp->patient[x].lab_result[y].rv_cnt = 1
      SET temp->patient[x].lab_result[y].rv_tag[1].rv_line = temp->patient[x].lab_result[y].
      result_value
     ENDIF
     IF (textlen(temp->patient[x].lab_result[y].ref_range) > max_length)
      SET pt->line_cnt = 0
      EXECUTE dcp_parse_text value(temp->patient[x].lab_result[y].ref_range), value(max_length)
      SET stat = alterlist(temp->patient[x].lab_result[y].rr_tag,pt->line_cnt)
      SET temp->patient[x].lab_result[y].rr_cnt = pt->line_cnt
      FOR (w = 1 TO pt->line_cnt)
        SET temp->patient[x].lab_result[y].rr_tag[w].rr_line = pt->lns[w].line
      ENDFOR
     ELSE
      SET stat = alterlist(temp->patient[x].lab_result[y].rr_tag,1)
      SET temp->patient[x].lab_result[y].rr_cnt = 1
      SET temp->patient[x].lab_result[y].rr_tag[1].rr_line = temp->patient[x].lab_result[y].ref_range
     ENDIF
     SET temp->patient[x].lab_result[y].lr_line_cnt = maxval(temp->patient[x].lab_result[y].en_cnt,
      temp->patient[x].lab_result[y].rv_cnt,temp->patient[x].lab_result[y].rr_cnt)
     IF (((mod(y,2) > 0) OR (y=1)) )
      SET temp->patient[x].lab_result_dt_grp[temp->patient[x].lab_result[y].lab_result_dt_grp_id].
      lr_tot_odd_line_cnt = (temp->patient[x].lab_result_dt_grp[temp->patient[x].lab_result[y].
      lab_result_dt_grp_id].lr_tot_odd_line_cnt+ temp->patient[x].lab_result[y].lr_line_cnt)
      SET temp->patient[x].lab_result_dt_grp[temp->patient[x].lab_result[y].lab_result_dt_grp_id].
      lr_left_index = y
     ELSE
      SET temp->patient[x].lab_result_dt_grp[temp->patient[x].lab_result[y].lab_result_dt_grp_id].
      lr_tot_even_line_cnt = (temp->patient[x].lab_result_dt_grp[temp->patient[x].lab_result[y].
      lab_result_dt_grp_id].lr_tot_even_line_cnt+ temp->patient[x].lab_result[y].lr_line_cnt)
     ENDIF
     SET temp->patient[x].lab_result_dt_grp[temp->patient[x].lab_result[y].lab_result_dt_grp_id].
     lr_high_line_cnt = maxval(temp->patient[x].lab_result_dt_grp[temp->patient[x].lab_result[y].
      lab_result_dt_grp_id].lr_tot_even_line_cnt,temp->patient[x].lab_result_dt_grp[temp->patient[x].
      lab_result[y].lab_result_dt_grp_id].lr_tot_odd_line_cnt)
   ENDFOR
   FOR (y = 1 TO temp->patient[x].mo_cnt)
    IF (substring(17,10,temp->patient[x].med_order[y].mnemonic) > " ")
     SET pt->line_cnt = 0
     SET max_length = 17
     EXECUTE dcp_parse_text value(temp->patient[x].med_order[y].mnemonic), value(max_length)
     SET stat = alterlist(temp->patient[x].med_order[y].mnem_tag,pt->line_cnt)
     SET temp->patient[x].med_order[y].mnem_cnt = pt->line_cnt
     FOR (w = 1 TO pt->line_cnt)
       SET temp->patient[x].med_order[y].mnem_tag[w].mnem_line = pt->lns[w].line
     ENDFOR
    ELSE
     SET stat = alterlist(temp->patient[x].med_order[y].mnem_tag,1)
     SET temp->patient[x].med_order[y].mnem_cnt = 1
     SET temp->patient[x].med_order[y].mnem_tag[1].mnem_line = temp->patient[x].med_order[y].mnemonic
    ENDIF
    IF (substring(30,10,temp->patient[x].med_order[y].display_line) > " ")
     SET pt->line_cnt = 0
     SET max_length = 30
     EXECUTE dcp_parse_text value(temp->patient[x].med_order[y].display_line), value(max_length)
     SET stat = alterlist(temp->patient[x].med_order[y].dl_tag,pt->line_cnt)
     SET temp->patient[x].med_order[y].dl_cnt = pt->line_cnt
     FOR (w = 1 TO pt->line_cnt)
       SET temp->patient[x].med_order[y].dl_tag[w].dl_line = pt->lns[w].line
     ENDFOR
    ELSE
     SET stat = alterlist(temp->patient[x].med_order[y].dl_tag,1)
     SET temp->patient[x].med_order[y].dl_cnt = 1
     SET temp->patient[x].med_order[y].dl_tag[1].dl_line = temp->patient[x].med_order[y].display_line
    ENDIF
   ENDFOR
   FOR (y = 1 TO temp->patient[x].rd_cnt)
     SET pt->line_cnt = 0
     SET max_length = 80
     EXECUTE dcp_parse_text value(temp->patient[x].radiology_doc[y].blob), value(max_length)
     SET stat = alterlist(temp->patient[x].radiology_doc[y].rd_tag,pt->line_cnt)
     SET temp->patient[x].radiology_doc[y].rd_cnt = pt->line_cnt
     FOR (w = 1 TO pt->line_cnt)
       SET temp->patient[x].radiology_doc[y].rd_tag[w].rd_line = pt->lns[w].line
     ENDFOR
   ENDFOR
   FOR (y = 1 TO temp->patient[x].pn_cnt)
     SET pt->line_cnt = 0
     SET max_length = 80
     EXECUTE dcp_parse_text value(temp->patient[x].progress_note[y].blob), value(max_length)
     SET stat = alterlist(temp->patient[x].progress_note[y].pn_tag,pt->line_cnt)
     SET temp->patient[x].progress_note[y].pn_cnt = pt->line_cnt
     FOR (w = 1 TO pt->line_cnt)
       SET temp->patient[x].progress_note[y].pn_tag[w].pn_line = pt->lns[w].line
     ENDFOR
   ENDFOR
   FOR (y = 1 TO temp->patient[x].od_cnt)
     SET pt->line_cnt = 0
     SET max_length = 80
     EXECUTE dcp_parse_text value(temp->patient[x].other_doc[y].blob), value(max_length)
     SET stat = alterlist(temp->patient[x].other_doc[y].od_tag,pt->line_cnt)
     SET temp->patient[x].other_doc[y].od_cnt = pt->line_cnt
     FOR (w = 1 TO pt->line_cnt)
       SET temp->patient[x].other_doc[y].od_tag[w].od_line = pt->lns[w].line
     ENDFOR
   ENDFOR
   FOR (y = 1 TO temp->patient[x].pcr_cnt)
     SET pt->line_cnt = 0
     SET max_length = 17
     EXECUTE dcp_parse_text value(temp->patient[x].patient_care_result[y].event_name), value(
      max_length)
     SET stat = alterlist(temp->patient[x].patient_care_result[y].en_tag,pt->line_cnt)
     SET temp->patient[x].patient_care_result[y].en_cnt = pt->line_cnt
     FOR (w = 1 TO pt->line_cnt)
       SET temp->patient[x].patient_care_result[y].en_tag[w].en_line = pt->lns[w].line
     ENDFOR
     SET pt->line_cnt = 0
     SET max_length = 17
     EXECUTE dcp_parse_text value(temp->patient[x].patient_care_result[y].result_value), value(
      max_length)
     SET stat = alterlist(temp->patient[x].patient_care_result[y].rv_tag,pt->line_cnt)
     SET temp->patient[x].patient_care_result[y].rv_cnt = pt->line_cnt
     FOR (w = 1 TO pt->line_cnt)
       SET temp->patient[x].patient_care_result[y].rv_tag[w].rv_line = pt->lns[w].line
     ENDFOR
     SET pt->line_cnt = 0
     SET max_length = 17
     EXECUTE dcp_parse_text value(temp->patient[x].patient_care_result[y].ref_range), value(
      max_length)
     SET stat = alterlist(temp->patient[x].patient_care_result[y].rr_tag,pt->line_cnt)
     SET temp->patient[x].patient_care_result[y].rr_cnt = pt->line_cnt
     FOR (w = 1 TO pt->line_cnt)
       SET temp->patient[x].patient_care_result[y].rr_tag[w].rr_line = pt->lns[w].line
     ENDFOR
   ENDFOR
   FOR (y = 1 TO temp->patient[x].po_cnt)
     IF (substring(60,10,temp->patient[x].pending_order[y].display_line) > " ")
      SET pt->line_cnt = 0
      SET max_length = 55
      EXECUTE dcp_parse_text value(temp->patient[x].pending_order[y].display_line), value(max_length)
      SET stat = alterlist(temp->patient[x].pending_order[y].dl_tag,pt->line_cnt)
      SET temp->patient[x].pending_order[y].dl_cnt = pt->line_cnt
      FOR (w = 1 TO pt->line_cnt)
        SET temp->patient[x].pending_order[y].dl_tag[w].dl_line = pt->lns[w].line
      ENDFOR
     ELSE
      SET stat = alterlist(temp->patient[x].pending_order[y].dl_tag,1)
      SET temp->patient[x].pending_order[y].dl_cnt = 1
      SET temp->patient[x].pending_order[y].dl_tag[1].dl_line = temp->patient[x].pending_order[y].
      display_line
     ENDIF
   ENDFOR
   FOR (y = 1 TO temp->patient[x].ao_cnt)
     IF (substring(60,10,temp->patient[x].active_order[y].display_line) > " ")
      SET pt->line_cnt = 0
      SET max_length = 55
      EXECUTE dcp_parse_text value(temp->patient[x].active_order[y].display_line), value(max_length)
      SET stat = alterlist(temp->patient[x].active_order[y].dl_tag,pt->line_cnt)
      SET temp->patient[x].active_order[y].dl_cnt = pt->line_cnt
      FOR (w = 1 TO pt->line_cnt)
        SET temp->patient[x].active_order[y].dl_tag[w].dl_line = pt->lns[w].line
      ENDFOR
     ELSE
      SET stat = alterlist(temp->patient[x].active_order[y].dl_tag,1)
      SET temp->patient[x].active_order[y].dl_cnt = 1
      SET temp->patient[x].active_order[y].dl_tag[1].dl_line = temp->patient[x].active_order[y].
      display_line
     ENDIF
   ENDFOR
   FOR (y = 1 TO temp->patient[x].sn_cnt)
     SET pt->line_cnt = 0
     SET max_length = 55
     EXECUTE dcp_parse_text value(temp->patient[x].sticky_note[y].note), value(max_length)
     SET stat = alterlist(temp->patient[x].sticky_note[y].note_tag,pt->line_cnt)
     SET temp->patient[x].sticky_note[y].note_cnt = pt->line_cnt
     FOR (w = 1 TO pt->line_cnt)
       SET temp->patient[x].sticky_note[y].note_tag[w].note_line = pt->lns[w].line
     ENDFOR
   ENDFOR
 ENDFOR
 SET printed_by = "                                     "
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id=reqinfo->updt_id))
  DETAIL
   printed_by = p.name_full_formatted
  WITH nocounter
 ;end select
 FOR (p = 1 TO patient_cnt)
   SELECT INTO request->output_device
    d1.seq
    FROM (dummyt d1  WITH seq = 1)
    PLAN (d1)
    HEAD REPORT
     MACRO (does_dt_grp_fit)
      CALL echo("***"),
      CALL echo("***   does_dt_grp_fit"),
      CALL echo("***"),
      CALL echo(build("***      b_idx :",b_idx)),
      CALL echo(build("***      m_idx :",m_idx)),
      CALL echo(build("***      e_idx :",e_idx)),
      dt_grp_fit = true, c_idx = b_idx, left_line_knt = 0,
      temp_line_knt = 0,
      CALL echo("***      enter c_idx <= m_idx")
      WHILE (c_idx <= m_idx)
        CALL echo(build("***      c_idx :",c_idx)), temp_line_knt = temp->patient[p].lab_result[c_idx
        ].en_cnt
        IF ((temp->patient[p].lab_result[c_idx].rv_cnt > temp_line_knt))
         temp_line_knt = temp->patient[p].lab_result[c_idx].rv_cnt
        ENDIF
        IF ((temp->patient[p].lab_result[c_idx].rr_cnt > temp_line_knt))
         temp_line_knt = temp->patient[p].lab_result[c_idx].rr_cnt
        ENDIF
        CALL echo(build("***         left_line_knt :",left_line_knt)),
        CALL echo(build("***         temp_line_knt :",temp_line_knt)), left_line_knt = (left_line_knt
        + temp_line_knt),
        CALL echo(build("***         left_line_knt = left_line_knt + temp_line_knt :",left_line_knt)),
        c_idx = (c_idx+ 1)
      ENDWHILE
      right_line_knt = 0, temp_line_knt = 0,
      CALL echo("***      enter c_idx <= e_idx")
      WHILE (c_idx <= e_idx)
        CALL echo(build("***      c_idx :",c_idx)), temp_line_knt = temp->patient[p].lab_result[c_idx
        ].en_cnt
        IF ((temp->patient[p].lab_result[c_idx].rv_cnt > temp_line_knt))
         temp_line_knt = temp->patient[p].lab_result[c_idx].rv_cnt
        ENDIF
        IF ((temp->patient[p].lab_result[c_idx].rr_cnt > temp_line_knt))
         temp_line_knt = temp->patient[p].lab_result[c_idx].rr_cnt
        ENDIF
        CALL echo(build("***         right_line_knt :",right_line_knt)),
        CALL echo(build("***         temp_line_knt :",temp_line_knt)), right_line_knt = (
        right_line_knt+ temp_line_knt),
        CALL echo(build("***         right_line_knt = right_line_knt + temp_line_knt :",
         right_line_knt)), c_idx = (c_idx+ 1)
      ENDWHILE
      left_ycol_knt = (left_line_knt * 12), right_ycol_knt = (right_line_knt * 12),
      CALL echo(build("***      left_line_knt  :",left_line_knt)),
      CALL echo(build("***      left_ycol_knt  :",left_ycol_knt)),
      CALL echo(build("***      right_line_knt :",right_line_knt)),
      CALL echo(build("***      right_ycol_knt :",right_ycol_knt)),
      CALL echo(build("***      ycol           :",ycol)),
      CALL echo(build("***      650 - ycol - left_ycol_knt - 36  :",(((650 - ycol) - left_ycol_knt)
        - 36))),
      CALL echo(build("***      650 - ycol - right_ycol_knt - 36 :",(((650 - ycol) - right_ycol_knt)
        - 36)))
      IF (((((((650 - ycol) - left_ycol_knt) - 36) < 0)) OR (((((650 - ycol) - right_ycol_knt) - 36)
       < 0))) )
       dt_grp_fit = false
      ENDIF
     ENDMACRO
     ,
     MACRO (print_dt_grp_head)
      CALL echo("***"),
      CALL echo("***   print_dt_grp_head"),
      CALL echo("***")
      IF (has_printed_dt_grp_header=false)
       CALL print(calcpos(xcol,ycol)), temp->patient[p].lab_result[f_idx].event_end_dt_tm, dot_line,
       has_printed_dt_grp_header = true
      ELSE
       CALL print(calcpos(xcol,ycol)), temp->patient[p].lab_result[f_idx].event_end_dt_tm,
       " Continued",
       dot_line
      ENDIF
      ycol = (ycol+ 12), row + 1
     ENDMACRO
     ,
     MACRO (print_dt_grp)
      CALL echo("***"),
      CALL echo("***   print_dt_grp"),
      CALL echo("***"),
      c_idx = b_idx, top_left_ycol = ycol, last_ycol = ycol,
      last_left_ycol = ycol, current_lab_top_ycol = ycol
      WHILE (c_idx <= e_idx)
        IF (c_idx <= m_idx)
         print_lab_side = "L"
        ELSE
         print_lab_side = "R"
        ENDIF
        ycol = current_lab_top_ycol, print_lab, current_lab_top_ycol = last_ycol,
        c_idx = (c_idx+ 1)
        IF ((c_idx=(m_idx+ 1))
         AND c_idx <= e_idx)
         last_left_ycol = last_ycol, current_lab_top_ycol = top_left_ycol, last_ycol =
         current_lab_top_ycol
        ENDIF
      ENDWHILE
      IF (last_ycol > last_left_ycol)
       ycol = last_ycol
      ELSE
       ycol = last_left_ycol
      ENDIF
     ENDMACRO
     ,
     MACRO (print_lab)
      CALL echo("***"),
      CALL echo("***   print_lab"),
      CALL echo("***")
      IF (print_lab_side="L")
       xcol1 = 30, xcol2 = 120, xcol3 = 210
      ELSE
       xcol1 = 300, xcol2 = 390, xcol3 = 480
      ENDIF
      temp_top_ycol = ycol, last_ycol = ycol
      IF ((temp->patient[p].lab_result[c_idx].en_cnt > 0))
       FOR (l_idx = 1 TO temp->patient[p].lab_result[c_idx].en_cnt)
         CALL print(calcpos(xcol1,ycol)), temp->patient[p].lab_result[c_idx].en_tag[l_idx].en_line,
         ycol = (ycol+ 12),
         row + 1
       ENDFOR
      ENDIF
      IF (ycol > last_ycol)
       last_ycol = ycol
      ENDIF
      ycol = temp_top_ycol
      IF ((temp->patient[p].lab_result[c_idx].rv_cnt > 0))
       FOR (l_idx = 1 TO temp->patient[p].lab_result[c_idx].rv_cnt)
         CALL print(calcpos(xcol2,ycol)), temp->patient[p].lab_result[c_idx].rv_tag[l_idx].rv_line,
         ycol = (ycol+ 12),
         row + 1
       ENDFOR
      ENDIF
      IF (ycol > last_ycol)
       last_ycol = ycol
      ENDIF
      ycol = temp_top_ycol
      IF ((temp->patient[p].lab_result[c_idx].rr_cnt > 0))
       FOR (l_idx = 1 TO temp->patient[p].lab_result[c_idx].rr_cnt)
         CALL print(calcpos(xcol3,ycol)), temp->patient[p].lab_result[c_idx].rr_tag[l_idx].rr_line,
         ycol = (ycol+ 12),
         row + 1
       ENDFOR
      ENDIF
      IF (ycol > last_ycol)
       last_ycol = ycol
      ENDIF
      ycol = last_ycol
     ENDMACRO
     ,
     MACRO (does_lab_fit)
      CALL echo("***"),
      CALL echo("***   does_lab_fit"),
      CALL echo("***"),
      lab_fit = true, lab_row_knt = 0, lab_row_knt = temp->patient[p].lab_result[c_idx].en_cnt
      IF ((temp->patient[p].lab_result[c_idx].rv_cnt > lab_row_knt))
       lab_row_knt = temp->patient[p].lab_result[c_idx].rv_cnt
      ENDIF
      IF ((temp->patient[p].lab_result[c_idx].rr_cnt > lab_row_knt))
       lab_row_knt = temp->patient[p].lab_result[c_idx].rr_cnt
      ENDIF
      lab_ycol_knt = (lab_row_knt * 12),
      CALL echo(build("***      lab_row_knt  :",lab_row_knt)),
      CALL echo(build("***      lab_ycol_knt :",lab_ycol_knt)),
      CALL echo(build("***      ycol         :",ycol)),
      CALL echo(build("***      650 - ycol - lab_ycol_knt - 36  :",(((650 - ycol) - lab_ycol_knt) -
       36)))
      IF (((((650 - ycol) - lab_ycol_knt) - 36) < 0))
       lab_fit = false
      ENDIF
     ENDMACRO
     ,
     MACRO (print_partial_lab)
      CALL echo("***"),
      CALL echo("***   print_partial_lab"),
      CALL echo("***"),
      xcol1 = 30, xcol2 = 120, xcol3 = 210,
      CALL print(calcpos(xcol1,ycol)), temp->patient[p].lab_result[c_idx].en_tag[1].en_line, row + 1,
      CALL print(calcpos(xcol2,ycol)), "Large Lab", row + 1,
      CALL print(calcpos(xcol3,ycol)), "See Flowsheet", row + 1,
      ycol = (ycol+ 12)
     ENDMACRO
     ,
     MACRO (lab_page_break)
      CALL echo("***"),
      CALL echo("***   lab_page_break"),
      CALL echo("***"),
      BREAK,
      CALL print(calcpos(xcol,ycol)), "{f/8}{b}Labs (cont): {endb}{f/0}",
      ycol = (ycol+ 12), xcol = 30, last_ycol = ycol,
      row + 1
     ENDMACRO
     ,
     MACRO (does_next_pat_care_fit)
      pc_cnt = maxval(temp->patient[p].patient_care_result[z].en_cnt,temp->patient[p].
       patient_care_result[z].rv_cnt,temp->patient[p].patient_care_result[z].rr_cnt)
      IF ((((pc_cnt * 12)+ (ycol+ 36)) > 650))
       next_pat_care_fits = false
      ELSE
       next_pat_care_fits = true
      ENDIF
     ENDMACRO
     ,
     MACRO (pat_care_page_break)
      BREAK,
      CALL print(calcpos(xcol,ycol)), "{f/8}{b}Patient Care Results (cont): {endb}{f/0}",
      row + 1, ycol = (ycol+ 12), xcol = 30,
      lycol = ycol, rycol = ycol, save_lycol = lycol,
      save_rycol = rycol, save_dt_tm = "                               ", left_right = "L",
      newdate = (newdate - 1), next_lab_fits = true
     ENDMACRO
     ,
     MACRO (pending_order_break)
      BREAK,
      CALL print(calcpos(xcol,ycol)), "{f/8}{b}Pending Orders (cont): {endb}{f/0}",
      row + 1, ycol = (ycol+ 12)
     ENDMACRO
     ,
     MACRO (active_order_break)
      BREAK,
      CALL print(calcpos(xcol,ycol)), "{f/8}{b}Active Orders (cont): {endb}{f/0}",
      row + 1, ycol = (ycol+ 12)
     ENDMACRO
     ,
     MACRO (med_order_break)
      BREAK,
      CALL print(calcpos(xcol,ycol)), "{f/8}{b}Medication Orders (cont): {endb}{f/0}",
      row + 1, ycol = (ycol+ 12), left_right = "L",
      save_lycol = ycol, save_rycol = ycol, lycol = ycol,
      rycol = ycol
     ENDMACRO
     ,
     MACRO (sch_order_break)
      CALL print(calcpos(xcol,ycol)), "{f/8}{b}Scheduled Medication Orders (cont): {endb}{f/0}", row
       + 1,
      ycol = (ycol+ 12), left_right = "L", save_lycol = ycol,
      save_rycol = ycol, lycol = ycol, rycol = ycol
     ENDMACRO
     ,
     MACRO (iv_order_break)
      CALL print(calcpos(xcol,ycol)), "{f/8}{b}Continuous IV Orders (cont): {endb}{f/0}", row + 1,
      ycol = (ycol+ 12), left_right = "L", save_lycol = ycol,
      save_rycol = ycol, lycol = ycol, rycol = ycol
     ENDMACRO
     ,
     MACRO (prn_order_break)
      CALL print(calcpos(xcol,ycol)), "{f/8}{b}PRN Medication Orders (cont): {endb}{f/0}", row + 1,
      ycol = (ycol+ 12), left_right = "L", save_lycol = ycol,
      save_rycol = ycol, lycol = ycol, rycol = ycol
     ENDMACRO
     ,
     line = fillstring(115,"_"), dot_line = fillstring(100,"-"), continue_ind = 1,
     xcol = 0, ycol = 0, save_ycol = 0,
     order_ind = 0, thead = fillstring(115," "), line_cnt = 0,
     b_dt = cnvtdatetime(beg_dt_tm), e_dt = cnvtdatetime(end_dt_tm), newdate = 0,
     pc_cnt = 0, lab_cnt = 0, print_flag = 0,
     max_length = 57, parse_length = 0, pt->line_cnt = 0,
     cur_print_col = 1, label_data = fillstring(57," "), parse_string = fillstring(250," "),
     label = fillstring(57," "), next_lab_fits = true, next_pat_care_fits = true,
     remain_page_lines = 0, all_labs_fit = false, lr_start_left_idx = 0,
     lr_end_left_idx = 0, lr_start_right_idx = 0, lr_end_right_idx = 0,
     t_left_idx = 0, t_right_index = 0, t_remain_page_lines = 0,
     cont_ind = true, xcol1 = 0, xcol2 = 0,
     xcol3 = 0, lab_results_cont = true, lab_page_ind = false
    HEAD PAGE
     "{f/8}{cpi/12}", row + 1, "{cpi/14}{pos/450/45}",
     "Printed by: ", printed_by, row + 1,
     "{cpi/12}{pos/30/57}Patient Summary  ", "(", b_dt"mm/dd/yy hh:mm;;d",
     " to ", e_dt"mm/dd/yy hh:mm;;d", ")",
     row + 1, "{cpi/14}{pos/450/57}", "Printed on: ",
     curdate, " ", curtime,
     row + 1, "{cpi/15}{pos/30/63}", line,
     row + 1, "{cpi/12}{pos/30/75}", temp->patient[p].demographics.room_bed
     IF ((temp->patient[p].demographics.room_bed > " "))
      "{pos/100/75}{b}", temp->patient[p].demographics.name_full_formatted, " ",
      temp->patient[p].demographics.age, row + 1
     ELSE
      "{pos/30/75}{b}", temp->patient[p].demographics.name_full_formatted, " ",
      temp->patient[p].demographics.age, row + 1
     ENDIF
     "{pos/300/75}{b}MRN: ", temp->patient[p].demographics.mrn, "{endb}",
     row + 1, "{cpi/15}{pos/30/81}", line,
     row + 1, xcol = 30, ycol = 81,
     "{f/0}", row + 1, ycol = (ycol+ 12)
    DETAIL
     xcol = 30
     IF ((temp->patient[p].demographics.reason_ln_cnt > 0))
      FOR (z = 1 TO temp->patient[p].demographics.reason_ln_cnt)
        IF (z=1)
         CALL print(calcpos(xcol,ycol)), "Reason for Admission: ", temp->patient[p].demographics.
         reason_tag[z].reason_line
        ELSE
         CALL print(calcpos(xcol,ycol)), "{color/10}Reason for Admission: {color/0}", temp->patient[p
         ].demographics.reason_tag[z].reason_line
        ENDIF
        row + 1, ycol = (ycol+ 12)
      ENDFOR
     ENDIF
     CALL print(calcpos(xcol,ycol)), "Address: ", xcol = 95,
     CALL print(calcpos(xcol,ycol)), temp->patient[p].demographics.address1, row + 1,
     ycol = (ycol+ 12), xcol = 30
     IF ((temp->patient[p].demographics.address2 > " "))
      xcol = 95,
      CALL print(calcpos(xcol,ycol)), temp->patient[p].demographics.address2,
      row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->patient[p].demographics.address3 > " "))
      xcol = 95,
      CALL print(calcpos(xcol,ycol)), temp->patient[p].demographics.address3,
      row + 1, ycol = (ycol+ 12)
     ENDIF
     CALL print(calcpos(xcol,ycol)), "Phone: ", temp->patient[p].demographics.phone,
     row + 1, ycol = (ycol+ 12), xcol = 30,
     CALL print(calcpos(xcol,ycol)), "Attending: ", xcol = 100,
     CALL print(calcpos(xcol,ycol)), temp->patient[p].demographics.attending_doc, row + 1,
     ycol = (ycol+ 12), xcol = 30,
     CALL print(calcpos(xcol,ycol)),
     "Allergies: "
     IF ((temp->patient[p].demographics.all_ln_cnt > 0))
      FOR (z = 1 TO temp->patient[p].demographics.all_ln_cnt)
        xcol = 95,
        CALL print(calcpos(xcol,ycol)), temp->patient[p].demographics.all_tag[z].all_line,
        row + 1, ycol = (ycol+ 12)
      ENDFOR
     ELSE
      ycol = (ycol+ 12)
     ENDIF
     xcol = 30,
     CALL print(calcpos(xcol,ycol)), "Problems: "
     IF ((temp->patient[p].demographics.prob_ln_cnt > 0))
      FOR (z = 1 TO temp->patient[p].demographics.prob_ln_cnt)
        xcol = 95,
        CALL print(calcpos(xcol,ycol)), temp->patient[p].demographics.prob_tag[z].prob_line,
        row + 1, ycol = (ycol+ 12)
      ENDFOR
     ELSE
      ycol = (ycol+ 12)
     ENDIF
     IF ((temp->patient[p].sn_cnt > 0))
      xcol = 30
      FOR (z = 1 TO temp->patient[p].sn_cnt)
        xcol = 30,
        CALL print(calcpos(xcol,ycol)), "Sticky Note: "
        FOR (zz = 1 TO temp->patient[p].sticky_note[z].note_cnt)
          xcol = 95,
          CALL print(calcpos(xcol,ycol)), temp->patient[p].sticky_note[z].note_tag[zz].note_line,
          row + 1, ycol = (ycol+ 12)
        ENDFOR
      ENDFOR
     ENDIF
     save_ycol = ycol, ycol = 81, ycol = (ycol+ 12),
     xcol = 300,
     CALL print(calcpos(xcol,ycol)), "Insurance: ",
     temp->patient[p].demographics.insurance, row + 1, ycol = (ycol+ 12),
     xcol = 300,
     CALL print(calcpos(xcol,ycol)), "Contact: ",
     temp->patient[p].demographics.emergency_contact, row + 1, ycol = (ycol+ 12),
     xcol = 300,
     CALL print(calcpos(xcol,ycol)), "Contact Phone: ",
     temp->patient[p].demographics.emergency_contact_phone, row + 1, ycol = (ycol+ 12),
     xcol = 300,
     CALL print(calcpos(xcol,ycol)), "Admitting: ",
     temp->patient[p].demographics.admitting_doc, row + 1, ycol = (ycol+ 12)
     IF (save_ycol > ycol)
      ycol = save_ycol
     ENDIF
     ycol = (ycol - 6), xcol = 30,
     CALL print(calcpos(xcol,ycol)),
     line, row + 1, ycol = (ycol+ 12),
     xcol = 30
     IF (lab_result_ind=1)
      CALL echo("***"),
      CALL echo("***   lab_result_ind = 1"),
      CALL echo("***")
      IF (((ycol+ 36) >= 650))
       CALL echo("***"),
       CALL echo("***   ycol + 36 >= 650"),
       CALL echo("***"),
       BREAK
      ENDIF
      CALL print(calcpos(xcol,ycol)), "{f/8}{b}Labs: {endb}{f/0}", row + 1,
      ycol = (ycol+ 12), xcol = 30
      IF ((temp->patient[p].lr_cnt > 0))
       CALL echo("***"),
       CALL echo("***   temp->patient[p].lr_cnt"),
       CALL echo("***"),
       dt_grp_knt = size(temp->patient[p].lab_result_dt_grp,5),
       CALL echo("***"),
       CALL echo(build("***   dt_grp_knt :",dt_grp_knt)),
       CALL echo("***")
       FOR (d_idx = 1 TO dt_grp_knt)
         CALL echo("***"),
         CALL echo(build("***   d_idx :",d_idx)),
         CALL echo("***"),
         temp_last_ycol = 0, has_printed_dt_grp_header = false, b_idx = temp->patient[p].
         lab_result_dt_grp[d_idx].lab_result_first_idx,
         f_idx = b_idx, e_idx = temp->patient[p].lab_result_dt_grp[d_idx].lab_result_last_idx, m_idx
          = (((((e_idx - b_idx)+ 1)/ 2)+ b_idx) - 1),
         is_even = even(((e_idx - b_idx)+ 1))
         IF (is_even != true)
          m_idx = (m_idx+ 1)
         ENDIF
         does_dt_grp_fit
         IF (dt_grp_fit=true)
          print_dt_grp_head, print_dt_grp
         ELSE
          print_dt_grp_head, continue = true, printed_something = true,
          another_pass = false, start_lab_ycol = ycol, start_right_col_lab_print = false,
          printing_side = "L", print_lab_side = "L", temp_last_ycol = ycol
          WHILE (b_idx <= e_idx
           AND continue=true)
            IF (printed_something=true)
             printed_something = false
            ELSE
             another_pass = true
            ENDIF
            c_idx = b_idx
            IF (c_idx <= m_idx
             AND start_right_col_lab_print=false)
             print_lab_side = "L"
            ELSE
             IF (start_right_col_lab_print=false)
              start_right_col_lab_print = true, ycol = start_lab_ycol
             ENDIF
             print_lab_side = "R"
            ENDIF
            does_lab_fit
            IF (another_pass=true
             AND lab_fit=false)
             printed_something = true, another_pass = false, print_partial_lab
             IF (ycol > temp_last_ycol)
              temp_last_ycol = ycol
             ENDIF
            ELSEIF (lab_fit=true)
             c_idx = b_idx, print_lab
             IF (ycol > temp_last_ycol)
              temp_last_ycol = ycol
             ENDIF
             printed_something = true, another_pass = false
            ELSEIF (lab_fit=false
             AND print_lab_side="L")
             ycol = start_lab_ycol, start_right_col_lab_print = true, print_lab_side = "R",
             does_lab_fit
             IF (lab_fit=true)
              c_idx = b_idx, print_lab
              IF (ycol > temp_last_ycol)
               temp_last_ycol = ycol
              ENDIF
              printed_something = true, another_pass = false
             ELSE
              lab_page_break, start_right_col_lab_print = false, start_lab_ycol = ycol,
              m_idx = (((((e_idx - b_idx)+ 1)/ 2)+ b_idx) - 1), is_even = even(((e_idx - b_idx)+ 1))
              IF (is_even != true)
               m_idx = (m_idx+ 1)
              ENDIF
              print_dt_grp_head, start_lab_ycol = ycol, temp_last_ycol = ycol,
              does_dt_grp_fit
              IF (dt_grp_fit=true)
               print_dt_grp
               IF (ycol > temp_last_ycol)
                temp_last_ycol = ycol
               ENDIF
               continue = false, printed_something = true, another_pass = false
              ENDIF
             ENDIF
            ELSE
             lab_page_break, start_right_col_lab_print = false, start_lab_ycol = ycol,
             m_idx = (((((e_idx - b_idx)+ 1)/ 2)+ b_idx) - 1), is_even = even(((e_idx - b_idx)+ 1))
             IF (is_even != true)
              m_idx = (m_idx+ 1)
             ENDIF
             print_dt_grp_head, start_lab_ycol = ycol, temp_last_ycol = ycol,
             does_dt_grp_fit
             IF (dt_grp_fit=true)
              print_dt_grp
              IF (ycol > temp_last_ycol)
               temp_last_ycol = ycol
              ENDIF
              continue = false, printed_something = true, another_pass = false
             ENDIF
            ENDIF
            IF (printed_something=true)
             b_idx = (b_idx+ 1)
            ENDIF
          ENDWHILE
         ENDIF
         IF (temp_last_ycol > ycol)
          ycol = temp_last_ycol
         ENDIF
       ENDFOR
      ELSE
       CALL print(calcpos(xcol,ycol)), "There are no Lab results to report in this time range.", row
        + 1,
       ycol = (ycol+ 12)
      ENDIF
      ycol = (ycol - 6), xcol = 30,
      CALL print(calcpos(xcol,ycol)),
      line, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF (pending_order_ind=1)
      IF (((ycol+ 12) > 650))
       BREAK, ycol = 93
      ENDIF
      CALL print(calcpos(xcol,ycol)), "{f/8}{b}Pending Orders: {endb}{f/0}", row + 1,
      ycol = (ycol+ 12), xcol = 30
      IF ((temp->patient[p].po_cnt > 0))
       FOR (z = 1 TO temp->patient[p].po_cnt)
         IF ((((temp->patient[p].pending_order[z].dl_cnt * 12)+ (ycol+ 12)) >= 650))
          pending_order_break
         ENDIF
         xcol = 30,
         CALL print(calcpos(xcol,ycol)), temp->patient[p].pending_order[z].mnemonic,
         xcol = 300
         IF ((temp->patient[p].pending_order[z].dl_cnt > 0))
          FOR (zz = 1 TO temp->patient[p].pending_order[z].dl_cnt)
            CALL print(calcpos(xcol,ycol)), temp->patient[p].pending_order[z].dl_tag[zz].dl_line, row
             + 1,
            ycol = (ycol+ 12)
          ENDFOR
         ELSE
          ycol = (ycol+ 12), row + 1
         ENDIF
       ENDFOR
      ELSE
       CALL print(calcpos(xcol,ycol)), "There are no pending orders to report.", row + 1,
       ycol = (ycol+ 12)
      ENDIF
      ycol = (ycol - 6), xcol = 30,
      CALL print(calcpos(xcol,ycol)),
      line, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF (active_order_ind=1)
      IF (((ycol+ 12) > 650))
       BREAK, ycol = 93
      ENDIF
      CALL print(calcpos(xcol,ycol)), "{f/8}{b}Active Orders: {endb}{f/0}", row + 1,
      ycol = (ycol+ 12), xcol = 30
      IF ((temp->patient[p].ao_cnt > 0))
       FOR (z = 1 TO temp->patient[p].ao_cnt)
         IF ((((temp->patient[p].active_order[z].dl_cnt * 12)+ (ycol+ 12)) > 650))
          active_order_break
         ENDIF
         xcol = 30,
         CALL print(calcpos(xcol,ycol)), temp->patient[p].active_order[z].mnemonic,
         xcol = 300
         IF ((temp->patient[p].active_order[z].dl_cnt > 0))
          FOR (zz = 1 TO temp->patient[p].active_order[z].dl_cnt)
            CALL print(calcpos(xcol,ycol)), temp->patient[p].active_order[z].dl_tag[zz].dl_line, row
             + 1,
            ycol = (ycol+ 12)
          ENDFOR
         ELSE
          ycol = (ycol+ 12), row + 1
         ENDIF
       ENDFOR
      ELSE
       CALL print(calcpos(xcol,ycol)), "There are no active orders to report.", row + 1,
       ycol = (ycol+ 12)
      ENDIF
      ycol = (ycol - 6), xcol = 30,
      CALL print(calcpos(xcol,ycol)),
      line, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF (med_order_ind=1)
      IF (((ycol+ 12) > 650))
       BREAK, ycol = 93
      ENDIF
      CALL print(calcpos(xcol,ycol)), "{f/8}{b}Medication Orders: {endb}{f/0}", row + 1,
      ycol = (ycol+ 12), xcol = 30
      IF ((temp->patient[p].mo_cnt > 0))
       left_right = "L", save_lycol = ycol, save_rycol = ycol,
       lycol = ycol, rycol = ycol
       FOR (q = 1 TO 3)
        pp = 1,
        FOR (z = 1 TO temp->patient[p].mo_cnt)
          max_sch_cnt = maxval(temp->patient[p].med_order[z].mnem_cnt,temp->patient[p].med_order[z].
           dl_cnt)
          IF (q=1)
           IF (pp=1)
            IF (((ycol+ 12) > 650))
             BREAK
            ENDIF
            "{f/8}",
            CALL print(calcpos(xcol,ycol)), "{b}Scheduled Medication Orders: {endb}{f/0}",
            row + 1, ycol = (ycol+ 12), xcol = 30,
            pp = 2, left_right = "L", save_lycol = ycol,
            save_rycol = ycol, lycol = ycol, rycol = ycol
           ENDIF
           IF ((temp->patient[p].med_order[z].iv_ind=0)
            AND (temp->patient[p].med_order[z].prn_ind=0))
            IF ((((max_sch_cnt * 12)+ ycol) > 650))
             med_order_break, sch_order_break
            ENDIF
            IF (left_right="L")
             xcol = 30, ycol = lycol
             FOR (zz = 1 TO temp->patient[p].med_order[z].mnem_cnt)
               CALL print(calcpos(xcol,ycol)), temp->patient[p].med_order[z].mnem_tag[zz].mnem_line,
               ycol = (ycol+ 12)
             ENDFOR
             save_lycol = ycol, xcol = 140, ycol = lycol
             IF ((temp->patient[p].med_order[z].dl_cnt > 0))
              FOR (zz = 1 TO temp->patient[p].med_order[z].dl_cnt)
                CALL print(calcpos(xcol,ycol)), temp->patient[p].med_order[z].dl_tag[zz].dl_line, row
                 + 1,
                ycol = (ycol+ 12)
              ENDFOR
             ELSE
              ycol = (ycol+ 12), row + 1
             ENDIF
             IF (ycol > save_lycol)
              save_lycol = ycol
             ENDIF
             lycol = save_lycol, left_right = "R"
            ELSE
             xcol = 300, ycol = rycol
             FOR (zz = 1 TO temp->patient[p].med_order[z].mnem_cnt)
               CALL print(calcpos(xcol,ycol)), temp->patient[p].med_order[z].mnem_tag[zz].mnem_line,
               ycol = (ycol+ 12)
             ENDFOR
             save_rycol = ycol, xcol = 410, ycol = rycol
             IF ((temp->patient[p].med_order[z].dl_cnt > 0))
              FOR (zz = 1 TO temp->patient[p].med_order[z].dl_cnt)
                CALL print(calcpos(xcol,ycol)), temp->patient[p].med_order[z].dl_tag[zz].dl_line, row
                 + 1,
                ycol = (ycol+ 12)
              ENDFOR
             ELSE
              ycol = (ycol+ 12), row + 1
             ENDIF
             IF (ycol > save_rycol)
              save_rycol = ycol
             ENDIF
             rycol = save_rycol, left_right = "L"
             IF (save_rycol > save_lycol)
              save_lycol = save_rycol, ycol = save_lycol, lycol = ycol,
              rycol = ycol
             ENDIF
            ENDIF
           ENDIF
          ENDIF
          IF (q=2)
           IF (pp=1)
            row + 1, xcol = 30, ycol = lycol
            IF (((ycol+ 12) > 650))
             BREAK
            ENDIF
            "{f/8}",
            CALL print(calcpos(xcol,ycol)), "{b}Continuous IV Orders: {endb}{f/0}",
            row + 1, ycol = (ycol+ 12), xcol = 30,
            pp = 2, left_right = "L", save_lycol = ycol,
            save_rycol = ycol, lycol = ycol, rycol = ycol
           ENDIF
           IF ((temp->patient[p].med_order[z].iv_ind=1))
            IF ((((max_sch_cnt * 12)+ ycol) > 650))
             med_order_break, iv_order_break
            ENDIF
            IF (left_right="L")
             xcol = 30, ycol = lycol
             FOR (zz = 1 TO temp->patient[p].med_order[z].mnem_cnt)
               CALL print(calcpos(xcol,ycol)), temp->patient[p].med_order[z].mnem_tag[zz].mnem_line,
               ycol = (ycol+ 12)
             ENDFOR
             save_lycol = ycol, xcol = 140, ycol = lycol
             IF ((temp->patient[p].med_order[z].dl_cnt > 0))
              FOR (zz = 1 TO temp->patient[p].med_order[z].dl_cnt)
                CALL print(calcpos(xcol,ycol)), temp->patient[p].med_order[z].dl_tag[zz].dl_line, row
                 + 1,
                ycol = (ycol+ 12)
              ENDFOR
             ELSE
              ycol = (ycol+ 12), row + 1
             ENDIF
             IF (ycol > save_lycol)
              save_lycol = ycol
             ENDIF
             lycol = save_lycol, left_right = "R"
            ELSE
             xcol = 300, ycol = rycol
             FOR (zz = 1 TO temp->patient[p].med_order[z].mnem_cnt)
               CALL print(calcpos(xcol,ycol)), temp->patient[p].med_order[z].mnem_tag[zz].mnem_line,
               ycol = (ycol+ 12)
             ENDFOR
             save_rycol = ycol, xcol = 410, ycol = rycol
             IF ((temp->patient[p].med_order[z].dl_cnt > 0))
              FOR (zz = 1 TO temp->patient[p].med_order[z].dl_cnt)
                CALL print(calcpos(xcol,ycol)), temp->patient[p].med_order[z].dl_tag[zz].dl_line, row
                 + 1,
                ycol = (ycol+ 12)
              ENDFOR
             ELSE
              ycol = (ycol+ 12), row + 1
             ENDIF
             IF (ycol > save_rycol)
              save_rycol = ycol
             ENDIF
             rycol = save_rycol, left_right = "L"
             IF (save_rycol > save_lycol)
              save_lycol = save_rycol, ycol = save_lycol, lycol = ycol,
              rycol = ycol
             ENDIF
            ENDIF
           ENDIF
          ENDIF
          IF (q=3)
           IF (pp=1)
            row + 1, xcol = 30, ycol = lycol
            IF (((ycol+ 12) > 650))
             BREAK
            ENDIF
            "{f/8}",
            CALL print(calcpos(xcol,ycol)), "{b}PRN Medication Orders: {endb}{f/0}",
            row + 1, ycol = (ycol+ 12), xcol = 30,
            pp = 2, left_right = "L", save_lycol = ycol,
            save_rycol = ycol, lycol = ycol, rycol = ycol
           ENDIF
           IF ((temp->patient[p].med_order[z].prn_ind=1))
            IF ((((max_sch_cnt * 12)+ ycol) > 650))
             med_order_break, prn_order_break
            ENDIF
            IF (left_right="L")
             xcol = 30, ycol = lycol
             FOR (zz = 1 TO temp->patient[p].med_order[z].mnem_cnt)
               CALL print(calcpos(xcol,ycol)), temp->patient[p].med_order[z].mnem_tag[zz].mnem_line,
               ycol = (ycol+ 12)
             ENDFOR
             save_lycol = ycol, xcol = 140, ycol = lycol
             IF ((temp->patient[p].med_order[z].dl_cnt > 0))
              FOR (zz = 1 TO temp->patient[p].med_order[z].dl_cnt)
                CALL print(calcpos(xcol,ycol)), temp->patient[p].med_order[z].dl_tag[zz].dl_line, row
                 + 1,
                ycol = (ycol+ 12)
              ENDFOR
             ELSE
              ycol = (ycol+ 12), row + 1
             ENDIF
             IF (ycol > save_lycol)
              save_lycol = ycol
             ENDIF
             lycol = save_lycol, left_right = "R"
            ELSE
             xcol = 300, ycol = rycol
             FOR (zz = 1 TO temp->patient[p].med_order[z].mnem_cnt)
               CALL print(calcpos(xcol,ycol)), temp->patient[p].med_order[z].mnem_tag[zz].mnem_line,
               ycol = (ycol+ 12)
             ENDFOR
             save_rycol = ycol, xcol = 410, ycol = rycol
             IF ((temp->patient[p].med_order[z].dl_cnt > 0))
              FOR (zz = 1 TO temp->patient[p].med_order[z].dl_cnt)
                CALL print(calcpos(xcol,ycol)), temp->patient[p].med_order[z].dl_tag[zz].dl_line, row
                 + 1,
                ycol = (ycol+ 12)
              ENDFOR
             ELSE
              ycol = (ycol+ 12), row + 1
             ENDIF
             IF (ycol > save_rycol)
              save_rycol = ycol
             ENDIF
             rycol = save_rycol, left_right = "L"
             IF (save_rycol > save_lycol)
              save_lycol = save_rycol, ycol = save_lycol, lycol = ycol,
              rycol = ycol
             ENDIF
            ENDIF
           ENDIF
          ENDIF
        ENDFOR
       ENDFOR
       IF (lycol > rycol)
        ycol = lycol
       ELSE
        ycol = rycol
       ENDIF
      ELSE
       CALL print(calcpos(xcol,ycol)), "There are no medication orders to report.", row + 1,
       ycol = (ycol+ 12)
      ENDIF
      ycol = (ycol - 6), xcol = 30,
      CALL print(calcpos(xcol,ycol)),
      line, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF (radiology_ind=1)
      IF (((ycol+ 12) > 650))
       BREAK, ycol = 93
      ENDIF
      CALL print(calcpos(xcol,ycol)), "{f/8}{b}Radiology Reports: {endb}{f/0}", row + 1,
      ycol = (ycol+ 12), xcol = 30
      IF ((temp->patient[p].rd_cnt > 0))
       FOR (z = 1 TO temp->patient[p].rd_cnt)
         IF ((((temp->patient[p].radiology_doc[z].rd_cnt * 12)+ (ycol+ 12)) > 650))
          BREAK, ycol = 93,
          CALL print(calcpos(xcol,ycol)),
          "{f/8}{b}Radiology Reports (cont): {endb}{f/0}", row + 1, ycol = (ycol+ 12)
         ENDIF
         xcol = 30,
         CALL print(calcpos(xcol,ycol)), temp->patient[p].radiology_doc[z].event_end_dt_tm,
         " ", temp->patient[p].radiology_doc[z].doc_name, row + 1,
         ycol = (ycol+ 12)
         FOR (zz = 1 TO temp->patient[p].radiology_doc[z].rd_cnt)
           xcol = 30,
           CALL print(calcpos(xcol,ycol)), temp->patient[p].radiology_doc[z].rd_tag[zz].rd_line,
           row + 1, ycol = (ycol+ 12)
         ENDFOR
       ENDFOR
      ELSE
       CALL print(calcpos(xcol,ycol)),
       "There are no radiology documents to report in this time frame.", row + 1,
       ycol = (ycol+ 12)
      ENDIF
      ycol = (ycol - 6), xcol = 30,
      CALL print(calcpos(xcol,ycol)),
      line, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF (progress_note_ind=1)
      IF (((ycol+ 12) > 650))
       BREAK, ycol = 93
      ENDIF
      CALL print(calcpos(xcol,ycol)), "{f/8}{b}Progress Notes: {endb}{f/0}", row + 1,
      ycol = (ycol+ 12), xcol = 30
      IF ((temp->patient[p].pn_cnt > 0))
       FOR (z = 1 TO temp->patient[p].pn_cnt)
         IF ((((temp->patient[p].progress_note[z].pn_cnt * 12)+ (ycol+ 12)) > 650))
          BREAK, ycol = 93,
          CALL print(calcpos(xcol,ycol)),
          "{f/8}{b}Progress Notes (cont): {endb}{f/0}", row + 1, ycol = (ycol+ 12)
         ENDIF
         xcol = 30,
         CALL print(calcpos(xcol,ycol)), temp->patient[p].progress_note[z].event_end_dt_tm,
         " ", temp->patient[p].progress_note[z].doc_name, row + 1,
         ycol = (ycol+ 12)
         FOR (zz = 1 TO temp->patient[p].progress_note[z].pn_cnt)
           xcol = 30,
           CALL print(calcpos(xcol,ycol)), temp->patient[p].progress_note[z].pn_tag[zz].pn_line,
           row + 1, ycol = (ycol+ 12)
         ENDFOR
       ENDFOR
      ELSE
       CALL print(calcpos(xcol,ycol)), "There are no progress notes to report in this time frame.",
       row + 1,
       ycol = (ycol+ 12)
      ENDIF
      ycol = (ycol - 6), xcol = 30,
      CALL print(calcpos(xcol,ycol)),
      line, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF (documents_ind=1)
      IF (((ycol+ 12) > 650))
       BREAK, ycol = 93
      ENDIF
      CALL print(calcpos(xcol,ycol)), "{f/8}{b}Other Documents: {endb}{f/0}", row + 1,
      ycol = (ycol+ 12), xcol = 30
      IF ((temp->patient[p].od_cnt > 0))
       FOR (z = 1 TO temp->patient[p].od_cnt)
         IF ((((temp->patient[p].other_doc[z].od_cnt * 12)+ (ycol+ 12)) > 650))
          BREAK, ycol = 93,
          CALL print(calcpos(xcol,ycol)),
          "{f/8}{b}Other Documents (cont): {endb}{f/0}", row + 1, ycol = (ycol+ 12)
         ENDIF
         xcol = 30,
         CALL print(calcpos(xcol,ycol)), temp->patient[p].other_doc[z].event_end_dt_tm,
         " ", temp->patient[p].other_doc[z].doc_name, row + 1,
         ycol = (ycol+ 12)
         FOR (zz = 1 TO temp->patient[p].other_doc[z].od_cnt)
           xcol = 30,
           CALL print(calcpos(xcol,ycol)), temp->patient[p].other_doc[z].od_tag[zz].od_line,
           row + 1, ycol = (ycol+ 12)
         ENDFOR
       ENDFOR
      ELSE
       CALL print(calcpos(xcol,ycol)), "There are no other documents to report in this time frame.",
       row + 1,
       ycol = (ycol+ 12)
      ENDIF
      ycol = (ycol - 6), xcol = 30,
      CALL print(calcpos(xcol,ycol)),
      line, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF (nurse_result_ind=1)
      xcol = 30, lycol = ycol, rycol = ycol,
      save_lycol = lycol, save_rycol = rycol, save_dt_tm = "                               ",
      left_right = "L"
      IF ((temp->patient[p].pcr_cnt > 0))
       FOR (z = 1 TO temp->patient[p].pcr_cnt)
         IF (z=1)
          ycol = (ycol+ 36), does_next_pat_care_fit
          IF ( NOT (next_pat_care_fits))
           BREAK,
           CALL print(calcpos(xcol,ycol)), "{f/8}{b}Patient Care Results: {endb}{f/0}",
           row + 1, ycol = (ycol+ 12), next_pat_care_fits = true,
           xcol = 30, lycol = ycol, rycol = ycol,
           save_lycol = lycol, save_rycol = rycol, save_dt_tm = "                               ",
           left_right = "L"
          ELSE
           ycol = (ycol - 36),
           CALL print(calcpos(xcol,ycol)), "{f/8}{b}Patient Care Results: {endb}{f/0}",
           row + 1, ycol = (ycol+ 12)
          ENDIF
         ELSE
          does_next_pat_care_fit
         ENDIF
         IF ( NOT (next_pat_care_fits))
          pat_care_page_break
         ENDIF
         IF ((temp->patient[p].patient_care_result[z].event_end_dt_tm != save_dt_tm))
          xcol = 30, ycol = save_lycol
          IF (((ycol+ 12) >= 650))
           pat_care_page_break
          ENDIF
          CALL print(calcpos(xcol,ycol)), temp->patient[p].patient_care_result[z].event_end_dt_tm,
          dot_line,
          row + 1, save_lycol = (save_lycol+ 12), save_rycol = save_lycol,
          rycol = save_rycol, lycol = save_lycol, save_dt_tm = temp->patient[p].patient_care_result[z
          ].event_end_dt_tm,
          left_right = "L"
         ENDIF
         IF (left_right="L")
          xcol = 30, ycol = lycol
          FOR (zz = 1 TO temp->patient[p].patient_care_result[z].en_cnt)
            CALL print(calcpos(xcol,ycol)), temp->patient[p].patient_care_result[z].en_tag[zz].
            en_line, ycol = (ycol+ 12),
            row + 1
          ENDFOR
          save_lycol = ycol, xcol = 120, ycol = lycol
          FOR (zz = 1 TO temp->patient[p].patient_care_result[z].rv_cnt)
            CALL print(calcpos(xcol,ycol)), temp->patient[p].patient_care_result[z].rv_tag[zz].
            rv_line, ycol = (ycol+ 12),
            row + 1
          ENDFOR
          IF (ycol > save_lycol)
           save_lycol = ycol
          ENDIF
          xcol = 210, ycol = lycol
          FOR (zz = 1 TO temp->patient[p].patient_care_result[z].rr_cnt)
            CALL print(calcpos(xcol,ycol)), temp->patient[p].patient_care_result[z].rr_tag[zz].
            rr_line, ycol = (ycol+ 12),
            row + 1
          ENDFOR
          IF (ycol > save_lycol)
           save_lycol = ycol
          ENDIF
          lycol = save_lycol, left_right = "R"
         ELSE
          xcol = 300, ycol = rycol
          FOR (zz = 1 TO temp->patient[p].patient_care_result[z].en_cnt)
            CALL print(calcpos(xcol,ycol)), temp->patient[p].patient_care_result[z].en_tag[zz].
            en_line, ycol = (ycol+ 12),
            row + 1
          ENDFOR
          save_rycol = ycol, xcol = 390, ycol = rycol
          FOR (zz = 1 TO temp->patient[p].patient_care_result[z].rv_cnt)
            CALL print(calcpos(xcol,ycol)), temp->patient[p].patient_care_result[z].rv_tag[zz].
            rv_line, ycol = (ycol+ 12),
            row + 1
          ENDFOR
          IF (ycol > save_rycol)
           save_rycol = ycol
          ENDIF
          xcol = 480, ycol = rycol
          FOR (zz = 1 TO temp->patient[p].patient_care_result[z].rr_cnt)
            CALL print(calcpos(xcol,ycol)), temp->patient[p].patient_care_result[z].rr_tag[zz].
            rr_line, ycol = (ycol+ 12),
            row + 1
          ENDFOR
          left_right = "L", rycol = save_rycol
          IF (save_rycol > save_lycol)
           save_lycol = save_rycol, lycol = save_lycol
          ELSE
           save_rycol = save_lycol, rycol = save_rycol, lycol = save_lycol
          ENDIF
         ENDIF
       ENDFOR
       ycol = save_lycol
      ELSE
       CALL print(calcpos(xcol,ycol)), "{f/8}{b}Patient Care Results: {endb}{f/0}", row + 1,
       ycol = (ycol+ 12),
       CALL print(calcpos(xcol,ycol)),
       "There are no patient care results to report in this time range.",
       row + 1, ycol = (ycol+ 12)
      ENDIF
      ycol = (ycol - 6), xcol = 30,
      CALL print(calcpos(xcol,ycol)),
      line, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF (vitals_ind=1)
      IF (((ycol+ 124) > 650))
       BREAK, ycol = 93
      ENDIF
      CALL print(calcpos(xcol,ycol)), "{f/8}{b}Vital Signs: {endb}{f/0}", row + 1,
      ycol = (ycol+ 12), xcol = 30,
      CALL print(calcpos(xcol,ycol)),
      "Height: "
      IF ((temp->patient[p].height > " "))
       temp->patient[p].height, " (", temp->patient[p].height_dt_tm,
       ")", row + 1
      ENDIF
      ycol = (ycol+ 12), xcol = 30,
      CALL print(calcpos(xcol,ycol)),
      "Weight: "
      IF ((temp->patient[p].weight > " "))
       temp->patient[p].weight, " (", temp->patient[p].weight_dt_tm,
       ")", row + 1
      ENDIF
      ycol = (ycol+ 6), ycol = (ycol+ 12), xcol = 30,
      CALL print(calcpos(xcol,ycol)), "Date", xcol = 130
      IF ((temp->patient[p].vital_sign[1].vital_sign_dt_tm > "0"))
       CALL print(calcpos(xcol,ycol)), temp->patient[p].vital_sign[1].vital_sign_dt_tm, row + 1
      ENDIF
      xcol = 230
      IF ((temp->patient[p].vital_sign[2].vital_sign_dt_tm > "0"))
       CALL print(calcpos(xcol,ycol)), temp->patient[p].vital_sign[2].vital_sign_dt_tm, row + 1
      ENDIF
      xcol = 330
      IF ((temp->patient[p].vital_sign[3].vital_sign_dt_tm > "0"))
       CALL print(calcpos(xcol,ycol)), temp->patient[p].vital_sign[3].vital_sign_dt_tm, row + 1
      ENDIF
      xcol = 430
      IF ((temp->patient[p].vital_sign[4].vital_sign_dt_tm > "0"))
       CALL print(calcpos(xcol,ycol)), temp->patient[p].vital_sign[4].vital_sign_dt_tm, row + 1
      ENDIF
      xcol = 530
      IF ((temp->patient[p].vital_sign[5].vital_sign_dt_tm > "0"))
       CALL print(calcpos(xcol,ycol)), temp->patient[p].vital_sign[5].vital_sign_dt_tm, row + 1
      ENDIF
      ycol = (ycol+ 2), xcol = 30,
      CALL print(calcpos(xcol,ycol)),
      line, row + 1, ycol = (ycol+ 12),
      xcol = 30,
      CALL print(calcpos(xcol,ycol)), "Temperature",
      xcol = 130
      IF ((temp->patient[p].vital_sign[1].temperature > "0"))
       CALL print(calcpos(xcol,ycol)), temp->patient[p].vital_sign[1].temperature
      ENDIF
      xcol = 230
      IF ((temp->patient[p].vital_sign[2].temperature > "0"))
       CALL print(calcpos(xcol,ycol)), temp->patient[p].vital_sign[2].temperature
      ENDIF
      xcol = 330
      IF ((temp->patient[p].vital_sign[3].temperature > "0"))
       CALL print(calcpos(xcol,ycol)), temp->patient[p].vital_sign[3].temperature
      ENDIF
      xcol = 430
      IF ((temp->patient[p].vital_sign[4].temperature > "0"))
       CALL print(calcpos(xcol,ycol)), temp->patient[p].vital_sign[4].temperature
      ENDIF
      xcol = 530
      IF ((temp->patient[p].vital_sign[5].temperature > "0"))
       CALL print(calcpos(xcol,ycol)), temp->patient[p].vital_sign[5].temperature
      ENDIF
      ycol = (ycol+ 2), xcol = 30,
      CALL print(calcpos(xcol,ycol)),
      line, row + 1, ycol = (ycol+ 12),
      xcol = 30,
      CALL print(calcpos(xcol,ycol)), "Heart Rate",
      xcol = 130
      IF ((temp->patient[p].vital_sign[1].pulse > "0"))
       CALL print(calcpos(xcol,ycol)), temp->patient[p].vital_sign[1].pulse
      ENDIF
      xcol = 230
      IF ((temp->patient[p].vital_sign[2].pulse > "0"))
       CALL print(calcpos(xcol,ycol)), temp->patient[p].vital_sign[2].pulse
      ENDIF
      xcol = 330
      IF ((temp->patient[p].vital_sign[3].pulse > "0"))
       CALL print(calcpos(xcol,ycol)), temp->patient[p].vital_sign[3].pulse
      ENDIF
      xcol = 430
      IF ((temp->patient[p].vital_sign[4].pulse > "0"))
       CALL print(calcpos(xcol,ycol)), temp->patient[p].vital_sign[4].pulse
      ENDIF
      xcol = 530
      IF ((temp->patient[p].vital_sign[5].pulse > "0"))
       CALL print(calcpos(xcol,ycol)), temp->patient[p].vital_sign[5].pulse
      ENDIF
      ycol = (ycol+ 2), xcol = 30,
      CALL print(calcpos(xcol,ycol)),
      line, row + 1, ycol = (ycol+ 12),
      xcol = 30,
      CALL print(calcpos(xcol,ycol)), "Respiratory Rate",
      xcol = 130
      IF ((temp->patient[p].vital_sign[1].respiratory > "0"))
       CALL print(calcpos(xcol,ycol)), temp->patient[p].vital_sign[1].respiratory
      ENDIF
      xcol = 230
      IF ((temp->patient[p].vital_sign[2].respiratory > "0"))
       CALL print(calcpos(xcol,ycol)), temp->patient[p].vital_sign[2].respiratory
      ENDIF
      xcol = 330
      IF ((temp->patient[p].vital_sign[3].respiratory > "0"))
       CALL print(calcpos(xcol,ycol)), temp->patient[p].vital_sign[3].respiratory
      ENDIF
      xcol = 430
      IF ((temp->patient[p].vital_sign[4].respiratory > "0"))
       CALL print(calcpos(xcol,ycol)), temp->patient[p].vital_sign[4].respiratory
      ENDIF
      xcol = 530
      IF ((temp->patient[p].vital_sign[5].respiratory > "0"))
       CALL print(calcpos(xcol,ycol)), temp->patient[p].vital_sign[5].respiratory
      ENDIF
      ycol = (ycol+ 2), xcol = 30,
      CALL print(calcpos(xcol,ycol)),
      line, row + 1, ycol = (ycol+ 12),
      xcol = 30,
      CALL print(calcpos(xcol,ycol)), "Blood Pressure",
      xcol = 130
      IF ((temp->patient[p].vital_sign[1].blood_pressure > "0"))
       CALL print(calcpos(xcol,ycol)), temp->patient[p].vital_sign[1].blood_pressure
      ENDIF
      xcol = 230
      IF ((temp->patient[p].vital_sign[2].blood_pressure > "0"))
       CALL print(calcpos(xcol,ycol)), temp->patient[p].vital_sign[2].blood_pressure
      ENDIF
      xcol = 330
      IF ((temp->patient[p].vital_sign[3].blood_pressure > "0"))
       CALL print(calcpos(xcol,ycol)), temp->patient[p].vital_sign[3].blood_pressure
      ENDIF
      xcol = 430
      IF ((temp->patient[p].vital_sign[4].blood_pressure > "0"))
       CALL print(calcpos(xcol,ycol)), temp->patient[p].vital_sign[4].blood_pressure
      ENDIF
      xcol = 530
      IF ((temp->patient[p].vital_sign[5].blood_pressure > "0"))
       CALL print(calcpos(xcol,ycol)), temp->patient[p].vital_sign[5].blood_pressure
      ENDIF
      ycol = (ycol+ 2), xcol = 30,
      CALL print(calcpos(xcol,ycol)),
      line, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF (io_ind=1)
      IF (((ycol+ 70) > 600))
       BREAK, ycol = 93
      ENDIF
      "{f/8}",
      CALL print(calcpos(xcol,ycol)), "{b}Intake & Output: {endb}{f/0}",
      row + 1, ycol = (ycol+ 12), xcol = 30,
      CALL print(calcpos(xcol,ycol)), "Date", xcol = 40
      FOR (z = 1 TO temp->patient[p].io_cnt)
       xcol = (xcol+ 70),
       IF ((temp->patient[p].io[z].io_dt_tm > "0"))
        CALL print(calcpos(xcol,ycol)), temp->patient[p].io[((temp->patient[p].io_cnt+ 1) - z)].
        io_dt_tm, row + 1
       ENDIF
      ENDFOR
      ycol = (ycol+ 2), xcol = 30,
      CALL print(calcpos(xcol,ycol)),
      line, row + 1, ycol = (ycol+ 12),
      xcol = 30,
      CALL print(calcpos(xcol,ycol)), "Intake",
      xcol = 40
      FOR (z = 1 TO temp->patient[p].io_cnt)
        xcol = (xcol+ 70),
        CALL print(calcpos(xcol,ycol)), temp->patient[p].io[((temp->patient[p].io_cnt+ 1) - z)].
        intake"#####.##;r"
      ENDFOR
      ycol = (ycol+ 2), xcol = 30,
      CALL print(calcpos(xcol,ycol)),
      line, row + 1, ycol = (ycol+ 12),
      xcol = 30,
      CALL print(calcpos(xcol,ycol)), "Output",
      xcol = 40
      FOR (z = 1 TO temp->patient[p].io_cnt)
        xcol = (xcol+ 70),
        CALL print(calcpos(xcol,ycol)), temp->patient[p].io[((temp->patient[p].io_cnt+ 1) - z)].
        output"#####.##;r"
      ENDFOR
      ycol = (ycol+ 2), xcol = 30,
      CALL print(calcpos(xcol,ycol)),
      line, row + 1, ycol = (ycol+ 12),
      xcol = 30,
      CALL print(calcpos(xcol,ycol)), "Balance",
      xcol = 40
      FOR (z = 1 TO temp->patient[p].io_cnt)
        xcol = (xcol+ 70),
        CALL print(calcpos(xcol,ycol)), temp->patient[p].io[((temp->patient[p].io_cnt+ 1) - z)].
        balance"#####.##;r"
      ENDFOR
      ycol = (ycol+ 2), xcol = 30,
      CALL print(calcpos(xcol,ycol)),
      line, row + 1
     ENDIF
     ycol = (ycol+ 24), row + 1, xcol = 250,
     "{f/8}{cpi/13}",
     CALL print(calcpos(xcol,ycol)), "*** End of Patient Summary ***",
     row + 1
    FOOT PAGE
     "{f/8}{cpi/14}", row + 1, "{pos/450/720}{b}Page: {endb}",
     curpage"##", row + 1
    FOOT REPORT
     row + 0
    WITH nocounter, maxrow = 800, maxcol = 800,
     dio = postscript
   ;end select
 ENDFOR
#exit_script
 FREE RECORD lr_dt_tm
 SET script_version = "MOD 027 SF3151 03/03/03"
END GO
