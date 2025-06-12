CREATE PROGRAM dcp_get_eligible_trial_plans:dba
 FREE RECORD reply
 RECORD reply(
   1 power_trials[*]
     2 prot_master_id = f8
     2 on_study_dt_tm = dq8
     2 primary_mnemonic = vc
     2 trial_plans[*]
       3 pathway_catalog_id = f8
       3 display_description = vc
       3 pw_evidence_reltn_id = f8
       3 evidence_locator = vc
       3 ref_text_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD temptrials
 RECORD temptrials(
   1 power_trials[*]
     2 prot_master_id = f8
     2 on_study_dt_tm = dq8
     2 primary_mnemonic = vc
 )
 FREE RECORD pathway_list
 RECORD pathway_list(
   1 pathway_list[*]
     2 pathway_catalog_id = f8
     2 trial_idx = i4
     2 plan_idx = i4
 )
 FREE RECORD org_sec_reply
 RECORD org_sec_reply(
   1 orgsecurityflag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE cstatus = c1 WITH protect, noconstant("Z")
 DECLARE userorgstr = vc WITH protect
 DECLARE trialcnt = i4 WITH protect, noconstant(0)
 DECLARE trialsize = i4 WITH protect, noconstant(0)
 DECLARE replycnt = i4 WITH protect, noconstant(0)
 DECLARE replysize = i4 WITH protect, noconstant(0)
 DECLARE plancnt = i4 WITH protect, noconstant(0)
 DECLARE plansize = i4 WITH protect, noconstant(0)
 DECLARE pathwaycnt = i4 WITH protect, noconstant(0)
 DECLARE pathwaysize = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE reftextcnt = i4 WITH protect, noconstant(0)
 DECLARE nincludecnt = i4 WITH protect, noconstant(0)
 DECLARE nexcludecnt = i4 WITH protect, noconstant(0)
 DECLARE nincludeidx = i4 WITH protect, noconstant(0)
 DECLARE nexcludeidx = i4 WITH protect, noconstant(0)
 DECLARE batch_size = i4 WITH protect, constant(20)
 DECLARE prot_master_id = f8 WITH protect, noconstant(0)
 DECLARE on_study_dt_tm = dq8 WITH protect
 DECLARE primary_mnemonic = vc WITH protect
 DECLARE denrolledstatuscd = f8 WITH constant(uar_get_code_by("MEANING",17349,"ENROLLING")), protect
 RECORD user_org_reply(
   1 organizations[*]
     2 organization_id = f8
     2 confid_cd = f8
     2 confid_level = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE userorgsize = i2 WITH protect, noconstant(0)
 DECLARE orgidx = i2 WITH protect, noconstant(0)
 DECLARE orgstr = vc WITH protect
 SUBROUTINE (builduserorglist(tablestr=vc) =vc)
   EXECUTE ct_get_user_orgs  WITH replace("REPLY","USER_ORG_REPLY")
   SET userorgsize = size(user_org_reply->organizations,5)
   IF (userorgsize > 0)
    SET orgstr = build("expand(orgIdx, 1, userOrgSize, ",tablestr,
     ", user_org_reply->organizations[orgIdx]->organization_id)")
   ELSE
    SET orgstr = "1=1"
   ENDIF
   RETURN(orgstr)
 END ;Subroutine
 IF (validate(request->plan_type_include_list[1].pathway_type_cd)=1)
  SET nincludecnt = size(request->plan_type_include_list,5)
 ENDIF
 IF (validate(request->plan_type_exclude_list[1].pathway_type_cd)=1)
  SET nexcludecnt = size(request->plan_type_exclude_list,5)
 ENDIF
 EXECUTE ct_get_org_security  WITH replace("REPLY","ORG_SEC_REPLY")
 IF ((org_sec_reply->orgsecurityflag=1))
  SET userorgstr = builduserorglist("ppr.enrolling_organization_id")
 ELSE
  SET userorgstr = "1=1"
 ENDIF
 SELECT INTO "nl:"
  FROM pt_prot_reg ppr
  WHERE (ppr.person_id=request->person_id)
   AND parser(userorgstr)
   AND ppr.end_effective_dt_tm >= cnvtdatetime(sysdate)
   AND ppr.off_study_dt_tm >= cnvtdatetime(sysdate)
   AND ppr.on_study_dt_tm <= cnvtdatetime(sysdate)
  DETAIL
   trialcnt += 1
   IF (trialcnt > trialsize)
    stat = alterlist(temptrials->power_trials,(trialcnt+ (batch_size - 1))), trialsize += batch_size
   ENDIF
   temptrials->power_trials[trialcnt].prot_master_id = ppr.prot_master_id, temptrials->power_trials[
   trialcnt].on_study_dt_tm = cnvtdatetime(ppr.on_study_dt_tm)
  WITH nocounter
 ;end select
 SET userorgstr = fillstring(1,"")
 IF ((org_sec_reply->orgsecurityflag=1))
  SET userorgstr = builduserorglist("pc.consenting_organization_id")
 ELSE
  SET userorgstr = "1=1"
 ENDIF
 SELECT INTO "nl:"
  FROM pt_consent pc,
   prot_amendment pa
  WHERE (pc.person_id=request->person_id)
   AND pc.reason_for_consent_cd=denrolledstatuscd
   AND parser(userorgstr)
   AND pc.end_effective_dt_tm >= cnvtdatetime(sysdate)
   AND pc.consent_signed_dt_tm >= cnvtdatetime(sysdate)
   AND pc.not_returned_dt_tm >= cnvtdatetime(sysdate)
   AND pc.prot_amendment_id=pa.prot_amendment_id
  DETAIL
   trialcnt += 1
   IF (trialcnt > trialsize)
    stat = alterlist(temptrials->power_trials,(trialcnt+ (batch_size - 1))), trialsize += batch_size
   ENDIF
   temptrials->power_trials[trialcnt].prot_master_id = pa.prot_master_id
  WITH nocounter
 ;end select
 IF (trialcnt > 0)
  SET stat = alterlist(temptrials->power_trials,trialcnt)
 ELSE
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM prot_master pm
  WHERE expand(num,1,trialcnt,pm.prot_master_id,temptrials->power_trials[num].prot_master_id)
  ORDER BY pm.primary_mnemonic
  HEAD pm.prot_master_id
   idx = locateval(num,1,trialcnt,pm.prot_master_id,temptrials->power_trials[num].prot_master_id)
  DETAIL
   IF (idx > 0)
    IF (uar_get_code_meaning(pm.prot_status_cd) != "COMPLETED")
     replycnt += 1
     IF (replycnt > replysize)
      stat = alterlist(reply->power_trials,(replycnt+ (batch_size - 1))), replysize += batch_size
     ENDIF
     reply->power_trials[replycnt].prot_master_id = temptrials->power_trials[idx].prot_master_id,
     reply->power_trials[replycnt].on_study_dt_tm = temptrials->power_trials[idx].on_study_dt_tm,
     reply->power_trials[replycnt].primary_mnemonic = trim(pm.primary_mnemonic)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (replycnt > 0)
  SET stat = alterlist(reply->power_trials,replycnt)
 ELSE
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO replycnt)
   SELECT INTO "nl:"
    FROM pw_pt_reltn ppr,
     pw_cat_flex pcf,
     pathway_catalog pc
    PLAN (ppr
     WHERE (ppr.prot_master_id=reply->power_trials[i].prot_master_id)
      AND ppr.active_ind=1)
     JOIN (pcf
     WHERE pcf.pathway_catalog_id=ppr.pathway_catalog_id
      AND pcf.parent_entity_id IN (0, request->facility_cd)
      AND pcf.parent_entity_name="CODE_VALUE")
     JOIN (pc
     WHERE pc.pathway_catalog_id=pcf.pathway_catalog_id
      AND pc.active_ind=1)
    ORDER BY pc.display_description
    DETAIL
     IF (nexcludecnt > 0)
      nexcludeidx = locateval(num,1,nexcludecnt,pc.pathway_type_cd,request->plan_type_exclude_list[
       num].pathway_type_cd)
     ELSE
      nexcludeidx = 0
     ENDIF
     IF (nincludecnt > 0)
      nincludeidx = locateval(num,1,nincludecnt,pc.pathway_type_cd,request->plan_type_include_list[
       num].pathway_type_cd)
     ELSE
      nincludeidx = 1
     ENDIF
     IF (nexcludeidx=0
      AND nincludeidx > 0)
      dcurdate = cnvtdatetime(sysdate), dbegdate = cnvtdatetime(ppr.beg_effective_dt_tm), denddate =
      cnvtdatetime(ppr.end_effective_dt_tm),
      dlowdate = datetimediff(dcurdate,dbegdate), dhighdate = datetimediff(dcurdate,denddate)
      IF (dlowdate > 0
       AND dhighdate < 0)
       plancnt += 1, pathwaycnt += 1
       IF (plancnt > plansize)
        stat = alterlist(reply->power_trials[i].trial_plans,(plancnt+ (batch_size - 1))), plansize
         += batch_size
       ENDIF
       reply->power_trials[i].trial_plans[plancnt].pathway_catalog_id = ppr.pathway_catalog_id, reply
       ->power_trials[i].trial_plans[plancnt].display_description = pc.display_description
       IF (pathwaycnt > pathwaysize)
        stat = alterlist(pathway_list->pathway_list,(pathwaycnt+ (batch_size - 1))), pathwaysize +=
        batch_size
       ENDIF
       pathway_list->pathway_list[pathwaycnt].pathway_catalog_id = ppr.pathway_catalog_id,
       pathway_list->pathway_list[pathwaycnt].trial_idx = i, pathway_list->pathway_list[pathwaycnt].
       plan_idx = plancnt
      ENDIF
     ENDIF
    FOOT REPORT
     IF (plancnt > 0)
      stat = alterlist(reply->power_trials[i].trial_plans,plancnt)
     ENDIF
     plancnt = 0, plansize = 0
    WITH nocounter
   ;end select
 ENDFOR
 IF (pathwaycnt > 0)
  SET stat = alterlist(pathway_list->pathway_list,pathwaycnt)
 ENDIF
 SELECT INTO "nl:"
  FROM pw_evidence_reltn per
  WHERE expand(num,1,pathwaycnt,per.pathway_catalog_id,pathway_list->pathway_list[num].
   pathway_catalog_id)
  HEAD per.pathway_catalog_id
   idx = locateval(num,1,pathwaycnt,per.pathway_catalog_id,pathway_list->pathway_list[num].
    pathway_catalog_id)
  DETAIL
   IF (idx > 0)
    IF (per.dcp_clin_cat_cd=0
     AND per.dcp_clin_sub_cat_cd=0
     AND per.pathway_comp_id=0)
     IF (per.type_mean="REFTEXT")
      reply->power_trials[pathway_list->pathway_list[idx].trial_idx].trial_plans[pathway_list->
      pathway_list[idx].plan_idx].pw_evidence_reltn_id = per.pw_evidence_reltn_id
     ENDIF
     IF (((per.type_mean="ZYNX") OR (per.type_mean="URL")) )
      reply->power_trials[pathway_list->pathway_list[idx].trial_idx].trial_plans[pathway_list->
      pathway_list[idx].plan_idx].evidence_locator = per.evidence_locator
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM ref_text_reltn rtr
  WHERE rtr.parent_entity_name="PATHWAY_CATALOG"
   AND expand(num,1,pathwaycnt,rtr.parent_entity_id,pathway_list->pathway_list[num].
   pathway_catalog_id)
   AND rtr.active_ind=1
  HEAD rtr.parent_entity_id
   idx = locateval(num,1,pathwaycnt,rtr.parent_entity_id,pathway_list->pathway_list[num].
    pathway_catalog_id)
   IF (idx > 0)
    reply->power_trials[pathway_list->pathway_list[idx].trial_idx].trial_plans[pathway_list->
    pathway_list[idx].plan_idx].ref_text_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SET cstatus = "S"
#exit_script
 SET reply->status_data.status = cstatus
 CALL echorecord(reply)
END GO
