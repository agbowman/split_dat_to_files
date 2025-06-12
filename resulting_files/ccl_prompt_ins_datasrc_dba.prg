CREATE PROGRAM ccl_prompt_ins_datasrc:dba
 PROMPT
  "Object Name:" = "",
  "Group NO:" = "0",
  "Display :" = "",
  "Description:" = "",
  "Control ID:" = 0
  WITH prgname, groupno, pddisplay,
  desc, ctrlid
 RECORD req(
   1 programname = vc
   1 groupno = i2
   1 display = vc
   1 description = vc
   1 classid = i2
 )
 RECORD rep(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DELETE  FROM ccl_prompt_programs
  WHERE program_name=cnvtupper(trim( $PRGNAME))
   AND group_no=cnvtint( $GROUPNO)
   AND (control_class_id= $CTRLID)
  WITH nocounter
 ;end delete
 COMMIT
 SET req->programname = cnvtupper(trim( $PRGNAME))
 SET req->groupno = cnvtint( $GROUPNO)
 SET req->display =  $PDDISPLAY
 SET req->description =  $DESC
 SET req->classid =  $CTRLID
 CALL echo("execute ccl_prompt_addprogram")
 EXECUTE ccl_prompt_addprogram  WITH replace(request,req), replace(reply,rep)
END GO
