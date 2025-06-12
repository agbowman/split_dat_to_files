CREATE PROGRAM bed_get_unassigned_prntrs:dba
 FREE SET reply
 RECORD reply(
   01 error_msg = vc
   01 odlist[*]
     02 output_dest_cd = f8
     02 name = vc
     02 description = vc
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
  FROM output_dest od
  PLAN (od
   WHERE od.name > " "
    AND  NOT (od.device_cd IN (
   (SELECT DISTINCT
    dx.device_cd
    FROM device_xref dx
    WHERE dx.parent_entity_name="LOCATION"
     AND dx.usage_type_cd=printer_cd))))
  ORDER BY od.name
  HEAD REPORT
   odcnt = 0
  DETAIL
   odcnt = (odcnt+ 1), stat = alterlist(reply->odlist,odcnt), reply->odlist[odcnt].output_dest_cd =
   od.output_dest_cd,
   reply->odlist[odcnt].name = od.name, reply->odlist[odcnt].description = od.description
  WITH nocounter
 ;end select
#exit_script
 IF (odcnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
