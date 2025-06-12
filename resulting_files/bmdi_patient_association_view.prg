CREATE PROGRAM bmdi_patient_association_view
 DECLARE monid = vc
 DECLARE unit = vc
 DECLARE room = vc
 DECLARE bed = vc
 DECLARE pname = vc
 DECLARE pnum = f8
 DECLARE index = i2
 DECLARE unitsize = i2
 DECLARE unitindex = i2
 DECLARE roomsize = i2
 DECLARE roomindex = i2
 DECLARE bedsize = i2
 DECLARE bedindex = i2
 DECLARE custom_options = vc
 DECLARE room_cd = f8 WITH noconstant(0.0)
 DECLARE unit_cd = f8 WITH noconstant(0.0)
 DECLARE amb_cd = f8 WITH noconstant(0.0)
 DECLARE building_cd = f8 WITH noconstant(0.0)
 DECLARE facility_cd = f8 WITH noconstant(0.0)
 DECLARE nurse_unit_cd = f8 WITH noconstant(0.0)
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
 RECORD associationlist(
   1 unit_list[*]
     2 unit_cd = f8
     2 room_list[*]
       3 room_cd = f8
       3 bed_list[*]
         4 device_alias = c40
         4 device_cd = f8
         4 location_cd = f8
         4 association_id = f8
         4 association_dt_tm = dq8
         4 dis_association_dt_tm = dq8
         4 person_id = f8
         4 parent_entity_name = c32
         4 parent_entity_id = f8
         4 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET monid = ""
 SET unit = ""
 SET room = ""
 SET bed = ""
 SET pname = ""
 SET pnum = 0.0
 SET index = 0
 SET unitsize = 0
 SET unitindex = 0
 SET roomsize = 0
 SET roomindex = 0
 SET bedsize = 0
 SET bedindex = 0
 SELECT INTO "nl:"
  FROM strt_model_custom s
  WHERE s.strt_config_id=1282105
  DETAIL
   custom_options = s.custom_option
  WITH nocounter
 ;end select
 IF (substring(1,1,custom_options) != "1")
  SELECT DISTINCT INTO "nl:"
   unt_seq = lg3.sequence, rm_seq = lg2.sequence, bed_seq = lg1.sequence
   FROM bmdi_monitored_device bmd,
    bmdi_acquired_data_track badt,
    person p,
    location_group lg1,
    location_group lg2,
    location_group lg3
   PLAN (bmd
    WHERE bmd.location_cd > 0)
    JOIN (badt
    WHERE badt.device_cd=bmd.device_cd
     AND badt.location_cd=bmd.location_cd
     AND ((badt.active_ind=1
     AND ((badt.person_id > 0) OR (badt.parent_entity_id=0)) ) OR (((badt.person_id=0
     AND badt.active_ind=0
     AND badt.parent_entity_id=0) OR (badt.person_id=0
     AND badt.active_ind=1
     AND badt.parent_entity_id != 0)) )) )
    JOIN (p
    WHERE p.person_id=badt.person_id)
    JOIN (lg1
    WHERE lg1.child_loc_cd=badt.location_cd
     AND lg1.location_group_type_cd=room_cd
     AND lg1.active_ind=1
     AND lg1.root_loc_cd=0)
    JOIN (lg2
    WHERE lg2.child_loc_cd=lg1.parent_loc_cd
     AND lg2.location_group_type_cd IN (unit_cd, amb_cd)
     AND lg2.active_ind=1
     AND lg2.root_loc_cd=0)
    JOIN (lg3
    WHERE lg3.child_loc_cd=lg2.parent_loc_cd
     AND lg3.location_group_type_cd=building_cd
     AND lg3.active_ind=1
     AND lg3.root_loc_cd=0)
   ORDER BY unt_seq, lg3.child_loc_cd, rm_seq,
    lg2.child_loc_cd, bed_seq, lg1.child_loc_cd
   HEAD REPORT
    ucnt = 0, rcnt = 0, bcnt = 0,
    lined = fillstring(120,"="), col 0, "Monitor ID",
    col 21, "Unit", col 42,
    "Room", col 63, "Bed",
    col 84, "Person Name", col 105,
    "Person ID", row + 1, lined,
    row + 1
   DETAIL
    IF (nurse_unit_cd != lg2.parent_loc_cd)
     rcnt = 0, ucnt = (ucnt+ 1), stat = alterlist(associationlist->unit_list,ucnt),
     nurse_unit_cd = lg2.parent_loc_cd, associationlist->unit_list[ucnt].unit_cd = lg2.parent_loc_cd,
     room_cd = 0
    ENDIF
    IF (room_cd != lg1.parent_loc_cd)
     bcnt = 0, rcnt = (rcnt+ 1), stat = alterlist(associationlist->unit_list[ucnt].room_list,rcnt),
     associationlist->unit_list[ucnt].room_list[rcnt].room_cd = lg1.parent_loc_cd, room_cd = lg1
     .parent_loc_cd
    ENDIF
    bcnt = (bcnt+ 1), stat = alterlist(associationlist->unit_list[ucnt].room_list[rcnt].bed_list,bcnt
     ), associationlist->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].device_alias = bmd
    .device_alias,
    associationlist->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].device_cd = bmd.device_cd,
    associationlist->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].location_cd = bmd.location_cd,
    associationlist->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].association_id = badt
    .association_id,
    associationlist->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].association_dt_tm = badt
    .association_dt_tm, associationlist->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].
    dis_association_dt_tm = badt.dis_association_dt_tm
    IF (badt.person_id=0
     AND badt.active_ind=0
     AND badt.parent_entity_id=0)
     associationlist->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].person_id = 0, associationlist->
     unit_list[ucnt].room_list[rcnt].bed_list[bcnt].parent_entity_name = ""
    ELSE
     associationlist->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].person_id = badt.person_id,
     associationlist->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].parent_entity_name = p
     .name_full_formatted
    ENDIF
    associationlist->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].parent_entity_id = badt
    .parent_entity_id, associationlist->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].active_ind =
    badt.active_ind, col 0,
    monid, col 21, unit,
    col 42, room, col 63,
    bed, col 84, pname,
    col 105, pnum, row + 1
   WITH nocounter
  ;end select
 ELSE
  SELECT DISTINCT INTO "nl:"
   unt_seq = lg3.sequence, rm_seq = lg2.sequence, bed_seq = lg1.sequence
   FROM bmdi_monitored_device bmd,
    bmdi_acquired_data_track badt,
    person p,
    location_group lg1,
    location_group lg2,
    location_group lg3
   PLAN (bmd
    WHERE bmd.location_cd > 0)
    JOIN (badt
    WHERE badt.monitored_device_id=bmd.monitored_device_id
     AND ((badt.active_ind=1
     AND ((badt.person_id > 0) OR (badt.parent_entity_id=0)) ) OR (((badt.person_id=0
     AND badt.active_ind=0
     AND badt.parent_entity_id=0) OR (badt.person_id=0
     AND badt.active_ind=1
     AND badt.parent_entity_id != 0)) )) )
    JOIN (p
    WHERE p.person_id=badt.person_id)
    JOIN (lg1
    WHERE lg1.child_loc_cd=badt.location_cd
     AND lg1.location_group_type_cd=room_cd
     AND lg1.active_ind=1
     AND lg1.root_loc_cd=0)
    JOIN (lg2
    WHERE lg2.child_loc_cd=lg1.parent_loc_cd
     AND lg2.location_group_type_cd IN (unit_cd, amb_cd)
     AND lg2.active_ind=1
     AND lg2.root_loc_cd=0)
    JOIN (lg3
    WHERE lg3.child_loc_cd=lg2.parent_loc_cd
     AND lg3.location_group_type_cd=building_cd
     AND lg3.active_ind=1
     AND lg3.root_loc_cd=0)
   ORDER BY unt_seq, lg3.child_loc_cd, rm_seq,
    lg2.child_loc_cd, bed_seq, lg1.child_loc_cd
   HEAD REPORT
    ucnt = 0, rcnt = 0, bcnt = 0,
    lined = fillstring(120,"="), col 0, "Monitor ID",
    col 21, "Unit", col 42,
    "Room", col 63, "Bed",
    col 84, "Person Name", col 105,
    "Person ID", row + 1, lined,
    row + 1
   DETAIL
    IF (nurse_unit_cd != lg2.parent_loc_cd)
     rcnt = 0, ucnt = (ucnt+ 1), stat = alterlist(associationlist->unit_list,ucnt),
     nurse_unit_cd = lg2.parent_loc_cd, associationlist->unit_list[ucnt].unit_cd = lg2.parent_loc_cd,
     room_cd = 0
    ENDIF
    IF (room_cd != lg1.parent_loc_cd)
     bcnt = 0, rcnt = (rcnt+ 1), stat = alterlist(associationlist->unit_list[ucnt].room_list,rcnt),
     associationlist->unit_list[ucnt].room_list[rcnt].room_cd = lg1.parent_loc_cd, room_cd = lg1
     .parent_loc_cd
    ENDIF
    bcnt = (bcnt+ 1), stat = alterlist(associationlist->unit_list[ucnt].room_list[rcnt].bed_list,bcnt
     ), associationlist->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].device_alias = bmd
    .device_alias,
    associationlist->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].device_cd = bmd.device_cd,
    associationlist->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].location_cd = bmd.location_cd,
    associationlist->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].association_id = badt
    .association_id,
    associationlist->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].association_dt_tm = badt
    .association_dt_tm, associationlist->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].
    dis_association_dt_tm = badt.dis_association_dt_tm
    IF (((badt.person_id=0) OR (badt.active_ind=0)) )
     associationlist->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].person_id = 0, associationlist->
     unit_list[ucnt].room_list[rcnt].bed_list[bcnt].parent_entity_name = ""
    ELSE
     associationlist->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].person_id = badt.person_id,
     associationlist->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].parent_entity_name = p
     .name_full_formatted
    ENDIF
    associationlist->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].parent_entity_id = badt
    .parent_entity_id, associationlist->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].active_ind =
    badt.active_ind, col 0,
    monid, col 21, unit,
    col 42, room, col 63,
    bed, col 84, pname,
    col 105, pnum, row + 1
   WITH nocounter
  ;end select
 ENDIF
 SET index = 0
 SET unitsize = 0
 SET unitindex = 0
 SET roomsize = 0
 SET roomindex = 0
 SET bedsize = 0
 SET bedindex = 0
 SELECT
  FROM (dummyt d1  WITH seq = value(index))
  HEAD REPORT
   lined = fillstring(120,"="), col 0, "Monitor ID",
   col 21, "Unit", col 42,
   "Room", col 63, "Bed",
   col 84, "Person Name", col 105,
   "Person ID", row + 1, lined,
   row + 1
  DETAIL
   unitsize = size(associationlist->unit_list,5)
   FOR (unitindex = 1 TO unitsize)
     unit = substring(0,20,uar_get_code_display(associationlist->unit_list[unitindex].unit_cd)),
     roomsize = size(associationlist->unit_list[unitindex].room_list,5)
     FOR (roomindex = 1 TO roomsize)
       room = substring(0,20,uar_get_code_display(associationlist->unit_list[unitindex].room_list[
         roomindex].room_cd)), bedsize = size(associationlist->unit_list[unitindex].room_list[
        roomindex].bed_list,5)
       FOR (bedindex = 1 TO bedsize)
         monid = substring(0,20,associationlist->unit_list[unitindex].room_list[roomindex].bed_list[
          bedindex].device_alias), bed = substring(0,20,uar_get_code_display(associationlist->
           unit_list[unitindex].room_list[roomindex].bed_list[bedindex].location_cd))
         IF ((associationlist->unit_list[unitindex].room_list[roomindex].bed_list[bedindex].person_id
          > 0))
          pnum = associationlist->unit_list[unitindex].room_list[roomindex].bed_list[bedindex].
          person_id, pname = associationlist->unit_list[unitindex].room_list[roomindex].bed_list[
          bedindex].parent_entity_name
         ELSE
          pnum = 0, pname = ""
         ENDIF
         col 0, monid, col 21,
         unit, col 42, room,
         col 63, bed, col 84,
         pname, col 105, pnum,
         row + 1
       ENDFOR
     ENDFOR
   ENDFOR
  WITH nocounter
 ;end select
END GO
