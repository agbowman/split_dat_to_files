CREATE PROGRAM bed_get_def_sched_temp_list:dba
 FREE SET reply
 RECORD reply(
   1 templates[*]
     2 br_sch_template_id = f8
     2 template_name = vc
     2 updt_dt_tm = dq8
     2 new_format_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET data_partition_ind = 0
 RANGE OF b IS br_sch_template
 SET data_partition_ind = validate(b.logical_domain_id)
 FREE RANGE b
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
 DECLARE bparse = vc
 SET bparse = "b.template_status_flag = 0"
 IF (data_partition_ind=1)
  SET bparse = build2(bparse," and b.logical_domain_id = ",acm_get_curr_logical_domain_rep->
   logical_domain_id)
 ENDIF
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM br_sch_template b
  WHERE parser(bparse)
  DETAIL
   tcnt = (tcnt+ 1), stat = alterlist(reply->templates,tcnt), reply->templates[tcnt].
   br_sch_template_id = b.br_sch_template_id,
   reply->templates[tcnt].template_name = b.template_name, reply->templates[tcnt].updt_dt_tm = b
   .updt_dt_tm, reply->templates[tcnt].new_format_ind = b.new_format_ind
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
