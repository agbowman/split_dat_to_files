CREATE PROGRAM dcp_add_prsnl_loc_r:dba
 RECORD request(
   1 qual[*]
     2 prsnl_id = f8
     2 location_cd = f8
     2 inactive_ind = i2
     2 description = c200
     2 note = c255
     2 short_desc = c15
     2 cdf_meaning = c12
     2 reltn[*]
       3 parent_loc_cd = f8
       3 child_loc_cd = f8
       3 cdf_meaning2 = c12
 )
 RECORD reply(
   1 qual[1]
     2 location_cd = f8
     2 description = vc
     2 tag_value = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD tempx(
   1 qual[*]
     2 parent_loc_cd = f8
     2 child_loc_cd = f8
     2 cdf_meaning = c12
 )
 RECORD temp_request(
   1 qual[*]
     2 prsnl_id = f8
     2 location_cd = f8
     2 inactive_ind = i2
     2 description = c200
     2 note = c255
     2 short_desc = c15
     2 cdf_meaning = c12
     2 reltn[*]
       3 parent_loc_cd = f8
       3 child_loc_cd = f8
       3 cdf_meaning2 = c12
 )
 SET failed = "F"
 SET found = "F"
 SET reply->status_data.status = "F"
 SET number_of_requests = size(request->qual,5)
 SET desc = fillstring(50," ")
 SET note = fillstring(255," ")
 SET short_desc = fillstring(50," ")
 SET cdf_meaning = fillstring(12," ")
 SET new_code = 0.0
 SET row_active = 1
 SET row_location = 0
 SET stat = alterlist(temp_request->qual,1)
 FOR (num = 1 TO value(number_of_requests))
   SET stat = alterlist(temp_request->qual,num)
   SET temp_request->qual[num].prsnl_id = request->qual[num].prsnl_id
   SET temp_request->qual[num].location_cd = request->qual[num].location_cd
   SET temp_request->qual[num].inactive_ind = request->qual[num].inactive_ind
   SET temp_request->qual[num].description = request->qual[num].description
   SET temp_request->qual[num].note = request->qual[num].note
   SET temp_request->qual[num].short_desc = request->qual[num].short_desc
   SET temp_request->qual[num].cdf_meaning = request->qual[num].cdf_meaning
   SET number_of_reltns = size(request->qual[num].reltn,5)
   SET stat = alterlist(temp_request->qual[num].reltn,1)
   FOR (y = 1 TO number_of_reltns)
     SET stat = alterlist(temp_request->qual[num].reltn,y)
     SET temp_request->qual[num].reltn[y].parent_loc_cd = request->qual[num].reltn[y].parent_loc_cd
     SET temp_request->qual[num].reltn[y].child_loc_cd = request->qual[num].reltn[y].child_loc_cd
     SET temp_request->qual[num].reltn[y].cdf_meaning2 = trim(request->qual[num].reltn[y].
      cdf_meaning2)
   ENDFOR
 ENDFOR
 FOR (num = 1 TO value(number_of_requests))
   SET prsnl = temp_request->qual[num].prsnl_id
   SET loc = temp_request->qual[num].location_cd
   SET inact = temp_request->qual[num].inactive_ind
   SET desc = trim(temp_request->qual[num].description)
   SET note = trim(temp_request->qual[num].note)
   SET short_desc = trim(temp_request->qual[num].short_desc)
   SET cdf_meaning = trim(temp_request->qual[num].cdf_meaning)
   SET number_of_reltns = size(temp_request->qual[num].reltn,5)
   SET stat = alterlist(tempx->qual,1)
   FOR (y = 1 TO number_of_reltns)
     SET stat = alterlist(tempx->qual,y)
     SET tempx->qual[y].parent_loc_cd = temp_request->qual[num].reltn[y].parent_loc_cd
     SET tempx->qual[y].child_loc_cd = temp_request->qual[num].reltn[y].child_loc_cd
     SET tempx->qual[y].cdf_meaning = trim(temp_request->qual[num].reltn[y].cdf_meaning2)
   ENDFOR
   SELECT INTO "nl:"
    dplr.*
    FROM dcp_prsnl_loc_r dplr
    WHERE (dplr.person_id=temp_request->qual[num].prsnl_id)
     AND (dplr.location_cd=temp_request->qual[num].location_cd)
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET found = "T"
   ELSE
    SET found = "F"
   ENDIF
   IF ((temp_request->qual[num].location_cd > 0)
    AND found="F"
    AND (temp_request->qual[num].inactive_ind=0))
    CALL echo("insert")
    INSERT  FROM dcp_prsnl_loc_r dplr
     SET dplr.person_id = temp_request->qual[num].prsnl_id, dplr.location_cd = temp_request->qual[num
      ].location_cd, dplr.active_ind = 1,
      dplr.updt_id = reqinfo->updt_id, dplr.updt_task = reqinfo->updt_task, dplr.updt_cnt = 0,
      dplr.updt_applctx = reqinfo->updt_applctx, dplr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      dplr.note = temp_request->qual[num].note
     WHERE (dplr.person_id=temp_request->qual[num].prsnl_id)
     WITH nocounter, dontexist
    ;end insert
    IF (curqual=0)
     CALL echo("failed on insert")
     SET failed = "T"
     GO TO exit_script
    ELSE
     FREE SET request
     RECORD request(
       1 qual[number_of_reltns]
         2 parent_loc_cd = f8
         2 child_loc_cd = f8
         2 cdf_meaning = c12
         2 root_loc_cd = f8
         2 active_ind = i2
         2 beg_effective_dt_tm = dq8
         2 end_effective_dt_tm = dq8
         2 sequence = i4
     )
     FOR (vv = 1 TO number_of_reltns)
       IF ((tempx->qual[vv].parent_loc_cd=0.0))
        SET request->qual[vv].parent_loc_cd = new_code
       ELSE
        SET request->qual[vv].parent_loc_cd = tempx->qual[vv].parent_loc_cd
       ENDIF
       SET request->qual[vv].child_loc_cd = tempx->qual[vv].child_loc_cd
       SET request->qual[vv].cdf_meaning = tempx->qual[vv].cdf_meaning
       SET request->qual[vv].root_loc_cd = new_code
       SET request->qual[vv].active_ind = 1
       SET request->qual[vv].beg_effective_dt_tm = cnvtdatetime(curdate,curtime)
       SET request->qual[vv].end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00")
       SET request->qual[vv].sequence = 1
       CALL echo(request->qual[vv].parent_loc_cd)
     ENDFOR
     EXECUTE value("LOC_ADD_LOC_PARENT_CHILD_R")
     IF ((reply->status_data.status != "S"))
      CALL echo("failed on parent-child after insert")
      SET failed = "T"
      GO TO exit_script
     ENDIF
    ENDIF
   ELSEIF ((temp_request->qual[num].location_cd > 0)
    AND found="T"
    AND (temp_request->qual[num].inactive_ind=1))
    DELETE  FROM location_group lg
     SET lg.seq = 1
     WHERE (lg.root_loc_cd=temp_request->qual[num].location_cd)
     WITH counter
    ;end delete
    IF (curqual=0)
     CALL echo("failed on delete from location group")
     SET failed = "T"
     GO TO exit_script
    ELSE
     DELETE  FROM dcp_prsnl_loc_r dplr
      WHERE (dplr.person_id=temp_request->qual[num].prsnl_id)
       AND (dplr.location_cd=temp_request->qual[num].location_cd)
      WITH nocounter
     ;end delete
     IF (curqual=0)
      CALL echo("failed on delete from dplr")
      SET failed = "T"
      GO TO exit_script
     ENDIF
    ENDIF
   ELSEIF ((temp_request->qual[num].location_cd > 0)
    AND found="T"
    AND (temp_request->qual[num].inactive_ind=0))
    UPDATE  FROM dcp_prsnl_loc_r dplr,
      (dummyt d  WITH seq = 1)
     SET dplr.active_ind = 1, dplr.updt_id = reqinfo->updt_id, dplr.updt_task = reqinfo->updt_task,
      dplr.updt_cnt = (dplr.updt_cnt+ 1), dplr.updt_applctx = reqinfo->updt_applctx, dplr.updt_dt_tm
       = cnvtdatetime(curdate,curtime3),
      dplr.note = temp_request->qual[num].note
     PLAN (d)
      JOIN (dplr
      WHERE (dplr.person_id=temp_request->qual[num].prsnl_id)
       AND (dplr.location_cd=temp_request->qual[num].location_cd))
     WITH nocounter
    ;end update
    IF (curqual=0)
     CALL echo("failed on update")
     SET failed = "T"
     GO TO exit_script
    ENDIF
    SET new_code = request->qual[num].location_cd
    DELETE  FROM location_group lg
     WHERE (lg.root_loc_cd=temp_request->qual[num].location_cd)
     WITH nocounter
    ;end delete
    IF (curqual=0)
     CALL echo("failed on update - delete from location group")
     SET failed = "T"
     GO TO exit_script
    ENDIF
    FREE SET request
    RECORD request(
      1 qual[number_of_reltns]
        2 parent_loc_cd = f8
        2 child_loc_cd = f8
        2 cdf_meaning = c12
        2 root_loc_cd = f8
        2 active_ind = i2
        2 beg_effective_dt_tm = dq8
        2 end_effective_dt_tm = dq8
        2 sequence = i4
    )
    FOR (vv = 1 TO number_of_reltns)
      SET request->qual[vv].parent_loc_cd = tempx->qual[vv].parent_loc_cd
      SET request->qual[vv].child_loc_cd = tempx->qual[vv].child_loc_cd
      SET request->qual[vv].cdf_meaning = tempx->qual[vv].cdf_meaning
      SET request->qual[vv].root_loc_cd = new_code
      SET request->qual[vv].active_ind = 1
      SET request->qual[vv].beg_effective_dt_tm = cnvtdatetime(curdate,curtime)
      SET request->qual[vv].end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00")
      SET request->qual[vv].sequence = 1
    ENDFOR
    EXECUTE value("LOC_ADD_LOC_PARENT_CHILD_R")
    IF ((reply->status_data.status != "S"))
     CALL echo("failed on parent-child after update")
     SET failed = "T"
     GO TO exit_script
    ENDIF
   ELSEIF ((temp_request->qual[num].location_cd=0))
    FREE SET request
    RECORD request(
      1 qual[1]
        2 resource_ind = i2
        2 active_ind = i2
        2 census_ind = i2
        2 organization_id = f8
        2 beg_effective_dt_tm = dq8
        2 end_effective_dt_tm = dq8
        2 description = c200
        2 note = c255
        2 short_desc = c15
        2 cdf_meaning = c12
        2 patcare_node_ind = i2
        2 discipline_type_cd = f8
        2 definition = c100
        2 collation_seq = i4
        2 transmit_outbound_order_ind = i2
        2 tray_type_cd = f8
        2 rack_type_cd = f8
        2 med_service_cd = f8
        2 atd_req_loc = i4
        2 cart_qty_ind = i2
        2 dispense_window = i4
        2 class_cd = f8
        2 fixed_bed_ind = i2
        2 number_fixed_beds = i4
        2 isolation_cd = f8
        2 loc_building_cd = f8
        2 loc_facility_cd = f8
        2 loc_nurse_unit_cd = f8
        2 tag_value = i4
        2 contributor_source_cd = f8
        2 ref_lab_acct_nbr = vc
    )
    SET request->qual[1].description = desc
    SET request->qual[1].note = note
    SET request->qual[1].short_desc = short_desc
    SET request->qual[1].cdf_meaning = cdf_meaning
    SET request->qual[1].active_ind = 1
    SET request->qual[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime)
    SET request->qual[1].end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00")
    EXECUTE value("LOC_ADD_LOCATION")
    CALL echo(build("root back from loc add loc :",reply->qual[1].location_cd))
    SET new_code = reply->qual[1].location_cd
    FREE SET request
    RECORD request(
      1 qual[number_of_reltns]
        2 parent_loc_cd = f8
        2 child_loc_cd = f8
        2 cdf_meaning = c12
        2 root_loc_cd = f8
        2 active_ind = i2
        2 beg_effective_dt_tm = dq8
        2 end_effective_dt_tm = dq8
        2 sequence = i4
    )
    CALL echo(build("new code :",new_code))
    FOR (vv = 1 TO number_of_reltns)
      IF ((tempx->qual[vv].parent_loc_cd=0.0))
       SET request->qual[vv].parent_loc_cd = new_code
      ELSE
       SET request->qual[vv].parent_loc_cd = tempx->qual[vv].parent_loc_cd
      ENDIF
      SET request->qual[vv].child_loc_cd = tempx->qual[vv].child_loc_cd
      SET request->qual[vv].cdf_meaning = tempx->qual[vv].cdf_meaning
      SET request->qual[vv].root_loc_cd = new_code
      SET request->qual[vv].active_ind = 1
      SET request->qual[vv].beg_effective_dt_tm = cnvtdatetime(curdate,curtime)
      SET request->qual[vv].end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00")
      SET request->qual[vv].sequence = 1
    ENDFOR
    EXECUTE value("LOC_ADD_LOC_PARENT_CHILD_R")
    CALL echo(build("!!",reply->status_data.status))
    IF ((reply->status_data.status="S"))
     IF (found="F")
      INSERT  FROM dcp_prsnl_loc_r dplr
       SET dplr.person_id = prsnl, dplr.location_cd = new_code, dplr.active_ind = 1,
        dplr.updt_id = reqinfo->updt_id, dplr.updt_task = reqinfo->updt_task, dplr.updt_cnt = 0,
        dplr.updt_applctx = reqinfo->updt_applctx, dplr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        dplr.note = temp_request->qual[num].note
       WHERE dplr.person_id=prsnl
        AND dplr.location_cd=new_code
       WITH nocounter, dontexist
      ;end insert
      IF (curqual=0)
       CALL echo("failed on insert into dplr")
       SET failed = "T"
       GO TO exit_script
      ENDIF
     ENDIF
    ELSE
     CALL echo("failed on parent-child after new root")
     SET failed = "T"
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  COMMIT
  CALL echo("commit")
 ELSE
  SET reply->status_data.status = "Z"
  ROLLBACK
  CALL echo("rollback")
 ENDIF
 CALL echo(reply->status_data.status)
END GO
