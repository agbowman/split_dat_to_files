CREATE PROGRAM ct_run_charge_transformation:dba
 IF ("Z"=validate(ct_run_charge_transformation_vrsn,"Z"))
  DECLARE ct_run_charge_transformation_vrsn = vc WITH noconstant("45958.009")
 ENDIF
 SET ct_run_charge_transformation_vrsn = "45958.009"
 EXECUTE crmrtl
 EXECUTE srvrtl
 EXECUTE cclseclogin
 SET message = nowindow
 IF (validate(request->ops_date,999)=999)
  IF ((xxcclseclogin->loggedin != 1))
   CALL echo("******************************************")
   CALL echo("*** User Not Signed In.                ***")
   CALL echo("*** Type 'CCLSECLOGIN GO'              ***")
   CALL echo("*** and sign in to continue.           ***")
   CALL echo("******************************************")
   GO TO end_program
  ENDIF
 ENDIF
 RECORD reply1(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationstatus = c15
       3 operationname = c5
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD tier(
   1 tier_qual = i2
   1 tier_list[*]
     2 ct_ruleset_tier_id = f8
     2 priority = f8
     2 organization_id = f8
     2 ins_organization_id = f8
     2 health_plan_id = f8
     2 fin_class_cd = f8
     2 encntr_type_cd = f8
     2 exclude_encntr_type_cd = f8
     2 ct_ruleset_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 rule_qual = i2
     2 rule_list[*]
       3 ct_rule_id = f8
       3 description = vc
       3 action_cd = f8
       3 action_meaning = c12
       3 duration_cd = f8
       3 vocab_type_cd = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 active_ind = i2
       3 active_status_cd = f8
       3 active_status_dt_tm = dq
       3 active_status_prsnl_id = i2
       3 updt_cnt = i4
       3 updt_dt_tm = dq
       3 updt_id = f8
       3 updt_applctx = i4
       3 updt_task = i4
 )
 RECORD process_request(
   1 org_id = f8
   1 ins_org_id = f8
   1 health_plan_id = f8
   1 fin_class_cd = f8
   1 encntr_type_cd = f8
   1 exclude_encntr_type_cd = f8
   1 ct_rule_id = f8
   1 duration_cd = f8
 )
 FREE SET code_val
 RECORD code_val(
   1 18849_replacelist = f8
   1 18849_replaceprice = f8
   1 18849_replaceadjust = f8
   1 18849_modifylist = f8
   1 18849_count = f8
   1 18851_and = f8
   1 18851_or = f8
   1 18851_multiply = f8
   1 18851_add = f8
   1 18851_equal = f8
   1 18851_nochange = f8
   1 18851_remove = f8
   1 172986_subtraction = f8
   1 15729_precursor = f8
   1 15729_result = f8
   1 18850_accession = f8
   1 18850_dtofservice = f8
   1 13029_complete = f8
   1 13028_charge_now = f8
   1 13016_charge_event = f8
 )
 SET reply1->status_data.status = "S"
 SET count1 = 0
 SET count2 = 0
 DECLARE numberofdaysbacktoprocess = i2
 IF (validate(request->batch_selection," ") != " ")
  SET numberofdaysbacktoprocess = cnvtint(request->batch_selection)
  CALL echo(build("The number of days to process from ops is: ",numberofdaysbacktoprocess))
 ELSE
  SET numberofdaysbacktoprocess = cnvtint( $1)
  CALL echo(build("The number of days to process is: ",numberofdaysbacktoprocess))
 ENDIF
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE list = f8
 DECLARE listcnt = i4
 SET code_set = 18849
 SET cdf_meaning = "REPLACELIST"
 SET listcnt = 1
 SET iret = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),listcnt,list)
 IF (iret=0)
  SET code_val->18849_replacelist = list
 ELSE
  CALL echo("Falure")
 ENDIF
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE price = f8
 DECLARE pricecnt = i4
 SET code_set = 18849
 SET cdf_meaning = "REPLACEPRICE"
 SET pricecnt = 1
 SET iret = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),pricecnt,price)
 IF (iret=0)
  SET code_val->18849_replaceprice = price
 ELSE
  CALL echo("Falure")
 ENDIF
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE adjst = f8
 DECLARE adjustcnt = i4
 SET code_set = 18849
 SET cdf_meaning = "REPLACEADJST"
 SET adjustcnt = 1
 SET iret = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),adjustcnt,adjst)
 IF (iret=0)
  SET code_val->18849_replaceadjust = adjst
 ELSE
  CALL echo("Falure")
 ENDIF
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE count5 = f8
 DECLARE countlist = i4
 SET code_set = 18849
 SET cdf_meaning = "COUNT"
 SET countlist = 1
 SET iret = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),countlist,count5)
 IF (iret=0)
  SET code_val->18849_count = count5
 ELSE
  CALL echo("Falure")
 ENDIF
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE modify = f8
 DECLARE modifycnt = i4
 SET code_set = 18849
 SET cdf_meaning = "MODIFYLIST"
 SET modifycnt = 1
 SET iret = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),modifycnt,modify)
 IF (iret=0)
  SET code_val->18849_modifylist = modify
 ELSE
  CALL echo("Falure")
 ENDIF
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE dtofservice = f8
 DECLARE dtofservecnt = i4
 SET code_set = 18850
 SET cdf_meaning = "DTOFSERVICE"
 SET dtofservicecnt = 1
 SET iret = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),dtofservicecnt,dtofservice)
 IF (iret=0)
  SET code_val->18850_dtofservice = dtofservice
 ELSE
  CALL echo("Falure")
 ENDIF
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE accession = f8
 DECLARE accessioncnt = i4
 SET code_set = 18850
 SET cdf_meaning = "ACCESSION"
 SET accessioncnt = 1
 SET iret = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),accessioncnt,accession)
 IF (iret=0)
  SET code_val->18850_accession = accession
 ELSE
  CALL echo("Falure")
 ENDIF
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE precursor = f8
 DECLARE precursorcnt = i4
 SET code_set = 15729
 SET cdf_meaning = "PRECURSOR"
 SET precursorcnt = 1
 SET iret = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),precursorcnt,precursor)
 IF (iret=0)
  SET code_val->15729_precursor = precursor
 ELSE
  CALL echo("Falure")
 ENDIF
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE result = f8
 DECLARE resultcnt = i4
 SET code_set = 15729
 SET cdf_meaning = "RESULT"
 SET resultcnt = 1
 SET iret = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),resultcnt,result)
 IF (iret=0)
  SET code_val->15729_result = result
 ELSE
  CALL echo("Falure")
 ENDIF
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE add = f8
 DECLARE addcnt = i4
 SET code_set = 18851
 SET cdf_meaning = "ADD"
 SET addcnt = 1
 SET iret = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),addcnt,add)
 IF (iret=0)
  SET code_val->18851_add = add
 ELSE
  CALL echo("Falure")
 ENDIF
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE andvalue = f8
 DECLARE andcnt = i4
 SET code_set = 18851
 SET cdf_meaning = "AND"
 SET andcnt = 1
 SET iret = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),andcnt,andvalue)
 IF (iret=0)
  SET code_val->18851_and = andvalue
 ELSE
  CALL echo("Falure")
 ENDIF
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE equal = f8
 DECLARE equalcnt = i4
 SET code_set = 18851
 SET cdf_meaning = "EQUAL"
 SET equalcnt = 1
 SET iret = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),equalcnt,equal)
 IF (iret=0)
  SET code_val->18851_equal = equal
 ELSE
  CALL echo("Falure")
 ENDIF
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE multiply = f8
 DECLARE multiplycnt = i4
 SET code_set = 18851
 SET cdf_meaning = "MULTIPLY"
 SET multiplycnt = 1
 SET iret = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),multiplycnt,multiply)
 IF (iret=0)
  SET code_val->18851_multiply = multiply
 ELSE
  CALL echo("Falure")
 ENDIF
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE orvalue = f8
 DECLARE orcnt = i4
 SET code_set = 18851
 SET cdf_meaning = "OR"
 SET orcnt = 1
 SET iret = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),orcnt,orvalue)
 IF (iret=0)
  SET code_val->18851_or = orvalue
 ELSE
  CALL echo("Falure")
 ENDIF
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE subtraction = f8
 DECLARE subtractioncnt = i4
 SET code_set = 18851
 SET cdf_meaning = "SUBTRACTION"
 SET subtractioncnt = 1
 SET iret = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),subtractioncnt,subtraction)
 IF (iret=0)
  SET code_val->172986_subtraction = subtraction
 ELSE
  CALL echo("Falure")
 ENDIF
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE remove = f8
 DECLARE removecnt = i4
 SET code_set = 18851
 SET cdf_meaning = "REMOVE"
 SET removecnt = 1
 SET iret = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),removecnt,remove)
 IF (iret=0)
  SET code_val->18851_remove = remove
 ELSE
  CALL echo("Falure")
 ENDIF
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE nochange = f8
 DECLARE nochangecnt = i4
 SET code_set = 18851
 SET cdf_meaning = "NOCHANGE"
 SET nochangecnt = 1
 SET iret = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),nochangecnt,nochange)
 IF (iret=0)
  SET code_val->18851_nochange = nochange
 ELSE
  CALL echo("Falure")
 ENDIF
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE complete = f8
 DECLARE completecnt = i4
 SET code_set = 13029
 SET cdf_meaning = "COMPLETE"
 SET completecnt = 1
 SET iret = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),completecnt,complete)
 IF (iret=0)
  SET code_val->13029_complete = complete
 ELSE
  CALL echo("Falure")
 ENDIF
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE chargenow = f8
 DECLARE chargenowcnt = i4
 SET code_set = 13028
 SET cdf_meaning = "CHARGE NOW"
 SET chargenowcnt = 1
 SET iret = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),chargenowcnt,chargenow)
 IF (iret=0)
  SET code_val->13028_charge_now = chargenow
 ELSE
  CALL echo("Falure")
 ENDIF
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE chargeevent = f8
 DECLARE eventcnt = i4
 SET code_set = 13016
 SET cdf_meaning = "CHARGE EVENT"
 SET eventcnt = 1
 SET iret = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),eventcnt,chargeevent)
 IF (iret=0)
  SET code_val->13016_charge_event = chargeevent
 ELSE
  CALL echo("Falure")
 ENDIF
 SELECT INTO "nl:"
  ct.*, e.ct_rule_id, r.*
  FROM ct_ruleset_tier ct,
   ct_ruleset_rule_reltn e,
   ct_rule r
  PLAN (ct
   WHERE ct.active_ind=1
    AND cnvtdatetime(curdate,curtime) BETWEEN ct.beg_effective_dt_tm AND ct.end_effective_dt_tm)
   JOIN (e
   WHERE e.ct_ruleset_cd=ct.ct_ruleset_cd
    AND e.active_ind=1)
   JOIN (r
   WHERE r.ct_rule_id=e.ct_rule_id
    AND r.active_ind=1)
  ORDER BY ct.priority, e.priority
  HEAD ct.priority
   count2 = 0, count1 = (count1+ 1), stat = alterlist(tier->tier_list,count1),
   tier->tier_list[count1].ct_ruleset_tier_id = ct.ct_ruleset_tier_id,
   CALL echo(build("ct_ruleset_tier_id: ",tier->tier_list[count1].ct_ruleset_tier_id)), tier->
   tier_list[count1].priority = ct.priority,
   tier->tier_list[count1].organization_id = ct.organization_id, tier->tier_list[count1].
   ins_organization_id = ct.ins_org_id, tier->tier_list[count1].health_plan_id = ct.health_plan_id,
   tier->tier_list[count1].fin_class_cd = ct.fin_class_cd, tier->tier_list[count1].encntr_type_cd =
   ct.encntr_type_cd, tier->tier_list[count1].exclude_encntr_type_cd = ct.exclude_encntr_type_cd,
   tier->tier_list[count1].ct_ruleset_cd = ct.ct_ruleset_cd, tier->tier_list[count1].
   beg_effective_dt_tm = ct.beg_effective_dt_tm, tier->tier_list[count1].end_effective_dt_tm = ct
   .end_effective_dt_tm,
   tier->tier_list[count1].active_ind = ct.active_ind
  DETAIL
   count2 = (count2+ 1), stat = alterlist(tier->tier_list[count1].rule_list,count2), tier->tier_list[
   count1].rule_list[count2].ct_rule_id = r.ct_rule_id,
   CALL echo(build("ct_rule_id: ",tier->tier_list[count1].rule_list[count2].ct_rule_id)), tier->
   tier_list[count1].rule_list[count2].description = r.description, tier->tier_list[count1].
   rule_list[count2].action_cd = r.action_cd,
   tier->tier_list[count1].rule_list[count2].action_meaning = uar_get_code_meaning(r.action_cd), tier
   ->tier_list[count1].rule_list[count2].duration_cd = r.duration_cd, tier->tier_list[count1].
   rule_list[count2].vocab_type_cd = r.vocab_type_cd,
   tier->tier_list[count1].rule_list[count2].beg_effective_dt_tm = r.beg_effective_dt_tm, tier->
   tier_list[count1].rule_list[count2].end_effective_dt_tm = r.end_effective_dt_tm
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply1->status_data.status = "Z"
 ENDIF
 FOR (crct = 1 TO size(tier->tier_list,5))
   CALL echo(build("size of tier: ",size(tier->tier_list,5)))
   CALL echo(build("Tier_id: ",tier->tier_list.ct_ruleset_tier_id))
   SET process_request->org_id = tier->tier_list[crct].organization_id
   SET process_request->ins_org_id = tier->tier_list[crct].ins_organization_id
   SET process_request->health_plan_id = tier->tier_list[crct].health_plan_id
   SET process_request->fin_class_cd = tier->tier_list[crct].fin_class_cd
   SET process_request->encntr_type_cd = tier->tier_list[crct].encntr_type_cd
   SET process_request->exclude_encntr_type_cd = tier->tier_list[crct].exclude_encntr_type_cd
   FOR (crct2 = 1 TO size(tier->tier_list[crct].rule_list,5))
     SET process_request->ct_rule_id = tier->tier_list[crct].rule_list[crct2].ct_rule_id
     SET process_request->duration_cd = tier->tier_list[crct].rule_list[crct2].duration_cd
     IF ((tier->tier_list[crct].rule_list[crct2].action_meaning="COUNT"))
      CALL echo(build("action_cd is: ",tier->tier_list[crct].rule_list[crct2].action_meaning))
      EXECUTE ct_process_count
     ELSEIF ((tier->tier_list[crct].rule_list[crct2].action_meaning="REPLACECUSM"))
      SET script_custom = concat("ctcustom_",trim(cnvtstring(process_request->ct_rule_id),3))
      CALL echo(build("action_cd is: ",tier->tier_list[crct].rule_list[crct2].action_meaning))
      CALL echo(build("Execute: ",script_custom))
      CALL parser(concat(script_custom," go"))
     ELSE
      SET script_name = concat("ctrule_",trim(cnvtstring(process_request->ct_rule_id),3))
      CALL echo(build("action_cd is: ",tier->tier_list[crct].rule_list[crct2].action_meaning))
      CALL echo(build("Execute: ",script_name))
      CALL parser(concat(script_name," go"))
     ENDIF
   ENDFOR
 ENDFOR
#end_program
END GO
