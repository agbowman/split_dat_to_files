CREATE PROGRAM dcp_rpt_expired_ceprsnl:dba
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD captions(
   1 hdrpt_title = vc
   1 hdrpt_page = vc
   1 hdrpt_date = vc
   1 hdrpt_rule_param = vc
   1 col_pat_name = vc
   1 col_mrn = vc
   1 col_fin = vc
   1 col_discdt = vc
   1 col_enctype = vc
   1 col_facility = vc
   1 col_location = vc
   1 col_doctype = vc
   1 col_prsnl_name = vc
   1 col_action = vc
   1 col_reqdt = vc
   1 end_of_report = vc
 )
 SET captions->hdrpt_title = trim(uar_i18ngetmessage(i18nhandle,"HDRPT_TITLE",
   "Batch Expiration of Review and Signature Requests"))
 SET captions->hdrpt_page = trim(uar_i18ngetmessage(i18nhandle,"HDPRT_PAGE","Page"))
 SET captions->hdrpt_rule_param = trim(uar_i18ngetmessage(i18nhandle,"HDRPT_RULE_PARAM",
   "Rule Parameters"))
 SET captions->col_pat_name = trim(uar_i18ngetmessage(i18nhandle,"COL_PATIENT_NAME","Patient Name"))
 SET captions->col_mrn = trim(uar_i18ngetmessage(i18nhandle,"COL_MRN","MRN#"))
 SET captions->col_fin = trim(uar_i18ngetmessage(i18nhandle,"COL_FIN","FIN#"))
 SET captions->col_discdt = trim(uar_i18ngetmessage(i18nhandle,"COL_DISCDT","Disch.Dt"))
 SET captions->col_enctype = trim(uar_i18ngetmessage(i18nhandle,"COL_ENCTYPE","Enc. Type"))
 SET captions->col_facility = trim(uar_i18ngetmessage(i18nhandle,"COL_FACILITY","Facility"))
 SET captions->col_doctype = trim(uar_i18ngetmessage(i18nhandle,"COL_DOCTYPE","Doc Type"))
 SET captions->col_prsnl_name = trim(uar_i18ngetmessage(i18nhandle,"COL_PRSNL_NAME","Personnel"))
 SET captions->col_action = trim(uar_i18ngetmessage(i18nhandle,"COL_ACTION","Action"))
 SET captions->col_reqdt = trim(uar_i18ngetmessage(i18nhandle,"COL_REQDT","Request Date"))
 SET captions->end_of_report = trim(uar_i18ngetmessage(i18nhandle,"END_OF_REPORT",
   "** END OF REPORT **"))
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 DECLARE headpage = i2 WITH noconstant
 DECLARE max_length = i4 WITH noconstant
 DECLARE posa = i4 WITH noconstant
 DECLARE posb = i4 WITH noconstant
 DECLARE default_loc = vc WITH constant("cer_temp:")
 DECLARE file_loc = vc WITH noconstant
 DECLARE file_name = vc WITH noconstant
 DECLARE print = vc WITH noconstant
 DECLARE person_name = c30 WITH noconstant
 DECLARE mrn = c12 WITH noconstant
 DECLARE fin_num = c12 WITH noconstant
 DECLARE dis_dt = c8 WITH noconstant
 DECLARE enc_type = c24 WITH noconstant
 DECLARE facility = c24 WITH noconstant
 DECLARE location = c24 WITH noconstant
 DECLARE doc_type = c8 WITH noconstant
 DECLARE prsnl_name = c30 WITH noconstant
 DECLARE action_type = c8 WITH noconstant
 DECLARE req_dt_tm = c16 WITH noconstant
 SET headpage = 0
 SET max_length = 212
 SET pt->line_cnt = 0
 SET reply->status_data.status = "Z"
 SET posa = 0
 SET posb = 0
 SET file_loc = " "
 SET person_name = " "
 SET mrn = " "
 SET fin_num = " "
 SET dis_dt = " "
 SET enc_type = " "
 SET facility = " "
 SET location = " "
 SET doc_type = " "
 SET prsnl_name = " "
 SET action_type = " "
 SET req_dt_tm = " "
 IF (textlen(trim(request->batch_selection)) > 0)
  SET posa = findstring(";",request->batch_selection)
  IF (posa > 1)
   SET file_loc = substring(1,(posa - 1),request->batch_selection)
  ELSE
   SET file_loc = default_loc
  ENDIF
 ELSE
  SET file_loc = default_loc
 ENDIF
 SET file_name = concat(trim(file_loc),"cerpt",trim(format(curdate,"YYMMDD;;D")),trim(format(curtime,
    "hhmmss;;m")),".dat")
 CALL echo(build("PRINTER",file_name))
 EXECUTE dcp_parse_text value(concat("{B}",captions->hdrpt_rule_param,":","{ENDB}"," ",
   request->rule_parameter)), value(max_length)
 SET event_prsnl_list_cnt = cnvtint(size(request->event_prsnl_list,5))
 SELECT INTO value(file_name)
  FROM (dummyt d1  WITH seq = value(event_prsnl_list_cnt)),
   person person,
   prsnl prsnl
  PLAN (d1)
   JOIN (person
   WHERE (person.person_id=request->event_prsnl_list[d1.seq].person_id))
   JOIN (prsnl
   WHERE (prsnl.person_id=request->event_prsnl_list[d1.seq].action_prsnl_id))
  ORDER BY person.name_last_key
  HEAD REPORT
   nbritems = 0
  HEAD PAGE
   col 0, "{PS/792 0 translate 90 rotate/}"
   IF ( NOT (headpage=1))
    row + 1, print = concat("{cpi/20}{B}",captions->hdrpt_title,"{ENDB}"), col 0,
    print, print = " ", print = format(concat("{B}",captions->hdrpt_page,":","{ENDB}"," ",
      format(curpage,"###;P0")),"############################;R"),
    col 200, print, print = " ",
    row + 1
    IF ((request->run_type_flag=0))
     run_mode = "Operations"
    ELSE
     run_mode = "Ad-Hoc"
    ENDIF
    date1 = concat(format(curdate,"@SHORTDATE;;Q")," ",format(curtime3,"@TIMENOSECONDS")), run_prsnl
     = request->run_prsnl_name_full, print = uar_i18nbuildmessage(i18nhandle,"HDRPT_LINE2",
     "{B}Date:{ENDB} %1 {B}Run Mode:{ENDB} %2 {B}Run By:{ENDB} %3 {B}Rows Updated{ENDB} %4",
     "sssi",date1,
     run_mode,run_prsnl,event_prsnl_list_cnt),
    col 0, print, print = " ",
    row + 1
    FOR (xx = 1 TO pt->line_cnt)
      col 0, pt->lns[xx].line, row + 1
    ENDFOR
    headpage = 1
   ELSE
    row + 1, print = format(concat("{B}",captions->hdrpt_page,":","{ENDB}"," ",
      format(curpage,"###;P0")),"############################;R"), col 183,
    print, print = " ", row + 3
   ENDIF
   print = concat("{B}",format(captions->col_pat_name,"###############################;L"),format(
     captions->col_mrn,"#############;L"),format(captions->col_fin,"#############;L"),"{ENDB}"), col
   0, print,
   print = " ", print = concat("{B}",format(captions->col_discdt,"#########;L"),format(captions->
     col_enctype,"#########################;L"),"{ENDB}"), col 66,
   print, print = " ", print = concat("{B}",format(captions->col_facility,
     "#########################;L"),format(captions->col_doctype,"#########;L"),format(captions->
     col_prsnl_name,"###############################;L"),"{ENDB}"),
   col 109, print, print = " ",
   print = concat("{B}",format(captions->col_action,"########;L"),format(captions->col_reqdt,
     "#############;L"),"{ENDB}"), col 184, print,
   print = " "
  DETAIL
   row + 1
   IF (event_prsnl_list_cnt > 0)
    person_name = substring(1,30,person.name_full_formatted), mrn = substring(1,12,request->
     event_prsnl_list[d1.seq].med_rec_num_str), fin_num = substring(1,12,request->event_prsnl_list[d1
     .seq].financial_num_str),
    dis_dt = format(request->event_prsnl_list[d1.seq].discharge_dt_tm,"@SHORTDATE"), enc_type =
    substring(1,24,uar_get_code_display(request->event_prsnl_list[d1.seq].encounter_type_cd)),
    facility = substring(1,24,uar_get_code_display(request->event_prsnl_list[d1.seq].facility_cd)),
    doc_type = substring(1,8,uar_get_code_display(request->event_prsnl_list[d1.seq].event_cd)),
    prsnl_name = substring(1,30,prsnl.name_full_formatted), action_type = substring(1,8,trim(
      uar_get_code_display(request->event_prsnl_list[d1.seq].action_type_cd))),
    req_dt_tm = uar_i18nbuildmessage(i18nhandle,"REQ_DT_TM","%1","s",format(request->
      event_prsnl_list[d1.seq].req_dt_tm,"mm/dd/yyyy HH:MM;;q"))
   ENDIF
   col 0, person_name, col + 1,
   mrn, col + 1, fin_num,
   col + 1, dis_dt, col + 1,
   enc_type, col + 1, facility,
   col + 1, doc_type, col + 1,
   prsnl_name, col + 1, action_type,
   col + 1, req_dt_tm
   IF (((row+ 9) > maxrow))
    BREAK
   ENDIF
  FOOT REPORT
   row + 5,
   CALL center(captions->end_of_report,0,210)
  WITH dio = postscript, maxcol = 240, maxrow = 60,
   nocounter
 ;end select
 CALL echo(build("PRINTER",file_name))
 IF (curqual > 0)
  SET reply->status_data.status = "S"
  IF (textlen(trim(request->output_dist)) > 0)
   SET spool value(file_name) value(request->output_dist) WITH compress
  ENDIF
 ENDIF
 GO TO exit_script
#exit_script
 SET reply->status_data.subeventstatus.operationname = "Print expired CePrsnls"
 SET reply->status_data.subeventstatus.targetobjectname = "Table: prsnl,person"
 SET reply->status_data.subeventstatus.targetobjectvalue = "dcp_rpt_expired_cePrsnl.prg"
 IF ((reply->status_data.status="S"))
  SET reply->status_data.subeventstatus.operationstatus = "S"
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.subeventstatus.operationstatus = "Z"
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
