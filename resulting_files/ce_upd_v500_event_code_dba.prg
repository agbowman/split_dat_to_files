CREATE PROGRAM ce_upd_v500_event_code:dba
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 UPDATE  FROM v500_event_code t,
   (dummyt d  WITH seq = value(size(request->request_list,5)))
  SET t.event_cd_disp = trim(request->request_list[d.seq].event_cd_disp), t.event_cd_disp_key = trim(
    request->request_list[d.seq].event_cd_disp_key), t.event_add_access_ind = request->request_list[d
   .seq].event_add_access_ind,
   t.event_cd_subclass_cd =
   IF ((request->request_list[d.seq].event_cd_subclass_cd=- (1))) 0
   ELSE request->request_list[d.seq].event_cd_subclass_cd
   ENDIF
   , t.event_chg_access_ind = request->request_list[d.seq].event_chg_access_ind, t.event_cd_descr =
   request->request_list[d.seq].event_cd_descr,
   t.event_cd_definition = request->request_list[d.seq].event_cd_definition, t.def_event_level =
   request->request_list[d.seq].def_event_level, t.def_event_class_cd =
   IF ((request->request_list[d.seq].def_event_class_cd=- (1))) 0
   ELSE request->request_list[d.seq].def_event_class_cd
   ENDIF
   ,
   t.def_event_confid_level_cd =
   IF ((request->request_list[d.seq].def_event_confid_level_cd=- (1))) 0
   ELSE request->request_list[d.seq].def_event_confid_level_cd
   ENDIF
   , t.def_docmnt_storage_cd =
   IF ((request->request_list[d.seq].def_docmnt_storage_cd=- (1))) 0
   ELSE request->request_list[d.seq].def_docmnt_storage_cd
   ENDIF
   , t.def_docmnt_format_cd =
   IF ((request->request_list[d.seq].def_docmnt_format_cd=- (1))) 0
   ELSE request->request_list[d.seq].def_docmnt_format_cd
   ENDIF
   ,
   t.def_docmnt_attributes = request->request_list[d.seq].def_docmnt_attributes, t.event_set_name =
   request->request_list[d.seq].event_set_name, t.code_status_cd =
   IF ((request->request_list[d.seq].code_status_cd=- (1))) 0
   ELSE request->request_list[d.seq].code_status_cd
   ENDIF
   ,
   t.event_code_status_cd =
   IF ((request->request_list[d.seq].event_code_status_cd=- (1))) 0
   ELSE request->request_list[d.seq].event_code_status_cd
   ENDIF
   , t.retention_days = request->request_list[d.seq].retention_days, t.collating_seq = request->
   request_list[d.seq].collating_seq,
   t.updt_dt_tm = cnvtdatetimeutc(request->request_list[d.seq].updt_dt_tm), t.updt_task = request->
   request_list[d.seq].updt_task, t.updt_id = request->request_list[d.seq].updt_id,
   t.updt_cnt = request->request_list[d.seq].updt_cnt, t.updt_applctx = request->request_list[d.seq].
   updt_applctx
  PLAN (d)
   JOIN (t
   WHERE (t.event_cd=request->request_list[d.seq].event_cd))
  WITH counter
 ;end update
 SET error_code = error(error_msg,0)
 SET reply->num_updated = curqual
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
