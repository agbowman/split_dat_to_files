CREATE PROGRAM dcp_get_trial_plan_reltn:dba
 RECORD reply(
   1 trial_plan_reltn[*]
     2 minimum_enrollment_status_flag = i2
     2 ordering_policy_flag = i2
     2 pathway_catalog_id = f8
     2 prot_master_id = f8
     2 pw_pt_reltn_id = f8
     2 require_override_reason_ind = i2
     2 sequence = i4
     2 plan_description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE list_size = i4 WITH protect, noconstant(0)
 DECLARE cstatus = c1 WITH protect, noconstant("Z")
 DECLARE batch_size = i4 WITH protect, constant(20)
 DECLARE iindex = i4 WITH noconstant(0), protect
 DECLARE dcurdate = dq8
 DECLARE dbegdate = dq8
 DECLARE denddate = dq8
 DECLARE lowdatediff = f8 WITH noconstant(0.0), protect
 DECLARE highdatediff = f8 WITH noconstant(0.0), protect
 SELECT INTO "nl:"
  ppr.prot_master_id, ppr.pathway_catalog_id, pc.pathway_catalog_id
  FROM pw_pt_reltn ppr,
   pathway_catalog pc
  WHERE (ppr.prot_master_id=request->prot_master_id)
   AND pc.pathway_catalog_id=ppr.pathway_catalog_id
   AND ppr.active_ind=1
  ORDER BY ppr.sequence, ppr.pathway_catalog_id
  HEAD REPORT
   stat = alterlist(reply->trial_plan_reltn,batch_size), list_size = batch_size
  DETAIL
   dcurdate = cnvtdatetime(sysdate), dbegdate = cnvtdatetime(ppr.beg_effective_dt_tm), denddate =
   cnvtdatetime(ppr.end_effective_dt_tm),
   lowdatediff = datetimediff(dcurdate,dbegdate), highdatediff = datetimediff(dcurdate,denddate)
   IF (lowdatediff > 0.0
    AND highdatediff < 0.0)
    iindex += 1
    IF (iindex > list_size)
     stat = alterlist(reply->trial_plan_reltn,(iindex+ (batch_size - 1))), list_size += batch_size
    ENDIF
    reply->trial_plan_reltn[iindex].minimum_enrollment_status_flag = ppr
    .minimum_enrollment_status_flag, reply->trial_plan_reltn[iindex].ordering_policy_flag = ppr
    .ordering_policy_flag, reply->trial_plan_reltn[iindex].pathway_catalog_id = ppr
    .pathway_catalog_id,
    reply->trial_plan_reltn[iindex].prot_master_id = ppr.prot_master_id, reply->trial_plan_reltn[
    iindex].pw_pt_reltn_id = ppr.pw_pt_reltn_id, reply->trial_plan_reltn[iindex].
    require_override_reason_ind = ppr.require_override_reason_ind,
    reply->trial_plan_reltn[iindex].sequence = ppr.sequence, reply->trial_plan_reltn[iindex].
    plan_description = pc.description
   ENDIF
  FOOT REPORT
   IF (iindex > 0)
    stat = alterlist(reply->trial_plan_reltn,iindex)
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET cstatus = "S"
 ENDIF
 SET reply->status_data.status = cstatus
END GO
