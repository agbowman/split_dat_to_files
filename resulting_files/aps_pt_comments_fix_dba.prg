CREATE PROGRAM aps_pt_comments_fix:dba
 FREE SET temp
 RECORD temp(
   1 qual[*]
     2 comments_long_text_id = f8
     2 processing_task_id = f8
     2 comments = vc
     2 updated_pt = c1
     2 updated_lt = c1
 )
 SET pt_cntr = 0
 SET max_recs_to_commit = 0
 SET snoptrecs = "F"
 SET max_commit_recs = 500.000000
 SET max_commit_recs_whole = 500
 SET pt_commit_recs_whole = 0
 SET pt_commit_recs_whole = max_commit_recs_whole
 SELECT INTO "nl:"
  FROM processing_task pt
  WHERE pt.processing_task_id > 0
   AND pt.comments > " "
   AND pt.comments_long_text_id IN (null, 0)
  DETAIL
   max_recs_to_commit = (max_recs_to_commit+ 1), stat = alterlist(temp->qual,max_recs_to_commit),
   temp->qual[max_recs_to_commit].processing_task_id = pt.processing_task_id,
   temp->qual[max_recs_to_commit].comments = pt.comments, temp->qual[max_recs_to_commit].updated_pt
    = "F", temp->qual[max_recs_to_commit].updated_lt = "F"
  WITH nocounter, forupdate(pt)
 ;end select
 IF (curqual=0)
  SET snoptrecs = "T"
  GO TO exit_script
 ENDIF
 SET pt_cntr = max_recs_to_commit
 SET count = 0
 WHILE (pt_cntr >= 1)
   IF (pt_cntr >= pt_commit_recs_whole)
    SET pt_cntr = (pt_cntr - pt_commit_recs_whole)
   ELSE
    SET pt_commit_recs_whole = pt_cntr
    SET pt_cntr = 0
   ENDIF
   FOR (seq_retrieve = (count+ 1) TO (count+ pt_commit_recs_whole))
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
     (dummyt d1  WITH seq = value(pt_commit_recs_whole))
    SET lt.long_text_id = temp->qual[(count+ d1.seq)].comments_long_text_id, lt.updt_cnt = 0, lt
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
     cnvtdatetime(curdate,curtime3),
     lt.parent_entity_name = "PROCESSING_TASK", lt.parent_entity_id = temp->qual[(count+ d1.seq)].
     processing_task_id, lt.long_text = temp->qual[(count+ d1.seq)].comments,
     temp->qual[(count+ d1.seq)].updated_lt = "T"
    PLAN (d1
     WHERE (temp->qual[(count+ d1.seq)].updated_lt="F")
      AND (temp->qual[(count+ d1.seq)].processing_task_id > 0))
     JOIN (lt)
    WITH nocounter
   ;end insert
   IF (curqual != value(pt_commit_recs_whole))
    CALL echo("Failed to update long_text table.")
    GO TO exit_script
   ENDIF
   UPDATE  FROM processing_task pt,
     (dummyt d1  WITH seq = value(pt_commit_recs_whole))
    SET pt.comments_long_text_id = temp->qual[(count+ d1.seq)].comments_long_text_id, pt.updt_dt_tm
      = cnvtdatetime(curdate,curtime), pt.updt_cnt = (pt.updt_cnt+ 1),
     temp->qual[(count+ d1.seq)].updated_pt = "T"
    PLAN (d1
     WHERE (temp->qual[(count+ d1.seq)].updated_pt="F"))
     JOIN (pt
     WHERE (temp->qual[(count+ d1.seq)].processing_task_id=pt.processing_task_id))
    WITH nocounter
   ;end update
   IF (curqual != value(pt_commit_recs_whole))
    CALL echo("Failed to update processing_task table.")
    GO TO exit_script
   ENDIF
   COMMIT
   SET count = (count+ pt_commit_recs_whole)
 ENDWHILE
#exit_script
 ROLLBACK
END GO
