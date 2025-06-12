CREATE PROGRAM bhs_bed_mgmttestf:dba
 PROMPT
  "Defaut Prompt for any error messages:" = "MINE",
  "Beginning Date:" = "BOM",
  "End Date:" = "EOM",
  "Select Facility" = 673936,
  "Select Nursing Unit or Any(*) for All :" = 0,
  "Type in email address or leave default for report preview:" = "Report_Preview"
  WITH outdev, bdate, edate,
  fname, nunit, email
 DECLARE finnbr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")), protect
 DECLARE obs = f8 WITH constant(uar_get_code_by("DISPLAYKEY",69,"OBSERVATION")), protect
 DECLARE inpatient = f8 WITH constant(uar_get_code_by("DISPLAYKEY",69,"INPATIENT")), protect
 DECLARE dischargepatient_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"DISCHARGEPATIENT")
  ), protect
 DECLARE rec_size = i4
 DECLARE i_disp = c10
 SET beg_date_qual = cnvtdatetime( $BDATE)
 SET end_date_qual = cnvtdatetime( $EDATE)
 IF (cnvtupper( $BDATE) IN ("BEGOFPREVMONTH", "BOM"))
  SET beg_date_qual = datetimefind(cnvtdatetime((curdate - 28),0000),"M","B","B")
  SET end_date_qual = datetimefind(cnvtdatetime((curdate - 28),235959),"M","E","E")
 ELSEIF (datetimediff(end_date_qual,beg_date_qual) > 31)
  CALL echo("Date range > 31")
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
 ELSEIF (datetimediff(end_date_qual,beg_date_qual) < 0)
  CALL echo("Date range < 0")
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is incorrect", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08
  ;end select
  GO TO exit_prg
 ENDIF
 DECLARE any_loc_ind = c1 WITH constant(substring(1,1,reflect(parameter(5,0)))), public
 CALL echo(build("any_loc_ind:",any_loc_ind))
 IF (any_loc_ind="C")
  SET loc_where = build2(" ehx.loc_facility_cd + 0 = ", $FNAME)
 ELSEIF (( $5 > 0))
  SET loc_where = build2(" ehx.loc_nurse_unit_cd + 0 = ", $NUNIT)
 ELSE
  SET loc_where = build2(" ehx.loc_facility_cd + 0 = ", $FNAME)
 ENDIF
 DECLARE var_output = vc
 DECLARE email_ind = i4
 SET email_ind = 4
 IF (findstring("@", $EMAIL) > 0)
  SET email_ind = 1
  SET var_output = "bhs_bed_mgmt"
 ELSE
  SET var_output =  $OUTDEV
  SET email_ind = 0
 ENDIF
 CALL echo(build("LocWhere:",loc_where))
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 eid = c20
     2 pid = c20
     2 uname = vc
     2 pname = vc
     2 admit = vc
     2 actnum = vc
     2 dischord = vc
     2 dischpat = vc
     2 tat = c10
     2 tat_display = c10
     2 disch_dt_tm = dq8
 )
 SELECT INTO "nl:"
  e.encntr_id, tat = datetimediff(e.disch_dt_tm,o.orig_order_dt_tm,4), unit = e.loc_nurse_unit_cd,
  unitd = uar_get_code_display(e.loc_nurse_unit_cd), loc = e.location_cd, locd = uar_get_code_display
  (e.location_cd),
  hxunit = ehx.loc_nurse_unit_cd, hxunitd = uar_get_code_display(ehx.loc_nurse_unit_cd)
  FROM encounter e,
   orders o,
   encntr_loc_hist ehx
  PLAN (e
   WHERE e.disch_dt_tm BETWEEN cnvtdatetime(beg_date_qual) AND cnvtdatetime(end_date_qual)
    AND ((e.encntr_type_class_cd+ 0) IN (obs, inpatient)))
   JOIN (ehx
   WHERE ehx.encntr_id=e.encntr_id
    AND ((ehx.end_effective_dt_tm+ 0) >= e.disch_dt_tm)
    AND ((ehx.loc_nurse_unit_cd+ 0) != 0)
    AND parser(loc_where))
   JOIN (o
   WHERE o.encntr_id=e.encntr_id
    AND o.catalog_cd=dischargepatient_var)
  ORDER BY ehx.encntr_id, tat
  HEAD REPORT
   cnt = 0, stat = alterlist(temp->qual,10)
  HEAD ehx.encntr_id
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alterlist(temp->qual,(cnt+ 9))
   ENDIF
   temp->qual[cnt].eid = cnvtstring(e.encntr_id), temp->qual[cnt].pid = cnvtstring(e.person_id), temp
   ->qual[cnt].dischord = format(o.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;d"),
   temp->qual[cnt].dischpat = format(e.disch_dt_tm,"mm/dd/yyyy hh:mm;;d"), temp->qual[cnt].admit =
   format(e.reg_dt_tm,"mm/dd/yyyy hh:mm;;d"), temp->qual[cnt].tat = cnvtstring(tat),
   temp->qual[cnt].uname = uar_get_code_display(ehx.loc_nurse_unit_cd), temp->qual[cnt].disch_dt_tm
    = e.disch_dt_tm
  FOOT REPORT
   stat = alterlist(temp->qual,cnt)
  WITH nocounter, nullreport, format
 ;end select
 SET rec_size = size(temp->qual,5)
 IF (rec_size > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(rec_size)),
    person p
   PLAN (d
    WHERE d.seq > 0)
    JOIN (p
    WHERE p.person_id=cnvtint(temp->qual[d.seq].pid))
   DETAIL
    temp->qual[d.seq].pname = trim(p.name_full_formatted)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(rec_size)),
    encntr_alias ea
   PLAN (d)
    JOIN (ea
    WHERE ea.encntr_id=cnvtint(temp->qual[d.seq].eid)
     AND ea.encntr_alias_type_cd=finnbr
     AND ea.end_effective_dt_tm > sysdate
     AND ea.active_ind=1)
   DETAIL
    temp->qual[d.seq].actnum = trim(ea.alias)
   WITH nocounter
  ;end select
  SET i = 0
  SET absi = 0
  SET hr = "  "
  SET mm = "  "
  FOR (x = 1 TO rec_size)
   SET i = cnvtint(temp->qual[x].tat)
   IF (i > 59)
    SET hr = format((i/ 60),"##;rp0")
    SET mm = format(mod(i,60),"##;rp0")
    SET i_disp = build2(hr,":",mm)
    SET temp->qual[x].tat_display = trim(i_disp)
   ELSEIF (i < 0)
    SET absi = abs(i)
    SET hr = format((absi/ 60),"##;rp0")
    SET mm = format(mod(absi,60),"##;rp0")
    SET i_disp = build2("-",hr,":",mm)
    SET temp->qual[x].tat_display = trim(i_disp)
   ELSE
    SET mm = format(i,"##;rp0")
    SET i_disp = build2("00:",mm)
    SET temp->qual[x].tat_display = trim(i_disp)
   ENDIF
  ENDFOR
  IF (email_ind=0)
   SELECT INTO value(var_output)
    nurse_unit = temp->qual[d.seq].uname, patient_name = temp->qual[d.seq].pname, admit_date = temp->
    qual[d.seq].admit,
    acc_nbr = temp->qual[d.seq].actnum, disch_ord_date = temp->qual[d.seq].dischord, disch_date =
    temp->qual[d.seq].dischpat,
    tat_min = temp->qual[d.seq].tat, tat_formatted = temp->qual[d.seq].tat_display
    FROM (dummyt d  WITH seq = value(rec_size))
    PLAN (d
     WHERE d.seq > 0)
    ORDER BY nurse_unit, temp->qual[d.seq].disch_dt_tm, 0
    WITH nocounter, format, separator = " ",
     nullreport
   ;end select
  ELSE
   SELECT INTO value(var_output)
    nurse_unit = temp->qual[d.seq].uname, patient_name = temp->qual[d.seq].pname, admit_date = temp->
    qual[d.seq].admit,
    acc_nbr = temp->qual[d.seq].actnum, disch_ord_date = temp->qual[d.seq].dischord, disch_date =
    temp->qual[d.seq].dischpat,
    tat_min = temp->qual[d.seq].tat, tat_formatted = temp->qual[d.seq].tat_display
    FROM (dummyt d  WITH seq = value(rec_size))
    PLAN (d
     WHERE d.seq > 0)
    ORDER BY nurse_unit, temp->qual[d.seq].disch_dt_tm, 0
    WITH nocounter, format, pcformat('"',","),
     time = 30
   ;end select
   SET filename_in = trim(var_output)
   SET email_address = trim( $EMAIL)
   SET filename_out = "bhs_bed_mgmt.csv"
   SET subject = concat(curprog," - AP Sched2 Meds - inbox")
   EXECUTE bhs_ma_email_file
   CALL emailfile(concat(filename_in,".dat"),filename_out,email_address,subject,0)
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
