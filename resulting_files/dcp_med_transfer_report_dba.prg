CREATE PROGRAM dcp_med_transfer_report:dba
 RECORD query_data(
   1 person_list[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 prn_order_list[*]
       3 order_mnemonic = vc
       3 clinical_display_line = vc
       3 remaining_dose_cnt = i4
     2 response_task_list[*]
       3 order_mnemonic = vc
       3 task_desc = vc
       3 task_dt_tm = dq8
 )
 RECORD report_data(
   1 person_list[*]
     2 name_full_formatted = vc
     2 prn_order_list[*]
       3 seq_string = vc
       3 order_information_cnt = i4
       3 order_information[*]
         4 order_info_line = c80
       3 remaining_doses = vc
     2 response_task_list[*]
       3 seq_string = vc
       3 task_information_cnt = i4
       3 task_information[*]
         4 task_info_line = c80
       3 task_dt_tm = vc
 )
 DECLARE pendingtaskstatus = f8 WITH protected, constant(uar_get_code_by("MEANING",79,"PENDING"))
 DECLARE overduetaskstatus = f8 WITH protected, constant(uar_get_code_by("MEANING",79,"OVERDUE"))
 DECLARE pharmacycatalogtype = f8 WITH protected, constant(uar_get_code_by("MEANING",6000,"PHARMACY")
  )
 DECLARE orderedorderstatus = f8 WITH protected, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE responsetasktype = f8 WITH protected, constant(uar_get_code_by("MEANING",6026,"RESPONSE"))
 IF (((pendingtaskstatus <= 0.0) OR (((overduetaskstatus <= 0.0) OR (((pharmacycatalogtype <= 0.0)
  OR (((orderedorderstatus <= 0.0) OR (responsetasktype <= 0.0)) )) )) )) )
  GO TO exit_script
 ENDIF
 DECLARE encntrcnt = i4 WITH constant(value(size(request->encntr_list,5)))
 DECLARE tofacilitycd = f8 WITH noconstant(0.0)
 DECLARE tonurseunitcd = f8 WITH noconstant(0.0)
 DECLARE orderinfo = vc WITH noconstant("")
 DECLARE fromnurseunitcd = f8 WITH noconstant(0.0)
 IF ((request->from_nurse_unit_cd > 0.0))
  SET fromnurseunitcd = request->from_nurse_unit_cd
 ENDIF
 SELECT INTO "nl:"
  prnorderind = decode(o1.seq,1.0,0.0), responsetaskind = decode(o2.seq,1.0,0.0), orderid = decode(o1
   .seq,o1.order_id,o2.seq,o2.order_id,0.0),
  ordermnemonic = decode(o1.seq,o1.order_mnemonic,o2.seq,o2.order_mnemonic,""), clinicaldisplayline
   = decode(o1.seq,o1.clinical_display_line,o2.seq,o2.clinical_display_line,""), remainingdoses =
  decode(o1.seq,o1.remaining_dose_cnt,o2.seq,o2.remaining_dose_cnt,0)
  FROM (dummyt d  WITH seq = value(encntrcnt)),
   encounter e,
   person p,
   dummyt d1,
   dummyt d2,
   orders o1,
   orders o2,
   task_activity ta,
   order_task ot
  PLAN (d)
   JOIN (e
   WHERE (e.encntr_id=request->encntr_list[d.seq].encntr_id))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (((d1)
   JOIN (o1
   WHERE o1.encntr_id=e.encntr_id
    AND o1.catalog_type_cd=pharmacycatalogtype
    AND ((o1.prn_ind+ 0)=1)
    AND ((o1.order_status_cd+ 0)=orderedorderstatus)
    AND o1.remaining_dose_cnt > 0)
   ) ORJOIN ((d2)
   JOIN (ta
   WHERE ta.encntr_id=e.encntr_id
    AND ta.task_type_cd=responsetasktype
    AND ta.task_status_cd IN (pendingtaskstatus, overduetaskstatus))
   JOIN (o2
   WHERE o2.order_id=ta.order_id
    AND o2.catalog_type_cd=pharmacycatalogtype)
   JOIN (ot
   WHERE ot.reference_task_id=ta.reference_task_id)
   ))
  ORDER BY p.person_id, orderid
  HEAD REPORT
   personcnt = 0
  HEAD p.person_id
   personcnt = (personcnt+ 1)
   IF (personcnt > size(query_data->person_list,5))
    stat = alterlist(query_data->person_list,(personcnt+ 10))
   ENDIF
   tonurseunitcd = e.loc_nurse_unit_cd, tofacilitycd = e.loc_facility_cd
   IF ((request->from_nurse_unit_cd <= 0.0))
    fromnurseunitcd = tonurseunitcd
   ENDIF
   query_data->person_list[personcnt].name_full_formatted = p.name_full_formatted, prnordercnt = 0,
   responsetaskcnt = 0
  HEAD orderid
   IF (prnorderind=1)
    prnordercnt = (prnordercnt+ 1)
    IF (prnordercnt > size(query_data->person_list[personcnt].prn_order_list,5))
     stat = alterlist(query_data->person_list[personcnt].prn_order_list,(prnordercnt+ 10))
    ENDIF
    query_data->person_list[personcnt].prn_order_list[prnordercnt].order_mnemonic = ordermnemonic,
    query_data->person_list[personcnt].prn_order_list[prnordercnt].clinical_display_line =
    clinicaldisplayline, query_data->person_list[personcnt].prn_order_list[prnordercnt].
    remaining_dose_cnt = remainingdoses
   ENDIF
  DETAIL
   IF (responsetaskind=1)
    responsetaskcnt = (responsetaskcnt+ 1)
    IF (responsetaskcnt > size(query_data->person_list[personcnt].response_task_list,5))
     stat = alterlist(query_data->person_list[personcnt].response_task_list,(responsetaskcnt+ 10))
    ENDIF
    query_data->person_list[personcnt].response_task_list[responsetaskcnt].order_mnemonic =
    ordermnemonic, query_data->person_list[personcnt].response_task_list[responsetaskcnt].task_desc
     = ot.task_description, query_data->person_list[personcnt].response_task_list[responsetaskcnt].
    task_dt_tm = ta.task_dt_tm
   ENDIF
  FOOT  orderid
   stat = alterlist(query_data->person_list[personcnt].response_task_list,responsetaskcnt)
  FOOT  p.person_id
   stat = alterlist(query_data->person_list[personcnt].prn_order_list,prnordercnt)
  FOOT REPORT
   stat = alterlist(query_data->person_list,personcnt)
  WITH check, nocounter
 ;end select
 CALL echorecord(query_data)
 SET stat = alterlist(report_data->person_list,size(query_data->person_list,5))
 FOR (peoplecnt = 1 TO size(query_data->person_list,5))
   SET report_data->person_list[peoplecnt].name_full_formatted = query_data->person_list[peoplecnt].
   name_full_formatted
   SET numprnorders = size(query_data->person_list[peoplecnt].prn_order_list,5)
   SET numresponsetasks = size(query_data->person_list[peoplecnt].response_task_list,5)
   CALL echo(numprnorders)
   CALL echo(numresponsetasks)
   SET stat = alterlist(report_data->person_list[peoplecnt].prn_order_list,numprnorders)
   FOR (prnordercnt = 1 TO numprnorders)
     SET report_data->person_list[peoplecnt].prn_order_list[prnordercnt].seq_string = cnvtstring(
      prnordercnt)
     SET orderinfo = concat(trim(query_data->person_list[peoplecnt].prn_order_list[prnordercnt].
       order_mnemonic)," - ",trim(query_data->person_list[peoplecnt].prn_order_list[prnordercnt].
       clinical_display_line))
     SET stat = alterlist(report_data->person_list[peoplecnt].prn_order_list[prnordercnt].
      order_information,10)
     SET startpos = 1
     SET orderlines = 0
     SET orderinfosize = size(orderinfo)
     FOR (ol = 1 TO 10)
       SET orderinfosub = trim(substring(startpos,80,orderinfo))
       IF (orderinfosize > 80)
        SET lastspacepos = findstring(" ",orderinfosub,1,1)
        SET orderinfosub = substring(startpos,lastspacepos,orderinfo)
        SET orderinfosize = (orderinfosize - size(orderinfosub))
        SET startpos = (startpos+ lastspacepos)
       ELSE
        SET ol = 10
       ENDIF
       SET orderlines = (orderlines+ 1)
       SET report_data->person_list[peoplecnt].prn_order_list[prnordercnt].order_information[
       orderlines].order_info_line = trim(orderinfosub,3)
     ENDFOR
     SET report_data->person_list[peoplecnt].prn_order_list[prnordercnt].order_information_cnt =
     orderlines
     SET stat = alterlist(report_data->person_list[peoplecnt].prn_order_list[prnordercnt].
      order_information,orderlines)
     SET report_data->person_list[peoplecnt].prn_order_list[prnordercnt].remaining_doses = build(
      query_data->person_list[peoplecnt].prn_order_list[prnordercnt].remaining_dose_cnt)
   ENDFOR
   SET stat = alterlist(report_data->person_list[peoplecnt].response_task_list,numresponsetasks)
   FOR (responsecnt = 1 TO numresponsetasks)
     SET report_data->person_list[peoplecnt].response_task_list[responsecnt].seq_string = cnvtstring(
      responsecnt)
     SET taskinfo = concat(trim(query_data->person_list[peoplecnt].response_task_list[responsecnt].
       order_mnemonic,3),": ",trim(query_data->person_list[peoplecnt].response_task_list[responsecnt]
       .task_desc,3))
     SET taskinfo = trim(taskinfo,3)
     SET stat = alterlist(report_data->person_list[peoplecnt].response_task_list[responsecnt].
      task_information,10)
     SET startpos = 1
     SET tasklines = 0
     SET taskinfosize = size(taskinfo)
     CALL echo(build("taskInfo:",taskinfo))
     FOR (tl = 1 TO 10)
       CALL echo(build("tL:",tl))
       CALL echo(build("taskInfoSize:",taskinfosize))
       IF (tl=1)
        SET taskinfosub = trim(substring(startpos,65,taskinfo))
        IF (taskinfosize > 65)
         SET lastspacepos = findstring(" ",taskinfosub,1,1)
         CALL echo(build("lastSpacePos:",lastspacepos))
         SET taskinfosub = substring(startpos,lastspacepos,taskinfo)
         SET taskinfosize = (taskinfosize - size(taskinfosub))
         SET startpos = (startpos+ lastspacepos)
        ELSE
         SET tl = 10
        ENDIF
       ELSE
        CALL echo("I'm Here")
        SET taskinfosub = trim(substring(startpos,80,taskinfo))
        IF (taskinfosize > 80)
         SET lastspacepos = findstring(" ",taskinfosub,1,1)
         CALL echo(build("lastSpacePos:",lastspacepos))
         SET taskinfosub = substring(startpos,lastspacepos,taskinfo)
         SET taskinfosize = (taskinfosize - size(taskinfosub))
         SET startpos = (lastspacepos+ 1)
        ELSE
         SET tl = 10
        ENDIF
       ENDIF
       SET tasklines = (tasklines+ 1)
       SET report_data->person_list[peoplecnt].response_task_list[responsecnt].task_information[
       tasklines].task_info_line = trim(taskinfosub,3)
     ENDFOR
     SET report_data->person_list[peoplecnt].response_task_list[responsecnt].task_information_cnt =
     tasklines
     SET stat = alterlist(report_data->person_list[peoplecnt].response_task_list[responsecnt].
      task_information,tasklines)
     SET report_data->person_list[peoplecnt].response_task_list[responsecnt].task_dt_tm = format(
      query_data->person_list[peoplecnt].response_task_list[responsecnt].task_dt_tm,
      "MMM DD, YYYY at HH:MM:SS;;D")
   ENDFOR
 ENDFOR
 CALL echorecord(report_data)
 IF (size(report_data->person_list,5) > 0)
  DECLARE fromnurseunit = vc WITH constant(uar_get_code_display(fromnurseunitcd))
  DECLARE tonurseunit = vc WITH constant(uar_get_code_display(tonurseunitcd))
  DECLARE tofacility = vc WITH constant(uar_get_code_display(tofacilitycd))
  DECLARE tofacilitydisplay = vc WITH constant(concat("{CENTER/",tofacility,"/8/5}"))
  SELECT INTO value(request->printer_name)
   FROM (dummyt d  WITH seq = value(size(report_data->person_list,5)))
   WHERE ((size(report_data->person_list[d.seq].prn_order_list,5) > 0) OR (size(report_data->
    person_list[d.seq].response_task_list,5) > 0))
   ORDER BY d.seq
   HEAD PAGE
    col 0, "{b}{CENTER/Medication Transfer Report/8/5}{endb}", row + 2,
    col 0, tofacilitydisplay, row + 2
   HEAD d.seq
    col 1, "Patient Name:  ", col 17,
    report_data->person_list[d.seq].name_full_formatted, row + 1, col 1,
    "Transfer From: ", col 17, fromnurseunit,
    row + 1, col 1, "Transfer To:   ",
    col 17, tonurseunit, row + 2,
    col 1,
    "This patient was transferred from a nursing unit where online documentation was occurring.", row
     + 5
   DETAIL
    numprnorders = size(report_data->person_list[d.seq].prn_order_list,5)
    IF (numprnorders > 0)
     col 1,
     "The following dose based PRN orders are pending for this patient (please reconcile records",
     row + 1,
     col 1, "appropriately following patient transfer within your medication documentation):", row +
     2
    ENDIF
    FOR (i = 1 TO numprnorders)
      col 2, report_data->person_list[d.seq].prn_order_list[i].seq_string, col 4,
      ")"
      FOR (k = 1 TO report_data->person_list[d.seq].prn_order_list[i].order_information_cnt)
       IF (k=1)
        col 6, report_data->person_list[d.seq].prn_order_list[i].order_information[k].order_info_line
       ELSE
        col 8, report_data->person_list[d.seq].prn_order_list[i].order_information[k].order_info_line
       ENDIF
       ,row + 1
      ENDFOR
      col 6, "Doses remaining that can be administered for this order:", col 63,
      report_data->person_list[d.seq].prn_order_list[i].remaining_doses, col 66, "dose(s)",
      row + 2
    ENDFOR
    row + 3, numresponsetasks = size(report_data->person_list[d.seq].response_task_list,5)
    IF (numresponsetasks > 0)
     col 1,
     "The following PRN response tasks were scheduled for this patient at the time of transfer:", row
      + 2
    ENDIF
    FOR (j = 1 TO numresponsetasks)
      col 2, report_data->person_list[d.seq].response_task_list[j].seq_string, col 4,
      ")", col 6, "PRN response to"
      FOR (k = 1 TO report_data->person_list[d.seq].response_task_list[j].task_information_cnt)
       IF (k=1)
        col 22, report_data->person_list[d.seq].response_task_list[j].task_information[k].
        task_info_line
       ELSE
        col 8, report_data->person_list[d.seq].response_task_list[j].task_information[k].
        task_info_line
       ENDIF
       ,row + 1
      ENDFOR
      col 4, "Due:", col 11,
      report_data->person_list[d.seq].response_task_list[j].task_dt_tm, row + 2
    ENDFOR
   FOOT  d.seq
    x = 0
   FOOT PAGE
    x = 0
   WITH nocounter, check, dio = postscript,
    maxrow = 90
  ;end select
 ENDIF
#exit_script
END GO
