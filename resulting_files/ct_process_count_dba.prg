CREATE PROGRAM ct_process_count:dba
 IF ("Z"=validate(ct_process_count_vrsn,"Z"))
  DECLARE ct_process_count_vrsn = vc WITH noconstant("70583.014")
 ENDIF
 SET ct_process_count_vrsn = "45958.013"
 FREE SET request2
 RECORD request2(
   1 encntr_id = f8
   1 payor_id = f8
   1 rule_id = f8
   1 person_id = f8
   1 bundle_id = f8
   1 charge_qual = i4
   1 charges[*]
     2 charge_item_id = f8
     2 detail_type_cd = f8
     2 active_status_cd = f8
     2 item_quantity = i4
     2 item_price = f8
     2 rule_entity_id = f8
     2 process_flg = f8
     2 service_dt_tm = dq8
 )
 RECORD tmpreq(
   1 encntr[*]
     2 encntr_id = f8
     2 process_ind = i2
     2 payor_id = f8
     2 rule_id = f8
     2 person_id = f8
     2 bundle_id = f8
     2 charge_qual = i4
     2 charges[*]
       3 charge_item_id = f8
       3 detail_type_cd = f8
       3 active_status_cd = f8
       3 item_quantity = i4
       3 item_price = f8
       3 rule_entity_id = f8
       3 item_entity_id = f8
       3 process_flg = f8
       3 service_dt_tm = dq8
 )
 RECORD ct_detail(
   1 rule_entity_id = f8
 )
 SELECT INTO nl
  FROM ct_rule_detail d
  WHERE (d.ct_rule_id=process_request->ct_rule_id)
   AND (d.detail_type_cd=code_val->15729_precursor)
  DETAIL
   ct_detail->rule_entity_id = d.rule_entity_id
  WITH nocounter
 ;end select
 CALL echo(build("rule_entity_id = ",ct_detail->rule_entity_id))
 SET chargemodruleid_for_credits = process_request->ct_rule_id
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
 SET failed = false
 SET status = "Z"
 SET last_id = 0
 SET var = 0
 SET varcnt = 0
 SET request2->charge_qual = 0
 UPDATE  FROM charge c
  SET c.process_flg = 0
  WHERE c.process_flg=14
 ;end update
 SET code_set = 22449
 SET cdf_meaning = "PFTPTACCT"
 SET code_value = 0.0
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,code_value)
 SET pftptacct = code_value
 CALL echo("PFTPTACCT")
 CALL echo(code_value)
 SET code_set = 22449
 SET cdf_meaning = "PFTCLTBILL"
 SET code_value = 0.0
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,code_value)
 SET pftcltbill = code_value
 CALL echo("PFTCLIBILL")
 CALL echo(code_value)
 SET code_set = 22449
 SET cdf_meaning = "PFTCLTACCT"
 SET code_value = 0.0
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,code_value)
 SET pftcltacct = code_value
 CALL echo("PFTCLTACCT")
 CALL echo(code_value)
 SET code_set = 370
 SET cdf_meaning = "CARRIER"
 SET code_value = 0.0
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,code_value)
 SET insurance_carrier = code_value
 CALL echo("INSURANCE_CARRIER")
 CALL echo(code_value)
 DECLARE bill_item_search = i2
 DECLARE rule_entity_id = f8
 SELECT INTO "nl:"
  FROM ct_rule_detail c
  WHERE (c.ct_rule_id=process_request->ct_rule_id)
   AND (c.detail_type_cd=
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=15729
    AND cv.cdf_meaning="PRECURSOR"
    AND cv.active_ind=1))
   AND c.rule_entity_name="BILL_ITEM"
   AND c.active_ind=1
  DETAIL
   bill_item_search = 1, rule_entity_id = c.rule_entity_id,
   CALL echo("bill_item_search is 1"),
   CALL echo(build("rule_entity_id: ",rule_entity_id))
  WITH nocounter
 ;end select
 IF ((process_request->ins_org_id > 0))
  IF (bill_item_search=1)
   SELECT DISTINCT INTO "nl:"
    FROM charge c1,
     org_plan_reltn opr
    PLAN (c1
     WHERE ((((c1.payor_id+ 0)=process_request->org_id)) OR ((process_request->org_id=0)))
      AND ((((c1.health_plan_id+ 0)=process_request->health_plan_id)) OR ((process_request->
     health_plan_id=0)))
      AND ((((c1.fin_class_cd+ 0)=process_request->fin_class_cd)) OR ((process_request->fin_class_cd=
     0)))
      AND ((((c1.admit_type_cd+ 0)=process_request->encntr_type_cd)) OR ((process_request->
     encntr_type_cd=0)))
      AND ((((c1.admit_type_cd+ 0) != process_request->exclude_encntr_type_cd)) OR ((process_request
     ->exclude_encntr_type_cd=0)))
      AND ((c1.offset_charge_item_id+ 0)=0)
      AND c1.process_flg IN (0, 1, 2, 3, 4)
      AND ((c1.charge_item_id+ 0) > last_id)
      AND  NOT (c1.interface_file_id IN (
     (SELECT
      int.interface_file_id
      FROM interface_file int
      WHERE int.profit_type_cd IN (pftcltbill, pftptacct, pftcltacct))))
      AND c1.bill_item_id=rule_entity_id
      AND c1.active_ind=1)
     JOIN (opr
     WHERE opr.health_plan_id=c1.health_plan_id
      AND opr.active_ind=1
      AND (opr.organization_id=process_request->ins_org_id)
      AND opr.org_plan_reltn_cd=insurance_carrier)
    ORDER BY c1.encntr_id
    HEAD REPORT
     var = 0, varcnt = 0, stat = alterlist(tmpreq->encntr,10)
    HEAD c1.encntr_id
     last_id = c1.charge_item_id, varcnt += 1, stat = mod(varcnt,10)
     IF (stat=1
      AND varcnt != 1)
      stat = alterlist(tmpreq->encntr,(varcnt+ 10))
     ENDIF
     tmpreq->encntr[varcnt].process_ind = 0, var = 0, stat = alterlist(tmpreq->encntr[varcnt].charges,
      10)
    DETAIL
     var += 1, stat = mod(var,10)
     IF (stat=1
      AND var != 1)
      stat = alterlist(tmpreq->encntr[varcnt].charges,(var+ 10))
     ENDIF
     IF (c1.process_flg != 0
      AND c1.process_flg != 999)
      tmpreq->encntr[varcnt].process_ind = 1
     ENDIF
     tmpreq->encntr[varcnt].encntr_id = c1.encntr_id, tmpreq->encntr[varcnt].person_id = c1.person_id,
     tmpreq->encntr[varcnt].charges[var].charge_item_id = c1.charge_item_id,
     tmpreq->encntr[varcnt].charges[var].detail_type_cd = code_val->15729_precursor, tmpreq->encntr[
     varcnt].charges[var].item_quantity = c1.item_quantity, tmpreq->encntr[varcnt].charges[var].
     item_price = c1.item_price,
     tmpreq->encntr[varcnt].charges[var].rule_entity_id = rule_entity_id, tmpreq->encntr[varcnt].
     charges[var].process_flg = c1.process_flg, tmpreq->encntr[varcnt].charges[var].service_dt_tm =
     c1.service_dt_tm,
     tmpreq->encntr[varcnt].charge_qual = var,
     CALL echo("charge_item_id:  "),
     CALL echo(tmpreq->encntr[varcnt].charges[var].charge_item_id),
     CALL echo("the quantity is: "),
     CALL echo(tmpreq->encntr[varcnt].charges[var].item_quantity), tmpreq->encntr[varcnt].charge_qual
      = var
    FOOT  c1.encntr_id
     stat = alterlist(tmpreq->encntr[varcnt].charges,var)
    FOOT REPORT
     stat = alterlist(tmpreq->encntr,varcnt)
   ;end select
  ELSE
   SELECT DISTINCT INTO "nl:"
    c1.charge_item_id, cm1.field4_id, cm1.nomen_id
    FROM charge c1,
     charge_mod cm1,
     org_plan_reltn opr
    PLAN (c1
     WHERE ((((c1.payor_id+ 0)=process_request->org_id)) OR ((process_request->org_id=0)))
      AND ((((c1.health_plan_id+ 0)=process_request->health_plan_id)) OR ((process_request->
     health_plan_id=0)))
      AND ((((c1.fin_class_cd+ 0)=process_request->fin_class_cd)) OR ((process_request->fin_class_cd=
     0)))
      AND ((((c1.admit_type_cd+ 0)=process_request->encntr_type_cd)) OR ((process_request->
     encntr_type_cd=0)))
      AND ((((c1.admit_type_cd+ 0) != process_request->exclude_encntr_type_cd)) OR ((process_request
     ->exclude_encntr_type_cd=0)))
      AND ((c1.offset_charge_item_id+ 0)=0)
      AND c1.process_flg IN (0, 1, 2, 3, 4)
      AND ((c1.charge_item_id+ 0) > last_id)
      AND c1.active_ind=1
      AND  NOT (c1.interface_file_id IN (
     (SELECT
      int.interface_file_id
      FROM interface_file int
      WHERE int.profit_type_cd IN (pftcltbill, pftptacct, pftcltacct)))))
     JOIN (cm1
     WHERE cm1.charge_item_id=c1.charge_item_id
      AND (cm1.nomen_id=ct_detail->rule_entity_id)
      AND (cm1.field4_id != process_request->ct_rule_id))
     JOIN (opr
     WHERE opr.health_plan_id=c1.health_plan_id
      AND (opr.organization_id=process_request->ins_org_id)
      AND opr.org_plan_reltn_cd=insurance_carrier
      AND opr.active_ind=1)
    ORDER BY c1.encntr_id
    HEAD REPORT
     var = 0, varcnt = 0, stat = alterlist(tmpreq->encntr,10)
    HEAD c1.encntr_id
     last_id = c1.charge_item_id, varcnt += 1, stat = mod(varcnt,10)
     IF (stat=1
      AND varcnt != 1)
      stat = alterlist(tmpreq->encntr,(varcnt+ 10))
     ENDIF
     tmpreq->encntr[varcnt].process_ind = 0, var = 0, stat = alterlist(tmpreq->encntr[varcnt].charges,
      10)
    DETAIL
     var += 1, stat = mod(var,10)
     IF (stat=1
      AND var != 1)
      stat = alterlist(tmpreq->encntr[varcnt].charges,(var+ 10))
     ENDIF
     IF (c1.process_flg != 0
      AND c1.process_flg != 999)
      tmpreq->encntr[varcnt].process_ind = 1
     ENDIF
     tmpreq->encntr[varcnt].encntr_id = c1.encntr_id, tmpreq->encntr[varcnt].person_id = c1.person_id,
     tmpreq->encntr[varcnt].charges[var].charge_item_id = c1.charge_item_id,
     tmpreq->encntr[varcnt].charges[var].detail_type_cd = code_val->15729_precursor, tmpreq->encntr[
     varcnt].charges[var].item_quantity = c1.item_quantity, tmpreq->encntr[varcnt].charges[var].
     item_price = c1.item_price,
     tmpreq->encntr[varcnt].charges[var].rule_entity_id = cm1.nomen_id, tmpreq->encntr[varcnt].
     charges[var].process_flg = c1.process_flg, tmpreq->encntr[varcnt].charges[var].service_dt_tm =
     c1.service_dt_tm,
     tmpreq->encntr[varcnt].charge_qual = var,
     CALL echo("charge_item_id:  "),
     CALL echo(tmpreq->encntr[varcnt].charges[var].charge_item_id),
     CALL echo("the quantity is: "),
     CALL echo(tmpreq->encntr[varcnt].charges[var].item_quantity), tmpreq->encntr[varcnt].charge_qual
      = var
    FOOT  c1.encntr_id
     stat = alterlist(tmpreq->encntr[varcnt].charges,var)
    FOOT REPORT
     stat = alterlist(tmpreq->encntr,varcnt)
   ;end select
  ENDIF
 ELSE
  IF (bill_item_search=1)
   SELECT DISTINCT INTO "nl:"
    FROM charge c1
    WHERE ((((c1.payor_id+ 0)=process_request->org_id)) OR ((process_request->org_id=0)))
     AND ((((c1.health_plan_id+ 0)=process_request->health_plan_id)) OR ((process_request->
    health_plan_id=0)))
     AND ((((c1.fin_class_cd+ 0)=process_request->fin_class_cd)) OR ((process_request->fin_class_cd=0
    )))
     AND ((((c1.admit_type_cd+ 0)=process_request->encntr_type_cd)) OR ((process_request->
    encntr_type_cd=0)))
     AND ((((c1.admit_type_cd+ 0) != process_request->exclude_encntr_type_cd)) OR ((process_request->
    exclude_encntr_type_cd=0)))
     AND ((c1.offset_charge_item_id+ 0)=0)
     AND c1.process_flg IN (0, 1, 2, 3, 4)
     AND ((c1.charge_item_id+ 0) > last_id)
     AND  NOT (c1.interface_file_id IN (
    (SELECT
     int.interface_file_id
     FROM interface_file int
     WHERE int.profit_type_cd IN (pftcltbill, pftptacct, pftcltacct))))
     AND c1.bill_item_id=rule_entity_id
     AND c1.active_ind=1
    ORDER BY c1.encntr_id
    HEAD REPORT
     var = 0, varcnt = 0, stat = alterlist(tmpreq->encntr,10)
    HEAD c1.encntr_id
     last_id = c1.charge_item_id, varcnt += 1, stat = mod(varcnt,10)
     IF (stat=1
      AND varcnt != 1)
      stat = alterlist(tmpreq->encntr,(varcnt+ 10))
     ENDIF
     tmpreq->encntr[varcnt].process_ind = 0, var = 0, stat = alterlist(tmpreq->encntr[varcnt].charges,
      10)
    DETAIL
     var += 1, stat = mod(var,10)
     IF (stat=1
      AND var != 1)
      stat = alterlist(tmpreq->encntr[varcnt].charges,(var+ 10))
     ENDIF
     IF (c1.process_flg != 0
      AND c1.process_flg != 999)
      tmpreq->encntr[varcnt].process_ind = 1
     ENDIF
     tmpreq->encntr[varcnt].encntr_id = c1.encntr_id, tmpreq->encntr[varcnt].person_id = c1.person_id,
     tmpreq->encntr[varcnt].charges[var].charge_item_id = c1.charge_item_id,
     tmpreq->encntr[varcnt].charges[var].detail_type_cd = code_val->15729_precursor, tmpreq->encntr[
     varcnt].charges[var].item_quantity = c1.item_quantity, tmpreq->encntr[varcnt].charges[var].
     item_price = c1.item_price,
     tmpreq->encntr[varcnt].charges[var].rule_entity_id = rule_entity_id, tmpreq->encntr[varcnt].
     charges[var].process_flg = c1.process_flg, tmpreq->encntr[varcnt].charges[var].service_dt_tm =
     c1.service_dt_tm,
     tmpreq->encntr[varcnt].charge_qual = var,
     CALL echo("charge_item_id:  "),
     CALL echo(tmpreq->encntr[varcnt].charges[var].charge_item_id),
     CALL echo("the quantity is: "),
     CALL echo(tmpreq->encntr[varcnt].charges[var].item_quantity), tmpreq->encntr[varcnt].charge_qual
      = var
    FOOT  c1.encntr_id
     stat = alterlist(tmpreq->encntr[varcnt].charges,var)
    FOOT REPORT
     stat = alterlist(tmpreq->encntr,varcnt)
   ;end select
  ELSE
   SELECT DISTINCT INTO "nl:"
    c1.charge_item_id, cm1.field4_id, cm1.nomen_id
    FROM charge c1,
     charge_mod cm1
    PLAN (c1
     WHERE ((((c1.payor_id+ 0)=process_request->org_id)) OR ((process_request->org_id=0)))
      AND ((((c1.health_plan_id+ 0)=process_request->health_plan_id)) OR ((process_request->
     health_plan_id=0)))
      AND ((((c1.fin_class_cd+ 0)=process_request->fin_class_cd)) OR ((process_request->fin_class_cd=
     0)))
      AND ((((c1.admit_type_cd+ 0)=process_request->encntr_type_cd)) OR ((process_request->
     encntr_type_cd=0)))
      AND ((((c1.admit_type_cd+ 0) != process_request->exclude_encntr_type_cd)) OR ((process_request
     ->exclude_encntr_type_cd=0)))
      AND ((c1.offset_charge_item_id+ 0)=0)
      AND c1.process_flg IN (0, 1, 2, 3, 4)
      AND ((c1.charge_item_id+ 0) > last_id)
      AND c1.active_ind=1
      AND  NOT (c1.interface_file_id IN (
     (SELECT
      int.interface_file_id
      FROM interface_file int
      WHERE int.profit_type_cd IN (pftcltbill, pftptacct, pftcltacct)))))
     JOIN (cm1
     WHERE cm1.charge_item_id=c1.charge_item_id
      AND (cm1.nomen_id=ct_detail->rule_entity_id)
      AND (cm1.field4_id != process_request->ct_rule_id))
    ORDER BY c1.encntr_id
    HEAD REPORT
     var = 0, varcnt = 0, stat = alterlist(tmpreq->encntr,10)
    HEAD c1.encntr_id
     last_id = c1.charge_item_id, varcnt += 1, stat = mod(varcnt,10)
     IF (stat=1
      AND varcnt != 1)
      stat = alterlist(tmpreq->encntr,(varcnt+ 10))
     ENDIF
     tmpreq->encntr[varcnt].process_ind = 0, var = 0, stat = alterlist(tmpreq->encntr[varcnt].charges,
      10)
    DETAIL
     var += 1, stat = mod(var,10)
     IF (stat=1
      AND var != 1)
      stat = alterlist(tmpreq->encntr[varcnt].charges,(var+ 10))
     ENDIF
     IF (c1.process_flg != 0
      AND c1.process_flg != 999)
      tmpreq->encntr[varcnt].process_ind = 1
     ENDIF
     tmpreq->encntr[varcnt].encntr_id = c1.encntr_id, tmpreq->encntr[varcnt].person_id = c1.person_id,
     tmpreq->encntr[varcnt].charges[var].charge_item_id = c1.charge_item_id,
     tmpreq->encntr[varcnt].charges[var].detail_type_cd = code_val->15729_precursor, tmpreq->encntr[
     varcnt].charges[var].item_quantity = c1.item_quantity, tmpreq->encntr[varcnt].charges[var].
     item_price = c1.item_price,
     tmpreq->encntr[varcnt].charges[var].rule_entity_id = cm1.nomen_id, tmpreq->encntr[varcnt].
     charges[var].process_flg = c1.process_flg, tmpreq->encntr[varcnt].charges[var].service_dt_tm =
     c1.service_dt_tm,
     tmpreq->encntr[varcnt].charge_qual = var,
     CALL echo("charge_item_id:  "),
     CALL echo(tmpreq->encntr[varcnt].charges[var].charge_item_id),
     CALL echo("the quantity is: "),
     CALL echo(tmpreq->encntr[varcnt].charges[var].item_quantity), tmpreq->encntr[varcnt].charge_qual
      = var
    FOOT  c1.encntr_id
     stat = alterlist(tmpreq->encntr[varcnt].charges,var)
    FOOT REPORT
     stat = alterlist(tmpreq->encntr,varcnt)
   ;end select
  ENDIF
 ENDIF
 SET request2->rule_id = process_request->ct_rule_id
 SET request2->payor_id = process_request->org_id
 IF ((tmpreq->encntr[varcnt].charge_qual > 0))
  SET status = "S"
 ENDIF
 CALL echo(build("status is: ",status))
 CALL echo(build("Total Charges ",tmpreq->encntr[varcnt].charge_qual))
 FOR (xtmp = 1 TO varcnt)
   IF ((tmpreq->encntr[xtmp].charge_qual > 0))
    IF ((tmpreq->encntr[xtmp].process_ind=1))
     CALL echo("testing process_ind")
     CALL echo(tmpreq->encntr[xtmp].process_ind)
     FOR (p = 1 TO tmpreq->encntr[xtmp].charge_qual)
      UPDATE  FROM charge c
       SET c.process_flg = 778
       WHERE c.process_flg=0
        AND (charge_item_id=tmpreq->encntr[xtmp].charges[p].charge_item_id)
      ;end update
      COMMIT
     ENDFOR
    ELSE
     CALL echo("size of charge_qual: ")
     CALL echo(size(tmpreq->encntr[xtmp].charges,5))
     SET request2->encntr_id = tmpreq->encntr[xtmp].encntr_id
     SET request2->person_id = tmpreq->encntr[xtmp].person_id
     SET stat = alterlist(request2->charges,size(tmpreq->encntr[xtmp].charges,5))
     FOR (sreq = 1 TO size(tmpreq->encntr[xtmp].charges,5))
       CALL echo("size of charge_qual from ct_process_count")
       CALL echo(size(tmpreq->encntr[xtmp].charges,5))
       SET request2->charges[sreq].charge_item_id = tmpreq->encntr[xtmp].charges[sreq].charge_item_id
       CALL echo("charge_item_id from ct_process_count")
       CALL echo(request2->charges[sreq].charge_item_id)
       SET request2->charges[sreq].detail_type_cd = code_val->15729_precursor
       SET request2->charges[sreq].item_quantity = tmpreq->encntr[xtmp].charges[sreq].item_quantity
       CALL echo("item_quantity from ct_process_count")
       CALL echo(request2->charges[sreq].item_quantity)
       SET request2->charges[sreq].item_price = tmpreq->encntr[xtmp].charges[sreq].item_price
       SET request2->charges[sreq].rule_entity_id = tmpreq->encntr[xtmp].charges[sreq].rule_entity_id
       SET request2->charges[sreq].process_flg = tmpreq->encntr[xtmp].charges[sreq].process_flg
       SET request2->charges[sreq].service_dt_tm = tmpreq->encntr[xtmp].charges[sreq].service_dt_tm
       SET request2->charge_qual = tmpreq->encntr[xtmp].charge_qual
     ENDFOR
     EXECUTE ct_count_result
    ENDIF
   ENDIF
 ENDFOR
 UPDATE  FROM charge c
  SET process_flg = 14
  WHERE c.process_flg=778
 ;end update
 COMMIT
 CALL echo("CT_PROCESS_COUNT::STARTING PROFIT SECTION")
 UPDATE  FROM charge c
  SET c.process_flg = 100
  WHERE c.process_flg IN (114, 178)
 ;end update
 UPDATE  FROM charge c
  SET c.process_flg = 999
  WHERE c.process_flg IN (914, 978)
 ;end update
 FREE SET reply_credit
 RECORD reply_credit(
   1 new_charge_item_id = f8
   1 charge_mod_qual = i2
   1 charge_mods[*]
     2 charge_mod_id = f8
 )
 SET failed = false
 SET status = "Z"
 SET last_id = 0
 SET var = 0
 SET varcnt = 0
 SET stat = alterlist(tmpreq->encntr,0)
 SET request2->charge_qual = 0
 SET today = cnvtdatetime(sysdate)
 SET today = cnvtdatetime(concat(format(today,"DD-MMM-YYYY;;D")," 00:00:00.00"))
 SET from_date = datetimeadd(today,- (numberofdaysbacktoprocess))
 CALL echo(build("CT_PROCESS_COUNT::FROM_DATE: ",format(from_date,"DD-MMM-YYYY HH:MM:SS;;d")))
 CALL echo("**************************************")
 IF ((process_request->ins_org_id > 0))
  IF (bill_item_search=1)
   SELECT DISTINCT INTO "nl:"
    FROM charge c1,
     org_plan_reltn opr
    PLAN (c1
     WHERE ((((c1.payor_id+ 0)=process_request->org_id)) OR ((process_request->org_id=0)))
      AND ((((c1.health_plan_id+ 0)=process_request->health_plan_id)) OR ((process_request->
     health_plan_id=0)))
      AND ((((c1.fin_class_cd+ 0)=process_request->fin_class_cd)) OR ((process_request->fin_class_cd=
     0)))
      AND ((((c1.admit_type_cd+ 0)=process_request->encntr_type_cd)) OR ((process_request->
     encntr_type_cd=0)))
      AND ((((c1.admit_type_cd+ 0) != process_request->exclude_encntr_type_cd)) OR ((process_request
     ->exclude_encntr_type_cd=0)))
      AND ((c1.offset_charge_item_id+ 0)=0)
      AND ((c1.process_flg+ 0) IN (999, 100, 1, 2, 3,
     4))
      AND ((c1.charge_item_id+ 0) > last_id)
      AND c1.bill_item_id=rule_entity_id
      AND c1.service_dt_tm > cnvtdatetime(from_date)
      AND c1.active_ind=1)
     JOIN (opr
     WHERE opr.health_plan_id=c1.health_plan_id
      AND (opr.organization_id=process_request->ins_org_id)
      AND opr.org_plan_reltn_cd=insurance_carrier
      AND opr.active_ind=1)
    ORDER BY c1.encntr_id
    HEAD REPORT
     var = 0, varcnt = 0, stat = alterlist(tmpreq->encntr,10)
    HEAD c1.encntr_id
     last_id = c1.charge_item_id, varcnt += 1, stat = mod(varcnt,10)
     IF (stat=1
      AND varcnt != 1)
      stat = alterlist(tmpreq->encntr,(varcnt+ 10))
     ENDIF
     tmpreq->encntr[varcnt].process_ind = 0, var = 0, stat = alterlist(tmpreq->encntr[varcnt].charges,
      10)
    DETAIL
     var += 1, stat = mod(var,10)
     IF (stat=1
      AND var != 1)
      stat = alterlist(tmpreq->encntr[varcnt].charges,(var+ 10))
     ENDIF
     IF (c1.process_flg != 100
      AND c1.process_flg != 999)
      tmpreq->encntr[varcnt].process_ind = 1,
      CALL echo("CT_PROCESS_COUNT::PROCESS_IND IS 1"),
      CALL echo("CT_PROCESS_COUNT::PROCESS_FLG:"),
      CALL echo(c1.process_flg)
     ENDIF
     tmpreq->encntr[varcnt].encntr_id = c1.encntr_id, tmpreq->encntr[varcnt].person_id = c1.person_id,
     tmpreq->encntr[varcnt].charges[var].charge_item_id = c1.charge_item_id,
     tmpreq->encntr[varcnt].charges[var].detail_type_cd = code_val->15729_precursor, tmpreq->encntr[
     varcnt].charges[var].item_quantity = c1.item_quantity, tmpreq->encntr[varcnt].charges[var].
     item_price = c1.item_price,
     tmpreq->encntr[varcnt].charges[var].rule_entity_id = rule_entity_id, tmpreq->encntr[varcnt].
     charges[var].process_flg = c1.process_flg, tmpreq->encntr[varcnt].charges[var].service_dt_tm =
     c1.service_dt_tm,
     CALL echo("charge_item_id:  "),
     CALL echo(tmpreq->encntr[varcnt].charges[var].charge_item_id),
     CALL echo("the quantity is: "),
     CALL echo(tmpreq->encntr[varcnt].charges[var].item_quantity), tmpreq->encntr[varcnt].charge_qual
      = var
    FOOT  c1.encntr_id
     stat = alterlist(tmpreq->encntr[varcnt].charges,var)
    FOOT REPORT
     stat = alterlist(tmpreq->encntr,varcnt)
   ;end select
  ELSE
   SELECT DISTINCT INTO "nl:"
    c1.charge_item_id, cm1.field4_id, cm1.nomen_id
    FROM charge c1,
     charge_mod cm1,
     org_plan_reltn opr
    PLAN (c1
     WHERE ((((c1.payor_id+ 0)=process_request->org_id)) OR ((process_request->org_id=0)))
      AND ((((c1.health_plan_id+ 0)=process_request->health_plan_id)) OR ((process_request->
     health_plan_id=0)))
      AND ((((c1.fin_class_cd+ 0)=process_request->fin_class_cd)) OR ((process_request->fin_class_cd=
     0)))
      AND ((((c1.admit_type_cd+ 0)=process_request->encntr_type_cd)) OR ((process_request->
     encntr_type_cd=0)))
      AND ((((c1.admit_type_cd+ 0) != process_request->exclude_encntr_type_cd)) OR ((process_request
     ->exclude_encntr_type_cd=0)))
      AND ((c1.offset_charge_item_id+ 0)=0)
      AND ((c1.process_flg+ 0) IN (999, 100, 1, 2, 3,
     4))
      AND ((c1.charge_item_id+ 0) > last_id)
      AND c1.service_dt_tm > cnvtdatetime(from_date)
      AND c1.active_ind=1)
     JOIN (cm1
     WHERE cm1.charge_item_id=c1.charge_item_id
      AND (cm1.nomen_id=ct_detail->rule_entity_id)
      AND (cm1.field4_id != process_request->ct_rule_id))
     JOIN (opr
     WHERE opr.health_plan_id=c1.health_plan_id
      AND (opr.organization_id=process_request->ins_org_id)
      AND opr.org_plan_reltn_cd=insurance_carrier
      AND opr.active_ind=1)
    ORDER BY c1.encntr_id
    HEAD REPORT
     var = 0, varcnt = 0, stat = alterlist(tmpreq->encntr,10)
    HEAD c1.encntr_id
     last_id = c1.charge_item_id, varcnt += 1, stat = mod(varcnt,10)
     IF (stat=1
      AND varcnt != 1)
      stat = alterlist(tmpreq->encntr,(varcnt+ 10))
     ENDIF
     tmpreq->encntr[varcnt].process_ind = 0, var = 0, stat = alterlist(tmpreq->encntr[varcnt].charges,
      10)
    DETAIL
     var += 1, stat = mod(var,10)
     IF (stat=1
      AND var != 1)
      stat = alterlist(tmpreq->encntr[varcnt].charges,(var+ 10))
     ENDIF
     IF (c1.process_flg != 100
      AND c1.process_flg != 999)
      tmpreq->encntr[varcnt].process_ind = 1,
      CALL echo("CT_PROCESS_COUNT::PROCESS_IND IS 1"),
      CALL echo("CT_PROCESS_COUNT::PROCESS_FLG:"),
      CALL echo(c1.process_flg)
     ENDIF
     tmpreq->encntr[varcnt].encntr_id = c1.encntr_id, tmpreq->encntr[varcnt].person_id = c1.person_id,
     tmpreq->encntr[varcnt].charges[var].charge_item_id = c1.charge_item_id,
     tmpreq->encntr[varcnt].charges[var].detail_type_cd = code_val->15729_precursor, tmpreq->encntr[
     varcnt].charges[var].item_quantity = c1.item_quantity, tmpreq->encntr[varcnt].charges[var].
     item_price = c1.item_price,
     tmpreq->encntr[varcnt].charges[var].rule_entity_id = cm1.nomen_id, tmpreq->encntr[varcnt].
     charges[var].process_flg = c1.process_flg, tmpreq->encntr[varcnt].charges[var].service_dt_tm =
     c1.service_dt_tm,
     CALL echo("charge_item_id:  "),
     CALL echo(tmpreq->encntr[varcnt].charges[var].charge_item_id),
     CALL echo("the quantity is: "),
     CALL echo(tmpreq->encntr[varcnt].charges[var].item_quantity), tmpreq->encntr[varcnt].charge_qual
      = var
    FOOT  c1.encntr_id
     stat = alterlist(tmpreq->encntr[varcnt].charges,var)
    FOOT REPORT
     stat = alterlist(tmpreq->encntr,varcnt)
   ;end select
  ENDIF
 ELSE
  IF (bill_item_search=1)
   SELECT DISTINCT INTO "nl:"
    FROM charge c1
    WHERE ((((c1.payor_id+ 0)=process_request->org_id)) OR ((process_request->org_id=0)))
     AND ((((c1.health_plan_id+ 0)=process_request->health_plan_id)) OR ((process_request->
    health_plan_id=0)))
     AND ((((c1.fin_class_cd+ 0)=process_request->fin_class_cd)) OR ((process_request->fin_class_cd=0
    )))
     AND ((((c1.admit_type_cd+ 0)=process_request->encntr_type_cd)) OR ((process_request->
    encntr_type_cd=0)))
     AND ((((c1.admit_type_cd+ 0) != process_request->exclude_encntr_type_cd)) OR ((process_request->
    exclude_encntr_type_cd=0)))
     AND ((c1.offset_charge_item_id+ 0)=0)
     AND ((c1.process_flg+ 0) IN (999, 100, 1, 2, 3,
    4))
     AND ((c1.charge_item_id+ 0) > last_id)
     AND c1.bill_item_id=rule_entity_id
     AND c1.service_dt_tm > cnvtdatetime(from_date)
     AND c1.active_ind=1
    ORDER BY c1.encntr_id
    HEAD REPORT
     var = 0, varcnt = 0, stat = alterlist(tmpreq->encntr,10)
    HEAD c1.encntr_id
     last_id = c1.charge_item_id, varcnt += 1, stat = mod(varcnt,10)
     IF (stat=1
      AND varcnt != 1)
      stat = alterlist(tmpreq->encntr,(varcnt+ 10))
     ENDIF
     tmpreq->encntr[varcnt].process_ind = 0, var = 0, stat = alterlist(tmpreq->encntr[varcnt].charges,
      10)
    DETAIL
     var += 1, stat = mod(var,10)
     IF (stat=1
      AND var != 1)
      stat = alterlist(tmpreq->encntr[varcnt].charges,(var+ 10))
     ENDIF
     IF (c1.process_flg != 100
      AND c1.process_flg != 999)
      tmpreq->encntr[varcnt].process_ind = 1,
      CALL echo("CT_PROCESS_COUNT::PROCESS_IND IS 1"),
      CALL echo("CT_PROCESS_COUNT::PROCESS_FLG:"),
      CALL echo(c1.process_flg)
     ENDIF
     tmpreq->encntr[varcnt].encntr_id = c1.encntr_id, tmpreq->encntr[varcnt].person_id = c1.person_id,
     tmpreq->encntr[varcnt].charges[var].charge_item_id = c1.charge_item_id,
     tmpreq->encntr[varcnt].charges[var].detail_type_cd = code_val->15729_precursor, tmpreq->encntr[
     varcnt].charges[var].item_quantity = c1.item_quantity, tmpreq->encntr[varcnt].charges[var].
     item_price = c1.item_price,
     tmpreq->encntr[varcnt].charges[var].rule_entity_id = rule_entity_id, tmpreq->encntr[varcnt].
     charges[var].process_flg = c1.process_flg, tmpreq->encntr[varcnt].charges[var].service_dt_tm =
     c1.service_dt_tm,
     CALL echo("charge_item_id:  "),
     CALL echo(tmpreq->encntr[varcnt].charges[var].charge_item_id),
     CALL echo("the quantity is: "),
     CALL echo(tmpreq->encntr[varcnt].charges[var].item_quantity), tmpreq->encntr[varcnt].charge_qual
      = var
    FOOT  c1.encntr_id
     stat = alterlist(tmpreq->encntr[varcnt].charges,var)
    FOOT REPORT
     stat = alterlist(tmpreq->encntr,varcnt)
   ;end select
  ELSE
   SELECT DISTINCT INTO "nl:"
    c1.charge_item_id, cm1.field4_id, cm1.nomen_id
    FROM charge c1,
     charge_mod cm1
    PLAN (c1
     WHERE ((((c1.payor_id+ 0)=process_request->org_id)) OR ((process_request->org_id=0)))
      AND ((((c1.health_plan_id+ 0)=process_request->health_plan_id)) OR ((process_request->
     health_plan_id=0)))
      AND ((((c1.fin_class_cd+ 0)=process_request->fin_class_cd)) OR ((process_request->fin_class_cd=
     0)))
      AND ((((c1.admit_type_cd+ 0)=process_request->encntr_type_cd)) OR ((process_request->
     encntr_type_cd=0)))
      AND ((((c1.admit_type_cd+ 0) != process_request->exclude_encntr_type_cd)) OR ((process_request
     ->exclude_encntr_type_cd=0)))
      AND ((c1.offset_charge_item_id+ 0)=0)
      AND ((c1.process_flg+ 0) IN (999, 100, 1, 2, 3,
     4))
      AND ((c1.charge_item_id+ 0) > last_id)
      AND c1.service_dt_tm > cnvtdatetime(from_date)
      AND c1.active_ind=1)
     JOIN (cm1
     WHERE cm1.charge_item_id=c1.charge_item_id
      AND (cm1.nomen_id=ct_detail->rule_entity_id)
      AND (cm1.field4_id != process_request->ct_rule_id))
    ORDER BY c1.encntr_id
    HEAD REPORT
     var = 0, varcnt = 0, stat = alterlist(tmpreq->encntr,10)
    HEAD c1.encntr_id
     last_id = c1.charge_item_id, varcnt += 1, stat = mod(varcnt,10)
     IF (stat=1
      AND varcnt != 1)
      stat = alterlist(tmpreq->encntr,(varcnt+ 10))
     ENDIF
     tmpreq->encntr[varcnt].process_ind = 0, var = 0, stat = alterlist(tmpreq->encntr[varcnt].charges,
      10)
    DETAIL
     var += 1, stat = mod(var,10)
     IF (stat=1
      AND var != 1)
      stat = alterlist(tmpreq->encntr[varcnt].charges,(var+ 10))
     ENDIF
     IF (c1.process_flg != 100
      AND c1.process_flg != 999)
      tmpreq->encntr[varcnt].process_ind = 1,
      CALL echo("CT_PROCESS_COUNT::PROCESS_IND IS 1"),
      CALL echo("CT_PROCESS_COUNT::PROCESS_FLG:"),
      CALL echo(c1.process_flg)
     ENDIF
     tmpreq->encntr[varcnt].encntr_id = c1.encntr_id, tmpreq->encntr[varcnt].person_id = c1.person_id,
     tmpreq->encntr[varcnt].charges[var].charge_item_id = c1.charge_item_id,
     tmpreq->encntr[varcnt].charges[var].detail_type_cd = code_val->15729_precursor, tmpreq->encntr[
     varcnt].charges[var].item_quantity = c1.item_quantity, tmpreq->encntr[varcnt].charges[var].
     item_price = c1.item_price,
     tmpreq->encntr[varcnt].charges[var].rule_entity_id = cm1.nomen_id, tmpreq->encntr[varcnt].
     charges[var].process_flg = c1.process_flg, tmpreq->encntr[varcnt].charges[var].service_dt_tm =
     c1.service_dt_tm,
     CALL echo("charge_item_id:  "),
     CALL echo(tmpreq->encntr[varcnt].charges[var].charge_item_id),
     CALL echo("the quantity is: "),
     CALL echo(tmpreq->encntr[varcnt].charges[var].item_quantity), tmpreq->encntr[varcnt].charge_qual
      = var
    FOOT  c1.encntr_id
     stat = alterlist(tmpreq->encntr[varcnt].charges,var)
    FOOT REPORT
     stat = alterlist(tmpreq->encntr,varcnt)
   ;end select
  ENDIF
 ENDIF
 SET request2->rule_id = process_request->ct_rule_id
 SET request2->payor_id = process_request->org_id
 IF ((tmpreq->encntr[varcnt].charge_qual > 0))
  SET status = "S"
 ENDIF
 CALL echo(build("status is: ",status))
 CALL echo(build("Total Charges ",tmpreq->encntr[varcnt].charge_qual))
 FOR (xtmp = 1 TO varcnt)
   IF ((tmpreq->encntr[xtmp].charge_qual > 0))
    IF ((tmpreq->encntr[xtmp].process_ind=1))
     CALL echo("testing process_ind")
     CALL echo(tmpreq->encntr[xtmp].process_ind)
     FOR (p = 1 TO tmpreq->encntr[xtmp].charge_qual)
      IF ((tmpreq->encntr[xtmp].charges[p].process_flg=100))
       UPDATE  FROM charge c
        SET c.process_flg = 178
        WHERE c.process_flg=100
         AND (charge_item_id=tmpreq->encntr[xtmp].charges[p].charge_item_id)
       ;end update
      ELSE
       UPDATE  FROM charge c
        SET c.process_flg = 978
        WHERE c.process_flg=999
         AND (charge_item_id=tmpreq->encntr[xtmp].charges[p].charge_item_id)
       ;end update
      ENDIF
      COMMIT
     ENDFOR
    ELSE
     CALL echo("size of charge_qual: ")
     CALL echo(size(tmpreq->encntr[xtmp].charges,5))
     SET request2->encntr_id = tmpreq->encntr[xtmp].encntr_id
     SET request2->person_id = tmpreq->encntr[xtmp].person_id
     SET stat = alterlist(request2->charges,size(tmpreq->encntr[xtmp].charges,5))
     FOR (sreq = 1 TO size(tmpreq->encntr[xtmp].charges,5))
       CALL echo("size of charge_qual from ct_process_count")
       CALL echo(size(tmpreq->encntr[xtmp].charges,5))
       SET request2->charges[sreq].charge_item_id = tmpreq->encntr[xtmp].charges[sreq].charge_item_id
       CALL echo("charge_item_id from ct_process_count")
       CALL echo(request2->charges[sreq].charge_item_id)
       SET request2->charges[sreq].detail_type_cd = code_val->15729_precursor
       SET request2->charges[sreq].item_quantity = tmpreq->encntr[xtmp].charges[sreq].item_quantity
       CALL echo("item_quantity from ct_process_count")
       CALL echo(request2->charges[sreq].item_quantity)
       SET request2->charges[sreq].item_price = tmpreq->encntr[xtmp].charges[sreq].item_price
       SET request2->charges[sreq].rule_entity_id = tmpreq->encntr[xtmp].charges[sreq].rule_entity_id
       SET request2->charges[sreq].process_flg = tmpreq->encntr[xtmp].charges[sreq].process_flg
       SET request2->charges[sreq].service_dt_tm = tmpreq->encntr[xtmp].charges[sreq].service_dt_tm
       SET request2->charge_qual = tmpreq->encntr[xtmp].charge_qual
     ENDFOR
     EXECUTE ct_count_result_profit
     CALL echo("CT_PROCESS_COUNT::back from ct_count_result_profit")
     FOR (credit_count2 = 1 TO tmpreq->encntr[xtmp].charge_qual)
      EXECUTE ct_credit_profit_charge tmpreq->encntr[xtmp].charges[credit_count2].charge_item_id
      CALL echo("CT_PROCESS_COUNT::back from ct_credit_profit_charge")
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
 IF ((request2->charges[1].process_flg=100))
  UPDATE  FROM charge c
   SET process_flg = 114
   WHERE c.process_flg=178
  ;end update
 ELSE
  UPDATE  FROM charge c
   SET process_flg = 914
   WHERE c.process_flg=978
  ;end update
 ENDIF
 COMMIT
#end_prog
 IF (failed=true)
  SET status = "F"
  CALL echo("script failure")
 ENDIF
END GO
