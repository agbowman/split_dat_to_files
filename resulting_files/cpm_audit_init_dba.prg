CREATE PROGRAM cpm_audit_init:dba
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
 RECORD request(
   1 concept = i4
 )
 RECORD reply(
   1 enabled = i2
   1 status_block
     2 status_ind = i2
     2 status_code = i4
 ) WITH persistscript
 SET auditinfo->logical_domain_enabled = false
 IF (checkprg("ACM_CHECK_LD_ENABLED") > 0)
  SET request->concept = ld_concept_prsnl
  EXECUTE acm_check_ld_enabled
  IF ((reply->enabled=true)
   AND (reply->status_ind=1))
   SET auditinfo->logical_domain_enabled = true
  ENDIF
 ENDIF
END GO
