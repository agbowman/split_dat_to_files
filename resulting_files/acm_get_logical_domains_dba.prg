CREATE PROGRAM acm_get_logical_domains:dba
 IF (validate(reply)=0)
  RECORD reply(
    1 logical_domains[*]
      2 logical_domain_id = f8
      2 mnemonic = vc
    1 status_block
      2 status_ind = i2
      2 status_code = i4
  ) WITH persistscript
 ENDIF
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
 DECLARE success = i4 WITH protect, constant(1)
 DECLARE failure = i4 WITH protect, constant(0)
 DECLARE unknown_status = i4 WITH protect, constant(- (1))
 DECLARE invalid_concept = i4 WITH protect, constant(- (2))
 DECLARE invalid_state = i4 WITH protect, constant(- (3))
 DECLARE no_domains = i4 WITH protect, constant(2)
 DECLARE cur_datetime = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 SET reply->status_block.status_ind = failure
 SET reply->status_block.status_code = unknown_status
 IF ((((request->concept < ld_concept_minvalue)) OR ((request->concept > ld_concept_maxvalue))) )
  SET reply->status_block.status_code = invalid_concept
 ELSE
  SELECT INTO "nl:"
   FROM logical_domain ld,
    prsnl p
   PLAN (ld
    WHERE ld.active_ind=1
     AND ld.system_user_id > 0)
    JOIN (p
    WHERE p.person_id=ld.system_user_id
     AND p.active_ind=1
     AND cnvtdatetime(cur_datetime) BETWEEN p.beg_effective_dt_tm AND p.end_effective_dt_tm
     AND p.logical_domain_id=ld.logical_domain_id)
   HEAD REPORT
    rec = 0
   DETAIL
    rec = (rec+ 1)
    IF (mod(rec,10)=1)
     stat = alterlist(reply->logical_domains,(rec+ 9))
    ENDIF
    reply->logical_domains[rec].logical_domain_id = ld.logical_domain_id, reply->logical_domains[rec]
    .mnemonic = ld.mnemonic
   FOOT REPORT
    stat = alterlist(reply->logical_domains,rec), reply->status_block.status_ind = success, reply->
    status_block.status_code = success
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_block.status_ind = failure
   SET reply->status_block.status_code = invalid_state
   SELECT INTO "nl:"
    FROM logical_domain ld
    PLAN (ld
     WHERE ld.active_ind=1
      AND ld.logical_domain_id=0
      AND ld.system_user_id=0)
    DETAIL
     reply->status_block.status_ind = success, reply->status_block.status_code = no_domains
    WITH nocounter
   ;end select
   IF (curqual=1)
    SELECT INTO "nl:"
     cnt = count(*)
     FROM logical_domain ld
     PLAN (ld
      WHERE ld.active_ind=1
       AND ld.logical_domain_id != 0)
     DETAIL
      IF (cnt > 0)
       reply->status_block.status_ind = failure, reply->status_block.status_code = invalid_state
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ENDIF
END GO
