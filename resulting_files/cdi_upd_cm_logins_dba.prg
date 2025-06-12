CREATE PROGRAM cdi_upd_cm_logins:dba
 RECORD reply(
   1 logins[*]
     2 cdi_cm_login_id = f8
     2 username = vc
     2 password = vc
     2 organization_id = f8
     2 org_default_ind = i2
     2 updt_cnt = i4
     2 positions[*]
       3 cdi_cm_login_position_id = f8
       3 position_cd = f8
       3 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD tempfields(
   1 update_logins[*]
     2 cdi_cm_login_id = f8
     2 cm_password = vc
     2 cm_username = vc
     2 organization_id = f8
     2 org_default_ind = i2
     2 updt_cnt = i4
   1 update_positions[*]
     2 cdi_cm_login_position_id = f8
     2 cdi_cm_login_id = f8
     2 position_cd = f8
     2 updt_cnt = i4
   1 insert_logins[*]
     2 cdi_cm_login_id = f8
     2 cm_password = vc
     2 cm_username = vc
     2 organization_id = f8
     2 org_default_ind = i2
     2 positions[*]
       3 position_cd = f8
   1 insert_positions[*]
     2 cdi_cm_login_position_id = f8
     2 cdi_cm_login_id = f8
     2 position_cd = f8
   1 delete_logins[*]
     2 cdi_cm_login_id = f8
   1 delete_positions[*]
     2 cdi_cm_login_id = f8
   1 delete_positions2[*]
     2 cdi_cm_login_position_id = f8
 )
 DECLARE login_rows = i4 WITH noconstant(value(size(request->logins,5))), protect
 DECLARE login_cnt = i4 WITH noconstant(0), public
 DECLARE position_rows = i4 WITH noconstant(0), protect
 DECLARE position_cnt = i4 WITH noconstant(0), public
 DECLARE upd_login_cnt = i4 WITH noconstant(0), protect
 DECLARE upd_position_cnt = i4 WITH noconstant(0), protect
 DECLARE ins_login_cnt = i4 WITH noconstant(0), protect
 DECLARE ins_position_cnt = i4 WITH noconstant(0), protect
 DECLARE del_login_cnt = i4 WITH noconstant(0), protect
 DECLARE del_position_cnt = i4 WITH noconstant(0), protect
 DECLARE reply_ctr = i4 WITH noconstant(0), protect
 DECLARE reply_pos_ctr = i4 WITH noconstant(0), protect
 DECLARE num = i4 WITH noconstant(0), protect
 DECLARE del_position2_cnt = i4 WITH noconstant(0), protect
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 ) WITH protect
 SET reply->status_data.subeventstatus[1].operationstatus = "S"
 SET stat = alterlist(tempfields->update_logins,login_rows)
 SET stat = alterlist(tempfields->insert_logins,login_rows)
 SET stat = alterlist(tempfields->delete_logins,login_rows)
 FOR (login_cnt = 1 TO login_rows)
  SET position_rows = value(size(request->logins[login_cnt].positions,5))
  IF ((request->logins[login_cnt].cdi_cm_login_id > 0.0))
   IF ((request->logins[login_cnt].deleted_ind=1))
    SET del_login_cnt = (del_login_cnt+ 1)
    SET tempfields->delete_logins[del_login_cnt].cdi_cm_login_id = request->logins[login_cnt].
    cdi_cm_login_id
   ELSE
    SET upd_login_cnt = (upd_login_cnt+ 1)
    SET tempfields->update_logins[upd_login_cnt].cdi_cm_login_id = request->logins[login_cnt].
    cdi_cm_login_id
    SET tempfields->update_logins[upd_login_cnt].cm_password = request->logins[login_cnt].password
    SET tempfields->update_logins[upd_login_cnt].cm_username = request->logins[login_cnt].username
    SET tempfields->update_logins[upd_login_cnt].organization_id = request->logins[login_cnt].
    organization_id
    SET tempfields->update_logins[upd_login_cnt].org_default_ind = request->logins[login_cnt].
    org_default_ind
    SET tempfields->update_logins[upd_login_cnt].updt_cnt = request->logins[login_cnt].updt_cnt
    IF (position_rows > 0)
     SET stat = alterlist(tempfields->delete_positions2,(del_position2_cnt+ position_rows))
     SET stat = alterlist(tempfields->update_positions,(upd_position_cnt+ position_rows))
     SET stat = alterlist(tempfields->insert_positions,(ins_position_cnt+ position_rows))
    ELSE
     SET stat = alterlist(tempfields->delete_positions,(del_position_cnt+ 1))
    ENDIF
    FOR (position_cnt = 1 TO position_rows)
      IF ((request->logins[login_cnt].positions[position_cnt].cdi_cm_login_position_id > 0.0))
       IF ((request->logins[login_cnt].positions[position_cnt].deleted_ind=1))
        SET del_position2_cnt = (del_position2_cnt+ 1)
        SET tempfields->delete_positions2[del_position2_cnt].cdi_cm_login_position_id = request->
        logins[login_cnt].positions[position_cnt].cdi_cm_login_position_id
       ELSE
        SET upd_position_cnt = (upd_position_cnt+ 1)
        SET tempfields->update_positions[upd_position_cnt].cdi_cm_login_position_id = request->
        logins[login_cnt].positions[position_cnt].cdi_cm_login_position_id
        SET tempfields->update_positions[upd_position_cnt].position_cd = request->logins[login_cnt].
        positions[position_cnt].position_cd
        SET tempfields->update_positions[upd_position_cnt].cdi_cm_login_id = request->logins[
        login_cnt].cdi_cm_login_id
        SET tempfields->update_positions[upd_position_cnt].updt_cnt = request->logins[login_cnt].
        updt_cnt
       ENDIF
      ELSE
       SET ins_position_cnt = (ins_position_cnt+ 1)
       SET tempfields->insert_positions[ins_position_cnt].cdi_cm_login_id = request->logins[login_cnt
       ].cdi_cm_login_id
       SET tempfields->insert_positions[ins_position_cnt].position_cd = request->logins[login_cnt].
       positions[position_cnt].position_cd
      ENDIF
    ENDFOR
    IF (position_rows < 1)
     SET del_position_cnt = (del_position_cnt+ 1)
     SET tempfields->delete_positions[del_position_cnt].cdi_cm_login_id = request->logins[login_cnt].
     cdi_cm_login_id
    ENDIF
   ENDIF
  ELSE
   SET ins_login_cnt = (ins_login_cnt+ 1)
   SET tempfields->insert_logins[ins_login_cnt].cm_password = request->logins[login_cnt].password
   SET tempfields->insert_logins[ins_login_cnt].cm_username = request->logins[login_cnt].username
   SET tempfields->insert_logins[ins_login_cnt].organization_id = request->logins[login_cnt].
   organization_id
   SET tempfields->insert_logins[ins_login_cnt].org_default_ind = request->logins[login_cnt].
   org_default_ind
   SET stat = alterlist(tempfields->insert_logins[ins_login_cnt].positions,position_rows)
   FOR (position_cnt = 1 TO position_rows)
     SET tempfields->insert_logins[ins_login_cnt].positions[position_cnt].position_cd = request->
     logins[login_cnt].positions[position_cnt].position_cd
   ENDFOR
  ENDIF
 ENDFOR
 SET stat = alterlist(tempfields->update_logins,upd_login_cnt)
 SET stat = alterlist(tempfields->insert_logins,ins_login_cnt)
 SET stat = alterlist(tempfields->delete_logins,del_login_cnt)
 SET stat = alterlist(tempfields->delete_positions2,del_position2_cnt)
 SET stat = alterlist(tempfields->update_positions,upd_position_cnt)
 SET stat = alterlist(tempfields->insert_positions,ins_position_cnt)
 SET stat = alterlist(tempfields->delete_positions,del_position_cnt)
 SET reply->status_data.subeventstatus[1].operationname = "SELECT"
 SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_CM_LOGIN"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = build2("Lock ",upd_login_cnt,
  " rows to be updated.")
 IF (upd_login_cnt > 0)
  SELECT
   FROM cdi_cm_login cl,
    (dummyt d  WITH seq = upd_login_cnt)
   PLAN (d)
    JOIN (cl
    WHERE (cl.cdi_cm_login_id=tempfields->update_logins[d.seq].cdi_cm_login_id)
     AND (cl.updt_cnt <= tempfields->update_logins[d.seq].updt_cnt))
   WITH nocounter, forupdate(cl)
  ;end select
  IF (curqual != upd_login_cnt)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.subeventstatus[1].operationname = "SELECT"
 SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_CM_LOGIN_POSITION"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = build2("Lock ",upd_position_cnt,
  " rows to be updated.")
 IF (upd_position_cnt > 0)
  SELECT
   FROM cdi_cm_login_position cp,
    (dummyt d  WITH seq = upd_position_cnt)
   PLAN (d)
    JOIN (cp
    WHERE (cp.cdi_cm_login_position_id=tempfields->update_positions[d.seq].cdi_cm_login_position_id)
     AND (cp.updt_cnt <= tempfields->update_positions[d.seq].updt_cnt))
   WITH nocounter, forupdate(cp)
  ;end select
  IF (curqual != upd_position_cnt)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_CM_LOGIN"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = build2("Update ",upd_login_cnt,
  " login rows.")
 IF (upd_login_cnt > 0)
  UPDATE  FROM cdi_cm_login cl,
    (dummyt d  WITH seq = upd_login_cnt)
   SET cl.cm_password = tempfields->update_logins[d.seq].cm_password, cl.cm_username = tempfields->
    update_logins[d.seq].cm_username, cl.organization_id = tempfields->update_logins[d.seq].
    organization_id,
    cl.org_default_ind = tempfields->update_logins[d.seq].org_default_ind, cl.updt_cnt = (cl.updt_cnt
    + 1), cl.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    cl.updt_task = reqinfo->updt_task, cl.updt_id = reqinfo->updt_id, cl.updt_applctx = reqinfo->
    updt_applctx
   PLAN (d)
    JOIN (cl
    WHERE (cl.cdi_cm_login_id=tempfields->update_logins[d.seq].cdi_cm_login_id))
   WITH nocounter
  ;end update
  IF (curqual != upd_login_cnt)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_CM_LOGIN_POSITION"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = build2("Update ",upd_position_cnt,
  " position rows.")
 IF (upd_position_cnt > 0)
  UPDATE  FROM cdi_cm_login_position cp,
    (dummyt d  WITH seq = upd_position_cnt)
   SET cp.position_cd = tempfields->update_positions[d.seq].position_cd, cp.cdi_cm_login_id =
    tempfields->update_positions[d.seq].cdi_cm_login_id, cp.updt_cnt = (cp.updt_cnt+ 1),
    cp.updt_dt_tm = cnvtdatetime(curdate,curtime3), cp.updt_task = reqinfo->updt_task, cp.updt_id =
    reqinfo->updt_id,
    cp.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (cp
    WHERE (cp.cdi_cm_login_position_id=tempfields->update_positions[d.seq].cdi_cm_login_position_id))
   WITH nocounter
  ;end update
  IF (curqual != upd_position_cnt)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.subeventstatus[1].operationname = "EXECUTE"
 SET reply->status_data.subeventstatus[1].targetobjectname = "DM2_DAR_GET_BULK_SEQ"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = build2("Assign ",ins_login_cnt,
  " login IDs.")
 IF (ins_login_cnt > 0)
  EXECUTE dm2_dar_get_bulk_seq "tempfields->insert_logins", ins_login_cnt, "cdi_cm_login_id",
  1, "CDI_SEQ"
  IF ((m_dm2_seq_stat->n_status != 1))
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = m_dm2_seq_stat->s_error_msg
   GO TO exit_script
  ENDIF
 ENDIF
 SET login_rows = value(size(tempfields->insert_logins,5))
 FOR (login_cnt = 1 TO login_rows)
  SET position_rows = value(size(tempfields->insert_logins[login_cnt].positions,5))
  FOR (position_cnt = 1 TO position_rows)
    SET ins_position_cnt = (ins_position_cnt+ 1)
    SET stat = alterlist(tempfields->insert_positions,ins_position_cnt)
    SET tempfields->insert_positions[ins_position_cnt].cdi_cm_login_id = tempfields->insert_logins[
    login_cnt].cdi_cm_login_id
    SET tempfields->insert_positions[ins_position_cnt].position_cd = tempfields->insert_logins[
    login_cnt].positions[position_cnt].position_cd
  ENDFOR
 ENDFOR
 SET reply->status_data.subeventstatus[1].operationname = "EXECUTE"
 SET reply->status_data.subeventstatus[1].targetobjectname = "DM2_DAR_GET_BULK_SEQ"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = build2("Assign ",ins_position_cnt,
  " position IDs.")
 IF (ins_position_cnt > 0)
  EXECUTE dm2_dar_get_bulk_seq "tempfields->insert_positions", ins_position_cnt,
  "cdi_cm_login_position_id",
  1, "CDI_SEQ"
  IF ((m_dm2_seq_stat->n_status != 1))
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = m_dm2_seq_stat->s_error_msg
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.subeventstatus[1].operationname = "DELETE"
 SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_CM_LOGIN_POSITION"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = build2("Deleting ",del_position2_cnt,
  " position rows by cdi_cm_login_position_id.")
 IF (del_position2_cnt > 0)
  DELETE  FROM cdi_cm_login_position cp
   WHERE expand(num,1,del_position2_cnt,cp.cdi_cm_login_position_id,tempfields->delete_positions2[num
    ].cdi_cm_login_position_id)
  ;end delete
  IF (curqual != del_position2_cnt)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.subeventstatus[1].operationname = "DELETE"
 SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_CM_LOGIN_POSITION"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = build2("Deleting ",del_position_cnt,
  " position rows by cdi_cm_login_id.")
 IF (del_position_cnt > 0)
  DELETE  FROM cdi_cm_login_position cp
   WHERE expand(num,1,del_position_cnt,cp.cdi_cm_login_id,tempfields->delete_positions[num].
    cdi_cm_login_id)
  ;end delete
 ENDIF
 SET reply->status_data.subeventstatus[1].operationname = "DELETE"
 SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_CM_LOGIN"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = build2("Deleting ",del_login_cnt,
  " login (and associated position) rows.")
 IF (del_login_cnt > 0)
  DELETE  FROM cdi_cm_login_position cp
   WHERE expand(num,1,del_login_cnt,cp.cdi_cm_login_id,tempfields->delete_logins[num].cdi_cm_login_id
    )
  ;end delete
  DELETE  FROM cdi_cm_login cl
   WHERE expand(num,1,del_login_cnt,cl.cdi_cm_login_id,tempfields->delete_logins[num].cdi_cm_login_id
    )
  ;end delete
  IF (curqual != del_login_cnt)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_CM_LOGIN"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = build2("Inserting ",ins_login_cnt,
  " login rows.")
 IF (ins_login_cnt > 0)
  INSERT  FROM cdi_cm_login cl,
    (dummyt d  WITH seq = ins_login_cnt)
   SET cl.cdi_cm_login_id = tempfields->insert_logins[d.seq].cdi_cm_login_id, cl.cm_password =
    tempfields->insert_logins[d.seq].cm_password, cl.cm_username = tempfields->insert_logins[d.seq].
    cm_username,
    cl.organization_id = tempfields->insert_logins[d.seq].organization_id, cl.org_default_ind =
    tempfields->insert_logins[d.seq].org_default_ind, cl.updt_cnt = 0,
    cl.updt_dt_tm = cnvtdatetime(curdate,curtime3), cl.updt_task = reqinfo->updt_task, cl.updt_id =
    reqinfo->updt_id,
    cl.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (cl)
   WITH nocounter
  ;end insert
  IF (curqual != ins_login_cnt)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_CM_LOGIN_POSITION"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = build2("Inserting ",ins_position_cnt,
  " position rows.")
 IF (ins_position_cnt > 0)
  INSERT  FROM cdi_cm_login_position cp,
    (dummyt d  WITH seq = ins_position_cnt)
   SET cp.cdi_cm_login_id = tempfields->insert_positions[d.seq].cdi_cm_login_id, cp
    .cdi_cm_login_position_id = tempfields->insert_positions[d.seq].cdi_cm_login_position_id, cp
    .position_cd = tempfields->insert_positions[d.seq].position_cd
   PLAN (d)
    JOIN (cp)
   WITH nocounter
  ;end insert
  IF (curqual != ins_position_cnt)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.subeventstatus[1].operationname = "-"
 SET reply->status_data.subeventstatus[1].targetobjectname = "REPLY"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "Populating reply."
 IF ((request->return_dataset_ind=1))
  SET position_rows = value(size(tempfields->insert_positions,5))
  FOR (position_cnt = 1 TO position_rows)
    SET upd_position_cnt = (upd_position_cnt+ 1)
    SET stat = alterlist(tempfields->update_positions,upd_position_cnt)
    SET tempfields->update_positions[upd_position_cnt].cdi_cm_login_position_id = tempfields->
    insert_positions[position_cnt].cdi_cm_login_position_id
    SET tempfields->update_positions[upd_position_cnt].cdi_cm_login_id = tempfields->
    insert_positions[position_cnt].cdi_cm_login_id
    SET tempfields->update_positions[upd_position_cnt].position_cd = tempfields->insert_positions[
    position_cnt].position_cd
    SET tempfields->update_positions[upd_position_cnt].updt_cnt = - (1)
  ENDFOR
  SET position_rows = upd_position_cnt
  SET login_rows = upd_login_cnt
  FOR (login_cnt = 1 TO login_rows)
    SET reply_ctr = (reply_ctr+ 1)
    SET stat = alterlist(reply->logins,reply_ctr)
    SET reply->logins[reply_ctr].cdi_cm_login_id = tempfields->update_logins[login_cnt].
    cdi_cm_login_id
    SET reply->logins[reply_ctr].username = tempfields->update_logins[login_cnt].cm_username
    SET reply->logins[reply_ctr].password = tempfields->update_logins[login_cnt].cm_password
    SET reply->logins[reply_ctr].organization_id = tempfields->update_logins[login_cnt].
    organization_id
    SET reply->logins[reply_ctr].org_default_ind = tempfields->update_logins[login_cnt].
    org_default_ind
    SET reply->logins[reply_ctr].updt_cnt = (tempfields->update_logins[login_cnt].updt_cnt+ 1)
    SET reply_pos_ctr = 0
    FOR (position_cnt = 1 TO position_rows)
      IF ((tempfields->update_positions[position_cnt].cdi_cm_login_id=reply->logins[reply_ctr].
      cdi_cm_login_id))
       SET reply_pos_ctr = (reply_pos_ctr+ 1)
       SET stat = alterlist(reply->logins[reply_ctr].positions,reply_pos_ctr)
       SET reply->logins[reply_ctr].positions[reply_pos_ctr].cdi_cm_login_position_id = tempfields->
       update_positions[position_cnt].cdi_cm_login_position_id
       SET reply->logins[reply_ctr].positions[reply_pos_ctr].position_cd = tempfields->
       update_positions[position_cnt].position_cd
       SET reply->logins[reply_ctr].positions[reply_pos_ctr].updt_cnt = (tempfields->
       update_positions[position_cnt].updt_cnt+ 1)
      ENDIF
    ENDFOR
  ENDFOR
  SET login_rows = ins_login_cnt
  FOR (login_cnt = 1 TO login_rows)
    SET reply_ctr = (reply_ctr+ 1)
    SET stat = alterlist(reply->logins,reply_ctr)
    SET reply->logins[reply_ctr].cdi_cm_login_id = tempfields->insert_logins[login_cnt].
    cdi_cm_login_id
    SET reply->logins[reply_ctr].username = tempfields->insert_logins[login_cnt].cm_username
    SET reply->logins[reply_ctr].password = tempfields->insert_logins[login_cnt].cm_password
    SET reply->logins[reply_ctr].organization_id = tempfields->insert_logins[login_cnt].
    organization_id
    SET reply->logins[reply_ctr].org_default_ind = tempfields->insert_logins[login_cnt].
    org_default_ind
    SET reply_pos_ctr = 0
    FOR (position_cnt = 1 TO position_rows)
      IF ((tempfields->update_positions[position_cnt].cdi_cm_login_id=reply->logins[reply_ctr].
      cdi_cm_login_id))
       SET reply_pos_ctr = (reply_pos_ctr+ 1)
       SET stat = alterlist(reply->logins[reply_ctr].positions,reply_pos_ctr)
       SET reply->logins[reply_ctr].positions[reply_pos_ctr].cdi_cm_login_position_id = tempfields->
       update_positions[position_cnt].cdi_cm_login_position_id
       SET reply->logins[reply_ctr].positions[reply_pos_ctr].position_cd = tempfields->
       update_positions[position_cnt].position_cd
       SET reply->logins[reply_ctr].positions[reply_pos_ctr].updt_cnt = (tempfields->
       update_positions[position_cnt].updt_cnt+ 1)
      ENDIF
    ENDFOR
  ENDFOR
 ENDIF
#exit_script
 IF ((reply->status_data.subeventstatus[1].operationstatus="S"))
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationname = "-"
  SET reply->status_data.subeventstatus[1].targetobjectname = "-"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Success."
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
