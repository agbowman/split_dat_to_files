CREATE PROGRAM dcp_get_careteam_prsnls:dba
 SET modify = predeclare
 RECORD reply(
   1 default_ind = i2
   1 careteam_list[*]
     2 careteam_id = f8
     2 careteam_name = vc
     2 qual[*]
       3 assignment_id = f8
       3 loc_bed_cd = f8
       3 loc_room_cd = f8
       3 loc_unit_cd = f8
       3 loc_building_cd = f8
       3 loc_facility_cd = f8
       3 person_id = f8
       3 name_full_formatted = vc
       3 encntr_id = f8
       3 beg_dt_tm = dq8
       3 end_dt_tm = dq8
       3 carry_forward_ind = i2
     2 prsnl_list[*]
       3 prsnl_id = f8
       3 position_cd = f8
       3 name_full_formatted = vc
   1 prsnl_list[*]
     2 prsnl_id = f8
     2 position_cd = f8
     2 name_full_formatted = vc
     2 qual[*]
       3 assignment_id = f8
       3 loc_bed_cd = f8
       3 loc_room_cd = f8
       3 loc_unit_cd = f8
       3 loc_building_cd = f8
       3 loc_facility_cd = f8
       3 person_id = f8
       3 name_full_formatted = vc
       3 encntr_id = f8
       3 beg_dt_tm = dq8
       3 end_dt_tm = dq8
       3 carry_forward_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD locations
 RECORD locations(
   1 qual[*]
     2 location_cd = f8
 )
 SUBROUTINE (reportfailure(opname=vc,opstatus=vc,targetname=vc,targetvalue=vc) =null)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus(opname,opstatus,targetname,targetvalue)
 END ;Subroutine
 SUBROUTINE (fillsubeventstatus(opname=vc,opstatus=vc,objname=vc,objvalue=vc) =null)
   DECLARE dcp_substatus_cnt = i4 WITH protect, noconstant(size(reply->status_data.subeventstatus,5))
   SET dcp_substatus_cnt += 1
   IF (dcp_substatus_cnt != 1)
    SET stat = alter(reply->status_data.subeventstatus,dcp_substatus_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectname = trim(objname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectvalue = trim(objvalue)
 END ;Subroutine
 DECLARE prsnl_cnt = i4 WITH protect, noconstant(0)
 DECLARE care_cnt = i4 WITH protect, noconstant(0)
 DECLARE loc_cnt = i4 WITH protect, noconstant(0)
 DECLARE position_cd = f8 WITH protect, noconstant(0.0)
 DECLARE iter_cnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE location_cd = f8 WITH protect, noconstant(0.0)
 DECLARE childcnt_temp = i4 WITH protect, noconstant(0)
 DECLARE childcnt = i4 WITH protect, noconstant(0)
 DECLARE non_nurse_unit_exists = i4 WITH protect, noconstant(0)
 DECLARE size_list = i4 WITH protect, noconstant(0)
 DECLARE iptr = i4 WITH protect, noconstant(0)
 DECLARE error_code = i2 WITH protect, noconstant(false)
 DECLARE debug_ind = i2 WITH protect, noconstant(0)
 DECLARE fail_ind = i2 WITH protect, noconstant(false)
 DECLARE zero_ind = i2 WITH protect, noconstant(false)
 DECLARE icnt = i4 WITH protect, noconstant(0)
 DECLARE jcnt = i4 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE shift_assign_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"SHFTASGNROOT"))
 DECLARE nurse_unit_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"NURSEUNIT"))
 DECLARE ambulatory_unit_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"AMBULATORY"))
 DECLARE active_status_cd = f8 WITH protect, constant(reqdata->active_status_cd)
 DECLARE look_for_cf = i2 WITH protect, noconstant(1)
 DECLARE max_end_date = dq8 WITH protect, noconstant(cnvtdatetime("31-DEC-2100,23:59:59"))
 IF ((request->beg_dt_tm=null))
  SET request->beg_dt_tm = cnvtdatetime(sysdate)
 ENDIF
 DECLARE req_beg_dt_tm = dq8 WITH public, noconstant(request->beg_dt_tm)
 DECLARE req_end_dt_tm = dq8 WITH public, noconstant(request->end_dt_tm)
 DECLARE cf_beg_dt_tm = dq8 WITH public, noconstant(datetimeadd(request->beg_dt_tm,- (1)))
 DECLARE cf_end_dt_tm = dq8 WITH public, noconstant(datetimeadd(request->end_dt_tm,- (1)))
 DECLARE getlocation(null) = null
 DECLARE getcareteamassignment(null) = null
 DECLARE getprsnlassignment(null) = null
 DECLARE getcarryforwardcareteamassignments(null) = null
 DECLARE getcarryforwardprsnlassignments(null) = null
 SET reply->status_data.status = "F"
 SET reply->default_ind = 0
 IF (validate(request->debug_ind)=1)
  IF ((request->debug_ind=1))
   SET debug_ind = 1
  ENDIF
 ENDIF
 IF (shift_assign_cd=0.0)
  SET fail_ind = true
  CALL fillsubeventstatus("dcp_get_careteam_prsnls","F","UAR_GET_CODE_BY_MEANING",
   "shift_assign_cd = 0")
  GO TO exit_script
 ENDIF
 IF (nurse_unit_cd=0.0)
  SET fail_ind = true
  CALL fillsubeventstatus("dcp_get_careteam_prsnls","F","UAR_GET_CODE_BY_MEANING","nurse_unit_cd = 0"
   )
  GO TO exit_script
 ENDIF
 IF (ambulatory_unit_cd=0.0)
  SET fail_ind = true
  CALL fillsubeventstatus("dcp_get_careteam_prsnls","F","UAR_GET_CODE_BY_MEANING",
   "ambulatory_unit_cd = 0")
  GO TO exit_script
 ENDIF
 IF (active_status_cd=0.0)
  SET fail_ind = true
  CALL fillsubeventstatus("dcp_get_careteam_prsnls","F","UAR_GET_CODE_BY_MEANING",
   "active_status_cd = 0")
  GO TO exit_script
 ENDIF
 IF ((request->use_loc_hier_for_assign=1))
  CALL getlocation(null)
  CALL getcareteamassignment(null)
  CALL getprsnlassignment(null)
  IF ((request->nocarryforward=0)
   AND look_for_cf=1)
   CALL getcarryforwardcareteamassignments(null)
   CALL getcarryforwardprsnlassignments(null)
  ENDIF
 ELSE
  CALL getlocation(null)
  CALL getcareteamassignment(null)
  CALL getprsnlassignment(null)
 ENDIF
 IF (((care_cnt != 0) OR (prsnl_cnt != 0)) )
  GO TO exit_script
 ELSE
  SELECT
   IF ((request->assign_type_cd > 0))INTO "nl:"
    FROM dcp_shift_assignment dsa
    WHERE dsa.beg_effective_dt_tm < cnvtdatetime(request->end_dt_tm)
     AND dsa.end_effective_dt_tm > cnvtdatetime(request->beg_dt_tm)
     AND dsa.active_ind=1
     AND (dsa.assignment_group_cd=request->location_cd)
     AND (dsa.assign_type_cd=request->assign_type_cd)
     AND dsa.prsnl_id=0
     AND dsa.careteam_id=0
   ELSE
    FROM dcp_shift_assignment dsa
    WHERE dsa.beg_effective_dt_tm < cnvtdatetime(request->end_dt_tm)
     AND dsa.end_effective_dt_tm > cnvtdatetime(request->beg_dt_tm)
     AND dsa.active_ind=1
     AND (dsa.assignment_group_cd=request->location_cd)
     AND (dsa.assignment_pos_cd=request->position_cd)
     AND dsa.prsnl_id=0
     AND dsa.careteam_id=0
   ENDIF
   WITH nocounter
  ;end select
  IF (curqual != 0)
   SET zero_ind = true
   CALL echo("going to get the blank row")
   GO TO exit_script
  ELSEIF ((request->use_loc_hier_for_assign=0))
   SET req_beg_dt_tm = cf_beg_dt_tm
   SET req_end_dt_tm = cf_end_dt_tm
   SET reply->default_ind = 1
   CALL getcareteamassignment(null)
   CALL getprsnlassignment(null)
   IF (care_cnt=0
    AND prsnl_cnt=0)
    SET zero_ind = true
   ENDIF
  ELSE
   SET zero_ind = true
  ENDIF
 ENDIF
 SUBROUTINE getlocation(null)
   IF ((request->is_custom_location=1))
    FREE RECORD locations_temp
    RECORD locations_temp(
      1 qual[*]
        2 location_cd = f8
        2 location_type_cd = f8
        2 isscanned = i2
    )
    SET non_nurse_unit_exists = 1
    SELECT INTO "nl:"
     FROM location_group lg,
      location l
     WHERE (lg.parent_loc_cd=request->location_cd)
      AND lg.location_group_type_cd=shift_assign_cd
      AND lg.active_ind=1
      AND lg.active_status_cd=active_status_cd
      AND lg.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND lg.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND lg.child_loc_cd=l.location_cd
     DETAIL
      IF (lg.child_loc_cd != 0)
       childcnt_temp += 1
       IF (mod(childcnt_temp,10)=1)
        stat = alterlist(locations_temp->qual,(childcnt_temp+ 9))
       ENDIF
       locations_temp->qual[childcnt_temp].location_cd = lg.child_loc_cd, locations_temp->qual[
       childcnt_temp].location_type_cd = l.location_type_cd
      ENDIF
     FOOT REPORT
      stat = alterlist(locations_temp->qual,childcnt_temp)
     WITH nocounter
    ;end select
    WHILE (non_nurse_unit_exists=1)
      SET non_nurse_unit_exists = 0
      FOR (icnt = 1 TO size(locations_temp->qual,5))
        IF ((locations_temp->qual[icnt].isscanned=0))
         IF ((locations_temp->qual[icnt].location_type_cd IN (nurse_unit_cd, ambulatory_unit_cd)))
          IF (((mod(childcnt,10)=1) OR (mod((childcnt+ 1),10)=1)) )
           SET stat = alterlist(locations->qual,(childcnt+ 9))
          ENDIF
          SET childcnt += 1
          SET locations->qual[childcnt].location_cd = locations_temp->qual[icnt].location_cd
          SET locations_temp->qual[icnt].isscanned = 1
         ELSE
          SET non_nurse_unit_exists = 1
          SET locations_temp->qual[icnt].isscanned = 1
         ENDIF
        ENDIF
      ENDFOR
      IF (non_nurse_unit_exists=1)
       SELECT DISTINCT
        lg.child_loc_cd
        FROM location_group lg,
         location l
        WHERE expand(iptr,1,size(locations_temp->qual,5),lg.parent_loc_cd,locations_temp->qual[iptr].
         location_cd)
         AND lg.active_ind=1
         AND lg.active_status_cd=active_status_cd
         AND lg.beg_effective_dt_tm <= cnvtdatetime(sysdate)
         AND lg.end_effective_dt_tm > cnvtdatetime(sysdate)
         AND (lg.root_loc_cd=request->location_cd)
         AND lg.child_loc_cd=l.location_cd
        HEAD REPORT
         size_list = size(locations_temp->qual,5), stat = alterlist(locations_temp->qual,(((size_list
          / 10)+ 1) * 10))
        DETAIL
         IF (lg.child_loc_cd != 0)
          childcnt_temp += 1
          IF (mod(childcnt_temp,10)=1)
           stat = alterlist(locations_temp->qual,(childcnt_temp+ 9))
          ENDIF
          locations_temp->qual[childcnt_temp].location_cd = lg.child_loc_cd, locations_temp->qual[
          childcnt_temp].location_type_cd = l.location_type_cd
         ENDIF
        FOOT REPORT
         stat = alterlist(locations_temp->qual,childcnt_temp)
        WITH nocounter
       ;end select
       FOR (icnt = 1 TO size(locations_temp->qual,5))
         IF ((locations_temp->qual[icnt].isscanned=1))
          SET locations_temp->qual[icnt].location_cd = - (1)
         ENDIF
       ENDFOR
      ENDIF
    ENDWHILE
    SET stat = alterlist(locations->qual,childcnt)
   ELSE
    SET stat = alterlist(locations->qual,1)
    SET locations->qual[1].location_cd = request->location_cd
   ENDIF
 END ;Subroutine
 SUBROUTINE getcareteamassignment(null)
  SELECT
   IF ((request->assign_type_cd > 0)
    AND (request->use_loc_hier_for_assign=1))
    FROM dcp_shift_assignment dsa,
     (dummyt d1  WITH seq = 1),
     dcp_care_team dct,
     (dummyt d2  WITH seq = 1),
     dcp_care_team_prsnl dctp,
     prsnl p,
     (dummyt d4  WITH seq = 1),
     encounter e,
     person ps
    PLAN (dsa
     WHERE ((expand(iptr,1,size(locations->qual,5),dsa.loc_facility_cd,locations->qual[iptr].
      location_cd)) OR (((expand(iptr,1,size(locations->qual,5),dsa.loc_building_cd,locations->qual[
      iptr].location_cd)) OR (expand(iptr,1,size(locations->qual,5),dsa.loc_unit_cd,locations->qual[
      iptr].location_cd))) ))
      AND (dsa.assign_type_cd=request->assign_type_cd)
      AND dsa.beg_effective_dt_tm < cnvtdatetime(req_end_dt_tm)
      AND dsa.end_effective_dt_tm > cnvtdatetime(req_beg_dt_tm)
      AND dsa.active_ind=1
      AND ((dsa.careteam_id+ 0) != 0))
     JOIN (d1)
     JOIN (dct
     WHERE dct.careteam_id=dsa.careteam_id
      AND dct.beg_effective_dt_tm < cnvtdatetime(req_end_dt_tm)
      AND dct.end_effective_dt_tm > cnvtdatetime(req_beg_dt_tm)
      AND dct.active_ind=1
      AND dct.careteam_id != 0)
     JOIN (d2)
     JOIN (dctp
     WHERE dctp.careteam_id=dct.careteam_id
      AND dctp.active_ind=1)
     JOIN (p
     WHERE p.person_id=dctp.prsnl_id
      AND p.active_ind=1)
     JOIN (d4)
     JOIN (e
     WHERE e.person_id=dsa.person_id
      AND e.encntr_id=dsa.encntr_id
      AND e.loc_nurse_unit_cd=dsa.loc_unit_cd)
     JOIN (ps
     WHERE ps.person_id=e.person_id
      AND ps.active_ind=1)
   ELSEIF ((request->assign_type_cd > 0)
    AND (request->use_loc_hier_for_assign=0))
    FROM dcp_shift_assignment dsa,
     (dummyt d1  WITH seq = 1),
     dcp_care_team dct,
     (dummyt d2  WITH seq = 1),
     dcp_care_team_prsnl dctp,
     prsnl p,
     (dummyt d4  WITH seq = 1),
     encounter e,
     person ps
    PLAN (dsa
     WHERE (dsa.assignment_group_cd=request->location_cd)
      AND (dsa.assign_type_cd=request->assign_type_cd)
      AND dsa.beg_effective_dt_tm < cnvtdatetime(req_end_dt_tm)
      AND dsa.end_effective_dt_tm > cnvtdatetime(req_beg_dt_tm)
      AND dsa.active_ind=1
      AND ((dsa.careteam_id+ 0) != 0))
     JOIN (d1)
     JOIN (dct
     WHERE dct.careteam_id=dsa.careteam_id
      AND dct.beg_effective_dt_tm < cnvtdatetime(req_end_dt_tm)
      AND dct.end_effective_dt_tm > cnvtdatetime(req_beg_dt_tm)
      AND dct.active_ind=1
      AND dct.careteam_id != 0)
     JOIN (d2)
     JOIN (dctp
     WHERE dctp.careteam_id=dct.careteam_id
      AND dctp.active_ind=1)
     JOIN (p
     WHERE p.person_id=dctp.prsnl_id
      AND p.active_ind=1)
     JOIN (d4)
     JOIN (e
     WHERE e.person_id=dsa.person_id
      AND e.encntr_id=dsa.encntr_id
      AND e.loc_nurse_unit_cd=dsa.loc_unit_cd)
     JOIN (ps
     WHERE ps.person_id=e.person_id
      AND ps.active_ind=1)
   ELSEIF ((request->use_loc_hier_for_assign=1))
    FROM dcp_shift_assignment dsa,
     (dummyt d1  WITH seq = 1),
     dcp_care_team dct,
     (dummyt d2  WITH seq = 1),
     dcp_care_team_prsnl dctp,
     prsnl p,
     (dummyt d4  WITH seq = 1),
     encounter e,
     person ps
    PLAN (dsa
     WHERE ((expand(iptr,1,size(locations->qual,5),dsa.loc_facility_cd,locations->qual[iptr].
      location_cd)) OR (((expand(iptr,1,size(locations->qual,5),dsa.loc_building_cd,locations->qual[
      iptr].location_cd)) OR (expand(iptr,1,size(locations->qual,5),dsa.loc_unit_cd,locations->qual[
      iptr].location_cd))) ))
      AND (dsa.assignment_pos_cd=request->position_cd)
      AND dsa.beg_effective_dt_tm < cnvtdatetime(req_end_dt_tm)
      AND dsa.end_effective_dt_tm > cnvtdatetime(req_beg_dt_tm)
      AND dsa.active_ind=1
      AND ((dsa.careteam_id+ 0) != 0))
     JOIN (d1)
     JOIN (dct
     WHERE dct.careteam_id=dsa.careteam_id
      AND dct.beg_effective_dt_tm < cnvtdatetime(req_end_dt_tm)
      AND dct.end_effective_dt_tm > cnvtdatetime(req_beg_dt_tm)
      AND dct.active_ind=1
      AND dct.careteam_id != 0)
     JOIN (d2)
     JOIN (dctp
     WHERE dctp.careteam_id=dct.careteam_id
      AND dctp.active_ind=1)
     JOIN (p
     WHERE p.person_id=dctp.prsnl_id
      AND p.active_ind=1)
     JOIN (d4)
     JOIN (e
     WHERE e.person_id=dsa.person_id
      AND e.encntr_id=dsa.encntr_id
      AND e.loc_nurse_unit_cd=dsa.loc_unit_cd)
     JOIN (ps
     WHERE ps.person_id=e.person_id
      AND ps.active_ind=1)
   ELSE
    FROM dcp_shift_assignment dsa,
     (dummyt d1  WITH seq = 1),
     dcp_care_team dct,
     (dummyt d2  WITH seq = 1),
     dcp_care_team_prsnl dctp,
     prsnl p,
     (dummyt d4  WITH seq = 1),
     encounter e,
     person ps
    PLAN (dsa
     WHERE (dsa.assignment_group_cd=request->location_cd)
      AND (dsa.assignment_pos_cd=request->position_cd)
      AND dsa.beg_effective_dt_tm < cnvtdatetime(req_end_dt_tm)
      AND dsa.end_effective_dt_tm > cnvtdatetime(req_beg_dt_tm)
      AND dsa.active_ind=1
      AND ((dsa.careteam_id+ 0) != 0))
     JOIN (d1)
     JOIN (dct
     WHERE dct.careteam_id=dsa.careteam_id
      AND dct.beg_effective_dt_tm < cnvtdatetime(req_end_dt_tm)
      AND dct.end_effective_dt_tm > cnvtdatetime(req_beg_dt_tm)
      AND dct.active_ind=1
      AND dct.careteam_id != 0)
     JOIN (d2)
     JOIN (dctp
     WHERE dctp.careteam_id=dct.careteam_id
      AND dctp.active_ind=1)
     JOIN (p
     WHERE p.person_id=dctp.prsnl_id
      AND p.active_ind=1)
     JOIN (d4)
     JOIN (e
     WHERE e.person_id=dsa.person_id
      AND e.encntr_id=dsa.encntr_id
      AND e.loc_nurse_unit_cd=dsa.loc_unit_cd)
     JOIN (ps
     WHERE ps.person_id=e.person_id
      AND ps.active_ind=1)
   ENDIF
   INTO "nl:"
   dsa.assignment_id, dct.careteam_id, ps.person_id,
   p.person_id
   ORDER BY dct.careteam_id
   HEAD dct.careteam_id
    care_cnt += 1
    IF (care_cnt > size(reply->careteam_list,5))
     stat = alterlist(reply->careteam_list,(care_cnt+ 5))
    ENDIF
    reply->careteam_list[care_cnt].careteam_id = dct.careteam_id, reply->careteam_list[care_cnt].
    careteam_name = dct.name, loc_cnt = 0,
    prsnl_cnt = 0
   HEAD p.person_id
    IF (p.person_id != 0)
     prsnl_cnt += 1
     IF (prsnl_cnt > size(reply->careteam_list[care_cnt].prsnl_list,5))
      stat = alterlist(reply->careteam_list[care_cnt].prsnl_list,(prsnl_cnt+ 5))
     ENDIF
     reply->careteam_list[care_cnt].prsnl_list[prsnl_cnt].prsnl_id = p.person_id, reply->
     careteam_list[care_cnt].prsnl_list[prsnl_cnt].position_cd = p.position_cd, reply->careteam_list[
     care_cnt].prsnl_list[prsnl_cnt].name_full_formatted = p.name_full_formatted
    ENDIF
   DETAIL
    IF (((e.loc_nurse_unit_cd=dsa.loc_unit_cd) OR (((dsa.loc_room_cd > 0
     AND dsa.loc_bed_cd > 0
     AND dsa.person_id=0
     AND dsa.encntr_id=0) OR (((dsa.loc_room_cd > 0
     AND dsa.loc_bed_cd=0
     AND dsa.person_id=0
     AND dsa.encntr_id=0) OR (dsa.loc_room_cd=0
     AND dsa.loc_bed_cd=0
     AND dsa.person_id=0
     AND dsa.encntr_id=0)) )) )) )
     loc_cnt += 1
     IF (loc_cnt > size(reply->careteam_list[care_cnt].qual,5))
      stat = alterlist(reply->careteam_list[care_cnt].qual,(loc_cnt+ 5))
     ENDIF
     IF ((dsa.beg_effective_dt_tm >= request->beg_dt_tm)
      AND (dsa.end_effective_dt_tm <= request->end_dt_tm))
      look_for_cf = 0
     ENDIF
     reply->careteam_list[care_cnt].qual[loc_cnt].assignment_id = dsa.assignment_id, reply->
     careteam_list[care_cnt].qual[loc_cnt].loc_bed_cd = dsa.loc_bed_cd, reply->careteam_list[care_cnt
     ].qual[loc_cnt].loc_room_cd = dsa.loc_room_cd,
     reply->careteam_list[care_cnt].qual[loc_cnt].loc_unit_cd = dsa.loc_unit_cd, reply->
     careteam_list[care_cnt].qual[loc_cnt].loc_building_cd = dsa.loc_building_cd, reply->
     careteam_list[care_cnt].qual[loc_cnt].loc_facility_cd = dsa.loc_facility_cd,
     reply->careteam_list[care_cnt].qual[loc_cnt].person_id = ps.person_id, reply->careteam_list[
     care_cnt].qual[loc_cnt].encntr_id = e.encntr_id
     IF ((reply->default_ind=1)
      AND (request->use_loc_hier_for_assign=0))
      reply->careteam_list[care_cnt].qual[loc_cnt].beg_dt_tm = request->beg_dt_tm, reply->
      careteam_list[care_cnt].qual[loc_cnt].end_dt_tm = request->end_dt_tm
     ELSE
      reply->careteam_list[care_cnt].qual[loc_cnt].beg_dt_tm = dsa.beg_effective_dt_tm
      IF (dsa.end_effective_dt_tm > max_end_date)
       reply->careteam_list[care_cnt].qual[loc_cnt].end_dt_tm = max_end_date
      ELSE
       reply->careteam_list[care_cnt].qual[loc_cnt].end_dt_tm = dsa.end_effective_dt_tm
      ENDIF
     ENDIF
     reply->careteam_list[care_cnt].qual[loc_cnt].name_full_formatted = ps.name_full_formatted, reply
     ->careteam_list[care_cnt].qual[loc_cnt].carry_forward_ind = 0
    ENDIF
   FOOT  dct.careteam_id
    IF (loc_cnt > 0)
     stat = alterlist(reply->careteam_list[care_cnt].qual,loc_cnt)
    ENDIF
    stat = alterlist(reply->careteam_list[care_cnt].prsnl_list,prsnl_cnt)
   WITH nocounter, outerjoin = d1, outerjoin = d2,
    outerjoin = d4
  ;end select
  SET stat = alterlist(reply->careteam_list,care_cnt)
 END ;Subroutine
 SUBROUTINE getprsnlassignment(null)
   SET prsnl_cnt = 0
   SET loc_cnt = 0
   SELECT
    IF ((request->assign_type_cd > 0)
     AND (request->use_loc_hier_for_assign=1))
     FROM dcp_shift_assignment dsa,
      (dummyt d1  WITH seq = 1),
      prsnl p,
      (dummyt d4  WITH seq = 1),
      encounter e,
      person ps
     PLAN (dsa
      WHERE ((expand(iptr,1,size(locations->qual,5),dsa.loc_facility_cd,locations->qual[iptr].
       location_cd)) OR (((expand(iptr,1,size(locations->qual,5),dsa.loc_building_cd,locations->qual[
       iptr].location_cd)) OR (expand(iptr,1,size(locations->qual,5),dsa.loc_unit_cd,locations->qual[
       iptr].location_cd))) ))
       AND (dsa.assign_type_cd=request->assign_type_cd)
       AND dsa.beg_effective_dt_tm < cnvtdatetime(req_end_dt_tm)
       AND dsa.end_effective_dt_tm > cnvtdatetime(req_beg_dt_tm)
       AND dsa.active_ind=1
       AND dsa.prsnl_id != 0)
      JOIN (d1)
      JOIN (p
      WHERE p.person_id=dsa.prsnl_id
       AND p.active_ind=1
       AND p.person_id != 0)
      JOIN (d4)
      JOIN (e
      WHERE e.person_id=dsa.person_id
       AND e.encntr_id=dsa.encntr_id
       AND e.loc_nurse_unit_cd=dsa.loc_unit_cd)
      JOIN (ps
      WHERE ps.person_id=e.person_id
       AND ps.active_ind=1)
    ELSEIF ((request->assign_type_cd > 0)
     AND (request->use_loc_hier_for_assign=0))
     FROM dcp_shift_assignment dsa,
      (dummyt d1  WITH seq = 1),
      prsnl p,
      (dummyt d4  WITH seq = 1),
      encounter e,
      person ps
     PLAN (dsa
      WHERE (dsa.assignment_group_cd=request->location_cd)
       AND (dsa.assign_type_cd=request->assign_type_cd)
       AND dsa.beg_effective_dt_tm < cnvtdatetime(req_end_dt_tm)
       AND dsa.end_effective_dt_tm > cnvtdatetime(req_beg_dt_tm)
       AND dsa.active_ind=1
       AND dsa.prsnl_id != 0)
      JOIN (d1)
      JOIN (p
      WHERE p.person_id=dsa.prsnl_id
       AND p.active_ind=1
       AND p.person_id != 0)
      JOIN (d4)
      JOIN (e
      WHERE e.person_id=dsa.person_id
       AND e.encntr_id=dsa.encntr_id
       AND e.loc_nurse_unit_cd=dsa.loc_unit_cd)
      JOIN (ps
      WHERE ps.person_id=e.person_id
       AND ps.active_ind=1)
    ELSEIF ((request->use_loc_hier_for_assign=1))
     FROM dcp_shift_assignment dsa,
      (dummyt d1  WITH seq = 1),
      prsnl p,
      (dummyt d4  WITH seq = 1),
      encounter e,
      person ps
     PLAN (dsa
      WHERE ((expand(iptr,1,size(locations->qual,5),dsa.loc_facility_cd,locations->qual[iptr].
       location_cd)) OR (((expand(iptr,1,size(locations->qual,5),dsa.loc_building_cd,locations->qual[
       iptr].location_cd)) OR (expand(iptr,1,size(locations->qual,5),dsa.loc_unit_cd,locations->qual[
       iptr].location_cd))) ))
       AND (dsa.assignment_pos_cd=request->position_cd)
       AND dsa.beg_effective_dt_tm < cnvtdatetime(req_end_dt_tm)
       AND dsa.end_effective_dt_tm > cnvtdatetime(req_beg_dt_tm)
       AND dsa.active_ind=1
       AND dsa.prsnl_id != 0)
      JOIN (d1)
      JOIN (p
      WHERE p.person_id=dsa.prsnl_id
       AND p.active_ind=1
       AND p.person_id != 0)
      JOIN (d4)
      JOIN (e
      WHERE e.person_id=dsa.person_id
       AND e.encntr_id=dsa.encntr_id
       AND e.loc_nurse_unit_cd=dsa.loc_unit_cd)
      JOIN (ps
      WHERE ps.person_id=e.person_id
       AND ps.active_ind=1)
    ELSE
     FROM dcp_shift_assignment dsa,
      (dummyt d1  WITH seq = 1),
      prsnl p,
      (dummyt d4  WITH seq = 1),
      encounter e,
      person ps
     PLAN (dsa
      WHERE (dsa.assignment_group_cd=request->location_cd)
       AND (dsa.assignment_pos_cd=request->position_cd)
       AND dsa.beg_effective_dt_tm < cnvtdatetime(req_end_dt_tm)
       AND dsa.end_effective_dt_tm > cnvtdatetime(req_beg_dt_tm)
       AND dsa.active_ind=1
       AND dsa.prsnl_id != 0)
      JOIN (d1)
      JOIN (p
      WHERE p.person_id=dsa.prsnl_id
       AND p.active_ind=1
       AND p.person_id != 0)
      JOIN (d4)
      JOIN (e
      WHERE e.person_id=dsa.person_id
       AND e.encntr_id=dsa.encntr_id
       AND e.loc_nurse_unit_cd=dsa.loc_unit_cd)
      JOIN (ps
      WHERE ps.person_id=e.person_id
       AND ps.active_ind=1)
    ENDIF
    INTO "nl:"
    dsa.assignment_id, ps.person_id, p.person_id
    ORDER BY p.person_id
    HEAD p.person_id
     CALL echo(build("person_id:",p.person_id)), prsnl_cnt += 1
     IF (prsnl_cnt > size(reply->prsnl_list,5))
      stat = alterlist(reply->prsnl_list,(prsnl_cnt+ 5))
     ENDIF
     reply->prsnl_list[prsnl_cnt].prsnl_id = p.person_id, reply->prsnl_list[prsnl_cnt].position_cd =
     p.position_cd, reply->prsnl_list[prsnl_cnt].name_full_formatted = p.name_full_formatted,
     loc_cnt = 0
    DETAIL
     IF (((e.loc_nurse_unit_cd=dsa.loc_unit_cd) OR (((dsa.loc_room_cd > 0
      AND dsa.loc_bed_cd > 0
      AND dsa.person_id=0
      AND dsa.encntr_id=0) OR (((dsa.loc_room_cd > 0
      AND dsa.loc_bed_cd=0
      AND dsa.person_id=0
      AND dsa.encntr_id=0) OR (dsa.loc_room_cd=0
      AND dsa.loc_bed_cd=0
      AND dsa.person_id=0
      AND dsa.encntr_id=0)) )) )) )
      loc_cnt += 1
      IF (loc_cnt > size(reply->prsnl_list[prsnl_cnt].qual,5))
       stat = alterlist(reply->prsnl_list[prsnl_cnt].qual,(loc_cnt+ 5))
      ENDIF
      IF ((dsa.beg_effective_dt_tm >= request->beg_dt_tm)
       AND (dsa.end_effective_dt_tm <= request->end_dt_tm))
       look_for_cf = 0
      ENDIF
      reply->prsnl_list[prsnl_cnt].qual[loc_cnt].assignment_id = dsa.assignment_id, reply->
      prsnl_list[prsnl_cnt].qual[loc_cnt].loc_bed_cd = dsa.loc_bed_cd, reply->prsnl_list[prsnl_cnt].
      qual[loc_cnt].loc_room_cd = dsa.loc_room_cd,
      reply->prsnl_list[prsnl_cnt].qual[loc_cnt].loc_unit_cd = dsa.loc_unit_cd, reply->prsnl_list[
      prsnl_cnt].qual[loc_cnt].loc_building_cd = dsa.loc_building_cd, reply->prsnl_list[prsnl_cnt].
      qual[loc_cnt].loc_facility_cd = dsa.loc_facility_cd,
      reply->prsnl_list[prsnl_cnt].qual[loc_cnt].person_id = ps.person_id, reply->prsnl_list[
      prsnl_cnt].qual[loc_cnt].encntr_id = e.encntr_id
      IF ((reply->default_ind=1)
       AND (request->use_loc_hier_for_assign=0))
       reply->prsnl_list[prsnl_cnt].qual[loc_cnt].beg_dt_tm = request->beg_dt_tm, reply->prsnl_list[
       prsnl_cnt].qual[loc_cnt].end_dt_tm = request->end_dt_tm
      ELSE
       reply->prsnl_list[prsnl_cnt].qual[loc_cnt].beg_dt_tm = dsa.beg_effective_dt_tm
       IF (dsa.end_effective_dt_tm > max_end_date)
        reply->prsnl_list[prsnl_cnt].qual[loc_cnt].end_dt_tm = max_end_date
       ELSE
        reply->prsnl_list[prsnl_cnt].qual[loc_cnt].end_dt_tm = dsa.end_effective_dt_tm
       ENDIF
      ENDIF
      reply->prsnl_list[prsnl_cnt].qual[loc_cnt].name_full_formatted = ps.name_full_formatted, reply
      ->prsnl_list[prsnl_cnt].qual[loc_cnt].carry_forward_ind = 0
     ENDIF
    FOOT  p.person_id
     IF (loc_cnt > 0)
      stat = alterlist(reply->prsnl_list[prsnl_cnt].qual,loc_cnt)
     ENDIF
    WITH nocounter, outerjoin = d1, outerjoin = d4
   ;end select
   SET stat = alterlist(reply->prsnl_list,prsnl_cnt)
 END ;Subroutine
 SUBROUTINE getcarryforwardcareteamassignments(null)
  SELECT
   IF ((request->assign_type_cd > 0)
    AND (request->use_loc_hier_for_assign=1))
    FROM dcp_shift_assignment dsa,
     (dummyt d1  WITH seq = 1),
     dcp_care_team dct,
     (dummyt d2  WITH seq = 1),
     dcp_care_team_prsnl dctp,
     prsnl p,
     (dummyt d4  WITH seq = 1),
     encounter e,
     person ps
    PLAN (dsa
     WHERE ((expand(iptr,1,size(locations->qual,5),dsa.loc_facility_cd,locations->qual[iptr].
      location_cd)) OR (((expand(iptr,1,size(locations->qual,5),dsa.loc_building_cd,locations->qual[
      iptr].location_cd)) OR (expand(iptr,1,size(locations->qual,5),dsa.loc_unit_cd,locations->qual[
      iptr].location_cd))) ))
      AND (dsa.assign_type_cd=request->assign_type_cd)
      AND dsa.beg_effective_dt_tm >= cnvtdatetime(cf_beg_dt_tm)
      AND dsa.end_effective_dt_tm <= cnvtdatetime(cf_end_dt_tm)
      AND dsa.active_ind=1
      AND ((dsa.careteam_id+ 0) != 0))
     JOIN (d1)
     JOIN (dct
     WHERE dct.careteam_id=dsa.careteam_id
      AND dct.beg_effective_dt_tm >= cnvtdatetime(cf_beg_dt_tm)
      AND dct.end_effective_dt_tm <= cnvtdatetime(cf_end_dt_tm)
      AND dct.active_ind=1
      AND dct.careteam_id != 0)
     JOIN (d2)
     JOIN (dctp
     WHERE dctp.careteam_id=dct.careteam_id
      AND dctp.active_ind=1)
     JOIN (p
     WHERE p.person_id=dctp.prsnl_id
      AND p.active_ind=1)
     JOIN (d4)
     JOIN (e
     WHERE e.person_id=dsa.person_id
      AND e.encntr_id=dsa.encntr_id
      AND e.loc_nurse_unit_cd=dsa.loc_unit_cd)
     JOIN (ps
     WHERE ps.person_id=e.person_id
      AND ps.active_ind=1)
   ELSEIF ((request->use_loc_hier_for_assign=1))
    FROM dcp_shift_assignment dsa,
     (dummyt d1  WITH seq = 1),
     dcp_care_team dct,
     (dummyt d2  WITH seq = 1),
     dcp_care_team_prsnl dctp,
     prsnl p,
     (dummyt d4  WITH seq = 1),
     encounter e,
     person ps
    PLAN (dsa
     WHERE ((expand(iptr,1,size(locations->qual,5),dsa.loc_facility_cd,locations->qual[iptr].
      location_cd)) OR (((expand(iptr,1,size(locations->qual,5),dsa.loc_building_cd,locations->qual[
      iptr].location_cd)) OR (expand(iptr,1,size(locations->qual,5),dsa.loc_unit_cd,locations->qual[
      iptr].location_cd))) ))
      AND (dsa.assignment_pos_cd=request->position_cd)
      AND dsa.beg_effective_dt_tm >= cnvtdatetime(cf_beg_dt_tm)
      AND dsa.end_effective_dt_tm <= cnvtdatetime(cf_end_dt_tm)
      AND dsa.active_ind=1
      AND ((dsa.careteam_id+ 0) != 0))
     JOIN (d1)
     JOIN (dct
     WHERE dct.careteam_id=dsa.careteam_id
      AND dct.beg_effective_dt_tm >= cnvtdatetime(cf_beg_dt_tm)
      AND dct.end_effective_dt_tm <= cnvtdatetime(cf_end_dt_tm)
      AND dct.active_ind=1
      AND dct.careteam_id != 0)
     JOIN (d2)
     JOIN (dctp
     WHERE dctp.careteam_id=dct.careteam_id
      AND dctp.active_ind=1)
     JOIN (p
     WHERE p.person_id=dctp.prsnl_id
      AND p.active_ind=1)
     JOIN (d4)
     JOIN (e
     WHERE e.person_id=dsa.person_id
      AND e.encntr_id=dsa.encntr_id
      AND e.loc_nurse_unit_cd=dsa.loc_unit_cd)
     JOIN (ps
     WHERE ps.person_id=e.person_id
      AND ps.active_ind=1)
   ELSE
    FROM dcp_shift_assignment dsa,
     (dummyt d1  WITH seq = 1),
     dcp_care_team dct,
     (dummyt d2  WITH seq = 1),
     dcp_care_team_prsnl dctp,
     prsnl p,
     (dummyt d4  WITH seq = 1),
     encounter e,
     person ps
    PLAN (dsa
     WHERE (dsa.assignment_group_cd=request->location_cd)
      AND (dsa.assignment_pos_cd=request->position_cd)
      AND dsa.beg_effective_dt_tm >= cnvtdatetime(cf_beg_dt_tm)
      AND dsa.end_effective_dt_tm <= cnvtdatetime(cf_end_dt_tm)
      AND dsa.active_ind=1
      AND ((dsa.careteam_id+ 0) != 0))
     JOIN (d1)
     JOIN (dct
     WHERE dct.careteam_id=dsa.careteam_id
      AND dct.beg_effective_dt_tm >= cnvtdatetime(cf_beg_dt_tm)
      AND dct.end_effective_dt_tm <= cnvtdatetime(cf_end_dt_tm)
      AND dct.active_ind=1
      AND dct.careteam_id != 0)
     JOIN (d2)
     JOIN (dctp
     WHERE dctp.careteam_id=dct.careteam_id
      AND dctp.active_ind=1)
     JOIN (p
     WHERE p.person_id=dctp.prsnl_id
      AND p.active_ind=1)
     JOIN (d4)
     JOIN (e
     WHERE e.person_id=dsa.person_id
      AND e.encntr_id=dsa.encntr_id
      AND e.loc_nurse_unit_cd=dsa.loc_unit_cd)
     JOIN (ps
     WHERE ps.person_id=e.person_id
      AND ps.active_ind=1)
   ENDIF
   INTO "nl:"
   dsa.assignment_id, dct.careteam_id, ps.person_id,
   p.person_id
   ORDER BY dct.careteam_id
   HEAD dct.careteam_id
    care_cnt += 1
    IF (care_cnt > size(reply->careteam_list,5))
     stat = alterlist(reply->careteam_list,(care_cnt+ 5))
    ENDIF
    CALL echo(build("careteam_id start:",dct.careteam_id)), reply->careteam_list[care_cnt].
    careteam_id = dct.careteam_id, reply->careteam_list[care_cnt].careteam_name = dct.name,
    loc_cnt = 0, prsnl_cnt = 0
   HEAD p.person_id
    IF (p.person_id != 0)
     CALL echo(build("person_id:",p.person_id)), prsnl_cnt += 1
     IF (prsnl_cnt > size(reply->careteam_list[care_cnt].prsnl_list,5))
      stat = alterlist(reply->careteam_list[care_cnt].prsnl_list,(prsnl_cnt+ 5))
     ENDIF
     reply->careteam_list[care_cnt].prsnl_list[prsnl_cnt].prsnl_id = p.person_id, reply->
     careteam_list[care_cnt].prsnl_list[prsnl_cnt].position_cd = p.position_cd, reply->careteam_list[
     care_cnt].prsnl_list[prsnl_cnt].name_full_formatted = p.name_full_formatted
    ENDIF
   DETAIL
    IF (((e.loc_nurse_unit_cd=dsa.loc_unit_cd) OR (((dsa.loc_room_cd > 0
     AND dsa.loc_bed_cd > 0
     AND dsa.person_id=0
     AND dsa.encntr_id=0) OR (((dsa.loc_room_cd > 0
     AND dsa.loc_bed_cd=0
     AND dsa.person_id=0
     AND dsa.encntr_id=0) OR (dsa.loc_room_cd=0
     AND dsa.loc_bed_cd=0
     AND dsa.person_id=0
     AND dsa.encntr_id=0)) )) )) )
     loc_cnt += 1
     IF (loc_cnt > size(reply->careteam_list[care_cnt].qual,5))
      stat = alterlist(reply->careteam_list[care_cnt].qual,(loc_cnt+ 5))
     ENDIF
     reply->careteam_list[care_cnt].qual[loc_cnt].assignment_id = dsa.assignment_id, reply->
     careteam_list[care_cnt].qual[loc_cnt].loc_bed_cd = dsa.loc_bed_cd, reply->careteam_list[care_cnt
     ].qual[loc_cnt].loc_room_cd = dsa.loc_room_cd,
     reply->careteam_list[care_cnt].qual[loc_cnt].loc_unit_cd = dsa.loc_unit_cd, reply->
     careteam_list[care_cnt].qual[loc_cnt].loc_building_cd = dsa.loc_building_cd, reply->
     careteam_list[care_cnt].qual[loc_cnt].loc_facility_cd = dsa.loc_facility_cd,
     reply->careteam_list[care_cnt].qual[loc_cnt].person_id = ps.person_id, reply->careteam_list[
     care_cnt].qual[loc_cnt].encntr_id = e.encntr_id, reply->careteam_list[care_cnt].qual[loc_cnt].
     beg_dt_tm = datetimeadd(cf_beg_dt_tm,1),
     reply->careteam_list[care_cnt].qual[loc_cnt].end_dt_tm = datetimeadd(cf_end_dt_tm,1), reply->
     careteam_list[care_cnt].qual[loc_cnt].name_full_formatted = ps.name_full_formatted, reply->
     careteam_list[care_cnt].qual[loc_cnt].carry_forward_ind = 1
    ENDIF
   FOOT  dct.careteam_id
    IF (loc_cnt > 0)
     stat = alterlist(reply->careteam_list[care_cnt].qual,loc_cnt)
    ENDIF
    stat = alterlist(reply->careteam_list[care_cnt].prsnl_list,prsnl_cnt)
   WITH nocounter, outerjoin = d1, outerjoin = d2,
    outerjoin = d4
  ;end select
  SET stat = alterlist(reply->careteam_list,care_cnt)
 END ;Subroutine
 SUBROUTINE getcarryforwardprsnlassignments(null)
   SET loc_cnt = 0
   SET prsnl_cnt = size(reply->prsnl_list,5)
   SELECT
    IF ((request->assign_type_cd > 0)
     AND (request->use_loc_hier_for_assign=1))
     FROM dcp_shift_assignment dsa,
      (dummyt d1  WITH seq = 1),
      prsnl p,
      (dummyt d4  WITH seq = 1),
      encounter e,
      person ps
     PLAN (dsa
      WHERE ((expand(iptr,1,size(locations->qual,5),dsa.loc_facility_cd,locations->qual[iptr].
       location_cd)) OR (((expand(iptr,1,size(locations->qual,5),dsa.loc_building_cd,locations->qual[
       iptr].location_cd)) OR (expand(iptr,1,size(locations->qual,5),dsa.loc_unit_cd,locations->qual[
       iptr].location_cd))) ))
       AND (dsa.assign_type_cd=request->assign_type_cd)
       AND dsa.beg_effective_dt_tm >= cnvtdatetime(cf_beg_dt_tm)
       AND dsa.end_effective_dt_tm <= cnvtdatetime(cf_end_dt_tm)
       AND dsa.active_ind=1
       AND dsa.prsnl_id != 0)
      JOIN (d1)
      JOIN (p
      WHERE p.person_id=dsa.prsnl_id
       AND p.active_ind=1
       AND p.person_id != 0)
      JOIN (d4)
      JOIN (e
      WHERE e.person_id=dsa.person_id
       AND e.encntr_id=dsa.encntr_id
       AND e.loc_nurse_unit_cd=dsa.loc_unit_cd)
      JOIN (ps
      WHERE ps.person_id=e.person_id
       AND ps.active_ind=1)
    ELSEIF ((request->use_loc_hier_for_assign=1))
     FROM dcp_shift_assignment dsa,
      (dummyt d1  WITH seq = 1),
      prsnl p,
      (dummyt d4  WITH seq = 1),
      encounter e,
      person ps
     PLAN (dsa
      WHERE ((expand(iptr,1,size(locations->qual,5),dsa.loc_facility_cd,locations->qual[iptr].
       location_cd)) OR (((expand(iptr,1,size(locations->qual,5),dsa.loc_building_cd,locations->qual[
       iptr].location_cd)) OR (expand(iptr,1,size(locations->qual,5),dsa.loc_unit_cd,locations->qual[
       iptr].location_cd))) ))
       AND (dsa.assignment_pos_cd=request->position_cd)
       AND dsa.beg_effective_dt_tm >= cnvtdatetime(cf_beg_dt_tm)
       AND dsa.end_effective_dt_tm <= cnvtdatetime(cf_end_dt_tm)
       AND dsa.active_ind=1
       AND dsa.prsnl_id != 0)
      JOIN (d1)
      JOIN (p
      WHERE p.person_id=dsa.prsnl_id
       AND p.active_ind=1
       AND p.person_id != 0)
      JOIN (d4)
      JOIN (e
      WHERE e.person_id=dsa.person_id
       AND e.encntr_id=dsa.encntr_id
       AND e.loc_nurse_unit_cd=dsa.loc_unit_cd)
      JOIN (ps
      WHERE ps.person_id=e.person_id
       AND ps.active_ind=1)
    ELSE
     FROM dcp_shift_assignment dsa,
      (dummyt d1  WITH seq = 1),
      prsnl p,
      (dummyt d4  WITH seq = 1),
      encounter e,
      person ps
     PLAN (dsa
      WHERE (dsa.assignment_group_cd=request->location_cd)
       AND (dsa.assignment_pos_cd=request->position_cd)
       AND dsa.beg_effective_dt_tm >= cnvtdatetime(cf_beg_dt_tm)
       AND dsa.end_effective_dt_tm <= cnvtdatetime(cf_end_dt_tm)
       AND dsa.active_ind=1
       AND dsa.prsnl_id != 0)
      JOIN (d1)
      JOIN (p
      WHERE p.person_id=dsa.prsnl_id
       AND p.active_ind=1
       AND p.person_id != 0)
      JOIN (d4)
      JOIN (e
      WHERE e.person_id=dsa.person_id
       AND e.encntr_id=dsa.encntr_id
       AND e.loc_nurse_unit_cd=dsa.loc_unit_cd)
      JOIN (ps
      WHERE ps.person_id=e.person_id
       AND ps.active_ind=1)
    ENDIF
    INTO "nl:"
    dsa.assignment_id, ps.person_id, p.person_id
    ORDER BY p.person_id
    HEAD p.person_id
     CALL echo(build("person_id:",p.person_id)), prsnl_cnt += 1
     IF (prsnl_cnt > size(reply->prsnl_list,5))
      stat = alterlist(reply->prsnl_list,(prsnl_cnt+ 5))
     ENDIF
     reply->prsnl_list[prsnl_cnt].prsnl_id = p.person_id, reply->prsnl_list[prsnl_cnt].position_cd =
     p.position_cd, reply->prsnl_list[prsnl_cnt].name_full_formatted = p.name_full_formatted,
     loc_cnt = 0
    DETAIL
     IF (((e.loc_nurse_unit_cd=dsa.loc_unit_cd) OR (((dsa.loc_room_cd > 0
      AND dsa.loc_bed_cd > 0
      AND dsa.person_id=0
      AND dsa.encntr_id=0) OR (((dsa.loc_room_cd > 0
      AND dsa.loc_bed_cd=0
      AND dsa.person_id=0
      AND dsa.encntr_id=0) OR (dsa.loc_room_cd=0
      AND dsa.loc_bed_cd=0
      AND dsa.person_id=0
      AND dsa.encntr_id=0)) )) )) )
      loc_cnt += 1
      IF (loc_cnt > size(reply->prsnl_list[prsnl_cnt].qual,5))
       stat = alterlist(reply->prsnl_list[prsnl_cnt].qual,(loc_cnt+ 5))
      ENDIF
      reply->prsnl_list[prsnl_cnt].qual[loc_cnt].assignment_id = dsa.assignment_id, reply->
      prsnl_list[prsnl_cnt].qual[loc_cnt].loc_bed_cd = dsa.loc_bed_cd, reply->prsnl_list[prsnl_cnt].
      qual[loc_cnt].loc_room_cd = dsa.loc_room_cd,
      reply->prsnl_list[prsnl_cnt].qual[loc_cnt].loc_unit_cd = dsa.loc_unit_cd, reply->prsnl_list[
      prsnl_cnt].qual[loc_cnt].loc_building_cd = dsa.loc_building_cd, reply->prsnl_list[prsnl_cnt].
      qual[loc_cnt].loc_facility_cd = dsa.loc_facility_cd,
      reply->prsnl_list[prsnl_cnt].qual[loc_cnt].person_id = ps.person_id, reply->prsnl_list[
      prsnl_cnt].qual[loc_cnt].encntr_id = e.encntr_id, reply->prsnl_list[prsnl_cnt].qual[loc_cnt].
      beg_dt_tm = datetimeadd(cf_beg_dt_tm,1),
      reply->prsnl_list[prsnl_cnt].qual[loc_cnt].end_dt_tm = datetimeadd(cf_end_dt_tm,1), reply->
      prsnl_list[prsnl_cnt].qual[loc_cnt].name_full_formatted = ps.name_full_formatted, reply->
      prsnl_list[prsnl_cnt].qual[loc_cnt].carry_forward_ind = 1
     ENDIF
    FOOT  p.person_id
     IF (loc_cnt > 0)
      stat = alterlist(reply->prsnl_list[prsnl_cnt].qual,loc_cnt)
     ENDIF
    WITH nocounter, outerjoin = d1, outerjoin = d4
   ;end select
   SET stat = alterlist(reply->prsnl_list,prsnl_cnt)
 END ;Subroutine
#exit_script
 SET error_code = error(error_msg,1)
 IF (error_code != 0)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus("ERROR","F","dcp_get_careteam_prsnls",error_msg)
 ELSEIF (fail_ind=true)
  SET reply->status_data.status = "F"
  CALL echo("*DCP_GET_CARETEAM_PRSNLS failed*")
 ELSEIF (zero_ind=true)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (debug_ind=0)
  FREE RECORD locations
  FREE RECORD locations_temp
 ELSE
  CALL echorecord(reply)
  DECLARE last_mod = vc WITH protect, noconstant("MOD 008 - 09/17/12")
  CALL echo(last_mod)
 ENDIF
 SET modify = nopredeclare
END GO
