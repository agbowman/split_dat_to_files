CREATE PROGRAM dm2_update_xnt_job:dba
 IF ((validate(request->job_id,- (1))=- (1)))
  RECORD request(
    1 job_id = f8
    1 job_name = vc
    1 active_flag = i2
    1 tokens[*]
      2 token_str = vc
      2 token_value = vc
  )
 ENDIF
 IF (validate(reply->status_data.status,"NONE")="NONE")
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD duxj_tokens
 RECORD duxj_tokens(
   1 data_cnt = i4
   1 data[*]
     2 token_str = vc
     2 token_value = vc
     2 token_exists_ind = i2
 )
 FREE RECORD duxj_tblrequest
 RECORD duxj_tblrequest(
   1 template_nbr = i4
 )
 FREE RECORD duxj_tblreply
 RECORD duxj_tblreply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD duxj_deltokens
 RECORD duxj_deltokens(
   1 tokens[*]
     2 token_str = vc
 )
 SET reply->status_data.status = "F"
 DECLARE duxj_errmsg = vc WITH protect, noconstant("")
 DECLARE duxj_table_list = vc WITH protect, noconstant("")
 DECLARE duxj_job_name_token_str = vc WITH protect, constant("JOBNAME")
 DECLARE duxj_old_job_name = vc WITH protect, noconstant("")
 DECLARE duxj_missing_tbl_ind = i2 WITH protect, noconstant(0)
 DECLARE duxj_loop = i4 WITH protect, noconstant(0)
 DECLARE duxj_expand_idx = i4 WITH protect, noconstant(0)
 DECLARE duxj_lval_idx = i4 WITH protect, noconstant(0)
 DECLARE duxj_template_nbr = i4 WITH protect, noconstant(0)
 DECLARE duxj_i18nhandle = i4 WITH protect, noconstant(0)
 DECLARE duxj_delcnt = i4 WITH protect, noconstant(0)
 DECLARE duxj_updtid = vc WITH protect, noconstant("")
 SET stat = uar_i18nlocalizationinit(duxj_i18nhandle,curprog,"",curcclrev)
 SELECT INTO "nl:"
  FROM dm_purge_job dpj
  WHERE (dpj.job_id=request->job_id)
  DETAIL
   duxj_template_nbr = dpj.template_nbr
  WITH nocounter
 ;end select
 IF (error(duxj_errmsg,0) > 0)
  ROLLBACK
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "fetching template number"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = curprog
  SET reply->status_data.subeventstatus[1].targetobjectvalue = uar_i18nbuildmessage(duxj_i18nhandle,
   "TEMPSEARCH","Failed while fetching the template number: %1","s",nullterm(duxj_errmsg))
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "fetching template number"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = curprog
  SET reply->status_data.subeventstatus[1].targetobjectvalue = uar_i18ngetmessage(duxj_i18nhandle,
   "NOJOB","Job does not exist")
  GO TO exit_script
 ENDIF
 SET duxj_tblrequest->template_nbr = duxj_template_nbr
 EXECUTE dm2_verify_purge_tables  WITH replace("REQUEST","DUXJ_TBLREQUEST"), replace("REPLY",
  "DUXJ_TBLREPLY")
 IF ((duxj_tblreply->status_data.status="F"))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = duxj_tblreply->status_data.subeventstatus[
  1].operationname
  SET reply->status_data.subeventstatus[1].operationstatus = duxj_tblreply->status_data.
  subeventstatus[1].operationstatus
  SET reply->status_data.subeventstatus[1].targetobjectname = duxj_tblreply->status_data.
  subeventstatus[1].targetobjectname
  SET reply->status_data.subeventstatus[1].targetobjectvalue = duxj_tblreply->status_data.
  subeventstatus[1].targetobjectvalue
  GO TO exit_script
 ENDIF
 SET duxj_tokens->data_cnt = size(request->tokens,5)
 SET stat = alterlist(duxj_tokens->data,duxj_tokens->data_cnt)
 FOR (duxj_loop = 1 TO duxj_tokens->data_cnt)
  SET duxj_tokens->data[duxj_loop].token_str = request->tokens[duxj_loop].token_str
  SET duxj_tokens->data[duxj_loop].token_value = request->tokens[duxj_loop].token_value
 ENDFOR
 IF ((duxj_tokens->data_cnt > 0))
  SELECT INTO "nl:"
   FROM dm_purge_job_token dpjt,
    (dummyt d  WITH seq = value(duxj_tokens->data_cnt))
   PLAN (d)
    JOIN (dpjt
    WHERE (dpjt.job_id=request->job_id)
     AND (dpjt.token_str=duxj_tokens->data[d.seq].token_str))
   DETAIL
    duxj_tokens->data[d.seq].token_exists_ind = 1
   WITH nocounter
  ;end select
  IF (error(duxj_errmsg,0) > 0)
   ROLLBACK
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "verifying token existence"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = curprog
   SET reply->status_data.subeventstatus[1].targetobjectvalue = uar_i18nbuildmessage(duxj_i18nhandle,
    "TOKEXIST","Error while comparing token values: %1","s",nullterm(duxj_errmsg))
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM dm_purge_job_token dpjt
  WHERE (dpjt.job_id=request->job_id)
   AND  NOT (expand(duxj_expand_idx,1,duxj_tokens->data_cnt,dpjt.token_str,duxj_tokens->data[
   duxj_expand_idx].token_str))
   AND dpjt.token_str != duxj_job_name_token_str
  DETAIL
   duxj_delcnt = (duxj_delcnt+ 1), stat = alterlist(duxj_deltokens->tokens,duxj_delcnt),
   duxj_deltokens->tokens[duxj_delcnt].token_str = dpjt.token_str
  WITH nocounter
 ;end select
 SET duxj_updtid = build(reqinfo->updt_id)
 IF (duxj_delcnt > 0)
  CALL parser("rdb ")
  CALL parser("ASIS(^  begin ^)")
  CALL parser(concat("ASIS(^    dm_purge_log_package.set_value_in_context(",duxj_updtid,"); ^)"))
  CALL parser("ASIS(^  end; ^) go")
  FOR (loop = 1 TO duxj_delcnt)
   DELETE  FROM dm_purge_job_token dpjt
    WHERE (dpjt.job_id=request->job_id)
     AND (dpjt.token_str=duxj_deltokens->tokens[duxj_delcnt].token_str)
    WITH nocounter
   ;end delete
   IF (error(duxj_errmsg,0) > 0)
    ROLLBACK
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "deleting unused tokens"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = curprog
    SET reply->status_data.subeventstatus[1].targetobjectvalue = uar_i18nbuildmessage(duxj_i18nhandle,
     "DELTOKENS","Error while deleting unused tokens: %1","s",nullterm(duxj_errmsg))
    GO TO exit_script
   ENDIF
  ENDFOR
 ENDIF
 UPDATE  FROM dm_purge_job dpj
  SET dpj.active_flag = request->active_flag, dpj.updt_cnt = (dpj.updt_cnt+ 1), dpj.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   dpj.updt_id = reqinfo->updt_id, dpj.updt_task = reqinfo->updt_task, dpj.updt_applctx = reqinfo->
   updt_applctx
  PLAN (dpj
   WHERE (dpj.job_id=request->job_id))
  WITH nocounter
 ;end update
 IF (error(duxj_errmsg,0) > 0)
  ROLLBACK
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "updating purge job"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = curprog
  SET reply->status_data.subeventstatus[1].targetobjectvalue = uar_i18nbuildmessage(duxj_i18nhandle,
   "UPDATEJOB","Error while updating job: %1","s",nullterm(duxj_errmsg))
  GO TO exit_script
 ENDIF
 SET duxj_old_job_name = request->job_name
 SELECT INTO "nl:"
  FROM dm_purge_job_token dpjt
  WHERE (dpjt.job_id=request->job_id)
   AND dpjt.token_str=duxj_job_name_token_str
   AND (dpjt.value != request->job_name)
  DETAIL
   duxj_old_job_name = dpjt.value
  WITH nocounter
 ;end select
 IF ((duxj_old_job_name != request->job_name))
  UPDATE  FROM dm_purge_job_token dpjt
   SET dpjt.value = request->job_name, dpjt.updt_cnt = (dpjt.updt_cnt+ 1), dpjt.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    dpjt.updt_id = reqinfo->updt_id, dpjt.updt_task = reqinfo->updt_task, dpjt.updt_applctx = reqinfo
    ->updt_applctx
   PLAN (dpjt
    WHERE (dpjt.job_id=request->job_id)
     AND dpjt.token_str=duxj_job_name_token_str)
   WITH nocounter
  ;end update
  IF (error(duxj_errmsg,0) > 0)
   ROLLBACK
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "updating purge job name"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = curprog
   SET reply->status_data.subeventstatus[1].targetobjectvalue = uar_i18nbuildmessage(duxj_i18nhandle,
    "UPDATENAME","Error while updating job name: %1","s",nullterm(duxj_errmsg))
   GO TO exit_script
  ENDIF
  IF (curqual=0
   AND textlen(trim(request->job_name)) > 0)
   INSERT  FROM dm_purge_job_token dpjt
    SET dpjt.job_id = request->job_id, dpjt.token_str = duxj_job_name_token_str, dpjt.value = request
     ->job_name,
     dpjt.updt_cnt = 0, dpjt.updt_dt_tm = cnvtdatetime(curdate,curtime3), dpjt.updt_id = reqinfo->
     updt_id,
     dpjt.updt_task = reqinfo->updt_task, dpjt.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (error(duxj_errmsg,0) > 0)
    ROLLBACK
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "updating purge job name"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = curprog
    SET reply->status_data.subeventstatus[1].targetobjectvalue = uar_i18nbuildmessage(duxj_i18nhandle,
     "INSERTNAME","Error while inserting job name: %1","s",nullterm(duxj_errmsg))
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 IF ((duxj_tokens->data_cnt > 0))
  INSERT  FROM dm_purge_job_token dpjt,
    (dummyt d  WITH seq = value(duxj_tokens->data_cnt))
   SET dpjt.job_id = request->job_id, dpjt.token_str = duxj_tokens->data[d.seq].token_str, dpjt.value
     = duxj_tokens->data[d.seq].token_value,
    dpjt.updt_task = reqinfo->updt_task, dpjt.updt_id = reqinfo->updt_id, dpjt.updt_applctx = reqinfo
    ->updt_applctx,
    dpjt.updt_dt_tm = cnvtdatetime(curdate,curtime3), dpjt.updt_cnt = 0
   PLAN (d
    WHERE (duxj_tokens->data[d.seq].token_exists_ind=0))
    JOIN (dpjt)
   WITH nocounter
  ;end insert
  IF (error(duxj_errmsg,0) > 0)
   ROLLBACK
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "inserting new job tokens"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = curprog
   SET reply->status_data.subeventstatus[1].targetobjectvalue = uar_i18nbuildmessage(duxj_i18nhandle,
    "INSTOKEN","Error while inserting new tokens: %1","s",nullterm(duxj_errmsg))
   GO TO exit_script
  ENDIF
  UPDATE  FROM dm_purge_job_token dpjt,
    (dummyt d  WITH seq = value(duxj_tokens->data_cnt))
   SET dpjt.value = duxj_tokens->data[d.seq].token_value, dpjt.updt_id = reqinfo->updt_id, dpjt
    .updt_task = reqinfo->updt_task,
    dpjt.updt_cnt = (dpjt.updt_cnt+ 1), dpjt.updt_applctx = reqinfo->updt_applctx, dpjt.updt_dt_tm =
    cnvtdatetime(curdate,curtime3)
   PLAN (d
    WHERE (duxj_tokens->data[d.seq].token_exists_ind=1))
    JOIN (dpjt
    WHERE (dpjt.job_id=request->job_id)
     AND (dpjt.token_str=duxj_tokens->data[d.seq].token_str)
     AND (dpjt.value != duxj_tokens->data[d.seq].token_value))
   WITH nocounter
  ;end update
  IF (error(duxj_errmsg,0) > 0)
   ROLLBACK
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "inserting new job tokens"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = curprog
   SET reply->status_data.subeventstatus[1].targetobjectvalue = uar_i18nbuildmessage(duxj_i18nhandle,
    "UPDTOKENS","Error while updating tokens: %1","s",nullterm(duxj_errmsg))
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 COMMIT
#exit_script
 FREE RECORD duxj_tables
 FREE RECORD duxj_tokens
 FREE RECORD duxj_tblrequest
 FREE RECORD duxj_tblreply
 FREE RECORD duxj_deltokens
END GO
