CREATE PROGRAM bed_get_quickbuild_positions:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 positions[*]
      2 code_value = f8
      2 display = vc
      2 description = vc
      2 definition = vc
    1 all_positions_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE position_size = i4 WITH protect
 DECLARE count = i4 WITH protect
 IF ((request->activity_type_code_value=0))
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="PHARMACY"
    AND cv.active_ind=1
   DETAIL
    request->activity_type_code_value = cv.code_value
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error getting activity type.")
 ENDIF
 IF ((request->catalog_type_code_value=0))
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="PHARMACY"
    AND cv.active_ind=1
   DETAIL
    request->catalog_type_code_value = cv.code_value
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error getting catalog type.")
 ENDIF
 SELECT INTO "nl:"
  FROM tl_quick_build_position_xref t,
   code_value cv
  PLAN (t
   WHERE (t.catalog_type_cd=request->catalog_type_code_value)
    AND (t.activity_type_cd=request->activity_type_code_value))
   JOIN (cv
   WHERE cv.code_value=t.position_cd
    AND cv.active_ind=1)
  ORDER BY cv.code_value
  HEAD REPORT
   stat = alterlist(reply->positions,10), position_size = 0, count = 0
  HEAD cv.code_value
   position_size = (position_size+ 1), count = (count+ 1)
   IF (count=10)
    count = 0, stat = alterlist(reply->positions,(position_size+ 10))
   ENDIF
   reply->positions[position_size].code_value = cv.code_value, reply->positions[position_size].
   display = cv.display, reply->positions[position_size].description = cv.description,
   reply->positions[position_size].definition = cv.definition
  FOOT REPORT
   stat = alterlist(reply->positions,position_size)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error getting positions for quick build.")
 SELECT INTO "nl:"
  FROM tl_quick_build_params tlqb
  WHERE (tlqb.catalog_type_cd=request->catalog_type_code_value)
   AND (tlqb.activity_type_cd=request->activity_type_code_value)
  DETAIL
   reply->all_positions_ind = tlqb.allpositionchart_ind
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error getting all position ind for quick build.")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
