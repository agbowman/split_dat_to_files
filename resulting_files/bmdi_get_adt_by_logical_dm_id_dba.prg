CREATE PROGRAM bmdi_get_adt_by_logical_dm_id:dba
 SET reply->status_data.status = "F"
 SET sfailed = "S"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = 0
 SET sall = 0
 DECLARE nurse_unit_cd = f8 WITH noconstant(0.0)
 DECLARE room_cd = f8 WITH noconstant(0.0)
 DECLARE fac_seq = f8 WITH noconstant(0.0)
 DECLARE loc_mean = c13 WITH private, noconstant("")
 DECLARE mon_id = f8 WITH noconstant(0.0)
 SET loc_mean = uar_get_code_meaning(request->unit_cd)
 DECLARE display_options = vc
 DECLARE hide_fetal = i2
 DECLARE fetal_mon_cd = f8
 SET hide_fetal = 0
 SET fetal_mon_cd = uar_get_code_by("DISPLAYKEY",4002330,"FETALMONITOR")
 CALL echo("Executing bmdi_get_adt_by_logical_dm_id")
 CALL echorecord(request)
 SELECT INTO "nl:"
  FROM strt_model_custom smc
  WHERE smc.strt_model_id=0
   AND smc.strt_config_id=1282103
   AND smc.process_flag=10
  DETAIL
   custom_options = smc.custom_option
  WITH nocounter
 ;end select
 IF (curqual=1)
  IF (substring(1,1,custom_options)="1")
   IF ((request->facility_ind=1)
    AND (request->unit_cd > 0))
    SET request->unit_cd = 0
    CALL echo("Fetch monitors across all facilities")
   ELSE
    CALL echo("Fetch monitors from the facility to which the nurseunit belongs")
   ENDIF
  ENDIF
 ELSE
  CALL echo("row doesn't exist for all facilities")
 ENDIF
 SELECT INTO "nl:"
  FROM strt_model_custom smc
  WHERE smc.strt_model_id=0
   AND smc.strt_config_id=1282154
   AND process_flag=10
  DETAIL
   display_options = smc.custom_option
  WITH nocounter
 ;end select
 IF (curqual=1)
  IF (size(display_options,1)=2)
   CALL echo(build("The display option is = ",display_options))
   IF (display_options="01")
    SET hide_fetal = 1
   ENDIF
  ENDIF
 ENDIF
 CALL echo(build("loc_mean: ",loc_mean))
 SET def_facility_cd = 0.0
 IF ((request->facility_ind=1)
  AND (request->unit_cd > 0))
  IF (cnvtupper(trim(loc_mean))="FACILITY")
   SET def_facility_cd = request->unit_cd
  ELSEIF (cnvtupper(trim(loc_mean))="BUILDING")
   SELECT INTO "nl:"
    FROM location_group lg
    PLAN (lg
     WHERE (lg.child_loc_cd=request->unit_cd)
      AND lg.root_loc_cd=0
      AND lg.active_ind=1)
    DETAIL
     def_facility_cd = lg.parent_loc_cd
    WITH nocounter
   ;end select
  ELSEIF (((cnvtupper(trim(loc_mean))="NURSEUNIT") OR (cnvtupper(trim(loc_mean))="AMBULATORY")) )
   SELECT INTO "nl:"
    FROM location_group lg,
     location_group lg1
    PLAN (lg
     WHERE (lg.child_loc_cd=request->unit_cd)
      AND lg.root_loc_cd=0
      AND lg.active_ind=1)
     JOIN (lg1
     WHERE lg1.child_loc_cd=lg.parent_loc_cd
      AND lg1.location_group_type_cd=facilitytypecd
      AND lg1.root_loc_cd=0
      AND lg1.active_ind=1)
    DETAIL
     def_facility_cd = lg1.parent_loc_cd
    WITH nocounter
   ;end select
  ELSEIF (cnvtupper(trim(loc_mean))="ROOM")
   SELECT INTO "nl:"
    FROM location_group lg,
     location_group lg1,
     location_group lg2
    PLAN (lg
     WHERE (lg.child_loc_cd=request->unit_cd)
      AND lg.root_loc_cd=0
      AND lg.active_ind=1)
     JOIN (lg1
     WHERE lg1.child_loc_cd=lg.parent_loc_cd
      AND lg1.root_loc_cd=0
      AND lg1.active_ind=1)
     JOIN (lg2
     WHERE lg2.child_loc_cd=lg1.parent_loc_cd
      AND lg2.location_group_type_cd=facilitytypecd
      AND lg2.root_loc_cd=0
      AND lg2.active_ind=1)
    DETAIL
     def_facility_cd = lg2.parent_loc_cd
    WITH nocounter
   ;end select
  ELSEIF (cnvtupper(trim(loc_mean))="BED")
   SELECT INTO "nl:"
    FROM location_group lg,
     location_group lg1,
     location_group lg2,
     location_group lg3
    PLAN (lg
     WHERE (lg.child_loc_cd=request->unit_cd)
      AND lg.root_loc_cd=0
      AND lg.active_ind=1)
     JOIN (lg1
     WHERE lg1.child_loc_cd=lg.parent_loc_cd
      AND lg1.root_loc_cd=0
      AND lg1.active_ind=1)
     JOIN (lg2
     WHERE lg2.child_loc_cd=lg1.parent_loc_cd
      AND lg2.root_loc_cd=0
      AND lg2.active_ind=1)
     JOIN (lg3
     WHERE lg3.child_loc_cd=lg2.parent_loc_cd
      AND lg3.location_group_type_cd=facilitytypecd
      AND lg3.root_loc_cd=0
      AND lg3.active_ind=1)
    DETAIL
     def_facility_cd = lg3.parent_loc_cd
    WITH nocounter
   ;end select
  ELSEIF (substring(1,1,custom_options)="1")
   SET request->unit_cd = 0
  ELSE
   GO TO invalid
  ENDIF
 ENDIF
 CALL echo(build("facility_cd: ",cnvtstring(def_facility_cd)))
 CALL echo(build("unit_cd: ",cnvtstring(request->unit_cd)))
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
 SET level = - (1)
 IF ((request->unit_cd > 0))
  IF (((cnvtupper(trim(loc_mean))="FACILITY") OR ((request->facility_ind=1))) )
   SET level = 0
   CALL echo("Will show all devices for this facility")
  ELSEIF (cnvtupper(trim(loc_mean))="BUILDING")
   SET level = 1
  ELSEIF (((cnvtupper(trim(loc_mean))="NURSEUNIT") OR (cnvtupper(trim(loc_mean))="AMBULATORY")) )
   SET level = 2
  ELSEIF (cnvtupper(trim(loc_mean))="ROOM")
   SET level = 3
  ELSEIF (cnvtupper(trim(loc_mean))="BED")
   SET level = 4
  ELSE
   GO TO invalid
  ENDIF
 ENDIF
 SELECT
  IF (hide_fetal=1)DISTINCT INTO "nl:"
   fac_seq = lg4.parent_loc_cd, bld_seq = lg4.sequence, unt_seq = lg3.sequence,
   rm_seq = lg2.sequence, bed_seq = lg1.sequence, mon_id = bmd.monitored_device_id
   FROM bmdi_monitored_device bmd,
    bmdi_acquired_data_track badt,
    person p,
    location_group lg1,
    location_group lg2,
    location_group lg3,
    location_group lg4,
    organization og,
    location lt,
    prsnl pn
   PLAN (bmd
    WHERE bmd.location_cd > 0
     AND bmd.device_type_cd != fetal_mon_cd)
    JOIN (badt
    WHERE badt.device_cd=bmd.device_cd
     AND badt.location_cd=bmd.location_cd
     AND badt.monitored_device_id=bmd.monitored_device_id
     AND ((badt.active_ind=1
     AND ((badt.person_id > 0) OR (badt.parent_entity_id=0)) ) OR (((badt.person_id=0
     AND badt.active_ind=0
     AND badt.parent_entity_id=0) OR (badt.person_id=0
     AND badt.active_ind=1
     AND badt.parent_entity_id != 0)) )) )
    JOIN (lt
    WHERE lt.location_cd=bmd.location_cd
     AND lt.active_ind=1)
    JOIN (og
    WHERE og.organization_id=lt.organization_id
     AND og.active_ind=1)
    JOIN (pn
    WHERE og.logical_domain_id=pn.logical_domain_id
     AND (pn.person_id=reqinfo->updt_id)
     AND pn.active_ind=1)
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
    JOIN (lg4
    WHERE lg4.child_loc_cd=lg3.parent_loc_cd
     AND lg4.location_group_type_cd=facility_cd
     AND lg4.active_ind=1
     AND lg4.root_loc_cd=0)
   ORDER BY fac_seq, bld_seq, lg4.child_loc_cd,
    unt_seq, lg3.child_loc_cd, rm_seq,
    lg2.child_loc_cd, bed_seq, lg1.child_loc_cd,
    mon_id
  ELSE DISTINCT INTO "nl:"
   fac_seq = lg4.parent_loc_cd, bld_seq = lg4.sequence, unt_seq = lg3.sequence,
   rm_seq = lg2.sequence, bed_seq = lg1.sequence, mon_id = bmd.monitored_device_id
   FROM bmdi_monitored_device bmd,
    bmdi_acquired_data_track badt,
    person p,
    location_group lg1,
    location_group lg2,
    location_group lg3,
    location_group lg4,
    organization og,
    location lt,
    prsnl pn
   PLAN (bmd
    WHERE bmd.location_cd > 0)
    JOIN (badt
    WHERE badt.device_cd=bmd.device_cd
     AND badt.location_cd=bmd.location_cd
     AND badt.monitored_device_id=bmd.monitored_device_id
     AND ((badt.active_ind=1
     AND ((badt.person_id > 0) OR (badt.parent_entity_id=0)) ) OR (((badt.person_id=0
     AND badt.active_ind=0
     AND badt.parent_entity_id=0) OR (badt.person_id=0
     AND badt.active_ind=1
     AND badt.parent_entity_id != 0)) )) )
    JOIN (lt
    WHERE lt.location_cd=bmd.location_cd
     AND lt.active_ind=1)
    JOIN (og
    WHERE og.organization_id=lt.organization_id
     AND og.active_ind=1)
    JOIN (pn
    WHERE og.logical_domain_id=pn.logical_domain_id
     AND (pn.person_id=reqinfo->updt_id)
     AND pn.active_ind=1)
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
    JOIN (lg4
    WHERE lg4.child_loc_cd=lg3.parent_loc_cd
     AND lg4.location_group_type_cd=facility_cd
     AND lg4.active_ind=1
     AND lg4.root_loc_cd=0)
   ORDER BY fac_seq, bld_seq, lg4.child_loc_cd,
    unt_seq, lg3.child_loc_cd, rm_seq,
    lg2.child_loc_cd, bed_seq, lg1.child_loc_cd,
    mon_id
  ENDIF
  HEAD REPORT
   ucnt = 0, rcnt = 0, bcnt = 0
  DETAIL
   IF ((((level=- (1))) OR (((level=0
    AND def_facility_cd=lg4.parent_loc_cd) OR (((level=1
    AND (request->unit_cd=lg3.parent_loc_cd)) OR (((level=2
    AND (request->unit_cd=lg2.parent_loc_cd)) OR (((level=3
    AND (request->unit_cd=lg1.parent_loc_cd)) OR (level=4
    AND (request->unit_cd=bmd.location_cd))) )) )) )) )) )
    IF (nurse_unit_cd != lg2.parent_loc_cd)
     rcnt = 0, ucnt = (ucnt+ 1), stat = alterlist(reply->unit_list,ucnt),
     nurse_unit_cd = lg2.parent_loc_cd, reply->unit_list[ucnt].facility_cd = lg4.parent_loc_cd, reply
     ->unit_list[ucnt].building_cd = lg3.parent_loc_cd,
     reply->unit_list[ucnt].unit_cd = lg2.parent_loc_cd, reply->unit_list[ucnt].unit_sequence = lg3
     .sequence, room_cd = 0
    ENDIF
    IF (room_cd != lg1.parent_loc_cd)
     bcnt = 0, rcnt = (rcnt+ 1), stat = alterlist(reply->unit_list[ucnt].room_list,rcnt),
     reply->unit_list[ucnt].room_list[rcnt].room_cd = lg1.parent_loc_cd, room_cd = lg1.parent_loc_cd,
     reply->unit_list[ucnt].room_list[rcnt].room_sequence = lg2.sequence
    ENDIF
    bcnt = (bcnt+ 1), stat = alterlist(reply->unit_list[ucnt].room_list[rcnt].bed_list,bcnt), reply->
    unit_list[ucnt].room_list[rcnt].bed_list[bcnt].device_alias = bmd.device_alias,
    reply->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].device_cd = bmd.device_cd, reply->
    unit_list[ucnt].room_list[rcnt].bed_list[bcnt].location_cd = bmd.location_cd, reply->unit_list[
    ucnt].room_list[rcnt].bed_list[bcnt].location_sequence = lg1.sequence,
    reply->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].association_id = badt.association_id, reply
    ->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].association_dt_tm = badt.association_dt_tm,
    reply->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].dis_association_dt_tm = badt
    .dis_association_dt_tm,
    reply->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].person_id = badt.person_id
    IF (p.person_id > 0)
     reply->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].name_full_formatted = p
     .name_full_formatted
    ENDIF
    reply->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].parent_entity_name = badt
    .parent_entity_name, reply->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].parent_entity_id =
    badt.parent_entity_id, reply->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].active_ind = badt
    .active_ind,
    reply->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].assoc_prsnl_id = badt.assoc_prsnl_id, reply
    ->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].dissoc_prsnl_id = badt.dissoc_prsnl_id, reply->
    unit_list[ucnt].room_list[rcnt].bed_list[bcnt].upd_status_cd = badt.upd_status_cd,
    reply->unit_list[ucnt].room_list[rcnt].bed_list[bcnt].hint_id = badt.hint_id, reply->unit_list[
    ucnt].room_list[rcnt].bed_list[bcnt].device_ind = bmd.device_ind
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#invalid
 IF ((reply->status_data.status="F"))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "Check Request"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_get_adt_logical_dm_id"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "No valid identifier in request"
 ENDIF
 CALL echorecord(reply)
END GO
