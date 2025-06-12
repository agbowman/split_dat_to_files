CREATE PROGRAM ccl_get_prompt_help:dba
 RECORD reply(
   1 qual[*]
     2 prompt_id = i4
     2 program_name = c30
     2 prompt_num = i2
     2 control_ind = i2
     2 help_codeset = i4
     2 help_lookup = vc
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
  p.prompt_id, p.program_name, p.control_ind,
  p.prompt_num, p.help_codeset, p.help_lookup
  FROM ccl_prompt_help p
  PLAN (p
   WHERE (p.program_name=request->program_name))
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->qual,(cnt+ 9))
   ENDIF
   reply->qual[cnt].prompt_id = p.prompt_id, reply->qual[cnt].program_name = p.program_name, reply->
   qual[cnt].prompt_num = p.prompt_num,
   reply->qual[cnt].control_ind = p.control_ind, reply->qual[cnt].help_codeset = p.help_codeset,
   reply->qual[cnt].help_lookup = p.help_lookup
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
  SET reply->status_data.subeventstatus[1].operationname = "get prompt help"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ccl_get_prompt_help"
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
