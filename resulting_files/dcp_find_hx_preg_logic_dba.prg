CREATE PROGRAM dcp_find_hx_preg_logic:dba
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
 DECLARE ret_true = i4 WITH protect, constant(100)
 DECLARE ret_false = i4 WITH protect, constant(0)
 DECLARE p_had = vc WITH protect, constant("had")
 DECLARE p_did_not_have = vc WITH protect, constant("did not have")
 DECLARE labor_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002124,"PRETERMLABOR"))
 DECLARE mother_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002124,"MOTHERCOMP"))
 DECLARE fetal_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002124,"FETUSCOMP"))
 DECLARE neonate_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002124,"NEWBORNCOMP")
  )
 DECLARE smsg = vc WITH protect, noconstant(" ")
 DECLARE sparam = vc WITH protect, noconstant(" ")
 DECLARE dnomenid = f8 WITH protect, noconstant(0)
 DECLARE batch_size = i4 WITH public, noconstant(20)
 DECLARE cur_list_size = i4 WITH public, noconstant(0)
 DECLARE loop_cnt = i4 WITH public, noconstant(0)
 DECLARE new_list_size = i4 WITH public, noconstant(0)
 DECLARE nstart = i4 WITH public, noconstant(1)
 DECLARE stat = i4 WITH public, noconstant(0)
 DECLARE preg_cnt = i4 WITH protect, noconstant(0)
 DECLARE soutcomes = vc WITH protect, noconstant(" ")
 DECLARE slabors = vc WITH protect, noconstant(" ")
 DECLARE smothercomps = vc WITH protect, noconstant(" ")
 DECLARE sfetalcomps = vc WITH protect, noconstant(" ")
 DECLARE sneonatecomps = vc WITH protect, noconstant(" ")
 DECLARE cidx = i4 WITH protect, noconstant(0)
 DECLARE pidx = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE child_cnt = i4 WITH protect, noconstant(0)
 DECLARE pid = i4 WITH protect, noconstant(0)
 DECLARE cid = i4 WITH protect, noconstant(0)
 DECLARE param_idx = i4 WITH protect, noconstant(0)
 DECLARE data_idx = i4 WITH protect, noconstant(0)
 DECLARE boptparam = i2 WITH protect, noconstant(0)
 DECLARE checkpregoutcome(null) = null
 DECLARE checkchildcomponents(null) = null
 DECLARE evaluatepretermlabors(null) = null
 DECLARE evaluatemothercomps(null) = null
 DECLARE evaluatefetalcomps(null) = null
 DECLARE evaluateneonatecomps(null) = null
 DECLARE evaluateall(null) = null
 DECLARE buildmessage(null) = null
 FREE RECORD phx_param
 RECORD phx_param(
   1 person_id = f8
   1 evaluation
     2 value = vc
     2 exist_ind = i2
   1 opt_outcome_eval
     2 value = vc
     2 exist_ind = i2
   1 opt_outcome
     2 cnt = i4
     2 list[*]
       3 display = vc
       3 value = f8
   1 opt_labor_eval
     2 value = vc
     2 exist_ind = i2
   1 opt_labor
     2 cnt = i4
     2 list[*]
       3 display = vc
       3 value = f8
   1 opt_mother_comp_eval
     2 value = vc
     2 exist_ind = i2
   1 opt_mother_comp
     2 cnt = i4
     2 list[*]
       3 display = vc
       3 value = f8
   1 opt_fetal_comp_eval
     2 value = vc
     2 exist_ind = i2
   1 opt_fetal_comp
     2 cnt = i4
     2 list[*]
       3 display = vc
       3 value = f8
   1 opt_neonate_comp_eval
     2 value = vc
     2 exist_ind = i2
   1 opt_neonate_comp
     2 cnt = i4
     2 list[*]
       3 display = vc
       3 value = f8
 )
 FREE RECORD opt_laborlist
 RECORD opt_laborlist(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
 )
 FREE RECORD opt_outcomelist
 RECORD opt_outcomelist(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
 )
 FREE RECORD opt_mother_complist
 RECORD opt_mother_complist(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
 )
 FREE RECORD opt_fetal_complist
 RECORD opt_fetal_complist(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
 )
 FREE RECORD opt_neonate_complist
 RECORD opt_neonate_complist(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
 )
 FREE RECORD phx_data
 RECORD phx_data(
   1 preg_match_cnt = i4
   1 pregnancies[*]
     2 match_ind = i2
     2 pregnancy_id = f8
     2 child_cnt = i4
     2 outcome_match_cnt = i4
     2 labor_match_cnt = i4
     2 mother_comp_match_cnt = i4
     2 fetal_comp_match_cnt = i4
     2 neonate_comp_match_cnt = i4
     2 children[*]
       3 child_id = f8
     2 outcomes[*]
       3 value = f8
     2 labors[*]
       3 value = f8
     2 mother_comps[*]
       3 value = f8
     2 fetal_comps[*]
       3 value = f8
     2 neonate_comps[*]
       3 value = f8
 )
 FREE RECORD children_data
 RECORD children_data(
   1 children[*]
     2 child_id = f8
     2 pregnancy_id = f8
 )
 CALL echo("--------------------------------------------------------------------")
 CALL echo(concat(format(curdate,"dd-mmm-yyyy;;d")," ",format(curtime3,"hh:mm:ss.cc;3;m"),
   " BEGIN OF DCP_FIND_HX_PREG_LOGIC"))
 CALL echo("--------------------------------------------------------------------")
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
 SET retval = ret_false
 SET phx_param->person_id = event->qual[eks_common->event_repeat_count].person_id
 IF ((phx_param->person_id <= 0.0))
  SET smsg = "The person_id is not valid."
  GO TO end_of_program
 ENDIF
 IF (validate(evaluation)=1)
  SET phx_param->evaluation.value = trim(evaluation)
  IF (size(phx_param->evaluation.value,1) >= 1
   AND (phx_param->evaluation.value IN (p_had, p_did_not_have)))
   SET phx_param->evaluation.exist_ind = 1
  ENDIF
 ENDIF
 IF ((phx_param->evaluation.exist_ind != 1))
  SET smsg = "Required variable EVALUATION does not exist."
  GO TO end_of_program
 ENDIF
 IF (validate(opt_outcome_eval)=1)
  SET phx_param->opt_outcome_eval.value = trim(opt_outcome_eval)
  IF (size(phx_param->opt_outcome_eval.value,1) >= 1
   AND (phx_param->opt_outcome_eval.value IN (p_had, p_did_not_have)))
   SET phx_param->opt_outcome_eval.exist_ind = 1
  ENDIF
 ENDIF
 SET orig_param = opt_outcome
 EXECUTE eks_t_parse_list  WITH replace(reply,opt_outcomelist)
 FREE SET orig_param
 IF ((opt_outcomelist->cnt > 0))
  IF ((phx_param->opt_outcome_eval.exist_ind != 1))
   SET smsg = "OPT_OUTCOME is invalid since OPT_OUTCOME_EVAL does not exist!"
   GO TO end_of_program
  ENDIF
  SET stat = alterlist(phx_param->opt_outcome.list,opt_outcomelist->cnt)
  SET phx_param->opt_outcome.cnt = opt_outcomelist->cnt
  FOR (i = 1 TO opt_outcomelist->cnt)
    SET phx_param->opt_outcome.list[i].display = opt_outcomelist->qual[i].display
    SET phx_param->opt_outcome.list[i].value = cnvtreal(opt_outcomelist->qual[i].value)
    SET soutcomes = concat(soutcomes,"'",opt_outcomelist->qual[i].display,"' ")
  ENDFOR
  IF (boptparam=1)
   SET sparam = concat(sparam," and ")
  ENDIF
  SET sparam = concat(sparam," ",phx_param->opt_outcome_eval.value," outcome of ",soutcomes)
  SET boptparam = 1
 ELSE
  SET phx_param->opt_outcome_eval.exist_ind = 0
 ENDIF
 IF (validate(opt_labor_eval)=1)
  SET phx_param->opt_labor_eval.value = trim(opt_labor_eval)
  IF (size(phx_param->opt_labor_eval.value,1) >= 1
   AND (phx_param->opt_labor_eval.value IN (p_had, p_did_not_have)))
   SET phx_param->opt_labor_eval.exist_ind = 1
  ENDIF
 ENDIF
 SET orig_param = opt_labor
 EXECUTE eks_t_parse_list  WITH replace(reply,opt_laborlist)
 FREE SET orig_param
 IF ((opt_laborlist->cnt > 0))
  IF ((phx_param->opt_labor_eval.exist_ind != 1))
   SET smsg = "OPT_LABOR is invalid since OPT_LABOR_EVAL does not exist!"
   GO TO end_of_program
  ENDIF
  SET stat = alterlist(phx_param->opt_labor.list,opt_laborlist->cnt)
  SET phx_param->opt_labor.cnt = opt_laborlist->cnt
  FOR (i = 1 TO opt_laborlist->cnt)
    SET phx_param->opt_labor.list[i].display = opt_laborlist->qual[i].display
    SET phx_param->opt_labor.list[i].value = cnvtreal(opt_laborlist->qual[i].value)
    SET slabors = concat(slabors,"'",opt_laborlist->qual[i].display,"' ")
  ENDFOR
  IF (boptparam=1)
   SET sparam = concat(sparam," and ")
  ENDIF
  SET sparam = concat(sparam," ",phx_param->opt_labor_eval.value," preterm labor of ",slabors)
  SET boptparam = 1
 ELSE
  SET phx_param->opt_labor_eval.exist_ind = 0
 ENDIF
 IF (validate(opt_mother_comp_eval)=1)
  SET phx_param->opt_mother_comp_eval.value = trim(opt_mother_comp_eval)
  IF (size(phx_param->opt_mother_comp_eval.value,1) >= 1
   AND (phx_param->opt_mother_comp_eval.value IN (p_had, p_did_not_have)))
   SET phx_param->opt_mother_comp_eval.exist_ind = 1
  ENDIF
 ENDIF
 SET orig_param = opt_mother_comp
 EXECUTE eks_t_parse_list  WITH replace(reply,opt_mother_complist)
 FREE SET orig_param
 IF ((opt_mother_complist->cnt > 0))
  IF ((phx_param->opt_mother_comp_eval.exist_ind != 1))
   SET smsg = "Invalid OPT_MOTHER_COMP since OPT_MOTHER_COMP_EVAL is not set!"
   GO TO end_of_program
  ENDIF
  SET stat = alterlist(phx_param->opt_mother_comp.list,opt_mother_complist->cnt)
  SET phx_param->opt_mother_comp.cnt = opt_mother_complist->cnt
  FOR (i = 1 TO opt_mother_complist->cnt)
    CALL extractnomenid(dnomenid,opt_mother_complist->qual[i].value)
    SET phx_param->opt_mother_comp.list[i].value = dnomenid
    SET smothercomps = concat(smothercomps,"'",opt_mother_complist->qual[i].display,"' ")
  ENDFOR
  IF (boptparam=1)
   SET sparam = concat(sparam," and ")
  ENDIF
  SET sparam = concat(sparam," ",phx_param->opt_mother_comp_eval.value," maternal complications of ",
   smothercomps)
  SET boptparam = 1
 ELSE
  SET phx_param->opt_mother_comp_eval.exist_ind = 0
 ENDIF
 IF (validate(opt_fetal_comp_eval)=1)
  SET phx_param->opt_fetal_comp_eval.value = trim(opt_fetal_comp_eval)
  IF (size(phx_param->opt_fetal_comp_eval.value,1) >= 1
   AND (phx_param->opt_fetal_comp_eval.value IN (p_had, p_did_not_have)))
   SET phx_param->opt_fetal_comp_eval.exist_ind = 1
  ENDIF
 ENDIF
 SET orig_param = opt_fetal_comp
 EXECUTE eks_t_parse_list  WITH replace(reply,opt_fetal_complist)
 FREE SET orig_param
 IF ((opt_fetal_complist->cnt > 0))
  IF ((phx_param->opt_fetal_comp_eval.exist_ind != 1))
   SET smsg = "Invalid OPT_FETAL_COMP since OPT_FETAL_COMP_EVAL is not set!"
   GO TO end_of_program
  ENDIF
  SET stat = alterlist(phx_param->opt_fetal_comp.list,opt_fetal_complist->cnt)
  SET phx_param->opt_fetal_comp.cnt = opt_fetal_complist->cnt
  FOR (i = 1 TO opt_fetal_complist->cnt)
    CALL extractnomenid(dnomenid,opt_fetal_complist->qual[i].value)
    SET phx_param->opt_fetal_comp.list[i].value = dnomenid
    SET sfetalcomps = concat(sfetalcomps,"'",opt_fetal_complist->qual[i].display,"' ")
  ENDFOR
  IF (boptparam=1)
   SET sparam = concat(sparam," and ")
  ENDIF
  SET sparam = concat(sparam," ",phx_param->opt_fetal_comp_eval.value," fetal complications of ",
   sfetalcomps)
  SET boptparam = 1
 ELSE
  SET phx_param->opt_fetal_comp_eval.exist_ind = 0
 ENDIF
 IF (validate(opt_neonate_comp_eval)=1)
  SET phx_param->opt_neonate_comp_eval.value = trim(opt_neonate_comp_eval)
  IF (size(phx_param->opt_neonate_comp_eval.value,1) >= 1
   AND (phx_param->opt_neonate_comp_eval.value IN (p_had, p_did_not_have)))
   SET phx_param->opt_neonate_comp_eval.exist_ind = 1
  ENDIF
 ENDIF
 SET orig_param = opt_neonate_comp
 EXECUTE eks_t_parse_list  WITH replace(reply,opt_neonate_complist)
 FREE SET orig_param
 IF ((opt_neonate_complist->cnt > 0))
  IF ((phx_param->opt_neonate_comp_eval.exist_ind != 1))
   SET smsg = "Invalid OPT_NEONATE_COMP since OPT_NEONATE_COMP_EVAL is not set!"
   GO TO end_of_program
  ENDIF
  SET stat = alterlist(phx_param->opt_neonate_comp.list,opt_neonate_complist->cnt)
  SET phx_param->opt_neonate_comp.cnt = opt_neonate_complist->cnt
  FOR (i = 1 TO opt_neonate_complist->cnt)
    CALL extractnomenid(dnomenid,opt_neonate_complist->qual[i].value)
    SET phx_param->opt_neonate_comp.list[i].value = dnomenid
    SET sneonatecomps = concat(sneonatecomps,"'",opt_neonate_complist->qual[i].display,"' ")
  ENDFOR
  IF (boptparam=1)
   SET sparam = concat(sparam," and ")
  ENDIF
  SET sparam = concat(sparam," ",phx_param->opt_neonate_comp_eval.value," neonatal complications of ",
   sneonatecomps)
  SET boptparam = 1
 ELSE
  SET phx_param->opt_neonate_comp_eval.exist_ind = 0
 ENDIF
 CALL checkpregoutcome(null)
 CALL checkchildcomponents(null)
 CALL evaluateall(null)
 GO TO end_of_program
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
 SUBROUTINE checkpregoutcome(null)
   SELECT
    IF (preg_org_sec_ind=0)
     FROM pregnancy_instance pi,
      pregnancy_child pc
     PLAN (pi
      WHERE (pi.person_id=phx_param->person_id)
       AND pi.active_ind=1
       AND pi.preg_start_dt_tm != null
       AND pi.preg_end_dt_tm != null
       AND pi.preg_end_dt_tm < cnvtdatetime("31-DEC-2100"))
      JOIN (pc
      WHERE pc.pregnancy_id=pi.pregnancy_id
       AND pc.active_ind=1)
    ELSE
     FROM pregnancy_instance pi,
      pregnancy_child pc,
      (dummyt d  WITH seq = size(preg_sec_orgs->qual,5))
     PLAN (pi
      WHERE (pi.person_id=phx_param->person_id)
       AND pi.active_ind=1
       AND pi.preg_start_dt_tm != null
       AND pi.preg_end_dt_tm != null
       AND pi.preg_end_dt_tm < cnvtdatetime("31-DEC-2100"))
      JOIN (pc
      WHERE pc.pregnancy_id=pi.pregnancy_id
       AND pc.active_ind=1)
      JOIN (d
      WHERE (pi.organization_id=preg_sec_orgs->qual[d.seq].org_id))
    ENDIF
    INTO "nl:"
    ORDER BY pi.pregnancy_id
    HEAD REPORT
     preg_cnt = 0
    HEAD pi.pregnancy_id
     preg_cnt += 1
     IF (mod(preg_cnt,5)=1)
      stat = alterlist(phx_data->pregnancies,(preg_cnt+ 4))
     ENDIF
     phx_data->pregnancies[preg_cnt].match_ind = 0, phx_data->pregnancies[preg_cnt].pregnancy_id = pi
     .pregnancy_id, ccnt = 0
    DETAIL
     ccnt += 1
     IF (mod(ccnt,5)=1)
      stat = alterlist(phx_data->pregnancies[preg_cnt].children,(ccnt+ 4))
     ENDIF
     phx_data->pregnancies[preg_cnt].children[ccnt].child_id = pc.pregnancy_child_id
     IF ((phx_param->opt_outcome_eval.exist_ind=1)
      AND locateval(idx,1,phx_param->opt_outcome.cnt,pc.delivery_method_cd,phx_param->opt_outcome.
      list[idx].value) > 0
      AND locateval(idx,1,phx_data->pregnancies[preg_cnt].outcome_match_cnt,pc.delivery_method_cd,
      phx_data->pregnancies[preg_cnt].outcomes[idx].value) <= 0)
      phx_data->pregnancies[preg_cnt].outcome_match_cnt += 1, stat = alterlist(phx_data->pregnancies[
       preg_cnt].outcomes,phx_data->pregnancies[preg_cnt].outcome_match_cnt), phx_data->pregnancies[
      preg_cnt].outcomes[phx_data->pregnancies[preg_cnt].outcome_match_cnt].value = pc
      .delivery_method_cd
     ENDIF
    FOOT  pi.pregnancy_id
     stat = alterlist(phx_data->pregnancies[preg_cnt].children,ccnt)
     IF ((((phx_param->opt_outcome_eval.exist_ind=1)
      AND (((phx_param->opt_outcome_eval.value=p_had)
      AND (phx_data->pregnancies[preg_cnt].outcome_match_cnt=phx_param->opt_outcome.cnt)) OR ((
     phx_param->opt_outcome_eval.value=p_did_not_have)
      AND (phx_data->pregnancies[preg_cnt].outcome_match_cnt=0))) ) OR ((phx_param->opt_outcome_eval.
     exist_ind=0))) )
      phx_data->pregnancies[preg_cnt].match_ind = 1, phx_data->preg_match_cnt += 1
     ENDIF
    FOOT REPORT
     stat = alterlist(phx_data->pregnancies,preg_cnt)
    WITH nocounter
   ;end select
   IF (preg_cnt=0)
    IF ((phx_param->evaluation.value=p_had))
     SET smsg = "Patient didn't have any historical pregnancy."
    ELSE
     SET retval = ret_true
    ENDIF
    GO TO end_of_program
   ENDIF
   IF ((phx_data->preg_match_cnt=0))
    IF ((phx_param->evaluation.value=p_had))
     SET smsg = concat("Patient didn't have any historical pregnancy that ",phx_param->
      opt_outcome_eval.value," outcome of ",soutcomes,".")
    ELSE
     SET retval = ret_true
    ENDIF
    GO TO end_of_program
   ENDIF
 END ;Subroutine
 SUBROUTINE checkchildcomponents(null)
   IF ((phx_param->opt_labor_eval.exist_ind=0)
    AND (phx_param->opt_fetal_comp_eval.exist_ind=0)
    AND (phx_param->opt_mother_comp_eval.exist_ind=0)
    AND (phx_param->opt_neonate_comp_eval.exist_ind=0))
    RETURN
   ENDIF
   SET cidx = 0
   FOR (pid = 1 TO preg_cnt)
     IF ((phx_data->pregnancies[pid].match_ind=1))
      SET child_cnt = size(phx_data->pregnancies[pid].children,5)
      SET stat = alterlist(children_data->children,(cidx+ child_cnt))
      FOR (cid = 1 TO child_cnt)
        SET cidx += 1
        SET children_data->children[cidx].child_id = phx_data->pregnancies[pid].children[cid].
        child_id
        SET children_data->children[cidx].pregnancy_id = phx_data->pregnancies[pid].pregnancy_id
      ENDFOR
     ENDIF
   ENDFOR
   SET cur_list_size = cidx
   SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
   SET new_list_size = (loop_cnt * batch_size)
   SET stat = alterlist(children_data->children,new_list_size)
   FOR (cidx = (cur_list_size+ 1) TO new_list_size)
    SET children_data->children[cidx].child_id = children_data->children[cur_list_size].child_id
    SET children_data->children[cidx].pregnancy_id = children_data->children[cur_list_size].
    pregnancy_id
   ENDFOR
   SET cid = 0
   SELECT INTO "nl:"
    FROM (dummyt dpc  WITH seq = value(loop_cnt)),
     pregnancy_child_entity_r pcer
    PLAN (dpc
     WHERE initarray(nstart,evaluate(dpc.seq,1,1,(nstart+ batch_size))))
     JOIN (pcer
     WHERE expand(cid,nstart,(nstart+ (batch_size - 1)),pcer.pregnancy_child_id,children_data->
      children[cid].child_id)
      AND pcer.active_ind=1)
    ORDER BY pcer.pregnancy_child_id
    HEAD pcer.pregnancy_child_id
     cidx = locateval(idx,1,cur_list_size,pcer.pregnancy_child_id,children_data->children[idx].
      child_id), pidx = locateval(idx,1,preg_cnt,children_data->children[cidx].pregnancy_id,phx_data
      ->pregnancies[idx].pregnancy_id)
    DETAIL
     IF (pcer.component_type_cd=labor_comp_cd
      AND (phx_param->opt_labor_eval.exist_ind=1))
      IF (locateval(idx,1,phx_param->opt_labor.cnt,pcer.parent_entity_id,phx_param->opt_labor.list[
       idx].value) > 0
       AND locateval(idx,1,phx_data->pregnancies[pidx].labor_match_cnt,pcer.parent_entity_id,phx_data
       ->pregnancies[pidx].labors[idx].value) <= 0)
       phx_data->pregnancies[pidx].labor_match_cnt += 1, stat = alterlist(phx_data->pregnancies[pidx]
        .labors,phx_data->pregnancies[pidx].labor_match_cnt), phx_data->pregnancies[pidx].labors[
       phx_data->pregnancies[pidx].labor_match_cnt].value = pcer.parent_entity_id
      ENDIF
     ELSEIF (pcer.component_type_cd=mother_comp_cd
      AND (phx_param->opt_mother_comp_eval.exist_ind=1))
      IF (locateval(idx,1,phx_param->opt_mother_comp.cnt,pcer.parent_entity_id,phx_param->
       opt_mother_comp.list[idx].value) > 0
       AND locateval(idx,1,phx_data->pregnancies[pidx].mother_comp_match_cnt,pcer.parent_entity_id,
       phx_data->pregnancies[pidx].mother_comps[idx].value) <= 0)
       phx_data->pregnancies[pidx].mother_comp_match_cnt += 1, stat = alterlist(phx_data->
        pregnancies[pidx].mother_comps,phx_data->pregnancies[pidx].mother_comp_match_cnt), phx_data->
       pregnancies[pidx].mother_comps[phx_data->pregnancies[pidx].mother_comp_match_cnt].value = pcer
       .parent_entity_id
      ENDIF
     ELSEIF (pcer.component_type_cd=fetal_comp_cd
      AND (phx_param->opt_fetal_comp_eval.exist_ind=1))
      IF (locateval(idx,1,phx_param->opt_fetal_comp.cnt,pcer.parent_entity_id,phx_param->
       opt_fetal_comp.list[idx].value) > 0
       AND locateval(idx,1,phx_data->pregnancies[pidx].fetal_comp_match_cnt,pcer.parent_entity_id,
       phx_data->pregnancies[pidx].fetal_comps[idx].value) <= 0)
       phx_data->pregnancies[pidx].fetal_comp_match_cnt += 1, stat = alterlist(phx_data->pregnancies[
        pidx].fetal_comps,phx_data->pregnancies[pidx].fetal_comp_match_cnt), phx_data->pregnancies[
       pidx].fetal_comps[phx_data->pregnancies[pidx].fetal_comp_match_cnt].value = pcer
       .parent_entity_id
      ENDIF
     ELSEIF (pcer.component_type_cd=neonate_comp_cd
      AND (phx_param->opt_neonate_comp_eval.exist_ind=1))
      IF (locateval(idx,1,phx_param->opt_neonate_comp.cnt,pcer.parent_entity_id,phx_param->
       opt_neonate_comp.list[idx].value) > 0
       AND locateval(idx,1,phx_data->pregnancies[pidx].neonate_comp_match_cnt,pcer.parent_entity_id,
       phx_data->pregnancies[pidx].neonate_comps[idx].value) <= 0)
       phx_data->pregnancies[pidx].neonate_comp_match_cnt += 1, stat = alterlist(phx_data->
        pregnancies[pidx].neonate_comps,phx_data->pregnancies[pidx].neonate_comp_match_cnt), phx_data
       ->pregnancies[pidx].neonate_comps[phx_data->pregnancies[pidx].neonate_comp_match_cnt].value =
       pcer.parent_entity_id
      ENDIF
     ENDIF
    FOOT  pcer.pregnancy_child_id
     pidx = 0
    WITH nocounter
   ;end select
   CALL evaluatepretermlabors(null)
   CALL evaluatemothercomps(null)
   CALL evaluatefetalcomps(null)
   CALL evaluateneonatecomps(null)
 END ;Subroutine
 SUBROUTINE evaluatepretermlabors(null)
   IF ((phx_param->opt_labor_eval.exist_ind=0))
    RETURN
   ENDIF
   SET phx_data->preg_match_cnt = 0
   FOR (pid = 1 TO preg_cnt)
     IF ((phx_data->pregnancies[pid].match_ind=1))
      IF ((((phx_param->opt_labor_eval.value=p_had)
       AND (phx_data->pregnancies[pid].labor_match_cnt < opt_laborlist->cnt)) OR ((phx_param->
      opt_labor_eval.value=p_did_not_have)
       AND (phx_data->pregnancies[pid].labor_match_cnt > 0))) )
       SET phx_data->pregnancies[pid].match_ind = 0
      ELSE
       SET phx_data->preg_match_cnt += 1
      ENDIF
     ENDIF
   ENDFOR
   IF ((phx_data->preg_match_cnt=0))
    IF ((phx_param->evaluation.value=p_did_not_have))
     SET retval = ret_true
    ENDIF
    GO TO end_of_program
   ENDIF
 END ;Subroutine
 SUBROUTINE evaluatemothercomps(null)
   IF ((phx_param->opt_mother_comp_eval.exist_ind=0))
    RETURN
   ENDIF
   SET phx_data->preg_match_cnt = 0
   FOR (pid = 1 TO preg_cnt)
     IF ((phx_data->pregnancies[pid].match_ind=1))
      IF ((((phx_param->opt_mother_comp_eval.value=p_had)
       AND (phx_data->pregnancies[pid].mother_comp_match_cnt < phx_param->opt_mother_comp.cnt)) OR ((
      phx_param->opt_mother_comp_eval.value=p_did_not_have)
       AND (phx_data->pregnancies[pid].mother_comp_match_cnt > 0))) )
       SET phx_data->pregnancies[pid].match_ind = 0
      ELSE
       SET phx_data->preg_match_cnt += 1
      ENDIF
     ENDIF
   ENDFOR
   IF ((phx_data->preg_match_cnt=0))
    IF ((phx_param->evaluation.value=p_did_not_have))
     SET retval = ret_true
    ENDIF
    GO TO end_of_program
   ENDIF
 END ;Subroutine
 SUBROUTINE evaluatefetalcomps(null)
   IF ((phx_param->opt_fetal_comp_eval.exist_ind=0))
    RETURN
   ENDIF
   SET phx_data->preg_match_cnt = 0
   FOR (pid = 1 TO preg_cnt)
     IF ((phx_data->pregnancies[pid].match_ind=1))
      IF ((((phx_param->opt_fetal_comp_eval.value=p_had)
       AND (phx_data->pregnancies[pid].fetal_comp_match_cnt < phx_param->opt_fetal_comp.cnt)) OR ((
      phx_param->opt_fetal_comp_eval.value=p_did_not_have)
       AND (phx_data->pregnancies[pid].fetal_comp_match_cnt > 0))) )
       SET phx_data->pregnancies[pid].match_ind = 0
      ELSE
       SET phx_data->preg_match_cnt += 1
      ENDIF
     ENDIF
   ENDFOR
   IF ((phx_data->preg_match_cnt=0))
    IF ((phx_param->evaluation.value=p_did_not_have))
     SET retval = ret_true
    ENDIF
    GO TO end_of_program
   ENDIF
 END ;Subroutine
 SUBROUTINE evaluateneonatecomps(null)
   IF ((phx_param->opt_neonate_comp_eval.exist_ind=0))
    RETURN
   ENDIF
   SET phx_data->preg_match_cnt = 0
   FOR (pid = 1 TO preg_cnt)
     IF ((phx_data->pregnancies[pid].match_ind=1))
      IF ((((phx_param->opt_neonate_comp_eval.value=p_had)
       AND (phx_data->pregnancies[pid].neonate_comp_match_cnt < phx_param->opt_neonate_comp.cnt)) OR
      ((phx_param->opt_neonate_comp_eval.value=p_did_not_have)
       AND (phx_data->pregnancies[pid].neonate_comp_match_cnt > 0))) )
       SET phx_data->pregnancies[pid].match_ind = 0
      ELSE
       SET phx_data->preg_match_cnt += 1
      ENDIF
     ENDIF
   ENDFOR
   IF ((phx_data->preg_match_cnt=0))
    IF ((phx_param->evaluation.value=p_did_not_have))
     SET retval = ret_true
    ENDIF
    GO TO end_of_program
   ENDIF
 END ;Subroutine
 SUBROUTINE evaluateall(null)
   IF ((((phx_data->preg_match_cnt > 0)
    AND (phx_param->evaluation.value=p_had)) OR ((phx_data->preg_match_cnt=0)
    AND (phx_param->evaluation.value=p_did_not_have))) )
    SET retval = ret_true
   ENDIF
 END ;Subroutine
 SUBROUTINE buildmessage(null)
   SET smsg = trim(smsg)
   IF (smsg != "")
    RETURN
   ENDIF
   IF ((phx_data->preg_match_cnt=1))
    SET spreg = "pregnancy"
   ELSE
    SET spreg = "pregnancies"
   ENDIF
   SET smsg = concat("Patient had ",build(phx_data->preg_match_cnt)," historical ",spreg)
   IF (boptparam)
    SET sparam = concat(" that ",sparam,".")
   ELSE
    SET sparam = "."
   ENDIF
   SET smsg = concat(smsg,sparam)
 END ;Subroutine
#end_of_program
 CALL buildmessage(null)
 SET eksdata->tqual[tcurindex].qual[curindex].cnt = 1
 SET stat = alterlist(eksdata->tqual[tcurindex].qual[curindex].data,1)
 SET eksdata->tqual[tcurindex].qual[curindex].data[1].misc = trim(build(phx_data->preg_match_cnt))
 SET eksdata->tqual[tcurindex].qual[curindex].person_id = phx_param->person_id
 SET eksdata->tqual[tcurindex].qual[curindex].logging = smsg
 CALL echorecord(phx_data)
 CALL echorecord(phx_param)
 CALL echorecord(children_data)
 FREE RECORD phx_data
 FREE RECORD phx_param
 FREE RECORD children_data
 FREE RECORD opt_laborlist
 FREE RECORD opt_fetal_complist
 FREE RECORD opt_mother_complist
 FREE RECORD opt_neonate_complist
 FREE RECORD opt_outcomelist
 CALL echo("------------------------------------------------------------")
 CALL echo("************** END OF DCP_FIND_HX_PREG_LOGIC ***************")
 CALL echo("------------------------------------------------------------")
END GO
