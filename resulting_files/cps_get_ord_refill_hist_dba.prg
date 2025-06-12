CREATE PROGRAM cps_get_ord_refill_hist:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 FREE RECORD reply
 RECORD reply(
   1 qual_cnt = i4
   1 qual[*]
     2 order_id = f8
     2 details_qual = i4
     2 details[*]
       3 action_sequence = i4
       3 updt_dt_tm = dq8
       3 oe_field_value_display = vc
       3 oe_field_dt_tm_value = dq8
       3 oe_field_tz = i4
       3 oe_field_meaning_id = f8
       3 oe_field_meaning = c25
       3 oe_field_id = f8
       3 oe_field_value = f8
       3 updt_id = f8
       3 updt_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SELECT INTO "nl:"
  FROM order_detail od,
   prsnl p,
   (dummyt d  WITH seq = value(request->qual_cnt))
  PLAN (d
   WHERE d.seq > 0)
   JOIN (od
   WHERE (od.order_id=request->qual[d.seq].order_id)
    AND od.oe_field_meaning IN ("REQREFILLDATE", "ADDITIONALREFILLS"))
   JOIN (p
   WHERE p.person_id=od.updt_id)
  ORDER BY od.order_id, od.action_sequence, od.oe_field_id
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->qual,1)
  HEAD od.order_id
   cnt2 = 0, cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->qual,(cnt+ 9))
   ENDIF
   reply->qual[cnt].order_id = od.order_id
  DETAIL
   cnt2 = (cnt2+ 1)
   IF (size(reply->qual[cnt].details,5) < cnt2)
    stat = alterlist(reply->qual[cnt].details,(cnt2+ 5))
   ENDIF
   reply->qual[cnt].details[cnt2].action_sequence = od.action_sequence, reply->qual[cnt].details[cnt2
   ].updt_dt_tm = od.updt_dt_tm, reply->qual[cnt].details[cnt2].updt_id = od.updt_id,
   reply->qual[cnt].details[cnt2].updt_name = p.name_full_formatted, reply->qual[cnt].details[cnt2].
   oe_field_value_display = od.oe_field_display_value, reply->qual[cnt].details[cnt2].
   oe_field_dt_tm_value = od.oe_field_dt_tm_value,
   reply->qual[cnt].details[cnt2].oe_field_tz = od.oe_field_tz, reply->qual[cnt].details[cnt2].
   oe_field_meaning_id = od.oe_field_meaning_id, reply->qual[cnt].details[cnt2].oe_field_meaning = od
   .oe_field_meaning,
   reply->qual[cnt].details[cnt2].oe_field_id = od.oe_field_id, reply->qual[cnt].details[cnt2].
   oe_field_value = od.oe_field_value
  FOOT  od.order_id
   stat = alterlist(reply->qual[cnt].details,cnt2), reply->qual[cnt].details_qual = cnt2
  FOOT REPORT
   reply->qual_cnt = cnt, stat = alterlist(reply->qual,cnt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ORDER_DETAIL"
  GO TO exit_script
 ELSEIF ((reply->qual_cnt < 1))
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
 ENDIF
END GO
