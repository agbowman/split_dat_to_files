CREATE PROGRAM aps_cs_spec_comments_fix:dba
 FREE SET temp
 RECORD temp(
   1 qual[*]
     2 spec_comments_long_text_id = f8
     2 case_specimen_id = f8
     2 special_comments = c100
     2 updated_cs = c1
     2 updated_lt = c1
 )
 SET cs_cntr = 0
 SET max_recs_to_commit = 0
 SET snocsrecs = "F"
 SET max_commit_recs = 500.000000
 SET max_commit_recs_whole = 500
 SET cs_commit_recs_whole = 0
 SET cs_commit_recs_whole = max_commit_recs_whole
 SELECT INTO "nl:"
  FROM case_specimen cs
  WHERE cs.case_specimen_id > 0
   AND cs.special_comments > " "
   AND cs.spec_comments_long_text_id IN (null, 0)
  DETAIL
   max_recs_to_commit = (max_recs_to_commit+ 1), stat = alterlist(temp->qual,max_recs_to_commit),
   temp->qual[max_recs_to_commit].case_specimen_id = cs.case_specimen_id,
   temp->qual[max_recs_to_commit].special_comments = cs.special_comments, temp->qual[
   max_recs_to_commit].updated_cs = "F", temp->qual[max_recs_to_commit].updated_lt = "F"
  WITH nocounter, forupdate(cs)
 ;end select
 IF (curqual=0)
  SET snocsrecs = "T"
  GO TO exit_script
 ENDIF
 SET cs_cntr = max_recs_to_commit
 SET count = 0
 WHILE (cs_cntr >= 1)
   IF (cs_cntr >= cs_commit_recs_whole)
    SET cs_cntr = (cs_cntr - cs_commit_recs_whole)
   ELSE
    SET cs_commit_recs_whole = cs_cntr
    SET cs_cntr = 0
   ENDIF
   FOR (seq_retrieve = (count+ 1) TO (count+ cs_commit_recs_whole))
    SELECT INTO "nl:"
     seq_nbr = seq(long_data_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      temp->qual[seq_retrieve].spec_comments_long_text_id = seq_nbr
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL echo("Failed to obtain an accurate sequence number.")
     GO TO exit_script
    ENDIF
   ENDFOR
   INSERT  FROM long_text lt,
     (dummyt d1  WITH seq = value(cs_commit_recs_whole))
    SET lt.long_text_id = temp->qual[(count+ d1.seq)].spec_comments_long_text_id, lt.updt_cnt = 0, lt
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
     cnvtdatetime(curdate,curtime3),
     lt.parent_entity_name = "CASE_SPECIMEN", lt.parent_entity_id = temp->qual[(count+ d1.seq)].
     case_specimen_id, lt.long_text = temp->qual[(count+ d1.seq)].special_comments,
     temp->qual[(count+ d1.seq)].updated_lt = "T"
    PLAN (d1
     WHERE (temp->qual[(count+ d1.seq)].updated_lt="F")
      AND (temp->qual[(count+ d1.seq)].case_specimen_id > 0))
     JOIN (lt)
    WITH nocounter
   ;end insert
   IF (curqual != value(cs_commit_recs_whole))
    CALL echo("Failed to update long_text table.")
    GO TO exit_script
   ENDIF
   UPDATE  FROM case_specimen cs,
     (dummyt d1  WITH seq = value(cs_commit_recs_whole))
    SET cs.spec_comments_long_text_id = temp->qual[(count+ d1.seq)].spec_comments_long_text_id, cs
     .updt_dt_tm = cnvtdatetime(curdate,curtime), cs.updt_cnt = (cs.updt_cnt+ 1),
     temp->qual[(count+ d1.seq)].updated_cs = "T"
    PLAN (d1
     WHERE (temp->qual[(count+ d1.seq)].updated_cs="F"))
     JOIN (cs
     WHERE (temp->qual[(count+ d1.seq)].case_specimen_id=cs.case_specimen_id))
    WITH nocounter
   ;end update
   IF (curqual != value(cs_commit_recs_whole))
    CALL echo("Failed to update case_specimen table.")
    GO TO exit_script
   ENDIF
   COMMIT
   SET count = (count+ cs_commit_recs_whole)
 ENDWHILE
#exit_script
 ROLLBACK
END GO
