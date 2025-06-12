CREATE PROGRAM dcp_readme_1927:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 RECORD list_maint_tabview(
   1 qual[*]
     2 position_cd = f8
     2 prsnl_id = f8
     2 pref = vc
 )
 RECORD permissions(
   1 qual[*]
     2 position_cd = f8
     2 prsnl_id = f8
     2 pref = vc
 )
 RECORD all_provider_group(
   1 qual[*]
     2 position_cd = f8
     2 prsnl_id = f8
     2 pref = vc
 )
 FREE RECORD request
 RECORD request(
   1 person_id = f8
   1 position_cd = f8
   1 ppr_cd = f8
   1 location_cd = f8
   1 active_ind = i2
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 privilege_cd = f8
   1 priv_value_cd = f8
   1 qual[*]
     2 exception_type_cd = f8
     2 exception_entity_name = c40
     2 exception_id = f8
     2 event_set_name = c100
 )
 DECLARE checkpriv(privpersonid=f8,privpositioncd=f8,privpprcd=f8,privlocationcd=f8,privcd=f8) = null
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE itemcnt = i2 WITH noconstant(0)
 DECLARE permcnt = i2 WITH noconstant(0)
 DECLARE provgrpcnt = i2 WITH noconstant(0)
 DECLARE privcd = f8 WITH noconstant(0.0)
 DECLARE personid = f8 WITH noconstant(0.0)
 DECLARE positioncd = f8 WITH noconstant(0.0)
 DECLARE yescd = f8 WITH noconstant(0.0)
 DECLARE nocd = f8 WITH noconstant(0.0)
 DECLARE includecd = f8 WITH noconstant(0.0)
 DECLARE exceptioncd = f8 WITH noconstant(0.0)
 DECLARE x = i4 WITH public, noconstant(0)
 DECLARE i = i4 WITH public, noconstant(0)
 DECLARE j = i4 WITH public, noconstant(0)
 DECLARE value = vc WITH public, noconstant(fillstring(100," "))
 DECLARE exceptions_cnt = i4 WITH public, noconstant(0)
 DECLARE tmp_exception_id = f8 WITH public, noconstant(0.0)
 DECLARE custom_str = vc WITH public, noconstant(fillstring(100," "))
 DECLARE location_str = vc WITH public, noconstant(fillstring(100," "))
 DECLARE vreltn_str = vc WITH public, noconstant(fillstring(100," "))
 DECLARE lreltn_str = vc WITH public, noconstant(fillstring(100," "))
 DECLARE provgrp_str = vc WITH public, noconstant(fillstring(100," "))
 DECLARE service_str = vc WITH public, noconstant(fillstring(100," "))
 DECLARE careteam_str = vc WITH public, noconstant(fillstring(100," "))
 DECLARE locgrp_str = vc WITH public, noconstant(fillstring(100," "))
 DECLARE loc_cd = f8 WITH noconstant(0.0)
 DECLARE vreltn_cd = f8 WITH noconstant(0.0)
 DECLARE lreltn_cd = f8 WITH noconstant(0.0)
 DECLARE cust_cd = f8 WITH noconstant(0.0)
 DECLARE grp_cd = f8 WITH noconstant(0.0)
 DECLARE med_serv_cd = f8 WITH noconstant(0.0)
 DECLARE locgrp_cd = f8 WITH noconstant(0.0)
 DECLARE code_value = f8 WITH public, noconstant(0.0)
 DECLARE cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE code_set = i4 WITH public, noconstant(0)
 DECLARE gprivfound = i2 WITH public, noconstant(0)
 DECLARE ierrorlevel = i2 WITH public, noconstant(0)
 DECLARE stablename = vc WITH public, noconstant(fillstring(100," "))
 DECLARE serrmsg = vc WITH public, noconstant(fillstring(132," "))
 SET cdf_meaning = "YES"
 SET code_set = 6017
 EXECUTE cpm_get_cd_for_cdf
 SET yescd = code_value
 IF (yescd < 1)
  SET ierrorlevel = 1
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "NO"
 SET code_set = 6017
 EXECUTE cpm_get_cd_for_cdf
 SET nocd = code_value
 IF (nocd < 1)
  SET ierrorlevel = 1
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "EXCLUDE"
 SET code_set = 6017
 EXECUTE cpm_get_cd_for_cdf
 SET excludecd = code_value
 IF (excludecd < 1)
  SET ierrorlevel = 1
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "PATIENTLISTS"
 SET code_set = 6015
 EXECUTE cpm_get_cd_for_cdf
 SET exceptioncd = code_value
 IF (exceptioncd < 1)
  SET ierrorlevel = 1
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "LOCATION"
 SET code_set = 27360
 EXECUTE cpm_get_cd_for_cdf
 SET loc_cd = code_value
 IF (loc_cd < 1)
  SET ierrorlevel = 1
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "VRELTN"
 SET code_set = 27360
 EXECUTE cpm_get_cd_for_cdf
 SET vreltn_cd = code_value
 IF (vreltn_cd < 1)
  SET ierrorlevel = 1
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "LRELTN"
 SET code_set = 27360
 EXECUTE cpm_get_cd_for_cdf
 SET lreltn_cd = code_value
 IF (lreltn_cd < 1)
  SET ierrorlevel = 1
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "CUSTOM"
 SET code_set = 27360
 EXECUTE cpm_get_cd_for_cdf
 SET cust_cd = code_value
 IF (cust_cd < 1)
  SET ierrorlevel = 1
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "PROVIDERGRP"
 SET code_set = 27360
 EXECUTE cpm_get_cd_for_cdf
 SET grp_cd = code_value
 IF (grp_cd < 1)
  SET ierrorlevel = 1
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "SERVICE"
 SET code_set = 27360
 EXECUTE cpm_get_cd_for_cdf
 SET med_serv_cd = code_value
 IF (med_serv_cd < 1)
  SET ierrorlevel = 1
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "LOCATIONGRP"
 SET code_set = 27360
 EXECUTE cpm_get_cd_for_cdf
 SET locgrp_cd = code_value
 IF (locgrp_cd < 1)
  SET ierrorlevel = 1
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "PROXYPTLIST"
 SET code_set = 6016
 EXECUTE cpm_get_cd_for_cdf
 SET privcd = code_value
 IF (privcd < 1)
  SET ierrorlevel = 1
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SELECT INTO "nl:"
  FROM name_value_prefs nvp,
   app_prefs ap
  PLAN (nvp
   WHERE nvp.pvc_name="PERMISSIONS"
    AND nvp.parent_entity_name="APP_PREFS")
   JOIN (ap
   WHERE ap.app_prefs_id=nvp.parent_entity_id)
  ORDER BY ap.position_cd, ap.prsnl_id, ap.application_number
  HEAD REPORT
   permcnt = 0
  HEAD ap.position_cd
   row + 0
  HEAD ap.prsnl_id
   permcnt = (permcnt+ 1)
   IF (mod(permcnt,1000)=1)
    stat = alterlist(permissions->qual,(permcnt+ 999))
   ENDIF
   permissions->qual[permcnt].position_cd = ap.position_cd, permissions->qual[permcnt].prsnl_id = ap
   .prsnl_id, permissions->qual[permcnt].pref = nvp.pvc_value
  FOOT  ap.position_cd
   row + 0
  FOOT  ap.prsnl_id
   row + 0
  FOOT REPORT
   stat = alterlist(permissions->qual,permcnt)
  WITH nocounter
 ;end select
 SET ierrcode = 0
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET ierrorlevel = 2
  SET stablename = "NAME_VALUE_PREFS, APP_PREFS (1)"
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO permcnt)
  CALL checkpriv(permissions->qual[x].prsnl_id,permissions->qual[x].position_cd,0.0,0.0,privcd)
  IF (gprivfound=0)
   SET request->position_cd = permissions->qual[x].position_cd
   SET request->person_id = permissions->qual[x].prsnl_id
   SET request->ppr_cd = 0
   SET request->location_cd = 0
   SET request->active_ind = 1
   SET request->beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET request->end_effective_dt_tm = cnvtdatetime("31-Dec-2100")
   SET request->privilege_cd = privcd
   SET reqinfo->updt_applctx = 1927
   IF ((permissions->qual[x].pref="1"))
    SET request->priv_value_cd = yescd
   ELSE
    SET request->priv_value_cd = nocd
   ENDIF
   EXECUTE orm_add_priv
  ENDIF
 ENDFOR
 SET cdf_meaning = "ALLPGPTLIST"
 SET code_set = 6016
 EXECUTE cpm_get_cd_for_cdf
 SET privcd = code_value
 IF (privcd < 1)
  SET ierrorlevel = 1
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SELECT INTO "nl:"
  FROM name_value_prefs nvp,
   app_prefs ap
  PLAN (nvp
   WHERE nvp.pvc_name="ALL_PROVIDER_GROUP"
    AND nvp.parent_entity_name="APP_PREFS")
   JOIN (ap
   WHERE ap.app_prefs_id=nvp.parent_entity_id)
  ORDER BY ap.position_cd, ap.prsnl_id, ap.application_number
  HEAD REPORT
   provgrpcnt = 0
  HEAD ap.position_cd
   row + 0
  HEAD ap.prsnl_id
   provgrpcnt = (provgrpcnt+ 1)
   IF (mod(provgrpcnt,1000)=1)
    stat = alterlist(all_provider_group->qual,(provgrpcnt+ 999))
   ENDIF
   all_provider_group->qual[provgrpcnt].position_cd = ap.position_cd, all_provider_group->qual[
   provgrpcnt].prsnl_id = ap.prsnl_id, all_provider_group->qual[provgrpcnt].pref = nvp.pvc_value
  FOOT  ap.position_cd
   row + 0
  FOOT  ap.prsnl_id
   row + 0
  FOOT REPORT
   stat = alterlist(all_provider_group->qual,provgrpcnt)
  WITH nocounter
 ;end select
 SET ierrcode = 0
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET ierrorlevel = 2
  SET stablename = "NAME_VALUE_PREFS, APP_PREFS (2)"
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO provgrpcnt)
  CALL checkpriv(all_provider_group->qual[x].prsnl_id,all_provider_group->qual[x].position_cd,0.0,0.0,
   privcd)
  IF (gprivfound=0)
   SET request->position_cd = all_provider_group->qual[x].position_cd
   SET request->person_id = all_provider_group->qual[x].prsnl_id
   SET request->ppr_cd = 0
   SET request->location_cd = 0
   SET request->active_ind = 1
   SET request->beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET request->end_effective_dt_tm = cnvtdatetime("31-Dec-2100")
   SET request->privilege_cd = privcd
   SET reqinfo->updt_applctx = 1927
   IF ((permissions->qual[x].pref="1"))
    SET request->priv_value_cd = yescd
   ELSE
    SET request->priv_value_cd = nocd
   ENDIF
   EXECUTE orm_add_priv
  ENDIF
 ENDFOR
 SET cdf_meaning = "BLDPTLIST"
 SET code_set = 6016
 EXECUTE cpm_get_cd_for_cdf
 SET privcd = code_value
 IF (privcd < 1)
  SET ierrorlevel = 1
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SELECT INTO "nl:"
  FROM name_value_prefs nvp,
   app_prefs ap
  PLAN (nvp
   WHERE nvp.pvc_name="LIST_MAINT_TABVIEW"
    AND nvp.parent_entity_name="APP_PREFS")
   JOIN (ap
   WHERE ap.app_prefs_id=nvp.parent_entity_id)
  ORDER BY ap.position_cd, ap.prsnl_id, ap.application_number
  HEAD REPORT
   itemcnt = 0
  HEAD ap.position_cd
   row + 0
  HEAD ap.prsnl_id
   itemcnt = (itemcnt+ 1)
   IF (mod(itemcnt,1000)=1)
    stat = alterlist(list_maint_tabview->qual,(itemcnt+ 999))
   ENDIF
   list_maint_tabview->qual[itemcnt].position_cd = ap.position_cd, list_maint_tabview->qual[itemcnt].
   prsnl_id = ap.prsnl_id, list_maint_tabview->qual[itemcnt].pref = nvp.pvc_value
  FOOT  ap.position_cd
   row + 0
  FOOT  ap.prsnl_id
   row + 0
  FOOT REPORT
   stat = alterlist(list_maint_tabview->qual,itemcnt)
  WITH nocounter
 ;end select
 SET ierrcode = 0
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET ierrorlevel = 2
  SET stablename = "NAME_VALUE_PREFS, APP_PREFS (3)"
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO itemcnt)
  CALL checkpriv(list_maint_tabview->qual[x].prsnl_id,list_maint_tabview->qual[x].position_cd,0.0,0.0,
   privcd)
  IF (gprivfound=0)
   SET exceptions_cnt = 0
   SET value = list_maint_tabview->qual[x].pref
   SET i = findstring(";",value,1)
   SET custom_str = substring(1,(i - 1),value)
   IF (custom_str="0")
    SET exceptions_cnt = (exceptions_cnt+ 1)
    SET stat = alterlist(request->qual,exceptions_cnt)
    SET request->qual[exceptions_cnt].exception_type_cd = exceptioncd
    SET request->qual[exceptions_cnt].exception_entity_name = "CODE_VALUE"
    SET request->qual[exceptions_cnt].exception_id = cust_cd
    SET request->qual[exceptions_cnt].event_set_name = ""
   ENDIF
   SET j = findstring(";",value,(i+ 1))
   SET location_str = substring((i+ 1),((j - i) - 1),value)
   IF (location_str="0")
    SET exceptions_cnt = (exceptions_cnt+ 1)
    SET stat = alterlist(request->qual,exceptions_cnt)
    SET request->qual[exceptions_cnt].exception_type_cd = exceptioncd
    SET request->qual[exceptions_cnt].exception_entity_name = "CODE_VALUE"
    SET request->qual[exceptions_cnt].exception_id = loc_cd
    SET request->qual[exceptions_cnt].event_set_name = ""
   ENDIF
   SET i = findstring(";",value,(j+ 1))
   SET vreltn_str = substring((j+ 1),((i - j) - 1),value)
   IF (vreltn_str="0")
    SET exceptions_cnt = (exceptions_cnt+ 1)
    SET stat = alterlist(request->qual,exceptions_cnt)
    SET request->qual[exceptions_cnt].exception_type_cd = exceptioncd
    SET request->qual[exceptions_cnt].exception_entity_name = "CODE_VALUE"
    SET request->qual[exceptions_cnt].exception_id = vreltn_cd
    SET request->qual[exceptions_cnt].event_set_name = ""
   ENDIF
   SET j = findstring(";",value,(i+ 1))
   SET lreltn_str = substring((i+ 1),((j - i) - 1),value)
   IF (lreltn_str="0")
    SET exceptions_cnt = (exceptions_cnt+ 1)
    SET stat = alterlist(request->qual,exceptions_cnt)
    SET request->qual[exceptions_cnt].exception_type_cd = exceptioncd
    SET request->qual[exceptions_cnt].exception_entity_name = "CODE_VALUE"
    SET request->qual[exceptions_cnt].exception_id = lreltn_cd
    SET request->qual[exceptions_cnt].event_set_name = ""
   ENDIF
   SET i = findstring(";",value,(j+ 1))
   SET provgrp_str = substring((j+ 1),((i - j) - 1),value)
   IF (provgrp_str="0")
    SET exceptions_cnt = (exceptions_cnt+ 1)
    SET stat = alterlist(request->qual,exceptions_cnt)
    SET request->qual[exceptions_cnt].exception_type_cd = exceptioncd
    SET request->qual[exceptions_cnt].exception_entity_name = "CODE_VALUE"
    SET request->qual[exceptions_cnt].exception_id = grp_cd
    SET request->qual[exceptions_cnt].event_set_name = ""
   ENDIF
   SET j = findstring(";",value,(i+ 1))
   SET service_str = substring((i+ 1),((j - i) - 1),value)
   IF (service_str="0")
    SET exceptions_cnt = (exceptions_cnt+ 1)
    SET stat = alterlist(request->qual,exceptions_cnt)
    SET request->qual[exceptions_cnt].exception_type_cd = exceptioncd
    SET request->qual[exceptions_cnt].exception_entity_name = "CODE_VALUE"
    SET request->qual[exceptions_cnt].exception_id = med_serv_cd
    SET request->qual[exceptions_cnt].event_set_name = ""
   ENDIF
   SET i = findstring(";",value,(j+ 1))
   SET careteam_str = substring((j+ 1),((i - j) - 1),value)
   IF (findstring(";",value,(i+ 1))=0)
    SET j = size(value)
    SET locgrp_str = substring((i+ 1),(j - i),value)
   ELSE
    SET j = findstring(";",value,(i+ 1))
    SET locgrp_str = substring((i+ 1),((j - i) - 1),value)
   ENDIF
   IF (locgrp_str="0")
    SET exceptions_cnt = (exceptions_cnt+ 1)
    SET stat = alterlist(request->qual,exceptions_cnt)
    SET request->qual[exceptions_cnt].exception_type_cd = exceptioncd
    SET request->qual[exceptions_cnt].exception_entity_name = "CODE_VALUE"
    SET request->qual[exceptions_cnt].exception_id = locgrp_cd
    SET request->qual[exceptions_cnt].event_set_name = ""
   ENDIF
   SET request->position_cd = list_maint_tabview->qual[x].position_cd
   SET request->person_id = list_maint_tabview->qual[x].prsnl_id
   SET request->ppr_cd = 0
   SET request->location_cd = 0
   SET request->active_ind = 1
   SET request->beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET request->end_effective_dt_tm = cnvtdatetime("31-Dec-2100")
   SET request->privilege_cd = privcd
   SET reqinfo->updt_applctx = 1927
   IF (exceptions_cnt=0)
    SET request->priv_value_cd = yescd
   ELSEIF (exceptions_cnt=7)
    SET request->priv_value_cd = nocd
   ELSE
    SET request->priv_value_cd = excludecd
   ENDIF
   EXECUTE orm_add_priv
   SET exceptions_cnt = 1
   SET stat = alterlist(request->qual,exceptions_cnt)
   SET request->qual[exceptions_cnt].exception_type_cd = 0
  ENDIF
 ENDFOR
 SUBROUTINE checkpriv(privpersonid,privpositioncd,privpprcd,privlocationcd,privcd)
   SET gprivfound = 0
   SET ierrcode = error(serrmsg,1)
   SELECT INTO "nl:"
    FROM priv_loc_reltn plr,
     privilege p
    PLAN (plr
     WHERE plr.person_id=privpersonid
      AND plr.position_cd=privpositioncd
      AND plr.ppr_cd=privpprcd
      AND plr.location_cd=privlocationcd)
     JOIN (p
     WHERE p.priv_loc_reltn_id=plr.priv_loc_reltn_id
      AND p.privilege_cd=privcd)
    DETAIL
     gprivfound = 1
    WITH nocounter
   ;end select
   SET ierrcode = 0
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET ierrorlevel = 2
    SET stablename = "PRIV_LOC_RELTN, PRIVILEGE"
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
 FREE RECORD list_maint_tabview
 FREE RECORD permissions
 FREE RECORD all_provider_group
 IF (ierrorlevel > 0)
  SET readme_data->status = "F"
  CASE (ierrorlevel)
   OF 1:
    SET readme_data->message = build("Cdf Meaning: ",trim(cdf_meaning)," not found in code set: ",
     trim(cnvtstring(code_set)))
   OF 2:
    SET readme_data->message = build("Select error on: ",trim(stablename))
  ENDCASE
 ELSE
  SET readme_data->status = "S"
 ENDIF
 EXECUTE dm_readme_status
 SET script_version = "*** MOD 002 JF7198 05/29/02"
END GO
