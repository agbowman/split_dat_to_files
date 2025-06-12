CREATE PROGRAM bed_get_reason_group:dba
 FREE SET reply
 RECORD reply(
   1 reason_groupings[*]
     2 reason_group_type
       3 code_value = f8
       3 display = vc
       3 meaning = vc
     2 reason_groups[*]
       3 code_value = f8
       3 display = vc
       3 meaning = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE error_flag = vc
 DECLARE gcnt = i4
 DECLARE rgcnt = i4
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 SET gcnt = 0
 SET rgcnt = 0
 SELECT INTO "nl:"
  FROM code_value cv,
   code_value_extension cve,
   code_value cv2,
   dummyt d1,
   dummyt d2
  PLAN (cv
   WHERE cv.code_set=29904
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d1)
   JOIN (cve
   WHERE cnvtreal(cve.field_value)=cv.code_value
    AND cve.field_name="DENIALTYPE")
   JOIN (d2)
   JOIN (cv2
   WHERE cv2.code_value=cve.code_value
    AND cv2.code_set=29903
    AND cv2.active_ind=1)
  ORDER BY cv.display
  HEAD cv.code_value
   gcnt = (gcnt+ 1), stat = alterlist(reply->reason_groupings,gcnt), rgcnt = 0,
   reply->reason_groupings[gcnt].reason_group_type.code_value = cv.code_value, reply->
   reason_groupings[gcnt].reason_group_type.display = cv.display, reply->reason_groupings[gcnt].
   reason_group_type.meaning = cv.cdf_meaning
  DETAIL
   IF (cnvtreal(cve.field_value) > 0
    AND cv2.code_value > 0)
    rgcnt = (rgcnt+ 1), stat = alterlist(reply->reason_groupings[gcnt].reason_groups,rgcnt), reply->
    reason_groupings[gcnt].reason_groups[rgcnt].code_value = cv2.code_value,
    reply->reason_groupings[gcnt].reason_groups[rgcnt].display = cv2.display, reply->
    reason_groupings[gcnt].reason_groups[rgcnt].meaning = cv2.cdf_meaning
   ENDIF
  WITH nocounter, outerjoin = d1, outerjoin = d2,
   dontcare = cve
 ;end select
#exit_script
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
