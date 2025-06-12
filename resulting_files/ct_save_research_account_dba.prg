CREATE PROGRAM ct_save_research_account:dba
 DECLARE lock_error = i2 WITH private, constant(1)
 DECLARE update_error = i2 WITH private, constant(2)
 DECLARE delete_error = i2 WITH private, constant(7)
 DECLARE insert_error = i2 WITH private, constant(20)
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 UPDATE  FROM prot_crpc_billing pcb
  SET pcb.prot_res_accnt_cd = request->code_value, pcb.prot_req_update_dt_tm = cnvtdatetime(sysdate),
   pcb.updt_applctx = reqinfo->updt_applctx,
   pcb.updt_id = reqinfo->updt_id, pcb.updt_task = reqinfo->updt_task, pcb.updt_cnt = (pcb.updt_cnt+
   1),
   pcb.prot_research_account_name = request->research_ac, pcb.updt_dt_tm = cnvtdatetime(sysdate)
  WHERE (pcb.prot_master_id=request->prot_id)
 ;end update
#check_error
 IF (fail_flag=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  SET reply->status_data.subeventstatus[1].operationname = ""
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
 ELSE
  CASE (fail_flag)
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    SET reply->status_data.subeventstatus[1].operationstatus = "I"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unknown error."
    SET reply->status_data.subeventstatus[1].operationstatus = "U"
  ENDCASE
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reqinfo->commit_ind = 0
 ENDIF
 SET last_mod = "003"
 SET mod_date = "Mar 23, 2018"
END GO
