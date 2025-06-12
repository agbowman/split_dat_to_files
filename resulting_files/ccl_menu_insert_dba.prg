CREATE PROGRAM ccl_menu_insert:dba
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
 SET nbr = 0
 SET menu_id = 99.9
 SELECT
  e.menu_id
  FROM explorer_menu e
  DETAIL
   nbr += 1, menu_id = e.menu_id
  WITH check, nocounter, noforms
 ;end select
 SET menu_empty = 1
 SET item_name = fillstring(25," ")
 SET item_desc = fillstring(40," ")
 IF (nbr=1)
  IF (menu_id=0)
   DELETE  FROM explorer_menu e
    WHERE e.menu_id=0
    WITH check, nocounter
   ;end delete
  ELSE
   SET menu_empty = 0
  ENDIF
 ELSEIF (nbr > 1)
  SET menu_empty = 0
 ENDIF
 SET item_name = "CCLUAF"
 SET item_desc = uar_i18ngetmessage(i18nhandle,"KeyGet1","Look up Users")
 SET item_type = "P"
 SET parent_id = 0.0
 SET item_on_file = 0
 IF (menu_empty=0)
  CALL item_on_file(item_name,item_type)
 ENDIF
 IF (item_on_file=0)
  CALL insert_item(item_name,item_desc,item_type,parent_id)
 ENDIF
 SET item_name = "DATA DICTIONARY"
 SET item_desc = uar_i18ngetmessage(i18nhandle,"KeyGet2","Discern Explorer Data Dictionary")
 SET item_type = "M"
 SET parent_id = 0.0
 SET item_on_file = 0
 IF (menu_empty=0)
  CALL item_on_file(item_name,item_type)
 ENDIF
 IF (item_on_file=0)
  CALL insert_item(item_name,item_desc,item_type,parent_id)
 ENDIF
 SET parent_id = 0.00
 SELECT
  e.menu_id, e.item_name
  FROM explorer_menu e
  WHERE e.item_name="DATA DICTIONARY"
  DETAIL
   parent_id = e.menu_id
  WITH check, nocounter, noforms
 ;end select
 SET item_name = "CCLORATABLE"
 SET item_desc = uar_i18ngetmessage(i18nhandle,"KeyGet3","View Indexes and Columns by Table")
 SET item_type = "P"
 SET item_on_file = 0
 IF (menu_empty=0)
  CALL item_on_file(item_name,item_type)
 ENDIF
 IF (item_on_file=0)
  CALL insert_item(item_name,item_desc,item_type,parent_id)
 ENDIF
 SET item_name = "CCLGLOS"
 SET item_desc = uar_i18ngetmessage(i18nhandle,"KeyGet4","Look up Table/Column Descriptions")
 SET item_type = "P"
 SET item_on_file = 0
 IF (menu_empty=0)
  CALL item_on_file(item_name,item_type)
 ENDIF
 IF (item_on_file=0)
  CALL insert_item(item_name,item_desc,item_type,parent_id)
 ENDIF
 SET item_name = "CCLPROT"
 SET item_desc = uar_i18ngetmessge(i18nhandle,"KeyGet5","Discern Explorer Items")
 SET item_type = "P"
 SET item_on_file = 0
 IF (menu_empty=0)
  CALL item_on_file(item_name,item_type)
 ENDIF
 IF (item_on_file=0)
  CALL insert_item(item_name,item_desc,item_type,parent_id)
 ENDIF
 SET item_name = "EXPLORER MENU AUDITS"
 SET item_desc = uar_i18ngetmessage(i18nhandle,"KeyGet6","Explorer Menu Audits")
 SET item_type = "M"
 SET parent_id = 0.0
 SET item_on_file = 0
 IF (menu_empty=0)
  CALL item_on_file(item_name,item_type)
 ENDIF
 IF (item_on_file=0)
  CALL insert_item(item_name,item_desc,item_type,parent_id)
 ENDIF
 SET parent_id = 0.00
 SELECT
  e.menu_id, e.item_name
  FROM explorer_menu e
  WHERE e.item_name="EXPLORER MENU AUDITS"
  DETAIL
   parent_id = e.menu_id
  WITH check, nocounter, noforms
 ;end select
 SET item_name = "CCL_MENU_DISPLAY_SECURITY"
 SET item_desc = uar_i18ngetmessage(i18nhandle,"KeyGet7","Security Audit")
 SET item_type = "P"
 SET item_on_file = 0
 IF (menu_empty=0)
  CALL item_on_file(item_name,item_type)
 ENDIF
 IF (item_on_file=0)
  CALL insert_item(item_name,item_desc,item_type,parent_id)
 ENDIF
 SET item_name = "CCL_MENU_PERSON_ID"
 SET item_desc = uar_i18ngetmessage(i18nhandle,"KeyGet8","Persons without DBA App Group Code")
 SET item_type = "P"
 SET item_on_file = 0
 IF (menu_empty=0)
  CALL item_on_file(item_name,item_type)
 ENDIF
 IF (item_on_file=0)
  CALL insert_item(item_name,item_desc,item_type,parent_id)
 ENDIF
 SET item_name = "CCL_MENU_DISP_USER_SEC"
 SET item_desc = uar_i18ngetmessage(i18nhandle,"KeyGet9)","Security by User")
 SET item_type = "P"
 SET item_on_file = 0
 IF (menu_empty=0)
  CALL item_on_file(item_name,item_type)
 ENDIF
 IF (item_on_file=0)
  CALL insert_item(item_name,item_desc,item_type,parent_id)
 ENDIF
 SET item_name = "EXPERT AUDITS"
 SET item_desc = uar_i18ngetmessage(i18nhandle,"KeyGet10","Expert Audits")
 SET item_type = "M"
 SET parent_id = 0.0
 SET item_on_file = 0
 IF (menu_empty=0)
  CALL item_on_file(item_name,item_type)
 ENDIF
 IF (item_on_file=0)
  CALL insert_item(item_name,item_desc,item_type,parent_id)
 ENDIF
 SET parent_id = 0.00
 SELECT
  e.menu_id, e.item_name
  FROM explorer_menu e
  WHERE e.item_name="EXPERT AUDITS"
  DETAIL
   parent_id = e.menu_id
  WITH check, nocounter, noforms
 ;end select
 SET item_name = "EKS_MONITOR"
 SET item_desc = uar_i18ngetmessage(i18nhandle,"KeyGet11","Expert Monitor")
 SET item_type = "P"
 SET item_on_file = 0
 IF (menu_empty=0)
  CALL item_on_file(item_name,item_type)
 ENDIF
 IF (item_on_file=0)
  CALL insert_item(item_name,item_desc,item_type,parent_id)
 ENDIF
 SET item_name = "EKS_MOD_EXTRACT_REPORT"
 SET item_desc = uar_i18ngetmessage(i18nhandle,"KeyGet12","Module Extract Report")
 SET item_type = "P"
 SET item_on_file = 0
 IF (menu_empty=0)
  CALL item_on_file(item_name,item_type)
 ENDIF
 IF (item_on_file=0)
  CALL insert_item(item_name,item_desc,item_type,parent_id)
 ENDIF
 SUBROUTINE item_on_file(name,type)
  SELECT
   e.menu_id
   FROM explorer_menu e
   WHERE e.item_name=name
    AND e.item_type=type
   WITH check, nocounter, noforms
  ;end select
  IF (curqual > 0)
   SET item_on_file = 1
  ELSE
   SET item_on_file = 0
  ENDIF
 END ;Subroutine
 SUBROUTINE insert_item(name,desc,type,parent)
   INSERT  FROM explorer_menu e
    SET e.menu_id = seq(explorer_menu_seq,nextval), e.menu_parent_id = parent, e.person_id = 0.0,
     e.item_name = name, e.item_desc = desc, e.item_type = type,
     e.active_ind = 1
    WITH check, nocounter
   ;end insert
 END ;Subroutine
 COMMIT
#end_add
END GO
