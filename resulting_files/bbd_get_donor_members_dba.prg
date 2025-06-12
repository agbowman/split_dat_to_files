CREATE PROGRAM bbd_get_donor_members:dba
 RECORD reply(
   1 qual[*]
     2 org_id = f8
     2 org_name = vc
     2 last_donation_dt_tm = dq8
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET donor_org_cd = 0.0
 SET contact_type_cd = 0.0
 SET count = 0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=338
   AND c.cdf_meaning="DONOR"
   AND c.active_ind=1
  DETAIL
   donor_org_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=14220
   AND c.cdf_meaning="DONATE"
   AND c.active_ind=1
  DETAIL
   contact_type_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.organization_id, p.acitve_ind, o.org_name,
  d.contact_dt_tm
  FROM person_org_reltn p,
   organization o,
   bbd_donor_contact d
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND p.person_org_reltn_cd=donor_org_cd)
   JOIN (d
   WHERE d.person_id=p.person_id
    AND d.organization_id=p.organization_id
    AND d.contact_type_cd=contact_type_cd
    AND d.active_ind=1)
   JOIN (o
   WHERE o.organization_id=d.organization_id
    AND o.active_ind=1)
  ORDER BY o.org_name, o.organization_id, d.contact_dt_tm DESC
  HEAD o.organization_id
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].org_id = o
   .organization_id,
   reply->qual[count].org_name = o.org_name, reply->qual[count].last_donation_dt_tm = d.contact_dt_tm,
   reply->qual[count].active_ind = p.active_ind
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exitscript
END GO
