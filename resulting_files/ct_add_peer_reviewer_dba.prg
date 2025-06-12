CREATE PROGRAM ct_add_peer_reviewer:dba
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 CALL echo("before select")
 SET num_to_add = size(request->reviewers,5)
 FOR (i = 1 TO num_to_add)
   IF ((request->reviewers[i].reviewer_updt_cnt=- (9)))
    INSERT  FROM peer_reviewer pr
     SET pr.peer_reviewer_id = seq(protocol_def_seq,nextval), pr.prot_master_id = prot_master_id, pr
      .organization_id = request->reviewers[i].organization_id,
      pr.peer_reviewer_status_cd = request->reviewers[i].reviewer_status_cd, pr.updt_dt_tm =
      cnvtdatetime(curdate,curtime3), pr.updt_id = reqinfo->updt_id,
      pr.updt_applctx = reqinfo->updt_applctx, pr.updt_task = reqinfo->updt_task, pr.updt_cnt = 0
     WITH nocounter
    ;end insert
   ELSE
    CALL echo("before select - reviewers")
    SELECT INTO "nl:"
     pr.*
     FROM peer_reviewer pr
     WHERE pr.prot_master_id=prot_master_id
      AND (pr.organization_id=request->reviewers[i].organization_id)
     DETAIL
      cur_updt_cnt = pr.updt_cnt
     WITH nocounter, forupdate(pr)
    ;end select
    IF (curqual=0)
     SET reqinfo->commit_ind = 0
     SET reply->status_data.status = "F"
     GO TO exit_script
    ENDIF
    IF ((cur_updt_cnt != request->reviewers[i].reviewer_updt_cnt))
     SET reqinfo->commit_ind = 0
     SET reply->status_data.status = "F"
     GO TO exit_script
    ENDIF
    CALL echo("before update - reviewers")
    DELETE  FROM peer_reviewer pr
     WHERE pr.prot_master_id=prot_master_id
      AND (pr.organization_id=request->reviewers[i].organization_id)
     WITH nocounter
    ;end delete
    IF (curqual=0)
     SET reqinfo->commit_ind = 0
     SET reply->status_data.status = "F"
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 IF (curqual != 0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
 SET last_mod = "003"
 SET mod_date = "Sept 11, 2006"
#exit_script
END GO
