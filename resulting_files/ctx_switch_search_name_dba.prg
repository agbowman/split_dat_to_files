CREATE PROGRAM ctx_switch_search_name:dba
 RECORD reply(
   1 username = vc
   1 name_full_formatted = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 IF ((request->username="null"))
  SELECT INTO "nl:"
   p.username
   FROM prsnl p
   WHERE trim(p.name_full_formatted)=trim(request->name_full_formatted)
    AND  NOT (trim(p.username) IN ("", null))
    AND p.active_ind=1
   DETAIL
    count1 += 1, reply->username = p.username
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   p.name_full_formatted
   FROM prsnl p
   WHERE trim(p.username)=trim(request->username)
    AND p.active_ind=1
   DETAIL
    count1 += 1, reply->name_full_formatted = p.name_full_formatted
   WITH nocounter
  ;end select
 ENDIF
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
