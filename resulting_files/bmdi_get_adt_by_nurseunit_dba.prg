CREATE PROGRAM bmdi_get_adt_by_nurseunit:dba
 RECORD reply(
   1 unit_list[*]
     2 facility_cd = f8
     2 building_cd = f8
     2 unit_cd = f8
     2 unit_sequence = i4
     2 room_list[*]
       3 room_cd = f8
       3 room_sequence = i4
       3 bed_list[*]
         4 device_alias = c40
         4 device_cd = f8
         4 location_cd = f8
         4 location_sequence = i4
         4 association_id = f8
         4 association_dt_tm = dq8
         4 dis_association_dt_tm = dq8
         4 person_id = f8
         4 name_full_formatted = vc
         4 parent_entity_name = c32
         4 parent_entity_id = f8
         4 active_ind = i2
         4 assoc_prsnl_id = f8
         4 dissoc_prsnl_id = f8
         4 upd_status_cd = f8
         4 hint_id = f8
         4 device_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD reply_1(
   1 unit_list[*]
     2 unit_cd = f8
     2 unit_sequence = i4
     2 room_list[*]
       3 room_cd = f8
       3 room_sequence = i4
       3 bed_list[*]
         4 device_alias = c40
         4 device_cd = f8
         4 location_cd = f8
         4 location_sequence = i4
         4 association_id = f8
         4 association_dt_tm = dq8
         4 dis_association_dt_tm = dq8
         4 person_id = f8
         4 parent_entity_name = c32
         4 parent_entity_id = f8
         4 active_ind = i2
         4 assoc_prsnl_id = f8
         4 dissoc_prsnl_id = f8
         4 upd_status_cd = f8
         4 hint_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD req_locs_child(
   1 location_cd = f8
   1 search_depth = i4
 )
 RECORD rep_locs_child(
   1 qual[*]
     2 level = i4
     2 parent_loc_cd = f8
     2 location_cd = f8
     2 location_disp = c40
     2 location_desc = c60
     2 location_mean = c12
     2 sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD child_list(
   1 facility_cd = f8
   1 building_cd = f8
   1 unit_cd = f8
   1 unit_sequence = i4
   1 room_list[*]
     2 room_cd = f8
     2 room_sequence = i4
     2 bed_list[1]
       3 device_alias = c40
       3 device_cd = f8
       3 location_cd = f8
       3 location_sequence = i4
       3 association_id = f8
       3 association_dt_tm = dq8
       3 dis_association_dt_tm = dq8
       3 person_id = f8
       3 parent_entity_name = c32
       3 parent_entity_id = f8
       3 active_ind = i2
       3 assoc_prsnl_id = f8
       3 dissoc_prsnl_id = f8
       3 upd_status_cd = f8
       3 hint_id = f8
       3 device_ind = i2
 )
 RECORD location_list(
   1 list[*]
     2 device_alias = c40
     2 device_cd = f8
     2 location_cd = f8
     2 association_id = f8
     2 association_dt_tm = dq8
     2 dis_association_dt_tm = dq8
     2 person_id = f8
     2 parent_entity_name = c32
     2 parent_entity_id = f8
     2 active_ind = i2
     2 assoc_prsnl_id = f8
     2 dissoc_prsnl_id = f8
     2 upd_status_cd = f8
     2 hint_id = f8
     2 device_ind = i2
 )
 SET reply->status_data.status = "F"
 SET sfailed = "S"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = 0
 SET sall = 0
 DECLARE unit_list_size = i2 WITH private, noconstant
 DECLARE room_list_size = i2 WITH private, noconstant(0)
 DECLARE bed_list_size = i2 WITH private, noconstant(0)
 DECLARE rep_size = i2 WITH private, noconstant(0)
 DECLARE i = i2 WITH private, noconstant(0)
 DECLARE j = i2 WITH private, noconstant(0)
 DECLARE k = i2 WITH private, noconstant(0)
 DECLARE a = i2 WITH private, noconstant(0)
 DECLARE b = i2 WITH private, noconstant(0)
 DECLARE c = i2 WITH private, noconstant(0)
 DECLARE x = i2 WITH private, noconstant(0)
 DECLARE y = i2 WITH private, noconstant(0)
 DECLARE z = i2 WITH private, noconstant(0)
 DECLARE tot_bed_size = i2 WITH private, noconstant(0)
 DECLARE exitwhile = i2 WITH private, noconstant(0)
 DECLARE locationcount = i2 WITH private, noconstant(0)
 DECLARE locationindex = i2 WITH private, noconstant(0)
 DECLARE unitsize = i2 WITH private, noconstant(0)
 DECLARE unitindex = i2 WITH private, noconstant(0)
 DECLARE savedunitindex = i2 WITH private, noconstant(0)
 DECLARE roomindex = i2 WITH private, noconstant(0)
 DECLARE roomsize = i2 WITH private, noconstant(0)
 DECLARE savedroomindex = i2 WITH private, noconstant(0)
 DECLARE bedindex = i2 WITH private, noconstant(0)
 DECLARE bedsize = i2 WITH private, noconstant(0)
 DECLARE savedbedindex = i2 WITH private, noconstant(0)
 DECLARE locationcd = f8 WITH noconstant(0.0)
 DECLARE facilitytypecd = f8 WITH constant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE buildingtypecd = f8 WITH constant(uar_get_code_by("MEANING",222,"BUILDING"))
 DECLARE unittypecd = f8 WITH constant(uar_get_code_by("MEANING",222,"NURSEUNIT"))
 DECLARE ambulatorytypecd = f8 WITH constant(uar_get_code_by("MEANING",222,"AMBULATORY"))
 DECLARE roomtypecd = f8 WITH constant(uar_get_code_by("MEANING",222,"ROOM"))
 DECLARE ignorefromreply = i2 WITH private, noconstant(0)
 DECLARE custom_options = vc
 DECLARE def_facility_cd = f8 WITH public, noconstant(0.0)
 DECLARE def_building_cd = f8 WITH public, noconstant(0.0)
 DECLARE logical_dm_id = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  ld.logical_domain_id
  FROM logical_domain ld
  WHERE ld.logical_domain_id > 0
   AND ld.active_ind=1
  WITH nocounter
 ;end select
 IF (curqual >= 1)
  SET logical_dm_id = 1
 ENDIF
 IF (logical_dm_id=1)
  EXECUTE bmdi_get_adt_by_logical_dm_id
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM strt_model_custom smc
  WHERE smc.strt_model_id=0
   AND smc.strt_config_id=1282103
   AND process_flag=10
  DETAIL
   custom_options = smc.custom_option
  WITH nocounter
 ;end select
 IF (curqual=1)
  IF (substring(2,1,custom_options)="1")
   CALL echo("Executing bmdi_get_adt_by_nurseunit_new script")
   CALL echorecord(request)
   EXECUTE bmdi_get_adt_new
   GO TO end_script
  ENDIF
  IF (substring(1,1,custom_options)="1")
   IF ((request->facility_ind=1)
    AND (request->unit_cd > 0))
    SET request->unit_cd = 0
    CALL echo("do all facilities")
   ENDIF
  ENDIF
 ENDIF
 IF ((request->unit_cd=0))
  SET sall = 1
 ELSE
  DECLARE loc_mean = c13 WITH private, noconstant("")
  SET loc_mean = uar_get_code_meaning(request->unit_cd)
  IF (cnvtupper(trim(loc_mean)) != "NURSEUNIT"
   AND cnvtupper(trim(loc_mean)) != "AMBULATORY")
   SET sfailed = "N"
   GO TO no_valid_ids
  ENDIF
  SET locationcd = request->unit_cd
  SET exitwhile = 0
  WHILE (exitwhile=0)
   SELECT INTO "nl:"
    FROM location_group lg
    WHERE lg.child_loc_cd=locationcd
     AND lg.location_group_type_cd IN (facilitytypecd, buildingtypecd)
     AND ((lg.root_loc_cd+ 0)=0.0)
     AND lg.active_ind=1
    DETAIL
     IF (uar_get_code_meaning(lg.parent_loc_cd)="BUILDING")
      def_building_cd = lg.parent_loc_cd
     ELSEIF (uar_get_code_meaning(lg.parent_loc_cd)="FACILITY")
      def_facility_cd = lg.parent_loc_cd
     ENDIF
    FOOT REPORT
     locationcd = lg.parent_loc_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET exitwhile = 1
   ENDIF
  ENDWHILE
  IF ((request->facility_ind=1))
   SET sall = 1
  ENDIF
 ENDIF
 IF (sall=0)
  SET req_locs_child->location_cd = request->unit_cd
  SET req_locs_child->search_depth = 2
  EXECUTE dcp_get_child_locations  WITH replace("REQUEST","REQ_LOCS_CHILD"), replace("REPLY",
   "REP_LOCS_CHILD")
  IF ((rep_locs_child->status_data.status != "S"))
   SET sfailed = "C"
   GO TO failure_called_script
  ENDIF
  SET rep_size = size(rep_locs_child->qual,5)
  IF (rep_size <= 1)
   SET sfailed = "CZ"
   GO TO failure_called_script
  ENDIF
  SET stat = alterlist(reply->unit_list,1)
  SET reply->unit_list[1].unit_cd = request->unit_cd
  SET reply->unit_list[1].facility_cd = def_facility_cd
  SET reply->unit_list[1].building_cd = def_building_cd
  FOR (i = 1 TO rep_size)
    IF ((rep_locs_child->qual[i].level=1))
     SET room_list_size = size(reply->unit_list[1].room_list,5)
     SET stat = alterlist(reply->unit_list[1].room_list,(room_list_size+ 1))
     SET reply->unit_list[1].room_list[(room_list_size+ 1)].room_cd = rep_locs_child->qual[i].
     location_cd
     SET reply->unit_list[1].room_list[(room_list_size+ 1)].room_sequence = rep_locs_child->qual[i].
     sequence
    ENDIF
  ENDFOR
  SET unit_list_size = 1
  SET room_list_size = size(reply->unit_list[1].room_list,5)
  FOR (i = 1 TO rep_size)
    IF ((rep_locs_child->qual[i].level=2))
     SET tot_bed_size = (tot_bed_size+ 1)
     FOR (j = 1 TO room_list_size)
       IF ((rep_locs_child->qual[i].parent_loc_cd=reply->unit_list[1].room_list[j].room_cd))
        SET bed_list_size = size(reply->unit_list[1].room_list[j].bed_list,5)
        SET stat = alterlist(reply->unit_list[1].room_list[j].bed_list,(bed_list_size+ 1))
        SET reply->unit_list[1].room_list[j].bed_list[(bed_list_size+ 1)].location_cd =
        rep_locs_child->qual[i].location_cd
        SET reply->unit_list[1].room_list[j].bed_list[(bed_list_size+ 1)].location_sequence =
        rep_locs_child->qual[i].sequence
        SET j = room_list_size
       ENDIF
     ENDFOR
    ENDIF
  ENDFOR
  SELECT INTO "nl:"
   unit_disp = uar_get_code_display(reply->unit_list[du.seq].unit_cd), room_disp =
   uar_get_code_display(reply->unit_list[du.seq].room_list[dr.seq].room_cd), bed_disp =
   uar_get_code_display(reply->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].location_cd),
   unit_seq = reply->unit_list[du.seq].unit_sequence, room_seq = reply->unit_list[du.seq].room_list[
   dr.seq].room_sequence, bed_seq = reply->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].
   location_sequence,
   unit_cd = reply->unit_list[du.seq].unit_cd, room_cd = reply->unit_list[du.seq].room_list[dr.seq].
   room_cd, device_alias = reply->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].device_alias,
   device_cd = reply->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].device_cd, location_cd =
   reply->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].location_cd, association_id = reply->
   unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].association_id,
   association_dt_tm = reply->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].association_dt_tm,
   dis_association_dt_tm = reply->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].
   dis_association_dt_tm, person_id = reply->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].
   person_id,
   parent_entity_name = reply->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].
   parent_entity_name, parent_entity_id = reply->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq]
   .parent_entity_id, active_ind = reply->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].
   active_ind,
   assoc_prsnl_id = reply->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].assoc_prsnl_id,
   dissoc_prsnl_id = reply->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].dissoc_prsnl_id,
   upd_status_cd = reply->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].upd_status_cd,
   hint_id = reply->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].hint_id, device_ind = reply
   ->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].device_ind, spat = p.name_full_formatted
   FROM bmdi_acquired_data_track badt,
    (dummyt du  WITH seq = size(reply->unit_list,5)),
    (dummyt db  WITH seq = 1),
    (dummyt dr  WITH seq = 1),
    bmdi_monitored_device bmd,
    person p
   PLAN (du
    WHERE maxrec(dr,size(reply->unit_list[du.seq].room_list,5)))
    JOIN (dr
    WHERE maxrec(db,size(reply->unit_list[du.seq].room_list[dr.seq].bed_list,5)))
    JOIN (db)
    JOIN (badt
    WHERE (((badt.location_cd=reply->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].location_cd
    )
     AND badt.person_id=0
     AND badt.parent_entity_id=0) OR ((badt.location_cd=reply->unit_list[du.seq].room_list[dr.seq].
    bed_list[db.seq].location_cd)
     AND badt.active_ind=1)) )
    JOIN (bmd
    WHERE bmd.location_cd=badt.location_cd)
    JOIN (p
    WHERE p.person_id=outerjoin(badt.person_id))
   ORDER BY unit_seq, room_seq, bed_seq
   HEAD REPORT
    u_ind = 0, r_ind = 0, b_ind = 0
   HEAD unit_seq
    u_ind = (u_ind+ 1), stat = alterlist(reply->unit_list,u_ind), r_ind = 0,
    b_ind = 0, reply->unit_list[u_ind].unit_cd = unit_cd, reply->unit_list[u_ind].unit_sequence =
    unit_seq
   HEAD room_seq
    r_ind = (r_ind+ 1), stat = alterlist(reply->unit_list[u_ind].room_list,r_ind), b_ind = 0,
    reply->unit_list[u_ind].room_list[r_ind].room_cd = room_cd, reply->unit_list[u_ind].room_list[
    r_ind].room_sequence = room_seq
   HEAD bed_seq
    b_ind = (b_ind+ 1), stat = alterlist(reply->unit_list[u_ind].room_list[r_ind].bed_list,b_ind),
    reply->unit_list[u_ind].room_list[r_ind].bed_list[b_ind].device_alias = bmd.device_alias,
    reply->unit_list[u_ind].room_list[r_ind].bed_list[b_ind].device_cd = badt.device_cd, reply->
    unit_list[u_ind].room_list[r_ind].bed_list[b_ind].location_cd = badt.location_cd, reply->
    unit_list[u_ind].room_list[r_ind].bed_list[b_ind].location_sequence = bed_seq,
    reply->unit_list[u_ind].room_list[r_ind].bed_list[b_ind].association_id = badt.association_id,
    reply->unit_list[u_ind].room_list[r_ind].bed_list[b_ind].association_dt_tm = badt
    .association_dt_tm, reply->unit_list[u_ind].room_list[r_ind].bed_list[b_ind].person_id = badt
    .person_id,
    reply->unit_list[u_ind].room_list[r_ind].bed_list[b_ind].parent_entity_name = badt
    .parent_entity_name, reply->unit_list[u_ind].room_list[r_ind].bed_list[b_ind].parent_entity_id =
    badt.parent_entity_id, reply->unit_list[u_ind].room_list[r_ind].bed_list[b_ind].
    dis_association_dt_tm = badt.dis_association_dt_tm,
    reply->unit_list[u_ind].room_list[r_ind].bed_list[b_ind].active_ind = badt.active_ind, reply->
    unit_list[u_ind].room_list[r_ind].bed_list[b_ind].assoc_prsnl_id = validate(badt.assoc_prsnl_id,
     0.0), reply->unit_list[u_ind].room_list[r_ind].bed_list[b_ind].dissoc_prsnl_id = validate(badt
     .dissoc_prsnl_id,0.0),
    reply->unit_list[u_ind].room_list[r_ind].bed_list[b_ind].upd_status_cd = validate(badt
     .upd_status_cd,0.0), reply->unit_list[u_ind].room_list[r_ind].bed_list[b_ind].hint_id = validate
    (badt.hint_id,0.0), reply->unit_list[u_ind].room_list[r_ind].bed_list[b_ind].device_ind = bmd
    .device_ind,
    reply->unit_list[u_ind].room_list[r_ind].bed_list[b_ind].name_full_formatted = spat
   WITH nocounter
  ;end select
  IF (curqual < 1)
   SET ierrcode = error(serrmsg,1)
   SET sfailed = "T"
   IF (ierrcode > 0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Data Retrieval failed!"
   ELSE
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "No data matching request"
   ENDIF
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_get_adt_by_nurseunit"
   IF (ierrcode > 0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   ENDIF
   GO TO exit_script
  ENDIF
 ELSE
  SELECT INTO "nl:"
   location_mean = uar_get_code_meaning(bmd.location_cd)
   FROM bmdi_monitored_device bmd,
    bmdi_acquired_data_track badt
   PLAN (bmd)
    JOIN (badt
    WHERE badt.location_cd=bmd.location_cd
     AND badt.dis_association_dt_tm=null)
   HEAD REPORT
    locationcount = 0
   DETAIL
    IF (location_mean="BED")
     locationcount = (locationcount+ 1)
     IF (mod(locationcount,10)=1)
      stat = alterlist(location_list->list,(locationcount+ 9))
     ENDIF
     location_list->list[locationcount].device_alias = bmd.device_alias, location_list->list[
     locationcount].device_cd = bmd.device_cd, location_list->list[locationcount].location_cd = bmd
     .location_cd,
     location_list->list[locationcount].association_id = badt.association_id, location_list->list[
     locationcount].association_dt_tm = badt.association_dt_tm, location_list->list[locationcount].
     dis_association_dt_tm = badt.dis_association_dt_tm,
     location_list->list[locationcount].person_id = badt.person_id, location_list->list[locationcount
     ].parent_entity_name = badt.parent_entity_name, location_list->list[locationcount].
     parent_entity_id = badt.parent_entity_id,
     location_list->list[locationcount].active_ind = badt.active_ind, location_list->list[
     locationcount].assoc_prsnl_id = validate(badt.assoc_prsnl_id,0.0), location_list->list[
     locationcount].dissoc_prsnl_id = validate(badt.dissoc_prsnl_id,0.0),
     location_list->list[locationcount].upd_status_cd = validate(badt.upd_status_cd,0.0),
     location_list->list[locationcount].hint_id = validate(badt.hint_id,0.0), location_list->list[
     locationcount].device_ind = bmd.device_ind
    ENDIF
   FOOT REPORT
    stat = alterlist(location_list->list,locationcount)
   WITH nocounter
  ;end select
  SET locationcount = size(location_list->list,5)
  FOR (locationindex = 1 TO locationcount)
    SET exitwhile = 0
    SET stat = alterlist(child_list->room_list,0)
    SET stat = alterlist(child_list->room_list,1)
    SET child_list->room_list[1].bed_list[1].location_cd = location_list->list[locationindex].
    location_cd
    SET locationcd = child_list->room_list[1].bed_list[1].location_cd
    WHILE (exitwhile=0)
     SELECT INTO "nl:"
      FROM location_group lg
      WHERE lg.child_loc_cd=locationcd
       AND lg.location_group_type_cd IN (facilitytypecd, buildingtypecd, unittypecd, ambulatorytypecd,
      roomtypecd)
       AND ((lg.root_loc_cd+ 0)=0.0)
       AND lg.active_ind=1
      DETAIL
       IF (uar_get_code_meaning(lg.parent_loc_cd)="ROOM")
        child_list->room_list[1].room_cd = lg.parent_loc_cd, child_list->room_list[1].bed_list[1].
        location_sequence = lg.sequence
       ELSEIF (uar_get_code_meaning(lg.parent_loc_cd)="NURSEUNIT")
        child_list->unit_cd = lg.parent_loc_cd, child_list->room_list[1].room_sequence = lg.sequence
       ELSEIF (uar_get_code_meaning(lg.parent_loc_cd)="AMBULATORY")
        child_list->unit_cd = lg.parent_loc_cd, child_list->room_list[1].room_sequence = lg.sequence
       ELSEIF (uar_get_code_meaning(lg.parent_loc_cd)="BUILDING")
        child_list->unit_sequence = lg.sequence, child_list->building_cd = lg.parent_loc_cd
       ELSEIF (uar_get_code_meaning(lg.parent_loc_cd)="FACILITY")
        child_list->facility_cd = lg.parent_loc_cd
       ENDIF
      FOOT REPORT
       locationcd = lg.parent_loc_cd
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET exitwhile = 1
     ENDIF
    ENDWHILE
    IF (exitwhile=1)
     SET ignorefromreply = 0
     IF (def_facility_cd > 0)
      IF ((def_facility_cd != child_list->facility_cd))
       SET ignorefromreply = 1
      ENDIF
     ENDIF
     IF (ignorefromreply=0)
      SET savedunitindex = 0
      SET savedroomindex = 0
      SET savedbedindex = 0
      SET unitsize = size(reply->unit_list,5)
      FOR (unitindex = 1 TO unitsize)
        IF ((reply->unit_list[unitindex].unit_cd=child_list->unit_cd))
         SET roomsize = size(reply->unit_list[unitindex].room_list,5)
         SET savedunitindex = unitindex
         FOR (roomindex = 1 TO roomsize)
           IF ((reply->unit_list[unitindex].room_list[roomindex].room_cd=child_list->room_list[1].
           room_cd))
            SET bedsize = size(reply->unit_list[unitindex].room_list[roomindex].bed_list,5)
            SET savedroomindex = roomindex
            FOR (bedindex = 1 TO bedsize)
              IF ((reply->unit_list[unitindex].room_list[roomindex].bed_list[bedindex].location_cd=
              child_list->room_list[1].bed_list[1].location_cd))
               SET savedbedindex = bedindex
               SET bedindex = bedsize
              ENDIF
            ENDFOR
            SET roomindex = roomsize
           ENDIF
         ENDFOR
         SET unitindex = unitsize
        ENDIF
      ENDFOR
      IF (savedbedindex=0)
       IF (savedroomindex > 0)
        SET bedsize = (size(reply->unit_list[savedunitindex].room_list[savedroomindex].bed_list,5)+ 1
        )
        SET stat = alterlist(reply->unit_list[savedunitindex].room_list[savedroomindex].bed_list,
         bedsize)
        SET savedbedindex = bedsize
       ELSEIF (savedunitindex > 0)
        SET roomsize = (size(reply->unit_list[savedunitindex].room_list,5)+ 1)
        SET stat = alterlist(reply->unit_list[savedunitindex].room_list,roomsize)
        SET savedroomindex = roomsize
        SET bedsize = (size(reply->unit_list[savedunitindex].room_list[savedroomindex].bed_list,5)+ 1
        )
        SET stat = alterlist(reply->unit_list[savedunitindex].room_list[savedroomindex].bed_list,
         bedsize)
        SET savedbedindex = bedsize
        SET reply->unit_list[savedunitindex].room_list[savedroomindex].room_cd = child_list->
        room_list[1].room_cd
        SET reply->unit_list[savedunitindex].room_list[savedroomindex].room_sequence = child_list->
        room_list[1].room_sequence
       ELSE
        SET unitsize = (unitsize+ 1)
        SET savedunitindex = unitsize
        SET stat = alterlist(reply->unit_list,unitsize)
        SET roomsize = (size(reply->unit_list[savedunitindex].room_list,5)+ 1)
        SET savedroomindex = roomsize
        SET stat = alterlist(reply->unit_list[savedunitindex].room_list,roomsize)
        SET bedsize = (size(reply->unit_list[savedunitindex].room_list[savedroomindex].bed_list,5)+ 1
        )
        SET stat = alterlist(reply->unit_list[savedunitindex].room_list[savedroomindex].bed_list,
         bedsize)
        SET savedbedindex = bedsize
        SET reply->unit_list[savedunitindex].unit_cd = child_list->unit_cd
        SET reply->unit_list[savedunitindex].unit_sequence = child_list->unit_sequence
        SET reply->unit_list[savedunitindex].building_cd = child_list->building_cd
        SET reply->unit_list[savedunitindex].facility_cd = child_list->facility_cd
        SET reply->unit_list[savedunitindex].room_list[savedroomindex].room_cd = child_list->
        room_list[1].room_cd
        SET reply->unit_list[savedunitindex].room_list[savedroomindex].room_sequence = child_list->
        room_list[1].room_sequence
       ENDIF
       SET reply->unit_list[savedunitindex].room_list[savedroomindex].bed_list[savedbedindex].
       device_alias = location_list->list[locationindex].device_alias
       SET reply->unit_list[savedunitindex].room_list[savedroomindex].bed_list[savedbedindex].
       device_cd = location_list->list[locationindex].device_cd
       SET reply->unit_list[savedunitindex].room_list[savedroomindex].bed_list[savedbedindex].
       location_cd = location_list->list[locationindex].location_cd
       SET reply->unit_list[savedunitindex].room_list[savedroomindex].bed_list[savedbedindex].
       location_sequence = child_list->room_list[1].bed_list[1].location_sequence
       SET reply->unit_list[savedunitindex].room_list[savedroomindex].bed_list[savedbedindex].
       association_id = location_list->list[locationindex].association_id
       SET reply->unit_list[savedunitindex].room_list[savedroomindex].bed_list[savedbedindex].
       association_dt_tm = location_list->list[locationindex].association_dt_tm
       SET reply->unit_list[savedunitindex].room_list[savedroomindex].bed_list[savedbedindex].
       dis_association_dt_tm = location_list->list[locationindex].dis_association_dt_tm
       SET reply->unit_list[savedunitindex].room_list[savedroomindex].bed_list[savedbedindex].
       person_id = location_list->list[locationindex].person_id
       SET reply->unit_list[savedunitindex].room_list[savedroomindex].bed_list[savedbedindex].
       parent_entity_name = location_list->list[locationindex].parent_entity_name
       SET reply->unit_list[savedunitindex].room_list[savedroomindex].bed_list[savedbedindex].
       parent_entity_id = location_list->list[locationindex].parent_entity_id
       SET reply->unit_list[savedunitindex].room_list[savedroomindex].bed_list[savedbedindex].
       active_ind = location_list->list[locationindex].active_ind
       SET reply->unit_list[savedunitindex].room_list[savedroomindex].bed_list[savedbedindex].
       assoc_prsnl_id = location_list->list[locationindex].assoc_prsnl_id
       SET reply->unit_list[savedunitindex].room_list[savedroomindex].bed_list[savedbedindex].
       dissoc_prsnl_id = location_list->list[locationindex].dissoc_prsnl_id
       SET reply->unit_list[savedunitindex].room_list[savedroomindex].bed_list[savedbedindex].
       upd_status_cd = location_list->list[locationindex].upd_status_cd
       SET reply->unit_list[savedunitindex].room_list[savedroomindex].bed_list[savedbedindex].hint_id
        = location_list->list[locationindex].hint_id
       SET reply->unit_list[savedunitindex].room_list[savedroomindex].bed_list[savedbedindex].
       device_ind = location_list->list[locationindex].device_ind
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
  SELECT INTO "nl:"
   unit_disp = uar_get_code_display(reply->unit_list[du.seq].unit_cd), room_disp =
   uar_get_code_display(reply->unit_list[du.seq].room_list[dr.seq].room_cd), bed_disp =
   uar_get_code_display(reply->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].location_cd),
   facility_cd = reply->unit_list[du.seq].facility_cd, building_cd = reply->unit_list[du.seq].
   building_cd, unit_seq = reply->unit_list[du.seq].unit_sequence,
   room_seq = reply->unit_list[du.seq].room_list[dr.seq].room_sequence, bed_seq = reply->unit_list[du
   .seq].room_list[dr.seq].bed_list[db.seq].location_sequence, unit_cd = reply->unit_list[du.seq].
   unit_cd,
   room_cd = reply->unit_list[du.seq].room_list[dr.seq].room_cd, device_alias = reply->unit_list[du
   .seq].room_list[dr.seq].bed_list[db.seq].device_alias, device_cd = reply->unit_list[du.seq].
   room_list[dr.seq].bed_list[db.seq].device_cd,
   location_cd = reply->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].location_cd,
   association_id = reply->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].association_id,
   association_dt_tm = reply->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].association_dt_tm,
   dis_association_dt_tm = reply->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].
   dis_association_dt_tm, person_id = reply->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].
   person_id, parent_entity_name = reply->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].
   parent_entity_name,
   parent_entity_id = reply->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].parent_entity_id,
   active_ind = reply->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].active_ind,
   assoc_prsnl_id = reply->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].assoc_prsnl_id,
   dissoc_prsnl_id = reply->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].dissoc_prsnl_id,
   upd_status_cd = reply->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].upd_status_cd, hint_id
    = reply->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].hint_id,
   device_ind = reply->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].device_ind, spat = p
   .name_full_formatted
   FROM (dummyt du  WITH seq = size(reply->unit_list,5)),
    (dummyt dr  WITH seq = 1),
    (dummyt db  WITH seq = 1),
    person p
   PLAN (du
    WHERE maxrec(dr,size(reply->unit_list[du.seq].room_list,5)))
    JOIN (dr
    WHERE maxrec(db,size(reply->unit_list[du.seq].room_list[dr.seq].bed_list,5)))
    JOIN (db)
    JOIN (p
    WHERE p.person_id=outerjoin(reply->unit_list[du.seq].room_list[dr.seq].bed_list[db.seq].person_id
     ))
   ORDER BY building_cd, unit_seq, room_seq,
    bed_seq
   HEAD REPORT
    u_ind = 0, r_ind = 0, b_ind = 0
   HEAD building_cd
    i = 0
   HEAD unit_seq
    u_ind = (u_ind+ 1), stat = alterlist(reply->unit_list,u_ind), r_ind = 0,
    b_ind = 0, reply->unit_list[u_ind].facility_cd = facility_cd, reply->unit_list[u_ind].building_cd
     = building_cd,
    reply->unit_list[u_ind].unit_cd = unit_cd, reply->unit_list[u_ind].unit_sequence = unit_seq
   HEAD room_seq
    r_ind = (r_ind+ 1), stat = alterlist(reply->unit_list[u_ind].room_list,r_ind), b_ind = 0,
    reply->unit_list[u_ind].room_list[r_ind].room_cd = room_cd, reply->unit_list[u_ind].room_list[
    r_ind].room_sequence = room_seq
   HEAD bed_seq
    b_ind = (b_ind+ 1), stat = alterlist(reply->unit_list[u_ind].room_list[r_ind].bed_list,b_ind),
    reply->unit_list[u_ind].room_list[r_ind].bed_list[b_ind].location_cd = location_cd,
    reply->unit_list[u_ind].room_list[r_ind].bed_list[b_ind].location_sequence = bed_seq, reply->
    unit_list[u_ind].room_list[r_ind].bed_list[b_ind].device_alias = device_alias, reply->unit_list[
    u_ind].room_list[r_ind].bed_list[b_ind].device_cd = device_cd,
    reply->unit_list[u_ind].room_list[r_ind].bed_list[b_ind].association_id = association_id, reply->
    unit_list[u_ind].room_list[r_ind].bed_list[b_ind].association_dt_tm = association_dt_tm, reply->
    unit_list[u_ind].room_list[r_ind].bed_list[b_ind].dis_association_dt_tm = dis_association_dt_tm,
    reply->unit_list[u_ind].room_list[r_ind].bed_list[b_ind].person_id = person_id, reply->unit_list[
    u_ind].room_list[r_ind].bed_list[b_ind].parent_entity_name = parent_entity_name, reply->
    unit_list[u_ind].room_list[r_ind].bed_list[b_ind].parent_entity_id = parent_entity_id,
    reply->unit_list[u_ind].room_list[r_ind].bed_list[b_ind].active_ind = active_ind, reply->
    unit_list[u_ind].room_list[r_ind].bed_list[b_ind].assoc_prsnl_id = assoc_prsnl_id, reply->
    unit_list[u_ind].room_list[r_ind].bed_list[b_ind].dissoc_prsnl_id = dissoc_prsnl_id,
    reply->unit_list[u_ind].room_list[r_ind].bed_list[b_ind].upd_status_cd = upd_status_cd, reply->
    unit_list[u_ind].room_list[r_ind].bed_list[b_ind].hint_id = hint_id, reply->unit_list[u_ind].
    room_list[r_ind].bed_list[b_ind].device_ind = device_ind,
    reply->unit_list[u_ind].room_list[r_ind].bed_list[b_ind].name_full_formatted = spat
   WITH nocounter
  ;end select
 ENDIF
#failure_called_script
 IF (sfailed="C")
  SET reply->status_data.subeventstatus[1].operationname = "Execute dcp_get_child_locations"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_get_adt_by_nurseunit"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failure - dcp_get_child_locations"
  GO TO exit_script
 ENDIF
#no_valid_ids
 IF (sfailed="I")
  SET reply->status_data.subeventstatus[1].operationname = "Check Request"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_get_adt_by_nurseunit"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "No valid identifier in request"
  GO TO exit_script
 ELSEIF (sfailed="N")
  SET reply->status_data.subeventstatus[1].operationname = "Check Request"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_get_adt_by_nurseunit"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unit code in request is NOT a nurseunit"
  GO TO exit_script
 ENDIF
#unsupported_option
 IF (sfailed="U")
  SET reply->status_data.subeventstatus[1].operationname = "Check Request"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_get_adt_by_nurseunit"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Combination of Request Attribute values unsupported"
  GO TO exit_script
 ENDIF
#exit_script
 IF (sfailed="T")
  IF (ierrcode > 0)
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSEIF (((sfailed="I") OR (((sfailed="U") OR (sfailed="N")) )) )
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#end_script
 CALL echorecord(reply)
END GO
