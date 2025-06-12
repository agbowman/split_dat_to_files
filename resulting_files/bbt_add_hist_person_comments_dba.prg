CREATE PROGRAM bbt_add_hist_person_comments:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE script_name = c40 WITH public, constant("bbt_add_person_comments")
 DECLARE new_long_text_id = f8 WITH public, noconstant(0.0)
 DECLARE long_text_id_new = f8 WITH public, noconstant(0.0)
 DECLARE bb_comment_id_new = f8 WITH public, noconstant(0.0)
 DECLARE active_exists_ind = i2 WITH public, noconstant(0)
 DECLARE i = i4 WITH public, noconstant(0)
 DECLARE item_prsnl_id = f8 WITH private, noconstant(0.0)
 DECLARE item_dt_tm = q8 WITH private, noconstant(cnvtdatetime(sysdate))
 DECLARE bb_comment_updt_cnt = i4 WITH public, noconstant(0)
 DECLARE long_text_updt_cnt = i4 WITH public, noconstant(0)
 DECLARE new_line = c2 WITH public, constant(concat(char(13),char(11)))
 RECORD comment(
   1 existing_comment = vc
   1 new_comment = vc
 )
 IF ( NOT ((request->contributor_system_cd > 0.0)))
  CALL fill_out_status_data("F","Validate contrib_sys_cd",
   "Validation of contributor system code failed - Contributor system code not > 0")
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO size(request->qual,5))
   SET comment->existing_comment = " "
   SET comment->new_comment = " "
   IF (perform_data_validation(request->qual[i].person_id,i)=0)
    GO TO exit_script
   ENDIF
   IF ((request->qual[i].comment_prsnl_id > 0.0))
    SET item_prsnl_id = request->qual[i].comment_prsnl_id
   ELSE
    SET item_prsnl_id = request->active_status_prsnl_id
   ENDIF
   IF ((request->qual[i].comment_dt_tm > 0))
    SET item_dt_tm = request->qual[i].comment_dt_tm
   ELSE
    SET item_dt_tm = cnvtdatetime(sysdate)
   ENDIF
   IF (get_active_comment(request->qual[i].person_id)=0)
    GO TO exit_script
   ENDIF
   IF (active_exists_ind=1)
    IF (update_bb_comment(bb_comment_id_new,bb_comment_updt_cnt,long_text_id_new,long_text_updt_cnt,0,
     item_prsnl_id,item_dt_tm)=0)
     GO TO exit_script
    ENDIF
    IF ((request->comment_append_ind=1))
     SET comment->new_comment = concat(comment->existing_comment,new_line,new_line,request->qual[i].
      comment)
    ELSE
     SET comment->new_comment = concat(request->qual[i].comment,new_line,new_line,comment->
      existing_comment)
    ENDIF
    IF (insert_bb_comment(request->qual[i].person_id,0,request->contributor_system_cd,item_prsnl_id,
     item_dt_tm)=0)
     GO TO exit_script
    ENDIF
   ELSE
    IF (insert_bb_comment(request->qual[i].person_id,i,request->contributor_system_cd,item_prsnl_id,
     item_dt_tm)=0)
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 GO TO exit_script
 SUBROUTINE (update_bb_comment(bb_comment_id_new=f8,bb_comment_updt_cnt=i4,long_text_id_new=f8,
  long_text_updt_cnt=i4,active_ind_new=i2,active_status_prsnl_id_new=f8,active_status_dt_tm=dq8) =i2)
   SELECT INTO "nl:"
    bbc.bb_comment_id
    FROM blood_bank_comment bbc
    WHERE bbc.bb_comment_id=bb_comment_id_new
     AND bbc.bb_comment_id > 0.0
     AND bbc.updt_cnt=bb_comment_updt_cnt
    WITH nocounter, forupdate(bbc)
   ;end select
   IF (check_for_ccl_error("lock bbc forupdate")=0)
    RETURN(0)
   ELSE
    IF (curqual=0)
     CALL fill_out_status_data("F","lock bbc forupdate",
      "unable to lock blood_bank_comment table for update")
     RETURN(0)
    ENDIF
   ENDIF
   UPDATE  FROM blood_bank_comment bbc
    SET bbc.active_ind = active_ind_new, bbc.active_status_cd =
     IF (active_ind_new=1) reqdata->active_status_cd
     ELSE reqdata->inactive_status_cd
     ENDIF
     , bbc.active_status_dt_tm = cnvtdatetime(active_status_dt_tm),
     bbc.active_status_prsnl_id = active_status_prsnl_id_new, bbc.updt_cnt = 0, bbc.updt_dt_tm =
     cnvtdatetime(sysdate),
     bbc.updt_id = reqinfo->updt_id, bbc.updt_task = reqinfo->updt_task, bbc.updt_applctx = reqinfo->
     updt_applctx
    WHERE bbc.bb_comment_id=bb_comment_id_new
     AND bbc.bb_comment_id > 0.0
     AND bbc.updt_cnt=bb_comment_updt_cnt
    WITH nocounter
   ;end update
   IF (check_for_ccl_error("update blood_bank_comment")=0)
    RETURN(0)
   ELSE
    IF (curqual=0)
     CALL fill_out_status_data("F","update blood_bank_comment",
      "unable to update into blood_bank_comment table")
     RETURN(0)
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    lt.long_text_id
    FROM long_text lt
    WHERE lt.long_text_id=long_text_id_new
     AND lt.long_text_id > 0.0
     AND lt.updt_cnt=long_text_updt_cnt
    WITH nocounter, forupdate(lt)
   ;end select
   IF (check_for_ccl_error("lock lt forupdate")=0)
    RETURN(0)
   ELSE
    IF (curqual=0)
     CALL fill_out_status_data("F","lock lt forupdate","unable to lock long_text table for update")
     RETURN(0)
    ENDIF
   ENDIF
   UPDATE  FROM long_text lt
    SET lt.active_ind = active_ind_new, lt.active_status_cd =
     IF (active_ind_new=1) reqdata->active_status_cd
     ELSE reqdata->inactive_status_cd
     ENDIF
     , lt.active_status_dt_tm = cnvtdatetime(active_status_dt_tm),
     lt.active_status_prsnl_id = active_status_prsnl_id_new, lt.updt_cnt = 0, lt.updt_dt_tm =
     cnvtdatetime(sysdate),
     lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
     updt_applctx
    WHERE lt.long_text_id=long_text_id_new
     AND lt.long_text_id > 0.0
     AND lt.updt_cnt=long_text_updt_cnt
    WITH nocounter
   ;end update
   IF (check_for_ccl_error("update long_text")=0)
    RETURN(0)
   ELSE
    IF (curqual=0)
     CALL fill_out_status_data("F","update long_text","unable to update long_text table")
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (insert_bb_comment(person_id_new=f8,list_index=i2,contributor_system_cd_new=f8,
  active_status_prsnl_id_new=f8,active_status_dt_tm=dq8) =i2)
   DECLARE new_bb_comment_id = f8 WITH noconstant(0.0)
   DECLARE new_long_text_id = f8 WITH noconstant(0.0)
   DECLARE new_comment_text = vc WITH noconstant(" ")
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_bb_comment_id = seqn
    WITH format, nocounter
   ;end select
   IF (check_for_ccl_error("Get pathnet_seq")=0)
    RETURN(0)
   ELSE
    IF (curqual=0)
     CALL fill_out_status_data("F","Get pathnet_seq","Failed getting new pathnet_seq id")
     RETURN(0)
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    seqn = seq(long_data_seq,nextval)
    FROM dual
    DETAIL
     new_long_text_id = seqn
    WITH format, nocounter
   ;end select
   IF (check_for_ccl_error("Get long_data_seq")=0)
    RETURN(0)
   ELSE
    IF (curqual=0)
     CALL fill_out_status_data("F","Get long_data_seq","Failed getting new long_data_seq id")
     RETURN(0)
    ENDIF
   ENDIF
   INSERT  FROM blood_bank_comment bbc
    SET bbc.bb_comment_id = new_bb_comment_id, bbc.person_id = person_id_new, bbc.long_text_id =
     new_long_text_id,
     bbc.active_ind = 1, bbc.active_status_cd = reqdata->active_status_cd, bbc.active_status_dt_tm =
     cnvtdatetime(active_status_dt_tm),
     bbc.active_status_prsnl_id = active_status_prsnl_id_new, bbc.updt_cnt = 0, bbc.updt_dt_tm =
     cnvtdatetime(sysdate),
     bbc.updt_id = reqinfo->updt_id, bbc.updt_task = reqinfo->updt_task, bbc.updt_applctx = reqinfo->
     updt_applctx,
     bbc.contributor_system_cd = contributor_system_cd_new, bbc.comment_dt_tm = cnvtdatetime(
      active_status_dt_tm), bbc.comment_added_prsnl_id = active_status_prsnl_id_new
    WITH nocounter
   ;end insert
   IF (check_for_ccl_error("insert blood_bank_comment")=0)
    RETURN(0)
   ELSE
    IF (curqual=0)
     CALL fill_out_status_data("F","insert blood_bank_comment",
      "unable to insert into blood_bank_comment table")
     RETURN(0)
    ENDIF
   ENDIF
   IF (list_index=0)
    SET new_comment_text = comment->new_comment
   ELSE
    SET new_comment_text = request->qual[list_index].comment
   ENDIF
   INSERT  FROM long_text lt
    SET lt.long_text_id = new_long_text_id, lt.active_ind = 1, lt.long_text = new_comment_text,
     lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm = cnvtdatetime(
      active_status_dt_tm), lt.active_status_prsnl_id = active_status_prsnl_id_new,
     lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(sysdate), lt.updt_id = reqinfo->updt_id,
     lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx, lt
     .parent_entity_name = "BLOOD_BANK_COMMENT",
     lt.parent_entity_id = new_bb_comment_id
    WITH nocounter
   ;end insert
   IF (check_for_ccl_error("add_long_text")=0)
    RETURN(0)
   ELSE
    IF (curqual=0)
     CALL fill_out_status_data("F","add_long_text","unable to add long_text row")
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (get_active_comment(person_id_new=f8) =i2)
   SET active_exists_ind = 0
   SET long_text_id_new = 0.0
   SET blood_bank_comment_id = 0.0
   SET comment->existing_comment = " "
   SET bb_comment_updt_cnt = 0
   SET long_text_updt_cnt = 0
   SELECT INTO "nl:"
    bbc.person_id, lt.long_text_id
    FROM long_text lt,
     blood_bank_comment bbc
    PLAN (bbc
     WHERE bbc.person_id=person_id_new
      AND bbc.bb_comment_id > 0.0
      AND bbc.active_ind=1)
     JOIN (lt
     WHERE lt.long_text_id=bbc.long_text_id
      AND lt.long_text_id > 0.0
      AND lt.active_ind=1)
    DETAIL
     active_exists_ind = 1, comment->existing_comment = lt.long_text, long_text_id_new = lt
     .long_text_id,
     bb_comment_id_new = bbc.bb_comment_id, bb_comment_updt_cnt = bbc.updt_cnt, long_text_updt_cnt =
     lt.updt_cnt
    WITH nocounter
   ;end select
   IF (check_for_ccl_error("Select comment")=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (perform_data_validation(person_id_new=f8,list_index=i2) =i2)
   SELECT INTO "nl:"
    p.person_id
    FROM person p
    WHERE p.person_id=person_id_new
     AND p.person_id > 0.0
    WITH nocounter
   ;end select
   IF (check_for_ccl_error("Select on person")=0)
    RETURN(0)
   ELSE
    IF (curqual=0)
     CALL fill_out_status_data("F","Validate person_id",concat("Person ",trim(cnvtstring(
         person_id_new,32,2))," does not exist on person table"))
     RETURN(0)
    ENDIF
   ENDIF
   IF (size(trim(request->qual[list_index].comment),1)=0)
    CALL fill_out_status_data("F","Validate comment",concat("Comment is blank for person ",cnvtstring
      (person_id_new,32,2)))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (check_for_ccl_error(target_object_name=vc) =i2)
   DECLARE error_msg = c132 WITH private, noconstant(fillstring(132," "))
   DECLARE new_error = c132 WITH private, noconstant(fillstring(132," "))
   DECLARE error_ind = i4 WITH private, noconstant(0)
   SET error_ind = error(new_error,0)
   IF (error_ind != 0)
    WHILE (error_ind != 0)
     SET error_msg = concat(error_msg," ",new_error)
     SET error_ind = error(new_error,0)
    ENDWHILE
    CALL fill_out_status_data("F",target_object_name,error_msg)
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE (fill_out_status_data(status=c1,target_object_name=vc,target_object_value=vc) =null)
   SET reply->status_data.status = status
   SET reply->status_data.subeventstatus[1].operationstatus = status
   SET reply->status_data.subeventstatus[1].operationname = script_name
   SET reply->status_data.subeventstatus[1].targetobjectname = target_object_name
   SET reply->status_data.subeventstatus[1].targetobjectvalue = target_object_value
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status="F"))
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 IF ((request->debug_ind=1))
  CALL echorecord(request)
  CALL echorecord(reply)
 ENDIF
END GO
