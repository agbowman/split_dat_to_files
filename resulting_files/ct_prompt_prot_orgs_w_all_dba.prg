CREATE PROGRAM ct_prompt_prot_orgs_w_all:dba
 EXECUTE ccl_prompt_api_dataset "autoset"
 IF ( NOT (validate(domain_reply)))
  RECORD domain_reply(
    1 logical_domain_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE ct_get_logical_domain_id  WITH replace("REPLY",domain_reply)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SELECT DISTINCT
  org.organization_id, org.org_name
  FROM prot_amendment pa,
   prot_master pm,
   organization org,
   pt_prot_reg ppr
  PLAN (pa
   WHERE pa.amendment_dt_tm < cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (pm
   WHERE pm.prot_master_id=pa.prot_master_id
    AND pm.prot_master_id > 0
    AND (((0.0= $1)) OR ((pm.prot_master_id= $1)))
    AND (((0.0= $2)) OR ((pm.initiating_service_cd= $2))) )
   JOIN (ppr
   WHERE ppr.prot_master_id=pm.prot_master_id
    AND ppr.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (org
   WHERE org.organization_id=ppr.enrolling_organization_id
    AND (org.logical_domain_id=domain_reply->logical_domain_id))
  ORDER BY cnvtlower(org.org_name)
  HEAD REPORT
   stat = makedataset(20)
  DETAIL
   stat = writerecord(0)
  FOOT REPORT
   stat = closedataset(0)
  WITH nocounter, reporthelp, check
 ;end select
 SET last_mod = "001"
 SET mod_date = "Nov 22, 2019"
END GO
