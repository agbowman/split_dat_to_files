CREATE PROGRAM bed_aud_bb_supp_manuf:dba
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
 FREE RECORD temp
 RECORD temp(
   1 tcnt = i2
   1 tqual[*]
     2 org_id = f8
     2 name = vc
     2 supplier_ind = i2
     2 manuf_ind = i2
     2 client_ind = i2
     2 fac_ind = i2
     2 fda_lic_nbr = vc
     2 address1 = vc
     2 address2 = vc
     2 address3 = vc
     2 address4 = vc
     2 city = vc
     2 state_cd = f8
     2 state = vc
     2 zipcode = vc
     2 address_id = f8
 )
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
   RANGE OF o IS organization
   SET field_found = validate(o.logical_domain_id)
   FREE RANGE o
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
    SET acm_get_acc_logical_domains_req->concept = 3
    EXECUTE acm_get_acc_logical_domains  WITH replace("REQUEST",acm_get_acc_logical_domains_req),
    replace("REPLY",acm_get_acc_logical_domains_rep)
   ENDIF
  ENDIF
 ENDIF
 DECLARE org_parse = vc
 SET org_parse = "o.active_ind = 1"
 IF (data_partition_ind=1)
  IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
   SET org_parse = concat(org_parse," and o.logical_domain_id in (")
   FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
     IF ((d=acm_get_acc_logical_domains_rep->logical_domains_cnt))
      SET org_parse = build(org_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,")")
     ELSE
      SET org_parse = build(org_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,",")
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 SET x = 0
 SET supplier_cd = 0.0
 SET manuf_cd = 0.0
 SET client_cd = 0.0
 SET facility_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=278
    AND cv.active_ind=1
    AND cv.cdf_meaning IN ("BBSUPPL", "BBMANUF", "CLIENT", "FACILITY"))
  DETAIL
   IF (cv.cdf_meaning="BBSUPPL")
    supplier_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="BBMANUF")
    manuf_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="CLIENT")
    client_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="FACILITY")
    facility_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET buss_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=212
    AND cv.cdf_meaning="BUSINESS"
    AND cv.active_ind=1)
  DETAIL
   buss_cd = cv.code_value
  WITH nocounter
 ;end select
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   FROM org_type_reltn otr,
    organization o
   PLAN (otr
    WHERE otr.org_type_cd IN (supplier_cd, manuf_cd)
     AND otr.active_ind=1)
    JOIN (o
    WHERE o.organization_id=otr.organization_id
     AND parser(org_parse))
   ORDER BY o.organization_id
   HEAD o.organization_id
    high_volume_cnt = (high_volume_cnt+ 1)
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
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM org_type_reltn otr,
   organization o,
   address a,
   org_type_reltn otr2,
   org_type_reltn otr3
  PLAN (otr
   WHERE otr.org_type_cd IN (supplier_cd, manuf_cd)
    AND otr.active_ind=1)
   JOIN (o
   WHERE o.organization_id=otr.organization_id
    AND parser(org_parse))
   JOIN (a
   WHERE a.parent_entity_id=outerjoin(o.organization_id)
    AND a.parent_entity_name=outerjoin("ORGANIZATION")
    AND a.address_type_cd=outerjoin(buss_cd)
    AND a.address_type_seq=outerjoin(0)
    AND a.active_ind=outerjoin(1))
   JOIN (otr2
   WHERE otr2.organization_id=outerjoin(o.organization_id)
    AND otr2.org_type_cd=outerjoin(client_cd)
    AND otr2.active_ind=outerjoin(1))
   JOIN (otr3
   WHERE otr3.organization_id=outerjoin(o.organization_id)
    AND otr3.org_type_cd=outerjoin(facility_cd)
    AND otr3.active_ind=outerjoin(1))
  ORDER BY o.org_name
  HEAD REPORT
   tcnt = 0
  HEAD otr.organization_id
   tcnt = (tcnt+ 1), temp->tcnt = tcnt, stat = alterlist(temp->tqual,tcnt),
   temp->tqual[tcnt].name = o.org_name, temp->tqual[tcnt].org_id = o.organization_id, temp->tqual[
   tcnt].fda_lic_nbr = o.federal_tax_id_nbr,
   temp->tqual[tcnt].address1 = a.street_addr, temp->tqual[tcnt].address2 = a.street_addr2, temp->
   tqual[tcnt].address3 = a.street_addr3,
   temp->tqual[tcnt].address4 = a.street_addr4, temp->tqual[tcnt].city = a.city, temp->tqual[tcnt].
   state_cd = a.state_cd,
   temp->tqual[tcnt].zipcode = a.zipcode, temp->tqual[tcnt].address_id = a.address_id
  DETAIL
   IF (otr.org_type_cd=supplier_cd)
    temp->tqual[tcnt].supplier_ind = 1
   ENDIF
   IF (otr.org_type_cd=manuf_cd)
    temp->tqual[tcnt].manuf_ind = 1
   ENDIF
   IF (otr2.organization_id > 0)
    temp->tqual[tcnt].client_ind = 1
   ENDIF
   IF (otr3.organization_id > 0)
    temp->tqual[tcnt].fac_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (tcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(tcnt)),
    code_value cv
   PLAN (d
    WHERE (temp->tqual[d.seq].state_cd > 0))
    JOIN (cv
    WHERE (cv.code_value=temp->tqual[d.seq].state_cd)
     AND cv.active_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    temp->tqual[d.seq].state = cv.display
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(tcnt)),
    organization_alias oa,
    code_value cv
   PLAN (d)
    JOIN (oa
    WHERE (oa.organization_id=temp->tqual[d.seq].org_id)
     AND oa.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=oa.org_alias_type_cd
     AND cv.code_set=334
     AND cv.cdf_meaning="FDALICNO"
     AND cv.active_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    temp->tqual[d.seq].fda_lic_nbr = oa.alias
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->collist,7)
 SET reply->collist[1].header_text = "Organization Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Supplier"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Manufacturer"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Client"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 1
 SET reply->collist[5].header_text = "Facility"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 1
 SET reply->collist[6].header_text = "FDA License Number"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Address"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,7)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].name
   IF ((temp->tqual[x].supplier_ind=1))
    SET reply->rowlist[row_nbr].celllist[2].string_value = "X"
   ENDIF
   IF ((temp->tqual[x].manuf_ind=1))
    SET reply->rowlist[row_nbr].celllist[3].string_value = "X"
   ENDIF
   IF ((temp->tqual[x].client_ind=1))
    SET reply->rowlist[row_nbr].celllist[4].string_value = "X"
   ENDIF
   IF ((temp->tqual[x].fac_ind=1))
    SET reply->rowlist[row_nbr].celllist[5].string_value = "X"
   ENDIF
   SET reply->rowlist[row_nbr].celllist[6].string_value = temp->tqual[x].fda_lic_nbr
   DECLARE addr = vc
   IF ((temp->tqual[x].address_id > 0))
    IF ((temp->tqual[x].address1 > " "))
     SET addr = concat(addr,trim(temp->tqual[x].address1),",")
    ENDIF
    IF ((temp->tqual[x].address2 > " "))
     SET addr = concat(addr," ",trim(temp->tqual[x].address2),",")
    ENDIF
    IF ((temp->tqual[x].address3 > " "))
     SET addr = concat(addr," ",trim(temp->tqual[x].address3),",")
    ENDIF
    IF ((temp->tqual[x].address4 > " "))
     SET addr = concat(addr," ",trim(temp->tqual[x].address4),",")
    ENDIF
    SET addr = concat(addr," ",trim(temp->tqual[x].city),", ",trim(temp->tqual[x].state),
     " ",trim(temp->tqual[x].zipcode))
    SET reply->rowlist[row_nbr].celllist[7].string_value = addr
   ENDIF
 ENDFOR
 CALL echorecord(reply)
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("bb_supp_manuf.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
