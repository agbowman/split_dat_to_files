CREATE PROGRAM ch_submit_gamma:dba
 RECORD reply(
   1 qual[1]
     2 line = c170
   1 output_filename = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 DECLARE date_time_format = vc WITH constant("MM/dd/yyyy HH:mm:ss ZZZ")
 DECLARE current_date_time = q8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE current_date_time_str = vc WITH noconstant(""), protect
 IF (curutc)
  SET current_date_time_str = datetimezoneformat(cnvtdatetime(current_date_time),curtimezoneapp,
   date_time_format)
 ELSE
  SET current_date_time_str = datetimezoneformat(cnvtdatetime(current_date_time),curtimezoneapp,
   date_time_format,curtimezonesys)
 ENDIF
 SET reply->status_data.status = "F"
 SET dist_count = 0
 SET pat_count = 0
 SET pat_dist_count = 0
 SET cr_clause = fillstring(300," ")
 SET cd_clause = fillstring(300," ")
 SET a = "(cr.request_type = 4 or (cr.request_type = 2 and cr.mcis_ind = 1)) and "
 SET b =
 "cr.dist_run_dt_tm >= CNVTDATETIME(request->start_dt_tm) and cr.dist_run_dt_tm <= CNVTDATETIME(request->end_dt_tm)"
 SET d =
 "cr.distribution_id = request->distribution_id and 0=datetimecmp(cr.dist_run_dt_tm,cnvtdatetime(CURRENT_DATE_TIME))"
 SET f =
 "cr.distribution_id = request->distribution_id and cr.dist_run_dt_tm >= CNVTDATETIME(request->start_dt_tm) and "
 SET g = "cr.dist_run_dt_tm <= CNVTDATETIME(request->end_dt_tm)"
 SET i =
 "cr.distribution_id = request->distribution_id and cr.dist_run_dt_tm = CNVTDATETIME(request->start_dt_tm)"
 SET j = "cd.distribution_id = cr.distribution_id"
 SET k = " and cd.distribution_id = request->distribution_id"
 SET code_value = 0
 SET code_set = 319
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_code_value = code_value
 CASE (request->switch)
  OF 1:
   SET cr_clause = concat(a,b)
   SET cd_clause = j
  OF 2:
   SET cr_clause = concat(a,"datetimecmp(cr.dist_run_dt_tm,cnvtdatetime(CURRENT_DATE_TIME)) = 0")
   SET cd_clause = j
  OF 3:
   SET cr_clause = concat(a,"0 = datetimecmp(cr.dist_run_dt_tm,cnvtdatetime(CURRENT_DATE_TIME))")
   SET cd_clause = j
  OF 4:
   SET cr_clause = concat(a,"0 = datetimecmp(cr.dist_run_dt_tm,cnvtdatetime(CURRENT_DATE_TIME))")
   SET cd_clause = concat(j,k)
  OF 5:
   SET cr_clause = concat(a,d)
   SET cd_clause = concat(j,k)
  OF 6:
   SET cr_clause = concat(a,f,g)
   SET cd_clause = concat(j,k)
  OF 7:
   SET cr_clause = concat(a,i)
   SET cd_clause = concat(j,k)
 ENDCASE
 CALL echo(build("Switch:",request->switch))
 CALL echo(curtime)
 CALL echo(cr_clause)
 CALL echo(cd_clause)
 CALL echo(build("dist_id =",request->distribution_id))
 CALL echo(build("start =",datetimezoneformat(cnvtdatetime(request->start_dt_tm),curtimezoneapp,
    date_time_format,curtimezonesys)))
 CALL echo(build("end =",datetimezoneformat(cnvtdatetime(request->end_dt_tm),curtimezoneapp,
    date_time_format,curtimezonesys)))
 CALL echo(build("current date =",current_date_time_str))
 SET outfile = fillstring(100," ")
 SET outfile = build("dist_journal",cnvtstring(curtime3))
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
 DECLARE h = i4
 DECLARE i18nhandle = i4 WITH noconstant(0)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE tempstr = vc WITH noconstant("")
 DECLARE tempstrperson = vc WITH constant(uar_i18ngetmessage(i18nhandle,"PERSON_ID","Person ID"))
 DECLARE tempstrencntr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ENCOUNTER_ID","Encounter ID"
   ))
 DECLARE tempstraccn = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ACCN_NUMBER","Accession #"))
 DECLARE tempstrorder = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ORDER_ID","Order #"))
 SELECT DISTINCT INTO value(outfile)
  cd.distribution_id, cd.dist_descr, cf.chart_format_id,
  cf.chart_format_desc, cr.request_type, dist_run_dt_tm_str =
  IF (curutc) datetimezoneformat(cnvtdatetime(cr.dist_run_dt_tm),curtimezoneapp,date_time_format)
  ELSE datetimezoneformat(cnvtdatetime(cr.dist_run_dt_tm),curtimezoneapp,date_time_format,
    curtimezonesys)
  ENDIF
  ,
  encntr_id = format(cr.encntr_id,"##########.##;L"), accession_number = uar_fmt_accession(cr
   .accession_nbr,size(cr.accession_nbr,1)), order_id = format(cr.order_id,"##########.##;L"),
  cr.scope_flag, cr.chart_request_id, pages = format(cr.total_pages,"#####;L"),
  dist_run_type = uar_get_code_display(cr.dist_run_type_cd), patient_type = uar_get_code_display(e
   .encntr_type_cd), nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd),
  room = uar_get_code_display(e.loc_room_cd), bed = uar_get_code_display(e.loc_bed_cd),
  output_description = od.name,
  person_id = format(p.person_id,"##########.##;L"), p.name_full_formatted, ea.encntr_alias_type_cd,
  o.org_name
  FROM chart_request cr,
   chart_distribution cd,
   chart_format cf,
   encounter e,
   organization o,
   output_dest od,
   person p,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1),
   encntr_alias ea
  PLAN (cr
   WHERE parser(cr_clause))
   JOIN (cf
   WHERE cf.chart_format_id=cr.chart_format_id)
   JOIN (p
   WHERE p.person_id=cr.person_id)
   JOIN (cd
   WHERE parser(cd_clause))
   JOIN (e
   WHERE e.encntr_id=cr.encntr_id)
   JOIN (o
   WHERE o.organization_id=e.organization_id)
   JOIN (d1)
   JOIN (od
   WHERE od.output_dest_cd=cr.output_dest_cd)
   JOIN (d2)
   JOIN (ea
   WHERE ea.encntr_id=cr.encntr_id
    AND mrn_code_value=ea.encntr_alias_type_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(current_date_time)
    AND ea.end_effective_dt_tm > cnvtdatetime(current_date_time))
  ORDER BY cr.request_dt_tm, cr.dist_run_dt_tm, cr.dist_run_type_cd,
   cr.chart_request_id
  HEAD REPORT
   line1 = fillstring(165,"*"), pat_count = 0, last_pat = 0,
   dist_count = 0, row 1, tempstr = uar_i18ngetmessage(i18nhandle,"DIST_JOURNAL_SUMMARY",
    "D I S T R I B U T I O N  J O U R N A L"),
   CALL center(tempstr,0,160), tempstr = uar_i18ngetmessage(i18nhandle,"PAGE","PAGE:"), col 140,
   tempstr, col + 2, curpage"###",
   row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"PRINT_DATE_TIME","Print Date/Time:"), col 1,
   tempstr, col + 2, current_date_time_str,
   row + 2, line1
  HEAD PAGE
   IF (curpage > 1)
    row 1, tempstr = uar_i18ngetmessage(i18nhandle,"PAGE","PAGE:"), col 140,
    tempstr, col + 2, curpage"###",
    row + 1
   ENDIF
  HEAD cr.dist_run_dt_tm
   do_nothing = 0
  HEAD cr.dist_run_type_cd
   pat_dist_count = 0, row + 2, tempstr = uar_i18ngetmessage(i18nhandle,"DIST_LABEL","Distribution:"),
   col 1, tempstr, col + 2,
   CALL print(substring(1,50,cd.dist_descr)), tempstr = uar_i18ngetmessage(i18nhandle,
    "DIST_RUN_DATE_TIME","Run Date/Time:"), col 110,
   tempstr, col + 2,
   CALL print(substring(1,25,dist_run_dt_tm_str)),
   row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"CHART_FORMAT","Chart Format:"), col 1,
   tempstr, col + 2,
   CALL print(substring(1,50,cf.chart_format_desc)),
   tempstr = uar_i18ngetmessage(i18nhandle,"DIST_RUN_TYPE","Run Type:"), col 110, tempstr,
   col + 2, dist_run_type, row + 2,
   tempstr = uar_i18ngetmessage(i18nhandle,"PATIENT_NAME","NAME"), col 1, tempstr,
   tempstr = uar_i18ngetmessage(i18nhandle,"PRINTER","PRINTER"), col 42, tempstr,
   tempstr = uar_i18ngetmessage(i18nhandle,"PAGES","PAGES"), col 59, tempstr,
   tempstr = uar_i18ngetmessage(i18nhandle,"PATIENT_TYPE","PT. TYPE"), col 65, tempstr,
   col 92
   IF (cr.scope_flag=1)
    tempstrperson
   ELSEIF (cr.scope_flag=2)
    tempstrencntr
   ELSEIF (cr.scope_flag=4)
    tempstraccn
   ELSEIF (cr.scope_flag=3)
    tempstrorder
   ENDIF
   tempstr = uar_i18ngetmessage(i18nhandle,"ORGANIZATION","ORG"), col 115, tempstr,
   tempstr = uar_i18ngetmessage(i18nhandle,"UNIT_ROOM_BED","UNIT/ROOM/BED"), col 141, tempstr,
   row + 1, last_pat = p.person_id
  DETAIL
   pat_count = (pat_count+ 1), pat_dist_count = (pat_dist_count+ 1), row + 1,
   col 1,
   CALL print(substring(1,40,p.name_full_formatted)), col 42,
   CALL print(substring(1,15,output_description)), col 59,
   CALL print(pages),
   col 65,
   CALL print(substring(1,25,patient_type)), col 92
   IF (cr.scope_flag=1)
    CALL print(person_id)
   ELSEIF (cr.scope_flag=2)
    CALL print(encntr_id)
   ELSEIF (cr.scope_flag=4)
    CALL print(substring(1,22,accession_number))
   ELSEIF (cr.scope_flag=3)
    CALL print(order_id)
   ENDIF
   col 115,
   CALL print(substring(1,25,o.org_name)), col 141,
   CALL print(concat(trim(substring(1,15,nurse_unit)),"/",trim(substring(1,10,room)),"/",trim(
     substring(1,3,bed)))), last_pat = p.person_id
  FOOT  cr.dist_run_type_cd
   row + 2, tempstr = uar_i18ngetmessage(i18nhandle,"NUMBER_OF_CHARTS","NUMBER OF CHARTS"), col 1,
   tempstr, col + 2, pat_dist_count"#####",
   row + 2, line1
  FOOT  cr.dist_run_dt_tm
   dist_count = (dist_count+ 1)
  FOOT  cd.dist_descr
   row + 2
  FOOT REPORT
   row + 3, tempstr = uar_i18ngetmessage(i18nhandle,"TOTAL_DISTRIBUTIONS","TOTAL # OF DISTRIBUTIONS:"
    ), col 1,
   tempstr, col + 2, dist_count"#####",
   row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"TOTAL_CHARTS","TOTAL # OF CHARTS:"), col 1,
   tempstr, col + 2, pat_count"#####",
   row + 1
  WITH outerjoin = d1, outerjoin = d2, maxcol = 170,
   maxrow = 40, compress, landscape
 ;end select
 CALL echo(build("Curqual:",curqual))
 SET outfile1 = fillstring(150," ")
 SET outfile1 = build("ccluserdir:",outfile)
 FREE DEFINE rtl2
 DEFINE rtl2 value(outfile1)
 SELECT INTO "nl:"
  r.line
  FROM rtl2t r
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1), stat = alter(reply->qual,count1), reply->qual[count1].line = r.line
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
  SET reply->output_filename = build(outfile1,".dat")
 ELSE
  SET reply->status_data.status = "Z"
  SET reply->output_filename = ""
 ENDIF
END GO
