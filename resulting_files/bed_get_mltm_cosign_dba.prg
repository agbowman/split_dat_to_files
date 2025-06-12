CREATE PROGRAM bed_get_mltm_cosign:dba
 FREE SET reply
 RECORD reply(
   1 cosignatures[*]
     2 action
       3 code_value = f8
       3 display = vc
     2 cosign_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE parse_action = vc
 SET reply->status_data.status = "F"
 SET pharmacy_code_value = 0.0
 SET cnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cdf_meaning="PHARMACY"
   AND cv.code_set=6000
   AND cv.active_ind=1
  DETAIL
   pharmacy_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6003
   AND cv.cdf_meaning IN ("ACTIVATE", "CANCEL", "CANCEL REORD", "CLEAR", "COMPLETE",
  "DISCONTINUE", "FUTUREDC", "MODIFY", "ORDER", "REFILL",
  "RENEW", "RESCHEDULE", "RESTORE", "RESUME", "SUSPEND",
  "TRANSFER/CAN", "DELETE")
   AND cv.active_ind=1
  HEAD REPORT
   comma_flag = 0
  DETAIL
   IF (comma_flag=0)
    parse_action = build("ocr.action_type_cd IN (",cv.code_value)
   ELSE
    parse_action = build(parse_action,", ",cv.code_value)
   ENDIF
   comma_flag = 1
  FOOT REPORT
   parse_action = concat(parse_action,")")
  WITH nocounter
 ;end select
 FREE SET temp
 RECORD temp(
   1 actions[*]
     2 code_value = f8
     2 display = vc
     2 meaning = vc
     2 cosign_flag = i2
     2 count = i4
 )
 SET percent_level = 0.0
 SET tcnt = 0
 SET qual_cnt = 0
 SELECT INTO "nl:"
  FROM order_catalog oc,
   code_value c
  PLAN (oc
   WHERE oc.catalog_type_cd=pharmacy_code_value
    AND oc.orderable_type_flag IN (0, 1)
    AND oc.active_ind=1)
   JOIN (c
   WHERE c.code_value=oc.catalog_cd
    AND c.active_ind=1)
  DETAIL
   qual_cnt = (qual_cnt+ 1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value c,
   order_catalog_review ocr,
   order_catalog oc
  PLAN (oc
   WHERE oc.catalog_type_cd=pharmacy_code_value
    AND oc.orderable_type_flag IN (0, 1)
    AND oc.active_ind=1)
   JOIN (ocr
   WHERE ocr.catalog_cd=oc.catalog_cd
    AND ocr.doctor_cosign_flag > 0)
   JOIN (c
   WHERE c.code_value=ocr.action_type_cd
    AND c.code_set=6003
    AND c.active_ind=1)
  ORDER BY ocr.action_type_cd, ocr.doctor_cosign_flag
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(temp->actions,10)
  HEAD ocr.action_type_cd
   cnt = cnt
  HEAD ocr.doctor_cosign_flag
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 10)
    stat = alterlist(temp->actions,(tcnt+ 10)), cnt = 1
   ENDIF
   temp->actions[tcnt].code_value = ocr.action_type_cd, temp->actions[tcnt].display = c.display, temp
   ->actions[tcnt].meaning = c.cdf_meaning,
   temp->actions[tcnt].cosign_flag = ocr.doctor_cosign_flag
  DETAIL
   temp->actions[tcnt].count = (temp->actions[tcnt].count+ 1)
  FOOT REPORT
   stat = alterlist(temp->actions,tcnt)
  WITH nocounter
 ;end select
 SET percent_level = (qual_cnt * 0.90)
 SET fin_cnt = 0
 FOR (x = 1 TO tcnt)
   IF (cnvtreal(temp->actions[x].count) >= percent_level)
    SET fin_cnt = (fin_cnt+ 1)
    SET stat = alterlist(reply->cosignatures,fin_cnt)
    SET reply->cosignatures[fin_cnt].action.code_value = temp->actions[x].code_value
    SET reply->cosignatures[fin_cnt].action.display = temp->actions[x].display
    SET reply->cosignatures[fin_cnt].cosign_flag = temp->actions[x].cosign_flag
   ENDIF
 ENDFOR
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
 CALL echorecord(temp)
 CALL echo(percent_level)
END GO
