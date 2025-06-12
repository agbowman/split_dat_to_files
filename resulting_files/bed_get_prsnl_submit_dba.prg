CREATE PROGRAM bed_get_prsnl_submit:dba
 FREE SET reply
 RECORD reply(
   1 slist[*]
     2 submit_by = c100
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "Z"
 SET tot_count = 0
 SET count = 0
 SET stat = alterlist(reply->slist,50)
 SELECT DISTINCT INTO "NL:"
  FROM br_prsnl_submit b
  ORDER BY b.submit_by
  DETAIL
   tot_count = (tot_count+ 1), count = (count+ 1)
   IF (count > 50)
    stat = alterlist(reply->slist,(tot_count+ 50)), count = 1
   ENDIF
   reply->slist[tot_count].submit_by = b.submit_by
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->slist,tot_count)
 GO TO exit_script
#exit_script
 IF (tot_count > 0)
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
