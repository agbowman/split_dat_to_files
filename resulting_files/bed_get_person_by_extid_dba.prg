CREATE PROGRAM bed_get_person_by_extid:dba
 FREE SET reply
 RECORD reply(
   1 person_id = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "F"
 SET code_value = 0.0
 SET code_set = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET extid_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=320
    AND cv.cdf_meaning="EXTERNALID")
  ORDER BY cv.code_value
  HEAD cv.code_value
   extid_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (extid_cd=0.0)
  SET error_flag = "T"
  SET error_msg = "Unable to retrieve EXTERNALID code value from code_set 320"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl_alias p
  PLAN (p
   WHERE (p.alias_pool_cd=request->alias_pool_cd)
    AND p.prsnl_alias_type_cd=extid_cd
    AND (p.alias=request->external_id))
  ORDER BY p.prsnl_alias_id
  HEAD REPORT
   reply->person_id = 0.0
  HEAD p.prsnl_alias_id
   reply->person_id = p.person_id
  WITH nocounter
 ;end select
#exit_script
 IF (error_flag="T")
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME:  BED_GET_PERSON_BY_EXTID   >> ERROR MESSAGE:  ",
   error_msg)
 ELSE
  IF (curqual > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
 CALL echorecord(reply)
END GO
