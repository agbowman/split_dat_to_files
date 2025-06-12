CREATE PROGRAM bhs_ccl_pklist_autoset:dba
 PROMPT
  "selected_actions" = ""
  WITH update_action
 DECLARE mf_careteam = f8 WITH constant(uar_get_code_by("DISPLAYKEY",19189,"CARETEAM")), protect
 EXECUTE ccl_prompt_api_dataset "dataset"
 IF (( $UPDATE_ACTION="ADD"))
  SELECT
   pg.prsnl_group_name, pg.prsnl_group_id
   FROM prsnl_group pg
   PLAN (pg
    WHERE pg.prsnl_group_class_cd=mf_careteam
     AND pg.active_ind=1
     AND  NOT (pg.prsnl_group_id IN (
    (SELECT
     d.info_number
     FROM dm_info d
     WHERE d.info_domain="BHS_LIST_KEYS:PK_PAT_LIST"
      AND d.info_long_id=1.0
     WITH nocounter))))
   ORDER BY pg.prsnl_group_id
   HEAD REPORT
    pcnt = 0, stat = makedataset(10)
   HEAD pg.prsnl_group_id
    stat = writerecord(0)
   FOOT  pg.prsnl_group_id
    null
   FOOT REPORT
    stat = closedataset(0)
   WITH reporthelp, check
  ;end select
 ELSEIF (( $UPDATE_ACTION="REMOVE"))
  SELECT
   pg.prsnl_group_name, pg.prsnl_group_id
   FROM prsnl_group pg
   WHERE pg.prsnl_group_class_cd=11155.00
    AND pg.active_ind=1
    AND pg.prsnl_group_id IN (
   (SELECT
    d.info_number
    FROM dm_info d
    WHERE d.info_domain="BHS_LIST_KEYS:PK_PAT_LIST"
     AND d.info_long_id=1.0
    WITH nocounter))
   ORDER BY pg.prsnl_group_id
   HEAD REPORT
    stat = makedataset(10)
   HEAD pg.prsnl_group_id
    stat = writerecord(0)
   FOOT  pg.prsnl_group_id
    null
   FOOT REPORT
    stat = closedataset(0)
   WITH reporthelp, check
  ;end select
 ENDIF
END GO
