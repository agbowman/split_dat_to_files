CREATE PROGRAM dcp_get_log_entry:dba
 RECORD reply(
   1 activity_list[*]
     2 activity_type_cd = f8
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 parent_entity_dt_tm = dq8
     2 activity_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET x = 0
 SELECT INTO "nl:"
  dal.activity_type_cd, dal.activity_dt_tm
  FROM dcp_activity_log dal
  WHERE (dal.prsnl_id=request->prsnl_id)
   AND (dal.activity_type_cd=request->activity_type_cd)
   AND dal.activity_dt_tm >= cnvtdatetime(request->beg_dt_tm)
   AND dal.activity_dt_tm <= cnvtdatetime(request->end_dt_tm)
  HEAD REPORT
   x = 0
  DETAIL
   x = (x+ 1)
   IF (x > size(reply->activity_list,5))
    stat = alterlist(reply->activity_list,(x+ 5))
   ENDIF
   reply->activity_list[x].activity_type_cd = dal.activity_type_cd, reply->activity_list[x].
   parent_entity_id = dal.parent_entity_id, reply->activity_list[x].parent_entity_name = dal
   .parent_entity_name,
   reply->activity_list[x].parent_entity_dt_tm = cnvtdatetime(dal.parent_entity_dt_tm), reply->
   activity_list[x].activity_dt_tm = cnvtdatetime(dal.activity_dt_tm)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET stat = alterlist(reply->activity_list,x)
  SET reply->status_data.status = "S"
 ENDIF
END GO
