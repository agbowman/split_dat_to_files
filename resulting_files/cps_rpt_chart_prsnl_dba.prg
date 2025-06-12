CREATE PROGRAM cps_rpt_chart_prsnl:dba
 RECORD reply(
   1 person_id = f8
   1 encntr_id = f8
   1 output_file = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET person_id = request->person_id
 SET encntr_id = request->encntr_id
 SET print_id = reqinfo->updt_id
 FREE SET person
 RECORD person(
   1 prsnl_id = f8
   1 prsnl_name = vc
   1 position = vc
 )
 FREE RECORD reply1
 RECORD reply1(
   1 person_cnt = i4
   1 person[*]
     2 person_id = f8
     2 name = vc
     2 mrn = vc
     2 reltn = vc
     2 qual_cnt = i4
     2 qual[*]
       3 ppa_id = f8
       3 ppa_type_cd = f8
       3 ppa_type_mean = vc
       3 ppa_last_dt_tm = dq8
       3 view_caption = vc
       3 computer_name = vc
       3 ppa_comment = vc
 )
 SET output_file = fillstring(100," ")
 IF ((request->output_file > " "))
  SET output_file = trim(request->output_file)
 ELSE
  SET output_file = "cps_rpt_chart_prsnl"
 ENDIF
 SET false = 0
 SET true = 1
 SET total_pages = 1
 SET state_cd = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET printer = fillstring(60," ")
 SET name = fillstring(18," ")
 SET dob_sex = fillstring(28," ")
 SET home_addr = fillstring(28," ")
 SET city = fillstring(14," ")
 SET city_state_zip = fillstring(28," ")
 SET home_phone = fillstring(28," ")
 SET visit_date = fillstring(28," ")
 SET print_line1 = fillstring(80," ")
 SET print_line2 = fillstring(79," ")
 FREE RECORD drec
 RECORD drec(
   1 app_dt_tm = dq8
   1 sys_dt_tm = dq8
 )
 DECLARE print_time = vc WITH public, noconstant(" ")
 DECLARE print_time_ampm = vc WITH public, noconstant(" ")
 DECLARE the_time = vc WITH public, noconstant(" ")
 DECLARE pm_check = vc WITH public, noconstant(" ")
 DECLARE utc_is_on = i2 WITH public, noconstant(0)
 SET utc_is_on = curutc
 IF (utc_is_on > 0)
  SET drec->sys_dt_tm = datetimezone(cnvtdatetime(curdate,curtime3),curtimezonesys,2)
  SET drec->app_dt_tm = datetimezone(drec->sys_dt_tm,curtimezoneapp)
 ELSE
  SET drec->app_dt_tm = cnvtdatetime(curdate,curtime3)
 ENDIF
 SET print_time = format(drec->app_dt_tm,"mm/dd/yy;;d")
 CALL echo("***")
 CALL echo(build("***   print_time :",print_time))
 CALL echo("***")
 SET the_time = format(drec->app_dt_tm,"hh:mm;;s")
 CALL echo("***")
 CALL echo(build("***   the_time :",the_time))
 CALL echo("***")
 SET print_time = concat(print_time," ",substring(1,5,the_time))
 CALL echo("***")
 CALL echo(build("***   print_time :",print_time))
 CALL echo("***")
 SET pm_check = format(drec->app_dt_tm,"hh:mm;;m")
 CALL echo("***")
 CALL echo(build("***   pm_check :",pm_check))
 CALL echo("***")
 IF (cnvtint(substring(1,2,pm_check)) >= 12)
  SET print_time_ampm = cnvtupper(concat(print_time," PM"))
 ELSE
  SET print_time_ampm = cnvtupper(concat(print_time," AM"))
 ENDIF
 CALL echo("***")
 CALL echo(build("***   print_time_ampm :",print_time_ampm))
 CALL echo("***")
 IF (curutc > 0)
  SET offset = 0
  SET daylight = 0
  SET utclabel = datetimezonebyindex(curtimezoneapp,offset,daylight,7,drec->app_dt_tm)
  SET print_time = concat(print_time," ",utclabel)
  SET print_time_ampm = concat(print_time_ampm," ",utclabel)
 ENDIF
 CALL echo("***")
 CALL echo(build("***   print_time      :",print_time))
 CALL echo(build("***   print_time_ampm :",print_time_ampm))
 CALL echo("***")
 FREE SET offset
 FREE SET daylight
 FREE SET utclabel
 SET report_title = concat("PROVIDE : PRSNL CHART AUDIT")
 SELECT INTO "nl:"
  position = uar_get_code_display(p.position_cd)
  FROM prsnl p
  WHERE (p.person_id=request->person_id)
   AND p.active_ind=1
  DETAIL
   person->prsnl_id = p.person_id, person->prsnl_name = p.name_full_formatted, person->position =
   position,
   CALL echo(build("prsnl : ",person->prsnl_name," : ",person->position))
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  ppa_type_mean = uar_get_code_display(ppa.ppa_type_cd), relation = uar_get_code_display(pl
   .person_prsnl_r_cd)
  FROM person_prsnl_activity ppa,
   person p,
   dummyt d,
   person_prsnl_reltn pl
  PLAN (ppa
   WHERE (ppa.prsnl_id=request->person_id)
    AND ppa.active_ind=1)
   JOIN (p
   WHERE ppa.person_id=p.person_id
    AND p.active_ind=1)
   JOIN (d)
   JOIN (pl
   WHERE pl.person_id=ppa.prsnl_id)
  ORDER BY p.person_id, ppa.ppa_last_dt_tm DESC
  HEAD REPORT
   count1 = 0
  HEAD p.person_id
   count1 = (count1+ 1), cnt = 0
   IF (mod(count1,10)=1)
    stat = alterlist(reply1->person,(count1+ 10))
   ENDIF
   reply1->person[count1].name = p.name_full_formatted, reply1->person[count1].person_id = p
   .person_id, reply1->person[count1].reltn = relation
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply1->person[count1].qual,(cnt+ 10))
   ENDIF
   reply1->person[count1].qual[cnt].ppa_last_dt_tm = cnvtdatetime(ppa.ppa_last_dt_tm), reply1->
   person[count1].qual[cnt].ppa_type_cd = ppa.ppa_type_cd, reply1->person[count1].qual[cnt].
   ppa_type_mean = ppa_type_mean,
   reply1->person[count1].qual[cnt].ppa_comment = ppa.ppa_comment, reply1->person[count1].qual[cnt].
   view_caption = ppa.view_caption, reply1->person[count1].qual[cnt].computer_name = ppa
   .computer_name,
   reply1->person[count1].qual[cnt].ppa_id = ppa.ppa_id,
   CALL echo(build("PPA : ",reply1->person[count1].name," : ",reply1->person[count1].qual[cnt].
    ppa_comment," : ",
    reply1->person[count1].qual[cnt].ppa_last_dt_tm," : ",reply1->person[count1].qual[cnt].
    ppa_type_mean," : ",reply1->person[count1].qual[cnt].ppa_id))
  FOOT  p.person_id
   reply1->person[count1].qual_cnt = cnt, stat = alterlist(reply1->person[count1].qual,cnt),
   CALL echo(build(reply1->person[count1].qual_cnt))
  FOOT REPORT
   reply1->person_cnt = count1, stat = alterlist(reply1->person,count1),
   CALL echo(build("cnt : ",reply1->person[count1].qual_cnt," : ",reply1->person_cnt))
  WITH nocounter, outerjoin = d
 ;end select
 SET ierrcode = 0
 SET cdf_meaning = "MRN"
 SET code_set = 4
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_cd = code_value
 SELECT INTO "nl:"
  p.seq, mrn = cnvtalias(p.alias,p.alias_pool_cd)
  FROM person_alias p,
   (dummyt d  WITH seq = value(size(reply1->person,5)))
  PLAN (d
   WHERE d.seq > 0)
   JOIN (p
   WHERE (p.person_id=reply1->person[d.seq].person_id)
    AND p.person_alias_type_cd=mrn_cd
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  HEAD REPORT
   reply1->person[d.seq].mrn = mrn,
   CALL echo(build("mrn : ",reply1->person[d.seq].mrn))
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET reply1->person[d.seq].mrn = ""
 ENDIF
 SET dvar = 0
 SET prsnl_name = person->prsnl_name
 SET position = person->position
 SET prsnl_id = person->prsnl_id
 CALL echo(build("PERSON : ",name," : ",position))
 SELECT INTO value(output_file)
  dvar
  HEAD REPORT
   max_row = 43, row_count = 0, new_row = 0,
   page_cnt = 1, page_break = fillstring(01,"N"), last_page = fillstring(01,"Y"),
   MACRO (print_page_template)
    "{f/0/1}{cpi/14^}{lpi/8}", row + 1, "{color/31/1}",
    "{pos/065/20}{box/093/2/1}", row + 1, "{color/30/1}",
    "{pos/095/47}{box/080/4/1}", row + 1, "{color/31/1}",
    "{pos/095/47}{box/080/4/1}", row + 1
    IF (last_page="Y")
     "{color/31/1}", "{pos/035/110}{box/103/65/1}", row + 1,
     "{color/31/1}", "{pos/065/720}{box/93/2/1}", row + 1
    ELSE
     "{color/31/1}", "{pos/035/110}{box/103/72/1}", row + 1
    ENDIF
    "{f/5/1}{cpi/5^}{lpi/3}", "{pos/000/10}", row + 1,
    col 20, report_title, row + 1,
    "{f/0/1}{cpi/16^}{lpi/6}", row + 1, "{pos/000/043}",
    row + 1, col 40, "Personnel Name :   ",
    col 80, prsnl_name, row + 1,
    col 40, "Personnel Id :  ", col 80,
    prsnl_id, row + 1, col 40,
    "Position : ", col 80, position,
    row + 1, print_dt_tm = concat(format(datetimezone(datetimezone(cnvtdatetime(curdate,curtime3),
        curtimezonesys,2),curtimezoneapp),"mm/dd/yy hh:mm;;q")," ",datetimezonebyindex(curtimezoneapp
      )), "{pos/000/715}",
    row + 1, col 015, "Print_by :  ",
    row + 1, col 015, "Printed :  ",
    print_dt_tm, col 058
    IF (page_cnt=total_pages)
     "(end of report)"
    ELSE
     "  (continued)   "
    ENDIF
    page_cnt_line = concat("Page ",format(trim(cnvtstring(page_cnt)),"###;R")," of ",format(trim(
       cnvtstring(total_pages)),"###;R")),
    CALL echo(" "),
    CALL echo(build("Printing Page Format page_cnt :",page_cnt,"  total_pages :",total_pages)),
    CALL echo(" "), col 100, page_cnt_line,
    row + 1, "{pos/000/105}", row + 1
   ENDMACRO
   ,
   MACRO (row_counter)
    row_count = (row_count+ 1)
    IF (row_count > max_row)
     CALL echo(" "),
     CALL echo("row_counter BREAKING PAGE"),
     CALL echo(" "),
     BREAK, page_cnt = (page_cnt+ 1), print_page_template,
     row_count = 0, page_break = "Y"
    ELSE
     page_break = "N"
    ENDIF
   ENDMACRO
   ,
   MACRO (row_check)
    IF (((row_count+ new_row) > max_row))
     BREAK,
     CALL echo(" "),
     CALL echo("row_check BREAKING PAGE"),
     CALL echo(" "), page_cnt = (page_cnt+ 1), print_page_template,
     row_count = 0, page_break = "Y"
    ELSE
     page_break = "N"
    ENDIF
   ENDMACRO
   ,
   MACRO (dummy_row_counter)
    row_count = (row_count+ 1)
    IF (row_count > max_row)
     page_cnt = (page_cnt+ 1), row_count = 0, page_break = "Y"
    ELSE
     total_pages = page_cnt, page_break = "N"
    ENDIF
   ENDMACRO
   ,
   MACRO (dummy_row_check)
    IF (((row_count+ new_row) > max_row))
     page_cnt = (page_cnt+ 1), row_count = 0, page_break = "Y"
    ELSE
     page_break = "N"
    ENDIF
   ENDMACRO
   ,
   MACRO (find_page_cnt)
    avail_rows = max_row, new_row = 3, dummy_row_check,
    dummy_row_counter, dummy_row_counter
    IF ((reply1->person_cnt < 1))
     dummy_row_counter, dummy_row_counter
    ELSE
     FOR (i = 1 TO reply1->person_cnt)
       new_row = 1, dummy_row_check
       IF (page_break="Y")
        dummy_row_counter
       ENDIF
       dummy_row_counter
       IF ((reply1->person[i].qual_cnt < 1))
        dummy_row_counter
       ELSE
        FOR (index = 1 TO reply1->person[i].qual_cnt)
          new_row = 1, dummy_row_check
          IF (page_break="Y")
           dummy_row_counter, dummy_row_counter
          ENDIF
          dummy_row_counter
          IF (page_break="Y")
           dummy_row_counter, dummy_row_counter
          ENDIF
        ENDFOR
       ENDIF
     ENDFOR
    ENDIF
    CALL echo(" "),
    CALL echo(build("Found total_pages :",total_pages,"  page_cnt :",page_cnt)),
    CALL echo(" ")
   ENDMACRO
   ,
   MACRO (print_body)
    new_row = 3, row_check, row + 1,
    row_counter
    IF ((reply1->person_cnt < 1))
     row + 1, col 006, "{f/1/1}{cpi/16^}{lpi/6}",
     "{color/19/120/07}", "PPA ID ", col 15,
     "Review Date", col 45, "Activity",
     col 70, "Location", col 85,
     "Comment", "{f/0/1}{cpi/16^}{lpi/6}", row + 1,
     row_counter, col 010, "No Patients are found",
     row + 1, row_counter
    ELSE
     FOR (i = 1 TO value(size(reply1->person,5)))
       person_id = reply1->person[i].person_id, name = substring(1,20,reply1->person[i].name), reltn
        = substring(1,12,reply1->person[i].reltn),
       mrn = reply1->person[i].mrn, prsnl = concat("Patient Name : ",trim(name),"  Id : ",trim(
         cnvtstring(person_id)),"   MRN : ",
        trim(mrn),"  Relation with Patient : ",trim(reltn)),
       CALL echo(prsnl),
       new_row = 1, row_check
       IF (page_break="Y")
        row + 1, row_counter, col 008,
        "{f/1/1}{cpi/16^}{lpi/6}", "{color/19/120/07}", prsnl,
        row + 2, row_counter, col 8,
        "PPA ID ", col 15, "Review Date",
        col 45, "Activity", col 70,
        "Location", col 85, "Comment"
       ELSE
        IF (i < 2)
         row + 1, row_counter, col 008,
         "{f/1/1}{cpi/16^}{lpi/6}", "{color/19/120/07}", prsnl,
         row + 2, row_counter, col 8,
         "PPA ID ", col 15, "Review Date",
         col 45, "Activity", col 70,
         "Location       ", col 85, "Comment"
        ELSE
         row + 1, row_counter, col 008,
         "{f/1/1}{cpi/16^}{lpi/6}", "{color/19/120/07}", prsnl,
         row + 2, row_counter, col 8,
         "PPA ID ", col 15, "Review Date",
         col 45, "Activity", col 70,
         "Location       ", col 85, "Comment"
        ENDIF
       ENDIF
       "{f/0/1}{cpi/16^}{lpi/6}", row + 1, row_counter
       IF ((reply1->person[i].qual_cnt < 1))
        col 010, "No Activity are found For this patient", row + 1,
        row_counter
       ELSE
        FOR (j = 1 TO value(size(reply1->person[i].qual,5)))
          ppa_id = cnvtstring(reply1->person[i].qual[j].ppa_id), date = format(cnvtdatetime(reply1->
            person[i].qual[j].ppa_last_dt_tm),"mm/dd/yy hh:mm:ss;;q")
          IF ((reply1->person[i].qual[j].ppa_type_mean > ""))
           activity = substring(1,20,reply1->person[i].qual[j].ppa_type_mean)
          ELSE
           activity = "----"
          ENDIF
          IF ((reply1->person[i].qual[j].ppa_comment > " "))
           comment = substring(1,12,reply1->person[i].qual[j].ppa_comment)
          ELSE
           comment = "----"
          ENDIF
          IF ((reply1->person[i].qual[j].computer_name > ""))
           location = reply1->person[i].qual[j].computer_name
          ELSE
           location = "----"
          ENDIF
          new_row = 1, row_check
          IF (page_break="Y")
           row_counter, row + 1, row_counter,
           col 008, "{f/1/1}{cpi/16^}{lpi/6}", "{color/19/118/07}",
           prsnl, row + 2, row_counter,
           col 8, "PPA ID ", col 15,
           "Review Date", col 45, "Activity",
           col 70, "Location       ", col 85,
           "Comment", "{f/0/1}{cpi/16^}{lpi/6}", row + 1,
           row_counter
          ENDIF
          col 006, ppa_id, col 15,
          date, col 45, activity,
          col 70, location, col 85,
          comment, row + 1, row_counter
          IF (page_break="Y")
           row + 1, row_counter, col 008,
           "{f/1/1}{cpi/16^}{lpi/6}", "{color/19/120/07}", prsnl,
           row + 2, row_counter, col 8,
           "PPA ID ", col 15, "Review Date",
           col 45, "Activity", col 70,
           "Location       ", col 85, "Comment",
           "{f/0/1}{cpi/16^}{lpi/6}", row + 1, row_counter
          ENDIF
        ENDFOR
       ENDIF
     ENDFOR
    ENDIF
    CALL echo(" "),
    CALL echo(build("End of chart audit page_cnt :",page_cnt,"  row_count :",row_count)),
    CALL echo(" ")
   ENDMACRO
   ,
   MACRO (print_no_data)
    row + 1, col 7, "{f/1/1}",
    "No personel access this patient information", row + 1
   ENDMACRO
   , find_page_cnt,
   row_count = 0, new_row = 0, page_cnt = 1,
   print_page_template
   IF (size(reply1->person,5) > 0)
    print_body
   ELSE
    print_no_data
   ENDIF
  WITH check, nocounter, nullreport,
   maxrow = 150, maxcol = 255, dio = postscript
 ;end select
 FREE SET reply
 RECORD reply(
   1 person_id = f8
   1 encntr_id = f8
   1 output_file = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->person_id = person_id
 SET reply->encntr_id = encntr_id
 SET reply->output_file = concat("ccluserdir:",trim(output_file),".dat")
 SET reply->status_data.status = "S"
 FREE SET person
 FREE SET reply1
 SET trace = norecpersist
 CALL echo(build("reply->person_id    :",reply->person_id))
 CALL echo(build("reply->encntr_id    :",reply->encntr_id))
 CALL echo(build("reply->output_file  :",reply->output_file,"***"))
#quit_script
END GO
