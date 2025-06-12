CREATE PROGRAM bed_get_coll_cntnr_info:dba
 FREE SET reply
 RECORD reply(
   1 containers[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
     2 mean = vc
     2 aliquot_ind = i2
     2 volume_units
       3 code_value = f8
       3 display = vc
     2 volumes[*]
       3 volume = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET ccnt = 0
 SELECT INTO "NL:"
  FROM code_value cv1,
   specimen_container sc,
   specimen_container_volume sv,
   code_value cv2
  PLAN (cv1
   WHERE cv1.code_set=2051
    AND cv1.active_ind=1)
   JOIN (sc
   WHERE sc.spec_cntnr_cd=cv1.code_value)
   JOIN (cv2
   WHERE cv2.code_value=sc.volume_units_cd
    AND cv2.active_ind=1)
   JOIN (sv
   WHERE sv.spec_cntnr_cd=sc.spec_cntnr_cd)
  ORDER BY cv1.code_value
  HEAD cv1.code_value
   ccnt = (ccnt+ 1), stat = alterlist(reply->containers,ccnt), reply->containers[ccnt].code_value =
   cv1.code_value,
   reply->containers[ccnt].display = cv1.display, reply->containers[ccnt].description = cv1
   .description, reply->containers[ccnt].mean = cv1.cdf_meaning,
   reply->containers[ccnt].aliquot_ind = sc.aliquot_ind, reply->containers[ccnt].volume_units.
   code_value = sc.volume_units_cd, reply->containers[ccnt].volume_units.display = cv2.display,
   vcnt = 0
  DETAIL
   vcnt = (vcnt+ 1), stat = alterlist(reply->containers[ccnt].volumes,vcnt), reply->containers[ccnt].
   volumes[vcnt].volume = sv.volume
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
