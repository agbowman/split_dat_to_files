CREATE PROGRAM ct_chg_amd_milestones:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 qual[*]
      2 ct_amd_milestones_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE fail_flag = i4 WITH private, noconstant(0)
 DECLARE gen_nbr_error = i4 WITH private, constant(1)
 DECLARE insert_error = i4 WITH private, constant(2)
 DECLARE update_error = i4 WITH private, constant(3)
 DECLARE delete_error = i4 WITH private, constant(4)
 DECLARE open_to_accrual_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17274,"ACTIVATED"))
 DECLARE amd_superseded_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17274,"SUPERCEDED"))
 DECLARE activated_by_meaning = c11 WITH protect, constant("ACTIVATEDBY")
 DECLARE activation_date_updated_ind = i2 WITH private, noconstant(false)
 DECLARE date_conflicts_ind = i2 WITH private, noconstant(false)
 DECLARE patient_conflicts_ind = i2 WITH private, noconstant(false)
 DECLARE upt_size = i4 WITH private, noconstant(0)
 DECLARE add_size = i4 WITH private, noconstant(0)
 DECLARE del_size = i4 WITH private, noconstant(0)
 DECLARE new_id = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 IF ((request->prot_amendment_status_cd=open_to_accrual_cd))
  SET upt_size = size(request->upt_qual,5)
  IF (upt_size > 0)
   FOR (i = 1 TO upt_size)
     IF (uar_get_code_meaning(request->upt_qual[i].activity_cd)=activated_by_meaning
      AND (request->upt_qual[i].date_changed_flag=1))
      SELECT INTO "nl:"
       FROM prot_amendment pa,
        prot_amendment pa1
       PLAN (pa
        WHERE (pa.prot_amendment_id=request->prot_amendment_id))
        JOIN (pa1
        WHERE pa.prot_master_id=pa1.prot_master_id
         AND pa1.amendment_status_cd=amd_superseded_cd
         AND pa1.amendment_dt_tm > cnvtdatetime(request->upt_qual[i].performed_dt_tm))
       WITH nocounter
      ;end select
      IF (curqual > 0)
       SET date_conflicts_ind = true
       SET stat = alterlist(request->upt_qual,(upt_size - 1),(i - 1))
      ELSE
       UPDATE  FROM prot_amendment pa
        SET pa.amendment_dt_tm = cnvtdatetime(request->upt_qual[i].performed_dt_tm), pa.updt_dt_tm =
         cnvtdatetime(curdate,curtime3), pa.updt_id = reqinfo->updt_id,
         pa.updt_applctx = reqinfo->updt_applctx, pa.updt_task = reqinfo->updt_task, pa.updt_cnt = (
         pa.updt_cnt+ 1)
        WHERE (pa.prot_amendment_id=request->prot_amendment_id)
        WITH nocounter
       ;end update
       IF (curqual=0)
        SET fail_flag = update_error
        GO TO check_error
       ELSE
        SET activation_date_updated_ind = true
       ENDIF
       SELECT DISTINCT INTO "nl:"
        FROM pt_prot_reg ppr,
         ct_pt_amd_assignment cpaa,
         person p
        PLAN (cpaa
         WHERE (cpaa.prot_amendment_id=request->prot_amendment_id)
          AND cpaa.assign_start_dt_tm < cnvtdatetime(request->upt_qual[i].performed_dt_tm)
          AND cpaa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
         JOIN (ppr
         WHERE ppr.pt_prot_reg_id=cpaa.reg_id)
         JOIN (p
         WHERE p.person_id=ppr.person_id)
        ORDER BY ppr.pt_prot_reg_id
       ;end select
       IF (curqual > 0)
        SET patient_conflicts_ind = true
       ENDIF
      ENDIF
      SET i = (upt_size+ 1)
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 SET new_id = 0.0
 SET add_size = size(request->add_qual,5)
 SET stat = alterlist(reply->qual,add_size)
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
   SET reply->qual[i].ct_amd_milestones_id = new_id
   INSERT  FROM ct_milestones cm
    SET cm.ct_milestones_id = new_id, cm.prot_amendment_id = request->prot_amendment_id, cm
     .sequence_nbr = request->add_qual[i].sequence_nbr,
     cm.activity_cd = request->add_qual[i].activity_cd, cm.entity_type_flag = request->add_qual[i].
     entity_type_flag, cm.organization_id = request->add_qual[i].organization_id,
     cm.committee_id = request->add_qual[i].committee_id, cm.prot_role_cd = request->add_qual[i].
     prot_role_cd, cm.performed_dt_tm = cnvtdatetime(request->add_qual[i].performed_dt_tm),
     cm.updt_cnt = 0, cm.updt_dt_tm = cnvtdatetime(curdate,curtime3), cm.updt_id = reqinfo->updt_id,
     cm.updt_applctx = reqinfo->updt_applctx, cm.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET fail_flag = insert_error
    GO TO check_error
   ENDIF
 ENDFOR
 SET upt_size = size(request->upt_qual,5)
 IF (upt_size > 0)
  UPDATE  FROM ct_milestones cm,
    (dummyt d  WITH seq = value(upt_size))
   SET cm.prot_amendment_id = request->prot_amendment_id, cm.sequence_nbr = request->upt_qual[d.seq].
    sequence_nbr, cm.activity_cd = request->upt_qual[d.seq].activity_cd,
    cm.entity_type_flag = request->upt_qual[d.seq].entity_type_flag, cm.organization_id = request->
    upt_qual[d.seq].organization_id, cm.committee_id = request->upt_qual[d.seq].committee_id,
    cm.prot_role_cd = request->upt_qual[d.seq].prot_role_cd, cm.performed_dt_tm = cnvtdatetime(
     request->upt_qual[d.seq].performed_dt_tm), cm.updt_cnt = (cm.updt_cnt+ 1),
    cm.updt_dt_tm = cnvtdatetime(curdate,curtime3), cm.updt_id = reqinfo->updt_id, cm.updt_applctx =
    reqinfo->updt_applctx,
    cm.updt_task = reqinfo->updt_task
   PLAN (d)
    JOIN (cm
    WHERE (cm.ct_milestones_id=request->upt_qual[d.seq].milestones_id))
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET fail_flag = update_error
   GO TO check_error
  ENDIF
 ENDIF
 SET del_size = size(request->del_qual,5)
 FOR (i = 1 TO del_size)
  DELETE  FROM ct_milestones cm
   WHERE (cm.ct_milestones_id=request->del_qual[i].milestones_id)
   WITH nocounter
  ;end delete
  IF (curqual=0)
   SET fail_flag = delete_error
   GO TO check_error
  ENDIF
 ENDFOR
#check_error
 IF (fail_flag=0)
  IF (activation_date_updated_ind=true)
   IF (patient_conflicts_ind=true)
    SET reply->status_data.status = "P"
   ELSE
    SET reply->status_data.status = "U"
   ENDIF
  ELSEIF (date_conflicts_ind=true)
   SET reply->status_data.status = "D"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
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
 SET last_mod = "002"
 SET mod_date = "April 12, 2011"
END GO
