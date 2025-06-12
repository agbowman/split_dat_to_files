CREATE PROGRAM ccl_get_prompt_hlp_names:dba
 RECORD reply(
   1 qual[*]
     2 help_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET errmsg = fillstring(255," ")
 SET cnt = 0
 SELECT INTO "nl:"
  d.object_name
  FROM dprotect d
  WHERE d.object="P"
   AND d.object_name="HLP_*"
  ORDER BY d.object_name
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->qual,(cnt+ 9))
   ENDIF
   reply->qual[cnt].help_name = d.object_name
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,cnt)
 IF (curqual > 0)
  SET reply->status_data.status = "S"
  SET failed = "F"
 ELSEIF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET errcode = error(errmsg,1)
  SET failed = "T"
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.subeventstatus[1].operationname = "get prompt hlp names"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ccl_get_prompt_hlp_names"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
  SET reqinfo->commit_ind = 0
  GO TO endit
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  GO TO endit
 ENDIF
#endit
END GO
