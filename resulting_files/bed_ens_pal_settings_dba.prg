CREATE PROGRAM bed_ens_pal_settings:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET vcnt = 0
 SET scnt = 0
 SET pip_id = 0.0
 SET section_id = 0.0
 SET column_id = 0.0
 SET pref_id = 0.0
 SET new_id = 0.0
 SET position_cd = 0.0
 SET location_cd = 0.0
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET vcnt = size(request->views,5)
 SET scnt = size(request->sections,5)
 IF (vcnt=0)
  GO TO exit_script
 ENDIF
 IF ((request->action_flag IN (1, 2))
  AND scnt=0)
  GO TO exit_script
 ENDIF
 SUBROUTINE next_id(next_id_dummy)
   SET new_id = 0.0
   SELECT INTO "nl:"
    j = seq(carenet_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_id = cnvtreal(j)
    WITH format, nocounter
   ;end select
   RETURN(new_id)
 END ;Subroutine
 SET demographic_cd = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=25491
   AND cv.cdf_meaning="DEMOGRAPHIC"
  DETAIL
   demographic_cd = cv.code_value
  WITH nocounter
 ;end select
 SET notify_cd = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=25491
   AND cv.cdf_meaning="NOTIFY"
  DETAIL
   notify_cd = cv.code_value
  WITH nocounter
 ;end select
 SET task_cd = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=25491
   AND cv.cdf_meaning="TASK"
  DETAIL
   task_cd = cv.code_value
  WITH nocounter
 ;end select
 SET result_cd = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=25491
   AND cv.cdf_meaning="RESULT"
  DETAIL
   result_cd = cv.code_value
  WITH nocounter
 ;end select
 SET demog_cd = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=25511
   AND cv.cdf_meaning="DEMOGFLD"
  DETAIL
   demog_cd = cv.code_value
  WITH nocounter
 ;end select
 SET note_cd = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=25511
   AND cv.cdf_meaning="NOTEIND"
  DETAIL
   note_cd = cv.code_value
  WITH nocounter
 ;end select
 SET iv_cd = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=25511
   AND cv.cdf_meaning="IVIND"
  DETAIL
   iv_cd = cv.code_value
  WITH nocounter
 ;end select
 SET orddetail_cd = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=25511
   AND cv.cdf_meaning="ORDDETAIL"
  DETAIL
   orddetail_cd = cv.code_value
  WITH nocounter
 ;end select
 SET resnotify_cd = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=25511
   AND cv.cdf_meaning="RESULTNOTIFY"
  DETAIL
   resnotify_cd = cv.code_value
  WITH nocounter
 ;end select
 SET ordnotify_cd = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=25511
   AND cv.cdf_meaning="ORDERNOTIFY"
  DETAIL
   ordnotify_cd = cv.code_value
  WITH nocounter
 ;end select
 SET allergy_cd = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=25511
   AND cv.cdf_meaning="ALLERGYIND"
  DETAIL
   allergy_cd = cv.code_value
  WITH nocounter
 ;end select
 SET problem_cd = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=25511
   AND cv.cdf_meaning="PROBLEMIND"
  DETAIL
   problem_cd = cv.code_value
  WITH nocounter
 ;end select
 SET sched_cd = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=25511
   AND cv.cdf_meaning="SCHEDEVENTIN"
  DETAIL
   sched_cd = cv.code_value
  WITH nocounter
 ;end select
 SET care_cd = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=25511
   AND cv.cdf_meaning="CAREPLANIND"
  DETAIL
   care_cd = cv.code_value
  WITH nocounter
 ;end select
 DECLARE sect_color = vc
 RECORD vw(
   1 qual[*]
     2 id = f8
     2 sect[*]
       3 id = f8
       3 cd = f8
       3 color = vc
 )
 SET stat = alterlist(vw->qual,vcnt)
 FOR (x = 1 TO vcnt)
  SET sccnt = 0
  SELECT INTO "nl:"
   FROM pip p,
    pip_section s,
    pip_prefs pp
   PLAN (p
    WHERE (p.position_cd=request->views[x].position_code_value)
     AND (p.location_cd=request->views[x].location_code_value)
     AND p.prsnl_id=0)
    JOIN (s
    WHERE s.pip_id=p.pip_id)
    JOIN (pp
    WHERE pp.parent_entity_name="PIP_SECTION"
     AND pp.parent_entity_id=s.pip_section_id
     AND pp.prsnl_id=0
     AND pp.pref_name="COLOR")
   ORDER BY p.pip_id, s.sequence
   HEAD p.pip_id
    vw->qual[x].id = p.pip_id
   HEAD s.sequence
    sccnt = (sccnt+ 1), stat = alterlist(vw->qual[x].sect,sccnt), vw->qual[x].sect[sccnt].id = s
    .pip_section_id,
    vw->qual[x].sect[sccnt].cd = s.section_type_cd, vw->qual[x].sect[sccnt].color = pp.pref_value
   WITH nocounter
  ;end select
 ENDFOR
 FREE SET prsnl_col
 RECORD prsnl_col(
   1 pip[*]
     2 id = f8
     2 position_cd = f8
     2 location_cd = f8
     2 sections[*]
       3 id = f8
       3 section_type_cd = f8
       3 columns[*]
         4 id = f8
         4 prsnl_id = f8
         4 column_type_cd = f8
         4 sequence = i4
         4 added_ind = i2
 )
 SET prsnl_pip_cnt = 0
 SET prsnl_sect_cnt = 0
 SET prsnl_col_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(vcnt)),
   pip p,
   pip_section s,
   pip_column c
  PLAN (d)
   JOIN (p
   WHERE (p.position_cd=request->views[d.seq].position_code_value)
    AND (p.location_cd=request->views[d.seq].location_code_value)
    AND p.prsnl_id=0)
   JOIN (s
   WHERE s.pip_id=p.pip_id)
   JOIN (c
   WHERE c.pip_section_id=s.pip_section_id
    AND c.prsnl_id > 0)
  HEAD p.pip_id
   prsnl_pip_cnt = (prsnl_pip_cnt+ 1), stat = alterlist(prsnl_col->pip,prsnl_pip_cnt), prsnl_col->
   pip[prsnl_pip_cnt].id = p.pip_id,
   prsnl_col->pip[prsnl_pip_cnt].position_cd = p.position_cd, prsnl_col->pip[prsnl_pip_cnt].
   location_cd = p.location_cd, prsnl_sect_cnt = 0
  HEAD s.pip_section_id
   prsnl_sect_cnt = (prsnl_sect_cnt+ 1), stat = alterlist(prsnl_col->pip[prsnl_pip_cnt].sections,
    prsnl_sect_cnt), prsnl_col->pip[prsnl_pip_cnt].sections[prsnl_sect_cnt].id = s.pip_section_id,
   prsnl_col->pip[prsnl_pip_cnt].sections[prsnl_sect_cnt].section_type_cd = s.section_type_cd,
   prsnl_col_cnt = 0
  DETAIL
   prsnl_col_cnt = (prsnl_col_cnt+ 1), stat = alterlist(prsnl_col->pip[prsnl_pip_cnt].sections[
    prsnl_sect_cnt].columns,prsnl_col_cnt), prsnl_col->pip[prsnl_pip_cnt].sections[prsnl_sect_cnt].
   columns[prsnl_col_cnt].id = c.pip_column_id,
   prsnl_col->pip[prsnl_pip_cnt].sections[prsnl_sect_cnt].columns[prsnl_col_cnt].prsnl_id = c
   .prsnl_id, prsnl_col->pip[prsnl_pip_cnt].sections[prsnl_sect_cnt].columns[prsnl_col_cnt].
   column_type_cd = c.column_type_cd, prsnl_col->pip[prsnl_pip_cnt].sections[prsnl_sect_cnt].columns[
   prsnl_col_cnt].sequence = c.sequence,
   prsnl_col->pip[prsnl_pip_cnt].sections[prsnl_sect_cnt].columns[prsnl_col_cnt].added_ind = 0
  WITH nocounter
 ;end select
 RECORD del_view(
   1 qual[*]
     2 id = f8
 )
 SET dv_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(vcnt)),
   pip p
  PLAN (d)
   JOIN (p
   WHERE (p.position_cd=request->views[d.seq].position_code_value)
    AND (p.location_cd=request->views[d.seq].location_code_value)
    AND p.prsnl_id=0)
  DETAIL
   dv_cnt = (dv_cnt+ 1), stat = alterlist(del_view->qual,dv_cnt), del_view->qual[dv_cnt].id = p
   .pip_id
  WITH nocounter
 ;end select
 IF (dv_cnt > 0)
  FOR (x = 1 TO dv_cnt)
    FREE SET del_sect
    RECORD del_sect(
      1 qual[*]
        2 id = f8
        2 cd = f8
    )
    SET ds_cnt = 0
    SELECT INTO "nl:"
     FROM pip_section s
     PLAN (s
      WHERE (s.pip_id=del_view->qual[x].id))
     DETAIL
      ds_cnt = (ds_cnt+ 1), stat = alterlist(del_sect->qual,ds_cnt), del_sect->qual[ds_cnt].id = s
      .pip_section_id,
      del_sect->qual[ds_cnt].cd = s.section_type_cd
     WITH nocounter
    ;end select
    IF (ds_cnt > 0)
     FOR (y = 1 TO ds_cnt)
       SET ierrcode = 0
       DELETE  FROM pip_prefs p
        WHERE p.parent_entity_name="PIP_SECTION"
         AND (p.parent_entity_id=del_sect->qual[y].id)
         AND p.prsnl_id=0
        WITH nocounter
       ;end delete
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = "Y"
        SET reply->error_msg = serrmsg
        GO TO exit_script
       ENDIF
       FREE SET del_col
       RECORD del_col(
         1 qual[*]
           2 id = f8
       )
       SET dc_cnt = 0
       SELECT INTO "nl:"
        FROM pip_column c
        PLAN (c
         WHERE (c.pip_section_id=del_sect->qual[y].id)
          AND c.prsnl_id=0)
        DETAIL
         dc_cnt = (dc_cnt+ 1), stat = alterlist(del_col->qual,dc_cnt), del_col->qual[dc_cnt].id = c
         .pip_column_id
        WITH nocounter
       ;end select
       IF (dc_cnt > 0)
        SET ierrcode = 0
        DELETE  FROM pip_prefs p,
          (dummyt d  WITH seq = value(dc_cnt))
         SET p.seq = 1
         PLAN (d)
          JOIN (p
          WHERE p.parent_entity_name="PIP_COLUMN"
           AND (p.parent_entity_id=del_col->qual[d.seq].id)
           AND p.prsnl_id=0)
         WITH nocounter
        ;end delete
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET failed = "Y"
         SET reply->error_msg = serrmsg
         GO TO exit_script
        ENDIF
       ENDIF
       SET ierrcode = 0
       DELETE  FROM pip_column c
        WHERE (c.pip_section_id=del_sect->qual[y].id)
         AND c.prsnl_id=0
        WITH nocounter
       ;end delete
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = "Y"
        SET reply->error_msg = serrmsg
        GO TO exit_script
       ENDIF
     ENDFOR
     SET ierrcode = 0
     DELETE  FROM pip_section s
      WHERE (s.pip_id=del_view->qual[x].id)
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = "Y"
      SET reply->error_msg = serrmsg
      GO TO exit_script
     ENDIF
    ENDIF
  ENDFOR
  SET ierrcode = 0
  DELETE  FROM pip p,
    (dummyt d  WITH seq = value(dv_cnt))
   SET p.seq = 1
   PLAN (d)
    JOIN (p
    WHERE (p.pip_id=del_view->qual[d.seq].id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = "Y"
   SET reply->error_msg = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->action_flag IN (1, 2)))
  FOR (x = 1 TO vcnt)
    SET position_cd = request->views[x].position_code_value
    SET location_cd = request->views[x].location_code_value
    SET pip_id = next_id(1)
    SET ierrcode = 0
    INSERT  FROM pip p
     SET p.pip_id = pip_id, p.prsnl_id = 0.0, p.position_cd = position_cd,
      p.location_cd = location_cd, p.updt_id = reqinfo->updt_id, p.updt_dt_tm = cnvtdatetime(curdate,
       curtime),
      p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0
     PLAN (p)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     SET reply->error_msg = serrmsg
     GO TO exit_script
    ENDIF
    FOR (y = 1 TO scnt)
      SET sect_color = "16777215"
      IF ((vw->qual[x].id > 0))
       FOR (h = 1 TO size(vw->qual[x].sect,5))
         IF ((vw->qual[x].sect[h].cd=request->sections[y].code_value))
          IF ((vw->qual[x].sect[h].color > " "))
           SET sect_color = vw->qual[x].sect[h].color
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
      SET section_id = next_id(1)
      SET ierrcode = 0
      INSERT  FROM pip_section s
       SET s.pip_section_id = section_id, s.pip_id = pip_id, s.section_type_cd = request->sections[y]
        .code_value,
        s.sequence = request->sections[y].sequence, s.updt_id = reqinfo->updt_id, s.updt_dt_tm =
        cnvtdatetime(curdate,curtime),
        s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = 0
       PLAN (s)
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = "Y"
       SET reply->error_msg = serrmsg
       GO TO exit_script
      ENDIF
      IF ((request->sections[y].code_value=task_cd))
       FREE SET task
       RECORD task(
         1 qual[*]
           2 id = f8
           2 pref_name = vc
           2 pref_value = vc
           2 merge_name = vc
           2 merge_id = f8
           2 sequence = i4
       )
       SET stat = alterlist(task->qual,3)
       SET pref_id = next_id(1)
       SET task->qual[1].id = pref_id
       SET task->qual[1].pref_name = "COLOR"
       SET task->qual[1].pref_value = request->sections[y].sect_color
       SET task->qual[1].merge_name = ""
       SET task->qual[1].merge_id = 0
       SET task->qual[1].sequence = 1
       SET pref_id = next_id(1)
       SET task->qual[2].id = pref_id
       SET task->qual[2].pref_name = "WIDTH"
       SET task->qual[2].pref_value = "3000"
       SET task->qual[2].merge_name = ""
       SET task->qual[2].merge_id = 0
       SET task->qual[2].sequence = 1
       SET pref_id = next_id(1)
       SET task->qual[3].id = pref_id
       SET task->qual[3].pref_name = "TIME_INTERVAL"
       SET task->qual[3].pref_value = request->sections[y].task_group_time_interval
       SET task->qual[3].merge_name = ""
       SET task->qual[3].merge_id = 0
       SET task->qual[3].sequence = 1
       SET ccnt = size(request->sections[y].columns,5)
       SET tcnt = 3
       FOR (z = 1 TO ccnt)
         SET tcnt = (tcnt+ 1)
         SET stat = alterlist(task->qual,tcnt)
         SET pref_id = next_id(1)
         SET task->qual[tcnt].id = pref_id
         SET task->qual[tcnt].pref_name = "TASK_GROUP"
         SET task->qual[tcnt].pref_value = ""
         SET task->qual[tcnt].merge_name = "CODE_VALUE"
         SET task->qual[tcnt].merge_id = request->sections[y].columns[z].task_group_code_value
         SET task->qual[tcnt].sequence = request->sections[y].columns[z].sequence
       ENDFOR
       SET ierrcode = 0
       INSERT  FROM pip_prefs p,
         (dummyt d  WITH seq = value(size(task->qual,5)))
        SET p.pip_prefs_id = task->qual[d.seq].id, p.parent_entity_name = "PIP_SECTION", p
         .parent_entity_id = section_id,
         p.prsnl_id = 0.0, p.pref_name = task->qual[d.seq].pref_name, p.pref_value = task->qual[d.seq
         ].pref_value,
         p.merge_name = task->qual[d.seq].merge_name, p.merge_id = task->qual[d.seq].merge_id, p
         .sequence = task->qual[d.seq].sequence,
         p.updt_id = reqinfo->updt_id, p.updt_dt_tm = cnvtdatetime(curdate,curtime), p.updt_task =
         reqinfo->updt_task,
         p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0
        PLAN (d)
         JOIN (p)
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = "Y"
        SET reply->error_msg = serrmsg
        GO TO exit_script
       ENDIF
      ELSE
       FREE SET pref
       RECORD pref(
         1 qual[*]
           2 id = f8
           2 pref_name = vc
           2 pref_value = vc
       )
       SET stat = alterlist(pref->qual,2)
       SET pref_id = next_id(1)
       SET pref->qual[1].id = pref_id
       SET pref->qual[1].pref_name = "COLOR"
       SET pref->qual[1].pref_value = request->sections[y].sect_color
       SET pref_id = next_id(1)
       SET pref->qual[2].id = pref_id
       SET pref->qual[2].pref_name = "WIDTH"
       SET pref->qual[2].pref_value = "3000"
       SET ierrcode = 0
       INSERT  FROM pip_prefs p,
         (dummyt d  WITH seq = value(size(pref->qual,5)))
        SET p.pip_prefs_id = pref->qual[d.seq].id, p.parent_entity_name = "PIP_SECTION", p
         .parent_entity_id = section_id,
         p.prsnl_id = 0.0, p.pref_name = pref->qual[d.seq].pref_name, p.pref_value = pref->qual[d.seq
         ].pref_value,
         p.merge_name = "", p.merge_id = 0, p.sequence = 1,
         p.updt_id = reqinfo->updt_id, p.updt_dt_tm = cnvtdatetime(curdate,curtime), p.updt_task =
         reqinfo->updt_task,
         p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0
        PLAN (d)
         JOIN (p)
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = "Y"
        SET reply->error_msg = serrmsg
        GO TO exit_script
       ENDIF
       SET ccnt = size(request->sections[y].columns,5)
       FOR (z = 1 TO ccnt)
         SET column_id = next_id(1)
         SET ierrcode = 0
         INSERT  FROM pip_column c
          SET c.pip_column_id = column_id, c.pip_section_id = section_id, c.prsnl_id = 0.0,
           c.column_type_cd = request->sections[y].columns[z].code_value, c.sequence = request->
           sections[y].columns[z].sequence, c.updt_id = reqinfo->updt_id,
           c.updt_dt_tm = cnvtdatetime(curdate,curtime), c.updt_task = reqinfo->updt_task, c
           .updt_applctx = reqinfo->updt_applctx,
           c.updt_cnt = 0
          PLAN (c)
          WITH nocounter
         ;end insert
         SET ierrcode = error(serrmsg,1)
         IF (ierrcode > 0)
          SET failed = "Y"
          SET reply->error_msg = serrmsg
          GO TO exit_script
         ENDIF
         IF ((request->sections[y].columns[z].code_value=demog_cd))
          FREE SET demog
          RECORD demog(
            1 qual[*]
              2 id = f8
              2 pref_name = vc
              2 pref_value = vc
              2 merge_name = vc
              2 merge_id = f8
          )
          SET stat = alterlist(demog->qual,4)
          SET pref_id = next_id(1)
          SET demog->qual[1].id = pref_id
          SET demog->qual[1].pref_name = "DETAIL_CD"
          SET demog->qual[1].pref_value = ""
          SET demog->qual[1].merge_name = "CODE_VALUE"
          SET demog->qual[1].merge_id = request->sections[y].columns[z].detail_code_value
          SET pref_id = next_id(1)
          SET demog->qual[2].id = pref_id
          SET demog->qual[2].pref_name = "WIDTH"
          SET demog->qual[2].pref_value = request->sections[y].columns[z].col_width
          SET demog->qual[2].merge_name = ""
          SET demog->qual[2].merge_id = 0
          SET pref_id = next_id(1)
          SET demog->qual[3].id = pref_id
          SET demog->qual[3].pref_name = "TITLE"
          SET demog->qual[3].pref_value = request->sections[y].columns[z].title
          SET demog->qual[3].merge_name = ""
          SET demog->qual[3].merge_id = 0
          SET pref_id = next_id(1)
          SET demog->qual[4].id = pref_id
          SET demog->qual[4].pref_name = "SHOW_WHEN_COLLAPSED"
          SET demog->qual[4].pref_value = cnvtstring(request->sections[y].columns[z].
           show_when_collapsed_ind)
          SET demog->qual[4].merge_name = ""
          SET demog->qual[4].merge_id = 0
          IF (validate(request->sections[y].columns[z].report_code_value))
           IF ((request->sections[y].columns[z].report_code_value > 0))
            SET stat = alterlist(demog->qual,5)
            SET pref_id = next_id(1)
            SET demog->qual[5].id = pref_id
            SET demog->qual[5].pref_name = "REPORT_CD"
            SET demog->qual[5].pref_value = ""
            SET demog->qual[5].merge_name = "CODE_VALUE"
            SET demog->qual[5].merge_id = request->sections[y].columns[z].report_code_value
           ENDIF
          ENDIF
          SET ierrcode = 0
          INSERT  FROM pip_prefs p,
            (dummyt d  WITH seq = value(size(demog->qual,5)))
           SET p.pip_prefs_id = demog->qual[d.seq].id, p.parent_entity_name = "PIP_COLUMN", p
            .parent_entity_id = column_id,
            p.prsnl_id = 0.0, p.pref_name = demog->qual[d.seq].pref_name, p.pref_value = demog->qual[
            d.seq].pref_value,
            p.merge_name = demog->qual[d.seq].merge_name, p.merge_id = demog->qual[d.seq].merge_id, p
            .sequence = 1,
            p.updt_id = reqinfo->updt_id, p.updt_dt_tm = cnvtdatetime(curdate,curtime), p.updt_task
             = reqinfo->updt_task,
            p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0
           PLAN (d)
            JOIN (p)
           WITH nocounter
          ;end insert
          SET ierrcode = error(serrmsg,1)
          IF (ierrcode > 0)
           SET failed = "Y"
           SET reply->error_msg = serrmsg
           GO TO exit_script
          ENDIF
         ENDIF
         IF ((request->sections[y].columns[z].code_value IN (allergy_cd, iv_cd, sched_cd, problem_cd,
         care_cd)))
          FREE SET ind
          RECORD ind(
            1 qual[*]
              2 id = f8
              2 pref_name = vc
              2 pref_value = vc
          )
          SET stat = alterlist(ind->qual,3)
          SET pref_id = next_id(1)
          SET ind->qual[1].id = pref_id
          SET ind->qual[1].pref_name = "TITLE"
          SET ind->qual[1].pref_value = request->sections[y].columns[z].title
          SET pref_id = next_id(1)
          SET ind->qual[2].id = pref_id
          SET ind->qual[2].pref_name = "SHOW_WHEN_COLLAPSED"
          SET ind->qual[2].pref_value = cnvtstring(request->sections[y].columns[z].
           show_when_collapsed_ind)
          SET pref_id = next_id(1)
          SET ind->qual[3].id = pref_id
          SET ind->qual[3].pref_name = "WIDTH"
          SET ind->qual[3].pref_value = request->sections[y].columns[z].col_width
          SET ierrcode = 0
          INSERT  FROM pip_prefs p,
            (dummyt d  WITH seq = value(size(ind->qual,5)))
           SET p.pip_prefs_id = ind->qual[d.seq].id, p.parent_entity_name = "PIP_COLUMN", p
            .parent_entity_id = column_id,
            p.prsnl_id = 0.0, p.pref_name = ind->qual[d.seq].pref_name, p.pref_value = ind->qual[d
            .seq].pref_value,
            p.merge_name = "", p.merge_id = 0, p.sequence = 1,
            p.updt_id = reqinfo->updt_id, p.updt_dt_tm = cnvtdatetime(curdate,curtime), p.updt_task
             = reqinfo->updt_task,
            p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0
           PLAN (d)
            JOIN (p)
           WITH nocounter
          ;end insert
          SET ierrcode = error(serrmsg,1)
          IF (ierrcode > 0)
           SET failed = "Y"
           SET reply->error_msg = serrmsg
           GO TO exit_script
          ENDIF
         ENDIF
         IF ((request->sections[y].columns[z].code_value=orddetail_cd))
          FREE SET ord
          RECORD ord(
            1 qual[*]
              2 id = f8
              2 pref_name = vc
              2 pref_value = vc
              2 merge_name = vc
              2 merge_id = f8
          )
          SET stat = alterlist(ord->qual,3)
          SET pref_id = next_id(1)
          SET ord->qual[1].id = pref_id
          SET ord->qual[1].pref_name = "TITLE"
          SET ord->qual[1].pref_value = request->sections[y].columns[z].title
          SET ord->qual[1].merge_name = ""
          SET ord->qual[1].merge_id = 0
          SET pref_id = next_id(1)
          SET ord->qual[2].id = pref_id
          SET ord->qual[2].pref_name = "SHOW_WHEN_COLLAPSED"
          SET ord->qual[2].pref_value = cnvtstring(request->sections[y].columns[z].
           show_when_collapsed_ind)
          SET ord->qual[2].merge_name = ""
          SET ord->qual[2].merge_id = 0
          SET pref_id = next_id(1)
          SET ord->qual[3].id = pref_id
          SET ord->qual[3].pref_name = "WIDTH"
          SET ord->qual[3].pref_value = request->sections[y].columns[z].col_width
          SET ord->qual[3].merge_name = ""
          SET ord->qual[3].merge_id = 0
          SET ocnt = 3
          IF ((request->sections[y].columns[z].activity_type_code_value > 0))
           SET ocnt = (ocnt+ 1)
           SET stat = alterlist(ord->qual,ocnt)
           SET pref_id = next_id(1)
           SET ord->qual[ocnt].id = pref_id
           SET ord->qual[ocnt].pref_name = "ACTIVITY_TYPE"
           SET ord->qual[ocnt].pref_value = ""
           SET ord->qual[ocnt].merge_name = "CODE_VALUE"
           SET ord->qual[ocnt].merge_id = request->sections[y].columns[z].activity_type_code_value
          ENDIF
          IF ((request->sections[y].columns[z].orderable_code_value > 0))
           SET ocnt = (ocnt+ 1)
           SET stat = alterlist(ord->qual,ocnt)
           SET pref_id = next_id(1)
           SET ord->qual[ocnt].id = pref_id
           SET ord->qual[ocnt].pref_name = "CATALOG_CD"
           SET ord->qual[ocnt].pref_value = ""
           SET ord->qual[ocnt].merge_name = "CODE_VALUE"
           SET ord->qual[ocnt].merge_id = request->sections[y].columns[z].orderable_code_value
          ENDIF
          IF ((request->sections[y].columns[z].format_id > 0))
           SET ocnt = (ocnt+ 1)
           SET stat = alterlist(ord->qual,ocnt)
           SET pref_id = next_id(1)
           SET ord->qual[ocnt].id = pref_id
           SET ord->qual[ocnt].pref_name = "FORMAT_CD"
           SET ord->qual[ocnt].pref_value = ""
           SET ord->qual[ocnt].merge_name = "CODE_VALUE"
           SET ord->qual[ocnt].merge_id = request->sections[y].columns[z].format_id
          ENDIF
          IF ((request->sections[y].columns[z].field_id > 0))
           SET ocnt = (ocnt+ 1)
           SET stat = alterlist(ord->qual,ocnt)
           SET pref_id = next_id(1)
           SET ord->qual[ocnt].id = pref_id
           SET ord->qual[ocnt].pref_name = "OE_FIELD_ID"
           SET ord->qual[ocnt].pref_value = ""
           SET ord->qual[ocnt].merge_name = "OE_FORMAT_FIELDS"
           SET ord->qual[ocnt].merge_id = request->sections[y].columns[z].field_id
          ENDIF
          SET ierrcode = 0
          INSERT  FROM pip_prefs p,
            (dummyt d  WITH seq = value(size(ord->qual,5)))
           SET p.pip_prefs_id = ord->qual[d.seq].id, p.parent_entity_name = "PIP_COLUMN", p
            .parent_entity_id = column_id,
            p.prsnl_id = 0.0, p.pref_name = ord->qual[d.seq].pref_name, p.pref_value = ord->qual[d
            .seq].pref_value,
            p.merge_name = ord->qual[d.seq].merge_name, p.merge_id = ord->qual[d.seq].merge_id, p
            .sequence = 1,
            p.updt_id = reqinfo->updt_id, p.updt_dt_tm = cnvtdatetime(curdate,curtime), p.updt_task
             = reqinfo->updt_task,
            p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0
           PLAN (d)
            JOIN (p)
           WITH nocounter
          ;end insert
          SET ierrcode = error(serrmsg,1)
          IF (ierrcode > 0)
           SET failed = "Y"
           SET reply->error_msg = serrmsg
           GO TO exit_script
          ENDIF
         ENDIF
         IF ((request->sections[y].columns[z].code_value=ordnotify_cd))
          FREE SET ord
          RECORD ord(
            1 qual[*]
              2 id = f8
              2 pref_name = vc
              2 pref_value = vc
              2 merge_name = vc
              2 merge_id = f8
          )
          SET stat = alterlist(ord->qual,3)
          SET pref_id = next_id(1)
          SET ord->qual[1].id = pref_id
          SET ord->qual[1].pref_name = "TITLE"
          SET ord->qual[1].pref_value = request->sections[y].columns[z].title
          SET ord->qual[1].merge_name = ""
          SET ord->qual[1].merge_id = 0
          SET pref_id = next_id(1)
          SET ord->qual[2].id = pref_id
          SET ord->qual[2].pref_name = "SHOW_WHEN_COLLAPSED"
          SET ord->qual[2].pref_value = cnvtstring(request->sections[y].columns[z].
           show_when_collapsed_ind)
          SET ord->qual[2].merge_name = ""
          SET ord->qual[2].merge_id = 0
          SET pref_id = next_id(1)
          SET ord->qual[3].id = pref_id
          SET ord->qual[3].pref_name = "WIDTH"
          SET ord->qual[3].pref_value = request->sections[y].columns[z].col_width
          SET ord->qual[3].merge_name = ""
          SET ord->qual[3].merge_id = 0
          SET ocnt = 3
          IF ((request->sections[y].columns[z].catalog_type_code_value > 0))
           SET ocnt = (ocnt+ 1)
           SET stat = alterlist(ord->qual,ocnt)
           SET pref_id = next_id(1)
           SET ord->qual[ocnt].id = pref_id
           SET ord->qual[ocnt].pref_value = ""
           IF ((request->sections[y].columns[z].catalog_type_code_value=1))
            SET ord->qual[ocnt].pref_name = "ALL_ORDERS"
            SET ord->qual[ocnt].merge_name = "CODE_VALUE"
            SET ord->qual[ocnt].merge_id = request->sections[y].columns[z].catalog_type_code_value
           ELSE
            SET ord->qual[ocnt].pref_name = "CATALOG_TYPE"
            SET ord->qual[ocnt].merge_name = "CODE_VALUE"
            SET ord->qual[ocnt].merge_id = request->sections[y].columns[z].catalog_type_code_value
           ENDIF
          ENDIF
          IF ((request->sections[y].columns[z].ord_activity_type_code_value > 0))
           SET ocnt = (ocnt+ 1)
           SET stat = alterlist(ord->qual,ocnt)
           SET pref_id = next_id(1)
           SET ord->qual[ocnt].id = pref_id
           SET ord->qual[ocnt].pref_name = "ACTIVITY_TYPE"
           SET ord->qual[ocnt].pref_value = ""
           SET ord->qual[ocnt].merge_name = "CODE_VALUE"
           SET ord->qual[ocnt].merge_id = request->sections[y].columns[z].
           ord_activity_type_code_value
          ENDIF
          SET ierrcode = 0
          INSERT  FROM pip_prefs p,
            (dummyt d  WITH seq = value(size(ord->qual,5)))
           SET p.pip_prefs_id = ord->qual[d.seq].id, p.parent_entity_name = "PIP_COLUMN", p
            .parent_entity_id = column_id,
            p.prsnl_id = 0.0, p.pref_name = ord->qual[d.seq].pref_name, p.pref_value = ord->qual[d
            .seq].pref_value,
            p.merge_name = ord->qual[d.seq].merge_name, p.merge_id = ord->qual[d.seq].merge_id, p
            .sequence = 1,
            p.updt_id = reqinfo->updt_id, p.updt_dt_tm = cnvtdatetime(curdate,curtime), p.updt_task
             = reqinfo->updt_task,
            p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0
           PLAN (d)
            JOIN (p)
           WITH nocounter
          ;end insert
          SET ierrcode = error(serrmsg,1)
          IF (ierrcode > 0)
           SET failed = "Y"
           SET reply->error_msg = serrmsg
           GO TO exit_script
          ENDIF
         ENDIF
         IF ((request->sections[y].columns[z].code_value=resnotify_cd))
          FREE SET res
          RECORD res(
            1 qual[*]
              2 id = f8
              2 pref_name = vc
              2 pref_value = vc
          )
          SET stat = alterlist(res->qual,4)
          SET pref_id = next_id(1)
          SET res->qual[1].id = pref_id
          SET res->qual[1].pref_name = "TITLE"
          SET res->qual[1].pref_value = request->sections[y].columns[z].title
          SET pref_id = next_id(1)
          SET res->qual[2].id = pref_id
          SET res->qual[2].pref_name = "SHOW_WHEN_COLLAPSED"
          SET res->qual[2].pref_value = cnvtstring(request->sections[y].columns[z].
           show_when_collapsed_ind)
          SET pref_id = next_id(1)
          SET res->qual[3].id = pref_id
          SET res->qual[3].pref_name = "WIDTH"
          SET res->qual[3].pref_value = request->sections[y].columns[z].col_width
          SET pref_id = next_id(1)
          SET res->qual[4].id = pref_id
          SET res->qual[4].pref_name = "EVENT_SET_NAME"
          IF ((request->sections[y].columns[z].event_set_name > " "))
           SET res->qual[4].pref_value = request->sections[y].columns[z].event_set_name
          ELSE
           SELECT INTO "NL:"
            FROM v500_event_set_code v
            WHERE (v.event_set_cd=request->sections[y].columns[z].event_set_code_value)
            DETAIL
             res->qual[4].pref_value = v.event_set_name
            WITH nocounter
           ;end select
          ENDIF
          SET ierrcode = 0
          INSERT  FROM pip_prefs p,
            (dummyt d  WITH seq = value(size(res->qual,5)))
           SET p.pip_prefs_id = res->qual[d.seq].id, p.parent_entity_name = "PIP_COLUMN", p
            .parent_entity_id = column_id,
            p.prsnl_id = 0.0, p.pref_name = res->qual[d.seq].pref_name, p.pref_value = res->qual[d
            .seq].pref_value,
            p.merge_name = "", p.merge_id = 0, p.sequence = 1,
            p.updt_id = reqinfo->updt_id, p.updt_dt_tm = cnvtdatetime(curdate,curtime), p.updt_task
             = reqinfo->updt_task,
            p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0
           PLAN (d)
            JOIN (p)
           WITH nocounter
          ;end insert
          SET ierrcode = error(serrmsg,1)
          IF (ierrcode > 0)
           SET failed = "Y"
           SET reply->error_msg = serrmsg
           GO TO exit_script
          ENDIF
         ENDIF
         IF ((request->sections[y].columns[z].code_value=result_cd))
          FREE SET res
          RECORD res(
            1 qual[*]
              2 id = f8
              2 pref_name = vc
              2 pref_value = vc
          )
          SET stat = alterlist(res->qual,5)
          SET pref_id = next_id(1)
          SET res->qual[1].id = pref_id
          SET res->qual[1].pref_name = "TITLE"
          SET res->qual[1].pref_value = request->sections[y].columns[z].title
          SET pref_id = next_id(1)
          SET res->qual[2].id = pref_id
          SET res->qual[2].pref_name = "SHOW_WHEN_COLLAPSED"
          SET res->qual[2].pref_value = cnvtstring(request->sections[y].columns[z].
           show_when_collapsed_ind)
          SET pref_id = next_id(1)
          SET res->qual[3].id = pref_id
          SET res->qual[3].pref_name = "WIDTH"
          SET res->qual[3].pref_value = request->sections[y].columns[z].col_width
          SET pref_id = next_id(1)
          SET res->qual[4].id = pref_id
          SET res->qual[4].pref_name = "EVENT_SET_NAME"
          IF ((request->sections[y].columns[z].event_set_name > " "))
           SET res->qual[4].pref_value = request->sections[y].columns[z].event_set_name
          ELSE
           SELECT INTO "NL:"
            FROM v500_event_set_code v
            WHERE (v.event_set_cd=request->sections[y].columns[z].event_set_code_value)
            DETAIL
             res->qual[4].pref_value = v.event_set_name
            WITH nocounter
           ;end select
          ENDIF
          SET ierrcode = 0
          SET pref_id = next_id(1)
          SET res->qual[5].id = pref_id
          SET res->qual[5].pref_name = "DURATION"
          SET res->qual[5].pref_value = request->sections[y].columns[z].duration
          SET ierrcode = 0
          INSERT  FROM pip_prefs p,
            (dummyt d  WITH seq = value(size(res->qual,5)))
           SET p.pip_prefs_id = res->qual[d.seq].id, p.parent_entity_name = "PIP_COLUMN", p
            .parent_entity_id = column_id,
            p.prsnl_id = 0.0, p.pref_name = res->qual[d.seq].pref_name, p.pref_value = res->qual[d
            .seq].pref_value,
            p.merge_name = "", p.merge_id = 0, p.sequence = 1,
            p.updt_id = reqinfo->updt_id, p.updt_dt_tm = cnvtdatetime(curdate,curtime), p.updt_task
             = reqinfo->updt_task,
            p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0
           PLAN (d)
            JOIN (p)
           WITH nocounter
          ;end insert
          SET ierrcode = error(serrmsg,1)
          IF (ierrcode > 0)
           SET failed = "Y"
           SET reply->error_msg = serrmsg
           GO TO exit_script
          ENDIF
         ENDIF
         IF ((request->sections[y].columns[z].code_value=note_cd))
          FREE SET note
          RECORD note(
            1 qual[*]
              2 id = f8
              2 pref_name = vc
              2 pref_value = vc
              2 merge_name = vc
              2 merge_id = f8
          )
          SET stat = alterlist(note->qual,4)
          SET pref_id = next_id(1)
          SET note->qual[1].id = pref_id
          SET note->qual[1].pref_name = "TITLE"
          SET note->qual[1].pref_value = request->sections[y].columns[z].title
          SET note->qual[1].merge_name = ""
          SET note->qual[1].merge_id = 0
          SET pref_id = next_id(1)
          SET note->qual[2].id = pref_id
          SET note->qual[2].pref_name = "SHOW_WHEN_COLLAPSED"
          SET note->qual[2].pref_value = cnvtstring(request->sections[y].columns[z].
           show_when_collapsed_ind)
          SET note->qual[2].merge_name = ""
          SET note->qual[2].merge_id = 0
          SET pref_id = next_id(1)
          SET note->qual[3].id = pref_id
          SET note->qual[3].pref_name = "WIDTH"
          SET note->qual[3].pref_value = request->sections[y].columns[z].col_width
          SET note->qual[3].merge_name = ""
          SET note->qual[3].merge_id = 0
          SET pref_id = next_id(1)
          SET note->qual[4].id = pref_id
          SET note->qual[4].pref_name = "NOTE_TYPE"
          SET note->qual[4].pref_value = ""
          SET note->qual[4].merge_name = "CODE_VALUE"
          SET note->qual[4].merge_id = request->sections[y].columns[z].note_code_value
          SET ierrcode = 0
          INSERT  FROM pip_prefs p,
            (dummyt d  WITH seq = value(size(note->qual,5)))
           SET p.pip_prefs_id = note->qual[d.seq].id, p.parent_entity_name = "PIP_COLUMN", p
            .parent_entity_id = column_id,
            p.prsnl_id = 0.0, p.pref_name = note->qual[d.seq].pref_name, p.pref_value = note->qual[d
            .seq].pref_value,
            p.merge_name = note->qual[d.seq].merge_name, p.merge_id = note->qual[d.seq].merge_id, p
            .sequence = 1,
            p.updt_id = reqinfo->updt_id, p.updt_dt_tm = cnvtdatetime(curdate,curtime), p.updt_task
             = reqinfo->updt_task,
            p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0
           PLAN (d)
            JOIN (p)
           WITH nocounter
          ;end insert
          SET ierrcode = error(serrmsg,1)
          IF (ierrcode > 0)
           SET failed = "Y"
           SET reply->error_msg = serrmsg
           GO TO exit_script
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
      FOR (p = 1 TO prsnl_pip_cnt)
        IF ((prsnl_col->pip[p].location_cd=location_cd)
         AND (prsnl_col->pip[p].position_cd=position_cd))
         SET prsnl_sect_cnt = size(prsnl_col->pip[p].sections,5)
         FOR (s = 1 TO prsnl_sect_cnt)
           IF ((prsnl_col->pip[p].sections[s].section_type_cd=request->sections[y].code_value))
            SET prsnl_col_cnt = size(prsnl_col->pip[p].sections[s].columns,5)
            FOR (c = 1 TO prsnl_col_cnt)
              IF ((prsnl_col->pip[p].sections[s].columns[c].added_ind=0))
               SET ccnt = (ccnt+ 1)
               SET ierrcode = 0
               UPDATE  FROM pip_column c
                SET c.pip_section_id = section_id, c.sequence = ccnt, c.updt_id = reqinfo->updt_id,
                 c.updt_dt_tm = cnvtdatetime(curdate,curtime), c.updt_task = reqinfo->updt_task, c
                 .updt_applctx = reqinfo->updt_applctx,
                 c.updt_cnt = (c.updt_cnt+ 1)
                WHERE (c.pip_column_id=prsnl_col->pip[p].sections[s].columns[c].id)
                WITH nocounter
               ;end update
               SET ierrcode = error(serrmsg,1)
               IF (ierrcode > 0)
                SET failed = "Y"
                SET reply->error_msg = serrmsg
                GO TO exit_script
               ENDIF
               SET prsnl_col->pip[p].sections[s].columns[c].added_ind = 1
              ENDIF
            ENDFOR
           ENDIF
         ENDFOR
        ENDIF
      ENDFOR
    ENDFOR
  ENDFOR
 ENDIF
 FOR (p = 1 TO prsnl_pip_cnt)
  SET prsnl_sect_cnt = size(prsnl_col->pip[p].sections,5)
  FOR (s = 1 TO prsnl_sect_cnt)
   SET prsnl_col_cnt = size(prsnl_col->pip[p].sections[s].columns,5)
   FOR (c = 1 TO prsnl_col_cnt)
     IF ((prsnl_col->pip[p].sections[s].columns[c].added_ind=0))
      SET ierrcode = 0
      DELETE  FROM pip_column c
       WHERE (c.pip_column_id=prsnl_col->pip[p].sections[s].columns[c].id)
       WITH nocounter
      ;end delete
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = "Y"
       SET reply->error_msg = serrmsg
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
  ENDFOR
 ENDFOR
 CALL echorecord(reply)
#exit_script
 IF (failed="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
