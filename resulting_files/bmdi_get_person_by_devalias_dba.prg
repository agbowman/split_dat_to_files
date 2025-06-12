CREATE PROGRAM bmdi_get_person_by_devalias:dba
 RECORD reply(
   1 assoc_list[*]
     2 person_id = f8
     2 name_full_formatted = c100
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
 SELECT DISTINCT INTO "nl:"
  FROM bmdi_monitored_device bmd,
   bmdi_acquired_data_track badt,
   person p,
   location_group lg1,
   location_group lg2,
   location_group lg3,
   location_group lg4
  PLAN (bmd
   WHERE (bmd.device_alias=request->device_alias))
   JOIN (badt
   WHERE badt.device_cd=bmd.device_cd
    AND badt.location_cd=bmd.location_cd
    AND badt.active_ind=1
    AND badt.person_id > 0)
   JOIN (p
   WHERE p.person_id=badt.person_id)
   JOIN (lg1
   WHERE lg1.child_loc_cd=outerjoin(badt.location_cd)
    AND lg1.location_group_type_cd=outerjoin(room_cd)
    AND lg1.active_ind=outerjoin(1))
   JOIN (lg2
   WHERE lg2.child_loc_cd=outerjoin(lg1.parent_loc_cd)
    AND lg2.location_group_type_cd IN (outerjoin(unit_cd), outerjoin(amb_cd))
    AND lg2.active_ind=outerjoin(1))
   JOIN (lg3
   WHERE lg3.child_loc_cd=outerjoin(lg2.parent_loc_cd)
    AND lg3.location_group_type_cd=outerjoin(building_cd)
    AND lg3.active_ind=outerjoin(1))
   JOIN (lg4
   WHERE lg4.child_loc_cd=outerjoin(lg3.parent_loc_cd)
    AND lg4.location_group_type_cd=outerjoin(facility_cd)
    AND lg4.active_ind=outerjoin(1))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->assoc_list,(cnt+ 9))
   ENDIF
   reply->assoc_list[cnt].person_id = badt.person_id, reply->assoc_list[cnt].name_full_formatted = p
   .name_full_formatted, reply->assoc_list[cnt].bed_cd = badt.location_cd,
   reply->assoc_list[cnt].bed_display = uar_get_code_display(badt.location_cd), reply->assoc_list[cnt
   ].room_cd = lg1.parent_loc_cd, reply->assoc_list[cnt].room_display = uar_get_code_display(lg1
    .parent_loc_cd),
   reply->assoc_list[cnt].unit_cd = lg2.parent_loc_cd, reply->assoc_list[cnt].unit_display =
   uar_get_code_display(lg2.parent_loc_cd), reply->assoc_list[cnt].building_cd = lg3.parent_loc_cd,
   reply->assoc_list[cnt].building_display = uar_get_code_display(lg3.parent_loc_cd), reply->
   assoc_list[cnt].facility_cd = lg4.parent_loc_cd, reply->assoc_list[cnt].facility_display =
   uar_get_code_display(lg4.parent_loc_cd),
   reply->assoc_list[cnt].association_dt_tm = cnvtdatetime(badt.association_dt_tm)
  FOOT REPORT
   stat = alterlist(reply->assoc_list,cnt)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
