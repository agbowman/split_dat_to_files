CREATE PROGRAM aps_get_inventory_types:dba
 RECORD reply(
   1 qual[*]
     2 inventory_type_cd = f8
     2 inventory_type_disp = vc
     2 retention[*]
       3 ap_inv_retention_id = f8
       3 prefix_id = f8
       3 prefix_name = vc
       3 normalcy_cd = f8
       3 normalcy_disp = vc
       3 retention_tm_value = f8
       3 retention_units_cd = f8
       3 retention_units_disp = vc
       3 retention_units_desc = vc
       3 retention_units_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM ap_inv_retention air,
   ap_prefix ap
  PLAN (air
   WHERE air.ap_inv_retention_id != 0.0)
   JOIN (ap
   WHERE ap.prefix_id=air.prefix_id)
  ORDER BY air.inventory_type_cd
  HEAD REPORT
   nqualcnt = 0, nretcnt = 0, lstat = 0
  HEAD air.inventory_type_cd
   nqualcnt = (nqualcnt+ 1), nretcnt = 0
   IF (mod(nqualcnt,3)=1)
    lstat = alterlist(reply->qual,(nqualcnt+ 2))
   ENDIF
   reply->qual[nqualcnt].inventory_type_cd = air.inventory_type_cd
  DETAIL
   nretcnt = (nretcnt+ 1)
   IF (mod(nretcnt,10)=1)
    lstat = alterlist(reply->qual[nqualcnt].retention,(nretcnt+ 9))
   ENDIF
   reply->qual[nqualcnt].retention[nretcnt].ap_inv_retention_id = air.ap_inv_retention_id, reply->
   qual[nqualcnt].retention[nretcnt].prefix_id = air.prefix_id, reply->qual[nqualcnt].retention[
   nretcnt].prefix_name = ap.prefix_name,
   reply->qual[nqualcnt].retention[nretcnt].normalcy_cd = air.normalcy_cd, reply->qual[nqualcnt].
   retention[nretcnt].retention_tm_value = air.retention_tm_value, reply->qual[nqualcnt].retention[
   nretcnt].retention_units_cd = air.retention_units_cd
  FOOT  air.inventory_type_cd
   lstat = alterlist(reply->qual[nqualcnt].retention,nretcnt)
  FOOT REPORT
   lstat = alterlist(reply->qual,nqualcnt)
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
