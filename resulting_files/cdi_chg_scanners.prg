CREATE PROGRAM cdi_chg_scanners
 IF (validate(reply)=0)
  RECORD reply(
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
 DECLARE rows_to_update_count = i4 WITH noconstant(0), protect
 DECLARE num = i4 WITH noconstant(0), protect
 DECLARE count = i4 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 SELECT INTO "NL:"
  FROM cdi_scanner s
  WHERE expand(num,1,scanner_rows,s.cdi_scanner_id,request->scanners[num].cdi_scanner_id)
  DETAIL
   rows_to_update_count = (rows_to_update_count+ 1)
  WITH nocounter, forupdate(s)
 ;end select
 IF (rows_to_update_count != scanner_rows)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 UPDATE  FROM cdi_scanner s,
   (dummyt d  WITH seq = scanner_rows)
  SET s.auto_correct_ind = request->scanners[d.seq].auto_correct_ind, s.brightness = request->
   scanners[d.seq].brightness, s.building_cd = request->scanners[d.seq].building_cd,
   s.contrast_cd = request->scanners[d.seq].contrast_cd, s.depth_cd = request->scanners[d.seq].
   depth_cd, s.duplex_ind = request->scanners[d.seq].duplex_ind,
   s.facility_cd = request->scanners[d.seq].facility_cd, s.jpeg_quality = request->scanners[d.seq].
   jpeg_quality, s.nurse_unit_cd = request->scanners[d.seq].nurse_unit_cd,
   s.orientation = request->scanners[d.seq].orientation, s.resolution_cd = request->scanners[d.seq].
   resolution_cd, s.room_cd = request->scanners[d.seq].room_cd,
   s.scanner_description = request->scanners[d.seq].scanner_description, s.scanner_ip_address =
   request->scanners[d.seq].scanner_ip_address, s.scanner_name = request->scanners[d.seq].
   scanner_name,
   s.scanner_path = request->scanners[d.seq].scanner_path, s.size_cd = request->scanners[d.seq].
   size_cd, s.timeout = request->scanners[d.seq].timeout,
   s.type_cd = request->scanners[d.seq].type_cd, s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt
    = (s.updt_cnt+ 1),
   s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo
   ->updt_task
  PLAN (d)
   JOIN (s
   WHERE (s.cdi_scanner_id=request->scanners[d.seq].cdi_scanner_id))
  WITH nocounter
 ;end update
 IF (curqual != scanner_rows)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
