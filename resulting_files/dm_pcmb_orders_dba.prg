CREATE PROGRAM dm_pcmb_orders:dba
 DECLARE program_version = vc WITH private, constant("002")
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
 FREE SET order_group
 RECORD order_group(
   1 normal_orders[*]
     2 order_id = f8
   1 protocol_groups[*]
     2 order_id = f8
     2 order_status_cd = f8
     2 warning_level_bit = i4
     2 person_id = f8
     2 day_of_treatments_count = i4
     2 day_of_treatment_orders[*]
       3 order_id = f8
       3 warning_level_bit = i4
       3 encounter_id = f8
       3 person_id = f8
   1 originating_encounter_orders[*]
     2 order_id = f8
 )
 DECLARE protocol_warning_action_set = i2 WITH protect, constant(1)
 DECLARE protocol_warning_action_clear = i2 WITH protect, constant(0)
 DECLARE protocol_warning_level_bit_mask = i4 WITH protect, constant(8)
 DECLARE list_size = i4 WITH protect, constant(10)
 DECLARE order_warning_full_mask_set = i4 WITH protect, constant(2147483647)
 DECLARE current_date_time = dq8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE person_id_not_changed = i2 WITH protect, constant(1)
 DECLARE person_id_changed = i2 WITH protect, constant(0)
 DECLARE person_combine_operation_ind = i2 WITH protect, noconstant(0)
 DECLARE update_failure_ind = i2 WITH protect, noconstant(0)
 DECLARE canceled_order_status_cd = f8 WITH protect, noconstant(- (1.0))
 DECLARE voided_with_results_order_status_cd = f8 WITH protect, noconstant(- (1.0))
 DECLARE voided_without_results_order_status_cd = f8 WITH protect, noconstant(- (1.0))
 DECLARE stat = i4 WITH protect
 DECLARE local_debug_ind = i2 WITH protect, noconstant(0)
 DECLARE process_order_groups_for_encounter_move(null) = null
 DECLARE process_order_groups_for_person_combine(null) = null
 DECLARE update_normal_orders(null) = null
 DECLARE update_originating_encounter_orders(null) = null
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
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "dm_pcmb_orders"
  SET dcem_request->qual[1].single_encntr_ind = 1
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
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
  SET failed = data_error
  SET request->error_message = "Invalid order status code value."
  GO TO exit_sub
 ENDIF
 IF ((request->xxx_combine[icombine].encntr_id=0.0))
  CALL log_debug_message(build2("Starting person combine from person id: ",request->xxx_combine[
    icombine].from_xxx_id," into person id: ",request->xxx_combine[icombine].to_xxx_id))
  SET person_combine_operation_ind = 1
  CALL retrieve_orders(request->xxx_combine[icombine].from_xxx_id,0.0)
  IF (size(order_group->protocol_groups,5) > 0)
   CALL retrieve_related_day_of_treatments_and_protocol_orders(request->xxx_combine[icombine].
    from_xxx_id,0.0)
  ENDIF
  IF (local_debug_ind=1)
   CALL echorecord(order_group)
  ENDIF
  IF (((size(order_group->normal_orders,5) > 0) OR (size(order_group->protocol_groups,5) > 0)) )
   CALL process_order_groups_for_person_combine(null)
  ENDIF
 ELSE
  CALL log_debug_message(build2("Starting encounter move for encounter id: ",request->xxx_combine[
    icombine].encntr_id," to person id: ",request->xxx_combine[icombine].to_xxx_id))
  SET person_combine_operation_ind = 0
  CALL retrieve_orders(0.0,request->xxx_combine[icombine].encntr_id)
  IF (size(order_group->protocol_groups,5) > 0)
   CALL retrieve_related_day_of_treatments_and_protocol_orders(0.0,request->xxx_combine[icombine].
    encntr_id)
  ENDIF
  CALL retrieve_originating_encounter_orders(request->xxx_combine[icombine].encntr_id)
  IF (local_debug_ind=1)
   CALL echorecord(order_group)
  ENDIF
  IF (((size(order_group->normal_orders,5) > 0) OR (((size(order_group->protocol_groups,5) > 0) OR (
  size(order_group->originating_encounter_orders,5) > 0)) )) )
   CALL process_order_groups_for_encounter_move(null)
  ENDIF
 ENDIF
 SUBROUTINE (retrieve_related_day_of_treatments_and_protocol_orders(person_id=f8,encounter_id=f8) =
  null)
   DECLARE expand_start = i4 WITH protect, noconstant(1)
   DECLARE expand_total = i4 WITH protect, noconstant(0)
   DECLARE expand_idx1 = i4 WITH protect, noconstant(0)
   DECLARE expand_idx2 = i4 WITH protect, noconstant(0)
   DECLARE expand_size = i4 WITH protect, constant(50)
   DECLARE protocol_idx = i4 WITH protect, noconstant(0)
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE day_of_treatment_idx = i4 WITH protect, noconstant(0)
   DECLARE cust_loopcount = i4 WITH protect, noconstant(0)
   DECLARE protocol_groups_count = i4 WITH protect, noconstant(size(order_group->protocol_groups,5))
   DECLARE additional_condition = vc WITH protect, noconstant("")
   IF (person_id != 0.0
    AND encounter_id=0.0)
    SET additional_condition = "o.person_id+0 != person_id"
   ELSEIF (encounter_id != 0.0
    AND person_id=0.0)
    SET additional_condition = "o.encntr_id+0 != encounter_id"
   ELSE
    SET failed = general_error
    SET request->error_message =
    "Logic error. Either none or both person_id and encounter_id were given to retrieve orders."
    GO TO exit_sub
   ENDIF
   IF (mod(protocol_groups_count,expand_size) != 0)
    SET expand_total = (protocol_groups_count+ (expand_size - mod(protocol_groups_count,expand_size))
    )
    SET stat = alterlist(order_group->protocol_groups,expand_total)
   ENDIF
   FOR (index = (protocol_groups_count+ 1) TO expand_total)
     SET order_group->protocol_groups[index].order_id = order_group->protocol_groups[
     protocol_groups_count].order_id
   ENDFOR
   CALL log_debug_message("Starting retrieval of related DoTs and protocols.")
   SELECT INTO "nl:"
    o.order_id, o.protocol_order_id, o.person_id,
    o.encntr_id, o.warning_level_bit, o.order_status_cd,
    o.template_order_flag
    FROM orders o,
     (dummyt d  WITH seq = value((expand_total/ expand_size)))
    PLAN (d
     WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size))))
     JOIN (o
     WHERE ((expand(expand_idx1,expand_start,(expand_start+ (expand_size - 1)),o.protocol_order_id,
      order_group->protocol_groups[expand_idx1].order_id)) OR (expand(expand_idx2,expand_start,(
      expand_start+ (expand_size - 1)),o.order_id,order_group->protocol_groups[expand_idx2].order_id)
     ))
      AND parser(additional_condition))
    ORDER BY o.protocol_order_id
    HEAD o.protocol_order_id
     IF (o.protocol_order_id != 0.0)
      protocol_idx = locateval(index,1,protocol_groups_count,o.protocol_order_id,order_group->
       protocol_groups[index].order_id)
     ENDIF
    DETAIL
     IF (o.protocol_order_id=0.0)
      protocol_idx = locateval(index,1,protocol_groups_count,o.order_id,order_group->protocol_groups[
       index].order_id), order_group->protocol_groups[protocol_idx].warning_level_bit = o
      .warning_level_bit, order_group->protocol_groups[protocol_idx].order_status_cd = o
      .order_status_cd,
      order_group->protocol_groups[protocol_idx].person_id = o.person_id
     ELSE
      day_of_treatment_idx = (order_group->protocol_groups[protocol_idx].day_of_treatments_count+ 1),
      order_group->protocol_groups[protocol_idx].day_of_treatments_count = day_of_treatment_idx
      IF (day_of_treatment_idx > size(order_group->protocol_groups[protocol_idx].
       day_of_treatment_orders,5))
       stat = alterlist(order_group->protocol_groups[protocol_idx].day_of_treatment_orders,(
        day_of_treatment_idx+ list_size))
      ENDIF
      order_group->protocol_groups[protocol_idx].day_of_treatment_orders[day_of_treatment_idx].
      order_id = o.order_id, order_group->protocol_groups[protocol_idx].day_of_treatment_orders[
      day_of_treatment_idx].encounter_id = o.encntr_id, order_group->protocol_groups[protocol_idx].
      day_of_treatment_orders[day_of_treatment_idx].person_id = o.person_id,
      order_group->protocol_groups[protocol_idx].day_of_treatment_orders[day_of_treatment_idx].
      warning_level_bit = o.warning_level_bit
     ENDIF
    WITH forupdatewait(o)
   ;end select
   FOR (cust_loopcount = 1 TO protocol_groups_count)
     SET stat = alterlist(order_group->protocol_groups[cust_loopcount].day_of_treatment_orders,
      order_group->protocol_groups[cust_loopcount].day_of_treatments_count)
   ENDFOR
   SET stat = alterlist(order_group->protocol_groups,protocol_groups_count)
 END ;Subroutine
 SUBROUTINE (retrieve_orders(person_id=f8,encounter_id=f8) =null)
   DECLARE protocol_idx = i4 WITH protect, noconstant(0)
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE day_of_treatments_idx = i4 WITH protect, noconstant(0)
   DECLARE normal_orders_count = i4 WITH protect, noconstant(0)
   DECLARE protocol_groups_count = i4 WITH protect, noconstant(size(order_group->protocol_groups,5))
   DECLARE condition_string = vc WITH protect, noconstant("")
   DECLARE protocol_template_order_flag = i2 WITH protect, constant(7)
   DECLARE order_based_instance_template = i2 WITH protect, constant(2)
   DECLARE task_based_instance_template = i2 WITH protect, constant(3)
   DECLARE rx_based_instance_template = i2 WITH protect, constant(4)
   DECLARE future_recurring_instance_template = i2 WITH protect, constant(6)
   IF (person_id != 0.0
    AND encounter_id=0.0)
    SET condition_string = "o.person_id = person_id"
   ELSEIF (encounter_id != 0.0
    AND person_id=0.0)
    SET condition_string = "o.encntr_id = encounter_id"
   ELSE
    SET failed = general_error
    SET request->error_message =
    "Logic error. Either none or both person_id and encounter_id were given to retrieve orders."
    GO TO exit_sub
   ENDIF
   SELECT INTO "nl:"
    o.order_id, o.protocol_order_id, o.template_order_flag,
    o.person_id, o.encntr_id, o.warning_level_bit,
    o.order_status_cd
    FROM orders o
    PLAN (o
     WHERE parser(condition_string))
    DETAIL
     IF (((o.protocol_order_id=0.0
      AND o.template_order_flag != protocol_template_order_flag) OR (o.template_order_flag IN (
     order_based_instance_template, task_based_instance_template, rx_based_instance_template,
     future_recurring_instance_template))) )
      normal_orders_count += 1
      IF (normal_orders_count > size(order_group->normal_orders,5))
       stat = alterlist(order_group->normal_orders,(normal_orders_count+ list_size))
      ENDIF
      order_group->normal_orders[normal_orders_count].order_id = o.order_id
     ELSEIF (o.protocol_order_id != 0.0)
      protocol_idx = locateval(index,1,protocol_groups_count,o.protocol_order_id,order_group->
       protocol_groups[index].order_id)
      IF (protocol_idx > 0)
       day_of_treatments_idx = (order_group->protocol_groups[protocol_idx].day_of_treatments_count+ 1
       ), order_group->protocol_groups[protocol_idx].day_of_treatments_count = day_of_treatments_idx
       IF (day_of_treatments_idx > size(order_group->protocol_groups[protocol_idx].
        day_of_treatment_orders,5))
        stat = alterlist(order_group->protocol_groups[protocol_idx].day_of_treatment_orders,(
         day_of_treatments_idx+ list_size))
       ENDIF
       order_group->protocol_groups[protocol_idx].day_of_treatment_orders[day_of_treatments_idx].
       order_id = o.order_id, order_group->protocol_groups[protocol_idx].day_of_treatment_orders[
       day_of_treatments_idx].encounter_id = o.encntr_id, order_group->protocol_groups[protocol_idx].
       day_of_treatment_orders[day_of_treatments_idx].person_id = o.person_id,
       order_group->protocol_groups[protocol_idx].day_of_treatment_orders[day_of_treatments_idx].
       warning_level_bit = o.warning_level_bit
      ELSE
       protocol_groups_count += 1
       IF (protocol_groups_count > size(order_group->protocol_groups,5))
        stat = alterlist(order_group->protocol_groups,(protocol_groups_count+ list_size))
       ENDIF
       order_group->protocol_groups[protocol_groups_count].order_id = o.protocol_order_id,
       order_group->protocol_groups[protocol_groups_count].day_of_treatments_count = 1, stat =
       alterlist(order_group->protocol_groups[protocol_groups_count].day_of_treatment_orders,
        list_size),
       order_group->protocol_groups[protocol_groups_count].day_of_treatment_orders[1].order_id = o
       .order_id, order_group->protocol_groups[protocol_groups_count].day_of_treatment_orders[1].
       encounter_id = o.encntr_id, order_group->protocol_groups[protocol_groups_count].
       day_of_treatment_orders[1].person_id = o.person_id,
       order_group->protocol_groups[protocol_groups_count].day_of_treatment_orders[1].
       warning_level_bit = o.warning_level_bit
      ENDIF
     ELSEIF (o.protocol_order_id=0.0
      AND o.template_order_flag=protocol_template_order_flag)
      protocol_idx = locateval(index,1,protocol_groups_count,o.order_id,order_group->protocol_groups[
       index].order_id)
      IF (protocol_idx > 0)
       order_group->protocol_groups[protocol_idx].warning_level_bit = o.warning_level_bit,
       order_group->protocol_groups[protocol_idx].order_status_cd = o.order_status_cd, order_group->
       protocol_groups[protocol_idx].person_id = o.person_id
      ELSE
       protocol_groups_count += 1
       IF (protocol_groups_count > size(order_group->protocol_groups,5))
        stat = alterlist(order_group->protocol_groups,(protocol_groups_count+ list_size))
       ENDIF
       order_group->protocol_groups[protocol_groups_count].order_id = o.order_id, order_group->
       protocol_groups[protocol_groups_count].day_of_treatments_count = 0, order_group->
       protocol_groups[protocol_groups_count].warning_level_bit = o.warning_level_bit,
       order_group->protocol_groups[protocol_groups_count].order_status_cd = o.order_status_cd,
       order_group->protocol_groups[protocol_groups_count].person_id = o.person_id
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(order_group->normal_orders,normal_orders_count), stat = alterlist(order_group->
      protocol_groups,protocol_groups_count)
    WITH forupdatewait(o)
   ;end select
 END ;Subroutine
 SUBROUTINE (retrieve_originating_encounter_orders(encounter_id=f8) =null)
   DECLARE originating_encounter_orders_count = i4 WITH protect, noconstant(0)
   IF (encounter_id <= 0.0)
    SET failed = general_error
    SET request->error_message =
    "Logic error. Encounter_id is not provided for encounter move workflow."
    GO TO exit_sub
   ENDIF
   SELECT INTO "nl:"
    o.order_id
    FROM orders o
    PLAN (o
     WHERE ((o.originating_encntr_id=encounter_id) OR (o.encntr_id=encounter_id))
      AND o.encntr_id != o.originating_encntr_id)
    DETAIL
     originating_encounter_orders_count += 1
     IF (originating_encounter_orders_count > size(order_group->originating_encounter_orders,5))
      stat = alterlist(order_group->originating_encounter_orders,(originating_encounter_orders_count
       + 10))
     ENDIF
     order_group->originating_encounter_orders[originating_encounter_orders_count].order_id = o
     .order_id
    FOOT REPORT
     stat = alterlist(order_group->originating_encounter_orders,originating_encounter_orders_count)
    WITH forupdatewait(o)
   ;end select
 END ;Subroutine
 SUBROUTINE process_order_groups_for_person_combine(null)
   DECLARE cust_loopcount_dot = i4 WITH private, noconstant(0)
   DECLARE from_person_id = f8 WITH private, noconstant(request->xxx_combine[icombine].from_xxx_id)
   DECLARE person_id_of_all_dots_same = i2 WITH private, noconstant(1)
   DECLARE protocol_order_status_valid = i2 WITH private, noconstant(1)
   DECLARE protocol_order_status_cd = f8 WITH private, noconstant(0.0)
   DECLARE person_id_of_protocol_after_combine = f8 WITH private, noconstant(0.0)
   DECLARE person_id_of_dot_after_combine = f8 WITH private, noconstant(0.0)
   CALL log_debug_message("start processing orders for person combine")
   IF (size(order_group->normal_orders,5) > 0)
    CALL update_normal_orders(null)
   ENDIF
   IF (size(order_group->protocol_groups,5) <= 0)
    RETURN
   ENDIF
   CALL log_debug_message("Starting processing of protocol groups.")
   FOR (cust_loopcount = 1 TO size(order_group->protocol_groups,5))
     SET cust_loopcount_dot = 1
     SET person_id_of_all_dots_same = 1
     SET protocol_order_status_valid = 1
     SET protocol_order_status_cd = order_group->protocol_groups[cust_loopcount].order_status_cd
     IF ((order_group->protocol_groups[cust_loopcount].person_id=request->xxx_combine[icombine].
     from_xxx_id))
      SET person_id_of_protocol_after_combine = request->xxx_combine[icombine].to_xxx_id
     ELSE
      SET person_id_of_protocol_after_combine = order_group->protocol_groups[cust_loopcount].
      person_id
     ENDIF
     CALL log_debug_message(build2("person_id of protocol after combine: ",
       person_id_of_protocol_after_combine," for protocol order id: ",order_group->protocol_groups[
       cust_loopcount].order_id))
     IF (((protocol_order_status_cd=canceled_order_status_cd) OR (((protocol_order_status_cd=
     voided_with_results_order_status_cd) OR (protocol_order_status_cd=
     voided_without_results_order_status_cd)) )) )
      CALL log_debug_message(build2("protocol order with id:",order_group->protocol_groups[
        cust_loopcount].order_id," has          an invalid status cd: ",protocol_order_status_cd,
        " for order warning logic of person combine/encounter move operation         ."))
      SET protocol_order_status_valid = 0
     ENDIF
     WHILE (person_id_of_all_dots_same=1
      AND cust_loopcount_dot <= size(order_group->protocol_groups[cust_loopcount].
      day_of_treatment_orders,5))
      IF ((order_group->protocol_groups[cust_loopcount].day_of_treatment_orders[cust_loopcount_dot].
      person_id != from_person_id)
       AND (order_group->protocol_groups[cust_loopcount].day_of_treatment_orders[cust_loopcount_dot].
      person_id != request->xxx_combine[icombine].to_xxx_id))
       SET person_id_of_all_dots_same = 0
      ENDIF
      SET cust_loopcount_dot += 1
     ENDWHILE
     CALL log_debug_message(build2("Person id of all DoTs same after patient combine : ",
       person_id_of_all_dots_same," for protocol_order_id: ",order_group->protocol_groups[
       cust_loopcount].order_id))
     FOR (cust_loopcount_dot = 1 TO size(order_group->protocol_groups[cust_loopcount].
      day_of_treatment_orders,5))
      IF ((order_group->protocol_groups[cust_loopcount].day_of_treatment_orders[cust_loopcount_dot].
      person_id=request->xxx_combine[icombine].from_xxx_id))
       SET person_id_of_dot_after_combine = request->xxx_combine[icombine].to_xxx_id
      ELSE
       SET person_id_of_dot_after_combine = order_group->protocol_groups[cust_loopcount].
       day_of_treatment_orders[cust_loopcount_dot].person_id
      ENDIF
      IF (person_id_of_dot_after_combine=person_id_of_protocol_after_combine)
       IF ((order_group->protocol_groups[cust_loopcount].day_of_treatment_orders[cust_loopcount_dot].
       person_id=request->xxx_combine[icombine].from_xxx_id))
        IF (is_protocol_level_warning_bit_set(order_group->protocol_groups[cust_loopcount].
         day_of_treatment_orders[cust_loopcount_dot].warning_level_bit))
         CALL update_order(order_group->protocol_groups[cust_loopcount].day_of_treatment_orders[
          cust_loopcount_dot].order_id,request->xxx_combine[icombine].to_xxx_id,order_group->
          protocol_groups[cust_loopcount].day_of_treatment_orders[cust_loopcount_dot].
          warning_level_bit,protocol_warning_action_clear,protocol_order_status_valid)
        ELSE
         CALL update_order_move_only(order_group->protocol_groups[cust_loopcount].
          day_of_treatment_orders[cust_loopcount_dot].order_id,request->xxx_combine[icombine].
          to_xxx_id,order_group->protocol_groups[cust_loopcount].day_of_treatment_orders[
          cust_loopcount_dot].warning_level_bit)
        ENDIF
       ELSE
        IF (is_protocol_level_warning_bit_set(order_group->protocol_groups[cust_loopcount].
         day_of_treatment_orders[cust_loopcount_dot].warning_level_bit))
         CALL update_order_level_bitmask(order_group->protocol_groups[cust_loopcount].
          day_of_treatment_orders[cust_loopcount_dot].order_id,order_group->protocol_groups[
          cust_loopcount].day_of_treatment_orders[cust_loopcount_dot].warning_level_bit,
          protocol_warning_action_clear,protocol_order_status_valid)
        ENDIF
       ENDIF
      ELSEIF ((order_group->protocol_groups[cust_loopcount].day_of_treatment_orders[
      cust_loopcount_dot].person_id=request->xxx_combine[icombine].from_xxx_id))
       IF ( NOT (is_protocol_level_warning_bit_set(order_group->protocol_groups[cust_loopcount].
        day_of_treatment_orders[cust_loopcount_dot].warning_level_bit)))
        CALL log_debug_message(build2("warning flag for order id: ",order_group->protocol_groups[
          cust_loopcount].day_of_treatment_orders[cust_loopcount_dot].order_id," is not set."))
        CALL log_debug_message(
"If this piece of code is hit, it means that the person id of the DoT is not same as the                	 protocol and the \
flag is not set on the DoT. This indicates bad data as the only way the flag is not set on the                	  	DoT is w\
hen the person_id of the DoT is same as the protocol.\
")
       ENDIF
       CALL update_order(order_group->protocol_groups[cust_loopcount].day_of_treatment_orders[
        cust_loopcount_dot].order_id,request->xxx_combine[icombine].to_xxx_id,order_group->
        protocol_groups[cust_loopcount].day_of_treatment_orders[cust_loopcount_dot].warning_level_bit,
        protocol_warning_action_set,protocol_order_status_valid)
      ENDIF
     ENDFOR
     CALL log_debug_message(build2("Update the protocol order with id: ",order_group->
       protocol_groups[cust_loopcount].order_id))
     IF ((order_group->protocol_groups[cust_loopcount].person_id=request->xxx_combine[icombine].
     from_xxx_id))
      IF (person_id_of_all_dots_same=1)
       CALL update_order(order_group->protocol_groups[cust_loopcount].order_id,request->xxx_combine[
        icombine].to_xxx_id,order_group->protocol_groups[cust_loopcount].warning_level_bit,
        protocol_warning_action_clear,protocol_order_status_valid)
      ELSE
       IF ( NOT (is_protocol_level_warning_bit_set(order_group->protocol_groups[cust_loopcount].
        warning_level_bit)))
        CALL log_debug_message(build2("warning flag for order id: ",order_group->protocol_groups[
          cust_loopcount].order_id," is not set."))
        CALL log_debug_message(build2(
          "If this piece of code is hit,it means that the person id of all DoT for the protocol:",
          order_group->protocol_groups[cust_loopcount].order_id,
" is not the same and the flag is not set on the protocol                  This indicates bad data as the only way the flag\
 is not set on the protocol is when the                   person_id of all DoTs is same for the protocol.\
"))
       ENDIF
       CALL update_order(order_group->protocol_groups[cust_loopcount].order_id,request->xxx_combine[
        icombine].to_xxx_id,order_group->protocol_groups[cust_loopcount].warning_level_bit,
        protocol_warning_action_set,protocol_order_status_valid)
      ENDIF
     ELSE
      IF (person_id_of_all_dots_same=1)
       IF (is_protocol_level_warning_bit_set(order_group->protocol_groups[cust_loopcount].
        warning_level_bit))
        CALL update_order_level_bitmask(order_group->protocol_groups[cust_loopcount].order_id,
         order_group->protocol_groups[cust_loopcount].warning_level_bit,protocol_warning_action_clear,
         protocol_order_status_valid)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE update_normal_orders(null)
   IF (size(order_group->normal_orders,5)=0)
    RETURN
   ENDIF
   DECLARE normal_orders_cnt = i4 WITH protect, constant(size(order_group->normal_orders,5))
   DECLARE size = i2 WITH protect, constant(50)
   DECLARE ndx = i4 WITH protect, noconstant(0)
   DECLARE loop_cnt = i2 WITH protect, noconstant(ceil((cnvtreal(normal_orders_cnt)/ size)))
   DECLARE total = i4 WITH protect, noconstant((loop_cnt * size))
   DECLARE start = i4 WITH protect, noconstant(1)
   DECLARE stat = i4 WITH protect, noconstant(alterlist(order_group->normal_orders,total))
   CALL log_debug_message("starting processing of normal orders (non-Dot, non protocol orders)")
   FOR (ndx = (normal_orders_cnt+ 1) TO total)
     SET order_group->normal_orders[ndx].order_id = order_group->normal_orders[normal_orders_cnt].
     order_id
   ENDFOR
   UPDATE  FROM (dummyt d  WITH seq = value(loop_cnt)),
     orders o
    SET o.updt_cnt = (o.updt_cnt+ 1), o.updt_id = reqinfo->updt_id, o.updt_applctx = reqinfo->
     updt_applctx,
     o.updt_task = reqinfo->updt_task, o.updt_dt_tm = cnvtdatetime(current_date_time), o.person_id =
     request->xxx_combine[icombine].to_xxx_id
    PLAN (d
     WHERE initarray(start,evaluate(d.seq,1,1,(start+ size))))
     JOIN (o
     WHERE expand(ndx,start,((start+ size) - 1),o.order_id,order_group->normal_orders[ndx].order_id))
    WITH nocounter
   ;end update
   SET stat = alterlist(order_group->normal_orders,normal_orders_cnt)
   SET stat = alterlist(request->xxx_combine_det,normal_orders_cnt)
   IF (curqual=0)
    SET update_failure_ind = 1
   ELSE
    SET update_failure_ind = 0
   ENDIF
   FOR (ndx = 1 TO normal_orders_cnt)
     CALL update_parent_request(order_group->normal_orders[ndx].order_id,update_failure_ind,
      person_id_changed)
   ENDFOR
 END ;Subroutine
 SUBROUTINE update_originating_encounter_orders(null)
   IF (size(order_group->originating_encounter_orders,5)=0)
    RETURN
   ENDIF
   DECLARE originating_encounter_orders_cnt = i4 WITH protect, constant(size(order_group->
     originating_encounter_orders,5))
   CALL log_debug_message("starting processing of normal orders (non-Dot, non protocol orders)")
   UPDATE  FROM (dummyt d  WITH seq = value(originating_encounter_orders_cnt)),
     orders o
    SET o.updt_cnt = (o.updt_cnt+ 1), o.updt_id = reqinfo->updt_id, o.updt_applctx = reqinfo->
     updt_applctx,
     o.updt_task = reqinfo->updt_task, o.updt_dt_tm = cnvtdatetime(current_date_time), o
     .originating_encntr_id = 0.0
    PLAN (d)
     JOIN (o
     WHERE (o.order_id=order_group->originating_encounter_orders[d.seq].order_id))
    WITH nocounter
   ;end update
 END ;Subroutine
 SUBROUTINE process_order_groups_for_encounter_move(null)
   DECLARE cust_loopcount_dot = i4 WITH private, noconstant(0)
   DECLARE cust_loopcount = i4 WITH private, noconstant(0)
   DECLARE person_id_of_first_dot = f8 WITH private, noconstant(0.0)
   DECLARE person_id_of_all_dots_same = i2 WITH private, noconstant(1)
   DECLARE encounter_id_of_first_dot = f8 WITH private, noconstant(0.0)
   DECLARE move_all_future_siblings = i2 WITH private, noconstant(1)
   DECLARE protocol_order_status_cd = f8 WITH private, noconstant(0.0)
   DECLARE protocol_order_status_valid = i2 WITH private, noconstant(1)
   DECLARE person_id_of_protocol_after_move = f8 WITH private, noconstant(0.0)
   DECLARE person_id_of_dot_after_move = f8 WITH private, noconstant(0.0)
   CALL log_debug_message("starting order group processing for encounter move.")
   IF (size(order_group->normal_orders,5) > 0)
    CALL update_normal_orders(null)
   ENDIF
   IF (size(order_group->protocol_groups,5) > 0)
    CALL log_debug_message("Starting processing of protocol groups.")
    FOR (cust_loopcount = 1 TO size(order_group->protocol_groups,5))
      CALL log_debug_message(build2("starting processing of protocol order group: ",cust_loopcount))
      SET person_id_of_first_dot = 0.0
      SET person_id_of_all_dots_same = 1
      SET encounter_id_of_first_dot = 0.0
      SET move_all_future_siblings = 1
      SET protocol_order_status_cd = order_group->protocol_groups[cust_loopcount].order_status_cd
      SET protocol_order_status_valid = 1
      IF (((protocol_order_status_cd=canceled_order_status_cd) OR (((protocol_order_status_cd=
      voided_with_results_order_status_cd) OR (protocol_order_status_cd=
      voided_without_results_order_status_cd)) )) )
       SET protocol_order_status_valid = 0
      ENDIF
      IF ((order_group->protocol_groups[1].day_of_treatment_orders[1].encounter_id != request->
      xxx_combine[icombine].encntr_id))
       SET person_id_of_first_dot = order_group->protocol_groups[1].day_of_treatment_orders[1].
       person_id
      ELSE
       SET person_id_of_first_dot = request->xxx_combine[icombine].to_xxx_id
      ENDIF
      SET cust_loopcount_dot = 1
      WHILE (encounter_id_of_first_dot=0.0
       AND cust_loopcount_dot <= size(order_group->protocol_groups[cust_loopcount].
       day_of_treatment_orders,5))
       SET encounter_id_of_first_dot = order_group->protocol_groups[cust_loopcount].
       day_of_treatment_orders[cust_loopcount_dot].encounter_id
       SET cust_loopcount_dot += 1
      ENDWHILE
      IF (encounter_id_of_first_dot=0.0)
       CALL log_debug_message(build2("All siblings are in future status for the protocol order id: ",
         order_group->protocol_groups[cust_loopcount].order_id))
       SET move_all_future_siblings = 0
      ELSE
       SET cust_loopcount_dot = 1
       WHILE (move_all_future_siblings=1
        AND cust_loopcount_dot <= size(order_group->protocol_groups[cust_loopcount].
        day_of_treatment_orders,5))
        IF ((order_group->protocol_groups[cust_loopcount].day_of_treatment_orders[cust_loopcount_dot]
        .encounter_id != 0)
         AND (order_group->protocol_groups[cust_loopcount].day_of_treatment_orders[cust_loopcount_dot
        ].encounter_id != encounter_id_of_first_dot)
         AND (order_group->protocol_groups[cust_loopcount].day_of_treatment_orders[cust_loopcount_dot
        ].person_id != request->xxx_combine[icombine].to_xxx_id))
         SET move_all_future_siblings = 0
        ENDIF
        SET cust_loopcount_dot += 1
       ENDWHILE
      ENDIF
      CALL log_debug_message(build2("Should all future siblings be moved for protocol order id: ",
        order_group->protocol_groups[cust_loopcount].order_id," ?: ",move_all_future_siblings))
      SET cust_loopcount_dot = 1
      WHILE (person_id_of_all_dots_same=1
       AND cust_loopcount_dot <= size(order_group->protocol_groups[cust_loopcount].
       day_of_treatment_orders,5))
       IF ((((order_group->protocol_groups[cust_loopcount].day_of_treatment_orders[cust_loopcount_dot
       ].encounter_id=request->xxx_combine[icombine].encntr_id)) OR ((order_group->protocol_groups[
       cust_loopcount].day_of_treatment_orders[cust_loopcount_dot].encounter_id=0.0)
        AND move_all_future_siblings=1)) )
        CALL log_debug_message(build2(
          "Ignoring the order when calculating person_id_of_all_dots_same for protocol"," order id: ",
          order_group->protocol_groups[cust_loopcount].order_id))
       ELSE
        IF ((order_group->protocol_groups[cust_loopcount].day_of_treatment_orders[cust_loopcount_dot]
        .person_id != person_id_of_first_dot))
         SET person_id_of_all_dots_same = 0
        ENDIF
       ENDIF
       SET cust_loopcount_dot += 1
      ENDWHILE
      CALL log_debug_message(build2("Person id of all DoTs same after encounter move : ",
        person_id_of_all_dots_same))
      IF (person_id_of_all_dots_same=1)
       SET person_id_of_protocol_after_move = request->xxx_combine[icombine].to_xxx_id
      ELSE
       SET person_id_of_protocol_after_move = order_group->protocol_groups[cust_loopcount].person_id
      ENDIF
      FOR (cust_loopcount_dot = 1 TO size(order_group->protocol_groups[cust_loopcount].
       day_of_treatment_orders,5))
       IF ((order_group->protocol_groups[cust_loopcount].day_of_treatment_orders[cust_loopcount_dot].
       encounter_id=request->xxx_combine[icombine].encntr_id))
        SET person_id_of_dot_after_move = request->xxx_combine[icombine].to_xxx_id
       ELSEIF ((order_group->protocol_groups[cust_loopcount].day_of_treatment_orders[
       cust_loopcount_dot].encounter_id=0)
        AND move_all_future_siblings=1)
        SET person_id_of_dot_after_move = request->xxx_combine[icombine].to_xxx_id
       ELSE
        SET person_id_of_dot_after_move = order_group->protocol_groups[cust_loopcount].
        day_of_treatment_orders[cust_loopcount_dot].person_id
       ENDIF
       IF ((((order_group->protocol_groups[cust_loopcount].day_of_treatment_orders[cust_loopcount_dot
       ].encounter_id=request->xxx_combine[icombine].encntr_id)) OR ((order_group->protocol_groups[
       cust_loopcount].day_of_treatment_orders[cust_loopcount_dot].encounter_id=0.0)
        AND move_all_future_siblings=1)) )
        IF (person_id_of_dot_after_move=person_id_of_protocol_after_move)
         CALL log_debug_message(build2("Clear the warning flag for order id: ",order_group->
           protocol_groups[cust_loopcount].day_of_treatment_orders[cust_loopcount_dot].order_id))
         CALL update_order(order_group->protocol_groups[cust_loopcount].day_of_treatment_orders[
          cust_loopcount_dot].order_id,request->xxx_combine[icombine].to_xxx_id,order_group->
          protocol_groups[cust_loopcount].day_of_treatment_orders[cust_loopcount_dot].
          warning_level_bit,protocol_warning_action_clear,protocol_order_status_valid)
        ELSE
         CALL log_debug_message(build2("Set the warning flag for order id: ",order_group->
           protocol_groups[cust_loopcount].day_of_treatment_orders[cust_loopcount_dot].order_id))
         CALL update_order(order_group->protocol_groups[cust_loopcount].day_of_treatment_orders[
          cust_loopcount_dot].order_id,request->xxx_combine[icombine].to_xxx_id,order_group->
          protocol_groups[cust_loopcount].day_of_treatment_orders[cust_loopcount_dot].
          warning_level_bit,protocol_warning_action_set,protocol_order_status_valid)
        ENDIF
       ELSE
        IF ((order_group->protocol_groups[cust_loopcount].day_of_treatment_orders[cust_loopcount_dot]
        .encounter_id != request->xxx_combine[icombine].encntr_id)
         AND  NOT (is_protocol_level_warning_bit_set(order_group->protocol_groups[cust_loopcount].
         day_of_treatment_orders[cust_loopcount_dot].warning_level_bit)))
         CALL log_debug_message(build2("Day of treatment with order Id does not need to be updated: ",
           order_group->protocol_groups[cust_loopcount].day_of_treatment_orders[cust_loopcount_dot].
           order_id))
        ELSE
         IF (person_id_of_dot_after_move=person_id_of_protocol_after_move)
          CALL log_debug_message(build2("Clear the warning flag for order id: ",order_group->
            protocol_groups[cust_loopcount].day_of_treatment_orders[cust_loopcount_dot].order_id))
          CALL update_order_level_bitmask(order_group->protocol_groups[cust_loopcount].
           day_of_treatment_orders[cust_loopcount_dot].order_id,order_group->protocol_groups[
           cust_loopcount].day_of_treatment_orders[cust_loopcount_dot].warning_level_bit,
           protocol_warning_action_clear,protocol_order_status_valid)
         ENDIF
        ENDIF
       ENDIF
      ENDFOR
      CALL log_debug_message(build2("update protocol order id: ",order_group->protocol_groups[
        cust_loopcount].order_id))
      IF (person_id_of_all_dots_same=1)
       CALL log_debug_message(build2("Clear the warning flag for order id: ",order_group->
         protocol_groups[cust_loopcount].order_id))
       CALL update_order(order_group->protocol_groups[cust_loopcount].order_id,request->xxx_combine[
        icombine].to_xxx_id,order_group->protocol_groups[cust_loopcount].warning_level_bit,
        protocol_warning_action_clear,protocol_order_status_valid)
      ELSE
       IF ( NOT (is_protocol_level_warning_bit_set(order_group->protocol_groups[cust_loopcount].
        warning_level_bit)))
        CALL log_debug_message(build2("Set the warning flag for order id: ",order_group->
          protocol_groups[cust_loopcount].order_id))
        CALL update_order_level_bitmask(order_group->protocol_groups[cust_loopcount].order_id,
         order_group->protocol_groups[cust_loopcount].warning_level_bit,protocol_warning_action_set,
         protocol_order_status_valid)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   CALL update_originating_encounter_orders(null)
 END ;Subroutine
 SUBROUTINE (update_order_level_bitmask(order_id=f8,current_warning_level_bit=i4,
  protocol_level_warning=i2,protocol_order_status_valid=i2) =null)
   DECLARE new_warning_level_bit = i4 WITH protect, noconstant(0)
   SET new_warning_level_bit = current_warning_level_bit
   CALL log_debug_message(build2("updating update_order_level_bitmask for order_id: ",order_id,
     " with current warning_level_bit: ",current_warning_level_bit))
   IF (protocol_order_status_valid=1)
    CALL log_debug_message(build(
      "Protocol order is in valid status, calculate warning_level_bit for orderid: ",order_id))
    SET new_warning_level_bit = update_order_warning_and_bit_mask(order_id,current_warning_level_bit,
     protocol_level_warning)
   ELSE
    CALL log_debug_message(build(
      "Protocol order is not in valid status, do not update the warning_level_bit for orderid: ",
      order_id))
   ENDIF
   CALL log_debug_message(build("set warning bit to :",new_warning_level_bit," for orderid: ",
     order_id))
   UPDATE  FROM orders o
    SET o.updt_cnt = (o.updt_cnt+ 1), o.updt_id = reqinfo->updt_id, o.updt_applctx = reqinfo->
     updt_applctx,
     o.updt_task = reqinfo->updt_task, o.updt_dt_tm = cnvtdatetime(current_date_time), o
     .warning_level_bit = new_warning_level_bit
    WHERE o.order_id=order_id
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET update_failure_ind = 1
   ELSE
    SET update_failure_ind = 0
   ENDIF
   CALL update_parent_request(order_id,update_failure_ind,person_id_not_changed)
   IF (person_combine_operation_ind=1)
    CALL save_warning_level_bit(order_id,current_warning_level_bit,new_warning_level_bit)
   ENDIF
 END ;Subroutine
 SUBROUTINE (update_order_warning_and_bit_mask(order_id=f8,warning_level_bit=i4,
  protocol_level_warning=i2) =i4)
   DECLARE warning_id_to_update = f8 WITH protect, noconstant(0.0)
   DECLARE severe_protocol_warning_exists = i2 WITH protect, noconstant(0)
   DECLARE other_severe_warnings_exist = i2 WITH protect, noconstant(0)
   DECLARE severe_warning_level_flag = i2 WITH protect, constant(1)
   DECLARE protocol_warning_type_flag = i2 WITH protect, constant(1)
   DECLARE protocol_patient_mismatch_bitmask = i2 WITH protect, constant(8)
   DECLARE severe_warning_bitmask = i2 WITH protect, constant(1)
   SELECT INTO "nl:"
    ow.order_id, ow.warning_level_flag, ow.warning_type_flag
    FROM order_warning ow
    PLAN (ow
     WHERE ow.order_id=order_id
      AND ((ow.warning_level_flag+ 0)=severe_warning_level_flag)
      AND ow.active_ind=1)
    DETAIL
     IF (ow.warning_type_flag=protocol_warning_type_flag)
      severe_protocol_warning_exists = 1, warning_id_to_update = ow.order_warning_id
     ELSE
      other_severe_warnings_exist = 1
     ENDIF
    WITH forupdatewait(ow)
   ;end select
   IF (protocol_level_warning=protocol_warning_action_set)
    IF (severe_protocol_warning_exists=1)
     CALL log_debug_message(build2("Updating the row in order warning table with warning id: ",
       warning_id_to_update," for          	order id: ",order_id))
     UPDATE  FROM order_warning ow
      SET ow.updt_cnt = (ow.updt_cnt+ 1), ow.updt_id = reqinfo->updt_id, ow.updt_task = reqinfo->
       updt_task,
       ow.updt_applctx = reqinfo->updt_applctx, ow.updt_dt_tm = cnvtdatetime(current_date_time)
      WHERE ow.order_warning_id=warning_id_to_update
      WITH nocounter
     ;end update
    ELSE
     CALL log_debug_message(build2("Inserting a row in order warning table for order id: ",order_id))
     DECLARE next_warning_id = f8 WITH protect, noconstant(0.0)
     SET next_warning_id = get_next_available_warning_id(null)
     CALL log_debug_message(build2("next warning_id: ",next_warning_id))
     INSERT  FROM order_warning ow
      SET ow.order_warning_id = next_warning_id, ow.updt_cnt = 0, ow.updt_id = reqinfo->updt_id,
       ow.updt_task = reqinfo->updt_task, ow.updt_applctx = reqinfo->updt_applctx, ow.updt_dt_tm =
       cnvtdatetime(current_date_time),
       ow.warning_level_flag = severe_warning_level_flag, ow.warning_type_flag =
       protocol_warning_type_flag, ow.active_ind = 1,
       ow.order_id = order_id
      WITH nocounter
     ;end insert
    ENDIF
    RETURN(bor(warning_level_bit,(protocol_patient_mismatch_bitmask+ severe_warning_bitmask)))
   ELSEIF (protocol_level_warning=protocol_warning_action_clear)
    IF (warning_id_to_update > 0.0)
     CALL log_debug_message(build2("Deleting the row in order warning table with warning id: ",
       warning_id_to_update,"          	 for order id: ",order_id))
     DELETE  FROM order_warning ow
      WHERE ow.order_warning_id=warning_id_to_update
      WITH nocounter
     ;end delete
    ENDIF
    IF (other_severe_warnings_exist=1)
     CALL log_debug_message(build2("set the warning_bit(clear bit 3 only) to ",band(warning_level_bit,
        (order_warning_full_mask_set - protocol_patient_mismatch_bitmask))," for order id: ",order_id
       ))
     RETURN(band(warning_level_bit,(order_warning_full_mask_set - protocol_patient_mismatch_bitmask))
     )
    ELSE
     CALL log_debug_message(build2("set the warning_bit(clear bit 3 & bit 0) to ",band(
        warning_level_bit,(order_warning_full_mask_set - (protocol_patient_mismatch_bitmask+
        severe_warning_bitmask)))," for order id: ",order_id))
     RETURN(band(warning_level_bit,(order_warning_full_mask_set - (protocol_patient_mismatch_bitmask
      + severe_warning_bitmask))))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (update_order(order_id=f8,person_id=f8,current_warning_level_bit=i4,
  protocol_level_warning=i2,protocol_order_status_valid=i2) =null)
   DECLARE new_warning_level_bit = i4 WITH protect, noconstant(0)
   SET new_warning_level_bit = current_warning_level_bit
   CALL log_debug_message(build2("updating order_level_bitmask for order_id: ",order_id,
     " with current warning_level_bit: ",current_warning_level_bit))
   CALL log_debug_message(build2("updating person_id to :",person_id," for order_id: ",order_id))
   IF (protocol_order_status_valid=1)
    CALL log_debug_message(build(
      "Protocol order is in valid status, calculate warning_level_bit for orderid: ",order_id))
    SET new_warning_level_bit = update_order_warning_and_bit_mask(order_id,current_warning_level_bit,
     protocol_level_warning)
   ELSE
    CALL log_debug_message(build(
      "Protocol order is not in valid status, do not update the warning_level_bit for orderid: ",
      order_id))
   ENDIF
   CALL log_debug_message(build("set warning bit to :",new_warning_level_bit," for orderid: ",
     order_id))
   UPDATE  FROM orders o
    SET o.updt_cnt = (o.updt_cnt+ 1), o.updt_id = reqinfo->updt_id, o.updt_applctx = reqinfo->
     updt_applctx,
     o.updt_task = reqinfo->updt_task, o.updt_dt_tm = cnvtdatetime(current_date_time), o.person_id =
     person_id,
     o.warning_level_bit = new_warning_level_bit
    WHERE o.order_id=order_id
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET update_failure_ind = 1
   ELSE
    SET update_failure_ind = 0
   ENDIF
   CALL update_parent_request(order_id,update_failure_ind,person_id_changed)
   IF (person_combine_operation_ind=1)
    CALL save_warning_level_bit(order_id,current_warning_level_bit,new_warning_level_bit)
   ENDIF
 END ;Subroutine
 SUBROUTINE (save_warning_level_bit(order_id=f8,original_warning_level_bit=i4,new_warning_level_bit=
  i4) =null)
   DECLARE breturn = i2 WITH private, noconstant(0)
   CALL log_debug_message(build2("Saving warning_level_bit: ",original_warning_level_bit,
     " for order_id: ",order_id))
   SET breturn = cmb_save_column_value("ORDERS",order_id,"WARNING_LEVEL_BIT","I4",build(
     original_warning_level_bit),
    build(new_warning_level_bit))
   IF (breturn=0)
    SET failed = insert_error
    SET request->error_message = substring(1,132,build2(
      "Couldn't insert COMBINE_DET_VALUE record with ENTITY_ID = ",order_id))
    GO TO exit_sub
   ENDIF
 END ;Subroutine
 SUBROUTINE (update_order_move_only(order_id=f8,person_id=f8,current_warning_level_bit=i4) =null)
   CALL log_debug_message(build2("updating person_id to :",person_id," for order_id: ",order_id))
   UPDATE  FROM orders o
    SET o.updt_cnt = (o.updt_cnt+ 1), o.updt_id = reqinfo->updt_id, o.updt_applctx = reqinfo->
     updt_applctx,
     o.updt_task = reqinfo->updt_task, o.updt_dt_tm = cnvtdatetime(current_date_time), o.person_id =
     person_id
    WHERE o.order_id=order_id
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET update_failure_ind = 1
   ELSE
    SET update_failure_ind = 0
   ENDIF
   CALL update_parent_request(order_id,update_failure_ind,person_id_changed)
   IF (person_combine_operation_ind=1)
    CALL save_warning_level_bit(order_id,current_warning_level_bit,current_warning_level_bit)
   ENDIF
 END ;Subroutine
 SUBROUTINE (update_parent_request(order_id=f8,update_failure_ind=i2,person_id_not_changed=i2) =null)
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_id = order_id
   SET request->xxx_combine_det[icombinedet].entity_name = "ORDERS"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   IF (update_failure_ind=1)
    SET failed = update_error
    SET request->error_message = substring(1,132,build2("Could not update pk val=",order_id))
    GO TO exit_sub
   ENDIF
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
 SUBROUTINE (is_protocol_level_warning_bit_set(bitmask=i4) =i2)
   IF (band(bitmask,protocol_warning_level_bit_mask)=protocol_warning_level_bit_mask)
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
#exit_sub
 FREE SET order_group
END GO
