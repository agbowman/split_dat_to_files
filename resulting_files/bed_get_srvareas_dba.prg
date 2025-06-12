CREATE PROGRAM bed_get_srvareas:dba
 FREE SET reply
 RECORD reply(
   1 srvareas[*]
     2 code_value = f8
     2 disp = vc
     2 mean = vc
     2 assign_ind = i2
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
 DECLARE radiology = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=222
    AND cv.cdf_meaning="SRVAREA")
  DETAIL
   srvarea = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="RADIOLOGY")
  DETAIL
   radiology = cv.code_value
  WITH nocounter
 ;end select
 SET cnt = 0
 IF ((request->show_all_srvareas_ind=1))
  SELECT INTO "nl:"
   FROM location l,
    code_value cv
   PLAN (l
    WHERE l.location_type_cd=srvarea
     AND l.discipline_type_cd=radiology
     AND l.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=l.location_cd
     AND cv.active_ind=1)
   ORDER BY cv.display
   HEAD l.location_cd
    cnt = (cnt+ 1), stat = alterlist(reply->srvareas,cnt), reply->srvareas[cnt].code_value = l
    .location_cd,
    reply->srvareas[cnt].disp = cv.display, reply->srvareas[cnt].mean = cv.cdf_meaning
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM location l,
    code_value cv
   PLAN (l
    WHERE (l.organization_id=request->organization_id)
     AND l.location_type_cd=srvarea
     AND l.discipline_type_cd=radiology
     AND l.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=l.location_cd
     AND cv.active_ind=1)
   ORDER BY cv.display
   HEAD l.location_cd
    cnt = (cnt+ 1), stat = alterlist(reply->srvareas,cnt), reply->srvareas[cnt].code_value = l
    .location_cd,
    reply->srvareas[cnt].disp = cv.display, reply->srvareas[cnt].mean = cv.cdf_meaning
   WITH nocounter
  ;end select
 ENDIF
 IF (size(reply->srvareas,5)=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(reply->srvareas,5))),
   location_group lg
  PLAN (d)
   JOIN (lg
   WHERE (lg.parent_loc_cd=reply->srvareas[d.seq].code_value)
    AND lg.active_ind=1)
  ORDER BY d.seq
  HEAD d.seq
   reply->srvareas[d.seq].assign_ind = 1
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 IF (size(reply->srvareas,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
