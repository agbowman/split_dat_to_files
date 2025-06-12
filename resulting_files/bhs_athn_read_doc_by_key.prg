CREATE PROGRAM bhs_athn_read_doc_by_key
 RECORD orequest(
   1 query_mode = i4
   1 query_mode_ind = i2
   1 event_id = f8
   1 contributor_system_cd = f8
   1 reference_nbr = vc
   1 dataset_uid = vc
   1 subtable_bit_map = i4
   1 subtable_bit_map_ind = i2
   1 valid_from_dt_tm = dq8
   1 valid_from_dt_tm_ind = i2
   1 decode_flag = i2
   1 ordering_provider_id = f8
   1 action_prsnl_id = f8
   1 event_id_list[*]
     2 event_id = f8
   1 action_type_cd_list[*]
     2 action_type_cd = f8
   1 src_event_id_ind = i2
   1 action_prsnl_group_id = f8
   1 query_mode2 = i4
   1 event_uuid = vc
 )
 RECORD out_rec(
   1 event_id = vc
   1 event_code = vc
   1 event_code_disp = vc
   1 event_end_dt_tm = dq8
   1 person_id = vc
   1 encounter_id = vc
   1 result_status_disp = vc
   1 result_status_mean = vc
   1 result_status_value = vc
   1 order_id = vc
   1 update_dt_tm = dq8
   1 view_level = vc
   1 event_tag = vc
   1 contrib_sys_disp = vc
   1 contrib_sys_mean = vc
   1 contrib_sys_value = vc
   1 parent_event_id = vc
   1 record_status_disp = vc
   1 record_status_mean = vc
   1 record_status_value = vc
   1 publish = vc
   1 title_text = vc
   1 update_cnt = vc
   1 entry_mode_disp = vc
   1 entry_mode_mean = vc
   1 entry_mode_value = vc
   1 document[*]
     2 event_id = vc
     2 event_disp = vc
     2 event_mean = vc
     2 event_value = vc
     2 succession_type_disp = vc
     2 succession_type_mean = vc
     2 succession_type_value = vc
     2 storage_disp = vc
     2 storage_mean = vc
     2 storage_value = vc
     2 format_disp = vc
     2 format_mean = vc
     2 format_value = vc
     2 body = vc
     2 length = vc
     2 collating_sequence = vc
   1 event_prsnl[*]
     2 event_id = vc
     2 event_prsnl_action_id = vc
     2 action_type_disp = vc
     2 action_type_mean = vc
     2 action_type_value = vc
     2 action_dt_tm = dq8
     2 action_status_disp = vc
     2 action_status_mean = vc
     2 action_status_value = vc
     2 action_prsnl_id = vc
     2 request_prsnl_id = vc
     2 proxy_prsnl_id = vc
 )
 SET orequest->event_id =  $2
 DECLARE event_prsnl_ind = i2
 SET event_prsnl_ind =  $3
 SET orequest->query_mode = 2
 SET orequest->valid_from_dt_tm_ind = 1
 SET orequest->decode_flag = 1
 SET orequest->subtable_bit_map_ind = 1
 SET stat = tdbexecute(3200000,3200200,1000011,"REC",orequest,
  "REC",oreply)
 CALL echorecord(oreply)
 SET out_rec->event_id = cnvtstring(oreply->rb_list[1].event_id)
 SET out_rec->event_code = cnvtstring(oreply->rb_list[1].event_cd)
 SET out_rec->event_code_disp = uar_get_code_display(oreply->rb_list[1].event_cd)
 SET out_rec->event_end_dt_tm = oreply->rb_list[1].event_end_dt_tm
 SET out_rec->person_id = cnvtstring(oreply->rb_list[1].person_id)
 SET out_rec->encounter_id = cnvtstring(oreply->rb_list[1].encntr_id)
 SET out_rec->result_status_disp = uar_get_code_display(oreply->rb_list[1].result_status_cd)
 SET out_rec->result_status_mean = uar_get_code_meaning(oreply->rb_list[1].result_status_cd)
 SET out_rec->result_status_value = cnvtstring(oreply->rb_list[1].result_status_cd)
 SET out_rec->order_id = cnvtstring(oreply->rb_list[1].order_id)
 SET out_rec->update_dt_tm = oreply->rb_list[1].updt_dt_tm
 SET out_rec->view_level = cnvtstring(oreply->rb_list[1].view_level)
 SET out_rec->event_tag = oreply->rb_list[1].event_tag
 SET out_rec->contrib_sys_disp = uar_get_code_display(oreply->rb_list[1].contributor_system_cd)
 SET out_rec->contrib_sys_mean = uar_get_code_meaning(oreply->rb_list[1].contributor_system_cd)
 SET out_rec->contrib_sys_value = cnvtstring(oreply->rb_list[1].contributor_system_cd)
 SET out_rec->parent_event_id = cnvtstring(oreply->rb_list[1].parent_event_id)
 SET out_rec->record_status_disp = uar_get_code_display(oreply->rb_list[1].record_status_cd)
 SET out_rec->record_status_mean = uar_get_code_meaning(oreply->rb_list[1].record_status_cd)
 SET out_rec->record_status_value = cnvtstring(oreply->rb_list[1].record_status_cd)
 SET out_rec->publish = cnvtstring(oreply->rb_list[1].publish_flag)
 SET out_rec->update_cnt = cnvtstring(oreply->rb_list[1].updt_cnt)
 SET out_rec->entry_mode_disp = uar_get_code_display(oreply->rb_list[1].entry_mode_cd)
 SET out_rec->entry_mode_mean = uar_get_code_meaning(oreply->rb_list[1].entry_mode_cd)
 SET out_rec->entry_mode_value = cnvtstring(oreply->rb_list[1].entry_mode_cd)
 SET out_rec->title_text = oreply->rb_list[1].event_title_text
 SET stat = alterlist(out_rec->document,size(oreply->rb_list[1].child_event_list,5))
 FOR (i = 1 TO size(oreply->rb_list[1].child_event_list,5))
   SET out_rec->document[i].event_id = cnvtstring(oreply->rb_list[1].child_event_list[i].event_id)
   SET out_rec->document[i].event_disp = uar_get_code_display(oreply->rb_list[1].child_event_list[i].
    event_cd)
   SET out_rec->document[i].event_mean = uar_get_code_meaning(oreply->rb_list[1].child_event_list[i].
    event_cd)
   SET out_rec->document[i].event_value = cnvtstring(oreply->rb_list[1].child_event_list[i].event_cd)
   SET out_rec->document[i].succession_type_disp = uar_get_code_display(oreply->rb_list[1].
    child_event_list[i].blob_result[1].succession_type_cd)
   SET out_rec->document[i].succession_type_mean = uar_get_code_meaning(oreply->rb_list[1].
    child_event_list[i].blob_result[1].succession_type_cd)
   SET out_rec->document[i].succession_type_value = cnvtstring(oreply->rb_list[1].child_event_list[i]
    .blob_result[1].succession_type_cd)
   SET out_rec->document[i].storage_disp = uar_get_code_display(oreply->rb_list[1].child_event_list[i
    ].blob_result[1].storage_cd)
   SET out_rec->document[i].storage_mean = uar_get_code_meaning(oreply->rb_list[1].child_event_list[i
    ].blob_result[1].storage_cd)
   SET out_rec->document[i].storage_value = cnvtstring(oreply->rb_list[1].child_event_list[i].
    blob_result[1].storage_cd)
   SET out_rec->document[i].format_disp = uar_get_code_display(oreply->rb_list[1].child_event_list[i]
    .blob_result[1].format_cd)
   SET out_rec->document[i].format_mean = uar_get_code_meaning(oreply->rb_list[1].child_event_list[i]
    .blob_result[1].format_cd)
   SET out_rec->document[i].format_value = cnvtstring(oreply->rb_list[1].child_event_list[i].
    blob_result[1].format_cd)
   IF (size(oreply->rb_list[1].child_event_list[i].blob_result[1].blob,5) > 0)
    SET out_rec->document[i].body = oreply->rb_list[1].child_event_list[i].blob_result[1].blob[1].
    blob_contents
    SET out_rec->document[i].length = cnvtstring(oreply->rb_list[1].child_event_list[i].blob_result[1
     ].blob[1].blob_length)
    SET out_rec->document[i].collating_sequence = oreply->rb_list[1].child_event_list[i].
    collating_seq
   ENDIF
 ENDFOR
 IF (event_prsnl_ind=1)
  SET stat = alterlist(out_rec->event_prsnl,size(oreply->rb_list[1].event_prsnl_list,5))
  FOR (j = 1 TO size(oreply->rb_list[1].event_prsnl_list,5))
    SET out_rec->event_prsnl[j].event_id = cnvtstring(oreply->rb_list[1].event_prsnl_list[j].event_id
     )
    SET out_rec->event_prsnl[j].event_prsnl_action_id = cnvtstring(oreply->rb_list[1].
     event_prsnl_list[j].event_prsnl_id)
    SET out_rec->event_prsnl[j].action_type_disp = uar_get_code_display(oreply->rb_list[1].
     event_prsnl_list[j].action_type_cd)
    SET out_rec->event_prsnl[j].action_type_mean = uar_get_code_meaning(oreply->rb_list[1].
     event_prsnl_list[j].action_type_cd)
    SET out_rec->event_prsnl[j].action_type_value = cnvtstring(oreply->rb_list[1].event_prsnl_list[j]
     .action_type_cd)
    SET out_rec->event_prsnl[j].action_dt_tm = oreply->rb_list[1].event_prsnl_list[j].action_dt_tm
    SET out_rec->event_prsnl[j].action_status_disp = uar_get_code_display(oreply->rb_list[1].
     event_prsnl_list[j].action_status_cd)
    SET out_rec->event_prsnl[j].action_status_mean = uar_get_code_meaning(oreply->rb_list[1].
     event_prsnl_list[j].action_status_cd)
    SET out_rec->event_prsnl[j].action_status_value = cnvtstring(oreply->rb_list[1].event_prsnl_list[
     j].action_status_cd)
    SET out_rec->event_prsnl[j].action_prsnl_id = cnvtstring(oreply->rb_list[1].event_prsnl_list[j].
     action_prsnl_id)
    SET out_rec->event_prsnl[j].request_prsnl_id = cnvtstring(oreply->rb_list[1].event_prsnl_list[j].
     request_prsnl_id)
    SET out_rec->event_prsnl[j].proxy_prsnl_id = cnvtstring(oreply->rb_list[1].event_prsnl_list[j].
     proxy_prsnl_id)
  ENDFOR
 ENDIF
 CALL echojson(out_rec, $1)
END GO
