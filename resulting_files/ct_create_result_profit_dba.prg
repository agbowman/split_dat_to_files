CREATE PROGRAM ct_create_result_profit:dba
 CALL echo("executing ct_create_result_profit")
 SET ct_create_result_profit_version = "92657.MOD.009"
 FREE SET request
 RECORD request(
   1 ct_rule_id = f8
   1 charge_item_id = f8
   1 charge_description = c200
   1 item_price = f8
   1 item_extended_price = f8
   1 process_flg = i4
   1 item_quantity = f8
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
 FREE SET reply_adjustment
 RECORD reply_adjustment(
   1 new_charge_item_id = f8
   1 charge_mod_qual = i2
   1 charge_mods[*]
     2 charge_mod_id = f8
 )
 FREE SET request_quant
 RECORD request_quant(
   1 charge_item_id = f8
 )
 FREE SET reply_quant
 RECORD reply_quant(
   1 charge_item_id = f8
   1 charge_mod_qual = i2
   1 charge_mods[*]
     2 charge_mod_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 FREE SET profit_request
 RECORD profit_request(
   1 charge_qual = i2
   1 charges[*]
     2 charge_item_id = f8
     2 reprocess_ind = i2
     2 dupe_ind = i2
 )
 FREE SET profit_reply
 RECORD profit_reply(
   1 success_ind = i4
   1 failed_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD tempinterfacerequest(
   1 interface_charge[*]
     2 charge_item_id = f8
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
 SET request->ct_rule_id = request2->rule_id
 SELECT INTO "nl:"
  FROM ct_rule_detail ct
  WHERE (ct.ct_rule_id=request2->rule_id)
   AND (ct.detail_type_cd=code_val->15729_result)
  DETAIL
   num_results = (num_results+ 1), stat = alterlist(ct_result->rules,num_results), ct_result->rule_id
    = ct.ct_rule_id,
   ct_result->rules[num_results].res = ct.rule_entity_id
  WITH nocounter
 ;end select
 FOR (create_result_num_profit = 1 TO num_results)
   CALL echo("the rule is ")
   CALL echo(ct_result->rule_id)
   CALL echo("the result is ")
   CALL echo(ct_result->rules[create_result_num_profit].res)
 ENDFOR
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
 SET ct_order = 0.0
 SELECT INTO "nl:"
  FROM charge c,
   charge_event_act cea
  PLAN (c
   WHERE (c.charge_item_id=request2->charges[1].charge_item_id))
   JOIN (cea
   WHERE cea.charge_event_act_id=c.charge_event_act_id)
  DETAIL
   ct_order = c.order_id, ct_request->service_res_cd = cea.service_resource_cd
  WITH nocounter
 ;end select
 SET ct_request->order_id = ct_order
 FOR (w = 1 TO request2->charge_qual)
   IF ((request2->charges[w].item_quantity > 1))
    SET request_quant->charge_item_id = request2->charges[w].charge_item_id
    CALL echo("executing ct_handle_quant")
    EXECUTE ct_handle_quant_profit
    SET request2->charges[w].charge_item_id = reply_quant->charge_item_id
    SET request2->charges[w].item_quantity = 1
   ENDIF
 ENDFOR
 IF ((tier->tier_list[crct].rule_list[crct2].action_meaning="REPLACELIST"))
  CALL echo("REPLACELIST")
  CALL echo("num_results before the for loop is:")
  CALL echo(num_results)
  FOR (create_result_num_profit2 = 1 TO num_results)
    SELECT INTO "nl:"
     FROM bill_item b
     WHERE (b.bill_item_id=ct_result->rules[create_result_num_profit2].res)
      AND active_ind=1
     DETAIL
      ct_result->rules[create_result_num_profit2].g_ref_id = b.ext_parent_reference_id,
      CALL echo(build("ref id in loop is: ",ct_result->rules[create_result_num_profit2].g_ref_id)),
      ct_result->rules[create_result_num_profit2].g_ref_cd = b.ext_parent_contributor_cd,
      CALL echo(build("ref cd in loop is: ",ct_result->rules[create_result_num_profit2].g_ref_id))
     WITH nocounter
    ;end select
  ENDFOR
  FOR (j = 1 TO request2->charge_qual)
    SET reply_bundle_history->status_data.status = "S"
    SET request2->bundle_id = new_bundle_id
    IF ((request2->charges[j].process_flg=100))
     UPDATE  FROM charge c
      SET c.process_flg = 177, c.bundle_id = new_bundle_id
      WHERE (c.charge_item_id=request2->charges[j].charge_item_id)
     ;end update
    ELSE
     UPDATE  FROM charge c
      SET c.process_flg = 977, c.bundle_id = new_bundle_id
      WHERE (c.charge_item_id=request2->charges[j].charge_item_id)
     ;end update
    ENDIF
    UPDATE  FROM charge_mod cm
     SET cm.field4_id = ct_result->rule_id
     WHERE (cm.charge_item_id=request2->charges[j].charge_item_id)
    ;end update
    CALL echo(build("Updating process_flg and adding bundle_id: ",request2->charges[j].charge_item_id
      ))
    SET ct_request->service_dt_tm = cnvtdatetime(request2->charges[j].service_dt_tm)
  ENDFOR
  FOR (create_result_num_profit3 = 1 TO num_results)
    SET ct_request->person_id = request2->person_id
    CALL echo(build("the person_id is :",ct_request->person_id))
    SET ct_request->encntr_id = request2->encntr_id
    CALL echo(build("the encntr_id is :",ct_request->encntr_id))
    SET ct_request->quantity = 1
    SET ct_request->ref_id = ct_result->rules[create_result_num_profit3].g_ref_id
    CALL echo(build("the ref_id is :",ct_request->ref_id))
    SET ct_request->ref_cont_cd = ct_result->rules[create_result_num_profit3].g_ref_cd
    CALL echo(build("the ref_cont_cd is :",ct_request->ref_cont_cd))
    CALL echo("CT_CREATE_RESULT_PROFIT::CALLING CT_CREATE_RESULT_CHARGE*****************")
    EXECUTE ct_create_result_charge
    IF ((ct_reply->charges[1].process_flg=100))
     SET profit_request->charge_qual = 1
     SET stat = alterlist(profit_request->charges,1)
     SET stat = alterlist(ct_reply->charges,1)
     SET profit_request->charges[1].charge_item_id = ct_reply->charges[1].charge_item_id
     EXECUTE pft_nt_chrg_billing  WITH replace("REQUEST",profit_request), replace("REPLY",
      profit_reply)
    ELSE
     SET nrealtimeind = 0
     SELECT INTO "nl:"
      FROM charge c,
       interface_file i
      PLAN (c
       WHERE (c.charge_item_id=ct_reply->charges[1].charge_item_id))
       JOIN (i
       WHERE i.interface_file_id=c.interface_file_id
        AND i.realtime_ind=1)
      DETAIL
       nrealtimeind = 1
      WITH nocounter
     ;end select
     IF (nrealtimeind=1)
      EXECUTE afc_srv_interface_charge  WITH replace("REQUEST",tempinterfacerequest)
     ENDIF
    ENDIF
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
  ENDFOR
 ELSEIF ((tier->tier_list[crct].rule_list[crct2].action_meaning="REPLACEPRICE"))
  CALL echo("replaceprice")
  CALL echo(" ")
  FOR (g = 1 TO num_results)
    SELECT INTO "nl:"
     FROM ct_rule_detail ct
     WHERE (ct.rule_entity_id=request2->charges[g].rule_entity_id)
      AND (ct.detail_type_cd=code_val->15729_result)
     DETAIL
      request->item_quantity = request2->charges[g].item_quantity, request->item_price = ct
      .result_factor, request->charge_item_id = request2->charges[g].charge_item_id,
      request->process_flg = 0
     WITH nocounter
    ;end select
    EXECUTE ct_adjust_profit_charge
    IF ((request2->charges[1].process_flg=100))
     UPDATE  FROM charge c
      SET c.process_flg = 177, c.bundle_id = new_bundle_id
      WHERE (c.charge_item_id=request2->charges[g].charge_item_id)
     ;end update
    ELSE
     UPDATE  FROM charge c
      SET c.process_flg = 977, c.bundle_id = new_bundle_id
      WHERE (c.charge_item_id=request2->charges[g].charge_item_id)
     ;end update
    ENDIF
    UPDATE  FROM charge c
     SET c.bundle_id = new_bundle_id
     WHERE (c.charge_item_id=reply_adjustment->new_charge_item_id)
    ;end update
    SET temp = (1+ request2->charge_qual)
    SET request2->charge_qual = temp
    SET stat = alterlist(request2->charges,temp)
    SET request2->charges[temp].charge_item_id = reply_adjustment->new_charge_item_id
    CALL echo(build("running through result loop the : ",g,"time"))
    CALL echo(" ")
    FOR (h = 1 TO reply_adjustment->charge_mod_qual)
      UPDATE  FROM charge_mod
       SET field4_id = ct_result->rule_id
       WHERE (charge_mod_id=reply_adjustment->charge_mods[h].charge_mod_id)
      ;end update
    ENDFOR
  ENDFOR
 ELSEIF ((tier->tier_list[crct].rule_list[crct2].action_meaning="REPLACEADJST"))
  CALL echo("replaceadjst")
  CALL echo(" ")
  FOR (g = 1 TO num_results)
    SELECT INTO "nl:"
     FROM ct_rule_detail ct
     WHERE (ct.rule_entity_id=request2->charges[g].rule_entity_id)
      AND (ct.detail_type_cd=code_val->15729_result)
     DETAIL
      IF ((ct.operator_cd=code_val->18851_multiply))
       request->item_price = (request2->charges[g].item_price * ct.result_factor)
      ELSEIF ((ct.operator_cd=code_val->18851_add))
       request->item_price = (request2->charges[g].item_price+ ct.result_factor)
      ELSEIF ((ct.operator_cd=code_val->172986_subtraction))
       request->item_price = (request2->charges[g].item_price - ct.result_factor)
      ELSEIF ((ct.operator_cd=code_val->18851_equal))
       request->item_price = ct.result_factor
      ENDIF
      request->item_quantity = request2->charges[g].item_quantity, request->charge_item_id = request2
      ->charges[g].charge_item_id, request->process_flg = 0
     WITH nocounter
    ;end select
    EXECUTE ct_adjust_profit_charge
    IF ((request2->charges[1].process_flg=100))
     UPDATE  FROM charge c
      SET c.process_flg = 177, c.bundle_id = new_bundle_id
      WHERE (c.charge_item_id=request2->charges[g].charge_item_id)
     ;end update
    ELSE
     UPDATE  FROM charge c
      SET c.process_flg = 977, c.bundle_id = new_bundle_id
      WHERE (c.charge_item_id=request2->charges[g].charge_item_id)
     ;end update
    ENDIF
    UPDATE  FROM charge c
     SET c.bundle_id = new_bundle_id
     WHERE (c.charge_item_id=reply_adjustment->new_charge_item_id)
    ;end update
    SET temp = (1+ request2->charge_qual)
    SET request2->charge_qual = temp
    SET stat = alterlist(request2->charges,temp)
    SET request2->charges[temp].charge_item_id = reply_adjustment->new_charge_item_id
    FOR (h = 1 TO reply_adjustment->charge_mod_qual)
      UPDATE  FROM charge_mod
       SET field4_id = ct_result->rule_id
       WHERE (charge_mod_id=reply_adjustment->charge_mods[h].charge_mod_id)
      ;end update
    ENDFOR
  ENDFOR
 ELSEIF ((tier->tier_list[crct].rule_list[crct2].action_meaning="MODIFYLIST"))
  CALL echo("modifylist")
  CALL echo(" ")
  FOR (g = 1 TO num_results)
    SET do_nothing = 0
    SELECT INTO "nl:"
     FROM ct_rule_detail ct
     WHERE (ct.rule_entity_id=request2->charges[g].rule_entity_id)
      AND (ct.detail_type_cd=code_val->15729_result)
     DETAIL
      IF ((ct.operator_cd=code_val->18851_multiply))
       request->item_price = (request2->charges[g].item_price * ct.result_factor)
      ELSEIF ((ct.operator_cd=code_val->18851_add))
       request->item_price = (request2->charges[g].item_price+ ct.result_factor)
      ELSEIF ((ct.operator_cd=code_val->172986_subtraction))
       request->item_price = (request2->charges[g].item_price - ct.result_factor)
      ELSEIF ((ct.operator_cd=code_val->18851_nochange))
       request->item_price = request2->charges[g].item_price
      ELSEIF ((ct.operator_cd=code_val->18851_remove))
       do_nothing = 1
      ENDIF
      request->item_quantity = request2->charges[g].item_quantity, request->charge_item_id = request2
      ->charges[g].charge_item_id, request->process_flg = 0
     WITH nocounter
    ;end select
    IF (do_nothing != 1)
     EXECUTE ct_adjust_profit_charge
     UPDATE  FROM charge c
      SET c.bundle_id = new_bundle_id
      WHERE (c.charge_item_id=reply_adjustment->new_charge_item_id)
     ;end update
     SET temp = (1+ request2->charge_qual)
     SET request2->charge_qual = temp
     SET stat = alterlist(request2->charges,temp)
     SET request2->charges[temp].charge_item_id = reply_adjustment->new_charge_item_id
     FOR (h = 1 TO reply_adjustment->charge_mod_qual)
       UPDATE  FROM charge_mod
        SET field4_id = ct_result->rule_id
        WHERE (charge_mod_id=reply_adjustment->charge_mods[h].charge_mod_id)
       ;end update
     ENDFOR
    ENDIF
    IF ((request2->charges[1].process_flg=100))
     UPDATE  FROM charge c
      SET c.process_flg = 177, c.bundle_id = new_bundle_id
      WHERE (c.charge_item_id=request2->charges[g].charge_item_id)
     ;end update
    ELSE
     UPDATE  FROM charge c
      SET c.process_flg = 977, c.bundle_id = new_bundle_id
      WHERE (c.charge_item_id=request2->charges[g].charge_item_id)
     ;end update
    ENDIF
  ENDFOR
 ENDIF
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
#end_prog
 IF (failed=true)
  CALL echo("script failure")
 ELSE
  SET reply_bundle_history->status_data.status = "S"
  SET cnt = 0
 ENDIF
END GO
