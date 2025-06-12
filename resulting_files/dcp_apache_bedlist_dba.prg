CREATE PROGRAM dcp_apache_bedlist:dba
 RECORD internalrequest(
   1 nurse_unit_or_amb_cd = f8
   1 nlist[*]
     2 multi_nurse_unit_or_amb_cd = f8
   1 patient_list_id = f8
   1 patient_list_type_cd = f8
 )
 RECORD reply(
   1 result_limit_exceeded = i4
   1 nursing_rec_status = c1
   1 virtual_rec_status = c1
   1 bedlist[*]
     2 bed_occupied_ind = i2
     2 poss_bed_occupied_ind = i2
     2 non_predicted_pt_ind = i2
     2 poss_non_predicted_pt_ind = i2
     2 nurse_unit_cd = f8
     2 loc_room_cd = f8
     2 loc_bed_cd = f8
     2 person_id = f8
     2 poss_person_id = f8
     2 encntr_id = f8
     2 poss_encntr_id = f8
     2 name_full_formatted = vc
     2 poss_name_full_formatted = vc
     2 attend_doc = vc
     2 attend_doc_id = f8
     2 reg_dt_tm = dq8
     2 poss_reg_dt_tm = dq8
     2 birth_dt_tm = dq8
     2 poss_birth_dt_tm = dq8
     2 sex_cd = f8
     2 poss_sex_cd = f8
     2 age = vc
     2 poss_age = vc
     2 age_in_years = i2
     2 poss_age_in_years = i2
     2 med_service_cd = f8
     2 med_service_disp = vc
     2 risk_adjustment_id = f8
     2 admit_category = vc
     2 elective_surgery_ind = i2
     2 admit_diagnosis = vc
     2 icu_admit_date = dq8
     2 copdlevel = vc
     2 chronic_dialysis_ind = i2
     2 chronic_health = vc
     2 room_bed_disp = vc
     2 poss_room_bed_disp = vc
     2 room_bed_init_disp = vc
     2 poss_room_bed_init_disp = vc
     2 attend_doc_init = vc
     2 apache_three = i4
     2 apache_dt_tm = dq8
     2 apache_three_day_one = i4
     2 aps_day_one = i4
     2 aps_current = i4
     2 phys_res_pts = i4
     2 icu_risk_of_death = i4
     2 hosp_risk_of_death = i4
     2 risk_of_pac = i4
     2 discharge_alive = i4
     2 active_treatment_ind = i2
     2 last_active_treatment_ind = i2
     2 tomorrow_discharge_alive = i4
     2 today_risk_active_tx = i4
     2 day1_risk_active_tx = i4
     2 tomorrow_risk_active_tx = i4
     2 last_cc_day_beg_dt_tm = dq8
     2 last_cc_day_end_dt_tm = dq8
     2 actual_hosp_los = f8
     2 poss_actual_hosp_los = f8
     2 predicted_hosp_los = f8
     2 actual_icu_los = f8
     2 predicted_icu_los = f8
     2 predicted_vent_days = f8
     2 today_tiss_predict = f8
     2 raw_tiss = f8
     2 tomorrow_tiss_predict = f8
     2 day_5_icu_los = f8
     2 treatments_events[*]
       3 treatment_event_flag = c1
       3 treatment_event_disp = vc
     2 error_code = f8
     2 poss_error_code = f8
     2 error_string = vc
     2 poss_error_string = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 FREE SET validrooms
 RECORD validrooms(
   1 validroom[*]
     2 validroom_cd = f8
 )
 DECLARE meaning_code(p1,p2) = f8
 DECLARE apache_age(birth_dt_tm,admit_dt_tm) = i2
 DECLARE convertrequest("") = i2
 SET failed_text = fillstring(200," ")
 SET failed_status = "F"
 DECLARE num = i4
 SET junk = convertrequest("")
 EXECUTE FROM 1000_initialize TO 1999_initialize_exit
 IF (((size(internalrequest->nlist,5) >= 1) OR ((internalrequest->nurse_unit_or_amb_cd > 0.0))) )
  EXECUTE FROM 2000_read TO 2999_read_exit
 ENDIF
 IF ((internalrequest->patient_list_id >= 1))
  EXECUTE FROM 3000_read_by_list_id TO 3099_read_by_list_id_exit
 ENDIF
 IF (size(reply->bedlist,5) > 200)
  SET reply->result_limit_exceeded = 1
 ENDIF
 EXECUTE FROM 4000_populate_bedlist_with_ra_data TO 4099_populate_bedlist_with_ra_data_exit
 GO TO 9999_exit_program
 SUBROUTINE apache_age(birth_dt_tm,admit_dt_tm)
   SET return_age = 0
   SET age_diff_days = 0.0
   SET age_diff_years = 0.0
   SET agex = fillstring(12," ")
   SET a_yr = year(cnvtdatetime(admit_dt_tm))
   SET b_yr = year(cnvtdatetime(birth_dt_tm))
   SET a_mn = month(cnvtdatetime(admit_dt_tm))
   SET b_mn = month(cnvtdatetime(birth_dt_tm))
   SET a_dy = day(cnvtdatetime(admit_dt_tm))
   SET b_dy = day(cnvtdatetime(birth_dt_tm))
   SET yr_diff = (a_yr - b_yr)
   SET mn_diff = (a_mn - b_mn)
   SET dy_diff = (a_dy - b_dy)
   IF (yr_diff > 3)
    SET agex = cnvtage(cnvtdatetime(birth_dt_tm),cnvtdatetime(admit_dt_tm),0)
    SET agex = replace(agex," ","0",0)
    SET return_age = cnvtint(substring(1,3,agex))
   ELSE
    IF (dy_diff < 0)
     SET mn_diff = (mn_diff - 1)
     SET dy_diff = (31+ dy_diff)
    ENDIF
    IF (mn_diff < 0)
     SET yr_diff = (yr_diff - 1)
     SET mn_diff = (12+ mn_diff)
    ENDIF
    SET return_age = yr_diff
   ENDIF
   RETURN(return_age)
 END ;Subroutine
 SUBROUTINE meaning_code(mc_codeset,mc_meaning)
   SET mc_code = 0.0
   SET mc_text = fillstring(12," ")
   SET mc_text = mc_meaning
   SET mc_stat = uar_get_meaning_by_codeset(mc_codeset,nullterm(mc_text),1,mc_code)
   IF (mc_code > 0.0)
    RETURN(mc_code)
   ELSE
    RETURN(- (1.0))
   ENDIF
 END ;Subroutine
 SUBROUTINE convertrequest(junk)
   SET internalrequest->nurse_unit_or_amb_cd = request->nurse_unit_or_amb_cd
   SET internalrequest->patient_list_id = request->patient_list_id
   SET internalrequest->patient_list_type_cd = request->patient_list_type_cd
   IF (validate(request->nlist)=1)
    SET listsize = size(request->nlist,5)
    SET stat = alterlist(internalrequest->nlist,listsize)
    FOR (idx = 1 TO listsize)
      SET internalrequest->nlist[idx].multi_nurse_unit_or_amb_cd = request->nlist[idx].
      multi_nurse_unit_or_amb_cd
    ENDFOR
   ENDIF
   RETURN(1)
 END ;Subroutine
#1000_initialize
 SET reply->status_data.status = "F"
 SET reply->result_limit_exceeded = 0
 DECLARE f_text = vc
 SET ambulatory_type_cd = meaning_code(222,"AMBULATORY")
 SET census_type_cd = meaning_code(339,"CENSUS")
 SET nurse_unit_type_cd = meaning_code(222,"NURSEUNIT")
 SET room_type_cd = meaning_code(222,"ROOM")
 SET attend_doc_cd = meaning_code(333,"ATTENDDOC")
 SET unit_ok = "N"
 SET bed_ok = "N"
 SET vroom_count = 0
 SET day_str = "   "
 DECLARE inpatienttypeclasscd = f8 WITH noconstant(uar_get_code_by("MEANING",69,"INPATIENT"))
#1999_initialize_exit
#2000_read
 IF (((validate(internalrequest->nlist)=1) OR ((internalrequest->nurse_unit_or_amb_cd > 0.0))) )
  FREE SET rooms
  RECORD rooms(
    1 room[*]
      2 room_cd = f8
      2 location_cd = f8
  )
  SET room_count = 0
  SET bed_count = 0
  SET patient_count = 0
  SET found_icu_cd = 0
  SET base_location_list = fillstring(5000," ")
  SET x = 0
  SET nlistsize = 0
  SET reply->nursing_rec_status = "S"
  IF (validate(request->nlist)=1)
   SET base_location_list = " in ("
   SET nlistsize = size(internalrequest->nlist,5)
   FOR (x = 1 TO nlistsize)
    IF (x > 1)
     SET base_location_list = build(base_location_list,",")
    ENDIF
    SET base_location_list = build(base_location_list,internalrequest->nlist[x].
     multi_nurse_unit_or_amb_cd)
   ENDFOR
  ELSEIF ((internalrequest->nurse_unit_or_amb_cd > 0))
   SET base_location_list = " = ("
   SET base_location_list = build(base_location_list,internalrequest->nurse_unit_or_amb_cd)
  ENDIF
  SET base_location_list = trim(build(base_location_list,")"))
  CALL echo(build("base_location_list=",base_location_list))
  SET location_list = build("l.location_cd ",base_location_list)
  SET group_list = build("g.parent_loc_cd ",base_location_list)
  SELECT INTO "nl:"
   FROM location l
   PLAN (l
    WHERE parser(location_list)
     AND l.active_ind=1
     AND ((l.icu_ind+ 0)=1))
   DETAIL
    found_icu_cd = l.icu_ind
   WITH nocounter
  ;end select
  IF (found_icu_cd=0)
   SET failed_status = "Z"
   SET failed_text = concat("Not an APACHE location")
   SET reply->nursing_rec_status = "Z"
  ENDIF
  IF ((reply->nursing_rec_status="S"))
   SELECT INTO "nl:"
    r.location_cd, g.parent_loc_cd
    FROM location_group g,
     location l,
     room r,
     code_value c
    PLAN (g
     WHERE parser(group_list)
      AND ((g.location_group_type_cd+ 0) IN (ambulatory_type_cd, nurse_unit_type_cd))
      AND ((g.root_loc_cd+ 0)=0)
      AND ((g.active_ind+ 0)=1)
      AND ((g.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
      AND ((g.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3)))
     JOIN (l
     WHERE l.location_cd=g.child_loc_cd
      AND ((l.active_ind+ 0)=1)
      AND ((l.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
      AND ((l.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3)))
     JOIN (r
     WHERE r.location_cd=l.location_cd
      AND ((r.active_ind+ 0)=1)
      AND ((r.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
      AND ((r.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3)))
     JOIN (c
     WHERE c.code_value=l.location_cd)
    ORDER BY c.display
    DETAIL
     room_count = (room_count+ 1), stat = alterlist(rooms->room,room_count), rooms->room[room_count].
     room_cd = r.location_cd,
     rooms->room[room_count].location_cd = g.parent_loc_cd
    WITH nocounter
   ;end select
   IF (room_count > 0)
    SET batch_size = 40
    SET loop_cnt = ceil((cnvtreal(room_count)/ batch_size))
    SET nstart = 1
    SET new_list_size = (loop_cnt * batch_size)
    SET stat = alterlist(rooms->room,new_list_size)
    FOR (idx = (room_count+ 1) TO new_list_size)
      SET rooms->room[idx].room_cd = rooms->room[room_count].room_cd
    ENDFOR
    SELECT INTO "nl:"
     b.location_cd
     FROM location_group g,
      location l,
      bed b,
      code_value c,
      (dummyt d  WITH seq = value(loop_cnt))
     PLAN (d
      WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
      JOIN (g
      WHERE expand(num,nstart,(nstart+ (batch_size - 1)),g.parent_loc_cd,rooms->room[num].room_cd)
       AND ((g.location_group_type_cd+ 0)=room_type_cd)
       AND ((g.root_loc_cd+ 0)=0)
       AND ((g.active_ind+ 0)=1)
       AND ((g.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
       AND ((g.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3)))
      JOIN (l
      WHERE l.location_cd=g.child_loc_cd
       AND ((l.active_ind+ 0)=1)
       AND ((l.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
       AND ((l.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3)))
      JOIN (b
      WHERE b.location_cd=l.location_cd
       AND ((b.active_ind+ 0)=1)
       AND ((b.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
       AND ((b.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3)))
      JOIN (c
      WHERE c.code_value=l.location_cd)
     ORDER BY c.display
     DETAIL
      bed_count = (bed_count+ 1)
      IF (mod(bed_count,50)=1)
       stat = alterlist(reply->bedlist,(bed_count+ 49))
      ENDIF
      index = locateval(num,1,room_count,g.parent_loc_cd,rooms->room[num].room_cd), reply->bedlist[
      bed_count].nurse_unit_cd = rooms->room[num].location_cd, reply->bedlist[bed_count].loc_room_cd
       = g.parent_loc_cd,
      reply->bedlist[bed_count].loc_bed_cd = b.location_cd, reply->bedlist[bed_count].
      bed_occupied_ind = 0, reply->bedlist[bed_count].non_predicted_pt_ind = 0,
      reply->bedlist[bed_count].apache_three = - (1), reply->bedlist[bed_count].apache_three_day_one
       = - (1), reply->bedlist[bed_count].aps_day_one = - (1),
      reply->bedlist[bed_count].aps_current = - (1), reply->bedlist[bed_count].phys_res_pts = - (1),
      reply->bedlist[bed_count].icu_risk_of_death = - (1),
      reply->bedlist[bed_count].hosp_risk_of_death = - (1), reply->bedlist[bed_count].risk_of_pac =
      - (1), reply->bedlist[bed_count].active_treatment_ind = - (1),
      reply->bedlist[bed_count].last_active_treatment_ind = 0, reply->bedlist[bed_count].
      discharge_alive = - (1), reply->bedlist[bed_count].tomorrow_discharge_alive = - (1),
      reply->bedlist[bed_count].today_risk_active_tx = - (1), reply->bedlist[bed_count].
      day1_risk_active_tx = - (1), reply->bedlist[bed_count].tomorrow_risk_active_tx = - (1),
      reply->bedlist[bed_count].actual_hosp_los = - (1), reply->bedlist[bed_count].predicted_hosp_los
       = - (1), reply->bedlist[bed_count].actual_icu_los = - (1),
      reply->bedlist[bed_count].predicted_icu_los = - (1), reply->bedlist[bed_count].day_5_icu_los =
      - (1), reply->bedlist[bed_count].predicted_vent_days = - (1),
      reply->bedlist[bed_count].today_tiss_predict = - (1), reply->bedlist[bed_count].raw_tiss = - (1
      ), reply->bedlist[bed_count].tomorrow_tiss_predict = - (1),
      reply->bedlist[bed_count].room_bed_disp = concat(trim(uar_get_code_display(rooms->room[index].
         room_cd)),trim(uar_get_code_display(b.location_cd))), reply->bedlist[bed_count].
      room_bed_init_disp = concat(trim(uar_get_code_display(rooms->room[index].room_cd)),trim(
        uar_get_code_display(b.location_cd)),":")
     WITH nocounter
    ;end select
    SET stat = alterlist(reply->bedlist,bed_count)
   ENDIF
   IF (bed_count > 0)
    SET batch_size = 50
    SET loop_cnt = ceil((cnvtreal(bed_count)/ batch_size))
    SET nstart = 1
    SET new_list_size = (loop_cnt * batch_size)
    SET stat = alterlist(reply->bedlist,new_list_size)
    FOR (idx = (bed_count+ 1) TO new_list_size)
      SET reply->bedlist[idx].loc_room_cd = reply->bedlist[bed_count].loc_room_cd
      SET reply->bedlist[idx].loc_bed_cd = reply->bedlist[bed_count].loc_bed_cd
      SET reply->bedlist[idx].nurse_unit_cd = reply->bedlist[bed_count].nurse_unit_cd
    ENDFOR
    SELECT INTO "nl:"
     e.encntr_id
     FROM encntr_domain ed,
      encounter e,
      person p,
      (dummyt d  WITH seq = value(loop_cnt))
     PLAN (d
      WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
      JOIN (ed
      WHERE expand(num,nstart,(nstart+ (batch_size - 1)),ed.loc_nurse_unit_cd,reply->bedlist[num].
       nurse_unit_cd,
       ed.loc_room_cd,reply->bedlist[num].loc_room_cd,ed.loc_bed_cd,reply->bedlist[num].loc_bed_cd)
       AND ed.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
       AND ed.encntr_domain_type_cd=census_type_cd
       AND ((ed.active_ind+ 0)=1)
       AND ((ed.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3)))
      JOIN (e
      WHERE e.encntr_id=ed.encntr_id
       AND e.loc_nurse_unit_cd=ed.loc_nurse_unit_cd
       AND ((e.loc_room_cd+ 0)=ed.loc_room_cd)
       AND ((e.loc_bed_cd+ 0)=ed.loc_bed_cd)
       AND ((e.active_ind+ 0)=1)
       AND ((e.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
       AND ((e.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3))
       AND e.reg_dt_tm > cnvtdatetime((curdate - 999),curtime))
      JOIN (p
      WHERE p.person_id=e.person_id
       AND ((p.active_ind+ 0)=1)
       AND ((p.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
       AND ((p.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3)))
     ORDER BY ed.encntr_id, cnvtdatetime(e.reg_dt_tm) DESC
     HEAD REPORT
      agex = "            "
     HEAD ed.encntr_id
      index = locateval(num,1,bed_count,ed.loc_nurse_unit_cd,reply->bedlist[num].nurse_unit_cd,
       ed.loc_room_cd,reply->bedlist[num].loc_room_cd,ed.loc_bed_cd,reply->bedlist[num].loc_bed_cd),
      patient_count = (patient_count+ 1)
      IF (e.encntr_type_class_cd=inpatienttypeclasscd)
       reply->bedlist[index].bed_occupied_ind = 1, reply->bedlist[index].encntr_id = e.encntr_id,
       reply->bedlist[index].person_id = p.person_id,
       reply->bedlist[index].name_full_formatted = trim(p.name_full_formatted,3), reply->bedlist[
       index].birth_dt_tm = p.birth_dt_tm, reply->bedlist[index].age = cnvtage(p.birth_dt_tm,e
        .reg_dt_tm,0),
       reply->bedlist[index].age_in_years = apache_age(p.birth_dt_tm,e.reg_dt_tm)
       IF ((reply->bedlist[index].age_in_years < 16))
        reply->bedlist[index].non_predicted_pt_ind = 1, f_text =
        "Patient under 16, unable to calculate predictions.", reply->bedlist[index].error_string =
        f_text,
        reply->bedlist[index].error_code = - (23103)
       ENDIF
       reply->bedlist[index].sex_cd = p.sex_cd, reply->bedlist[index].reg_dt_tm = e.reg_dt_tm
       IF (e.disch_dt_tm = null)
        reply->bedlist[index].actual_hosp_los = datetimediff(cnvtdatetime(curdate,curtime),e
         .reg_dt_tm,1)
       ELSE
        reply->bedlist[index].actual_hosp_los = datetimediff(e.disch_dt_tm,e.reg_dt_tm,1)
       ENDIF
       reply->bedlist[index].room_bed_disp = concat(trim(uar_get_code_display(ed.loc_room_cd)),trim(
         uar_get_code_display(ed.loc_bed_cd))), reply->bedlist[index].room_bed_init_disp = concat(
        trim(uar_get_code_display(ed.loc_room_cd)),trim(uar_get_code_display(ed.loc_bed_cd)),":",
        substring(1,1,p.name_first_key),trim(substring(1,1,p.name_middle_key)),
        substring(1,1,p.name_last_key))
      ENDIF
      reply->bedlist[index].poss_bed_occupied_ind = 1, reply->bedlist[index].poss_encntr_id = e
      .encntr_id, reply->bedlist[index].poss_person_id = p.person_id,
      reply->bedlist[index].poss_name_full_formatted = trim(p.name_full_formatted,3), reply->bedlist[
      index].poss_birth_dt_tm = p.birth_dt_tm, reply->bedlist[index].poss_age = cnvtage(p.birth_dt_tm,
       e.reg_dt_tm,0),
      reply->bedlist[index].poss_age_in_years = apache_age(p.birth_dt_tm,e.reg_dt_tm)
      IF ((reply->bedlist[index].poss_age_in_years < 16))
       reply->bedlist[index].poss_non_predicted_pt_ind = 1, f_text =
       "Patient under 16, unable to calculate predictions.", reply->bedlist[index].poss_error_string
        = f_text,
       reply->bedlist[index].poss_error_code = - (23103)
      ENDIF
      reply->bedlist[index].poss_sex_cd = p.sex_cd, reply->bedlist[index].poss_reg_dt_tm = e
      .reg_dt_tm
      IF (e.disch_dt_tm = null)
       reply->bedlist[index].poss_actual_hosp_los = datetimediff(cnvtdatetime(curdate,curtime),e
        .reg_dt_tm,1)
      ELSE
       reply->bedlist[index].poss_actual_hosp_los = datetimediff(e.disch_dt_tm,e.reg_dt_tm,1)
      ENDIF
      reply->bedlist[index].poss_room_bed_disp = concat(trim(uar_get_code_display(ed.loc_room_cd)),
       trim(uar_get_code_display(ed.loc_bed_cd))), reply->bedlist[index].poss_room_bed_init_disp =
      concat(trim(uar_get_code_display(ed.loc_room_cd)),trim(uar_get_code_display(ed.loc_bed_cd)),":",
       substring(1,1,p.name_first_key),trim(substring(1,1,p.name_middle_key)),
       substring(1,1,p.name_last_key))
     WITH nocounter
    ;end select
    SET stat = alterlist(reply->bedlist,bed_count)
   ENDIF
  ENDIF
 ENDIF
#2999_read_exit
#3000_read_by_list_id
 DECLARE _app = i4 WITH protect, noconstant(0)
 DECLARE _task = i4 WITH protect, noconstant(0)
 DECLARE _happ = i4 WITH protect, noconstant(0)
 DECLARE _htask = i4 WITH protect, noconstant(0)
 DECLARE _hreq = i4 WITH protect, noconstant(0)
 DECLARE _hrep = i4 WITH protect, noconstant(0)
 DECLARE _hstat = i4 WITH protect, noconstant(0)
 SET _app = 600700
 SET _task = 600720
 SET _reqnum = 600123
 SET currentcount = size(reply->bedlist,5)
 SET reply->virtual_rec_status = "S"
 SET crmstatus = uar_crmbeginapp(_app,_happ)
 IF (crmstatus != 0)
  SET failed_text = fillstring(255," ")
  SET failed_text = concat("Error! uar_CrmBeginApp failed with status: ",build(crmstatus))
  CALL echo(failed_text)
  SET reply->virtual_rec_status = "F"
 ELSE
  CALL echo(concat("Uar_CrmBeginApp success, app: ",build(_app)))
 ENDIF
 IF ((reply->virtual_rec_status="S"))
  SET crmstatus = uar_crmbegintask(_happ,_task,_htask)
  IF (crmstatus != 0)
   SET failed_text = fillstring(255," ")
   SET failed_text = concat("Error! uar_CrmBeginTask failed with status: ",build(crmstatus))
   CALL echo(failed_text)
   CALL uar_crmendapp(_happ)
   SET reply->virtual_rec_status = "F"
  ELSE
   CALL echo(concat("Uar_CrmBeginTask success, task: ",build(_task)))
  ENDIF
  IF ((reply->virtual_rec_status="S"))
   SET crmstatus = uar_crmbeginreq(_htask,0,_reqnum,_hreq)
   IF (crmstatus != 0)
    SET failed_text = fillstring(255," ")
    SET failed_text = concat("Invalid CrmBeginReq return status of",build(crmstatus))
    CALL echo(failed_text)
    CALL uar_crmendtask(_htask)
    CALL uar_crmendapp(_happ)
    SET reply->virtual_rec_status = "F"
   ELSE
    CALL echo("uar_CrmBeginReq success")
   ENDIF
   IF ((reply->virtual_rec_status="S"))
    SET _hrequest = uar_crmgetrequest(_hreq)
    IF (_hrequest)
     IF (_hrequest=null)
      SET failed_text = "Invalid hRequest handle returned from CrmGetRequest"
      CALL echo(failed_text)
      SET reply->virtual_rec_status = "F"
     ELSE
      SELECT INTO "nl:"
       FROM dcp_patient_list pl,
        dcp_pl_argument pla
       PLAN (pl
        WHERE (pl.patient_list_id=internalrequest->patient_list_id))
        JOIN (pla
        WHERE pla.patient_list_id=pl.patient_list_id
         AND pla.argument_name="careteam_id")
       HEAD REPORT
        stat = uar_srvsetdouble(_hrequest,"patient_list_id",pl.patient_list_id), stat =
        uar_srvsetdouble(_hrequest,"patient_list_type_cd",pl.patient_list_type_cd), stat =
        uar_srvsetshort(_hrequest,"best_encntr_flag",0)
       DETAIL
        _hargument = uar_srvadditem(_hrequest,"arguments"), stat = uar_srvsetstring(_hargument,
         "argument_name",nullterm(pla.argument_name)), stat = uar_srvsetstring(_hargument,
         "argument_value",nullterm(pla.argument_value)),
        stat = uar_srvsetstring(_hargument,"parent_entity_name",nullterm(pla.parent_entity_name)),
        stat = uar_srvsetdouble(_hargument,"parent_entity_id",pla.parent_entity_id)
       WITH nocounter
      ;end select
      CALL echo(" calling uar_CrmPerform()")
      SET crmstatus = uar_crmperform(_hreq)
      IF (crmstatus != 0)
       SET failed_text = concat("Invalid CrmPerform return status of ",build(crmstatus))
       CALL echo(failed_text)
       SET reply->virtual_rec_status = "F"
      ELSE
       CALL echo(" uar_CrmPerform() success")
       SET _hreply = uar_crmgetreply(_hreq)
       SET _hstat = uar_srvgetstruct(_hreply,"status_data")
       SET _status = uar_srvgetstringptr(_hstat,"status")
       CALL echo(concat("Called process returned: ",_status))
       IF (_status != "S")
        IF (_status="Z")
         SET failed_status = "Z"
         SET reply->virtual_rec_status = "Z"
        ELSE
         SET failed_status = "F"
         SET reply->virtual_rec_status = "F"
        ENDIF
        SET failed_text = fillstring(255," ")
        SET failed_text = concat("dcp_get_patient_list2 returned status= ",build(_status))
        CALL echo(failed_text)
        CALL echo(build(" patient_list_id = ",internalrequest->patient_list_id))
       ELSE
        CALL echo("_Status = 'S'")
        SET patientcnt = uar_srvgetitemcount(_hreply,"patients")
        SET stat = alterlist(reply->bedlist,(patientcnt+ currentcount))
        SET realcnt = currentcount
        FOR (i = 0 TO (patientcnt - 1))
         SET hpatient = uar_srvgetitem(_hreply,"patients",i)
         IF (hpatient=null)
          CALL echo("invalid Patient returned")
         ELSE
          SET encntr_id = uar_srvgetdouble(hpatient,"encntr_id")
          SET posfound = locateval(num,1,(patientcnt+ currentcount),encntr_id,reply->bedlist[num].
           encntr_id)
          IF (encntr_id > 0.0
           AND posfound=0)
           SET realcnt = (realcnt+ 1)
           SET reply->bedlist[realcnt].person_id = uar_srvgetdouble(hpatient,"person_id")
           SET reply->bedlist[realcnt].encntr_id = encntr_id
           SET reply->bedlist[realcnt].poss_person_id = reply->bedlist[realcnt].person_id
           SET reply->bedlist[realcnt].poss_encntr_id = encntr_id
          ELSEIF (encntr_id > 0.0
           AND posfound > 0)
           SET reply->bedlist[posfound].poss_encntr_id = encntr_id
           SET reply->bedlist[posfound].poss_person_id = reply->bedlist[posfound].person_id
          ENDIF
         ENDIF
        ENDFOR
       ENDIF
      ENDIF
      IF ((reply->virtual_rec_status="S"))
       SET stat = alterlist(reply->bedlist,realcnt)
       SET patientcnt = realcnt
       IF (patientcnt > 200)
        SET reply->result_limit_exceeded = 1
       ENDIF
       DECLARE num4 = i4
       SELECT INTO "nl:"
        FROM encounter e,
         person p
        PLAN (e
         WHERE expand(num4,1,patientcnt,e.encntr_id,reply->bedlist[num4].encntr_id)
          AND e.active_ind=1)
         JOIN (p
         WHERE p.person_id=e.person_id
          AND p.active_ind=1)
        DETAIL
         pos = locateval(num4,1,patientcnt,e.encntr_id,reply->bedlist[num4].encntr_id), reply->
         bedlist[pos].bed_occupied_ind = 1, reply->bedlist[pos].poss_bed_occupied_ind = 1,
         reply->bedlist[pos].encntr_id = e.encntr_id, reply->bedlist[pos].poss_encntr_id = e
         .encntr_id, reply->bedlist[pos].loc_bed_cd = e.loc_bed_cd,
         reply->bedlist[pos].loc_room_cd = e.loc_room_cd, reply->bedlist[pos].nurse_unit_cd = e
         .loc_nurse_unit_cd, reply->bedlist[pos].name_full_formatted = p.name_full_formatted,
         reply->bedlist[pos].poss_name_full_formatted = p.name_full_formatted, reply->bedlist[pos].
         person_id = p.person_id, reply->bedlist[pos].poss_person_id = p.person_id,
         reply->bedlist[pos].reg_dt_tm = e.reg_dt_tm, reply->bedlist[pos].poss_reg_dt_tm = reply->
         bedlist[pos].reg_dt_tm, reply->bedlist[pos].sex_cd = p.sex_cd,
         reply->bedlist[pos].poss_sex_cd = reply->bedlist[pos].sex_cd, reply->bedlist[pos].
         birth_dt_tm = p.birth_dt_tm, reply->bedlist[pos].poss_birth_dt_tm = p.birth_dt_tm,
         reply->bedlist[pos].age = cnvtage(p.birth_dt_tm,e.reg_dt_tm,0), reply->bedlist[pos].poss_age
          = reply->bedlist[pos].age, reply->bedlist[pos].age_in_years = apache_age(p.birth_dt_tm,e
          .reg_dt_tm),
         reply->bedlist[pos].poss_age_in_years = reply->bedlist[pos].age_in_years
         IF ((reply->bedlist[pos].age_in_years < 16))
          reply->bedlist[pos].non_predicted_pt_ind = 1, f_text =
          "Patient under 16, unable to calculate predictions.", reply->bedlist[pos].error_string =
          f_text,
          reply->bedlist[pos].error_code = - (23103)
         ENDIF
         reply->bedlist[pos].poss_non_predicted_pt_ind = reply->bedlist[pos].non_predicted_pt_ind,
         reply->bedlist[pos].poss_error_string = reply->bedlist[pos].error_string, reply->bedlist[pos
         ].poss_error_code = reply->bedlist[pos].error_code
         IF (e.disch_dt_tm = null)
          reply->bedlist[pos].actual_hosp_los = datetimediff(cnvtdatetime(curdate,curtime),e
           .reg_dt_tm,1)
         ELSE
          reply->bedlist[pos].actual_hosp_los = datetimediff(e.disch_dt_tm,e.reg_dt_tm,1)
         ENDIF
         reply->bedlist[pos].poss_actual_hosp_los = reply->bedlist[pos].actual_hosp_los, reply->
         bedlist[pos].room_bed_disp = concat(trim(uar_get_code_display(e.loc_room_cd)),trim(
           uar_get_code_display(e.loc_bed_cd))), reply->bedlist[pos].poss_room_bed_disp = reply->
         bedlist[pos].room_bed_disp,
         reply->bedlist[pos].room_bed_init_disp = concat(trim(uar_get_code_display(e.loc_room_cd)),
          trim(uar_get_code_display(e.loc_bed_cd)),":",substring(1,1,p.name_first_key),trim(substring
           (1,1,p.name_middle_key)),
          substring(1,1,p.name_last_key)), reply->bedlist[pos].poss_room_bed_init_disp = reply->
         bedlist[pos].room_bed_init_disp, reply->bedlist[pos].non_predicted_pt_ind = 0,
         reply->bedlist[pos].poss_non_predicted_pt_ind = reply->bedlist[pos].non_predicted_pt_ind,
         reply->bedlist[pos].apache_three = - (1), reply->bedlist[pos].apache_three_day_one = - (1),
         reply->bedlist[pos].aps_day_one = - (1), reply->bedlist[pos].aps_current = - (1), reply->
         bedlist[pos].phys_res_pts = - (1),
         reply->bedlist[pos].icu_risk_of_death = - (1), reply->bedlist[pos].hosp_risk_of_death = - (1
         ), reply->bedlist[pos].risk_of_pac = - (1),
         reply->bedlist[pos].active_treatment_ind = - (1), reply->bedlist[pos].
         last_active_treatment_ind = 0, reply->bedlist[pos].discharge_alive = - (1),
         reply->bedlist[pos].tomorrow_discharge_alive = - (1), reply->bedlist[pos].
         today_risk_active_tx = - (1), reply->bedlist[pos].day1_risk_active_tx = - (1),
         reply->bedlist[pos].tomorrow_risk_active_tx = - (1), reply->bedlist[pos].predicted_hosp_los
          = - (1), reply->bedlist[pos].actual_icu_los = - (1),
         reply->bedlist[pos].predicted_icu_los = - (1), reply->bedlist[pos].day_5_icu_los = - (1),
         reply->bedlist[pos].predicted_vent_days = - (1),
         reply->bedlist[pos].today_tiss_predict = - (1), reply->bedlist[pos].raw_tiss = - (1), reply
         ->bedlist[pos].tomorrow_tiss_predict = - (1)
        WITH nocounter
       ;end select
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDIF
#3099_read_by_list_id_exit
#4000_populate_bedlist_with_ra_data
 SET patient_count = size(reply->bedlist,5)
 CALL echo("POPULATE_BEDLIST")
 CALL echo(build("patient_count =",patient_count))
 IF (patient_count > 0)
  SET batch_size = 50
  SET loop_cnt = ceil((cnvtreal(patient_count)/ batch_size))
  SET nstart = 1
  SET new_list_size = (loop_cnt * batch_size)
  SET stat = alterlist(reply->bedlist,new_list_size)
  FOR (idx = (patient_count+ 1) TO new_list_size)
    SET reply->bedlist[idx].poss_encntr_id = reply->bedlist[patient_count].poss_encntr_id
  ENDFOR
  CALL echo(build("AFTER RESETTING BEDLIST =",size(reply->bedlist,5)))
  CALL echorecord(reply)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(loop_cnt)),
    risk_adjustment ra
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
    JOIN (ra
    WHERE expand(num,nstart,(nstart+ (batch_size - 1)),ra.encntr_id,reply->bedlist[num].
     poss_encntr_id)
     AND ra.icu_disch_dt_tm=cnvtdatetime("31-DEC-2100")
     AND ra.active_ind=1
     AND ((ra.risk_adjustment_id+ 0) > 0))
   HEAD REPORT
    dt_slash = " "
   DETAIL
    dt_slash = " ", index = locateval(num,1,patient_count,ra.encntr_id,reply->bedlist[num].
     poss_encntr_id),
    CALL echo(build("IN DETAIL OF GETTING RA DATA; ENCNTR_ID =",reply->bedlist[num].encntr_id)),
    CALL echo(build("IN DETAIL OF GETTING RA DATA; POSS_ENCNTR_ID =",reply->bedlist[num].
     poss_encntr_id))
    IF ((reply->bedlist[index].encntr_id=0))
     reply->bedlist[index].bed_occupied_ind = reply->bedlist[index].poss_bed_occupied_ind, reply->
     bedlist[index].person_id = reply->bedlist[index].poss_person_id, reply->bedlist[index].encntr_id
      = reply->bedlist[index].poss_encntr_id,
     reply->bedlist[index].name_full_formatted = reply->bedlist[index].poss_name_full_formatted,
     reply->bedlist[index].birth_dt_tm = reply->bedlist[index].poss_birth_dt_tm, reply->bedlist[index
     ].age = reply->bedlist[index].poss_age,
     reply->bedlist[index].age_in_years = reply->bedlist[index].poss_age_in_years, reply->bedlist[
     index].non_predicted_pt_ind = reply->bedlist[index].poss_non_predicted_pt_ind, reply->bedlist[
     index].error_string = reply->bedlist[index].poss_error_string,
     reply->bedlist[index].error_code = reply->bedlist[index].poss_error_code, reply->bedlist[index].
     sex_cd = reply->bedlist[index].poss_sex_cd, reply->bedlist[index].reg_dt_tm = reply->bedlist[
     index].poss_reg_dt_tm,
     reply->bedlist[index].actual_hosp_los = reply->bedlist[index].poss_actual_hosp_los, reply->
     bedlist[index].room_bed_disp = reply->bedlist[index].poss_room_bed_disp, reply->bedlist[index].
     room_bed_init_disp = reply->bedlist[index].poss_room_bed_init_disp
    ENDIF
    reply->bedlist[index].risk_adjustment_id = ra.risk_adjustment_id, reply->bedlist[index].
    elective_surgery_ind = ra.electivesurgery_ind, reply->bedlist[index].admit_diagnosis = ra
    .admit_diagnosis,
    reply->bedlist[index].med_service_cd = ra.med_service_cd
    IF (ra.therapy_level=1)
     reply->bedlist[index].admit_category = "ACTIVE"
    ELSEIF (ra.therapy_level=2)
     reply->bedlist[index].admit_category = "LR-MONITOR"
    ELSEIF (ra.therapy_level=3)
     reply->bedlist[index].admit_category = "HR-MONITOR"
    ELSEIF (ra.therapy_level=4)
     reply->bedlist[index].admit_category = "NP-MONITOR"
    ELSEIF (ra.therapy_level=5)
     reply->bedlist[index].admit_category = "NP-ACTIVE"
    ENDIF
    reply->bedlist[index].icu_admit_date = ra.icu_admit_dt_tm
    IF (ra.icu_disch_dt_tm=cnvtdatetime("31-DEC-2100"))
     reply->bedlist[index].actual_icu_los = datetimediff(cnvtdatetime(curdate,curtime),ra
      .icu_admit_dt_tm,1)
    ELSE
     reply->bedlist[index].actual_icu_los = datetimediff(ra.icu_disch_dt_tm,ra.icu_admit_dt_tm,1)
    ENDIF
    IF (ra.copd_ind=1)
     reply->bedlist[index].copdlevel = cnvtstring(ra.copd_flag)
    ELSE
     reply->bedlist[index].copdlevel = "-1"
    ENDIF
    reply->bedlist[index].chronic_dialysis_ind = ra.dialysis_ind, reply->bedlist[index].attend_doc_id
     = ra.adm_doc_id
    IF (ra.aids_ind=1)
     reply->bedlist[index].chronic_health = trim(concat(reply->bedlist[index].chronic_health,dt_slash,
       "OTHER IMMUNE")), dt_slash = "/"
    ENDIF
    IF (ra.hepaticfailure_ind=1)
     reply->bedlist[index].chronic_health = trim(concat(reply->bedlist[index].chronic_health,dt_slash,
       "HEPATIC FAILURE")), dt_slash = "/"
    ENDIF
    IF (ra.lymphoma_ind=1)
     reply->bedlist[index].chronic_health = trim(concat(reply->bedlist[index].chronic_health,dt_slash,
       "LYMPHOMA")), dt_slash = "/"
    ENDIF
    IF (ra.metastaticcancer_ind=1)
     reply->bedlist[index].chronic_health = trim(concat(reply->bedlist[index].chronic_health,dt_slash,
       "METASTATIC CANCER")), dt_slash = "/"
    ENDIF
    IF (ra.leukemia_ind=1)
     reply->bedlist[index].chronic_health = trim(concat(reply->bedlist[index].chronic_health,dt_slash,
       "LEUKEMIA/MULTIPLE MYELOMA")), dt_slash = "/"
    ENDIF
    IF (ra.immunosuppression_ind=1)
     reply->bedlist[index].chronic_health = trim(concat(reply->bedlist[index].chronic_health,dt_slash,
       "IMMUNOSUPPRESSION")), dt_slash = "/"
    ENDIF
    IF (ra.cirrhosis_ind=1)
     reply->bedlist[index].chronic_health = trim(concat(reply->bedlist[index].chronic_health,dt_slash,
       "CIRRHOSIS")), dt_slash = "/"
    ENDIF
    IF (ra.copd_ind=1)
     IF (ra.copd_flag=2)
      reply->bedlist[index].chronic_health = trim(concat(reply->bedlist[index].chronic_health,
        dt_slash,"SEV_COPD")), dt_slash = "/"
     ELSEIF (ra.copd_flag=1)
      reply->bedlist[index].chronic_health = trim(concat(reply->bedlist[index].chronic_health,
        dt_slash,"MOD_COPD")), dt_slash = "/"
     ELSE
      reply->bedlist[index].chronic_health = trim(concat(reply->bedlist[index].chronic_health,
        dt_slash,"NOLIM_COPD")), dt_slash = "/"
     ENDIF
    ENDIF
    IF (ra.diabetes_ind=1)
     reply->bedlist[index].chronic_health = trim(concat(reply->bedlist[index].chronic_health,dt_slash,
       "DIABETES")), dt_slash = "/"
    ENDIF
    IF (ra.chronic_health_none_ind=1)
     reply->bedlist[index].chronic_health = "NONE"
    ENDIF
    IF (ra.chronic_health_unavail_ind=1)
     reply->bedlist[index].chronic_health = "UNAVAILABLE"
    ENDIF
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->bedlist,patient_count)
  SET batch_size = 50
  SET loop_cnt = ceil((cnvtreal(patient_count)/ batch_size))
  SET nstart = 1
  SET new_list_size = (loop_cnt * batch_size)
  SET stat = alterlist(reply->bedlist,new_list_size)
  FOR (idx = (patient_count+ 1) TO new_list_size)
    SET reply->bedlist[idx].risk_adjustment_id = reply->bedlist[patient_count].risk_adjustment_id
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(loop_cnt)),
    risk_adjustment ra,
    risk_adjustment_day rad,
    risk_adjustment_outcomes rao
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
    JOIN (ra
    WHERE expand(num,nstart,(nstart+ (batch_size - 1)),ra.risk_adjustment_id,reply->bedlist[num].
     risk_adjustment_id)
     AND ra.active_ind=1
     AND ((ra.risk_adjustment_id+ 0) > 0))
    JOIN (rad
    WHERE rad.risk_adjustment_id=ra.risk_adjustment_id
     AND rad.active_ind=1
     AND ((rad.risk_adjustment_day_id+ 0) > 0))
    JOIN (rao
    WHERE ((rao.risk_adjustment_day_id=rad.risk_adjustment_day_id
     AND rao.active_ind=1) OR (rao.risk_adjustment_day_id=0)) )
   ORDER BY rad.risk_adjustment_id, rad.cc_day DESC
   HEAD rad.risk_adjustment_id
    index = locateval(num,1,patient_count,ra.risk_adjustment_id,reply->bedlist[num].
     risk_adjustment_id), pt_loaded = "N", details_loaded = "N",
    hold_cc_day = 0, dt_slash = " ", hosp_los_loaded = "N",
    icu_los_loaded = "N", last_act_tx_loaded = "N"
   HEAD rad.cc_day
    IF (pt_loaded="N")
     IF (rad.outcome_status >= 0)
      hold_cc_day = rad.cc_day
     ENDIF
     reply->bedlist[index].apache_dt_tm = rad.valid_from_dt_tm, reply->bedlist[index].aps_day_one =
     rad.aps_day1
     IF (rad.cc_end_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND rad.cc_beg_dt_tm < cnvtdatetime(curdate,curtime3))
      reply->bedlist[index].active_treatment_ind = rad.activetx_ind, reply->bedlist[index].
      last_active_treatment_ind = rad.activetx_ind, last_act_tx_loaded = "Y"
     ENDIF
     reply->bedlist[index].phys_res_pts = rad.phys_res_pts
     IF (rad.aps_day1 >= 0
      AND rad.phys_res_pts >= 0)
      reply->bedlist[index].apache_three_day_one = (rad.aps_day1+ rad.phys_res_pts)
     ELSE
      reply->bedlist[index].apache_three_day_one = - (1)
     ENDIF
     IF ((reply->bedlist[index].aps_current=- (1)))
      reply->bedlist[index].aps_current = rad.aps_score
      IF (rad.aps_score >= 0
       AND rad.phys_res_pts >= 0)
       reply->bedlist[index].apache_three = (rad.phys_res_pts+ rad.aps_score)
      ELSE
       reply->bedlist[index].apache_three = - (1)
      ENDIF
     ENDIF
     IF (rad.outcome_status >= 0)
      IF (last_act_tx_loaded="N")
       IF (rad.cc_day > 1)
        reply->bedlist[index].last_active_treatment_ind = 0, last_act_tx_loaded = "Y"
       ELSE
        reply->bedlist[index].last_active_treatment_ind = rad.activetx_ind, last_act_tx_loaded = "Y"
       ENDIF
      ENDIF
     ELSE
      reply->bedlist[index].error_code = rad.outcome_status, day_str = cnvtstring(rad.cc_day,3,0,r)
      IF (day_str="00*")
       day_str = cnvtstring(rad.cc_day,2,0,r)
       IF (day_str="0*")
        day_str = cnvtstring(rad.cc_day,1,0,r)
       ENDIF
      ENDIF
      CASE (rad.outcome_status)
       OF - (22001):
        f_text = concat("Valid Temperature required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22002):
        f_text = concat("Valid Heart Rate required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22003):
        f_text = concat("Valid Resp Rate required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22004):
        f_text = concat("Valid Mean BP required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22005):
        f_text = concat("Valid Sodium required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22006):
        f_text = concat("Valid Glucose required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22007):
        f_text = concat("Valid Albumin required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22008):
        f_text = concat("Valid Creatinine required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22009):
        f_text = concat("Valid BUN required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22010):
        f_text = concat("Valid WBC required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22011):
        f_text = concat("Valid Urine Output required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22012):
        f_text = concat("Valid Bilirubin required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22013):
        f_text = concat("Valid PCO2 & pH required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22014):
        f_text = concat("Valid Hematocrit required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22015):
        f_text = concat("Valid paO2 & pcO2 required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22017):
        f_text = concat("Valid values for meds, eyes, motor & verbal required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22018):
        f_text = concat("Valid Heart Rate, Resp Rate & Mean BP required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22019):
        f_text = concat("Minimum of 4 valid lab values required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23009):
        f_text = concat("Valid ICU Day required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23010):
        f_text = concat("Valid APS for today required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23011):
        f_text = concat("Valid APS for day one required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23013):
        f_text = concat("Valid DOB required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23014):
        f_text = concat("Valid Hosp Admit Date required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23015):
        f_text = concat("Valid ICU Admit Date required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23016):
        f_text = concat("Valid Admission Diagnosis required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23017):
        f_text = concat("Valid Admission Source required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23018):
        f_text = concat("Valid gender required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23019):
        f_text = concat("Valid Meds Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23020):
        f_text = concat("Valid Eye value (GCS) required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23021):
        f_text = concat("Valid Motor value (GCS) required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23022):
        f_text = concat("Valid Verbal value (GCS) required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23023):
        f_text = concat("Valid Thrombolytics Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23024):
        f_text = concat("Valid Other Immune Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23025):
        f_text = concat("Valid Hepatic Failure Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23026):
        f_text = concat("Valid Lymphoma Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23027):
        f_text = concat("Valid Metastatic Cancer Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23028):
        f_text = concat("Valid Leukemia Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23029):
        f_text = concat("Valid Immunosuppression Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23030):
        f_text = concat("Valid Cirrhosis Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23031):
        f_text = concat("Valid Elective Surgery Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23032):
        f_text = concat("Valid Active Treatment Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23033):
        f_text = concat("Valid chronic health information required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23034):
        f_text = concat("Valid readmission information required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23035):
        f_text = concat("Valid internal mammory artery information required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23036):
        f_text = "Unable to calculate predictions, Hosp admission date is too early.",reply->bedlist[
        index].non_predicted_pt_ind = 1
       OF - (23037):
        f_text = concat("Valid Eye value (GCS) required for Day 1(Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23038):
        f_text = concat("Valid Motor value (GCS) required for Day 1(Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23039):
        f_text = concat("Valid Verbal value (GCS) required for Day 1(Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23040):
        f_text = "Unable to calculate predictions, ICU admission date is too early.",reply->bedlist[
        index].non_predicted_pt_ind = 1
       OF - (23100):
        f_text = "Nonpredictive diagnosis, unable to calculate predictions.",reply->bedlist[index].
        non_predicted_pt_ind = 1
       OF - (23103):
        f_text = "Nonpredictive patient age (<16 years), unable to calculate predictions.",reply->
        bedlist[index].non_predicted_pt_ind = 1
       OF - (23110):
        f_text = "Invalid Age, unable to calculate predictions."
       OF - (23112):
        f_text = "Invalid FIO2 (ABG) required. Unable to calculate APACHE IV predictions."
       OF - (23113):
        f_text = "Valid Admission Source required. Unable to calculate APACHE IV predictions."
       OF - (23115):
        f_text = concat("Valid Creatinine required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23116):
        f_text = concat("Valid Eject FX information required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23117):
        f_text = "Nonpredictive admission source (ICU), unable to calculate predictions.",reply->
        bedlist[index].non_predicted_pt_ind = 1
       OF - (23118):
        f_text = concat("Valid Dicharge Location required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23119):
        f_text = concat("Valid Visit Number information required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23120):
        f_text = concat("Valid AMI Location information required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       ELSE
        f_text = concat("An unrecognized error occurred - error number ",cnvtstring(reply->bedlist[
          index].error_code)," (Day ",trim(day_str),"). Unable to calculate predictions.")
      ENDCASE
      reply->bedlist[index].error_string = f_text
     ENDIF
    ENDIF
   DETAIL
    IF (details_loaded="N"
     AND rao.risk_adjustment_day_id > 0)
     CASE (rao.equation_name)
      OF "TISS_TMR":
       reply->bedlist[index].tomorrow_tiss_predict = round(rao.outcome_value,0)
      OF "VENT_DAYS":
       IF (rad.cc_day=1)
        reply->bedlist[index].predicted_vent_days = round(rao.outcome_value,2)
       ENDIF
      OF "ICU_DEATH":
       reply->bedlist[index].icu_risk_of_death = round((rao.outcome_value * 100),0)
      OF "HSP_DEATH":
       reply->bedlist[index].hosp_risk_of_death = round((rao.outcome_value * 100),0)
      OF "SWAN_GANZ":
       reply->bedlist[index].risk_of_pac = round((rao.outcome_value * 100),0)
      OF "DSCHG_ALIVE_TMR":
       reply->bedlist[index].tomorrow_discharge_alive = round((rao.outcome_value * 100),0)
      OF "NTL_ACT_DAY1":
       IF (rad.activetx_ind=1
        AND rad.cc_day=1)
        reply->bedlist[index].today_risk_active_tx = round((rao.outcome_value * 100),0)
       ENDIF
      OF "ACT_ICU_EVER":
       IF (rad.activetx_ind=0
        AND rad.cc_day=1)
        reply->bedlist[index].today_risk_active_tx = round((rao.outcome_value * 100),0)
       ENDIF
      OF "1ST_TISS":
       IF (rad.cc_day=1)
        reply->bedlist[index].today_tiss_predict = round(rao.outcome_value,0)
       ENDIF
      OF "ACT_TMR":
       reply->bedlist[index].tomorrow_risk_active_tx = round((rao.outcome_value * 100),0)
     ENDCASE
    ELSE
     IF (rao.equation_name="ACT_TMR"
      AND hold_cc_day > 1
      AND (rad.cc_day=(hold_cc_day - 1))
      AND details_loaded="Y"
      AND rad.outcome_status >= 0)
      reply->bedlist[index].today_risk_active_tx = round((rao.outcome_value * 100),0)
     ELSEIF (rao.equation_name="DSCHG_ALIVE_TMR"
      AND hold_cc_day > 1
      AND (rad.cc_day=(hold_cc_day - 1))
      AND details_loaded="Y"
      AND rad.outcome_status >= 0)
      reply->bedlist[index].discharge_alive = round((rao.outcome_value * 100),0)
     ELSEIF (rao.equation_name="TISS_TMR"
      AND hold_cc_day > 1
      AND (rad.cc_day=(hold_cc_day - 1))
      AND details_loaded="Y"
      AND rad.outcome_status >= 0)
      reply->bedlist[index].today_tiss_predict = round(rao.outcome_value,0)
     ENDIF
    ENDIF
    IF (rad.cc_day=5
     AND rad.outcome_status >= 0)
     IF (rao.equation_name="NTL_ICU_LOS")
      reply->bedlist[index].day_5_icu_los = round(rao.outcome_value,2)
     ENDIF
    ELSEIF (rad.cc_day=1
     AND rad.outcome_status >= 0)
     IF (rao.equation_name="HSP_LOS"
      AND hosp_los_loaded="N")
      reply->bedlist[index].predicted_hosp_los = round(rao.outcome_value,2)
     ELSEIF (rao.equation_name="ICU_LOS"
      AND icu_los_loaded="N")
      reply->bedlist[index].predicted_icu_los = round(rao.outcome_value,2)
     ELSEIF (rao.equation_name="VENT_DAYS")
      reply->bedlist[index].predicted_vent_days = round(rao.outcome_value,2)
     ENDIF
    ENDIF
   FOOT  rad.cc_day
    IF (rad.cc_day=1
     AND (reply->bedlist[index].admit_diagnosis IN ("CARDARREST", "POISON", "NTCOMA", "CARDSHOCK",
    "PAPMUSCLE",
    "S-VALVAM", "S-VALVAO", "S-VALVMI", "S-VALVMR", "S-VALVPULM",
    "SVALVTRI", "S-CABGAOV", "S-CABGMIV", "S-CABGMVR", "S-CABGVALV",
    "S-LIVTRAN", "S-AAANEUUP", "S-TAANEURU", "S-CABG", "S-CABGREDO",
    "S-CABGROTH", "S-CABGWOTH")))
     reply->bedlist[index].today_risk_active_tx = 100
    ENDIF
    IF (rad.outcome_status >= 0)
     details_loaded = "Y"
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = loop_cnt),
    risk_adjustment_event rae,
    risk_adjustment ra
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
    JOIN (ra
    WHERE expand(num,nstart,(nstart+ (batch_size - 1)),ra.risk_adjustment_id,reply->bedlist[num].
     risk_adjustment_id)
     AND ra.active_ind=1)
    JOIN (rae
    WHERE rae.risk_adjustment_id=ra.risk_adjustment_id
     AND rae.active_ind=1)
   ORDER BY ra.risk_adjustment_id
   HEAD ra.risk_adjustment_id
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), index = locateval(num,1,patient_count,ra.risk_adjustment_id,reply->bedlist[num].
     risk_adjustment_id), stat = alterlist(reply->bedlist[index].treatments_events,cnt),
    reply->bedlist[index].treatments_events[cnt].treatment_event_flag = "E", reply->bedlist[index].
    treatments_events[cnt].treatment_event_disp = trim(uar_get_code_display(rae
      .sentinel_event_code_cd))
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = loop_cnt),
    risk_adjustment ra,
    risk_adjustment_day rad
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
    JOIN (ra
    WHERE expand(num,nstart,(nstart+ (batch_size - 1)),ra.risk_adjustment_id,reply->bedlist[num].
     risk_adjustment_id)
     AND ra.active_ind=1)
    JOIN (rad
    WHERE rad.risk_adjustment_id=ra.risk_adjustment_id
     AND rad.active_ind=1
     AND ((rad.risk_adjustment_day_id+ 0) > 0))
   ORDER BY ra.risk_adjustment_id, rad.cc_day DESC
   HEAD REPORT
    found_day = 0
   HEAD ra.risk_adjustment_id
    index = locateval(num,1,patient_count,ra.risk_adjustment_id,reply->bedlist[num].
     risk_adjustment_id)
    IF (found_day=0)
     found_day = 1
     IF (rad.cc_end_dt_tm > cnvtdatetime(curdate,curtime3))
      reply->bedlist[index].last_cc_day_beg_dt_tm = rad.cc_beg_dt_tm, reply->bedlist[index].
      last_cc_day_end_dt_tm = rad.cc_end_dt_tm
     ELSE
      reply->bedlist[index].last_cc_day_beg_dt_tm = cnvtdatetime(curdate,curtime3), reply->bedlist[
      index].last_cc_day_end_dt_tm = cnvtdatetime(curdate,curtime3)
     ENDIF
    ENDIF
   DETAIL
    found_day = 1
   FOOT  ra.risk_adjustment_id
    found_day = 0
   WITH nocounter
  ;end select
  CALL echo("ABOUT TO DO TISS QUERY")
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = loop_cnt),
    risk_adj_tiss rat,
    code_value cv1
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
    JOIN (rat
    WHERE expand(num,nstart,(nstart+ (batch_size - 1)),rat.risk_adjustment_id,reply->bedlist[num].
     risk_adjustment_id)
     AND rat.active_ind=1)
    JOIN (cv1
    WHERE cv1.code_value=rat.tiss_cd
     AND ((cv1.active_ind+ 0)=1))
   ORDER BY rat.risk_adjustment_id, rat.tiss_beg_dt_tm DESC, rat.tiss_cd
   HEAD rat.risk_adjustment_id
    index = locateval(num,1,patient_count,rat.risk_adjustment_id,reply->bedlist[num].
     risk_adjustment_id), raw_tiss_score = 0.0,
    CALL echo(build("IN TISS D.SEQ HEAD FOR risk_adjustment_id= ",rat.risk_adjustment_id))
   HEAD rat.tiss_cd
    CALL echo(build("TISS = ",cv1.display)), discrete = substring(2,1,cv1.definition)
    IF (discrete="N")
     this_score = 0
     IF (rat.tiss_beg_dt_tm <= cnvtdatetime(reply->bedlist[index].last_cc_day_end_dt_tm)
      AND rat.tiss_end_dt_tm >= cnvtdatetime(reply->bedlist[index].last_cc_day_beg_dt_tm))
      this_score = cnvtint(substring(3,1,cv1.definition)), raw_tiss_score = (raw_tiss_score+
      this_score)
     ENDIF
    ENDIF
   DETAIL
    IF (discrete="Y")
     IF (rat.tiss_beg_dt_tm <= cnvtdatetime(reply->bedlist[index].last_cc_day_end_dt_tm)
      AND rat.tiss_end_dt_tm >= cnvtdatetime(reply->bedlist[index].last_cc_day_beg_dt_tm))
      this_score = 0, this_score = cnvtint(substring(3,1,cv1.definition)), raw_tiss_score = (
      raw_tiss_score+ this_score)
     ENDIF
    ENDIF
   FOOT  rat.risk_adjustment_id
    reply->bedlist[index].raw_tiss = raw_tiss_score
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = loop_cnt),
    risk_adjustment ra,
    prsnl p
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
    JOIN (ra
    WHERE expand(num,nstart,(nstart+ (batch_size - 1)),ra.risk_adjustment_id,reply->bedlist[num].
     risk_adjustment_id))
    JOIN (p
    WHERE p.person_id=ra.adm_doc_id
     AND p.person_id > 0)
   DETAIL
    index = locateval(num,1,patient_count,ra.risk_adjustment_id,reply->bedlist[num].
     risk_adjustment_id), reply->bedlist[index].attend_doc = p.name_full_formatted, reply->bedlist[
    index].attend_doc_init = concat(trim(substring(1,1,p.name_first_key)),trim(substring(1,1,p
       .name_last_key)))
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = loop_cnt),
    risk_adjustment ra,
    encntr_prsnl_reltn epr,
    prsnl p
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
    JOIN (ra
    WHERE expand(num,nstart,(nstart+ (batch_size - 1)),ra.risk_adjustment_id,reply->bedlist[num].
     risk_adjustment_id)
     AND ra.adm_doc_id <= 0)
    JOIN (epr
    WHERE epr.encntr_id=ra.encntr_id
     AND epr.encntr_prsnl_r_cd=attend_doc_cd
     AND epr.active_ind=1
     AND epr.expiration_ind=0)
    JOIN (p
    WHERE p.person_id=epr.prsnl_person_id
     AND p.person_id > 0)
   DETAIL
    index = locateval(num,1,patient_count,ra.risk_adjustment_id,reply->bedlist[num].
     risk_adjustment_id), reply->bedlist[index].attend_doc = p.name_full_formatted, reply->bedlist[
    index].attend_doc_init = concat(trim(substring(1,1,p.name_first_key)),trim(substring(1,1,p
       .name_last_key)))
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = loop_cnt),
    risk_adjustment_day rad
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
    JOIN (rad
    WHERE expand(num,nstart,(nstart+ (batch_size - 1)),rad.risk_adjustment_id,reply->bedlist[num].
     risk_adjustment_id)
     AND ((rad.risk_adjustment_day_id+ 0) > 0)
     AND rad.active_ind=1)
   ORDER BY rad.risk_adjustment_id, rad.cc_day
   HEAD rad.risk_adjustment_id
    missed_day_found = "N", compare_nbr = 1, missed_day = 0,
    index = locateval(num,1,patient_count,rad.risk_adjustment_id,reply->bedlist[num].
     risk_adjustment_id), skip = "Y"
    IF ((reply->bedlist[index].error_code=- (1)))
     skip = "N"
    ENDIF
   DETAIL
    IF (skip="N")
     IF (missed_day_found="N")
      IF (rad.cc_day=compare_nbr)
       compare_nbr = (compare_nbr+ 1)
      ELSE
       missed_day = compare_nbr, missed_day_found = "Y", day_str = cnvtstring(compare_nbr,3,0,r)
      ENDIF
     ENDIF
    ENDIF
   FOOT  rad.risk_adjustment_id
    IF (skip="N")
     IF (missed_day > 0
      AND missed_day_found="Y")
      IF (day_str="00*")
       day_str = cnvtstring(missed_day,2,0,r)
       IF (day_str="0*")
        day_str = cnvtstring(missed_day,1,0,r)
       ENDIF
      ENDIF
      reply->bedlist[index].error_string = concat("Missing data for day ",day_str,
       ". Unable to calculate predictions.")
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->bedlist,patient_count)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#4099_populate_bedlist_with_ra_data_exit
#9999_exit_program
 CALL echorecord(reply)
 SET reply->status_data.subeventstatus[1].operationname = "QUERY"
 SET reply->status_data.subeventstatus[1].targetobjectname = "DCP_APACHE_BEDLIST"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = failed_text
END GO
