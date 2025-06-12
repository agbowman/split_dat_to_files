CREATE PROGRAM aps_review_followup:dba
 RECORD temp(
   1 term_ind = i2
   1 event_id = f8
   1 term_reason_cd = f8
 )
#script
 SET failure = 0
 SET temp->term_ind = 0
 SET temp->event_id = 0.0
 SET temp->term_reason_cd = 0.0
 CALL echo("^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-")
 CALL echo("^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-")
 CALL echo(" ")
 CALL echo("     request->person_id    > ",0)
 CALL echo(request->person_id)
 CALL echo("     request->case_id      > ",0)
 CALL echo(request->case_id)
 CALL echo("     request->catalog_cd   > ",0)
 CALL echo(request->catalog_cd)
 CALL echo("     request->accession_nbr> ",0)
 CALL echo(request->accession_nbr)
 SELECT INTO "nl:"
  fte.followup_event_id, fttp.auto_termination_ind
  FROM ap_ft_event fte,
   ap_ft_term_proc fttp
  PLAN (fte
   WHERE (request->person_id=fte.person_id)
    AND (request->case_id != fte.case_id)
    AND fte.term_dt_tm = null)
   JOIN (fttp
   WHERE fte.followup_type_cd=fttp.followup_tracking_type_cd
    AND (request->catalog_cd=fttp.catalog_cd))
  DETAIL
   temp->term_ind = fttp.auto_termination_ind, temp->event_id = fte.followup_event_id, temp->
   term_reason_cd = fttp.auto_termination_reason_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("     <<<<<<<<<<<failure<<<<<<<<<<<")
  CALL echo("     <<<<<<<<<<<failure<<<<<<<<<<<")
  CALL echo("     11111111111111111111111111111")
  SET failure = 1
  GO TO exit_script
 ENDIF
 CALL echo("^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-")
 CALL echo("^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-")
 CALL echo("     temp->term_ind        > ",0)
 CALL echo(temp->term_ind)
 CALL echo("     temp->event_id        > ",0)
 CALL echo(temp->event_id)
 CALL echo("     temp->term_reason_cd  > ",0)
 CALL echo(temp->term_reason_cd)
 CALL echo("      ")
 IF ((temp->term_ind=1))
  DECLARE term_long_text_id = f8 WITH protect, noconstant(0.0)
  SELECT INTO "nl:"
   seq_nbr = seq(long_data_seq,nextval)
   FROM dual
   DETAIL
    term_long_text_id = seq_nbr
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET failure = 1
   GO TO exit_script
  ENDIF
  INSERT  FROM long_text lt
   SET lt.long_text_id = term_long_text_id, lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
    updt_applctx,
    lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
    cnvtdatetime(curdate,curtime3),
    lt.active_status_prsnl_id = reqinfo->updt_id, lt.parent_entity_name = "AP_FT_EVENT", lt
    .parent_entity_id = temp->event_id,
    lt.long_text = "AUTO TERMINATED BY SYSTEM"
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failure = 1
   GO TO exit_script
  ENDIF
  UPDATE  FROM ap_ft_event fte
   SET fte.term_id = 0.0, fte.term_dt_tm = cnvtdatetime(curdate,curtime), fte.term_reason_cd = temp->
    term_reason_cd,
    fte.term_long_text_id = term_long_text_id, fte.term_accession_nbr = request->accession_nbr, fte
    .term_comment = "AUTO TERMINATED BY SYSTEM (verify of terminating procedure)",
    fte.updt_dt_tm = cnvtdatetime(curdate,curtime), fte.updt_id = reqinfo->updt_id, fte.updt_task =
    reqinfo->updt_task,
    fte.updt_applctx = reqinfo->updt_applctx, fte.updt_cnt = (fte.updt_cnt+ 1)
   WHERE (temp->event_id=fte.followup_event_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL echo("     <<<<<<<<<<<failure<<<<<<<<<<<")
   CALL echo("     <<<<<<<<<<<failure<<<<<<<<<<<")
   CALL echo("     22222222222222222222222222222")
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
    CALL echo("     <<<<<<<<<<<failure<<<<<<<<<<<")
    CALL echo("     <<<<<<<<<<<failure<<<<<<<<<<<")
    CALL echo("     33333333333333333333333333333")
    SET failure = 1
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 IF ((temp->term_ind=0))
  SELECT INTO "nl:"
   ftcl.followup_event_id, ftcl.review_case_id
   FROM ft_term_candidate_list ftcl
   WHERE (ftcl.review_case_id=request->case_id)
    AND (ftcl.followup_event_id=temp->event_id)
   WITH nocounter
  ;end select
  INSERT  FROM ft_term_candidate_list ftcl
   SET ftcl.followup_event_id = temp->event_id, ftcl.review_case_id = request->case_id, ftcl
    .updt_dt_tm = cnvtdatetime(curdate,curtime),
    ftcl.updt_id = reqinfo->updt_id, ftcl.updt_task = reqinfo->updt_task, ftcl.updt_applctx = reqinfo
    ->updt_applctx,
    ftcl.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failure = 1
   CALL echo("     <<<<<<<<<<<failure<<<<<<<<<<<")
   CALL echo("     <<<<<<<<<<<failure<<<<<<<<<<<")
   CALL echo("     44444444444444444444444444444")
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failure=1)
  ROLLBACK
  CALL echo("     <<<<< ROLLBACK <<<<<")
 ELSE
  COMMIT
  CALL echo("     >>>>> COMMIT >>>>>")
 ENDIF
END GO
