CREATE PROGRAM dcp_get_pl_provider_group2:dba
 DECLARE encntr_org_sec_ind = i4 WITH noconstant(0)
 DECLARE confid_ind = i4 WITH noconstant(0)
 DECLARE locx = i4 WITH noconstant(0)
 DECLARE locy = i4 WITH noconstant(0)
 DECLARE locz = i4 WITH noconstant(0)
 DECLARE servicex = i4 WITH noconstant(0)
 DECLARE visitx = i4 WITH noconstant(0)
 DECLARE typex = i4 WITH noconstant(0)
 DECLARE lifex = i4 WITH noconstant(0)
 DECLARE timediffset = i2 WITH noconstant(0)
 DECLARE bed_level = i2 WITH constant(0)
 DECLARE room_level = i2 WITH constant(1)
 DECLARE unit_level = i2 WITH constant(2)
 DECLARE building_level = i2 WITH constant(3)
 DECLARE facility_level = i2 WITH constant(4)
 DECLARE notimeparameter = i2 WITH constant(0)
 DECLARE lagtimeparameter = i2 WITH constant(1)
 DECLARE recenttimeparameter = i2 WITH constant(2)
 DECLARE timerangeparameter = i2 WITH constant(3)
 FREE SET criteria
 RECORD criteria(
   1 best_encntr_flag = i4
   1 time_frame_flag = i4
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 admit_flag = i2
   1 admit_dt_tm = dq8
   1 lookforward_admit_flag = i2
   1 lookforward_admit_dt_tm = dq8
   1 discharge_flag = i2
   1 disch_dt_tm = dq8
   1 locations
     2 level = i2
     2 group_cnt = i4
     2 groups[*]
       3 group_cd = f8
     2 facility_cnt = i4
     2 facilities[*]
       3 facility_cd = f8
     2 building_cnt = i4
     2 buildings[*]
       3 building_cd = f8
     2 unit_cnt = i4
     2 units[*]
       3 unit_cd = f8
     2 room_cnt = i4
     2 rooms[*]
       3 room_cd = f8
     2 bed_cnt = i4
     2 beds[*]
       3 bed_cd = f8
   1 service_cnt = i4
   1 services[*]
     2 service_cd = f8
   1 type_cnt = i4
   1 types[*]
     2 encntr_type_cd = f8
   1 class_cnt = i4
   1 classes[*]
     2 encntr_class_cd = f8
   1 status_cnt = i4
   1 statuses[*]
     2 encntr_status_cd = f8
   1 reltn_prsnl_id = f8
   1 vreltn_cnt = i4
   1 vreltns[*]
     2 vreltn_cd = f8
   1 lreltn_cnt = i4
   1 lreltns[*]
     2 lreltn_cd = f8
   1 careteam_cnt = i4
   1 careteams[*]
     2 group_id = f8
   1 provider_grp_cnt = i4
   1 provider_grps[*]
     2 group_id = f8
   1 begin_dt_tm = dq8
   1 begin_tz = i4
   1 end_dt_tm = dq8
   1 end_tz = i4
   1 schedule_location_cnt = i4
   1 schedule_locations[*]
     2 loc_cd = f8
   1 resource_cnt = i4
   1 resources[*]
     2 resource_cd = f8
 )
 SUBROUTINE (examineorgsecurity(x=i4) =null)
   IF (validate(ccldminfo,1))
    SET encntr_org_sec_ind = ccldminfo->sec_org_reltn
    SET confid_ind = ccldminfo->sec_confid
   ELSE
    SELECT INTO "nl:"
     FROM dm_info di
     PLAN (di
      WHERE di.info_domain="SECURITY"
       AND di.info_name IN ("SEC_ORG_RELTN", "SEC_CONFID"))
     DETAIL
      IF (di.info_name="SEC_ORG_RELTN"
       AND di.info_number=1)
       encntr_org_sec_ind = 1
      ELSEIF (di.info_name="SEC_CONFID"
       AND di.info_number=1)
       encntr_org_sec_ind = 1, confid_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE (initializecriteria(x=i4) =null)
   SET criteria->best_encntr_flag = 0
   SET criteria->time_frame_flag = notimeparameter
   SET criteria->beg_effective_dt_tm = cnvtdatetime("01-JAN-1700 00:00:00")
   SET criteria->end_effective_dt_tm = cnvtdatetime(sysdate)
   SET criteria->begin_tz = curtimezoneapp
   SET criteria->end_tz = curtimezoneapp
   SET criteria->admit_flag = 0
   SET criteria->discharge_flag = 0
   SET criteria->lookforward_admit_flag = 0
   SET criteria->disch_dt_tm = cnvtdatetime(sysdate)
   SET criteria->locations.level = facility_level
   SET criteria->locations.group_cnt = 0
   SET criteria->locations.facility_cnt = 0
   SET criteria->locations.building_cnt = 0
   SET criteria->locations.unit_cnt = 0
   SET criteria->locations.room_cnt = 0
   SET criteria->locations.bed_cnt = 0
   SET criteria->service_cnt = 0
   SET criteria->type_cnt = 0
   SET criteria->class_cnt = 0
   SET criteria->status_cnt = 0
   SET criteria->vreltn_cnt = 0
   SET criteria->lreltn_cnt = 0
   SET criteria->reltn_prsnl_id = 0.0
 END ;Subroutine
 SUBROUTINE (addlocation(loccd=f8) =null)
   DECLARE locationtype = vc WITH noconstant(fillstring(50," "))
   SET locationtype = uar_get_code_meaning(loccd)
   IF (locationtype="PATLISTROOT")
    SET criteria->locations.group_cnt += 1
    SET stat = alterlist(criteria->locations.groups,criteria->locations.group_cnt)
    SET criteria->locations.groups[criteria->locations.group_cnt].group_cd = loccd
    SET criteria->locations.level = minval(criteria->locations.level,unit_level)
   ELSEIF (locationtype="FACILITY")
    SET criteria->locations.facility_cnt += 1
    SET stat = alterlist(criteria->locations.facilities,criteria->locations.facility_cnt)
    SET criteria->locations.facilities[criteria->locations.facility_cnt].facility_cd = loccd
    SET criteria->locations.level = minval(criteria->locations.level,facility_level)
   ELSEIF (locationtype="BUILDING")
    SET criteria->locations.building_cnt += 1
    IF (mod(criteria->locations.building_cnt,10)=1)
     SET stat = alterlist(criteria->locations.buildings,(criteria->locations.building_cnt+ 9))
    ENDIF
    SET criteria->locations.buildings[criteria->locations.building_cnt].building_cd = loccd
    SET criteria->locations.level = minval(criteria->locations.level,building_level)
   ELSEIF (((locationtype="NURSEUNIT") OR (((locationtype="AMBULATORY") OR (locationtype="ANCILSURG"
   )) )) )
    SET criteria->locations.unit_cnt += 1
    IF (mod(criteria->locations.unit_cnt,10)=1)
     SET stat = alterlist(criteria->locations.units,(criteria->locations.unit_cnt+ 9))
    ENDIF
    SET criteria->locations.units[criteria->locations.unit_cnt].unit_cd = loccd
    SET criteria->locations.level = minval(criteria->locations.level,unit_level)
   ELSEIF (locationtype="ROOM")
    SET criteria->locations.room_cnt += 1
    IF (mod(criteria->locations.room_cnt,10)=1)
     SET stat = alterlist(criteria->locations.rooms,(criteria->locations.room_cnt+ 9))
    ENDIF
    SET criteria->locations.rooms[criteria->locations.room_cnt].room_cd = loccd
    SET criteria->locations.level = minval(criteria->locations.level,room_level)
   ELSEIF (locationtype="BED")
    SET criteria->locations.bed_cnt += 1
    IF (mod(criteria->locations.bed_cnt,10)=1)
     SET stat = alterlist(criteria->locations.beds,(criteria->locations.bed_cnt+ 9))
    ENDIF
    SET criteria->locations.beds[criteria->locations.bed_cnt].bed_cd = loccd
    SET criteria->locations.level = minval(criteria->locations.level,bed_level)
   ENDIF
 END ;Subroutine
 SUBROUTINE (addresource(rescd=f8) =null)
   SET criteria->resource_cnt += 1
   SET stat = alterlist(criteria->resources,criteria->resource_cnt)
   SET criteria->resources[criteria->resource_cnt].resource_cd = rescd
 END ;Subroutine
 SUBROUTINE (standardizelocations(normalize=i4) =null)
   DECLARE roomcnt = i4 WITH constant(criteria->locations.room_cnt)
   DECLARE bedcnt = i4 WITH constant(criteria->locations.bed_cnt)
   DECLARE roomadditions = i4 WITH noconstant(0)
   IF ((criteria->locations.group_cnt > 0))
    SELECT INTO "nl:"
     FROM location_group lg
     WHERE expand(locx,1,criteria->locations.group_cnt,lg.root_loc_cd,criteria->locations.groups[locx
      ].group_cd)
      AND lg.active_ind=1
      AND lg.end_effective_dt_tm >= cnvtdatetime(sysdate)
      AND  NOT (expand(locy,1,criteria->locations.unit_cnt,lg.child_loc_cd,criteria->locations.units[
      locy].unit_cd))
     ORDER BY lg.child_loc_cd
     HEAD lg.child_loc_cd
      criteria->locations.unit_cnt += 1
      IF (mod(criteria->locations.unit_cnt,10)=1)
       stat = alterlist(criteria->locations.units,(criteria->locations.unit_cnt+ 9))
      ENDIF
      criteria->locations.units[criteria->locations.unit_cnt].unit_cd = lg.child_loc_cd
     WITH nocounter
    ;end select
   ENDIF
   IF ((criteria->locations.facility_cnt > 0)
    AND (criteria->locations.level < facility_level))
    SELECT INTO "nl:"
     FROM location_group lg
     PLAN (lg
      WHERE expand(locx,1,criteria->locations.facility_cnt,lg.parent_loc_cd,criteria->locations.
       facilities[locx].facility_cd)
       AND ((lg.root_loc_cd+ 0)=0.0)
       AND lg.active_ind=1
       AND lg.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND  NOT (expand(locy,1,criteria->locations.building_cnt,lg.child_loc_cd,criteria->locations.
       buildings[locy].building_cd)))
     ORDER BY lg.child_loc_cd
     HEAD lg.child_loc_cd
      criteria->locations.building_cnt += 1
      IF (mod(criteria->locations.building_cnt,10)=1)
       stat = alterlist(criteria->locations.buildings,(criteria->locations.building_cnt+ 9))
      ENDIF
      criteria->locations.buildings[criteria->locations.building_cnt].building_cd = lg.child_loc_cd
     WITH nocounter
    ;end select
   ENDIF
   IF ((criteria->locations.building_cnt > 0)
    AND (criteria->locations.level < building_level))
    SELECT INTO "nl:"
     FROM location_group lg
     WHERE expand(locx,1,criteria->locations.building_cnt,lg.parent_loc_cd,criteria->locations.
      buildings[locx].building_cd)
      AND ((lg.root_loc_cd+ 0)=0.0)
      AND lg.active_ind=1
      AND lg.end_effective_dt_tm >= cnvtdatetime(sysdate)
      AND  NOT (expand(locy,1,criteria->locations.unit_cnt,lg.child_loc_cd,criteria->locations.units[
      locy].unit_cd))
     ORDER BY lg.child_loc_cd
     HEAD lg.child_loc_cd
      criteria->locations.unit_cnt += 1
      IF (mod(criteria->locations.unit_cnt,10)=1)
       stat = alterlist(criteria->locations.units,(criteria->locations.unit_cnt+ 9))
      ENDIF
      criteria->locations.units[criteria->locations.unit_cnt].unit_cd = lg.child_loc_cd
     WITH nocounter
    ;end select
   ENDIF
   IF ((criteria->locations.unit_cnt > 0)
    AND (criteria->locations.level < unit_level))
    SELECT INTO "nl:"
     FROM location_group lg
     WHERE expand(locx,1,criteria->locations.unit_cnt,lg.parent_loc_cd,criteria->locations.units[locx
      ].unit_cd)
      AND ((lg.root_loc_cd+ 0)=0.0)
      AND lg.active_ind=1
      AND lg.end_effective_dt_tm >= cnvtdatetime(sysdate)
      AND  NOT (expand(locy,1,criteria->locations.room_cnt,lg.child_loc_cd,criteria->locations.rooms[
      locy].room_cd))
     ORDER BY lg.child_loc_cd
     HEAD lg.child_loc_cd
      criteria->locations.room_cnt += 1
      IF (mod(criteria->locations.room_cnt,10)=1)
       stat = alterlist(criteria->locations.rooms,(criteria->locations.room_cnt+ 9))
      ENDIF
      criteria->locations.rooms[criteria->locations.room_cnt].room_cd = lg.child_loc_cd
     WITH nocounter
    ;end select
   ENDIF
   IF ((criteria->locations.room_cnt > 0)
    AND (criteria->locations.level < room_level))
    SELECT INTO "nl:"
     FROM location_group lg
     WHERE expand(locx,1,criteria->locations.room_cnt,lg.parent_loc_cd,criteria->locations.rooms[locx
      ].room_cd)
      AND ((lg.root_loc_cd+ 0)=0.0)
      AND lg.active_ind=1
      AND lg.end_effective_dt_tm >= cnvtdatetime(sysdate)
      AND  NOT (expand(locy,1,criteria->locations.bed_cnt,lg.child_loc_cd,criteria->locations.beds[
      locy].bed_cd))
     ORDER BY lg.child_loc_cd
     HEAD lg.child_loc_cd
      criteria->locations.bed_cnt += 1
      IF (mod(criteria->locations.bed_cnt,10)=1)
       stat = alterlist(criteria->locations.beds,(criteria->locations.bed_cnt+ 9))
      ENDIF
      criteria->locations.beds[criteria->locations.bed_cnt].bed_cd = lg.child_loc_cd
     WITH nocounter
    ;end select
   ENDIF
   IF (normalize)
    IF (bedcnt > 0)
     SELECT INTO "nl:"
      FROM location_group lg
      WHERE expand(locx,1,bedcnt,lg.child_loc_cd,criteria->locations.beds[locx].bed_cd)
       AND  NOT (expand(locy,1,criteria->locations.room_cnt,lg.parent_loc_cd,criteria->locations.
       rooms[locy].room_cd))
       AND ((lg.root_loc_cd+ 0)=0.0)
       AND lg.active_ind=1
       AND lg.end_effective_dt_tm >= cnvtdatetime(sysdate)
      ORDER BY lg.parent_loc_cd
      HEAD lg.parent_loc_cd
       roomadditions += 1, criteria->locations.room_cnt += 1
       IF (mod(criteria->locations.room_cnt,10)=1)
        stat = alterlist(criteria->locations.rooms,(criteria->locations.room_cnt+ 9))
       ENDIF
       criteria->locations.rooms[criteria->locations.room_cnt].room_cd = lg.parent_loc_cd
      WITH nocounter
     ;end select
     IF (roomadditions > 0)
      SET roomadditions = ((criteria->locations.room_cnt - roomadditions)+ 1)
      SELECT INTO "nl:"
       FROM location_group lg
       PLAN (lg
        WHERE expand(locx,roomadditions,criteria->locations.room_cnt,lg.child_loc_cd,criteria->
         locations.rooms[locx].room_cd)
         AND  NOT (expand(locy,1,criteria->locations.unit_cnt,lg.parent_loc_cd,criteria->locations.
         units[locy].unit_cd))
         AND ((lg.root_loc_cd+ 0)=0.0)
         AND lg.active_ind=1
         AND lg.end_effective_dt_tm >= cnvtdatetime(sysdate))
       ORDER BY lg.parent_loc_cd
       HEAD lg.parent_loc_cd
        criteria->locations.unit_cnt += 1
        IF (mod(criteria->locations.unit_cnt,10)=1)
         stat = alterlist(criteria->locations.units,(criteria->locations.unit_cnt+ 9))
        ENDIF
        criteria->locations.units[criteria->locations.unit_cnt].unit_cd = lg.parent_loc_cd
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
    IF (roomcnt > 0)
     SELECT INTO "nl:"
      FROM location_group lg
      WHERE expand(locx,1,roomcnt,lg.child_loc_cd,criteria->locations.rooms[locx].room_cd)
       AND  NOT (expand(locy,1,criteria->locations.unit_cnt,lg.parent_loc_cd,criteria->locations.
       units[locy].unit_cd))
       AND ((lg.root_loc_cd+ 0)=0.0)
       AND lg.active_ind=1
       AND lg.end_effective_dt_tm >= cnvtdatetime(sysdate)
      ORDER BY lg.parent_loc_cd
      HEAD lg.parent_loc_cd
       criteria->locations.unit_cnt += 1
       IF (mod(criteria->locations.unit_cnt,10)=1)
        stat = alterlist(criteria->locations.units,(criteria->locations.unit_cnt+ 9))
       ENDIF
       criteria->locations.units[criteria->locations.unit_cnt].unit_cd = lg.parent_loc_cd
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (populateschedulelocations(x=i4) =null)
   DECLARE faclevel = i2 WITH noconstant(0)
   DECLARE bldglevel = i2 WITH noconstant(0)
   DECLARE nulevel = i2 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM sch_code_group s
    PLAN (s
     WHERE s.code_group_id=1)
    DETAIL
     IF (s.cdf_meaning="FACILITY")
      faclevel = 1
     ELSEIF (s.cdf_meaning="BUILDING")
      bldglevel = 1
     ELSEIF (((s.cdf_meaning="NURSEUNIT") OR (((s.cdf_meaning="ANCILSURG") OR (s.cdf_meaning=
     "AMBULATORY")) )) )
      nulevel = 1
     ENDIF
    WITH nocounter
   ;end select
   IF ((criteria->locations.facility_cnt > 0))
    FOR (x = 1 TO criteria->locations.facility_cnt)
      SET criteria->schedule_location_cnt += 1
      IF (mod(criteria->schedule_location_cnt,10)=1)
       SET stat = alterlist(criteria->schedule_locations,(criteria->schedule_location_cnt+ 9))
      ENDIF
      SET criteria->schedule_locations[criteria->schedule_location_cnt].loc_cd = criteria->locations.
      facilities[x].facility_cd
    ENDFOR
    IF (((bldglevel=1) OR (nulevel=1)) )
     SELECT INTO "nl:"
      FROM location_group lg
      PLAN (lg
       WHERE expand(locx,1,criteria->locations.facility_cnt,lg.parent_loc_cd,criteria->locations.
        facilities[locx].facility_cd)
        AND ((lg.root_loc_cd+ 0)=0.0)
        AND lg.active_ind=1
        AND lg.end_effective_dt_tm >= cnvtdatetime(sysdate)
        AND  NOT (expand(locy,1,criteria->locations.building_cnt,lg.child_loc_cd,criteria->locations.
        buildings[locy].building_cd)))
      ORDER BY lg.child_loc_cd
      HEAD lg.child_loc_cd
       criteria->locations.building_cnt += 1
       IF (mod(criteria->locations.building_cnt,10)=1)
        stat = alterlist(criteria->locations.buildings,(criteria->locations.building_cnt+ 9))
       ENDIF
       criteria->locations.buildings[criteria->locations.building_cnt].building_cd = lg.child_loc_cd
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF ((criteria->locations.building_cnt > 0))
    FOR (x = 1 TO criteria->locations.building_cnt)
      SET criteria->schedule_location_cnt += 1
      IF (mod(criteria->schedule_location_cnt,10)=1)
       SET stat = alterlist(criteria->schedule_locations,(criteria->schedule_location_cnt+ 9))
      ENDIF
      SET criteria->schedule_locations[criteria->schedule_location_cnt].loc_cd = criteria->locations.
      buildings[x].building_cd
    ENDFOR
    IF (nulevel=1)
     SELECT INTO "nl:"
      FROM location_group lg
      WHERE expand(locx,1,criteria->locations.building_cnt,lg.parent_loc_cd,criteria->locations.
       buildings[locx].building_cd)
       AND ((lg.root_loc_cd+ 0)=0.0)
       AND lg.active_ind=1
       AND lg.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND  NOT (expand(locy,1,criteria->locations.unit_cnt,lg.child_loc_cd,criteria->locations.
       units[locy].unit_cd))
      ORDER BY lg.child_loc_cd
      HEAD lg.child_loc_cd
       criteria->locations.unit_cnt += 1
       IF (mod(criteria->locations.unit_cnt,10)=1)
        stat = alterlist(criteria->locations.units,(criteria->locations.unit_cnt+ 9))
       ENDIF
       criteria->locations.units[criteria->locations.unit_cnt].unit_cd = lg.child_loc_cd
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF ((criteria->locations.unit_cnt > 0))
    FOR (x = 1 TO criteria->locations.unit_cnt)
      SET criteria->schedule_location_cnt += 1
      IF (mod(criteria->schedule_location_cnt,10)=1)
       SET stat = alterlist(criteria->schedule_locations,(criteria->schedule_location_cnt+ 9))
      ENDIF
      SET criteria->schedule_locations[criteria->schedule_location_cnt].loc_cd = criteria->locations.
      units[x].unit_cd
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (addservice(servicecd=f8) =null)
   SET criteria->service_cnt += 1
   SET stat = alterlist(criteria->services,criteria->service_cnt)
   SET criteria->services[criteria->service_cnt].service_cd = servicecd
 END ;Subroutine
 SUBROUTINE (addencntrtype(typecd=f8) =null)
   SET criteria->type_cnt += 1
   SET stat = alterlist(criteria->types,criteria->type_cnt)
   SET criteria->types[criteria->type_cnt].encntr_type_cd = typecd
 END ;Subroutine
 SUBROUTINE (addencntrclass(classcd=f8) =null)
   SET criteria->class_cnt += 1
   SET stat = alterlist(criteria->classes,criteria->class_cnt)
   SET criteria->classes[criteria->class_cnt].encntr_class_cd = classcd
 END ;Subroutine
 SUBROUTINE (addencntrstatus(statuscd=f8) =null)
   SET criteria->status_cnt += 1
   SET stat = alterlist(criteria->statuses,criteria->status_cnt)
   SET criteria->statuses[criteria->status_cnt].encntr_status_cd = statuscd
 END ;Subroutine
 SUBROUTINE (addreltn(reltncd=f8) =null)
   DECLARE reltntype = i2 WITH noconstant(0), protected
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_value=reltncd)
    DETAIL
     IF (cv.code_set=333)
      reltntype = 1
     ELSEIF (cv.code_set=331)
      reltntype = 2
     ENDIF
    WITH nocounter
   ;end select
   IF (reltntype=1)
    CALL addvisitreltn(reltncd)
   ELSEIF (reltntype=2)
    CALL addlifetimereltn(reltncd)
   ENDIF
 END ;Subroutine
 SUBROUTINE (addvisitreltn(reltncd=f8) =null)
   IF (reltncd=0.0)
    SET criteria->vreltn_cnt = - (1)
   ELSEIF ((criteria->vreltn_cnt >= 0))
    SET criteria->vreltn_cnt += 1
    SET stat = alterlist(criteria->vreltns,criteria->vreltn_cnt)
    SET criteria->vreltns[criteria->vreltn_cnt].vreltn_cd = reltncd
   ENDIF
 END ;Subroutine
 SUBROUTINE (addlifetimereltn(reltncd=f8) =null)
   IF (reltncd=0.0)
    SET criteria->lreltn_cnt = - (1)
   ELSEIF ((criteria->lreltn_cnt >= 0))
    SET criteria->lreltn_cnt += 1
    SET stat = alterlist(criteria->lreltns,criteria->lreltn_cnt)
    SET criteria->lreltns[criteria->lreltn_cnt].lreltn_cd = reltncd
   ENDIF
 END ;Subroutine
 SUBROUTINE (addprsnlgroup(groupid=f8) =null)
  DECLARE prsnlgrouplisttype = vc WITH constant(uar_get_code_meaning(request->patient_list_type_cd)),
  private
  IF (prsnlgrouplisttype="PROVIDERGRP")
   CALL addprovidergroup(groupid)
  ELSE
   CALL addcareteam(groupid)
  ENDIF
 END ;Subroutine
 SUBROUTINE (addprovidergroup(groupid=f8) =null)
   SET criteria->provider_grp_cnt += 1
   SET stat = alterlist(criteria->provider_grps,criteria->provider_grp_cnt)
   SET criteria->provider_grps[criteria->provider_grp_cnt].group_id = groupid
 END ;Subroutine
 SUBROUTINE (addcareteam(groupid=f8) =null)
   SET criteria->careteam_cnt += 1
   SET stat = alterlist(criteria->careteams,criteria->careteam_cnt)
   SET criteria->careteams[criteria->careteam_cnt].group_id = groupid
 END ;Subroutine
 SUBROUTINE (setlagminutes(mins=i4) =null)
   DECLARE interval = vc WITH noconstant(fillstring(25," ")), private
   SET interval = build(abs(mins),"min")
   SET criteria->end_effective_dt_tm = cnvtlookbehind(interval,cnvtdatetime(sysdate))
   SET criteria->time_frame_flag = lagtimeparameter
 END ;Subroutine
 SUBROUTINE (setrecentminutes(mins=i4) =null)
   DECLARE interval = vc WITH noconstant(fillstring(25," ")), private
   SET interval = build(abs(mins),"min")
   SET criteria->beg_effective_dt_tm = cnvtlookbehind(interval,cnvtdatetime(sysdate))
   SET criteria->time_frame_flag = recenttimeparameter
 END ;Subroutine
 SUBROUTINE (setadmitminutes(mins=i4) =null)
   DECLARE interval = vc WITH noconstant(fillstring(25," ")), private
   SET interval = build(abs(mins),"min")
   SET criteria->admit_dt_tm = cnvtlookbehind(interval,cnvtdatetime(sysdate))
   SET criteria->admit_flag = 1
 END ;Subroutine
 SUBROUTINE (setlookforwardadmitminutes(mins=i4) =null)
   DECLARE interval = vc WITH noconstant(fillstring(25," ")), private
   SET interval = build(abs(mins),"min")
   SET criteria->lookforward_admit_dt_tm = cnvtlookahead(interval,cnvtdatetime(sysdate))
   SET criteria->lookforward_admit_flag = 1
 END ;Subroutine
 SUBROUTINE (setdischargeminutes(mins=i4) =null)
  DECLARE interval = vc WITH noconstant(fillstring(25," ")), private
  IF (mins < 0)
   SET criteria->discharge_flag = 2
  ELSEIF (mins > 0)
   SET interval = build(abs(mins),"min")
   SET criteria->disch_dt_tm = cnvtlookbehind(interval,cnvtdatetime(sysdate))
   SET criteria->discharge_flag = 1
  ENDIF
 END ;Subroutine
 SUBROUTINE (setbegindt(value=vc) =null)
   DECLARE index = i4 WITH noconstant(0), private
   DECLARE len = i4 WITH noconstant(0), private
   DECLARE srctz = i2 WITH noconstant(0), private
   DECLARE dtstring = vc WITH noconstant(fillstring(8," ")), private
   DECLARE tmstring = vc WITH noconstant(fillstring(8," ")), private
   SET index = findstring(";",value)
   SET len = textlen(value)
   SET dtstring = substring(1,(index - 1),value)
   SET srctz = cnvtint(substring((index+ 1),(len - index),value))
   SET newdt = cnvtdatetime(cnvtdate2(dtstring,"YYYYMMDD"),0)
   SET criteria->beg_effective_dt_tm = newdt
   SET criteria->begin_tz = srctz
   SET criteria->time_frame_flag = timerangeparameter
 END ;Subroutine
 SUBROUTINE (setenddt(value=vc) =null)
   DECLARE index = i4 WITH noconstant(0), private
   DECLARE len = i4 WITH noconstant(0), private
   DECLARE srctz = i2 WITH noconstant(0), private
   DECLARE dtstring = vc WITH noconstant(fillstring(8," ")), private
   DECLARE tmstring = vc WITH noconstant(fillstring(8," ")), private
   SET index = findstring(";",value)
   SET len = textlen(value)
   SET dtstring = substring(1,(index - 1),value)
   SET srctz = cnvtint(substring((index+ 1),(len - index),value))
   SET newdt = cnvtdatetime(cnvtdate2(dtstring,"YYYYMMDD"),0)
   SET criteria->end_effective_dt_tm = newdt
   SET criteria->end_tz = srctz
   SET criteria->time_frame_flag = timerangeparameter
 END ;Subroutine
 SUBROUTINE (setbegintm(value=vc) =null)
   DECLARE index = i4 WITH noconstant(0), private
   DECLARE len = i4 WITH noconstant(0), private
   DECLARE srctz = i2 WITH noconstant(0), private
   DECLARE dtstring = vc WITH noconstant(fillstring(8," ")), private
   DECLARE tmstring = vc WITH noconstant(fillstring(8," ")), private
   DECLARE tmstring2 = vc WITH noconstant(fillstring(8," ")), private
   DECLARE ind = i2 WITH noconstant(0)
   DECLARE interval = vc WITH noconstant(fillstring(25," ")), private
   SET index = findstring(";",value)
   SET len = textlen(value)
   SET tmstring2 = substring(1,(index - 1),value)
   SET tmstring = substring(9,6,tmstring2)
   SET srctz = cnvtint(substring((index+ 1),(len - index),value))
   SET now = cnvtdatetime(curdate,cnvtint(tmstring))
   SET criteria->beg_effective_dt_tm = datetimezone(now,srctz,2)
   SET criteria->begin_tz = srctz
   IF (timediffset=1)
    CALL determinedttmshift(1)
   ENDIF
   SET timediffset = 1
   SET criteria->time_frame_flag = timerangeparameter
 END ;Subroutine
 SUBROUTINE (setendtm(value=vc) =null)
   DECLARE index = i4 WITH noconstant(0), private
   DECLARE len = i4 WITH noconstant(0), private
   DECLARE srctz = i2 WITH noconstant(0), private
   DECLARE dtstring = vc WITH noconstant(fillstring(8," ")), private
   DECLARE tmstring = vc WITH noconstant(fillstring(8," ")), private
   DECLARE tmstring2 = vc WITH noconstant(fillstring(8," ")), private
   DECLARE ind = i2 WITH noconstant(0)
   SET index = findstring(";",value)
   SET len = textlen(value)
   SET tmstring2 = substring(1,(index - 1),value)
   SET tmstring = substring(9,6,tmstring2)
   SET srctz = cnvtint(substring((index+ 1),(len - index),value))
   SET now = cnvtdatetime(curdate,cnvtint(tmstring))
   SET criteria->end_effective_dt_tm = datetimezone(now,srctz,2)
   SET criteria->end_tz = srctz
   IF (timediffset=1)
    CALL determinedttmshift(1)
   ENDIF
   SET timediffset = 1
   SET criteria->time_frame_flag = timerangeparameter
 END ;Subroutine
 SUBROUTINE (determinedttmshift(x=i4) =null)
   IF ((criteria->beg_effective_dt_tm > criteria->end_effective_dt_tm))
    IF (cnvtdatetime(curdate,curtime) < cnvtdatetime(curdate,0)
     AND cnvtdatetime(curdate,curtime) > cnvtdatetime(criteria->beg_effective_dt_tm))
     SET dt = cnvtlookahead("1,D",criteria->end_effective_dt_tm)
     SET criteria->end_effective_dt_tm = dt
    ELSEIF (cnvtdatetime(curdate,curtime) > cnvtdatetime(curdate,0)
     AND cnvtdatetime(curdate,curtime) < cnvtdatetime(criteria->end_effective_dt_tm))
     SET dt = cnvtlookbehind("1,D",criteria->beg_effective_dt_tm)
     SET criteria->beg_effective_dt_tm = dt
    ELSE
     SET dt1 = datetimediff(criteria->beg_effective_dt_tm,cnvtdatetime(curdate,curtime))
     SET dt2 = datetimediff(cnvtdatetime(curdate,curtime),criteria->end_effective_dt_tm)
     IF (dt1 < dt2)
      SET dt = cnvtlookahead("1,D",criteria->end_effective_dt_tm)
      SET criteria->end_effective_dt_tm = dt
     ELSE
      SET dt = cnvtlookbehind("1,D",criteria->beg_effective_dt_tm)
      SET criteria->beg_effective_dt_tm = dt
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (setbegindttm(value=vc) =null)
   DECLARE index = i4 WITH noconstant(0), private
   DECLARE len = i4 WITH noconstant(0), private
   DECLARE srctz = i2 WITH noconstant(0), private
   DECLARE dtstring = vc WITH noconstant(fillstring(8," ")), private
   DECLARE tmstring = vc WITH noconstant(fillstring(8," ")), private
   SET index = findstring(";",value)
   SET len = textlen(value)
   SET dtstring = substring(1,(index - 1),value)
   SET srctz = cnvtint(substring((index+ 1),(len - index),value))
   CALL echo(value)
   CALL echo(dtstring)
   SET newdt = cnvtdatetime(cnvtdate2(dtstring,"YYYYMMDD"),0)
   CALL echo(newdt)
   SET criteria->beg_effective_dt_tm = datetimezone(newdt,srctz,2)
   SET criteria->begin_tz = srctz
   CALL echo(criteria->beg_effective_dt_tm)
   SET criteria->time_frame_flag = timerangeparameter
 END ;Subroutine
 SUBROUTINE (setenddttm(value=vc) =null)
   DECLARE index = i4 WITH noconstant(0), private
   DECLARE len = i4 WITH noconstant(0), private
   DECLARE srctz = i2 WITH noconstant(0), private
   DECLARE dtstring = vc WITH noconstant(fillstring(8," ")), private
   DECLARE tmstring = vc WITH noconstant(fillstring(8," ")), private
   SET index = findstring(";",value)
   SET len = textlen(value)
   SET dtstring = substring(1,(index - 1),value)
   SET srctz = cnvtint(substring((index+ 1),(len - index),value))
   SET newdt = cnvtdatetime(cnvtdate2(dtstring,"YYYYMMDD"),235959)
   SET criteria->end_effective_dt_tm = datetimezone(newdt,srctz,2)
   SET criteria->end_tz = srctz
   SET criteria->time_frame_flag = timerangeparameter
 END ;Subroutine
 SUBROUTINE (parsefilters(x=i4) =null)
   DECLARE filter_nbr = i4 WITH noconstant(cnvtint(size(request->encntr_type_filters,5)))
   DECLARE counter = i4 WITH noconstant(1), private
   FOR (counter = 1 TO filter_nbr)
     IF ((request->encntr_type_filters[counter].encntr_class_cd > 0))
      CALL addencntrclass(request->encntr_type_filters[counter].encntr_class_cd)
     ELSEIF ((request->encntr_type_filters[counter].encntr_type_cd > 0))
      CALL addencntrtype(request->encntr_type_filters[counter].encntr_type_cd)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (parsearguments(x=i4) =null)
   DECLARE arg_nbr = i4 WITH noconstant(cnvtint(size(request->arguments,5))), private
   DECLARE counter = i4 WITH noconstant(1), private
   DECLARE patient_status_flag = i4 WITH noconstant(0), private
   DECLARE patient_status_minutes = i4 WITH noconstant(0), private
   DECLARE listtypemeaning = vc WITH constant(uar_get_code_meaning(request->patient_list_type_cd)),
   private
   FOR (counter = 1 TO arg_nbr)
     CASE (request->arguments[counter].argument_name)
      OF "facility_filter":
       CALL addlocation(request->arguments[counter].parent_entity_id)
      OF "location_group":
       CALL addlocation(request->arguments[counter].parent_entity_id)
      OF "location":
       CALL addlocation(request->arguments[counter].parent_entity_id)
      OF "resource":
       CALL addresource(request->arguments[counter].parent_entity_id)
      OF "medical_service_cd":
       CALL addservice(request->arguments[counter].parent_entity_id)
      OF "encntr_type":
       CALL addencntrtype(request->arguments[counter].parent_entity_id)
      OF "encntr_class":
       CALL addencntrclass(request->arguments[counter].parent_entity_id)
      OF "encntr_status":
       CALL addencntrstatus(request->arguments[counter].parent_entity_id)
      OF "reltn_cd":
       CALL addreltn(request->arguments[counter].parent_entity_id)
      OF "visit_reltn_cd":
       CALL addvisitreltn(request->arguments[counter].parent_entity_id)
      OF "lifetime_reltn_cd":
       CALL addlifetimereltn(request->arguments[counter].parent_entity_id)
      OF "prsnl_id":
       SET criteria->reltn_prsnl_id = request->arguments[counter].parent_entity_id
      OF "careteam_id":
       CALL addcareteam(request->arguments[counter].parent_entity_id)
      OF "provider_group_id":
       CALL addprovidergroup(request->arguments[counter].parent_entity_id)
      OF "prsnl_group_id":
       CALL addprsnlgroup(request->arguments[counter].parent_entity_id)
      OF "lag_minutes":
       CALL setlagminutes(cnvtint(request->arguments[counter].argument_value))
      OF "recent_mins":
       CALL setrecentminutes(cnvtint(request->arguments[counter].argument_value))
      OF "begin_dt":
       CALL setbegindt(request->arguments[counter].argument_value)
      OF "end_dt":
       CALL setenddt(request->arguments[counter].argument_value)
      OF "begin_tm":
       CALL setbegintm(request->arguments[counter].argument_value)
      OF "end_tm":
       CALL setendtm(request->arguments[counter].argument_value)
      OF "begin_dt_tm":
       CALL setbegindttm(request->arguments[counter].argument_value)
      OF "end_dt_tm":
       CALL setenddttm(request->arguments[counter].argument_value)
      OF "admit_mins":
       CALL setadmitminutes(cnvtint(request->arguments[counter].argument_value))
      OF "lookforward_admit_mins":
       CALL setlookforwardadmitminutes(cnvtint(request->arguments[counter].argument_value))
      OF "disch_mins":
       CALL setdischargeminutes(cnvtint(request->arguments[counter].argument_value))
      OF "discharged_only":
       CALL setdischargeminutes(((120 * 24) * 60))
      OF "best_encntr_flag":
       SET criteria->best_encntr_flag = 1
      OF "patient_status_flag":
       SET patient_status_flag = cnvtint(request->arguments[counter].argument_value)
      OF "patient_status_minutes":
       SET patient_status_minutes = cnvtint(request->arguments[counter].argument_value)
     ENDCASE
   ENDFOR
   IF (patient_status_flag=1)
    CALL setadmitminutes(patient_status_minutes)
   ELSEIF (patient_status_flag=2)
    CALL setdischargeminutes(patient_status_minutes)
   ELSEIF (patient_status_flag=3)
    CALL setdischargeminutes(- (1))
   ENDIF
   IF ((criteria->discharge_flag=1)
    AND (criteria->time_frame_flag=notimeparameter))
    SET criteria->end_effective_dt_tm = criteria->disch_dt_tm
   ENDIF
   CALL parsefilters(1)
   IF (listtypemeaning="VRELTN")
    IF ((criteria->vreltn_cnt=0))
     SET criteria->vreltn_cnt = - (1)
    ENDIF
   ELSEIF (listtypemeaning="LRELTN")
    IF ((criteria->lreltn_cnt=0))
     SET criteria->lreltn_cnt = - (1)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (standardizeencntrclasses(x=i4) =null)
  DECLARE clsx = i4 WITH noconstant(0)
  IF ((criteria->class_cnt > 0))
   SELECT INTO "nl:"
    FROM code_value_group cvg
    PLAN (cvg
     WHERE expand(clsx,1,criteria->class_cnt,cvg.parent_code_value,criteria->classes[clsx].
      encntr_class_cd))
    ORDER BY cvg.child_code_value
    HEAD cvg.child_code_value
     criteria->type_cnt += 1, stat = alterlist(criteria->types,criteria->type_cnt), criteria->types[
     criteria->type_cnt].encntr_type_cd = cvg.child_code_value
    WITH nocounter
   ;end select
  ENDIF
 END ;Subroutine
 SUBROUTINE (performorgsecurity(x=i4) =null)
   DECLARE b = i4 WITH noconstant(0)
   DECLARE org_cnt = i4 WITH noconstant(0)
   DECLARE temp_cnt = i4 WITH noconstant(0)
   DECLARE orgid = f8 WITH noconstant(0.0)
   FREE SET orgs
   RECORD orgs(
     1 temp[*]
       2 org_id = f8
     1 qual[*]
       2 org_id = f8
       2 confid_level = i4
   )
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(patient_cnt))
    PLAN (d
     WHERE (reply->patients[d.seq].filter_ind=1))
    ORDER BY reply->patients[d.seq].organization_id
    HEAD REPORT
     orgid = 0.0, temp_cnt = 0
    DETAIL
     IF ((reply->patients[d.seq].organization_id != orgid))
      temp_cnt += 1
      IF (mod(temp_cnt,10)=1)
       stat = alterlist(orgs->temp,(temp_cnt+ 9))
      ENDIF
      orgs->temp[temp_cnt].org_id = reply->patients[d.seq].organization_id
     ENDIF
    WITH nocounter
   ;end select
   IF (temp_cnt > 0)
    IF (validate(_sacrtl_org_inc_,99999)=99999)
     DECLARE _sacrtl_org_inc_ = i2 WITH constant(1)
     RECORD sac_org(
       1 organizations[*]
         2 organization_id = f8
         2 confid_cd = f8
         2 confid_level = i4
     )
     EXECUTE secrtl
     EXECUTE sacrtl
     DECLARE orgcnt = i4 WITH protected, noconstant(0)
     DECLARE secstat = i2
     DECLARE logontype = i4 WITH protect, noconstant(- (1))
     DECLARE dynamic_org_ind = i4 WITH protect, noconstant(- (1))
     DECLARE dcur_trustid = f8 WITH protect, noconstant(0.0)
     DECLARE dynorg_enabled = i4 WITH constant(1)
     DECLARE dynorg_disabled = i4 WITH constant(0)
     DECLARE logontype_nhs = i4 WITH constant(1)
     DECLARE logontype_legacy = i4 WITH constant(0)
     DECLARE confid_cnt = i4 WITH protected, noconstant(0)
     RECORD confid_codes(
       1 list[*]
         2 code_value = f8
         2 coll_seq = f8
     )
     CALL uar_secgetclientlogontype(logontype)
     CALL echo(build("logontype:",logontype))
     IF (logontype != logontype_nhs)
      SET dynamic_org_ind = dynorg_disabled
     ENDIF
     IF (logontype=logontype_nhs)
      SUBROUTINE (getdynamicorgpref(dtrustid=f8) =i4)
        DECLARE scur_trust = vc
        DECLARE pref_val = vc
        DECLARE is_enabled = i4 WITH constant(1)
        DECLARE is_disabled = i4 WITH constant(0)
        SET scur_trust = cnvtstring(dtrustid)
        SET scur_trust = concat(scur_trust,".00")
        IF ( NOT (validate(pref_req,0)))
         RECORD pref_req(
           1 write_ind = i2
           1 delete_ind = i2
           1 pref[*]
             2 contexts[*]
               3 context = vc
               3 context_id = vc
             2 section = vc
             2 section_id = vc
             2 subgroup = vc
             2 entries[*]
               3 entry = vc
               3 values[*]
                 4 value = vc
         )
        ENDIF
        IF ( NOT (validate(pref_rep,0)))
         RECORD pref_rep(
           1 pref[*]
             2 section = vc
             2 section_id = vc
             2 subgroup = vc
             2 entries[*]
               3 pref_exists_ind = i2
               3 entry = vc
               3 values[*]
                 4 value = vc
           1 status_data
             2 status = c1
             2 subeventstatus[1]
               3 operationname = c25
               3 operationstatus = c1
               3 targetobjectname = c25
               3 targetobjectvalue = vc
         )
        ENDIF
        SET stat = alterlist(pref_req->pref,1)
        SET stat = alterlist(pref_req->pref[1].contexts,2)
        SET stat = alterlist(pref_req->pref[1].entries,1)
        SET pref_req->pref[1].contexts[1].context = "organization"
        SET pref_req->pref[1].contexts[1].context_id = scur_trust
        SET pref_req->pref[1].contexts[2].context = "default"
        SET pref_req->pref[1].contexts[2].context_id = "system"
        SET pref_req->pref[1].section = "workflow"
        SET pref_req->pref[1].section_id = "UK Trust Security"
        SET pref_req->pref[1].entries[1].entry = "dynamic organizations"
        EXECUTE ppr_preferences  WITH replace("REQUEST","PREF_REQ"), replace("REPLY","PREF_REP")
        IF (cnvtupper(pref_rep->pref[1].entries[1].values[1].value)="ENABLED")
         RETURN(is_enabled)
        ELSE
         RETURN(is_disabled)
        ENDIF
      END ;Subroutine
      DECLARE hprop = i4 WITH protect, noconstant(0)
      DECLARE tmpstat = i2
      DECLARE spropname = vc
      DECLARE sroleprofile = vc
      SET hprop = uar_srvcreateproperty()
      SET tmpstat = uar_secgetclientattributesext(5,hprop)
      SET spropname = uar_srvfirstproperty(hprop)
      SET sroleprofile = uar_srvgetpropertyptr(hprop,nullterm(spropname))
      SELECT INTO "nl:"
       FROM prsnl_org_reltn_type prt,
        prsnl_org_reltn por
       PLAN (prt
        WHERE prt.role_profile=sroleprofile
         AND prt.active_ind=1
         AND prt.beg_effective_dt_tm <= cnvtdatetime(sysdate)
         AND prt.end_effective_dt_tm > cnvtdatetime(sysdate))
        JOIN (por
        WHERE (por.organization_id= Outerjoin(prt.organization_id))
         AND (por.person_id= Outerjoin(prt.prsnl_id))
         AND (por.active_ind= Outerjoin(1))
         AND (por.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
         AND (por.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
       ORDER BY por.prsnl_org_reltn_id
       DETAIL
        orgcnt = 1, secstat = alterlist(sac_org->organizations,1), user_person_id = prt.prsnl_id,
        sac_org->organizations[1].organization_id = prt.organization_id, sac_org->organizations[1].
        confid_cd = por.confid_level_cd, confid_cd = uar_get_collation_seq(por.confid_level_cd),
        sac_org->organizations[1].confid_level =
        IF (confid_cd > 0) confid_cd
        ELSE 0
        ENDIF
       WITH maxrec = 1
      ;end select
      SET dcur_trustid = sac_org->organizations[1].organization_id
      SET dynamic_org_ind = getdynamicorgpref(dcur_trustid)
      CALL uar_srvdestroyhandle(hprop)
     ENDIF
     IF (dynamic_org_ind=dynorg_disabled)
      SET confid_cnt = 0
      SELECT INTO "NL:"
       c.code_value, c.collation_seq
       FROM code_value c
       WHERE c.code_set=87
       DETAIL
        confid_cnt += 1
        IF (mod(confid_cnt,10)=1)
         secstat = alterlist(confid_codes->list,(confid_cnt+ 9))
        ENDIF
        confid_codes->list[confid_cnt].code_value = c.code_value, confid_codes->list[confid_cnt].
        coll_seq = c.collation_seq
       WITH nocounter
      ;end select
      SET secstat = alterlist(confid_codes->list,confid_cnt)
      SELECT DISTINCT INTO "nl:"
       FROM prsnl_org_reltn por
       WHERE (por.person_id=reqinfo->updt_id)
        AND por.active_ind=1
        AND por.beg_effective_dt_tm < cnvtdatetime(sysdate)
        AND por.end_effective_dt_tm >= cnvtdatetime(sysdate)
       HEAD REPORT
        IF (orgcnt > 0)
         secstat = alterlist(sac_org->organizations,100)
        ENDIF
       DETAIL
        orgcnt += 1
        IF (mod(orgcnt,100)=1)
         secstat = alterlist(sac_org->organizations,(orgcnt+ 99))
        ENDIF
        sac_org->organizations[orgcnt].organization_id = por.organization_id, sac_org->organizations[
        orgcnt].confid_cd = por.confid_level_cd
       FOOT REPORT
        secstat = alterlist(sac_org->organizations,orgcnt)
       WITH nocounter
      ;end select
      SELECT INTO "NL:"
       FROM (dummyt d1  WITH seq = value(orgcnt)),
        (dummyt d2  WITH seq = value(confid_cnt))
       PLAN (d1)
        JOIN (d2
        WHERE (sac_org->organizations[d1.seq].confid_cd=confid_codes->list[d2.seq].code_value))
       DETAIL
        sac_org->organizations[d1.seq].confid_level = confid_codes->list[d2.seq].coll_seq
       WITH nocounter
      ;end select
     ELSEIF (dynamic_org_ind=dynorg_enabled)
      DECLARE nhstrustchild_org_org_reltn_cd = f8
      SET nhstrustchild_org_org_reltn_cd = uar_get_code_by("MEANING",369,"NHSTRUSTCHLD")
      SELECT INTO "nl:"
       FROM org_org_reltn oor
       PLAN (oor
        WHERE oor.organization_id=dcur_trustid
         AND oor.active_ind=1
         AND oor.beg_effective_dt_tm < cnvtdatetime(sysdate)
         AND oor.end_effective_dt_tm >= cnvtdatetime(sysdate)
         AND oor.org_org_reltn_cd=nhstrustchild_org_org_reltn_cd)
       HEAD REPORT
        IF (orgcnt > 0)
         secstat = alterlist(sac_org->organizations,10)
        ENDIF
       DETAIL
        IF (oor.related_org_id > 0)
         orgcnt += 1
         IF (mod(orgcnt,10)=1)
          secstat = alterlist(sac_org->organizations,(orgcnt+ 9))
         ENDIF
         sac_org->organizations[orgcnt].organization_id = oor.related_org_id
        ENDIF
       FOOT REPORT
        secstat = alterlist(sac_org->organizations,orgcnt)
       WITH nocounter
      ;end select
     ELSE
      CALL echo(build("Unexpected login type: ",dynamimc_org_ind))
     ENDIF
    ENDIF
    SET org_cnt = size(sac_org->organizations,5)
    SET stat = alterlist(orgs->qual,org_cnt)
    FOR (count = 1 TO org_cnt)
     SET orgs->qual[count].org_id = sac_org->organizations[count].organization_id
     SET orgs->qual[count].confid_level = sac_org->organizations[count].confid_level
    ENDFOR
   ENDIF
   IF (org_cnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(patient_cnt)),
      (dummyt d2  WITH seq = value(org_cnt))
     PLAN (d
      WHERE (reply->patients[d.seq].filter_ind=1))
      JOIN (d2
      WHERE (orgs->qual[d2.seq].org_id=reply->patients[d.seq].organization_id))
     DETAIL
      IF (((confid_ind=0) OR ((orgs->qual[d2.seq].confid_level >= reply->patients[d.seq].confid_level
      ))) )
       reply->patients[d.seq].filter_ind = 0
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   FREE SET orgs
 END ;Subroutine
 SUBROUTINE (performrelationshipoverrides(x=i4) =null)
   DECLARE reltncnt = i4 WITH noconstant(0)
   DECLARE i = i4 WITH noconstant(0)
   DECLARE j = i4 WITH noconstant(0)
   DECLARE k = i4 WITH noconstant(0)
   DECLARE found = i2 WITH noconstant(0), private
   DECLARE m = i4 WITH noconstant(0)
   DECLARE min_encntrid = f8 WITH noconstant(0.0)
   DECLARE max_encntrid = f8 WITH noconstant(0.0)
   FREE SET temp
   RECORD temp(
     1 entity_cnt = i4
     1 entities[*]
       2 entity_id = f8
       2 entity_index = i4
     1 person_cnt = i4
     1 persons[*]
       2 person_id = f8
       2 override_level = i2
     1 reltns[*]
       2 ppr_cd = f8
       2 override_type = i4
   )
   SELECT INTO "nl:"
    FROM code_value_extension cve
    PLAN (cve
     WHERE cve.code_set=331
      AND cve.field_name="Override")
    DETAIL
     reltncnt += 1
     IF (mod(reltncnt,10)=1)
      stat = alterlist(temp->reltns,(reltncnt+ 9))
     ENDIF
     temp->reltns[reltncnt].ppr_cd = cve.code_value, temp->reltns[reltncnt].override_type = cnvtint(
      cve.field_value)
     IF ((temp->reltns[reltncnt].override_type < 1))
      reltncnt -= 1
     ENDIF
    WITH nocounter
   ;end select
   IF (reltncnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = patient_cnt)
     PLAN (d
      WHERE (reply->patients[d.seq].filter_ind=1))
     ORDER BY reply->patients[d.seq].person_id
     HEAD REPORT
      temp->entity_cnt = 0
     DETAIL
      IF ((((temp->entity_cnt=0)) OR ((temp->entities[temp->entity_cnt].entity_id != reply->patients[
      d.seq].person_id))) )
       temp->entity_cnt += 1
       IF (mod(temp->entity_cnt,100)=1)
        stat = alterlist(temp->entities,(temp->entity_cnt+ 99))
       ENDIF
       temp->entities[temp->entity_cnt].entity_id = reply->patients[d.seq].person_id
      ENDIF
     WITH nocounter
    ;end select
    IF ((temp->entity_cnt > 0))
     SET stat = alterlist(temp->persons,temp->entity_cnt)
     SELECT INTO "nl:"
      FROM person_prsnl_reltn ppr
      PLAN (ppr
       WHERE (ppr.prsnl_person_id=reqinfo->updt_id)
        AND ppr.active_ind=1
        AND expand(i,1,reltncnt,ppr.person_prsnl_r_cd,temp->reltns[i].ppr_cd)
        AND expand(j,1,temp->entity_cnt,(ppr.person_id+ 0),temp->entities[j].entity_id))
      ORDER BY ppr.person_id
      HEAD REPORT
       temp->person_cnt = 0
      HEAD ppr.person_id
       temp->person_cnt += 1, temp->persons[temp->person_cnt].person_id = ppr.person_id
      DETAIL
       ridx = locateval(m,1,reltncnt,ppr.person_prsnl_r_cd,temp->reltns[m].ppr_cd), temp->persons[
       temp->person_cnt].override_level = maxval(temp->persons[temp->person_cnt].override_level,temp
        ->reltns[ridx].override_type)
      WITH nocounter
     ;end select
     IF ((temp->person_cnt > 0))
      SELECT INTO "nl:"
       FROM (dummyt d1  WITH seq = temp->person_cnt),
        (dummyt d2  WITH seq = patient_cnt)
       PLAN (d1
        WHERE (temp->persons[d1.seq].override_level > 0))
        JOIN (d2
        WHERE (reply->patients[d2.seq].person_id=temp->persons[d1.seq].person_id)
         AND (reply->patients[d2.seq].filter_ind=1))
       DETAIL
        IF ((((temp->persons[d1.seq].override_level=2)) OR ((reply->patients[d2.seq].confid_level=0)
        )) )
         reply->patients[d2.seq].filter_ind = 0
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = patient_cnt)
    PLAN (d
     WHERE (reply->patients[d.seq].filter_ind=1)
      AND (reply->patients[d.seq].encntr_id > 0.0))
    ORDER BY reply->patients[d.seq].encntr_id
    HEAD REPORT
     temp->entity_cnt = 0
    DETAIL
     temp->entity_cnt += 1
     IF (mod(temp->entity_cnt,100)=1)
      stat = alterlist(temp->entities,(temp->entity_cnt+ 99))
     ENDIF
     temp->entities[temp->entity_cnt].entity_id = reply->patients[d.seq].encntr_id, temp->entities[
     temp->entity_cnt].entity_index = d.seq
    WITH nocounter
   ;end select
   IF ((temp->entity_cnt > 0))
    SET j = 1
    WHILE ((j <= temp->entity_cnt))
      SET k = minval((j+ 199),temp->entity_cnt)
      SELECT INTO "nl:"
       FROM encntr_prsnl_reltn epr
       PLAN (epr
        WHERE expand(m,j,k,epr.encntr_id,temp->entities[m].entity_id)
         AND (epr.prsnl_person_id=reqinfo->updt_id)
         AND epr.expiration_ind=0
         AND epr.active_ind=1
         AND epr.encntr_prsnl_r_cd > 0
         AND epr.beg_effective_dt_tm < cnvtdatetime(sysdate)
         AND epr.end_effective_dt_tm > cnvtdatetime(sysdate))
       ORDER BY epr.encntr_id
       HEAD epr.encntr_id
        i = locateval(m,1,temp->entity_cnt,epr.encntr_id,temp->entities[m].entity_id)
        IF (i > 0)
         reply->patients[temp->entities[i].entity_index].filter_ind = 0
        ENDIF
       WITH nocounter
      ;end select
      SET j += 200
    ENDWHILE
   ENDIF
   FREE SET temp
 END ;Subroutine
 SUBROUTINE (removefilteredpatients(x=i4) =null)
   DECLARE actual_cnt = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(patient_cnt))
    PLAN (d
     WHERE (reply->patients[d.seq].filter_ind=0))
    HEAD REPORT
     actual_cnt = 0
    DETAIL
     actual_cnt += 1, reply->patients[actual_cnt].person_id = reply->patients[d.seq].person_id, reply
     ->patients[actual_cnt].person_name = reply->patients[d.seq].person_name,
     reply->patients[actual_cnt].encntr_id = reply->patients[d.seq].encntr_id, reply->patients[
     actual_cnt].priority = reply->patients[d.seq].priority, reply->patients[actual_cnt].active_ind
      = reply->patients[d.seq].active_ind,
     reply->patients[actual_cnt].organization_id = reply->patients[d.seq].organization_id, reply->
     patients[actual_cnt].confid_level_cd = reply->patients[d.seq].confid_level_cd, reply->patients[
     actual_cnt].confid_level = reply->patients[d.seq].confid_level,
     reply->patients[actual_cnt].filter_ind = reply->patients[d.seq].filter_ind, reply->patients[
     actual_cnt].birthdate = reply->patients[d.seq].birthdate, reply->patients[actual_cnt].birth_tz
      = reply->patients[d.seq].birth_tz,
     reply->patients[actual_cnt].gender_cd = reply->patients[d.seq].gender_cd, reply->patients[
     actual_cnt].vip_cd = reply->patients[d.seq].vip_cd, reply->patients[actual_cnt].deceased_date =
     reply->patients[d.seq].deceased_date,
     reply->patients[actual_cnt].deceased_tz = reply->patients[d.seq].deceased_tz, reply->patients[
     actual_cnt].end_effective_dt_tm = reply->patients[d.seq].end_effective_dt_tm, reply->patients[
     actual_cnt].service_cd = reply->patients[d.seq].service_cd,
     reply->patients[actual_cnt].temp_location_cd = reply->patients[d.seq].temp_location_cd, reply->
     patients[actual_cnt].visit_reason = reply->patients[d.seq].visit_reason, reply->patients[
     actual_cnt].visitor_status_cd = reply->patients[d.seq].visitor_status_cd
    FOOT REPORT
     patient_cnt = actual_cnt, stat = alterlist(reply->patients,patient_cnt)
    WITH nocounter
   ;end select
   SET patient_cnt = actual_cnt
   SET stat = alterlist(reply->patients,patient_cnt)
 END ;Subroutine
 SUBROUTINE (parseencounterbyencntr(condition=vc,usecensuscritieria=i2) =null)
   DECLARE txt = vc WITH noconstant(fillstring(50," ")), private
   SET txt = concat("join E where ",condition)
   CALL parser(txt)
   CALL parser("and (E.active_ind = 1 or E.encntr_id = 0.0)")
   IF ((criteria->time_frame_flag=notimeparameter)
    AND (criteria->type_cnt > 0))
    CALL parser(
     " and expand (typeX, 1, criteria->type_cnt, E.encntr_type_cd+0, criteria->types[typeX].encntr_type_cd)"
     )
   ENDIF
   IF (usecensuscritieria=1
    AND (criteria->time_frame_flag=notimeparameter)
    AND (criteria->service_cnt > 0))
    CALL parser(
     " and expand (serviceX, 1, criteria->service_cnt, E.med_service_cd+0, criteria->services[serviceX].service_cd)"
     )
   ENDIF
   IF (usecensuscritieria=1
    AND (criteria->time_frame_flag=notimeparameter))
    IF ((criteria->locations.bed_cnt > 0))
     CALL parser(" and expand (locX, 1, criteria->locations.bed_cnt, E.loc_bed_cd,")
     CALL parser(" criteria->locations.beds[locX].bed_cd)")
    ELSEIF ((criteria->locations.room_cnt > 0))
     CALL parser(" and expand (locX, 1, criteria->locations.room_cnt, E.loc_room_cd,")
     CALL parser(" criteria->locations.rooms[locX].room_cd)")
    ELSEIF ((criteria->locations.unit_cnt > 0))
     CALL parser(" and expand (locX, 1, criteria->locations.unit_cnt, E.loc_nurse_unit_cd,")
     CALL parser(" criteria->locations.units[locX].unit_cd)")
    ELSEIF ((criteria->locations.building_cnt > 0))
     CALL parser(" and expand (locX, 1, criteria->locations.building_cnt, E.loc_building_cd,")
     CALL parser(" criteria->locations.buildings[locX].building_cd)")
    ELSEIF ((criteria->locations.facility_cnt > 0))
     CALL parser(" and expand (locX, 1, criteria->locations.facility_cnt, E.loc_facility_cd,")
     CALL parser(" criteria->locations.facilities[locX].facility_cd)")
    ENDIF
   ENDIF
   IF ((criteria->admit_flag > 0)
    AND (criteria->lookforward_admit_flag=0))
    CALL parser(" and e.reg_dt_tm - 0 > cnvtdatetime(criteria->admit_dt_tm)")
   ELSEIF ((criteria->admit_flag=0)
    AND (criteria->lookforward_admit_flag > 0))
    CALL parser(" and e.reg_dt_tm - 0 < cnvtdatetime(criteria->lookforward_admit_dt_tm)")
   ELSEIF ((criteria->admit_flag > 0)
    AND (criteria->lookforward_admit_flag > 0))
    CALL parser(
     " and e.reg_dt_tm between cnvtdatetime(criteria->admit_dt_tm) and cnvtdatetime(criteria->lookforward_admit_dt_tm)"
     )
   ENDIF
   IF ((criteria->discharge_flag=1))
    CALL parser(" and e.disch_dt_tm - 0 >= cnvtdatetime(criteria->disch_dt_tm)")
    CALL parser(" and e.disch_dt_tm - 0 <= cnvtdatetime(curdate, curtime3)")
   ELSEIF ((criteria->discharge_flag=2))
    CALL parser(" and (nullind(e.disch_dt_tm) = 1")
    CALL parser(" or e.disch_dt_tm - 0 >= cnvtdatetime(criteria->disch_dt_tm))")
   ENDIF
 END ;Subroutine
 SUBROUTINE parseencntrlochistbyencntr(alias)
   DECLARE text = vc WITH noconstant(fillstring(25," ")), private
   SET text = concat("join ELH where ELH.encntr_id = ",alias)
   CALL parser(text)
   IF ((criteria->time_frame_flag=timerangeparameter))
    CALL parser("and ELH.end_effective_dt_tm >= cnvtdate(criteria->beg_effective_dt_tm)")
    CALL parser("and ELH.beg_effective_dt_tm <= cnvtdate(criteria->end_effective_dt_tm)")
   ELSE
    CALL parser("and ELH.end_effective_dt_tm >= cnvtdate(criteria->end_effective_dt_tm)")
    CALL parser("and ELH.beg_effective_dt_tm >= cnvtdate(criteria->beg_effective_dt_tm)")
   ENDIF
   CALL parser("and ELH.active_ind = 1")
   IF ((criteria->locations.bed_cnt > 0))
    CALL parser(" and expand (locX, 1, criteria->locations.bed_cnt, ELH.loc_bed_cd,")
    CALL parser(" critiera->locations.beds[locX].bed_cd)")
   ELSEIF ((criteria->locations.room_cnt > 0))
    CALL parser(" and expand (locX, 1, criteria->locations.room_cnt, ELH.loc_room_cd,")
    CALL parser(" criteria->locations.rooms[locX].room_cd)")
   ELSEIF ((criteria->locations.unit_cnt > 0))
    CALL parser("and expand(locX, 1, criteria->locations.unit_cnt, ELH.loc_nurse_unit_cd,")
    CALL parser(" criteria->locations.units[locX].unit_cd)")
   ELSEIF ((criteria->locations.building_cnt > 0))
    CALL parser("and expand(locX, 1, criteria->locations.building_cnt, ELH.loc_building_cd, ")
    CALL parser(" criteria->locations.buildings[locX].building_cd)")
   ELSEIF ((criteria->locations.facility_cnt > 0))
    CALL parser(" and expand(locX, 1, criteria->locations.facility_cnt, ELH.loc_facility_cd,")
    CALL parser(" criteria->locations.facilities[locX].facility_cd)")
   ENDIF
   IF ((criteria->service_cnt > 0))
    CALL parser("and expand (serviceX, 1, criteria->service_cnt, ELH.med_service_cd,")
    CALL parser(" criteria->services[serviceX].service_cd)")
   ENDIF
   IF ((criteria->type_cnt > 0))
    CALL parser(
     "and expand (typeX, 1, criteria->type_cnt, ELH.encntr_type_cd, criteria->types[typeX].encntr_type_cd)"
     )
   ENDIF
 END ;Subroutine
 SUBROUTINE (parseepr(alias=vc) =null)
   DECLARE text = vc WITH noconstant(fillstring(50," ")), private
   SET text = concat("join EPR where EPR.encntr_id = ",alias)
   CALL parser(text)
   IF ((criteria->vreltn_cnt > 0))
    CALL parser(
     "and expand (visitX, 1, criteria->vreltn_cnt, EPR.encntr_prsnl_r_cd, criteria->vreltns[visitX].vreltn_cd)"
     )
   ENDIF
   CALL parser("and EPR.prsnl_person_id+0 = criteria->reltn_prsnl_id")
   CALL parser("and EPR.active_ind = 1")
   IF ((criteria->time_frame_flag=timerangeparameter))
    CALL parser("and EPR.end_effective_dt_tm >= cnvtdatetime(criteria->beg_effective_dt_tm)")
    CALL parser("and EPR.expire_dt_tm >= cnvtdatetime(criteria->beg_effective_dt_tm)")
    CALL parser("and EPR.beg_effective_dt_tm <= cnvtdatetime(criteria->end_effective_dt_tm)")
   ELSEIF ((criteria->time_frame_flag=notimeparameter))
    CALL parser("and EPR.expiration_ind+0 = 0")
    CALL parser("and EPR.end_effective_dt_tm >= cnvtdatetime(curdate, curtime3)")
   ELSE
    CALL parser("and EPR.end_effective_dt_tm >= cnvtdatetime(criteria->end_effective_dt_tm)")
    CALL parser(
     "and (EPR.expiration_ind = 0 or EPR.expire_dt_tm >= cnvtdatetime(criteria->end_effective_dt_tm))"
     )
    CALL parser("and EPR.beg_effective_dt_tm >= cnvtdatetime(criteria->beg_effective_dt_tm)")
   ENDIF
 END ;Subroutine
 SUBROUTINE (parseppr(alias=vc) =null)
   DECLARE text = vc WITH noconstant(fillstring(50," ")), private
   SET text = concat("join PPR where PPR.person_id = ",alias)
   CALL parser(text)
   CALL parser("and PPR.prsnl_person_id+0 = criteria->reltn_prsnl_id")
   IF ((criteria->lreltn_cnt > 0))
    CALL parser(
     "and expand (lifeX, 1, criteria->lreltn_cnt, PPR.person_prsnl_r_cd, criteria->lreltns[lifeX].lreltn_cd)"
     )
   ENDIF
   CALL parser("and PPR.active_ind = 1")
   IF ((criteria->time_frame_flag=timerangeparameter))
    CALL parser("and PPR.end_effective_dt_tm >= cnvtdatetime(criteria->beg_effective_dt_tm)")
    CALL parser("and PPR.beg_effective_dt_tm <= cnvtdatetime(criteria->end_effective_dt_tm)")
   ELSEIF ((criteria->time_frame_flag=notimeparameter))
    CALL parser("and PPR.end_effective_dt_tm >= cnvtdatetime(curdate, curtime3)")
   ELSE
    CALL parser("and PPR.end_effective_dt_tm >= cnvtdatetime(criteria->end_effective_dt_tm)")
    CALL parser("and PPR.beg_effective_dt_tm >= cnvtdatetime(criteria->beg_effective_dt_tm)")
   ENDIF
 END ;Subroutine
 SUBROUTINE (assignpriorities(x=i4) =null)
   DECLARE i = i4 WITH noconstant(0), private
   DECLARE j = i4 WITH noconstant(0), private
   DECLARE k = i4 WITH noconstant(0), private
   DECLARE found = i2 WITH noconstant(0), private
   DECLARE m = i4 WITH noconstant(0)
   FREE SET temp
   RECORD temp(
     1 person_cnt = i4
     1 persons[*]
       2 person_id = f8
       2 priority = i4
   )
   IF ((request->patient_list_id > 0)
    AND patient_cnt > 0)
    SET temp->person_cnt = 0
    SELECT INTO "nl:"
     FROM dcp_pl_prioritization pr
     PLAN (pr
      WHERE (pr.patient_list_id=request->patient_list_id)
       AND expand(m,1,patient_cnt,(pr.person_id+ 0),reply->patients[m].person_id))
     DETAIL
      temp->person_cnt += 1
      IF (mod(temp->person_cnt,25)=1)
       stat = alterlist(temp->persons,(temp->person_cnt+ 24))
      ENDIF
      temp->persons[temp->person_cnt].person_id = pr.person_id, temp->persons[temp->person_cnt].
      priority = pr.priority
     WITH nocounter
    ;end select
    FOR (j = 1 TO temp->person_cnt)
      FOR (i = 1 TO patient_cnt)
        IF ((reply->patients[i].person_id=temp->persons[j].person_id))
         SET reply->patients[i].priority = temp->persons[j].priority
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   FREE SET temp
 END ;Subroutine
 SUBROUTINE (performbestencntr(n=i4) =null)
   RECORD encntrrequest(
     1 persons[*]
       2 person_id = f8
   )
   RECORD encntrreply(
     1 encounters[*]
       2 encntr_id = f8
       2 person_id = f8
     1 lookup_status = i4
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   DECLARE patcount = i4 WITH constant(size(reply->patients,5)), private
   DECLARE encntrcnt = i4 WITH noconstant(0), private
   DECLARE x = i4 WITH noconstant(0), private
   DECLARE y = i4 WITH noconstant(0), private
   SET stat = alterlist(encntrrequest->persons,patcount)
   FOR (x = 1 TO patcount)
     IF ((reply->patients[x].encntr_id=0))
      SET encntrrequest->persons[x].person_id = reply->patients[x].person_id
      SET encntrcnt += 1
     ENDIF
   ENDFOR
   IF (encntrcnt > 0)
    SET stat = alterlist(encntrrequest->persons,encntrcnt)
    EXECUTE pts_get_best_encntr_list  WITH replace(request,encntrrequest), replace(reply,encntrreply)
    SET encntr_cnt = size(encntrreply->encounters,5)
    FOR (x = 1 TO encntrcnt)
      FOR (y = 1 TO patcount)
        IF ((reply->patients[y].person_id=encntrreply->encounters[x].person_id)
         AND (reply->patients[y].encntr_id=0))
         SET reply->patients[y].encntr_id = encntrreply->encounters[x].encntr_id
         SET y = (patcount+ 1)
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   FREE RECORD encntrreply
   FREE RECORD encntrrequest
 END ;Subroutine
 DECLARE ppr_where = vc WITH noconstant(fillstring(1000," "))
 DECLARE patient_cnt = i4 WITH noconstant(0)
 DECLARE prsnl_group_id = f8 WITH noconstant(0.0)
 RECORD prov_reltn(
   1 visit_cnt = i4
   1 visit[*]
     2 ppr_cd = f8
     2 pgr_id = f8
   1 life_cnt = i4
   1 life[*]
     2 ppr_cd = f8
     2 pgr_id = f8
 )
 DECLARE populateprovidernames(null) = null
 DECLARE evaluatetimecriteria(null) = i2
 DECLARE populateprovider_reltns(null) = null
 DECLARE deleteexpiredremovedrows(null) = null
 CALL examineorgsecurity(1)
 CALL initializecriteria(1)
 CALL parsearguments(1)
 CALL standardizelocations(1)
 CALL standardizeencntrclasses(1)
 IF ((criteria->provider_grp_cnt=0))
  CALL echo("Definition Error: No provider group specified.")
  GO TO finish
 ELSEIF ((criteria->provider_grp_cnt > 0))
  SET prsnl_group_id = criteria->provider_grps[0].group_id
 ENDIF
 CALL populateprovider_reltns(null)
 IF ((request->rmv_pl_rows_flag=1))
  CALL deleteexpiredremovedrows(null)
 ENDIF
 IF ((prov_reltn->visit_cnt > 0))
  CALL executevisitprimaryselect(1)
 ENDIF
 IF ((prov_reltn->life_cnt > 0))
  CALL executelifeprimaryselect(1)
 ENDIF
 SET stat = alterlist(reply->patients,patient_cnt)
 IF (patient_cnt > 0)
  IF (encntr_org_sec_ind=1)
   CALL performorgsecurity(1)
   CALL performrelationshipoverrides(1)
   CALL removefilteredpatients(1)
  ENDIF
  CALL assignpriorities(1)
  CALL populateprovidernames(null)
  IF ((criteria->best_encntr_flag > 0))
   CALL performbestencntr(1)
  ENDIF
 ENDIF
#finish
 FREE SET criteria
 IF (patient_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE populateprovider_reltns(null)
   DECLARE nsize = i4 WITH noconstant(5)
   DECLARE ntotal = i4 WITH noconstant(0)
   DECLARE nstart = i4 WITH noconstant(1)
   DECLARE idx = i4 WITH noconstant(0)
   SET ntotal = (ceil((cnvtreal(criteria->provider_grp_cnt)/ nsize)) * nsize)
   SET stat = alterlist(criteria->provider_grps,ntotal)
   FOR (idx = (criteria->provider_grp_cnt+ 1) TO ntotal)
     SET criteria->provider_grps[idx].group_id = criteria->provider_grps[criteria->provider_grp_cnt].
     group_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     prsnl_group_reltn pgr,
     team_mem_ppr_reltn team
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
     JOIN (pgr
     WHERE expand(idx,nstart,(nstart+ (nsize - 1)),pgr.prsnl_group_id,criteria->provider_grps[idx].
      group_id,
      nsize)
      AND pgr.active_ind=1)
     JOIN (team
     WHERE team.prsnl_group_reltn_id=pgr.prsnl_group_reltn_id)
    HEAD REPORT
     prov_reltn->life_cnt = 0, prov_reltn->visit_cnt = 0
    DETAIL
     IF (team.ppr_flag=0)
      prov_reltn->life_cnt += 1
      IF (mod(prov_reltn->life_cnt,10)=1)
       stat = alterlist(prov_reltn->life,(prov_reltn->life_cnt+ 9))
      ENDIF
      prov_reltn->life[prov_reltn->life_cnt].ppr_cd = team.ppr_cd, prov_reltn->life[prov_reltn->
      life_cnt].pgr_id = pgr.person_id
     ELSEIF (team.ppr_flag=1)
      prov_reltn->visit_cnt += 1
      IF (mod(prov_reltn->visit_cnt,10)=1)
       stat = alterlist(prov_reltn->visit,(prov_reltn->visit_cnt+ 9))
      ENDIF
      prov_reltn->visit[prov_reltn->visit_cnt].ppr_cd = team.ppr_cd, prov_reltn->visit[prov_reltn->
      visit_cnt].pgr_id = pgr.person_id
     ENDIF
    FOOT REPORT
     stat = alterlist(prov_reltn->life,prov_reltn->life_cnt), stat = alterlist(prov_reltn->visit,
      prov_reltn->visit_cnt)
    WITH nocounter
   ;end select
   SET stat = alterlist(criteria->provider_grps,criteria->provider_grp_cnt)
   SET nstart = 1
   SET nsize = 50
   SET ntotal = (ceil((cnvtreal(prov_reltn->life_cnt)/ nsize)) * nsize)
   SET stat = alterlist(prov_reltn->life,ntotal)
   FOR (idx = (prov_reltn->life_cnt+ 1) TO ntotal)
    SET prov_reltn->life[idx].pgr_id = prov_reltn->life[prov_reltn->life_cnt].pgr_id
    SET prov_reltn->life[idx].ppr_cd = prov_reltn->life[prov_reltn->life_cnt].ppr_cd
   ENDFOR
   SET ntotal = (ceil((cnvtreal(prov_reltn->visit_cnt)/ nsize)) * nsize)
   SET stat = alterlist(prov_reltn->visit,ntotal)
   FOR (idx = (prov_reltn->visit_cnt+ 1) TO ntotal)
    SET prov_reltn->visit[idx].pgr_id = prov_reltn->visit[prov_reltn->visit_cnt].pgr_id
    SET prov_reltn->visit[idx].ppr_cd = prov_reltn->visit[prov_reltn->visit_cnt].ppr_cd
   ENDFOR
 END ;Subroutine
 SUBROUTINE (executevisitprimaryselect(x=i4) =null)
   DECLARE uselochist = i2 WITH constant(evaluatetimecriteria(null))
   DECLARE nsize = i4 WITH noconstant(5)
   DECLARE nstart = i4 WITH noconstant(1)
   DECLARE ntotal = i4 WITH noconstant(0)
   SET nstart = 1
   SET nsize = 50
   SET ntotal = (ceil((cnvtreal(prov_reltn->visit_cnt)/ nsize)) * nsize)
   SET stat = alterlist(prov_reltn->visit,ntotal)
   CALL parser("select into 'nl:'")
   CALL parser("from (dummyt d1 with seq = value(1+((ntotal-1)/nsize))),")
   CALL parser("encntr_prsnl_reltn epr,")
   CALL parser("encounter e,")
   IF (uselochist > 0)
    CALL parser("encntr_loc_hist elh,")
   ENDIF
   CALL parser("person p")
   CALL parser("plan d1 where initarray( nstart, evaluate(d1.seq,1,1,nstart+nsize))")
   CALL parser("join epr where expand(x, nstart, nstart+(nsize-1), ")
   CALL parser("          epr.prsnl_person_id , prov_reltn->visit[x].pgr_id")
   IF (((((currev * 10000)+ (currevminor * 100))+ currevminor2) >= 080204))
    CALL parser("        ,epr.encntr_prsnl_r_cd ,  prov_reltn->visit[x].ppr_cd)")
   ELSE
    CALL parser(
     ", nsize) and expand(x, nstart, nstart+(nsize-1), epr.encntr_prsnl_r_cd, prov_reltn->visit[x].ppr_cd, nsize)"
     )
   ENDIF
   CALL parser("and epr.expiration_ind = 0")
   CALL parser("and epr.beg_effective_dt_tm < cnvtdatetime(curdate, curtime3)")
   CALL parser("and epr.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)")
   CALL parser("and epr.active_ind+0 = 1")
   IF (uselochist > 0)
    CALL parseencntrlochistbyencntr("epr.encntr_id")
    CALL parseencounterbyencntr("e.encntr_id = elh.encntr_id",1)
   ELSE
    CALL parseencounterbyencntr("e.encntr_id = epr.encntr_id",1)
   ENDIF
   CALL parser("join p where p.person_id = e.person_id and p.active_ind = 1")
   CALL parser("order by epr.encntr_id")
   CALL parser("head epr.encntr_id")
   IF (((((currev * 10000)+ (currevminor * 100))+ currevminor2) < 080204))
    CALL parser(
     " index = locateval( x, 1,prov_reltn->visit_cnt, epr.prsnl_person_id , prov_reltn->visit[x].pgr_id)"
     )
    CALL parser(" while( index != 0) ")
    CALL parser(" if( epr.encntr_prsnl_r_cd = prov_reltn->visit[index].ppr_cd) ")
   ENDIF
   CALL parser("  patient_cnt = patient_cnt+1")
   CALL parser("  if(mod(patient_cnt,100) = 1)")
   CALL parser("    stat = alterlist(reply->patients,patient_cnt+99)")
   CALL parser("  endif")
   CALL parser("  reply->patients[patient_cnt].person_id = p.person_id")
   CALL parser("  reply->patients[patient_cnt].person_name = p.name_full_formatted")
   CALL parser("  reply->patients[patient_cnt].filter_ind = encntr_org_sec_ind")
   CALL parser("  reply->patients[patient_cnt].encntr_id = epr.encntr_id")
   CALL parser("  reply->patients[patient_cnt].organization_id = e.organization_id")
   CALL parser("  reply->patients[patient_cnt].confid_level_cd = e.confid_level_cd ")
   CALL parser("  reply->patients[patient_cnt].responsible_prsnl_id = epr.prsnl_person_id")
   CALL parser("  reply->patients[patient_cnt].responsible_reltn_cd = epr.encntr_prsnl_r_cd")
   CALL parser("  reply->patients[patient_cnt].responsible_reltn_id = epr.encntr_prsnl_reltn_id")
   CALL parser("  reply->patients[patient_cnt].responsible_reltn_flag = 1")
   CALL parser("  reply->patients[patient_cnt].active_ind = 1")
   CALL parser("  if (epr.end_effective_dt_tm < cnvtdatetime(curdate,curtime3))")
   CALL parser("    reply->patients[patient_cnt].active_ind = 0")
   CALL parser("  endif")
   CALL parser("  reply->patients[patient_cnt].birthdate = p.birth_dt_tm")
   CALL parser("  reply->patients[patient_cnt].birth_tz = p.birth_tz")
   CALL parser("  reply->patients[patient_cnt].gender_cd = p.sex_cd")
   CALL parser("  reply->patients[patient_cnt].vip_cd = p.vip_cd")
   CALL parser("  reply->patients[patient_cnt].deceased_date = p.deceased_dt_tm")
   CALL parser("  reply->patients[patient_cnt].deceased_tz = p.deceased_tz")
   CALL parser("  reply->patients[patient_cnt].end_effective_dt_tm = e.end_effective_dt_tm")
   CALL parser("  reply->patients[patient_cnt].service_cd = e.med_service_cd")
   CALL parser("  reply->patients[patient_cnt].temp_location_cd = e.loc_temp_cd")
   CALL parser("  reply->patients[patient_cnt].visit_reason = e.reason_for_visit")
   CALL parser("  reply->patients[patient_cnt].visitor_status_cd = e.visitor_status_cd")
   CALL parser("  detail")
   CALL parser("  if ((epr.prsnl_person_id = reqinfo->updt_id")
   CALL parser("     and (epr.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)")
   CALL parser("     or reply->patients[patient_cnt].responsible_prsnl_id != reqinfo->updt_id))")
   CALL parser("     or (reply->patients[patient_cnt].active_ind = 0")
   CALL parser("     and epr.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)")
   CALL parser("     and reply->patients[patient_cnt].responsible_prsnl_id != reqinfo->updt_id))")
   CALL parser("    reply->patients[patient_cnt].responsible_prsnl_id = epr.prsnl_person_id")
   CALL parser("    reply->patients[patient_cnt].responsible_reltn_cd = epr.encntr_prsnl_r_cd")
   CALL parser("    reply->patients[patient_cnt].responsible_reltn_id = epr.encntr_prsnl_reltn_id")
   CALL parser("    reply->patients[patient_cnt].responsible_reltn_flag = 1")
   CALL parser("    reply->patients[patient_cnt].active_ind = 1")
   CALL parser("    if (epr.end_effective_dt_tm < cnvtdatetime(curdate,curtime3))")
   CALL parser("reply->patients[patient_cnt].active_ind = 0")
   CALL parser("    endif")
   CALL parser("  endif")
   IF (((((currev * 10000)+ (currevminor * 100))+ currevminor2) < 080204))
    CALL parser(" endif")
    CALL parser(
     " index = locateval( x, index+1, prov_reltn->visit_cnt, epr.prsnl_person_id , prov_reltn->visit[x].pgr_id)"
     )
    CALL parser(" endwhile")
   ENDIF
   CALL parser("foot epr.encntr_id")
   CALL parser("  if (reply->patients[patient_cnt].responsible_prsnl_id = reqinfo->updt_id")
   CALL parser("    and reply->patients[patient_cnt].active_ind = 1)")
   CALL parser("      reply->patients[patient_cnt].filter_ind = 0")
   CALL parser("  else ")
   CALL parser("  if (encntr_org_sec_ind = 0)")
   CALL parser("    reply->patients[patient_cnt].filter_ind = 0")
   CALL parser("  else")
   CALL parser("    reply->patients[patient_cnt].filter_ind = 1")
   CALL parser("  endif")
   CALL parser("  if (confid_ind = 1)")
   CALL parser(
    "    reply->patients[patient_cnt].confid_level = uar_get_collation_seq(e.confid_level_cd)")
   CALL parser("  endif ")
   CALL parser("  if (reply->patients[patient_cnt].confid_level < 0)")
   CALL parser("    reply->patients[patient_cnt].confid_level = 0 ")
   CALL parser("  endif ")
   CALL parser("  endif")
   CALL parser(
    "with nocounter,orahintcbo('INDEX(EPR XIE3ENCNTR_PRSNL_RELTN) INDEX(E XPKENCOUNTER) LEADING(EPR ELH E P) USE_NL(E P)') go"
    )
 END ;Subroutine
 SUBROUTINE (executelifeprimaryselect(x=i4) =null)
   DECLARE useelh = i2 WITH noconstant(0)
   DECLARE usee = i2 WITH noconstant(0)
   DECLARE l = i4 WITH noconstant(0)
   DECLARE nsize = i4 WITH noconstant(5)
   DECLARE nstart = i4 WITH noconstant(1)
   DECLARE ntotal = i4 WITH noconstant(0)
   SET nstart = 1
   SET nsize = 50
   SET ntotal = (ceil((cnvtreal(prov_reltn->life_cnt)/ nsize)) * nsize)
   SET stat = alterlist(prov_reltn->life,ntotal)
   IF ((((criteria->locations.unit_cnt > 0)) OR ((((criteria->service_cnt > 0)) OR ((criteria->
   type_cnt > 0))) )) )
    SET usee = 1
   ENDIF
   IF ((criteria->time_frame_flag != notimeparameter)
    AND usee)
    SET useelh = 1
   ENDIF
   IF (usee=0
    AND (((criteria->admit_flag > 0)) OR ((((criteria->discharge_flag > 0)) OR ((criteria->
   lookforward_admit_flag > 0))) )) )
    SET usee = 1
   ENDIF
   CALL parser("select into 'nl:'")
   CALL parser("from (dummyt d1 with seq = value(1+((ntotal-1)/nsize))),")
   CALL parser("person_prsnl_reltn ppr,")
   CALL parser("person p")
   IF (usee > 0)
    CALL parser(", encounter e")
   ENDIF
   IF (useelh > 0)
    CALL parser(", encntr_loc_hist elh")
   ENDIF
   CALL parser("plan d1 where initarray( nstart, evaluate(d1.seq,1,1,nstart+nsize))")
   CALL parser("join ppr where expand(x, nstart, nstart+(nsize-1), ")
   CALL parser("          ppr.prsnl_person_id , prov_reltn->life[x].pgr_id")
   CALL parser("        ,ppr.person_prsnl_r_cd ,  prov_reltn->life[x].ppr_cd)")
   CALL parser("and ppr.active_ind = 1")
   CALL parser("and ppr.beg_effective_dt_tm < cnvtdatetime(curdate, curtime3)")
   CALL parser("and ppr.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)")
   CALL parser("join p where p.person_id = ppr.person_id")
   CALL parser("and p.active_ind = 1")
   IF (usee > 0)
    CALL parseencounterbyencntr("E.person_id = P.person_id",1)
    IF (useelh > 0)
     CALL parseencntrlochistbyencntr("E.encntr_id")
    ENDIF
   ENDIF
   CALL parser("order by p.person_id")
   IF (useelh > 0)
    CALL parser(", ELH.end_effective_dt_tm desc")
   ENDIF
   CALL parser("head p.person_id")
   CALL parser("idx = locateval (l, 1, patient_cnt, p.person_id, reply->patients[l].person_id)")
   CALL parser("if (idx = 0)")
   CALL parser("patient_cnt = patient_cnt+1")
   CALL parser("if(mod(patient_cnt,100) = 1)")
   CALL parser("stat = alterlist(reply->patients,patient_cnt+99)")
   CALL parser("endif")
   CALL parser("reply->patients[patient_cnt].person_id = p.person_id")
   CALL parser("reply->patients[patient_cnt].person_name = p.name_full_formatted")
   CALL parser("reply->patients[patient_cnt].filter_ind = 0")
   CALL parser("reply->patients[patient_cnt].encntr_id = 0")
   CALL parser("reply->patients[patient_cnt].responsible_prsnl_id = ppr.prsnl_person_id")
   CALL parser("reply->patients[patient_cnt].responsible_reltn_cd = ppr.person_prsnl_r_cd")
   CALL parser("reply->patients[patient_cnt].responsible_reltn_id = ppr.person_prsnl_reltn_id")
   CALL parser("reply->patients[patient_cnt].responsible_reltn_flag = 0")
   CALL parser("reply->patients[patient_cnt].active_ind = 1")
   CALL parser("  reply->patients[patient_cnt].birthdate = p.birth_dt_tm")
   CALL parser("  reply->patients[patient_cnt].birth_tz = p.birth_tz")
   CALL parser("  reply->patients[patient_cnt].gender_cd = p.sex_cd")
   CALL parser("  reply->patients[patient_cnt].vip_cd = p.vip_cd")
   CALL parser("  reply->patients[patient_cnt].deceased_date = p.deceased_dt_tm")
   CALL parser("  reply->patients[patient_cnt].deceased_tz = p.deceased_tz")
   IF (usee)
    CALL parser("reply->patients[patient_cnt].encntr_id = E.encntr_id")
    CALL parser("reply->patients[patient_cnt].organization_id = e.organization_id")
    CALL parser("reply->patients[patient_cnt].confid_level_cd = e.confid_level_cd")
    CALL parser("  reply->patients[patient_cnt].end_effective_dt_tm = e.end_effective_dt_tm")
    CALL parser("  reply->patients[patient_cnt].service_cd = e.med_service_cd")
    CALL parser("  reply->patients[patient_cnt].temp_location_cd = e.loc_temp_cd")
    CALL parser("  reply->patients[patient_cnt].visit_reason = e.reason_for_visit")
    CALL parser("  reply->patients[patient_cnt].visitor_status_cd = e.visitor_status_cd")
    IF (encntr_org_sec_ind=0)
     CALL parser("reply->patients[patient_cnt].filter_ind = 0")
    ELSE
     CALL parser("reply->patients[patient_cnt].filter_ind = 1")
    ENDIF
    IF (confid_ind=1)
     CALL parser(
      "reply->patients[patient_cnt].confid_level = maxval(0, uar_get_collation_seq(e.confid_level_cd))"
      )
    ENDIF
   ELSE
    CALL parser("reply->patients[patient_cnt].filter_ind = 0")
   ENDIF
   CALL parser("endif")
   CALL parser("detail")
   CALL parser(
    "if (idx = 0 and reply->patients[patient_cnt].responsible_prsnl_id != reqinfo->updt_id)")
   CALL parser("if (ppr.prsnl_person_id = reqinfo->updt_id)")
   CALL parser("reply->patients[patient_cnt].responsible_prsnl_id = ppr.prsnl_person_id")
   CALL parser("reply->patients[patient_cnt].responsible_reltn_cd = ppr.person_prsnl_r_cd")
   CALL parser("reply->patients[patient_cnt].responsible_reltn_id = ppr.person_prsnl_reltn_id")
   CALL parser("reply->patients[patient_cnt].responsible_reltn_flag = 0")
   CALL parser("reply->patients[patient_cnt].active_ind = 1")
   CALL parser("endif")
   CALL parser("endif")
   CALL parser("with nocounter ,orahintcbo('LEADING(PPR) INDEX(PPR  XIE1PERSON_PRSNL_RELTN)') go")
   SET stat = alterlist(reply->patients,patient_cnt)
 END ;Subroutine
 SUBROUTINE populateprovidernames(null)
   DECLARE i = i4 WITH noconstant(0)
   DECLARE j = i4 WITH noconstant(0), private
   DECLARE prsnlcnt = i2 WITH noconstant(0)
   FREE SET temp
   RECORD temp(
     1 persons[*]
       2 person_id = f8
       2 name = vc
   )
   IF (patient_cnt > 0)
    SELECT INTO "nl:"
     FROM prsnl_group_reltn pgr,
      prsnl p
     PLAN (pgr
      WHERE pgr.prsnl_group_id=prsnl_group_id)
      JOIN (p
      WHERE p.person_id=pgr.person_id)
     ORDER BY p.person_id
     HEAD p.person_id
      prsnlcnt += 1
      IF (mod(prsnlcnt,50)=1)
       stat = alterlist(temp->persons,(prsnlcnt+ 49))
      ENDIF
      temp->persons[prsnlcnt].person_id = p.person_id, temp->persons[prsnlcnt].name = p
      .name_full_formatted
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = prsnlcnt),
      (dummyt d2  WITH seq = patient_cnt)
     PLAN (d1)
      JOIN (d2
      WHERE (reply->patients[d2.seq].responsible_prsnl_id=temp->persons[d1.seq].person_id))
     DETAIL
      reply->patients[d2.seq].responsible_prsnl_name = temp->persons[d1.seq].name
     WITH nocounter
    ;end select
   ENDIF
   FREE SET temp
 END ;Subroutine
 SUBROUTINE evaluatetimecriteria(null)
  DECLARE etc = i2 WITH noconstant(0)
  IF ((criteria->time_frame_flag=notimeparameter))
   RETURN(0)
  ELSE
   RETURN(1)
  ENDIF
 END ;Subroutine
 SUBROUTINE deleteexpiredremovedrows(null)
   RECORD temp(
     1 row_cnt = i4
     1 row[*]
       2 priority_id = f8
       2 encntr_id = f8
       2 person_id = f8
       2 epr_ind = i2
   )
   SET temp->row_cnt = 0
   DECLARE visitx1 = i4 WITH noconstant(0)
   DECLARE lifex1 = i4 WITH noconstant(0)
   DECLARE nsize = i4 WITH noconstant(5)
   DECLARE nstart = i4 WITH noconstant(1)
   DECLARE ntotal = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM dcp_pl_prioritization dpp
    WHERE (dpp.patient_list_id=request->patient_list_id)
     AND dpp.remove_ind=1
    DETAIL
     temp->row_cnt += 1
     IF (mod(temp->row_cnt,25)=1)
      stat = alterlist(temp->row,(temp->row_cnt+ 24))
     ENDIF
     temp->row[temp->row_cnt].priority_id = dpp.priority_id, temp->row[temp->row_cnt].encntr_id = 0,
     temp->row[temp->row_cnt].encntr_id = dpp.encntr_id,
     temp->row[temp->row_cnt].person_id = dpp.person_id, temp->row[temp->row_cnt].epr_ind = 0
    FOOT REPORT
     stat = alterlist(temp->row,temp->row_cnt)
    WITH nocounter
   ;end select
   SET nstart = 1
   CALL echo(build("visit_count",prov_reltn->visit_cnt))
   IF ((prov_reltn->visit_cnt > 0)
    AND (temp->row_cnt > 0))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(temp->row_cnt)),
      encntr_prsnl_reltn epr
     PLAN (d
      WHERE (temp->row[d.seq].encntr_id != 0))
      JOIN (epr
      WHERE (epr.encntr_id=temp->row[d.seq].encntr_id)
       AND epr.expiration_ind=0
       AND epr.active_ind=1
       AND epr.manual_inact_ind=0
       AND epr.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND expand(visitx1,nstart,prov_reltn->visit_cnt,epr.prsnl_person_id,prov_reltn->visit[visitx1]
       .pgr_id,
       epr.encntr_prsnl_r_cd,prov_reltn->visit[visitx1].ppr_cd))
     DETAIL
      temp->row[d.seq].priority_id = 0.0, temp->row[d.seq].epr_ind = 1
     WITH nocounter
    ;end select
   ENDIF
   IF ((prov_reltn->life_cnt > 0)
    AND (temp->row_cnt > 0))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(temp->row_cnt)),
      person_prsnl_reltn ppr
     PLAN (d
      WHERE (temp->row[d.seq].epr_ind=0))
      JOIN (ppr
      WHERE (ppr.person_id=temp->row[d.seq].person_id)
       AND ppr.active_ind=1
       AND ppr.manual_inact_ind=0
       AND ppr.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND ppr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND expand(lifex1,nstart,prov_reltn->life_cnt,ppr.prsnl_person_id,prov_reltn->life[lifex1].
       pgr_id,
       ppr.person_prsnl_r_cd,prov_reltn->life[lifex1].ppr_cd))
     DETAIL
      temp->row[d.seq].priority_id = 0.0
     WITH nocounter
    ;end select
   ENDIF
   DELETE  FROM dcp_pl_prioritization p,
     (dummyt d  WITH seq = value(temp->row_cnt))
    SET p.seq = 1
    PLAN (d)
     JOIN (p
     WHERE (p.priority_id=temp->row[d.seq].priority_id)
      AND (p.patient_list_id=request->patient_list_id)
      AND p.remove_ind=1
      AND p.priority_id > 0)
    WITH nocounter
   ;end delete
   FREE RECORD temp
 END ;Subroutine
END GO
