CREATE PROGRAM bed_get_health_plan_wo_org:dba
 FREE SET reply
 RECORD reply(
   1 health_plan_wo_org_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->health_plan_wo_org_ind = 0
 SET auth_cd = 0
 SET auth_cd = uar_get_code_by("MEANING",8,"AUTH")
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
    SET acm_get_acc_logical_domains_req->concept = 4
    EXECUTE acm_get_acc_logical_domains  WITH replace("REQUEST",acm_get_acc_logical_domains_req),
    replace("REPLY",acm_get_acc_logical_domains_rep)
   ENDIF
  ENDIF
 ENDIF
 DECLARE hp_parse = vc
 SET hp_parse = "h.active_ind = 1"
 IF (data_partition_ind=1)
  IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
   SET hp_parse = concat(hp_parse," and h.logical_domain_id in (")
   FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
     IF ((d=acm_get_acc_logical_domains_rep->logical_domains_cnt))
      SET hp_parse = build(hp_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,")")
     ELSE
      SET hp_parse = build(hp_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,",")
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 IF (data_partition_ind=1)
  IF (validate(ld_concept_person)=0)
   DECLARE ld_concept_person = i2 WITH public, constant(1)
  ENDIF
  IF (validate(ld_concept_prsnl)=0)
   DECLARE ld_concept_prsnl = i2 WITH public, constant(2)
  ENDIF
  IF (validate(ld_concept_organization)=0)
   DECLARE ld_concept_organization = i2 WITH public, constant(3)
  ENDIF
  IF (validate(ld_concept_healthplan)=0)
   DECLARE ld_concept_healthplan = i2 WITH public, constant(4)
  ENDIF
  IF (validate(ld_concept_alias_pool)=0)
   DECLARE ld_concept_alias_pool = i2 WITH public, constant(5)
  ENDIF
  IF (validate(ld_concept_minvalue)=0)
   DECLARE ld_concept_minvalue = i2 WITH public, constant(1)
  ENDIF
  IF (validate(ld_concept_maxvalue)=0)
   DECLARE ld_concept_maxvalue = i2 WITH public, constant(5)
  ENDIF
  RECORD acm_get_curr_logical_domain_req(
    1 concept = i4
  )
  RECORD acm_get_curr_logical_domain_rep(
    1 logical_domain_id = f8
    1 status_block
      2 status_ind = i2
      2 error_code = i4
  )
  SET acm_get_curr_logical_domain_req->concept = ld_concept_prsnl
  EXECUTE acm_get_curr_logical_domain  WITH replace("REQUEST",acm_get_curr_logical_domain_req),
  replace("REPLY",acm_get_curr_logical_domain_rep)
 ENDIF
 DECLARE oparse = vc
 SET oparse = "o.active_ind = 1"
 IF (data_partition_ind=1)
  SET oparse = build2(oparse," and o.logical_domain_id = ",acm_get_curr_logical_domain_rep->
   logical_domain_id)
 ENDIF
 SELECT INTO "NL:"
  FROM org_plan_reltn opr,
   health_plan h
  PLAN (opr
   WHERE opr.health_plan_id > 0
    AND opr.organization_id=0
    AND opr.active_ind=1
    AND opr.data_status_cd=auth_cd)
   JOIN (h
   WHERE h.health_plan_id=opr.health_plan_id
    AND parser(hp_parse)
    AND h.data_status_cd=auth_cd)
  DETAIL
   reply->health_plan_wo_org_ind = 1
  WITH nocounter, maxrec = 1
 ;end select
 IF ((reply->health_plan_wo_org_ind=0))
  SELECT INTO "NL:"
   FROM health_plan h
   PLAN (h
    WHERE parser(hp_parse)
     AND h.data_status_cd=auth_cd
     AND  NOT ( EXISTS (
    (SELECT
     opr.organization_id
     FROM org_plan_reltn opr,
      org_type_reltn otr,
      organization o
     WHERE opr.health_plan_id=h.health_plan_id
      AND ((opr.active_ind+ 0)=1)
      AND opr.data_status_cd=auth_cd
      AND o.organization_id=opr.organization_id
      AND parser(oparse)
      AND o.data_status_cd=auth_cd
      AND ((opr.organization_id+ 0)=otr.organization_id)
      AND ((otr.org_type_cd+ 0)=request->organization_type_code_value)))))
   DETAIL
    reply->health_plan_wo_org_ind = 1
   WITH nocounter, maxrec = 1
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
