CREATE PROGRAM ct_add_bundle_history:dba
 CALL echo("executing ct_create_result")
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
 RECORD ct_result(
   1 rule_id = f8
   1 rules[*] = f8
     2 res = f8
     2 g_ref_id = f8
     2 g_ref_cd = f8
 )
 SET count1 = 0
 CALL echo("the rule_id is:")
 CALL echo(request->rule_id)
 SELECT INTO "nl:"
  FROM ct_rule_detail ct
  WHERE (ct.ct_rule_id=request->rule_id)
   AND (ct.detail_type_cd=code_val->15729_result)
  DETAIL
   count1 = (count1+ 1), stat = alterlist(ct_result->rules,count1), ct_result->rule_id = ct
   .ct_rule_id,
   ct_result->rules[count1].res = ct.rule_entity_id
  WITH nocounter
 ;end select
 FOR (y = 1 TO count1)
   CALL echo("the rule is ")
   CALL echo(ct_result->rule_id)
   CALL echo("the result is ")
   CALL echo(ct_result->rules[y].res)
 ENDFOR
 SET new_bundle_id = 0.00
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
 FOR (y = 1 TO count1)
   SELECT INTO "nl:"
    FROM bill_item b
    WHERE (b.bill_item_id=ct_result->rules[y].res)
     AND active_ind=1
    DETAIL
     ct_result->rules[y].g_ref_id = b.ext_parent_reference_id,
     CALL echo(build("ref id in loop is: ",ct_result->rules[y].g_ref_id)), ct_result->rules[y].
     g_ref_cd = b.ext_parent_contributor_cd,
     CALL echo(build("ref cd in loop is: ",ct_result->rules[y].g_ref_id))
    WITH nocounter
   ;end select
 ENDFOR
 CALL echo("count1 before the for loop is:")
 CALL echo(count1)
 FOR (j = 1 TO request->charge_qual)
   SET reply_bundle_history->status_data.status = "S"
   SET ref_id = 0.00
   SET ref_cd = 0.00
   SET qty = 0
   SET payor_id = 0.00
   SET person_id = 0.00
   SET encntr_id = 0.00
   SET charge_item_id = 0.0
   SET process_flg = 0
   SET qty = 1
   SET request->bundle_id = new_bundle_id
   UPDATE  FROM charge c
    SET c.process_flg = 777, c.bundle_id = new_bundle_id
    WHERE (c.charge_item_id=request->charges[j].charge_item_id)
   ;end update
   CALL echo(build("Updating process_flg and adding bundle_id: ",request->charges[j].charge_item_id))
 ENDFOR
 FOR (y = 1 TO count1)
   SET payor_id = request->payor_id
   SET person_id = request->person_id
   SET encntr_id = request->encntr_id
   CALL echo("org_id:")
   CALL echo(payor_id)
   CALL echo("person_id:")
   CALL echo(person_id)
   CALL echo("encntr_id:")
   CALL echo(encntr_id)
   SET ref_id = ct_result->rules[y].g_ref_id
   SET ref_cd = ct_result->rules[y].g_ref_cd
   CALL echo(ref_id)
   CALL echo(ref_cd)
   SET stat = uar_create_charge_sync(ref_id,ref_cd,qty,payor_id,person_id,
    encntr_id,charge_item_id,process_flg)
   IF ((stat=- (1)))
    CALL echo("stat is :")
    CALL echo(stat)
    SET failed = true
    GO TO end_prog
   ENDIF
   CALL echo("the new charge_item_id is :")
   CALL echo(charge_item_id)
   UPDATE  FROM charge c
    SET c.bundle_id = new_bundle_id
    WHERE c.charge_item_id=charge_item_id
   ;end update
   CALL echo(build("Updating new charge: ",charge_item_id))
   SET temp = (1+ request->charge_qual)
   SET request->charge_qual = temp
   SET stat = alterlist(request->charges,temp)
   SET request->charges[temp].charge_item_id = charge_item_id
 ENDFOR
 SET action_beg = 1
 SET action_end = request->charge_qual
 CALL add_ct_bundle_history(action_beg,action_end)
 CALL echo(build("CHARGEQUAL IS :",request->charge_qual))
 SET reply_bundle_history->charge_qual = request->charge_qual
 SUBROUTINE add_ct_bundle_history(add_begin,add_end)
   FOR (k = add_begin TO add_end)
     SET blank_date = cnvtdatetime("01-JAN-1800 00:00:00.00")
     SET active_code = 0.0
     IF ((request->charges[k].active_status_cd=0))
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
       IF ((request->charges[k].detail_type_cd <= 0)) request->charges[k].charge_item_id
       ELSE 0
       ENDIF
       , c.from_charge_item_id =
       IF ((request->charges[k].detail_type_cd > 0)) request->charges[k].charge_item_id
       ELSE 0
       ENDIF
       , c.ct_rule_id = request->rule_id,
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
      SET reply_bundle_history->charges[k].charge_item_id = request->charges[k].charge_item_id
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
