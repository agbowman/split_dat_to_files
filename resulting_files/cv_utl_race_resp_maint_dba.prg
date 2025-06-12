CREATE PROGRAM cv_utl_race_resp_maint:dba
 PAINT
 DECLARE ierror = i2 WITH public, noconstant(0)
 DECLARE serrmsg = c132 WITH public, noconstant(fillstring(132," "))
 SET width = 132
#begin
 FREE RECORD hold
 RECORD hold(
   1 status = c1
   1 errloc = vc
   1 response_id = f8
   1 a3 = c12
   1 code_value = f8
   1 cdf_meaning = c12
 )
 CALL text(3,4,"Select a response from the help:")
 SET help =
 SELECT
  c.response_id, c.a1, c.a3
  FROM cv_response c
  WHERE c.response_internal_name="ST02_RACE_*"
   AND c.a1 != "<blank>"
   AND c.field_type="C"
  ORDER BY c.response_internal_name
  WITH nocounter
 ;end select
 CALL text(4,1,"Response_id:")
 CALL accept(4,25,"9(11);df")
 SET hold->response_id = curaccept
 IF ((hold->response_id=0))
  GO TO exit_script
 ENDIF
 SET accept = nochange
 SET help =
 SELECT
  cv.code_value, cv.display, cv.cdf_meaning
  FROM code_value cv
  WHERE cv.code_set=282
  ORDER BY cv.display
  WITH nocounter
 ;end select
 CALL text(5,1,"CodeValue:")
 CALL accept(5,25,"9(11);df")
 SET hold->code_value = curaccept
 CALL text(4,25,cnvtstring(hold->response_id))
 CALL text(5,25,cnvtstring(hold->code_value))
 SET help = off
 SELECT INTO "nl:"
  FROM code_value c
  WHERE (c.code_value=hold->code_value)
  DETAIL
   IF (size(trim(c.cdf_meaning,3)) > 0)
    hold->a3 = c.cdf_meaning
   ELSE
    hold->a3 = trim(substring(1,12,c.display_key),3), hold->cdf_meaning = trim(substring(1,12,c
      .display_key),3)
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET x = (x+ 1)
  SET hold->status = "F"
  SET hold->errloc = build("CODE_VALUE:",x)
  GO TO exit_script
 ENDIF
 IF (size(hold->a3) > 0)
  SET ierror = error(serrmsg,1)
  SET ierror = 0
  UPDATE  FROM cv_response r
   SET r.a3 = trim(hold->a3,3), r.updt_cnt = (r.updt_cnt+ 1), r.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    r.updt_applctx = 30376
   WHERE (r.response_id=hold->response_id)
   WITH nocounter
  ;end update
  SET ierror = error(serrmsg,1)
  IF (ierror > 0)
   SET hold->errloc = build("*** Error Updating cv_response:",serrmsg)
   GO TO exit_script
  ENDIF
  IF (curqual=0)
   SET hold->status = "F"
   SET hold->errloc = "CV_RESPONSE"
  ENDIF
  IF (curqual > 0)
   SET hold->status = "T"
   SET hold->errloc = "CV_RESPONSE"
  ENDIF
  IF (size(hold->cdf_meaning) > 0)
   SET ierror = error(serrmsg,1)
   SET ierror = 0
   UPDATE  FROM code_value c
    SET c.cdf_meaning = hold->cdf_meaning
    WHERE (c.code_value=hold->code_value)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET hold->status = "F"
    SET hold->errloc = "UPDT CV"
   ENDIF
   SET ierror = error(serrmsg,1)
   IF (ierror > 0)
    SET hold->status = "F"
    SET hold->errloc = "UPD CODE_VAL"
    GO TO exit_script
   ENDIF
  ENDIF
 ELSE
  SET hold->status = "F"
  SET hold->errloc = "HOLD->A3"
 ENDIF
 COMMIT
 GO TO begin
#exit_script
 SET script_version = "MOD 001 03/04/03 JF7198"
END GO
