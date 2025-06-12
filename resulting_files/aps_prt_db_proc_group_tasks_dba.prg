CREATE PROGRAM aps_prt_db_proc_group_tasks:dba
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
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 rptaps = vc
   1 pathap = vc
   1 ddate = vc
   1 dir = vc
   1 ttime = vc
   1 rda = vc
   1 bby = vc
   1 dbpgtt = vc
   1 ppage = vc
   1 grptsk = vc
   1 status = vc
   1 active = vc
   1 inactive = vc
   1 cmptsk = vc
   1 blkseq = vc
   1 sldseq = vc
   1 nochrg = vc
   1 cont = vc
   1 prefix = vc
   1 none = vc
 )
 SET captions->rptaps = uar_i18ngetmessage(i18nhandle,"rptaps",
  "REPORT: APS_PRT_DB_PROC_GROUP_TASKS.PRG")
 SET captions->pathap = uar_i18ngetmessage(i18nhandle,"pathap","PATHNET ANATOMIC PATHOLOGY")
 SET captions->ddate = uar_i18ngetmessage(i18nhandle,"ddate","DATE")
 SET captions->dir = uar_i18ngetmessage(i18nhandle,"dir","DIRECTORY")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"ttime","TIME")
 SET captions->rda = uar_i18ngetmessage(i18nhandle,"rda","REFERENCE DATABASE AUDIT")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"bby","BY")
 SET captions->dbpgtt = uar_i18ngetmessage(i18nhandle,"dbpgtt","DB PROCESSING GROUP TASK TOOL")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"ppage","PAGE")
 SET captions->grptsk = uar_i18ngetmessage(i18nhandle,"grptsk","GROUP TASK")
 SET captions->status = uar_i18ngetmessage(i18nhandle,"status","STATUS")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"active","ACTIVE")
 SET captions->inactive = uar_i18ngetmessage(i18nhandle,"inactive","INACTIVE")
 SET captions->cmptsk = uar_i18ngetmessage(i18nhandle,"cmptsk","COMPONENT TASK")
 SET captions->blkseq = uar_i18ngetmessage(i18nhandle,"blkseq","BLOCK SEQUENCE")
 SET captions->sldseq = uar_i18ngetmessage(i18nhandle,"sldseq","SLIDE SEQUENCE")
 SET captions->nochrg = uar_i18ngetmessage(i18nhandle,"nochrg","NO CHARGE")
 SET captions->cont = uar_i18ngetmessage(i18nhandle,"cont","CONTINUED...")
 SET captions->prefix = uar_i18ngetmessage(i18nhandle,"prefix","ASSOCIATED PREFIXES:")
 SET captions->none = uar_i18ngetmessage(i18nhandle,"none","NONE")
 RECORD temp(
   1 max_task_assay_cd_val = i4
   1 qual[10]
     2 parent_entity_id = f8
     2 grouper_disp = c40
     2 grouper_disp_key = c40
     2 grouper_desc = c60
     2 active_ind = i2
     2 task_qual[*]
       3 task_assay_cd = f8
       3 mnemonic = c50
       3 begin_section = i4
       3 begin_level = i4
       3 no_charge_ind = i2
       3 sequence = i4
     2 prefix_qual[*]
       3 prefix_id = f8
       3 prefix_disp = vc
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
 DECLARE prefix_idx = i4 WITH protect, noconstant(0)
 DECLARE loc_idx = i4 WITH protect, noconstant(0)
 DECLARE temp_string = vc WITH protect
 DECLARE prefix_itr = i4 WITH protect
 DECLARE new_row_ind = i2 WITH protect
 DECLARE prefix_cnt = i4 WITH protect
 DECLARE lindex = i4 WITH protect
 SET reply->status_data.status = "F"
 SET dynamic_where = fillstring(50," ")
 SET max_cnt = 0
 SET max_task_cnt = 0
 SET task_cnt = 0
 SET cnt = 0
 SELECT INTO "nl:"
  cv.code_value, apgr.parent_entity_id
  FROM code_value cv,
   ap_processing_grp_r apgr
  PLAN (cv
   WHERE cv.code_set=1310)
   JOIN (apgr
   WHERE apgr.parent_entity_id=cv.code_value
    AND apgr.parent_entity_name="CODE_VALUE")
  ORDER BY cv.display, apgr.begin_section, apgr.begin_level,
   apgr.sequence
  HEAD REPORT
   max_cnt = 10, cnt = 0
  HEAD cv.display
   cnt += 1, max_task_cnt = 10, task_cnt = 0,
   prefix_cnt = 0
   IF (cnt > max_cnt)
    stat = alter(temp->qual,(cnt+ 10)), max_cnt = (cnt+ 10)
   ENDIF
   stat = alterlist(temp->qual[cnt].task_qual,(task_cnt+ 10)), temp->qual[cnt].parent_entity_id = cv
   .code_value, temp->qual[cnt].grouper_disp = cv.display,
   temp->qual[cnt].grouper_disp_key = cv.display_key, temp->qual[cnt].grouper_desc = cv.description,
   temp->qual[cnt].active_ind = cv.active_ind
  DETAIL
   task_cnt += 1
   IF (task_cnt > max_task_cnt)
    stat = alterlist(temp->qual[cnt].task_qual,(task_cnt+ 10)), max_task_cnt = (task_cnt+ 10)
   ENDIF
   IF ((task_cnt > temp->max_task_assay_cd_val))
    temp->max_task_assay_cd_val = task_cnt
   ENDIF
   temp->qual[cnt].task_qual[task_cnt].task_assay_cd = apgr.task_assay_cd, temp->qual[cnt].task_qual[
   task_cnt].begin_section = apgr.begin_section, temp->qual[cnt].task_qual[task_cnt].begin_level =
   apgr.begin_level,
   temp->qual[cnt].task_qual[task_cnt].no_charge_ind = apgr.no_charge_ind, temp->qual[cnt].task_qual[
   task_cnt].sequence = apgr.sequence
  FOOT  cv.display
   stat = alterlist(temp->qual[cnt].task_qual,task_cnt)
  FOOT REPORT
   stat = alter(temp->qual,cnt)
  WITH nocounter
 ;end select
 FREE SET req200001
 FREE SET rep200001
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
 SELECT INTO "n1:"
  appg.prefix_id, appg.processing_grp_cd
  FROM ap_prefix_proc_grp_r appg
  PLAN (appg
   WHERE expand(prefix_idx,1,size(temp->qual,5),appg.processing_grp_cd,temp->qual[prefix_idx].
    parent_entity_id))
  ORDER BY appg.processing_grp_cd
  HEAD appg.processing_grp_cd
   prefix_cnt = 0, lindex = locateval(loc_idx,1,size(temp->qual,5),appg.processing_grp_cd,temp->qual[
    loc_idx].parent_entity_id)
  DETAIL
   prefix_idx = locateval(loc_idx,1,size(rep200001->prefix_qual,5),appg.prefix_id,rep200001->
    prefix_qual[loc_idx].prefix_cd)
   IF (prefix_idx > 0)
    prefix_cnt += 1
    IF (mod(prefix_cnt,10)=1)
     stat = alterlist(temp->qual[lindex].prefix_qual,(prefix_cnt+ 9))
    ENDIF
    temp->qual[lindex].prefix_qual[prefix_cnt].prefix_id = rep200001->prefix_qual[prefix_idx].
    prefix_cd, temp->qual[lindex].prefix_qual[prefix_cnt].prefix_disp = build(trim(rep200001->
      prefix_qual[prefix_idx].site_disp),rep200001->prefix_qual[prefix_idx].prefix_name)
   ENDIF
  FOOT  appg.processing_grp_cd
   stat = alterlist(temp->qual[lindex].prefix_qual,prefix_cnt)
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  grouper_disp = temp->qual[d1.seq].grouper_disp, begin_section = temp->qual[cnt].task_qual[task_cnt]
  .begin_section, begin_level = temp->qual[cnt].task_qual[task_cnt].begin_level,
  sequence = temp->qual[cnt].task_qual[task_cnt].sequence
  FROM (dummyt d1  WITH seq = value(size(temp->qual,5))),
   (dummyt d2  WITH seq = value(temp->max_task_assay_cd_val)),
   profile_task_r ptr,
   order_catalog oc,
   code_value cv
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->qual[d1.seq].task_qual,5)
    AND (temp->qual[d1.seq].task_qual[d2.seq].task_assay_cd != 0.0))
   JOIN (ptr
   WHERE (temp->qual[d1.seq].task_qual[d2.seq].task_assay_cd=ptr.task_assay_cd))
   JOIN (oc
   WHERE ptr.catalog_cd=oc.catalog_cd)
   JOIN (cv
   WHERE oc.activity_subtype_cd=cv.code_value
    AND cv.code_set=5801
    AND cv.cdf_meaning IN ("APPROCESS", "APBILLING")
    AND cv.active_ind=1)
  ORDER BY grouper_disp, begin_section, begin_level,
   sequence
  DETAIL
   temp->qual[d1.seq].task_qual[d2.seq].mnemonic = oc.primary_mnemonic
  WITH nocounter
 ;end select
#report_maker
 EXECUTE cpm_create_file_name_logical "apsDbProcGroups", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  temp->qual[d1.seq].parent_entity_id, grouper_disp = temp->qual[d1.seq].grouper_disp,
  grouper_disp_key = temp->qual[d1.seq].grouper_disp_key,
  grouper_desc = temp->qual[d1.seq].grouper_desc, active_ind = temp->qual[d1.seq].active_ind, temp->
  qual[d1.seq].task_qual[d2.seq].task_assay_cd,
  task_mnemonic = temp->qual[d1.seq].task_qual[d2.seq].mnemonic, begin_section = temp->qual[d1.seq].
  task_qual[d2.seq].begin_section, begin_level = temp->qual[d1.seq].task_qual[d2.seq].begin_level,
  no_charge_ind = temp->qual[d1.seq].task_qual[d2.seq].no_charge_ind, sequence = temp->qual[d1.seq].
  task_qual[d2.seq].sequence
  FROM (dummyt d1  WITH seq = value(size(temp->qual,5))),
   (dummyt d2  WITH seq = value(temp->max_task_assay_cd_val))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->qual[d1.seq].task_qual,5))
  ORDER BY grouper_disp, begin_section, begin_level,
   sequence
  HEAD REPORT
   line1 = fillstring(125,"-")
  HEAD PAGE
   row + 1, col 0, captions->rptaps,
   CALL center(captions->pathap,0,132), col 110, captions->ddate,
   ":", cdate = format(curdate,"@SHORTDATE;;d"), col 117,
   cdate, row + 1, col 0,
   captions->dir, ":", col 110,
   captions->ttime, ":", col 117,
   curtime, row + 1,
   CALL center(captions->rda,0,132),
   col 112, captions->bby, ":",
   col 117, request->scuruser"##############", row + 1,
   CALL center(captions->dbpgtt,0,132), col 110, captions->ppage,
   ":", col 117, curpage"###",
   row + 2
  HEAD grouper_disp
   IF (((row+ 12) > maxrow))
    BREAK
   ENDIF
   row + 1, col 0, captions->grptsk,
   ": ", col 13, grouper_disp,
   row + 1, col 13, grouper_desc,
   row + 1, col 13, captions->status,
   ": ", col 22
   IF (active_ind=1)
    captions->active
   ELSE
    captions->inactive
   ENDIF
   row + 2, col 0, captions->cmptsk,
   col 27, captions->blkseq, col 43,
   captions->sldseq, col 59, captions->nochrg,
   row + 1, col 0, "-------------------------",
   col 27, "--------------", col 43,
   "--------------", col 59, "---------"
  DETAIL
   row + 1, col 0, temp->qual[d1.seq].task_qual[d2.seq].mnemonic
   IF ((temp->qual[d1.seq].task_qual[d2.seq].begin_section > 0))
    col 27, temp->qual[d1.seq].task_qual[d2.seq].begin_section
   ENDIF
   IF ((temp->qual[d1.seq].task_qual[d2.seq].begin_level > 0))
    col 43, temp->qual[d1.seq].task_qual[d2.seq].begin_level
   ENDIF
   col 59
   IF ((temp->qual[d1.seq].task_qual[d2.seq].no_charge_ind > 0))
    captions->nochrg
   ELSE
    ""
   ENDIF
   IF (((row+ 12) > maxrow))
    BREAK
   ENDIF
  FOOT  grouper_disp
   row + 1, col 0, captions->prefix
   IF (size(temp->qual[d1.seq].prefix_qual,5)=0)
    col + 1, captions->none
   ELSE
    FOR (prefix_itr = 1 TO size(temp->qual[d1.seq].prefix_qual,5))
      IF ((temp->qual[d1.seq].prefix_qual[prefix_itr].prefix_id != 0))
       IF (prefix_itr=1)
        col + 1, temp->qual[d1.seq].prefix_qual[prefix_itr].prefix_disp
       ENDIF
       IF (col > 100)
        new_row_ind = 1
        IF (((row+ 12) > maxrow))
         BREAK
        ENDIF
        row + 1, col 22, temp->qual[d1.seq].prefix_qual[prefix_itr].prefix_disp
       ENDIF
       IF (prefix_itr != 1
        AND new_row_ind != 1)
        temp_string = build(", ",temp->qual[d1.seq].prefix_qual[prefix_itr].prefix_disp), col + 1,
        temp_string
       ENDIF
       new_row_ind = 0
      ENDIF
    ENDFOR
   ENDIF
   row + 1,
   CALL center("* * * * * * * * * * *",0,132)
   IF (((row+ 12) > maxrow))
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
 FREE SET instrument_list
 FREE SET temp
 FREE SET captions
END GO
