CREATE PROGRAM aps_chg_db_rpt_hist_groupings:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 exception_data[1]
     2 grouping_cd = f8
     2 grouping_desc = vc
 )
 SET reply->status_data.status = "F"
 SET cur_updt_cnt = 0
 SET nbr_of_groupings = size(request->qual,5)
 SET x = 1
 SET error_cnt = 0
 SET count1 = 0
 IF ( NOT (validate(upd_codeset_req,0)))
  RECORD upd_codeset_req(
    1 qual[*]
      2 code_value = f8
      2 code_set = i4
      2 cdf_meaning = c12
      2 display = c40
      2 description = c60
      2 definition = c100
      2 collation_seq = i4
      2 active_ind = i2
      2 cv_key = vc
  )
 ENDIF
 IF ( NOT (validate(upd_codeset_rep,0)))
  RECORD upd_codeset_rep(
    1 qual[*]
      2 code_value = f8
      2 cv_key = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
#start_of_script
 FOR (x = x TO nbr_of_groupings)
   SET stat = initrec(upd_codeset_req)
   SET stat = initrec(upd_codeset_rep)
   IF ((request->qual[x].action="A"))
    SET stat = alterlist(upd_codeset_req->qual,1)
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE cv.code_set=1311
      AND cv.display_key=cnvtupper(request->qual[x].grouping_short_desc)
     DETAIL
      upd_codeset_req->qual[1].code_value = cv.code_value
     WITH nocounter
    ;end select
    SET upd_codeset_req->qual[1].code_set = 1311
    SET upd_codeset_req->qual[1].display = request->qual[x].grouping_short_desc
    SET upd_codeset_req->qual[1].description = request->qual[x].grouping_long_desc
    SET upd_codeset_req->qual[1].active_ind = 1
    SET upd_codeset_req->qual[1].cv_key = cnvtstring(x)
    EXECUTE pcs_upd_code_values  WITH replace("REQUEST","UPD_CODESET_REQ"), replace("REPLY",
     "UPD_CODESET_REP")
    IF ((upd_codeset_rep->status_data.status="S"))
     SET request->qual[x].grouping_cd = upd_codeset_rep->qual[1].code_value
    ELSE
     CALL handle_errors("Insert","F","TABLE","CODE_VALUE, 1311")
     GO TO start_of_script
    ENDIF
   ELSEIF ((request->qual[x].action="C"))
    SET stat = alterlist(upd_codeset_req->qual,1)
    SET upd_codeset_req->qual[1].code_set = 1311
    SET upd_codeset_req->qual[1].code_value = request->qual[x].grouping_cd
    SET upd_codeset_req->qual[1].display = request->qual[x].grouping_short_desc
    SET upd_codeset_req->qual[1].description = request->qual[x].grouping_long_desc
    SET upd_codeset_req->qual[1].active_ind = 1
    SET upd_codeset_req->qual[1].cv_key = cnvtstring(x)
    EXECUTE pcs_upd_code_values  WITH replace("REQUEST","UPD_CODESET_REQ"), replace("REPLY",
     "UPD_CODESET_REP")
    IF ((upd_codeset_rep->status_data.status="F"))
     CALL handle_errors("UPDATE","F","TABLE","CODE_VALUE",1311)
     GO TO start_of_script
    ENDIF
   ENDIF
   IF ((request->qual[x].task_del_cnt > 0))
    DELETE  FROM report_history_grouping_r rhgr,
      (dummyt d  WITH seq = value(request->qual[x].task_del_cnt))
     SET rhgr.seq = 1
     PLAN (d)
      JOIN (rhgr
      WHERE (request->qual[x].grouping_cd=rhgr.grouping_cd)
       AND (request->qual[x].task_del_qual[d.seq].task_assay_cd=rhgr.task_assay_cd))
     WITH nocounter
    ;end delete
    IF ((curqual != request->qual[x].task_del_cnt))
     CALL handle_errors("DELETE","F","TABLE","SPEC_GROUP_R")
     GO TO start_of_script
    ENDIF
   ENDIF
   IF ((request->qual[x].task_add_cnt > 0))
    INSERT  FROM report_history_grouping_r rhgr,
      (dummyt d  WITH seq = value(request->qual[x].task_add_cnt))
     SET rhgr.grouping_cd = request->qual[x].grouping_cd, rhgr.task_assay_cd = request->qual[x].
      task_add_qual[d.seq].task_assay_cd, rhgr.collating_seq = request->qual[x].task_add_qual[d.seq].
      task_seq,
      rhgr.updt_dt_tm = cnvtdatetime(curdate,curtime), rhgr.updt_id = reqinfo->updt_id, rhgr
      .updt_task = reqinfo->updt_task,
      rhgr.updt_applctx = reqinfo->updt_applctx, rhgr.updt_cnt = 0
     PLAN (d)
      JOIN (rhgr)
     WITH nocounter
    ;end insert
    IF ((curqual != request->qual[x].task_add_cnt))
     CALL handle_errors("ADD","F","TABLE","SPEC_GROUP_R")
     GO TO start_of_script
    ENDIF
   ENDIF
   IF ((request->qual[x].task_chg_cnt > 0))
    SET cur_updt_cnt2[value(request->qual[x].task_chg_cnt)] = 0
    SELECT INTO "nl:"
     rhgr.*
     FROM report_history_grouping_r rhgr,
      (dummyt d  WITH seq = value(request->qual[x].task_chg_cnt))
     PLAN (d)
      JOIN (rhgr
      WHERE (rhgr.grouping_cd=request->qual[x].grouping_cd)
       AND (rhgr.task_assay_cd=request->qual[x].task_chg_qual[d.seq].task_assay_cd))
     HEAD REPORT
      count1 = 0
     DETAIL
      count1 += 1, cur_updt_cnt2[count1] = rhgr.updt_cnt
     WITH nocounter, forupdate(rhgr)
    ;end select
    IF ((count1 != request->qual[x].task_chg_cnt))
     CALL handle_errors("SELECT","F","TABLE","REPORT_HISTORY_GROUPING_R")
     GO TO start_of_script
    ENDIF
    FOR (xx = 1 TO request->qual[x].task_chg_cnt)
      IF ((request->qual[x].task_chg_qual[xx].updt_cnt != cur_updt_cnt2[xx]))
       CALL handle_errors("LOCK","F","TABLE","REPORT_HISTORY_GROUPING_R")
       GO TO start_of_script
      ENDIF
    ENDFOR
    UPDATE  FROM report_history_grouping_r rhgr,
      (dummyt d  WITH seq = value(request->qual[x].task_chg_cnt))
     SET rhgr.collating_seq = request->qual[x].task_chg_qual[d.seq].task_seq, rhgr.updt_dt_tm =
      cnvtdatetime(curdate,curtime), rhgr.updt_id = reqinfo->updt_id,
      rhgr.updt_task = reqinfo->updt_task, rhgr.updt_applctx = reqinfo->updt_applctx, rhgr.updt_cnt
       = (rhgr.updt_cnt+ 1)
     PLAN (d)
      JOIN (rhgr
      WHERE (rhgr.grouping_cd=request->qual[x].grouping_cd)
       AND (rhgr.task_assay_cd=request->qual[x].task_chg_qual[d.seq].task_assay_cd))
     WITH nocounter
    ;end update
    IF ((curqual != request->qual[x].task_chg_cnt))
     CALL handle_errors("UPDATE","F","TABLE","REPORT_HISTORY_GROUPING_R")
     GO TO start_of_script
    ENDIF
   ENDIF
   IF ((request->qual[x].task_add_cnt=0)
    AND (request->qual[x].task_del_cnt > 0))
    SET stat = initrec(upd_codeset_req)
    SELECT INTO "nl:"
     request->qual[x].grouping_cd
     FROM report_history_grouping_r r
     WHERE (r.grouping_cd=request->qual[x].grouping_cd)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = alterlist(upd_codeset_req->qual,1)
     SET upd_codeset_req->qual[1].code_set = 1311
     SET upd_codeset_req->qual[1].code_value = request->qual[x].grouping_cd
     SET upd_codeset_req->qual[1].display = request->qual[x].grouping_short_desc
     SET upd_codeset_req->qual[1].description = request->qual[x].grouping_long_desc
     SET upd_codeset_req->qual[1].active_ind = 0
     SET upd_codeset_req->qual[1].cv_key = cnvtstring(x)
    ENDIF
    IF (size(upd_codeset_req->qual,5) > 0)
     EXECUTE pcs_upd_code_values  WITH replace("REQUEST","UPD_CODESET_REQ"), replace("REPLY",
      "UPD_CODESET_REP")
     IF ((upd_codeset_rep->status_data.status="F"))
      CALL handle_errors("UPDATE","F","TABLE","CODE_VALUE",1311)
      GO TO start_of_script
     ENDIF
    ENDIF
   ENDIF
   COMMIT
 ENDFOR
#exit_script
 IF (error_cnt > 0)
  IF (error_cnt=nbr_of_groupings)
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "P"
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   ROLLBACK
   SET error_cnt += 1
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
    SET stat = alter(reply->exception_data,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
   IF ((request->qual[x].action="A"))
    SET reply->exception_data[error_cnt].grouping_desc = request->qual[x].grouping_long_desc
   ELSE
    SET reply->exception_data[error_cnt].grouping_cd = request->qual[x].grouping_cd
   ENDIF
   SET x += 1
 END ;Subroutine
END GO
