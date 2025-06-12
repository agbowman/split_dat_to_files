CREATE PROGRAM ct_get_orgs_by_type:dba
 RECORD reply(
   1 organization[*]
     2 organization_id = f8
     2 org_name = c100
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD pmorgs_reply(
   1 organization[*]
     2 organization_id = f8
     2 org_name = c100
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
 DECLARE num = i2 WITH protect, noconstant(0)
 DECLARE count = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 EXECUTE pm_get_orgs_by_type  WITH replace("REPLY",pmorgs_reply)
 IF ((pmorgs_reply->status_data.status != "S"))
  GO TO check_error
 ENDIF
 CALL echo("Filtering tenant specific organizations")
 SELECT INTO "nl:"
  o.organization_id, o.org_name
  FROM organization o
  WHERE expand(num,1,size(pmorgs_reply->organization,5),o.organization_id,pmorgs_reply->organization[
   num].organization_id)
   AND (o.logical_domain_id=domain_reply->logical_domain_id)
  ORDER BY o.org_name
  HEAD REPORT
   count = 0
  DETAIL
   count += 1
   IF (count > size(reply->organization,5))
    stat = alterlist(reply->organization,(count+ 10))
   ENDIF
   reply->organization[count].organization_id = o.organization_id, reply->organization[count].
   org_name = o.org_name
  FOOT REPORT
   stat = alterlist(reply->organization,count)
  WITH nocounter, expand = 2
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "No Organizations Found"
  SET reply->status_data.status = "Z"
 ENDIF
#check_error
 IF ((((pmorgs_reply->status_data.status="Z")) OR ((pmorgs_reply->status_data.status="F"))) )
  SET reply->status_data.status = pmorgs_reply->status_data.status
  SET reply->status_data.subeventstatus[1].operationname = pmorgs_reply->status_data.subeventstatus[1
  ].operationname
  SET reply->status_data.subeventstatus[1].operationstatus = pmorgs_reply->status_data.
  subeventstatus[1].operationstatus
  SET reply->status_data.subeventstatus[1].targetobjectname = pmorgs_reply->status_data.
  subeventstatus[1].targetobjectname
  SET reply->status_data.subeventstatus[1].targetobjectvalue = pmorgs_reply->status_data.
  subeventstatus[1].targetobjectvalue
 ENDIF
 SET last_mod = "001"
 SET mod_date = "April 15, 2019"
END GO
