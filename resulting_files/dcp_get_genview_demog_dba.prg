CREATE PROGRAM dcp_get_genview_demog:dba
 SET fmtphone = fillstring(22," ")
 SET tempphone = fillstring(22," ")
 SET person_found = 0
 SET phone_home_cd = 0
 SET phone_bus_cd = 0
 SET default_phone_cd = 0
 SET home_address_cd = 0
 SET bus_address_cd = 0
 SET employer_cd = 0
 SET tempitem = fillstring(100," ")
 SET tempget = fillstring(100," ")
 SET display = fillstring(100," ")
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 43
 SET cdf_meaning = "HOME"
 EXECUTE cpm_get_cd_for_cdf
 SET phone_home_cd = code_value
 SET code_set = 43
 SET cdf_meaning = "BUSINESS"
 EXECUTE cpm_get_cd_for_cdf
 SET phone_bus_cd = code_value
 SET code_set = 281
 SET cdf_meaning = "DEFAULT"
 EXECUTE cpm_get_cd_for_cdf
 SET default_phone_cd = code_value
 SET code_set = 212
 SET cdf_meaning = "HOME"
 EXECUTE cpm_get_cd_for_cdf
 SET home_address_cd = code_value
 SET code_set = 212
 SET cdf_meaning = "BUSINESS"
 EXECUTE cpm_get_cd_for_cdf
 SET bus_address_cd = code_value
 SET code_set = 338
 SET cdf_meaning = "EMPLOYER"
 EXECUTE cpm_get_cd_for_cdf
 SET employer_cd = code_value
 SET name_ind = 1
 SET sex_ind = 1
 SET birth_dt_ind = 1
 SET age_ind = 1
 SET race_ind = 1
 SET language_ind = 0
 SET marital_ind = 0
 SET religion_ind = 0
 SET vip_ind = 0
 SET dialect_ind = 0
 SET ethnic_ind = 0
 SET deceased_ind = 0
 SET citizenship_ind = 0
 SET data_status_ind = 0
 SET smoke_ind = 0
 SET organ_ind = 0
 SET will_ind = 0
 SET immun_ind = 0
 SET birth_wt_ind = 0
 SET allergy_ind = 0
 SET address_ind = 1
 SET address_type_ind = 0
 SET street_ind = 1
 SET street2_ind = 1
 SET street3_ind = 1
 SET street4_ind = 1
 SET city_ind = 1
 SET state_ind = 1
 SET zip_ind = 1
 SET citystatezip_ind = 1
 SET county_ind = 0
 SET country_ind = 0
 SET phone_ind = 1
 SET phone_type_ind = 1
 SET alias_ind = 1
 SET person_name_ind = 1
 SET diagnosis_ind = 1
 SET diag_date_ind = 1
 SET diag_ident_ind = 1
 SET diag_type_ind = 1
 SET health_plan_ind = 1
 SET health_plan_type_ind = 1
 SET deduct_amt_ind = 1
 SET deduct_met_amt_ind = 1
 SET deduct_met_date_ind = 1
 SET fam_deduct_met_amt_ind = 1
 SET fam_deduct_met_date_ind = 1
 SET max_pckt_amt_ind = 1
 SET max_pckt_date_ind = 1
 SET signature_ind = 1
 SET plan_name_ind = 1
 SET baby_coverage_ind = 1
 SET baby_bill_ind = 1
 SET person_person_reltn_ind = 1
 SET rel_address_type_ind = 0
 SET rel_street_ind = 1
 SET rel_street2_ind = 1
 SET rel_street3_ind = 1
 SET rel_street4_ind = 1
 SET rel_city_ind = 1
 SET rel_state_ind = 1
 SET rel_zip_ind = 1
 SET rel_citystatezip_ind = 1
 SET rel_county_ind = 0
 SET rel_country_ind = 0
 SET rel_phone_ind = 1
 SET org_ind = 1
 SET org_address_type_ind = 0
 SET org_street_ind = 1
 SET org_street2_ind = 1
 SET org_street3_ind = 1
 SET org_street4_ind = 1
 SET org_city_ind = 1
 SET org_state_ind = 1
 SET org_zip_ind = 1
 SET org_citystatezip_ind = 1
 SET org_county_ind = 0
 SET org_country_ind = 0
 SET org_phone_ind = 1
 SET reply->col_cnt = 20
 SET reply->row_cnt = 0
 SELECT INTO "nl:"
  FROM person p
  WHERE (p.person_id=request->person[1].person_id)
  DETAIL
   IF (name_ind=1)
    reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
    alterlist(reply->row[reply->row_cnt].col,100),
    reply->row[reply->row_cnt].col[1].data_string = "Name", reply->row[reply->row_cnt].col[3].
    data_string = p.name_full_formatted
   ENDIF
   IF (sex_ind=1)
    reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
    alterlist(reply->row[reply->row_cnt].col,100),
    reply->row[reply->row_cnt].col[1].data_string = "Sex", reply->row[reply->row_cnt].col[3].
    data_string = uar_get_code_display(p.sex_cd)
   ENDIF
   IF (birth_dt_ind=1)
    reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
    alterlist(reply->row[reply->row_cnt].col,100),
    reply->row[reply->row_cnt].col[1].data_string = "Date of Birth", reply->row[reply->row_cnt].col[3
    ].data_string = format(p.birth_dt_tm,"mm/dd/yy;;d")
   ENDIF
   IF (race_ind=1)
    reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
    alterlist(reply->row[reply->row_cnt].col,100),
    reply->row[reply->row_cnt].col[1].data_string = "Race", reply->row[reply->row_cnt].col[3].
    data_string = uar_get_code_display(p.race_cd)
   ENDIF
   IF (age_ind=1)
    IF (nullind(p.deceased_dt_tm)=0)
     age = cnvtage(cnvtdate2(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),"mm/dd/yyyy"),cnvtint(format(p
        .birth_dt_tm,"hhmm;;m")),cnvtdate2(format(p.deceased_dt_tm,"mm/dd/yyyy;;d"),"mm/dd/yyyy"),
      cnvtint(format(p.deceased_dt_tm,"hhmm;;m")))
    ELSE
     age = cnvtage(cnvtdate2(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),"mm/dd/yyyy"),cnvtint(format(p
        .birth_dt_tm,"hhmm;;m")))
    ENDIF
    reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
    alterlist(reply->row[reply->row_cnt].col,100),
    reply->row[reply->row_cnt].col[1].data_string = "Age", reply->row[reply->row_cnt].col[3].
    data_string = age
   ENDIF
   IF (citizenship_ind=1)
    reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
    alterlist(reply->row[reply->row_cnt].col,100),
    reply->row[reply->row_cnt].col[1].data_string = "Citizenship", reply->row[reply->row_cnt].col[3].
    data_string = uar_get_code_display(p.citizenship_cd)
   ENDIF
   IF (data_status_ind=1)
    reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
    alterlist(reply->row[reply->row_cnt].col,100),
    reply->row[reply->row_cnt].col[1].data_string = "Data Status", reply->row[reply->row_cnt].col[3].
    data_string = uar_get_code_display(p.data_status_cd)
   ENDIF
   IF (deceased_ind=1)
    reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
    alterlist(reply->row[reply->row_cnt].col,100),
    reply->row[reply->row_cnt].col[1].data_string = "Deceased", reply->row[reply->row_cnt].col[3].
    data_string = uar_get_code_display(p.deceased_cd)
   ENDIF
   IF (ethnic_ind=1)
    reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
    alterlist(reply->row[reply->row_cnt].col,100),
    reply->row[reply->row_cnt].col[1].data_string = "Ethnic Group", reply->row[reply->row_cnt].col[3]
    .data_string = uar_get_code_display(p.ethnic_grp_cd)
   ENDIF
   IF (dialect_ind=1)
    reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
    alterlist(reply->row[reply->row_cnt].col,100),
    reply->row[reply->row_cnt].col[1].data_string = "Language Dialect", reply->row[reply->row_cnt].
    col[3].data_string = uar_get_code_display(p.language_dialect_cd)
   ENDIF
   IF (language_ind=1)
    reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
    alterlist(reply->row[reply->row_cnt].col,100),
    reply->row[reply->row_cnt].col[1].data_string = "Language", reply->row[reply->row_cnt].col[3].
    data_string = uar_get_code_display(p.language_cd)
   ENDIF
   IF (marital_ind=1)
    reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
    alterlist(reply->row[reply->row_cnt].col,100),
    reply->row[reply->row_cnt].col[1].data_string = "Marital Status", reply->row[reply->row_cnt].col[
    3].data_string = uar_get_code_display(p.marital_type_cd)
   ENDIF
   IF (religion_ind=1)
    reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
    alterlist(reply->row[reply->row_cnt].col,100),
    reply->row[reply->row_cnt].col[1].data_string = "Religion", reply->row[reply->row_cnt].col[3].
    data_string = uar_get_code_display(p.religion_cd)
   ENDIF
   IF (vip_ind=1)
    reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
    alterlist(reply->row[reply->row_cnt].col,100),
    reply->row[reply->row_cnt].col[1].data_string = "VIP", reply->row[reply->row_cnt].col[3].
    data_string = uar_get_code_display(p.vip_cd)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM person_patient pp
  WHERE (pp.person_id=request->person[1].person_id)
  DETAIL
   IF (immun_ind=1)
    reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
    alterlist(reply->row[reply->row_cnt].col,100),
    reply->row[reply->row_cnt].col[1].data_string = "Immunizations", reply->row[reply->row_cnt].col[3
    ].data_string = uar_get_code_display(pp.immun_on_file_cd)
   ENDIF
   IF (will_ind=1)
    reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
    alterlist(reply->row[reply->row_cnt].col,100),
    reply->row[reply->row_cnt].col[1].data_string = "Living Will", reply->row[reply->row_cnt].col[3].
    data_string = uar_get_code_display(pp.living_will_cd)
   ENDIF
   IF (organ_ind=1)
    reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
    alterlist(reply->row[reply->row_cnt].col,100),
    reply->row[reply->row_cnt].col[1].data_string = "Organ Donor", reply->row[reply->row_cnt].col[3].
    data_string = uar_get_code_display(pp.organ_donor_cd)
   ENDIF
   IF (smoke_ind=1)
    reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
    alterlist(reply->row[reply->row_cnt].col,100),
    reply->row[reply->row_cnt].col[1].data_string = "Smokes", reply->row[reply->row_cnt].col[3].
    data_string = uar_get_code_display(pp.smokes_cd)
   ENDIF
   IF (birth_wt_ind=1)
    reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
    alterlist(reply->row[reply->row_cnt].col,100),
    reply->row[reply->row_cnt].col[1].data_string = "Birth Weight", reply->row[reply->row_cnt].col[3]
    .data_string = cnvtstring(pp.birth_weight)
   ENDIF
  WITH nocounter
 ;end select
 IF (allergy_ind=1)
  SELECT INTO "nl:"
   FROM allergy a
   WHERE (a.person_id=request->person[1].person_id)
    AND a.active_ind=1
   DETAIL
    reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
    alterlist(reply->row[reply->row_cnt].col,100),
    reply->row[reply->row_cnt].col[1].data_string = "Allergies", reply->row[reply->row_cnt].col[3].
    data_string = "Allergies"
   WITH nocounter, maxqual(a,1)
  ;end select
 ENDIF
 IF (address_ind=1)
  SELECT INTO "nl:"
   FROM address a
   WHERE trim(a.parent_entity_name)="PERSON"
    AND (a.parent_entity_id=request->person[1].person_id)
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   HEAD REPORT
    save_row = 0, row_cnt = reply->row_cnt, x = 0
   HEAD a.address_id
    x = (x+ 3), reply->row_cnt = row_cnt
    IF (address_type_ind=1)
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Address Type", reply->row[reply->row_cnt].col[x
     ].data_string = uar_get_code_display(a.address_type_cd)
    ENDIF
    IF (street_ind=1)
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Street", reply->row[reply->row_cnt].col[x].
     data_string = a.street_addr
    ENDIF
    IF (citystatezip_ind=1)
     tempitem = "", tempget = ""
     IF (a.city > " ")
      tempitem = a.city
     ENDIF
     IF (a.state > " ")
      tempget = concat(trim(tempitem),", ",trim(a.state))
     ELSEIF (a.state <= " ")
      tempget = concat(trim(tempitem),", ",trim(uar_get_code_display(a.state_cd)))
     ENDIF
     tempitem = tempget
     IF (a.zipcode > " ")
      tempget = concat(trim(tempitem),", ",trim(a.zipcode))
     ENDIF
     tempitem = tempget, reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->
      row_cnt),
     stat = alterlist(reply->row[reply->row_cnt].col,100), reply->row[reply->row_cnt].col[1].
     data_string = "City State Zip"
     IF (tempitem > ", ")
      reply->row[reply->row_cnt].col[x].data_string = tempitem
     ELSE
      reply->row[reply->row_cnt].col[x].data_string = " "
     ENDIF
    ENDIF
    IF (county_ind=1)
     IF (a.county_cd <= 0)
      tempget = a.county
     ELSE
      tempget = uar_get_code_display(a.county_cd)
     ENDIF
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "County", reply->row[reply->row_cnt].col[x].
     data_string = tempget
    ENDIF
    IF (country_ind=1)
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Country", reply->row[reply->row_cnt].col[x].
     data_string = uar_get_code_display(a.country_cd)
    ENDIF
    IF (street2_ind=1
     AND a.street_addr2 > " ")
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Street2", reply->row[reply->row_cnt].col[x].
     data_string = a.street_addr2
    ENDIF
    IF (street3_ind=1
     AND a.street_addr3 > " ")
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Street3", reply->row[reply->row_cnt].col[x].
     data_string = a.street_addr3
    ENDIF
    IF (street4_ind=1
     AND a.street_addr4 > " ")
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Street4", reply->row[reply->row_cnt].col[x].
     data_string = a.street_addr4
    ENDIF
   FOOT  a.address_id
    IF ((reply->row_cnt > save_row))
     save_row = reply->row_cnt
    ENDIF
   FOOT REPORT
    reply->row_cnt = save_row, reply->col_cnt = x
   WITH nocounter
  ;end select
 ENDIF
 IF (phone_ind=1)
  SELECT INTO "nl:"
   FROM phone ph
   WHERE (ph.parent_entity_id=request->person[1].person_id)
    AND ph.parent_entity_name="PERSON"
    AND ph.active_ind=1
    AND ph.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND ph.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   ORDER BY ph.phone_type_cd
   HEAD REPORT
    save_row = 0, row_cnt = reply->row_cnt, x = 0
   HEAD ph.phone_id
    reply->row_cnt = row_cnt, x = (x+ 3)
    IF (phone_type_ind=1)
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Phone Type", reply->row[reply->row_cnt].col[x].
     data_string = uar_get_code_display(ph.phone_type_cd)
    ENDIF
    tempphone = fillstring(22," "), tempphone = cnvtalphanum(ph.phone_num)
    IF (tempphone != ph.phone_num)
     fmtphone = ph.phone_num
    ELSE
     IF (ph.phone_format_cd > 0)
      fmtphone = cnvtphone(trim(ph.phone_num),ph.phone_format_cd)
     ELSEIF (default_phone_cd > 0)
      fmtphone = cnvtphone(trim(ph.phone_num),default_phone_cd)
     ELSEIF (size(tempphone) < 8)
      fmtphone = format(trim(ph.phone_num),"###-####")
     ELSE
      fmtphone = format(trim(ph.phone_num),"(###) ###-####")
     ENDIF
    ENDIF
    IF (fmtphone <= " ")
     fmtphone = ph.phone_num
    ENDIF
    IF (ph.extension > " ")
     fmtphone = concat(trim(fmtphone)," x",ph.extension)
    ENDIF
    reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
    alterlist(reply->row[reply->row_cnt].col,100),
    reply->row[reply->row_cnt].col[1].data_string = "Phone Number", reply->row[reply->row_cnt].col[x]
    .data_string = fmtphone
   FOOT  ph.phone_id
    IF ((reply->row_cnt > save_row))
     save_row = reply->row_cnt
    ENDIF
   FOOT REPORT
    reply->row_cnt = save_row
    IF ((x > reply->col_cnt))
     reply->col_cnt = x
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (alias_ind=1)
  SELECT INTO "nl:"
   FROM person_alias pa
   WHERE (pa.person_id=request->person[1].person_id)
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND ((pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (pa.end_effective_dt_tm=null))
   ORDER BY pa.person_alias_type_cd
   HEAD pa.person_alias_id
    reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
    alterlist(reply->row[reply->row_cnt].col,100),
    reply->row[reply->row_cnt].col[1].data_string = uar_get_code_display(pa.person_alias_type_cd)
    IF (pa.alias > " ")
     reply->row[reply->row_cnt].col[3].data_string = cnvtalias(pa.alias,pa.alias_pool_cd)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (person_name_ind=1)
  SELECT INTO "nl:"
   FROM person_name pn
   WHERE (pn.person_id=request->person[1].person_id)
   ORDER BY pn.name_type_cd
   HEAD pn.person_name_id
    IF (pn.name_full > " ")
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = concat("Name (",trim(uar_get_code_display(pn
        .name_type_cd)),")"), reply->row[reply->row_cnt].col[3].data_string = pn.name_full
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (diagnosis_ind=1)
  SELECT INTO "nl:"
   FROM diagnosis d,
    (dummyt d1  WITH seq = 1),
    nomenclature n
   PLAN (d
    WHERE (d.person_id=request->person[1].person_id)
     AND d.active_ind=1
     AND d.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ((d.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (d.end_effective_dt_tm=null))
    )
    JOIN (d1)
    JOIN (n
    WHERE n.nomenclature_id=d.nomenclature_id)
   ORDER BY n.source_vocabulary_cd, d.diag_dt_tm DESC
   HEAD REPORT
    save_row = 0, row_cnt = reply->row_cnt, x = 0
   HEAD d.diagnosis_id
    reply->row_cnt = row_cnt, x = (x+ 3)
    IF (diag_type_ind=1)
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Diagnosis Type", reply->row[reply->row_cnt].
     col[x].data_string = uar_get_code_display(n.source_vocabulary_cd)
    ENDIF
    IF (trim(n.source_string) > "")
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Diagnosis", reply->row[reply->row_cnt].col[x].
     data_string = n.source_string
    ELSE
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Diagnosis", reply->row[reply->row_cnt].col[x].
     data_string = d.diag_ftdesc
    ENDIF
    IF (diag_ident_ind=1)
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Diagnosis Identifier", reply->row[reply->
     row_cnt].col[x].data_string = n.source_identifier
    ENDIF
    IF (diag_date_ind=1)
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Diagnosis Date/Time", reply->row[reply->row_cnt
     ].col[x].data_string = format(d.diag_dt_tm,"mm/dd/yy hh:mm;;d")
    ENDIF
   FOOT  d.diagnosis_id
    IF ((reply->row_cnt > save_row))
     save_row = reply->row_cnt
    ENDIF
   FOOT REPORT
    reply->row_cnt = save_row
    IF ((x > reply->col_cnt))
     reply->col_cnt = x
    ENDIF
   WITH nocounter, outerjoin = d1, dontcare = n
  ;end select
 ENDIF
 IF (health_plan_ind=1)
  SELECT INTO "nl:"
   FROM person_plan_reltn ppr,
    (dummyt d1  WITH seq = 1),
    health_plan hp
   PLAN (ppr
    WHERE (ppr.person_id=request->person[1].person_id)
     AND ppr.active_ind=1)
    JOIN (d1)
    JOIN (hp
    WHERE hp.health_plan_id=ppr.health_plan_id
     AND hp.active_ind=1)
   ORDER BY hp.plan_type_cd
   HEAD REPORT
    save_row = 0, row_cnt = reply->row_cnt, x = 0
   HEAD ppr.health_plan_id
    reply->row_cnt = row_cnt, x = (x+ 3)
    IF (health_plan_type_ind=1)
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Health Plan Type", reply->row[reply->row_cnt].
     col[x].data_string = uar_get_code_display(hp.plan_type_cd)
    ENDIF
    IF (deduct_amt_ind=1)
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Deductible Amount", reply->row[reply->row_cnt].
     col[x].data_string = cnvtstring(ppr.deduct_amt)
    ENDIF
    IF (deduct_met_amt_ind=1)
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Deductible MET Amount", reply->row[reply->
     row_cnt].col[x].data_string = cnvtstring(ppr.deduct_met_amt)
    ENDIF
    IF (deduct_met_date_ind=1)
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Deductible MET date", reply->row[reply->row_cnt
     ].col[x].data_string = format(ppr.deduct_met_dt_tm,"mm/dd/yy;;d")
    ENDIF
    IF (fam_deduct_met_amt_ind=1)
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Family Deductible MET Amount", reply->row[reply
     ->row_cnt].col[x].data_string = cnvtstring(ppr.fam_deduct_met_amt)
    ENDIF
    IF (fam_deduct_met_date_ind=1)
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Family Deductible MET Date", reply->row[reply->
     row_cnt].col[x].data_string = format(ppr.fam_deduct_met_dt_tm,"mm/dd/yy;;d")
    ENDIF
    IF (max_pckt_amt_ind=1)
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Maximum Out of Pocket Amount", reply->row[reply
     ->row_cnt].col[x].data_string = cnvtstring(ppr.max_out_pckt_amt)
    ENDIF
    IF (max_pckt_date_ind=1)
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Maximum Out of Pocket Date", reply->row[reply->
     row_cnt].col[x].data_string = format(ppr.max_out_pckt_dt_tm,"mm/dd/yy;;d")
    ENDIF
    IF (signature_ind=1)
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Signature On File", reply->row[reply->row_cnt].
     col[x].data_string = uar_get_code_display(ppr.signature_on_file_cd)
    ENDIF
    IF (plan_name_ind=1)
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Plan Name", reply->row[reply->row_cnt].col[x].
     data_string = hp.plan_name
    ENDIF
    IF (baby_coverage_ind=1)
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Baby Coverage", reply->row[reply->row_cnt].col[
     x].data_string = uar_get_code_display(hp.baby_coverage_cd)
    ENDIF
    IF (baby_bill_ind=1)
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Baby Bill", reply->row[reply->row_cnt].col[x].
     data_string = uar_get_code_display(hp.comb_baby_bill_cd)
    ENDIF
   FOOT  ppr.health_plan_id
    IF ((reply->row_cnt > save_row))
     save_row = reply->row_cnt
    ENDIF
   FOOT REPORT
    reply->row_cnt = save_row
    IF ((x > reply->col_cnt))
     reply->col_cnt = x
    ENDIF
   WITH nocounter, outerjoin = d1, dontcare = hp
  ;end select
 ENDIF
 IF (person_person_reltn_ind=1)
  SELECT INTO "nl:"
   FROM person_person_reltn ppr,
    (dummyt d1  WITH seq = 1),
    person p,
    (dummyt d2  WITH seq = 1),
    address a,
    (dummyt d3  WITH seq = 1),
    phone ph
   PLAN (ppr
    WHERE (ppr.person_id=request->person[1].person_id)
     AND ppr.active_ind=1)
    JOIN (d1)
    JOIN (p
    WHERE p.person_id=ppr.related_person_id
     AND p.active_ind=1)
    JOIN (d2)
    JOIN (a
    WHERE trim(a.parent_entity_name)="PERSON"
     AND a.parent_entity_id=ppr.related_person_id
     AND a.address_type_cd=home_address_cd
     AND a.active_ind=1
     AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (d3)
    JOIN (ph
    WHERE ph.parent_entity_name="PERSON"
     AND ph.parent_entity_id=ppr.related_person_id
     AND ((ph.phone_type_cd=phone_bus_cd) OR (ph.phone_type_cd=phone_home_cd))
     AND ph.active_ind=1
     AND ph.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
     AND ph.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ORDER BY ppr.person_reltn_type_cd
   HEAD REPORT
    save_row = 0, row_cnt = reply->row_cnt, x = 0
   HEAD ppr.person_person_reltn_id
    reply->row_cnt = row_cnt, x = (x+ 3), reply->row_cnt = (reply->row_cnt+ 1),
    stat = alterlist(reply->row,reply->row_cnt), stat = alterlist(reply->row[reply->row_cnt].col,100),
    reply->row[reply->row_cnt].col[1].data_string = "Relation Type",
    reply->row[reply->row_cnt].col[x].data_string = uar_get_code_display(ppr.person_reltn_type_cd),
    reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt),
    stat = alterlist(reply->row[reply->row_cnt].col,100), reply->row[reply->row_cnt].col[1].
    data_string = "Name", reply->row[reply->row_cnt].col[x].data_string = p.name_full_formatted,
    reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
    alterlist(reply->row[reply->row_cnt].col,100),
    reply->row[reply->row_cnt].col[1].data_string = "Relation", reply->row[reply->row_cnt].col[x].
    data_string = uar_get_code_display(ppr.person_reltn_cd)
   HEAD a.address_id
    IF (rel_address_type_ind=1)
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Address Type", reply->row[reply->row_cnt].col[x
     ].data_string = uar_get_code_display(a.address_type_cd)
    ENDIF
    IF (rel_street_ind=1)
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Street", reply->row[reply->row_cnt].col[x].
     data_string = a.street_addr
    ENDIF
    IF (rel_citystatezip_ind=1)
     tempitem = "", tempget = ""
     IF (a.city > " ")
      tempitem = a.city
     ENDIF
     IF (a.state > " ")
      tempget = concat(trim(tempitem),", ",trim(a.state))
     ELSEIF (a.state <= " ")
      tempget = concat(trim(tempitem),", ",trim(uar_get_code_display(a.state_cd)))
     ENDIF
     tempitem = tempget
     IF (a.zipcode > " ")
      tempget = concat(trim(tempitem),", ",trim(a.zipcode))
     ENDIF
     tempitem = tempget, reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->
      row_cnt),
     stat = alterlist(reply->row[reply->row_cnt].col,100), reply->row[reply->row_cnt].col[1].
     data_string = "CityStateZip"
     IF (tempitem > ", ")
      reply->row[reply->row_cnt].col[x].data_string = tempitem
     ELSE
      reply->row[reply->row_cnt].col[x].data_string = " "
     ENDIF
    ENDIF
    IF (rel_county_ind=1)
     IF (a.county_cd <= 0)
      tempget = a.county
     ELSE
      tempget = uar_get_code_display(a.county_cd)
     ENDIF
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "County", reply->row[reply->row_cnt].col[x].
     data_string = tempget
    ENDIF
    IF (rel_country_ind=1)
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Country", reply->row[reply->row_cnt].col[x].
     data_string = uar_get_code_display(a.country_cd)
    ENDIF
    IF (rel_street2_ind=1
     AND a.street_addr2 > " ")
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Street2", reply->row[reply->row_cnt].col[x].
     data_string = a.street_addr2
    ENDIF
    IF (rel_street3_ind=1
     AND a.street_addr3 > " ")
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Street3", reply->row[reply->row_cnt].col[x].
     data_string = a.street_addr3
    ENDIF
    IF (rel_street4_ind=1
     AND a.street_addr4 > " ")
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Street4", reply->row[reply->row_cnt].col[x].
     data_string = a.street_addr4
    ENDIF
   HEAD ph.phone_id
    IF (rel_phone_ind=1)
     IF (ph.phone_type_cd=phone_home_cd)
      reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
      alterlist(reply->row[reply->row_cnt].col,100),
      reply->row[reply->row_cnt].col[1].data_string = "Phone Type", reply->row[reply->row_cnt].col[x]
      .data_string = "Home", tempphone = fillstring(22," "),
      tempphone = cnvtalphanum(ph.phone_num)
      IF (tempphone != ph.phone_num)
       fmtphone = ph.phone_num
      ELSE
       IF (ph.phone_format_cd > 0)
        fmtphone = cnvtphone(trim(ph.phone_num),ph.phone_format_cd)
       ELSEIF (default_phone_cd > 0)
        fmtphone = cnvtphone(trim(ph.phone_num),default_phone_cd)
       ELSEIF (size(tempphone) < 8)
        fmtphone = format(trim(ph.phone_num),"###-####")
       ELSE
        fmtphone = format(trim(ph.phone_num),"(###) ###-####")
       ENDIF
      ENDIF
      IF (ph.extension > " ")
       fmtphone = concat(trim(fmtphone)," x",ph.extension)
      ENDIF
      reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
      alterlist(reply->row[reply->row_cnt].col,100),
      reply->row[reply->row_cnt].col[1].data_string = "Phone Number", reply->row[reply->row_cnt].col[
      x].data_string = fmtphone
     ENDIF
     IF (ph.phone_type_cd=phone_bus_cd)
      reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
      alterlist(reply->row[reply->row_cnt].col,100),
      reply->row[reply->row_cnt].col[1].data_string = "Phone Type", reply->row[reply->row_cnt].col[x]
      .data_string = "Business", tempphone = fillstring(22," "),
      tempphone = cnvtalphanum(ph.phone_num)
      IF (tempphone != ph.phone_num)
       fmtphone = ph.phone_num
      ELSE
       IF (ph.phone_format_cd > 0)
        fmtphone = cnvtphone(trim(ph.phone_num),ph.phone_format_cd)
       ELSEIF (default_phone_cd > 0)
        fmtphone = cnvtphone(trim(ph.phone_num),default_phone_cd)
       ELSEIF (size(tempphone) < 8)
        fmtphone = format(trim(ph.phone_num),"###-####")
       ELSE
        fmtphone = format(trim(ph.phone_num),"(###) ###-####")
       ENDIF
      ENDIF
      IF (ph.extension > " ")
       fmtphone = concat(trim(fmtphone)," x",ph.extension)
      ENDIF
      reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
      alterlist(reply->row[reply->row_cnt].col,100),
      reply->row[reply->row_cnt].col[1].data_string = "Phone Number", reply->row[reply->row_cnt].col[
      x].data_string = fmtphone
     ENDIF
    ENDIF
   FOOT  ppr.person_person_reltn_id
    IF ((reply->row_cnt > save_row))
     save_row = reply->row_cnt
    ENDIF
   FOOT REPORT
    reply->row_cnt = save_row
    IF ((x > reply->col_cnt))
     reply->col_cnt = x
    ENDIF
   WITH nocounter, outerjoin = d2, outerjoin = d3,
    dontcare = addr, dontcare = ph
  ;end select
 ENDIF
 IF (org_ind=1)
  SELECT INTO "nl:"
   FROM person_org_reltn por,
    (dummyt d1  WITH seq = 1),
    address a,
    (dummyt d2  WITH seq = 1),
    phone ph,
    (dummyt d3  WITH seq = 1),
    organization o
   PLAN (por
    WHERE (por.person_id=request->person[1].person_id)
     AND por.person_org_reltn_cd=employer_cd
     AND por.active_ind=1)
    JOIN (d1)
    JOIN (a
    WHERE trim(a.parent_entity_name)="ORGANIZATION"
     AND a.parent_entity_id=por.organization_id
     AND a.address_type_cd=bus_address_cd
     AND a.active_ind=1
     AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (d2)
    JOIN (ph
    WHERE ph.parent_entity_name="ORGANIZATION"
     AND ph.parent_entity_id=por.organization_id
     AND ph.phone_type_cd=phone_bus_cd
     AND ph.active_ind=1
     AND ph.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
     AND ph.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (d3)
    JOIN (o
    WHERE o.organization_id=por.organization_id
     AND o.active_ind=1)
   ORDER BY por.person_org_reltn_cd
   HEAD REPORT
    save_row = 0, row_cnt = reply->row_cnt, x = 0
   HEAD por.organization_id
    reply->row_cnt = row_cnt, x = (x+ 3), reply->row_cnt = (reply->row_cnt+ 1),
    stat = alterlist(reply->row,reply->row_cnt), stat = alterlist(reply->row[reply->row_cnt].col,100),
    reply->row[reply->row_cnt].col[1].data_string = "Employed Status",
    reply->row[reply->row_cnt].col[x].data_string = uar_get_code_display(por.empl_status_cd), reply->
    row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt),
    stat = alterlist(reply->row[reply->row_cnt].col,100), reply->row[reply->row_cnt].col[1].
    data_string = "Employer", reply->row[reply->row_cnt].col[x].data_string = o.org_name
   HEAD a.address_id
    IF (org_address_type_ind=1)
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Address Type", reply->row[reply->row_cnt].col[x
     ].data_string = uar_get_code_display(a.address_type_cd)
    ENDIF
    IF (org_street_ind=1)
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Street", reply->row[reply->row_cnt].col[x].
     data_string = a.street_addr
    ENDIF
    IF (org_citystatezip_ind=1)
     tempitem = "", tempget = ""
     IF (a.city > " ")
      tempitem = a.city
     ENDIF
     IF (a.state > " ")
      tempget = concat(trim(tempitem),", ",trim(a.state))
     ELSEIF (a.state <= " ")
      tempget = concat(trim(tempitem),", ",trim(uar_get_code_display(a.state_cd)))
     ENDIF
     tempitem = tempget
     IF (a.zipcode > " ")
      tempget = concat(trim(tempitem),", ",trim(a.zipcode))
     ENDIF
     tempitem = tempget, reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->
      row_cnt),
     stat = alterlist(reply->row[reply->row_cnt].col,100), reply->row[reply->row_cnt].col[1].
     data_string = "CityStateZip"
     IF (tempitem > ", ")
      reply->row[reply->row_cnt].col[x].data_string = tempitem
     ELSE
      reply->row[reply->row_cnt].col[x].data_string = " "
     ENDIF
    ENDIF
    IF (org_county_ind=1)
     IF (a.county_cd <= 0)
      tempget = a.county
     ELSE
      tempget = uar_get_code_display(a.county_cd)
     ENDIF
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "County", reply->row[reply->row_cnt].col[x].
     data_string = tempget
    ENDIF
    IF (org_country_ind=1)
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Country", reply->row[reply->row_cnt].col[x].
     data_string = uar_get_code_display(a.country_cd)
    ENDIF
    IF (org_street2_ind=1
     AND a.street_addr2 > " ")
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Street2", reply->row[reply->row_cnt].col[x].
     data_string = a.street_addr2
    ENDIF
    IF (org_street3_ind=1
     AND a.street_addr3 > " ")
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Street3", reply->row[reply->row_cnt].col[x].
     data_string = a.street_addr3
    ENDIF
    IF (org_street4_ind=1
     AND a.street_addr4 > " ")
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Street4", reply->row[reply->row_cnt].col[x].
     data_string = a.street_addr4
    ENDIF
   HEAD ph.phone_id
    IF (org_phone_ind=1)
     tempphone = fillstring(22," "), tempphone = cnvtalphanum(ph.phone_num)
     IF (tempphone != ph.phone_num)
      fmtphone = ph.phone_num
     ELSE
      IF (ph.phone_format_cd > 0)
       fmtphone = cnvtphone(trim(ph.phone_num),ph.phone_format_cd)
      ELSEIF (default_phone_cd > 0)
       fmtphone = cnvtphone(trim(ph.phone_num),default_phone_cd)
      ELSEIF (size(tempphone) < 8)
       fmtphone = format(trim(ph.phone_num),"###-####")
      ELSE
       fmtphone = format(trim(ph.phone_num),"(###) ###-####")
      ENDIF
     ENDIF
     IF (ph.extension > " ")
      fmtphone = concat(trim(fmtphone)," x",ph.extension)
     ENDIF
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), stat =
     alterlist(reply->row[reply->row_cnt].col,100),
     reply->row[reply->row_cnt].col[1].data_string = "Phone Number", reply->row[reply->row_cnt].col[x
     ].data_string = fmtphone
    ENDIF
   FOOT  por.organization_id
    IF ((reply->row_cnt > save_row))
     save_row = reply->row_cnt
    ENDIF
   FOOT REPORT
    reply->row_cnt = save_row
    IF ((x > reply->col_cnt))
     reply->col_cnt = x
    ENDIF
   WITH nocounter, outerjoin = d1, dontcare = a,
    dontcare = ph
  ;end select
 ENDIF
END GO
