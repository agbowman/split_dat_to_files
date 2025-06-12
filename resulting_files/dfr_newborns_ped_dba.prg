CREATE PROGRAM dfr_newborns_ped:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility "
  WITH outdev, var_fac_cd
 SET echo_ind = 1
 SET echo_ind = 0
 DECLARE pcp_cd = f8
 SET pcp_cd = 0.0
 DECLARE fin_cd = f8
 SET fin_cd = 0.0
 DECLARE nb1 = f8
 DECLARE nb2 = f8
 DECLARE nb3 = f8
 DECLARE nb4 = f8
 DECLARE nb5 = f8
 DECLARE nb6 = f8
 DECLARE nb7 = f8
 DECLARE nb8 = f8
 DECLARE nb9 = f8
 SET nb1 = 0.0
 SET nb2 = 0.0
 SET nb3 = 0.0
 SET nb4 = 0.0
 SET nb5 = 0.0
 SET nb6 = 0.0
 SET nb7 = 0.0
 SET nb8 = 0.0
 SET nb9 = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.active_ind=1
   AND cv.code_set=319
   AND cv.display_key="FINNBR"
  DETAIL
   fin_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.*
  FROM code_value cv
  WHERE cv.active_ind=1
   AND cv.code_set=331
   AND cv.display_key="PCP"
  DETAIL
   pcp_cd = cv.code_value
  WITH nocounter, check
 ;end select
 SELECT INTO "nl:"
  cd = cv.code_value, d_key = cv.display_key
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.active_ind=1
   AND cv.cdf_meaning="NURSEUNIT"
  DETAIL
   CASE (d_key)
    OF "NNURA":
     nb1 = cd
    OF "NNURB":
     nb2 = cd
    OF "NNURC":
     nb3 = cd
    OF "NNURD":
     nb4 = cd
    OF "NICU":
     nb5 = cd
    OF "NCCN":
     nb6 = cd
    OF "NURS":
     nb7 = cd
    OF "NSY":
     nb8 = cd
    OF "WI":
     nb9 = cd
   ENDCASE
  WITH nocounter, check
 ;end select
 IF (echo_ind)
  CALL echo(build("pcp_cd =",pcp_cd))
  CALL echo(build("NNURA nb1 =",nb1))
  CALL echo(build("NNURB nb2 =",nb2))
  CALL echo(build("NNURC nb3 =",nb3))
  CALL echo(build("NNURD nb4 =",nb4))
  CALL echo(build("NICU nb5 =",nb5))
  CALL echo(build("NCCN nb6 =",nb6))
  CALL echo(build("NURS nb7 =",nb7))
  CALL echo(build("NSY nb8 =",nb8))
  CALL echo(build("WI nb9 =",nb9))
  CALL echo(build("fin_cd =",fin_cd))
 ENDIF
 SELECT INTO value( $OUTDEV)
  ed.loc_facility_cd, fac_desc = uar_get_code_description(ed.loc_facility_cd), ed.loc_building_cd,
  build_desc = uar_get_code_display(ed.loc_building_cd), ed.loc_nurse_unit_cd, nu_desc =
  uar_get_code_display(ed.loc_nurse_unit_cd),
  ed.loc_room_cd, rm = uar_get_code_display(ed.loc_room_cd), ed.loc_bed_cd,
  bd = uar_get_code_display(ed.loc_bed_cd), rm_bd = concat(trim(uar_get_code_display(ed.loc_room_cd),
    3),"/",trim(uar_get_code_display(ed.loc_bed_cd),3)), ea.alias,
  p.name_full_formatted, p.birth_dt_tm"mm/dd/yyyy hh:mm;3;q", e.reg_dt_tm"mm/dd/yyyy hh:mm;3;q",
  p1.name_full_formatted, pdi.doc_phone, ppr.person_prsnl_r_cd,
  ppr_person_prsnl_r_cd = uar_get_code_display(ppr.person_prsnl_r_cd)
  FROM encntr_domain ed,
   encounter e,
   encntr_alias ea,
   person p,
   dummyt d1,
   person_prsnl_reltn ppr,
   prsnl p1,
   bhs_ped_doc_info pdi
  PLAN (ed
   WHERE ed.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ed.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ed.active_ind=1
    AND ed.loc_nurse_unit_cd IN (nb1, nb2, nb3, nb4, nb5,
   nb6, nb7, nb8, nb9)
    AND (ed.loc_facility_cd= $VAR_FAC_CD))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=fin_cd)
   JOIN (p
   WHERE p.person_id=ed.person_id
    AND p.birth_dt_tm >= cnvtdatetime((curdate - 1),0))
   JOIN (d1)
   JOIN (ppr
   WHERE ppr.person_id=ed.person_id
    AND ppr.person_prsnl_r_cd=pcp_cd)
   JOIN (p1
   WHERE p1.person_id=ppr.prsnl_person_id)
   JOIN (pdi
   WHERE pdi.person_id=p1.person_id)
  ORDER BY fac_desc, nu_desc, rm_bd
  HEAD REPORT
   title1 = "BAYSTATE HEALTH SYSTEM", title2 = "NEWBORN PEDIATRICIAN REPORT", title3 =
   "END OF REPORT",
   prev_fac = fillstring(60," "), prev_nu = fillstring(40," "), prt_fac = 0,
   prt_nu = 0, line1 = fillstring(128,"_"), line2 = fillstring(128,"-"),
   line3 = fillstring(60,"_"), blk_line = fillstring(128," "), r_cnt = 0
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
   "Patient Name", col 065, "FIN",
   col 080, "Birth Date", r_cnt = (r_cnt+ 1),
   row r_cnt, col 020, "Pediatrician",
   col 080, "Phone Nbr", r_cnt = (r_cnt+ 1),
   row r_cnt, col 001, line2
  HEAD fac_desc
   r_cnt = (r_cnt+ 1), row r_cnt, fac = trim(fac_desc),
   col 001, fac, prev_fac = fac
  HEAD nu_desc
   r_cnt = (r_cnt+ 1), row r_cnt, nu = trim(nu_desc,3),
   col 005, nu, prev_nu = nu
  DETAIL
   r_cnt = (r_cnt+ 1), row r_cnt, p_name = substring(1,40,p.name_full_formatted),
   col 010, rm_bd, col 020,
   p_name, col 065, ea.alias"##########",
   col 080, p.birth_dt_tm"mm/dd/yy hh:mm;;q"
   IF (p1.name_full_formatted > " "
    AND pdi.doc_phone > " ")
    r_cnt = (r_cnt+ 1), row r_cnt, doc_name = trim(substring(1,40,p1.name_full_formatted)),
    col 020, doc_name, doc_ph = concat("(",substring(1,3,pdi.doc_phone),") ",substring(4,3,pdi
      .doc_phone),"-",
     substring(7,4,pdi.doc_phone)),
    col 080, doc_ph
   ELSE
    r_cnt = (r_cnt+ 1), row r_cnt, col 020,
    "NO PEDIATRICIAN ENTERED FOR THIS PATIENT"
   ENDIF
   r_cnt = (r_cnt+ 1), row r_cnt, col 020,
   line3, r_cnt = (r_cnt+ 1)
   IF (r_cnt >= 54)
    r_cnt = 0, prt_fac = 1, prt_nu = 1,
    BREAK
   ENDIF
   IF (prt_fac
    AND fac=prev_fac)
    prt_fac = 0, r_cnt = (r_cnt+ 1), row r_cnt,
    col 001, prev_fac
   ENDIF
   IF (prt_nu
    AND nu=prev_nu)
    prt_nu = 0, r_cnt = (r_cnt+ 1), row r_cnt,
    col 005, prev_nu
   ENDIF
  FOOT  nu_desc
   IF (r_cnt >= 52)
    r_cnt = 0, prt_fac = 1, prt_nu = 1,
    BREAK
   ENDIF
   IF (prt_fac)
    prt_fac = 0, r_cnt = (r_cnt+ 1), row r_cnt,
    col 001, prev_fac
   ENDIF
   IF (prt_nu)
    prt_nu = 0, r_cnt = (r_cnt+ 1), row r_cnt,
    col 005, prev_nu
   ENDIF
   prev_nu = nu_desc
  FOOT  fac_desc
   prev_fac = fac_desc, BREAK
  FOOT REPORT
   r_cnt = 4, row r_cnt, col 001,
   line1, r_cnt = (r_cnt+ 1), row r_cnt,
   col 001, blk_line, r_cnt = (r_cnt+ 1),
   row r_cnt, col 001, blk_line,
   r_cnt = (r_cnt+ 1), row r_cnt, col 001,
   blk_line, r_cnt = (r_cnt+ 1), row r_cnt,
   col 001, blk_line, r_cnt = (r_cnt+ 1),
   row r_cnt, col 001, blk_line,
   r_cnt = (r_cnt+ 21), row r_cnt,
   CALL center(title3,1,128)
  WITH check, nocounter, outerjoin = d1,
   nullreport
 ;end select
END GO
