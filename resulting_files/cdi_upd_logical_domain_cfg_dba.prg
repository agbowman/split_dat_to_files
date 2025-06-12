CREATE PROGRAM cdi_upd_logical_domain_cfg:dba
 SET modify = predeclare
 IF (validate(reply->status_data.status)=0)
  RECORD reply(
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
 DECLARE rows_to_update_count = i4 WITH noconstant(0), public
 DECLARE inserted_rows = i4 WITH noconstant(0), protect
 DECLARE updated_rows = i4 WITH noconstant(0), protect
 DECLARE sstatus = c1 WITH protect, noconstant("F")
 DECLARE sstatusreason = vc WITH protect, noconstant("Script Error")
 SET reply->status_data.status = "F"
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
  GO TO exit_script
 ENDIF
 SET current_logical_domain_id = acm_get_curr_logical_domain_rep->logical_domain_id
 FREE RECORD acm_get_curr_logical_domain_req
 FREE RECORD acm_get_curr_logical_domain_rep
 CALL echo(sline)
 CALL echo("********** BEGIN cdi_upd_logical_domain_cfg **********")
 CALL echo(sline)
 SELECT INTO "nl:"
  FROM cdi_logical_domain_config cdi
  WHERE cdi.logical_domain_id=current_logical_domain_id
  DETAIL
   rows_to_update_count += 1
  WITH nocounter, forupdatewait(cdi)
 ;end select
 IF (rows_to_update_count > 0)
  UPDATE  FROM cdi_logical_domain_config cdi
   SET cdi.alias_contrib_src_cd = request->alias_contrib_src_cd
   WHERE cdi.logical_domain_id=current_logical_domain_id
   WITH nocounter
  ;end update
  SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 ENDIF
 IF (rows_to_update_count=0)
  INSERT  FROM cdi_logical_domain_config cdi
   SET cdi.cdi_logical_domain_config_id = seq(cdi_seq,nextval), cdi.logical_domain_id =
    current_logical_domain_id, cdi.alias_contrib_src_cd = request->alias_contrib_src_cd
   WITH nocounter
  ;end insert
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 ENDIF
 IF (curqual=1)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_upd_sign_anno"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echo("Last Mod: 000")
 CALL echo("Mod Date: 06/20/2018")
 CALL echo(sline)
 SET modify = nopredeclare
 CALL echo("********** END cdi_upd_logical_domain_cfg **********")
 CALL echo(sline)
END GO
