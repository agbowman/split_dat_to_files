CREATE PROGRAM da_get_location_list:dba
 DECLARE searchkeypattern = vc WITH protect
 DECLARE searchwordspattern = vc WITH protect
 DECLARE ldcount = i4 WITH protect
 DECLARE cvcount = i4 WITH protect
 DECLARE stat = i4 WITH protect
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE idy = i4 WITH protect, noconstant(0)
 DECLARE idz = i4 WITH protect, noconstant(0)
 DECLARE orgsecurityind = i4 WITH protect, noconstant(0)
 DECLARE qualifications = vc WITH protect
 RECORD locmeanings(
   1 qual[*]
     2 meaning = vc
 ) WITH protect
 RECORD orgtypemeanings(
   1 qual[*]
     2 meaning = vc
 ) WITH protect
 SUBROUTINE (parsecommalist(input=vc(ref),rec=vc(ref)) =i2)
   DECLARE pos = i4 WITH protect
   DECLARE len = i4 WITH protect, noconstant(textlen(input))
   DECLARE char = c1 WITH protect
   DECLARE begin = i4 WITH protect, noconstant(1)
   DECLARE count = i4 WITH protect, noconstant(0)
   DECLARE quote = i2 WITH protect, noconstant(- (1))
   DECLARE val = vc WITH protect, noconstant(" ")
   IF (textlen(trim(input))=0)
    RETURN(0)
   ELSEIF (substring(1,1,input)='"')
    SET quote = 1
   ENDIF
   FOR (pos = 1 TO len)
    SET char = substring(pos,1,input)
    IF (quote=1
     AND pos < len)
     IF (char='"'
      AND pos > 1)
      IF (substring((pos+ 1),1,input)='"')
       SET val = notrim(concat(val,char))
       SET pos += 1
      ELSE
       SET quote = 2
      ENDIF
     ELSEIF (pos > 1)
      SET val = notrim(concat(val,char))
     ENDIF
    ELSEIF (((char=",") OR (pos=len)) )
     SET count += 1
     IF (mod(count,10)=1)
      SET stat = alterlist(rec->qual,(count+ 9))
     ENDIF
     IF (char != ","
      AND ((quote != 1) OR (char != '"')) )
      SET val = notrim(concat(val,char))
     ENDIF
     IF (quote > 0)
      SET rec->qual[count].meaning = notrim(val)
     ELSE
      SET rec->qual[count].meaning = trim(val,3)
     ENDIF
     SET val = " "
     IF (pos=len
      AND char=",")
      SET count += 1
     ELSEIF (substring((pos+ 1),1,input)='"')
      SET quote = 1
      SET pos += 1
     ENDIF
    ELSE
     SET val = notrim(concat(val,char))
    ENDIF
   ENDFOR
   SET stat = alterlist(rec->qual,count)
   RETURN(count)
 END ;Subroutine
 SET qualifications = concat("cv.code_set = 220 and cv.display_key = patstring(searchKeyPattern)",
  " and cnvtupper(cv.display) = patstring(searchWordsPattern)",
  " and cnvtdatetime(curdate, curtime3) between cv.begin_effective_dt_tm and cv.end_effective_dt_tm",
  " and cv.active_ind = 1 and l.location_cd = cv.code_value and l.active_ind = 1",
  " and cnvtdatetime(curdate, curtime3) between l.beg_effective_dt_tm and l.end_effective_dt_tm",
  " and o.organization_id = l.organization_id and o.active_ind = 1 ",
  " and cnvtdatetime(curdate, curtime3) between o.beg_effective_dt_tm and o.end_effective_dt_tm")
 SET searchwordspattern = concat(trim(cnvtupper(start_value),3),"*")
 SET searchkeypattern = concat(trim(cnvtupper(cnvtalphanum(start_value)),3),"*")
 SET stat = parsecommalist(request->val2,locmeanings)
 IF (stat > 0)
  SET qualifications = concat("expand(idy, 1, size(locMeanings->qual, 5), cv.cdf_meaning, ",
   "locMeanings->qual[idy]->meaning) and ",qualifications)
 ENDIF
 SET stat = parsecommalist(request->val3,orgtypemeanings)
 IF (stat > 0)
  SET qualifications = concat(qualifications," and otr.organization_id = o.organization_id",
   " and tv.code_value = otr.org_type_cd and otr.active_ind = 1 ",
   " and cnvtdatetime(curdate, curtime3) between otr.beg_effective_dt_tm and otr.end_effective_dt_tm",
   " and tv.active_ind = 1",
   " and cnvtdatetime(curdate, curtime3) between tv.begin_effective_dt_tm and tv.end_effective_dt_tm",
   " and not expand(idz, 1, size(orgTypeMeanings->qual, 5), tv.cdf_meaning, orgTypeMeanings->qual[idz]->meaning)"
   )
 ENDIF
 IF (cnvtupper(trim(request->val4,3))="FEDERAL_TAX_ID_NBR")
  SET qualifications = concat(qualifications," and o.federal_tax_id_nbr != ' '")
 ENDIF
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
 SET reply->status_data.status = "F"
 SET stat = get_logical_domains("ORGANIZATION")
 IF (stat=ld_success)
  SET ldcount = size(logical_domains->qual,5)
  SET qualifications = concat(qualifications,
   " and expand(idx, 1, ldCount, o.logical_domain_id, logical_domains->qual[idx]->logical_domain_id)"
   )
 ELSEIF (stat=ld_no_schema)
  SET ldcount = 0
 ELSE
  SET reply->status_data.operationname = "EXECUTE"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "subroutine"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "get_logical_domains"
  SET reply->status_data.status = "F"
  GO TO end_now
 ENDIF
 IF (context_ind=1)
  SET qualifications = concat(qualifications,
   " and ( cnvtupper(cv.display) > cnvtupper(context->string1)",
   " or ( cnvtupper(cv.display) = cnvtupper(context->string1)",
   " and l.location_cd > context->num1 ) )")
 ENDIF
 SELECT INTO "nl:"
  d.info_number
  FROM dm_info d
  WHERE d.info_domain="SECURITY"
   AND d.info_name="SEC_ORG_RELTN"
   AND d.info_domain_id=0
  DETAIL
   orgsecurityind = d.info_number
  WITH nocounter
 ;end select
 SELECT
  IF (orgsecurityind=1
   AND size(orgtypemeanings->qual,5) > 0)
   FROM location l,
    code_value cv,
    organization o,
    prsnl_org_reltn por,
    org_type_reltn otr,
    code_value tv
   WHERE (por.person_id=reqinfo->updt_id)
    AND por.active_ind=1
    AND cnvtdatetime(sysdate) BETWEEN por.beg_effective_dt_tm AND por.end_effective_dt_tm
    AND o.organization_id=por.organization_id
    AND parser(qualifications)
  ELSEIF (orgsecurityind=1)
   FROM location l,
    code_value cv,
    organization o,
    prsnl_org_reltn por
   WHERE (por.person_id=reqinfo->updt_id)
    AND por.active_ind=1
    AND cnvtdatetime(sysdate) BETWEEN por.beg_effective_dt_tm AND por.end_effective_dt_tm
    AND o.organization_id=por.organization_id
    AND parser(qualifications)
  ELSEIF (size(orgtypemeanings->qual,5) > 0)
   FROM location l,
    code_value cv,
    organization o,
    org_type_reltn otr,
    code_value tv
   WHERE parser(qualifications)
  ELSE
   FROM location l,
    code_value cv,
    organization o
   WHERE parser(qualifications)
  ENDIF
  DISTINCT INTO "nl:"
  l.location_cd, cv.display, cv.cdf_meaning
  ORDER BY sqlpassthru("UPPER(CV.DISPLAY)"), l.location_cd
  HEAD REPORT
   cvcount = 0
  DETAIL
   cvcount += 1
   IF (mod(cvcount,100)=1)
    stat = alterlist(reply->datacoll,(cvcount+ 99))
   ENDIF
   reply->datacoll[cvcount].currcv = trim(build2(l.location_cd),3), reply->datacoll[cvcount].
   description = cv.display, reply->datacoll[cvcount].val1 = cv.cdf_meaning
   IF (cvcount=maxqualrows)
    context->context_ind = 1, context->num1 = l.location_cd, context->string1 = cv.display,
    context->start_value = start_value, context->maxqual = maxqualrows
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->datacoll,cvcount)
  WITH nocounter, rdbunion, maxrec = value(maxqualrows)
 ;end select
#end_now
END GO
