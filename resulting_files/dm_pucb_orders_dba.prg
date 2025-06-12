CREATE PROGRAM dm_pucb_orders:dba
 IF ((validate(dm_cmb_cust_script->called_by_readme_ind,- (9))=- (9)))
  RECORD dm_cmb_cust_script(
    1 called_by_readme_ind = i2
    1 exc_maint_ind = i2
  )
 ENDIF
 SUBROUTINE (dm_cmb_get_context(dummy=i2) =null)
   SET dm_cmb_cust_script->called_by_readme_ind = 0
   IF (validate(readme_data->status,"b") != "b"
    AND validate(readme_data->message,"CUSTCMBVALIDATE") != "CUSTCMBVALIDATE")
    SET dm_cmb_cust_script->called_by_readme_ind = 1
   ENDIF
   SET dm_cmb_cust_script->exc_maint_ind = 0
   IF ((validate(dcue_context_rec->called_by_dcue_ind,- (11)) != - (11))
    AND (validate(dcue_context_rec->called_by_dcue_ind,- (22)) != - (22)))
    SET dm_cmb_cust_script->exc_maint_ind = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE cust_chk_ccl_def_col(ftbl_name,fcol_name)
   SELECT INTO "nl:"
    l.attr_name
    FROM dtableattr a,
     dtableattrl l
    WHERE a.table_name=cnvtupper(trim(ftbl_name,3))
     AND l.attr_name=cnvtupper(trim(fcol_name,3))
     AND l.structtype="F"
     AND btest(l.stat,11)=0
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (dm_cmb_exc_maint_status(s_dcems_status=c1,s_dcems_msg=c255,s_dcems_tname=vc) =null)
   SET dcue_upt_exc_reply->status = s_dcems_status
   SET dcue_upt_exc_reply->message = s_dcems_msg
   SET dcue_upt_exc_reply->error_table = s_dcems_tname
 END ;Subroutine
 IF ((validate(dcem_request->qual[1].single_encntr_ind,- (1))=- (1)))
  FREE RECORD dcem_request
  RECORD dcem_request(
    1 qual[*]
      2 parent_entity = vc
      2 child_entity = vc
      2 op_type = vc
      2 script_name = vc
      2 single_encntr_ind = i2
      2 script_run_order = i4
      2 del_chg_id_ind = i2
      2 delete_row_ind = i2
  )
 ENDIF
 IF (validate(dcem_reply->status,"B")="B")
  FREE RECORD dcem_reply
  RECORD dcem_reply(
    1 status = c1
    1 err_msg = c255
  )
 ENDIF
 DECLARE cmb_save_col_value(sv_pk_value,sv_col_name,sv_from,sv_to) = i2
 DECLARE cmb_read_col_value(rv_col_name) = i2
 DECLARE cmb_save_column_value(svf_tbl_name,svf_pk_value,svf_col_name,svf_col_type,svf_from,
  svf_to) = i2
 DECLARE cmb_read_column_value(rvf_tbl_name,rvf_pk_value,rvf_rv_col_name) = i2
 RECORD cmb_det_value(
   1 table_name = vc
   1 column_name = vc
   1 column_type = vc
   1 from_value = vc
   1 to_value = vc
 )
 SUBROUTINE cmb_save_col_value(sv_pk_value,sv_col_name,sv_from,sv_to)
  SET sv_return = cmb_save_column_value(rcmblist->custom[maincount3].table_name,sv_pk_value,
   sv_col_name,"",sv_from,
   sv_to)
  RETURN(sv_return)
 END ;Subroutine
 SUBROUTINE cmb_save_column_value(svf_tbl_name,svf_pk_value,svf_col_name,svf_col_type,svf_from,svf_to
  )
   IF (((svf_tbl_name="") OR (svf_tbl_name=" ")) )
    SET svf_tbl_name = rcmblist->custom[maincount3].table_name
   ENDIF
   INSERT  FROM combine_det_value
    SET combine_det_value_id = seq(combine_seq,nextval), combine_id = request->xxx_combine[icombine].
     xxx_combine_id, combine_parent = evaluate(cnvtupper(trim(request->parent_table,3)),"ENCOUNTER",
      "ENCNTR_COMBINE","PERSON","PERSON_COMBINE",
      "COMBINE"),
     parent_entity = request->parent_table, entity_name = cnvtupper(svf_tbl_name), entity_id =
     svf_pk_value,
     column_name = cnvtupper(svf_col_name), column_type = evaluate(svf_col_type,"",null,svf_col_type),
     from_value = svf_from,
     to_value = evaluate(svf_to,"",null,svf_to), updt_cnt = 0, updt_id = reqinfo->updt_id,
     updt_applctx = reqinfo->updt_applctx, updt_task = reqinfo->updt_task, updt_dt_tm = cnvtdatetime(
      sysdate)
    WITH nocounter
   ;end insert
   RETURN(curqual)
 END ;Subroutine
 SUBROUTINE cmb_read_col_value(rv_col_name)
  SET rv_return = cmb_read_column_value(rchildren->qual1[det_cnt].entity_name,rchildren->qual1[
   det_cnt].entity_id,rv_col_name)
  RETURN(rv_return)
 END ;Subroutine
 SUBROUTINE cmb_read_column_value(rv_tbl_name,rv_pk_value,rv_col_name)
   SET cmb_det_value->table_name = ""
   SET cmb_det_value->column_name = ""
   SET cmb_det_value->from_value = ""
   SET cmb_det_value->to_value = ""
   IF (((rv_tbl_name="") OR (rv_tbl_name=" ")) )
    SET rv_tbl_name = rchildren->qual1[det_cnt].entity_name
   ENDIF
   IF (rv_pk_value=0)
    SET rv_pk_value = rchildren->qual1[det_cnt].entity_id
   ENDIF
   SELECT INTO "nl:"
    v.column_name, v.from_value, v.to_value
    FROM combine_det_value v
    WHERE (v.combine_id=request->xxx_uncombine[ucb_cnt].xxx_combine_id)
     AND v.combine_parent=evaluate(cnvtupper(trim(request->parent_table,3)),"ENCOUNTER",
     "ENCNTR_COMBINE","PERSON","PERSON_COMBINE",
     "COMBINE")
     AND (v.parent_entity=request->parent_table)
     AND v.entity_name=cnvtupper(rv_tbl_name)
     AND v.entity_id=rv_pk_value
     AND v.column_name=cnvtupper(rv_col_name)
    DETAIL
     cmb_det_value->table_name = v.entity_name, cmb_det_value->column_name = v.column_name,
     cmb_det_value->column_type = v.column_type,
     cmb_det_value->from_value = v.from_value, cmb_det_value->to_value = v.to_value
    WITH nocounter
   ;end select
   RETURN(curqual)
 END ;Subroutine
 DECLARE dpo_cnt = i4
 DECLARE dpo_warn_type = f8
 DECLARE dpo_f_flag = i2
 DECLARE warn_seq_val = f8
 SET dpo_f_flag = 0
 SET dpp_warn_type = 0.0
 DECLARE order_warning_full_mask_set = i4 WITH protect, constant(2147483647)
 DECLARE current_date_time = dq8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE severe_warning_level_flag = i4 WITH protect, constant(1)
 DECLARE protocol_warning_type_flag = i4 WITH protect, constant(1)
 DECLARE canceled_order_status_cd = f8 WITH protect, noconstant(- (1.0))
 DECLARE voided_with_results_order_status_cd = f8 WITH protect, noconstant(- (1.0))
 DECLARE voided_without_results_order_status_cd = f8 WITH protect, noconstant(- (1.0))
 DECLARE local_debug_ind = i2 WITH protect, noconstant(0)
 DECLARE ucberrmsg = vc WITH protect, noconstant(" ")
 DECLARE get_next_available_warning_id(null) = f8
 IF (validate(dm_debug_cmb,0))
  IF (dm_debug_cmb=1)
   SET local_debug_ind = 1
  ENDIF
 ENDIF
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "ORDERS"
  SET dcem_request->qual[1].op_type = "UNCOMBINE"
  SET dcem_request->qual[1].script_name = "DM_PUCB_ORDERS"
  SET dcem_request->qual[1].single_encntr_ind = 1
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6004
    AND cv.active_ind=1
    AND cv.cdf_meaning IN ("CANCELED", "DELETED", "VOIDEDWRSLT"))
  DETAIL
   CASE (cv.cdf_meaning)
    OF "CANCELED":
     canceled_order_status_cd = cv.code_value
    OF "DELETED":
     voided_without_results_order_status_cd = cv.code_value
    OF "VOIDEDWRSLT":
     voided_with_results_order_status_cd = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 IF (((canceled_order_status_cd < 0) OR (((voided_without_results_order_status_cd < 0) OR (
 voided_with_results_order_status_cd < 0)) )) )
  SET error_table = "CODE_VALUE"
  SET request->error_message =
  "No active, effective code_value with code_set = 6004, cdf_meaning = CANCELED, DELETED or VOIDEDWRSLT"
  SET ucb_failed = data_error
  GO TO exit_program
 ENDIF
 SET dpo_cnt = size(reply->em,5)
 SET cust_ucb_dummy = 0
 IF ((rchildren->qual1[det_cnt].combine_action_cd=upt))
  CALL cust_ucb_upt(cust_ucb_dummy)
 ELSE
  SET ucb_failed = data_error
  SET error_table = rchildren->qual1[det_cnt].entity_name
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM encounter e,
   orders o
  PLAN (e
   WHERE (e.person_id=request->xxx_uncombine[ucb_cnt].from_xxx_id))
   JOIN (o
   WHERE (o.order_id=rchildren->qual1[det_cnt].entity_id)
    AND o.encntr_id=e.encntr_id
    AND (o.person_id=request->xxx_uncombine[ucb_cnt].to_xxx_id))
  DETAIL
   dpo_cnt += 1, stat = alterlist(reply->em,dpo_cnt), reply->em[dpo_cnt].to_person_id = request->
   xxx_uncombine[ucb_cnt].from_xxx_id,
   reply->em[dpo_cnt].from_person_id = request->xxx_uncombine[ucb_cnt].to_xxx_id, reply->em[dpo_cnt].
   encntr_id = e.encntr_id, reply->em[dpo_cnt].entity_id = o.order_id,
   dpo_f_flag = 1
  WITH nocounter
 ;end select
 IF (dm_debug_cmb=1)
  CALL echorecord(reply)
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=4001903
    AND cv.active_ind=1
    AND cv.cdf_meaning="FUTUREORDER")
  DETAIL
   dpo_warn_type = cv.code_value
  WITH nocounter
 ;end select
 IF (dpo_warn_type=0)
  SET error_table = "CODE_VALUE"
  SET request->error_message =
  "No active, effective code_value with code_set=4001903, cdf_meaning='FUTUREORDER'"
  SET ucb_failed = data_error
  GO TO exit_program
 ENDIF
 SET ecode = 0
 SET emsg = fillstring(132," ")
 IF (dpo_f_flag=1)
  SELECT INTO "nl:"
   y = seq(dm_cmb_warning_seq,nextval)
   FROM dual
   DETAIL
    warn_seq_val = cnvtreal(y)
   WITH nocounter
  ;end select
  DELETE  FROM dm_cmb_warning
   WHERE dm_cmb_warning_id=warn_seq_val
   WITH nocounter
  ;end delete
  INSERT  FROM dm_cmb_warning d
   SET d.dm_cmb_warning_id = warn_seq_val, d.combine_entity_id = request->xxx_uncombine[ucb_cnt].
    xxx_combine_id, d.combine_entity_name = "PERSON_COMBINE",
    d.warning_type_cd = dpo_warn_type, d.parent_entity_name = "ORDERS", d.parent_entity_id = reply->
    em[dpo_cnt].entity_id,
    d.updt_id = reqinfo->updt_id, d.updt_dt_tm = cnvtdatetime(sysdate), d.updt_applctx = reqinfo->
    updt_applctx,
    d.updt_cnt = 0, d.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
 ENDIF
 SET ecode = error(emsg,0)
 IF (ecode != 0)
  SET ucb_failed = ccl_error
  SET error_table = "DM_CMB_WARNING"
  SET request->error_message = emsg
  GO TO exit_program
 ENDIF
 SUBROUTINE cust_ucb_upt(dummy)
   DECLARE warning_level_bit_to_set = i4 WITH protect, noconstant(0)
   DECLARE protocol_order_in_valid_status = i2 WITH private, noconstant(0)
   DECLARE breturn = i2 WITH protect, noconstant(0)
   DECLARE protocol_order_id = f8 WITH protect, noconstant(0.0)
   DECLARE warning_level_bit = i4 WITH protect, noconstant(0)
   DECLARE is_protocol_or_dot_ind = i2 WITH protect, noconstant(0)
   DECLARE protocol_template_order_flag = i2 WITH protect, constant(7)
   SELECT INTO "nl:"
    o.order_id, o.protocol_order_id, o.warning_level_bit,
    o.order_status_cd, o.template_order_flag, o.template_order_id
    FROM orders o
    PLAN (o
     WHERE (o.order_id=rchildren->qual1[det_cnt].entity_id))
    DETAIL
     IF (o.protocol_order_id=0.0
      AND o.template_order_flag=protocol_template_order_flag)
      CALL log_debug_message(build2("Processing uncombine for protocol order id: ",rchildren->qual1[
       det_cnt].entity_id)), is_protocol_or_dot_ind = 1, protocol_order_id = o.order_id,
      warning_level_bit = o.warning_level_bit
     ELSEIF (o.protocol_order_id != 0.0
      AND o.template_order_id=0.0)
      CALL log_debug_message(build2("Processing uncombine for DoT order id: ",rchildren->qual1[
       det_cnt].entity_id)), is_protocol_or_dot_ind = 1, protocol_order_id = o.protocol_order_id,
      warning_level_bit = o.warning_level_bit
     ELSE
      CALL log_debug_message(build2("Processing uncombine for non-protocol, non-DoT order id: ",
       rchildren->qual1[det_cnt].entity_id))
     ENDIF
    WITH forupdatewait(o)
   ;end select
   IF (is_protocol_or_dot_ind=1)
    SET breturn = cmb_read_column_value("ORDERS",rchildren->qual1[det_cnt].entity_id,
     "WARNING_LEVEL_BIT")
    IF (breturn > 0)
     CALL log_debug_message(build2("Record saved during the combine process found for order id: ",
       rchildren->qual1[det_cnt].entity_id))
     SET protocol_order_in_valid_status = is_order_in_valid_status(protocol_order_id)
     IF (protocol_order_in_valid_status=1)
      CALL log_debug_message(build2("Protocol order id: ",protocol_order_id,
        " is in valid status(not canceled/voided) 				. Re-calculate the warning level bit."))
      SET warning_level_bit_to_set = calculate_warning_bit_and_update_order_warning(rchildren->qual1[
       det_cnt].entity_id,warning_level_bit,cnvtint(cmb_det_value->from_value))
     ELSE
      CALL log_debug_message(build2("Protocol order id: ",protocol_order_id,
        " is not in valid status. Do not re-calculate the               warning level bit."))
      SET warning_level_bit_to_set = warning_level_bit
     ENDIF
    ELSE
     SET request->error_message = build2("No entries found in cmb_det_value table for order id:",
      rchildren->qual1[det_cnt].entity_id)
     SET ucb_failed = data_error
     GO TO exit_program
    ENDIF
   ENDIF
   CALL log_debug_message(build2("Updating ORDERS table for order id: ",rchildren->qual1[det_cnt].
     entity_id))
   UPDATE  FROM orders o
    SET o.updt_id = reqinfo->updt_id, o.updt_dt_tm = cnvtdatetime(current_date_time), o.updt_applctx
      = reqinfo->updt_applctx,
     o.updt_cnt = (o.updt_cnt+ 1), o.updt_task = reqinfo->updt_task, o.person_id =
     IF ((rchildren->qual1[det_cnt].to_record_ind=1)) o.person_id
     ELSE request->xxx_uncombine[ucb_cnt].to_xxx_id
     ENDIF
     ,
     o.warning_level_bit =
     IF (breturn > 0) warning_level_bit_to_set
     ELSE o.warning_level_bit
     ENDIF
    WHERE (o.order_id=rchildren->qual1[det_cnt].entity_id)
     AND (o.person_id=request->xxx_uncombine[ucb_cnt].from_xxx_id)
    WITH nocounter
   ;end update
   IF (error(ucberrmsg,0) != 0)
    SET ucb_failed = update_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_program
   ENDIF
   SET activity_updt_cnt += 1
 END ;Subroutine
 SUBROUTINE (is_order_in_valid_status(order_id=f8) =i2)
   DECLARE order_status_cd = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    o.order_id, o.order_status_cd
    FROM orders o
    PLAN (o
     WHERE o.order_id=order_id)
    DETAIL
     order_status_cd = o.order_status_cd
    WITH nocounter
   ;end select
   IF (((order_status_cd=canceled_order_status_cd) OR (((order_status_cd=
   voided_with_results_order_status_cd) OR (order_status_cd=voided_without_results_order_status_cd))
   )) )
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE (calculate_warning_bit_and_update_order_warning(order_id=f8,current_warning_level_bit=i4,
  saved_warning_level_bit=i4) =i4)
   DECLARE other_severe_warnings_exist = i2 WITH protect, noconstant(0)
   DECLARE protocol_patient_mismatch_bitmask = i2 WITH protect, constant(8)
   DECLARE severe_warning_bitmask = i2 WITH protect, constant(1)
   IF (band(current_warning_level_bit,protocol_patient_mismatch_bitmask)=band(saved_warning_level_bit,
    protocol_patient_mismatch_bitmask))
    IF (band(current_warning_level_bit,protocol_patient_mismatch_bitmask)=
    protocol_patient_mismatch_bitmask)
     CALL log_debug_message(build2("updating the order warning for order id: ",order_id))
     CALL update_protocol_person_mismatch_order_warning(order_id)
    ENDIF
    RETURN(current_warning_level_bit)
   ELSEIF (band(saved_warning_level_bit,protocol_patient_mismatch_bitmask)=
   protocol_patient_mismatch_bitmask
    AND band(current_warning_level_bit,protocol_patient_mismatch_bitmask)=0)
    CALL log_debug_message(build2("Inserting order warning for order id: ",order_id))
    CALL insert_protocol_person_mismatch_order_warning(order_id)
    RETURN(bor(current_warning_level_bit,(protocol_patient_mismatch_bitmask+ severe_warning_bitmask))
    )
   ELSEIF (band(saved_warning_level_bit,protocol_patient_mismatch_bitmask)=0
    AND band(current_warning_level_bit,protocol_patient_mismatch_bitmask)=
   protocol_patient_mismatch_bitmask)
    CALL log_debug_message(build2("Deleting order warning for order id: ",order_id))
    CALL delete_protocol_person_mismatch_order_warning(order_id)
    SET other_severe_warnings_exist = do_other_active_severe_warnings_exist(order_id)
    IF (other_severe_warnings_exist=1)
     RETURN(band(current_warning_level_bit,(order_warning_full_mask_set -
      protocol_patient_mismatch_bitmask)))
    ELSE
     RETURN(band(current_warning_level_bit,(order_warning_full_mask_set - (
      protocol_patient_mismatch_bitmask+ severe_warning_bitmask))))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (update_protocol_person_mismatch_order_warning(order_id=f8) =null)
   UPDATE  FROM order_warning ow
    SET ow.updt_cnt = (ow.updt_cnt+ 1), ow.updt_id = reqinfo->updt_id, ow.updt_task = reqinfo->
     updt_task,
     ow.updt_dt_tm = cnvtdatetime(current_date_time), ow.updt_applctx = reqinfo->updt_applctx
    WHERE ow.order_id=order_id
     AND ((ow.warning_level_flag+ 0)=severe_warning_level_flag)
     AND ((ow.warning_type_flag+ 0)=protocol_warning_type_flag)
     AND ((ow.active_ind+ 0)=1)
    WITH nocounter
   ;end update
 END ;Subroutine
 SUBROUTINE (insert_protocol_person_mismatch_order_warning(order_id=f8) =null)
  DECLARE next_warning_id = f8 WITH protect, constant(get_next_available_warning_id(null))
  INSERT  FROM order_warning ow
   SET ow.order_warning_id = next_warning_id, ow.updt_cnt = 0, ow.updt_id = reqinfo->updt_id,
    ow.updt_task = reqinfo->updt_task, ow.updt_dt_tm = cnvtdatetime(current_date_time), ow
    .updt_applctx = reqinfo->updt_applctx,
    ow.warning_level_flag = severe_warning_level_flag, ow.warning_type_flag =
    protocol_warning_type_flag, ow.active_ind = 1,
    ow.order_id = order_id
   WITH nocounter
  ;end insert
 END ;Subroutine
 SUBROUTINE (delete_protocol_person_mismatch_order_warning(order_id=f8) =null)
   DELETE  FROM order_warning ow
    WHERE ow.order_id=order_id
     AND ((ow.warning_level_flag+ 0)=severe_warning_level_flag)
     AND ((ow.warning_type_flag+ 0)=protocol_warning_type_flag)
     AND ((ow.active_ind+ 0)=1)
    WITH nocounter
   ;end delete
 END ;Subroutine
 SUBROUTINE get_next_available_warning_id(null)
   DECLARE value = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    next_warn_id = seq(order_seq,nextval)
    FROM dual
    DETAIL
     value = next_warn_id
    WITH format, nocounter
   ;end select
   RETURN(value)
 END ;Subroutine
 SUBROUTINE (do_other_active_severe_warnings_exist(order_id=f8) =i2)
   DECLARE num = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    number_of_non_protocol_person_mismatch_severe_warnings = count(*)
    FROM order_warning ow
    PLAN (ow
     WHERE ow.order_id=order_id
      AND ((ow.warning_level_flag+ 0)=severe_warning_level_flag)
      AND ((ow.warning_type_flag+ 0) != protocol_warning_type_flag)
      AND ((ow.active_ind+ 0)=1))
    DETAIL
     num = number_of_non_protocol_person_mismatch_severe_warnings
    WITH nocounter
   ;end select
   IF (num > 0)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (log_debug_message(debug_message=vc) =null)
   IF (local_debug_ind=1)
    CALL echo(debug_message)
   ENDIF
 END ;Subroutine
#exit_program
END GO
