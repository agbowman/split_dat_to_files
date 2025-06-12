CREATE PROGRAM bbt_chg_order_status:dba
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
 SET status_count = 0
 SET failed = "F"
 SET cur_updt_cnt = 0
 SELECT INTO "nl:"
  osrc.*
  FROM order_serv_res_container osrc
  WHERE (osrc.order_id=request->order_id)
   AND (osrc.container_id=request->container_id)
  DETAIL
   cur_updt_cnt = osrc.updt_cnt
  WITH nocounter, forupdate(osrc)
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET status_count = (status_count+ 1)
  IF (status_count > 1)
   SET stat = alter(reply->status_data.subeventstatus,(status_count+ 1))
  ENDIF
  SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
  SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
  SET reply->status_data.subeventstatus[status_count].targetobjectname = "Order Serv Res Container"
  SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
  "Unable to lock order serv res container"
 ELSEIF ((cur_updt_cnt != request->order_serv_res_updt_cnt))
  SET failed = "T"
  SET status_count = (status_count+ 1)
  IF (status_count > 1)
   SET stat = alter(reply->status_data.subeventstatus,(status_count+ 1))
  ENDIF
  SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
  SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
  SET reply->status_data.subeventstatus[status_count].targetobjectname = "Order Serv Res Container"
  SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
  "Update conflict on order serv res container"
 ELSE
  UPDATE  FROM order_serv_res_container osrc
   SET osrc.status_flag = 2, osrc.updt_dt_tm = cnvtdatetime(curdate,curtime3), osrc.updt_id = reqinfo
    ->updt_id,
    osrc.updt_task = reqinfo->updt_task, osrc.updt_applctx = reqinfo->updt_applctx, osrc.updt_cnt = (
    osrc.updt_cnt+ 1)
   WHERE (osrc.order_id=request->order_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET status_count = (status_count+ 1)
   IF (status_count > 1)
    SET stat = alter(reply->status_data.subeventstatus,(status_count+ 1))
   ENDIF
   SET reply->status_data.subeventstatus[status_count].operationname = "CHANGE"
   SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
   SET reply->status_data.subeventstatus[status_count].targetobjectname = "Order Serv Res Container"
   SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
   "Unable to update order serv res container"
  ENDIF
 ENDIF
 IF (failed="T")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
