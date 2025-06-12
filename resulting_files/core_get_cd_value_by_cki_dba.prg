CREATE PROGRAM core_get_cd_value_by_cki:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 active_ind = i2
   1 auth_ind = i2
   1 begin_effective_dt_tm = dq8
   1 cdf_meaning = c12
   1 cki = vc
   1 code_set = i4
   1 code_value = f8
   1 collation_seq = i4
   1 concept_cki = vc
   1 definition = vc
   1 description = c60
   1 display = c40
   1 display_key = c40
   1 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE auth = f8 WITH public, noconstant(0.0)
 SET reply->status_data.status = "F"
 IF ((reqdata->data_status_cd < 1))
  SET auth = uar_get_code_by("MEANING",8,"AUTH")
 ELSE
  SET auth = reqdata->data_status_cd
 ENDIF
 SELECT INTO "nl:"
  cv.*
  FROM code_value cv
  PLAN (cv
   WHERE (cv.cki=request->cki))
  DETAIL
   reply->active_ind = cv.active_ind, reply->begin_effective_dt_tm = cnvtdatetime(cv
    .begin_effective_dt_tm), reply->cdf_meaning = cv.cdf_meaning,
   reply->cki = cv.cki, reply->code_set = cv.code_set, reply->code_value = cv.code_value,
   reply->collation_seq = cv.collation_seq, reply->concept_cki = cv.concept_cki, reply->definition =
   cv.definition,
   reply->description = cv.description, reply->display = cv.display, reply->display_key = cv
   .display_key,
   reply->end_effective_dt_tm = cnvtdatetime(cv.end_effective_dt_tm)
   IF (cv.data_status_cd=auth)
    reply->auth_ind = 1
   ELSE
    reply->auth_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "000 06/03/03 AW8266"
END GO
