CREATE PROGRAM dcp_get_trial_plan_validation:dba
 FREE RECORD reply
 RECORD reply(
   1 trial_plan_info[*]
     2 prot_master_id = f8
     2 primary_mnemonic = vc
     2 trial_status_flag = i2
     2 organization_id = f8
     2 minimum_enrollment_status_flag = i2
     2 ordering_policy_flag = i2
     2 require_override_reason_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
 DECLARE cretstatus = c1 WITH protect, noconstant("Z")
 DECLARE ifound = i4 WITH protect, noconstant(0)
 DECLARE dcurdate = dq8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE dbegdate = dq8
 DECLARE denddate = dq8
 DECLARE lowdatediff = f8 WITH noconstant(0.0), protect
 DECLARE highdatediff = f8 WITH noconstant(0.0), protect
 DECLARE suserorgs = vc WITH protect
 DECLARE icnt = i4 WITH protect, noconstant(0)
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
 SELECT INTO "n1:"
  FROM pw_pt_reltn ppr
  WHERE (ppr.pathway_catalog_id=request->pathway_catalog_id)
   AND ppr.active_ind=1
  ORDER BY ppr.end_effective_dt_tm DESC
  DETAIL
   dbegdate = cnvtdatetime(ppr.beg_effective_dt_tm), denddate = cnvtdatetime(ppr.end_effective_dt_tm),
   lowdatediff = datetimediff(dcurdate,dbegdate),
   highdatediff = datetimediff(dcurdate,denddate)
   IF (lowdatediff > 0.0
    AND highdatediff < 0.0)
    IF (ppr.minimum_enrollment_status_flag != 0)
     stat = alterlist(reply->trial_plan_info,1), reply->trial_plan_info[1].prot_master_id = ppr
     .prot_master_id, reply->trial_plan_info[1].minimum_enrollment_status_flag = ppr
     .minimum_enrollment_status_flag,
     reply->trial_plan_info[1].ordering_policy_flag = ppr.ordering_policy_flag, reply->
     trial_plan_info[1].require_override_reason_flag = ppr.require_override_reason_ind,
     CALL echo(ifound),
     ifound = 1,
     CALL cancel(1)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (((ifound=0) OR (ifound > 1)) )
  GO TO exit_script
 ENDIF
 SET reply->trial_plan_info[1].trial_status_flag = - (1)
 SET cretstatus = check_enrolled(1)
 IF (cretstatus="F")
  SET cretstatus = check_consent(1)
 ENDIF
 IF (cretstatus="F")
  SET reply->trial_plan_info[1].trial_status_flag = 3
 ELSE
  SET cretstatus = check_access(1)
 ENDIF
 SELECT INTO "nl:"
  FROM prot_master pm
  WHERE (pm.prot_master_id=reply->trial_plan_info[1].prot_master_id)
  DETAIL
   reply->trial_plan_info[1].primary_mnemonic = pm.primary_mnemonic,
   CALL echo(pm.prot_status_cd)
   IF (uar_get_code_meaning(pm.prot_status_cd)="COMPLETED")
    reply->trial_plan_info[1].trial_status_flag = 4
   ENDIF
  WITH nocounter
 ;end select
 SUBROUTINE (check_enrolled(i=i4) =c1)
  SELECT INTO "nl:"
   FROM pt_prot_reg ppr
   WHERE (ppr.prot_master_id=reply->trial_plan_info[1].prot_master_id)
    AND (ppr.person_id=request->person_id)
    AND ppr.on_study_dt_tm <= cnvtdatetime(sysdate)
    AND ppr.end_effective_dt_tm >= cnvtdatetime(sysdate)
   DETAIL
    reply->trial_plan_info[1].trial_status_flag = 1, reply->trial_plan_info[1].organization_id = ppr
    .enrolling_organization_id
    IF (ppr.off_study_dt_tm <= cnvtdatetime(sysdate))
     reply->trial_plan_info[1].trial_status_flag = 5
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual > 0)
   RETURN("S")
  ELSE
   RETURN("F")
  ENDIF
 END ;Subroutine
 SUBROUTINE (check_consent(i=i4) =c1)
  SELECT INTO "nl:"
   FROM prot_master pm,
    prot_amendment pa,
    pt_consent pc
   PLAN (pm
    WHERE (pm.prot_master_id=reply->trial_plan_info[1].prot_master_id))
    JOIN (pa
    WHERE pm.prot_master_id=pa.prot_master_id)
    JOIN (pc
    WHERE pc.prot_amendment_id=pa.prot_amendment_id
     AND pc.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND pc.consent_signed_dt_tm >= cnvtdatetime(sysdate)
     AND pc.not_returned_dt_tm >= cnvtdatetime(sysdate)
     AND (pc.person_id=request->person_id))
   DETAIL
    reply->trial_plan_info[1].trial_status_flag = 0, reply->trial_plan_info[1].organization_id = pc
    .consenting_organization_id
   WITH nocounter
  ;end select
  IF (curqual > 0)
   RETURN("S")
  ELSE
   RETURN("F")
  ENDIF
 END ;Subroutine
 SUBROUTINE (check_access(i=i4) =c1)
   DECLARE corgstatus = c1 WITH protect, noconstant("F")
   EXECUTE ct_get_org_security  WITH replace("REPLY","ORG_SEC_REPLY")
   IF ((org_sec_reply->orgsecurityflag=1))
    SET suserorgs = builduserorglist("")
    SET icnt = size(user_org_reply->organizations,5)
    FOR (i = 1 TO icnt)
      IF ((user_org_reply->organizations[i].organization_id=reply->trial_plan_info[1].organization_id
      ))
       SET corgstatus = "S"
       SET i = icnt
      ENDIF
    ENDFOR
   ELSE
    SET corgstatus = "S"
   ENDIF
   IF (corgstatus="F")
    SET reply->trial_plan_info[1].trial_status_flag = 2
   ENDIF
   RETURN(corgstatus)
 END ;Subroutine
 SET cstatus = "S"
#exit_script
 SET reply->status_data.status = cstatus
 CALL echorecord(reply)
END GO
