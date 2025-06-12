CREATE PROGRAM bhs_athn_read_doc_by_key_v3
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
 RECORD t_record(
   1 event_id = vc
   1 event_code = vc
   1 event_code_disp = vc
   1 event_end_dt_tm = vc
   1 person_id = vc
   1 encounter_id = vc
   1 result_status_disp = vc
   1 result_status_mean = vc
   1 result_status_value = vc
   1 order_id = vc
   1 catalog_cd = vc
   1 catalog_disp = vc
   1 update_dt_tm = vc
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
   1 body = vc
   1 length = vc
   1 format_disp = vc
   1 format_mean = vc
   1 format_value = vc
   1 event_note[*]
     2 event_note_id = vc
     2 event_id = vc
     2 note = vc
     2 note_dt_tm = vc
     2 note_prsnl_id = vc
     2 note_prsnl = vc
     2 importance_flag = vc
     2 non_chartable_ind = vc
     2 note_type_cd = vc
     2 note_type_disp = vc
     2 note_type_mean = vc
     2 note_format_cd = vc
     2 note_format_disp = vc
     2 note_format_mean = vc
     2 entry_method_cd = vc
     2 entry_method_disp = vc
     2 entry_method_mean = vc
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
     2 url = vc
     2 body = vc
     2 length = vc
     2 title_text = vc
     2 collating_sequence = vc
     2 update_dt_tm = vc
     2 attachment[*]
       3 event_id = vc
       3 title_text = vc
       3 storage_disp = vc
       3 storage_mean = vc
       3 storage_value = vc
       3 format_disp = vc
       3 format_mean = vc
       3 format_value = vc
       3 body = vc
       3 update_dt_tm = vc
   1 event_prsnl[*]
     2 event_id = vc
     2 event_prsnl_action_id = vc
     2 action_type_disp = vc
     2 action_type_mean = vc
     2 action_type_value = vc
     2 action_dt_tm = vc
     2 request_dt_tm = vc
     2 action_status_disp = vc
     2 action_status_mean = vc
     2 action_status_value = vc
     2 action_prsnl_id = vc
     2 action_prsnl = vc
     2 request_prsnl_id = vc
     2 request_prsnl = vc
     2 proxy_prsnl_id = vc
     2 proxy_prsnl = vc
 )
 RECORD out_rec(
   1 event_id = vc
   1 event_code = vc
   1 event_code_disp = vc
   1 event_end_dt_tm = vc
   1 person_id = vc
   1 encounter_id = vc
   1 result_status_disp = vc
   1 result_status_mean = vc
   1 result_status_value = vc
   1 order_id = vc
   1 catalog_cd = vc
   1 catalog_disp = vc
   1 update_dt_tm = vc
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
   1 body = vc
   1 length = vc
   1 format_disp = vc
   1 format_mean = vc
   1 format_value = vc
   1 event_note[*]
     2 event_note_id = vc
     2 event_id = vc
     2 note = vc
     2 note_dt_tm = vc
     2 note_prsnl_id = vc
     2 note_prsnl = vc
     2 importance_flag = vc
     2 non_chartable_ind = vc
     2 note_type_cd = vc
     2 note_type_disp = vc
     2 note_type_mean = vc
     2 note_format_cd = vc
     2 note_format_disp = vc
     2 note_format_mean = vc
     2 entry_method_cd = vc
     2 entry_method_disp = vc
     2 entry_method_mean = vc
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
     2 url = vc
     2 body = vc
     2 length = vc
     2 title_text = vc
     2 collating_sequence = vc
     2 update_dt_tm = vc
     2 attachment[*]
       3 event_id = vc
       3 title_text = vc
       3 storage_disp = vc
       3 storage_mean = vc
       3 storage_value = vc
       3 format_disp = vc
       3 format_mean = vc
       3 format_value = vc
       3 body = vc
       3 update_dt_tm = vc
   1 event_prsnl[*]
     2 event_id = vc
     2 event_prsnl_action_id = vc
     2 action_type_disp = vc
     2 action_type_mean = vc
     2 action_type_value = vc
     2 action_dt_tm = vc
     2 request_dt_tm = vc
     2 action_status_disp = vc
     2 action_status_mean = vc
     2 action_status_value = vc
     2 action_prsnl_id = vc
     2 action_prsnl = vc
     2 request_prsnl_id = vc
     2 request_prsnl = vc
     2 proxy_prsnl_id = vc
     2 proxy_prsnl = vc
 )
 DECLARE uar_si_encode_base64(p1=vc(ref),p2=i4(ref),p3=i4(ref)) = vc
 DECLARE strencoded = vc WITH public, noconstant("")
 DECLARE ibase64size = i4 WITH public, noconstant(0)
 DECLARE raw_data = vc
 DECLARE has_attachment = i2 WITH public, noconstant(0)
 DECLARE note_cnt = i2 WITH protect, noconstant(0)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
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
 IF (size(oreply->rb_list,5) <= 0)
  GO TO end_prog
 ENDIF
 SET t_record->event_id = cnvtstring(oreply->rb_list[1].event_id)
 SET t_record->event_code = cnvtstring(oreply->rb_list[1].event_cd)
 SET t_record->event_code_disp = uar_get_code_display(oreply->rb_list[1].event_cd)
 SET t_record->event_end_dt_tm = datetimezoneformat(oreply->rb_list[1].event_end_dt_tm,curtimezonesys,
  "yyyy-MM-dd HH:mm:ss",curtimezonedef)
 SET t_record->person_id = cnvtstring(oreply->rb_list[1].person_id)
 SET t_record->encounter_id = cnvtstring(oreply->rb_list[1].encntr_id)
 SET t_record->result_status_disp = uar_get_code_display(oreply->rb_list[1].result_status_cd)
 SET t_record->result_status_mean = uar_get_code_meaning(oreply->rb_list[1].result_status_cd)
 SET t_record->result_status_value = cnvtstring(oreply->rb_list[1].result_status_cd)
 SET t_record->order_id = cnvtstring(oreply->rb_list[1].order_id)
 SET t_record->catalog_cd = cnvtstring(oreply->rb_list[1].catalog_cd)
 SET t_record->catalog_disp = uar_get_code_display(oreply->rb_list[1].catalog_cd)
 SET t_record->update_dt_tm = datetimezoneformat(oreply->rb_list[1].updt_dt_tm,curtimezonesys,
  "yyyy-MM-dd HH:mm:ss",curtimezonedef)
 SET t_record->view_level = cnvtstring(oreply->rb_list[1].view_level)
 SET t_record->event_tag = oreply->rb_list[1].event_tag
 SET t_record->contrib_sys_disp = uar_get_code_display(oreply->rb_list[1].contributor_system_cd)
 SET t_record->contrib_sys_mean = uar_get_code_meaning(oreply->rb_list[1].contributor_system_cd)
 SET t_record->contrib_sys_value = cnvtstring(oreply->rb_list[1].contributor_system_cd)
 SET t_record->parent_event_id = cnvtstring(oreply->rb_list[1].parent_event_id)
 SET t_record->record_status_disp = uar_get_code_display(oreply->rb_list[1].record_status_cd)
 SET t_record->record_status_mean = uar_get_code_meaning(oreply->rb_list[1].record_status_cd)
 SET t_record->record_status_value = cnvtstring(oreply->rb_list[1].record_status_cd)
 IF ((oreply->rb_list[1].publish_flag=1))
  SET t_record->publish = "Published"
 ELSE
  SET t_record->publish = "NonPublished"
 ENDIF
 SET t_record->update_cnt = cnvtstring(oreply->rb_list[1].updt_cnt)
 SET t_record->entry_mode_disp = uar_get_code_display(oreply->rb_list[1].entry_mode_cd)
 SET t_record->entry_mode_mean = uar_get_code_meaning(oreply->rb_list[1].entry_mode_cd)
 SET t_record->entry_mode_value = cnvtstring(oreply->rb_list[1].entry_mode_cd)
 SET t_record->title_text = oreply->rb_list[1].event_title_text
 IF (size(oreply->rb_list[1].blob_result,5) > 0)
  IF (size(oreply->rb_list[1].blob_result[1].blob,5) > 0)
   SET raw_data = oreply->rb_list[1].blob_result[1].blob[1].blob_contents
   SET strencoded = uar_si_encode_base64(raw_data,size(raw_data),ibase64size)
   SET strencoded = substring(1,ibase64size,strencoded)
   SET strencoded = replace(strencoded,char(1),"",0)
   SET strencoded = replace(strencoded,char(2),"",0)
   SET strencoded = replace(strencoded,char(10),"",0)
   SET strencoded = replace(strencoded,char(13),"",0)
   SET t_record->body = strencoded
   SET t_record->length = cnvtstring(oreply->rb_list[1].blob_result[1].blob[1].blob_length)
  ELSE
   SET t_record->body = oreply->rb_list[1].blob_result[1].blob_handle
   SET t_record->length = textlen(oreply->rb_list[1].blob_result[1].blob_handle)
  ENDIF
  SET t_record->format_value = cnvtstring(oreply->rb_list[1].blob_result[1].format_cd)
  SET t_record->format_disp = uar_get_code_display(oreply->rb_list[1].blob_result[1].format_cd)
  SET t_record->format_mean = uar_get_code_meaning(oreply->rb_list[1].blob_result[1].format_cd)
 ENDIF
 SET stat = alterlist(t_record->document,size(oreply->rb_list[1].child_event_list,5))
 FOR (i = 1 TO size(oreply->rb_list[1].child_event_list,5))
   SET t_record->document[i].event_id = cnvtstring(oreply->rb_list[1].child_event_list[i].event_id)
   SET t_record->document[i].event_disp = uar_get_code_display(oreply->rb_list[1].child_event_list[i]
    .event_cd)
   SET t_record->document[i].event_mean = uar_get_code_meaning(oreply->rb_list[1].child_event_list[i]
    .event_cd)
   SET t_record->document[i].event_value = cnvtstring(oreply->rb_list[1].child_event_list[i].event_cd
    )
   SET t_record->document[i].succession_type_disp = uar_get_code_display(oreply->rb_list[1].
    child_event_list[i].blob_result[1].succession_type_cd)
   SET t_record->document[i].succession_type_mean = uar_get_code_meaning(oreply->rb_list[1].
    child_event_list[i].blob_result[1].succession_type_cd)
   SET t_record->document[i].succession_type_value = cnvtstring(oreply->rb_list[1].child_event_list[i
    ].blob_result[1].succession_type_cd)
   SET t_record->document[i].storage_disp = uar_get_code_display(oreply->rb_list[1].child_event_list[
    i].blob_result[1].storage_cd)
   SET t_record->document[i].storage_mean = uar_get_code_meaning(oreply->rb_list[1].child_event_list[
    i].blob_result[1].storage_cd)
   SET t_record->document[i].storage_value = cnvtstring(oreply->rb_list[1].child_event_list[i].
    blob_result[1].storage_cd)
   SET t_record->document[i].format_disp = uar_get_code_display(oreply->rb_list[1].child_event_list[i
    ].blob_result[1].format_cd)
   SET t_record->document[i].format_mean = uar_get_code_meaning(oreply->rb_list[1].child_event_list[i
    ].blob_result[1].format_cd)
   SET t_record->document[i].format_value = cnvtstring(oreply->rb_list[1].child_event_list[i].
    blob_result[1].format_cd)
   SET t_record->document[i].title_text = oreply->rb_list[1].child_event_list[i].event_title_text
   SET t_record->document[i].collating_sequence = oreply->rb_list[1].child_event_list[i].
   collating_seq
   SET t_record->document[i].update_dt_tm = datetimezoneformat(oreply->rb_list[1].child_event_list[i]
    .blob_result[1].updt_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
   SET has_attachment = 0
   IF (size(oreply->rb_list[1].child_event_list[i].child_event_list,5) > 0)
    IF (size(oreply->rb_list[1].child_event_list[i].child_event_list[1].blob_result,5) > 0)
     SET stat = alterlist(t_record->document[i].attachment,size(oreply->rb_list[1].child_event_list[i
       ].child_event_list[1].blob_result,5))
     FOR (l = 1 TO size(oreply->rb_list[1].child_event_list[i].child_event_list[1].blob_result,5))
       SET has_attachment = 1
       SET t_record->document[i].attachment[l].event_id = cnvtstring(oreply->rb_list[1].
        child_event_list[i].child_event_list[1].blob_result[l].event_id)
       SET t_record->document[i].attachment[l].storage_value = cnvtstring(oreply->rb_list[1].
        child_event_list[i].child_event_list[1].blob_result[l].storage_cd)
       SET t_record->document[i].attachment[l].storage_disp = uar_get_code_display(oreply->rb_list[1]
        .child_event_list[i].child_event_list[1].blob_result[l].storage_cd)
       SET t_record->document[i].attachment[l].storage_mean = uar_get_code_meaning(oreply->rb_list[1]
        .child_event_list[i].child_event_list[1].blob_result[l].storage_cd)
       SET t_record->document[i].storage_value = cnvtstring(oreply->rb_list[1].child_event_list[i].
        child_event_list[1].blob_result[l].storage_cd)
       SET t_record->document[i].storage_disp = uar_get_code_display(oreply->rb_list[1].
        child_event_list[i].child_event_list[1].blob_result[l].storage_cd)
       SET t_record->document[i].storage_mean = uar_get_code_meaning(oreply->rb_list[1].
        child_event_list[i].child_event_list[1].blob_result[l].storage_cd)
       SET t_record->document[i].attachment[l].format_value = cnvtstring(oreply->rb_list[1].
        child_event_list[i].child_event_list[1].blob_result[l].format_cd)
       SET t_record->document[i].attachment[l].format_disp = uar_get_code_display(oreply->rb_list[1].
        child_event_list[i].child_event_list[1].blob_result[l].format_cd)
       SET t_record->document[i].attachment[l].format_mean = uar_get_code_meaning(oreply->rb_list[1].
        child_event_list[i].child_event_list[1].blob_result[l].format_cd)
       SET t_record->document[i].format_value = cnvtstring(oreply->rb_list[1].child_event_list[i].
        child_event_list[1].blob_result[l].format_cd)
       SET t_record->document[i].format_disp = uar_get_code_display(oreply->rb_list[1].
        child_event_list[i].child_event_list[1].blob_result[l].format_cd)
       SET t_record->document[i].format_mean = uar_get_code_meaning(oreply->rb_list[1].
        child_event_list[i].child_event_list[1].blob_result[l].format_cd)
       SET t_record->document[i].attachment[l].title_text = oreply->rb_list[1].child_event_list[i].
       child_event_list[1].event_title_text
       SET t_record->document[i].attachment[l].body = oreply->rb_list[1].child_event_list[i].
       child_event_list[1].blob_result[l].blob_handle
       SET t_record->document[i].attachment[l].update_dt_tm = datetimezoneformat(oreply->rb_list[1].
        child_event_list[i].child_event_list[1].blob_result[1].updt_dt_tm,curtimezonesys,
        "yyyy-MM-dd HH:mm:ss",curtimezonedef)
     ENDFOR
    ENDIF
   ENDIF
   IF (size(oreply->rb_list[1].child_event_list[i].blob_result,5) > 0)
    SET t_record->document[i].url = oreply->rb_list[1].child_event_list[i].blob_result[1].blob_handle
    IF (size(oreply->rb_list[1].child_event_list[i].blob_result[1].blob,5) > 0)
     SET raw_data = oreply->rb_list[1].child_event_list[i].blob_result[1].blob[1].blob_contents
     SET strencoded = uar_si_encode_base64(raw_data,size(raw_data),ibase64size)
     SET strencoded = substring(1,ibase64size,strencoded)
     SET strencoded = replace(strencoded,char(1),"",0)
     SET strencoded = replace(strencoded,char(2),"",0)
     SET strencoded = replace(strencoded,char(10),"",0)
     SET strencoded = replace(strencoded,char(13),"",0)
     SET t_record->document[i].body = strencoded
     SET t_record->document[i].length = cnvtstring(oreply->rb_list[1].child_event_list[i].
      blob_result[1].blob[1].blob_length)
    ELSE
     SET t_record->document[i].body = oreply->rb_list[1].child_event_list[i].blob_result[1].
     blob_handle
    ENDIF
   ELSEIF (size(oreply->rb_list[1].child_event_list[i].child_event_list,5) > 0
    AND size(oreply->rb_list[1].child_event_list[i].child_event_list[1].blob_result[1].blob,5) > 0)
    SET t_record->document[i].url = oreply->rb_list[1].child_event_list[i].child_event_list[1].
    blob_result[1].blob_handle
    IF (size(oreply->rb_list[1].child_event_list[i].child_event_list[1].blob_result[1].blob,5) > 0)
     SET raw_data = oreply->rb_list[1].child_event_list[i].child_event_list[1].blob_result[1].blob[1]
     .blob_contents
     SET strencoded = uar_si_encode_base64(raw_data,size(raw_data),ibase64size)
     SET strencoded = substring(1,ibase64size,strencoded)
     SET strencoded = replace(strencoded,char(1),"",0)
     SET strencoded = replace(strencoded,char(2),"",0)
     SET strencoded = replace(strencoded,char(10),"",0)
     SET strencoded = replace(strencoded,char(13),"",0)
     SET t_record->document[i].body = strencoded
     SET t_record->document[i].length = cnvtstring(oreply->rb_list[1].child_event_list[i].
      child_event_list[1].blob_result[1].blob[1].blob_length)
    ELSE
     SET t_record->document[i].body = oreply->rb_list[1].child_event_list[i].child_event_list[1].
     blob_result[1].blob_handle
    ENDIF
   ENDIF
   IF (size(oreply->rb_list[1].child_event_list[i].event_note_list,5) > 0)
    SET note_cnt += size(oreply->rb_list[1].child_event_list[i].event_note_list,5)
    SET stat1 = alterlist(t_record->event_note,note_cnt)
    FOR (ncnt = 1 TO size(oreply->rb_list[1].child_event_list[i].event_note_list,5))
      SET t_record->event_note[ncnt].event_id = cnvtstring(oreply->rb_list[1].child_event_list[i].
       event_note_list[ncnt].event_id)
      SET t_record->event_note[ncnt].event_note_id = cnvtstring(oreply->rb_list[1].child_event_list[i
       ].event_note_list[ncnt].event_note_id)
      SET t_record->event_note[ncnt].note_dt_tm = datetimezoneformat(oreply->rb_list[1].
       child_event_list[i].event_note_list[ncnt].note_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",
       curtimezonedef)
      SET t_record->event_note[ncnt].note_type_cd = cnvtstring(oreply->rb_list[1].child_event_list[i]
       .event_note_list[ncnt].note_type_cd)
      SET t_record->event_note[ncnt].note_type_disp = uar_get_code_display(oreply->rb_list[1].
       child_event_list[i].event_note_list[ncnt].note_type_cd)
      SET t_record->event_note[ncnt].note_type_mean = uar_get_code_meaning(oreply->rb_list[1].
       child_event_list[i].event_note_list[ncnt].note_type_cd)
      SET t_record->event_note[ncnt].note_format_cd = cnvtstring(oreply->rb_list[1].child_event_list[
       i].event_note_list[ncnt].note_format_cd)
      SET t_record->event_note[ncnt].note_format_disp = uar_get_code_display(oreply->rb_list[1].
       child_event_list[i].event_note_list[ncnt].note_format_cd)
      SET t_record->event_note[ncnt].note_format_mean = uar_get_code_meaning(oreply->rb_list[1].
       child_event_list[i].event_note_list[ncnt].note_format_cd)
      SET t_record->event_note[ncnt].entry_method_cd = cnvtstring(oreply->rb_list[1].
       child_event_list[i].event_note_list[ncnt].entry_method_cd)
      SET t_record->event_note[ncnt].entry_method_disp = uar_get_code_display(oreply->rb_list[1].
       child_event_list[i].event_note_list[ncnt].entry_method_cd)
      SET t_record->event_note[ncnt].entry_method_mean = uar_get_code_meaning(oreply->rb_list[1].
       child_event_list[i].event_note_list[ncnt].entry_method_cd)
      IF ((oreply->rb_list[1].child_event_list[i].event_note_list[ncnt].importance_flag=1))
       SET t_record->event_note[ncnt].importance_flag = "Low"
      ELSEIF ((oreply->rb_list[1].child_event_list[i].event_note_list[ncnt].importance_flag=2))
       SET t_record->event_note[ncnt].importance_flag = "Medium"
      ELSEIF ((oreply->rb_list[1].child_event_list[i].event_note_list[ncnt].importance_flag=4))
       SET t_record->event_note[ncnt].importance_flag = "High"
      ENDIF
      IF ((oreply->rb_list[1].child_event_list[i].event_note_list[ncnt].non_chartable_flag=1))
       SET t_record->event_note[ncnt].non_chartable_ind = "true"
      ELSE
       SET t_record->event_note[ncnt].non_chartable_ind = "false"
      ENDIF
      IF ((oreply->rb_list[1].child_event_list[i].event_note_list[ncnt].long_text_id > 0))
       SET t_record->event_note[ncnt].note = oreply->rb_list[1].child_event_list[i].event_note_list[
       ncnt].long_text
      ELSE
       SET t_record->event_note[ncnt].note = oreply->rb_list[1].child_event_list[i].event_note_list[
       ncnt].long_blob
      ENDIF
      IF ((oreply->rb_list[1].child_event_list[i].event_note_list[ncnt].note_prsnl_id > 0))
       SET t_record->event_note[ncnt].note_prsnl_id = cnvtstring(oreply->rb_list[1].child_event_list[
        i].event_note_list[ncnt].note_prsnl_id)
       SELECT INTO "nl:"
        FROM prsnl p
        PLAN (p
         WHERE (p.person_id=oreply->rb_list[1].child_event_list[i].event_note_list[ncnt].
         note_prsnl_id)
          AND p.person_id > 0)
        DETAIL
         t_record->event_note[ncnt].note_prsnl = p.name_full_formatted
        WITH nocounter, time = 10
       ;end select
      ENDIF
    ENDFOR
   ENDIF
   IF (size(oreply->rb_list[1].child_event_list[i].child_event_list,5) > 0)
    IF (size(oreply->rb_list[1].child_event_list[i].child_event_list[1].event_note_list,5) > 0)
     SET note_cnt += size(oreply->rb_list[1].child_event_list[i].child_event_list[1].event_note_list,
      5)
     SET stat1 = alterlist(t_record->event_note,note_cnt)
     FOR (ncnt = 1 TO size(oreply->rb_list[1].child_event_list[i].child_event_list[1].event_note_list,
      5))
       SET t_record->event_note[ncnt].event_id = cnvtstring(oreply->rb_list[1].child_event_list[i].
        child_event_list[1].event_note_list[ncnt].event_id)
       SET t_record->event_note[ncnt].event_note_id = cnvtstring(oreply->rb_list[1].child_event_list[
        i].child_event_list[1].event_note_list[ncnt].event_note_id)
       SET t_record->event_note[ncnt].note_dt_tm = datetimezoneformat(oreply->rb_list[1].
        child_event_list[i].child_event_list[1].event_note_list[ncnt].note_dt_tm,curtimezonesys,
        "yyyy-MM-dd HH:mm:ss",curtimezonedef)
       SET t_record->event_note[ncnt].note_type_cd = cnvtstring(oreply->rb_list[1].child_event_list[i
        ].child_event_list[1].event_note_list[ncnt].note_type_cd)
       SET t_record->event_note[ncnt].note_type_disp = uar_get_code_display(oreply->rb_list[1].
        child_event_list[i].child_event_list[1].event_note_list[ncnt].note_type_cd)
       SET t_record->event_note[ncnt].note_type_mean = uar_get_code_meaning(oreply->rb_list[1].
        child_event_list[i].child_event_list[1].event_note_list[ncnt].note_type_cd)
       SET t_record->event_note[ncnt].note_format_cd = cnvtstring(oreply->rb_list[1].
        child_event_list[i].child_event_list[1].event_note_list[ncnt].note_format_cd)
       SET t_record->event_note[ncnt].note_format_disp = uar_get_code_display(oreply->rb_list[1].
        child_event_list[i].child_event_list[1].event_note_list[ncnt].note_format_cd)
       SET t_record->event_note[ncnt].note_format_mean = uar_get_code_meaning(oreply->rb_list[1].
        child_event_list[i].child_event_list[1].event_note_list[ncnt].note_format_cd)
       SET t_record->event_note[ncnt].entry_method_cd = cnvtstring(oreply->rb_list[1].
        child_event_list[i].child_event_list[1].event_note_list[ncnt].entry_method_cd)
       SET t_record->event_note[ncnt].entry_method_disp = uar_get_code_display(oreply->rb_list[1].
        child_event_list[i].child_event_list[1].event_note_list[ncnt].entry_method_cd)
       SET t_record->event_note[ncnt].entry_method_mean = uar_get_code_meaning(oreply->rb_list[1].
        child_event_list[i].child_event_list[1].event_note_list[ncnt].entry_method_cd)
       IF ((oreply->rb_list[1].child_event_list[i].child_event_list[1].event_note_list[ncnt].
       importance_flag=1))
        SET t_record->event_note[ncnt].importance_flag = "Low"
       ELSEIF ((oreply->rb_list[1].child_event_list[i].child_event_list[1].event_note_list[ncnt].
       importance_flag=2))
        SET t_record->event_note[ncnt].importance_flag = "Medium"
       ELSEIF ((oreply->rb_list[1].child_event_list[i].child_event_list[1].event_note_list[ncnt].
       importance_flag=4))
        SET t_record->event_note[ncnt].importance_flag = "High"
       ENDIF
       IF ((oreply->rb_list[1].child_event_list[i].child_event_list[1].event_note_list[ncnt].
       non_chartable_flag=1))
        SET t_record->event_note[ncnt].non_chartable_ind = "true"
       ELSE
        SET t_record->event_note[ncnt].non_chartable_ind = "false"
       ENDIF
       IF ((oreply->rb_list[1].child_event_list[i].child_event_list[1].event_note_list[ncnt].
       long_text_id > 0))
        SET t_record->event_note[ncnt].note = oreply->rb_list[1].child_event_list[i].
        child_event_list[1].event_note_list[ncnt].long_text
       ELSE
        SET t_record->event_note[ncnt].note = oreply->rb_list[1].child_event_list[i].
        child_event_list[1].event_note_list[ncnt].long_blob
       ENDIF
       IF ((oreply->rb_list[1].child_event_list[i].child_event_list[1].event_note_list[ncnt].
       note_prsnl_id > 0))
        SET t_record->event_note[ncnt].note_prsnl_id = cnvtstring(oreply->rb_list[1].
         child_event_list[i].child_event_list[1].event_note_list[ncnt].note_prsnl_id)
        SELECT INTO "nl:"
         FROM prsnl p
         PLAN (p
          WHERE (p.person_id=oreply->rb_list[1].child_event_list[i].child_event_list[1].
          event_note_list[ncnt].note_prsnl_id)
           AND p.person_id > 0)
         DETAIL
          t_record->event_note[ncnt].note_prsnl = p.name_full_formatted
         WITH nocounter, time = 10
        ;end select
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
 SET stat = alterlist(t_record->event_note,(size(oreply->rb_list[1].event_note_list,5)+ note_cnt))
 FOR (j = 1 TO size(oreply->rb_list[1].event_note_list,5))
   SET t_record->event_note[(j+ note_cnt)].event_id = cnvtstring(oreply->rb_list[1].event_note_list[j
    ].event_id)
   SET t_record->event_note[(j+ note_cnt)].event_note_id = cnvtstring(oreply->rb_list[1].
    event_note_list[j].event_note_id)
   SET t_record->event_note[(j+ note_cnt)].note_dt_tm = datetimezoneformat(oreply->rb_list[1].
    event_note_list[j].note_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
   SET t_record->event_note[(j+ note_cnt)].note_type_cd = cnvtstring(oreply->rb_list[1].
    event_note_list[j].note_type_cd)
   SET t_record->event_note[(j+ note_cnt)].note_type_disp = uar_get_code_display(oreply->rb_list[1].
    event_note_list[j].note_type_cd)
   SET t_record->event_note[(j+ note_cnt)].note_type_mean = uar_get_code_meaning(oreply->rb_list[1].
    event_note_list[j].note_type_cd)
   SET t_record->event_note[(j+ note_cnt)].note_format_cd = cnvtstring(oreply->rb_list[1].
    event_note_list[j].note_format_cd)
   SET t_record->event_note[(j+ note_cnt)].note_format_disp = uar_get_code_display(oreply->rb_list[1]
    .event_note_list[j].note_format_cd)
   SET t_record->event_note[(j+ note_cnt)].note_format_mean = uar_get_code_meaning(oreply->rb_list[1]
    .event_note_list[j].note_format_cd)
   SET t_record->event_note[(j+ note_cnt)].entry_method_cd = cnvtstring(oreply->rb_list[1].
    event_note_list[j].entry_method_cd)
   SET t_record->event_note[(j+ note_cnt)].entry_method_disp = uar_get_code_display(oreply->rb_list[1
    ].event_note_list[j].entry_method_cd)
   SET t_record->event_note[(j+ note_cnt)].entry_method_mean = uar_get_code_meaning(oreply->rb_list[1
    ].event_note_list[j].entry_method_cd)
   IF ((oreply->rb_list[1].event_note_list[j].importance_flag=1))
    SET t_record->event_note[(j+ note_cnt)].importance_flag = "Low"
   ELSEIF ((oreply->rb_list[1].event_note_list[j].importance_flag=2))
    SET t_record->event_note[(j+ note_cnt)].importance_flag = "Medium"
   ELSEIF ((oreply->rb_list[1].event_note_list[j].importance_flag=4))
    SET t_record->event_note[(j+ note_cnt)].importance_flag = "High"
   ENDIF
   IF ((oreply->rb_list[1].event_note_list[j].non_chartable_flag=1))
    SET t_record->event_note[(j+ note_cnt)].non_chartable_ind = "true"
   ELSE
    SET t_record->event_note[(j+ note_cnt)].non_chartable_ind = "false"
   ENDIF
   IF ((oreply->rb_list[1].event_note_list[j].long_text_id > 0))
    SET t_record->event_note[(j+ note_cnt)].note = oreply->rb_list[1].event_note_list[j].long_text
   ELSE
    SET t_record->event_note[(j+ note_cnt)].note = oreply->rb_list[1].event_note_list[j].long_blob
   ENDIF
   IF ((oreply->rb_list[1].event_note_list[j].note_prsnl_id > 0))
    SET t_record->event_note[(j+ note_cnt)].note_prsnl_id = cnvtstring(oreply->rb_list[1].
     event_note_list[j].note_prsnl_id)
    SELECT INTO "nl:"
     FROM prsnl p
     PLAN (p
      WHERE (p.person_id=oreply->rb_list[1].event_note_list[j].note_prsnl_id)
       AND p.person_id > 0)
     DETAIL
      t_record->event_note[(j+ note_cnt)].note_prsnl = p.name_full_formatted
     WITH nocounter, time = 10
    ;end select
   ENDIF
 ENDFOR
 IF (event_prsnl_ind=1)
  SET stat = alterlist(t_record->event_prsnl,size(oreply->rb_list[1].event_prsnl_list,5))
  FOR (j = 1 TO size(oreply->rb_list[1].event_prsnl_list,5))
    SET t_record->event_prsnl[j].event_id = cnvtstring(oreply->rb_list[1].event_prsnl_list[j].
     event_id)
    SET t_record->event_prsnl[j].event_prsnl_action_id = cnvtstring(oreply->rb_list[1].
     event_prsnl_list[j].event_prsnl_id)
    SET t_record->event_prsnl[j].action_type_disp = uar_get_code_display(oreply->rb_list[1].
     event_prsnl_list[j].action_type_cd)
    SET t_record->event_prsnl[j].action_type_mean = uar_get_code_meaning(oreply->rb_list[1].
     event_prsnl_list[j].action_type_cd)
    SET t_record->event_prsnl[j].action_type_value = cnvtstring(oreply->rb_list[1].event_prsnl_list[j
     ].action_type_cd)
    SET t_record->event_prsnl[j].action_dt_tm = datetimezoneformat(oreply->rb_list[1].
     event_prsnl_list[j].action_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
    SET t_record->event_prsnl[j].request_dt_tm = datetimezoneformat(oreply->rb_list[1].
     event_prsnl_list[j].request_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
    SET t_record->event_prsnl[j].action_status_disp = uar_get_code_display(oreply->rb_list[1].
     event_prsnl_list[j].action_status_cd)
    SET t_record->event_prsnl[j].action_status_mean = uar_get_code_meaning(oreply->rb_list[1].
     event_prsnl_list[j].action_status_cd)
    SET t_record->event_prsnl[j].action_status_value = cnvtstring(oreply->rb_list[1].
     event_prsnl_list[j].action_status_cd)
    IF ((oreply->rb_list[1].event_prsnl_list[j].action_prsnl_id > 0))
     SET t_record->event_prsnl[j].action_prsnl_id = cnvtstring(oreply->rb_list[1].event_prsnl_list[j]
      .action_prsnl_id)
     SELECT INTO "nl:"
      FROM prsnl p
      PLAN (p
       WHERE (p.person_id=oreply->rb_list[1].event_prsnl_list[j].action_prsnl_id)
        AND p.person_id > 0)
      DETAIL
       t_record->event_prsnl[j].action_prsnl = p.name_full_formatted
      WITH nocounter, time = 10
     ;end select
    ENDIF
    IF ((oreply->rb_list[1].event_prsnl_list[j].request_prsnl_id > 0))
     SET t_record->event_prsnl[j].request_prsnl_id = cnvtstring(oreply->rb_list[1].event_prsnl_list[j
      ].request_prsnl_id)
     SELECT INTO "nl:"
      FROM prsnl p
      PLAN (p
       WHERE (p.person_id=oreply->rb_list[1].event_prsnl_list[j].request_prsnl_id)
        AND p.person_id > 0)
      DETAIL
       t_record->event_prsnl[j].request_prsnl = p.name_full_formatted
      WITH nocounter, time = 10
     ;end select
    ENDIF
    IF ((oreply->rb_list[1].event_prsnl_list[j].proxy_prsnl_id > 0))
     SET t_record->event_prsnl[j].proxy_prsnl_id = cnvtstring(oreply->rb_list[1].event_prsnl_list[j].
      proxy_prsnl_id)
     SELECT INTO "nl:"
      FROM prsnl p
      PLAN (p
       WHERE (p.person_id=oreply->rb_list[1].event_prsnl_list[j].proxy_prsnl_id)
        AND p.person_id > 0)
      DETAIL
       t_record->event_prsnl[j].proxy_prsnl = p.name_full_formatted
      WITH nocounter, time = 10
     ;end select
    ENDIF
  ENDFOR
 ENDIF
 SET stat = alterlist(out_rec->document,size(t_record->document,5))
 SELECT INTO "nl:"
  coll_seq = t_record->document[d.seq].collating_sequence
  FROM (dummyt d  WITH seq = size(t_record->document,5))
  PLAN (d)
  ORDER BY coll_seq
  HEAD REPORT
   out_rec->event_id = t_record->event_id, out_rec->event_code = t_record->event_code, out_rec->
   event_code_disp = t_record->event_code_disp,
   out_rec->event_end_dt_tm = t_record->event_end_dt_tm, out_rec->person_id = t_record->person_id,
   out_rec->encounter_id = t_record->encounter_id,
   out_rec->result_status_disp = t_record->result_status_disp, out_rec->result_status_mean = t_record
   ->result_status_mean, out_rec->result_status_value = t_record->result_status_value,
   out_rec->order_id = t_record->order_id, out_rec->catalog_cd = t_record->catalog_cd, out_rec->
   catalog_disp = t_record->catalog_disp,
   out_rec->update_dt_tm = t_record->update_dt_tm, out_rec->view_level = t_record->view_level,
   out_rec->event_tag = t_record->event_tag,
   out_rec->contrib_sys_disp = t_record->contrib_sys_disp, out_rec->contrib_sys_mean = t_record->
   contrib_sys_mean, out_rec->contrib_sys_value = t_record->contrib_sys_value,
   out_rec->parent_event_id = t_record->parent_event_id, out_rec->record_status_disp = t_record->
   record_status_disp, out_rec->record_status_mean = t_record->record_status_mean,
   out_rec->record_status_value = t_record->record_status_value, out_rec->publish = t_record->publish,
   out_rec->title_text = t_record->title_text,
   out_rec->update_cnt = t_record->update_cnt, out_rec->entry_mode_disp = t_record->entry_mode_disp,
   out_rec->entry_mode_mean = t_record->entry_mode_mean,
   out_rec->entry_mode_value = t_record->entry_mode_value, out_rec->body = t_record->body, out_rec->
   length = t_record->length,
   out_rec->format_value = t_record->format_value, out_rec->format_disp = t_record->format_disp,
   out_rec->format_mean = t_record->format_mean,
   c_cnt = 0
  DETAIL
   IF (size(t_record->document,5) > 0)
    c_cnt += 1, out_rec->document[c_cnt].event_id = t_record->document[d.seq].event_id, out_rec->
    document[c_cnt].event_disp = t_record->document[d.seq].event_disp,
    out_rec->document[c_cnt].event_mean = t_record->document[d.seq].event_mean, out_rec->document[
    c_cnt].event_value = t_record->document[d.seq].event_value, out_rec->document[c_cnt].
    succession_type_disp = t_record->document[d.seq].succession_type_disp,
    out_rec->document[c_cnt].succession_type_mean = t_record->document[d.seq].succession_type_mean,
    out_rec->document[c_cnt].succession_type_value = t_record->document[d.seq].succession_type_value,
    out_rec->document[c_cnt].storage_disp = t_record->document[d.seq].storage_disp,
    out_rec->document[c_cnt].storage_mean = t_record->document[d.seq].storage_mean, out_rec->
    document[c_cnt].storage_value = t_record->document[d.seq].storage_value, out_rec->document[c_cnt]
    .format_disp = t_record->document[d.seq].format_disp,
    out_rec->document[c_cnt].format_mean = t_record->document[d.seq].format_mean, out_rec->document[
    c_cnt].format_value = t_record->document[d.seq].format_value, out_rec->document[c_cnt].url =
    t_record->document[d.seq].url,
    out_rec->document[c_cnt].body = t_record->document[d.seq].body, out_rec->document[c_cnt].length
     = t_record->document[d.seq].length, out_rec->document[c_cnt].title_text = t_record->document[d
    .seq].title_text,
    out_rec->document[c_cnt].collating_sequence = concat(t_record->document[d.seq].collating_sequence,
     cnvtstring(c_cnt)), out_rec->document[c_cnt].update_dt_tm = t_record->document[d.seq].
    update_dt_tm, stat = alterlist(out_rec->document[c_cnt].attachment,size(t_record->document[d.seq]
      .attachment,5))
    FOR (k = 1 TO size(t_record->document[d.seq].attachment,5))
      out_rec->document[c_cnt].attachment[k].event_id = t_record->document[d.seq].attachment[k].
      event_id, out_rec->document[c_cnt].attachment[k].format_value = t_record->document[d.seq].
      attachment[k].format_value, out_rec->document[c_cnt].attachment[k].format_disp = t_record->
      document[d.seq].attachment[k].format_disp,
      out_rec->document[c_cnt].attachment[k].format_mean = t_record->document[d.seq].attachment[k].
      format_mean, out_rec->document[c_cnt].attachment[k].storage_value = t_record->document[d.seq].
      attachment[k].storage_value, out_rec->document[c_cnt].attachment[k].storage_disp = t_record->
      document[d.seq].attachment[k].storage_disp,
      out_rec->document[c_cnt].attachment[k].storage_mean = t_record->document[d.seq].attachment[k].
      storage_mean, out_rec->document[c_cnt].attachment[k].title_text = t_record->document[d.seq].
      attachment[k].title_text, out_rec->document[c_cnt].attachment[k].body = t_record->document[d
      .seq].attachment[k].body,
      out_rec->document[c_cnt].attachment[k].update_dt_tm = t_record->document[d.seq].attachment[k].
      update_dt_tm
    ENDFOR
   ENDIF
  WITH nocounter, time = 30
 ;end select
 SET stat = alterlist(out_rec->event_note,size(t_record->event_note,5))
 IF (size(t_record->event_note,5) > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = size(t_record->event_note,5))
   PLAN (d)
   ORDER BY d.seq
   HEAD REPORT
    e_cnt = 0
   HEAD d.seq
    e_cnt += 1, out_rec->event_note[e_cnt].event_id = t_record->event_note[d.seq].event_id, out_rec->
    event_note[e_cnt].event_note_id = t_record->event_note[d.seq].event_note_id,
    out_rec->event_note[e_cnt].note = t_record->event_note[d.seq].note, out_rec->event_note[e_cnt].
    note_dt_tm = t_record->event_note[d.seq].note_dt_tm, out_rec->event_note[e_cnt].importance_flag
     = t_record->event_note[d.seq].importance_flag,
    out_rec->event_note[e_cnt].non_chartable_ind = t_record->event_note[d.seq].non_chartable_ind,
    out_rec->event_note[e_cnt].note_prsnl_id = t_record->event_note[d.seq].note_prsnl_id, out_rec->
    event_note[e_cnt].note_prsnl = t_record->event_note[d.seq].note_prsnl,
    out_rec->event_note[e_cnt].note_type_cd = t_record->event_note[d.seq].note_type_cd, out_rec->
    event_note[e_cnt].note_type_disp = t_record->event_note[d.seq].note_type_disp, out_rec->
    event_note[e_cnt].note_type_mean = t_record->event_note[d.seq].note_type_mean,
    out_rec->event_note[e_cnt].note_format_cd = t_record->event_note[d.seq].note_format_cd, out_rec->
    event_note[e_cnt].note_format_disp = t_record->event_note[d.seq].note_format_disp, out_rec->
    event_note[e_cnt].note_format_mean = t_record->event_note[d.seq].note_format_mean,
    out_rec->event_note[e_cnt].entry_method_cd = t_record->event_note[d.seq].entry_method_cd, out_rec
    ->event_note[e_cnt].entry_method_disp = t_record->event_note[d.seq].entry_method_disp, out_rec->
    event_note[e_cnt].entry_method_mean = t_record->event_note[d.seq].entry_method_mean
   WITH nocounter, time = 30
  ;end select
 ENDIF
 SET stat = alterlist(out_rec->event_prsnl,size(t_record->event_prsnl,5))
 IF (size(t_record->event_prsnl,5) > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = size(t_record->event_prsnl,5))
   PLAN (d)
   ORDER BY d.seq
   HEAD REPORT
    e_cnt = 0
   HEAD d.seq
    e_cnt += 1, out_rec->event_prsnl[e_cnt].event_id = t_record->event_prsnl[d.seq].event_id, out_rec
    ->event_prsnl[e_cnt].event_prsnl_action_id = t_record->event_prsnl[d.seq].event_prsnl_action_id,
    out_rec->event_prsnl[e_cnt].action_type_disp = t_record->event_prsnl[d.seq].action_type_disp,
    out_rec->event_prsnl[e_cnt].action_type_mean = t_record->event_prsnl[d.seq].action_type_mean,
    out_rec->event_prsnl[e_cnt].action_type_value = t_record->event_prsnl[d.seq].action_type_value,
    out_rec->event_prsnl[e_cnt].action_dt_tm = t_record->event_prsnl[d.seq].action_dt_tm, out_rec->
    event_prsnl[e_cnt].request_dt_tm = t_record->event_prsnl[d.seq].request_dt_tm, out_rec->
    event_prsnl[e_cnt].action_status_disp = t_record->event_prsnl[d.seq].action_status_disp,
    out_rec->event_prsnl[e_cnt].action_status_mean = t_record->event_prsnl[d.seq].action_status_mean,
    out_rec->event_prsnl[e_cnt].action_status_value = t_record->event_prsnl[d.seq].
    action_status_value, out_rec->event_prsnl[e_cnt].action_prsnl_id = t_record->event_prsnl[d.seq].
    action_prsnl_id,
    out_rec->event_prsnl[e_cnt].action_prsnl = t_record->event_prsnl[d.seq].action_prsnl, out_rec->
    event_prsnl[e_cnt].request_prsnl_id = t_record->event_prsnl[d.seq].request_prsnl_id, out_rec->
    event_prsnl[e_cnt].request_prsnl = t_record->event_prsnl[d.seq].request_prsnl,
    out_rec->event_prsnl[e_cnt].proxy_prsnl_id = t_record->event_prsnl[d.seq].proxy_prsnl_id, out_rec
    ->event_prsnl[e_cnt].proxy_prsnl = t_record->event_prsnl[d.seq].proxy_prsnl
   WITH nocounter, time = 30
  ;end select
 ENDIF
#end_prog
 IF (validate(_memory_reply_string))
  SET _memory_reply_string = cnvtrectojson(out_rec)
 ELSE
  CALL echojson(out_rec,moutputdevice)
 ENDIF
 FREE RECORD out_rec
END GO
