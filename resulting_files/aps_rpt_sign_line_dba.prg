CREATE PROGRAM aps_rpt_sign_line:dba
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
 RECORD temp(
   1 activity_type = c40
   1 format_qual[*]
     2 description = c60
     2 active_ind = i2
     2 row_qual[*]
       3 line_num = i4
       3 column_pos = i4
       3 literal_display = c40
       3 literal_size = i4
       3 data_elem = f8
       3 data_elem_display = c40
       3 max_size = i4
       3 data_elem_fmt = c60
       3 suppress_line_ind = i2
   1 assign_qual[*]
     2 activity_type = c20
     2 activity_subtype = c20
     2 discrete_task = c20
     2 status_display = c20
     2 format_display = c40
 )
 RECORD captions(
   1 transign = vc
   1 tran = vc
   1 signa = vc
   1 corr = vc
   1 invstat = vc
   1 perfver = vc
   1 perf = vc
   1 ver = vc
   1 vercor = vc
   1 rptaps = vc
   1 pathnet = vc
   1 dt = vc
   1 dir = vc
   1 time = vc
   1 refdata = vc
   1 bycd = vc
   1 signtool = vc
   1 pageno = vc
   1 audparam = vc
   1 incsign = vc
   1 exsign = vc
   1 incform = vc
   1 exform = vc
   1 acttypecol = vc
   1 actsubtype = vc
   1 distask = vc
   1 stat = vc
   1 signline = vc
   1 acttype = vc
   1 signforms = vc
   1 desc = vc
   1 statcol = vc
   1 act = vc
   1 inact = vc
   1 line = vc
   1 column = vc
   1 literal = vc
   1 sepsize = vc
   1 datael = vc
   1 maxsize = vc
   1 format = vc
   1 rptsign = vc
   1 cont = vc
   1 endrep = vc
   1 format2 = vc
   1 suppress = vc
   1 none = vc
 )
 SET captions->transign = uar_i18ngetmessage(i18nhandle,"T1","Transcribed & Signed")
 SET captions->tran = uar_i18ngetmessage(i18nhandle,"T2","Transcribed")
 SET captions->signa = uar_i18ngetmessage(i18nhandle,"T3","Signed")
 SET captions->corr = uar_i18ngetmessage(i18nhandle,"T4","Corrected")
 SET captions->invstat = uar_i18ngetmessage(i18nhandle,"T5","Invalid Status")
 SET captions->perfver = uar_i18ngetmessage(i18nhandle,"T6","Performed & Verified")
 SET captions->perf = uar_i18ngetmessage(i18nhandle,"T7","Performed")
 SET captions->ver = uar_i18ngetmessage(i18nhandle,"T8","Verified")
 SET captions->vercor = uar_i18ngetmessage(i18nhandle,"T8.1","Verified / Corrected")
 SET captions->rptaps = uar_i18ngetmessage(i18nhandle,"T9","REPORT: APS_RPT_SIGN_LINE.PRG")
 IF ((request->sact_prefix="HLA"))
  SET captions->pathnet = uar_i18ngetmessage(i18nhandle,"HLA Title",
   "PathNet HLA: DB Formatted Signature Line")
 ELSEIF ((request->sact_prefix="GLB"))
  SET captions->pathnet = uar_i18ngetmessage(i18nhandle,"GL Title",
   "PathNet General Lab: DB Formatted Signature Line")
 ELSEIF ((request->sact_prefix="RA"))
  SET captions->pathnet = uar_i18ngetmessage(i18nhandle,"RA Title",
   "Radiology: DB Formatted Signature Line")
 ELSEIF ((request->sact_prefix="HX"))
  SET captions->pathnet = uar_i18ngetmessage(i18nhandle,"HX Title",
   "PathNet Helix: DB Formatted Signature Line")
 ELSEIF ((request->sact_prefix="CI"))
  SET captions->pathnet = uar_i18ngetmessage(i18nhandle,"CI Title",
   "Case Integration: DB Formatted Signature Line")
 ELSEIF ((request->sact_prefix="UC"))
  SET captions->pathnet = uar_i18ngetmessage(i18nhandle,"UCR Title",
   "Unified Case Report: DB Formatted Signature Line")
 ELSEIF ((request->sact_prefix="BB"))
  SET captions->pathnet = uar_i18ngetmessage(i18nhandle,"BB Title",
   "Blood Bank: DB Formatted Signature Line")
 ELSE
  SET captions->pathnet = uar_i18ngetmessage(i18nhandle,"AP Title","PathNet Anatomic Pathology")
 ENDIF
 SET captions->dt = uar_i18ngetmessage(i18nhandle,"T11","DATE:")
 SET captions->dir = uar_i18ngetmessage(i18nhandle,"T12","DIRECTORY:")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"T13","TIME:")
 SET captions->refdata = uar_i18ngetmessage(i18nhandle,"T14","REFERENCE DATABASE AUDIT")
 SET captions->bycd = uar_i18ngetmessage(i18nhandle,"T15","BY:")
 SET captions->signtool = uar_i18ngetmessage(i18nhandle,"T16","SIGNATURE LINE FORMAT TOOL")
 SET captions->pageno = uar_i18ngetmessage(i18nhandle,"T17","PAGE:")
 SET captions->audparam = uar_i18ngetmessage(i18nhandle,"T18","AUDIT PARAMETERS:")
 SET captions->incsign = uar_i18ngetmessage(i18nhandle,"T19","INCLUDE SIGNATURE LINE FORMATS")
 SET captions->exsign = uar_i18ngetmessage(i18nhandle,"T20","EXCLUDE SIGNATURE LINE FORMATS")
 SET captions->incform = uar_i18ngetmessage(i18nhandle,"T21","INCLUDE FORMAT ASSIGNMENTS")
 SET captions->exform = uar_i18ngetmessage(i18nhandle,"T22","EXCLUDE FORMAT ASSIGNMENTS")
 SET captions->acttypecol = uar_i18ngetmessage(i18nhandle,"T23","ACTIVITY TYPE:")
 SET captions->actsubtype = uar_i18ngetmessage(i18nhandle,"T24","ACTIVITY SUB-TYPE")
 SET captions->distask = uar_i18ngetmessage(i18nhandle,"T25","DISCRETE TASK")
 SET captions->stat = uar_i18ngetmessage(i18nhandle,"T26","STATUS")
 SET captions->signline = uar_i18ngetmessage(i18nhandle,"T27","SIGNATURE LINE FORMAT")
 SET captions->acttype = uar_i18ngetmessage(i18nhandle,"T28","ACTIVITY TYPE")
 SET captions->signforms = uar_i18ngetmessage(i18nhandle,"T29","SIGNATURE LINE FORMATS")
 SET captions->desc = uar_i18ngetmessage(i18nhandle,"T30","DESCRIPTION:")
 SET captions->statcol = uar_i18ngetmessage(i18nhandle,"T31","STATUS:")
 SET captions->act = uar_i18ngetmessage(i18nhandle,"T32","ACTIVE")
 SET captions->inact = uar_i18ngetmessage(i18nhandle,"T33","INACTIVE")
 SET captions->line = uar_i18ngetmessage(i18nhandle,"T34","LINE")
 SET captions->column = uar_i18ngetmessage(i18nhandle,"T35","COL")
 SET captions->literal = uar_i18ngetmessage(i18nhandle,"T36","LITERAL")
 SET captions->sepsize = uar_i18ngetmessage(i18nhandle,"T37","SEP")
 SET captions->datael = uar_i18ngetmessage(i18nhandle,"T38","DATA ELEMENT")
 SET captions->maxsize = uar_i18ngetmessage(i18nhandle,"T39","MAX SIZE")
 SET captions->format = uar_i18ngetmessage(i18nhandle,"T40","FORMAT ASSOCIATIONS")
 SET captions->rptsign = uar_i18ngetmessage(i18nhandle,"T41",
  "REPORT: SIGNATURE LINE FORMAT DATABASE AUDIT")
 SET captions->cont = uar_i18ngetmessage(i18nhandle,"T42","CONTINUED...")
 SET captions->endrep = uar_i18ngetmessage(i18nhandle,"T43","### END OF REPORT ###")
 SET captions->format2 = uar_i18ngetmessage(i18nhandle,"T44","FORMAT")
 IF ((request->activity_type_cd > 0))
  SET temp->activity_type = uar_get_code_display(request->activity_type_cd)
 ELSE
  SET temp->activity_type = uar_i18ngetmessage(i18nhandle,"T45","(All)")
 ENDIF
 SET captions->suppress = uar_i18ngetmessage(i18nhandle,"T46","SUPPRESS")
 SET captions->none = uar_i18ngetmessage(i18nhandle,"T47","(None)")
 IF ((request->sact_prefix="CI"))
  SET captions->distask = uar_i18ngetmessage(i18nhandle,"T49","ENCOUNTER PATHWAY")
 ELSEIF ((request->sact_prefix="UC"))
  SET captions->distask = uar_i18ngetmessage(i18nhandle,"T48","LAYOUT FIELD")
 ENDIF
 RECORD reply(
   1 ops_event = vc
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
 SET line3 = fillstring(3,"-")
 SET line4 = fillstring(4,"-")
 SET line6 = fillstring(6,"-")
 SET line8 = fillstring(8,"-")
 SET line9 = fillstring(9,"-")
 SET line12 = fillstring(12,"-")
 SET line14 = fillstring(14,"-")
 SET line20 = fillstring(20,"-")
 SET line34 = fillstring(34,"-")
 SET line40 = fillstring(40,"-")
 SET line = fillstring(3," ")
 SET fmt = fillstring(20," ")
 SET assignmentheader = 0
 SET ndx = 0
 SET ndx2 = 0
 SET cnt = 0
 SET cnt2 = 0
 SET sactivity_prefix = concat(trim(request->sact_prefix),"*")
 SET element_where = concat("cv.cdf_meaning = '",sactivity_prefix,"'")
 IF ((request->format_ind=1))
  SELECT INTO "nl:"
   slf.format_id, slfd.format_id, displayvalue = uar_get_code_display(slfd.data_element_cd),
   format_desc = uar_get_code_display(slfd.data_element_format_cd)
   FROM sign_line_format slf,
    sign_line_format_detail slfd,
    code_value cv
   PLAN (slf)
    JOIN (slfd
    WHERE slf.format_id=slfd.format_id)
    JOIN (cv
    WHERE slfd.data_element_cd=cv.code_value
     AND parser(element_where))
   ORDER BY slf.description, slf.format_id, slfd.sequence
   HEAD slf.format_id
    cnt = (cnt+ 1), cnt2 = 0, stat = alterlist(temp->format_qual,cnt),
    temp->format_qual[cnt].description = slf.description, temp->format_qual[cnt].active_ind = slf
    .active_ind
   DETAIL
    cnt2 = (cnt2+ 1), stat = alterlist(temp->format_qual[cnt].row_qual,cnt2), temp->format_qual[cnt].
    row_qual[cnt2].line_num = slfd.line_nbr,
    temp->format_qual[cnt].row_qual[cnt2].column_pos = slfd.column_pos
    IF (slfd.data_element_cd > 0)
     temp->format_qual[cnt].row_qual[cnt2].data_elem_display = displayvalue
    ELSE
     temp->format_qual[cnt].row_qual[cnt2].data_elem_display = " "
    ENDIF
    temp->format_qual[cnt].row_qual[cnt2].data_elem = slfd.data_element_cd, temp->format_qual[cnt].
    row_qual[cnt2].literal_display = slfd.literal_display
    IF ((temp->format_qual[cnt].row_qual[cnt2].literal_display=""))
     temp->format_qual[cnt].row_qual[cnt2].literal_display = " "
    ENDIF
    temp->format_qual[cnt].row_qual[cnt2].literal_size = slfd.literal_size, temp->format_qual[cnt].
    row_qual[cnt2].max_size = slfd.max_size, temp->format_qual[cnt].row_qual[cnt2].data_elem_fmt =
    format_desc,
    temp->format_qual[cnt].row_qual[cnt2].suppress_line_ind = slfd.suppress_line_ind
   FOOT  slf.format_id
    stat = alterlist(temp->format_qual,cnt), stat = alterlist(temp->format_qual[cnt].row_qual,cnt2)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "SIGN_LINE_FORMAT"
   SET reply->status_data.status = "Z"
   GO TO report_maker
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 IF ((request->assoc_ind=1))
  SET cnt = 0
  IF ((request->sact_prefix="UC"))
   CALL loadlayoutfields(null)
  ELSEIF ((request->sact_prefix="CI"))
   CALL loadeps(null)
  ELSE
   SELECT
    IF ((request->sact_prefix="BB"))INTO "nl:"
     sldr.task_assay_cd, slf.format_id, dta.task_assay_cd,
     cv.display
     FROM code_value cv,
      code_value cv2,
      code_value cv3,
      sign_line_format_detail slfd,
      sign_line_format slf,
      sign_line_dta_r sldr,
      discrete_task_assay dta
     PLAN (cv
      WHERE (cv.code_value=request->activity_type_cd))
      JOIN (cv2
      WHERE cv2.code_value=0.0)
      JOIN (cv3
      WHERE cv3.cdf_meaning="BB*"
       AND cv3.code_set=14287)
      JOIN (slfd
      WHERE slfd.data_element_cd=cv3.code_value)
      JOIN (slf
      WHERE slf.format_id=slfd.format_id)
      JOIN (sldr
      WHERE sldr.format_id=slf.format_id)
      JOIN (dta
      WHERE dta.task_assay_cd=sldr.task_assay_cd)
     ORDER BY cv.display, dta.mnemonic, sldr.status_flag
    ELSEIF ((request->activity_type_cd > 0))INTO "nl:"
     sldr.task_assay_cd, slf.format_id, dta.task_assay_cd,
     cv.display, cv2.display
     FROM sign_line_dta_r sldr,
      sign_line_format slf,
      discrete_task_assay dta,
      code_value cv,
      code_value cv2
     PLAN (cv
      WHERE (request->activity_type_cd=cv.code_value))
      JOIN (cv2
      WHERE cv2.code_set=5801
       AND cv2.definition=cv.cdf_meaning)
      JOIN (sldr
      WHERE sldr.activity_subtype_cd=cv2.code_value)
      JOIN (dta
      WHERE dta.task_assay_cd=sldr.task_assay_cd)
      JOIN (slf
      WHERE slf.format_id=sldr.format_id)
     ORDER BY cv.display, cv2.display, dta.mnemonic,
      sldr.status_flag
    ELSE INTO "nl:"
     sldr.task_assay_cd, slf.format_id, dta.task_assay_cd,
     cv.display, cv2.display
     FROM sign_line_dta_r sldr,
      sign_line_format slf,
      discrete_task_assay dta,
      code_value cv,
      code_value cv2
     PLAN (sldr)
      JOIN (cv2
      WHERE sldr.activity_subtype_cd=cv2.code_value)
      JOIN (cv
      WHERE cv.code_set=106
       AND cv2.definition=cv.cdf_meaning)
      JOIN (dta
      WHERE dta.task_assay_cd=sldr.task_assay_cd)
      JOIN (slf
      WHERE slf.format_id=sldr.format_id)
     ORDER BY cv.display, cv2.display, dta.mnemonic,
      sldr.status_flag
    ENDIF
    HEAD dta.mnemonic
     cnt = (cnt+ 1), stat = alterlist(temp->assign_qual,cnt), temp->assign_qual[cnt].format_display
      = slf.description
     IF (cv.cdf_meaning="RADIOLOGY")
      CASE (sldr.status_flag)
       OF 0:
        temp->assign_qual[cnt].status_display = captions->transign
       OF 1:
        temp->assign_qual[cnt].status_display = captions->tran
       OF 2:
        temp->assign_qual[cnt].status_display = captions->signa
       ELSE
        temp->assign_qual[cnt].status_display = captions->invstat
      ENDCASE
     ELSE
      CASE (sldr.status_flag)
       OF 0:
        temp->assign_qual[cnt].status_display = captions->perfver
       OF 1:
        temp->assign_qual[cnt].status_display = captions->perf
       OF 2:
        temp->assign_qual[cnt].status_display = captions->ver
       OF 3:
        temp->assign_qual[cnt].status_display = captions->corr
       ELSE
        temp->assign_qual[cnt].status_display = captions->invstat
      ENDCASE
     ENDIF
     temp->assign_qual[cnt].discrete_task = substring(1,20,dta.mnemonic)
     IF ((request->sact_prefix="BB"))
      temp->assign_qual[cnt].activity_subtype = captions->none
     ELSE
      temp->assign_qual[cnt].activity_subtype = cv2.display
     ENDIF
     temp->assign_qual[cnt].activity_type = cv.display
    FOOT  dta.mnemonic
     stat = alterlist(temp->assign_qual,cnt)
    WITH nocounter
   ;end select
  ENDIF
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "SIGN_LINE_DTA_R"
   SET reply->status_data.status = "Z"
   GO TO report_maker
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
#report_maker
 EXECUTE cpm_create_file_name_logical "apsDbSignLine", "dat", "x"
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
   line1 = fillstring(125,"-"), line2 = fillstring(116,"-")
  HEAD PAGE
   row + 1, col 1, captions->rptaps,
   col 56,
   CALL center(captions->pathnet,1,132), col 110,
   captions->dt, col 117, curdate"@SHORTDATE;;D",
   row + 1, col 1, captions->dir,
   col 110, captions->time, col 117,
   curtime, row + 1, col 54,
   CALL center(captions->refdata,1,132), col 112, captions->bycd,
   col 117, request->scuruser, row + 1,
   col 50,
   CALL center(captions->signtool,1,132), col 110,
   captions->pageno, col 117, curpage"###",
   row + 1, row + 1, col 1,
   captions->audparam, row + 1, col 3
   IF ((request->format_ind=1))
    captions->incsign
   ELSE
    captions->exsign
   ENDIF
   row + 1, col 3
   IF ((request->assoc_ind=1))
    captions->incform
   ELSE
    captions->exform
   ENDIF
   row + 1, col 1, captions->acttypecol,
   col 17, temp->activity_type, row + 1
   IF (assignmentheader=1)
    row + 1, col 1, captions->acttype,
    col 23, captions->actsubtype, col 45,
    captions->distask, col 67, captions->stat,
    col 90, captions->signline, row + 1,
    col 1, line20, col 23,
    line20, col 45, line20,
    col 67, line20, col 90,
    line40
   ENDIF
  DETAIL
   IF ((request->format_ind=1))
    row + 1, col 40,
    CALL center(fillstring(41,"-"),1,132),
    row + 1, col 50,
    CALL center(captions->signforms,1,132),
    row + 1, col 39,
    CALL center(fillstring(41,"-"),1,132),
    row + 1, ndx = 0
    FOR (ndx = 1 TO size(temp->format_qual,5))
      IF ((((row+ 6)+ size(temp->format_qual[ndx].row_qual,5)) >= (maxrow - 3)))
       BREAK
      ENDIF
      row + 1, col 1, captions->desc,
      col 15, temp->format_qual[ndx].description, row + 1,
      col 6, captions->statcol
      IF ((temp->format_qual[ndx].active_ind=1))
       col 15, captions->act
      ELSE
       col 15, captions->inact
      ENDIF
      row + 1, row + 1, col 1,
      captions->line, col 7, captions->column,
      col 12, captions->literal, col 48,
      captions->sepsize, col 53, captions->datael,
      col 89, captions->maxsize, col 98,
      captions->format2
      IF (((trim(request->sact_prefix)="AP") OR (((trim(request->sact_prefix)="RA") OR (trim(request
       ->sact_prefix)="HX")) )) )
       col 119, captions->suppress
      ENDIF
      row + 1, col 1, line4,
      col 7, line3, col 12,
      line34, col 48, line3,
      col 53, line34, col 89,
      line8, col 98, line20
      IF (((trim(request->sact_prefix)="AP") OR (((trim(request->sact_prefix)="RA") OR (trim(request
       ->sact_prefix)="HX")) )) )
       col 119, line8
      ENDIF
      ndx2 = 0
      FOR (ndx2 = 1 TO size(temp->format_qual[ndx].row_qual,5))
        line = format(temp->format_qual[ndx].row_qual[ndx2].line_num,"##;p "), row + 1, col 3,
        line, line = format(temp->format_qual[ndx].row_qual[ndx2].column_pos,"##;p "), col 8,
        line, col 12, temp->format_qual[ndx].row_qual[ndx2].literal_display,
        line = format(temp->format_qual[ndx].row_qual[ndx2].literal_size,"##;p "), col 49, line,
        col 53, temp->format_qual[ndx].row_qual[ndx2].data_elem_display, line = format(temp->
         format_qual[ndx].row_qual[ndx2].max_size,"###;p "),
        col 92, line, fmt = substring(1,20,temp->format_qual[ndx].row_qual[ndx2].data_elem_fmt),
        col 98, fmt
        IF (((trim(request->sact_prefix)="AP") OR (((trim(request->sact_prefix)="RA") OR (trim(
         request->sact_prefix)="HX")) )) )
         IF ((temp->format_qual[ndx].row_qual[ndx2].suppress_line_ind=1))
          col 123, "Y"
         ENDIF
        ENDIF
      ENDFOR
      row + 1
    ENDFOR
    row + 1
   ENDIF
   IF ((request->assoc_ind=1))
    IF (((row+ 8) >= (maxrow - 3)))
     BREAK
    ENDIF
    row + 1, col 40,
    CALL center(fillstring(41,"-"),1,132),
    row + 1, col 50,
    CALL center(captions->format,1,132),
    row + 1, col 39,
    CALL center(fillstring(41,"-"),1,132),
    row + 1, row + 1, col 1,
    captions->acttype, col 23, captions->actsubtype,
    col 45, captions->distask, col 67,
    captions->stat, col 90, captions->signline,
    row + 1, col 1, line20,
    col 23, line20, col 45,
    line20, col 67, line20,
    col 90, line40, assignmentheader = 1,
    ndx = 0
    FOR (ndx = 1 TO size(temp->assign_qual,5))
      IF (((row+ 1) >= (maxrow - 3)))
       BREAK
      ENDIF
      row + 1, col 1, temp->assign_qual[ndx].activity_type,
      col 23, temp->assign_qual[ndx].activity_subtype, col 45,
      temp->assign_qual[ndx].discrete_task, col 67, temp->assign_qual[ndx].status_display,
      col 90, temp->assign_qual[ndx].format_display
    ENDFOR
   ENDIF
  FOOT PAGE
   row 60, col 1, line1,
   row + 1, col 1, captions->rptsign,
   newday = format(curdate,"@WEEKDAYABBREV;;Q"), newdate = format(curdate,"@MEDIUMDATE4YR;;D"), col
   58,
   newday, " ", newdate,
   col 110, captions->pageno, col 117,
   curpage"###", row + 1, col 55,
   CALL center(captions->cont,1,132)
  FOOT REPORT
   col 55,
   CALL center(captions->endrep,1,132)
  WITH nocounter, maxcol = 132, nullreport,
   maxrow = 63, compress
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 DECLARE loadeps() = i2
 SUBROUTINE loadeps(null)
  SELECT INTO "nl:"
   slf.format_id
   FROM sign_line_ep_r sler,
    sign_line_format slf,
    scr_pattern srp
   PLAN (sler)
    JOIN (srp
    WHERE trim(srp.cki_source)=trim(sler.cki_source)
     AND trim(srp.cki_identifier)=trim(sler.cki_identifier))
    JOIN (slf
    WHERE slf.format_id=sler.format_id)
   ORDER BY srp.display, sler.status_flag
   HEAD REPORT
    sci = uar_get_code_display(uar_get_code_by("MEANING",106,"CI"))
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(temp->assign_qual,cnt), temp->assign_qual[cnt].format_display =
    slf.description
    CASE (sler.status_flag)
     OF 2:
      temp->assign_qual[cnt].status_display = captions->vercor
     ELSE
      temp->assign_qual[cnt].status_display = captions->invstat
    ENDCASE
    temp->assign_qual[cnt].activity_subtype = captions->none, temp->assign_qual[cnt].activity_type =
    sci, temp->assign_qual[cnt].discrete_task = substring(1,20,srp.display)
   WITH nocounter
  ;end select
  RETURN(1)
 END ;Subroutine
 DECLARE loadlayoutfields() = i2
 SUBROUTINE loadlayoutfields(null)
   SELECT INTO "nl:"
    slf.format_id
    FROM sign_line_layout_field_r slfr,
     sign_line_format slf,
     ucmr_layout_field ulf
    PLAN (slfr)
     JOIN (slf
     WHERE slf.format_id=slfr.format_id)
     JOIN (ulf
     WHERE ulf.ucmr_layout_field_id=slfr.ucmr_layout_field_id)
    ORDER BY ulf.field_name, slfr.status_flag
    HEAD REPORT
     sucr = uar_get_code_display(uar_get_code_by("MEANING",5801,"UCR")), sci = uar_get_code_display(
      uar_get_code_by("MEANING",106,"CI"))
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(temp->assign_qual,cnt), temp->assign_qual[cnt].format_display
      = slf.description
     CASE (slfr.status_flag)
      OF 1:
       temp->assign_qual[cnt].status_display = captions->perf
      OF 2:
       temp->assign_qual[cnt].status_display = captions->vercor
      ELSE
       temp->assign_qual[cnt].status_display = captions->invstat
     ENDCASE
     temp->assign_qual[cnt].activity_type = sci, temp->assign_qual[cnt].activity_subtype = sucr, temp
     ->assign_qual[cnt].discrete_task = substring(1,20,ulf.field_name)
    WITH nocounter
   ;end select
   CALL echo("lfs count:")
   CALL echo(cnt)
   RETURN(1)
 END ;Subroutine
#exit_script
END GO
