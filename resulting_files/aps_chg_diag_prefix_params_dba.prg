CREATE PROGRAM aps_chg_diag_prefix_params:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET ap_updt_cnt = - (1)
 SET cnt = 0
 SET number_to_del = size(request->remove_qual,5)
 SET number_to_add = size(request->add_qual,5)
 SET reqinfo->commit_ind = 0
 IF ((value(request->vocab_cd) > - (1)))
  SELECT INTO "nl:"
   ap.*
   FROM ap_prefix ap
   WHERE (request->prefix_cd=ap.prefix_id)
   DETAIL
    ap_updt_cnt = ap.updt_cnt
   WITH nocounter, forupdate(ap)
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_PREFIX"
   SET failed = "T"
   GO TO exit_script
  ENDIF
  IF ((ap_updt_cnt != request->updt_cnt))
   SET reply->status_data.subeventstatus[1].operationname = "COUNTER SYNC"
   SET reply->status_data.subeventstatus[1].operationstatus = "C"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_PREFIX"
   SET failed = "T"
   GO TO exit_script
  ENDIF
  UPDATE  FROM ap_prefix ap
   SET ap.diag_coding_vocabulary_cd = request->vocab_cd, ap.updt_dt_tm = cnvtdatetime(curdate,curtime
     ), ap.updt_id = reqinfo->updt_id,
    ap.updt_task = reqinfo->updt_task, ap.updt_applctx = reqinfo->updt_applctx, ap.updt_cnt = (
    ap_updt_cnt+ 1)
   WHERE (request->prefix_cd=ap.prefix_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_PREFIX"
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
 IF (number_to_del > 0)
  DELETE  FROM ap_prefix_diag_axis apds,
    (dummyt d  WITH seq = value(number_to_del))
   SET apds.seq = 1
   PLAN (d)
    JOIN (apds
    WHERE (apds.exclude_axis_cd=request->remove_qual[d.seq].exclude_axis_cd)
     AND (apds.prefix_id=request->prefix_cd))
   WITH nocounter
  ;end delete
  IF (curqual != number_to_del)
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Delete"
   SET reply->status_data.subeventstatus[1].targetobjectname = "AP_PREFIX_DIAG_AXIS"
   GO TO exit_script
  ENDIF
 ENDIF
 IF (number_to_add > 0)
  INSERT  FROM ap_prefix_diag_axis apds,
    (dummyt d  WITH seq = value(number_to_add))
   SET apds.prefix_id = request->prefix_cd, apds.exclude_axis_cd = request->add_qual[d.seq].
    exclude_axis_cd, apds.updt_cnt = 0,
    apds.updt_dt_tm = cnvtdatetime(curdate,curtime3), apds.updt_id = reqinfo->updt_id, apds.updt_task
     = reqinfo->updt_task,
    apds.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (apds)
   WITH nocounter
  ;end insert
  IF (curqual != number_to_add)
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Insert"
   SET reply->status_data.subeventstatus[1].targetobjectname = "AP_PREFIX_DIAG_AXIS"
   GO TO exit_script
  ENDIF
 ENDIF
 SET reqinfo->commit_ind = 1
 COMMIT
 SET reply->status_data.status = "S"
#exit_script
END GO
