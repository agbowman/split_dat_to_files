CREATE PROGRAM aps_update_acc_templates:dba
 FREE SET temp
 RECORD temp(
   1 qual[*]
     2 template_detail_id = f8
     2 updated_template = c1
 )
 SET aatd_cntr = 0
 SET max_recs_to_commit = 0
 SET snoaatdrecs = "F"
 SET max_commit_recs = 500.000000
 SET max_commit_recs_whole = 500
 SET aatd_commit_recs_whole = 0
 SET aatd_commit_recs_whole = max_commit_recs_whole
 SELECT INTO "nl:"
  FROM ap_accn_template_detail aatd
  WHERE aatd.template_detail_id > 0
   AND aatd.carry_forward_ind=1
   AND aatd.carry_forward_spec_ind=0
  DETAIL
   max_recs_to_commit = (max_recs_to_commit+ 1), stat = alterlist(temp->qual,max_recs_to_commit),
   temp->qual[max_recs_to_commit].template_detail_id = aatd.template_detail_id,
   temp->qual[max_recs_to_commit].updated_template = "F"
  WITH nocounter, forupdate(aatd)
 ;end select
 IF (curqual=0)
  SET snoaatdrecs = "T"
  GO TO exit_script
 ENDIF
 SET aatd_cntr = max_recs_to_commit
 SET count = 0
 WHILE (aatd_cntr >= 1)
   IF (aatd_cntr >= aatd_commit_recs_whole)
    SET aatd_cntr = (aatd_cntr - aatd_commit_recs_whole)
   ELSE
    SET aatd_commit_recs_whole = aatd_cntr
    SET aatd_cntr = 0
   ENDIF
   UPDATE  FROM ap_accn_template_detail aatd,
     (dummyt d1  WITH seq = value(aatd_commit_recs_whole))
    SET aatd.carry_forward_spec_ind = 1, aatd.updt_dt_tm = cnvtdatetime(curdate,curtime), aatd
     .updt_cnt = (aatd.updt_cnt+ 1),
     temp->qual[(count+ d1.seq)].updated_template = "T"
    PLAN (d1
     WHERE (temp->qual[(count+ d1.seq)].updated_template="F"))
     JOIN (aatd
     WHERE (temp->qual[(count+ d1.seq)].template_detail_id=aatd.template_detail_id))
    WITH nocounter
   ;end update
   IF (curqual != value(aatd_commit_recs_whole))
    CALL echo("Failed to update ap_accn_template_detail table.")
    GO TO exit_script
   ENDIF
   COMMIT
   SET count = (count+ aatd_commit_recs_whole)
 ENDWHILE
#exit_script
 ROLLBACK
END GO
