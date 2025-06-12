CREATE PROGRAM dcp_upd_shift_assign:dba
 RECORD reply(
   1 shift_assignment[*]
     2 assign_list[*]
       3 assignment_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE max_end_date = dq8 WITH protect, noconstant(cnvtdatetime("31-DEC-2100,23:59:59"))
 DECLARE effective_end_dt_tm = dq8 WITH protect
 DELETE  FROM dcp_shift_assignment dsa
  WHERE dsa.prsnl_id=0
   AND dsa.careteam_id=0
   AND dsa.loc_facility_cd=0
   AND dsa.loc_building_cd=0
   AND dsa.loc_unit_cd=0
   AND dsa.loc_room_cd=0
   AND dsa.loc_bed_cd=0
   AND dsa.person_id=0
   AND dsa.encntr_id=0
   AND dsa.beg_effective_dt_tm < cnvtdatetime(request->shift_assignment[1].end_effective_dt_tm)
   AND dsa.end_effective_dt_tm > cnvtdatetime(request->shift_assignment[1].beg_effective_dt_tm)
   AND dsa.active_ind=1
  WITH nocounter
 ;end delete
 SET assign_cnt = size(request->shift_assignment,5)
 SET stat = alterlist(reply->shift_assignment,assign_cnt)
 SET assignment_id = 0
 SET loc_cnt = 0
 SET reply->status_data.status = "Z"
 FOR (i = 1 TO assign_cnt)
   SET loc_cnt = size(request->shift_assignment[i].qual,5)
   SET updt_cnt = 0
   FOR (k = 1 TO loc_cnt)
     IF ((request->shift_assignment[i].qual[k].assignment_id > 0))
      SET updt_cnt += 1
     ENDIF
   ENDFOR
   SET stat = alterlist(reply->shift_assignment[i].assign_list,loc_cnt)
   UPDATE  FROM dcp_shift_assignment dsa,
     (dummyt d  WITH seq = value(loc_cnt))
    SET dsa.end_effective_dt_tm = cnvtdatetime(sysdate), dsa.active_ind = 0, dsa.updt_dt_tm =
     cnvtdatetime(sysdate),
     dsa.updt_id = reqinfo->updt_id, dsa.updt_applctx = reqinfo->updt_applctx, dsa.updt_task =
     reqinfo->updt_task,
     dsa.updt_cnt = (dsa.updt_cnt+ 1)
    PLAN (d)
     JOIN (dsa
     WHERE (dsa.assignment_id=request->shift_assignment[i].qual[d.seq].assignment_id)
      AND dsa.active_ind=1)
    WITH nocounter, outerjoin = d
   ;end update
   IF (curqual=updt_cnt)
    SET reply->status_data.status = "S"
   ENDIF
   IF ((request->shift_assignment[i].end_effective_dt_tm > max_end_date))
    SET effective_end_dt_tm = max_end_date
   ELSE
    SET effective_end_dt_tm = cnvtdatetime(request->shift_assignment[i].end_effective_dt_tm)
   ENDIF
   FOR (j = 1 TO loc_cnt)
     IF ((validate(request->shift_assignment[i].qual[j].pre_generated_id,- (999.0)) != - (999.0)))
      IF ((request->shift_assignment[i].qual[j].assignment_id=0)
       AND (request->shift_assignment[i].qual[j].pre_generated_id=0))
       SELECT INTO "nl:"
        w = seq(dcp_assignment_seq,nextval)
        FROM dual
        DETAIL
         reply->shift_assignment[i].assign_list[j].assignment_id = cnvtreal(w)
        WITH nocounter
       ;end select
       IF ((request->shift_assignment[i].qual[j].person_id != 0))
        SELECT INTO "nl:"
         e.encntr_id
         FROM encntr_domain e
         WHERE (e.encntr_id=request->shift_assignment[i].qual[j].encntr_id)
          AND (e.person_id=request->shift_assignment[i].qual[j].person_id)
          AND e.active_ind=1
         DETAIL
          CALL echo(build("facility_cd:",e.loc_facility_cd)), request->shift_assignment[i].qual[j].
          loc_facility_cd = e.loc_facility_cd, request->shift_assignment[i].qual[j].loc_building_cd
           = e.loc_building_cd,
          request->shift_assignment[i].qual[j].loc_unit_cd = e.loc_nurse_unit_cd
         WITH nocounter
        ;end select
       ENDIF
       INSERT  FROM dcp_shift_assignment dsa
        SET dsa.assignment_id = reply->shift_assignment[i].assign_list[j].assignment_id, dsa
         .careteam_id = request->shift_assignment[i].careteam_id, dsa.prsnl_id = request->
         shift_assignment[i].prsnl_id,
         dsa.assignment_group_cd = request->shift_assignment[i].assignment_group_cd, dsa
         .loc_facility_cd = request->shift_assignment[i].qual[j].loc_facility_cd, dsa.loc_building_cd
          = request->shift_assignment[i].qual[j].loc_building_cd,
         dsa.loc_unit_cd = request->shift_assignment[i].qual[j].loc_unit_cd, dsa.loc_room_cd =
         request->shift_assignment[i].qual[j].loc_room_cd, dsa.loc_bed_cd = request->
         shift_assignment[i].qual[j].loc_bed_cd,
         dsa.person_id = request->shift_assignment[i].qual[j].person_id, dsa.encntr_id = request->
         shift_assignment[i].qual[j].encntr_id, dsa.assignment_pos_cd = request->shift_assignment[i].
         position_cd,
         dsa.assign_type_cd = request->shift_assignment[i].assign_type_cd, dsa.beg_effective_dt_tm =
         cnvtdatetime(request->shift_assignment[i].beg_effective_dt_tm), dsa.end_effective_dt_tm =
         cnvtdatetime(effective_end_dt_tm),
         dsa.updt_id = reqinfo->updt_id, dsa.updt_cnt = 0, dsa.updt_applctx = reqinfo->updt_applctx,
         dsa.updt_task = reqinfo->updt_task, dsa.updt_dt_tm = cnvtdatetime(sysdate), dsa.active_ind
          = 1,
         dsa.purge_ind = 0
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET reply->status_data.subeventstatus[1].operationname = "insert"
        SET reply->status_data.subeventstatus[1].operationstatus = "s"
        SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_shift_assignment"
        SET reply->status_data.status = "Z"
        SET i = assign_cnt
        SET j = loc_cnt
       ELSE
        SET reply->status_data.status = "S"
       ENDIF
      ELSEIF ((request->shift_assignment[i].qual[j].pre_generated_id > 0))
       SET reply->shift_assignment[i].assign_list[j].assignment_id = request->shift_assignment[i].
       qual[j].pre_generated_id
       INSERT  FROM dcp_shift_assignment dsa
        SET dsa.assignment_id = reply->shift_assignment[i].assign_list[j].assignment_id, dsa
         .careteam_id = request->shift_assignment[i].careteam_id, dsa.prsnl_id = request->
         shift_assignment[i].prsnl_id,
         dsa.assignment_group_cd = request->shift_assignment[i].assignment_group_cd, dsa
         .loc_facility_cd = request->shift_assignment[i].qual[j].loc_facility_cd, dsa.loc_building_cd
          = request->shift_assignment[i].qual[j].loc_building_cd,
         dsa.loc_unit_cd = request->shift_assignment[i].qual[j].loc_unit_cd, dsa.loc_room_cd =
         request->shift_assignment[i].qual[j].loc_room_cd, dsa.loc_bed_cd = request->
         shift_assignment[i].qual[j].loc_bed_cd,
         dsa.person_id = request->shift_assignment[i].qual[j].person_id, dsa.encntr_id = request->
         shift_assignment[i].qual[j].encntr_id, dsa.assignment_pos_cd = request->shift_assignment[i].
         position_cd,
         dsa.assign_type_cd = request->shift_assignment[i].assign_type_cd, dsa.beg_effective_dt_tm =
         cnvtdatetime(request->shift_assignment[i].beg_effective_dt_tm), dsa.end_effective_dt_tm =
         cnvtdatetime(effective_end_dt_tm),
         dsa.updt_id = reqinfo->updt_id, dsa.updt_cnt = 0, dsa.updt_applctx = reqinfo->updt_applctx,
         dsa.updt_task = reqinfo->updt_task, dsa.updt_dt_tm = cnvtdatetime(sysdate), dsa.active_ind
          = 1,
         dsa.purge_ind = 0
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET reply->status_data.subeventstatus[1].operationname = "insert"
        SET reply->status_data.subeventstatus[1].operationstatus = "s"
        SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_shift_assignment"
        SET reply->status_data.status = "Z"
        SET i = assign_cnt
        SET j = loc_cnt
       ELSE
        SET reply->status_data.status = "S"
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
 ENDFOR
 IF ((reply->status_data.status="Z"))
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
