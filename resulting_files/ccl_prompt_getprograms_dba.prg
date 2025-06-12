CREATE PROGRAM ccl_prompt_getprograms:dba
 RECORD reply(
   1 programs[*]
     2 programname = vc
     2 groupno = i2
     2 display = vc
     2 description = vc
     2 classid = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE prgname = vc WITH protect
 SET prgname = "*"
 IF (validate(request->programname,"0") != "0")
  IF (textlen(trim(request->programname)) > 0)
   SET prgname = cnvtupper(request->programname)
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  cpg.*
  FROM ccl_prompt_programs cpg
  WHERE (cpg.control_class_id=request->classid)
   AND cpg.program_name=patstring(prgname)
  ORDER BY cpg.control_class_id, cpg.program_name, cpg.group_no
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->programs,cnt), reply->programs[cnt].programname = cpg
   .program_name,
   reply->programs[cnt].groupno = cpg.group_no, reply->programs[cnt].display = cpg.display, reply->
   programs[cnt].description = cpg.description,
   reply->programs[cnt].classid = cpg.control_class_id
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
END GO
