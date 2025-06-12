CREATE PROGRAM ccl_prompt_insertprg:dba
 PROMPT
  "Send Confirmation Report To:" = "",
  "Program Name:" = "",
  "Group NO:" = "0",
  "Display :" = "",
  "Description:" = ""
  WITH outdev, prgname, groupno,
  pddisplay, desc
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
 SET req->programname = cnvtupper(trim( $PRGNAME))
 SET req->groupno = cnvtint( $GROUPNO)
 SET req->display =  $PDDISPLAY
 SET req->description =  $DESC
 SET req->classid = 0
 CALL echo("execute ccl_prompt_addprogram")
 EXECUTE ccl_prompt_addprogram  WITH replace(request,req), replace(reply,rep)
 SELECT INTO  $OUTDEV
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   row + 2, col 5, rep->status_data.subeventstatus[1].operationname
  WITH nocounter
 ;end select
 RETURN
END GO
