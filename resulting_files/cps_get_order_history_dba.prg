CREATE PROGRAM cps_get_order_history:dba
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
   1 qual_knt = i4
   1 qual[*]
     2 order_id = f8
     2 action_qual_cnt = i4
     2 action_qual[*]
       3 order_id = f8
       3 action_sequence = i4
       3 action_type_cd = f8
       3 action_type_disp = vc
       3 action_type_mean = c12
       3 communication_type_cd = f8
       3 action_dt_tm = dq8
       3 action_tz = i4
       3 action_personnel_name = vc
       3 detail_qual_cnt = i4
       3 detail_qual[*]
         4 oe_field_display_value = vc
         4 oe_field_meaning_id = f8
       3 comment_qual_cnt = i4
       3 comment_qual[*]
         4 comment_type_cd = f8
         4 comment_type_disp = vc
         4 comment_text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET dvar = 0
 CALL echo(" ")
 CALL echo("Getting Action Stuff")
 CALL echo(" ")
 SELECT INTO "nl:"
  d1.seq, oa.order_id, oa.action_sequence,
  p.name_full_formatted
  FROM order_action oa,
   person p,
   (dummyt d1  WITH seq = value(request->qual_knt))
  PLAN (d1
   WHERE d1.seq > 0)
   JOIN (oa
   WHERE (oa.order_id=request->qual[d1.seq].order_id))
   JOIN (p
   WHERE p.person_id=oa.action_personnel_id)
  ORDER BY d1.seq
  HEAD REPORT
   oknt = 0, stat = alterlist(reply->qual,10)
  HEAD oa.order_id
   oknt = (oknt+ 1)
   IF (mod(oknt,10)=1
    AND oknt != 1)
    stat = alterlist(reply->qual,(oknt+ 9))
   ENDIF
   reply->qual[oknt].order_id = request->qual[d1.seq].order_id
  HEAD oa.action_sequence
   aknt = 0, stat = alterlist(reply->qual[oknt].action_qual,10)
  DETAIL
   aknt = (aknt+ 1)
   IF (mod(aknt,10)=1
    AND aknt != 1)
    stat = alterlist(reply->qual[oknt].action_qual,(aknt+ 9))
   ENDIF
   reply->qual[oknt].action_qual[aknt].order_id = oa.order_id, reply->qual[oknt].action_qual[aknt].
   action_sequence = oa.action_sequence, reply->qual[oknt].action_qual[aknt].action_type_cd = oa
   .action_type_cd,
   reply->qual[oknt].action_qual[aknt].communication_type_cd = oa.communication_type_cd, reply->qual[
   oknt].action_qual[aknt].action_dt_tm = oa.action_dt_tm, reply->qual[oknt].action_qual[aknt].
   action_tz = oa.action_tz,
   reply->qual[oknt].action_qual[aknt].action_personnel_name = p.name_full_formatted
  FOOT  oa.action_sequence
   reply->qual[oknt].action_qual_cnt = aknt, stat = alterlist(reply->qual[oknt].action_qual,aknt)
  FOOT REPORT
   reply->qual_knt = oknt, stat = alterlist(reply->qual,oknt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "ORDER_ACTION"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   SET failed = true
   GO TO exit_script
  ELSE
   SET reply->status_data.status = "Z"
   GO TO exit_script
  ENDIF
 ENDIF
 FOR (i = 1 TO reply->qual_knt)
   SELECT INTO "nl:"
    d.seq
    FROM order_detail od,
     (dummyt d  WITH seq = value(reply->qual[i].action_qual_cnt))
    PLAN (d
     WHERE d.seq > 0)
     JOIN (od
     WHERE (od.order_id=reply->qual[i].action_qual[d.seq].order_id)
      AND (od.action_sequence=reply->qual[i].action_qual[d.seq].action_sequence))
    HEAD REPORT
     dvar = 0
    HEAD d.seq
     knt = 0, stat = alterlist(reply->qual[i].action_qual[d.seq].detail_qual,10)
    DETAIL
     knt = (knt+ 1)
     IF (mod(knt,10)=1
      AND knt != 1)
      stat = alterlist(reply->qual[i].action_qual[d.seq].detail_qual,(knt+ 9))
     ENDIF
     reply->qual[i].action_qual[d.seq].detail_qual[knt].oe_field_display_value = od
     .oe_field_display_value, reply->qual[i].action_qual[d.seq].detail_qual[knt].oe_field_meaning_id
      = od.oe_field_meaning_id
    FOOT  d.seq
     reply->qual[i].action_qual[d.seq].detail_qual_cnt = knt, stat = alterlist(reply->qual[i].
      action_qual[d.seq].detail_qual,knt)
    WITH nocounter
   ;end select
   IF (curqual < 1)
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET reply->status_data.subeventstatus[1].operationname = "SELECT"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "ORDER_DETAIL"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     SET failed = true
     GO TO exit_script
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    d.seq
    FROM order_comment oc,
     long_text lt,
     (dummyt d  WITH seq = value(reply->qual[i].action_qual_cnt))
    PLAN (d
     WHERE d.seq > 0)
     JOIN (oc
     WHERE (oc.order_id=reply->qual[i].action_qual[d.seq].order_id)
      AND (oc.action_sequence=reply->qual[i].action_qual[d.seq].action_sequence))
     JOIN (lt
     WHERE lt.long_text_id=oc.long_text_id
      AND lt.active_ind=1)
    HEAD REPORT
     dvar = 0
    HEAD d.seq
     knt = 0, stat = alterlist(reply->qual[i].action_qual[d.seq].comment_qual,10)
    DETAIL
     knt = (knt+ 1)
     IF (mod(knt,10)=1
      AND knt != 1)
      stat = alterlist(reply->qual[i].action_qual[d.seq].comment_qual,(knt+ 9))
     ENDIF
     reply->qual[i].action_qual[d.seq].comment_qual[knt].comment_type_cd = oc.comment_type_cd, reply
     ->qual[i].action_qual[d.seq].comment_qual[knt].comment_text = lt.long_text
    FOOT  d.seq
     reply->qual[i].action_qual[d.seq].comment_qual_cnt = knt, stat = alterlist(reply->qual[i].
      action_qual[d.seq].comment_qual,knt)
    WITH nocounter
   ;end select
   IF (curqual < 1)
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET reply->status_data.subeventstatus[1].operationname = "SELECT"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "ORDER_COMMENT"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     SET failed = true
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (failed=true)
  SET reply->status_data.status = "F"
 ELSE
  IF ((reply->status_data.status != "Z"))
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
END GO
