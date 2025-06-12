CREATE PROGRAM bed_get_hs_dta_mappings:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 items[*]
      2 br_health_sent_item_id = f8
      2 description_1 = vc
      2 description_2 = vc
      2 description_3 = vc
      2 description_4 = vc
      2 description_5 = vc
      2 description_6 = vc
      2 reltns[*]
        3 health_sentry_item_relation_id = f8
        3 code_value = f8
        3 description = vc
        3 mnemonic = vc
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
 SELECT INTO "nl:"
  FROM br_hlth_sntry_item h,
   br_hlth_sntry_mill_item r,
   code_value c,
   discrete_task_assay d
  PLAN (h
   WHERE h.code_set=14003)
   JOIN (r
   WHERE r.br_hlth_sntry_item_id=h.br_hlth_sntry_item_id)
   JOIN (c
   WHERE c.code_value=r.code_value)
   JOIN (d
   WHERE d.task_assay_cd=c.code_value
    AND d.active_ind=1)
  ORDER BY r.br_hlth_sntry_item_id
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(reply->items,100)
  HEAD r.br_hlth_sntry_item_id
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    cnt = 1, stat = alterlist(reply->items,(tcnt+ 100))
   ENDIF
   reply->items[tcnt].br_health_sent_item_id = r.br_hlth_sntry_item_id, reply->items[tcnt].
   description_1 = h.description_1, reply->items[tcnt].description_2 = h.description_2,
   reply->items[tcnt].description_3 = h.description_3, reply->items[tcnt].description_4 = h
   .description_4, reply->items[tcnt].description_5 = h.description_5,
   reply->items[tcnt].description_6 = h.description_6, r_cnt = 0, r_tcnt = 0,
   stat = alterlist(reply->items[tcnt].reltns,10)
  DETAIL
   r_cnt = (r_cnt+ 1), r_tcnt = (r_tcnt+ 1)
   IF (r_cnt > 10)
    r_cnt = 1, stat = alterlist(reply->items[tcnt].reltns,(r_tcnt+ 10))
   ENDIF
   reply->items[tcnt].reltns[r_tcnt].code_value = c.code_value, reply->items[tcnt].reltns[r_tcnt].
   mnemonic = d.mnemonic, reply->items[tcnt].reltns[r_tcnt].description = d.description,
   reply->items[tcnt].reltns[r_tcnt].health_sentry_item_relation_id = r.br_hlth_sntry_mill_item_id
  FOOT  r.br_hlth_sntry_item_id
   stat = alterlist(reply->items[tcnt].reltns,r_tcnt)
  FOOT REPORT
   stat = alterlist(reply->items,tcnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error Getting Mappings")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
