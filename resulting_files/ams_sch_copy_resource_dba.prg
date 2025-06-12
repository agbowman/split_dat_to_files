CREATE PROGRAM ams_sch_copy_resource:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select the Scheduling Resource to copy from" = 0,
  "Enter the mnemonic of the resource to be created" = "",
  "Search personnel for personnel resource, or skip to create general resource" = "",
  "Select the personnel" = 0
  WITH outdev, from_res_cd, to_res_mnemonic,
  search_string, person_id
 EXECUTE ams_define_toolkit_common
 DECLARE tracking_name = vc
 DECLARE temp_string = vc
 DECLARE flag = vc
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "S"
 IF ( NOT (validate(t_record,0)))
  RECORD t_record(
    1 from_resource_cd = f8
    1 from_resource_mnemonic = vc
    1 from_person_id = f8
    1 from_name_full_formatted = vc
    1 from_position_cd = f8
    1 from_position_disp = vc
    1 resource_cd = f8
    1 mnemonic = vc
    1 res_type_flag = i2
    1 person_id = f8
    1 name_full_formatted = vc
    1 quota = i4
    1 position_cd = f8
    1 position_disp = vc
    1 book_qual_cnt = i4
    1 book_qual[*]
      2 appt_book_id = f8
      2 mnemonic = vc
      2 child_appt_book_id = f8
      2 seq_nbr = i2
    1 book_reply_cnt = i4
    1 res_list_qual_cnt = i4
    1 res_list_qual[*]
      2 mnemonic = vc
      2 res_group_id = f8
      2 seq_nbr = i4
      2 child_res_group_id = f8
    1 res_list_reply_cnt = i4
    1 res_role_qual_cnt = i4
    1 res_role_qual[*]
      2 sch_role_cd = f8
      2 mnemonic = vc
      2 role_meaning = c30
    1 res_role_reply_cnt = i4
    1 list_res_qual_cnt = i4
    1 list_res_qual[*]
      2 list_role_id = f8
      2 resource_cd = f8
      2 res_list_id = f8
      2 res_list_mnemonic = vc
      2 list_role_description = vc
      2 pref_ind = i2
      2 display_seq = i4
      2 res_sch_cd = f8
      2 res_sch_meaning = c12
      2 search_seq = i4
      2 selected_ind = i2
      2 sch_flex_id = f8
      2 list_slot_qual_cnt = i4
      2 list_slot_qual[*]
        3 slot_type_id = f8
        3 setup_units = i4
        3 setup_units = i4
        3 setup_units_cd = f8
        3 setup_units_meaning = c12
        3 setup_role_id = f8
        3 duration_role_id = f8
        3 duration_units = i4
        3 duration_units_cd = f8
        3 duration_units_meaning = c12
        3 cleanup_units = i4
        3 cleanup_units_cd = f8
        3 cleanup_units_meaning = c12
        3 cleanup_role_id = f8
        3 offset_type_cd = f8
        3 offset_type_meaning = c12
        3 offset_role_id = f8
        3 offset_beg_units = i4
        3 offset_beg_units_cd = f8
        3 offset_beg_units_meaning = c12
        3 offset_end_units = i4
        3 offset_end_units_cd = f8
        3 offset_end_units_meaning = c12
        3 display_seq = i4
        3 search_seq = i4
        3 selected_ind = i2
        3 sch_flex_id = f8
    1 list_slot_reply_cnt = i4
    1 list_res_reply_cnt = i4
    1 sec_qual_cnt = i4
    1 sec_total = i4
    1 sec_qual[*]
      2 sec_type_cd = f8
      2 sec_type_display = vc
      2 sec_type_meaning = vc
      2 security_qual_cnt = i4
      2 security_qual[*]
        3 parent1_table = vc
        3 parent1_id = f8
        3 parent1_meaning = c12
        3 display1_table = vc
        3 display1_id = f8
        3 display1_meaning = c12
        3 mnemonic1 = c100
        3 data1_source_cd = f8
        3 data1_source_meaning = c12
        3 parent2_table = vc
        3 parent2_id = f8
        3 parent2_meaning = c12
        3 display2_table = vc
        3 display2_id = f8
        3 display2_meaning = c12
        3 mnemonic2 = c100
        3 data2_source_cd = f8
        3 data2_source_meaning = c12
        3 parent3_table = vc
        3 parent3_id = f8
        3 parent3_meaning = c12
        3 display3_table = vc
        3 display3_id = f8
        3 display3_meaning = c12
        3 mnemonic3 = c100
        3 data3_source_cd = f8
        3 data3_source_meaning = c12
        3 lock_table = vc
        3 lock_id = f8
        3 lock_meaning = c12
        3 lock_mnemonic = vc
    1 sec_reply_cnt = i4
    1 assoc_qual_cnt = i4
    1 assoc_qual[*]
      2 parent_table = c32
      2 parent_id = f8
      2 parent_mnemonic = vc
      2 parent_meaning = c12
      2 child_table = c32
      2 child_id = f8
      2 child_meaning = c12
      2 seq_nbr = i4
      2 assoc_type_cd = f8
      2 assoc_type_meaning = c12
      2 data_source_cd = f8
      2 data_source_meaning = c12
      2 active_ind = i2
      2 display_table = c32
      2 display_id = f8
      2 display_meaning = c12
    1 assoc_reply_cnt = i4
    1 position_assoc_qual_cnt = i4
    1 position_assoc_qual[*]
      2 parent_mnemonic = vc
  )
 ENDIF
 IF ( NOT (validate(add_list_slot_request,0)))
  RECORD add_list_slot_request(
    1 call_echo_ind = i2
    1 qual[*]
      2 list_role_id = f8
      2 resource_cd = f8
      2 slot_type_id = f8
      2 setup_units = i4
      2 setup_units_cd = f8
      2 setup_units_meaning = c12
      2 setup_role_id = f8
      2 duration_role_id = f8
      2 duration_units = i4
      2 duration_units_cd = f8
      2 duration_units_meaning = c12
      2 cleanup_units = i4
      2 cleanup_units_cd = f8
      2 cleanup_units_meaning = c12
      2 cleanup_role_id = f8
      2 offset_type_cd = f8
      2 offset_type_meaning = c12
      2 offset_role_id = f8
      2 offset_beg_units = i4
      2 offset_beg_units_cd = f8
      2 offset_beg_units_meaning = c12
      2 offset_end_units = i4
      2 offset_end_units_cd = f8
      2 offset_end_units_meaning = c12
      2 display_seq = i4
      2 search_seq = i4
      2 candidate_id = f8
      2 active_ind = i2
      2 active_status_cd = f8
      2 selected_ind = i2
      2 sch_flex_id = f8
      2 allow_partial_ind = i2
  )
 ENDIF
 IF ( NOT (validate(add_list_slot_reply,0)))
  RECORD add_list_slot_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 candidate_id = f8
      2 status = i4
  )
 ENDIF
 FREE RECORD get_sec_request
 RECORD get_sec_request(
   1 call_echo_ind = i2
   1 all_sec_ind = i2
   1 qual[*]
     2 sec_type_cd = f8
     2 sec_type_meaning = c12
     2 parent1[*]
       3 parent1_id = f8
 )
 FREE RECORD get_sec_reply
 RECORD get_sec_reply(
   1 qual_cnt = i4
   1 qual[*]
     2 sec_type_cd = f8
     2 sec_type_meaning = vc
     2 security_qual_cnt = i4
     2 security_qual[*]
       3 security_id = f8
       3 parent1_table = vc
       3 parent1_id = f8
       3 parent1_meaning = c12
       3 display1_table = vc
       3 display1_id = f8
       3 display1_meaning = c12
       3 mnemonic1 = c100
       3 data1_source_cd = f8
       3 data1_source_meaning = c12
       3 parent2_table = vc
       3 parent2_id = f8
       3 parent2_meaning = c12
       3 display2_table = vc
       3 display2_id = f8
       3 display2_meaning = c12
       3 mnemonic2 = c100
       3 data2_source_cd = f8
       3 data2_source_meaning = c12
       3 parent3_table = vc
       3 parent3_id = f8
       3 parent3_meaning = c12
       3 display3_table = vc
       3 display3_id = f8
       3 display3_meaning = c12
       3 mnemonic3 = c100
       3 data3_source_cd = f8
       3 data3_source_meaning = c12
       3 lock_table = vc
       3 lock_id = f8
       3 lock_meaning = c12
       3 lock_mnemonic = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(add_book_list_request,0)))
  RECORD add_book_list_request(
    1 call_echo_ind = i2
    1 qual[*]
      2 appt_book_id = f8
      2 seq_nbr = i4
      2 resource_cd = f8
      2 child_appt_book_id = f8
      2 candidate_id = f8
      2 active_ind = i2
      2 active_status_cd = f8
      2 allow_partial_ind = i2
  )
 ENDIF
 IF ( NOT (validate(add_book_list_reply,0)))
  RECORD add_book_list_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 candidate_id = f8
      2 status = i4
  )
 ENDIF
 IF ( NOT (validate(add_res_list_request,0)))
  RECORD add_res_list_request(
    1 call_echo_ind = i2
    1 qual[*]
      2 res_group_id = f8
      2 seq_nbr = i4
      2 resource_cd = f8
      2 child_res_group_id = f8
      2 candidate_id = f8
      2 active_ind = i2
      2 active_status_cd = f8
      2 allow_partial_ind = i2
  )
 ENDIF
 IF ( NOT (validate(add_res_list_reply,0)))
  RECORD add_res_list_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 candidate_id = f8
      2 status = i4
  )
 ENDIF
 IF ( NOT (validate(add_res_role_request,0)))
  RECORD add_res_role_request(
    1 call_echo_ind = i2
    1 qual[*]
      2 resource_cd = f8
      2 sch_role_cd = f8
      2 role_meaning = c12
      2 candidate_id = f8
      2 active_ind = i2
      2 active_status_cd = f8
      2 allow_partial_ind = i2
  )
 ENDIF
 IF ( NOT (validate(add_res_role_reply,0)))
  RECORD add_res_role_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 candidate_id = f8
      2 status = i4
  )
 ENDIF
 IF ( NOT (validate(add_list_res_request,0)))
  RECORD add_list_res_request(
    1 call_echo_ind = i2
    1 qual[*]
      2 list_role_id = f8
      2 resource_cd = f8
      2 pref_ind = i2
      2 search_seq = i4
      2 display_seq = i4
      2 candidate_id = f8
      2 active_ind = i2
      2 active_status_cd = f8
      2 res_sch_cd = f8
      2 res_sch_meaning = c12
      2 selected_ind = i2
      2 sch_flex_id = f8
      2 allow_partial_ind = i2
  )
 ENDIF
 IF ( NOT (validate(add_list_res_reply,0)))
  RECORD add_list_res_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 candidate_id = f8
      2 status = i4
  )
 ENDIF
 IF ( NOT (validate(chgw_security_request,0)))
  RECORD chgw_security_request(
    1 call_echo_ind = i2
    1 allow_partial_ind = i2
    1 qual[*]
      2 security_id = f8
      2 version_dt_tm = di8
      2 sec_type_cd = f8
      2 sec_type_meaning = c12
      2 parent1_table = c32
      2 parent1_id = f8
      2 parent1_meaning = c12
      2 display1_table = c32
      2 display1_id = f8
      2 display1_meaning = c12
      2 data1_source_cd = f8
      2 data1_source_meaning = c12
      2 parent2_table = c32
      2 parent2_id = f8
      2 parent2_meaning = c12
      2 display2_table = c32
      2 display2_id = f8
      2 display2_meaning = c12
      2 data2_source_cd = f8
      2 data2_source_meaning = c12
      2 parent3_table = c32
      2 parent3_id = f8
      2 parent3_meaning = c12
      2 display3_table = c32
      2 display3_id = f8
      2 display3_meaning = c12
      2 data3_source_cd = f8
      2 data3_source_meaning = c12
      2 lock_table = c32
      2 lock_id = f8
      2 lock_meaning = c12
      2 updt_cnt = i4
      2 action = i2
      2 force_updt_ind = i2
      2 version_ind = i2
      2 active_status_cd = f8
      2 active_ind = i2
      2 candidate_id = f8
  )
 ENDIF
 IF ( NOT (validate(chgw_security_reply,0)))
  RECORD chgw_security_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 status = i2
      2 security_id = f8
  )
 ENDIF
 IF ( NOT (validate(add_assoc_request,0)))
  RECORD add_assoc_request(
    1 call_echo_ind = i2
    1 qual[*]
      2 association_id = f8
      2 parent_table = c32
      2 parent_id = f8
      2 parent_meaning = c12
      2 child_table = c32
      2 child_id = f8
      2 child_meaning = c12
      2 seq_nbr = i4
      2 assoc_type_cd = f8
      2 assoc_type_meaning = c12
      2 data_source_cd = f8
      2 data_source_meaning = c12
      2 active_ind = i2
      2 active_status_cd = f8
      2 candidate_id = f8
      2 display_table = c32
      2 display_id = f8
      2 display_meaning = c12
      2 allow_partial_ind = i2
  )
 ENDIF
 IF ( NOT (validate(add_assoc_reply,0)))
  RECORD add_assoc_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 association_id = f8
      2 candidate_id = f8
      2 status = i4
  )
 ENDIF
 SET t_record->from_resource_cd = cnvtreal( $FROM_RES_CD)
 SET t_record->mnemonic =  $TO_RES_MNEMONIC
 SET t_record->person_id = cnvtreal( $PERSON_ID)
 IF ((t_record->from_resource_cd <= 0))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "No valid resource selected."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  res.mnemonic_key
  FROM sch_resource res
  WHERE res.mnemonic_key=trim(cnvtupper( $TO_RES_MNEMONIC))
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "The mnemonic entered exists in the database"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  a.resource_cd
  FROM sch_resource a,
   prsnl p
  PLAN (a
   WHERE (a.resource_cd=t_record->from_resource_cd))
   JOIN (p
   WHERE p.person_id=a.person_id)
  DETAIL
   t_record->res_type_flag = a.res_type_flag, t_record->from_resource_mnemonic = a.mnemonic, t_record
   ->from_person_id = a.person_id,
   t_record->quota = a.quota, t_record->from_name_full_formatted = p.name_full_formatted, t_record->
   from_position_cd = p.position_cd
   IF (p.position_cd > 0)
    t_record->from_position_disp = uar_get_code_display(p.position_cd)
   ELSE
    t_record->from_position_disp = ""
   ENDIF
  WITH nocounter
 ;end select
 IF ((t_record->res_type_flag=1))
  IF ((t_record->person_id != 0.0))
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "A personnel is selected for a general resource"
   GO TO exit_script
  ENDIF
 ELSEIF ((t_record->res_type_flag=2))
  IF ((t_record->person_id=0.0))
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Personnel must be selected when copying from a personnel resource"
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((t_record->person_id > 0.0))
  SELECT INTO "nl:"
   res.person_id
   FROM sch_resource res
   WHERE (person_id=t_record->person_id)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "The selected personnel is associated with an existing resource"
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((t_record->person_id > 0))
  SELECT INTO "nl:"
   p.name_full_formatted
   FROM prsnl p
   PLAN (p
    WHERE (p.person_id=t_record->person_id))
   DETAIL
    t_record->name_full_formatted = p.name_full_formatted, t_record->position_cd = p.position_cd,
    t_record->position_disp = uar_get_code_display(p.position_cd)
   WITH nocounter
  ;end select
 ENDIF
 IF ( NOT (validate(addw_resource_request,0)))
  RECORD addw_resource_request(
    1 call_echo_ind = i2
    1 allow_partial_ind = i2
    1 qual[*]
      2 res_type_flag = i2
      2 mnemonic = vc
      2 description = vc
      2 info_sch_text_id = f8
      2 person_id = f8
      2 service_resource_cd = f8
      2 candidate_id = f8
      2 active_ind = i2
      2 active_status_cd = f8
      2 item_id = f8
      2 item_location_cd = f8
      2 info_sch_text = vc
      2 quota = i4
      2 loc_partial_ind = i2
      2 loc[*]
        3 location_cd = f8
        3 candidate_id = f8
        3 active_ind = i2
        3 active_status_cd = f8
      2 date_link_r_partial_ind = i2
      2 date_link_r[*]
        3 sch_date_link_r_id = f8
        3 sch_date_set_id = f8
        3 date_set_seq_nbr = i4
        3 active_ind = i2
      2 organization_qual_cnt = i4
      2 organization[*]
        3 organization_id = f8
        3 action = i2
  )
 ENDIF
 IF ( NOT (validate(addw_resource_reply,0)))
  RECORD addw_resource_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 candidate_id = f8
      2 status = i2
      2 info_sch_text_id = f8
      2 resource_cd = f8
      2 loc_qual_cnt = i4
      2 loc[*]
        3 candidate_id = f8
        3 status = i2
      2 date_link_r_qual_cnt = i4
      2 date_link_r[*]
        3 sch_date_link_r_id = f8
        3 status = i2
      2 organization_qual_cnt = i4
      2 organization[*]
        3 organization_id = f8
        3 status = i2
  )
 ENDIF
 SET addw_resource_request->call_echo_ind = 1
 SET addw_resource_request->allow_partial_ind = 0
 SET stat = alterlist(addw_resource_request->qual,1)
 SET addw_resource_request->qual[1].mnemonic = t_record->mnemonic
 SET addw_resource_request->qual[1].description = t_record->mnemonic
 SET addw_resource_request->qual[1].quota = t_record->quota
 SET addw_resource_request->qual[1].info_sch_text_id = 0.000000
 SET addw_resource_request->qual[1].res_type_flag = t_record->res_type_flag
 SET addw_resource_request->qual[1].person_id = t_record->person_id
 SET addw_resource_request->qual[1].service_resource_cd = 0.000000
 SET addw_resource_request->qual[1].candidate_id = 0.000000
 SET addw_resource_request->qual[1].active_ind = 1
 SET addw_resource_request->qual[1].active_status_cd = 0.000000
 SET addw_resource_request->qual[1].item_id = 0.000000
 SET addw_resource_request->qual[1].item_location_cd = 0.000000
 SET addw_resource_request->qual[1].info_sch_text = ""
 SET addw_resource_request->qual[1].loc_partial_ind = 0
 SET stat = alterlist(addw_resource_request->qual[1].loc,0)
 SET addw_resource_request->qual[1].date_link_r_partial_ind = 0
 SET stat = alterlist(addw_resource_request->qual[1].date_link_r,0)
 EXECUTE sch_addw_resource
 SET tracking_name = "AMS_SCH_COPY_RESOURCE|RESOURCE"
 CALL updtdminfo(tracking_name)
 IF ((addw_resource_reply->qual[1].status != true))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Fail to add the new resource to the database"
  GO TO exit_script
 ENDIF
 SET t_record->resource_cd = addw_resource_reply->qual[1].resource_cd
 SET t_record->book_qual_cnt = 0
 SELECT INTO "nl:"
  a.appt_book_id
  FROM sch_book_list a,
   sch_appt_book b
  PLAN (a
   WHERE (a.resource_cd=t_record->from_resource_cd)
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (b
   WHERE b.appt_book_id=a.appt_book_id
    AND b.active_ind=1)
  DETAIL
   t_record->book_qual_cnt = (t_record->book_qual_cnt+ 1)
   IF (mod(t_record->book_qual_cnt,10)=1)
    stat = alterlist(t_record->book_qual,(t_record->book_qual_cnt+ 9))
   ENDIF
   t_record->book_qual[t_record->book_qual_cnt].appt_book_id = a.appt_book_id, t_record->book_qual[
   t_record->book_qual_cnt].mnemonic = b.mnemonic, t_record->book_qual[t_record->book_qual_cnt].
   child_appt_book_id = a.child_appt_book_id
  WITH nocounter
 ;end select
 SET stat = alterlist(t_record->book_qual,t_record->book_qual_cnt)
 SELECT INTO "nl:"
  max_nbr = max(a.seq_nbr)
  FROM (dummyt d  WITH seq = value(t_record->book_qual_cnt)),
   sch_book_list a
  PLAN (d
   WHERE (t_record->book_qual[d.seq].appt_book_id > 0))
   JOIN (a
   WHERE (a.appt_book_id=t_record->book_qual[d.seq].appt_book_id))
  DETAIL
   t_record->book_qual[d.seq].seq_nbr = (max_nbr+ 1)
  WITH nocounter
 ;end select
 SET t_record->res_list_qual_cnt = 0
 SELECT INTO "nl:"
  a.res_group_id
  FROM sch_res_list a,
   sch_res_group b
  PLAN (a
   WHERE (a.resource_cd=t_record->from_resource_cd)
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (b
   WHERE b.res_group_id=a.res_group_id
    AND b.active_ind=1)
  DETAIL
   t_record->res_list_qual_cnt = (t_record->res_list_qual_cnt+ 1)
   IF (mod(t_record->res_list_qual_cnt,10)=1)
    stat = alterlist(t_record->res_list_qual,(t_record->res_list_qual_cnt+ 9))
   ENDIF
   t_record->res_list_qual[t_record->res_list_qual_cnt].res_group_id = a.res_group_id, t_record->
   res_list_qual[t_record->res_list_qual_cnt].mnemonic = b.mnemonic, t_record->res_list_qual[t_record
   ->res_list_qual_cnt].child_res_group_id = a.child_res_group_id
  WITH nocounter
 ;end select
 SET stat = alterlist(t_record->res_list_qual,t_record->res_list_qual_cnt)
 SELECT INTO "nl:"
  max_nbr = max(a.seq_nbr)
  FROM (dummyt d  WITH seq = value(t_record->res_list_qual_cnt)),
   sch_res_list a
  PLAN (d
   WHERE (t_record->res_list_qual[d.seq].res_group_id > 0))
   JOIN (a
   WHERE (a.res_group_id=t_record->res_list_qual[d.seq].res_group_id))
  DETAIL
   t_record->res_list_qual[d.seq].seq_nbr = (max_nbr+ 1)
  WITH nocounter
 ;end select
 SET t_record->res_role_qual_cnt = 0
 SELECT INTO "nl:"
  a.sch_role_cd, a.role_meaning
  FROM sch_res_role a,
   sch_role r
  PLAN (a
   WHERE (a.resource_cd=t_record->from_resource_cd)
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (r
   WHERE r.sch_role_cd=a.sch_role_cd
    AND r.active_ind=1)
  DETAIL
   t_record->res_role_qual_cnt = (t_record->res_role_qual_cnt+ 1)
   IF (mod(t_record->res_role_qual_cnt,10)=1)
    stat = alterlist(t_record->res_role_qual,(t_record->res_role_qual_cnt+ 9))
   ENDIF
   t_record->res_role_qual[t_record->res_role_qual_cnt].sch_role_cd = a.sch_role_cd, t_record->
   res_role_qual[t_record->res_role_qual_cnt].mnemonic = r.mnemonic, t_record->res_role_qual[t_record
   ->res_role_qual_cnt].role_meaning = a.role_meaning
  WITH nocounter
 ;end select
 SET stat = alterlist(t_record->res_role_qual,t_record->res_role_qual_cnt)
 SET count1 = 0
 SET count2 = 0
 SET t_record->list_res_qual_cnt = 0
 SELECT INTO "nl:"
  res.resource_cd, res.list_role_id, slot.slot_type_id
  FROM sch_list_res res,
   sch_list_slot slot,
   sch_list_role lr,
   sch_resource_list rl
  PLAN (res
   WHERE (res.resource_cd=t_record->from_resource_cd)
    AND res.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (slot
   WHERE slot.list_role_id=res.list_role_id
    AND slot.resource_cd=res.resource_cd
    AND slot.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (lr
   WHERE lr.list_role_id=res.list_role_id
    AND lr.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (rl
   WHERE rl.res_list_id=lr.res_list_id
    AND rl.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  ORDER BY res.list_role_id
  HEAD res.list_role_id
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(t_record->list_res_qual,(count1+ 9))
   ENDIF
   count2 = 0, t_record->list_res_qual[count1].list_role_id = res.list_role_id, t_record->
   list_res_qual[count1].resource_cd = t_record->resource_cd,
   t_record->list_res_qual[count1].res_list_mnemonic = rl.mnemonic, t_record->list_res_qual[count1].
   res_list_id = rl.res_list_id, t_record->list_res_qual[count1].list_role_description = lr
   .description,
   t_record->list_res_qual[count1].pref_ind = res.pref_ind, t_record->list_res_qual[count1].
   search_seq = res.search_seq, t_record->list_res_qual[count1].selected_ind = res.selected_ind,
   t_record->list_res_qual[count1].res_sch_cd = res.res_sch_cd, t_record->list_res_qual[count1].
   res_sch_meaning = res.res_sch_meaning, t_record->list_res_qual[count1].sch_flex_id = 0.0,
   t_record->list_res_qual[count1].list_slot_qual_cnt = 0
  DETAIL
   count2 = (count2+ 1)
   IF (mod(count2,10)=1)
    stat = alterlist(t_record->list_res_qual[count1].list_slot_qual,(count2+ 9))
   ENDIF
   t_record->list_res_qual[count1].list_slot_qual[count2].slot_type_id = slot.slot_type_id, t_record
   ->list_res_qual[count1].list_slot_qual[count2].sch_flex_id = 0.0, t_record->list_res_qual[count1].
   list_slot_qual[count2].setup_units = slot.setup_units,
   t_record->list_res_qual[count1].list_slot_qual[count2].setup_units_cd = slot.setup_units_cd,
   t_record->list_res_qual[count1].list_slot_qual[count2].setup_units_meaning = slot
   .setup_units_meaning, t_record->list_res_qual[count1].list_slot_qual[count2].setup_role_id = slot
   .setup_role_id,
   t_record->list_res_qual[count1].list_slot_qual[count2].duration_role_id = slot.duration_role_id,
   t_record->list_res_qual[count1].list_slot_qual[count2].duration_units = slot.duration_units,
   t_record->list_res_qual[count1].list_slot_qual[count2].duration_units_cd = slot.duration_units_cd,
   t_record->list_res_qual[count1].list_slot_qual[count2].duration_units_meaning = slot
   .duration_units_meaning, t_record->list_res_qual[count1].list_slot_qual[count2].cleanup_units =
   slot.cleanup_units, t_record->list_res_qual[count1].list_slot_qual[count2].cleanup_units_cd = slot
   .cleanup_units_cd,
   t_record->list_res_qual[count1].list_slot_qual[count2].cleanup_units_meaning = slot
   .cleanup_units_meaning, t_record->list_res_qual[count1].list_slot_qual[count2].cleanup_role_id =
   slot.cleanup_role_id, t_record->list_res_qual[count1].list_slot_qual[count2].offset_type_cd = slot
   .offset_type_cd,
   t_record->list_res_qual[count1].list_slot_qual[count2].offset_type_meaning = slot
   .offset_type_meaning, t_record->list_res_qual[count1].list_slot_qual[count2].offset_role_id = slot
   .offset_role_id, t_record->list_res_qual[count1].list_slot_qual[count2].offset_beg_units = slot
   .offset_beg_units,
   t_record->list_res_qual[count1].list_slot_qual[count2].offset_beg_units_cd = slot
   .offset_beg_units_cd, t_record->list_res_qual[count1].list_slot_qual[count2].
   offset_beg_units_meaning = slot.offset_beg_units_meaning, t_record->list_res_qual[count1].
   list_slot_qual[count2].offset_end_units = slot.offset_end_units,
   t_record->list_res_qual[count1].list_slot_qual[count2].offset_end_units_cd = slot
   .offset_end_units_cd, t_record->list_res_qual[count1].list_slot_qual[count2].
   offset_end_units_meaning = slot.offset_end_units_meaning, t_record->list_res_qual[count1].
   list_slot_qual[count2].display_seq = slot.display_seq,
   t_record->list_res_qual[count1].list_slot_qual[count2].search_seq = slot.search_seq, t_record->
   list_res_qual[count1].list_slot_qual[count2].selected_ind = slot.selected_ind
  FOOT  res.list_role_id
   t_record->list_res_qual[count1].list_slot_qual_cnt = count2, stat = alterlist(t_record->
    list_res_qual[count1].list_slot_qual,count2)
  WITH nocounter
 ;end select
 SET t_record->list_res_qual_cnt = count1
 SET stat = alterlist(t_record->list_res_qual,t_record->list_res_qual_cnt)
 SELECT INTO "nl:"
  max_seq = max(a.display_seq)
  FROM (dummyt d  WITH seq = value(t_record->list_res_qual_cnt)),
   sch_list_res a
  PLAN (d
   WHERE (t_record->list_res_qual[d.seq].list_role_id > 0))
   JOIN (a
   WHERE (a.list_role_id=t_record->list_res_qual[d.seq].list_role_id))
  DETAIL
   t_record->list_res_qual[d.seq].display_seq = (max_seq+ 1)
  WITH nocounter
 ;end select
 SET get_sec_request->call_echo_ind = 0
 SET get_sec_request->all_sec_ind = 0
 SET stat = alterlist(get_sec_request->qual,5)
 SET get_sec_request->qual[1].sec_type_cd = 0.0
 SET get_sec_request->qual[1].sec_type_meaning = concat("RESOURCE")
 SET stat = alterlist(get_sec_request->qual[1].parent1,1)
 SET get_sec_request->qual[1].parent1[1].parent1_id = t_record->from_resource_cd
 SET get_sec_request->qual[2].sec_type_cd = 0.0
 SET get_sec_request->qual[2].sec_type_meaning = concat("RESLOC")
 SET stat = alterlist(get_sec_request->qual[2].parent1,1)
 SET get_sec_request->qual[2].parent1[1].parent1_id = t_record->from_resource_cd
 SET get_sec_request->qual[3].sec_type_cd = 0.0
 SET get_sec_request->qual[3].sec_type_meaning = concat("RESCOMM")
 SET stat = alterlist(get_sec_request->qual[3].parent1,1)
 SET get_sec_request->qual[3].parent1[1].parent1_id = t_record->from_resource_cd
 SET get_sec_request->qual[4].sec_type_cd = 0.0
 SET get_sec_request->qual[4].sec_type_meaning = concat("RESWARN")
 SET stat = alterlist(get_sec_request->qual[4].parent1,1)
 SET get_sec_request->qual[4].parent1[1].parent1_id = t_record->from_resource_cd
 SET get_sec_request->qual[5].sec_type_cd = 0.0
 SET get_sec_request->qual[5].sec_type_meaning = concat("RESSLOT")
 SET stat = alterlist(get_sec_request->qual[5].parent1,1)
 SET get_sec_request->qual[5].parent1[1].parent1_id = t_record->from_resource_cd
 EXECUTE sch_get_sec_by_type  WITH replace("REQUEST","GET_SEC_REQUEST"), replace("REPLY",
  "GET_SEC_REPLY")
 SET t_record->sec_total = 0
 IF ((get_sec_reply->status_data.status="S"))
  SET t_record->sec_qual_cnt = get_sec_reply->qual_cnt
  SET stat = alterlist(t_record->sec_qual,t_record->sec_qual_cnt)
  FOR (i = 1 TO get_sec_reply->qual_cnt)
    SET t_record->sec_qual[i].sec_type_cd = get_sec_reply->qual[i].sec_type_cd
    SET t_record->sec_qual[i].sec_type_display = uar_get_code_display(t_record->sec_qual[i].
     sec_type_cd)
    SET t_record->sec_qual[i].sec_type_meaning = get_sec_reply->qual[i].sec_type_meaning
    SET t_record->sec_qual[i].security_qual_cnt = get_sec_reply->qual[i].security_qual_cnt
    IF ((get_sec_reply->qual[i].security_qual_cnt > 0))
     FOR (j = 1 TO get_sec_reply->qual[i].security_qual_cnt)
       SET t_record->sec_total = (t_record->sec_total+ 1)
       SET t_record->sec_qual[i].security_qual_cnt = get_sec_reply->qual[i].security_qual_cnt
       SET stat = alterlist(t_record->sec_qual[i].security_qual,t_record->sec_qual[i].
        security_qual_cnt)
       SET t_record->sec_qual[i].security_qual[j].parent1_table = get_sec_reply->qual[i].
       security_qual[j].parent1_table
       SET t_record->sec_qual[i].security_qual[j].parent1_id = t_record->resource_cd
       SET t_record->sec_qual[i].security_qual[j].parent1_meaning = get_sec_reply->qual[i].
       security_qual[j].parent1_meaning
       SET t_record->sec_qual[i].security_qual[j].display1_table = get_sec_reply->qual[i].
       security_qual[j].display1_table
       SET t_record->sec_qual[i].security_qual[j].display1_id = t_record->resource_cd
       SET t_record->sec_qual[i].security_qual[j].display1_meaning = get_sec_reply->qual[i].
       security_qual[j].display1_meaning
       SET t_record->sec_qual[i].security_qual[j].mnemonic1 = t_record->mnemonic
       SET t_record->sec_qual[i].security_qual[j].data1_source_cd = get_sec_reply->qual[i].
       security_qual[j].data1_source_cd
       SET t_record->sec_qual[i].security_qual[j].data1_source_meaning = get_sec_reply->qual[i].
       security_qual[j].data1_source_meaning
       SET t_record->sec_qual[i].security_qual[j].parent2_table = get_sec_reply->qual[i].
       security_qual[j].parent2_table
       SET t_record->sec_qual[i].security_qual[j].parent2_id = get_sec_reply->qual[i].security_qual[j
       ].parent2_id
       SET t_record->sec_qual[i].security_qual[j].parent2_meaning = get_sec_reply->qual[i].
       security_qual[j].parent2_meaning
       SET t_record->sec_qual[i].security_qual[j].display2_table = get_sec_reply->qual[i].
       security_qual[j].display2_table
       SET t_record->sec_qual[i].security_qual[j].display2_id = get_sec_reply->qual[i].security_qual[
       j].display2_id
       SET t_record->sec_qual[i].security_qual[j].display2_meaning = get_sec_reply->qual[i].
       security_qual[j].display2_meaning
       SET t_record->sec_qual[i].security_qual[j].mnemonic2 = get_sec_reply->qual[i].security_qual[j]
       .mnemonic2
       SET t_record->sec_qual[i].security_qual[j].data2_source_cd = get_sec_reply->qual[i].
       security_qual[j].data2_source_cd
       SET t_record->sec_qual[i].security_qual[j].data2_source_meaning = get_sec_reply->qual[i].
       security_qual[j].data2_source_meaning
       SET t_record->sec_qual[i].security_qual[j].parent3_table = get_sec_reply->qual[i].
       security_qual[j].parent3_table
       SET t_record->sec_qual[i].security_qual[j].parent3_id = get_sec_reply->qual[i].security_qual[j
       ].parent3_id
       SET t_record->sec_qual[i].security_qual[j].parent3_meaning = get_sec_reply->qual[i].
       security_qual[j].parent3_meaning
       SET t_record->sec_qual[i].security_qual[j].display3_table = get_sec_reply->qual[i].
       security_qual[j].display3_table
       SET t_record->sec_qual[i].security_qual[j].display3_id = get_sec_reply->qual[i].security_qual[
       j].display3_id
       SET t_record->sec_qual[i].security_qual[j].display3_meaning = get_sec_reply->qual[i].
       security_qual[j].display3_meaning
       SET t_record->sec_qual[i].security_qual[j].mnemonic3 = get_sec_reply->qual[i].security_qual[j]
       .mnemonic3
       SET t_record->sec_qual[i].security_qual[j].data3_source_cd = get_sec_reply->qual[i].
       security_qual[j].data3_source_cd
       SET t_record->sec_qual[i].security_qual[j].data3_source_meaning = get_sec_reply->qual[i].
       security_qual[j].data3_source_meaning
       SET t_record->sec_qual[i].security_qual[j].lock_table = get_sec_reply->qual[i].security_qual[j
       ].lock_table
       SET t_record->sec_qual[i].security_qual[j].lock_id = get_sec_reply->qual[i].security_qual[j].
       lock_id
       SET t_record->sec_qual[i].security_qual[j].lock_meaning = get_sec_reply->qual[i].
       security_qual[j].lock_meaning
       SET t_record->sec_qual[i].security_qual[j].lock_mnemonic = get_sec_reply->qual[i].
       security_qual[j].lock_mnemonic
       SET t_record->sec_qual[i].security_qual[j].lock_table = get_sec_reply->qual[i].security_qual[j
       ].lock_table
     ENDFOR
    ENDIF
  ENDFOR
 ENDIF
 SET t_record->assoc_qual_cnt = 0
 IF ((t_record->from_person_id > 0))
  SELECT INTO "nl:"
   a.parent_id
   FROM sch_assoc a,
    sch_object b
   PLAN (a
    WHERE a.assoc_type_meaning="PRSNLCHAIN"
     AND a.data_source_meaning="PRSNL"
     AND a.child_table="PERSON"
     AND (a.child_id=t_record->from_person_id))
    JOIN (b
    WHERE b.sch_object_id=a.parent_id
     AND b.active_ind=1)
   DETAIL
    t_record->assoc_qual_cnt = (t_record->assoc_qual_cnt+ 1)
    IF (mod(t_record->assoc_qual_cnt,10)=1)
     stat = alterlist(t_record->assoc_qual,(t_record->assoc_qual_cnt+ 9))
    ENDIF
    t_record->assoc_qual[t_record->assoc_qual_cnt].parent_table = a.parent_table, t_record->
    assoc_qual[t_record->assoc_qual_cnt].parent_id = a.parent_id, t_record->assoc_qual[t_record->
    assoc_qual_cnt].parent_mnemonic = b.mnemonic,
    t_record->assoc_qual[t_record->assoc_qual_cnt].parent_meaning = a.parent_meaning, t_record->
    assoc_qual[t_record->assoc_qual_cnt].child_table = a.child_table, t_record->assoc_qual[t_record->
    assoc_qual_cnt].child_meaning = a.child_meaning,
    t_record->assoc_qual[t_record->assoc_qual_cnt].assoc_type_cd = a.assoc_type_cd, t_record->
    assoc_qual[t_record->assoc_qual_cnt].assoc_type_meaning = a.assoc_type_meaning, t_record->
    assoc_qual[t_record->assoc_qual_cnt].data_source_cd = a.data_source_cd,
    t_record->assoc_qual[t_record->assoc_qual_cnt].data_source_meaning = a.data_source_meaning,
    t_record->assoc_qual[t_record->assoc_qual_cnt].display_table = a.display_table, t_record->
    assoc_qual[t_record->assoc_qual_cnt].display_meaning = a.display_meaning
   WITH nocounter
  ;end select
  SET stat = alterlist(t_record->assoc_qual,t_record->assoc_qual_cnt)
 ENDIF
 IF ((t_record->from_person_id > 0))
  SELECT INTO "nl:"
   max_nbr = max(a.seq_nbr)
   FROM (dummyt d  WITH seq = value(t_record->assoc_qual_cnt)),
    sch_assoc a
   PLAN (d
    WHERE (t_record->assoc_qual[d.seq].parent_id > 0))
    JOIN (a
    WHERE (a.parent_id=t_record->assoc_qual[d.seq].parent_id)
     AND a.assoc_type_meaning="PRSNLCHAIN")
   DETAIL
    t_record->assoc_qual[d.seq].seq_nbr = (max_nbr+ 1)
   WITH nocounter
  ;end select
 ENDIF
 SET t_record->position_assoc_qual_cnt = 0
 IF ((t_record->position_cd > 0))
  SELECT INTO "nl:"
   a.parent_id
   FROM sch_assoc a,
    sch_object b
   PLAN (a
    WHERE a.assoc_type_meaning="PRSNLCHAIN"
     AND a.data_source_meaning="POSITION"
     AND (a.child_id=t_record->position_cd))
    JOIN (b
    WHERE b.sch_object_id=a.parent_id)
   DETAIL
    t_record->position_assoc_qual_cnt = (t_record->position_assoc_qual_cnt+ 1)
    IF (mod(t_record->position_assoc_qual_cnt,10)=1)
     stat = alterlist(t_record->position_assoc_qual,(t_record->position_assoc_qual_cnt+ 9))
    ENDIF
    t_record->position_assoc_qual[t_record->position_assoc_qual_cnt].parent_mnemonic = b.mnemonic
   WITH nocounter
  ;end select
  SET stat = alterlist(t_record->position_assoc_qual,t_record->position_assoc_qual_cnt)
 ENDIF
 SET t_record->book_reply_cnt = 0
 IF ((t_record->book_qual_cnt > 0))
  SET stat = alterlist(add_book_list_request->qual,t_record->book_qual_cnt)
  FOR (i = 1 TO t_record->book_qual_cnt)
    SET add_book_list_request->qual[i].appt_book_id = t_record->book_qual[i].appt_book_id
    SET add_book_list_request->qual[i].resource_cd = t_record->resource_cd
    SET add_book_list_request->qual[i].child_appt_book_id = t_record->book_qual[i].child_appt_book_id
    SET add_book_list_request->qual[i].seq_nbr = t_record->book_qual[i].seq_nbr
    SET add_book_list_request->qual[i].active_ind = 1
  ENDFOR
  EXECUTE sch_add_book_list
  FOR (i = 1 TO add_book_list_reply->qual_cnt)
    IF ((add_book_list_reply->qual[i].status=true))
     SET t_record->book_reply_cnt = (t_record->book_reply_cnt+ 1)
    ENDIF
  ENDFOR
  SET tracking_name = "AMS_SCH_COPY_RESOURCE|APPOINTMENT BOOK"
  CALL updtdminfo(tracking_name,cnvtreal(t_record->book_reply_cnt))
 ENDIF
 SET t_record->res_list_reply_cnt = 0
 IF ((t_record->res_list_qual_cnt > 0))
  SET stat = alterlist(add_res_list_request->qual,t_record->res_list_qual_cnt)
  FOR (i = 1 TO t_record->res_list_qual_cnt)
    SET add_res_list_request->qual[i].res_group_id = t_record->res_list_qual[i].res_group_id
    SET add_res_list_request->qual[i].resource_cd = t_record->resource_cd
    SET add_res_list_request->qual[i].child_res_group_id = t_record->res_list_qual[i].
    child_res_group_id
    SET add_res_list_request->qual[i].seq_nbr = t_record->res_list_qual[i].seq_nbr
    SET add_res_list_request->qual[i].active_ind = 1
  ENDFOR
  EXECUTE sch_add_res_list
  FOR (i = 1 TO add_res_list_reply->qual_cnt)
    IF ((add_res_list_reply->qual[i].status=true))
     SET t_record->res_list_reply_cnt = (t_record->res_list_reply_cnt+ 1)
    ENDIF
  ENDFOR
  SET tracking_name = "AMS_SCH_COPY_RESOURCE|RESOURCE GROUP"
  CALL updtdminfo(tracking_name,cnvtreal(t_record->res_list_reply_cnt))
 ENDIF
 SET t_record->res_role_reply_cnt = 0
 IF ((t_record->res_role_qual_cnt > 0))
  SET stat = alterlist(add_res_role_request->qual,t_record->res_role_qual_cnt)
  FOR (i = 1 TO t_record->res_role_qual_cnt)
    SET add_res_role_request->qual[i].sch_role_cd = t_record->res_role_qual[i].sch_role_cd
    SET add_res_role_request->qual[i].resource_cd = t_record->resource_cd
    SET add_res_role_request->qual[i].role_meaning = t_record->res_role_qual[i].role_meaning
    SET add_res_role_request->qual[i].active_ind = 1
  ENDFOR
  EXECUTE sch_add_res_role
  FOR (i = 1 TO add_res_role_reply->qual_cnt)
    IF ((add_res_role_reply->qual[i].status=true))
     SET t_record->res_role_reply_cnt = (t_record->res_role_reply_cnt+ 1)
    ENDIF
  ENDFOR
  SET tracking_name = "AMS_SCH_COPY_RESOURCE|RESOURCE ROLE"
  CALL updtdminfo(tracking_name,cnvtreal(t_record->res_role_reply_cnt))
 ENDIF
 SET t_record->list_res_reply_cnt = 0
 IF ((t_record->list_res_qual_cnt > 0))
  SET stat = alterlist(add_list_res_request->qual,t_record->list_res_qual_cnt)
  FOR (i = 1 TO t_record->list_res_qual_cnt)
    SET add_list_res_request->qual[i].list_role_id = t_record->list_res_qual[i].list_role_id
    SET add_list_res_request->qual[i].resource_cd = t_record->resource_cd
    SET add_list_res_request->qual[i].pref_ind = t_record->list_res_qual[i].pref_ind
    SET add_list_res_request->qual[i].search_seq = t_record->list_res_qual[i].search_seq
    SET add_list_res_request->qual[i].display_seq = t_record->list_res_qual[i].display_seq
    SET add_list_res_request->qual[i].res_sch_cd = t_record->list_res_qual[i].res_sch_cd
    SET add_list_res_request->qual[i].res_sch_meaning = t_record->list_res_qual[i].res_sch_meaning
    SET add_list_res_request->qual[i].selected_ind = t_record->list_res_qual[i].selected_ind
    SET add_list_res_request->qual[i].sch_flex_id = t_record->list_res_qual[i].sch_flex_id
    SET add_list_res_request->qual[i].active_ind = 1
  ENDFOR
  EXECUTE sch_add_list_res
  FOR (i = 1 TO add_list_res_reply->qual_cnt)
    IF ((add_list_res_reply->qual[i].status=true))
     SET t_record->list_res_reply_cnt = (t_record->list_res_reply_cnt+ 1)
    ENDIF
  ENDFOR
  SET tracking_name = "AMS_SCH_COPY_RESOURCE|RESOURCE LIST RESOURCE"
  CALL updtdminfo(tracking_name,cnvtreal(t_record->list_res_reply_cnt))
 ENDIF
 SET t_record->list_slot_reply_cnt = 0
 SET add_list_slot_reply->qual_cnt = 0
 FOR (i = 1 TO t_record->list_res_qual_cnt)
   SET add_list_slot_reply->qual_cnt = (add_list_slot_reply->qual_cnt+ t_record->list_res_qual[i].
   list_slot_qual_cnt)
 ENDFOR
 IF ((add_list_slot_reply->qual_cnt > 0))
  SET stat = alterlist(add_list_slot_request->qual,add_list_slot_reply->qual_cnt)
  SET k = 0
  FOR (i = 1 TO t_record->list_res_qual_cnt)
    FOR (j = 1 TO t_record->list_res_qual[i].list_slot_qual_cnt)
      SET k = (k+ 1)
      SET add_list_slot_request->qual[k].list_role_id = t_record->list_res_qual[i].list_role_id
      SET add_list_slot_request->qual[k].resource_cd = t_record->resource_cd
      SET add_list_slot_request->qual[k].slot_type_id = t_record->list_res_qual[i].list_slot_qual[j].
      slot_type_id
      SET add_list_slot_request->qual[k].sch_flex_id = t_record->list_res_qual[i].list_slot_qual[j].
      sch_flex_id
      SET add_list_slot_request->qual[k].setup_units = t_record->list_res_qual[i].list_slot_qual[j].
      setup_units
      SET add_list_slot_request->qual[k].setup_units_cd = t_record->list_res_qual[i].list_slot_qual[j
      ].setup_units_cd
      SET add_list_slot_request->qual[k].setup_units_meaning = t_record->list_res_qual[i].
      list_slot_qual[j].setup_units_meaning
      SET add_list_slot_request->qual[k].setup_role_id = t_record->list_res_qual[i].list_slot_qual[j]
      .setup_role_id
      SET add_list_slot_request->qual[k].duration_role_id = t_record->list_res_qual[i].
      list_slot_qual[j].duration_role_id
      SET add_list_slot_request->qual[k].duration_units = t_record->list_res_qual[i].list_slot_qual[j
      ].duration_units
      SET add_list_slot_request->qual[k].duration_units_cd = t_record->list_res_qual[i].
      list_slot_qual[j].duration_units_cd
      SET add_list_slot_request->qual[k].duration_units_meaning = t_record->list_res_qual[i].
      list_slot_qual[j].duration_units_meaning
      SET add_list_slot_request->qual[k].cleanup_units = t_record->list_res_qual[i].list_slot_qual[j]
      .cleanup_units
      SET add_list_slot_request->qual[k].cleanup_units_cd = t_record->list_res_qual[i].
      list_slot_qual[j].cleanup_units_cd
      SET add_list_slot_request->qual[k].cleanup_units_meaning = t_record->list_res_qual[i].
      list_slot_qual[j].cleanup_units_meaning
      SET add_list_slot_request->qual[k].cleanup_role_id = t_record->list_res_qual[i].list_slot_qual[
      j].cleanup_role_id
      SET add_list_slot_request->qual[k].offset_type_cd = t_record->list_res_qual[i].list_slot_qual[j
      ].offset_type_cd
      SET add_list_slot_request->qual[k].offset_type_meaning = t_record->list_res_qual[i].
      list_slot_qual[j].offset_type_meaning
      SET add_list_slot_request->qual[k].offset_role_id = t_record->list_res_qual[i].list_slot_qual[j
      ].offset_role_id
      SET add_list_slot_request->qual[k].offset_beg_units = t_record->list_res_qual[i].
      list_slot_qual[j].offset_beg_units
      SET add_list_slot_request->qual[k].offset_beg_units_cd = t_record->list_res_qual[i].
      list_slot_qual[j].offset_beg_units_cd
      SET add_list_slot_request->qual[k].offset_beg_units_meaning = t_record->list_res_qual[i].
      list_slot_qual[j].offset_beg_units_meaning
      SET add_list_slot_request->qual[k].offset_end_units = t_record->list_res_qual[i].
      list_slot_qual[j].offset_end_units
      SET add_list_slot_request->qual[k].offset_end_units_cd = t_record->list_res_qual[i].
      list_slot_qual[j].offset_end_units_cd
      SET add_list_slot_request->qual[k].offset_end_units_meaning = t_record->list_res_qual[i].
      list_slot_qual[j].offset_end_units_meaning
      SET add_list_slot_request->qual[k].display_seq = t_record->list_res_qual[i].list_slot_qual[j].
      display_seq
      SET add_list_slot_request->qual[k].selected_ind = t_record->list_res_qual[i].list_slot_qual[j].
      selected_ind
      SET add_list_slot_request->qual[k].search_seq = t_record->list_res_qual[i].list_slot_qual[j].
      search_seq
      SET add_list_slot_request->qual[k].active_ind = 1
      SET add_list_slot_request->qual[k].allow_partial_ind = 0
    ENDFOR
  ENDFOR
  EXECUTE sch_add_list_slot
  FOR (i = 1 TO add_list_slot_reply->qual_cnt)
    IF ((add_list_slot_reply->qual[i].status=true))
     SET t_record->list_slot_reply_cnt = (t_record->list_slot_reply_cnt+ 1)
    ENDIF
  ENDFOR
  SET tracking_name = "AMS_SCH_COPY_RESOURCE|RESOURCE LIST SLOT"
  CALL updtdminfo(tracking_name,cnvtreal(t_record->list_slot_reply_cnt))
 ENDIF
 SET t_record->sec_reply_cnt = 0
 IF ((t_record->sec_total > 0))
  SET stat = alterlist(chgw_security_request->qual,t_record->sec_total)
  SET chgw_security_request->allow_partial_ind = 0
  SET chgw_security_request->call_echo_ind = 0
  SET k = 0
  FOR (i = 1 TO t_record->sec_qual_cnt)
    FOR (j = 1 TO t_record->sec_qual[i].security_qual_cnt)
      SET k = (k+ 1)
      SET chgw_security_request->qual[k].security_id = 0
      SET chgw_security_request->qual[k].sec_type_cd = t_record->sec_qual[i].sec_type_cd
      SET chgw_security_request->qual[k].sec_type_meaning = t_record->sec_qual[i].sec_type_meaning
      SET chgw_security_request->qual[k].version_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
      SET chgw_security_request->qual[k].parent1_table = t_record->sec_qual[i].security_qual[j].
      parent1_table
      SET chgw_security_request->qual[k].parent1_id = t_record->sec_qual[i].security_qual[j].
      parent1_id
      SET chgw_security_request->qual[k].parent1_meaning = t_record->sec_qual[i].security_qual[j].
      parent1_meaning
      SET chgw_security_request->qual[k].display1_table = t_record->sec_qual[i].security_qual[j].
      display1_table
      SET chgw_security_request->qual[k].display1_id = t_record->sec_qual[i].security_qual[j].
      display1_id
      SET chgw_security_request->qual[k].display1_meaning = t_record->sec_qual[i].security_qual[j].
      display1_meaning
      SET chgw_security_request->qual[k].data1_source_cd = t_record->sec_qual[i].security_qual[j].
      data1_source_cd
      SET chgw_security_request->qual[k].data1_source_meaning = t_record->sec_qual[i].security_qual[j
      ].data1_source_meaning
      SET chgw_security_request->qual[k].parent2_table = t_record->sec_qual[i].security_qual[j].
      parent2_table
      SET chgw_security_request->qual[k].parent2_id = t_record->sec_qual[i].security_qual[j].
      parent2_id
      SET chgw_security_request->qual[k].parent2_meaning = t_record->sec_qual[i].security_qual[j].
      parent2_meaning
      SET chgw_security_request->qual[k].display2_table = t_record->sec_qual[i].security_qual[j].
      display2_table
      SET chgw_security_request->qual[k].display2_id = t_record->sec_qual[i].security_qual[j].
      display2_id
      SET chgw_security_request->qual[k].display2_meaning = t_record->sec_qual[i].security_qual[j].
      display2_meaning
      SET chgw_security_request->qual[k].data2_source_cd = t_record->sec_qual[i].security_qual[j].
      data2_source_cd
      SET chgw_security_request->qual[k].data2_source_meaning = t_record->sec_qual[i].security_qual[j
      ].data2_source_meaning
      SET chgw_security_request->qual[k].parent3_table = t_record->sec_qual[i].security_qual[j].
      parent3_table
      SET chgw_security_request->qual[k].parent3_id = t_record->sec_qual[i].security_qual[j].
      parent3_id
      SET chgw_security_request->qual[k].parent3_meaning = t_record->sec_qual[i].security_qual[j].
      parent3_meaning
      SET chgw_security_request->qual[k].display3_table = t_record->sec_qual[i].security_qual[j].
      display3_table
      SET chgw_security_request->qual[k].display3_id = t_record->sec_qual[i].security_qual[j].
      display3_id
      SET chgw_security_request->qual[k].display3_meaning = t_record->sec_qual[i].security_qual[j].
      display3_meaning
      SET chgw_security_request->qual[k].data3_source_cd = t_record->sec_qual[i].security_qual[j].
      data3_source_cd
      SET chgw_security_request->qual[k].data3_source_meaning = t_record->sec_qual[i].security_qual[j
      ].data3_source_meaning
      SET chgw_security_request->qual[k].lock_table = t_record->sec_qual[i].security_qual[j].
      lock_table
      SET chgw_security_request->qual[k].lock_id = t_record->sec_qual[i].security_qual[j].lock_id
      SET chgw_security_request->qual[k].lock_meaning = t_record->sec_qual[i].security_qual[j].
      lock_meaning
      SET chgw_security_request->qual[k].updt_cnt = 0
      SET chgw_security_request->qual[k].action = 1
      SET chgw_security_request->qual[k].active_ind = 1
      SET chgw_security_request->qual[k].force_updt_ind = 0
    ENDFOR
  ENDFOR
  EXECUTE sch_chgw_security
  FOR (i = 1 TO chgw_security_reply->qual_cnt)
    IF ((chgw_security_reply->qual[i].status=true))
     SET t_record->sec_reply_cnt = (t_record->sec_reply_cnt+ 1)
    ENDIF
  ENDFOR
  SET tracking_name = "AMS_SCH_COPY_RESOURCE|SECURITY"
  CALL updtdminfo(tracking_name,cnvtreal(t_record->sec_reply_cnt))
 ENDIF
 SET t_record->assoc_reply_cnt = 0
 IF ((t_record->assoc_qual_cnt > 0))
  SET stat = alterlist(add_assoc_request->qual,t_record->assoc_qual_cnt)
  FOR (i = 1 TO t_record->assoc_qual_cnt)
    SET add_assoc_request->qual[i].association_id = 0
    SET add_assoc_request->qual[i].parent_table = t_record->assoc_qual[i].parent_table
    SET add_assoc_request->qual[i].parent_id = t_record->assoc_qual[i].parent_id
    SET add_assoc_request->qual[i].parent_meaning = t_record->assoc_qual[i].parent_meaning
    SET add_assoc_request->qual[i].child_table = t_record->assoc_qual[i].child_table
    SET add_assoc_request->qual[i].child_id = t_record->person_id
    SET add_assoc_request->qual[i].child_meaning = t_record->assoc_qual[i].child_meaning
    SET add_assoc_request->qual[i].seq_nbr = t_record->assoc_qual[i].seq_nbr
    SET add_assoc_request->qual[i].assoc_type_cd = t_record->assoc_qual[i].assoc_type_cd
    SET add_assoc_request->qual[i].assoc_type_meaning = t_record->assoc_qual[i].assoc_type_meaning
    SET add_assoc_request->qual[i].data_source_cd = t_record->assoc_qual[i].data_source_cd
    SET add_assoc_request->qual[i].data_source_meaning = t_record->assoc_qual[i].data_source_meaning
    SET add_assoc_request->qual[i].active_ind = 1
    SET add_assoc_request->qual[i].active_status_cd = 0.0
    SET add_assoc_request->qual[i].candidate_id = 0.0
    SET add_assoc_request->qual[i].display_table = t_record->assoc_qual[i].display_table
    SET add_assoc_request->qual[i].display_id = t_record->person_id
    SET add_assoc_request->qual[i].display_meaning = t_record->assoc_qual[i].display_meaning
    SET add_assoc_request->qual[i].allow_partial_ind = 0
  ENDFOR
  EXECUTE sch_add_assoc
  FOR (i = 1 TO add_assoc_reply->qual_cnt)
    IF ((add_assoc_reply->qual[i].status=true))
     SET t_record->assoc_reply_cnt = (t_record->assoc_reply_cnt+ 1)
    ENDIF
  ENDFOR
  SET tracking_name = "AMS_SCH_COPY_RESOURCE|KEYCHAIN"
  CALL updtdminfo(tracking_name,cnvtreal(t_record->assoc_reply_cnt))
 ENDIF
#exit_script
 SET cur_row = 1
 SELECT INTO  $1
  FROM dummyt d
  DETAIL
   row cur_row, col 30, "Resource Association Copy Report"
   IF ((reply->status_data.status="F"))
    cur_row = (cur_row+ 3), row cur_row, col 10,
    reply->status_data.subeventstatus.targetobjectvalue
   ELSEIF ((reply->status_data.status="S"))
    IF ((chgw_security_reply->qual_cnt > 0))
     cur_row = (cur_row+ 3), row cur_row, col 15,
     "*******************************************************", cur_row = (cur_row+ 1), row cur_row,
     col 15, "* SCHEDULING SECURITY SERVER (581) NEED TO BE CYCLED! *", cur_row = (cur_row+ 1),
     row cur_row, col 15, "*******************************************************"
    ENDIF
    cur_row = (cur_row+ 3), row cur_row, col 5,
    "        From Resource", cur_row = (cur_row+ 1), row cur_row,
    col 5, "Mnemonic:", col 35,
    t_record->from_resource_mnemonic, cur_row = (cur_row+ 1), row cur_row,
    col 5, "Resource Type:"
    IF ((t_record->res_type_flag=1))
     col 35, "General"
    ELSEIF ((t_record->res_type_flag=2))
     col 35, "Personnel"
    ENDIF
    IF ((t_record->from_person_id > 0))
     cur_row = (cur_row+ 1), row cur_row, col 5,
     "Personnel:", col 35, t_record->from_name_full_formatted,
     cur_row = (cur_row+ 1), row cur_row, col 5,
     "Position:", col 35, t_record->from_position_disp
    ENDIF
    cur_row = (cur_row+ 2), row cur_row, col 5,
    "        To Resource", cur_row = (cur_row+ 1), row cur_row,
    col 5, "Mnemonic:", col 35,
    t_record->mnemonic, cur_row = (cur_row+ 1), row cur_row,
    col 5, "Resource Type:"
    IF ((t_record->res_type_flag=1))
     col 35, "General"
    ELSEIF ((t_record->res_type_flag=2))
     col 35, "Personnel", cur_row = (cur_row+ 1),
     row cur_row, col 5, "Personnel:",
     col 35, t_record->name_full_formatted, cur_row = (cur_row+ 1),
     row cur_row, col 5, "Position:",
     col 35, t_record->position_disp
    ENDIF
    cur_row = (cur_row+ 2), row cur_row, col 5,
    "Appt Book Assoc Found: ", col 65, t_record->book_qual_cnt,
    cur_row = (cur_row+ 1), row cur_row, col 5,
    "Appt Book Assoc Created: ", col 65, t_record->book_reply_cnt
    IF ((t_record->book_qual_cnt > 0))
     cur_row = (cur_row+ 2), row cur_row, col 5,
     "Appt Books:", col 35, "Mnemonic",
     col 73, "Seq", cur_row = (cur_row+ 1),
     row cur_row, col 35, "--------",
     col 73, "---"
     FOR (i = 1 TO t_record->book_qual_cnt)
       temp_string = substring(1,29,t_record->book_qual[i].mnemonic), cur_row = (cur_row+ 1), row
       cur_row,
       col 35, temp_string, col 65,
       t_record->book_qual[i].seq_nbr
     ENDFOR
    ENDIF
    cur_row = (cur_row+ 2), row cur_row, col 5,
    "Resource Role Assoc Found: ", col 65, t_record->res_role_qual_cnt,
    cur_row = (cur_row+ 1), row cur_row, col 5,
    "Resource Role Assoc Created: ", col 65, t_record->res_role_reply_cnt
    IF ((t_record->res_role_qual_cnt > 0))
     cur_row = (cur_row+ 2), row cur_row, col 5,
     "Resource Roles:", col 35, "Mnemonic",
     cur_row = (cur_row+ 1), row cur_row, col 35,
     "--------"
     FOR (i = 1 TO t_record->res_role_qual_cnt)
       temp_string = substring(1,40,t_record->res_role_qual[i].mnemonic), cur_row = (cur_row+ 1), row
        cur_row,
       col 35, temp_string
     ENDFOR
    ENDIF
    cur_row = (cur_row+ 2), row cur_row, col 5,
    "Resource Group Assoc Found: ", col 65, t_record->res_list_qual_cnt,
    cur_row = (cur_row+ 1), row cur_row, col 5,
    "Resource Group Assoc Created: ", col 65, t_record->res_list_reply_cnt
    IF ((t_record->res_list_qual_cnt > 0))
     cur_row = (cur_row+ 2), row cur_row, col 5,
     "Resource Groups:", col 35, "Mnemonic",
     col 73, "Seq", cur_row = (cur_row+ 1),
     row cur_row, col 35, "--------",
     col 73, "---"
     FOR (i = 1 TO t_record->res_list_qual_cnt)
       temp_string = substring(1,29,t_record->res_list_qual[i].mnemonic), cur_row = (cur_row+ 1), row
        cur_row,
       col 35, temp_string, col 65,
       t_record->res_list_qual[i].seq_nbr
     ENDFOR
    ENDIF
    cur_row = (cur_row+ 2), row cur_row, col 5,
    "Resource List Assoc Found: ", col 65, t_record->list_res_qual_cnt,
    cur_row = (cur_row+ 1), row cur_row, col 5,
    "Resource List Assoc Created: ", col 65, t_record->list_res_reply_cnt
    IF ((t_record->list_res_qual_cnt > 0))
     cur_row = (cur_row+ 2), row cur_row, col 5,
     "Resource Lists:", col 35, "Res List Mnemonic",
     col 70, "Role Description", cur_row = (cur_row+ 1),
     row cur_row, col 35, "-----------------",
     col 70, "----------------"
     FOR (i = 1 TO t_record->list_res_qual_cnt)
       cur_row = (cur_row+ 1), row cur_row
       IF ((t_record->list_res_qual[i].res_list_id=0))
        col 35, "(Order Role Only)"
       ELSE
        temp_string = substring(1,29,t_record->list_res_qual[i].res_list_mnemonic), col 35,
        temp_string
       ENDIF
       temp_string = substring(1,29,t_record->list_res_qual[i].list_role_description), col 70,
       temp_string
     ENDFOR
    ENDIF
    cur_row = (cur_row+ 2), row cur_row, col 5,
    "Security Assoc Found:", col 65, t_record->sec_total,
    cur_row = (cur_row+ 1), row cur_row, col 5,
    "Security Assoc Created:", col 65, chgw_security_reply->qual_cnt
    IF ((t_record->sec_total > 0)
     AND (t_record->sec_total=chgw_security_reply->qual_cnt))
     cur_row = (cur_row+ 2), row cur_row, col 5,
     "Securities:", col 20, "Type",
     col 48, "Action", col 70,
     "Lock", cur_row = (cur_row+ 1), row cur_row,
     col 20, "-------------", col 48,
     "-------------", col 70, "-------------------"
     FOR (i = 1 TO t_record->sec_qual_cnt)
       FOR (j = 1 TO t_record->sec_qual[i].security_qual_cnt)
         cur_row = (cur_row+ 1), row cur_row, col 20,
         t_record->sec_qual[i].sec_type_display
         IF ((t_record->sec_qual[i].sec_type_meaning="RESOURCE"))
          temp_string = substring(1,16,t_record->sec_qual[i].security_qual[j].mnemonic2), col 48,
          temp_string
         ELSE
          temp_string = substring(1,16,t_record->sec_qual[i].security_qual[j].mnemonic3), col 48,
          temp_string
         ENDIF
         temp_string = substring(1,40,t_record->sec_qual[i].security_qual[j].lock_mnemonic), col 70,
         t_record->sec_qual[i].security_qual[j].lock_mnemonic
       ENDFOR
     ENDFOR
    ENDIF
    IF ((t_record->from_person_id > 0.0))
     cur_row = (cur_row+ 2), row cur_row, col 5,
     "Keychain Assoc Found:", col 65, t_record->assoc_qual_cnt,
     cur_row = (cur_row+ 1), row cur_row, col 5,
     "Keychain Assoc Created:", col 65, t_record->assoc_reply_cnt
     IF ((t_record->assoc_qual_cnt > 0))
      cur_row = (cur_row+ 2), row cur_row, col 5,
      "Keychains:", col 35, "Mnemonic",
      cur_row = (cur_row+ 1), row cur_row, col 35,
      "-------------"
      FOR (i = 1 TO t_record->assoc_qual_cnt)
        temp_string = substring(1,80,t_record->assoc_qual[i].parent_mnemonic), cur_row = (cur_row+ 1),
        row cur_row,
        col 35, temp_string
      ENDFOR
     ENDIF
    ENDIF
    IF ((t_record->position_assoc_qual_cnt > 0))
     cur_row = (cur_row+ 3), row cur_row, col 15,
     "*******************************************************", cur_row = (cur_row+ 1), row cur_row,
     col 15, "*      INFO ONLY, NO ASSOCIATION CREATED              *", cur_row = (cur_row+ 1),
     row cur_row, col 15, "*******************************************************",
     temp_string = concat("Position ",t_record->position_disp,"(for ",t_record->
      from_name_full_formatted,")"), cur_row = (cur_row+ 1), row cur_row,
     col 23, temp_string, temp_string = "is associated with the following keychains",
     cur_row = (cur_row+ 1), row cur_row, col 23,
     temp_string, cur_row = (cur_row+ 2), row cur_row,
     col 5, "Keychains:", col 20,
     "Mnemonic", cur_row = (cur_row+ 1), row cur_row,
     col 20, "-------------"
     FOR (i = 1 TO t_record->position_assoc_qual_cnt)
       cur_row = (cur_row+ 1), row cur_row, col 20,
       t_record->position_assoc_qual[i].parent_mnemonic
     ENDFOR
    ENDIF
    IF ((chgw_security_reply->qual_cnt > 0))
     cur_row = (cur_row+ 3), row cur_row, col 15,
     "*******************************************************", cur_row = (cur_row+ 1), row cur_row,
     col 15, "* SCHEDULING SECURITY SERVER (581) NEED TO BE CYCLED! *", cur_row = (cur_row+ 1),
     row cur_row, col 15, "*******************************************************"
    ENDIF
   ELSE
    cur_row = (cur_row+ 3), row cur_row, col 10,
    "Unexpected error, please write down the resource you tried to copy from and contact support"
   ENDIF
  WITH nocounter, format, maxrow = 10000,
   maxcol = 132
 ;end select
END GO
