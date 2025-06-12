CREATE PROGRAM aps_rpt_diag_coding:dba
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
   1 rptaps = vc
   1 pathnetap = vc
   1 ddate = vc
   1 directory = vc
   1 ttime = vc
   1 refdbaudit = vc
   1 bby = vc
   1 diagcodingparamtool = vc
   1 ppage = vc
   1 auditparam = vc
   1 includeterminology = vc
   1 excludeterminology = vc
   1 includeprefixparam = vc
   1 excludeprefixparam = vc
   1 includeautocoding = vc
   1 excludeautocoding = vc
   1 includesourcevocab = vc
   1 excludesourcevocab = vc
   1 noncodeablewords = vc
   1 activeentries = vc
   1 noactiveentries = vc
   1 inactiveentries = vc
   1 noinactiveentries = vc
   1 commonwords = vc
   1 wordsofnegation = vc
   1 prefixparam = vc
   1 prefix = vc
   1 description = vc
   1 nomenclature = vc
   1 excludeaxes = vc
   1 noprefixparam = vc
   1 nnone = vc
   1 automaticcoding = vc
   1 ccode = vc
   1 description = vc
   1 noautocoding = vc
   1 sourcevocab = vc
   1 nosourcevocab = vc
   1 vocabulary = vc
   1 selectedvocab = vc
   1 rptdiagcodingparam = vc
   1 continued = vc
   1 endoreport = vc
 )
 SET captions->rptaps = uar_i18ngetmessage(i18nhandle,"h1","REPORT:  APS_RPT_DIAG_CODING.PRG")
 SET captions->pathnetap = uar_i18ngetmessage(i18nhandle,"h2","PathNet Anatomic Pathology")
 SET captions->ddate = uar_i18ngetmessage(i18nhandle,"h3","DATE:")
 SET captions->directory = uar_i18ngetmessage(i18nhandle,"h4","DIRECTORY")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"h5","TIME:")
 SET captions->refdbaudit = uar_i18ngetmessage(i18nhandle,"h6","REFERENCE DATABASE AUDIT")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"h7","BY:")
 SET captions->diagcodingparamtool = uar_i18ngetmessage(i18nhandle,"h8",
  "DIAGNOSTIC CODING PARAMETERS TOOL")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"h9","PAGE:")
 SET captions->auditparam = uar_i18ngetmessage(i18nhandle,"h10","AUDIT PARAMETERS:")
 SET captions->includeterminology = uar_i18ngetmessage(i18nhandle,"h11","INCLUDE TERMINOLOGY")
 SET captions->excludeterminology = uar_i18ngetmessage(i18nhandle,"h12","EXCLUDE TERMINOLOGY")
 SET captions->includeprefixparam = uar_i18ngetmessage(i18nhandle,"h13","INCLUDE PREFIX PARAMETERS")
 SET captions->excludeprefixparam = uar_i18ngetmessage(i18nhandle,"h14","EXCLUDE PREFIX PARAMETERS")
 SET captions->includeautocoding = uar_i18ngetmessage(i18nhandle,"h15","INCLUDE AUTOMATIC CODING")
 SET captions->excludeautocoding = uar_i18ngetmessage(i18nhandle,"h16","EXCLUDE AUTOMATIC CODING")
 SET captions->includesourcevocab = uar_i18ngetmessage(i18nhandle,"h17","INCLUDE SOURCE VOCABULARIES"
  )
 SET captions->excludesourcevocab = uar_i18ngetmessage(i18nhandle,"h18","EXCLUDE SOURCE VOCABULARIES"
  )
 SET captions->noncodeablewords = uar_i18ngetmessage(i18nhandle,"d1","NON-CODEABLE WORDS")
 SET captions->activeentries = uar_i18ngetmessage(i18nhandle,"d2","*** ACTIVE ENTRIES ***")
 SET captions->noactiveentries = uar_i18ngetmessage(i18nhandle,"d3","NO ACTIVE ENTRIES")
 SET captions->inactiveentries = uar_i18ngetmessage(i18nhandle,"d4","*** INACTIVE ENTRIES ***")
 SET captions->noinactiveentries = uar_i18ngetmessage(i18nhandle,"d5","NO INACTIVE ENTRIES")
 SET captions->commonwords = uar_i18ngetmessage(i18nhandle,"d6","COMMON WORDS")
 SET captions->wordsofnegation = uar_i18ngetmessage(i18nhandle,"d7","WORDS OF NEGATION")
 SET captions->prefixparam = uar_i18ngetmessage(i18nhandle,"d8","PREFIX PARAMETERS")
 SET captions->prefix = uar_i18ngetmessage(i18nhandle,"d9","PREFIX")
 SET captions->description = uar_i18ngetmessage(i18nhandle,"d10","DESCRIPTION")
 SET captions->nomenclature = uar_i18ngetmessage(i18nhandle,"d11","NOMENCLATURE")
 SET captions->excludeaxes = uar_i18ngetmessage(i18nhandle,"d12","EXCLUDE AXES")
 SET captions->noprefixparam = uar_i18ngetmessage(i18nhandle,"d13","NO PREFIX PARAMETERS")
 SET captions->nnone = uar_i18ngetmessage(i18nhandle,"d14","(NONE)")
 SET captions->automaticcoding = uar_i18ngetmessage(i18nhandle,"d15","AUTOMATIC CODING")
 SET captions->ccode = uar_i18ngetmessage(i18nhandle,"d16","CODE")
 SET captions->description = uar_i18ngetmessage(i18nhandle,"d17","DESCRIPTION")
 SET captions->noautocoding = uar_i18ngetmessage(i18nhandle,"d18","NO AUTOMATIC CODING")
 SET captions->sourcevocab = uar_i18ngetmessage(i18nhandle,"d19","SOURCE VOCABULARIES")
 SET captions->nosourcevocab = uar_i18ngetmessage(i18nhandle,"d20","NO SOURCE VOCABULARIES")
 SET captions->vocabulary = uar_i18ngetmessage(i18nhandle,"d21","VOCABULARY:")
 SET captions->selectedvocab = uar_i18ngetmessage(i18nhandle,"d22","SELECTED VOCABULARIES")
 SET captions->rptdiagcodingparam = uar_i18ngetmessage(i18nhandle,"d23",
  "REPORT:  DIAGNOSTIC CODING PARAMETERS DATABASE AUDIT")
 SET captions->continued = uar_i18ngetmessage(i18nhandle,"f1","CONTINUED...")
 SET captions->endoreport = uar_i18ngetmessage(i18nhandle,"f2","### END OF REPORT ###")
 SET week = format(curdate,"@WEEKDAYABBREV;;Q")
 SET day = format(curdate,"@MEDIUMDATE;;Q")
 RECORD temp(
   1 non_codeable_qual[1]
     2 active_cnt = i2
     2 active_qual[*]
       3 word_display = c40
     2 inactive_cnt = i2
     2 inactive_qual[*]
       3 word_display = c40
   1 common_qual[1]
     2 active_cnt = i2
     2 active_qual[*]
       3 word_display = c40
     2 inactive_cnt = i2
     2 inactive_qual[*]
       3 word_display = c40
   1 negation_qual[1]
     2 active_cnt = i2
     2 active_qual[*]
       3 word_display = c40
     2 inactive_cnt = i2
     2 inactive_qual[*]
       3 word_display = c40
   1 prefix_params_cnt = i2
   1 prefix_params_qual[10]
     2 prefix_disp = c40
     2 prefix_desc = c40
     2 nomenclature = c40
     2 excluded_axes_cnt = i2
     2 excluded_axes_qual[*]
       3 axis_disp = c40
   1 auto_coding_cnt = i2
   1 auto_coding_qual[10]
     2 auto_code_disp = vc
     2 auto_code_desc = vc
   1 source_vocabs_cnt = i2
   1 source_vocabs_qual[5]
     2 vocab_name = c40
     2 selected_vocabs_cnt = i2
     2 selected_vocabs_qual[*]
       3 vocab_name = c40
   1 print_line = c130
   1 print_line20 = c20
 )
 RECORD reply(
   1 print_status_data
     2 print_directory = c19
     2 print_filename = c40
     2 print_dir_and_filename = c60
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET line4 = fillstring(4,"-")
 SET line6 = fillstring(6,"-")
 SET line7 = fillstring(7,"-")
 SET line12 = fillstring(12,"-")
 SET line14 = fillstring(14,"-")
 SET line20 = fillstring(20,"-")
 SET line25 = fillstring(25,"-")
 SET line40 = fillstring(40,"-")
 SET line55 = fillstring(55,"-")
 SET line60 = fillstring(60,"-")
 SET line = fillstring(3," ")
 SET assignmentheader = 0
 SET ndx = 0
 SET ndx2 = 0
 SET cnt = 0
 SET cnt2 = 0
 SET cnt3 = 0
 SET cnt4 = 0
 SET cnt5 = 0
 SET cnt6 = 0
 SET x = 0
 IF ((request->terminology_ind=1))
  SET stat = alterlist(temp->non_codeable_qual[1].active_qual,10)
  SET stat = alterlist(temp->non_codeable_qual[1].inactive_qual,10)
  SET stat = alterlist(temp->common_qual[1].active_qual,10)
  SET stat = alterlist(temp->common_qual[1].inactive_qual,10)
  SET stat = alterlist(temp->negation_qual[1].active_qual,10)
  SET stat = alterlist(temp->negation_qual[1].inactive_qual,10)
  SELECT INTO "nl:"
   cv.display
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set IN (15029, 15049, 15050))
   ORDER BY cv.code_set, cv.display
   DETAIL
    CASE (cv.code_set)
     OF 15029:
      IF (cv.active_ind=1)
       cnt = (cnt+ 1)
       IF (mod(cnt,10)=1
        AND cnt != 1)
        stat = alterlist(temp->non_codeable_qual[1].active_qual,(cnt+ 9))
       ENDIF
       temp->non_codeable_qual[1].active_qual[cnt].word_display = cv.display
      ELSE
       cnt2 = (cnt2+ 1)
       IF (mod(cnt2,10)=1
        AND cnt2 != 1)
        stat = alterlist(temp->non_codeable_qual[1].inactive_qual,(cnt2+ 9))
       ENDIF
       temp->non_codeable_qual[1].inactive_qual[cnt2].word_display = cv.display
      ENDIF
     OF 15049:
      IF (cv.active_ind=1)
       cnt3 = (cnt3+ 1)
       IF (mod(cnt3,10)=1
        AND cnt3 != 1)
        stat = alterlist(temp->common_qual[1].active_qual,(cnt3+ 9))
       ENDIF
       temp->common_qual[1].active_qual[cnt3].word_display = cv.display
      ELSE
       cnt4 = (cnt4+ 1)
       IF (mod(cnt4,10)=1
        AND cnt4 != 1)
        stat = alterlist(temp->common_qual[1].inactive_qual,(cnt4+ 9))
       ENDIF
       temp->common_qual[1].inactive_qual[cnt4].word_display = cv.display
      ENDIF
     OF 15050:
      IF (cv.active_ind=1)
       cnt5 = (cnt5+ 1)
       IF (mod(cnt5,10)=1
        AND cnt5 != 1)
        stat = alterlist(temp->negation_qual[1].active_qual,(cnt5+ 9))
       ENDIF
       temp->negation_qual[1].active_qual[cnt5].word_display = cv.display
      ELSE
       cnt6 = (cnt6+ 1)
       IF (mod(cnt6,10)=1
        AND cnt6 != 1)
        stat = alterlist(temp->negation_qual[1].inactive_qual,(cnt6+ 9))
       ENDIF
       temp->negation_qual[1].inactive_qual[cnt6].word_display = cv.display
      ENDIF
    ENDCASE
   FOOT REPORT
    temp->non_codeable_qual[1].active_cnt = cnt, stat = alterlist(temp->non_codeable_qual[1].
     active_qual,cnt), temp->non_codeable_qual[1].inactive_cnt = cnt2,
    stat = alterlist(temp->non_codeable_qual[1].inactive_qual,cnt2), temp->common_qual[1].active_cnt
     = cnt3, stat = alterlist(temp->common_qual[1].active_qual,cnt3),
    temp->common_qual[1].inactive_cnt = cnt4, stat = alterlist(temp->common_qual[1].inactive_qual,
     cnt4), temp->negation_qual[1].active_cnt = cnt5,
    stat = alterlist(temp->negation_qual[1].active_qual,cnt5), temp->negation_qual[1].inactive_cnt =
    cnt6, stat = alterlist(temp->negation_qual[1].inactive_qual,cnt6)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
   SET reply->status_data.status = "P"
  ELSE
   IF ((reply->status_data.status != "P"))
    SET reply->status_data.status = "S"
   ENDIF
  ENDIF
 ENDIF
 IF ((request->prefix_params_ind=1))
  SET cnt = 0
  SET cnt2 = 0
  SELECT INTO "nl:"
   ap.prefix_name, apda.exclude_axis_cd
   FROM ap_prefix ap,
    code_value cv,
    code_value cv2,
    (dummyt d  WITH seq = 1),
    ap_prefix_diag_axis apda,
    code_value cv3
   PLAN (ap
    WHERE ap.diag_coding_vocabulary_cd > 0)
    JOIN (cv
    WHERE cv.code_value=ap.site_cd)
    JOIN (cv2
    WHERE ap.diag_coding_vocabulary_cd=cv2.code_value)
    JOIN (d)
    JOIN (apda
    WHERE apda.exclude_axis_cd > 0
     AND apda.prefix_id=ap.prefix_id)
    JOIN (cv3
    WHERE cv3.code_value=apda.exclude_axis_cd)
   ORDER BY cv2.display, ap.prefix_name, cv.display,
    cv3.display
   HEAD REPORT
    stat = alter(temp->prefix_params_qual,10)
   HEAD ap.prefix_name
    cnt2 = 0, cnt = (cnt+ 1)
    IF (mod(cnt,10)=1
     AND cnt != 1)
     stat = alter(temp->prefix_params_qual,(cnt+ 9))
    ENDIF
    temp->prefix_params_qual[cnt].prefix_disp = format(trim(cv.display),"#####;p0"), temp->
    prefix_params_qual[cnt].prefix_disp = concat(trim(temp->prefix_params_qual[cnt].prefix_disp),trim
     (ap.prefix_name)), temp->prefix_params_qual[cnt].prefix_desc = ap.prefix_desc,
    temp->prefix_params_qual[cnt].nomenclature = cv2.display, stat = alterlist(temp->
     prefix_params_qual[cnt].excluded_axes_qual,5)
   HEAD apda.exclude_axis_cd
    IF (textlen(trim(cv3.display)) > 0)
     cnt2 = (cnt2+ 1)
     IF (mod(cnt2,5)=1
      AND cnt2 != 1)
      stat = alterlist(temp->prefix_params_qual[cnt].excluded_axes_qual,(cnt2+ 4))
     ENDIF
     x = findstring(",",cv3.display), temp->prefix_params_qual[cnt].excluded_axes_qual[cnt2].
     axis_disp = trim(substring(1,(x - 1),cv3.display))
    ENDIF
   FOOT  ap.prefix_name
    temp->prefix_params_qual[cnt].excluded_axes_cnt = cnt2, stat = alterlist(temp->
     prefix_params_qual[cnt].excluded_axes_qual,cnt2)
   FOOT REPORT
    temp->prefix_params_cnt = cnt, stat = alter(temp->prefix_params_qual,cnt)
   WITH nocounter, outerjoin = d
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_PREFIX"
   SET reply->status_data.status = "P"
  ELSE
   IF ((reply->status_data.status != "P"))
    SET reply->status_data.status = "S"
   ENDIF
  ENDIF
 ENDIF
 IF ((request->auto_coding_ind=1))
  SET cnt = 0
  SELECT INTO "nl:"
   oc.description, dta.description
   FROM ap_diag_auto_code adac,
    order_catalog oc,
    discrete_task_assay dta
   PLAN (adac
    WHERE adac.catalog_cd > 0
     AND adac.task_assay_cd > 0)
    JOIN (oc
    WHERE adac.catalog_cd=oc.catalog_cd)
    JOIN (dta
    WHERE dta.task_assay_cd=adac.task_assay_cd)
   ORDER BY dta.mnemonic, dta.description
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1
     AND cnt != 1)
     stat = alter(temp->auto_coding_qual,(cnt+ 9))
    ENDIF
    temp->auto_coding_qual[cnt].auto_code_disp = dta.mnemonic, temp->auto_coding_qual[cnt].
    auto_code_desc = dta.description
   FOOT REPORT
    temp->auto_coding_cnt = cnt, stat = alter(temp->auto_coding_qual,cnt)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_DIAG_AUTO_CODE"
   SET reply->status_data.status = "P"
  ELSE
   IF ((reply->status_data.status != "P"))
    SET reply->status_data.status = "S"
   ENDIF
  ENDIF
 ENDIF
 IF ((request->source_vocabs_ind=1))
  SET cnt = 0
  SET cnt2 = 0
  SELECT INTO "nl:"
   cv.display, cv2.display
   FROM ap_source_vocabulary_r asvr,
    code_value cv,
    code_value cv2
   PLAN (asvr
    WHERE asvr.source_vocabulary_cd > 0)
    JOIN (cv
    WHERE cv.code_value=asvr.source_vocabulary_cd)
    JOIN (cv2
    WHERE cv2.code_value=asvr.include_source_vocabulary_cd)
   ORDER BY cv.display, cv2.display
   HEAD cv.display
    cnt = (cnt+ 1), cnt2 = 0, stat = alterlist(temp->source_vocabs_qual[cnt].selected_vocabs_qual,5)
    IF (mod(cnt,5)=1
     AND cnt != 1)
     stat = alter(temp->source_vocabs_qual,(cnt+ 4))
    ENDIF
    temp->source_vocabs_qual[cnt].vocab_name = cv.display
   DETAIL
    cnt2 = (cnt2+ 1)
    IF (mod(cnt2,5)=1
     AND cnt2 != 1)
     stat = alterlist(temp->source_vocabs_qual[cnt].selected_vocabs_qual,(cnt2+ 4))
    ENDIF
    temp->source_vocabs_qual[cnt].selected_vocabs_qual[cnt2].vocab_name = cv2.display
   FOOT  cv.display
    temp->source_vocabs_qual[cnt].selected_vocabs_cnt = cnt2, stat = alterlist(temp->
     source_vocabs_qual[cnt].selected_vocabs_qual,cnt2)
   FOOT REPORT
    temp->source_vocabs_cnt = cnt, stat = alter(temp->source_vocabs_qual,cnt)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_SOURCE_VOCABULARY_R"
   SET reply->status_data.status = "P"
  ELSE
   IF ((reply->status_data.status != "P"))
    SET reply->status_data.status = "S"
   ENDIF
  ENDIF
 ENDIF
#report_maker
 EXECUTE cpm_create_file_name_logical "apsDbDiagCoding", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 CALL echo(value(reply->print_status_data.print_dir_and_filename))
 SELECT INTO value(reply->print_status_data.print_filename)
  d.seq
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   line1 = fillstring(125,"-"), line2 = fillstring(116,"-"), row + 1,
   col 1, captions->rptaps, col 56,
   CALL center(captions->pathnetap,1,132), col 110, captions->ddate,
   col 117, curdate"@SHORTDATE;;Q", row + 1,
   col 1, captions->directory, col 110,
   captions->ttime, col 117, curtime,
   row + 1, col 54,
   CALL center(captions->refdbaudit,1,132),
   col 112, captions->bby, col 117,
   request->scuruser, row + 1, col 50,
   CALL center(captions->diagcodingparamtool,1,132), col 110, captions->ppage,
   col 117, curpage"###", row + 1,
   row + 1, col 1, captions->auditparam,
   " ", row + 1, col 3
   IF ((request->terminology_ind=1))
    captions->includeterminology
   ELSE
    captions->excludeterminology
   ENDIF
   row + 1, col 3
   IF ((request->prefix_params_ind=1))
    captions->includeprefixparam
   ELSE
    captions->excludeprefixparam
   ENDIF
   row + 1, col 3
   IF ((request->auto_coding_ind=1))
    captions->includeautocoding
   ELSE
    captions->excludeautocoding
   ENDIF
   row + 1, col 3
   IF ((request->source_vocabs_ind=1))
    captions->includesourcevocab
   ELSE
    captions->excludesourcevocab
   ENDIF
   row + 1
  HEAD PAGE
   IF (curpage > 1)
    row + 1, col 1, captions->rptaps,
    col 56,
    CALL center(captions->pathnetap,1,132), col 110,
    captions->ddate, col 117, curdate"@SHORTDATE;;Q",
    row + 1, col 1, captions->directory,
    col 110, captions->ttime, col 117,
    curtime, row + 1, col 54,
    CALL center(captions->refdbaudit,1,132), col 112, captions->bby,
    col 117, request->scuruser, row + 1,
    col 50,
    CALL center(captions->diagcodingparamtool,1,132), col 110,
    captions->ppage, col 117, curpage"###",
    row + 1
   ENDIF
  DETAIL
   IF ((request->terminology_ind=1))
    row + 1, row + 1, col 40,
    CALL center(fillstring(41,"-"),1,132), row + 1, col 50,
    CALL center(captions->noncodeablewords,1,132), row + 1, col 39,
    CALL center(fillstring(41,"-"),1,132), row + 1, row + 1,
    col 50,
    CALL center(captions->activeentries,1,132), row + 1,
    ndx = 0, temp->print_line = captions->noactiveentries
    FOR (ndx = 1 TO temp->non_codeable_qual[1].active_cnt)
     IF (((textlen(trim(temp->print_line))+ textlen(trim(temp->non_codeable_qual[1].active_qual[ndx].
       word_display))) >= 128))
      IF (((row+ 1) >= (maxrow - 4)))
       BREAK
      ENDIF
      temp->print_line = concat(trim(temp->print_line),", "), row + 1, col 1,
      temp->print_line, temp->print_line = ""
     ENDIF
     ,
     IF (((ndx=1) OR (textlen(trim(temp->print_line))=0)) )
      temp->print_line = trim(temp->non_codeable_qual[1].active_qual[ndx].word_display)
     ELSE
      temp->print_line = concat(trim(temp->print_line),", ",trim(temp->non_codeable_qual[1].
        active_qual[ndx].word_display))
     ENDIF
    ENDFOR
    IF (((row+ 1) >= (maxrow - 4)))
     BREAK
    ENDIF
    row + 1, col 1, temp->print_line,
    temp->print_line = ""
    IF (((row+ 4) >= (maxrow - 4)))
     BREAK
    ENDIF
    row + 1, row + 1, col 50,
    CALL center(captions->inactiveentries,1,132), row + 1, ndx = 0,
    temp->print_line = captions->noinactiveentries
    FOR (ndx = 1 TO temp->non_codeable_qual[1].inactive_cnt)
     IF (((textlen(trim(temp->print_line))+ textlen(trim(temp->non_codeable_qual[1].inactive_qual[ndx
       ].word_display))) >= 128))
      IF (((row+ 1) >= (maxrow - 4)))
       BREAK
      ENDIF
      temp->print_line = concat(trim(temp->print_line),", "), row + 1, col 1,
      temp->print_line, temp->print_line = ""
     ENDIF
     ,
     IF (((ndx=1) OR (textlen(trim(temp->print_line))=0)) )
      temp->print_line = trim(temp->non_codeable_qual[1].inactive_qual[ndx].word_display)
     ELSE
      temp->print_line = concat(trim(temp->print_line),", ",trim(temp->non_codeable_qual[1].
        inactive_qual[ndx].word_display))
     ENDIF
    ENDFOR
    IF (((row+ 1) >= (maxrow - 4)))
     BREAK
    ENDIF
    row + 1, col 1, temp->print_line,
    temp->print_line = ""
    IF (((row+ 8) >= (maxrow - 4)))
     BREAK
    ENDIF
    row + 1, row + 1, col 40,
    CALL center(fillstring(41,"-"),1,132), row + 1, col 50,
    CALL center(captions->commonwords,1,132), row + 1, col 39,
    CALL center(fillstring(41,"-"),1,132), row + 1, row + 1,
    col 50,
    CALL center(captions->activeentries,1,132), row + 1,
    ndx = 0, temp->print_line = captions->noactiveentries
    FOR (ndx = 1 TO temp->common_qual[1].active_cnt)
     IF (((textlen(trim(temp->print_line))+ textlen(trim(temp->common_qual[1].active_qual[ndx].
       word_display))) >= 128))
      IF (((row+ 1) >= (maxrow - 4)))
       BREAK
      ENDIF
      temp->print_line = concat(trim(temp->print_line),", "), row + 1, col 1,
      temp->print_line, temp->print_line = ""
     ENDIF
     ,
     IF (((ndx=1) OR (textlen(trim(temp->print_line))=0)) )
      temp->print_line = trim(temp->common_qual[1].active_qual[ndx].word_display)
     ELSE
      temp->print_line = concat(trim(temp->print_line),", ",trim(temp->common_qual[1].active_qual[ndx
        ].word_display))
     ENDIF
    ENDFOR
    IF (((row+ 1) >= (maxrow - 4)))
     BREAK
    ENDIF
    row + 1, col 1, temp->print_line,
    temp->print_line = ""
    IF (((row+ 4) >= (maxrow - 4)))
     BREAK
    ENDIF
    row + 1, row + 1, col 50,
    CALL center(captions->inactiveentries,1,132), row + 1, ndx = 0,
    temp->print_line = captions->noinactiveentries
    FOR (ndx = 1 TO temp->common_qual[1].inactive_cnt)
     IF (((textlen(trim(temp->print_line))+ textlen(trim(temp->common_qual[1].inactive_qual[ndx].
       word_display))) >= 128))
      IF (((row+ 1) >= (maxrow - 4)))
       BREAK
      ENDIF
      temp->print_line = concat(trim(temp->print_line),", "), row + 1, col 1,
      temp->print_line, temp->print_line = ""
     ENDIF
     ,
     IF (((ndx=1) OR (textlen(trim(temp->print_line))=0)) )
      temp->print_line = trim(temp->common_qual[1].inactive_qual[ndx].word_display)
     ELSE
      temp->print_line = concat(trim(temp->print_line),", ",trim(temp->common_qual[1].inactive_qual[
        ndx].word_display))
     ENDIF
    ENDFOR
    IF (((row+ 1) >= (maxrow - 4)))
     BREAK
    ENDIF
    row + 1, col 1, temp->print_line,
    temp->print_line = ""
    IF (((row+ 8) >= (maxrow - 4)))
     BREAK
    ENDIF
    row + 1, row + 1, col 40,
    CALL center(fillstring(41,"-"),1,132), row + 1, col 50,
    CALL center(captions->wordsofnegation,1,132), row + 1, col 39,
    CALL center(fillstring(41,"-"),1,132), row + 1, row + 1,
    col 50,
    CALL center(captions->activeentries,1,132), row + 1,
    ndx = 0, temp->print_line = captions->noactiveentries
    FOR (ndx = 1 TO temp->negation_qual[1].active_cnt)
     IF (((textlen(trim(temp->print_line))+ textlen(trim(temp->negation_qual[1].active_qual[ndx].
       word_display))) >= 128))
      IF (((row+ 1) >= (maxrow - 4)))
       BREAK
      ENDIF
      temp->print_line = concat(trim(temp->print_line),", "), row + 1, col 1,
      temp->print_line, temp->print_line = ""
     ENDIF
     ,
     IF (((ndx=1) OR (textlen(trim(temp->print_line))=0)) )
      temp->print_line = trim(temp->negation_qual[1].active_qual[ndx].word_display)
     ELSE
      temp->print_line = concat(trim(temp->print_line),", ",trim(temp->negation_qual[1].active_qual[
        ndx].word_display))
     ENDIF
    ENDFOR
    IF (((row+ 1) >= (maxrow - 4)))
     BREAK
    ENDIF
    row + 1, col 1, temp->print_line,
    temp->print_line = ""
    IF (((row+ 4) >= (maxrow - 4)))
     BREAK
    ENDIF
    row + 1, row + 1, col 50,
    CALL center(captions->inactiveentries,1,132), row + 1, ndx = 0,
    temp->print_line = captions->noinactiveentries
    FOR (ndx = 1 TO temp->negation_qual[1].inactive_cnt)
     IF (((textlen(trim(temp->print_line))+ textlen(trim(temp->negation_qual[1].inactive_qual[ndx].
       word_display))) >= 128))
      IF (((row+ 1) >= (maxrow - 4)))
       BREAK
      ENDIF
      temp->print_line = concat(trim(temp->print_line),", "), row + 1, col 1,
      temp->print_line, temp->print_line = ""
     ENDIF
     ,
     IF (((ndx=1) OR (textlen(trim(temp->print_line))=0)) )
      temp->print_line = trim(temp->negation_qual[1].inactive_qual[ndx].word_display)
     ELSE
      temp->print_line = concat(trim(temp->print_line),", ",trim(temp->negation_qual[1].
        inactive_qual[ndx].word_display))
     ENDIF
    ENDFOR
    IF (((row+ 1) >= (maxrow - 4)))
     BREAK
    ENDIF
    row + 1, col 1, temp->print_line,
    temp->print_line = ""
   ENDIF
   IF ((request->prefix_params_ind=1))
    IF (((row+ 8) >= (maxrow - 4)))
     BREAK
    ENDIF
    row + 1, row + 1, col 40,
    CALL center(fillstring(41,"-"),1,132), row + 1, col 50,
    CALL center(captions->prefixparam,1,132), row + 1, col 39,
    CALL center(fillstring(41,"-"),1,132), row + 1, row + 1,
    col 1, captions->prefix, col 10,
    captions->description, col 52, captions->nomenclature,
    col 110, captions->excludeaxes, row + 1,
    col 1, line7, col 10,
    line40, col 52, line55,
    col 110, line20, row + 1,
    ndx = 0, temp->print_line = captions->noprefixparam
    FOR (ndx = 1 TO temp->prefix_params_cnt)
      row + 1, col 1, temp->prefix_params_qual[ndx].prefix_disp,
      col 10, temp->prefix_params_qual[ndx].prefix_desc, col 52,
      temp->prefix_params_qual[ndx].nomenclature, temp->print_line20 = captions->nnone
      FOR (ndx2 = 1 TO temp->prefix_params_qual[ndx].excluded_axes_cnt)
       IF (((textlen(trim(temp->print_line20))+ textlen(trim(temp->prefix_params_qual[ndx].
         excluded_axes_qual[ndx2].axis_disp))) >= 15))
        IF (((row+ 1) >= (maxrow - 4)))
         BREAK
        ENDIF
        temp->print_line20 = concat(trim(temp->print_line20),", "), col 110, temp->print_line20,
        row + 1, temp->print_line20 = ""
       ENDIF
       ,
       IF (((ndx2=1) OR (textlen(trim(temp->print_line20))=0)) )
        temp->print_line20 = trim(temp->prefix_params_qual[ndx].excluded_axes_qual[ndx2].axis_disp)
       ELSE
        temp->print_line20 = concat(trim(temp->print_line20),", ",trim(temp->prefix_params_qual[ndx].
          excluded_axes_qual[ndx2].axis_disp))
       ENDIF
      ENDFOR
      col 110, temp->print_line20, temp->print_line20 = ""
    ENDFOR
    IF (((row+ 1) >= (maxrow - 4)))
     BREAK
    ENDIF
   ENDIF
   IF ((request->auto_coding_ind=1))
    IF (((row+ 8) >= (maxrow - 4)))
     BREAK
    ENDIF
    row + 1, row + 1, col 40,
    CALL center(fillstring(41,"-"),1,132), row + 1, col 50,
    CALL center(captions->automaticcoding,1,132), row + 1, col 39,
    CALL center(fillstring(41,"-"),1,132), row + 1, row + 1,
    col 1, captions->ccode, col 28,
    captions->description, row + 1, col 1,
    line25, col 28, line60,
    row + 1, ndx = 0, temp->print_line = captions->noautocoding
    FOR (ndx = 1 TO temp->auto_coding_cnt)
      IF (((row+ 1) >= (maxrow - 4)))
       BREAK
      ENDIF
      row + 1, col 1, temp->auto_coding_qual[ndx].auto_code_disp,
      col 28, temp->auto_coding_qual[ndx].auto_code_desc
    ENDFOR
   ENDIF
   IF ((request->source_vocabs_ind=1))
    IF (((row+ 10) >= (maxrow - 4)))
     BREAK
    ENDIF
    row + 1, row + 1, col 40,
    CALL center(fillstring(41,"-"),1,132), row + 1, col 50,
    CALL center(captions->sourcevocab,1,132), row + 1, col 39,
    CALL center(fillstring(41,"-"),1,132), row + 1, ndx = 0,
    temp->print_line = captions->nosourcevocab
    FOR (ndx = 1 TO temp->source_vocabs_cnt)
      row + 1, row + 1, col 1,
      captions->vocabulary, col 24, temp->source_vocabs_qual[ndx].vocab_name,
      row + 1, row + 1, col 1,
      captions->selectedvocab, row + 1, col 1,
      line40
      FOR (ndx2 = 1 TO temp->source_vocabs_qual[ndx].selected_vocabs_cnt)
        IF (((row+ 1) >= (maxrow - 4)))
         BREAK
        ENDIF
        row + 1, col 1, temp->source_vocabs_qual[ndx].selected_vocabs_qual[ndx2].vocab_name
      ENDFOR
    ENDFOR
   ENDIF
  FOOT PAGE
   row 60, col 1, line1,
   row + 1, col 1, captions->rptaps,
   today = concat(week,"",day), col 58, today,
   col 110, captions->ppage, col 117,
   curpage"###", row + 1, col 55,
   CALL center(captions->continued,1,132)
  FOOT REPORT
   col 55,
   CALL center(captions->endoreport,1,132)
  WITH nocounter, maxcol = 132, nullreport,
   maxrow = 63, compress
 ;end select
 IF (curqual > 0)
  IF ((reply->status_data.status != "P"))
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
END GO
