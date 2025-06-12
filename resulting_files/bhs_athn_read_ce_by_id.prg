CREATE PROGRAM bhs_athn_read_ce_by_id
 DECLARE moutputdevice = vc WITH noconstant( $1)
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
   1 events[*]
     2 event_id = vc
     2 event_code_disp = vc
     2 event_code_value = vc
     2 event_end_dt_tm = vc
     2 display = vc
     2 person_id = vc
     2 encounter_id = vc
     2 result_status_disp = vc
     2 result_status_mean = vc
     2 result_status_value = vc
     2 normalcy_disp = vc
     2 normalcy_mean = vc
     2 normalcy_value = vc
     2 order_id = vc
     2 updt_dt_tm = vc
     2 clinsig_updt_dt_tm = vc
     2 view_level = vc
     2 event_tag = vc
     2 contributor_system_disp = vc
     2 contributor_system_mean = vc
     2 contributor_system_value = vc
     2 parent_event_id = vc
     2 task_assay_value = vc
     2 record_status_disp = vc
     2 record_status_mean = vc
     2 record_status_value = vc
     2 publish = vc
     2 updt_cnt = vc
     2 entry_mode_disp = vc
     2 entry_mode_mean = vc
     2 entry_mode_value = vc
     2 value = vc
     2 result_units_disp = vc
     2 result_units_value = vc
     2 normal_low = vc
     2 normal_high = vc
     2 event_prsnl_actions[*]
       3 event_prsnl_id = vc
       3 event_id = vc
       3 action_type_disp = vc
       3 action_type_mean = vc
       3 action_type_value = vc
       3 action_dt_tm = vc
       3 action_status_disp = vc
       3 action_status_mean = vc
       3 action_status_value = vc
       3 action_prsnl = vc
       3 action_prsnl_id = vc
       3 action_prsnl_ft = vc
       3 request_dt_tm = vc
       3 request_prsnl = vc
       3 request_prsnl_id = vc
       3 request_comment = vc
       3 proxy_prsnl = vc
       3 proxy_prsnl_id = vc
       3 prsnl_group_id = vc
       3 prsnl_group = vc
 )
 DECLARE t_line = vc
 DECLARE t_line2 = vc
 DECLARE done = i2
 SET cnt = 0
 SET t_line =  $2
 WHILE (done=0)
   IF (findstring(",",t_line)=0)
    SET cnt += 1
    SET stat = alterlist(orequest->event_id_list,cnt)
    SET orequest->event_id_list[cnt].event_id = cnvtreal(t_line)
    SET done = 1
   ELSE
    SET cnt += 1
    SET t_line2 = substring(1,(findstring(",",t_line) - 1),t_line)
    SET stat = alterlist(orequest->event_id_list,cnt)
    SET orequest->event_id_list[cnt].event_id = cnvtreal(t_line2)
    SET t_line = substring((findstring(",",t_line)+ 1),textlen(t_line),t_line)
   ENDIF
 ENDWHILE
 SET orequest->query_mode = 1
 SET orequest->valid_from_dt_tm_ind = 1
 SET orequest->subtable_bit_map_ind = 1
 SET stat = tdbexecute(3200000,3200200,1000011,"REC",orequest,
  "REC",oreply)
 SET stat = alterlist(out_rec->events,size(oreply->rb_list,5))
 FOR (i = 1 TO size(oreply->rb_list,5))
   SET out_rec->events[i].event_id = cnvtstring(oreply->rb_list[i].event_id)
   SET out_rec->events[i].event_code_disp = uar_get_code_display(oreply->rb_list[i].event_cd)
   SET out_rec->events[i].event_code_value = cnvtstring(oreply->rb_list[i].event_cd)
   SET out_rec->events[i].event_end_dt_tm = datetimezoneformat(oreply->rb_list[i].event_end_dt_tm,
    curtimezoneapp,"MM/dd/yyyy HH:mm:ss",curtimezonedef)
   SET out_rec->events[i].display = concat(trim(oreply->rb_list[i].result_val)," ",trim(
     uar_get_code_display(oreply->rb_list[i].result_units_cd)))
   SET out_rec->events[i].person_id = cnvtstring(oreply->rb_list[i].person_id)
   SET out_rec->events[i].encounter_id = cnvtstring(oreply->rb_list[i].encntr_id)
   SET out_rec->events[i].result_status_disp = uar_get_code_display(oreply->rb_list[i].
    result_status_cd)
   SET out_rec->events[i].result_status_mean = uar_get_code_meaning(oreply->rb_list[i].
    result_status_cd)
   SET out_rec->events[i].result_status_value = cnvtstring(oreply->rb_list[i].result_status_cd)
   SET out_rec->events[i].normalcy_disp = uar_get_code_display(oreply->rb_list[i].normalcy_cd)
   SET out_rec->events[i].normalcy_mean = uar_get_code_meaning(oreply->rb_list[i].normalcy_cd)
   SET out_rec->events[i].normalcy_value = cnvtstring(oreply->rb_list[i].normalcy_cd)
   SET out_rec->events[i].order_id = cnvtstring(oreply->rb_list[i].order_id)
   SET out_rec->events[i].updt_dt_tm = datetimezoneformat(oreply->rb_list[i].updt_dt_tm,
    curtimezoneapp,"MM/dd/yyyy HH:mm:ss",curtimezonedef)
   SET out_rec->events[i].clinsig_updt_dt_tm = datetimezoneformat(oreply->rb_list[i].
    clinsig_updt_dt_tm,curtimezoneapp,"MM/dd/yyyy HH:mm:ss",curtimezonedef)
   SET out_rec->events[i].view_level = cnvtstring(oreply->rb_list[i].view_level)
   SET out_rec->events[i].event_tag = oreply->rb_list[i].event_tag
   SET out_rec->events[i].contributor_system_disp = uar_get_code_display(oreply->rb_list[i].
    contributor_system_cd)
   SET out_rec->events[i].contributor_system_mean = uar_get_code_meaning(oreply->rb_list[i].
    contributor_system_cd)
   SET out_rec->events[i].contributor_system_value = cnvtstring(oreply->rb_list[i].
    contributor_system_cd)
   SET out_rec->events[i].parent_event_id = cnvtstring(oreply->rb_list[i].parent_event_id)
   SET out_rec->events[i].task_assay_value = cnvtstring(oreply->rb_list[i].task_assay_cd)
   SET out_rec->events[i].record_status_disp = uar_get_code_display(oreply->rb_list[i].
    record_status_cd)
   SET out_rec->events[i].record_status_mean = uar_get_code_meaning(oreply->rb_list[i].
    record_status_cd)
   SET out_rec->events[i].record_status_value = cnvtstring(oreply->rb_list[i].record_status_cd)
   IF ((oreply->rb_list[i].publish_flag=1))
    SET out_rec->events[i].publish = "Published"
   ELSE
    SET out_rec->events[i].publish = "Unpublished"
   ENDIF
   SET out_rec->events[i].updt_cnt = cnvtstring(oreply->rb_list[i].updt_cnt)
   SET out_rec->events[i].entry_mode_disp = uar_get_code_display(oreply->rb_list[i].entry_mode_cd)
   SET out_rec->events[i].entry_mode_mean = uar_get_code_meaning(oreply->rb_list[i].entry_mode_cd)
   SET out_rec->events[i].entry_mode_value = cnvtstring(oreply->rb_list[i].entry_mode_cd)
   SET out_rec->events[i].value = oreply->rb_list[i].result_val
   SET out_rec->events[i].result_units_disp = uar_get_code_display(oreply->rb_list[i].result_units_cd
    )
   SET out_rec->events[i].result_units_value = cnvtstring(oreply->rb_list[i].result_units_cd)
   SET out_rec->events[i].normal_low = oreply->rb_list[i].normal_low
   SET out_rec->events[i].normal_high = oreply->rb_list[i].normal_high
   SET stat = alterlist(out_rec->events[i].event_prsnl_actions,size(oreply->rb_list[i].
     event_prsnl_list,5))
   FOR (j = 1 TO size(oreply->rb_list[i].event_prsnl_list,5))
     SET out_rec->events[i].event_prsnl_actions[j].event_prsnl_id = cnvtstring(oreply->rb_list[i].
      event_prsnl_list[j].event_prsnl_id)
     SET out_rec->events[i].event_prsnl_actions[j].event_id = cnvtstring(oreply->rb_list[i].
      event_prsnl_list[j].event_id)
     SET out_rec->events[i].event_prsnl_actions[j].action_type_disp = uar_get_code_display(oreply->
      rb_list[i].event_prsnl_list[j].action_type_cd)
     SET out_rec->events[i].event_prsnl_actions[j].action_type_mean = uar_get_code_meaning(oreply->
      rb_list[i].event_prsnl_list[j].action_type_cd)
     SET out_rec->events[i].event_prsnl_actions[j].action_type_value = cnvtstring(oreply->rb_list[i].
      event_prsnl_list[j].action_type_cd)
     SET out_rec->events[i].event_prsnl_actions[j].action_dt_tm = datetimezoneformat(oreply->rb_list[
      i].event_prsnl_list[j].action_dt_tm,curtimezoneapp,"MM/dd/yyyy HH:mm:ss",curtimezonedef)
     SET out_rec->events[i].event_prsnl_actions[j].action_status_disp = uar_get_code_display(oreply->
      rb_list[i].event_prsnl_list[j].action_status_cd)
     SET out_rec->events[i].event_prsnl_actions[j].action_status_mean = uar_get_code_meaning(oreply->
      rb_list[i].event_prsnl_list[j].action_status_cd)
     SET out_rec->events[i].event_prsnl_actions[j].action_status_value = cnvtstring(oreply->rb_list[i
      ].event_prsnl_list[j].action_status_cd)
     SELECT INTO "nl:"
      FROM prsnl pr
      PLAN (pr
       WHERE (pr.person_id=oreply->rb_list[i].event_prsnl_list[j].action_prsnl_id))
      HEAD REPORT
       out_rec->events[i].event_prsnl_actions[j].action_prsnl = pr.name_full_formatted
      WITH nocounter, time = 30
     ;end select
     SET out_rec->events[i].event_prsnl_actions[j].action_prsnl_id = cnvtstring(oreply->rb_list[i].
      event_prsnl_list[j].action_prsnl_id)
     SET out_rec->events[i].event_prsnl_actions[j].action_prsnl_ft = oreply->rb_list[i].
     event_prsnl_list[j].action_prsnl_ft
     SET out_rec->events[i].event_prsnl_actions[j].request_dt_tm = datetimezoneformat(oreply->
      rb_list[i].event_prsnl_list[j].request_dt_tm,curtimezoneapp,"MM/dd/yyyy HH:mm:ss",
      curtimezonedef)
     SELECT INTO "nl:"
      FROM prsnl pr
      PLAN (pr
       WHERE (pr.person_id=oreply->rb_list[i].event_prsnl_list[j].request_prsnl_id))
      HEAD REPORT
       out_rec->events[i].event_prsnl_actions[j].request_prsnl = pr.name_full_formatted
      WITH nocounter, time = 30
     ;end select
     SET out_rec->events[i].event_prsnl_actions[j].request_prsnl_id = cnvtstring(oreply->rb_list[i].
      event_prsnl_list[j].request_prsnl_id)
     SET out_rec->events[i].event_prsnl_actions[j].request_comment = oreply->rb_list[i].
     event_prsnl_list[j].request_comment
     SELECT INTO "nl:"
      FROM prsnl pr
      PLAN (pr
       WHERE (pr.person_id=oreply->rb_list[i].event_prsnl_list[j].proxy_prsnl_id))
      HEAD REPORT
       out_rec->events[i].event_prsnl_actions[j].proxy_prsnl = pr.name_full_formatted
      WITH nocounter, time = 30
     ;end select
     SET out_rec->events[i].event_prsnl_actions[j].proxy_prsnl_id = cnvtstring(oreply->rb_list[i].
      event_prsnl_list[j].proxy_prsnl_id)
     IF ((oreply->rb_list[i].event_prsnl_list[j].action_prsnl_group_id > 0))
      SET out_rec->events[i].event_prsnl_actions[j].prsnl_group_id = cnvtstring(oreply->rb_list[i].
       event_prsnl_list[j].action_prsnl_group_id)
      SELECT INTO "nl:"
       FROM prsnl_group pg
       PLAN (pg
        WHERE (pg.prsnl_group_id=oreply->rb_list[i].event_prsnl_list[j].action_prsnl_group_id))
       HEAD REPORT
        out_rec->events[i].event_prsnl_actions[j].prsnl_group = pg.prsnl_group_name
       WITH nocounter, time = 3o
      ;end select
     ENDIF
   ENDFOR
 ENDFOR
 EXECUTE bhs_athn_write_json_output
END GO
