CREATE PROGRAM bed_ens_br_long_text:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET temp_items
 RECORD temp_items(
   1 items[*]
     2 action_flag = i2
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 long_text = vc
 )
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET req_cnt = size(request->items,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(temp_items->items,req_cnt)
 FOR (x = 1 TO req_cnt)
   SET temp_items->items[x].action_flag = 1
   SET temp_items->items[x].parent_entity_id = request->items[x].parent_entity_id
   SET temp_items->items[x].parent_entity_name = request->items[x].parent_entity_name
   SET temp_items->items[x].long_text = request->items[x].long_text
 ENDFOR
 SELECT INTO "NL:"
  FROM br_long_text lt,
   (dummyt d  WITH seq = value(req_cnt))
  PLAN (d)
   JOIN (lt
   WHERE (lt.parent_entity_id=temp_items->items[d.seq].parent_entity_id)
    AND (lt.parent_entity_name=temp_items->items[d.seq].parent_entity_name))
  DETAIL
   temp_items->items[d.seq].action_flag = 2
  WITH nocounter
 ;end select
 SET ierrcode = 0
 INSERT  FROM br_long_text lt,
   (dummyt d  WITH seq = value(req_cnt))
  SET lt.long_text_id = seq(bedrock_seq,nextval), lt.long_text = temp_items->items[d.seq].long_text,
   lt.parent_entity_name = temp_items->items[d.seq].parent_entity_name,
   lt.parent_entity_id = temp_items->items[d.seq].parent_entity_id, lt.updt_id = reqinfo->updt_id, lt
   .updt_cnt = 0,
   lt.updt_applctx = reqinfo->updt_applctx, lt.updt_task = reqinfo->updt_task, lt.updt_dt_tm =
   cnvtdatetime(curdate,curtime3)
  PLAN (d
   WHERE (temp_items->items[d.seq].action_flag=1))
   JOIN (lt)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Insert br_long_text rows."
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 UPDATE  FROM br_long_text lt,
   (dummyt d  WITH seq = value(req_cnt))
  SET lt.long_text = temp_items->items[d.seq].long_text, lt.updt_id = reqinfo->updt_id, lt.updt_cnt
    = (lt.updt_cnt+ 1),
   lt.updt_applctx = reqinfo->updt_applctx, lt.updt_task = reqinfo->updt_task, lt.updt_dt_tm =
   cnvtdatetime(curdate,curtime3)
  PLAN (d
   WHERE (temp_items->items[d.seq].action_flag=2))
   JOIN (lt
   WHERE (lt.parent_entity_name=temp_items->items[d.seq].parent_entity_name)
    AND (lt.parent_entity_id=temp_items->items[d.seq].parent_entity_id))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Update br_long_text rows."
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
