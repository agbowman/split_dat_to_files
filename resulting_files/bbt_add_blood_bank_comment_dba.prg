CREATE PROGRAM bbt_add_blood_bank_comment:dba
 RECORD reply(
   1 status = c1
   1 process = vc
   1 message = vc
   1 bb_comment_id = f8
   1 bb_comment = vc
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
 RECORD cur_comment(
   1 cur_bb_comment_id = f8
   1 cur_bb_comment = vc
   1 cur_updt_cnt = i4
   1 long_text_id = f8
   1 long_text_updt_cnt = i4
 )
 RECORD new_comment(
   1 new_username = c20
   1 new_bb_comment = vc
 )
 SET reply->status_data.status = "F"
 SET new_pathnet_seq = 0.0
 SET new_bb_comment_id = 0.0
 SET new_long_text_id = 0.0
 SET reqinfo->commit_ind = 0
 SET cur_comment_cnt = 0
 SET count1 = 0
 SET new_comment_ind = " "
 SET gsub_dummy = " "
 SET gsub_status = " "
 SET gsub_process = fillstring(200," ")
 SET gsub_message = fillstring(200," ")
 SET dt_tm_text = fillstring(20," ")
 SET nupdflg = 0
#begin_main
 SET reply->status = "I"
 SET cur_comment_cnt = 0
 SET new_comment_ind = " "
 SELECT INTO "nl:"
  bbc.bb_comment_id, bbc.updt_cnt
  FROM blood_bank_comment bbc
  PLAN (bbc
   WHERE (bbc.person_id=request->person_id)
    AND bbc.active_ind=1
    AND bbc.long_text_id > 0)
  DETAIL
   cur_comment_cnt += 1, cur_comment->cur_bb_comment_id = bbc.bb_comment_id, cur_comment->
   cur_updt_cnt = bbc.updt_cnt,
   cur_comment->long_text_id = bbc.long_text_id
  WITH nocounter, forupdate(bbc)
 ;end select
 SET nupdflg = curqual
 IF (nupdflg > 0)
  SELECT INTO "nl:"
   lt.long_text_id, lt.long_text, lt.updt_cnt
   FROM long_text lt
   PLAN (lt
    WHERE (lt.long_text_id=cur_comment->long_text_id)
     AND lt.active_ind=1
     AND (cur_comment->long_text_id > 0))
   DETAIL
    cur_comment->cur_bb_comment = lt.long_text, cur_comment->long_text_updt_cnt = lt.updt_cnt
   WITH nocounter, forupdate(lt)
  ;end select
  IF (curqual=0)
   SET nupdflg = 0
  ENDIF
 ENDIF
 IF (nupdflg=0)
  IF ((request->bb_comment_id=0))
   IF ((request->bb_comment_id=0)
    AND (request->updt_cnt=0))
    SET new_comment_ind = "Y"
    GO TO add_blood_bank_comment_ctrl
   ELSE
    SET reply->status = "F"
    SET reply->process = "update/archive bb_comment"
    SET reply->message = "existing bb_comment row found for create-new-note request"
    GO TO exit_script
   ENDIF
  ELSE
   SET reply->status = "F"
   SET reply->process = "update/archive bb_comment"
   SET reply->message = "existing bb_comment row to be updated/archived could not be found"
   GO TO exit_script
  ENDIF
 ELSE
  IF (cur_comment_cnt=1)
   IF ((cur_comment->cur_bb_comment_id=request->bb_comment_id)
    AND (cur_comment->long_text_id=request->long_text_id))
    IF ((cur_comment->cur_updt_cnt=request->updt_cnt)
     AND (cur_comment->long_text_updt_cnt=request->long_text_updt_cnt))
     GO TO add_blood_bank_comment_ctrl
    ELSE
     SET reply->status = "F"
     SET reply->process = "update/archive bb_comment"
     SET reply->message = "bb_comment row has been modified by another user--resubmit changes"
     GO TO exit_script
    ENDIF
   ELSE
    SET reply->status = "F"
    SET reply->process = "update/archive bb_comment"
    SET reply->message = "current active bb_comment not found--note not added"
    GO TO exit_script
   ENDIF
  ELSE
   IF (cur_comment_cnt > 1)
    SET reply->status = "F"
    SET reply->process = "update/archive bb_comment"
    SET reply->message =
    "multiple active blood_bank_comment rows exist--new note could not be appended"
   ELSE
    SET reply->status = "F"
    SET reply->process = "update/archive bb_comment"
    SET reply->message =
    "Script error:  rows selected but detail not processed (cur_comment_cnt = 0)"
   ENDIF
   GO TO exit_script
  ENDIF
 ENDIF
#add_blood_bank_comment_ctrl
 IF (new_comment_ind != "Y")
  CALL archive_bb_comment(request->bb_comment_id,request->person_id,request->updt_cnt,request->
   long_text_id,request->long_text_updt_cnt)
  IF (gsub_status="F")
   SET reply->status = gsub_status
   SET reply->process = gsub_process
   SET reply->message = gsub_message
  ENDIF
 ENDIF
 IF ((reply->status != "F"))
  CALL create_bb_comment(gsub_dummy)
  IF ((reply->status != "F"))
   SET reply->bb_comment_id = new_bb_comment_id
   SET reply->bb_comment = new_comment->new_bb_comment
   SET reply->updt_cnt = 0
   SET reply->long_text_id = new_long_text_id
   SET reply->long_text_updt_cnt = 0
   SET reply->status = "S"
   SET reply->process = "SUCCESS"
   SET reply->message = "bb_comment added"
  ENDIF
 ENDIF
 GO TO exit_script
#end_main
 SUBROUTINE archive_bb_comment(sub_bb_comment_id,sub_person_id,sub_bb_comment_updt_cnt,
  sub_pn_long_text_id,sub_pn_long_text_updt_cnt)
  UPDATE  FROM blood_bank_comment bbc
   SET bbc.active_ind = 0, bbc.active_status_cd = reqdata->inactive_status_cd, bbc
    .active_status_dt_tm = cnvtdatetime(sysdate),
    bbc.active_status_prsnl_id = reqinfo->updt_id, bbc.updt_cnt = (bbc.updt_cnt+ 1), bbc.updt_dt_tm
     = cnvtdatetime(sysdate),
    bbc.updt_id = reqinfo->updt_id, bbc.updt_task = reqinfo->updt_task, bbc.updt_applctx = reqinfo->
    updt_applctx
   WHERE bbc.bb_comment_id=sub_bb_comment_id
    AND bbc.person_id=sub_person_id
    AND bbc.updt_cnt=sub_bb_comment_updt_cnt
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET gsub_status = "F"
   SET gsub_process = "inactivate/archive blood_bank_comment"
   SET gsub_message =
   "current active blood_bank_comment row could not be archived--blood_bank_comment not added"
  ELSE
   CALL chg_long_text(sub_pn_long_text_id,sub_pn_long_text_updt_cnt," ",0,reqdata->inactive_status_cd,
    0)
   IF (curqual=0)
    SET gsub_status = "F"
    SET gsub_process = "inactivate/archive long_text"
    SET gsub_message =
    "current active long_text row could not be archived--blood_bank_comment not added"
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE chg_long_text(sub_long_text_id,sub_long_text_updt_cnt,sub_long_text,sub_active_ind,
  sub_active_status_cd,sub_update_text_ind)
   IF (sub_update_text_ind=1)
    UPDATE  FROM long_text lt
     SET lt.long_text = sub_long_text, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_dt_tm = cnvtdatetime(
       sysdate),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
      updt_applctx,
      lt.active_ind = sub_active_ind, lt.active_status_cd = sub_active_status_cd, lt
      .active_status_dt_tm = cnvtdatetime(sysdate),
      lt.active_status_prsnl_id = reqinfo->updt_id
     WHERE lt.long_text_id=sub_long_text_id
      AND lt.updt_cnt=sub_long_text_updt_cnt
     WITH nocounter
    ;end update
   ELSE
    UPDATE  FROM long_text lt
     SET lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_dt_tm = cnvtdatetime(sysdate), lt.updt_id = reqinfo
      ->updt_id,
      lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx, lt.active_ind =
      sub_active_ind,
      lt.active_status_cd = sub_active_status_cd, lt.active_status_dt_tm = cnvtdatetime(sysdate), lt
      .active_status_prsnl_id = reqinfo->updt_id
     WHERE lt.long_text_id=sub_long_text_id
      AND lt.updt_cnt=sub_long_text_updt_cnt
     WITH nocounter
    ;end update
   ENDIF
 END ;Subroutine
 SUBROUTINE create_bb_comment(gsub_dummy2)
  SELECT INTO "nl:"
   pnl.username
   FROM prsnl pnl
   WHERE (pnl.person_id=reqinfo->updt_id)
   DETAIL
    new_comment->new_username = pnl.username
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status = "F"
   SET reply->process = "get personnel username"
   SET reply->message = "get personnel username failed--note not added"
  ELSE
   SET dt_tm_text = format(cnvtdatetime(curdate,curtime),cclfmt->mediumdatetime)
   IF (new_comment_ind="Y")
    SET new_comment->new_bb_comment = concat(">> ",trim(dt_tm_text),"  ",trim(new_comment->
      new_username),"   ",
     trim(request->new_bb_comment))
   ELSE
    SET new_comment->new_bb_comment = concat(">> ",trim(dt_tm_text),"  ",trim(new_comment->
      new_username),"   ",
     trim(request->new_bb_comment),char(13),char(10),char(13),char(10),
     cur_comment->cur_bb_comment)
   ENDIF
   CALL add_bb_comment(request->person_id,new_comment->new_bb_comment)
   IF (gsub_status="F")
    SET reply->status = gsub_status
    SET reply->process = gsub_process
    SET reply->message = gsub_message
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE add_bb_comment(sub_person_id,sub_bb_comment)
   SET new_bb_comment_id = 0.0
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
    SET gsub_process = "get new bb_comment_id (PATHNET_SEQ)"
    SET gsub_message = "get new bb_comment_id (PATHNET_SEQ) failed"
   ELSE
    SET new_bb_comment_id = new_pathnet_seq
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
     INSERT  FROM blood_bank_comment bbc
      SET bbc.bb_comment_id = new_bb_comment_id, bbc.person_id = sub_person_id, bbc.long_text_id =
       new_long_text_id,
       bbc.active_ind = 1, bbc.active_status_cd = reqdata->active_status_cd, bbc.active_status_dt_tm
        = cnvtdatetime(sysdate),
       bbc.active_status_prsnl_id = reqinfo->updt_id, bbc.updt_cnt = 0, bbc.updt_dt_tm = cnvtdatetime
       (sysdate),
       bbc.updt_id = reqinfo->updt_id, bbc.updt_task = reqinfo->updt_task, bbc.updt_applctx = reqinfo
       ->updt_applctx,
       bbc.comment_dt_tm = cnvtdatetime(sysdate), bbc.comment_added_prsnl_id = reqinfo->updt_id
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET gsub_status = "F"
      SET gsub_process = "insert into bb_comment"
      SET gsub_message = "insert into blood_bank_comment failed"
     ELSE
      CALL add_long_text(new_long_text_id,"BLOOD_BANK_COMMENT",new_bb_comment_id,sub_bb_comment)
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
     lt.long_text = sub_long_text, lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(sysdate),
     lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
     updt_applctx,
     lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
     cnvtdatetime(sysdate),
     lt.active_status_prsnl_id = reqinfo->updt_id
    WITH nocounter
   ;end insert
 END ;Subroutine
#exit_script
 SET count1 += 1
 IF (count1 > size(reply->status_data.subeventstatus,5))
  SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
 ENDIF
 IF ((reply->status="S"))
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[count1].operationname = "Success"
  SET reply->status_data.subeventstatus[count1].operationstatus = "S"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_add_blood_bank_comment"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "bb comment added"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = reply->status
  SET reply->status_data.subeventstatus[count1].operationname = reply->process
  SET reply->status_data.subeventstatus[count1].operationstatus = reply->status
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_add_blood_bank_comment"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = reply->message
 ENDIF
END GO
