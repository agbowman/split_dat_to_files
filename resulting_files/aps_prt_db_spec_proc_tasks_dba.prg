CREATE PROGRAM aps_prt_db_spec_proc_tasks:dba
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
 SET week = format(curdate,"@WEEKDAYABBREV;;Q")
 SET day = format(curdate,"@MEDIUMDATE;;Q")
 RECORD captions(
   1 apsrtp = vc
   1 pathnetap = vc
   1 ddate = vc
   1 directory = vc
   1 ttime = vc
   1 refdbaudit = vc
   1 bby = vc
   1 dbspecimenproctask = vc
   1 ppage = vc
   1 specimen = vc
   1 prefix = vc
   1 none = vc
   1 pathologist = vc
   1 ttask = vc
   1 blocksequence = vc
   1 slidesequence = vc
   1 nocharge = vc
   1 cont = vc
   1 yes = vc
   1 no = vc
   1 continued = vc
 )
 SET captions->apsrtp = uar_i18ngetmessage(i18nhandle,"h1","REPORT: APS_PRT_DB_SPEC_PROC_TASKS.PRG")
 SET captions->pathnetap = uar_i18ngetmessage(i18nhandle,"h2","PATHNET ANATOMIC PATHOLOGY")
 SET captions->ddate = uar_i18ngetmessage(i18nhandle,"h3","DATE:")
 SET captions->directory = uar_i18ngetmessage(i18nhandle,"h4","DIRECTORY:")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"h5","TIME:")
 SET captions->refdbaudit = uar_i18ngetmessage(i18nhandle,"h6","REFERENCE DATABASE AUDIT")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"h7","BY:")
 SET captions->dbspecimenproctask = uar_i18ngetmessage(i18nhandle,"h8",
  "DB SPECIMEN PROCESSING TASKS TOOL")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"h9","PAGE:")
 SET captions->specimen = uar_i18ngetmessage(i18nhandle,"h10","SPECIMEN:")
 SET captions->prefix = uar_i18ngetmessage(i18nhandle,"h11","PREFIX:")
 SET captions->none = uar_i18ngetmessage(i18nhandle,"h12","(NONE)")
 SET captions->pathologist = uar_i18ngetmessage(i18nhandle,"h13","PATHOLOGIST:")
 SET captions->ttask = uar_i18ngetmessage(i18nhandle,"h14","TASK")
 SET captions->blocksequence = uar_i18ngetmessage(i18nhandle,"h15","BLOCK SEQUENCE")
 SET captions->slidesequence = uar_i18ngetmessage(i18nhandle,"h16","SLIDE SEQUENCE")
 SET captions->nocharge = uar_i18ngetmessage(i18nhandle,"h17","NO CHARGE")
 SET captions->cont = uar_i18ngetmessage(i18nhandle,"d1","(Cont.)")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"d2","YES")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"d3","NO")
 SET captions->continued = uar_i18ngetmessage(i18nhandle,"f1","CONTINUED...")
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
 RECORD temp(
   1 max_details = i4
   1 qual[*]
     2 spec_cd = f8
     2 spec_disp = c40
     2 spec_desc = c60
     2 prefix_id = f8
     2 prefix_name = c2
     2 site_cd = f8
     2 site_disp = vc
     2 path_id = f8
     2 path_disp = c40
     2 path_disc = vc
     2 protocol_id = f8
     2 protocol_qual[*]
       3 task_assay_cd = f8
       3 task_assay_disp = c40
       3 begin_section = i4
       3 begin_level = i4
       3 no_charge_ind = i2
       3 sequence = i4
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  asp.protocol_id
  FROM ap_specimen_protocol asp,
   dummyt d1,
   ap_prefix ap,
   dummyt d2,
   prsnl p
  PLAN (asp
   WHERE asp.protocol_id != 0)
   JOIN (d1)
   JOIN (ap
   WHERE asp.prefix_id=ap.prefix_id)
   JOIN (d2)
   JOIN (p
   WHERE asp.pathologist_id=p.person_id)
  HEAD REPORT
   ncnt = 0
  DETAIL
   ncnt = (ncnt+ 1), stat = alterlist(temp->qual,ncnt), temp->qual[ncnt].protocol_id = asp
   .protocol_id,
   temp->qual[ncnt].spec_cd = asp.specimen_cd, temp->qual[ncnt].prefix_id = asp.prefix_id, temp->
   qual[ncnt].prefix_name = ap.prefix_name,
   temp->qual[ncnt].site_cd = ap.site_cd, temp->qual[ncnt].path_id = asp.pathologist_id, temp->qual[
   ncnt].path_disp = p.name_full_formatted,
   temp->qual[ncnt].path_disc = p.name_full_formatted
  WITH outerjoin = d1, dontcare = ap, nocounter
 ;end select
 SELECT INTO "nl:"
  cv.display
  FROM (dummyt d1  WITH seq = value(size(temp->qual,5))),
   code_value cv
  PLAN (d1
   WHERE (temp->qual[d1.seq].spec_cd != 0.0))
   JOIN (cv
   WHERE (temp->qual[d1.seq].spec_cd=cv.code_value))
  DETAIL
   temp->qual[d1.seq].spec_disp = cv.display, temp->qual[d1.seq].spec_desc = cv.description
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.display
  FROM (dummyt d1  WITH seq = value(size(temp->qual,5))),
   code_value cv
  PLAN (d1
   WHERE (temp->qual[d1.seq].site_cd != 0.0))
   JOIN (cv
   WHERE (temp->qual[d1.seq].site_cd=cv.code_value))
  DETAIL
   temp->qual[d1.seq].site_disp = cv.display
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  apgr.parent_entity_id, apgr.task_assay_cd, apgr.begin_section,
  apgr.begin_level, apgr.no_charge_ind, apgr.sequence
  FROM (dummyt d1  WITH seq = value(size(temp->qual,5))),
   ap_processing_grp_r apgr
  PLAN (d1
   WHERE (temp->qual[d1.seq].protocol_id != 0.0))
   JOIN (apgr
   WHERE (temp->qual[d1.seq].protocol_id=apgr.parent_entity_id)
    AND apgr.parent_entity_name="AP_SPECIMEN_PROTOCOL")
  ORDER BY apgr.parent_entity_id, apgr.begin_section, apgr.begin_level,
   apgr.sequence
  HEAD REPORT
   ncnt = 0
  HEAD apgr.parent_entity_id
   ncnt = 0
  DETAIL
   ncnt = (ncnt+ 1)
   IF ((ncnt > temp->max_details))
    temp->max_details = ncnt
   ENDIF
   stat = alterlist(temp->qual[d1.seq].protocol_qual,ncnt), temp->qual[d1.seq].protocol_qual[ncnt].
   task_assay_cd = apgr.task_assay_cd, temp->qual[d1.seq].protocol_qual[ncnt].begin_section = apgr
   .begin_section,
   temp->qual[d1.seq].protocol_qual[ncnt].begin_level = apgr.begin_level, temp->qual[d1.seq].
   protocol_qual[ncnt].no_charge_ind = apgr.no_charge_ind, temp->qual[d1.seq].protocol_qual[ncnt].
   sequence = apgr.sequence
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  task_assay_cd = temp->qual[d1.seq].protocol_qual[d2.seq].task_assay_cd, ptr_task_assay_cd = ptr
  .task_assay_cd, ptr_catalog_cd = ptr.catalog_cd,
  oc.primary_mnemonic, cv.description
  FROM (dummyt d1  WITH seq = value(size(temp->qual,5))),
   (dummyt d2  WITH seq = value(temp->max_details)),
   profile_task_r ptr,
   order_catalog oc,
   code_value cv
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->qual[d1.seq].protocol_qual,5)
    AND (temp->qual[d1.seq].protocol_qual[d2.seq].task_assay_cd != 0.0))
   JOIN (ptr
   WHERE (temp->qual[d1.seq].protocol_qual[d2.seq].task_assay_cd=ptr.task_assay_cd))
   JOIN (oc
   WHERE ptr.catalog_cd=oc.catalog_cd)
   JOIN (cv
   WHERE oc.activity_subtype_cd=cv.code_value
    AND cv.code_set=5801
    AND cv.cdf_meaning IN ("APPROCESS", "APBILLING")
    AND cv.active_ind=1)
  DETAIL
   temp->qual[d1.seq].protocol_qual[d2.seq].task_assay_disp = oc.primary_mnemonic
  WITH nocounter
 ;end select
#report_maker
 EXECUTE cpm_create_file_name_logical "apsDbSpecTasks", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  spec_disp = temp->qual[d1.seq].spec_disp, prefix_disp = temp->qual[d1.seq].prefix_name, path_disp
   = temp->qual[d1.seq].path_disp,
  ordering_seq = concat(temp->qual[d1.seq].spec_disp,temp->qual[d1.seq].prefix_name,temp->qual[d1.seq
   ].path_disp), protocol_id = temp->qual[d1.seq].protocol_id, task_assay_disp = temp->qual[d1.seq].
  protocol_qual[d2.seq].task_assay_disp,
  begin_section = temp->qual[d1.seq].protocol_qual[d2.seq].begin_section, begin_level = temp->qual[d1
  .seq].protocol_qual[d2.seq].begin_level, no_charge_ind = temp->qual[d1.seq].protocol_qual[d2.seq].
  no_charge_ind,
  sequence = temp->qual[d1.seq].protocol_qual[d2.seq].sequence
  FROM (dummyt d1  WITH seq = value(size(temp->qual,5))),
   (dummyt d2  WITH seq = value(temp->max_details))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->qual[d1.seq].protocol_qual,5))
  ORDER BY ordering_seq, begin_section, begin_level,
   sequence
  HEAD REPORT
   line1 = fillstring(125,"-")
  HEAD PAGE
   row + 1, col 0, captions->apsrtp,
   CALL center(captions->pathnetap,0,132), col 110, captions->ddate,
   col 117, curdate"@SHORTDATE;;Q", row + 1,
   col 0, captions->directory, col 110,
   captions->ttime, col 117, curtime,
   row + 1,
   CALL center(captions->refdbaudit,0,132), col 112,
   captions->bby, col 117, request->scuruser"##############",
   row + 1,
   CALL center(captions->dbspecimenproctask,0,132), col 110,
   captions->ppage, col 117, curpage"###",
   row + 2
  HEAD ordering_seq
   IF (((row+ 11) > maxrow))
    BREAK
   ENDIF
   row + 1, col 3, captions->specimen,
   col 14, temp->qual[d1.seq].spec_disp, row + 1,
   col 14, temp->qual[d1.seq].spec_desc, row + 1,
   col 5, captions->prefix, col 14
   IF ((temp->qual[d1.seq].prefix_id=0.0))
    captions->none
   ELSE
    temp->qual[d1.seq].site_disp, temp->qual[d1.seq].prefix_name
   ENDIF
   row + 1, col 0, captions->pathologist,
   col 14
   IF ((temp->qual[d1.seq].path_id=0.0))
    captions->none
   ELSE
    temp->qual[d1.seq].path_disp
   ENDIF
   row + 2, col 14, captions->ttask,
   col 41, captions->blocksequence, col 57,
   captions->slidesequence, col 73, captions->nocharge,
   row + 1, col 14, "-------------------------",
   col 41, "--------------", col 57,
   "--------------", col 73, "---------"
  DETAIL
   IF (((row+ 10) > maxrow))
    row + 1, captions->cont, BREAK
   ENDIF
   row + 1, col 14, task_assay_disp,
   col 41
   IF (begin_section > 0)
    begin_section"###"
   ENDIF
   col 57
   IF (begin_level > 0)
    begin_level"###"
   ENDIF
   col 73
   IF (no_charge_ind != 0)
    captions->yes
   ELSE
    captions->no
   ENDIF
  FOOT  ordering_seq
   row + 1, row + 1,
   CALL center("* * * * * * * * * *",0,132)
  FOOT PAGE
   row 60, col 0, line1,
   row + 1, col 0, captions->apsrtp,
   today = concat(week," ",day), col 53, today,
   col 110, captions->ppage, col 117,
   curpage"###", row + 1, col 55,
   captions->continued
  FOOT REPORT
   col 55, "##########                              "
  WITH nocounter, maxcol = 132, nullreport,
   maxrow = 63, compress
 ;end select
 SET reply->status_data.status = "S"
END GO
