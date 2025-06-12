CREATE PROGRAM afc_upt_interface_file:dba
 IF ("Z"=validate(afc_upt_interface_file_vrsn,"Z"))
  DECLARE afc_upt_interface_file_vrsn = vc WITH noconstant("CHARGSRV-14071.016"), public
 ENDIF
 SET afc_upt_interface_file_vrsn = "CHARGSRV-14071.016"
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 DECLARE action_begin = i2 WITH protect, noconstant(1)
 DECLARE action_end = i2 WITH protect, noconstant(request->interface_file_qual)
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 interface_file_qual = i2
    1 interface_file[10]
      2 interface_file_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET reply->interface_file_qual = action_end
 ENDIF
 SET reply->status_data.status = "F"
 SET table_name = "INTERFACE_FILE"
 CALL upt_interface_file(action_begin,action_end)
 IF (failed != false)
  GO TO check_error
 ENDIF
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failed)
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   OF replace_error:
    SET reply->status_data.subeventstatus[1].operationname = "REPLACE"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   OF undelete_error:
    SET reply->status_data.subeventstatus[1].operationname = "UNDELETE"
   OF remove_error:
    SET reply->status_data.subeventstatus[1].operationname = "REMOVE"
   OF attribute_error:
    SET reply->status_data.subeventstatus[1].operationname = "ATTRIBUTE"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
 ENDIF
 GO TO end_program
 SUBROUTINE (upt_interface_file(upt_begin=i2,upt_end=i2) =i2)
   DECLARE blank_date = f8 WITH protect, noconstant(0.0)
   DECLARE loopcnt = i2 WITH protect, noconstant(0)
   DECLARE active_status_code = f8 WITH protect, noconstant(0.0)
   FOR (loopcnt = upt_begin TO upt_end)
     SET blank_date = cnvtdatetime("01-JAN-1800 00:00:00.00")
     UPDATE  FROM interface_file i
      SET i.description = evaluate(request->interface_file[loopcnt].description," ",i.description,
        '""',null,
        request->interface_file[loopcnt].description), i.file_name = evaluate(request->
        interface_file[loopcnt].file_name," ",i.file_name,'""',null,
        request->interface_file[loopcnt].file_name), i.realtime_ind = request->interface_file[loopcnt
       ].realtime_ind,
       i.hl7_ind = request->interface_file[loopcnt].hl7_ind, i.hold_period = evaluate(request->
        interface_file[loopcnt].hold_period,0.0,i.hold_period,- (1.0),0.0,
        request->interface_file[loopcnt].hold_period), i.batch_frequency = evaluate(request->
        interface_file[loopcnt].batch_frequency,0.0,i.batch_frequency,- (1.0),0.0,
        request->interface_file[loopcnt].batch_frequency),
       i.round_method_flag = request->interface_file[loopcnt].round_method_flag, i.active_ind =
       request->interface_file[loopcnt].active_ind, i.active_status_dt_tm = nullcheck(i
        .active_status_dt_tm,cnvtdatetime(sysdate),
        IF ((request->interface_file[loopcnt].active_status_cd=active_status_code)) 0
        ELSE 1
        ENDIF
        ),
       i.updt_cnt = (i.updt_cnt+ 1), i.updt_dt_tm = cnvtdatetime(sysdate), i.updt_id = reqinfo->
       updt_id,
       i.updt_applctx = reqinfo->updt_applctx, i.updt_task = reqinfo->updt_task, i.cdm_sched_cd =
       request->interface_file[loopcnt].cdm_sched_cd,
       i.cpt_sched_cd = request->interface_file[loopcnt].cpt_sched_cd, i.rev_sched_cd = request->
       interface_file[loopcnt].rev_sched_cd, i.mult_bill_code_sched_cd = request->interface_file[
       loopcnt].mult_bill_code_sched_cd,
       i.contributor_system_cd = request->interface_file[loopcnt].contributor_system_cd, i.doc_nbr_cd
        = request->interface_file[loopcnt].doc_nbr_cd, i.explode_ind = request->interface_file[
       loopcnt].explode_ind,
       i.profit_type_cd = request->interface_file[loopcnt].profit_type_cd, i.fin_nbr_suspend_ind =
       request->interface_file[loopcnt].fin_nbr_suspend_ind, i.max_ft1 = request->interface_file[
       loopcnt].max_ft1,
       i.perf_phys_cont_ind = request->interface_file[loopcnt].perf_phys_cont_ind, i.reprocess_ind =
       validate(request->interface_file[loopcnt].reprocess_ind,0), i.reprocess_cpt_ind = validate(
        request->interface_file[loopcnt].reprocess_cpt_ind,0),
       i.interface_type_flag = validate(request->interface_file[loopcnt].interface_type_flag,0), i
       .billing_entity_id = validate(request->interface_file[loopcnt].billing_entity_id,0.0), i
       .order_phys_copy_ind = validate(request->interface_file[loopcnt].order_phys_copy_ind,0),
       i.susp_chrg_process_flag = validate(request->interface_file[loopcnt].susp_chrg_process_flag,0),
       i.service_based_ind = validate(request->interface_file[loopcnt].service_based_ind,0), i
       .cdm_id_suspend_ind = validate(request->interface_file[loopcnt].cdm_id_suspend_ind,0),
       i.cost_center_suspend_ind = validate(request->interface_file[loopcnt].cost_center_suspend_ind,
        0)
      WHERE (i.interface_file_id=request->interface_file[loopcnt].interface_file_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = update_error
      RETURN
     ELSE
      SET reply->interface_file[loopcnt].interface_file_id = request->interface_file[loopcnt].
      interface_file_id
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
