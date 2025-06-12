CREATE PROGRAM bed_ens_locations:dba
 RECORD request_cv(
   1 cd_value_list[1]
     2 action_flag = i2
     2 cdf_meaning = vc
     2 cki = vc
     2 code_set = i4
     2 code_value = f8
     2 collation_seq = i4
     2 concept_cki = vc
     2 definition = vc
     2 description = vc
     2 display = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 display_key = vc
 )
 FREE SET reply
 RECORD reply(
   1 qual[*]
     2 facility_code_value = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE br_value = vc
 DECLARE br_name = vc
 DECLARE meaning = vc
 DECLARE nvkey = vc
 DECLARE error_msg = vc
 DECLARE state_display = vc
 DECLARE county_display = vc
 DECLARE country_display = vc
 DECLARE org_id = f8 WITH protect
 SET error_flag = "N"
 SET fcnt = 0
 SET org_id = 0.0
 SET loc_facility_cd = 0.0
 SET loc_building_cd = 0.0
 SET loc_unit_cd = 0.0
 SET loc_room_cd = 0.0
 SET loc_bed_cd = 0.0
 SET building_code_value = 0.0
 SET active_cd = 0.0
 SET inactive_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=48
    AND c.cdf_meaning IN ("ACTIVE", "INACTIVE"))
  DETAIL
   IF (c.cdf_meaning="ACTIVE")
    active_cd = c.code_value
   ELSE
    inactive_cd = c.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET auth_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=8
    AND c.cdf_meaning="AUTH")
  DETAIL
   auth_cd = c.code_value
  WITH nocounter
 ;end select
 SET org_class_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=396
    AND c.cdf_meaning="ORG")
  DETAIL
   org_class_cd = c.code_value
  WITH nocounter
 ;end select
 SET facility_cd = 0.0
 SET building_cd = 0.0
 SET nurseunit_cd = 0.0
 SET ambulatory_cd = 0.0
 SET room_cd = 0.0
 SET bed_cd = 0.0
 SET waitroom_cd = 0.0
 SET checkout_cd = 0.0
 SET prearrival_cd = 0.0
 SET save_room_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=222
    AND c.cdf_meaning IN ("FACILITY", "BUILDING", "NURSEUNIT", "AMBULATORY", "ROOM",
   "BED", "WAITROOM", "CHECKOUT", "PREARRIVAL"))
  DETAIL
   IF (c.cdf_meaning="FACILITY")
    facility_cd = c.code_value
   ELSEIF (c.cdf_meaning="BUILDING")
    building_cd = c.code_value
   ELSEIF (c.cdf_meaning="NURSEUNIT")
    nurseunit_cd = c.code_value
   ELSEIF (c.cdf_meaning="AMBULATORY")
    ambulatory_cd = c.code_value
   ELSEIF (c.cdf_meaning="ROOM")
    room_cd = c.code_value, save_room_cd = c.code_value
   ELSEIF (c.cdf_meaning="BED")
    bed_cd = c.code_value
   ELSEIF (c.cdf_meaning="WAITROOM")
    waitroom_cd = c.code_value
   ELSEIF (c.cdf_meaning="CHECKOUT")
    checkout_cd = c.code_value
   ELSEIF (c.cdf_meaning="PREARRIVAL")
    prearrival_cd = c.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF (((facility_cd=0) OR (((building_cd=0) OR (((nurseunit_cd=0) OR (((ambulatory_cd=0) OR (((room_cd
 =0) OR (((bed_cd=0) OR (((waitroom_cd=0) OR (((checkout_cd=0) OR (((prearrival_cd=0) OR (((auth_cd=0
 ) OR (((org_class_cd=0) OR (active_cd=0)) )) )) )) )) )) )) )) )) )) )) )
  SET error_flag = "Y"
  SET error_msg = concat("A Cerner defined code value could not be found. ",
   "FACILITY,BUILDING,NURSEUNIT,AMBULATORY,ROOM,BED,WAITROOM,CHECKOUT,PREARRIVAL ",
   " from 222, AUTH from 8, ORG from 396 or ACTIVE from 48.")
  GO TO exit_script
 ENDIF
 SET allow_mult_phone_types = 0
 IF (validate(request->multiple_phone_type_cd_ind))
  SET allow_mult_phone_types = request->multiple_phone_type_cd_ind
 ENDIF
 SET fcnt = size(request->fac,5)
 IF (fcnt=0)
  SET error_flag = "Y"
  SET error_msg = "There were no entries in the facility list."
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->qual,fcnt)
 FOR (f = 1 TO fcnt)
   SET org_id = 0.0
   IF ((request->fac[f].location_code_value > 0))
    SELECT INTO "nl:"
     FROM location l
     PLAN (l
      WHERE (l.location_cd=request->fac[f].location_code_value))
     DETAIL
      org_id = l.organization_id
     WITH nocounter
    ;end select
    IF (org_id=0)
     SET error_flag = "Y"
     SET error_msg = concat("Organization ID not found for the location ",
      "in the request, unable to continue.")
     GO TO exit_script
    ENDIF
   ELSE
    SELECT INTO "nl:"
     FROM code_value c,
      location l
     PLAN (c
      WHERE c.code_set=220
       AND ((c.display_key=cnvtalphanum(cnvtupper(trim(request->fac[f].short_description)))) OR (c
      .description=trim(request->fac[f].full_description))) )
      JOIN (l
      WHERE l.location_cd=c.code_value
       AND l.location_type_cd=facility_cd)
     DETAIL
      org_id = l.organization_id, request->fac[f].location_code_value = c.code_value
     WITH nocounter
    ;end select
    IF (org_id=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to determine org id from ",
      "facility info in request. Unable to continue. ","Request entry: ",cnvtstring(f),
      ", short desc: ",
      trim(request->fac[f].short_description))
     GO TO exit_script
    ENDIF
   ENDIF
   SET reply->qual[f].facility_code_value = request->fac[f].location_code_value
   SET bcnt = size(request->fac[f].bld,5)
   FOR (b = 1 TO bcnt)
     IF ((request->fac[f].bld[b].action_flag=0))
      SET a = 1
     ELSEIF ((request->fac[f].bld[b].action_flag=1))
      IF ((request->fac[f].start_ind=1))
       SELECT INTO "nl:"
        FROM code_value c
        WHERE c.code_set=220
         AND c.cdf_meaning="BUILDING"
         AND ((c.display="START Bldg") OR (c.display="STANDARD Bldg"))
        DETAIL
         loc_building_cd = c.code_value
        WITH nocounter
       ;end select
       IF (curqual=0)
        SET stat = add_building(b)
       ELSEIF (curqual=1)
        SET request->fac[f].bld[b].location_code_value = loc_building_cd
        SET stat = chg_building(b)
       ELSE
        SET error_flag = "Y"
        SET error_msg = concat("Multiple code values on code set 220 ",
         "exist with a CDF_MEANING of BUILDING and DISPLAY of either ","START Bldg or STANDARD Bldg")
        GO TO exit_script
       ENDIF
      ELSE
       SET stat = add_building(b)
      ENDIF
     ELSE
      IF ((request->fac[f].bld[b].location_code_value > 0))
       IF ((request->fac[f].bld[b].action_flag=2))
        SET stat = chg_building(b)
       ELSEIF ((request->fac[f].bld[b].action_flag=3))
        SET stat = del_building(b)
       ELSE
        SET error_flag = "Y"
        SET error_msg = concat("Invalid action at the building level, must be in (0,1,2,3).",
         "No action taken on facility: ",trim(request->fac[f].short_description),", building: ",trim(
          request->fac[f].bld[b].short_description),
         ".")
        GO TO exit_script
       ENDIF
      ELSE
       SET error_flag = "Y"
       SET error_msg = concat("Actions other than ADD require a location_cd. ",
        "No building location_cd sent with facility: ",trim(request->fac[f].short_description),
        ", building: ",trim(request->fac[f].bld[b].short_description),
        ".",". This building is being skipped.")
       GO TO exit_script
      ENDIF
     ENDIF
     SET acnt = size(request->fac[f].bld[b].address,5)
     FOR (y = 1 TO acnt)
       IF ((request->fac[f].bld[b].address[y].action_flag=1))
        SET stat = add_bld_address(b,y)
       ELSEIF ((request->fac[f].bld[b].address[y].action_flag=2))
        SET stat = chg_bld_address(b,y)
       ELSEIF ((request->fac[f].bld[b].address[y].action_flag=3))
        SET stat = del_bld_address(b,y)
       ENDIF
     ENDFOR
     SET pcnt = size(request->fac[f].bld[b].phone,5)
     FOR (y = 1 TO pcnt)
       IF ((request->fac[f].bld[b].phone[y].action_flag=1))
        SET stat = add_bld_phone(b,y)
       ELSEIF ((request->fac[f].bld[b].phone[y].action_flag=2))
        SET stat = chg_bld_phone(b,y)
       ELSEIF ((request->fac[f].bld[b].phone[y].action_flag=3))
        SET stat = del_bld_phone(b,y)
       ENDIF
     ENDFOR
     SET ucnt = size(request->fac[f].bld[b].unit,5)
     FOR (u = 1 TO ucnt)
       IF ((request->fac[f].bld[b].unit[u].location_type_code_value != ambulatory_cd)
        AND (request->fac[f].bld[b].unit[u].location_type_code_value != nurseunit_cd))
        SET request->fac[f].bld[b].unit[u].location_type_code_value = nurseunit_cd
       ENDIF
       IF ((request->fac[f].bld[b].unit[u].action_flag=0))
        SET a = 1
       ELSEIF ((request->fac[f].bld[b].unit[u].action_flag=1))
        SET stat = add_unit(b,u)
       ELSE
        IF ((request->fac[f].bld[b].unit[u].location_code_value > 0))
         IF ((request->fac[f].bld[b].unit[u].action_flag=2))
          SET stat = chg_unit(b,u)
         ELSEIF ((request->fac[f].bld[b].unit[u].action_flag=3))
          SET stat = del_unit(b,u)
         ELSE
          SET error_flag = "Y"
          SET error_msg = concat("Invalid action at the unit level, must be in (0,1,2,3).",
           "No action taken on facility: ",trim(request->fac[f].short_description),", building: ",
           trim(request->fac[f].bld[b].short_description),
           ", unit: ",trim(request->fac[f].bld[b].unit[u].short_description),".")
          GO TO exit_script
         ENDIF
        ELSE
         SET error_flag = "Y"
         SET error_msg = concat("Actions other than ADD require a location_cd. ",
          "No unit location_cd sent with facility: ",trim(request->fac[f].short_description),
          ", building: ",trim(request->fac[f].bld[b].short_description),
          ", unit: ",trim(request->fac[f].bld[b].unit[u].short_description),
          ". This unit is being skipped.")
         GO TO exit_script
        ENDIF
       ENDIF
       SET acnt = size(request->fac[f].bld[b].unit[u].address,5)
       FOR (y = 1 TO acnt)
         IF ((request->fac[f].bld[b].unit[u].address[y].action_flag=1))
          SET stat = add_unit_address(b,u,y)
         ELSEIF ((request->fac[f].bld[b].unit[u].address[y].action_flag=2))
          SET stat = chg_unit_address(b,u,y)
         ELSEIF ((request->fac[f].bld[b].unit[u].address[y].action_flag=3))
          SET stat = del_unit_address(b,u,y)
         ENDIF
       ENDFOR
       SET pcnt = size(request->fac[f].bld[b].unit[u].phone,5)
       FOR (y = 1 TO pcnt)
         IF ((request->fac[f].bld[b].unit[u].phone[y].action_flag=1))
          SET stat = add_unit_phone(b,u,y)
         ELSEIF ((request->fac[f].bld[b].unit[u].phone[y].action_flag=2))
          SET stat = chg_unit_phone(b,u,y)
         ELSEIF ((request->fac[f].bld[b].unit[u].phone[y].action_flag=3))
          SET stat = del_unit_phone(b,u,y)
         ENDIF
       ENDFOR
       SET rcnt = size(request->fac[f].bld[b].unit[u].room,5)
       FOR (r = 1 TO rcnt)
         IF ((request->fac[f].bld[b].unit[u].room[r].action_flag=0))
          SET a = 1
         ELSEIF ((request->fac[f].bld[b].unit[u].room[r].action_flag=1))
          SET stat = add_room(b,u,r)
         ELSE
          IF ((request->fac[f].bld[b].unit[u].room[r].location_code_value > 0))
           IF ((request->fac[f].bld[b].unit[u].room[r].action_flag=2))
            SET stat = chg_room(b,u,r)
           ELSEIF ((request->fac[f].bld[b].unit[u].room[r].action_flag=3))
            SET stat = del_room(b,u,r)
           ELSE
            SET error_flag = "Y"
            SET error_msg = concat("Invalid action at the room level, must be in (0,1,2,3).",
             "No action taken on facility: ",trim(request->fac[f].short_description),", building: ",
             trim(request->fac[f].bld[b].short_description),
             ", unit: ",trim(request->fac[f].bld[b].unit[u].short_description),", room: ",trim(
              request->fac[f].bld[b].unit[u].room[r].short_description),".")
            GO TO exit_script
           ENDIF
          ELSE
           SET error_flag = "Y"
           SET error_msg = concat("Actions other than ADD require a location_cd. ",
            "No room location_cd sent with facility: ",trim(request->fac[f].short_description),
            ", building: ",trim(request->fac[f].bld[b].short_description),
            ", unit: ",trim(request->fac[f].bld[b].unit[u].short_description),", room: ",trim(request
             ->fac[f].bld[b].unit[u].room[r].short_description),". This room is being skipped.")
           GO TO exit_script
          ENDIF
         ENDIF
         SET bedcnt = size(request->fac[f].bld[b].unit[u].room[r].bed,5)
         FOR (d = 1 TO bedcnt)
           IF ((request->fac[f].bld[b].unit[u].room[r].bed[d].action_flag=0))
            SET a = 1
           ELSEIF ((request->fac[f].bld[b].unit[u].room[r].bed[d].action_flag=1))
            SET stat = add_bed(b,u,r,d)
           ELSE
            IF ((request->fac[f].bld[b].unit[u].room[r].bed[d].location_code_value > 0))
             IF ((request->fac[f].bld[b].unit[u].room[r].bed[d].action_flag=2))
              SET stat = chg_bed(b,u,r,d)
             ELSEIF ((request->fac[f].bld[b].unit[u].room[r].bed[d].action_flag=3))
              SET stat = del_bed(b,u,r,d)
             ELSE
              SET error_flag = "Y"
              SET error_msg = concat("Invalid action at the bed level, must be in (0,1,2). ",
               "No action taken on facility: ",trim(request->fac[f].short_description),", building:",
               trim(request->fac[f].bld[b].short_description),
               ", unit: ",trim(request->fac[f].bld[b].unit[u].short_description),", room: ",trim(
                request->fac[f].bld[b].unit[u].room[r].short_description),", bed: ",
               trim(request->fac[f].bld[b].unit[u].room[r].bed[d].short_description),".")
              GO TO exit_script
             ENDIF
            ELSE
             SET error_flag = "Y"
             SET error_msg = concat("Actions other than ADD require a location_cd. ",
              "No bed location_cd sent with facility: ",trim(request->fac[f].short_description),
              ", building: ",trim(request->fac[f].bld[b].short_description),
              ", unit: ",trim(request->fac[f].bld[b].unit[u].short_description),", room: ",trim(
               request->fac[f].bld[b].unit[u].room[r].short_description),", bed: ",
              trim(request->fac[f].bld[b].unit[u].room[r].bed[d].short_description),
              ". This bed is being skipped.")
             GO TO exit_script
            ENDIF
           ENDIF
         ENDFOR
       ENDFOR
     ENDFOR
   ENDFOR
 ENDFOR
 GO TO exit_script
 SUBROUTINE add_building(b)
   SET colseq = 0
   SELECT INTO "nl:"
    csq = max(c.collation_seq)
    FROM code_value c
    PLAN (c
     WHERE c.code_set=220
      AND c.cdf_meaning="BUILDING")
    DETAIL
     colseq = csq
    WITH nocounter
   ;end select
   SET request_cv->cd_value_list[1].action_flag = 1
   SET request_cv->cd_value_list[1].code_set = 220
   SET request_cv->cd_value_list[1].display = substring(1,40,request->fac[f].bld[b].short_description
    )
   SET request_cv->cd_value_list[1].description = substring(1,60,request->fac[f].bld[b].
    full_description)
   SET request_cv->cd_value_list[1].definition = " "
   SET request_cv->cd_value_list[1].cdf_meaning = "BUILDING"
   SET request_cv->cd_value_list[1].concept_cki = " "
   SET request_cv->cd_value_list[1].collation_seq = (colseq+ 1)
   SET request_cv->cd_value_list[1].active_ind = 1
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   SET next_code = 0.0
   IF ((reply_cv->status_data.status="S")
    AND (reply_cv->qual[1].code_value > 0))
    SET next_code = reply_cv->qual[1].code_value
    SET request->fac[f].bld[b].location_code_value = next_code
    INSERT  FROM location l
     SET l.location_cd = next_code, l.location_type_cd = building_cd, l.organization_id = org_id,
      l.resource_ind = 0, l.transmit_outbound_order_ind = 0, l.census_ind = 0,
      l.patcare_node_ind = 0, l.ref_lab_acct_nbr = " ", l.active_ind = 1,
      l.active_status_cd = active_cd, l.active_status_dt_tm = cnvtdatetime(curdate,curtime3), l
      .active_status_prsnl_id = 0,
      l.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), l.end_effective_dt_tm = cnvtdatetime(
       "31-dec-2100 00:00:00.00"), l.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      l.updt_id = reqinfo->updt_id, l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->
      updt_applctx,
      l.updt_cnt = 0, l.data_status_cd = auth_cd, l.data_status_prsnl_id = 0,
      l.data_status_dt_tm = cnvtdatetime(curdate,curtime3), l.contributor_system_cd = 0, l
      .contributor_source_cd = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error writing BUILDING location for facility: ",request->fac[f].
      full_description,", building: ",request->fac[f].bld[b].full_description,".")
     GO TO exit_script
    ELSE
     INSERT  FROM location_group l
      SET l.parent_loc_cd = request->fac[f].location_code_value, l.child_loc_cd = next_code, l
       .location_group_type_cd = facility_cd,
       l.sequence =
       IF ((request->fac[f].bld[b].sequence > 0)) request->fac[f].bld[b].sequence
       ELSE b
       ENDIF
       , l.root_loc_cd = 0, l.active_ind = 1,
       l.active_status_cd = active_cd, l.active_status_dt_tm = cnvtdatetime(curdate,curtime3), l
       .active_status_prsnl_id = 0,
       l.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), l.end_effective_dt_tm = cnvtdatetime(
        "31-dec-2100 00:00:00.00"), l.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       l.updt_id = reqinfo->updt_id, l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->
       updt_applctx,
       l.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Error writing location group for facility: ",request->fac[f].
       full_description,", building: ",request->fac[f].bld[b].full_description,".")
      GO TO exit_script
     ENDIF
    ENDIF
   ELSE
    SET error_flag = "Y"
    SET error_msg = concat("Error writing BUILDING code value for facility: ",request->fac[f].
     full_description,", building: ",request->fac[f].bld[b].full_description,".")
    GO TO exit_script
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE chg_building(b)
   SET request_cv->cd_value_list[1].action_flag = 2
   SET request_cv->cd_value_list[1].code_set = 220
   SET request_cv->cd_value_list[1].code_value = request->fac[f].bld[b].location_code_value
   SET request_cv->cd_value_list[1].display = substring(1,40,request->fac[f].bld[b].short_description
    )
   SET request_cv->cd_value_list[1].description = substring(1,60,request->fac[f].bld[b].
    full_description)
   SET request_cv->cd_value_list[1].cdf_meaning = " "
   SET request_cv->cd_value_list[1].active_ind = 1
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   IF ((reply_cv->status_data.status != "S"))
    SET error_flag = "Y"
    SET error_msg = concat("Error updating building code value for facility: ",request->fac[f].
     full_description,", building: ",request->fac[f].bld[b].full_description,".")
    GO TO exit_script
   ENDIF
   UPDATE  FROM location l
    SET l.updt_dt_tm = cnvtdatetime(curdate,curtime), l.updt_cnt = (l.updt_cnt+ 1), l.updt_id =
     reqinfo->updt_id,
     l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx
    WHERE (l.location_cd=request->fac[f].bld[b].location_code_value)
    WITH nocounter
   ;end update
   IF ((request->fac[f].start_ind=0))
    IF ((request->fac[f].bld[b].sequence > 0))
     UPDATE  FROM location_group l
      SET l.sequence = request->fac[f].bld[b].sequence, l.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       l.updt_id = reqinfo->updt_id,
       l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = (l
       .updt_cnt+ 1)
      WHERE (l.parent_loc_cd=request->fac[f].location_code_value)
       AND (l.child_loc_cd=request->fac[f].bld[b].location_code_value)
       AND l.location_group_type_cd=facility_cd
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Error updating location group (sequence) for facility: ",request->fac[f
       ].full_description,", building: ",request->fac[f].bld[b].full_description,".")
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE del_building(b)
   SET request_cv->cd_value_list[1].action_flag = 3
   SET request_cv->cd_value_list[1].code_set = 220
   SET request_cv->cd_value_list[1].code_value = request->fac[f].bld[b].location_code_value
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   UPDATE  FROM location l
    SET l.active_ind = 0, l.active_status_cd = inactive_cd, l.end_effective_dt_tm = cnvtdatetime(
      curdate,curtime),
     l.updt_dt_tm = cnvtdatetime(curdate,curtime), l.updt_id = reqinfo->updt_id, l.updt_task =
     reqinfo->updt_task,
     l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = (l.updt_cnt+ 1)
    WHERE (l.location_cd=request->fac[f].bld[b].location_code_value)
    WITH nocounter
   ;end update
   UPDATE  FROM location_group lg
    SET lg.active_ind = 0, lg.active_status_cd = inactive_cd, lg.end_effective_dt_tm = cnvtdatetime(
      curdate,curtime),
     lg.updt_dt_tm = cnvtdatetime(curdate,curtime), lg.updt_id = reqinfo->updt_id, lg.updt_task =
     reqinfo->updt_task,
     lg.updt_applctx = reqinfo->updt_applctx, lg.updt_cnt = (lg.updt_cnt+ 1)
    WHERE (lg.parent_loc_cd=request->fac[f].bld[b].location_code_value)
    WITH nocounter
   ;end update
   UPDATE  FROM location_group lg
    SET lg.active_ind = 0, lg.active_status_cd = inactive_cd, lg.end_effective_dt_tm = cnvtdatetime(
      curdate,curtime),
     lg.updt_dt_tm = cnvtdatetime(curdate,curtime), lg.updt_id = reqinfo->updt_id, lg.updt_task =
     reqinfo->updt_task,
     lg.updt_applctx = reqinfo->updt_applctx, lg.updt_cnt = (lg.updt_cnt+ 1)
    WHERE (lg.child_loc_cd=request->fac[f].bld[b].location_code_value)
    WITH nocounter
   ;end update
   IF ((request->fac[f].bld[b].delete_bld_alias_ind=1))
    DELETE  FROM code_value_alias cva
     WHERE (cva.code_value=request->fac[f].bld[b].location_code_value)
     WITH nocounter
    ;end delete
    DELETE  FROM code_value_outbound cvo
     WHERE (cvo.code_value=request->fac[f].bld[b].location_code_value)
     WITH nocounter
    ;end delete
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE add_unit(b,u)
   SET colseq = 0
   IF ((request->fac[f].bld[b].unit[u].location_type_code_value=nurseunit_cd))
    SELECT INTO "nl:"
     csq = max(c.collation_seq)
     FROM code_value c
     PLAN (c
      WHERE c.code_set=220
       AND c.cdf_meaning="NURSEUNIT")
     DETAIL
      colseq = csq
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     csq = max(c.collation_seq)
     FROM code_value c
     PLAN (c
      WHERE c.code_set=220
       AND c.cdf_meaning="AMBULATORY")
     DETAIL
      colseq = csq
     WITH nocounter
    ;end select
   ENDIF
   SET request_cv->cd_value_list[1].action_flag = 1
   SET request_cv->cd_value_list[1].code_set = 220
   SET request_cv->cd_value_list[1].display = substring(1,40,request->fac[f].bld[b].unit[u].
    short_description)
   SET request_cv->cd_value_list[1].description = substring(1,60,request->fac[f].bld[b].unit[u].
    full_description)
   SET request_cv->cd_value_list[1].definition = " "
   SET request_cv->cd_value_list[1].concept_cki = " "
   SET request_cv->cd_value_list[1].collation_seq = (colseq+ 1)
   IF ((request->fac[f].bld[b].unit[u].location_type_code_value=nurseunit_cd))
    SET request_cv->cd_value_list[1].cdf_meaning = "NURSEUNIT"
   ELSE
    SET request_cv->cd_value_list[1].cdf_meaning = "AMBULATORY"
   ENDIF
   SET request_cv->cd_value_list[1].active_ind = 1
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   SET next_code = 0.0
   IF ((reply_cv->status_data.status="S")
    AND (reply_cv->qual[1].code_value > 0))
    SET next_code = reply_cv->qual[1].code_value
    SET request->fac[f].bld[b].unit[u].location_code_value = next_code
    INSERT  FROM location l
     SET l.location_cd = next_code, l.location_type_cd = request->fac[f].bld[b].unit[u].
      location_type_code_value, l.icu_ind = request->fac[f].bld[b].unit[u].icu_ind,
      l.organization_id = org_id, l.resource_ind = 0, l.transmit_outbound_order_ind = 0,
      l.census_ind = 1, l.patcare_node_ind = 0, l.ref_lab_acct_nbr = " ",
      l.active_ind = 1, l.active_status_cd = active_cd, l.active_status_dt_tm = cnvtdatetime(curdate,
       curtime3),
      l.active_status_prsnl_id = 0, l.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), l
      .end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"),
      l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_id = reqinfo->updt_id, l.updt_task =
      reqinfo->updt_task,
      l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = 0, l.data_status_cd = auth_cd,
      l.data_status_prsnl_id = 0, l.data_status_dt_tm = cnvtdatetime(curdate,curtime3), l
      .contributor_system_cd = 0,
      l.contributor_source_cd = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error writing UNIT location for facility: ",request->fac[f].
      full_description,", building: ",request->fac[f].bld[b].full_description,", unit: ",
      request->fac[f].bld[b].unit[u].full_description,".")
     GO TO exit_script
    ELSE
     INSERT  FROM location_group l
      SET l.parent_loc_cd = request->fac[f].bld[b].location_code_value, l.child_loc_cd = next_code, l
       .location_group_type_cd = building_cd,
       l.sequence =
       IF ((request->fac[f].bld[b].unit[u].sequence > 0)) request->fac[f].bld[b].unit[u].sequence
       ELSE u
       ENDIF
       , l.root_loc_cd = 0, l.active_ind = 1,
       l.active_status_cd = active_cd, l.active_status_dt_tm = cnvtdatetime(curdate,curtime3), l
       .active_status_prsnl_id = 0,
       l.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), l.end_effective_dt_tm = cnvtdatetime(
        "31-dec-2100 00:00:00.00"), l.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       l.updt_id = reqinfo->updt_id, l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->
       updt_applctx,
       l.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Error writing location group for building: ",request->fac[f].bld[b].
       full_description,", unit: ",request->fac[f].bld[b].unit[u].full_description,".")
      GO TO exit_script
     ELSE
      INSERT  FROM nurse_unit n
       SET n.location_cd = next_code, n.loc_facility_cd = request->fac[f].location_code_value, n
        .loc_building_cd = request->fac[f].bld[b].location_code_value,
        n.atd_req_loc = 0, n.cart_qty_ind = 0, n.dispense_window = 0,
        n.active_ind = 1, n.active_status_cd = active_cd, n.active_status_dt_tm = cnvtdatetime(
         curdate,curtime3),
        n.active_status_prsnl_id = 0, n.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), n
        .end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"),
        n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_id = reqinfo->updt_id, n.updt_task =
        reqinfo->updt_task,
        n.updt_applctx = reqinfo->updt_applctx, n.updt_cnt = 0
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Error writing NURSE_UNIT row for building: ",request->fac[f].bld[b].
        full_description,", unit: ",request->fac[f].bld[b].unit[u].full_description,".")
       GO TO exit_script
      ENDIF
      IF ((request->fac[f].bld[b].unit[u].ed_ind=1))
       SET name_value_id = 0.0
       SELECT INTO "nl:"
        br_val = seq(bedrock_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         name_value_id = cnvtreal(br_val)
        WITH format, counter
       ;end select
       IF (curqual=0)
        SET error_flag = "Y"
        SET error_msg = concat("Error getting br_name_value_id for building: ",request->fac[f].bld[b]
         .full_description,", unit: ",request->fac[f].bld[b].unit[u].full_description,".")
        GO TO exit_script
       ENDIF
       SET br_value = cnvtstring(request->fac[f].bld[b].unit[u].location_code_value)
       INSERT  FROM br_name_value br
        SET br.br_name_value_id = name_value_id, br.br_nv_key1 = "EDUNIT", br.br_name = "CVFROMCS220",
         br.br_value = br_value, br.updt_cnt = 0, br.updt_dt_tm = cnvtdatetime(curdate,curtime),
         br.updt_id = reqinfo->updt_id, br.updt_task = reqinfo->updt_task, br.updt_applctx = reqinfo
         ->updt_applctx
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET error_flag = "Y"
        SET error_msg = concat("Error writing BR_NAME_VALUE row for building: ",request->fac[f].bld[b
         ].full_description,", unit: ",request->fac[f].bld[b].unit[u].full_description,".")
        GO TO exit_script
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET error_flag = "Y"
    SET error_msg = concat("Error writing UNIT code value for facility: ",request->fac[f].
     full_description,", building: ",request->fac[f].bld[b].full_description,", unit: ",
     request->fac[f].bld[b].unit[u].full_description,".")
    GO TO exit_script
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE chg_unit(b,u)
   SET request_cv->cd_value_list[1].action_flag = 2
   SET request_cv->cd_value_list[1].code_set = 220
   SET request_cv->cd_value_list[1].code_value = request->fac[f].bld[b].unit[u].location_code_value
   SET request_cv->cd_value_list[1].display = substring(1,40,request->fac[f].bld[b].unit[u].
    short_description)
   SET request_cv->cd_value_list[1].description = substring(1,60,request->fac[f].bld[b].unit[u].
    full_description)
   SET request_cv->cd_value_list[1].cdf_meaning = " "
   SET request_cv->cd_value_list[1].active_ind = 1
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   IF ((reply_cv->status_data.status != "S"))
    SET error_flag = "Y"
    SET error_msg = concat("Error updating unit code value for facility: ",request->fac[f].
     full_description,", building: ",request->fac[f].bld[b].full_description,", unit: ",
     request->fac[f].bld[b].unit[u].full_description,".")
    GO TO exit_script
   ENDIF
   UPDATE  FROM location l
    SET l.icu_ind = request->fac[f].bld[b].unit[u].icu_ind, l.updt_dt_tm = cnvtdatetime(curdate,
      curtime), l.updt_cnt = (l.updt_cnt+ 1),
     l.updt_id = reqinfo->updt_id, l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->
     updt_applctx
    WHERE (l.location_cd=request->fac[f].bld[b].unit[u].location_code_value)
    WITH nocounter
   ;end update
   UPDATE  FROM nurse_unit n
    SET n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_id = reqinfo->updt_id, n.updt_task =
     reqinfo->updt_task,
     n.updt_applctx = reqinfo->updt_applctx, n.updt_cnt = (n.updt_cnt+ 1)
    WHERE (n.location_cd=request->fac[f].bld[b].unit[u].location_code_value)
    WITH nocounter
   ;end update
   IF ((request->fac[f].bld[b].unit[u].sequence > 0))
    UPDATE  FROM location_group l
     SET l.sequence = request->fac[f].bld[b].unit[u].sequence, l.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), l.updt_id = reqinfo->updt_id,
      l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = (l
      .updt_cnt+ 1)
     WHERE (l.parent_loc_cd=request->fac[f].bld[b].location_code_value)
      AND (l.child_loc_cd=request->fac[f].bld[b].unit[u].location_code_value)
      AND l.location_group_type_cd=building_cd
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error updating locaction group (sequence) for building: ",request->fac[f
      ].bld[b].full_description," unit: ",request->fac[f].bld[b].unit[u].full_description,".")
     GO TO exit_script
    ENDIF
   ENDIF
   IF ((request->fac[f].bld[b].unit[u].ed_ind=1))
    SET found_ind = 0
    SELECT INTO "NL:"
     FROM br_name_value br
     WHERE br.br_nv_key1="EDUNIT"
      AND br.br_name="CVFROMCS220"
      AND br.br_value=cnvtstring(request->fac[f].bld[b].unit[u].location_code_value)
     DETAIL
      found_ind = 1
     WITH nocounter
    ;end select
    IF (found_ind=0)
     SET name_value_id = 0.0
     SELECT INTO "nl:"
      br_val = seq(bedrock_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       name_value_id = cnvtreal(br_val)
      WITH format, counter
     ;end select
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Error getting br_name_value_id for building: ",request->fac[f].bld[b].
       full_description,", unit: ",request->fac[f].bld[b].unit[u].full_description,".")
      GO TO exit_script
     ENDIF
     SET br_value = cnvtstring(request->fac[f].bld[b].unit[u].location_code_value)
     INSERT  FROM br_name_value br
      SET br.br_name_value_id = name_value_id, br.br_nv_key1 = "EDUNIT", br.br_name = "CVFROMCS220",
       br.br_value = br_value, br.updt_cnt = 0, br.updt_dt_tm = cnvtdatetime(curdate,curtime),
       br.updt_id = reqinfo->updt_id, br.updt_task = reqinfo->updt_task, br.updt_applctx = reqinfo->
       updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Error writing BR_NAME_VALUE row for building: ",request->fac[f].bld[b].
       full_description,", unit: ",request->fac[f].bld[b].unit[u].full_description,".")
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE del_unit(b,u)
   SET request_cv->cd_value_list[1].action_flag = 3
   SET request_cv->cd_value_list[1].code_set = 220
   SET request_cv->cd_value_list[1].code_value = request->fac[f].bld[b].unit[u].location_code_value
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   UPDATE  FROM location l
    SET l.active_ind = 0, l.active_status_cd = inactive_cd, l.end_effective_dt_tm = cnvtdatetime(
      curdate,curtime),
     l.updt_dt_tm = cnvtdatetime(curdate,curtime), l.updt_id = reqinfo->updt_id, l.updt_task =
     reqinfo->updt_task,
     l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = (l.updt_cnt+ 1)
    WHERE (l.location_cd=request->fac[f].bld[b].unit[u].location_code_value)
    WITH nocounter
   ;end update
   UPDATE  FROM location_group lg
    SET lg.active_ind = 0, lg.active_status_cd = inactive_cd, lg.end_effective_dt_tm = cnvtdatetime(
      curdate,curtime),
     lg.updt_dt_tm = cnvtdatetime(curdate,curtime), lg.updt_id = reqinfo->updt_id, lg.updt_task =
     reqinfo->updt_task,
     lg.updt_applctx = reqinfo->updt_applctx, lg.updt_cnt = (lg.updt_cnt+ 1)
    WHERE (lg.parent_loc_cd=request->fac[f].bld[b].unit[u].location_code_value)
    WITH nocounter
   ;end update
   UPDATE  FROM location_group lg
    SET lg.active_ind = 0, lg.active_status_cd = inactive_cd, lg.end_effective_dt_tm = cnvtdatetime(
      curdate,curtime),
     lg.updt_dt_tm = cnvtdatetime(curdate,curtime), lg.updt_id = reqinfo->updt_id, lg.updt_task =
     reqinfo->updt_task,
     lg.updt_applctx = reqinfo->updt_applctx, lg.updt_cnt = (lg.updt_cnt+ 1)
    WHERE (lg.child_loc_cd=request->fac[f].bld[b].unit[u].location_code_value)
    WITH nocounter
   ;end update
   IF ((request->fac[f].bld[b].unit[u].location_type_code_value IN (nurseunit_cd, ambulatory_cd)))
    UPDATE  FROM nurse_unit nu
     SET nu.active_ind = 0, nu.active_status_cd = inactive_cd, nu.end_effective_dt_tm = cnvtdatetime(
       curdate,curtime),
      nu.updt_dt_tm = cnvtdatetime(curdate,curtime), nu.updt_id = reqinfo->updt_id, nu.updt_task =
      reqinfo->updt_task,
      nu.updt_applctx = reqinfo->updt_applctx, nu.updt_cnt = (nu.updt_cnt+ 1)
     WHERE (nu.location_cd=request->fac[f].bld[b].unit[u].location_code_value)
     WITH nocounter
    ;end update
   ENDIF
   IF ((request->fac[f].bld[b].unit[u].delete_unit_alias_ind=1))
    DELETE  FROM code_value_alias cva
     WHERE (cva.code_value=request->fac[f].bld[b].unit[u].location_code_value)
     WITH nocounter
    ;end delete
    DELETE  FROM code_value_outbound cvo
     WHERE (cvo.code_value=request->fac[f].bld[b].unit[u].location_code_value)
     WITH nocounter
    ;end delete
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE add_room(b,u,r)
   SET next_code = 0.0
   IF ((request->fac[f].bld[b].unit[u].room[r].full_description > " "))
    SET next_code = 0.0
   ELSE
    SET request->fac[f].bld[b].unit[u].room[r].full_description = request->fac[f].bld[b].unit[u].
    room[r].short_description
   ENDIF
   SET area_id = 0.0
   IF ((request->fac[f].bld[b].unit[u].room[r].area_id > " "))
    SET area_id = cnvtreal(request->fac[f].bld[b].unit[u].room[r].area_id)
    SELECT INTO "nl:"
     FROM br_name_value br
     PLAN (br
      WHERE br.br_name_value_id=area_id)
     DETAIL
      nvkey = br.br_nv_key1
     WITH nocounter
    ;end select
    IF (curqual=1)
     IF (nvkey="EDWAITAREA")
      SET meaning = "WAITROOM"
      SET room_cd = waitroom_cd
     ELSEIF (nvkey="EDCOAREA")
      SET meaning = "CHECKOUT"
      SET room_cd = checkout_cd
     ELSEIF (nvkey="EDPAAREA")
      SET meaning = "PREARRIVAL"
      SET room_cd = prearrival_cd
     ELSE
      SET meaning = "ROOM"
     ENDIF
    ELSE
     SET meaning = "ROOM"
    ENDIF
   ELSE
    SET meaning = "ROOM"
   ENDIF
   SET request_cv->cd_value_list[1].action_flag = 1
   SET request_cv->cd_value_list[1].code_set = 220
   SET request_cv->cd_value_list[1].display = substring(1,40,request->fac[f].bld[b].unit[u].room[r].
    short_description)
   SET request_cv->cd_value_list[1].description = substring(1,60,request->fac[f].bld[b].unit[u].room[
    r].full_description)
   SET request_cv->cd_value_list[1].definition = " "
   SET request_cv->cd_value_list[1].cdf_meaning = meaning
   SET request_cv->cd_value_list[1].concept_cki = " "
   SET request_cv->cd_value_list[1].active_ind = 1
   SET request_cv->cd_value_list[1].collation_seq = 0
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   SET next_code = 0.0
   IF ((reply_cv->status_data.status="S")
    AND (reply_cv->qual[1].code_value > 0))
    SET next_code = reply_cv->qual[1].code_value
    SET request->fac[f].bld[b].unit[u].room[r].location_code_value = next_code
    INSERT  FROM location l
     SET l.location_cd = next_code, l.location_type_cd = room_cd, l.organization_id = org_id,
      l.census_ind = 1, l.active_ind = 1, l.active_status_cd = active_cd,
      l.active_status_dt_tm = cnvtdatetime(curdate,curtime3), l.active_status_prsnl_id = 0, l
      .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      l.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"), l.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), l.updt_id = reqinfo->updt_id,
      l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = 0,
      l.data_status_cd = auth_cd, l.data_status_prsnl_id = 0, l.data_status_dt_tm = cnvtdatetime(
       curdate,curtime3),
      l.contributor_system_cd = 0, l.contributor_source_cd = 0
     WITH nocounter
    ;end insert
    SET room_cd = save_room_cd
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error writing ROOM location for facility: ",request->fac[f].
      full_description,", building: ",request->fac[f].bld[b].full_description,", unit: ",
      request->fac[f].bld[b].unit[u].full_description,", room: ",request->fac[f].bld[b].unit[u].room[
      r].full_description,".")
     GO TO exit_script
    ELSE
     INSERT  FROM location_group l
      SET l.parent_loc_cd = request->fac[f].bld[b].unit[u].location_code_value, l.child_loc_cd =
       next_code, l.location_group_type_cd = request->fac[f].bld[b].unit[u].location_type_code_value,
       l.sequence =
       IF ((request->fac[f].bld[b].unit[u].room[r].sequence > 0)) request->fac[f].bld[b].unit[u].
        room[r].sequence
       ELSE r
       ENDIF
       , l.root_loc_cd = 0, l.active_ind = 1,
       l.active_status_cd = active_cd, l.active_status_dt_tm = cnvtdatetime(curdate,curtime3), l
       .active_status_prsnl_id = 0,
       l.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), l.end_effective_dt_tm = cnvtdatetime(
        "31-dec-2100 00:00:00.00"), l.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       l.updt_id = reqinfo->updt_id, l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->
       updt_applctx,
       l.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Error writing location group for building: ",request->fac[f].bld[b].
       full_description,", unit: ",request->fac[f].bld[b].unit[u].full_description,", room: ",
       request->fac[f].bld[b].unit[u].room[r].full_description,".")
      GO TO exit_script
     ELSE
      INSERT  FROM room r
       SET r.location_cd = next_code, r.loc_nurse_unit_cd = request->fac[f].bld[b].unit[u].
        location_code_value, r.fixed_bed_ind = 0,
        r.active_ind = 1, r.active_status_cd = active_cd, r.active_status_dt_tm = cnvtdatetime(
         curdate,curtime3),
        r.active_status_prsnl_id = 0, r.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), r
        .end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"),
        r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_id = reqinfo->updt_id, r.updt_task =
        reqinfo->updt_task,
        r.updt_applctx = reqinfo->updt_applctx, r.updt_cnt = 0
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Error writing ROOM row for building: ",request->fac[f].bld[b].
        full_description,", unit: ",request->fac[f].bld[b].unit[u].full_description,", room: ",
        request->fac[f].bld[b].unit[u].room[r].full_description,".")
       GO TO exit_script
      ENDIF
      IF ((request->fac[f].bld[b].unit[u].room[r].area_id > " "))
       SET name_value_id = 0.0
       SELECT INTO "nl:"
        bed_val = seq(bedrock_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         name_value_id = cnvtreal(bed_val)
        WITH format, counter
       ;end select
       IF (curqual=0)
        SET error_flag = "Y"
        SET error_msg = concat("Error getting br_name_value_id for building: ",request->fac[f].bld[b]
         .full_description,", unit: ",request->fac[f].bld[b].unit[u].full_description,", room: ",
         request->fac[f].bld[b].unit[u].room[r].full_description,".")
        GO TO exit_script
       ENDIF
       SET br_value = cnvtstring(request->fac[f].bld[b].unit[u].room[r].location_code_value)
       SET br_name = request->fac[f].bld[b].unit[u].room[r].area_id
       INSERT  FROM br_name_value br
        SET br.br_name_value_id = name_value_id, br.br_nv_key1 = "EDAREAROOMRELTN", br.br_name =
         br_name,
         br.br_value = br_value, br.updt_cnt = 0, br.updt_dt_tm = cnvtdatetime(curdate,curtime),
         br.updt_id = reqinfo->updt_id, br.updt_task = reqinfo->updt_task, br.updt_applctx = reqinfo
         ->updt_applctx
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET error_flag = "Y"
        SET error_msg = concat("Error writing BR_NAME_VALUE row for building: ",request->fac[f].bld[b
         ].full_description,", unit: ",request->fac[f].bld[b].unit[u].full_description,", room: ",
         request->fac[f].bld[b].unit[u].room[r].full_description,".")
        GO TO exit_script
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET error_flag = "Y"
    SET error_msg = concat("Error writing ROOM code value for facility: ",request->fac[f].
     full_description,", building: ",request->fac[f].bld[b].full_description,", unit: ",
     request->fac[f].bld[b].unit[u].full_description,", room: ",request->fac[f].bld[b].unit[u].room[r
     ].full_description,".")
    GO TO exit_script
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE chg_room(b,u,r)
   IF ((request->fac[f].bld[b].unit[u].room[r].full_description > " "))
    SET error_flag = error_flag
   ELSE
    SET request->fac[f].bld[b].unit[u].room[r].full_description = request->fac[f].bld[b].unit[u].
    room[r].short_description
   ENDIF
   SET request_cv->cd_value_list[1].action_flag = 2
   SET request_cv->cd_value_list[1].code_set = 220
   SET request_cv->cd_value_list[1].code_value = request->fac[f].bld[b].unit[u].room[r].
   location_code_value
   SET request_cv->cd_value_list[1].display = substring(1,40,request->fac[f].bld[b].unit[u].room[r].
    short_description)
   SET request_cv->cd_value_list[1].description = substring(1,60,request->fac[f].bld[b].unit[u].room[
    r].full_description)
   SET request_cv->cd_value_list[1].cdf_meaning = " "
   SET request_cv->cd_value_list[1].active_ind = 1
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   IF ((reply_cv->status_data.status != "S"))
    SET error_flag = "Y"
    SET error_msg = concat("Error updating room code value for facility: ",request->fac[f].
     full_description,", building: ",request->fac[f].bld[b].full_description,", unit: ",
     request->fac[f].bld[b].unit[u].full_description,", room: ",request->fac[f].bld[b].unit[u].room[r
     ].full_description,".")
    GO TO exit_script
   ENDIF
   UPDATE  FROM location l
    SET l.updt_dt_tm = cnvtdatetime(curdate,curtime), l.updt_cnt = (l.updt_cnt+ 1), l.updt_id =
     reqinfo->updt_id,
     l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx
    WHERE (l.location_cd=request->fac[f].bld[b].unit[u].room[r].location_code_value)
    WITH nocounter
   ;end update
   UPDATE  FROM room r
    SET r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_id = reqinfo->updt_id, r.updt_task =
     reqinfo->updt_task,
     r.updt_applctx = reqinfo->updt_applctx, r.updt_cnt = (r.updt_cnt+ 1)
    WHERE (r.location_cd=request->fac[f].bld[b].unit[u].room[r].location_code_value)
    WITH nocounter
   ;end update
   IF ((request->fac[f].bld[b].unit[u].room[r].sequence > 0))
    UPDATE  FROM location_group l
     SET l.sequence = request->fac[f].bld[b].unit[u].room[r].sequence, l.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), l.updt_id = reqinfo->updt_id,
      l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = (l
      .updt_cnt+ 1)
     WHERE (l.parent_loc_cd=request->fac[f].bld[b].unit[u].location_code_value)
      AND (l.child_loc_cd=request->fac[f].bld[b].unit[u].room[r].location_code_value)
      AND (l.location_group_type_cd=request->fac[f].bld[b].unit[u].location_type_code_value)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error updating locaction group (sequence) for unit: ",request->fac[f].
      bld[b].unit[u].full_description," room: ",request->fac[f].bld[b].unit[u].room[r].
      full_description,".")
     GO TO exit_script
    ENDIF
   ENDIF
   IF ((request->fac[f].bld[b].unit[u].room[r].area_id > " "))
    SET br_value = cnvtstring(request->fac[f].bld[b].unit[u].room[r].location_code_value)
    SET br_name = request->fac[f].bld[b].unit[u].room[r].area_id
    UPDATE  FROM br_name_value br
     SET br.br_name = br_name, br.updt_cnt = (br.updt_cnt+ 1), br.updt_dt_tm = cnvtdatetime(curdate,
       curtime),
      br.updt_id = reqinfo->updt_id, br.updt_task = reqinfo->updt_task, br.updt_applctx = reqinfo->
      updt_applctx
     WHERE br.br_nv_key1="EDAREAROOMRELTN"
      AND br.br_value=br_value
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error updating BR_NAME_VALUE row for building: ",request->fac[f].bld[b].
      full_description,", unit: ",request->fac[f].bld[b].unit[u].full_description,", room: ",
      request->fac[f].bld[b].unit[u].room[r].full_description,".")
     GO TO exit_script
    ENDIF
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE del_room(b,u,r)
   SET request_cv->cd_value_list[1].action_flag = 3
   SET request_cv->cd_value_list[1].code_set = 220
   SET request_cv->cd_value_list[1].code_value = request->fac[f].bld[b].unit[u].room[r].
   location_code_value
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   UPDATE  FROM location l
    SET l.active_ind = 0, l.active_status_cd = inactive_cd, l.end_effective_dt_tm = cnvtdatetime(
      curdate,curtime),
     l.updt_dt_tm = cnvtdatetime(curdate,curtime), l.updt_id = reqinfo->updt_id, l.updt_task =
     reqinfo->updt_task,
     l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = (l.updt_cnt+ 1)
    WHERE (l.location_cd=request->fac[f].bld[b].unit[u].room[r].location_code_value)
    WITH nocounter
   ;end update
   UPDATE  FROM location_group lg
    SET lg.active_ind = 0, lg.active_status_cd = inactive_cd, lg.end_effective_dt_tm = cnvtdatetime(
      curdate,curtime),
     lg.updt_dt_tm = cnvtdatetime(curdate,curtime), lg.updt_id = reqinfo->updt_id, lg.updt_task =
     reqinfo->updt_task,
     lg.updt_applctx = reqinfo->updt_applctx, lg.updt_cnt = (lg.updt_cnt+ 1)
    WHERE (lg.parent_loc_cd=request->fac[f].bld[b].unit[u].room[r].location_code_value)
    WITH nocounter
   ;end update
   UPDATE  FROM location_group lg
    SET lg.active_ind = 0, lg.active_status_cd = inactive_cd, lg.end_effective_dt_tm = cnvtdatetime(
      curdate,curtime),
     lg.updt_dt_tm = cnvtdatetime(curdate,curtime), lg.updt_id = reqinfo->updt_id, lg.updt_task =
     reqinfo->updt_task,
     lg.updt_applctx = reqinfo->updt_applctx, lg.updt_cnt = (lg.updt_cnt+ 1)
    WHERE (lg.child_loc_cd=request->fac[f].bld[b].unit[u].room[r].location_code_value)
    WITH nocounter
   ;end update
   UPDATE  FROM room r
    SET r.active_ind = 0, r.active_status_cd = inactive_cd, r.end_effective_dt_tm = cnvtdatetime(
      curdate,curtime),
     r.updt_dt_tm = cnvtdatetime(curdate,curtime), r.updt_id = reqinfo->updt_id, r.updt_task =
     reqinfo->updt_task,
     r.updt_applctx = reqinfo->updt_applctx, r.updt_cnt = (r.updt_cnt+ 1)
    WHERE (r.location_cd=request->fac[f].bld[b].unit[u].room[r].location_code_value)
    WITH nocounter
   ;end update
   IF ((request->fac[f].bld[b].unit[u].room[r].area_id > " "))
    SET br_value = cnvtstring(request->fac[f].bld[b].unit[u].room[r].location_code_value)
    SET br_name = request->fac[f].bld[b].unit[u].room[r].area_id
    DELETE  FROM br_name_value br
     WHERE br.br_nv_key1="EDAREAROOMRELTN"
      AND br.name=br_name
      AND br.value=br_value
     WITH nocounter
    ;end delete
   ENDIF
   IF ((request->fac[f].bld[b].unit[u].room[r].delete_room_alias_ind=1))
    DELETE  FROM code_value_alias cva
     WHERE (cva.code_value=request->fac[f].bld[b].unit[u].room[r].location_code_value)
     WITH nocounter
    ;end delete
    DELETE  FROM code_value_outbound cvo
     WHERE (cvo.code_value=request->fac[f].bld[b].unit[u].room[r].location_code_value)
     WITH nocounter
    ;end delete
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE add_bed(b,u,r,d)
   SET next_code = 0.0
   IF ((request->fac[f].bld[b].unit[u].room[r].bed[d].full_description > " "))
    SET next_code = 0.0
   ELSE
    SET request->fac[f].bld[b].unit[u].room[r].bed[d].full_description = request->fac[f].bld[b].unit[
    u].room[r].bed[d].short_description
   ENDIF
   SET request_cv->cd_value_list[1].action_flag = 1
   SET request_cv->cd_value_list[1].code_set = 220
   SET request_cv->cd_value_list[1].display = substring(1,40,request->fac[f].bld[b].unit[u].room[r].
    bed[d].short_description)
   SET request_cv->cd_value_list[1].description = substring(1,60,request->fac[f].bld[b].unit[u].room[
    r].bed[d].full_description)
   SET request_cv->cd_value_list[1].definition = " "
   SET request_cv->cd_value_list[1].cdf_meaning = "BED"
   SET request_cv->cd_value_list[1].concept_cki = " "
   SET request_cv->cd_value_list[1].collation_seq = 0
   SET request_cv->cd_value_list[1].active_ind = 1
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   SET next_code = 0.0
   IF ((reply_cv->status_data.status="S")
    AND (reply_cv->qual[1].code_value > 0))
    SET next_code = reply_cv->qual[1].code_value
    SET request->fac[f].bld[b].unit[u].room[r].bed[d].location_code_value = next_code
    INSERT  FROM location l
     SET l.location_cd = next_code, l.location_type_cd = bed_cd, l.organization_id = org_id,
      l.census_ind = 1, l.active_ind = 1, l.active_status_cd = active_cd,
      l.active_status_dt_tm = cnvtdatetime(curdate,curtime3), l.active_status_prsnl_id = 0, l
      .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      l.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"), l.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), l.updt_id = reqinfo->updt_id,
      l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = 0,
      l.data_status_cd = auth_cd, l.data_status_prsnl_id = 0, l.data_status_dt_tm = cnvtdatetime(
       curdate,curtime3),
      l.contributor_system_cd = 0, l.contributor_source_cd = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error writing BED location for facility: ",request->fac[f].
      full_description,", building: ",request->fac[f].bld[b].full_description,", unit: ",
      request->fac[f].bld[b].unit[u].full_description,", room: ",request->fac[f].bld[b].unit[u].room[
      r].full_description,", bed: ",request->fac[f].bld[b].unit[u].room[r].bed[d].full_description,
      ".")
     GO TO exit_script
    ELSE
     INSERT  FROM location_group l
      SET l.parent_loc_cd = request->fac[f].bld[b].unit[u].room[r].location_code_value, l
       .child_loc_cd = next_code, l.location_group_type_cd = room_cd,
       l.sequence =
       IF ((request->fac[f].bld[b].unit[u].room[r].bed[d].sequence > 0)) request->fac[f].bld[b].unit[
        u].room[r].bed[d].sequence
       ELSE (d - 1)
       ENDIF
       , l.root_loc_cd = 0, l.active_ind = 1,
       l.active_status_cd = active_cd, l.active_status_dt_tm = cnvtdatetime(curdate,curtime3), l
       .active_status_prsnl_id = 0,
       l.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), l.end_effective_dt_tm = cnvtdatetime(
        "31-dec-2100 00:00:00.00"), l.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       l.updt_id = reqinfo->updt_id, l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->
       updt_applctx,
       l.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Error writing location group for building: ",request->fac[f].bld[b].
       full_description,", unit: ",request->fac[f].bld[b].unit[u].full_description,", room: ",
       request->fac[f].bld[b].unit[u].room[r].full_description,", bed: ",request->fac[f].bld[b].unit[
       u].room[r].bed[d].full_description,".")
      GO TO exit_script
     ELSE
      INSERT  FROM bed b
       SET b.location_cd = next_code, b.loc_room_cd = request->fac[f].bld[b].unit[u].room[r].
        location_code_value, b.dup_bed_ind = 0,
        b.active_ind = 1, b.active_status_cd = active_cd, b.active_status_dt_tm = cnvtdatetime(
         curdate,curtime3),
        b.active_status_prsnl_id = 0, b.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), b
        .end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"),
        b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
        reqinfo->updt_task,
        b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Error writing BED row for building: ",request->fac[f].bld[b].
        full_description,", unit: ",request->fac[f].bld[b].unit[u].full_description,", room: ",
        request->fac[f].bld[b].unit[u].room[r].full_description,", bed: ",request->fac[f].bld[b].
        unit[u].room[r].bed[d].full_description,".")
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET error_flag = "Y"
    SET error_msg = concat("Error writing BED code value for facility: ",request->fac[f].
     full_description,", building: ",request->fac[f].bld[b].full_description,", unit: ",
     request->fac[f].bld[b].unit[u].full_description,", room: ",request->fac[f].bld[b].unit[u].room[r
     ].full_description,", bed: ",request->fac[f].bld[b].unit[u].room[r].bed[d].full_description,
     ".")
    GO TO exit_script
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE chg_bed(b,u,r,d)
   IF ((request->fac[f].bld[b].unit[u].room[r].bed[d].full_description > " "))
    SET error_flag = error_flag
   ELSE
    SET request->fac[f].bld[b].unit[u].room[r].bed[d].full_description = request->fac[f].bld[b].unit[
    u].room[r].bed[d].short_description
   ENDIF
   SET request_cv->cd_value_list[1].action_flag = 2
   SET request_cv->cd_value_list[1].code_set = 220
   SET request_cv->cd_value_list[1].code_value = request->fac[f].bld[b].unit[u].room[r].bed[d].
   location_code_value
   SET request_cv->cd_value_list[1].display = substring(1,40,request->fac[f].bld[b].unit[u].room[r].
    bed[d].short_description)
   SET request_cv->cd_value_list[1].description = substring(1,60,request->fac[f].bld[b].unit[u].room[
    r].bed[d].full_description)
   SET request_cv->cd_value_list[1].cdf_meaning = " "
   SET request_cv->cd_value_list[1].active_ind = 1
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   IF ((reply_cv->status_data.status != "S"))
    SET error_flag = "Y"
    SET error_msg = concat("Error updating bed code value for facility: ",request->fac[f].
     full_description,", building: ",request->fac[f].bld[b].full_description,", unit: ",
     request->fac[f].bld[b].unit[u].full_description,", room: ",request->fac[f].bld[b].unit[u].room[r
     ].full_description,", bed: ",request->fac[f].bld[b].unit[u].room[r].bed[d].full_description,
     ".")
    GO TO exit_script
   ENDIF
   UPDATE  FROM location l
    SET l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_id = reqinfo->updt_id, l.updt_task =
     reqinfo->updt_task,
     l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = (l.updt_cnt+ 1)
    WHERE (l.location_cd=request->fac[f].bld[b].unit[u].room[r].bed[d].location_code_value)
    WITH nocounter
   ;end update
   UPDATE  FROM bed b
    SET b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
     reqinfo->updt_task,
     b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = (b.updt_cnt+ 1)
    WHERE (b.location_cd=request->fac[f].bld[b].unit[u].room[r].bed[d].location_code_value)
    WITH nocounter
   ;end update
   IF ((request->fac[f].bld[b].unit[u].room[r].bed[d].sequence > 0))
    UPDATE  FROM location_group l
     SET l.sequence = request->fac[f].bld[b].unit[u].room[r].bed[d].sequence, l.updt_dt_tm =
      cnvtdatetime(curdate,curtime3), l.updt_id = reqinfo->updt_id,
      l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = (l
      .updt_cnt+ 1)
     WHERE (l.parent_loc_cd=request->fac[f].bld[b].unit[u].room[r].location_code_value)
      AND (l.child_loc_cd=request->fac[f].bld[b].unit[u].room[r].bed[d].location_code_value)
      AND l.location_group_type_cd=room_cd
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error updating locaction group (sequence) for room: ",request->fac[f].
      bld[b].unit[u].room[r].full_description," bed: ",request->fac[f].bld[b].unit[u].room[r].bed[d].
      full_description,".")
     GO TO exit_script
    ENDIF
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE del_bed(b,u,r,d)
   SET request_cv->cd_value_list[1].action_flag = 3
   SET request_cv->cd_value_list[1].code_set = 220
   SET request_cv->cd_value_list[1].code_value = request->fac[f].bld[b].unit[u].room[r].bed[d].
   location_code_value
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   UPDATE  FROM location l
    SET l.active_ind = 0, l.active_status_cd = inactive_cd, l.end_effective_dt_tm = cnvtdatetime(
      curdate,curtime),
     l.updt_dt_tm = cnvtdatetime(curdate,curtime), l.updt_id = reqinfo->updt_id, l.updt_task =
     reqinfo->updt_task,
     l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = (l.updt_cnt+ 1)
    WHERE (l.location_cd=request->fac[f].bld[b].unit[u].room[r].bed[d].location_code_value)
    WITH nocounter
   ;end update
   UPDATE  FROM location_group lg
    SET lg.active_ind = 0, lg.active_status_cd = inactive_cd, lg.end_effective_dt_tm = cnvtdatetime(
      curdate,curtime),
     lg.updt_dt_tm = cnvtdatetime(curdate,curtime), lg.updt_id = reqinfo->updt_id, lg.updt_task =
     reqinfo->updt_task,
     lg.updt_applctx = reqinfo->updt_applctx, lg.updt_cnt = (lg.updt_cnt+ 1)
    WHERE (lg.parent_loc_cd=request->fac[f].bld[b].unit[u].room[r].bed[d].location_code_value)
    WITH nocounter
   ;end update
   UPDATE  FROM location_group lg
    SET lg.active_ind = 0, lg.active_status_cd = inactive_cd, lg.end_effective_dt_tm = cnvtdatetime(
      curdate,curtime),
     lg.updt_dt_tm = cnvtdatetime(curdate,curtime), lg.updt_id = reqinfo->updt_id, lg.updt_task =
     reqinfo->updt_task,
     lg.updt_applctx = reqinfo->updt_applctx, lg.updt_cnt = (lg.updt_cnt+ 1)
    WHERE (lg.child_loc_cd=request->fac[f].bld[b].unit[u].room[r].bed[d].location_code_value)
    WITH nocounter
   ;end update
   UPDATE  FROM bed b
    SET b.active_ind = 0, b.active_status_cd = inactive_cd, b.end_effective_dt_tm = cnvtdatetime(
      curdate,curtime),
     b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id = reqinfo->updt_id, b.updt_task =
     reqinfo->updt_task,
     b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = (b.updt_cnt+ 1)
    WHERE (b.location_cd=request->fac[f].bld[b].unit[u].room[r].bed[d].location_code_value)
    WITH nocounter
   ;end update
   IF ((request->fac[f].bld[b].unit[u].room[r].bed[d].delete_bed_alias_ind=1))
    DELETE  FROM code_value_alias cva
     WHERE (cva.code_value=request->fac[f].bld[b].unit[u].room[r].bed[d].location_code_value)
     WITH nocounter
    ;end delete
    DELETE  FROM code_value_outbound cvo
     WHERE (cvo.code_value=request->fac[f].bld[b].unit[u].room[r].bed[d].location_code_value)
     WITH nocounter
    ;end delete
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE add_bld_address(b,y)
   SET address_type_cd = 0.0
   IF ((request->fac[f].bld[b].address[y].address_type_code_value=0))
    IF (trim(request->fac[f].bld[b].address[y].address_type_mean) > " ")
     SELECT INTO "nl:"
      FROM code_value c
      PLAN (c
       WHERE c.code_set=212
        AND (c.cdf_meaning=request->fac[f].bld[b].address[y].address_type_mean))
      DETAIL
       address_type_cd = c.code_value
      WITH nocounter
     ;end select
     IF (address_type_cd=0)
      SET error_flag = "Y"
      SET error_msg = concat("Code value not found for address type mean: ",request->fac[f].bld[b].
       address[y].address_type_mean,". Unable to add address for building name: ",request->fac[f].
       bld[b].short_description,".")
      GO TO exit_script
     ENDIF
    ELSE
     SET error_flag = "Y"
     SET error_msg = concat("Address type code value not available, unable to add ",
      "address for building name: ",request->fac[f].bld[b].short_description,".")
     GO TO exit_script
    ENDIF
   ELSE
    SET address_type_cd = request->fac[f].bld[b].address[y].address_type_code_value
   ENDIF
   IF (address_type_cd > 0)
    SELECT INTO "nl:"
     FROM address a
     PLAN (a
      WHERE a.address_type_cd=address_type_cd
       AND (a.parent_entity_id=request->fac[f].bld[b].location_code_value)
       AND a.parent_entity_name="LOCATION"
       AND a.active_ind=1)
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET error_flag = "Y"
     SET error_msg = concat("Address type already exists for building name: ",request->fac[f].bld[b].
      short_description," address type: ",request->fac[f].bld[b].address[y].address_type_mean,".")
     GO TO exit_script
    ELSE
     SET state_display = " "
     IF ((request->fac[f].bld[b].address[y].state_code_value > 0))
      SELECT INTO "NL:"
       FROM code_value cv
       WHERE (cv.code_value=request->fac[f].bld[b].address[y].state_code_value)
        AND cv.active_ind=1
       DETAIL
        state_display = cv.display
       WITH nocounter
      ;end select
     ENDIF
     SET county_display = " "
     IF ((request->fac[f].bld[b].address[y].county_code_value > 0))
      SELECT INTO "NL:"
       FROM code_value cv
       WHERE (cv.code_value=request->fac[f].bld[b].address[y].county_code_value)
        AND cv.active_ind=1
       DETAIL
        county_display = cv.display
       WITH nocounter
      ;end select
     ENDIF
     SET country_display = " "
     IF ((request->fac[f].bld[b].address[y].country_code_value > 0))
      SELECT INTO "NL:"
       FROM code_value cv
       WHERE (cv.code_value=request->fac[f].bld[b].address[y].country_code_value)
        AND cv.active_ind=1
       DETAIL
        country_display = cv.display
       WITH nocounter
      ;end select
     ENDIF
     INSERT  FROM address a
      SET a.address_id = seq(address_seq,nextval), a.parent_entity_name = "LOCATION", a
       .parent_entity_id = request->fac[f].bld[b].location_code_value,
       a.address_type_cd = address_type_cd, a.updt_id = reqinfo->updt_id, a.updt_cnt = 0,
       a.updt_applctx = reqinfo->updt_applctx, a.updt_task = reqinfo->updt_task, a.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       a.active_ind = 1, a.active_status_cd = active_cd, a.active_status_dt_tm = cnvtdatetime(curdate,
        curtime3),
       a.active_status_prsnl_id = 0, a.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), a
       .end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
       a.street_addr = request->fac[f].bld[b].address[y].street_addr1, a.street_addr2 = request->fac[
       f].bld[b].address[y].street_addr2, a.street_addr3 = request->fac[f].bld[b].address[y].
       street_addr3,
       a.street_addr4 = request->fac[f].bld[b].address[y].street_addr4, a.city = request->fac[f].bld[
       b].address[y].city, a.state = state_display,
       a.state_cd = request->fac[f].bld[b].address[y].state_code_value, a.zipcode = request->fac[f].
       bld[b].address[y].zipcode, a.zipcode_key = cnvtupper(cnvtalphanum(request->fac[f].bld[b].
         address[y].zipcode)),
       a.county = county_display, a.county_cd = request->fac[f].bld[b].address[y].county_code_value,
       a.country = country_display,
       a.country_cd = request->fac[f].bld[b].address[y].country_code_value, a.contact_name = request
       ->fac[f].bld[b].address[y].contact_name, a.comment_txt = request->fac[f].bld[b].address[y].
       comment_txt,
       a.postal_barcode_info = " ", a.mail_stop = " ", a.data_status_cd = auth_cd,
       a.data_status_dt_tm = cnvtdatetime(curdate,curtime3), a.data_status_prsnl_id = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Error writing address for bld name: ",request->fac[f].bld[b].
       short_description," address type: ",request->fac[f].bld[b].address[y].address_type_mean,".")
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE chg_bld_address(b,y)
  IF ((request->fac[f].bld[b].address[y].address_id > 0))
   SET state_display = " "
   IF ((request->fac[f].bld[b].address[y].state_code_value > 0))
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE (cv.code_value=request->fac[f].bld[b].address[y].state_code_value)
      AND cv.active_ind=1
     DETAIL
      state_display = cv.display
     WITH nocounter
    ;end select
   ENDIF
   SET county_display = " "
   IF ((request->fac[f].bld[b].address[y].county_code_value > 0))
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE (cv.code_value=request->fac[f].bld[b].address[y].county_code_value)
      AND cv.active_ind=1
     DETAIL
      county_display = cv.display
     WITH nocounter
    ;end select
   ENDIF
   SET country_display = " "
   IF ((request->fac[f].bld[b].address[y].country_code_value > 0))
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE (cv.code_value=request->fac[f].bld[b].address[y].country_code_value)
      AND cv.active_ind=1
     DETAIL
      country_display = cv.display
     WITH nocounter
    ;end select
   ENDIF
   UPDATE  FROM address a
    SET a.street_addr = request->fac[f].bld[b].address[y].street_addr1, a.street_addr2 = request->
     fac[f].bld[b].address[y].street_addr2, a.street_addr3 = request->fac[f].bld[b].address[y].
     street_addr3,
     a.street_addr4 = request->fac[f].bld[b].address[y].street_addr4, a.city = request->fac[f].bld[b]
     .address[y].city, a.state = state_display,
     a.state_cd = request->fac[f].bld[b].address[y].state_code_value, a.zipcode = request->fac[f].
     bld[b].address[y].zipcode, a.zipcode_key = cnvtupper(cnvtalphanum(request->fac[f].bld[b].
       address[y].zipcode)),
     a.county = county_display, a.county_cd = request->fac[f].bld[b].address[y].county_code_value, a
     .country = country_display,
     a.country_cd = request->fac[f].bld[b].address[y].country_code_value, a.address_type_cd = request
     ->fac[f].bld[b].address[y].address_type_code_value, a.contact_name = request->fac[f].bld[b].
     address[y].contact_name,
     a.comment_txt = request->fac[f].bld[b].address[y].comment_txt, a.updt_cnt = (a.updt_cnt+ 1), a
     .updt_id = reqinfo->updt_id,
     a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->updt_applctx, a.updt_dt_tm =
     cnvtdatetime(curdate,curtime3)
    WHERE (a.address_id=request->fac[f].bld[b].address[y].address_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Error updating address for bld name: ",request->fac[f].bld[b].
     short_description," address type: ",request->fac[f].bld[b].address[y].address_type_mean,".")
    GO TO exit_script
   ENDIF
  ELSE
   SET error_flag = "Y"
   SET error_msg = concat("Address_ID required, error updating address for bld name: ",request->fac[f
    ].bld[b].short_description," address type: ",request->fac[f].bld[b].address[y].address_type_mean,
    ".")
   GO TO exit_script
  ENDIF
  RETURN(1.0)
 END ;Subroutine
 SUBROUTINE del_bld_address(b,y)
  IF ((request->fac[f].bld[b].address[y].address_id > 0))
   UPDATE  FROM address a
    SET a.active_ind = 0, a.updt_cnt = (a.updt_cnt+ 1), a.updt_id = reqinfo->updt_id,
     a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->updt_applctx, a.updt_dt_tm =
     cnvtdatetime(curdate,curtime3)
    WHERE (a.address_id=request->fac[f].bld[b].address[y].address_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Error inactivating address for bld name: ",request->fac[f].bld[b].
     short_desc," address type: ",request->fac[f].bld[b].address[y].address_type_mean,".")
    GO TO exit_script
   ENDIF
  ELSE
   SET error_flag = "Y"
   SET error_msg = concat("Address_ID required, error inactivating address for bld name: ",request->
    fac[f].bld[b].short_description," address type: ",request->fac[f].bld[b].address[y].
    address_type_mean,".")
   GO TO exit_script
  ENDIF
  RETURN(1.0)
 END ;Subroutine
 SUBROUTINE add_bld_phone(b,y)
   SET phone_type_cd = 0.0
   IF ((request->fac[f].bld[b].phone[y].phone_type_code_value=0))
    IF (trim(request->fac[f].bld[b].phone[y].phone_type_mean) > " ")
     SELECT INTO "nl:"
      FROM code_value c
      PLAN (c
       WHERE c.code_set=43
        AND (c.cdf_meaning=request->fac[f].bld[b].phone[y].phone_type_mean))
      DETAIL
       phone_type_cd = c.code_value
      WITH nocounter
     ;end select
     IF (phone_type_cd=0)
      SET error_flag = "Y"
      SET error_msg = concat("Code value not found for phone type mean: ",request->fac[f].bld[b].
       phone[y].phone_type_mean,". Unable to add phone for bld name: ",request->fac[f].bld[b].
       short_description,".")
      GO TO exit_script
     ENDIF
    ELSE
     SET error_flag = "Y"
     SET error_msg = concat("Phone type code value not available, unable to add ",
      "phone for bld name: ",request->fac[f].bld[b].short_description,".")
     GO TO exit_script
    ENDIF
   ELSE
    SET phone_type_cd = request->fac[f].bld[b].phone[y].phone_type_code_value
   ENDIF
   IF (phone_type_cd > 0)
    SELECT INTO "nl:"
     FROM phone p
     PLAN (p
      WHERE p.phone_type_cd=phone_type_cd
       AND (p.parent_entity_id=request->fac[f].bld[b].location_code_value)
       AND p.parent_entity_name="LOCATION"
       AND p.active_ind=1)
     WITH nocounter
    ;end select
    IF (curqual > 0
     AND allow_mult_phone_types=0)
     SET error_flag = "Y"
     SET error_msg = concat("Phone type already exists for bld name: ",request->fac[f].bld[b].
      short_description," phone type: ",request->fac[f].bld[b].phone[y].phone_type_mean,".")
     GO TO exit_script
    ELSE
     SET phone_format_cd = 0.0
     IF ((request->fac[f].bld[b].phone[y].phone_format_code_value > 0))
      SET phone_format_cd = request->fac[f].bld[b].phone[y].phone_format_code_value
     ELSE
      IF (trim(request->fac[f].bld[b].phone[y].phone_format_mean) > " ")
       SELECT INTO "nl:"
        FROM code_value c
        PLAN (c
         WHERE c.code_set=281
          AND (c.cdf_meaning=request->fac[f].bld[b].phone[y].phone_format_mean))
        DETAIL
         phone_format_cd = c.code_value
        WITH nocounter
       ;end select
       IF (curqual=0)
        SET error_flag = "Y"
        SET error_msg = concat("Unable to find phone format on code set 281 for: ",request->fac[f].
         bld[b].phone[y].phone_format_mean,".")
        GO TO exit_script
       ENDIF
      ELSE
       SET error_flag = "Y"
       SET error_msg = concat("Invalid phone format on bld: ",request->fac[f].bld[b].
        short_description,".")
       GO TO exit_script
      ENDIF
     ENDIF
     INSERT  FROM phone p
      SET p.phone_id = seq(phone_seq,nextval), p.parent_entity_name = "LOCATION", p.parent_entity_id
        = request->fac[f].bld[b].location_code_value,
       p.phone_type_cd = phone_type_cd, p.phone_format_cd = phone_format_cd, p.phone_num = trim(
        request->fac[f].bld[b].phone[y].phone_num),
       p.phone_num_key = trim(cnvtupper(cnvtalphanum(request->fac[f].bld[b].phone[y].phone_num))), p
       .phone_type_seq = request->fac[f].bld[b].phone[y].sequence, p.description = trim(request->fac[
        f].bld[b].phone[y].description),
       p.contact = trim(request->fac[f].bld[b].phone[y].contact), p.call_instruction = trim(request->
        fac[f].bld[b].phone[y].call_instruction), p.extension = trim(request->fac[f].bld[b].phone[y].
        extension),
       p.paging_code = trim(request->fac[f].bld[b].phone[y].paging_code), p.updt_id = reqinfo->
       updt_id, p.updt_cnt = 0,
       p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->updt_task, p.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       p.active_ind = 1, p.active_status_cd = active_cd, p.active_status_dt_tm = cnvtdatetime(curdate,
        curtime3),
       p.active_status_prsnl_id = 0, p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p
       .end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
       p.data_status_cd = auth_cd, p.data_status_dt_tm = cnvtdatetime(curdate,curtime3), p
       .data_status_prsnl_id = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Error writing phone for bld name: ",request->fac[f].bld[b].
       short_description," phone type: ",request->fac[f].bld[b].phone[y].phone_type_mean,".")
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE chg_bld_phone(b,y)
  IF ((request->fac[f].bld[b].phone[y].phone_id > 0))
   UPDATE  FROM phone p
    SET p.phone_format_cd = request->fac[f].bld[b].phone[y].phone_format_code_value, p.phone_num =
     request->fac[f].bld[b].phone[y].phone_num, p.phone_num_key = cnvtupper(cnvtalphanum(request->
       fac[f].bld[b].phone[y].phone_num)),
     p.phone_type_seq = request->fac[f].bld[b].phone[y].sequence, p.description = request->fac[f].
     bld[b].phone[y].description, p.contact = request->fac[f].bld[b].phone[y].contact,
     p.call_instruction = request->fac[f].bld[b].phone[y].call_instruction, p.paging_code = request->
     fac[f].bld[b].phone[y].paging_code, p.extension = request->fac[f].bld[b].phone[y].extension,
     p.phone_type_cd = request->fac[f].bld[b].phone[y].phone_type_code_value, p.updt_cnt = (p
     .updt_cnt+ 1), p.updt_id = reqinfo->updt_id,
     p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_dt_tm =
     cnvtdatetime(curdate,curtime3)
    WHERE (p.phone_id=request->fac[f].bld[b].phone[y].phone_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Error updating phone for bld name: ",request->fac[f].bld[b].
     short_description," phone type: ",request->fac[f].bld[b].phone[y].phone_type_mean,".")
    GO TO exit_script
   ENDIF
  ELSE
   SET error_flag = "Y"
   SET error_msg = concat("Phone_ID required, error updating phone for bld name: ",request->fac[f].
    bld[b].short_description," phone type: ",request->fac[f].bld[b].phone[y].phone_type_mean,".")
   GO TO exit_script
  ENDIF
  RETURN(1.0)
 END ;Subroutine
 SUBROUTINE del_bld_phone(b,y)
  IF ((request->fac[f].bld[b].phone[y].phone_id > 0))
   UPDATE  FROM phone p
    SET p.active_ind = 0, p.updt_cnt = (p.updt_cnt+ 1), p.updt_id = reqinfo->updt_id,
     p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_dt_tm =
     cnvtdatetime(curdate,curtime3)
    WHERE (p.phone_id=request->fac[f].bld[b].phone[y].phone_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Error inactivating phone for bld name: ",request->fac[f].bld[b].
     short_description," phone type: ",request->fac[f].bld[b].phone[y].phone_type_mean,".")
    GO TO exit_script
   ENDIF
  ELSE
   SET error_flag = "Y"
   SET error_msg = concat("Phone_ID required, error inactivating phone for bld name: ",request->fac[f
    ].bld[b].short_description," phone type: ",request->fac[f].bld[b].phone[y].phone_type_mean,".")
   GO TO exit_script
  ENDIF
  RETURN(1.0)
 END ;Subroutine
 SUBROUTINE add_unit_address(b,u,y)
   SET address_type_cd = 0.0
   IF ((request->fac[f].bld[b].unit[u].address[y].address_type_code_value=0))
    IF (trim(request->fac[f].bld[b].unit[u].address[y].address_type_mean) > " ")
     SELECT INTO "nl:"
      FROM code_value c
      PLAN (c
       WHERE c.code_set=212
        AND (c.cdf_meaning=request->fac[f].bld[b].unit[u].address[y].address_type_mean))
      DETAIL
       address_type_cd = c.code_value
      WITH nocounter
     ;end select
     IF (address_type_cd=0)
      SET error_flag = "Y"
      SET error_msg = concat("Code value not found for address type mean: ",request->fac[f].bld[b].
       unit[u].address[y].address_type_mean,". Unable to add address for unit name: ",request->fac[f]
       .bld[b].unit[u].short_description,".")
      GO TO exit_script
     ENDIF
    ELSE
     SET error_flag = "Y"
     SET error_msg = concat("Address type code value not available, unable to add ",
      "address for unit name: ",request->fac[f].bld[b].unit[u].short_description,".")
     GO TO exit_script
    ENDIF
   ELSE
    SET address_type_cd = request->fac[f].bld[b].unit[u].address[y].address_type_code_value
   ENDIF
   IF (address_type_cd > 0)
    SELECT INTO "nl:"
     FROM address a
     PLAN (a
      WHERE a.address_type_cd=address_type_cd
       AND (a.parent_entity_id=request->fac[f].bld[b].unit[u].location_code_value)
       AND a.parent_entity_name="LOCATION"
       AND a.active_ind=1)
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET error_flag = "Y"
     SET error_msg = concat("Address type already exists for unit name: ",request->fac[f].bld[b].
      unit[u].short_description," address type: ",request->fac[f].bld[b].unit[u].address[y].
      address_type_mean,".")
     GO TO exit_script
    ELSE
     SET state_display = " "
     IF ((request->fac[f].bld[b].unit[u].address[y].state_code_value > 0))
      SELECT INTO "NL:"
       FROM code_value cv
       WHERE (cv.code_value=request->fac[f].bld[b].unit[u].address[y].state_code_value)
        AND cv.active_ind=1
       DETAIL
        state_display = cv.display
       WITH nocounter
      ;end select
     ENDIF
     SET county_display = " "
     IF ((request->fac[f].bld[b].unit[u].address[y].county_code_value > 0))
      SELECT INTO "NL:"
       FROM code_value cv
       WHERE (cv.code_value=request->fac[f].bld[b].unit[u].address[y].county_code_value)
        AND cv.active_ind=1
       DETAIL
        county_display = cv.display
       WITH nocounter
      ;end select
     ENDIF
     SET country_display = " "
     IF ((request->fac[f].bld[b].unit[u].address[y].country_code_value > 0))
      SELECT INTO "NL:"
       FROM code_value cv
       WHERE (cv.code_value=request->fac[f].bld[b].unit[u].address[y].country_code_value)
        AND cv.active_ind=1
       DETAIL
        country_display = cv.display
       WITH nocounter
      ;end select
     ENDIF
     INSERT  FROM address a
      SET a.address_id = seq(address_seq,nextval), a.parent_entity_name = "LOCATION", a
       .parent_entity_id = request->fac[f].bld[b].unit[u].location_code_value,
       a.address_type_cd = address_type_cd, a.updt_id = reqinfo->updt_id, a.updt_cnt = 0,
       a.updt_applctx = reqinfo->updt_applctx, a.updt_task = reqinfo->updt_task, a.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       a.active_ind = 1, a.active_status_cd = active_cd, a.active_status_dt_tm = cnvtdatetime(curdate,
        curtime3),
       a.active_status_prsnl_id = 0, a.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), a
       .end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
       a.street_addr = request->fac[f].bld[b].unit[u].address[y].street_addr1, a.street_addr2 =
       request->fac[f].bld[b].unit[u].address[y].street_addr2, a.street_addr3 = request->fac[f].bld[b
       ].unit[u].address[y].street_addr3,
       a.street_addr4 = request->fac[f].bld[b].unit[u].address[y].street_addr4, a.city = request->
       fac[f].bld[b].unit[u].address[y].city, a.state = state_display,
       a.state_cd = request->fac[f].bld[b].unit[u].address[y].state_code_value, a.zipcode = request->
       fac[f].bld[b].unit[u].address[y].zipcode, a.zipcode_key = cnvtupper(cnvtalphanum(request->fac[
         f].bld[b].unit[u].address[y].zipcode)),
       a.county = county_display, a.county_cd = request->fac[f].bld[b].unit[u].address[y].
       county_code_value, a.country = country_display,
       a.country_cd = request->fac[f].bld[b].unit[u].address[y].country_code_value, a.contact_name =
       request->fac[f].bld[b].unit[u].address[y].contact_name, a.comment_txt = request->fac[f].bld[b]
       .unit[u].address[y].comment_txt,
       a.postal_barcode_info = " ", a.mail_stop = " ", a.data_status_cd = auth_cd,
       a.data_status_dt_tm = cnvtdatetime(curdate,curtime3), a.data_status_prsnl_id = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Error writing address for unit name: ",rrequest->fac[f].bld[b].unit[u].
       short_description," address type: ",request->fac[f].bld[b].unit[u].address[y].
       address_type_mean,".")
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE chg_unit_address(b,u,y)
  IF ((request->fac[f].bld[b].unit[u].address[y].address_id > 0))
   SET state_display = " "
   IF ((request->fac[f].bld[b].unit[u].address[y].state_code_value > 0))
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE (cv.code_value=request->fac[f].bld[b].unit[u].address[y].state_code_value)
      AND cv.active_ind=1
     DETAIL
      state_display = cv.display
     WITH nocounter
    ;end select
   ENDIF
   SET county_display = " "
   IF ((request->fac[f].bld[b].unit[u].address[y].county_code_value > 0))
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE (cv.code_value=request->fac[f].bld[b].unit[u].address[y].county_code_value)
      AND cv.active_ind=1
     DETAIL
      county_display = cv.display
     WITH nocounter
    ;end select
   ENDIF
   SET country_display = " "
   IF ((request->fac[f].bld[b].unit[u].address[y].country_code_value > 0))
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE (cv.code_value=request->fac[f].bld[b].unit[u].address[y].country_code_value)
      AND cv.active_ind=1
     DETAIL
      country_display = cv.display
     WITH nocounter
    ;end select
   ENDIF
   UPDATE  FROM address a
    SET a.street_addr = request->fac[f].bld[b].unit[u].address[y].street_addr1, a.street_addr2 =
     request->fac[f].bld[b].unit[u].address[y].street_addr2, a.street_addr3 = request->fac[f].bld[b].
     unit[u].address[y].street_addr3,
     a.street_addr4 = request->fac[f].bld[b].unit[u].address[y].street_addr4, a.city = request->fac[f
     ].bld[b].unit[u].address[y].city, a.state = state_display,
     a.state_cd = request->fac[f].bld[b].unit[u].address[y].state_code_value, a.zipcode = request->
     fac[f].bld[b].unit[u].address[y].zipcode, a.zipcode_key = cnvtupper(cnvtalphanum(request->fac[f]
       .bld[b].unit[u].address[y].zipcode)),
     a.county = county_display, a.county_cd = request->fac[f].bld[b].unit[u].address[y].
     county_code_value, a.country = country_display,
     a.country_cd = request->fac[f].bld[b].unit[u].address[y].country_code_value, a.address_type_cd
      = request->fac[f].bld[b].unit[u].address[y].address_type_code_value, a.contact_name = request->
     fac[f].bld[b].unit[u].address[y].contact_name,
     a.comment_txt = request->fac[f].bld[b].unit[u].address[y].comment_txt, a.updt_cnt = (a.updt_cnt
     + 1), a.updt_id = reqinfo->updt_id,
     a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->updt_applctx, a.updt_dt_tm =
     cnvtdatetime(curdate,curtime3)
    WHERE (a.address_id=request->fac[f].bld[b].unit[u].address[y].address_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Error updating address for unit name: ",request->fac[f].bld[b].unit[u].
     short_description," address type: ",request->fac[f].bld[b].unit[u].address[y].address_type_mean,
     ".")
    GO TO exit_script
   ENDIF
  ELSE
   SET error_flag = "Y"
   SET error_msg = concat("Address_ID required, error updating address for unit name: ",request->fac[
    f].bld[b].unit[u].short_description," address type: ",request->fac[f].bld[b].unit[u].address[y].
    address_type_mean,".")
   GO TO exit_script
  ENDIF
  RETURN(1.0)
 END ;Subroutine
 SUBROUTINE del_unit_address(b,u,y)
  IF ((request->fac[f].bld[b].unit[u].address[y].address_id > 0))
   UPDATE  FROM address a
    SET a.active_ind = 0, a.updt_cnt = (a.updt_cnt+ 1), a.updt_id = reqinfo->updt_id,
     a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->updt_applctx, a.updt_dt_tm =
     cnvtdatetime(curdate,curtime3)
    WHERE (a.address_id=request->fac[f].bld[b].unit[u].address[y].address_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Error inactivating address for unit name: ",request->fac[f].bld[b].unit[u
     ].short_desc," address type: ",request->fac[f].bld[b].unit[u].address[y].address_type_mean,".")
    GO TO exit_script
   ENDIF
  ELSE
   SET error_flag = "Y"
   SET error_msg = concat("Address_ID required, error inactivating address for unit name: ",request->
    fac[f].bld[b].unit[u].short_description," address type: ",request->fac[f].bld[b].unit[u].address[
    y].address_type_mean,".")
   GO TO exit_script
  ENDIF
  RETURN(1.0)
 END ;Subroutine
 SUBROUTINE add_unit_phone(b,u,y)
   SET phone_type_cd = 0.0
   IF ((request->fac[f].bld[b].unit[u].phone[y].phone_type_code_value=0))
    IF (trim(request->fac[f].bld[b].unit[u].phone[y].phone_type_mean) > " ")
     SELECT INTO "nl:"
      FROM code_value c
      PLAN (c
       WHERE c.code_set=43
        AND (c.cdf_meaning=request->fac[f].bld[b].unit[u].phone[y].phone_type_mean))
      DETAIL
       phone_type_cd = c.code_value
      WITH nocounter
     ;end select
     IF (phone_type_cd=0)
      SET error_flag = "Y"
      SET error_msg = concat("Code value not found for phone type mean: ",request->fac[f].bld[b].
       unit[u].phone[y].phone_type_mean,". Unable to add phone for unit name: ",request->fac[f].bld[b
       ].unit[u].short_description,".")
      GO TO exit_script
     ENDIF
    ELSE
     SET error_flag = "Y"
     SET error_msg = concat("Phone type code value not available, unable to add ",
      "phone for unit name: ",request->fac[f].bld[b].unit[u].short_description,".")
     GO TO exit_script
    ENDIF
   ELSE
    SET phone_type_cd = request->fac[f].bld[b].unit[u].phone[y].phone_type_code_value
   ENDIF
   IF (phone_type_cd > 0)
    SELECT INTO "nl:"
     FROM phone p
     PLAN (p
      WHERE p.phone_type_cd=phone_type_cd
       AND (p.parent_entity_id=request->fac[f].bld[b].unit[u].location_code_value)
       AND p.parent_entity_name="LOCATION"
       AND p.active_ind=1)
     WITH nocounter
    ;end select
    IF (curqual > 0
     AND allow_mult_phone_types=0)
     SET error_flag = "Y"
     SET error_msg = concat("Phone type already exists for unit name: ",request->fac[f].bld[b].unit[u
      ].short_description," phone type: ",request->fac[f].bld[b].unit[u].phone[y].phone_type_mean,"."
      )
     GO TO exit_script
    ELSE
     SET phone_format_cd = 0.0
     IF ((request->fac[f].bld[b].unit[u].phone[y].phone_format_code_value > 0))
      SET phone_format_cd = request->fac[f].bld[b].unit[u].phone[y].phone_format_code_value
     ELSE
      IF (trim(request->fac[f].bld[b].unit[u].phone[y].phone_format_mean) > " ")
       SELECT INTO "nl:"
        FROM code_value c
        PLAN (c
         WHERE c.code_set=281
          AND (c.cdf_meaning=request->fac[f].bld[b].unit[u].phone[y].phone_format_mean))
        DETAIL
         phone_format_cd = c.code_value
        WITH nocounter
       ;end select
       IF (curqual=0)
        SET error_flag = "Y"
        SET error_msg = concat("Unable to find phone format on code set 281 for: ",request->fac[f].
         bld[b].unit[u].phone[y].phone_format_mean,".")
        GO TO exit_script
       ENDIF
      ELSE
       SET error_flag = "Y"
       SET error_msg = concat("Invalid phone format on unit: ",request->fac[f].bld[b].unit[u].
        short_description,".")
       GO TO exit_script
      ENDIF
     ENDIF
     INSERT  FROM phone p
      SET p.phone_id = seq(phone_seq,nextval), p.parent_entity_name = "LOCATION", p.parent_entity_id
        = request->fac[f].bld[b].unit[u].location_code_value,
       p.phone_type_cd = phone_type_cd, p.phone_format_cd = phone_format_cd, p.phone_num = trim(
        request->fac[f].bld[b].unit[u].phone[y].phone_num),
       p.phone_num_key = trim(cnvtupper(cnvtalphanum(request->fac[f].bld[b].unit[u].phone[y].
          phone_num))), p.phone_type_seq = request->fac[f].bld[b].unit[u].phone[y].sequence, p
       .description = trim(request->fac[f].bld[b].unit[u].phone[y].description),
       p.contact = trim(request->fac[f].bld[b].unit[u].phone[y].contact), p.call_instruction = trim(
        request->fac[f].bld[b].unit[u].phone[y].call_instruction), p.extension = trim(request->fac[f]
        .bld[b].unit[u].phone[y].extension),
       p.paging_code = trim(request->fac[f].bld[b].unit[u].phone[y].paging_code), p.updt_id = reqinfo
       ->updt_id, p.updt_cnt = 0,
       p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->updt_task, p.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       p.active_ind = 1, p.active_status_cd = active_cd, p.active_status_dt_tm = cnvtdatetime(curdate,
        curtime3),
       p.active_status_prsnl_id = 0, p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p
       .end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
       p.data_status_cd = auth_cd, p.data_status_dt_tm = cnvtdatetime(curdate,curtime3), p
       .data_status_prsnl_id = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Error writing phone for unit name: ",request->fac[f].bld[b].unit[u].
       short_description," phone type: ",request->fac[f].bld[b].unit[u].phone[y].phone_type_mean,".")
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE chg_unit_phone(b,u,y)
  IF ((request->fac[f].bld[b].unit[u].phone[y].phone_id > 0))
   UPDATE  FROM phone p
    SET p.phone_format_cd = request->fac[f].bld[b].unit[u].phone[y].phone_format_code_value, p
     .phone_num = request->fac[f].bld[b].unit[u].phone[y].phone_num, p.phone_num_key = cnvtupper(
      cnvtalphanum(request->fac[f].bld[b].unit[u].phone[y].phone_num)),
     p.phone_type_seq = request->fac[f].bld[b].unit[u].phone[y].sequence, p.description = request->
     fac[f].bld[b].unit[u].phone[y].description, p.contact = request->fac[f].bld[b].unit[u].phone[y].
     contact,
     p.call_instruction = request->fac[f].bld[b].unit[u].phone[y].call_instruction, p.paging_code =
     request->fac[f].bld[b].unit[u].phone[y].paging_code, p.extension = request->fac[f].bld[b].unit[u
     ].phone[y].extension,
     p.phone_type_cd = request->fac[f].bld[b].unit[u].phone[y].phone_type_code_value, p.updt_cnt = (p
     .updt_cnt+ 1), p.updt_id = reqinfo->updt_id,
     p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_dt_tm =
     cnvtdatetime(curdate,curtime3)
    WHERE (p.phone_id=request->fac[f].bld[b].unit[u].phone[y].phone_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Error updating phone for unit name: ",request->fac[f].bld[b].unit[u].
     short_description," phone type: ",request->fac[f].bld[b].unit[u].phone[y].phone_type_mean,".")
    GO TO exit_script
   ENDIF
  ELSE
   SET error_flag = "Y"
   SET error_msg = concat("Phone_ID required, error updating phone for unit name: ",request->fac[f].
    bld[b].unit[u].short_description," phone type: ",request->fac[f].bld[b].unit[u].phone_type_mean,
    ".")
   GO TO exit_script
  ENDIF
  RETURN(1.0)
 END ;Subroutine
 SUBROUTINE del_unit_phone(b,u,y)
  IF ((request->fac[f].bld[b].unit[u].phone[y].phone_id > 0))
   UPDATE  FROM phone p
    SET p.active_ind = 0, p.updt_cnt = (p.updt_cnt+ 1), p.updt_id = reqinfo->updt_id,
     p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_dt_tm =
     cnvtdatetime(curdate,curtime3)
    WHERE (p.phone_id=request->fac[f].bld[b].unit[u].phone[y].phone_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Error inactivating phone for unit name: ",request->fac[f].bld[b].unit[u].
     short_description," phone type: ",request->fac[f].bld[b].unit[u].phone[y].phone_type_mean,".")
    GO TO exit_script
   ENDIF
  ELSE
   SET error_flag = "Y"
   SET error_msg = concat("Phone_ID required, error inactivating phone for unit name: ",request->fac[
    f].bld[b].unit[u].short_description," phone type: ",request->fac[f].bld[b].unit[u].phone[y].
    phone_type_mean,".")
   GO TO exit_script
  ENDIF
  RETURN(1.0)
 END ;Subroutine
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  SET reply->error_msg = concat("  >>PROGRAM NAME: BED_ENS_LOCATIONS","  >>ERROR MSG: ",error_msg)
 ENDIF
 IF ((request->audit_mode_ind=1))
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
