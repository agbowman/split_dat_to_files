CREATE PROGRAM cps_rpt_driver:dba
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
 FREE SET reply
 RECORD reply(
   1 file_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET program_name = fillstring(30," ")
 SET file_name = fillstring(30," ")
 DECLARE output_file = vc WITH public, noconstant("")
 FREE SET person_info
 RECORD person_info(
   1 list_knt = i4
   1 list[*]
     2 person_id = f8
     2 name = vc
     2 birthdate = vc
     2 mrn = vc
     2 w_phone = vc
     2 h_phone = vc
     2 address = vc
     2 city = vc
     2 state = vc
     2 zip = vc
     2 result = vc
     2 action = vc
     2 description = vc
     2 status = vc
     2 req_by = vc
     2 req_date = vc
 )
 SET username = fillstring(50," ")
 SET printer_name = fillstring(25," ")
 SET dvar = 0
 SET title_line = fillstring(83," ")
 SET max_items_on_page = 8
 SET total_persons = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET code_set = 0
 SET home_add_cd = 0.0
 SET home_ph_cd = 0.0
 SET work_ph_cd = 0.0
 SET mrn_cd = 0.0
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
 IF ((request->report_name > " "))
  SET report_title = format(trim(substring(1,35,request->report_name)),
   "###################################;C;C")
  SET title_line = concat("PCO Print Request      ",report_title,"  ",print_time_ampm)
 ELSE
  SET report_title = format(trim(substring(1,35,"Unknown Report")),
   "###################################;C;C")
  SET title_line = concat("PCO Print Request      ",report_title,"  ",print_time_ampm)
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  p.updt_dt_tm
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id=reqinfo->updt_id)
    AND p.active_ind > 0
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY cnvtdatetime(p.updt_dt_tm) DESC
  HEAD REPORT
   username = p.username, printer_name = p.name_full_formatted
  WITH nocounter
 ;end select
 IF (curqual < 0)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "PRSNL"
   GO TO exit_script
  ELSE
   SET username = "UNKNOWN"
   SET printer_name = "UNKNOWN"
  ENDIF
 ENDIF
 EXECUTE cpm_create_file_name "ibx", "dat"
 SET output_file = cpm_cfn_info->file_name_path
 SET output_file = substring(1,(findstring(".",output_file) - 1),output_file)
 CALL echo("***")
 CALL echo(build("***   output_file :",output_file))
 CALL echo("***")
 SET ierrcode = 0
 SET cdf_meaning = "HOME"
 SET code_set = 212
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET home_add_cd = code_value
 IF (code_value < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Error finding cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(cnvstring(
     code_set)))
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 SET cdf_meaning = "HOME"
 SET code_set = 43
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET home_ph_cd = code_value
 IF (code_value < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Error finding cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(cnvstring(
     code_set)))
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 SET cdf_meaning = "BUSINESS"
 SET code_set = 43
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET work_ph_cd = code_value
 IF (code_value < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Error finding cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(cnvstring(
     code_set)))
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 SET cdf_meaning = "MRN"
 SET code_set = 4
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_cd = code_value
 IF (code_value < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Error finding cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(cnvstring(
     code_set)))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  d1.seq, a.address_id, a.updt_dt_tm,
  state_disp = uar_get_code_display(a.state_cd), ph.phone_id, ph.updt_dt_tm,
  phone_num = cnvtalias(ph.phone_num,ph.phone_format_cd), pa.person_alias_id, pa.updt_dt_tm,
  mrn = cnvtalias(pa.alias,pa.alias_pool_cd)
  FROM (dummyt d1  WITH seq = value(request->qual_knt)),
   person p,
   (dummyt d2  WITH seq = 1),
   address a,
   (dummyt d3  WITH seq = 1),
   phone ph,
   (dummyt d4  WITH seq = 1),
   person_alias pa
  PLAN (d1
   WHERE d1.seq > 0)
   JOIN (p
   WHERE (p.person_id=request->qual[d1.seq].id))
   JOIN (d2)
   JOIN (a
   WHERE a.parent_entity_id=p.person_id
    AND a.parent_entity_name="PERSON"
    AND a.address_type_cd=home_add_cd
    AND a.active_ind > 0
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d3)
   JOIN (ph
   WHERE ph.parent_entity_id=p.person_id
    AND ph.parent_entity_name="PERSON"
    AND ph.phone_type_cd IN (home_ph_cd, work_ph_cd)
    AND ph.active_ind > 0
    AND ph.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ph.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d4)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=mrn_cd
    AND pa.active_ind > 0
    AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY d1.seq, cnvtdatetime(a.updt_dt_tm) DESC, cnvtdatetime(ph.updt_dt_tm) DESC,
   cnvtdatetime(pa.updt_dt_tm) DESC
  HEAD REPORT
   knt = 0, stat = alterlist(person_info->list,10), master_mrn = fillstring(200," ")
  HEAD d1.seq
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(person_info->list,(knt+ 9))
   ENDIF
   person_info->list[knt].person_id = p.person_id, person_info->list[knt].name = p
   .name_full_formatted, person_info->list[knt].birthdate = format(cnvtdatetime(p.birth_dt_tm),
    "mm/dd/yy;;d"),
   person_info->list[knt].result = request->qual[d1.seq].result, person_info->list[knt].action =
   request->qual[d1.seq].action, person_info->list[knt].description = request->qual[d1.seq].
   description,
   person_info->list[knt].status = request->qual[d1.seq].status, person_info->list[knt].req_by =
   request->qual[d1.seq].req_by, person_info->list[knt].req_date = request->qual[d1.seq].req_date,
   add_knt = 0, home_ph_knt = 0, work_ph_knt = 0,
   mrn_knt = 0
  HEAD a.address_id
   IF (add_knt < 1)
    person_info->list[knt].address = a.street_addr, person_info->list[knt].city = a.city, person_info
    ->list[knt].state = state_disp,
    person_info->list[knt].zip = a.zipcode, add_knt = (add_knt+ 1)
   ENDIF
  HEAD ph.phone_id
   IF (ph.phone_type_cd=home_ph_cd
    AND home_ph_knt < 1)
    person_info->list[knt].h_phone = ph.phone_num, home_ph_knt = (home_ph_knt+ 1)
   ENDIF
   IF (ph.phone_type_cd=work_ph_cd
    AND work_ph_knt < 1)
    person_info->list[knt].w_phone = phone_num, work_ph_knt = (work_ph_knt+ 1)
   ENDIF
  HEAD pa.person_alias_id
   IF (mrn_knt < 1)
    master_mrn = mrn, mrn_knt = (mrn_knt+ 1)
   ENDIF
   IF (master_mrn > " ")
    person_info->list[knt].mrn = mrn
   ELSE
    person_info->list[knt].mrn = " "
   ENDIF
  FOOT REPORT
   person_info->list_knt = knt, stat = alterlist(person_info->list,knt)
  WITH nocounter, outerjoin = d2, outerjoin = d3,
   outerjoin = d4
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "PERSON"
  GO TO exit_script
 ENDIF
 SET reply->file_name = trim(output_file)
 CALL echo("***")
 CALL echo(build("***   output_file :",output_file))
 CALL echo("***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO value(trim(output_file))
  dvar
  HEAD REPORT
   nbr_of_pages = 0, last_page = false, max_rows = 53,
   cur_page_row_knt = 0,
   MACRO (find_total_pages)
    total_pages = (person_info->list_knt/ max_items_on_page)
    IF (mod(person_info->list_knt,max_items_on_page) > 0)
     total_pages = (total_pages+ 1)
    ENDIF
   ENDMACRO
   ,
   MACRO (print_page_template)
    "{f/1/1}{cpi/11^}{b}{lpi/7}", "{pos/000/000}", row + 2,
    nbr_line = concat("12345678901234567890123456789012345678901234567890",
     "12345678901234567890123456789012345678901234567890"), row + 1, col 4,
    title_line, row + 1, col 4,
    "Printed by", col + 1, printer_name,
    page_stamp = concat("Page ",trim(cnvtstring(nbr_of_pages))," of ",trim(cnvtstring(total_pages))),
    col 72, page_stamp,
    col + 0, "{f/0/1}{cpi/15^}{lpi/8}", row + 2,
    col 4, "{u/113/5}{endb}", col + 1
   ENDMACRO
   ,
   MACRO (print_body)
    items_printed = 0, name = fillstring(20," "), mrn = fillstring(15," "),
    work_phone = fillstring(20," "), home_phone = fillstring(15," "), address = fillstring(25," "),
    city = fillstring(20," "), state = fillstring(4," "), zip = fillstring(10," "),
    result = fillstring(15," "), action = fillstring(16," "), description = fillstring(33," "),
    r_status = fillstring(15," "), req_by = fillstring(20," "), req_date = fillstring(25," ")
    FOR (i = 1 TO person_info->list_knt)
      "{f/0/1}{cpi/15^}{lpi/8}", name = substring(1,20,person_info->list[i].name), mrn = substring(1,
       15,person_info->list[i].mrn),
      birthdate = substring(1,8,person_info->list[i].birthdate), home_phone = substring(1,15,
       person_info->list[i].h_phone), work_phone = substring(1,20,person_info->list[i].w_phone),
      address = substring(1,25,person_info->list[i].address), city = substring(1,20,person_info->
       list[i].city), state = substring(1,4,person_info->list[i].state),
      zip = substring(1,10,person_info->list[i].zip), result = substring(1,15,person_info->list[i].
       result), action = substring(1,16,person_info->list[i].action),
      description = substring(1,33,person_info->list[i].description), r_status = substring(1,15,
       person_info->list[i].status), req_by = substring(1,20,person_info->list[i].req_by),
      req_date = substring(1,25,person_info->list[i].req_date), row + 1, col 5,
      "{BOLD/21/5}", name, col + 2,
      "MRN: ", mrn, col + 2,
      "Birthdate: ", birthdate, col + 2,
      "H: ", home_phone, col + 2,
      "W: ", work_phone, row + 1,
      col 12, "Address: ", address,
      col + 2, "City: ", city,
      col + 2, "State: ", state,
      col + 2, "Zip: ", zip,
      row + 1, col 13, "Result: ",
      result, col + 2, "Action: ",
      action, col + 2, "Descript: ",
      description, row + 1, col 13,
      "Status: ", r_status, col + 2,
      "Requested By: ", req_by, col + 2,
      "Request Date: ", req_date, row + 5,
      col + 0, "{B}", col 5,
      "{u/113/5}", col + 0, "{ENDB}",
      col + 1, items_printed = (items_printed+ 1)
      IF (items_printed=max_items_on_page
       AND (i != person_info->list_knt))
       items_printed = 0, nbr_of_pages = (nbr_of_pages+ 1), BREAK,
       print_page_template, col + 0
      ENDIF
    ENDFOR
   ENDMACRO
   ,
   MACRO (print_no_data)
    "{f/0/1}{cpi/12^}{b}{lpi/8}", col 4, "No persons found",
    row + 1
   ENDMACRO
   , find_total_pages,
   nbr_of_pages = (nbr_of_pages+ 1)
   IF (nbr_of_pages=total_pages)
    last_page = true
   ENDIF
   print_page_template
   IF ((person_info->list_knt > 0))
    print_body
   ELSE
    print_no_data
   ENDIF
  WITH nocounter, nullreport, maxrow = 100,
   maxcol = 150, dio = postscript
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = exe_error
  SET table_name = "REPORT"
  GO TO exit_script
 ENDIF
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
#end_program
 SET script_version = "006 02/13/04 SF3151"
END GO
