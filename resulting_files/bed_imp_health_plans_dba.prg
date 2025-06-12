CREATE PROGRAM bed_imp_health_plans:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET health_plan
 RECORD health_plan(
   1 health_plan_cnt = i4
   1 list[*]
     2 health_plan_name = vc
     2 health_plan_id = f8
     2 health_plan_type = vc
     2 health_plan_type_cd = f8
     2 financial_class = vc
     2 financial_class_cd = f8
     2 insurance_org_id = f8
     2 insurance_name = vc
     2 address_cnt = i4
     2 phone_num_cnt = i4
     2 alias_cnt = i4
     2 sponsor_cnt = i4
     2 facility_cnt = i4
     2 error_string = vc
     2 action_flag = i2
     2 row_num = i4
     2 cons_add_covrg_allow_ind = i2
     2 cons_mod_covrg_deny_ind = i2
     2 address[*]
       3 address_id = f8
       3 address_type_name = vc
       3 address_type_cd = f8
       3 street_addr = vc
       3 street_addr2 = vc
       3 street_addr3 = vc
       3 street_addr4 = vc
       3 city = vc
       3 state = vc
       3 state_cd = f8
       3 zipcode = vc
       3 country = vc
       3 country_cd = f8
       3 error_string = vc
       3 action_flag = i2
       3 row_num = i4
       3 contact_name = vc
     2 phone_num[*]
       3 phone_id = f8
       3 phone_type_name = vc
       3 phone_type_cd = f8
       3 phone_number = vc
       3 phone_extension = vc
       3 error_string = vc
       3 action_flag = i2
       3 row_num = i4
       3 contact_name = vc
     2 alias[*]
       3 alias_id = f8
       3 alias_type = vc
       3 alias_type_cd = f8
       3 alias_pool_name = vc
       3 alias_pool_cd = f8
       3 alias = vc
       3 error_string = vc
       3 action_flag = i2
       3 row_num = i4
     2 sponsor[*]
       3 sponsor_name = vc
       3 sponsor_reltn = f8
       3 organization_id = f8
       3 error_string = vc
       3 action_flag = i2
       3 row_num = i4
     2 facility[*]
       3 facility_name = vc
       3 organization_id = f8
       3 error_string = vc
       3 action_flag = i2
       3 row_num = i4
     2 logical_domain_id = f8
     2 priority_ranking_nbr = vc
 )
 FREE SET addr
 RECORD addr(
   1 qual[*]
     2 address_type_cd = f8
     2 street_addr1 = vc
     2 street_addr2 = vc
     2 street_addr3 = vc
     2 street_addr4 = vc
     2 city = vc
     2 state = vc
     2 state_cd = f8
     2 zipcode = vc
     2 zipcode_key = vc
     2 county = vc
     2 county_cd = f8
     2 country = vc
     2 country_cd = f8
     2 contact_name = vc
     2 comment_txt = vc
     2 postal_barcode_info = vc
     2 mail_stop = vc
     2 operation_hours = vc
     2 sponsor_reltn = f8
 )
 FREE SET phone
 RECORD phone(
   1 qual[*]
     2 phone_type_cd = f8
     2 phone_format_cd = f8
     2 phone_num = vc
     2 phone_type_seq = i4
     2 description = vc
     2 contact = vc
     2 call_instruction = vc
     2 extension = vc
     2 paging_code = vc
     2 sponsor_reltn = f8
 )
 FREE SET str_data
 RECORD str_data(
   1 str_qual = c1
 )
#1000_initialize
 SET write_mode = 0
 IF ((tempreq->insert_ind="Y"))
  SET write_mode = 1
 ENDIF
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET error_flag = "Y"
 DECLARE error_msg = vc
 DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE end_dt_tm = dq8 WITH constant(cnvtdatetime("31-dec-2100 00:00:00"))
 SET active_cd = get_code_value(48,"ACTIVE")
 SET auth_cd = get_code_value(8,"AUTH")
 SET ins_reltn_cd = get_code_value(370,"CARRIER")
 SET emp_reltn_cd = get_code_value(370,"SPONSOR")
 SET ins_cd = get_code_value(278,"INSCO")
 SET emp_cd = get_code_value(278,"EMPLOYER")
 SET facility_cd = get_code_value(278,"FACILITY")
 SET health_plan_cd = get_code_value(397,"HEALTHPLAN")
 SET freetext_cd = get_code_value(281,"FREETEXT")
 SET filter_type_cd = get_code_value(30620,"HEALTHPLAN")
 SET service_type_cd = get_code_value(27137,"MEDICAL")
 SET numrows = size(requestin->list_0,5)
 SET stat = alterlist(health_plan->list,0)
 SET health_plan->health_plan_cnt = 0
 IF (numrows=0)
  SET error_msg = "No rows to process"
  GO TO exit_script
 ENDIF
 SET logical_domain_column_ind = 0
 IF (validate(requestin->list_0[1].logical_domain_id))
  SET logical_domain_column_ind = 1
 ENDIF
 SET data_partition_ind = 0
 RANGE OF h IS health_plan
 SET data_partition_ind = validate(h.logical_domain_id)
 FREE RANGE h
 SET address_contact_column_ind = 0
 IF (validate(requestin->list_0[1].address_contact))
  SET address_contact_column_ind = 1
 ENDIF
 SET phone_contact_column_ind = 0
 IF (validate(requestin->list_0[1].phone_contact))
  SET phone_contact_column_ind = 1
 ENDIF
 SET hp_alias_type_column_ind = 0
 IF (validate(requestin->list_0[1].health_plan_alias_type))
  SET hp_alias_type_column_ind = 1
 ENDIF
 SET does_ph_ext_column_exists = 0
 IF (validate(requestin->list_0[1].phone_ext))
  SET does_ph_ext_column_exists = 1
 ENDIF
 CALL echo("ready to start import")
 SET title = validate(log_title_set,"Health Plan Load Log")
 SET name = validate(log_name_set,"bed_health_plans.log")
 SET status = validate(log_col_set,"STATUS")
 SET alt_mode = validate(alt_mode_set,0)
 SET alt_detail = validate(alt_detail_set,0)
 CALL logstart(title,name)
 FOR (i = 1 TO numrows)
   SET exists_id = 0
   FOR (ii = 1 TO health_plan->health_plan_cnt)
     IF (cnvtupper(health_plan->list[ii].health_plan_name)=cnvtupper(requestin->list_0[i].
      health_plan_name)
      AND cnvtupper(health_plan->list[ii].insurance_name)=cnvtupper(requestin->list_0[i].
      insurance_comp))
      SET exists_id = ii
     ENDIF
   ENDFOR
   IF (exists_id=0)
    SET health_plan->health_plan_cnt = (health_plan->health_plan_cnt+ 1)
    SET stat = alterlist(health_plan->list,health_plan->health_plan_cnt)
    SET exists_id = health_plan->health_plan_cnt
    SET health_plan->list[exists_id].row_num = i
    SET health_plan->list[exists_id].health_plan_name = requestin->list_0[i].health_plan_name
    SET health_plan->list[exists_id].health_plan_type = requestin->list_0[i].health_plan_type
    SET health_plan->list[exists_id].financial_class = requestin->list_0[i].financial_class
    SET health_plan->list[exists_id].cons_add_covrg_allow_ind = cnvtint(requestin->list_0[i].
     cons_add_covrg_allow_ind)
    SET health_plan->list[exists_id].cons_mod_covrg_deny_ind = cnvtint(requestin->list_0[i].
     cons_mod_covrg_deny_ind)
    IF (logical_domain_column_ind=1)
     SET health_plan->list[exists_id].logical_domain_id = cnvtreal(requestin->list_0[i].
      logical_domain_id)
    ENDIF
    SET health_plan->list[exists_id].priority_ranking_nbr = requestin->list_0[i].priority_ranking_nbr
    SET health_plan->list[exists_id].health_plan_type_cd = 0
    SET health_plan->list[exists_id].health_plan_type_cd = get_cv_by_disp(367,health_plan->list[
     exists_id].health_plan_type)
    IF ((health_plan->list[exists_id].health_plan_type_cd=0))
     SET health_plan->list[exists_id].action_flag = - (1)
     SET health_plan->list[exists_id].error_string = "Plan Type does not exist"
    ENDIF
    SET health_plan->list[exists_id].financial_class_cd = 0
    SET health_plan->list[exists_id].financial_class_cd = get_cv_by_disp(354,health_plan->list[
     exists_id].financial_class)
    IF ((health_plan->list[exists_id].financial_class_cd=0)
     AND (requestin->list_0[i].financial_class != ""))
     SET health_plan->list[exists_id].action_flag = - (1)
     SET health_plan->list[exists_id].error_string = "Financial C does not exist"
    ENDIF
    SET health_plan->list[exists_id].insurance_name = requestin->list_0[i].insurance_comp
    SELECT INTO "NL:"
     FROM organization o,
      org_type_reltn ot
     PLAN (o
      WHERE o.org_name_key=cnvtalphanum(cnvtupper(health_plan->list[exists_id].insurance_name))
       AND o.active_ind=1
       AND o.data_status_cd=auth_cd
       AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND o.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
      JOIN (ot
      WHERE ot.organization_id=o.organization_id
       AND ot.active_ind=1
       AND ot.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND ot.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
       AND ot.org_type_cd=ins_cd)
     DETAIL
      health_plan->list[exists_id].insurance_org_id = o.organization_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET health_plan->list[exists_id].action_flag = - (1)
     SET health_plan->list[exists_id].error_string = "Invalid Insurance"
    ENDIF
    DECLARE plan_key = vc WITH noconstant(cnvtalphanum(cnvtupper(health_plan->list[exists_id].
       health_plan_name)))
    IF ((health_plan->list[exists_id].action_flag != - (1)))
     SET temp_active = 0
     SELECT INTO "NL:"
      FROM health_plan hp,
       org_plan_reltn opr
      PLAN (hp
       WHERE hp.plan_name_key=plan_key
        AND (hp.financial_class_cd=health_plan->list[exists_id].financial_class_cd)
        AND (hp.plan_type_cd=health_plan->list[exists_id].health_plan_type_cd))
       JOIN (opr
       WHERE opr.health_plan_id=hp.health_plan_id
        AND (opr.organization_id=health_plan->list[exists_id].insurance_org_id)
        AND opr.org_plan_reltn_cd=ins_reltn_cd
        AND opr.active_ind=1
        AND opr.data_status_cd=auth_cd)
      DETAIL
       IF (temp_active=0)
        health_plan->list[exists_id].health_plan_id = hp.health_plan_id, health_plan->list[exists_id]
        .action_flag = 2
       ENDIF
       IF (opr.active_ind=1)
        temp_active = 1
       ENDIF
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET health_plan->list[exists_id].action_flag = 1
     ENDIF
    ENDIF
   ENDIF
   IF (hp_alias_type_column_ind=1
    AND trim(requestin->list_0[i].alias_pool) != ""
    AND trim(requestin->list_0[i].alias) != "")
    SET health_plan->list[exists_id].alias_cnt = (health_plan->list[exists_id].alias_cnt+ 1)
    SET stat = alterlist(health_plan->list[exists_id].alias,health_plan->list[exists_id].alias_cnt)
    SET health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].row_num = i
    SET health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].alias = requestin
    ->list_0[i].alias
    SET health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].alias_type =
    requestin->list_0[i].health_plan_alias_type
    SET health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].alias_type_cd = 0
    SET health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].alias_type_cd =
    get_cv_by_disp(27121,requestin->list_0[i].health_plan_alias_type)
    IF ((health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].alias_type_cd=0))
     SET health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].action_flag = - (
     1)
     SET health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].error_string =
     "Invalid alias type"
    ENDIF
    FOR (ii = 1 TO health_plan->list[exists_id].alias_cnt)
      IF (cnvtupper(health_plan->list[exists_id].alias[ii].alias_pool_name)=cnvtupper(requestin->
       list_0[i].alias_pool)
       AND cnvtupper(health_plan->list[exists_id].alias[ii].alias)=cnvtupper(requestin->list_0[i].
       alias))
       SET health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].action_flag =
       - (1)
       SET health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].error_string =
       "Alias already defined"
      ENDIF
    ENDFOR
    SET health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].alias_pool_name =
    requestin->list_0[i].alias_pool
    SET health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].alias_pool_cd = 0
    SET health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].alias_pool_cd =
    get_cv_by_disp(263,health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].
     alias_pool_name)
    IF ((health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].alias_pool_cd=0))
     SET health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].action_flag = - (
     1)
     SET health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].error_string =
     "Alias Pool does not exist"
    ENDIF
    IF ((health_plan->list[exists_id].action_flag < 0))
     SET health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].action_flag = - (
     1)
     SET health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].error_string =
     "Health Plan Error"
    ENDIF
    IF ((health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].alias_type_cd > 0
    )
     AND (health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].alias_pool_cd >
    0))
     SET org_count = 0
     SELECT INTO "NL:"
      FROM org_alias_pool_reltn oapr
      PLAN (oapr
       WHERE (oapr.alias_entity_alias_type_cd=health_plan->list[exists_id].alias[health_plan->list[
       exists_id].alias_cnt].alias_type_cd)
        AND (oapr.alias_pool_cd=health_plan->list[exists_id].alias[health_plan->list[exists_id].
       alias_cnt].alias_pool_cd))
      DETAIL
       org_count = (org_count+ 1)
      WITH nocounter
     ;end select
     IF (org_count=0)
      SET health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].action_flag =
      - (1)
      SET health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].error_string =
      "No org associated to alias pool"
     ENDIF
    ENDIF
    IF ((health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].action_flag !=
    - (1)))
     SET health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].action_flag = 1
     IF ((health_plan->list[exists_id].health_plan_id > 0))
      SET temp_active = 0
      SELECT INTO "NL:"
       FROM health_plan_alias hpa
       PLAN (hpa
        WHERE (hpa.health_plan_id=health_plan->list[exists_id].health_plan_id)
         AND (hpa.plan_alias_type_cd=health_plan->list[exists_id].alias[health_plan->list[exists_id].
        alias_cnt].alias_type_cd)
         AND (hpa.alias_pool_cd=health_plan->list[exists_id].alias[health_plan->list[exists_id].
        alias_cnt].alias_pool_cd)
         AND cnvtupper(hpa.alias) != cnvtupper(health_plan->list[exists_id].alias[health_plan->list[
         exists_id].alias_cnt].alias))
       DETAIL
        IF (temp_active=0)
         health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].action_flag = 2,
         health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].alias_id = hpa
         .health_plan_alias_id
        ENDIF
        IF (hpa.active_ind=1)
         temp_active = 1
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
   ELSEIF (trim(requestin->list_0[i].alias_pool)="")
    SET health_plan->list[exists_id].alias_cnt = (health_plan->list[exists_id].alias_cnt+ 1)
    SET stat = alterlist(health_plan->list[exists_id].alias,health_plan->list[exists_id].alias_cnt)
    SET health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].row_num = i
    SET health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].action_flag = - (1
    )
    SET health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].error_string =
    "Alias Pool does not exist"
   ELSEIF (trim(requestin->list_0[i].alias)="")
    SET health_plan->list[exists_id].alias_cnt = (health_plan->list[exists_id].alias_cnt+ 1)
    SET stat = alterlist(health_plan->list[exists_id].alias,health_plan->list[exists_id].alias_cnt)
    SET health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].row_num = i
    SET health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].action_flag = - (1
    )
    SET health_plan->list[exists_id].alias[health_plan->list[exists_id].alias_cnt].error_string =
    "Alias not entered"
   ENDIF
   IF (trim(requestin->list_0[i].address_type) != "")
    SET health_plan->list[exists_id].address_cnt = (health_plan->list[exists_id].address_cnt+ 1)
    SET stat = alterlist(health_plan->list[exists_id].address,health_plan->list[exists_id].
     address_cnt)
    SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].row_num = i
    SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].street_addr =
    requestin->list_0[i].street_addr
    SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].street_addr2
     = requestin->list_0[i].street_addr2
    SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].street_addr3
     = requestin->list_0[i].street_addr3
    SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].street_addr4
     = requestin->list_0[i].street_addr4
    SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].city =
    requestin->list_0[i].city
    SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].state =
    requestin->list_0[i].state
    SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].zipcode =
    requestin->list_0[i].zipcode
    SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].country =
    requestin->list_0[i].country
    IF (address_contact_column_ind=1)
     SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].contact_name
      = requestin->list_0[i].address_contact
    ENDIF
    FOR (ii = 1 TO health_plan->list[exists_id].address_cnt)
      IF (cnvtupper(health_plan->list[exists_id].address[ii].address_type_name)=cnvtupper(requestin->
       list_0[i].address_type)
       AND cnvtupper(health_plan->list[exists_id].address[ii].street_addr)=cnvtupper(requestin->
       list_0[i].street_addr))
       SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].action_flag
        = - (1)
       SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].
       error_string = "Address already defined"
      ENDIF
    ENDFOR
    SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].
    address_type_name = requestin->list_0[i].address_type
    SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].
    address_type_cd = 0
    SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].
    address_type_cd = get_cv_by_disp(212,health_plan->list[exists_id].address[health_plan->list[
     exists_id].address_cnt].address_type_name)
    SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].state_cd = 0
    SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].country_cd = 0
    SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].state_cd =
    get_cv_by_disp(62,health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].
     state)
    SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].country_cd =
    get_cv_by_disp(15,health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].
     country)
    IF ((health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].state_cd=0)
     AND (health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].state != "")
    )
     SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].action_flag
      = - (1)
     SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].error_string
      = "Invalid State"
    ENDIF
    IF ((health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].country_cd=0)
     AND (health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].country !=
    ""))
     SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].action_flag
      = - (1)
     SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].error_string
      = "Invalid Country"
    ENDIF
    IF ((health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].
    address_type_cd=0))
     SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].action_flag
      = - (1)
     SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].error_string
      = "Invalid Address Type"
    ENDIF
    IF ((health_plan->list[exists_id].action_flag < 0))
     SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].action_flag
      = - (1)
     SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].error_string
      = "Health Plan Error"
    ENDIF
    IF ((health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].action_flag
     != - (1)))
     SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].action_flag
      = 1
     IF ((health_plan->list[exists_id].health_plan_id > 0))
      SET addr_id = 0
      SET a_cnt = 0
      SET address_changed = 0
      SELECT INTO "NL:"
       FROM address a
       WHERE (a.parent_entity_id=health_plan->list[exists_id].health_plan_id)
        AND a.parent_entity_name="HEALTH_PLAN"
        AND (a.address_type_cd=health_plan->list[exists_id].address[health_plan->list[exists_id].
       address_cnt].address_type_cd)
        AND (a.street_addr=health_plan->list[exists_id].address[health_plan->list[exists_id].
       address_cnt].street_addr)
        AND a.active_ind=1
       DETAIL
        a_cnt = (a_cnt+ 1), addr_id = a.address_id
        IF (cnvtupper(a.street_addr2) != cnvtupper(health_plan->list[exists_id].address[health_plan->
         list[exists_id].address_cnt].street_addr2))
         address_changed = 1
        ELSEIF (cnvtupper(a.street_addr3) != cnvtupper(health_plan->list[exists_id].address[
         health_plan->list[exists_id].address_cnt].street_addr3))
         address_changed = 1
        ELSEIF (cnvtupper(a.street_addr4) != cnvtupper(health_plan->list[exists_id].address[
         health_plan->list[exists_id].address_cnt].street_addr4))
         address_changed = 1
        ELSEIF (cnvtupper(a.city) != cnvtupper(health_plan->list[exists_id].address[health_plan->
         list[exists_id].address_cnt].city))
         address_changed = 1
        ELSEIF (cnvtupper(a.state) != cnvtupper(health_plan->list[exists_id].address[health_plan->
         list[exists_id].address_cnt].state))
         address_changed = 1
        ELSEIF (cnvtupper(a.zipcode) != cnvtupper(health_plan->list[exists_id].address[health_plan->
         list[exists_id].address_cnt].zipcode))
         address_changed = 1
        ELSEIF (cnvtupper(a.country) != cnvtupper(health_plan->list[exists_id].address[health_plan->
         list[exists_id].address_cnt].country))
         address_changed = 1
        ENDIF
       WITH nocounter
      ;end select
      IF (a_cnt=1)
       IF (address_changed=1)
        SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].
        action_flag = 2
        SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].address_id
         = addr_id
       ELSE
        SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].
        action_flag = - (1)
        SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].
        error_string = "Address already defined"
       ENDIF
      ELSEIF (a_cnt > 1)
       SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].action_flag
        = - (1)
       SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].
       error_string = "Address found twice"
      ENDIF
     ENDIF
    ENDIF
   ELSEIF (trim(requestin->list_0[i].address_type)="")
    SET health_plan->list[exists_id].address_cnt = (health_plan->list[exists_id].address_cnt+ 1)
    SET stat = alterlist(health_plan->list[exists_id].address,health_plan->list[exists_id].
     address_cnt)
    SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].row_num = i
    SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].action_flag =
    - (1)
    SET health_plan->list[exists_id].address[health_plan->list[exists_id].address_cnt].error_string
     = "Invalid address type"
   ENDIF
   IF (trim(requestin->list_0[i].phone_type) != ""
    AND trim(requestin->list_0[i].phone_num) != "")
    SET health_plan->list[exists_id].phone_num_cnt = (health_plan->list[exists_id].phone_num_cnt+ 1)
    SET stat = alterlist(health_plan->list[exists_id].phone_num,health_plan->list[exists_id].
     phone_num_cnt)
    SET health_plan->list[exists_id].phone_num[health_plan->list[exists_id].phone_num_cnt].row_num =
    i
    FOR (ii = 1 TO health_plan->list[exists_id].phone_num_cnt)
      IF (cnvtupper(health_plan->list[exists_id].phone_num[ii].phone_type_name)=cnvtupper(requestin->
       list_0[i].phone_type)
       AND cnvtupper(health_plan->list[exists_id].phone_num[ii].phone_number)=cnvtupper(requestin->
       list_0[i].phone_num))
       SET health_plan->list[exists_id].phone_num[health_plan->list[exists_id].phone_num_cnt].
       action_flag = - (1)
       SET health_plan->list[exists_id].phone_num[health_plan->list[exists_id].phone_num_cnt].
       error_string = "Phone Number already defined"
      ENDIF
    ENDFOR
    SET health_plan->list[exists_id].phone_num[health_plan->list[exists_id].phone_num_cnt].
    phone_type_name = requestin->list_0[i].phone_type
    SET health_plan->list[exists_id].phone_num[health_plan->list[exists_id].phone_num_cnt].
    phone_number = cnvtalphanum(requestin->list_0[i].phone_num,1)
    IF (phone_contact_column_ind=1)
     SET health_plan->list[exists_id].phone_num[health_plan->list[exists_id].phone_num_cnt].
     contact_name = requestin->list_0[i].phone_contact
    ENDIF
    SET health_plan->list[exists_id].phone_num[health_plan->list[exists_id].phone_num_cnt].
    phone_type_cd = 0
    SET health_plan->list[exists_id].phone_num[health_plan->list[exists_id].phone_num_cnt].
    phone_type_cd = get_cv_by_disp(43,health_plan->list[exists_id].phone_num[health_plan->list[
     exists_id].phone_num_cnt].phone_type_name)
    IF ((health_plan->list[exists_id].phone_num[health_plan->list[exists_id].phone_num_cnt].
    phone_type_cd=0))
     SET health_plan->list[exists_id].phone_num[health_plan->list[exists_id].phone_num_cnt].
     action_flag = - (1)
     SET health_plan->list[exists_id].phone_num[health_plan->list[exists_id].phone_num_cnt].
     error_string = "Invalid Phone Type"
    ENDIF
    IF (cnvtint(health_plan->list[exists_id].phone_num[health_plan->list[exists_id].phone_num_cnt].
     phone_number)=0)
     SET health_plan->list[exists_id].phone_num[health_plan->list[exists_id].phone_num_cnt].
     action_flag = - (1)
     SET health_plan->list[exists_id].phone_num[health_plan->list[exists_id].phone_num_cnt].
     error_string = "Invalid Phone Number found"
    ELSEIF (cnvtint(health_plan->list[exists_id].phone_num[health_plan->list[exists_id].phone_num_cnt
     ].phone_number) > 0
     AND cnvtint(requestin->list_0[i].phone_num) <= 0)
     SET health_plan->list[exists_id].phone_num[health_plan->list[exists_id].phone_num_cnt].
     error_string = "Characters found in phone num"
    ENDIF
    IF (does_ph_ext_column_exists=1)
     SET phone_ext_empty_ind = 0
     IF (trim(requestin->list_0[i].phone_ext) != "")
      SET health_plan->list[exists_id].phone_num[health_plan->list[exists_id].phone_num_cnt].
      phone_extension = cnvtalphanum(requestin->list_0[i].phone_ext,1)
      IF (cnvtint(health_plan->list[exists_id].phone_num[health_plan->list[exists_id].phone_num_cnt].
       phone_extension) > 0
       AND cnvtint(requestin->list_0[i].phone_ext) <= 0)
       SET health_plan->list[exists_id].phone_num[health_plan->list[exists_id].phone_num_cnt].
       error_string = "Characters found in phone ext"
      ELSEIF (cnvtint(health_plan->list[exists_id].phone_num[health_plan->list[exists_id].
       phone_num_cnt].phone_extension) <= 0)
       SET health_plan->list[exists_id].phone_num[health_plan->list[exists_id].phone_num_cnt].
       error_string = "Invalid Phone Extension"
      ENDIF
     ELSE
      SET phone_ext_empty_ind = 1
     ENDIF
    ENDIF
    IF ((health_plan->list[exists_id].action_flag < 0))
     SET health_plan->list[exists_id].phone_num[health_plan->list[exists_id].phone_num_cnt].
     action_flag = - (1)
     SET health_plan->list[exists_id].phone_num[health_plan->list[exists_id].phone_num_cnt].
     error_string = "Health Plan Error"
    ENDIF
    IF ((health_plan->list[exists_id].phone_num[health_plan->list[exists_id].phone_num_cnt].
    action_flag != - (1)))
     SET health_plan->list[exists_id].phone_num[health_plan->list[exists_id].phone_num_cnt].
     action_flag = 1
     IF ((health_plan->list[exists_id].health_plan_id > 0))
      SET p_cnt = 0
      SET phn_id = 0
      SET phone_changed = 0
      SET phone_extension_changed = 0
      SELECT INTO "NL:"
       FROM phone p
       WHERE (p.phone_type_cd=health_plan->list[exists_id].phone_num[health_plan->list[exists_id].
       phone_num_cnt].phone_type_cd)
        AND (p.phone_num=health_plan->list[exists_id].phone_num[health_plan->list[exists_id].
       phone_num_cnt].phone_number)
        AND (p.parent_entity_id=health_plan->list[exists_id].health_plan_id)
        AND p.parent_entity_name="HEALTH_PLAN"
        AND p.active_ind=1
       DETAIL
        p_cnt = (p_cnt+ 1), phn_id = p.phone_id
        IF (phone_contact_column_ind=1
         AND cnvtupper(p.contact) != cnvtupper(health_plan->list[exists_id].phone_num[health_plan->
         list[exists_id].phone_num_cnt].contact_name))
         phone_changed = 1
        ENDIF
        IF (does_ph_ext_column_exists=1
         AND (cnvtupper(p.extension) != health_plan->list[exists_id].phone_num[health_plan->list[
        exists_id].phone_num_cnt].phone_extension)
         AND ((cnvtint(health_plan->list[exists_id].phone_num[health_plan->list[exists_id].
         phone_num_cnt].phone_extension) > 0) OR (phone_ext_empty_ind=1)) )
         phone_extension_changed = 1
        ENDIF
       WITH nocounter
      ;end select
      IF (p_cnt=1)
       IF (((phone_changed=1) OR (phone_extension_changed=1)) )
        SET health_plan->list[exists_id].phone_num[health_plan->list[exists_id].phone_num_cnt].
        action_flag = 2
        SET health_plan->list[exists_id].phone_num[health_plan->list[exists_id].phone_num_cnt].
        phone_id = phn_id
       ELSE
        SET health_plan->list[exists_id].phone_num[health_plan->list[exists_id].phone_num_cnt].
        action_flag = - (1)
        SET health_plan->list[exists_id].phone_num[health_plan->list[exists_id].phone_num_cnt].
        error_string = "Phone number already defined"
       ENDIF
      ELSEIF (p_cnt > 1)
       SET health_plan->list[exists_id].phone_num[health_plan->list[exists_id].phone_num_cnt].
       action_flag = - (1)
       SET health_plan->list[exists_id].phone_num[health_plan->list[exists_id].phone_num_cnt].
       error_string = "Phone number found twice"
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (trim(requestin->list_0[i].sponsor) != "")
    SET health_plan->list[exists_id].sponsor_cnt = (health_plan->list[exists_id].sponsor_cnt+ 1)
    SET stat = alterlist(health_plan->list[exists_id].sponsor,health_plan->list[exists_id].
     sponsor_cnt)
    SET health_plan->list[exists_id].sponsor[health_plan->list[exists_id].sponsor_cnt].row_num = i
    FOR (ii = 1 TO health_plan->list[exists_id].sponsor_cnt)
      IF (cnvtupper(health_plan->list[exists_id].sponsor[ii].sponsor_name)=cnvtupper(requestin->
       list_0[i].sponsor))
       SET health_plan->list[exists_id].sponsor[health_plan->list[exists_id].sponsor_cnt].action_flag
        = - (1)
       SET health_plan->list[exists_id].sponsor[health_plan->list[exists_id].sponsor_cnt].
       error_string = "Sponsor already defined"
      ENDIF
    ENDFOR
    SET health_plan->list[exists_id].sponsor[health_plan->list[exists_id].sponsor_cnt].sponsor_name
     = requestin->list_0[i].sponsor
    SELECT INTO "NL:"
     FROM organization o,
      org_type_reltn otr
     PLAN (o
      WHERE o.org_name_key=cnvtalphanum(cnvtupper(health_plan->list[exists_id].sponsor[health_plan->
        list[exists_id].sponsor_cnt].sponsor_name))
       AND o.active_ind=1)
      JOIN (otr
      WHERE o.organization_id=otr.organization_id
       AND otr.org_type_cd=emp_cd
       AND otr.active_ind=1)
     DETAIL
      health_plan->list[exists_id].sponsor[health_plan->list[exists_id].sponsor_cnt].organization_id
       = o.organization_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET health_plan->list[exists_id].sponsor[health_plan->list[exists_id].sponsor_cnt].action_flag
      = - (1)
     SET health_plan->list[exists_id].sponsor[health_plan->list[exists_id].sponsor_cnt].error_string
      = "Invalid Sponsor"
    ENDIF
    IF ((health_plan->list[exists_id].action_flag < 0))
     SET health_plan->list[exists_id].sponsor[health_plan->list[exists_id].sponsor_cnt].action_flag
      = - (1)
     SET health_plan->list[exists_id].sponsor[health_plan->list[exists_id].sponsor_cnt].error_string
      = "Health Plan Error"
    ENDIF
    IF ((health_plan->list[exists_id].sponsor[health_plan->list[exists_id].sponsor_cnt].action_flag
     != - (1)))
     SET health_plan->list[exists_id].sponsor[health_plan->list[exists_id].sponsor_cnt].action_flag
      = 1
     IF ((health_plan->list[exists_id].health_plan_id > 0))
      SET temp_active = 0
      SELECT INTO "NL:"
       FROM org_plan_reltn opr
       WHERE (opr.health_plan_id=health_plan->list[exists_id].health_plan_id)
        AND (opr.organization_id=health_plan->list[exists_id].sponsor[health_plan->list[exists_id].
       sponsor_cnt].organization_id)
        AND opr.org_plan_reltn_cd=emp_reltn_cd
       DETAIL
        IF (temp_active=0)
         health_plan->list[exists_id].sponsor[health_plan->list[exists_id].sponsor_cnt].action_flag
          = 2, health_plan->list[exists_id].sponsor[health_plan->list[exists_id].sponsor_cnt].
         sponsor_reltn = opr.org_plan_reltn_id
        ENDIF
        IF (opr.active_ind=1)
         temp_active = 1
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
   ENDIF
   IF (trim(requestin->list_0[i].facility) != "")
    SET health_plan->list[exists_id].facility_cnt = (health_plan->list[exists_id].facility_cnt+ 1)
    SET stat = alterlist(health_plan->list[exists_id].facility,health_plan->list[exists_id].
     facility_cnt)
    SET health_plan->list[exists_id].facility[health_plan->list[exists_id].facility_cnt].row_num = i
    FOR (ii = 1 TO health_plan->list[exists_id].facility_cnt)
      IF (cnvtupper(health_plan->list[exists_id].facility[ii].facility_name)=cnvtupper(requestin->
       list_0[i].facility))
       SET health_plan->list[exists_id].facility[health_plan->list[exists_id].facility_cnt].
       action_flag = - (1)
       SET health_plan->list[exists_id].facility[health_plan->list[exists_id].facility_cnt].
       error_string = "Facility already defined"
      ENDIF
    ENDFOR
    SET health_plan->list[exists_id].facility[health_plan->list[exists_id].facility_cnt].
    facility_name = requestin->list_0[i].facility
    SELECT INTO "NL:"
     FROM code_value c
     PLAN (c
      WHERE c.code_set=220
       AND c.cdf_meaning="FACILITY"
       AND c.active_ind=1
       AND cnvtupper(c.display)=cnvtupper(health_plan->list[exists_id].facility[health_plan->list[
       exists_id].facility_cnt].facility_name))
     DETAIL
      health_plan->list[exists_id].facility[health_plan->list[exists_id].facility_cnt].
      organization_id = c.code_value
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET health_plan->list[exists_id].facility[health_plan->list[exists_id].facility_cnt].action_flag
      = - (1)
     SET health_plan->list[exists_id].facility[health_plan->list[exists_id].facility_cnt].
     error_string = "Invalid Facility"
    ENDIF
    IF ((health_plan->list[exists_id].action_flag < 0))
     SET health_plan->list[exists_id].facility[health_plan->list[exists_id].facility_cnt].action_flag
      = - (1)
     SET health_plan->list[exists_id].facility[health_plan->list[exists_id].facility_cnt].
     error_string = "Health Plan Error"
    ENDIF
    IF ((health_plan->list[exists_id].facility[health_plan->list[exists_id].facility_cnt].action_flag
     != - (1)))
     SET health_plan->list[exists_id].facility[health_plan->list[exists_id].facility_cnt].action_flag
      = 1
     IF ((health_plan->list[exists_id].health_plan_id > 0))
      SELECT INTO "NL:"
       FROM filter_entity_reltn fer
       WHERE (fer.parent_entity_id=health_plan->list[exists_id].health_plan_id)
        AND fer.parent_entity_name="HEALTH_PLAN"
       WITH nocounter
      ;end select
      IF (curqual > 0)
       SET health_plan->list[exists_id].facility[health_plan->list[exists_id].facility_cnt].
       action_flag = - (1)
       SET health_plan->list[exists_id].facility[health_plan->list[exists_id].facility_cnt].
       error_string = "Link Exists"
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 IF (write_mode=1
  AND (health_plan->health_plan_cnt > 0))
  CALL echorecord(health_plan)
  FOR (i = 1 TO health_plan->health_plan_cnt)
    IF ((health_plan->list[i].action_flag=1))
     SELECT INTO "NL:"
      nextseqnum = seq(health_plan_seq,nextval)"##################;RP0"
      FROM dual
      DETAIL
       health_plan->list[i].health_plan_id = nextseqnum
      WITH nocounter, format
     ;end select
    ENDIF
  ENDFOR
  IF (data_partition_ind=1
   AND logical_domain_column_ind=1)
   INSERT  FROM health_plan hp,
     (dummyt d  WITH seq = health_plan->health_plan_cnt)
    SET hp.seq = 1, hp.health_plan_id = health_plan->list[d.seq].health_plan_id, hp.plan_type_cd =
     health_plan->list[d.seq].health_plan_type_cd,
     hp.plan_name = health_plan->list[d.seq].health_plan_name, hp.plan_desc = health_plan->list[d.seq
     ].health_plan_name, hp.financial_class_cd = health_plan->list[d.seq].financial_class_cd,
     hp.ft_entity_name = " ", hp.ft_entity_id = 0.00, hp.baby_coverage_cd = 0.00,
     hp.comb_baby_bill_cd = 0.00, hp.plan_class_cd = health_plan_cd, hp.group_nbr = " ",
     hp.group_name = " ", hp.policy_nbr = " ", hp.plan_name_key = trim(cnvtupper(cnvtalphanum(
        health_plan->list[d.seq].health_plan_name))),
     hp.pat_bill_pref_flag = 0.00, hp.pri_concurrent_ind = 0.00, hp.sec_concurrent_ind = 0.00,
     hp.product_cd = 0.00, hp.active_ind = 1, hp.active_status_cd = active_cd,
     hp.active_status_dt_tm = cnvtdatetime(curdate,curtime3), hp.active_status_prsnl_id = reqinfo->
     updt_id, hp.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     hp.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), hp.data_status_cd = auth_cd, hp
     .data_status_dt_tm = cnvtdatetime(curdate,curtime3),
     hp.data_status_prsnl_id = reqinfo->updt_id, hp.contributor_system_cd = 0.00, hp.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     hp.updt_id = reqinfo->updt_id, hp.updt_task = reqinfo->updt_task, hp.updt_applctx = reqinfo->
     updt_applctx,
     hp.updt_cnt = 0, hp.logical_domain_id = health_plan->list[d.seq].logical_domain_id, hp
     .service_type_cd = service_type_cd,
     hp.consumer_add_covrg_allow_ind = health_plan->list[d.seq].cons_add_covrg_allow_ind, hp
     .consumer_modify_covrg_deny_ind = health_plan->list[d.seq].cons_mod_covrg_deny_ind, hp
     .priority_ranking_nbr =
     IF (isnumeric(health_plan->list[d.seq].priority_ranking_nbr) > 0
      AND cnvtint(health_plan->list[d.seq].priority_ranking_nbr) >= 0
      AND cnvtint(health_plan->list[d.seq].priority_ranking_nbr) <= 99) cnvtint(health_plan->list[d
       .seq].priority_ranking_nbr)
     ELSE null
     ENDIF
    PLAN (d
     WHERE (health_plan->list[d.seq].action_flag=1))
     JOIN (hp)
    WITH nocounter
   ;end insert
  ELSE
   INSERT  FROM health_plan hp,
     (dummyt d  WITH seq = health_plan->health_plan_cnt)
    SET hp.seq = 1, hp.health_plan_id = health_plan->list[d.seq].health_plan_id, hp.plan_type_cd =
     health_plan->list[d.seq].health_plan_type_cd,
     hp.plan_name = health_plan->list[d.seq].health_plan_name, hp.plan_desc = health_plan->list[d.seq
     ].health_plan_name, hp.financial_class_cd = health_plan->list[d.seq].financial_class_cd,
     hp.ft_entity_name = " ", hp.ft_entity_id = 0.00, hp.baby_coverage_cd = 0.00,
     hp.comb_baby_bill_cd = 0.00, hp.plan_class_cd = health_plan_cd, hp.group_nbr = " ",
     hp.group_name = " ", hp.policy_nbr = " ", hp.plan_name_key = trim(cnvtupper(cnvtalphanum(
        health_plan->list[d.seq].health_plan_name))),
     hp.pat_bill_pref_flag = 0.00, hp.pri_concurrent_ind = 0.00, hp.sec_concurrent_ind = 0.00,
     hp.product_cd = 0.00, hp.active_ind = 1, hp.active_status_cd = active_cd,
     hp.active_status_dt_tm = cnvtdatetime(curdate,curtime3), hp.active_status_prsnl_id = reqinfo->
     updt_id, hp.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     hp.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), hp.data_status_cd = auth_cd, hp
     .data_status_dt_tm = cnvtdatetime(curdate,curtime3),
     hp.data_status_prsnl_id = reqinfo->updt_id, hp.contributor_system_cd = 0.00, hp.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     hp.updt_id = reqinfo->updt_id, hp.updt_task = reqinfo->updt_task, hp.updt_applctx = reqinfo->
     updt_applctx,
     hp.updt_cnt = 0, hp.service_type_cd = service_type_cd, hp.consumer_add_covrg_allow_ind =
     health_plan->list[d.seq].cons_add_covrg_allow_ind,
     hp.consumer_modify_covrg_deny_ind = health_plan->list[d.seq].cons_mod_covrg_deny_ind, hp
     .priority_ranking_nbr =
     IF (isnumeric(health_plan->list[d.seq].priority_ranking_nbr) > 0
      AND cnvtint(health_plan->list[d.seq].priority_ranking_nbr) >= 0
      AND cnvtint(health_plan->list[d.seq].priority_ranking_nbr) <= 99) cnvtint(health_plan->list[d
       .seq].priority_ranking_nbr)
     ELSE null
     ENDIF
    PLAN (d
     WHERE (health_plan->list[d.seq].action_flag=1))
     JOIN (hp)
    WITH nocounter
   ;end insert
  ENDIF
  INSERT  FROM org_plan_reltn opr,
    (dummyt d  WITH seq = health_plan->health_plan_cnt)
   SET opr.seq = 1, opr.org_plan_reltn_id = seq(organization_seq,nextval), opr.health_plan_id =
    health_plan->list[d.seq].health_plan_id,
    opr.org_plan_reltn_cd = ins_reltn_cd, opr.organization_id = health_plan->list[d.seq].
    insurance_org_id, opr.active_ind = 1,
    opr.active_status_cd = active_cd, opr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), opr
    .active_status_prsnl_id = reqinfo->updt_id,
    opr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), opr.end_effective_dt_tm = cnvtdatetime(
     "31-dec-2100 00:00:00"), opr.data_status_cd = auth_cd,
    opr.data_status_dt_tm = cnvtdatetime(curdate,curtime3), opr.data_status_prsnl_id = reqinfo->
    updt_id, opr.contributor_system_cd = 0.00,
    opr.updt_dt_tm = cnvtdatetime(curdate,curtime3), opr.updt_id = reqinfo->updt_id, opr.updt_task =
    reqinfo->updt_task,
    opr.updt_applctx = reqinfo->updt_applctx, opr.updt_cnt = 0
   PLAN (d
    WHERE (health_plan->list[d.seq].action_flag=1))
    JOIN (opr)
   WITH nocounter
  ;end insert
  FOR (i = 1 TO health_plan->health_plan_cnt)
    IF ((health_plan->list[i].address_cnt > 0))
     INSERT  FROM address a,
       (dummyt d  WITH seq = health_plan->list[i].address_cnt)
      SET a.seq = 1, a.address_id = seq(address_seq,nextval), a.parent_entity_name = "HEALTH_PLAN",
       a.parent_entity_id = health_plan->list[i].health_plan_id, a.address_type_cd = health_plan->
       list[i].address[d.seq].address_type_cd, a.active_ind = 1,
       a.residence_type_cd = 0.00, a.street_addr = health_plan->list[i].address[d.seq].street_addr, a
       .street_addr2 = health_plan->list[i].address[d.seq].street_addr2,
       a.street_addr3 = health_plan->list[i].address[d.seq].street_addr3, a.street_addr4 =
       health_plan->list[i].address[d.seq].street_addr4, a.city = health_plan->list[i].address[d.seq]
       .city,
       a.state = health_plan->list[i].address[d.seq].state, a.state_cd = health_plan->list[i].
       address[d.seq].state_cd, a.zipcode = health_plan->list[i].address[d.seq].zipcode,
       a.zip_code_group_cd = 0.00, a.country = health_plan->list[i].address[d.seq].country, a
       .country_cd = health_plan->list[i].address[d.seq].country_cd,
       a.residence_cd = 0.00, a.long_text_id = 0.00, a.address_info_status_cd = 0.00,
       a.primary_care_cd = 0.00, a.district_health_cd = 0.00, a.zipcode_key = trim(cnvtupper(
         cnvtalphanum(health_plan->list[i].address[d.seq].zipcode))),
       a.active_status_cd = active_cd, a.active_status_dt_tm = cnvtdatetime(curdate,curtime3), a
       .active_status_prsnl_id = reqinfo->updt_id,
       a.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), a.end_effective_dt_tm = cnvtdatetime(
        "31-dec-2100 00:00:00"), a.data_status_cd = auth_cd,
       a.data_status_dt_tm = cnvtdatetime(curdate,curtime3), a.data_status_prsnl_id = reqinfo->
       updt_id, a.contributor_system_cd = 0.00,
       a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = reqinfo->updt_id, a.updt_task =
       reqinfo->updt_task,
       a.updt_applctx = reqinfo->updt_applctx, a.updt_cnt = 0, a.contact_name = health_plan->list[i].
       address[d.seq].contact_name
      PLAN (d
       WHERE (health_plan->list[i].address[d.seq].action_flag=1))
       JOIN (a)
      WITH nocounter
     ;end insert
    ENDIF
    IF ((health_plan->list[i].phone_num_cnt > 0))
     INSERT  FROM phone p,
       (dummyt d  WITH seq = health_plan->list[i].phone_num_cnt)
      SET p.seq = 1, p.phone_id = seq(phone_seq,nextval), p.parent_entity_name = "HEALTH_PLAN",
       p.parent_entity_id = health_plan->list[i].health_plan_id, p.phone_type_cd = health_plan->list[
       i].phone_num[d.seq].phone_type_cd, p.phone_format_cd = freetext_cd,
       p.phone_num = health_plan->list[i].phone_num[d.seq].phone_number, p.extension = health_plan->
       list[i].phone_num[d.seq].phone_extension, p.phone_num_key = cnvtupper(cnvtalphanum(health_plan
         ->list[i].phone_num[d.seq].phone_number)),
       p.phone_type_seq = d.seq, p.modem_capability_cd = 0.00, p.long_text_id = 0.00,
       p.active_ind = 1, p.active_status_cd = active_cd, p.active_status_dt_tm = cnvtdatetime(curdate,
        curtime3),
       p.active_status_prsnl_id = reqinfo->updt_id, p.beg_effective_dt_tm = cnvtdatetime(curdate,
        curtime3), p.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"),
       p.data_status_cd = auth_cd, p.data_status_dt_tm = cnvtdatetime(curdate,curtime3), p
       .data_status_prsnl_id = reqinfo->updt_id,
       p.contributor_system_cd = 0.00, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id =
       reqinfo->updt_id,
       p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0,
       p.contact = health_plan->list[i].phone_num[d.seq].contact_name
      PLAN (d
       WHERE (health_plan->list[i].phone_num[d.seq].action_flag=1))
       JOIN (p)
      WITH nocounter
     ;end insert
    ENDIF
    IF ((health_plan->list[i].alias_cnt > 0))
     INSERT  FROM health_plan_alias hpa,
       (dummyt d  WITH seq = health_plan->list[i].alias_cnt)
      SET hpa.seq = 1, hpa.health_plan_alias_id = seq(health_plan_seq,nextval), hpa.health_plan_id =
       health_plan->list[i].health_plan_id,
       hpa.alias_pool_cd = health_plan->list[i].alias[d.seq].alias_pool_cd, hpa.alias = health_plan->
       list[i].alias[d.seq].alias, hpa.check_digit_method_cd = 0.00,
       hpa.plan_alias_type_cd = health_plan->list[i].alias[d.seq].alias_type_cd, hpa
       .plan_alias_sub_type_cd = 0.00, hpa.active_ind = 1,
       hpa.active_status_cd = active_cd, hpa.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
       hpa.active_status_prsnl_id = reqinfo->updt_id,
       hpa.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), hpa.end_effective_dt_tm =
       cnvtdatetime("31-dec-2100 00:00:00"), hpa.data_status_cd = auth_cd,
       hpa.data_status_dt_tm = cnvtdatetime(curdate,curtime3), hpa.data_status_prsnl_id = reqinfo->
       updt_id, hpa.contributor_system_cd = 0.00,
       hpa.updt_dt_tm = cnvtdatetime(curdate,curtime3), hpa.updt_id = reqinfo->updt_id, hpa.updt_task
        = reqinfo->updt_task,
       hpa.updt_applctx = reqinfo->updt_applctx, hpa.updt_cnt = 0
      PLAN (d
       WHERE (health_plan->list[i].alias[d.seq].action_flag=1))
       JOIN (hpa)
      WITH nocounter
     ;end insert
    ENDIF
    IF ((health_plan->list[i].sponsor_cnt > 0))
     FOR (k = 1 TO health_plan->list[i].sponsor_cnt)
       IF ((health_plan->list[i].sponsor[k].action_flag=1))
        SELECT INTO "nl:"
         j = seq(organization_seq,nextval)"##################;rp0"
         FROM dual
         DETAIL
          health_plan->list[i].sponsor[k].sponsor_reltn = cnvtreal(j)
         WITH format, counter
        ;end select
       ENDIF
     ENDFOR
     INSERT  FROM org_plan_reltn opr,
       (dummyt d  WITH seq = health_plan->list[i].sponsor_cnt)
      SET opr.seq = 1, opr.org_plan_reltn_id = health_plan->list[i].sponsor[d.seq].sponsor_reltn, opr
       .health_plan_id = health_plan->list[i].health_plan_id,
       opr.org_plan_reltn_cd = emp_reltn_cd, opr.organization_id = health_plan->list[i].sponsor[d.seq
       ].organization_id, opr.active_ind = 1,
       opr.active_status_cd = active_cd, opr.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
       opr.active_status_prsnl_id = reqinfo->updt_id,
       opr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), opr.end_effective_dt_tm =
       cnvtdatetime("31-dec-2100 00:00:00"), opr.data_status_cd = auth_cd,
       opr.data_status_dt_tm = cnvtdatetime(curdate,curtime3), opr.data_status_prsnl_id = reqinfo->
       updt_id, opr.contributor_system_cd = 0.00,
       opr.updt_dt_tm = cnvtdatetime(curdate,curtime3), opr.updt_id = reqinfo->updt_id, opr.updt_task
        = reqinfo->updt_task,
       opr.updt_applctx = reqinfo->updt_applctx, opr.updt_cnt = 0
      PLAN (d
       WHERE (health_plan->list[i].sponsor[d.seq].action_flag=1))
       JOIN (opr)
      WITH nocounter
     ;end insert
     SELECT INTO "nl:"
      FROM address a,
       (dummyt d  WITH seq = health_plan->list[i].sponsor_cnt)
      PLAN (d)
       JOIN (a
       WHERE (a.parent_entity_id=health_plan->list[i].sponsor[d.seq].organization_id)
        AND a.parent_entity_name="ORGANIZATION"
        AND a.active_ind=1)
      HEAD REPORT
       acnt = 0
      DETAIL
       acnt = (acnt+ 1), stat = alterlist(addr->qual,acnt), addr->qual[acnt].address_type_cd = a
       .address_type_cd,
       addr->qual[acnt].street_addr1 = a.street_addr, addr->qual[acnt].street_addr2 = a.street_addr2,
       addr->qual[acnt].street_addr3 = a.street_addr3,
       addr->qual[acnt].street_addr4 = a.street_addr4, addr->qual[acnt].city = a.city, addr->qual[
       acnt].state_cd = a.state_cd,
       addr->qual[acnt].state = a.state, addr->qual[acnt].zipcode = a.zipcode, addr->qual[acnt].
       zipcode_key = a.zipcode_key,
       addr->qual[acnt].county_cd = a.county_cd, addr->qual[acnt].county = a.county, addr->qual[acnt]
       .country_cd = a.country_cd,
       addr->qual[acnt].country = a.country, addr->qual[acnt].contact_name = a.contact_name, addr->
       qual[acnt].comment_txt = a.comment_txt,
       addr->qual[acnt].postal_barcode_info = a.postal_barcode_info, addr->qual[acnt].mail_stop = a
       .mail_stop, addr->qual[acnt].operation_hours = a.operation_hours,
       addr->qual[acnt].sponsor_reltn = health_plan->list[i].sponsor[d.seq].sponsor_reltn
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM phone p,
       (dummyt d  WITH seq = health_plan->list[i].sponsor_cnt)
      PLAN (d)
       JOIN (p
       WHERE (p.parent_entity_id=health_plan->list[i].sponsor[d.seq].organization_id)
        AND p.parent_entity_name="ORGANIZATION"
        AND p.active_ind=1)
      HEAD REPORT
       pcnt = 0
      DETAIL
       pcnt = (pcnt+ 1), stat = alterlist(phone->qual,pcnt), phone->qual[pcnt].phone_type_cd = p
       .phone_type_cd,
       phone->qual[pcnt].phone_format_cd = p.phone_format_cd, phone->qual[pcnt].phone_num = p
       .phone_num, phone->qual[pcnt].phone_type_seq = p.phone_type_seq,
       phone->qual[pcnt].description = p.description, phone->qual[pcnt].contact = p.contact, phone->
       qual[pcnt].call_instruction = p.call_instruction,
       phone->qual[pcnt].extension = p.extension, phone->qual[pcnt].paging_code = p.paging_code,
       phone->qual[pcnt].sponsor_reltn = health_plan->list[i].sponsor[d.seq].sponsor_reltn
      WITH nocounter
     ;end select
     IF (size(addr->qual,5) > 0)
      SET ierrcode = 0
      INSERT  FROM (dummyt d  WITH seq = value(size(addr->qual,5))),
        address a
       SET a.address_id = seq(address_seq,nextval), a.parent_entity_name = "ORG_PLAN_RELTN", a
        .parent_entity_id = addr->qual[d.seq].sponsor_reltn,
        a.address_type_cd = addr->qual[d.seq].address_type_cd, a.updt_id = reqinfo->updt_id, a
        .updt_cnt = 0,
        a.updt_applctx = reqinfo->updt_applctx, a.updt_task = reqinfo->updt_task, a.updt_dt_tm =
        cnvtdatetime(curdate,curtime3),
        a.active_ind = 1, a.active_status_cd = active_cd, a.active_status_dt_tm = cnvtdatetime(
         curdate,curtime3),
        a.active_status_prsnl_id = reqinfo->updt_id, a.beg_effective_dt_tm = cnvtdatetime(curdate,
         curtime3), a.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
        a.street_addr = addr->qual[d.seq].street_addr1, a.street_addr2 = addr->qual[d.seq].
        street_addr2, a.street_addr3 = addr->qual[d.seq].street_addr3,
        a.street_addr4 = addr->qual[d.seq].street_addr4, a.city = addr->qual[d.seq].city, a.state =
        addr->qual[d.seq].state,
        a.state_cd = addr->qual[d.seq].state_cd, a.zipcode = addr->qual[d.seq].zipcode, a.zipcode_key
         = addr->qual[d.seq].zipcode_key,
        a.county = addr->qual[d.seq].county, a.county_cd = addr->qual[d.seq].county_cd, a.country =
        addr->qual[d.seq].country,
        a.country_cd = addr->qual[d.seq].country_cd, a.contact_name = addr->qual[d.seq].contact_name,
        a.comment_txt = addr->qual[d.seq].comment_txt,
        a.postal_barcode_info = addr->qual[d.seq].postal_barcode_info, a.mail_stop = addr->qual[d.seq
        ].mail_stop, a.operation_hours = addr->qual[d.seq].operation_hours,
        a.data_status_cd = auth_cd, a.data_status_dt_tm = cnvtdatetime(curdate,curtime3), a
        .data_status_prsnl_id = reqinfo->updt_id
       PLAN (d)
        JOIN (a)
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       GO TO exit_script
      ENDIF
     ENDIF
     IF (size(phone->qual,5) > 0)
      SET ierrcode = 0
      INSERT  FROM (dummyt d  WITH seq = value(size(phone->qual,5))),
        phone p
       SET p.phone_id = seq(phone_seq,nextval), p.parent_entity_name = "ORG_PLAN_RELTN", p
        .parent_entity_id = phone->qual[d.seq].sponsor_reltn,
        p.phone_type_cd = phone->qual[d.seq].phone_type_cd, p.phone_format_cd = phone->qual[d.seq].
        phone_format_cd, p.phone_num = phone->qual[d.seq].phone_num,
        p.phone_num_key = cnvtupper(cnvtalphanum(phone->qual[d.seq].phone_num)), p.phone_type_seq =
        phone->qual[d.seq].phone_type_seq, p.description = phone->qual[d.seq].description,
        p.contact = phone->qual[d.seq].contact, p.call_instruction = phone->qual[d.seq].
        call_instruction, p.extension = phone->qual[d.seq].extension,
        p.paging_code = phone->qual[d.seq].paging_code, p.updt_id = reqinfo->updt_id, p.updt_cnt = 0,
        p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->updt_task, p.updt_dt_tm =
        cnvtdatetime(curdate,curtime3),
        p.active_ind = 1, p.active_status_cd = active_cd, p.active_status_dt_tm = cnvtdatetime(
         curdate,curtime3),
        p.active_status_prsnl_id = reqinfo->updt_id, p.beg_effective_dt_tm = cnvtdatetime(curdate,
         curtime3), p.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
        p.data_status_cd = auth_cd, p.data_status_dt_tm = cnvtdatetime(curdate,curtime3), p
        .data_status_prsnl_id = reqinfo->updt_id
       PLAN (d)
        JOIN (p)
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
    IF ((health_plan->list[i].facility_cnt > 0))
     INSERT  FROM filter_entity_reltn fer,
       (dummyt d  WITH seq = health_plan->list[i].facility_cnt)
      SET fer.seq = 1, fer.filter_entity_reltn_id = seq(reference_seq,nextval), fer
       .parent_entity_name = "HEALTH_PLAN",
       fer.parent_entity_id = health_plan->list[i].health_plan_id, fer.filter_entity1_name =
       "LOCATION", fer.filter_entity1_id = health_plan->list[i].facility[d.seq].organization_id,
       fer.filter_entity2_name = " ", fer.filter_entity2_id = 0.00, fer.filter_entity3_name = " ",
       fer.filter_entity3_id = 0.00, fer.filter_entity4_name = " ", fer.filter_entity4_id = 0.00,
       fer.filter_entity5_name = " ", fer.filter_entity5_id = 0.00, fer.filter_type_cd =
       filter_type_cd,
       fer.exclusion_filter_ind = 0.00, fer.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), fer
       .end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"),
       fer.updt_dt_tm = cnvtdatetime(curdate,curtime3), fer.updt_id = reqinfo->updt_id, fer.updt_task
        = reqinfo->updt_task,
       fer.updt_applctx = reqinfo->updt_applctx, fer.updt_cnt = 0
      PLAN (d
       WHERE (health_plan->list[i].facility[d.seq].action_flag=1))
       JOIN (fer)
      WITH nocounter
     ;end insert
    ENDIF
  ENDFOR
  UPDATE  FROM health_plan hp,
    (dummyt d  WITH seq = health_plan->health_plan_cnt)
   SET hp.seq = 1, hp.plan_type_cd = health_plan->list[d.seq].health_plan_type_cd, hp
    .financial_class_cd = health_plan->list[d.seq].financial_class_cd,
    hp.active_ind = 1, hp.active_status_cd = active_cd, hp.active_status_dt_tm = cnvtdatetime(curdate,
     curtime3),
    hp.active_status_prsnl_id = reqinfo->updt_id, hp.end_effective_dt_tm = cnvtdatetime(
     "31-dec-2100 00:00:00"), hp.data_status_cd = auth_cd,
    hp.contributor_system_cd = 0.00, hp.updt_dt_tm = cnvtdatetime(curdate,curtime3), hp.updt_id =
    reqinfo->updt_id,
    hp.updt_task = reqinfo->updt_task, hp.updt_applctx = reqinfo->updt_applctx, hp.updt_cnt = (hp
    .updt_cnt+ 1),
    hp.consumer_add_covrg_allow_ind = health_plan->list[d.seq].cons_add_covrg_allow_ind, hp
    .consumer_modify_covrg_deny_ind = health_plan->list[d.seq].cons_mod_covrg_deny_ind, hp
    .priority_ranking_nbr =
    IF (isnumeric(health_plan->list[d.seq].priority_ranking_nbr) > 0
     AND cnvtint(health_plan->list[d.seq].priority_ranking_nbr) >= 0
     AND cnvtint(health_plan->list[d.seq].priority_ranking_nbr) <= 99) cnvtint(health_plan->list[d
      .seq].priority_ranking_nbr)
    ELSE null
    ENDIF
   PLAN (d
    WHERE (health_plan->list[d.seq].action_flag=2))
    JOIN (hp
    WHERE (hp.health_plan_id=health_plan->list[d.seq].health_plan_id))
   WITH nocounter
  ;end update
  FOR (i = 1 TO health_plan->health_plan_cnt)
    IF ((health_plan->list[i].address_cnt > 0))
     UPDATE  FROM address a,
       (dummyt d  WITH seq = health_plan->list[i].address_cnt)
      SET a.seq = 1, a.active_ind = 1, a.street_addr = health_plan->list[i].address[d.seq].
       street_addr,
       a.street_addr2 = health_plan->list[i].address[d.seq].street_addr2, a.street_addr3 =
       health_plan->list[i].address[d.seq].street_addr3, a.street_addr4 = health_plan->list[i].
       address[d.seq].street_addr4,
       a.city = health_plan->list[i].address[d.seq].city, a.state = health_plan->list[i].address[d
       .seq].state, a.state_cd = health_plan->list[i].address[d.seq].state_cd,
       a.zipcode = health_plan->list[i].address[d.seq].zipcode, a.country = health_plan->list[i].
       address[d.seq].country, a.country_cd = health_plan->list[i].address[d.seq].country_cd,
       a.zipcode_key = trim(cnvtupper(cnvtalphanum(health_plan->list[i].address[d.seq].zipcode))), a
       .active_status_cd = active_cd, a.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
       a.active_status_prsnl_id = reqinfo->updt_id, a.end_effective_dt_tm = cnvtdatetime(
        "31-dec-2100 00:00:00"), a.data_status_cd = auth_cd,
       a.contributor_system_cd = 0.00, a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id =
       reqinfo->updt_id,
       a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->updt_applctx, a.updt_cnt = (a
       .updt_cnt+ 1)
      PLAN (d
       WHERE (health_plan->list[i].address[d.seq].action_flag=2))
       JOIN (a
       WHERE (a.address_id=health_plan->list[i].address[d.seq].address_id))
      WITH nocounter
     ;end update
    ENDIF
    IF ((health_plan->list[i].phone_num_cnt > 0))
     UPDATE  FROM phone p,
       (dummyt d  WITH seq = health_plan->list[i].phone_num_cnt)
      SET p.seq = 1, p.phone_num = health_plan->list[i].phone_num[d.seq].phone_number, p
       .phone_num_key = cnvtupper(cnvtalphanum(health_plan->list[i].phone_num[d.seq].phone_number)),
       p.extension = health_plan->list[i].phone_num[d.seq].phone_extension, p.contact = health_plan->
       list[i].phone_num[d.seq].contact_name, p.active_ind = 1,
       p.active_status_cd = active_cd, p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p
       .active_status_prsnl_id = reqinfo->updt_id,
       p.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), p.data_status_cd = auth_cd, p
       .contributor_system_cd = 0.00,
       p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_task =
       reqinfo->updt_task,
       p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = (p.updt_cnt+ 1)
      PLAN (d
       WHERE (health_plan->list[i].phone_num[d.seq].action_flag=2))
       JOIN (p
       WHERE (p.phone_id=health_plan->list[i].phone_num[d.seq].phone_id))
      WITH nocounter
     ;end update
    ENDIF
    IF ((health_plan->list[i].alias_cnt > 0))
     UPDATE  FROM health_plan_alias hpa,
       (dummyt d  WITH seq = health_plan->list[i].alias_cnt)
      SET hpa.seq = 1, hpa.alias = health_plan->list[i].alias[d.seq].alias, hpa.active_ind = 1,
       hpa.active_status_cd = active_cd, hpa.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
       hpa.active_status_prsnl_id = reqinfo->updt_id,
       hpa.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), hpa.data_status_cd = auth_cd,
       hpa.contributor_system_cd = 0.00,
       hpa.updt_dt_tm = cnvtdatetime(curdate,curtime3), hpa.updt_id = reqinfo->updt_id, hpa.updt_task
        = reqinfo->updt_task,
       hpa.updt_applctx = reqinfo->updt_applctx, hpa.updt_cnt = 0
      PLAN (d
       WHERE (health_plan->list[i].alias[d.seq].action_flag=2))
       JOIN (hpa
       WHERE (hpa.health_plan_alias_id=health_plan->list[i].alias[d.seq].alias_id))
      WITH nocounter
     ;end update
    ENDIF
    IF ((health_plan->list[i].sponsor_cnt > 0))
     UPDATE  FROM org_plan_reltn opr,
       (dummyt d  WITH seq = health_plan->list[i].sponsor_cnt)
      SET opr.seq = 1, opr.active_ind = 1, opr.active_status_cd = active_cd,
       opr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), opr.active_status_prsnl_id = reqinfo
       ->updt_id, opr.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"),
       opr.data_status_cd = auth_cd, opr.contributor_system_cd = 0.00, opr.updt_dt_tm = cnvtdatetime(
        curdate,curtime3),
       opr.updt_id = reqinfo->updt_id, opr.updt_task = reqinfo->updt_task, opr.updt_applctx = reqinfo
       ->updt_applctx,
       opr.updt_cnt = (opr.updt_cnt+ 1)
      PLAN (d
       WHERE (health_plan->list[i].sponsor[d.seq].action_flag=2))
       JOIN (opr
       WHERE (opr.org_plan_reltn_id=health_plan->list[i].sponsor[d.seq].organization_id))
      WITH nocounter
     ;end update
    ENDIF
  ENDFOR
 ENDIF
 SELECT INTO value(name)
  FROM (dummyt d  WITH seq = health_plan->health_plan_cnt)
  DETAIL
   col 2, "---------------------", row + 1,
   col 1, health_plan->list[d.seq].row_num"#####", col 10,
   health_plan->list[d.seq].health_plan_name
   IF ((health_plan->list[d.seq].action_flag=1))
    col 90, "ADDED"
   ELSEIF ((health_plan->list[d.seq].action_flag=2))
    col 90, "UPDATED"
   ELSE
    col 90, "ERROR"
   ENDIF
   col 100, health_plan->list[d.seq].error_string, row + 1,
   col 1, health_plan->list[d.seq].row_num"#####", col 30,
   "INSURANCE COMPANY", col 50, health_plan->list[d.seq].insurance_name,
   row + 1, col 1, health_plan->list[d.seq].row_num"#####",
   col 30, "PLAN TYPE", col 50,
   health_plan->list[d.seq].health_plan_type, row + 1, col 1,
   health_plan->list[d.seq].row_num"#####", col 30, "FINANCIAL CLASS",
   col 50, health_plan->list[d.seq].financial_class, row + 1
   FOR (j = 1 TO health_plan->list[d.seq].sponsor_cnt)
     col 1, health_plan->list[d.seq].sponsor[j].row_num"#####", col 30,
     "SPONSOR", col 50, health_plan->list[d.seq].sponsor[j].sponsor_name
     IF ((health_plan->list[d.seq].sponsor[j].action_flag=1))
      col 90, "ADDED"
     ELSEIF ((health_plan->list[d.seq].sponsor[j].action_flag=2))
      col 90, "UPDATED"
     ELSE
      col 90, "ERROR"
     ENDIF
     col 100, health_plan->list[d.seq].sponsor[j].error_string, row + 1
   ENDFOR
   FOR (j = 1 TO health_plan->list[d.seq].facility_cnt)
     col 1, health_plan->list[d.seq].facility[j].row_num"#####", col 30,
     "FACILITY", col 50, health_plan->list[d.seq].facility[j].facility_name
     IF ((health_plan->list[d.seq].facility[j].action_flag=1))
      col 90, "ADDED"
     ELSEIF ((health_plan->list[d.seq].facility[j].action_flag=2))
      col 90, "UPDATED"
     ELSE
      col 90, "ERROR"
     ENDIF
     col 100, health_plan->list[d.seq].facility[j].error_string, row + 1
   ENDFOR
   row + 1
   FOR (j = 1 TO health_plan->list[d.seq].address_cnt)
     col 1, health_plan->list[d.seq].address[j].row_num"#####", col 30,
     "ADDRESS TYPE", col 50, health_plan->list[d.seq].address[j].address_type_name
     IF ((health_plan->list[d.seq].address[j].action_flag=1))
      col 90, "ADDED"
     ELSEIF ((health_plan->list[d.seq].address[j].action_flag=2))
      col 90, "UPDATED"
     ELSE
      col 90, "ERROR"
     ENDIF
     col 100, health_plan->list[d.seq].address[j].error_string, row + 1,
     col 1, health_plan->list[d.seq].address[j].row_num"#####", col 30,
     "ADDRESS", col 50, health_plan->list[d.seq].address[j].street_addr,
     row + 1
     IF ((health_plan->list[d.seq].address[j].street_addr2 != ""))
      col 1, health_plan->list[d.seq].address[j].row_num"#####", col 50,
      health_plan->list[d.seq].address[j].street_addr2, row + 1
     ENDIF
     IF ((health_plan->list[d.seq].address[j].street_addr3 != ""))
      col 1, health_plan->list[d.seq].address[j].row_num"#####", col 50,
      health_plan->list[d.seq].address[j].street_addr3, row + 1
     ENDIF
     IF ((health_plan->list[d.seq].address[j].street_addr4 != ""))
      col 1, health_plan->list[d.seq].address[j].row_num"#####", col 50,
      health_plan->list[d.seq].address[j].street_addr4, row + 1
     ENDIF
     col 1, health_plan->list[d.seq].address[j].row_num"#####", col 50,
     health_plan->list[d.seq].address[j].city, col 70, health_plan->list[d.seq].address[j].state,
     col 75, health_plan->list[d.seq].address[j].zipcode, row + 1,
     row + 1
   ENDFOR
   FOR (j = 1 TO health_plan->list[d.seq].phone_num_cnt)
     col 1, health_plan->list[d.seq].phone_num[j].row_num"#####", col 30,
     "PHONE TYPE", col 50, health_plan->list[d.seq].phone_num[j].phone_type_name
     IF ((health_plan->list[d.seq].phone_num[j].action_flag=1))
      col 90, "ADDED"
     ELSEIF ((health_plan->list[d.seq].phone_num[j].action_flag=2))
      col 90, "UPDATED"
     ELSE
      col 90, "ERROR"
     ENDIF
     col 100, health_plan->list[d.seq].phone_num[j].error_string, row + 1,
     col 1, health_plan->list[d.seq].phone_num[j].row_num"#####", col 30,
     "PHONE NUMBER", col 50, health_plan->list[d.seq].phone_num[j].phone_number,
     row + 1, col 1, health_plan->list[d.seq].phone_num[j].row_num"#####",
     col 30, "PHONE EXTENSION", col 50,
     health_plan->list[d.seq].phone_num[j].phone_extension, row + 1, row + 1
   ENDFOR
   FOR (j = 1 TO health_plan->list[d.seq].alias_cnt)
     col 1, health_plan->list[d.seq].alias[j].row_num"#####", col 30,
     "ALIAS TYPE", col 50, health_plan->list[d.seq].alias[j].alias_type
     IF ((health_plan->list[d.seq].alias[j].action_flag=1))
      col 90, "ADDED"
     ELSEIF ((health_plan->list[d.seq].alias[j].action_flag=2))
      col 90, "UPDATED"
     ELSE
      col 90, "ERROR"
     ENDIF
     col 100, health_plan->list[d.seq].alias[j].error_string, row + 1,
     col 1, health_plan->list[d.seq].alias[j].row_num"#####", col 30,
     "ALIAS POOL", col 50, health_plan->list[d.seq].alias[j].alias_pool_name,
     row + 1, col 1, health_plan->list[d.seq].alias[j].row_num"#####",
     col 30, "ALIAS", col 50,
     health_plan->list[d.seq].alias[j].alias, row + 1, row + 1
   ENDFOR
  WITH nocounter, append, format = variable,
   noformfeed, maxcol = 132
 ;end select
 SET error_flag = "N"
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
  SET reqinfo->commit_ind = 0
 ENDIF
 RETURN
 SUBROUTINE logstart(xtitle,xname)
   DECLARE dir_name = vc
   SET dir_name = "ccluserdir:"
   SET log_name = concat(trim(dir_name),xname)
   SET logvar = 0
   SELECT INTO value(log_name)
    logvar
    HEAD REPORT
     begin_dt_tm"dd-mmm-yyyy;;d", "-", begin_dt_tm"hh:mm:ss;;m",
     col + 1, xtitle, row + 1
     IF (write_mode=0)
      col 30, "AUDIT MODE: NO CHANGES HAVE BEEN MADE TO THE DATABASE"
     ELSE
      col 30, "COMMIT MODE: CHANGES HAVE BEEN MADE TO THE DATABASE"
     ENDIF
    DETAIL
     row + 2, col 2, "ROW",
     col 10, "HEALTH PLAN", col 30,
     "PROPERTY", col 50, "DETAIL",
     col 90, "STATUS", col 100,
     "ERROR"
    WITH nocounter, format = variable, noformfeed,
     maxcol = 132, maxrow = 1
   ;end select
   RETURN
 END ;Subroutine
 SUBROUTINE get_code_value(xcodeset,xcdf)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND c.cdf_meaning=xcdf)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
 SUBROUTINE get_cv_by_disp(xcodeset,xdisp)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND cnvtupper(c.display)=trim(cnvtupper(xdisp))
      AND c.active_ind=1)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
END GO
