CREATE PROGRAM bed_rpt_hist:dba
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
 SET reply->status_data.status = "F"
 RANGE OF c IS code_value_set
 FREE RANGE c
 IF (validate(c.br_client_id))
  GO TO exit_program
 ENDIF
 IF ((((request->run_status_flag < 0)) OR ((request->run_status_flag > 3))) )
  SET request->run_status_flag = 0
 ENDIF
 SET br_report_id = 0.0
 SELECT INTO "nl:"
  FROM br_report br
  PLAN (br
   WHERE (br.program_name=request->program_name))
  DETAIL
   br_report_id = br.br_report_id
  WITH nocounter
 ;end select
 IF (br_report_id > 0)
  SET new_hist_id = 0.0
  SELECT INTO "nl:"
   z = seq(bedrock_seq,nextval)
   FROM dual
   DETAIL
    new_hist_id = cnvtreal(z)
   WITH format, nocounter
  ;end select
  UPDATE  FROM br_report br
   SET br.last_run_prsnl_id = reqinfo->updt_id, br.last_run_dt_tm = cnvtdatetime(curdate,curtime), br
    .last_run_status_flag = request->run_status_flag,
    br.br_report_history_id = new_hist_id, br.updt_id = reqinfo->updt_id, br.updt_dt_tm =
    cnvtdatetime(curdate,curtime),
    br.updt_task = reqinfo->updt_task, br.updt_applctx = reqinfo->updt_applctx, br.updt_cnt = (br
    .updt_cnt+ 1)
   WHERE br.br_report_id=br_report_id
   WITH nocounter
  ;end update
  INSERT  FROM br_report_history brh
   SET brh.br_report_history_id = new_hist_id, brh.br_report_id = br_report_id, brh.run_prsnl_id =
    reqinfo->updt_id,
    brh.run_dt_tm = cnvtdatetime(curdate,curtime), brh.run_status_flag = request->run_status_flag,
    brh.updt_id = reqinfo->updt_id,
    brh.updt_dt_tm = cnvtdatetime(curdate,curtime), brh.updt_task = reqinfo->updt_task, brh
    .updt_applctx = reqinfo->updt_applctx,
    brh.updt_cnt = 0
   WITH nocounter
  ;end insert
  SET stat_cnt = size(request->statlist,5)
  IF (stat_cnt > 0)
   FOR (sc = 1 TO stat_cnt)
     INSERT  FROM br_report_statistics brs
      SET brs.br_report_statistics_id = seq(bedrock_seq,nextval), brs.br_report_history_id =
       new_hist_id, brs.statistic_meaning = request->statlist[sc].statistic_meaning,
       brs.status_flag = request->statlist[sc].status_flag, brs.qualifying_items = request->statlist[
       sc].qualifying_items, brs.total_items = request->statlist[sc].total_items,
       brs.updt_id = reqinfo->updt_id, brs.updt_dt_tm = cnvtdatetime(curdate,curtime), brs.updt_task
        = reqinfo->updt_task,
       brs.updt_applctx = reqinfo->updt_applctx, brs.updt_cnt = 0
      WITH nocounter
     ;end insert
   ENDFOR
  ENDIF
  SET reqinfo->commit_ind = 1
 ENDIF
#exit_program
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
