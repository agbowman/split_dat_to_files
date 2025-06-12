CREATE PROGRAM bed_ens_res_resource_list:dba
 FREE SET reply
 RECORD reply(
   1 resource_lists[*]
     2 res_list_id = f8
     2 mnemonic = vc
     2 resource_sets[*]
       3 res_set_id = f8
       3 description = vc
       3 resources[*]
         4 sch_resource_code_value = f8
         4 mnemonic = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
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
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 SET res_role_code = 0
 DECLARE cur_role_meaning = vc
 SET mul_pat_ind = 0
 SET mul_pat_seq = 0
 SET add_pat_ind = 0
 SET res_role_code = 0
 DECLARE role_name = vc
 DECLARE original_name = vc
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
 SET res_list_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=16151
   AND cv.cdf_meaning="RESLIST"
   AND cv.active_ind=1
  DETAIL
   res_list_code = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to retrive code value with cdf_meaning = RESLIST from",
   " code set 16151.")
 ELSEIF (curqual > 1)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Multiple code values with cdf_meaning = RESLIST found on",
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
 SET reseq_patient = 0
 SET dept_cnt = size(request->departments,5)
 FOR (w = 1 TO dept_cnt)
  SET appt_cnt = size(request->departments[w].appointment_types,5)
  FOR (x = 1 TO appt_cnt)
    SET list_cnt = size(request->departments[w].appointment_types[x].resource_lists,5)
    SET rep_list_cnt = 0
    FOR (y = 1 TO list_cnt)
      SET rep_list_ind = 0
      IF ((request->departments[w].appointment_types[x].resource_lists[y].action_flag=1))
       SET new_res_list_id = 0.0
       SELECT INTO "NL:"
        j = seq(sch_res_list_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         new_res_list_id = cnvtreal(j)
        WITH format, counter
       ;end select
       IF (curqual=0)
        SET error_flag = "Y"
        SET reply->error_msg = concat("Unable to retrieve next code value in SCH_RES_LIST_SEQ.")
       ENDIF
       INSERT  FROM sch_resource_list s
        SET s.res_list_id = new_res_list_id, s.version_dt_tm = cnvtdatetime("31-DEC-2100"), s
         .mnemonic = trim(substring(1,100,request->departments[w].appointment_types[x].
           resource_lists[y].mnemonic)),
         s.mnemonic_key = cnvtupper(trim(substring(1,100,request->departments[w].appointment_types[x]
            .resource_lists[y].mnemonic))), s.description = trim(substring(1,200,request->
           departments[w].appointment_types[x].resource_lists[y].mnemonic)), s.info_sch_text_id = 0,
         s.appt_type_cd = 0, s.location_cd = 0, s.null_dt_tm = cnvtdatetime("31-DEC-2100"),
         s.candidate_id = seq(sch_candidate_seq,nextval), s.beg_effective_dt_tm = cnvtdatetime(
          curdate,curtime3), s.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
         s.active_ind = 1, s.active_status_cd = active_code_value, s.active_status_dt_tm =
         cnvtdatetime(curdate,curtime3),
         s.active_status_prsnl_id = reqinfo->updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime3),
         s.updt_id = reqinfo->updt_id,
         s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = 0,
         s.mnemonic_key_nls = null
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET error_flag = "Y"
        SET reply->error_msg = concat("Unable to insert resource list: ",trim(request->departments[w]
          .appointment_types[x].resource_lists[y].mnemonic)," on sch_resource_list.")
        GO TO exit_script
       ENDIF
       UPDATE  FROM sch_appt_loc a
        SET a.res_list_id = new_res_list_id, a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id
          = reqinfo->updt_id,
         a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->updt_applctx, a.updt_cnt = (a
         .updt_cnt+ 1)
        WHERE (a.appt_type_cd=request->departments[w].appointment_types[x].appt_type_code_value)
         AND (a.location_cd=request->departments[w].dept_code_value)
       ;end update
       IF (curqual=0)
        SET error_flag = "Y"
        SET reply->error_msg = concat("Unable to associate resource list: ",trim(request->
          departments[w].appointment_types[x].resource_lists[y].mnemonic),
         " to appointment type on sch_appt_loc.")
        GO TO exit_script
       ENDIF
       SET request->departments[w].appointment_types[x].resource_lists[y].res_list_id =
       new_res_list_id
       SET rep_list_cnt = (rep_list_cnt+ 1)
       SET rep_list_ind = 1
       SET stat = alterlist(reply->resource_lists,rep_list_cnt)
       SET reply->resource_lists[rep_list_cnt].res_list_id = request->departments[w].
       appointment_types[x].resource_lists[y].res_list_id
       SET reply->resource_lists[rep_list_cnt].mnemonic = request->departments[w].appointment_types[x
       ].resource_lists[y].mnemonic
      ELSEIF ((request->departments[w].appointment_types[x].resource_lists[y].action_flag IN (0, 2)))
       IF ((request->departments[w].appointment_types[x].resource_lists[y].action_flag=2))
        UPDATE  FROM sch_resource_list s
         SET s.mnemonic = trim(substring(1,100,request->departments[w].appointment_types[x].
            resource_lists[y].mnemonic)), s.mnemonic_key = cnvtupper(trim(substring(1,100,request->
             departments[w].appointment_types[x].resource_lists[y].mnemonic))), s.description = trim(
           substring(1,200,request->departments[w].appointment_types[x].resource_lists[y].mnemonic)),
          s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task =
          reqinfo->updt_task,
          s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s.updt_cnt+ 1)
         WHERE (s.res_list_id=request->departments[w].appointment_types[x].resource_lists[y].
         res_list_id)
         WITH nocounter
        ;end update
        IF (curqual=0)
         SET error_flag = "Y"
         SET reply->error_msg = concat("Unable to update resource list: ",trim(request->departments[w
           ].appointment_types[x].resource_lists[y].mnemonic)," on sch_resource_list.")
         GO TO exit_script
        ENDIF
       ENDIF
       SET copy_ind = 0
       SELECT INTO "nl:"
        FROM sch_appt_loc a
        PLAN (a
         WHERE (a.appt_type_cd=request->departments[w].appointment_types[x].appt_type_code_value)
          AND (a.location_cd=request->departments[w].dept_code_value)
          AND (a.res_list_id != request->departments[w].appointment_types[x].resource_lists[y].
         res_list_id)
          AND a.active_ind=1)
        DETAIL
         copy_ind = 1
        WITH nocounter
       ;end select
       IF (copy_ind=1)
        UPDATE  FROM sch_appt_loc a
         SET a.res_list_id = request->departments[w].appointment_types[x].resource_lists[y].
          res_list_id, a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = reqinfo->updt_id,
          a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->updt_applctx, a.updt_cnt = (a
          .updt_cnt+ 1)
         WHERE (a.appt_type_cd=request->departments[w].appointment_types[x].appt_type_code_value)
          AND (a.location_cd=request->departments[w].dept_code_value)
        ;end update
        IF (curqual=0)
         SET error_flag = "Y"
         SET reply->error_msg = concat("Unable to associate resource list: ",trim(request->
           departments[w].appointment_types[x].resource_lists[y].mnemonic),
          " to appointment type on sch_appt_loc.")
         GO TO exit_script
        ENDIF
       ENDIF
      ENDIF
      IF ((request->departments[w].appointment_types[x].resource_lists[y].action_flag != 1))
       FREE SET temp_pat
       RECORD temp_pat(
         1 ids[*]
           2 list_role_id = f8
       )
       SET mul_pat_ind = 0
       SET mul_pat_id = 0
       SET add_pat_ind = 0
       SET tot_cnt = 0
       SELECT INTO "nl:"
        FROM sch_list_role s
        PLAN (s
         WHERE (s.res_list_id=request->departments[w].appointment_types[x].resource_lists[y].
         res_list_id)
          AND s.role_meaning="PATIENT"
          AND s.active_ind=1)
        ORDER BY s.role_seq
        HEAD REPORT
         cnt = 0, tot_cnt = 0, stat = alterlist(temp_pat->ids,10)
        DETAIL
         cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
         IF (cnt > 10)
          stat = alterlist(temp_pat->ids,(tot_cnt+ 10)), cnt = 1
         ENDIF
         temp_pat->ids[tot_cnt].list_role_id = s.list_role_id, cnt = (cnt+ 1)
        FOOT REPORT
         stat = alterlist(temp_pat->ids,tot_cnt)
        WITH nocounter
       ;end select
       IF (tot_cnt=0)
        SET add_pat_ind = 1
       ELSEIF (tot_cnt > 1)
        FOR (del_cnt = 2 TO tot_cnt)
          DELETE  FROM sch_list_role s
           WHERE (s.res_list_id=request->departments[w].appointment_types[x].resource_lists[y].
           res_list_id)
            AND (s.list_role_id=temp_pat->ids[del_cnt].list_role_id)
           WITH nocounter
          ;end delete
          DELETE  FROM sch_list_res s
           WHERE (s.list_role_id=temp_pat->ids[del_cnt].list_role_id)
           WITH nocounter
          ;end delete
          DELETE  FROM sch_list_slot s
           WHERE (s.list_role_id=temp_pat->ids[del_cnt].list_role_id)
           WITH nocounter
          ;end delete
        ENDFOR
       ENDIF
      ENDIF
      SET set_cnt = size(request->departments[w].appointment_types[x].resource_lists[y].resource_sets,
       5)
      SET new_offset_from_id = 0.0
      SET cur_offset_from_id = 0.0
      SELECT INTO "nl:"
       FROM sch_list_role s
       PLAN (s
        WHERE (s.res_list_id=request->departments[w].appointment_types[x].resource_lists[y].
        res_list_id)
         AND s.active_ind=1)
       ORDER BY s.role_seq
       HEAD REPORT
        cur_offset_from_id = s.list_role_id
       WITH nocounter
      ;end select
      SET rep_set_cnt = 0
      FOR (z = 1 TO set_cnt)
        SET rep_set_ind = 0
        SET res_role_code = 0
        SET reseq_patient = 1
        IF ((request->departments[w].appointment_types[x].resource_lists[y].resource_sets[z].
        action_flag=1))
         SET role_name = substring(1,40,concat(request->departments[w].appointment_types[x].
           resource_lists[y].resource_sets[z].description,"-",request->departments[w].
           appointment_types[x].resource_lists[y].mnemonic))
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
         SET request_cv->cd_value_list[1].display = trim(substring(1,40,role_name))
         SET request_cv->cd_value_list[1].description = trim(substring(1,60,role_name))
         SET request_cv->cd_value_list[1].definition = trim(substring(1,100,role_name))
         SET request_cv->cd_value_list[1].active_ind = 1
         SET trace = recpersist
         EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
         IF ((reply_cv->status_data.status="S")
          AND (reply_cv->qual[1].code_value > 0))
          SET res_role_code = reply_cv->qual[1].code_value
         ELSE
          SET error_flag = "Y"
          SET reply->error_msg = concat("Unable to insert ",trim(request->departments[w].
            appointment_types[x].resource_lists[y].resource_sets[z].description),
           " into codeset 14250.")
          GO TO exit_script
         ENDIF
         INSERT  FROM sch_role s
          SET s.sch_role_cd = res_role_code, s.version_dt_tm = cnvtdatetime("31-DEC-2100"), s
           .mnemonic = trim(substring(1,100,role_name)),
           s.mnemonic_key = cnvtupper(trim(substring(1,100,role_name))), s.description = trim(
            substring(1,200,role_name)), s.info_sch_text_id = 0,
           s.null_dt_tm = cnvtdatetime("31-DEC-2100"), s.candidate_id = seq(sch_candidate_seq,nextval
            ), s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
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
          SET reply->error_msg = concat("Unable to insert resource role: ",trim(request->departments[
            w].appointment_types[x].resource_lists[y].resource_sets[z].description)," on sch_role.")
          GO TO exit_script
         ENDIF
         SET new_res_set_id = 0.0
         SELECT INTO "NL:"
          j = seq(sch_res_list_seq,nextval)"##################;rp0"
          FROM dual
          DETAIL
           new_res_set_id = cnvtreal(j)
          WITH format, counter
         ;end select
         IF (curqual=0)
          SET error_flag = "Y"
          SET reply->error_msg = concat("Unable to retrieve next code value in SCH_RES_LIST_SEQ.")
         ENDIF
         INSERT  FROM sch_list_role s
          SET s.list_role_id = new_res_set_id, s.version_dt_tm = cnvtdatetime("31-DEC-2100"), s
           .sch_role_cd = res_role_code,
           s.role_meaning = "RESOURCE", s.res_list_id = request->departments[w].appointment_types[x].
           resource_lists[y].res_list_id, s.role_seq = request->departments[w].appointment_types[x].
           resource_lists[y].resource_sets[z].sequence,
           s.description = trim(substring(1,200,request->departments[w].appointment_types[x].
             resource_lists[y].resource_sets[z].description)), s.primary_ind =
           IF ((request->departments[w].appointment_types[x].resource_lists[y].resource_sets[z].
           sequence=0)) 1
           ELSE 0
           ENDIF
           , s.optional_ind = 0,
           s.defining_ind = 0, s.algorithm_cd = favail_code, s.algorithm_meaning = "FIRSTAVAIL",
           s.dep_list_role_id = 0, s.dep_resource_cd = 0, s.null_dt_tm = cnvtdatetime("31-DEC-2100"),
           s.candidate_id = seq(sch_candidate_seq,nextval), s.beg_effective_dt_tm = cnvtdatetime(
            curdate,curtime3), s.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
           s.active_ind = 1, s.active_status_cd = active_code_value, s.active_status_dt_tm =
           cnvtdatetime(curdate,curtime3),
           s.active_status_prsnl_id = reqinfo->updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime3),
           s.updt_id = reqinfo->updt_id,
           s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = 0,
           s.info_sch_text_id = 0, s.mnemonic = null, s.mnemonic_key = null,
           s.mnemonic_key_nls = null, s.prompt_accept_cd = disable_code, s.prompt_accept_meaning =
           "DISABLE",
           s.role_type_cd = res_list_code, s.role_type_meaning = "RESLIST", s.sch_flex_id = 0,
           s.selected_ind = 1
          WITH nocounter
         ;end insert
         IF (curqual=0)
          SET error_flag = "Y"
          SET reply->error_msg = concat("Unable to insert resource set: ",trim(request->departments[w
            ].appointment_types[x].resource_lists[y].resource_sets[z].description),
           " on sch_list_role.")
          GO TO exit_script
         ENDIF
         SET request->departments[w].appointment_types[x].resource_lists[y].resource_sets[z].
         res_set_id = new_res_set_id
         INSERT  FROM br_name_value b
          SET b.br_name_value_id = seq(bedrock_seq,nextval), b.br_nv_key1 = "SCHRESGROUPROLE", b
           .br_name = cnvtstring(request->departments[w].appointment_types[x].resource_lists[y].
            resource_sets[z].res_set_id),
           b.br_value = cnvtstring(request->departments[w].appointment_types[x].resource_lists[y].
            resource_sets[z].group_id), b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id =
           reqinfo->updt_id,
           b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
          WITH nocounter
         ;end insert
         IF (curqual=0)
          SET error_flag = "Y"
          SET reply->error_msg = concat("Unable to insert resource set: ",trim(request->departments[w
            ].appointment_types[x].resource_lists[y].resource_sets[z].description),
           " on br_name_value.")
          GO TO exit_script
         ENDIF
         IF (rep_list_ind=0)
          SET rep_list_cnt = (rep_list_cnt+ 1)
          SET rep_list_ind = 1
          SET stat = alterlist(reply->resource_lists,rep_list_cnt)
          SET reply->resource_lists[rep_list_cnt].res_list_id = request->departments[w].
          appointment_types[x].resource_lists[y].res_list_id
          SET reply->resource_lists[rep_list_cnt].mnemonic = request->departments[w].
          appointment_types[x].resource_lists[y].mnemonic
         ENDIF
         SET rep_set_ind = 1
         SET rep_set_cnt = (rep_set_cnt+ 1)
         SET stat = alterlist(reply->resource_lists[rep_list_cnt].resource_sets,rep_set_cnt)
         SET reply->resource_lists[rep_list_cnt].resource_sets[rep_set_cnt].res_set_id = request->
         departments[w].appointment_types[x].resource_lists[y].resource_sets[z].res_set_id
         SET reply->resource_lists[rep_list_cnt].resource_sets[rep_set_cnt].description = request->
         departments[w].appointment_types[x].resource_lists[y].resource_sets[z].description
        ELSEIF ((request->departments[w].appointment_types[x].resource_lists[y].resource_sets[z].
        action_flag=2))
         UPDATE  FROM sch_list_role s
          SET s.description = trim(substring(1,200,request->departments[w].appointment_types[x].
             resource_lists[y].resource_sets[z].description)), s.role_seq = request->departments[w].
           appointment_types[x].resource_lists[y].resource_sets[z].sequence, s.primary_ind =
           IF ((request->departments[w].appointment_types[x].resource_lists[y].resource_sets[z].
           sequence=0)) 1
           ELSE 0
           ENDIF
           ,
           s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task
            = reqinfo->updt_task,
           s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s.updt_cnt+ 1)
          WHERE (s.list_role_id=request->departments[w].appointment_types[x].resource_lists[y].
          resource_sets[z].res_set_id)
          WITH nocounter
         ;end update
         IF (curqual=0)
          SET error_flag = "Y"
          SET reply->error_msg = concat("Unable to update resource set: ",trim(request->departments[w
            ].appointment_types[x].resource_lists[y].resource_sets[z].description),
           " on sch_list_role.")
          GO TO exit_script
         ENDIF
         UPDATE  FROM br_name_value b
          SET b.br_value = cnvtstring(request->departments[w].appointment_types[x].resource_lists[y].
            resource_sets[z].group_id), b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id =
           reqinfo->updt_id,
           b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = (b
           .updt_cnt+ 1)
          WHERE b.br_nv_key1="SCHRESGROUPROLE"
           AND b.br_name=cnvtstring(request->departments[w].appointment_types[x].resource_lists[y].
           resource_sets[z].res_set_id)
          WITH nocounter
         ;end update
         IF (curqual=0)
          SET error_flag = "Y"
          SET reply->error_msg = concat("Unable to update resource set: ",trim(request->departments[w
            ].appointment_types[x].resource_lists[y].resource_sets[z].description),
           " on br_name_value.")
          GO TO exit_script
         ENDIF
        ELSEIF ((request->departments[w].appointment_types[x].resource_lists[y].resource_sets[z].
        action_flag=3))
         DELETE  FROM sch_list_role s
          WHERE (s.list_role_id=request->departments[w].appointment_types[x].resource_lists[y].
          resource_sets[z].res_set_id)
          WITH nocounter
         ;end delete
         DELETE  FROM sch_list_res s
          WHERE (s.list_role_id=request->departments[w].appointment_types[x].resource_lists[y].
          resource_sets[z].res_set_id)
          WITH nocounter
         ;end delete
         DELETE  FROM sch_list_slot s
          WHERE (s.list_role_id=request->departments[w].appointment_types[x].resource_lists[y].
          resource_sets[z].res_set_id)
          WITH nocounter
         ;end delete
        ENDIF
        IF ((request->departments[w].appointment_types[x].resource_lists[y].resource_sets[z].
        action_flag IN (1, 2)))
         IF ((request->departments[w].appointment_types[x].resource_lists[y].resource_sets[z].
         sequence=0))
          SET new_offset_from_id = request->departments[w].appointment_types[x].resource_lists[y].
          resource_sets[z].res_set_id
         ENDIF
        ENDIF
        SET resource_cnt = size(request->departments[w].appointment_types[x].resource_lists[y].
         resource_sets[z].resources,5)
        SET res_role_ind = 0
        SET rep_res_cnt = 0
        IF (resource_cnt > 0)
         SELECT INTO "nl:"
          FROM sch_list_role role,
           sch_list_role role2
          PLAN (role
           WHERE (role.list_role_id=request->departments[w].appointment_types[x].resource_lists[y].
           resource_sets[z].res_set_id)
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
        SET cur_role_meaning = ""
        SELECT INTO "nl:"
         FROM sch_list_role role
         PLAN (role
          WHERE (role.list_role_id=request->departments[w].appointment_types[x].resource_lists[y].
          resource_sets[z].res_set_id)
           AND role.active_ind=1)
         DETAIL
          cur_role_meaning = role.role_meaning
         WITH nocounter
        ;end select
        SET rad_room_ind = 0
        FOR (a = 1 TO resource_cnt)
          SET res_role_id = 0.0
          SELECT INTO "nl:"
           FROM sch_list_role role
           WHERE (role.list_role_id=request->departments[w].appointment_types[x].resource_lists[y].
           resource_sets[z].res_set_id)
            AND role.active_ind=1
           DETAIL
            res_role_id = role.sch_role_cd
           WITH nocounter
          ;end select
          IF ((request->departments[w].appointment_types[x].resource_lists[y].resource_sets[z].
          resources[a].action_flag=1))
           IF ((request->departments[w].appointment_types[x].resource_lists[y].resource_sets[z].
           resources[a].sch_resource_code_value=0))
            IF ((request->departments[w].appointment_types[x].resource_lists[y].resource_sets[z].
            resources[a].person_id > 0))
             SET res_flag = 2
            ELSEIF ((request->departments[w].appointment_types[x].resource_lists[y].resource_sets[z].
            resources[a].service_resource_code_value > 0))
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
              appointment_types[x].resource_lists[y].resource_sets[z].resources[a].mnemonic))
            SET request_cv->cd_value_list[1].description = trim(substring(1,60,request->departments[w
              ].appointment_types[x].resource_lists[y].resource_sets[z].resources[a].mnemonic))
            SET request_cv->cd_value_list[1].definition = trim(substring(1,100,request->departments[w
              ].appointment_types[x].resource_lists[y].resource_sets[z].resources[a].mnemonic))
            SET request_cv->cd_value_list[1].active_ind = 1
            SET trace = recpersist
            EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
            IF ((reply_cv->status_data.status="S")
             AND (reply_cv->qual[1].code_value > 0))
             SET request->departments[w].appointment_types[x].resource_lists[y].resource_sets[z].
             resources[a].sch_resource_code_value = reply_cv->qual[1].code_value
            ELSE
             SET error_flag = "Y"
             SET reply->error_msg = concat("Unable to insert ",trim(request->departments[w].
               appointment_types[x].resource_lists[y].resource_sets[z].resources[a].mnemonic),
              " into codeset 14231.")
             GO TO exit_script
            ENDIF
            INSERT  FROM sch_resource s
             SET s.resource_cd = request->departments[w].appointment_types[x].resource_lists[y].
              resource_sets[z].resources[a].sch_resource_code_value, s.version_dt_tm = cnvtdatetime(
               "31-DEC-2100"), s.res_type_flag = res_flag,
              s.mnemonic = trim(substring(1,100,request->departments[w].appointment_types[x].
                resource_lists[y].resource_sets[z].resources[a].mnemonic)), s.mnemonic_key = trim(
               cnvtupper(substring(1,100,request->departments[w].appointment_types[x].resource_lists[
                 y].resource_sets[z].resources[a].mnemonic))), s.description = trim(substring(1,200,
                request->departments[w].appointment_types[x].resource_lists[y].resource_sets[z].
                resources[a].mnemonic)),
              s.info_sch_text_id = 0, s.person_id = request->departments[w].appointment_types[x].
              resource_lists[y].resource_sets[z].resources[a].person_id, s.service_resource_cd =
              request->departments[w].appointment_types[x].resource_lists[y].resource_sets[z].
              resources[a].service_resource_code_value,
              s.null_dt_tm = cnvtdatetime("31-DEC-2100"), s.candidate_id = seq(sch_candidate_seq,
               nextval), s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
              s.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), s.active_ind = 1, s
              .active_status_cd = active_code_value,
              s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s.active_status_prsnl_id =
              reqinfo->updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime3),
              s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx =
              reqinfo->updt_applctx,
              s.updt_cnt = 0, s.mnemonic_key_nls = null, s.item_id = 0,
              s.item_location_cd = 0, s.quota = 0
             WITH nocounter
            ;end insert
            IF (curqual=0)
             SET error_flag = "Y"
             SET reply->error_msg = concat("Unable to create scheduling resource for: ",trim(request
               ->departments[w].appointment_types[x].resource_lists[y].resource_sets[z].resources[a].
               mnemonic)," on sch_resource.")
             GO TO exit_script
            ENDIF
            INSERT  FROM br_name_value b
             SET b.br_name_value_id = seq(bedrock_seq,nextval), b.br_nv_key1 = "SCHRESGROUPRES", b
              .br_name = cnvtstring(request->departments[w].appointment_types[x].resource_lists[y].
               resource_sets[z].resources[a].sch_resource_code_value),
              b.br_value = cnvtstring(request->departments[w].appointment_types[x].resource_lists[y].
               resource_sets[z].group_id), b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id
               = reqinfo->updt_id,
              b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt =
              0
             WITH nocounter
            ;end insert
            IF (curqual=0)
             SET error_flag = "Y"
             SET reply->error_msg = concat("Unable to insert resource: ",trim(request->departments[w]
               .appointment_types[x].resource_lists[y].resource_sets[z].resources[a].mnemonic),
              " on br_name_value.")
             GO TO exit_script
            ENDIF
           ELSE
            SELECT INTO "nl:"
             FROM sch_resource s
             PLAN (s
              WHERE (s.resource_cd=request->departments[w].appointment_types[x].resource_lists[y].
              resource_sets[z].resources[a].sch_resource_code_value)
               AND s.res_type_flag=3)
             DETAIL
              rad_room_ind = 1
             WITH nocounter
            ;end select
            SET request_cv->cd_value_list[1].action_flag = 2
            SET request_cv->cd_value_list[1].code_value = request->departments[w].appointment_types[x
            ].resource_lists[y].resource_sets[z].resources[a].sch_resource_code_value
            SET request_cv->cd_value_list[1].code_set = 14231
            SET request_cv->cd_value_list[1].display = trim(substring(1,40,request->departments[w].
              appointment_types[x].resource_lists[y].resource_sets[z].resources[a].mnemonic))
            SET request_cv->cd_value_list[1].description = trim(substring(1,60,request->departments[w
              ].appointment_types[x].resource_lists[y].resource_sets[z].resources[a].mnemonic))
            SET request_cv->cd_value_list[1].definition = trim(substring(1,100,request->departments[w
              ].appointment_types[x].resource_lists[y].resource_sets[z].resources[a].mnemonic))
            SET request_cv->cd_value_list[1].active_ind = 1
            SET trace = recpersist
            EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
            IF ((reply_cv->status_data.status="F"))
             SET error_flag = "Y"
             SET reply->error_msg = concat("Unable to update ",trim(request->departments[w].
               appointment_types[x].resource_lists[y].resource_sets[z].resources[a].mnemonic),
              " into codeset 14231.")
             GO TO exit_script
            ENDIF
            UPDATE  FROM sch_resource s
             SET s.mnemonic = trim(substring(1,100,request->departments[w].appointment_types[x].
                resource_lists[y].resource_sets[z].resources[a].mnemonic)), s.mnemonic_key = trim(
               cnvtupper(substring(1,100,request->departments[w].appointment_types[x].resource_lists[
                 y].resource_sets[z].resources[a].mnemonic))), s.description = trim(substring(1,200,
                request->departments[w].appointment_types[x].resource_lists[y].resource_sets[z].
                resources[a].mnemonic)),
              s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s
              .updt_task = reqinfo->updt_task,
              s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s.updt_cnt+ 1)
             WHERE (s.resource_cd=request->departments[w].appointment_types[x].resource_lists[y].
             resource_sets[z].resources[a].sch_resource_code_value)
             WITH nocounter
            ;end update
            IF (curqual=0)
             SET error_flag = "Y"
             SET reply->error_msg = concat("Unable to update scheduling resource for: ",trim(request
               ->departments[w].appointment_types[x].resource_lists[y].resource_sets[z].resources[a].
               mnemonic)," on sch_resource.")
             GO TO exit_script
            ENDIF
           ENDIF
           IF (res_role_ind=0)
            IF (res_role_id > 0)
             INSERT  FROM sch_res_role s
              SET s.resource_cd = request->departments[w].appointment_types[x].resource_lists[y].
               resource_sets[z].resources[a].sch_resource_code_value, s.sch_role_cd = res_role_id, s
               .version_dt_tm = cnvtdatetime("31-DEC-2100"),
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
                departments[w].appointment_types[x].resource_lists[y].resource_sets[z].resources[a].
                mnemonic)," on sch_res_role.")
              GO TO exit_script
             ENDIF
            ENDIF
           ENDIF
           INSERT  FROM sch_list_res s
            SET s.list_role_id = request->departments[w].appointment_types[x].resource_lists[y].
             resource_sets[z].res_set_id, s.resource_cd = request->departments[w].appointment_types[x
             ].resource_lists[y].resource_sets[z].resources[a].sch_resource_code_value, s
             .version_dt_tm = cnvtdatetime("31-DEC-2100"),
             s.pref_ind = 0, s.search_seq = 0, s.display_seq = request->departments[w].
             appointment_types[x].resource_lists[y].resource_sets[z].resources[a].display_seq,
             s.null_dt_tm = cnvtdatetime("31-DEC-2100"), s.candidate_id = seq(sch_candidate_seq,
              nextval), s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
             s.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), s.active_ind = 1, s
             .active_status_cd = active_code_value,
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
            SET reply->error_msg = concat("Unable to insert resource set resource: ",trim(request->
              departments[w].appointment_types[x].resource_lists[y].resource_sets[z].resources[a].
              mnemonic)," on sch_list_res.")
            GO TO exit_script
           ENDIF
           IF (rep_list_ind=0)
            SET rep_list_cnt = (rep_list_cnt+ 1)
            SET rep_list_ind = 1
            SET stat = alterlist(reply->resource_lists,rep_list_cnt)
            SET reply->resource_lists[rep_list_cnt].res_list_id = request->departments[w].
            appointment_types[x].resource_lists[y].res_list_id
            SET reply->resource_lists[rep_list_cnt].mnemonic = request->departments[w].
            appointment_types[x].resource_lists[y].mnemonic
           ENDIF
           IF (rep_set_ind=0)
            SET rep_set_cnt = (rep_set_cnt+ 1)
            SET rep_set_ind = 1
            SET stat = alterlist(reply->resource_lists[rep_list_cnt].resource_sets,rep_set_cnt)
            SET reply->resource_lists[rep_list_cnt].resource_sets[rep_set_cnt].res_set_id = request->
            departments[w].appointment_types[x].resource_lists[y].resource_sets[z].res_set_id
            SET reply->resource_lists[rep_list_cnt].resource_sets[rep_set_cnt].description = request
            ->departments[w].appointment_types[x].resource_lists[y].resource_sets[z].description
           ENDIF
           SET rep_res_cnt = (rep_res_cnt+ 1)
           SET stat = alterlist(reply->resource_lists[rep_list_cnt].resource_sets[rep_set_cnt].
            resources,rep_res_cnt)
           SET reply->resource_lists[rep_list_cnt].resource_sets[rep_set_cnt].resources[rep_res_cnt].
           sch_resource_code_value = request->departments[w].appointment_types[x].resource_lists[y].
           resource_sets[z].resources[a].sch_resource_code_value
           SET reply->resource_lists[rep_list_cnt].resource_sets[rep_set_cnt].resources[rep_res_cnt].
           mnemonic = request->departments[w].appointment_types[x].resource_lists[y].resource_sets[z]
           .resources[a].mnemonic
          ELSEIF ((request->departments[w].appointment_types[x].resource_lists[y].resource_sets[z].
          resources[a].action_flag=2))
           UPDATE  FROM sch_list_res s
            SET s.display_seq = request->departments[w].appointment_types[x].resource_lists[y].
             resource_sets[z].resources[a].display_seq, s.updt_dt_tm = cnvtdatetime(curdate,curtime3),
             s.updt_id = reqinfo->updt_id,
             s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (
             s.updt_cnt+ 1)
            WHERE (s.list_role_id=request->departments[w].appointment_types[x].resource_lists[y].
            resource_sets[z].res_set_id)
             AND (s.resource_cd=request->departments[w].appointment_types[x].resource_lists[y].
            resource_sets[z].resources[a].sch_resource_code_value)
            WITH nocounter
           ;end update
           IF (curqual=0)
            SET error_flag = "Y"
            SET reply->error_msg = concat("Unable to update resource set resource: ",trim(request->
              departments[w].appointment_types[x].resource_lists[y].resource_sets[z].resources[a].
              mnemonic)," on sch_list_res.")
            GO TO exit_script
           ENDIF
           SET request_cv->cd_value_list[1].action_flag = 2
           SET request_cv->cd_value_list[1].code_value = request->departments[w].appointment_types[x]
           .resource_lists[y].resource_sets[z].resources[a].sch_resource_code_value
           SET request_cv->cd_value_list[1].code_set = 14231
           SET request_cv->cd_value_list[1].display = trim(substring(1,40,request->departments[w].
             appointment_types[x].resource_lists[y].resource_sets[z].resources[a].mnemonic))
           SET request_cv->cd_value_list[1].description = trim(substring(1,60,request->departments[w]
             .appointment_types[x].resource_lists[y].resource_sets[z].resources[a].mnemonic))
           SET request_cv->cd_value_list[1].definition = trim(substring(1,100,request->departments[w]
             .appointment_types[x].resource_lists[y].resource_sets[z].resources[a].mnemonic))
           SET request_cv->cd_value_list[1].active_ind = 1
           SET trace = recpersist
           EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
           IF ((reply_cv->status_data.status="F"))
            SET error_flag = "Y"
            SET reply->error_msg = concat("Unable to update ",trim(request->departments[w].
              appointment_types[x].resource_lists[y].resource_sets[z].resources[a].mnemonic),
             " into codeset 14231.")
            GO TO exit_script
           ENDIF
           UPDATE  FROM sch_resource s
            SET s.mnemonic = trim(substring(1,100,request->departments[w].appointment_types[x].
               resource_lists[y].resource_sets[z].resources[a].mnemonic)), s.mnemonic_key = trim(
              cnvtupper(substring(1,100,request->departments[w].appointment_types[x].resource_lists[y
                ].resource_sets[z].resources[a].mnemonic))), s.description = trim(substring(1,200,
               request->departments[w].appointment_types[x].resource_lists[y].resource_sets[z].
               resources[a].mnemonic)),
             s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task
              = reqinfo->updt_task,
             s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s.updt_cnt+ 1)
            WHERE (s.resource_cd=request->departments[w].appointment_types[x].resource_lists[y].
            resource_sets[z].resources[a].sch_resource_code_value)
            WITH nocounter
           ;end update
           IF (curqual=0)
            SET error_flag = "Y"
            SET reply->error_msg = concat("Unable to update scheduling resource for: ",trim(request->
              departments[w].appointment_types[x].resource_lists[y].resource_sets[z].resources[a].
              mnemonic)," on sch_resource.")
            GO TO exit_script
           ENDIF
          ELSEIF ((request->departments[w].appointment_types[x].resource_lists[y].resource_sets[z].
          resources[a].action_flag=3))
           IF (res_role_ind=0)
            DELETE  FROM sch_res_role s
             WHERE (s.resource_cd=request->departments[w].appointment_types[x].resource_lists[y].
             resource_sets[z].resources[a].sch_resource_code_value)
              AND s.sch_role_cd=res_role_id
             WITH nocounter
            ;end delete
           ENDIF
           DELETE  FROM sch_list_res s
            WHERE (s.list_role_id=request->departments[w].appointment_types[x].resource_lists[y].
            resource_sets[z].res_set_id)
             AND (s.resource_cd=request->departments[w].appointment_types[x].resource_lists[y].
            resource_sets[z].resources[a].sch_resource_code_value)
            WITH nocounter
           ;end delete
           IF (curqual=0)
            SET error_flag = "Y"
            SET reply->error_msg = concat("Unable to delete resource set resource: ",trim(request->
              departments[w].appointment_types[x].resource_lists[y].resource_sets[z].resources[a].
              mnemonic)," from sch_list_res.")
            GO TO exit_script
           ENDIF
          ENDIF
          SET req_slot_size = size(request->departments[w].appointment_types[x].resource_lists[y].
           resource_sets[z].resources[a].slot_types,5)
          FOR (b = 1 TO req_slot_size)
            IF ((request->departments[w].appointment_types[x].resource_lists[y].resource_sets[z].
            resources[a].slot_types[b].action_flag=1))
             SET slot_dur = 0.0
             SELECT INTO "nl:"
              FROM sch_slot_type sst
              WHERE (sst.slot_type_id=request->departments[w].appointment_types[x].resource_lists[y].
              resource_sets[z].resources[a].slot_types[b].slot_type_id)
              DETAIL
               slot_dur = sst.def_duration
              WITH nocounter
             ;end select
             INSERT  FROM sch_list_slot s
              SET s.list_role_id = request->departments[w].appointment_types[x].resource_lists[y].
               resource_sets[z].res_set_id, s.resource_cd = request->departments[w].
               appointment_types[x].resource_lists[y].resource_sets[z].resources[a].
               sch_resource_code_value, s.slot_type_id = request->departments[w].appointment_types[x]
               .resource_lists[y].resource_sets[z].resources[a].slot_types[b].slot_type_id,
               s.version_dt_tm = cnvtdatetime("31-DEC-2100"), s.setup_role_id = 0, s.setup_units = 0,
               s.setup_units_cd = min_code, s.setup_units_meaning = "MINUTES", s.duration_role_id = 0,
               s.duration_units = slot_dur, s.duration_units_cd = min_code, s.duration_units_meaning
                = "MINUTES",
               s.cleanup_role_id = 0, s.cleanup_units = 0, s.cleanup_units_cd = min_code,
               s.cleanup_units_meaning = "MINUTES", s.offset_role_id =
               IF ((request->departments[w].appointment_types[x].resource_lists[y].resource_sets[z].
               sequence=0)) 0
               ELSE cur_offset_from_id
               ENDIF
               , s.offset_type_cd = beg_code,
               s.offset_type_meaning = "BEG", s.offset_beg_units = 0, s.offset_beg_units_cd =
               min_code,
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
               departments[w].appointment_types[x].resource_lists[y].resource_sets[z].resources[a].
               slot_types[b].slot_type_seq,
               s.search_seq = 0, s.sch_flex_id = 0, s.selected_ind = 1
              WITH nocounter
             ;end insert
             IF (curqual=0)
              SET error_flag = "Y"
              SET reply->error_msg = concat("Unable to insert resource set resource: ",trim(request->
                departments[w].appointment_types[x].resource_lists[y].resource_sets[z].resources[a].
                mnemonic)," on sch_list_slot.")
              GO TO exit_script
             ENDIF
            ELSEIF ((request->departments[w].appointment_types[x].resource_lists[y].resource_sets[z].
            resources[a].slot_types[b].action_flag=2))
             UPDATE  FROM sch_list_slot s
              SET s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s
               .updt_task = reqinfo->updt_task,
               s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s.updt_cnt+ 1), s.display_seq =
               request->departments[w].appointment_types[x].resource_lists[y].resource_sets[z].
               resources[a].slot_types[b].slot_type_seq
              WHERE (s.list_role_id=request->departments[w].appointment_types[x].resource_lists[y].
              resource_sets[z].res_set_id)
               AND (s.resource_cd=request->departments[w].appointment_types[x].resource_lists[y].
              resource_sets[z].resources[a].sch_resource_code_value)
               AND (s.slot_type_id=request->departments[w].appointment_types[x].resource_lists[y].
              resource_sets[z].resources[a].slot_types[b].slot_type_id)
              WITH nocounter
             ;end update
             IF (curqual=0)
              SET error_flag = "Y"
              SET reply->error_msg = concat("Unable to update order role resource: ",trim(request->
                departments[w].appointment_types[x].resource_lists[y].resource_sets[z].resources[a].
                mnemonic)," on sch_list_slot.")
              GO TO exit_script
             ENDIF
            ELSEIF ((request->departments[w].appointment_types[x].resource_lists[y].resource_sets[z].
            resources[a].slot_types[b].action_flag=3))
             DELETE  FROM sch_list_slot s
              WHERE (s.list_role_id=request->departments[w].appointment_types[x].resource_lists[y].
              resource_sets[z].res_set_id)
               AND (s.resource_cd=request->departments[w].appointment_types[x].resource_lists[y].
              resource_sets[z].resources[a].sch_resource_code_value)
               AND (s.slot_type_id=request->departments[w].appointment_types[x].resource_lists[y].
              resource_sets[z].resources[a].slot_types[b].slot_type_id)
              WITH nocounter
             ;end delete
             IF (curqual=0)
              SET error_flag = "Y"
              SET reply->error_msg = concat("Unable to delete resource set resource: ",trim(request->
                departments[w].appointment_types[x].resource_lists[y].resource_sets[z].resources[a].
                mnemonic)," from sch_list_slot.")
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
            request->departments[w].appointment_types[x].resource_lists[y].resource_sets[z].
            description)," on codeset 14250.")
          GO TO exit_script
         ENDIF
         UPDATE  FROM sch_role s
          SET s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s
           .updt_task = reqinfo->updt_task,
           s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s.updt_cnt+ 1), s.role_meaning =
           "EXAMROOM"
          WHERE s.sch_role_cd=res_role_id
          WITH nocounter
         ;end update
         IF (curqual=0)
          SET error_flag = "Y"
          SET reply->error_msg = concat("Unable to update resource role: ",trim(request->departments[
            w].appointment_types[x].resource_lists[y].resource_sets[z].description)," on sch_role.")
          GO TO exit_script
         ENDIF
         UPDATE  FROM sch_res_role s
          SET s.role_meaning = "EXAMROOM", s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id
            = reqinfo->updt_id,
           s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s
           .updt_cnt+ 1)
          WHERE s.sch_role_cd=res_role_id
          WITH nocounter
         ;end update
         IF (curqual=0)
          SET error_flag = "Y"
          SET reply->error_msg = concat("Unable to update resource role meaning: ",trim(request->
            departments[w].appointment_types[x].resource_lists[y].resource_sets[z].description),
           " on sch_res_role.")
          GO TO exit_script
         ENDIF
         UPDATE  FROM sch_list_role s
          SET s.role_meaning = "EXAMROOM", s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id
            = reqinfo->updt_id,
           s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s
           .updt_cnt+ 1)
          WHERE (s.list_role_id=request->departments[w].appointment_types[x].resource_lists[y].
          resource_sets[z].res_set_id)
          WITH nocounter
         ;end update
         IF (curqual=0)
          SET error_flag = "Y"
          SET reply->error_msg = concat("Unable to update resource set: ",trim(request->departments[w
            ].appointment_types[x].resource_lists[y].resource_sets[z].description),
           " on sch_list_role.")
          GO TO exit_script
         ENDIF
        ENDIF
      ENDFOR
      IF (cur_offset_from_id != new_offset_from_id
       AND new_offset_from_id > 0)
       UPDATE  FROM sch_list_slot sls
        SET sls.offset_role_id = new_offset_from_id, sls.updt_dt_tm = cnvtdatetime(curdate,curtime3),
         sls.updt_id = reqinfo->updt_id,
         sls.updt_task = reqinfo->updt_task, sls.updt_applctx = reqinfo->updt_applctx, sls.updt_cnt
          = (sls.updt_cnt+ 1)
        WHERE sls.list_role_id IN (
        (SELECT
         slr.list_role_id
         FROM sch_list_role slr
         WHERE (slr.res_list_id=request->departments[w].appointment_types[x].resource_lists[y].
         res_list_id)
          AND slr.role_seq > 0
          AND slr.active_ind=1))
         AND sls.offset_role_id IN (cur_offset_from_id, 0)
         AND sls.active_ind=1
        WITH nocounter
       ;end update
       UPDATE  FROM sch_list_slot sls
        SET sls.offset_role_id = 0, sls.updt_dt_tm = cnvtdatetime(curdate,curtime3), sls.updt_id =
         reqinfo->updt_id,
         sls.updt_task = reqinfo->updt_task, sls.updt_applctx = reqinfo->updt_applctx, sls.updt_cnt
          = (sls.updt_cnt+ 1)
        WHERE sls.list_role_id IN (
        (SELECT
         slr.list_role_id
         FROM sch_list_role slr
         WHERE (slr.res_list_id=request->departments[w].appointment_types[x].resource_lists[y].
         res_list_id)
          AND slr.role_seq=0
          AND slr.active_ind=1))
         AND sls.active_ind=1
        WITH nocounter
       ;end update
      ENDIF
      IF ((((request->departments[w].appointment_types[x].resource_lists[y].action_flag=1)) OR (
      add_pat_ind=1)) )
       DECLARE patient_desc = vc
       SET patient_code = 0.0
       SELECT INTO "nl:"
        FROM code_value cv,
         sch_role sr
        PLAN (cv
         WHERE cv.code_set=14250
          AND cv.cdf_meaning="PATIENT"
          AND cv.active_ind=1)
         JOIN (sr
         WHERE sr.sch_role_cd=cv.code_value
          AND sr.role_meaning=cv.cdf_meaning
          AND sr.active_ind=1)
        DETAIL
         patient_code = cv.code_value, patient_desc = sr.mnemonic
        WITH nocounter
       ;end select
       IF (curqual=0)
        SET error_flag = "Y"
        SET reply->error_msg = concat("Could not find Patient resource role.")
        GO TO exit_script
       ELSEIF (curqual > 1)
        SET error_flag = "Y"
        SET reply->error_msg = concat(
         "More then one resource role found with meaning = PATIENT on code set 14250.")
        GO TO exit_script
       ENDIF
       SET patient_seq = 0.0
       SET inherit_code = 0.0
       SET offset_from_code = 0.0
       SELECT INTO "nl:"
        FROM sch_list_role slr
        WHERE (slr.res_list_id=request->departments[w].appointment_types[x].resource_lists[y].
        res_list_id)
         AND slr.active_ind=1
        ORDER BY slr.role_seq
        HEAD REPORT
         inherit_code = slr.list_role_id, offset_from_code = slr.list_role_id
        DETAIL
         patient_seq = (slr.role_seq+ 1)
        WITH nocounter
       ;end select
       SET new_res_set_id = 0.0
       SELECT INTO "NL:"
        j = seq(sch_res_list_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         new_res_set_id = cnvtreal(j)
        WITH format, counter
       ;end select
       IF (curqual=0)
        SET error_flag = "Y"
        SET reply->error_msg = concat("Unable to retrieve next code value in SCH_RES_LIST_SEQ.")
       ENDIF
       INSERT  FROM sch_list_role s
        SET s.list_role_id = new_res_set_id, s.version_dt_tm = cnvtdatetime("31-DEC-2100"), s
         .sch_role_cd = patient_code,
         s.role_meaning = "PATIENT", s.res_list_id = request->departments[w].appointment_types[x].
         resource_lists[y].res_list_id, s.role_seq = patient_seq,
         s.description = patient_desc, s.primary_ind = 0, s.optional_ind = 0,
         s.defining_ind = 0, s.algorithm_cd = favail_code, s.algorithm_meaning = "FIRSTAVAIL",
         s.dep_list_role_id = 0, s.dep_resource_cd = 0, s.null_dt_tm = cnvtdatetime("31-DEC-2100"),
         s.candidate_id = seq(sch_candidate_seq,nextval), s.beg_effective_dt_tm = cnvtdatetime(
          curdate,curtime3), s.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
         s.active_ind = 1, s.active_status_cd = active_code_value, s.active_status_dt_tm =
         cnvtdatetime(curdate,curtime3),
         s.active_status_prsnl_id = reqinfo->updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime3),
         s.updt_id = reqinfo->updt_id,
         s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = 0,
         s.info_sch_text_id = 0, s.mnemonic = null, s.mnemonic_key = null,
         s.mnemonic_key_nls = null, s.prompt_accept_cd = disable_code, s.prompt_accept_meaning =
         "DISABLE",
         s.role_type_cd = res_list_code, s.role_type_meaning = "RESLIST", s.sch_flex_id = 0,
         s.selected_ind = 1
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET error_flag = "Y"
        SET reply->error_msg = concat("Unable to insert Patient resource set on sch_list_role.")
        GO TO exit_script
       ENDIF
       INSERT  FROM sch_list_res s
        SET s.list_role_id = new_res_set_id, s.resource_cd = 0, s.version_dt_tm = cnvtdatetime(
          "31-DEC-2100"),
         s.pref_ind = 0, s.search_seq = 0, s.display_seq = 0,
         s.null_dt_tm = cnvtdatetime("31-DEC-2100"), s.candidate_id = seq(sch_candidate_seq,nextval),
         s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
         s.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), s.active_ind = 1, s.active_status_cd =
         active_code_value,
         s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s.active_status_prsnl_id = reqinfo->
         updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime3),
         s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
         updt_applctx,
         s.updt_cnt = 0, s.res_sch_cd = schedule_code, s.res_sch_meaning = "SCHEDULE",
         s.sch_flex_id = 0, s.selected_ind = 1
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET error_flag = "Y"
        SET reply->error_msg = concat("Unable to insert Patient resource on sch_list_res.")
        GO TO exit_script
       ENDIF
       SET slot_id = 0.0
       SELECT INTO "nl:"
        FROM sch_slot_type sst
        WHERE sst.mnemonic_key="OPEN"
         AND sst.active_ind=1
        DETAIL
         slot_id = sst.slot_type_id
        WITH nocounter
       ;end select
       IF (curqual=0)
        SET error_flag = "Y"
        SET reply->error_msg = "Unable to retrieve Open slot type ID."
        GO TO exit_script
       ENDIF
       INSERT  FROM sch_list_slot s
        SET s.list_role_id = new_res_set_id, s.resource_cd = 0, s.slot_type_id = slot_id,
         s.version_dt_tm = cnvtdatetime("31-DEC-2100"), s.setup_role_id = 0, s.setup_units = 0,
         s.setup_units_cd = min_code, s.setup_units_meaning = "MINUTES", s.duration_role_id =
         inherit_code,
         s.duration_units = 0, s.duration_units_cd = min_code, s.duration_units_meaning = "MINUTES",
         s.cleanup_role_id = 0, s.cleanup_units = 0, s.cleanup_units_cd = min_code,
         s.cleanup_units_meaning = "MINUTES", s.offset_role_id = offset_from_code, s.offset_type_cd
          = beg_code,
         s.offset_type_meaning = "BEG", s.offset_beg_units = 0, s.offset_beg_units_cd = min_code,
         s.offset_beg_units_meaning = "MINUTES", s.offset_end_units = 0, s.offset_end_units_cd =
         min_code,
         s.offset_end_units_meaning = "MINUTES", s.null_dt_tm = cnvtdatetime("31-DEC-2100"), s
         .candidate_id = seq(sch_candidate_seq,nextval),
         s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), s.end_effective_dt_tm = cnvtdatetime
         ("31-DEC-2100"), s.active_ind = 1,
         s.active_status_cd = active_code_value, s.active_status_dt_tm = cnvtdatetime(curdate,
          curtime3), s.active_status_prsnl_id = reqinfo->updt_id,
         s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task =
         reqinfo->updt_task,
         s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = 0, s.display_seq = 0,
         s.search_seq = 0, s.sch_flex_id = 0, s.selected_ind = 1
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET error_flag = "Y"
        SET reply->error_msg = concat("Unable to insert Patient resource on sch_list_slot.")
        GO TO exit_script
       ENDIF
      ELSEIF (reseq_patient=1)
       SET cur_patient_seq = 0.0
       SET new_patient_seq = 0.0
       SELECT INTO "nl:"
        FROM sch_list_role slr
        WHERE (slr.res_list_id=request->departments[w].appointment_types[x].resource_lists[y].
        res_list_id)
         AND slr.active_ind=1
        ORDER BY slr.role_seq
        DETAIL
         IF (slr.role_meaning="PATIENT")
          cur_patient_seq = slr.role_seq
         ELSE
          new_patient_seq = (slr.role_seq+ 1)
         ENDIF
        WITH nocounter
       ;end select
       IF (cur_patient_seq != new_patient_seq)
        UPDATE  FROM sch_list_role s
         SET s.role_seq = new_patient_seq, s.primary_ind =
          IF (new_patient_seq=0) 1
          ELSE 0
          ENDIF
          , s.updt_dt_tm = cnvtdatetime(curdate,curtime3),
          s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
          updt_applctx,
          s.updt_cnt = (s.updt_cnt+ 1)
         WHERE s.role_meaning="PATIENT"
          AND s.active_ind=1
         WITH nocounter
        ;end update
        IF (curqual=0)
         SET error_flag = "Y"
         SET reply->error_msg = concat("Unable to re-sequence patient set on sch_list_role.")
         GO TO exit_script
        ENDIF
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
