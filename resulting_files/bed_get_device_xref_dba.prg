CREATE PROGRAM bed_get_device_xref:dba
 FREE SET reply
 RECORD reply(
   01 destinations[*]
     02 code_value = f8
     02 display = vc
     02 description = vc
     02 mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET odcnt = 0
 SET printer_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=3000
    AND cv.cdf_meaning="PRINTER")
  DETAIL
   printer_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM device_xref dx,
   output_dest od
  PLAN (dx
   WHERE dx.parent_entity_name="LOCATION"
    AND (dx.parent_entity_id=request->location_code_value)
    AND dx.usage_type_cd=printer_cd)
   JOIN (od
   WHERE od.device_cd=dx.device_cd
    AND od.name > " ")
  ORDER BY od.name
  HEAD REPORT
   odcnt = 0
  HEAD od.name
   odcnt = (odcnt+ 1), stat = alterlist(reply->destinations,odcnt), reply->destinations[odcnt].
   code_value = od.output_dest_cd,
   reply->destinations[odcnt].display = od.name, reply->destinations[odcnt].description = od
   .description
  WITH nocounter
 ;end select
 IF (odcnt > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = odcnt),
    code_value cv
   PLAN (d)
    JOIN (cv
    WHERE (cv.code_value=reply->destinations[d.seq].code_value))
   DETAIL
    reply->destinations[d.seq].mean = cv.cdf_meaning
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (odcnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
