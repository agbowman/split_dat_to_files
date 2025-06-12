CREATE PROGRAM bed_aud_erx_reltns:dba
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
 FREE RECORD temp_rep
 RECORD temp_rep(
   1 locations[*]
     2 facility_id = f8
     2 facility_description = vc
     2 unit_description = vc
     2 unit_id = f8
     2 location_id = f8
     2 prsnl[*]
       3 prsnl_id = f8
       3 name_full_formatted = vc
       3 erx_reltns[*]
         4 submission_dt_tm = dq8
         4 prsnl_reltn_id = f8
         4 parent_entity_name = vc
         4 parent_entity_id = f8
         4 display_seq = i4
         4 beg_effective_dt_tm = dq8
         4 end_effective_dt_tm = dq8
         4 service_level_mask = i4
         4 status_code_value = f8
         4 error_code_value = f8
         4 desc_error = vc
         4 child_reltns[*]
           5 prsnl_reltn_child_id = f8
           5 parent_entity_name = vc
           5 parent_entity_id = f8
           5 display_seq = i4
   1 max_phone_cnt = i4
 )
 FREE SET temp_locations
 RECORD temp_locations(
   1 locations[*]
     2 location_cd = f8
     2 facility_id = f8
     2 facility_description = vc
     2 unit_description = vc
     2 unit_id = f8
 )
 FREE RECORD tprsnl_alias
 RECORD tprsnl_alias(
   1 prsnl_aliases[*]
     2 prsnl_alias_id = f8
     2 alias_type_cd = vc
     2 alias = vc
 )
 FREE RECORD tprsn_alias
 RECORD tprsn_alias(
   1 person_aliases[*]
     2 person_alias_id = f8
     2 alias_type_cd = vc
     2 alias = vc
 )
 FREE RECORD taddress
 RECORD taddress(
   1 addresses[*]
     2 address_id = f8
     2 address_type_display = vc
     2 street_addr = vc
     2 street_addr2 = vc
     2 city = vc
     2 state = vc
     2 zipcode = vc
 )
 FREE RECORD tphone
 RECORD tphone(
   1 phones[*]
     2 phone_id = f8
     2 phone_type_display = vc
     2 phone_formatted = vc
 )
 DECLARE address_cnt = i4 WITH protect
 DECLARE prsn_alias_cnt = i4 WITH protect
 DECLARE prsnl_alias_cnt = i4 WITH protect
 DECLARE phone_cnt = i4 WITH protect
 DECLARE total_reltns_cnt = i4 WITH protect
 DECLARE loc_cnt = i4 WITH protect
 DECLARE tot_sort_cnt = i4 WITH protect
 SELECT INTO "nl:"
  FROM eprescribe_detail e,
   prsnl_reltn p,
   location l,
   code_value c,
   code_value c2
  PLAN (e)
   JOIN (p
   WHERE p.prsnl_reltn_id=e.prsnl_reltn_id
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND p.parent_entity_name="LOCATION")
   JOIN (l
   WHERE l.location_cd=p.parent_entity_id
    AND l.active_ind=1)
   JOIN (c
   WHERE c.code_value=l.location_cd
    AND c.active_ind=1)
   JOIN (c2
   WHERE c2.code_value=l.location_type_cd
    AND c2.active_ind=1)
  ORDER BY c.code_value
  HEAD REPORT
   loc_cnt = 0
  HEAD c.code_value
   loc_cnt = (loc_cnt+ 1), stat = alterlist(temp_locations->locations,loc_cnt), temp_locations->
   locations[loc_cnt].location_cd = c.code_value
   IF (c2.cdf_meaning="FACILITY")
    temp_locations->locations[loc_cnt].facility_id = c.code_value, temp_locations->locations[loc_cnt]
    .facility_description = c.description
   ELSEIF (c2.cdf_meaning IN ("AMBULATORY", "NURSEUNIT"))
    temp_locations->locations[loc_cnt].unit_id = c.code_value, temp_locations->locations[loc_cnt].
    unit_description = c.description
   ENDIF
  DETAIL
   total_reltns_cnt = (total_reltns_cnt+ 1)
  WITH nocounter
 ;end select
 IF ((request->skip_volume_check_ind=0))
  CALL echo(total_reltns_cnt)
  IF (total_reltns_cnt > 20000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (total_reltns_cnt > 5000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 IF (total_reltns_cnt=0)
  GO TO exit_script
 ENDIF
 SET facility_code = uar_get_code_by("MEANING",222,"FACILITY")
 SET building_code = uar_get_code_by("MEANING",222,"BUILDING")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(loc_cnt)),
   location_group lg,
   location l,
   location_group lg2,
   location l2,
   code_value c
  PLAN (d
   WHERE (temp_locations->locations[d.seq].unit_id > 0))
   JOIN (lg
   WHERE (lg.child_loc_cd=temp_locations->locations[d.seq].unit_id)
    AND lg.root_loc_cd=0
    AND lg.location_group_type_cd=building_code
    AND lg.active_ind=1)
   JOIN (l
   WHERE l.location_cd=lg.parent_loc_cd
    AND l.active_ind=1)
   JOIN (lg2
   WHERE lg2.child_loc_cd=lg.parent_loc_cd
    AND lg2.active_ind=1
    AND lg2.location_group_type_cd=facility_code
    AND lg2.root_loc_cd=0)
   JOIN (l2
   WHERE l2.location_cd=lg2.parent_loc_cd
    AND l2.active_ind=1)
   JOIN (c
   WHERE c.code_value=l2.location_cd
    AND c.active_ind=1)
  ORDER BY d.seq
  HEAD d.seq
   temp_locations->locations[d.seq].facility_id = c.code_value, temp_locations->locations[d.seq].
   facility_description = c.description
  WITH nocounter
 ;end select
 SET tot_sort_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(loc_cnt)),
   code_value c,
   code_value c2
  PLAN (d)
   JOIN (c
   WHERE (c.code_value=temp_locations->locations[d.seq].facility_id))
   JOIN (c2
   WHERE (c2.code_value=temp_locations->locations[d.seq].unit_id))
  ORDER BY cnvtupper(c.description), cnvtupper(c2.description)
  HEAD REPORT
   stat = alterlist(temp_rep->locations,10), sort_cnt = 0, tot_sort_cnt = 0
  DETAIL
   sort_cnt = (sort_cnt+ 1), tot_sort_cnt = (tot_sort_cnt+ 1)
   IF (sort_cnt > 10)
    stat = alterlist(temp_rep->locations,(tot_sort_cnt+ 10)), sort_cnt = 1
   ENDIF
   temp_rep->locations[tot_sort_cnt].facility_id = temp_locations->locations[d.seq].facility_id,
   temp_rep->locations[tot_sort_cnt].facility_description = c.description, temp_rep->locations[
   tot_sort_cnt].unit_id = temp_locations->locations[d.seq].unit_id,
   temp_rep->locations[tot_sort_cnt].unit_description = c2.description, temp_rep->locations[
   tot_sort_cnt].location_id = temp_locations->locations[d.seq].location_cd
  FOOT REPORT
   stat = alterlist(temp_rep->locations,tot_sort_cnt)
  WITH nocounter
 ;end select
 DECLARE pparse = vc
 SET pparse = " p.person_id > 0 "
 SET auth_cd = uar_get_code_by("MEANING",8,"AUTH")
 SET active_code = uar_get_code_by("MEANING",48,"ACTIVE")
 SET prsnl_code = uar_get_code_by("MEANING",213,"PRSNL")
 SET npi_code = uar_get_code_by("MEANING",320,"NPI")
 SET reltn_type_code_value = uar_get_code_by("MEANING",30300,"EPRESCRELTN")
 SET pparse = concat(pparse," and p.active_ind = 1 ",
  " and p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) ",
  "  and p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3) ")
 SET pparse = build(pparse," and p.data_status_cd  = ",auth_cd)
 SET data_partition_ind = 0
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
    FREE SET acm_get_acc_logical_domains_req
    RECORD acm_get_acc_logical_domains_req(
      1 write_mode_ind = i2
      1 concept = i4
    )
    FREE SET acm_get_acc_logical_domains_rep
    RECORD acm_get_acc_logical_domains_rep(
      1 logical_domain_grp_id = f8
      1 logical_domains_cnt = i4
      1 logical_domains[*]
        2 logical_domain_id = f8
      1 status_block
        2 status_ind = i2
        2 error_code = i4
    )
    SET acm_get_acc_logical_domains_req->write_mode_ind = 0
    SET acm_get_acc_logical_domains_req->concept = 2
    EXECUTE acm_get_acc_logical_domains  WITH replace("REQUEST",acm_get_acc_logical_domains_req),
    replace("REPLY",acm_get_acc_logical_domains_rep)
   ENDIF
  ENDIF
 ENDIF
 IF (data_partition_ind=1)
  IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
   SET pparse = concat(pparse," and p.logical_domain_id in (")
   FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
     IF ((d=acm_get_acc_logical_domains_rep->logical_domains_cnt))
      SET pparse = build(pparse,acm_get_acc_logical_domains_rep->logical_domains[d].logical_domain_id,
       ")")
     ELSE
      SET pparse = build(pparse,acm_get_acc_logical_domains_rep->logical_domains[d].logical_domain_id,
       ",")
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 CALL echo(pparse)
 SET address_cnt = 0
 SET prsn_alias_cnt = 0
 SET prsnl_alias_cnt = 0
 SET phone_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(tot_sort_cnt)),
   prsnl_reltn pr,
   prsnl_reltn_child c,
   eprescribe_detail e,
   prsnl p,
   person_name pn
  PLAN (d)
   JOIN (pr
   WHERE (pr.parent_entity_id=temp_rep->locations[d.seq].location_id)
    AND pr.parent_entity_name="LOCATION"
    AND pr.reltn_type_cd=reltn_type_code_value
    AND pr.active_ind=1
    AND pr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (e
   WHERE e.prsnl_reltn_id=pr.prsnl_reltn_id)
   JOIN (c
   WHERE c.prsnl_reltn_id=pr.prsnl_reltn_id
    AND c.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND c.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=pr.person_id
    AND parser(pparse))
   JOIN (pn
   WHERE pn.person_id=p.person_id
    AND pn.active_ind=1
    AND pn.name_type_cd=prsnl_code
    AND pn.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pn.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY d.seq, pn.name_full, p.person_id,
   pr.prsnl_reltn_id, c.display_seq
  HEAD REPORT
   max_phone_total_cnt = 0
  HEAD d.seq
   listcnt = 0, pcnt = 0, stat = alterlist(temp_rep->locations[d.seq].prsnl,10)
  HEAD p.person_id
   pcnt = (pcnt+ 1), listcnt = (listcnt+ 1)
   IF (listcnt > 10)
    listcnt = 1, stat = alterlist(temp_rep->locations[d.seq].prsnl,(pcnt+ 10))
   ENDIF
   temp_rep->locations[d.seq].prsnl[pcnt].prsnl_id = p.person_id, temp_rep->locations[d.seq].prsnl[
   pcnt].name_full_formatted = pn.name_full, rcnt = 0,
   rtcnt = 0, stat = alterlist(temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns,10)
  HEAD pr.prsnl_reltn_id
   total_phones_per_reltn = 0, rcnt = (rcnt+ 1), rtcnt = (rtcnt+ 1)
   IF (rcnt > 10)
    stat = alterlist(temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns,(rtcnt+ 10)), rcnt = 1
   ENDIF
   temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].prsnl_reltn_id = pr.prsnl_reltn_id,
   temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].display_seq = pr.display_seq, temp_rep->
   locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].submission_dt_tm = e.submit_dt_tm,
   temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].parent_entity_id = pr.parent_entity_id,
   temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].parent_entity_name = pr
   .parent_entity_name, temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].service_level_mask
    = e.service_level_nbr,
   temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].beg_effective_dt_tm = e
   .beg_effective_dt_tm, temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].end_effective_dt_tm
    = e.end_effective_dt_tm, temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].
   status_code_value = e.status_cd,
   temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].error_code_value = e.error_cd, temp_rep->
   locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].desc_error = e.error_desc, ccnt = 0,
   ctcnt = 0, stat = alterlist(temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].child_reltns,
    10)
  DETAIL
   ccnt = (ccnt+ 1), ctcnt = (ctcnt+ 1)
   IF (ccnt > 10)
    stat = alterlist(temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].child_reltns,(ctcnt+ 10
     )), ccnt = 1
   ENDIF
   temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].child_reltns[ctcnt].display_seq = c
   .display_seq, temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].child_reltns[ctcnt].
   parent_entity_id = c.parent_entity_id, temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].
   child_reltns[ctcnt].parent_entity_name = c.parent_entity_name,
   temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].child_reltns[ctcnt].prsnl_reltn_child_id
    = c.prsnl_reltn_child_id
   IF (c.parent_entity_name="PRSNL_ALIAS")
    prsnl_alias_cnt = (prsnl_alias_cnt+ 1), stat = alterlist(tprsnl_alias->prsnl_aliases,
     prsnl_alias_cnt), tprsnl_alias->prsnl_aliases[prsnl_alias_cnt].prsnl_alias_id = c
    .parent_entity_id
   ELSEIF (c.parent_entity_name="PERSON_ALIAS")
    prsn_alias_cnt = (prsn_alias_cnt+ 1), stat = alterlist(tprsn_alias->person_aliases,prsn_alias_cnt
     ), tprsn_alias->person_aliases[prsn_alias_cnt].person_alias_id = c.parent_entity_id
   ELSEIF (c.parent_entity_name="ADDRESS")
    address_cnt = (address_cnt+ 1), stat = alterlist(taddress->addresses,address_cnt), taddress->
    addresses[address_cnt].address_id = c.parent_entity_id
   ELSEIF (c.parent_entity_name="PHONE")
    phone_cnt = (phone_cnt+ 1), stat = alterlist(tphone->phones,phone_cnt), tphone->phones[phone_cnt]
    .phone_id = c.parent_entity_id,
    total_phones_per_reltn = (total_phones_per_reltn+ 1)
   ENDIF
  FOOT  pr.prsnl_reltn_id
   stat = alterlist(temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].child_reltns,ctcnt)
   IF (total_phones_per_reltn > max_phone_total_cnt)
    max_phone_total_cnt = total_phones_per_reltn
   ENDIF
  FOOT  p.person_id
   stat = alterlist(temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns,rtcnt)
  FOOT  d.seq
   stat = alterlist(temp_rep->locations[d.seq].prsnl,pcnt)
  FOOT REPORT
   temp_rep->max_phone_cnt = max_phone_total_cnt
  WITH nocounter
 ;end select
 DECLARE col_cnt_wo_phones = i4 WITH protected
 DECLARE phone_col_cnt = i4 WITH private
 DECLARE col_cnt = i4 WITH private
 SET col_cnt_wo_phones = 25
 SET phone_col_cnt = (temp_rep->max_phone_cnt * 2)
 SET col_cnt = (col_cnt_wo_phones+ phone_col_cnt)
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Facility"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Location"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Provider"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Status"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Error Message"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Submission Date"
 SET reply->collist[6].data_type = 4
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "SPI Alias"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "NPI Alias"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "DOCDEA Alias"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "DOCUPIN Alias"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "GDP Alias"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "LICENSENBR Alias"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Medicaid Alias"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = "Med History Service Level"
 SET reply->collist[14].data_type = 1
 SET reply->collist[14].hide_ind = 0
 SET reply->collist[15].header_text = "New RX Service Level"
 SET reply->collist[15].data_type = 1
 SET reply->collist[15].hide_ind = 0
 SET reply->collist[16].header_text = "Refill Service Level"
 SET reply->collist[16].data_type = 1
 SET reply->collist[16].hide_ind = 0
 SET reply->collist[17].header_text = "Controlled Substances Service Level"
 SET reply->collist[17].data_type = 1
 SET reply->collist[17].hide_ind = 0
 SET reply->collist[18].header_text = "Begin Effective Date"
 SET reply->collist[18].data_type = 4
 SET reply->collist[18].hide_ind = 0
 SET reply->collist[19].header_text = "End Effective Date"
 SET reply->collist[19].data_type = 4
 SET reply->collist[19].hide_ind = 0
 SET reply->collist[20].header_text = "Address Type"
 SET reply->collist[20].data_type = 1
 SET reply->collist[20].hide_ind = 0
 SET reply->collist[21].header_text = "Address Line 1"
 SET reply->collist[21].data_type = 1
 SET reply->collist[21].hide_ind = 0
 SET reply->collist[22].header_text = "Address Line 2"
 SET reply->collist[22].data_type = 1
 SET reply->collist[22].hide_ind = 0
 SET reply->collist[23].header_text = "City"
 SET reply->collist[23].data_type = 1
 SET reply->collist[23].hide_ind = 0
 SET reply->collist[24].header_text = "State"
 SET reply->collist[24].data_type = 1
 SET reply->collist[24].hide_ind = 0
 SET reply->collist[25].header_text = "Zip Code"
 SET reply->collist[25].data_type = 1
 SET reply->collist[25].hide_ind = 0
 DECLARE c = i4 WITH private
 SET cur_phone_cnt = 0
 FOR (c = 1 TO phone_col_cnt)
   SET cur_phone_cnt = (cur_phone_cnt+ 1)
   SET reply->collist[(col_cnt_wo_phones+ c)].header_text = concat("Phone "," ",trim(cnvtstring(
      cur_phone_cnt))," Type")
   SET reply->collist[(col_cnt_wo_phones+ c)].data_type = 1
   SET reply->collist[(col_cnt_wo_phones+ c)].hide_ind = 0
   SET c = (c+ 1)
   SET reply->collist[(col_cnt_wo_phones+ c)].header_text = concat("Phone "," ",trim(cnvtstring(
      cur_phone_cnt))," Number")
   SET reply->collist[(col_cnt_wo_phones+ c)].data_type = 1
   SET reply->collist[(col_cnt_wo_phones+ c)].hide_ind = 0
 ENDFOR
 CALL load_child_reltn_info(1)
 SET row_cnt = 0
 DECLARE y = i4 WITH private
 DECLARE x = i4 WITH private
 DECLARE row_cnt = i4 WITH private
 FOR (x = 1 TO tot_sort_cnt)
  SET prsnl_size = size(temp_rep->locations[x].prsnl,5)
  FOR (y = 1 TO prsnl_size)
   SET reltn_size = size(temp_rep->locations[x].prsnl[y].erx_reltns,5)
   IF (reltn_size > 0)
    FOR (z = 1 TO reltn_size)
      SET row_cnt = (row_cnt+ 1)
      SET stat = alterlist(reply->rowlist,row_cnt)
      SET stat = alterlist(reply->rowlist[row_cnt].celllist,col_cnt)
      SET reply->rowlist[row_cnt].celllist[1].string_value = temp_rep->locations[x].
      facility_description
      SET reply->rowlist[row_cnt].celllist[2].string_value = temp_rep->locations[x].unit_description
      SET reply->rowlist[row_cnt].celllist[3].string_value = temp_rep->locations[x].prsnl[y].
      name_full_formatted
      SET status_cd = temp_rep->locations[x].prsnl[y].erx_reltns[z].status_code_value
      IF (status_cd > 0)
       SET reply->rowlist[row_cnt].celllist[4].string_value = uar_get_code_display(status_cd)
      ELSE
       SET reply->rowlist[row_cnt].celllist[4].string_value = "In Progress"
      ENDIF
      SET reply->rowlist[row_cnt].celllist[5].string_value = temp_rep->locations[x].prsnl[y].
      erx_reltns[z].desc_error
      SET reply->rowlist[row_cnt].celllist[6].date_value = cnvtdatetime(temp_rep->locations[x].prsnl[
       y].erx_reltns[z].submission_dt_tm)
      CALL add_children(x,y,z,row_cnt)
      CALL add_service_levels(x,y,z,row_cnt)
      SET reply->rowlist[row_cnt].celllist[18].date_value = cnvtdatetime(temp_rep->locations[x].
       prsnl[y].erx_reltns[z].beg_effective_dt_tm)
      SET reply->rowlist[row_cnt].celllist[19].date_value = cnvtdatetime(temp_rep->locations[x].
       prsnl[y].erx_reltns[z].end_effective_dt_tm)
    ENDFOR
   ENDIF
  ENDFOR
 ENDFOR
 CALL echo(build("Row Cnt: ",row_cnt))
 SUBROUTINE add_children(loc_pos,prsnl_pos,erx_pos,row_cnt)
   DECLARE parent_entity_name = vc
   SET phone_cnt_for_reltn = 0
   FOR (x = 1 TO size(temp_rep->locations[loc_pos].prsnl[prsnl_pos].erx_reltns[erx_pos].child_reltns,
    5))
     SET parent_entity_id = temp_rep->locations[loc_pos].prsnl[prsnl_pos].erx_reltns[erx_pos].
     child_reltns[x].parent_entity_id
     SET parent_entity_name = temp_rep->locations[loc_pos].prsnl[prsnl_pos].erx_reltns[erx_pos].
     child_reltns[x].parent_entity_name
     IF (parent_entity_name="PRSNL_ALIAS")
      SET num = 0
      SET alias_index = locateval(num,1,prsnl_alias_cnt,parent_entity_id,tprsnl_alias->prsnl_aliases[
       num].prsnl_alias_id)
      IF (alias_index > 0)
       CALL set_prsnl_alias_rowlist(tprsnl_alias->prsnl_aliases[alias_index].alias_type_cd,
        tprsnl_alias->prsnl_aliases[alias_index].alias,row_cnt)
      ENDIF
     ELSEIF (parent_entity_name="PERSON_ALIAS")
      SET num = 0
      SET alias_index = locateval(num,1,prsn_alias_cnt,parent_entity_id,tprsn_alias->person_aliases[
       num].person_alias_id)
      IF (alias_index > 0)
       SET reply->rowlist[row_cnt].celllist[14].string_value = tprsn_alias->person_aliases[
       alias_index].alias
      ENDIF
     ELSEIF (parent_entity_name="ADDRESS")
      SET num = 0
      SET address_index = locateval(num,1,address_cnt,parent_entity_id,taddress->addresses[num].
       address_id)
      IF (address_index > 0)
       SET reply->rowlist[row_cnt].celllist[20].string_value = taddress->addresses[address_index].
       address_type_display
       SET reply->rowlist[row_cnt].celllist[21].string_value = taddress->addresses[address_index].
       street_addr
       SET reply->rowlist[row_cnt].celllist[22].string_value = taddress->addresses[address_index].
       street_addr2
       SET reply->rowlist[row_cnt].celllist[23].string_value = taddress->addresses[address_index].
       city
       SET reply->rowlist[row_cnt].celllist[24].string_value = taddress->addresses[address_index].
       state
       SET reply->rowlist[row_cnt].celllist[25].string_value = taddress->addresses[address_index].
       zipcode
      ENDIF
     ELSEIF (parent_entity_name="PHONE")
      SET num = 0
      SET phone_index = locateval(num,1,phone_cnt,parent_entity_id,tphone->phones[num].phone_id)
      IF (phone_index > 0)
       SET phone_cnt_for_reltn = (phone_cnt_for_reltn+ 1)
       SET reply->rowlist[row_cnt].celllist[(col_cnt_wo_phones+ phone_cnt_for_reltn)].string_value =
       tphone->phones[phone_index].phone_type_display
       SET phone_cnt_for_reltn = (phone_cnt_for_reltn+ 1)
       SET reply->rowlist[row_cnt].celllist[(col_cnt_wo_phones+ phone_cnt_for_reltn)].string_value =
       tphone->phones[phone_index].phone_formatted
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE set_prsnl_alias_rowlist(cdf_meaning,alias,row_cnt)
   IF (cdf_meaning="SPI")
    SET reply->rowlist[row_cnt].celllist[7].string_value = alias
   ENDIF
   IF (cdf_meaning="NPI")
    SET reply->rowlist[row_cnt].celllist[8].string_value = alias
   ENDIF
   IF (cdf_meaning="DOCDEA")
    SET reply->rowlist[row_cnt].celllist[9].string_value = alias
   ENDIF
   IF (cdf_meaning="DOCUPIN")
    SET reply->rowlist[row_cnt].celllist[10].string_value = alias
   ENDIF
   IF (cdf_meaning="GDP")
    SET reply->rowlist[row_cnt].celllist[11].string_value = alias
   ENDIF
   IF (cdf_meaning="LICENSENBR")
    SET reply->rowlist[row_cnt].celllist[12].string_value = alias
   ENDIF
   IF (cdf_meaning="MEDICAID")
    SET reply->rowlist[row_cnt].celllist[13].string_value = alias
   ENDIF
 END ;Subroutine
 SUBROUTINE add_service_levels(loc_pos,prsnl_pos,erx_pos,row_cnt)
   SET bit_mask = temp_rep->locations[loc_pos].prsnl[prsnl_pos].erx_reltns[erx_pos].
   service_level_mask
   IF (band(bit_mask,32) > 0)
    SET reply->rowlist[row_cnt].celllist[14].string_value = "X"
   ELSE
    SET reply->rowlist[row_cnt].celllist[14].string_value = ""
   ENDIF
   IF (band(bit_mask,1) > 0)
    SET reply->rowlist[row_cnt].celllist[15].string_value = "X"
   ELSE
    SET reply->rowlist[row_cnt].celllist[15].string_value = ""
   ENDIF
   IF (band(bit_mask,2) > 0)
    SET reply->rowlist[row_cnt].celllist[16].string_value = "X"
   ELSE
    SET reply->rowlist[row_cnt].celllist[16].string_value = ""
   ENDIF
   IF (band(bit_mask,2048) > 0)
    SET reply->rowlist[row_cnt].celllist[17].string_value = "X"
   ELSE
    SET reply->rowlist[row_cnt].celllist[17].string_value = ""
   ENDIF
 END ;Subroutine
 SUBROUTINE load_child_reltn_info(i)
   IF (prsnl_alias_cnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(prsnl_alias_cnt)),
      prsnl_alias p,
      code_value c
     PLAN (d)
      JOIN (p
      WHERE (p.prsnl_alias_id=tprsnl_alias->prsnl_aliases[d.seq].prsnl_alias_id)
       AND p.active_ind=1
       AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (c
      WHERE c.code_value=p.prsnl_alias_type_cd
       AND c.active_ind=1)
     ORDER BY d.seq
     DETAIL
      tprsnl_alias->prsnl_aliases[d.seq].alias_type_cd = c.cdf_meaning, tprsnl_alias->prsnl_aliases[d
      .seq].alias = p.alias
     WITH nocounter
    ;end select
   ENDIF
   IF (prsn_alias_cnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(prsn_alias_cnt)),
      person_alias p,
      code_value c
     PLAN (d)
      JOIN (p
      WHERE (p.person_alias_id=tprsn_alias->person_aliases[d.seq].person_alias_id)
       AND p.active_ind=1
       AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (c
      WHERE c.code_value=p.person_alias_type_cd
       AND c.active_ind=1)
     ORDER BY d.seq
     DETAIL
      tprsn_alias->person_aliases[d.seq].alias_type_cd = c.cdf_meaning, tprsn_alias->person_aliases[d
      .seq].alias = p.alias
     WITH nocounter
    ;end select
   ENDIF
   IF (address_cnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(address_cnt)),
      address a,
      code_value c,
      code_value c2,
      code_value c3
     PLAN (d)
      JOIN (a
      WHERE (a.address_id=taddress->addresses[d.seq].address_id)
       AND a.address_id > 0
       AND a.active_ind=1
       AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (c
      WHERE c.code_value=a.address_type_cd
       AND c.active_ind=1)
      JOIN (c2
      WHERE c2.code_value=outerjoin(a.state_cd)
       AND c2.active_ind=outerjoin(1))
      JOIN (c3
      WHERE c3.code_value=outerjoin(a.city_cd)
       AND c3.active_ind=outerjoin(1))
     ORDER BY d.seq
     DETAIL
      taddress->addresses[d.seq].address_id = a.address_id, taddress->addresses[d.seq].
      address_type_display = c.display, taddress->addresses[d.seq].street_addr = a.street_addr,
      taddress->addresses[d.seq].street_addr2 = a.street_addr2, taddress->addresses[d.seq].city = a
      .city
      IF (c3.code_value > 0)
       taddress->addresses[d.seq].city = c3.display
      ENDIF
      taddress->addresses[d.seq].state = c2.display, taddress->addresses[d.seq].zipcode = a.zipcode
     WITH nocounter
    ;end select
   ENDIF
   IF (phone_cnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(phone_cnt)),
      phone p,
      code_value c
     PLAN (d)
      JOIN (p
      WHERE (p.phone_id=tphone->phones[d.seq].phone_id)
       AND p.phone_id > 0
       AND p.active_ind=1
       AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (c
      WHERE c.code_value=p.phone_type_cd
       AND c.active_ind=1)
     ORDER BY d.seq
     DETAIL
      tphone->phones[d.seq].phone_type_display = c.display, tphone->phones[d.seq].phone_formatted =
      cnvtphone(cnvtalphanum(p.phone_num),p.phone_format_cd)
      IF (p.extension > " ")
       tphone->phones[d.seq].phone_formatted = concat(tphone->phones[d.seq].phone_formatted," ext ",p
        .extension)
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("bed_aud_erx_reltns.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
