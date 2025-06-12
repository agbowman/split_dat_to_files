CREATE PROGRAM ch_get_clients:dba
 RECORD reply(
   1 qual[*]
     2 organization_id = f8
     2 org_name = c100
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
 SET reply->status_data.status = "F"
 CALL logicaldomainlookup(null)
 DECLARE client_code = f8 WITH constant(uar_get_code_by("MEANING",278,"CLIENT"))
 SET count = 0
 SET searchstring = cnvtupper(concat(request->start_name,"*"))
 SELECT INTO "nl:"
  o.organization_id, o.org_name
  FROM organization o,
   org_type_reltn t
  PLAN (t
   WHERE t.org_type_cd=client_code
    AND t.active_ind=1
    AND t.organization_id > 0.0
    AND t.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND t.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (o
   WHERE t.organization_id=o.organization_id
    AND o.logical_domain_id=logical_domain
    AND o.active_ind=1
    AND o.org_name_key=patstring(searchstring))
  ORDER BY o.org_name
  DETAIL
   count += 1, stat = alterlist(reply->qual,count), reply->qual[count].organization_id = o
   .organization_id,
   reply->qual[count].org_name = o.org_name
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  GO TO 9999_end
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE logicaldomainlookup(null)
   DECLARE lgetldstatus = i4 WITH private, noconstant(0)
   SET lgetldstatus = get_logical_domain("ORGANIZATION")
   IF (lgetldstatus != ld_success)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "ch_get_clients"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "EXECUTE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "ERROR! - CCL errors occurred in pm_get_logical_domain! Exiting Job."
    GO TO 9999_end
   ENDIF
 END ;Subroutine
#9999_end
END GO
