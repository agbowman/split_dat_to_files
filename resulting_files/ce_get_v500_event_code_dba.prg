CREATE PROGRAM ce_get_v500_event_code:dba
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 SELECT INTO "nl:"
  FROM v500_event_code ec
  WHERE (ec.event_cd=request->event_cd)
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->reply_list,(cnt+ 9))
   ENDIF
   reply->reply_list[cnt].event_cd = ec.event_cd, reply->reply_list[cnt].event_cd_definition = trim(
    ec.event_cd_definition), reply->reply_list[cnt].event_cd_descr = trim(ec.event_cd_descr),
   reply->reply_list[cnt].event_cd_disp = trim(ec.event_cd_disp), reply->reply_list[cnt].
   event_cd_disp_key = trim(ec.event_cd_disp_key), reply->reply_list[cnt].code_status_cd = ec
   .code_status_cd,
   reply->reply_list[cnt].def_docmnt_attributes = trim(ec.def_docmnt_attributes), reply->reply_list[
   cnt].def_docmnt_format_cd = ec.def_docmnt_format_cd, reply->reply_list[cnt].def_docmnt_storage_cd
    = ec.def_docmnt_storage_cd,
   reply->reply_list[cnt].def_event_class_cd = ec.def_event_class_cd, reply->reply_list[cnt].
   def_event_confid_level_cd = ec.def_event_confid_level_cd, reply->reply_list[cnt].def_event_level
    = ec.def_event_level,
   reply->reply_list[cnt].event_add_access_ind = ec.event_add_access_ind, reply->reply_list[cnt].
   event_cd_subclass_cd = ec.event_cd_subclass_cd, reply->reply_list[cnt].event_chg_access_ind = ec
   .event_chg_access_ind,
   reply->reply_list[cnt].event_set_name = trim(ec.event_set_name), reply->reply_list[cnt].
   retention_days = ec.retention_days, reply->reply_list[cnt].updt_applctx = ec.updt_applctx,
   reply->reply_list[cnt].updt_cnt = ec.updt_cnt, reply->reply_list[cnt].updt_dt_tm = ec.updt_dt_tm,
   reply->reply_list[cnt].updt_id = ec.updt_id,
   reply->reply_list[cnt].updt_task = ec.updt_task, reply->reply_list[cnt].event_code_status_cd = ec
   .event_code_status_cd, reply->reply_list[cnt].collating_seq = ec.collating_seq
  WITH nocounter
 ;end select
 SET reply->qual = cnt
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
 SET stat = alterlist(reply->reply_list,cnt)
END GO
