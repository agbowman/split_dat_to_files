CREATE PROGRAM ct_chg_amd_assignment:dba
 SET false = 0
 SET true = 1
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET replace_error = 6
 SET delete_error = 7
 SET undelete_error = 8
 SET remove_error = 9
 SET attribute_error = 10
 SET lock_error = 11
 SET none_found = 12
 SET select_error = 13
 SET failed = false
 SET table_name = fillstring(50," ")
 RECORD reply(
   1 reg_id = f8
   1 prot_amendment_id = f8
   1 prot_amendment_nbr = i4
   1 revision_ind = i2
   1 revision_nbr_txt = c30
   1 off_study_dt_tm = dq8
   1 tx_completion_dt_tm = dq8
   1 assign_start_dt_tm = dq8
   1 updt_cnt = i4
   1 consent_released_dt_tm = dq8
   1 reason_for_failure = vc
   1 debug_string = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tempstring = fillstring(100,"")
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SET last_mod = "005"
 SET mod_date = "Apr 24, 2006"
 SET no_transfer = 0
 SET no_consent_transfer = 1
 SET safety_transfer = 2
 SET reconsent_transfer = 3
 SET cancel_transfer = 4
 SET meaning = fillstring(12,"")
 SET cdaa_ct_pt_amd_assignment_id = 0.0
 SET cdaa_status = fillstring(1," ")
 SET caaa_status = fillstring(1," ")
 RECORD pt_amd_assignment(
   1 reg_id = f8
   1 prot_amendment_id = f8
   1 transfer_checked_amendment_id = f8
   1 assign_start_dt_tm = dq8
   1 assign_end_dt_tm = dq8
 )
 SET updt_cnt = 0
 IF ((request->off_study_dt_tm=null))
  SET request->off_study_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00")
 ENDIF
 SELECT INTO "nl:"
  cpaa.ct_pt_amd_assignment_id
  FROM ct_pt_amd_assignment cpaa
  WHERE (cpaa.reg_id=request->reg_id)
   AND cpaa.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00.00")
   AND (cpaa.prot_amendment_id=request->prev_amendment_id)
  DETAIL
   cdaa_ct_pt_amd_assignment_id = cpaa.ct_pt_amd_assignment_id, pt_amd_assignment->prot_amendment_id
    = cpaa.prot_amendment_id, pt_amd_assignment->reg_id = cpaa.reg_id,
   pt_amd_assignment->transfer_checked_amendment_id = cpaa.transfer_checked_amendment_id,
   pt_amd_assignment->assign_start_dt_tm = cpaa.assign_start_dt_tm, updt_cnt = cpaa.updt_cnt
  WITH nocounter
 ;end select
 IF (curqual=1)
  IF ((updt_cnt != request->updt_cnt))
   SET reply->status_data.status = "F"
   SET reply->reason_for_failure = "Rows have changed since last access"
   GO TO exit_script
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->reason_for_failure = "Failure to get current amendment assignment"
  GO TO exit_script
 ENDIF
 EXECUTE ct_del_a_a_func
 IF (cdaa_status="L")
  SET reply->status_data.status = "F"
  SET reply->reason_for_failure = "Failure to lock row for update"
  GO TO exit_script
 ELSEIF (cdaa_status="F")
  SET reply->status_data.status = "F"
  SET reply->reason_for_failure = "Failure to logically delete row"
  GO TO exit_script
 ENDIF
 CALL echo("*** After deleting previous amendment assignment ***")
 IF ((request->transfer_type=no_transfer))
  SET pt_amd_assignment->transfer_checked_amendment_id = request->prot_amendment_id
  SET pt_amd_assignment->assign_end_dt_tm = cnvtdatetime(request->off_study_dt_tm)
  EXECUTE ct_add_a_a_func
 ELSEIF ((request->transfer_type IN (no_consent_transfer, safety_transfer, reconsent_transfer)))
  SET pt_amd_assignment->assign_end_dt_tm = cnvtdatetime(cnvtdate2(request->assign_start_dt_tm,
    "YYYYMMDD"),0)
  EXECUTE ct_add_a_a_func
  CALL echo("After adding a row with assign end_dt_tm set")
  SET pt_amd_assignment->assign_start_dt_tm = cnvtdatetime(cnvtdate2(request->assign_start_dt_tm,
    "YYYYMMDD"),0)
  SET pt_amd_assignment->assign_end_dt_tm = cnvtdatetime(request->off_study_dt_tm)
  SET pt_amd_assignment->prot_amendment_id = request->prot_amendment_id
  SET pt_amd_assignment->transfer_checked_amendment_id = request->prot_amendment_id
  EXECUTE ct_add_a_a_func
 ELSEIF ((request->transfer_type=cancel_transfer))
  CALL echo("**** CANCEL TRANSFER ****")
  SET reconsent_cd = 0.0
  SET stat = uar_get_meaning_by_codeset(17349,"RECONSENT",1,reconsent_cd)
  SELECT INTO "NL:"
   FROM pt_reg_consent_reltn prcr,
    prot_amendment p_am2,
    pt_consent pc
   PLAN (prcr
    WHERE (prcr.reg_id=request->reg_id))
    JOIN (pc
    WHERE pc.consent_id=prcr.consent_id
     AND pc.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND pc.reason_for_consent_cd=reconsent_cd
     AND pc.not_returned_reason_cd=0.0
     AND pc.consent_received_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (p_am2
    WHERE p_am2.prot_amendment_id=pc.prot_amendment_id
     AND (p_am2.amendment_nbr >
    (SELECT
     amendment_nbr
     FROM prot_amendment
     WHERE (prot_amendment_id=request->prot_amendment_id))))
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET reply->status_data.status = "F"
   SET reply->reason_for_failure =
   "Cannot cancel transfer. The patient is pending transfer to a higher amendment."
   GO TO exit_script
  ENDIF
  SET cnt = 0
  SELECT INTO "nl:"
   cpaa.ct_pt_amd_assignment_id
   FROM ct_pt_amd_assignment cpaa
   WHERE (cpaa.reg_id=request->reg_id)
    AND cpaa.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00.00")
    AND cpaa.assign_end_dt_tm != cnvtdatetime("31-dec-2100 00:00:00.00")
    AND cpaa.ct_pt_amd_assignment_id < cdaa_ct_pt_amd_assignment_id
   ORDER BY cpaa.assign_end_dt_tm DESC, cpaa.prot_amendment_id DESC
   HEAD REPORT
    cdaa_ct_pt_amd_assignment_id = cpaa.ct_pt_amd_assignment_id, pt_amd_assignment->prot_amendment_id
     = cpaa.prot_amendment_id, pt_amd_assignment->reg_id = cpaa.reg_id,
    pt_amd_assignment->assign_start_dt_tm = cpaa.assign_start_dt_tm
   DETAIL
    cnt += 1
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET reply->reason_for_failure = "Failure to get the previous assignment"
   GO TO exit_script
  ENDIF
  EXECUTE ct_del_a_a_func
  IF (cdaa_status="L")
   SET reply->status_data.status = "F"
   SET reply->reason_for_failure = "Failure to lock row for update"
   GO TO exit_script
  ELSEIF (cdaa_status="F")
   SET reply->status_data.status = "F"
   SET reply->reason_for_failure = "Failure to logically delete row"
   GO TO exit_script
  ENDIF
  SET pt_amd_assignment->transfer_checked_amendment_id = request->prot_amendment_id
  SET pt_amd_assignment->assign_end_dt_tm = cnvtdatetime(request->off_study_dt_tm)
  EXECUTE ct_add_a_a_func
 ENDIF
 SET cnt = 0
 SELECT INTO "nl:"
  ppr.pt_prot_re_id
  FROM pt_prot_reg ppr,
   ct_pt_amd_assignment cpaa,
   prot_amendment p_am,
   pt_reg_consent_reltn prcr,
   pt_consent pc,
   dummyt d
  PLAN (ppr
   WHERE (ppr.reg_id=request->reg_id)
    AND ppr.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00.00"))
   JOIN (cpaa
   WHERE cpaa.reg_id=ppr.reg_id
    AND cpaa.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00.00")
    AND cpaa.assign_end_dt_tm=ppr.off_study_dt_tm)
   JOIN (p_am
   WHERE p_am.prot_amendment_id=cpaa.prot_amendment_id)
   JOIN (d)
   JOIN (prcr
   WHERE prcr.reg_id=ppr.reg_id)
   JOIN (pc
   WHERE pc.consent_id=prcr.consent_id
    AND (pc.prot_amendment_id=request->prot_amendment_id))
  ORDER BY cpaa.assign_end_dt_tm DESC, p_am.prot_amendment_id DESC
  HEAD cpaa.assign_end_dt_tm
   reply->reg_id = ppr.reg_id, reply->off_study_dt_tm =
   IF (ppr.off_study_dt_tm=cnvtdatetime("31-dec-2100 00:00:00.00")) null
   ELSE ppr.off_study_dt_tm
   ENDIF
   , reply->tx_completion_dt_tm =
   IF (ppr.tx_completion_dt_tm=cnvtdatetime("31-dec-2100 00:00:00.00")) null
   ELSE ppr.tx_completion_dt_tm
   ENDIF
   ,
   reply->assign_start_dt_tm = cpaa.assign_start_dt_tm, reply->updt_cnt = cpaa.updt_cnt, reply->
   prot_amendment_nbr = p_am.amendment_nbr,
   reply->consent_released_dt_tm = pc.consent_released_dt_tm, reply->prot_amendment_id = p_am
   .prot_amendment_id, reply->revision_ind = p_am.revision_ind,
   reply->revision_nbr_txt = p_am.revision_nbr_txt
  DETAIL
   cnt += 1
  WITH outerjoin = d, dontcare = pc, nocounter
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 CALL echo(build("Status:",reply->status_data.status))
 IF ((reply->status_data.status="F"))
  CALL echo(build("reason for failure:",reply->reason_for_failure))
 ENDIF
 IF ((reply->status_data.status="F"))
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
