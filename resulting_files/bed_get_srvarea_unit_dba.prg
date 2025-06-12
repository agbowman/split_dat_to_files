CREATE PROGRAM bed_get_srvarea_unit:dba
 FREE SET reply
 RECORD reply(
   1 srvareaunits[*]
     2 code_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE srvarea = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=222
    AND cv.cdf_meaning="SRVAREA")
  DETAIL
   srvarea = cv.code_value
  WITH nocounter
 ;end select
 SET rad_cat_cd = 0
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.active_ind=1
    AND cv.cdf_meaning="RADIOLOGY")
  DETAIL
   rad_cat_cd = cv.code_value
  WITH nocounter
 ;end select
 SET cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(request->locunits,5))),
   location_group lg,
   location l
  PLAN (d)
   JOIN (lg
   WHERE (lg.child_loc_cd=request->locunits[d.seq].code_value)
    AND lg.location_group_type_cd=srvarea
    AND lg.active_ind=1)
   JOIN (l
   WHERE l.location_cd=lg.parent_loc_cd
    AND l.discipline_type_cd=rad_cat_cd)
  ORDER BY lg.child_loc_cd
  HEAD lg.child_loc_cd
   cnt = (cnt+ 1), stat = alterlist(reply->srvareaunits,cnt), reply->srvareaunits[cnt].code_value =
   lg.child_loc_cd
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 IF (size(reply->srvareaunits,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
