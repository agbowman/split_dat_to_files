CREATE PROGRAM dm_ins_arc_cons:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 IF (validate(danc_request->batch_selection,"-1")="-1")
  FREE RECORD danc_request
  RECORD danc_request(
    1 batch_selection = vc
    1 cons_prefix = vc
    1 all_tab_ind = i2
  )
 ENDIF
 IF ((validate(danc_reply->found_ind,- (1))=- (1)))
  FREE RECORD danc_reply
  RECORD danc_reply(
    1 found_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(requestin->list_0[1].child_table,"X")="X")
  CALL echo("*****************************************")
  CALL echo("*****FAILED: requestin doesn't exist*****")
  CALL echo("*****************************************")
  SET readme_data->status = "F"
  SET readme_data->message = "FAILED: requestin doesn't exist"
 ELSE
  CALL echo("*****************************************")
  CALL echo("******* CSV File Finished Loading *******")
  CALL echo("*****************************************")
  FOR (ri_ndx = 1 TO size(requestin->list_0,5))
    UPDATE  FROM dm_arc_constraints dac
     SET dac.exclude_ind = cnvtint(requestin->list_0[ri_ndx].exclude_ind), dac.active_ind = cnvtint(
       requestin->list_0[ri_ndx].active_ind), dac.archive_entity_name = requestin->list_0[ri_ndx].
      archive_entity_name,
      dac.constraint_name = trim(requestin->list_0[ri_ndx].constraint_name,3), dac.updt_dt_tm =
      cnvtdatetime(curdate,curtime3), dac.updt_id = reqinfo->updt_id,
      dac.updt_cnt = (dac.updt_cnt+ 1), dac.updt_task = reqinfo->updt_task, dac.updt_applctx =
      reqinfo->updt_applctx
     WHERE (dac.child_table=requestin->list_0[ri_ndx].child_table)
      AND (dac.child_column=requestin->list_0[ri_ndx].child_column)
      AND (dac.child_where=requestin->list_0[ri_ndx].child_where)
      AND (dac.parent_table=requestin->list_0[ri_ndx].parent_table)
      AND (dac.parent_column=requestin->list_0[ri_ndx].parent_column)
     WITH nocounter
    ;end update
    IF (error(readme_data->message,0) != 0)
     ROLLBACK
     SET readme_data->status = "F"
     GO TO exit_program
    ENDIF
    IF (curqual=0)
     INSERT  FROM dm_arc_constraints dac
      SET dac.dm_arc_constraints_id = seq(dm_clinical_seq,nextval), dac.exclude_ind = cnvtint(
        requestin->list_0[ri_ndx].exclude_ind), dac.active_ind = cnvtint(requestin->list_0[ri_ndx].
        active_ind),
       dac.archive_entity_name = requestin->list_0[ri_ndx].archive_entity_name, dac.child_table =
       requestin->list_0[ri_ndx].child_table, dac.child_column = requestin->list_0[ri_ndx].
       child_column,
       dac.child_where = requestin->list_0[ri_ndx].child_where, dac.parent_table = requestin->list_0[
       ri_ndx].parent_table, dac.parent_column = requestin->list_0[ri_ndx].parent_column,
       dac.constraint_name = trim(requestin->list_0[ri_ndx].constraint_name,3), dac.updt_dt_tm =
       cnvtdatetime(curdate,curtime3), dac.updt_id = reqinfo->updt_id,
       dac.updt_cnt = 0, dac.updt_task = reqinfo->updt_task, dac.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (error(readme_data->message,0) != 0)
      ROLLBACK
      SET readme_data->status = "F"
      GO TO exit_program
     ENDIF
    ENDIF
  ENDFOR
  COMMIT
  SET danc_request->batch_selection = "PERSON"
  SET danc_request->cons_prefix = "XARC"
  SET danc_request->all_tab_ind = 1
  EXECUTE dm2_arc_new_constraints  WITH replace("REQUEST","DANC_REQUEST"), replace("REPLY",
   "DANC_REPLY")
  IF ((danc_reply->status_data.status="F"))
   SET readme_data->status = "F"
   SET readme_data->message = danc_reply->status_data.subeventstatus.targetobjectvalue
   GO TO exit_program
  ENDIF
 ENDIF
#exit_program
END GO
