CREATE PROGRAM ccl_del_prompt_help:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET success = "T"
 IF ((request->just_update=0))
  DELETE  FROM ccl_prompt_help p
   WHERE (p.program_name=request->program_name)
    AND (p.prompt_num=request->prompt_num)
   WITH nocounter
  ;end delete
  IF (curqual=0)
   SET success = "F"
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO ":nl"
  p.*
  FROM ccl_prompt_help p
  WHERE (p.prompt_num > request->prompt_num)
   AND (p.program_name=request->program_name)
  WITH nocounter, forupdate(p)
 ;end select
 UPDATE  FROM ccl_prompt_help p
  SET p.prompt_num = (p.prompt_num - 1)
  WHERE (p.prompt_num > request->prompt_num)
   AND (p.program_name=request->program_name)
  WITH nocounter
 ;end update
#exit_script
 IF (success="F")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
END GO
