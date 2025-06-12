CREATE PROGRAM bhs_active_order_consult_rpt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility" = 0,
  "Nurse Unit" = 0
  WITH outdev, var_fac_cd, nu
 FREE RECORD ord_cat
 RECORD ord_cat(
   1 l_cnt = i4
   1 list[*]
     2 f_cat_cd = f8
     2 s_cat_prim_mnem = vc
 ) WITH protect
 DECLARE spaces = c90
 DECLARE temp = c90
 DECLARE ml_idx1 = i4
 DECLARE mf_cs6004_completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,
   "COMPLETED"))
 DECLARE mf_cs6004_ordered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE mf_cs6003_order_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE mf_cs48_active_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE"))
 DECLARE mf_cs71_observation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "OBSERVATION"))
 DECLARE mf_cs71_dischip_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHIP"))
 DECLARE mf_cs71_expiredip_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDIP"
   ))
 DECLARE mf_cs71_disches_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHES"))
 DECLARE mf_cs71_dischobv_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHOBV"))
 DECLARE mf_cs71_preadmitdaystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "PREADMITDAYSTAY"))
 DECLARE mf_cs71_dischdaystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "DISCHDAYSTAY"))
 DECLARE mf_cs71_daystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY"))
 DECLARE mf_cs71_expiredes_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDES"
   ))
 DECLARE mf_cs71_expiredobv_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "EXPIREDOBV"))
 DECLARE mf_cs71_expireddaystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "EXPIREDDAYSTAY"))
 DECLARE mf_cs71_emergency_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY"
   ))
 DECLARE mf_cs71_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"
   ))
 DECLARE mf_ea_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_ea_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 SET spaces = fillstring(90," ")
 SET temp = fillstring(90," ")
 SET echo_ind = 1
 SET rpt_name = "Consults (Active Orders)"
 SET prg_name = cnvtlower(curprog)
 DECLARE mrn_cd = f8
 SET mrn_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(319,"MRN",1,mrn_cd)
 DECLARE fin_cd = f8
 SET fin_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(319,"FIN NBR",1,fin_cd)
 DECLARE any_loc_ind = c1 WITH constant(substring(1,1,reflect(parameter(3,0)))), public
 CALL echo(build("any_loc_ind:",any_loc_ind))
 IF (any_loc_ind="C")
  SET loc_where = build2(" ed.loc_facility_cd + 0 = ", $VAR_FAC_CD)
 ELSEIF (( $NU > 0))
  SET loc_where = build2(" ed.loc_nurse_unit_cd + 0 = ", $NU)
 ELSE
  SET loc_where = build2(" ed.loc_facility_cd + 0 = ", $VAR_FAC_CD)
 ENDIF
 CALL echo(build("Parser: ",loc_where))
 SELECT INTO "nl:"
  FROM order_catalog oc
  WHERE oc.primary_mnemonic IN ("Consult Geriatric BMC", "Psych Consult (Adult)",
  "Consult Palliative Care")
  HEAD REPORT
   ord_cat->l_cnt = 0
  DETAIL
   ord_cat->l_cnt += 1, stat = alterlist(ord_cat->list,ord_cat->l_cnt), ord_cat->list[ord_cat->l_cnt]
   .f_cat_cd = oc.catalog_cd,
   ord_cat->list[ord_cat->l_cnt].s_cat_prim_mnem = trim(oc.primary_mnemonic,3)
  WITH nocounter
 ;end select
 SELECT INTO  $OUTDEV
  e_loc_facility_cd = uar_get_code_description(e.loc_facility_cd), e_loc_nurse_unit_cd =
  uar_get_code_display(e.loc_nurse_unit_cd), p.name_full_formatted,
  mrn = substring(1,10,ea1.alias), fin = substring(1,10,ea2.alias), rm_bd = concat(trim(
    uar_get_code_display(e.loc_room_cd)),"/",trim(uar_get_code_display(e.loc_bed_cd))),
  o.ordered_as_mnemonic, o.orig_order_dt_tm"dd-mmm-yyyy hh:mm:ss;;q"
  FROM encntr_domain ed,
   orders o,
   encounter e,
   order_action oa,
   prsnl p,
   person pp,
   encntr_alias ea1,
   encntr_alias ea2
  PLAN (ed
   WHERE parser(loc_where)
    AND ed.end_effective_dt_tm > sysdate
    AND ed.loc_nurse_unit_cd > 0)
   JOIN (o
   WHERE expand(ml_idx1,1,ord_cat->l_cnt,o.catalog_cd,ord_cat->list[ml_idx1].f_cat_cd)
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime((curdate - 1),0) AND cnvtdatetime((curdate - 1),
    235959)
    AND o.order_status_cd=mf_cs6004_ordered_cd
    AND o.active_ind=1
    AND o.active_status_cd=mf_cs48_active_cd)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_type_cd=mf_cs6003_order_cd)
   JOIN (p
   WHERE p.person_id=oa.order_provider_id)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.encntr_type_cd IN (mf_cs71_observation_cd, mf_cs71_dischip_cd, mf_cs71_expiredip_cd,
   mf_cs71_disches_cd, mf_cs71_dischobv_cd,
   mf_cs71_preadmitdaystay_cd, mf_cs71_dischdaystay_cd, mf_cs71_daystay_cd, mf_cs71_expiredes_cd,
   mf_cs71_expiredobv_cd,
   mf_cs71_expireddaystay_cd, mf_cs71_emergency_cd, mf_cs71_inpatient_cd))
   JOIN (pp
   WHERE pp.person_id=e.person_id)
   JOIN (ea1
   WHERE (ea1.encntr_id= Outerjoin(e.encntr_id))
    AND (ea1.encntr_alias_type_cd= Outerjoin(mf_ea_mrn_cd))
    AND (ea1.active_ind= Outerjoin(1))
    AND (ea1.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (ea2
   WHERE (ea2.encntr_id= Outerjoin(e.encntr_id))
    AND (ea2.encntr_alias_type_cd= Outerjoin(mf_ea_fin_cd))
    AND (ea2.active_ind= Outerjoin(1))
    AND (ea2.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
  HEAD REPORT
   MACRO (init_wrap)
    beg_line = 1, bw = 0, pos = 1,
    eol = 0, len = 0, t_len = 1,
    ew = 0, line_cnt = 0
   ENDMACRO
   ,
   MACRO (init_row)
    r_cnt = 16
   ENDMACRO
   ,
   MACRO (ln_feed)
    font0, row + 1, r_cnt += 1,
    row r_cnt
   ENDMACRO
   ,
   x_col = 20, y_col = 45, y_jump = 12,
   nu_rests = 0, fac_rests = 0, org_rests = 0,
   r_cnt = 0, cnt = 0, date_stamp = format(curdate,"mm/dd/yyyy;;d"),
   time_stamp = format(curtime,"hh:mm;;m"), line = fillstring(24,"="), line1 = fillstring(90,"_"),
   line2 = fillstring(85,"_"), 1st_nu = 1, fac_prtd = 0,
   new_nu = 0, new_rm_bd = 0, nu_prtd = 0,
   re_prt = 1, new_pat = 0, last_fac = e_loc_facility_cd,
   last_nur_u = e_loc_nurse_unit_cd, last_rm_bd = rm_bd, last_pt_name = p.name_full_formatted,
   last_mrn = mrn, last_fin = fin, font0 = "{f/0}{cpi/12}{lpi/6}",
   font1 = "{f/8}{cpi/8}", font2 = "{f/8}{cpi/15}{lpi/8}", font3 = "{f/8}{cpi/10}{lpi/8}"
  HEAD PAGE
   "{cpi/8}{pos/36/30}{color/20/140}", row + 1, "{cpi/8}{pos/36/37}{color/20/140}",
   row + 1, "{cpi/8}{pos/36/44}{color/20/140}", row + 1,
   "{cpi/8}{pos/36/51}{color/20/140}", row + 1, "{cpi/8}{pos/36/58}{color/20/140}",
   row + 1, "{cpi/8}{pos/36/65}{color/20/140}", row + 1,
   font1, row + 1, col 01,
   CALL print(calcpos(197,20)), "{b/23}BAYSTATE HEALTH SYSTEMS", font3,
   row + 1, col 01,
   CALL print(calcpos(225,49)),
   "{b}", rpt_name, "{endb}",
   row + 1, lf_xcol = 40, y_col = 80,
   y_jump = 10, ct_xcol = 190, rt_xcol = 450,
   font2, row + 1,
   CALL print(calcpos(lf_xcol,y_col)),
   "{b/9}Run Date: ", date_stamp, row + 1,
   CALL print(calcpos(rt_xcol,y_col)), "{b/9}Prg Name: ", prg_name,
   row + 1, y_col += y_jump,
   CALL print(calcpos(lf_xcol,y_col)),
   "{b/9}Run Time: ", time_stamp, row + 1,
   CALL print(calcpos(ct_xcol,y_col)), row + 1,
   CALL print(calcpos(rt_xcol,y_col)),
   "{b/5}Page: ", curpage"###", row + 1,
   r_cnt = 16
  HEAD e.loc_facility_cd
   ln_feed, fac_rests = 0
   IF (e_loc_facility_cd=last_fac)
    ln_feed, col 005, line2,
    ln_feed, ln_feed, col 005,
    "{b/9}Facility: ", col 023, last_fac,
    fac_prtd = 1
   ELSE
    last_fac = e_loc_facility_cd, fac_prtd = 1
   ENDIF
  HEAD e.loc_nurse_unit_cd
   nur_rests = 0
   IF (e_loc_nurse_unit_cd=last_nur_u)
    nu_prtd = 1, ln_feed, col 005,
    "{b/11}Nurse Unit: ", col 024, last_nur_u
   ELSE
    1st_nu = 1, nu_prtd = 1, new_nu = 1,
    init_row, BREAK, ln_feed,
    col 005, line2, ln_feed,
    ln_feed, col 005, "{b/9}Facility: ",
    col 023, last_fac, ln_feed,
    col 005, "{b/11}Nurse Unit: ", col 024,
    e_loc_nurse_unit_cd, last_nur_u = e_loc_nurse_unit_cd, last_rm_bd = rm_bd,
    last_pt_name = p.name_full_formatted, last_mrn = mrn, last_fin = fin
   ENDIF
  HEAD rm_bd
   IF (r_cnt >= 50)
    rm_prtd = 1, new_rm_bd = 1, init_row,
    BREAK
   ENDIF
   IF (new_rm_bd)
    ln_feed, col 005, line2,
    ln_feed, ln_feed, col 005,
    "{b/9}Facility: ", col 023, last_fac
   ENDIF
   IF (new_rm_bd)
    ln_feed, col 005, "{b/11}Nurse Unit: ",
    col 024, last_nur_u
   ENDIF
  DETAIL
   ln_feed, ln_feed, pt_name = substring(1,40,p.name_full_formatted),
   col 005, "{b/8}Patient: ", col 023,
   pt_name, col 060, "{b/4}MRN: ",
   mrn, col 080, "{b/4}FIN: ",
   fin, rm_prtd = 1, ln_feed,
   col 005, "{b/9}Room/Bed: ", col 023,
   rm_bd, nur_rests += 1, fac_rests += 1,
   org_rests += 1, ln_feed, ln_feed,
   mnem = trim(o.ordered_as_mnemonic), col 005, "{b/8}Ordered: ",
   mnem, ln_feed, col 005,
   "{b/18}Date/Time Ordered: ", o.orig_order_dt_tm"mm/dd/yy hh:mm;;q", col 040,
   oa.action_dt_tm"mm/dd/yy hh:mm;;q", init_wrap
   IF (((t_len > 0) OR (size(trim(temp)) > 0)) )
    ln_feed, p_temp = trim(temp,3), col 005,
    p_temp, temp = spaces, beg_line = 1,
    t_len = 0
   ENDIF
   ln_feed, col 005, line2,
   ln_feed
  FOOT  e.loc_nurse_unit_cd
   r_cnt = 64, row r_cnt, nu_line = concat("{b}","****  End of Nurse Unit - ",trim(last_nur_u,3),
    "  ****","{endb}"),
   col 10, nu_line, ln_feed,
   col 16, "Total Restraints For This Unit = ", nur_rests"##"
  FOOT  e.loc_facility_cd
   ln_feed, row r_cnt, fac_line = concat("{b}","****  End of Facility - ",trim(last_fac,3),"  ****",
    "{endb}"),
   col 10, fac_line, ln_feed,
   row r_cnt, col 16, "Total Restraints For This Facility = ",
   fac_rests"##"
  FOOT REPORT
   ln_feed, org_line = concat("{b}","****  END OF REPORT  ****","{endb}"), col 10,
   org_line, ln_feed, col 16,
   "Grand Total For Baystate Health System = ", org_rests"###"
  WITH nocounter, dio = postscript, maxrow = 70,
   maxcol = 500, nullreport
 ;end select
END GO
