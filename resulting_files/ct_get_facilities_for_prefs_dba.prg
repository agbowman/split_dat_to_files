CREATE PROGRAM ct_get_facilities_for_prefs:dba
 RECORD reply(
   1 qual[*]
     2 value = f8
     2 name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE fac_cnt = i2 WITH protect, noconstant(0)
 DECLARE serror = vc WITH protect, noconstant("")
 DECLARE facility_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"FACILITY"))
 SELECT DISTINCT INTO "NL:"
  item_display = f.display, item_keyvalue = f.code_value
  FROM code_value f,
   location_group lg,
   location l
  PLAN (lg
   WHERE lg.location_group_type_cd=facility_cd
    AND lg.active_ind=1)
   JOIN (f
   WHERE f.code_value=lg.parent_loc_cd
    AND f.cdf_meaning="FACILITY"
    AND f.active_ind=1)
   JOIN (l
   WHERE l.location_cd=f.code_value)
  ORDER BY cnvtupper(f.display)
  HEAD REPORT
   fac_cnt = 0
  DETAIL
   fac_cnt = (fac_cnt+ 1)
   IF (mod(fac_cnt,10)=1)
    stat = alterlist(reply->qual,(fac_cnt+ 9))
   ENDIF
   reply->qual[fac_cnt].name = f.display, reply->qual[fac_cnt].value = f.code_value
  FOOT REPORT
   stat = alterlist(reply->qual,fac_cnt)
  WITH nocounter
 ;end select
 IF (error(serror,0) > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serror
 ELSEIF (fac_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "001"
 SET mod_date = "March 31, 2009"
END GO
