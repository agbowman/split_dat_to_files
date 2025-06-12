CREATE PROGRAM dm2_update_purge_job:dba
 IF ((validate(request->job_id,- (1))=- (1)))
  RECORD request(
    1 job_id = f8
    1 max_rows = i4
    1 purge_flag = i2
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
 FREE RECORD dupj_tokens
 RECORD dupj_tokens(
   1 data_cnt = i4
   1 data[*]
     2 token_str = vc
     2 token_value = vc
     2 token_exists_ind = i2
 )
 FREE RECORD dupj_tblrequest
 RECORD dupj_tblrequest(
   1 template_nbr = i4
 )
 FREE RECORD dupj_tblreply
 RECORD dupj_tblreply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE dupj_errmsg = vc WITH protect, noconstant("")
 DECLARE dupj_table_list = vc WITH protect, noconstant("")
 DECLARE dupj_missing_tbl_ind = i2 WITH protect, noconstant(0)
 DECLARE dupj_loop = i4 WITH protect, noconstant(0)
 DECLARE dupj_expand_idx = i4 WITH protect, noconstant(0)
 DECLARE dupj_lval_idx = i4 WITH protect, noconstant(0)
 DECLARE dupj_template_nbr = i4 WITH protect, noconstant(0)
 DECLARE dupj_i18nhandle = i4 WITH protect, noconstant(0)
 SET stat = uar_i18nlocalizationinit(dupj_i18nhandle,curprog,"",curcclrev)
 SELECT INTO "nl:"
  FROM dm_purge_job dpj
  WHERE (dpj.job_id=request->job_id)
  DETAIL
   dupj_template_nbr = dpj.template_nbr
  WITH nocounter
 ;end select
 IF (error(dupj_errmsg,0) > 0)
  ROLLBACK
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "fetching template number"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = curprog
  SET reply->status_data.subeventstatus[1].targetobjectvalue = uar_i18nbuildmessage(dupj_i18nhandle,
   "TEMPSEARCH","Failed while fetching the template number: %1","s",nullterm(dupj_errmsg))
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "fetching template number"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = curprog
  SET reply->status_data.subeventstatus[1].targetobjectvalue = uar_i18ngetmessage(dupj_i18nhandle,
   "NOJOB","Job does not exist")
  GO TO exit_script
 ENDIF
 SET dupj_tblrequest->template_nbr = dupj_template_nbr
 EXECUTE dm2_verify_purge_tables  WITH replace("REQUEST","DUPJ_TBLREQUEST"), replace("REPLY",
  "DUPJ_TBLREPLY")
 IF ((dupj_tblreply->status_data.status="F"))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = dupj_tblreply->status_data.subeventstatus[
  1].operationname
  SET reply->status_data.subeventstatus[1].operationstatus = dupj_tblreply->status_data.
  subeventstatus[1].operationstatus
  SET reply->status_data.subeventstatus[1].targetobjectname = dupj_tblreply->status_data.
  subeventstatus[1].targetobjectname
  SET reply->status_data.subeventstatus[1].targetobjectvalue = dupj_tblreply->status_data.
  subeventstatus[1].targetobjectvalue
  GO TO exit_script
 ENDIF
 SET dupj_tokens->data_cnt = size(request->tokens,5)
 SET stat = alterlist(dupj_tokens->data,dupj_tokens->data_cnt)
 FOR (dupj_loop = 1 TO dupj_tokens->data_cnt)
  SET dupj_tokens->data[dupj_loop].token_str = request->tokens[dupj_loop].token_str
  SET dupj_tokens->data[dupj_loop].token_value = request->tokens[dupj_loop].token_value
 ENDFOR
 IF ((dupj_tokens->data_cnt > 0))
  SELECT INTO "nl:"
   FROM dm_purge_job_token dpjt,
    (dummyt d  WITH seq = value(dupj_tokens->data_cnt))
   PLAN (d)
    JOIN (dpjt
    WHERE (dpjt.job_id=request->job_id)
     AND (dpjt.token_str=dupj_tokens->data[d.seq].token_str))
   DETAIL
    dupj_tokens->data[d.seq].token_exists_ind = 1
   WITH nocounter
  ;end select
  IF (error(dupj_errmsg,0) > 0)
   ROLLBACK
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "verifying token existence"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = curprog
   SET reply->status_data.subeventstatus[1].targetobjectvalue = uar_i18nbuildmessage(dupj_i18nhandle,
    "TOKEXIST","Error while comparing token values: %1","s",nullterm(dupj_errmsg))
   GO TO exit_script
  ENDIF
 ENDIF
 DELETE  FROM dm_purge_job_token dpjt
  WHERE (dpjt.job_id=request->job_id)
   AND  NOT (expand(dupj_expand_idx,1,dupj_tokens->data_cnt,dpjt.token_str,dupj_tokens->data[
   dupj_expand_idx].token_str))
  WITH nocounter
 ;end delete
 IF (error(dupj_errmsg,0) > 0)
  ROLLBACK
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "deleting unused tokens"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = curprog
  SET reply->status_data.subeventstatus[1].targetobjectvalue = uar_i18nbuildmessage(dupj_i18nhandle,
   "DELTOKENS","Error while deleting unused tokens: %1","s",nullterm(dupj_errmsg))
  GO TO exit_script
 ENDIF
 UPDATE  FROM dm_purge_job dpj
  SET dpj.max_rows = request->max_rows, dpj.active_flag = request->active_flag, dpj.purge_flag =
   request->purge_flag,
   dpj.updt_cnt = (dpj.updt_cnt+ 1), dpj.updt_dt_tm = cnvtdatetime(curdate,curtime3), dpj.updt_id =
   reqinfo->updt_id,
   dpj.updt_task = reqinfo->updt_task, dpj.updt_applctx = reqinfo->updt_applctx
  PLAN (dpj
   WHERE (dpj.job_id=request->job_id))
  WITH nocounter
 ;end update
 IF (error(dupj_errmsg,0) > 0)
  ROLLBACK
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "updating purge job"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = curprog
  SET reply->status_data.subeventstatus[1].targetobjectvalue = uar_i18nbuildmessage(dupj_i18nhandle,
   "UPDATEJOB","Error while updating job: %1","s",nullterm(dupj_errmsg))
  GO TO exit_script
 ENDIF
 IF ((dupj_tokens->data_cnt > 0))
  INSERT  FROM dm_purge_job_token dpjt,
    (dummyt d  WITH seq = value(dupj_tokens->data_cnt))
   SET dpjt.job_id = request->job_id, dpjt.token_str = dupj_tokens->data[d.seq].token_str, dpjt.value
     = dupj_tokens->data[d.seq].token_value,
    dpjt.updt_task = reqinfo->updt_task, dpjt.updt_id = reqinfo->updt_id, dpjt.updt_applctx = reqinfo
    ->updt_applctx,
    dpjt.updt_dt_tm = cnvtdatetime(curdate,curtime3), dpjt.updt_cnt = 0
   PLAN (d
    WHERE (dupj_tokens->data[d.seq].token_exists_ind=0))
    JOIN (dpjt)
   WITH nocounter
  ;end insert
  IF (error(dupj_errmsg,0) > 0)
   ROLLBACK
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "inserting new job tokens"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = curprog
   SET reply->status_data.subeventstatus[1].targetobjectvalue = uar_i18nbuildmessage(dupj_i18nhandle,
    "INSTOKEN","Error while inserting new tokens: %1","s",nullterm(dupj_errmsg))
   GO TO exit_script
  ENDIF
  UPDATE  FROM dm_purge_job_token dpjt,
    (dummyt d  WITH seq = value(dupj_tokens->data_cnt))
   SET dpjt.value = dupj_tokens->data[d.seq].token_value, dpjt.updt_id = reqinfo->updt_id, dpjt
    .updt_task = reqinfo->updt_task,
    dpjt.updt_cnt = (dpjt.updt_cnt+ 1), dpjt.updt_applctx = reqinfo->updt_applctx, dpjt.updt_dt_tm =
    cnvtdatetime(curdate,curtime3)
   PLAN (d
    WHERE (dupj_tokens->data[d.seq].token_exists_ind=1))
    JOIN (dpjt
    WHERE (dpjt.job_id=request->job_id)
     AND (dpjt.token_str=dupj_tokens->data[d.seq].token_str)
     AND (dpjt.value != dupj_tokens->data[d.seq].token_value))
   WITH nocounter
  ;end update
  IF (error(dupj_errmsg,0) > 0)
   ROLLBACK
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "inserting new job tokens"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = curprog
   SET reply->status_data.subeventstatus[1].targetobjectvalue = uar_i18nbuildmessage(dupj_i18nhandle,
    "UPDTOKENS","Error while updating tokens: %1","s",nullterm(dupj_errmsg))
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 COMMIT
#exit_script
 FREE RECORD dupj_tables
 FREE RECORD dupj_tokens
 FREE RECORD dupj_tblrequest
 FREE RECORD dupj_tblreply
END GO
