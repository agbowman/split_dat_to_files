CREATE PROGRAM aps_chg_proxy_privileges:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 qual[*]
     2 privilege_id = f8
 )
 RECORD temp_add(
   1 qual[*]
     2 privilege_id = f8
     2 privilege_cd = f8
 )
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 )
 SET reply->status_data.status = "F"
 DECLARE max_to_add = i4
 DECLARE max_to_del = i4
 DECLARE max_to_updt = i4
 DECLARE max_add_qual = i4
 DECLARE max_del_qual = i4
 DECLARE max_updt_qual = i4
 DECLARE nneedidcount = i4
 DECLARE nneedidcount2 = i4
 DECLARE naddparent = i4
 SET x = 0
 SET qual_size = 0
 SET naddparent = 0
 SET max_to_add = 0
 SET max_to_del = 0
 SET max_to_updt = 0
 SET max_add_qual = 0
 SET max_del_qual = 0
 SET max_updt_qual = 0
 SET qual_size = cnvtint(size(request->qual,5))
 CALL echo(build("request->qual = ",qual_size))
 FOR (x = 1 TO qual_size)
   IF (size(request->qual[x].add_qual,5) > max_add_qual)
    SET max_add_qual = size(request->qual[x].add_qual,5)
   ENDIF
   IF (size(request->qual[x].del_qual,5) > max_to_del)
    SET max_del_qual = size(request->qual[x].del_qual,5)
   ENDIF
   IF (size(request->qual[x].updt_qual,5) > max_updt_qual)
    SET max_updt_qual = size(request->qual[x].updt_qual,5)
   ENDIF
   SET max_to_add = (max_to_add+ size(request->qual[x].add_qual,5))
   SET max_to_del = (max_to_del+ size(request->qual[x].del_qual,5))
   SET max_to_updt = (max_to_updt+ size(request->qual[x].updt_qual,5))
 ENDFOR
 CALL echo(build("max to add = ",max_to_add))
 CALL echo(build("max to del = ",max_to_del))
 CALL echo(build("max add qual = ",max_add_qual))
 CALL echo(build("max del qual = ",max_del_qual))
 IF (max_to_add > 0)
  SET nneedidcount = value(size(temp_add->qual,5))
  FOR (x = 1 TO qual_size)
    IF ((request->qual[x].privilege_id=0.00))
     SET naddparent = 1
     SET nneedidcount = (nneedidcount+ 1)
     SET stat = alterlist(temp_add->qual,nneedidcount)
     SET temp_add->qual[nneedidcount].privilege_cd = request->qual[x].privilege_cd
    ENDIF
  ENDFOR
  IF (naddparent=1)
   EXECUTE dm2_dar_get_bulk_seq "temp_add->qual", nneedidcount, "privilege_id",
   1, "reference_seq"
   IF ((m_dm2_seq_stat->n_status=0))
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "SEQ"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "REFERENCE_SEQ"
    GO TO exit_script
   ENDIF
   SET nneedidcount2 = 0
   FOR (x = 1 TO qual_size)
     IF ((request->qual[x].privilege_id=0.00))
      SET nneedidcount2 = (nneedidcount2+ 1)
      SET request->qual[x].privilege_id = temp_add->qual[nneedidcount2].privilege_id
     ENDIF
   ENDFOR
   CALL echo("adding parent")
   INSERT  FROM ap_prsnl_priv app,
     (dummyt d1  WITH seq = value(size(temp_add->qual,5)))
    SET app.privilege_id = temp_add->qual[d1.seq].privilege_id, app.prsnl_id = request->prsnl_id, app
     .privilege_cd = temp_add->qual[d1.seq].privilege_cd,
     app.updt_dt_tm = cnvtdatetime(curdate,curtime3), app.updt_id = reqinfo->updt_id, app.updt_task
      = reqinfo->updt_task,
     app.updt_cnt = 0, app.updt_applctx = reqinfo->updt_applctx
    PLAN (d1
     WHERE (temp_add->qual[d1.seq].privilege_id > 0))
     JOIN (app)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_PRSNL_PRIV"
    GO TO exit_script
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
   CALL echo(build("ParentAdd->status_data.status:",reply->status_data.status))
  ENDIF
  CALL echo("adding child")
  INSERT  FROM ap_prsnl_priv_r appr,
    (dummyt d1  WITH seq = value(size(request->qual,5))),
    (dummyt d2  WITH seq = value(max_add_qual))
   SET appr.privilege_id = request->qual[d1.seq].privilege_id, appr.parent_entity_name = request->
    qual[d1.seq].add_qual[d2.seq].parent_entity_name, appr.parent_entity_id = request->qual[d1.seq].
    add_qual[d2.seq].parent_entity_id,
    appr.proxy_beg_dt_tm =
    IF ((request->qual[d1.seq].add_qual[d2.seq].proxy_beg_dt_tm=null)) cnvtdatetime(curdate,curtime3)
    ELSE cnvtdatetime(request->qual[d1.seq].add_qual[d2.seq].proxy_beg_dt_tm)
    ENDIF
    , appr.proxy_end_dt_tm =
    IF ((request->qual[d1.seq].add_qual[d2.seq].proxy_end_dt_tm=null)) cnvtdatetime(
      "31-DEC-2100 00:00:00.00")
    ELSE cnvtdatetime(request->qual[d1.seq].add_qual[d2.seq].proxy_end_dt_tm)
    ENDIF
    , appr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    appr.updt_id = reqinfo->updt_id, appr.updt_task = reqinfo->updt_task, appr.updt_cnt = 0,
    appr.updt_applctx = reqinfo->updt_applctx
   PLAN (d1)
    JOIN (d2
    WHERE d2.seq <= size(request->qual[d1.seq].add_qual,5))
    JOIN (appr)
   WITH nocounter
  ;end insert
  CALL echo(build("curqual = ",curqual))
  CALL echo(build("max to add =",max_to_add))
  IF (curqual != max_to_add)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_PRSNL_PRIV_R"
   GO TO exit_script
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
  CALL echo(build("ParentChild->status_data.status:",reply->status_data.status))
 ENDIF
 IF (max_to_updt > 0)
  UPDATE  FROM ap_prsnl_priv_r appr,
    (dummyt d1  WITH seq = value(size(request->qual,5))),
    (dummyt d2  WITH seq = value(max_updt_qual))
   SET appr.proxy_beg_dt_tm =
    IF ((request->qual[d1.seq].updt_qual[d2.seq].proxy_beg_dt_tm=null)) cnvtdatetime(curdate,curtime3
      )
    ELSE cnvtdatetime(request->qual[d1.seq].updt_qual[d2.seq].proxy_beg_dt_tm)
    ENDIF
    , appr.proxy_end_dt_tm =
    IF ((request->qual[d1.seq].updt_qual[d2.seq].proxy_end_dt_tm=null)) cnvtdatetime(
      "31-DEC-2100 00:00:00.00")
    ELSE cnvtdatetime(request->qual[d1.seq].updt_qual[d2.seq].proxy_end_dt_tm)
    ENDIF
    , appr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    appr.updt_id = reqinfo->updt_id, appr.updt_task = reqinfo->updt_task, appr.updt_cnt = (appr
    .updt_cnt+ 1),
    appr.updt_applctx = reqinfo->updt_applctx
   PLAN (d1)
    JOIN (d2
    WHERE d2.seq <= size(request->qual[d1.seq].updt_qual,5))
    JOIN (appr
    WHERE (appr.privilege_id=request->qual[d1.seq].privilege_id)
     AND (appr.parent_entity_name=request->qual[d1.seq].updt_qual[d2.seq].parent_entity_name)
     AND (appr.parent_entity_id=request->qual[d1.seq].updt_qual[d2.seq].parent_entity_id))
   WITH nocounter
  ;end update
  IF (curqual != max_to_updt)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_PRSNL_PRIV_R"
   GO TO exit_script
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 IF (max_to_del > 0)
  CALL echo("deleting child")
  DELETE  FROM ap_prsnl_priv_r appr,
    (dummyt d1  WITH seq = value(size(request->qual,5))),
    (dummyt d2  WITH seq = value(max_del_qual))
   SET appr.seq = 1
   PLAN (d1)
    JOIN (d2
    WHERE d2.seq <= size(request->qual[d1.seq].del_qual,5))
    JOIN (appr
    WHERE (appr.privilege_id=request->qual[d1.seq].privilege_id)
     AND (appr.parent_entity_id=request->qual[d1.seq].del_qual[d2.seq].parent_entity_id)
     AND (appr.parent_entity_name=request->qual[d1.seq].del_qual[d2.seq].parent_entity_name))
   WITH nocounter
  ;end delete
  CALL echo(build("curqual = ",curqual))
  CALL echo(build("max to del =",max_to_del))
  IF (curqual != max_to_del)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_PRSNL_PRIV_R"
   GO TO exit_script
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
  CALL echo(build("DeleteChild->status_data.status:",reply->status_data.status))
  SELECT INTO "nl:"
   FROM ap_prsnl_priv app,
    ap_prsnl_priv_r appr,
    (dummyt d1  WITH seq = value(size(request->qual,5))),
    dummyt d2
   PLAN (d1)
    JOIN (app
    WHERE (app.privilege_id=request->qual[d1.seq].privilege_id))
    JOIN (d2)
    JOIN (appr
    WHERE appr.privilege_id=app.privilege_id)
   HEAD REPORT
    nneedidcount = 0
   DETAIL
    nneedidcount = (nneedidcount+ 1)
    IF (mod(nneedidcount,10)=1)
     stat = alterlist(temp->qual,(nneedidcount+ 9))
    ENDIF
    temp->qual[nneedidcount].privilege_id = app.privilege_id,
    CALL echo(build("ID to delete",temp->qual[nneedidcount].privilege_id))
   FOOT REPORT
    stat = alterlist(temp->qual,nneedidcount)
   WITH nocounter, outerjoin = d2, dontexist
  ;end select
  SET tempqual = curqual
  IF (tempqual > 0)
   CALL echo(build("temp->qual:",value(size(temp->qual,5))))
   DELETE  FROM ap_prsnl_priv app,
     (dummyt d1  WITH seq = value(size(temp->qual,5)))
    SET app.seq = 1
    PLAN (d1)
     JOIN (app
     WHERE (app.privilege_id=temp->qual[d1.seq].privilege_id))
    WITH nocounter
   ;end delete
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_PRSNL_PRIV"
    GO TO exit_script
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
   CALL echo(build("DeleteParent->status_data.status:",reply->status_data.status))
  ENDIF
 ENDIF
#exit_script
 IF ((reply->status_data.status="S"))
  CALL echo("commit")
  SET reqinfo->commit_ind = 1
 ELSE
  CALL echo("rollback")
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
