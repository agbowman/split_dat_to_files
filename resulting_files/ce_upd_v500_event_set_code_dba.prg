CREATE PROGRAM ce_upd_v500_event_set_code:dba
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 UPDATE  FROM v500_event_set_code t,
   (dummyt d  WITH seq = value(size(request->request_list,5)))
  SET t.code_status_cd =
   IF ((request->request_list[d.seq].code_status_cd=- (1))) 0
   ELSE request->request_list[d.seq].code_status_cd
   ENDIF
   , t.event_set_status_cd =
   IF ((request->request_list[d.seq].event_set_status_cd=- (1))) 0
   ELSE request->request_list[d.seq].event_set_status_cd
   ENDIF
   , t.updt_id = request->request_list[d.seq].updt_id,
   t.updt_dt_tm = cnvtdatetimeutc(request->request_list[d.seq].updt_dt_tm), t.event_set_name_key =
   trim(request->request_list[d.seq].event_set_name_key), t.event_set_name = trim(request->
    request_list[d.seq].event_set_name),
   t.event_set_cd_disp = trim(request->request_list[d.seq].event_set_cd_disp), t
   .event_set_cd_disp_key = trim(request->request_list[d.seq].event_set_cd_disp_key), t
   .event_set_cd_descr = trim(request->request_list[d.seq].event_set_cd_descr),
   t.event_set_cd_definition = trim(request->request_list[d.seq].event_set_cd_definition), t
   .event_set_icon_name = trim(request->request_list[d.seq].event_set_icon_name), t
   .event_set_color_name = trim(request->request_list[d.seq].event_set_color_name),
   t.combine_format = request->request_list[d.seq].combine_format, t.operation_formula = request->
   request_list[d.seq].operation_formula, t.leaf_event_cd_count = request->request_list[d.seq].
   leaf_event_cd_count,
   t.primitive_event_set_count = request->request_list[d.seq].primitive_event_set_count, t.updt_task
    = request->request_list[d.seq].updt_task, t.updt_cnt = request->request_list[d.seq].updt_cnt,
   t.updt_applctx = request->request_list[d.seq].updt_applctx, t.grouping_rule_flag = request->
   request_list[d.seq].grouping_rule_flag, t.operation_display_flag = request->request_list[d.seq].
   operation_display_flag,
   t.show_if_no_data_ind = request->request_list[d.seq].show_if_no_data_ind, t.accumulation_ind =
   request->request_list[d.seq].accumulation_ind, t.display_association_ind = request->request_list[d
   .seq].display_association_ind,
   t.category_flag = request->request_list[d.seq].category_flag
  PLAN (d)
   JOIN (t
   WHERE (t.event_set_cd=request->request_list[d.seq].event_set_cd))
  WITH counter
 ;end update
 SET error_code = error(error_msg,0)
 SET reply->num_updated = curqual
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
