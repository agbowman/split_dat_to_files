CREATE PROGRAM cclstartup:dba
 SET hnam_release = 2018
 SET currevafd = 0
 SET modify compileversion 2
 DECLARE false = i4 WITH persist, constant(0)
 DECLARE true = i4 WITH persist, constant(1)
 DECLARE eksdebug = c1 WITH persist, noconstant("0")
 DECLARE isodbc = i4 WITH persist, noconstant(0)
 CALL echo(uar_get_version())
 EXECUTE secrtl:dba
 IF (curenv=0
  AND curbatch=0
  AND validate(xxcclseclogin->loggedin,99) != 1)
  EXECUTE cclseclogin
 ENDIF
 SET ccl_nls_lang = cnvtupper(logical("NLS_LANG"))
 SET ccl_rdbms_connect = cnvtupper(logical("CER_RDBMS_CONNECT"))
 IF (ccl_rdbms_connect > " ")
  CALL echo(build("cer_rdbms_connect=",ccl_rdbms_connect))
 ENDIF
 SET ccl_node = cnvtupper(logical("JOU_INSTANCE"))
 SET language_log = fillstring(5," ")
 SET language_log = cnvtupper(logical("CCL_LANG"))
 IF (language_log=" ")
  SET language_log = cnvtupper(logical("LANG"))
  IF (language_log IN (" ", "C"))
   SET language_log = "EN_US"
  ENDIF
 ENDIF
 SET jcm_log = cnvtupper(logical("JCMSERVER"))
 SET ccl_env = cnvtupper(logical("ENVIRONMENT_MODE"))
 SET ccl_env2 = cnvtupper(logical("ENVIRONMENT"))
 IF (ccl_env=" ")
  SET ccl_env = ccl_env2
 ENDIF
 EXECUTE crmrtl:dba
 EXECUTE srvrtl:dba
 EXECUTE srvuri_mft:dba
 EXECUTE srvcore:dba
 EXECUTE msgrtl:dba
 IF (currev >= 8)
  EXECUTE cclauditdef
 ENDIF
 IF (cursysbit=32)
  IF (trace("DEPRECATED"))
   DECLARE dcl(p1=vc,p2=i4,p3=i4) = i4 WITH persist
  ELSE
   DECLARE dcl(p1,p2,p3) = i4 WITH persist
  ENDIF
 ENDIF
 EXECUTE ccluarrtl:dba
 DECLARE cclsql_cnvtdatetimeutc() = dq8 WITH persist
 DECLARE cclsql_cnvtutc() = dq8 WITH persist
 DECLARE cclsql_datetimediff() = f8 WITH persist
 DECLARE cclsql_datetimetrunc() = dq8 WITH persist
 DECLARE cclsql_datetimezonebyindex() = c128 WITH persist
 DECLARE cclsql_datetimezonebyname() = i4 WITH persist
 DECLARE cclsql_encountertz() = i4 WITH persist
 DECLARE cclsql_tzabbrev() = c128 WITH persist
 DECLARE cclsql_utc_cnvt() = dq8 WITH persist
 DECLARE cclsql_utc_cnvt2() = c22 WITH persist
 RECORD eks_global(
   1 sub1 = c1
   1 logic_return_buf = vc
   1 action_return_buf = vc
 ) WITH persist
 RECORD ccldminfo(
   1 mode = i1
   1 sec_org_reltn = i1
   1 sec_confid = i1
   1 person_org_sec = i1
 ) WITH persist
 RECORD cpmdummyrec(
   1 context = c1
   1 contextin = c1
   1 eks_common = c1
   1 errorrecord = c1
   1 event = c1
   1 internal = c1
   1 queuerecord = c1
   1 reply = c1
   1 replyin = c1
   1 replyout = c1
   1 reqinfo = c1
   1 request = c1
   1 requestin = c1
   1 reqdata = c1
   1 ccldminfo = c1
   1 crmreqinfo = c1
 ) WITH persist
 RECORD cclfmt(
   1 shortdate = vc
   1 mediumdate = vc
   1 longdate = vc
   1 shortdatetime = vc
   1 mediumdatetime = vc
   1 longdatetime = vc
   1 timewithseconds = vc
   1 timenoseconds = vc
   1 weekdaynumber = vc
   1 weekdayabbrev = vc
   1 weekdayname = vc
   1 monthnumber = vc
   1 monthabbrev = vc
   1 monthname = vc
   1 shortdate4yr = vc
   1 mediumdate4yr = vc
   1 shortdatetimenosec = vc
   1 datetimecondensed = vc
   1 datecondensed = vc
   1 mediumdate4yr2 = vc
   1 ccl_rdbms_noconnect = vc
   1 ccl_email_review = vc
   1 ccl_email_time = vc
   1 ccl_email_errors = vc
   1 ccl_rdbms_server = vc
   1 ccl_rdbms_tns = vc
   1 ccl_last = vc
 ) WITH persist
 IF (cursysbit=64)
  RECORD cclrechandle(
    1 hsys = i1
    1 hcharge = i1
    1 file_desc = i1
    1 hxmlroot = i1
    1 hxmlhippscode = i1
    1 hxmlprocedurecode = i1
    1 hxmldiagnosiscode = i1
    1 i18nhandle = i1
  ) WITH persist
 ENDIF
 CALL setup_cpmcreatefilename(1)
 SET server_srvtime = 21
 SET server_cpm_auth = 50
 SET server_cpm_script = 51
 SET server_cpm_decoder = 52
 SET server_cpm_scriptp = 53
 SET server_cpm_scripta = 54
 SET server_cpm_process = 55
 SET server_cpm_script_batch = 56
 SET server_cpm_script_discern = 58
 SET server_cpm_script_001 = 61
 SET server_cpm_script_002 = 62
 SET server_cpm_script_003 = 63
 SET server_cpm_script_004 = 64
 SET server_cpm_script_005 = 65
 SET server_cpm_audit = 70
 SET server_cpm_script_report = 74
 SET server_cpm_script_cache = 80
 SET server_discern_asynch1 = 150
 SET server_discern_asynch2 = 151
 SET server_discern_asynch3 = 152
 SET server_discern_asynch4 = 153
 SET server_discern_odbc = 170
 SET server_discern_synch = 175
 SET server_discern_event = 176
 SET server_cpm_script_batchcust = 179
 SET server_oen_begin1 = 240
 SET server_oen_end1 = 247
 SET server_oen_begin2 = 700
 SET server_oen_end2 = 1999
 IF (ccl_env="*TEST*")
  SET trace = exitcleanup
 ENDIF
 IF (validate(curprcname," ")=" ")
  SET curprcname = " "
 ENDIF
 IF (cnvtupper(curprcname)="SRV*")
  SET server_num = cnvtint(substring(4,4,curprcname))
  IF (textlen(trim(curprcname)) >= 15)
   SET instance_num = cnvtint(substring(9,4,curprcname))
   SET domain_num = cnvtint(substring(14,1,curprcname))
  ELSE
   SET instance_num = cnvtint(substring(9,2,curprcname))
   SET domain_num = cnvtint(substring(12,1,curprcname))
  ENDIF
 ELSE
  SET server_num = 0
  SET instance_num = 0
  SET domain_num = 0
 ENDIF
 IF (server_num=0)
  DECLARE _cmb_server = c4 WITH constant(substring(1,4,logical("CMB_SERVER")))
  SET server_num = cnvtint(_cmb_server)
  SET trace = callecho
  CALL echo(build("Read CMB_SERVER logical, server_num= ",server_num))
 ENDIF
 SET cclfmt->ccl_rdbms_noconnect = concat("[12150-12236]","[12500-12699]","[25401-25409]","[18]",
  "[19]",
  "[20]","[28]","[41]","[451]","[452]",
  "[1001]","[1012]","[1014]","[1033]","[1034]",
  "[1089]","[1090]","[1092]","[2396]","[3106]",
  "[3113]","[3114]","[3127]","[3135]","[12154]",
  "[12203]","[12206]","[12221]","[12222]","[12223]",
  "[12224]","[12500]","[12505]","[12531]","[12533]",
  "[12535]","[12537]","[12538]","[12540]","[12541]",
  "[12542]","[12545]","[12546]","[12547]","[12560]",
  "[12570]","[12571]","[12598]","[25402]","[25405]",
  "[25408]")
 SET cclfmt->ccl_rdbms_server = concat("[376]","[1157]","[4020]","[4021]","[4030]")
 EXECUTE cclstartup_locale:dba language_log
 SET trace = callecho
 SET trace = srvuint
 SET trace = nocost
 SET trace = noflush
 SET trace = noskiprecache
 SET trace = rdbbindcons
 SET trace = noechorecdebug
 SET trace = noechorecord
 SET trace = noechoprog
 SET trace = memory5
 SET trace rangecache 200
 SET trace progcache 200
 SET trace progcachesize 125
 SET trace memsort 3000
 SET trace = nordbprogram
 SET trace rdbarrayinsert 100
 SET trace = cnvtbigintreal
 SET trace rdbstmtcache 200
 CASE (currdb)
  OF "DB2UDB":
   SET trace = nordbprogram
   SET trace rdbarrayfetch 25
   SET trace rdbarrayfetch 1
  OF "SQLSRV":
   SET trace = nordbprogram
   SET trace rdbarrayfetch 25
  OF "ORACLE":
   IF (cursys="WIN")
    SET trace = nordbprogram
   ELSE
    SET trace = rdbprogram
   ENDIF
   SET trace rdbarrayfetch 25
 ENDCASE
 IF (curenv=0)
  SET oci_exists = checkdic("CCLUAR_OCI","P",0)
  IF (oci_exists=2)
   EXECUTE ccluar_oci "Y", 0
  ELSE
   CALL echo("CCLUAR_OCI not found: bypassing UAR OCI init.")
  ENDIF
  IF (ccl_env="*PROD*")
   SET trace = nowarning
   SET trace = nowarning2
  ELSEIF (ccl_env="*CERT*")
   SET trace = warning
   SET trace = nowarning2
  ELSEIF (ccl_env="*TEST*")
   SET trace = warning
   SET trace = warning2
  ELSE
   SET trace = warning
   SET trace = nowarning2
  ENDIF
  SET trace = cost
  SET message = noinformation
  CALL setup_reqdata(0)
  CALL setup_dminfo(0)
  SET message = information
  SET trace = skipreconnect
  SET trace registerprg "D"
 ELSE
  CALL echo("calling setup_server()")
  SET trace = nowarning
  SET trace = nowarning2
  CALL setup_server(0)
  CALL setup_jcmserver(0)
  IF (server_num > 0)
   SET trace = server
   IF (server_num IN (server_cpm_script_batch, server_cpm_script_discern, server_discern_odbc))
    SET trace registerprg "D"
   ENDIF
  ELSE
   SET trace = rdblogincase
  ENDIF
 ENDIF
 IF (checkprg("CCLSTARTUP_CUSTREFLOG")=0)
  RECORD cclreflog(
    1 code_value = c1
    1 code_value_set = c1
    1 code_value_alias = c1
    1 eks_request = c1
    1 chart_request = c1
  ) WITH persist
 ELSE
  EXECUTE cclstartup_custreflog
 ENDIF
 RECORD cclrptaudit_rec(
   1 programs[*]
     2 script_name = vc
   1 users[*]
     2 user_name = vc
     2 prsnl_id = f8
 ) WITH persist
 CALL echo(build("Env:",ccl_env," Env2:",ccl_env2," Node:",
   ccl_node," Prcname:",curprcname," Server:",server_num,
   " Instance:",instance_num," Domain:",domain_num," Nls:",
   ccl_nls_lang))
 IF (currev >= 8
  AND currevminor >= 1)
  CALL echo(build("TimeZone:",curtimezonesys,",",datetimezonebyindex(curtimezonesys)))
 ENDIF
 SUBROUTINE setup_server(par_nothing)
   IF (ccl_env="*PROD*")
    SET trace = noflush
    SET trace flush 3600
    SET trace = skiprecache
   ELSE
    SET trace = noflush
    SET trace flush 900
    SET trace = skiprecache
    IF (server_num IN (54, 57, 106, 625, 626))
     SET trace = noskiprecache
    ENDIF
   ENDIF
   IF (currev >= 8)
    IF (server_num IN (51, 56, 61, 62, 63,
    64, 65))
     SET trace = hipaa
     SET trace = skipabort
    ELSEIF (server_num IN (101, 102, 104, 106, 131,
    132, 140, 200, 330, 420,
    625, 626))
     SET trace = hipaa2
    ENDIF
   ENDIF
   IF (server_num IN (53, 70, 80, 103, 106,
   111, 112, 117, 119))
    SET trace = rdbtranend
   ENDIF
   CASE (server_num)
    OF server_srvtime:
     SET trace = rdblogincase
    OF server_cpm_auth:
     SET trace = autolock
    OF server_cpm_process:
     SET trace = autolock
    OF server_cpm_script:
     SET trace = autolock
     SET trace = skippersist
    OF server_cpm_script_batch:
     SET trace = autolock
     SET trace = noskiprecache
    OF server_cpm_script_discern:
     SET trace = cost
     DECLARE _report_readonly = i2 WITH persist, constant(1)
    OF server_cpm_script_report:
     SET trace = cost
     SET trace = noskiprecache
     DECLARE _report_readonly = i2 WITH persist, constant(1)
    OF server_discern_asynch1:
    OF server_discern_asynch2:
    OF server_discern_asynch3:
    OF server_discern_synch:
     SET trace = noautolock
    OF server_discern_asynch4:
     SET trace = noautolock
     SET trace = cost
    OF server_cpm_script_batchcust:
     SET trace = noskiprecache
    ELSE
     IF (server_num BETWEEN server_oen_begin1 AND server_oen_end1)
      SET trace memsort 1000
      SET trace = noautolock
     ELSEIF (server_num BETWEEN server_oen_begin2 AND server_oen_end2)
      SET trace memsort 1000
      SET trace = noautolock
     ELSEIF (server_num != 0)
      SET trace = autolock
     ENDIF
   ENDCASE
 END ;Subroutine
 SUBROUTINE setup_jcmserver(par_nothing)
   IF (curbatch=0
    AND jcm_log != " ")
    SET trace = callecho
    CALL echo("jcmserver debug...")
    SET trace = noautolock
    SET trace = nocallecho
    SET trace = cost
    SET trace = noflush
    SET trace flush 60
    SET trace = exitcleanup
    SET log_redirect = 1
    IF (findstring("1",jcm_log))
     SET trace = memory
    ENDIF
    IF (findstring("2",jcm_log))
     SET trace = memory2
    ENDIF
    IF (findstring("3",jcm_log))
     SET trace = memory3
    ENDIF
    IF (findstring("4",jcm_log))
     SET trace = memory4
    ENDIF
    IF (findstring("5",jcm_log))
     SET trace = memory5
    ENDIF
    IF (findstring("6",jcm_log))
     SET trace = memory6
    ENDIF
    IF (findstring("7",jcm_log))
     SET trace = memory7
    ENDIF
    IF (findstring("B",jcm_log))
     SET trace = rdbdebug
    ENDIF
    IF (findstring("D",jcm_log))
     SET trace = echorecdebug
    ENDIF
    IF (findstring("E",jcm_log))
     SET trace = callecho
    ENDIF
    IF (findstring("I",jcm_log))
     SET trace = echoinput
    ENDIF
    IF (findstring("K",jcm_log))
     SET trace = memchk
    ENDIF
    IF (findstring("M",jcm_log))
     SET trace = memcost
    ENDIF
    IF (findstring("O",jcm_log))
     SET log_redirect = 0
    ENDIF
    IF (findstring("P",jcm_log))
     SET trace = echoprog
    ENDIF
    IF (findstring("R",jcm_log))
     SET trace = echorecord
    ENDIF
    IF (findstring("S",jcm_log))
     SET trace = echoprogsub
    ENDIF
    IF (findstring("U",jcm_log))
     SET trace = showuar
    ENDIF
    IF (findstring("V",jcm_log))
     SET trace = revtest
    ENDIF
    IF (findstring("W",jcm_log))
     SET trace querytimeout 300
    ENDIF
    IF (findstring("X",jcm_log))
     SET trace = checkuar
    ENDIF
    IF (findstring("Y",jcm_log))
     SET trace = skipabort
    ENDIF
    IF (findstring("Z",jcm_log))
     SET trace = echoinput2
    ENDIF
    IF (log_redirect=0)
     CALL trace(2)
    ELSE
     CALL trace(1)
    ENDIF
    SET trace = callecholock
    IF (findstring("L",jcm_log))
     SET trace = lock
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE setup_reqdata(par_nothing)
   RECORD reqdata(
     1 data_status_cd = f8
     1 contributor_system_cd = f8
     1 active_status_cd = f8
     1 inactive_status_cd = f8
     1 bus = c50
     1 domain_id = i2
     1 domain = c50
     1 environment = c50
     1 loglevel = i4
     1 combined_cd = f8
     1 combinedhist_cd = f8
     1 deleted_cd = f8
     1 reviewed_cd = f8
     1 suspended_cd = f8
     1 recstd_unknown_cd = f8
     1 male_cd = f8
     1 female_cd = f8
     1 unknown_sex_cd = f8
     1 auth_active_cd = f8
     1 auth_altered_cd = f8
     1 auth_anticipated_cd = f8
     1 auth_auth_cd = f8
     1 auth_cancel_cd = f8
     1 auth_inerror_cd = f8
     1 auth_inlab_cd = f8
     1 auth_inprogress_cd = f8
     1 auth_modified_cd = f8
     1 auth_notdone_cd = f8
     1 auth_superseded_cd = f8
     1 auth_unauth_cd = f8
     1 auth_unknown_cd = f8
   ) WITH persist
   RECORD reqinfo(
     1 reqinfo
       2 updt_app = i4
       2 updt_task = i4
       2 updt_req = i4
       2 updt_id = f8
       2 updt_applctx = i4
       2 position_cd = f8
       2 commit_ind = i2
       2 perform_cnt = i4
       2 client_node_name = c100
       2 domain_network_id = f8
   ) WITH persist
   RECORD crmreqinfo(
     1 proxy_id = f8
     1 proxy_position_cd = f8
     1 proxy_organization_id = f8
     1 user_id = f8
     1 user_position_cd = f8
     1 user_organization_id = f8
     1 user_role_profile = c256
     1 proxy_role_profile = c256
   ) WITH persist
   SET fetch_reqdata_codes = 2
   IF (fetch_reqdata_codes=1)
    SET reqdata->auth_auth_cd = uar_get_code_by("MEANING",8,"AUTH")
    SET reqdata->data_status_cd = reqdata->auth_auth_cd
    SET reqdata->auth_active_cd = uar_get_code_by("MEANING",8,"ACTIVE")
    SET reqdata->auth_altered_cd = uar_get_code_by("MEANING",8,"ALTERED")
    SET reqdata->auth_anticipated_cd = uar_get_code_by("MEANING",8,"ANTICIPATED")
    SET reqdata->auth_cancel_cd = uar_get_code_by("MEANING",8,"CANCELLED")
    SET reqdata->auth_inerror_cd = uar_get_code_by("MEANING",8,"IN ERROR")
    SET reqdata->auth_inlab_cd = uar_get_code_by("MEANING",8,"IN LAB")
    SET reqdata->auth_inprogress_cd = uar_get_code_by("MEANING",8,"IN PROGRESS")
    SET reqdata->auth_modified_cd = uar_get_code_by("MEANING",8,"MODIFIED")
    SET reqdata->auth_notdone_cd = uar_get_code_by("MEANING",8,"NOT DONE")
    SET reqdata->auth_superseded_cd = uar_get_code_by("MEANING",8,"SUPERSEDED")
    SET reqdata->auth_unauth_cd = uar_get_code_by("MEANING",8,"UNAUTH")
    SET reqdata->auth_unknown_cd = uar_get_code_by("MEANING",8,"UNKNOWN")
    SET reqdata->active_status_cd = uar_get_code_by("MEANING",48,"ACTIVE")
    SET reqdata->inactive_status_cd = uar_get_code_by("MEANING",48,"INACTIVE")
    SET reqdata->combined_cd = uar_get_code_by("MEANING",48,"COMBINED")
    SET reqdata->combinedhist_cd = uar_get_code_by("MEANING",48,"COMBINEHIST")
    SET reqdata->deleted_cd = uar_get_code_by("MEANING",48,"DELETED")
    SET reqdata->reviewed_cd = uar_get_code_by("MEANING",48,"REVIEW")
    SET reqdata->suspended_cd = uar_get_code_by("MEANING",48,"SUSPENDED")
    SET reqdata->recstd_unknown_cd = uar_get_code_by("MEANING",48,"UNKNOWN")
    SET reqdata->male_cd = uar_get_code_by("MEANING",57,"MALE")
    SET reqdata->female_cd = uar_get_code_by("MEANING",57,"FEMALE")
    SET reqdata->unknown_sex_cd = uar_get_code_by("MEANING",57,"UNKNOWN")
    SET reqdata->contributor_system_cd = uar_get_code_by("MEANING",89,"POWERCHART")
   ELSE
    SELECT INTO "nl:"
     c.code_value
     FROM code_value c
     WHERE ((c.code_set IN (8, 48, 57)) OR (c.code_set=89
      AND c.cdf_meaning="POWERCHART"
      AND c.active_ind=1
      AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
      AND c.end_effective_dt_tm > cnvtdatetime(sysdate)))
     DETAIL
      IF (c.code_set=8)
       CASE (c.cdf_meaning)
        OF "AUTH":
         reqdata->data_status_cd = c.code_value,reqdata->auth_auth_cd = c.code_value
        OF "ACTIVE":
         reqdata->auth_active_cd = c.code_value
        OF "ALTERED":
         reqdata->auth_altered_cd = c.code_value
        OF "ANTICIPATED":
         reqdata->auth_anticipated_cd = c.code_value
        OF "CANCELLED":
         reqdata->auth_cancel_cd = c.code_value
        OF "IN ERROR":
         reqdata->auth_inerror_cd = c.code_value
        OF "IN LAB":
         reqdata->auth_inlab_cd = c.code_value
        OF "IN PROGRESS":
         reqdata->auth_inprogress_cd = c.code_value
        OF "MODIFIED":
         reqdata->auth_modified_cd = c.code_value
        OF "NOT DONE":
         reqdata->auth_notdone_cd = c.code_value
        OF "SUPERSEDED":
         reqdata->auth_superseded_cd = c.code_value
        OF "UNAUTH":
         reqdata->auth_unauth_cd = c.code_value
        OF "UNKNOWN":
         reqdata->auth_unknown_cd = c.code_value
       ENDCASE
      ELSEIF (c.code_set=48)
       CASE (c.cdf_meaning)
        OF "ACTIVE":
         reqdata->active_status_cd = c.code_value
        OF "INACTIVE":
         reqdata->inactive_status_cd = c.code_value
        OF "COMBINED":
         reqdata->combined_cd = c.code_value
        OF "COMBINEHIST":
         reqdata->combinedhist_cd = c.code_value
        OF "DELETED":
         reqdata->deleted_cd = c.code_value
        OF "REVIEWED":
         reqdata->reviewed_cd = c.code_value
        OF "SUSPENDED":
         reqdata->suspended_cd = c.code_value
        OF "UNKNOWN":
         reqdata->recstd_unknown_cd = c.code_value
       ENDCASE
      ELSEIF (c.code_set=57)
       CASE (c.cdf_meaning)
        OF "MALE":
         reqdata->male_cd = c.code_value
        OF "FEMALE":
         reqdata->female_cd = c.code_value
        OF "UNKNOWN":
         reqdata->unknown_sex_cd = c.code_value
       ENDCASE
      ELSEIF (c.code_set=89)
       reqdata->contributor_system_cd = c.code_value
      ENDIF
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE setup_dminfo(par_nothing)
   SET ccldminfo->mode = 1
   SET ccldminfo->sec_org_reltn = 0
   SET ccldminfo->sec_confid = 0
   SET ccldminfo->person_org_sec = 0
   SELECT INTO "nl:"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain="SECURITY"
      AND di.info_name IN ("SEC_ORG_RELTN", "SEC_CONFID", "PERSON_ORG_SEC"))
    DETAIL
     IF (di.info_name="SEC_ORG_RELTN"
      AND di.info_number=1)
      ccldminfo->sec_org_reltn = 1
     ELSEIF (di.info_name="SEC_CONFID"
      AND di.info_number=1)
      ccldminfo->sec_confid = 1
     ELSEIF (di.info_name="PERSON_ORG_SEC"
      AND di.info_number=1)
      ccldminfo->person_org_sec = 1
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE setup_cpmcreatefilename(par_nothing)
  RECORD cpm_cfn_info(
    1 file_name = vc
    1 file_name_path = vc
    1 file_name_full_path = vc
    1 file_name_logical = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH persist
  IF (cursys="AIX")
   FREE SET cpm_cfn_path
   DECLARE cpm_cfn_path = vc WITH persist, constant("cer_print/")
   FREE SET cpm_cfn_full_path
   DECLARE cpm_cfn_full_path = vc WITH persist, constant(concat(trim(cnvtlower(logical("cer_print"))),
     "/"))
  ELSE
   CALL echo(build("setup_cpmcreatefilename, cursys= ",cursys," ignored.."))
  ENDIF
 END ;Subroutine
END GO
