CREATE PROGRAM bbt_get_inv_devices:dba
 RECORD reply(
   1 qual[*]
     2 device_id = f8
     2 description = c40
     2 active_ind = i2
     2 device_type_cd = f8
     2 interface_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD inventoryarealist(
   1 inventorylist[*]
     2 inventory_cd = f8
 )
 SET reply->status_data.status = "F"
 SET execute_current = 0
 IF (validate(request->filter_devices_ind)=0
  AND validate(request->apply_filter_ind)=0)
  CALL getalldevices(null)
 ELSE
  IF ((request->apply_filter_ind=1))
   CALL getfiltereddevicelist(request->filter_devices_ind)
  ELSE
   CALL getalldevices(null)
  ENDIF
 ENDIF
 SUBROUTINE getalldevices(null)
   SET count = 0
   SET stat = alterlist(reply->qual,10)
   SELECT INTO "nl:"
    bd.bb_inv_device_id, bd.description, bd.active_ind,
    bd.device_type_cd
    FROM bb_inv_device bd
    WHERE bd.bb_inv_device_id > 0
    HEAD REPORT
     count = 0
    DETAIL
     count = (count+ 1)
     IF (mod(count,10)=1
      AND count != 1)
      stat = alterlist(reply->qual,(count+ 9))
     ENDIF
     reply->qual[count].device_id = bd.bb_inv_device_id, reply->qual[count].description = bd
     .description, reply->qual[count].active_ind = bd.active_ind,
     reply->qual[count].device_type_cd = bd.device_type_cd, reply->qual[count].interface_flag = bd
     .interface_flag
    WITH counter
   ;end select
   SET stat = alterlist(reply->qual,count)
   IF (curqual=0)
    SET reply->status_data.status = "Z"
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
 END ;Subroutine
 DECLARE getfiltereddevicelist(filter_devices=i4) = null
 SUBROUTINE getfiltereddevicelist(filter_devices)
   RECORD invareasreply(
     1 ownerlist[*]
       2 owner_cd = f8
       2 owner_disp = vc
       2 invlist[*]
         3 inventory_cd = f8
         3 inventory_disp = vc
         3 org_id = f8
         3 restrict_ind = i2
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   DECLARE inv_cnt = i4 WITH noconstant(0)
   DECLARE owner_area_index = i4 WITH noconstant(1)
   DECLARE inv_area_index = i4 WITH noconstant(1)
   DECLARE owner_area_cnt = i4 WITH noconstant(0)
   DECLARE inv_area_cnt = i4 WITH noconstant(0)
   DECLARE invdeviceididx = i4 WITH noconstant(0)
   DECLARE device_count = i4 WITH noconstant(0)
   DECLARE locn_cd = f8 WITH noconstant(0.0)
   DECLARE srvres_cd = f8 WITH noconstant(0.0)
   DECLARE invarea_cd = f8 WITH noconstant(0.0)
   SET reply->status_data.status = "F"
   SET stat = uar_get_meaning_by_codeset(17396,"BBINVAREA",1,invarea_cd)
   EXECUTE bb_ref_get_owner_inv_areas  WITH replace("REQUEST","INVAREASREQUEST"), replace("REPLY",
    "INVAREASREPLY")
   IF ((invareasreply->status_data.status="F"))
    EXECUTE goto endscript
   ENDIF
   SET owner_area_cnt = size(invareasreply->ownerlist,5)
   WHILE (owner_area_index <= owner_area_cnt)
     SET inv_area_cnt = size(invareasreply->ownerlist[owner_area_index].invlist,5)
     SET inv_area_index = 1
     WHILE (inv_area_index <= inv_area_cnt)
       IF (((mod(inv_cnt,10)=1) OR (inv_cnt=0)) )
        SET stat = alterlist(inventoryarealist->inventorylist,(inv_cnt+ 10))
       ENDIF
       IF (filter_devices=1)
        IF ((invareasreply->ownerlist[owner_area_index].invlist[inv_area_index].restrict_ind=0))
         SET inv_cnt = (inv_cnt+ 1)
         SET inventoryarealist->inventorylist[inv_cnt].inventory_cd = invareasreply->ownerlist[
         owner_area_index].invlist[inv_area_index].inventory_cd
        ENDIF
       ELSE
        SET inv_cnt = (inv_cnt+ 1)
        SET inventoryarealist->inventorylist[inv_cnt].inventory_cd = invareasreply->ownerlist[
        owner_area_index].invlist[inv_area_index].inventory_cd
       ENDIF
       SET inv_area_index = (inv_area_index+ 1)
     ENDWHILE
     SET owner_area_index = (owner_area_index+ 1)
   ENDWHILE
   SET stat = alterlist(inventoryarealist->inventorylist,inv_cnt)
   SET device_count = populatedevice(device_count)
   SET stat = alterlist(reply->qual,device_count)
   IF (device_count > 0)
    SET reply->status_data.status = "S"
   ELSE
    SET reply->status_data.status = "Z"
   ENDIF
#endscript
 END ;Subroutine
 DECLARE populatedevice(device_count=i4) = i4
 SUBROUTINE populatedevice(device_count)
   DECLARE num = i4 WITH noconstant(0), public
   SELECT INTO "nl:"
    bbd.bb_inv_device_id, bbd.active_ind, bdr.bb_inv_device_r_id,
    device_r_type_mean = uar_get_code_meaning(bdr.device_r_type_cd), bdr.device_r_cd, y =
    uar_get_code_display(bdr.device_r_cd),
    bdr.active_ind
    FROM bb_inv_device bbd,
     bb_inv_device_r bdr
    PLAN (bdr
     WHERE expand(invdeviceididx,1,size(inventoryarealist->inventorylist,5),bdr.device_r_cd,
      inventoryarealist->inventorylist[invdeviceididx].inventory_cd)
      AND bdr.active_ind=1)
     JOIN (bbd
     WHERE bbd.bb_inv_device_id=bdr.bb_inv_device_id
      AND bdr.device_r_type_cd=invarea_cd
      AND bbd.active_ind=1)
    ORDER BY bbd.bb_inv_device_id, bdr.bb_inv_device_r_id
    HEAD REPORT
     row + 0
    DETAIL
     IF (((mod(device_count,10)=1) OR (device_count=0)) )
      stat = alterlist(reply->qual,(device_count+ 10))
     ENDIF
     pos_one = locateval(num,1,device_count,bbd.bb_inv_device_id,reply->qual[num].device_id)
     IF (pos_one=0)
      device_count = (device_count+ 1), reply->qual[device_count].device_id = bbd.bb_inv_device_id,
      reply->qual[device_count].description = bbd.description,
      reply->qual[device_count].active_ind = bbd.active_ind, reply->qual[device_count].device_type_cd
       = bbd.device_type_cd, reply->qual[device_count].interface_flag = bbd.interface_flag
     ENDIF
    FOOT REPORT
     row + 0
    WITH nocounter
   ;end select
   RETURN(device_count)
 END ;Subroutine
END GO
