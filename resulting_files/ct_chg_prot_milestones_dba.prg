CREATE PROGRAM ct_chg_prot_milestones:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 qual[*]
      2 ct_prot_milestones_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET fail_flag = 0
 SET gen_nbr_error = 1
 SET insert_error = 2
 SET update_error = 3
 SET delete_error = 4
 SET new_id = 0.0
 SET add_size = size(request->add_qual,5)
 SET bstat = alterlist(reply->qual,add_size)
 FOR (i = 1 TO add_size)
   SELECT INTO "nl:"
    num = seq(protocol_def_seq,nextval)"########################;rpO"
    FROM dual
    DETAIL
     new_id = cnvtreal(num)
    WITH format, counter
   ;end select
   IF (curqual=0)
    SET fail_flag = gen_nbr_error
    GO TO check_error
   ENDIF
   SET reply->qual[i].ct_prot_milestones_id = new_id
   INSERT  FROM ct_prot_milestones cpm
    SET cpm.ct_prot_milestones_id = new_id, cpm.prot_master_id = request->prot_master_id, cpm
     .sequence_nbr = request->add_qual[i].sequence_nbr,
     cpm.activity_cd = request->add_qual[i].activity_cd, cpm.entity_type_flag = request->add_qual[i].
     entity_type_flag, cpm.organization_id = request->add_qual[i].organization_id,
     cpm.committee_id = request->add_qual[i].committee_id, cpm.prot_role_cd = request->add_qual[i].
     prot_role_cd, cpm.performed_dt_tm = cnvtdatetime(request->add_qual[i].performed_dt_tm),
     cpm.updt_cnt = 0, cpm.updt_dt_tm = cnvtdatetime(curdate,curtime3), cpm.updt_id = reqinfo->
     updt_id,
     cpm.updt_applctx = reqinfo->updt_applctx, cpm.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET fail_flag = insert_error
    GO TO check_error
   ENDIF
 ENDFOR
 SET upt_size = size(request->upt_qual,5)
 IF (upt_size > 0)
  UPDATE  FROM ct_prot_milestones cpm,
    (dummyt d  WITH seq = value(upt_size))
   SET cpm.prot_master_id = request->prot_master_id, cpm.sequence_nbr = request->upt_qual[d.seq].
    sequence_nbr, cpm.activity_cd = request->upt_qual[d.seq].activity_cd,
    cpm.entity_type_flag = request->upt_qual[d.seq].entity_type_flag, cpm.organization_id = request->
    upt_qual[d.seq].organization_id, cpm.committee_id = request->upt_qual[d.seq].committee_id,
    cpm.prot_role_cd = request->upt_qual[d.seq].prot_role_cd, cpm.performed_dt_tm = cnvtdatetime(
     request->upt_qual[d.seq].performed_dt_tm), cpm.updt_cnt = (cpm.updt_cnt+ 1),
    cpm.updt_dt_tm = cnvtdatetime(curdate,curtime3), cpm.updt_id = reqinfo->updt_id, cpm.updt_applctx
     = reqinfo->updt_applctx,
    cpm.updt_task = reqinfo->updt_task
   PLAN (d)
    JOIN (cpm
    WHERE (cpm.ct_prot_milestones_id=request->upt_qual[d.seq].milestones_id))
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET fail_flag = update_error
   GO TO check_error
  ENDIF
 ENDIF
 SET del_size = size(request->del_qual,5)
 FOR (i = 1 TO del_size)
  DELETE  FROM ct_prot_milestones cpm
   WHERE (cpm.ct_prot_milestones_id=request->del_qual[i].milestones_id)
   WITH nocounter
  ;end delete
  IF (curqual=0)
   SET fail_flag = delete_error
   GO TO check_error
  ENDIF
 ENDFOR
#check_error
 IF (fail_flag=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  CASE (fail_flag)
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
