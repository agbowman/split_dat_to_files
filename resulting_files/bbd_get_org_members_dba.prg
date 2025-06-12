CREATE PROGRAM bbd_get_org_members:dba
 RECORD reply(
   1 qual[*]
     2 person_id = f8
     2 name_full_formatted = vc
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
 SET contact_type_cd = 0.0
 SET donor_org_cd = 0.0
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
  p.name_full_formatted, po.active_ind, dc.person_id,
  dc.contact_dt_tm
  FROM person p,
   person_org_reltn po,
   bbd_donor_contact dc
  PLAN (po
   WHERE (po.organization_id=request->organization_id)
    AND po.person_org_reltn_cd=donor_org_cd)
   JOIN (dc
   WHERE dc.organization_id=po.organization_id
    AND dc.person_id=po.person_id
    AND dc.contact_type_cd=contact_type_cd
    AND dc.active_ind=1)
   JOIN (p
   WHERE p.person_id=dc.person_id
    AND p.active_ind=1)
  ORDER BY p.name_full_formatted, dc.person_id, dc.contact_dt_tm DESC
  HEAD dc.person_id
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].person_id = dc
   .person_id,
   reply->qual[count].name_full_formatted = p.name_full_formatted, reply->qual[count].
   last_donation_dt_tm = dc.contact_dt_tm, reply->qual[count].active_ind = po.active_ind
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exitscript
END GO
