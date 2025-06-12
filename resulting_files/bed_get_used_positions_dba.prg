CREATE PROGRAM bed_get_used_positions:dba
 FREE SET reply
 RECORD reply(
   1 positions[*]
     2 code_value = f8
     2 display = vc
     2 personnel_cnt = i4
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
 SET org_cnt = size(request->orgs,5)
 IF (org_cnt=0)
  DECLARE prsnl_parse = vc
  SET prsnl_parse = "c.code_value = p.position_cd"
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
  SET pcnt = 0
  SELECT DISTINCT INTO "nl:"
   c.code_value, c.display
   FROM code_value c,
    prsnl p
   PLAN (c
    WHERE c.code_set=88)
    JOIN (p
    WHERE parser(prsnl_parse))
   DETAIL
    pcnt = (pcnt+ 1), stat = alterlist(reply->positions,pcnt), reply->positions[pcnt].code_value = c
    .code_value,
    reply->positions[pcnt].display = c.display
   WITH nocounter
  ;end select
  DECLARE prsnl_parse = vc
  SET prsnl_parse = "p.position_cd = reply->positions[i].code_value"
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
  FOR (i = 1 TO pcnt)
    SELECT INTO "NL:"
     count = count(*)
     FROM prsnl p
     PLAN (p
      WHERE parser(prsnl_parse))
     DETAIL
      reply->positions[i].personnel_cnt = count
     WITH nocounter
    ;end select
  ENDFOR
 ELSE
  SET pcnt = 0
  IF (org_cnt > 0)
   DECLARE prsnl_parse = vc
   SET prsnl_parse = "c.code_value = p.position_cd"
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
   SELECT DISTINCT INTO "nl:"
    c.code_value, c.display
    FROM code_value c,
     prsnl p,
     prsnl_org_reltn por,
     (dummyt d  WITH seq = org_cnt)
    PLAN (c
     WHERE c.code_set=88)
     JOIN (p
     WHERE parser(prsnl_parse))
     JOIN (d)
     JOIN (por
     WHERE por.person_id=p.person_id
      AND (por.organization_id=request->orgs[d.seq].id)
      AND por.active_ind=1)
    HEAD c.code_value
     pcnt = (pcnt+ 1), stat = alterlist(reply->positions,pcnt), reply->positions[pcnt].code_value = c
     .code_value,
     reply->positions[pcnt].display = c.display
    WITH nocounter
   ;end select
   DECLARE prsnl_parse = vc
   SET prsnl_parse = "p.position_cd = reply->positions[i].code_value"
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
   FOR (i = 1 TO pcnt)
     SELECT DISTINCT INTO "NL:"
      p.person_id
      FROM prsnl p,
       prsnl_org_reltn por,
       (dummyt d  WITH seq = org_cnt)
      PLAN (p
       WHERE parser(prsnl_parse))
       JOIN (d)
       JOIN (por
       WHERE p.person_id=por.person_id
        AND (por.organization_id=request->orgs[d.seq].id)
        AND por.active_ind=1)
      HEAD p.person_id
       reply->positions[i].personnel_cnt = (reply->positions[i].personnel_cnt+ 1)
      WITH nocounter
     ;end select
   ENDFOR
  ENDIF
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
