CREATE PROGRAM dcp_readme_1725:dba
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
 CALL echo("Starting dcp_readme_1725")
 RECORD patientlist(
   1 qual[*]
     2 prsnl_id = f8
     2 nvp_id = f8
     2 info = vc
     2 name = vc
     2 type_cd = f8
     2 pe_name = vc
     2 pe_id = f8
     2 pat_list_id = f8
     2 owner_id = f8
     2 cust_list_id = f8
 )
 RECORD customentry(
   1 qual[*]
     2 encntr_id = f8
     2 person_id = f8
 )
 RECORD proxylist(
   1 qual[*]
     2 proxy_person_id = f8
     2 beg_dt_tm = dq8
     2 end_dt_tm = dq8
 )
 RECORD prioritization(
   1 qual[*]
     2 person_id = f8
     2 priority = i4
 )
 SET modify = predeclare
 DECLARE x = i4 WITH public, noconstant(0)
 DECLARE y = i4 WITH public, noconstant(0)
 DECLARE strvalue = vc WITH public, noconstant(fillstring(100," "))
 DECLARE i = i4 WITH public, noconstant(0)
 DECLARE j = i4 WITH public, noconstant(0)
 DECLARE k = i4 WITH public, noconstant(0)
 DECLARE l = i4 WITH public, noconstant(0)
 DECLARE listcnt = i4 WITH public, noconstant(0)
 DECLARE ce_cnt = i4 WITH public, noconstant(0)
 DECLARE check_flg = i4 WITH public, noconstant(0)
 DECLARE tmpcnt = i4 WITH public, noconstant(0)
 DECLARE tmp_patient_list_id = f8 WITH public, noconstant(0.0)
 DECLARE pl_desc = vc WITH public, noconstant(fillstring(100," "))
 DECLARE dummyvar = i2 WITH public, constant(0)
 DECLARE listownerflg = i4 WITH public, noconstant(0)
 DECLARE ce_flg = i4 WITH public, noconstant(0)
 DECLARE proxylist_cnt = i4 WITH public, noconstant(0)
 DECLARE proxy_cnt = i4 WITH public, noconstant(0)
 DECLARE p_cnt = i4 WITH public, noconstant(0)
 DECLARE p_count = i4 WITH public, noconstant(0)
 DECLARE found = i4 WITH public, noconstant(0)
 DECLARE list_type = vc WITH public, noconstant(fillstring(50," "))
 DECLARE priority_where = vc WITH public, noconstant(fillstring(1000," "))
 DECLARE nvp_value = vc WITH public, noconstant(fillstring(50," "))
 DECLARE skip_nv_prefs = i4 WITH public, noconstant(0)
 DECLARE insertfailed = i4 WITH public, noconstant(0)
 DECLARE scriptfailed = i4 WITH public, noconstant(0)
 DECLARE priortizationpass = i4 WITH public, noconstant(1)
 SET modify = nopredeclare
 SET beg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET end_dt_tm = cnvtdatetime(curdate,curtime3)
 SET modify = predeclare
 DECLARE arg_name = vc WITH public, noconstant(fillstring(50," "))
 DECLARE arg_value = vc WITH public, noconstant(fillstring(50," "))
 DECLARE pe_name = vc WITH public, noconstant(fillstring(100," "))
 DECLARE pe_id = f8 WITH public, noconstant(0.0)
 DECLARE plce_encntr_id = f8 WITH public, noconstant(0.0)
 DECLARE plce_person_id = f8 WITH public, noconstant(0.0)
 DECLARE type = vc WITH public, noconstant(fillstring(100," "))
 DECLARE filter_str = vc WITH public, noconstant(fillstring(100," "))
 DECLARE facility_cd = vc WITH public, noconstant(fillstring(100," "))
 DECLARE building_cd = vc WITH public, noconstant(fillstring(100," "))
 DECLARE unit_cd = vc WITH public, noconstant(fillstring(100," "))
 DECLARE room_cd = vc WITH public, noconstant(fillstring(100," "))
 DECLARE bed_cd = vc WITH public, noconstant(fillstring(100," "))
 DECLARE list_owner_id = vc WITH public, noconstant(fillstring(100," "))
 DECLARE reltn_cnt = vc WITH public, noconstant(fillstring(100," "))
 DECLARE reltn_cd = vc WITH public, noconstant(fillstring(100," "))
 DECLARE list_id = vc WITH public, noconstant(fillstring(100," "))
 DECLARE med_service_cd = vc WITH public, noconstant(fillstring(100," "))
 DECLARE loc_grp_cd = vc WITH public, noconstant(fillstring(100," "))
 DECLARE patient_status = vc WITH public, noconstant(fillstring(100," "))
 DECLARE time_units = vc WITH public, noconstant(fillstring(100," "))
 DECLARE time_quantity = vc WITH public, noconstant(fillstring(100," "))
 DECLARE patient_type_count = vc WITH public, noconstant(fillstring(100," "))
 DECLARE patient_type = vc WITH public, noconstant(fillstring(100," "))
 DECLARE new_results = vc WITH public, noconstant(fillstring(100," "))
 DECLARE status_minutes = vc WITH public, noconstant(fillstring(50," "))
 DECLARE stat = i4 WITH public, noconstant(0)
 DECLARE code_value = f8 WITH public, noconstant(0.0)
 DECLARE cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE code_set = i4 WITH public, noconstant(0)
 DECLARE location(pl_info=vc,subcnt=i4) = null
 DECLARE visitppr(pl_info=vc,subcnt=i4) = null
 DECLARE lifeppr(pl_info=vc,subcnt=i4) = null
 DECLARE custom(pl_info=vc,subcnt=i4) = null
 DECLARE group(pl_info=vc,subcnt=i4) = null
 DECLARE medservice(pl_info=vc,subcnt=i4) = null
 DECLARE careteam(pl_info=vc,subcnt=i4) = null
 DECLARE locgroup(pl_info=vc,subcnt=i4) = null
 DECLARE inserttonamevalueprefs(x=i4) = null
 DECLARE inserttopatientlist(subcnt=i4) = null
 DECLARE getlistownerid(strvalue=vc) = null
 DECLARE filters(filter_str=vc) = null
 DECLARE teampatients(x=i4) = null
 DECLARE custompatients(x=i4) = null
 SET modify = nopredeclare
 SET code_set = 27360
 SET cdf_meaning = "LOCATION"
 EXECUTE cpm_get_cd_for_cdf
 SET loc_cd = code_value
 SET code_set = 27360
 SET cdf_meaning = "VRELTN "
 EXECUTE cpm_get_cd_for_cdf
 SET vreltn_cd = code_value
 SET code_set = 27360
 SET cdf_meaning = "LRELTN"
 EXECUTE cpm_get_cd_for_cdf
 SET lreltn_cd = code_value
 SET code_set = 27360
 SET cdf_meaning = "CUSTOM"
 EXECUTE cpm_get_cd_for_cdf
 SET cust_cd = code_value
 SET code_set = 27360
 SET cdf_meaning = "PROVIDERGRP"
 EXECUTE cpm_get_cd_for_cdf
 SET grp_cd = code_value
 SET code_set = 27360
 SET cdf_meaning = "SERVICE"
 EXECUTE cpm_get_cd_for_cdf
 SET med_serv_cd = code_value
 SET code_set = 27360
 SET cdf_meaning = "LOCATIONGRP"
 EXECUTE cpm_get_cd_for_cdf
 SET locgrp_cd = code_value
 SET code_set = 27380
 SET cdf_meaning = "READ"
 EXECUTE cpm_get_cd_for_cdf
 SET lst_access_cd = code_value
 SET code_set = 6022
 SET cdf_meaning = "PTVRELTNLST"
 EXECUTE cpm_get_cd_for_cdf
 SET visit_type_cd = code_value
 SET code_set = 6022
 SET cdf_meaning = "PTGROUPLST"
 EXECUTE cpm_get_cd_for_cdf
 SET group_type_cd = code_value
 SET code_set = 27360
 SET cdf_meaning = "CARETEAM"
 EXECUTE cpm_get_cd_for_cdf
 SET teamlist_cd = code_value
 SET code_set = 19189
 SET cdf_meaning = "CARETEAM"
 EXECUTE cpm_get_cd_for_cdf
 SET team_cd = code_value
 SET modify = predeclare
 SELECT INTO "nl:"
  FROM user_tables ut
  WHERE ut.table_name IN ("DCP_PATIENT_LIST", "DCP_PL_RELTN", "DCP_PL_ARGUMENT",
  "DCP_PL_CUSTOM_ENTRY", "DCP_PL_ENCNTR_FILTER",
  "DCP_PL_PRIORITIZATION")
  WITH nocounter
 ;end select
 IF (curqual < 6)
  SET readme_data->message = "New Patient List Tables Not Present."
  SET scriptfailed = 1
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM user_tables ut
  WHERE ut.table_name IN ("DCP_PL", "DCP_PL_PRIORITY")
  WITH nocounter
 ;end select
 IF (curqual < 2)
  SET priortizationpass = 0
 ENDIF
 SELECT INTO "nl:"
  FROM name_value_prefs nvp,
   detail_prefs dp,
   view_prefs vp,
   name_value_prefs nvp2
  PLAN (nvp
   WHERE ((nvp.pvc_name="TABINFO") OR (nvp.pvc_name="PatientListId"
    AND nvp.parent_entity_id > 0)) )
   JOIN (dp
   WHERE dp.detail_prefs_id=nvp.parent_entity_id
    AND dp.view_name="PATLISTVIEW")
   JOIN (vp
   WHERE vp.prsnl_id=dp.prsnl_id
    AND vp.view_name=dp.view_name
    AND vp.view_seq=dp.view_seq
    AND vp.application_number=dp.application_number)
   JOIN (nvp2
   WHERE nvp2.parent_entity_id=vp.view_prefs_id
    AND nvp2.pvc_name="VIEW_CAPTION")
  ORDER BY nvp.parent_entity_id, nvp.pvc_name
  HEAD nvp.parent_entity_id
   listownerflg = 0
  HEAD nvp.pvc_name
   IF (nvp.pvc_name="PatientListId")
    listownerflg = 1
   ENDIF
  DETAIL
   IF (nvp.pvc_name="TABINFO"
    AND listownerflg=0)
    listcnt = (listcnt+ 1), stat = alterlist(patientlist->qual,listcnt), patientlist->qual[listcnt].
    prsnl_id = dp.prsnl_id,
    patientlist->qual[listcnt].nvp_id = nvp.name_value_prefs_id, patientlist->qual[listcnt].info =
    nvp.pvc_value, patientlist->qual[listcnt].name = nvp2.pvc_value,
    patientlist->qual[listcnt].pe_name = nvp.parent_entity_name, patientlist->qual[listcnt].pe_id =
    nvp.parent_entity_id
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("testing dcp_readme_1725")
 IF (listcnt=0)
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO listcnt)
   SELECT INTO "nl:"
    nextseqnum = seq(dcp_patient_list_seq,nextval)
    FROM dual
    DETAIL
     tmp_patient_list_id = cnvtint(nextseqnum)
    WITH nocounter
   ;end select
   SET insertfailed = 0
   IF ((patientlist->qual[x].info="LOCATION*"))
    CALL location(patientlist->qual[x].info,x)
   ELSEIF ((patientlist->qual[x].info="VISITPPR*"))
    CALL visitppr(patientlist->qual[x].info,x)
   ELSEIF ((patientlist->qual[x].info="LIFEPPR*"))
    CALL lifeppr(patientlist->qual[x].info,x)
   ELSEIF ((patientlist->qual[x].info="CUSTOM*"))
    CALL custom(patientlist->qual[x].info,x)
   ELSEIF ((patientlist->qual[x].info="GROUP*"))
    CALL group(patientlist->qual[x].info,x)
   ELSEIF ((patientlist->qual[x].info="MEDSERVICE*"))
    CALL medservice(patientlist->qual[x].info,x)
   ELSEIF ((patientlist->qual[x].info="CARETEAM*"))
    CALL careteam(patientlist->qual[x].info,x)
   ELSEIF ((patientlist->qual[x].info="LOCGROUP*"))
    CALL locgroup(patientlist->qual[x].info,x)
   ENDIF
   IF (insertfailed=1)
    SET readme_data->status = "F"
    SET scriptfailed = 1
    ROLLBACK
   ELSE
    COMMIT
   ENDIF
 ENDFOR
 SET insertfailed = 0
 FOR (x = 1 TO listcnt)
   IF ((patientlist->qual[x].pat_list_id=0)
    AND (patientlist->qual[x].owner_id > 0))
    CALL inserttonamevalueprefs(x)
   ENDIF
 ENDFOR
 IF (insertfailed)
  SET readme_data->status = "F"
  SET scriptfailed = 1
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
 SUBROUTINE location(pl_info,subcnt)
   SET patientlist->qual[subcnt].type_cd = loc_cd
   SET strvalue = pl_info
   SET pl_desc = concat("LOCATION: Location List for ",patientlist->qual[subcnt].name)
   SET i = findstring(";",strvalue,1)
   SET type = substring(1,(i - 1),strvalue)
   SET j = findstring(";",strvalue,(i+ 1))
   SET filter_str = substring((i+ 1),((j - i) - 1),strvalue)
   SET i = findstring(";",strvalue,(j+ 1))
   SET facility_cd = substring((j+ 1),((i - j) - 1),strvalue)
   SET j = findstring(";",strvalue,(i+ 1))
   SET building_cd = substring((i+ 1),((j - i) - 1),strvalue)
   SET i = findstring(";",strvalue,(j+ 1))
   SET unit_cd = substring((j+ 1),((i - j) - 1),strvalue)
   SET j = findstring(";",strvalue,(i+ 1))
   SET room_cd = substring((i+ 1),((j - i) - 1),strvalue)
   IF (findstring(";",strvalue,(j+ 1))=0)
    SET i = size(strvalue)
    SET bed_cd = substring((j+ 1),(i - j),strvalue)
    SET list_owner_id = " "
   ELSE
    SET i = findstring(";",strvalue,(j+ 1))
    SET bed_cd = substring((j+ 1),((i - j) - 1),strvalue)
    SET j = size(strvalue)
    SET list_owner_id = substring((i+ 1),(j - i),strvalue)
   ENDIF
   IF (((list_owner_id=" ") OR (cnvtint(list_owner_id)=0)) )
    CALL inserttopatientlist(subcnt)
    CALL filters(filter_str)
    SET arg_name = "location"
    SET arg_value = " "
    SET pe_name = "CODE_VALUE"
    IF (cnvtint(bed_cd) > 0)
     SET pe_id = cnvtint(bed_cd)
    ELSEIF (cnvtint(room_cd) > 0)
     SET pe_id = cnvtint(room_cd)
    ELSEIF (cnvtint(unit_cd) > 0)
     SET pe_id = cnvtint(unit_cd)
    ELSEIF (cnvtint(building_cd) > 0)
     SET pe_id = cnvtint(building_cd)
    ELSEIF (cnvtint(facility_cd) > 0)
     SET pe_id = cnvtint(facility_cd)
    ENDIF
    CALL inserttoargument(dummyvar)
    SET arg_name = "lag_minutes"
    SET arg_value = "120"
    SET pe_name = " "
    SET pe_id = 0
    CALL inserttoargument(dummyvar)
   ELSE
    SET patientlist->qual[subcnt].pat_list_id = 0
    SET patientlist->qual[subcnt].owner_id = cnvtint(list_owner_id)
   ENDIF
 END ;Subroutine
 SUBROUTINE visitppr(pl_info,subcnt)
   SET patientlist->qual[subcnt].type_cd = vreltn_cd
   SET strvalue = pl_info
   SET pl_desc = concat("VISITPPR: Visit Relationship List for ",patientlist->qual[subcnt].name)
   CALL getlistownerid(strvalue)
   IF (((list_owner_id=" ") OR (cnvtint(list_owner_id)=0)) )
    SET i = findstring(";",strvalue,1)
    SET type = substring(1,(i - 1),strvalue)
    SET j = findstring(";",strvalue,(i+ 1))
    SET filter_str = substring((i+ 1),((j - i) - 1),strvalue)
    CALL inserttopatientlist(subcnt)
    CALL filters(filter_str)
    IF (findstring(";",strvalue,(j+ 1))=0)
     SET i = size(strvalue)
     SET reltn_cnt = substring((j+ 1),(i - j),strvalue)
    ELSE
     SET i = findstring(";",strvalue,(j+ 1))
     SET reltn_cnt = substring((j+ 1),((i - j) - 1),strvalue)
    ENDIF
    SET arg_name = "prsnl_id"
    SET arg_value = " "
    SET pe_name = "PERSON"
    SET pe_id = patientlist->qual[subcnt].prsnl_id
    CALL inserttoargument(dummyvar)
    SET tmpcnt = cnvtint(reltn_cnt)
    IF (tmpcnt=0)
     IF (findstring(";",strvalue,(i+ 1))=0)
      SET list_owner_id = " "
     ELSE
      SET j = size(strvalue)
      SET list_owner_id = substring((i+ 1),(j - i),strvalue)
     ENDIF
    ELSEIF ((tmpcnt=- (1)))
     IF (findstring(";",strvalue,(i+ 1))=0)
      SET reltn_cd = " "
      SET list_owner_id = " "
     ELSE
      SET j = size(strvalue)
      SET reltn_cd = " "
      SET list_owner_id = substring((i+ 1),(j - i),strvalue)
     ENDIF
    ELSE
     SET check_flg = 1
     FOR (y = 1 TO tmpcnt)
       IF (check_flg=1)
        IF (findstring(";",strvalue,(i+ 1))=0)
         SET j = size(strvalue)
         SET reltn_cd = substring((i+ 1),(j - i),strvalue)
         SET list_owner_id = " "
         SET arg_name = "visit_reltn_cd"
         SET arg_value = " "
         SET pe_name = "CODE_VALUE"
         SET pe_id = cnvtint(reltn_cd)
         CALL inserttoargument(dummyvar)
        ELSE
         SET j = findstring(";",strvalue,(i+ 1))
         SET reltn_cd = substring((i+ 1),((j - i) - 1),strvalue)
         IF (y=tmpcnt)
          SET j = size(strvalue)
          SET list_owner_id = substring((i+ 1),(j - i),strvalue)
         ENDIF
         SET arg_name = "visit_reltn_cd"
         SET arg_value = " "
         SET pe_name = "CODE_VALUE"
         SET pe_id = cnvtint(reltn_cd)
         CALL inserttoargument(dummyvar)
        ENDIF
        SET check_flg = 0
       ELSE
        IF (findstring(";",strvalue,(j+ 1))=0)
         SET i = size(strvalue)
         SET reltn_cd = substring((j+ 1),(i - j),strvalue)
         SET list_owner_id = " "
         SET arg_name = "visit_reltn_cd"
         SET arg_value = " "
         SET pe_name = "CODE_VALUE"
         SET pe_id = cnvtint(reltn_cd)
         CALL inserttoargument(dummyvar)
        ELSE
         SET i = findstring(";",strvalue,(j+ 1))
         SET reltn_cd = substring((j+ 1),((i - j) - 1),strvalue)
         IF (y=tmpcnt)
          SET i = size(strvalue)
          SET list_owner_id = substring((j+ 1),(i - j),strvalue)
         ENDIF
         SET arg_name = "visit_reltn_cd"
         SET arg_value = " "
         SET pe_name = "CODE_VALUE"
         SET pe_id = cnvtint(reltn_cd)
         CALL inserttoargument(dummyvar)
        ENDIF
        SET check_flg = 1
       ENDIF
     ENDFOR
    ENDIF
    IF (priortizationpass)
     CALL inserttoprioritization(visit_type_cd,1)
    ENDIF
   ELSE
    SET patientlist->qual[subcnt].pat_list_id = 0
    SET patientlist->qual[subcnt].owner_id = cnvtint(list_owner_id)
   ENDIF
 END ;Subroutine
 SUBROUTINE lifeppr(pl_info,subcnt)
   SET patientlist->qual[subcnt].type_cd = lreltn_cd
   SET strvalue = pl_info
   SET pl_desc = concat("LIFEPPR: Lifetime Relation List for ",patientlist->qual[subcnt].name)
   CALL getlistownerid(strvalue)
   IF (((list_owner_id=" ") OR (cnvtint(list_owner_id)=0)) )
    SET i = findstring(";",strvalue,1)
    SET type = substring(1,(i - 1),strvalue)
    SET j = findstring(";",strvalue,(i+ 1))
    SET filter_str = substring((i+ 1),((j - i) - 1),strvalue)
    CALL inserttopatientlist(subcnt)
    CALL filters(filter_str)
    IF (findstring(";",strvalue,(j+ 1))=0)
     SET i = size(strvalue)
     SET reltn_cnt = substring((j+ 1),(i - j),strvalue)
    ELSE
     SET i = findstring(";",strvalue,(j+ 1))
     SET reltn_cnt = substring((j+ 1),((i - j) - 1),strvalue)
    ENDIF
    SET arg_name = "prsnl_id"
    SET arg_value = " "
    SET pe_name = "PERSON"
    SET pe_id = patientlist->qual[subcnt].prsnl_id
    CALL inserttoargument(dummyvar)
    SET tmpcnt = cnvtint(reltn_cnt)
    IF (tmpcnt=0)
     IF (findstring(";",strvalue,(i+ 1))=0)
      SET list_owner_id = " "
     ELSE
      SET j = size(strvalue)
      SET list_owner_id = substring((i+ 1),(j - i),strvalue)
     ENDIF
    ELSEIF ((tmpcnt=- (1)))
     IF (findstring(";",strvalue,(i+ 1))=0)
      SET reltn_cd = " "
      SET list_owner_id = " "
     ELSE
      SET j = size(strvalue)
      SET reltn_cd = " "
      SET list_owner_id = substring((i+ 1),(j - i),strvalue)
     ENDIF
    ELSE
     SET check_flg = 1
     FOR (y = 1 TO tmpcnt)
       IF (check_flg=1)
        IF (findstring(";",strvalue,(i+ 1))=0)
         SET j = size(strvalue)
         SET reltn_cd = substring((i+ 1),(j - i),strvalue)
         SET list_owner_id = " "
         SET arg_name = "lifetime_reltn_cd"
         SET arg_value = " "
         SET pe_name = "CODE_VALUE"
         SET pe_id = cnvtint(reltn_cd)
         CALL inserttoargument(dummyvar)
        ELSE
         SET j = findstring(";",strvalue,(i+ 1))
         SET reltn_cd = substring((i+ 1),((j - i) - 1),strvalue)
         IF (y=tmpcnt)
          SET j = size(strvalue)
          SET list_owner_id = substring((i+ 1),(j - i),strvalue)
         ENDIF
         SET arg_name = "lifetime_reltn_cd"
         SET arg_value = " "
         SET pe_name = "CODE_VALUE"
         SET pe_id = cnvtint(reltn_cd)
         CALL inserttoargument(dummyvar)
        ENDIF
        SET check_flg = 0
       ELSE
        IF (findstring(";",strvalue,(j+ 1))=0)
         SET i = size(strvalue)
         SET reltn_cd = substring((j+ 1),(i - j),strvalue)
         SET list_owner_id = " "
         SET arg_name = "lifetime_reltn_cd"
         SET arg_value = " "
         SET pe_name = "CODE_VALUE"
         SET pe_id = cnvtint(reltn_cd)
         CALL inserttoargument(dummyvar)
        ELSE
         SET i = findstring(";",strvalue,(j+ 1))
         SET reltn_cd = substring((j+ 1),((i - j) - 1),strvalue)
         IF (y=tmpcnt)
          SET i = size(strvalue)
          SET list_owner_id = substring((j+ 1),(i - j),strvalue)
         ENDIF
         SET arg_name = "lifetime_reltn_cd"
         SET arg_value = " "
         SET pe_name = "CODE_VALUE"
         SET pe_id = cnvtint(reltn_cd)
         CALL inserttoargument(dummyvar)
        ENDIF
        SET check_flg = 1
       ENDIF
     ENDFOR
    ENDIF
   ELSE
    SET patientlist->qual[subcnt].pat_list_id = 0
    SET patientlist->qual[subcnt].owner_id = cnvtint(list_owner_id)
   ENDIF
 END ;Subroutine
 SUBROUTINE custom(pl_info,subcnt)
   SET patientlist->qual[subcnt].type_cd = cust_cd
   SET strvalue = pl_info
   SET pl_desc = concat("CUSTOM: Custom List for ",patientlist->qual[subcnt].name)
   SET i = findstring(";",strvalue,1)
   SET type = substring(1,(i - 1),strvalue)
   SET j = findstring(";",strvalue,(i+ 1))
   SET filter_str = substring((i+ 1),((j - i) - 1),strvalue)
   IF (findstring(";",strvalue,(j+ 1))=0)
    SET i = size(strvalue)
    SET list_id = substring((j+ 1),(i - j),strvalue)
    SET list_owner_id = " "
   ELSE
    SET i = findstring(";",strvalue,(j+ 1))
    SET list_id = substring((j+ 1),((i - j) - 1),strvalue)
    SET j = size(strvalue)
    SET list_owner_id = substring((i+ 1),(j - i),strvalue)
   ENDIF
   IF (((list_owner_id=" ") OR (cnvtint(list_owner_id)=0)) )
    CALL echo(build("Insert to patient list with new pt list id of ",tmp_patient_list_id))
    CALL inserttopatientlist(subcnt)
    CALL filters(filter_str)
    SELECT INTO "nl:"
     FROM custom_pt_list_entry cple
     PLAN (cple
      WHERE cple.custom_pt_list_id=cnvtint(list_id)
       AND cple.active_ind=1
       AND cple.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND cple.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     HEAD REPORT
      ce_cnt = 0
     DETAIL
      ce_flg = 1, ce_cnt = (ce_cnt+ 1), stat = alterlist(customentry->qual,ce_cnt),
      customentry->qual[ce_cnt].encntr_id = cple.encntr_id, customentry->qual[ce_cnt].person_id =
      cple.person_id
     WITH nocounter
    ;end select
    FOR (a = 1 TO ce_cnt)
      CALL echo(build("Person_id: ",customentry->qual[ce_cnt].person_id))
    ENDFOR
    CALL inserttoplcustomentry(ce_cnt)
   ELSE
    SET patientlist->qual[subcnt].pat_list_id = 0
    SET patientlist->qual[subcnt].owner_id = cnvtint(list_owner_id)
   ENDIF
 END ;Subroutine
 SUBROUTINE group(pl_info,subcnt)
   SET patientlist->qual[subcnt].type_cd = grp_cd
   SET strvalue = pl_info
   SET pl_desc = concat("GROUP: Group List for ",patientlist->qual[subcnt].name)
   SET i = findstring(";",strvalue,1)
   SET type = substring(1,(i - 1),strvalue)
   SET j = findstring(";",strvalue,(i+ 1))
   SET filter_str = substring((i+ 1),((j - i) - 1),strvalue)
   IF (findstring(";",strvalue,(j+ 1))=0)
    SET i = size(strvalue)
    SET list_id = substring((j+ 1),(i - j),strvalue)
    SET list_owner_id = " "
   ELSE
    SET i = findstring(";",strvalue,(j+ 1))
    SET list_id = substring((j+ 1),((i - j) - 1),strvalue)
    SET j = size(strvalue)
    SET list_owner_id = substring((i+ 1),(j - i),strvalue)
   ENDIF
   IF (((list_owner_id=" ") OR (cnvtint(list_owner_id)=0)) )
    CALL inserttopatientlist(subcnt)
    CALL filters(filter_str)
    SET arg_name = "prsnl_group_id"
    SET arg_value = " "
    SET pe_name = "PRSNL_GROUP"
    SET pe_id = cnvtint(list_id)
    CALL inserttoargument(dummyvar)
    IF (priortizationpass)
     CALL inserttoprioritization(group_type_cd,list_id)
    ENDIF
   ELSE
    SET patientlist->qual[subcnt].pat_list_id = 0
    SET patientlist->qual[subcnt].owner_id = cnvtint(list_owner_id)
   ENDIF
 END ;Subroutine
 SUBROUTINE medservice(pl_info,subcnt)
   SET patientlist->qual[subcnt].type_cd = med_serv_cd
   SET strvalue = pl_info
   SET pl_desc = concat("MEDSERVICE: Medical Service List for ",patientlist->qual[subcnt].name)
   SET i = findstring(";",strvalue,1)
   SET type = substring(1,(i - 1),strvalue)
   SET j = findstring(";",strvalue,(i+ 1))
   SET filter_str = substring((i+ 1),((j - i) - 1),strvalue)
   IF (findstring(";",strvalue,(j+ 1))=0)
    SET i = size(strvalue)
    SET med_service_cd = substring((j+ 1),(i - j),strvalue)
    SET list_owner_id = " "
   ELSE
    SET i = findstring(";",strvalue,(j+ 1))
    SET med_service_cd = substring((j+ 1),((i - j) - 1),strvalue)
    SET j = size(strvalue)
    SET list_owner_id = substring((i+ 1),(j - i),strvalue)
   ENDIF
   IF (((list_owner_id=" ") OR (cnvtint(list_owner_id)=0)) )
    CALL inserttopatientlist(subcnt)
    CALL filters(filter_str)
    SET arg_name = "medical_service_cd"
    SET arg_value = " "
    SET pe_name = "CODE_VALUE"
    SET pe_id = cnvtint(med_service_cd)
    CALL inserttoargument(dummyvar)
    SET arg_name = "lag_minutes"
    SET arg_value = "120"
    SET pe_name = " "
    SET pe_id = 0
    CALL inserttoargument(dummyvar)
   ELSE
    SET patientlist->qual[subcnt].pat_list_id = 0
    SET patientlist->qual[subcnt].owner_id = cnvtint(list_owner_id)
   ENDIF
 END ;Subroutine
 SUBROUTINE careteam(pl_info,subcnt)
   SET patientlist->qual[subcnt].type_cd = teamlist_cd
   SET strvalue = pl_info
   SET pl_desc = concat("CARETEAM: CareTeam List for ",patientlist->qual[subcnt].name)
   SET i = findstring(";",strvalue,1)
   SET type = substring(1,(i - 1),strvalue)
   SET j = findstring(";",strvalue,(i+ 1))
   SET filter_str = substring((i+ 1),((j - i) - 1),strvalue)
   IF (findstring(";",strvalue,(j+ 1))=0)
    SET i = size(strvalue)
    SET list_id = substring((j+ 1),(i - j),strvalue)
    SET list_owner_id = " "
   ELSE
    SET i = findstring(";",strvalue,(j+ 1))
    SET list_id = substring((j+ 1),((i - j) - 1),strvalue)
    SET j = size(strvalue)
    SET list_owner_id = substring((i+ 1),(j - i),strvalue)
   ENDIF
   IF (((list_owner_id=" ") OR (cnvtint(list_owner_id)=0)) )
    CALL inserttopatientlist(subcnt)
    CALL filters(filter_str)
    SET arg_name = "prsnl_group_id"
    SET arg_value = " "
    SET pe_name = "PRSNL_GROUP"
    SET pe_id = cnvtint(list_id)
    CALL inserttoargument(dummyvar)
   ELSE
    SET patientlist->qual[subcnt].pat_list_id = 0
    SET patientlist->qual[subcnt].owner_id = cnvtint(list_owner_id)
   ENDIF
 END ;Subroutine
 SUBROUTINE locgroup(pl_info,subcnt)
   SET patientlist->qual[subcnt].type_cd = locgrp_cd
   SET strvalue = pl_info
   SET pl_desc = concat("LOCGROUP: Location Group List for ",patientlist->qual[subcnt].name)
   SET i = findstring(";",strvalue,1)
   SET type = substring(1,(i - 1),strvalue)
   SET j = findstring(";",strvalue,(i+ 1))
   SET filter_str = substring((i+ 1),((j - i) - 1),strvalue)
   IF (findstring(";",strvalue,(j+ 1))=0)
    SET i = size(strvalue)
    SET loc_grp_cd = substring((j+ 1),(i - j),strvalue)
    SET list_owner_id = " "
   ELSE
    SET i = findstring(";",strvalue,(j+ 1))
    SET list_id = substring((j+ 1),((i - j) - 1),strvalue)
    SET j = size(strvalue)
    SET list_owner_id = substring((i+ 1),(j - i),strvalue)
   ENDIF
   IF (((list_owner_id=" ") OR (cnvtint(list_owner_id)=0)) )
    CALL inserttopatientlist(subcnt)
    CALL filters(filter_str)
    SET arg_name = "location_group"
    SET arg_value = " "
    SET pe_name = "CODE_VALUE"
    SET pe_id = cnvtint(loc_grp_cd)
    CALL inserttoargument(dummyvar)
    SET arg_name = "lag_minutes"
    SET arg_value = "120"
    SET pe_name = " "
    SET pe_id = 0
    CALL inserttoargument(dummyvar)
   ELSE
    SET patientlist->qual[subcnt].pat_list_id = 0
    SET patientlist->qual[subcnt].owner_id = cnvtint(list_owner_id)
   ENDIF
 END ;Subroutine
 SUBROUTINE filters(fstring)
   SET k = findstring(",",fstring,1)
   SET patient_status = substring(1,(k - 1),fstring)
   SET l = findstring(",",fstring,(k+ 1))
   SET time_units = substring((k+ 1),((l - k) - 1),fstring)
   SET k = findstring(",",fstring,(l+ 1))
   SET time_quantity = substring((l+ 1),((k - l) - 1),fstring)
   SET l = findstring(",",fstring,(k+ 1))
   SET patient_type_count = substring((k+ 1),((l - k) - 1),fstring)
   IF (cnvtint(patient_status) > 0)
    SET arg_name = "patient_status_flag"
    SET arg_value = patient_status
    SET pe_name = " "
    SET pe_id = 0
    CALL inserttoargument(dummyvar)
    IF (cnvtint(time_units)=0)
     SET status_minutes = cnvtstring((1440 * cnvtreal(time_quantity)))
    ELSE
     SET status_minutes = cnvtstring((60 * cnvtreal(time_quantity)))
    ENDIF
    SET arg_name = "patient_status_minutes"
    SET arg_value = status_minutes
    SET pe_name = " "
    SET pe_id = 0
    IF (status_minutes > cnvtstring(0))
     CALL inserttoargument(dummyvar)
    ENDIF
   ENDIF
   SET tmpcnt = cnvtint(patient_type_count)
   IF (tmpcnt=0)
    SET patient_type = "**All Types**"
    SET k = size(fstring)
    SET new_results = substring((l+ 1),(k - l),fstring)
   ELSE
    SET check_flg = 1
    FOR (y = 1 TO tmpcnt)
      IF (check_flg=1)
       SET k = findstring(",",fstring,(l+ 1))
       SET patient_type = substring((l+ 1),((k - l) - 1),fstring)
       IF (y=tmpcnt)
        SET l = size(fstring)
        SET new_results = substring((k+ 1),(l - k),fstring)
       ENDIF
       CALL inserttoencntrfilter(patient_type)
       SET check_flg = 0
      ELSE
       SET l = findstring(",",fstring,(k+ 1))
       SET patient_type = substring((k+ 1),((l - k) - 1),fstring)
       IF (y=tmpcnt)
        SET k = size(fstring)
        SET new_results = substring((l+ 1),(k - l),fstring)
       ENDIF
       CALL inserttoencntrfilter(patient_type)
       SET check_flg = 1
      ENDIF
    ENDFOR
   ENDIF
   IF (cnvtint(new_results)=1)
    SET arg_name = "new_results_flag"
    SET arg_value = new_results
    SET pe_name = " "
    SET pe_id = 0
    CALL inserttoargument(dummyvar)
   ENDIF
 END ;Subroutine
 SUBROUTINE inserttopatientlist(cnt)
   CALL echo("Insert To Patient List")
   CALL echo(build("list name: ",substring(0,50,patientlist->qual[cnt].name)))
   SET patientlist->qual[cnt].pat_list_id = tmp_patient_list_id
   SET patientlist->qual[cnt].owner_id = 0
   INSERT  FROM dcp_patient_list pl
    SET pl.patient_list_id = tmp_patient_list_id, pl.description = substring(0,50,pl_desc), pl.name
      = substring(0,50,patientlist->qual[cnt].name),
     pl.owner_prsnl_id = patientlist->qual[cnt].prsnl_id, pl.patient_list_type_cd = patientlist->
     qual[cnt].type_cd, pl.updt_applctx = reqinfo->updt_applctx,
     pl.updt_cnt = 0, pl.updt_dt_tm = cnvtdatetime(curdate,curtime3), pl.updt_id = reqinfo->updt_id,
     pl.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET insertfailed = 1
    SET readme_data->message = "DCP_PATIENT_LIST insert failed."
   ENDIF
   IF (skip_nv_prefs=0)
    INSERT  FROM name_value_prefs nvp
     SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name = substring(0,50,
       patientlist->qual[cnt].pe_name), nvp.parent_entity_id = patientlist->qual[cnt].pe_id,
      nvp.pvc_name = "PatientListId", nvp.pvc_value = cnvtstring(tmp_patient_list_id), nvp.active_ind
       = 1,
      nvp.merge_id = 0, nvp.merge_name = " ", nvp.updt_applctx = reqinfo->updt_applctx,
      nvp.updt_cnt = 0, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->
      updt_id,
      nvp.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET insertfailed = 1
     SET readme_data->message = "NAME_VALUE_PREFS insert failed."
    ENDIF
   ENDIF
   SET proxylist_cnt = 0
   SET proxy_cnt = 0
   SELECT INTO "nl:"
    FROM proxy prxy
    WHERE (prxy.person_id=patientlist->qual[cnt].prsnl_id)
     AND prxy.proxy_person_id > 0
     AND prxy.active_ind=1
    ORDER BY prxy.proxy_person_id
    HEAD prxy.proxy_person_id
     proxylist_cnt = (proxylist_cnt+ 1), stat = alterlist(proxylist->qual,proxylist_cnt), proxylist->
     qual[proxylist_cnt].proxy_person_id = prxy.proxy_person_id,
     proxylist->qual[proxylist_cnt].beg_dt_tm = cnvtdatetime(prxy.beg_effective_dt_tm), proxylist->
     qual[proxylist_cnt].end_dt_tm = cnvtdatetime(prxy.end_effective_dt_tm)
    WITH nocounter
   ;end select
   IF (proxylist_cnt > 0)
    FOR (proxy_cnt = 1 TO proxylist_cnt)
     INSERT  FROM dcp_pl_reltn plr
      SET plr.reltn_id = seq(dcp_patient_list_seq,nextval), plr.patient_list_id = tmp_patient_list_id,
       plr.prsnl_group_id = 0,
       plr.prsnl_id = proxylist->qual[proxy_cnt].proxy_person_id, plr.list_access_cd = lst_access_cd,
       plr.beg_effective_dt_tm = cnvtdatetime(proxylist->qual[proxy_cnt].beg_dt_tm),
       plr.end_effective_dt_tm = cnvtdatetime(proxylist->qual[proxy_cnt].end_dt_tm), plr.updt_applctx
        = reqinfo->updt_applctx, plr.updt_cnt = 0,
       plr.updt_dt_tm = cnvtdatetime(curdate,curtime3), plr.updt_id = reqinfo->updt_id, plr.updt_task
        = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET insertfailed = 1
      SET readme_data->message = "DCP_PL_RELTN insert failed."
     ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE inserttoprioritization(priority_type_cd,priority_list_id)
   SET found = 0
   SET p_cnt = 0
   SELECT INTO "nl:"
    FROM dcp_pl pl,
     dcp_pl_priority plp
    PLAN (pl
     WHERE pl.type_cd=priority_type_cd
      AND pl.list_id=cnvtint(priority_list_id))
     JOIN (plp
     WHERE plp.pl_id=pl.pl_id)
    DETAIL
     found = 1, p_cnt = (p_cnt+ 1), stat = alterlist(prioritization->qual,p_cnt),
     prioritization->qual[p_cnt].person_id = plp.person_id, prioritization->qual[p_cnt].priority =
     plp.priority_flag
    WITH nocounter
   ;end select
   CALL echo(build("Priority_Type_Cd: ",priority_type_cd))
   CALL echo(build("Priority_List_Id: ",priority_list_id))
   IF (found=1)
    FOR (p_count = 1 TO p_cnt)
     INSERT  FROM dcp_pl_prioritization plpzn
      SET plpzn.priority_id = seq(dcp_patient_list_seq,nextval), plpzn.patient_list_id =
       tmp_patient_list_id, plpzn.priority = prioritization->qual[p_count].priority,
       plpzn.person_id = prioritization->qual[p_count].person_id, plpzn.updt_applctx = reqinfo->
       updt_applctx, plpzn.updt_cnt = 0,
       plpzn.updt_dt_tm = cnvtdatetime(curdate,curtime3), plpzn.updt_id = reqinfo->updt_id, plpzn
       .updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET insertfailed = 1
      SET readme_data->message = "DCP_PL_PRIORITIZATION insert failed."
     ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE inserttoargument(arg_dummyvar)
  INSERT  FROM dcp_pl_argument pla
   SET pla.argument_id = seq(dcp_patient_list_seq,nextval), pla.argument_name = substring(0,50,
     arg_name), pla.argument_value = substring(0,50,arg_value),
    pla.parent_entity_id = pe_id, pla.parent_entity_name = substring(0,50,pe_name), pla
    .patient_list_id = tmp_patient_list_id,
    pla.sequence = 1, pla.updt_applctx = reqinfo->updt_applctx, pla.updt_cnt = 0,
    pla.updt_dt_tm = cnvtdatetime(curdate,curtime3), pla.updt_id = reqinfo->updt_id, pla.updt_task =
    reqinfo->updt_task
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET insertfailed = 1
   SET readme_data->message = "DCP_PL_ARGUMENT insert failed."
  ENDIF
 END ;Subroutine
 SUBROUTINE inserttoplcustomentry(subcnt)
   CALL echo("Begin InsertToPLCustomEntry Subroutine")
   CALL echo(build("Patient List Id is: ",tmp_patient_list_id))
   IF (ce_flg=1)
    FOR (ce_count = 1 TO value(subcnt))
      CALL echo(build("Person ID: ",customentry->qual[ce_count].person_id))
      INSERT  FROM dcp_pl_custom_entry plce
       SET plce.custom_entry_id = seq(dcp_patient_list_seq,nextval), plce.patient_list_id =
        tmp_patient_list_id, plce.encntr_id = customentry->qual[ce_count].encntr_id,
        plce.person_id = customentry->qual[ce_count].person_id, plce.updt_applctx = reqinfo->
        updt_applctx, plce.updt_cnt = 0,
        plce.updt_dt_tm = cnvtdatetime(curdate,curtime3), plce.updt_id = reqinfo->updt_id, plce
        .updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET insertfailed = 1
       SET readme_data->message = "DCP_PL_CUSTOM_ENTRY insert failed."
      ENDIF
    ENDFOR
   ENDIF
   SET ce_flg = 0
 END ;Subroutine
 SUBROUTINE inserttoencntrfilter(p_type_cd)
  INSERT  FROM dcp_pl_encntr_filter plef
   SET plef.encntr_filter_id = seq(dcp_patient_list_seq,nextval), plef.encntr_type_cd = cnvtint(
     p_type_cd), plef.patient_list_id = tmp_patient_list_id,
    plef.updt_applctx = reqinfo->updt_applctx, plef.updt_cnt = 0, plef.updt_dt_tm = cnvtdatetime(
     curdate,curtime3),
    plef.updt_id = reqinfo->updt_id, plef.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET insertfailed = 1
   SET readme_data->message = "DCP_PL_ENCNTR_FILTER insert failed."
  ENDIF
 END ;Subroutine
 SUBROUTINE inserttonamevalueprefs(nvp_cnt)
   SET strvalue = patientlist->qual[nvp_cnt].info
   SET i = findstring(";",strvalue,1)
   SET type = substring(1,(i - 1),strvalue)
   SET list_type = concat('"',trim(type,3),"*",'"')
   CALL echo(build("List_Type: ",list_type))
   SET priority_where = concat("pl.patient_list_id = plr.patient_list_id",
    " and pl.patient_list_type_cd = patientlist->qual[NVP_Cnt]->type_cd",
    " and pl.owner_prsnl_id = patientlist->qual[NVP_Cnt]->owner_id"," and pl.description like ",trim(
     list_type,3))
   SET found = 0
   SELECT INTO "nl:"
    FROM dcp_pl_reltn plr,
     dcp_patient_list pl
    PLAN (plr
     WHERE (plr.prsnl_id=patientlist->qual[nvp_cnt].prsnl_id))
     JOIN (pl
     WHERE parser(trim(priority_where)))
    DETAIL
     found = 1, nvp_value = cnvtstring(pl.patient_list_id)
    WITH nocounter
   ;end select
   IF (found=1)
    INSERT  FROM name_value_prefs nvp
     SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name = substring(0,50,
       patientlist->qual[nvp_cnt].pe_name), nvp.parent_entity_id = patientlist->qual[nvp_cnt].pe_id,
      nvp.pvc_name = "PatientListId", nvp.pvc_value = substring(0,50,nvp_value), nvp.active_ind = 1,
      nvp.merge_id = 0, nvp.merge_name = " ", nvp.updt_applctx = reqinfo->updt_applctx,
      nvp.updt_cnt = 0, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->
      updt_id,
      nvp.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET insertfailed = 1
     SET readme_data->message = "NAME_VALUE_PREFS insert failed."
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE inserttoreltn(lo_cnt)
   SET found = 0
   SELECT INTO "nl:"
    FROM dcp_patient_list pl,
     proxy p
    PLAN (pl
     WHERE (pl.owner_prsnl_id=patientlist->qual[lo_cnt].owner_id)
      AND (pl.patient_list_type_cd=patientlist->qual[lo_cnt].type_cd))
     JOIN (p
     WHERE (p.person_id=patientlist->qual[lo_cnt].owner_id)
      AND (p.proxy_person_id=patientlist->qual[lo_cnt].prsnl_id))
    DETAIL
     found = 1, beg_dt_tm = cnvtdatetime(p.beg_effective_dt_tm), end_dt_tm = cnvtdatetime(p
      .end_effective_dt_tm)
    WITH nocounter
   ;end select
   IF (found=1)
    INSERT  FROM dcp_pl_reltn plr
     SET plr.reltn_id = seq(dcp_patient_list_seq,nextval), plr.patient_list_id = pl.patient_list_id,
      plr.prsnl_group_id = 0,
      plr.prsnl_id = patientlist->qual[lo_cnt].prsnl_id, plr.list_access_cd = lst_access_cd, plr
      .beg_effective_dt_tm = beg_dt_tm,
      plr.end_effective_dt_tm = end_dt_tm, plr.updt_applctx = reqinfo->updt_applctx, plr.updt_cnt = 0,
      plr.updt_dt_tm = cnvtdatetime(curdate,curtime3), plr.updt_id = reqinfo->updt_id, plr.updt_task
       = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET insertfailed = 1
     SET readme_data->message = "DCP_PL_RELTN insert failed."
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE getlistownerid(pl_value)
   SET strvalue = pl_value
   SET i = findstring(";",strvalue,1)
   SET j = findstring(";",strvalue,(i+ 1))
   IF (findstring(";",strvalue,(j+ 1))=0)
    SET i = size(strvalue)
   ELSE
    SET i = findstring(";",strvalue,(j+ 1))
   ENDIF
   IF (tmpcnt=0)
    IF (findstring(";",strvalue,(i+ 1))=0)
     SET list_owner_id = " "
    ELSE
     SET j = size(strvalue)
     SET list_owner_id = substring((i+ 1),(j - i),strvalue)
    ENDIF
   ELSEIF ((tmpcnt=- (1)))
    IF (findstring(";",strvalue,(i+ 1))=0)
     SET list_owner_id = " "
    ELSE
     SET j = size(strvalue)
     SET list_owner_id = substring((i+ 1),(j - i),strvalue)
    ENDIF
   ELSE
    SET check_flg = 1
    FOR (y = 1 TO tmpcnt)
      IF (check_flg=1)
       IF (findstring(";",strvalue,(i+ 1))=0)
        SET list_owner_id = " "
       ELSE
        SET j = findstring(";",strvalue,(i+ 1))
        IF (y=tmpcnt)
         SET j = size(strvalue)
         SET list_owner_id = substring((i+ 1),(j - i),strvalue)
        ENDIF
       ENDIF
       SET check_flg = 0
      ELSE
       IF (findstring(";",strvalue,(j+ 1))=0)
        SET list_owner_id = " "
       ELSE
        SET i = findstring(";",strvalue,(j+ 1))
        IF (y=tmpcnt)
         SET i = size(strvalue)
         SET list_owner_id = substring((j+ 1),(i - j),strvalue)
        ENDIF
       ENDIF
       SET check_flg = 1
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE teampatients(x)
   DECLARE group_cnt = i4 WITH public, noconstant(0)
   DECLARE te_cnt = i4 WITH public, noconstant(0)
   RECORD grouprec(
     1 qual[*]
       2 prsnl_group_id = f8
   )
   RECORD teamrec(
     1 qual[*]
       2 group_id = f8
       2 encntr_id = f8
       2 person_id = f8
   )
   SET group_cnt = 0
   SELECT INTO "nl:"
    FROM prsnl_group pg
    PLAN (pg
     WHERE pg.active_ind=1
      AND pg.prsnl_group_class_cd=team_cd
      AND pg.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND pg.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    DETAIL
     group_cnt = (group_cnt+ 1), stat = alterlist(grouprec->qual,group_cnt), grouprec->qual[group_cnt
     ].prsnl_group_id = pg.prsnl_group_id
    WITH nocounter
   ;end select
   SET te_cnt = 0
   FOR (x = 1 TO group_cnt)
     SELECT INTO "nl:"
      FROM encntr_prsnl_grp_reltn epgr,
       encounter e
      PLAN (epgr
       WHERE (epgr.prsnl_group_id=grouprec->qual[x].prsnl_group_id)
        AND epgr.active_ind=1
        AND epgr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND epgr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
       JOIN (e
       WHERE e.encntr_id=epgr.encntr_id
        AND e.active_ind=1
        AND e.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
      HEAD REPORT
       te_cnt = 0
      DETAIL
       te_cnt = (te_cnt+ 1), stat = alterlist(teamrec->qual,te_cnt), teamrec->qual[te_cnt].encntr_id
        = epgr.encntr_id,
       teamrec->qual[te_cnt].person_id = e.person_id
      WITH nocounter
     ;end select
     FOR (y = 1 TO te_cnt)
      INSERT  FROM dcp_pl_custom_entry plce
       SET plce.custom_entry_id = seq(dcp_patient_list_seq,nextval), plce.patient_list_id = 0, plce
        .prsnl_group_id = grouprec->qual[x].prsnl_group_id,
        plce.encntr_id = teamrec->qual[y].encntr_id, plce.person_id = teamrec->qual[y].person_id,
        plce.updt_applctx = reqinfo->updt_applctx,
        plce.updt_cnt = 0, plce.updt_dt_tm = cnvtdatetime(curdate,curtime3), plce.updt_id = reqinfo->
        updt_id,
        plce.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET insertfailed = 1
       SET readme_data->message = "DCP_PL_CUSTOM_ENTRY insert failed."
      ENDIF
     ENDFOR
     UPDATE  FROM encntr_prsnl_grp_reltn
      SET active_ind = 0
      WHERE (prsnl_group_id=grouprec->qual[x].prsnl_group_id)
     ;end update
   ENDFOR
 END ;Subroutine
 SUBROUTINE custompatients(x)
   CALL echo("*********************BEGIN CUSTOMPATIENTS SUBROUTINE******************************")
   CALL echo("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&")
   DECLARE custcnt = i4 WITH public, noconstant(0)
   DECLARE prefcnt = i4 WITH public, noconstant(0)
   DECLARE pid = vc WITH public, noconstant(fillstring(100," "))
   DECLARE pref = vc WITH public, noconstant(fillstring(100," "))
   DECLARE pref1 = vc WITH public, noconstant(fillstring(100," "))
   RECORD prefrec(
     1 qualcnt = f8
     1 qual[*]
       2 listid = f8
   )
   RECORD custrec(
     1 qualcnt = f8
     1 qual[*]
       2 listid = f8
       2 listname = vc
       2 owner_prsnl_id = f8
   )
   SET listcnt = 0
   SELECT INTO "nl:"
    FROM custom_pt_list cp
    PLAN (cp
     WHERE cp.active_ind=1)
    ORDER BY cp.custom_pt_list_id
    DETAIL
     custcnt = (custcnt+ 1), stat = alterlist(custrec->qual,custcnt), custrec->qual[custcnt].listid
      = cp.custom_pt_list_id,
     custrec->qual[custcnt].listname = cp.list_name, custrec->qual[custcnt].owner_prsnl_id = cp
     .person_id
    WITH nocounter
   ;end select
   SET custrec->qualcnt = custcnt
   CALL echo(build("Custcnt = ",custcnt))
   SELECT INTO "nl:"
    FROM name_value_prefs nvp
    PLAN (nvp
     WHERE nvp.pvc_name="TABINFO"
      AND nvp.pvc_value="CUSTOM;*")
    DETAIL
     prefcnt = (prefcnt+ 1), stat = alterlist(prefrec->qual,prefcnt), strvalue = nvp.pvc_value,
     i = findstring(";",strvalue,1), j = findstring(";",strvalue,(i+ 1))
     IF (findstring(";",strvalue,(j+ 1))=0)
      i = size(strvalue), list_id = substring((j+ 1),(i - j),strvalue), list_owner_id = " "
     ELSE
      i = findstring(";",strvalue,(j+ 1)), list_id = substring((j+ 1),((i - j) - 1),strvalue), j =
      size(strvalue),
      list_owner_id = substring((i+ 1),(j - i),strvalue)
     ENDIF
     prefrec->qual[prefcnt].listid = cnvtint(list_id)
    WITH nocounter
   ;end select
   SET prefrec->qualcnt = prefcnt
   CALL echo(build("prefrec QUALCNT: ",prefcnt))
   CALL echo(build("CUSTCNT: ",custcnt))
   FOR (x = 1 TO custcnt)
     CALL echo(build("Cust table List Id : ",custrec->qual[x].listid))
     CALL echo(build("Cust table List Name: ",custrec->qual[x].listname))
     SET found = 0
     FOR (y = 1 TO prefcnt)
      IF ((custrec->qual[x].listid=prefrec->qual[y].listid))
       CALL echo(build("Pref item :",y," matched, set found = 1"))
       SET found = 1
      ENDIF
      IF (found=1)
       SET y = prefcnt
      ENDIF
     ENDFOR
     CALL echo(build("Last pref item # : ",y))
     IF (found=0)
      CALL echo(build("Did not find match for custom pt list id: ",custrec->qual[x].listid))
      SET listcnt = (listcnt+ 1)
      SET stat = alterlist(patientlist->qual,listcnt)
      SET patientlist->qual[listcnt].prsnl_id = custrec->qual[x].owner_prsnl_id
      SET patientlist->qual[listcnt].name = custrec->qual[x].listname
      SET patientlist->qual[listcnt].type_cd = cust_cd
      SET patientlist->qual[listcnt].cust_list_id = custrec->qual[x].listid
      SET pid = cnvtstring(custrec->qual[x].listid)
      CALL echo(build("pid = ",pid))
      SET pref = "CUSTOM;0,0,0,0,0;"
      CALL echo(build("pref = ",pref))
      SET pref1 = concat(trim(pref),trim(pid))
      CALL echo(build("pref1 = ",pref1))
      SET patientlist->qual[listcnt].info = trim(pref1)
      CALL echo(build("List Id to add: ",custrec->qual[x].listid))
      CALL echo(build("          name: ",custrec->qual[x].listname))
     ELSE
      CALL echo(build("Found match for custom pt list id: ",custrec->qual[x].listid))
     ENDIF
     CALL echo(" ---------------")
   ENDFOR
   CALL echo(build(" *****DID NOT FIND MATCH FOR ",listcnt," LISTS."))
   FOR (x = 1 TO listcnt)
     CALL echo(build("No match for ",patientlist->qual[x].cust_list_id))
     CALL echo("adding it")
     SELECT INTO "nl:"
      nextseqnum = seq(dcp_patient_list_seq,nextval)
      FROM dual
      DETAIL
       tmp_patient_list_id = cnvtint(nextseqnum)
      WITH nocounter
     ;end select
     SET skip_nv_prefs = 1
     CALL custom(patientlist->qual[x].info,x)
     SET skip_nv_prefs = 0
     UPDATE  FROM custom_pt_list
      SET active_ind = 0
      WHERE (custom_pt_list_id=patientlist->qual[x].cust_list_id)
     ;end update
     UPDATE  FROM custom_pt_list_entry
      SET active_ind = 0
      WHERE (custom_pt_list_id=patientlist->qual[x].cust_list_id)
     ;end update
     CALL echo("-------------------------")
     COMMIT
   ENDFOR
 END ;Subroutine
#exit_script
 IF (scriptfailed=1)
  CALL echo("Updating readme status as failed")
  SET readme_data->status = "F"
 ELSE
  SET x = 0
  CALL teampatients(x)
  CALL custompatients(x)
  CALL echo("Updating readme status as successful")
  SET readme_data->message = "Readme 1725 completed successfully."
  SET readme_data->status = "S"
 ENDIF
 FREE RECORD teamrec
 FREE RECORD grouprec
 FREE RECORD patientlist
 FREE RECORD customentry
 FREE RECORD proxylist
 FREE RECORD prioritization
 SET modify = nopredeclare
 EXECUTE dm_readme_status
END GO
