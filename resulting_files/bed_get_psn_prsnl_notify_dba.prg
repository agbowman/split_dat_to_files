CREATE PROGRAM bed_get_psn_prsnl_notify:dba
 FREE SET reply
 RECORD reply(
   1 personnel[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 sign_result_ind = i2
     2 review_result_ind = i2
     2 perform_result_ind = i2
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 DECLARE error_msg = vc
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
 SET prsnl_parse = "p.position_cd = request->position_code_value"
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
 SET org_cnt = size(request->orgs,5)
 IF (org_cnt=0)
  SET pcnt = 0
  SELECT INTO "nl:"
   FROM prsnl p,
    prsnl_notify pn
   PLAN (p
    WHERE parser(prsnl_parse))
    JOIN (pn
    WHERE pn.person_id=outerjoin(p.person_id))
   ORDER BY p.name_full_formatted, p.person_id
   HEAD REPORT
    pcnt = 0
   HEAD p.person_id
    pcnt = (pcnt+ 1), stat = alterlist(reply->personnel,pcnt), reply->personnel[pcnt].person_id = p
    .person_id,
    reply->personnel[pcnt].name_full_formatted = p.name_full_formatted, reply->personnel[pcnt].
    sign_result_ind = 0, reply->personnel[pcnt].review_result_ind = 0,
    reply->personnel[pcnt].perform_result_ind = 0
   DETAIL
    IF (pn.task_activity_cd=sign_cd
     AND pn.notify_flag=1)
     reply->personnel[pcnt].sign_result_ind = 1
    ELSEIF (pn.task_activity_cd=review_cd
     AND pn.notify_flag=1)
     reply->personnel[pcnt].review_result_ind = 1
    ELSEIF (pn.task_activity_cd=perform_cd
     AND pn.notify_flag=1)
     reply->personnel[pcnt].perform_result_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SET pcnt = 0
  FOR (i = 1 TO org_cnt)
    SELECT DISTINCT INTO "nl:"
     p.person_id, pn.task_activity_cd
     FROM prsnl p,
      prsnl_notify pn,
      prsnl_org_reltn por
     PLAN (p
      WHERE parser(prsnl_parse))
      JOIN (por
      WHERE por.person_id=p.person_id
       AND (por.organization_id=request->orgs[i].id)
       AND por.active_ind=1)
      JOIN (pn
      WHERE pn.person_id=outerjoin(p.person_id))
     ORDER BY p.name_full_formatted, p.person_id
     HEAD REPORT
      pcnt = 0
     HEAD p.person_id
      pcnt = (pcnt+ 1), stat = alterlist(reply->personnel,pcnt), reply->personnel[pcnt].person_id = p
      .person_id,
      reply->personnel[pcnt].name_full_formatted = p.name_full_formatted, reply->personnel[pcnt].
      sign_result_ind = 0, reply->personnel[pcnt].review_result_ind = 0,
      reply->personnel[pcnt].perform_result_ind = 0
     DETAIL
      IF (pn.task_activity_cd=sign_cd
       AND pn.notify_flag=1)
       reply->personnel[pcnt].sign_result_ind = 1
      ELSEIF (pn.task_activity_cd=review_cd
       AND pn.notify_flag=1)
       reply->personnel[pcnt].review_result_ind = 1
      ELSEIF (pn.task_activity_cd=perform_cd
       AND pn.notify_flag=1)
       reply->personnel[pcnt].perform_result_ind = 1
      ENDIF
     WITH nocounter
    ;end select
  ENDFOR
 ENDIF
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
 CALL echorecord(reply)
END GO
