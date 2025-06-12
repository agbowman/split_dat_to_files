CREATE PROGRAM ct_add_power_plan_details:dba
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
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SET fail_flag = 0
 SET reply->status_data.status = "F"
 DECLARE update_error = i2 WITH private, constant(7)
 UPDATE  FROM prot_crpc_billing pcb
  SET pcb.prot_power_plan_name = request->powerplanname, pcb.prot_power_plan_status_ind = request->
   powerplanstatus, pcb.prot_power_plan_dt_tm = cnvtdatetime(request->powerplandate),
   pcb.prot_power_plan_cmnt_txt = request->comments, pcb.updt_applctx = reqinfo->updt_applctx, pcb
   .updt_id = reqinfo->updt_id,
   pcb.updt_task = reqinfo->updt_task, pcb.updt_cnt = (pcb.updt_cnt+ 1), pcb.updt_dt_tm =
   cnvtdatetime(sysdate)
  WHERE (pcb.prot_kcw_long_blob_id=request->kcwid)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Error updating into prot_crpc_billing table."
  SET fail_flag = update_error
  GO TO check_error
 ENDIF
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
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    SET reply->status_data.subeventstatus[1].operationstatus = "U"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unknown error."
    SET reply->status_data.subeventstatus[1].operationstatus = "X"
  ENDCASE
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reqinfo->commit_ind = 0
 ENDIF
 SET last_mod = "000"
 SET mod_date = "Jan 02, 2018"
END GO
