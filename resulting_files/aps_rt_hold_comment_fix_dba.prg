CREATE PROGRAM aps_rt_hold_comment_fix:dba
 FREE SET temp
 RECORD temp(
   1 qual[*]
     2 hold_comment_long_text_id = f8
     2 report_id = f8
     2 hold_comment = c100
     2 updated_rt = c1
     2 updated_lt = c1
 )
 SET rt_cntr = 0
 SET max_recs_to_commit = 0
 SET snortrecs = "F"
 SET max_commit_recs = 500.000000
 SET max_commit_recs_whole = 500
 SET rt_commit_recs_whole = 0
 SET rt_commit_recs_whole = max_commit_recs_whole
 SELECT INTO "nl:"
  FROM report_task rt
  WHERE rt.report_id > 0
   AND rt.hold_comment > " "
   AND rt.hold_comment_long_text_id IN (null, 0)
  DETAIL
   max_recs_to_commit = (max_recs_to_commit+ 1), stat = alterlist(temp->qual,max_recs_to_commit),
   temp->qual[max_recs_to_commit].report_id = rt.report_id,
   temp->qual[max_recs_to_commit].hold_comment = rt.hold_comment, temp->qual[max_recs_to_commit].
   updated_rt = "F", temp->qual[max_recs_to_commit].updated_lt = "F"
  WITH nocounter, forupdate(rt)
 ;end select
 IF (curqual=0)
  SET snortrecs = "T"
  GO TO exit_script
 ENDIF
 SET rt_cntr = max_recs_to_commit
 SET count = 0
 WHILE (rt_cntr >= 1)
   IF (rt_cntr >= rt_commit_recs_whole)
    SET rt_cntr = (rt_cntr - rt_commit_recs_whole)
   ELSE
    SET rt_commit_recs_whole = rt_cntr
    SET rt_cntr = 0
   ENDIF
   FOR (seq_retrieve = (count+ 1) TO (count+ rt_commit_recs_whole))
    SELECT INTO "nl:"
     seq_nbr = seq(long_data_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      temp->qual[seq_retrieve].hold_comment_long_text_id = seq_nbr
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL echo("Failed to obtain an accurate sequence number.")
     GO TO exit_script
    ENDIF
   ENDFOR
   INSERT  FROM long_text lt,
     (dummyt d1  WITH seq = value(rt_commit_recs_whole))
    SET lt.long_text_id = temp->qual[(count+ d1.seq)].hold_comment_long_text_id, lt.updt_cnt = 0, lt
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
     cnvtdatetime(curdate,curtime3),
     lt.parent_entity_name = "REPORT_TASK", lt.parent_entity_id = temp->qual[(count+ d1.seq)].
     report_id, lt.long_text = temp->qual[(count+ d1.seq)].hold_comment,
     temp->qual[(count+ d1.seq)].updated_lt = "T"
    PLAN (d1
     WHERE (temp->qual[(count+ d1.seq)].updated_lt="F")
      AND (temp->qual[(count+ d1.seq)].report_id > 0))
     JOIN (lt)
    WITH nocounter
   ;end insert
   IF (curqual != value(rt_commit_recs_whole))
    CALL echo("Failed to update Report Task for hold comment.")
    GO TO exit_script
   ENDIF
   UPDATE  FROM report_task rt,
     (dummyt d1  WITH seq = value(rt_commit_recs_whole))
    SET rt.hold_comment_long_text_id = temp->qual[(count+ d1.seq)].hold_comment_long_text_id, rt
     .updt_dt_tm = cnvtdatetime(curdate,curtime), rt.updt_cnt = (rt.updt_cnt+ 1),
     temp->qual[(count+ d1.seq)].updated_rt = "T"
    PLAN (d1
     WHERE (temp->qual[(count+ d1.seq)].updated_rt="F"))
     JOIN (rt
     WHERE (temp->qual[(count+ d1.seq)].report_id=rt.report_id))
    WITH nocounter
   ;end update
   IF (curqual != value(rt_commit_recs_whole))
    CALL echo("Failed to update Long Text  for Report Task hold comment.")
    GO TO exit_script
   ENDIF
   COMMIT
   SET count = (count+ rt_commit_recs_whole)
 ENDWHILE
#exit_script
 ROLLBACK
END GO
