CREATE PROGRAM ct_get_committee_by_person:dba
 RECORD reply(
   1 qual[*]
     2 committee_id = f8
     2 committee_type_cd = f8
     2 sponsoring_org_id = f8
     2 sponsoring_org_name = vc
     2 committee_member_id = f8
     2 committee_name = vc
     2 role = vc
     2 email_address = vc
   1 reason_for_failure = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SELECT INTO "nl:"
  c.committee_id, cm.committee_member_id, cv.code_value
  FROM committee c,
   committee_member cm,
   code_value cv,
   organization org
  PLAN (cm
   WHERE (cm.person_id=request->person_id)
    AND cm.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00.00"))
   JOIN (c
   WHERE c.committee_id=cm.committee_id
    AND c.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00.00"))
   JOIN (cv
   WHERE cv.code_value=cm.role_cd)
   JOIN (org
   WHERE org.organization_id=c.sponsoring_org_id)
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].committee_id = c
   .committee_id,
   reply->qual[count].committee_type_cd = c.committee_type_cd, reply->qual[count].committee_member_id
    = cm.committee_member_id, reply->qual[count].committee_name = c.committee_name,
   reply->qual[count].role = cv.display, reply->qual[count].sponsoring_org_id = c.sponsoring_org_id,
   reply->qual[count].sponsoring_org_name = org.org_name,
   reply->qual[count].email_address = c.email_address,
   CALL echo(build("Committee Name =",c.committee_name)),
   CALL echo(build("Role = ",cv.display))
  WITH nocounter
 ;end select
#exit_script
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSEIF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echo(build("Status = ",reply->status_data.status))
END GO
