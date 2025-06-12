CREATE PROGRAM dcp_upd_predefined_prefs:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 IF ((request->nv_cnt > 0))
  DELETE  FROM name_value_prefs nv
   WHERE nv.parent_entity_name="PREDEFINED_PREFS"
    AND (nv.parent_entity_id=request->predefined_prefs_id)
   WITH nocounter
  ;end delete
 ENDIF
 UPDATE  FROM predefined_prefs pp
  SET pp.name = request->name, pp.active_ind = request->active_ind, pp.updt_dt_tm = cnvtdatetime(
    curdate,curtime3),
   pp.updt_id = reqinfo->updt_id, pp.updt_task = reqinfo->updt_task, pp.updt_applctx = reqinfo->
   updt_applctx,
   pp.updt_cnt = (pp.updt_cnt+ 1)
  WHERE (pp.predefined_prefs_id=request->predefined_prefs_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "PREDEFINED_PREFS"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PREDEFINED_PREFS"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 INSERT  FROM name_value_prefs nvp,
   (dummyt d1  WITH seq = value(request->nv_cnt))
  SET nvp.seq = 1, nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name =
   "PREDEFINED_PREFS",
   nvp.parent_entity_id = request->predefined_prefs_id, nvp.pvc_name = request->nv[d1.seq].pvc_name,
   nvp.pvc_value = request->nv[d1.seq].pvc_value,
   nvp.active_ind = 1, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->
   updt_id,
   nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0
  PLAN (d1)
   JOIN (nvp)
  WITH nocounter
 ;end insert
 IF ((curqual != request->nv_cnt))
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "NAME_VALUE_PREFS"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_PREDEFINED_PREFS"
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
END GO
