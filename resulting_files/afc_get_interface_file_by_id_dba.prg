CREATE PROGRAM afc_get_interface_file_by_id:dba
 SET afc_get_interface_file_by_id_vrsn = "176624.001"
 DECLARE lcount = i4 WITH noconstant(0)
 FREE RECORD reply
 RECORD reply(
   1 qual[*]
     2 interface_file_id = f8
     2 description = vc
     2 realtime_ind = i2
     2 profit_type_cd = f8
     2 active_ind = i2
     2 interface_type_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "Nl:"
  FROM (dummyt d  WITH seq = value(size(request->qual,5))),
   interface_file ifl
  PLAN (d)
   JOIN (ifl
   WHERE (ifl.interface_file_id=request->qual[d.seq].interface_file_id)
    AND ifl.active_ind=1)
  ORDER BY ifl.interface_file_id DESC
  DETAIL
   lcount = (lcount+ 1), stat = alterlist(reply->qual,lcount), reply->qual[lcount].interface_file_id
    = ifl.interface_file_id,
   reply->qual[lcount].description = trim(ifl.description,3), reply->qual[lcount].realtime_ind = ifl
   .realtime_ind, reply->qual[lcount].profit_type_cd = ifl.profit_type_cd,
   reply->qual[lcount].active_ind = ifl.active_ind, reply->qual[lcount].interface_type_flag = ifl
   .interface_type_flag
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET reply->status_data.status = "Z"
  GO TO exitscript
 ENDIF
 SET reply->status_data.status = "S"
#exitscript
 CALL echorecord(reply)
END GO
