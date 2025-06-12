CREATE PROGRAM aps_lookback_followup:dba
 RECORD temp(
   1 person_id = f8
   1 event_id = f8
   1 term_ind = i2
   1 term_reason_cd = f8
   1 accession_nbr = c21
   1 case_id = f8
   1 type_qual[*]
     2 term_ind = i2
     2 term_reason_cd = f8
     2 catalog_cd = f8
     2 start_date = dq8
 )
#script
 SET failure = 0
 SET dtermlongtextid = 0.0
 SET verified_cd = 0.0
 SET corrected_cd = 0.0
 SET signinproc_cd = 0.0
 SET csigninproc_cd = 0.0
 SET cdf_meaning = fillstring(12," ")
 SELECT INTO "nl:"
  cv.cdf_meaning
  FROM code_value cv
  WHERE 1305=cv.code_set
   AND cv.cdf_meaning IN ("VERIFIED", "CORRECTED", "SIGNINPROC", "CSIGNINPROC")
  DETAIL
   CASE (cv.cdf_meaning)
    OF "VERIFIED":
     verified_cd = cv.code_value
    OF "CORRECTED":
     corrected_cd = cv.code_value
    OF "SIGNINPROC":
     signinproc_cd = cv.code_value
    OF "CSIGNINPROC":
     csigninproc_cd = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failure = 1
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  fte.followup_event_id, fttp.auto_termination_ind
  FROM ap_ft_event fte,
   ap_ft_term_proc fttp
  PLAN (fte
   WHERE (request->case_id=fte.case_id)
    AND fte.term_dt_tm = null)
   JOIN (fttp
   WHERE fte.followup_type_cd=fttp.followup_tracking_type_cd)
  HEAD REPORT
   tcnt = 0, temp->event_id = fte.followup_event_id, temp->person_id = fte.person_id
  DETAIL
   tcnt = (tcnt+ 1), stat = alterlist(temp->type_qual,tcnt), temp->type_qual[tcnt].term_ind = fttp
   .auto_termination_ind,
   temp->type_qual[tcnt].term_reason_cd = fttp.auto_termination_reason_cd, temp->type_qual[tcnt].
   catalog_cd = fttp.catalog_cd, temp->type_qual[tcnt].start_date = datetimeadd(sysdate,(fttp
    .look_back_days * - (1)))
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failure = 1
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  pc.person_id, pc.accession_nbr, d.seq,
  cr.catalog_cd, pc2.accession_nbr, col_date = pc2.case_collect_dt_tm"mm/dd/yy;;d"
  FROM pathology_case pc,
   (dummyt d  WITH seq = value(size(temp->type_qual,5))),
   case_report cr,
   pathology_case pc2
  PLAN (pc
   WHERE (temp->person_id=pc.person_id)
    AND (request->case_id != pc.case_id)
    AND pc.cancel_dt_tm = null)
   JOIN (d)
   JOIN (cr
   WHERE pc.case_id=cr.case_id
    AND (temp->type_qual[d.seq].catalog_cd=cr.catalog_cd)
    AND cr.status_cd IN (verified_cd, corrected_cd, signinproc_cd, csigninproc_cd))
   JOIN (pc2
   WHERE cr.case_id=pc2.case_id
    AND cnvtdatetime(temp->type_qual[d.seq].start_date) <= pc.case_collect_dt_tm)
  DETAIL
   temp->term_ind = temp->type_qual[d.seq].term_ind, temp->term_reason_cd = temp->type_qual[d.seq].
   term_reason_cd, temp->accession_nbr = pc2.accession_nbr,
   temp->case_id = pc2.case_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failure = 1
  GO TO exit_script
 ENDIF
 IF ((temp->term_ind=1))
  SELECT INTO "nl:"
   seq_nbr = seq(long_data_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    dtermlongtextid = seq_nbr
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET failure = 1
   GO TO exit_script
  ENDIF
  INSERT  FROM long_text lt
   SET lt.long_text_id = dtermlongtextid, lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
    updt_applctx,
    lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
    cnvtdatetime(curdate,curtime3),
    lt.active_status_prsnl_id = reqinfo->updt_id, lt.parent_entity_name = "AP_FT_EVENT", lt
    .parent_entity_id = temp->event_id,
    lt.long_text = "AUTO TERMINATED BY SYSTEM (verify of terminating procedure)"
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failure = 1
   GO TO exit_script
  ENDIF
  UPDATE  FROM ap_ft_event fte
   SET fte.term_id = 0, fte.term_dt_tm = cnvtdatetime(curdate,curtime), fte.term_reason_cd = temp->
    term_reason_cd,
    fte.term_accession_nbr = temp->accession_nbr, fte.term_long_text_id = dtermlongtextid, fte
    .updt_dt_tm = cnvtdatetime(curdate,curtime),
    fte.updt_id = reqinfo->updt_id, fte.updt_task = reqinfo->updt_task, fte.updt_applctx = reqinfo->
    updt_applctx,
    fte.updt_cnt = (fte.updt_cnt+ 1)
   WHERE (temp->event_id=fte.followup_event_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failure = 1
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   ftcl.followup_event_id
   FROM ft_term_candidate_list ftcl
   WHERE (temp->event_id=ftcl.followup_event_id)
   WITH forupdate(ftcl)
  ;end select
  IF (curqual > 0)
   DELETE  FROM ft_term_candidate_list ftcl
    WHERE (temp->event_id=ftcl.followup_event_id)
    WITH nocounter
   ;end delete
   IF (curqual=0)
    SET failure = 1
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 IF ((temp->term_ind=0))
  INSERT  FROM ft_term_candidate_list ftcl
   SET ftcl.followup_event_id = temp->event_id, ftcl.review_case_id = temp->case_id, ftcl.updt_dt_tm
     = cnvtdatetime(curdate,curtime),
    ftcl.updt_id = reqinfo->updt_id, ftcl.updt_task = reqinfo->updt_task, ftcl.updt_applctx = reqinfo
    ->updt_applctx,
    ftcl.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failure = 1
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failure=1)
  ROLLBACK
  CALL echo(">>>>> ROLLBACK >>>>>")
 ELSE
  COMMIT
  CALL echo(">>>>> COMMIT >>>>>")
 ENDIF
END GO
