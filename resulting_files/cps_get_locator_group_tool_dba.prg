CREATE PROGRAM cps_get_locator_group_tool:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 location_qual = i4
    1 location[0]
      2 locator_area_id = f8
      2 location_cd = f8
      2 location_disp = c40
      2 location_desc = c60
      2 location_mean = c12
      2 caption = vc
      2 alert_time = i4
      2 style = i4
      2 top = i4
      2 left = i4
      2 right = i4
      2 bottom = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM locator_view_area_r lvar,
   locator_area la
  PLAN (lvar
   WHERE (lvar.locator_view_cd=request->locator_view_cd))
   JOIN (la
   WHERE la.locator_area_id=lvar.locator_area_id)
  HEAD REPORT
   lockount = 0
  DETAIL
   lockount = (lockount+ 1)
   IF (mod(lockount,10)=1)
    stat = alter(reply->location,(lockount+ 10))
   ENDIF
   reply->location[lockount].location_cd = la.location_cd, reply->location[lockount].caption = la
   .caption, reply->location[lockount].alert_time = la.alert_time,
   reply->location[lockount].style = la.style, reply->location[lockount].top = la.top, reply->
   location[lockount].left = la.left,
   reply->location[lockount].right = la.right, reply->location[lockount].bottom = la.bottom
  FOOT REPORT
   stat = alter(reply->location,lockount), reply->location_qual = lockount
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "LOCATOR_AREA"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
 ELSEIF ((reply->location_qual < 1))
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET cps_script_version = "002 02/06/04 SF3151"
END GO
