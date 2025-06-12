CREATE PROGRAM da2_updt_owner_omf_views:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Type to modify <0>:" = 0,
  "Select User/Group <0>:" = 0
  WITH outdev, modtype, selecteditem
 DECLARE mtype = i2 WITH constant( $MODTYPE)
 DECLARE selecteduserorgroup = f8 WITH constant( $SELECTEDITEM)
 DECLARE current_prsnl_id = f8 WITH noconstant(0.0)
 DECLARE oorgsecurity = i2 WITH noconstant(1)
 DECLARE strstatusmsg = vc WITH protect
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE num = i4 WITH protect
 FREE RECORD i18n
 RECORD i18n(
   1 need_valid_login = vc
   1 invalid_mod_type = vc
   1 invalid_id = vc
   1 failed_msg = vc
   1 number_modified = vc
   1 empty_group_msg = vc
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
 FREE RECORD prsnlorgroupidstomodify
 RECORD prsnlorgroupidstomodify(
   1 prsnlorgroupids[*]
     2 id = f8
 )
 FREE RECORD prsnlgroups
 RECORD prsnlgroups(
   1 prsnlgroupids[*]
     2 id = f8
 )
 SET istat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 CALL doi18nonstrings(istat)
 SET current_prsnl_id = reqinfo->updt_id
 IF (current_prsnl_id <= 0)
  SET strstatusmsg = i18n->need_valid_login
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
 IF (((mtype < 1) OR (mtype > 4)) )
  SET strstatusmsg = i18n->invalid_mod_type
  GO TO end_now
 ENDIF
 SET usergroupcount = 0
 SELECT DISTINCT INTO "nl:"
  groupid = pg.prsnl_group_id
  FROM prsnl_group pg,
   code_value cv
  WHERE cv.code_set=357
   AND cv.active_ind=1
   AND cv.cdf_meaning="DISCERNGROUP"
   AND pg.prsnl_group_type_cd=cv.code_value
   AND pg.active_ind=1
  HEAD REPORT
   stat = alterlist(prsnlgroups->prsnlgroupids,10), usergroupcount = 0
  DETAIL
   usergroupcount += 1
   IF (mod(usergroupcount,10)=0)
    stat = alterlist(prsnlgroups->prsnlgroupids,(usergroupcount+ 10))
   ENDIF
   prsnlgroups->prsnlgroupids[usergroupcount].id = groupid
  FOOT REPORT
   stat = alterlist(prsnlgroups->prsnlgroupids,usergroupcount)
  WITH nocounter
 ;end select
 SELECT
  IF (mtype=1
   AND oorgsecurity=1)DISTINCT INTO "nl:"
   userid = o.user_id
   FROM omf_pv_items o,
    prsnl_org_reltn po
   WHERE o.user_id=selecteduserorgroup
    AND o.user_id=po.person_id
    AND o.user_id > 0
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
  ELSEIF (mtype=1
   AND oorgsecurity=0)DISTINCT INTO "nl:"
   userid = o.user_id
   FROM omf_pv_items o
   WHERE o.user_id=selecteduserorgroup
    AND o.user_id > 0
  ELSEIF (mtype=2
   AND oorgsecurity=1)DISTINCT INTO "nl:"
   userid = o.user_id
   FROM omf_pv_items o,
    prsnl_org_reltn po
   WHERE o.user_id=po.person_id
    AND o.user_id > 0
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
  ELSEIF (mtype=2
   AND oorgsecurity=0)DISTINCT INTO "nl:"
   userid = o.user_id
   FROM omf_pv_items o
   WHERE o.user_id > 0
  ELSEIF (mtype=3
   AND oorgsecurity=1)DISTINCT INTO "nl:"
   userid = pg.prsnl_group_id
   FROM prsnl_group pg,
    prsnl_group_reltn pgr
   WHERE pg.active_ind=1
    AND pg.prsnl_group_id=selecteduserorgroup
    AND pg.prsnl_group_id > 0
    AND pg.active_ind=1
    AND pgr.active_ind=1
    AND ((pgr.prsnl_group_id=pg.prsnl_group_id) MINUS (
   (SELECT DISTINCT
    pg.prsnl_group_id
    FROM prsnl_group pg,
     prsnl_group_reltn pgr
    WHERE expand(num,1,usergroupcount,pg.prsnl_group_id,prsnlgroups->prsnlgroupids[num].id)
     AND pg.active_ind=1
     AND pgr.active_ind=1
     AND pgr.prsnl_group_id=pg.prsnl_group_id
     AND (pgr.person_id=
    (SELECT DISTINCT
     pgr.person_id
     FROM prsnl_group pg,
      prsnl_group_reltn pgr
     WHERE expand(num,1,usergroupcount,pg.prsnl_group_id,prsnlgroups->prsnlgroupids[num].id)
      AND pg.active_ind=1
      AND pgr.active_ind=1
      AND ((pgr.prsnl_group_id=pg.prsnl_group_id) MINUS (
     (SELECT DISTINCT
      pgr.person_id
      FROM prsnl_group pg,
       prsnl_group_reltn pgr,
       prsnl_org_reltn po
      WHERE expand(num,1,usergroupcount,pg.prsnl_group_id,prsnlgroups->prsnlgroupids[num].id)
       AND pg.active_ind=1
       AND pgr.active_ind=1
       AND pgr.prsnl_group_id=pg.prsnl_group_id
       AND po.person_id=pgr.person_id
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
        AND sysdate BETWEEN o.beg_effective_dt_tm AND o.end_effective_dt_tm))))) )))))
  ELSEIF (mtype=3
   AND oorgsecurity=0)DISTINCT INTO "nl:"
   userid = pg.prsnl_group_id
   FROM prsnl_group pg,
    prsnl_group_reltn pgr
   WHERE pg.active_ind=1
    AND pg.prsnl_group_id=selecteduserorgroup
    AND pg.prsnl_group_id > 0
    AND pgr.active_ind=1
    AND pgr.prsnl_group_id=pg.prsnl_group_id
  ELSEIF (mtype=4
   AND oorgsecurity=1)DISTINCT INTO "nl:"
   userid = pg.prsnl_group_id
   FROM prsnl_group pg,
    prsnl_group_reltn pgr
   WHERE expand(num,1,usergroupcount,pg.prsnl_group_id,prsnlgroups->prsnlgroupids[num].id)
    AND pg.active_ind=1
    AND pg.prsnl_group_id > 0
    AND pgr.active_ind=1
    AND ((pgr.prsnl_group_id=pg.prsnl_group_id) MINUS (
   (SELECT DISTINCT
    pg.prsnl_group_id
    FROM prsnl_group pg,
     prsnl_group_reltn pgr
    WHERE expand(num,1,usergroupcount,pg.prsnl_group_id,prsnlgroups->prsnlgroupids[num].id)
     AND pg.active_ind=1
     AND pgr.active_ind=1
     AND pgr.prsnl_group_id=pg.prsnl_group_id
     AND (pgr.person_id=
    (SELECT DISTINCT
     pgr.person_id
     FROM prsnl_group pg,
      prsnl_group_reltn pgr
     WHERE expand(num,1,usergroupcount,pg.prsnl_group_id,prsnlgroups->prsnlgroupids[num].id)
      AND pg.active_ind=1
      AND pgr.active_ind=1
      AND ((pgr.prsnl_group_id=pg.prsnl_group_id) MINUS (
     (SELECT DISTINCT
      pgr.person_id
      FROM prsnl_group pg,
       prsnl_group_reltn pgr,
       prsnl_org_reltn po
      WHERE expand(num,1,usergroupcount,pg.prsnl_group_id,prsnlgroups->prsnlgroupids[num].id)
       AND pg.active_ind=1
       AND pgr.active_ind=1
       AND pgr.prsnl_group_id=pg.prsnl_group_id
       AND po.person_id=pgr.person_id
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
        AND sysdate BETWEEN o.beg_effective_dt_tm AND o.end_effective_dt_tm))))) )))))
  ELSEIF (mtype=4
   AND oorgsecurity=0)DISTINCT INTO "nl:"
   userid = pg.prsnl_group_id
   FROM prsnl_group pg,
    prsnl_group_reltn pgr
   WHERE expand(num,1,usergroupcount,pg.prsnl_group_id,prsnlgroups->prsnlgroupids[num].id)
    AND pg.active_ind=1
    AND pg.prsnl_group_id > 0
    AND pgr.active_ind=1
    AND pgr.prsnl_group_id=pg.prsnl_group_id
  ELSE
  ENDIF
  HEAD REPORT
   stat = alterlist(prsnlorgroupidstomodify->prsnlorgroupids,10), usergroupcount = 0
  DETAIL
   usergroupcount += 1
   IF (mod(usergroupcount,10)=0)
    stat = alterlist(prsnlorgroupidstomodify->prsnlorgroupids,(usergroupcount+ 10))
   ENDIF
   prsnlorgroupidstomodify->prsnlorgroupids[usergroupcount].id = userid
  FOOT REPORT
   stat = alterlist(prsnlorgroupidstomodify->prsnlorgroupids,usergroupcount)
  WITH nocounter
 ;end select
 IF (usergroupcount=0)
  SET strstatusmsg = i18n->invalid_id
  GO TO end_now
 ENDIF
 SET viewcount = 0
 IF (((mtype=1) OR (mtype=2)) )
  UPDATE  FROM omf_pv_items o
   SET o.filter_prompt_ind = 1, o.updt_dt_tm = cnvtdatetime(sysdate), o.updt_id = reqinfo->updt_id,
    o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = (o
    .updt_cnt+ 1)
   WHERE expand(num,1,usergroupcount,o.user_id,prsnlorgroupidstomodify->prsnlorgroupids[num].id)
    AND o.user_id > 0
    AND o.item_type_flag < 4
  ;end update
  SET viewcount = curqual
 ELSEIF (((mtype=3) OR (mtype=4)) )
  UPDATE  FROM omf_pv_items o
   SET o.filter_prompt_ind = 1, o.updt_dt_tm = cnvtdatetime(sysdate), o.updt_id = reqinfo->updt_id,
    o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = (o
    .updt_cnt+ 1)
   WHERE expand(num,1,usergroupcount,o.prsnl_group_id,prsnlorgroupidstomodify->prsnlorgroupids[num].
    id)
    AND o.prsnl_group_id > 0
    AND o.item_type_flag < 4
  ;end update
  SET viewcount = curqual
 ENDIF
 SET ecode = 0
 SET emsg = fillstring(132," ")
 SET ecode = error(strstatusmsg,1)
 IF (ecode != 0)
  SET strstatusmsg = concat(i18n->failed_msg,strstatusmsg)
  ROLLBACK
 ELSE
  SET strstatusmsg = concat(i18n->number_modified,build(viewcount))
  COMMIT
 ENDIF
#end_now
 SELECT INTO  $OUTDEV
  HEAD REPORT
   col 0, strstatusmsg, row + 1
  FOOT REPORT
   IF (mtype=4)
    row + 1, col 0, i18n->empty_group_msg,
    row + 1
   ENDIF
  WITH nocounter
 ;end select
 FREE RECORD prsnlorgroupidstomodify
 FREE RECORD i18n
 FREE RECORD prsnlgroups
 SUBROUTINE (doi18nonstrings(ndummyvar=i2(value)) =null)
   SET i18n->need_valid_login = uar_i18ngetmessage(i18nhandle,"need_valid_login",
    "User must have valid login to run program")
   SET i18n->failed_msg = uar_i18ngetmessage(i18nhandle,"failed_msg","FAILED:  ")
   SET i18n->number_modified = uar_i18ngetmessage(i18nhandle,"number_added",
    "Number of saved views modified: ")
   SET i18n->invalid_mod_type = uar_i18ngetmessage(i18nhandle,"invalid_mod_type",
    "Selected modification type must be 1, 2, 3, or 4")
   SET i18n->invalid_id = uar_i18ngetmessage(i18nhandle,"invalid_id",
    "The provided user/group ID is not valid")
   SET i18n->empty_group_msg = uar_i18ngetmessage(i18nhandle,"empty_group_msg",
    "NOTE: User groups that contain no users will not have their saved views modified")
 END ;Subroutine
END GO
