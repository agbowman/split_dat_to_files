CREATE PROGRAM bsc_fetch_update_count:dba
 SET modify = predeclare
 RECORD reply(
   1 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE fetchupdatecount(order_id=f8) = i4
 IF ((request->order_id != 0))
  CALL fetchupdatecount(request->order_id)
 ENDIF
 SUBROUTINE fetchupdatecount(order_id)
   SELECT INTO "nl:"
    FROM order_iv_info o
    WHERE o.order_id=order_id
    DETAIL
     reply->updt_cnt = o.updt_cnt
    WITH nocounter
   ;end select
   SET reply->status_data.status = "S"
   SET reply->status_data.subeventstatus.targetobjectname = "FetchUpdateCount"
   SET reply->status_data.subeventstatus.targetobjectvalue = ""
 END ;Subroutine
 SET last_mod = "000 05/20/2013"
 SET modify = nopredeclare
END GO
