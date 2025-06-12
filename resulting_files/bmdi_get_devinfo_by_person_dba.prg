CREATE PROGRAM bmdi_get_devinfo_by_person:dba
 RECORD reply(
   1 assoc_list[*]
     2 device_alias = c40
     2 facility_cd = f8
     2 facility_display = c40
     2 building_cd = f8
     2 building_display = c40
     2 unit_cd = f8
     2 unit_display = c40
     2 room_cd = f8
     2 room_display = c40
     2 bed_cd = f8
     2 bed_display = c40
     2 association_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE custom_options = vc
 DECLARE fetaldeviceind = i2
 DECLARE fetal_mon_cd = f8
 SET reply->status_data.status = "F"
 SET room_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(222,"ROOM",1,room_cd)
 SET unit_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(222,"NURSEUNIT",1,unit_cd)
 SET amb_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(222,"AMBULATORY",1,amb_cd)
 SET building_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(222,"BUILDING",1,building_cd)
 SET facility_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(222,"FACILITY",1,facility_cd)
 SET fetaldeviceind = 0
 SET fetal_mon_cd = uar_get_code_by("DISPLAYKEY",4002330,"FETALMONITOR")
 SELECT INTO "nl:"
  FROM strt_model_custom smc
  WHERE smc.strt_model_id=0
   AND smc.strt_config_id=1282154
   AND process_flag=10
  DETAIL
   custom_options = smc.custom_option
  WITH nocounter
 ;end select
 IF (curqual=1)
  IF (size(custom_options,1)=2)
   CALL echo(build("The display option is = ",custom_options))
   IF (custom_options="01")
    SET fetaldeviceind = 1
   ENDIF
  ENDIF
 ENDIF
 SELECT
  IF (fetaldeviceind=1)DISTINCT INTO "nl:"
   FROM bmdi_acquired_data_track badt,
    bmdi_monitored_device bmd,
    location_group lg1,
    code_value cv1,
    location_group lg2,
    code_value cv2,
    location_group lg3,
    code_value cv3,
    location_group lg4,
    code_value cv4
   PLAN (badt
    WHERE (badt.person_id=request->person_id)
     AND badt.active_ind=1)
    JOIN (bmd
    WHERE bmd.device_cd=badt.device_cd
     AND bmd.location_cd=badt.location_cd
     AND bmd.device_type_cd != fetal_mon_cd)
    JOIN (lg1
    WHERE lg1.child_loc_cd=outerjoin(badt.location_cd)
     AND lg1.location_group_type_cd=outerjoin(room_cd)
     AND lg1.active_ind=outerjoin(1))
    JOIN (cv1
    WHERE cv1.code_value=lg1.parent_loc_cd)
    JOIN (lg2
    WHERE lg2.child_loc_cd=outerjoin(lg1.parent_loc_cd)
     AND lg2.location_group_type_cd IN (outerjoin(unit_cd), outerjoin(amb_cd))
     AND lg2.active_ind=outerjoin(1))
    JOIN (cv2
    WHERE cv2.code_value=lg2.parent_loc_cd)
    JOIN (lg3
    WHERE lg3.child_loc_cd=outerjoin(lg2.parent_loc_cd)
     AND lg3.location_group_type_cd=outerjoin(building_cd)
     AND lg3.active_ind=outerjoin(1))
    JOIN (cv3
    WHERE cv3.code_value=lg3.parent_loc_cd)
    JOIN (lg4
    WHERE lg4.child_loc_cd=outerjoin(lg3.parent_loc_cd)
     AND lg4.location_group_type_cd=outerjoin(facility_cd)
     AND lg4.active_ind=outerjoin(1))
    JOIN (cv4
    WHERE cv4.code_value=lg4.parent_loc_cd)
  ELSE DISTINCT INTO "nl:"
   FROM bmdi_acquired_data_track badt,
    bmdi_monitored_device bmd,
    location_group lg1,
    code_value cv1,
    location_group lg2,
    code_value cv2,
    location_group lg3,
    code_value cv3,
    location_group lg4,
    code_value cv4
   PLAN (badt
    WHERE (badt.person_id=request->person_id)
     AND badt.active_ind=1)
    JOIN (bmd
    WHERE bmd.device_cd=badt.device_cd
     AND bmd.location_cd=badt.location_cd)
    JOIN (lg1
    WHERE lg1.child_loc_cd=outerjoin(badt.location_cd)
     AND lg1.location_group_type_cd=outerjoin(room_cd)
     AND lg1.active_ind=outerjoin(1))
    JOIN (cv1
    WHERE cv1.code_value=lg1.parent_loc_cd)
    JOIN (lg2
    WHERE lg2.child_loc_cd=outerjoin(lg1.parent_loc_cd)
     AND lg2.location_group_type_cd IN (outerjoin(unit_cd), outerjoin(amb_cd))
     AND lg2.active_ind=outerjoin(1))
    JOIN (cv2
    WHERE cv2.code_value=lg2.parent_loc_cd)
    JOIN (lg3
    WHERE lg3.child_loc_cd=outerjoin(lg2.parent_loc_cd)
     AND lg3.location_group_type_cd=outerjoin(building_cd)
     AND lg3.active_ind=outerjoin(1))
    JOIN (cv3
    WHERE cv3.code_value=lg3.parent_loc_cd)
    JOIN (lg4
    WHERE lg4.child_loc_cd=outerjoin(lg3.parent_loc_cd)
     AND lg4.location_group_type_cd=outerjoin(facility_cd)
     AND lg4.active_ind=outerjoin(1))
    JOIN (cv4
    WHERE cv4.code_value=lg4.parent_loc_cd)
  ENDIF
  HEAD REPORT
   cnt = 0
  DETAIL
   IF (cv1.active_ind=1
    AND cv2.active_ind=1
    AND cv3.active_ind=1
    AND cv4.active_ind=1)
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(reply->assoc_list,(cnt+ 9))
    ENDIF
    reply->assoc_list[cnt].device_alias = bmd.device_alias, reply->assoc_list[cnt].bed_cd = badt
    .location_cd, reply->assoc_list[cnt].bed_display = uar_get_code_display(badt.location_cd),
    reply->assoc_list[cnt].room_cd = lg1.parent_loc_cd, reply->assoc_list[cnt].room_display =
    uar_get_code_display(lg1.parent_loc_cd), reply->assoc_list[cnt].unit_cd = lg2.parent_loc_cd,
    reply->assoc_list[cnt].unit_display = uar_get_code_display(lg2.parent_loc_cd), reply->assoc_list[
    cnt].building_cd = lg3.parent_loc_cd, reply->assoc_list[cnt].building_display =
    uar_get_code_display(lg3.parent_loc_cd),
    reply->assoc_list[cnt].facility_cd = lg4.parent_loc_cd, reply->assoc_list[cnt].facility_display
     = uar_get_code_display(lg4.parent_loc_cd), reply->assoc_list[cnt].association_dt_tm =
    cnvtdatetime(badt.association_dt_tm)
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->assoc_list,cnt)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
