CREATE PROGRAM aps_pc_comments_fix:dba
 FREE SET temp
 RECORD temp(
   1 qual[*]
     2 comments_long_text_id = f8
     2 case_id = f8
     2 comments = c100
     2 updated_pc = c1
     2 updated_lt = c1
 )
 SET pc_cntr = 0
 SET lt_cntr = 0
 SET max_recs_to_commit = 0
 SET snopcrecs = "F"
 SET max_commit_recs = 500.000000
 SET max_commit_recs_whole = 500
 SET pc_commit_recs_whole = 0
 SET lt_commit_recs_whole = 0
 SET pc_commit_recs_whole = max_commit_recs_whole
 SET lt_commit_recs_whole = max_commit_recs_whole
 SELECT INTO "nl:"
  FROM pathology_case pc
  WHERE pc.case_id > 0
   AND pc.comments > " "
   AND pc.comments_long_text_id IN (null, 0)
  DETAIL
   max_recs_to_commit = (max_recs_to_commit+ 1), stat = alterlist(temp->qual,max_recs_to_commit),
   temp->qual[max_recs_to_commit].case_id = pc.case_id,
   temp->qual[max_recs_to_commit].comments = pc.comments, temp->qual[max_recs_to_commit].updated_pc
    = "F", temp->qual[max_recs_to_commit].updated_lt = "F"
  WITH nocounter, forupdate(pc)
 ;end select
 IF (curqual=0)
  SET snopcrecs = "T"
  GO TO exit_script
 ENDIF
 SET pc_cntr = max_recs_to_commit
 SET count = 0
 WHILE (pc_cntr >= 1)
   IF (pc_cntr >= pc_commit_recs_whole)
    SET pc_cntr = (pc_cntr - pc_commit_recs_whole)
   ELSE
    SET pc_commit_recs_whole = pc_cntr
    SET pc_cntr = 0
   ENDIF
   FOR (seq_retrieve = (count+ 1) TO (count+ pc_commit_recs_whole))
    SELECT INTO "nl:"
     seq_nbr = seq(long_data_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      temp->qual[seq_retrieve].comments_long_text_id = seq_nbr
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL echo("Failed to obtain an accurate sequence number.")
     GO TO exit_script
    ENDIF
   ENDFOR
   INSERT  FROM long_text lt,
     (dummyt d1  WITH seq = value(pc_commit_recs_whole))
    SET lt.long_text_id = temp->qual[(count+ d1.seq)].comments_long_text_id, lt.updt_cnt = 0, lt
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
     cnvtdatetime(curdate,curtime3),
     lt.parent_entity_name = "PATHOLOGY_CASE", lt.parent_entity_id = temp->qual[(count+ d1.seq)].
     case_id, lt.long_text = temp->qual[(count+ d1.seq)].comments,
     temp->qual[(count+ d1.seq)].updated_lt = "T"
    PLAN (d1
     WHERE (temp->qual[(count+ d1.seq)].updated_lt="F")
      AND (temp->qual[(count+ d1.seq)].case_id > 0))
     JOIN (lt)
    WITH nocounter
   ;end insert
   IF (curqual != value(pc_commit_recs_whole))
    CALL echo("Failed to insert into long_text table.")
    GO TO exit_script
   ENDIF
   UPDATE  FROM pathology_case pc,
     (dummyt d1  WITH seq = value(pc_commit_recs_whole))
    SET pc.comments_long_text_id = temp->qual[(count+ d1.seq)].comments_long_text_id, pc.updt_dt_tm
      = cnvtdatetime(curdate,curtime), pc.updt_cnt = (pc.updt_cnt+ 1),
     temp->qual[(count+ d1.seq)].updated_pc = "T"
    PLAN (d1
     WHERE (temp->qual[(count+ d1.seq)].updated_pc="F"))
     JOIN (pc
     WHERE (temp->qual[(count+ d1.seq)].case_id=pc.case_id))
    WITH nocounter
   ;end update
   IF (curqual != value(pc_commit_recs_whole))
    CALL echo("Failed to update pathology_case table.")
    GO TO exit_script
   ENDIF
   COMMIT
   SET count = (count+ pc_commit_recs_whole)
 ENDWHILE
#exit_script
 ROLLBACK
END GO
