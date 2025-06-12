CREATE PROGRAM dcp_get_trial_by_plan_id:dba
 FREE RECORD reply
 RECORD reply(
   1 prot_master_id = f8
   1 primary_mnemonic = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE cstatus = c1 WITH protect, noconstant("Z")
 DECLARE ddate = dq8 WITH protect, constant(cnvtdatetime(request->date_time))
 DECLARE dbegdate = dq8
 DECLARE denddate = dq8
 DECLARE lowdatediff = f8 WITH noconstant(0.0), protect
 DECLARE highdatediff = f8 WITH noconstant(0.0), protect
 SELECT INTO "n1:"
  FROM pw_pt_reltn ppr
  WHERE (ppr.pathway_catalog_id=request->pathway_catalog_id)
  ORDER BY ppr.end_effective_dt_tm DESC
  DETAIL
   dbegdate = cnvtdatetime(ppr.beg_effective_dt_tm), denddate = cnvtdatetime(ppr.end_effective_dt_tm),
   lowdatediff = datetimediff(ddate,dbegdate),
   highdatediff = datetimediff(ddate,denddate)
   IF (lowdatediff > 0.0
    AND highdatediff < 0.0)
    reply->prot_master_id = ppr.prot_master_id,
    CALL cancel(1)
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM prot_master pm
  WHERE (pm.prot_master_id=reply->prot_master_id)
  DETAIL
   reply->primary_mnemonic = trim(pm.primary_mnemonic)
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 SET cstatus = "S"
#exit_script
 SET reply->status_data.status = cstatus
END GO
