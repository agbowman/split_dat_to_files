CREATE PROGRAM da2_import_da_users:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE strstatusmsg = vc WITH protect
 DECLARE oorgsecurity = i2 WITH noconstant(1)
 DECLARE i18nhandle = i4 WITH noconstant(0)
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
 FREE RECORD prsnlidstocopy
 RECORD prsnlidstocopy(
   1 prsnlids[*]
     2 prsnl_id = f8
 )
 SET istat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET da2usercd = uar_get_code_by("DISPLAYKEY",355,"DISCERNANALYTICSUSER")
 SET activecd = uar_get_code_by("MEANING",48,"ACTIVE")
 SET current_prsnl_id = reqinfo->updt_id
 SELECT INTO "nl:"
  FROM dm_info i
  WHERE i.info_name="SEC_ORG_RELTN"
   AND i.info_domain="SECURITY"
  DETAIL
   oorgsecurity = i.info_number
  WITH nocounter
 ;end select
 IF (current_prsnl_id <= 0)
  SET strstatusmsg = uar_i18ngetmessage(i18nhandle,"need_valid_login",
   "User must have valid login to run program")
  GO TO end_now
 ENDIF
 IF (oorgsecurity=1)
  SELECT DISTINCT INTO "nl:"
   userid = op.user_id
   FROM omf_pv_user op,
    prsnl_org_reltn po
   WHERE (op.user_id !=
   (SELECT
    p.person_id
    FROM prsnl_info p
    WHERE p.info_type_cd=da2usercd))
    AND op.user_id=po.person_id
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
   ORDER BY op.user_id
   HEAD REPORT
    stat = alterlist(prsnlidstocopy->prsnlids,10), count = 0
   DETAIL
    count += 1
    IF (mod(count,10)=0)
     stat = alterlist(prsnlidstocopy->prsnlids,(count+ 10))
    ENDIF
    prsnlidstocopy->prsnlids[count].prsnl_id = userid
   FOOT REPORT
    stat = alterlist(prsnlidstocopy->prsnlids,count)
   WITH nocounter
  ;end select
 ELSE
  SELECT DISTINCT INTO "nl:"
   userid = op.user_id
   FROM omf_pv_user op
   WHERE (op.user_id !=
   (SELECT
    p.person_id
    FROM prsnl_info p
    WHERE p.info_type_cd=da2usercd))
   ORDER BY op.user_id
   HEAD REPORT
    stat = alterlist(prsnlidstocopy->prsnlids,10), count = 0
   DETAIL
    count += 1
    IF (mod(count,10)=0)
     stat = alterlist(prsnlidstocopy->prsnlids,(count+ 10))
    ENDIF
    prsnlidstocopy->prsnlids[count].prsnl_id = userid
   FOOT REPORT
    stat = alterlist(prsnlidstocopy->prsnlids,count)
   WITH nocounter
  ;end select
 ENDIF
 INSERT  FROM prsnl_info pi,
   (dummyt d  WITH seq = value(size(prsnlidstocopy->prsnlids,5)))
  SET pi.prsnl_info_id = seq(prsnl_seq,nextval), pi.person_id = prsnlidstocopy->prsnlids[d.seq].
   prsnl_id, pi.info_type_cd = da2usercd,
   pi.info_sub_type_cd = 0, pi.updt_cnt = 0, pi.updt_dt_tm = cnvtdatetime(sysdate),
   pi.updt_id = reqinfo->updt_id, pi.updt_task = reqinfo->updt_task, pi.updt_applctx = reqinfo->
   updt_applctx,
   pi.active_ind = 1, pi.active_status_cd = activecd, pi.active_status_dt_tm = cnvtdatetime(sysdate),
   pi.active_status_prsnl_id = current_prsnl_id, pi.beg_effective_dt_tm = cnvtdatetime(sysdate), pi
   .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
   pi.long_text_id = 0, pi.value_numeric = 0, pi.chartable_ind = 0,
   pi.contributor_system_cd = 0
  PLAN (d)
   JOIN (pi)
  WITH nocounter
 ;end insert
 SET ecode = 0
 SET emsg = fillstring(132," ")
 SET ecode = error(strstatusmsg,1)
 IF (ecode != 0)
  SET i18nerrormsg = uar_i18ngetmessage(i18nhandle,"failed_msg","FAILED:  ")
  SET strstatusmsg = concat(i18nerrormsg,strstatusmsg)
  ROLLBACK
 ELSE
  SET i18nsuccessmsg = uar_i18ngetmessage(i18nhandle,"number_added","Number of users added: ")
  SET strstatusmsg = concat(i18nsuccessmsg,build(size(prsnlidstocopy->prsnlids,5)))
  COMMIT
 ENDIF
#end_now
 SELECT INTO  $OUTDEV
  HEAD REPORT
   col 0, strstatusmsg, row + 1
  WITH nocounter
 ;end select
 FREE RECORD prsnlidstocopy
END GO
