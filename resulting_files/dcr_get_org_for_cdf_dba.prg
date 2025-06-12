CREATE PROGRAM dcr_get_org_for_cdf:dba
 RECORD reply(
   1 qual[*]
     2 organization_id = f8
     2 org_name = c200
     2 org_type_cd = f8
     2 org_type_disp = c40
     2 org_type_desc = c60
     2 org_type_mean = c12
     2 active_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 status_ind = i2
     2 collation_seq = i4
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ((validate(passive_check_define,- (99))=- (99)))
  DECLARE passive_check_define = i4 WITH constant(1)
  DECLARE column_exists(stable,scolumn) = i4
  SUBROUTINE column_exists(stable,scolumn)
    DECLARE ce_flag = i4
    SET ce_flag = 0
    DECLARE ce_temp = vc WITH noconstant("")
    SET stable = cnvtupper(stable)
    SET scolumn = cnvtupper(scolumn)
    IF (((currev=8
     AND currevminor=2
     AND currevminor2 >= 4) OR (((currev=8
     AND currevminor > 2) OR (currev > 8)) )) )
     SET ce_temp = build('"',stable,".",scolumn,'"')
     SET stat = checkdic(parser(ce_temp),"A",0)
     IF (stat > 0)
      SET ce_flag = 1
     ENDIF
    ELSE
     SELECT INTO "nl:"
      l.attr_name
      FROM dtableattr a,
       dtableattrl l
      WHERE a.table_name=stable
       AND l.attr_name=scolumn
       AND l.structtype="F"
       AND btest(l.stat,11)=0
      DETAIL
       ce_flag = 1
      WITH nocounter
     ;end select
    ENDIF
    RETURN(ce_flag)
  END ;Subroutine
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
 IF ((validate(get_logical_domain_define,- (99))=- (99)))
  DECLARE get_logical_domain_define = i4 WITH constant(1)
  FREE RECORD logical_domains
  RECORD logical_domains(
    1 qual[*]
      2 logical_domain_id = f8
  )
  DECLARE logical_domain = f8 WITH noconstant(0.0)
  DECLARE ld_success = i4 WITH constant(0)
  DECLARE ld_no_user = i4 WITH constant(1)
  DECLARE ld_no_logical_domains = i4 WITH constant(2)
  DECLARE ld_invalid_concept = i4 WITH constant(3)
  DECLARE ld_no_schema = i4 WITH constant(4)
  SUBROUTINE (get_logical_domain(parent_entity_name=vc) =i4)
   DECLARE b_logicaldomain = i4 WITH constant(column_exists(cnvtupper(parent_entity_name),
     "LOGICAL_DOMAIN_ID"))
   IF (b_logicaldomain > 0)
    DECLARE lerrorcode = i4 WITH noconstant(0)
    FREE RECORD acm_get_curr_logical_domain_req
    FREE RECORD acm_get_curr_logical_domain_rep
    RECORD acm_get_curr_logical_domain_req(
      1 concept = i4
    )
    RECORD acm_get_curr_logical_domain_rep(
      1 logical_domain_id = f8
      1 status_block
        2 status_ind = i2
        2 error_code = i4
    )
    DECLARE concept_id = i4 WITH noconstant(0)
    CASE (parent_entity_name)
     OF "PERSON":
      SET concept_id = ld_concept_person
     OF "PRSNL":
      SET concept_id = ld_concept_prsnl
     OF "ORGANIZATION":
      SET concept_id = ld_concept_organization
     OF "HEALTH_PLAN":
      SET concept_id = ld_concept_healthplan
     OF "ALIAS_POOL":
      SET concept_id = ld_concept_alias_pool
     ELSE
      SET concept_id = 0
    ENDCASE
    IF (concept_id=0)
     RETURN(ld_invalid_concept)
    ENDIF
    SET acm_get_curr_logical_domain_req->concept = concept_id
    EXECUTE acm_get_curr_logical_domain
    SET logical_domain = acm_get_curr_logical_domain_rep->logical_domain_id
    SET lerrorcode = acm_get_curr_logical_domain_rep->status_block.error_code
    FREE RECORD acm_get_curr_logical_domain_req
    FREE RECORD acm_get_curr_logical_domain_rep
    RETURN(lerrorcode)
   ELSE
    RETURN(ld_no_schema)
   ENDIF
  END ;Subroutine
  SUBROUTINE (get_logical_domains(parent_entity_name=vc) =i4)
   DECLARE b_logicaldomain = i4 WITH constant(column_exists(cnvtupper(parent_entity_name),
     "LOGICAL_DOMAIN_ID"))
   IF (b_logicaldomain > 0)
    DECLARE lcount = i4 WITH noconstant(0)
    DECLARE lerrorcode = i4 WITH noconstant(0)
    FREE RECORD acm_get_acc_logical_domains_req
    FREE RECORD acm_get_acc_logical_domains_rep
    RECORD acm_get_acc_logical_domains_req(
      1 write_mode_ind = i2
      1 concept = i4
    )
    RECORD acm_get_acc_logical_domains_rep(
      1 logical_domain_grp_id = f8
      1 logical_domains_cnt = i4
      1 logical_domains[*]
        2 logical_domain_id = f8
      1 status_block
        2 status_ind = i2
        2 error_code = i4
    )
    DECLARE concept_id = i4 WITH noconstant(0)
    CASE (parent_entity_name)
     OF "PERSON":
      SET concept_id = ld_concept_person
     OF "PRSNL":
      SET concept_id = ld_concept_prsnl
     OF "ORGANIZATION":
      SET concept_id = ld_concept_organization
     OF "HEALTH_PLAN":
      SET concept_id = ld_concept_healthplan
     OF "ALIAS_POOL":
      SET concept_id = ld_concept_alias_pool
     ELSE
      SET concept_id = 0
    ENDCASE
    IF (concept_id=0)
     RETURN(ld_invalid_concept)
    ENDIF
    SET acm_get_acc_logical_domains_req->concept = concept_id
    SET acm_get_acc_logical_domains_req->write_mode_ind = 0
    EXECUTE acm_get_acc_logical_domains
    SET lerrorcode = acm_get_acc_logical_domains_rep->status_block.error_code
    IF (lerrorcode=ld_success)
     FOR (lcount = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
      IF (mod(lcount,10)=1)
       SET stat = alterlist(logical_domains->qual,(lcount+ 9))
      ENDIF
      SET logical_domains->qual[lcount].logical_domain_id = acm_get_acc_logical_domains_rep->
      logical_domains[lcount].logical_domain_id
     ENDFOR
     SET stat = alterlist(logical_domains->qual,acm_get_acc_logical_domains_rep->logical_domains_cnt)
    ENDIF
    FREE RECORD acm_get_acc_logical_domains_req
    FREE RECORD acm_get_acc_logical_domains_rep
    RETURN(lerrorcode)
   ELSE
    RETURN(ld_no_schema)
   ENDIF
  END ;Subroutine
 ENDIF
 DECLARE logicaldomainlookup(null) = null
 CALL logicaldomainlookup(null)
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET stat = alterlist(reply->qual,1)
 DECLARE org_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",278,nullterm(request->
    cdf_meaning)))
 DECLARE org_class_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",396,"FREETEXT"))
 SELECT
  IF ((request->get_all_flag=0))
   PLAN (otr
    WHERE otr.org_type_cd=org_type_cd
     AND otr.active_ind=1
     AND otr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND otr.end_effective_dt_tm >= cnvtdatetime(sysdate))
    JOIN (o
    WHERE o.organization_id=otr.organization_id
     AND o.logical_domain_id=logical_domain
     AND o.active_ind=1
     AND o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND o.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND o.org_class_cd != org_class_cd)
  ELSEIF ((request->get_all_flag=1))
   PLAN (otr
    WHERE otr.org_type_cd=org_type_cd)
    JOIN (o
    WHERE o.organization_id=otr.organization_id
     AND o.org_class_cd != org_class_cd
     AND o.logical_domain_id=logical_domain)
  ELSE
  ENDIF
  INTO "nl:"
  otr.organization_id, o.org_name
  FROM org_type_reltn otr,
   organization o
  ORDER BY cnvtupper(o.org_name)
  HEAD REPORT
   count1 = 0
  HEAD otr.organization_id
   count1 += 1
   IF (mod(count1,10)=2)
    stat = alterlist(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].organization_id = otr.organization_id, reply->qual[count1].org_name = o
   .org_name, reply->qual[count1].org_type_cd = otr.org_type_cd,
   reply->qual[count1].active_ind = o.active_ind, reply->qual[count1].beg_effective_dt_tm = o
   .beg_effective_dt_tm, reply->qual[count1].end_effective_dt_tm = o.end_effective_dt_tm
   IF (o.active_ind=1
    AND o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND o.end_effective_dt_tm >= cnvtdatetime(sysdate))
    reply->qual[count1].status_ind = 1
   ELSE
    reply->qual[count1].status_ind = 0
   ENDIF
   reply->qual[count1].updt_cnt = o.updt_cnt
  WITH nocounter
 ;end select
 IF (count1=0)
  SET stat = alterlist(reply->qual,0)
  SET reply->status_data.status = "Z"
 ELSE
  SET stat = alterlist(reply->qual,count1)
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE logicaldomainlookup(null)
   DECLARE lgetldstatus = i4 WITH private, noconstant(0)
   SET lgetldstatus = get_logical_domain("ORGANIZATION")
   IF (lgetldstatus != ld_success)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "dcr_get_org_for_cdf"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "EXECUTE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "ERROR! - CCL errors occurred in pm_get_logical_domain! Exiting Job."
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
END GO
