CREATE PROGRAM da_get_sec_omf_lists
 PROMPT
  "Update Flag" = "0",
  "Mode Flag" = "0",
  "Last Name" = "",
  "Reporting Domain ID" = ""
  WITH update_flag, mode_flag, name_search_str,
  domain_id
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE orgsecurity = i2 WITH noconstant(1)
 DECLARE current_prsnl_id = f8 WITH noconstant(0.0)
 DECLARE itemndx = i4 WITH noconstant(0)
 DECLARE mdomainid = f8 WITH constant( $DOMAIN_ID)
 DECLARE domainqual = vc
 FREE RECORD i18n
 RECORD i18n(
   1 all_subject_areas = vc
   1 all_domains = vc
   1 no_users_found = vc
   1 no_omf_sec = vc
   1 no_omf_domains = vc
   1 no_omf_sa = vc
   1 no_views = vc
   1 all_views = vc
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
 RECORD item_lists(
   1 lists[*]
     2 item_cd = f8
     2 item_name = c155
 )
 SET istat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 CALL doi18nonstrings(istat)
 SELECT INTO "nl:"
  FROM dm_info i
  WHERE i.info_name="SEC_ORG_RELTN"
   AND i.info_domain="SECURITY"
  DETAIL
   orgsecurity = i.info_number
  WITH nocounter
 ;end select
 SET current_prsnl_id = reqinfo->updt_id
 EXECUTE ccl_prompt_api_dataset "autoset"
 IF (( $MODE_FLAG=1))
  SELECT
   IF (orgsecurity=1)DISTINCT
    p.person_id, p.name_last_key, p.name_first_key,
    p.name_full_formatted
    FROM prsnl p,
     prsnl_org_reltn po
    WHERE p.name_last_key=patstring(cnvtupper(concat( $NAME_SEARCH_STR,"*")))
     AND p.person_id=po.person_id
     AND (po.organization_id=
    (SELECT
     p.organization_id
     FROM prsnl_org_reltn p,
      organization o
     WHERE o.organization_id=p.organization_id
      AND p.person_id=current_prsnl_id
      AND p.active_ind=1
      AND sysdate BETWEEN p.beg_effective_dt_tm AND p.end_effective_dt_tm
      AND o.active_ind=1
      AND sysdate BETWEEN o.beg_effective_dt_tm AND o.end_effective_dt_tm))
   ELSE DISTINCT
    p.person_id, p.name_last_key, p.name_first_key,
    p.name_full_formatted
    FROM prsnl p
    WHERE p.name_last_key=patstring(cnvtupper(concat( $NAME_SEARCH_STR,"*")))
   ENDIF
   ORDER BY p.name_last_key, p.name_first_key
   HEAD REPORT
    itemndx = 0
   DETAIL
    itemndx += 1
    IF (mod(itemndx,10)=1)
     stat = alterlist(item_lists->lists,(itemndx+ 9))
    ENDIF
    item_lists->lists[itemndx].item_cd = p.person_id, item_lists->lists[itemndx].item_name = concat(
     build(p.name_full_formatted),"  [",build(cnvtupper(p.username)),"]")
   FOOT REPORT
    stat = alterlist(item_lists->lists,itemndx)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET stat = alterlist(item_lists->lists,1)
   SET item_lists->lists[itemndx].item_cd = - (999)
   SET item_lists->lists[itemndx].item_name = i18n->no_users_found
  ENDIF
 ELSEIF (( $MODE_FLAG=2))
  SELECT
   IF (orgsecurity=1)DISTINCT
    o.user_id, p.name_last_key, p.name_first_key,
    p.name_full_formatted
    FROM omf_pv_security_filter o,
     prsnl p,
     prsnl_org_reltn po
    WHERE o.user_id=p.person_id
     AND p.name_last_key=patstring(cnvtupper(concat( $NAME_SEARCH_STR,"*")))
     AND o.user_id > 0
     AND o.user_id=po.person_id
     AND (po.organization_id=
    (SELECT
     p.organization_id
     FROM prsnl_org_reltn p,
      organization o
     WHERE o.organization_id=p.organization_id
      AND p.person_id=current_prsnl_id
      AND p.active_ind=1
      AND sysdate BETWEEN p.beg_effective_dt_tm AND p.end_effective_dt_tm
      AND o.active_ind=1
      AND sysdate BETWEEN o.beg_effective_dt_tm AND o.end_effective_dt_tm))
   ELSE DISTINCT
    o.user_id, p.name_last_key, p.name_first_key,
    p.name_full_formatted
    FROM omf_pv_security_filter o,
     prsnl p
    WHERE o.user_id=p.person_id
     AND p.name_last_key=patstring(cnvtupper(concat( $NAME_SEARCH_STR,"*")))
     AND o.user_id > 0
   ENDIF
   ORDER BY p.name_last_key, p.name_first_key
   HEAD REPORT
    itemndx = 0
   DETAIL
    itemndx += 1
    IF (mod(itemndx,10)=1)
     stat = alterlist(item_lists->lists,(itemndx+ 9))
    ENDIF
    item_lists->lists[itemndx].item_cd = o.user_id, item_lists->lists[itemndx].item_name = concat(
     build(p.name_full_formatted),"  [",build(cnvtupper(p.username)),"]")
   FOOT REPORT
    stat = alterlist(item_lists->lists,itemndx)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET stat = alterlist(item_lists->lists,1)
   SET item_lists->lists[itemndx].item_cd = - (999)
   SET item_lists->lists[itemndx].item_name = concat(i18n->no_users_found," ",i18n->no_omf_sec)
  ENDIF
 ELSEIF (( $MODE_FLAG=3))
  SELECT DISTINCT INTO "nl:"
   og.grid_group_cd, disp = uar_get_code_display(og.grid_group_cd)
   FROM omf_grid og
   WHERE og.grid_group_cd > 0
    AND og.active_ind=1
   ORDER BY disp
   HEAD REPORT
    itemndx = 1, stat = alterlist(item_lists->lists,(itemndx+ 9)), item_lists->lists[itemndx].item_cd
     = - (1),
    item_lists->lists[itemndx].item_name = i18n->all_domains
   DETAIL
    itemndx += 1
    IF (mod(itemndx,10)=1)
     stat = alterlist(item_lists->lists,(itemndx+ 9))
    ENDIF
    item_lists->lists[itemndx].item_cd = og.grid_group_cd, item_lists->lists[itemndx].item_name =
    disp
   FOOT REPORT
    stat = alterlist(item_lists->lists,itemndx)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET stat = alterlist(item_lists->lists,1)
   SET item_lists->lists[itemndx].item_cd = - (999)
   SET item_lists->lists[itemndx].item_name = i18n->no_omf_domains
  ENDIF
 ELSEIF (( $MODE_FLAG=4))
  IF (mdomainid > 0)
   SET domainqual = concat(" og.grid_group_cd = ",build(mdomainid))
  ELSE
   SET domainqual = " 1=1"
  ENDIF
  SELECT INTO "nl:"
   og.grid_cd, disp = uar_get_code_display(og.grid_cd)
   FROM omf_grid og
   WHERE og.grid_cd > 0
    AND og.active_ind=1
    AND parser(domainqual)
   ORDER BY disp
   HEAD REPORT
    itemndx = 0
   DETAIL
    itemndx += 1
    IF (mod(itemndx,10)=1)
     stat = alterlist(item_lists->lists,(itemndx+ 9))
    ENDIF
    item_lists->lists[itemndx].item_cd = og.grid_cd, item_lists->lists[itemndx].item_name = disp
   FOOT REPORT
    stat = alterlist(item_lists->lists,itemndx)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET stat = alterlist(item_lists->lists,1)
   SET item_lists->lists[itemndx].item_cd = - (999)
   SET item_lists->lists[itemndx].item_name = i18n->no_omf_sa
  ENDIF
 ELSEIF (( $MODE_FLAG=5))
  IF (mdomainid > 0)
   SET domainqual = concat(" opi.user_id = ",build(mdomainid))
  ELSE
   SET domainqual = " 1=1"
  ENDIF
  SELECT INTO "nl:"
   opi.omf_pv_item_id, opi.pv_item_name
   FROM omf_pv_items opi
   WHERE parser(domainqual)
    AND opi.item_type_flag=0
   ORDER BY opi.pv_item_name
   HEAD REPORT
    itemndx = 1, stat = alterlist(item_lists->lists,(itemndx+ 9)), item_lists->lists[itemndx].item_cd
     = - (1),
    item_lists->lists[itemndx].item_name = i18n->all_views
   DETAIL
    itemndx += 1
    IF (mod(itemndx,10)=1)
     stat = alterlist(item_lists->lists,(itemndx+ 9))
    ENDIF
    item_lists->lists[itemndx].item_cd = opi.omf_pv_item_id, item_lists->lists[itemndx].item_name =
    opi.pv_item_name
   FOOT REPORT
    stat = alterlist(item_lists->lists,itemndx)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET stat = alterlist(item_lists->lists,1)
   SET item_lists->lists[itemndx].item_cd = - (999)
   SET item_lists->lists[itemndx].item_name = i18n->no_views
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  item_lists->lists[d.seq].item_cd, item_lists->lists[d.seq].item_name
  FROM (dummyt d  WITH seq = size(item_lists->lists,5))
  WHERE 1=1
  HEAD REPORT
   stat = makedataset(10)
  DETAIL
   stat = writerecord(0)
  FOOT REPORT
   stat = closedataset(0)
  WITH reporthelp, check
 ;end select
 SUBROUTINE doi18nonstrings(ndummyvar)
   SET i18n->all_subject_areas = uar_i18ngetmessage(i18nhandle,"all_subject_areas",
    "All listed Subject Areas")
   SET i18n->all_domains = uar_i18ngetmessage(i18nhandle,"all_domains",
    "Show Subject Areas for all Domains")
   SET i18n->no_users_found = uar_i18ngetmessage(i18nhandle,"no_users_found",
    "No matching users found")
   SET i18n->no_omf_sec = uar_i18ngetmessage(i18nhandle,"no_omf_sec","with omf security settings")
   SET i18n->no_omf_domains = uar_i18ngetmessage(i18nhandle,"no_omf_domains",
    "No active OMF Reporting Domains found")
   SET i18n->no_omf_sa = uar_i18ngetmessage(i18nhandle,"no_omf_sa",
    "No active OMF Subject Areas found")
   SET i18n->no_views = uar_i18ngetmessage(i18nhandle,"no_views",
    "Selected user does not own any active saved views.")
   SET i18n->all_views = uar_i18ngetmessage(i18nhandle,"all_views","Select All views")
 END ;Subroutine
END GO
