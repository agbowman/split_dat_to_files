CREATE PROGRAM dcp_get_cvg:dba
 RECORD reply(
   1 code_value = f8
   1 display = vc
   1 list[*]
     2 child_code_value = f8
     2 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET list_count = 0
 SET codev = 0.0
 SET disp = "EMPTY"
 SET disp2 = ""
 SET childcv = 0.0
 SET child_cnt = 0
 SET count1 = 0
 SELECT INTO "nl:"
  cv.code_value, cv.display
  FROM code_value cv
  WHERE (cv.code_value=request->code_value)
  DETAIL
   codev = cv.code_value, disp = cv.display, reply->code_value = codev,
   reply->display = substring(1,40,disp)
  WITH counter
 ;end select
 CALL echo("---------------------------")
 CALL echo("---------------------------")
 CALL echo("CodeV")
 CALL echo(codev)
 CALL echo("disp")
 CALL echo(build(disp))
 CALL echo("---------------------------")
 CALL echo("---------------------------")
 CALL echo("---------------------------")
 SELECT INTO "nl:"
  cvg.parent_code_value, cvg.child_code_value, cv.code_value,
  cv.code_set
  FROM code_value_group cvg,
   code_value cv
  PLAN (cvg
   WHERE cvg.parent_code_value=codev)
   JOIN (cv
   WHERE cvg.child_code_value=cv.code_value
    AND cv.code_set=6026)
  HEAD REPORT
   count1 = (count1+ 1)
  DETAIL
   IF (count1 > size(reply->list,5))
    stat = alterlist(reply->list,(count1+ 5))
   ENDIF
   reply->list[count1].child_code_value = cvg.child_code_value, reply->list[count1].display = cv
   .display,
   CALL echo("---------------------------"),
   CALL echo("COUNT1"),
   CALL echo(count1),
   CALL echo(reply->list[count1].display)
 ;end select
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "READ"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DCP TimeScale Tool"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "UNABLE TO RETRIEVE"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
