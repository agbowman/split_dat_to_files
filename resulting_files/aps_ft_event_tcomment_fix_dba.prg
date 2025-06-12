CREATE PROGRAM aps_ft_event_tcomment_fix:dba
 FREE SET temp
 RECORD temp(
   1 qual[*]
     2 term_long_text_id = f8
     2 followup_event_id = f8
     2 term_comment = c100
     2 updated_afe = c1
     2 updated_lt = c1
 )
 SET afe_cntr = 0
 SET max_recs_to_commit = 0
 SET snoaferecs = "F"
 SET max_commit_recs = 500.000000
 SET max_commit_recs_whole = 500
 SET afe_commit_recs_whole = 0
 SET afe_commit_recs_whole = max_commit_recs_whole
 SELECT INTO "nl:"
  FROM ap_ft_event afe
  WHERE afe.followup_event_id > 0
   AND afe.term_comment > " "
   AND afe.term_long_text_id IN (null, 0)
  DETAIL
   max_recs_to_commit = (max_recs_to_commit+ 1), stat = alterlist(temp->qual,max_recs_to_commit),
   temp->qual[max_recs_to_commit].followup_event_id = afe.followup_event_id,
   temp->qual[max_recs_to_commit].term_comment = afe.term_comment, temp->qual[max_recs_to_commit].
   updated_afe = "F", temp->qual[max_recs_to_commit].updated_lt = "F"
  WITH nocounter, forupdate(afe)
 ;end select
 IF (curqual=0)
  SET snoaferecs = "T"
  GO TO exit_script
 ENDIF
 SET afe_cntr = max_recs_to_commit
 SET count = 0
 WHILE (afe_cntr >= 1)
   IF (afe_cntr >= afe_commit_recs_whole)
    SET afe_cntr = (afe_cntr - afe_commit_recs_whole)
   ELSE
    SET afe_commit_recs_whole = afe_cntr
    SET afe_cntr = 0
   ENDIF
   FOR (seq_retrieve = (count+ 1) TO (count+ afe_commit_recs_whole))
    SELECT INTO "nl:"
     seq_nbr = seq(long_data_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      temp->qual[seq_retrieve].term_long_text_id = seq_nbr
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL echo("Failed to obtain an accurate sequence number.")
     GO TO exit_script
    ENDIF
   ENDFOR
   INSERT  FROM long_text lt,
     (dummyt d1  WITH seq = value(afe_commit_recs_whole))
    SET lt.long_text_id = temp->qual[(count+ d1.seq)].term_long_text_id, lt.updt_cnt = 0, lt
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
     cnvtdatetime(curdate,curtime3),
     lt.parent_entity_name = "AP_FT_EVENT", lt.parent_entity_id = temp->qual[(count+ d1.seq)].
     followup_event_id, lt.long_text = temp->qual[(count+ d1.seq)].term_comment,
     temp->qual[(count+ d1.seq)].updated_lt = "T"
    PLAN (d1
     WHERE (temp->qual[(count+ d1.seq)].updated_lt="F")
      AND (temp->qual[(count+ d1.seq)].followup_event_id > 0))
     JOIN (lt)
    WITH nocounter
   ;end insert
   IF (curqual != value(afe_commit_recs_whole))
    CALL echo("Failed to update long_text table.")
    GO TO exit_script
   ENDIF
   UPDATE  FROM ap_ft_event afe,
     (dummyt d1  WITH seq = value(afe_commit_recs_whole))
    SET afe.term_long_text_id = temp->qual[(count+ d1.seq)].term_long_text_id, afe.updt_dt_tm =
     cnvtdatetime(curdate,curtime), afe.updt_cnt = (afe.updt_cnt+ 1),
     temp->qual[(count+ d1.seq)].updated_afe = "T"
    PLAN (d1
     WHERE (temp->qual[(count+ d1.seq)].updated_afe="F"))
     JOIN (afe
     WHERE (temp->qual[(count+ d1.seq)].followup_event_id=afe.followup_event_id))
    WITH nocounter
   ;end update
   IF (curqual != value(afe_commit_recs_whole))
    CALL echo("Failed to update ap_ft_event table.")
    GO TO exit_script
   ENDIF
   COMMIT
   SET count = (count+ afe_commit_recs_whole)
 ENDWHILE
#exit_script
 ROLLBACK
END GO
