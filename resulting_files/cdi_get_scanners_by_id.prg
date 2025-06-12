CREATE PROGRAM cdi_get_scanners_by_id
 IF (validate(reply)=0)
  RECORD reply(
    1 scanners[*]
      2 cdi_scanner_id = f8
      2 scanner_name = vc
      2 scanner_ip_address = vc
      2 scanner_description = vc
      2 room_cd = f8
      2 nurse_unit_cd = f8
      2 building_cd = f8
      2 facility_cd = f8
      2 scanner_path = vc
      2 timeout = i4
      2 resolution_cd = f8
      2 type_cd = f8
      2 jpeg_quality = i2
      2 depth_cd = f8
      2 size_cd = f8
      2 orientation = i2
      2 duplex_ind = i2
      2 brightness = i4
      2 contrast_cd = f8
      2 auto_correct_ind = i2
      2 updt_cnt = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE scanner_rows = i4 WITH noconstant(value(size(request->scanners,5))), protect
 DECLARE num = i4 WITH noconstant(0), protect
 DECLARE count = i4 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 SELECT INTO "NL:"
  FROM cdi_scanner s
  WHERE expand(num,1,scanner_rows,s.cdi_scanner_id,request->scanners[num].cdi_scanner_id)
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1)
    stat = alterlist(reply->scanners,(count+ 9))
   ENDIF
   reply->scanners[count].cdi_scanner_id = s.cdi_scanner_id, reply->scanners[count].auto_correct_ind
    = s.auto_correct_ind, reply->scanners[count].brightness = s.brightness,
   reply->scanners[count].building_cd = s.building_cd, reply->scanners[count].contrast_cd = s
   .contrast_cd, reply->scanners[count].depth_cd = s.depth_cd,
   reply->scanners[count].duplex_ind = s.duplex_ind, reply->scanners[count].facility_cd = s
   .facility_cd, reply->scanners[count].jpeg_quality = s.jpeg_quality,
   reply->scanners[count].nurse_unit_cd = s.nurse_unit_cd, reply->scanners[count].orientation = s
   .orientation, reply->scanners[count].resolution_cd = s.resolution_cd,
   reply->scanners[count].room_cd = s.room_cd, reply->scanners[count].scanner_description = s
   .scanner_description, reply->scanners[count].scanner_ip_address = s.scanner_ip_address,
   reply->scanners[count].scanner_name = s.scanner_name, reply->scanners[count].scanner_path = s
   .scanner_path, reply->scanners[count].size_cd = s.size_cd,
   reply->scanners[count].timeout = s.timeout, reply->scanners[count].type_cd = s.type_cd, reply->
   scanners[count].updt_cnt = s.updt_cnt
  FOOT REPORT
   stat = alterlist(reply->scanners,count)
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
