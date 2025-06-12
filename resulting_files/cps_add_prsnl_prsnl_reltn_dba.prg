CREATE PROGRAM cps_add_prsnl_prsnl_reltn:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET code_value = 0.0
 SET code_set = 375
 SET cdf_meaning = fillstring(12," ")
 SET ppr_cd = 0.0
 IF ((request->prsnl_prsnl_reltn_cd <= 0))
  SET cdf_meaning = "PAB"
  EXECUTE cpm_get_cd_for_cdf
  SET ppr_cd = code_value
  IF (code_value < 1)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
    "Invalid code_value for cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(cnvtstring(code_set)
     ))
   GO TO exit_script
  ENDIF
 ELSE
  SET ppr_cd = request->prsnl_prsnl_reltn_cd
 ENDIF
 IF ((request->clear_pab=0))
  SET ierrcode = 0
  DELETE  FROM prsnl_prsnl_reltn p
   PLAN (p
    WHERE (p.person_id=request->person_id)
     AND p.prsnl_prsnl_reltn_cd=ppr_cd)
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = delete_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "DELETE_ERROR"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "PRSNL_PRSNL_RELTN"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ELSE
  SET ierrcode = 0
  SELECT INTO "NL:"
   FROM prsnl_prsnl_reltn p,
    (dummyt d  WITH seq = value(size(request->prsnl,5)))
   PLAN (d
    WHERE d.seq > 0)
    JOIN (p
    WHERE (p.person_id=request->person_id)
     AND (p.related_person_id=request->prsnl[d.seq].prsnl_id)
     AND p.prsnl_prsnl_reltn_cd=ppr_cd)
   DETAIL
    FOR (count1 = 1 TO value(size(request->prsnl,5)))
      IF ((request->prsnl[count1].prsnl_id=p.related_person_id))
       request->prsnl[count1].updt_prsnl_id = 1
      ENDIF
    ENDFOR
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "PRSNL_PRSNL_RELTN"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->prsnl_qual > 0))
  SET ierrcode = 0
  INSERT  FROM prsnl_prsnl_reltn p,
    (dummyt d  WITH seq = value(size(request->prsnl,5)))
   SET p.seq = 1, p.prsnl_prsnl_reltn_id = seq(prsnl_seq,nextval), p.person_id = request->person_id,
    p.prsnl_prsnl_reltn_cd = ppr_cd, p.related_person_id = request->prsnl[d.seq].prsnl_id, p.updt_cnt
     = 0,
    p.updt_id = reqinfo->updt_id, p.updt_dt_tm = cnvtdatetime(sysdate), p.updt_task = reqinfo->
    updt_task,
    p.updt_applctx = reqinfo->updt_applctx, p.active_ind = 1, p.active_status_cd = reqdata->
    active_status_cd,
    p.active_status_dt_tm = cnvtdatetime(sysdate), p.active_status_prsnl_id = reqinfo->updt_id, p
    .beg_effective_dt_tm = cnvtdatetime(sysdate),
    p.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"), p.data_status_cd = reqdata->
    data_status_cd, p.data_status_dt_tm = cnvtdatetime(sysdate),
    p.data_status_prsnl_id = reqinfo->updt_id, p.contributor_system_cd = reqdata->
    contributor_system_cd, p.organization_id = request->organization_id
   PLAN (d
    WHERE (request->prsnl[d.seq].updt_prsnl_id <= 0))
    JOIN (p)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = insert_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "INSERT_ERROR"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "PRSNL_PRSNL_RELTN"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  SET reqinfo->commit_ind = false
 ENDIF
END GO
