CREATE PROGRAM dm2_arc_upd_pers_next_rest:dba
 RECORD dunr_request(
   1 person_id = f8
   1 next_restore_dt_tm = dq8
 )
 RECORD dunr_reply(
   1 err_num = i4
   1 err_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD reply(
   1 err_num = i4
   1 err_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET dunr_request->person_id = request->person_id
 SET dunr_request->next_restore_dt_tm = cnvtdatetime(request->next_restore_dt_tm)
 EXECUTE dm_upd_person_nxt_restore_date  WITH replace("REQUEST","DUNR_REQUEST"), replace("REPLY",
  "DUNR_REPLY")
 SET reply->status_data.status = dunr_reply->status_data.status
 FREE RECORD dunr_request
 FREE RECORD dunr_reply
END GO
