CREATE PROGRAM bbd_get_conta_selected_org:dba
 RECORD reply(
   1 qual[*]
     2 container_org_id = f8
     2 container_type_cd = f8
     2 organization_id = f8
     2 updt_cnt = i4
     2 inventory_area_cd = f8
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
  c.*
  FROM container_org_r c
  WHERE (c.container_type_cd=request->container_cd)
   AND c.active_ind=1
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].container_org_id = c
   .container_org_id,
   reply->qual[count].container_type_cd = c.container_type_cd, reply->qual[count].organization_id = c
   .organization_id, reply->qual[count].updt_cnt = c.updt_cnt,
   reply->qual[count].inventory_area_cd = c.inventory_area_cd
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exitscript
END GO
