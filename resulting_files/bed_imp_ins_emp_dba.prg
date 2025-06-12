CREATE PROGRAM bed_imp_ins_emp:dba
 FREE SET org
 RECORD org(
   1 org_cnt = i4
   1 org[*]
     2 organization_id = f8
     2 name = vc
     2 type = vc
     2 ins_ind = i2
     2 ins_id = f8
     2 emp_ind = i2
     2 emp_id = f8
     2 address_cnt = i4
     2 phone_cnt = i4
     2 alias_cnt = i4
     2 action_flag = i2
     2 error_string = vc
     2 row_num = i4
     2 address[*]
       3 address_type_cd = f8
       3 address_type = vc
       3 street_addr = vc
       3 street_addr2 = vc
       3 street_addr3 = vc
       3 street_addr4 = vc
       3 city = vc
       3 state = vc
       3 state_cd = f8
       3 zip = vc
       3 county = vc
       3 county_cd = f8
       3 country = vc
       3 country_cd = f8
       3 action_flag = i2
       3 error_string = vc
       3 row_num = i4
     2 phone[*]
       3 phone_type_cd = f8
       3 phone_type = vc
       3 phone_num = vc
       3 action_flag = i2
       3 error_string = vc
       3 row_num = i4
     2 alias[*]
       3 alias_pool_cd = f8
       3 alias_pool = vc
       3 alias_type_cd = f8
       3 alias_type = vc
       3 alias = vc
       3 action_flag = i2
       3 error_string = vc
       3 row_num = i4
     2 logical_domain_id = f8
 )
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
 SET error_flag = "Y"
 DECLARE error_msg = vc
 DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE end_dt_tm = dq8 WITH constant(cnvtdatetime("31-dec-2100 00:00:00"))
 SET active_cd = get_code_value(48,"ACTIVE")
 SET inactive_cd = get_code_value(48,"INACTIVE")
 SET auth_cd = get_code_value(8,"AUTH")
 SET ins_cd = get_code_value(278,"INSCO")
 SET emp_cd = get_code_value(278,"EMPLOYER")
 SET facility_cd = get_code_value(278,"FACILITY")
 SET health_plan_cd = get_code_value(397,"HEALTHPLAN")
 SET freetext_cd = get_code_value(281,"FREETEXT")
 SET filter_type_cd = get_code_value(30620,"HEALTHPLAN")
 SET org_class_cd = get_code_value(396,"ORG")
 SET file_name = "bed_ins_emp.csv"
 SET numrows = size(requestin->list_0,5)
 SET title = validate(log_title_set,"Insurance and Employer Log")
 SET name = validate(log_name_set,"bed_ins_emp.log")
 SET status = validate(log_col_set,"STATUS")
 SET alt_mode = validate(alt_mode_set,0)
 SET alt_detail = validate(alt_detail_set,0)
 CALL logstart(title,name)
 SET logical_domain_column_ind = 0
 IF (validate(requestin->list_0[1].logical_domain_id))
  SET logical_domain_column_ind = 1
 ENDIF
 SET data_partition_ind = 0
 RANGE OF o IS organization
 SET data_partition_ind = validate(o.logical_domain_id)
 FREE RANGE o
 FOR (i = 1 TO numrows)
   SET exists_id = 0
   IF (cnvtreal(requestin->list_0[i].organization_id) > 0.0)
    FOR (ii = 1 TO org->org_cnt)
      IF ((org->org[ii].organization_id=cnvtreal(requestin->list_0[i].organization_id)))
       SET exists_id = ii
      ENDIF
    ENDFOR
   ENDIF
   IF (exists_id=0)
    FOR (ii = 1 TO org->org_cnt)
      IF (cnvtupper(org->org[ii].name)=cnvtupper(requestin->list_0[i].name))
       SET exists_id = ii
      ENDIF
    ENDFOR
   ENDIF
   IF (exists_id=0)
    SET org->org_cnt = (org->org_cnt+ 1)
    SET stat = alterlist(org->org,org->org_cnt)
    SET exists_id = org->org_cnt
    SET org->org[exists_id].name = requestin->list_0[i].name
    SET org->org[exists_id].row_num = i
    SET org->org[exists_id].type = requestin->list_0[i].type
    SET org->org[exists_id].organization_id = cnvtreal(requestin->list_0[i].organization_id)
    IF (logical_domain_column_ind=1)
     SET org->org[exists_id].logical_domain_id = cnvtreal(requestin->list_0[i].logical_domain_id)
    ENDIF
    IF (trim(cnvtupper(org->org[exists_id].type))="INSURANCE COMPANY")
     SET org->org[exists_id].ins_ind = 1
    ENDIF
    IF (trim(cnvtupper(org->org[exists_id].type))="EMPLOYER")
     SET org->org[exists_id].emp_ind = 1
    ENDIF
    IF (trim(cnvtupper(org->org[exists_id].type))="BOTH")
     SET org->org[exists_id].emp_ind = 1
     SET org->org[exists_id].ins_ind = 1
    ENDIF
    IF ((org->org[exists_id].ins_ind=0)
     AND (org->org[exists_id].emp_ind=0))
     SET org->org[exists_id].action_flag = - (1)
     SET org->org[exists_id].error_string = "Invalid Type"
    ENDIF
    IF ((org->org[exists_id].organization_id > 0))
     DECLARE org_name_check = vc
     SET org_name_check = " "
     SELECT INTO "NL:"
      FROM organization o
      PLAN (o
       WHERE o.data_status_cd=auth_cd
        AND (o.organization_id=org->org[exists_id].organization_id)
        AND o.active_ind=1)
      DETAIL
       org_name_check = o.org_name
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET org->org[exists_id].action_flag = - (1)
      SET org->org[exists_id].error_string = "Invalid Org ID"
     ELSE
      IF (cnvtupper(org_name_check)=cnvtupper(org->org[exists_id].name))
       SET org->org[exists_id].action_flag = 3
      ELSE
       SET org->org[exists_id].action_flag = 2
      ENDIF
     ENDIF
    ELSE
     SELECT INTO "NL:"
      FROM organization o
      PLAN (o
       WHERE o.data_status_cd=auth_cd
        AND cnvtalphanum(cnvtupper(org->org[exists_id].name))=o.org_name_key
        AND o.active_ind=1)
      DETAIL
       org->org[exists_id].organization_id = o.organization_id
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET org->org[exists_id].action_flag = 1
     ELSE
      SET org->org[exists_id].action_flag = 2
     ENDIF
    ENDIF
    IF ((org->org[exists_id].organization_id > 0))
     SELECT INTO "NL:"
      FROM org_type_reltn o
      WHERE (o.organization_id=org->org[exists_id].organization_id)
       AND o.org_type_cd=emp_cd
       AND o.active_ind=1
      WITH nocounter
     ;end select
     IF (curqual > 0)
      IF ((org->org[exists_id].emp_ind=1))
       SET org->org[exists_id].emp_ind = 0
      ELSE
       SET org->org[exists_id].emp_ind = - (1)
      ENDIF
     ENDIF
     SELECT INTO "NL:"
      FROM org_type_reltn o
      WHERE (o.organization_id=org->org[exists_id].organization_id)
       AND o.org_type_cd=ins_cd
       AND o.active_ind=1
      WITH nocounter
     ;end select
     IF (curqual > 0)
      IF ((org->org[exists_id].ins_ind=1))
       SET org->org[exists_id].ins_ind = 0
      ELSE
       SET org->org[exists_id].ins_ind = - (1)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF ((org->org[exists_id].action_flag > 0))
    IF ((requestin->list_0[i].address_type != ""))
     SET org->org[exists_id].address_cnt = (org->org[exists_id].address_cnt+ 1)
     SET stat = alterlist(org->org[exists_id].address,org->org[exists_id].address_cnt)
     SET org->org[exists_id].address[org->org[exists_id].address_cnt].row_num = i
     SET org->org[exists_id].address[org->org[exists_id].address_cnt].address_type = requestin->
     list_0[i].address_type
     SET org->org[exists_id].address[org->org[exists_id].address_cnt].street_addr = requestin->
     list_0[i].street_addr
     SET org->org[exists_id].address[org->org[exists_id].address_cnt].street_addr2 = requestin->
     list_0[i].street_addr2
     SET org->org[exists_id].address[org->org[exists_id].address_cnt].street_addr3 = requestin->
     list_0[i].street_addr3
     SET org->org[exists_id].address[org->org[exists_id].address_cnt].street_addr4 = requestin->
     list_0[i].street_addr4
     SET org->org[exists_id].address[org->org[exists_id].address_cnt].city = requestin->list_0[i].
     city
     SET org->org[exists_id].address[org->org[exists_id].address_cnt].state = requestin->list_0[i].
     state
     SET org->org[exists_id].address[org->org[exists_id].address_cnt].zip = requestin->list_0[i].zip
     SET org->org[exists_id].address[org->org[exists_id].address_cnt].country = requestin->list_0[i].
     country
     SET county_code_value = uar_get_code_by("DISPLAYKEY",74,cnvtupper(trim(requestin->list_0[i].
        county,3)))
     IF ((county_code_value > - (1)))
      SET org->org[exists_id].address[org->org[exists_id].address_cnt].county_cd = county_code_value
      SET org->org[exists_id].address[org->org[exists_id].address_cnt].county = uar_get_code_display(
       county_code_value)
     ENDIF
     SET org->org[exists_id].address[org->org[exists_id].address_cnt].address_type_cd =
     get_cv_by_disp(212,org->org[exists_id].address[org->org[exists_id].address_cnt].address_type)
     SET org->org[exists_id].address[org->org[exists_id].address_cnt].state_cd = get_cv_by_disp(62,
      org->org[exists_id].address[org->org[exists_id].address_cnt].state)
     SET org->org[exists_id].address[org->org[exists_id].address_cnt].country_cd = get_cv_by_disp(15,
      org->org[exists_id].address[org->org[exists_id].address_cnt].country)
     IF ((org->org[exists_id].address[org->org[exists_id].address_cnt].address_type_cd=0))
      SET org->org[exists_id].address[org->org[exists_id].address_cnt].action_flag = - (1)
      SET org->org[exists_id].address[org->org[exists_id].address_cnt].error_string =
      "Invalid Address Type (CS 212)"
     ENDIF
     IF ((org->org[exists_id].address[org->org[exists_id].address_cnt].state_cd=0)
      AND (requestin->list_0[i].state > " "))
      SET org->org[exists_id].address[org->org[exists_id].address_cnt].action_flag = - (1)
      SET org->org[exists_id].address[org->org[exists_id].address_cnt].error_string =
      "Invalid State (CS 62)"
     ENDIF
     IF ((org->org[exists_id].address[org->org[exists_id].address_cnt].country_cd=0)
      AND (requestin->list_0[i].country > " "))
      SET org->org[exists_id].address[org->org[exists_id].address_cnt].action_flag = - (1)
      SET org->org[exists_id].address[org->org[exists_id].address_cnt].error_string =
      "Invalid Country (CS 15)"
     ENDIF
     IF ((org->org[exists_id].address[org->org[exists_id].address_cnt].action_flag != - (1)))
      SET org->org[exists_id].address[org->org[exists_id].address_cnt].action_flag = 1
      IF ((org->org[exists_id].organization_id > 0))
       SET temp_active = 0
       SELECT INTO "NL:"
        FROM address a
        WHERE (a.parent_entity_id=org->org[exists_id].organization_id)
         AND a.parent_entity_name="ORGANIZATION"
         AND (a.address_type_cd=org->org[exists_id].address[org->org[exists_id].address_cnt].
        address_type_cd)
         AND cnvtupper(a.street_addr)=cnvtupper(org->org[exists_id].address[org->org[exists_id].
         address_cnt].street_addr)
         AND cnvtupper(a.street_addr2)=cnvtupper(org->org[exists_id].address[org->org[exists_id].
         address_cnt].street_addr2)
         AND cnvtupper(a.street_addr3)=cnvtupper(org->org[exists_id].address[org->org[exists_id].
         address_cnt].street_addr3)
         AND cnvtupper(a.street_addr4)=cnvtupper(org->org[exists_id].address[org->org[exists_id].
         address_cnt].street_addr4)
         AND cnvtupper(a.county)=cnvtupper(org->org[exists_id].address[org->org[exists_id].
         address_cnt].county)
         AND cnvtupper(a.city)=cnvtupper(org->org[exists_id].address[org->org[exists_id].address_cnt]
         .city)
         AND cnvtupper(a.country)=cnvtupper(org->org[exists_id].address[org->org[exists_id].
         address_cnt].country)
         AND cnvtupper(a.state)=cnvtupper(org->org[exists_id].address[org->org[exists_id].address_cnt
         ].state)
         AND cnvtupper(a.zipcode)=cnvtupper(org->org[exists_id].address[org->org[exists_id].
         address_cnt].zip)
         AND a.active_ind=1
        WITH nocounter
       ;end select
       IF (curqual > 0)
        SET org->org[exists_id].address[org->org[exists_id].address_cnt].action_flag = 2
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    IF ((requestin->list_0[i].phone_type != ""))
     SET org->org[exists_id].phone_cnt = (org->org[exists_id].phone_cnt+ 1)
     SET stat = alterlist(org->org[exists_id].phone,org->org[exists_id].phone_cnt)
     SET org->org[exists_id].phone[org->org[exists_id].phone_cnt].row_num = i
     SET org->org[exists_id].phone[org->org[exists_id].phone_cnt].phone_num = requestin->list_0[i].
     phone_num
     SET org->org[exists_id].phone[org->org[exists_id].phone_cnt].phone_type = requestin->list_0[i].
     phone_type
     SET org->org[exists_id].phone[org->org[exists_id].phone_cnt].phone_type_cd = get_cv_by_disp(43,
      org->org[exists_id].phone[org->org[exists_id].phone_cnt].phone_type)
     IF ((org->org[exists_id].phone[org->org[exists_id].phone_cnt].phone_type_cd=0))
      SET org->org[exists_id].phone[org->org[exists_id].phone_cnt].action_flag = - (1)
      SET org->org[exists_id].phone[org->org[exists_id].phone_cnt].error_string =
      "Invalid Phone Type (CS 43)"
     ENDIF
     IF ((org->org[exists_id].phone[org->org[exists_id].phone_cnt].action_flag != - (1)))
      SET org->org[exists_id].phone[org->org[exists_id].phone_cnt].action_flag = 1
      IF ((org->org[exists_id].organization_id > 0))
       SELECT INTO "NL:"
        FROM phone p
        WHERE (p.phone_type_cd=org->org[exists_id].phone[org->org[exists_id].phone_cnt].phone_type_cd
        )
         AND (p.parent_entity_id=org->org[exists_id].organization_id)
         AND p.parent_entity_name="ORGANIZATION"
         AND (p.phone_num=org->org[exists_id].phone[org->org[exists_id].phone_cnt].phone_num)
         AND p.active_ind=1
        WITH nocounter
       ;end select
       IF (curqual > 0)
        SET org->org[exists_id].phone[org->org[exists_id].phone_cnt].action_flag = 2
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    IF ((requestin->list_0[i].alias_pool != ""))
     SET org->org[exists_id].alias_cnt = (org->org[exists_id].alias_cnt+ 1)
     SET stat = alterlist(org->org[exists_id].alias,org->org[exists_id].alias_cnt)
     SET org->org[exists_id].alias[org->org[exists_id].alias_cnt].row_num = i
     SET org->org[exists_id].alias[org->org[exists_id].alias_cnt].alias = requestin->list_0[i].alias
     SET org->org[exists_id].alias[org->org[exists_id].alias_cnt].alias_pool = requestin->list_0[i].
     alias_pool
     SET org->org[exists_id].alias[org->org[exists_id].alias_cnt].alias_pool_cd = get_cv_by_disp(263,
      org->org[exists_id].alias[org->org[exists_id].alias_cnt].alias_pool)
     IF ((org->org[exists_id].alias[org->org[exists_id].alias_cnt].alias_pool_cd=0))
      SET org->org[exists_id].alias[org->org[exists_id].alias_cnt].action_flag = - (1)
      SET org->org[exists_id].alias[org->org[exists_id].alias_cnt].error_string =
      "Invalid Pool (CS 263)"
     ELSE
      SELECT INTO "NL:"
       FROM org_alias_pool_reltn oa
       WHERE oa.active_ind=1
        AND (oa.alias_pool_cd=org->org[exists_id].alias[org->org[exists_id].alias_cnt].alias_pool_cd)
       DETAIL
        org->org[exists_id].alias[org->org[exists_id].alias_cnt].alias_type_cd = oa
        .alias_entity_alias_type_cd, org->org[exists_id].alias[org->org[exists_id].alias_cnt].
        alias_type = oa.alias_entity_name
       WITH nocounter
      ;end select
      IF ((org->org[exists_id].alias[org->org[exists_id].alias_cnt].alias_type_cd=0))
       SET org->org[exists_id].alias[org->org[exists_id].alias_cnt].action_flag = - (1)
       SET org->org[exists_id].alias[org->org[exists_id].alias_cnt].error_string =
       "No Valid Alias Type"
      ENDIF
     ENDIF
     IF ((org->org[exists_id].alias[org->org[exists_id].alias_cnt].action_flag != - (1)))
      SET org->org[exists_id].alias[org->org[exists_id].alias_cnt].action_flag = 1
      IF ((org->org[exists_id].organization_id > 0))
       SELECT INTO "NL:"
        FROM organization_alias oa
        PLAN (oa
         WHERE (oa.organization_id=org->org[exists_id].organization_id)
          AND (oa.alias_pool_cd=org->org[exists_id].alias[org->org[exists_id].alias_cnt].
         alias_pool_cd)
          AND (oa.org_alias_type_cd=org->org[exists_id].alias[org->org[exists_id].alias_cnt].
         alias_type_cd)
          AND (oa.alias=org->org[exists_id].alias[org->org[exists_id].alias_cnt].alias)
          AND oa.active_ind=1)
        WITH nocounter
       ;end select
       IF (curqual > 0)
        SET org->org[exists_id].alias[org->org[exists_id].alias_cnt].action_flag = 2
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 IF (write_mode=1
  AND (org->org_cnt > 0))
  FOR (i = 1 TO org->org_cnt)
    IF ((org->org[i].action_flag=1))
     SELECT INTO "nl:"
      y = seq(organization_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       org->org[i].organization_id = cnvtreal(y)
      WITH format, nocounter
     ;end select
    ENDIF
  ENDFOR
  IF (data_partition_ind=1
   AND logical_domain_column_ind=1)
   INSERT  FROM organization o,
     (dummyt d  WITH seq = org->org_cnt)
    SET o.seq = 1, o.organization_id = org->org[d.seq].organization_id, o.contributor_system_cd = 0,
     o.org_name = org->org[d.seq].name, o.org_name_key = cnvtupper(cnvtalphanum(org->org[d.seq].name)
      ), o.federal_tax_id_nbr = "",
     o.org_status_cd = 0, o.ft_entity_id = 0, o.ft_entity_name = "",
     o.org_class_cd = org_class_cd, o.data_status_cd = auth_cd, o.data_status_dt_tm = cnvtdatetime(
      curdate,curtime3),
     o.data_status_prsnl_id = reqinfo->updt_id, o.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3
      ), o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
     o.active_ind = 1, o.active_status_cd = active_cd, o.active_status_prsnl_id = reqinfo->updt_id,
     o.active_status_dt_tm = cnvtdatetime(curdate,curtime), o.updt_cnt = 0, o.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     o.updt_id = reqinfo->updt_id, o.updt_applctx = reqinfo->updt_applctx, o.updt_task = reqinfo->
     updt_task,
     o.logical_domain_id = org->org[d.seq].logical_domain_id
    PLAN (d
     WHERE (org->org[d.seq].action_flag=1))
     JOIN (o)
    WITH nocounter
   ;end insert
  ELSE
   INSERT  FROM organization o,
     (dummyt d  WITH seq = org->org_cnt)
    SET o.seq = 1, o.organization_id = org->org[d.seq].organization_id, o.contributor_system_cd = 0,
     o.org_name = org->org[d.seq].name, o.org_name_key = cnvtupper(cnvtalphanum(org->org[d.seq].name)
      ), o.federal_tax_id_nbr = "",
     o.org_status_cd = 0, o.ft_entity_id = 0, o.ft_entity_name = "",
     o.org_class_cd = org_class_cd, o.data_status_cd = auth_cd, o.data_status_dt_tm = cnvtdatetime(
      curdate,curtime3),
     o.data_status_prsnl_id = reqinfo->updt_id, o.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3
      ), o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
     o.active_ind = 1, o.active_status_cd = active_cd, o.active_status_prsnl_id = reqinfo->updt_id,
     o.active_status_dt_tm = cnvtdatetime(curdate,curtime), o.updt_cnt = 0, o.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     o.updt_id = reqinfo->updt_id, o.updt_applctx = reqinfo->updt_applctx, o.updt_task = reqinfo->
     updt_task
    PLAN (d
     WHERE (org->org[d.seq].action_flag=1))
     JOIN (o)
    WITH nocounter
   ;end insert
  ENDIF
  UPDATE  FROM organization o,
    (dummyt d  WITH seq = org->org_cnt)
   SET o.seq = 1, o.org_name = org->org[d.seq].name, o.org_name_key = cnvtupper(cnvtalphanum(org->
      org[d.seq].name))
   PLAN (d
    WHERE (org->org[d.seq].action_flag=2))
    JOIN (o
    WHERE (o.organization_id=org->org[d.seq].organization_id))
   WITH nocounter
  ;end update
  INSERT  FROM org_type_reltn o,
    (dummyt d  WITH seq = org->org_cnt)
   SET o.seq = 1, o.organization_id = org->org[d.seq].organization_id, o.org_type_cd = ins_cd,
    o.updt_cnt = 0, o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id,
    o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->updt_applctx, o.active_ind = 1,
    o.active_status_cd = active_cd, o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o
    .active_status_prsnl_id = reqinfo->updt_id,
    o.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), o.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100")
   PLAN (d
    WHERE (org->org[d.seq].ins_ind=1))
    JOIN (o)
   WITH nocounter
  ;end insert
  INSERT  FROM org_type_reltn o,
    (dummyt d  WITH seq = org->org_cnt)
   SET o.seq = 1, o.organization_id = org->org[d.seq].organization_id, o.org_type_cd = emp_cd,
    o.updt_cnt = 0, o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id,
    o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->updt_applctx, o.active_ind = 1,
    o.active_status_cd = active_cd, o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o
    .active_status_prsnl_id = reqinfo->updt_id,
    o.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), o.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100")
   PLAN (d
    WHERE (org->org[d.seq].emp_ind=1))
    JOIN (o)
   WITH nocounter
  ;end insert
  UPDATE  FROM org_type_reltn o,
    (dummyt d  WITH seq = org->org_cnt)
   SET o.seq = 1, o.updt_cnt = (o.updt_cnt+ 1), o.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    o.updt_id = reqinfo->updt_id, o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->
    updt_applctx,
    o.active_ind = 0, o.active_status_cd = inactive_cd
   PLAN (d
    WHERE (org->org[d.seq].ins_ind=- (1)))
    JOIN (o
    WHERE (o.organization_id=org->org[d.seq].organization_id))
   WITH nocounter
  ;end update
  UPDATE  FROM org_type_reltn o,
    (dummyt d  WITH seq = org->org_cnt)
   SET o.seq = 1, o.updt_cnt = (o.updt_cnt+ 1), o.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    o.updt_id = reqinfo->updt_id, o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->
    updt_applctx,
    o.active_ind = 0, o.active_status_cd = inactive_cd
   PLAN (d
    WHERE (org->org[d.seq].emp_ind=- (1)))
    JOIN (o
    WHERE (o.organization_id=org->org[d.seq].organization_id))
   WITH nocounter
  ;end update
  FOR (i = 1 TO org->org_cnt)
    IF ((org->org[i].address_cnt > 0))
     INSERT  FROM address a,
       (dummyt d  WITH seq = org->org[i].address_cnt)
      SET a.seq = 1, a.address_id = seq(address_seq,nextval), a.parent_entity_name = "ORGANIZATION",
       a.parent_entity_id = org->org[i].organization_id, a.address_type_cd = org->org[i].address[d
       .seq].address_type_cd, a.active_ind = 1,
       a.residence_type_cd = 0.00, a.street_addr = org->org[i].address[d.seq].street_addr, a
       .street_addr2 = org->org[i].address[d.seq].street_addr2,
       a.street_addr3 = org->org[i].address[d.seq].street_addr3, a.street_addr4 = org->org[i].
       address[d.seq].street_addr4, a.city = org->org[i].address[d.seq].city,
       a.state = org->org[i].address[d.seq].state, a.state_cd = org->org[i].address[d.seq].state_cd,
       a.zipcode = org->org[i].address[d.seq].zip,
       a.zip_code_group_cd = 0.00, a.country = org->org[i].address[d.seq].country, a.country_cd = org
       ->org[i].address[d.seq].country_cd,
       a.county = org->org[i].address[d.seq].county, a.county_cd = org->org[i].address[d.seq].
       county_cd, a.residence_cd = 0.00,
       a.long_text_id = 0.00, a.address_info_status_cd = 0.00, a.primary_care_cd = 0.00,
       a.district_health_cd = 0.00, a.zipcode_key = trim(cnvtupper(cnvtalphanum(org->org[i].address[d
          .seq].zip))), a.active_status_cd = active_cd,
       a.active_status_dt_tm = cnvtdatetime(curdate,curtime3), a.active_status_prsnl_id = reqinfo->
       updt_id, a.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       a.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), a.data_status_cd = auth_cd, a
       .data_status_dt_tm = cnvtdatetime(curdate,curtime3),
       a.data_status_prsnl_id = reqinfo->updt_id, a.contributor_system_cd = 0.00, a.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->
       updt_applctx,
       a.updt_cnt = 0
      PLAN (d
       WHERE (org->org[i].address[d.seq].action_flag=1))
       JOIN (a)
      WITH nocounter
     ;end insert
    ENDIF
    IF ((org->org[i].phone_cnt > 0))
     INSERT  FROM phone p,
       (dummyt d  WITH seq = org->org[i].phone_cnt)
      SET p.seq = 1, p.phone_id = seq(phone_seq,nextval), p.parent_entity_name = "ORGANIZATION",
       p.parent_entity_id = org->org[i].organization_id, p.phone_type_cd = org->org[i].phone[d.seq].
       phone_type_cd, p.phone_format_cd = freetext_cd,
       p.phone_num = org->org[i].phone[d.seq].phone_num, p.phone_num_key = cnvtupper(cnvtalphanum(org
         ->org[i].phone[d.seq].phone_num)), p.phone_type_seq = d.seq,
       p.modem_capability_cd = 0.00, p.long_text_id = 0.00, p.active_ind = 1,
       p.active_status_cd = active_cd, p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p
       .active_status_prsnl_id = reqinfo->updt_id,
       p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.end_effective_dt_tm = cnvtdatetime(
        "31-dec-2100 00:00:00"), p.data_status_cd = auth_cd,
       p.data_status_dt_tm = cnvtdatetime(curdate,curtime3), p.data_status_prsnl_id = reqinfo->
       updt_id, p.contributor_system_cd = 0.00,
       p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_task =
       reqinfo->updt_task,
       p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0
      PLAN (d
       WHERE (org->org[i].phone[d.seq].action_flag=1))
       JOIN (p)
      WITH nocounter
     ;end insert
    ENDIF
    IF ((org->org[i].alias_cnt > 0))
     INSERT  FROM organization_alias o,
       (dummyt d  WITH seq = org->org[i].alias_cnt)
      SET o.seq = 1, o.organization_alias_id = seq(organization_seq,nextval), o.organization_id = org
       ->org[i].organization_id,
       o.updt_cnt = 0, o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id,
       o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->updt_applctx, o.active_ind = 1,
       o.active_status_cd = active_cd, o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o
       .active_status_prsnl_id = reqinfo->updt_id,
       o.alias_pool_cd = org->org[i].alias[d.seq].alias_pool_cd, o.org_alias_type_cd = org->org[i].
       alias[d.seq].alias_type_cd, o.alias = org->org[i].alias[d.seq].alias,
       o.check_digit = 0, o.check_digit_method_cd = 0, o.beg_effective_dt_tm = cnvtdatetime(curdate,
        curtime3),
       o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), o.data_status_cd = auth_cd, o
       .data_status_dt_tm = cnvtdatetime(curdate,curtime3),
       o.data_status_prsnl_id = reqinfo->updt_id, o.contributor_system_cd = 0
      PLAN (d
       WHERE (org->org[i].alias[d.seq].action_flag=1))
       JOIN (o)
      WITH nocounter
     ;end insert
    ENDIF
  ENDFOR
 ENDIF
 SELECT INTO value(name)
  FROM (dummyt d  WITH seq = org->org_cnt)
  DETAIL
   col 2, "---------------------", row + 1,
   col 1, org->org[d.seq].row_num"#####", col 10,
   org->org[d.seq].name
   IF ((org->org[d.seq].action_flag=1))
    col 90, "ADDED"
   ELSEIF ((org->org[d.seq].action_flag=2))
    col 90, "EXISTS"
   ELSEIF ((org->org[d.seq].action_flag=- (1)))
    col 90, "ERROR"
   ENDIF
   col 100, org->org[d.seq].error_string, row + 1
   IF ((org->org[d.seq].ins_ind=1))
    col 1, org->org[d.seq].row_num"#####", col 30,
    "TYPE", col 50, "Insurance Company",
    row + 1
   ENDIF
   IF ((org->org[d.seq].emp_ind=1))
    col 1, org->org[d.seq].row_num"#####", col 30,
    "TYPE", col 50, "Employer",
    row + 1
   ENDIF
   FOR (j = 1 TO org->org[d.seq].address_cnt)
     col 1, org->org[d.seq].address[j].row_num"#####", col 30,
     "ADDRESS TYPE", col 50, org->org[d.seq].address[j].address_type
     IF ((org->org[d.seq].address[j].action_flag=1))
      col 90, "ADDED"
     ELSEIF ((org->org[d.seq].address[j].action_flag=2))
      col 90, "EXISTS"
     ELSEIF ((org->org[d.seq].address[j].action_flag=- (1)))
      col 90, "ERROR"
     ENDIF
     col 100, org->org[d.seq].address[j].error_string, row + 1,
     col 1, org->org[d.seq].address[j].row_num"#####", col 30,
     "ADDRESS", col 50, org->org[d.seq].address[j].street_addr,
     row + 1
     IF ((org->org[d.seq].address[j].street_addr2 != ""))
      col 1, org->org[d.seq].address[j].row_num"#####", col 50,
      org->org[d.seq].address[j].street_addr2, row + 1
     ENDIF
     IF ((org->org[d.seq].address[j].street_addr3 != ""))
      col 1, org->org[d.seq].address[j].row_num"#####", col 50,
      org->org[d.seq].address[j].street_addr3, row + 1
     ENDIF
     IF ((org->org[d.seq].address[j].street_addr4 != ""))
      col 1, org->org[d.seq].address[j].row_num"#####", col 50,
      org->org[d.seq].address[j].street_addr4, row + 1
     ENDIF
     col 1, org->org[d.seq].address[j].row_num"#####", col 50,
     org->org[d.seq].address[j].city, col 70, org->org[d.seq].address[j].state,
     col 75, org->org[d.seq].address[j].zip, row + 1
     IF ((org->org[d.seq].address[j].county != ""))
      col 1, org->org[d.seq].address[j].row_num"#####", col 50,
      org->org[d.seq].address[j].county, row + 1
     ENDIF
     row + 1
   ENDFOR
   FOR (j = 1 TO org->org[d.seq].phone_cnt)
     col 1, org->org[d.seq].phone[j].row_num"#####", col 30,
     "PHONE TYPE", col 50, org->org[d.seq].phone[j].phone_type
     IF ((org->org[d.seq].phone[j].action_flag=1))
      col 90, "ADDED"
     ELSEIF ((org->org[d.seq].phone[j].action_flag=2))
      col 90, "EXISTS"
     ELSEIF ((org->org[d.seq].phone[j].action_flag=- (1)))
      col 90, "ERROR"
     ENDIF
     col 100, org->org[d.seq].phone[j].error_string, row + 1,
     col 1, org->org[d.seq].phone[j].row_num"#####", col 30,
     "PHONE NUMBER", col 50, org->org[d.seq].phone[j].phone_num,
     row + 1, row + 1
   ENDFOR
   FOR (j = 1 TO org->org[d.seq].alias_cnt)
     col 1, org->org[d.seq].alias[j].row_num"#####", col 30,
     "ALIAS POOL", col 50, org->org[d.seq].alias[j].alias_pool
     IF ((org->org[d.seq].alias[j].action_flag=1))
      col 90, "ADDED"
     ELSEIF ((org->org[d.seq].alias[j].action_flag=2))
      col 90, "EXISTS"
     ELSEIF ((org->org[d.seq].alias[j].action_flag=- (1)))
      col 90, "ERROR"
     ENDIF
     col 100, org->org[d.seq].alias[j].error_string, row + 1,
     col 1, org->org[d.seq].alias[j].row_num"#####", col 30,
     "ALIAS", col 50, org->org[d.seq].alias[j].alias,
     row + 1, row + 1
   ENDFOR
  WITH nocounter, append, format = variable,
   noformfeed, maxcol = 132
 ;end select
 SET error_flag = "N"
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
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
     col 10, "ORGANIZATION", col 30,
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
#9999_end
END GO
