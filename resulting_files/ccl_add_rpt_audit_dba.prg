CREATE PROGRAM ccl_add_rpt_audit:dba
 RECORD reply(
   1 report_audit_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE _statusflag = c1
 DECLARE _errmsg = c132
 DECLARE _report_audit_seq = f8
 DECLARE _long_text_id = f8
 DECLARE _orig_crm_reqnum = i4
 DECLARE _obj_params = vc
 DECLARE prsnl_id = f8
 DECLARE _orig_crm_appnum = i4
 SET reply->status_data.status = "F"
 SET _statusflag = "F"
 SET _errmsg = fillstring(132," ")
 SET _report_audit_seq = 0
 SET _long_text_id = 0.0
 IF (validate(request->crm_reqnum,0) > 0)
  SET _orig_crm_reqnum = request->crm_reqnum
 ELSE
  SET _orig_crm_reqnum = reqinfo->updt_req
 ENDIF
 IF ((request->person_id > 0))
  SET prsnl_id = request->person_id
 ELSE
  SET prsnl_id = reqinfo->updt_id
 ENDIF
 IF (validate(request->crm_appnum,0) > 0)
  SET _orig_crm_appnum = request->crm_appnum
 ELSE
  SET _orig_crm_appnum = reqinfo->updt_app
 ENDIF
 SUBROUTINE insert_long_text(audit_seq)
  SELECT INTO "nl:"
   longtext_id = seq(long_data_seq,nextval)
   FROM dual
   DETAIL
    _long_text_id = longtext_id
   WITH nocounter
  ;end select
  INSERT  FROM long_text lt
   SET lt.long_text_id = _long_text_id, lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(sysdate),
    lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
    updt_applctx,
    lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
    cnvtdatetime(sysdate),
    lt.active_status_prsnl_id = reqinfo->updt_id, lt.parent_entity_name = "CCL_REPORT_AUDIT", lt
    .parent_entity_id = audit_seq,
    lt.long_text = request->long_text
   WITH nocounter
  ;end insert
 END ;Subroutine
 SELECT INTO "nl:"
  _reportseq = seq(ccl_seq,nextval)
  FROM dual
  DETAIL
   _report_audit_seq = _reportseq
  WITH nocounter
 ;end select
 SET reply->report_audit_id = _report_audit_seq
 SET _errcode = error(_errmsg,0)
 IF (_errcode != 0)
  GO TO exit_script
 ENDIF
 IF (textlen(trim(request->object_params)) > 2000)
  SET request->long_text = request->object_params
  SET _obj_params = substring(1,2000,trim(request->object_params))
 ELSE
  SET _obj_params = request->object_params
 ENDIF
 IF ((((request->omf_object_cd > 0.0)) OR ((request->long_text > ""))) )
  CALL insert_long_text(_report_audit_seq)
 ENDIF
 INSERT  FROM ccl_report_audit c
  SET c.report_event_id = _report_audit_seq, c.object_name = trim(cnvtupper(request->object_name)), c
   .object_type = request->report_type,
   c.object_params = _obj_params, c.application_nbr = _orig_crm_appnum, c.begin_dt_tm = cnvtdatetime(
    sysdate),
   c.output_device = trim(request->output_device), c.tempfile = trim(request->temp_file), c
   .records_cnt = 0,
   c.status = "ACTIVE", c.active_ind = 1, c.omf_object_cd = request->omf_object_cd,
   c.long_text_id = _long_text_id, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = prsnl_id,
   c.updt_applctx = cnvtreal(reqinfo->updt_applctx), c.updt_cnt = 0, c.updt_task = reqinfo->updt_task,
   c.request_nbr = _orig_crm_reqnum
  WITH nocounter
 ;end insert
 IF (curqual=1)
  SET _statusflag = "S"
 ELSE
  SET _errcode = error(_errmsg,1)
 ENDIF
#exit_script
 SET _commit_ind = reqinfo->commit_ind
 IF (_statusflag="S")
  SET reply->status_data.status = "S"
  COMMIT
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ccl_add_rpt_audit"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = _errmsg
 ENDIF
 SET reqinfo->commit_ind = _commit_ind
END GO
