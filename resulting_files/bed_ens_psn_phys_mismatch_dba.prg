CREATE PROGRAM bed_ens_psn_phys_mismatch:dba
 FREE SET reply
 RECORD reply(
   01 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
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
 SET prsnl_parse = "p.physician_ind != request->physician_ind"
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
 UPDATE  FROM prsnl p
  SET p.physician_ind = request->physician_ind, p.updt_dt_tm = cnvtdatetime(curdate,curtime), p
   .updt_task = reqinfo->updt_task,
   p.updt_applctx = reqinfo->updt_applctx, p.updt_id = reqinfo->updt_id, p.updt_cnt = (p.updt_cnt+ 1)
  WHERE (p.position_cd=request->position_code_value)
   AND parser(prsnl_parse)
  WITH nocounter
 ;end update
 SET updatetable = 0
 IF (validate(request->do_not_update_cat_comp))
  IF ((request->do_not_update_cat_comp=0))
   SET updatetable = 1
  ENDIF
 ELSE
  SET updatetable = 1
 ENDIF
 IF (updatetable=1)
  UPDATE  FROM br_position_cat_comp bpcc
   SET bpcc.physician_ind = request->physician_ind, bpcc.updt_dt_tm = cnvtdatetime(curdate,curtime),
    bpcc.updt_task = reqinfo->updt_task,
    bpcc.updt_applctx = reqinfo->updt_applctx, bpcc.updt_id = reqinfo->updt_id, bpcc.updt_cnt = (bpcc
    .updt_cnt+ 1)
   WHERE (bpcc.position_cd=request->position_code_value)
    AND (bpcc.physician_ind != request->physician_ind)
   WITH nocounter
  ;end update
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 CALL echorecord(reply)
END GO
