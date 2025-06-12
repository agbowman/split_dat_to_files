CREATE PROGRAM ct_get_orgname:dba
 SET _orgname = fillstring(255,"")
 SET _orgid = 0.0
 SET prot_acc_nbr = fillstring(255,"")
 SELECT INTO "nl:"
  FROM pt_prot_reg ppr,
   organization org
  PLAN (ppr
   WHERE ppr.reg_id=reg_id
    AND ppr.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00.00"))
   JOIN (org
   WHERE org.organization_id=ppr.enrolling_organization_id)
  DETAIL
   _orgname = org.org_name, _orgid = ppr.enrolling_organization_id, prot_acc_nbr = ppr
   .prot_accession_nbr
  WITH nocounter
 ;end select
END GO
