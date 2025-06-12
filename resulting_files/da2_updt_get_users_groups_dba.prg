CREATE PROGRAM da2_updt_get_users_groups:dba
 PROMPT
  "Type to modify <0>:" = "0"
  WITH modtype
 DECLARE oorgsecurity = i2 WITH noconstant(1)
 DECLARE num = i4 WITH protect
 FREE RECORD prsnlgroups
 RECORD prsnlgroups(
   1 prsnlgroupids[*]
     2 id = f8
 )
 SELECT INTO "nl:"
  FROM dm_info i
  WHERE i.info_name="SEC_ORG_RELTN"
   AND i.info_domain="SECURITY"
  DETAIL
   oorgsecurity = i.info_number
  WITH nocounter
 ;end select
 SET current_prsnl_id = reqinfo->updt_id
 EXECUTE ccl_prompt_api_dataset "autoset"
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
  IF (( $MODTYPE=1)
   AND oorgsecurity=1)DISTINCT
   o.user_id, p.name_full_formatted
   FROM omf_pv_items o,
    prsnl p,
    prsnl_org_reltn po
   WHERE o.user_id=p.person_id
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
   ORDER BY p.name_full_formatted
   HEAD REPORT
    stat = makedataset(10)
   DETAIL
    stat = writerecord(0)
   FOOT REPORT
    stat = closedataset(0)
   WITH reporthelp, check
  ELSEIF (( $MODTYPE=1)
   AND oorgsecurity=0)DISTINCT
   o.user_id, p.name_full_formatted
   FROM omf_pv_items o,
    prsnl p
   WHERE o.user_id=p.person_id
    AND o.user_id > 0
   ORDER BY p.name_full_formatted
   HEAD REPORT
    stat = makedataset(10)
   DETAIL
    stat = writerecord(0)
   FOOT REPORT
    stat = closedataset(0)
   WITH reporthelp, check
  ELSEIF (( $MODTYPE=3)
   AND oorgsecurity=1)DISTINCT
   pg.prsnl_group_id, pg.prsnl_group_name
   FROM prsnl_group pg,
    prsnl_group_reltn pgr
   WHERE expand(num,1,usergroupcount,pg.prsnl_group_id,prsnlgroups->prsnlgroupids[num].id)
    AND pgr.active_ind=1
    AND pg.prsnl_group_id > 0
    AND ((pgr.prsnl_group_id=pg.prsnl_group_id) MINUS (
   (SELECT DISTINCT
    pg.prsnl_group_id, pg.prsnl_group_name
    FROM prsnl_group pg,
     prsnl_group_reltn pgr
    WHERE expand(num,1,usergroupcount,pg.prsnl_group_id,prsnlgroups->prsnlgroupids[num].id)
     AND pgr.prsnl_group_id=pg.prsnl_group_id
     AND pgr.active_ind=1
     AND pg.prsnl_group_id > 0
     AND (pgr.person_id=
    (SELECT DISTINCT
     pgr.person_id
     FROM prsnl_group pg,
      prsnl_group_reltn pgr
     WHERE expand(num,1,usergroupcount,pg.prsnl_group_id,prsnlgroups->prsnlgroupids[num].id)
      AND pgr.prsnl_group_id=pg.prsnl_group_id
      AND pgr.active_ind=1
      AND ((pg.prsnl_group_id > 0) MINUS (
     (SELECT DISTINCT
      pgr.person_id
      FROM prsnl_group pg,
       prsnl_group_reltn pgr,
       prsnl_org_reltn po
      WHERE expand(num,1,usergroupcount,pg.prsnl_group_id,prsnlgroups->prsnlgroupids[num].id)
       AND pgr.prsnl_group_id=pg.prsnl_group_id
       AND po.person_id=pgr.person_id
       AND pgr.active_ind=1
       AND pg.prsnl_group_id > 0
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
   ORDER BY 2
   HEAD REPORT
    stat = makedataset(10)
   DETAIL
    stat = writerecord(0)
   FOOT REPORT
    stat = closedataset(0)
   WITH reporthelp, check
  ELSEIF (( $MODTYPE=3)
   AND oorgsecurity=0)DISTINCT
   pg.prsnl_group_id, pg.prsnl_group_name
   FROM prsnl_group pg,
    prsnl_group_reltn pgr
   WHERE expand(num,1,usergroupcount,pg.prsnl_group_id,prsnlgroups->prsnlgroupids[num].id)
    AND pgr.prsnl_group_id=pg.prsnl_group_id
    AND pgr.active_ind=1
    AND pg.prsnl_group_id > 0
   ORDER BY pg.prsnl_group_name
   HEAD REPORT
    stat = makedataset(10)
   DETAIL
    stat = writerecord(0)
   FOOT REPORT
    stat = closedataset(0)
   WITH reporthelp, check
  ELSE
  ENDIF
 ;end select
 FREE RECORD prsnlgroups
END GO
