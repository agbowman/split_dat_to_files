CREATE PROGRAM ct_get_excluded_clients:dba
 RECORD reply(
   1 client_qual[*]
     2 organization_id = f8
     2 org_name = vc
     2 active_ind = i2
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
 SET count = 0
 DECLARE new = i4
 SET new = 0
 SELECT INTO "nl:"
  FROM ct_excluded_clients ec,
   organization o,
   dummyt d
  PLAN (ec)
   JOIN (d)
   JOIN (o
   WHERE o.organization_id=ec.organization_id
    AND (o.logical_domain_id=domain_reply->logical_domain_id))
  DETAIL
   count += 1
   IF (mod(count,10)=1)
    new = (count+ 10), stat = alterlist(reply->client_qual,new)
   ENDIF
   reply->client_qual[count].organization_id = ec.organization_id, reply->client_qual[count].org_name
    = o.org_name, reply->client_qual[count].active_ind = ec.active_ind
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->client_qual,count)
 IF (count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL echo(build("status:",reply->status_data.status))
 SET last_mod = "001"
 SET mod_date = "April 10, 2019"
END GO
