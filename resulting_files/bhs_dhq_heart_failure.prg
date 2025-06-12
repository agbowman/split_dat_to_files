CREATE PROGRAM bhs_dhq_heart_failure
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility (1 - BMC, 2 - FMC, 3 - MLH, 4 - BWH,  5 - BNH)" = "1"
  WITH outdev, facility
 SET begin_dt_tm = cnvtdatetime(curdate,curtime3)
 DECLARE active_active_type_cd = f8
 DECLARE egate_adt_cd = f8
 DECLARE lasix_cat_cd = f8
 DECLARE noninvas_card_type_cd = f8
 DECLARE daily_freq_cd = f8
 DECLARE daily_bb_freq_cd = f8
 DECLARE daily_am_freq_cd = f8
 DECLARE every_24_freq_cd = f8
 DECLARE every_8_freq_cd = f8
 DECLARE ordered_order_status_cd = f8
 DECLARE completed_order_status_cd = f8
 DECLARE cardiology_catalog_type_cd = f8
 DECLARE pharmacy_catalog_type_cd = f8
 DECLARE attending_phys_r_cd = f8
 DECLARE bnp_cat_cd = f8
 SET active_active_type_cd = uar_get_code_by("MEANING",48,"ACTIVE")
 SET egate_adt_cd = uar_get_code_by("DISPLAYKEY",73,"ADTEGATE")
 SET lasix_cat_cd = uar_get_code_by("DISPLAYKEY",200,"FUROSEMIDE")
 SET bnp_cat_cd = uar_get_code_by("DISPLAYKEY",200,"BTYPENATRIURETICPEPTIDE")
 SET noninvas_card_type_cd = uar_get_code_by("MEANING",106,"CARDIOLOGY")
 SET weights_cat_cd = uar_get_code_by("DISPLAYKEY",200,"WEIGHT")
 SET daily_freq_cd = uar_get_code_by("DISPLAYKEY",4003,"DAILY")
 SET daily_am_freq_cd = uar_get_code_by("DISPLAYKEY",4003,"DAILYINAM")
 SET daily_am_freq_cd = uar_get_code_by("DISPLAYKEY",4003,"DAILYBEFOREBREAKFAST")
 SET every_24_freq_cd = uar_get_code_by("DISPLAYKEY",4003,"EVERY24HOURS")
 SET every_8_freq_cd = uar_get_code_by("DISPLAYKEY",4003,"EVERY8HOURS")
 SET ordered_order_status_cd = uar_get_code_by("MEANING",6004,"ORDERED")
 SET completed_order_status_cd = uar_get_code_by("MEANING",6004,"COMPLETED")
 SET cardiology_catalog_type_cd = uar_get_code_by("MEANING",6000,"CARDIOLOGY")
 SET pharmacy_catalog_type_cd = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET attending_phys_r_cd = uar_get_code_by("MEANING",333,"ATTENDDOC")
 FREE RECORD facilities
 RECORD facilities(
   1 list[*]
     2 loc_facility_cd = f8
 )
 SELECT INTO "nl:"
  cv.display, cva.alias
  FROM code_value cv,
   code_value_outbound cva
  PLAN (cv
   WHERE cv.code_set=220
    AND cv.active_ind=1
    AND cv.cdf_meaning="FACILITY"
    AND cv.active_type_cd=active_active_type_cd)
   JOIN (cva
   WHERE cva.code_value=cv.code_value
    AND cva.contributor_source_cd=egate_adt_cd)
  HEAD REPORT
   fac_cnt = 0
  DETAIL
   IF (( $FACILITY="1")
    AND cva.alias="BMC")
    fac_cnt = (fac_cnt+ 1)
    IF (mod(fac_cnt,10)=1)
     stat = alterlist(facilities->list,(fac_cnt+ 9))
    ENDIF
    facilities->list[fac_cnt].loc_facility_cd = cv.code_value
   ELSEIF (( $FACILITY="2")
    AND cva.alias="FMC")
    fac_cnt = (fac_cnt+ 1)
    IF (mod(fac_cnt,10)=1)
     stat = alterlist(facilities->list,(fac_cnt+ 9))
    ENDIF
    facilities->list[fac_cnt].loc_facility_cd = cv.code_value
   ELSEIF (( $FACILITY="3")
    AND cva.alias="MLH")
    fac_cnt = (fac_cnt+ 1)
    IF (mod(fac_cnt,10)=1)
     stat = alterlist(facilities->list,(fac_cnt+ 9))
    ENDIF
    facilities->list[fac_cnt].loc_facility_cd = cv.code_value
   ELSEIF (( $FACILITY="4")
    AND cva.alias="BWH")
    fac_cnt = (fac_cnt+ 1)
    IF (mod(fac_cnt,10)=1)
     stat = alterlist(facilities->list,(fac_cnt+ 9))
    ENDIF
    facilities->list[fac_cnt].loc_facility_cd = cv.code_value
   ELSEIF (( $FACILITY="5")
    AND cva.alias="BNH")
    fac_cnt = (fac_cnt+ 1)
    IF (mod(fac_cnt,10)=1)
     stat = alterlist(facilities->list,(fac_cnt+ 9))
    ENDIF
    facilities->list[fac_cnt].loc_facility_cd = cv.code_value
   ENDIF
  FOOT REPORT
   stat = alterlist(facilities->list,fac_cnt)
  WITH nocounter
 ;end select
 FREE RECORD ace_arb_cds
 RECORD ace_arb_cds(
   1 list[*]
     2 catalog_cd = f8
     2 multum_category_id = f8
 )
 SELECT INTO "nl:"
  FROM mltm_drug_categories mdc,
   mltm_category_drug_xref mcdx,
   order_catalog oc
  PLAN (mdc
   WHERE mdc.category_name IN ("angiotensin converting enzyme inhibitors",
   "angiotensin II inhibitors", "antihypertensive combinations"))
   JOIN (mcdx
   WHERE mcdx.multum_category_id=mdc.multum_category_id)
   JOIN (oc
   WHERE oc.cki=concat("MUL.ORD!",mcdx.drug_identifier))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(ace_arb_cds->list,(cnt+ 9))
   ENDIF
   ace_arb_cds->list[cnt].catalog_cd = oc.catalog_cd, ace_arb_cds->list[cnt].multum_category_id = mdc
   .multum_category_id
  FOOT REPORT
   cnt = (cnt+ 1), stat = alterlist(ace_arb_cds->list,cnt), ace_arb_cds->list[cnt].catalog_cd =
   lasix_cat_cd,
   ace_arb_cds->list[cnt].multum_category_id = 154
  WITH nocounter
 ;end select
 CALL echorecord(ace_arb_cds)
 FREE RECORD encntrs
 RECORD encntrs(
   1 list[*]
     2 encntr_id = f8
     2 person_id = f8
     2 pat_name = c30
     2 loc_facility_cd = f8
     2 loc_nurse_unit_cd = f8
     2 loc_room_cd = f8
     2 loc_bed_cd = f8
     2 att_phys_id = f8
     2 att_phys_name = c30
     2 bnp = c1
     2 lasix = c1
     2 lasix_home = c1
     2 med_cnt1 = i4
     2 med_cnt2 = i4
     2 med_cnt3 = i4
     2 meds_ace[*]
       3 catalog_cd = f8
       3 home = c1
     2 meds_arb[*]
       3 catalog_cd = f8
       3 home = c1
     2 meds_other[*]
       3 catalog_cd = f8
       3 home = c1
     2 echo_cnt = i4
     2 echos[*]
       3 catalog_cd = f8
       3 current_start_dt_tm = dq8
       3 order_status_cd = f8
 )
 DECLARE inpatient_encntr_type_cd = f8
 DECLARE observation_encntr_type_cd = f8
 SET inpatient_encntr_type_cd = uar_get_code_by("DISPLAY",71,"Inpatient")
 SET observation_encntr_type_cd = uar_get_code_by("DISPLAY",71,"Observation")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(facilities->list,5))),
   encounter e,
   encntr_domain ed,
   orders o,
   order_detail od,
   dummyt d2
  PLAN (d)
   JOIN (ed
   WHERE ed.end_effective_dt_tm=cnvtdate("12312100")
    AND (ed.loc_facility_cd=facilities->list[d.seq].loc_facility_cd))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.encntr_type_cd IN (inpatient_encntr_type_cd, observation_encntr_type_cd))
   JOIN (d2)
   JOIN (o
   WHERE o.encntr_id=e.encntr_id
    AND o.catalog_cd=bnp_cat_cd)
   JOIN (od
   WHERE od.order_id=outerjoin(o.order_id)
    AND od.oe_field_meaning=outerjoin("FREQ"))
  ORDER BY e.encntr_id
  HEAD REPORT
   cnt = 0
  HEAD e.encntr_id
   cnt = (cnt+ 1)
   IF (mod(cnt,50)=1)
    stat = alterlist(encntrs->list,(cnt+ 49))
   ENDIF
   encntrs->list[cnt].encntr_id = e.encntr_id, encntrs->list[cnt].person_id = e.person_id, encntrs->
   list[cnt].loc_facility_cd = e.loc_facility_cd,
   encntrs->list[cnt].loc_nurse_unit_cd = e.loc_nurse_unit_cd, encntrs->list[cnt].loc_room_cd = e
   .loc_room_cd, encntrs->list[cnt].loc_bed_cd = e.loc_bed_cd
  DETAIL
   IF (o.catalog_cd=bnp_cat_cd
    AND o.order_status_cd=ordered_order_status_cd
    AND o.order_status_cd IN (ordered_order_status_cd, completed_order_status_cd))
    encntrs->list[cnt].bnp = "Y"
   ENDIF
  FOOT  e.encntr_id
   echo_idx = 0, encntrs->list[cnt].echo_cnt = echo_idx, echo_idx = 0
  FOOT REPORT
   stat = alterlist(encntrs->list,cnt)
  WITH outerjoin = d2
 ;end select
 CALL echo(ordered_order_status_cd)
 CALL echo(pharmacy_catalog_type_cd)
 DECLARE idx = i4
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(encntrs->list,5))),
   orders o
  PLAN (d)
   JOIN (o
   WHERE (o.person_id=encntrs->list[d.seq].person_id)
    AND o.order_status_cd=ordered_order_status_cd
    AND o.catalog_type_cd=pharmacy_catalog_type_cd
    AND o.template_order_id=0
    AND expand(idx,1,size(ace_arb_cds->list,5),o.catalog_cd,ace_arb_cds->list[idx].catalog_cd))
  ORDER BY o.encntr_id
  HEAD o.encntr_id
   row + 0, med_idx1 = 0, med_idx2 = 0,
   med_idx3 = 0, encntrs->list[d.seq].lasix = "N", encntrs->list[d.seq].lasix_home = "N"
  DETAIL
   current_category = 0
   FOR (i = 1 TO size(ace_arb_cds->list,5))
     IF ((ace_arb_cds->list[i].catalog_cd=o.catalog_cd))
      current_category = ace_arb_cds->list[i].multum_category_id
     ENDIF
   ENDFOR
   IF (o.orig_ord_as_flag IN (0, 1)
    AND (o.encntr_id=encntrs->list[d.seq].encntr_id))
    IF (current_category=42)
     med_idx1 = (size(encntrs->list[d.seq].meds_ace,5)+ 1), stat = alterlist(encntrs->list[d.seq].
      meds_ace,med_idx1), encntrs->list[d.seq].meds_ace[med_idx1].catalog_cd = o.catalog_cd,
     encntrs->list[d.seq].meds_ace[med_idx1].home = "N"
    ELSEIF (current_category=56)
     med_idx2 = (size(encntrs->list[d.seq].meds_arb,5)+ 1), stat = alterlist(encntrs->list[d.seq].
      meds_arb,med_idx2), encntrs->list[d.seq].meds_arb[med_idx2].catalog_cd = o.catalog_cd,
     encntrs->list[d.seq].meds_arb[med_idx2].home = "N"
    ELSEIF (current_category=154)
     IF (o.orig_ord_as_flag=0)
      encntrs->list[d.seq].lasix = "Y"
     ENDIF
    ENDIF
   ELSEIF (o.orig_ord_as_flag=2)
    IF (current_category=42)
     med_idx1 = (size(encntrs->list[d.seq].meds_ace,5)+ 1), stat = alterlist(encntrs->list[d.seq].
      meds_ace,med_idx1), encntrs->list[d.seq].meds_ace[med_idx1].catalog_cd = o.catalog_cd,
     encntrs->list[d.seq].meds_ace[med_idx1].home = "Y"
    ELSEIF (current_category=56)
     med_idx2 = (size(encntrs->list[d.seq].meds_arb,5)+ 1), stat = alterlist(encntrs->list[d.seq].
      meds_arb,med_idx2), encntrs->list[d.seq].meds_arb[med_idx2].catalog_cd = o.catalog_cd,
     encntrs->list[d.seq].meds_arb[med_idx2].home = "Y"
    ELSEIF (current_category=154)
     encntrs->list[d.seq].lasix_home = "Y"
    ENDIF
   ENDIF
  FOOT  o.encntr_id
   encntrs->list[d.seq].med_cnt1 = size(encntrs->list[d.seq].meds_ace,5), encntrs->list[d.seq].
   med_cnt2 = size(encntrs->list[d.seq].meds_arb,5)
  WITH nocounter
 ;end select
 CALL echorecord(encntrs)
 DECLARE display_line = vc
 SELECT INTO  $1
  FROM (dummyt d  WITH seq = value(size(encntrs->list,5))),
   encntr_alias ea,
   person p,
   encntr_prsnl_reltn epr,
   prsnl pr
  PLAN (d
   WHERE (((encntrs->list[d.seq].bnp="Y")) OR ((((encntrs->list[d.seq].lasix="Y")) OR ((((encntrs->
   list[d.seq].lasix_home="Y")) OR ((((encntrs->list[d.seq].echo_cnt > 0)) OR ((((encntrs->list[d.seq
   ].med_cnt1 > 0)) OR ((encntrs->list[d.seq].med_cnt2 > 0))) )) )) )) )) )
   JOIN (ea
   WHERE (ea.encntr_id=encntrs->list[d.seq].encntr_id)
    AND ea.encntr_alias_type_cd=1077)
   JOIN (p
   WHERE (p.person_id=encntrs->list[d.seq].person_id))
   JOIN (epr
   WHERE epr.encntr_id=outerjoin(ea.encntr_id)
    AND epr.active_ind=outerjoin(1)
    AND epr.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND epr.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
    AND epr.encntr_prsnl_r_cd=outerjoin(attending_phys_r_cd))
   JOIN (pr
   WHERE pr.person_id=outerjoin(epr.prsnl_person_id))
  HEAD PAGE
   IF (( $2="1"))
    CALL center("Baystate Medical Center",1,131)
   ELSEIF (( $2="2"))
    CALL center("Baystate Franklin Medical Center",1,131)
   ELSEIF (( $2="3"))
    CALL center("Baystate Marylane Hospital",1,131)
   ENDIF
   row + 1,
   CALL center("Division of Healthcare Quality",1,131), row + 1,
   CALL center("Patients Whose Orders Suggest the Presence of Heart Failure",1,131), row + 1,
   CALL center(format(cnvtdatetime(curdate,curtime3),"MM/DD/YYYY;;D"),1,131),
   row + 2
   IF (curendreport)
    CALL center("No Report Today",1,131)
   ENDIF
  DETAIL
   CALL center("               ",1,131), pat_name_disp = substring(1,30,p.name_full_formatted),
   att_name_disp = substring(1,30,pr.name_full_formatted),
   loc_nu_disp = substring(1,20,concat(trim(uar_get_code_display(encntrs->list[d.seq].
       loc_nurse_unit_cd)),"/",trim(uar_get_code_display(encntrs->list[d.seq].loc_room_cd)),"/",trim(
      uar_get_code_display(encntrs->list[d.seq].loc_bed_cd)))), col 1, pat_name_disp,
   col 32, loc_nu_disp, col 53,
   att_name_disp, row + 1, col 5,
   "BNP: "
   IF ((encntrs->list[d.seq].bnp="Y"))
    col 20, "Yes"
   ELSE
    col 20, "No"
   ENDIF
   row + 1, col 5, "Furosemide: "
   IF ((encntrs->list[d.seq].lasix="Y"))
    col 20, "Yes (Inp)", cur_col = 29
   ELSE
    col 20, "No (Inp)", cur_col = 28
   ENDIF
   IF ((encntrs->list[d.seq].lasix_home="Y"))
    col cur_col, ", Yes (Home)"
   ELSE
    col cur_col, ", No (Home)"
   ENDIF
   row + 1, row + 1, col 5,
   "ACE Inhibitor:"
   IF ((encntrs->list[d.seq].med_cnt1=0))
    col 20, "No"
   ELSE
    FOR (i = 1 TO encntrs->list[d.seq].med_cnt1)
     IF (i=1)
      display_line = trim(uar_get_code_display(encntrs->list[d.seq].meds_ace[i].catalog_cd))
     ELSE
      display_line = concat(display_line,", ",trim(uar_get_code_display(encntrs->list[d.seq].
         meds_ace[i].catalog_cd)))
     ENDIF
     ,
     IF ((encntrs->list[d.seq].meds_ace[i].home="Y"))
      display_line = concat(display_line," (Home)")
     ELSE
      display_line = concat(display_line," (Inp)")
     ENDIF
    ENDFOR
    col 20, display_line
   ENDIF
   row + 1, col 5, "ARB: "
   IF ((encntrs->list[d.seq].med_cnt2=0))
    col 20, "No"
   ELSE
    FOR (i = 1 TO encntrs->list[d.seq].med_cnt2)
     IF (i=1)
      display_line = trim(uar_get_code_display(encntrs->list[d.seq].meds_arb[i].catalog_cd))
     ELSE
      display_line = concat(display_line,", ",trim(uar_get_code_display(encntrs->list[d.seq].
         meds_arb[i].catalog_cd)))
     ENDIF
     ,
     IF ((encntrs->list[d.seq].meds_arb[i].home="Y"))
      display_line = concat(display_line," (Home)")
     ELSE
      display_line = concat(display_line," (Inp)")
     ENDIF
    ENDFOR
    col 20, display_line
   ENDIF
   row + 1
  WITH nocounter, nullreport
 ;end select
 CALL echo(concat("Beginning Time: ",format(begin_dt_tm,"MM/DD/YYYY HH:MM:SS;;D")))
 CALL echo(concat("Endinding Time: ",format(cnvtdatetime(curdate,curtime3),"MM/DD/YYYY HH:MM:SS;;D"))
  )
END GO
