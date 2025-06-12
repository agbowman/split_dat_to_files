CREATE PROGRAM cps_get_order_detail:dba
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
 FREE SET reply
 RECORD reply(
   1 qual_cnt = i4
   1 qual[*]
     2 order_id = f8
     2 details_qual = i4
     2 encntr_id = f8
     2 requisition_format_cd = f8
     2 requisition_object_name = vc
     2 details[*]
       3 oe_field_value_display = vc
       3 oe_field_dt_tm_value = dq8
       3 oe_field_tz = i4
       3 oe_field_meaning_id = f8
       3 oe_field_meaning = c25
       3 oe_field_id = f8
       3 oe_field_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE num1 = i4 WITH protect, noconstant(0)
 DECLARE routingiter = i4 WITH protect, noconstant(- (1))
 DECLARE routingactionseq = i4 WITH protect, noconstant(- (1))
 DECLARE tmp_idx = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM order_detail od
  PLAN (od
   WHERE expand(num1,1,value(size(request->qual,5)),od.order_id,request->qual[num1].order_id)
    AND od.oe_field_meaning_id IN (1, 7, 10, 18, 67,
   138, 139, 140, 142, 1558,
   2011, 2015, 2017, 2037, 2050,
   2056, 2057, 2058, 2059, 2061,
   2062, 2063, 2091, 2092, 2102,
   2101, 2105, 2108, 2290, 2291,
   1103))
  ORDER BY od.order_id, od.oe_field_meaning_id, od.action_sequence DESC
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->qual,10)
  HEAD od.order_id
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alterlist(reply->qual,(cnt+ 9))
   ENDIF
   reply->qual[cnt].order_id = od.order_id, cnt2 = 0, routingactionseq = - (1),
   routingiter = - (1), stat = alterlist(reply->qual[cnt].details,10)
  HEAD od.oe_field_meaning_id
   IF (od.oe_field_meaning_id IN (18, 138, 139, 2105))
    IF (od.action_sequence > routingactionseq
     AND ((od.oe_field_display_value != ""
     AND od.oe_field_display_value != null) OR (od.oe_field_value > 0)) )
     routingactionseq = od.action_sequence
     IF ((routingiter=- (1)))
      cnt2 = (cnt2+ 1), routingiter = cnt2
      IF (mod(cnt2,10)=1
       AND cnt2 != 1)
       stat = alterlist(reply->qual[cnt].details,(cnt2+ 9))
      ENDIF
     ENDIF
     reply->qual[cnt].details[routingiter].oe_field_value_display = od.oe_field_display_value, reply
     ->qual[cnt].details[routingiter].oe_field_dt_tm_value = od.oe_field_dt_tm_value, reply->qual[cnt
     ].details[routingiter].oe_field_tz = od.oe_field_tz,
     reply->qual[cnt].details[routingiter].oe_field_meaning_id = od.oe_field_meaning_id, reply->qual[
     cnt].details[routingiter].oe_field_meaning = od.oe_field_meaning, reply->qual[cnt].details[
     routingiter].oe_field_id = od.oe_field_id,
     reply->qual[cnt].details[routingiter].oe_field_value = od.oe_field_value
    ENDIF
   ELSE
    cnt2 = (cnt2+ 1)
    IF (mod(cnt2,10)=1
     AND cnt2 != 1)
     stat = alterlist(reply->qual[cnt].details,(cnt2+ 9))
    ENDIF
    reply->qual[cnt].details[cnt2].oe_field_value_display = od.oe_field_display_value, reply->qual[
    cnt].details[cnt2].oe_field_dt_tm_value = od.oe_field_dt_tm_value, reply->qual[cnt].details[cnt2]
    .oe_field_tz = od.oe_field_tz,
    reply->qual[cnt].details[cnt2].oe_field_meaning_id = od.oe_field_meaning_id, reply->qual[cnt].
    details[cnt2].oe_field_meaning = od.oe_field_meaning, reply->qual[cnt].details[cnt2].oe_field_id
     = od.oe_field_id,
    reply->qual[cnt].details[cnt2].oe_field_value = od.oe_field_value
   ENDIF
  DETAIL
   dvar = 0
  FOOT  od.order_id
   stat = alterlist(reply->qual[cnt].details,cnt2), reply->qual[cnt].details_qual = cnt2
  FOOT REPORT
   reply->qual_cnt = cnt, stat = alterlist(reply->qual,cnt)
  WITH nocounter
 ;end select
 IF ((request->get_requisition_info_ind=1))
  SELECT INTO "nl:"
   *
   FROM orders o,
    order_catalog oc
   PLAN (o
    WHERE expand(num1,1,value(reply->qual_cnt),o.order_id,reply->qual[num1].order_id))
    JOIN (oc
    WHERE oc.catalog_cd=o.catalog_cd)
   DETAIL
    ord_idx = locateval(tmp_idx,1,reply->qual_cnt,o.order_id,reply->qual[tmp_idx].order_id)
    IF (ord_idx > 0)
     reply->qual[ord_idx].requisition_format_cd = oc.requisition_format_cd, reply->qual[ord_idx].
     requisition_object_name = uar_get_code_meaning(oc.requisition_format_cd), reply->qual[ord_idx].
     encntr_id = o.encntr_id
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ORDERS"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ELSE
  IF (curqual < 1)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
#exit_script
 SET script_version = "010 06/02/08 SJ016555"
END GO
