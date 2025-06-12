CREATE PROGRAM bbt_upd_order_phase:dba
 RECORD reply(
   1 order_phase_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 UPDATE  FROM bb_order_phase o
  SET o.phase_grp_cd = request->phase_grp_cd, o.order_phase_id = o.order_phase_id, o.updt_cnt = (o
   .updt_cnt+ 1),
   o.updt_dt_tm = cnvtdatetime(sysdate), o.updt_id = reqinfo->updt_id, o.updt_task = reqinfo->
   updt_task,
   o.updt_applctx = reqinfo->updt_applctx
  WHERE (o.order_id=request->order_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET reply->status_data.operationname = "update"
  SET reply->status_data.operationstatus = "F"
  SET reply->status_data.targetobjectname = "order_phase"
  SET reply->status_data.targetobjectvalue = cnvtstring(request->phase_grp_cd,32,2)
  SET failed = "T"
  GO TO row_failed
 ELSE
  SELECT INTO "nl:"
   bop.order_phase_id
   FROM bb_order_phase bop
   WHERE (bop.order_id=request->order_id)
   DETAIL
    reply->order_phase_id = bop.order_phase_id
   WITH nocounter
  ;end select
 ENDIF
#row_failed
 IF (failed="T")
  SET reqinfo->commit_ind = 0
  GO TO end_script
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
#end_script
END GO
