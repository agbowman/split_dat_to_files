CREATE PROGRAM bhs_rpt_mpage_icu_status:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE bhs_check_domain
 FREE RECORD m_monitor
 RECORD m_monitor(
   1 inactive_rows[*]
     2 s_inactive_asset_tag = vc
   1 active_rows[*]
     2 s_active_asset_tag = vc
 ) WITH protect
 DECLARE mf_lst_ran_ops = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE ml_down = i4 WITH protect, noconstant(0)
 DECLARE ml_inactive = i4 WITH protect, noconstant(0)
 DECLARE ml_active = i4 WITH protect, noconstant(0)
 DECLARE ml_counter = i4 WITH protect, noconstant(0)
 DECLARE ml_dclcom_len = i4 WITH protect, noconstant(0)
 DECLARE mn_dclcom_stat = i2 WITH protect, noconstant(0)
 DECLARE ms_inactive_asset = vc WITH protect, noconstant(" ")
 DECLARE ms_email_body = vc WITH protect, noconstant(" ")
 DECLARE ms_email_list = vc WITH protect, noconstant(" ")
 DECLARE ms_dclcom_str = vc WITH protect, noconstant(" ")
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="BHS_RPT_MPAGE_ICU_STATUS"
  DETAIL
   mf_lst_ran_ops = di.updt_dt_tm
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="BHS_MP_ICU_DRIVER"
  HEAD REPORT
   ml_inactive = 0, ml_active = 0
  DETAIL
   IF (di.updt_dt_tm > cnvtlookbehind("5, MIN",sysdate))
    ml_active = (ml_active+ 1),
    CALL alterlist(m_monitor->active_rows,(ml_active+ 1)), m_monitor->active_rows[ml_active].
    s_active_asset_tag = di.info_name
   ELSE
    IF (((di.info_char="Active") OR (di.info_char="Inactive"
     AND di.updt_dt_tm > mf_lst_ran_ops)) )
     ml_inactive = (ml_inactive+ 1),
     CALL alterlist(m_monitor->inactive_rows,(ml_inactive+ 1)), m_monitor->inactive_rows[ml_inactive]
     .s_inactive_asset_tag = di.info_name
     IF (size(trim(ms_inactive_asset,3)) > 0)
      ms_inactive_asset = concat(ms_inactive_asset,", ",trim(di.info_name))
     ELSE
      ms_inactive_asset = trim(di.info_name)
     ENDIF
    ELSE
     ml_down = (ml_down+ 1)
    ENDIF
   ENDIF
 ;end select
 UPDATE  FROM dm_info di
  SET di.info_char = "Inactive"
  WHERE trim(di.info_domain,3)="BHS_MP_ICU_DRIVER"
   AND expand(ml_counter,1,size(m_monitor->inactive_rows,5),di.info_name,m_monitor->inactive_rows[
   ml_counter].s_inactive_asset_tag)
  WITH nocounter
 ;end update
 COMMIT
 UPDATE  FROM dm_info di
  SET di.info_char = "Active"
  WHERE trim(di.info_domain,3)="BHS_MP_ICU_DRIVER"
   AND expand(ml_counter,1,size(m_monitor->active_rows,5),di.info_name,m_monitor->active_rows[
   ml_counter].s_active_asset_tag)
  WITH nocounter
 ;end update
 COMMIT
 IF (ml_inactive > 0
  AND gl_bhs_prod_flag=1
  AND validate(request->batch_selection))
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE trim(di.info_domain,3)="BHS_MP_ICU_DRIVER:EMAIL"
   DETAIL
    IF (size(trim(ms_email_list,3)) > 0)
     ms_email_list = concat(ms_email_list,", ",trim(di.info_name,3))
    ELSE
     ms_email_list = trim(di.info_name,3)
    ENDIF
   WITH nocounter
  ;end select
  IF (ml_inactive < 15)
   SET ms_email_body = concat(
    "The mpage ICU Monitor Status Report has located the following inactive monitors: ",
    ms_inactive_asset)
  ELSE
   SET ms_email_body = concat(
    "The mpage ICU Monitor Status Report has located that there are currently ",cnvtstring(
     ml_inactive),
    " inactive monitors. Please run bhs_rpt_mpage_icu_status from Explorer Menu for full listing.")
  ENDIF
  SET ms_dclcom_str = concat("echo ",ms_email_body," | mailx -s MPage_Inactive ",ms_email_list)
  SET ml_dclcom_len = size(trim(ms_dclcom_str,3))
  SET mn_dclcom_stat = 0
  SET stat = dcl(ms_dclcom_str,ml_dclcom_len,mn_dclcom_stat)
  UPDATE  FROM dm_info di
   SET di.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WHERE trim(di.info_domain,3)="BHS_RPT_MPAGE_ICU_STATUS"
   WITH nocounter
  ;end update
  COMMIT
 ELSE
  SELECT INTO  $OUTDEV
   FROM dm_info di
   WHERE di.info_domain="BHS_MP_ICU_DRIVER"
   HEAD REPORT
    col 0, "Asset Tag", col 15,
    "Last Updated", col 40, "Location Code",
    col 60, "Active/Inactive", row + 1
   DETAIL
    IF (di.updt_dt_tm > cnvtlookbehind("5, MIN",sysdate))
     col 0,
     CALL print(trim(di.info_name)), col 15,
     CALL print(trim(format(di.updt_dt_tm,"@SHORTDATETIME"))), col 40,
     CALL print(trim(cnvtstring(di.info_number))),
     col 60, "Active", row + 1
    ELSE
     IF (((di.info_char="Active") OR (di.info_char="Inactive"
      AND di.updt_dt_tm > mf_lst_ran_ops)) )
      col 0,
      CALL print(trim(di.info_name)), col 15,
      CALL print(trim(format(di.updt_dt_tm,"@SHORTDATETIME"))), col 40,
      CALL print(trim(cnvtstring(di.info_number))),
      col 60, "Inactive", row + 1
     ELSE
      col 0,
      CALL print(trim(di.info_name)), col 15,
      CALL print(trim(format(di.updt_dt_tm,"@SHORTDATETIME"))), col 40,
      CALL print(trim(cnvtstring(di.info_number))),
      col 60, "Down", row + 1
     ENDIF
    ENDIF
   FOOT REPORT
    col 0,
    CALL print(build2("Active: ",trim(cnvtstring(ml_active)))), col 15,
    CALL print(build2("Inactive: ",trim(cnvtstring(ml_inactive)))), col 30,
    CALL print(build2("Down: ",trim(cnvtstring(ml_down)))),
    col 45,
    CALL print(build2("Total: ",trim(cnvtstring(((ml_active+ ml_inactive)+ ml_down)))))
   WITH nocounter, format, separator = "  ",
    format(date,"@SHORTDATETIME"), maxcol = 100
  ;end select
 ENDIF
 FREE RECORD m_monitor
END GO
