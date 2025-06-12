CREATE PROGRAM dcp_chg_pip_prefs:dba
 DECLARE failed = c1 WITH noconstant("F")
 DECLARE updt_pref_cnt = i4 WITH noconstant(cnvtint(size(request->qual_updt_prefs,5)))
 DECLARE add_pref_cnt = i4 WITH noconstant(cnvtint(size(request->qual_add_prefs,5)))
 DECLARE del_pref_cnt = i4 WITH noconstant(cnvtint(size(request->qual_del_prefs,5)))
 DECLARE col_cnt = i4 WITH noconstant(cnvtint(size(request->qual_col,5)))
 DECLARE new_id = f8 WITH noconstant(0.0)
 DECLARE pip_column_id = f8 WITH noconstant(0.0)
 CALL echo(build("updt_pref_cnt: ",updt_pref_cnt))
 CALL echo(build("add_pref_cnt: ",add_pref_cnt))
 CALL echo(build("del_pref_cnt: ",del_pref_cnt))
 CALL echo(build("col_cnt: ",col_cnt))
 CALL echo(build("col_cnt: ",col_cnt))
 FOR (x = 1 TO col_cnt)
   CALL echo(build("X ",x))
   SELECT INTO "nl:"
    j = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     pip_column_id = cnvtreal(j)
    WITH format, nocounter
   ;end select
   CALL echo(build("pip_col_id: ",pip_column_id))
   INSERT  FROM pip_column pc
    SET pc.pip_column_id = pip_column_id, pc.pip_section_id = request->qual_col[x].pip_section_id, pc
     .column_type_cd = request->qual_col[x].column_type_cd,
     pc.sequence = request->qual_col[x].sequence, pc.prsnl_id = request->qual_col[x].prsnl_id, pc
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     pc.updt_id = reqinfo->updt_id, pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->
     updt_applctx,
     pc.updt_cnt = 0
    WITH counter
   ;end insert
   IF (curqual=0)
    GO TO exit_script
   ENDIF
   CALL echo(build("INSERT COL HERE ",col_cnt))
   SET column_pref_cnt = cnvtint(size(request->qual_col[x].column_prefs,5))
   INSERT  FROM pip_prefs pp,
     (dummyt d1  WITH seq = value(column_pref_cnt))
    SET pp.pip_prefs_id = seq(carenet_seq,nextval), pp.prsnl_id = request->qual_col[x].prsnl_id, pp
     .pref_name = request->qual_col[x].column_prefs[d1.seq].pref_name,
     pp.pref_value = request->qual_col[x].column_prefs[d1.seq].pref_value, pp.parent_entity_name =
     "PIP_COLUMN", pp.parent_entity_id = pip_column_id,
     pp.merge_name = request->qual_col[x].column_prefs[d1.seq].merge_name, pp.merge_id = request->
     qual_col[x].column_prefs[d1.seq].merge_id, pp.sequence = request->qual_col[x].column_prefs[d1
     .seq].sequence,
     pp.updt_dt_tm = cnvtdatetime(curdate,curtime3), pp.updt_id = reqinfo->updt_id, pp.updt_task =
     reqinfo->updt_task,
     pp.updt_applctx = reqinfo->updt_applctx, pp.updt_cnt = 0
    PLAN (d1)
     JOIN (pp)
    WITH nocounter
   ;end insert
 ENDFOR
 FOR (x = 1 TO updt_pref_cnt)
   SET updt_cnt = 0
   SELECT INTO "nl:"
    pp.pip_prefs_id
    FROM pip_prefs pp
    WHERE (pp.pip_prefs_id=request->qual_updt_prefs[x].pip_prefs_id)
    HEAD REPORT
     updt_cnt = pp.updt_cnt
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET cfailed = "T"
    GO TO exit_script
   ENDIF
   IF ((updt_cnt != request->qual_updt_prefs[x].updt_cnt))
    SET cfailed = "T"
    GO TO exit_script
   ENDIF
   UPDATE  FROM pip_prefs pp
    SET pp.pref_name = request->qual_updt_prefs[x].pref_name, pp.pref_value = request->
     qual_updt_prefs[x].pref_value, pp.merge_name = request->qual_updt_prefs[x].merge_name,
     pp.merge_id = request->qual_updt_prefs[x].merge_id, pp.sequence = request->qual_updt_prefs[x].
     sequence, pp.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     pp.updt_id = reqinfo->updt_id, pp.updt_task = reqinfo->updt_task, pp.updt_cnt = (pp.updt_cnt+ 1),
     pp.updt_applctx = reqinfo->updt_applctx
    WHERE (pp.pip_prefs_id=request->qual_updt_prefs[x].pip_prefs_id)
   ;end update
   IF (curqual=0)
    SET cfailed = "T"
    GO TO exit_script
   ENDIF
 ENDFOR
 CALL echo(build("add_pref_cnt: ",add_pref_cnt))
 FOR (x = 1 TO add_pref_cnt)
   SELECT INTO "nl:"
    j = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     new_id = cnvtreal(j)
    WITH format, nocounter
   ;end select
   INSERT  FROM pip_prefs pp
    SET pp.pip_prefs_id = new_id, pp.parent_entity_name = request->qual_add_prefs[x].
     parent_entity_name, pp.parent_entity_id = request->qual_add_prefs[x].parent_entity_id,
     pp.prsnl_id = request->qual_add_prefs[x].prsnl_id, pp.pref_name = request->qual_add_prefs[x].
     pref_name, pp.pref_value = request->qual_add_prefs[x].pref_value,
     pp.merge_name = request->qual_add_prefs[x].merge_name, pp.merge_id = request->qual_add_prefs[x].
     merge_id, pp.sequence = request->qual_add_prefs[x].sequence,
     pp.updt_dt_tm = cnvtdatetime(curdate,curtime3), pp.updt_id = reqinfo->updt_id, pp.updt_task =
     reqinfo->updt_task,
     pp.updt_cnt = 0, pp.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET cfailed = "T"
    GO TO exit_script
   ENDIF
 ENDFOR
 CALL echo(build("del_cnt: ",del_pref_cnt))
 FOR (x = 1 TO del_pref_cnt)
  DELETE  FROM pip_prefs
   WHERE (request->qual_del_prefs[x].merge_id=merge_id)
   WITH nocounter
  ;end delete
  IF (curqual=0)
   SET cfailed = "T"
   GO TO exit_script
  ENDIF
 ENDFOR
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
