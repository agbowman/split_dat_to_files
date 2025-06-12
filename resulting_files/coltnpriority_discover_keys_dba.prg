CREATE PROGRAM coltnpriority_discover_keys:dba
 SET modify = predeclare
 RECORD reply(
   1 keys[*]
     2 key_id = vc
     2 changed = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 IF ((request->since=0))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM collection_priority c
  WHERE c.collection_priority_cd > 0
   AND c.updt_dt_tm > cnvtdatetime(request->since)
  HEAD REPORT
   i = 0
  DETAIL
   i = (i+ 1)
   IF (i > size(reply->keys,5))
    stat = alterlist(reply->keys,(i+ 10))
   ENDIF
   reply->keys[i].key_id = concat("0932-",cnvtstring(c.collection_priority_cd)), reply->keys[i].
   changed = c.updt_dt_tm
  FOOT REPORT
   stat = alterlist(reply->keys,i)
  WITH nocounter
 ;end select
#exit_script
 IF (size(reply->keys,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
