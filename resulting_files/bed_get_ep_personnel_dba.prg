CREATE PROGRAM bed_get_ep_personnel:dba
 FREE RECORD temp_reply
 RECORD temp_reply(
   1 ep_prsnl_list[*]
     2 ep_id = f8
     2 person_id = f8
     2 name_full_formatted = vc
     2 username = vc
     2 defined_measure_count = i4
     2 active_ind = i2
     2 effective_ind = i2
     2 ep_groups_qualified_ind = i2
     2 measures_qualified_ind = i2
     2 npi_alias = vc
     2 tin_alias = vc
     2 gpro_ind = i2
     2 gpro_submit_type_flag = i2
 )
 FREE RECORD get_measures_request
 RECORD get_measures_request(
   1 measure_type_flag = i4
   1 pqrs_type = i2
   1 ep_prsnl_list[*]
     2 ep_id = f8
   1 mu_years[*]
     2 year = vc
   1 report_type_id = vc
 )
 FREE RECORD get_measures_reply
 RECORD get_measures_reply(
   1 ep_prsnl_list[*]
     2 ep_id = f8
     2 measure_cnt = i4
     2 pilot_measures_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 ep_prsnl_list[*]
      2 ep_id = f8
      2 person_id = f8
      2 name_full_formatted = vc
      2 username = vc
      2 defined_measure_count = i4
      2 active_ind = i2
      2 effective_ind = i2
      2 npi_alias = vc
      2 tin_alias = vc
      2 gpro_ind = i2
      2 gpro_submit_type_flag = i2
    1 too_many_results_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  SET reply->status_data.status = "F"
  SET reply->too_many_results_ind = 0
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE get_measures(measure_flag=i2,pqrs_type=i2) = null
 SUBROUTINE get_measures(measure_flag,pqrs_type)
   SET epsize = size(temp_reply->ep_prsnl_list,5)
   SET stat = alterlist(get_measures_request->ep_prsnl_list,epsize)
   SET stat = alterlist(get_measures_reply->ep_prsnl_list,0)
   SET report_type_id = request->report_type_id
   FOR (x = 1 TO epsize)
     SET get_measures_request->ep_prsnl_list[x].ep_id = temp_reply->ep_prsnl_list[x].ep_id
   ENDFOR
   SET get_measures_request->measure_type_flag = measure_flag
   SET get_measures_request->pqrs_type = pqrs_type
   SET get_measures_request->report_type_id = report_type_id
   IF (validate(request->mu_years))
    FOR (year_cnt = 1 TO size(request->mu_years,5))
     SET stat = alterlist(get_measures_request->mu_years,year_cnt)
     SET get_measures_request->mu_years[year_cnt].year = request->mu_years[year_cnt].year
    ENDFOR
   ENDIF
   EXECUTE bed_get_ep_meas_defined  WITH replace("REQUEST",get_measures_request), replace("REPLY",
    get_measures_reply)
   DECLARE parse = vc WITH protect
   SET parse =
   " temp_reply->ep_prsnl_list[d1.seq].ep_id = get_measures_reply->ep_prsnl_list[d2.seq].ep_id"
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = epsize),
     (dummyt d2  WITH seq = epsize)
    PLAN (d1)
     JOIN (d2
     WHERE parser(parse))
    ORDER BY d1.seq, d2.seq
    DETAIL
     temp_reply->ep_prsnl_list[d1.seq].defined_measure_count = get_measures_reply->ep_prsnl_list[d2
     .seq].measure_cnt
     IF ((get_measures_reply->ep_prsnl_list[d2.seq].pilot_measures_cnt > 2))
      temp_reply->ep_prsnl_list[d1.seq].measures_qualified_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("Measure Placement error")
 END ;Subroutine
 DECLARE req_size = i4 WITH noconstant(0), protect
 DECLARE reply_size = i4 WITH noconstant(0), protect
 DECLARE temp_reg_size = i4 WITH noconstant(0), protect
 DECLARE pos_cnt = i4 WITH noconstant(0), protect
 DECLARE org_cnt = i4 WITH noconstant(0), protect
 DECLARE org_grp_cnt = i4 WITH noconstant(0), protect
 DECLARE ep_prsnl_parse = vc WITH noconstant(""), protect
 DECLARE org_parse = vc WITH noconstant(""), protect
 DECLARE org_grp_parse = vc WITH noconstant(""), protect
 DECLARE pqrs_reltn_parse = vc WITH noconstant(""), protect
 DECLARE pqrs_meas_parse = vc WITH noconstant(""), protect
 SET pos_cnt = size(request->positions_list,5)
 SET org_cnt = size(request->organizations_list,5)
 SET org_grp_cnt = size(request->organization_groups_list,5)
 SET ep_prsnl_parse = "p.person_id > 0 and p.name_full_formatted > ' '"
 IF (validate(debug,0)=1)
  CALL echorecord(request)
  CALL echo(build("ORG GRP CNT: - ",org_grp_cnt))
  CALL echo(build("ORG CNT: - ",org_cnt))
  CALL echo(build("POS CNT: - ",pos_cnt))
  CALL echo(build("INITIAL: - ",ep_prsnl_parse))
 ENDIF
 SET data_partition_ind = 0
 RANGE OF b IS br_ccn
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
 IF (data_partition_ind=1)
  SET ep_prsnl_parse = build2(ep_prsnl_parse," and p.logical_domain_id = ",
   acm_get_curr_logical_domain_rep->logical_domain_id)
 ENDIF
 IF (org_cnt > 0
  AND org_grp_cnt > 0)
  CALL bederror("Org and Org grp > 0")
  GO TO exit_script
 ENDIF
 IF (pos_cnt > 999)
  CALL bederror("Position count exceeds 999")
  GO TO exit_script
 ENDIF
 IF (org_grp_cnt > 999)
  CALL bederror("Organization grp count exceeds 999")
  GO TO exit_script
 ENDIF
 IF (org_cnt > 999)
  CALL bederror("Organization count exceeds 999")
  GO TO exit_script
 ENDIF
 IF ((request->name_first > " "))
  SET ep_prsnl_parse = concat(ep_prsnl_parse," and p.name_first_key = '",nullterm(cnvtalphanum(
     cnvtupper(trim(request->name_first)))),"*'")
 ENDIF
 CALL echo(build("FIRST NAME: - ",ep_prsnl_parse))
 IF ((request->name_last > " "))
  SET ep_prsnl_parse = concat(ep_prsnl_parse," and p.name_last_key = '",nullterm(cnvtalphanum(
     cnvtupper(trim(request->name_last)))),"*'")
 ENDIF
 CALL echo(build("LAST NAME: - ",ep_prsnl_parse))
 IF ((request->username > " "))
  SET ep_prsnl_parse = concat(ep_prsnl_parse," and cnvtupper(p.username) = '",trim(cnvtupper(request
     ->username)),"*'")
 ENDIF
 CALL echo(build("USERNAME: - ",ep_prsnl_parse))
 IF ((request->inc_inactive_ind=0))
  SET ep_prsnl_parse = concat(ep_prsnl_parse," and p.active_ind = 1")
 ENDIF
 CALL echo(build("ACTIVE PERSONNEL: - ",ep_prsnl_parse))
 IF ((request->filter_non_effectives_ind=1))
  SET ep_prsnl_parse = concat(ep_prsnl_parse,
   " and p.END_EFFECTIVE_DT_TM > cnvtdatetime(curdate,curtime3)")
 ENDIF
 CALL echo(build("EFFECTIVE PERSONNEL: - ",ep_prsnl_parse))
 IF ((request->physician_only_ind=1))
  SET ep_prsnl_parse = concat(ep_prsnl_parse," and p.physician_ind = 1")
 ENDIF
 CALL echo(build("PHYSICIAN IND: - ",ep_prsnl_parse))
 IF ((request->username_only_ind=1))
  SET ep_prsnl_parse = concat(ep_prsnl_parse," and p.username != NULL and p.username > '  *' ")
 ENDIF
 CALL echo(build("USERNAME INDICATOR:  - ",ep_prsnl_parse))
 IF (pos_cnt > 0)
  SET ep_prsnl_parse = build(ep_prsnl_parse," and p.position_cd in (")
  FOR (i = 1 TO pos_cnt)
    IF (i=1)
     SET ep_prsnl_parse = build(ep_prsnl_parse,request->positions_list[i].position_cd)
    ELSE
     SET ep_prsnl_parse = build(ep_prsnl_parse,", ",request->positions_list[i].position_cd)
    ENDIF
  ENDFOR
  SET ep_prsnl_parse = build(ep_prsnl_parse,")")
 ENDIF
 CALL echo(build("POSITIONS: - ",ep_prsnl_parse))
 IF (org_cnt > 0)
  SET org_parse = "por.organization_id in ("
  FOR (i = 1 TO org_cnt)
    IF (i=1)
     SET org_parse = build(org_parse,request->organizations_list[i].org_id)
    ELSE
     SET org_parse = build(org_parse,", ",request->organizations_list[i].org_id)
    ENDIF
  ENDFOR
  SET org_parse = build(org_parse,")")
 ELSEIF (org_grp_cnt > 0)
  SET org_grp_parse = "ospr.org_set_id in ("
  FOR (i = 1 TO org_grp_cnt)
    IF (i=1)
     SET org_grp_parse = build(org_grp_parse,request->organization_groups_list[i].org_grp_id)
    ELSE
     SET org_grp_parse = build(org_grp_parse,", ",request->organization_groups_list[i].org_grp_id)
    ENDIF
  ENDFOR
  SET org_grp_parse = build(org_grp_parse,")")
 ENDIF
 CALL echo(build("ORG_PARSE: - ",org_parse))
 CALL echo(build("ORG_GRP_PARSE:  - ",org_grp_parse))
 SET rcnt = 0
 IF (org_cnt > 0)
  SELECT INTO "nl:"
   FROM prsnl p,
    prsnl_org_reltn por,
    br_eligible_provider brep
   PLAN (p
    WHERE parser(ep_prsnl_parse))
    JOIN (por
    WHERE parser(org_parse)
     AND por.person_id=p.person_id
     AND por.active_ind=1
     AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ((por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (por.end_effective_dt_tm=null
    )) )
    JOIN (brep
    WHERE brep.provider_id=p.person_id
     AND brep.active_ind=1
     AND brep.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ORDER BY p.person_id
   HEAD REPORT
    rcnt = 0, listcnt = 0, stat = alterlist(temp_reply->ep_prsnl_list,100)
   HEAD p.person_id
    rcnt = (rcnt+ 1), listcnt = (listcnt+ 1)
    IF (listcnt > 100)
     listcnt = 1, stat = alterlist(temp_reply->ep_prsnl_list,(rcnt+ 100))
    ENDIF
    temp_reply->ep_prsnl_list[rcnt].ep_id = brep.br_eligible_provider_id, temp_reply->ep_prsnl_list[
    rcnt].person_id = p.person_id, temp_reply->ep_prsnl_list[rcnt].name_full_formatted = p
    .name_full_formatted,
    temp_reply->ep_prsnl_list[rcnt].username = p.username, temp_reply->ep_prsnl_list[rcnt].active_ind
     = p.active_ind
    IF (p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     temp_reply->ep_prsnl_list[rcnt].effective_ind = 1
    ENDIF
    temp_reply->ep_prsnl_list[rcnt].npi_alias = brep.national_provider_nbr_txt, temp_reply->
    ep_prsnl_list[rcnt].tin_alias = brep.tax_id_nbr_txt
   WITH nocounter
  ;end select
 ELSEIF (org_grp_cnt > 0)
  SELECT INTO "nl:"
   FROM prsnl p,
    org_set_prsnl_r ospr,
    br_eligible_provider brep
   PLAN (p
    WHERE parser(ep_prsnl_parse))
    JOIN (ospr
    WHERE parser(org_grp_parse)
     AND ospr.prsnl_id=p.person_id
     AND ospr.active_ind=1
     AND ospr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ((ospr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (ospr.end_effective_dt_tm=
    null)) )
    JOIN (brep
    WHERE brep.provider_id=p.person_id
     AND brep.active_ind=1
     AND brep.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ORDER BY p.person_id
   HEAD REPORT
    rcnt = 0, listcnt = 0, stat = alterlist(temp_reply->ep_prsnl_list,100)
   HEAD p.person_id
    rcnt = (rcnt+ 1), listcnt = (listcnt+ 1)
    IF (listcnt > 100)
     listcnt = 1, stat = alterlist(temp_reply->ep_prsnl_list,(rcnt+ 100))
    ENDIF
    temp_reply->ep_prsnl_list[rcnt].ep_id = brep.br_eligible_provider_id, temp_reply->ep_prsnl_list[
    rcnt].person_id = p.person_id, temp_reply->ep_prsnl_list[rcnt].name_full_formatted = p
    .name_full_formatted,
    temp_reply->ep_prsnl_list[rcnt].username = p.username, temp_reply->ep_prsnl_list[rcnt].active_ind
     = p.active_ind
    IF (p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     temp_reply->ep_prsnl_list[rcnt].effective_ind = 1
    ENDIF
    temp_reply->ep_prsnl_list[rcnt].npi_alias = brep.national_provider_nbr_txt, temp_reply->
    ep_prsnl_list[rcnt].tin_alias = brep.tax_id_nbr_txt
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM prsnl p,
    br_eligible_provider brep
   PLAN (p
    WHERE parser(ep_prsnl_parse))
    JOIN (brep
    WHERE brep.provider_id=p.person_id
     AND brep.active_ind=1
     AND brep.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ORDER BY p.person_id
   HEAD REPORT
    rcnt = 0, listcnt = 0, stat = alterlist(temp_reply->ep_prsnl_list,100)
   DETAIL
    rcnt = (rcnt+ 1), listcnt = (listcnt+ 1)
    IF (listcnt > 100)
     listcnt = 1, stat = alterlist(temp_reply->ep_prsnl_list,(rcnt+ 100))
    ENDIF
    temp_reply->ep_prsnl_list[rcnt].ep_id = brep.br_eligible_provider_id, temp_reply->ep_prsnl_list[
    rcnt].person_id = p.person_id, temp_reply->ep_prsnl_list[rcnt].name_full_formatted = p
    .name_full_formatted,
    temp_reply->ep_prsnl_list[rcnt].username = p.username, temp_reply->ep_prsnl_list[rcnt].active_ind
     = p.active_ind
    IF (p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     temp_reply->ep_prsnl_list[rcnt].effective_ind = 1
    ENDIF
    temp_reply->ep_prsnl_list[rcnt].npi_alias = brep.national_provider_nbr_txt, temp_reply->
    ep_prsnl_list[rcnt].tin_alias = brep.tax_id_nbr_txt
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(temp_reply->ep_prsnl_list,rcnt)
 CALL bederrorcheck("error on get eligible providers")
 IF (validate(request->measure_type_flag))
  SET measure_type_flag = request->measure_type_flag
 ENDIF
 IF (rcnt > 0)
  IF (measure_type_flag=1)
   CALL get_measures(1,request->pqrs_type)
  ELSE
   CALL get_measures(measure_type_flag,0)
  ENDIF
 ENDIF
 SET temp_cnt = size(temp_reply->ep_prsnl_list,5)
 SET ep_group_cnt = size(request->eligible_provider_groups,5)
 IF (ep_group_cnt > 0)
  SELECT INTO "nl:"
   FROM br_group_reltn bgr,
    (dummyt d1  WITH seq = ep_group_cnt),
    (dummyt d2  WITH seq = temp_cnt)
   PLAN (bgr)
    JOIN (d1
    WHERE (bgr.br_group_id=request->eligible_provider_groups[d1.seq].eligible_provider_group_id))
    JOIN (d2
    WHERE bgr.parent_entity_name="BR_ELIGIBLE_PROVIDER"
     AND (bgr.parent_entity_id=temp_reply->ep_prsnl_list[d2.seq].ep_id))
   ORDER BY bgr.br_group_reltn_id, d1.seq, d2.seq
   HEAD d2.seq
    temp_reply->ep_prsnl_list[d2.seq].ep_groups_qualified_ind = 1
   WITH nocounter
  ;end select
  CALL bederrorcheck("BR_GROUP_RELTN Select Error")
 ENDIF
 FOR (x = 1 TO temp_cnt)
   SET curr_ep_id = temp_reply->ep_prsnl_list[x].ep_id
   SELECT INTO "nl:"
    FROM br_gpro_reltn bgr,
     br_gpro g
    PLAN (bgr
     WHERE bgr.parent_entity_id=curr_ep_id
      AND bgr.active_ind=1
      AND bgr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
     JOIN (g
     WHERE g.br_gpro_id=bgr.br_gpro_id)
    DETAIL
     temp_reply->ep_prsnl_list[x].gpro_submit_type_flag = g.submit_type_flag
    WITH nocounter
   ;end select
   SET temp_reply->ep_prsnl_list[x].gpro_ind = curqual
 ENDFOR
 DECLARE reply_cnt = i4 WITH protect
 SET reply_cnt = 0
 IF (temp_cnt > 0)
  FOR (x = 1 TO temp_cnt)
    IF ((((request->pqrs_type=0)) OR ((temp_reply->ep_prsnl_list[x].measures_qualified_ind=1)))
     AND ((ep_group_cnt=0) OR ((temp_reply->ep_prsnl_list[x].ep_groups_qualified_ind=1))) )
     SET reply_cnt = (reply_cnt+ 1)
     SET stat = alterlist(reply->ep_prsnl_list,reply_cnt)
     SET reply->ep_prsnl_list[reply_cnt].ep_id = temp_reply->ep_prsnl_list[x].ep_id
     SET reply->ep_prsnl_list[reply_cnt].person_id = temp_reply->ep_prsnl_list[x].person_id
     SET reply->ep_prsnl_list[reply_cnt].name_full_formatted = temp_reply->ep_prsnl_list[x].
     name_full_formatted
     SET reply->ep_prsnl_list[reply_cnt].username = temp_reply->ep_prsnl_list[x].username
     SET reply->ep_prsnl_list[reply_cnt].defined_measure_count = temp_reply->ep_prsnl_list[x].
     defined_measure_count
     SET reply->ep_prsnl_list[reply_cnt].active_ind = temp_reply->ep_prsnl_list[x].active_ind
     SET reply->ep_prsnl_list[reply_cnt].effective_ind = temp_reply->ep_prsnl_list[x].effective_ind
     SET reply->ep_prsnl_list[reply_cnt].npi_alias = temp_reply->ep_prsnl_list[x].npi_alias
     SET reply->ep_prsnl_list[reply_cnt].tin_alias = temp_reply->ep_prsnl_list[x].tin_alias
     SET reply->ep_prsnl_list[reply_cnt].gpro_ind = temp_reply->ep_prsnl_list[x].gpro_ind
     SET reply->ep_prsnl_list[reply_cnt].gpro_submit_type_flag = temp_reply->ep_prsnl_list[x].
     gpro_submit_type_flag
    ENDIF
  ENDFOR
 ENDIF
 IF ((reply_cnt > request->max_reply))
  SET reply->too_many_results_ind = 1
 ELSE
  SET reply->too_many_results_ind = 0
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
