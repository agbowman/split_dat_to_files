CREATE PROGRAM dcp_get_order_action:dba
 RECORD reply(
   1 action_cnt = i4
   1 order_id = f8
   1 template_order_id = f8
   1 action_qual[*]
     2 user_id = f8
     2 needs_verify_ind = i2
     2 action_sequence = i4
     2 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE action_cnt = i4 WITH noconstant(0)
 DECLARE tmp_order_id = f8 WITH noconstant(0.0)
 DECLARE template_ord_ind = i2 WITH noconstant(0)
 DECLARE verify_ind = i2 WITH noconstant(0)
 IF ((request->template_order_id > 0))
  SET template_ord_ind = 1
  SET tmp_order_id = request->template_order_id
 ELSE
  SET template_ord_ind = 0
  SET tmp_order_id = request->order_id
 ENDIF
 IF (template_ord_ind=1)
  SELECT INTO "nl:"
   FROM order_action oa,
    prsnl p
   PLAN (oa
    WHERE oa.order_id=tmp_order_id)
    JOIN (p
    WHERE p.person_id=oa.action_personnel_id)
   ORDER BY oa.action_sequence DESC
   HEAD REPORT
    action_cnt = 0, verify_ind = 1
   HEAD oa.action_sequence
    action_cnt = (action_cnt+ 1)
    CASE (oa.needs_verify_ind)
     OF 3:
      verify_ind = 0
     OF 1:
      verify_ind = 1
     OF 4:
      verify_ind = 2
    ENDCASE
    IF (action_cnt > size(reply->action_qual,5))
     stat = alterlist(reply->action_qual,(action_cnt+ 5))
    ENDIF
    reply->action_qual[action_cnt].user_id = oa.action_personnel_id, reply->action_qual[action_cnt].
    action_sequence = oa.action_sequence, reply->action_qual[action_cnt].position_cd = p.position_cd
    CASE (oa.needs_verify_ind)
     OF 0:
      reply->action_qual[action_cnt].needs_verify_ind = 0
     OF 1:
      reply->action_qual[action_cnt].needs_verify_ind = 1
     OF 2:
      reply->action_qual[action_cnt].needs_verify_ind = verify_ind
     OF 3:
      reply->action_qual[action_cnt].needs_verify_ind = 0
     OF 4:
      reply->action_qual[action_cnt].needs_verify_ind = 2
     OF 5:
      reply->action_qual[action_cnt].needs_verify_ind = 0
    ENDCASE
   FOOT REPORT
    reply->action_cnt = action_cnt, reply->order_id = request->order_id, reply->template_order_id =
    request->template_order_id,
    stat = alterlist(reply->action_qual,action_cnt)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM order_action oa,
    prsnl p
   PLAN (oa
    WHERE oa.order_id=tmp_order_id
     AND oa.needs_verify_ind > 0)
    JOIN (p
    WHERE p.person_id=oa.action_personnel_id)
   ORDER BY oa.action_sequence DESC
   HEAD REPORT
    action_cnt = 0
   HEAD oa.action_sequence
    action_cnt = (action_cnt+ 1)
    CASE (oa.needs_verify_ind)
     OF 3:
      verify_ind = 0
     OF 1:
      verify_ind = 1
     OF 4:
      verify_ind = 2
    ENDCASE
    IF (action_cnt > size(reply->action_qual,5))
     stat = alterlist(reply->action_qual,(action_cnt+ 5))
    ENDIF
    reply->action_qual[action_cnt].user_id = oa.action_personnel_id, reply->action_qual[action_cnt].
    action_sequence = oa.action_sequence, reply->action_qual[action_cnt].position_cd = p.position_cd
    CASE (oa.needs_verify_ind)
     OF 0:
      reply->action_qual[action_cnt].needs_verify_ind = 0
     OF 1:
      reply->action_qual[action_cnt].needs_verify_ind = 1
     OF 2:
      reply->action_qual[action_cnt].needs_verify_ind = verify_ind
     OF 3:
      reply->action_qual[action_cnt].needs_verify_ind = 0
     OF 4:
      reply->action_qual[action_cnt].needs_verify_ind = 2
     OF 5:
      reply->action_qual[action_cnt].needs_verify_ind = 0
    ENDCASE
   FOOT REPORT
    reply->action_cnt = action_cnt, reply->order_id = request->order_id, reply->template_order_id =
    request->template_order_id,
    stat = alterlist(reply->action_qual,action_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->action_cnt=0))
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
 SET script_version = "001 08/05/2004 Randy Rogers"
END GO
