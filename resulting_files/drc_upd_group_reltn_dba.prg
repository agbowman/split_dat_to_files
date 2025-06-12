CREATE PROGRAM drc_upd_group_reltn:dba
 FREE SET reply
 RECORD reply(
   1 error_string = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE number_of_reltns = i4 WITH public, noconstant(0)
 DECLARE product_id = f8 WITH public, noconstant(0.0)
 DECLARE synonym_id = f8 WITH public, noconstant(0.0)
 DECLARE v_ver_seq = i4 WITH public, noconstant(0)
 DECLARE drc_group_reltn_id = f8 WITH public, noconstant(0.0)
 SET reply->status_data.status = "F"
 SET number_of_reltns = size(request->group_reltns,5)
 SET errmsg = fillstring(132," ")
 FOR (x = 1 TO number_of_reltns)
   CASE (request->group_reltns[x].action_ind)
    OF 0:
     EXECUTE FROM update_beg TO update_end
    OF 1:
     EXECUTE FROM insert_beg TO insert_end
    ELSE
     SET failed = "T"
     SET reply->error_string = "Don't recognize the action_ind"
     GO TO exit_script
   ENDCASE
 ENDFOR
 GO TO exit_script
#update_beg
 IF ((request->group_reltns[x].type_ind=0))
  CALL echo(build("Removing product: ",request->group_reltns[x].item_id," from group_id:",request->
    group_reltns[x].old_group_id))
  UPDATE  FROM drc_group_reltn dgr
   SET dgr.formulation_id = 0.0, dgr.active_ind = dgr.active_ind, dgr.updt_dt_tm = cnvtdatetime(
     curdate,curtime3),
    dgr.updt_cnt = (dgr.updt_cnt+ 1), dgr.updt_id = reqinfo->updt_id, dgr.updt_task = reqinfo->
    updt_task,
    dgr.updt_applctx = reqinfo->updt_applctx
   WHERE (dgr.drc_group_id=request->group_reltns[x].old_group_id)
    AND (dgr.formulation_id=request->group_reltns[x].item_id)
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->error_string = "Could not remove product from drc_group_reltn table"
   SET reply->status_data.subeventstatus[1].operationname = "update"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   GO TO exit_script
  ENDIF
  IF ((request->group_reltns[x].drc_group_reltn_id > 0.0))
   SET v_ver_seq = 0
   SELECT INTO "nl:"
    temp_seq = max(dgrv.ver_seq)
    FROM drc_group_reltn_ver dgrv
    WHERE (dgrv.drc_group_reltn_id=request->group_reltns[x].drc_group_reltn_id)
    DETAIL
     v_ver_seq = (temp_seq+ 1)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    dgrv.drug_synonym_id
    FROM drc_group_reltn_ver dgrv
    WHERE (dgrv.drc_group_reltn_id=request->group_reltns[x].drc_group_reltn_id)
     AND (dgrv.ver_seq=(v_ver_seq - 1))
    DETAIL
     synonym_id = dgrv.drug_synonym_id
    WITH nocounter
   ;end select
   CALL echo(build("Inserting row for product into drc_group_reltn_ver:",request->group_reltns[x].
     drc_group_reltn_id))
   CALL echo(build("Version number:",v_ver_seq))
   INSERT  FROM drc_group_reltn_ver dgrv
    SET dgrv.drc_group_reltn_id = request->group_reltns[x].drc_group_reltn_id, dgrv.ver_seq =
     v_ver_seq, dgrv.formulation_id = 0.0,
     dgrv.drug_synonym_id = synonym_id, dgrv.drc_group_id = request->group_reltns[x].old_group_id,
     dgrv.active_ind = 1,
     dgrv.updt_dt_tm = cnvtdatetime(curdate,curtime3), dgrv.updt_id = reqinfo->updt_id, dgrv
     .updt_task = reqinfo->updt_task,
     dgrv.updt_applctx = reqinfo->updt_applctx, dgrv.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    SET reply->error_string = "Could not update product into drc_group_reltn_ver table"
    SET reply->status_data.subeventstatus[1].operationname = "update"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    GO TO exit_script
   ENDIF
  ENDIF
 ELSEIF ((request->group_reltns[x].type_ind=1))
  CALL echo(build("Removing synonym: ",request->group_reltns[x].item_id," from group_id:",request->
    group_reltns[x].old_group_id))
  UPDATE  FROM drc_group_reltn dgr
   SET dgr.drug_synonym_id = 0.0, dgr.active_ind = dgr.active_ind, dgr.updt_dt_tm = cnvtdatetime(
     curdate,curtime3),
    dgr.updt_cnt = (dgr.updt_cnt+ 1), dgr.updt_id = reqinfo->updt_id, dgr.updt_task = reqinfo->
    updt_task,
    dgr.updt_applctx = reqinfo->updt_applctx
   WHERE (dgr.drc_group_id=request->group_reltns[x].old_group_id)
    AND (dgr.drug_synonym_id=request->group_reltns[x].item_id)
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->error_string = "Could not remove synonym from drc_group_reltn table"
   SET reply->status_data.subeventstatus[1].operationname = "update"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   GO TO exit_script
  ENDIF
  IF ((request->group_reltns[x].drc_group_reltn_id > 0.0))
   SET v_ver_seq = 0
   SELECT INTO "nl:"
    temp_seq = max(dgrv.ver_seq)
    FROM drc_group_reltn_ver dgrv
    WHERE (dgrv.drc_group_reltn_id=request->group_reltns[x].drc_group_reltn_id)
    DETAIL
     v_ver_seq = (temp_seq+ 1)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    dgrv.formulation_id
    FROM drc_group_reltn_ver dgrv
    WHERE (dgrv.drc_group_reltn_id=request->group_reltns[x].drc_group_reltn_id)
     AND (dgrv.ver_seq=(v_ver_seq - 1))
    DETAIL
     product_id = dgrv.formulation_id
    WITH nocounter
   ;end select
   CALL echo(build("Inserting row for synonym into drc_group_reltn_ver:",request->group_reltns[x].
     drc_group_reltn_id))
   CALL echo(build("Version number:",v_ver_seq))
   INSERT  FROM drc_group_reltn_ver dgrv
    SET dgrv.drc_group_reltn_id = request->group_reltns[x].drc_group_reltn_id, dgrv.ver_seq =
     v_ver_seq, dgrv.formulation_id = product_id,
     dgrv.drug_synonym_id = 0.0, dgrv.drc_group_id = request->group_reltns[x].old_group_id, dgrv
     .active_ind = 1,
     dgrv.updt_dt_tm = cnvtdatetime(curdate,curtime3), dgrv.updt_id = reqinfo->updt_id, dgrv
     .updt_task = reqinfo->updt_task,
     dgrv.updt_applctx = reqinfo->updt_applctx, dgrv.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    SET reply->error_string = "Could not update synonym into drc_group_reltn_ver table"
    SET reply->status_data.subeventstatus[1].operationname = "update"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    GO TO exit_script
   ENDIF
  ENDIF
 ELSE
  SET failed = "T"
  SET reply->error_string = "Don't recognize type_ind for remove"
  GO TO exit_script
 ENDIF
 IF ((request->group_reltns[x].active_ind > 0))
  EXECUTE FROM insert_beg TO insert_end
 ENDIF
#update_end
#insert_beg
 IF ((request->group_reltns[x].type_ind=0))
  SELECT INTO "nl:"
   nextseqnum = seq(drc_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    drc_group_reltn_id = cnvtint(nextseqnum)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->error_string = "Could not find nextseqnum for product add"
   GO TO exit_script
  ENDIF
  CALL echo(build("Inserting product into drc_group_reltn:",drc_group_reltn_id))
  INSERT  FROM drc_group_reltn dgr
   SET dgr.drc_group_reltn_id = drc_group_reltn_id, dgr.formulation_id = request->group_reltns[x].
    item_id, dgr.drug_synonym_id = 0.0,
    dgr.drc_group_id = request->group_reltns[x].new_group_id, dgr.active_ind = 1, dgr.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    dgr.updt_id = reqinfo->updt_id, dgr.updt_task = reqinfo->updt_task, dgr.updt_applctx = reqinfo->
    updt_applctx,
    dgr.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->error_string = "Could not insert product into drc_group_reltn table"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   GO TO exit_script
  ENDIF
  CALL echo(build("Inserting product into drc_group_reltn_ver:",drc_group_reltn_id))
  INSERT  FROM drc_group_reltn_ver dgrv
   SET dgrv.drc_group_reltn_id = drc_group_reltn_id, dgrv.ver_seq = 1, dgrv.formulation_id = request
    ->group_reltns[x].item_id,
    dgrv.drug_synonym_id = 0.0, dgrv.drc_group_id = request->group_reltns[x].new_group_id, dgrv
    .active_ind = 1,
    dgrv.updt_dt_tm = cnvtdatetime(curdate,curtime3), dgrv.updt_id = reqinfo->updt_id, dgrv.updt_task
     = reqinfo->updt_task,
    dgrv.updt_applctx = reqinfo->updt_applctx, dgrv.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->error_string = "Could not insert product into drc_group_reltn_ver table"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   GO TO exit_script
  ENDIF
 ELSEIF ((request->group_reltns[x].type_ind=1))
  SELECT INTO "nl:"
   nextseqnum = seq(drc_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    drc_group_reltn_id = cnvtint(nextseqnum)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->error_string = "Could not find nextseqnum for synonym add"
   GO TO exit_script
  ENDIF
  CALL echo(build("Inserting synonym into drc_group_reltn:",drc_group_reltn_id))
  INSERT  FROM drc_group_reltn dgr
   SET dgr.drc_group_reltn_id = drc_group_reltn_id, dgr.formulation_id = 0.0, dgr.drug_synonym_id =
    request->group_reltns[x].item_id,
    dgr.drc_group_id = request->group_reltns[x].new_group_id, dgr.active_ind = 1, dgr.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    dgr.updt_id = reqinfo->updt_id, dgr.updt_task = reqinfo->updt_task, dgr.updt_applctx = reqinfo->
    updt_applctx,
    dgr.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->error_string = "Could not insert synonym into drc_group_reltn table"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   GO TO exit_script
  ENDIF
  CALL echo(build("Inserting synonym into drc_group_reltn_ver:",drc_group_reltn_id))
  INSERT  FROM drc_group_reltn_ver dgrv
   SET dgrv.drc_group_reltn_id = drc_group_reltn_id, dgrv.ver_seq = 1, dgrv.formulation_id = 0.0,
    dgrv.drug_synonym_id = request->group_reltns[x].item_id, dgrv.drc_group_id = request->
    group_reltns[x].new_group_id, dgrv.active_ind = 1,
    dgrv.updt_dt_tm = cnvtdatetime(curdate,curtime3), dgrv.updt_id = reqinfo->updt_id, dgrv.updt_task
     = reqinfo->updt_task,
    dgrv.updt_applctx = reqinfo->updt_applctx, dgrv.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->error_string = "Could not insert synonym into drc_group_reltn_ver table"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   GO TO exit_script
  ENDIF
 ELSE
  SET failed = "T"
  SET reply->error_string = "Don't recognize type_ind for insert"
  GO TO exit_script
 ENDIF
#insert_end
#exit_script
 SET errorcode = error(errmsg,0)
 IF (errorcode != 0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "ErrorMessage"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
 ENDIF
 IF (failed="T")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
