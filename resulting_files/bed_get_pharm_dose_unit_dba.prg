CREATE PROGRAM bed_get_pharm_dose_unit:dba
 FREE SET reply
 RECORD reply(
   1 unit_of_measure[*]
     2 code_value = f8
     2 display = vc
     2 mean = vc
     2 cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET list_count = 0
 SELECT INTO "nl:"
  FROM code_value cv,
   code_value_extension cve
  PLAN (cv
   WHERE cv.code_set=54
    AND cv.active_ind=1)
   JOIN (cve
   WHERE cve.code_value=cv.code_value
    AND cve.field_name="PHARM_UNIT")
  HEAD REPORT
   cnt = 0, list_count = 0, stat = alterlist(reply->unit_of_measure,200)
  DETAIL
   list_count = (list_count+ 1), cnt = (cnt+ 1)
   IF (list_count > 200)
    stat = alterlist(reply->unit_of_measure,(cnt+ 200)), list_count = 1
   ENDIF
   reply->unit_of_measure[cnt].code_value = cv.code_value, reply->unit_of_measure[cnt].display = cv
   .display, reply->unit_of_measure[cnt].mean = cv.cdf_meaning,
   reply->unit_of_measure[cnt].cki = cv.cki
  FOOT REPORT
   stat = alterlist(reply->unit_of_measure,cnt)
  WITH nocounter
 ;end select
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
