CREATE PROGRAM cdi_get_logical_domain_cfg:dba
 SET modify = predeclare
 IF (validate(reply)=0)
  RECORD reply(
    1 alias_contrib_src_cd = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE current_logical_domain_id = f8 WITH noconstant(0.0), protect
 SET reply->status_data.status = "S"
 FREE RECORD acm_get_curr_logical_domain_req
 FREE RECORD acm_get_curr_logical_domain_rep
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
 EXECUTE acm_get_curr_logical_domain
 IF ((acm_get_curr_logical_domain_rep->status_block.status_ind=0))
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET current_logical_domain_id = acm_get_curr_logical_domain_rep->logical_domain_id
 FREE RECORD acm_get_curr_logical_domain_req
 FREE RECORD acm_get_curr_logical_domain_rep
 CALL echo(sline)
 CALL echo("********** BEGIN CDI_GET_LOGICAL_DOMAIN_CFG **********")
 CALL echo(sline)
 SELECT INTO "nl:"
  FROM cdi_logical_domain_config cdi
  WHERE cdi.logical_domain_id=current_logical_domain_id
  DETAIL
   reply->alias_contrib_src_cd = cdi.alias_contrib_src_cd
 ;end select
#exit_script
 CALL echo("Last Mod: 000")
 CALL echo("Mod Date: 06/20/2018")
 CALL echo(sline)
 SET modify = nopredeclare
 CALL echo("********** END CDI_GET_LOGICAL_DOMAIN_CFG **********")
 CALL echo(sline)
END GO
