CREATE PROGRAM bed_ens_srvres_hier:dba
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
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 inst_code_value = f8
    1 error_msg = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD disc_type(
   1 disc_type_list[*]
     2 disc_type_code_value = f8
     2 disc_type_disp = vc
     2 disc_type_dispkey = vc
     2 disc_type_mean = vc
 )
 RECORD act_type(
   1 act_type_list[*]
     2 act_type_code_value = f8
     2 act_type_disp = vc
     2 act_type_dispkey = vc
     2 act_type_mean = vc
 )
 RECORD act_subtype(
   1 act_subtype_list[*]
     2 act_subtype_code_value = f8
     2 act_subtype_disp = vc
     2 act_subtype_dispkey = vc
     2 act_subtype_mean = vc
 )
 RECORD prio(
   1 prio_list[*]
     2 prio_code_value = f8
     2 prio_disp = vc
     2 prio_dispkey = vc
     2 prio_mean = vc
 )
 RECORD spectype(
   1 spectype_list[*]
     2 spectype_code_value = f8
     2 spectype_disp = vc
     2 spectype_dispkey = vc
     2 spectype_mean = vc
 )
 RECORD age(
   1 age_list[*]
     2 age_code_value = f8
     2 age_disp = vc
     2 age_dispkey = vc
     2 age_mean = vc
 )
 RECORD sres(
   1 sres_list[*]
     2 disp = vc
     2 code = f8
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 DECLARE lib_search_name = vc
 SET org_prefix = fillstring(4," ")
 SET s_disc_type_cd = 0.0
 SET s_act_type_cd = 0.0
 SET s_act_subtype_cd = 0.0
 SET s_prio_cd = 0.0
 SET s_spectype_cd = 0.0
 SET s_age_cd = 0.0
 SET s_disc_type_mean = fillstring(12," ")
 SET s_act_type_mean = fillstring(12," ")
 SET s_act_subtype_mean = fillstring(12," ")
 SET s_prio_mean = fillstring(12," ")
 SET s_spectype_mean = fillstring(12," ")
 SET s_age_mean = fillstring(12," ")
 SET s_disc_type_dispkey = fillstring(40," ")
 SET s_act_type_dispkey = fillstring(40," ")
 SET s_act_subtype_dispkey = fillstring(40," ")
 SET s_prio_dispkey = fillstring(40," ")
 SET s_spectype_dispkey = fillstring(40," ")
 SET s_age_dispkey = fillstring(40," ")
 SET deptcnt = 0
 SET sectcnt = 0
 SET subsectcnt = 0
 SET rescnt = 0
 SET calcnt = 0
 SET error_flag = "N"
 SET org_name = fillstring(100," ")
 SET org_name_key = fillstring(100," ")
 SET srescnt = 0
 SET active_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="ACTIVE")
  ORDER BY cv.code_value
  HEAD cv.code_value
   active_cd = cv.code_value
  WITH nocounter
 ;end select
 SET inactive_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="INACTIVE")
  ORDER BY cv.code_value
  HEAD cv.code_value
   inactive_cd = cv.code_value
  WITH nocounter
 ;end select
 SET auth_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=8
    AND cv.cdf_meaning="AUTH")
  ORDER BY cv.code_value
  HEAD cv.code_value
   auth_cd = cv.code_value
  WITH nocounter
 ;end select
 SET disccnt = 0
 SET rad_disc_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.active_ind=1)
  ORDER BY cv.code_value
  HEAD cv.code_value
   disccnt = (disccnt+ 1), stat = alterlist(disc_type->disc_type_list,disccnt), disc_type->
   disc_type_list[disccnt].disc_type_code_value = cv.code_value,
   disc_type->disc_type_list[disccnt].disc_type_disp = cv.display, disc_type->disc_type_list[disccnt]
   .disc_type_dispkey = cv.display_key, disc_type->disc_type_list[disccnt].disc_type_mean = cv
   .cdf_meaning
   IF (cv.cdf_meaning="RADIOLOGY")
    rad_disc_type_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET rad_act_type_cd = 0.0
 SET actcnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.active_ind=1)
  ORDER BY cv.code_value
  HEAD cv.code_value
   actcnt = (actcnt+ 1), stat = alterlist(act_type->act_type_list,actcnt), act_type->act_type_list[
   actcnt].act_type_code_value = cv.code_value,
   act_type->act_type_list[actcnt].act_type_disp = cv.display, act_type->act_type_list[actcnt].
   act_type_dispkey = cv.display_key, act_type->act_type_list[actcnt].act_type_mean = cv.cdf_meaning
   IF (cv.cdf_meaning="RADIOLOGY")
    rad_act_type_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET asubcnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=5801
    AND cv.active_ind=1)
  ORDER BY cv.code_value
  HEAD cv.code_value
   asubcnt = (asubcnt+ 1), stat = alterlist(act_subtype->act_subtype_list,asubcnt), act_subtype->
   act_subtype_list[asubcnt].act_subtype_code_value = cv.code_value,
   act_subtype->act_subtype_list[asubcnt].act_subtype_disp = cv.display, act_subtype->
   act_subtype_list[asubcnt].act_subtype_dispkey = cv.display_key, act_subtype->act_subtype_list[
   asubcnt].act_subtype_mean = cv.cdf_meaning
  WITH nocounter
 ;end select
 SET priocnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=1905
    AND cv.active_ind=1)
  ORDER BY cv.code_value
  HEAD cv.code_value
   priocnt = (priocnt+ 1), stat = alterlist(prio->prio_list,priocnt), prio->prio_list[priocnt].
   prio_code_value = cv.code_value,
   prio->prio_list[priocnt].prio_disp = cv.display, prio->prio_list[priocnt].prio_dispkey = cv
   .display_key, prio->prio_list[priocnt].prio_mean = cv.cdf_meaning
  WITH nocounter
 ;end select
 SET spectypecnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=2052
    AND cv.active_ind=1)
  ORDER BY cv.code_value
  HEAD cv.code_value
   spectypecnt = (spectypecnt+ 1), stat = alterlist(spectype->spectype_list,spectypecnt), spectype->
   spectype_list[spectypecnt].spectype_code_value = cv.code_value,
   spectype->spectype_list[spectypecnt].spectype_disp = cv.display, spectype->spectype_list[
   spectypecnt].spectype_dispkey = cv.display_key, spectype->spectype_list[spectypecnt].spectype_mean
    = cv.cdf_meaning
  WITH nocounter
 ;end select
 SET agecnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=340
    AND cv.active_ind=1)
  ORDER BY cv.code_value
  HEAD cv.code_value
   agecnt = (agecnt+ 1), stat = alterlist(age->age_list,agecnt), age->age_list[agecnt].age_code_value
    = cv.code_value,
   age->age_list[agecnt].age_disp = cv.display, age->age_list[agecnt].age_dispkey = cv.display_key,
   age->age_list[agecnt].age_mean = cv.cdf_meaning
  WITH nocounter
 ;end select
 SET inst_type_cd = 0.0
 SET dept_type_cd = 0.0
 SET sect_type_cd = 0.0
 SET subsect_type_cd = 0.0
 SET instr_type_cd = 0.0
 SET bench_type_cd = 0.0
 SET exam_type_cd = 0.0
 SET lib_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=223
   AND cv.active_ind=1
   AND cv.cdf_meaning IN ("INSTITUTION", "DEPARTMENT", "SECTION", "SUBSECTION", "INSTRUMENT",
  "BENCH", "RADEXAMROOM", "LIBGRP")
  DETAIL
   CASE (cv.cdf_meaning)
    OF "INSTITUTION":
     inst_type_cd = cv.code_value
    OF "DEPARTMENT":
     dept_type_cd = cv.code_value
    OF "SECTION":
     sect_type_cd = cv.code_value
    OF "SUBSECTION":
     subsect_type_cd = cv.code_value
    OF "INSTRUMENT":
     instr_type_cd = cv.code_value
    OF "BENCH":
     bench_type_cd = cv.code_value
    OF "RADEXAMROOM":
     exam_type_cd = cv.code_value
    OF "LIBGRP":
     lib_type_cd = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SET srvarea_cd = 0.0
 SET locview_cd = 0.0
 SET facility_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=222
   AND cv.active_ind=1
   AND cv.cdf_meaning IN ("SRVAREA", "LAB", "FACILITY")
  DETAIL
   CASE (cv.cdf_meaning)
    OF "SRVAREA":
     srvarea_cd = cv.code_value
    OF "LAB":
     locview_cd = cv.code_value
    OF "FACILITY":
     facility_cd = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SET lab_cd = 0.0
 SET rad_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=202
   AND cv.active_ind=1
   AND cv.cdf_meaning IN ("LAB", "RAD")
  DETAIL
   CASE (cv.cdf_meaning)
    OF "LAB":
     lab_cd = cv.code_value
    OF "RAD":
     rad_cd = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 IF (((active_cd=0) OR (((inactive_cd=0) OR (auth_cd=0)) )) )
  SET error_flag = "T"
  SET error_msg = concat("Error retrieving required code value (active, inactive, auth)")
  GO TO exit_script
 ENDIF
 IF (((inst_type_cd=0) OR (((dept_type_cd=0) OR (((sect_type_cd=0) OR (((subsect_type_cd=0) OR (((
 instr_type_cd=0) OR (((bench_type_cd=0) OR (facility_cd=0)) )) )) )) )) )) )
  SET error_flag = "T"
  SET error_msg = concat("Error retrieving required code value (CS223)")
  GO TO exit_script
 ENDIF
 IF (((srvarea_cd=0) OR (((locview_cd=0) OR (lab_cd=0)) )) )
  SET error_flag = "T"
  SET error_msg = concat("Error retrieving required code value (CS202, CS223)")
  GO TO exit_script
 ENDIF
 SET x1 = size(request->srh.dept,5)
 FOR (ss = 1 TO x1)
   IF ((request->srh.dept[ss].disc_type_code_value=0))
    SET s_disc_type_mean = request->srh.dept[ss].disc_type_mean
    SET s_disc_type_dispkey = cnvtupper(cnvtalphanum(request->srh.dept[ss].disc_type_disp))
    CALL get_disc_type_code(ss)
    SET request->srh.dept[ss].disc_type_code_value = s_disc_type_cd
   ENDIF
   IF ((request->srh.dept[ss].act_type_code_value=0))
    SET s_act_type_mean = request->srh.dept[ss].act_type_mean
    SET s_act_type_dispkey = cnvtupper(cnvtalphanum(request->srh.dept[ss].act_type_disp))
    CALL get_act_type_code(ss)
    SET request->srh.dept[ss].act_type_code_value = s_act_type_cd
   ENDIF
   IF ((request->srh.dept[ss].act_subtype_code_value=0))
    SET s_act_subtype_mean = request->srh.dept[ss].act_subtype_mean
    SET s_act_subtype_dispkey = cnvtupper(cnvtalphanum(request->srh.dept[ss].act_subtype_disp))
    CALL get_act_subtype_code(ss)
    SET request->srh.dept[ss].act_subtype_code_value = s_act_subtype_cd
   ENDIF
   SET x2 = size(request->srh.dept[ss].sect,5)
   FOR (tt = 1 TO x2)
     IF ((request->srh.dept[ss].sect[tt].disc_type_code_value=0))
      SET s_disc_type_mean = request->srh.dept[ss].sect[tt].disc_type_mean
      SET s_disc_type_dispkey = cnvtupper(cnvtalphanum(request->srh.dept[ss].sect[tt].disc_type_disp)
       )
      CALL get_disc_type_code(tt)
      SET request->srh.dept[ss].sect[tt].disc_type_code_value = s_disc_type_cd
     ENDIF
     IF ((request->srh.dept[ss].sect[tt].act_type_code_value=0))
      SET s_act_type_mean = request->srh.dept[ss].sect[tt].act_type_mean
      SET s_act_type_dispkey = cnvtupper(cnvtalphanum(request->srh.dept[ss].sect[tt].act_type_disp))
      CALL get_act_type_code(tt)
      SET request->srh.dept[ss].sect[tt].act_type_code_value = s_act_type_cd
     ENDIF
     IF ((request->srh.dept[ss].sect[tt].act_subtype_code_value=0))
      SET s_act_subtype_mean = request->srh.dept[ss].sect[tt].act_subtype_mean
      SET s_act_subtype_dispkey = cnvtupper(cnvtalphanum(request->srh.dept[ss].sect[tt].
        act_subtype_disp))
      CALL get_act_subtype_code(tt)
      SET request->srh.dept[ss].sect[tt].act_subtype_code_value = s_act_subtype_cd
     ENDIF
     SET x3 = size(request->srh.dept[ss].sect[tt].subsect,5)
     FOR (uu = 1 TO x3)
       IF ((request->srh.dept[ss].sect[tt].subsect[uu].disc_type_code_value=0))
        SET s_disc_type_mean = request->srh.dept[ss].sect[tt].subsect[uu].disc_type_mean
        SET s_disc_type_dispkey = cnvtupper(cnvtalphanum(request->srh.dept[ss].sect[tt].subsect[uu].
          disc_type_disp))
        CALL get_disc_type_code(uu)
        SET request->srh.dept[ss].sect[tt].subsect[uu].disc_type_code_value = s_disc_type_cd
       ENDIF
       IF ((request->srh.dept[ss].sect[tt].subsect[uu].act_type_code_value=0))
        SET s_act_type_mean = request->srh.dept[ss].sect[tt].subsect[uu].act_type_mean
        SET s_act_type_dispkey = cnvtupper(cnvtalphanum(request->srh.dept[ss].sect[tt].subsect[uu].
          act_type_disp))
        CALL get_act_type_code(uu)
        SET request->srh.dept[ss].sect[tt].subsect[uu].act_type_code_value = s_act_type_cd
       ENDIF
       IF ((request->srh.dept[ss].sect[tt].subsect[uu].act_subtype_code_value=0))
        SET s_act_subtype_dispkey = cnvtupper(cnvtalphanum(request->srh.dept[ss].sect[tt].subsect[uu]
          .act_subtype_disp))
        SET s_act_subtype_mean = request->srh.dept[ss].sect[tt].subsect[uu].act_subtype_mean
        CALL get_act_subtype_code(uu)
        SET request->srh.dept[ss].sect[tt].subsect[uu].act_subtype_code_value = s_act_subtype_cd
       ENDIF
       SET x4 = size(request->srh.dept[ss].sect[tt].subsect[uu].res,5)
       FOR (vv = 1 TO x4)
         IF ((request->srh.dept[ss].sect[tt].subsect[uu].res[vv].disc_type_code_value=0))
          SET s_disc_type_mean = request->srh.dept[ss].sect[tt].subsect[uu].res[vv].disc_type_mean
          SET s_disc_type_dispkey = cnvtupper(cnvtalphanum(request->srh.dept[ss].sect[tt].subsect[uu]
            .res[vv].disc_type_disp))
          CALL get_disc_type_code(vv)
          SET request->srh.dept[ss].sect[tt].subsect[uu].res[vv].disc_type_code_value =
          s_disc_type_cd
         ENDIF
         IF ((request->srh.dept[ss].sect[tt].subsect[uu].res[vv].act_type_code_value=0))
          SET s_act_type_mean = request->srh.dept[ss].sect[tt].subsect[uu].res[vv].act_type_mean
          SET s_act_type_dispkey = cnvtupper(cnvtalphanum(request->srh.dept[ss].sect[tt].subsect[uu].
            res[vv].act_type_disp))
          CALL get_act_type_code(vv)
          SET request->srh.dept[ss].sect[tt].subsect[uu].res[vv].act_type_code_value = s_act_type_cd
         ENDIF
         IF ((request->srh.dept[ss].sect[tt].subsect[uu].res[vv].act_subtype_code_value=0))
          SET s_act_subtype_mean = request->srh.dept[ss].sect[tt].subsect[uu].res[vv].
          act_subtype_mean
          SET s_act_subtype_dispkey = cnvtupper(cnvtalphanum(request->srh.dept[ss].sect[tt].subsect[
            uu].res[vv].act_subtype_disp))
          CALL get_act_subtype_code(vv)
          SET request->srh.dept[ss].sect[tt].subsect[uu].res[vv].act_subtype_code_value =
          s_act_subtype_cd
         ENDIF
         SET x5 = size(request->srh.dept[ss].sect[tt].subsect[uu].res[vv].cal,5)
         FOR (ww = 1 TO x5)
          SET x6 = size(request->srh.dept[ss].sect[tt].subsect[uu].res[vv].cal[ww].cal_det,5)
          FOR (xxx = 1 TO x6)
            IF ((request->srh.dept[ss].sect[tt].subsect[uu].res[vv].cal[ww].cal_det[xxx].
            priority_code_value=0))
             SET s_prio_mean = request->srh.dept[ss].sect[tt].subsect[uu].res[vv].cal[ww].cal_det[xxx
             ].priority_mean
             SET s_prio_dispkey = cnvtupper(cnvtalphanum(request->srh.dept[ss].sect[tt].subsect[uu].
               res[vv].cal[ww].cal_det[xxx].priority_disp))
             CALL get_prio_code(xxx)
             SET request->srh.dept[ss].sect[tt].subsect[uu].res[vv].cal[ww].cal_det[xxx].
             priority_code_value = s_prio_cd
            ENDIF
            IF ((request->srh.dept[ss].sect[tt].subsect[uu].res[vv].cal[ww].cal_det[xxx].
            specimen_type_code_value=0))
             SET s_spectype_mean = request->srh.dept[ss].sect[tt].subsect[uu].res[vv].cal[ww].
             cal_det[xxx].specimen_type_mean
             SET s_spectype_dispkey = cnvtupper(cnvtalphanum(request->srh.dept[ss].sect[tt].subsect[
               uu].res[vv].cal[ww].cal_det[xxx].specimen_type_disp))
             CALL get_spectype_code(xxx)
             SET request->srh.dept[ss].sect[tt].subsect[uu].res[vv].cal[ww].cal_det[xxx].
             specimen_type_code_value = s_spectype_cd
            ENDIF
            IF ((request->srh.dept[ss].sect[tt].subsect[uu].res[vv].cal[ww].cal_det[xxx].
            age_from_code_value=0))
             SET s_age_mean = request->srh.dept[ss].sect[tt].subsect[uu].res[vv].cal[ww].cal_det[xxx]
             .age_from_mean
             SET s_age_dispkey = cnvtupper(cnvtalphanum(request->srh.dept[ss].sect[tt].subsect[uu].
               res[vv].cal[ww].cal_det[xxx].age_from_disp))
             CALL get_age_code(xxx)
             SET request->srh.dept[ss].sect[tt].subsect[uu].res[vv].cal[ww].cal_det[xxx].
             age_from_code_value = s_age_cd
            ENDIF
            IF ((request->srh.dept[ss].sect[tt].subsect[uu].res[vv].cal[ww].cal_det[xxx].
            age_to_code_value=0))
             SET s_age_mean = request->srh.dept[ss].sect[tt].subsect[uu].res[vv].cal[ww].cal_det[xxx]
             .age_to_mean
             SET s_age_dispkey = cnvtupper(cnvtalphanum(request->srh.dept[ss].sect[tt].subsect[uu].
               res[vv].cal[ww].cal_det[xxx].age_to_disp))
             CALL get_age_code(xxx)
             SET request->srh.dept[ss].sect[tt].subsect[uu].res[vv].cal[ww].cal_det[xxx].
             age_to_code_value = s_age_cd
            ENDIF
          ENDFOR
         ENDFOR
       ENDFOR
     ENDFOR
   ENDFOR
 ENDFOR
 SET org_id = 0.0
 SELECT DISTINCT INTO "nl:"
  FROM organization o
  PLAN (o
   WHERE (o.organization_id=request->srh.org_id)
    AND o.active_ind=1)
  ORDER BY o.organization_id
  HEAD o.organization_id
   org_id = o.organization_id, org_name = o.org_name, org_name_key = o.org_name_key
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "T"
  SET error_msg = concat("Unable to retrieve organization: ",cnvtstring(request->srh.org_id))
  GO TO exit_script
 ENDIF
 SET institution_cd = 0.0
 DECLARE institution_disp = vc
 DECLARE institution_desc = vc
 DECLARE institution_def = vc
 IF ((request->srh.inst_code_value > 0))
  SELECT DISTINCT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE (cv.code_value=request->srh.inst_code_value)
     AND cv.code_set=221
     AND cv.active_ind=1)
   ORDER BY cv.code_value
   HEAD cv.code_value
    institution_cd = cv.code_value, institution_disp = cv.display, institution_desc = cv.description,
    institution_def = cv.definition
   WITH nocounter
  ;end select
 ELSE
  SELECT DISTINCT INTO "nl:"
   FROM service_resource s,
    code_value c
   PLAN (s
    WHERE s.organization_id=org_id
     AND s.service_resource_type_cd=inst_type_cd
     AND s.active_ind=1)
    JOIN (c
    WHERE c.code_value=s.service_resource_cd
     AND c.code_set=221)
   ORDER BY s.service_resource_cd
   HEAD s.service_resource_cd
    institution_cd = s.service_resource_cd, institution_disp = c.display, institution_desc = c
    .description,
    institution_def = c.definition
   WITH nocounter
  ;end select
 ENDIF
 IF (institution_cd > 0)
  SET reply->inst_code_value = institution_cd
 ELSE
  SELECT INTO "nl:"
   FROM location l,
    code_value cv
   PLAN (l
    WHERE l.organization_id=org_id
     AND l.location_type_cd=facility_cd)
    JOIN (cv
    WHERE cv.code_value=l.location_cd)
   DETAIL
    institution_disp = cv.display, institution_desc = cv.description, institution_def = cv.definition
   WITH nocounter
  ;end select
 ENDIF
 IF (institution_cd=0)
  SET request_cv->cd_value_list[1].action_flag = 1
  SET request_cv->cd_value_list[1].code_set = 221
  SET request_cv->cd_value_list[1].display = substring(1,40,institution_disp)
  SET request_cv->cd_value_list[1].description = substring(1,60,institution_desc)
  SET request_cv->cd_value_list[1].cdf_meaning = "INSTITUTION"
  SET request_cv->cd_value_list[1].active_ind = 1
  SET trace = recpersist
  EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
  SET new_sr_code = 0.0
  IF ((reply_cv->status_data.status="S")
   AND (reply_cv->qual[1].code_value > 0))
   SET new_sr_code = reply_cv->qual[1].code_value
   SET institution_cd = new_sr_code
   INSERT  FROM service_resource s
    SET s.service_resource_cd = new_sr_code, s.location_cd = 0, s.service_resource_type_cd =
     inst_type_cd,
     s.discipline_type_cd = 0, s.activity_type_cd = 0, s.activity_subtype_cd = 0,
     s.pharmacy_type_cd = 0, s.cs_login_loc_cd = 0, s.accn_site_prefix = "",
     s.active_ind = 1, s.autologin_ind = 0, s.dispatch_download_ind = 0,
     s.inventory_resource_cd = 0, s.pat_care_loc_ind = 0, s.active_status_cd = active_cd,
     s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s.active_status_prsnl_id = 0, s
     .except_exist_ind = 0,
     s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), s.end_effective_dt_tm = cnvtdatetime(
      "31-dec-2100 00:00:00.00"), s.organization_id = org_id,
     s.data_status_cd = auth_cd, s.data_status_prsnl_id = 0, s.data_status_dt_tm = cnvtdatetime(
      curdate,curtime3),
     s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task =
     reqinfo->updt_task,
     s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = 0, s.inv_location_cd = 0
    WITH nocounter, dontexist
   ;end insert
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Unable to add institution to service_resource for organization: ",
     institution_disp)
    GO TO exit_script
   ENDIF
  ELSE
   SET error_flag = "T"
   SET error_msg = concat("Unable to add institution to CS221 for organization: ",institution_disp)
   GO TO exit_script
  ENDIF
 ELSEIF ((request->srh.action_flag=2))
  SET request_cv->cd_value_list[1].action_flag = 2
  SET request_cv->cd_value_list[1].code_set = 221
  SET request_cv->cd_value_list[1].code_value = request->srh.inst_code_value
  SET request_cv->cd_value_list[1].display = substring(1,40,request->srh.inst_disp)
  SET request_cv->cd_value_list[1].description = substring(1,60,request->srh.inst_desc)
  SET request_cv->cd_value_list[1].cdf_meaning = "INSTITUTION"
  SET request_cv->cd_value_list[1].active_ind = 1
  SET trace = recpersist
  EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
  IF ((reply_cv->status_data.status != "S"))
   SET error_flag = "T"
   SET error_msg = concat("Unable to update institution: ",request->srh.inst_disp)
   GO TO exit_script
  ENDIF
 ELSEIF ((request->srh.action_flag=3))
  CALL del_inst(1)
  IF (error_flag="T")
   SET error_msg = concat(error_text,request->srh.inst_disp)
   GO TO exit_script
  ENDIF
 ENDIF
 SET xx = 1
 SET error_text = fillstring(100," ")
 SET dept_cd = 0.0
 SET sect_cd = 0.0
 SET subsect_cd = 0.0
 SET bench_cd = 0.0
 SET instr_cd = 0.0
 SET exam_cd = 0.0
 SET lib_group_cd = 0.0
 SET n_parent_cd = 0.0
 SET n_parent_type_cd = 0.0
 SET n_child_cd = 0.0
 SET new_sr_code = 0.0
 SET n_root_service_resource_cd = 0.0
 SET n_coll_seq = 0
 SET n_max_sequence = 0
 SET n_group_sequence = 0
 SET cur_max = 0
 SET n_locview_cd = 0.0
 SET n_lab_svc_area_cd = 0.0
 SET n_dept_code_value = 0.0
 SET n_sect_code_value = 0.0
 SET n_subsect_code_value = 0.0
 SET n_instr_code_value = 0.0
 SET n_bench_code_value = 0.0
 SET n_cdf_meaning = fillstring(12," ")
 SET n_description = fillstring(60," ")
 SET n_display = fillstring(40," ")
 SET n_accn_site_prefix = fillstring(5," ")
 SET i_instr_alias = fillstring(100," ")
 SET add_sects = "N"
 SET add_subsects = "N"
 SET add_res = "N"
 SET add_cal = "N"
 SET n_organization_id = org_id
 SET n_location_cd = 0.0
 SET i_multiplexor_ind = 0
 SET i_point_of_care_flag = 0
 SET i_strt_model_id = 0.0
 SET i_instr_identifier = 0
 SET i_identifier_flag = 0
 SET i_auto_verify_flag = 0
 SET i_worklist_build_flag = 0
 SET i_worklist_hours = 0
 SET i_worklist_max = 0
 SET i_container_ind = 0
 SET i_gate_ind = 0
 SET i_instr_alias = fillstring(200," ")
 SET b_worklist_build_flag = 0
 SET b_worklist_hours = 0
 SET b_worklist_max = 0
 SET b_container_ind = 0
 SET b_gate_ind = 0
 SET deptcnt = size(request->srh.dept,5)
 FOR (ii = 1 TO deptcnt)
   SET add_sects = "N"
   SET add_subsects = "N"
   SET add_res = "N"
   SET add_cal = "N"
   IF ((request->srh.dept[ii].action_flag=0))
    SET dept_cd = request->srh.dept[ii].dept_code_value
   ENDIF
   IF ((request->srh.dept[ii].action_flag=1))
    SET add_sects = "Y"
    SET add_subsects = "Y"
    SET add_res = "Y"
    SET add_cal = "Y"
    SET n_parent_cd = institution_cd
    SET n_cdf_meaning = "DEPARTMENT"
    SET n_description = request->srh.dept[ii].dept_desc
    SET n_display = request->srh.dept[ii].dept_disp
    SET n_location_cd = 0
    SET n_service_resource_type_cd = dept_type_cd
    SET n_discipline_type_cd = request->srh.dept[ii].disc_type_code_value
    SET n_activity_type_cd = request->srh.dept[ii].act_type_code_value
    SET n_activity_subtype_cd = request->srh.dept[ii].act_subtype_code_value
    SET n_pharmacy_type_cd = request->srh.dept[ii].pharmacy_type_code_value
    SET n_specimen_login_cd = request->srh.dept[ii].specimen_login_type_code_value
    SET n_accn_site_prefix = request->srh.dept[ii].accn_site_prefix
    SET n_autologin_ind = request->srh.dept[ii].autologin_ind
    SET n_dispatch_download_ind = request->srh.dept[ii].dispatch_download_ind
    SET n_inventory_resource_cd = request->srh.dept[ii].inventory_resource_code_value
    SET n_pat_care_loc_ind = request->srh.dept[ii].pat_care_loc_ind
    SET n_inv_location_cd = request->srh.dept[ii].inv_location_cd
    SET d_charge_cost_ratio = request->srh.dept[ii].charge_cost_ratio
    SET d_reimbursement_cost_ratio = request->srh.dept[ii].reimbursement_cost_ratio
    CALL get_cs_max_coll_seq(xx)
    CALL add_serv_res(xx)
    IF ((request->srh.dept[ii].dept_prefix > "  "))
     INSERT  FROM br_name_value bnv
      SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = "SR_DEPTPREFIX", bnv
       .br_name = request->srh.dept[ii].dept_prefix,
       bnv.br_value = cnvtstring(new_sr_code), bnv.default_selected_ind = 0, bnv.updt_id = reqinfo->
       updt_id,
       bnv.updt_task = reqinfo->updt_task, bnv.updt_applctx = reqinfo->updt_applctx, bnv.updt_cnt = 0
      WITH nocounter
     ;end insert
    ENDIF
    IF (error_flag="T")
     GO TO exit_script
    ENDIF
    SET dept_cd = new_sr_code
    SET n_child_cd = new_sr_code
    SET n_parent_type_cd = inst_type_cd
    CALL get_res_group_max_seq(xx)
    CALL add_res_parent_child(xx)
    IF (error_flag="T")
     GO TO exit_script
    ENDIF
    IF ((request->srh.dept[ii].disc_type_mean="GENERAL LAB"))
     CALL add_lab_loc_view(xx)
     IF (error_flag="T")
      GO TO exit_script
     ENDIF
     CALL add_lab_svc_area(xx)
     IF (error_flag="T")
      GO TO exit_script
     ENDIF
    ELSEIF ((((request->srh.dept[ii].disc_type_mean="RADIOLOGY")) OR ((request->srh.dept[ii].
    disc_type_code_value=rad_disc_type_cd)
     AND rad_disc_type_cd > 0)) )
     SELECT INTO "NL:"
      FROM code_value cv,
       resource_group rg
      PLAN (cv
       WHERE cv.code_set=221
        AND cv.cdf_meaning="LIBGRP"
        AND cv.active_ind=1)
       JOIN (rg
       WHERE rg.parent_service_resource_cd=institution_cd
        AND rg.child_service_resource_cd=cv.code_value)
      DETAIL
       lib_group_cd = cv.code_value
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET next_lib = 1
      SELECT INTO "NL:"
       FROM code_value cv
       WHERE cv.code_set=221
        AND cv.cdf_meaning="LIBGRP"
        AND cv.active_ind=1
       DETAIL
        next_lib = (next_lib+ 1)
       WITH nocounter
      ;end select
      SET found_ind = 1
      WHILE (found_ind=1)
        IF (next_lib < 100)
         SET lib_search_name = cnvtstring(next_lib,2,0,r)
        ELSEIF (next_lib >= 100
         AND next_lib <= 999)
         SET lib_search_name = cnvtstring(next_lib,3,0,r)
        ELSE
         SET lib_search_name = cnvtstring(next_lib,4,0,r)
        ENDIF
        SELECT INTO "NL:"
         FROM code_value cv
         WHERE cv.display=lib_search_name
          AND cv.code_set=221
          AND cv.cdf_meaning="LIBGRP"
         WITH nocounter
        ;end select
        IF (curqual=0)
         SET found_ind = 0
        ELSE
         SET next_lib = (next_lib+ 1)
        ENDIF
      ENDWHILE
      SELECT INTO "NL:"
       FROM br_organization b
       WHERE (b.organization_id=request->srh.org_id)
       DETAIL
        org_prefix = b.br_prefix
       WITH nocounter
      ;end select
      SET n_parent_cd = institution_cd
      SET n_cdf_meaning = "LIBGRP"
      IF (org_prefix > "   ")
       SET n_description = concat(trim(org_prefix)," Library Group")
      ELSE
       SET n_description = "Library Group"
      ENDIF
      IF (next_lib < 100)
       SET n_display = cnvtstring(next_lib,2,0,r)
      ELSEIF (next_lib >= 100
       AND next_lib <= 999)
       SET n_display = cnvtstring(next_lib,3,0,r)
      ELSE
       SET n_display = cnvtstring(next_lib,4,0,r)
      ENDIF
      SET n_location_cd = 0.0
      SET n_service_resource_type_cd = lib_type_cd
      SET n_discipline_type_cd = rad_disc_type_cd
      SET n_activity_type_cd = rad_act_type_cd
      SET n_activity_subtype_cd = 0.0
      SET n_pharmacy_type_cd = request->srh.dept[ii].pharmacy_type_code_value
      SET n_specimen_login_cd = request->srh.dept[ii].specimen_login_type_code_value
      SET n_accn_site_prefix = request->srh.dept[ii].accn_site_prefix
      SET n_autologin_ind = request->srh.dept[ii].autologin_ind
      SET n_dispatch_download_ind = request->srh.dept[ii].dispatch_download_ind
      SET n_inventory_resource_cd = request->srh.dept[ii].inventory_resource_code_value
      SET n_pat_care_loc_ind = request->srh.dept[ii].pat_care_loc_ind
      SET n_inv_location_cd = request->srh.dept[ii].inv_location_cd
      SET d_charge_cost_ratio = request->srh.dept[ii].charge_cost_ratio
      SET d_reimbursement_cost_ratio = request->srh.dept[ii].reimbursement_cost_ratio
      CALL add_serv_res(xx)
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Unable to add library group to service_resource for organization: ",
        institution_disp)
       GO TO exit_script
      ENDIF
      SET lib_group_cd = new_sr_code
      SET n_child_cd = lib_group_cd
      SET n_parent_cd = institution_cd
      SET n_parent_type_cd = inst_type_cd
      CALL add_res_parent_child(xx)
     ENDIF
    ENDIF
   ENDIF
   IF ((request->srh.dept[ii].action_flag=2))
    SET n_cdf_meaning = "DEPARTMENT"
    SET dept_cd = request->srh.dept[ii].dept_code_value
    SET n_dept_code_value = request->srh.dept[ii].dept_code_value
    SET n_description = request->srh.dept[ii].dept_desc
    SET n_display = request->srh.dept[ii].dept_disp
    SET n_location_cd = 0
    SET n_discipline_type_cd = request->srh.dept[ii].disc_type_code_value
    SET n_activity_type_cd = request->srh.dept[ii].act_type_code_value
    SET n_activity_subtype_cd = request->srh.dept[ii].act_subtype_code_value
    SET n_pharmacy_type_cd = request->srh.dept[ii].pharmacy_type_code_value
    SET n_specimen_login_cd = request->srh.dept[ii].specimen_login_type_code_value
    SET n_accn_site_prefix = request->srh.dept[ii].accn_site_prefix
    SET n_autologin_ind = request->srh.dept[ii].autologin_ind
    SET n_dispatch_download_ind = request->srh.dept[ii].dispatch_download_ind
    SET n_inventory_resource_cd = request->srh.dept[ii].inventory_resource_code_value
    SET n_pat_care_loc_ind = request->srh.dept[ii].pat_care_loc_ind
    SET n_inv_location_cd = request->srh.dept[ii].inv_location_cd
    SET d_charge_cost_ratio = request->srh.dept[ii].charge_cost_ratio
    SET d_reimbursement_cost_ratio = request->srh.dept[ii].reimbursement_cost_ratio
    CALL updt_dept(xx)
    IF (error_flag="T")
     SET error_msg = concat("Error updating dept: ",n_display)
     GO TO exit_script
    ENDIF
   ENDIF
   IF ((request->srh.dept[ii].action_flag=3))
    SET n_dept_code_value = request->srh.dept[ii].dept_code_value
    SET n_description = request->srh.dept[ii].dept_desc
    CALL del_dept(xx)
    IF (error_flag="T")
     SET error_msg = concat("Error inactivating dept: ",n_display)
     GO TO exit_script
    ENDIF
   ENDIF
   SET sectcnt = size(request->srh.dept[ii].sect,5)
   FOR (jj = 1 TO sectcnt)
     IF ((request->srh.dept[ii].sect[jj].action_flag=0))
      SET sect_cd = request->srh.dept[ii].sect[jj].sect_code_value
     ENDIF
     IF ((((request->srh.dept[ii].sect[jj].action_flag=1)) OR (add_sects="Y")) )
      SET add_subsects = "Y"
      SET add_res = "Y"
      SET add_cal = "Y"
      SET n_parent_cd = dept_cd
      SET n_cdf_meaning = "SECTION"
      SET n_description = request->srh.dept[ii].sect[jj].sect_desc
      SET n_display = request->srh.dept[ii].sect[jj].sect_disp
      SET n_location_cd = 0
      SET n_service_resource_type_cd = sect_type_cd
      SET n_discipline_type_cd = request->srh.dept[ii].sect[jj].disc_type_code_value
      SET n_activity_type_cd = request->srh.dept[ii].sect[jj].act_type_code_value
      SET n_activity_subtype_cd = request->srh.dept[ii].sect[jj].act_subtype_code_value
      SET n_pharmacy_type_cd = request->srh.dept[ii].sect[jj].pharmacy_type_code_value
      SET n_specimen_login_cd = request->srh.dept[ii].sect[jj].specimen_login_type_code_value
      SET n_accn_site_prefix = request->srh.dept[ii].sect[jj].accn_site_prefix
      SET n_autologin_ind = request->srh.dept[ii].sect[jj].autologin_ind
      SET n_dispatch_download_ind = request->srh.dept[ii].sect[jj].dispatch_download_ind
      SET n_inventory_resource_cd = request->srh.dept[ii].sect[jj].inventory_resource_code_value
      SET n_pat_care_loc_ind = request->srh.dept[ii].sect[jj].pat_care_loc_ind
      SET n_inv_location_cd = request->srh.dept[ii].sect[jj].inv_location_cd
      SET s_transcript_que_cd = request->srh.dept[ii].sect[jj].transcript_que_code_value
      SET s_temp_multi_flag = request->srh.dept[ii].sect[jj].temp_multi_flag
      SET s_nbr_exam_on_req = request->srh.dept[ii].sect[jj].nbr_exam_on_req
      SET s_prelim_ind = request->srh.dept[ii].sect[jj].prelim_ind
      SET s_expedite_nursing_ind = request->srh.dept[ii].sect[jj].expedite_nursing_ind
      CALL get_cs_max_coll_seq(xx)
      CALL add_serv_res(xx)
      IF (error_flag="T")
       GO TO exit_script
      ENDIF
      IF ((request->srh.dept[ii].sect[jj].sect_mean > "  "))
       INSERT  FROM br_name_value b
        SET b.br_name_value_id = seq(bedrock_seq,nextval), b.br_name = trim(request->srh.dept[ii].
          sect[jj].sect_mean), b.br_nv_key1 = "SR_SECTION",
         b.br_value = cnvtstring(new_sr_code)
        WITH nocounter
       ;end insert
      ENDIF
      SET sect_cd = new_sr_code
      SET n_child_cd = new_sr_code
      SET n_parent_type_cd = dept_type_cd
      CALL get_res_group_max_seq(xx)
      CALL add_res_parent_child(xx)
      IF ((request->srh.dept[ii].disc_type_mean="RADIOLOGY")
       AND n_display="*ED*")
       CALL add_svc_area(xx)
      ENDIF
      IF (error_flag="T")
       GO TO exit_script
      ENDIF
     ENDIF
     IF ((request->srh.dept[ii].sect[jj].action_flag=2))
      SET sect_cd = request->srh.dept[ii].sect[jj].sect_code_value
      SET n_sect_code_value = request->srh.dept[ii].sect[jj].sect_code_value
      SET n_description = request->srh.dept[ii].sect[jj].sect_desc
      SET n_display = request->srh.dept[ii].sect[jj].sect_disp
      SET n_cdf_meaning = "SECTION"
      SET n_location_cd = 0
      SET n_discipline_type_cd = request->srh.dept[ii].sect[jj].disc_type_code_value
      SET n_activity_type_cd = request->srh.dept[ii].sect[jj].act_type_code_value
      SET n_activity_subtype_cd = request->srh.dept[ii].sect[jj].act_subtype_code_value
      SET n_pharmacy_type_cd = request->srh.dept[ii].sect[jj].pharmacy_type_code_value
      SET n_specimen_login_cd = request->srh.dept[ii].sect[jj].specimen_login_type_code_value
      SET n_accn_site_prefix = request->srh.dept[ii].sect[jj].accn_site_prefix
      SET n_autologin_ind = request->srh.dept[ii].sect[jj].autologin_ind
      SET n_dispatch_download_ind = request->srh.dept[ii].sect[jj].dispatch_download_ind
      SET n_inventory_resource_cd = request->srh.dept[ii].sect[jj].inventory_resource_code_value
      SET n_pat_care_loc_ind = request->srh.dept[ii].sect[jj].pat_care_loc_ind
      SET n_inv_location_cd = request->srh.dept[ii].sect[jj].inv_location_cd
      SET s_transcript_que_cd = request->srh.dept[ii].sect[jj].transcript_que_code_value
      SET s_temp_multi_flag = request->srh.dept[ii].sect[jj].temp_multi_flag
      SET s_nbr_exam_on_req = request->srh.dept[ii].sect[jj].nbr_exam_on_req
      SET s_prelim_ind = request->srh.dept[ii].sect[jj].prelim_ind
      SET s_expedite_nursing_ind = request->srh.dept[ii].sect[jj].expedite_nursing_ind
      CALL updt_sect(xx)
      IF (error_flag="T")
       GO TO exit_script
      ENDIF
     ENDIF
     IF ((request->srh.dept[ii].sect[jj].action_flag=3))
      SET n_sect_code_value = request->srh.dept[ii].sect[jj].sect_code_value
      SET n_description = request->srh.dept[ii].sect[jj].sect_desc
      CALL del_sect(xx)
      IF (error_flag="T")
       SET error_msg = concat("Error inactivating section: ",cnvtstring(n_sect_code_value))
       GO TO exit_script
      ENDIF
     ENDIF
     SET subsectcnt = size(request->srh.dept[ii].sect[jj].subsect,5)
     FOR (kk = 1 TO subsectcnt)
       IF ((request->srh.dept[ii].sect[jj].subsect[kk].action_flag=0))
        SET subsect_cd = request->srh.dept[ii].sect[jj].subsect[kk].subsect_code_value
       ENDIF
       IF ((((request->srh.dept[ii].sect[jj].subsect[kk].action_flag=1)) OR (add_subsects="Y")) )
        SET add_res = "Y"
        SET add_cal = "Y"
        SET n_parent_cd = sect_cd
        SET n_cdf_meaning = "SUBSECTION"
        SET n_description = request->srh.dept[ii].sect[jj].subsect[kk].subsect_desc
        SET n_display = request->srh.dept[ii].sect[jj].subsect[kk].subsect_disp
        SET n_location_cd = n_locview_cd
        IF (n_location_cd=0)
         SELECT INTO "NL:"
          FROM code_value cv
          WHERE cv.code_set=220
           AND cv.display=substring(1,40,request->srh.dept[ii].dept_disp)
           AND cv.description=substring(1,60,request->srh.dept[ii].dept_desc)
           AND cv.definition=substring(1,60,request->srh.dept[ii].dept_desc)
           AND cv.cdf_meaning="LAB"
          DETAIL
           n_location_cd = cv.code_value
          WITH nocounter
         ;end select
        ENDIF
        SET n_service_resource_type_cd = subsect_type_cd
        SET n_discipline_type_cd = request->srh.dept[ii].sect[jj].subsect[kk].disc_type_code_value
        SET n_activity_type_cd = request->srh.dept[ii].sect[jj].subsect[kk].act_type_code_value
        SET n_activity_subtype_cd = request->srh.dept[ii].sect[jj].subsect[kk].act_subtype_code_value
        SET n_pharmacy_type_cd = request->srh.dept[ii].sect[jj].subsect[kk].pharmacy_type_code_value
        SET n_specimen_login_cd = request->srh.dept[ii].sect[jj].subsect[kk].
        specimen_login_type_code_value
        SET n_accn_site_prefix = request->srh.dept[ii].sect[jj].subsect[kk].accn_site_prefix
        SET n_autologin_ind = request->srh.dept[ii].sect[jj].subsect[kk].autologin_ind
        SET n_dispatch_download_ind = request->srh.dept[ii].sect[jj].subsect[kk].
        dispatch_download_ind
        SET n_inventory_resource_cd = request->srh.dept[ii].sect[jj].subsect[kk].
        inventory_resource_code_value
        SET n_pat_care_loc_ind = request->srh.dept[ii].sect[jj].subsect[kk].pat_care_loc_ind
        SET n_inv_location_cd = request->srh.dept[ii].sect[jj].subsect[kk].inv_location_cd
        SET ss_transcript_que_cd = request->srh.dept[ii].sect[jj].subsect[kk].
        transcript_que_code_value
        SET ss_strt_model_id = request->srh.dept[ii].sect[jj].subsect[kk].strt_model_id
        SET ss_multiplexor_ind = request->srh.dept[ii].sect[jj].subsect[kk].multiplexor_ind
        CALL get_cs_max_coll_seq(xx)
        CALL add_serv_res(xx)
        IF (error_flag="T")
         GO TO exit_script
        ENDIF
        IF ((request->srh.dept[ii].sect[jj].subsect[kk].subsect_mean > "  "))
         INSERT  FROM br_name_value b
          SET b.br_name_value_id = seq(bedrock_seq,nextval), b.br_name = trim(request->srh.dept[ii].
            sect[jj].subsect[kk].subsect_mean), b.br_nv_key1 = "SR_SUBSECTION",
           b.br_value = cnvtstring(new_sr_code)
          WITH nocounter
         ;end insert
        ENDIF
        SET subsect_cd = new_sr_code
        SET n_child_cd = new_sr_code
        SET n_parent_type_cd = sect_type_cd
        CALL get_res_group_max_seq(xx)
        CALL add_res_parent_child(xx)
        IF (error_flag="T")
         GO TO exit_script
        ENDIF
       ENDIF
       IF ((request->srh.dept[ii].sect[jj].subsect[kk].action_flag=2))
        SET subsect_cd = request->srh.dept[ii].sect[jj].subsect[kk].subsect_code_value
        SET n_subsect_code_value = request->srh.dept[ii].sect[jj].subsect[kk].subsect_code_value
        SET n_description = request->srh.dept[ii].sect[jj].subsect[kk].subsect_desc
        SET n_display = request->srh.dept[ii].sect[jj].subsect[kk].subsect_disp
        SET n_cdf_meaning = "SUBSECTION"
        SET n_service_resource_type_cd = subsect_type_cd
        SET n_discipline_type_cd = request->srh.dept[ii].sect[jj].subsect[kk].disc_type_code_value
        SET n_activity_type_cd = request->srh.dept[ii].sect[jj].subsect[kk].act_type_code_value
        SET n_activity_subtype_cd = request->srh.dept[ii].sect[jj].subsect[kk].act_subtype_code_value
        SET n_pharmacy_type_cd = request->srh.dept[ii].sect[jj].subsect[kk].pharmacy_type_code_value
        SET n_specimen_login_cd = request->srh.dept[ii].sect[jj].subsect[kk].
        specimen_login_type_code_value
        SET n_accn_site_prefix = request->srh.dept[ii].sect[jj].subsect[kk].accn_site_prefix
        SET n_autologin_ind = request->srh.dept[ii].sect[jj].subsect[kk].autologin_ind
        SET n_dispatch_download_ind = request->srh.dept[ii].sect[jj].subsect[kk].
        dispatch_download_ind
        SET n_inventory_resource_cd = request->srh.dept[ii].sect[jj].subsect[kk].
        inventory_resource_code_value
        SET n_pat_care_loc_ind = request->srh.dept[ii].sect[jj].subsect[kk].pat_care_loc_ind
        SET n_inv_location_cd = request->srh.dept[ii].sect[jj].subsect[kk].inv_location_cd
        SET ss_transcript_que_cd = request->srh.dept[ii].sect[jj].subsect[kk].
        transcript_que_code_value
        SET ss_strt_model_id = request->srh.dept[ii].sect[jj].subsect[kk].strt_model_id
        SET ss_multiplexor_ind = request->srh.dept[ii].sect[jj].subsect[kk].multiplexor_ind
        CALL updt_subsect(xx)
        IF (error_flag="T")
         GO TO exit_script
        ENDIF
       ENDIF
       IF ((request->srh.dept[ii].sect[jj].subsect[kk].action_flag=3))
        SET n_subsect_code_value = request->srh.dept[ii].sect[jj].subsect[kk].subsect_code_value
        SET n_description = request->srh.dept[ii].sect[jj].subsect[kk].subsect_desc
        CALL del_subsect(xx)
        IF (error_flag="T")
         GO TO exit_script
        ENDIF
       ENDIF
       SET rescnt = size(request->srh.dept[ii].sect[jj].subsect[kk].res,5)
       FOR (ll = 1 TO rescnt)
         SET n_cdf_meaning = cnvtupper(request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
          res_type_mean)
         IF ((request->srh.dept[ii].sect[jj].subsect[kk].res[ll].action_flag=0))
          CASE (n_cdf_meaning)
           OF "BENCH":
            SET bench_cd = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].res_code_value
            SET new_sr_code = bench_cd
           OF "INSTRUMENT":
            SET instr_cd = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].res_code_value
            SET new_sr_code = instr_cd
           OF "RADEXAMROOM":
            SET exam_cd = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].res_code_value
            SET new_sr_code = exam_cd
          ENDCASE
         ENDIF
         IF ((((request->srh.dept[ii].sect[jj].subsect[kk].res[ll].action_flag=1)) OR (add_res="Y"))
         )
          SET add_cal = "Y"
          SET n_parent_cd = subsect_cd
          SET n_cdf_meaning = cnvtupper(request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
           res_type_mean)
          SET n_description = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].res_desc
          SET n_display = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].res_disp
          SET n_location_cd = n_locview_cd
          IF (n_location_cd=0)
           SELECT INTO "NL:"
            FROM service_resource sr
            WHERE sr.service_resource_cd=subsect_cd
            DETAIL
             n_location_cd = sr.location_cd
            WITH nocounter
           ;end select
           IF (n_location_cd=0)
            SELECT INTO "NL:"
             FROM code_value cv
             WHERE cv.code_set=220
              AND cv.display=substring(1,40,request->srh.dept[ii].dept_disp)
              AND cv.description=substring(1,60,request->srh.dept[ii].dept_desc)
              AND cv.definition=substring(1,60,request->srh.dept[ii].dept_desc)
              AND cv.cdf_meaning="LAB"
             DETAIL
              n_location_cd = cv.code_value
             WITH nocounter
            ;end select
           ENDIF
          ENDIF
          CASE (n_cdf_meaning)
           OF "BENCH":
            SET n_service_resource_type_cd = bench_type_cd
            SET b_worklist_build_flag = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
            b_worklist_build_flag
            SET b_worklist_hours = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
            b_worklist_hours
            SET b_worklist_max = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].b_worklist_max
            SET b_container_ind = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].b_container_ind
            SET b_gate_ind = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].b_gate_ind
           OF "INSTRUMENT":
            SET n_service_resource_type_cd = instr_type_cd
            SET i_multiplexor_ind = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
            i_multiplexor_ind
            SET i_point_of_care_flag = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
            i_point_of_care_flag
            SET i_strt_model_id = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].i_strt_model_id
            SET i_instr_identifier = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
            i_instr_identifier
            SET i_identifier_flag = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
            i_identifier_flag
            SET i_auto_verify_flag = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
            i_auto_verify_flag
            SET i_instr_alias = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].i_instr_alias
            SET i_worklist_build_flag = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
            i_worklist_build_flag
            SET i_worklist_hours = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
            i_worklist_hours
            SET i_worklist_max = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].i_worklist_max
            SET i_container_ind = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].i_container_ind
            SET i_gate_ind = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].i_gate_ind
           OF "RADEXAMROOM":
            SET n_service_resource_type_cd = exam_type_cd
          ENDCASE
          SET n_discipline_type_cd = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
          disc_type_code_value
          SET n_activity_type_cd = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
          act_type_code_value
          SET n_activity_subtype_cd = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
          act_subtype_code_value
          SET n_pharmacy_type_cd = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
          pharmacy_type_code_value
          SET n_specimen_login_cd = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
          specimen_login_type_code_value
          SET n_accn_site_prefix = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
          accn_site_prefix
          SET n_autologin_ind = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].autologin_ind
          SET n_dispatch_download_ind = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
          dispatch_download_ind
          SET n_inventory_resource_cd = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
          inventory_resource_code_value
          SET n_pat_care_loc_ind = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
          pat_care_loc_ind
          SET n_inv_location_cd = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].inv_location_cd
          SET res_exists = "F"
          IF ((request->srh.dept[ii].sect[jj].subsect[kk].res[ll].share_resource_ind=1))
           CALL check_for_existing_resource(xx)
          ENDIF
          IF (res_exists="F")
           CALL get_cs_max_coll_seq(xx)
           CALL add_serv_res(xx)
           IF (error_flag="T")
            GO TO exit_script
           ELSE
            SET srescnt = (srescnt+ 1)
            SET stat = alterlist(sres->sres_list,srescnt)
            SET sres->sres_list[srescnt].code = new_sr_code
            SET sres->sres_list[srescnt].disp = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
            res_disp
           ENDIF
          ENDIF
          IF ((request->srh.dept[ii].sect[jj].subsect[kk].res[ll].res_mean > "  "))
           INSERT  FROM br_name_value b
            SET b.br_name_value_id = seq(bedrock_seq,nextval), b.br_name = trim(request->srh.dept[ii]
              .sect[jj].subsect[kk].res[ll].res_mean), b.br_nv_key1 = "SR_RESOURCE",
             b.br_value = cnvtstring(new_sr_code)
            WITH nocounter
           ;end insert
          ENDIF
          CASE (n_cdf_meaning)
           OF "BENCH":
            SET bench_cd = new_sr_code
           OF "INSTRUMENT":
            SET instr_cd = new_sr_code
           OF "RADEXAMROOM":
            SET exam_cd = new_sr_code
          ENDCASE
          SET n_child_cd = new_sr_code
          SET n_parent_type_cd = subsect_type_cd
          CALL get_res_group_max_seq(xx)
          CALL add_res_parent_child(xx)
          IF (error_flag="T")
           GO TO exit_script
          ENDIF
         ENDIF
         IF ((request->srh.dept[ii].sect[jj].subsect[kk].res[ll].action_flag=2))
          CASE (n_cdf_meaning)
           OF "BENCH":
            SET bench_cd = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].res_code_value
            SET b_worklist_build_flag = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
            b_worklist_build_flag
            SET b_worklist_hours = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
            b_worklist_hours
            SET b_worklist_max = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].b_worklist_max
            SET b_container_ind = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].b_container_ind
            SET b_gate_ind = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].b_gate_ind
           OF "INSTRUMENT":
            SET instr_cd = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].res_code_value
            SET i_multiplexor_ind = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
            i_multiplexor_ind
            SET i_point_of_care_flag = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
            i_point_of_care_flag
            SET i_strt_model_id = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].i_strt_model_id
            SET i_instr_identifier = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
            i_instr_identifier
            SET i_identifier_flag = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
            i_identifier_flag
            SET i_auto_verify_flag = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
            i_auto_verify_flag
            SET i_worklist_build_flag = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
            i_worklist_build_flag
            SET i_worklist_hours = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
            i_worklist_hours
            SET i_worklist_max = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].i_worklist_max
            SET i_container_ind = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].i_container_ind
            SET i_gate_ind = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].i_gate_ind
            SET i_instr_alias = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].i_instr_alias
           OF "RADEXAMROOM":
            SET exam_cd = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].res_code_value
            SET e_multiplexor_ind = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
            i_multiplexor_ind
            SET e_point_of_care_flag = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
            i_point_of_care_flag
            SET e_strt_model_id = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].i_strt_model_id
            SET e_instr_identifier = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
            i_instr_identifier
            SET e_identifier_flag = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
            i_identifier_flag
            SET e_auto_verify_flag = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
            i_auto_verify_flag
            SET e_worklist_build_flag = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
            i_worklist_build_flag
            SET e_worklist_hours = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
            i_worklist_hours
            SET e_worklist_max = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].i_worklist_max
            SET e_container_ind = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].i_container_ind
            SET e_gate_ind = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].i_gate_ind
            SET e_instr_alias = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].i_instr_alias
          ENDCASE
          SET n_res_code_value = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].res_code_value
          SET new_sr_code = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].res_code_value
          SET n_description = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].res_desc
          SET n_display = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].res_disp
          SET n_cdf_meaning = cnvtupper(request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
           res_type_mean)
          SET n_lab_svc_area_cd = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
          location_code_value
          SET n_discipline_type_cd = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
          disc_type_code_value
          SET n_activity_type_cd = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
          act_type_code_value
          SET n_activity_subtype_cd = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
          act_subtype_code_value
          SET n_pharmacy_type_cd = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
          pharmacy_type_code_value
          SET n_specimen_login_cd = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
          specimen_login_type_code_value
          SET n_accn_site_prefix = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
          accn_site_prefix
          SET n_autologin_ind = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].autologin_ind
          SET n_dispatch_download_ind = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
          dispatch_download_ind
          SET n_inventory_resource_cd = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
          inventory_resource_code_value
          SET n_pat_care_loc_ind = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
          pat_care_loc_ind
          SET n_inv_location_cd = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].inv_location_cd
          CALL updt_res(xx)
          IF (error_flag="T")
           GO TO exit_script
          ENDIF
         ENDIF
         IF ((request->srh.dept[ii].sect[jj].subsect[kk].res[ll].action_flag=3))
          SET n_res_code_value = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].res_code_value
          SET n_description = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].res_desc
          SET n_cdf_meaning = cnvtupper(request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
           res_type_mean)
          CALL del_res(xx)
          IF (error_flag="T")
           GO TO exit_script
          ENDIF
         ENDIF
         SET calcnt = size(request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal,5)
         SET calcheck = 0
         IF ((request->srh.dept[ii].sect[jj].subsect[kk].res[ll].share_resource_ind=1))
          SELECT INTO "nl:"
           FROM loc_resource_calendar lrc
           WHERE lrc.service_resource_cd=new_sr_code
           DETAIL
            calcheck = (calcheck+ 1)
           WITH nocounter
          ;end select
         ENDIF
         IF (calcheck=0)
          IF (calcnt > 0)
           CALL clean_old_cals(xx)
          ENDIF
          IF ((request->srh.dept[ii].sect[jj].subsect[kk].res[ll].del_all_calendars_ind=1))
           CALL clean_old_cals(xx)
          ENDIF
          FOR (mm = 1 TO calcnt)
            IF ((((request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].action_flag=1)) OR (
            add_cal="Y"))
             AND (request->srh.dept[ii].sect[jj].subsect[kk].res[ll].action_flag != 3))
             CALL add_calendar(xx)
             IF (error_flag="T")
              GO TO exit_script
             ENDIF
            ENDIF
            IF ((request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].action_flag=2)
             AND (request->srh.dept[ii].sect[jj].subsect[kk].res[ll].action_flag != 3))
             CALL upd_calendar(xx)
             IF (error_flag="T")
              GO TO exit_script
             ENDIF
            ENDIF
            IF ((request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].action_flag=3))
             CALL del_calendar(xx)
             IF (error_flag="T")
              GO TO exit_script
             ENDIF
            ENDIF
          ENDFOR
         ENDIF
       ENDFOR
       SET add_res = "N"
     ENDFOR
     SET add_subsects = "N"
   ENDFOR
   SET add_sects = "N"
 ENDFOR
 GO TO exit_script
 SUBROUTINE check_for_existing_resource(x)
   SET e_code_value = 0.0
   IF ((request->srh.dept[ii].sect[jj].subsect[kk].res[ll].res_code_value > 0))
    SELECT INTO "nl:"
     FROM code_value cv
     PLAN (cv
      WHERE cv.code_set=221
       AND (cv.code_value=request->srh.dept[ii].sect[jj].subsect[kk].res[ll].res_code_value))
     ORDER BY cv.code_value
     HEAD cv.code_value
      e_code_value = cv.code_value
     WITH nocounter
    ;end select
   ELSE
    FOR (i = 1 TO srescnt)
      IF ((request->srh.dept[ii].sect[jj].subsect[kk].res[ll].res_disp=sres->sres_list[i].disp))
       SET e_code_value = sres->sres_list[i].code
      ENDIF
    ENDFOR
   ENDIF
   IF (e_code_value > 0)
    SET new_sr_code = e_code_value
    SET res_exists = "T"
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE add_serv_res(x)
   SET request_cv->cd_value_list[1].action_flag = 1
   SET request_cv->cd_value_list[1].code_set = 221
   SET request_cv->cd_value_list[1].display = substring(1,40,n_display)
   SET request_cv->cd_value_list[1].description = substring(1,60,n_description)
   SET request_cv->cd_value_list[1].definition = substring(1,60,n_description)
   SET request_cv->cd_value_list[1].cdf_meaning = n_cdf_meaning
   SET request_cv->cd_value_list[1].active_ind = 1
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   SET new_sr_code = 0.0
   IF ((reply_cv->status_data.status="S")
    AND (reply_cv->qual[1].code_value > 0))
    SET new_sr_code = reply_cv->qual[1].code_value
   ELSE
    SET error_flag = "T"
    SET error_msg = concat("Error adding",n_cdf_meaning," service resource code_value: ",
     n_description)
    GO TO exit_script
   ENDIF
   INSERT  FROM service_resource s
    SET s.service_resource_cd = new_sr_code, s.location_cd = n_location_cd, s
     .service_resource_type_cd = n_service_resource_type_cd,
     s.discipline_type_cd = n_discipline_type_cd, s.activity_type_cd = n_activity_type_cd, s
     .activity_subtype_cd = n_activity_subtype_cd,
     s.pharmacy_type_cd = n_pharmacy_type_cd, s.cs_login_loc_cd = n_specimen_login_cd, s
     .accn_site_prefix = n_accn_site_prefix,
     s.active_ind = 1, s.autologin_ind = n_autologin_ind, s.dispatch_download_ind =
     n_dispatch_download_ind,
     s.inventory_resource_cd = n_inventory_resource_cd, s.pat_care_loc_ind = n_pat_care_loc_ind, s
     .active_status_cd = active_cd,
     s.active_status_prsnl_id = 0, s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s
     .except_exist_ind = 0,
     s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), s.end_effective_dt_tm = cnvtdatetime(
      "31-dec-2100 00:00:00.00"), s.organization_id = n_organization_id,
     s.data_status_cd = auth_cd, s.data_status_prsnl_id = 0, s.data_status_dt_tm = cnvtdatetime(
      curdate,curtime3),
     s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task =
     reqinfo->updt_task,
     s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = 0, s.inv_location_cd = n_inv_location_cd
    WITH nocounter, dontexist
   ;end insert
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Error adding SR service_resource: ",n_description)
    GO TO exit_script
   ENDIF
   CASE (n_cdf_meaning)
    OF "DEPARTMENT":
     INSERT  FROM department d
      SET d.service_resource_cd = new_sr_code, d.charge_cost_ratio = d_charge_cost_ratio, d
       .reimbursement_cost_ratio = d_reimbursement_cost_ratio,
       d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id = reqinfo->updt_id, d.updt_task =
       reqinfo->updt_task,
       d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "T"
      SET error_msg = concat("Error adding SR department: ",n_description)
      GO TO exit_script
     ENDIF
    OF "SECTION":
     INSERT  FROM section s
      SET s.service_resource_cd = new_sr_code, s.transcript_que_cd = s_transcript_que_cd, s
       .temp_multi_flag = s_temp_multi_flag,
       s.nbr_exam_on_req = s_nbr_exam_on_req, s.prelim_ind = s_prelim_ind, s.expedite_nursing_ind =
       s_expedite_nursing_ind,
       s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task =
       reqinfo->updt_task,
       s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "T"
      SET error_msg = concat("Error adding SR section: ",n_description)
      GO TO exit_script
     ENDIF
    OF "SUBSECTION":
     INSERT  FROM sub_section s
      SET s.service_resource_cd = new_sr_code, s.transcript_que_cd = ss_transcript_que_cd, s
       .strt_model_id = ss_strt_model_id,
       s.multiplexor_ind = ss_multiplexor_ind, s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s
       .updt_id = reqinfo->updt_id,
       s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "T"
      SET error_msg = concat("Error adding SR subsection: ",n_description)
      GO TO exit_script
     ENDIF
    OF "BENCH":
     INSERT  FROM lab_bench l
      SET l.service_resource_cd = new_sr_code, l.worklist_build_flag = b_worklist_build_flag, l
       .worklist_hours = b_worklist_hours,
       l.worklist_max = b_worklist_max, l.container_ind = b_container_ind, l.gate_ind = b_gate_ind,
       l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_id = reqinfo->updt_id, l.updt_task =
       reqinfo->updt_task,
       l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "T"
      SET error_msg = concat("Error adding SR bench: ",n_description)
      GO TO exit_script
     ENDIF
    OF "INSTRUMENT":
     INSERT  FROM lab_instrument l
      SET l.service_resource_cd = new_sr_code, l.multiplexor_ind = i_multiplexor_ind, l
       .point_of_care_flag = i_point_of_care_flag,
       l.strt_model_id = i_strt_model_id, l.instr_identifier = i_instr_identifier, l.identifier_flag
        = i_identifier_flag,
       l.auto_verify_flag = i_auto_verify_flag, l.worklist_build_flag = i_worklist_build_flag, l
       .worklist_hours = i_worklist_hours,
       l.worklist_max = i_worklist_max, l.container_ind = i_container_ind, l.gate_ind = i_gate_ind,
       l.instr_alias = i_instr_alias, l.active_ind = 1, l.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       l.updt_id = reqinfo->updt_id, l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->
       updt_applctx,
       l.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "T"
      SET error_msg = concat("Error adding SR instrument: ",n_description)
      GO TO exit_script
     ENDIF
    OF "RADEXAMROOM":
     INSERT  FROM rad_exam_room r
      SET r.service_resource_cd = new_sr_code, r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r
       .updt_id = reqinfo->updt_id,
       r.updt_task = reqinfo->updt_task, r.updt_applctx = reqinfo->updt_applctx, r.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Error adding SR instrument: ",n_description)
      GO TO exit_script
     ENDIF
     IF (lib_group_cd=0.0)
      SELECT INTO "NL:"
       FROM code_value cv,
        resource_group rg
       PLAN (cv
        WHERE cv.code_set=221
         AND cv.cdf_meaning="LIBGRP"
         AND cv.active_ind=1)
        JOIN (rg
        WHERE rg.parent_service_resource_cd=institution_cd
         AND rg.child_service_resource_cd=cv.code_value)
       DETAIL
        lib_group_cd = cv.code_value
       WITH nocounter
      ;end select
     ENDIF
     INSERT  FROM exam_room_lib_grp_reltn e
      SET e.service_resource_cd = new_sr_code, e.lib_group_cd = lib_group_cd, e.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       e.updt_id = reqinfo->updt_id, e.updt_task = reqinfo->updt_task, e.updt_applctx = reqinfo->
       updt_applctx,
       e.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Error adding SR instrument: ",n_description,
       " to exam_room_lib_grp_reltn.")
      GO TO exit_script
     ENDIF
    OF "LIBGRP":
     INSERT  FROM library_group l
      SET l.service_resource_cd = new_sr_code, l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l
       .updt_id = reqinfo->updt_id,
       l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Error adding SR instrument: ",n_description)
      GO TO exit_script
     ENDIF
   ENDCASE
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE get_cs_max_coll_seq(x)
   SET n_coll_seq = 0
   SELECT INTO "nl:"
    c.collation_seq, c.code_value, c.cdf_meaning
    FROM code_value c
    PLAN (c
     WHERE c.code_set=221
      AND c.cdf_meaning=n_cdf_meaning
      AND c.active_ind=1)
    ORDER BY c.collation_seq, c.code_value
    DETAIL
     IF (n_coll_seq < c.collation_seq)
      n_coll_seq = c.collation_seq
     ENDIF
    WITH nocounter
   ;end select
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE get_res_group_max_seq(x)
   SET code_value = 0.0
   SET n_max_sequence = 0
   SELECT INTO "nl:"
    rg.parent_service_cd, rg.resource_group_type_cd, rg.sequence
    FROM resource_group rg
    PLAN (rg
     WHERE rg.parent_service_resource_cd=n_parent_cd
      AND rg.resource_group_type_cd=n_parent_type_cd
      AND rg.root_service_resource_cd=n_root_service_resource_cd)
    DETAIL
     IF (n_max_sequence < rg.sequence)
      n_max_sequence = rg.sequence
     ENDIF
    WITH nocounter
   ;end select
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE get_group_sequence(x)
   SET n_group_sequence = 0
   SELECT INTO "nl:"
    lrr.group_sequence, lrr.service_resource_cd
    FROM loc_resource_r lrr
    WHERE lrr.service_resource_cd=new_sr_code
    ORDER BY lrr.group_sequence DESC
    DETAIL
     IF (n_group_sequence < lrr.group_sequence)
      n_group_sequence = lrr.group_sequence
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET n_group_sequence = 0
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE add_svc_area(x)
   SET request_cv->cd_value_list[1].action_flag = 1
   SET request_cv->cd_value_list[1].code_set = 220
   SET request_cv->cd_value_list[1].cdf_meaning = "SRVAREA"
   SET request_cv->cd_value_list[1].display = concat(trim(org_prefix)," ",trim(request->srh.dept[ii].
     dept_prefix)," ",n_display)
   SET request_cv->cd_value_list[1].description = concat(trim(org_prefix)," ",trim(request->srh.dept[
     ii].dept_prefix)," ",n_description)
   SET request_cv->cd_value_list[1].active_ind = 1
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   IF ((reply_cv->status_data.status="S")
    AND (reply_cv->qual[1].code_value > 0))
    SET new_svc_area_code = reply_cv->qual[1].code_value
    SET n_svc_area_cd = reply_cv->qual[1].code_value
   ELSE
    SET error_flag = "Y"
    SET error_msg = concat("Error adding service area to code set 220 for: ",n_description)
    GO TO exit_script
   ENDIF
   INSERT  FROM location l
    SET l.location_cd = new_svc_area_code, l.location_type_cd = srvarea_cd, l.organization_id =
     org_id,
     l.active_ind = 1, l.active_status_cd = active_cd, l.active_status_dt_tm = cnvtdatetime(curdate,
      curtime3),
     l.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), l.end_effective_dt_tm = cnvtdatetime(
      "31-dec-2100 00:00:00.00"), l.data_status_cd = auth_cd,
     l.data_status_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_applctx = reqinfo->updt_applctx, l
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     l.updt_id = reqinfo->updt_id, l.updt_task = reqinfo->updt_task, l.discipline_type_cd =
     n_discipline_type_cd
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_text = concat("Error adding service area to location for: ",n_description)
   ENDIF
 END ;Subroutine
 SUBROUTINE add_res_parent_child(x)
   INSERT  FROM resource_group r
    SET r.seq = 1, r.parent_service_resource_cd = n_parent_cd, r.child_service_resource_cd =
     n_child_cd,
     r.resource_group_type_cd = n_parent_type_cd, r.root_service_resource_cd = 0.0, r.sequence = (
     n_max_sequence+ 1),
     r.active_ind = 1, r.active_status_cd = active_cd, r.active_status_dt_tm = cnvtdatetime(curdate,
      curtime3),
     r.active_status_prsnl_id = 0, r.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), r
     .end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"),
     r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_id = reqinfo->updt_id, r.updt_task =
     reqinfo->updt_task,
     r.updt_applctx = reqinfo->updt_applctx, r.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "T"
    SET error_text = concat("Error adding resource_group for parent: ",cnvtstring(n_parent_cd),
     " child: ",cnvtstring(n_child_cd))
   ENDIF
   INSERT  FROM sr_resource_group_hist s
    SET s.sr_resource_group_hist_id = seq(location_resource_seq,nextval), s
     .parent_service_resource_cd = n_parent_cd, s.child_service_resource_cd = n_child_cd,
     s.resource_group_type_cd = n_parent_type_cd, s.root_service_resource_cd = 0.0, s.active_ind = 1,
     s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), s.end_effective_dt_tm = cnvtdatetime(
      "31-dec-2100 00:00:00.00"), s.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
     updt_applctx,
     s.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "T"
    SET error_text = concat("Error adding sr_resource_group_hist for parent: ",cnvtstring(n_parent_cd
      )," child: ",cnvtstring(n_child_cd))
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE add_lab_loc_view(x)
   CALL echo("******************************** adding location view")
   SET existing_loc_cd = 0.0
   SET row_cnt = 0
   SELECT INTO "NL:"
    FROM location l
    WHERE l.location_type_cd=locview_cd
     AND l.organization_id=org_id
     AND l.active_ind=1
    DETAIL
     existing_loc_cd = l.location_cd, row_cnt = (row_cnt+ 1)
    WITH nocounter
   ;end select
   IF (row_cnt=1)
    SET n_locview_cd = existing_loc_cd
   ELSEIF (row_cnt > 1)
    SET n_locview_cd = 0
   ELSEIF (row_cnt=0)
    SET n_lv_coll_seq = 0
    SELECT INTO "nl:"
     c.code_value, c.collation_seq
     FROM code_value c
     PLAN (c
      WHERE c.code_set=220
       AND c.cdf_meaning="LAB"
       AND c.active_ind=1)
     ORDER BY c.collation_seq DESC
     DETAIL
      n_lv_coll_seq = c.collation_seq
     WITH nocounter
    ;end select
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 220
    SET request_cv->cd_value_list[1].display = substring(1,40,n_display)
    SET request_cv->cd_value_list[1].description = substring(1,60,n_description)
    SET request_cv->cd_value_list[1].definition = substring(1,60,n_description)
    SET request_cv->cd_value_list[1].cdf_meaning = "LAB"
    SET request_cv->cd_value_list[1].collation_seq = (n_lv_coll_seq+ 1)
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    SET new_lab_loc_view_code = 0.0
    IF ((reply_cv->status_data.status="S")
     AND (reply_cv->qual[1].code_value > 0))
     SET new_lab_loc_view_code = reply_cv->qual[1].code_value
     SET n_locview_cd = new_lab_loc_view_code
    ELSE
     SET error_flag = "T"
     SET error_msg = concat("Error adding location view to code set 220 for: ",n_description)
     GO TO exit_script
    ENDIF
    INSERT  FROM location l
     SET l.location_cd = new_lab_loc_view_code, l.location_type_cd = locview_cd, l.organization_id =
      org_id,
      l.resource_ind = 0, l.active_ind = 1, l.active_status_cd = active_cd,
      l.active_status_dt_tm = cnvtdatetime(curdate,curtime3), l.active_status_prsnl_id = 0, l
      .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      l.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"), l.census_ind = 0, l
      .contributor_system_cd = 0,
      l.data_status_cd = auth_cd, l.data_status_dt_tm = cnvtdatetime(curdate,curtime3), l
      .data_status_prsnl_id = 0,
      l.updt_applctx = reqinfo->updt_applctx, l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l
      .updt_id = reqinfo->updt_id,
      l.updt_task = reqinfo->updt_task, l.facility_accn_prefix_cd = 0, l.discipline_type_cd = 0,
      l.view_type_cd = 0, l.exp_lvl_cd = 0, l.chart_format_id = 0,
      l.transmit_outbound_order_ind = 0, l.patcare_node_ind = 0, l.registration_ind = 0,
      l.contributor_source_cd = 0, l.ref_lab_acct_nbr = ""
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "T"
     SET error_text = concat("Error adding location view to location for: ",n_description)
    ENDIF
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE add_lab_svc_area(x)
   CALL echo("******************************** adding service area")
   SET existing_loc_cd = 0.0
   SET row_cnt = 0
   SELECT INTO "NL:"
    FROM location l
    WHERE l.location_type_cd=srvarea_cd
     AND l.organization_id=org_id
     AND l.discipline_type_cd=n_discipline_type_cd
     AND l.active_ind=1
    DETAIL
     existing_loc_cd = l.location_cd, row_cnt = (row_cnt+ 1)
    WITH nocounter
   ;end select
   IF (row_cnt=1)
    SET n_lab_svc_area_cd = existing_loc_cd
   ELSEIF (row_cnt > 1)
    SET n_lab_svc_area_cd = 0
   ELSEIF (row_cnt=0)
    SET n_sva_coll_seq = 0
    SELECT INTO "nl:"
     c.code_value, c.collation_seq
     FROM code_value c
     PLAN (c
      WHERE c.code_set=220
       AND c.cdf_meaning="SRVAREA"
       AND c.active_ind=1)
     ORDER BY c.collation_seq
     DETAIL
      n_sva_coll_seq = c.collation_seq
     WITH nocounter
    ;end select
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 220
    SET request_cv->cd_value_list[1].display = substring(1,40,institution_disp)
    SET request_cv->cd_value_list[1].description = substring(1,60,org_name)
    SET request_cv->cd_value_list[1].definition = substring(1,60,institution_desc)
    SET request_cv->cd_value_list[1].cdf_meaning = "SRVAREA"
    SET request_cv->cd_value_list[1].collation_seq = (n_sva_coll_seq+ 1)
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    SET new_lab_svc_area_code = 0.0
    IF ((reply_cv->status_data.status="S")
     AND (reply_cv->qual[1].code_value > 0))
     SET new_lab_svc_area_code = reply_cv->qual[1].code_value
     SET n_lab_svc_area_cd = new_lab_svc_area_code
    ELSE
     SET error_flag = "T"
     SET error_msg = concat("Error adding service area to code set 220 for: ",n_description)
     GO TO exit_script
    ENDIF
    INSERT  FROM location l
     SET l.location_cd = new_lab_svc_area_code, l.location_type_cd = srvarea_cd, l.organization_id =
      org_id,
      l.resource_ind = 0, l.active_ind = 1, l.active_status_cd = active_cd,
      l.active_status_dt_tm = cnvtdatetime(curdate,curtime3), l.active_status_prsnl_id = 0, l
      .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      l.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"), l.census_ind = 0, l
      .contributor_system_cd = 0,
      l.data_status_cd = auth_cd, l.data_status_dt_tm = cnvtdatetime(curdate,curtime3), l
      .data_status_prsnl_id = 0,
      l.updt_applctx = reqinfo->updt_applctx, l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l
      .updt_id = reqinfo->updt_id,
      l.updt_task = reqinfo->updt_task, l.facility_accn_prefix_cd = 0, l.discipline_type_cd =
      n_discipline_type_cd,
      l.view_type_cd = 0, l.exp_lvl_cd = 0, l.chart_format_id = 0,
      l.transmit_outbound_order_ind = 0, l.patcare_node_ind = 0, l.registration_ind = 0,
      l.contributor_source_cd = 0, l.ref_lab_acct_nbr = ""
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "T"
     SET error_text = concat("Error adding service area to location for: ",n_description)
    ENDIF
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE add_calendar(x)
   IF (n_lab_svc_area_cd=0)
    SELECT INTO "nl:"
     c.code_value
     FROM code_value c
     WHERE c.code_set=220
      AND c.cdf_meaning="SRVAREA"
      AND c.description=org_name
      AND c.display=institution_disp
      AND c.active_ind=1
     DETAIL
      n_lab_svc_area_cd = c.code_value
     WITH nocounter
    ;end select
   ENDIF
   SET n_group_sequence = 0
   CALL get_group_sequence(xx)
   INSERT  FROM loc_resource_r l
    SET l.service_resource_cd = new_sr_code, l.loc_resource_type_cd =
     IF (n_cdf_meaning != "RADEXAMROOM") lab_cd
     ELSE rad_cd
     ENDIF
     , l.location_cd = n_lab_svc_area_cd,
     l.sequence =
     IF ((request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].sequence > 0)) request->srh.
      dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].sequence
     ELSE mm
     ENDIF
     , l.mm_vendor_customer_account_id = 0, l.group_sequence = (n_group_sequence+ 1),
     l.updt_id = reqinfo->updt_id, l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_task =
     reqinfo->updt_task,
     l.updt_cnt = 0, l.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Error adding loc_resource_r row for service resource: ",cnvtstring(
      new_sr_code))
    GO TO exit_script
   ENDIF
   SET nbr_of_cals = 0
   SET nbr_of_cals = size(request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].cal_det,5)
   FOR (nn = 1 TO nbr_of_cals)
    INSERT  FROM loc_resource_calendar l
     SET l.service_resource_cd = new_sr_code, l.location_cd = n_lab_svc_area_cd, l.sequence =
      IF ((request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].sequence > 0)) request->srh.
       dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].sequence
      ELSE mm
      ENDIF
      ,
      l.loc_resource_type_cd =
      IF (n_cdf_meaning != "RADEXAMROOM") lab_cd
      ELSE rad_cd
      ENDIF
      , l.calendar_seq =
      IF ((request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].cal_det[nn].calendar_seq > 0))
       request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].cal_det[nn].calendar_seq
      ELSE (nn - 1)
      ENDIF
      , l.dow = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].cal_det[nn].dow,
      l.priority_cd = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].cal_det[nn].
      priority_code_value, l.specimen_type_cd = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
      cal[mm].cal_det[nn].specimen_type_code_value, l.avail_ind = request->srh.dept[ii].sect[jj].
      subsect[kk].res[ll].cal[mm].avail_ind,
      l.open_time = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].cal_det[nn].open_time,
      l.close_time = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].cal_det[nn].
      close_time, l.age_from_minutes = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].
      cal_det[nn].age_from_minutes,
      l.age_from_units_cd = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].cal_det[nn].
      age_from_code_value, l.age_to_minutes = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[
      mm].cal_det[nn].age_to_minutes, l.age_to_units_cd = request->srh.dept[ii].sect[jj].subsect[kk].
      res[ll].cal[mm].cal_det[nn].age_to_code_value,
      l.description = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].description, l
      .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), l.end_effective_dt_tm = cnvtdatetime(
       "31-dec-2100 00:00:00.00"),
      l.active_ind = 1, l.active_status_cd = active_cd, l.active_status_dt_tm = cnvtdatetime(curdate,
       curtime3),
      l.active_status_prsnl_id = reqinfo->updt_id, l.updt_cnt = 0, l.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      l.updt_id = reqinfo->updt_id, l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->
      updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat("Error adding loc_resource_calendar row for: ",request->srh.dept[ii].
      sect[jj].subsect[kk].res[ll].cal[mm].description)
     GO TO exit_script
    ENDIF
   ENDFOR
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE updt_dept(x)
   SET request_cv->cd_value_list[1].action_flag = 2
   SET request_cv->cd_value_list[1].code_set = 221
   SET request_cv->cd_value_list[1].code_value = n_dept_code_value
   SET request_cv->cd_value_list[1].display = substring(1,40,n_display)
   SET request_cv->cd_value_list[1].description = substring(1,60,n_description)
   SET request_cv->cd_value_list[1].definition = substring(1,60,n_description)
   SET request_cv->cd_value_list[1].cdf_meaning = n_cdf_meaning
   SET request_cv->cd_value_list[1].active_ind = 1
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   IF ((reply_cv->status_data.status != "S"))
    SET error_flag = "T"
    SET error_msg = concat("Error updating code_value for department: ",n_description)
    GO TO exit_script
   ENDIF
   UPDATE  FROM service_resource s
    SET s.location_cd = n_location_cd, s.discipline_type_cd = n_discipline_type_cd, s
     .activity_type_cd = n_activity_type_cd,
     s.activity_subtype_cd = n_activity_subtype_cd, s.pharmacy_type_cd = n_pharmacy_type_cd, s
     .cs_login_loc_cd = n_specimen_login_cd,
     s.accn_site_prefix = n_accn_site_prefix, s.autologin_ind = n_autologin_ind, s
     .dispatch_download_ind = n_dispatch_download_ind,
     s.inventory_resource_cd = n_inventory_resource_cd, s.pat_care_loc_ind = n_pat_care_loc_ind, s
     .inv_location_cd = n_inv_location_cd,
     s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task =
     reqinfo->updt_task,
     s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s.updt_cnt+ 1)
    WHERE s.service_resource_cd=n_dept_code_value
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Error updating service_resource for department: ",n_description)
    GO TO exit_script
   ENDIF
   UPDATE  FROM department d
    SET d.charge_cost_ratio = d_charge_cost_ratio, d.reimbursement_cost_ratio =
     d_reimbursement_cost_ratio, d.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->
     updt_applctx,
     d.updt_cnt = (d.updt_cnt+ 1)
    WHERE d.service_resource_cd=n_dept_code_value
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Error updating department for department: ",n_description)
    GO TO exit_script
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE del_inst(x)
   SET request_cv->cd_value_list[1].action_flag = 3
   SET request_cv->cd_value_list[1].code_set = 221
   SET request_cv->cd_value_list[1].code_value = request->srh.inst_code_value
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   IF ((reply_cv->status_data.status != "S"))
    SET error_flag = "T"
    SET error_msg = concat("Error inactivating code_value for institution: ",request->srh.inst_disp)
    GO TO exit_script
   ENDIF
   UPDATE  FROM service_resource s
    SET s.active_ind = 0, s.active_status_cd = inactive_cd, s.active_status_prsnl_id = 0,
     s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_dt_tm = cnvtdatetime(curdate,
      curtime3), s.updt_id = reqinfo->updt_id,
     s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s
     .updt_cnt+ 1)
    WHERE (s.service_resource_cd=request->srh.inst_code_value)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Error inactivating service_resource for institution: ",request->srh.
     inst_disp)
    GO TO exit_script
   ENDIF
   UPDATE  FROM resource_group r
    SET r.active_ind = 0, r.active_status_cd = inactive_cd, r.active_status_prsnl_id = 0,
     r.active_status_dt_tm = cnvtdatetime(curdate,curtime3), r.end_effective_dt_tm = cnvtdatetime(
      curdate,curtime3), r.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     r.updt_id = reqinfo->updt_id, r.updt_task = reqinfo->updt_task, r.updt_applctx = reqinfo->
     updt_applctx,
     r.updt_cnt = (r.updt_cnt+ 1)
    WHERE (((r.parent_service_resource_cd=request->srh.inst_code_value)) OR ((r
    .child_service_resource_cd=request->srh.inst_code_value)))
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Error inactivating resource_group for institution: ",request->srh.
     inst_disp)
    GO TO exit_script
   ENDIF
   UPDATE  FROM sr_resource_group_hist s
    SET s.active_ind = 0, s.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
     updt_applctx,
     s.updt_cnt = (s.updt_cnt+ 1)
    WHERE (((s.parent_service_resource_cd=request->srh.inst_code_value)) OR ((s
    .child_service_resource_cd=request->srh.inst_code_value)))
    WITH nocounter
   ;end update
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE del_dept(x)
   SET request_cv->cd_value_list[1].action_flag = 3
   SET request_cv->cd_value_list[1].code_set = 221
   SET request_cv->cd_value_list[1].code_value = n_dept_code_value
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   IF ((reply_cv->status_data.status != "S"))
    SET error_flag = "T"
    SET error_msg = concat("Error inactivating code_value for department: ",n_description)
    GO TO exit_script
   ENDIF
   UPDATE  FROM service_resource s
    SET s.active_ind = 0, s.active_status_cd = inactive_cd, s.active_status_prsnl_id = 0,
     s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_dt_tm = cnvtdatetime(curdate,
      curtime3), s.updt_id = reqinfo->updt_id,
     s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s
     .updt_cnt+ 1)
    WHERE s.service_resource_cd=n_dept_code_value
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Error inactivating service_resource for department: ",n_description)
    GO TO exit_script
   ENDIF
   UPDATE  FROM department d
    SET d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id = reqinfo->updt_id, d.updt_task =
     reqinfo->updt_task,
     d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = (d.updt_cnt+ 1)
    WHERE d.service_resource_cd=n_dept_code_value
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Error inactivating department for department: ",n_description)
    GO TO exit_script
   ENDIF
   UPDATE  FROM resource_group r
    SET r.active_ind = 0, r.active_status_cd = inactive_cd, r.active_status_prsnl_id = 0,
     r.active_status_dt_tm = cnvtdatetime(curdate,curtime3), r.end_effective_dt_tm = cnvtdatetime(
      curdate,curtime3), r.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     r.updt_id = reqinfo->updt_id, r.updt_task = reqinfo->updt_task, r.updt_applctx = reqinfo->
     updt_applctx,
     r.updt_cnt = (r.updt_cnt+ 1)
    WHERE ((r.parent_service_resource_cd=n_dept_code_value) OR (r.child_service_resource_cd=
    n_dept_code_value))
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Error inactivating resource_group for department: ",n_description)
    GO TO exit_script
   ENDIF
   UPDATE  FROM sr_resource_group_hist s
    SET s.active_ind = 0, s.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
     updt_applctx,
     s.updt_cnt = (s.updt_cnt+ 1)
    WHERE ((s.parent_service_resource_cd=n_dept_code_value) OR (s.child_service_resource_cd=
    n_dept_code_value))
    WITH nocounter
   ;end update
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE updt_sect(x)
   SET request_cv->cd_value_list[1].action_flag = 2
   SET request_cv->cd_value_list[1].code_set = 221
   SET request_cv->cd_value_list[1].code_value = n_sect_code_value
   SET request_cv->cd_value_list[1].display = substring(1,40,n_display)
   SET request_cv->cd_value_list[1].description = substring(1,60,n_description)
   SET request_cv->cd_value_list[1].definition = substring(1,60,n_description)
   SET request_cv->cd_value_list[1].cdf_meaning = n_cdf_meaning
   SET request_cv->cd_value_list[1].active_ind = 1
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   IF ((reply_cv->status_data.status != "S"))
    SET error_flag = "T"
    SET error_msg = concat("Error updating code_value for section: ",n_description)
    GO TO exit_script
   ENDIF
   UPDATE  FROM service_resource s
    SET s.location_cd = n_location_cd, s.discipline_type_cd = n_discipline_type_cd, s
     .activity_type_cd = n_activity_type_cd,
     s.activity_subtype_cd = n_activity_subtype_cd, s.pharmacy_type_cd = n_pharmacy_type_cd, s
     .cs_login_loc_cd = n_specimen_login_cd,
     s.accn_site_prefix = n_accn_site_prefix, s.autologin_ind = n_autologin_ind, s
     .dispatch_download_ind = n_dispatch_download_ind,
     s.inventory_resource_cd = n_inventory_resource_cd, s.pat_care_loc_ind = n_pat_care_loc_ind, s
     .inv_location_cd = n_inv_location_cd,
     s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task =
     reqinfo->updt_task,
     s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s.updt_cnt+ 1)
    WHERE s.service_resource_cd=n_sect_code_value
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Error updating service_resource for section: ",n_description)
    GO TO exit_script
   ENDIF
   UPDATE  FROM section sc
    SET sc.transcript_que_cd = s_transcript_que_cd, sc.temp_multi_flag = s_temp_multi_flag, sc
     .nbr_exam_on_req = s_nbr_exam_on_req,
     sc.prelim_ind = s_prelim_ind, sc.expedite_nursing_ind = s_expedite_nursing_ind, sc.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     sc.updt_id = reqinfo->updt_id, sc.updt_task = reqinfo->updt_task, sc.updt_applctx = reqinfo->
     updt_applctx,
     sc.updt_cnt = (sc.updt_cnt+ 1)
    WHERE sc.service_resource_cd=n_sect_code_value
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Error updating section for secton: ",n_description)
    GO TO exit_script
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE del_sect(x)
   SET request_cv->cd_value_list[1].action_flag = 3
   SET request_cv->cd_value_list[1].code_set = 221
   SET request_cv->cd_value_list[1].code_value = n_sect_code_value
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   IF ((reply_cv->status_data.status != "S"))
    SET error_flag = "T"
    SET error_msg = concat("Error inactivating code_value for section: ",n_description)
    GO TO exit_script
   ENDIF
   UPDATE  FROM service_resource s
    SET s.active_ind = 0, s.active_status_cd = inactive_cd, s.active_status_prsnl_id = 0,
     s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_dt_tm = cnvtdatetime(curdate,
      curtime3), s.updt_id = reqinfo->updt_id,
     s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s
     .updt_cnt+ 1)
    WHERE s.service_resource_cd=n_sect_code_value
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Error inactivating service_resource for section: ",n_description)
    GO TO exit_script
   ENDIF
   UPDATE  FROM section sc
    SET sc.updt_dt_tm = cnvtdatetime(curdate,curtime3), sc.updt_id = reqinfo->updt_id, sc.updt_task
      = reqinfo->updt_task,
     sc.updt_applctx = reqinfo->updt_applctx, sc.updt_cnt = (sc.updt_cnt+ 1)
    WHERE sc.service_resource_cd=n_sect_code_value
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Error inactivating section for section: ",n_description)
    GO TO exit_script
   ENDIF
   UPDATE  FROM resource_group r
    SET r.active_ind = 0, r.active_status_cd = inactive_cd, r.active_status_prsnl_id = 0,
     r.active_status_dt_tm = cnvtdatetime(curdate,curtime3), r.end_effective_dt_tm = cnvtdatetime(
      curdate,curtime3), r.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     r.updt_id = reqinfo->updt_id, r.updt_task = reqinfo->updt_task, r.updt_applctx = reqinfo->
     updt_applctx,
     r.updt_cnt = (r.updt_cnt+ 1)
    WHERE ((r.parent_service_resource_cd=n_sect_code_value) OR (r.child_service_resource_cd=
    n_sect_code_value))
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Error inactivating resource_group for section: ",n_description)
    GO TO exit_script
   ENDIF
   UPDATE  FROM sr_resource_group_hist s
    SET s.active_ind = 0, s.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
     updt_applctx,
     s.updt_cnt = (s.updt_cnt+ 1)
    WHERE ((s.parent_service_resource_cd=n_sect_code_value) OR (s.child_service_resource_cd=
    n_sect_code_value))
    WITH nocounter
   ;end update
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE updt_subsect(x)
   SET request_cv->cd_value_list[1].action_flag = 2
   SET request_cv->cd_value_list[1].code_set = 221
   SET request_cv->cd_value_list[1].code_value = n_subsect_code_value
   SET request_cv->cd_value_list[1].display = substring(1,40,n_display)
   SET request_cv->cd_value_list[1].description = substring(1,60,n_description)
   SET request_cv->cd_value_list[1].definition = substring(1,60,n_description)
   SET request_cv->cd_value_list[1].cdf_meaning = n_cdf_meaning
   SET request_cv->cd_value_list[1].active_ind = 1
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   IF ((reply_cv->status_data.status != "S"))
    SET error_flag = "T"
    SET error_msg = concat("Error updating code_value for subsection: ",n_description)
    GO TO exit_script
   ENDIF
   UPDATE  FROM service_resource s
    SET s.location_cd = n_location_cd, s.discipline_type_cd = n_discipline_type_cd, s
     .activity_type_cd = n_activity_type_cd,
     s.activity_subtype_cd = n_activity_subtype_cd, s.pharmacy_type_cd = n_pharmacy_type_cd, s
     .cs_login_loc_cd = n_specimen_login_cd,
     s.accn_site_prefix = n_accn_site_prefix, s.autologin_ind = n_autologin_ind, s
     .dispatch_download_ind = n_dispatch_download_ind,
     s.inventory_resource_cd = n_inventory_resource_cd, s.pat_care_loc_ind = n_pat_care_loc_ind, s
     .inv_location_cd = n_inv_location_cd,
     s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task =
     reqinfo->updt_task,
     s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s.updt_cnt+ 1)
    WHERE s.service_resource_cd=n_subsect_code_value
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Error updating service_resource for subsection: ",n_description)
    GO TO exit_script
   ENDIF
   UPDATE  FROM sub_section ss
    SET ss.transcript_que_cd = ss_transcript_que_cd, ss.strt_model_id = ss_strt_model_id, ss
     .multiplexor_ind = ss.multiplexor_ind,
     ss.updt_dt_tm = cnvtdatetime(curdate,curtime3), ss.updt_id = reqinfo->updt_id, ss.updt_task =
     reqinfo->updt_task,
     ss.updt_applctx = reqinfo->updt_applctx, ss.updt_cnt = (ss.updt_cnt+ 1)
    WHERE ss.service_resource_cd=n_subsect_code_value
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Error updating subsection for subsection: ",n_description)
    GO TO exit_script
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE del_subsect(x)
   SET request_cv->cd_value_list[1].action_flag = 3
   SET request_cv->cd_value_list[1].code_set = 221
   SET request_cv->cd_value_list[1].code_value = n_subsect_code_value
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   IF ((reply_cv->status_data.status != "S"))
    SET error_flag = "T"
    SET error_msg = concat("Error inactivating code_value for subsection: ",n_description)
    GO TO exit_script
   ENDIF
   UPDATE  FROM service_resource s
    SET s.active_ind = 0, s.active_status_cd = inactive_cd, s.active_status_prsnl_id = 0,
     s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_dt_tm = cnvtdatetime(curdate,
      curtime3), s.updt_id = reqinfo->updt_id,
     s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s
     .updt_cnt+ 1)
    WHERE s.service_resource_cd=n_subsect_code_value
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Error inactivating service_resource for subsection: ",n_description)
    GO TO exit_script
   ENDIF
   UPDATE  FROM sub_section ss
    SET ss.updt_dt_tm = cnvtdatetime(curdate,curtime3), ss.updt_id = reqinfo->updt_id, ss.updt_task
      = reqinfo->updt_task,
     ss.updt_applctx = reqinfo->updt_applctx, ss.updt_cnt = (ss.updt_cnt+ 1)
    WHERE ss.service_resource_cd=n_subsect_code_value
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Error inactivating sub_section for subsection: ",n_description)
    GO TO exit_script
   ENDIF
   UPDATE  FROM resource_group r
    SET r.active_ind = 0, r.active_status_cd = inactive_cd, r.active_status_prsnl_id = 0,
     r.active_status_dt_tm = cnvtdatetime(curdate,curtime3), r.end_effective_dt_tm = cnvtdatetime(
      curdate,curtime3), r.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     r.updt_id = reqinfo->updt_id, r.updt_task = reqinfo->updt_task, r.updt_applctx = reqinfo->
     updt_applctx,
     r.updt_cnt = (r.updt_cnt+ 1)
    WHERE ((r.parent_service_resource_cd=n_subsect_code_value) OR (r.child_service_resource_cd=
    n_subsect_code_value))
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Error inactivating resource_group for subsection: ",n_description)
    GO TO exit_script
   ENDIF
   UPDATE  FROM sr_resource_group_hist s
    SET s.active_ind = 0, s.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
     updt_applctx,
     s.updt_cnt = (s.updt_cnt+ 1)
    WHERE ((s.parent_service_resource_cd=n_subsect_code_value) OR (s.child_service_resource_cd=
    n_subsect_code_value))
    WITH nocounter
   ;end update
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE updt_res(x)
   SET request_cv->cd_value_list[1].action_flag = 2
   SET request_cv->cd_value_list[1].code_set = 221
   SET request_cv->cd_value_list[1].code_value = n_res_code_value
   SET request_cv->cd_value_list[1].display = substring(1,40,n_display)
   SET request_cv->cd_value_list[1].description = substring(1,60,n_description)
   SET request_cv->cd_value_list[1].definition = substring(1,60,n_description)
   SET request_cv->cd_value_list[1].cdf_meaning = n_cdf_meaning
   SET request_cv->cd_value_list[1].active_ind = 1
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   IF ((reply_cv->status_data.status != "S"))
    SET error_flag = "T"
    SET error_msg = concat("Error updating code_value for resource: ",n_description)
    GO TO exit_script
   ENDIF
   UPDATE  FROM service_resource s
    SET s.discipline_type_cd = n_discipline_type_cd, s.activity_type_cd = n_activity_type_cd, s
     .activity_subtype_cd = n_activity_subtype_cd,
     s.pharmacy_type_cd = n_pharmacy_type_cd, s.cs_login_loc_cd = n_specimen_login_cd, s
     .accn_site_prefix = n_accn_site_prefix,
     s.autologin_ind = n_autologin_ind, s.dispatch_download_ind = n_dispatch_download_ind, s
     .inventory_resource_cd = n_inventory_resource_cd,
     s.pat_care_loc_ind = n_pat_care_loc_ind, s.inv_location_cd = n_inv_location_cd, s.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
     updt_applctx,
     s.updt_cnt = (s.updt_cnt+ 1)
    WHERE s.service_resource_cd=n_res_code_value
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Error updating service_resource for resource: ",n_description)
    GO TO exit_script
   ENDIF
   IF (n_cdf_meaning="BENCH")
    UPDATE  FROM lab_bench b
     SET b.worklist_build_flag = b_worklist_build_flag, b.worklist_hours = b_worklist_hours, b
      .worklist_max = b_worklist_max,
      b.container_ind = b_container_ind, b.gate_ind = b_gate_ind, b.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
      updt_applctx,
      b.updt_cnt = (b.updt_cnt+ 1)
     WHERE b.service_resource_cd=n_res_code_value
     WITH nocounter
    ;end update
   ELSEIF (n_cdf_meaning="INSTRUMENT")
    UPDATE  FROM lab_instrument i
     SET i.multiplexor_ind = i_multiplexor_ind, i.point_of_care_flag = i_point_of_care_flag, i
      .strt_model_id = i.strt_model_id,
      i.instr_identifier = i_instr_identifier, i.identifier_flag = i_identifier_flag, i
      .auto_verify_flag = i_auto_verify_flag,
      i.worklist_build_flag = i_worklist_build_flag, i.worklist_hours = i_worklist_hours, i
      .worklist_max = i_worklist_max,
      i.container_ind = i_container_ind, i.gate_ind = i_gate_ind, i.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      i.updt_id = reqinfo->updt_id, i.updt_task = reqinfo->updt_task, i.updt_applctx = reqinfo->
      updt_applctx,
      i.updt_cnt = (i.updt_cnt+ 1)
     WHERE i.service_resource_cd=n_res_code_value
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat("Error updating section for resource: ",n_description)
     GO TO exit_script
    ENDIF
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE del_res(x)
  IF ((request->srh.dept[ii].sect[jj].subsect[kk].res[ll].share_resource_ind=0))
   SET request_cv->cd_value_list[1].action_flag = 3
   SET request_cv->cd_value_list[1].code_set = 221
   SET request_cv->cd_value_list[1].code_value = n_res_code_value
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   IF ((reply_cv->status_data.status != "S"))
    SET error_flag = "T"
    SET error_msg = concat("Error inactivating code_value for resource: ",n_description)
    GO TO exit_script
   ENDIF
   UPDATE  FROM service_resource s
    SET s.active_ind = 0, s.active_status_cd = inactive_cd, s.active_status_prsnl_id = 0,
     s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_dt_tm = cnvtdatetime(curdate,
      curtime3), s.updt_id = reqinfo->updt_id,
     s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s
     .updt_cnt+ 1)
    WHERE s.service_resource_cd=n_res_code_value
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Error inactivating service_resource for resource: ",n_description)
    GO TO exit_script
   ENDIF
   UPDATE  FROM resource_group r
    SET r.active_ind = 0, r.active_status_cd = inactive_cd, r.active_status_prsnl_id = 0,
     r.active_status_dt_tm = cnvtdatetime(curdate,curtime3), r.end_effective_dt_tm = cnvtdatetime(
      curdate,curtime3), r.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     r.updt_id = reqinfo->updt_id, r.updt_task = reqinfo->updt_task, r.updt_applctx = reqinfo->
     updt_applctx,
     r.updt_cnt = (r.updt_cnt+ 1)
    WHERE ((r.parent_service_resource_cd=n_res_code_value) OR (r.child_service_resource_cd=
    n_res_code_value))
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Error inactivating resource_group for resource: ",n_description)
    GO TO exit_script
   ENDIF
   UPDATE  FROM sr_resource_group_hist s
    SET s.active_ind = 0, s.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
     updt_applctx,
     s.updt_cnt = (s.updt_cnt+ 1)
    WHERE ((s.parent_service_resource_cd=n_res_code_value) OR (s.child_service_resource_cd=
    n_res_code_value))
    WITH nocounter
   ;end update
  ELSE
   UPDATE  FROM resource_group r
    SET r.active_ind = 0, r.active_status_cd = inactive_cd, r.active_status_prsnl_id = 0,
     r.active_status_dt_tm = cnvtdatetime(curdate,curtime3), r.end_effective_dt_tm = cnvtdatetime(
      curdate,curtime3), r.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     r.updt_id = reqinfo->updt_id, r.updt_task = reqinfo->updt_task, r.updt_applctx = reqinfo->
     updt_applctx,
     r.updt_cnt = (r.updt_cnt+ 1)
    WHERE r.parent_service_resource_cd=subsect_cd
     AND r.child_service_resource_cd=n_res_code_value
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Error inactivating resource_group for resource: ",n_description)
    GO TO exit_script
   ENDIF
   UPDATE  FROM sr_resource_group_hist s
    SET s.active_ind = 0, s.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
     updt_applctx,
     s.updt_cnt = (s.updt_cnt+ 1)
    WHERE ((s.parent_service_resource_cd=subsect_cd) OR (s.child_service_resource_cd=n_res_code_value
    ))
    WITH nocounter
   ;end update
  ENDIF
  RETURN(1.0)
 END ;Subroutine
 SUBROUTINE upd_calendar(x)
   SET cdcnt = size(request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].cal_det,5)
   FOR (cc = 1 TO cdcnt)
    UPDATE  FROM loc_resource_calendar lrc
     SET lrc.priority_cd = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].cal_det[cc].
      priority_code_value, lrc.specimen_type_cd = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
      cal[mm].cal_det[cc].specimen_type_code_value, lrc.open_time = request->srh.dept[ii].sect[jj].
      subsect[kk].res[ll].cal[mm].cal_det[cc].open_time,
      lrc.close_time = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].cal_det[cc].
      close_time, lrc.dow = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].cal_det[cc].
      dow, lrc.age_from_minutes = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].cal_det[
      cc].age_from_minutes,
      lrc.age_from_units_cd = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].cal_det[cc].
      age_from_code_value, lrc.age_to_minutes = request->srh.dept[ii].sect[jj].subsect[kk].res[ll].
      cal[mm].cal_det[cc].age_to_minutes, lrc.age_to_units_cd = request->srh.dept[ii].sect[jj].
      subsect[kk].res[ll].cal[mm].cal_det[cc].age_to_code_value,
      lrc.updt_dt_tm = cnvtdatetime(curdate,curtime3), lrc.updt_id = reqinfo->updt_id, lrc.updt_task
       = reqinfo->updt_task,
      lrc.updt_applctx = reqinfo->updt_applctx, lrc.updt_cnt = (lrc.updt_cnt+ 1)
     WHERE (lrc.service_resource_cd=request->srh.dept[ii].sect[jj].subsect[kk].res[ll].res_code_value
     )
      AND (lrc.location_cd=request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].loc_code_value)
      AND (lrc.loc_resource_type_cd=request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].
     loc_res_type_code_value)
      AND (lrc.sequence=request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].sequence)
      AND (lrc.calendar_seq=request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].cal_det[cc].
     calendar_seq)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "T"
     SET error_text = concat("error updating loc_resource_calendar for resource: ",cnvtstring(request
       ->srh.dept[ii].sect[jj].subsect[kk].res[ll].res_code_value))
    ENDIF
   ENDFOR
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE clean_old_cals(x)
   IF (n_lab_svc_area_cd=0)
    SELECT INTO "nl:"
     l.location_cd
     FROM loc_resource_r l
     WHERE (l.service_resource_cd=request->srh.dept[ii].sect[jj].subsect[kk].res[ll].res_code_value)
     DETAIL
      n_lab_svc_area_cd = l.location_cd
     WITH nocounter
    ;end select
   ENDIF
   DELETE  FROM loc_resource_r l
    WHERE (l.service_resource_cd=request->srh.dept[ii].sect[jj].subsect[kk].res[ll].res_code_value)
    WITH nocounter
   ;end delete
   DELETE  FROM loc_resource_calendar lrc
    WHERE (lrc.service_resource_cd=request->srh.dept[ii].sect[jj].subsect[kk].res[ll].res_code_value)
    WITH nocounter
   ;end delete
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE del_calendar(x)
   DELETE  FROM loc_resource_r l
    WHERE (l.service_resource_cd=request->srh.dept[ii].sect[jj].subsect[kk].res[ll].res_code_value)
     AND (l.location_cd=request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].loc_code_value)
     AND (l.loc_resource_type_cd=request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].
    loc_res_type_code_value)
     AND (l.sequence=request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].sequence)
    WITH nocounter
   ;end delete
   DELETE  FROM loc_resource_calendar lrc
    WHERE (lrc.service_resource_cd=request->srh.dept[ii].sect[jj].subsect[kk].res[ll].res_code_value)
     AND (lrc.location_cd=request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].loc_code_value)
     AND (lrc.loc_resource_type_cd=request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].
    loc_res_type_code_value)
     AND (lrc.sequence=request->srh.dept[ii].sect[jj].subsect[kk].res[ll].cal[mm].sequence)
    WITH nocounter
   ;end delete
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE get_disc_type_code(xx)
  SET s_disc_type_cd = 0.0
  FOR (i = 1 TO disccnt)
    IF (s_disc_type_mean > " "
     AND (s_disc_type_mean=disc_type->disc_type_list[i].disc_type_mean))
     SET s_disc_type_cd = disc_type->disc_type_list[i].disc_type_code_value
    ELSEIF ((s_disc_type_dispkey=disc_type->disc_type_list[i].disc_type_dispkey))
     SET s_disc_type_cd = disc_type->disc_type_list[i].disc_type_code_value
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE get_act_type_code(xx)
  SET s_act_type_cd = 0.0
  FOR (i = 1 TO actcnt)
    IF (s_act_type_mean > " "
     AND (s_act_type_mean=act_type->act_type_list[i].act_type_mean))
     SET s_act_type_cd = act_type->act_type_list[i].act_type_code_value
    ELSEIF ((s_act_type_dispkey=act_type->act_type_list[i].act_type_dispkey))
     SET s_act_type_cd = act_type->act_type_list[i].act_type_code_value
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE get_act_subtype_code(xx)
  SET s_act_subtype_cd = 0.0
  FOR (i = 1 TO asubcnt)
    IF (s_act_subtype_mean > " "
     AND (s_act_subtype_mean=act_subtype->act_subtype_list[i].act_subtype_mean))
     SET s_act_subtype_cd = act_subtype->act_subtype_list[i].act_subtype_code_value
    ELSEIF ((s_act_subtype_dispkey=act_subtype->act_subtype_list[i].act_subtype_dispkey))
     SET s_act_subtype_cd = act_subtype->act_subtype_list[i].act_subtype_code_value
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE get_prio_code(xx)
  SET s_prio_cd = 0.0
  FOR (i = 1 TO priocnt)
    IF (s_prio_mean > " "
     AND s_prio_mean=cnvtupper(prio->prio_list[i].prio_mean))
     SET s_prio_cd = prio->prio_list[i].prio_code_value
    ELSEIF (s_prio_dispkey=cnvtupper(prio->prio_list[i].prio_dispkey))
     SET s_prio_cd = prio->prio_list[i].prio_code_value
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE get_spectype_code(xx)
  SET s_spectype_cd = 0.0
  FOR (i = 1 TO spectypecnt)
    IF ((s_spectype_dispkey=spectype->spectype_list[i].spectype_dispkey))
     SET s_spectype_cd = spectype->spectype_list[i].spectype_code_value
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE get_age_code(xx)
  SET s_age_cd = 0.0
  FOR (i = 1 TO agecnt)
    IF (s_age_mean > " "
     AND (s_age_mean=age->age_list[i].age_mean))
     SET s_age_cd = age->age_list[i].age_code_value
    ELSEIF ((s_age_dispkey=age->age_list[i].age_dispkey))
     SET s_age_cd = age->age_list[i].age_code_value
    ENDIF
  ENDFOR
 END ;Subroutine
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (error_flag="T")
  CALL echo(error_msg)
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_SRVRES_HIER","  >> ERROR MSG: ",error_msg
   )
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
