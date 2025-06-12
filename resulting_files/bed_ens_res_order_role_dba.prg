CREATE PROGRAM bed_ens_res_order_role:dba
 FREE SET request_cv
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
   1 ord_roles[*]
     2 ord_role_id = f8
     2 mnemonic = vc
     2 sequence = i4
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET temp_roles
 RECORD temp_roles(
   1 roles[*]
     2 catalog_code_value = f8
     2 location_code_value = f8
     2 cur_seq = i4
     2 new_seq = i4
     2 flex_id = f8
     2 setup = i4
     2 setup_code = f8
     2 setup_mean = vc
     2 duration = i4
     2 duration_code = f8
     2 duration_mean = vc
     2 cleanup = i4
     2 cleanup_code = f8
     2 cleanup_mean = vc
     2 offset_code = f8
     2 offset_mean = vc
     2 offset_beg = i4
     2 offset_beg_code = f8
     2 offset_beg_mean = vc
     2 offset_end = i4
     2 offset_end_code = f8
     2 offset_end_mean = vc
     2 candidate_code = f8
     2 active_ind = i2
     2 active_status = f8
     2 arrival = i4
     2 arrival_code = f8
     2 arrival_mean = vc
     2 recovery = i4
     2 recovery_code = f8
     2 recovery_mean = vc
 )
 FREE SET temp_roles2
 RECORD temp_roles2(
   1 roles[*]
     2 catalog_code = f8
     2 location_code_value = f8
     2 cur_seq = i4
     2 new_seq = i4
     2 list_role = f8
     2 flex_id = f8
     2 candidate_code = f8
     2 active_ind = i2
     2 active_code = f8
 )
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 SET res_role_code = 0
 DECLARE slot_duration = i4
 DECLARE cur_role_meaning = vc
 SET rad_room_ind = 0
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET active_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
   AND cv.active_ind=1
  DETAIL
   active_code_value = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to retrive code value with cdf_meaning = ACTIVE from",
   " code set 48.")
 ELSEIF (curqual > 1)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Multiple code values with cdf_meaning = ACTIVE found on",
   " code set 48.")
 ENDIF
 SET favail_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=15109
   AND cv.cdf_meaning="FIRSTAVAIL"
   AND cv.active_ind=1
  DETAIL
   favail_code = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to retrive code value with cdf_meaning = FIRSTAVAIL from",
   " code set 15109.")
 ELSEIF (curqual > 1)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Multiple code values with cdf_meaning = FIRSTAVAIL found on",
   " code set 15109.")
 ENDIF
 SET disable_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=16109
   AND cv.cdf_meaning="DISABLE"
   AND cv.active_ind=1
  DETAIL
   disable_code = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to retrive code value with cdf_meaning = DISABLE from",
   " code set 16109.")
 ELSEIF (curqual > 1)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Multiple code values with cdf_meaning = DISABLE found on",
   " code set 16109.")
 ENDIF
 SET single_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=16151
   AND cv.cdf_meaning="SINGLE"
   AND cv.active_ind=1
  DETAIL
   single_code = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to retrive code value with cdf_meaning = SINGLE from",
   " code set 16151.")
 ELSEIF (curqual > 1)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Multiple code values with cdf_meaning = SINGLE found on",
   " code set 16151.")
 ENDIF
 SET schedule_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=16145
   AND cv.cdf_meaning="SCHEDULE"
   AND cv.active_ind=1
  DETAIL
   schedule_code = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to retrive code value with cdf_meaning = SCHEDULE from",
   " code set 16145.")
 ELSEIF (curqual > 1)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Multiple code values with cdf_meaning = SCHEDULE found on",
   " code set 16145.")
 ENDIF
 SET min_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=54
   AND cv.cdf_meaning="MINUTES"
   AND cv.active_ind=1
  DETAIL
   min_code = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to retrive code value with cdf_meaning = MINUTES from",
   " code set 54.")
 ELSEIF (curqual > 1)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Multiple code values with cdf_meaning = MINUTES found on",
   " code set 54.")
 ENDIF
 SET beg_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=15129
   AND cv.cdf_meaning="BEG"
   AND cv.active_ind=1
  DETAIL
   beg_code = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to retrive code value with cdf_meaning = BEG from",
   " code set 15129.")
 ELSEIF (curqual > 1)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Multiple code values with cdf_meaning = BEG found on",
   " code set 15129.")
 ENDIF
 SET inh_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=23001
   AND cv.cdf_meaning="INHERIT"
   AND cv.active_ind=1
  DETAIL
   inh_code = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to retrive code value with cdf_meaning = INHERIT from",
   " code set 23001.")
 ELSEIF (curqual > 1)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Multiple code values with cdf_meaning = INHERIT found on",
   " code set 23001.")
 ENDIF
 SET dept_cnt = size(request->departments,5)
 FOR (w = 1 TO dept_cnt)
  SET appt_cnt = size(request->departments[w].appointment_types,5)
  FOR (x = 1 TO appt_cnt)
    SET role_cnt = size(request->departments[w].appointment_types[x].ord_roles,5)
    IF (role_cnt > 0)
     SET ierrcode = 0
     DELETE  FROM sch_order_role s,
       (dummyt d  WITH seq = value(role_cnt))
      SET s.seq = 1
      PLAN (d
       WHERE (request->departments[w].appointment_types[x].ord_roles[d.seq].action_flag=3))
       JOIN (s
       WHERE (s.catalog_cd=request->departments[w].appointment_types[x].catalog_code_value)
        AND (s.location_cd=request->departments[w].dept_code_value)
        AND (s.list_role_id=request->departments[w].appointment_types[x].ord_roles[d.seq].ord_role_id
       )
        AND (s.seq_nbr=request->departments[w].appointment_types[x].ord_roles[d.seq].prev_seq))
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->error_msg = serrmsg
      GO TO exit_script
     ENDIF
     SET ierrcode = 0
     DELETE  FROM sch_order_duration s,
       (dummyt d  WITH seq = value(role_cnt))
      SET s.seq = 1
      PLAN (d
       WHERE (request->departments[w].appointment_types[x].ord_roles[d.seq].action_flag=3))
       JOIN (s
       WHERE (s.catalog_cd=request->departments[w].appointment_types[x].catalog_code_value)
        AND (s.location_cd=request->departments[w].dept_code_value)
        AND (s.seq_nbr=request->departments[w].appointment_types[x].ord_roles[d.seq].prev_seq))
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->error_msg = serrmsg
      GO TO exit_script
     ENDIF
     SET stat = initrec(temp_roles)
     SET ttot_cnt = 0
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(role_cnt)),
       sch_order_duration s
      PLAN (d
       WHERE (request->departments[w].appointment_types[x].ord_roles[d.seq].action_flag=2))
       JOIN (s
       WHERE (s.catalog_cd=request->departments[w].appointment_types[x].catalog_code_value)
        AND (s.location_cd=request->departments[w].dept_code_value)
        AND (s.seq_nbr=request->departments[w].appointment_types[x].ord_roles[d.seq].prev_seq)
        AND (s.seq_nbr != request->departments[w].appointment_types[x].ord_roles[d.seq].new_seq))
      ORDER BY d.seq
      HEAD REPORT
       tcnt = 0, ttot_cnt = 0, stat = alterlist(temp_roles->roles,100)
      DETAIL
       tcnt = (tcnt+ 1), ttot_cnt = (ttot_cnt+ 1)
       IF (tcnt > 100)
        stat = alterlist(temp_roles->roles,(ttot_cnt+ 100)), tcnt = 1
       ENDIF
       temp_roles->roles[ttot_cnt].active_ind = s.active_ind, temp_roles->roles[ttot_cnt].
       active_status = s.active_status_cd, temp_roles->roles[ttot_cnt].arrival = s.arrival_units,
       temp_roles->roles[ttot_cnt].arrival_code = s.arrival_units_cd, temp_roles->roles[ttot_cnt].
       arrival_mean = s.arrival_units_meaning, temp_roles->roles[ttot_cnt].candidate_code = s
       .candidate_id,
       temp_roles->roles[ttot_cnt].catalog_code_value = s.catalog_cd, temp_roles->roles[ttot_cnt].
       cleanup = s.cleanup_units, temp_roles->roles[ttot_cnt].cleanup_code = s.cleanup_units_cd,
       temp_roles->roles[ttot_cnt].cleanup_mean = s.cleanup_units_meaning, temp_roles->roles[ttot_cnt
       ].cur_seq = s.seq_nbr, temp_roles->roles[ttot_cnt].duration = s.duration_units,
       temp_roles->roles[ttot_cnt].duration_code = s.duration_units_cd, temp_roles->roles[ttot_cnt].
       duration_mean = s.duration_units_meaning, temp_roles->roles[ttot_cnt].flex_id = s.sch_flex_id,
       temp_roles->roles[ttot_cnt].location_code_value = s.location_cd, temp_roles->roles[ttot_cnt].
       new_seq = request->departments[w].appointment_types[x].ord_roles[d.seq].new_seq, temp_roles->
       roles[ttot_cnt].offset_beg = s.offset_beg_units,
       temp_roles->roles[ttot_cnt].offset_beg_code = s.offset_beg_units_cd, temp_roles->roles[
       ttot_cnt].offset_beg_mean = s.offset_beg_units_meaning, temp_roles->roles[ttot_cnt].
       offset_code = s.offset_type_cd,
       temp_roles->roles[ttot_cnt].offset_mean = s.offset_type_meaning, temp_roles->roles[ttot_cnt].
       offset_end = s.offset_end_units, temp_roles->roles[ttot_cnt].offset_end_code = s
       .offset_end_units_cd,
       temp_roles->roles[ttot_cnt].offset_end_mean = s.offset_end_units_meaning, temp_roles->roles[
       ttot_cnt].recovery = s.recovery_units, temp_roles->roles[ttot_cnt].recovery_code = s
       .recovery_units_cd,
       temp_roles->roles[ttot_cnt].recovery_mean = s.recovery_units_meaning, temp_roles->roles[
       ttot_cnt].setup = s.setup_units, temp_roles->roles[ttot_cnt].setup_code = s.setup_units_cd,
       temp_roles->roles[ttot_cnt].setup_mean = s.setup_units_meaning
      FOOT REPORT
       stat = alterlist(temp_roles->roles,ttot_cnt)
      WITH nocounter
     ;end select
     IF (ttot_cnt > 0)
      SET ierrcode = 0
      DELETE  FROM sch_order_duration s,
        (dummyt d  WITH seq = value(ttot_cnt))
       SET s.seq = 1
       PLAN (d)
        JOIN (s
        WHERE (s.catalog_cd=temp_roles->roles[d.seq].catalog_code_value)
         AND (s.location_cd=temp_roles->roles[d.seq].location_code_value)
         AND (s.seq_nbr=temp_roles->roles[d.seq].cur_seq)
         AND (s.sch_flex_id=temp_roles->roles[d.seq].flex_id))
       WITH nocounter
      ;end delete
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET reply->error_msg = serrmsg
       GO TO exit_script
      ENDIF
      SET ierrcode = 0
      INSERT  FROM sch_order_duration s,
        (dummyt d  WITH seq = value(ttot_cnt))
       SET s.catalog_cd = temp_roles->roles[d.seq].catalog_code_value, s.location_cd = temp_roles->
        roles[d.seq].location_code_value, s.seq_nbr = temp_roles->roles[d.seq].new_seq,
        s.sch_flex_id = temp_roles->roles[d.seq].flex_id, s.version_dt_tm = cnvtdatetime(
         "31-DEC-2100"), s.setup_units = temp_roles->roles[d.seq].setup,
        s.setup_units_cd = temp_roles->roles[d.seq].setup_code, s.setup_units_meaning = temp_roles->
        roles[d.seq].setup_mean, s.duration_units = temp_roles->roles[d.seq].duration,
        s.duration_units_cd = temp_roles->roles[d.seq].duration_code, s.duration_units_meaning =
        temp_roles->roles[d.seq].duration_mean, s.cleanup_units = temp_roles->roles[d.seq].cleanup,
        s.cleanup_units_cd = temp_roles->roles[d.seq].cleanup_code, s.cleanup_units_meaning =
        temp_roles->roles[d.seq].cleanup_mean, s.offset_type_cd = temp_roles->roles[d.seq].
        offset_code,
        s.offset_type_meaning = temp_roles->roles[d.seq].offset_mean, s.offset_beg_units = temp_roles
        ->roles[d.seq].offset_beg, s.offset_beg_units_cd = temp_roles->roles[d.seq].offset_beg_code,
        s.offset_beg_units_meaning = temp_roles->roles[d.seq].offset_beg_mean, s.offset_end_units =
        temp_roles->roles[d.seq].offset_end, s.offset_end_units_cd = temp_roles->roles[d.seq].
        offset_end_code,
        s.offset_end_units_meaning = temp_roles->roles[d.seq].offset_end_mean, s.null_dt_tm =
        cnvtdatetime("31-DEC-2100"), s.candidate_id = temp_roles->roles[d.seq].candidate_code,
        s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), s.end_effective_dt_tm = cnvtdatetime(
         "31-DEC-2100"), s.active_ind = temp_roles->roles[d.seq].active_ind,
        s.active_status_cd = temp_roles->roles[d.seq].active_status, s.active_status_dt_tm =
        cnvtdatetime(curdate,curtime3), s.active_status_prsnl_id = reqinfo->updt_id,
        s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task =
        reqinfo->updt_task,
        s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = 0, s.arrival_units = temp_roles->roles[d
        .seq].arrival,
        s.arrival_units_cd = temp_roles->roles[d.seq].arrival_code, s.arrival_units_meaning =
        temp_roles->roles[d.seq].arrival_mean, s.recovery_units = temp_roles->roles[d.seq].recovery,
        s.recovery_units_cd = temp_roles->roles[d.seq].recovery_code, s.recovery_units_meaning =
        temp_roles->roles[d.seq].recovery_mean
       PLAN (d)
        JOIN (s)
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET reply->error_msg = serrmsg
       GO TO exit_script
      ENDIF
     ENDIF
     SET ttot_cnt = 0
     SET stat = initrec(temp_roles2)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(role_cnt)),
       sch_order_role s
      PLAN (d
       WHERE (request->departments[w].appointment_types[x].ord_roles[d.seq].action_flag=2))
       JOIN (s
       WHERE (s.catalog_cd=request->departments[w].appointment_types[x].catalog_code_value)
        AND (s.location_cd=request->departments[w].dept_code_value)
        AND (s.list_role_id=request->departments[w].appointment_types[x].ord_roles[d.seq].ord_role_id
       )
        AND (s.seq_nbr=request->departments[w].appointment_types[x].ord_roles[d.seq].prev_seq)
        AND (s.seq_nbr != request->departments[w].appointment_types[x].ord_roles[d.seq].new_seq))
      ORDER BY d.seq
      HEAD REPORT
       tcnt = 0, ttot_cnt = 0, stat = alterlist(temp_roles2->roles,100)
      DETAIL
       tcnt = (tcnt+ 1), ttot_cnt = (ttot_cnt+ 1)
       IF (tcnt > 100)
        stat = alterlist(temp_roles2->roles,(ttot_cnt+ 100)), tcnt = 1
       ENDIF
       temp_roles2->roles[ttot_cnt].active_code = s.active_status_cd, temp_roles2->roles[ttot_cnt].
       active_ind = s.active_ind, temp_roles2->roles[ttot_cnt].candidate_code = s.candidate_id,
       temp_roles2->roles[ttot_cnt].catalog_code = s.catalog_cd, temp_roles2->roles[ttot_cnt].cur_seq
        = s.seq_nbr, temp_roles2->roles[ttot_cnt].flex_id = s.sch_flex_id,
       temp_roles2->roles[ttot_cnt].list_role = s.list_role_id, temp_roles2->roles[ttot_cnt].
       location_code_value = s.location_cd, temp_roles2->roles[ttot_cnt].new_seq = request->
       departments[w].appointment_types[x].ord_roles[d.seq].new_seq
      FOOT REPORT
       stat = alterlist(temp_roles2->roles,ttot_cnt)
      WITH nocounter
     ;end select
     IF (ttot_cnt > 0)
      DELETE  FROM sch_order_role s,
        (dummyt d  WITH seq = value(ttot_cnt))
       SET s.seq = 1
       PLAN (d)
        JOIN (s
        WHERE (s.catalog_cd=temp_roles2->roles[d.seq].catalog_code)
         AND (s.location_cd=temp_roles2->roles[d.seq].location_code_value)
         AND (s.seq_nbr=temp_roles2->roles[d.seq].cur_seq)
         AND (s.list_role_id=temp_roles2->roles[d.seq].list_role))
       WITH nocounter
      ;end delete
      SET ierrcode = 0
      INSERT  FROM sch_order_role s,
        (dummyt d  WITH seq = value(ttot_cnt))
       SET s.catalog_cd = temp_roles2->roles[d.seq].catalog_code, s.location_cd = temp_roles2->roles[
        d.seq].location_code_value, s.seq_nbr = temp_roles2->roles[d.seq].new_seq,
        s.version_dt_tm = cnvtdatetime("31-DEC-2100"), s.null_dt_tm = cnvtdatetime("31-DEC-2100"), s
        .list_role_id = temp_roles2->roles[d.seq].list_role,
        s.sch_flex_id = temp_roles2->roles[d.seq].flex_id, s.candidate_id = temp_roles2->roles[d.seq]
        .candidate_code, s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        s.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), s.active_ind = temp_roles2->roles[d.seq]
        .active_ind, s.active_status_cd = temp_roles2->roles[d.seq].active_code,
        s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s.active_status_prsnl_id = reqinfo->
        updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
        updt_applctx,
        s.updt_cnt = 0
       PLAN (d)
        JOIN (s)
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET reply->error_msg = serrmsg
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
    CALL echorecord(temp_roles)
    CALL echorecord(temp_roles2)
    FOR (y = 1 TO role_cnt)
      SET res_role_code = 0
      IF ((request->departments[w].appointment_types[x].ord_roles[y].action_flag=1))
       IF ((request->departments[w].appointment_types[x].ord_roles[y].ord_role_id > 0))
        UPDATE  FROM sch_list_role s
         SET s.description = trim(substring(1,200,request->departments[w].appointment_types[x].
            ord_roles[y].mnemonic)), s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id =
          reqinfo->updt_id,
          s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s
          .updt_cnt+ 1),
          s.mnemonic = trim(substring(1,100,request->departments[w].appointment_types[x].ord_roles[y]
            .mnemonic)), s.mnemonic_key = cnvtupper(trim(substring(1,100,request->departments[w].
             appointment_types[x].ord_roles[y].mnemonic)))
         WHERE (s.list_role_id=request->departments[w].appointment_types[x].ord_roles[y].ord_role_id)
         WITH nocounter
        ;end update
        IF (curqual=0)
         SET error_flag = "Y"
         SET reply->error_msg = concat("Unable to update order role: ",trim(request->departments[w].
           appointment_types[x].ord_roles[y].mnemonic)," on sch_list_role.")
         GO TO exit_script
        ENDIF
        SET updt_role_ind = 1
        SET updt_role_id = 0.0
        SELECT INTO "nl:"
         FROM sch_list_role role,
          sch_list_role role2
         PLAN (role
          WHERE (role.list_role_id=request->departments[w].appointment_types[x].ord_roles[y].
          ord_role_id)
           AND role.active_ind=1)
          JOIN (role2
          WHERE role2.sch_role_cd=outerjoin(role.sch_role_cd)
           AND role2.list_role_id != outerjoin(role.list_role_id)
           AND role2.active_ind=outerjoin(1))
         DETAIL
          updt_role_id = role.sch_role_cd
          IF (role2.list_role_id > 0)
           updt_role_ind = 0
          ENDIF
         WITH nocounter
        ;end select
        IF (updt_role_ind=1)
         DECLARE role_name = vc
         SET role_name = substring(1,40,request->departments[w].appointment_types[x].ord_roles[y].
          mnemonic)
         SET original_name = role_name
         SET dup_ind = 1
         SET dup_cnt = 0
         WHILE (dup_ind=1)
           SET dup_ind = 0
           SELECT INTO "nl:"
            FROM code_value cv
            PLAN (cv
             WHERE cv.code_set=14250
              AND cv.display_key=trim(cnvtupper(cnvtalphanum(role_name)))
              AND cv.code_value != updt_role_id)
            DETAIL
             dup_ind = 1
            WITH nocounter
           ;end select
           SELECT INTO "nl:"
            FROM sch_role s
            PLAN (s
             WHERE s.mnemonic_key=trim(cnvtupper(role_name))
              AND s.sch_role_cd != updt_role_id)
            DETAIL
             dup_ind = 1
            WITH nocounter
           ;end select
           IF (dup_ind=1)
            SET dup_cnt = (dup_cnt+ 1)
            SET role_len = textlen(original_name)
            SET cnt_len = textlen(trim(cnvtstring(dup_cnt)))
            SET len_cnt = (role_len+ cnt_len)
            IF (len_cnt > 40)
             SET temp_cnt = (40 - (len_cnt - 40))
             SET role_name = concat(substring(1,temp_cnt,original_name),trim(cnvtstring(dup_cnt)))
            ELSE
             SET role_name = concat(original_name,trim(cnvtstring(dup_cnt)))
            ENDIF
           ENDIF
         ENDWHILE
         SET request_cv->cd_value_list[1].action_flag = 2
         SET request_cv->cd_value_list[1].code_value = updt_role_id
         SET request_cv->cd_value_list[1].code_set = 14250
         SET request_cv->cd_value_list[1].cdf_meaning = "RESOURCE"
         SET request_cv->cd_value_list[1].display = role_name
         SET request_cv->cd_value_list[1].description = role_name
         SET request_cv->cd_value_list[1].definition = role_name
         SET request_cv->cd_value_list[1].active_ind = 1
         SET trace = recpersist
         EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
         IF ((reply_cv->status_data.status="F"))
          SET error_flag = "Y"
          SET reply->error_msg = concat("Unable to update ",trim(request->departments[w].
            appointment_types[x].ord_roles[y].mnemonic)," into codeset 14250.")
          GO TO exit_script
         ENDIF
         SET request_cv->cd_value_list[1].code_value = 0
         UPDATE  FROM sch_role s
          SET s.mnemonic = role_name, s.mnemonic_key = cnvtupper(trim(role_name)), s.description =
           role_name,
           s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task
            = reqinfo->updt_task,
           s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s.updt_cnt+ 1)
          WHERE s.sch_role_cd=updt_role_id
          WITH nocounter
         ;end update
         IF (curqual=0)
          SET error_flag = "Y"
          SET reply->error_msg = concat("Unable to update resource role: ",trim(request->departments[
            w].appointment_types[x].ord_roles[y].mnemonic)," on sch_role.")
          GO TO exit_script
         ENDIF
        ENDIF
        UPDATE  FROM br_name_value b
         SET b.br_value = cnvtstring(request->departments[w].appointment_types[x].ord_roles[y].
           group_id), b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
          b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = (b
          .updt_cnt+ 1)
         WHERE b.br_nv_key1="SCHRESGROUPROLE"
          AND b.br_name=cnvtstring(request->departments[w].appointment_types[x].ord_roles[y].
          ord_role_id)
         WITH nocounter
        ;end update
        IF (curqual=0)
         SET error_flag = "Y"
         SET reply->error_msg = concat("Unable to update order role: ",trim(request->departments[w].
           appointment_types[x].ord_roles[y].mnemonic)," on br_name_value.")
         GO TO exit_script
        ENDIF
        INSERT  FROM sch_order_role s
         SET s.catalog_cd = request->departments[w].appointment_types[x].catalog_code_value, s
          .location_cd = request->departments[w].dept_code_value, s.seq_nbr = request->departments[w]
          .appointment_types[x].ord_roles[y].new_seq,
          s.version_dt_tm = cnvtdatetime("31-DEC-2100"), s.null_dt_tm = cnvtdatetime("31-DEC-2100"),
          s.list_role_id = request->departments[w].appointment_types[x].ord_roles[y].ord_role_id,
          s.sch_flex_id = 0, s.candidate_id = seq(sch_candidate_seq,nextval), s.beg_effective_dt_tm
           = cnvtdatetime(curdate,curtime3),
          s.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), s.active_ind = 1, s.active_status_cd
           = active_code_value,
          s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s.active_status_prsnl_id = reqinfo
          ->updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime3),
          s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
          updt_applctx,
          s.updt_cnt = 0
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET error_flag = "Y"
         SET reply->error_msg = concat("Unable to insert order role: ",trim(request->departments[w].
           appointment_types[x].ord_roles[y].mnemonic)," on sch_order_role.")
         GO TO exit_script
        ENDIF
       ELSE
        DECLARE role_name = vc
        SET role_name = substring(1,40,request->departments[w].appointment_types[x].ord_roles[y].
         mnemonic)
        SET original_name = role_name
        SET dup_ind = 1
        SET dup_cnt = 0
        WHILE (dup_ind=1)
          SET dup_ind = 0
          SELECT INTO "nl:"
           FROM code_value cv
           PLAN (cv
            WHERE cv.code_set=14250
             AND cv.display_key=trim(cnvtupper(cnvtalphanum(role_name))))
           DETAIL
            dup_ind = 1
           WITH nocounter
          ;end select
          SELECT INTO "nl:"
           FROM sch_role s
           PLAN (s
            WHERE s.mnemonic_key=trim(cnvtupper(role_name)))
           DETAIL
            dup_ind = 1
           WITH nocounter
          ;end select
          IF (dup_ind=1)
           SET dup_cnt = (dup_cnt+ 1)
           SET role_len = textlen(original_name)
           SET cnt_len = textlen(trim(cnvtstring(dup_cnt)))
           SET len_cnt = (role_len+ cnt_len)
           IF (len_cnt > 40)
            SET temp_cnt = (40 - (len_cnt - 40))
            SET role_name = concat(substring(1,temp_cnt,original_name),trim(cnvtstring(dup_cnt)))
           ELSE
            SET role_name = concat(original_name,trim(cnvtstring(dup_cnt)))
           ENDIF
          ENDIF
        ENDWHILE
        SET request_cv->cd_value_list[1].action_flag = 1
        SET request_cv->cd_value_list[1].code_set = 14250
        SET request_cv->cd_value_list[1].cdf_meaning = "RESOURCE"
        SET request_cv->cd_value_list[1].display = role_name
        SET request_cv->cd_value_list[1].description = role_name
        SET request_cv->cd_value_list[1].definition = role_name
        SET request_cv->cd_value_list[1].active_ind = 1
        SET trace = recpersist
        EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
        IF ((reply_cv->status_data.status="S")
         AND (reply_cv->qual[1].code_value > 0))
         SET res_role_code = reply_cv->qual[1].code_value
        ELSE
         SET error_flag = "Y"
         SET reply->error_msg = concat("Unable to insert ",trim(request->departments[w].
           appointment_types[x].ord_roles[y].mnemonic)," into codeset 14250.")
         GO TO exit_script
        ENDIF
        INSERT  FROM sch_role s
         SET s.sch_role_cd = res_role_code, s.version_dt_tm = cnvtdatetime("31-DEC-2100"), s.mnemonic
           = role_name,
          s.mnemonic_key = cnvtupper(trim(role_name)), s.description = role_name, s.info_sch_text_id
           = 0,
          s.null_dt_tm = cnvtdatetime("31-DEC-2100"), s.candidate_id = seq(sch_candidate_seq,nextval),
          s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
          s.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), s.active_ind = 1, s.active_status_cd
           = active_code_value,
          s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s.active_status_prsnl_id = reqinfo
          ->updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime3),
          s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
          updt_applctx,
          s.updt_cnt = 0, s.role_meaning = "RESOURCE", s.mnemonic_key_nls = null
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET error_flag = "Y"
         SET reply->error_msg = concat("Unable to insert resource role: ",trim(request->departments[w
           ].appointment_types[x].ord_roles[y].mnemonic)," on sch_role.")
         GO TO exit_script
        ENDIF
        SET new_ord_role_id = 0.0
        SELECT INTO "NL:"
         j = seq(sch_res_list_seq,nextval)"##################;rp0"
         FROM dual
         DETAIL
          new_ord_role_id = cnvtreal(j)
         WITH format, counter
        ;end select
        IF (curqual=0)
         SET error_flag = "Y"
         SET reply->error_msg = concat("Unable to retrieve next code value in SCH_RES_LIST_SEQ.")
        ENDIF
        INSERT  FROM sch_list_role s
         SET s.list_role_id = new_ord_role_id, s.version_dt_tm = cnvtdatetime("31-DEC-2100"), s
          .sch_role_cd = res_role_code,
          s.role_meaning = "RESOURCE", s.res_list_id = 0, s.role_seq = 0,
          s.description = trim(substring(1,200,request->departments[w].appointment_types[x].
            ord_roles[y].mnemonic)), s.primary_ind = 0, s.optional_ind = 0,
          s.defining_ind = 0, s.algorithm_cd = favail_code, s.algorithm_meaning = "FIRSTAVAIL",
          s.dep_list_role_id = 0, s.dep_resource_cd = 0, s.null_dt_tm = cnvtdatetime("31-DEC-2100"),
          s.candidate_id = seq(sch_candidate_seq,nextval), s.beg_effective_dt_tm = cnvtdatetime(
           curdate,curtime3), s.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
          s.active_ind = 1, s.active_status_cd = active_code_value, s.active_status_dt_tm =
          cnvtdatetime(curdate,curtime3),
          s.active_status_prsnl_id = reqinfo->updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime3),
          s.updt_id = reqinfo->updt_id,
          s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = 0,
          s.info_sch_text_id = 0, s.mnemonic = trim(substring(1,100,request->departments[w].
            appointment_types[x].ord_roles[y].mnemonic)), s.mnemonic_key = cnvtupper(trim(substring(1,
             100,request->departments[w].appointment_types[x].ord_roles[y].mnemonic))),
          s.mnemonic_key_nls = null, s.prompt_accept_cd = disable_code, s.prompt_accept_meaning =
          "DISABLE",
          s.role_type_cd = single_code, s.role_type_meaning = "SINGLE", s.sch_flex_id = 0,
          s.selected_ind = 1
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET error_flag = "Y"
         SET reply->error_msg = concat("Unable to insert order role: ",trim(request->departments[w].
           appointment_types[x].ord_roles[y].mnemonic)," on sch_list_role.")
         GO TO exit_script
        ENDIF
        INSERT  FROM sch_order_role s
         SET s.catalog_cd = request->departments[w].appointment_types[x].catalog_code_value, s
          .location_cd = request->departments[w].dept_code_value, s.seq_nbr = request->departments[w]
          .appointment_types[x].ord_roles[y].new_seq,
          s.version_dt_tm = cnvtdatetime("31-DEC-2100"), s.null_dt_tm = cnvtdatetime("31-DEC-2100"),
          s.list_role_id = new_ord_role_id,
          s.sch_flex_id = 0, s.candidate_id = seq(sch_candidate_seq,nextval), s.beg_effective_dt_tm
           = cnvtdatetime(curdate,curtime3),
          s.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), s.active_ind = 1, s.active_status_cd
           = active_code_value,
          s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s.active_status_prsnl_id = reqinfo
          ->updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime3),
          s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
          updt_applctx,
          s.updt_cnt = 0
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET error_flag = "Y"
         SET reply->error_msg = concat("Unable to insert order role: ",trim(request->departments[w].
           appointment_types[x].ord_roles[y].mnemonic)," on sch_order_role.")
         GO TO exit_script
        ENDIF
        INSERT  FROM sch_order_duration s
         SET s.catalog_cd = request->departments[w].appointment_types[x].catalog_code_value, s
          .location_cd = request->departments[w].dept_code_value, s.seq_nbr = request->departments[w]
          .appointment_types[x].ord_roles[y].new_seq,
          s.sch_flex_id = 0, s.version_dt_tm = cnvtdatetime("31-DEC-2100"), s.setup_units = 0,
          s.setup_units_cd = min_code, s.setup_units_meaning = "MINUTES", s.duration_units = 0,
          s.duration_units_cd = min_code, s.duration_units_meaning = "MINUTES", s.cleanup_units = 0,
          s.cleanup_units_cd = min_code, s.cleanup_units_meaning = "MINUTES", s.offset_type_cd =
          inh_code,
          s.offset_type_meaning = "INHERIT", s.offset_beg_units = 0, s.offset_beg_units_cd = min_code,
          s.offset_beg_units_meaning = "MINUTES", s.offset_end_units = 0, s.offset_end_units_cd = 0,
          s.offset_end_units_meaning = null, s.null_dt_tm = cnvtdatetime("31-DEC-2100"), s
          .candidate_id = seq(sch_candidate_seq,nextval),
          s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), s.end_effective_dt_tm =
          cnvtdatetime("31-DEC-2100"), s.active_ind = 1,
          s.active_status_cd = active_code_value, s.active_status_dt_tm = cnvtdatetime(curdate,
           curtime3), s.active_status_prsnl_id = reqinfo->updt_id,
          s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task =
          reqinfo->updt_task,
          s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = 0, s.arrival_units = 0,
          s.arrival_units_cd = 0, s.arrival_units_meaning = null, s.recovery_units = 0,
          s.recovery_units_cd = 0, s.recovery_units_meaning = null
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET error_flag = "Y"
         SET reply->error_msg = concat("Unable to insert order role durations: ",trim(request->
           departments[w].appointment_types[x].ord_roles[y].mnemonic)," on sch_order_duration.")
         GO TO exit_script
        ENDIF
        INSERT  FROM br_name_value b
         SET b.br_name_value_id = seq(bedrock_seq,nextval), b.br_nv_key1 = "SCHRESGROUPROLE", b
          .br_name = cnvtstring(new_ord_role_id),
          b.br_value = cnvtstring(request->departments[w].appointment_types[x].ord_roles[y].group_id),
          b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
          b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET error_flag = "Y"
         SET reply->error_msg = concat("Unable to insert order role: ",trim(request->departments[w].
           appointment_types[x].ord_roles[y].mnemonic)," on br_name_value.")
         GO TO exit_script
        ENDIF
        SET request->departments[w].appointment_types[x].ord_roles[y].ord_role_id = new_ord_role_id
        SET rep_size = size(reply->ord_roles,5)
        SET stat = alterlist(reply->ord_roles,(rep_size+ 1))
        SET reply->ord_roles[(rep_size+ 1)].ord_role_id = new_ord_role_id
        SET reply->ord_roles[(rep_size+ 1)].mnemonic = request->departments[w].appointment_types[x].
        ord_roles[y].mnemonic
        SET reply->ord_roles[(rep_size+ 1)].sequence = request->departments[w].appointment_types[x].
        ord_roles[y].new_seq
       ENDIF
      ELSEIF ((request->departments[w].appointment_types[x].ord_roles[y].action_flag=2))
       UPDATE  FROM sch_list_role s
        SET s.description = trim(substring(1,200,request->departments[w].appointment_types[x].
           ord_roles[y].mnemonic)), s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id =
         reqinfo->updt_id,
         s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s
         .updt_cnt+ 1),
         s.mnemonic = trim(substring(1,100,request->departments[w].appointment_types[x].ord_roles[y].
           mnemonic)), s.mnemonic_key = cnvtupper(trim(substring(1,100,request->departments[w].
            appointment_types[x].ord_roles[y].mnemonic)))
        WHERE (s.list_role_id=request->departments[w].appointment_types[x].ord_roles[y].ord_role_id)
        WITH nocounter
       ;end update
       IF (curqual=0)
        SET error_flag = "Y"
        SET reply->error_msg = concat("Unable to update order role: ",trim(request->departments[w].
          appointment_types[x].ord_roles[y].mnemonic)," on sch_list_role.")
        GO TO exit_script
       ENDIF
       SET updt_role_ind = 1
       SET updt_role_id = 0.0
       SELECT INTO "nl:"
        FROM sch_list_role role,
         sch_list_role role2
        PLAN (role
         WHERE (role.list_role_id=request->departments[w].appointment_types[x].ord_roles[y].
         ord_role_id)
          AND role.active_ind=1)
         JOIN (role2
         WHERE role2.sch_role_cd=outerjoin(role.sch_role_cd)
          AND role2.list_role_id != outerjoin(role.list_role_id)
          AND role2.active_ind=outerjoin(1))
        DETAIL
         updt_role_id = role.sch_role_cd
         IF (role2.list_role_id > 0)
          updt_role_ind = 0
         ENDIF
        WITH nocounter
       ;end select
       IF (updt_role_ind=1)
        DECLARE role_name = vc
        SET role_name = substring(1,40,request->departments[w].appointment_types[x].ord_roles[y].
         mnemonic)
        SET original_name = role_name
        SET dup_ind = 1
        SET dup_cnt = 0
        WHILE (dup_ind=1)
          SET dup_ind = 0
          SELECT INTO "nl:"
           FROM code_value cv
           PLAN (cv
            WHERE cv.code_set=14250
             AND cv.display_key=trim(cnvtupper(cnvtalphanum(role_name)))
             AND cv.code_value != updt_role_ind)
           DETAIL
            dup_ind = 1
           WITH nocounter
          ;end select
          SELECT INTO "nl:"
           FROM sch_role s
           PLAN (s
            WHERE s.mnemonic_key=trim(cnvtupper(role_name))
             AND s.sch_role_cd != updt_role_ind)
           DETAIL
            dup_ind = 1
           WITH nocounter
          ;end select
          IF (dup_ind=1)
           SET dup_cnt = (dup_cnt+ 1)
           SET role_len = textlen(original_name)
           SET cnt_len = textlen(trim(cnvtstring(dup_cnt)))
           SET len_cnt = (role_len+ cnt_len)
           IF (len_cnt > 40)
            SET temp_cnt = (40 - (len_cnt - 40))
            SET role_name = concat(substring(1,temp_cnt,original_name),trim(cnvtstring(dup_cnt)))
           ELSE
            SET role_name = concat(original_name,trim(cnvtstring(dup_cnt)))
           ENDIF
          ENDIF
        ENDWHILE
        SET request_cv->cd_value_list[1].action_flag = 2
        SET request_cv->cd_value_list[1].code_value = updt_role_id
        SET request_cv->cd_value_list[1].code_set = 14250
        SET request_cv->cd_value_list[1].cdf_meaning = "RESOURCE"
        SET request_cv->cd_value_list[1].display = role_name
        SET request_cv->cd_value_list[1].description = role_name
        SET request_cv->cd_value_list[1].definition = role_name
        SET request_cv->cd_value_list[1].active_ind = 1
        SET trace = recpersist
        EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
        IF ((reply_cv->status_data.status="F"))
         SET error_flag = "Y"
         SET reply->error_msg = concat("Unable to update ",trim(request->departments[w].
           appointment_types[x].ord_roles[y].mnemonic)," into codeset 14250.")
         GO TO exit_script
        ENDIF
        SET request_cv->cd_value_list[1].code_value = 0
        UPDATE  FROM sch_role s
         SET s.mnemonic = role_name, s.mnemonic_key = cnvtupper(trim(role_name)), s.description =
          role_name,
          s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task =
          reqinfo->updt_task,
          s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s.updt_cnt+ 1)
         WHERE s.sch_role_cd=updt_role_id
         WITH nocounter
        ;end update
        IF (curqual=0)
         SET error_flag = "Y"
         SET reply->error_msg = concat("Unable to update resource role: ",trim(request->departments[w
           ].appointment_types[x].ord_roles[y].mnemonic)," on sch_role.")
         GO TO exit_script
        ENDIF
       ENDIF
       UPDATE  FROM br_name_value b
        SET b.br_value = cnvtstring(request->departments[w].appointment_types[x].ord_roles[y].
          group_id), b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
         b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = (b
         .updt_cnt+ 1)
        WHERE b.br_nv_key1="SCHRESGROUPROLE"
         AND b.br_name=cnvtstring(request->departments[w].appointment_types[x].ord_roles[y].
         ord_role_id)
        WITH nocounter
       ;end update
       IF (curqual=0)
        SET error_flag = "Y"
        SET reply->error_msg = concat("Unable to update order role: ",trim(request->departments[w].
          appointment_types[x].ord_roles[y].mnemonic)," on br_name_value.")
        GO TO exit_script
       ENDIF
      ENDIF
      SET res_cnt = size(request->departments[w].appointment_types[x].ord_roles[y].resources,5)
      SET res_role_ind = 0
      IF (res_cnt > 0)
       SELECT INTO "nl:"
        FROM sch_list_role role,
         sch_list_role role2
        PLAN (role
         WHERE (role.list_role_id=request->departments[w].appointment_types[x].ord_roles[y].
         ord_role_id)
          AND role.active_ind=1)
         JOIN (role2
         WHERE role2.sch_role_cd=role.sch_role_cd
          AND role2.list_role_id != role.list_role_id
          AND role2.active_ind=1)
        DETAIL
         res_role_ind = 1
        WITH nocounter
       ;end select
      ENDIF
      FOR (z = 1 TO res_cnt)
        SET res_role_id = 0.0
        SELECT INTO "nl:"
         FROM sch_list_role role
         WHERE (role.list_role_id=request->departments[w].appointment_types[x].ord_roles[y].
         ord_role_id)
          AND role.active_ind=1
         DETAIL
          res_role_id = role.sch_role_cd
         WITH nocounter
        ;end select
        SET cur_role_meaning = ""
        SELECT INTO "nl:"
         FROM sch_list_role role
         PLAN (role
          WHERE (role.list_role_id=request->departments[w].appointment_types[x].ord_roles[y].
          ord_role_id)
           AND role.active_ind=1)
         DETAIL
          cur_role_meaning = role.role_meaning
         WITH nocounter
        ;end select
        SET rad_room_ind = 0
        IF ((request->departments[w].appointment_types[x].ord_roles[y].resources[z].action_flag=1))
         IF ((request->departments[w].appointment_types[x].ord_roles[y].resources[z].
         sch_resource_code_value=0))
          IF ((request->departments[w].appointment_types[x].ord_roles[y].resources[z].person_id > 0))
           SET res_flag = 2
          ELSEIF ((request->departments[w].appointment_types[x].ord_roles[y].resources[z].
          service_resource_code_value > 0))
           SET res_flag = 3
           SET rad_room_ind = 1
          ELSE
           SET res_flag = 1
          ENDIF
          SET sch_res_code = 0
          SET stat = initrec(request_cv)
          SET request_cv->cd_value_list[1].action_flag = 1
          SET request_cv->cd_value_list[1].code_set = 14231
          SET request_cv->cd_value_list[1].cdf_meaning = ""
          SET request_cv->cd_value_list[1].display = trim(substring(1,40,request->departments[w].
            appointment_types[x].ord_roles[y].resources[z].mnemonic))
          SET request_cv->cd_value_list[1].description = trim(substring(1,60,request->departments[w].
            appointment_types[x].ord_roles[y].resources[z].mnemonic))
          SET request_cv->cd_value_list[1].definition = trim(substring(1,100,request->departments[w].
            appointment_types[x].ord_roles[y].resources[z].mnemonic))
          SET request_cv->cd_value_list[1].active_ind = 1
          SET trace = recpersist
          EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
          IF ((reply_cv->status_data.status="S")
           AND (reply_cv->qual[1].code_value > 0))
           SET request->departments[w].appointment_types[x].ord_roles[y].resources[z].
           sch_resource_code_value = reply_cv->qual[1].code_value
          ELSE
           SET error_flag = "Y"
           SET reply->error_msg = concat("Unable to insert ",trim(request->departments[w].
             appointment_types[x].ord_roles[y].resources[z].mnemonic)," into codeset 14231.")
           GO TO exit_script
          ENDIF
          INSERT  FROM sch_resource s
           SET s.resource_cd = request->departments[w].appointment_types[x].ord_roles[y].resources[z]
            .sch_resource_code_value, s.version_dt_tm = cnvtdatetime("31-DEC-2100"), s.res_type_flag
             = res_flag,
            s.mnemonic = trim(substring(1,100,request->departments[w].appointment_types[x].ord_roles[
              y].resources[z].mnemonic)), s.mnemonic_key = trim(cnvtupper(substring(1,100,request->
               departments[w].appointment_types[x].ord_roles[y].resources[z].mnemonic))), s
            .description = trim(substring(1,200,request->departments[w].appointment_types[x].
              ord_roles[y].resources[z].mnemonic)),
            s.info_sch_text_id = 0, s.person_id = request->departments[w].appointment_types[x].
            ord_roles[y].resources[z].person_id, s.service_resource_cd = request->departments[w].
            appointment_types[x].ord_roles[y].resources[z].service_resource_code_value,
            s.null_dt_tm = cnvtdatetime("31-DEC-2100"), s.candidate_id = seq(sch_candidate_seq,
             nextval), s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
            s.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), s.active_ind = 1, s.active_status_cd
             = active_code_value,
            s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s.active_status_prsnl_id =
            reqinfo->updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime3),
            s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo
            ->updt_applctx,
            s.updt_cnt = 0, s.mnemonic_key_nls = null, s.item_id = 0,
            s.item_location_cd = 0, s.quota = 0
           WITH nocounter
          ;end insert
          IF (curqual=0)
           SET error_flag = "Y"
           SET reply->error_msg = concat("Unable to create scheduling resource for: ",trim(request->
             departments[w].appointment_types[x].ord_roles[y].resources[z].mnemonic),
            " on sch_resource.")
           GO TO exit_script
          ENDIF
          INSERT  FROM br_name_value b
           SET b.br_name_value_id = seq(bedrock_seq,nextval), b.br_nv_key1 = "SCHRESGROUPRES", b
            .br_name = cnvtstring(request->departments[w].appointment_types[x].ord_roles[y].
             resources[z].sch_resource_code_value),
            b.br_value = cnvtstring(request->departments[w].appointment_types[x].ord_roles[y].
             group_id), b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
            b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
           WITH nocounter
          ;end insert
          IF (curqual=0)
           SET error_flag = "Y"
           SET reply->error_msg = concat("Unable to insert resource: ",trim(request->departments[w].
             appointment_types[x].ord_roles[y].resources[z].mnemonic)," on br_name_value.")
           GO TO exit_script
          ENDIF
         ELSE
          SELECT INTO "nl:"
           FROM sch_resource s
           PLAN (s
            WHERE (s.resource_cd=request->departments[w].appointment_types[x].ord_roles[y].resources[
            z].sch_resource_code_value)
             AND s.res_type_flag=3)
           DETAIL
            rad_room_ind = 1
           WITH nocounter
          ;end select
          SET request_cv->cd_value_list[1].action_flag = 2
          SET request_cv->cd_value_list[1].code_value = request->departments[w].appointment_types[x].
          ord_roles[y].resources[z].sch_resource_code_value
          SET request_cv->cd_value_list[1].code_set = 14231
          SET request_cv->cd_value_list[1].display = trim(substring(1,40,request->departments[w].
            appointment_types[x].ord_roles[y].resources[z].mnemonic))
          SET request_cv->cd_value_list[1].description = trim(substring(1,60,request->departments[w].
            appointment_types[x].ord_roles[y].resources[z].mnemonic))
          SET request_cv->cd_value_list[1].definition = trim(substring(1,100,request->departments[w].
            appointment_types[x].ord_roles[y].resources[z].mnemonic))
          SET request_cv->cd_value_list[1].active_ind = 1
          SET trace = recpersist
          EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
          IF ((reply_cv->status_data.status="F"))
           SET error_flag = "Y"
           SET reply->error_msg = concat("Unable to update ",trim(request->departments[w].
             appointment_types[x].ord_roles[y].resources[z].mnemonic)," into codeset 14231.")
           GO TO exit_script
          ENDIF
          UPDATE  FROM sch_resource s
           SET s.mnemonic = trim(substring(1,100,request->departments[w].appointment_types[x].
              ord_roles[y].resources[z].mnemonic)), s.mnemonic_key = trim(cnvtupper(substring(1,100,
               request->departments[w].appointment_types[x].ord_roles[y].resources[z].mnemonic))), s
            .description = trim(substring(1,200,request->departments[w].appointment_types[x].
              ord_roles[y].resources[z].mnemonic)),
            s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task
             = reqinfo->updt_task,
            s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s.updt_cnt+ 1)
           WHERE (s.resource_cd=request->departments[w].appointment_types[x].ord_roles[y].resources[z
           ].sch_resource_code_value)
           WITH nocounter
          ;end update
          IF (curqual=0)
           SET error_flag = "Y"
           SET reply->error_msg = concat("Unable to update scheduling resource for: ",trim(request->
             departments[w].appointment_types[x].ord_roles[y].resources[z].mnemonic),
            " on sch_resource.")
           GO TO exit_script
          ENDIF
         ENDIF
         SET no_insert_ind = 0
         SELECT INTO "nl:"
          FROM sch_list_res s
          PLAN (s
           WHERE (s.list_role_id=request->departments[w].appointment_types[x].ord_roles[y].
           ord_role_id)
            AND (s.resource_cd=request->departments[w].appointment_types[x].ord_roles[y].resources[z]
           .sch_resource_code_value))
          DETAIL
           no_insert_ind = 1
          WITH nocounter
         ;end select
         IF (no_insert_ind=0)
          IF (res_role_ind=0)
           IF (res_role_id > 0)
            INSERT  FROM sch_res_role s
             SET s.resource_cd = request->departments[w].appointment_types[x].ord_roles[y].resources[
              z].sch_resource_code_value, s.sch_role_cd = res_role_id, s.version_dt_tm = cnvtdatetime
              ("31-DEC-2100"),
              s.role_meaning = cur_role_meaning, s.null_dt_tm = cnvtdatetime("31-DEC-2100"), s
              .candidate_id = seq(sch_candidate_seq,nextval),
              s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), s.end_effective_dt_tm =
              cnvtdatetime("31-DEC-2100"), s.active_ind = 1,
              s.active_status_cd = active_code_value, s.active_status_dt_tm = cnvtdatetime(curdate,
               curtime3), s.active_status_prsnl_id = reqinfo->updt_id,
              s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s
              .updt_task = reqinfo->updt_task,
              s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = 0
             WITH nocounter
            ;end insert
            IF (curqual=0)
             SET error_flag = "Y"
             SET reply->error_msg = concat("Unable to update order role resource: ",trim(request->
               departments[w].appointment_types[x].ord_roles[y].resources[z].mnemonic),
              " on sch_res_role.")
             GO TO exit_script
            ENDIF
           ENDIF
          ENDIF
          INSERT  FROM sch_list_res s
           SET s.list_role_id = request->departments[w].appointment_types[x].ord_roles[y].ord_role_id,
            s.resource_cd = request->departments[w].appointment_types[x].ord_roles[y].resources[z].
            sch_resource_code_value, s.version_dt_tm = cnvtdatetime("31-DEC-2100"),
            s.pref_ind = 0, s.search_seq = 0, s.display_seq = request->departments[w].
            appointment_types[x].ord_roles[y].resources[z].display_seq,
            s.null_dt_tm = cnvtdatetime("31-DEC-2100"), s.candidate_id = seq(sch_candidate_seq,
             nextval), s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
            s.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), s.active_ind = 1, s.active_status_cd
             = active_code_value,
            s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s.active_status_prsnl_id =
            reqinfo->updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime3),
            s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo
            ->updt_applctx,
            s.updt_cnt = 0, s.res_sch_cd = schedule_code, s.res_sch_meaning = "SCHEDULE",
            s.sch_flex_id = 0, s.selected_ind = 1
           WITH nocounter
          ;end insert
          IF (curqual=0)
           SET error_flag = "Y"
           SET reply->error_msg = concat("Unable to insert order role resource: ",trim(request->
             departments[w].appointment_types[x].ord_roles[y].resources[z].mnemonic),
            " on sch_list_res.")
           GO TO exit_script
          ENDIF
         ENDIF
        ELSEIF ((request->departments[w].appointment_types[x].ord_roles[y].resources[z].action_flag=2
        ))
         UPDATE  FROM sch_list_res s
          SET s.display_seq = request->departments[w].appointment_types[x].ord_roles[y].resources[z].
           display_seq, s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id,
           s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s
           .updt_cnt+ 1)
          WHERE (s.list_role_id=request->departments[w].appointment_types[x].ord_roles[y].ord_role_id
          )
          WITH nocounter
         ;end update
         IF (curqual=0)
          SET error_flag = "Y"
          SET reply->error_msg = concat("Unable to update order role resource: ",trim(request->
            departments[w].appointment_types[x].ord_roles[y].resources[z].mnemonic),
           " on sch_list_res.")
          GO TO exit_script
         ENDIF
         SET request_cv->cd_value_list[1].action_flag = 2
         SET request_cv->cd_value_list[1].code_value = request->departments[w].appointment_types[x].
         ord_roles[y].resources[z].sch_resource_code_value
         SET request_cv->cd_value_list[1].code_set = 14231
         SET request_cv->cd_value_list[1].display = trim(substring(1,40,request->departments[w].
           appointment_types[x].ord_roles[y].resources[z].mnemonic))
         SET request_cv->cd_value_list[1].description = trim(substring(1,60,request->departments[w].
           appointment_types[x].ord_roles[y].resources[z].mnemonic))
         SET request_cv->cd_value_list[1].definition = trim(substring(1,100,request->departments[w].
           appointment_types[x].ord_roles[y].resources[z].mnemonic))
         SET request_cv->cd_value_list[1].active_ind = 1
         SET trace = recpersist
         EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
         IF ((reply_cv->status_data.status="F"))
          SET error_flag = "Y"
          SET reply->error_msg = concat("Unable to update ",trim(request->departments[w].
            appointment_types[x].ord_roles[y].resources[z].mnemonic)," into codeset 14231.")
          GO TO exit_script
         ENDIF
         UPDATE  FROM sch_resource s
          SET s.mnemonic = trim(substring(1,100,request->departments[w].appointment_types[x].
             ord_roles[y].resources[z].mnemonic)), s.mnemonic_key = trim(cnvtupper(substring(1,100,
              request->departments[w].appointment_types[x].ord_roles[y].resources[z].mnemonic))), s
           .description = trim(substring(1,200,request->departments[w].appointment_types[x].
             ord_roles[y].resources[z].mnemonic)),
           s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task
            = reqinfo->updt_task,
           s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s.updt_cnt+ 1)
          WHERE (s.resource_cd=request->departments[w].appointment_types[x].ord_roles[y].resources[z]
          .sch_resource_code_value)
          WITH nocounter
         ;end update
         IF (curqual=0)
          SET error_flag = "Y"
          SET reply->error_msg = concat("Unable to update scheduling resource for: ",trim(request->
            departments[w].appointment_types[x].ord_roles[y].resources[z].mnemonic),
           " on sch_resource.")
          GO TO exit_script
         ENDIF
        ELSEIF ((request->departments[w].appointment_types[x].ord_roles[y].resources[z].action_flag=3
        ))
         IF (res_role_ind=0)
          DELETE  FROM sch_res_role s
           WHERE (s.resource_cd=request->departments[w].appointment_types[x].ord_roles[y].resources[z
           ].sch_resource_code_value)
            AND s.sch_role_cd=res_role_id
           WITH nocounter
          ;end delete
         ENDIF
         DELETE  FROM sch_list_res s
          WHERE (s.list_role_id=request->departments[w].appointment_types[x].ord_roles[y].ord_role_id
          )
           AND (s.resource_cd=request->departments[w].appointment_types[x].ord_roles[y].resources[z].
          sch_resource_code_value)
          WITH nocounter
         ;end delete
         IF (curqual=0)
          SET error_flag = "Y"
          SET reply->error_msg = concat("Unable to delete order role resource: ",trim(request->
            departments[w].appointment_types[x].ord_roles[y].resources[z].mnemonic),
           " from sch_list_res.")
          GO TO exit_script
         ENDIF
        ENDIF
        SET slot_size = 0
        SET slot_size = size(request->departments[w].appointment_types[x].ord_roles[y].resources[z].
         slot_types,5)
        FOR (s = 1 TO slot_size)
          IF ((request->departments[w].appointment_types[x].ord_roles[y].resources[z].slot_types[s].
          action_flag=1))
           SET no_insert_ind = 0
           SELECT INTO "nl:"
            FROM sch_list_slot s
            PLAN (s
             WHERE (s.list_role_id=request->departments[w].appointment_types[x].ord_roles[y].
             ord_role_id)
              AND (s.resource_cd=request->departments[w].appointment_types[x].ord_roles[y].resources[
             z].sch_resource_code_value)
              AND (s.slot_type_id=request->departments[w].appointment_types[x].ord_roles[y].
             resources[z].slot_types[s].slot_type_id))
            DETAIL
             no_insert_ind = 1
            WITH nocounter
           ;end select
           IF (no_insert_ind=0)
            INSERT  FROM sch_list_slot s
             SET s.list_role_id = request->departments[w].appointment_types[x].ord_roles[y].
              ord_role_id, s.resource_cd = request->departments[w].appointment_types[x].ord_roles[y].
              resources[z].sch_resource_code_value, s.slot_type_id = request->departments[w].
              appointment_types[x].ord_roles[y].resources[z].slot_types[s].slot_type_id,
              s.version_dt_tm = cnvtdatetime("31-DEC-2100"), s.setup_role_id = 0, s.setup_units = 0,
              s.setup_units_cd = min_code, s.setup_units_meaning = "MINUTES", s.duration_role_id = 0,
              s.duration_units = 0, s.duration_units_cd = min_code, s.duration_units_meaning =
              "MINUTES",
              s.cleanup_role_id = 0, s.cleanup_units = 0, s.cleanup_units_cd = min_code,
              s.cleanup_units_meaning = "MINUTES", s.offset_role_id = 0, s.offset_type_cd = beg_code,
              s.offset_type_meaning = "BEG", s.offset_beg_units = 0, s.offset_beg_units_cd = min_code,
              s.offset_beg_units_meaning = "MINUTES", s.offset_end_units = 0, s.offset_end_units_cd
               = min_code,
              s.offset_end_units_meaning = "MINUTES", s.null_dt_tm = cnvtdatetime("31-DEC-2100"), s
              .candidate_id = seq(sch_candidate_seq,nextval),
              s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), s.end_effective_dt_tm =
              cnvtdatetime("31-DEC-2100"), s.active_ind = 1,
              s.active_status_cd = active_code_value, s.active_status_dt_tm = cnvtdatetime(curdate,
               curtime3), s.active_status_prsnl_id = reqinfo->updt_id,
              s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s
              .updt_task = reqinfo->updt_task,
              s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = 0, s.display_seq = request->
              departments[w].appointment_types[x].ord_roles[y].resources[z].slot_types[s].
              slot_type_seq,
              s.search_seq = 0, s.sch_flex_id = 0, s.selected_ind = 1
             WITH nocounter
            ;end insert
            IF (curqual=0)
             SET error_flag = "Y"
             SET reply->error_msg = concat("Unable to insert order role resource: ",trim(request->
               departments[w].appointment_types[x].ord_roles[y].resources[z].mnemonic),
              " on sch_list_slot.")
             GO TO exit_script
            ENDIF
           ENDIF
          ELSEIF ((request->departments[w].appointment_types[x].ord_roles[y].resources[z].slot_types[
          s].action_flag=2))
           UPDATE  FROM sch_list_slot s
            SET s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s
             .updt_task = reqinfo->updt_task,
             s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s.updt_cnt+ 1), s.display_seq =
             request->departments[w].appointment_types[x].ord_roles[y].resources[z].slot_types[s].
             slot_type_seq
            WHERE (s.list_role_id=request->departments[w].appointment_types[x].ord_roles[y].
            ord_role_id)
             AND (s.resource_cd=request->departments[w].appointment_types[x].ord_roles[y].resources[z
            ].sch_resource_code_value)
             AND (s.slot_type_id=request->departments[w].appointment_types[x].ord_roles[y].resources[
            z].slot_types[s].slot_type_id)
            WITH nocounter
           ;end update
           IF (curqual=0)
            SET error_flag = "Y"
            SET reply->error_msg = concat("Unable to update order role resource: ",trim(request->
              departments[w].appointment_types[x].ord_roles[y].resources[z].mnemonic),
             " on sch_list_slot.")
            GO TO exit_script
           ENDIF
          ELSEIF ((request->departments[w].appointment_types[x].ord_roles[y].resources[z].slot_types[
          x].action_flag=3))
           DELETE  FROM sch_list_slot s
            WHERE (s.list_role_id=request->departments[w].appointment_types[x].ord_roles[y].
            ord_role_id)
             AND (s.resource_cd=request->departments[w].appointment_types[x].ord_roles[y].resources[z
            ].sch_resource_code_value)
             AND (s.slot_type_id=request->departments[w].appointment_types[x].ord_roles[y].resources[
            z].slot_types[s].slot_type_id)
            WITH nocounter
           ;end delete
           IF (curqual=0)
            SET error_flag = "Y"
            SET reply->error_msg = concat("Unable to delete order role resource: ",trim(request->
              departments[w].appointment_types[x].ord_roles[y].resources[z].mnemonic),
             " from sch_list_slot.")
            GO TO exit_script
           ENDIF
          ENDIF
        ENDFOR
      ENDFOR
      IF (rad_room_ind=1
       AND cur_role_meaning != "EXAMROOM")
       DECLARE cv_display = vc
       SELECT INTO "nl:"
        FROM code_value c
        PLAN (c
         WHERE c.code_value=res_role_id)
        DETAIL
         cv_display = c.display
        WITH nocounter
       ;end select
       SET stat = initrec(request_cv)
       SET request_cv->cd_value_list[1].action_flag = 2
       SET request_cv->cd_value_list[1].code_value = res_role_id
       SET request_cv->cd_value_list[1].code_set = 14250
       SET request_cv->cd_value_list[1].cdf_meaning = "EXAMROOM"
       SET request_cv->cd_value_list[1].active_ind = 1
       SET request_cv->cd_value_list[1].display = cv_display
       SET trace = recpersist
       EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
       IF ((reply_cv->status_data.status="F"))
        SET error_flag = "Y"
        SET reply->error_msg = concat("Unable to update role meaning for resource role: ",trim(
          request->departments[w].appointment_types[x].ord_roles[y].mnemonic)," on codeset 14250.")
        GO TO exit_script
       ENDIF
       UPDATE  FROM sch_role s
        SET s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task
          = reqinfo->updt_task,
         s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s.updt_cnt+ 1), s.role_meaning =
         "EXAMROOM"
        WHERE s.sch_role_cd=res_role_id
        WITH nocounter
       ;end update
       IF (curqual=0)
        SET error_flag = "Y"
        SET reply->error_msg = concat("Unable to update resource role: ",trim(request->departments[w]
          .appointment_types[x].ord_roles[y].mnemonic)," on sch_role.")
        GO TO exit_script
       ENDIF
       UPDATE  FROM sch_res_role s
        SET s.role_meaning = "EXAMROOM", s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id =
         reqinfo->updt_id,
         s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s
         .updt_cnt+ 1)
        WHERE s.sch_role_cd=res_role_id
        WITH nocounter
       ;end update
       IF (curqual=0)
        SET error_flag = "Y"
        SET reply->error_msg = concat("Unable to update resource role meaning: ",trim(request->
          departments[w].appointment_types[x].ord_roles[y].mnemonic)," on sch_res_role.")
        GO TO exit_script
       ENDIF
       UPDATE  FROM sch_list_role s
        SET s.role_meaning = "EXAMROOM", s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id =
         reqinfo->updt_id,
         s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s
         .updt_cnt+ 1)
        WHERE (s.list_role_id=request->departments[w].appointment_types[x].ord_roles[y].ord_role_id)
        WITH nocounter
       ;end update
       IF (curqual=0)
        SET error_flag = "Y"
        SET reply->error_msg = concat("Unable to update resource set: ",trim(request->departments[w].
          appointment_types[x].ord_roles[y].mnemonic)," on sch_list_role.")
        GO TO exit_script
       ENDIF
      ENDIF
    ENDFOR
  ENDFOR
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
