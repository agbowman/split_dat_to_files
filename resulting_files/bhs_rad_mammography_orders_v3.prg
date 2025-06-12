CREATE PROGRAM bhs_rad_mammography_orders_v3
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility" = "",
  "Signed From Date" = "CURDATE",
  "Signed To Date (no more than 1 week)" = "CURDATE",
  "Email ID" = ""
  WITH outdev, facility, fromdate,
  todate, email
 FREE RECORD rec_str
 RECORD rec_str(
   1 patients[*]
     2 f_encntr_id = f8
     2 s_patient_name = vc
     2 s_mrn = vc
     2 s_fin = vc
     2 orders[*]
       3 f_order_id = f8
       3 s_order_date = vc
       3 s_order_desc = vc
       3 s_signed_date = vc
       3 s_signed_by = vc
       3 s_ordering_phy = vc
       3 s_accession = vc
       3 consltdocs[*]
         4 s_phys_name = vc
 ) WITH protect
 DECLARE mf_mrn_cd = f8 WITH constant(validatecodevalue("DISPLAYKEY",319,"MRN")), protect
 DECLARE mf_fin_cd = f8 WITH constant(validatecodevalue("DISPLAYKEY",319,"FINNBR")), protect
 DECLARE mf_verify_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",21,"VERIFY"))
 DECLARE mf_completed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",103,"COMPLETED"))
 DECLARE mf_mammography_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",5801,
   "MAMMOGRAPHY"))
 DECLARE mf_final_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14202,"FINAL"))
 DECLARE user_name = vc
 DECLARE facility_name = vc
 DECLARE facility_cd = f8
 IF (validate(request->batch_selection))
  SET tmp = findstring(":", $3,1,0)
  SET daystr = substring(1,(tmp - 1), $3)
  SET timestr = cnvtint(substring((tmp+ 1),4, $3))
  SET strdate = format(cnvtdatetime((curdate+ cnvtint(daystr)),timestr),";;Q")
  SET strdatedisplay = format(cnvtdatetime(strdate),"mm/dd/yyyy;;d")
  SET tmp = findstring(":", $4,1,0)
  SET daystr = substring(1,(tmp - 1), $4)
  SET timestr = cnvtint(substring((tmp+ 1),4, $4))
  SET enddate = format(cnvtdatetime((curdate+ cnvtint(daystr)),timestr),";;Q")
  SET enddatedisplay = format(cnvtdatetime(enddate),"mm/dd/yyyy;;d")
 ELSE
  SET strdate = format(cnvtdatetime(cnvtdate2( $3,"DD-MMM-YYYY"),0000),";;Q")
  SET enddate = format(cnvtdatetime(cnvtdate2( $4,"DD-MMM-YYYY"),2359),";;Q")
  SET strdatedisplay = format(cnvtdatetime(cnvtdate2( $3,"DD-MMM-YYYY"),0000),"mm/dd/yyyy;;d")
  SET enddatedisplay = format(cnvtdatetime(cnvtdate2( $4,"DD-MMM-YYYY"),0000),"mm/dd/yyyy;;d")
  IF (datetimediff(cnvtdatetime(enddate),cnvtdatetime(strdate)) > 7)
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = "Your date range is larger than 7 days.", msg2 = "  Please retry.", col 0,
     "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
     "{F/1}{CPI/7}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1,
     row + 2, msg2
    WITH dio = 08, mine, time = 5
   ;end select
   GO TO exit_program
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id=reqinfo->updt_id))
  HEAD REPORT
   user_name = p.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  c.code_value, c.display
  FROM code_value c
  WHERE c.code_set=220
   AND cnvtupper(c.cdf_meaning)="FACILITY"
   AND c.display_key=trim( $2)
   AND c.active_ind=1
   AND c.description != "BMC"
  DETAIL
   facility_cd = c.code_value, facility_name = trim( $2)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_radiology ord,
   orders o,
   order_catalog oc,
   clinical_event ce,
   ce_event_prsnl cep,
   encounter e,
   person p,
   prsnl pr1,
   prsnl pr2,
   prsnl pr3
  PLAN (pr1)
   JOIN (cep
   WHERE cep.action_prsnl_id=pr1.person_id
    AND cep.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
    AND cep.action_dt_tm BETWEEN cnvtdatetime(strdate) AND cnvtdatetime(enddate)
    AND ((cep.action_type_cd+ 0)=mf_verify_cd)
    AND ((cep.action_status_cd+ 0)=mf_completed_cd))
   JOIN (pr3
   WHERE cep.action_prsnl_id=pr3.person_id)
   JOIN (ce
   WHERE cep.event_id=ce.event_id
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ce.view_level=1)
   JOIN (ord
   WHERE ce.order_id=ord.order_id
    AND ((ord.report_status_cd+ 0)=mf_final_cd))
   JOIN (o
   WHERE o.order_id=ord.order_id)
   JOIN (oc
   WHERE o.catalog_cd=oc.catalog_cd
    AND ((oc.activity_subtype_cd+ 0)=mf_mammography_cd))
   JOIN (pr2
   WHERE pr2.person_id=ord.order_physician_id)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND ((e.loc_facility_cd+ 0)=cnvtreal(facility_cd)))
   JOIN (p
   WHERE p.person_id=e.person_id)
  ORDER BY p.name_full_formatted, o.orig_order_dt_tm
  HEAD REPORT
   pcnt = 0, ocnt = 0
  HEAD p.name_full_formatted
   ocnt = 0, pcnt = (pcnt+ 1)
   IF (pcnt > size(rec_str->patients,5))
    stat = alterlist(rec_str->patients,(pcnt+ 10))
   ENDIF
   rec_str->patients[pcnt].f_encntr_id = e.encntr_id, rec_str->patients[pcnt].s_patient_name = p
   .name_full_formatted
  HEAD ord.order_id
   ocnt = (ocnt+ 1)
   IF (ocnt > size(rec_str->patients[pcnt].orders,5))
    stat = alterlist(rec_str->patients[pcnt].orders,(ocnt+ 10))
   ENDIF
   rec_str->patients[pcnt].orders[ocnt].f_order_id = o.order_id, rec_str->patients[pcnt].orders[ocnt]
   .s_order_date = format(o.orig_order_dt_tm,"mm/dd/yyyy;;d"), rec_str->patients[pcnt].orders[ocnt].
   s_order_desc = o.order_mnemonic,
   rec_str->patients[pcnt].orders[ocnt].s_signed_date = format(cep.action_dt_tm,"mm/dd/yyyy;;d"),
   rec_str->patients[pcnt].orders[ocnt].s_ordering_phy = substring(1,25,pr2.name_full_formatted),
   rec_str->patients[pcnt].orders[ocnt].s_signed_by = pr3.name_full_formatted,
   rec_str->patients[pcnt].orders[ocnt].s_accession = ord.accession
  FOOT  p.name_full_formatted
   stat = alterlist(rec_str->patients[pcnt].orders,ocnt)
  FOOT REPORT
   stat = alterlist(rec_str->patients,pcnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(rec_str->patients,5)),
   encntr_alias ea
  PLAN (d)
   JOIN (ea
   WHERE (ea.encntr_id=rec_str->patients[d.seq].f_encntr_id)
    AND ea.encntr_alias_type_cd=mf_mrn_cd)
  DETAIL
   rec_str->patients[d.seq].s_mrn = ea.alias
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(rec_str->patients,5)),
   encntr_alias ea
  PLAN (d)
   JOIN (ea
   WHERE (ea.encntr_id=rec_str->patients[d.seq].f_encntr_id)
    AND ea.encntr_alias_type_cd=mf_fin_cd)
  DETAIL
   rec_str->patients[d.seq].s_fin = ea.alias
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(rec_str->patients,5))),
   dummyt d1,
   order_detail od
  PLAN (d
   WHERE maxrec(d1,size(rec_str->patients[d.seq].orders,5)))
   JOIN (d1)
   JOIN (od
   WHERE (od.order_id=rec_str->patients[d.seq].orders[d1.seq].f_order_id)
    AND od.oe_field_meaning="CONSULTDOC")
  ORDER BY od.order_id
  HEAD od.order_id
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(rec_str->patients[d.seq].orders[d1.seq].consltdocs,cnt), rec_str
   ->patients[d.seq].orders[d1.seq].consltdocs[cnt].s_phys_name = od.oe_field_display_value
  WITH nocounter
 ;end select
 IF (validate(request->batch_selection))
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = value(size(rec_str->patients,5))),
    dummyt d1
   PLAN (d
    WHERE maxrec(d1,size(rec_str->patients[d.seq].orders,5)))
    JOIN (d1)
   HEAD REPORT
    cnt = 0, nunit = 0.00, pat_cnt = 0,
    i = 0, s_line = fillstring(200,"-"), flag = 0
   HEAD PAGE
    y_pos = 20, "{F/4}{CPI/18}",
    CALL print(calcpos(20,18)),
    "Printed Date/Time: ", curdate, " ",
    curtime, row + 1,
    CALL print(calcpos(20,27)),
    "Printed in OPS by: ", user_name, row + 1,
    CALL print(calcpos(20,36)), "Program: ", curprog,
    row + 1, "{F/5}{CPI/13}", y_pos = 18,
    CALL print(calcpos(240,(y_pos+ 9))), "{b}Summary of Mammography Procedures Final ", y_pos = (
    y_pos+ 10),
    row + 1,
    CALL print(calcpos(220,(y_pos+ 9))), "Date Range :",
    strdatedisplay, " to ", enddatedisplay,
    " for Facility ", facility_name, row + 1,
    "{F/5}{CPI/13}", y_pos = (y_pos+ 15), row + 1,
    y_val = ((792 - y_pos) - 42), "{PS/newpath 2 setlinewidth   18 ", y_val,
    " moveto  590 ", y_val, " lineto stroke 18 ",
    y_val, " moveto/}", y_pos = (y_pos+ 40),
    row + 1, "{F/4}{CPI/14}",
    CALL print(calcpos(20,y_pos)),
    "{B}", "Patient Name",
    CALL print(calcpos(130,y_pos)),
    "{B}", "MRN#",
    CALL print(calcpos(170,y_pos)),
    "{B}", "FIN#",
    CALL print(calcpos(220,y_pos)),
    "{B}", "Order Date",
    CALL print(calcpos(280,y_pos)),
    "{B}", "Description",
    CALL print(calcpos(480,y_pos)),
    "{B}", "Signed Date", y_pos = (y_pos+ 10),
    row + 1,
    CALL print(calcpos(20,y_pos)), s_line,
    row + 1
   DETAIL
    "{CPI/15}"
    IF (y_pos >= 650)
     BREAK
    ENDIF
    y_pos = (y_pos+ 15), "{F/4}{CPI/14}",
    CALL print(calcpos(20,y_pos)),
    rec_str->patients[d.seq].s_patient_name,
    CALL print(calcpos(130,y_pos)), rec_str->patients[d.seq].s_mrn,
    CALL print(calcpos(170,y_pos)), rec_str->patients[d.seq].s_fin,
    CALL print(calcpos(220,y_pos)),
    rec_str->patients[d.seq].orders[d1.seq].s_order_date,
    CALL print(calcpos(280,y_pos)), rec_str->patients[d.seq].orders[d1.seq].s_order_desc,
    CALL print(calcpos(480,y_pos)), rec_str->patients[d.seq].orders[d1.seq].s_signed_date, y_pos = (
    y_pos+ 10),
    row + 1, doc_size = size(rec_str->patients[d.seq].orders[d1.seq].consltdocs,5),
    CALL print(calcpos(20,y_pos)),
    "{B}", "Ordering Physician : {endb}", rec_str->patients[d.seq].orders[d1.seq].s_ordering_phy,
    CALL print(calcpos(20,(y_pos+ 10))), "{B}", "Accession Number : {endb}",
    rec_str->patients[d.seq].orders[d1.seq].s_accession,
    CALL print(calcpos(280,y_pos)), "{B}",
    "Consulting Doctors:",
    CALL print(calcpos(480,y_pos)), "{B}",
    "Signed by:", y_pos = (y_pos+ 10), row + 1,
    CALL print(calcpos(480,y_pos)), rec_str->patients[d.seq].orders[d1.seq].s_signed_by, y_pos = (
    y_pos - 10)
    FOR (i = 1 TO doc_size)
      y_pos = (y_pos+ 10), row + 1,
      CALL print(calcpos(280,y_pos)),
      rec_str->patients[d.seq].orders[d1.seq].consltdocs[i].s_phys_name
    ENDFOR
    IF (y_pos >= 650)
     BREAK
    ENDIF
    y_pos = (y_pos+ 10)
   FOOT PAGE
    y_pos = 740, row + 1, y_val = ((792 - y_pos) - 10),
    "{PS/newpath 2 setlinewidth   18 ", y_val, " moveto  590 ",
    y_val, " lineto stroke 18 ", y_val,
    " moveto/}", "{F/4}{CPI/16}", "{F/4}{CPI/18}",
    CALL print(calcpos(490,(y_pos+ 10))), "Page:", curpage,
    row + 1, row + 1
   WITH nullreport, maxcol = 3000, maxrow = 500,
    dio = 08, noheading, format = variable
  ;end select
 ELSE
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = value(size(rec_str->patients,5))),
    dummyt d1
   PLAN (d
    WHERE maxrec(d1,size(rec_str->patients[d.seq].orders,5)))
    JOIN (d1)
   HEAD REPORT
    cnt = 0, nunit = 0.00, pat_cnt = 0,
    i = 0, s_line = fillstring(200,"-"), flag = 0
   HEAD PAGE
    y_pos = 20, "{F/4}{CPI/18}",
    CALL print(calcpos(20,18)),
    "Printed Date/Time: ", curdate, " ",
    curtime, row + 1,
    CALL print(calcpos(20,27)),
    "Printed by: ", user_name, row + 1,
    CALL print(calcpos(20,36)), "Program: ", curprog,
    row + 1, "{F/5}{CPI/13}", y_pos = 18,
    CALL print(calcpos(240,(y_pos+ 9))), "{b}Summary of Mammography Procedures Final ", y_pos = (
    y_pos+ 10),
    row + 1,
    CALL print(calcpos(220,(y_pos+ 9))), "Date Range :",
    strdatedisplay, " to ", enddatedisplay,
    " for Facility ", facility_name, row + 1,
    "{F/5}{CPI/13}", y_pos = (y_pos+ 15), row + 1,
    y_val = ((792 - y_pos) - 42), "{PS/newpath 2 setlinewidth   18 ", y_val,
    " moveto  590 ", y_val, " lineto stroke 18 ",
    y_val, " moveto/}", y_pos = (y_pos+ 40),
    row + 1, "{F/4}{CPI/14}",
    CALL print(calcpos(20,y_pos)),
    "{B}", "Patient Name",
    CALL print(calcpos(130,y_pos)),
    "{B}", "MRN#",
    CALL print(calcpos(170,y_pos)),
    "{B}", "FIN#",
    CALL print(calcpos(220,y_pos)),
    "{B}", "Order Date",
    CALL print(calcpos(280,y_pos)),
    "{B}", "Description",
    CALL print(calcpos(480,y_pos)),
    "{B}", "Signed Date", y_pos = (y_pos+ 10),
    row + 1,
    CALL print(calcpos(20,y_pos)), s_line,
    row + 1
   DETAIL
    "{CPI/15}"
    IF (y_pos >= 650)
     BREAK
    ENDIF
    y_pos = (y_pos+ 15), "{F/4}{CPI/14}",
    CALL print(calcpos(20,y_pos)),
    rec_str->patients[d.seq].s_patient_name,
    CALL print(calcpos(130,y_pos)), rec_str->patients[d.seq].s_mrn,
    CALL print(calcpos(170,y_pos)), rec_str->patients[d.seq].s_fin,
    CALL print(calcpos(220,y_pos)),
    rec_str->patients[d.seq].orders[d1.seq].s_order_date,
    CALL print(calcpos(280,y_pos)), rec_str->patients[d.seq].orders[d1.seq].s_order_desc,
    CALL print(calcpos(480,y_pos)), rec_str->patients[d.seq].orders[d1.seq].s_signed_date, y_pos = (
    y_pos+ 10),
    row + 1, doc_size = size(rec_str->patients[d.seq].orders[d1.seq].consltdocs,5),
    CALL print(calcpos(20,y_pos)),
    "{B}", "Ordering Physician : {endb}", rec_str->patients[d.seq].orders[d1.seq].s_ordering_phy,
    CALL print(calcpos(20,(y_pos+ 10))), "{B}", "Accession Number : {endb}",
    rec_str->patients[d.seq].orders[d1.seq].s_accession,
    CALL print(calcpos(280,y_pos)), "{B}",
    "Consulting Doctors:",
    CALL print(calcpos(480,y_pos)), "{B}",
    "Signed by:", y_pos = (y_pos+ 10), row + 1,
    CALL print(calcpos(480,y_pos)), rec_str->patients[d.seq].orders[d1.seq].s_signed_by, y_pos = (
    y_pos - 10)
    FOR (i = 1 TO doc_size)
      y_pos = (y_pos+ 10), row + 1,
      CALL print(calcpos(280,y_pos)),
      rec_str->patients[d.seq].orders[d1.seq].consltdocs[i].s_phys_name
    ENDFOR
    IF (y_pos >= 650)
     BREAK
    ENDIF
    y_pos = (y_pos+ 10)
   FOOT PAGE
    y_pos = 740, row + 1, y_val = ((792 - y_pos) - 10),
    "{PS/newpath 2 setlinewidth   18 ", y_val, " moveto  590 ",
    y_val, " lineto stroke 18 ", y_val,
    " moveto/}", "{F/4}{CPI/16}", "{F/4}{CPI/18}",
    CALL print(calcpos(490,(y_pos+ 10))), "Page:", curpage,
    row + 1, row + 1
   WITH nullreport, maxcol = 3000, maxrow = 500,
    dio = 08, noheading, format = variable
  ;end select
 ENDIF
 SUBROUTINE validatecodevalue(type,codeset,val)
   SET codeval = 0.0
   SET codeval = uar_get_code_by(value(type),codeset,value(val))
   IF (codeval <= 0)
    SET errmsg = concat("failed finding code_val - type: ",type," codeset:",build(codeset)," val:",
     val)
    CALL echo(errmsg)
    GO TO exit_program
   ELSE
    CALL echo(concat("type: ",type," codeset:",build(codeset)," val:",
      val," Code_value=",cnvtstring(codeval)))
   ENDIF
   RETURN(codeval)
 END ;Subroutine
#exit_program
END GO
