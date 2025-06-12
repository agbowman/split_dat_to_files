CREATE PROGRAM bed_copy_pal_settings:dba
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
 SET copy_cnt = 0
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
 SET copy_cnt = size(request->copy_to,5)
 IF (copy_cnt=0)
  GO TO exit_script
 ENDIF
 SET copy_from_pip_id = 0.0
 SELECT INTO "nl:"
  FROM pip p
  PLAN (p
   WHERE (p.position_cd=request->copy_from_position_code_value)
    AND (p.location_cd=request->copy_from_location_code_value)
    AND p.prsnl_id=0)
  DETAIL
   copy_from_pip_id = p.pip_id
  WITH nocounter
 ;end select
 SET always_delete_ind = 0
 IF (validate(request->always_delete_ind))
  SET always_delete_ind = request->always_delete_ind
 ENDIF
 IF (copy_from_pip_id=0
  AND always_delete_ind=0)
  GO TO exit_script
 ENDIF
 SUBROUTINE next_id(next_id_dummy)
   SET new_id = 0.0
   SELECT INTO "nl:"
    j = seq(carenet_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_id = cnvtreal(j)
    WITH format, counter
   ;end select
   RETURN(new_id)
 END ;Subroutine
 RECORD del_view(
   1 qual[*]
     2 id = f8
 )
 SET dv_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(copy_cnt)),
   pip p
  PLAN (d
   WHERE (((request->copy_to[d.seq].position_code_value != request->copy_from_position_code_value))
    OR ((request->copy_to[d.seq].location_code_value != request->copy_from_location_code_value))) )
   JOIN (p
   WHERE (p.position_cd=request->copy_to[d.seq].position_code_value)
    AND (p.location_cd=request->copy_to[d.seq].location_code_value)
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
 IF (copy_from_pip_id=0)
  GO TO exit_script
 ENDIF
 RECORD temp(
   1 squal[*]
     2 id = f8
     2 cd = f8
     2 seq = i4
     2 s_prefs[*]
       3 pref_name = vc
       3 pref_value = vc
       3 merge_name = vc
       3 merge_id = f8
       3 sequence = i4
     2 cqual[*]
       3 id = f8
       3 cd = f8
       3 seq = i4
       3 c_prefs[*]
         4 pref_name = vc
         4 pref_value = vc
         4 merge_name = vc
         4 merge_id = f8
         4 sequence = i4
 )
 SET scnt = 0
 SET pcnt = 0
 SELECT INTO "nl:"
  FROM pip_section s,
   pip_prefs p
  PLAN (s
   WHERE s.pip_id=copy_from_pip_id)
   JOIN (p
   WHERE p.parent_entity_name="PIP_SECTION"
    AND p.parent_entity_id=s.pip_section_id
    AND p.prsnl_id=0)
  ORDER BY s.pip_section_id
  HEAD s.pip_section_id
   pcnt = 0, scnt = (scnt+ 1), stat = alterlist(temp->squal,scnt),
   temp->squal[scnt].id = s.pip_section_id, temp->squal[scnt].cd = s.section_type_cd, temp->squal[
   scnt].seq = s.sequence
  DETAIL
   pcnt = (pcnt+ 1), stat = alterlist(temp->squal[scnt].s_prefs,pcnt), temp->squal[scnt].s_prefs[pcnt
   ].pref_name = p.pref_name,
   temp->squal[scnt].s_prefs[pcnt].pref_value = p.pref_value, temp->squal[scnt].s_prefs[pcnt].
   merge_name = p.merge_name, temp->squal[scnt].s_prefs[pcnt].merge_id = p.merge_id,
   temp->squal[scnt].s_prefs[pcnt].sequence = p.sequence
  WITH nocounter
 ;end select
 FOR (x = 1 TO scnt)
   SET ccnt = 0
   SET pcnt = 0
   SELECT INTO "nl:"
    FROM pip_column c,
     pip_prefs p
    PLAN (c
     WHERE (c.pip_section_id=temp->squal[x].id)
      AND c.prsnl_id=0)
     JOIN (p
     WHERE p.parent_entity_name="PIP_COLUMN"
      AND p.parent_entity_id=c.pip_column_id
      AND p.prsnl_id=0)
    ORDER BY c.pip_column_id
    HEAD c.pip_column_id
     pcnt = 0, ccnt = (ccnt+ 1), stat = alterlist(temp->squal[x].cqual,ccnt),
     temp->squal[x].cqual[ccnt].id = c.pip_column_id, temp->squal[x].cqual[ccnt].cd = c
     .column_type_cd, temp->squal[x].cqual[ccnt].seq = c.sequence
    DETAIL
     pcnt = (pcnt+ 1), stat = alterlist(temp->squal[x].cqual[ccnt].c_prefs,pcnt), temp->squal[x].
     cqual[ccnt].c_prefs[pcnt].pref_name = p.pref_name,
     temp->squal[x].cqual[ccnt].c_prefs[pcnt].pref_value = p.pref_value, temp->squal[x].cqual[ccnt].
     c_prefs[pcnt].merge_name = p.merge_name, temp->squal[x].cqual[ccnt].c_prefs[pcnt].merge_id = p
     .merge_id,
     temp->squal[x].cqual[ccnt].c_prefs[pcnt].sequence = p.sequence
    WITH nocounter
   ;end select
 ENDFOR
 FOR (a = 1 TO copy_cnt)
   IF ((((request->copy_from_position_code_value != request->copy_to[a].position_code_value)) OR ((
   request->copy_from_location_code_value != request->copy_to[a].location_code_value))) )
    SET position_cd = request->copy_to[a].position_code_value
    SET location_cd = request->copy_to[a].location_code_value
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
    FOR (x = 1 TO scnt)
      SET section_id = next_id(1)
      SET ierrcode = 0
      INSERT  FROM pip_section s
       SET s.pip_section_id = section_id, s.pip_id = pip_id, s.section_type_cd = temp->squal[x].cd,
        s.sequence = temp->squal[x].seq, s.updt_id = reqinfo->updt_id, s.updt_dt_tm = cnvtdatetime(
         curdate,curtime),
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
      SET pcnt = size(temp->squal[x].s_prefs,5)
      SET ierrcode = 0
      INSERT  FROM pip_prefs p,
        (dummyt d  WITH seq = value(pcnt))
       SET p.pip_prefs_id = seq(carenet_seq,nextval), p.parent_entity_name = "PIP_SECTION", p
        .parent_entity_id = section_id,
        p.prsnl_id = 0.0, p.pref_name = temp->squal[x].s_prefs[d.seq].pref_name, p.pref_value = temp
        ->squal[x].s_prefs[d.seq].pref_value,
        p.merge_name = temp->squal[x].s_prefs[d.seq].merge_name, p.merge_id = temp->squal[x].s_prefs[
        d.seq].merge_id, p.sequence = temp->squal[x].s_prefs[d.seq].sequence,
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
      SET ccnt = size(temp->squal[x].cqual,5)
      FOR (y = 1 TO ccnt)
        SET column_id = next_id(1)
        SET ierrcode = 0
        INSERT  FROM pip_column c
         SET c.pip_column_id = column_id, c.pip_section_id = section_id, c.prsnl_id = 0.0,
          c.column_type_cd = temp->squal[x].cqual[y].cd, c.sequence = temp->squal[x].cqual[y].seq, c
          .updt_id = reqinfo->updt_id,
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
        SET pcnt = size(temp->squal[x].cqual[y].c_prefs,5)
        SET ierrcode = 0
        INSERT  FROM pip_prefs p,
          (dummyt d  WITH seq = value(pcnt))
         SET p.pip_prefs_id = seq(carenet_seq,nextval), p.parent_entity_name = "PIP_COLUMN", p
          .parent_entity_id = column_id,
          p.prsnl_id = 0.0, p.pref_name = temp->squal[x].cqual[y].c_prefs[d.seq].pref_name, p
          .pref_value = temp->squal[x].cqual[y].c_prefs[d.seq].pref_value,
          p.merge_name = temp->squal[x].cqual[y].c_prefs[d.seq].merge_name, p.merge_id = temp->squal[
          x].cqual[y].c_prefs[d.seq].merge_id, p.sequence = temp->squal[x].cqual[y].c_prefs[d.seq].
          sequence,
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
      ENDFOR
    ENDFOR
   ENDIF
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
