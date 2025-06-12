CREATE PROGRAM dcp_get_user_appcontext:dba
 RECORD reply(
   1 start_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 qual[*]
     2 start_dt_tm = dq8
     2 end_dt_tm = dq8
 )
 SET reply->status_data.status = "S"
 SET cnt = 0
 SELECT INTO "nl:"
  FROM application_context ac
  WHERE (ac.person_id=request->user_id)
   AND ((ac.application_number+ 0)=request->application_number)
  ORDER BY ac.start_dt_tm
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > size(temp->qual,5))
    stat = alterlist(temp->qual,(cnt+ 10))
   ENDIF
   temp->qual[cnt].start_dt_tm = ac.start_dt_tm, temp->qual[cnt].end_dt_tm = ac.end_dt_tm
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET reply->start_dt_tm = temp->qual[(cnt - 1)].start_dt_tm
 CALL echo(build("Start = ",cnvtdatetime(reply->start_dt_tm)))
#exit_script
 IF ((reply->status_data.status="F"))
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "applicaion_context"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_get_user_appcontext.prg"
 ENDIF
 SET mod_version = "001 01/20/05 AW9942"
END GO
