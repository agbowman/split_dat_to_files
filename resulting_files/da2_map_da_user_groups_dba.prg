CREATE PROGRAM da2_map_da_user_groups:dba
 PROMPT
  "Output to File/Printer/MINE <MINE>:" = "MINE",
  "DA User Group <0>:" = 0,
  "DA2 security group <0>:" = 0
  WITH outdev, dagroup, secgroupcd
 DECLARE selecteddagroup = f8 WITH constant( $DAGROUP)
 DECLARE da2groupcd = f8 WITH constant( $SECGROUPCD)
 DECLARE current_prsnl_id = f8 WITH noconstant(0.0)
 DECLARE oorgsecurity = i2 WITH noconstant(1)
 DECLARE strstatusmsg = vc WITH protect
 DECLARE i18nhandle = i4 WITH noconstant(0)
 RECORD i18n(
   1 need_valid_login = vc
   1 ids_non_zero = vc
   1 invalid_da_group_id = vc
   1 invalid_da2_group_id = vc
   1 failed_msg = vc
   1 number_copied = vc
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
 FREE RECORD groupprsnlids
 RECORD groupprsnlids(
   1 prsnlids[*]
     2 prsnl_id = f8
 )
 SET istat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 CALL doi18nonstrings(istat)
 SET current_prsnl_id = reqinfo->updt_id
 IF (current_prsnl_id <= 0)
  SET strstatusmsg = i18n->need_valid_login
  GO TO end_now
 ENDIF
 IF (((selecteddagroup=0) OR (da2groupcd=0)) )
  SET strstatusmsg = i18n->ids_non_zero
  GO TO end_now
 ENDIF
 SET groupcount = 0
 SELECT INTO "nl:"
  groupscnt = count(pg.prsnl_group_id)
  FROM prsnl_group pg,
   code_value cv
  WHERE pg.prsnl_group_type_cd=cv.code_value
   AND cv.code_set=357
   AND cv.active_ind=1
   AND cv.cdf_meaning="DISCERNGROUP"
   AND pg.active_ind=1
   AND pg.prsnl_group_id=selecteddagroup
  DETAIL
   groupcount = groupscnt
  WITH nocounter
 ;end select
 IF (groupcount=0)
  SET strstatusmsg = i18n->invalid_da_group_id
  GO TO end_now
 ENDIF
 SELECT INTO "nl:"
  groupscnt = count(cv.code_value)
  FROM code_value cv
  WHERE cv.code_set=4002360
   AND cv.active_ind=1
   AND cv.cdf_meaning="SECGROUP"
   AND cv.code_value=da2groupcd
  DETAIL
   groupcount = groupscnt
  WITH nocounter
 ;end select
 IF (groupcount=0)
  SET strstatusmsg = i18n->invalid_da2_group_id
  GO TO end_now
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info i
  WHERE i.info_name="SEC_ORG_RELTN"
   AND i.info_domain="SECURITY"
  DETAIL
   oorgsecurity = i.info_number
  WITH nocounter
 ;end select
 SET da2usercd = uar_get_code_by("DISPLAYKEY",355,"DISCERNANALYTICSUSER")
 IF (oorgsecurity=1)
  SELECT DISTINCT INTO "nl:"
   prsnl_id = po.person_id
   FROM prsnl_org_reltn po,
    organization o
   WHERE po.active_ind=1
    AND o.organization_id=po.organization_id
    AND sysdate BETWEEN po.beg_effective_dt_tm AND po.end_effective_dt_tm
    AND o.active_ind=1
    AND sysdate BETWEEN o.beg_effective_dt_tm AND o.end_effective_dt_tm
    AND (po.person_id=
   (SELECT
    p.person_id
    FROM prsnl_group_reltn pgr,
     prsnl p,
     prsnl_group pg,
     prsnl_info pi
    WHERE pgr.prsnl_group_id=pg.prsnl_group_id
     AND pgr.person_id=p.person_id
     AND pg.prsnl_group_id=selecteddagroup
     AND pgr.active_ind=1
     AND p.active_ind=1
     AND pi.active_ind=1
     AND pi.person_id=p.person_id
     AND pi.info_type_cd=da2usercd))
    AND (po.person_id !=
   (SELECT
    dgur.prsnl_id
    FROM da_group_user_reltn dgur
    WHERE dgur.group_cd=da2groupcd))
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
   ORDER BY po.person_id
   HEAD REPORT
    stat = alterlist(groupprsnlids->prsnlids,10), count = 0
   DETAIL
    count += 1
    IF (mod(count,10)=0)
     stat = alterlist(groupprsnlids->prsnlids,(count+ 10))
    ENDIF
    groupprsnlids->prsnlids[count].prsnl_id = po.person_id
   FOOT REPORT
    stat = alterlist(groupprsnlids->prsnlids,count)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   p.person_id, p.name_full_formatted
   FROM prsnl_group_reltn pgr,
    prsnl p,
    prsnl_group pg,
    prsnl_info pi
   WHERE pgr.prsnl_group_id=pg.prsnl_group_id
    AND pgr.person_id=p.person_id
    AND pgr.active_ind=1
    AND pg.prsnl_group_id=selecteddagroup
    AND pi.active_ind=1
    AND pi.person_id=p.person_id
    AND pi.info_type_cd=da2usercd
    AND (p.person_id !=
   (SELECT
    dgur.prsnl_id
    FROM da_group_user_reltn dgur
    WHERE dgur.group_cd=da2groupcd))
   HEAD REPORT
    stat = alterlist(groupprsnlids->prsnlids,10), count = 0
   DETAIL
    count += 1
    IF (mod(count,10)=0)
     stat = alterlist(groupprsnlids->prsnlids,(count+ 10))
    ENDIF
    groupprsnlids->prsnlids[count].prsnl_id = p.person_id
   FOOT REPORT
    stat = alterlist(groupprsnlids->prsnlids,count)
   WITH nocounter
  ;end select
 ENDIF
 INSERT  FROM da_group_user_reltn dgur,
   (dummyt d  WITH seq = value(size(groupprsnlids->prsnlids,5)))
  SET dgur.da_group_user_reltn_id = seq(da_seq,nextval), dgur.group_cd = da2groupcd, dgur.prsnl_id =
   groupprsnlids->prsnlids[d.seq].prsnl_id,
   dgur.updt_dt_tm = cnvtdatetime(sysdate), dgur.updt_id = reqinfo->updt_id, dgur.updt_task = reqinfo
   ->updt_task,
   dgur.updt_applctx = reqinfo->updt_applctx, dgur.updt_cnt = 0
  PLAN (d)
   JOIN (dgur)
  WITH nocounter
 ;end insert
 SET ecode = 0
 SET emsg = fillstring(132," ")
 SET ecode = error(strstatusmsg,1)
 IF (ecode != 0)
  SET strstatusmsg = concat(i18n->failed_msg,strstatusmsg)
  ROLLBACK
 ELSE
  SET strstatusmsg = concat(i18n->number_copied,build(size(groupprsnlids->prsnlids,5)))
  COMMIT
 ENDIF
#end_now
 SELECT INTO  $OUTDEV
  HEAD REPORT
   col 0, strstatusmsg, row + 1
  WITH nocounter
 ;end select
 FREE RECORD groupprsnlids
 FREE RECORD i18n
 SUBROUTINE (doi18nonstrings(ndummyvar=i2(value)) =null)
   SET i18n->need_valid_login = uar_i18ngetmessage(i18nhandle,"need_valid_login",
    "User must have valid login to run program")
   SET i18n->ids_non_zero = uar_i18ngetmessage(i18nhandle,"ids_non_zero",
    "Both the DA user group and DA2 security group IDs must not be 0")
   SET i18n->invalid_da_group_id = uar_i18ngetmessage(i18nhandle,"invalid_da_group_id",
    "Invalid DA user group ID")
   SET i18n->invalid_da2_group_id = uar_i18ngetmessage(i18nhandle,"invalid_da_group_id",
    "Invalid DA2 security group ID")
   SET i18n->failed_msg = uar_i18ngetmessage(i18nhandle,"failed_msg","FAILED:  ")
   SET i18n->number_copied = uar_i18ngetmessage(i18nhandle,"number_copied","Number of users copied: "
    )
 END ;Subroutine
END GO
