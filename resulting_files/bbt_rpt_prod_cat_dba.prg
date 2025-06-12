CREATE PROGRAM bbt_rpt_prod_cat:dba
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
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 as_of_date = vc
   1 database_audit = vc
   1 page_no = vc
   1 time = vc
   1 product_tool = vc
   1 product_categories = vc
   1 product_class = vc
   1 product = vc
   1 require = vc
   1 prompt_for = vc
   1 special = vc
   1 red = vc
   1 abo = vc
   1 tags_labels = vc
   1 default = vc
   1 category = vc
   1 rh = vc
   1 confirm = vc
   1 vol = vc
   1 alt = vc
   1 seg = vc
   1 testing = vc
   1 cell = vc
   1 compat = vc
   1 xm = vc
   1 cpt = vc
   1 pilt = vc
   1 ship = vc
   1 meas = vc
   1 vis_ins = vc
   1 active = vc
   1 no = vc
   1 yes = vc
   1 end_of_report = vc
 )
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","AS OF DATE:   ")
 SET captions->database_audit = uar_i18ngetmessage(i18nhandle,"database_audit","DATABASE AUDIT")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","PAGE NO:  ")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","TIME:  ")
 SET captions->product_tool = uar_i18ngetmessage(i18nhandle,"product_tool","PRODUCT TOOL")
 SET captions->product_categories = uar_i18ngetmessage(i18nhandle,"product_categories",
  "PRODUCT CATEGORIES BY CLASS")
 SET captions->product_class = uar_i18ngetmessage(i18nhandle,"product_class","PRODUCT CLASS:  ")
 SET captions->product = uar_i18ngetmessage(i18nhandle,"product","PRODUCT             |")
 SET captions->require = uar_i18ngetmessage(i18nhandle,"require","REQUIRE   |")
 SET captions->prompt_for = uar_i18ngetmessage(i18nhandle,"prompt_for","PROMPT FOR  |")
 SET captions->special = uar_i18ngetmessage(i18nhandle,"special","SPECIAL|")
 SET captions->red = uar_i18ngetmessage(i18nhandle,"red","RED |")
 SET captions->abo = uar_i18ngetmessage(i18nhandle,"abo","ABO  |")
 SET captions->tags_labels = uar_i18ngetmessage(i18nhandle,"tags_labels","TAGS/LABELS|")
 SET captions->default = uar_i18ngetmessage(i18nhandle,"default","DEFAULT         |")
 SET captions->category = uar_i18ngetmessage(i18nhandle,"category","CATEGORY            |")
 SET captions->rh = uar_i18ngetmessage(i18nhandle,"rh","Rh")
 SET captions->confirm = uar_i18ngetmessage(i18nhandle,"confirm","CONFIRM")
 SET captions->vol = uar_i18ngetmessage(i18nhandle,"vol","|VOL")
 SET captions->alt = uar_i18ngetmessage(i18nhandle,"alt","ALT#")
 SET captions->seg = uar_i18ngetmessage(i18nhandle,"seg","SEG#|")
 SET captions->testing = uar_i18ngetmessage(i18nhandle,"testing","TESTING|")
 SET captions->cell = uar_i18ngetmessage(i18nhandle,"cell","CELL|")
 SET captions->compat = uar_i18ngetmessage(i18nhandle,"compat","COMPAT|")
 SET captions->xm = uar_i18ngetmessage(i18nhandle,"xm","XM")
 SET captions->cpt = uar_i18ngetmessage(i18nhandle,"cpt","CPT ")
 SET captions->pilt = uar_i18ngetmessage(i18nhandle,"pilt","PILT|")
 SET captions->ship = uar_i18ngetmessage(i18nhandle,"ship","SHIP")
 SET captions->meas = uar_i18ngetmessage(i18nhandle,"meas","MEAS")
 SET captions->vis_ins = uar_i18ngetmessage(i18nhandle,"vis_ins","VIS INS   |")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"active","ACTIVE")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"no","NO")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","YES")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  " * * * E N D  O F  R E P O R T * * * ")
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_prod_cat", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  pc.product_cat_cd, pc.product_class_cd, pc.rh_required_ind,
  pc.confirm_required_ind, pc.red_cell_product_ind, pc.xmatch_required_ind,
  pc.prompt_vol_ind, pc.prompt_alternate_ind, pc.prompt_segment_ind,
  pc.pilot_label_ind, pc.special_testing_ind, pc.crossmatch_tag_ind,
  pc.component_tag_ind, pc.active_ind, pc.valid_aborh_compat_ind,
  c1605_disp = format(uar_get_code_display(pc.product_cat_cd),"####################"), c1606_disp =
  format(uar_get_code_display(pc.product_class_cd),"###############"), c1600_disp = format(
   uar_get_code_display(pc.default_ship_cond_cd),"##########"),
  c54_disp = format(uar_get_code_display(pc.default_unit_measure_cd),"#####"), c1655_disp = format(
   uar_get_code_display(pc.default_vis_insp_cd),"##########")
  FROM product_category pc
  PLAN (pc
   WHERE pc.product_cat_cd > 0)
  ORDER BY c1606_disp, c1605_disp
  HEAD REPORT
   select_ok_ind = 0
  HEAD PAGE
   col 1, captions->as_of_date, col 14,
   curdate"@DATECONDENSED;;d", col 52, captions->database_audit,
   col 116, captions->page_no, col 126,
   curpage"##", row + 1, col 7,
   captions->time, col 14, curtime"@TIMENOSECONDS;;M",
   col 53, captions->product_tool, row + 1,
   col 45, captions->product_categories, row + 1,
   line = fillstring(131,"-"), line, row + 1
  HEAD c1606_disp
   row + 1, line, row + 1,
   col 2, captions->product_class, col 20,
   c1606_disp, row + 1, line,
   row + 1, col 1, captions->product,
   col 27, captions->require, col 39,
   captions->prompt_for, col 52, captions->special,
   col 60, captions->red, col 66,
   captions->abo, col 73, captions->tags_labels,
   col 95, captions->default, row + 1,
   col 1, captions->category, col 23,
   captions->rh, col 27, captions->confirm,
   col 35, captions->xm, col 37,
   captions->vol, col 42, captions->alt,
   col 47, captions->seg, col 52,
   captions->testing, col 60, captions->cell,
   col 65, captions->compat, col 73,
   captions->xm, col 76, captions->cpt,
   col 80, captions->pilt, col 88,
   captions->ship, col 95, captions->meas,
   col 101, captions->vis_ins, col 125,
   captions->active, row + 1, line,
   row + 1
  HEAD c1605_disp
   col 1, c1605_disp
  DETAIL
   IF (pc.rh_required_ind=0)
    col 23, captions->no
   ELSEIF (pc.rh_required_ind=1)
    col 22, captions->yes
   ENDIF
   IF (pc.confirm_required_ind=0)
    col 28, captions->no
   ELSEIF (pc.confirm_required_ind=1)
    col 27, captions->yes
   ENDIF
   IF (pc.xmatch_required_ind=0)
    col 35, captions->no
   ELSEIF (pc.xmatch_required_ind=1)
    col 34, captions->yes
   ENDIF
   IF (pc.prompt_vol_ind=0)
    col 39, captions->no
   ELSEIF (pc.prompt_vol_ind=1)
    col 38, captions->yes
   ENDIF
   IF (pc.prompt_alternate_ind=0)
    col 43, captions->no
   ELSEIF (pc.prompt_alternate_ind=1)
    col 42, captions->yes
   ENDIF
   IF (pc.prompt_segment_ind=0)
    col 48, captions->no
   ELSEIF (pc.prompt_segment_ind=1)
    col 47, captions->yes
   ENDIF
   IF (pc.special_testing_ind=0)
    col 54, captions->no
   ELSEIF (pc.special_testing_ind=1)
    col 53, captions->yes
   ENDIF
   IF (pc.red_cell_product_ind=0)
    col 61, captions->no
   ELSEIF (pc.red_cell_product_ind=1)
    col 60, captions->yes
   ENDIF
   IF (pc.valid_aborh_compat_ind=0)
    col 67, captions->no
   ELSEIF (pc.valid_aborh_compat_ind=1)
    col 66, captions->yes
   ENDIF
   IF (pc.crossmatch_tag_ind=0)
    col 73, captions->no
   ELSEIF (pc.crossmatch_tag_ind=1)
    col 72, captions->yes
   ENDIF
   IF (pc.component_tag_ind=0)
    col 77, captions->no
   ELSEIF (pc.component_tag_ind=1)
    col 76, captions->yes
   ENDIF
   IF (pc.pilot_label_ind=0)
    col 81, captions->no
   ELSEIF (pc.pilot_label_ind=1)
    col 80, captions->yes
   ENDIF
   col 85, c1600_disp, col 95,
   c54_disp, col 101, c1655_disp
   IF (pc.active_ind=0)
    col 127, captions->no
   ELSEIF (pc.active_ind=1)
    col 126, captions->yes
   ENDIF
   row + 1
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
END GO
