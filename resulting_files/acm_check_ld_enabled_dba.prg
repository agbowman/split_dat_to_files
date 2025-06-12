CREATE PROGRAM acm_check_ld_enabled:dba
 IF (validate(reply)=0)
  RECORD reply(
    1 enabled = i2
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
 DECLARE domain_cnt = i4 WITH noconstant(0)
 SET reply->enabled = false
 SET reply->status_block.status_ind = failure
 SET reply->status_block.status_code = unknown_status
 FREE RECORD acm_get_logical_domains_rep
 RECORD acm_get_logical_domains_rep(
   1 logical_domains[*]
     2 logical_domain_id = f8
     2 mnemonic = vc
   1 status_block
     2 status_ind = i2
     2 status_code = i4
 )
 EXECUTE acm_get_logical_domains  WITH replace("REQUEST",request), replace("REPLY",
  acm_get_logical_domains_rep)
 SET domain_cnt = value(size(acm_get_logical_domains_rep->logical_domains,5))
 IF (((domain_cnt > 1) OR (domain_cnt=1
  AND (acm_get_logical_domains_rep->logical_domains[0].logical_domain_id != 0))) )
  SET reply->enabled = true
 ENDIF
 SET reply->status_block.status_ind = acm_get_logical_domains_rep->status_block.status_ind
 SET reply->status_block.status_code = acm_get_logical_domains_rep->status_block.status_code
END GO
