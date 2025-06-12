CREATE PROGRAM ccl_menu_disp_user_sec:dba
 PROMPT
  "Output to File/Printer/MINE " = mine,
  "Last Name or ALL (pattern match OK) " = "ALL",
  "First Name or ALL (pattern match OK) " = "ALL",
  "Non-DBA's or DBA's N or D (N) " = "N"
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
 SET nametxt = uar_i18ngetmessage(i18nhandle,"KeyGet1","Name")
 SET person_idtxt = uar_i18ngetmessage(i18nhandle,"KeyGet2","Person ID")
 SET msg1 = uar_i18ngetmessage(i18nhandle,"KeyGet3",
  "DBA with access to menu items assigned to any application group.")
 SET msg2 = uar_i18ngetmessage(i18nhandle,"KeyGet4","Application Group")
 SET msg3 = uar_i18ngetmessage(i18nhandle,"KetGet5",
  "Non-DBA with access to menu items assigned to groups listed above,")
 SET msg4 = uar_i18ngetmessage(i18nhandle,"KeyGet6",
  "as well as items that do not have application groups assigned.")
 IF (findstring("*", $2)=0)
  IF (cnvtupper( $2)="ALL")
   SET name_last = "*"
  ELSE
   SET name_last = cnvtupper(concat(trim( $2),"*"))
  ENDIF
 ELSE
  SET name_last = cnvtupper( $2)
 ENDIF
 IF (findstring("*", $3)=0)
  IF (cnvtupper( $3)="ALL")
   SET name_first = "*"
  ELSE
   SET name_first = cnvtupper(concat(trim( $3),"*"))
  ENDIF
 ELSE
  SET name_first = cnvtupper( $3)
 ENDIF
 IF (( $4="N"))
  GO TO nondba
 ENDIF
 SELECT INTO  $1
  name_full_formatted = substring(1,30,p.name_full_formatted), p.person_id, cv.display_key
  FROM prsnl p,
   application_group ag,
   code_value cv
  PLAN (p
   WHERE p.name_last_key=patstring(name_last)
    AND p.name_first_key=patstring(name_first))
   JOIN (ag
   WHERE p.position_cd=ag.position_cd)
   JOIN (cv
   WHERE ag.app_group_cd=cv.code_value
    AND cv.display_key="DBA")
  ORDER BY name_full_formatted
  HEAD REPORT
   line30 = fillstring(30,"-"), line10 = fillstring(10,"-"), row + 1,
   col 0, nametxt, col 32,
   person_idtxt, row + 1, col 0,
   line30, col 32, line10
  DETAIL
   row + 1, col 0, name_full_formatted,
   col 32, p.person_id"##########;I"
  FOOT REPORT
   row + 2, col 0, msg1
  WITH check, nocounter, format = variable
 ;end select
 GO TO endit
#nondba
 SELECT INTO  $1
  p.person_id, name_full_formatted = substring(1,30,p.name_full_formatted), cv.display
  FROM prsnl p,
   application_group a,
   code_value cv
  PLAN (p
   WHERE p.name_last_key=patstring(name_last)
    AND p.name_first_key=patstring(name_first))
   JOIN (a
   WHERE p.position_cd=a.position_cd)
   JOIN (cv
   WHERE a.app_group_cd=cv.code_value
    AND cv.display_key != "DBA")
  ORDER BY name_full_formatted, p.person_id, cv.display
  HEAD REPORT
   line30 = fillstring(30,"-"), line10 = fillstring(10,"-"), line20 = fillstring(20,"-"),
   row + 1, col 0, nametxt,
   col 32, person_idtxt, col 44,
   msg2, row + 1, col 0,
   line30, col 32, line10,
   col 44, line20
  HEAD p.person_id
   row + 1, col 0, name_full_formatted,
   col 32, p.person_id"##########;I"
  DETAIL
   col 44, cv.display, row + 1
  FOOT REPORT
   row + 2, col 0, msg3,
   row + 1, col 0, msg4
  WITH check, nocounter, format = variable
 ;end select
#endit
END GO
