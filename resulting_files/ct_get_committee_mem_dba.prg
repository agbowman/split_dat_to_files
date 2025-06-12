CREATE PROGRAM ct_get_committee_mem:dba
 RECORD reply(
   1 comt_name = vc
   1 qual[*]
     2 role = vc
     2 name = vc
     2 person_id = f8
     2 org_id = f8
     2 orgname = vc
     2 role_codevalue = f8
     2 cmt_mem_id = f8
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
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET counter = 0
 SET loop = 0
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SELECT INTO "nl:"
  comname = comt.committee_name, name = p.name_full_formatted, person_id = cm.person_id,
  orgname = org.org_name, org_id = org.organization_id, cmt_mem_id = cm.committee_member_id,
  role_codevalue = cm.role_cd, role = uar_get_code_display(cm.role_cd)
  FROM committee_member cm,
   committee comt,
   person p,
   organization org,
   dummyt d
  PLAN (comt
   WHERE (comt.committee_id=request->cmt_id))
   JOIN (d)
   JOIN (cm
   WHERE comt.committee_id=cm.committee_id
    AND cm.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00.00"))
   JOIN (p
   WHERE cm.person_id=p.person_id)
   JOIN (org
   WHERE cm.organization_id=org.organization_id
    AND (org.logical_domain_id=domain_reply->logical_domain_id))
  HEAD REPORT
   stat = alterlist(reply->qual,10), reply->comt_name = comname
  DETAIL
   counter += 1
   IF (mod(counter,10)=1
    AND counter != 1)
    stat = alterlist(reply->qual,(counter+ 9))
   ENDIF
   reply->qual[counter].role = role, reply->qual[counter].name = name, reply->qual[counter].orgname
    = orgname,
   reply->qual[counter].person_id = person_id, reply->qual[counter].org_id = org_id, reply->qual[
   counter].role_codevalue = role_codevalue,
   reply->qual[counter].cmt_mem_id = cmt_mem_id
  FOOT REPORT
   stat = alterlist(reply->qual,counter)
  WITH outerjoin = d, nocounter
 ;end select
 CALL echo(build("counter now : ",counter))
 IF (curqual=0
  AND counter=1)
  SET failed = "T"
  SET reply->comt_name = comname
  CALL echo("there were no members in the committee")
  GO TO exit_script
 ELSE
  CALL echo(build("number of members: ",counter))
 ENDIF
 CALL echo(build("comt_name: ",reply->comt_name))
 FOR (loop = 1 TO counter)
   CALL echo(build("name:",reply->qual[loop].name))
   CALL echo(build("role:",reply->qual[loop].role))
   CALL echo(build("orgname:",reply->qual[loop].orgname))
   CALL echo(build("codevalue:",reply->qual[loop].role_codevalue))
   CALL echo(build("cmt_mem_id:",reply->qual[loop].cmt_mem_id))
 ENDFOR
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(build("Status:",reply->status_data.status))
 SET last_mod = "002"
 SET mod_date = "April 2, 2019"
END GO
