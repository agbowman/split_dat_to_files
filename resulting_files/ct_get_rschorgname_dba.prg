CREATE PROGRAM ct_get_rschorgname:dba
 SET _orgname = fillstring(255,"")
 SET _orgid = 0.0
 SET primary_cd = 0.0
 SET stat = 0.0
 SET stat = uar_get_meaning_by_codeset(17271,"PRIMARY",1,primary_cd)
 SELECT INTO "nl:"
  pgs.prot_grant_sponsor_id
  FROM prot_grant_sponsor pgs,
   organization org
  PLAN (pgs
   WHERE pgs.prot_amendment_id=amendment_id)
   JOIN (org
   WHERE pgs.organization_id=org.organization_id
    AND pgs.primary_secondary_cd=primary_cd)
  DETAIL
   _orgid = pgs.organization_id, _orgname = org.org_name
  WITH nocounter
 ;end select
END GO
