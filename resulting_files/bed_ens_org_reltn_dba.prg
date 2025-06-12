CREATE PROGRAM bed_ens_org_reltn:dba
 FREE SET reply
 RECORD reply(
   1 organizations[*]
     2 parent_org_id = f8
     2 rlist[*]
       3 org_org_reltn_id = f8
       3 child_org_id = f8
       3 reltn_type_code_value = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET child_list
 RECORD child_list(
   1 clist[*]
     2 org_id = f8
     2 reltn_type_code_value = f8
     2 comment_text = vc
     2 add_list[*]
       3 org_id = f8
 )
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 SET active_cd = 0.0
 SET inactive_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=48
    AND ((c.cdf_meaning="ACTIVE") OR (c.cdf_meaning="INACTIVE")) )
  DETAIL
   IF (c.cdf_meaning="ACTIVE")
    active_cd = c.code_value
   ELSE
    inactive_cd = c.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET req_cnt = size(request->organizations,5)
 SET rep_org_cnt = 0
 FOR (x = 1 TO req_cnt)
   SET rcnt = 0
   SET rcnt = size(request->organizations[x].rlist,5)
   SET ccnt = 0
   SET ccnt = size(request->organizations[x].clist,5)
   SET cnt = 0
   SET tot_cnt = 0
   SET rep_rlist_cnt = 0
   SET org_ind = 0
   FOR (j = 1 TO rcnt)
     IF ((request->organizations[x].rlist[j].action_flag=1))
      SET org_org_id = 0.0
      SELECT INTO "NL:"
       FROM org_org_reltn oor
       WHERE (oor.organization_id=request->organizations[x].parent_org_id)
        AND (oor.org_org_reltn_cd=request->organizations[x].rlist[j].reltn_type_code_value)
        AND (oor.related_org_id=request->organizations[x].rlist[j].child_org_id)
       DETAIL
        org_org_id = oor.org_org_reltn_id
       WITH nocounter
      ;end select
      IF (org_org_id > 0)
       UPDATE  FROM org_org_reltn oor
        SET oor.comment_text = request->organizations[x].rlist[j].comment_text, oor.active_ind = 1,
         oor.active_status_cd = active_cd,
         oor.active_status_dt_tm = cnvtdatetime(curdate,curtime), oor.active_status_prsnl_id =
         reqinfo->updt_id, oor.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
         oor.updt_dt_tm = cnvtdatetime(curdate,curtime), oor.updt_applctx = reqinfo->updt_applctx,
         oor.updt_id = reqinfo->updt_id,
         oor.updt_cnt = (oor.updt_cnt+ 1), oor.updt_task = reqinfo->updt_task
        WHERE oor.org_org_reltn_id=org_org_id
        WITH nocounter
       ;end update
       IF (curqual=0)
        SET error_flag = "Y"
        SET error_msg = concat("Error updating/inserting org_org_reltn for parent org  ",cnvtstring(
          request->organizations[x].parent_org_id))
        GO TO exit_script
       ENDIF
      ELSE
       SET org_org_id = 0.0
       SELECT INTO "nl:"
        y = seq(organization_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         org_org_id = cnvtreal(y)
        WITH format, counter
       ;end select
       INSERT  FROM org_org_reltn oor
        SET oor.org_org_reltn_id = org_org_id, oor.organization_id = request->organizations[x].
         parent_org_id, oor.org_org_reltn_cd = request->organizations[x].rlist[j].
         reltn_type_code_value,
         oor.related_org_id = request->organizations[x].rlist[j].child_org_id, oor.comment_text =
         request->organizations[x].rlist[j].comment_text, oor.active_ind = 1,
         oor.active_status_cd = active_cd, oor.active_status_dt_tm = cnvtdatetime(curdate,curtime),
         oor.active_status_prsnl_id = reqinfo->updt_id,
         oor.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), oor.end_effective_dt_tm =
         cnvtdatetime("31-DEC-2100 00:00:00.00"), oor.updt_dt_tm = cnvtdatetime(curdate,curtime),
         oor.updt_applctx = reqinfo->updt_applctx, oor.updt_id = reqinfo->updt_id, oor.updt_cnt = 0,
         oor.updt_task = reqinfo->updt_task
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET error_flag = "Y"
        SET error_msg = concat("Error inserting into org_org_reltn for parent org ",cnvtstring(
          request->organizations[x].parent_org_id))
        GO TO exit_script
       ENDIF
      ENDIF
      IF (org_ind=0)
       SET rep_org_cnt = (rep_org_cnt+ 1)
       SET stat = alterlist(reply->organizations,rep_org_cnt)
       SET reply->organizations[rep_org_cnt].parent_org_id = request->organizations[x].parent_org_id
       SET org_ind = 1
      ENDIF
      SET rep_rlist_cnt = (rep_rlist_cnt+ 1)
      SET stat = alterlist(reply->organizations[rep_org_cnt].rlist,rep_rlist_cnt)
      SET reply->organizations[rep_org_cnt].rlist[rep_rlist_cnt].child_org_id = request->
      organizations[x].rlist[j].child_org_id
      SET reply->organizations[rep_org_cnt].rlist[rep_rlist_cnt].org_org_reltn_id = org_org_id
      SET reply->organizations[rep_org_cnt].rlist[rep_rlist_cnt].reltn_type_code_value = request->
      organizations[x].rlist[j].reltn_type_code_value
     ELSEIF ((request->organizations[x].rlist[j].action_flag=2))
      UPDATE  FROM org_org_reltn oor
       SET oor.org_org_reltn_cd = request->organizations[x].rlist[j].reltn_type_code_value, oor
        .updt_dt_tm = cnvtdatetime(curdate,curtime), oor.updt_applctx = reqinfo->updt_applctx,
        oor.updt_id = reqinfo->updt_id, oor.updt_cnt = (oor.updt_cnt+ 1), oor.updt_task = reqinfo->
        updt_task
       WHERE (oor.org_org_reltn_id=request->organizations[x].rlist[j].org_org_reltn_id)
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Error updating org_org_reltn for parent org ",cnvtstring(request->
         organizations[x].parent_org_id))
       GO TO exit_script
      ENDIF
     ELSEIF ((request->organizations[x].rlist[j].action_flag=3))
      UPDATE  FROM org_org_reltn oor
       SET oor.active_ind = 0, oor.active_status_cd = inactive_cd, oor.active_status_dt_tm =
        cnvtdatetime(curdate,curtime),
        oor.active_status_prsnl_id = reqinfo->updt_id, oor.end_effective_dt_tm = cnvtdatetime(curdate,
         curtime), oor.updt_dt_tm = cnvtdatetime(curdate,curtime),
        oor.updt_applctx = reqinfo->updt_applctx, oor.updt_id = reqinfo->updt_id, oor.updt_cnt = (oor
        .updt_cnt+ 1),
        oor.updt_task = reqinfo->updt_task
       WHERE (oor.org_org_reltn_id=request->organizations[x].rlist[j].org_org_reltn_id)
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Error deleting from org_org_reltn for parent org ",cnvtstring(request
         ->organizations[x].parent_org_id))
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
   IF (ccnt > 0)
    SET stat = alterlist(child_list->clist,0)
    SELECT INTO "NL:"
     FROM org_org_reltn oor
     WHERE (oor.organization_id=request->organizations[x].parent_org_id)
     HEAD REPORT
      stat = alterlist(child_list->clist,50)
     DETAIL
      cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
      IF (cnt > 50)
       stat = alterlist(child_list->clist,(tot_cnt+ 50)), cnt = 1
      ENDIF
      child_list->clist[tot_cnt].org_id = oor.related_org_id, child_list->clist[tot_cnt].
      reltn_type_code_value = oor.org_org_reltn_cd, child_list->clist[tot_cnt].comment_text = oor
      .comment_text
     FOOT REPORT
      stat = alterlist(child_list->clist,tot_cnt)
     WITH nocounter
    ;end select
   ENDIF
   IF (ccnt > 0
    AND tot_cnt > 0)
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = ccnt),
      (dummyt d2  WITH seq = tot_cnt),
      org_org_reltn oor
     PLAN (d)
      JOIN (d2)
      JOIN (oor
      WHERE (oor.organization_id=request->organizations[x].clist[d.seq].org_id)
       AND (oor.org_org_reltn_cd=child_list->clist[d2.seq].reltn_type_code_value)
       AND (oor.related_org_id=child_list->clist[d2.seq].org_id))
     ORDER BY d2.seq, d.seq
     HEAD d2.seq
      acnt = 0, atot_cnt = 0, stat = alterlist(child_list->clist[d2.seq].add_list,20)
     DETAIL
      IF (oor.org_org_reltn_id=0)
       acnt = (acnt+ 1), atot_cnt = (atot_cnt+ 1)
       IF (acnt > 20)
        stat = alterlist(child_list->clist[d2.seq].add_list,(atot_cnt+ 20)), acnt = 1
       ENDIF
       child_list->clist[d2.seq].add_list[atot_cnt].org_id = request->organizations[x].clist[d.seq].
       org_id
      ENDIF
     FOOT  d2.seq
      stat = alterlist(child_list->clist[d2.seq].add_list,atot_cnt)
     WITH outerjoin = oor, outerjoin = d2, nocounter
    ;end select
    FOR (j = 1 TO tot_cnt)
     SET atot_cnt = size(child_list->clist[j].add_list,5)
     IF (atot_cnt > 0)
      INSERT  FROM org_org_reltn oor,
        (dummyt d2  WITH seq = atot_cnt)
       SET oor.org_org_reltn_id = seq(organization_seq,nextval), oor.organization_id = child_list->
        clist[j].add_list[d2.seq].org_id, oor.org_org_reltn_cd = child_list->clist[j].
        reltn_type_code_value,
        oor.related_org_id = child_list->clist[j].org_id, oor.comment_text = child_list->clist[j].
        comment_text, oor.active_ind = 1,
        oor.active_status_cd = active_cd, oor.active_status_dt_tm = cnvtdatetime(curdate,curtime),
        oor.active_status_prsnl_id = reqinfo->updt_id,
        oor.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), oor.end_effective_dt_tm =
        cnvtdatetime("31-DEC-2100 00:00:00.00"), oor.updt_dt_tm = cnvtdatetime(curdate,curtime),
        oor.updt_applctx = reqinfo->updt_applctx, oor.updt_id = reqinfo->updt_id, oor.updt_cnt = 0,
        oor.updt_task = reqinfo->updt_task
       PLAN (d2)
        JOIN (oor)
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat(
        "Error inserting into org_org_reltn for copying function with parent org ",cnvtstring(
         child_list->clist[j].org_id))
       GO TO exit_script
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  SET reply->error_msg = error_msg
 ENDIF
 CALL echorecord(reply)
END GO
