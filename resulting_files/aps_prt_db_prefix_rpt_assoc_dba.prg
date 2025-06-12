CREATE PROGRAM aps_prt_db_prefix_rpt_assoc:dba
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
 RECORD captions(
   1 apsrpt = vc
   1 pathnetap = vc
   1 date = vc
   1 directory = vc
   1 ttime = vc
   1 refdbaudit = vc
   1 bby = vc
   1 dbprefixrptassoc = vc
   1 ppage = vc
   1 prefix = vc
   1 allow = vc
   1 system = vc
   1 resulttext = vc
   1 requiredheading = vc
   1 optionalheading = vc
   1 rreport = vc
   1 primary = vc
   1 multiple = vc
   1 oorder = vc
   1 ffont = vc
   1 ssize = vc
   1 yes = vc
   1 no = vc
   1 notspecified = vc
   1 override_parameters = vc
   1 prefixnoassoc = vc
   1 prefixdescription = vc
   1 refertotool = vc
   1 continued = vc
 )
 SET captions->apsrpt = uar_i18ngetmessage(i18nhandle,"h1","REPORT:  APS_PRT_DB_PREFIX_RPT_ASSOC.PRG"
  )
 SET captions->pathnetap = uar_i18ngetmessage(i18nhandle,"h2","PATHNET AUTOMATION PATHOLOGY")
 SET captions->date = uar_i18ngetmessage(i18nhandle,"h3","DATE:")
 SET captions->directory = uar_i18ngetmessage(i18nhandle,"h4","DIRECTORY:")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"h5","TIME:")
 SET captions->refdbaudit = uar_i18ngetmessage(i18nhandle,"h6","REFERENCE DATABASE AUDIT")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"h7","BY:")
 SET captions->dbprefixrptassoc = uar_i18ngetmessage(i18nhandle,"h8",
  "DB PREFIX REPORT ASSOCIATIONS TOOL")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"h9","PAGE:")
 SET captions->prefix = uar_i18ngetmessage(i18nhandle,"h10","PREFIX:")
 SET captions->allow = uar_i18ngetmessage(i18nhandle,"h11","ALLOW")
 SET captions->system = uar_i18ngetmessage(i18nhandle,"h12","SYSTEM")
 SET captions->resulttext = uar_i18ngetmessage(i18nhandle,"h13","RESULT TEXT")
 SET captions->requiredheading = uar_i18ngetmessage(i18nhandle,"h14","REQUIRED HEADING")
 SET captions->optionalheading = uar_i18ngetmessage(i18nhandle,"h15","OPTIONAL HEADING")
 SET captions->rreport = uar_i18ngetmessage(i18nhandle,"h16","REPORT")
 SET captions->primary = uar_i18ngetmessage(i18nhandle,"h17","PRIMARY")
 SET captions->multiple = uar_i18ngetmessage(i18nhandle,"h18","MULTIPLE")
 SET captions->oorder = uar_i18ngetmessage(i18nhandle,"h19","ORDER")
 SET captions->ffont = uar_i18ngetmessage(i18nhandle,"h20","FONT")
 SET captions->ssize = uar_i18ngetmessage(i18nhandle,"h21","SIZE")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"h22","YES")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"h23","NO")
 SET captions->notspecified = uar_i18ngetmessage(i18nhandle,"h24","NOT SPECIFIED")
 SET captions->override_parameters = uar_i18ngetmessage(i18nhandle,"h25","OVERRIDE_PARAMETERS")
 SET captions->prefixnoassoc = uar_i18ngetmessage(i18nhandle,"f1",
  "PREFIXES FOR WHICH NO REPORT ASSOCAITIONS ARE DEFINED:")
 SET captions->prefixdescription = uar_i18ngetmessage(i18nhandle,"f2","PREFIX DESCRIPTION")
 SET captions->refertotool = uar_i18ngetmessage(i18nhandle,"f3",
  "REFER TO ONLINE TOOL FOR ADDITIONAL STYLE ATTRIBUTES.")
 SET captions->continued = uar_i18ngetmessage(i18nhandle,"f4","CONTINUED...")
 SET week = format(curdate,"@WEEKDAYABBREV;;Q")
 SET day = format(curdate,"@MEDIUMDATE;;Q")
 RECORD temp(
   1 max_reports = i4
   1 max_section_types = i4
   1 max_prefixes = i4
   1 prefix_qual[*]
     2 rpt_assoc_defined = c1
     2 site_cd = f8
     2 site_disp = c5
     2 prefix_cd = f8
     2 prefix_name = c2
     2 prefix_desc = c40
     2 report_qual[*]
       3 catalog_cd = f8
       3 primary_ind = i2
       3 mult_allowed_ind = i2
       3 system_order_ind = i2
       3 reporting_sequence = i4
       3 description = c100
       3 style_qual[*]
         4 catalog_cd = f8
         4 task_assay_disp = c40
         4 section_flag = i4
         4 font_attrib_flag = i4
         4 font_size = i4
         4 font_name = c32
   1 prefixes_qual[*]
     2 site_cd = f8
     2 site_disp = c40
     2 prefix_name = c2
     2 prefix_cd = f8
     2 printed = c1
     2 prefix_desc = c40
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 print_status_data
     2 print_directory = c19
     2 print_filename = c40
     2 print_dir_and_filename = c60
 )
#script
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET report_cnt = 0
 SET style_cnt = 0
 SET override_shown = 0
 DECLARE report_cd = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE 5801=cv.code_set
   AND "APREPORT"=cv.cdf_meaning
   AND 1=cv.active_ind
  DETAIL
   report_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.display, ap.prefix_name, ap.prefix_id
  FROM ap_prefix ap,
   code_value cv
  PLAN (ap
   WHERE ap.active_ind=1
    AND ap.prefix_id != 0.0)
   JOIN (cv
   WHERE ap.site_cd=cv.code_value)
  ORDER BY cv.display, ap.prefix_name
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp->prefixes_qual,cnt), temp->prefixes_qual[cnt].site_cd = ap
   .site_cd,
   temp->prefixes_qual[cnt].prefix_name = ap.prefix_name, temp->prefixes_qual[cnt].prefix_cd = ap
   .prefix_id, temp->prefixes_qual[cnt].printed = "N",
   temp->prefixes_qual[cnt].prefix_desc = ap.prefix_desc
   IF (ap.site_cd > 0)
    temp->prefixes_qual[cnt].site_disp = trim(cv.display)
   ELSE
    temp->prefixes_qual[cnt].site_disp = "00"
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  site_and_prefix = concat(cnvtstring(ap.site_cd,19,0),cnvtstring(ap.prefix_id,19,0)), ap.prefix_name,
  prr.catalog_cd,
  prfi.section_type_flag, prr.prefix_id, prr.updt_dt_tm,
  prfi.prefix_id, system_order_ind = decode(apat.seq,1,0)
  FROM ap_prefix ap,
   prefix_report_r prr,
   order_catalog oc,
   (dummyt d  WITH seq = 1),
   ap_prefix_auto_task apat,
   prefix_rpt_font_info prfi,
   code_value cv
  PLAN (ap
   WHERE ap.prefix_id != 0.0
    AND ap.active_ind=1)
   JOIN (prr
   WHERE ap.prefix_id=prr.prefix_id)
   JOIN (oc
   WHERE prr.catalog_cd=oc.catalog_cd
    AND oc.activity_subtype_cd=report_cd)
   JOIN (d
   WHERE 1=d.seq)
   JOIN (((apat
   WHERE ap.prefix_id=apat.prefix_id
    AND prr.catalog_cd=apat.catalog_cd)
   ) ORJOIN ((prfi
   WHERE ap.prefix_id=prfi.prefix_id
    AND oc.catalog_cd=prfi.catalog_cd)
   JOIN (cv
   WHERE cv.code_value=prfi.task_assay_cd)
   ))
  ORDER BY site_and_prefix, prr.catalog_cd, prfi.section_type_flag
  HEAD REPORT
   report_cnt = 0, style_cnt = 0, pref_cnt = 0
  HEAD site_and_prefix
   pref_cnt = (pref_cnt+ 1), stat = alterlist(temp->prefix_qual,pref_cnt)
   IF ((pref_cnt > temp->max_prefixes))
    temp->max_prefixes = pref_cnt
   ENDIF
   temp->prefix_qual[pref_cnt].prefix_cd = ap.prefix_id, temp->prefix_qual[pref_cnt].site_cd = ap
   .site_cd, temp->prefix_qual[pref_cnt].prefix_name = ap.prefix_name,
   temp->prefix_qual[pref_cnt].prefix_desc = ap.prefix_desc, report_cnt = 0
  HEAD prr.catalog_cd
   style_cnt = 0, report_cnt = (report_cnt+ 1), stat = alterlist(temp->prefix_qual[pref_cnt].
    report_qual,report_cnt)
   IF ((report_cnt > temp->max_reports))
    temp->max_reports = report_cnt
   ENDIF
   temp->prefix_qual[pref_cnt].report_qual[report_cnt].catalog_cd = prr.catalog_cd, temp->
   prefix_qual[pref_cnt].report_qual[report_cnt].primary_ind = prr.primary_ind, temp->prefix_qual[
   pref_cnt].report_qual[report_cnt].mult_allowed_ind = prr.mult_allowed_ind,
   temp->prefix_qual[pref_cnt].report_qual[report_cnt].reporting_sequence = prr.reporting_sequence,
   temp->prefix_qual[pref_cnt].report_qual[report_cnt].system_order_ind = system_order_ind
  HEAD prfi.section_type_flag
   IF (prr.catalog_cd=prfi.catalog_cd)
    style_cnt = (style_cnt+ 1), stat = alterlist(temp->prefix_qual[pref_cnt].report_qual[report_cnt].
     style_qual,style_cnt)
    IF ((style_cnt > temp->max_section_types))
     temp->max_section_types = style_cnt
    ENDIF
    temp->prefix_qual[pref_cnt].report_qual[report_cnt].style_qual[style_cnt].catalog_cd = prfi
    .catalog_cd, temp->prefix_qual[pref_cnt].report_qual[report_cnt].style_qual[style_cnt].
    task_assay_disp = cv.display, temp->prefix_qual[pref_cnt].report_qual[report_cnt].style_qual[
    style_cnt].section_flag = prfi.section_type_flag,
    temp->prefix_qual[pref_cnt].report_qual[report_cnt].style_qual[style_cnt].font_attrib_flag = prfi
    .font_attribute_flag, temp->prefix_qual[pref_cnt].report_qual[report_cnt].style_qual[style_cnt].
    font_size = prfi.font_size, temp->prefix_qual[pref_cnt].report_qual[report_cnt].style_qual[
    style_cnt].font_name = prfi.font_name
   ENDIF
  WITH outerjoin = d, nocounter
 ;end select
 SELECT INTO "nl:"
  temp->prefix_qual[d1.seq].site_cd, temp->prefix_qual[d1.seq].prefix_cd, cv.display
  FROM (dummyt d1  WITH seq = value(size(temp->prefix_qual,5))),
   code_value cv
  PLAN (d1)
   JOIN (cv
   WHERE (temp->prefix_qual[d1.seq].site_cd=cv.code_value))
  DETAIL
   IF ((temp->prefix_qual[d1.seq].site_cd > 0.0))
    temp->prefix_qual[d1.seq].site_disp = trim(cv.display)
   ELSE
    temp->prefix_qual[d1.seq].site_disp = "00"
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  prefix_name = temp->prefix_qual[d1.seq].prefix_name, temp->prefix_qual[d1.seq].report_qual[d2.seq].
  catalog_cd, oc.*
  FROM (dummyt d1  WITH seq = value(size(temp->prefix_qual,5))),
   (dummyt d2  WITH seq = value(temp->max_reports)),
   order_catalog oc
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->prefix_qual[d1.seq].report_qual,5))
   JOIN (oc
   WHERE (temp->prefix_qual[d1.seq].report_qual[d2.seq].catalog_cd=oc.catalog_cd))
  DETAIL
   temp->prefix_qual[d1.seq].report_qual[d2.seq].description = oc.description
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  temp->prefixes_qual[d1.seq].prefix_cd
  FROM (dummyt d1  WITH seq = value(size(temp->prefixes_qual,5))),
   (dummyt d2  WITH seq = value(temp->max_prefixes))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->prefix_qual,5)
    AND (temp->prefixes_qual[d1.seq].site_cd=temp->prefix_qual[d2.seq].site_cd)
    AND (temp->prefixes_qual[d1.seq].prefix_cd=temp->prefix_qual[d2.seq].prefix_cd))
  DETAIL
   temp->prefixes_qual[d1.seq].printed = "Y"
  WITH nocounter
 ;end select
#report_maker
 EXECUTE cpm_create_file_name_logical "apsDbPrefixRpt", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  site_and_prefix_disp = trim(build(trim(temp->prefix_qual[d1.seq].site_disp),trim(temp->prefix_qual[
     d1.seq].prefix_name))), no_site_and_prefix_disp = trim(temp->prefix_qual[d1.seq].prefix_name),
  site_disp = trim(temp->prefix_qual[d1.seq].site_disp),
  prefix_name = trim(temp->prefix_qual[d1.seq].prefix_name), prefix_desc = temp->prefix_qual[d1.seq].
  prefix_desc, report_description = temp->prefix_qual[d1.seq].report_qual[d2.seq].description,
  primary_ind = temp->prefix_qual[d1.seq].report_qual[d2.seq].primary_ind, mult_allowed_ind = temp->
  prefix_qual[d1.seq].report_qual[d2.seq].mult_allowed_ind, system_order_ind = temp->prefix_qual[d1
  .seq].report_qual[d2.seq].system_order_ind,
  reporting_sequence = temp->prefix_qual[d1.seq].report_qual[d2.seq].reporting_sequence, section_flag
   = temp->prefix_qual[d1.seq].report_qual[d2.seq].style_qual[d3.seq].section_flag, font_size = temp
  ->prefix_qual[d1.seq].report_qual[d2.seq].style_qual[d3.seq].font_size,
  font_name = temp->prefix_qual[d1.seq].report_qual[d2.seq].style_qual[d3.seq].font_name,
  task_assay_disp = temp->prefix_qual[d1.seq].report_qual[d2.seq].style_qual[d3.seq].task_assay_disp,
  rept_seq_and_sect_flag = concat(cnvtstring(temp->prefix_qual[d1.seq].report_qual[d2.seq].
    reporting_sequence),cnvtstring(temp->prefix_qual[d1.seq].report_qual[d2.seq].style_qual[d3.seq].
    section_flag))
  FROM (dummyt d1  WITH seq = value(size(temp->prefix_qual,5))),
   (dummyt d2  WITH seq = value(temp->max_reports)),
   (dummyt d4  WITH seq = 1),
   (dummyt d3  WITH seq = value(temp->max_section_types))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->prefix_qual[d1.seq].report_qual,5))
   JOIN (d4)
   JOIN (d3
   WHERE d3.seq <= size(temp->prefix_qual[d1.seq].report_qual[d2.seq].style_qual,5))
  ORDER BY site_and_prefix_disp, reporting_sequence, reporting_sequence,
   rept_seq_and_sect_flag
  HEAD REPORT
   line1 = fillstring(125,"-"), num_of_prefixes = 0
  HEAD PAGE
   row + 1, col 0, captions->apsrpt,
   CALL center(captions->pathnetap,0,132), col 110, captions->date,
   col 117, curdate"@SHORTDATE;;Q", row + 1,
   col 0, captions->directory, col 110,
   captions->ttime, col 117, curtime,
   row + 1,
   CALL center(captions->refdbaudit,0,132), col 112,
   captions->bby, col 117, request->scuruser"##############",
   row + 1,
   CALL center(captions->dbprefixrptassoc,0,132), col 110,
   captions->ppage, col 117, curpage"###",
   row + 2
  HEAD site_and_prefix_disp
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   row + 1, col 0, captions->prefix
   IF (site_disp > "00")
    col 9, site_and_prefix_disp
   ELSE
    col 9, no_site_and_prefix_disp
   ENDIF
   ", ", prefix_desc, row + 1,
   col 36, captions->allow, col 46,
   captions->system, col 54, captions->resulttext,
   col 80, captions->requiredheading, col 106,
   captions->optionalheading, row + 1, col 0,
   captions->rreport, col 27, captions->primary,
   col 36, captions->multiple, col 46,
   captions->oorder, col 54, captions->ffont,
   col 74, captions->ssize, col 80,
   captions->ffont, col 100, captions->ssize,
   col 106, captions->ffont, col 126,
   captions->ssize, row + 1, col 0,
   "------------------------", col 27, "-------",
   col 36, "--------", col 46,
   "------", col 54, "------------------------",
   col 80, "------------------------", col 106,
   "------------------------"
  HEAD reporting_sequence
   override_shown = 0, row + 1, col 0,
   report_description"########################", col 27
   IF (primary_ind=1)
    captions->yes
   ELSE
    captions->no
   ENDIF
   col 36
   IF (mult_allowed_ind=1)
    captions->yes
   ELSE
    captions->no
   ENDIF
   col 46
   IF (system_order_ind=1)
    captions->yes
   ELSE
    captions->no
   ENDIF
   col 54, captions->notspecified, col 80,
   captions->notspecified, col 106, captions->notspecified
  DETAIL
   IF (section_flag=1)
    col 54, font_name"####################", col 74,
    font_size"####"
   ENDIF
   IF (section_flag=2)
    col 80, font_name"####################", col 100,
    font_size"####"
   ENDIF
   IF (section_flag=3)
    col 106, font_name"####################", col 126,
    font_size"####"
   ENDIF
   IF (section_flag=4)
    IF (override_shown=0)
     row + 1, col 4, captions->override_parameters,
     override_shown = 1
    ENDIF
    row + 1, col 4, task_assay_disp,
    col 54, font_name"####################", col 74,
    font_size"####"
   ENDIF
  FOOT  site_and_prefix_disp
   num_of_prefixes = (num_of_prefixes+ 1), row + 2,
   CALL center("* * * * * * * * * *",0,132)
   IF (num_of_prefixes=value(size(temp->prefix_qual,5)))
    IF (((row+ 10) > maxrow))
     BREAK
    ENDIF
    row + 2, col 0, captions->prefixnoassoc,
    row + 2, col 0, captions->prefixdescription,
    row + 1, col 0, "-------  -----------"
    FOR (loop1 = 1 TO value(size(temp->prefixes_qual,5)))
      IF ((temp->prefixes_qual[loop1].printed != "Y"))
       row + 1, col 0
       IF ((temp->prefixes_qual[loop1].site_disp > "00"))
        temp->prefixes_qual[loop1].site_disp"#####"
       ELSE
        "     "
       ENDIF
       temp->prefixes_qual[loop1].prefix_name"##", col 9, temp->prefixes_qual[loop1].prefix_desc
       IF (((row+ 10) > maxrow))
        BREAK
       ENDIF
      ENDIF
    ENDFOR
    IF (((row+ 10) > maxrow))
     BREAK
    ENDIF
    row + 3,
    CALL center(captions->refertotool,0,132)
   ENDIF
  FOOT PAGE
   row 60, col 0, line1,
   row + 1, col 0, captions->apsrpt,
   today = concat(week," ",day), col 53, today,
   col 110, captions->ppage, col 117,
   curpage"###", row + 1, col 55,
   captions->continued
  FOOT REPORT
   row 60, col 0, line1,
   row + 1, col 0, captions->apsrpt,
   today = concat(week," ",day), col 53, today,
   col 110, captions->ppage, col 117,
   curpage"###", row + 1, col 55,
   "##########                              "
  WITH nocounter, outerjoin = d4, dontcare = d3,
   maxcol = 132, nullreport, maxrow = 63,
   compress
 ;end select
 SET reply->status_data.status = "S"
END GO
