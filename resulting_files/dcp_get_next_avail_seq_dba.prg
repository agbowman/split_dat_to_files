CREATE PROGRAM dcp_get_next_avail_seq:dba
 RECORD reply(
   1 sequence_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->sequence_id = 0
 SET reply->status_data.status = "F"
 SET sequence_name = build("seq(",request->sequence_name,",nextval)")
 SELECT INTO "nl:"
  j = parser(sequence_name)
  FROM dual
  DETAIL
   reply->sequence_id = cnvtreal(j)
  WITH format, nocounter
 ;end select
 IF ((reply->sequence_id != 0))
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.subeventstatus[1].operationname = "Get Next Sequence Failed"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "request->sequence_name"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "4-unable"
 ENDIF
END GO
