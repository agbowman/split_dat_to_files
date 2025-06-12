CREATE PROGRAM aps_get_valid_eps:dba
 RECORD reply(
   1 eps[*]
     2 format_id = f8
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
   WHERE sler.active_ind=1)
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->eps,5)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,5)=1
    AND cnt != 1)
    stat = alterlist(reply->eps,(cnt+ 4))
   ENDIF
   reply->eps[cnt].cki_source = sler.cki_source, reply->eps[cnt].cki_identifier = sler.cki_identifier,
   reply->eps[cnt].format_id = sler.format_id
  FOOT REPORT
   stat = alterlist(reply->eps,cnt)
  WITH nocounter
 ;end select
 IF (cnt=0)
  SET reply->status_data.status = "Z"
  SET stat = alterlist(reply->eps,0)
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
