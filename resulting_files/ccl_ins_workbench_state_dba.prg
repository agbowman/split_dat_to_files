CREATE PROGRAM ccl_ins_workbench_state:dba
 RECORD reply(
   1 long_blob_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE _status = c1 WITH noconstant("S"), protect
 DECLARE _blob_seq = f8 WITH noconstant(0.0), protect
 DECLARE _object_id = f8 WITH noconstant(0.0), protect
 DECLARE _object_ref_id = f8 WITH noconstant(0.0), protect
 DECLARE _active_var = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE _blob_id = f8 WITH noconstant(0)
 DECLARE _update_cnt = i4 WITH noconstant(0)
 DECLARE _workspace_table = vc WITH noconstant("LONG_BLOB_REFERENCE")
 SET reply->status_data.status = "F"
 SET _blob_id = request->long_blob_id
 SELECT INTO "nl:"
  lbr.long_blob_id
  FROM long_blob_reference lbr
  WHERE lbr.long_blob_id=_blob_id
  DETAIL
   _object_ref_id = lbr.long_blob_id, _workspace_table = "LONG_BLOB_REFERENCE"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT INTO "nl:"
   lb.long_blob_id
   FROM long_blob lb
   WHERE lb.long_blob_id=_blob_id
   DETAIL
    _object_id = lb.long_blob_id, _workspace_table = "LONG_BLOB"
   WITH nocounter
  ;end select
 ENDIF
 IF (_object_id > 0)
  SELECT INTO "nl:"
   lb.*
   FROM long_blob lb
   WHERE lb.long_blob_id=_blob_id
   WITH nocounter, forupdate(lb)
  ;end select
  SELECT INTO "nl:"
   lb.updt_cnt
   FROM long_blob lb
   WHERE lb.long_blob_id=_blob_id
   DETAIL
    _update_cnt = (lb.updt_cnt+ 1)
   WITH nocounter
  ;end select
  UPDATE  FROM long_blob lb
   SET lb.active_ind = 1, lb.active_status_cd = _active_var, lb.active_status_dt_tm = cnvtdatetime(
     sysdate),
    lb.active_status_prsnl_id = reqinfo->updt_id, lb.long_blob = request->workbench_state, lb
    .parent_entity_id = 0,
    lb.parent_entity_name = "DVDEV_WORKBENCH_STATE", lb.updt_dt_tm = cnvtdatetime(sysdate), lb
    .updt_task = reqinfo->updt_task,
    lb.updt_id = reqinfo->updt_id, lb.updt_cnt = _update_cnt, lb.updt_applctx = reqinfo->updt_applctx,
    lb.blob_length = request->blob_length
   WHERE lb.long_blob_id=_blob_id
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_BLOB"
   SET _status = "F"
   GO TO exit_script
  ELSE
   SET reply->long_blob_id = _blob_id
  ENDIF
 ELSEIF (_object_ref_id > 0)
  SELECT INTO "nl:"
   lbr.*
   FROM long_blob_reference lbr
   WHERE lbr.long_blob_id=_blob_id
   WITH nocounter, forupdate(lbr)
  ;end select
  SELECT INTO "nl:"
   lbr.updt_cnt
   FROM long_blob_reference lbr
   WHERE lbr.long_blob_id=_blob_id
   DETAIL
    _update_cnt = (lbr.updt_cnt+ 1)
   WITH nocounter
  ;end select
  UPDATE  FROM long_blob_reference lbr
   SET lbr.active_ind = 1, lbr.active_status_cd = _active_var, lbr.active_status_dt_tm = cnvtdatetime
    (sysdate),
    lbr.active_status_prsnl_id = reqinfo->updt_id, lbr.long_blob = request->workbench_state, lbr
    .parent_entity_id = 0,
    lbr.parent_entity_name = "DVDEV_WORKBENCH_STATE", lbr.updt_dt_tm = cnvtdatetime(sysdate), lbr
    .updt_task = reqinfo->updt_task,
    lbr.updt_id = reqinfo->updt_id, lbr.updt_cnt = _update_cnt, lbr.updt_applctx = reqinfo->
    updt_applctx
   WHERE lbr.long_blob_id=_blob_id
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_BLOB_REFERENCE"
   SET _status = "F"
   GO TO exit_script
  ELSE
   SET reply->long_blob_id = _blob_id
  ENDIF
 ELSE
  SELECT INTO "nl:"
   _blobseq = seq(long_data_seq,nextval)
   FROM dual
   DETAIL
    _blob_seq = _blobseq
   WITH nocounter
  ;end select
  INSERT  FROM long_blob_reference lbr
   SET lbr.active_ind = 1, lbr.active_status_cd = _active_var, lbr.active_status_dt_tm = cnvtdatetime
    (sysdate),
    lbr.active_status_prsnl_id = reqinfo->updt_id, lbr.long_blob = request->workbench_state, lbr
    .long_blob_id = _blob_seq,
    lbr.parent_entity_id = 0, lbr.parent_entity_name = "DVDEV_WORKBENCH_STATE", lbr.updt_dt_tm =
    cnvtdatetime(sysdate),
    lbr.updt_task = reqinfo->updt_task, lbr.updt_id = reqinfo->updt_id, lbr.updt_cnt = 1,
    lbr.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_BLOB_REFERENCE"
   SET _status = "F"
   GO TO exit_script
  ELSE
   SET reply->long_blob_id = _blob_seq
  ENDIF
 ENDIF
#exit_script
 IF (_status="F")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
