CREATE PROGRAM dm2_create_purge_job:dba
 IF ((validate(request->template_nbr,- (1))=- (1)))
  RECORD request(
    1 template_nbr = i4
    1 max_rows = i4
    1 purge_flag = i2
    1 active_flag = i2
    1 tokens[*]
      2 token_str = vc
      2 token_value = vc
  )
 ENDIF
 IF ((validate(reply->job_id,- (1.0))=- (1.0)))
  RECORD reply(
    1 job_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD dcpj_tblrequest
 RECORD dcpj_tblrequest(
   1 template_nbr = i4
 )
 FREE RECORD dcpj_tblreply
 RECORD dcpj_tblreply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE dcpj_errmsg = vc WITH protect, noconstant("")
 DECLARE dcpj_loop = i4 WITH protect, noconstant(0)
 DECLARE dcpj_i18nhandle = i4 WITH protect, noconstant(0)
 SET stat = uar_i18nlocalizationinit(dcpj_i18nhandle,curprog,"",curcclrev)
 SET dcpj_tblrequest->template_nbr = request->template_nbr
 EXECUTE dm2_verify_purge_tables  WITH replace("REPLY","DCPJ_TBLREPLY"), replace("REQUEST",
  "DCPJ_TBLREQUEST")
 IF ((dcpj_tblreply->status_data.status="F"))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = dcpj_tblreply->status_data.subeventstatus.
  operationname
  SET reply->status_data.subeventstatus.operationstatus = dcpj_tblreply->status_data.subeventstatus.
  operationstatus
  SET reply->status_data.subeventstatus.targetobjectname = dcpj_tblreply->status_data.subeventstatus.
  targetobjectname
  SET reply->status_data.subeventstatus.targetobjectvalue = dcpj_tblreply->status_data.subeventstatus
  .targetobjectvalue
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  seqval = seq(dm_clinical_seq,nextval)
  FROM dual
  DETAIL
   reply->job_id = seqval
  WITH nocounter
 ;end select
 INSERT  FROM dm_purge_job dpj
  SET dpj.job_id = reply->job_id, dpj.template_nbr = request->template_nbr, dpj.max_rows = request->
   max_rows,
   dpj.purge_flag = request->purge_flag, dpj.active_flag = request->active_flag, dpj.updt_id =
   reqinfo->updt_id,
   dpj.updt_dt_tm = cnvtdatetime(curdate,curtime3), dpj.updt_task = reqinfo->updt_task, dpj.updt_cnt
    = 0,
   dpj.updt_applctx = reqinfo->updt_applctx
  WITH nocounter
 ;end insert
 IF (error(dcpj_errmsg,0) > 0)
  ROLLBACK
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = "inserting purge job"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = curprog
  SET reply->status_data.subeventstatus.targetobjectvalue = uar_i18nbuildmessage(dcpj_i18nhandle,
   "INSTOKENS","Failed to insert job: %1","s",nullterm(dcpj_errmsg))
  GO TO exit_script
 ENDIF
 IF (size(request->tokens,5) > 0)
  INSERT  FROM dm_purge_job_token dpjt,
    (dummyt d  WITH seq = value(size(request->tokens,5)))
   SET dpjt.job_id = reply->job_id, dpjt.token_str = request->tokens[d.seq].token_str, dpjt.value =
    request->tokens[d.seq].token_value,
    dpjt.updt_id = reqinfo->updt_id, dpjt.updt_dt_tm = cnvtdatetime(curdate,curtime3), dpjt.updt_task
     = reqinfo->updt_task,
    dpjt.updt_cnt = 0, dpjt.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (dpjt)
   WITH nocounter
  ;end insert
  IF (error(dcpj_errmsg,0) > 0)
   ROLLBACK
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus.operationname = "inserting purge job tokens"
   SET reply->status_data.subeventstatus.operationstatus = "F"
   SET reply->status_data.subeventstatus.targetobjectname = curprog
   SET reply->status_data.subeventstatus.targetobjectvalue = uar_i18nbuildmessage(dcpj_i18nhandle,
    "INSTOKENS","Failed to insert job tokens: %1","s",nullterm(dcpj_errmsg))
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 COMMIT
#exit_script
END GO
