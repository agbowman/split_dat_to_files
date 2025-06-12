CREATE PROGRAM bsc_process_transaction_id:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 nursing_transaction_info_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE in_process_ind = i2 WITH noconstant(0)
 DECLARE next_trans_id = f8 WITH noconstant(0.0)
 DECLARE last_mod = c12 WITH private, noconstant(fillstring(12," "))
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM nursing_transaction_info nti
  WHERE (nti.group_nursing_transaction_id=request->group_transaction_id)
  DETAIL
   in_process_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  newseq = seq(nursing_transaction_seq,nextval)
  FROM dual
  DETAIL
   next_trans_id = newseq
  WITH nocounter
 ;end select
 IF (in_process_ind=0)
  INSERT  FROM nursing_transaction_info nti
   SET nti.group_nursing_transaction_id = request->group_transaction_id, nti
    .nursing_transaction_info_id = next_trans_id, nti.primary_transaction_ind = 1,
    nti.transaction_dt_tm = cnvtdatetime(curdate,curtime3), nti.updt_id = reqinfo->updt_id, nti
    .updt_task = reqinfo->updt_task,
    nti.updt_applctx = reqinfo->updt_applctx, nti.updt_cnt = 0, nti.updt_dt_tm = cnvtdatetime(curdate,
     curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   GO TO exit_script
  ENDIF
  SET reply->status_data.status = "S"
  SET reply->nursing_transaction_info_id = next_trans_id
  SET reqinfo->commit_ind = 1
 ELSE
  INSERT  FROM nursing_transaction_info nti
   SET nti.group_nursing_transaction_id = request->group_transaction_id, nti
    .nursing_transaction_info_id = next_trans_id, nti.primary_transaction_ind = 0,
    nti.transaction_dt_tm = cnvtdatetime(curdate,curtime3), nti.updt_id = reqinfo->updt_id, nti
    .updt_task = reqinfo->updt_task,
    nti.updt_applctx = reqinfo->updt_applctx, nti.updt_cnt = 0, nti.updt_dt_tm = cnvtdatetime(curdate,
     curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   GO TO exit_script
  ENDIF
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 1
 ENDIF
#exit_script
 SET last_mod = "001 7/27/10"
 SET modify = nopredeclare
END GO
