CREATE PROGRAM bed_get_srvres_hier:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 srh[*]
     2 inst_code_value = f8
     2 inst_disp = vc
     2 inst_desc = vc
     2 org_id = f8
     2 dept_list[*]
       3 dept_code_value = f8
       3 dept_disp = vc
       3 dept_desc = vc
       3 dept_disc_type_code_value = f8
       3 dept_disc_type_disp = vc
       3 dept_disc_type_mean = vc
       3 dept_act_type_code_value = f8
       3 dept_act_type_disp = vc
       3 dept_act_type_mean = vc
       3 dept_act_subtype_code_value = f8
       3 dept_act_subtype_disp = vc
       3 dept_act_subtype_mean = vc
       3 sequence = i4
       3 active_ind = i2
       3 sect_list[*]
         4 sect_code_value = f8
         4 sect_disp = vc
         4 sect_desc = vc
         4 sect_mean = vc
         4 sect_disc_type_code_value = f8
         4 sect_disc_type_disp = vc
         4 sect_disc_type_mean = vc
         4 sect_act_type_code_value = f8
         4 sect_act_type_disp = vc
         4 sect_act_type_mean = vc
         4 sect_act_subtype_code_value = f8
         4 sect_act_subtype_disp = vc
         4 sect_act_subtype_mean = vc
         4 sequence = i4
         4 active_ind = i2
         4 subsect_list[*]
           5 subsect_code_value = f8
           5 subsect_disp = vc
           5 subsect_desc = vc
           5 subsect_mean = vc
           5 subsect_disc_type_code_value = f8
           5 subsect_disc_type_disp = vc
           5 subsect_disc_type_mean = vc
           5 subsect_act_type_code_value = f8
           5 subsect_act_type_disp = vc
           5 subsect_act_type_mean = vc
           5 subsect_act_subtype_code_value = f8
           5 subsect_act_subtype_disp = vc
           5 subsect_act_subtype_mean = vc
           5 sequence = i4
           5 multiplexor_ind = i2
           5 active_ind = i2
           5 res_list[*]
             6 res_code_value = f8
             6 res_disp = vc
             6 res_desc = vc
             6 res_mean = vc
             6 res_type_code_value = f8
             6 res_type_mean = vc
             6 res_type_disp = vc
             6 res_type_desc = vc
             6 res_disc_type_code_value = f8
             6 res_disc_type_disp = vc
             6 res_disc_type_mean = vc
             6 res_act_type_code_value = f8
             6 res_act_type_disp = vc
             6 res_act_type_mean = vc
             6 res_act_subtype_code_value = f8
             6 res_act_subtype_disp = vc
             6 res_act_subtype_mean = vc
             6 sequence = i4
             6 active_ind = i2
             6 cal_list[*]
               7 loc_code_value = f8
               7 loc_disp = vc
               7 loc_res_type_code_value = f8
               7 loc_res_type_mean = vc
               7 loc_res_type_disp = vc
               7 avail_ind = i2
               7 description = vc
               7 sequence = i4
               7 active_ind = i2
               7 cal_det[*]
                 8 calendar_seq = i4
                 8 dow = i4
                 8 priority_code_value = f8
                 8 priority_disp = vc
                 8 priority_mean = vc
                 8 open_time = i4
                 8 close_time = i4
                 8 spectype_code_value = f8
                 8 spectype_disp = vc
                 8 spectype_mean = vc
                 8 dispense_type_code_value = f8
                 8 dispense_type_disp = vc
                 8 dispense_type_mean = vc
                 8 age_from_minutes = i4
                 8 age_from_code_value = f8
                 8 age_from_disp = vc
                 8 age_from_mean = vc
                 8 age_to_minutes = i4
                 8 age_to_code_value = f8
                 8 age_to_disp = vc
                 8 age_to_mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD disc_type(
   1 disc_type_list[*]
     2 disc_type_code_value = f8
     2 disc_type_disp = vc
     2 disc_type_mean = vc
 )
 RECORD act_type(
   1 act_type_list[*]
     2 act_type_code_value = f8
     2 act_type_disp = vc
     2 act_type_mean = vc
 )
 RECORD act_subtype(
   1 act_subtype_list[*]
     2 act_subtype_code_value = f8
     2 act_subtype_disp = vc
     2 act_subtype_mean = vc
 )
 RECORD prio(
   1 prio_list[*]
     2 prio_code_value = f8
     2 prio_disp = vc
     2 prio_mean = vc
 )
 RECORD spectype(
   1 spectype_list[*]
     2 spectype_code_value = f8
     2 spectype_disp = vc
     2 spectype_mean = vc
 )
 RECORD age(
   1 age_list[*]
     2 age_code_value = f8
     2 age_disp = vc
     2 age_mean = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET icnt = 0
 SET instcnt = 0
 SET deptcnt = 0
 SET sectcnt = 0
 SET subsectcnt = 0
 SET rescnt = 0
 SET calcnt = 0
 SET error_flag = "F"
 SET iic = 0
 SET iic = request->include_inactive_child_ind
 SET disccnt = 0
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
   .disc_type_mean = cv.cdf_meaning
  WITH nocounter
 ;end select
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
   act_type_mean = cv.cdf_meaning
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
   act_subtype_list[asubcnt].act_subtype_mean = cv.cdf_meaning
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
   prio->prio_list[priocnt].prio_disp = cv.display, prio->prio_list[priocnt].prio_mean = cv
   .cdf_meaning
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
   spectypecnt].spectype_mean = cv.cdf_meaning
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
   age->age_list[agecnt].age_disp = cv.display, age->age_list[agecnt].age_mean = cv.cdf_meaning
  WITH nocounter
 ;end select
 SET inst_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=223
    AND cv.cdf_meaning="INSTITUTION")
  ORDER BY cv.code_value
  HEAD cv.code_value
   inst_cd = cv.code_value
  WITH nocounter
 ;end select
 SET dept_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=223
    AND cv.cdf_meaning="DEPARTMENT")
  ORDER BY cv.code_value
  HEAD cv.code_value
   dept_cd = cv.code_value
  WITH nocounter
 ;end select
 SET sect_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=223
    AND cv.cdf_meaning="SECTION")
  ORDER BY cv.code_value
  HEAD cv.code_value
   sect_cd = cv.code_value
  WITH nocounter
 ;end select
 SET subsect_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=223
    AND cv.cdf_meaning="SUBSECTION")
  ORDER BY cv.code_value
  HEAD cv.code_value
   subsect_cd = cv.code_value
  WITH nocounter
 ;end select
 SET instr_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=223
    AND cv.cdf_meaning="INSTRUMENT")
  ORDER BY cv.code_value
  HEAD cv.code_value
   instr_cd = cv.code_value
  WITH nocounter
 ;end select
 SET bench_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=223
    AND cv.cdf_meaning="BENCH")
  ORDER BY cv.code_value
  HEAD cv.code_value
   bench_cd = cv.code_value
  WITH nocounter
 ;end select
 DECLARE discparse = vc
 SET dcnt = size(request->disc_list,5)
 IF (dcnt > 0)
  SET discparse =
  "sr.service_resource_cd = rg.child_service_resource_cd and sr.discipline_type_cd in ("
  FOR (i = 1 TO dcnt)
    SET dcode = 0
    FOR (j = 1 TO disccnt)
      IF ((request->disc_list[i].disc_meaning=disc_type->disc_type_list[j].disc_type_mean))
       SET dcode = disc_type->disc_type_list[j].disc_type_code_value
      ENDIF
    ENDFOR
    SET discparse = build(discparse,dcode)
    IF (dcnt > 1
     AND i < dcnt)
     SET discparse = concat(discparse,",")
    ENDIF
  ENDFOR
  SET discparse = concat(discparse,")")
 ELSE
  SET discparse = "sr.service_resource_cd = rg.child_service_resource_cd"
 ENDIF
 SET icnt = size(request->inst_list,5)
 IF (icnt <= 0)
  SET error_flag = "T"
  SET error_msg = concat("No institutions present in request structure. Script terminating.")
  GO TO exit_script
 ENDIF
 FOR (ii = 1 TO icnt)
  SELECT DISTINCT INTO "nl:"
   FROM code_value cv,
    service_resource sr
   PLAN (cv
    WHERE (cv.code_value=request->inst_list[ii].inst_cd)
     AND cv.code_set=221
     AND cv.cdf_meaning="INSTITUTION")
    JOIN (sr
    WHERE cv.code_value=sr.service_resource_cd)
   ORDER BY cv.code_value, sr.service_resource_cd
   HEAD cv.code_value
    instcnt = (instcnt+ 1), stat = alterlist(reply->srh,instcnt), reply->srh[instcnt].inst_code_value
     = cv.code_value,
    reply->srh[instcnt].inst_disp = cv.display, reply->srh[instcnt].inst_desc = cv.description, reply
    ->srh[instcnt].org_id = sr.organization_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET error_flag = "T"
   SET error_msg = concat("Unable to retrieve institution code: ",cnvtstring(request->inst_list[ii].
     inst_cd))
   GO TO exit_script
  ENDIF
 ENDFOR
 FOR (ii = 1 TO instcnt)
  SET deptcnt = 0
  SELECT INTO "nl:"
   FROM resource_group rg,
    service_resource sr,
    code_value cv
   PLAN (rg
    WHERE (rg.parent_service_resource_cd=reply->srh[ii].inst_code_value)
     AND ((rg.active_ind=1) OR (iic=1)) )
    JOIN (cv
    WHERE cv.code_value=rg.child_service_resource_cd
     AND cv.cdf_meaning="DEPARTMENT")
    JOIN (sr
    WHERE parser(discparse))
   ORDER BY rg.parent_service_resource_cd, rg.child_service_resource_cd, cv.code_value,
    sr.service_resource_cd
   HEAD rg.child_service_resource_cd
    deptcnt = (deptcnt+ 1), stat = alterlist(reply->srh[ii].dept_list,deptcnt), reply->srh[ii].
    dept_list[deptcnt].dept_code_value = rg.child_service_resource_cd,
    reply->srh[ii].dept_list[deptcnt].sequence = rg.sequence, reply->srh[ii].dept_list[deptcnt].
    active_ind = rg.active_ind
   HEAD cv.code_value
    reply->srh[ii].dept_list[deptcnt].dept_disp = cv.display, reply->srh[ii].dept_list[deptcnt].
    dept_desc = cv.description
    FOR (x = 1 TO disccnt)
      IF ((disc_type->disc_type_list[x].disc_type_code_value=sr.discipline_type_cd))
       reply->srh[ii].dept_list[deptcnt].dept_disc_type_code_value = disc_type->disc_type_list[x].
       disc_type_code_value, reply->srh[ii].dept_list[deptcnt].dept_disc_type_disp = disc_type->
       disc_type_list[x].disc_type_disp, reply->srh[ii].dept_list[deptcnt].dept_disc_type_mean =
       disc_type->disc_type_list[x].disc_type_mean
      ENDIF
    ENDFOR
    FOR (x = 1 TO actcnt)
      IF ((act_type->act_type_list[x].act_type_code_value=sr.activity_type_cd))
       reply->srh[ii].dept_list[deptcnt].dept_act_type_code_value = act_type->act_type_list[x].
       act_type_code_value, reply->srh[ii].dept_list[deptcnt].dept_act_type_disp = act_type->
       act_type_list[x].act_type_disp, reply->srh[ii].dept_list[deptcnt].dept_act_type_mean =
       act_type->act_type_list[x].act_type_mean
      ENDIF
    ENDFOR
    FOR (x = 1 TO asubcnt)
      IF ((act_subtype->act_subtype_list[x].act_subtype_code_value=sr.activity_subtype_cd))
       reply->srh[ii].dept_list[deptcnt].dept_act_subtype_code_value = act_subtype->act_subtype_list[
       x].act_subtype_code_value, reply->srh[ii].dept_list[deptcnt].dept_act_subtype_disp =
       act_subtype->act_subtype_list[x].act_subtype_disp, reply->srh[ii].dept_list[deptcnt].
       dept_act_subtype_mean = act_subtype->act_subtype_list[x].act_subtype_mean
      ENDIF
    ENDFOR
   WITH nocounter
  ;end select
 ENDFOR
 FOR (ii = 1 TO instcnt)
  SET deptcnt = size(reply->srh[ii].dept_list,5)
  IF (deptcnt > 0)
   FOR (i = 1 TO deptcnt)
    SELECT INTO "nl:"
     FROM resource_group rg,
      service_resource sr,
      code_value cv,
      br_name_value b
     PLAN (rg
      WHERE (rg.parent_service_resource_cd=reply->srh[ii].dept_list[i].dept_code_value)
       AND ((rg.active_ind=1) OR (iic=1)) )
      JOIN (cv
      WHERE cv.code_value=rg.child_service_resource_cd)
      JOIN (sr
      WHERE sr.service_resource_cd=outerjoin(rg.child_service_resource_cd))
      JOIN (b
      WHERE b.br_nv_key1=outerjoin("SR_SECTION")
       AND b.br_value=outerjoin(cnvtstring(rg.child_service_resource_cd)))
     ORDER BY rg.parent_service_resource_cd, rg.child_service_resource_cd, cv.code_value,
      sr.service_resource_cd
     HEAD REPORT
      sectcnt = 0
     HEAD rg.child_service_resource_cd
      sectcnt = (sectcnt+ 1), stat = alterlist(reply->srh[ii].dept_list[i].sect_list,sectcnt), reply
      ->srh[ii].dept_list[i].sect_list[sectcnt].sect_code_value = rg.child_service_resource_cd,
      reply->srh[ii].dept_list[i].sect_list[sectcnt].sequence = rg.sequence, reply->srh[ii].
      dept_list[i].sect_list[sectcnt].active_ind = rg.active_ind
     HEAD cv.code_value
      reply->srh[ii].dept_list[i].sect_list[sectcnt].sect_disp = cv.display, reply->srh[ii].
      dept_list[i].sect_list[sectcnt].sect_desc = cv.description
      IF (b.br_name > "  ")
       reply->srh[ii].dept_list[i].sect_list[sectcnt].sect_mean = b.br_name
      ENDIF
      FOR (x = 1 TO disccnt)
        IF ((disc_type->disc_type_list[x].disc_type_code_value=sr.discipline_type_cd))
         reply->srh[ii].dept_list[i].sect_list[sectcnt].sect_disc_type_code_value = disc_type->
         disc_type_list[x].disc_type_code_value, reply->srh[ii].dept_list[i].sect_list[sectcnt].
         sect_disc_type_disp = disc_type->disc_type_list[x].disc_type_disp, reply->srh[ii].dept_list[
         i].sect_list[sectcnt].sect_disc_type_mean = disc_type->disc_type_list[x].disc_type_mean
        ENDIF
      ENDFOR
      FOR (x = 1 TO actcnt)
        IF ((act_type->act_type_list[x].act_type_code_value=sr.activity_type_cd))
         reply->srh[ii].dept_list[i].sect_list[sectcnt].sect_act_type_code_value = act_type->
         act_type_list[x].act_type_code_value, reply->srh[ii].dept_list[i].sect_list[sectcnt].
         sect_act_type_disp = act_type->act_type_list[x].act_type_disp, reply->srh[ii].dept_list[i].
         sect_list[sectcnt].sect_act_type_mean = act_type->act_type_list[x].act_type_mean
        ENDIF
      ENDFOR
      FOR (x = 1 TO asubcnt)
        IF ((act_subtype->act_subtype_list[x].act_subtype_code_value=sr.activity_subtype_cd))
         reply->srh[ii].dept_list[i].sect_list[sectcnt].sect_act_subtype_code_value = act_subtype->
         act_subtype_list[x].act_subtype_code_value, reply->srh[ii].dept_list[i].sect_list[sectcnt].
         sect_act_subtype_disp = act_subtype->act_subtype_list[x].act_subtype_disp, reply->srh[ii].
         dept_list[i].sect_list[sectcnt].sect_act_subtype_mean = act_subtype->act_subtype_list[x].
         act_subtype_mean
        ENDIF
      ENDFOR
     WITH nocounter
    ;end select
    IF (sectcnt > 0)
     FOR (j = 1 TO sectcnt)
      SELECT INTO "nl:"
       FROM resource_group rg,
        service_resource sr,
        code_value cv,
        sub_section ss,
        br_name_value b
       PLAN (rg
        WHERE (rg.parent_service_resource_cd=reply->srh[ii].dept_list[i].sect_list[j].sect_code_value
        )
         AND ((rg.active_ind=1) OR (iic=1)) )
        JOIN (cv
        WHERE cv.code_value=rg.child_service_resource_cd)
        JOIN (sr
        WHERE sr.service_resource_cd=outerjoin(rg.child_service_resource_cd))
        JOIN (ss
        WHERE ss.service_resource_cd=outerjoin(rg.child_service_resource_cd))
        JOIN (b
        WHERE b.br_nv_key1=outerjoin("SR_SUBSECTION")
         AND b.br_value=outerjoin(cnvtstring(rg.child_service_resource_cd)))
       ORDER BY rg.parent_service_resource_cd, rg.child_service_resource_cd, cv.code_value,
        sr.service_resource_cd
       HEAD REPORT
        subsectcnt = 0
       HEAD rg.child_service_resource_cd
        subsectcnt = (subsectcnt+ 1), stat = alterlist(reply->srh[ii].dept_list[i].sect_list[j].
         subsect_list,subsectcnt), reply->srh[ii].dept_list[i].sect_list[j].subsect_list[subsectcnt].
        subsect_code_value = rg.child_service_resource_cd,
        reply->srh[ii].dept_list[i].sect_list[j].subsect_list[subsectcnt].sequence = rg.sequence,
        reply->srh[ii].dept_list[i].sect_list[j].subsect_list[subsectcnt].active_ind = rg.active_ind
       HEAD cv.code_value
        reply->srh[ii].dept_list[i].sect_list[j].subsect_list[subsectcnt].subsect_disp = cv.display,
        reply->srh[ii].dept_list[i].sect_list[j].subsect_list[subsectcnt].subsect_desc = cv
        .description
        IF (b.br_name > "  ")
         reply->srh[ii].dept_list[i].sect_list[j].subsect_list[subsectcnt].subsect_mean = b.br_name
        ENDIF
        reply->srh[ii].dept_list[i].sect_list[j].subsect_list[subsectcnt].multiplexor_ind = ss
        .multiplexor_ind
        FOR (x = 1 TO disccnt)
          IF ((disc_type->disc_type_list[x].disc_type_code_value=sr.discipline_type_cd))
           reply->srh[ii].dept_list[i].sect_list[j].subsect_list[subsectcnt].
           subsect_disc_type_code_value = disc_type->disc_type_list[x].disc_type_code_value, reply->
           srh[ii].dept_list[i].sect_list[j].subsect_list[subsectcnt].subsect_disc_type_disp =
           disc_type->disc_type_list[x].disc_type_disp, reply->srh[ii].dept_list[i].sect_list[j].
           subsect_list[subsectcnt].subsect_disc_type_mean = disc_type->disc_type_list[x].
           disc_type_mean
          ENDIF
        ENDFOR
        FOR (x = 1 TO actcnt)
          IF ((act_type->act_type_list[x].act_type_code_value=sr.activity_type_cd))
           reply->srh[ii].dept_list[i].sect_list[j].subsect_list[subsectcnt].
           subsect_act_type_code_value = act_type->act_type_list[x].act_type_code_value, reply->srh[
           ii].dept_list[i].sect_list[j].subsect_list[subsectcnt].subsect_act_type_disp = act_type->
           act_type_list[x].act_type_disp, reply->srh[ii].dept_list[i].sect_list[j].subsect_list[
           subsectcnt].subsect_act_type_mean = act_type->act_type_list[x].act_type_mean
          ENDIF
        ENDFOR
        FOR (x = 1 TO asubcnt)
          IF ((act_subtype->act_subtype_list[x].act_subtype_code_value=sr.activity_subtype_cd))
           reply->srh[ii].dept_list[i].sect_list[j].subsect_list[subsectcnt].
           subsect_act_subtype_code_value = act_subtype->act_subtype_list[x].act_subtype_code_value,
           reply->srh[ii].dept_list[i].sect_list[j].subsect_list[subsectcnt].subsect_act_subtype_disp
            = act_subtype->act_subtype_list[x].act_subtype_disp, reply->srh[ii].dept_list[i].
           sect_list[j].subsect_list[subsectcnt].subsect_act_subtype_mean = act_subtype->
           act_subtype_list[x].act_subtype_mean
          ENDIF
        ENDFOR
       WITH nocounter
      ;end select
      IF (subsectcnt > 0)
       FOR (k = 1 TO subsectcnt)
        SELECT INTO "nl:"
         FROM resource_group rg,
          service_resource sr,
          code_value cv,
          code_value cv2,
          br_name_value b
         PLAN (rg
          WHERE (rg.parent_service_resource_cd=reply->srh[ii].dept_list[i].sect_list[j].subsect_list[
          k].subsect_code_value)
           AND ((rg.active_ind=1) OR (iic=1)) )
          JOIN (cv
          WHERE cv.code_value=rg.child_service_resource_cd)
          JOIN (sr
          WHERE sr.service_resource_cd=outerjoin(rg.child_service_resource_cd))
          JOIN (cv2
          WHERE cv2.code_value=outerjoin(sr.service_resource_type_cd))
          JOIN (b
          WHERE b.br_nv_key1=outerjoin("SR_RESOURCE")
           AND b.br_value=outerjoin(cnvtstring(rg.child_service_resource_cd)))
         ORDER BY rg.parent_service_resource_cd, rg.child_service_resource_cd, cv.code_value,
          cv2.code_value
         HEAD REPORT
          rescnt = 0
         HEAD rg.child_service_resource_cd
          rescnt = (rescnt+ 1), stat = alterlist(reply->srh[ii].dept_list[i].sect_list[j].
           subsect_list[k].res_list,rescnt), reply->srh[ii].dept_list[i].sect_list[j].subsect_list[k]
          .res_list[rescnt].sequence = rg.sequence,
          reply->srh[ii].dept_list[i].sect_list[j].subsect_list[k].res_list[rescnt].res_code_value =
          rg.child_service_resource_cd, reply->srh[ii].dept_list[i].sect_list[j].subsect_list[k].
          res_list[rescnt].active_ind = rg.active_ind
         HEAD cv.code_value
          reply->srh[ii].dept_list[i].sect_list[j].subsect_list[k].res_list[rescnt].res_disp = cv
          .display, reply->srh[ii].dept_list[i].sect_list[j].subsect_list[k].res_list[rescnt].
          res_desc = cv.description
          IF (b.br_name > "  ")
           reply->srh[ii].dept_list[i].sect_list[j].subsect_list[k].res_list[rescnt].res_mean = b
           .br_name
          ENDIF
         HEAD cv2.code_value
          reply->srh[ii].dept_list[i].sect_list[j].subsect_list[k].res_list[rescnt].
          res_type_code_value = cv2.code_value, reply->srh[ii].dept_list[i].sect_list[j].
          subsect_list[k].res_list[rescnt].res_type_disp = cv2.display, reply->srh[ii].dept_list[i].
          sect_list[j].subsect_list[k].res_list[rescnt].res_type_mean = cv2.cdf_meaning,
          reply->srh[ii].dept_list[i].sect_list[j].subsect_list[k].res_list[rescnt].res_type_desc =
          cv.description
          FOR (x = 1 TO disccnt)
            IF ((disc_type->disc_type_list[x].disc_type_code_value=sr.discipline_type_cd))
             reply->srh[ii].dept_list[i].sect_list[j].subsect_list[k].res_list[rescnt].
             res_disc_type_code_value = disc_type->disc_type_list[x].disc_type_code_value, reply->
             srh[ii].dept_list[i].sect_list[j].subsect_list[k].res_list[rescnt].res_disc_type_disp =
             disc_type->disc_type_list[x].disc_type_disp, reply->srh[ii].dept_list[i].sect_list[j].
             subsect_list[k].res_list[rescnt].res_disc_type_mean = disc_type->disc_type_list[x].
             disc_type_mean
            ENDIF
          ENDFOR
          FOR (x = 1 TO actcnt)
            IF ((act_type->act_type_list[x].act_type_code_value=sr.activity_type_cd))
             reply->srh[ii].dept_list[i].sect_list[j].subsect_list[k].res_list[rescnt].
             res_act_type_code_value = act_type->act_type_list[x].act_type_code_value, reply->srh[ii]
             .dept_list[i].sect_list[j].subsect_list[k].res_list[rescnt].res_act_type_disp = act_type
             ->act_type_list[x].act_type_disp, reply->srh[ii].dept_list[i].sect_list[j].subsect_list[
             k].res_list[rescnt].res_act_type_mean = act_type->act_type_list[x].act_type_mean
            ENDIF
          ENDFOR
          FOR (x = 1 TO asubcnt)
            IF ((act_subtype->act_subtype_list[x].act_subtype_code_value=sr.activity_subtype_cd))
             reply->srh[ii].dept_list[i].sect_list[j].subsect_list[k].res_list[rescnt].
             res_act_subtype_code_value = act_subtype->act_subtype_list[x].act_subtype_code_value,
             reply->srh[ii].dept_list[i].sect_list[j].subsect_list[k].res_list[rescnt].
             res_act_subtype_disp = act_subtype->act_subtype_list[x].act_subtype_disp, reply->srh[ii]
             .dept_list[i].sect_list[j].subsect_list[k].res_list[rescnt].res_act_subtype_mean =
             act_subtype->act_subtype_list[x].act_subtype_mean
            ENDIF
          ENDFOR
         WITH nocounter
        ;end select
        IF (rescnt > 0)
         FOR (l = 1 TO rescnt)
           SELECT INTO "nl:"
            FROM loc_resource_calendar lrc,
             code_value cv,
             code_value cv2
            PLAN (lrc
             WHERE (lrc.service_resource_cd=reply->srh[ii].dept_list[i].sect_list[j].subsect_list[k].
             res_list[l].res_code_value)
              AND ((lrc.active_ind=1) OR (iic=1)) )
             JOIN (cv
             WHERE cv.code_value=lrc.location_cd)
             JOIN (cv2
             WHERE cv2.code_value=outerjoin(lrc.loc_resource_type_cd))
            ORDER BY lrc.service_resource_cd, lrc.sequence, lrc.calendar_seq
            HEAD REPORT
             calcnt = 0
            HEAD lrc.sequence
             calcnt = (calcnt+ 1), dc = 0, stat = alterlist(reply->srh[ii].dept_list[i].sect_list[j].
              subsect_list[k].res_list[l].cal_list,calcnt),
             reply->srh[ii].dept_list[i].sect_list[j].subsect_list[k].res_list[l].cal_list[calcnt].
             loc_code_value = lrc.location_cd, reply->srh[ii].dept_list[i].sect_list[j].subsect_list[
             k].res_list[l].cal_list[calcnt].description = lrc.description, reply->srh[ii].dept_list[
             i].sect_list[j].subsect_list[k].res_list[l].cal_list[calcnt].sequence = lrc.sequence,
             reply->srh[ii].dept_list[i].sect_list[j].subsect_list[k].res_list[l].cal_list[calcnt].
             avail_ind = lrc.avail_ind, reply->srh[ii].dept_list[i].sect_list[j].subsect_list[k].
             res_list[l].cal_list[calcnt].loc_disp = cv.display, reply->srh[ii].dept_list[i].
             sect_list[j].subsect_list[k].res_list[l].cal_list[calcnt].loc_res_type_code_value = cv2
             .code_value,
             reply->srh[ii].dept_list[i].sect_list[j].subsect_list[k].res_list[l].cal_list[calcnt].
             loc_res_type_disp = cv2.display, reply->srh[ii].dept_list[i].sect_list[j].subsect_list[k
             ].res_list[l].cal_list[calcnt].loc_res_type_mean = cv2.cdf_meaning, reply->srh[ii].
             dept_list[i].sect_list[j].subsect_list[k].res_list[l].cal_list[calcnt].active_ind = lrc
             .active_ind
            HEAD lrc.calendar_seq
             dc = (dc+ 1), stat = alterlist(reply->srh[ii].dept_list[i].sect_list[j].subsect_list[k].
              res_list[l].cal_list[calcnt].cal_det,dc), reply->srh[ii].dept_list[i].sect_list[j].
             subsect_list[k].res_list[l].cal_list[calcnt].cal_det[dc].calendar_seq = lrc.calendar_seq,
             reply->srh[ii].dept_list[i].sect_list[j].subsect_list[k].res_list[l].cal_list[calcnt].
             cal_det[dc].dow = lrc.dow, reply->srh[ii].dept_list[i].sect_list[j].subsect_list[k].
             res_list[l].cal_list[calcnt].cal_det[dc].open_time = lrc.open_time, reply->srh[ii].
             dept_list[i].sect_list[j].subsect_list[k].res_list[l].cal_list[calcnt].cal_det[dc].
             close_time = lrc.close_time,
             reply->srh[ii].dept_list[i].sect_list[j].subsect_list[k].res_list[l].cal_list[calcnt].
             cal_det[dc].age_from_minutes = lrc.age_from_minutes, reply->srh[ii].dept_list[i].
             sect_list[j].subsect_list[k].res_list[l].cal_list[calcnt].cal_det[dc].age_to_minutes =
             lrc.age_to_minutes
             FOR (x = 1 TO priocnt)
               IF ((prio->prio_list[x].prio_code_value=lrc.priority_cd))
                reply->srh[ii].dept_list[i].sect_list[j].subsect_list[k].res_list[l].cal_list[calcnt]
                .cal_det[dc].priority_code_value = prio->prio_list[x].prio_code_value, reply->srh[ii]
                .dept_list[i].sect_list[j].subsect_list[k].res_list[l].cal_list[calcnt].cal_det[dc].
                priority_disp = prio->prio_list[x].prio_disp, reply->srh[ii].dept_list[i].sect_list[j
                ].subsect_list[k].res_list[l].cal_list[calcnt].cal_det[dc].priority_mean = prio->
                prio_list[x].prio_mean
               ENDIF
             ENDFOR
             FOR (x = 1 TO spectypecnt)
               IF ((spectype->spectype_list[x].spectype_code_value=lrc.specimen_type_cd))
                reply->srh[ii].dept_list[i].sect_list[j].subsect_list[k].res_list[l].cal_list[calcnt]
                .cal_det[dc].spectype_code_value = spectype->spectype_list[x].spectype_code_value,
                reply->srh[ii].dept_list[i].sect_list[j].subsect_list[k].res_list[l].cal_list[calcnt]
                .cal_det[dc].spectype_disp = spectype->spectype_list[x].spectype_disp, reply->srh[ii]
                .dept_list[i].sect_list[j].subsect_list[k].res_list[l].cal_list[calcnt].cal_det[dc].
                spectype_mean = spectype->spectype_list[x].spectype_mean
               ENDIF
             ENDFOR
             FOR (x = 1 TO agecnt)
               IF ((age->age_list[x].age_code_value=lrc.age_from_units_cd))
                reply->srh[ii].dept_list[i].sect_list[j].subsect_list[k].res_list[l].cal_list[calcnt]
                .cal_det[dc].age_from_code_value = age->age_list[x].age_code_value, reply->srh[ii].
                dept_list[i].sect_list[j].subsect_list[k].res_list[l].cal_list[calcnt].cal_det[dc].
                age_from_disp = age->age_list[x].age_disp, reply->srh[ii].dept_list[i].sect_list[j].
                subsect_list[k].res_list[l].cal_list[calcnt].cal_det[dc].age_from_mean = age->
                age_list[x].age_mean
               ENDIF
             ENDFOR
             FOR (x = 1 TO agecnt)
               IF ((age->age_list[x].age_code_value=lrc.age_to_units_cd))
                reply->srh[ii].dept_list[i].sect_list[j].subsect_list[k].res_list[l].cal_list[calcnt]
                .cal_det[dc].age_to_code_value = age->age_list[x].age_code_value, reply->srh[ii].
                dept_list[i].sect_list[j].subsect_list[k].res_list[l].cal_list[calcnt].cal_det[dc].
                age_to_disp = age->age_list[x].age_disp, reply->srh[ii].dept_list[i].sect_list[j].
                subsect_list[k].res_list[l].cal_list[calcnt].cal_det[dc].age_to_mean = age->age_list[
                x].age_mean
               ENDIF
             ENDFOR
            WITH nocounter
           ;end select
         ENDFOR
        ENDIF
       ENDFOR
      ENDIF
     ENDFOR
    ENDIF
   ENDFOR
  ENDIF
 ENDFOR
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->error_msg = concat("  >> PROGRAM NAME:  BED_GET_SRVRES_HIER  >>  ERROR MESSAGE:  ",
   error_msg)
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
