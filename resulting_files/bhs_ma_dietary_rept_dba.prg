CREATE PROGRAM bhs_ma_dietary_rept:dba
 PROMPT
  "Enter print option (file/printer/MINE):" = "MINE",
  "Facility" = ""
  WITH outdev, var_fac_cd
 EXECUTE cclseclogin
 SET echo_ind = 1
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET prt_loc = value( $OUTDEV)
 SET prg_name = "bhs_ma_dietary_rept"
 SET rpt_name = "ORDER SUMMARY"
 SET run_dttm = concat(format(curdate,"mm/dd/yy;;d")," - ",format(curtime3,"hh:mm;;m"))
 SET run_range = concat("Period Covered: ",format((curdate - 1),"mm/dd/yy;;d")," 00:00"," to ",format
  ((curdate - 1),"mm/dd/yy;;d"),
  " 23:59")
 FREE RECORD pat_data
 RECORD pat_data(
   1 pat_cnt = i2
   1 pat_qual[*]
     2 pat_name = vc
     2 person_id = f8
     2 encntr_id = f8
     2 mrn = vc
     2 fin = vc
     2 birth_dt_tm = dq8
     2 reg_dt_tm = dq8
     2 disch_dt_tm = dq8
     2 facility_cd = f8
     2 facility_disp = vc
     2 nurse_sta_cd = f8
     2 nurse_disp = vc
     2 room_cd = f8
     2 room_disp = vc
     2 bed_cd = f8
     2 bed_disp = vc
     2 encntr_type_class_cd = f8
     2 pat_type_disp = vc
     2 allergy_cnt = i2
     2 allergy_qual[*]
       3 mnemonic = vc
     2 diet_cnt = i2
     2 diet_qual[*]
       3 order_id = f8
       3 hna_order_mnemonic = vc
       3 orig_order_dt_tm = dq8
     2 tpn_cnt = i2
     2 tpn_qual[*]
       3 tpn_order_id = f8
       3 tpn_hna_order_mnemonic = vc
       3 tpn_orig_order_dt_tm = dq8
 )
 SET curalias pat pat_data->pat_qual[p]
 SET curalias pats pat_data->pat_qual[d1.seq]
 SET curalias pat_prt pat_data->pat_qual[p]
 SET curalias a_prt pat_data->pat_qual[p].allergy_qual[a]
 SET curalias diet pat_data->pat_qual[d1.seq].diet_qual[o]
 SET curalias diet_prt pat_data->pat_qual[p].diet_qual[o]
 SET curalias tpn pat_data->pat_qual[d1.seq].tpn_qual[t]
 DECLARE mrn_cd = f8
 SET mrn_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(319,"MRN",1,mrn_cd)
 DECLARE fin_cd = f8
 SET fin_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(319,"FIN NBR",1,fin_cd)
 DECLARE i_active_status_cd = f8
 SET i_active_status_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(48,"ACTIVE",1,i_active_status_cd)
 DECLARE diet_cd = f8
 DECLARE dsi_cd = f8
 DECLARE td_cd = f8
 DECLARE supp_cd = f8
 DECLARE inf_cd = f8
 DECLARE infa_cd = f8
 DECLARE tfb_cd = f8
 DECLARE tfc_cd = f8
 DECLARE tfa_cd = f8
 DECLARE high_cd = f8
 DECLARE ncs_cd = f8
 SET diet_cd = 0.0
 SET dsi_cd = 0.0
 SET td_cd = 0.0
 SET supp_cd = 0.0
 SET inf_cd = 0.0
 SET infa_cd = 0.0
 SET tfb_cd = 0.0
 SET tfc_cd = 0.0
 SET tfa_cd = 0.0
 SET high_cd = 0.0
 SET ncs_cd = 0.0
 DECLARE i_facility_cd = f8
 SET i_facility_cd = 0.0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=220
   AND (c.display_key= $VAR_FAC_CD)
   AND c.cdf_meaning="FACILITY"
   AND c.active_ind=1
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND c.inactive_dt_tm=null
  DETAIL
   i_facility_cd = c.code_value
  WITH nocounter
 ;end select
 DECLARE at_cd = f8
 SET at_cd = 0.0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=14281
   AND c.display_key="ORDERED"
   AND c.active_ind=1
  DETAIL
   at_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv = c.code_value, d_key = c.display_key
  FROM code_value c
  WHERE c.active_ind=1
   AND c.code_set=106
  DETAIL
   CASE (d_key)
    OF "DIETS":
     diet_cd = cv
    OF "DIETSPECIALINSTRUCTIONS":
     dsi_cd = cv
    OF "TESTDIET":
     td_cd = cv
    OF "SUPPLEMENTS":
     supp_cd = cv
    OF "INFANTFORMULAS":
     inf_cd = cv
    OF "INFANTFORMULAADDITIVES":
     infa_cd = cv
    OF "TUBEFEEDINGBOLUS":
     tfb_cd = cv
    OF "TUBEFEEDINGCONTINUOUS":
     tfc_cd = cv
    OF "TUBEFEEDINGADDITIVES":
     tfa_cd = cv
    OF "NUTRITIONSERVICESCONSULTS":
     ncs_cd = cv
   ENDCASE
  WITH nocounter
 ;end select
 DECLARE tpn1 = f8
 DECLARE tpn2 = f8
 DECLARE tpn3 = f8
 DECLARE tpn4 = f8
 DECLARE tpn5 = f8
 DECLARE tpn6 = f8
 DECLARE tpn7 = f8
 DECLARE tpn8 = f8
 DECLARE tpn9 = f8
 DECLARE tpn10 = f8
 DECLARE tpn11 = f8
 DECLARE tpn12 = f8
 DECLARE ppn1 = f8
 DECLARE ppn2 = f8
 DECLARE ppn3 = f8
 DECLARE ppn4 = f8
 DECLARE ppn5 = f8
 DECLARE ppn6 = f8
 SET tpn1 = 0.0
 SET tpn2 = 0.0
 SET tpn3 = 0.0
 SET tpn4 = 0.0
 SET tpn5 = 0.0
 SET tpn6 = 0.0
 SET tpn7 = 0.0
 SET tpn8 = 0.0
 SET tpn9 = 0.0
 SET tpn10 = 0.0
 SET tpn11 = 0.0
 SET tpn12 = 0.0
 SET ppn1 = 0.0
 SET ppn2 = 0.0
 SET ppn3 = 0.0
 SET ppn4 = 0.0
 SET ppn5 = 0.0
 SET ppn6 = 0.0
 SELECT INTO "nl:"
  cd = oc.catalog_cd, desc = substring(1,45,oc.description), d_key = cv.display_key,
  sorter = substring(1,3,oc.description)
  FROM order_catalog oc,
   code_value cv
  PLAN (oc
   WHERE oc.active_ind=1
    AND substring(1,3,oc.description) IN ("TPN", "PPN"))
   JOIN (cv
   WHERE cv.code_value=oc.catalog_cd
    AND cv.code_set=200
    AND cv.active_ind=1)
  ORDER BY sorter DESC
  DETAIL
   CASE (d_key)
    OF "TPNPEDIATRICCENTRALLINE":
     tpn1 = cd
    OF "TPNNEONATECENTRAL":
     tpn2 = cd
    OF "TPNFMCCENTRALLINE":
     tpn3 = cd
    OF "TPNFMCCENTRAL":
     tpn4 = cd
    OF "TPNADULTCENTRALSTANDARDLYTES":
     tpn5 = cd
    OF "TPNADULTCENTRALLINECUSTOM":
     tpn6 = cd
    OF "TPNADULTCENTRALHIPROTEINSTDLYTES":
     tpn7 = cd
    OF "TPNADULTCENTRALHIPROTEINACETATELYTES":
     tpn8 = cd
    OF "TPNADULTCENTRALACETLYTES":
     tpn9 = cd
    OF "PPNPEDIATRIC":
     ppn1 = cd
    OF "PPNNEONATE":
     ppn2 = cd
    OF "PPNMLHADULT":
     ppn3 = cd
    OF "PPNFMCADULT":
     ppn4 = cd
    OF "PPNADULTSTANDARDLYTES":
     ppn5 = cd
    OF "PPNADULTACETATELYTES":
     ppn6 = cd
   ENDCASE
  WITH nocounter
 ;end select
 IF (echo_ind)
  CALL echo(build("DIETS - diet_cd = ",diet_cd))
  CALL echo(build("DIETSPECIALINSTRUCTIONS - dsi_cd = ",dsi_cd))
  CALL echo(build("TESTDIET - td_cd = ",td_cd))
  CALL echo(build("SUPPLEMENTS - supp_cd = ",supp_cd))
  CALL echo(build("INFANTFORMULAS - inf_cd = ",inf_cd))
  CALL echo(build("INFANTFORMULAADDITIVES - infa_cd = ",infa_cd))
  CALL echo(build("TUBEFEEDINGBOLUS - tfb_cd = ",tfb_cd))
  CALL echo(build("TUBEFEEDINGCONTINUOUS - tfc_cd = ",tfc_cd))
  CALL echo(build("TUBEFEEDINGADDITIVES - tfa_cd = ",tfa_cd))
  CALL echo(build("NUTRITIONSERVICESCONSULTS - ncs_cd = ",ncs_cd))
  CALL echo(build("at_cd = ",at_cd))
  CALL echo(build("TPNPEDIATRICCENTRALLINE - tpn1 =",tpn1))
  CALL echo(build("TPNNEONATECENTRAL - tpn2 =",tpn2))
  CALL echo(build("TPNFMCCENTRALLINE - tpn3 =",tpn3))
  CALL echo(build("TPNFMCCENTRAL - tpn4 =",tpn4))
  CALL echo(build("TPNADULTCENTRALSTANDARDLYTES - tpn5 =",tpn5))
  CALL echo(build("TPNADULTCENTRALLINECUSTOM - tpn6 =",tpn6))
  CALL echo(build("TPNADULTCENTRALHIPROTEINSTDLYTES - tpn7 =",tpn7))
  CALL echo(build("TPNADULTCENTRALHIPROTEINACETATELYTES - tpn8 =",tpn8))
  CALL echo(build("TPNADULTCENTRALACETLYTES - tpn9 =",tpn9))
  CALL echo(build("PPNPEDIATRIC - ppn1 =",ppn1))
  CALL echo(build("PPNNEONATE - ppn2 =",ppn2))
  CALL echo(build("PPNMLHADULT - ppn3 =",ppn3))
  CALL echo(build("PPNFMCADULT - ppn4 =",ppn4))
  CALL echo(build("PPNADULTSTANDARDLYTES - ppn5 =",ppn5))
  CALL echo(build("PPNADULTACETATELYTES - ppn6 =",ppn6))
 ENDIF
 SELECT INTO "nl:"
  p.name_full_formatted, p.birth_dt_tm, ed.person_id,
  ed.encntr_id, ed.loc_building_cd, ed_loc_building_disp = uar_get_code_display(ed.loc_building_cd),
  ed.loc_facility_cd, ed_loc_facility_disp = uar_get_code_display(ed.loc_facility_cd), ed
  .loc_nurse_unit_cd,
  ed_loc_nurse_unit_disp = uar_get_code_display(ed.loc_nurse_unit_cd), ed.loc_room_cd,
  ed_loc_room_disp = uar_get_code_display(ed.loc_room_cd),
  ed.loc_bed_cd, ed_loc_bed_disp = uar_get_code_display(ed.loc_bed_cd), rm_bd = concat(trim(
    uar_get_code_display(ed.loc_room_cd),3),"/",trim(uar_get_code_display(ed.loc_bed_cd),3)),
  e.reg_dt_tm, e.disch_dt_tm, e.encntr_type_class_cd,
  e_encntr_type_class_cd = uar_get_code_display(e.encntr_type_class_cd), ea.alias, ea1.alias,
  n.mnemonic
  FROM encntr_domain ed,
   encounter e,
   person p,
   encntr_alias ea,
   encntr_alias ea1,
   dummyt d1,
   allergy a,
   dummyt d2,
   nomenclature_outbound no,
   nomenclature n
  PLAN (ed
   WHERE ed.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ed.loc_facility_cd=i_facility_cd
    AND ed.active_ind=1
    AND ed.active_status_cd=i_active_status_cd
    AND ed.loc_nurse_unit_cd > 0
    AND ed.loc_bed_cd > 0
    AND ed.loc_room_cd > 0)
   JOIN (p
   WHERE p.person_id=ed.person_id)
   JOIN (e
   WHERE e.person_id=ed.person_id
    AND e.encntr_id=ed.encntr_id
    AND e.disch_dt_tm=null)
   JOIN (ea
   WHERE ea.encntr_id=ed.encntr_id
    AND ea.encntr_alias_type_cd=fin_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3))
   JOIN (ea1
   WHERE ea1.encntr_id=ed.encntr_id
    AND ea1.encntr_alias_type_cd=mrn_cd
    AND ea1.active_ind=1
    AND ea1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3))
   JOIN (d1)
   JOIN (a
   WHERE a.person_id=ed.person_id
    AND a.encntr_id=ed.encntr_id
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (d2)
   JOIN (no
   WHERE no.nomenclature_id=a.substance_nom_id
    AND substring(1,3,no.alias)="DFM")
   JOIN (n
   WHERE n.nomenclature_id=no.nomenclature_id)
  ORDER BY ed.loc_facility_cd, ed.loc_nurse_unit_cd, rm_bd
  HEAD REPORT
   p = 0, a = 0
  HEAD rm_bd
   p = (p+ 1), pat_data->pat_cnt = p, stat = alterlist(pat_data->pat_qual,p),
   pat_name = substring(1,40,p.name_full_formatted), pat->pat_name = pat_name, pat->person_id = ed
   .person_id,
   pat->encntr_id = ed.encntr_id, mrn = trim(ea1.alias), pat->mrn = mrn,
   fin = trim(ea.alias), pat->fin = fin, pat->birth_dt_tm = p.birth_dt_tm,
   pat->reg_dt_tm = e.reg_dt_tm, pat->disch_dt_tm = e.disch_dt_tm, pat->facility_cd = ed
   .loc_facility_cd,
   fac = trim(uar_get_code_description(ed.loc_facility_cd)), pat->facility_disp = fac, pat->
   nurse_sta_cd = ed.loc_nurse_unit_cd,
   nur_u = trim(uar_get_code_display(ed.loc_nurse_unit_cd)), pat->nurse_disp = nur_u, pat->room_cd =
   ed.loc_room_cd,
   rm = trim(uar_get_code_display(ed.loc_room_cd)), pat->room_disp = rm, pat->bed_cd = ed.loc_bed_cd,
   bd = trim(uar_get_code_display(ed.loc_bed_cd)), pat->bed_disp = bd, pat->encntr_type_class_cd = e
   .encntr_type_class_cd,
   pat_type = trim(uar_get_code_display(e.encntr_type_class_cd)), pat->pat_type_disp = pat_type, a =
   0
  DETAIL
   IF (n.mnemonic > " ")
    a = (a+ 1), pat->allergy_cnt = a, stat = alterlist(pat_data->pat_qual[p].allergy_qual,a),
    mnem = trim(n.mnemonic), pat_data->pat_qual[p].allergy_qual[a].mnemonic = mnem
   ENDIF
  WITH nocounter, maxrow = 1000, maxcol = 2000,
   outerjoin = d1, outerjoin = d2
 ;end select
 SELECT INTO "nl:"
  sorter =
  IF (o.activity_type_cd=diet_cd) 1
  ELSEIF (o.activity_type_cd=dsi_cd) 2
  ELSEIF (o.activity_type_cd=td_cd) 3
  ELSEIF (o.activity_type_cd=supp_cd) 4
  ELSEIF (o.activity_type_cd=inf_cd) 5
  ELSEIF (o.activity_type_cd=infa_cd) 6
  ELSEIF (o.activity_type_cd=tfb_cd) 7
  ELSEIF (o.activity_type_cd=tfc_cd) 8
  ELSEIF (o.activity_type_cd=tfa_cd) 9
  ELSEIF (o.activity_type_cd=ncs_cd) 10
  ENDIF
  , psid = pats->person_id, name = pats->pat_name,
  fac = pats->facility_disp, nu = pats->nurse_disp, rm = pats->room_disp,
  pt = pats->pat_type_disp, aller = pats->allergy_qual[1].mnemonic, o.order_id,
  o.activity_type_cd, o_activity_type_cd = uar_get_code_display(o.activity_type_cd), o.catalog_cd,
  o_catalog_disp = uar_get_code_display(o.catalog_cd), o.dept_status_cd, o_dept_status_disp =
  uar_get_code_display(o.dept_status_cd),
  o.med_order_type_cd, o_med_order_type_disp = uar_get_code_display(o.med_order_type_cd), o
  .order_detail_display_line,
  o.order_mnemonic, o.order_status_cd, o_order_status_disp = uar_get_code_display(o.order_status_cd),
  o.hna_order_mnemonic, o.orig_order_dt_tm
  FROM (dummyt d1  WITH seq = pat_data->pat_cnt),
   orders o
  PLAN (d1)
   JOIN (o
   WHERE (o.person_id=pats->person_id)
    AND (o.encntr_id=pats->encntr_id)
    AND o.template_order_id=0
    AND o.activity_type_cd IN (diet_cd, td_cd, supp_cd, inf_cd, infa_cd,
   tfb_cd, tfc_cd, tfa_cd, tfc_cd, ncs_cd)
    AND o.dept_status_cd=at_cd)
  ORDER BY psid, sorter
  HEAD psid
   p = d1.seq, o = 0
  DETAIL
   o = (o+ 1), pat_data->pat_qual[d1.seq].diet_cnt = o, stat = alterlist(pat_data->pat_qual[d1.seq].
    diet_qual,o),
   diet->order_id = o.order_id, diet = trim(o.hna_order_mnemonic), diet->hna_order_mnemonic = diet,
   diet->orig_order_dt_tm = o.orig_order_dt_tm
  WITH nocounter, maxrow = 1000, maxcol = 2000
 ;end select
 IF (echo_ind)
  CALL echorecord(pat_data)
 ENDIF
 SELECT INTO value( $OUTDEV)
  FROM dummyt d
  HEAD REPORT
   title1 = "BAYSTATE HEALTH SYSTEM", title2 = "DIETARY REPORT", title3 = "END OF REPORT",
   prev_fac = fillstring(60," "), prev_nu = fillstring(40," "), prt_fac = 0,
   prt_nu = 0, first_time = 1, algy = fillstring(100," "),
   line1 = fillstring(128,"_"), line2 = fillstring(128,"-"), line3 = fillstring(60,"_"),
   blk_line = fillstring(128," "), r_cnt = 0
  HEAD PAGE
   r_cnt = 0, row r_cnt,
   CALL center(title1,1,128),
   r_cnt = (r_cnt+ 1), row r_cnt, r_dt = format(curdate,"mm/dd/yy;;d"),
   prg = cnvtlower(curprog), col 001, "Prg: ",
   prg,
   CALL center(title2,1,128), col 110,
   "Run Date: ", r_dt, r_cnt = (r_cnt+ 1),
   row r_cnt, r_tm = format(curtime3,"hh:mm;;m"), col 001,
   "Page: ", curpage"##", col 110,
   "Run Time: ", r_tm, r_cnt = (r_cnt+ 2),
   row r_cnt, col 001, "Facility",
   r_cnt = (r_cnt+ 1), row r_cnt, col 005,
   "Nurse Unit", r_cnt = (r_cnt+ 1), row r_cnt,
   col 010, "Rm/Bd", col 020,
   "Patient Name", col 065, "MRN",
   r_cnt = (r_cnt+ 1), row r_cnt, col 020,
   "Diet Order", col 085, "Order ID",
   col 100, "Order Dt/Tm", r_cnt = (r_cnt+ 1),
   row r_cnt, col 020, "Allergies",
   r_cnt = (r_cnt+ 1), row r_cnt, col 001,
   line2
  DETAIL
   FOR (p = 1 TO pat_data->pat_cnt)
     first_time = 1, fac = trim(pat_prt->facility_disp,3), prev_fac = fac,
     r_cnt = (r_cnt+ 1), row r_cnt, col 001,
     fac, nu = trim(pat_prt->nurse_disp,3), prev_nu = nu,
     r_cnt = (r_cnt+ 1), row r_cnt, col 005,
     nu, r_cnt = (r_cnt+ 1), row r_cnt,
     rm = trim(pat_prt->room_disp), bd = trim(pat_prt->bed_disp), col 010,
     rm, "/", bd,
     p_name = substring(1,40,pat_prt->pat_name), col 020, p_name,
     col 065, pat_prt->mrn"#########"
     FOR (o = 1 TO pat_data->pat_qual[p].diet_cnt)
       r_cnt = (r_cnt+ 1), row r_cnt, d_mnem = substring(1,60,diet_prt->hna_order_mnemonic),
       col 020, d_mnem, col 085,
       diet_prt->order_id"########", o_dt_tm = format(diet_prt->orig_order_dt_tm,"mm/dd/yy hh:mm;3;q"
        ), col 100,
       o_dt_tm
       IF (r_cnt >= 50)
        r_cnt = 0, BREAK
       ENDIF
     ENDFOR
     FOR (a = 1 TO pat_data->pat_qual[p].allergy_cnt)
       max_cnt = pat_data->pat_qual[p].allergy_cnt
       IF (((a=1) OR (first_time=1)) )
        algy = trim(a_prt->mnemonic), p_algy = trim(algy), len = size(p_algy),
        first_time = 0
       ENDIF
       IF (((len+ size(trim(a_prt->mnemonic))) < 90)
        AND a < max_cnt)
        algy = concat(algy,", ",a_prt->mnemonic), p_algy = trim(algy), len = size(p_algy),
        r_cnt = (r_cnt+ 1), row r_cnt, col 020,
        p_algy
       ENDIF
       IF (((len+ size(trim(a_prt->mnemonic))) >= 90)
        AND a < max_cnt)
        r_cnt = (r_cnt+ 1), row r_cnt, col 020,
        algy, first_time = 1
       ENDIF
       IF (a=max_cnt)
        r_cnt = (r_cnt+ 1), row r_cnt, col 020,
        algy
       ENDIF
     ENDFOR
     IF (r_cnt >= 45)
      r_cnt = 0, BREAK
     ENDIF
   ENDFOR
  WITH nullreport, check, maxrow = 66
 ;end select
END GO
