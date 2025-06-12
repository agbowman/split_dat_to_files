CREATE PROGRAM bhs_bed_mgm_pot_dsc_pat:dba
 PROMPT
  "Defaut Prompt for any error messages:" = "MINE",
  "Type in email address or leave default for report preview:" = "Report_Preview"
  WITH outdev, email
 DECLARE finnbr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")), protect
 DECLARE observation = f8 WITH constant(uar_get_code_by("DISPLAYKEY",69,"OBSERVATION")), protect
 DECLARE inpatient = f8 WITH constant(uar_get_code_by("DISPLAYKEY",69,"INPATIENT")), protect
 DECLARE ordered = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED")), protect
 DECLARE inprocess = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"INPROCESS")), protect
 DECLARE dischargepatient_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"DISCHARGE")),
 protect
 DECLARE attenddoc = f8 WITH constant(uar_get_code_by("MEANING",333,"ATTENDDOC")), protect
 DECLARE mf_nccn_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_nicu_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_nnura_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_nnurb_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_nnurc_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_nnurd_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE rec_size = i4
 DECLARE i_disp = c10
 DECLARE var_output = vc
 DECLARE email_ind = i4
 SET email_ind = 4
 IF (findstring("@", $EMAIL) > 0)
  SET email_ind = 1
  SET var_output = "bhs_bed_mgmt.csv"
 ELSE
  SET var_output =  $OUTDEV
  SET email_ind = 0
 ENDIF
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 eid = f8
     2 pid = f8
     2 uname = vc
     2 pname = vc
     2 admit = vc
     2 actnum = vc
     2 dischargelist = vc
     2 dischord = vc
     2 dischpat = vc
     2 attdphy = vc
 )
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.cdf_meaning="NURSEUNIT"
   AND cv.active_ind=1
   AND cv.data_status_cd=mf_auth_cd
   AND cv.display_key IN ("NCCN", "NICU", "NNURA", "NNURB", "NNURC",
  "NNURD")
  DETAIL
   CASE (cv.display_key)
    OF "NCCN":
     mf_nccn_cd = cv.code_value
    OF "NICU":
     mf_nicu_cd = cv.code_value
    OF "NNURA":
     mf_nnura_cd = cv.code_value
    OF "NNURB":
     mf_nnurb_cd = cv.code_value
    OF "NNURC":
     mf_nnurc_cd = cv.code_value
    OF "NNURD":
     mf_nnurd_cd = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 CALL echo("Find all active patients with discharge orders")
 SELECT INTO "nl:"
  FROM encntr_domain ed,
   orders o,
   encounter e
  PLAN (ed
   WHERE ed.active_ind=1
    AND cnvtdatetime(curdate,curtime3) BETWEEN ed.beg_effective_dt_tm AND ed.end_effective_dt_tm
    AND ed.active_status_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ed.loc_facility_cd IN (673936, 679549)
    AND  NOT (ed.loc_nurse_unit_cd IN (mf_nccn_cd, mf_nicu_cd, mf_nnura_cd, mf_nnurb_cd, mf_nnurc_cd,
   mf_nnurd_cd)))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND ((e.encntr_type_class_cd+ 0) IN (observation, inpatient)))
   JOIN (o
   WHERE o.encntr_id=ed.encntr_id
    AND ((o.catalog_cd+ 0)=dischargepatient_var)
    AND ((o.order_status_cd+ 0) IN (ordered, inprocess)))
  HEAD REPORT
   cnt = 0, stat = alterlist(temp->qual,10)
  HEAD e.encntr_id
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alterlist(temp->qual,(cnt+ 9))
   ENDIF
   temp->qual[cnt].eid = e.encntr_id, temp->qual[cnt].pid = e.person_id, temp->qual[cnt].dischord =
   format(o.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;d"),
   temp->qual[cnt].dischpat = format(e.disch_dt_tm,"mm/dd/yyyy hh:mm;;d"), temp->qual[cnt].admit =
   format(e.reg_dt_tm,"mm/dd/yyyy hh:mm;;d"), temp->qual[cnt].uname = uar_get_code_display(ed
    .loc_nurse_unit_cd)
  FOOT REPORT
   stat = alterlist(temp->qual,cnt)
  WITH counter, nullreport, format
 ;end select
 CALL echo("find all patients that exist on potential discharge list")
 SELECT
  dpce.encntr_id
  FROM prsnl p,
   dcp_patient_list dpl,
   dcp_pl_custom_entry dpce,
   encntr_domain ed,
   encounter e
  PLAN (p
   WHERE p.person_id=936628)
   JOIN (dpl
   WHERE dpl.owner_prsnl_id=p.person_id
    AND dpl.name="Potential D/C list DO NOT DELETE!")
   JOIN (dpce
   WHERE dpce.patient_list_id=dpl.patient_list_id)
   JOIN (ed
   WHERE ed.encntr_id=dpce.encntr_id
    AND ed.active_ind=1
    AND cnvtdatetime(curdate,curtime3) BETWEEN ed.beg_effective_dt_tm AND ed.end_effective_dt_tm
    AND  NOT (ed.loc_nurse_unit_cd IN (mf_nccn_cd, mf_nicu_cd, mf_nnura_cd, mf_nnurb_cd, mf_nnurc_cd,
   mf_nnurd_cd)))
   JOIN (e
   WHERE e.encntr_id=dpce.encntr_id)
  ORDER BY dpce.encntr_id
  HEAD dpce.encntr_id
   pos = 0, locnum = 0, pos = locateval(locnum,1,size(temp->qual,5),dpce.encntr_id,temp->qual[locnum]
    .eid)
   IF (pos > 0)
    temp->qual[pos].dischargelist = "YES"
   ELSE
    tempcnt = (size(temp->qual,5)+ 1), stat = alterlist(temp->qual,tempcnt), temp->qual[tempcnt].eid
     = dpce.encntr_id,
    temp->qual[tempcnt].pid = dpce.person_id, temp->qual[tempcnt].admit = format(e.reg_dt_tm,
     "mm/dd/yyyy hh:mm;;d"), temp->qual[tempcnt].uname = uar_get_code_display(ed.loc_nurse_unit_cd),
    temp->qual[tempcnt].dischargelist = "YES"
   ENDIF
  WITH nocounter
 ;end select
 SET rec_size = size(temp->qual,5)
 IF (rec_size > 0)
  CALL echo("Get Patient Demog")
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(rec_size)),
    person p
   PLAN (d
    WHERE d.seq > 0)
    JOIN (p
    WHERE (p.person_id=temp->qual[d.seq].pid))
   DETAIL
    temp->qual[d.seq].pname = trim(p.name_full_formatted)
   WITH nocounter
  ;end select
  CALL echo("Get Patient Acc#")
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(rec_size)),
    encntr_alias ea
   PLAN (d)
    JOIN (ea
    WHERE (ea.encntr_id=temp->qual[d.seq].eid)
     AND ea.encntr_alias_type_cd=finnbr
     AND ea.end_effective_dt_tm > sysdate
     AND ea.active_ind=1)
   DETAIL
    temp->qual[d.seq].actnum = trim(ea.alias)
   WITH nocounter
  ;end select
  CALL echo("Get Attd phy")
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(rec_size)),
    encntr_prsnl_reltn epr,
    prsnl pr
   PLAN (d)
    JOIN (epr
    WHERE (epr.encntr_id=temp->qual[d.seq].eid)
     AND epr.active_ind=1
     AND cnvtdatetime(curdate,curtime3) BETWEEN epr.beg_effective_dt_tm AND epr.end_effective_dt_tm
     AND epr.encntr_prsnl_r_cd=attenddoc)
    JOIN (pr
    WHERE pr.person_id=epr.prsnl_person_id
     AND pr.active_ind=1)
   DETAIL
    temp->qual[d.seq].attdphy = trim(pr.name_full_formatted,3)
   WITH nocounter
  ;end select
  CALL echo("Output")
  SET i = 0
  SET absi = 0
  SET hr = "  "
  SET mm = "  "
  IF (email_ind=0)
   SELECT INTO value(var_output)
    nurse_unit = substring(1,20,temp->qual[d.seq].uname), patient_name = substring(1,35,temp->qual[d
     .seq].pname), admit_date = temp->qual[d.seq].admit,
    acc_nbr = substring(1,12,temp->qual[d.seq].actnum), attendingphy = substring(1,35,temp->qual[d
     .seq].attdphy), dischargelist = substring(1,3,temp->qual[d.seq].dischargelist),
    disch_ord_date = temp->qual[d.seq].dischord
    FROM (dummyt d  WITH seq = value(rec_size))
    PLAN (d
     WHERE d.seq > 0)
    ORDER BY nurse_unit
    WITH nocounter, format, separator = " ",
     nullreport
   ;end select
  ELSE
   SELECT INTO value(var_output)
    nurse_unit = substring(1,20,temp->qual[d.seq].uname), patient_name = substring(1,35,temp->qual[d
     .seq].pname), admit_date = temp->qual[d.seq].admit,
    acc_nbr = substring(1,12,temp->qual[d.seq].actnum), attendingphy = substring(1,35,temp->qual[d
     .seq].attdphy), dischargelist = substring(1,3,temp->qual[d.seq].dischargelist),
    disch_ord_date = temp->qual[d.seq].dischord
    FROM (dummyt d  WITH seq = value(rec_size))
    PLAN (d
     WHERE d.seq > 0)
    ORDER BY nurse_unit, 0
    WITH nocounter, format, pcformat('"',","),
     time = 30
   ;end select
   SET filename_in = trim(var_output)
   SET email_address = trim( $EMAIL)
   SET filename_out = "bhs_bed_mgmt.csv"
   SET subject = concat(curprog," - inbox")
   EXECUTE bhs_ma_email_file
   CALL emailfile(concat(filename_in),filename_out,email_address,subject,0)
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = concat(trim("bhs_bed_mgmt_"),format(curdate,"MMDDYYYY;;D"),".csv will be sent to -"),
     msg2 = concat("   ", $EMAIL), col 0,
     "{PS/792 0 translate 90 rotate/}", y_pos = 1, row + 1,
     "{F/1}{CPI/9}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1,
     row + 2, msg2
    WITH dio = 08, mine, time = 5
   ;end select
  ENDIF
 ENDIF
#exit_prg
END GO
