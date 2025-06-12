CREATE PROGRAM bhs_rad_mammography_orders_v2
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility" = "",
  "From Signed Date" = "CURDATE",
  "To Signed Date" = "CURDATE"
  WITH outdev, facility, fromdate,
  todate
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
       3 s_ordering_phy = vc
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
   AND c.code_value=cnvtreal( $FACILITY)
   AND c.active_ind=1
  DETAIL
   facility_name = c.display
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_radiology ord,
   orders o,
   order_catalog oc,
   prsnl pr,
   encounter e,
   person p
  PLAN (ord
   WHERE ord.report_status_cd=mf_final_cd
    AND ord.complete_dt_tm BETWEEN cnvtdatetime(cnvtdate2( $FROMDATE,"DD-MMM-YYYY"),0000) AND
   cnvtdatetime(cnvtdate2( $TODATE,"DD-MMM-YYYY"),2359))
   JOIN (o
   WHERE o.order_id=ord.order_id
    AND o.active_ind=1)
   JOIN (oc
   WHERE o.catalog_cd=oc.catalog_cd
    AND oc.activity_subtype_cd=mf_mammography_cd)
   JOIN (pr
   WHERE pr.person_id=ord.order_physician_id)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.loc_facility_cd=cnvtreal( $FACILITY))
   JOIN (p
   WHERE p.person_id=e.person_id)
  ORDER BY e.encntr_id, ord.order_id
  HEAD REPORT
   pcnt = 0, ocnt = 0
  HEAD e.encntr_id
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
   rec_str->patients[pcnt].orders[ocnt].s_signed_date = format(ord.complete_dt_tm,"mm/dd/yyyy;;d"),
   rec_str->patients[pcnt].orders[ocnt].s_ordering_phy = pr.name_full_formatted
  FOOT  e.encntr_id
   stat = alterlist(rec_str->patients[pcnt].orders,ocnt)
  FOOT REPORT
   stat = alterlist(rec_str->patients,pcnt)
  WITH nocounter
 ;end select
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
   CALL print(calcpos(240,(y_pos+ 9))), "{b}Summary of Mammography Procedures Final ", y_pos = (y_pos
   + 10),
   row + 1,
   CALL print(calcpos(220,(y_pos+ 9))), "Date Range :",
    $FROMDATE, " to ",  $TODATE,
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
   CALL print(calcpos(300,y_pos)),
   "{B}", "Description",
   CALL print(calcpos(520,y_pos)),
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
   CALL print(calcpos(300,y_pos)), rec_str->patients[d.seq].orders[d1.seq].s_order_desc,
   CALL print(calcpos(520,y_pos)), rec_str->patients[d.seq].orders[d1.seq].s_signed_date, y_pos = (
   y_pos+ 10),
   row + 1, doc_size = size(rec_str->patients[d.seq].orders[d1.seq].consltdocs,5),
   CALL print(calcpos(20,y_pos)),
   "{B}", "Ordering Physician : {endb}", rec_str->patients[d.seq].orders[d1.seq].s_ordering_phy,
   CALL print(calcpos(300,y_pos)), "{B}", "Consulting Doctors"
   FOR (i = 1 TO doc_size)
     y_pos = (y_pos+ 10), row + 1,
     CALL print(calcpos(300,y_pos)),
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
END GO
