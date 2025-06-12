CREATE PROGRAM bed_ens_psn_prsnl_notify:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET prsnl_data
 RECORD prsnl_data(
   1 numqual = i4
   1 qual[*]
     2 person_id = f8
     2 sign_id = f8
     2 review_id = f8
     2 perform_id = f8
 )
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
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 DECLARE error_msg = vc
 SET prsnl_notify_id = 0.0
 SET active_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=48
    AND c.cdf_meaning="ACTIVE")
  DETAIL
   active_cd = c.code_value
  WITH nocounter
 ;end select
 SET inactive_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=48
    AND c.cdf_meaning="INACTIVE")
  DETAIL
   inactive_cd = c.code_value
  WITH nocounter
 ;end select
 SET sign_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=6027
    AND c.cdf_meaning="SIGN RESULT")
  DETAIL
   sign_cd = c.code_value
  WITH nocounter
 ;end select
 SET review_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=6027
    AND c.cdf_meaning="REVIEW RESUL")
  DETAIL
   review_cd = c.code_value
  WITH nocounter
 ;end select
 SET perform_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=6027
    AND c.cdf_meaning="PERF RESULT")
  DETAIL
   perform_cd = c.code_value
  WITH nocounter
 ;end select
 SET numrows = size(request->positions,5)
 SET org_cnt = size(request->orgs,5)
 IF (numrows=0)
  SET error_msg = "No rows to process"
  GO TO exit_script
 ENDIF
 DECLARE prsnl_parse = vc
 SET prsnl_parse = "p.position_cd = request->positions[d.seq].code_value"
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
 IF (org_cnt=0)
  SET pcnt = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = numrows),
    prsnl p,
    prsnl_notify pn
   PLAN (d)
    JOIN (p
    WHERE parser(prsnl_parse))
    JOIN (pn
    WHERE pn.person_id=outerjoin(p.person_id))
   ORDER BY p.person_id
   HEAD REPORT
    pcnt = 0
   HEAD p.person_id
    pcnt = (pcnt+ 1), stat = alterlist(prsnl_data->qual,pcnt), prsnl_data->qual[pcnt].person_id = p
    .person_id,
    prsnl_data->qual[pcnt].sign_id = 0, prsnl_data->qual[pcnt].review_id = 0, prsnl_data->qual[pcnt].
    perform_id = 0
   DETAIL
    IF (pn.prsnl_notify_id > 0)
     IF (pn.task_activity_cd=sign_cd)
      IF ((pn.notify_flag=request->sign_and_review_ind))
       prsnl_data->qual[pcnt].sign_id = - (1)
      ELSE
       prsnl_data->qual[pcnt].sign_id = pn.prsnl_notify_id
      ENDIF
     ELSEIF (pn.task_activity_cd=review_cd)
      IF ((pn.notify_flag=request->sign_and_review_ind))
       prsnl_data->qual[pcnt].review_id = - (1)
      ELSE
       prsnl_data->qual[pcnt].review_id = pn.prsnl_notify_id
      ENDIF
     ELSEIF (pn.task_activity_cd=perform_cd)
      IF ((pn.notify_flag=request->perform_result_ind))
       prsnl_data->qual[pcnt].perform_id = - (1)
      ELSE
       prsnl_data->qual[pcnt].perform_id = pn.prsnl_notify_id
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SET pcnt = 0
  FOR (i = 1 TO org_cnt)
    SELECT DISTINCT INTO "nl:"
     p.person_id, pn.task_activity_cd
     FROM (dummyt d  WITH seq = numrows),
      prsnl p,
      prsnl_notify pn,
      prsnl_org_reltn por
     PLAN (d)
      JOIN (p
      WHERE parser(prsnl_parse))
      JOIN (por
      WHERE p.person_id=por.person_id
       AND por.active_ind=1
       AND (por.organization_id=request->orgs[i].id))
      JOIN (pn
      WHERE pn.person_id=outerjoin(p.person_id))
     ORDER BY p.person_id
     HEAD REPORT
      pcnt = 0
     HEAD p.person_id
      pcnt = (pcnt+ 1), stat = alterlist(prsnl_data->qual,pcnt), prsnl_data->qual[pcnt].person_id = p
      .person_id,
      prsnl_data->qual[pcnt].sign_id = 0, prsnl_data->qual[pcnt].review_id = 0, prsnl_data->qual[pcnt
      ].perform_id = 0
     DETAIL
      IF (pn.prsnl_notify_id > 0)
       IF (pn.task_activity_cd=sign_cd)
        IF ((pn.notify_flag=request->sign_and_review_ind))
         prsnl_data->qual[pcnt].sign_id = - (1)
        ELSE
         prsnl_data->qual[pcnt].sign_id = pn.prsnl_notify_id
        ENDIF
       ELSEIF (pn.task_activity_cd=review_cd)
        IF ((pn.notify_flag=request->sign_and_review_ind))
         prsnl_data->qual[pcnt].review_id = - (1)
        ELSE
         prsnl_data->qual[pcnt].review_id = pn.prsnl_notify_id
        ENDIF
       ELSEIF (pn.task_activity_cd=perform_cd)
        IF ((pn.notify_flag=request->perform_result_ind))
         prsnl_data->qual[pcnt].perform_id = - (1)
        ELSE
         prsnl_data->qual[pcnt].perform_id = pn.prsnl_notify_id
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
  ENDFOR
 ENDIF
 IF (pcnt=0)
  GO TO exit_script
 ENDIF
 UPDATE  FROM prsnl_notify pn,
   (dummyt d  WITH seq = pcnt)
  SET pn.seq = 1, pn.notify_flag = request->sign_and_review_ind, pn.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   pn.updt_id = reqinfo->updt_id, pn.updt_task = reqinfo->updt_task, pn.updt_applctx = reqinfo->
   updt_applctx,
   pn.updt_cnt = (pn.updt_cnt+ 1)
  PLAN (d
   WHERE (prsnl_data->qual[d.seq].sign_id > 0))
   JOIN (pn
   WHERE (pn.prsnl_notify_id=prsnl_data->qual[d.seq].sign_id))
  WITH nocounter
 ;end update
 INSERT  FROM prsnl_notify pn,
   (dummyt d  WITH seq = pcnt)
  SET pn.seq = 1, pn.prsnl_notify_id = seq(reference_seq,nextval), pn.person_id = prsnl_data->qual[d
   .seq].person_id,
   pn.task_activity_cd = sign_cd, pn.notify_flag = request->sign_and_review_ind, pn.active_ind = 1,
   pn.active_status_cd = active_cd, pn.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pn
   .active_status_prsnl_id = reqinfo->updt_id,
   pn.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), pn.end_effective_dt_tm = cnvtdatetime(
    "31-dec-2100 00:00:00"), pn.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   pn.updt_id = reqinfo->updt_id, pn.updt_task = reqinfo->updt_task, pn.updt_applctx = reqinfo->
   updt_applctx,
   pn.updt_cnt = 0
  PLAN (d
   WHERE (prsnl_data->qual[d.seq].sign_id=0))
   JOIN (pn)
  WITH nocounter
 ;end insert
 UPDATE  FROM prsnl_notify pn,
   (dummyt d  WITH seq = pcnt)
  SET pn.seq = 1, pn.notify_flag = request->sign_and_review_ind, pn.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   pn.updt_id = reqinfo->updt_id, pn.updt_task = reqinfo->updt_task, pn.updt_applctx = reqinfo->
   updt_applctx,
   pn.updt_cnt = (pn.updt_cnt+ 1)
  PLAN (d
   WHERE (prsnl_data->qual[d.seq].review_id > 0))
   JOIN (pn
   WHERE (pn.prsnl_notify_id=prsnl_data->qual[d.seq].review_id))
  WITH nocounter
 ;end update
 INSERT  FROM prsnl_notify pn,
   (dummyt d  WITH seq = pcnt)
  SET pn.seq = 1, pn.prsnl_notify_id = seq(reference_seq,nextval), pn.person_id = prsnl_data->qual[d
   .seq].person_id,
   pn.task_activity_cd = review_cd, pn.notify_flag = request->sign_and_review_ind, pn.active_ind = 1,
   pn.active_status_cd = active_cd, pn.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pn
   .active_status_prsnl_id = reqinfo->updt_id,
   pn.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), pn.end_effective_dt_tm = cnvtdatetime(
    "31-dec-2100 00:00:00"), pn.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   pn.updt_id = reqinfo->updt_id, pn.updt_task = reqinfo->updt_task, pn.updt_applctx = reqinfo->
   updt_applctx,
   pn.updt_cnt = 0
  PLAN (d
   WHERE (prsnl_data->qual[d.seq].review_id=0))
   JOIN (pn)
  WITH nocounter
 ;end insert
 UPDATE  FROM prsnl_notify pn,
   (dummyt d  WITH seq = pcnt)
  SET pn.seq = 1, pn.notify_flag = request->perform_result_ind, pn.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   pn.updt_id = reqinfo->updt_id, pn.updt_task = reqinfo->updt_task, pn.updt_applctx = reqinfo->
   updt_applctx,
   pn.updt_cnt = (pn.updt_cnt+ 1)
  PLAN (d
   WHERE (prsnl_data->qual[d.seq].perform_id > 0))
   JOIN (pn
   WHERE (pn.prsnl_notify_id=prsnl_data->qual[d.seq].perform_id))
  WITH nocounter
 ;end update
 INSERT  FROM prsnl_notify pn,
   (dummyt d  WITH seq = pcnt)
  SET pn.seq = 1, pn.prsnl_notify_id = seq(reference_seq,nextval), pn.person_id = prsnl_data->qual[d
   .seq].person_id,
   pn.task_activity_cd = perform_cd, pn.notify_flag = request->perform_result_ind, pn.active_ind = 1,
   pn.active_status_cd = active_cd, pn.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pn
   .active_status_prsnl_id = reqinfo->updt_id,
   pn.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), pn.end_effective_dt_tm = cnvtdatetime(
    "31-dec-2100 00:00:00"), pn.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   pn.updt_id = reqinfo->updt_id, pn.updt_task = reqinfo->updt_task, pn.updt_applctx = reqinfo->
   updt_applctx,
   pn.updt_cnt = 0
  PLAN (d
   WHERE (prsnl_data->qual[d.seq].perform_id=0))
   JOIN (pn)
  WITH nocounter
 ;end insert
 SET error_flag = "N"
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(prsnl_data)
 CALL echorecord(reply)
END GO
