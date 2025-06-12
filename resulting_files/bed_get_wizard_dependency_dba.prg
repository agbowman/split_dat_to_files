CREATE PROGRAM bed_get_wizard_dependency:dba
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
     02 statlist[*]
       03 statistic_meaning = vc
       03 status_flag = i2
       03 qualifying_items = i4
       03 total_items = i4
     02 br_report_history_id = f8
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
 IF (shared_domain_ind=1)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM br_step_dep bsd,
   br_report br
  PLAN (bsd
   WHERE (bsd.step_mean=request->step_mean)
    AND bsd.dependency_type_flag=2)
   JOIN (br
   WHERE br.program_name=bsd.xray_name)
  HEAD REPORT
   rcnt = 0
  DETAIL
   rcnt = (rcnt+ 1), stat = alterlist(reply->rlist,rcnt), reply->rlist[rcnt].report_name = br
   .report_name,
   reply->rlist[rcnt].program_name = br.program_name, reply->rlist[rcnt].br_report_id = br
   .br_report_id, reply->rlist[rcnt].br_report_history_id = br.br_report_history_id,
   reply->rlist[rcnt].sequence = br.sequence, reply->rlist[rcnt].step_cat_mean = br.step_cat_mean,
   reply->rlist[rcnt].output_type_flag = 0,
   reply->rlist[rcnt].last_run_prsnl_id = br.last_run_prsnl_id, reply->rlist[rcnt].last_run_dt_tm =
   br.last_run_dt_tm, reply->rlist[rcnt].last_run_status_flag = br.last_run_status_flag
  WITH nocounter
 ;end select
 IF (rcnt > 0
  AND shared_domain_ind=0)
  SET data_partition_ind = 0
  SET field_found = 0
  RANGE OF c IS code_value_set
  SET field_found = validate(c.br_client_id)
  FREE RANGE c
  IF (field_found=0)
   SET prg_exists_ind = 0
   SET prg_exists_ind = checkprg("ACM_GET_ACC_LOGICAL_DOMAINS")
   IF (prg_exists_ind > 0)
    SET field_found = 0
    RANGE OF p IS prsnl
    SET field_found = validate(p.logical_domain_id)
    FREE RANGE p
    IF (field_found=1)
     SET data_partition_ind = 1
     FREE SET acm_get_acc_logical_domains_req
     RECORD acm_get_acc_logical_domains_req(
       1 write_mode_ind = i2
       1 concept = i4
     )
     FREE SET acm_get_acc_logical_domains_rep
     RECORD acm_get_acc_logical_domains_rep(
       1 logical_domain_grp_id = f8
       1 logical_domains_cnt = i4
       1 logical_domains[*]
         2 logical_domain_id = f8
       1 status_block
         2 status_ind = i2
         2 error_code = i4
     )
     SET acm_get_acc_logical_domains_req->write_mode_ind = 0
     SET acm_get_acc_logical_domains_req->concept = 2
     EXECUTE acm_get_acc_logical_domains  WITH replace("REQUEST",acm_get_acc_logical_domains_req),
     replace("REPLY",acm_get_acc_logical_domains_rep)
    ENDIF
   ENDIF
  ENDIF
  DECLARE prsnl_parse = vc
  SET prsnl_parse = "p.person_id = reply->rlist[d.seq].last_run_prsnl_id"
  IF (data_partition_ind=1)
   IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
    SET prsnl_parse = concat(prsnl_parse," and p.logical_domain_id in (")
    FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
      IF ((d=acm_get_acc_logical_domains_rep->logical_domains_cnt))
       SET prsnl_parse = build(prsnl_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
        logical_domain_id,")")
      ELSE
       SET prsnl_parse = build(prsnl_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
        logical_domain_id,",")
      ENDIF
    ENDFOR
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = rcnt),
    prsnl p
   PLAN (d
    WHERE (reply->rlist[d.seq].last_run_prsnl_id > 0))
    JOIN (p
    WHERE parser(prsnl_parse))
   DETAIL
    reply->rlist[d.seq].last_run_username = p.username
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = rcnt),
    br_report_statistics bls
   PLAN (d
    WHERE (reply->rlist[d.seq].br_report_history_id > 0))
    JOIN (bls
    WHERE (bls.br_report_history_id=reply->rlist[d.seq].br_report_history_id))
   HEAD REPORT
    stcnt = 0
   DETAIL
    stcnt = (stcnt+ 1), stat = alterlist(reply->rlist[d.seq].statlist,stcnt), reply->rlist[d.seq].
    statlist[stcnt].statistic_meaning = bls.statistic_meaning,
    reply->rlist[d.seq].statlist[stcnt].status_flag = bls.status_flag, reply->rlist[d.seq].statlist[
    stcnt].qualifying_items = bls.qualifying_items, reply->rlist[d.seq].statlist[stcnt].total_items
     = bls.total_items
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = rcnt),
    br_report_params brp
   PLAN (d)
    JOIN (brp
    WHERE (brp.br_report_id=reply->rlist[d.seq].br_report_id))
   ORDER BY d.seq, brp.sequence
   HEAD REPORT
    pcnt = 0
   DETAIL
    reply->rlist[d.seq].paramlist[pcnt].param_type_mean = brp.param_type_mean, reply->rlist[d.seq].
    paramlist[pcnt].code_set = brp.code_set, reply->rlist[d.seq].paramlist[pcnt].multiple_value_ind
     = brp.multiple_value_ind,
    reply->rlist[d.seq].paramlist[pcnt].required_ind = brp.required_ind
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 CALL echorecord(reply)
END GO
