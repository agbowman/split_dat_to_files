CREATE PROGRAM ccl_prompt_del_form
 PROMPT
  "Prompt Form Name :" = "",
  "Group :",
  "OUTPUT TO :" = ""
  WITH formname, groupaccess, outdev
 FREE RECORD reqdefform
 RECORD reqdefform(
   1 programname = c30
   1 groupno = i2
 )
 FREE RECORD rep
 RECORD rep(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reqdefform->programname =  $FORMNAME
 SET reqdefform->groupno =  $GROUPACCESS
 EXECUTE ccl_prompt_del_prompts  WITH replace(request,reqdefform), replace(reply,rep)
 IF ((rep->status_data.status != "F"))
  CALL echo(concat("the prompt form '", $FORMNAME,"' has been deleted."))
  SET errorflag = 0
 ELSE
  CALL echo(concat("failed to delete the prompt form '", $FORMNAME,"'"))
  SET errorflag = 1
 ENDIF
END GO
