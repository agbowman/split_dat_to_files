CREATE PROGRAM aps_prt_db_prefix_group_report:dba
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
   1 pathap = vc
   1 ddate = vc
   1 ttime = vc
   1 rda = vc
   1 bby = vc
   1 dbpgtt = vc
   1 ppage = vc
   1 status = vc
   1 code = vc
   1 desc = vc
   1 prefix = vc
   1 none = vc
   1 cont = vc
 )
 SET captions->rptaps = uar_i18ngetmessage(i18nhandle,"rptaps",
  "REPORT: APS_PRT_DB_PREFIX_GROUP_REPORT.PRG")
 SET captions->pathap = uar_i18ngetmessage(i18nhandle,"pathap","PATHNET ANATOMIC PATHOLOGY")
 SET captions->ddate = uar_i18ngetmessage(i18nhandle,"ddate","DATE")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"ttime","TIME")
 SET captions->rda = uar_i18ngetmessage(i18nhandle,"rda","REFERENCE DATABASE AUDIT")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"bby","BY")
 SET captions->dbpgtt = uar_i18ngetmessage(i18nhandle,"dbpgtt","DB PROCESSING GROUP TASK TOOL")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"ppage","PAGE")
 SET captions->status = uar_i18ngetmessage(i18nhandle,"status","STATUS")
 SET captions->code = uar_i18ngetmessage(i18nhandle,"code","CODE")
 SET captions->desc = uar_i18ngetmessage(i18nhandle,"desc","DESCRIPTION")
 SET captions->prefix = uar_i18ngetmessage(i18nhandle,"prefix","PREFIX")
 SET captions->none = uar_i18ngetmessage(i18nhandle,"none","NONE ASSOCIATED")
 SET captions->cont = uar_i18ngetmessage(i18nhandle,"cont","CONTINUED...")
 RECORD prefix_list(
   1 max_prefix_cnt = i4
   1 prefix[*]
     2 prefix_id = f8
     2 prefix_disp = c6
     2 group_cnt = i4
     2 group_qual[*]
       3 grouper_disp_key = c40
       3 grouper_desc = c60
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
 DECLARE lrep200001count = i4 WITH protect, noconstant(0)
 DECLARE lrep200001index = i4 WITH protect, noconstant(0)
 DECLARE lprefixindex = i4 WITH protect, noconstant(0)
 DECLARE lgroupcnt = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 SUBROUTINE (subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value
   )) =null WITH protect)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 SET reply->status_data.status = "F"
 IF (size(request->prefix_qual,5)=0)
  RECORD req200001(
    1 dummy = vc
    1 bshowinactives = i2
    1 skip_resource_security_ind = i2
  )
  RECORD rep200001(
    1 prefix_qual[10]
      2 site_cd = f8
      2 unformatted_site_disp = c40
      2 prefix_cd = f8
      2 prefix_desc = c40
      2 prefix_name = c2
      2 case_type_cd = f8
      2 case_type_disp = c40
      2 case_type_desc = c40
      2 case_type_mean = c40
      2 accession_format_cd = f8
      2 active_ind = i4
      2 group_id = f8
      2 site_disp = c40
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  SET req200001->bshowinactives = 0
  SET req200001->skip_resource_security_ind = 1
  EXECUTE aps_get_all_prefixes  WITH replace("REQUEST","REQ200001"), replace("REPLY","REP200001")
  IF ((rep200001->status_data.status != "S"))
   CALL subevent_add("EXECUTE","F","aps_get_all_prefixes","Execute failed.")
   GO TO exit_script
  ENDIF
  SET lrep200001count = size(rep200001->prefix_qual,5)
  SET prefix_list->max_prefix_cnt = lrep200001count
  SET stat = alterlist(prefix_list->prefix,maxval(1,prefix_list->max_prefix_cnt))
  FOR (lrep200001index = 1 TO lrep200001count)
   SET prefix_list->prefix[lrep200001index].prefix_id = rep200001->prefix_qual[lrep200001index].
   prefix_cd
   SET prefix_list->prefix[lrep200001index].prefix_disp = build(trim(rep200001->prefix_qual[
     lrep200001index].site_disp),rep200001->prefix_qual[lrep200001index].prefix_name)
  ENDFOR
  FREE SET req200001
  FREE SET rep200001
 ELSE
  SET stat = alterlist(prefix_list->prefix,size(request->prefix_qual,5))
  FOR (idx = 1 TO size(request->prefix_qual,5))
   SET prefix_list->prefix[idx].prefix_id = request->prefix_qual[idx].prefix_id
   SET prefix_list->prefix[idx].prefix_disp = request->prefix_qual[idx].prefix_disp
  ENDFOR
 ENDIF
 SELECT INTO "n1:"
  apg.prefix_id, apg.processing_grp_cd, proc_grp_disp = uar_get_code_display(apg.processing_grp_cd)
  FROM ap_prefix_proc_grp_r apg
  PLAN (apg
   WHERE expand(idx,1,size(prefix_list->prefix,5),apg.prefix_id,prefix_list->prefix[idx].prefix_id))
  ORDER BY apg.prefix_id, proc_grp_disp
  HEAD apg.prefix_id
   lgroupcnt = 0, lprefixindex = locateval(idx,1,size(prefix_list->prefix,5),apg.prefix_id,
    prefix_list->prefix[idx].prefix_id)
  DETAIL
   lgroupcnt += 1
   IF (mod(lgroupcnt,10)=1)
    stat = alterlist(prefix_list->prefix[lprefixindex].group_qual,(lgroupcnt+ 9))
   ENDIF
   prefix_list->prefix[lprefixindex].group_qual[lgroupcnt].grouper_disp_key = uar_get_code_display(
    apg.processing_grp_cd), prefix_list->prefix[lprefixindex].group_qual[lgroupcnt].grouper_desc =
   uar_get_code_description(apg.processing_grp_cd)
  FOOT  apg.prefix_id
   prefix_list->prefix[lprefixindex].group_cnt = lgroupcnt, stat = alterlist(prefix_list->prefix[
    lprefixindex].group_qual,lgroupcnt)
  WITH nocounter, expand = 1
 ;end select
#report_maker
 EXECUTE cpm_create_file_name_logical "apsDBPrefixProcGrp", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  prefix_id = prefix_list->prefix[d1.seq].prefix_id, prefix_disp = prefix_list->prefix[d1.seq].
  prefix_disp
  FROM (dummyt d1  WITH seq = size(prefix_list->prefix,5))
  PLAN (d1)
  ORDER BY prefix_disp
  HEAD REPORT
   line1 = fillstring(125,"-")
  HEAD PAGE
   row + 1, col 0, captions->rptaps,
   CALL center(captions->pathap,0,132), col 110, captions->ddate,
   ":", cdate = format(curdate,"@SHORTDATE;;d"), col 117,
   cdate, row + 1, col 110,
   captions->ttime, ":", col 117,
   curtime, row + 1,
   CALL center(captions->rda,0,132),
   col 112, captions->bby, ":",
   col 117, curuser"##############", row + 1,
   CALL center(captions->dbpgtt,0,132), col 110, captions->ppage,
   ":", col 117, curpage"###"
  HEAD prefix_disp
   IF (((row+ 8) > maxrow))
    BREAK
   ENDIF
   row + 2, col 0, captions->prefix,
   ": ", col 8, prefix_disp,
   row + 1, col 0, captions->code,
   col 43, captions->desc, row + 1,
   col 0, "------", col 43,
   "--------------"
  DETAIL
   IF (size(prefix_list->prefix[d1.seq].group_qual,5) > 0)
    FOR (idx = 1 TO size(prefix_list->prefix[d1.seq].group_qual,5))
      IF (((row+ 8) > maxrow))
       BREAK
      ENDIF
      row + 1, col 0, prefix_list->prefix[d1.seq].group_qual[idx].grouper_disp_key,
      col 43, prefix_list->prefix[d1.seq].group_qual[idx].grouper_desc
    ENDFOR
   ELSE
    row + 1, col 0, captions->none
   ENDIF
  FOOT  prefix_disp
   row + 1,
   CALL center("* * * * * * * * * * *",0,132)
   IF (((row+ 8) > maxrow))
    BREAK
   ENDIF
  FOOT PAGE
   row 60, col 0, line1,
   row + 1, col 0, captions->rptaps,
   today = concat(format(curdate,"@WEEKDAYABBREV;;d")," ",format(curdate,"@MEDIUMDATE4YR;;d")), col
   53, today,
   col 110, captions->ppage, ":",
   col 117, curpage"###", row + 1,
   col 55, captions->cont
  FOOT REPORT
   col 55, "##########                              "
  WITH nocounter, maxcol = 132, nullreport,
   maxrow = 63, compress
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 FREE SET captions
 FREE SET prefix_list
END GO
