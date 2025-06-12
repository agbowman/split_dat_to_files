CREATE PROGRAM dcp_upd_trans_cat_reltn:dba
 DECLARE insertcategory(status=i2,id=f8(ref)) = null
 DECLARE updatecatreltn(new_status=i2,cid=f8(ref),cdr_id=f8(ref),i=i4(ref)) = null
 DECLARE updateeventcdr(new_status=i2,cdr_id=f8(ref)) = null
 DECLARE del = i2 WITH constant(0), public
 DECLARE add = i2 WITH constant(1), public
 DECLARE curr_category_name = c100
 DECLARE curr_dcp_cf_trans_cat_id = f8 WITH noconstant(- (1.00))
 DECLARE curr_cat_active_ind = i2 WITH noconstant(0)
 DECLARE curr_dcp_cf_trans_cat_reltn_id = f8 WITH noconstant(- (1.00))
 DECLARE cat_num = i4 WITH noconstant(0)
 DECLARE status = i2
 DECLARE id1 = f8
 DECLARE id2 = f8
 DECLARE idx = i4 WITH noconstant(0)
 RECORD reply(
   1 active_ind = i2
   1 category_name = vc
   1 transfer_cat_id = f8
   1 transfer_type_cd = f8
   1 relationship[*]
     2 estat = i2
     2 trans_event_cd_r_id = f8
     2 source_event_cd = f8
     2 target_event_cd = f8
     2 association_identifier_cd = f8
     2 transfer_type_cd = f8
   1 status_data
     2 status = c1
 )
 RECORD inactive_event_cd(
   1 qual[*]
     2 trans_event_cd_r_id = f8
 )
 RECORD category(
   1 qual[*]
     2 cat_id = f8
 )
 SET relationship_number = size(request->relationship,5)
 SET stat = alterlist(reply->relationship,relationship_number)
 SET reply->status_data.status = "S"
 SET reply->active_ind = request->active_ind
 SET reply->category_name = request->category_name
 SET reply->transfer_cat_id = request->transfer_cat_id
 SET reply->transfer_type_cd = request->transfer_type_cd
 SELECT
  IF ((request->active_ind=1))
   WHERE (c.cf_category_name=request->category_name)
    AND (c.cf_transfer_type_cd=request->transfer_type_cd)
  ELSE
   WHERE (c.dcp_cf_trans_cat_id=request->transfer_cat_id)
  ENDIF
  INTO "NL:"
  c.active_ind, c.dcp_cf_trans_cat_id
  FROM dcp_cf_trans_cat c
  DETAIL
   curr_dcp_cf_trans_cat_id = c.dcp_cf_trans_cat_id, curr_cat_active_ind = c.active_ind,
   curr_category_name = c.cf_category_name
  WITH nocounter
 ;end select
 IF ((request->active_ind=1))
  SET update_category = false
  IF (curr_dcp_cf_trans_cat_id > 0
   AND (curr_dcp_cf_trans_cat_id != request->transfer_cat_id))
   CALL echo(build("ERROR: cat_id does not exist",request->transfer_cat_id))
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
  IF (curr_dcp_cf_trans_cat_id < 0)
   SET update_category = true
   SELECT INTO "NL:"
    w = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     curr_dcp_cf_trans_cat_id = cnvtreal(w)
    WITH nocounter
   ;end select
   SET status = 1
   SET id1 = curr_dcp_cf_trans_cat_id
   CALL insertcategory(status,id1)
   SET reply->transfer_cat_id = curr_dcp_cf_trans_cat_id
  ELSEIF (curr_cat_active_ind=0)
   SET update_category = true
   UPDATE  FROM dcp_cf_trans_cat c
    SET c.active_ind = 1, c.updt_applctx = reqinfo->updt_applctx, c.updt_id = reqinfo->updt_id,
     c.updt_task = reqinfo->updt_task, c.updt_cnt = (c.updt_cnt+ 1), c.updt_dt_tm = cnvtdatetime(
      curdate,curtime),
     c.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), c.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100")
    WHERE c.dcp_cf_trans_cat_id=curr_dcp_cf_trans_cat_id
     AND c.active_ind=0
    WITH nocounter
   ;end update
  ENDIF
  IF (update_category=true
   AND curqual=0)
   CALL echo(build("ERROR: Fail to ADD category:",request->category_name))
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
 ELSE
  IF (curr_dcp_cf_trans_cat_id > 0
   AND (request->category_name != curr_category_name))
   CALL echo(build("ERROR: does not exist :",request->category_name))
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
  IF (curr_dcp_cf_trans_cat_id > 0
   AND curr_cat_active_ind=1)
   UPDATE  FROM dcp_cf_trans_cat c
    SET c.active_ind = 0, c.updt_applctx = reqinfo->updt_applctx, c.updt_id = reqinfo->updt_id,
     c.updt_task = reqinfo->updt_task, c.updt_cnt = (c.updt_cnt+ 1), c.updt_dt_tm = cnvtdatetime(
      curdate,curtime),
     c.beg_effective_dt_tm = cnvtdatetime("31-DEC-2100"), c.end_effective_dt_tm = cnvtdatetime(
      curdate,curtime)
    WHERE c.dcp_cf_trans_cat_id=curr_dcp_cf_trans_cat_id
     AND (c.cf_category_name=request->category_name)
     AND (c.cf_transfer_type_cd=request->transfer_type_cd)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL echo(build("ERROR: Fail to deactivate a category:",request->category_name))
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
  ELSEIF ((request->transfer_cat_id=0))
   SELECT INTO "NL:"
    w = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     curr_dcp_cf_trans_cat_id = cnvtreal(w)
    WITH nocounter
   ;end select
   SET status = 0
   SET id1 = curr_dcp_cf_trans_cat_id
   CALL insertcategory(status,id1)
   SET reply->transfer_cat_id = curr_dcp_cf_trans_cat_id
  ENDIF
 ENDIF
 FOR (idx = 1 TO relationship_number)
   SET reply->relationship[idx].estat = request->relationship[idx].estat
   SET reply->relationship[idx].association_identifier_cd = request->relationship[idx].
   association_identifier_cd
   SET reply->relationship[idx].target_event_cd = request->relationship[idx].target_event_cd
   SET reply->relationship[idx].source_event_cd = request->relationship[idx].source_event_cd
   SET reply->relationship[idx].transfer_type_cd = request->relationship[idx].transfer_type_cd
   SET reply->relationship[idx].trans_event_cd_r_id = request->relationship[idx].trans_event_cd_r_id
   SET stat = alterlist(inactive_event_cd->qual,5)
   SET inactive_cnt = 0
   SET curr_dcp_cf_trans_event_cd_r_id = - (1)
   SET legal_operation = true
   SET ignore_mapping = false
   IF ((request->relationship[idx].estat=del))
    SET legal_operation = false
   ENDIF
   SELECT
    IF ((request->relationship[idx].estat=add))
     WHERE (r.association_identifier_cd=request->relationship[idx].association_identifier_cd)
      AND (r.cf_transfer_type_cd=request->relationship[idx].transfer_type_cd)
      AND (r.source_event_cd=request->relationship[idx].source_event_cd)
    ELSEIF ((request->relationship[idx].estat=del))
     WHERE (r.association_identifier_cd=request->relationship[idx].association_identifier_cd)
      AND (r.cf_transfer_type_cd=request->relationship[idx].transfer_type_cd)
      AND (r.source_event_cd=request->relationship[idx].source_event_cd)
      AND (r.target_event_cd=request->relationship[idx].target_event_cd)
    ELSE
    ENDIF
    INTO "NL:"
    r.active_ind, r.target_event_cd, r.dcp_cf_trans_event_cd_r_id
    FROM dcp_cf_trans_event_cd_r r
    HEAD REPORT
     row + 0
    DETAIL
     IF ((request->relationship[idx].estat=del))
      curr_dcp_cf_trans_event_cd_r_id = r.dcp_cf_trans_event_cd_r_id
      IF (r.active_ind=1)
       legal_operation = true
      ELSE
       ignore_mapping = true
      ENDIF
      IF ((request->relationship[idx].need_propagate_ind=0))
       ignore_mapping = true
      ENDIF
     ELSEIF ((request->relationship[idx].estat=add))
      IF (curr_dcp_cf_trans_event_cd_r_id < 0
       AND (request->relationship[idx].target_event_cd=r.target_event_cd)
       AND r.active_ind=0)
       curr_dcp_cf_trans_event_cd_r_id = r.dcp_cf_trans_event_cd_r_id
      ELSEIF (curr_dcp_cf_trans_event_cd_r_id < 0
       AND r.active_ind=1
       AND (request->relationship[idx].target_event_cd != r.target_event_cd))
       curr_dcp_cf_trans_event_cd_r_id = r.dcp_cf_trans_event_cd_r_id, legal_operation = false
      ELSEIF (curr_dcp_cf_trans_event_cd_r_id < 0
       AND r.active_ind=1
       AND (request->relationship[idx].target_event_cd=r.target_event_cd))
       ignore_mapping = true, curr_dcp_cf_trans_event_cd_r_id = r.dcp_cf_trans_event_cd_r_id
      ENDIF
      IF ((request->relationship[idx].target_event_cd != r.target_event_cd))
       inactive_cnt = (inactive_cnt+ 1)
       IF (inactive_cnt != 1
        AND mod(inactive_cnt,5)=0)
        stat = alterlist(inactive_event_cd->qual,(inactive_cnt+ 4))
       ENDIF
       inactive_event_cd->qual[inactive_cnt].trans_event_cd_r_id = r.dcp_cf_trans_event_cd_r_id
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(inactive_event_cd->qual,inactive_cnt)
    WITH nocounter
   ;end select
   IF ((request->relationship[idx].estat=del))
    IF (ignore_mapping=false
     AND legal_operation=true
     AND (curr_dcp_cf_trans_event_cd_r_id != request->relationship[idx].trans_event_cd_r_id)
     AND (request->relationship[idx].trans_event_cd_r_id > 0))
     CALL echo(build("Fail to DELETE map, cd_r_id =",request->relationship[idx].trans_event_cd_r_id))
     SET reply->status_data.status = "F"
     GO TO exit_script
    ELSEIF (ignore_mapping=false
     AND legal_operation=true)
     CALL echo(build("DELETE idx =",idx))
     SET status = 0
     SET id1 = curr_dcp_cf_trans_event_cd_r_id
     CALL updateeventcdr(status,id1)
     IF (curqual=0)
      CALL echo(build("Fail to DELETE map, cd_r_id =",curr_dcp_cf_trans_event_cd_r_id))
      SET reply->status_data.status = "F"
      GO TO exit_script
     ENDIF
    ELSEIF (ignore_mapping=false)
     CALL echo(build("IGNORE: DELETE non-exist map, idx=",idx))
    ENDIF
    IF (((legal_operation=true) OR (ignore_mapping=true)) )
     IF ((request->relationship[idx].need_propagate_ind=1))
      UPDATE  FROM dcp_cf_trans_cat_reltn rel
       SET rel.active_ind = 0, rel.updt_applctx = reqinfo->updt_applctx, rel.updt_id = reqinfo->
        updt_id,
        rel.updt_task = reqinfo->updt_task, rel.updt_cnt = (rel.updt_cnt+ 1), rel.updt_dt_tm =
        cnvtdatetime(curdate,curtime),
        rel.beg_effective_dt_tm = cnvtdatetime("31-DEC-2100"), rel.end_effective_dt_tm = cnvtdatetime
        (curdate,curtime), rel.reltn_sequence = request->relationship[idx].reltn_sequence
       WHERE rel.dcp_cf_trans_event_cd_r_id=curr_dcp_cf_trans_event_cd_r_id
        AND rel.active_ind=1
      ;end update
     ELSE
      SET status = 0
      SET id1 = curr_dcp_cf_trans_cat_id
      SET id2 = curr_dcp_cf_trans_event_cd_r_id
      CALL updatecatreltn(status,id1,id2,idx)
     ENDIF
    ENDIF
   ELSEIF ((request->relationship[idx].estat=add))
    IF ((request->relationship[idx].source_event_cd=request->relationship[idx].target_event_cd))
     SET reply->status_data.status = "F"
     GO TO exit_script
    ENDIF
    IF (ignore_mapping=false
     AND legal_operation=true
     AND curr_dcp_cf_trans_event_cd_r_id >= 0)
     CALL echo(build("ATIVATE an inactive map, idx =",idx))
     SET status = 1
     SET id1 = curr_dcp_cf_trans_event_cd_r_id
     CALL updateeventcdr(status,id1)
     SET reply->relationship[idx].trans_event_cd_r_id = curr_dcp_cf_trans_event_cd_r_id
    ELSEIF (ignore_mapping=false
     AND legal_operation=true)
     CALL echo(build("INSERT new map, idx =",idx))
     SELECT INTO "NL:"
      w = seq(carenet_seq,nextval)
      FROM dual
      DETAIL
       curr_dcp_cf_trans_event_cd_r_id = cnvtreal(w)
      WITH nocounter
     ;end select
     INSERT  FROM dcp_cf_trans_event_cd_r r
      SET r.active_ind = 1, r.association_identifier_cd = request->relationship[idx].
       association_identifier_cd, r.source_event_cd = request->relationship[idx].source_event_cd,
       r.target_event_cd = request->relationship[idx].target_event_cd, r.dcp_cf_trans_event_cd_r_id
        = curr_dcp_cf_trans_event_cd_r_id, r.cf_transfer_type_cd = request->relationship[idx].
       transfer_type_cd,
       r.updt_applctx = reqinfo->updt_applctx, r.updt_id = reqinfo->updt_id, r.updt_task = reqinfo->
       updt_task,
       r.updt_cnt = 0, r.updt_dt_tm = cnvtdatetime(curdate,curtime), r.beg_effective_dt_tm =
       cnvtdatetime(curdate,curtime),
       r.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
      WITH nocounter
     ;end insert
     SET reply->relationship[idx].trans_event_cd_r_id = curr_dcp_cf_trans_event_cd_r_id
    ELSEIF (ignore_mapping=true)
     SET reply->relationship[idx].trans_event_cd_r_id = curr_dcp_cf_trans_event_cd_r_id
    ENDIF
    IF (ignore_mapping=false
     AND curqual=0)
     CALL echo(build("Fail to ADD a map, idx =",idx))
     SET reply->status_data.status = "F"
     GO TO exit_script
    ENDIF
    CALL echo("Process dcp_cf_trans_cat_reltn table")
    SELECT
     IF ((request->relationship[idx].need_propagate_ind=0))
      WHERE (c.dcp_cf_trans_cat_id=reply->transfer_cat_id)
     ELSE
     ENDIF
     INTO "NL:"
     c.dcp_cf_trans_cat_id
     FROM dcp_cf_trans_cat c
     HEAD REPORT
      cat_num = 0
     DETAIL
      cat_num = (cat_num+ 1)
      IF (mod(cat_num,5)=1)
       stat = alterlist(category->qual,(cat_num+ 4))
      ENDIF
      category->qual[cat_num].cat_id = c.dcp_cf_trans_cat_id
     FOOT REPORT
      stat = alterlist(category->qual,cat_num)
     WITH nocounter
    ;end select
    SET cat_num = size(category->qual,5)
    SET cdr_num = size(inactive_event_cd->qual,5)
    SET status = 0
    FOR (cat_idx = 1 TO cat_num)
     SET id1 = category->qual[cat_idx].cat_id
     FOR (cdr_idx = 1 TO cdr_num)
      SET id2 = inactive_event_cd->qual[cdr_idx].trans_event_cd_r_id
      CALL updatecatreltn(status,id1,id2,idx)
     ENDFOR
    ENDFOR
    CALL echo(build("*** cat_num=",cat_num))
    FOR (j = 1 TO cat_num)
      SET curr_rel_active_ind = - (1)
      SELECT INTO "NL:"
       rel.active_ind, rel.dcp_cf_trans_cat_reltn_id
       FROM dcp_cf_trans_cat_reltn rel
       WHERE (rel.dcp_cf_trans_cat_id=category->qual[j].cat_id)
        AND rel.dcp_cf_trans_event_cd_r_id=curr_dcp_cf_trans_event_cd_r_id
       DETAIL
        curr_rel_active_ind = rel.active_ind
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET curr_dcp_cf_trans_cat_reltn_id = - (1)
       SELECT INTO "NL:"
        w = seq(carenet_seq,nextval)
        FROM dual
        DETAIL
         curr_dcp_cf_trans_cat_reltn_id = cnvtreal(w)
        WITH nocounter
       ;end select
       INSERT  FROM dcp_cf_trans_cat_reltn rel
        SET rel.active_ind = 1, rel.dcp_cf_trans_event_cd_r_id = curr_dcp_cf_trans_event_cd_r_id, rel
         .dcp_cf_trans_cat_id = category->qual[j].cat_id,
         rel.dcp_cf_trans_cat_reltn_id = curr_dcp_cf_trans_cat_reltn_id, rel.updt_applctx = reqinfo->
         updt_applctx, rel.updt_id = reqinfo->updt_id,
         rel.updt_task = reqinfo->updt_task, rel.updt_cnt = 0, rel.updt_dt_tm = cnvtdatetime(curdate,
          curtime),
         rel.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), rel.end_effective_dt_tm =
         cnvtdatetime("31-DEC-2100"), rel.reltn_sequence = request->relationship[idx].reltn_sequence
        WITH nocounter
       ;end insert
      ELSEIF (curr_rel_active_ind=0)
       SET status = 1
       SET id1 = category->qual[j].cat_id
       SET id2 = curr_dcp_cf_trans_event_cd_r_id
       CALL updatecatreltn(status,id1,id2,idx)
      ENDIF
      IF (curqual=0
       AND curr_rel_active_ind >= 0)
       CALL echo(build("Fail to ADD a relationship, cat_id =",category->qual[j].cat_id,
         ", event_cd_r_id=",curr_dcp_cf_trans_event_cd_r_id))
       SET reply->status_data.status = "F"
       GO TO exit_script
      ENDIF
    ENDFOR
   ENDIF
   UPDATE  FROM dcp_cf_trans_cat_reltn rel
    SET rel.reltn_sequence = request->relationship[idx].reltn_sequence
    WHERE rel.dcp_cf_trans_cat_id=curr_dcp_cf_trans_cat_id
     AND rel.dcp_cf_trans_event_cd_r_id=curr_dcp_cf_trans_event_cd_r_id
    WITH nocounter
   ;end update
 ENDFOR
#exit_script
 IF (relationship_number=0)
  SET reply->status_data.status = "Z"
 ENDIF
 IF ((reply->status_data.status != "F"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(request)
 CALL echorecord(reply)
 SUBROUTINE insertcategory(status,id)
   INSERT  FROM dcp_cf_trans_cat c
    SET c.active_ind = status, c.dcp_cf_trans_cat_id = id, c.cf_category_name = request->
     category_name,
     c.cf_transfer_type_cd = request->transfer_type_cd, c.updt_applctx = reqinfo->updt_applctx, c
     .updt_id = reqinfo->updt_id,
     c.updt_task = reqinfo->updt_task, c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime),
     c.beg_effective_dt_tm =
     IF (status=0) cnvtdatetime("31-DEC-2100")
     ELSE cnvtdatetime(curdate,curtime)
     ENDIF
     , c.end_effective_dt_tm =
     IF (status=0) cnvtdatetime(curdate,curtime)
     ELSE cnvtdatetime("31-DEC-2100")
     ENDIF
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE updatecatreltn(new_status,cid,cdr_id,i)
   UPDATE  FROM dcp_cf_trans_cat_reltn rel
    SET rel.active_ind = new_status, rel.updt_applctx = reqinfo->updt_applctx, rel.updt_id = reqinfo
     ->updt_id,
     rel.updt_task = reqinfo->updt_task, rel.updt_cnt = (rel.updt_cnt+ 1), rel.updt_dt_tm =
     cnvtdatetime(curdate,curtime),
     rel.beg_effective_dt_tm =
     IF (new_status=0) cnvtdatetime("31-DEC-2100")
     ELSE cnvtdatetime(curdate,curtime)
     ENDIF
     , rel.end_effective_dt_tm =
     IF (new_status=0) cnvtdatetime(curdate,curtime)
     ELSE cnvtdatetime("31-DEC-2100")
     ENDIF
     , rel.reltn_sequence = request->relationship[i].reltn_sequence
    WHERE rel.dcp_cf_trans_cat_id=cid
     AND rel.dcp_cf_trans_event_cd_r_id=curr_dcp_cf_trans_event_cd_r_id
     AND (rel.active_ind=(1 - new_status))
    WITH nocounter
   ;end update
 END ;Subroutine
 SUBROUTINE updateeventcdr(new_status,cdr_id)
   UPDATE  FROM dcp_cf_trans_event_cd_r r
    SET r.active_ind = new_status, r.updt_applctx = reqinfo->updt_applctx, r.updt_id = reqinfo->
     updt_id,
     r.updt_task = reqinfo->updt_task, r.updt_cnt = (r.updt_cnt+ 1), r.updt_dt_tm = cnvtdatetime(
      curdate,curtime),
     r.beg_effective_dt_tm =
     IF (new_status=1) cnvtdatetime(curdate,curtime)
     ELSE cnvtdatetime("31-DEC-2100")
     ENDIF
     , r.end_effective_dt_tm =
     IF (new_status=1) cnvtdatetime("31-DEC-2100")
     ELSE cnvtdatetime(curdate,curtime)
     ENDIF
    WHERE r.dcp_cf_trans_event_cd_r_id=cdr_id
    WITH nocounter
   ;end update
 END ;Subroutine
END GO
