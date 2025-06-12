CREATE PROGRAM aps_prt_db_group_and_prefix:dba
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
   1 dir = vc
   1 ttime = vc
   1 rda = vc
   1 bby = vc
   1 dbgandpt = vc
   1 ppage = vc
   1 status = vc
   1 sitecd = vc
   1 grpcd = vc
   1 grpdesc = vc
   1 resetyr = vc
   1 manassign = vc
   1 nextavl = vc
   1 inactive = vc
   1 active = vc
   1 none = vc
   1 yep = vc
   1 nope = vc
   1 agrp = vc
   1 prefix = vc
   1 init = vc
   1 id = vc
   1 code = vc
   1 prefdesc = vc
   1 casetype = vc
   1 ocproc = vc
   1 taskdef = vc
   1 tasks = vc
   1 scheme = vc
   1 cont = vc
   1 service_resource = vc
   1 interface_type = vc
   1 interface_resource = vc
   1 tracking = vc
   1 imaging = vc
   1 off = vc
   1 onn = vc
 )
 SET captions->rptaps = uar_i18ngetmessage(i18nhandle,"rptaps",
  "REPORT: APS_PRT_DB_GROUP_AND_PREFIX.PRG")
 SET captions->pathap = uar_i18ngetmessage(i18nhandle,"pathap","PATHNET ANATOMIC PATHOLOGY")
 SET captions->ddate = uar_i18ngetmessage(i18nhandle,"ddate","DATE")
 SET captions->dir = uar_i18ngetmessage(i18nhandle,"dir","DIRECTORY")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"ttime","TIME")
 SET captions->rda = uar_i18ngetmessage(i18nhandle,"rda","REFERENCE DATABASE AUDIT")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"bby","BY")
 SET captions->dbgandpt = uar_i18ngetmessage(i18nhandle,"dbgandpt","DB GROUP AND PREFIX TOOL")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"ppage","PAGE")
 SET captions->status = uar_i18ngetmessage(i18nhandle,"status","STATUS")
 SET captions->sitecd = uar_i18ngetmessage(i18nhandle,"sitecd","SITE CODE")
 SET captions->grpcd = uar_i18ngetmessage(i18nhandle,"grpcd","GROUP CODE")
 SET captions->grpdesc = uar_i18ngetmessage(i18nhandle,"grpdesc","GROUP DESCRIPTION")
 SET captions->resetyr = uar_i18ngetmessage(i18nhandle,"resetyr","RESET YEARLY")
 SET captions->manassign = uar_i18ngetmessage(i18nhandle,"manassign","ALLOW MANUAL ASSIGN")
 SET captions->nextavl = uar_i18ngetmessage(i18nhandle,"nxtavl","NEXT AVAILABLE NUMBER")
 SET captions->inactive = uar_i18ngetmessage(i18nhandle,"inactive","INACTIVE")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"active","ACTIVE")
 SET captions->none = uar_i18ngetmessage(i18nhandle,"none","NONE")
 SET captions->yep = uar_i18ngetmessage(i18nhandle,"yep","YES")
 SET captions->nope = uar_i18ngetmessage(i18nhandle,"nope","NO")
 SET captions->agrp = uar_i18ngetmessage(i18nhandle,"agrp","ACCESSION GROUP")
 SET captions->prefix = uar_i18ngetmessage(i18nhandle,"prefix","PREFIX")
 SET captions->init = uar_i18ngetmessage(i18nhandle,"init","INITIATE")
 SET captions->id = uar_i18ngetmessage(i18nhandle,"id","ID")
 SET captions->code = uar_i18ngetmessage(i18nhandle,"code","CODE")
 SET captions->prefdesc = uar_i18ngetmessage(i18nhandle,"prefdesc","PREFIX DESCRIPTION")
 SET captions->casetype = uar_i18ngetmessage(i18nhandle,"casetype","CASE TYPE")
 SET captions->ocproc = uar_i18ngetmessage(i18nhandle,"ocproc","ORDER CATALOG PROCEDURE")
 SET captions->taskdef = uar_i18ngetmessage(i18nhandle,"taskdef","TASK DEFAULT")
 SET captions->tasks = uar_i18ngetmessage(i18nhandle,"tasks","TASKS?")
 SET captions->scheme = uar_i18ngetmessage(i18nhandle,"scheme","SCHEME")
 SET captions->cont = uar_i18ngetmessage(i18nhandle,"cont","CONTINUED...")
 SET captions->service_resource = uar_i18ngetmessage(i18nhandle,"service_resource","SERVICE RESOURCE"
  )
 SET captions->interface_type = uar_i18ngetmessage(i18nhandle,"interface_type","INTERFACE TYPE")
 SET captions->interface_resource = uar_i18ngetmessage(i18nhandle,"interface_resource",
  "INTERFACE RESOURCE")
 SET captions->tracking = uar_i18ngetmessage(i18nhandle,"tracking","Tracking -")
 SET captions->imaging = uar_i18ngetmessage(i18nhandle,"imaging","Imaging  -")
 SET captions->off = uar_i18ngetmessage(i18nhandle,"off"," OFF")
 SET captions->onn = uar_i18ngetmessage(i18nhandle,"onn"," ON")
 RECORD temp(
   1 max_prefixes = i4
   1 max_schemes = i4
   1 group_qual[*]
     2 group_cd = f8
     2 group_name = c2
     2 group_desc = c40
     2 site_cd = f8
     2 site_disp = c40
     2 reset_yearly_ind = i2
     2 manual_assign_ind = i2
     2 active_ind = i2
     2 next_available_nbr = i4
     2 prefix_qual[*]
       3 prefix_cd = f8
       3 prefix_desc = c30
       3 prefix_name = c4
       3 case_type_cd = f8
       3 case_type_disp = c9
       3 order_catalog_cd = f8
       3 order_catalog_desc = vc
       3 task_default_cd = f8
       3 task_default_disp = c40
       3 initiate_tasks_ind = i2
       3 active_ind = i2
       3 id_scheme = c40
       3 pre_tag_qual[*]
         4 tag_group_cd = f8
         4 tag_type_flag = i2
         4 first_tag_disp = c7
         4 tag_separator = c1
       3 service_resource_cd = f8
       3 service_resource_disp = c40
       3 tracking_interface_flag = i2
       3 tracking_service_resource_cd = f8
       3 tracking_service_resource_disp = c40
       3 imaging_interface_ind = i2
       3 imaging_service_resource_cd = f8
       3 imaging_service_resource_disp = c40
   1 task_default_qual[*]
     2 task_cd = f8
     2 task_desc = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
 SET acc_frmt_cnt = 0
 SET group_cnt = 0
 SET prefix_cnt = 0
 SET pre_tag_cnt = 0
 SET max_task_cnt = 0
 SET task_cnt = 0
 SET cnt = 0
 SET already_removed = 0
 SET add_default = 0
 SET _acc_assign_date = cnvtdatetimeutc(cnvtdatetime(cnvtdate2(concat("0101",cnvtstring(year(curdate),
      4,0,r)),"mmddyyyy"),0),2)
 SET stat = alterlist(temp->group_qual,1)
 SET stat = alterlist(temp->group_qual[1].prefix_qual,1)
 SET stat = alterlist(temp->group_qual[1].prefix_qual[1].pre_tag_qual,1)
 SET stat = alterlist(temp->task_default_qual,10)
 SELECT INTO "nl:"
  pg.group_id, ap.prefix_id, tg.tag_group_id,
  tg.tag_type_flag, tg.tag_separator, t.tag_disp,
  casetypedispval = uar_get_code_display(ap.case_type_cd), taskdefdispval = uar_get_code_display(ap
   .default_proc_catalog_cd), serviceresourcedispval = uar_get_code_display(ap.service_resource_cd),
  trackingresourcedispval = uar_get_code_display(ap.tracking_service_resource_cd),
  imagingresourcedispval = uar_get_code_display(ap.imaging_service_resource_cd), group_exists =
  evaluate(nullind(ap.group_id),1,0,1),
  catalog_exists = evaluate(nullind(oc.catalog_cd),1,0,1), tag_prefix_id_exists = evaluate(nullind(tg
    .prefix_id),1,0,1)
  FROM prefix_group pg,
   accession_assign_pool aap,
   accession_assignment aa,
   ap_prefix ap,
   order_catalog oc,
   ap_prefix_tag_group_r tg,
   ap_tag t
  PLAN (pg)
   JOIN (aap
   WHERE pg.group_id=aap.accession_assignment_pool_id)
   JOIN (aa
   WHERE (aa.acc_assign_pool_id= Outerjoin(pg.group_id))
    AND (aa.acc_assign_date= Outerjoin(cnvtdatetimeutc(_acc_assign_date,0))) )
   JOIN (ap
   WHERE (ap.group_id= Outerjoin(pg.group_id)) )
   JOIN (oc
   WHERE (oc.catalog_cd= Outerjoin(ap.order_catalog_cd)) )
   JOIN (tg
   WHERE (tg.prefix_id= Outerjoin(ap.prefix_id)) )
   JOIN (t
   WHERE tg.tag_group_id=t.tag_group_id
    AND 1=t.tag_sequence
    AND 1=t.active_ind)
  ORDER BY pg.active_ind DESC, pg.site_cd, pg.group_name,
   ap.prefix_name, tg.tag_type_flag
  HEAD REPORT
   group_cnt = 0
  HEAD pg.group_id
   IF (pg.group_id > 0.0)
    prefix_cnt = 0, group_cnt += 1, stat = alterlist(temp->group_qual,group_cnt),
    temp->group_qual[group_cnt].group_cd = pg.group_id, temp->group_qual[group_cnt].group_name = pg
    .group_name, temp->group_qual[group_cnt].group_desc = pg.group_desc,
    temp->group_qual[group_cnt].site_cd = pg.site_cd, temp->group_qual[group_cnt].site_disp =
    uar_get_code_display(pg.site_cd), temp->group_qual[group_cnt].reset_yearly_ind = pg
    .reset_yearly_ind,
    temp->group_qual[group_cnt].manual_assign_ind = pg.manual_assign_ind, temp->group_qual[group_cnt]
    .active_ind = pg.active_ind
    IF (aa.acc_assign_pool_id > 0.0)
     temp->group_qual[group_cnt].next_available_nbr = aa.accession_seq_nbr
    ELSE
     temp->group_qual[group_cnt].next_available_nbr = aap.initial_value
    ENDIF
   ENDIF
  HEAD ap.prefix_id
   IF (group_exists=1)
    IF (ap.prefix_id > 0.0)
     prefix_cnt += 1, stat = alterlist(temp->group_qual[group_cnt].prefix_qual,prefix_cnt)
     IF ((prefix_cnt > temp->max_prefixes))
      temp->max_prefixes = prefix_cnt
     ENDIF
     temp->group_qual[group_cnt].prefix_qual[prefix_cnt].prefix_cd = ap.prefix_id, temp->group_qual[
     group_cnt].prefix_qual[prefix_cnt].prefix_desc = ap.prefix_desc, temp->group_qual[group_cnt].
     prefix_qual[prefix_cnt].prefix_name = ap.prefix_name,
     temp->group_qual[group_cnt].prefix_qual[prefix_cnt].case_type_cd = ap.case_type_cd, temp->
     group_qual[group_cnt].prefix_qual[prefix_cnt].case_type_disp = casetypedispval, temp->
     group_qual[group_cnt].prefix_qual[prefix_cnt].order_catalog_cd = ap.order_catalog_cd,
     temp->group_qual[group_cnt].prefix_qual[prefix_cnt].initiate_tasks_ind = ap
     .initiate_protocol_ind, temp->group_qual[group_cnt].prefix_qual[prefix_cnt].task_default_cd = ap
     .default_proc_catalog_cd, temp->group_qual[group_cnt].prefix_qual[prefix_cnt].task_default_disp
      = taskdefdispval,
     temp->group_qual[group_cnt].prefix_qual[prefix_cnt].active_ind = ap.active_ind, temp->
     group_qual[group_cnt].prefix_qual[prefix_cnt].service_resource_cd = ap.service_resource_cd, temp
     ->group_qual[group_cnt].prefix_qual[prefix_cnt].service_resource_disp = serviceresourcedispval,
     temp->group_qual[group_cnt].prefix_qual[prefix_cnt].tracking_interface_flag = ap.interface_flag,
     temp->group_qual[group_cnt].prefix_qual[prefix_cnt].tracking_service_resource_cd = ap
     .tracking_service_resource_cd, temp->group_qual[group_cnt].prefix_qual[prefix_cnt].
     tracking_service_resource_disp = trackingresourcedispval,
     temp->group_qual[group_cnt].prefix_qual[prefix_cnt].imaging_interface_ind = ap
     .imaging_interface_ind, temp->group_qual[group_cnt].prefix_qual[prefix_cnt].
     imaging_service_resource_cd = ap.imaging_service_resource_cd, temp->group_qual[group_cnt].
     prefix_qual[prefix_cnt].imaging_service_resource_disp = imagingresourcedispval
     IF (catalog_exists=1)
      temp->group_qual[group_cnt].prefix_qual[prefix_cnt].order_catalog_desc = oc.primary_mnemonic
     ENDIF
     pre_tag_cnt = 0
    ENDIF
   ENDIF
  DETAIL
   IF (tag_prefix_id_exists=1)
    IF (prefix_cnt > 0)
     IF (tg.tag_group_id > 0)
      pre_tag_cnt += 1, stat = alterlist(temp->group_qual[group_cnt].prefix_qual[prefix_cnt].
       pre_tag_qual,pre_tag_cnt)
      IF ((pre_tag_cnt > temp->max_schemes))
       temp->max_schemes = pre_tag_cnt
      ENDIF
      temp->group_qual[group_cnt].prefix_qual[prefix_cnt].pre_tag_qual[pre_tag_cnt].tag_group_cd = tg
      .tag_group_id, temp->group_qual[group_cnt].prefix_qual[prefix_cnt].pre_tag_qual[pre_tag_cnt].
      tag_type_flag = tg.tag_type_flag, temp->group_qual[group_cnt].prefix_qual[prefix_cnt].
      pre_tag_qual[pre_tag_cnt].tag_separator = tg.tag_separator,
      temp->group_qual[group_cnt].prefix_qual[prefix_cnt].pre_tag_qual[pre_tag_cnt].first_tag_disp =
      t.tag_disp
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  group_name = temp->group_qual[d1.seq].group_name, group_cd = temp->group_qual[d1.seq].group_cd,
  prefix_name = temp->group_qual[d1.seq].prefix_qual[d2.seq].prefix_name,
  prefix_cd = temp->group_qual[d1.seq].prefix_qual[d2.seq].prefix_cd, tag_group_cd = temp->
  group_qual[d1.seq].prefix_qual[d2.seq].pre_tag_qual[d3.seq].tag_group_cd, tag_type_flag = temp->
  group_qual[d1.seq].prefix_qual[d2.seq].pre_tag_qual[d3.seq].tag_type_flag,
  first_tag_disp = temp->group_qual[d1.seq].prefix_qual[d2.seq].pre_tag_qual[d3.seq].first_tag_disp,
  tag_separator = temp->group_qual[d1.seq].prefix_qual[d2.seq].pre_tag_qual[d3.seq].tag_separator
  FROM (dummyt d1  WITH seq = value(size(temp->group_qual,5))),
   (dummyt d2  WITH seq = value(temp->max_prefixes)),
   (dummyt d3  WITH seq = value(temp->max_schemes))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->group_qual[d1.seq].prefix_qual,5))
   JOIN (d3
   WHERE d3.seq <= size(temp->group_qual[d1.seq].prefix_qual[d2.seq].pre_tag_qual,5))
  ORDER BY group_cd, prefix_cd, tag_type_flag
  HEAD group_cd
   id_scheme = fillstring(40," ")
  HEAD prefix_cd
   id_scheme = fillstring(40," ")
  HEAD tag_type_flag
   IF (tag_type_flag=1)
    id_scheme = build(id_scheme,first_tag_disp)
   ENDIF
   IF (tag_type_flag > 1)
    id_scheme = build(id_scheme,tag_separator,first_tag_disp)
   ENDIF
   temp->group_qual[d1.seq].prefix_qual[d2.seq].id_scheme = id_scheme
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.code_value, agi.parent_entity_id
  FROM code_value cv,
   ap_processing_grp_r agi
  PLAN (cv
   WHERE 1310=cv.code_set
    AND 1=cv.active_ind)
   JOIN (agi
   WHERE agi.parent_entity_id=cv.code_value
    AND agi.parent_entity_name="CODE_VALUE")
  HEAD REPORT
   cnt = 0
  HEAD cv.code_value
   already_removed = 0
  DETAIL
   IF (already_removed=0
    AND (agi.begin_section=- (1)))
    already_removed = 1
   ENDIF
  FOOT  cv.code_value
   IF (already_removed=0)
    cnt += 1
    IF (mod(cnt,10)=1
     AND cnt != 1)
     stat = alterlist(temp->task_default_qual,(cnt+ 9))
    ENDIF
    temp->task_default_qual[cnt].task_cd = cv.code_value, temp->task_default_qual[cnt].task_desc = cv
    .display
   ENDIF
  FOOT REPORT
   stat = alterlist(temp->task_default_qual,cnt)
  WITH nocounter
 ;end select
#report_maker
 EXECUTE cpm_create_file_name_logical "apsDbPrefix", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  group_active_ind = temp->group_qual[d1.seq].active_ind, site_disp = trim(temp->group_qual[d1.seq].
   site_disp), group_name = trim(temp->group_qual[d1.seq].group_name),
  group_desc = trim(temp->group_qual[d1.seq].group_desc), reset_yearly_ind = temp->group_qual[d1.seq]
  .reset_yearly_ind, manually_assign = temp->group_qual[d1.seq].manual_assign_ind,
  next_available_nbr = temp->group_qual[d1.seq].next_available_nbr, prefix_active_ind = temp->
  group_qual[d1.seq].prefix_qual[d2.seq].active_ind, prefix_name = temp->group_qual[d1.seq].
  prefix_qual[d2.seq].prefix_name,
  site_and_prefix = build(trim(temp->group_qual[d1.seq].site_disp),trim(temp->group_qual[d1.seq].
    prefix_qual[d2.seq].prefix_name))
  FROM (dummyt d1  WITH seq = value(size(temp->group_qual,5))),
   (dummyt d2  WITH seq = value(temp->max_prefixes)),
   (dummyt d3  WITH seq = value(temp->max_schemes))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->group_qual[d1.seq].prefix_qual,5))
   JOIN (d3
   WHERE d3.seq <= size(temp->group_qual[d1.seq].prefix_qual[d2.seq].pre_tag_qual,5))
  ORDER BY group_active_ind DESC, site_disp, group_name,
   prefix_name
  HEAD REPORT
   already_printed = "N", line1 = fillstring(125,"-"), beg_val = 1,
   print_group_header = "N"
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
   CALL center(captions->dbgandpt,0,132), col 110, captions->ppage,
   ":", col 117, curpage"###",
   row + 2
  HEAD group_name
   IF (already_printed="N")
    already_printed = "Y"
    FOR (loop = 1 TO value(size(temp->group_qual,5)))
      IF (((row+ 6) > maxrow))
       print_group_header = "Y", BREAK
      ENDIF
      IF (((loop=1) OR (print_group_header="Y")) )
       print_group_header = "N", row + 1, col 0,
       captions->status, col 9, captions->sitecd,
       col 20, captions->grpcd, col 32,
       captions->grpdesc, col 74, captions->resetyr,
       col 88, captions->manassign, col 109,
       captions->nextavl, row + 1, col 0,
       "--------", col 9, "---------",
       col 20, "----------", col 32,
       "----------------------------------------", col 74, "------------",
       col 88, "-------------------", col 109,
       "---------------------"
      ENDIF
      row + 1, col 0
      IF ((temp->group_qual[loop].active_ind=0))
       captions->inactive
      ELSE
       captions->active
      ENDIF
      col 9
      IF ((temp->group_qual[loop].site_cd=0.0))
       captions->none
      ELSE
       temp->group_qual[loop].site_disp"#########"
      ENDIF
      col 20, temp->group_qual[loop].group_name"##########", col 32,
      temp->group_qual[loop].group_desc"##############################", col 74
      IF ((temp->group_qual[loop].reset_yearly_ind=1))
       captions->yep
      ELSE
       captions->nope
      ENDIF
      col 88
      IF ((temp->group_qual[loop].manual_assign_ind=1))
       captions->yep
      ELSE
       captions->nope
      ENDIF
      col 109, temp->group_qual[loop].next_available_nbr
    ENDFOR
    row + 1
   ENDIF
   IF (((row+ 12) > maxrow))
    BREAK
   ENDIF
   row + 1, col 0, captions->agrp,
   ":", col 18, temp->group_qual[d1.seq].group_name,
   ", ", temp->group_qual[d1.seq].group_desc, row + 2,
   col 9, captions->prefix, col 17,
   captions->prefdesc, col 58, captions->ocproc,
   col 83, captions->taskdef, col 105,
   captions->init, col 115, captions->id,
   row + 1, col 0, captions->status,
   col 9, captions->code, col 19,
   captions->service_resource, col 47, captions->casetype,
   col 60, captions->interface_type, col 85,
   captions->interface_resource, col 105, captions->tasks,
   col 115, captions->scheme, row + 1,
   col 0, "--------", col 9,
   "-------", col 17, "-----------------------------",
   col 47, "---------", col 58,
   "-----------------------", col 83, "--------------------",
   col 105, "--------", col 115,
   "----------------"
  HEAD prefix_name
   row + 1, col 0
   IF ((temp->group_qual[d1.seq].prefix_qual[d2.seq].active_ind=1))
    captions->active
   ELSE
    captions->inactive
   ENDIF
   col 9, site_and_prefix"#######", col 17,
   temp->group_qual[d1.seq].prefix_qual[d2.seq].prefix_desc"#############################", col 47,
   temp->group_qual[d1.seq].prefix_qual[d2.seq].case_type_disp"#########",
   col 58, temp->group_qual[d1.seq].prefix_qual[d2.seq].order_catalog_desc"#######################",
   col 83
   IF ((temp->group_qual[d1.seq].prefix_qual[d2.seq].task_default_cd=0.0))
    captions->none"####################"
   ELSE
    temp->group_qual[d1.seq].prefix_qual[d2.seq].task_default_disp"####################"
   ENDIF
   col 105
   IF ((temp->group_qual[d1.seq].prefix_qual[d2.seq].initiate_tasks_ind=1))
    captions->yep
   ELSE
    captions->nope
   ENDIF
   col 115, temp->group_qual[d1.seq].prefix_qual[d2.seq].id_scheme"###############", row + 1,
   col 19
   IF ((temp->group_qual[d1.seq].prefix_qual[d2.seq].service_resource_cd=0.0))
    captions->none"###########################"
   ELSE
    temp->group_qual[d1.seq].prefix_qual[d2.seq].service_resource_disp"###########################"
   ENDIF
   col 60
   IF ((temp->group_qual[d1.seq].prefix_qual[d2.seq].tracking_interface_flag=1))
    trackingonoff = concat(captions->tracking,captions->onn)
   ELSE
    trackingonoff = concat(captions->tracking,captions->off)
   ENDIF
   trackingonoff"#####################", col 85
   IF ((temp->group_qual[d1.seq].prefix_qual[d2.seq].tracking_service_resource_cd=0.0))
    captions->none"##################"
   ELSE
    temp->group_qual[d1.seq].prefix_qual[d2.seq].tracking_service_resource_disp"##################"
   ENDIF
   row + 1, col 60
   IF ((temp->group_qual[d1.seq].prefix_qual[d2.seq].imaging_interface_ind=1))
    imagingonoff = concat(captions->imaging,captions->onn)
   ELSE
    imagingonoff = concat(captions->imaging,captions->off)
   ENDIF
   imagingonoff"#####################", col 85
   IF ((temp->group_qual[d1.seq].prefix_qual[d2.seq].imaging_service_resource_cd=0.0))
    captions->none"##################"
   ELSE
    temp->group_qual[d1.seq].prefix_qual[d2.seq].imaging_service_resource_disp"##################"
   ENDIF
   IF (((row+ 12) > maxrow))
    BREAK
   ENDIF
  FOOT  group_name
   row + 1
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
  WITH nocounter, maxcol = 135, nullreport,
   maxrow = 63, compress
 ;end select
 SET reply->status_data.status = "S"
END GO
