CREATE PROGRAM dcp_find_active_preg_logic:dba
 SET rev_inc = "708"
 SET ininc = "eks_tell_ekscommon"
 SET ttemp = trim(eks_common->cur_module_name)
 SET eksmodule = trim(ttemp)
 FREE SET ttemp
 SET ttemp = trim(eks_common->event_name)
 SET eksevent = ttemp
 SET eksrequest = eks_common->request_number
 FREE SET ttemp
 DECLARE tcurindex = i4
 DECLARE tinx = i4
 SET tcurindex = 1
 SET tinx = 1
 SET evoke_inx = 1
 SET data_inx = 2
 SET logic_inx = 3
 SET action_inx = 4
 IF ( NOT (validate(eksdata->tqual,"Y")="Y"
  AND validate(eksdata->tqual,"Z")="Z"))
  FREE SET templatetype
  IF (conclude > 0)
   SET templatetype = "ACTION"
   SET basecurindex = (logiccnt+ evokecnt)
   SET tcurindex = 4
  ELSE
   SET templatetype = "LOGIC"
   SET basecurindex = evokecnt
   SET tcurindex = 3
  ENDIF
  SET cbinx = curindex
  SET tinx = logic_inx
 ELSE
  SET templatetype = "EVOKE"
  SET curindex = 0
  SET tcurindex = 0
  SET tinx = 0
 ENDIF
 CALL echo(concat("****  ",format(curdate,"dd-mmm-yyyy;;d")," ",format(curtime3,"hh:mm:ss.cc;3;m"),
   "     Module:  ",
   trim(eksmodule),"  ****"),1,0)
 IF (validate(tname,"Y")="Y"
  AND validate(tname,"Z")="Z")
  IF (templatetype != "EVOKE")
   CALL echo(concat("****  EKM Beginning of ",trim(templatetype)," Template(",build(curindex),
     ")           Event:  ",
     trim(eksevent),"         Request number:  ",cnvtstring(eksrequest)),1,10)
  ELSE
   CALL echo(concat("****  EKM Beginning an Evoke Template","           Event:  ",trim(eksevent),
     "         Request number:  ",cnvtstring(eksrequest)),1,10)
  ENDIF
 ELSE
  IF (templatetype != "EVOKE")
   CALL echo(concat("****  EKM Beginning of ",trim(templatetype)," Template(",build(curindex),"):  ",
     trim(tname),"       Event:  ",trim(eksevent),"         Request number:  ",cnvtstring(eksrequest)
     ),1,10)
  ELSE
   CALL echo(concat("****  EKM Beginning Evoke Template:  ",trim(tname),"       Event:  ",trim(
      eksevent),"         Request number:  ",
     cnvtstring(eksrequest)),1,10)
  ENDIF
 ENDIF
 DECLARE ret_true = i2 WITH protect, constant(100)
 DECLARE ret_false = i2 WITH protect, constant(0)
 DECLARE p_has = vc WITH protect, constant("has")
 DECLARE p_does_not_have = vc WITH protect, constant("does not have")
 DECLARE p_is = vc WITH protect, constant("is")
 DECLARE p_is_not = vc WITH protect, constant("is not")
 DECLARE p_equal = vc WITH protect, constant("equal to")
 DECLARE p_not_equal = vc WITH protect, constant("not equal to")
 DECLARE p_greater = vc WITH protect, constant("greater than")
 DECLARE p_less = vc WITH protect, constant("less than")
 DECLARE p_greater_equal = vc WITH protect, constant("greater than or equal to")
 DECLARE p_less_equal = vc WITH protect, constant("less than or equal to")
 DECLARE p_between = vc WITH protect, constant("between")
 DECLARE p_days = vc WITH protect, constant("days")
 DECLARE p_weeks = vc WITH protect, constant("weeks")
 DECLARE p_months = vc WITH protect, constant("months")
 DECLARE reltn_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23549,"PROBTOPROB"))
 DECLARE reltn_subtype_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",29744,"ASSOCIATED"))
 DECLARE sproblem = vc WITH protect, constant("PROBLEM")
 DECLARE ega_in_days_param = i4 WITH protect, noconstant(0)
 DECLARE ega_in_days_param2 = i4 WITH protect, noconstant(0)
 DECLARE sga = vc WITH protect, noconstant(" ")
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE preg_cnt = i4 WITH protect, noconstant(0)
 DECLARE bfound = i2 WITH protect, noconstant(0)
 DECLARE smsg = vc WITH protect, noconstant(" ")
 DECLARE dnomenid = f8 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE smothercomps = vc WITH protect, noconstant(" ")
 DECLARE param_idx = i4 WITH protect, noconstant(0)
 DECLARE data_idx = i4 WITH protect, noconstant(0)
 DECLARE stemp = vc WITH protect, noconstant(" ")
 DECLARE qualify_until_dt_tm = q8 WITH protect, noconstant(curdate)
 DECLARE max_ega_days = i4 WITH protect, noconstant((7 * 42))
 DECLARE checkactivepregnancy(null) = null
 DECLARE checkmothercomps(null) = null
 DECLARE checkega(null) = null
 DECLARE buildmessage(null) = null
 DECLARE sethealthqualifydttm(null) = null
 FREE RECORD preg_param
 RECORD preg_param(
   1 person_id = f8
   1 evaluation
     2 value = vc
     2 exist_ind = i2
   1 opt_ga_operation
     2 value = vc
     2 exist_ind = i2
   1 opt_ga_value1
     2 value = i4
     2 exist_ind = i2
   1 opt_ga_value2
     2 value = i4
     2 exist_ind = i2
   1 opt_ga_units
     2 value = vc
     2 exist_ind = i2
   1 opt_mother_comp_eval
     2 value = vc
     2 exist_ind = i2
   1 opt_mother_comp
     2 cnt = i4
     2 list[*]
       3 display = vc
       3 value = f8
 )
 FREE RECORD ega_reply
 RECORD ega_reply(
   1 gestation_info[*]
     2 person_id = f8
     2 pregnancy_id = f8
     2 est_gest_age = i4
     2 current_gest_age = i4
     2 est_delivery_date = dq8
     2 edd_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD preg_data
 RECORD preg_data(
   1 preg_cnt = i4
   1 pregs[*]
     2 pregnancy_id = f8
     2 problem_id = f8
   1 match_mother_comp_cnt = i4
   1 mother_comps[*]
     2 value = f8
     2 display = vc
   1 match_ga_ind = i2
   1 ga_in_days = i4
 )
 FREE RECORD opt_mother_complist
 RECORD opt_mother_complist(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
 )
 DECLARE loadpregnancyorganizationsecuritylist() = null
 IF (validate(preg_org_sec_ind)=0)
  DECLARE preg_org_sec_ind = i4 WITH noconstant(0)
  SELECT INTO "nl:"
   FROM dm_info d1,
    dm_info d2
   WHERE d1.info_domain="SECURITY"
    AND d1.info_name="SEC_ORG_RELTN"
    AND d1.info_number=1
    AND d2.info_domain="SECURITY"
    AND d2.info_name="SEC_PREG_ORG_RELTN"
    AND d2.info_number=1
   DETAIL
    preg_org_sec_ind = 1
   WITH nocounter
  ;end select
  CALL echo(build("preg_org_sec_ind=",preg_org_sec_ind))
  IF (preg_org_sec_ind=1)
   FREE RECORD preg_sec_orgs
   RECORD preg_sec_orgs(
     1 qual[*]
       2 org_id = f8
       2 confid_level = i4
   )
   CALL loadpregnancyorganizationsecuritylist(null)
  ENDIF
 ENDIF
 SUBROUTINE loadpregnancyorganizationsecuritylist(null)
   DECLARE org_cnt = i2 WITH noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (validate(sac_org)=1)
    FREE RECORD sac_org
   ENDIF
   IF (validate(_sacrtl_org_inc_,99999)=99999)
    DECLARE _sacrtl_org_inc_ = i2 WITH constant(1)
    RECORD sac_org(
      1 organizations[*]
        2 organization_id = f8
        2 confid_cd = f8
        2 confid_level = i4
    )
    EXECUTE secrtl
    EXECUTE sacrtl
    DECLARE orgcnt = i4 WITH protected, noconstant(0)
    DECLARE secstat = i2
    DECLARE logontype = i4 WITH protect, noconstant(- (1))
    DECLARE dynamic_org_ind = i4 WITH protect, noconstant(- (1))
    DECLARE dcur_trustid = f8 WITH protect, noconstant(0.0)
    DECLARE dynorg_enabled = i4 WITH constant(1)
    DECLARE dynorg_disabled = i4 WITH constant(0)
    DECLARE logontype_nhs = i4 WITH constant(1)
    DECLARE logontype_legacy = i4 WITH constant(0)
    DECLARE confid_cnt = i4 WITH protected, noconstant(0)
    RECORD confid_codes(
      1 list[*]
        2 code_value = f8
        2 coll_seq = f8
    )
    CALL uar_secgetclientlogontype(logontype)
    CALL echo(build("logontype:",logontype))
    IF (logontype != logontype_nhs)
     SET dynamic_org_ind = dynorg_disabled
    ENDIF
    IF (logontype=logontype_nhs)
     SUBROUTINE (getdynamicorgpref(dtrustid=f8) =i4)
       DECLARE scur_trust = vc
       DECLARE pref_val = vc
       DECLARE is_enabled = i4 WITH constant(1)
       DECLARE is_disabled = i4 WITH constant(0)
       SET scur_trust = cnvtstring(dtrustid)
       SET scur_trust = concat(scur_trust,".00")
       IF ( NOT (validate(pref_req,0)))
        RECORD pref_req(
          1 write_ind = i2
          1 delete_ind = i2
          1 pref[*]
            2 contexts[*]
              3 context = vc
              3 context_id = vc
            2 section = vc
            2 section_id = vc
            2 subgroup = vc
            2 entries[*]
              3 entry = vc
              3 values[*]
                4 value = vc
        )
       ENDIF
       IF ( NOT (validate(pref_rep,0)))
        RECORD pref_rep(
          1 pref[*]
            2 section = vc
            2 section_id = vc
            2 subgroup = vc
            2 entries[*]
              3 pref_exists_ind = i2
              3 entry = vc
              3 values[*]
                4 value = vc
          1 status_data
            2 status = c1
            2 subeventstatus[1]
              3 operationname = c25
              3 operationstatus = c1
              3 targetobjectname = c25
              3 targetobjectvalue = vc
        )
       ENDIF
       SET stat = alterlist(pref_req->pref,1)
       SET stat = alterlist(pref_req->pref[1].contexts,2)
       SET stat = alterlist(pref_req->pref[1].entries,1)
       SET pref_req->pref[1].contexts[1].context = "organization"
       SET pref_req->pref[1].contexts[1].context_id = scur_trust
       SET pref_req->pref[1].contexts[2].context = "default"
       SET pref_req->pref[1].contexts[2].context_id = "system"
       SET pref_req->pref[1].section = "workflow"
       SET pref_req->pref[1].section_id = "UK Trust Security"
       SET pref_req->pref[1].entries[1].entry = "dynamic organizations"
       EXECUTE ppr_preferences  WITH replace("REQUEST","PREF_REQ"), replace("REPLY","PREF_REP")
       IF (cnvtupper(pref_rep->pref[1].entries[1].values[1].value)="ENABLED")
        RETURN(is_enabled)
       ELSE
        RETURN(is_disabled)
       ENDIF
     END ;Subroutine
     DECLARE hprop = i4 WITH protect, noconstant(0)
     DECLARE tmpstat = i2
     DECLARE spropname = vc
     DECLARE sroleprofile = vc
     SET hprop = uar_srvcreateproperty()
     SET tmpstat = uar_secgetclientattributesext(5,hprop)
     SET spropname = uar_srvfirstproperty(hprop)
     SET sroleprofile = uar_srvgetpropertyptr(hprop,nullterm(spropname))
     SELECT INTO "nl:"
      FROM prsnl_org_reltn_type prt,
       prsnl_org_reltn por
      PLAN (prt
       WHERE prt.role_profile=sroleprofile
        AND prt.active_ind=1
        AND prt.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND prt.end_effective_dt_tm > cnvtdatetime(sysdate))
       JOIN (por
       WHERE (por.organization_id= Outerjoin(prt.organization_id))
        AND (por.person_id= Outerjoin(prt.prsnl_id))
        AND (por.active_ind= Outerjoin(1))
        AND (por.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
        AND (por.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
      ORDER BY por.prsnl_org_reltn_id
      DETAIL
       orgcnt = 1, secstat = alterlist(sac_org->organizations,1), user_person_id = prt.prsnl_id,
       sac_org->organizations[1].organization_id = prt.organization_id, sac_org->organizations[1].
       confid_cd = por.confid_level_cd, confid_cd = uar_get_collation_seq(por.confid_level_cd),
       sac_org->organizations[1].confid_level =
       IF (confid_cd > 0) confid_cd
       ELSE 0
       ENDIF
      WITH maxrec = 1
     ;end select
     SET dcur_trustid = sac_org->organizations[1].organization_id
     SET dynamic_org_ind = getdynamicorgpref(dcur_trustid)
     CALL uar_srvdestroyhandle(hprop)
    ENDIF
    IF (dynamic_org_ind=dynorg_disabled)
     SET confid_cnt = 0
     SELECT INTO "NL:"
      c.code_value, c.collation_seq
      FROM code_value c
      WHERE c.code_set=87
      DETAIL
       confid_cnt += 1
       IF (mod(confid_cnt,10)=1)
        secstat = alterlist(confid_codes->list,(confid_cnt+ 9))
       ENDIF
       confid_codes->list[confid_cnt].code_value = c.code_value, confid_codes->list[confid_cnt].
       coll_seq = c.collation_seq
      WITH nocounter
     ;end select
     SET secstat = alterlist(confid_codes->list,confid_cnt)
     SELECT DISTINCT INTO "nl:"
      FROM prsnl_org_reltn por
      WHERE (por.person_id=reqinfo->updt_id)
       AND por.active_ind=1
       AND por.beg_effective_dt_tm < cnvtdatetime(sysdate)
       AND por.end_effective_dt_tm >= cnvtdatetime(sysdate)
      HEAD REPORT
       IF (orgcnt > 0)
        secstat = alterlist(sac_org->organizations,100)
       ENDIF
      DETAIL
       orgcnt += 1
       IF (mod(orgcnt,100)=1)
        secstat = alterlist(sac_org->organizations,(orgcnt+ 99))
       ENDIF
       sac_org->organizations[orgcnt].organization_id = por.organization_id, sac_org->organizations[
       orgcnt].confid_cd = por.confid_level_cd
      FOOT REPORT
       secstat = alterlist(sac_org->organizations,orgcnt)
      WITH nocounter
     ;end select
     SELECT INTO "NL:"
      FROM (dummyt d1  WITH seq = value(orgcnt)),
       (dummyt d2  WITH seq = value(confid_cnt))
      PLAN (d1)
       JOIN (d2
       WHERE (sac_org->organizations[d1.seq].confid_cd=confid_codes->list[d2.seq].code_value))
      DETAIL
       sac_org->organizations[d1.seq].confid_level = confid_codes->list[d2.seq].coll_seq
      WITH nocounter
     ;end select
    ELSEIF (dynamic_org_ind=dynorg_enabled)
     DECLARE nhstrustchild_org_org_reltn_cd = f8
     SET nhstrustchild_org_org_reltn_cd = uar_get_code_by("MEANING",369,"NHSTRUSTCHLD")
     SELECT INTO "nl:"
      FROM org_org_reltn oor
      PLAN (oor
       WHERE oor.organization_id=dcur_trustid
        AND oor.active_ind=1
        AND oor.beg_effective_dt_tm < cnvtdatetime(sysdate)
        AND oor.end_effective_dt_tm >= cnvtdatetime(sysdate)
        AND oor.org_org_reltn_cd=nhstrustchild_org_org_reltn_cd)
      HEAD REPORT
       IF (orgcnt > 0)
        secstat = alterlist(sac_org->organizations,10)
       ENDIF
      DETAIL
       IF (oor.related_org_id > 0)
        orgcnt += 1
        IF (mod(orgcnt,10)=1)
         secstat = alterlist(sac_org->organizations,(orgcnt+ 9))
        ENDIF
        sac_org->organizations[orgcnt].organization_id = oor.related_org_id
       ENDIF
      FOOT REPORT
       secstat = alterlist(sac_org->organizations,orgcnt)
      WITH nocounter
     ;end select
    ELSE
     CALL echo(build("Unexpected login type: ",dynamimc_org_ind))
    ENDIF
   ENDIF
   SET org_cnt = size(sac_org->organizations,5)
   CALL echo(build("org_cnt: ",org_cnt))
   SET stat = alterlist(preg_sec_orgs->qual,(org_cnt+ 1))
   FOR (count = 1 TO org_cnt)
    SET preg_sec_orgs->qual[count].org_id = sac_org->organizations[count].organization_id
    SET preg_sec_orgs->qual[count].confid_level = sac_org->organizations[count].confid_level
   ENDFOR
   SET preg_sec_orgs->qual[(org_cnt+ 1)].org_id = 0.00
   SET preg_sec_orgs->qual[(org_cnt+ 1)].confid_level = 0
 END ;Subroutine
 CALL echo("-----------------------------------------------------------------")
 CALL echo(concat(format(curdate,"dd-mmm-yyyy;;d")," ",format(curtime3,"hh:mm:ss.cc;3;m"),
   " dcp_find_active_preg_logic begins"))
 CALL echo("-----------------------------------------------------------------")
 SET retval = ret_false
 SET preg_param->person_id = event->qual[eks_common->event_repeat_count].person_id
 IF ((preg_param->person_id <= 0.0))
  SET smsg = " The person_id is not valid."
  GO TO end_of_program
 ENDIF
 IF (validate(evaluation)=1)
  SET preg_param->evaluation.value = trim(evaluation)
  IF (size(preg_param->evaluation.value,1) >= 1
   AND (preg_param->evaluation.value IN (p_is, p_is_not)))
   SET preg_param->evaluation.exist_ind = 1
  ENDIF
 ENDIF
 IF ((preg_param->evaluation.exist_ind != 1))
  SET smsg = concat(smsg," Required variable EVALUATION does not exist.")
  GO TO end_of_program
 ENDIF
 IF (validate(opt_ga_operation)=1)
  SET preg_param->opt_ga_operation.value = trim(opt_ga_operation)
  IF (size(preg_param->opt_ga_operation.value,1) >= 1
   AND (preg_param->opt_ga_operation.value IN (p_equal, p_not_equal, p_greater, p_less,
  p_greater_equal,
  p_less_equal, p_between)))
   SET preg_param->opt_ga_operation.exist_ind = 1
  ENDIF
 ENDIF
 IF (validate(opt_ga_value1)=1
  AND isnumeric(opt_ga_value1)=1
  AND cnvtint(opt_ga_value1) >= 0)
  SET preg_param->opt_ga_value1.value = cnvtint(opt_ga_value1)
  SET preg_param->opt_ga_value1.exist_ind = 1
 ENDIF
 IF (validate(opt_ga_value2)=1
  AND isnumeric(opt_ga_value2)=1
  AND cnvtint(opt_ga_value2) >= 0)
  SET preg_param->opt_ga_value2.value = cnvtint(opt_ga_value2)
  SET preg_param->opt_ga_value2.exist_ind = 1
 ENDIF
 IF (validate(opt_ga_units)=1)
  SET preg_param->opt_ga_units.value = trim(opt_ga_units)
  IF (size(preg_param->opt_ga_units.value,1) >= 1
   AND (preg_param->opt_ga_units.value IN (p_days, p_weeks, p_months)))
   SET preg_param->opt_ga_units.exist_ind = 1
  ENDIF
 ENDIF
 IF ((((preg_param->opt_ga_operation.exist_ind != preg_param->opt_ga_value1.exist_ind)) OR ((((
 preg_param->opt_ga_operation.exist_ind != preg_param->opt_ga_units.exist_ind)) OR (((preg_param->
 opt_ga_value2.exist_ind
  AND (((preg_param->opt_ga_operation.exist_ind=0)) OR ((((preg_param->opt_ga_operation.value !=
 p_between)) OR ((((preg_param->opt_ga_value1.exist_ind=0)) OR ((((preg_param->opt_ga_units.exist_ind
 =0)) OR ((preg_param->opt_ga_value1.value > preg_param->opt_ga_value2.value))) )) )) )) ) OR ((
 preg_param->opt_ga_value2.exist_ind=0)
  AND (preg_param->opt_ga_operation.exist_ind=1)
  AND (preg_param->opt_ga_operation.value=p_between))) )) )) )
  SET smsg = "Invalid gestational age criteria."
  GO TO end_of_program
 ELSEIF ((preg_param->opt_ga_operation.exist_ind=1))
  SET sga = concat(preg_param->opt_ga_operation.value," ",build(preg_param->opt_ga_value1.value))
  IF ((preg_param->opt_ga_operation.value=p_between))
   SET sga = concat(sga," and ",build(preg_param->opt_ga_value2.value))
  ENDIF
  SET sga = concat(sga," ",preg_param->opt_ga_units.value)
 ENDIF
 IF ((preg_param->evaluation.value=p_is_not))
  SET preg_param->opt_mother_comp_eval.exist_ind = 0
 ELSE
  IF (validate(opt_mother_comp_eval)=1)
   SET preg_param->opt_mother_comp_eval.value = trim(opt_mother_comp_eval)
   IF (size(preg_param->opt_mother_comp_eval.value,1) >= 1
    AND (preg_param->opt_mother_comp_eval.value IN (p_has, p_does_not_have)))
    SET preg_param->opt_mother_comp_eval.exist_ind = 1
   ENDIF
  ENDIF
  SET orig_param = opt_mother_comp
  EXECUTE eks_t_parse_list  WITH replace(reply,opt_mother_complist)
  FREE SET orig_param
  IF ((opt_mother_complist->cnt > 0))
   IF ((preg_param->opt_mother_comp_eval.exist_ind=0))
    SET smsg = "Invalid OPT_MOTHER_COMP since OPT_MOTHER_COMP_EVAL is not set!"
    GO TO end_of_program
   ENDIF
   SET preg_param->opt_mother_comp.cnt = opt_mother_complist->cnt
   SET stat = alterlist(preg_param->opt_mother_comp.list,opt_mother_complist->cnt)
   FOR (i = 1 TO opt_mother_complist->cnt)
     CALL extractnomenid(dnomenid,opt_mother_complist->qual[i].value)
     SET preg_param->opt_mother_comp.list[i].value = dnomenid
     SET preg_param->opt_mother_comp.list[i].display = opt_mother_complist->qual[i].display
     SET smothercomps = concat(smothercomps,"'",preg_param->opt_mother_comp.list[i].display,"'")
   ENDFOR
  ELSE
   SET preg_param->opt_mother_comp_eval.exist_ind = 0
  ENDIF
 ENDIF
 CALL checkactivepregnancy(null)
 IF (size(preg_data->pregs,5) <= 0)
  IF ((preg_param->evaluation.value=p_is_not))
   SET retval = ret_true
  ELSE
   SET smsg = "Patient is not pregnant!"
  ENDIF
  GO TO end_of_program
 ELSE
  CALL checkega(null)
  CALL checkmothercomps(null)
 ENDIF
 CALL buildmessage(null)
 SET retval = ret_true
 GO TO end_of_program
 SUBROUTINE checkactivepregnancy(null)
   DECLARE preg_idx = i4 WITH protect, noconstant(0)
   SELECT
    IF (preg_org_sec_ind=0)
     FROM pregnancy_instance pi
     WHERE (pi.person_id=preg_param->person_id)
      AND pi.active_ind=1
      AND pi.preg_end_dt_tm=cnvtdatetime("31-DEC-2100")
    ELSE
     FROM pregnancy_instance pi,
      (dummyt d  WITH seq = size(preg_sec_orgs->qual,5))
     PLAN (pi
      WHERE (pi.person_id=preg_param->person_id)
       AND pi.active_ind=1
       AND pi.preg_end_dt_tm=cnvtdatetime("31-DEC-2100"))
      JOIN (d
      WHERE (pi.organization_id=preg_sec_orgs->qual[d.seq].org_id))
    ENDIF
    INTO "nl:"
    HEAD pi.pregnancy_id
     preg_idx += 1
     IF (preg_idx > size(preg_data->pregs,5))
      stat = alterlist(preg_data->pregs,(preg_idx+ 9))
     ENDIF
     preg_data->pregs[preg_idx].pregnancy_id = pi.pregnancy_id, preg_data->pregs[preg_idx].problem_id
      = pi.problem_id
    FOOT  pi.pregnancy_id
     stat = alterlist(preg_data->pregs,preg_idx)
    WITH nocounter
   ;end select
   SET preg_data->preg_cnt = preg_idx
   SET preg_cnt = preg_idx
 END ;Subroutine
 SUBROUTINE checkmothercomps(null)
   IF ((preg_param->opt_mother_comp_eval.exist_ind=0))
    RETURN
   ENDIF
   DECLARE expand_index = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM nomen_entity_reltn ner,
     problem p
    PLAN (ner
     WHERE (ner.person_id=preg_param->person_id)
      AND ner.active_ind=1
      AND ner.reltn_type_cd=reltn_type_cd
      AND ner.reltn_subtype_cd=reltn_subtype_cd
      AND ner.child_entity_name=sproblem
      AND expand(expand_index,1,preg_data->preg_cnt,ner.child_entity_id,preg_data->pregs[expand_index
      ].problem_id)
      AND ner.parent_entity_name=sproblem)
     JOIN (p
     WHERE p.problem_id=ner.parent_entity_id)
    DETAIL
     param_idx = locateval(idx,1,preg_param->opt_mother_comp.cnt,p.nomenclature_id,preg_param->
      opt_mother_comp.list[idx].value), data_idx = locateval(idx,1,preg_data->match_mother_comp_cnt,p
      .nomenclature_id,preg_data->mother_comps[idx].value)
     IF (param_idx > 0
      AND data_idx <= 0)
      preg_data->match_mother_comp_cnt += 1, stat = alterlist(preg_data->mother_comps,preg_data->
       match_mother_comp_cnt), preg_data->mother_comps[preg_data->match_mother_comp_cnt].value = p
      .nomenclature_id,
      preg_data->mother_comps[preg_data->match_mother_comp_cnt].display = preg_param->opt_mother_comp
      .list[param_idx].display
     ENDIF
    WITH nocounter
   ;end select
   IF ((preg_param->opt_mother_comp_eval.value=p_has)
    AND (preg_data->match_mother_comp_cnt < preg_param->opt_mother_comp.cnt))
    SET smsg = concat("Patient doesn't have maternal complications of ",smothercomps)
    GO TO end_of_program
   ELSEIF ((preg_param->opt_mother_comp_eval.value=p_does_not_have)
    AND (preg_data->match_mother_comp_cnt > 0))
    FOR (i = 1 TO preg_data->match_mother_comp_cnt)
      SET stemp = concat(stemp,"'",preg_data->mother_comps[i].display,"'")
    ENDFOR
    SET smsg = concat("Patient has maternal complications of ",stemp)
    GO TO end_of_program
   ENDIF
 END ;Subroutine
 SUBROUTINE checkega(null)
   IF ((preg_param->opt_ga_operation.exist_ind=0))
    IF ((preg_param->evaluation.value=p_is_not))
     SET smsg = "Patient is pregnant!"
     GO TO end_of_program
    ELSE
     RETURN
    ENDIF
   ENDIF
   FREE RECORD ega_request
   RECORD ega_request(
     1 patient_list[*]
       2 patient_id = f8
       2 encntr_id = f8
     1 pregnancy_list[*]
       2 pregnancy_id = f8
     1 multiple_egas = i2
   )
   SET stat = alterlist(ega_request->patient_list,1)
   SET ega_request->patient_list[1].patient_id = preg_param->person_id
   SET ega_request->patient_list[1].encntr = 0
   SET ega_request->multiple_egas = 0
   EXECUTE dcp_get_final_ega  WITH replace(request,ega_request), replace(reply,ega_reply)
   DECLARE ega_cnt = i4 WITH private, noconstant(size(ega_reply->gestation_info,5))
   IF ((((ega_reply->status_data.status="S")) OR ((ega_reply->status_data.status="s")))
    AND size(ega_reply->gestation_info,5) > 0)
    SET preg_data->ga_in_days = ega_reply->gestation_info[ega_cnt].current_gest_age
    IF ((preg_param->opt_ga_units.value=p_days))
     SET ega_in_days_param = preg_param->opt_ga_value1.value
     SET ega_in_days_param2 = preg_param->opt_ga_value2.value
    ELSEIF ((preg_param->opt_ga_units.value=p_weeks))
     SET ega_in_days_param = (preg_param->opt_ga_value1.value * 7)
     SET ega_in_days_param2 = (preg_param->opt_ga_value2.value * 7)
    ELSEIF ((preg_param->opt_ga_units.value=p_months))
     SET ega_in_days_param = (preg_param->opt_ga_value1.value * 30)
     SET ega_in_days_param2 = (preg_param->opt_ga_value2.value * 30)
    ENDIF
    IF ((((preg_param->opt_ga_operation.value=p_equal)
     AND (preg_data->ga_in_days=ega_in_days_param)) OR ((((preg_param->opt_ga_operation.value=
    p_not_equal)
     AND (preg_data->ga_in_days != ega_in_days_param)) OR ((((preg_param->opt_ga_operation.value=
    p_greater)
     AND (preg_data->ga_in_days > ega_in_days_param)) OR ((((preg_param->opt_ga_operation.value=
    p_greater_equal)
     AND (preg_data->ga_in_days >= ega_in_days_param)) OR ((((preg_param->opt_ga_operation.value=
    p_less_equal)
     AND (preg_data->ga_in_days <= ega_in_days_param)) OR ((((preg_param->opt_ga_operation.value=
    p_less)
     AND (preg_data->ga_in_days < ega_in_days_param)) OR ((preg_param->opt_ga_operation.value=
    p_between)
     AND (preg_data->ga_in_days > ega_in_days_param)
     AND (preg_data->ga_in_days <= ega_in_days_param2))) )) )) )) )) )) )
     SET preg_data->match_ga_ind = 1
    ELSE
     SET preg_data->match_ga_ind = 0
    ENDIF
    IF ((((preg_param->evaluation.value=p_is)
     AND (preg_data->match_ga_ind=0)) OR ((preg_param->evaluation.value=p_is_not)
     AND (preg_data->match_ga_ind=1))) )
     IF ((preg_data->match_ga_ind=0))
      SET stemp = p_is_not
     ELSE
      SET stemp = p_is
     ENDIF
     SET smsg = concat("Gestational age is ",build(ega_reply->gestation_info[ega_cnt].
       current_gest_age)," days which ",stemp," ",
      sga,".")
     GO TO end_of_program
    ELSEIF ((preg_param->evaluation.value=p_is_not)
     AND (preg_data->match_ga_ind=0))
     SET smsg = concat("Patient is pregnant with gestional age of ",build(ega_reply->gestation_info[
       ega_cnt].current_gest_age)," days which is not ",sga,".")
    ENDIF
    CALL sethealthqualifydttm(null)
   ELSEIF ((((ega_reply->status_data.status="Z")) OR ((ega_reply->status_data.status="z"))) )
    SET smsg = "Gestational age is not found!"
    GO TO end_of_program
   ELSE
    SET smsg = concat(smsg," Fail to execute dcp_get_final ega.")
    GO TO end_of_program
   ENDIF
 END ;Subroutine
 SUBROUTINE (extractnomenid(nomenid=f8(ref),valuestr=vc) =null)
   DECLARE iposnomen = i4 WITH private, noconstant(0)
   DECLARE nomenstr = vc WITH private, noconstant("")
   SET nomenid = 0
   IF (isnumeric(valuestr))
    SET nomenid = cnvtreal(valuestr)
    RETURN
   ENDIF
   SET iposnomen = findstring("NOMEN:",valuestr,1,0)
   IF (iposnomen > 0)
    SET nomenstr = trim(substring(1,(iposnomen - 1),valuestr))
   ENDIF
   IF (isnumeric(nomenstr))
    SET nomenid = cnvtreal(nomenstr)
   ENDIF
 END ;Subroutine
 SUBROUTINE sethealthqualifydttm(null)
   IF (validate(reply->expectation_series[cur_series_index].qualify_until_dt_tm)=0)
    RETURN
   ENDIF
   IF ((((preg_param->opt_ga_operation.value=p_less)) OR ((((preg_param->opt_ga_operation.value=
   p_less_equal)) OR ((preg_param->opt_ga_operation.value=p_equal))) )) )
    SET max_ega_days = ega_in_days_param
   ELSEIF ((preg_param->opt_ga_operation.value=p_between))
    SET max_ega_days = ega_in_days_param2
   ENDIF
   SET qualify_until_dt_tm = datetimeadd(cnvtdatetime(curdate,235959),(max_ega_days - preg_data->
    ga_in_days))
   CALL echo(build("Last qualifed date time: ",format(qualify_until_dt_tm,";;q")))
   IF ((reply->expectation_series[cur_series_index].qualify_until_dt_tm != null)
    AND (reply->expectation_series[cur_series_index].qualify_until_dt_tm > qualify_until_dt_tm))
    SET reply->expectation_series[cur_series_index].qualify_until_dt_tm = qualify_until_dt_tm
   ENDIF
 END ;Subroutine
 SUBROUTINE buildmessage(null)
   SET smsg = trim(smsg)
   IF (smsg != "")
    RETURN
   ENDIF
   SET smsg = concat("Patient ",preg_param->evaluation.value," pregnant")
   IF (preg_param->opt_ga_operation.exist_ind)
    SET smsg = concat(smsg," with gestational age of ",build(preg_data->ga_in_days)," days which is ",
     sga)
   ENDIF
   IF (preg_param->opt_mother_comp_eval.exist_ind)
    SET smsg = concat(smsg," and ",preg_param->opt_mother_comp_eval.value,
     " maternal complications of ",smothercomps)
   ENDIF
   SET smsg = concat(smsg,".")
 END ;Subroutine
#end_of_program
 SET eksdata->tqual[tcurindex].qual[curindex].cnt = 1
 SET stat = alterlist(eksdata->tqual[tcurindex].qual[curindex].data,1)
 SET eksdata->tqual[tcurindex].qual[curindex].data[1].misc = trim(build(preg_data->pregnancy_id))
 SET eksdata->tqual[tcurindex].qual[curindex].person_id = preg_param->person_id
 SET eksdata->tqual[tcurindex].qual[curindex].logging = smsg
 FREE RECORD ega_reply
 FREE RECORD opt_mother_complist
 FREE RECORD preg_data
 FREE RECORD preg_param
 CALL echo("-----------------------------------------------------------------")
 CALL echo("dcp_find_active_preg_logic ends")
 CALL echo("-----------------------------------------------------------------")
END GO
