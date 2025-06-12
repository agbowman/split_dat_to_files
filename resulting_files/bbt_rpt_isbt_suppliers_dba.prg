CREATE PROGRAM bbt_rpt_isbt_suppliers:dba
 RECORD reply(
   1 rpt_list[*]
     2 rpt_filename = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 DECLARE inv_area = vc
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 rpt_as_of_date = vc
   1 database_audit = vc
   1 page_no = vc
   1 rpt_time = vc
   1 bb_supplier_list = vc
   1 supplier_org = vc
   1 fin = vc
   1 fda_reg = vc
   1 inventory = vc
   1 us_license_area = vc
   1 active = vc
   1 no = vc
   1 yes = vc
   1 end_of_report = vc
 )
 DECLARE org_type_code_set = i4 WITH protect, constant(278)
 DECLARE select_ok_ind = i2 WITH protect, noconstant(0)
 DECLARE count1 = i4 WITH protect, noconstant(0)
 DECLARE rpt_cnt = i4 WITH protect, noconstant(0)
 DECLARE org_type_cd = f8 WITH protect, noconstant(0)
 SET captions->rpt_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","As of date:  ")
 SET captions->database_audit = uar_i18ngetmessage(i18nhandle,"database_audit","Database Audit")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","Page No: ")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:  ")
 SET captions->bb_supplier_list = uar_i18ngetmessage(i18nhandle,"bb_supplier_list",
  "ISBT 128 Supplier List")
 SET captions->fin = uar_i18ngetmessage(i18nhandle,"fin","FIN")
 SET captions->fda_reg = uar_i18ngetmessage(i18nhandle,"fda reg #","FDA Reg #")
 SET captions->inventory = uar_i18ngetmessage(i18nhandle,"inventory area","Inventory Area")
 SET captions->us_license_area = uar_i18ngetmessage(i18nhandle,"us license #","US License #")
 SET captions->supplier_org = uar_i18ngetmessage(i18nhandle,"supplier_org","Supplier/Organization")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"active","Active")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"no","No")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","Yes")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * END OF REPORT * * * ")
 SET reply->status_data.status = "F"
 EXECUTE cpm_create_file_name_logical "bb_isbt_supplier", "txt", "x"
 SET org_type_cd = uar_get_code_by("MEANING",org_type_code_set,nullterm("BBSUPPL"))
 IF (org_type_cd=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "Failed to get org_type_cd"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "BBT_RPT_ISBT_SUPPLIERS"
  GO TO exit_script
 ENDIF
 SELECT INTO cpm_cfn_info->file_name_logical
  otr.org_type_cd, org.organization_id, org.org_name,
  bbs.seq, bbs.bb_isbt_supplier_id, bbs.updt_cnt,
  bbs.active_ind, inv_area = uar_get_code_display(bbs.inventory_area_cd)
  FROM org_type_reltn otr,
   organization org,
   bb_isbt_supplier bbs
  PLAN (otr
   WHERE otr.org_type_cd=org_type_cd
    AND otr.organization_id != null
    AND otr.organization_id > 0
    AND otr.active_ind=1)
   JOIN (org
   WHERE org.organization_id=otr.organization_id
    AND org.active_ind=1)
   JOIN (bbs
   WHERE bbs.organization_id=org.organization_id)
  HEAD REPORT
   line = fillstring(126,"-"), select_ok_ind = 0
  HEAD PAGE
   col 1, captions->rpt_as_of_date, col 14,
   curdate"@DATECONDENSED;;d", col 52, captions->database_audit,
   col 108, captions->page_no, col 120,
   curpage"##", row + 1, col 7,
   captions->rpt_time, col 14, curtime"@TIMENOSECONDS;;M",
   col 52, captions->bb_supplier_list, row + 2,
   line, row + 1, row + 1,
   col 1, captions->supplier_org, row + 1,
   col 1, captions->fin, col 8,
   captions->fda_reg, col 26, captions->us_license_area,
   col 44, captions->inventory, col 87,
   captions->active, row + 1, line,
   row + 1
  DETAIL
   row + 2, col 1, org.org_name,
   row + 1
   IF (bbs.bb_isbt_supplier_id > 0)
    col 1, bbs.isbt_supplier_fin, col 8,
    bbs.registration_nbr_txt, col 26, bbs.license_nbr_txt,
    col 44, inv_area
    IF (bbs.active_ind=1)
     col 87, captions->yes
    ELSE
     col 87, captions->no
    ENDIF
   ENDIF
  FOOT REPORT
   row + 3, col 49, captions->end_of_report,
   select_ok_ind = 1
  WITH nullreport, nocounter, compress,
   nolandscape
 ;end select
 SET rpt_cnt = (rpt_cnt+ 1)
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
