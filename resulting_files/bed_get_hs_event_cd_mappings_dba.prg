CREATE PROGRAM bed_get_hs_event_cd_mappings:dba
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
        3 display = vc
        3 event_set_name = vc
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
 DECLARE cnt = i4
 DECLARE r_cnt = i4
 SELECT INTO "nl:"
  FROM br_hlth_sntry_item h,
   br_hlth_sntry_mill_item r,
   v500_event_code vec
  PLAN (h
   WHERE h.code_set=72)
   JOIN (r
   WHERE r.br_hlth_sntry_item_id=h.br_hlth_sntry_item_id)
   JOIN (vec
   WHERE vec.event_cd=r.code_value)
  ORDER BY r.br_hlth_sntry_item_id
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->items,100)
  HEAD r.br_hlth_sntry_item_id
   cnt = (cnt+ 1)
   IF (mod(cnt,100)=0)
    stat = alterlist(reply->items,(cnt+ 100))
   ENDIF
   reply->items[cnt].br_health_sent_item_id = r.br_hlth_sntry_item_id, reply->items[cnt].
   description_1 = h.description_1, reply->items[cnt].description_2 = h.description_2,
   reply->items[cnt].description_3 = h.description_3, reply->items[cnt].description_4 = h
   .description_4, reply->items[cnt].description_5 = h.description_5,
   reply->items[cnt].description_6 = h.description_6, r_cnt = 0, stat = alterlist(reply->items[cnt].
    reltns,10)
  DETAIL
   r_cnt = (r_cnt+ 1)
   IF (mod(r_cnt,10)=0)
    stat = alterlist(reply->items[cnt].reltns,(r_cnt+ 10))
   ENDIF
   reply->items[cnt].reltns[r_cnt].code_value = vec.event_cd, reply->items[cnt].reltns[r_cnt].
   description = vec.event_cd_descr, reply->items[cnt].reltns[r_cnt].display = vec.event_cd_disp,
   reply->items[cnt].reltns[r_cnt].event_set_name = vec.event_set_name, reply->items[cnt].reltns[
   r_cnt].health_sentry_item_relation_id = r.br_hlth_sntry_mill_item_id
  FOOT  r.br_hlth_sntry_item_id
   stat = alterlist(reply->items[cnt].reltns,r_cnt)
  FOOT REPORT
   stat = alterlist(reply->items,cnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error Getting Event Code Mappings")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
