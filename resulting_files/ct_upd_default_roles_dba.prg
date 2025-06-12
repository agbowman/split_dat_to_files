CREATE PROGRAM ct_upd_default_roles:dba
 RECORD reply(
   1 idlist[*]
     2 prot_default_role_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(domain_reply)))
  RECORD domain_reply(
    1 logical_domain_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE ct_get_logical_domain_id  WITH replace("REPLY",domain_reply)
 DECLARE fail_flag = i2 WITH private, noconstant(0)
 DECLARE updtcnt = i4 WITH protect, noconstant(0)
 DECLARE insertcnt = i4 WITH protect, noconstant(0)
 DECLARE deletecnt = i4 WITH protect, noconstant(0)
 DECLARE replycnt = i2 WITH protect, noconstant(0)
 DECLARE count = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE stat = i2 WITH private, noconstant(0)
 SET reply->status_data.status = "F"
 SET insertcnt = size(request->addlist,5)
 SET deletecnt = size(request->deletelist,5)
 SET updtcnt = size(request->updatelist,5)
 DECLARE gen_nbr_error = i2 WITH private, constant(1)
 DECLARE insert_error = i2 WITH private, constant(2)
 DECLARE update_error = i2 WITH private, constant(3)
 DECLARE lock_error = i2 WITH private, constant(4)
 DECLARE delete_error = i2 WITH private, constant(5)
 FOR (i = 1 TO insertcnt)
  SELECT INTO "nl:"
   new_id = seq(protocol_def_seq,nextval)
   FROM dual
   DETAIL
    replycnt += 1, stat = alterlist(reply->idlist,replycnt), reply->idlist[replycnt].
    prot_default_role_id = new_id,
    request->addlist[i].prot_default_role_id = new_id
   WITH counter
  ;end select
  IF (replycnt > 0)
   IF (curqual=0)
    SET fail_flag = gen_nbr_error
    GO TO check_error
   ENDIF
  ENDIF
 ENDFOR
 IF (insertcnt > 0)
  INSERT  FROM prot_default_roles pdr,
    (dummyt d  WITH seq = value(insertcnt))
   SET pdr.prot_default_role_id = request->addlist[d.seq].prot_default_role_id, pdr.prot_role_cd =
    request->addlist[d.seq].prot_role_cd, pdr.role_type_cd = request->addlist[d.seq].role_type_cd,
    pdr.person_id = request->addlist[d.seq].person_id, pdr.organization_id = request->addlist[d.seq].
    organization_id, pdr.position_cd = request->addlist[d.seq].position_cd,
    pdr.updt_cnt = 0, pdr.updt_dt_tm = cnvtdatetime(sysdate), pdr.updt_id = reqinfo->updt_id,
    pdr.updt_applctx = reqinfo->updt_applctx, pdr.updt_task = reqinfo->updt_task, pdr
    .logical_domain_id = domain_reply->logical_domain_id
   PLAN (d)
    JOIN (pdr)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET fail_flag = insert_error
   GO TO check_error
  ENDIF
 ENDIF
 IF (updtcnt > 0)
  SELECT INTO "nl:"
   pdr.*
   FROM prot_default_roles pdr,
    (dummyt d  WITH seq = value(updtcnt))
   PLAN (d)
    JOIN (pdr
    WHERE (pdr.prot_default_role_id=request->updatelist[d.seq].prot_default_role_id))
   DETAIL
    count += 1
   WITH counter
  ;end select
  CALL echo(build("count is ",count))
  IF (count != updtcnt)
   SET fail_flag = lock_error
   GO TO check_error
  ENDIF
  UPDATE  FROM prot_default_roles pdr,
    (dummyt d  WITH seq = value(updtcnt))
   SET pdr.prot_role_cd = request->updatelist[d.seq].prot_role_cd, pdr.role_type_cd = request->
    updatelist[d.seq].role_type_cd, pdr.person_id = request->updatelist[d.seq].person_id,
    pdr.organization_id = request->updatelist[d.seq].organization_id, pdr.position_cd = request->
    updatelist[d.seq].position_cd, pdr.updt_cnt = (pdr.updt_cnt+ 1),
    pdr.updt_dt_tm = cnvtdatetime(sysdate), pdr.updt_id = reqinfo->updt_id, pdr.updt_applctx =
    reqinfo->updt_applctx,
    pdr.updt_task = reqinfo->updt_task
   PLAN (d)
    JOIN (pdr
    WHERE (pdr.prot_default_role_id=request->updatelist[d.seq].prot_default_role_id))
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET fail_flag = update_error
   GO TO check_error
  ENDIF
 ENDIF
 IF (deletecnt > 0)
  FOR (i = 1 TO deletecnt)
   DELETE  FROM prot_default_roles pdr
    WHERE (pdr.prot_default_role_id=request->deletelist[i].prot_default_role_id)
   ;end delete
   IF (curqual=0)
    SET fail_flag = delete_error
    GO TO check_error
   ENDIF
  ENDFOR
 ENDIF
#check_error
 IF (fail_flag=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  SET reply->status_data.subeventstatus[1].operationname = ""
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
 ELSE
  CASE (fail_flag)
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error generating new id"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Error inserting into Prot_Default_Roles"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Error updating into Prot_Default_Roles"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error locking rows for update"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Error deleting rows in Prot_Default_Roles"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unknown Error"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reqinfo->commit_ind = 0
 ENDIF
 SET last_mod = "002"
 SET mod_date = "February 11, 2019"
END GO
