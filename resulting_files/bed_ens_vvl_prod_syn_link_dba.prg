CREATE PROGRAM bed_ens_vvl_prod_syn_link:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_vv
 RECORD temp_vv(
   1 temps[*]
     2 action_flag = i2
     2 synonym_id = f8
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET error_flag = "N"
 SET req_cnt = size(request->products,5)
 FOR (x = 1 TO req_cnt)
  SET s_size = size(request->products[x].synonyms,5)
  IF (s_size > 0)
   SET ierrcode = 0
   INSERT  FROM synonym_item_r s,
     (dummyt d  WITH seq = value(s_size))
    SET s.synonym_id = request->products[x].synonyms[d.seq].synonym_id, s.item_id = request->
     products[x].item_id, s.updt_applctx = reqinfo->updt_applctx,
     s.updt_cnt = 0, s.updt_dt_tm = cnvtdatetime(curdate,curtime), s.updt_id = reqinfo->updt_id,
     s.updt_task = reqinfo->updt_task
    PLAN (d
     WHERE (request->products[x].synonyms[d.seq].action_flag=1))
     JOIN (s)
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET reply->error_msg = serrmsg
    GO TO exit_script
   ENDIF
   SET ierrcode = 0
   DELETE  FROM synonym_item_r s,
     (dummyt d  WITH seq = value(s_size))
    SET s.seq = 1
    PLAN (d
     WHERE (request->products[x].synonyms[d.seq].action_flag=3))
     JOIN (s
     WHERE (s.synonym_id=request->products[x].synonyms[d.seq].synonym_id)
      AND (s.item_id=request->products[x].item_id))
    WITH nocounter
   ;end delete
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET reply->error_msg = serrmsg
    GO TO exit_script
   ENDIF
  ENDIF
 ENDFOR
#exit_script
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
