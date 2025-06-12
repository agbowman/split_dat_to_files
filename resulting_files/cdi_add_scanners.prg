CREATE PROGRAM cdi_add_scanners
 IF (validate(reply)=0)
  RECORD reply(
    1 scanners[*]
      2 cdi_scanner_id = f8
    1 err_msg = vc
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
 DECLARE err_msg = vc WITH noconstant(" "), protect
 SET reply->status_data.status = "F"
 IF (scanner_rows > 0)
  SELECT INTO "NL:"
   FROM cdi_scanner s
   WHERE expand(num,1,scanner_rows,s.scanner_name,request->scanners[num].scanner_name)
   HEAD REPORT
    count = 0
   DETAIL
    count = (count+ 1)
    IF (count > 1)
     err_msg = build2(err_msg,", ")
    ENDIF
    err_msg = build2(err_msg,trim(request->scanners[num].scanner_name))
   FOOT REPORT
    IF (count > 1)
     err_msg = build2("Error adding scanners. Scanner names already exist: ",err_msg,".")
    ELSE
     err_msg = build2("Error adding scanner. Scanner name already exists: ",err_msg,".")
    ENDIF
   WITH nocounter
  ;end select
  IF (count > 0)
   SET reply->err_msg = err_msg
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
  INSERT  FROM (dummyt d  WITH seq = scanner_rows),
    cdi_scanner s
   SET s.cdi_scanner_id = seq(cdi_seq,nextval), s.scanner_name = request->scanners[d.seq].
    scanner_name, s.scanner_ip_address = request->scanners[d.seq].scanner_ip_address,
    s.scanner_description = request->scanners[d.seq].scanner_description, s.room_cd = request->
    scanners[d.seq].room_cd, s.nurse_unit_cd = request->scanners[d.seq].nurse_unit_cd,
    s.building_cd = request->scanners[d.seq].building_cd, s.facility_cd = request->scanners[d.seq].
    facility_cd, s.scanner_path = request->scanners[d.seq].scanner_path,
    s.timeout = request->scanners[d.seq].timeout, s.resolution_cd = request->scanners[d.seq].
    resolution_cd, s.type_cd = request->scanners[d.seq].type_cd,
    s.jpeg_quality = request->scanners[d.seq].jpeg_quality, s.depth_cd = request->scanners[d.seq].
    depth_cd, s.size_cd = request->scanners[d.seq].size_cd,
    s.orientation = request->scanners[d.seq].orientation, s.duplex_ind = request->scanners[d.seq].
    duplex_ind, s.brightness = request->scanners[d.seq].brightness,
    s.contrast_cd = request->scanners[d.seq].contrast_cd, s.auto_correct_ind = request->scanners[d
    .seq].auto_correct_ind, s.updt_applctx = reqinfo->updt_applctx,
    s.updt_cnt = 0, s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id,
    s.updt_task = reqinfo->updt_task
   PLAN (d)
    JOIN (s)
   WITH nocounter
  ;end insert
  IF (curqual != scanner_rows)
   GO TO exit_script
  ENDIF
  SELECT INTO "NL:"
   FROM cdi_scanner s
   WHERE expand(num,1,scanner_rows,s.scanner_name,request->scanners[num].scanner_name)
   HEAD REPORT
    stat = alterlist(reply->scanners,scanner_rows)
   DETAIL
    reply->scanners[num].cdi_scanner_id = s.cdi_scanner_id
   WITH nocounter
  ;end select
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
