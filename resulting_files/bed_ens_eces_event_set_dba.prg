CREATE PROGRAM bed_ens_eces_event_set:dba
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
 ) WITH protect
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 event_sets[*]
      2 code_value = f8
      2 display = vc
    1 error_msg = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 RECORD temp_hier(
   1 event_hier[*]
     2 code_value = f8
     2 level = i4
 ) WITH protect
 RECORD fin_temp_hier(
   1 event_hier[*]
     2 code_value = f8
     2 level = i4
 ) WITH protect
 RECORD temp_sets(
   1 event_sets[*]
     2 code_value = f8
 ) WITH protect
 RECORD set_temp_hier(
   1 event_hier[*]
     2 code_value = f8
     2 level = i4
 ) WITH protect
 DECLARE dupeventind = i2 WITH protect, noconstant(0)
 DECLARE errorflag = vc WITH protect
 DECLARE listcnt = i4 WITH protect, noconstant(0)
 DECLARE cnt = i2 WITH protect, noconstant(0)
 DECLARE totcnt = i4 WITH protect, noconstant(0)
 DECLARE repcnt = i4 WITH protect, noconstant(0)
 DECLARE reptcnt = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect, noconstant(0)
 DECLARE ts_cnt = i4 WITH protect, noconstant(0)
 DECLARE level = i4 WITH protect, noconstant(0)
 DECLARE parent_ind = i2 WITH protect, noconstant(0)
 DECLARE newcode_ind = i2 WITH protect, noconstant(0)
 DECLARE tempset_size = i4 WITH protect, noconstant(0)
 DECLARE updt_ind = i2 WITH protect, noconstant(0)
 DECLARE activestatuscodevalue = f8 WITH protect, noconstant(0.0)
 DECLARE authcodevalue = f8 WITH protect, noconstant(0.0)
 DECLARE newsetcodevalue = f8 WITH protect, noconstant(0.0)
 DECLARE newcv = f8 WITH protect, noconstant(0.0)
 DECLARE updtpsind = i2 WITH protect, noconstant(0)
 SET errorflag = "N"
 SET reply->status_data.status = "F"
 SET listcnt = 0
 SET cnt = 0
 SET listcnt = 0
 SET totcnt = 0
 SET repcnt = 0
 SET reptcnt = 0
 SET stat = alterlist(reply->event_sets,100)
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SET activestatuscodevalue = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
   AND cv.active_ind=1
  DETAIL
   activestatuscodevalue = cv.code_value
  WITH nocounter
 ;end select
 SET authcodevalue = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=8
   AND cv.cdf_meaning="AUTH"
   AND cv.active_ind=1
  DETAIL
   authcodevalue = cv.code_value
  WITH nocounter
 ;end select
 FOR (x = 1 TO size(request->event_sets,5))
   SET dupeventind = 0
   SELECT INTO "nl:"
    FROM v500_event_set_code vesc
    WHERE vesc.event_set_name_key=trim(cnvtupper(cnvtalphanum(substring(1,40,request->event_sets[x].
        display))))
     AND trim(cnvtupper(vesc.event_set_name))=trim(cnvtupper(substring(1,40,request->event_sets[x].
       display)))
    DETAIL
     dupeventind = 1
    WITH nocounter
   ;end select
   IF ((request->event_sets[x].action_flag=1))
    SET newsetcodevalue = 0.0
    SET repcnt = (repcnt+ 1)
    SET reptcnt = (reptcnt+ 1)
    IF (reptcnt > 100)
     SET stat = alterlist(reply->event_sets,(repcnt+ 100))
     SET reptcnt = 1
    ENDIF
    IF (dupeventind=0)
     IF ((request->event_sets[x].event_set_code_value=0))
      SET newcv = 0.0
      SELECT INTO "NL:"
       j = seq(reference_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        newcv = cnvtreal(j)
       WITH format, counter
      ;end select
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET errorflag = "Y"
       SET reply->error_msg = concat(
        "ERROR 001: Problems occured retrieveing new sequence value for code_value table",serrmsg)
       GO TO exit_script
      ENDIF
      INSERT  FROM code_value cv
       SET cv.code_value = newcv, cv.code_set = 93, cv.cdf_meaning = null,
        cv.display = trim(substring(1,40,request->event_sets[x].display)), cv.display_key = trim(
         cnvtupper(cnvtalphanum(substring(1,40,request->event_sets[x].display)))), cv.description =
        trim(substring(1,60,request->event_sets[x].display)),
        cv.definition = trim(substring(1,100,request->event_sets[x].display)), cv.collation_seq = 0,
        cv.active_type_cd = activestatuscodevalue,
        cv.active_ind = 1, cv.active_dt_tm = cnvtdatetime(curdate,curtime3), cv.inactive_dt_tm = null,
        cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id, cv.updt_task
         = reqinfo->updt_task,
        cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = 0, cv.begin_effective_dt_tm =
        cnvtdatetime(curdate,curtime3),
        cv.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), cv.data_status_cd = authcodevalue, cv
        .data_status_dt_tm = cnvtdatetime(curdate,curtime3),
        cv.cki = null, cv.display_key_nls = "", cv.concept_cki = null
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET errorflag = "Y"
       SET reply->error_msg = concat("Unable to insert ",trim(request->event_sets[x].display),
        " into codeset 93.")
       GO TO exit_script
      ENDIF
      SET newsetcodevalue = newcv
      SET request->event_sets[x].event_set_code_value = newsetcodevalue
      INSERT  FROM v500_event_set_code ves
       SET ves.accumulation_ind = 0, ves.category_flag = 0, ves.event_set_cd_definition = trim(
         substring(1,100,request->event_sets[x].display)),
        ves.event_set_cd_descr = trim(substring(1,60,request->event_sets[x].display)), ves
        .event_set_cd_disp = trim(substring(1,40,request->event_sets[x].display)), ves
        .event_set_cd_disp_key = trim(cnvtupper(cnvtalphanum(substring(1,40,request->event_sets[x].
            display)))),
        ves.code_status_cd = activestatuscodevalue, ves.event_set_cd = newsetcodevalue, ves
        .combine_format = " ",
        ves.event_set_color_name = " ", ves.event_set_icon_name = " ", ves.event_set_name = trim(
         substring(1,40,request->event_sets[x].display)),
        ves.event_set_name_key = trim(cnvtupper(cnvtalphanum(substring(1,40,request->event_sets[x].
            display)))), ves.event_set_status_cd = authcodevalue, ves.grouping_rule_flag = 0,
        ves.leaf_event_cd_count = 0, ves.operation_display_flag = 0, ves.operation_formula = " ",
        ves.primitive_event_set_count = 0, ves.show_if_no_data_ind = 0, ves.updt_dt_tm = cnvtdatetime
        (curdate,curtime3),
        ves.updt_id = reqinfo->updt_id, ves.updt_task = reqinfo->updt_task, ves.updt_cnt = 0,
        ves.updt_applctx = reqinfo->updt_applctx, ves.display_association_ind = 0
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET errorflag = "Y"
       SET reply->error_msg = concat("Unable to insert ",trim(request->event_sets[x].display),
        " into v500_event_set_code table.")
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
    IF (size(request->event_sets[x].parent_event_sets,5) > 0)
     FOR (ps = 1 TO size(request->event_sets[x].parent_event_sets,5))
       SET updtpsind = 0
       SELECT INTO "nl:"
        FROM v500_event_set_canon v
        PLAN (v
         WHERE (v.parent_event_set_cd=request->event_sets[x].parent_event_sets[ps].code_value)
          AND (v.event_set_cd=request->event_sets[x].event_set_code_value))
        DETAIL
         IF ((v.event_set_collating_seq != request->event_sets[x].parent_event_sets[ps].sequence))
          updtpsind = 1
         ENDIF
        WITH nocounter
       ;end select
       IF (curqual=0)
        INSERT  FROM v500_event_set_canon vesc
         SET vesc.parent_event_set_cd = request->event_sets[x].parent_event_sets[ps].code_value, vesc
          .event_set_cd = request->event_sets[x].event_set_code_value, vesc.event_set_collating_seq
           = request->event_sets[x].parent_event_sets[ps].sequence,
          vesc.event_set_explode_ind = 0, vesc.event_set_status_cd = activestatuscodevalue, vesc
          .updt_dt_tm = cnvtdatetime(curdate,curtime3),
          vesc.updt_id = reqinfo->updt_id, vesc.updt_task = reqinfo->updt_task, vesc.updt_cnt = 0,
          vesc.updt_applctx = reqinfo->updt_applctx
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET errorflag = "Y"
         SET reply->error_msg = concat("Unable to insert into ","the v500_event_set_canon table.")
         GO TO exit_script
        ENDIF
       ELSEIF (updtpsind=1)
        UPDATE  FROM v500_event_set_canon vesc
         SET vesc.event_set_collating_seq = request->event_sets[x].parent_event_sets[ps].sequence,
          vesc.updt_dt_tm = cnvtdatetime(curdate,curtime3), vesc.updt_id = reqinfo->updt_id,
          vesc.updt_task = reqinfo->updt_task, vesc.updt_cnt = (vesc.updt_cnt+ 1), vesc.updt_applctx
           = reqinfo->updt_applctx
         WHERE (vesc.parent_event_set_cd=request->event_sets[x].parent_event_sets[ps].code_value)
          AND (vesc.event_set_cd=request->event_sets[x].event_set_code_value)
         WITH nocounter
        ;end update
        IF (curqual=0)
         SET errorflag = "Y"
         SET reply->error_msg = concat("Unable to update into ","the v500_event_set_canon table.")
         GO TO exit_script
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
    SET reply->event_sets[repcnt].code_value = request->event_sets[x].event_set_code_value
    SET reply->event_sets[repcnt].display = trim(substring(1,40,request->event_sets[x].display))
   ELSEIF ((request->event_sets[x].action_flag=2))
    IF ((request->event_sets[x].display > " "))
     UPDATE  FROM v500_event_set_code ves
      SET ves.event_set_cd_disp = trim(substring(1,40,request->event_sets[x].display)), ves
       .event_set_cd_disp_key = trim(cnvtupper(cnvtalphanum(substring(1,40,request->event_sets[x].
           display)))), ves.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       ves.updt_id = reqinfo->updt_id, ves.updt_task = reqinfo->updt_task, ves.updt_cnt = (ves
       .updt_cnt+ 1),
       ves.updt_applctx = reqinfo->updt_applctx
      WHERE (ves.event_set_cd=request->event_sets[x].event_set_code_value)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET errorflag = "Y"
      SET reply->error_msg = concat("Unable to update ",trim(request->event_sets[x].display),
       " on v500_event_set_code table.")
      GO TO exit_script
     ENDIF
     UPDATE  FROM code_value cv
      SET cv.display = trim(substring(1,40,request->event_sets[x].display)), cv.display_key = trim(
        cnvtupper(cnvtalphanum(substring(1,40,request->event_sets[x].display)))), cv.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       cv.updt_id = reqinfo->updt_id, cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->
       updt_applctx,
       cv.updt_cnt = (cv.updt_cnt+ 1)
      WHERE (cv.code_value=request->event_sets[x].event_set_code_value)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET errorflag = "Y"
      SET reply->error_msg = concat("Unable to update ",trim(request->event_sets[x].display),
       " into codeset 93.")
      GO TO exit_script
     ENDIF
    ENDIF
    IF (size(request->event_sets[x].parent_event_sets,5) > 0)
     SET ierrcode = 0
     UPDATE  FROM v500_event_set_canon vesc,
       (dummyt d  WITH seq = size(request->event_sets[x].parent_event_sets,5))
      SET vesc.event_set_collating_seq = request->event_sets[x].parent_event_sets[d.seq].sequence,
       vesc.updt_dt_tm = cnvtdatetime(curdate,curtime3), vesc.updt_id = reqinfo->updt_id,
       vesc.updt_task = reqinfo->updt_task, vesc.updt_cnt = (vesc.updt_cnt+ 1), vesc.updt_applctx =
       reqinfo->updt_applctx
      PLAN (d)
       JOIN (vesc
       WHERE (vesc.parent_event_set_cd=request->event_sets[x].parent_event_sets[d.seq].code_value)
        AND (vesc.event_set_cd=request->event_sets[x].event_set_code_value))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET errorflag = "Y"
      SET reply->error_msg = concat("Unable to update ","the v500_event_set_canon table: ",serrmsg)
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
   SET stat = initrec(set_temp_hier)
   IF (size(request->event_sets[x].event_codes,5) > 0)
    SET ierrcode = 0
    UPDATE  FROM v500_event_code vec,
      (dummyt d  WITH seq = value(size(request->event_sets[x].event_codes,5)))
     SET vec.event_set_name = trim(substring(1,40,request->event_sets[x].display)), vec.updt_dt_tm =
      cnvtdatetime(curdate,curtime3), vec.updt_id = reqinfo->updt_id,
      vec.updt_task = reqinfo->updt_task, vec.updt_cnt = (vec.updt_cnt+ 1), vec.updt_applctx =
      reqinfo->updt_applctx
     PLAN (d
      WHERE (request->event_sets[x].event_codes[d.seq].action_flag IN (1, 2)))
      JOIN (vec
      WHERE (vec.event_cd=request->event_sets[x].event_codes[d.seq].code_value))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET errorflag = "Y"
     SET reply->error_msg = concat("Unable to update event_set_name on ",
      "the v500_event_code table: ",serrmsg)
     GO TO exit_script
    ENDIF
    SET level = 0
    SET stat = alterlist(temp_sets->event_sets,1)
    SET temp_sets->event_sets[1].code_value = request->event_sets[x].event_set_code_value
    SET parent_ind = 1
    WHILE (parent_ind=1)
      SET ts_cnt = size(temp_sets->event_sets,5)
      SET level = (level+ 1)
      SET parent_ind = 0
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(ts_cnt)),
        v500_event_set_canon vec
       PLAN (d)
        JOIN (vec
        WHERE (vec.event_set_cd=temp_sets->event_sets[d.seq].code_value))
       ORDER BY d.seq
       HEAD REPORT
        ts_cnt = 0, listcnt = size(set_temp_hier->event_hier,5), totcnt = 0,
        stat = alterlist(set_temp_hier->event_hier,(listcnt+ 10)), stat = alterlist(temp_sets->
         event_sets,10)
       DETAIL
        ts_cnt = (ts_cnt+ 1), listcnt = (listcnt+ 1), totcnt = (totcnt+ 1)
        IF (totcnt > 10)
         stat = alterlist(set_temp_hier->event_hier,(listcnt+ 10)), stat = alterlist(temp_sets->
          event_sets,(ts_cnt+ 10)), totcnt = 1
        ENDIF
        set_temp_hier->event_hier[listcnt].code_value = vec.parent_event_set_cd, set_temp_hier->
        event_hier[listcnt].level = level, temp_sets->event_sets[ts_cnt].code_value = vec
        .parent_event_set_cd,
        parent_ind = 1
       FOOT REPORT
        stat = alterlist(set_temp_hier->event_hier,listcnt), stat = alterlist(temp_sets->event_sets,
         ts_cnt)
       WITH nocounter
      ;end select
    ENDWHILE
   ENDIF
   FOR (e = 1 TO size(request->event_sets[x].event_codes,5))
     IF ((request->event_sets[x].event_codes[e].action_flag=1))
      SET stat = initrec(temp_hier)
      SET stat = moverec(set_temp_hier,temp_hier)
      SET newcode_ind = 0
      SET listcnt = 0
      SELECT INTO "nl:"
       FROM v500_event_set_explode v
       WHERE (v.event_cd=request->event_sets[x].event_codes[e].code_value)
       HEAD REPORT
        listcnt = size(temp_hier->event_hier,5), totcnt = 0, stat = alterlist(temp_hier->event_hier,(
         listcnt+ 10))
       DETAIL
        listcnt = (listcnt+ 1), totcnt = (totcnt+ 1)
        IF (totcnt > 10)
         stat = alterlist(temp_hier->event_hier,(listcnt+ 10)), totcnt = 1
        ENDIF
        temp_hier->event_hier[listcnt].code_value = v.event_set_cd, temp_hier->event_hier[listcnt].
        level = v.event_set_level, newcode_ind = 1
       FOOT REPORT
        stat = alterlist(temp_hier->event_hier,listcnt)
       WITH nocounter
      ;end select
      IF (newcode_ind=0)
       SET tempset_size = size(temp_hier->event_hier,5)
       SET tempset_size = (tempset_size+ 1)
       SET stat = alterlist(temp_hier->event_hier,tempset_size)
       SET temp_hier->event_hier[tempset_size].code_value = request->event_sets[x].
       event_set_code_value
       SET temp_hier->event_hier[tempset_size].level = 0
      ENDIF
      IF (size(temp_hier->event_hier,5) > 0)
       SELECT INTO "nl:"
        c = temp_hier->event_hier[d.seq].code_value, l = temp_hier->event_hier[d.seq].level
        FROM (dummyt d  WITH seq = size(temp_hier->event_hier,5))
        PLAN (d)
        ORDER BY c, l DESC
        HEAD REPORT
         listcnt = 0, totcnt = 0, stat = alterlist(fin_temp_hier->event_hier,10)
        HEAD c
         listcnt = (listcnt+ 1), totcnt = (totcnt+ 1)
         IF (totcnt > 10)
          stat = alterlist(fin_temp_hier->event_hier,(listcnt+ 10)), totcnt = 1
         ENDIF
         fin_temp_hier->event_hier[listcnt].code_value = c, fin_temp_hier->event_hier[listcnt].level
          = l
        FOOT REPORT
         stat = alterlist(fin_temp_hier->event_hier,listcnt)
        WITH nocounter
       ;end select
      ENDIF
      FOR (f = 1 TO size(fin_temp_hier->event_hier,5))
        SET updt_ind = 0
        SELECT INTO "nl:"
         FROM v500_event_set_explode v
         WHERE (v.event_cd=request->event_sets[x].event_codes[e].code_value)
          AND (v.event_set_cd=fin_temp_hier->event_hier[f].code_value)
         DETAIL
          updt_ind = 1
         WITH nocounter
        ;end select
        IF (updt_ind=1)
         UPDATE  FROM v500_event_set_explode vee
          SET vee.event_set_level = fin_temp_hier->event_hier[f].level, vee.updt_dt_tm = cnvtdatetime
           (curdate,curtime3), vee.updt_id = reqinfo->updt_id,
           vee.updt_task = reqinfo->updt_task, vee.updt_cnt = (vee.updt_cnt+ 1), vee.updt_applctx =
           reqinfo->updt_applctx
          WHERE (vee.event_cd=request->event_sets[x].event_codes[e].code_value)
           AND (vee.event_set_cd=fin_temp_hier->event_hier[f].code_value)
          WITH nocounter
         ;end update
         IF (curqual=0)
          SET errorflag = "Y"
          SET reply->error_msg = concat("Unable to update ",request->event_sets[x].display,
           " on the v500_event_set_explode table")
          GO TO exit_script
         ENDIF
        ELSEIF (updt_ind=0)
         INSERT  FROM v500_event_set_explode vee
          SET vee.event_cd = request->event_sets[x].event_codes[e].code_value, vee.event_set_cd =
           fin_temp_hier->event_hier[f].code_value, vee.event_set_status_cd = 0.0,
           vee.event_set_level = fin_temp_hier->event_hier[f].level, vee.updt_dt_tm = cnvtdatetime(
            curdate,curtime3), vee.updt_id = reqinfo->updt_id,
           vee.updt_task = reqinfo->updt_task, vee.updt_cnt = 0, vee.updt_applctx = reqinfo->
           updt_applctx
          WITH nocounter
         ;end insert
         IF (curqual=0)
          SET errorflag = "Y"
          SET reply->error_msg = concat("Unable to insert ",request->event_sets[x].display,
           " into the v500_event_set_explode table")
          GO TO exit_script
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
 ENDFOR
 SET stat = alterlist(reply->event_sets,repcnt)
#exit_script
 IF (errorflag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
