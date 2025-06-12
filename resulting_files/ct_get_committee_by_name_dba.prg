CREATE PROGRAM ct_get_committee_by_name:dba
 RECORD reply(
   1 qual[*]
     2 committee_id = f8
     2 committee_name = vc
     2 committee_type_cd = f8
     2 sponsoring_org_id = f8
     2 sponsoring_org_name = vc
     2 email_address = vc
     2 member[*]
       3 committee_member_id = f8
       3 member_name = vc
       3 role = vc
       3 person_id = f8
   1 reason_for_failure = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 SET sizestr = size(request->committee_name,1)
 SET reply->status_data.status = "F"
 SET cmtcount = 0
 SET membcount = 0
 CALL echo(build("sizestr =",sizestr))
 IF ((request->committee_name="\*"))
  SET sizestr = 0
 ELSEIF (substring(sizestr,1,request->committee_name)="\*")
  CALL echo(build("Last char =",substring(sizestr,1,request->committee_name)))
  SET request->committee_name = substring(1,(sizestr - 1),request->committee_name)
  SET sizestr -= 1
 ENDIF
 CALL echo(build("request->Committee Name =",request->committee_name))
 CALL echo(build("sizestr = ",sizestr))
 SELECT INTO "nl:"
  c.committee_id, cm.committee_member_id, cv.code_value,
  org.organization_id, p.person_id
  FROM committee c,
   committee_member cm,
   code_value cv,
   organization org,
   person p,
   dummyt d1
  PLAN (c
   WHERE c.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00.00")
    AND (((request->committee_name="\*")) OR (cnvtlower(substring(1,sizestr,c.committee_name))=
   cnvtlower(request->committee_name))) )
   JOIN (org
   WHERE org.organization_id=c.sponsoring_org_id
    AND (org.logical_domain_id=domain_reply->logical_domain_id))
   JOIN (d1)
   JOIN (cm
   WHERE c.committee_id=cm.committee_id
    AND cm.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00.00"))
   JOIN (p
   WHERE p.person_id=cm.person_id)
   JOIN (cv
   WHERE cv.code_value=cm.role_cd)
  HEAD c.committee_id
   cmtcount += 1, membcount = 0, stat = alterlist(reply->qual,cmtcount),
   reply->qual[cmtcount].committee_id = c.committee_id, reply->qual[cmtcount].committee_name = c
   .committee_name, reply->qual[cmtcount].committee_type_cd = c.committee_type_cd,
   reply->qual[cmtcount].sponsoring_org_id = c.sponsoring_org_id, reply->qual[cmtcount].
   sponsoring_org_name = org.org_name, reply->qual[cmtcount].email_address = c.email_address,
   CALL echo(build("COmmittee Name = ",c.committee_name)),
   CALL echo(build("Sponsoring Org = ",org.org_name))
  DETAIL
   IF (cm.committee_member_id != 0)
    membcount += 1, stat = alterlist(reply->qual[cmtcount].member,membcount), reply->qual[cmtcount].
    member[membcount].committee_member_id = cm.committee_member_id,
    reply->qual[cmtcount].member[membcount].member_name = p.name_full_formatted, reply->qual[cmtcount
    ].member[membcount].role = cv.display, reply->qual[cmtcount].member[membcount].person_id = cm
    .person_id,
    CALL echo(build("Member Name =",p.name_full_formatted)),
    CALL echo(build("Role = ",cv.display))
   ENDIF
  WITH outerjoin = d1, nocounter
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
 SET last_mod = "002"
 SET mod_date = "May 14, 2019"
END GO
