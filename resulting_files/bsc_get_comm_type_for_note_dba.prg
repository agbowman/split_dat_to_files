CREATE PROGRAM bsc_get_comm_type_for_note:dba
 SET modify = predeclare
 RECORD reply(
   1 comm_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 SET reply->status_data.status = "Z"
 SELECT INTO "nl:"
  FROM order_action oa
  WHERE (oa.order_id=request->order_id)
  ORDER BY oa.action_sequence
  DETAIL
   reply->comm_type_cd = oa.communication_type_cd
 ;end select
 SET reply->status_data.status = "S" WITH nocounter
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = errmsg
 ENDIF
 SET last_mod = "000"
 SET mod_date = "03/04/2009"
 SET modify = nopredeclare
END GO
