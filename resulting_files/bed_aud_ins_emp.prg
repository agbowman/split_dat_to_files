CREATE PROGRAM bed_aud_ins_emp
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 FREE SET org
 RECORD org(
   1 org[*]
     2 organization_id = f8
     2 name = vc
     2 type = vc
     2 address_cnt = i4
     2 phone_cnt = i4
     2 alias_cnt = i4
     2 address[*]
       3 address_type = vc
       3 street_addr = vc
       3 street_addr2 = vc
       3 city = vc
       3 state = vc
       3 zip = vc
       3 country = vc
     2 phone[*]
       3 phone_type = vc
       3 phone_num = vc
     2 alias[*]
       3 alias_pool = vc
       3 alias = vc
     2 timely_filing_configuration_cnt = i4
     2 timely_filing_configuration[*]
       3 limit_days = i4
       3 auto_release_days = i4
       3 notify_days = i4
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
 )
 FREE SET output
 RECORD output(
   1 line[*]
     2 linestr = vc
 )
#1000_initialize
 SET reply->status_data.status = "F"
 SET error_flag = "Y"
 SET log_name = "ccluserdir:bed_exp_ins_emp.csv"
 SET auth_cd = get_code_value(8,"AUTH")
 SET ins_cd = 0.0
 SET emp_cd = 0.0
 SET ins_disp = "                                       "
 SET emp_disp = "                                       "
 SELECT INTO "NL:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=278
    AND c.cdf_meaning IN ("INSCO", "EMPLOYER")
    AND c.active_ind=1)
  DETAIL
   IF (c.cdf_meaning="INSCO")
    ins_cd = c.code_value, ins_disp = c.display
   ELSE
    emp_cd = c.code_value, emp_disp = c.display
   ENDIF
  WITH nocounter
 ;end select
 SET field_found = 0
 RANGE OF c IS code_value_set
 SET field_found = validate(c.br_client_id)
 FREE RANGE c
 IF (field_found=0)
  SET prg_exists_ind = 0
  SET prg_exists_ind = checkprg("ACM_GET_ACC_LOGICAL_DOMAINS")
  IF (prg_exists_ind > 0)
   SET field_found = 0
   RANGE OF p IS prsnl
   SET field_found = validate(p.logical_domain_id)
   FREE RANGE p
   IF (field_found=1)
    SET data_partition_ind = 1
    FREE SET acm_get_curr_logical_domain_req
    RECORD acm_get_curr_logical_domain_req(
      1 concept = i4
    )
    FREE SET acm_get_curr_logical_domain_rep
    RECORD acm_get_curr_logical_domain_rep(
      1 logical_domain_id = f8
      1 status_block
        2 status_ind = i2
        2 error_code = i4
    )
    SET acm_get_curr_logical_domain_req->concept = 4
    EXECUTE acm_get_curr_logical_domain  WITH replace("REQUEST",acm_get_curr_logical_domain_req),
    replace("REPLY",acm_get_curr_logical_domain_rep)
   ENDIF
  ENDIF
 ENDIF
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM organization o,
    org_type_reltn otr
   PLAN (o
    WHERE o.active_ind=1
     AND o.data_status_cd=auth_cd
     AND (o.logical_domain_id=acm_get_curr_logical_domain_rep->logical_domain_id))
    JOIN (otr
    WHERE o.organization_id=otr.organization_id
     AND otr.org_type_cd IN (ins_cd, emp_cd))
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 3000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET org_cnt = 0
 SELECT INTO "NL:"
  FROM organization o,
   org_type_reltn otr
  PLAN (otr
   WHERE otr.org_type_cd IN (ins_cd, emp_cd)
    AND otr.active_ind=1)
   JOIN (o
   WHERE otr.organization_id=o.organization_id
    AND o.active_ind=1
    AND o.data_status_cd=auth_cd
    AND o.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND (o.logical_domain_id=acm_get_curr_logical_domain_rep->logical_domain_id))
  ORDER BY o.org_name
  HEAD o.organization_id
   org_cnt = (org_cnt+ 1), stat = alterlist(org->org,org_cnt), org->org[org_cnt].organization_id = o
   .organization_id,
   org->org[org_cnt].name = o.org_name
  DETAIL
   IF (otr.org_type_cd=ins_cd)
    IF ((org->org[org_cnt].type=""))
     org->org[org_cnt].type = ins_disp
    ELSE
     org->org[org_cnt].type = "Both"
    ENDIF
   ELSE
    IF ((org->org[org_cnt].type=""))
     org->org[org_cnt].type = emp_disp
    ELSE
     org->org[org_cnt].type = "Both"
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM organization o,
   address a,
   code_value c,
   (dummyt d  WITH seq = org_cnt)
  PLAN (d)
   JOIN (o
   WHERE (o.organization_id=org->org[d.seq].organization_id))
   JOIN (a
   WHERE a.parent_entity_id=o.organization_id
    AND a.parent_entity_name="ORGANIZATION"
    AND a.active_ind=1)
   JOIN (c
   WHERE c.code_value=a.address_type_cd)
  ORDER BY a.address_id
  HEAD a.address_id
   org->org[d.seq].address_cnt = (org->org[d.seq].address_cnt+ 1), stat = alterlist(org->org[d.seq].
    address,org->org[d.seq].address_cnt)
  DETAIL
   org->org[d.seq].address[org->org[d.seq].address_cnt].address_type = c.display, org->org[d.seq].
   address[org->org[d.seq].address_cnt].street_addr = a.street_addr, org->org[d.seq].address[org->
   org[d.seq].address_cnt].street_addr2 = a.street_addr2,
   org->org[d.seq].address[org->org[d.seq].address_cnt].city = a.city, org->org[d.seq].address[org->
   org[d.seq].address_cnt].state = a.state, org->org[d.seq].address[org->org[d.seq].address_cnt].zip
    = a.zipcode,
   org->org[d.seq].address[org->org[d.seq].address_cnt].country = a.country
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM organization o,
   phone p,
   code_value c,
   (dummyt d  WITH seq = org_cnt)
  PLAN (d)
   JOIN (o
   WHERE (o.organization_id=org->org[d.seq].organization_id))
   JOIN (p
   WHERE p.parent_entity_id=o.organization_id
    AND p.parent_entity_name="ORGANIZATION"
    AND p.active_ind=1)
   JOIN (c
   WHERE c.code_value=p.phone_type_cd)
  ORDER BY p.phone_id
  HEAD p.phone_id
   org->org[d.seq].phone_cnt = (org->org[d.seq].phone_cnt+ 1), stat = alterlist(org->org[d.seq].phone,
    org->org[d.seq].phone_cnt)
  DETAIL
   org->org[d.seq].phone[org->org[d.seq].phone_cnt].phone_type = c.display, org->org[d.seq].phone[org
   ->org[d.seq].phone_cnt].phone_num = p.phone_num
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM organization o,
   organization_alias oa,
   code_value c,
   (dummyt d  WITH seq = org_cnt)
  PLAN (d)
   JOIN (o
   WHERE (o.organization_id=org->org[d.seq].organization_id))
   JOIN (oa
   WHERE oa.organization_id=o.organization_id
    AND oa.active_ind=1)
   JOIN (c
   WHERE c.code_value=oa.alias_pool_cd)
  ORDER BY oa.organization_alias_id
  HEAD oa.organization_alias_id
   org->org[d.seq].alias_cnt = (org->org[d.seq].alias_cnt+ 1), stat = alterlist(org->org[d.seq].alias,
    org->org[d.seq].alias_cnt)
  DETAIL
   org->org[d.seq].alias[org->org[d.seq].alias_cnt].alias = oa.alias, org->org[d.seq].alias[org->org[
   d.seq].alias_cnt].alias_pool = c.display
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM organization o,
   org_timely_filing otf,
   (dummyt d  WITH seq = org_cnt)
  PLAN (d)
   JOIN (o
   WHERE (o.organization_id=org->org[d.seq].organization_id))
   JOIN (otf
   WHERE otf.organization_id=o.organization_id
    AND otf.active_ind=1)
  ORDER BY otf.organization_id, cnvtdatetime(otf.beg_effective_dt_tm)
  HEAD otf.org_timely_filing_id
   org->org[d.seq].timely_filing_configuration_cnt = (org->org[d.seq].timely_filing_configuration_cnt
   + 1), stat = alterlist(org->org[d.seq].timely_filing_configuration,org->org[d.seq].
    timely_filing_configuration_cnt)
  DETAIL
   org->org[d.seq].timely_filing_configuration[org->org[d.seq].timely_filing_configuration_cnt].
   limit_days = otf.limit_days, org->org[d.seq].timely_filing_configuration[org->org[d.seq].
   timely_filing_configuration_cnt].auto_release_days = otf.auto_release_days, org->org[d.seq].
   timely_filing_configuration[org->org[d.seq].timely_filing_configuration_cnt].notify_days = otf
   .notify_days,
   org->org[d.seq].timely_filing_configuration[org->org[d.seq].timely_filing_configuration_cnt].
   beg_effective_dt_tm = otf.beg_effective_dt_tm, org->org[d.seq].timely_filing_configuration[org->
   org[d.seq].timely_filing_configuration_cnt].end_effective_dt_tm = otf.end_effective_dt_tm
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,19)
 SET reply->collist[1].header_text = "Organization ID"
 SET reply->collist[1].data_type = 2
 SET reply->collist[1].hide_ind = 1
 SET reply->collist[2].header_text = "Organization Name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Organization Type"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Address Type"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Street Address"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Street Address 2"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "City"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "State"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Zip"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Country"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Phone Number Type"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Phone Number"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Organization Identifier Type"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = "Organization Identifier"
 SET reply->collist[14].data_type = 1
 SET reply->collist[14].hide_ind = 0
 SET reply->collist[15].header_text = "Timely Filing Days"
 SET reply->collist[15].data_type = 1
 SET reply->collist[15].hide_ind = 0
 SET reply->collist[16].header_text = "Auto-Release Claims"
 SET reply->collist[16].data_type = 1
 SET reply->collist[16].hide_ind = 0
 SET reply->collist[17].header_text = "Timely Filing Notification"
 SET reply->collist[17].data_type = 1
 SET reply->collist[17].hide_ind = 0
 SET reply->collist[18].header_text = "Begin Effective Date"
 SET reply->collist[18].data_type = 4
 SET reply->collist[18].hide_ind = 0
 SET reply->collist[19].header_text = " End Effective Date"
 SET reply->collist[19].data_type = 4
 SET reply->collist[19].hide_ind = 0
 SET lines = 0
 SET records = 0
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = org_cnt)
  DETAIL
   lines = maxval(1,org->org[d.seq].address_cnt,org->org[d.seq].alias_cnt,org->org[d.seq].phone_cnt,
    org->org[d.seq].timely_filing_configuration_cnt), stat = alterlist(reply->rowlist,(lines+ records
    ))
   FOR (i = (records+ 1) TO (lines+ records))
     stat = alterlist(reply->rowlist[i].celllist,19), reply->rowlist[i].celllist[1].double_value =
     org->org[d.seq].organization_id, reply->rowlist[i].celllist[2].string_value = org->org[d.seq].
     name,
     reply->rowlist[i].celllist[3].string_value = org->org[d.seq].type
   ENDFOR
   FOR (i = 1 TO org->org[d.seq].address_cnt)
     reply->rowlist[(i+ records)].celllist[4].string_value = org->org[d.seq].address[i].address_type,
     reply->rowlist[(i+ records)].celllist[5].string_value = org->org[d.seq].address[i].street_addr,
     reply->rowlist[(i+ records)].celllist[6].string_value = org->org[d.seq].address[i].street_addr2,
     reply->rowlist[(i+ records)].celllist[7].string_value = org->org[d.seq].address[i].city, reply->
     rowlist[(i+ records)].celllist[8].string_value = org->org[d.seq].address[i].state, reply->
     rowlist[(i+ records)].celllist[9].string_value = org->org[d.seq].address[i].zip,
     reply->rowlist[(i+ records)].celllist[10].string_value = org->org[d.seq].address[i].country
   ENDFOR
   FOR (i = 1 TO org->org[d.seq].phone_cnt)
    reply->rowlist[(i+ records)].celllist[11].string_value = org->org[d.seq].phone[i].phone_type,
    reply->rowlist[(i+ records)].celllist[12].string_value = org->org[d.seq].phone[i].phone_num
   ENDFOR
   FOR (i = 1 TO org->org[d.seq].alias_cnt)
    reply->rowlist[(i+ records)].celllist[13].string_value = org->org[d.seq].alias[i].alias_pool,
    reply->rowlist[(i+ records)].celllist[14].string_value = org->org[d.seq].alias[i].alias
   ENDFOR
   FOR (i = 1 TO org->org[d.seq].timely_filing_configuration_cnt)
     IF ((org->org[d.seq].timely_filing_configuration[i].limit_days > 0.0))
      reply->rowlist[(i+ records)].celllist[15].string_value = cnvtstring(org->org[d.seq].
       timely_filing_configuration[i].limit_days)
     ELSE
      reply->rowlist[(i+ records)].celllist[15].string_value = ""
     ENDIF
     IF ((org->org[d.seq].timely_filing_configuration[i].auto_release_days > 0.0))
      reply->rowlist[(i+ records)].celllist[16].string_value = cnvtstring(org->org[d.seq].
       timely_filing_configuration[i].auto_release_days)
     ELSE
      reply->rowlist[(i+ records)].celllist[516].string_value = ""
     ENDIF
     IF ((org->org[d.seq].timely_filing_configuration[i].notify_days > 0.0))
      reply->rowlist[(i+ records)].celllist[17].string_value = cnvtstring(org->org[d.seq].
       timely_filing_configuration[i].notify_days)
     ELSE
      reply->rowlist[(i+ records)].celllist[17].string_value = ""
     ENDIF
     reply->rowlist[(i+ records)].celllist[18].date_value = org->org[d.seq].
     timely_filing_configuration[i].beg_effective_dt_tm, reply->rowlist[(i+ records)].celllist[19].
     date_value = org->org[d.seq].timely_filing_configuration[i].end_effective_dt_tm
   ENDFOR
   records = (records+ lines)
  WITH nocounter
 ;end select
 SET error_flag = "N"
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
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
      AND cnvtupper(c.display)=trim(cnvtupper(xdisp)))
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("insurance_comp_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
