CREATE PROGRAM aps_prt_db_image_stations:dba
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
   1 dbist = vc
   1 ppage = vc
   1 imgstn = vc
   1 srcdvc = vc
   1 prefix = vc
   1 rpt = vc
   1 rptcmpt = vc
   1 chrtbl = vc
   1 cont = vc
   1 endrpt = vc
   1 no = vc
   1 yes = vc
   1 sourcedevice = vc
   1 activeind = vc
   1 stationassoc = vc
   1 none = vc
   1 digitaltrayurl = vc
   1 networksharepath = vc
   1 username = vc
   1 password = vc
   1 imageserverurl = vc
 )
 SET captions->rptaps = uar_i18ngetmessage(i18nhandle,"rptaps",
  "REPORT: APS_PRT_DB_IMAGE_STATIONS.PRG")
 SET captions->pathap = uar_i18ngetmessage(i18nhandle,"pathap","PATHNET ANATOMIC PATHOLOGY")
 SET captions->ddate = uar_i18ngetmessage(i18nhandle,"ddate","DATE")
 SET captions->dir = uar_i18ngetmessage(i18nhandle,"dir","DIRECTORY")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"ttime","TIME")
 SET captions->rda = uar_i18ngetmessage(i18nhandle,"rda","REFERENCE DATABASE AUDIT")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"bby","BY")
 SET captions->dbist = uar_i18ngetmessage(i18nhandle,"dbist","DB IMAGING STATION TOOL")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"ppage","PAGE")
 SET captions->imgstn = uar_i18ngetmessage(i18nhandle,"imgstn","IMAGING STATION")
 SET captions->srcdvc = uar_i18ngetmessage(i18nhandle,"srcdvc","SOURCE DEVICE")
 SET captions->prefix = uar_i18ngetmessage(i18nhandle,"prefix","PREFIX")
 SET captions->rpt = uar_i18ngetmessage(i18nhandle,"rpt","REPORT")
 SET captions->rptcmpt = uar_i18ngetmessage(i18nhandle,"rptcmpt","REPORT COMPONENTS")
 SET captions->chrtbl = uar_i18ngetmessage(i18nhandle,"chrtbl","CHARTABLE")
 SET captions->cont = uar_i18ngetmessage(i18nhandle,"cont","(Cont.)")
 SET captions->endrpt = uar_i18ngetmessage(i18nhandle,"endrpt","END OF REPORT")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"NO","NO")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"YES","YES")
 SET captions->sourcedevice = uar_i18ngetmessage(i18nhandle,"SOURCE DEVICE","SOURCE DEVICE")
 SET captions->activeind = uar_i18ngetmessage(i18nhandle,"ACTIVE","ACTIVE")
 SET captions->stationassoc = uar_i18ngetmessage(i18nhandle,"STATIONASSOC","STATION ASSOCIATIONS")
 SET captions->none = uar_i18ngetmessage(i18nhandle,"NONE","NONE")
 SET captions->digitaltrayurl = uar_i18ngetmessage(i18nhandle,"digitalTrayUrl","DIGITAL TRAY URL")
 SET captions->networksharepath = uar_i18ngetmessage(i18nhandle,"networkSharePath",
  "NETWORK SHARE PATH")
 SET captions->username = uar_i18ngetmessage(i18nhandle,"username","USERNAME")
 SET captions->password = uar_i18ngetmessage(i18nhandle,"password","PASSWORD")
 SET captions->imageserverurl = uar_i18ngetmessage(i18nhandle,"imageServerURL","IMAGE SERVER URL")
 RECORD temp(
   1 station_qual[*]
     2 station_disp = c40
     2 source_device_disp = c40
     2 prefix_disp = c2
     2 site_disp = c5
     2 catalog_disp = c40
     2 task_assay_disp = c40
     2 publish_disp = c3
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD source(
   1 source_qual[*]
     2 source_device = c60
     2 active_ind = c3
     2 source_device_url = vc
     2 network_share_path = vc
     2 device_username = vc
     2 device_password = vc
     2 image_server_url = vc
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
 SET reply->status_data.status = "F"
 SET station_cnt = 0
 SET prefix_cnt = 0
 SET source_cnt = 0
 SELECT INTO "nl:"
  FROM code_value cv,
   ap_source_device_addl asda
  PLAN (cv
   WHERE cv.code_set=19369)
   JOIN (asda
   WHERE asda.source_device_cd=outerjoin(cv.code_value))
  ORDER BY cnvtupper(cv.description)
  HEAD REPORT
   source_cnt = 0, stat = alterlist(source->source_qual,10)
  DETAIL
   source_cnt = (source_cnt+ 1)
   IF (mod(source_cnt,10)=1)
    stat = alterlist(source->source_qual,(source_cnt+ 9))
   ENDIF
   source->source_qual[source_cnt].source_device = cv.description
   IF (cv.active_ind=1)
    source->source_qual[source_cnt].active_ind = captions->yes
   ELSE
    source->source_qual[source_cnt].active_ind = captions->no
   ENDIF
   IF (asda.source_device_cd > 0)
    source->source_qual[source_cnt].source_device_url = asda.source_device_url, source->source_qual[
    source_cnt].network_share_path = asda.network_share_path, source->source_qual[source_cnt].
    device_username = asda.device_username,
    source->source_qual[source_cnt].device_password = asda.device_password, source->source_qual[
    source_cnt].image_server_url = asda.image_server_url
   ENDIF
  FOOT REPORT
   stat = alterlist(source->source_qual,source_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ais.station_id, apsr.station_id, apsr.prefix_id,
  ap.prefix_id, sourcedevicedisp =
  IF (ais.source_device_cd > 0) uar_get_code_display(ais.source_device_cd)
  ELSE captions->none
  ENDIF
  , sitedisp = uar_get_code_display(ap.site_cd),
  catalogdisp = uar_get_code_display(apsr.catalog_cd), taskassaydisp = uar_get_code_display(apsr
   .task_assay_cd)
  FROM ap_image_station ais,
   ap_prefix_station_r apsr,
   ap_prefix ap
  PLAN (ais)
   JOIN (apsr
   WHERE apsr.station_id=outerjoin(ais.station_id))
   JOIN (ap
   WHERE ap.prefix_id=outerjoin(apsr.prefix_id))
  HEAD REPORT
   station_cnt = 0, stat = alterlist(temp->station_qual,10)
  DETAIL
   station_cnt = (station_cnt+ 1)
   IF (mod(station_cnt,10)=1
    AND station_cnt != 1)
    stat = alterlist(temp->station_qual,(station_cnt+ 9))
   ENDIF
   temp->station_qual[station_cnt].station_disp = ais.station_name, temp->station_qual[station_cnt].
   source_device_disp = sourcedevicedisp, temp->station_qual[station_cnt].prefix_disp = ap
   .prefix_name
   IF (size(trim(sitedisp,1),1) > 0)
    temp->station_qual[station_cnt].site_disp = format(sitedisp,"#####;P0")
   ENDIF
   temp->station_qual[station_cnt].catalog_disp = catalogdisp, temp->station_qual[station_cnt].
   task_assay_disp = taskassaydisp
   IF (ap.prefix_id > 0)
    IF (apsr.publish_flag)
     temp->station_qual[station_cnt].publish_disp = captions->yes
    ELSE
     temp->station_qual[station_cnt].publish_disp = captions->no
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(temp->station_qual,station_cnt)
  WITH nocounter
 ;end select
#report_maker
 EXECUTE cpm_create_file_name_logical "apsDbImaging", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  station_disp = temp->station_qual[d1.seq].station_disp, station_disp_upper = cnvtupper(temp->
   station_qual[d1.seq].station_disp), source_disp = temp->station_qual[d1.seq].source_device_disp,
  catalog_disp = temp->station_qual[d1.seq].catalog_disp, task_assay_disp = temp->station_qual[d1.seq
  ].task_assay_disp, chartable_disp = temp->station_qual[d1.seq].publish_disp,
  site_and_prefix_disp = build(trim(temp->station_qual[d1.seq].site_disp),trim(temp->station_qual[d1
    .seq].prefix_disp)), site_and_prefix_disp_upper = cnvtupper(build(trim(temp->station_qual[d1.seq]
     .site_disp),trim(temp->station_qual[d1.seq].prefix_disp)))
  FROM (dummyt d1  WITH seq = value(size(temp->station_qual,5)))
  PLAN (d1)
  ORDER BY station_disp_upper, site_and_prefix_disp_upper
  HEAD REPORT
   already_printed_source_device_section = "N"
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
   CALL center(captions->dbist,0,132), col 110, captions->ppage,
   ":", col 117, curpage"###"
   IF (already_printed_source_device_section="N")
    already_printed_source_device_section = "Y"
    IF ((request->source_ind=1))
     row + 2,
     CALL center(captions->sourcedevice,0,132), row + 1,
     CALL center("* * * * * * * * * * * * * * * * * * * *",0,132), row + 2, col 39,
     captions->digitaltrayurl, col 103, captions->username,
     row + 1, col 0, captions->sourcedevice,
     col 41, captions->networksharepath, col 105,
     captions->password, col 125, captions->activeind,
     row + 1, col 43, captions->imageserverurl,
     row + 1, col 0, "------------------------------------",
     col 39, "--------------------------------------------------------------", col 103,
     "--------------------", col 125, "------",
     num_source = value(cnvtint(size(source->source_qual,5)))
     FOR (x = 1 TO num_source)
       row + 1, col 0, source->source_qual[x].source_device"####################################",
       col 39, source->source_qual[x].source_device_url
       "##############################################################", col 103,
       source->source_qual[x].device_username"####################", col 125, source->source_qual[x].
       active_ind"#####",
       row + 1, col 41, source->source_qual[x].network_share_path
       "############################################################",
       col 105, source->source_qual[x].device_password"##################", row + 1,
       col 43, source->source_qual[x].image_server_url
       "############################################################"
     ENDFOR
    ENDIF
   ENDIF
   IF ((request->association_ind=1))
    row + 2,
    CALL center(captions->stationassoc,0,132), row + 1,
    CALL center("* * * * * * * * * * * * * * * * * * * *",0,132), row + 2, col 0,
    captions->imgstn, col 32, captions->srcdvc,
    col 58, captions->prefix, col 67,
    captions->rpt, col 94, captions->rptcmpt,
    col 121, captions->chrtbl, row + 1,
    col 0, "------------------------------", col 32,
    "------------------------", col 58, "-------",
    col 67, "-------------------------", col 94,
    "-------------------------", col 121, "----------",
    row + 1
   ENDIF
  HEAD station_disp_upper
   IF ((request->association_ind=1))
    IF (((row+ 11) > maxrow))
     BREAK
    ENDIF
    col 0, station_disp"##############################", col 32,
    source_disp"########################"
   ENDIF
  DETAIL
   IF ((request->association_ind=1))
    IF (((row+ 10) > maxrow))
     row + 1, captions->cont, BREAK
    ENDIF
    col 58, site_and_prefix_disp, col 67,
    catalog_disp"#########################", col 94, task_assay_disp"#########################",
    col 121, chartable_disp, row + 1
   ENDIF
  FOOT  station_disp
   row + 1
  FOOT REPORT
   row + 1, col 55, "* * * ",
   captions->endrpt, " * * *"
  WITH nocounter, maxcol = 135, nullreport,
   maxrow = 63, compress
 ;end select
 SET reply->status_data.status = "S"
END GO
