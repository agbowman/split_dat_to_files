CREATE PROGRAM bed_rpt_driver_asynch:dba
 DECLARE rowidentifier = vc WITH protect, noconstant("")
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
      2 yes_no_ind = i2
  )
 ENDIF
 RECORD reply(
   1 collist[*]
     2 header_text = vc
     2 data_type = i2
     2 hide_ind = i2
   1 rowlist[*]
     2 celllist[*]
       3 date_value = dq8
       3 nbr_value = i4
       3 double_value = f8
       3 string_value = vc
       3 display_flag = i2
   1 high_volume_flag = i2
   1 output_filename = vc
   1 run_status_flag = i2
   1 statlist[*]
     2 statistic_meaning = vc
     2 status_flag = i2
     2 qualifying_items = i4
     2 total_items = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 IF ( NOT (validate(temprequest,0)))
  RECORD temprequest(
    1 reportname = vc
    1 completedind = i2
    1 rowidentifier = vc
  )
 ENDIF
 IF ( NOT (validate(tempreply,0)))
  RECORD tempreply(
    1 nodename = vc
    1 rowidentifier = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET temprequest->reportname = request->output_filename
 SET temprequest->completedind = 0
 SET temprequest->rowidentifier = ""
 EXECUTE bed_ens_rpt_node_info  WITH replace("REQUEST",temprequest), replace("REPLY",tempreply)
 CALL echorecord(temprequest)
 CALL echorecord(tempreply)
 SET rowidentifier = tempreply->rowidentifier
 DECLARE program_name = vc
 IF (trim(request->program_name) > " ")
  SET program_name = cnvtupper(trim(request->program_name))
  EXECUTE value(program_name)
 ENDIF
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
  GO TO exit_program
 ENDIF
 IF ((((reply->run_status_flag < 0)) OR ((reply->run_status_flag > 3))) )
  SET reply->run_status_flag = 0
 ENDIF
 SET hold_br_report_id = 0.0
 SELECT INTO "nl:"
  FROM br_report br
  PLAN (br
   WHERE (br.program_name=request->program_name))
  DETAIL
   hold_br_report_id = br.br_report_id
  WITH nocounter
 ;end select
 SET new_hist_id = 0.0
 SELECT INTO "nl:"
  z = seq(bedrock_seq,nextval)
  FROM dual
  DETAIL
   new_hist_id = cnvtreal(z)
  WITH format, nocounter
 ;end select
 IF (hold_br_report_id > 0)
  UPDATE  FROM br_report br
   SET br.last_run_prsnl_id = reqinfo->updt_id, br.last_run_dt_tm = cnvtdatetime(curdate,curtime), br
    .last_run_status_flag = reply->run_status_flag,
    br.br_report_history_id = new_hist_id, br.updt_id = reqinfo->updt_id, br.updt_dt_tm =
    cnvtdatetime(curdate,curtime),
    br.updt_task = reqinfo->updt_task, br.updt_applctx = reqinfo->updt_applctx, br.updt_cnt = (br
    .updt_cnt+ 1)
   WHERE br.br_report_id=hold_br_report_id
   WITH nocounter
  ;end update
  INSERT  FROM br_report_history brh
   SET brh.br_report_history_id = new_hist_id, brh.br_report_id = hold_br_report_id, brh.run_prsnl_id
     = reqinfo->updt_id,
    brh.run_dt_tm = cnvtdatetime(curdate,curtime), brh.run_status_flag = reply->run_status_flag, brh
    .updt_id = reqinfo->updt_id,
    brh.updt_dt_tm = cnvtdatetime(curdate,curtime), brh.updt_task = reqinfo->updt_task, brh
    .updt_applctx = reqinfo->updt_applctx,
    brh.updt_cnt = 0
   WITH nocounter
  ;end insert
  SET statx = size(reply->statlist,5)
  IF (statx > 0)
   FOR (sx = 1 TO statx)
     INSERT  FROM br_report_statistics brs
      SET brs.br_report_statistics_id = seq(bedrock_seq,nextval), brs.br_report_history_id =
       new_hist_id, brs.statistic_meaning = reply->statlist[sx].statistic_meaning,
       brs.status_flag = reply->statlist[sx].status_flag, brs.qualifying_items = reply->statlist[sx].
       qualifying_items, brs.total_items = reply->statlist[sx].total_items,
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
 CALL echorecord(reply)
 IF ((reply->status_data.status != "F")
  AND (reply->status_data.status != "Z"))
  SET reply->status_data.status = "S"
  SET temprequest->reportname = request->output_filename
  SET temprequest->completedind = 1
  SET temprequest->rowidentifier = rowidentifier
  EXECUTE bed_ens_rpt_node_info  WITH replace("REQUEST",temprequest), replace("REPLY",tempreply)
  CALL echorecord(temprequest)
  CALL echorecord(tempreply)
 ENDIF
END GO
