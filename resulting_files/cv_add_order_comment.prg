CREATE PROGRAM cv_add_order_comment
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE order_note_cd_val = f8 WITH constant(uar_get_code_by("MEANING",14,"ORD COMMENT")), protect
 SET reply->status_data.status = "F"
 DECLARE long_text_id = f8 WITH noconstant(0.0)
 DECLARE max_act = f8 WITH noconstant(0.0)
 SELECT
  o.order_id
  FROM orders o
  WHERE (o.order_id=request->order_id)
  WITH nocounter, forupdatewait(o)
 ;end select
 SELECT INTO "nl:"
  FROM order_comment oc
  WHERE (oc.order_id=request->order_id)
   AND oc.comment_type_cd=order_note_cd_val
  FOOT REPORT
   max_act = max(oc.action_sequence)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  nextsequence = seq(long_data_seq,nextval)
  FROM dual
  DETAIL
   long_text_id = cnvtreal(nextsequence)
  WITH format, nocounter
 ;end select
 INSERT  FROM long_text lt
  SET lt.long_text_id = long_text_id, lt.parent_entity_name = "ORDER_COMMENT", lt.parent_entity_id =
   request->order_id,
   lt.long_text = request->comment, lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
   updt_applctx,
   lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
   cnvtdatetime(curdate,curtime3),
   lt.active_status_prsnl_id = reqinfo->updt_id
  WITH nocounter
 ;end insert
 INSERT  FROM order_comment oc
  SET oc.order_id = request->order_id, oc.long_text_id = long_text_id, oc.comment_type_cd =
   order_note_cd_val,
   oc.action_sequence = (max_act+ 1), oc.updt_dt_tm = cnvtdatetime(curdate,curtime3), oc.updt_id =
   reqinfo->updt_id,
   oc.updt_task = reqinfo->updt_task, oc.updt_applctx = reqinfo->updt_applctx, oc.updt_cnt = 0
  WITH nocounter
 ;end insert
 UPDATE  FROM orders o
  SET o.order_comment_ind = 1, o.comment_type_mask = 1, o.updt_applctx = reqinfo->updt_applctx,
   o.updt_cnt = (o.updt_cnt+ 1), o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->
   updt_id,
   o.updt_task = reqinfo->updt_task
  WHERE (o.order_id=request->order_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
