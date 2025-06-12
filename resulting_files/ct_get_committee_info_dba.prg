CREATE PROGRAM ct_get_committee_info:dba
 RECORD reply(
   1 qual[*]
     2 cmt_id = f8
     2 com_name = vc
     2 email = vc
     2 cmt_type = vc
     2 spons_org_id = f8
     2 orgname = vc
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
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET counter = 0
 SELECT INTO "nl:"
  cm.committee_name, orgname = org.org_name, cmt_type = uar_get_code_display(cm.committee_type_cd)
  FROM committee cm,
   organization org
  PLAN (cm)
   JOIN (org
   WHERE cm.sponsoring_org_id=org.organization_id
    AND cm.committee_id > 0
    AND cm.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00.00")
    AND (org.logical_domain_id=domain_reply->logical_domain_id))
  ORDER BY cm.committee_name
  HEAD REPORT
   stat = alterlist(reply->qual,10)
  DETAIL
   counter += 1
   IF (mod(counter,10)=1
    AND counter != 1)
    stat = alterlist(reply->qual,(counter+ 9))
   ENDIF
   reply->qual[counter].cmt_id = cm.committee_id, reply->qual[counter].com_name = cm.committee_name,
   reply->qual[counter].cmt_type = cmt_type,
   reply->qual[counter].email = cm.email_address, reply->qual[counter].spons_org_id = cm
   .sponsoring_org_id, reply->qual[counter].orgname = orgname
  FOOT REPORT
   stat = alterlist(reply->qual,counter)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  CALL echo("there were no committees in the table")
  GO TO exit_script
 ELSE
  CALL echo(build("number of committees: ",counter))
 ENDIF
 CALL echo(build("cmt_id: ",reply->qual[1].cmt_id))
 CALL echo(build("cmt_name: ",reply->qual[1].com_name))
 CALL echo(build("spongs_org_id: ",reply->qual[1].spons_org_id))
 CALL echo(build("email: ",reply->qual[1].email))
 CALL echo(build("orgname: ",reply->qual[1].orgname))
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(build("Status:",reply->status_data.status))
 SET last_mod = "002"
 SET mod_date = "April 1, 2019"
END GO
