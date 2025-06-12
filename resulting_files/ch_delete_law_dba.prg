CREATE PROGRAM ch_delete_law:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET failed = fillstring(1," ")
 SET failed = "T"
 SET active_code = 0.0
 SET code_value1 = 0.0
 SET cdf_meaning1 = fillstring(12," ")
 SET code_set1 = 48
 SET cdf_meaning1 = "ACTIVE"
 SET stat = uar_get_meaning_by_codeset(code_set1,cdf_meaning1,1,code_value1)
 SET active_code = code_value1
 SET inactive_code = 0.0
 SET code_value1 = 0.0
 SET cdf_meaning1 = fillstring(12," ")
 SET code_set1 = 48
 SET cdf_meaning1 = "INACTIVE"
 SET stat = uar_get_meaning_by_codeset(code_set1,cdf_meaning1,1,code_value1)
 SET inactive_code = code_value1
 UPDATE  FROM chart_law c
  SET c.active_ind = 0, c.active_status_cd = inactive_code, c.active_status_prsnl_id = reqinfo->
   updt_id,
   c.active_status_dt_tm = cnvtdatetime(curdate,curtime), c.updt_cnt = (c.updt_cnt+ 1), c.updt_dt_tm
    = cnvtdatetime(curdate,curtime),
   c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->
   updt_task
  WHERE (c.law_id=request->law_id)
  WITH nocounter
 ;end update
 UPDATE  FROM chart_law_filter clf
  SET clf.active_ind = 0, clf.active_status_cd = inactive_code, clf.active_status_dt_tm =
   cnvtdatetime(sysdate),
   clf.active_status_prsnl_id = reqinfo->updt_id
  WHERE (clf.law_id=request->law_id)
  WITH nocounter
 ;end update
 UPDATE  FROM chart_law_filter_value clfv
  SET clfv.active_ind = 0, clfv.active_status_cd = inactive_code, clfv.active_status_dt_tm =
   cnvtdatetime(sysdate),
   clfv.active_status_prsnl_id = reqinfo->updt_id
  WHERE (clfv.law_id=request->law_id)
  WITH nocounter
 ;end update
 IF (curqual > 0)
  SET failed = "F"
 ELSE
  SET failed = "T"
 ENDIF
 IF (failed="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  ROLLBACK
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
END GO
