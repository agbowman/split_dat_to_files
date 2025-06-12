CREATE PROGRAM bhs_athn_r_all_results_eset_v2
 RECORD orequest(
   1 query_mode = i4
   1 query_mode_ind = i2
   1 event_set_cd = f8
   1 person_id = f8
   1 order_id = f8
   1 encntr_id = f8
   1 encntr_financial_id = f8
   1 contributor_system_cd = f8
   1 accession_nbr = vc
   1 compress_flag = i2
   1 subtable_bit_map = i4
   1 subtable_bit_map_ind = i2
   1 small_subtable_bit_map = i4
   1 small_subtable_bit_map_ind = i2
   1 search_anchor_dt_tm = dq8
   1 search_anchor_dt_tm_ind = i2
   1 seconds_duration = f8
   1 direction_flag = i2
   1 events_to_fetch = i4
   1 date_flag = i2
   1 view_level = i4
   1 non_publish_flag = i2
   1 valid_from_dt_tm = dq8
   1 valid_from_dt_tm_ind = i2
   1 decode_flag = i2
   1 encntr_list[*]
     2 encntr_id = f8
   1 event_set_list[*]
     2 event_set_name = vc
   1 encntr_type_class_list[*]
     2 encntr_type_class_cd = f8
   1 order_id_list_ext[*]
     2 order_id = f8
   1 event_set_cd_list_ext[*]
     2 event_set_cd = f8
     2 event_set_name = vc
     2 fall_off_seconds_dur = f8
   1 ordering_provider_id = f8
   1 action_prsnl_id = f8
   1 query_mode2 = i4
   1 encntr_type_list[*]
     2 encntr_type_cd = f8
   1 end_of_day_tz = i4
   1 perform_prsnl_list[*]
     2 perform_prsnl_id = f8
   1 result_status_list[*]
     2 result_status_cd = f8
   1 search_begin_dt_tm = dq8
   1 search_end_dt_tm = dq8
   1 action_prsnl_group_id = f8
 )
 RECORD out_rec(
   1 event_set_name = vc
   1 event_set_disp = vc
   1 event_set_value = vc
   1 primitive = vc
   1 parent_value = vc
   1 children[*]
     2 event_set_name = vc
     2 event_set_disp = vc
     2 event_set_value = vc
     2 primitive = vc
     2 parent_value = vc
     2 collating_seq = vc
     2 event_codes[*]
       3 event_code_display = vc
       3 event_code_value = vc
       3 parent_value = vc
       3 event_list[*]
         4 event_type = vc
         4 event_id = vc
         4 event_code = vc
         4 event_code_disp = vc
         4 event_end_dt_tm = vc
         4 display = vc
         4 person_id = vc
         4 encounter_id = vc
         4 result_status_disp = vc
         4 result_status_mean = vc
         4 result_status_value = vc
         4 order_id = vc
         4 order_catalog_disp = vc
         4 order_catalog_value = vc
         4 order_catalog_desc = vc
         4 order_clin_disp_line = vc
         4 update_dt_tm = vc
         4 clinsig_updt_dt_tm = vc
         4 view_level = vc
         4 event_tag = vc
         4 contrib_sys_disp = vc
         4 contrib_sys_mean = vc
         4 contrib_sys_value = vc
         4 parent_event_id = vc
         4 task_assay = vc
         4 record_status_disp = vc
         4 record_status_mean = vc
         4 record_status_value = vc
         4 publish = vc
         4 collating_seq = vc
         4 update_cnt = vc
         4 entry_mode_disp = vc
         4 entry_mode_mean = vc
         4 entry_mode_value = vc
         4 title_text = vc
         4 document_type = vc
         4 accession_number = vc
         4 value = vc
         4 normalcy_mean = vc
         4 normalcy_value = vc
         4 normal_low = vc
         4 normal_high = vc
         4 critical_low = vc
         4 critital_high = vc
         4 result_unit_disp = vc
         4 result_unit_value = vc
         4 event_class_disp = vc
         4 event_class_mean = vc
         4 event_class_value = vc
         4 event_prsnl[*]
           5 event_prsnl_action_id = vc
           5 action_type_disp = vc
           5 action_type_mean = vc
           5 action_type_value = vc
           5 action_dt_tm = vc
           5 action_status_disp = vc
           5 action_status_mean = vc
           5 action_status_value = vc
           5 action_prsnl = vc
           5 action_prsnl_id = vc
           5 action_prsnl_ft = vc
           5 position_disp = vc
           5 position_mean = vc
           5 position_value = vc
           5 physician_ind = vc
           5 request_prsnl_id = vc
           5 request_comment = vc
           5 proxy_prsnl_id = vc
         4 selected_response[*]
           5 response_disp = vc
           5 response_value = vc
           5 nomenclature_id = vc
           5 mnemonic = vc
           5 short_string = vc
           5 seq = vc
           5 descriptor = vc
         4 event_note[*]
           5 event_note_id = vc
           5 date_time = vc
           5 type_disp = vc
           5 type_mean = vc
           5 type_value = vc
           5 format_disp = vc
           5 format_mean = vc
           5 format_value = vc
           5 importance = vc
           5 prsnl_id = vc
           5 body = vc
           5 entry_method_disp = vc
           5 entry_method_mean = vc
           5 entry_method_value = vc
           5 non_chartable_ind = vc
         4 med_result[*]
           5 provider_id = vc
           5 admin_dt_tm = vc
           5 admin_route_disp = vc
           5 admin_route_mean = vc
           5 admin_route_value = vc
           5 admin_site_disp = vc
           5 admin_site_mean = vc
           5 admin_site_value = vc
           5 admin_dose = vc
           5 admin_dose_units_disp = vc
           5 admin_dose_units_mean = vc
           5 admin_dose_units_value = vc
           5 admin_end_dt_tm = vc
         4 iv_event[*]
           5 iv_event_disp = vc
           5 iv_event_mean = vc
           5 iv_event_value = vc
           5 admin_site_disp = vc
           5 admin_site_mean = vc
           5 admin_site_value = vc
           5 admin_dose = vc
           5 admin_dose_units_disp = vc
           5 admin_dose_units_mean = vc
           5 admin_dose_units_value = vc
           5 initial_dosage = vc
           5 initial_dosage_units_disp = vc
           5 initial_dosage_units_mean = vc
           5 initial_dosage_units_value = vc
           5 initial_volume = vc
           5 initial_volume_units_disp = vc
           5 initial_volume_units_mean = vc
           5 initial_volume_units_value = vc
           5 infusion_rate = vc
           5 total_wasted_volume = vc
           5 synonym_id = vc
           5 order_action_seq = vc
           5 substance_lot_num = vc
 )
 SET orequest->person_id =  $2
 DECLARE t_line = vc
 DECLARE t_line2 = vc
 DECLARE done = i2
 SET cnt = 0
 SET t_line =  $3
 IF (( $3=""))
  SELECT INTO "nl:"
   FROM encounter e
   PLAN (e
    WHERE (e.person_id= $2))
   ORDER BY e.encntr_id
   HEAD e.encntr_id
    cnt += 1, stat = alterlist(orequest->encntr_list,cnt), orequest->encntr_list[cnt].encntr_id = e
    .encntr_id
   WITH nocounter, time = 30
  ;end select
 ELSE
  WHILE (done=0)
    IF (findstring(",",t_line)=0)
     SET cnt += 1
     SET stat = alterlist(orequest->encntr_list,cnt)
     SET orequest->encntr_list[cnt].encntr_id = cnvtreal(t_line)
     SET done = 1
    ELSE
     SET cnt += 1
     SET t_line2 = substring(1,(findstring(",",t_line) - 1),t_line)
     SET stat = alterlist(orequest->encntr_list,cnt)
     SET orequest->encntr_list[cnt].encntr_id = cnvtreal(t_line2)
     SET t_line = substring((findstring(",",t_line)+ 1),textlen(t_line),t_line)
    ENDIF
  ENDWHILE
 ENDIF
 SET date_line = substring(1,10, $4)
 SET time_line = substring(12,8, $4)
 SET orequest->search_begin_dt_tm = cnvtdatetimeutc2(date_line,"YYYY-MM-DD",time_line,"HH;mm;ss",0)
 SET date_line = substring(1,10, $5)
 SET time_line = substring(12,8, $5)
 SET orequest->search_end_dt_tm = cnvtdatetimeutc2(date_line,"YYYY-MM-DD",time_line,"HH;mm;ss",0)
 SET orequest->event_set_cd = uar_get_code_by("DISPLAY",93, $6)
 DECLARE event_note_ind = i2
 SET event_note_ind =  $7
 DECLARE event_prsnl_ind = i2
 SET event_prsnl_ind =  $8
 SET orequest->query_mode2 = 3
 SET orequest->valid_from_dt_tm_ind = 1
 SET orequest->decode_flag = 1
 SET orequest->subtable_bit_map_ind = 1
 SET orequest->compress_flag = 1
 DECLARE code_set = f8
 SET stat = tdbexecute(3200000,3200200,1000001,"REC",orequest,
  "REC",oreply)
 IF (size(oreply->rb_list,5) <= 0)
  GO TO end_prog
 ENDIF
 SET out_rec->event_set_name = oreply->rb_list.event_set_list[1].self_name
 SET out_rec->event_set_disp = oreply->rb_list.event_set_list[1].self_disp
 SET out_rec->event_set_value = cnvtstring(oreply->rb_list.event_set_list[1].self_cd)
 IF ((oreply->rb_list.event_set_list[1].primitive_ind=1))
  SET out_rec->primitive = "true"
 ELSE
  SET out_rec->primitive = "false"
 ENDIF
 SET out_rec->parent_value = cnvtstring(oreply->rb_list.event_set_list[1].parent_event_set_cd)
 SET cnt = 0
 FOR (i = 2 TO size(oreply->rb_list.event_set_list,5))
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE (cv.code_value=oreply->rb_list.event_set_list[i].self_cd))
    DETAIL
     code_set = cv.code_set
    WITH nocounter, time = 30
   ;end select
   IF (code_set=93)
    SET cnt += 1
    SET stat = alterlist(out_rec->children,cnt)
    SET out_rec->children[cnt].event_set_name = oreply->rb_list.event_set_list[i].self_name
    SET out_rec->children[cnt].event_set_disp = oreply->rb_list.event_set_list[i].self_disp
    SET out_rec->children[cnt].event_set_value = cnvtstring(oreply->rb_list.event_set_list[i].self_cd
     )
    SET out_rec->children[cnt].parent_value = cnvtstring(oreply->rb_list.event_set_list[i].
     parent_event_set_cd)
    IF ((oreply->rb_list.event_set_list[i].primitive_ind=1))
     SET out_rec->children[cnt].primitive = "true"
    ELSE
     SET out_rec->children[cnt].primitive = "false"
    ENDIF
    SET out_rec->children[cnt].collating_seq = cnvtstring(oreply->rb_list.event_set_list[i].
     collating_seq)
   ENDIF
   IF (code_set=72)
    IF (cnt=0)
     SET cnt += 1
     SET stat = alterlist(out_rec->children,cnt)
    ENDIF
    SET stat = alterlist(out_rec->children[cnt].event_codes,1)
    SET out_rec->children[cnt].event_codes[1].event_code_display = oreply->rb_list.event_set_list[i].
    self_disp
    SET out_rec->children[cnt].event_codes[1].event_code_value = cnvtstring(oreply->rb_list.
     event_set_list[i].self_cd)
    SET out_rec->children[cnt].event_codes[1].parent_value = cnvtstring(oreply->rb_list.
     event_set_list[i].parent_event_set_cd)
   ENDIF
 ENDFOR
 FOR (i = 1 TO size(oreply->rb_list.event_list,5))
   FOR (j = 1 TO size(out_rec->children,5))
     IF ((cnvtstring(oreply->rb_list.event_list[i].event_cd)=out_rec->children[j].event_codes[1].
     event_code_value))
      SET stat = alterlist(out_rec->children[j].event_codes[1].event_list,(size(out_rec->children[j].
        event_codes[1].event_list,5)+ 1))
      SET e_cnt = size(out_rec->children[j].event_codes[1].event_list,5)
      IF (uar_get_code_description(oreply->rb_list.event_list[i].event_class_cd) IN ("mdoc",
      "Radiology", "Microbiology", "Document"))
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_type = "DocumentSummary"
      ELSEIF (uar_get_code_description(oreply->rb_list.event_list[i].event_class_cd)="Text")
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_type = "TextResult"
       IF (size(oreply->rb_list.event_list[i].coded_result_list,5) >= 1)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_type = "CodedResult"
       ENDIF
      ELSEIF (uar_get_code_description(oreply->rb_list.event_list[i].event_class_cd)="Numeric")
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_type = "NumericResult"
      ELSEIF (uar_get_code_description(oreply->rb_list.event_list[i].event_class_cd)="Group Event")
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_type = "GroupResult"
      ELSEIF (uar_get_code_description(oreply->rb_list.event_list[i].event_class_cd)="Medication")
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_type = "MedicationResult"
       IF (size(oreply->rb_list.event_list[i].med_result_list,5) > 0)
        IF ((oreply->rb_list.event_list[i].med_result_list.iv_event_cd > 0))
         SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_type = "IVEventResult"
        ENDIF
       ENDIF
      ELSEIF (uar_get_code_description(oreply->rb_list.event_list[i].event_class_cd)="Date Result")
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_type = "DateResult"
      ELSEIF (uar_get_code_description(oreply->rb_list.event_list[i].event_class_cd)="Immunization")
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_type = "ImmunizationResult"
      ELSEIF (uar_get_code_description(oreply->rb_list.event_list[i].event_class_cd)="Done Charted")
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_type = "UnknownResult"
      ELSE
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_type = "UnknownResult"
      ENDIF
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_id = cnvtstring(oreply->rb_list
       .event_list[i].event_id)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_code = cnvtstring(oreply->
       rb_list.event_list[i].event_cd)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_code_disp =
      uar_get_code_display(oreply->rb_list.event_list[i].event_cd)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_end_dt_tm = datetimezoneformat(
       oreply->rb_list.event_list[i].event_end_dt_tm,oreply->rb_list.event_list[i].event_end_tz,
       "MM/dd/yyyy HH:mm:ss",curtimezonedef)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].display = concat(trim(oreply->rb_list
        .event_list[i].result_val)," ",trim(uar_get_code_display(oreply->rb_list.event_list[i].
         result_units_cd)))
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].person_id = cnvtstring(oreply->
       rb_list.event_list[i].person_id)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].encounter_id = cnvtstring(oreply->
       rb_list.event_list[i].encntr_id)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].result_status_disp =
      uar_get_code_display(oreply->rb_list.event_list[i].result_status_cd)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].result_status_mean =
      uar_get_code_meaning(oreply->rb_list.event_list[i].result_status_cd)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].result_status_value = cnvtstring(
       oreply->rb_list.event_list[i].result_status_cd)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].order_id = cnvtstring(oreply->rb_list
       .event_list[i].order_id)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].order_catalog_disp =
      uar_get_code_display(oreply->rb_list.event_list[i].catalog_cd)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].order_catalog_value = cnvtstring(
       oreply->rb_list.event_list[i].catalog_cd)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].order_catalog_desc =
      uar_get_code_description(oreply->rb_list.event_list[i].catalog_cd)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].update_dt_tm = datetimezoneformat(
       oreply->rb_list.event_list[i].updt_dt_tm,oreply->rb_list.event_list[i].event_end_tz,
       "MM/dd/yyyy HH:mm:ss",curtimezonedef)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].clinsig_updt_dt_tm =
      datetimezoneformat(oreply->rb_list.event_list[i].clinsig_updt_dt_tm,oreply->rb_list.event_list[
       i].event_end_tz,"MM/dd/yyyy HH:mm:ss",curtimezonedef)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].view_level = cnvtstring(oreply->
       rb_list.event_list[i].view_level)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_tag = oreply->rb_list.
      event_list[i].event_tag
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].contrib_sys_disp =
      uar_get_code_display(oreply->rb_list.event_list[i].contributor_system_cd)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].contrib_sys_mean =
      uar_get_code_meaning(oreply->rb_list.event_list[i].contributor_system_cd)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].contrib_sys_value = cnvtstring(oreply
       ->rb_list.event_list[i].contributor_system_cd)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].parent_event_id = cnvtstring(oreply->
       rb_list.event_list[i].parent_event_id)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].task_assay = cnvtstring(oreply->
       rb_list.event_list[i].task_assay_cd)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].record_status_disp =
      uar_get_code_display(oreply->rb_list.event_list[i].record_status_cd)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].record_status_mean =
      uar_get_code_meaning(oreply->rb_list.event_list[i].record_status_cd)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].record_status_value = cnvtstring(
       oreply->rb_list.event_list[i].record_status_cd)
      IF ((oreply->rb_list.event_list[i].publish_flag=1))
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].publish = "Published"
      ELSE
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].publish = "NonPublished"
      ENDIF
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].collating_seq = cnvtstring(oreply->
       rb_list.event_list[i].collating_seq)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].update_cnt = cnvtstring(oreply->
       rb_list.event_list[i].updt_cnt)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].entry_mode_disp =
      uar_get_code_display(oreply->rb_list.event_list[i].entry_mode_cd)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].entry_mode_mean =
      uar_get_code_meaning(oreply->rb_list.event_list[i].entry_mode_cd)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].entry_mode_value = cnvtstring(oreply
       ->rb_list.event_list[i].entry_mode_cd)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].title_text = oreply->rb_list.
      event_list[i].event_title_text
      IF (uar_get_displaykey(oreply->rb_list.event_list[i].event_class_cd)="MDOC")
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].document_type = "MasterDocument"
      ELSEIF (uar_get_displaykey(oreply->rb_list.event_list[i].event_class_cd)="RADIOLOGY")
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].document_type = "RadiologyResult"
      ELSEIF (uar_get_displaykey(oreply->rb_list.event_list[i].event_class_cd)="MBO")
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].document_type =
       "MicrobiologyProcedure"
      ELSEIF (uar_get_displaykey(oreply->rb_list.event_list[i].event_class_cd)="DOC")
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].document_type = "SingleDocument"
      ELSEIF (uar_get_displaykey(oreply->rb_list.event_list[i].event_class_cd)="DOCUMENT")
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].document_type = "SingleDocument"
      ELSEIF (uar_get_displaykey(oreply->rb_list.event_list[i].event_class_cd)="ATTACHMENT")
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].document_type = "Attachment"
      ELSE
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].document_type = "Unknown"
      ENDIF
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].accession_number = oreply->rb_list.
      event_list[i].accession_nbr
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].value = oreply->rb_list.event_list[i]
      .result_val
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].normalcy_mean = uar_get_displaykey(
       oreply->rb_list.event_list[i].normalcy_cd)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].normalcy_value = cnvtstring(oreply->
       rb_list.event_list[i].normalcy_cd)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].normal_low = oreply->rb_list.
      event_list[i].normal_low
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].normal_high = oreply->rb_list.
      event_list[i].normal_high
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].critical_low = oreply->rb_list.
      event_list[i].critical_low
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].critital_high = oreply->rb_list.
      event_list[i].critical_high
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].result_unit_disp =
      uar_get_code_display(oreply->rb_list.event_list[i].result_units_cd)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].result_unit_value = cnvtstring(oreply
       ->rb_list.event_list[i].result_units_cd)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_class_disp =
      uar_get_code_display(oreply->rb_list.event_list[i].event_class_cd)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_class_mean =
      uar_get_code_meaning(oreply->rb_list.event_list[i].event_class_cd)
      SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_class_value = cnvtstring(oreply
       ->rb_list.event_list[i].event_class_cd)
      IF (event_prsnl_ind=1)
       SET stat = alterlist(out_rec->children[j].event_codes[1].event_list[e_cnt].event_prsnl,size(
         oreply->rb_list.event_list[i].event_prsnl_list,5))
       FOR (k = 1 TO size(oreply->rb_list.event_list[i].event_prsnl_list,5))
         SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_prsnl[k].
         event_prsnl_action_id = cnvtstring(oreply->rb_list.event_list[i].event_prsnl_list[k].
          event_prsnl_id)
         SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_prsnl[k].action_type_disp =
         uar_get_code_display(oreply->rb_list.event_list[i].event_prsnl_list[k].action_type_cd)
         SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_prsnl[k].action_type_mean =
         uar_get_code_meaning(oreply->rb_list.event_list[i].event_prsnl_list[k].action_type_cd)
         SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_prsnl[k].action_type_value
          = cnvtstring(oreply->rb_list.event_list[i].event_prsnl_list[k].action_type_cd)
         SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_prsnl[k].action_dt_tm =
         datetimezoneformat(oreply->rb_list.event_list[i].event_prsnl_list[k].action_dt_tm,oreply->
          rb_list.event_list[i].event_end_tz,"MM/dd/yyyy HH:mm:ss",curtimezonedef)
         SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_prsnl[k].action_status_disp
          = uar_get_code_display(oreply->rb_list.event_list[i].event_prsnl_list[k].action_status_cd)
         SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_prsnl[k].action_status_mean
          = uar_get_code_meaning(oreply->rb_list.event_list[i].event_prsnl_list[k].action_status_cd)
         SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_prsnl[k].action_status_value
          = cnvtstring(oreply->rb_list.event_list[i].event_prsnl_list[k].action_status_cd)
         SELECT INTO "nl:"
          FROM prsnl p
          PLAN (p
           WHERE (p.person_id=oreply->rb_list.event_list[i].event_prsnl_list[k].action_prsnl_id)
            AND p.person_id > 0)
          DETAIL
           out_rec->children[j].event_codes[1].event_list[e_cnt].event_prsnl[k].action_prsnl = p
           .name_full_formatted, out_rec->children[j].event_codes[1].event_list[e_cnt].event_prsnl[k]
           .position_disp = uar_get_code_display(p.position_cd), out_rec->children[j].event_codes[1].
           event_list[e_cnt].event_prsnl[k].position_mean = uar_get_code_meaning(p.position_cd),
           out_rec->children[j].event_codes[1].event_list[e_cnt].event_prsnl[k].position_value =
           cnvtstring(p.position_cd), out_rec->children[j].event_codes[1].event_list[e_cnt].
           event_prsnl[k].physician_ind = cnvtstring(p.physician_ind)
          WITH nocounter, time = 30
         ;end select
         SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_prsnl[k].action_prsnl_id =
         cnvtstring(oreply->rb_list.event_list[i].event_prsnl_list[k].action_prsnl_id)
         SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_prsnl[k].action_prsnl_ft =
         oreply->rb_list.event_list[i].event_prsnl_list[k].action_prsnl_ft
         SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_prsnl[k].request_prsnl_id =
         cnvtstring(oreply->rb_list.event_list[i].event_prsnl_list[k].request_prsnl_id)
         SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_prsnl[k].request_comment =
         oreply->rb_list.event_list[i].event_prsnl_list[k].request_comment
         SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_prsnl[k].proxy_prsnl_id =
         cnvtstring(oreply->rb_list.event_list[i].event_prsnl_list[k].proxy_prsnl_id)
       ENDFOR
      ENDIF
      IF (size(oreply->rb_list.event_list[i].coded_result_list,5) > 0)
       SET stat = alterlist(out_rec->children[j].event_codes[1].event_list[e_cnt].selected_response,1
        )
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].selected_response[1].response_disp
        = uar_get_code_display(oreply->rb_list.event_list[i].coded_result_list.result_cd)
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].selected_response[1].response_value
        = cnvtstring(oreply->rb_list.event_list[i].coded_result_list.result_cd)
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].selected_response[1].nomenclature_id
        = cnvtstring(oreply->rb_list.event_list[i].coded_result_list.nomenclature_id)
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].selected_response[1].mnemonic =
       oreply->rb_list.event_list[i].coded_result_list.mnemonic
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].selected_response[1].short_string =
       oreply->rb_list.event_list[i].coded_result_list.short_string
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].selected_response[1].seq =
       cnvtstring(oreply->rb_list.event_list[i].coded_result_list.sequence_nbr)
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].selected_response[1].descriptor =
       oreply->rb_list.event_list[i].coded_result_list.descriptor
      ENDIF
      IF (event_note_ind=1
       AND size(oreply->rb_list.event_list[i].event_note_list,5) > 0)
       SET stat = alterlist(out_rec->children[j].event_codes[1].event_list[e_cnt].event_note,1)
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_note[1].event_note_id =
       cnvtstring(oreply->rb_list.event_list[i].event_note_list.ce_event_note_id)
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_note[1].date_time =
       datetimezoneformat(oreply->rb_list.event_list[i].event_note_list.note_dt_tm,oreply->rb_list.
        event_list[i].event_end_tz,"MM/dd/yyyy HH:mm:ss",curtimezonedef)
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_note[1].type_disp =
       uar_get_code_display(oreply->rb_list.event_list[i].event_note_list.note_type_cd)
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_note[1].type_mean =
       uar_get_code_meaning(oreply->rb_list.event_list[i].event_note_list.note_type_cd)
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_note[1].type_value =
       cnvtstring(oreply->rb_list.event_list[i].event_note_list.note_type_cd)
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_note[1].format_disp =
       uar_get_code_display(oreply->rb_list.event_list[i].event_note_list.note_format_cd)
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_note[1].format_mean =
       uar_get_code_meaning(oreply->rb_list.event_list[i].event_note_list.note_format_cd)
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_note[1].format_value =
       cnvtstring(oreply->rb_list.event_list[i].event_note_list.note_format_cd)
       IF ((oreply->rb_list.event_list[i].event_note_list.importance_flag=1))
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_note[1].importance = "Low"
       ELSEIF ((oreply->rb_list.event_list[i].event_note_list.importance_flag=2))
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_note[1].importance = "Medium"
       ELSEIF ((oreply->rb_list.event_list[i].event_note_list.importance_flag=4))
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_note[1].importance = "High"
       ENDIF
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_note[1].prsnl_id = cnvtstring(
        oreply->rb_list.event_list[i].event_note_list.note_prsnl_id)
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_note[1].body = oreply->rb_list
       .event_list[i].event_note_list.long_blob
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_note[1].entry_method_disp =
       uar_get_code_display(oreply->rb_list.event_list[i].event_note_list.entry_method_cd)
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_note[1].entry_method_mean =
       uar_get_code_meaning(oreply->rb_list.event_list[i].event_note_list.entry_method_cd)
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_note[1].entry_method_value =
       cnvtstring(oreply->rb_list.event_list[i].event_note_list.entry_method_cd)
       SET out_rec->children[j].event_codes[1].event_list[e_cnt].event_note[1].non_chartable_ind =
       cnvtstring(oreply->rb_list.event_list[i].event_note_list.non_chartable_flag)
      ENDIF
      IF (size(oreply->rb_list.event_list[i].med_result_list,5) > 0)
       IF ((oreply->rb_list.event_list[i].med_result_list.iv_event_cd=0))
        SET stat = alterlist(out_rec->children[j].event_codes[1].event_list[e_cnt].med_result,1)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].med_result[1].provider_id =
        cnvtstring(oreply->rb_list.event_list[i].med_result_list.admin_prov_id)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].med_result[1].admin_dt_tm =
        datetimezoneformat(oreply->rb_list.event_list[i].med_result_list.admin_start_dt_tm,oreply->
         rb_list.event_list[i].event_end_tz,"MM/dd/yyyy HH:mm:ss",curtimezonedef)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].med_result[1].admin_route_disp =
        uar_get_code_display(oreply->rb_list.event_list[i].med_result_list.admin_route_cd)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].med_result[1].admin_route_mean =
        uar_get_code_meaning(oreply->rb_list.event_list[i].med_result_list.admin_route_cd)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].med_result[1].admin_route_value =
        cnvtstring(oreply->rb_list.event_list[i].med_result_list.admin_route_cd)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].med_result[1].admin_site_disp =
        uar_get_code_display(oreply->rb_list.event_list[i].med_result_list.admin_site_cd)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].med_result[1].admin_site_mean =
        uar_get_code_meaning(oreply->rb_list.event_list[i].med_result_list.admin_site_cd)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].med_result[1].admin_site_value =
        cnvtstring(oreply->rb_list.event_list[i].med_result_list.admin_site_cd)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].med_result[1].admin_dose =
        cnvtstring(oreply->rb_list.event_list[i].med_result_list.admin_dosage,12,2)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].med_result[1].admin_dose_units_disp
         = uar_get_code_display(oreply->rb_list.event_list[i].med_result_list.dosage_unit_cd)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].med_result[1].admin_dose_units_mean
         = uar_get_code_meaning(oreply->rb_list.event_list[i].med_result_list.dosage_unit_cd)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].med_result[1].
        admin_dose_units_value = cnvtstring(oreply->rb_list.event_list[i].med_result_list.
         dosage_unit_cd)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].med_result[1].admin_end_dt_tm =
        datetimezoneformat(oreply->rb_list.event_list[i].med_result_list.admin_end_dt_tm,oreply->
         rb_list.event_list[i].event_end_tz,"MM/dd/yyyy HH:mm:ss",curtimezonedef)
       ENDIF
      ENDIF
      IF (size(oreply->rb_list.event_list[i].med_result_list,5) > 0)
       IF ((oreply->rb_list.event_list[i].med_result_list.iv_event_cd > 0))
        SET stat = alterlist(out_rec->children[j].event_codes[1].event_list[e_cnt].iv_event,1)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].iv_event[1].iv_event_disp =
        uar_get_code_display(oreply->rb_list.event_list[i].med_result_list.iv_event_cd)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].iv_event[1].iv_event_mean =
        uar_get_code_meaning(oreply->rb_list.event_list[i].med_result_list.iv_event_cd)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].iv_event[1].iv_event_value =
        cnvtstring(oreply->rb_list.event_list[i].med_result_list.iv_event_cd)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].iv_event[1].admin_site_disp =
        uar_get_code_display(oreply->rb_list.event_list[i].med_result_list.admin_site_cd)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].iv_event[1].admin_site_mean =
        uar_get_code_meaning(oreply->rb_list.event_list[i].med_result_list.admin_site_cd)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].iv_event[1].admin_site_value =
        cnvtstring(oreply->rb_list.event_list[i].med_result_list.admin_site_cd)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].iv_event[1].admin_dose = cnvtstring
        (oreply->rb_list.event_list[i].med_result_list.admin_dosage,12,2)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].iv_event[1].admin_dose_units_disp
         = uar_get_code_display(oreply->rb_list.event_list[i].med_result_list.dosage_unit_cd)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].iv_event[1].admin_dose_units_mean
         = uar_get_code_meaning(oreply->rb_list.event_list[i].med_result_list.dosage_unit_cd)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].iv_event[1].admin_dose_units_value
         = cnvtstring(oreply->rb_list.event_list[i].med_result_list.dosage_unit_cd)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].iv_event[1].initial_dosage =
        cnvtstring(oreply->rb_list.event_list[i].med_result_list.initial_dosage,12,2)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].iv_event[1].
        initial_dosage_units_disp = uar_get_code_display(oreply->rb_list.event_list[i].
         med_result_list.dosage_unit_cd)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].iv_event[1].
        initial_dosage_units_mean = uar_get_code_meaning(oreply->rb_list.event_list[i].
         med_result_list.dosage_unit_cd)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].iv_event[1].
        initial_dosage_units_value = cnvtstring(oreply->rb_list.event_list[i].med_result_list.
         dosage_unit_cd)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].iv_event[1].initial_volume =
        cnvtstring(oreply->rb_list.event_list[i].med_result_list.initial_volume,12,2)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].iv_event[1].
        initial_volume_units_disp = uar_get_code_display(oreply->rb_list.event_list[i].
         med_result_list.infused_volume_unit_cd)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].iv_event[1].
        initial_volume_units_mean = uar_get_code_meaning(oreply->rb_list.event_list[i].
         med_result_list.infused_volume_unit_cd)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].iv_event[1].
        initial_volume_units_value = cnvtstring(oreply->rb_list.event_list[i].med_result_list.
         infused_volume_unit_cd)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].iv_event[1].
        initial_volume_units_value = cnvtstring(oreply->rb_list.event_list[i].med_result_list.
         infused_volume_unit_cd)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].iv_event[1].infusion_rate =
        cnvtstring(oreply->rb_list.event_list[i].med_result_list.infusion_rate)
        IF ((out_rec->children[j].event_codes[1].event_list[e_cnt].iv_event[1].iv_event_disp="Waste")
        )
         SET out_rec->children[j].event_codes[1].event_list[e_cnt].iv_event[1].total_wasted_volume =
         out_rec->children[j].event_codes[1].event_list[e_cnt].iv_event[1].admin_dose
        ENDIF
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].iv_event[1].synonym_id = cnvtstring
        (oreply->rb_list.event_list[i].med_result_list.synonym_id)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].iv_event[1].order_action_seq =
        cnvtstring(oreply->rb_list.event_list[i].order_action_sequence)
        SET out_rec->children[j].event_codes[1].event_list[e_cnt].iv_event[1].substance_lot_num =
        oreply->rb_list.event_list[i].med_result_list.substance_lot_number
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
 ENDFOR
 FOR (i = 1 TO size(out_rec->children,5))
   FOR (j = 1 TO size(out_rec->children[i].event_codes,5))
     FOR (k = 1 TO size(out_rec->children[i].event_codes[j],5))
       FOR (l = 1 TO size(out_rec->children[i].event_codes[j].event_list,5))
         SELECT INTO "nl:"
          FROM orders o
          PLAN (o
           WHERE o.order_id=cnvtreal(out_rec->children[i].event_codes[j].event_list[l].order_id))
          HEAD REPORT
           out_rec->children[i].event_codes[j].event_list[l].order_clin_disp_line = o
           .clinical_display_line
          WITH nocounter, time = 30
         ;end select
       ENDFOR
     ENDFOR
   ENDFOR
 ENDFOR
#end_prog
 SET _memory_reply_string = cnvtrectojson(out_rec)
 FREE RECORD out_rec
END GO
