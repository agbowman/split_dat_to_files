CREATE PROGRAM bbd_get_device_by_option:dba
 RECORD reply(
   1 qual[*]
     2 device_type_cd = f8
     2 device_type_disp = c40
     2 device_type_mean = c12
     2 nbr_of_device = i4
     2 device_qual[*]
       3 bb_inv_device_id = f8
       3 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
 SET reply->status_data.status = "F"
 SET qual_count = 0
 SET device_count = 0
 SELECT INTO "nl:"
  mod.device_type_cd, mod.nbr_of_device, bid.bb_inv_device_id,
  bid.description
  FROM modify_option_device mod,
   bb_inv_device bid
  PLAN (mod
   WHERE (mod.option_id=request->option_id)
    AND mod.active_ind=1)
   JOIN (bid
   WHERE bid.device_type_cd=mod.device_type_cd
    AND bid.active_ind=1)
  ORDER BY mod.device_type_cd
  HEAD mod.device_type_cd
   qual_count = (qual_count+ 1), stat = alterlist(reply->qual,qual_count), reply->qual[qual_count].
   device_type_cd = mod.device_type_cd,
   reply->qual[qual_count].nbr_of_device = mod.nbr_of_device, device_count = 0
  DETAIL
   device_count = (device_count+ 1), stat = alterlist(reply->qual[qual_count].device_qual,
    device_count), reply->qual[qual_count].device_qual[device_count].bb_inv_device_id = bid
   .bb_inv_device_id,
   reply->qual[qual_count].device_qual[device_count].description = bid.description
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_get_device_by_option.prg"
  SET reply->status_data.subeventstatus[1].operationname = "get"
  SET reply->status_data.subeventstatus[1].targetobjectname = "modify_option_device"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to retrieve devices"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 0
 ENDIF
#exitscript
END GO
