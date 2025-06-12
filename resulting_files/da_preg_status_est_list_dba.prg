CREATE PROGRAM da_preg_status_est_list:dba
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
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET strinitial = uar_i18ngetmessage(i18nhandle,"1Init","Initial")
 SET strauth = uar_i18ngetmessage(i18nhandle,"2Auth","Authoritative")
 SET strfinal = uar_i18ngetmessage(i18nhandle,"3Final","Final")
 SET stat = alterlist(reply->datacoll,3)
 SET reply->datacoll[1].currcv = "1"
 SET reply->datacoll[1].description = strinitial
 SET reply->datacoll[2].currcv = "2"
 SET reply->datacoll[2].description = strauth
 SET reply->datacoll[3].currcv = "3"
 SET reply->datacoll[3].description = strfinal
 SET reply->status_data.status = "S"
END GO
