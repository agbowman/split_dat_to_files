CREATE PROGRAM bbt_add_product_note:dba
 RECORD reply(
   1 status = c1
   1 process = vc
   1 message = vc
   1 product_note_id = f8
   1 product_note = vc
   1 updt_cnt = i4
   1 long_text_id = f8
   1 long_text_updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD cur_note(
   1 cur_product_note_id = f8
   1 cur_product_note = vc
   1 cur_updt_cnt = i4
   1 cur_lt_updt_cnt = i4
   1 long_text_id = f8
   1 long_text_updt_cnt = i4
 )
 RECORD new_note(
   1 new_username = c20
   1 new_product_note = vc
 )
 SET reply->status_data.status = "F"
 SET new_pathnet_seq = 0.0
 SET new_product_note_id = 0.0
 SET new_long_text_id = 0.0
 SET reqinfo->commit_ind = 0
 SET cur_note_cnt = 0
 SET count1 = 0
 SET new_note_ind = " "
 SET gsub_dummy = " "
 SET gsub_status = " "
 SET gsub_process = fillstring(200," ")
 SET gsub_message = fillstring(200," ")
 SET dt_tm_text = fillstring(20," ")
#begin_main
 SET reply->status = "I"
 SET cur_note_cnt = 0
 SET new_note_ind = " "
 SELECT INTO "nl:"
  pn.product_note_id, pn.updt_cnt, pn.long_text_id
  FROM product_note pn
  PLAN (pn
   WHERE (pn.product_id=request->product_id)
    AND pn.active_ind=1
    AND pn.long_text_id > 0)
  DETAIL
   cur_note_cnt = (cur_note_cnt+ 1), cur_note->cur_product_note_id = pn.product_note_id, cur_note->
   cur_updt_cnt = pn.updt_cnt,
   cur_note->long_text_id = pn.long_text_id
  WITH nocounter, forupdate(pn)
 ;end select
 IF (curqual > 0)
  SELECT INTO "nl:"
   lt.long_text_id
   FROM long_text lt
   PLAN (lt
    WHERE (lt.long_text_id=cur_note->long_text_id))
   DETAIL
    cur_note->cur_product_note = lt.long_text, cur_note->long_text_updt_cnt = lt.updt_cnt
   WITH nocounter, forupdate(lt)
  ;end select
 ENDIF
 IF (curqual=0)
  IF ((request->product_note_id=0))
   IF ((request->product_note_id=0)
    AND (request->updt_cnt=0))
    SET new_note_ind = "Y"
    GO TO add_product_note_ctrl
   ELSE
    SET reply->status = "F"
    SET reply->process = "update/archive product_note"
    SET reply->message = "existing product_note row found for create-new-note request"
    GO TO exit_script
   ENDIF
  ELSE
   SET reply->status = "F"
   SET reply->process = "update/archive product_note"
   SET reply->message = "existing product_note row to be updated/archived could not be found"
   GO TO exit_script
  ENDIF
 ELSE
  IF (cur_note_cnt=1)
   IF ((cur_note->cur_product_note_id=request->product_note_id)
    AND (cur_note->long_text_id=request->long_text_id))
    IF ((cur_note->cur_updt_cnt=request->updt_cnt)
     AND (cur_note->long_text_updt_cnt=request->long_text_updt_cnt))
     GO TO add_product_note_ctrl
    ELSE
     SET reply->status = "F"
     SET reply->process = "update/archive product_note"
     SET reply->message = "product_note row has been modified by another user--resubmit changes"
     GO TO exit_script
    ENDIF
   ELSE
    SET reply->status = "F"
    SET reply->process = "update/archive product_note"
    SET reply->message = "current active product_note not found--note not added"
    GO TO exit_script
   ENDIF
  ELSE
   IF (cur_note_cnt > 1)
    SET reply->status = "F"
    SET reply->process = "update/archive product_note"
    SET reply->message = "multiple active proudct_note rows exist--new note could not be appended"
   ELSE
    SET reply->status = "F"
    SET reply->process = "update/archive product_note"
    SET reply->message = "Script error:  rows selected but detail not processed (cur_note_cnt = 0)"
   ENDIF
   GO TO exit_script
  ENDIF
 ENDIF
#add_product_note_ctrl
 IF (new_note_ind != "Y")
  CALL archive_product_note(request->product_note_id,request->product_id,request->updt_cnt,request->
   long_text_id,request->long_text_updt_cnt)
  IF (gsub_status="F")
   SET reply->status = gsub_status
   SET reply->process = gsub_process
   SET reply->message = gsub_message
  ENDIF
 ENDIF
 IF ((reply->status != "F"))
  CALL create_product_note(gsub_dummy)
  IF ((reply->status != "F"))
   SET reply->product_note_id = new_product_note_id
   SET reply->product_note = new_note->new_product_note
   SET reply->updt_cnt = 0
   SET reply->long_text_id = new_long_text_id
   SET reply->long_text_updt_cnt = 0
   SET reply->status = "S"
   SET reply->process = "SUCCESS"
   SET reply->message = "product_note added"
  ENDIF
 ENDIF
 GO TO exit_script
 SUBROUTINE archive_product_note(sub_product_note_id,sub_product_id,sub_product_note_updt_cnt,
  sub_pn_long_text_id,sub_pn_long_text_updt_cnt)
  UPDATE  FROM product_note pn
   SET pn.active_ind = 0, pn.active_status_cd = reqdata->inactive_status_cd, pn.active_status_dt_tm
     = cnvtdatetime(curdate,curtime3),
    pn.active_status_prsnl_id = reqinfo->updt_id, pn.updt_cnt = (pn.updt_cnt+ 1), pn.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    pn.updt_id = reqinfo->updt_id, pn.updt_task = reqinfo->updt_task, pn.updt_applctx = reqinfo->
    updt_applctx
   WHERE pn.product_note_id=sub_product_note_id
    AND pn.product_id=sub_product_id
    AND pn.updt_cnt=sub_product_note_updt_cnt
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET gsub_status = "F"
   SET gsub_process = "inactivate/archive product_note"
   SET gsub_message = "current active product_note row could not be archived--product_note not added"
  ELSE
   CALL chg_long_text(sub_pn_long_text_id,sub_pn_long_text_updt_cnt," ",0,reqdata->inactive_status_cd,
    0)
   IF (curqual=0)
    SET gsub_status = "F"
    SET gsub_process = "inactivate/archive long_text"
    SET gsub_message = "current active long_text row could not be archived--product_note not added"
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE chg_long_text(sub_long_text_id,sub_long_text_updt_cnt,sub_long_text,sub_active_ind,
  sub_active_status_cd,sub_update_text_ind)
   IF (sub_update_text_ind=1)
    UPDATE  FROM long_text lt
     SET lt.long_text = sub_long_text, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
      updt_applctx,
      lt.active_ind = sub_active_ind, lt.active_status_cd = sub_active_status_cd, lt
      .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
      lt.active_status_prsnl_id = reqinfo->updt_id
     WHERE lt.long_text_id=sub_long_text_id
      AND lt.updt_cnt=sub_long_text_updt_cnt
     WITH nocounter
    ;end update
   ELSE
    UPDATE  FROM long_text lt
     SET lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id
       = reqinfo->updt_id,
      lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx, lt.active_ind =
      sub_active_ind,
      lt.active_status_cd = sub_active_status_cd, lt.active_status_dt_tm = cnvtdatetime(curdate,
       curtime3), lt.active_status_prsnl_id = reqinfo->updt_id
     WHERE lt.long_text_id=sub_long_text_id
      AND lt.updt_cnt=sub_long_text_updt_cnt
     WITH nocounter
    ;end update
   ENDIF
 END ;Subroutine
 SUBROUTINE create_product_note(gsub_dummy2)
  SELECT INTO "nl:"
   pnl.username
   FROM prsnl pnl
   WHERE (pnl.person_id=reqinfo->updt_id)
   DETAIL
    new_note->new_username = pnl.username
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status = "F"
   SET reply->process = "get personnel username"
   SET reply->message = "get personnel username failed--note not added"
  ELSE
   SET dt_tm_text = format(cnvtdatetime(curdate,curtime),cclfmt->mediumdatetime)
   IF (new_note_ind="Y")
    SET new_note->new_product_note = concat(">> ",trim(dt_tm_text),"  ",trim(new_note->new_username),
     "   ",
     trim(request->new_product_note))
   ELSE
    SET new_note->new_product_note = concat(">> ",trim(dt_tm_text),"  ",trim(new_note->new_username),
     "   ",
     trim(request->new_product_note),char(13),char(10),char(13),char(10),
     cur_note->cur_product_note)
   ENDIF
   CALL add_product_note(request->product_id,new_note->new_product_note)
   IF (gsub_status="F")
    SET reply->status = gsub_status
    SET reply->process = gsub_process
    SET reply->message = gsub_message
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE add_product_note(sub_product_id,sub_product_note)
   SET new_product_note_id = 0.0
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET gsub_status = "F"
    SET gsub_process = "get new product_note_id (PATHNET_SEQ)"
    SET gsub_message = "get new product_note_id (PATHNET_SEQ) failed"
   ELSE
    SET new_product_note_id = new_pathnet_seq
    SET new_long_text_id = 0.0
    SELECT INTO "nl:"
     seqn = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      new_long_text_id = seqn
     WITH format, nocounter
    ;end select
    IF (curqual=0)
     SET gsub_status = "F"
     SET gsub_process = "get new long_text_id (LONG_DATA_SEQ)"
     SET gsub_message = "get new long_text_id (LONG_DATA_SEQ) failed"
    ELSE
     INSERT  FROM product_note pn
      SET pn.product_note_id = new_product_note_id, pn.product_id = sub_product_id, pn.long_text_id
        = new_long_text_id,
       pn.active_ind = 1, pn.active_status_cd = reqdata->active_status_cd, pn.active_status_dt_tm =
       cnvtdatetime(curdate,curtime3),
       pn.active_status_prsnl_id = reqinfo->updt_id, pn.updt_cnt = 0, pn.updt_dt_tm = cnvtdatetime(
        curdate,curtime3),
       pn.updt_id = reqinfo->updt_id, pn.updt_task = reqinfo->updt_task, pn.updt_applctx = reqinfo->
       updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET gsub_status = "F"
      SET gsub_process = "insert into product_note"
      SET gsub_message = "insert into product_note failed"
     ELSE
      CALL add_long_text(new_long_text_id,"PRODUCT_NOTE",new_product_note_id,sub_product_note)
      IF (curqual=0)
       SET gsub_status = "F"
       SET gsub_process = "insert into long_text"
       SET gsub_message = "insert into long_text failed"
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE add_long_text(sub_long_text_id,sub_parent_entity_name,sub_parent_entity_id,sub_long_text)
   INSERT  FROM long_text lt
    SET lt.long_text_id = sub_long_text_id, lt.parent_entity_name = sub_parent_entity_name, lt
     .parent_entity_id = sub_parent_entity_id,
     lt.long_text = sub_long_text, lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
     updt_applctx,
     lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
     cnvtdatetime(curdate,curtime3),
     lt.active_status_prsnl_id = reqinfo->updt_id
    WITH nocounter
   ;end insert
 END ;Subroutine
#exit_script
 SET count1 = (count1+ 1)
 IF (count1 > size(reply->status_data.subeventstatus,5))
  SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
 ENDIF
 IF ((reply->status="S"))
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[count1].operationname = "Success"
  SET reply->status_data.subeventstatus[count1].operationstatus = "S"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_add_product_note"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "product note added"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = reply->status
  SET reply->status_data.subeventstatus[count1].operationname = reply->process
  SET reply->status_data.subeventstatus[count1].operationstatus = reply->status
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_add_product_note"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = reply->message
 ENDIF
END GO
