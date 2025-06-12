CREATE PROGRAM ccl_prompt_rename_form
 PROMPT
  "old form name " = "",
  "new form name " = ""
  WITH oldform, newform
 RECORD request(
   1 programname = vc
   1 newprogramname = vc
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET request->programname =  $OLDFORM
 SET request->newprogramname =  $NEWFORM
 EXECUTE ccl_prompt_rename_prompts
 CALL echo(concat("Form [", $OLDFORM,"] rename to [", $NEWFORM,"]"))
END GO
