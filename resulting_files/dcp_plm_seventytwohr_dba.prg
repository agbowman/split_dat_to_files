CREATE PROGRAM dcp_plm_seventytwohr:dba
 RECORD temp(
   1 ecnt = i2
   1 el[*]
     2 encntr_id = f8
     2 person_id = f8
     2 name_full_formatted = vc
     2 loc_facility_disp = vc
     2 loc_nurse_unit_disp = vc
     2 loc_room_disp = vc
     2 loc_bed_disp = vc
     2 room_bed_disp = vc
     2 reason_for_visit = vc
     2 dayofstay = vc
     2 sex_disp = vc
     2 age = vc
     2 address1 = vc
     2 address2 = vc
     2 address3 = vc
     2 address4 = vc
     2 phone = vc
     2 emcname = vc
     2 emcphone = vc
     2 refer_doc = vc
     2 attend_doc = vc
     2 admit_doc = vc
     2 insurance = vc
     2 allergies = vc
     2 problems = vc
     2 myreltn_cd = f8
     2 myreltn = vc
     2 po_cnt = i2
     2 po[*]
       3 po_catalog_cd = f8
       3 po_catalog_type_cd = f8
       3 po_activity_type_cd = f8
       3 po_order_id = f8
       3 po_mnemonic = vc
       3 po_disp_line = vc
     2 ao_cnt = i2
     2 ao[*]
       3 ao_catalog_cd = f8
       3 ao_catalog_type_cd = f8
       3 ao_activity_type_cd = f8
       3 ao_order_id = f8
       3 ao_mnemonic = vc
       3 ao_disp_line = vc
     2 mo_cnt = i2
     2 mo[*]
       3 mo_catalog_cd = f8
       3 mo_catalog_type_cd = f8
       3 mo_activity_type_cd = f8
       3 mo_order_id = f8
       3 mo_mnemonic = vc
       3 mo_freq = vc
       3 mo_dose = vc
       3 mo_route = vc
       3 mo_doseunit = vc
       3 mo_disp_line = vc
       3 dnum = vc
     2 lr_cnt = i2
     2 lr[*]
       3 event_cd = f8
       3 dayofweek = i2
       3 event_name = vc
       3 result_val = vc
       3 order_id = f8
       3 verify_dt_tm = vc
       3 event_end_dt_tm = vc
       3 normalcy_disp = vc
       3 ref_range = vc
       3 note = vc
     2 nr_cnt = i2
     2 nr[*]
       3 event_cd = f8
       3 dayofweek = i2
       3 event_name = vc
       3 result_val = vc
       3 order_id = f8
       3 verify_dt_tm = vc
       3 event_end_dt_tm = vc
       3 normalcy_disp = vc
       3 ref_range = vc
       3 note = vc
     2 vs_cnt = i2
     2 ht = vc
     2 ht_dt_tm = vc
     2 wt = vc
     2 wt_dt_tm = vc
     2 vs[*]
       3 vs_dt_tm = vc
       3 temp = vc
       3 pulse = vc
       3 resp = vc
       3 bp = vc
     2 rad_cnt = i2
     2 rad[*]
       3 event_cd = f8
       3 dayofweek = i2
       3 rad_name = vc
       3 rad_blob = vc
       3 event_end_dt_tm = vc
       3 rad_author = vc
     2 pro_cnt = i2
     2 pro[*]
       3 event_cd = f8
       3 dayofweek = i2
       3 pro_name = vc
       3 pro_blob = vc
       3 event_end_dt_tm = vc
       3 pro_author = vc
     2 doc_cnt = i2
     2 doc[*]
       3 event_cd = f8
       3 dayofweek = i2
       3 doc_name = vc
       3 doc_blob = vc
       3 event_end_dt_tm = vc
       3 doc_author = vc
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
   1 pro_cnt = i2
   1 pro[*]
     2 pro_event_cd = f8
   1 doc_cnt = i2
   1 doc[*]
     2 doc_event_cd = f8
   1 aoct_cnt = i2
   1 aoct[*]
     2 ao_catalog_type = f8
   1 poct_cnt = i2
   1 poct[*]
     2 po_catalog_type = f8
   1 oe_cnt = i2
   1 oe[*]
     2 oe_type_flag = i2
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
     2 po_catalog_cd = f8
     2 po_catalog_type_cd = f8
     2 po_activity_type_cd = f8
     2 po_order_id = f8
     2 po_mnemonic = vc
     2 po_disp_line = vc
     2 ao_catalog_cd = f8
     2 ao_catalog_type_cd = f8
     2 ao_activity_type_cd = f8
     2 ao_order_id = f8
     2 ao_mnemonic = vc
     2 ao_disp_line = vc
     2 mo_catalog_cd = f8
     2 mo_catalog_type_cd = f8
     2 mo_activity_type_cd = f8
     2 mo_order_id = f8
     2 mo_mnemonic = vc
     2 mo_freq = vc
     2 mo_dose = vc
     2 mo_route = vc
     2 mo_doseunit = vc
     2 mo_disp_line = vc
     2 dnum = vc
   1 r_cnt = i2
   1 r[*]
     2 event_cd = f8
     2 dayofweek = i2
     2 event_name = vc
     2 result_val = vc
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
 SET temp2->lrec_cnt = 0
 SET temp2->doc_cnt = 0
 SET temp2->rad_cnt = 0
 SET temp2->pro_cnt = 0
 SET temp2->nrec_cnt = 0
 SET temp2->aoct_cnt = 0
 SET temp2->poct_cnt = 0
 SET call_echo_ind = 1
 SET cnt = 0
 SET temp->ecnt = 0
 SET tempday = 0.0
 SET lf = char(10)
 SET lab_result_ind = 1
 SET nurse_result_ind = 1
 SET med_order_ind = 1
 SET vitals_ind = 1
 SET documents_ind = 1
 SET radiology_ind = 1
 SET progress_note_ind = 1
 SET pending_order_ind = 1
 SET active_order_ind = 1
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
   "RL_ACT_ORDER", "RL_PC", "RL_RAD_DOC", "RL_NOTE_DOC", "RL_CUSTOMIZE")
    AND n.pvc_value IN ("1", "0"))
  DETAIL
   IF (n.pvc_name="RL_LR")
    lab_result_ind = cnvtint(substring(1,1,n.pvc_value))
   ELSEIF (n.pvc_name="RL_MO")
    med_order_ind = cnvtint(substring(1,1,n.pvc_value))
   ELSEIF (n.pvc_name="RL_VS")
    vitals_ind = cnvtint(substring(1,1,n.pvc_value))
   ELSEIF (n.pvc_name="RL_OTEHR_DOC")
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
    nurse_result_ind = cnvtint(substring(1,1,n.pvc_value))
   ELSEIF (n.pvc_name="RL_CUSTOMIZE")
    prsnl_customize_ind = cnvtint(substring(1,1,n.pvc_value))
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
      AND (d.prsnl_id=request->prsnl[1].prsnl_id)
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
    ORDER BY n.sequence
    HEAD REPORT
     cnt = 0
    DETAIL
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
    ORDER BY n.sequence
    HEAD REPORT
     cnt = 0
    DETAIL
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
      AND (d.prsnl_id=request->prsnl[1].prsnl_id)
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
    ORDER BY n.sequence
    HEAD REPORT
     cnt = 0
    DETAIL
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
    ORDER BY n.sequence
    HEAD REPORT
     cnt = 0
    DETAIL
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
      AND (d.prsnl_id=request->prsnl[1].prsnl_id)
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
    ORDER BY n.sequence
    HEAD REPORT
     cnt = 0
    DETAIL
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
    ORDER BY n.sequence
    HEAD REPORT
     cnt = 0
    DETAIL
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
      AND (d.prsnl_id=request->prsnl[1].prsnl_id)
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
    ORDER BY n.sequence
    HEAD REPORT
     cnt = 0
    DETAIL
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
    ORDER BY n.sequence
    HEAD REPORT
     cnt = 0
    DETAIL
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
      AND (d.prsnl_id=request->prsnl[1].prsnl_id)
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
    ORDER BY n.sequence
    HEAD REPORT
     cnt = 0
    DETAIL
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
    ORDER BY n.sequence
    HEAD REPORT
     cnt = 0
    DETAIL
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
      AND (d.prsnl_id=request->prsnl[1].prsnl_id)
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
    ORDER BY n.sequence
    HEAD REPORT
     cnt = 0
    DETAIL
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
    ORDER BY n.sequence
    HEAD REPORT
     cnt = 0
    DETAIL
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
      AND (d.prsnl_id=request->prsnl[1].prsnl_id)
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
    ORDER BY n.sequence
    HEAD REPORT
     cnt = 0
    DETAIL
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
    ORDER BY n.sequence
    HEAD REPORT
     cnt = 0
    DETAIL
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
 SET a = 0
 IF ((request->visit_cnt > 0))
  SELECT INTO "nl:"
   dob_null = nullind(p.birth_dt_tm), deceased_null = nullind(p.deceased_dt_tm), disch_null = nullind
   (e.disch_dt_tm),
   reg_null = nullind(e.reg_dt_tm), facil = trim(uar_get_code_display(e.loc_facility_cd))
   FROM (dummyt d  WITH seq = value(request->visit_cnt)),
    encounter e,
    person p
   PLAN (d)
    JOIN (e
    WHERE (e.encntr_id=request->visit[d.seq].encntr_id))
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.name_full_formatted > " ")
   ORDER BY facil, p.name_full_formatted
   HEAD REPORT
    cnt = 0, temproom = fillstring(12," "), tempbed = fillstring(12," "),
    tempsex = fillstring(12," "), tempage = fillstring(20," "), a = 0
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(temp->el,cnt), temp->el[cnt].encntr_id = e.encntr_id,
    temp->el[cnt].person_id = p.person_id, temp->el[cnt].name_full_formatted = p.name_full_formatted,
    temp->el[cnt].loc_facility_disp = trim(uar_get_code_display(e.loc_facility_cd)),
    temp->el[cnt].loc_nurse_unit_disp = trim(uar_get_code_display(e.loc_nurse_unit_cd)), temp->el[cnt
    ].loc_room_disp = trim(uar_get_code_display(e.loc_room_cd)), temp->el[cnt].loc_bed_disp = trim(
     uar_get_code_display(e.loc_bed_cd)),
    temproom = uar_get_code_display(e.loc_room_cd), tempbed = uar_get_code_display(e.loc_bed_cd)
    IF (temproom > " ")
     IF (tempbed > " ")
      temp->el[cnt].room_bed_disp = build(temproom,".",tempbed)
     ELSE
      temp->el[cnt].room_bed_disp = trim(temproom)
     ENDIF
    ENDIF
    temp->el[cnt].reason_for_visit = e.reason_for_visit, tempsex = trim(uar_get_code_display(p.sex_cd
      )), temp->el[cnt].sex_disp = substring(1,1,tempsex)
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
     temp->el[cnt].age = " "
    ENDIF
    IF (tempage > " ")
     a = findstring(" ",tempage,3)
     IF (a > 3)
      temp->el[cnt].age = trim(build(substring(1,(a - 1),tempage),substring((a+ 1),1,tempage)))
     ELSE
      temp->el[cnt].age = tempage
     ENDIF
    ENDIF
    IF (reg_null=0)
     IF (disch_null=0)
      tempday = datetimediff(e.disch_dt_tm,e.reg_dt_tm), temp->el[cnt].dayofstay = format(tempday,
       "###.#")
     ELSE
      tempday = datetimediff(cnvtdatetime(curdate,curtime3),e.reg_dt_tm), temp->el[cnt].dayofstay =
      format(tempday,"###.#")
     ENDIF
    ELSE
     temp->el[cnt].dayofstay = " "
    ENDIF
    temp->el[cnt].po_cnt = 0, temp->el[cnt].ao_cnt = 0, temp->el[cnt].mo_cnt = 0,
    temp->el[cnt].lr_cnt = 0, temp->el[cnt].nr_cnt = 0, temp->el[cnt].vs_cnt = 0,
    temp->el[cnt].rad_cnt = 0, temp->el[cnt].pro_cnt = 0, temp->el[cnt].doc_cnt = 0
   FOOT REPORT
    temp->ecnt = cnt
   WITH nocounter
  ;end select
 ELSE
  SELECT DISTINCT INTO "nl:"
   epr.encntr_id, dob_null = nullind(p.birth_dt_tm), deceased_null = nullind(p.deceased_dt_tm),
   disch_null = nullind(e.disch_dt_tm), reg_null = nullind(e.reg_dt_tm), facil = trim(
    uar_get_code_display(ed.loc_facility_cd))
   FROM encntr_domain ed,
    encntr_prsnl_reltn epr,
    encounter e,
    person p
   PLAN (epr
    WHERE (epr.prsnl_person_id=request->prsnl[1].prsnl_id)
     AND epr.active_ind=1
     AND epr.expiration_ind != 1
     AND epr.beg_effective_dt_tm < cnvtdatetime((curdate+ 1),curtime)
     AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
    JOIN (ed
    WHERE ed.encntr_id=epr.encntr_id
     AND ed.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
     AND ed.active_ind=1
     AND ed.encntr_domain_type_cd=census_cd)
    JOIN (e
    WHERE e.encntr_id=epr.encntr_id)
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.name_full_formatted > " ")
   ORDER BY facil, p.name_full_formatted
   HEAD REPORT
    cnt = 0, temproom = fillstring(12," "), tempbed = fillstring(12," "),
    tempsex = fillstring(12," "), tempage = fillstring(20," "), a = 0
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(temp->el,cnt), temp->el[cnt].encntr_id = e.encntr_id,
    temp->el[cnt].person_id = p.person_id, temp->el[cnt].name_full_formatted = p.name_full_formatted,
    temp->el[cnt].loc_facility_disp = trim(uar_get_code_display(ed.loc_facility_cd)),
    temp->el[cnt].loc_nurse_unit_disp = trim(uar_get_code_display(ed.loc_nurse_unit_cd)), temp->el[
    cnt].loc_room_disp = trim(uar_get_code_display(ed.loc_room_cd)), temp->el[cnt].loc_bed_disp =
    trim(uar_get_code_display(ed.loc_bed_cd)),
    temproom = uar_get_code_display(ed.loc_room_cd), tempbed = uar_get_code_display(ed.loc_bed_cd)
    IF (temproom > " ")
     IF (tempbed > " ")
      temp->el[cnt].room_bed_disp = build(temproom,".",tempbed)
     ELSE
      temp->el[cnt].room_bed_disp = trim(temproom)
     ENDIF
    ENDIF
    temp->el[cnt].reason_for_visit = e.reason_for_visit, tempsex = trim(uar_get_code_display(p.sex_cd
      )), temp->el[cnt].sex_disp = substring(1,1,tempsex)
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
     temp->el[cnt].age = " "
    ENDIF
    IF (tempage > " ")
     a = findstring(" ",tempage,3)
     IF (a > 3)
      temp->el[cnt].age = trim(build(substring(1,(a - 1),tempage),substring((a+ 1),1,tempage)))
     ELSE
      temp->el[cnt].age = tempage
     ENDIF
    ENDIF
    IF (reg_null=0)
     IF (disch_null=0)
      tempday = datetimediff(e.disch_dt_tm,e.reg_dt_tm), temp->el[cnt].dayofstay = format(tempday,
       "###.#")
     ELSE
      tempday = datetimediff(cnvtdatetime(curdate,curtime3),e.reg_dt_tm), temp->el[cnt].dayofstay =
      format(tempday,"###.#")
     ENDIF
    ELSE
     temp->el[cnt].dayofstay = " "
    ENDIF
    temp->el[cnt].po_cnt = 0, temp->el[cnt].ao_cnt = 0, temp->el[cnt].mo_cnt = 0,
    temp->el[cnt].lr_cnt = 0, temp->el[cnt].nr_cnt = 0, temp->el[cnt].vs_cnt = 0,
    temp->el[cnt].rad_cnt = 0, temp->el[cnt].pro_cnt = 0, temp->el[cnt].doc_cnt = 0
   FOOT REPORT
    temp->ecnt = cnt
   WITH nocounter
  ;end select
 ENDIF
 IF ((temp->ecnt > 0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(temp->ecnt)),
   encntr_prsnl_reltn epr,
   prsnl p
  PLAN (d)
   JOIN (epr
   WHERE (epr.encntr_id=temp->el[d.seq].encntr_id)
    AND epr.encntr_prsnl_r_cd IN (refer_cd, attend_cd, admit_cd)
    AND epr.active_ind=1
    AND epr.expiration_ind != 1
    AND epr.beg_effective_dt_tm < cnvtdatetime((curdate+ 1),curtime)
    AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (p
   WHERE p.person_id=epr.prsnl_person_id)
  DETAIL
   IF (epr.encntr_prsnl_r_cd=refer_cd)
    IF (p.name_full_formatted > " ")
     temp->el[d.seq].refer_doc = substring(1,30,p.name_full_formatted)
    ELSE
     temp->el[d.seq].refer_doc = epr.ft_prsnl_name
    ENDIF
   ELSEIF (epr.encntr_prsnl_r_cd=attend_cd)
    IF (p.name_full_formatted > " ")
     temp->el[d.seq].attend_doc = substring(1,30,p.name_full_formatted)
    ELSE
     temp->el[d.seq].attend_doc = epr.ft_prsnl_name
    ENDIF
   ELSEIF (epr.encntr_prsnl_r_cd=admit_cd)
    IF (p.name_full_formatted > " ")
     temp->el[d.seq].admit_doc = substring(1,30,p.name_full_formatted)
    ELSE
     temp->el[d.seq].admit_doc = epr.ft_prsnl_name
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(temp->ecnt)),
   phone ph
  PLAN (d)
   JOIN (ph
   WHERE ph.parent_entity_name="PERSON"
    AND (ph.parent_entity_id=temp->el[d.seq].person_id)
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
   temp->el[d.seq].phone = fmtphone
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(temp->ecnt)),
   address a
  PLAN (d)
   JOIN (a
   WHERE a.parent_entity_name="PERSON"
    AND (a.parent_entity_id=temp->el[d.seq].person_id)
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
   el[d.seq].address1 = trim(a.street_addr), temp->el[d.seq].address2 = trim(tempaddr),
   temp->el[d.seq].address3 = concat(trim(a.city),",",trim(tempstate)," ",trim(a.zipcode))
   IF ((temp->el[d.seq].address1 > " ")
    AND (temp->el[d.seq].address2 > " "))
    temp->el[d.seq].address1 = concat(temp->el[d.seq].address1,lf,temp->el[d.seq].address2)
   ENDIF
   IF ((temp->el[d.seq].address1 > " ")
    AND (temp->el[d.seq].address3 > " "))
    temp->el[d.seq].address1 = concat(temp->el[d.seq].address1,lf,temp->el[d.seq].address3)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  checkp = decode(p.seq,1,0), checkph = decode(ph.seq,1,0)
  FROM (dummyt d  WITH seq = value(temp->ecnt)),
   encntr_person_reltn epr,
   (dummyt d1  WITH seq = 1),
   person p,
   (dummyt d2  WITH seq = 1),
   phone ph
  PLAN (d)
   JOIN (epr
   WHERE (epr.encntr_id=temp->el[d.seq].encntr_id)
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
   temp->el[d.seq].emcname = trim(tempemc), temp->el[d.seq].emcphone = trim(fmtphone)
  WITH nocounter, outerjoin = d1, outerjoin = d2
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(temp->ecnt)),
   encntr_plan_reltn epr,
   health_plan hp,
   org_plan_reltn opr,
   organization o
  PLAN (d)
   JOIN (epr
   WHERE (epr.encntr_id=temp->el[d.seq].encntr_id)
    AND epr.priority_seq IN (1, 99)
    AND epr.active_ind=1
    AND epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (hp
   WHERE hp.health_plan_id=epr.health_plan_id
    AND hp.active_ind=1)
   JOIN (opr
   WHERE opr.health_plan_id=hp.health_plan_id
    AND opr.active_ind=1
    AND opr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND opr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (o
   WHERE o.organization_id=opr.organization_id)
  ORDER BY d.seq, epr.priority_seq DESC
  DETAIL
   temp->el[d.seq].insurance = trim(o.org_name)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(temp->ecnt)),
   encntr_prsnl_reltn epr
  PLAN (d)
   JOIN (epr
   WHERE (epr.encntr_id=temp->el[d.seq].encntr_id)
    AND (epr.prsnl_person_id=request->prsnl[1].prsnl_id)
    AND epr.active_ind=1
    AND epr.expiration_ind != 1
    AND epr.beg_effective_dt_tm < cnvtdatetime((curdate+ 1),curtime)
    AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
  HEAD d.seq
   tempmyreltn = fillstring(100," "), temp->el[d.seq].myreltn_cd = epr.encntr_prsnl_r_cd
  DETAIL
   IF (tempmyreltn > " ")
    tempmyreltn = concat(tempmyreltn,", ",trim(uar_get_code_display(epr.encntr_prsnl_r_cd)))
   ELSE
    tempmyreltn = trim(uar_get_code_display(epr.encntr_prsnl_r_cd))
   ENDIF
  FOOT  d.seq
   temp->el[d.seq].myreltn = tempmyreltn
  WITH nocounter
 ;end select
 IF (pending_order_ind=1)
  IF ((temp2->poct_cnt > 0))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(temp->ecnt)),
     (dummyt d2  WITH seq = value(temp2->poct_cnt)),
     orders o
    PLAN (d)
     JOIN (d2)
     JOIN (o
     WHERE (o.encntr_id=temp->el[d.seq].encntr_id)
      AND (o.catalog_type_cd=temp2->poct[d2.seq].po_catalog_type)
      AND o.catalog_type_cd != pharmacy_cd
      AND o.order_status_cd IN (ordered_cd, pendrev_cd, inproc_cd)
      AND o.projected_stop_dt_tm < cnvtdatetime(curdate,curtime))
    ORDER BY d.seq, d2.seq, o.hna_order_mnemonic
    HEAD d.seq
     ocnt = 0
    DETAIL
     ocnt = (ocnt+ 1), stat = alterlist(temp->el[d.seq].po,ocnt), temp->el[d.seq].po[ocnt].
     po_order_id = o.order_id,
     temp->el[d.seq].po[ocnt].po_catalog_cd = o.catalog_cd, temp->el[d.seq].po[ocnt].
     po_catalog_type_cd = o.catalog_type_cd, temp->el[d.seq].po[ocnt].po_activity_type_cd = o
     .activity_type_cd,
     temp->el[d.seq].po[ocnt].po_mnemonic = trim(o.hna_order_mnemonic), temp->el[d.seq].po[ocnt].
     po_disp_line = trim(o.clinical_display_line)
    FOOT  d.seq
     temp->el[d.seq].po_cnt = ocnt
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(temp->ecnt)),
     orders o
    PLAN (d)
     JOIN (o
     WHERE (o.encntr_id=temp->el[d.seq].encntr_id)
      AND o.catalog_type_cd != pharmacy_cd
      AND o.catalog_type_cd != nurs_cd
      AND o.order_status_cd IN (ordered_cd, pendrev_cd, inproc_cd)
      AND o.projected_stop_dt_tm < cnvtdatetime(curdate,curtime))
    ORDER BY d.seq, o.hna_order_mnemonic
    HEAD d.seq
     ocnt = 0
    DETAIL
     ocnt = (ocnt+ 1), stat = alterlist(temp->el[d.seq].po,ocnt), temp->el[d.seq].po[ocnt].
     po_order_id = o.order_id,
     temp->el[d.seq].po[ocnt].po_catalog_cd = o.catalog_cd, temp->el[d.seq].po[ocnt].
     po_catalog_type_cd = o.catalog_type_cd, temp->el[d.seq].po[ocnt].po_activity_type_cd = o
     .activity_type_cd,
     temp->el[d.seq].po[ocnt].po_mnemonic = trim(o.hna_order_mnemonic), temp->el[d.seq].po[ocnt].
     po_disp_line = trim(o.clinical_display_line)
    FOOT  d.seq
     temp->el[d.seq].po_cnt = ocnt
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (active_order_ind=1)
  IF ((temp2->aoct_cnt > 0))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(temp->ecnt)),
     (dummyt d2  WITH seq = value(temp2->aoct_cnt)),
     orders o
    PLAN (d)
     JOIN (d2)
     JOIN (o
     WHERE (o.encntr_id=temp->el[d.seq].encntr_id)
      AND (o.catalog_type_cd=temp2->aoct[d2.seq].ao_catalog_type)
      AND o.order_status_cd IN (ordered_cd, pendrev_cd, inproc_cd)
      AND o.projected_stop_dt_tm > cnvtdatetime(curdate,curtime))
    ORDER BY d.seq, d2.seq, o.hna_order_mnemonic
    HEAD d.seq
     ocnt = 0
    DETAIL
     ocnt = (ocnt+ 1), stat = alterlist(temp->el[d.seq].ao,ocnt), temp->el[d.seq].ao[ocnt].
     ao_order_id = o.order_id,
     temp->el[d.seq].ao[ocnt].ao_catalog_cd = o.catalog_cd, temp->el[d.seq].ao[ocnt].
     ao_catalog_type_cd = o.catalog_type_cd, temp->el[d.seq].ao[ocnt].ao_activity_type_cd = o
     .activity_type_cd,
     temp->el[d.seq].ao[ocnt].ao_mnemonic = trim(o.hna_order_mnemonic), temp->el[d.seq].ao[ocnt].
     ao_disp_line = trim(o.clinical_display_line)
    FOOT  d.seq
     temp->el[d.seq].ao_cnt = ocnt
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(temp->ecnt)),
     orders o
    PLAN (d)
     JOIN (o
     WHERE (o.encntr_id=temp->el[d.seq].encntr_id)
      AND o.catalog_type_cd != pharmacy_cd
      AND o.catalog_type_cd != nurs_cd
      AND o.order_status_cd IN (ordered_cd, pendrev_cd, inproc_cd)
      AND o.projected_stop_dt_tm > cnvtdatetime(curdate,curtime))
    ORDER BY d.seq, o.hna_order_mnemonic
    HEAD d.seq
     ocnt = 0
    DETAIL
     ocnt = (ocnt+ 1), stat = alterlist(temp->el[d.seq].ao,ocnt), temp->el[d.seq].ao[ocnt].
     ao_order_id = o.order_id,
     temp->el[d.seq].ao[ocnt].ao_catalog_cd = o.catalog_cd, temp->el[d.seq].ao[ocnt].
     ao_catalog_type_cd = o.catalog_type_cd, temp->el[d.seq].ao[ocnt].ao_activity_type_cd = o
     .activity_type_cd,
     temp->el[d.seq].ao[ocnt].ao_mnemonic = trim(o.hna_order_mnemonic), temp->el[d.seq].ao[ocnt].
     ao_disp_line = trim(o.clinical_display_line)
    FOOT  d.seq
     temp->el[d.seq].ao_cnt = ocnt
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (med_order_ind=1)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(temp->ecnt)),
    orders o,
    order_detail od
   PLAN (d)
    JOIN (o
    WHERE (o.encntr_id=temp->el[d.seq].encntr_id)
     AND o.catalog_type_cd=pharmacy_cd
     AND o.order_status_cd IN (ordered_cd, pendrev_cd, inproc_cd)
     AND o.template_order_flag IN (0, 1))
    JOIN (od
    WHERE od.order_id=o.order_id
     AND od.oe_field_meaning IN ("FREQ", "FREETXTDOSE", "STRENGTHDOSE", "STRENGTHDOSEUNIT", "RXROUTE"
    ))
   ORDER BY d.seq, o.hna_order_mnemonic, o.order_id,
    od.action_sequence
   HEAD d.seq
    ocnt = 0
   HEAD o.order_id
    ocnt = (ocnt+ 1), stat = alterlist(temp->el[d.seq].mo,ocnt), temp->el[d.seq].mo[ocnt].mo_order_id
     = o.order_id,
    temp->el[d.seq].mo[ocnt].mo_catalog_cd = o.catalog_cd, temp->el[d.seq].mo[ocnt].
    mo_catalog_type_cd = o.catalog_type_cd, temp->el[d.seq].mo[ocnt].mo_activity_type_cd = o
    .activity_type_cd,
    temp->el[d.seq].mo[ocnt].mo_mnemonic = trim(o.hna_order_mnemonic), temp->el[d.seq].mo[ocnt].
    mo_disp_line = trim(o.clinical_display_line)
    IF (o.cki="MUL.ORD!*")
     temp->el[d.seq].mo[ocnt].dnum = trim(substring(9,25,o.cki))
    ELSE
     temp->el[d.seq].mo[ocnt].dnum = " "
    ENDIF
   DETAIL
    IF (od.oe_field_meaning="FREQ")
     temp->el[d.seq].mo[ocnt].mo_freq = od.oe_field_display_value
    ELSEIF (((od.oe_field_meaning="FREETXTDOSE") OR (od.oe_field_meaning="STRENGTHDOSE")) )
     temp->el[d.seq].mo[ocnt].mo_dose = od.oe_field_display_value
    ELSEIF (od.oe_field_meaning="STRENGTHDOSEUNIT")
     temp->el[d.seq].mo[ocnt].mo_doseunit = od.oe_field_display_value
    ELSEIF (od.oe_field_meaning="RXROUTE")
     temp->el[d.seq].mo[ocnt].mo_route = od.oe_field_display_value
    ENDIF
   FOOT  o.order_id
    IF ((temp->el[d.seq].mo[ocnt].mo_dose > " ")
     AND (temp->el[d.seq].mo[ocnt].mo_doseunit > " "))
     temp->el[d.seq].mo[ocnt].mo_dose = concat(trim(temp->el[d.seq].mo[ocnt].mo_dose),trim(temp->el[d
       .seq].mo[ocnt].mo_doseunit))
    ENDIF
   FOOT  d.seq
    temp->el[d.seq].mo_cnt = ocnt
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  checkn = decode(n.seq,1,0)
  FROM (dummyt d  WITH seq = value(temp->ecnt)),
   allergy a,
   (dummyt d1  WITH seq = 1),
   nomenclature n
  PLAN (d)
   JOIN (a
   WHERE (a.person_id=temp->el[d.seq].person_id)
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (a.end_effective_dt_tm=null))
    AND a.reaction_status_cd != canceled_cd)
   JOIN (d1)
   JOIN (n
   WHERE n.nomenclature_id=a.substance_nom_id)
  ORDER BY d.seq, a.onset_dt_tm
  HEAD d.seq
   tempall = fillstring(100," ")
  DETAIL
   IF (checkn=1)
    tempall = n.source_string
   ELSE
    tempall = a.substance_ftdesc
   ENDIF
   IF ((temp->el[d.seq].allergies > " "))
    temp->el[d.seq].allergies = concat(temp->el[d.seq].allergies,",",tempall)
   ELSE
    temp->el[d.seq].allergies = tempall
   ENDIF
  WITH nocounter, outerjoin = d1
 ;end select
 SELECT INTO "nl:"
  checkn = decode(n.seq,1,0)
  FROM (dummyt d  WITH seq = value(temp->ecnt)),
   problem p,
   (dummyt d1  WITH seq = 1),
   nomenclature n
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=temp->el[d.seq].person_id)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (p.end_effective_dt_tm=null)) )
   JOIN (d1)
   JOIN (n
   WHERE n.nomenclature_id=p.nomenclature_id)
  ORDER BY d.seq, p.onset_dt_tm
  HEAD d.seq
   tempprob = fillstring(100," ")
  DETAIL
   IF (checkn=1)
    tempprob = n.source_string
   ELSE
    tempprob = p.problem_ftdesc
   ENDIF
   IF ((temp->el[d.seq].problems > " "))
    temp->el[d.seq].problems = concat(temp->el[d.seq].problems,",",tempprob)
   ELSE
    temp->el[d.seq].problems = tempprob
   ENDIF
  WITH nocounter, outerjoin = d1
 ;end select
 IF (lab_result_ind=1
  AND (temp2->lrec_cnt=0))
  SELECT INTO "nl:"
   notefound = decode(lb.seq,1,0), tl = textlen(lb.long_blob)
   FROM (dummyt d  WITH seq = value(temp->ecnt)),
    orders o,
    clinical_event ce,
    (dummyt d2  WITH seq = 1),
    ce_event_note cen,
    long_blob lb
   PLAN (d)
    JOIN (o
    WHERE (o.encntr_id=temp->el[d.seq].encntr_id)
     AND o.catalog_type_cd=lab_cd
     AND o.activity_type_cd=genlab_cd
     AND o.template_order_flag IN (0, 2))
    JOIN (ce
    WHERE ce.order_id=o.order_id
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.event_end_dt_tm >= cnvtdatetime((curdate - 3),curtime)
     AND ce.event_end_dt_tm <= cnvtdatetime(curdate,curtime)
     AND ce.result_status_cd != inerror_cd)
    JOIN (d2)
    JOIN (cen
    WHERE ce.event_id=cen.event_id)
    JOIN (lb
    WHERE lb.parent_entity_id=cen.ce_event_note_id
     AND lb.parent_entity_name="CE_EVENT_NOTE")
   ORDER BY d.seq, o.hna_order_mnemonic, cnvtdatetime(ce.event_end_dt_tm) DESC
   HEAD d.seq
    lcnt = 0
   DETAIL
    lcnt = (lcnt+ 1), stat = alterlist(temp->el[d.seq].lr,lcnt), temp->el[d.seq].lr[lcnt].event_cd =
    ce.event_cd,
    temp->el[d.seq].lr[lcnt].dayofweek = 0, temp->el[d.seq].lr[lcnt].event_name = trim(
     uar_get_code_display(ce.event_cd))
    IF (ce.event_class_cd IN (txt_cd, num_cd, date_cd))
     temp->el[d.seq].lr[lcnt].result_val = trim(ce.event_tag)
    ELSE
     temp->el[d.seq].lr[lcnt].result_val = "See PowerChart"
    ENDIF
    temp->el[d.seq].lr[lcnt].order_id = ce.order_id, temp->el[d.seq].lr[lcnt].verify_dt_tm = format(
     ce.verified_dt_tm,"mm/dd hh:mm;;d"), temp->el[d.seq].lr[lcnt].event_end_dt_tm = format(ce
     .event_end_dt_tm,"mm/dd hh:mm;;d"),
    temp->el[d.seq].lr[lcnt].normalcy_disp = substring(1,1,trim(uar_get_code_display(ce.normalcy_cd))
     )
    IF (ce.normal_low > " "
     AND ce.normal_high > " ")
     temp->el[d.seq].lr[lcnt].ref_range = build("(",ce.normal_low,"-",ce.normal_high,")")
    ENDIF
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
     CALL uar_rtf(blob_out,textlen(blob_out),blob_out2,32000,32000,0), blob_out = blob_out2, temp->
     el[d.seq].lr[lcnt].note = blob_out
    ENDIF
   FOOT  d.seq
    temp->el[d.seq].lr_cnt = lcnt
   WITH nocounter, memsort, outerjoin = d2
  ;end select
 ENDIF
 IF (lab_result_ind=1
  AND (temp2->lrec_cnt > 0))
  SELECT INTO "nl:"
   notefound = decode(lb.seq,1,0), tl = textlen(lb.long_blob), dayofweek = weekday(ce.event_end_dt_tm
    )
   FROM (dummyt d  WITH seq = value(temp->ecnt)),
    (dummyt d2  WITH seq = value(temp2->lrec_cnt)),
    clinical_event ce,
    (dummyt d3  WITH seq = 1),
    ce_event_note cen,
    long_blob lb
   PLAN (d)
    JOIN (ce
    WHERE (ce.person_id=temp->el[d.seq].person_id)
     AND (ce.encntr_id=temp->el[d.seq].encntr_id)
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.event_end_dt_tm >= cnvtdatetime((curdate - 3),curtime)
     AND ce.event_end_dt_tm <= cnvtdatetime(curdate,curtime)
     AND ce.result_status_cd != inerror_cd)
    JOIN (d2
    WHERE (ce.event_cd=temp2->lrec[d2.seq].lr_event_cd))
    JOIN (d3)
    JOIN (cen
    WHERE ce.event_id=cen.event_id)
    JOIN (lb
    WHERE lb.parent_entity_id=cen.ce_event_note_id
     AND lb.parent_entity_name="CE_EVENT_NOTE")
   ORDER BY d.seq, cnvtdatetime(ce.event_end_dt_tm) DESC
   HEAD d.seq
    lcnt = 0
   DETAIL
    lcnt = (lcnt+ 1), stat = alterlist(temp->el[d.seq].lr,lcnt), temp->el[d.seq].lr[lcnt].event_cd =
    ce.event_cd,
    temp->el[d.seq].lr[lcnt].dayofweek = dayofweek, temp->el[d.seq].lr[lcnt].event_name = trim(
     uar_get_code_display(ce.event_cd))
    IF (ce.event_class_cd IN (txt_cd, num_cd, date_cd))
     temp->el[d.seq].lr[lcnt].result_val = trim(ce.event_tag)
    ELSE
     temp->el[d.seq].lr[lcnt].result_val = "See PowerChart"
    ENDIF
    temp->el[d.seq].lr[lcnt].order_id = ce.order_id, temp->el[d.seq].lr[lcnt].verify_dt_tm = format(
     ce.verified_dt_tm,"mm/dd hh:mm;;d"), temp->el[d.seq].lr[lcnt].event_end_dt_tm = format(ce
     .event_end_dt_tm,"mm/dd hh:mm;;d"),
    temp->el[d.seq].lr[lcnt].normalcy_disp = substring(1,1,trim(uar_get_code_display(ce.normalcy_cd))
     )
    IF (ce.normal_low > " "
     AND ce.normal_high > " ")
     temp->el[d.seq].lr[lcnt].ref_range = build("(",ce.normal_low,"-",ce.normal_high,")")
    ENDIF
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
     CALL uar_rtf(blob_out,textlen(blob_out),blob_out2,32000,32000,0), blob_out = blob_out2, temp->
     el[d.seq].lr[lcnt].note = blob_out
    ENDIF
   FOOT  d.seq
    temp->el[d.seq].lr_cnt = lcnt
   WITH nocounter, memsort, outerjoin = d3
  ;end select
 ENDIF
 IF (nurse_result_ind=1
  AND (temp2->nrec_cnt=0))
  SELECT INTO "nl:"
   notefound = decode(lb.seq,1,0), tl = textlen(lb.long_blob)
   FROM (dummyt d  WITH seq = value(temp->ecnt)),
    orders o,
    clinical_event ce,
    (dummyt d2  WITH seq = 1),
    ce_event_note cen,
    long_blob lb
   PLAN (d)
    JOIN (o
    WHERE (o.encntr_id=temp->el[d.seq].encntr_id)
     AND o.catalog_type_cd=nurs_cd
     AND o.template_order_flag IN (0, 2))
    JOIN (ce
    WHERE ce.order_id=o.order_id
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.event_end_dt_tm >= cnvtdatetime((curdate - 3),curtime)
     AND ce.event_end_dt_tm <= cnvtdatetime(curdate,curtime)
     AND ce.result_status_cd != inerror_cd)
    JOIN (d2)
    JOIN (cen
    WHERE ce.event_id=cen.event_id)
    JOIN (lb
    WHERE lb.parent_entity_id=cen.ce_event_note_id
     AND lb.parent_entity_name="CE_EVENT_NOTE")
   ORDER BY d.seq, o.hna_order_mnemonic, cnvtdatetime(ce.event_end_dt_tm)
   HEAD d.seq
    ncnt = 0
   DETAIL
    ncnt = (ncnt+ 1), stat = alterlist(temp->el[d.seq].nr,ncnt), temp->el[d.seq].nr[ncnt].event_cd =
    ce.event_cd,
    temp->el[d.seq].nr[ncnt].dayofweek = 0, temp->el[d.seq].nr[ncnt].event_name = trim(
     uar_get_code_display(ce.event_cd))
    IF (ce.event_class_cd IN (txt_cd, num_cd, date_cd))
     temp->el[d.seq].nr[ncnt].result_val = trim(ce.event_tag)
    ELSE
     temp->el[d.seq].nr[ncnt].result_val = "See PowerChart"
    ENDIF
    temp->el[d.seq].nr[ncnt].order_id = ce.order_id, temp->el[d.seq].nr[ncnt].verify_dt_tm = format(
     ce.verified_dt_tm,"mm/dd hh:mm;;d"), temp->el[d.seq].nr[ncnt].event_end_dt_tm = format(ce
     .event_end_dt_tm,"mm/dd hh:mm;;d"),
    temp->el[d.seq].nr[ncnt].normalcy_disp = trim(uar_get_code_display(ce.normalcy_cd))
    IF (ce.normal_low > " "
     AND ce.normal_high > " ")
     temp->el[d.seq].nr[ncnt].ref_range = build("(",ce.normal_low,"-",ce.normal_high,")")
    ENDIF
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
     CALL uar_rtf(blob_out,textlen(blob_out),blob_out2,32000,32000,0), blob_out = blob_out2, temp->
     el[d.seq].nr[ncnt].note = blob_out
    ENDIF
   FOOT  d.seq
    temp->el[d.seq].nr_cnt = ncnt
   WITH nocounter, memsort, outerjoin = d2
  ;end select
 ENDIF
 IF (nurse_result_ind=1
  AND (temp2->nrec_cnt > 0))
  SELECT INTO "nl:"
   notefound = decode(lb.seq,1,0), tl = textlen(lb.long_blob), dayofweek = weekday(ce.event_end_dt_tm
    )
   FROM (dummyt d  WITH seq = value(temp->ecnt)),
    (dummyt d2  WITH seq = value(temp2->nrec_cnt)),
    clinical_event ce,
    (dummyt d3  WITH seq = 1),
    ce_event_note cen,
    long_blob lb
   PLAN (d)
    JOIN (ce
    WHERE (ce.person_id=temp->el[d.seq].person_id)
     AND (ce.encntr_id=temp->el[d.seq].encntr_id)
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.event_end_dt_tm >= cnvtdatetime((curdate - 3),curtime)
     AND ce.event_end_dt_tm <= cnvtdatetime(curdate,curtime)
     AND ce.result_status_cd != inerror_cd)
    JOIN (d2
    WHERE (ce.event_cd=temp2->nrec[d2.seq].nr_event_cd))
    JOIN (d3)
    JOIN (cen
    WHERE ce.event_id=cen.event_id)
    JOIN (lb
    WHERE lb.parent_entity_id=cen.ce_event_note_id
     AND lb.parent_entity_name="CE_EVENT_NOTE")
   ORDER BY d.seq, cnvtdatetime(ce.event_end_dt_tm)
   HEAD d.seq
    ncnt = 0
   DETAIL
    ncnt = (ncnt+ 1), stat = alterlist(temp->el[d.seq].nr,ncnt), temp->el[d.seq].nr[ncnt].event_cd =
    ce.event_cd,
    temp->el[d.seq].nr[ncnt].dayofweek = dayofweek, temp->el[d.seq].nr[ncnt].event_name = trim(
     uar_get_code_display(ce.event_cd))
    IF (ce.event_class_cd IN (txt_cd, num_cd, date_cd))
     temp->el[d.seq].nr[ncnt].result_val = trim(ce.event_tag)
    ELSE
     temp->el[d.seq].nr[ncnt].result_val = "See PowerChart"
    ENDIF
    temp->el[d.seq].nr[ncnt].order_id = ce.order_id, temp->el[d.seq].nr[ncnt].verify_dt_tm = format(
     ce.verified_dt_tm,"mm/dd hh:mm;;d"), temp->el[d.seq].nr[ncnt].event_end_dt_tm = format(ce
     .event_end_dt_tm,"mm/dd hh:mm;;d"),
    temp->el[d.seq].nr[ncnt].normalcy_disp = trim(uar_get_code_display(ce.normalcy_cd))
    IF (ce.normal_low > " "
     AND ce.normal_high > " ")
     temp->el[d.seq].nr[ncnt].ref_range = build("(",ce.normal_low,"-",ce.normal_high,")")
    ENDIF
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
     CALL uar_rtf(blob_out,textlen(blob_out),blob_out2,32000,32000,0), blob_out = blob_out2, temp->
     el[d.seq].nr[ncnt].note = blob_out
    ENDIF
   FOOT  d.seq
    temp->el[d.seq].nr_cnt = ncnt
   WITH nocounter, memsort, outerjoin = d3
  ;end select
 ENDIF
 IF (vitals_ind=1)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(temp->ecnt)),
    clinical_event ce
   PLAN (d)
    JOIN (ce
    WHERE (ce.person_id=temp->el[d.seq].person_id)
     AND (ce.encntr_id=temp->el[d.seq].encntr_id)
     AND ce.event_cd IN (temp_cd, resp_cd, pulse_cd, sys_cd, dia_cd)
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.event_end_dt_tm >= cnvtdatetime((curdate - 3),curtime)
     AND ce.result_status_cd != inerror_cd)
   ORDER BY d.seq, cnvtdatetime(ce.event_end_dt_tm) DESC
   HEAD REPORT
    cnt = 0, tempdia = "      ", tempsys = "      "
   HEAD d.seq
    cnt = 0, stat = alterlist(temp->el[d.seq].vs,5)
   HEAD ce.event_end_dt_tm
    tempdia = "      ", tempsys = "      ", cnt = (cnt+ 1)
   DETAIL
    IF (cnt < 6)
     IF (ce.event_cd=temp_cd)
      temp->el[d.seq].vs[cnt].temp = trim(ce.event_tag)
     ELSEIF (ce.event_cd=resp_cd)
      temp->el[d.seq].vs[cnt].resp = trim(ce.event_tag)
     ELSEIF (ce.event_cd=pulse_cd)
      temp->el[d.seq].vs[cnt].pulse = trim(ce.event_tag)
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
      temp->el[d.seq].vs[cnt].bp = build(trim(tempsys),"/",trim(tempdia))
     ENDIF
     temp->el[d.seq].vs[cnt].vs_dt_tm = format(ce.event_end_dt_tm,"mm/dd hh:mm;;d")
    ENDIF
   FOOT  d.seq
    IF (cnt < 6)
     temp->el[d.seq].vs_cnt = cnt
    ELSE
     temp->el[d.seq].vs_cnt = 5
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(temp->ecnt)),
    clinical_event ce
   PLAN (d)
    JOIN (ce
    WHERE (ce.person_id=temp->el[d.seq].person_id)
     AND (ce.encntr_id=temp->el[d.seq].encntr_id)
     AND ce.event_cd IN (hgt_cd, wgt_cd)
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.event_end_dt_tm <= cnvtdatetime(curdate,curtime)
     AND ce.result_status_cd != inerror_cd)
   ORDER BY d.seq, cnvtdatetime(ce.event_end_dt_tm)
   DETAIL
    IF (ce.event_cd=hgt_cd)
     temp->el[d.seq].ht = trim(ce.event_tag), temp->el[d.seq].ht_dt_tm = format(ce.event_end_dt_tm,
      "mm/dd hh:mm;;d")
    ELSEIF (ce.event_cd=wgt_cd)
     temp->el[d.seq].wt = trim(ce.event_tag), temp->el[d.seq].wt_dt_tm = format(ce.event_end_dt_tm,
      "mm/dd hh:mm;;d")
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (documents_ind=1
  AND (temp2->doc_cnt > 0))
  SELECT INTO "nl:"
   sze = textlen(cb.blob_contents), dayofweek = weekday(ce.event_end_dt_tm)
   FROM (dummyt d  WITH seq = value(temp->ecnt)),
    (dummyt d2  WITH seq = value(temp2->doc_cnt)),
    clinical_event ce,
    clinical_event ce2,
    ce_blob_result cbr,
    ce_blob cb,
    prsnl pl
   PLAN (d)
    JOIN (ce
    WHERE (ce.person_id=temp->el[d.seq].person_id)
     AND (ce.encntr_id=temp->el[d.seq].encntr_id)
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.event_end_dt_tm >= cnvtdatetime((curdate - 3),curtime)
     AND ce.event_end_dt_tm <= cnvtdatetime(curdate,curtime)
     AND ce.result_status_cd != inerror_cd
     AND ce.event_class_cd IN (doc_cd, mdoc_cd))
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
   ORDER BY d.seq, cnvtdatetime(ce.event_end_dt_tm), ce.event_cd,
    ce2.parent_event_id
   HEAD d.seq
    temp->el[d.seq].doc_cnt = 0, hold_event_id = 0, cnt = 0
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
     CALL uar_rtf(blob_out,textlen(blob_out),blob_out2,32000,32000,0), temp->el[d.seq].doc[cnt].
     doc_blob = concat(temp->el[d.seq].doc[cnt].doc_blob," | ",trim(blob_out2))
    ELSE
     cnt = (cnt+ 1), stat = alterlist(temp->el[d.seq].doc,cnt), blob_out = fillstring(32000," "),
     blob_out2 = fillstring(32000," "), blob_out3 = fillstring(32000," ")
     IF (cb.compression_cd=ocfcomp_cd)
      blob_out = fillstring(32000," "), blob_ret_len = 0,
      CALL uar_ocf_uncompress(cb.blob_contents,sze,blob_out,32000,blob_ret_len)
     ELSE
      blob_out = fillstring(32000," "), y1 = size(trim(cb.blob_contents)), blob_out = substring(1,(y1
        - 8),cb.blob_contents)
     ENDIF
     temp->el[d.seq].doc[cnt].event_end_dt_tm = format(ce.event_end_dt_tm,"mm/dd hh:mm;;d"), temp->
     el[d.seq].doc[cnt].doc_author = concat(trim(pl.name_full_formatted)), temp->el[d.seq].doc[cnt].
     doc_name = trim(ce.event_tag),
     CALL uar_rtf(blob_out,textlen(blob_out),blob_out2,32000,32000,0), temp->el[d.seq].doc[cnt].
     doc_blob = trim(blob_out2), temp->el[d.seq].doc[cnt].event_cd = ce.event_cd,
     temp->el[d.seq].doc[cnt].dayofweek = dayofweek, hold_event_id = ce.event_id
    ENDIF
   FOOT  d.seq
    temp->el[d.seq].doc_cnt = cnt
   WITH nocounter, memsort
  ;end select
 ENDIF
 IF (documents_ind=1
  AND (temp2->doc_cnt=0))
  SELECT INTO "nl:"
   sze = textlen(cb.blob_contents)
   FROM (dummyt d  WITH seq = value(temp->ecnt)),
    orders o,
    clinical_event ce,
    clinical_event ce2,
    ce_blob_result cbr,
    ce_blob cb,
    prsnl pl
   PLAN (d)
    JOIN (o
    WHERE (o.encntr_id=temp->el[d.seq].encntr_id)
     AND o.catalog_type_cd != rad_cd
     AND o.template_order_flag IN (0, 2))
    JOIN (ce
    WHERE ce.order_id=o.order_id
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.event_end_dt_tm >= cnvtdatetime((curdate - 3),curtime)
     AND ce.event_end_dt_tm <= cnvtdatetime(curdate,curtime)
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
   ORDER BY d.seq, cnvtdatetime(ce.event_end_dt_tm), ce.event_cd,
    ce2.parent_event_id
   HEAD d.seq
    temp->el[d.seq].doc_cnt = 0, hold_event_id = 0, cnt = 0
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
     CALL uar_rtf(blob_out,textlen(blob_out),blob_out2,32000,32000,0), temp->el[d.seq].doc[cnt].
     doc_blob = concat(temp->el[d.seq].doc[cnt].doc_blob," | ",trim(blob_out2))
    ELSE
     cnt = (cnt+ 1), stat = alterlist(temp->el[d.seq].doc,cnt), blob_out = fillstring(32000," "),
     blob_out2 = fillstring(32000," "), blob_out3 = fillstring(32000," ")
     IF (cb.compression_cd=ocfcomp_cd)
      blob_out = fillstring(32000," "), blob_ret_len = 0,
      CALL uar_ocf_uncompress(cb.blob_contents,sze,blob_out,32000,blob_ret_len)
     ELSE
      blob_out = fillstring(32000," "), y1 = size(trim(cb.blob_contents)), blob_out = substring(1,(y1
        - 8),cb.blob_contents)
     ENDIF
     temp->el[d.seq].doc[cnt].event_end_dt_tm = format(ce.event_end_dt_tm,"mm/dd hh:mm;;d"), temp->
     el[d.seq].doc[cnt].doc_author = concat(trim(pl.name_full_formatted)), temp->el[d.seq].doc[cnt].
     doc_name = trim(ce.event_tag),
     CALL uar_rtf(blob_out,textlen(blob_out),blob_out2,32000,32000,0), temp->el[d.seq].doc[cnt].
     doc_blob = trim(blob_out2), temp->el[d.seq].doc[cnt].event_cd = ce.event_cd,
     temp->el[d.seq].doc[cnt].dayofweek = 0, hold_event_id = ce.event_id
    ENDIF
   FOOT  d.seq
    temp->el[d.seq].doc_cnt = cnt
   WITH nocounter, memsort
  ;end select
 ENDIF
 IF (radiology_ind=1
  AND (temp2->rad_cnt > 0))
  SELECT INTO "nl:"
   sze = textlen(cb.blob_contents), dayofweek = weekday(ce.event_end_dt_tm)
   FROM (dummyt d  WITH seq = value(temp->ecnt)),
    (dummyt d2  WITH seq = value(temp2->rad_cnt)),
    clinical_event rad,
    ce_linked_result clr,
    clinical_event ce,
    clinical_event ce2,
    ce_blob_result cbr,
    ce_blob cb,
    prsnl pl
   PLAN (d)
    JOIN (rad
    WHERE (rad.person_id=temp->el[d.seq].person_id)
     AND (rad.encntr_id=temp->el[d.seq].encntr_id)
     AND rad.view_level=1
     AND rad.publish_flag=1
     AND rad.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND rad.event_end_dt_tm >= cnvtdatetime((curdate - 3),curtime)
     AND rad.event_end_dt_tm <= cnvtdatetime(curdate,curtime)
     AND rad.result_status_cd != inerror_cd
     AND rad.event_class_cd=rad_doc_cd)
    JOIN (d2
    WHERE (rad.event_cd=temp2->rad[d2.seq].rad_event_cd))
    JOIN (clr
    WHERE clr.event_id=rad.event_id)
    JOIN (ce
    WHERE ce.event_id=clr.linked_event_id
     AND ce.view_level=0
     AND ce.publish_flag=1
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
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
   ORDER BY d.seq, cnvtdatetime(rad.event_end_dt_tm), rad.event_cd,
    ce2.parent_event_id
   HEAD d.seq
    temp->el[d.seq].rad_cnt = 0, hold_event_id = 0, cnt = 0
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
     CALL uar_rtf(blob_out,textlen(blob_out),blob_out2,32000,32000,0), temp->el[d.seq].rad[cnt].
     rad_blob = concat(temp->el[d.seq].rad[cnt].rad_blob," | ",trim(blob_out2))
    ELSE
     cnt = (cnt+ 1), stat = alterlist(temp->el[d.seq].rad,cnt), blob_out = fillstring(32000," "),
     blob_out2 = fillstring(32000," "), blob_out3 = fillstring(32000," ")
     IF (cb.compression_cd=ocfcomp_cd)
      blob_out = fillstring(32000," "), blob_ret_len = 0,
      CALL uar_ocf_uncompress(cb.blob_contents,sze,blob_out,32000,blob_ret_len)
     ELSE
      blob_out = fillstring(32000," "), y1 = size(trim(cb.blob_contents)), blob_out = substring(1,(y1
        - 8),cb.blob_contents)
     ENDIF
     temp->el[d.seq].rad[cnt].event_end_dt_tm = format(rad.event_end_dt_tm,"mm/dd hh:mm;;d"), temp->
     el[d.seq].rad[cnt].rad_author = concat(trim(pl.name_full_formatted)), temp->el[d.seq].rad[cnt].
     rad_name = trim(rad.event_tag),
     CALL uar_rtf(blob_out,textlen(blob_out),blob_out2,32000,32000,0), temp->el[d.seq].rad[cnt].
     rad_blob = trim(blob_out2), temp->el[d.seq].rad[cnt].event_cd = rad.event_cd,
     temp->el[d.seq].rad[cnt].dayofweek = dayofweek, hold_event_id = ce.event_id
    ENDIF
   FOOT  d.seq
    temp->el[d.seq].rad_cnt = cnt
   WITH nocounter, memsort
  ;end select
 ENDIF
 IF (radiology_ind=1
  AND (temp2->rad_cnt=0))
  SELECT INTO "nl:"
   sze = textlen(cb.blob_contents)
   FROM (dummyt d  WITH seq = value(temp->ecnt)),
    orders o,
    clinical_event rad,
    ce_linked_result clr,
    clinical_event ce,
    clinical_event ce2,
    ce_blob_result cbr,
    ce_blob cb,
    prsnl pl
   PLAN (d)
    JOIN (o
    WHERE (o.encntr_id=temp->el[d.seq].encntr_id)
     AND o.catalog_type_cd=rad_cd
     AND o.template_order_flag IN (0, 2))
    JOIN (rad
    WHERE rad.order_id=o.order_id
     AND rad.view_level=1
     AND rad.publish_flag=1
     AND rad.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND rad.event_end_dt_tm >= cnvtdatetime((curdate - 3),curtime)
     AND rad.event_end_dt_tm <= cnvtdatetime(curdate,curtime)
     AND rad.result_status_cd != inerror_cd
     AND rad.event_class_cd=rad_doc_cd)
    JOIN (clr
    WHERE clr.event_id=rad.event_id)
    JOIN (ce
    WHERE ce.event_id=clr.linked_event_id
     AND ce.view_level=0
     AND ce.publish_flag=1
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
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
   ORDER BY d.seq, cnvtdatetime(rad.event_end_dt_tm), rad.event_cd,
    ce2.parent_event_id
   HEAD d.seq
    temp->el[d.seq].rad_cnt = 0, hold_event_id = 0, cnt = 0
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
     CALL uar_rtf(blob_out,textlen(blob_out),blob_out2,32000,32000,0), temp->el[d.seq].rad[cnt].
     rad_blob = concat(temp->el[d.seq].rad[cnt].rad_blob," | ",trim(blob_out2))
    ELSE
     cnt = (cnt+ 1), stat = alterlist(temp->el[d.seq].rad,cnt), blob_out = fillstring(32000," "),
     blob_out2 = fillstring(32000," "), blob_out3 = fillstring(32000," ")
     IF (cb.compression_cd=ocfcomp_cd)
      blob_out = fillstring(32000," "), blob_ret_len = 0,
      CALL uar_ocf_uncompress(cb.blob_contents,sze,blob_out,32000,blob_ret_len)
     ELSE
      blob_out = fillstring(32000," "), y1 = size(trim(cb.blob_contents)), blob_out = substring(1,(y1
        - 8),cb.blob_contents)
     ENDIF
     temp->el[d.seq].rad[cnt].event_end_dt_tm = format(rad.event_end_dt_tm,"mm/dd hh:mm;;d"), temp->
     el[d.seq].rad[cnt].rad_author = concat(trim(pl.name_full_formatted)), temp->el[d.seq].rad[cnt].
     rad_name = trim(rad.event_tag),
     CALL uar_rtf(blob_out,textlen(blob_out),blob_out2,32000,32000,0), temp->el[d.seq].rad[cnt].
     rad_blob = trim(blob_out2), temp->el[d.seq].rad[cnt].event_cd = rad.event_cd,
     temp->el[d.seq].rad[cnt].dayofweek = 0, hold_event_id = ce.event_id
    ENDIF
   FOOT  d.seq
    temp->el[d.seq].rad_cnt = cnt
   WITH nocounter, memsort
  ;end select
 ENDIF
 IF (progress_note_ind=1
  AND (temp2->pro_cnt > 0))
  SELECT INTO "nl:"
   sze = textlen(cb.blob_contents), dayofweek = weekday(ce.event_end_dt_tm)
   FROM (dummyt d  WITH seq = value(temp->ecnt)),
    (dummyt d2  WITH seq = value(temp2->pro_cnt)),
    clinical_event ce,
    clinical_event ce2,
    ce_blob_result cbr,
    ce_blob cb,
    prsnl pl
   PLAN (d)
    JOIN (ce
    WHERE (ce.person_id=temp->el[d.seq].person_id)
     AND (ce.encntr_id=temp->el[d.seq].encntr_id)
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.event_end_dt_tm >= cnvtdatetime((curdate - 3),curtime)
     AND ce.event_end_dt_tm <= cnvtdatetime(curdate,curtime)
     AND ce.result_status_cd != inerror_cd
     AND ce.event_class_cd IN (doc_cd, mdoc_cd))
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
   ORDER BY d.seq, cnvtdatetime(ce.event_end_dt_tm), ce.event_cd,
    ce2.parent_event_id
   HEAD d.seq
    temp->el[d.seq].pro_cnt = 0, hold_event_id = 0, cnt = 0
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
     CALL uar_rtf(blob_out,textlen(blob_out),blob_out2,32000,32000,0), temp->el[d.seq].pro[cnt].
     pro_blob = concat(temp->el[d.seq].pro[cnt].pro_blob," | ",trim(blob_out2))
    ELSE
     cnt = (cnt+ 1), stat = alterlist(temp->el[d.seq].pro,cnt), blob_out = fillstring(32000," "),
     blob_out2 = fillstring(32000," "), blob_out3 = fillstring(32000," ")
     IF (cb.compression_cd=ocfcomp_cd)
      blob_out = fillstring(32000," "), blob_ret_len = 0,
      CALL uar_ocf_uncompress(cb.blob_contents,sze,blob_out,32000,blob_ret_len)
     ELSE
      blob_out = fillstring(32000," "), y1 = size(trim(cb.blob_contents)), blob_out = substring(1,(y1
        - 8),cb.blob_contents)
     ENDIF
     temp->el[d.seq].pro[cnt].event_end_dt_tm = format(ce.event_end_dt_tm,"mm/dd hh:mm;;d"), temp->
     el[d.seq].pro[cnt].pro_author = concat(trim(pl.name_full_formatted)), temp->el[d.seq].pro[cnt].
     pro_name = trim(ce.event_tag),
     CALL uar_rtf(blob_out,textlen(blob_out),blob_out2,32000,32000,0), temp->el[d.seq].pro[cnt].
     pro_blob = trim(blob_out2), temp->el[d.seq].pro[cnt].event_cd = ce.event_cd,
     temp->el[d.seq].pro[cnt].dayofweek = dayofweek, hold_event_id = ce.event_id
    ENDIF
   FOOT  d.seq
    temp->el[d.seq].pro_cnt = cnt
   WITH nocounter, memsort
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
  GO TO load_reply
 ENDIF
 IF (vieworder_secur_cd=0
  AND viewresult_secur_cd=0)
  GO TO load_reply
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
 FOR (x = 1 TO temp->ecnt)
   IF (pending_order_ind=1)
    SET hold->o_cnt = 0
    FOR (y = 1 TO temp->el[x].po_cnt)
      SET match_found = "N"
      FOR (z = 1 TO temp2->oe_cnt)
        IF ((((temp2->oe[z].oe_type_flag="O")
         AND (temp2->oe[z].catalog_cd=temp->el[x].po[y].po_catalog_cd)) OR ((((temp2->oe[z].
        oe_type_flag="C")
         AND (temp2->oe[z].catalog_type_cd=temp->el[x].po[y].po_catalog_type_cd)) OR ((temp2->oe[z].
        oe_type_flag="A")
         AND (temp2->oe[z].activity_type_cd=temp->el[x].po[y].po_activity_type_cd))) )) )
         SET match_found = "Y"
         SET z = temp2->oe_cnt
        ENDIF
      ENDFOR
      IF (((vieworder_secur_cd=include_cd
       AND match_found="Y") OR (vieworder_secur_cd=exclude_cd
       AND match_found="N")) )
       SET hold->o_cnt = (hold->o_cnt+ 1)
       SET stat = alterlist(hold->o,value(hold->o_cnt))
       SET hold->o[hold->o_cnt].po_catalog_cd = temp->el[x].po[y].po_catalog_cd
       SET hold->o[hold->o_cnt].po_catalog_type_cd = temp->el[x].po[y].po_catalog_type_cd
       SET hold->o[hold->o_cnt].po_activity_type_cd = temp->el[x].po[y].po_activity_type_cd
       SET hold->o[hold->o_cnt].po_order_id = temp->el[x].po[y].po_order_id
       SET hold->o[hold->o_cnt].po_mnemonic = temp->el[x].po[y].po_mnemonic
       SET hold->o[hold->o_cnt].po_disp_line = temp->el[x].po[y].po_disp_line
      ENDIF
    ENDFOR
    IF ((hold->o_cnt != temp->el[x].po_cnt))
     SET stat = alterlist(temp->el[x].po,value(hold->o_cnt))
     FOR (y = 1 TO hold->o_cnt)
       SET temp->el[x].po[y].po_catalog_cd = hold->o[y].po_catalog_cd
       SET temp->el[x].po[y].po_catalog_type_cd = hold->o[y].po_catalog_type_cd
       SET temp->el[x].po[y].po_activity_type_cd = hold->o[y].po_activity_type_cd
       SET temp->el[x].po[y].po_order_id = hold->o[y].po_order_id
       SET temp->el[x].po[y].po_mnemonic = hold->o[y].po_mnemonic
       SET temp->el[x].po[y].po_disp_line = hold->o[y].po_disp_line
     ENDFOR
    ENDIF
   ENDIF
   IF (active_order_ind=1)
    SET hold->o_cnt = 0
    FOR (y = 1 TO temp->el[x].ao_cnt)
      SET match_found = "N"
      FOR (z = 1 TO temp2->oe_cnt)
        IF ((((temp2->oe[z].oe_type_flag="O")
         AND (temp2->oe[z].catalog_cd=temp->el[x].ao[y].ao_catalog_cd)) OR ((((temp2->oe[z].
        oe_type_flag="C")
         AND (temp2->oe[z].catalog_type_cd=temp->el[x].ao[y].ao_catalog_type_cd)) OR ((temp2->oe[z].
        oe_type_flag="A")
         AND (temp2->oe[z].activity_type_cd=temp->el[x].ao[y].ao_activity_type_cd))) )) )
         SET match_found = "Y"
         SET z = temp2->oe_cnt
        ENDIF
      ENDFOR
      IF (((vieworder_secur_cd=include_cd
       AND match_found="Y") OR (vieworder_secur_cd=exclude_cd
       AND match_found="N")) )
       SET hold->o_cnt = (hold->o_cnt+ 1)
       SET stat = alterlist(hold->o,value(hold->o_cnt))
       SET hold->o[hold->o_cnt].ao_catalog_cd = temp->el[x].ao[y].ao_catalog_cd
       SET hold->o[hold->o_cnt].ao_catalog_type_cd = temp->el[x].ao[y].ao_catalog_type_cd
       SET hold->o[hold->o_cnt].ao_activity_type_cd = temp->el[x].ao[y].ao_activity_type_cd
       SET hold->o[hold->o_cnt].ao_order_id = temp->el[x].ao[y].ao_order_id
       SET hold->o[hold->o_cnt].ao_mnemonic = temp->el[x].ao[y].ao_mnemonic
       SET hold->o[hold->o_cnt].ao_disp_line = temp->el[x].ao[y].ao_disp_line
      ENDIF
    ENDFOR
    IF ((hold->o_cnt != temp->el[x].ao_cnt))
     SET stat = alterlist(temp->el[x].ao,value(hold->o_cnt))
     FOR (y = 1 TO hold->o_cnt)
       SET temp->el[x].ao[y].ao_catalog_cd = hold->o[y].ao_catalog_cd
       SET temp->el[x].ao[y].ao_catalog_type_cd = hold->o[y].ao_catalog_type_cd
       SET temp->el[x].ao[y].ao_activity_type_cd = hold->o[y].ao_activity_type_cd
       SET temp->el[x].ao[y].ao_order_id = hold->o[y].ao_order_id
       SET temp->el[x].ao[y].ao_mnemonic = hold->o[y].ao_mnemonic
       SET temp->el[x].ao[y].ao_disp_line = hold->o[y].ao_disp_line
     ENDFOR
    ENDIF
   ENDIF
   IF (med_order_ind=1)
    SET hold->o_cnt = 0
    FOR (y = 1 TO temp->el[x].mo_cnt)
      SET match_found = "N"
      FOR (z = 1 TO temp2->oe_cnt)
        IF ((((temp2->oe[z].oe_type_flag="O")
         AND (temp2->oe[z].catalog_cd=temp->el[x].mo[y].mo_catalog_cd)) OR ((((temp2->oe[z].
        oe_type_flag="C")
         AND (temp2->oe[z].catalog_type_cd=temp->el[x].mo[y].mo_catalog_type_cd)) OR ((temp2->oe[z].
        oe_type_flag="A")
         AND (temp2->oe[z].activity_type_cd=temp->el[x].mo[y].mo_activity_type_cd))) )) )
         SET match_found = "Y"
         SET z = temp2->oe_cnt
        ENDIF
      ENDFOR
      IF (((vieworder_secur_cd=include_cd
       AND match_found="Y") OR (vieworder_secur_cd=exclude_cd
       AND match_found="N")) )
       SET hold->o_cnt = (hold->o_cnt+ 1)
       SET stat = alterlist(hold->o,value(hold->o_cnt))
       SET hold->o[hold->o_cnt].mo_catalog_cd = temp->el[x].mo[y].mo_catalog_cd
       SET hold->o[hold->o_cnt].mo_catalog_type_cd = temp->el[x].mo[y].mo_catalog_type_cd
       SET hold->o[hold->o_cnt].mo_activity_type_cd = temp->el[x].mo[y].mo_activity_type_cd
       SET hold->o[hold->o_cnt].mo_order_id = temp->el[x].mo[y].mo_order_id
       SET hold->o[hold->o_cnt].mo_mnemonic = temp->el[x].mo[y].mo_mnemonic
       SET hold->o[hold->o_cnt].mo_disp_line = temp->el[x].mo[y].mo_disp_line
       SET hold->o[hold->o_cnt].mo_freq = temp->el[x].mo[y].mo_freq
       SET hold->o[hold->o_cnt].mo_route = temp->el[x].mo[y].mo_route
       SET hold->o[hold->o_cnt].mo_dose = temp->el[x].mo[y].mo_dose
       SET hold->o[hold->o_cnt].mo_doseunit = temp->el[x].mo[y].mo_doseunit
       SET hold->o[hold->o_cnt].dnum = temp->el[x].mo[y].dnum
      ENDIF
    ENDFOR
    IF ((hold->o_cnt != temp->el[x].mo_cnt))
     SET stat = alterlist(temp->el[x].mo,value(hold->o_cnt))
     FOR (y = 1 TO hold->o_cnt)
       SET temp->el[x].mo[y].mo_catalog_cd = hold->o[y].mo_catalog_cd
       SET temp->el[x].mo[y].mo_catalog_type_cd = hold->o[y].mo_catalog_type_cd
       SET temp->el[x].mo[y].mo_activity_type_cd = hold->o[y].mo_activity_type_cd
       SET temp->el[x].mo[y].mo_order_id = hold->o[y].mo_order_id
       SET temp->el[x].mo[y].mo_mnemonic = hold->o[y].mo_mnemonic
       SET temp->el[x].mo[y].mo_disp_line = hold->o[y].mo_disp_line
       SET temp->el[x].mo[y].mo_freq = hold->o[y].mo_freq
       SET temp->el[x].mo[y].mo_route = hold->o[y].mo_route
       SET temp->el[x].mo[y].mo_dose = hold->o[y].mo_dose
       SET temp->el[x].mo[y].mo_doseunit = hold->o[y].mo_doseunit
       SET temp->el[x].mo[y].dnum = hold->o[y].dnum
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
  GO TO load_reply
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
 FOR (x = 1 TO temp->ecnt)
   IF (lab_result_ind=1)
    SET hold->r_cnt = 0
    FOR (y = 1 TO temp->el[x].lr_cnt)
      SET match_found = "N"
      FOR (z = 1 TO temp2->re_cnt)
        IF ((temp2->re[z].event_cd=temp->el[x].lr[y].event_cd))
         SET match_found = "Y"
         SET z = temp2->re_cnt
        ENDIF
      ENDFOR
      IF (((viewresult_secur_cd=include_cd
       AND match_found="Y") OR (viewresult_secur_cd=exclude_cd
       AND match_found="N")) )
       SET hold->r_cnt = (hold->r_cnt+ 1)
       SET stat = alterlist(hold->r,value(hold->r_cnt))
       SET hold->r[hold->r_cnt].event_cd = temp->el[x].lr[y].event_cd
       SET hold->r[hold->r_cnt].dayofweek = temp->el[x].lr[y].dayofweek
       SET hold->r[hold->r_cnt].event_name = temp->el[x].lr[y].event_name
       SET hold->r[hold->r_cnt].result_val = temp->el[x].lr[y].result_val
       SET hold->r[hold->r_cnt].order_id = temp->el[x].lr[y].order_id
       SET hold->r[hold->r_cnt].verify_dt_tm = temp->el[x].lr[y].verify_dt_tm
       SET hold->r[hold->r_cnt].event_end_dt_tm = temp->el[x].lr[y].event_end_dt_tm
       SET hold->r[hold->r_cnt].normalcy_disp = temp->el[x].lr[y].normalcy_disp
       SET hold->r[hold->r_cnt].ref_range = temp->el[x].lr[y].ref_range
       SET hold->r[hold->r_cnt].note = temp->el[x].lr[y].note
      ENDIF
    ENDFOR
    IF ((hold->r_cnt != temp->el[x].lr_cnt))
     SET stat = alterlist(temp->el[x].lr,value(hold->r_cnt))
     FOR (y = 1 TO hold->r_cnt)
       SET temp->el[x].lr[y].event_cd = hold->r[y].event_cd
       SET temp->el[x].lr[y].dayofweek = hold->r[y].dayofweek
       SET temp->el[x].lr[y].event_name = hold->r[y].event_name
       SET temp->el[x].lr[y].result_val = hold->r[y].result_val
       SET temp->el[x].lr[y].order_id = hold->r[y].order_id
       SET temp->el[x].lr[y].verify_dt_tm = hold->r[y].verify_dt_tm
       SET temp->el[x].lr[y].event_end_dt_tm = hold->r[y].event_end_dt_tm
       SET temp->el[x].lr[y].normalcy_disp = hold->r[y].normalcy_disp
       SET temp->el[x].lr[y].ref_range = hold->r[y].ref_range
       SET temp->el[x].lr[y].note = hold->r[y].note
     ENDFOR
    ENDIF
   ENDIF
   IF (nurse_result_ind=1)
    SET hold->r_cnt = 0
    FOR (y = 1 TO temp->el[x].nr_cnt)
      SET match_found = "N"
      FOR (z = 1 TO temp2->re_cnt)
        IF ((temp2->re[z].event_cd=temp->el[x].nr[y].event_cd))
         SET match_found = "Y"
         SET z = temp2->re_cnt
        ENDIF
      ENDFOR
      IF (((viewresult_secur_cd=include_cd
       AND match_found="Y") OR (viewresult_secur_cd=exclude_cd
       AND match_found="N")) )
       SET hold->r_cnt = (hold->r_cnt+ 1)
       SET stat = alterlist(hold->r,value(hold->r_cnt))
       SET hold->r[hold->r_cnt].event_cd = temp->el[x].nr[y].event_cd
       SET hold->r[hold->r_cnt].dayofweek = temp->el[x].nr[y].dayofweek
       SET hold->r[hold->r_cnt].event_name = temp->el[x].nr[y].event_name
       SET hold->r[hold->r_cnt].result_val = temp->el[x].nr[y].result_val
       SET hold->r[hold->r_cnt].order_id = temp->el[x].nr[y].order_id
       SET hold->r[hold->r_cnt].verify_dt_tm = temp->el[x].nr[y].verify_dt_tm
       SET hold->r[hold->r_cnt].event_end_dt_tm = temp->el[x].nr[y].event_end_dt_tm
       SET hold->r[hold->r_cnt].normalcy_disp = temp->el[x].nr[y].normalcy_disp
       SET hold->r[hold->r_cnt].ref_range = temp->el[x].nr[y].ref_range
       SET hold->r[hold->r_cnt].note = temp->el[x].nr[y].note
      ENDIF
    ENDFOR
    IF ((hold->r_cnt != temp->el[x].nr_cnt))
     SET stat = alterlist(temp->el[x].nr,value(hold->r_cnt))
     FOR (y = 1 TO hold->r_cnt)
       SET temp->el[x].nr[y].event_cd = hold->r[y].event_cd
       SET temp->el[x].nr[y].dayofweek = hold->r[y].dayofweek
       SET temp->el[x].nr[y].event_name = hold->r[y].event_name
       SET temp->el[x].nr[y].result_val = hold->r[y].result_val
       SET temp->el[x].nr[y].order_id = hold->r[y].order_id
       SET temp->el[x].nr[y].verify_dt_tm = hold->r[y].verify_dt_tm
       SET temp->el[x].nr[y].event_end_dt_tm = hold->r[y].event_end_dt_tm
       SET temp->el[x].nr[y].normalcy_disp = hold->r[y].normalcy_disp
       SET temp->el[x].nr[y].ref_range = hold->r[y].ref_range
       SET temp->el[x].nr[y].note = hold->r[y].note
     ENDFOR
    ENDIF
   ENDIF
   IF (documents_ind=1)
    SET hold->r_cnt = 0
    FOR (y = 1 TO temp->el[x].doc_cnt)
      SET match_found = "N"
      FOR (z = 1 TO temp2->re_cnt)
        IF ((temp2->re[z].event_cd=temp->el[x].doc[y].event_cd))
         SET match_found = "Y"
         SET z = temp2->re_cnt
        ENDIF
      ENDFOR
      IF (((viewresult_secur_cd=include_cd
       AND match_found="Y") OR (viewresult_secur_cd=exclude_cd
       AND match_found="N")) )
       SET hold->r_cnt = (hold->r_cnt+ 1)
       SET stat = alterlist(hold->r,value(hold->r_cnt))
       SET hold->r[hold->r_cnt].event_cd = temp->el[x].doc[y].event_cd
       SET hold->r[hold->r_cnt].dayofweek = temp->el[x].doc[y].dayofweek
       SET hold->r[hold->r_cnt].doc_name = temp->el[x].doc[y].doc_name
       SET hold->r[hold->r_cnt].doc_blob = temp->el[x].doc[y].doc_blob
       SET hold->r[hold->r_cnt].event_end_dt_tm = temp->el[x].doc[y].event_end_dt_tm
       SET hold->r[hold->r_cnt].doc_author = temp->el[x].doc[y].doc_author
      ENDIF
    ENDFOR
    IF ((hold->r_cnt != temp->el[x].doc_cnt))
     SET stat = alterlist(temp->el[x].doc,value(hold->r_cnt))
     FOR (y = 1 TO hold->r_cnt)
       SET temp->el[x].doc[y].event_cd = hold->r[y].event_cd
       SET temp->el[x].doc[y].dayofweek = hold->r[y].dayofweek
       SET temp->el[x].doc[y].doc_name = hold->r[y].doc_name
       SET temp->el[x].doc[y].doc_blob = hold->r[y].doc_blob
       SET temp->el[x].doc[y].event_end_dt_tm = hold->r[y].event_end_dt_tm
       SET temp->el[x].doc[y].doc_author = hold->r[y].doc_author
     ENDFOR
    ENDIF
   ENDIF
   IF (radiology_ind=1)
    SET hold->r_cnt = 0
    FOR (y = 1 TO temp->el[x].rad_cnt)
      SET match_found = "N"
      FOR (z = 1 TO temp2->re_cnt)
        IF ((temp2->re[z].event_cd=temp->el[x].rad[y].event_cd))
         SET match_found = "Y"
         SET z = temp2->re_cnt
        ENDIF
      ENDFOR
      IF (((viewresult_secur_cd=include_cd
       AND match_found="Y") OR (viewresult_secur_cd=exclude_cd
       AND match_found="N")) )
       SET hold->r_cnt = (hold->r_cnt+ 1)
       SET stat = alterlist(hold->r,value(hold->r_cnt))
       SET hold->r[hold->r_cnt].event_cd = temp->el[x].rad[y].event_cd
       SET hold->r[hold->r_cnt].dayofweek = temp->el[x].rad[y].dayofweek
       SET hold->r[hold->r_cnt].doc_name = temp->el[x].rad[y].rad_name
       SET hold->r[hold->r_cnt].doc_blob = temp->el[x].rad[y].rad_blob
       SET hold->r[hold->r_cnt].event_end_dt_tm = temp->el[x].rad[y].event_end_dt_tm
       SET hold->r[hold->r_cnt].doc_author = temp->el[x].rad[y].rad_author
      ENDIF
    ENDFOR
    IF ((hold->r_cnt != temp->el[x].rad_cnt))
     SET stat = alterlist(temp->el[x].rad,value(hold->r_cnt))
     FOR (y = 1 TO hold->r_cnt)
       SET temp->el[x].rad[y].event_cd = hold->r[y].event_cd
       SET temp->el[x].rad[y].dayofweek = hold->r[y].dayofweek
       SET temp->el[x].rad[y].rad_name = hold->r[y].doc_name
       SET temp->el[x].rad[y].rad_blob = hold->r[y].doc_blob
       SET temp->el[x].rad[y].event_end_dt_tm = hold->r[y].event_end_dt_tm
       SET temp->el[x].rad[y].rad_author = hold->r[y].doc_author
     ENDFOR
    ENDIF
   ENDIF
   IF (progress_note_ind=1)
    SET hold->r_cnt = 0
    FOR (y = 1 TO temp->el[x].pro_cnt)
      SET match_found = "N"
      FOR (z = 1 TO temp2->re_cnt)
        IF ((temp2->re[z].event_cd=temp->el[x].pro[y].event_cd))
         SET match_found = "Y"
         SET z = temp2->re_cnt
        ENDIF
      ENDFOR
      IF (((viewresult_secur_cd=include_cd
       AND match_found="Y") OR (viewresult_secur_cd=exclude_cd
       AND match_found="N")) )
       SET hold->r_cnt = (hold->r_cnt+ 1)
       SET stat = alterlist(hold->r,value(hold->r_cnt))
       SET hold->r[hold->r_cnt].event_cd = temp->el[x].pro[y].event_cd
       SET hold->r[hold->r_cnt].dayofweek = temp->el[x].pro[y].dayofweek
       SET hold->r[hold->r_cnt].doc_name = temp->el[x].pro[y].pro_name
       SET hold->r[hold->r_cnt].doc_blob = temp->el[x].pro[y].pro_blob
       SET hold->r[hold->r_cnt].event_end_dt_tm = temp->el[x].pro[y].event_end_dt_tm
       SET hold->r[hold->r_cnt].doc_author = temp->el[x].pro[y].pro_author
      ENDIF
    ENDFOR
    IF ((hold->r_cnt != temp->el[x].pro_cnt))
     SET stat = alterlist(temp->el[x].pro,value(hold->r_cnt))
     FOR (y = 1 TO hold->r_cnt)
       SET temp->el[x].pro[y].event_cd = hold->r[y].event_cd
       SET temp->el[x].pro[y].dayofweek = hold->r[y].dayofweek
       SET temp->el[x].pro[y].pro_name = hold->r[y].doc_name
       SET temp->el[x].pro[y].pro_blob = hold->r[y].doc_blob
       SET temp->el[x].pro[y].event_end_dt_tm = hold->r[y].event_end_dt_tm
       SET temp->el[x].pro[y].pro_author = hold->r[y].doc_author
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
#load_reply
 SET reply->check_box_ind = 0
 SET reply->creation_dt_tm = cnvtdatetime(curdate,curtime)
 SET reply->expiration_dt_tm = cnvtdatetime((curdate+ 1),curtime)
 SET reply->delete_dt_tm = cnvtdatetime((curdate+ 3),curtime)
 SET stat = alterlist(reply->col,15)
 SET reply->col[1].header = "Room/Bed"
 SET reply->col[1].width = 22
 SET reply->col[1].primary_ind = 0
 SET reply->col[2].header = "Name"
 SET reply->col[2].width = 53
 SET reply->col[2].primary_ind = 1
 SET reply->col[3].header = "Age & Sex"
 SET reply->col[3].width = 25
 SET reply->col[3].primary_ind = 0
 SET reply->col[4].header = "Reason"
 SET reply->col[4].width = 0
 SET reply->col[4].primary_ind = 0
 SET reply->col[5].header = "Insurance    "
 SET reply->col[5].width = 0
 SET reply->col[5].primary_ind = 0
 SET reply->col[6].header = "Address      "
 SET reply->col[6].width = 0
 SET reply->col[6].primary_ind = 0
 SET reply->col[7].header = "Phone        "
 SET reply->col[7].width = 0
 SET reply->col[7].primary_ind = 0
 SET reply->col[8].header = "Contact Name "
 SET reply->col[8].width = 0
 SET reply->col[8].primary_ind = 0
 SET reply->col[9].header = "Contact Phone"
 SET reply->col[9].width = 0
 SET reply->col[9].primary_ind = 0
 SET reply->col[10].header = "Referring Doc"
 SET reply->col[10].width = 0
 SET reply->col[10].primary_ind = 0
 SET reply->col[11].header = "Attending Doc"
 SET reply->col[11].width = 0
 SET reply->col[11].primary_ind = 0
 SET reply->col[12].header = "Admitting Doc"
 SET reply->col[12].width = 0
 SET reply->col[12].primary_ind = 0
 SET reply->col[13].header = "Allergies    "
 SET reply->col[13].width = 0
 SET reply->col[13].primary_ind = 0
 SET reply->col[14].header = "Problems     "
 SET reply->col[14].width = 0
 SET reply->col[14].primary_ind = 0
 SET reply->col[15].header = "My Relation  "
 SET reply->col[15].width = 0
 SET reply->col[15].primary_ind = 0
 SET nbr_links = ((((((((radiology_ind+ progress_note_ind)+ documents_ind)+ lab_result_ind)+
 nurse_result_ind)+ med_order_ind)+ vitals_ind)+ pending_order_ind)+ active_order_ind)
 SET stat = alterlist(reply->links,value(nbr_links))
 SET lnk_idx = 0
 IF (lab_result_ind=1)
  SET lnk_idx = (lnk_idx+ 1)
  SET reply->links[lnk_idx].title = "LABS"
  SET reply->links[lnk_idx].type = 0
  SET reply->links[lnk_idx].menuname = "Lab Results"
  SET reply->links[lnk_idx].buttonname = "Labs"
  SET reply->links[lnk_idx].initial_ind = 1
  SET stat = alterlist(reply->links[lnk_idx].col,6)
  SET reply->links[lnk_idx].col[1].header = "Name"
  SET reply->links[lnk_idx].col[1].width = 47
  SET reply->links[lnk_idx].col[2].header = "Flag"
  SET reply->links[lnk_idx].col[2].width = 8
  SET reply->links[lnk_idx].col[3].header = "Result"
  SET reply->links[lnk_idx].col[3].width = 45
  SET reply->links[lnk_idx].col[4].header = "Ref Range"
  SET reply->links[lnk_idx].col[4].width = 0
  SET reply->links[lnk_idx].col[5].header = "Verified"
  SET reply->links[lnk_idx].col[5].width = 0
  SET reply->links[lnk_idx].col[6].header = "Notes   "
  SET reply->links[lnk_idx].col[6].width = 0
 ENDIF
 IF (med_order_ind=1)
  SET lnk_idx = (lnk_idx+ 1)
  SET reply->links[lnk_idx].title = "MEDS"
  SET reply->links[lnk_idx].type = 0
  SET reply->links[lnk_idx].menuname = "Medications"
  SET reply->links[lnk_idx].buttonname = "Meds"
  SET reply->links[lnk_idx].initial_ind = 0
  SET stat = alterlist(reply->links[lnk_idx].col,5)
  SET reply->links[lnk_idx].col[1].header = "Order"
  SET reply->links[lnk_idx].col[1].width = 55
  SET reply->links[lnk_idx].col[2].header = "Dose"
  SET reply->links[lnk_idx].col[2].width = 45
  SET reply->links[lnk_idx].col[3].header = "Route    "
  SET reply->links[lnk_idx].col[3].width = 0
  SET reply->links[lnk_idx].col[4].header = "Frequency"
  SET reply->links[lnk_idx].col[4].width = 0
  SET reply->links[lnk_idx].col[5].header = "Details"
  SET reply->links[lnk_idx].col[5].width = 0
 ENDIF
 IF (radiology_ind=1)
  SET lnk_idx = (lnk_idx+ 1)
  SET reply->links[lnk_idx].title = "RADS"
  SET reply->links[lnk_idx].type = 1
  SET reply->links[lnk_idx].menuname = "Radiology Documents"
  SET reply->links[lnk_idx].buttonname = "Rad"
  SET reply->links[lnk_idx].initial_ind = 0
  SET stat = alterlist(reply->links[lnk_idx].col,4)
  SET reply->links[lnk_idx].col[1].header = "Document Name"
  SET reply->links[lnk_idx].col[1].width = 50
  SET reply->links[lnk_idx].col[2].header = "Author"
  SET reply->links[lnk_idx].col[2].width = 50
  SET reply->links[lnk_idx].col[3].header = "Date"
  SET reply->links[lnk_idx].col[3].width = 0
  SET reply->links[lnk_idx].col[4].header = "Text"
  SET reply->links[lnk_idx].col[4].width = 0
 ENDIF
 IF (progress_note_ind=1)
  SET lnk_idx = (lnk_idx+ 1)
  SET reply->links[lnk_idx].title = "PROG"
  SET reply->links[lnk_idx].type = 1
  SET reply->links[lnk_idx].menuname = "Progress Notes"
  SET reply->links[lnk_idx].buttonname = " "
  SET reply->links[lnk_idx].initial_ind = 0
  SET stat = alterlist(reply->links[lnk_idx].col,4)
  SET reply->links[lnk_idx].col[1].header = "Document Name"
  SET reply->links[lnk_idx].col[1].width = 50
  SET reply->links[lnk_idx].col[2].header = "Author"
  SET reply->links[lnk_idx].col[2].width = 50
  SET reply->links[lnk_idx].col[3].header = "Date"
  SET reply->links[lnk_idx].col[3].width = 0
  SET reply->links[lnk_idx].col[4].header = "Text"
  SET reply->links[lnk_idx].col[4].width = 0
 ENDIF
 IF (documents_ind=1)
  SET lnk_idx = (lnk_idx+ 1)
  SET reply->links[lnk_idx].title = "DOCS"
  SET reply->links[lnk_idx].type = 1
  SET reply->links[lnk_idx].menuname = "Other Documents"
  SET reply->links[lnk_idx].buttonname = " "
  SET reply->links[lnk_idx].initial_ind = 0
  SET stat = alterlist(reply->links[lnk_idx].col,4)
  SET reply->links[lnk_idx].col[1].header = "Document Name"
  SET reply->links[lnk_idx].col[1].width = 50
  SET reply->links[lnk_idx].col[2].header = "Author"
  SET reply->links[lnk_idx].col[2].width = 50
  SET reply->links[lnk_idx].col[3].header = "Date"
  SET reply->links[lnk_idx].col[3].width = 0
  SET reply->links[lnk_idx].col[4].header = "Text"
  SET reply->links[lnk_idx].col[4].width = 0
 ENDIF
 IF (nurse_result_ind=1)
  SET lnk_idx = (lnk_idx+ 1)
  SET reply->links[lnk_idx].title = "NURS"
  SET reply->links[lnk_idx].type = 0
  SET reply->links[lnk_idx].menuname = "Patient Care Results"
  SET reply->links[lnk_idx].buttonname = " "
  SET reply->links[lnk_idx].initial_ind = 0
  SET stat = alterlist(reply->links[lnk_idx].col,4)
  SET reply->links[lnk_idx].col[1].header = "Name"
  SET reply->links[lnk_idx].col[1].width = 55
  SET reply->links[lnk_idx].col[2].header = "Result"
  SET reply->links[lnk_idx].col[2].width = 45
  SET reply->links[lnk_idx].col[3].header = "Verified"
  SET reply->links[lnk_idx].col[3].width = 0
  SET reply->links[lnk_idx].col[4].header = "Notes   "
  SET reply->links[lnk_idx].col[4].width = 0
 ENDIF
 IF (pending_order_ind=1)
  SET lnk_idx = (lnk_idx+ 1)
  SET reply->links[lnk_idx].title = "PEND"
  SET reply->links[lnk_idx].type = 0
  SET reply->links[lnk_idx].menuname = "Pending Orders"
  SET reply->links[lnk_idx].buttonname = "Pend"
  SET reply->links[lnk_idx].initial_ind = 0
  SET stat = alterlist(reply->links[lnk_idx].col,2)
  SET reply->links[lnk_idx].col[1].header = "Order"
  SET reply->links[lnk_idx].col[1].width = 55
  SET reply->links[lnk_idx].col[2].header = "Details"
  SET reply->links[lnk_idx].col[2].width = 45
 ENDIF
 IF (active_order_ind=1)
  SET lnk_idx = (lnk_idx+ 1)
  SET reply->links[lnk_idx].title = "ACTO"
  SET reply->links[lnk_idx].type = 0
  SET reply->links[lnk_idx].menuname = "Active Orders"
  SET reply->links[lnk_idx].buttonname = " "
  SET reply->links[lnk_idx].initial_ind = 0
  SET stat = alterlist(reply->links[lnk_idx].col,2)
  SET reply->links[lnk_idx].col[1].header = "Order"
  SET reply->links[lnk_idx].col[1].width = 55
  SET reply->links[lnk_idx].col[2].header = "Details"
  SET reply->links[lnk_idx].col[2].width = 45
 ENDIF
 IF (vitals_ind=1)
  SET lnk_idx = (lnk_idx+ 1)
  SET reply->links[lnk_idx].title = "VITA"
  SET reply->links[lnk_idx].type = 0
  SET reply->links[lnk_idx].menuname = "Vitals Summary"
  SET reply->links[lnk_idx].buttonname = "VS"
  SET reply->links[lnk_idx].initial_ind = 0
  SET stat = alterlist(reply->links[lnk_idx].col,11)
  SET reply->links[lnk_idx].col[1].header = "Name"
  SET reply->links[lnk_idx].col[1].width = 12
  SET reply->links[lnk_idx].col[2].header = "Result1"
  SET reply->links[lnk_idx].col[2].width = 22
  SET reply->links[lnk_idx].col[3].header = "Date1"
  SET reply->links[lnk_idx].col[3].width = 0
  SET reply->links[lnk_idx].col[4].header = "Result2"
  SET reply->links[lnk_idx].col[4].width = 22
  SET reply->links[lnk_idx].col[5].header = "Date2"
  SET reply->links[lnk_idx].col[5].width = 0
  SET reply->links[lnk_idx].col[6].header = "Result3"
  SET reply->links[lnk_idx].col[6].width = 22
  SET reply->links[lnk_idx].col[7].header = "Date3"
  SET reply->links[lnk_idx].col[7].width = 0
  SET reply->links[lnk_idx].col[8].header = "Result4"
  SET reply->links[lnk_idx].col[8].width = 22
  SET reply->links[lnk_idx].col[9].header = "Date4"
  SET reply->links[lnk_idx].col[9].width = 0
  SET reply->links[lnk_idx].col[10].header = "Result5"
  SET reply->links[lnk_idx].col[10].width = 0
  SET reply->links[lnk_idx].col[11].header = "Date5"
  SET reply->links[lnk_idx].col[11].width = 0
 ENDIF
 SET stat = alterlist(reply->row,value(temp->ecnt))
 FOR (x = 1 TO temp->ecnt)
   SET reply->row[x].separator_ind = 0
   SET reply->row[x].separator_value = ""
   SET stat = alterlist(reply->row[x].col,15)
   SET reply->row[x].col[1].value = temp->el[x].room_bed_disp
   SET reply->row[x].col[2].value = temp->el[x].name_full_formatted
   SET reply->row[x].col[3].value = concat(temp->el[x].age," ",temp->el[x].sex_disp)
   SET reply->row[x].col[4].value = temp->el[x].reason_for_visit
   SET reply->row[x].col[5].value = temp->el[x].insurance
   SET reply->row[x].col[6].value = temp->el[x].address1
   SET reply->row[x].col[7].value = temp->el[x].phone
   SET reply->row[x].col[8].value = temp->el[x].emcname
   SET reply->row[x].col[9].value = temp->el[x].emcphone
   SET reply->row[x].col[10].value = temp->el[x].refer_doc
   SET reply->row[x].col[11].value = temp->el[x].attend_doc
   SET reply->row[x].col[12].value = temp->el[x].admit_doc
   SET reply->row[x].col[13].value = temp->el[x].allergies
   SET reply->row[x].col[14].value = temp->el[x].problems
   SET reply->row[x].col[15].value = temp->el[x].myreltn
   SET stat = alterlist(reply->row[x].links,value(nbr_links))
   FOR (lnk_idx = 1 TO nbr_links)
     IF ((reply->links[lnk_idx].title="LABS"))
      SET stat = alterlist(reply->row[x].links[lnk_idx].row,value(temp->el[x].lr_cnt))
      SET hold_cnt = temp->el[x].lr_cnt
      SET holddayofweek = 0
      SET idx = 0
      FOR (y = 1 TO temp->el[x].lr_cnt)
       IF ((temp->el[x].lr[y].dayofweek != holddayofweek))
        SET holddayofweek = temp->el[x].lr[y].dayofweek
        SET hold_cnt = (hold_cnt+ 1)
        SET idx = (idx+ 1)
        SET stat = alterlist(reply->row[x].links[lnk_idx].row,hold_cnt)
        SET reply->row[x].links[lnk_idx].row[idx].separator_ind = 1
        SET reply->row[x].links[lnk_idx].row[idx].separator_value = concat("--- Results for ",temp->
         el[x].lr[y].event_end_dt_tm," ---")
       ENDIF
       IF (idx >= 255)
        SET idx = 256
        SET stat = alterlist(reply->row[x].links[lnk_idx].row,256)
        SET reply->row[x].links[lnk_idx].row[idx].separator_ind = 1
        SET reply->row[x].links[lnk_idx].row[idx].separator_value = "== UNABLE TO LOAD ALL LABS =="
        SET y = temp->el[x].lr_cnt
       ELSE
        SET idx = (idx+ 1)
        SET reply->row[x].links[lnk_idx].row[idx].separator_ind = 0
        SET reply->row[x].links[lnk_idx].row[idx].separator_value = ""
        SET stat = alterlist(reply->row[x].links[lnk_idx].row[idx].col,6)
        SET reply->row[x].links[lnk_idx].row[idx].col[1].value = temp->el[x].lr[y].event_name
        SET reply->row[x].links[lnk_idx].row[idx].col[2].value = temp->el[x].lr[y].normalcy_disp
        IF ((temp->el[x].lr[y].normalcy_disp > " "))
         SET reply->row[x].links[lnk_idx].row[idx].color = 255
        ENDIF
        SET reply->row[x].links[lnk_idx].row[idx].col[3].value = temp->el[x].lr[y].result_val
        SET reply->row[x].links[lnk_idx].row[idx].col[4].value = temp->el[x].lr[y].ref_range
        SET reply->row[x].links[lnk_idx].row[idx].col[5].value = temp->el[x].lr[y].event_end_dt_tm
        SET reply->row[x].links[lnk_idx].row[idx].col[6].value = temp->el[x].lr[y].note
        SET reply->row[x].links[lnk_idx].row[idx].blob = ""
       ENDIF
      ENDFOR
     ELSEIF ((reply->links[lnk_idx].title="MEDS"))
      SET stat = alterlist(reply->row[x].links[lnk_idx].row,value(temp->el[x].mo_cnt))
      FOR (y = 1 TO temp->el[x].mo_cnt)
        IF (y=256)
         SET reply->row[x].links[lnk_idx].row[y].separator_ind = 0
         SET reply->row[x].links[lnk_idx].row[y].separator_value = "== UNABLE TO LOAD ALL MEDS =="
         SET y = temp->el[x].mo_cnt
        ELSE
         SET reply->row[x].links[lnk_idx].row[y].separator_ind = 0
         SET reply->row[x].links[lnk_idx].row[y].separator_value = ""
         SET stat = alterlist(reply->row[x].links[lnk_idx].row[y].col,5)
         SET reply->row[x].links[lnk_idx].row[y].col[1].value = temp->el[x].mo[y].mo_mnemonic
         SET reply->row[x].links[lnk_idx].row[y].col[2].value = temp->el[x].mo[y].mo_dose
         SET reply->row[x].links[lnk_idx].row[y].col[3].value = temp->el[x].mo[y].mo_route
         SET reply->row[x].links[lnk_idx].row[y].col[4].value = temp->el[x].mo[y].mo_freq
         SET reply->row[x].links[lnk_idx].row[y].col[5].value = temp->el[x].mo[y].mo_disp_line
         SET reply->row[x].links[lnk_idx].row[y].blob = ""
        ENDIF
      ENDFOR
     ELSEIF ((reply->links[lnk_idx].title="NURS"))
      SET stat = alterlist(reply->row[x].links[lnk_idx].row,value(temp->el[x].nr_cnt))
      SET hold_cnt = temp->el[x].nr_cnt
      SET holddayofweek = 0
      SET idx = 0
      FOR (y = 1 TO temp->el[x].nr_cnt)
       IF ((temp->el[x].nr[y].dayofweek != holddayofweek))
        SET holddayofweek = temp->el[x].nr[y].dayofweek
        SET hold_cnt = (hold_cnt+ 1)
        SET idx = (idx+ 1)
        SET stat = alterlist(reply->row[x].links[lnk_idx].row,hold_cnt)
        SET reply->row[x].links[lnk_idx].row[idx].separator_ind = 1
        SET reply->row[x].links[lnk_idx].row[idx].separator_value = concat("--- Results for ",temp->
         el[x].nr[y].event_end_dt_tm," ---")
       ENDIF
       IF (idx >= 255)
        SET idx = 256
        SET stat = alterlist(reply->row[x].links[lnk_idx].row,256)
        SET reply->row[x].links[lnk_idx].row[idx].separator_ind = 1
        SET reply->row[x].links[lnk_idx].row[idx].separator_value =
        "== UNABLE TO LOAD ALL RESULTS =="
        SET y = temp->el[x].nr_cnt
       ELSE
        SET idx = (idx+ 1)
        SET reply->row[x].links[lnk_idx].row[idx].separator_ind = 0
        SET reply->row[x].links[lnk_idx].row[idx].separator_value = ""
        SET stat = alterlist(reply->row[x].links[lnk_idx].row[idx].col,4)
        SET reply->row[x].links[lnk_idx].row[idx].col[1].value = temp->el[x].nr[y].event_name
        SET reply->row[x].links[lnk_idx].row[idx].col[2].value = temp->el[x].nr[y].result_val
        SET reply->row[x].links[lnk_idx].row[idx].col[3].value = temp->el[x].nr[y].event_end_dt_tm
        SET reply->row[x].links[lnk_idx].row[idx].col[4].value = temp->el[x].nr[y].note
        SET reply->row[x].links[lnk_idx].row[idx].blob = ""
       ENDIF
      ENDFOR
     ELSEIF ((reply->links[lnk_idx].title="RADS"))
      SET stat = alterlist(reply->row[x].links[lnk_idx].row,value(temp->el[x].rad_cnt))
      SET hold_cnt = temp->el[x].rad_cnt
      SET holddayofweek = 0
      SET idx = 0
      FOR (y = 1 TO temp->el[x].rad_cnt)
       IF ((temp->el[x].rad[y].dayofweek != holddayofweek))
        SET holddayofweek = temp->el[x].rad[y].dayofweek
        SET hold_cnt = (hold_cnt+ 1)
        SET idx = (idx+ 1)
        SET stat = alterlist(reply->row[x].links[lnk_idx].row,hold_cnt)
        SET reply->row[x].links[lnk_idx].row[idx].separator_ind = 1
        SET reply->row[x].links[lnk_idx].row[idx].separator_value = concat("--- Documents for ",temp
         ->el[x].rad[y].event_end_dt_tm," ---")
       ENDIF
       IF (idx >= 255)
        SET idx = 256
        SET stat = alterlist(reply->row[x].links[lnk_idx].row,256)
        SET reply->row[x].links[lnk_idx].row[idx].separator_ind = 1
        SET reply->row[x].links[lnk_idx].row[idx].separator_value = "== UNABLE TO LOAD ALL RADS =="
        SET y = temp->el[x].rad_cnt
       ELSE
        SET idx = (idx+ 1)
        SET reply->row[x].links[lnk_idx].row[idx].separator_ind = 0
        SET reply->row[x].links[lnk_idx].row[idx].separator_value = ""
        SET stat = alterlist(reply->row[x].links[lnk_idx].row[idx].col,4)
        SET reply->row[x].links[lnk_idx].row[idx].col[1].value = temp->el[x].rad[y].rad_name
        SET reply->row[x].links[lnk_idx].row[idx].col[2].value = temp->el[x].rad[y].rad_author
        SET reply->row[x].links[lnk_idx].row[idx].col[3].value = temp->el[x].rad[y].event_end_dt_tm
        SET reply->row[x].links[lnk_idx].row[idx].col[4].value = temp->el[x].rad[y].rad_blob
        SET reply->row[x].links[lnk_idx].row[idx].blob = ""
       ENDIF
      ENDFOR
     ELSEIF ((reply->links[lnk_idx].title="PROG"))
      SET stat = alterlist(reply->row[x].links[lnk_idx].row,value(temp->el[x].pro_cnt))
      SET hold_cnt = temp->el[x].pro_cnt
      SET holddayofweek = 0
      SET idx = 0
      FOR (y = 1 TO temp->el[x].pro_cnt)
       IF ((temp->el[x].pro[y].dayofweek != holddayofweek))
        SET holddayofweek = temp->el[x].pro[y].dayofweek
        SET hold_cnt = (hold_cnt+ 1)
        SET idx = (idx+ 1)
        SET stat = alterlist(reply->row[x].links[lnk_idx].row,hold_cnt)
        SET reply->row[x].links[lnk_idx].row[idx].separator_ind = 1
        SET reply->row[x].links[lnk_idx].row[idx].separator_value = concat("--- Notes for ",temp->el[
         x].pro[y].event_end_dt_tm," ---")
       ENDIF
       IF (idx >= 255)
        SET idx = 256
        SET stat = alterlist(reply->row[x].links[lnk_idx].row,256)
        SET reply->row[x].links[lnk_idx].row[idx].separator_ind = 1
        SET reply->row[x].links[lnk_idx].row[idx].separator_value = "== UNABLE TO LOAD ALL NOTES =="
        SET y = temp->el[x].pro_cnt
       ELSE
        SET idx = (idx+ 1)
        SET reply->row[x].links[lnk_idx].row[idx].separator_ind = 0
        SET reply->row[x].links[lnk_idx].row[idx].separator_value = ""
        SET stat = alterlist(reply->row[x].links[lnk_idx].row[idx].col,4)
        SET reply->row[x].links[lnk_idx].row[idx].col[1].value = temp->el[x].pro[y].pro_name
        SET reply->row[x].links[lnk_idx].row[idx].col[2].value = temp->el[x].pro[y].pro_author
        SET reply->row[x].links[lnk_idx].row[idx].col[3].value = temp->el[x].pro[y].event_end_dt_tm
        SET reply->row[x].links[lnk_idx].row[idx].col[4].value = temp->el[x].pro[y].pro_blob
        SET reply->row[x].links[lnk_idx].row[idx].blob = ""
       ENDIF
      ENDFOR
     ELSEIF ((reply->links[lnk_idx].title="DOCS"))
      SET stat = alterlist(reply->row[x].links[lnk_idx].row,value(temp->el[x].doc_cnt))
      SET hold_cnt = temp->el[x].doc_cnt
      SET holddayofweek = 0
      SET idx = 0
      FOR (y = 1 TO temp->el[x].doc_cnt)
       IF ((temp->el[x].doc[y].dayofweek != holddayofweek))
        SET holddayofweek = temp->el[x].doc[y].dayofweek
        SET hold_cnt = (hold_cnt+ 1)
        SET idx = (idx+ 1)
        SET stat = alterlist(reply->row[x].links[lnk_idx].row,hold_cnt)
        SET reply->row[x].links[lnk_idx].row[idx].separator_ind = 1
        SET reply->row[x].links[lnk_idx].row[idx].separator_value = concat("--- Documents for ",temp
         ->el[x].doc[y].event_end_dt_tm," ---")
       ENDIF
       IF (idx >= 255)
        SET idx = 256
        SET stat = alterlist(reply->row[x].links[lnk_idx].row,256)
        SET reply->row[x].links[lnk_idx].row[idx].separator_ind = 1
        SET reply->row[x].links[lnk_idx].row[idx].separator_value = "== UNABLE TO LOAD ALL DOCS =="
        SET y = temp->el[x].doc_cnt
       ELSE
        SET idx = (idx+ 1)
        SET reply->row[x].links[lnk_idx].row[idx].separator_ind = 0
        SET reply->row[x].links[lnk_idx].row[idx].separator_value = ""
        SET stat = alterlist(reply->row[x].links[lnk_idx].row[idx].col,4)
        SET reply->row[x].links[lnk_idx].row[idx].col[1].value = temp->el[x].doc[y].doc_name
        SET reply->row[x].links[lnk_idx].row[idx].col[2].value = temp->el[x].doc[y].doc_author
        SET reply->row[x].links[lnk_idx].row[idx].col[3].value = temp->el[x].doc[y].event_end_dt_tm
        SET reply->row[x].links[lnk_idx].row[idx].col[4].value = temp->el[x].doc[y].doc_blob
        SET reply->row[x].links[lnk_idx].row[idx].blob = ""
       ENDIF
      ENDFOR
     ELSEIF ((reply->links[lnk_idx].title="PEND"))
      SET stat = alterlist(reply->row[x].links[lnk_idx].row,value(temp->el[x].po_cnt))
      FOR (y = 1 TO temp->el[x].po_cnt)
        IF (y=256)
         SET reply->row[x].links[lnk_idx].row[y].separator_ind = 0
         SET reply->row[x].links[lnk_idx].row[y].separator_value = "== UNABLE TO LOAD ALL ORDERS =="
         SET y = temp->el[x].po_cnt
        ELSE
         SET reply->row[x].links[lnk_idx].row[y].separator_ind = 0
         SET reply->row[x].links[lnk_idx].row[y].separator_value = ""
         SET stat = alterlist(reply->row[x].links[lnk_idx].row[y].col,2)
         SET reply->row[x].links[lnk_idx].row[y].col[1].value = temp->el[x].po[y].po_mnemonic
         SET reply->row[x].links[lnk_idx].row[y].col[2].value = temp->el[x].po[y].po_disp_line
         SET reply->row[x].links[lnk_idx].row[y].blob = ""
        ENDIF
      ENDFOR
     ELSEIF ((reply->links[lnk_idx].title="ACTO"))
      SET stat = alterlist(reply->row[x].links[lnk_idx].row,value(temp->el[x].ao_cnt))
      FOR (y = 1 TO temp->el[x].ao_cnt)
        IF (y=256)
         SET reply->row[x].links[lnk_idx].row[y].separator_ind = 0
         SET reply->row[x].links[lnk_idx].row[y].separator_value = "== UNABLE TO LOAD ALL ORDERS =="
         SET y = temp->el[x].ao_cnt
        ELSE
         SET reply->row[x].links[lnk_idx].row[y].separator_ind = 0
         SET reply->row[x].links[lnk_idx].row[y].separator_value = ""
         SET stat = alterlist(reply->row[x].links[lnk_idx].row[y].col,2)
         SET reply->row[x].links[lnk_idx].row[y].col[1].value = temp->el[x].ao[y].ao_mnemonic
         SET reply->row[x].links[lnk_idx].row[y].col[2].value = temp->el[x].ao[y].ao_disp_line
         SET reply->row[x].links[lnk_idx].row[y].blob = ""
        ENDIF
      ENDFOR
     ELSEIF ((reply->links[lnk_idx].title="VITA"))
      SET stat = alterlist(reply->row[x].links[lnk_idx].row,6)
      FOR (y = 1 TO 6)
        SET stat = alterlist(reply->row[x].links[lnk_idx].row[y].col,11)
      ENDFOR
      SET reply->row[x].links[lnk_idx].row[1].separator_ind = 0
      SET reply->row[x].links[lnk_idx].row[1].separator_value = ""
      SET reply->row[x].links[lnk_idx].row[1].col[1].value = "HT"
      SET reply->row[x].links[lnk_idx].row[1].col[2].value = temp->el[x].ht
      SET reply->row[x].links[lnk_idx].row[1].col[3].value = temp->el[x].ht_dt_tm
      SET reply->row[x].links[lnk_idx].row[2].separator_ind = 0
      SET reply->row[x].links[lnk_idx].row[2].separator_value = ""
      SET reply->row[x].links[lnk_idx].row[2].col[1].value = "WT"
      SET reply->row[x].links[lnk_idx].row[2].col[2].value = temp->el[x].wt
      SET reply->row[x].links[lnk_idx].row[2].col[3].value = temp->el[x].wt_dt_tm
      SET reply->row[x].links[lnk_idx].row[3].separator_ind = 0
      SET reply->row[x].links[lnk_idx].row[3].separator_value = ""
      SET reply->row[x].links[lnk_idx].row[3].blob = ""
      SET reply->row[x].links[lnk_idx].row[3].col[1].value = "T"
      SET z = 1
      FOR (y = 1 TO temp->el[x].vs_cnt)
        SET z = (z+ 1)
        SET reply->row[x].links[lnk_idx].row[3].col[z].value = temp->el[x].vs[y].temp
        SET z = (z+ 1)
        SET reply->row[x].links[lnk_idx].row[3].col[z].value = temp->el[x].vs[y].vs_dt_tm
      ENDFOR
      SET reply->row[x].links[lnk_idx].row[4].separator_ind = 0
      SET reply->row[x].links[lnk_idx].row[4].separator_value = ""
      SET reply->row[x].links[lnk_idx].row[4].blob = ""
      SET reply->row[x].links[lnk_idx].row[4].col[1].value = "P"
      SET z = 1
      FOR (y = 1 TO temp->el[x].vs_cnt)
        SET z = (z+ 1)
        SET reply->row[x].links[lnk_idx].row[4].col[z].value = temp->el[x].vs[y].pulse
        SET z = (z+ 1)
        SET reply->row[x].links[lnk_idx].row[4].col[z].value = temp->el[x].vs[y].vs_dt_tm
      ENDFOR
      SET reply->row[x].links[lnk_idx].row[5].separator_ind = 0
      SET reply->row[x].links[lnk_idx].row[5].separator_value = ""
      SET reply->row[x].links[lnk_idx].row[5].blob = ""
      SET reply->row[x].links[lnk_idx].row[5].col[1].value = "R"
      SET z = 1
      FOR (y = 1 TO temp->el[x].vs_cnt)
        SET z = (z+ 1)
        SET reply->row[x].links[lnk_idx].row[5].col[z].value = temp->el[x].vs[y].resp
        SET z = (z+ 1)
        SET reply->row[x].links[lnk_idx].row[5].col[z].value = temp->el[x].vs[y].vs_dt_tm
      ENDFOR
      SET reply->row[x].links[lnk_idx].row[6].separator_ind = 0
      SET reply->row[x].links[lnk_idx].row[6].separator_value = ""
      SET reply->row[x].links[lnk_idx].row[6].blob = ""
      SET reply->row[x].links[lnk_idx].row[6].col[1].value = "BP"
      SET z = 1
      FOR (y = 1 TO temp->el[x].vs_cnt)
        SET z = (z+ 1)
        SET reply->row[x].links[lnk_idx].row[6].col[z].value = temp->el[x].vs[y].bp
        SET z = (z+ 1)
        SET reply->row[x].links[lnk_idx].row[6].col[z].value = temp->el[x].vs[y].vs_dt_tm
      ENDFOR
     ENDIF
   ENDFOR
 ENDFOR
#update_ppa
 IF (ppa_type_cd=0)
  GO TO exit_script
 ENDIF
 SET same_date = cnvtdatetime(curdate,curtime3)
 FOR (x = 1 TO temp->ecnt)
   SET next_code = 0.0
   SET site_id = (cnvtreal(logical("SITE_ID")) * 0.1)
   SELECT INTO "nl:"
    nextseqnum = seq(person_prsnl_activity_seq,nextval)"#################;rp0"
    FROM dual
    DETAIL
     next_code = (cnvtreal(nextseqnum)+ site_id)
    WITH format
   ;end select
   IF (curqual <= 0)
    GO TO exit_script
   ENDIF
   INSERT  FROM person_prsnl_activity ppa
    SET ppa.ppa_id = next_code, ppa.person_id = temp->el[x].person_id, ppa.prsnl_id = request->prsnl[
     1].prsnl_id,
     ppa.ppa_type_cd = ppa_type_cd, ppa.ppa_first_dt_tm = cnvtdatetime(same_date), ppa.ppa_last_dt_tm
      = cnvtdatetime(same_date),
     ppa.ppr_cd = temp->el[x].myreltn_cd, ppa.view_caption = reply->title, ppa.active_status_cd = 0,
     ppa.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ppa.active_status_prsnl_id = reqinfo->
     updt_id, ppa.active_ind = 1,
     updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_cnt = 0, updt_id = reqinfo->updt_id,
     updt_applctx = reqinfo->updt_applctx, updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
 ENDFOR
 SET reqinfo->commit_ind = 1
#exit_script
END GO
