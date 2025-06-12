CREATE PROGRAM aps_get_signline_eps:dba
 RECORD reply(
   1 eps[*]
     2 cki_source = c12
     2 cki_identifier = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET cnt = 0
 SELECT INTO "nl:"
  FROM sign_line_ep_r sler
  PLAN (sler
   WHERE (sler.status_flag=request->status_flag)
    AND (sler.format_id=request->format_id))
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->eps,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alterlist(reply->eps,(cnt+ 9))
   ENDIF
   reply->eps[cnt].cki_source = sler.cki_source, reply->eps[cnt].cki_identifier = sler.cki_identifier
  FOOT REPORT
   stat = alterlist(reply->eps,cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET stat = alterlist(reply->eps,0)
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
