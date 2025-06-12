CREATE PROGRAM bed_get_conv_field_descs:dba
 FREE SET reply
 RECORD reply(
   1 fields[*]
     2 description = vc
     2 user_defined_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET fcnt = 0
 SET alterlist_fcnt = 0
 SET stat = alterlist(reply->fields,50)
 SELECT DISTINCT INTO "NL:"
  FROM pm_flx_prompt pfp
  WHERE pfp.parent_entity_name="PM_FLX_DATA_SOURCE"
   AND pfp.parent_entity_id > 0
   AND pfp.active_ind=1
   AND pfp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND pfp.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND pfp.field != "PERSON.QUESTIONNAIRE*"
  ORDER BY pfp.description
  DETAIL
   fcnt = (fcnt+ 1), alterlist_fcnt = (alterlist_fcnt+ 1)
   IF (alterlist_fcnt > 50)
    stat = alterlist(reply->fields,(fcnt+ 50)), alterlist_fcnt = 1
   ENDIF
   reply->fields[fcnt].description = pfp.description, reply->fields[fcnt].user_defined_ind = 0
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=356
   AND cv.active_ind=1
  ORDER BY cv.description
  DETAIL
   fcnt = (fcnt+ 1), alterlist_fcnt = (alterlist_fcnt+ 1)
   IF (alterlist_fcnt > 50)
    stat = alterlist(reply->fields,(fcnt+ 50)), alterlist_fcnt = 1
   ENDIF
   reply->fields[fcnt].description = cv.description, reply->fields[fcnt].user_defined_ind = 1
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->fields,fcnt)
 IF (fcnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
