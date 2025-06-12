CREATE PROGRAM ams_sch_remove_resource:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select the Scheduling Resource to remove" = 0
  WITH outdev, resource_cd
 IF (validate(action_none,- (1)) != 0)
  DECLARE action_none = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(action_add,- (1)) != 1)
  DECLARE action_add = i2 WITH protect, noconstant(1)
 ENDIF
 IF (validate(action_chg,- (1)) != 2)
  DECLARE action_chg = i2 WITH protect, noconstant(2)
 ENDIF
 IF (validate(action_del,- (1)) != 3)
  DECLARE action_del = i2 WITH protect, noconstant(3)
 ENDIF
 IF (validate(action_get,- (1)) != 4)
  DECLARE action_get = i2 WITH protect, noconstant(4)
 ENDIF
 IF (validate(action_ina,- (1)) != 5)
  DECLARE action_ina = i2 WITH protect, noconstant(5)
 ENDIF
 IF (validate(action_act,- (1)) != 6)
  DECLARE action_act = i2 WITH protect, noconstant(6)
 ENDIF
 IF (validate(action_temp,- (1)) != 999)
  DECLARE action_temp = i2 WITH protect, noconstant(999)
 ENDIF
 IF (validate(true,- (1)) != 1)
  DECLARE true = i2 WITH protect, noconstant(1)
 ENDIF
 IF (validate(false,- (1)) != 0)
  DECLARE false = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(gen_nbr_error,- (1)) != 3)
  DECLARE gen_nbr_error = i2 WITH protect, noconstant(3)
 ENDIF
 IF (validate(insert_error,- (1)) != 4)
  DECLARE insert_error = i2 WITH protect, noconstant(4)
 ENDIF
 IF (validate(update_error,- (1)) != 5)
  DECLARE update_error = i2 WITH protect, noconstant(5)
 ENDIF
 IF (validate(replace_error,- (1)) != 6)
  DECLARE replace_error = i2 WITH protect, noconstant(6)
 ENDIF
 IF (validate(delete_error,- (1)) != 7)
  DECLARE delete_error = i2 WITH protect, noconstant(7)
 ENDIF
 IF (validate(undelete_error,- (1)) != 8)
  DECLARE undelete_error = i2 WITH protect, noconstant(8)
 ENDIF
 IF (validate(remove_error,- (1)) != 9)
  DECLARE remove_error = i2 WITH protect, noconstant(9)
 ENDIF
 IF (validate(attribute_error,- (1)) != 10)
  DECLARE attribute_error = i2 WITH protect, noconstant(10)
 ENDIF
 IF (validate(lock_error,- (1)) != 11)
  DECLARE lock_error = i2 WITH protect, noconstant(11)
 ENDIF
 IF (validate(none_found,- (1)) != 12)
  DECLARE none_found = i2 WITH protect, noconstant(12)
 ENDIF
 IF (validate(select_error,- (1)) != 13)
  DECLARE select_error = i2 WITH protect, noconstant(13)
 ENDIF
 IF (validate(update_cnt_error,- (1)) != 14)
  DECLARE update_cnt_error = i2 WITH protect, noconstant(14)
 ENDIF
 IF (validate(not_found,- (1)) != 15)
  DECLARE not_found = i2 WITH protect, noconstant(15)
 ENDIF
 IF (validate(version_insert_error,- (1)) != 16)
  DECLARE version_insert_error = i2 WITH protect, noconstant(16)
 ENDIF
 IF (validate(inactivate_error,- (1)) != 17)
  DECLARE inactivate_error = i2 WITH protect, noconstant(17)
 ENDIF
 IF (validate(activate_error,- (1)) != 18)
  DECLARE activate_error = i2 WITH protect, noconstant(18)
 ENDIF
 IF (validate(version_delete_error,- (1)) != 19)
  DECLARE version_delete_error = i2 WITH protect, noconstant(19)
 ENDIF
 IF (validate(uar_error,- (1)) != 20)
  DECLARE uar_error = i2 WITH protect, noconstant(20)
 ENDIF
 IF (validate(duplicate_error,- (1)) != 21)
  DECLARE duplicate_error = i2 WITH protect, noconstant(21)
 ENDIF
 IF (validate(ccl_error,- (1)) != 22)
  DECLARE ccl_error = i2 WITH protect, noconstant(22)
 ENDIF
 IF (validate(execute_error,- (1)) != 23)
  DECLARE execute_error = i2 WITH protect, noconstant(23)
 ENDIF
 IF (validate(failed,- (1)) != 0)
  DECLARE failed = i2 WITH protect, noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH protect, noconstant("")
 ELSE
  SET table_name = fillstring(100," ")
 ENDIF
 IF (validate(call_echo_ind,- (1)) != 0)
  DECLARE call_echo_ind = i2 WITH protect, noconstant(false)
 ENDIF
 IF (validate(i_version,- (1)) != 0)
  DECLARE i_version = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(program_name,"ZZZ")="ZZZ")
  DECLARE program_name = vc WITH protect, noconstant(fillstring(30," "))
 ENDIF
 IF (validate(sch_security_id,- (1)) != 0)
  DECLARE sch_security_id = f8 WITH protect, noconstant(0.0)
 ENDIF
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
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
    1 resource_cd = f8
    1 mnemonic = vc
    1 person_id = f8
    1 name_full_formatted = vc
    1 res_type_flag = i2
    1 book_qual_cnt = i4
    1 book_qual[*]
      2 appt_book_id = f8
      2 mnemonic = vc
      2 single_child_ind = i2
      2 book_list_qual_cnt = i4
      2 book_list_qual[*]
        3 resource_cd = f8
        3 res_exist_ind = i2
        3 child_appt_book_id = f8
        3 updt_cnt = i4
        3 orig_seq_nbr = i4
        3 new_seq_nbr = i4
        3 action = i2
    1 book_del_cnt = i4
    1 book_cleanup_cnt = i4
    1 book_chg_cnt = i4
    1 book_del_reply_cnt = i4
    1 book_cleanup_reply_cnt = i4
    1 book_chg_reply_cnt = i4
    1 res_group_qual_cnt = i4
    1 res_group_qual[*]
      2 res_group_id = f8
      2 mnemonic = vc
      2 single_child_ind = i2
      2 res_list_qual_cnt = i4
      2 res_list_qual[*]
        3 resource_cd = f8
        3 res_exist_ind = i2
        3 child_res_group_id = f8
        3 updt_cnt = i4
        3 orig_seq_nbr = i4
        3 new_seq_nbr = i4
        3 action = i2
    1 res_group_del_cnt = i4
    1 res_group_cleanup_cnt = i4
    1 res_group_chg_cnt = i4
    1 res_group_del_reply_cnt = i4
    1 res_group_cleanup_reply_cnt = i4
    1 res_group_chg_reply_cnt = i4
    1 res_role_qual_cnt = i4
    1 res_role_qual[*]
      2 sch_role_cd = f8
      2 mnemonic = vc
      2 role_meaning = c30
      2 updt_cnt = i4
      2 single_child_ind = i2
    1 res_role_reply_cnt = i4
    1 list_res_qual_cnt = i4
    1 list_role_qual_cnt = i4
    1 list_role_qual[*]
      2 list_role_id = f8
      2 list_role_description = vc
      2 res_list_id = f8
      2 res_list_mnemonic = vc
      2 single_child_ind = i2
      2 list_res_qual_cnt = i4
      2 list_res_qual[*]
        3 list_role_id = f8
        3 resource_cd = f8
        3 res_exist_ind = i2
        3 display_seq = i4
        3 updt_cnt = i4
        3 resource_cd = i4
        3 version_dt_tm = dq8
        3 pref_ind = i2
        3 search_seq = i4
        3 updt_cnt = i4
        3 res_sch_cd = f8
        3 res_sch_meaning = c12
        3 selected_ind = i2
        3 sch_flex_id = f8
        3 action = i2
        3 list_slot_qual_cnt = i4
        3 list_slot_qual[*]
          4 slot_type_id = f8
          4 updt_cnt = i4
    1 list_res_del_cnt = i4
    1 list_res_cleanup_cnt = i4
    1 list_res_chg_cnt = i4
    1 list_res_del_reply_cnt = i4
    1 list_res_cleanup_reply_cnt = i4
    1 list_res_chg_reply_cnt = i4
    1 list_slot_del_cnt = i4
    1 list_slot_del_reply_cnt = i4
    1 def_res_qual_cnt = i4
    1 def_res_qual[*]
      2 def_sched_id = f8
      2 mnemonic = vc
      2 updt_cnt = i4
    1 def_res_reply_cnt = i4
    1 block_qual_cnt = i4
    1 block_qual[*]
      2 mnemonic = vc
      2 def_apply_id = f8
      2 frequency_id = f8
      2 beg_dt_tm = dq8
      2 end_dt_tm = dq8
      2 apply_range = i4
    1 block_reply_cnt = i4
  )
 ENDIF
 IF ( NOT (validate(del_res_role_request,0)))
  RECORD del_res_role_request(
    1 call_echo_ind = i2
    1 qual[*]
      2 resource_cd = f8
      2 sch_role_cd = f8
      2 updt_cnt = i4
      2 allow_partial_ind = i2
      2 force_updt_ind = i2
  )
 ENDIF
 IF ( NOT (validate(del_res_role_reply,0)))
  RECORD del_res_role_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 status = i4
  )
 ENDIF
 IF ( NOT (validate(del_book_list_request,0)))
  RECORD del_book_list_request(
    1 call_echo_ind = i2
    1 qual[*]
      2 appt_book_id = f8
      2 seq_nbr = i4
      2 updt_cnt = i4
      2 allow_partial_ind = i2
      2 force_updt_ind = i2
  )
 ENDIF
 IF ( NOT (validate(del_book_list_reply,0)))
  RECORD del_book_list_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 status = i4
  )
 ENDIF
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
 IF ( NOT (validate(del_res_list_request,0)))
  RECORD del_res_list_request(
    1 call_echo_ind = i2
    1 qual[*]
      2 res_group_id = f8
      2 seq_nbr = i4
      2 updt_cnt = i4
      2 allow_partial_ind = i2
      2 force_updt_ind = i2
  )
 ENDIF
 IF ( NOT (validate(del_res_list_reply,0)))
  RECORD del_res_list_reply(
    1 qual_cnt = i4
    1 qual[*]
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
 IF ( NOT (validate(del_list_res_request,0)))
  RECORD del_list_res_request(
    1 call_echo_ind = i2
    1 qual[*]
      2 list_role_id = f8
      2 resource_cd = i4
      2 updt_cnt = i4
      2 allow_partial_ind = i2
      2 force_updt_ind = i2
  )
 ENDIF
 IF ( NOT (validate(del_list_res_reply,0)))
  RECORD del_list_res_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 status = i4
  )
 ENDIF
 IF ( NOT (validate(chg_list_res_request,0)))
  RECORD chg_list_res_request(
    1 call_echo_ind = i2
    1 qual[*]
      2 list_role_id = f8
      2 resource_cd = i4
      2 version_dt_tm = dq8
      2 pref_ind = i2
      2 search_seq = i4
      2 display_seq = i4
      2 updt_cnt = i4
      2 res_sch_cd = f8
      2 res_sch_meaning = c12
      2 selected_ind = i2
      2 sch_flex_id = f8
      2 allow_partial_ind = i2
      2 version_ind = i2
      2 force_updt_ind = i2
  )
 ENDIF
 IF ( NOT (validate(chg_list_res_reply,0)))
  RECORD chg_list_res_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 status = i4
  )
 ENDIF
 IF ( NOT (validate(del_list_slot_request,0)))
  RECORD del_list_slot_request(
    1 call_echo_ind = i2
    1 qual[*]
      2 list_role_id = f8
      2 resource_cd = f8
      2 slot_type_id = f8
      2 updt_cnt = i4
      2 allow_partial_ind = i2
      2 force_updt_ind = i2
  )
 ENDIF
 IF ( NOT (validate(del_list_slot_reply,0)))
  RECORD del_list_slot_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 status = i4
  )
 ENDIF
 IF ( NOT (validate(del_def_res_request,0)))
  RECORD del_def_res_request(
    1 call_echo_ind = i2
    1 qual[*]
      2 def_sched_id = f8
      2 resource_cd = f8
      2 updt_cnt = i4
      2 allow_partial_ind = i2
      2 force_updt_ind = i2
  )
 ENDIF
 IF ( NOT (validate(del_def_res_reply,0)))
  RECORD del_def_res_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 status = i4
  )
 ENDIF
 IF ( NOT (validate(chgw_block_request,0)))
  RECORD chgw_block_request(
    1 call_echo_ind = i2
    1 conversation_id = f8
    1 allow_partial_ind = i2
    1 qual[*]
      2 sch_action_cd = f8
      2 action_meaning = vc
      2 def_apply_id = f8
      2 frequency_id = f8
      2 apply_range = i4
      2 end_dt_tm = dq8
      2 end_type_cd = f8
      2 end_type_meaning = c12
      2 max_occurance = i4
  )
 ENDIF
 IF ( NOT (validate(chgw_block_reply,0)))
  RECORD chgw_block_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 def_apply_id = f8
      2 frequency_id = f8
      2 def_action_id = f8
      2 def_action_candidate_id = f8
      2 freq_action_id = f8
      2 freq_action_candidate_id = f8
      2 status = i2
  )
 ENDIF
 SET t_record->resource_cd = cnvtreal( $RESOURCE_CD)
 IF ((t_record->resource_cd <= 0))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "No valid resource selected."
  GO TO report_section
 ENDIF
 SELECT INTO "nl:"
  a.resource_cd
  FROM sch_resource a,
   prsnl p
  PLAN (a
   WHERE (a.resource_cd=t_record->resource_cd))
   JOIN (p
   WHERE p.person_id=a.person_id)
  DETAIL
   t_record->res_type_flag = a.res_type_flag, t_record->mnemonic = a.mnemonic, t_record->person_id =
   a.person_id,
   t_record->name_full_formatted = p.name_full_formatted
  WITH nocounter
 ;end select
 SET tracking_name = "AMS_SCH_REMOVE_RESOURCE|RESOURCE - AUDIT"
 CALL updtdminfo(tracking_name,1.0)
 SET future_appt_count = 0
 SELECT INTO "nl:"
  a.candidate_id
  FROM sch_appt a,
   sch_appt a2
  PLAN (a
   WHERE (a.person_id=t_record->person_id)
    AND (a.resource_cd=t_record->resource_cd)
    AND a.end_dt_tm > cnvtdatetime(curdate,curtime3)
    AND a.sch_event_id > 0
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND a.state_meaning IN ("CHECKED IN", "CHECKED OUT", "CONFIRMED", "FINALIZED", "NOSHOW",
   "PENDING", "STANDBY", "SCHEDULED")
    AND ((a.role_meaning = null) OR (a.role_meaning != "PATIENT"))
    AND a.active_ind=1)
   JOIN (a2
   WHERE a2.sch_event_id=a.sch_event_id
    AND a2.schedule_id=a.schedule_id
    AND a2.role_meaning="PATIENT")
  DETAIL
   future_appt_count = (future_appt_count+ 1)
  WITH nocounter
 ;end select
 IF (future_appt_count > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Resource cannot be removed, future patient appointment exists."
  GO TO report_section
 ENDIF
 SET count1 = 0
 SET count2 = 0
 SET t_record->book_qual_cnt = 0
 SELECT INTO "nl:"
  bl1.appt_book_id, res_exist = decode(r.seq,1,0)
  FROM sch_book_list bl1,
   sch_appt_book ab,
   sch_book_list bl2,
   dummyt d,
   sch_resource r
  PLAN (bl1
   WHERE (bl1.resource_cd=t_record->resource_cd))
   JOIN (ab
   WHERE ab.appt_book_id=bl1.appt_book_id)
   JOIN (bl2
   WHERE bl2.appt_book_id=bl1.appt_book_id)
   JOIN (d
   WHERE d.seq=1)
   JOIN (r
   WHERE r.resource_cd=bl2.resource_cd)
  ORDER BY ab.mnemonic, bl2.seq_nbr
  HEAD ab.appt_book_id
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(t_record->book_qual,(count1+ 9))
   ENDIF
   count2 = 0, t_record->book_qual[count1].appt_book_id = ab.appt_book_id, t_record->book_qual[count1
   ].mnemonic = ab.mnemonic
  DETAIL
   count2 = (count2+ 1)
   IF (mod(count2,10)=1)
    stat = alterlist(t_record->book_qual[count1].book_list_qual,(count2+ 9))
   ENDIF
   t_record->book_qual[count1].book_list_qual[count2].resource_cd = bl2.resource_cd, t_record->
   book_qual[count1].book_list_qual[count2].res_exist_ind = res_exist, t_record->book_qual[count1].
   book_list_qual[count2].child_appt_book_id = bl2.child_appt_book_id,
   t_record->book_qual[count1].book_list_qual[count2].updt_cnt = bl2.updt_cnt, t_record->book_qual[
   count1].book_list_qual[count2].orig_seq_nbr = bl2.seq_nbr, t_record->book_qual[count1].
   book_list_qual[count2].new_seq_nbr = bl2.seq_nbr
  FOOT  ab.appt_book_id
   t_record->book_qual[count1].book_list_qual_cnt = count2, stat = alterlist(t_record->book_qual[
    count1].book_list_qual,count2)
  WITH outerjoin = d
 ;end select
 SET t_record->book_qual_cnt = count1
 SET stat = alterlist(t_record->book_qual,t_record->book_qual_cnt)
 SET t_record->book_del_cnt = 0
 SET t_record->book_cleanup_cnt = 0
 SET t_record->book_chg_cnt = 0
 FOR (i = 1 TO t_record->book_qual_cnt)
   SET next_seq_nbr = 0
   SET cur_del_cnt = 0
   SET cur_cleanup_cnt = 0
   SET cur_chg_cnt = 0
   FOR (j = 1 TO t_record->book_qual[i].book_list_qual_cnt)
     IF ((t_record->book_qual[i].book_list_qual[j].resource_cd=t_record->resource_cd))
      SET t_record->book_qual[i].book_list_qual[j].action = action_del
      SET cur_del_cnt = (cur_del_cnt+ 1)
     ELSEIF ((t_record->book_qual[i].book_list_qual[j].res_exist_ind=0))
      SET t_record->book_qual[i].book_list_qual[j].action = action_del
      SET cur_cleanup_cnt = (cur_cleanup_cnt+ 1)
     ELSE
      IF ((t_record->book_qual[i].book_list_qual[j].orig_seq_nbr != next_seq_nbr))
       SET t_record->book_qual[i].book_list_qual[j].new_seq_nbr = next_seq_nbr
       SET t_record->book_qual[i].book_list_qual[j].action = action_chg
       SET cur_chg_cnt = (cur_chg_cnt+ 1)
      ELSE
       SET t_record->book_qual[i].book_list_qual[j].action = action_none
      ENDIF
      SET next_seq_nbr = (next_seq_nbr+ 1)
     ENDIF
   ENDFOR
   IF (next_seq_nbr=0)
    SET t_record->book_qual[i].single_child_ind = 1
   ELSE
    SET t_record->book_qual[i].single_child_ind = 0
    SET t_record->book_del_cnt = ((t_record->book_del_cnt+ cur_del_cnt)+ cur_chg_cnt)
    SET t_record->book_cleanup_cnt = (t_record->book_cleanup_cnt+ cur_cleanup_cnt)
    SET t_record->book_chg_cnt = (t_record->book_chg_cnt+ cur_chg_cnt)
   ENDIF
 ENDFOR
 SET t_record->book_del_reply_cnt = 0
 SET t_record->book_chg_reply_cnt = 0
 IF (((t_record->book_del_cnt+ t_record->book_cleanup_cnt) > 0))
  SET stat = alterlist(del_book_list_request->qual,(t_record->book_del_cnt+ t_record->
   book_cleanup_cnt))
  SET del_book_list_request->call_echo_ind = 0
  SET n = 0
  FOR (i = 1 TO t_record->book_qual_cnt)
    IF ((t_record->book_qual[i].single_child_ind=0))
     FOR (j = 1 TO t_record->book_qual[i].book_list_qual_cnt)
       IF ((((t_record->book_qual[i].book_list_qual[j].action=action_del)) OR ((t_record->book_qual[i
       ].book_list_qual[j].action=action_chg))) )
        SET n = (n+ 1)
        SET del_book_list_request->qual[n].appt_book_id = t_record->book_qual[i].appt_book_id
        SET del_book_list_request->qual[n].seq_nbr = t_record->book_qual[i].book_list_qual[j].
        orig_seq_nbr
        SET del_book_list_request->qual[n].updt_cnt = t_record->book_qual[i].book_list_qual[j].
        updt_cnt
        SET del_book_list_request->qual[n].allow_partial_ind = 0
        SET del_book_list_request->qual[n].force_updt_ind = 1
       ENDIF
     ENDFOR
    ENDIF
  ENDFOR
  EXECUTE sch_del_book_list
  FOR (i = 1 TO del_book_list_reply->qual_cnt)
    IF ((del_book_list_reply->qual[i].status=true))
     SET t_record->book_del_reply_cnt = (t_record->book_del_reply_cnt+ 1)
    ENDIF
  ENDFOR
  SET tracking_name = "AMS_SCH_REMOVE_RESOURCE|APPOINTMENT BOOK - DELETE"
  CALL updtdminfo(tracking_name,cnvtreal(t_record->book_del_cnt))
  SET tracking_name = "AMS_SCH_REMOVE_RESOURCE|APPOINTMENT BOOK - CLEANUP"
  CALL updtdminfo(tracking_name,cnvtreal(t_record->book_cleanup_cnt))
 ENDIF
 IF ((t_record->book_chg_cnt > 0))
  SET stat = alterlist(add_book_list_request->qual,t_record->book_chg_cnt)
  SET add_book_list_request->call_echo_ind = 0
  SET n = 0
  FOR (i = 1 TO t_record->book_qual_cnt)
    IF ((t_record->book_qual[i].single_child_ind=0))
     FOR (j = 1 TO t_record->book_qual[i].book_list_qual_cnt)
       IF ((t_record->book_qual[i].book_list_qual[j].action=action_chg))
        SET n = (n+ 1)
        SET add_book_list_request->qual[n].appt_book_id = t_record->book_qual[i].appt_book_id
        SET add_book_list_request->qual[n].seq_nbr = t_record->book_qual[i].book_list_qual[j].
        new_seq_nbr
        SET add_book_list_request->qual[n].resource_cd = t_record->book_qual[i].book_list_qual[j].
        resource_cd
        SET add_book_list_request->qual[n].child_appt_book_id = t_record->book_qual[i].
        book_list_qual[j].child_appt_book_id
        SET add_book_list_request->qual[n].active_ind = 1
       ENDIF
     ENDFOR
    ENDIF
  ENDFOR
  EXECUTE sch_add_book_list
  FOR (i = 1 TO add_book_list_reply->qual_cnt)
    IF ((add_book_list_reply->qual[i].status=true))
     SET t_record->book_chg_reply_cnt = (t_record->book_chg_reply_cnt+ 1)
    ENDIF
  ENDFOR
 ENDIF
 SET count1 = 0
 SET count2 = 0
 SET t_record->res_group_qual_cnt = 0
 SELECT INTO "nl:"
  rl1.res_group_id, res_exist = decode(r.seq,1,0)
  FROM sch_res_list rl1,
   sch_res_group rg,
   sch_res_list rl2,
   dummyt d,
   sch_resource r
  PLAN (rl1
   WHERE (rl1.resource_cd=t_record->resource_cd))
   JOIN (rg
   WHERE rg.res_group_id=rl1.res_group_id)
   JOIN (rl2
   WHERE rl2.res_group_id=rl1.res_group_id)
   JOIN (d
   WHERE d.seq=1)
   JOIN (r
   WHERE r.resource_cd=rl2.resource_cd)
  ORDER BY rg.mnemonic, rl2.seq_nbr
  HEAD rg.res_group_id
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(t_record->res_group_qual,(count1+ 9))
   ENDIF
   count2 = 0, t_record->res_group_qual[count1].res_group_id = rg.res_group_id, t_record->
   res_group_qual[count1].mnemonic = rg.mnemonic
  DETAIL
   count2 = (count2+ 1)
   IF (mod(count2,10)=1)
    stat = alterlist(t_record->res_group_qual[count1].res_list_qual,(count2+ 9))
   ENDIF
   t_record->res_group_qual[count1].res_list_qual[count2].resource_cd = rl2.resource_cd, t_record->
   res_group_qual[count1].res_list_qual[count2].res_exist_ind = res_exist, t_record->res_group_qual[
   count1].res_list_qual[count2].child_res_group_id = rl2.child_res_group_id,
   t_record->res_group_qual[count1].res_list_qual[count2].updt_cnt = rl2.updt_cnt, t_record->
   res_group_qual[count1].res_list_qual[count2].orig_seq_nbr = rl2.seq_nbr, t_record->res_group_qual[
   count1].res_list_qual[count2].new_seq_nbr = rl2.seq_nbr
  FOOT  rg.res_group_id
   t_record->res_group_qual[count1].res_list_qual_cnt = count2, stat = alterlist(t_record->
    res_group_qual[count1].res_list_qual,count2)
  WITH outerjoin = d
 ;end select
 SET t_record->res_group_qual_cnt = count1
 SET stat = alterlist(t_record->res_group_qual,t_record->res_group_qual_cnt)
 SET t_record->res_group_del_cnt = 0
 SET t_record->res_group_cleanup_cnt = 0
 SET t_record->res_group_chg_cnt = 0
 FOR (i = 1 TO t_record->res_group_qual_cnt)
   SET next_seq_nbr = 0
   SET cur_del_cnt = 0
   SET cur_cleanup_cnt = 0
   SET cur_chg_cnt = 0
   FOR (j = 1 TO t_record->res_group_qual[i].res_list_qual_cnt)
     IF ((t_record->res_group_qual[i].res_list_qual[j].resource_cd=t_record->resource_cd))
      SET t_record->res_group_qual[i].res_list_qual[j].action = action_del
      SET cur_del_cnt = (cur_del_cnt+ 1)
     ELSEIF ((t_record->res_group_qual[i].res_list_qual[j].res_exist_ind=0))
      SET t_record->res_group_qual[i].res_list_qual[j].action = action_del
      SET cur_cleanup_cnt = (cur_cleanup_cnt+ 1)
     ELSE
      IF ((t_record->res_group_qual[i].res_list_qual[j].orig_seq_nbr != next_seq_nbr))
       SET t_record->res_group_qual[i].res_list_qual[j].new_seq_nbr = next_seq_nbr
       SET t_record->res_group_qual[i].res_list_qual[j].action = action_chg
       SET cur_chg_cnt = (cur_chg_cnt+ 1)
      ELSE
       SET t_record->res_group_qual[i].res_list_qual[j].action = action_none
      ENDIF
      SET next_seq_nbr = (next_seq_nbr+ 1)
     ENDIF
   ENDFOR
   IF (next_seq_nbr=0)
    SET t_record->res_group_qual[i].single_child_ind = 1
   ELSE
    SET t_record->res_group_qual[i].single_child_ind = 0
    SET t_record->res_group_del_cnt = ((t_record->res_group_del_cnt+ cur_del_cnt)+ cur_chg_cnt)
    SET t_record->res_group_cleanup_cnt = (t_record->res_group_cleanup_cnt+ cur_cleanup_cnt)
    SET t_record->res_group_chg_cnt = (t_record->res_group_chg_cnt+ cur_chg_cnt)
   ENDIF
 ENDFOR
 SET t_record->res_group_del_reply_cnt = 0
 SET t_record->res_group_chg_reply_cnt = 0
 IF (((t_record->res_group_del_cnt+ t_record->res_group_cleanup_cnt) > 0))
  SET stat = alterlist(del_res_list_request->qual,(t_record->res_group_del_cnt+ t_record->
   res_group_cleanup_cnt))
  SET del_res_list_request->call_echo_ind = 0
  SET n = 0
  FOR (i = 1 TO t_record->res_group_qual_cnt)
    IF ((t_record->res_group_qual[i].single_child_ind=0))
     FOR (j = 1 TO t_record->res_group_qual[i].res_list_qual_cnt)
       IF ((((t_record->res_group_qual[i].res_list_qual[j].action=action_del)) OR ((t_record->
       res_group_qual[i].res_list_qual[j].action=action_chg))) )
        SET n = (n+ 1)
        SET del_res_list_request->qual[n].res_group_id = t_record->res_group_qual[i].res_group_id
        SET del_res_list_request->qual[n].seq_nbr = t_record->res_group_qual[i].res_list_qual[j].
        orig_seq_nbr
        SET del_res_list_request->qual[n].updt_cnt = t_record->res_group_qual[i].res_list_qual[j].
        updt_cnt
        SET del_res_list_request->qual[n].allow_partial_ind = 0
        SET del_res_list_request->qual[n].force_updt_ind = 1
       ENDIF
     ENDFOR
    ENDIF
  ENDFOR
  EXECUTE sch_del_res_list
  FOR (i = 1 TO del_res_list_reply->qual_cnt)
    IF ((del_res_list_reply->qual[i].status=true))
     SET t_record->res_group_del_reply_cnt = (t_record->res_group_del_reply_cnt+ 1)
    ENDIF
  ENDFOR
  SET tracking_name = "AMS_SCH_REMOVE_RESOURCE|RESOURCE GROUP - DELETE"
  CALL updtdminfo(tracking_name,cnvtreal(t_record->res_group_del_cnt))
  SET tracking_name = "AMS_SCH_REMOVE_RESOURCE|RESOURCE GROUP - CLEANUP"
  CALL updtdminfo(tracking_name,cnvtreal(t_record->res_group_cleanup_cnt))
 ENDIF
 IF ((t_record->res_group_chg_cnt > 0))
  SET stat = alterlist(add_res_list_request->qual,t_record->res_group_chg_cnt)
  SET add_res_list_request->call_echo_ind = 0
  SET n = 0
  FOR (i = 1 TO t_record->res_group_qual_cnt)
    IF ((t_record->res_group_qual[i].single_child_ind=0))
     FOR (j = 1 TO t_record->res_group_qual[i].res_list_qual_cnt)
       IF ((t_record->res_group_qual[i].res_list_qual[j].action=action_chg))
        SET n = (n+ 1)
        SET add_res_list_request->qual[n].res_group_id = t_record->res_group_qual[i].res_group_id
        SET add_res_list_request->qual[n].seq_nbr = t_record->res_group_qual[i].res_list_qual[j].
        new_seq_nbr
        SET add_res_list_request->qual[n].resource_cd = t_record->res_group_qual[i].res_list_qual[j].
        resource_cd
        SET add_res_list_request->qual[n].child_res_group_id = t_record->res_group_qual[i].
        res_list_qual[j].child_res_group_id
        SET add_res_list_request->qual[n].active_ind = 1
       ENDIF
     ENDFOR
    ENDIF
  ENDFOR
  EXECUTE sch_add_res_list
  FOR (i = 1 TO add_res_list_reply->qual_cnt)
    IF ((add_res_list_reply->qual[i].status=true))
     SET t_record->res_group_chg_reply_cnt = (t_record->res_group_chg_reply_cnt+ 1)
    ENDIF
  ENDFOR
 ENDIF
 SET t_record->res_role_qual_cnt = 0
 SELECT INTO "nl:"
  a.sch_role_cd, a.role_meaning
  FROM sch_res_role a,
   sch_role r
  PLAN (a
   WHERE (a.resource_cd=t_record->resource_cd)
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
   ->res_role_qual_cnt].role_meaning = a.role_meaning,
   t_record->res_role_qual[t_record->res_role_qual_cnt].updt_cnt = a.updt_cnt
  WITH nocounter
 ;end select
 SET stat = alterlist(t_record->res_role_qual,t_record->res_role_qual_cnt)
 SELECT INTO "nl:"
  total = count(r.candidate_id)
  FROM (dummyt d  WITH seq = value(t_record->res_role_qual_cnt)),
   sch_res_role r
  PLAN (d
   WHERE (t_record->res_role_qual[d.seq].sch_role_cd > 0))
   JOIN (r
   WHERE (r.sch_role_cd=t_record->res_role_qual[d.seq].sch_role_cd)
    AND r.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  DETAIL
   IF (total > 1)
    t_record->res_role_qual[d.seq].single_child_ind = 0
   ELSE
    t_record->res_role_qual[d.seq].single_child_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SET t_record->res_role_reply_cnt = 0
 SET count = 0
 SET j = 0
 IF ((t_record->res_role_qual_cnt > 0))
  FOR (i = 1 TO t_record->res_role_qual_cnt)
    IF ((t_record->res_role_qual[i].single_child_ind=0))
     SET count = (count+ 1)
    ENDIF
  ENDFOR
  IF (count > 0)
   SET stat = alterlist(del_res_role_request->qual,count)
   SET del_res_role_request->call_echo_ind = 0
   FOR (i = 1 TO t_record->res_role_qual_cnt)
     IF ((t_record->res_role_qual[i].single_child_ind=0))
      SET j = (j+ 1)
      SET del_res_role_request->qual[j].resource_cd = t_record->resource_cd
      SET del_res_role_request->qual[j].sch_role_cd = t_record->res_role_qual[j].sch_role_cd
      SET del_res_role_request->qual[j].updt_cnt = t_record->res_role_qual[j].updt_cnt
      SET del_res_role_request->qual[j].allow_partial_ind = 0
      SET del_res_role_request->qual[j].force_updt_ind = 0
     ENDIF
   ENDFOR
   EXECUTE sch_del_res_role
   FOR (i = 1 TO del_res_role_reply->qual_cnt)
     IF ((del_res_role_reply->qual[i].status=true))
      SET t_record->res_role_reply_cnt = (t_record->res_role_reply_cnt+ 1)
     ENDIF
   ENDFOR
   SET tracking_name = "AMS_SCH_REMOVE_RESOURCE|RESOURCE ROLE - DELETE"
   CALL updtdminfo(tracking_name,cnvtreal(t_record->res_role_reply_cnt))
  ENDIF
 ENDIF
 SET count1 = 0
 SET count2 = 0
 SET count3 = 0
 SET t_record->list_role_qual_cnt = 0
 SELECT INTO "nl:"
  rl.mnemonic, res2.list_role_id, res2.resource_cd,
  res2.display_seq, res_exist = decode(r.seq,1,0), slot.slot_type_id
  FROM sch_list_res res,
   sch_list_role lr,
   sch_list_res res2,
   sch_list_slot slot,
   sch_resource_list rl,
   dummyt d,
   sch_resource r
  PLAN (res
   WHERE (res.resource_cd=t_record->resource_cd)
    AND res.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (lr
   WHERE lr.list_role_id=res.list_role_id
    AND lr.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (res2
   WHERE res2.list_role_id=lr.list_role_id
    AND res2.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (d
   WHERE d.seq=1)
   JOIN (r
   WHERE r.resource_cd=res2.resource_cd)
   JOIN (slot
   WHERE slot.list_role_id=res2.list_role_id
    AND slot.resource_cd=res2.resource_cd
    AND slot.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (rl
   WHERE rl.res_list_id=lr.res_list_id
    AND rl.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  ORDER BY res2.list_role_id, res2.display_seq, res2.resource_cd
  HEAD res2.list_role_id
   count1 = (count1+ 1), count2 = 0
   IF (mod(count1,10)=1)
    stat = alterlist(t_record->list_role_qual,(count1+ 9))
   ENDIF
   t_record->list_role_qual[count1].list_role_id = res2.list_role_id, t_record->list_role_qual[count1
   ].list_role_description = lr.description, t_record->list_role_qual[count1].res_list_id = rl
   .res_list_id,
   t_record->list_role_qual[count1].res_list_mnemonic = rl.mnemonic, t_record->list_role_qual[count1]
   .list_res_qual_cnt = 0
  HEAD res2.resource_cd
   count2 = (count2+ 1), count3 = 0
   IF (mod(count2,10)=1)
    stat = alterlist(t_record->list_role_qual[count1].list_res_qual,(count2+ 9))
   ENDIF
   t_record->list_role_qual[count1].list_res_qual[count2].resource_cd = res2.resource_cd, t_record->
   list_role_qual[count1].list_res_qual[count2].res_exist_ind = res_exist, t_record->list_role_qual[
   count1].list_res_qual[count2].display_seq = res2.display_seq,
   t_record->list_role_qual[count1].list_res_qual[count2].list_role_id = res2.list_role_id, t_record
   ->list_role_qual[count1].list_res_qual[count2].updt_cnt = res2.updt_cnt, t_record->list_role_qual[
   count1].list_res_qual[count2].pref_ind = res2.pref_ind,
   t_record->list_role_qual[count1].list_res_qual[count2].search_seq = res2.search_seq, t_record->
   list_role_qual[count1].list_res_qual[count2].selected_ind = res2.selected_ind, t_record->
   list_role_qual[count1].list_res_qual[count2].res_sch_cd = res2.res_sch_cd,
   t_record->list_role_qual[count1].list_res_qual[count2].res_sch_meaning = res2.res_sch_meaning,
   t_record->list_role_qual[count1].list_res_qual[count2].sch_flex_id = res2.sch_flex_id, t_record->
   list_role_qual[count1].list_res_qual[count2].list_slot_qual_cnt = 0
  DETAIL
   count3 = (count3+ 1)
   IF (mod(count3,10)=1)
    stat = alterlist(t_record->list_role_qual[count1].list_res_qual[count2].list_slot_qual,(count3+ 9
     ))
   ENDIF
   t_record->list_role_qual[count1].list_res_qual[count2].list_slot_qual[count3].slot_type_id = slot
   .slot_type_id, t_record->list_role_qual[count1].list_res_qual[count2].list_slot_qual[count3].
   updt_cnt = slot.updt_cnt
  FOOT  res2.resource_cd
   t_record->list_role_qual[count1].list_res_qual[count2].list_slot_qual_cnt = count3, stat =
   alterlist(t_record->list_role_qual[count1].list_res_qual[count2].list_slot_qual,count3)
  FOOT  res2.list_role_id
   t_record->list_role_qual[count1].list_res_qual_cnt = count2, stat = alterlist(t_record->
    list_role_qual[count1].list_res_qual,count2)
  WITH nocounter, outerjoin = d
 ;end select
 SET t_record->list_role_qual_cnt = count1
 SET stat = alterlist(t_record->list_role_qual,t_record->list_role_qual_cnt)
 SET t_record->list_res_del_cnt = 0
 SET t_record->list_res_cleanup_cnt = 0
 SET t_record->list_res_chg_cnt = 0
 SET t_record->list_slot_del_cnt = 0
 SET t_record->list_res_del_reply_cnt = 0
 SET t_record->list_res_cleanup_reply_cnt = 0
 SET t_record->list_res_chg_reply_cnt = 0
 SET t_record->list_slot_del_reply_cnt = 0
 FOR (i = 1 TO t_record->list_role_qual_cnt)
   SET next_seq_nbr = 0
   SET cur_del_cnt = 0
   SET cur_cleanup_cnt = 0
   SET cur_chg_cnt = 0
   SET slot_count = 0
   FOR (j = 1 TO t_record->list_role_qual[i].list_res_qual_cnt)
    IF ((t_record->list_role_qual[i].list_res_qual[j].resource_cd=t_record->resource_cd))
     SET t_record->list_role_qual[i].list_res_qual[j].action = action_del
     SET cur_del_cnt = (cur_del_cnt+ 1)
    ELSEIF ((t_record->list_role_qual[i].list_res_qual[j].res_exist_ind=0))
     SET t_record->list_role_qual[i].list_res_qual[j].action = action_del
     SET cur_cleanup_cnt = (cur_cleanup_cnt+ 1)
    ELSE
     IF ((t_record->list_role_qual[i].list_res_qual[j].display_seq != next_seq_nbr))
      SET t_record->list_role_qual[i].list_res_qual[j].display_seq = next_seq_nbr
      SET t_record->list_role_qual[i].list_res_qual[j].action = action_chg
      SET cur_chg_cnt = (cur_chg_cnt+ 1)
     ELSE
      SET t_record->list_role_qual[i].list_res_qual[j].action = action_none
     ENDIF
     SET next_seq_nbr = (next_seq_nbr+ 1)
    ENDIF
    SET slot_count = t_record->list_role_qual[i].list_res_qual[j].list_slot_qual_cnt
   ENDFOR
   IF (next_seq_nbr=0)
    SET t_record->list_role_qual[i].single_child_ind = 1
   ELSE
    SET t_record->list_role_qual[i].single_child_ind = 0
    SET t_record->list_res_del_cnt = (t_record->list_res_del_cnt+ cur_del_cnt)
    SET t_record->list_res_cleanup_cnt = (t_record->list_res_cleanup_cnt+ cur_cleanup_cnt)
    SET t_record->list_res_chg_cnt = (t_record->list_res_chg_cnt+ cur_chg_cnt)
    SET t_record->list_slot_del_cnt = (t_record->list_slot_del_cnt+ ((cur_del_cnt+ cur_cleanup_cnt)
     * slot_count))
   ENDIF
 ENDFOR
 SET t_record->list_res_del_reply_cnt = 0
 SET t_record->list_res_chg_reply_cnt = 0
 SET t_record->list_res_cleanup_reply_cnt = 0
 SET t_record->list_slot_del_reply_cnt = 0
 IF (((t_record->list_res_del_cnt+ t_record->list_res_cleanup_cnt) > 0))
  SET del_list_res_request->call_echo_ind = 0
  SET stat = alterlist(del_list_res_request->qual,(t_record->list_res_del_cnt+ t_record->
   list_res_cleanup_cnt))
 ENDIF
 IF ((t_record->list_res_chg_cnt > 0))
  SET chg_list_res_request->call_echo_ind = 0
  SET stat = alterlist(chg_list_res_request->qual,t_record->list_res_chg_cnt)
 ENDIF
 IF ((t_record->list_slot_del_cnt > 0))
  SET del_list_slot_request->call_echo_ind = 0
  SET stat = alterlist(del_list_slot_request->qual,t_record->list_slot_del_cnt)
 ENDIF
 SET k1 = 0
 SET k2 = 0
 SET k3 = 0
 IF ((t_record->list_role_qual_cnt > 0))
  FOR (i = 1 TO t_record->list_role_qual_cnt)
    IF ((t_record->list_role_qual[i].single_child_ind=0))
     FOR (j = 1 TO t_record->list_role_qual[i].list_res_qual_cnt)
       IF ((t_record->list_role_qual[i].list_res_qual[j].action=action_del))
        SET k1 = (k1+ 1)
        SET del_list_res_request->qual[k1].list_role_id = t_record->list_role_qual[i].list_res_qual[j
        ].list_role_id
        SET del_list_res_request->qual[k1].resource_cd = t_record->list_role_qual[i].list_res_qual[j]
        .resource_cd
        SET del_list_res_request->qual[k1].updt_cnt = t_record->list_role_qual[i].list_res_qual[j].
        updt_cnt
        SET del_list_res_request->qual[k1].allow_partial_ind = 0
        SET del_list_res_request->qual[k1].force_updt_ind = 0
        FOR (n = 1 TO t_record->list_role_qual[i].list_res_qual[j].list_slot_qual_cnt)
          SET k3 = (k3+ 1)
          SET del_list_slot_request->qual[k3].list_role_id = t_record->list_role_qual[i].
          list_res_qual[j].list_role_id
          SET del_list_slot_request->qual[k3].resource_cd = t_record->list_role_qual[i].
          list_res_qual[j].resource_cd
          SET del_list_slot_request->qual[k3].slot_type_id = t_record->list_role_qual[i].
          list_res_qual[j].list_slot_qual[n].slot_type_id
          SET del_list_slot_request->qual[k3].updt_cnt = t_record->list_role_qual[i].list_res_qual[j]
          .list_slot_qual[n].updt_cnt
          SET del_list_res_request->qual[k3].allow_partial_ind = 0
          SET del_list_res_request->qual[k3].force_updt_ind = 0
        ENDFOR
       ELSEIF ((t_record->list_role_qual[i].list_res_qual[j].action=action_chg))
        SET k2 = (k2+ 1)
        SET chg_list_res_request->qual[k2].list_role_id = t_record->list_role_qual[i].list_res_qual[j
        ].list_role_id
        SET chg_list_res_request->qual[k2].resource_cd = t_record->list_role_qual[i].list_res_qual[j]
        .resource_cd
        SET chg_list_res_request->qual[k2].version_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
        SET chg_list_res_request->qual[k2].updt_cnt = t_record->list_role_qual[i].list_res_qual[j].
        updt_cnt
        SET chg_list_res_request->qual[k2].display_seq = t_record->list_role_qual[i].list_res_qual[j]
        .display_seq
        SET chg_list_res_request->qual[k2].pref_ind = t_record->list_role_qual[i].list_res_qual[j].
        pref_ind
        SET chg_list_res_request->qual[k2].search_seq = t_record->list_role_qual[i].list_res_qual[j].
        search_seq
        SET chg_list_res_request->qual[k2].selected_ind = t_record->list_role_qual[i].list_res_qual[j
        ].selected_ind
        SET chg_list_res_request->qual[k2].res_sch_cd = t_record->list_role_qual[i].list_res_qual[j].
        res_sch_cd
        SET chg_list_res_request->qual[k2].res_sch_meaning = t_record->list_role_qual[i].
        list_res_qual[j].res_sch_meaning
        SET chg_list_res_request->qual[k2].sch_flex_id = t_record->list_role_qual[i].list_res_qual[j]
        .sch_flex_id
        SET chg_list_res_request->qual[k2].allow_partial_ind = 1
        SET chg_list_res_request->qual[k2].version_ind = 1
        SET chg_list_res_request->qual[k2].force_updt_ind = 1
       ENDIF
     ENDFOR
    ENDIF
  ENDFOR
 ENDIF
 IF (size(del_list_res_request->qual,5) > 0)
  EXECUTE sch_del_list_res
  FOR (i = 1 TO del_list_res_reply->qual_cnt)
    IF ((del_list_res_reply->qual[i].status=true))
     SET t_record->list_res_del_reply_cnt = (t_record->list_res_del_reply_cnt+ 1)
    ENDIF
  ENDFOR
  SET tracking_name = "AMS_SCH_REMOVE_RESOURCE|RESOURCE LIST RES - DELETE"
  CALL updtdminfo(tracking_name,cnvtreal(t_record->list_res_del_reply_cnt))
 ENDIF
 IF (size(chg_list_res_request->qual,5) > 0)
  EXECUTE sch_chg_list_res
  FOR (i = 1 TO chg_list_res_reply->qual_cnt)
    IF ((chg_list_res_reply->qual[i].status=true))
     SET t_record->list_res_chg_reply_cnt = (t_record->list_res_chg_reply_cnt+ 1)
    ENDIF
  ENDFOR
 ENDIF
 IF (size(del_list_slot_request->qual,5) > 0)
  EXECUTE sch_del_list_slot
  FOR (i = 1 TO del_list_slot_reply->qual_cnt)
    IF ((del_list_slot_reply->qual[i].status=true))
     SET t_record->list_slot_del_reply_cnt = (t_record->list_slot_del_reply_cnt+ 1)
    ENDIF
  ENDFOR
 ENDIF
 SET count1 = 0
 SET t_record->def_res_qual_cnt = 0
 SELECT INTO "nl:"
  r.resource_cd
  FROM sch_def_res r,
   sch_def_sched s
  PLAN (r
   WHERE (r.resource_cd=t_record->resource_cd))
   JOIN (s
   WHERE s.def_sched_id=r.def_sched_id)
  ORDER BY s.mnemonic
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(t_record->def_res_qual,(count1+ 9))
   ENDIF
   t_record->def_res_qual[count1].def_sched_id = r.def_sched_id, t_record->def_res_qual[count1].
   mnemonic = s.mnemonic, t_record->def_res_qual[count1].updt_cnt = r.updt_cnt
  WITH nocounter
 ;end select
 SET t_record->def_res_qual_cnt = count1
 SET stat = alterlist(t_record->def_res_qual,t_record->def_res_qual_cnt)
 SET t_record->def_res_reply_cnt = 0
 IF ((t_record->def_res_qual_cnt > 0))
  SET stat = alterlist(del_def_res_request->qual,t_record->def_res_qual_cnt)
  SET del_def_res_request->call_echo_ind = 0
  FOR (i = 1 TO t_record->def_res_qual_cnt)
    SET del_def_res_request->qual[i].def_sched_id = t_record->def_res_qual[i].def_sched_id
    SET del_def_res_request->qual[i].resource_cd = t_record->resource_cd
    SET del_def_res_request->qual[i].updt_id = t_record->def_res_qual[i].updt_id
    SET del_def_res_request->qual[i].allow_partial_ind = 0
    SET del_def_res_request->qual[i].force_updt_ind = 0
  ENDFOR
  EXECUTE sch_del_def_res
  FOR (i = 1 TO del_def_res_reply->qual_cnt)
    IF ((del_def_res_reply->qual[i].status=true))
     SET t_record->def_res_reply_cnt = (t_record->def_res_reply_cnt+ 1)
    ENDIF
  ENDFOR
  SET tracking_name = "AMS_SCH_REMOVE_RESOURCE|TEMPLATE - DELETE"
  CALL updtdminfo(tracking_name,cnvtreal(t_record->def_res_reply_cnt))
 ENDIF
 SET t_record->block_qual_cnt = 0
 SET count1 = 0
 SELECT INTO "nl:"
  a.resource_cd
  FROM sch_def_apply a,
   sch_freq f,
   sch_def_sched s
  PLAN (a
   WHERE (a.resource_cd=t_record->resource_cd)
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND a.def_state_meaning="ACTIVE"
    AND a.active_ind=1
    AND a.end_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (f
   WHERE f.frequency_id=a.frequency_id
    AND f.freq_state_meaning="ACTIVE")
   JOIN (s
   WHERE s.def_sched_id=a.def_sched_id)
  ORDER BY s.mnemonic, a.beg_dt_tm
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(t_record->block_qual,(count1+ 9))
   ENDIF
   t_record->block_qual[count1].def_apply_id = a.def_apply_id, t_record->block_qual[count1].
   frequency_id = a.frequency_id, t_record->block_qual[count1].beg_dt_tm = a.beg_dt_tm,
   t_record->block_qual[count1].end_dt_tm = a.end_dt_tm, t_record->block_qual[count1].mnemonic = s
   .mnemonic, t_record->block_qual[count1].apply_range = f.apply_range
  WITH nocounter
 ;end select
 SET t_record->block_qual_cnt = count1
 SET stat = alterlist(t_record->block_qual,t_record->block_qual_cnt)
 SET t_record->block_reply_cnt = 0
 IF ((t_record->block_qual_cnt > 0))
  SET stat = alterlist(chgw_block_request->qual,t_record->block_qual_cnt)
  SET chgw_block_request->call_echo_ind = 0
  SET chgw_block_request->conversation_id = 0
  SET chgw_block_request->allow_partial_ind = 0
  FOR (i = 1 TO t_record->block_qual_cnt)
    SET chgw_block_request->qual[i].sch_action_cd = 0
    SET chgw_block_request->qual[i].action_meaning = "COMPLETE"
    SET chgw_block_request->qual[i].def_apply_id = t_record->block_qual[i].def_apply_id
    SET chgw_block_request->qual[i].frequency_id = t_record->block_qual[i].frequency_id
    SET chgw_block_request->qual[i].end_dt_tm = cnvtdatetime(curdate,0)
    SET chgw_block_request->qual[i].end_type_cd = 0
    SET chgw_block_request->qual[i].end_type_meaning = "DATE"
    SET chgw_block_request->qual[i].mac_occurance = 0
  ENDFOR
  EXECUTE sch_chgw_block
  FOR (i = 1 TO chgw_block_reply->qual_cnt)
    IF ((chgw_block_reply->qual[i].status=true))
     SET t_record->block_reply_cnt = (t_record->block_reply_cnt+ 1)
    ENDIF
  ENDFOR
  SET tracking_name = "AMS_SCH_REMOVE_RESOURCE|DEFAULT SCHEDULE APPLICATION - END DATE"
  CALL updtdminfo(tracking_name,cnvtreal(t_record->block_reply_cnt))
 ENDIF
#report_section
 SET cur_row = 1
 SELECT INTO  $1
  FROM dummyt d
  DETAIL
   row cur_row, col 45, "Resource Association Removal Report"
   IF ((reply->status_data.status="F"))
    cur_row = (cur_row+ 3), row cur_row, col 10,
    reply->status_data.subeventstatus.targetobjectvalue
   ELSEIF ((reply->status_data.status="S"))
    cur_row = (cur_row+ 3), row cur_row, col 25,
    "No future patient appointment found for the selected resource", cur_row = (cur_row+ 1), row
    cur_row,
    col 5, "Mnemonic:", col 20,
    t_record->mnemonic, cur_row = (cur_row+ 1), row cur_row,
    col 5, "Resource Type:"
    IF ((t_record->res_type_flag=1))
     col 20, "General"
    ELSEIF ((t_record->res_type_flag=2))
     col 20, "Personnel"
    ENDIF
    IF ((t_record->person_id > 0))
     cur_row = (cur_row+ 1), row cur_row, col 5,
     "Personnel:", col 20, t_record->name_full_formatted
    ENDIF
    cur_row = (cur_row+ 1), row cur_row, col 5,
    "____________________________________________________________________________________________________________________",
    cur_row = (cur_row+ 3), row cur_row,
    col 5, "Appt Book Assoc Found: ", col 35,
    t_record->book_qual_cnt
    IF ((t_record->book_qual_cnt > 0))
     cur_row = (cur_row+ 1), row cur_row, col 8,
     "Appt Books:", col 35, "Mnemonic",
     cur_row = (cur_row+ 1), row cur_row, col 35,
     "--------"
     FOR (i = 1 TO t_record->book_qual_cnt)
       cur_row = (cur_row+ 1), row cur_row, temp_string = substring(1,29,t_record->book_qual[i].
        mnemonic),
       col 35, temp_string
       IF ((t_record->book_qual[i].single_child_ind=0))
        col 100, " - removed"
       ELSE
        col 100, " - not removed, last item left"
       ENDIF
     ENDFOR
    ENDIF
    cur_row = (cur_row+ 2), row cur_row, col 5,
    "Resource Group Assoc Found: ", col 35, t_record->res_group_qual_cnt
    IF ((t_record->res_group_qual_cnt > 0))
     cur_row = (cur_row+ 1), row cur_row, col 8,
     "Resource Groups:", col 35, "Mnemonic",
     cur_row = (cur_row+ 1), row cur_row, col 35,
     "--------"
     FOR (i = 1 TO t_record->res_group_qual_cnt)
       cur_row = (cur_row+ 1), row cur_row, temp_string = substring(1,29,t_record->res_group_qual[i].
        mnemonic),
       col 35, temp_string
       IF ((t_record->res_group_qual[i].single_child_ind=0))
        col 100, " - removed"
       ELSE
        col 100, " - not removed, last item left"
       ENDIF
     ENDFOR
    ENDIF
    cur_row = (cur_row+ 2), row cur_row, col 5,
    "Resource Role Assoc Found: ", col 35, t_record->res_role_qual_cnt
    IF ((t_record->res_role_qual_cnt > 0))
     cur_row = (cur_row+ 1), row cur_row, col 8,
     "Resource Roles:", col 35, "Mnemonic",
     cur_row = (cur_row+ 1), row cur_row, col 35,
     "--------"
     FOR (i = 1 TO t_record->res_role_qual_cnt)
       cur_row = (cur_row+ 1), row cur_row, temp_string = substring(1,29,t_record->res_role_qual[i].
        mnemonic),
       col 35, temp_string
       IF ((t_record->res_role_qual[i].single_child_ind=0))
        col 100, " - removed"
       ELSE
        col 100, " - not removed, last item left"
       ENDIF
     ENDFOR
    ENDIF
    cur_row = (cur_row+ 2), row cur_row, col 5,
    "Resource List Assoc Found: ", col 35, t_record->list_role_qual_cnt
    IF ((t_record->list_role_qual_cnt > 0))
     cur_row = (cur_row+ 1), row cur_row, col 8,
     "Resource Lists:", col 35, "Res List Mnemonic",
     col 70, "Role Description", cur_row = (cur_row+ 1),
     row cur_row, col 35, "-----------------",
     col 70, "----------------"
     FOR (i = 1 TO t_record->list_role_qual_cnt)
       cur_row = (cur_row+ 1), row cur_row
       IF ((t_record->list_role_qual[i].res_list_id=0))
        col 35, "(Order Role Only)"
       ELSE
        temp_string = substring(1,29,t_record->list_role_qual[i].res_list_mnemonic), col 35,
        temp_string
       ENDIF
       temp_string = substring(1,29,t_record->list_role_qual[i].list_role_description), col 70,
       temp_string
       IF ((t_record->list_role_qual[i].single_child_ind=0))
        col 100, " - removed"
       ELSE
        col 100, " - not removed, last item left"
       ENDIF
     ENDFOR
    ENDIF
    cur_row = (cur_row+ 2), row cur_row, col 5,
    "Template Assoc Found: ", col 35, t_record->def_res_qual_cnt
    IF ((t_record->def_res_qual_cnt > 0))
     cur_row = (cur_row+ 1), row cur_row, col 8,
     "Templates:", col 35, "Mnemonic",
     cur_row = (cur_row+ 1), row cur_row, col 35,
     "--------"
     FOR (i = 1 TO t_record->def_res_qual_cnt)
       cur_row = (cur_row+ 1), row cur_row, temp_string = substring(1,29,t_record->def_res_qual[i].
        mnemonic),
       col 35, temp_string, col 100,
       " - removed"
     ENDFOR
    ENDIF
    cur_row = (cur_row+ 2), row cur_row, col 5,
    "Template Applications Found: ", col 35, t_record->block_qual_cnt
    IF ((t_record->block_qual_cnt > 0))
     cur_row = (cur_row+ 1), row cur_row, col 8,
     "Applications:", col 35, "Template",
     col 70, "Begin date/time", cur_row = (cur_row+ 1),
     row cur_row, col 35, "--------",
     col 70, "---------------"
     FOR (i = 1 TO t_record->block_qual_cnt)
       cur_row = (cur_row+ 1), row cur_row, temp_string = substring(1,29,t_record->block_qual[i].
        mnemonic),
       col 35, temp_string, col 71,
       t_record->block_qual[i].beg_dt_tm"@SHORTDATE", col 80, t_record->block_qual[i].beg_dt_tm
       "@TIMENOSECONDS",
       col 100, " - end dated"
     ENDFOR
    ENDIF
   ELSE
    cur_row = (cur_row+ 3), row cur_row, col 10,
    "Unexpected error, please write down the resource you tried to copy from and contact support"
   ENDIF
  WITH nocounter, format, maxrow = 10000,
   maxcol = 132
 ;end select
#exit_script
END GO
