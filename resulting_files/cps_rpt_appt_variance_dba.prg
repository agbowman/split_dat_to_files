CREATE PROGRAM cps_rpt_appt_variance:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SET ran_from_prompt = false
 SET printed_by = fillstring(50," ")
 IF ((validate(request->date_range_flag,- (1))=- (1)))
  FREE RECORD request
  RECORD request(
    1 date_range_flag = c1
    1 appt_knt = i4
    1 appt[*]
      2 appt_type_cd = f8
    1 resource_knt = i4
    1 resource[*]
      2 resource_cd = f8
    1 location_knt = i4
    1 location[*]
      2 location_cd = f8
  )
  SET p_type =  $1
  SET p_user =  $2
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  IF (cnvtupper(p_type)="D")
   SET request->date_range_flag = cnvtupper(p_type)
  ELSEIF (cnvtupper(p_type)="W")
   SET request->date_range_flag = cnvtupper(p_type)
  ELSEIF (cnvtupper(p_type)="M")
   SET request->date_range_flag = cnvtupper(p_type)
  ELSEIF (cnvtupper(p_type)="Q")
   SET request->date_range_flag = cnvtupper(p_type)
  ELSEIF (cnvtupper(p_type)="Y")
   SET request->date_range_flag = cnvtupper(p_type)
  ELSE
   GO TO usage_msg
  ENDIF
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   GO TO usage_msg
  ENDIF
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  IF (cnvtupper(p_user) > " ")
   SET printed_by = trim(cnvtupper(p_user))
  ELSE
   GO TO usage_msg
  ENDIF
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   GO TO usage_msg
  ENDIF
 ENDIF
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE idvar = i2 WITH private, constant(1)
 DECLARE file_name = c25 WITH public, constant(concat("CER_PRINT:PCO_SCH_V",cnvtupper(request->
    date_range_flag),trim(cnvtstring(month(curdate))),trim(cnvtstring(day(curdate)))))
 DECLARE sreporttype = c15 WITH public, noconstant(fillstring(15," "))
 DECLARE ifounddata = i2 WITH public, noconstant(false)
 DECLARE efin_nbr_cd = f8 WITH public, noconstant(0.0)
 DECLARE emrn_cd = f8 WITH public, noconstant(0.0)
 DECLARE pmrn_cd = f8 WITH public, noconstant(0.0)
 DECLARE code_knt = i4 WITH public, noconstant(0)
 DECLARE code_set = i4 WITH public, noconstant(0)
 DECLARE cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE stat = i4 WITH public, noconstant(0)
 DECLARE max_appt_items = i4 WITH public, noconstant(0)
 DECLARE max_loc_items = i4 WITH public, noconstant(0)
 DECLARE cur_day = i2 WITH public, noconstant(1)
 DECLARE cur_month = i2 WITH public, noconstant(1)
 DECLARE cur_year = i2 WITH public, noconstant(1)
 DECLARE cur_week_day = i2 WITH public, noconstant(1)
 DECLARE sdate = c20 WITH public, noconstant(fillstring(20," "))
 SET code_knt = 1
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_knt,efin_nbr_cd)
 IF (stat != 0)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Error finding the code_value for ",trim(cdf_meaning)," in code_set ",trim(
    cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "MRN"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_knt,emrn_cd)
 IF (stat != 0)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Error finding the code_value for ",trim(cdf_meaning)," in code_set ",trim(
    cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET code_knt = 1
 SET code_set = 4
 SET cdf_meaning = "MRN"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_knt,pmrn_cd)
 IF (stat != 0)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Error finding the code_value for ",trim(cdf_meaning)," in code_set ",trim(
    cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 FREE RECORD range_dt
 RECORD range_dt(
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
 )
 FREE RECORD hold
 RECORD hold(
   1 qual_knt = i4
   1 qual[*]
     2 loc_cd = f8
     2 loc_disp = vc
     2 appt_type_cd = f8
     2 appt_type_disp = vc
     2 encntr_id = f8
     2 encntr_fin_nbr = vc
     2 encntr_mrn = vc
     2 fnd_encntr_ind = i2
     2 person_id = f8
     2 person_mrn = vc
     2 person_name = vc
     2 sch_duration = i4
     2 beg_dt_tm = dq8
     2 end_dt_tm = dq8
     2 act_duration = f8
     2 checkin_dt_tm = dq8
     2 checkout_dt_tm = dq8
     2 skip_ind = i2
     2 resource_cd = f8
     2 resource_id = f8
     2 resource_name = vc
 )
 FREE RECORD print_rec
 RECORD print_rec(
   1 loc_knt = i4
   1 loc[*]
     2 loc_cd = f8
     2 loc_disp = vc
     2 appt_knt = i4
     2 appt[*]
       3 appt_type_cd = f8
       3 appt_type_disp = vc
       3 tot_sch_duration = i4
       3 avg_sch_duration = f8
       3 tot_act_duration = f8
       3 avg_act_duration = f8
       3 standard_dev = f8
       3 std_dev_func = f8
       3 item_knt = i4
       3 item[*]
         4 print_item = i2
         4 person_id = f8
         4 person_name = vc
         4 beg_dt_tm = dq8
         4 resource_name = vc
         4 encntr_fin_nbr = vc
         4 encntr_mrn = vc
         4 person_mrn = vc
         4 act_duration = f8
         4 sch_duration = i4
         4 end_dt_tm = dq8
         4 checkin_dt_tm = dq8
         4 checkout_dt_tm = dq8
         4 std_dev = i4
 )
 IF ( NOT (printed_by > " "))
  SELECT INTO "nl:"
   FROM prsnl p
   PLAN (p
    WHERE (p.person_id=req_info->updt_id))
   DETAIL
    printed_by = p.username
   WITH nocounter
  ;end select
 ENDIF
 CASE (cnvtupper(request->date_range_flag))
  OF "D":
   SET range_dt->beg_dt_tm = cnvtdatetime((curdate - 2),235959)
   SET range_dt->end_dt_tm = cnvtdatetime((curdate - 1),0)
  OF "W":
   SET cur_week_day = weekday(curdate)
   SET range_dt->end_dt_tm = cnvtdatetime((curdate - (cur_week_day+ 1)),0)
   SET range_dt->beg_dt_tm = cnvtdatetime(cnvtdate(datetimeadd(range_dt->end_dt_tm,- (7))),235959)
  OF "M":
   SET cur_day = day(curdate)
   SET range_dt->end_dt_tm = cnvtdatetime((curdate - cur_day),0)
   SET cur_day = day(range_dt->end_dt_tm)
   SET range_dt->beg_dt_tm = cnvtdatetime(cnvtdate(datetimeadd(range_dt->end_dt_tm,- (cur_day))),
    235959)
  OF "Q":
   SET cur_month = month(curdate)
   IF (cur_month IN (1, 2, 3))
    SET cur_day = julian(curdate)
    SET range_dt->end_dt_tm = cnvtdatetime((curdate - cur_day),0)
    SET sdate = concat("30-sep-",trim(cnvtstring(year(range_dt->end_dt_tm)))," 23:59:59")
    SET range_dt->beg_dt_tm = cnvtdatetime(sdate)
   ELSEIF (cur_month IN (4, 5, 6))
    SET sdate = concat("31-mar-",trim(cnvtstring(year(curdate)))," 00:00:00")
    SET range_dt->end_dt_tm = cnvtdatetime(sdate)
    SET sdate = concat("31-dec-",trim(cnvtstring((year(curdate) - 1)))," 23:59:59")
    SET range_dt->beg_dt_tm = cnvtdatetime(sdate)
   ELSEIF (cur_month IN (7, 8, 9))
    SET sdate = concat("30-jun-",trim(cnvtstring(year(curdate)))," 00:00:00")
    SET range_dt->end_dt_tm = cnvtdatetime(sdate)
    SET sdate = concat("31-mar-",trim(cnvtstring(year(curdate)))," 23:59:59")
    SET range_dt->beg_dt_tm = cnvtdatetime(sdate)
   ELSEIF (cur_month IN (10, 11, 12))
    SET sdate = concat("30-sep-",trim(cnvtstring(year(curdate)))," 00:00:00")
    SET range_dt->end_dt_tm = cnvtdatetime(sdate)
    SET sdate = concat("30-jun-",trim(cnvtstring(year(curdate)))," 23:59:59")
    SET range_dt->beg_dt_tm = cnvtdatetime(sdate)
   ENDIF
  OF "Y":
   SET sdate = concat("31-dec-",trim(cnvtstring((year(curdate) - 2)))," 23:59:59")
   SET range_dt->beg_dt_tm = cnvtdatetime(sdate)
   SET sdate = concat("31-dec-",trim(cnvtstring((year(curdate) - 1)))," 00:00:00")
   SET range_dt->end_dt_tm = cnvtdatetime(sdate)
  ELSE
   SET failed = input_error
   SET table_name = "REQUEST"
   SET serrmsg = concat("Invalid DATE_RANGE_FLAG (",trim(request->date_range_flag),")")
   GO TO exit_script
 ENDCASE
 CALL echo("***")
 CALL echo(build("request->date_range_flag :",request->date_range_flag))
 CALL echo(concat("range_dt->beg_dt_tm = ",format(cnvtdatetime(range_dt->beg_dt_tm),
    "dd-mmm-yyyy hh:mm:ss;;d")))
 CALL echo(concat("range_dt->end_dt_tm = ",format(cnvtdatetime(range_dt->end_dt_tm),
    "dd-mmm-yyyy hh:mm:ss;;d")))
 CALL echo("***")
 IF ((request->appt_knt > 0)
  AND (request->resource_knt > 0))
  SET sreporttype = "RESOURCE/APPT"
 ELSEIF ((request->appt_knt > 0))
  SET sreporttype = "APPT"
 ELSEIF ((request->resource_knt > 0))
  SET sreporttype = "RESOURCE"
 ELSE
  SET sreporttype = "DEFAULT"
 ENDIF
 IF (sreporttype="DEFAULT")
  CALL load_default_data(idvar)
 ENDIF
 IF ((((hold->qual_knt < 1)) OR (ifounddata=false)) )
  GO TO produce_report
 ENDIF
 CALL load_names(idvar)
 CALL load_identifiers(idvar)
 CALL load_print_rec(idvar)
#produce_report
 SELECT INTO value(file_name)
  FROM (dummyt d  WITH seq = 1)
  HEAD REPORT
   cur_page = 1, total_pages = 1, cur_line = 1,
   max_lines = 51, max_columns = 117, printed_item = false,
   start_dt = format(cnvtdate(datetimeadd(range_dt->beg_dt_tm,1)),"@SHORTDATE;;Q"), stop_dt = format(
    cnvtdate(range_dt->end_dt_tm),"@SHORTDATE;;Q"), report_date = fillstring(33," ")
   IF ((request->date_range_flag="D"))
    report_date = concat("Report Date: ",trim(stop_dt))
   ELSE
    report_date = concat("Report Dates: ",trim(start_dt)," - ",trim(stop_dt))
   ENDIF
   print_dt_tm = concat(format(datetimezone(datetimezone(cnvtdatetime(curdate,curtime3),
       curtimezonesys,2),curtimezoneapp),"@SHORTDATETIME;;Q")," ",datetimezonebyindex(curtimezoneapp)
    ), uline = fillstring(119,"_"), appt_separator = fillstring(117,"_"),
   loc_separator = fillstring(119,"-"), item_line = fillstring(200," "), appt_line = fillstring(119,
    " "),
   appt_cont_line = fillstring(119," "), page_stamp = fillstring(17," "), printed_item_heading =
   false,
   report_title = fillstring(100," ")
   IF (sreporttype="DEFAULT")
    report_title = format("All Locations / All Appointment Types / All Resources",
     "#######################################################;R;T")
   ELSEIF (sreporttype="RESOURCE/APPT")
    IF ((request->appt_knt=1))
     report_title = trim(substring(1,20,uar_get_code_display(request->appt[1].appt_type_cd)))
    ELSE
     report_title = "Specified Appointment Types"
    ENDIF
    IF ((request->resource_knt=1))
     report_title = format(substring(1,41,concat(trim(report_title),"/",trim(substring(1,20,
          uar_get_code_display(request->resource[1].resource_cd))))),
      "#########################################;R;T")
    ELSE
     report_titile = format(substring(1,41,concat(trim(report_title),"/","Specified Resources")),
      "#########################################;R;T")
    ENDIF
   ELSEIF (sreporttype="RESOURCE")
    IF ((request->resource_knt=1))
     report_title = format(substring(1,41,concat("All Appointment Types/",trim(substring(1,19,
          uar_get_code_display(request->resource[1].resource_cd))))),
      "#########################################;R;T")
    ELSE
     report_titile = format("All Appointment Types/Specified Resources",
      "#########################################;R;T")
    ENDIF
   ELSEIF (sreporttype="APPT")
    IF ((request->appt_knt=1))
     report_title = format(concat(trim(substring(1,27,uar_get_code_display(request->appt[1].
          appt_type_cd))),"/All Resources"),"#########################################;R;T")
    ELSE
     report_title = format("Specified Appointment Types/All Resources",
      "#########################################;R;T")
    ENDIF
   ENDIF
   patient_name = fillstring(20," "), sch_dt_tm = fillstring(11," "), chk_in_dt_tm = fillstring(11,
    " "),
   resource_name = fillstring(20," "), ident = fillstring(29," "), sch_dur = fillstring(3," "),
   act_dur = fillstring(5," "), std_dev = fillstring(4," "),
   MACRO (find_total_pages)
    total_pages = 1, line_knt = 1
    IF ((print_rec->loc_knt > 0))
     FOR (k = 1 TO print_rec->loc_knt)
       IF ((print_rec->loc[k].appt_knt > 0))
        IF (((cur_line+ 3) > max_lines))
         total_pages = (total_pages+ 1), cur_line = 1
        ENDIF
       ELSE
        IF (((cur_line+ 2) > max_lines))
         total_pages = (total_pages+ 1), cur_line = 1
        ENDIF
       ENDIF
       cur_line = (cur_line+ 2)
       IF ((print_rec->loc[k].appt_knt > 0))
        FOR (i = 1 TO print_rec->loc[k].appt_knt)
          IF ((print_rec->loc[k].appt_knt > 0))
           IF (((cur_line+ 2) > max_lines))
            total_pages = (total_pages+ 1), cur_line = 1
           ENDIF
          ENDIF
          cur_line = (cur_line+ 1), cur_line = (cur_line+ 1), printed_item = false
          FOR (j = 1 TO print_rec->loc[k].appt[i].item_knt)
            IF ((print_rec->loc[k].appt[i].item[j].print_item=true))
             printed_item = true
             IF (cur_line > max_lines)
              total_pages = (total_pages+ 1), cur_line = 1, cur_line = (cur_line+ 2),
              cur_line = (cur_line+ 1), cur_line = (cur_line+ 1)
             ENDIF
             cur_line = (cur_line+ 1)
            ENDIF
          ENDFOR
          IF (printed_item=false)
           cur_line = (cur_line+ 1)
          ENDIF
          IF ((i != print_rec->loc[k].appt_knt))
           IF (((cur_line+ 4) > max_lines))
            total_pages = (total_pages+ 1), cur_line = 1, cur_line = (cur_line+ 2)
           ELSE
            cur_line = (cur_line+ 2)
           ENDIF
          ENDIF
        ENDFOR
       ELSE
        cur_line = (cur_line+ 1)
       ENDIF
       IF ((k != print_rec->loc_knt))
        IF (((cur_line+ 7) > max_lines))
         total_pages = (total_pages+ 1), cur_line = 1
        ELSE
         cur_line = (cur_line+ 3)
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
   ENDMACRO
   ,
   MACRO (print_page_layout)
    page_stamp = format(concat("Page ",trim(cnvtstring(cur_page))," of ",trim(cnvtstring(total_pages)
       )),"#################;R;T"), "{PS/792 0 translate 90 rotate/}", row + 1,
    "{f/5/1}{cpi/6^}{lpi/6}", row + 2, col 60,
    "Schedule Variance", "{cpi/10^}{lpi/8}", row + 2
    IF ((request->date_range_flag="D"))
     col 10, report_date, col 139,
     report_title
    ELSE
     col 10, report_date, col 131,
     report_title
    ENDIF
    row + 1, col 10, "{b}{u}",
    uline, "{endu}{endb}{pos/000/525}", row + 1,
    col 10, "{b}{u}", uline,
    "{endu}{endb}", row + 2, col 10,
    "Printed On: ", print_dt_tm, " By: ",
    printed_by, col 80, page_stamp,
    "{f/0/1}{cpi/12^}{lpi/8}{pos/000/065}", row + 1, cur_line = 1
   ENDMACRO
   ,
   MACRO (is_header_room)
    IF ((print_rec->loc[k].appt_knt > 0))
     IF (((cur_line+ 3) > max_lines))
      BREAK, cur_page = (cur_page+ 1), print_page_layout
     ENDIF
    ELSE
     IF (((cur_line+ 2) > max_lines))
      BREAK, cur_page = (cur_page+ 1), print_page_layout
     ENDIF
    ENDIF
   ENDMACRO
   ,
   MACRO (is_appt_header_room)
    IF ((print_rec->loc[k].appt_knt > 0))
     IF (((cur_line+ 2) > max_lines))
      BREAK, cur_page = (cur_page+ 1), print_page_layout
     ENDIF
    ENDIF
   ENDMACRO
   ,
   MACRO (is_item_room)
    IF (cur_line > max_lines)
     BREAK, cur_page = (cur_page+ 1), print_page_layout,
     col 5, "{b}", print_rec->loc[k].loc_disp,
     "  Continued ...", "{endb}", row + 2,
     cur_line = (cur_line+ 2), appt_cont_line = concat(format(print_rec->loc[k].appt[i].
       appt_type_disp,"####################;l;t"),"  Continued ... ","  Total Scheduled: ",trim(
       cnvtstring(print_rec->loc[k].appt[i].item_knt)),"  Actual Avg: ",
      trim(format(print_rec->loc[k].appt[i].avg_act_duration,"###.#;I;F"),3),"  Sched Avg: ",trim(
       format(print_rec->loc[k].appt[i].avg_sch_duration,"###.#;I;F"),3),"  Stand Dev: ",trim(format(
        print_rec->loc[k].appt[i].standard_dev,"###.##;I;F"),3)), col 7,
     "{b}", appt_cont_line, "{endb}",
     row + 1, cur_line = (cur_line+ 1), col 10,
     "{color/20}", "Patient Name", col 39,
     "Sch Dt/Tm", col 50, "Chk-In Dt/Tm",
     col 66, "Resource", col 86,
     "Identifier", col 108, "Sch Dur",
     col 118, "Act Dur", col 127,
     "Std Dev", "{color/0}", row + 1,
     cur_line = (cur_line+ 1)
    ENDIF
   ENDMACRO
   ,
   MACRO (print_appt_separator)
    IF ((i != print_rec->loc[k].appt_knt))
     IF (((cur_line+ 4) > max_lines))
      BREAK, cur_page = (cur_page+ 1), print_page_layout,
      col 5, "{b}", print_rec->loc[k].loc_disp,
      "  Continued ...", "{endb}", row + 2,
      cur_line = (cur_line+ 2)
     ELSE
      col 7, "{b}", appt_separator,
      "{endb}", row + 2, cur_line = (cur_line+ 2)
     ENDIF
    ENDIF
   ENDMACRO
   ,
   MACRO (print_loc_separator)
    IF ((k != print_rec->loc_knt))
     IF (((cur_line+ 7) > max_lines))
      BREAK, cur_page = (cur_page+ 1), print_page_layout
     ELSE
      row + 1, col 5, "{b}{u}",
      loc_separator, "{endu}{endb}", row + 2,
      cur_line = (cur_line+ 3)
     ENDIF
    ENDIF
   ENDMACRO
   ,
   MACRO (print_report_body)
    FOR (k = 1 TO print_rec->loc_knt)
      is_header_room, col 5, "{b}",
      print_rec->loc[k].loc_disp, "{endb}", row + 2,
      cur_line = (cur_line+ 2)
      IF ((print_rec->loc[k].appt_knt > 0))
       FOR (i = 1 TO print_rec->loc[k].appt_knt)
         is_appt_header_room, appt_line = concat(format(print_rec->loc[k].appt[i].appt_type_disp,
           "####################;l;t"),"  Total Scheduled: ",trim(cnvtstring(print_rec->loc[k].appt[i
            ].item_knt)),"  Actual Avg: ",trim(format(print_rec->loc[k].appt[i].avg_act_duration,
            "###.#;I;F"),3),
          "  Sched Avg: ",trim(format(print_rec->loc[k].appt[i].avg_sch_duration,"###.#;I;F"),3),
          "  Stand Dev: ",trim(format(print_rec->loc[k].appt[i].standard_dev,"###.##;I;F"),3)), col 7,
         "{b}", appt_line, "{endb}",
         row + 1, cur_line = (cur_line+ 1), col 10,
         "{color/20}", "Patient Name", col 39,
         "Sch Dt/Tm", col 50, "Chk-In Dt/Tm",
         col 66, "Resource", col 86,
         "Identifier", col 108, "Sch Dur",
         col 118, "Act Dur", col 127,
         "Std Dev", "{color/0}", row + 1,
         cur_line = (cur_line+ 1), printed_item = false
         FOR (j = 1 TO print_rec->loc[k].appt[i].item_knt)
           IF ((print_rec->loc[k].appt[i].item[j].print_item=true))
            printed_item = true, is_item_room, patient_name = trim(substring(1,15,print_rec->loc[k].
              appt[i].item[j].person_name),3),
            sch_dt_tm = concat(format(cnvtdatetime(print_rec->loc[k].appt[i].item[j].beg_dt_tm),
              "@MONTHNUMBER;;D"),"/",format(cnvtdatetime(print_rec->loc[k].appt[i].item[j].beg_dt_tm),
              "dd;;D")," ",format(cnvtdatetime(print_rec->loc[k].appt[i].item[j].beg_dt_tm),
              "@TIMENOSECONDS;;Q")), chk_in_dt_tm = concat(format(cnvtdatetime(print_rec->loc[k].
               appt[i].item[j].checkin_dt_tm),"@MONTHNUMBER;;D"),"/",format(cnvtdatetime(print_rec->
               loc[k].appt[i].item[j].checkin_dt_tm),"dd;;D")," ",format(cnvtdatetime(print_rec->loc[
               k].appt[i].item[j].checkin_dt_tm),"@TIMENOSECONDS;;Q")), resource_name = trim(
             substring(1,15,print_rec->loc[k].appt[i].item[j].resource_name),3)
            IF ((print_rec->loc[k].appt[i].item[j].encntr_fin_nbr > " "))
             IF (textlen(print_rec->loc[k].appt[i].item[j].encntr_fin_nbr) > 20)
              ident = "No encounter identifiers"
             ELSE
              ident = concat("Fin Nbr: ",trim(format(print_rec->loc[k].appt[i].item[j].encntr_fin_nbr,
                 "####################;L;T"),3))
             ENDIF
            ELSEIF ((print_rec->loc[k].appt[i].item[j].encntr_mrn > " "))
             IF (textlen(print_rec->loc[k].appt[i].item[j].encntr_fin_nbr) > 22)
              ident = "No encounter identifiers"
             ELSE
              ident = concat("E MRN: ",trim(format(print_rec->loc[k].appt[i].item[j].encntr_mrn,
                 "####################;L;T"),3))
             ENDIF
            ELSEIF ((print_rec->loc[k].appt[i].item[j].person_mrn > " "))
             IF (textlen(print_rec->loc[k].appt[i].item[j].encntr_fin_nbr) > 22)
              ident = "No encounter identifiers"
             ELSE
              ident = concat("P MRN: ",trim(format(print_rec->loc[k].appt[i].item[j].person_mrn,
                 "####################;L;T"),3))
             ENDIF
            ELSE
             ident = "No encounter identifiers"
            ENDIF
            sch_dur = trim(cnvtstring(print_rec->loc[k].appt[i].item[j].sch_duration)), act_dur =
            trim(format(print_rec->loc[k].appt[i].item[j].act_duration,"#####.#;I;F"),3)
            IF ((print_rec->loc[k].appt[i].item[j].std_dev > 0))
             std_dev = concat("> ",trim(cnvtstring(print_rec->loc[k].appt[i].item[j].std_dev)))
            ELSE
             std_dev = "None"
            ENDIF
            col 10, patient_name, col 28,
            sch_dt_tm, col 41, chk_in_dt_tm,
            col 54, resource_name, col 71,
            ident, col 102, sch_dur,
            col 110, act_dur, col 119,
            std_dev, row + 1, cur_line = (cur_line+ 1)
           ENDIF
         ENDFOR
         IF (printed_item=false)
          col 10,
          "No appointment items had an actual time deviation greater then one (1) standard deviation",
          row + 1,
          cur_line = (cur_line+ 1)
         ENDIF
         print_appt_separator
       ENDFOR
      ELSE
       col 7, "No appointments scheduled to this location", row + 1,
       cur_line = (cur_line+ 1)
      ENDIF
      print_loc_separator
    ENDFOR
   ENDMACRO
   ,
   MACRO (print_no_data)
    col 05, "No appointments for the specified date range where found", row + 1
   ENDMACRO
   , find_total_pages,
   print_page_layout
   IF ((print_rec->loc_knt > 0))
    print_report_body
   ELSE
    print_no_data
   ENDIF
  WITH check, nocounter, nullreport,
   maxrow = 100, maxcol = 300, dio = postscript,
   dio = 8
 ;end select
 GO TO exit_script
 SUBROUTINE load_print_rec(ilvar)
  SELECT INTO "nl:"
   loc_cd = hold->qual[d.seq].loc_cd, appt_type_cd = hold->qual[d.seq].appt_type_cd, act_duration =
   hold->qual[d.seq].act_duration,
   sch_duration = hold->qual[d.seq].sch_duration
   FROM (dummyt d  WITH seq = value(hold->qual_knt))
   PLAN (d
    WHERE d.seq > 0
     AND (hold->qual[d.seq].skip_ind=false))
   ORDER BY loc_cd, appt_type_cd, act_duration DESC,
    sch_duration DESC
   HEAD REPORT
    lknt = 0, stat = alterlist(print_rec->loc,10)
   HEAD loc_cd
    lknt = (lknt+ 1)
    IF (mod(lknt,10)=1
     AND lknt != 1)
     stat = alterlist(print_rec->loc,(lknt+ 9))
    ENDIF
    print_rec->loc[lknt].loc_cd = hold->qual[d.seq].loc_cd, print_rec->loc[lknt].loc_disp = hold->
    qual[d.seq].loc_disp, knt = 0,
    stat = alterlist(print_rec->loc[lknt].appt,10), sch_duration_total = 0, act_duration_total = 0.0
   HEAD appt_type_cd
    knt = (knt+ 1)
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(print_rec->loc[lknt].appt,(knt+ 9))
    ENDIF
    print_rec->loc[lknt].appt[knt].appt_type_cd = hold->qual[d.seq].appt_type_cd, print_rec->loc[lknt
    ].appt[knt].appt_type_disp = hold->qual[d.seq].appt_type_disp, sch_duration_total = 0,
    act_duration_total = 0.0, dknt = 0, stat = alterlist(print_rec->loc[lknt].appt[knt].item,10)
   DETAIL
    dknt = (dknt+ 1)
    IF (mod(dknt,10)=1
     AND dknt != 1)
     stat = alterlist(print_rec->loc[lknt].appt[knt].item,(dknt+ 9))
    ENDIF
    sch_duration_total = (sch_duration_total+ hold->qual[d.seq].sch_duration), act_duration_total = (
    act_duration_total+ hold->qual[d.seq].act_duration), print_rec->loc[lknt].appt[knt].item[dknt].
    person_id = hold->qual[d.seq].person_id,
    print_rec->loc[lknt].appt[knt].item[dknt].person_name = hold->qual[d.seq].person_name, print_rec
    ->loc[lknt].appt[knt].item[dknt].beg_dt_tm = hold->qual[d.seq].beg_dt_tm, print_rec->loc[lknt].
    appt[knt].item[dknt].checkin_dt_tm = hold->qual[d.seq].checkin_dt_tm,
    print_rec->loc[lknt].appt[knt].item[dknt].resource_name = hold->qual[d.seq].resource_name,
    print_rec->loc[lknt].appt[knt].item[dknt].encntr_fin_nbr = hold->qual[d.seq].encntr_fin_nbr,
    print_rec->loc[lknt].appt[knt].item[dknt].encntr_mrn = hold->qual[d.seq].encntr_mrn,
    print_rec->loc[lknt].appt[knt].item[dknt].person_mrn = hold->qual[d.seq].person_mrn, print_rec->
    loc[lknt].appt[knt].item[dknt].act_duration = hold->qual[d.seq].act_duration, print_rec->loc[lknt
    ].appt[knt].item[dknt].sch_duration = hold->qual[d.seq].sch_duration,
    print_rec->loc[lknt].appt[knt].item[dknt].end_dt_tm = hold->qual[d.seq].end_dt_tm, print_rec->
    loc[lknt].appt[knt].item[dknt].checkout_dt_tm = hold->qual[d.seq].checkout_dt_tm
   FOOT  appt_type_cd
    print_rec->loc[lknt].appt[knt].tot_sch_duration = sch_duration_total, print_rec->loc[lknt].appt[
    knt].tot_act_duration = act_duration_total
    IF (dknt > 0)
     print_rec->loc[lknt].appt[knt].avg_sch_duration = avg(sch_duration), print_rec->loc[lknt].appt[
     knt].avg_act_duration = avg(act_duration)
    ELSE
     print_rec->loc[lknt].appt[knt].avg_sch_duration = 0.0, print_rec->loc[lknt].appt[knt].
     avg_act_duration = 0.0
    ENDIF
    IF (dknt > 1)
     print_rec->loc[lknt].appt[knt].standard_dev = stddev(act_duration
      WHERE 1=1)
    ENDIF
    print_rec->loc[lknt].appt[knt].item_knt = dknt, stat = alterlist(print_rec->loc[lknt].appt[knt].
     item,dknt)
   FOOT  loc_cd
    IF (knt > max_appt_items)
     max_appt_items = knt
    ENDIF
    print_rec->loc[lknt].appt_knt = knt, stat = alterlist(print_rec->loc[lknt].appt,knt)
   FOOT REPORT
    IF (lknt > max_loc_items)
     max_loc_items = lknt
    ENDIF
    print_rec->loc_knt = lknt, stat = alterlist(print_rec->loc,lknt)
   WITH nocounter
  ;end select
  IF ((print_rec->loc_knt > 0))
   FOR (k = 1 TO print_rec->loc_knt)
     IF ((print_rec->loc[k].appt_knt > 0))
      FOR (i = 1 TO print_rec->loc[k].appt_knt)
        IF ((print_rec->loc[k].appt[i].item_knt > 1))
         SET avg_dur_plus_10 = ((print_rec->loc[k].appt[i].avg_act_duration * 0.1)+ print_rec->loc[k]
         .appt[i].avg_act_duration)
         FOR (j = 1 TO print_rec->loc[k].appt[i].item_knt)
           IF ((print_rec->loc[k].appt[i].item[j].act_duration > avg_dur_plus_10))
            SET print_rec->loc[k].appt[i].item[j].print_item = true
            SET print_rec->loc[k].appt[i].item[1].std_dev = floor(((print_rec->loc[k].appt[i].item[1]
             .act_duration - print_rec->loc[k].appt[i].avg_act_duration)/ print_rec->loc[k].appt[i].
             standard_dev))
           ENDIF
         ENDFOR
        ELSEIF ((print_rec->loc[k].appt[i].item_knt=1))
         IF ((print_rec->loc[k].appt[i].item[1].act_duration > (print_rec->loc[k].appt[i].item[1].
         sch_duration+ (print_rec->loc[k].appt[i].item[1].sch_duration * 0.1))))
          SET print_rec->loc[k].appt[i].item[1].print_item = true
          SET print_rec->loc[k].appt[i].item[1].std_dev = floor(((print_rec->loc[k].appt[i].item[1].
           act_duration - print_rec->loc[k].appt[i].avg_act_duration)/ print_rec->loc[k].appt[i].
           standard_dev))
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
  ENDIF
 END ;Subroutine
 SUBROUTINE load_identifiers(ilvar)
  SELECT INTO "nl:"
   ea.beg_effective_dt_tm, ea.beg_effective_tz, alias = cnvtalias(cnvtalphanum(ea.alias),ea
    .alias_pool_cd)
   FROM (dummyt d  WITH seq = value(hold->qual_knt)),
    encntr_alias ea
   PLAN (d
    WHERE d.seq > 0
     AND (hold->qual[d.seq].encntr_id > 0)
     AND (hold->qual[d.seq].skip_ind=false))
    JOIN (ea
    WHERE (ea.encntr_id=hold->qual[d.seq].encntr_id)
     AND ea.encntr_alias_type_cd IN (efin_nbr_cd, emrn_cd)
     AND ea.active_ind=1
     AND ea.beg_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND ea.end_effective_dt_tm <= cnvtdatetime(curdate,curtime3))
   ORDER BY ea.beg_effective_dt_tm DESC
   HEAD REPORT
    found_fin = false, found_mrn = false
   DETAIL
    IF (ea.encntr_alias_type_cd=efin_nbr_cd
     AND found_fin=false)
     found_fin = true, hold->qual[d.seq].fnd_encntr_ind = true
     IF (ea.alias_pool_cd > 0)
      hold->qual[d.seq].encntr_fin_nbr = alias
     ELSE
      hold->qual[d.seq].encntr_fin_nbr = ea.alias
     ENDIF
    ENDIF
    IF (ea.encntr_alias_type_cd=emrn_cd
     AND found_mrn=false)
     found_mrn = true, hold->qual[d.seq].fnd_encntr_ind = true
     IF (ea.alias_pool_cd > 0)
      hold->qual[d.seq].encntr_mrn = alias
     ELSE
      hold->qual[d.seq].encntr_mrn = ea.alias
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   pa.beg_effective_dt_tm, pa.beg_effective_tz, alias = cnvtalias(cnvtalphanum(pa.alias),pa
    .alias_pool_cd)
   FROM (dummyt d  WITH seq = value(hold->qual_knt)),
    person_alias pa
   PLAN (d
    WHERE d.seq > 0
     AND (hold->qual[d.seq].fnd_encntr_ind=false)
     AND (hold->qual[d.seq].skip_ind=false))
    JOIN (pa
    WHERE (pa.person_id=hold->qual[d.seq].person_id)
     AND pa.person_alias_type_cd=pmrn_cd
     AND pa.active_ind=1
     AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY pa.beg_effective_dt_tm DESC
   HEAD REPORT
    found_mrn = false
   DETAIL
    IF (found_mrn=false)
     found_mrn = true
     IF (pa.alias_pool_cd > 0)
      hold->qual[d.seq].person_mrn = alias
     ELSE
      hold->qual[d.seq].person_mrn = pa.alias
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE load_names(ilvar)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(hold->qual_knt)),
     person p,
     prsnl pr
    PLAN (d
     WHERE d.seq > 0
      AND (hold->qual[d.seq].skip_ind=false))
     JOIN (p
     WHERE (p.person_id=hold->qual[d.seq].person_id))
     JOIN (pr
     WHERE (pr.person_id=hold->qual[d.seq].resource_id))
    DETAIL
     hold->qual[d.seq].act_duration = datetimediff(hold->qual[d.seq].checkout_dt_tm,hold->qual[d.seq]
      .checkin_dt_tm,4), hold->qual[d.seq].person_name = p.name_full_formatted
     IF (pr.person_id > 0)
      hold->qual[d.seq].resource_name = pr.name_full_formatted
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE load_default_data(ilvar)
   SELECT INTO "nl:"
    se.appt_type_cd, sea.sch_action_id
    FROM sch_appt sa1,
     sch_event se,
     sch_appt sa2,
     sch_event_action sea
    PLAN (sa1
     WHERE sa1.beg_dt_tm > cnvtdatetime(range_dt->beg_dt_tm)
      AND sa1.beg_dt_tm <= cnvtdatetime(range_dt->end_dt_tm)
      AND sa1.resource_cd=0
      AND sa1.person_id > 0
      AND sa1.role_meaning="PATIENT"
      AND sa1.state_meaning="CHECKED OUT")
     JOIN (se
     WHERE se.sch_event_id=sa1.sch_event_id)
     JOIN (sa2
     WHERE sa2.sch_event_id=sa1.sch_event_id
      AND sa2.schedule_id=sa1.schedule_id
      AND sa2.role_meaning="RESOURCE"
      AND sa2.primary_role_ind=1
      AND sa2.resource_cd > 0)
     JOIN (sea
     WHERE sea.sch_event_id=sa1.sch_event_id
      AND sea.schedule_id=sa1.schedule_id
      AND sea.action_meaning IN ("CHECKIN", "CHECKOUT"))
    ORDER BY sa1.sch_appt_id, sea.action_meaning
    HEAD REPORT
     knt = 0, stat = alterlist(hold->qual,10), cur_action_meaning = fillstring(12," "),
     found_in = false, found_out = false, cur_sch_appt_id = 0.0
    DETAIL
     IF (cur_sch_appt_id != sa1.sch_appt_id)
      IF (knt != 1
       AND ((found_in=false) OR (found_out=false)) )
       hold->qual[(knt - 1)].skip_ind = true
      ENDIF
      cur_sch_appt_id = sa1.sch_appt_id, found_in = false, found_out = false,
      knt = (knt+ 1)
      IF (mod(knt,10)=1
       AND knt != 1)
       stat = alterlist(hold->qual,(knt+ 9))
      ENDIF
      hold->qual[knt].loc_cd = sa1.appt_location_cd
      IF (sa1.appt_location_cd > 0)
       hold->qual[knt].loc_disp = uar_get_code_display(sa1.appt_location_cd)
      ELSE
       hold->qual[knt].loc_disp = "Unkown Location"
      ENDIF
      hold->qual[knt].appt_type_cd = se.appt_type_cd, hold->qual[knt].appt_type_disp =
      uar_get_code_display(se.appt_type_cd), hold->qual[knt].encntr_id = sa1.encntr_id,
      hold->qual[knt].person_id = sa1.person_id, hold->qual[knt].sch_duration = sa1.duration, hold->
      qual[knt].beg_dt_tm = sa1.beg_dt_tm,
      hold->qual[knt].end_dt_tm = sa1.end_dt_tm, hold->qual[knt].resource_cd = sa2.resource_cd, hold
      ->qual[knt].resource_id = sa2.person_id
      IF (sa2.resource_cd > 0)
       hold->qual[knt].resource_name = uar_get_code_display(sa2.resource_cd)
      ENDIF
      IF (sea.action_meaning="CHECKIN")
       found_in = true, hold->qual[knt].checkin_dt_tm = sea.action_dt_tm
       IF (ifounddata=false
        AND found_out=true)
        ifounddata = true
       ENDIF
      ENDIF
      IF (sea.action_meaning="CHECKOUT")
       found_out = true, hold->qual[knt].checkout_dt_tm = sea.action_dt_tm
       IF (ifounddata=false
        AND found_in=true)
        ifounddata = true
       ENDIF
      ENDIF
     ELSE
      IF (sea.action_meaning="CHECKIN")
       found_in = true, hold->qual[knt].checkin_dt_tm = sea.action_dt_tm
       IF (ifounddata=false
        AND found_out=true)
        ifounddata = true
       ENDIF
      ENDIF
      IF (sea.action_meaning="CHECKOUT")
       found_out = true, hold->qual[knt].checkout_dt_tm = sea.action_dt_tm
       IF (ifounddata=false
        AND found_in=true)
        ifounddata = true
       ENDIF
      ENDIF
      IF (found_in=true
       AND found_out=true)
       hold->qual[knt].act_duration = datetimediff(hold->qual[knt].checkout_dt_tm,hold->qual[knt].
        checkin_dt_tm,4), hold->qual[knt].skip_ind = false
      ENDIF
     ENDIF
    FOOT REPORT
     IF (((found_in=false) OR (found_out=false)) )
      hold->qual[knt].skip_ind = true
     ELSEIF (ifounddata=false)
      ifounddata = true
     ENDIF
     hold->qual_knt = knt, stat = alterlist(hold->qual,knt)
    WITH nocounter
   ;end select
 END ;Subroutine
#usage_msg
 CALL echo("***")
 CALL echo("***")
 CALL echo('***   CPS_RPT_APPT_VARIANCE "X","USERNAME" GO')
 CALL echo("***")
 CALL echo("***   X - D (Previous Day)")
 CALL echo("***   X - W (Previous Week)")
 CALL echo("***   X - M (Previous Month)")
 CALL echo("***   X - Q (Previous Quarter)")
 CALL echo("***   X - Y (Previous Year)")
 CALL echo("***")
 CALL echo("***   USERNAME - Your username")
 CALL echo("***")
 CALL echo('***   Example of the command: CPS_RPT_APPT_VARIANCE "D","SF3151" GO')
 CALL echo("***")
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "000 04/23/01 SF3151"
END GO
