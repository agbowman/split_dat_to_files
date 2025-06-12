CREATE PROGRAM bed_get_hco:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 hco[*]
      2 hco_id = f8
      2 hco_nbr = i4
      2 hco_name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE logerror(namemsg=vc,valuemsg=vc) = null
 DECLARE error_flag = vc
 DECLARE bparse = vc
 DECLARE hco_cnt = i4
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET error_flag = "N"
 SET data_partition_ind = 0
 RANGE OF b IS br_hco
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
 SET bparse = "b.br_hco_id > 0"
 IF (data_partition_ind=1)
  SET bparse = build2(bparse," and b.logical_domain_id = ",acm_get_curr_logical_domain_rep->
   logical_domain_id)
 ENDIF
 SELECT INTO "nl:"
  FROM br_hco b
  WHERE parser(bparse)
  DETAIL
   hco_cnt = (hco_cnt+ 1), stat = alterlist(reply->hco,hco_cnt), reply->hco[hco_cnt].hco_id = b
   .br_hco_id,
   reply->hco[hco_cnt].hco_name = b.hco_name, reply->hco[hco_cnt].hco_nbr = b.hco_nbr
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  CALL logerror("Error reading BR_HCO table.",serrmsg)
 ENDIF
 SUBROUTINE logerror(namemsg,valuemsg)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = namemsg
   SET reply->status_data.subeventstatus[1].targetobjectvalue = valuemsg
   GO TO exit_script
 END ;Subroutine
#exit_script
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
