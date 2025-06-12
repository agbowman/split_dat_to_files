CREATE PROGRAM bhs_athn_read_micro_proc_by_id
 RECORD orequest(
   1 query_mode = i4
   1 query_mode_ind = i2
   1 event_id = f8
   1 contributor_system_cd = f8
   1 reference_nbr = vc
   1 dataset_uid = vc
   1 subtable_bit_map = i4
   1 subtable_bit_map_ind = i2
   1 valid_from_dt_tm = vc
   1 valid_from_dt_tm_ind = i2
   1 decode_flag = i2
   1 ordering_provider_id = f8
   1 action_prsnl_id = f8
   1 event_id_list[*]
   1 event_id = f8
   1 action_type_cd_list[*]
   1 action_type_cd = f8
   1 src_event_id_ind = i2
   1 action_prsnl_group_id = f8
   1 query_mode2 = i4
   1 event_uuid = vc
 )
 RECORD out_rec(
   1 status = vc
   1 event_id = vc
   1 event_code = vc
   1 event_code_disp = vc
   1 event_end_dt_tm = vc
   1 display = vc
   1 person_id = vc
   1 encounter_id = vc
   1 result_status_disp = vc
   1 result_status_mean = vc
   1 result_status_value = vc
   1 order_id = vc
   1 order_catalog_disp = vc
   1 order_catalog_value = vc
   1 order_catalog_desc = vc
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
   1 procedure_start_dt_tm = vc
   1 collect_dt_tm = vc
   1 source_type_disp = vc
   1 source_type_mean = vc
   1 source_type_value = vc
   1 accession_number = vc
   1 event_note[*]
     2 event_note_id = vc
     2 date_time = vc
     2 type_disp = vc
     2 type_mean = vc
     2 type_value = vc
     2 format_disp = vc
     2 format_mean = vc
     2 format_value = vc
     2 importance = vc
     2 prsnl_id = vc
     2 body = vc
     2 entry_method_disp = vc
     2 entry_method_mean = vc
     2 entry_method_value = vc
     2 non_chartable_ind = vc
     2 collect_dt_tm = vc
     2 source_type_disp = vc
     2 source_type_mean = vc
     2 source_type_value = vc
   1 unclassified_report[*]
     2 event_id = vc
     2 event_code = vc
     2 event_code_disp = vc
     2 event_end_dt_tm = vc
     2 display = vc
     2 person_id = vc
     2 encounter_id = vc
     2 result_status_disp = vc
     2 result_status_mean = vc
     2 result_status_value = vc
     2 order_id = vc
     2 order_catalog_disp = vc
     2 order_catalog_value = vc
     2 order_catalog_desc = vc
     2 update_dt_tm = vc
     2 view_level = vc
     2 event_tag = vc
     2 contrib_sys_disp = vc
     2 contrib_sys_mean = vc
     2 contrib_sys_value = vc
     2 parent_event_id = vc
     2 record_status_disp = vc
     2 record_status_mean = vc
     2 record_status_value = vc
     2 publish = vc
     2 collating_seq = vc
     2 format_disp = vc
     2 format_mean = vc
     2 format_value = vc
     2 body = vc
     2 body_length = vc
   1 event_prsnl[*]
     2 event_prsnl_action_id = vc
     2 action_type_disp = vc
     2 action_type_mean = vc
     2 action_type_value = vc
     2 action_dt_tm = vc
     2 action_status_disp = vc
     2 action_status_mean = vc
     2 action_status_value = vc
     2 action_prsnl_id = vc
     2 request_prsnl_id = vc
     2 proxy_prsnl_id = vc
     2 action_prsnl = vc
     2 position_disp = vc
     2 position_mean = vc
     2 position_value = vc
     2 physician_ind = vc
 )
 RECORD t_record(
   1 event_cnt = i4
   1 event_qual[*]
     2 event_id = f8
 )
 SET orequest->event_id =  $2
 SET orequest->query_mode = 2
 SET orequest->valid_from_dt_tm_ind = 1
 SET orequest->subtable_bit_map_ind = 1
 SET stat = tdbexecute(3200000,3200200,1000011,"REC",orequest,
  "REC",oreply)
 IF ((oreply->rb_list[1].event_class_cd != 230))
  SET out_rec->status = "Failed. This transaction is only for Microbiology Procedures"
  GO TO exit_script
 ENDIF
 SET out_rec->status = "Success"
 SET out_rec->event_id = cnvtstring(oreply->rb_list[1].event_id)
 SET out_rec->event_code = cnvtstring(oreply->rb_list[1].event_cd)
 SET out_rec->event_code_disp = uar_get_code_display(oreply->rb_list[1].event_cd)
 SET out_rec->event_end_dt_tm = datetimezoneformat(oreply->rb_list[1].event_end_dt_tm,curtimezonesys,
  "yyyy-MM-dd HH:mm:ss",curtimezonedef)
 SET out_rec->display = concat(trim(oreply->rb_list[1].result_val)," ",trim(uar_get_code_display(
    oreply->rb_list[1].result_units_cd)))
 SET out_rec->person_id = cnvtstring(oreply->rb_list[1].person_id)
 SET out_rec->encounter_id = cnvtstring(oreply->rb_list[1].encntr_id)
 SET out_rec->result_status_disp = uar_get_code_display(oreply->rb_list[1].result_status_cd)
 SET out_rec->result_status_mean = uar_get_code_meaning(oreply->rb_list[1].result_status_cd)
 SET out_rec->result_status_value = cnvtstring(oreply->rb_list[1].result_status_cd)
 SET out_rec->order_id = cnvtstring(oreply->rb_list[1].order_id)
 SET out_rec->order_catalog_disp = uar_get_code_display(oreply->rb_list[1].catalog_cd)
 SET out_rec->order_catalog_value = cnvtstring(oreply->rb_list[1].catalog_cd)
 SET out_rec->order_catalog_desc = uar_get_code_description(oreply->rb_list[1].catalog_cd)
 SET out_rec->update_dt_tm = datetimezoneformat(oreply->rb_list[1].updt_dt_tm,curtimezonesys,
  "yyyy-MM-dd HH:mm:ss",curtimezonedef)
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
 SET out_rec->procedure_start_dt_tm = datetimezoneformat(oreply->rb_list[1].event_start_dt_tm,
  curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
 SET out_rec->collect_dt_tm = datetimezoneformat(oreply->rb_list[1].specimen_coll[1].collect_dt_tm,
  curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
 SET out_rec->source_type_disp = uar_get_code_display(oreply->rb_list[1].specimen_coll[1].
  source_type_cd)
 SET out_rec->source_type_mean = uar_get_code_meaning(oreply->rb_list[1].specimen_coll[1].
  source_type_cd)
 SET out_rec->source_type_value = cnvtstring(oreply->rb_list[1].specimen_coll[1].source_type_cd)
 SET out_rec->accession_number = oreply->rb_list[1].accession_nbr
 SET out_rec->collect_dt_tm = datetimezoneformat(oreply->rb_list[1].specimen_coll[1].collect_dt_tm,
  curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
 SET out_rec->source_type_disp = uar_get_code_display(oreply->rb_list[1].specimen_coll[1].
  source_type_cd)
 SET out_rec->source_type_mean = uar_get_code_meaning(oreply->rb_list[1].specimen_coll[1].
  source_type_cd)
 SET out_rec->source_type_value = cnvtstring(oreply->rb_list[1].specimen_coll[1].source_type_cd)
 SET stat = alterlist(out_rec->unclassified_report,size(oreply->rb_list[1].child_event_list,5))
 FOR (i = 1 TO size(oreply->rb_list[1].child_event_list,5))
   SET out_rec->unclassified_report[i].event_id = cnvtstring(oreply->rb_list[1].child_event_list[i].
    event_id)
   SET out_rec->unclassified_report[i].event_code_disp = uar_get_code_display(oreply->rb_list[1].
    child_event_list[i].event_cd)
   SET out_rec->unclassified_report[i].event_code = cnvtstring(oreply->rb_list[1].child_event_list[i]
    .event_cd)
   SET out_rec->unclassified_report[i].event_end_dt_tm = datetimezoneformat(oreply->rb_list[1].
    child_event_list[i].event_end_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
   SET out_rec->unclassified_report[i].display = uar_get_code_display(oreply->rb_list[1].
    child_event_list[i].event_cd)
   SET out_rec->unclassified_report[i].person_id = cnvtstring(oreply->rb_list[1].child_event_list[i].
    person_id)
   SET out_rec->unclassified_report[i].encounter_id = cnvtstring(oreply->rb_list[1].child_event_list[
    i].encntr_id)
   SET out_rec->unclassified_report[i].result_status_disp = uar_get_code_display(oreply->rb_list[1].
    child_event_list[i].result_status_cd)
   SET out_rec->unclassified_report[i].result_status_mean = uar_get_code_meaning(oreply->rb_list[1].
    child_event_list[i].result_status_cd)
   SET out_rec->unclassified_report[i].result_status_value = cnvtstring(oreply->rb_list[1].
    child_event_list[i].result_status_cd)
   SET out_rec->unclassified_report[i].order_id = cnvtstring(oreply->rb_list[1].child_event_list[i].
    order_id)
   SET out_rec->unclassified_report[i].order_catalog_disp = uar_get_code_display(oreply->rb_list[1].
    child_event_list[i].catalog_cd)
   SET out_rec->unclassified_report[i].order_catalog_value = cnvtstring(oreply->rb_list[1].
    child_event_list[i].catalog_cd)
   SET out_rec->unclassified_report[i].order_catalog_desc = uar_get_code_description(oreply->rb_list[
    1].child_event_list[i].catalog_cd)
   SET out_rec->unclassified_report[i].update_dt_tm = datetimezoneformat(oreply->rb_list[1].
    child_event_list[i].updt_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
   SET out_rec->unclassified_report[i].view_level = cnvtstring(oreply->rb_list[1].child_event_list[i]
    .view_level)
   SET out_rec->unclassified_report[i].event_tag = oreply->rb_list[1].child_event_list[i].event_tag
   SET out_rec->unclassified_report[i].contrib_sys_disp = uar_get_code_display(oreply->rb_list[1].
    child_event_list[i].contributor_system_cd)
   SET out_rec->unclassified_report[i].contrib_sys_mean = uar_get_code_meaning(oreply->rb_list[1].
    child_event_list[i].contributor_system_cd)
   SET out_rec->unclassified_report[i].contrib_sys_value = cnvtstring(oreply->rb_list[1].
    child_event_list[i].contributor_system_cd)
   SET out_rec->unclassified_report[i].parent_event_id = cnvtstring(oreply->rb_list[1].
    child_event_list[i].parent_event_id)
   SET out_rec->unclassified_report[i].record_status_disp = uar_get_code_display(oreply->rb_list[1].
    child_event_list[i].record_status_cd)
   SET out_rec->unclassified_report[i].record_status_mean = uar_get_code_meaning(oreply->rb_list[1].
    child_event_list[i].record_status_cd)
   SET out_rec->unclassified_report[i].record_status_value = cnvtstring(oreply->rb_list[1].
    child_event_list[i].record_status_cd)
   SET out_rec->unclassified_report[i].publish = cnvtstring(oreply->rb_list[1].child_event_list[i].
    publish_flag)
   SET out_rec->unclassified_report[i].format_disp = uar_get_code_display(oreply->rb_list[1].
    child_event_list[i].blob_result[1].format_cd)
   SET out_rec->unclassified_report[i].format_mean = uar_get_code_meaning(oreply->rb_list[1].
    child_event_list[i].blob_result[1].format_cd)
   SET out_rec->unclassified_report[i].format_value = cnvtstring(oreply->rb_list[1].child_event_list[
    i].blob_result[1].format_cd)
   SET out_rec->unclassified_report[i].body = oreply->rb_list[1].child_event_list[i].blob_result[1].
   blob[1].blob_contents
   SET out_rec->unclassified_report[i].body_length = cnvtstring(oreply->rb_list[1].child_event_list[i
    ].blob_result[1].blob[1].blob_length)
   SET out_rec->unclassified_report[i].collating_seq = oreply->rb_list[1].child_event_list[i].
   collating_seq
 ENDFOR
 SET stat = alterlist(out_rec->event_prsnl,size(oreply->rb_list[1].event_prsnl_list,5))
 FOR (i = 1 TO size(oreply->rb_list[1].event_prsnl_list,5))
   SET out_rec->event_prsnl[i].event_prsnl_action_id = cnvtstring(oreply->rb_list[1].
    event_prsnl_list[i].event_prsnl_id)
   SET out_rec->event_prsnl[i].action_type_disp = uar_get_code_display(oreply->rb_list[1].
    event_prsnl_list[i].action_type_cd)
   SET out_rec->event_prsnl[i].action_type_mean = uar_get_code_meaning(oreply->rb_list[1].
    event_prsnl_list[i].action_type_cd)
   SET out_rec->event_prsnl[i].action_type_value = cnvtstring(oreply->rb_list[1].event_prsnl_list[i].
    action_type_cd)
   SET out_rec->event_prsnl[i].action_dt_tm = datetimezoneformat(oreply->rb_list[1].event_prsnl_list[
    i].action_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
   SET out_rec->event_prsnl[i].action_status_disp = uar_get_code_display(oreply->rb_list[1].
    event_prsnl_list[i].action_status_cd)
   SET out_rec->event_prsnl[i].action_status_mean = uar_get_code_meaning(oreply->rb_list[1].
    event_prsnl_list[i].action_status_cd)
   SET out_rec->event_prsnl[i].action_status_value = cnvtstring(oreply->rb_list[1].event_prsnl_list[i
    ].action_status_cd)
   SET out_rec->event_prsnl[i].action_prsnl_id = cnvtstring(oreply->rb_list[1].event_prsnl_list[i].
    action_prsnl_id)
   SET out_rec->event_prsnl[i].request_prsnl_id = cnvtstring(oreply->rb_list[1].event_prsnl_list[i].
    request_prsnl_id)
   SET out_rec->event_prsnl[i].proxy_prsnl_id = cnvtstring(oreply->rb_list[1].event_prsnl_list[i].
    proxy_prsnl_id)
   SELECT INTO "nl:"
    FROM prsnl p
    PLAN (p
     WHERE (p.person_id=oreply->rb_list[1].event_prsnl_list[i].action_prsnl_id)
      AND p.person_id > 0)
    DETAIL
     out_rec->event_prsnl[i].action_prsnl = p.name_full_formatted, out_rec->event_prsnl[i].
     position_disp = uar_get_code_display(p.position_cd), out_rec->event_prsnl[i].position_mean =
     uar_get_code_meaning(p.position_cd),
     out_rec->event_prsnl[i].position_value = cnvtstring(p.position_cd), out_rec->event_prsnl[i].
     physician_ind = cnvtstring(p.physician_ind)
    WITH nocounter, time = 30
   ;end select
 ENDFOR
#exit_script
 CALL echojson(out_rec, $1)
END GO
