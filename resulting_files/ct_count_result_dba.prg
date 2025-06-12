CREATE PROGRAM ct_count_result:dba
 CALL echo("executing ct_count_result")
 SET ct_count_result_version = "92657.MOD.005"
 FREE SET request5
 RECORD request5(
   1 ct_rule_id = f8
   1 charge_item_id = f8
   1 charge_description = c200
   1 item_price = f8
   1 item_extended_price = f8
   1 process_flg = i4
   1 item_quantity = f8
   1 service_dt_tm = dq8
 )
 FREE SET reply_adjustment
 RECORD reply_adjustment(
   1 new_charge_item_id = f8
   1 charge_mod_qual = i2
   1 charge_mods[*]
     2 charge_mod_id = f8
 )
 FREE SET reply_bundle_history
 RECORD reply_bundle_history(
   1 charge_qual = i2
   1 charges[*]
     2 charge_item_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply_bundle_history->status_data.status = "F"
 SET table_name = "CT_BUNDLE_HISTORY"
 SET result = 0.00
 SET g_ref_id = 0.00
 SET g_ref_cd = 0.00
 FREE SET ct_result
 RECORD ct_result(
   1 rule_id = f8
   1 rules[*] = f8
     2 res = f8
     2 g_ref_id = f8
     2 g_ref_cd = f8
     2 price = f8
     2 operator = f8
     2 res_factor = f8
     2 count_beg = i4
     2 count_end = i4
 )
 FREE SET ct_request
 RECORD ct_request(
   1 ref_id = f8
   1 ref_cont_cd = f8
   1 person_id = f8
   1 encntr_id = f8
   1 quantity = i4
   1 order_id = f8
   1 ord_phys_id = f8
   1 perf_phys_id = f8
   1 verify_phys_id = f8
   1 ref_phys_id = f8
   1 service_dt_tm = dq8
   1 service_res_cd = f8
 )
 FREE SET ct_reply
 RECORD ct_reply(
   1 charges[*]
     2 charge_item_id = f8
     2 process_flg = i4
 )
 SET num_results = 0
 CALL echo("the rule_id is:")
 CALL echo(request2->rule_id)
 SET request5->ct_rule_id = request2->rule_id
 SELECT INTO "nl:"
  FROM ct_rule_detail ct
  WHERE (ct.ct_rule_id=request2->rule_id)
   AND (ct.detail_type_cd=code_val->15729_result)
  DETAIL
   num_results = (num_results+ 1), stat = alterlist(ct_result->rules,num_results), ct_result->rule_id
    = ct.ct_rule_id,
   ct_result->rules[num_results].res = ct.rule_entity_id, ct_result->rules[num_results].res_factor =
   ct.result_factor, ct_result->rules[num_results].operator = ct.operator_cd,
   ct_result->rules[num_results].count_beg = ct.count_beg, ct_result->rules[num_results].count_end =
   ct.count_end
  WITH nocounter
 ;end select
 FOR (count_result_num = 1 TO num_results)
   CALL echo("the rule is ")
   CALL echo(ct_result->rule_id)
   CALL echo("the result is ")
   CALL echo(ct_result->rules[count_result_num].res)
   CALL echo("the operator is ")
   CALL echo(ct_result->rules[count_result_num].operator)
   CALL echo("the result factor is ")
   CALL echo(ct_result->rules[count_result_num].res_factor)
   CALL echo("count_beg is ")
   CALL echo(ct_result->rules[count_result_num].count_beg)
   CALL echo("count_end is ")
   CALL echo(ct_result->rules[count_result_num].count_end)
 ENDFOR
 SET real_quantity = 0
 CALL echo("the charge qual is this before the loop")
 CALL echo(request2->charge_qual)
 FOR (ct_charge_count_qual = 1 TO request2->charge_qual)
   IF ((request2->charges[ct_charge_count_qual].item_quantity != 0))
    SET real_quantity = (request2->charges[ct_charge_count_qual].item_quantity+ real_quantity)
   ELSE
    SET real_quantity = (real_quantity+ 1)
   ENDIF
 ENDFOR
 CALL echo(build("the real quantity is : ",real_quantity))
 SET new_bundle_id = 0
 SELECT INTO "nl:"
  newnum = seq(bundle_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   new_bundle_id = cnvtint(newnum)
  WITH format, nocounter
 ;end select
 IF (curqual=0)
  SET failed = true
  GO TO end_prog
 ENDIF
 CALL echo(build("New Bundle Id: ",new_bundle_id))
 SET bundle_dt_tm = cnvtdatetime(curdate,curtime3)
 FOR (j = 1 TO request2->charge_qual)
   SET reply_bundle_history->status_data.status = "S"
   SET request2->bundle_id = new_bundle_id
   UPDATE  FROM charge_mod cm
    SET cm.field4_id = ct_result->rule_id
    WHERE (cm.charge_item_id=request2->charges[j].charge_item_id)
   ;end update
   CALL echo(build("Updating process_flg and adding bundle_id: ",request2->charges[j].charge_item_id)
    )
   UPDATE  FROM charge c
    SET c.process_flg = 777, c.bundle_id = new_bundle_id
    WHERE (c.charge_item_id=request2->charges[j].charge_item_id)
   ;end update
 ENDFOR
 FOR (count_rules_result = 1 TO num_results)
   SELECT INTO "nl:"
    FROM bill_item b
    WHERE (b.bill_item_id=ct_result->rules[count_rules_result].res)
     AND active_ind=1
    DETAIL
     ct_result->rules[count_rules_result].g_ref_id = b.ext_parent_reference_id,
     CALL echo(build("ref id in loop is: ",ct_result->rules[count_rules_result].g_ref_id)), ct_result
     ->rules[count_rules_result].g_ref_cd = b.ext_parent_contributor_cd,
     CALL echo(build("ref cd in loop is: ",ct_result->rules[count_rules_result].g_ref_cd))
    WITH nocounter
   ;end select
 ENDFOR
 SELECT INTO "nl:"
  FROM charge c,
   charge_event_act cea
  PLAN (c
   WHERE (c.charge_item_id=request2->charges[1].charge_item_id))
   JOIN (cea
   WHERE cea.charge_event_act_id=c.charge_event_act_id)
  DETAIL
   ct_request->order_id = c.order_id, ct_request->ord_phys_id = c.ord_phys_id, ct_request->
   perf_phys_id = c.perf_phys_id,
   ct_request->verify_phys_id = c.verify_phys_id, ct_request->ref_phys_id = c.ref_phys_id, ct_request
   ->service_res_cd = cea.service_resource_cd
  WITH nocounter
 ;end select
 FOR (count_rules_result2 = 1 TO num_results)
   IF ((ct_result->rules[count_rules_result2].count_end != 0))
    IF (real_quantity BETWEEN ct_result->rules[count_rules_result2].count_beg AND ct_result->rules[
    count_rules_result2].count_end)
     IF ((ct_result->rules[count_rules_result2].operator=code_val->18851_equal))
      CALL equal_op_cd(count_rules_result2)
     ELSEIF ((ct_result->rules[count_rules_result2].operator=code_val->18851_and))
      CALL and_op_cd(count_rules_result2)
      CALL echo("made it to and")
     ELSEIF ((ct_result->rules[count_rules_result2].operator=code_val->18851_nochange))
      CALL nochange_op_cd(count_rules_result2)
     ELSE
      CALL echo("code value not found")
     ENDIF
    ENDIF
   ELSE
    IF ((real_quantity >= ct_result->rules[count_rules_result2].count_beg))
     IF ((ct_result->rules[count_rules_result2].operator=code_val->18851_equal))
      CALL equal_op_cd(count_rules_result2)
     ELSEIF ((ct_result->rules[count_rules_result2].operator=code_val->18851_and))
      CALL and_op_cd(count_rules_result2)
      CALL echo("made it to and")
     ELSEIF ((ct_result->rules[count_rules_result2].operator=code_val->18851_nochange))
      CALL nochange_op_cd(count_rules_result2)
     ELSE
      CALL echo("code value not found")
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SUBROUTINE equal_op_cd(num)
   SET request5->ct_rule_id = request2->rule_id
   SET request5->charge_item_id = request2->charges[1].charge_item_id
   SET request5->process_flg = 0
   SET request5->item_quantity = ct_result->rules[num].res_factor
   SET request5->service_dt_tm = request2->charges[1].service_dt_tm
   EXECUTE afc_add_adjustment_ct_new
   UPDATE  FROM charge c
    SET c.process_flg = 777, c.bundle_id = new_bundle_id
    WHERE (c.charge_item_id=request5->charge_item_id)
   ;end update
   UPDATE  FROM charge c
    SET c.bundle_id = new_bundle_id
    WHERE (c.charge_item_id=reply_adjustment->new_charge_item_id)
   ;end update
   SET temp = (1+ request2->charge_qual)
   SET request2->charge_qual = temp
   SET stat = alterlist(request2->charges,temp)
   SET request2->charges[temp].charge_item_id = reply_adjustment->new_charge_item_id
   FOR (h = 1 TO reply_adjustment->charge_mod_qual)
     UPDATE  FROM charge_mod cm
      SET cm.field4_id = ct_result->rule_id
      WHERE (cm.charge_mod_id=reply_adjustment->charge_mods[h].charge_mod_id)
     ;end update
   ENDFOR
 END ;Subroutine
 SUBROUTINE and_op_cd(num)
   SET ct_request->person_id = request2->person_id
   CALL echo(build("the person_id is :",ct_request->person_id))
   SET ct_request->encntr_id = request2->encntr_id
   CALL echo(build("the encntr_id is :",ct_request->encntr_id))
   IF ((ct_result->rules[num].res_factor=0))
    SET ct_request->quantity = real_quantity
   ELSEIF ((ct_result->rules[num].res_factor > 0))
    SET ct_request->quantity = ct_result->rules[num].res_factor
   ELSE
    SET ct_request->quantity = (real_quantity+ ct_result->rules[num].res_factor)
   ENDIF
   CALL echo(build("the quantity is :",ct_request->quantity))
   SET ct_request->ref_id = ct_result->rules[num].g_ref_id
   CALL echo(build("the ref_id is :",ct_request->ref_id))
   SET ct_request->ref_cont_cd = ct_result->rules[num].g_ref_cd
   CALL echo(build("the ref_cont_cd is :",ct_request->ref_cont_cd))
   SET ct_request->service_dt_tm = request2->charges[1].service_dt_tm
   CALL echo(build("the service_dt_tm is :",ct_request->service_dt_tm))
   CALL echo("executing ct_create_result_charge")
   EXECUTE ct_create_result_charge
   UPDATE  FROM charge c
    SET c.process_flg = 777, c.bundle_id = new_bundle_id
    WHERE (c.charge_item_id=request5->charge_item_id)
   ;end update
   CALL echo("the new charge_item_id is :")
   CALL echo(ct_reply->charges[1].charge_item_id)
   CALL echo("the new process_flg is :")
   CALL echo(ct_reply->charges[1].process_flg)
   UPDATE  FROM charge c
    SET c.bundle_id = new_bundle_id
    WHERE (c.charge_item_id=ct_reply->charges[1].charge_item_id)
   ;end update
   UPDATE  FROM charge_mod cm
    SET cm.field4_id = ct_result->rule_id
    WHERE (cm.charge_item_id=ct_reply->charges[1].charge_item_id)
   ;end update
   CALL echo(build("Updating new charge: ",ct_reply->charges[1].charge_item_id))
   SET temp = (1+ request2->charge_qual)
   SET request2->charge_qual = temp
   SET stat = alterlist(request2->charges,temp)
   SET request2->charges[temp].charge_item_id = ct_reply->charges[1].charge_item_id
   CALL echo(build("the new charge_item_id is : ",ct_reply->charges[1].charge_item_id))
 END ;Subroutine
 SUBROUTINE nochange_op_cd(num)
   SET request5->ct_rule_id = request2->rule_id
   SET request5->charge_item_id = request2->charges[1].charge_item_id
   SET request5->process_flg = 0
   SET request5->item_quantity = real_quantity
   SET request5->service_dt_tm = request2->charges[1].service_dt_tm
   EXECUTE afc_add_adjustment_ct_new
   UPDATE  FROM charge c
    SET c.process_flg = 777, c.bundle_id = new_bundle_id
    WHERE (c.charge_item_id=request5->charge_item_id)
   ;end update
   UPDATE  FROM charge c
    SET c.bundle_id = new_bundle_id
    WHERE (c.charge_item_id=reply_adjustment->new_charge_item_id)
   ;end update
   SET temp = (1+ request2->charge_qual)
   SET request2->charge_qual = temp
   SET stat = alterlist(request2->charges,temp)
   SET request2->charges[temp].charge_item_id = reply_adjustment->new_charge_item_id
   FOR (h = 1 TO reply_adjustment->charge_mod_qual)
     UPDATE  FROM charge_mod cm
      SET cm.field4_id = ct_result->rule_id
      WHERE (cm.charge_mod_id=reply_adjustment->charge_mods[h].charge_mod_id)
     ;end update
   ENDFOR
 END ;Subroutine
 SET action_beg = 1
 SET action_end = request2->charge_qual
 CALL add_ct_bundle_history(action_beg,action_end)
 CALL echo(build("CHARGEQUAL IS :",request2->charge_qual))
 SET reply_bundle_history->charge_qual = request2->charge_qual
 SUBROUTINE add_ct_bundle_history(add_begin,add_end)
   FOR (k = add_begin TO add_end)
     SET blank_date = cnvtdatetime("01-JAN-1800 00:00:00.00")
     SET active_code = 0.0
     IF ((request2->charges[k].active_status_cd=0))
      SELECT INTO "nl:"
       FROM code_value c
       WHERE c.code_set=48
        AND c.cdf_meaning="ACTIVE"
       DETAIL
        active_code = c.code_value
       WITH nocounter
      ;end select
     ENDIF
     INSERT  FROM ct_bundle_history c
      SET c.ct_bundle_history_id = cnvtreal(seq(bundle_seq,nextval)), c.bundle_id = new_bundle_id, c
       .bundle_dt_tm = cnvtdatetime(bundle_dt_tm),
       c.to_charge_item_id =
       IF ((request2->charges[k].detail_type_cd <= 0)) request2->charges[k].charge_item_id
       ELSE 0
       ENDIF
       , c.from_charge_item_id =
       IF ((request2->charges[k].detail_type_cd > 0)) request2->charges[k].charge_item_id
       ELSE 0
       ENDIF
       , c.ct_rule_id = request2->rule_id,
       c.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), c.end_effective_dt_tm = cnvtdatetime(
        "31-DEC-2100 00:00:00.00"), c.active_ind = true,
       c.active_status_cd = active_code, c.active_status_prsnl_id = reqinfo->updt_id, c
       .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
       c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id,
       c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = true
      RETURN
     ELSE
      SET stat = alterlist(reply_bundle_history->charges,k)
      SET reply_bundle_history->charges[k].charge_item_id = request2->charges[k].charge_item_id
     ENDIF
   ENDFOR
 END ;Subroutine
 COMMIT
 IF (failed != false)
  GO TO check_error
 ENDIF
#check_error
 IF (failed=false)
  SET reply_bundle_history->status_data.status = "S"
 ELSE
  CASE (failed)
   OF gen_nbr_error:
    SET reply_bundle_history->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF insert_error:
    SET reply_bundle_history->status_data.subeventstatus[1].operationname = "INSERT"
   OF update_error:
    SET reply_bundle_history->status_data.subeventstatus[1].operationname = "UPDATE"
   OF replace_error:
    SET reply_bundle_history->status_data.subeventstatus[1].operationname = "REPLACE"
   OF delete_error:
    SET reply_bundle_history->status_data.subeventstatus[1].operationname = "DELETE"
   OF undelete_error:
    SET reply_bundle_history->status_data.subeventstatus[1].operationname = "UNDELETE"
   OF remove_error:
    SET reply_bundle_history->status_data.subeventstatus[1].operationname = "REMOVE"
   OF attribute_error:
    SET reply_bundle_history->status_data.subeventstatus[1].operationname = "ATTRIBUTE"
   OF lock_error:
    SET reply_bundle_history->status_data.subeventstatus[1].operationname = "LOCK"
   ELSE
    SET reply_bundle_history->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply_bundle_history->status_data.subeventstatus[1].operationstatus = "F"
  SET reply_bundle_history->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply_bundle_history->status_data.subeventstatus[1].targetobjectvalue = table_name
 ENDIF
 GO TO end_prog
#end_prog
 IF (failed=true)
  CALL echo("script failure")
 ELSE
  SET reply_bundle_history->status_data.status = "S"
  SET cnt = 0
 ENDIF
END GO
