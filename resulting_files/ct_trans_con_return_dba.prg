CREATE PROGRAM ct_trans_con_return:dba
 RECORD reply(
   1 prprotregid = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 debug[*]
     2 str = vc
 )
 SET ccaa_status = "F"
 SET ccaa_updt_cnt = 0
 SET ccaa_ct_pt_amd_assignment_id = 0.0
 SET caaa_status = "F"
 RECORD pt_amd_assignment(
   1 transfer_checked_amendment_id = f8
   1 assign_start_dt_tm = dq8
   1 assign_end_dt_tm = dq8
   1 reg_id = f8
   1 prot_amendment_id = f8
 )
 SET pt_amd_assignment->reg_id = request->regid
 SET pt_amd_assignment->assign_end_dt_tm = request->dateamendmentassigned
 SET pt_amd_assignment->transfer_checked_amendment_id = 0
 SET pt_amd_assignment->prot_amendment_id = 0
 EXECUTE ct_chg_a_a_func
 IF (ccaa_status != "S")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "ct_trans_con_return->ct_chg_a_a_func"
  SET reply->status_data.subeventstatus[1].operationstatus = ccaa_status
  SET reply->prprotregid = 0
  SET reqinfo->commit_ind = false
  GO TO exit_ct_trans_con_return
 ENDIF
 SET pt_amd_assignment->transfer_checked_amendment_id = request->protamendmentid
 SET pt_amd_assignment->assign_start_dt_tm = request->dateamendmentassigned
 SET pt_amd_assignment->assign_end_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
 SET pt_amd_assignment->reg_id = request->regid
 SET pt_amd_assignment->prot_amendment_id = request->protamendmentid
 EXECUTE ct_add_a_a_func
 IF (caaa_status != "S")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "ct_trans_con_return->ct_add_a_a_func"
  SET reply->status_data.subeventstatus[1].operationstatus = caaa_status
  SET reply->prprotregid = 0
  SET reqinfo->commit_ind = false
  GO TO exit_ct_trans_con_return
 ENDIF
 SET reply->prprotregid = pt_amd_assignment->prot_amendment_id
 SET reply->status_data.status = "S"
 SET reply->status_data.subeventstatus[1].operationname = "ct_trans_con_return"
 SET reply->status_data.subeventstatus[1].operationstatus = "S"
 SET reqinfo->commit_ind = true
#exit_ct_trans_con_return
 SET debug_code_stemp = fillstring(999," ")
 SET debug_code_ecode = 1
 SET debug_code_cntd = size(reply->debug,5)
 WHILE (debug_code_ecode != 0)
  SET debug_code_ecode = error(debug_code_stemp,0)
  IF (debug_code_ecode != 0)
   SET debug_code_cntd = (debug_code_cntd+ 1)
   SET stat = alterlist(reply->debug,debug_code_cntd)
   SET reply->debug[debug_code_cntd].str = debug_code_stemp
  ENDIF
 ENDWHILE
END GO
