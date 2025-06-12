CREATE PROGRAM ct_get_billing_grid:dba
 DECLARE lock_error = i2 WITH private, constant(1)
 DECLARE update_error = i2 WITH private, constant(2)
 DECLARE delete_error = i2 WITH private, constant(7)
 DECLARE insert_error = i2 WITH private, constant(20)
 DECLARE research_account = vc WITH protect, constant("RSRCHACCT")
 RECORD reply(
   1 is_update = i2
   1 protocol_id = f8
   1 research_account_name = vc
   1 code_value = f8
   1 research_account_desc_num = vc
   1 received_date = dq8
   1 status = i2
   1 rpe_id = f8
   1 update_date = dq8
   1 update_status = i2
   1 power_plan_name = vc
   1 oe_field_description = vc
   1 is_research_account_active = i2
   1 xml_details[*]
     2 kcw_id = f8
     2 kcw_file_name = vc
     2 kcw_file_type = i2
     2 prot_power_plan_name = vc
     2 prot_power_plan_created_date = dq8
     2 prot_power_plan_status = i4
     2 prot_power_plan_comments = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 DECLARE research_account_id = f8
 SET reply->status_data.status = "F"
 SET reply->is_update = - (1)
 SET reply->is_research_account_active = 2
 SELECT
  pm.prot_master_id, pm.primary_mnemonic, pcb.beg_effective_dt_tm,
  pcb.prot_kcw_process_status_ind, pcb.prot_kcw_long_blob_id, pcb.prot_rpe_long_blob_id,
  pcb.prot_file_name, pcb.prot_file_type_flag, pcb.updt_dt_tm,
  pcb.updt_status_ind, pcb.prot_power_plan_name, pcb.prot_power_plan_dt_tm,
  pcb.prot_power_plan_status_ind, pcb.prot_power_plan_cmnt_txt
  FROM prot_crpc_billing pcb,
   prot_master pm
  PLAN (pcb)
   JOIN (pm
   WHERE pm.prot_master_id=pcb.prot_master_id
    AND (pcb.prot_master_id=request->prot_id))
  ORDER BY pm.primary_mnemonic
  HEAD REPORT
   j = 1, k = 0, reply->protocol_id = pm.prot_master_id,
   reply->code_value = pcb.prot_res_accnt_cd, reply->received_date = pcb.beg_effective_dt_tm, reply->
   update_date = pcb.updt_dt_tm,
   reply->status = pcb.prot_kcw_process_status_ind, reply->update_status = pcb.updt_status_ind, reply
   ->power_plan_name = pcb.prot_power_plan_name
   IF ((reply->is_update < pcb.prot_req_update_cnt))
    reply->is_update = pcb.prot_req_update_cnt
   ENDIF
  DETAIL
   k += 1
   IF (mod(k,10)=1)
    stat = alterlist(reply->xml_details,(k+ 9))
   ENDIF
   IF (pcb.prot_rpe_long_blob_id > 0.00)
    reply->rpe_id = pcb.prot_rpe_long_blob_id
   ENDIF
   reply->xml_details[k].kcw_id = pcb.prot_kcw_long_blob_id, reply->xml_details[k].kcw_file_name =
   pcb.prot_file_name, reply->xml_details[k].kcw_file_type = pcb.prot_file_type_flag,
   reply->xml_details[k].prot_power_plan_name = pcb.prot_power_plan_name, reply->xml_details[k].
   prot_power_plan_created_date = pcb.prot_power_plan_dt_tm, reply->xml_details[k].
   prot_power_plan_status = pcb.prot_power_plan_status_ind,
   reply->xml_details[k].prot_power_plan_comments = pcb.prot_power_plan_cmnt_txt
  FOOT REPORT
   stat = alterlist(reply->xml_details,k)
 ;end select
 SELECT
  ofm.description
  FROM oe_field_meaning ofm
  WHERE ofm.oe_field_meaning=research_account
  DETAIL
   reply->oe_field_description = ofm.description
 ;end select
 SELECT
  cv.definition
  FROM code_value cv
  WHERE (cv.code_value=reply->code_value)
  DETAIL
   research_account_id = cnvtreal(cv.definition)
 ;end select
 SELECT
  ra.active_ind
  FROM research_account ra
  WHERE ra.research_account_id=research_account_id
   AND ra.research_account_id > 0
  HEAD ra.research_account_id
   dummy = 0
  DETAIL
   reply->is_research_account_active = ra.active_ind, reply->research_account_desc_num = concat(trim(
     ra.description,7),concat("; ",trim(ra.account_nbr,7)))
 ;end select
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
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
    SET reply->status_data.subeventstatus[1].operationstatus = "L"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unknown error."
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
  ENDCASE
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reqinfo->commit_ind = 0
 ENDIF
 SET last_mod = "002"
 SET mod_date = "Sep 12, 2018"
END GO
