CREATE PROGRAM dm_get_ref_domain_r:dba
 RECORD reply(
   1 qual[*]
     2 group_name = vc
     2 ref_domain_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET cnt = 0
 SELECT INTO "NL:"
  dm.group_name, dm.ref_domain_name, dmr.code_set
  FROM dm_ref_domain_r dm,
   dm_ref_domain dmr
  WHERE dmr.ref_domain_name=dm.ref_domain_name
  ORDER BY dm.group_name, dmr.code_set, dm.ref_domain_name
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].group_name = dm.group_name,
   reply->qual[cnt].ref_domain_name = dm.ref_domain_name
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
