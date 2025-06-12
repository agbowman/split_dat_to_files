CREATE PROGRAM ccl_menu_display_security:dba
 PROMPT
  "Output to File/Printer/MINE " = mine
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
 SET lretval = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET pagetxt = uar_i18ngetmessage(i18nhandle,"KeyGet2","Page: ")
 SET menu_id = uar_i18ngetmessage(i18nhandle,"KeyGet3","MENU ID")
 SET item_description = uar_i18ngetmessage(i18nhandle,"KeyGet4","ITEM DESCRIPTION")
 SET app_group_cd = uar_i18ngetmessage(i18nhandle,"KeyGet5","APP GROUP CD")
 SET app_group_display = uar_i18ngetmessage(i18nhandle,"KeyGet6","APP GROUP DISPLAY")
 SELECT INTO  $1
  e.menu_id"############", em.item_desc, e.app_group_cd"############",
  app_group_disp = uar_get_code_display(e.app_group_cd)
  FROM explorer_menu em,
   explorer_menu_security e
  PLAN (e)
   JOIN (em
   WHERE e.menu_id=em.menu_id)
  ORDER BY em.item_desc, app_group_disp
  HEAD REPORT
   line1 = fillstring(40,"="), line2 = fillstring(12,"=")
  HEAD PAGE
   CALL center(uar_i18ngetmessage(i18nhandle,"KeyGet1","EXPLORER MENU SECURITY AUDIT"),1,112), col
   100, pagetxt,
   col + 1,
   CALL print(format(curpage,"##;L;I")), i18ncurdate = format(curdate,"@SHORTDATE;;Q"),
   row + 1, col 100, i18ncurdate,
   row + 2, col 0, menu_id,
   col 15, item_description, col 57,
   app_group_cd, col 72, app_group_display,
   row + 1, col 0, line2,
   col 15, line1, col 57,
   line2, col 72, line1,
   row + 1
  HEAD em.item_desc
   col 0, e.menu_id, col 15,
   em.item_desc
  HEAD app_group_disp
   col 57, e.app_group_cd, col 72,
   app_group_disp, row + 1
  DETAIL
   row + 0
  FOOT  em.item_desc
   row + 1
  WITH format, separator = " ", format = variable
 ;end select
END GO
