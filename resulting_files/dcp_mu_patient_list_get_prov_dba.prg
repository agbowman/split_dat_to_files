CREATE PROGRAM dcp_mu_patient_list_get_prov:dba
 PROMPT
  "Last Name:" = "",
  "First Name:" = "",
  "Suffix:" = "",
  "Title:" = "",
  "Alias:" = "",
  "Alias Type:" = 0,
  "View Physician Only" = 0,
  "Max:" = 0,
  "Search By (Name or Alias):" = 0
  WITH prmptlastname, prmptfirstname, prmptsuffix,
  prmpttitle, prmptalias, prmptaliastype,
  prmptviewphysicianonly, prmptmax, prmptsearchby
 DECLARE prmpt_last_name = vc WITH protect, constant( $PRMPTLASTNAME)
 DECLARE prmpt_first_name = vc WITH protect, constant( $PRMPTFIRSTNAME)
 DECLARE prmpt_suffix = vc WITH protect, constant( $PRMPTSUFFIX)
 DECLARE prmpt_title = vc WITH protect, constant( $PRMPTTITLE)
 DECLARE prmpt_alias = vc WITH protect, constant( $PRMPTALIAS)
 DECLARE prmpt_alias_type = f8 WITH protect, constant( $PRMPTALIASTYPE)
 DECLARE prmpt_view_physician_only = i2 WITH protect, constant( $PRMPTVIEWPHYSICIANONLY)
 DECLARE prmpt_max = i4 WITH protect, constant( $PRMPTMAX)
 DECLARE prmpt_search_by = i2 WITH protect, constant( $PRMPTSEARCHBY)
 DECLARE search_by_name = i2 WITH protect, constant(1)
 IF (validate(debug,- (1)) < 0)
  DECLARE debug = i2 WITH protect, constant(0)
 ENDIF
 DECLARE services_string = vc WITH protect, noconstant("")
 DECLARE orgs_string = vc WITH protect, noconstant("")
 DECLARE prsnl_alias_string = vc WITH protect, noconstant("")
 DECLARE positions_string = vc WITH protect, noconstant("")
 DECLARE org_security_ind = i2 WITH protect, noconstant(0)
 IF (debug)
  CALL echorecord(request)
  CALL echorecord(reply)
 ENDIF
 IF (prmpt_search_by=search_by_name)
  RECORD request(
    1 max = i4
    1 name_last_key = c100
    1 name_first_key = c100
    1 search_str_ind = i2
    1 search_str = vc
    1 title_str = vc
    1 suffix_str = vc
    1 degree_str = vc
    1 use_org_security_ind = i2
    1 organization_id = f8
    1 organizations[*]
      2 organization_id = f8
    1 context_ind = i2
    1 start_name = vc
    1 start_name_first = vc
    1 context_person_id = f8
    1 physician_ind = i2
    1 ft_ind = i2
    1 non_ft_ind = i2
    1 inactive_ind = i2
    1 prsnl_group_id = f8
    1 location_cd = f8
    1 return_aliases = i2
    1 return_orgs = i2
    1 return_services = i2
    1 alias_type_list = vc
    1 priv[*]
      2 privilege = c12
    1 auth_only_ind = i2
    1 provider_filter[*]
      2 filter_name = vc
      2 filter_data[*]
        3 data_id = f8
  ) WITH protect
  RECORD reply(
    1 prsnl_cnt = i4
    1 maxqual = i4
    1 more_exist_ind = i2
    1 context_ind = i2
    1 start_name = vc
    1 start_name_first = vc
    1 context_person_id = f8
    1 search_name_first = vc
    1 search_name_last = vc
    1 prsnl[*]
      2 person_id = f8
      2 name_last_key = c100
      2 name_first_key = c100
      2 prsnl_type_cd = f8
      2 name_full_formatted = c100
      2 password = c100
      2 email = c100
      2 physician_ind = i2
      2 position_cd = f8
      2 department_cd = f8
      2 free_text_ind = i2
      2 section_cd = f8
      2 contributor_system_cd = f8
      2 name_last = c200
      2 name_first = c200
      2 username = c50
      2 service[*]
        3 service_desc_id = f8
        3 service_desc_name = c40
      2 org[*]
        3 org_id = f8
        3 org_name = c40
      2 prsnl_alias[*]
        3 prsnl_alias_id = f8
        3 alias_pool_cd = f8
        3 alias_pool_disp = c40
        3 alias = c100
        3 prsnl_alias_type_cd = f8
        3 prsnl_alias_type_disp = c40
      2 positions[*]
        3 position_cd = f8
        3 position_disp = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
  FREE RECORD name_reply
  RECORD name_reply(
    1 prsnl_cnt = i4
    1 maxqual = i4
    1 more_exist_ind = i2
    1 context_ind = i2
    1 start_name = vc
    1 start_name_first = vc
    1 context_person_id = f8
    1 search_name_first = vc
    1 search_name_last = vc
    1 prsnl[*]
      2 person_id = f8
      2 name_last_key = c100
      2 name_first_key = c100
      2 prsnl_type_cd = f8
      2 name_full_formatted = c100
      2 password = c100
      2 email = c100
      2 physician_ind = i2
      2 position_cd = f8
      2 department_cd = f8
      2 free_text_ind = i2
      2 section_cd = f8
      2 contributor_system_cd = f8
      2 name_last = c200
      2 name_first = c200
      2 username = c50
      2 service[*]
        3 service_desc_id = f8
        3 service_desc_name = c40
      2 org[*]
        3 org_id = f8
        3 org_name = c40
      2 prsnl_alias[*]
        3 prsnl_alias_id = f8
        3 alias_pool_cd = f8
        3 alias_pool_disp = c40
        3 alias = c100
        3 prsnl_alias_type_cd = f8
        3 prsnl_alias_type_disp = c40
      2 positions[*]
        3 position_cd = f8
        3 position_disp = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ELSE
  RECORD request(
    1 max = i4
    1 alias = c200
    1 physician_ind = i2
    1 inactive_ind = i2
    1 group_id = f8
    1 organization_id = f8
    1 location_cd = f8
    1 priv[*]
      2 privilege = c12
    1 alias_type_cd = f8
    1 use_org_security_ind = i2
    1 orgs[*]
      2 org_id = f8
    1 context_ind = i2
    1 start_alias = vc
    1 context_alias_id = f8
    1 alias_type_list = vc
    1 return_orgs = i2
    1 auth_only_ind = i2
    1 provider_filter[*]
      2 filter_name = vc
      2 filter_data[*]
        3 data_id = f8
    1 return_services = i2
    1 return_aliases = i2
  ) WITH protect
  RECORD reply(
    1 prsnl_alias_cnt = i4
    1 more_exist_ind = i2
    1 context_ind = i2
    1 start_alias = vc
    1 context_alias_id = f8
    1 prsnl_alias[*]
      2 prsnl_alias_id = f8
      2 person_id = f8
      2 alias_pool_cd = f8
      2 prsnl_alias_type_cd = f8
      2 alias = c200
      2 prsnl_alias_sub_type_cd = f8
      2 check_digit = i4
      2 check_digit_method_cd = f8
      2 name_last_key = c100
      2 name_first_key = c100
      2 prsnl_type_cd = f8
      2 name_full_formatted = c100
      2 password = c100
      2 email = c100
      2 physician_ind = i2
      2 position_cd = f8
      2 department_cd = f8
      2 free_text_ind = i2
      2 section_cd = f8
      2 contributor_system_cd = f8
      2 name_last = c200
      2 name_first = c200
      2 username = c50
      2 service[*]
        3 service_desc_id = f8
        3 service_desc_name = c40
      2 org[*]
        3 org_id = f8
        3 org_name = c40
      2 other_prsnl_alias[*]
        3 prsnl_alias_id = f8
        3 alias_pool_cd = f8
        3 alias_pool_disp = c40
        3 alias = c100
        3 prsnl_alias_type_cd = f8
        3 prsnl_alias_type_disp = c40
      2 positions[*]
        3 position_cd = f8
        3 position_disp = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
  FREE RECORD alias_reply
  RECORD alias_reply(
    1 prsnl_alias_cnt = i4
    1 more_exist_ind = i2
    1 context_ind = i2
    1 start_alias = vc
    1 context_alias_id = f8
    1 prsnl_alias[*]
      2 prsnl_alias_id = f8
      2 person_id = f8
      2 alias_pool_cd = f8
      2 prsnl_alias_type_cd = f8
      2 alias = c200
      2 prsnl_alias_sub_type_cd = f8
      2 check_digit = i4
      2 check_digit_method_cd = f8
      2 name_last_key = c100
      2 name_first_key = c100
      2 prsnl_type_cd = f8
      2 name_full_formatted = c100
      2 password = c100
      2 email = c100
      2 physician_ind = i2
      2 position_cd = f8
      2 department_cd = f8
      2 free_text_ind = i2
      2 section_cd = f8
      2 contributor_system_cd = f8
      2 name_last = c200
      2 name_first = c200
      2 username = c50
      2 service[*]
        3 service_desc_id = f8
        3 service_desc_name = c40
      2 org[*]
        3 org_id = f8
        3 org_name = c40
      2 other_prsnl_alias[*]
        3 prsnl_alias_id = f8
        3 alias_pool_cd = f8
        3 alias_pool_disp = c40
        3 alias = c100
        3 prsnl_alias_type_cd = f8
        3 prsnl_alias_type_disp = c40
      2 positions[*]
        3 position_cd = f8
        3 position_disp = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info i
  WHERE i.info_name="SEC_ORG_RELTN"
   AND i.info_domain="SECURITY"
   AND i.info_number > 0.0
  DETAIL
   org_security_ind = true
  WITH nocounter
 ;end select
 IF (prmpt_search_by=search_by_name)
  SET request->name_last_key = prmpt_last_name
  SET request->name_first_key = prmpt_first_name
  SET request->suffix_str = prmpt_suffix
  SET request->title_str = prmpt_title
  SET request->physician_ind = prmpt_view_physician_only
  SET request->max = prmpt_max
  SET request->return_aliases = true
  SET request->return_orgs = true
  SET request->return_services = true
  SET request->use_org_security_ind = org_security_ind
  EXECUTE ocx_get_providers_by_name  WITH replace("REQUEST",request), replace("REPLY",reply)
  SET stat = moverec(reply,name_reply)
 ELSE
  SET request->alias = prmpt_alias
  SET request->alias_type_cd = prmpt_alias_type
  SET request->physician_ind = prmpt_view_physician_only
  SET request->max = prmpt_max
  SET request->return_aliases = true
  SET request->return_orgs = true
  SET request->return_services = true
  SET request->use_org_security_ind = org_security_ind
  EXECUTE ocx_get_providers_by_alias  WITH replace("REQUEST",request), replace("REPLY",reply)
  SET stat = moverec(reply,alias_reply)
 ENDIF
 IF (debug)
  CALL echorecord(request)
  CALL echorecord(reply)
 ENDIF
 FREE RECORD reply
 FREE RECORD request
 IF (validate(name_reply->prsnl_cnt,0)=0
  AND validate(alias_reply->prsnl_alias_cnt,0)=0)
  GO TO exit_script
 ENDIF
 EXECUTE ccl_prompt_api_dataset "dataset"
 IF (prmpt_search_by=search_by_name)
  SELECT INTO "nl:"
   name_order = build(name_reply->prsnl[d1.seq].name_last_key," ",name_reply->prsnl[d1.seq].
    name_first_key," ",name_reply->prsnl[d1.seq].person_id)
   FROM (dummyt d1  WITH seq = size(name_reply->prsnl,5))
   PLAN (d1)
   ORDER BY name_order
   HEAD REPORT
    pcnt = 0, x = 0, stat = makedataset(10),
    vpid = addrealfield("PID","Person ID",1), vname = addstringfield("Name","Name",1,50), vorg =
    addstringfield("Organizations","Organizations",1,50),
    vserv = addstringfield("Services","Services",1,50), valias = addstringfield("Aliases","Aliases",1,
     50), vpos = addstringfield("Positions","Positions",1,50)
   HEAD name_order
    pcnt = getnextrecord(0), stat = setrealfield(pcnt,vpid,name_reply->prsnl[d1.seq].person_id), stat
     = setstringfield(pcnt,vname,name_reply->prsnl[d1.seq].name_full_formatted),
    orgs_string = ""
    FOR (x = 1 TO size(name_reply->prsnl[d1.seq].org,5))
      orgs_string =
      IF (textlen(trim(orgs_string,3))=0) trim(name_reply->prsnl[d1.seq].org[x].org_name,3)
      ELSE build2(orgs_string,"; ",trim(name_reply->prsnl[d1.seq].org[x].org_name,3))
      ENDIF
    ENDFOR
    stat = setstringfield(pcnt,vorg,trim(orgs_string,3)), services_string = ""
    FOR (x = 1 TO size(name_reply->prsnl[d1.seq].service,5))
      services_string =
      IF (textlen(trim(services_string,3))=0) trim(name_reply->prsnl[d1.seq].service[x].
        service_desc_name,3)
      ELSE build2(services_string,"; ",trim(name_reply->prsnl[d1.seq].service[x].service_desc_name,3)
        )
      ENDIF
    ENDFOR
    stat = setstringfield(pcnt,vserv,trim(services_string,3)), prsnl_alias_string = ""
    FOR (x = 1 TO size(name_reply->prsnl[d1.seq].prsnl_alias,5))
      prsnl_alias_string =
      IF (textlen(trim(prsnl_alias_string,3))=0) trim(name_reply->prsnl[d1.seq].prsnl_alias[x].alias,
        3)
      ELSE build2(prsnl_alias_string,"; ",trim(name_reply->prsnl[d1.seq].prsnl_alias[x].alias,3))
      ENDIF
    ENDFOR
    stat = setstringfield(pcnt,valias,trim(prsnl_alias_string,3)), positions_string = ""
    FOR (x = 1 TO size(name_reply->prsnl[d1.seq].positions,5))
      positions_string =
      IF (textlen(trim(positions_string,3))=0) trim(name_reply->prsnl[d1.seq].positions[x].
        position_disp,3)
      ELSE build2(positions_string,"; ",trim(name_reply->prsnl[d1.seq].positions[x].position_disp,3))
      ENDIF
    ENDFOR
    stat = setstringfield(pcnt,vpos,trim(positions_string,3))
   DETAIL
    null
   FOOT  name_order
    null
   FOOT REPORT
    stat = closedataset(0)
   WITH check
  ;end select
  IF (debug)
   CALL echorecord(name_reply)
  ENDIF
 ELSE
  SELECT INTO "nl:"
   alias = alias_reply->prsnl_alias[d1.seq].alias, id = alias_reply->prsnl_alias[d1.seq].
   prsnl_alias_id
   FROM (dummyt d1  WITH seq = size(alias_reply->prsnl_alias,5))
   PLAN (d1
    WHERE d1.seq > 1)
   ORDER BY alias, id
   HEAD REPORT
    pcnt = 0, x = 0, stat = makedataset(10),
    vpid = addrealfield("PID","Person ID",1), vpalias = addstringfield("Alias","Alias",1,25), vname
     = addstringfield("Name","Name",1,50),
    vorg = addstringfield("Organizations","Organizations",1,50), vserv = addstringfield("Services",
     "Services",1,50), valias = addstringfield("Aliases","Aliases",1,50),
    vpos = addstringfield("Positions","Positions",1,50)
   HEAD id
    pcnt = getnextrecord(0), stat = setrealfield(pcnt,vpid,alias_reply->prsnl_alias[d1.seq].person_id
     ), stat = setstringfield(pcnt,vpalias,alias_reply->prsnl_alias[d1.seq].alias),
    stat = setstringfield(pcnt,vname,alias_reply->prsnl_alias[d1.seq].name_full_formatted),
    orgs_string = ""
    FOR (x = 1 TO size(alias_reply->prsnl_alias[d1.seq].org,5))
      orgs_string =
      IF (textlen(trim(orgs_string,3))=0) trim(alias_reply->prsnl_alias[d1.seq].org[x].org_name,3)
      ELSE build2(orgs_string,"; ",trim(alias_reply->prsnl_alias[d1.seq].org[x].org_name,3))
      ENDIF
    ENDFOR
    stat = setstringfield(pcnt,vorg,trim(orgs_string,3)), services_string = ""
    FOR (x = 1 TO size(alias_reply->prsnl_alias[d1.seq].service,5))
      services_string =
      IF (textlen(trim(services_string,3))=0) trim(alias_reply->prsnl_alias[d1.seq].service[x].
        service_desc_name,3)
      ELSE build2(services_string,"; ",trim(alias_reply->prsnl_alias[d1.seq].service[x].
         service_desc_name,3))
      ENDIF
    ENDFOR
    stat = setstringfield(pcnt,vserv,trim(services_string,3)), prsnl_alias_string = ""
    FOR (x = 1 TO size(alias_reply->prsnl_alias[d1.seq].other_prsnl_alias,5))
      prsnl_alias_string =
      IF (textlen(trim(prsnl_alias_string,3))=0) trim(alias_reply->prsnl_alias[d1.seq].
        other_prsnl_alias[x].alias,3)
      ELSE build2(prsnl_alias_string,"; ",trim(alias_reply->prsnl_alias[d1.seq].other_prsnl_alias[x].
         alias,3))
      ENDIF
    ENDFOR
    stat = setstringfield(pcnt,valias,trim(prsnl_alias_string,3)), positions_string = ""
    FOR (x = 1 TO size(alias_reply->prsnl_alias[d1.seq].positions,5))
      positions_string =
      IF (textlen(trim(positions_string,3))=0) trim(alias_reply->prsnl_alias[d1.seq].positions[x].
        position_disp,3)
      ELSE build2(positions_string,"; ",trim(alias_reply->prsnl_alias[d1.seq].positions[x].
         position_disp,3))
      ENDIF
    ENDFOR
    stat = setstringfield(pcnt,vpos,trim(positions_string,3))
   DETAIL
    null
   FOOT  id
    null
   FOOT REPORT
    stat = closedataset(0)
   WITH check
  ;end select
  IF (debug)
   CALL echorecord(alias_reply)
  ENDIF
 ENDIF
#exit_script
 IF (debug)
  CALL echo(build2("PRMPT_LAST_NAME: ",prmpt_last_name))
  CALL echo(build2("PRMPT_FIRST_NAME: ",prmpt_first_name))
  CALL echo(build2("PRMPT_SUFFIX: ",prmpt_suffix))
  CALL echo(build2("PRMPT_TITLE: ",prmpt_title))
  CALL echo(build2("PRMPT_ALIAS: ",prmpt_alias))
  CALL echo(build2("PRMPT_ALIAS_TYPE: ",prmpt_alias_type))
  CALL echo(build2("PRMPT_VIEW_PHYSICIAN_ONLY: ",prmpt_view_physician_only))
  CALL echo(build2("PRMPT_MAX: ",prmpt_max))
  CALL echo(build2("PRMPT_SEARCH_BY: ",prmpt_search_by))
  CALL echorecord(request)
  CALL echorecord(reply)
 ENDIF
 SET last_mod = "002 CJ012163 03/19/2013"
END GO
