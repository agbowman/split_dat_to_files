CREATE PROGRAM bed_get_pqrs_measures:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 measures[*]
      2 measure_id = f8
      2 measure_number = vc
      2 measure_display = vc
      2 pilot_eligible_ind = i2
      2 pilot_core_ind = i2
      2 active_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
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
 DECLARE measure_cnt = i4
 DECLARE temp_cnt = i4
 DECLARE parse_txt = vc
 SET parse_txt = "ms.br_pqrs_meas_id > 0"
 IF ((request->pilot_measures_flag=1))
  SET parse_txt = concat(parse_txt," and ms.pilot_eligible_ind = 1 and ms.pilot_core_ind = 0")
 ENDIF
 SELECT INTO "nl:"
  FROM br_pqrs_meas ms
  PLAN (ms
   WHERE parser(parse_txt))
  HEAD REPORT
   measure_cnt = 0, temp_cnt = 0, stat = alterlist(reply->measures,50)
  DETAIL
   measure_cnt = (measure_cnt+ 1), temp_cnt = (temp_cnt+ 1)
   IF (temp_cnt > 50)
    temp_cnt = 1, stat = alterlist(reply->measures,(measure_cnt+ 50))
   ENDIF
   reply->measures[measure_cnt].measure_id = ms.br_pqrs_meas_id, reply->measures[measure_cnt].
   measure_number = ms.meas_number_ident, reply->measures[measure_cnt].measure_display = ms
   .meas_display,
   reply->measures[measure_cnt].pilot_eligible_ind = ms.pilot_eligible_ind, reply->measures[
   measure_cnt].pilot_core_ind = ms.pilot_core_ind, reply->measures[measure_cnt].active_ind = ms
   .active_ind
  FOOT REPORT
   stat = alterlist(reply->measures,measure_cnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error selecting PQRS measures.")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
