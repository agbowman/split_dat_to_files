CREATE PROGRAM ct_get_organizations:dba
 RECORD reply(
   1 qual[*]
     2 organization_id = f8
     2 org_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET where_str = cnvtupper(build(request->org_name,"*"))
 CALL echo(build("where:",where_str))
 CALL echo("before select")
 SELECT INTO "nl:"
  p.organization_id, p.org_name
  FROM organization p
  WHERE cnvtupper(p.org_name)=patstring(where_str)
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->qual,count1), reply->qual[count1].organization_id =
   p.organization_id,
   reply->qual[count1].org_name = substring(1,50,p.org_name),
   CALL echo(build("orgname:",p.org_name))
  WITH nocounter
 ;end select
#exit_script
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
