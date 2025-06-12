CREATE PROGRAM bhs_ops_expire_account:dba
 DECLARE mf_cs48_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE mf_cs48_suspend_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"SUSPENDED"))
 DECLARE mf_cs88_cernersupport_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",88,
   "CERNERSUPPORT"))
 DECLARE ms_run_type = vc WITH protect, constant(cnvtupper(trim( $1,3)))
 DECLARE ml_lookback = i4 WITH protect, constant( $2)
 DECLARE ms_email = vc WITH protect, constant(cnvtupper(trim( $3,3)))
 DECLARE ms_loc_dir = vc WITH protect, constant(build(logical("bhscust"),
   "/ftp/bhs_ops_expire_account/"))
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_stat = i4 WITH protect, noconstant(0)
 DECLARE ms_tmp = vc WITH protect, noconstant("")
 CALL echo(mf_cs48_active_cd)
 CALL echo(mf_cs48_suspend_cd)
 CALL echo(ms_run_type)
 CALL echo(ml_lookback)
 FREE RECORD acct
 RECORD acct(
   1 l_cnt = i4
   1 qual[*]
     2 f_person_id = f8
     2 s_username = vc
     2 s_position = vc
     2 l_phys_ind = i4
     2 s_name = vc
     2 l_epr_ind = i4
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE p.active_ind=1
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND p.updt_dt_tm < cnvtdatetime((curdate - (30 - ml_lookback)),0)
    AND p.active_status_cd=mf_cs48_active_cd
    AND p.position_cd != mf_cs88_cernersupport_cd
    AND  NOT (p.person_id IN (
   (SELECT
    oa.person_id
    FROM omf_app_ctx_day_st oa
    WHERE oa.person_id=p.person_id
     AND oa.start_day > cnvtdatetime((curdate - (30 - ml_lookback)),0))))
    AND ((substring(1,2,trim(p.username,3))="CN") OR (substring(1,3,trim(p.username,3))="CER"))
    AND  NOT (trim(p.username,3) IN ("CERSUP1", "CERSUP2", "CERSUP3", "CERSUP4", "CERSUP5",
   "CERNER", "CERNSUP"))
    AND  NOT (p.username IN (
   (SELECT
    eu.username
    FROM ea_user eu,
     ea_user_attribute_reltn er,
     ea_attribute ea
    WHERE ea.attribute_name="NOLOGFAILDISUSER"
     AND er.ea_attribute_id=ea.ea_attribute_id
     AND eu.ea_user_id=er.ea_user_id))))
  ORDER BY p.username, p.person_id
  HEAD REPORT
   acct->l_cnt = 0
  HEAD p.person_id
   acct->l_cnt += 1, stat = alterlist(acct->qual,acct->l_cnt), acct->qual[acct->l_cnt].f_person_id =
   p.person_id,
   acct->qual[acct->l_cnt].l_phys_ind = p.physician_ind, acct->qual[acct->l_cnt].s_position =
   uar_get_code_display(p.position_cd), acct->qual[acct->l_cnt].s_username = p.username,
   acct->qual[acct->l_cnt].s_name = trim(p.name_full_formatted,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE p.active_ind=1
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND p.updt_dt_tm < cnvtdatetime((curdate - (90 - ml_lookback)),0)
    AND p.active_status_cd=mf_cs48_active_cd
    AND p.position_cd != mf_cs88_cernersupport_cd
    AND  NOT (p.person_id IN (
   (SELECT
    oa.person_id
    FROM omf_app_ctx_day_st oa
    WHERE oa.person_id=p.person_id
     AND oa.start_day > cnvtdatetime((curdate - (90 - ml_lookback)),0))))
    AND  NOT (substring(1,4,trim(p.username,3)) IN ("SPND", "TERM", "SUSP", "MSOS"))
    AND  NOT (substring(1,2,trim(p.username,3)) IN ("RF", "CN"))
    AND  NOT (substring(1,3,trim(p.username,3)) IN ("NA-", "DUM", "CER"))
    AND  NOT (trim(p.username,3) IN ("TESTPR", "REFUSORD", "EDATTEND", "INPTATTEND", "FNDTLIST",
   "FNENGINE", "EDPLASMA", "TRAUMARESIDENT", "TRAUMARES", "EDCACHE",
   "BHSDBA", "CERSUP1", "CERSUP2", "CERSUP3", "CERSUP4",
   "CERSUP5", "ETE1", "ETE2", "ETE3", "MED2A",
   "MOBJECTS", "RESET", "PATROL", "SHIELDS", "PHTRIAGE",
   "BEDROCK", "SYSTEMHF", "EXTRA", "FHAUTH", "SYSTEMRRD",
   "SSOPVIXUSER", "BEHAVIORALHEALTHSAFETYCHECKS", "PRDIRECT", "MRDIRECT", "TRANSFERSDIRECT",
   "REFERRALSDIRECT", "GOTHATHOL", "GOTHHOLY", "GOTHPITTS"))
    AND  NOT (substring(1,3,trim(p.name_last_key,3)) IN ("BHS", "BMC", "FMC", "MLH", "BWH"))
    AND  NOT (substring(1,4,trim(p.name_last_key,3)) IN ("ORGS"))
    AND  NOT (trim(p.name_last_key,3) IN ("FIRSTNET", "CERNER", "HISTORICALMD"))
    AND p.name_last_key != "*INBOX*"
    AND p.name_last_key != "*SYSTEM*"
    AND p.name_last_key != "*BYPASS*"
    AND p.name_first_key != "*INBOX*"
    AND p.name_first_key != "*SYSTEM*"
    AND  NOT (p.username IN (
   (SELECT
    eu.username
    FROM ea_user eu,
     ea_user_attribute_reltn er,
     ea_attribute ea
    WHERE ea.attribute_name="NOLOGFAILDISUSER"
     AND er.ea_attribute_id=ea.ea_attribute_id
     AND eu.ea_user_id=er.ea_user_id))))
  ORDER BY p.username, p.person_id
  HEAD p.person_id
   acct->l_cnt += 1, stat = alterlist(acct->qual,acct->l_cnt), acct->qual[acct->l_cnt].f_person_id =
   p.person_id,
   acct->qual[acct->l_cnt].l_phys_ind = p.physician_ind, acct->qual[acct->l_cnt].s_position =
   uar_get_code_display(p.position_cd), acct->qual[acct->l_cnt].s_username = p.username,
   acct->qual[acct->l_cnt].s_name = trim(p.name_full_formatted,3)
  WITH nocounter
 ;end select
 IF ((acct->l_cnt > 0))
  FOR (ml_idx1 = 1 TO acct->l_cnt)
    SELECT INTO "nl:"
     FROM encntr_prsnl_reltn epr
     WHERE (epr.prsnl_person_id=acct->qual[ml_idx1].f_person_id)
      AND epr.updt_dt_tm > cnvtdatetime((curdate - (90 - ml_lookback)),0)
      AND ((epr.manual_create_ind=0) OR (epr.manual_create_ind=1
      AND epr.manual_create_dt_tm > cnvtdatetime((curdate - (90 - ml_lookback)),0)))
     HEAD epr.prsnl_person_id
      acct->qual[ml_idx1].l_epr_ind = 1
     WITH nocounter
    ;end select
  ENDFOR
  IF (ml_lookback=0)
   SET frec->file_name = build(ms_loc_dir,"bhs_ma_acct_suspend_today_",format(cnvtdatetime(sysdate),
     "YYYYMMDDHHMMSS;;q"),".csv")
   CALL echo(frec->file_name)
  ELSE
   SET frec->file_name = build(ms_loc_dir,"bhs_ma_acct_suspend_in_",trim(cnvtstring(ml_lookback),3),
    "_days_",format(cnvtdatetime(sysdate),"YYYYMMDDHHMMSS;;q"),
    ".csv")
   CALL echo(frec->file_name)
  ENDIF
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = concat('"USERNAME","PERSON_ID","POSITION","NAME","PHYSICIAN_IND"',char(10))
  SET stat = cclio("WRITE",frec)
  FOR (ml_idx1 = 1 TO acct->l_cnt)
    IF ((acct->qual[ml_idx1].l_epr_ind=0))
     SET frec->file_buf = concat('"',acct->qual[ml_idx1].s_username,'","',trim(cnvtstring(acct->qual[
        ml_idx1].f_person_id,20),3),'","',
      acct->qual[ml_idx1].s_position,'","',acct->qual[ml_idx1].s_name,'","',trim(cnvtstring(acct->
        qual[ml_idx1].l_phys_ind),3),
      '"',char(10))
     SET stat = cclio("WRITE",frec)
    ENDIF
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  IF (findstring("@",ms_email) > 0)
   EXECUTE bhs_ma_email_file
   SET ms_tmp = concat("CIS Accounts Expire Job: ",format(cnvtdatetime(sysdate),"YYYYMMDDHHMMSS;;q"))
   CALL emailfile(value(frec->file_name),frec->file_name,ms_email,ms_tmp,1)
  ENDIF
  IF (ms_run_type="SUSPEND")
   FOR (ml_idx1 = 1 TO acct->l_cnt)
     IF ((acct->qual[ml_idx1].l_epr_ind=0))
      IF (((substring(1,2,trim(acct->qual[ml_idx1].s_username,3)) IN ("SN", "CN")) OR (substring(1,3,
       trim(acct->qual[ml_idx1].s_username,3))="CER")) )
       UPDATE  FROM prsnl p
        SET p.username = concat(trim(substring(1,41,trim(p.username,3)),3),"_",format(curdate,
           "YYYYMMDD;;d")), p.updt_dt_tm = cnvtdatetime(sysdate), p.active_status_cd =
         mf_cs48_suspend_cd,
         p.updt_cnt = (p.updt_cnt+ 1), p.updt_id = 99999999
        WHERE (p.person_id=acct->qual[ml_idx1].f_person_id)
        WITH nocounter
       ;end update
       COMMIT
      ELSE
       UPDATE  FROM prsnl p
        SET p.username = concat("NA-",trim(substring(1,38,trim(p.username,3)),3),"_",format(curdate,
           "YYYYMMDD;;d")), p.updt_dt_tm = cnvtdatetime(sysdate), p.updt_cnt = (p.updt_cnt+ 1),
         p.updt_id = 99999999
        WHERE (p.person_id=acct->qual[ml_idx1].f_person_id)
        WITH nocounter
       ;end update
       COMMIT
      ENDIF
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
#exit_script
END GO
