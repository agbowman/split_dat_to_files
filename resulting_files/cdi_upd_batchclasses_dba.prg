CREATE PROGRAM cdi_upd_batchclasses:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD newbc(
   1 batchclasses[*]
     2 cdi_ac_batchclass_id = f8
     2 batchclass_name = vc
     2 single_encntr = i2
     2 auto_comp_notify = i2
     2 auto_close = i2
     2 auditing_ind = i2
     2 organization_id = f8
     2 updt_cnt = i4
     2 alias_contrib_src_cd = f8
     2 cpdi_batch_class_ind = i2
     2 parent_types[*]
       3 parent_level_cd = f8
       3 cdi_ac_batchclass_parent_r_id = f8
       3 delitem = i2
     2 batch_profile_ind = i2
 )
 RECORD tempfields(
   1 insert_parent_types[*]
     2 cdi_ac_batchclass_id = f8
     2 parent_level_cd = f8
   1 delete_parent_types[*]
     2 cdi_ac_batchclass_parent_r_id = f8
 )
 RECORD templogdomain(
   1 batchclasses[*]
     2 cdi_ac_batchclass_id = f8
     2 logical_domain_id = f8
 )
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 ) WITH protect
 DECLARE batchclass_rows = i4 WITH noconstant(value(size(request->batchclasses,5))), protect
 DECLARE num = i4 WITH noconstant(0), protect
 DECLARE count = i4 WITH noconstant(0), protect
 DECLARE err_msg = vc WITH noconstant(" "), protect
 DECLARE rows_to_update_count = i4 WITH noconstant(0), public
 DECLARE rows_to_activate_count = i4 WITH noconstant(0), public
 DECLARE bc_cnt = i4 WITH noconstant(0), public
 DECLARE parent_rows = i4 WITH noconstant(0), public
 DECLARE parent_cnt = i4 WITH noconstant(0), public
 DECLARE del_parent_cnt = i4 WITH noconstant(0), public
 DECLARE insert_parent_cnt = i4 WITH noconstant(0), public
 DECLARE insert_bc_cnt = i4 WITH noconstant(0), public
 SET reply->status_data.status = "F"
 IF (batchclass_rows > 0)
  SELECT INTO "NL:"
   bc.updt_cnt
   FROM cdi_ac_batchclass bc,
    (dummyt d  WITH seq = batchclass_rows)
   PLAN (d)
    JOIN (bc
    WHERE cnvtupper(bc.batchclass_name)=cnvtupper(request->batchclasses[d.seq].batchclass_name)
     AND (request->batchclasses[d.seq].cdi_ac_batchclass_id=0)
     AND bc.active_ind=0)
   DETAIL
    rows_to_activate_count += 1, request->batchclasses[d.seq].cdi_ac_batchclass_id = bc
    .cdi_ac_batchclass_id, request->batchclasses[d.seq].single_encntr = bc.single_encntr,
    request->batchclasses[d.seq].auto_comp_notify = bc.auto_comp_notify, request->batchclasses[d.seq]
    .auto_close = bc.auto_close, request->batchclasses[d.seq].auditing_ind = bc.auditing_ind,
    request->batchclasses[d.seq].organization_id = bc.organization_id, request->batchclasses[d.seq].
    updt_cnt = (bc.updt_cnt+ 1), request->batchclasses[d.seq].alias_contrib_src_cd = bc
    .alias_contrib_src_cd,
    request->batchclasses[d.seq].cpdi_batch_class_ind = bc.cpdi_batch_class_ind, request->
    batchclasses[d.seq].batch_profile_ind = bc.batch_profile_ind
   WITH nocounter
  ;end select
  IF (rows_to_activate_count > 0)
   UPDATE  FROM cdi_ac_batchclass bc,
     (dummyt d  WITH seq = batchclass_rows)
    SET bc.active_ind = 1, bc.updt_cnt = (bc.updt_cnt+ 1), bc.updt_dt_tm = cnvtdatetime(sysdate),
     bc.updt_task = reqinfo->updt_task, bc.updt_id = reqinfo->updt_id, bc.updt_applctx = reqinfo->
     updt_applctx
    PLAN (d)
     JOIN (bc
     WHERE cnvtupper(bc.batchclass_name)=cnvtupper(request->batchclasses[d.seq].batchclass_name)
      AND (request->batchclasses[d.seq].cdi_ac_batchclass_id=bc.cdi_ac_batchclass_id)
      AND bc.active_ind=0)
    WITH nocounter
   ;end update
   IF (curqual != rows_to_activate_count)
    SET ecode = 0
    SET emsg = fillstring(132," ")
    SET ecode = error(emsg,1)
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_AC_BATCHCLASS"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = emsg
    GO TO exit_script
   ENDIF
  ENDIF
  FOR (bc_cnt = 1 TO batchclass_rows)
    IF ((request->batchclasses[bc_cnt].cdi_ac_batchclass_id=0))
     SET insert_bc_cnt += 1
     SET stat = alterlist(newbc->batchclasses,insert_bc_cnt)
     SET newbc->batchclasses[insert_bc_cnt].batchclass_name = request->batchclasses[bc_cnt].
     batchclass_name
     SET newbc->batchclasses[insert_bc_cnt].single_encntr = request->batchclasses[bc_cnt].
     single_encntr
     SET newbc->batchclasses[insert_bc_cnt].auto_comp_notify = request->batchclasses[bc_cnt].
     auto_comp_notify
     SET newbc->batchclasses[insert_bc_cnt].auto_close = request->batchclasses[bc_cnt].auto_close
     SET newbc->batchclasses[insert_bc_cnt].auditing_ind = request->batchclasses[bc_cnt].auditing_ind
     SET newbc->batchclasses[insert_bc_cnt].organization_id = request->batchclasses[bc_cnt].
     organization_id
     SET newbc->batchclasses[insert_bc_cnt].updt_cnt = request->batchclasses[bc_cnt].updt_cnt
     SET newbc->batchclasses[insert_bc_cnt].alias_contrib_src_cd = request->batchclasses[bc_cnt].
     alias_contrib_src_cd
     SET newbc->batchclasses[insert_bc_cnt].cpdi_batch_class_ind = request->batchclasses[bc_cnt].
     cpdi_batch_class_ind
     SET newbc->batchclasses[insert_bc_cnt].batch_profile_ind = request->batchclasses[bc_cnt].
     batch_profile_ind
     SET parent_rows = value(size(request->batchclasses[bc_cnt].parent_types,5))
     SET stat = alterlist(newbc->batchclasses[insert_bc_cnt].parent_types,parent_rows)
     FOR (parent_cnt = 1 TO parent_rows)
      SET newbc->batchclasses[insert_bc_cnt].parent_types[parent_cnt].cdi_ac_batchclass_parent_r_id
       = request->batchclasses[bc_cnt].parent_types[parent_cnt].cdi_ac_batchclass_parent_r_id
      SET newbc->batchclasses[insert_bc_cnt].parent_types[parent_cnt].parent_level_cd = request->
      batchclasses[bc_cnt].parent_types[parent_cnt].parent_level_cd
     ENDFOR
    ENDIF
  ENDFOR
  IF (insert_bc_cnt > 0)
   EXECUTE dm2_dar_get_bulk_seq "newbc->batchclasses", insert_bc_cnt, "cdi_ac_batchclass_id",
   1, "CDI_SEQ"
  ENDIF
  FOR (bc_cnt = 1 TO batchclass_rows)
    SET parent_rows = value(size(request->batchclasses[bc_cnt].parent_types,5))
    SET stat = alterlist(tempfields->insert_parent_types,(parent_rows+ insert_parent_cnt))
    SET stat = alterlist(tempfields->delete_parent_types,(parent_rows+ del_parent_cnt))
    FOR (parent_cnt = 1 TO parent_rows)
      IF ((request->batchclasses[bc_cnt].parent_types[parent_cnt].cdi_ac_batchclass_parent_r_id > 0.0
      ))
       IF ((request->batchclasses[bc_cnt].parent_types[parent_cnt].delitem=1))
        SET del_parent_cnt += 1
        SET tempfields->delete_parent_types[del_parent_cnt].cdi_ac_batchclass_parent_r_id = request->
        batchclasses[bc_cnt].parent_types[parent_cnt].cdi_ac_batchclass_parent_r_id
       ENDIF
      ELSE
       IF ((request->batchclasses[bc_cnt].cdi_ac_batchclass_id > 0))
        SET insert_parent_cnt += 1
        SET tempfields->insert_parent_types[insert_parent_cnt].cdi_ac_batchclass_id = request->
        batchclasses[bc_cnt].cdi_ac_batchclass_id
        SET tempfields->insert_parent_types[insert_parent_cnt].parent_level_cd = request->
        batchclasses[bc_cnt].parent_types[parent_cnt].parent_level_cd
       ENDIF
      ENDIF
    ENDFOR
  ENDFOR
  SET stat = alterlist(tempfields->delete_parent_types,del_parent_cnt)
  SET stat = alterlist(tempfields->insert_parent_types,insert_parent_cnt)
  FOR (bc_cnt = 1 TO insert_bc_cnt)
   SET parent_rows = value(size(newbc->batchclasses[bc_cnt].parent_types,5))
   FOR (parent_cnt = 1 TO parent_rows)
     SET insert_parent_cnt += 1
     SET stat = alterlist(tempfields->insert_parent_types,insert_parent_cnt)
     SET tempfields->insert_parent_types[insert_parent_cnt].cdi_ac_batchclass_id = newbc->
     batchclasses[bc_cnt].cdi_ac_batchclass_id
     SET tempfields->insert_parent_types[insert_parent_cnt].parent_level_cd = newbc->batchclasses[
     bc_cnt].parent_types[parent_cnt].parent_level_cd
   ENDFOR
  ENDFOR
  IF (insert_parent_cnt > 0)
   INSERT  FROM cdi_ac_batchclass_parent_r bcr,
     (dummyt d  WITH seq = insert_parent_cnt)
    SET bcr.cdi_ac_batchclass_parent_r_id = seq(cdi_seq,nextval), bcr.cdi_ac_batchclass_id =
     tempfields->insert_parent_types[d.seq].cdi_ac_batchclass_id, bcr.parent_level_cd = tempfields->
     insert_parent_types[d.seq].parent_level_cd,
     bcr.updt_cnt = 0, bcr.updt_dt_tm = cnvtdatetime(sysdate), bcr.updt_task = reqinfo->updt_task,
     bcr.updt_id = reqinfo->updt_id, bcr.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (bcr)
    WITH nocounter
   ;end insert
   IF (curqual != insert_parent_cnt)
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    GO TO exit_script
   ENDIF
  ENDIF
  IF (del_parent_cnt > 0)
   DELETE  FROM cdi_ac_batchclass_parent_r bcr
    WHERE expand(num,1,del_parent_cnt,bcr.cdi_ac_batchclass_parent_r_id,tempfields->
     delete_parent_types[num].cdi_ac_batchclass_parent_r_id)
    WITH nocounter
   ;end delete
   IF (curqual != del_parent_cnt)
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    GO TO exit_script
   ENDIF
  ENDIF
  SELECT INTO "NL:"
   bc.updt_cnt
   FROM cdi_ac_batchclass bc,
    (dummyt d  WITH seq = batchclass_rows)
   PLAN (d)
    JOIN (bc
    WHERE (bc.cdi_ac_batchclass_id=request->batchclasses[d.seq].cdi_ac_batchclass_id)
     AND (request->batchclasses[d.seq].cdi_ac_batchclass_id > 0))
   DETAIL
    rows_to_update_count += 1
   WITH nocounter, forupdate(bc)
  ;end select
  IF (rows_to_update_count > 0)
   UPDATE  FROM cdi_ac_batchclass bc,
     (dummyt d  WITH seq = batchclass_rows)
    SET bc.single_encntr = request->batchclasses[d.seq].single_encntr, bc.auto_comp_notify = request
     ->batchclasses[d.seq].auto_comp_notify, bc.auto_close = request->batchclasses[d.seq].auto_close,
     bc.auditing_ind = request->batchclasses[d.seq].auditing_ind, bc.organization_id = request->
     batchclasses[d.seq].organization_id, bc.alias_contrib_src_cd = request->batchclasses[d.seq].
     alias_contrib_src_cd,
     bc.cpdi_batch_class_ind = request->batchclasses[d.seq].cpdi_batch_class_ind, bc
     .batch_profile_ind = request->batchclasses[d.seq].batch_profile_ind, bc.updt_cnt = (bc.updt_cnt
     + 1),
     bc.updt_dt_tm = cnvtdatetime(sysdate), bc.updt_task = reqinfo->updt_task, bc.updt_id = reqinfo->
     updt_id,
     bc.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (bc
     WHERE (bc.cdi_ac_batchclass_id=request->batchclasses[d.seq].cdi_ac_batchclass_id)
      AND (request->batchclasses[d.seq].cdi_ac_batchclass_id > 0)
      AND (bc.updt_cnt=request->batchclasses[d.seq].updt_cnt))
    WITH nocounter
   ;end update
   IF (curqual != rows_to_update_count)
    SET ecode = 0
    SET emsg = fillstring(132," ")
    SET ecode = error(emsg,1)
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_AC_BATCHCLASS"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = emsg
    GO TO exit_script
   ENDIF
  ENDIF
  IF (insert_bc_cnt > 0)
   INSERT  FROM cdi_ac_batchclass bc,
     (dummyt d  WITH seq = insert_bc_cnt)
    SET bc.cdi_ac_batchclass_id = newbc->batchclasses[d.seq].cdi_ac_batchclass_id, bc.batchclass_name
      = newbc->batchclasses[d.seq].batchclass_name, bc.single_encntr = newbc->batchclasses[d.seq].
     single_encntr,
     bc.auto_comp_notify = newbc->batchclasses[d.seq].auto_comp_notify, bc.auto_close = newbc->
     batchclasses[d.seq].auto_close, bc.auditing_ind = newbc->batchclasses[d.seq].auditing_ind,
     bc.organization_id = newbc->batchclasses[d.seq].organization_id, bc.alias_contrib_src_cd = newbc
     ->batchclasses[d.seq].alias_contrib_src_cd, bc.cpdi_batch_class_ind = newbc->batchclasses[d.seq]
     .cpdi_batch_class_ind,
     bc.batch_profile_ind = newbc->batchclasses[d.seq].batch_profile_ind, bc.updt_cnt = 0, bc
     .updt_dt_tm = cnvtdatetime(sysdate),
     bc.updt_task = reqinfo->updt_task, bc.updt_id = reqinfo->updt_id, bc.updt_applctx = reqinfo->
     updt_applctx
    PLAN (d)
     JOIN (bc)
    WITH nocounter
   ;end insert
  ENDIF
  SELECT INTO "NL:"
   FROM cdi_ac_batchclass b,
    organization o
   PLAN (b
    WHERE expand(num,1,batchclass_rows,b.batchclass_name,request->batchclasses[num].batchclass_name))
    JOIN (o
    WHERE b.organization_id=o.organization_id)
   HEAD REPORT
    stat = alterlist(templogdomain->batchclasses,batchclass_rows)
   DETAIL
    count += 1, templogdomain->batchclasses[count].cdi_ac_batchclass_id = b.cdi_ac_batchclass_id,
    templogdomain->batchclasses[count].logical_domain_id = o.logical_domain_id
   FOOT REPORT
    stat = alterlist(templogdomain->batchclasses,count)
   WITH nocounter
  ;end select
  UPDATE  FROM cdi_pending_batch p,
    (dummyt d  WITH seq = count)
   SET p.logical_domain_id = templogdomain->batchclasses[d.seq].logical_domain_id, p.updt_cnt = (p
    .updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(sysdate),
    p.updt_task = reqinfo->updt_task, p.updt_id = reqinfo->updt_id, p.updt_applctx = reqinfo->
    updt_applctx
   PLAN (d)
    JOIN (p
    WHERE (p.cdi_ac_batchclass_id=templogdomain->batchclasses[d.seq].cdi_ac_batchclass_id)
     AND p.cdi_ac_batchclass_id > 0)
  ;end update
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
