CREATE PROGRAM ams_inactive_beds_prompts:dba
 PROMPT
  "Select" = "MINE",
  "Select Organization(s)" = 0,
  "Select Nurse Units" = 0,
  "Rooms" = 0,
  "Bed" = 0
  WITH outdev, org, nurse_unit,
  room, bed
 DECLARE cnt = i4 WITH public
 DECLARE cnt1 = i4 WITH public
 DECLARE cnt2 = i4 WITH public
 DECLARE cnt3 = i4 WITH public
 DECLARE inactive_var = f8 WITH constant(uar_get_code_by("MEANING",48,"INACTIVE")), protect
 DECLARE facility_var = f8 WITH constant(uar_get_code_by("MEANING",222,"FACILITY")), protect
 DECLARE room_cd = f8 WITH public
 DECLARE org_code = f8 WITH public
 DECLARE inact = i4 WITH public
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
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 DECLARE smessage = vc WITH protect, noconstant("")
 FREE RECORD rdata
 RECORD rdata(
   1 qual_knt = i4
   1 qual[*]
     2 object_name = vc
     2 user_name = vc
     2 compiled_dt_tm = vc
     2 source_name = vc
 )
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  CALL echo("manju2")
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 FREE RECORD request_new
 RECORD request_new(
   1 location_cd = f8
   1 organization_id = f8
   1 rooms[*]
     2 room_cd = f8
     2 updt_cnt = i4
     2 sequence = i4
     2 class_cd = f8
     2 med_service_cd = f8
     2 isolation_cd = f8
     2 resource_ind = i2
     2 active_ind = i2
     2 census_ind = i2
     2 fixed_bed_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 description = c200
     2 short_desc = c15
     2 definition = c100
     2 collation_seq = i4
     2 facility_accn_prefix = c5
     2 bed_cnt = i4
     2 beds[*]
       3 bed_cd = f8
       3 updt_cnt = i4
       3 sequence = i4
       3 resource_ind = i2
       3 active_ind = i2
       3 census_ind = i2
       3 dup_bed_ind = i2
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 description = c200
       3 short_desc = c15
       3 definition = c100
       3 collation_seq = i4
       3 facility_accn_prefix = c5
       3 reserve_ind = i2
 )
 FREE RECORD room_beds
 RECORD room_beds(
   1 orgs[*]
     2 org = f8
     2 nurseunits[*]
       3 nurseunit = f8
       3 rooms[*]
         4 room = f8
         4 room_updt_cnt = i4
         4 active_ind = i2
         4 beg_effective_dt_tm = dq8
         4 end_effective_dt_tm = dq8
         4 display = vc
         4 short_desc = vc
         4 description = vc
         4 beds[*]
           5 bed = f8
           5 updt_cnt = i4
           5 sequence = i4
           5 resource_ind = i2
           5 active_ind = i2
           5 census_ind = i2
           5 dup_bed_ind = i2
           5 beg_effective_dt_tm = dq8
           5 end_effective_dt_tm = dq8
           5 description = c200
           5 short_desc = c15
           5 definition = c100
           5 collation_seq = i4
           5 facility_accn_prefix = c5
           5 reserve_ind = i2
 )
 FREE RECORD bed_inact
 RECORD bed_inact(
   1 qual[*]
     2 parent_loc_cd = f8
     2 child_loc_cd = f8
 )
 FREE RECORD request_inact
 RECORD request_inact(
   1 qual[*]
     2 parent_loc_cd = f8
     2 child_loc_cd = f8
     2 cdf_meaning = c12
     2 root_loc_cd = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_cnt = i4
 )
 SET cnt1 = 0
 SET cnt2 = 0
 SET cnt3 = 0
 SELECT INTO "nl:"
  o.org_name, o.organization_id, uar_get_code_description(l.location_cd),
  uar_get_code_description(lg1.parent_loc_cd), uar_get_code_description(lg2.child_loc_cd),
  uar_get_code_description(cv1.code_value),
  uar_get_code_description(cv2.code_value)
  FROM organization o,
   location l,
   location_group lg1,
   location_group lg2,
   code_value cv,
   location_group lg3,
   code_value cv1,
   location_group lg4,
   code_value cv2
  PLAN (o
   WHERE o.organization_id IN ( $ORG)
    AND o.active_ind=1
    AND o.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (l
   WHERE l.organization_id=o.organization_id
    AND l.location_type_cd=facility_var)
   JOIN (lg1
   WHERE lg1.parent_loc_cd=l.location_cd
    AND lg1.root_loc_cd=0.0
    AND lg1.active_ind=1
    AND lg1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND lg1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND lg1.active_status_cd != 0.0)
   JOIN (lg2
   WHERE lg2.parent_loc_cd=lg1.child_loc_cd
    AND lg2.child_loc_cd IN ( $NURSE_UNIT)
    AND lg2.root_loc_cd=0.0
    AND lg2.active_ind=1
    AND lg2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND lg2.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND lg2.active_status_cd != 0.0)
   JOIN (cv
   WHERE cv.code_value=lg2.child_loc_cd
    AND cv.cdf_meaning="NURSEUNIT"
    AND cv.code_set=220
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (lg3
   WHERE lg3.parent_loc_cd=lg2.child_loc_cd
    AND lg3.child_loc_cd IN ( $ROOM)
    AND lg3.root_loc_cd=0.0
    AND lg3.active_ind=1
    AND lg3.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND lg3.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND lg3.active_status_cd != 0.0)
   JOIN (cv1
   WHERE cv1.code_value=lg3.child_loc_cd
    AND cv1.cdf_meaning="ROOM"
    AND cv1.active_ind=1
    AND cv1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (lg4
   WHERE lg4.parent_loc_cd=cv1.code_value
    AND lg4.child_loc_cd IN ( $BED)
    AND lg4.root_loc_cd=0.0
    AND lg4.active_ind=1
    AND lg4.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND lg4.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND lg4.active_status_cd != 0.0)
   JOIN (cv2
   WHERE cv2.code_value=lg4.child_loc_cd
    AND cv2.cdf_meaning="BED"
    AND cv2.active_ind=1
    AND cv2.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY o.organization_id, lg2.child_loc_cd, cv1.code_value,
   cv2.code_value
  HEAD REPORT
   cnt = 0
  HEAD o.organization_id
   cnt = (cnt+ 1),
   CALL echo("org section"), stat = alterlist(room_beds->orgs,cnt),
   room_beds->orgs[cnt].org = o.organization_id, cnt1 = 0
  HEAD lg2.child_loc_cd
   cnt1 = (cnt1+ 1), stat = alterlist(room_beds->orgs[cnt].nurseunits,cnt1), room_beds->orgs[cnt].
   nurseunits[cnt1].nurseunit = lg2.child_loc_cd,
   cnt2 = 0
  HEAD cv1.code_value
   cnt2 = (cnt2+ 1), stat = alterlist(room_beds->orgs[cnt].nurseunits[cnt1].rooms,cnt2), room_beds->
   orgs[cnt].nurseunits[cnt1].rooms[cnt2].room = cv1.code_value,
   room_beds->orgs[cnt].nurseunits[cnt1].rooms[cnt2].room_updt_cnt = cv1.updt_cnt, room_beds->orgs[
   cnt].nurseunits[cnt1].rooms[cnt2].beg_effective_dt_tm = cv1.begin_effective_dt_tm, room_beds->
   orgs[cnt].nurseunits[cnt1].rooms[cnt2].end_effective_dt_tm = cv1.end_effective_dt_tm,
   room_beds->orgs[cnt].nurseunits[cnt1].rooms[cnt2].active_ind = cv1.active_ind, room_beds->orgs[cnt
   ].nurseunits[cnt1].rooms[cnt2].short_desc = cv1.display, room_beds->orgs[cnt].nurseunits[cnt1].
   rooms[cnt2].description = cv1.description,
   cnt3 = 0
  HEAD cv2.code_value
   cnt3 = (cnt3+ 1), stat = alterlist(room_beds->orgs[cnt].nurseunits[cnt1].rooms[cnt2].beds,cnt3),
   room_beds->orgs[cnt].nurseunits[cnt1].rooms[cnt2].beds[cnt3].bed = cv2.code_value,
   room_beds->orgs[cnt].nurseunits[cnt1].rooms[cnt2].beds[cnt3].updt_cnt = cv2.updt_cnt, room_beds->
   orgs[cnt].nurseunits[cnt1].rooms[cnt2].beds[cnt3].active_ind = cv2.active_ind, room_beds->orgs[cnt
   ].nurseunits[cnt1].rooms[cnt2].beds[cnt3].census_ind = 1,
   room_beds->orgs[cnt].nurseunits[cnt1].rooms[cnt2].beds[cnt3].beg_effective_dt_tm = cv2
   .begin_effective_dt_tm, room_beds->orgs[cnt].nurseunits[cnt1].rooms[cnt2].beds[cnt3].
   end_effective_dt_tm = cnvtdatetime(curdate,curtime3), room_beds->orgs[cnt].nurseunits[cnt1].rooms[
   cnt2].beds[cnt3].description = cv2.description,
   room_beds->orgs[cnt].nurseunits[cnt1].rooms[cnt2].beds[cnt3].short_desc = cv2.display, room_beds->
   orgs[cnt].nurseunits[cnt1].rooms[cnt2].beds[cnt3].reserve_ind = 0, inact = (inact+ 1),
   stat = alterlist(bed_inact->qual,inact), bed_inact->qual[inact].parent_loc_cd = lg4.parent_loc_cd,
   bed_inact->qual[inact].child_loc_cd = cv2.code_value
  FOOT  cv2.code_value
   stat = alterlist(room_beds->orgs[cnt].nurseunits[cnt1].rooms[cnt2].beds,cnt3)
  FOOT  cv1.code_value
   stat = alterlist(room_beds->orgs[cnt].nurseunits[cnt1].rooms,cnt2)
  FOOT  lg2.child_loc_cd
   stat = alterlist(room_beds->orgs[cnt].nurseunits,cnt1)
  FOOT  o.organization_id
   stat = alterlist(room_beds->orgs,cnt)
  WITH nocounter
 ;end select
 CALL echorecord(room_beds)
 SET cnt = 0
 FOR (cnt = 1 TO size(room_beds->orgs,5))
   SET request_new->organization_id = room_beds->orgs[cnt].org
   SET cnt1 = 0
   FOR (cnt1 = 1 TO size(room_beds->orgs[cnt].nurseunits,5))
     SET request_new->location_cd = room_beds->orgs[cnt].nurseunits[cnt1].nurseunit
     SET cnt2 = 0
     FOR (cnt2 = 1 TO size(room_beds->orgs[cnt].nurseunits[cnt1].rooms,5))
       SET stat = alterlist(request_new->rooms,cnt2)
       SET request_new->rooms[cnt2].room_cd = room_beds->orgs[cnt].nurseunits[cnt1].rooms[cnt2].room
       SET request_new->rooms[cnt2].updt_cnt = room_beds->orgs[cnt].nurseunits[cnt1].rooms[cnt2].
       room_updt_cnt
       SET request_new->rooms[cnt2].beg_effective_dt_tm = room_beds->orgs[cnt].nurseunits[cnt1].
       rooms[cnt2].beg_effective_dt_tm
       SET request_new->rooms[cnt2].end_effective_dt_tm = room_beds->orgs[cnt].nurseunits[cnt1].
       rooms[cnt2].end_effective_dt_tm
       SET request_new->rooms[cnt2].short_desc = room_beds->orgs[cnt].nurseunits[cnt1].rooms[cnt2].
       display
       SET request_new->rooms[cnt2].description = room_beds->orgs[cnt].nurseunits[cnt1].rooms[cnt2].
       description
       SET request_new->rooms[cnt2].sequence = 0
       SET request_new->rooms[cnt2].class_cd = 0.0
       SET request_new->rooms[cnt2].med_service_cd = 0.0
       SET request_new->rooms[cnt2].isolation_cd = 0.0
       SET request_new->rooms[cnt2].resource_ind = 0
       SET request_new->rooms[cnt2].census_ind = 1
       SET request_new->rooms[cnt2].fixed_bed_ind = 0
       SET request_new->rooms[cnt2].active_ind = room_beds->orgs[cnt].nurseunits[cnt1].rooms[cnt2].
       active_ind
       SET request_new->rooms[cnt2].collation_seq = 0
       SET request_new->rooms[cnt2].bed_cnt = value(size(room_beds->orgs[cnt].nurseunits[cnt1].rooms[
         cnt2].beds,5))
       SET cnt3 = 0
       FOR (cnt3 = 1 TO size(room_beds->orgs[cnt].nurseunits[cnt1].rooms[cnt2].beds,5))
         SET stat = alterlist(request_new->rooms[cnt2].beds,cnt3)
         SET request_new->rooms[cnt2].beds[cnt3].bed_cd = room_beds->orgs[cnt].nurseunits[cnt1].
         rooms[cnt2].beds[cnt3].bed
         SET request_new->rooms[cnt2].beds[cnt3].updt_cnt = room_beds->orgs[cnt].nurseunits[cnt1].
         rooms[cnt2].beds[cnt3].updt_cnt
         SET request_new->rooms[cnt2].beds[cnt3].active_ind = room_beds->orgs[cnt].nurseunits[cnt1].
         rooms[cnt2].beds[cnt3].active_ind
         SET request_new->rooms[cnt2].beds[cnt3].census_ind = 1
         SET request_new->rooms[cnt2].beds[cnt3].beg_effective_dt_tm = room_beds->orgs[cnt].
         nurseunits[cnt1].rooms[cnt2].beds[cnt3].beg_effective_dt_tm
         SET request_new->rooms[cnt2].beds[cnt3].end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
         SET request_new->rooms[cnt2].beds[cnt3].description = room_beds->orgs[cnt].nurseunits[cnt1].
         rooms[cnt2].beds[cnt3].description
         SET request_new->rooms[cnt2].beds[cnt3].short_desc = room_beds->orgs[cnt].nurseunits[cnt1].
         rooms[cnt2].beds[cnt3].definition
         SET request_new->rooms[cnt2].beds[cnt3].reserve_ind = 0
       ENDFOR
     ENDFOR
     CALL echorecord(request_new)
     EXECUTE loc_chg_room_bed:dba  WITH replace("REQUEST",request_new)
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  lg.*
  FROM (dummyt d  WITH seq = value(size(bed_inact->qual,5))),
   location_group lg
  PLAN (d)
   JOIN (lg
   WHERE (lg.parent_loc_cd=bed_inact->qual[d.seq].parent_loc_cd)
    AND (lg.child_loc_cd=bed_inact->qual[d.seq].child_loc_cd)
    AND lg.root_loc_cd=0.0)
  ORDER BY lg.child_loc_cd
  HEAD REPORT
   cnt4 = 0
  HEAD lg.child_loc_cd
   cnt4 = (cnt4+ 1),
   CALL echo(cnt4), stat = alterlist(request_inact->qual,cnt4),
   request_inact->qual[cnt4].parent_loc_cd = lg.parent_loc_cd, request_inact->qual[cnt4].child_loc_cd
    = lg.child_loc_cd, request_inact->qual[cnt4].cdf_meaning = "ROOM",
   request_inact->qual[cnt4].active_ind = 0, request_inact->qual[cnt4].active_status_cd =
   inactive_var, request_inact->qual[cnt4].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   request_inact->qual[cnt4].end_effective_dt_tm = cnvtdatetime(curdate,curtime3), request_inact->
   qual[cnt4].root_loc_cd = 0.0, request_inact->qual[cnt4].updt_cnt = lg.updt_cnt
  WITH nocounter
 ;end select
 CALL echorecord(request_inact)
 EXECUTE loc_chg_loc_group_active:dba  WITH replace("REQUEST",request_inact)
 SELECT INTO  $OUTDEV
  status = "Succesfully Inactivated all the given beds in the respected oorganizations"
  FROM dummyt d1
  WITH nocounter, format
 ;end select
#exit_script
 IF (failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
END GO
