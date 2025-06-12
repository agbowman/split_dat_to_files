CREATE PROGRAM bbt_add_order_phase:dba
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
 SET order_phase_id = 0.0
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 IF (curqual=0)
  GO TO row_failed
 ELSE
  SET order_phase_id = new_pathnet_seq
  INSERT  FROM bb_order_phase o
   SET o.order_phase_id = order_phase_id, o.order_id = request->order_id, o.phase_grp_cd = request->
    phase_grp_cd,
    o.updt_cnt = 0, o.updt_dt_tm = cnvtdatetime(sysdate), o.updt_id = reqinfo->updt_id,
    o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->updt_applctx
   WITH counter
  ;end insert
  IF (curqual=0)
   SET reply->status_data.operationname = "insert"
   SET reply->status_data.operationstatus = "F"
   SET reply->status_data.targetobjectname = "order_phase"
   SET reply->status_data.targetobjectvalue = cnvtstring(request->phase_grp_cd,32,2)
   SET failed = "T"
   GO TO row_failed
  ELSE
   SET reply->order_phase_id = order_phase_id
  ENDIF
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
