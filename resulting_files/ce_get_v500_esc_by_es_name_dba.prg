CREATE PROGRAM ce_get_v500_esc_by_es_name:dba
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 SELECT INTO "nl:"
  FROM v500_event_set_code esc,
   code_value cv
  PLAN (esc
   WHERE esc.event_set_name=trim(request->event_set_name))
   JOIN (cv
   WHERE cv.code_value=esc.event_set_cd)
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->reply_list,(cnt+ 9))
   ENDIF
   reply->reply_list[cnt].display_association_ind = esc.display_association_ind, reply->reply_list[
   cnt].accumulation_ind = esc.accumulation_ind, reply->reply_list[cnt].category_flag = esc
   .category_flag,
   reply->reply_list[cnt].event_set_cd_definition = trim(esc.event_set_cd_definition), reply->
   reply_list[cnt].event_set_cd_descr = trim(esc.event_set_cd_descr), reply->reply_list[cnt].
   event_set_cd_disp = trim(esc.event_set_cd_disp),
   reply->reply_list[cnt].event_set_cd_disp_key = trim(esc.event_set_cd_disp_key), reply->reply_list[
   cnt].code_status_cd = esc.code_status_cd, reply->reply_list[cnt].event_set_cd = esc.event_set_cd,
   reply->reply_list[cnt].combine_format = esc.combine_format, reply->reply_list[cnt].
   event_set_color_name = trim(esc.event_set_color_name), reply->reply_list[cnt].event_set_icon_name
    = trim(esc.event_set_icon_name),
   reply->reply_list[cnt].event_set_name = trim(esc.event_set_name), reply->reply_list[cnt].
   event_set_name_key = trim(esc.event_set_name_key), reply->reply_list[cnt].event_set_status_cd =
   esc.event_set_status_cd,
   reply->reply_list[cnt].grouping_rule_flag = esc.grouping_rule_flag, reply->reply_list[cnt].
   leaf_event_cd_count = esc.leaf_event_cd_count, reply->reply_list[cnt].operation_display_flag = esc
   .operation_display_flag,
   reply->reply_list[cnt].operation_formula = trim(esc.operation_formula), reply->reply_list[cnt].
   primitive_event_set_count = esc.primitive_event_set_count, reply->reply_list[cnt].
   show_if_no_data_ind = esc.show_if_no_data_ind,
   reply->reply_list[cnt].updt_applctx = esc.updt_applctx, reply->reply_list[cnt].updt_cnt = esc
   .updt_cnt, reply->reply_list[cnt].updt_dt_tm = esc.updt_dt_tm,
   reply->reply_list[cnt].updt_id = esc.updt_id, reply->reply_list[cnt].updt_task = esc.updt_task,
   reply->reply_list[cnt].concept_cki = trim(cv.concept_cki)
  WITH nocounter
 ;end select
 SET reply->qual = cnt
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
 SET stat = alterlist(reply->reply_list,cnt)
END GO
