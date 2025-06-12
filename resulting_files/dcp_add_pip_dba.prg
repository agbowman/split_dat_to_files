CREATE PROGRAM dcp_add_pip:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET reply->status_data.status = "F"
 DECLARE pip_id = f8 WITH protect, noconstant(0)
 DECLARE pip_section_id = f8 WITH protect, noconstant(0)
 DECLARE pip_column_id = f8 WITH protect, noconstant(0)
 SET section_cnt = 0
 SET section_cnt = cnvtint(size(request->section,5))
 SET section_pref_cnt = 0
 SET column_cnt = 0
 SET column_pref_cnt = 0
 SELECT INTO "nl:"
  j = seq(carenet_seq,nextval)
  FROM dual
  DETAIL
   pip_id = j
  WITH format, nocounter
 ;end select
 INSERT  FROM pip p
  SET p.pip_id = pip_id, p.position_cd = request->position_cd, p.prsnl_id = request->prsnl_id,
   p.location_cd = request->location_cd, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id =
   reqinfo->updt_id,
   p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "pip table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to insert into pip table"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO section_cnt)
   SELECT INTO "nl:"
    j = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     pip_section_id = j
    WITH format, nocounter
   ;end select
   INSERT  FROM pip_section ps
    SET ps.pip_id = pip_id, ps.pip_section_id = pip_section_id, ps.section_type_cd = request->
     section[x].section_type_cd,
     ps.sequence = request->section[x].sequence, ps.updt_dt_tm = cnvtdatetime(curdate,curtime3), ps
     .updt_id = reqinfo->updt_id,
     ps.updt_task = reqinfo->updt_task, ps.updt_applctx = reqinfo->updt_applctx, ps.updt_cnt = 0
    WITH counter
   ;end insert
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "PIP_SECTION"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Unable to insert into pip_section table"
    SET failed = "T"
    GO TO exit_script
   ENDIF
   SET section_pref_cnt = cnvtint(size(request->section[x].section_prefs,5))
   IF (section_pref_cnt > 0)
    INSERT  FROM pip_prefs pp,
      (dummyt d1  WITH seq = value(section_pref_cnt))
     SET pp.pip_prefs_id = seq(carenet_seq,nextval), pp.prsnl_id = request->section[x].section_prefs[
      d1.seq].prsnl_id, pp.pref_name = request->section[x].section_prefs[d1.seq].pref_name,
      pp.pref_value = request->section[x].section_prefs[d1.seq].pref_value, pp.parent_entity_name =
      "PIP_SECTION", pp.parent_entity_id = pip_section_id,
      pp.merge_name = request->section[x].section_prefs[d1.seq].merge_name, pp.merge_id = request->
      section[x].section_prefs[d1.seq].merge_id, pp.sequence = request->section[x].section_prefs[d1
      .seq].sequence,
      pp.updt_dt_tm = cnvtdatetime(curdate,curtime3), pp.updt_id = reqinfo->updt_id, pp.updt_task =
      reqinfo->updt_task,
      pp.updt_applctx = reqinfo->updt_applctx, pp.updt_cnt = 0
     PLAN (d1)
      JOIN (pp)
     WITH nocounter
    ;end insert
   ENDIF
   SET column_cnt = cnvtint(size(request->section[x].column,5))
   FOR (i = 1 TO column_cnt)
     SELECT INTO "nl:"
      j = seq(carenet_seq,nextval)
      FROM dual
      DETAIL
       pip_column_id = j
      WITH format, nocounter
     ;end select
     INSERT  FROM pip_column pc
      SET pc.pip_column_id = pip_column_id, pc.pip_section_id = pip_section_id, pc.column_type_cd =
       request->section[x].column[i].column_type_cd,
       pc.sequence = request->section[x].column[i].sequence, pc.prsnl_id = request->section[x].
       column[i].prsnl_id, pc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       pc.updt_id = reqinfo->updt_id, pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->
       updt_applctx,
       pc.updt_cnt = 0
      WITH counter
     ;end insert
     IF (curqual=0)
      SET reply->status_data.subeventstatus[1].operationname = "INSERT"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "PIP_COLUMN"
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Unable to insert into pip_column table"
      SET failed = "T"
      GO TO exit_script
     ENDIF
     SET column_pref_cnt = cnvtint(size(request->section[x].column[i].column_prefs,5))
     INSERT  FROM pip_prefs pp,
       (dummyt d1  WITH seq = value(column_pref_cnt))
      SET pp.pip_prefs_id = seq(carenet_seq,nextval), pp.prsnl_id = request->section[x].column[i].
       column_prefs[d1.seq].prsnl_id, pp.pref_name = request->section[x].column[i].column_prefs[d1
       .seq].pref_name,
       pp.pref_value = request->section[x].column[i].column_prefs[d1.seq].pref_value, pp
       .parent_entity_name = "PIP_COLUMN", pp.parent_entity_id = pip_column_id,
       pp.merge_name = request->section[x].column[i].column_prefs[d1.seq].merge_name, pp.merge_id =
       request->section[x].column[i].column_prefs[d1.seq].merge_id, pp.sequence = request->section[x]
       .column[i].column_prefs[d1.seq].sequence,
       pp.updt_dt_tm = cnvtdatetime(curdate,curtime3), pp.updt_id = reqinfo->updt_id, pp.updt_task =
       reqinfo->updt_task,
       pp.updt_applctx = reqinfo->updt_applctx, pp.updt_cnt = 0
      PLAN (d1)
       JOIN (pp)
      WITH nocounter
     ;end insert
   ENDFOR
 ENDFOR
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
END GO
