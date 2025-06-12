CREATE PROGRAM ct_upt_master_amendment_status:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 prot_suspension_id = f8
    1 reason_for_failure = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
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
 DECLARE concept = i2 WITH protect, constant(1)
 DECLARE superceded = i2 WITH protect, constant(2)
 DECLARE indev = i2 WITH protect, constant(3)
 DECLARE approved = i2 WITH protect, constant(4)
 DECLARE discontinued = i2 WITH protect, constant(5)
 DECLARE active = i2 WITH protect, constant(6)
 DECLARE tempsuspended = i2 WITH protect, constant(7)
 DECLARE invalid = i2 WITH protect, constant(8)
 DECLARE closed = i2 WITH protect, constant(9)
 DECLARE completed = i2 WITH protect, constant(10)
 DECLARE prot_master_id = f8 WITH protect, noconstant(0.0)
 DECLARE cnt = i2 WITH protect, noconstant(0)
 DECLARE new_status_cdf = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE concept_cd = f8 WITH protect, noconstant(0.0)
 DECLARE superceded_cd = f8 WITH protect, noconstant(0.0)
 DECLARE invalid_cd = f8 WITH protect, noconstant(0.0)
 DECLARE activated_cd = f8 WITH protect, noconstant(0.0)
 DECLARE prev_amendment_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE activatedby_cd = f8 WITH protect, noconstant(0.0)
 DECLARE new_prot_status = i2 WITH protect, noconstant(0)
 DECLARE new_prot_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE script_date = f8 WITH protect, constant(cnvtdatetime(sysdate))
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = false
 SET stat = uar_get_meaning_by_codeset(17274,"CONCEPT",1,concept_cd)
 SET stat = uar_get_meaning_by_codeset(17274,"SUPERCEDED",1,superceded_cd)
 SET stat = uar_get_meaning_by_codeset(17274,"INVALID",1,invalid_cd)
 SET stat = uar_get_meaning_by_codeset(17274,"ACTIVATED",1,activated_cd)
 SET new_status_cdf = uar_get_code_meaning(request->new_status_cd)
 RECORD hold(
   1 qual[*]
     2 amendment_nbr = i4
     2 status_cd = f8
     2 id = f8
     2 amendment_dt_tm = dq8
     2 revision_nbr = c30
   1 amddttm = dq8
 )
 IF ((request->mode=2))
  SELECT INTO "nl:"
   num = seq(protocol_def_seq,nextval)
   FROM dual
   DETAIL
    reply->prot_suspension_id = num
   WITH format, counter
  ;end select
  INSERT  FROM prot_suspension ps
   SET ps.beg_effective_dt_tm = cnvtdatetime(sysdate), ps.comment_txt = request->comment_txt, ps
    .prot_amendment_id = request->prot_amendment_id,
    ps.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), ps.prot_suspension_id = reply->
    prot_suspension_id, ps.reason_cd = request->reason_cd,
    ps.reason_for_correspondence_cd = 0, ps.updt_dt_tm = cnvtdatetime(sysdate), ps.updt_id = reqinfo
    ->updt_id,
    ps.updt_task = reqinfo->updt_task, ps.updt_applctx = reqinfo->updt_applctx, ps.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET reply->reason_for_failure = "Failure to insert into prot_suspension table"
   GO TO exit_failed
  ENDIF
 ENDIF
 IF ((request->mode=1))
  UPDATE  FROM prot_suspension ps
   SET ps.end_effective_dt_tm = cnvtdatetime(sysdate), ps.updt_dt_tm = cnvtdatetime(sysdate), ps
    .updt_id = reqinfo->updt_id,
    ps.updt_task = reqinfo->updt_task, ps.updt_applctx = reqinfo->updt_applctx, ps.updt_cnt = (ps
    .updt_cnt+ 1)
   WHERE (ps.prot_suspension_id=request->prot_suspension_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET reply->reason_for_failure = "Failure to update prot_suspension table"
   GO TO exit_failed
  ENDIF
 ENDIF
 CALL echo(build("Activated_Cd =",activated_cd))
 IF ((request->revision_ind=1))
  SELECT INTO "nl:"
   pa2.prot_amendment_id
   FROM prot_amendment pa1,
    prot_amendment pa2,
    dummyt d
   PLAN (pa1
    WHERE (pa1.prot_amendment_id=request->prot_amendment_id))
    JOIN (d)
    JOIN (pa2
    WHERE pa2.prot_master_id=pa1.prot_master_id
     AND pa2.amendment_nbr <= pa1.amendment_nbr
     AND (((request->new_status_cd=activated_cd)) OR ((((request->closeonly_ind=1)) OR ((request->
    new_status_cd=invalid_cd))) )) )
   HEAD REPORT
    CALL echo("IN head"), cnt = 0, prot_master_id = pa1.prot_master_id,
    hold->amddttm = pa1.amendment_dt_tm
   DETAIL
    update_flag = 0,
    CALL echo("In Detail"), prev_amendment_status_cd = pa2.amendment_status_cd,
    pa2_status_cdf = uar_get_code_meaning(pa2.amendment_status_cd)
    IF (pa2_status_cdf IN ("ACTIVATED", "TEMPSUSPEND", "CLOSED")
     AND new_status_cdf="ACTIVATED")
     prev_amendment_status_cd = superceded_cd, update_flag = 1
    ELSEIF (pa2_status_cdf IN ("ACTIVATED", "TEMPSUSPEND", "CLOSED")
     AND new_status_cdf="CLOSED"
     AND (request->closeonly_ind=1))
     prev_amendment_status_cd = superceded_cd, update_flag = 1
    ELSEIF (pa2_status_cdf IN ("INDVLPMENT", "APPROVED")
     AND ((pa2.amendment_nbr < pa1.amendment_nbr) OR (pa2.revision_ind=1
     AND pa2.revision_seq < pa1.revision_seq))
     AND new_status_cdf="ACTIVATED")
     prev_amendment_status_cd = superceded_cd, update_flag = 1
    ELSEIF (pa2_status_cdf IN ("INDVLPMENT")
     AND pa2.amendment_nbr < pa1.amendment_nbr
     AND new_status_cdf="INVALID")
     prev_amendment_status_cd = superceded_cd
    ENDIF
    CALL echo(build("revision:",pa2.revision_seq))
    IF (update_flag=1)
     cnt += 1, bstat = alterlist(hold->qual,cnt), hold->qual[cnt].amendment_nbr = pa2.amendment_nbr,
     hold->qual[cnt].status_cd = prev_amendment_status_cd, hold->qual[cnt].id = pa2.prot_amendment_id,
     hold->qual[cnt].amendment_dt_tm = pa2.amendment_dt_tm,
     hold->qual[cnt].revision_nbr = pa2.revision_nbr_txt
    ENDIF
   WITH outerjoin = d, nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   pa2.prot_amendment_id
   FROM prot_amendment pa1,
    prot_amendment pa2,
    dummyt d
   PLAN (pa1
    WHERE (pa1.prot_amendment_id=request->prot_amendment_id))
    JOIN (d)
    JOIN (pa2
    WHERE pa2.prot_master_id=pa1.prot_master_id
     AND pa2.amendment_nbr != pa1.amendment_nbr
     AND pa2.amendment_nbr >= 0
     AND (((request->new_status_cd=activated_cd)) OR ((((request->closeonly_ind=1)) OR ((request->
    new_status_cd=invalid_cd))) )) )
   ORDER BY pa2.amendment_nbr
   HEAD REPORT
    CALL echo("IN head"), cnt = 0, prot_master_id = pa1.prot_master_id,
    hold->amddttm = pa1.amendment_dt_tm
   DETAIL
    CALL echo("In Detail"), update_flag = 0, prev_amendment_status_cd = pa2.amendment_status_cd,
    pa2_status_cdf = uar_get_code_meaning(pa2.amendment_status_cd)
    IF (pa2_status_cdf IN ("ACTIVATED", "TEMPSUSPEND", "CLOSED")
     AND new_status_cdf="ACTIVATED")
     prev_amendment_status_cd = superceded_cd, update_flag = 1
    ELSEIF (pa2_status_cdf IN ("ACTIVATED", "TEMPSUSPEND", "CLOSED")
     AND new_status_cdf="CLOSED"
     AND (request->closeonly_ind=1))
     prev_amendment_status_cd = superceded_cd, update_flag = 1
    ELSEIF (pa2_status_cdf IN ("INDVLPMENT", "APPROVED")
     AND pa2.amendment_nbr < pa1.amendment_nbr
     AND new_status_cdf="ACTIVATED")
     prev_amendment_status_cd = superceded_cd, update_flag = 1
    ELSEIF (pa2_status_cdf IN ("INDVLPMENT")
     AND pa2.amendment_nbr < pa1.amendment_nbr
     AND new_status_cdf="INVALID")
     prev_amendment_status_cd = superceded_cd, update_flag = 1
    ENDIF
    IF (update_flag=1)
     cnt += 1, bstat = alterlist(hold->qual,cnt), hold->qual[cnt].amendment_nbr = pa2.amendment_nbr,
     hold->qual[cnt].status_cd = prev_amendment_status_cd, hold->qual[cnt].id = pa2.prot_amendment_id,
     hold->qual[cnt].amendment_dt_tm = pa2.amendment_dt_tm
    ENDIF
   WITH outerjoin = d, nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reply->reason_for_failure = "Failure to get amendment information."
  GO TO exit_failed
 ENDIF
 SET cnt += 1
 SET bstat = alterlist(hold->qual,cnt)
 SET hold->qual[cnt].id = request->prot_amendment_id
 SET hold->qual[cnt].status_cd = request->new_status_cd
 IF ((request->new_status_cd=activated_cd))
  SET stat = uar_get_meaning_by_codeset(17876,"ACTIVATEDBY",1,activatedby_cd)
  SELECT INTO "nl:"
   cm.activity_cd, cm.performed_dt_tm
   FROM ct_milestones cm
   WHERE (cm.prot_amendment_id=request->prot_amendment_id)
    AND cm.activity_cd=activatedby_cd
    AND cm.performed_dt_tm != cnvtdatetime("31-dec-2100 00:00:00.00")
   DETAIL
    hold->qual[cnt].amendment_dt_tm = cnvtdatetime(cm.performed_dt_tm)
   WITH nocounter
  ;end select
  CALL echo("Amendment Dt Tm changed")
 ELSE
  SET hold->qual[cnt].amendment_dt_tm = hold->amddttm
  CALL echo("Amendment date and time has not changed.")
 ENDIF
 IF (cnt > 0)
  UPDATE  FROM prot_amendment pa,
    (dummyt d  WITH seq = value(cnt))
   SET pa.amendment_status_cd = hold->qual[d.seq].status_cd, pa.amendment_dt_tm = cnvtdatetime(hold->
     qual[d.seq].amendment_dt_tm), pa.updt_cnt = (pa.updt_cnt+ 1),
    pa.updt_dt_tm = cnvtdatetime(sysdate), pa.updt_id = reqinfo->updt_id, pa.updt_applctx = reqinfo->
    updt_applctx,
    pa.updt_task = reqinfo->updt_task
   PLAN (d)
    JOIN (pa
    WHERE (pa.prot_amendment_id=hold->qual[d.seq].id))
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET reply->reason_for_failure = "Failure to update prot_amendment table"
   GO TO exit_failed
  ENDIF
 ENDIF
 SET new_prot_status = 0
 SET new_prot_status_cd = concept_cd
 SELECT INTO "nl:"
  pa.prot_amendment_id
  FROM prot_amendment pa
  WHERE pa.prot_master_id=prot_master_id
  DETAIL
   amd_status = uar_get_code_meaning(pa.amendment_status_cd)
   CASE (amd_status)
    OF "CONCEPT":
     IF (concept > new_prot_status)
      new_prot_status_cd = pa.amendment_status_cd, new_prot_status = concept
     ENDIF
    OF "SUPERCEDED":
     IF (superceded > new_prot_status)
      new_prot_status_cd = pa.amendment_status_cd, new_prot_status = superceded
     ENDIF
    OF "INDVLPMENT":
     IF (indev > new_prot_status)
      new_prot_status_cd = pa.amendment_status_cd, new_prot_status = indev
     ENDIF
    OF "APPROVED":
     IF (approved > new_prot_status)
      new_prot_status_cd = pa.amendment_status_cd, new_prot_status = approved
     ENDIF
    OF "DISCONTINUED":
     IF (discontinued > new_prot_status)
      new_prot_status_cd = pa.amendment_status_cd, new_prot_status = discontinued
     ENDIF
    OF "ACTIVATED":
     IF (active > new_prot_status)
      new_prot_status_cd = pa.amendment_status_cd, new_prot_status = active
     ENDIF
    OF "TEMPSUSPEND":
     IF (tempsuspended > new_prot_status)
      new_prot_status_cd = pa.amendment_status_cd, new_prot_status = tempsuspended
     ENDIF
    OF "INVALID":
     IF (invalid > new_prot_status)
      new_prot_status_cd = pa.amendment_status_cd, new_prot_status = invalid
     ENDIF
    OF "CLOSED":
     IF (closed > new_prot_status)
      new_prot_status_cd = pa.amendment_status_cd, new_prot_status = closed
     ENDIF
    OF "COMPLETED":
     IF (completed > new_prot_status)
      new_prot_status_cd = pa.amendment_status_cd, new_prot_status = completed
     ENDIF
   ENDCASE
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->reason_for_failure = "Unable to get the highest amendment status for the protocol"
  GO TO exit_failed
 ENDIF
 CALL echo(build("New Protocol Status = ",new_prot_status_cd))
 INSERT  FROM prot_master pm
  (pm.prot_master_id, pm.accession_nbr_last, pm.accession_nbr_prefix,
  pm.accession_nbr_sig_dig, pm.prescreen_type_flag, pm.beg_effective_dt_tm,
  pm.collab_site_org_id, pm.display_ind, pm.end_effective_dt_tm,
  pm.initiating_service_cd, pm.initiating_service_desc, pm.parent_prot_master_id,
  pm.participation_type_cd, pm.peer_review_indicator_cd, pm.prev_prot_master_id,
  pm.primary_mnemonic, pm.primary_mnemonic_key, pm.program_cd,
  pm.prot_phase_cd, pm.prot_purpose_cd, pm.prot_status_cd,
  pm.prot_type_cd, pm.research_sponsor_org_id, pm.updt_dt_tm,
  pm.updt_id, pm.updt_task, pm.updt_applctx,
  pm.updt_cnt, pm.logical_domain_id)(SELECT
   seq(protocol_def_seq,nextval), pm1.accession_nbr_last, pm1.accession_nbr_prefix,
   pm1.accession_nbr_sig_dig, pm1.prescreen_type_flag, pm1.beg_effective_dt_tm,
   pm1.collab_site_org_id, pm1.display_ind, cnvtdatetime(script_date),
   pm1.initiating_service_cd, pm1.initiating_service_desc, pm1.parent_prot_master_id,
   pm1.participation_type_cd, pm1.peer_review_indicator_cd, pm1.prev_prot_master_id,
   pm1.primary_mnemonic, pm1.primary_mnemonic_key, pm1.program_cd,
   pm1.prot_phase_cd, pm1.prot_purpose_cd, pm1.prot_status_cd,
   pm1.prot_type_cd, pm1.research_sponsor_org_id, pm1.updt_dt_tm,
   pm1.updt_id, pm1.updt_task, pm1.updt_applctx,
   pm1.updt_cnt, pm1.logical_domain_id
   FROM prot_master pm1
   WHERE pm1.prot_master_id=prot_master_id)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Error inserting previous record into the prot_master table."
  SET reply->reason_for_failure = reply->status_data.subeventstatus[1].targetobjectvalue
  GO TO exit_failed
 ENDIF
 UPDATE  FROM prot_master pm
  SET pm.prot_status_cd = new_prot_status_cd, pm.updt_cnt = (pm.updt_cnt+ 1), pm.updt_dt_tm =
   cnvtdatetime(sysdate),
   pm.updt_id = reqinfo->updt_id, pm.updt_applctx = reqinfo->updt_applctx, pm.updt_task = reqinfo->
   updt_task,
   pm.beg_effective_dt_tm = cnvtdatetime(script_date)
  WHERE pm.prot_master_id=prot_master_id
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET reply->reason_for_failure = "Unable to update prot_master table"
  GO TO exit_failed
 ELSE
  GO TO exit_commit
 ENDIF
#exit_commit
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 GO TO exit_program
#exit_failed
 SET reply->status_data.status = "Z"
 SET reqinfo->commit_ind = 0
 GO TO exit_program
#exit_program
 CALL echo(reply->status_data.status)
 CALL echo(reply->reason_for_failure)
 SET last_mod = "010"
 SET mod_date = "July 30, 2019"
END GO
