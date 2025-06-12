CREATE PROGRAM ct_generate_rule_script:dba
 DECLARE ct_generate_rule_script_vrsn = vc
 SET ct_generate_rule_script_vrsn = "97693.FT.021"
 RECORD ct_detail(
   1 details[*]
     2 ct_rule_id = f8
     2 detail_type_cd = f8
     2 operator_cd = f8
     2 rule_entity_id = f8
     2 precedence = i4
     2 sequence = i4
     2 action_cd = f8
     2 action_type = vc
     2 rule_entity_name = vc
 )
 RECORD cv(
   1 15729_precursor = f8
   1 15729_result = f8
 )
 DECLARE z = i4 WITH noconstant(0)
 DECLARE precursor = f8
 DECLARE precursorcnt = i4
 SET code_set = 15729
 SET cdf_meaning = "PRECURSOR"
 SET precursorcnt = 1
 SET iret = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),precursorcnt,precursor)
 IF (iret=0)
  SET cv->15729_precursor = precursor
 ELSE
  CALL echo("Falure")
 ENDIF
 CALL echo("UAR call for PRECURSOR")
 CALL echo(cv->15729_precursor)
 DECLARE result = f8
 DECLARE resultcnt = i4
 SET code_set = 15729
 SET cdf_meaning = "RESULT"
 SET resultcnt = 1
 SET iret = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),resultcnt,result)
 IF (iret=0)
  SET cv->15729_result = result
 ELSE
  CALL echo("Falure")
 ENDIF
 CALL echo("UAR call for RESULT")
 CALL echo(cv->15729_result)
 SET count1 = 0
 SELECT INTO "nl:"
  FROM ct_rule_detail rd,
   ct_rule r
  WHERE (rd.ct_rule_id=request->ct_rule_id)
   AND r.active_ind=1
   AND (rd.detail_type_cd=cv->15729_precursor)
   AND r.ct_rule_id=rd.ct_rule_id
   AND rd.active_ind=1
  DETAIL
   count1 = (count1+ 1), stat = alterlist(ct_detail->details,count1), ct_detail->details[count1].
   ct_rule_id = rd.ct_rule_id,
   ct_detail->details[count1].detail_type_cd = rd.detail_type_cd, ct_detail->details[count1].
   operator_cd = rd.operator_cd, ct_detail->details[count1].rule_entity_id = rd.rule_entity_id,
   ct_detail->details[count1].precedence = rd.precedence, ct_detail->details[count1].sequence = rd
   .sequence, ct_detail->details[count1].action_cd = r.action_cd,
   ct_detail->details[count1].rule_entity_name = rd.rule_entity_name
  WITH nocounter
 ;end select
 SET startline = 1
 SET line_cnt = 0
 FREE SET select_s
 RECORD select_s(
   1 lines[*]
     2 sel_line = c110
 )
 SET details_size = count1
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = concat("drop program"," ctrule_",trim(cnvtstring(request->
    ct_rule_id),3),":dba go")
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = concat("create program"," ctrule_",trim(cnvtstring(request
    ->ct_rule_id),3),":dba")
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "free set request2"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "record request2"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "("
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "1      encntr_id       =       f8"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "1    payor_id        =       f8"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "1     rule_id =       f8"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "1       person_id =             f8"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "1        bundle_id =             f8"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "1        charge_qual =            i4"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "1         charges[*]"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "2         charge_item_id  =       f8"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "2         detail_type_cd =        f8"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "2         active_status_cd =      f8"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "2         item_quantity =         I4"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "2         item_price  =   f8"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "2         rule_entity_id  = f8"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "2         process_flg  = f8"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "2         service_dt_tm = dq8"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = ")"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set failed = FALSE"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set status = 'Z'"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set var= 1"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set last_id = 0"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set code_set    = 22449"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set cdf_meaning = 'PFTPTACCT' "
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set code_value  = 0.0"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set cnt         = 1"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line =
 "set stat = uar_get_meaning_by_codeset(code_set, nullterm(cdf_meaning), cnt, code_value)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set PFTPTACCT = code_value"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set code_set    = 22449"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set cdf_meaning = 'PFTCLTBILL' "
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set code_value  = 0.0"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set cnt         = 1"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line =
 "set stat =uar_get_meaning_by_codeset(code_set, nullterm(cdf_meaning), cnt, code_value)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set PFTCLTBILL = code_value"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set code_set    = 22449"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set cdf_meaning = 'PFTCLTACCT' "
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set code_value  = 0.0"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set cnt         = 1"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line =
 "set stat = uar_get_meaning_by_codeset(code_set, nullterm(cdf_meaning), cnt, code_value)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set PFTCLTACCT = code_value"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set code_set    = 370"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set cdf_meaning = 'CARRIER' "
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set code_value  = 0.0"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set cnt         = 1"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line =
 "set stat = uar_get_meaning_by_codeset(code_set, nullterm(cdf_meaning), cnt, code_value)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set INSURANCE_CARRIER = code_value"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "declare bill_item_search = i2"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "while (var > 0 )"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo ('while')"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo(curqual)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo('The rule is')"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo(process_request->ct_rule_id)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line =
 "set ChargeModRuleID_for_credits = process_request->ct_rule_id"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "update into charge set process_flg = 0"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "where process_flg = 14"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set var = 0"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set process_ind = 0"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "select into 'nl:'"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "from ct_rule_detail c"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "where c.ct_rule_id = process_request->ct_rule_id and"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line =
 "c.detail_type_cd = (select cv.code_value from code_value cv"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line =
 "where cv.code_set = 15729 and cv.cdf_meaning = 'PRECURSOR' and cv.active_ind = 1) and"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "c.rule_entity_name = 'BILL_ITEM' and c.active_ind = 1"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "detail"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "bill_item_search = 1"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo('bill_item_search is 1')"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "with nocounter"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "if (process_request->ins_org_id > 0)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "if (bill_item_search = 1)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "select into 'nl:'"
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (z < details_size)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id,")
   ELSE
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id")
   ENDIF
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "from"
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (z < details_size)
    SET select_s->lines[line_cnt].sel_line = concat("charge c",trim(cnvtstring(z),3),",")
   ELSE
    SET select_s->lines[line_cnt].sel_line = concat("charge c",trim(cnvtstring(z),3))
   ENDIF
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = ", org_plan_reltn opr"
 FOR (z = 1 TO details_size)
  IF (z=1)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "Plan c1 where ((c1.payor_id = process_request->org_id or process_request->org_id = 0)"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "and (c1.health_plan_id = process_request->health_plan_id or process_request->health_plan_id = 0)"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "and (c1.fin_class_cd = process_request->fin_class_cd or process_request->fin_class_cd = 0)"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "and (c1.admit_type_cd = process_request->encntr_type_cd or process_request->encntr_type_cd = 0)"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "and (c1.offset_charge_item_id+0 = 0)"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "and (c1.admit_type_cd != process_request->exclude_encntr_type_cd"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "or process_request->exclude_encntr_type_cd = 0)"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "and (c1.process_flg = 0 or c1.process_flg = 1 or"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "c1.process_flg = 2 or c1.process_flg = 3 or c1.process_flg = 4)"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("and c",trim(cnvtstring(z),3),
    ".charge_item_id+0 > last_id)")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = build("and c1.bill_item_id = ",ct_detail->details[z].
    rule_entity_id)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "and (c1.interface_file_id not in"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "(select int.interface_file_id from interface_file int"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "where int.profit_type_cd in (PFTCLTBILL,PFTPTACCT, PFTCLTACCT)))"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "and not exists(select bh.ct_bundle_history_id from ct_bundle_history bh"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = build(
    "where bh.to_charge_item_id = c1.charge_item_id and bh.ct_rule_id = ",request->ct_rule_id,")")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "and c1.active_ind = 1"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "join opr"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "where opr.health_plan_id = c1.health_plan_id and"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "opr.organization_id = process_request->ins_org_id and"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "opr.org_plan_reltn_cd = INSURANCE_CARRIER and"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "opr.active_ind = 1"
  ELSE
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("join c",trim(cnvtstring(z),3)," where c",trim(
     cnvtstring(z),3),".encntr_id = c",
    trim(cnvtstring((z - 1)),3),".encntr_id and")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = build("c",trim(cnvtstring(z),3),".bill_item_id = ",
    ct_detail->details[z].rule_entity_id," and ")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("(c",trim(cnvtstring(z),3),".process_flg = 0")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "or"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".process_flg= 1")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "or"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".process_flg = 2")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "or"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".process_flg = 3")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "or"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".process_flg = 4)")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "and not exists (select bh.ct_bundle_history_id from ct_bundle_history bh"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("where bh.to_charge_item_id = c",trim(cnvtstring(z
      ),3),".charge_item_id and")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = build("bh.ct_rule_id = ",request->ct_rule_id,")")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("and c",trim(cnvtstring(z),3),".active_ind = 1")
  ENDIF
  IF (z > 1)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "and datetimecmp("
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring((z - 1)),3),".service_dt_tm,")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".service_dt_tm) = 0")
  ENDIF
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "order by "
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (z < details_size)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id,")
   ELSE
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id")
   ENDIF
 ENDFOR
 FOR (m = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (m <= details_size)
    SET select_s->lines[line_cnt].sel_line = "head"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(m),3),".charge_item_id")
    IF (m=1)
     SET line_cnt = (line_cnt+ 1)
     SET stat = alterlist(select_s->lines,line_cnt)
     SET select_s->lines[line_cnt].sel_line = "last_id ="
     SET line_cnt = (line_cnt+ 1)
     SET stat = alterlist(select_s->lines,line_cnt)
     SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(m),3),".charge_item_id")
    ENDIF
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("stat = alterlist(request2->charges, ",trim(
      cnvtstring(details_size),3),")")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(m),3),
     "]->process_flg = c",trim(cnvtstring(m),3),".process_flg")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(m),3),
     "]->service_dt_tm = c",trim(cnvtstring(m),3),".service_dt_tm")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("call echo ('c[",trim(cnvtstring(m),3),
     "].process_flg:  ')")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("call echo(request2->charges[",trim(cnvtstring(m),
      3),"]->process_flg)")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("if ((request2->charges[",trim(cnvtstring(m),3),
     "]->process_flg != 0) and")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("(request2->charges[",trim(cnvtstring(m),3),
     "]->process_flg != 999)) ")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "process_ind = 1"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "endif"
   ENDIF
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo(build('Process_ind is ' ,  process_ind))"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "detail"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "var = var + 1"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = concat("stat = alterlist(request2->charges, ",trim(
   cnvtstring(details_size),3),")")
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "request2->encntr_id = c1.encntr_id"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo(build('c1.encntr_id: ', c1.encntr_id))"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "request2->person_id = c1.person_id"
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->charge_item_id = c",trim(cnvtstring(z),3),".charge_item_id")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->detail_type_cd = code_val->15729_PRECURSOR")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->item_quantity = c",trim(cnvtstring(z),3),".item_quantity")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->item_price = c",trim(cnvtstring(z),3),".item_price")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->rule_entity_id = c",trim(cnvtstring(z),3),".bill_item_id")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("call echo ('c[",trim(cnvtstring(z),3),
    "].charge_item_id:  ')")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("call echo(request2->charges[",trim(cnvtstring(z),
     3),"]->charge_item_id)")
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = concat("request2->charge_qual = ",trim(cnvtstring(
    details_size),3))
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo(build('var is :  ',var))"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "with nocounter, maxqual (c1, 1)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "else   ;if bill_item_search = 1"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "select into 'nl:'"
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (z < details_size)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id,cm",
     trim(cnvtstring(z),3),".field4_id,cm",
     trim(cnvtstring(z),3),".nomen_id,")
   ELSE
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id,cm",
     trim(cnvtstring(z),3),".field4_id,cm",
     trim(cnvtstring(z),3),".nomen_id")
   ENDIF
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "from"
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (z < details_size)
    SET select_s->lines[line_cnt].sel_line = concat("charge c",trim(cnvtstring(z),3),",charge_mod cm",
     trim(cnvtstring(z),3),",")
   ELSE
    SET select_s->lines[line_cnt].sel_line = concat("charge c",trim(cnvtstring(z),3),",charge_mod cm",
     trim(cnvtstring(z),3))
   ENDIF
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = ", org_plan_reltn opr"
 FOR (z = 1 TO details_size)
   IF (z=1)
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line =
    "Plan c1 where ((c1.payor_id = process_request->org_id or process_request->org_id = 0)"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line =
    "and (c1.health_plan_id = process_request->health_plan_id or process_request->health_plan_id = 0)"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line =
    "and (c1.fin_class_cd = process_request->fin_class_cd or process_request->fin_class_cd = 0)"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line =
    "and (c1.admit_type_cd = process_request->encntr_type_cd or process_request->encntr_type_cd = 0)"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "and (c1.offset_charge_item_id+0 = 0)"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line =
    "and (c1.admit_type_cd != process_request->exclude_encntr_type_cd"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "or process_request->exclude_encntr_type_cd = 0)"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "and (c1.process_flg =  0 or c1.process_flg = 1 or"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line =
    "c1.process_flg = 2 or c1.process_flg = 3 or c1.process_flg = 4)"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("and c",trim(cnvtstring(z),3),
     ".charge_item_id+0 > last_id)")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "and c1.active_ind = 1"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "and (c1.interface_file_id not in"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "(select int.interface_file_id from interface_file int"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line =
    "where int.profit_type_cd in (PFTCLTBILL,PFTPTACCT, PFTCLTACCT)))"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "join opr"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "where opr.health_plan_id = c1.health_plan_id and"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "opr.organization_id = process_request->ins_org_id and"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "opr.org_plan_reltn_cd = INSURANCE_CARRIER and"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "opr.active_ind = 1"
   ELSE
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("join c",trim(cnvtstring(z),3)," where c",trim(
      cnvtstring(z),3),".encntr_id = c",
     trim(cnvtstring((z - 1)),3),".encntr_id and")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("(c",trim(cnvtstring(z),3),".process_flg = 0")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "or"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".process_flg= 1")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "or"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".process_flg = 2")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "or"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".process_flg = 3")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "or"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".process_flg = 4)")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("and c",trim(cnvtstring(z),3),".active_ind = 1")
   ENDIF
   IF (z > 1)
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "and datetimecmp("
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring((z - 1)),3),".service_dt_tm,"
     )
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".service_dt_tm) = 0")
   ENDIF
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("join cm",trim(cnvtstring(z),3))
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat(" where cm",trim(cnvtstring(z),3),
    ".charge_item_id = c",trim(cnvtstring(z),3),".charge_item_id")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("and cm",trim(cnvtstring(z),3),".nomen_id = ",
    cnvtstring(ct_detail->details[z].rule_entity_id))
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("and cm",trim(cnvtstring(z),3),
    ".field4_id != process_request->ct_rule_id")
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "order by "
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (z < details_size)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id,")
   ELSE
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id")
   ENDIF
 ENDFOR
 FOR (m = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (m <= details_size)
    SET select_s->lines[line_cnt].sel_line = "head"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(m),3),".charge_item_id")
    IF (m=1)
     SET line_cnt = (line_cnt+ 1)
     SET stat = alterlist(select_s->lines,line_cnt)
     SET select_s->lines[line_cnt].sel_line = "last_id ="
     SET line_cnt = (line_cnt+ 1)
     SET stat = alterlist(select_s->lines,line_cnt)
     SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(m),3),".charge_item_id")
    ENDIF
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("stat = alterlist(request2->charges, ",trim(
      cnvtstring(details_size),3),")")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(m),3),
     "]->process_flg = c",trim(cnvtstring(m),3),".process_flg")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(m),3),
     "]->service_dt_tm = c",trim(cnvtstring(m),3),".service_dt_tm")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("call echo ('c[",trim(cnvtstring(m),3),
     "].process_flg:  ')")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("call echo(request2->charges[",trim(cnvtstring(m),
      3),"]->process_flg)")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("if ((request2->charges[",trim(cnvtstring(m),3),
     "]->process_flg != 0) and")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("(request2->charges[",trim(cnvtstring(m),3),
     "]->process_flg != 999)) ")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "process_ind = 1"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "endif"
   ENDIF
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo(build('Process_ind is ' ,  process_ind))"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "detail"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "var = var + 1"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = concat("stat = alterlist(request2->charges, ",trim(
   cnvtstring(details_size),3),")")
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "request2->encntr_id = c1.encntr_id"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "request2->person_id = c1.person_id"
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->charge_item_id = c",trim(cnvtstring(z),3),".charge_item_id")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->detail_type_cd = code_val->15729_PRECURSOR")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->item_quantity = c",trim(cnvtstring(z),3),".item_quantity")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->item_price = c",trim(cnvtstring(z),3),".item_price")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->rule_entity_id = cm",trim(cnvtstring(z),3),".nomen_id")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("call echo ('c[",trim(cnvtstring(z),3),
    "].charge_item_id:  ')")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("call echo(request2->charges[",trim(cnvtstring(z),
     3),"]->charge_item_id)")
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = concat("request2->charge_qual = ",trim(cnvtstring(
    details_size),3))
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo(build('var is :  ',var))"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "with nocounter, maxqual (c1, 1)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "endif   ;if bill_item_search = 1"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "else  ;process_request->ins_org_id"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "if (bill_item_search = 1)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "select into 'nl:'"
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (z < details_size)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id,")
   ELSE
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id")
   ENDIF
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "from"
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (z < details_size)
    SET select_s->lines[line_cnt].sel_line = concat("charge c",trim(cnvtstring(z),3),",")
   ELSE
    SET select_s->lines[line_cnt].sel_line = concat("charge c",trim(cnvtstring(z),3))
   ENDIF
 ENDFOR
 FOR (z = 1 TO details_size)
  IF (z=1)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "Plan c1 where ((c1.payor_id = process_request->org_id or process_request->org_id = 0)"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "and (c1.health_plan_id = process_request->health_plan_id or process_request->health_plan_id = 0)"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "and (c1.fin_class_cd = process_request->fin_class_cd or process_request->fin_class_cd = 0)"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "and (c1.admit_type_cd = process_request->encntr_type_cd or process_request->encntr_type_cd = 0)"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "and (c1.offset_charge_item_id+0 = 0)"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "and (c1.admit_type_cd != process_request->exclude_encntr_type_cd"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "or process_request->exclude_encntr_type_cd = 0)"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "and (c1.process_flg = 0 or c1.process_flg = 1 or"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "c1.process_flg = 2 or c1.process_flg = 3 or c1.process_flg = 4)"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("and c",trim(cnvtstring(z),3),
    ".charge_item_id+0 > last_id)")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = build("and c1.bill_item_id = ",ct_detail->details[z].
    rule_entity_id)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "and (c1.interface_file_id not in"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "(select int.interface_file_id from interface_file int"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "where int.profit_type_cd in (PFTCLTBILL,PFTPTACCT, PFTCLTACCT)))"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "and not exists(select bh.ct_bundle_history_id from ct_bundle_history bh"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = build(
    "where bh.to_charge_item_id = c1.charge_item_id and bh.ct_rule_id = ",request->ct_rule_id,")")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "and c1.active_ind = 1"
  ELSE
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("join c",trim(cnvtstring(z),3)," where c",trim(
     cnvtstring(z),3),".encntr_id = c",
    trim(cnvtstring((z - 1)),3),".encntr_id and")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = build("c",trim(cnvtstring(z),3),".bill_item_id = ",
    ct_detail->details[z].rule_entity_id," and ")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("(c",trim(cnvtstring(z),3),".process_flg = 0")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "or"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".process_flg= 1")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "or"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".process_flg = 2")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "or"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".process_flg = 3")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "or"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".process_flg = 4)")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "and not exists (select bh.ct_bundle_history_id from ct_bundle_history bh"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("where bh.to_charge_item_id = c",trim(cnvtstring(z
      ),3),".charge_item_id and")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = build("bh.ct_rule_id = ",request->ct_rule_id,")")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("and c",trim(cnvtstring(z),3),".active_ind = 1")
  ENDIF
  IF (z > 1)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "and datetimecmp("
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring((z - 1)),3),".service_dt_tm,")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".service_dt_tm) = 0")
  ENDIF
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "order by "
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (z < details_size)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id,")
   ELSE
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id")
   ENDIF
 ENDFOR
 FOR (m = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (m <= details_size)
    SET select_s->lines[line_cnt].sel_line = "head"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(m),3),".charge_item_id")
    IF (m=1)
     SET line_cnt = (line_cnt+ 1)
     SET stat = alterlist(select_s->lines,line_cnt)
     SET select_s->lines[line_cnt].sel_line = "last_id ="
     SET line_cnt = (line_cnt+ 1)
     SET stat = alterlist(select_s->lines,line_cnt)
     SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(m),3),".charge_item_id")
    ENDIF
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("stat = alterlist(request2->charges, ",trim(
      cnvtstring(details_size),3),")")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(m),3),
     "]->process_flg = c",trim(cnvtstring(m),3),".process_flg")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(m),3),
     "]->service_dt_tm = c",trim(cnvtstring(m),3),".service_dt_tm")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("call echo ('c[",trim(cnvtstring(m),3),
     "].process_flg:  ')")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("call echo(request2->charges[",trim(cnvtstring(m),
      3),"]->process_flg)")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("if ((request2->charges[",trim(cnvtstring(m),3),
     "]->process_flg != 0) and")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("(request2->charges[",trim(cnvtstring(m),3),
     "]->process_flg != 999)) ")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "process_ind = 1"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "endif"
   ENDIF
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo(build('Process_ind is ' ,  process_ind))"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "detail"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "var = var + 1"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = concat("stat = alterlist(request2->charges, ",trim(
   cnvtstring(details_size),3),")")
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "request2->encntr_id = c1.encntr_id"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo(build('c1.encntr_id: ', c1.encntr_id))"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "request2->person_id = c1.person_id"
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->charge_item_id = c",trim(cnvtstring(z),3),".charge_item_id")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->detail_type_cd = code_val->15729_PRECURSOR")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->item_quantity = c",trim(cnvtstring(z),3),".item_quantity")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->item_price = c",trim(cnvtstring(z),3),".item_price")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->rule_entity_id = c",trim(cnvtstring(z),3),".bill_item_id")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("call echo ('c[",trim(cnvtstring(z),3),
    "].charge_item_id:  ')")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("call echo(request2->charges[",trim(cnvtstring(z),
     3),"]->charge_item_id)")
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = concat("request2->charge_qual = ",trim(cnvtstring(
    details_size),3))
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo(build('var is :  ',var))"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "with nocounter, maxqual (c1, 1)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "else   ;if bill_item_search = 1"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "select into 'nl:'"
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (z < details_size)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id,cm",
     trim(cnvtstring(z),3),".field4_id,cm",
     trim(cnvtstring(z),3),".nomen_id,")
   ELSE
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id,cm",
     trim(cnvtstring(z),3),".field4_id,cm",
     trim(cnvtstring(z),3),".nomen_id")
   ENDIF
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "from"
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (z < details_size)
    SET select_s->lines[line_cnt].sel_line = concat("charge c",trim(cnvtstring(z),3),",charge_mod cm",
     trim(cnvtstring(z),3),",")
   ELSE
    SET select_s->lines[line_cnt].sel_line = concat("charge c",trim(cnvtstring(z),3),",charge_mod cm",
     trim(cnvtstring(z),3))
   ENDIF
 ENDFOR
 FOR (z = 1 TO details_size)
   IF (z=1)
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line =
    "Plan c1 where ((c1.payor_id = process_request->org_id or process_request->org_id = 0)"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line =
    "and (c1.health_plan_id = process_request->health_plan_id or process_request->health_plan_id = 0)"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line =
    "and (c1.fin_class_cd = process_request->fin_class_cd or process_request->fin_class_cd = 0)"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line =
    "and (c1.admit_type_cd = process_request->encntr_type_cd or process_request->encntr_type_cd = 0)"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "and (c1.offset_charge_item_id+0 = 0)"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line =
    "and (c1.admit_type_cd != process_request->exclude_encntr_type_cd"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "or process_request->exclude_encntr_type_cd = 0)"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "and (c1.process_flg =  0 or c1.process_flg = 1 or"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line =
    "c1.process_flg = 2 or c1.process_flg = 3 or c1.process_flg = 4)"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("and c",trim(cnvtstring(z),3),
     ".charge_item_id+0 > last_id)")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "and c1.active_ind = 1"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "and (c1.interface_file_id not in"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "(select int.interface_file_id from interface_file int"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line =
    "where int.profit_type_cd in (PFTCLTBILL,PFTPTACCT, PFTCLTACCT)))"
   ELSE
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("join c",trim(cnvtstring(z),3)," where c",trim(
      cnvtstring(z),3),".encntr_id = c",
     trim(cnvtstring((z - 1)),3),".encntr_id and")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("(c",trim(cnvtstring(z),3),".process_flg = 0")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "or"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".process_flg= 1")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "or"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".process_flg = 2")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "or"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".process_flg = 3")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "or"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".process_flg = 4)")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("and c",trim(cnvtstring(z),3),".active_ind = 1")
   ENDIF
   IF (z > 1)
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "and datetimecmp("
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring((z - 1)),3),".service_dt_tm,"
     )
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".service_dt_tm) = 0")
   ENDIF
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("join cm",trim(cnvtstring(z),3))
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat(" where cm",trim(cnvtstring(z),3),
    ".charge_item_id = c",trim(cnvtstring(z),3),".charge_item_id")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("and cm",trim(cnvtstring(z),3),".nomen_id = ",
    cnvtstring(ct_detail->details[z].rule_entity_id))
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("and cm",trim(cnvtstring(z),3),
    ".field4_id != process_request->ct_rule_id")
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "order by "
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (z < details_size)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id,")
   ELSE
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id")
   ENDIF
 ENDFOR
 FOR (m = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (m <= details_size)
    SET select_s->lines[line_cnt].sel_line = "head"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(m),3),".charge_item_id")
    IF (m=1)
     SET line_cnt = (line_cnt+ 1)
     SET stat = alterlist(select_s->lines,line_cnt)
     SET select_s->lines[line_cnt].sel_line = "last_id ="
     SET line_cnt = (line_cnt+ 1)
     SET stat = alterlist(select_s->lines,line_cnt)
     SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(m),3),".charge_item_id")
    ENDIF
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("stat = alterlist(request2->charges, ",trim(
      cnvtstring(details_size),3),")")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(m),3),
     "]->process_flg = c",trim(cnvtstring(m),3),".process_flg")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(m),3),
     "]->service_dt_tm = c",trim(cnvtstring(m),3),".service_dt_tm")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("call echo ('c[",trim(cnvtstring(m),3),
     "].process_flg:  ')")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("call echo(request2->charges[",trim(cnvtstring(m),
      3),"]->process_flg)")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("if ((request2->charges[",trim(cnvtstring(m),3),
     "]->process_flg != 0) and")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("(request2->charges[",trim(cnvtstring(m),3),
     "]->process_flg != 999)) ")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "process_ind = 1"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "endif"
   ENDIF
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo(build('Process_ind is ' ,  process_ind))"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "detail"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "var = var + 1"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = concat("stat = alterlist(request2->charges, ",trim(
   cnvtstring(details_size),3),")")
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "request2->encntr_id = c1.encntr_id"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "request2->person_id = c1.person_id"
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->charge_item_id = c",trim(cnvtstring(z),3),".charge_item_id")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->detail_type_cd = code_val->15729_PRECURSOR")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->item_quantity = c",trim(cnvtstring(z),3),".item_quantity")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->item_price = c",trim(cnvtstring(z),3),".item_price")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->rule_entity_id = cm",trim(cnvtstring(z),3),".nomen_id")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("call echo ('c[",trim(cnvtstring(z),3),
    "].charge_item_id:  ')")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("call echo(request2->charges[",trim(cnvtstring(z),
     3),"]->charge_item_id)")
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = concat("request2->charge_qual = ",trim(cnvtstring(
    details_size),3))
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo(build('var is :  ',var))"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "with nocounter, maxqual (c1, 1)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "endif   ;if bill_item_search = 1"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "endif  ;process_request->ins_org_id"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set request2->rule_id = process_request->ct_rule_id"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set request2->payor_id = process_request->org_id"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set failed = FALSE"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "If (var > 0)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set status = 'S'"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "if (process_ind = 1)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "for (i = 1 to request2->charge_qual)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line =
 "update into charge c set c.process_flg = 778 where c.process_flg = 0 and"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "charge_item_id+0 = request2->charges[i]->charge_item_id"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "commit"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "endfor"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "else"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "execute ct_create_result"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "endif"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "endif"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo('end while')"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "endwhile"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line =
 "update into charge c set c.process_flg = 14 where c.process_flg = 778"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "commit"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo(build('status is: ', status))"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "/*New Profit Logic begin*/"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo('New Profit Logic begin')"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "update into charge c set c.process_flg = 100"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "where c.process_flg in (114,178)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "update into charge c set c.process_flg = 999"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "where c.process_flg in (914,978)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set status = 'Z'"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set var = 0"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set last_id = 0"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set request2->encntr_id = 0"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set request2->payor_id = 0"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set request2->rule_id = 0"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set request2->person_id = 0"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set request2->bundle_id = 0"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set request2->charge_qual = 0"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set stat = alterlist(request2->charges,0)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "free set reply_credit"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "record reply_credit"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "( 1 new_charge_item_id = f8"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "1 charge_mod_qual = i2"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "1 charge_mods[*]"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "2 charge_mod_id = f8"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = ")"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set today = cnvtdatetime(curdate,curtime3)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line =
 "set today = cnvtdatetime(concat(format(today, 'DD-MMM-YYYY;;D'), ' 00:00:00.00'))"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line =
 "set from_date = datetimeadd(today, -(NumberOfDaysBackToProcess))"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set var = 1"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "while(var > 0)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set creditchargescount = 0"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set var = 0"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set process_ind = 0"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "free set charges_to_credit"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "record charges_to_credit"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "(1 charge_qual = i2"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "1 charges[*]"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "2 charge_item_id = f8"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = ")"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "if (process_request->ins_org_id > 0)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "if (bill_item_search = 1)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo('PROFIT bill_item_search is 1')"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "select into 'nl:'"
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (z < details_size)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id,")
   ELSE
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id")
   ENDIF
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "from"
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (z < details_size)
    SET select_s->lines[line_cnt].sel_line = concat("charge c",trim(cnvtstring(z),3),",")
   ELSE
    SET select_s->lines[line_cnt].sel_line = concat("charge c",trim(cnvtstring(z),3))
   ENDIF
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = ",org_plan_reltn opr"
 FOR (z = 1 TO details_size)
  IF (z=1)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "Plan c1 where ((c1.payor_id = process_request->org_id or process_request->org_id = 0)"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "and (c1.health_plan_id = process_request->health_plan_id or process_request->health_plan_id = 0)"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "and (c1.fin_class_cd = process_request->fin_class_cd or process_request->fin_class_cd = 0)"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "and (c1.admit_type_cd = process_request->encntr_type_cd or process_request->encntr_type_cd = 0)"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "and (c1.offset_charge_item_id+0 = 0)"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "and (c1.admit_type_cd != process_request->exclude_encntr_type_cd"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "or process_request->exclude_encntr_type_cd = 0)"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "and (c1.process_flg+0 in (999,100,1,2,3,4))"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = build("and c1.bill_item_id = ",ct_detail->details[z].
    rule_entity_id)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "and c1.service_dt_tm > cnvtdatetime(from_date)"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "and c1.charge_item_id+0 > last_id"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "and c1.bundle_id = 0"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "and c1.active_ind = 1)"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "and not exists(select bh.ct_bundle_history_id from ct_bundle_history bh"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = build(
    "where bh.to_charge_item_id = c1.charge_item_id and bh.ct_rule_id = ",request->ct_rule_id,")")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "join opr"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "where opr.health_plan_id = c1.health_plan_id and"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "opr.organization_id = process_request->ins_org_id and"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "opr.org_plan_reltn_cd = INSURANCE_CARRIER and"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "opr.active_ind = 1"
  ELSE
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("join c",trim(cnvtstring(z),3)," where c",trim(
     cnvtstring(z),3),".encntr_id = c",
    trim(cnvtstring((z - 1)),3),".encntr_id and")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".active_ind = 1 and ")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = build("c",trim(cnvtstring(z),3),".bill_item_id = ",
    ct_detail->details[z].rule_entity_id," and ")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),
    ".process_flg+0 in (999,100,1,2,3,4)")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "and not exists (select bh.ct_bundle_history_id from ct_bundle_history bh"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("where bh.to_charge_item_id = c",trim(cnvtstring(z
      ),3),".charge_item_id and")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = build("bh.ct_rule_id = ",request->ct_rule_id,")")
  ENDIF
  IF (z > 1)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "and datetimecmp("
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring((z - 1)),3),".service_dt_tm,")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".service_dt_tm) = 0")
  ENDIF
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "order by "
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (z < details_size)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id,")
   ELSE
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id")
   ENDIF
 ENDFOR
 FOR (m = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (m <= details_size)
    SET select_s->lines[line_cnt].sel_line = "head"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(m),3),".charge_item_id")
    IF (m=1)
     SET line_cnt = (line_cnt+ 1)
     SET stat = alterlist(select_s->lines,line_cnt)
     SET select_s->lines[line_cnt].sel_line = "last_id ="
     SET line_cnt = (line_cnt+ 1)
     SET stat = alterlist(select_s->lines,line_cnt)
     SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(m),3),".charge_item_id")
    ENDIF
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("stat = alterlist(request2->charges, ",trim(
      cnvtstring(details_size),3),")")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(m),3),
     "]->process_flg = c",trim(cnvtstring(m),3),".process_flg")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(m),3),
     "]->service_dt_tm = c",trim(cnvtstring(m),3),".service_dt_tm")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("call echo ('c[",trim(cnvtstring(m),3),
     "].process_flg:  ')")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("call echo(request2->charges[",trim(cnvtstring(m),
      3),"]->process_flg)")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("if (request2->charges[",trim(cnvtstring(m),3),
     "]->process_flg != 100"," and request2->charges[",trim(cnvtstring(m),3),
     "]->process_flg != 999)")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "process_ind = 1"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "endif"
   ENDIF
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo(build('Process_ind is ' ,  process_ind))"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "detail"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "var = var + 1"
 IF (details_size < 1)
  SET line_cnt = (line_cnt+ 1)
  SET stat = alterlist(select_s->lines,line_cnt)
  SET select_s->lines[line_cnt].sel_line = "creditchargescount = creditchargescount + 1"
  SET line_cnt = (line_cnt+ 1)
  SET stat = alterlist(select_s->lines,line_cnt)
  SET select_s->lines[line_cnt].sel_line = concat(
   "stat = alterlist(charges_to_credit->charges, creditchargescount)")
  SET line_cnt = (line_cnt+ 1)
  SET stat = alterlist(select_s->lines,line_cnt)
  SET select_s->lines[line_cnt].sel_line = concat(
   "charges_to_credit->charges[creditchargescount]->charge_item_id = c",trim(cnvtstring(details_size),
    3),".charge_item_id")
 ENDIF
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = concat("stat = alterlist(request2->charges, ",trim(
   cnvtstring(details_size),3),")")
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "request2->encntr_id = c1.encntr_id"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "request2->person_id = c1.person_id"
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "creditchargescount = creditchargescount + 1"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->charge_item_id = c",trim(cnvtstring(z),3),".charge_item_id")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat(
    "stat = alterlist(charges_to_credit->charges, creditchargescount)")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat(
    "charges_to_credit->charges[creditchargescount]->charge_item_id = c",trim(cnvtstring(z),3),
    ".charge_item_id")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->detail_type_cd = code_val->15729_PRECURSOR")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->item_quantity = c",trim(cnvtstring(z),3),".item_quantity")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->item_price = c",trim(cnvtstring(z),3),".item_price")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->rule_entity_id = c",trim(cnvtstring(z),3),".bill_item_id")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("call echo ('c[",trim(cnvtstring(z),3),
    "].charge_item_id:  ')")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("call echo(request2->charges[",trim(cnvtstring(z),
     3),"]->charge_item_id)")
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = concat("request2->charge_qual = ",trim(cnvtstring(
    details_size),3))
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo(build('var is :  ',var))"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "with nocounter, maxqual (c1, 1)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "else  ;if bill_item_search > 1"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "select into 'nl:'"
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (z < details_size)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id, cm",
     trim(cnvtstring(z),3),".field4_id,cm",
     trim(cnvtstring(z),3),".nomen_id,")
   ELSE
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id,cm",
     trim(cnvtstring(z),3),".field4_id,cm",
     trim(cnvtstring(z),3),".nomen_id")
   ENDIF
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "from"
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (z < details_size)
    SET select_s->lines[line_cnt].sel_line = concat("charge c",trim(cnvtstring(z),3),",charge_mod cm",
     trim(cnvtstring(z),3),",")
   ELSE
    SET select_s->lines[line_cnt].sel_line = concat("charge c",trim(cnvtstring(z),3),",charge_mod cm",
     trim(cnvtstring(z),3))
   ENDIF
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = ",org_plan_reltn opr"
 FOR (z = 1 TO details_size)
   IF (z=1)
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line =
    "Plan c1 where ((c1.payor_id = process_request->org_id or process_request->org_id = 0)"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line =
    "and (c1.health_plan_id = process_request->health_plan_id or process_request->health_plan_id = 0)"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line =
    "and (c1.fin_class_cd = process_request->fin_class_cd or process_request->fin_class_cd = 0)"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line =
    "and (c1.admit_type_cd = process_request->encntr_type_cd or process_request->encntr_type_cd = 0)"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "and (c1.offset_charge_item_id+0 = 0)"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line =
    "and (c1.admit_type_cd != process_request->exclude_encntr_type_cd"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "or process_request->exclude_encntr_type_cd = 0)"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "and c1.process_flg+0 in (999,100,1,2,3,4)"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "and c1.service_dt_tm > cnvtdatetime(from_date)"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "and c1.charge_item_id+0 > last_id"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "and c1.bundle_id = 0"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "and c1.active_ind = 1)"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "join opr"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "where opr.health_plan_id = c1.health_plan_id and"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "opr.organization_id = process_request->ins_org_id and"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "opr.org_plan_reltn_cd = INSURANCE_CARRIER and"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "opr.active_ind = 1"
   ELSE
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("join c",trim(cnvtstring(z),3)," where c",trim(
      cnvtstring(z),3),".encntr_id = c",
     trim(cnvtstring((z - 1)),3),".encntr_id and ")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".active_ind = 1 and ")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),
     ".process_flg+0 in (999,100,1,2,3,4)")
   ENDIF
   IF (z > 1)
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "and datetimecmp("
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring((z - 1)),3),".service_dt_tm,"
     )
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".service_dt_tm) = 0")
   ENDIF
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("join cm",trim(cnvtstring(z),3))
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat(" where cm",trim(cnvtstring(z),3),
    ".charge_item_id = c",trim(cnvtstring(z),3),".charge_item_id")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("and cm",trim(cnvtstring(z),3),".nomen_id = ",
    cnvtstring(ct_detail->details[z].rule_entity_id))
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("and cm",trim(cnvtstring(z),3),
    ".field4_id != process_request->ct_rule_id")
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "order by "
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (z < details_size)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id,")
   ELSE
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id")
   ENDIF
 ENDFOR
 FOR (m = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (m <= details_size)
    SET select_s->lines[line_cnt].sel_line = "head"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(m),3),".charge_item_id")
    IF (m=1)
     SET line_cnt = (line_cnt+ 1)
     SET stat = alterlist(select_s->lines,line_cnt)
     SET select_s->lines[line_cnt].sel_line = "last_id = "
     SET line_cnt = (line_cnt+ 1)
     SET stat = alterlist(select_s->lines,line_cnt)
     SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(m),3),".charge_item_id")
    ENDIF
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("stat = alterlist(request2->charges, ",trim(
      cnvtstring(details_size),3),")")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(m),3),
     "]->process_flg = c",trim(cnvtstring(m),3),".process_flg")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(m),3),
     "]->service_dt_tm = c",trim(cnvtstring(m),3),".service_dt_tm")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("call echo ('c[",trim(cnvtstring(m),3),
     "].process_flg:  ')")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("call echo(request2->charges[",trim(cnvtstring(m),
      3),"]->process_flg)")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("if (request2->charges[",trim(cnvtstring(m),3),
     "]->process_flg != 100"," and request2->charges[",trim(cnvtstring(m),3),
     "]->process_flg != 999)")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "process_ind = 1"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "endif"
   ENDIF
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo(build('Process_ind is ' ,  process_ind))"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "detail"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "var = var + 1"
 IF (details_size < 1)
  SET line_cnt = (line_cnt+ 1)
  SET stat = alterlist(select_s->lines,line_cnt)
  SET select_s->lines[line_cnt].sel_line = "creditchargescount = creditchargescount + 1"
  SET line_cnt = (line_cnt+ 1)
  SET stat = alterlist(select_s->lines,line_cnt)
  SET select_s->lines[line_cnt].sel_line = concat(
   "stat = alterlist(charges_to_credit->charges, creditchargescount)")
  SET line_cnt = (line_cnt+ 1)
  SET stat = alterlist(select_s->lines,line_cnt)
  SET select_s->lines[line_cnt].sel_line = concat(
   "charges_to_credit->charges[creditchargescount]->charge_item_id = c",trim(cnvtstring(details_size),
    3),".charge_item_id")
 ENDIF
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = concat("stat = alterlist(request2->charges, ",trim(
   cnvtstring(details_size),3),")")
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "request2->encntr_id = c1.encntr_id"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "request2->person_id = c1.person_id"
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "creditchargescount = creditchargescount + 1"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->charge_item_id = c",trim(cnvtstring(z),3),".charge_item_id")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat(
    "stat = alterlist(charges_to_credit->charges, creditchargescount)")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat(
    "charges_to_credit->charges[creditchargescount]->charge_item_id = c",trim(cnvtstring(z),3),
    ".charge_item_id")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->detail_type_cd = code_val->15729_PRECURSOR")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->item_quantity = c",trim(cnvtstring(z),3),".item_quantity")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->item_price = c",trim(cnvtstring(z),3),".item_price")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->rule_entity_id = cm",trim(cnvtstring(z),3),".nomen_id")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("call echo ('c[",trim(cnvtstring(z),3),
    "].charge_item_id:  ')")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("call echo(request2->charges[",trim(cnvtstring(z),
     3),"]->charge_item_id)")
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = concat("request2->charge_qual = ",trim(cnvtstring(
    details_size),3))
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo(build('var is :  ',var))"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "with nocounter, maxqual (c1, 1)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "endif  ;if bill_item_search"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "else  ;if process_request->ins_org_id > 0"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "if (bill_item_search = 1)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo('PROFIT bill_item_search is 1')"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "select into 'nl:'"
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (z < details_size)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id,")
   ELSE
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id")
   ENDIF
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "from"
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (z < details_size)
    SET select_s->lines[line_cnt].sel_line = concat("charge c",trim(cnvtstring(z),3),",")
   ELSE
    SET select_s->lines[line_cnt].sel_line = concat("charge c",trim(cnvtstring(z),3))
   ENDIF
 ENDFOR
 FOR (z = 1 TO details_size)
  IF (z=1)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "Plan c1 where ((c1.payor_id = process_request->org_id or process_request->org_id = 0)"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "and (c1.health_plan_id = process_request->health_plan_id or process_request->health_plan_id = 0)"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "and (c1.fin_class_cd = process_request->fin_class_cd or process_request->fin_class_cd = 0)"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "and (c1.admit_type_cd = process_request->encntr_type_cd or process_request->encntr_type_cd = 0)"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "and (c1.offset_charge_item_id+0 = 0)"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "and (c1.admit_type_cd != process_request->exclude_encntr_type_cd"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "or process_request->exclude_encntr_type_cd = 0)"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "and (c1.process_flg+0 in (999,100,1,2,3,4))"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = build("and c1.bill_item_id = ",ct_detail->details[z].
    rule_entity_id)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "and c1.service_dt_tm > cnvtdatetime(from_date)"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "and c1.charge_item_id+0 > last_id"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "and c1.bundle_id = 0"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "and c1.active_ind = 1)"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "and not exists(select bh.ct_bundle_history_id from ct_bundle_history bh"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = build(
    "where bh.to_charge_item_id = c1.charge_item_id and bh.ct_rule_id = ",request->ct_rule_id,")")
  ELSE
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("join c",trim(cnvtstring(z),3)," where c",trim(
     cnvtstring(z),3),".encntr_id = c",
    trim(cnvtstring((z - 1)),3),".encntr_id and")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".active_ind = 1 and ")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = build("c",trim(cnvtstring(z),3),".bill_item_id = ",
    ct_detail->details[z].rule_entity_id," and ")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),
    ".process_flg+0 in (999,100,1,2,3,4)")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line =
   "and not exists (select bh.ct_bundle_history_id from ct_bundle_history bh"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("where bh.to_charge_item_id = c",trim(cnvtstring(z
      ),3),".charge_item_id and")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = build("bh.ct_rule_id = ",request->ct_rule_id,")")
  ENDIF
  IF (z > 1)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "and datetimecmp("
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring((z - 1)),3),".service_dt_tm,")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".service_dt_tm) = 0")
  ENDIF
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "order by "
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (z < details_size)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id,")
   ELSE
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id")
   ENDIF
 ENDFOR
 FOR (m = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (m <= details_size)
    SET select_s->lines[line_cnt].sel_line = "head"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(m),3),".charge_item_id")
    IF (m=1)
     SET line_cnt = (line_cnt+ 1)
     SET stat = alterlist(select_s->lines,line_cnt)
     SET select_s->lines[line_cnt].sel_line = "last_id ="
     SET line_cnt = (line_cnt+ 1)
     SET stat = alterlist(select_s->lines,line_cnt)
     SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(m),3),".charge_item_id")
    ENDIF
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("stat = alterlist(request2->charges, ",trim(
      cnvtstring(details_size),3),")")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(m),3),
     "]->process_flg = c",trim(cnvtstring(m),3),".process_flg")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(m),3),
     "]->service_dt_tm = c",trim(cnvtstring(m),3),".service_dt_tm")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("call echo ('c[",trim(cnvtstring(m),3),
     "].process_flg:  ')")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("call echo(request2->charges[",trim(cnvtstring(m),
      3),"]->process_flg)")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("if (request2->charges[",trim(cnvtstring(m),3),
     "]->process_flg != 100"," and request2->charges[",trim(cnvtstring(m),3),
     "]->process_flg != 999)")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "process_ind = 1"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "endif"
   ENDIF
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo(build('Process_ind is ' ,  process_ind))"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "detail"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "var = var + 1"
 IF (details_size < 1)
  SET line_cnt = (line_cnt+ 1)
  SET stat = alterlist(select_s->lines,line_cnt)
  SET select_s->lines[line_cnt].sel_line = "creditchargescount = creditchargescount + 1"
  SET line_cnt = (line_cnt+ 1)
  SET stat = alterlist(select_s->lines,line_cnt)
  SET select_s->lines[line_cnt].sel_line = concat(
   "stat = alterlist(charges_to_credit->charges, creditchargescount)")
  SET line_cnt = (line_cnt+ 1)
  SET stat = alterlist(select_s->lines,line_cnt)
  SET select_s->lines[line_cnt].sel_line = concat(
   "charges_to_credit->charges[creditchargescount]->charge_item_id = c",trim(cnvtstring(details_size),
    3),".charge_item_id")
 ENDIF
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = concat("stat = alterlist(request2->charges, ",trim(
   cnvtstring(details_size),3),")")
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "request2->encntr_id = c1.encntr_id"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "request2->person_id = c1.person_id"
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "creditchargescount = creditchargescount + 1"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->charge_item_id = c",trim(cnvtstring(z),3),".charge_item_id")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat(
    "stat = alterlist(charges_to_credit->charges, creditchargescount)")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat(
    "charges_to_credit->charges[creditchargescount]->charge_item_id = c",trim(cnvtstring(z),3),
    ".charge_item_id")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->detail_type_cd = code_val->15729_PRECURSOR")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->item_quantity = c",trim(cnvtstring(z),3),".item_quantity")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->item_price = c",trim(cnvtstring(z),3),".item_price")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->rule_entity_id = c",trim(cnvtstring(z),3),".bill_item_id")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("call echo ('c[",trim(cnvtstring(z),3),
    "].charge_item_id:  ')")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("call echo(request2->charges[",trim(cnvtstring(z),
     3),"]->charge_item_id)")
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = concat("request2->charge_qual = ",trim(cnvtstring(
    details_size),3))
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo(build('var is :  ',var))"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "with nocounter, maxqual (c1, 1)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "else  ;if bill_item_search > 1"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "select into 'nl:'"
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (z < details_size)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id, cm",
     trim(cnvtstring(z),3),".field4_id,cm",
     trim(cnvtstring(z),3),".nomen_id,")
   ELSE
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id,cm",
     trim(cnvtstring(z),3),".field4_id,cm",
     trim(cnvtstring(z),3),".nomen_id")
   ENDIF
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "from"
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (z < details_size)
    SET select_s->lines[line_cnt].sel_line = concat("charge c",trim(cnvtstring(z),3),",charge_mod cm",
     trim(cnvtstring(z),3),",")
   ELSE
    SET select_s->lines[line_cnt].sel_line = concat("charge c",trim(cnvtstring(z),3),",charge_mod cm",
     trim(cnvtstring(z),3))
   ENDIF
 ENDFOR
 FOR (z = 1 TO details_size)
   IF (z=1)
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line =
    "Plan c1 where ((c1.payor_id = process_request->org_id or process_request->org_id = 0)"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line =
    "and (c1.health_plan_id = process_request->health_plan_id or process_request->health_plan_id = 0)"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line =
    "and (c1.fin_class_cd = process_request->fin_class_cd or process_request->fin_class_cd = 0)"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line =
    "and (c1.admit_type_cd = process_request->encntr_type_cd or process_request->encntr_type_cd = 0)"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "and (c1.offset_charge_item_id+0 = 0)"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line =
    "and (c1.admit_type_cd != process_request->exclude_encntr_type_cd"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "or process_request->exclude_encntr_type_cd = 0)"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "and c1.process_flg+0 in (999,100,1,2,3,4)"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "and c1.service_dt_tm > cnvtdatetime(from_date)"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "and c1.charge_item_id+0 > last_id"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "and c1.bundle_id = 0"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "and c1.active_ind = 1)"
   ELSE
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("join c",trim(cnvtstring(z),3)," where c",trim(
      cnvtstring(z),3),".encntr_id = c",
     trim(cnvtstring((z - 1)),3),".encntr_id and ")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".active_ind = 1 and ")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),
     ".process_flg+0 in (999,100,1,2,3,4)")
   ENDIF
   IF (z > 1)
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "and datetimecmp("
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring((z - 1)),3),".service_dt_tm,"
     )
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".service_dt_tm) = 0")
   ENDIF
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("join cm",trim(cnvtstring(z),3))
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat(" where cm",trim(cnvtstring(z),3),
    ".charge_item_id = c",trim(cnvtstring(z),3),".charge_item_id")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("and cm",trim(cnvtstring(z),3),".nomen_id = ",
    cnvtstring(ct_detail->details[z].rule_entity_id))
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("and cm",trim(cnvtstring(z),3),
    ".field4_id != process_request->ct_rule_id")
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "order by "
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (z < details_size)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id,")
   ELSE
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(z),3),".charge_item_id")
   ENDIF
 ENDFOR
 FOR (m = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   IF (m <= details_size)
    SET select_s->lines[line_cnt].sel_line = "head"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(m),3),".charge_item_id")
    IF (m=1)
     SET line_cnt = (line_cnt+ 1)
     SET stat = alterlist(select_s->lines,line_cnt)
     SET select_s->lines[line_cnt].sel_line = "last_id = "
     SET line_cnt = (line_cnt+ 1)
     SET stat = alterlist(select_s->lines,line_cnt)
     SET select_s->lines[line_cnt].sel_line = concat("c",trim(cnvtstring(m),3),".charge_item_id")
    ENDIF
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("stat = alterlist(request2->charges, ",trim(
      cnvtstring(details_size),3),")")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(m),3),
     "]->process_flg = c",trim(cnvtstring(m),3),".process_flg")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(m),3),
     "]->service_dt_tm = c",trim(cnvtstring(m),3),".service_dt_tm")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("call echo ('c[",trim(cnvtstring(m),3),
     "].process_flg:  ')")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("call echo(request2->charges[",trim(cnvtstring(m),
      3),"]->process_flg)")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = concat("if (request2->charges[",trim(cnvtstring(m),3),
     "]->process_flg != 100"," and request2->charges[",trim(cnvtstring(m),3),
     "]->process_flg != 999)")
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "process_ind = 1"
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(select_s->lines,line_cnt)
    SET select_s->lines[line_cnt].sel_line = "endif"
   ENDIF
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo(build('Process_ind is ' ,  process_ind))"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "detail"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "var = var + 1"
 IF (details_size < 1)
  SET line_cnt = (line_cnt+ 1)
  SET stat = alterlist(select_s->lines,line_cnt)
  SET select_s->lines[line_cnt].sel_line = "creditchargescount = creditchargescount + 1"
  SET line_cnt = (line_cnt+ 1)
  SET stat = alterlist(select_s->lines,line_cnt)
  SET select_s->lines[line_cnt].sel_line = concat(
   "stat = alterlist(charges_to_credit->charges, creditchargescount)")
  SET line_cnt = (line_cnt+ 1)
  SET stat = alterlist(select_s->lines,line_cnt)
  SET select_s->lines[line_cnt].sel_line = concat(
   "charges_to_credit->charges[creditchargescount]->charge_item_id = c",trim(cnvtstring(details_size),
    3),".charge_item_id")
 ENDIF
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = concat("stat = alterlist(request2->charges, ",trim(
   cnvtstring(details_size),3),")")
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "request2->encntr_id = c1.encntr_id"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "request2->person_id = c1.person_id"
 FOR (z = 1 TO details_size)
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = "creditchargescount = creditchargescount + 1"
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->charge_item_id = c",trim(cnvtstring(z),3),".charge_item_id")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat(
    "stat = alterlist(charges_to_credit->charges, creditchargescount)")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat(
    "charges_to_credit->charges[creditchargescount]->charge_item_id = c",trim(cnvtstring(z),3),
    ".charge_item_id")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->detail_type_cd = code_val->15729_PRECURSOR")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->item_quantity = c",trim(cnvtstring(z),3),".item_quantity")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->item_price = c",trim(cnvtstring(z),3),".item_price")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("request2->charges[",trim(cnvtstring(z),3),
    "]->rule_entity_id = cm",trim(cnvtstring(z),3),".nomen_id")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("call echo ('c[",trim(cnvtstring(z),3),
    "].charge_item_id:  ')")
   SET line_cnt = (line_cnt+ 1)
   SET stat = alterlist(select_s->lines,line_cnt)
   SET select_s->lines[line_cnt].sel_line = concat("call echo(request2->charges[",trim(cnvtstring(z),
     3),"]->charge_item_id)")
 ENDFOR
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = concat("request2->charge_qual = ",trim(cnvtstring(
    details_size),3))
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo(build('var is :  ',var))"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "with nocounter, maxqual (c1, 1)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "endif  ;if bill_item_search"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "endif   ;if process_request->ins_org_id > 0"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set request2->rule_id = process_request->ct_rule_id"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set request2->payor_id = process_request->org_id"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set failed = FALSE"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "If (var > 0)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set status = 'S'"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "if (process_ind = 1)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "for (i = 1 to request2->charge_qual)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "if (request2->charges[i]->process_flg = 100)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line =
 "update into charge c set c.process_flg = 178 where c.process_flg = 100 and"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "charge_item_id = request2->charges[i]->charge_item_id"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "commit"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "else"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line =
 "update into charge c set c.process_flg = 978 where c.process_flg = 999 and"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "charge_item_id = request2->charges[i]->charge_item_id"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "commit"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "endif"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "endfor"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "else"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "execute ct_create_result_profit"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line =
 "For (nCount = 1 to value(size(charges_to_credit->charges,5)))"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line =
 "call echo(build('ctrule_xxx::credit charge: ', charges_to_credit->charges[nCount]->charge_item_id))"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line =
 "execute ct_credit_profit_charge charges_to_credit->charges[ncount]->charge_item_id"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "EndFor"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "endif"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "endif"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "Endwhile"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo('CTRULE_XXX::size of structure to credit:')"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo(size(request2->charges,5))"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line =
 "update into charge c set c.process_flg = 114 where c.process_flg = 178"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "commit"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line =
 "update into charge c set c.process_flg = 914 where c.process_flg = 978"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "commit"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo(build('status is: ', status))"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "/*New Profit Logic end*/"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "# END_PROG"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "if (failed = True)"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "set status = 'F'"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "call echo('script failure')"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "endif"
 SET line_cnt = (line_cnt+ 1)
 SET stat = alterlist(select_s->lines,line_cnt)
 SET select_s->lines[line_cnt].sel_line = "end go"
 SET hold_string_rule = cnvtstring(request->ct_rule_id)
 SET filename = concat("ccluserdir:ctrule_",trim(cnvtstring(request->ct_rule_id)),".prg")
 SELECT INTO value(filename)
  sel_line = trim(select_s->lines[d1.seq].sel_line,3)
  FROM (dummyt d1  WITH seq = value(size(select_s->lines,5)))
  PLAN (d1)
  DETAIL
   col 00, sel_line, row + 1
  WITH nocounter, noformfeed, format = variable
 ;end select
 SET cclcom = concat("call compile('",filename,"') go")
 CALL echo(cclcom)
 CALL parser(cclcom)
END GO
