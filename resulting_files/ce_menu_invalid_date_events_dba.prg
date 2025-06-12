CREATE PROGRAM ce_menu_invalid_date_events:dba
 PAINT
 FREE RECORD menu_captions
 RECORD menu_captions(
   1 menutitle = vc
   1 menuretrieve = vc
   1 menufix = vc
   1 menu3 = vc
   1 menuexit = vc
   1 note = vc
   1 selectmenu = vc
   1 patientlist = vc
   1 processing = vc
   1 done = vc
 )
 DECLARE filename = vc WITH protect, noconstant(fillstring(100," "))
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
 SET menu_captions->menutitle = uar_i18ngetmessage(i18nhandle,"m1","Invalid Date Events Utility")
 SET menu_captions->menuretrieve = uar_i18ngetmessage(i18nhandle,"m2",
  " 1)  Retrieve list of patients with invalid date events")
 SET menu_captions->menufix = uar_i18ngetmessage(i18nhandle,"m3",
  " 2)  Fix invalid date events for list of patients")
 SET menu_captions->menu3 = uar_i18ngetmessage(i18nhandle,"m4"," 3)  ")
 SET menu_captions->menuexit = uar_i18ngetmessage(i18nhandle,"m5","Exit")
 SET menu_captions->note = uar_i18ngetmessage(i18nhandle,"m6",
  "Please note that the script could take a long time to execute.")
 SET menu_captions->selectmenu = uar_i18ngetmessage(i18nhandle,"m7","Select From Menu:")
 SET menu_captions->patientlist = uar_i18ngetmessage(i18nhandle,"m8","Patient List File:")
 SET menu_captions->processing = uar_i18ngetmessage(i18nhandle,"m9","Processing...")
 SET menu_captions->done = uar_i18ngetmessage(i18nhandle,"m10","Done processing.")
 SET filename = "ce_patients_with_invalid_date_events.dat"
 CALL video(w)
 CALL clear(1,1)
 CALL box(2,2,24,130)
 CALL line(6,2,129,xhor)
 CALL text(4,25,menu_captions->menutitle)
 CALL text(8,5,menu_captions->menuretrieve)
 CALL text(10,5,menu_captions->menufix)
 CALL text(12,5,menu_captions->menu3)
 CALL video(r)
 CALL text(12,10,menu_captions->menuexit)
 CALL video(n)
 CALL text(22,5,menu_captions->note)
 CALL text(16,5,menu_captions->selectmenu)
 CALL accept(16,27,"9",3
  WHERE curaccept IN (1, 2, 3))
 CASE (curaccept)
  OF 1:
   CALL clear(1,1)
   CALL text(2,1,menu_captions->processing)
   EXECUTE ce_get_invalid_date_events value(filename)
   CALL clear(1,1)
   CALL text(2,1,menu_captions->done)
  OF 2:
   CALL text(18,5,menu_captions->patientlist)
   CALL accept(18,27,"P(100);C",filename
    WHERE textlen(trim(curaccept,3)) > 0
     AND findfile(curaccept)=1)
   SET filename = curaccept
   CALL clear(1,1)
   CALL text(2,1,menu_captions->processing)
   EXECUTE ce_upd_invalid_date_events value(filename)
   CALL clear(1,1)
   CALL text(2,1,menu_captions->done)
  ELSE
   CALL clear(1,1)
 ENDCASE
#exit_script
 FREE RECORD menu_captions
END GO
