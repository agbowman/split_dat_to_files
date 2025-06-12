CREATE PROGRAM dcp_rpt_missingmed_org_tst:dba
 DECLARE routine_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4010,"ROUTINE")), protect
 DECLARE med_output_device = c20 WITH public, noconstant(fillstring(20," "))
 DECLARE iv_output_device = c20 WITH public, noconstant(fillstring(20," "))
 SET ord_cnt = value(size(request->ord,5))
 SET print_ind = 0
 CALL echo(ord_cnt)
 RECORD temp(
   1 text = vc
   1 cnt = i2
   1 qual[*]
     2 line = vc
 )
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 RECORD med(
   1 cnt = i2
   1 qual[*]
     2 id = f8
     2 doc = vc
     2 date = dq8
     2 tz = i4
     2 hna_mnemonic = vc
     2 order_mnemonic = vc
     2 disp_mnem = vc
     2 m_cnt = i2
     2 m_qual[*]
       3 m_line = vc
     2 disp_line = vc
     2 d_cnt = i2
     2 d_qual[*]
       3 d_line = vc
     2 review_comment = vc
 )
 RECORD iv(
   1 cnt = i2
   1 qual[*]
     2 id = f8
     2 doc = vc
     2 date = dq8
     2 tz = i4
     2 hna_mnemonic = vc
     2 order_mnemonic = vc
     2 disp_mnem = vc
     2 m_cnt = i2
     2 m_qual[*]
       3 m_line = vc
     2 disp_line = vc
     2 d_cnt = i2
     2 d_qual[*]
       3 d_line = vc
     2 review_comment = vc
 )
 DECLARE dispense_category_id = f8 WITH public, noconstant(0.0)
 DECLARE dispense_category_description = c17 WITH public, constant("Dispense Category")
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET name = fillstring(50," ")
 SET age = fillstring(50," ")
 SET dob = fillstring(50," ")
 SET mrn = fillstring(50," ")
 SET attenddoc = fillstring(50," ")
 SET admitdoc = fillstring(50," ")
 SET reqprov = fillstring(50," ")
 SET unit = fillstring(50," ")
 SET room = fillstring(50," ")
 SET bed = fillstring(50," ")
 SET facility = fillstring(4," ")
 SET finnbr = fillstring(50," ")
 SET xxx = fillstring(50," ")
 SET g = fillstring(35,"_")
 SET k = fillstring(34,"_")
 SET context = 0
 SET status1 = 0
 SET pgwidth = 8
 SET cnvtto = 0
 SET code_set = 4
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_cd = code_value
 SET code_set = 333
 SET cdf_meaning = "ATTENDDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET attend_doc_cd = code_value
 SET code_set = 333
 SET cdf_meaning = "ADMITDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET admit_doc_cd = code_value
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 EXECUTE cpm_get_cd_for_cdf
 SET finnbr_cd = code_value
 SELECT INTO "nl:"
  oef.oe_field_id
  FROM order_entry_fields oef
  WHERE oef.description=dispense_category_description
  DETAIL
   dispense_category_id = oef.oe_field_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id=reqinfo->updt_id))
  DETAIL
   reqprov = p.name_full_formatted
  WITH nocounter
 ;end select
 CALL echo(build("person_id = ",reqinfo->updt_id))
 SELECT INTO "nl:"
  e.encntr_id, e.reg_dt_tm, p.name_full_formatted,
  p.birth_dt_tm, pa.alias, pl.name_full_formatted,
  e.loc_facility_cd, e.loc_nurse_unit_cd, e.loc_room_cd,
  e.loc_bed_cd, epr.seq
  FROM person p,
   encounter e,
   person_alias pa,
   encntr_prsnl_reltn epr,
   prsnl pl,
   encntr_alias ea,
   (dummyt d1  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   (dummyt d2  WITH seq = 1)
  PLAN (e
   WHERE (e.encntr_id=request->encntr_id))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (d1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=mrn_alias_cd
    AND pa.active_ind=1)
   JOIN (d2)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND ((epr.encntr_prsnl_r_cd=attend_doc_cd) OR (epr.encntr_prsnl_r_cd=admit_doc_cd))
    AND epr.active_ind=1
    AND ((epr.expiration_ind != 1) OR (epr.expiration_ind=null)) )
   JOIN (d3)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=finnbr_cd)
   JOIN (pl
   WHERE pl.person_id=epr.prsnl_person_id)
  HEAD REPORT
   name = substring(1,30,p.name_full_formatted), age = cnvtage(cnvtdate(p.birth_dt_tm),curdate), dob
    = format(p.birth_dt_tm,"mm/dd/yy;;d"),
   mrn = substring(1,20,pa.alias), finnbr = substring(1,20,ea.alias), unit = substring(1,20,
    uar_get_code_display(e.loc_nurse_unit_cd)),
   room = substring(1,10,uar_get_code_display(e.loc_room_cd)), bed = substring(1,10,
    uar_get_code_display(e.loc_bed_cd)), facility = trim(substring(1,4,uar_get_code_display(e
      .loc_facility_cd)))
  DETAIL
   IF (epr.encntr_prsnl_r_cd=admit_doc_cd)
    admitdoc = substring(1,30,pl.name_full_formatted)
   ELSE
    attenddoc = substring(1,30,pl.name_full_formatted)
   ENDIF
  WITH nocounter, outerjoin = d1, dontcare = epr,
   dontcare = pa, outerjoin = d2, outerjoin = d3,
   dontcare = ea
 ;end select
 CALL echorecord(request)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(ord_cnt)),
   orders o,
   order_detail od,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1),
   prsnl pl
  PLAN (d)
   JOIN (o
   WHERE (o.order_id=request->ord[d.seq].order_id))
   JOIN (d1)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_id=dispense_category_id)
   JOIN (d2)
   JOIN (pl
   WHERE pl.person_id=o.last_update_provider_id)
  HEAD REPORT
   iv->cnt = 0, med->cnt = 0,
   MACRO (select_printer)
    IF (cnvtupper(facility)="BMC")
     IF (cnvtupper(trim(unit)) IN ("NCCN", "NICU", "NNURA", "NNURB", "NNURC",
     "NNURD"))
      IF (curtime BETWEEN 0800 AND 1815)
       med_output_device = "bmcww2rxpo", iv_output_device = "bmcww2rxtpn"
      ELSE
       med_output_device = "bmcspgrxpo", iv_output_device = "bmcspgrxtpn"
      ENDIF
     ELSE
      med_output_device = "bmcspgrxpo", iv_output_device = "bmcspgrxtpn"
     ENDIF
    ELSEIF (cnvtupper(facility) IN ("FMC", "BFMC"))
     med_output_device = "fmcflgrxpo", iv_output_device = "fmcflgrxtpn"
    ELSEIF (cnvtupper(facility) IN ("MLH", "BMLH"))
     med_output_device = "mlhstgrxpo", iv_output_device = "mlhstgrxtpn"
    ELSE
     med_output_device = "mlhstgrxpo", iv_output_device = "mlhstgrxtpn"
    ENDIF
    IF (trim(od.oe_field_display_value) IN ("HBM"))
     med_output_device = "bmcww2milk1", iv_output_device = "bmcww2milk1",
     CALL echo("IV label - Brest Milk printer overrider")
    ENDIF
    IF (build(trim(cnvtupper(curnode),3)) IN ("CASDTEST"))
     iv_output_device = "bmc361rxtst1", med_output_device = "bmc361rxtst1"
    ENDIF
   ENDMACRO
  DETAIL
   CALL echo(format(cnvtdatetime(o.orig_order_dt_tm),";;q")),
   CALL echo(format(cnvtdatetime(sysdate),";;q")),
   CALL echo(o.need_rx_verify_ind)
   IF (o.orig_order_dt_tm < sysdate
    AND o.need_rx_verify_ind=0)
    print_ind = 1
   ELSE
    print_ind = 0
   ENDIF
   CALL echo(build("printIND:",print_ind))
   IF (trim(od.oe_field_display_value) IN ("PREMIX IV", "TPN", "EPIDURAL", "IRRIGATION", "IVPB",
   "LVP", "PCA", "CHEMO INFUSION"))
    iv->cnt = (iv->cnt+ 1), stat = alterlist(iv->qual,iv->cnt), iv->qual[iv->cnt].id = o.order_id,
    iv->qual[iv->cnt].order_mnemonic = o.order_mnemonic, iv->qual[iv->cnt].hna_mnemonic = o
    .hna_order_mnemonic
    IF ((iv->qual[iv->cnt].order_mnemonic > " ")
     AND (iv->qual[iv->cnt].order_mnemonic != iv->qual[iv->cnt].hna_mnemonic))
     iv->qual[iv->cnt].disp_mnem = concat(trim(iv->qual[iv->cnt].hna_mnemonic),"(",trim(iv->qual[iv->
       cnt].order_mnemonic),")")
    ELSE
     iv->qual[iv->cnt].disp_mnem = trim(iv->qual[iv->cnt].hna_mnemonic)
    ENDIF
    iv->qual[iv->cnt].disp_line = trim(o.clinical_display_line), iv->qual[iv->cnt].date =
    cnvtdatetime(o.orig_order_dt_tm), iv->qual[iv->cnt].tz = o.orig_order_tz,
    iv->qual[iv->cnt].doc = pl.name_full_formatted
    IF (o.need_rx_verify_ind=0)
     iv->qual[iv->cnt].review_comment = "Verified"
    ELSEIF (o.need_rx_verify_ind=1)
     iv->qual[iv->cnt].review_comment = "Unverified"
    ELSEIF (o.need_rx_verify_ind=2)
     iv->qual[iv->cnt].review_comment = "Rejected"
    ENDIF
   ELSE
    med->cnt = (med->cnt+ 1), stat = alterlist(med->qual,med->cnt), med->qual[med->cnt].id = o
    .order_id,
    med->qual[med->cnt].order_mnemonic = o.order_mnemonic, med->qual[med->cnt].hna_mnemonic = o
    .hna_order_mnemonic
    IF ((med->qual[med->cnt].order_mnemonic > " ")
     AND (med->qual[med->cnt].order_mnemonic != med->qual[med->cnt].hna_mnemonic))
     med->qual[med->cnt].disp_mnem = concat(trim(med->qual[med->cnt].hna_mnemonic),"(",trim(med->
       qual[med->cnt].order_mnemonic),")")
    ELSE
     med->qual[med->cnt].disp_mnem = trim(med->qual[med->cnt].hna_mnemonic)
    ENDIF
    med->qual[med->cnt].disp_line = trim(o.clinical_display_line), med->qual[med->cnt].date =
    cnvtdatetime(o.orig_order_dt_tm), med->qual[med->cnt].tz = o.orig_order_tz,
    med->qual[med->cnt].doc = pl.name_full_formatted
    IF (o.need_rx_verify_ind=0)
     med->qual[med->cnt].review_comment = "Verified"
    ELSEIF (o.need_rx_verify_ind=1)
     med->qual[med->cnt].review_comment = "Unverified"
    ELSEIF (o.need_rx_verify_ind=2)
     med->qual[med->cnt].review_comment = "Rejected"
    ENDIF
   ENDIF
  FOOT REPORT
   select_printer
  WITH nocounter, outerjoin = d1, dontcare = od,
   outerjoin = d2
 ;end select
 CALL echo("checking priority")
 SELECT INTO "nl:"
  FROM order_detail od
  PLAN (od
   WHERE (od.order_id=request->ord[1].order_id)
    AND ((od.oe_field_meaning="RXPRIORITY"
    AND od.oe_field_display_value="STAT") OR (od.order_id IN (
   (SELECT
    o.order_id
    FROM orders o
    WHERE o.order_id=od.order_id
     AND o.encntr_id IN (
    (SELECT
     e.encntr_id
     FROM encounter e
     WHERE o.encntr_id=e.encntr_id
      AND  NOT (e.loc_facility_cd IN (673936.00, 679549)))))))) )
  DETAIL
   print_ind = 1
  WITH nocounter
 ;end select
 CALL echo(build("print_ind:",print_ind))
 IF ((request->text > " "))
  SET pt->line_cnt = 0
  SET max_length = 55
  EXECUTE dcp_parse_text value(request->text), value(max_length)
  SET stat = alterlist(temp->qual,pt->line_cnt)
  SET temp->cnt = pt->line_cnt
  FOR (x = 1 TO pt->line_cnt)
    SET temp->qual[x].line = pt->lns[x].line
  ENDFOR
 ELSE
  SET temp->cnt = 0
 ENDIF
 CALL echo(build("tempCnt:",temp->cnt))
 IF ((med->cnt > 0))
  CALL echo("MedCnt")
  FOR (x = 1 TO med->cnt)
   IF ((med->qual[x].disp_mnem > " "))
    SET pt->line_cnt = 0
    SET max_length = 50
    EXECUTE dcp_parse_text value(med->qual[x].disp_mnem), value(max_length)
    SET stat = alterlist(med->qual[x].m_qual,pt->line_cnt)
    SET med->qual[x].m_cnt = pt->line_cnt
    FOR (y = 1 TO pt->line_cnt)
      SET med->qual[x].m_qual[y].m_line = pt->lns[y].line
    ENDFOR
   ELSE
    SET med->qual[x].m_cnt = 0
   ENDIF
   IF ((med->qual[x].disp_line > " "))
    SET pt->line_cnt = 0
    SET max_length = 50
    EXECUTE dcp_parse_text value(med->qual[x].disp_line), value(max_length)
    SET stat = alterlist(med->qual[x].d_qual,pt->line_cnt)
    SET med->qual[x].d_cnt = pt->line_cnt
    FOR (y = 1 TO pt->line_cnt)
      SET med->qual[x].d_qual[y].d_line = pt->lns[y].line
    ENDFOR
   ELSE
    SET med->qual[x].d_cnt = 0
   ENDIF
  ENDFOR
  IF (print_ind=0)
   SET med_output_device = "holdingQ"
   SET iv_output_device = "holdingQ"
  ENDIF
  CALL echo("Send label output")
  CALL echo(med_output_device)
  CALL echo("for testing purposes change the printer to")
  SET med_output_device = "bisis1pharm1"
  SET iv_output_device = "bisis1pharm1"
  SELECT INTO value(med_output_device)
   d.seq
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   HEAD REPORT
    crb = 10
   DETAIL
    row 0, crb = (crb - 4), col crb,
    "{f/1/1}{lpi/8}{cpi/18}", "*** MEDICATION REQUEST ***", row + 1,
    col crb, "Patient: ", name,
    "{f/2/1}{lpi/6}{cpi/18}", row + 1, col crb,
    xxx = concat(trim(unit)," ; ",trim(room)," ; ",trim(bed)), "Location: ", xxx,
    "{f/2/1}{lpi/6}{cpi/18}", row + 1, col crb,
    "MRN#: ", mrn, row + 0,
    crb = (crb+ 26), col crb, "FIN#: ",
    finnbr, row + 1, crb = (crb - 26),
    col crb, xxx = substring(1,50,uar_get_code_display(request->reason_cd)), "Reason: ",
    xxx, row + 1, col crb,
    "Notes: ", col 16, lbl_cnt = 0
    FOR (x = 1 TO temp->cnt)
      temp->qual[x].line, row + 1, col 6,
      lbl_cnt = (lbl_cnt+ 1)
    ENDFOR
    FOR (x = 1 TO med->cnt)
      row + 0, col crb, "Order Status: ",
      med->qual[x].review_comment, row + 1, col crb,
      "Medication: ", col crb, lbl_cnt = 0
      FOR (y = 1 TO med->qual[x].m_cnt)
        med->qual[x].m_qual[y].m_line, row + 1, col crb,
        lbl_cnt = (lbl_cnt+ 1)
      ENDFOR
      col crb, "Details: ", col crb
      FOR (y = 1 TO med->qual[x].d_cnt)
        med->qual[x].d_qual[y].d_line, row + 1, col crb,
        lbl_cnt = 0, lbl_cnt = (lbl_cnt+ 1)
      ENDFOR
    ENDFOR
    row- (1), col crb, "Requested By: ",
    reqprov, row + 1, col crb,
    "Request Dt/Tm: ", curdate, " ",
    curtime, row + 1, col crb,
    "{f/1/1}{lpi/8}{cpi/18}", "********* END **********", BREAK
   WITH nocounter, dio = 16, maxcol = 250
  ;end select
 ENDIF
 IF ((iv->cnt > 0))
  CALL echo("ivCnt")
  FOR (x = 1 TO iv->cnt)
   IF ((iv->qual[x].disp_mnem > " "))
    SET pt->line_cnt = 0
    SET max_length = 25
    EXECUTE dcp_parse_text value(iv->qual[x].disp_mnem), value(max_length)
    SET stat = alterlist(iv->qual[x].m_qual,pt->line_cnt)
    SET iv->qual[x].m_cnt = pt->line_cnt
    FOR (y = 1 TO pt->line_cnt)
      SET iv->qual[x].m_qual[y].m_line = pt->lns[y].line
    ENDFOR
   ELSE
    SET iv->qual[x].m_cnt = 0
   ENDIF
   IF ((iv->qual[x].disp_line > " "))
    SET pt->line_cnt = 0
    SET max_length = 25
    EXECUTE dcp_parse_text value(iv->qual[x].disp_line), value(max_length)
    SET stat = alterlist(iv->qual[x].d_qual,pt->line_cnt)
    SET iv->qual[x].d_cnt = pt->line_cnt
    FOR (y = 1 TO pt->line_cnt)
      SET iv->qual[x].d_qual[y].d_line = pt->lns[y].line
    ENDFOR
   ELSE
    SET iv->qual[x].d_cnt = 0
   ENDIF
  ENDFOR
  SELECT INTO value(iv_output_device)
   d.seq
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   HEAD REPORT
    crb = 6
   DETAIL
    row 0, col crb, "{f/1/1}{lpi/8}{cpi/18}",
    "** IV MEDICATION REQUEST **", row + 1, col crb,
    "Patient: ", name, "{f/2/1}{lpi/6}{cpi/18}",
    row + 1, col crb, xxx = concat(trim(unit)," ; ",trim(room)," ; ",trim(bed)),
    "Location: ", xxx, "{f/2/1}{lpi/6}{cpi/18}",
    row + 1, col crb, "MRN#: ",
    mrn, row + 0, crb = (crb+ 26),
    col crb, "FIN#: ", finnbr,
    row + 1, col crb, xxx = substring(1,50,uar_get_code_display(request->reason_cd)),
    "Reason: ", xxx, row + 1,
    crb = 6, col crb, "Notes: ",
    col 16, lbl_cnt = 0
    FOR (x = 1 TO temp->cnt)
      temp->qual[x].line, row + 1, col 6,
      lbl_cnt = (lbl_cnt+ 1)
    ENDFOR
    FOR (x = 1 TO iv->cnt)
      row + 0, col crb, "Order Status: ",
      iv->qual[x].review_comment, row + 1, col crb,
      "IV Medication: ", col crb, lbl_cnt = 0
      FOR (y = 1 TO iv->qual[x].m_cnt)
        iv->qual[x].m_qual[y].m_line, row + 1, col crb,
        lbl_cnt = (lbl_cnt+ 1)
      ENDFOR
      col crb, "Details: ", col crb
      FOR (y = 1 TO iv->qual[x].d_cnt)
        iv->qual[x].d_qual[y].d_line, row + 1, col crb,
        lbl_cnt = 0, lbl_cnt = (lbl_cnt+ 1)
      ENDFOR
    ENDFOR
    row- (1), col crb, "Requested By: ",
    reqprov, row + 1, col crb,
    "Request Dt/Tm: ", curdate, " ",
    curtime, row + 1, col crb,
    "{f/1/1}{lpi/8}{cpi/18}", "********* END **********", BREAK
   WITH nocounter, dio = 16, maxcol = 250
  ;end select
 ENDIF
 FREE RECORD temp
 FREE RECORD iv
 FREE RECORD med
 FREE RECORD pt
END GO
