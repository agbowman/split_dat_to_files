CREATE PROGRAM bhs_ma_nut_stats_v5jw:dba
 PROMPT
  "Defaut Prompt for any error messages:" = "MINE",
  "Beginning Date:" = "SYSDATE",
  "End Date:" = "SYSDATE",
  "Select Facility" = 0,
  "Select Nursing Unit or Any(*) for All :" = 0,
  "Type in email address or leave default for report preview:" = "Report_Preview"
  WITH outdev, bdate, edate,
  fname, nunit, email
 EXECUTE bhs_sys_stand_subroutine
 IF (datetimediff(cnvtdatetime( $EDATE),cnvtdatetime( $BDATE)) > 31)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is larger than 31 days.", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_prg
 ELSEIF (datetimediff(cnvtdatetime( $EDATE),cnvtdatetime( $BDATE)) < 0)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is outside 31 days.", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08
  ;end select
  GO TO exit_prg
 ENDIF
 DECLARE var_output = c45
 DECLARE email_ind = i4
 SET email_ind = 4
 IF (findstring("@", $EMAIL) > 0)
  SET email_ind = 1
  SET var_output = "bhs_diet_stats1.csv"
 ELSE
  SET email_ind = 0
 ENDIF
 DECLARE any_status_ind = c1 WITH constant(substring(1,1,reflect(parameter(5,0)))), public
 DECLARE var_oname = f8 WITH noconstant(0.0), public
 DECLARE var_filename = c40
 SET var_filename = "jjacobs_csv_test1.csv"
 DECLARE var_grandtotal = i4
 SET var_grandtotal = 0
 DECLARE order_var = f8 WITH constant(uar_get_code_by("MEANING",6003,"ORDER")), protect
 DECLARE ordered_var = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED")), protect
 DECLARE completed_var = f8 WITH constant(uar_get_code_by("MEANING",6004,"COMPLETED")), protect
 DECLARE dc_var = f8 WITH constant(uar_get_code_by("MEANING",6004,"DISCONTINUED")), protect
 DECLARE nsconsult_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"CONSULTNUTRITIONSERVICES"
   )), protect
 DECLARE parnut_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "PARENTERALNUTRITIONASSESSMENT")), protect
 DECLARE nsfollow_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "NUTRITIONSERVICECONSULTFOLLOWUP")), protect
 DECLARE tubefeed_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "NUTRITIONASSESSMENTTUBEFEEDING")), protect
 DECLARE oralsupp_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "NUTRITIONASSESSMENTORALSUPPLEMENTS")), protect
 DECLARE assessadd_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "NUTRITIONASSESSMENTADDITIVES")), protect
 DECLARE highrisk_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "HIGHRISKNUTRITIONASSESSMENT")), protect
 DECLARE nutap_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"NUTRITIONASSESSMENTPERPOLICY"
   )), protect
 DECLARE metcart_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",100642,"METABOLICCART")),
 protect
 DECLARE dappdiet_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",100642,
   "DETERMINEAPPROPRIATEDIET")), protect
 DECLARE dietinst_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",100642,"DIETINSTRUCTIONS")),
 protect
 DECLARE foodpref_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",100642,"FOODPREFERENCES")),
 protect
 DECLARE oralsuppd_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",100642,"ORALSUPPLEMENTS")),
 protect
 DECLARE parnutd_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",100642,"PARENTERALNUTRITION")),
 protect
 DECLARE tubefeedd_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",100642,"TUBEFEEDINGS")),
 protect
 DECLARE nutassess_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",100642,"NUTRITIONASSESSMENT")),
 protect
 DECLARE dischrgday_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DISCHDAYSTAY")), protect
 DECLARE dischrgobs_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DISCHOBV")), protect
 DECLARE expip_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDIP")), protect
 DECLARE dischrgip_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DISCHIP")), protect
 FREE RECORD nut_cnt
 RECORD nut_cnt(
   1 begdate = c15
   1 enddate = c15
   1 facility = c30
   1 nurseunit = c30
   1 runtime = c15
   1 runby = c30
   1 totalcnt = i4
   1 list1_cnt = i4
   1 list2_cnt = i4
   1 list[*]
     2 sort_order = i4
     2 order_name = c40
     2 ordered = i4
     2 completed = i4
     2 discontinued_man = i4
     2 discontinued_sys = i4
     2 totalbyorder = i4
     2 grand_total_group = i4
     2 c_metabolic_carto = i4
     2 c_metabolic_cartc = i4
     2 c_metabolic_cartd = i4
     2 c_appro_dieto = i4
     2 c_appro_dietc = i4
     2 c_appro_dietd = i4
     2 c_dietinsto = i4
     2 c_dietinstc = i4
     2 c_dietinstd = i4
     2 c_foodprefo = i4
     2 c_foodprefc = i4
     2 c_foodprefd = i4
     2 c_oralsupo = i4
     2 c_oralsupc = i4
     2 c_oralsupd = i4
     2 c_parnuto = i4
     2 c_parnutc = i4
     2 c_parnutd = i4
     2 c_tubefo = i4
     2 c_tubefc = i4
     2 c_tubefd = i4
     2 c_nutassesso = i4
     2 c_nutassessc = i4
     2 c_nutassessd = i4
     2 ordersent_total = i4
 )
 SET name = curuser
 DECLARE username = c20
 DECLARE userfullname = c30
 IF ((reqinfo->updt_id=0))
  SET username = curuser
 ELSE
  SELECT INTO "nl:"
   p.name_full_formatted
   FROM prsnl p
   WHERE (p.person_id=reqinfo->updt_id)
   DETAIL
    username = substring(1,20,p.username), userfullname = substring(1,30,p.name_full_formatted)
   WITH nocounter
  ;end select
 ENDIF
 SELECT
  IF (any_status_ind="C")
   PLAN (o1
    WHERE o1.orig_order_dt_tm BETWEEN cnvtdatetime(value( $BDATE)) AND cnvtdatetime(value( $EDATE))
     AND ((o1.catalog_cd+ 0) IN (nsfollow_var, nsconsult_var, parnut_var, tubefeed_var, oralsupp_var,
    assessadd_var, highrisk_var, nutap_var))
     AND ((o1.order_status_cd+ 0) IN (ordered_var, completed_var, dc_var)))
    JOIN (oa
    WHERE oa.order_id=o1.order_id
     AND ((oa.action_type_cd+ 0)=order_var))
    JOIN (o
    WHERE o.order_id=oa.order_id
     AND ((o.catalog_cd+ 0) IN (nsfollow_var, nsconsult_var, parnut_var, tubefeed_var, oralsupp_var,
    assessadd_var, highrisk_var, nutap_var))
     AND ((o.order_status_cd+ 0) IN (ordered_var, completed_var, dc_var)))
    JOIN (e
    WHERE e.encntr_id=o.encntr_id
     AND ((e.loc_facility_cd+ 0)= $FNAME))
    JOIN (ec
    WHERE ec.encntr_id=o.encntr_id
     AND o.orig_order_dt_tm BETWEEN ec.beg_effective_dt_tm AND ec.end_effective_dt_tm)
    JOIN (d3)
    JOIN (od
    WHERE od.order_id=o.order_id
     AND od.oe_field_value IN (metcart_var, dappdiet_var, dietinst_var, foodpref_var, oralsuppd_var,
    parnutd_var, tubefeedd_var, nutassess_var))
  ELSE
   PLAN (o1
    WHERE o1.orig_order_dt_tm BETWEEN cnvtdatetime(value( $BDATE)) AND cnvtdatetime(value( $EDATE))
     AND ((o1.catalog_cd+ 0) IN (nsfollow_var, nsconsult_var, parnut_var, tubefeed_var, oralsupp_var,
    assessadd_var, highrisk_var, nutap_var))
     AND ((o1.order_status_cd+ 0) IN (ordered_var, completed_var, dc_var)))
    JOIN (oa
    WHERE oa.order_id=o1.order_id
     AND ((oa.action_type_cd+ 0)=order_var))
    JOIN (o
    WHERE o.order_id=oa.order_id
     AND ((o.catalog_cd+ 0) IN (nsfollow_var, nsconsult_var, parnut_var, tubefeed_var, oralsupp_var,
    assessadd_var, highrisk_var, nutap_var))
     AND ((o.order_status_cd+ 0) IN (ordered_var, completed_var, dc_var)))
    JOIN (e
    WHERE e.encntr_id=o.encntr_id
     AND (e.loc_facility_cd= $FNAME))
    JOIN (ec
    WHERE ec.encntr_id=o.encntr_id
     AND (ec.loc_nurse_unit_cd= $NUNIT)
     AND o.orig_order_dt_tm BETWEEN ec.beg_effective_dt_tm AND ec.end_effective_dt_tm)
    JOIN (d3)
    JOIN (od
    WHERE od.order_id=o.order_id
     AND od.oe_field_value IN (metcart_var, dappdiet_var, dietinst_var, foodpref_var, oralsuppd_var,
    parnutd_var, tubefeedd_var, nutassess_var))
  ENDIF
  DISTINCT INTO "nl:"
  e.encntr_id, e.reg_dt_tm"@SHORTDATETIMENOSEC", e_encntr_status_disp = uar_get_code_display(e
   .encntr_status_cd),
  e_encntr_type_disp = uar_get_code_display(e.encntr_type_cd), e_loc_facility_disp =
  uar_get_code_display(e.loc_facility_cd), e_loc_nurse_unit_disp = uar_get_code_display(e
   .loc_nurse_unit_cd),
  lochist_nurse_unit = uar_get_code_display(ec.loc_nurse_unit_cd), o.order_id, oa.action_dt_tm
  "@SHORTDATETIMENOSEC",
  o.hna_order_mnemonic, sort_order = evaluate(o.catalog_cd,1845632.00,1.0,1289389.00,2.0,
   1845629.00,3.0,1845622.00,4.0,1845627.00,
   5.0,792551.00,7.0,906086.00,8.0,
   71524750.00,9.0,10.0), od.oe_field_display_value,
  order_status = uar_get_code_display(o.order_status_cd), discontinue_type = uar_get_code_display(o
   .discontinue_type_cd), begdate =  $BDATE,
  enddate =  $EDATE, nunit_prompt =  $NUNIT
  FROM order_action oa,
   orders o,
   orders o1,
   encounter e,
   encntr_loc_hist ec,
   order_detail od,
   dummyt d3
  ORDER BY o.catalog_cd, o.order_id, od.order_id,
   od.action_sequence, od.detail_sequence
  HEAD REPORT
   cnt_cat = 0, cnt_total = 0, tcnt_ordered = 0,
   tcnt_completed = 0, tcnt_dcman = 0, tcnt_dcsys = 0,
   cnt_total_groupo = 0, cnt_total_groupc = 0, cnt_total_groupdm = 0,
   cnt_total_groupds = 0, cnt_grand_group = 0, nut_cnt->begdate = concat(substring(1,2, $BDATE),"/",
    substring(3,2, $BDATE),"/",substring(5,4, $BDATE)),
   nut_cnt->enddate = concat(substring(1,2, $EDATE),"/",substring(3,2, $EDATE),"/",substring(5,4,
      $EDATE)), nut_cnt->facility = uar_get_code_display( $FNAME), nut_cnt->runtime = format(
    cnvtdatetime(curdate,curtime3),"MM/DD/YY @HH:MM;;D"),
   nut_cnt->runby = userfullname
   IF (any_status_ind="C")
    nut_cnt->nurseunit = "ALL"
   ELSE
    nut_cnt->nurseunit = uar_get_code_display( $NUNIT)
   ENDIF
   stat = alterlist(nut_cnt->list,20)
  HEAD o.catalog_cd
   cnt_sum = 0, cnt_cat = (cnt_cat+ 1)
   IF (mod(cnt_cat,10)=1
    AND cnt_cat > 20)
    stat = alterlist(nut_cnt->list,(cnt_cat+ 9))
   ENDIF
   nut_cnt->list[cnt_cat].sort_order = sort_order, nut_cnt->list[cnt_cat].order_name =
   uar_get_code_display(o.catalog_cd), tcnt_order = 0,
   cnt_ordered = 0, cnt_complete = 0, cnt_dc = 0,
   cnt_dc_sys = 0, cnt_dc_man = 0, cnt_ordered_dad = 0,
   cnt_dc_dad = 0, cnt_complete_dad = 0, cnt_ordered_os = 0,
   cnt_dc_os = 0, cnt_complete_os = 0, cnt_ordered_mc = 0,
   cnt_dc_mc = 0, cnt_complete_mc = 0, cnt_ordered_di = 0,
   cnt_dc_di = 0, cnt_complete_di = 0, cnt_ordered_fp = 0,
   cnt_dc_fp = 0, cnt_complete_fp = 0, cnt_ordered_pn = 0,
   cnt_dc_pn = 0, cnt_complete_pn = 0, cnt_ordered_tf = 0,
   cnt_dc_tf = 0, cnt_complete_tf = 0, cnt_ordered_na = 0,
   cnt_dc_na = 0, cnt_complete_na = 0, cnt_ns_ordered = 0,
   cnt_ns_complete = 0, cnt_ns_dc_sys = 0, cnt_ns_dc_man = 0,
   var_nsc = 0
  HEAD o.order_id
   IF (o.catalog_cd IN (parnut_var, nsfollow_var, tubefeed_var, oralsupp_var, assessadd_var,
   highrisk_var, nutap_var))
    cnt_total = (cnt_total+ 1)
    IF (o.order_status_cd=dc_var)
     cnt_dc = (cnt_dc+ 1)
     IF (o.discontinue_type_cd=2415)
      cnt_dc_man = (cnt_dc_man+ 1)
     ELSEIF (((o.discontinue_type_cd != 2415) OR (o.discontinue_type_cd <= 0.0)) )
      cnt_dc_sys = (cnt_dc_sys+ 1)
     ENDIF
    ELSEIF (o.order_status_cd=ordered_var)
     cnt_ordered = (cnt_ordered+ 1)
    ELSEIF (o.order_status_cd=completed_var)
     cnt_complete = (cnt_complete+ 1)
    ENDIF
   ENDIF
  DETAIL
   IF (o.catalog_cd IN (nsconsult_var))
    cnt_total = (cnt_total+ 1), var_nsc = (var_nsc+ 1)
    IF (o.order_status_cd=dc_var)
     IF (o.discontinue_type_cd=2415)
      cnt_ns_dc_man = (cnt_ns_dc_man+ 1)
     ELSEIF (((o.discontinue_type_cd != 2415) OR (o.discontinue_type_cd <= 0.0)) )
      cnt_ns_dc_sys = (cnt_ns_dc_sys+ 1)
     ENDIF
    ELSEIF (o.order_status_cd=ordered_var)
     cnt_ns_ordered = (cnt_ns_ordered+ 1)
    ELSEIF (o.order_status_cd=completed_var)
     cnt_ns_complete = (cnt_ns_complete+ 1)
    ENDIF
    IF (od.oe_field_display_value="Determine Appropriate Diet")
     CASE (order_status)
      OF "Ordered":
       cnt_ordered_dad = (cnt_ordered_dad+ 1)
      OF "Discontinued":
       cnt_dc_dad = (cnt_dc_dad+ 1)
      OF "Completed":
       cnt_complete_dad = (cnt_complete_dad+ 1)
     ENDCASE
    ELSEIF (od.oe_field_display_value="Oral Supplements")
     CASE (order_status)
      OF "Ordered":
       cnt_ordered_os = (cnt_ordered_os+ 1)
      OF "Discontinued":
       cnt_dc_os = (cnt_dc_os+ 1)
      OF "Completed":
       cnt_complete_os = (cnt_complete_os+ 1)
     ENDCASE
    ELSEIF (od.oe_field_display_value="Metabolic Cart")
     CASE (order_status)
      OF "Ordered":
       cnt_ordered_mc = (cnt_ordered_mc+ 1)
      OF "Discontinued":
       cnt_dc_mc = (cnt_dc_mc+ 1)
      OF "Completed":
       cnt_complete_mc = (cnt_complete_mc+ 1)
     ENDCASE
    ELSEIF (od.oe_field_display_value="Diet Instructions")
     CASE (order_status)
      OF "Ordered":
       cnt_ordered_di = (cnt_ordered_di+ 1)
      OF "Discontinued":
       cnt_dc_di = (cnt_dc_di+ 1)
      OF "Completed":
       cnt_complete_di = (cnt_complete_di+ 1)
     ENDCASE
    ELSEIF (od.oe_field_display_value="Food Preferences")
     CASE (order_status)
      OF "Ordered":
       cnt_ordered_fp = (cnt_ordered_fp+ 1)
      OF "Discontinued":
       cnt_dc_fp = (cnt_dc_fp+ 1)
      OF "Completed":
       cnt_complete_fp = (cnt_complete_fp+ 1)
     ENDCASE
    ELSEIF (od.oe_field_display_value="Parenteral Nutrition")
     CASE (order_status)
      OF "Ordered":
       cnt_ordered_pn = (cnt_ordered_pn+ 1)
      OF "Discontinued":
       cnt_dc_pn = (cnt_dc_pn+ 1)
      OF "Completed":
       cnt_complete_pn = (cnt_complete_pn+ 1)
     ENDCASE
    ELSEIF (od.oe_field_display_value="Tube Feedings")
     CASE (order_status)
      OF "Ordered":
       cnt_ordered_tf = (cnt_ordered_tf+ 1)
      OF "Discontinued":
       cnt_dc_tf = (cnt_dc_tf+ 1)
      OF "Completed":
       cnt_complete_tf = (cnt_complete_tf+ 1)
     ENDCASE
    ELSEIF (od.oe_field_display_value="Nutrition Assessment")
     CASE (order_status)
      OF "Ordered":
       cnt_ordered_na = (cnt_ordered_na+ 1)
      OF "Discontinued":
       cnt_dc_na = (cnt_dc_na+ 1)
      OF "Completed":
       cnt_complete_na = (cnt_complete_na+ 1)
     ENDCASE
    ENDIF
   ENDIF
  FOOT  o.catalog_cd
   nut_cnt->list[cnt_cat].ordered = cnt_ordered, nut_cnt->list[cnt_cat].completed = cnt_complete,
   nut_cnt->list[cnt_cat].discontinued_man = cnt_dc_man,
   nut_cnt->list[cnt_cat].discontinued_sys = cnt_dc_sys, tcnt_order = ((((tcnt_order+ cnt_dc_sys)+
   cnt_dc_man)+ cnt_complete)+ cnt_ordered), nut_cnt->list[cnt_cat].totalbyorder = tcnt_order
   IF (sort_order IN (1, 2, 3, 4, 5))
    cnt_total_groupo = (cnt_total_groupo+ cnt_ordered), cnt_total_groupc = (cnt_total_groupc+
    cnt_complete), cnt_total_groupdm = (cnt_total_groupdm+ cnt_dc_man),
    cnt_total_groupds = (cnt_total_groupds+ cnt_dc_sys), cnt_grand_group = ((((cnt_grand_group+
    cnt_dc_sys)+ cnt_dc_man)+ cnt_complete)+ cnt_ordered)
   ENDIF
   IF (sort_order IN (7))
    nut_cnt->list[cnt_cat].ordered = cnt_ns_ordered, nut_cnt->list[cnt_cat].completed =
    cnt_ns_complete, nut_cnt->list[cnt_cat].discontinued_man = cnt_ns_dc_man,
    nut_cnt->list[cnt_cat].discontinued_sys = cnt_ns_dc_sys, nut_cnt->list[cnt_cat].totalbyorder =
    var_nsc
   ENDIF
   tcnt_ordered = ((tcnt_ordered+ cnt_ordered)+ cnt_ns_ordered), tcnt_completed = ((tcnt_completed+
   cnt_complete)+ cnt_ns_complete), tcnt_dcman = ((tcnt_dcman+ cnt_dc_man)+ cnt_ns_dc_man),
   tcnt_dcsys = ((tcnt_dcsys+ cnt_dc_sys)+ cnt_ns_dc_sys), nut_cnt->list[cnt_cat].c_appro_dieto =
   cnt_ordered_dad, nut_cnt->list[cnt_cat].c_appro_dietc = cnt_complete_dad,
   nut_cnt->list[cnt_cat].c_appro_dietd = cnt_dc_dad, nut_cnt->list[cnt_cat].c_oralsupc =
   cnt_complete_os, nut_cnt->list[cnt_cat].c_oralsupo = cnt_ordered_os,
   nut_cnt->list[cnt_cat].c_oralsupd = cnt_dc_os, nut_cnt->list[cnt_cat].c_metabolic_cartc =
   cnt_complete_mc, nut_cnt->list[cnt_cat].c_metabolic_carto = cnt_ordered_mc,
   nut_cnt->list[cnt_cat].c_metabolic_cartd = cnt_dc_mc, nut_cnt->list[cnt_cat].c_dietinstc =
   cnt_complete_di, nut_cnt->list[cnt_cat].c_dietinsto = cnt_ordered_di,
   nut_cnt->list[cnt_cat].c_dietinstd = cnt_dc_di, nut_cnt->list[cnt_cat].c_foodprefc =
   cnt_complete_fp, nut_cnt->list[cnt_cat].c_foodprefo = cnt_ordered_fp,
   nut_cnt->list[cnt_cat].c_foodprefd = cnt_dc_fp, nut_cnt->list[cnt_cat].c_parnutc = cnt_complete_pn,
   nut_cnt->list[cnt_cat].c_parnuto = cnt_ordered_pn,
   nut_cnt->list[cnt_cat].c_parnutd = cnt_dc_pn, nut_cnt->list[cnt_cat].c_tubefc = cnt_complete_tf,
   nut_cnt->list[cnt_cat].c_tubefo = cnt_ordered_tf,
   nut_cnt->list[cnt_cat].c_tubefd = cnt_dc_tf, nut_cnt->list[cnt_cat].c_nutassessc = cnt_complete_na,
   nut_cnt->list[cnt_cat].c_nutassesso = cnt_ordered_na,
   nut_cnt->list[cnt_cat].c_nutassessd = cnt_dc_na, nut_cnt->list[cnt_cat].ordersent_total = var_nsc
  FOOT REPORT
   nut_cnt->totalcnt = cnt_total
   IF (mod(cnt_cat,10)=1
    AND cnt_cat > 100)
    stat = alterlist(nut_cnt->list,(cnt_cat+ 9))
   ENDIF
   cnt_cat = (cnt_cat+ 1), nut_cnt->list[cnt_cat].sort_order = 6, nut_cnt->list[cnt_cat].order_name
    = "Totals for preceding orders",
   nut_cnt->list[cnt_cat].ordered = cnt_total_groupo, nut_cnt->list[cnt_cat].completed =
   cnt_total_groupc, nut_cnt->list[cnt_cat].discontinued_man = cnt_total_groupdm,
   nut_cnt->list[cnt_cat].discontinued_sys = cnt_total_groupds, nut_cnt->list[cnt_cat].totalbyorder
    = cnt_grand_group, cnt_cat = (cnt_cat+ 1),
   var_grandtotal = cnt_cat, nut_cnt->list[cnt_cat].sort_order = 11, nut_cnt->list[cnt_cat].
   order_name = "Grand Total All Orders",
   nut_cnt->list[cnt_cat].totalbyorder = cnt_total, nut_cnt->list[cnt_cat].ordered = tcnt_ordered,
   nut_cnt->list[cnt_cat].completed = tcnt_completed,
   nut_cnt->list[cnt_cat].discontinued_man = tcnt_dcman, nut_cnt->list[cnt_cat].discontinued_sys =
   tcnt_dcsys, stat = alterlist(nut_cnt->list,cnt_cat)
  WITH nocounter, outerjoin = d3, time = 520
 ;end select
 SELECT
  IF (any_status_ind="C")
   PLAN (ce
    WHERE ((ce.valid_from_dt_tm+ 0) BETWEEN cnvtdatetime(cnvtdate( $BDATE),0) AND cnvtdatetime(
     cnvtdate( $EDATE),235959))
     AND ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(cnvtdate( $BDATE),0) AND cnvtdatetime(cnvtdate(
       $EDATE),235959)
     AND ((ce.catalog_cd+ 0) IN (906086.00))
     AND ((ce.valid_until_dt_tm+ 0)=cnvtdatetime("31-Dec-2100"))
     AND ((ce.view_level+ 0)=1))
    JOIN (e
    WHERE e.encntr_id=ce.encntr_id
     AND (e.loc_facility_cd= $FNAME))
    JOIN (ec
    WHERE ec.encntr_id=e.encntr_id
     AND (ec.beg_effective_dt_tm=
    (SELECT
     max(e2.beg_effective_dt_tm)
     FROM encntr_loc_hist e2
     WHERE e2.encntr_id=e.encntr_id
      AND  NOT (((e2.encntr_type_cd+ 0) IN (dischrgday_var, dischrgobs_var, expip_var, dischrgip_var)
     )))))
    JOIN (o
    WHERE o.order_id=ce.order_id
     AND ((o.order_status_cd+ 0) IN (ordered_var, completed_var, dc_var)))
  ELSE
  ENDIF
  DISTINCT INTO "nl:"
  ce.encntr_id, c_catalog_disp = uar_get_code_display(ce.catalog_cd), ce.catalog_cd,
  ce.order_id, ce.person_id, ce.event_title_text,
  ce.event_tag, c_result_status_disp = uar_get_code_display(ce.result_status_cd), ce.event_id,
  sort_order = 8, ce.valid_until_dt_tm, ce.clinsig_updt_dt_tm,
  ce.valid_from_dt_tm, e.reg_dt_tm"@SHORTDATETIMENOSEC", e_encntr_status_disp = uar_get_code_display(
   e.encntr_status_cd),
  e_encntr_type_disp = uar_get_code_display(e.encntr_type_cd), e_loc_facility_disp =
  uar_get_code_display(e.loc_facility_cd), e_loc_nurse_unit_disp = uar_get_code_display(e
   .loc_nurse_unit_cd),
  lochist_nurse_unit = uar_get_code_display(ec.loc_nurse_unit_cd), order_status =
  uar_get_code_display(o.order_status_cd), discontinue_type = uar_get_code_display(o
   .discontinue_type_cd)
  FROM clinical_event ce,
   encounter e,
   encntr_loc_hist ec,
   orders o
  PLAN (ce
   WHERE ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(cnvtdate( $BDATE),0) AND cnvtdatetime(cnvtdate(
      $EDATE),235959)
    AND ((ce.valid_from_dt_tm+ 0) BETWEEN cnvtdatetime(cnvtdate( $BDATE),0) AND cnvtdatetime(cnvtdate
    ( $EDATE),235959))
    AND ((ce.catalog_cd+ 0) IN (906086.00))
    AND ((ce.valid_until_dt_tm+ 0)=cnvtdatetime("31-Dec-2100"))
    AND ((ce.view_level+ 0)=1))
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND (e.loc_facility_cd= $FNAME))
   JOIN (ec
   WHERE ec.encntr_id=e.encntr_id
    AND (ec.loc_nurse_unit_cd= $NUNIT)
    AND (ec.beg_effective_dt_tm=
   (SELECT
    max(e2.beg_effective_dt_tm)
    FROM encntr_loc_hist e2
    WHERE e2.encntr_id=e.encntr_id
     AND  NOT (((e2.encntr_type_cd+ 0) IN (dischrgday_var, dischrgobs_var, expip_var, dischrgip_var))
    ))))
   JOIN (o
   WHERE o.order_id=ce.order_id
    AND ((o.order_status_cd+ 0) IN (ordered_var, completed_var, dc_var)))
  ORDER BY ce.event_id
  HEAD REPORT
   cnt_cfu = 0, tcntx_order = 0, cntx_ordered = 0,
   cntx_complete = 0, cntx_dc = 0, cntx_dc_sys = 0,
   cntx_dc_man = 0, cfu_grands = 0, cfu_gordered = 0,
   cfu_gcomplete = 0, cfu_gdc_sys = 0, cfu_gdc_man = 0
  HEAD ce.event_id
   tcntx_order = (tcntx_order+ 1)
   IF (o.order_status_cd=dc_var)
    cntx_dc = (cntx_dc+ 1)
    IF (o.discontinue_type_cd=2415)
     cntx_dc_man = (cntx_dc_man+ 1)
    ELSEIF (((o.discontinue_type_cd != 2415) OR (o.discontinue_type_cd <= 0.0)) )
     cntx_dc_sys = (cntx_dc_sys+ 1)
    ENDIF
   ELSEIF (o.order_status_cd=ordered_var)
    cntx_ordered = (cntx_ordered+ 1)
   ELSEIF (o.order_status_cd=completed_var)
    cntx_complete = (cntx_complete+ 1)
   ENDIF
  FOOT REPORT
   cnt_cfu = (var_grandtotal+ 1), stat = alterlist(nut_cnt->list,cnt_cfu), nut_cnt->list[cnt_cfu].
   sort_order = sort_order,
   nut_cnt->list[cnt_cfu].order_name = uar_get_code_display(ce.catalog_cd), nut_cnt->list[cnt_cfu].
   ordered = cntx_ordered, nut_cnt->list[cnt_cfu].completed = cntx_complete,
   nut_cnt->list[cnt_cfu].discontinued_man = cntx_dc_man, nut_cnt->list[cnt_cfu].discontinued_sys =
   cntx_dc_sys, nut_cnt->list[cnt_cfu].totalbyorder = tcntx_order,
   cfu_grands = (tcntx_order+ nut_cnt->list[var_grandtotal].totalbyorder), cfu_gordered = (
   cntx_ordered+ nut_cnt->list[var_grandtotal].ordered), cfu_gcomplete = (cntx_complete+ nut_cnt->
   list[var_grandtotal].completed),
   cfu_gdc_sys = (cntx_dc_sys+ nut_cnt->list[var_grandtotal].discontinued_sys), cfu_gdc_man = (
   cntx_dc_man+ nut_cnt->list[var_grandtotal].discontinued_man), nut_cnt->list[var_grandtotal].
   totalbyorder = cfu_grands,
   nut_cnt->list[var_grandtotal].ordered = cfu_gordered, nut_cnt->list[var_grandtotal].completed =
   cfu_gcomplete, nut_cnt->list[var_grandtotal].discontinued_sys = cfu_gdc_sys,
   nut_cnt->list[var_grandtotal].discontinued_man = cfu_gdc_man
  WITH nocounter, time = 540
 ;end select
 IF (email_ind=1)
  SELECT INTO value(var_output)
   order_name_or_totals = nut_cnt->list[d3.seq].order_name, total_number_ordered = nut_cnt->list[d3
   .seq].totalbyorder, status_ordered = nut_cnt->list[d3.seq].ordered,
   status_completed = nut_cnt->list[d3.seq].completed, status_dc_manual = nut_cnt->list[d3.seq].
   discontinued_man, status_dc_system = nut_cnt->list[d3.seq].discontinued_sys,
   begin_nutritional_consult_details = "***", nsc_determine_appr_diet_ordered = nut_cnt->list[d3.seq]
   .c_appro_dieto, nsc_determine_appr_diet_completed = nut_cnt->list[d3.seq].c_appro_dietc,
   nsc_determine_appr_diet_dc = nut_cnt->list[d3.seq].c_appro_dietd, nsc_oral_supp_ordered = nut_cnt
   ->list[d3.seq].c_oralsupo, nsc_oral_supp_completed = nut_cnt->list[d3.seq].c_oralsupc,
   nsc_oral_supp_dc = nut_cnt->list[d3.seq].c_oralsupd, nsc_metabolic_cart_ordered = nut_cnt->list[d3
   .seq].c_metabolic_carto, nsc_metabolic_cart_completed = nut_cnt->list[d3.seq].c_metabolic_cartc,
   nsc_metabolic_cart_dc = nut_cnt->list[d3.seq].c_metabolic_cartd, nsc_diet_inst_ordered = nut_cnt->
   list[d3.seq].c_dietinsto, nsc_diet_inst_completed = nut_cnt->list[d3.seq].c_dietinstc,
   nsc_diet_inst_dc = nut_cnt->list[d3.seq].c_dietinstd, nsc_food_pref_ordered = nut_cnt->list[d3.seq
   ].c_foodprefo, nsc_food_pref_completed = nut_cnt->list[d3.seq].c_foodprefc,
   nsc_food_pref_dc = nut_cnt->list[d3.seq].c_foodprefd, nsc_parent_nut_ordered = nut_cnt->list[d3
   .seq].c_parnuto, nsc_parent_nut_completed = nut_cnt->list[d3.seq].c_parnutc,
   nsc_parent_nut_dc = nut_cnt->list[d3.seq].c_parnutd, nsc_tube_feed_ordered = nut_cnt->list[d3.seq]
   .c_tubefo, nsc_tube_feed_completed = nut_cnt->list[d3.seq].c_tubefc,
   nsc_tube_feed_dc = nut_cnt->list[d3.seq].c_tubefd, nsc_nutrition_assess_ordered = nut_cnt->list[d3
   .seq].c_nutassesso, nsc_nutrition_assess_completed = nut_cnt->list[d3.seq].c_nutassessc,
   nsc_nutrition_assess_dc = nut_cnt->list[d3.seq].c_nutassessd, total_count_nsc_order_sentances =
   nut_cnt->list[d3.seq].ordersent_total, begin_prompt_details = "***",
   beg_date_prompt = nut_cnt->begdate, end_date_prompt = nut_cnt->enddate, facility_prompt = nut_cnt
   ->facility,
   nursing_unit_prompt = nut_cnt->nurseunit, run_time = nut_cnt->runtime, run_by = nut_cnt->runby
   FROM (dummyt d3  WITH seq = size(nut_cnt->list,5))
   PLAN (d3)
   ORDER BY nut_cnt->list[d3.seq].sort_order
   WITH nocounter, format, pcformat('"',","),
    time = 30
  ;end select
  SET filename_in = var_output
  SET email_address = trim( $EMAIL)
  SET filename_out = "bhs_diet.csv"
  SET dclcom = concat('sed "s/$/`echo \\\r`/" ',filename_in)
  CALL echo(dclcom)
  SET len = size(trim(dclcom))
  SET status = 0
  CALL dcl(dclcom,len,status)
  CALL emailfile(filename_in,filename_out,email_address,concat(trim(curprog),
    " - Baystate Medical Center Charge Audit"),1)
 ELSE
  SELECT INTO  $OUTDEV
   order_name_or_totals = nut_cnt->list[d3.seq].order_name, total_number_ordered = nut_cnt->list[d3
   .seq].totalbyorder, status_ordered = nut_cnt->list[d3.seq].ordered,
   status_completed = nut_cnt->list[d3.seq].completed, status_dc_manual = nut_cnt->list[d3.seq].
   discontinued_man, status_dc_system = nut_cnt->list[d3.seq].discontinued_sys,
   begin_nutritional_consult_details = "***", nsc_determine_appr_diet_ordered = nut_cnt->list[d3.seq]
   .c_appro_dieto, nsc_determine_appr_diet_completed = nut_cnt->list[d3.seq].c_appro_dietc,
   nsc_determine_appr_diet_dc = nut_cnt->list[d3.seq].c_appro_dietd, nsc_oral_supp_ordered = nut_cnt
   ->list[d3.seq].c_oralsupo, nsc_oral_supp_completed = nut_cnt->list[d3.seq].c_oralsupc,
   nsc_oral_supp_dc = nut_cnt->list[d3.seq].c_oralsupd, nsc_metabolic_cart_ordered = nut_cnt->list[d3
   .seq].c_metabolic_carto, nsc_metabolic_cart_completed = nut_cnt->list[d3.seq].c_metabolic_cartc,
   nsc_metabolic_cart_dc = nut_cnt->list[d3.seq].c_metabolic_cartd, nsc_diet_inst_ordered = nut_cnt->
   list[d3.seq].c_dietinsto, nsc_diet_inst_completed = nut_cnt->list[d3.seq].c_dietinstc,
   nsc_diet_inst_dc = nut_cnt->list[d3.seq].c_dietinstd, nsc_food_pref_ordered = nut_cnt->list[d3.seq
   ].c_foodprefo, nsc_food_pref_completed = nut_cnt->list[d3.seq].c_foodprefc,
   nsc_food_pref_dc = nut_cnt->list[d3.seq].c_foodprefd, nsc_parent_nut_ordered = nut_cnt->list[d3
   .seq].c_parnuto, nsc_parent_nut_completed = nut_cnt->list[d3.seq].c_parnutc,
   nsc_parent_nut_dc = nut_cnt->list[d3.seq].c_parnutd, nsc_tube_feed_ordered = nut_cnt->list[d3.seq]
   .c_tubefo, nsc_tube_feed_completed = nut_cnt->list[d3.seq].c_tubefc,
   nsc_tube_feed_dc = nut_cnt->list[d3.seq].c_tubefd, nsc_nutrition_assess_ordered = nut_cnt->list[d3
   .seq].c_nutassesso, nsc_nutrition_assess_completed = nut_cnt->list[d3.seq].c_nutassessc,
   nsc_nutrition_assess_dc = nut_cnt->list[d3.seq].c_nutassessd, total_count_nsc_order_sentances =
   nut_cnt->list[d3.seq].ordersent_total, begin_prompt_details = "***",
   beg_date_prompt = nut_cnt->begdate, end_date_prompt = nut_cnt->enddate, facility_prompt = nut_cnt
   ->facility,
   nursing_unit_prompt = nut_cnt->nurseunit, run_time = nut_cnt->runtime, run_by = nut_cnt->runby
   FROM (dummyt d3  WITH seq = size(nut_cnt->list,5))
   PLAN (d3)
   ORDER BY nut_cnt->list[d3.seq].sort_order
   WITH nocounter, separator = " ", format,
    time = 15
  ;end select
 ENDIF
#exit_prg
END GO
