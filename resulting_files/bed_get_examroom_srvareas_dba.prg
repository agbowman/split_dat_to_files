CREATE PROGRAM bed_get_examroom_srvareas:dba
 FREE SET reply
 RECORD reply(
   1 srvareas[*]
     2 code_value = f8
     2 disp = vc
     2 mean = vc
     2 assign_ind = i2
     2 discipline_type
       3 code_value = f8
       3 disp = vc
       3 mean = vc
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
 SET cnt = 0
 SELECT INTO "nl:"
  FROM location l,
   code_value cv1,
   code_value cv2
  PLAN (l
   WHERE l.location_type_cd=srvarea
    AND l.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_value=l.location_cd
    AND cv1.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=l.discipline_type_cd)
  ORDER BY l.location_cd
  HEAD l.location_cd
   cnt = (cnt+ 1), stat = alterlist(reply->srvareas,cnt), reply->srvareas[cnt].code_value = l
   .location_cd,
   reply->srvareas[cnt].disp = cv1.display, reply->srvareas[cnt].mean = cv1.cdf_meaning, reply->
   srvareas[cnt].discipline_type.code_value = cv2.code_value,
   reply->srvareas[cnt].discipline_type.disp = cv2.display, reply->srvareas[cnt].discipline_type.mean
    = cv2.cdf_meaning
  WITH nocounter
 ;end select
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
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
 SET reply->status_data.status = "S"
END GO
