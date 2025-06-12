CREATE PROGRAM bed_ens_pqrs_measure_reltn:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET temp_reltn
 RECORD temp_reltn(
   1 reltns[*]
     2 action_flag = i2
     2 eligible_provider_id = f8
     2 pqrs_measure_id = f8
     2 pilot_eligible_ind = i2
 )
 FREE SET temp_core_meas
 RECORD temp_core_meas(
   1 core_meas[*]
     2 core_meas_id = f8
 )
 FREE SET temp_insrt_core
 RECORD temp_insrt_core(
   1 providers[*]
     2 id = f8
     2 core_no_add = i2
 )
 FREE SET temp_delte_core
 RECORD temp_delte_core(
   1 providers[*]
     2 id = f8
     2 core_no_delete = i2
 )
 FREE SET insert_core
 RECORD insert_core(
   1 providers[*]
     2 id = f8
     2 core_meas_id = f8
 )
 FREE SET delete_core
 RECORD delete_core(
   1 providers[*]
     2 id = f8
     2 core_meas_id = f8
 )
 FREE SET delete_hist
 RECORD delete_hist(
   1 deleted_item[*]
     2 parent_entity_id = f8
     2 parent_entity_name = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE req_size = i4 WITH noconstant(0), protect
 DECLARE meas_size = i4 WITH noconstant(0), protect
 DECLARE core_size = i4 WITH noconstant(0), protect
 DECLARE insert_core_size = i4 WITH noconstant(0), protect
 DECLARE delete_core_size = i4 WITH noconstant(0), protect
 DECLARE reltn_cnt = i4 WITH noconstant(0), protect
 DECLARE delte_core_cnt = i4 WITH noconstant(0), protect
 DECLARE insrt_core_cnt = i4 WITH noconstant(0), protect
 DECLARE insert_flag = i4 WITH noconstant(0), protect
 DECLARE delete_flag = i4 WITH noconstant(0), protect
 DECLARE delete_hist_cnt = i4 WITH noconstant(0), protect
 DECLARE cnt = i4 WITH noconstant(0), protect
 SET req_size = size(request->providers,5)
 IF (req_size=0)
  GO TO exit_script
 ENDIF
 CALL echorecord(request)
 CALL echo(build("REQUEST_SIZE - ",req_size))
 IF ((request->pilot_eligible_ind=1))
  SELECT INTO "NL:"
   FROM br_pqrs_meas bpm
   PLAN (bpm
    WHERE bpm.pilot_core_ind=1)
   HEAD REPORT
    core_size = 0, stat = alterlist(temp_core_meas->core_meas,10)
   HEAD bpm.br_pqrs_meas_id
    core_size = (core_size+ 1)
    IF (mod(core_size,10)=0)
     stat = alterlist(temp_core_meas->core_meas,(core_size+ 10))
    ENDIF
   DETAIL
    temp_core_meas->core_meas[core_size].core_meas_id = bpm.br_pqrs_meas_id
   FOOT REPORT
    stat = alterlist(temp_core_meas->core_meas,core_size)
   WITH nocounter
  ;end select
 ENDIF
 CALL echo(build("request->pilot_eligible_ind -- ",request->pilot_eligible_ind))
 CALL echo(build("TEMP_CORE_MEASURE_SIZE -- ",core_size))
 CALL echorecord(temp_core_meas)
 SET reltn_cnt = 0
 SET delte_core_cnt = 0
 SET insrt_core_cnt = 0
 SET stat = alterlist(temp_reltn->reltns,10)
 SET stat = alterlist(temp_insrt_core->providers,req_size)
 SET stat = alterlist(temp_delte_core->providers,req_size)
 FOR (x = 1 TO req_size)
   SET insert_flag = 0
   SET delete_flag = 0
   SET meas_size = size(request->providers[x].measures,5)
   FOR (y = 1 TO meas_size)
     IF ((request->providers[x].measures[y].action_flag=1))
      SET insert_flag = 1
     ENDIF
     IF ((request->providers[x].measures[y].action_flag=3))
      SET delete_flag = 1
     ENDIF
     SET reltn_cnt = (reltn_cnt+ 1)
     IF (mod(reltn_cnt,10)=0)
      SET stat = alterlist(temp_reltn->reltns,(reltn_cnt+ 10))
     ENDIF
     SET temp_reltn->reltns[reltn_cnt].pilot_eligible_ind = request->pilot_eligible_ind
     SET temp_reltn->reltns[reltn_cnt].eligible_provider_id = request->providers[x].
     eligible_provider_id
     SET temp_reltn->reltns[reltn_cnt].pqrs_measure_id = request->providers[x].measures[y].
     pqrs_measure_id
     SET temp_reltn->reltns[reltn_cnt].action_flag = request->providers[x].measures[y].action_flag
   ENDFOR
   IF (insert_flag=1)
    SET insrt_core_cnt = (insrt_core_cnt+ 1)
    SET temp_insrt_core->providers[insrt_core_cnt].id = request->providers[x].eligible_provider_id
   ENDIF
   IF (delete_flag=1)
    SET delte_core_cnt = (delte_core_cnt+ 1)
    SET temp_delte_core->providers[delte_core_cnt].id = request->providers[x].eligible_provider_id
   ENDIF
 ENDFOR
 SET stat = alterlist(temp_reltn->reltns,reltn_cnt)
 SET tmp_insrt_core_size = insrt_core_cnt
 SET tmp_delte_core_size = delte_core_cnt
 CALL echorecord(temp_insrt_core)
 CALL echorecord(temp_delte_core)
 CALL echorecord(temp_reltn)
 IF (reltn_cnt > 0)
  SELECT INTO "nl:"
   FROM br_pqrs_meas_provider_reltn bpmpr,
    (dummyt d  WITH seq = value(reltn_cnt))
   PLAN (d
    WHERE (temp_reltn->reltns[d.seq].action_flag=3))
    JOIN (bpmpr
    WHERE (bpmpr.br_eligible_provider_id=temp_reltn->reltns[d.seq].eligible_provider_id)
     AND (bpmpr.br_pqrs_meas_id=temp_reltn->reltns[d.seq].pqrs_measure_id)
     AND (bpmpr.pilot_eligible_ind=temp_reltn->reltns[d.seq].pilot_eligible_ind))
   HEAD REPORT
    stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10)), cnt = 0
   DETAIL
    cnt = (cnt+ 1)
    IF (cnt > 10)
     cnt = 1, stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10))
    ENDIF
    delete_hist_cnt = (delete_hist_cnt+ 1), delete_hist->deleted_item[delete_hist_cnt].
    parent_entity_id = bpmpr.br_pqrs_meas_provider_reltn_id, delete_hist->deleted_item[
    delete_hist_cnt].parent_entity_name = "BR_PQRS_MEAS_PROVIDER_RELTN"
   FOOT REPORT
    stat = alterlist(delete_hist->deleted_item,delete_hist_cnt)
   WITH nocounter
  ;end select
  CALL bederrorcheck("DELETEHIST1")
  DELETE  FROM br_pqrs_meas_provider_reltn bpmpr,
    (dummyt d  WITH seq = value(reltn_cnt))
   SET bpmpr.seq = 1
   PLAN (d
    WHERE (temp_reltn->reltns[d.seq].action_flag=3))
    JOIN (bpmpr
    WHERE (bpmpr.br_eligible_provider_id=temp_reltn->reltns[d.seq].eligible_provider_id)
     AND (bpmpr.br_pqrs_meas_id=temp_reltn->reltns[d.seq].pqrs_measure_id)
     AND (bpmpr.pilot_eligible_ind=temp_reltn->reltns[d.seq].pilot_eligible_ind))
   WITH nocounter
  ;end delete
  CALL bederrorcheck("Reltn Delete Error")
  FOR (rcnt = 1 TO reltn_cnt)
   IF ((temp_reltn->reltns[rcnt].action_flag=1))
    SET newprovid = 0.0
    SELECT INTO "nl:"
     z = seq(bedrock_seq,nextval)
     FROM dual
     DETAIL
      newprovid = cnvtreal(z)
     WITH nocounter
    ;end select
    INSERT  FROM br_pqrs_meas_provider_reltn bpmpr
     SET bpmpr.br_eligible_provider_id = temp_reltn->reltns[rcnt].eligible_provider_id, bpmpr
      .br_pqrs_meas_id = temp_reltn->reltns[rcnt].pqrs_measure_id, bpmpr
      .br_pqrs_meas_provider_reltn_id = newprovid,
      bpmpr.pilot_eligible_ind = temp_reltn->reltns[rcnt].pilot_eligible_ind, bpmpr.updt_dt_tm =
      cnvtdatetime(curdate,curtime3), bpmpr.updt_id = reqinfo->updt_id,
      bpmpr.updt_task = reqinfo->updt_task, bpmpr.updt_cnt = 0, bpmpr.updt_applctx = reqinfo->
      updt_applctx,
      bpmpr.active_ind = 1, bpmpr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), bpmpr
      .end_effective_dt_tm = cnvtdatetime("31-DEC-2014 00:00:00"),
      bpmpr.orig_br_pqrs_meas_prov_r_id = newprovid
     WITH nocounter
    ;end insert
   ENDIF
   CALL bederrorcheck("Reltn Insert Error")
  ENDFOR
 ENDIF
 IF ((request->pilot_eligible_ind=1))
  CALL echo(build("tmp_insrt_core_size --- ",tmp_insrt_core_size))
  IF (tmp_insrt_core_size > 0)
   SELECT INTO "nl:"
    FROM br_pqrs_meas_provider_reltn bpmpr,
     br_pqrs_meas bpm,
     (dummyt d  WITH seq = value(tmp_insrt_core_size))
    PLAN (d)
     JOIN (bpmpr
     WHERE (bpmpr.br_eligible_provider_id=temp_insrt_core->providers[d.seq].id)
      AND bpmpr.pilot_eligible_ind=1
      AND bpmpr.active_ind=1
      AND bpmpr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (bpm
     WHERE bpm.br_pqrs_meas_id=bpmpr.br_pqrs_meas_id
      AND bpm.pilot_core_ind=1)
    ORDER BY bpmpr.br_eligible_provider_id
    HEAD bpmpr.br_eligible_provider_id
     temp_insrt_core->providers[d.seq].core_no_add = 1
    WITH nocounter
   ;end select
   CALL echorecord(temp_insrt_core)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(tmp_insrt_core_size)),
     (dummyt d1  WITH seq = value(core_size))
    PLAN (d
     WHERE (temp_insrt_core->providers[d.seq].core_no_add=0))
     JOIN (d1)
    HEAD REPORT
     insert_core_size = 0, stat = alterlist(insert_core->providers,10)
    DETAIL
     insert_core_size = (insert_core_size+ 1), insert_core->providers[insert_core_size].id =
     temp_insrt_core->providers[d.seq].id, insert_core->providers[insert_core_size].core_meas_id =
     temp_core_meas->core_meas[d1.seq].core_meas_id,
     lsize = size(insert_core->providers,5)
     IF (insert_core_size=lsize)
      stat = alterlist(insert_core->providers,(insert_core_size+ 10))
     ENDIF
    FOOT REPORT
     stat = alterlist(insert_core->providers,insert_core_size)
    WITH nocounter
   ;end select
   CALL echorecord(insert_core)
   FOR (pcnt = 1 TO insert_core_size)
     SET newpid = 0.0
     SELECT INTO "nl:"
      z = seq(bedrock_seq,nextval)
      FROM dual
      DETAIL
       newpid = cnvtreal(z)
      WITH nocounter
     ;end select
     INSERT  FROM br_pqrs_meas_provider_reltn bpmpr
      SET bpmpr.br_pqrs_meas_provider_reltn_id = newpid, bpmpr.br_eligible_provider_id = insert_core
       ->providers[pcnt].id, bpmpr.br_pqrs_meas_id = insert_core->providers[pcnt].core_meas_id,
       bpmpr.pilot_eligible_ind = 1, bpmpr.updt_dt_tm = cnvtdatetime(curdate,curtime3), bpmpr.updt_id
        = reqinfo->updt_id,
       bpmpr.updt_task = reqinfo->updt_task, bpmpr.updt_cnt = 0, bpmpr.updt_applctx = reqinfo->
       updt_applctx,
       bpmpr.active_ind = 1, bpmpr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), bpmpr
       .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"),
       bpmpr.orig_br_pqrs_meas_prov_r_id = newpid
      WITH nocounter
     ;end insert
     CALL bederrorcheck("Core Reltn Insert Error")
   ENDFOR
  ENDIF
  CALL echo(build("tmp_delte_core_size --- ",tmp_delte_core_size))
  IF (tmp_delte_core_size > 0)
   SELECT INTO "nl:"
    FROM br_pqrs_meas_provider_reltn bpmpr,
     br_pqrs_meas bpm,
     (dummyt d  WITH seq = value(tmp_delte_core_size))
    PLAN (d)
     JOIN (bpmpr
     WHERE (bpmpr.br_eligible_provider_id=temp_delte_core->providers[d.seq].id)
      AND bpmpr.pilot_eligible_ind=1)
     JOIN (bpm
     WHERE bpm.br_pqrs_meas_id=bpmpr.br_pqrs_meas_id
      AND bpm.pilot_core_ind=0)
    ORDER BY bpmpr.br_eligible_provider_id
    HEAD bpmpr.br_eligible_provider_id
     temp_delte_core->providers[d.seq].core_no_delete = 1
    WITH nocounter
   ;end select
   CALL echorecord(temp_delte_core)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(tmp_delte_core_size)),
     (dummyt d1  WITH seq = value(core_size))
    PLAN (d
     WHERE (temp_delte_core->providers[d.seq].core_no_delete=0))
     JOIN (d1)
    HEAD REPORT
     delete_core_size = 0, stat = alterlist(delete_core->providers,10)
    DETAIL
     delete_core_size = (delete_core_size+ 1), delete_core->providers[delete_core_size].id =
     temp_delte_core->providers[d.seq].id, delete_core->providers[delete_core_size].core_meas_id =
     temp_core_meas->core_meas[d1.seq].core_meas_id,
     lsize = size(delete_core->providers,5)
     IF (delete_core_size=lsize)
      stat = alterlist(delete_core->providers,(delete_core_size+ 10))
     ENDIF
    FOOT REPORT
     stat = alterlist(delete_core->providers,delete_core_size)
    WITH nocounter
   ;end select
   CALL echorecord(insert_core)
   IF (delete_core_size > 0)
    SELECT INTO "nl:"
     FROM br_pqrs_meas_provider_reltn bpmpr,
      (dummyt d  WITH seq = value(delete_core_size))
     PLAN (d)
      JOIN (bpmpr
      WHERE (bpmpr.br_eligible_provider_id=delete_core->providers[d.seq].id)
       AND (bpmpr.br_pqrs_meas_id=delete_core->providers[d.seq].core_meas_id)
       AND bpmpr.active_ind=1
       AND bpmpr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     HEAD REPORT
      stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10)), cnt = 0
     DETAIL
      cnt = (cnt+ 1)
      IF (cnt > 10)
       cnt = 1, stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10))
      ENDIF
      delete_hist_cnt = (delete_hist_cnt+ 1), delete_hist->deleted_item[delete_hist_cnt].
      parent_entity_id = bpmpr.br_pqrs_meas_provider_reltn_id, delete_hist->deleted_item[
      delete_hist_cnt].parent_entity_name = "BR_PQRS_MEAS_PROVIDER_RELTN"
     FOOT REPORT
      stat = alterlist(delete_hist->deleted_item,delete_hist_cnt)
     WITH nocounter
    ;end select
    CALL bederrorcheck("DELETEHIST2")
    DELETE  FROM br_pqrs_meas_provider_reltn bpmpr,
      (dummyt d  WITH seq = value(delete_core_size))
     SET bpmpr.seq = 1
     PLAN (d)
      JOIN (bpmpr
      WHERE (bpmpr.br_eligible_provider_id=delete_core->providers[d.seq].id)
       AND (bpmpr.br_pqrs_meas_id=delete_core->providers[d.seq].core_meas_id))
     WITH nocounter
    ;end delete
    CALL bederrorcheck("Core Reltn Delete Error")
   ENDIF
  ENDIF
 ENDIF
 IF (delete_hist_cnt > 0)
  INSERT  FROM br_delete_hist his,
    (dummyt d  WITH seq = delete_hist_cnt)
   SET his.br_delete_hist_id = seq(bedrock_seq,nextval), his.parent_entity_name = delete_hist->
    deleted_item[d.seq].parent_entity_name, his.parent_entity_id = delete_hist->deleted_item[d.seq].
    parent_entity_id,
    his.updt_dt_tm = cnvtdatetime(curdate,curtime3), his.updt_id = reqinfo->updt_id, his.updt_task =
    reqinfo->updt_task,
    his.updt_cnt = 0, his.updt_applctx = reqinfo->updt_applctx, his.create_dt_tm = cnvtdatetime(
     curdate,curtime3)
   PLAN (d)
    JOIN (his)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("DELHISTINSERTFAILED1")
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
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
