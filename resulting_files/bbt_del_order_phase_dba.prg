CREATE PROGRAM bbt_del_order_phase:dba
 RECORD reply(
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
  SET o.active_ind = 0
  WHERE (o.order_phase_id=request->order_phase_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET reply->status_data.operationname = "delete"
  SET reply->status_data.operationstatus = "F"
  SET reply->status_data.targetobjectname = "order_phase"
  SET reply->status_data.targetobjectvalue = cnvtstring(request->order_phase_id,32,2)
  SET failed = "T"
 ENDIF
 IF (failed="T")
  ROLLBACK
  GO TO end_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 COMMIT
#end_script
END GO
