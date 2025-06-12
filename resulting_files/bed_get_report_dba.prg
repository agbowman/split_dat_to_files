CREATE PROGRAM bed_get_report:dba
 FREE SET reply
 RECORD reply(
   01 rlist[*]
     02 br_report_id = f8
     02 report_name = vc
     02 program_name = vc
     02 step_cat_mean = vc
     02 step_cat_disp = vc
     02 sequence = i4
     02 output_type_flag = i2
     02 last_run_prsnl_id = f8
     02 last_run_username = vc
     02 last_run_dt_tm = dq8
     02 last_run_status_flag = i4
     02 paramlist[*]
       03 param_type_mean = vc
       03 code_set = i4
       03 multiple_value_ind = i2
       03 required_ind = i2
       03 caption = vc
     02 statlist[*]
       03 statistic_meaning = vc
       03 status_flag = i2
       03 qualifying_items = i4
       03 total_items = i4
     02 br_report_history_id = f8
     02 solution_mean = vc
     02 solution_disp = vc
     02 name_full_formatted = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 SET rcnt = 0
 SET shared_domain_ind = 0
 RANGE OF c IS code_value_set
 SET fnd = validate(c.br_client_id)
 FREE RANGE c
 IF (fnd=1)
  SET shared_domain_ind = 1
 ELSE
  SET shared_domain_ind = 0
 ENDIF
 DECLARE br_parse = vc
 SET br_parse =
 "br.br_report_id > 0 and br.report_type_flag = request->report_type_flag and br.sequence >= 0"
 IF (validate(request->return_inactive_reports))
  IF ((request->return_inactive_reports=1))
   SET br_parse = "br.br_report_id > 0 and br.report_type_flag = request->report_type_flag"
  ENDIF
 ENDIF
 IF (shared_domain_ind=1)
  SELECT INTO "nl:"
   group_sort =
   IF (br.step_cat_mean="CORE"
    AND  NOT (br.solution_mean IN ("COREL", "COREM", "COREIC", "COREHS", "COREH")))
    IF (br.solution_disp > " ") concat("1",cnvtupper(br.solution_disp))
    ELSE concat("1",cnvtupper(bnv.br_value))
    ENDIF
   ELSE
    IF (br.solution_disp > " ") concat("2",cnvtupper(br.solution_disp))
    ELSE concat("2",cnvtupper(bnv.br_value))
    ENDIF
   ENDIF
   FROM br_report br,
    br_name_value bnv
   PLAN (br
    WHERE parser(br_parse))
    JOIN (bnv
    WHERE bnv.br_nv_key1="STEP_CAT_MEAN"
     AND bnv.br_name=br.step_cat_mean)
   ORDER BY group_sort, br.sequence, br.br_report_id
   HEAD REPORT
    rcnt = 0
   HEAD br.br_report_id
    rcnt = (rcnt+ 1), stat = alterlist(reply->rlist,rcnt), reply->rlist[rcnt].report_name = br
    .report_name,
    reply->rlist[rcnt].program_name = br.program_name, reply->rlist[rcnt].br_report_id = br
    .br_report_id, reply->rlist[rcnt].sequence = br.sequence,
    reply->rlist[rcnt].step_cat_mean = br.step_cat_mean, reply->rlist[rcnt].output_type_flag = 0,
    reply->rlist[rcnt].step_cat_disp = bnv.br_value
    IF (br.solution_mean > " ")
     reply->rlist[rcnt].solution_mean = br.solution_mean
    ELSE
     reply->rlist[rcnt].solution_mean = br.step_cat_mean
    ENDIF
    IF (br.solution_disp > " ")
     reply->rlist[rcnt].solution_disp = br.solution_disp
    ELSE
     reply->rlist[rcnt].solution_disp = bnv.br_value
    ENDIF
   WITH nocounter, skipbedrock = 1
  ;end select
 ELSE
  IF ((request->return_inactive_solutions=1))
   SELECT INTO "nl:"
    group_sort =
    IF (br.step_cat_mean="CORE"
     AND  NOT (br.solution_mean IN ("COREL", "COREM", "COREIC", "COREHS", "COREH")))
     IF (br.solution_disp > " ") concat("1",cnvtupper(br.solution_disp))
     ELSE concat("1",cnvtupper(bnv.br_value))
     ENDIF
    ELSE
     IF (br.solution_disp > " ") concat("2",cnvtupper(br.solution_disp))
     ELSE concat("2",cnvtupper(bnv.br_value))
     ENDIF
    ENDIF
    FROM br_report br,
     br_name_value bnv,
     br_name_value bnv2
    PLAN (br
     WHERE parser(br_parse))
     JOIN (bnv
     WHERE bnv.br_nv_key1=outerjoin("STEP_CAT_MEAN")
      AND bnv.br_name=outerjoin(br.step_cat_mean))
     JOIN (bnv2
     WHERE bnv2.br_nv_key1=outerjoin("SOLUTION_STATUS")
      AND bnv2.br_value=outerjoin(bnv.br_name))
    ORDER BY group_sort, br.sequence, br.br_report_id
    HEAD REPORT
     rcnt = 0
    HEAD br.br_report_id
     rcnt = (rcnt+ 1), stat = alterlist(reply->rlist,rcnt), reply->rlist[rcnt].report_name = br
     .report_name,
     reply->rlist[rcnt].program_name = br.program_name, reply->rlist[rcnt].br_report_id = br
     .br_report_id, reply->rlist[rcnt].br_report_history_id = br.br_report_history_id,
     reply->rlist[rcnt].sequence = br.sequence, reply->rlist[rcnt].step_cat_mean = br.step_cat_mean,
     reply->rlist[rcnt].output_type_flag = 0,
     reply->rlist[rcnt].step_cat_disp = bnv.br_value, reply->rlist[rcnt].last_run_prsnl_id = br
     .last_run_prsnl_id, reply->rlist[rcnt].last_run_dt_tm = br.last_run_dt_tm,
     reply->rlist[rcnt].last_run_status_flag = br.last_run_status_flag
     IF (br.solution_mean > " ")
      reply->rlist[rcnt].solution_mean = br.solution_mean
     ELSE
      reply->rlist[rcnt].solution_mean = br.step_cat_mean
     ENDIF
     IF (br.solution_disp > " ")
      reply->rlist[rcnt].solution_disp = br.solution_disp
     ELSE
      reply->rlist[rcnt].solution_disp = bnv.br_value
     ENDIF
    WITH nocounter, skipbedrock = 1
   ;end select
  ELSE
   SELECT INTO "nl:"
    group_sort =
    IF (br.step_cat_mean="CORE"
     AND  NOT (br.solution_mean IN ("COREL", "COREM", "COREIC", "COREHS", "COREH")))
     IF (br.solution_disp > " ") concat("1",cnvtupper(br.solution_disp))
     ELSE concat("1",cnvtupper(bnv.br_value))
     ENDIF
    ELSE
     IF (br.solution_disp > " ") concat("2",cnvtupper(br.solution_disp))
     ELSE concat("2",cnvtupper(bnv.br_value))
     ENDIF
    ENDIF
    FROM br_report br,
     br_name_value bnv,
     br_name_value bnv2
    PLAN (br
     WHERE parser(br_parse))
     JOIN (bnv
     WHERE bnv.br_nv_key1="STEP_CAT_MEAN"
      AND bnv.br_name=br.step_cat_mean)
     JOIN (bnv2
     WHERE bnv2.br_nv_key1=outerjoin("SOLUTION_STATUS")
      AND bnv2.br_value=outerjoin(bnv.br_name))
    ORDER BY group_sort, br.sequence, br.br_report_id
    HEAD REPORT
     rcnt = 0
    HEAD br.br_report_id
     IF (((bnv.br_name="CORE") OR (bnv2.br_name IN ("GOING_LIVE", "LIVE_IN_PROD"))) )
      rcnt = (rcnt+ 1), stat = alterlist(reply->rlist,rcnt), reply->rlist[rcnt].report_name = br
      .report_name,
      reply->rlist[rcnt].program_name = br.program_name, reply->rlist[rcnt].br_report_id = br
      .br_report_id, reply->rlist[rcnt].br_report_history_id = br.br_report_history_id,
      reply->rlist[rcnt].sequence = br.sequence, reply->rlist[rcnt].step_cat_mean = br.step_cat_mean,
      reply->rlist[rcnt].output_type_flag = 0,
      reply->rlist[rcnt].step_cat_disp = bnv.br_value, reply->rlist[rcnt].last_run_prsnl_id = br
      .last_run_prsnl_id, reply->rlist[rcnt].last_run_dt_tm = br.last_run_dt_tm,
      reply->rlist[rcnt].last_run_status_flag = br.last_run_status_flag
      IF (br.solution_mean > " ")
       reply->rlist[rcnt].solution_mean = br.solution_mean
      ELSE
       reply->rlist[rcnt].solution_mean = br.step_cat_mean
      ENDIF
      IF (br.solution_disp > " ")
       reply->rlist[rcnt].solution_disp = br.solution_disp
      ELSE
       reply->rlist[rcnt].solution_disp = bnv.br_value
      ENDIF
     ENDIF
    WITH nocounter, skipbedrock = 1
   ;end select
  ENDIF
 ENDIF
 IF (rcnt > 0)
  IF (shared_domain_ind=0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = rcnt),
     prsnl p
    PLAN (d
     WHERE (reply->rlist[d.seq].last_run_prsnl_id > 0))
     JOIN (p
     WHERE (p.person_id=reply->rlist[d.seq].last_run_prsnl_id))
    DETAIL
     reply->rlist[d.seq].last_run_username = p.username, reply->rlist[d.seq].name_full_formatted = p
     .name_full_formatted
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = rcnt),
     br_report_statistics bls
    PLAN (d
     WHERE (reply->rlist[d.seq].br_report_history_id > 0))
     JOIN (bls
     WHERE (bls.br_report_history_id=reply->rlist[d.seq].br_report_history_id))
    HEAD d.seq
     stcnt = 0
    DETAIL
     stcnt = (stcnt+ 1), stat = alterlist(reply->rlist[d.seq].statlist,stcnt), reply->rlist[d.seq].
     statlist[stcnt].statistic_meaning = bls.statistic_meaning,
     reply->rlist[d.seq].statlist[stcnt].status_flag = bls.status_flag, reply->rlist[d.seq].statlist[
     stcnt].qualifying_items = bls.qualifying_items, reply->rlist[d.seq].statlist[stcnt].total_items
      = bls.total_items
    WITH nocounter
   ;end select
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = rcnt),
    br_report_params brp
   PLAN (d)
    JOIN (brp
    WHERE (brp.br_report_id=reply->rlist[d.seq].br_report_id))
   ORDER BY d.seq, brp.sequence
   HEAD d.seq
    pcnt = 0
   DETAIL
    pcnt = (pcnt+ 1), stat = alterlist(reply->rlist[d.seq].paramlist,pcnt), reply->rlist[d.seq].
    paramlist[pcnt].param_type_mean = brp.param_type_mean,
    reply->rlist[d.seq].paramlist[pcnt].code_set = brp.code_set, reply->rlist[d.seq].paramlist[pcnt].
    multiple_value_ind = brp.multiple_value_ind, reply->rlist[d.seq].paramlist[pcnt].required_ind =
    brp.required_ind,
    reply->rlist[d.seq].paramlist[pcnt].caption = brp.caption
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 CALL echorecord(reply)
 CALL echo(build("***** rcnt = ",rcnt))
 CALL echo(br_parse)
END GO
