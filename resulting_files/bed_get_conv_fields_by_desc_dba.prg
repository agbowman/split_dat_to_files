CREATE PROGRAM bed_get_conv_fields_by_desc:dba
 FREE SET reply
 RECORD reply(
   1 fields[*]
     2 field = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 IF ((request->user_defined_ind=1))
  SET field_code_value = 0.0
  SELECT INTO "NL:"
   FROM code_value cv
   WHERE cv.code_set=356
    AND (cv.description=request->field_description)
   DETAIL
    field_code_value = cv.code_value
   WITH nocounter
  ;end select
  SET field_level = fillstring(100," ")
  SET field_field = fillstring(100," ")
  SELECT INTO "NL:"
   FROM code_value_extension cve
   WHERE cve.code_value=field_code_value
    AND cve.code_set=356
    AND cve.field_name IN ("LEVEL", "FIELD")
   DETAIL
    IF (cve.field_name="LEVEL")
     field_level = cve.field_value
    ELSEIF (cve.field_name="FIELD")
     field_field = cve.field_value
    ENDIF
   WITH nocounter
  ;end select
  DECLARE work_name = vc
  IF (field_level="PERSON")
   SET work_name = concat("PERSON.USER_DEFINED",".",field_field)
  ELSEIF (field_level="ENCOUNTER")
   SET work_name = concat("PERSON.ENCOUNTER.USER_DEFINED",".",field_field)
  ENDIF
  SET fcnt = 1
  SET stat = alterlist(reply->fields,1)
  SET reply->fields[1].field = work_name
 ELSE
  SET fcnt = 0
  SET alterlist_fcnt = 0
  SET stat = alterlist(reply->fields,50)
  SELECT DISTINCT INTO "NL:"
   FROM pm_flx_prompt pfp
   WHERE (pfp.description=request->field_description)
    AND pfp.parent_entity_name="PM_FLX_DATA_SOURCE"
    AND pfp.parent_entity_id > 0
    AND pfp.active_ind=1
    AND pfp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pfp.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   DETAIL
    fcnt = (fcnt+ 1), alterlist_fcnt = (alterlist_fcnt+ 1)
    IF (alterlist_fcnt > 50)
     stat = alterlist(reply->fields,(fcnt+ 50)), alterlist_fcnt = 1
    ENDIF
    reply->fields[fcnt].field = pfp.field
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->fields,fcnt)
 ENDIF
 IF (fcnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
