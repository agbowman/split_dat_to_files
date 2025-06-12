CREATE PROGRAM bed_imp_client_org:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE active_cd = f8
 DECLARE auth_cd = f8
 DECLARE emp_cd = f8
 DECLARE client_cd = f8
 DECLARE guarantor_cd = f8
 DECLARE followup_cd = f8
 DECLARE pharmacy_cd = f8
 DECLARE collect_agency_cd = f8
 DECLARE pre_collect_agency_cd = f8
 DECLARE org_class_cd = f8
 DECLARE bus_addr_cd = f8
 DECLARE state_cd = f8
 DECLARE county_cd = f8
 DECLARE country_cd = f8
 DECLARE freetext_cd = f8
 DECLARE bus_phone_cd = f8
 DECLARE fax_phone_cd = f8
 DECLARE neworgid = f8
 DECLARE found = vc
 DECLARE active = i2
 DECLARE msg = vc
 DECLARE error_flag = vc
 DECLARE skip_ind = i2
 DECLARE addr3 = vc
 DECLARE addr4 = vc
 DECLARE post_acute_assist_living_cd = f8
 DECLARE post_acute_hospice_cd = f8
 DECLARE post_acute_hospital_cd = f8
 DECLARE post_acute_long_term_care_cd = f8
 DECLARE post_acute_rehab_hospital_cd = f8
 DECLARE post_acute_skilled_nursing_cd = f8
 DECLARE post_acute_services_cd = f8
 SET rvar = 0
 SELECT INTO "ccluserdir:bed_imp_client_org.log"
  rvar
  HEAD REPORT
   curdate"dd-mmm-yyyy;;d", "-", curtime"hh:mm;;m",
   col + 1, "Bedrock Client Organization Import Log"
  DETAIL
   row + 2, col 2, " "
  WITH nocounter, format = variable, noformfeed,
   maxcol = 132, maxrow = 1
 ;end select
 SET active_cd = 0.0
 SET auth_cd = 0.0
 SET client_cd = 0.0
 SET emp_cd = 0.0
 SET guarantor_cd = 0.0
 SET followup_cd = 0.0
 SET pharmacy_cd = 0.0
 SET collect_agency_cd = 0.0
 SET pre_collect_agency_cd = 0.0
 SET org_class_cd = 0.0
 SET bus_addr_cd = 0.0
 SET bus_phone_cd = 0.0
 SET fax_phone_cd = 0.0
 SET freetext_cd = 0.0
 SET error_flag = "N"
 SET skip_ind = 0
 SET post_acute_assist_living_cd = 0.0
 SET post_acute_hospice_cd = 0.0
 SET post_acute_hospital_cd = 0.0
 SET post_acute_long_term_care_cd = 0.0
 SET post_acute_rehab_hospital_cd = 0.0
 SET post_acute_skilled_nursing_cd = 0.0
 SET post_acute_services_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="ACTIVE"
    AND cv.active_ind=1)
  DETAIL
   active_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (active_cd=0.0)
  SET msg = "Error:  ACTIVE code not defined on code set 48.  Script Teminating"
  CALL logmessage(msg)
  SET error_flag = "Y"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=8
    AND cv.cdf_meaning="AUTH"
    AND cv.active_ind=1)
  DETAIL
   auth_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (auth_cd=0.0)
  SET msg = "Error:  AUTH code not defined on code set 8.  Script Teminating"
  CALL logmessage(msg)
  SET error_flag = "Y"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=278
    AND cv.cdf_meaning="CLIENT"
    AND cv.active_ind=1)
  DETAIL
   client_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (client_cd=0.0)
  SET msg = "Error:  CLIENT code not defined on code set 278.  Script Teminating"
  CALL logmessage(msg)
  SET error_flag = "Y"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=278
    AND cv.cdf_meaning="EMPLOYER"
    AND cv.active_ind=1)
  DETAIL
   emp_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (emp_cd=0.0)
  SET msg = "Error:  EMPLOYER code not defined on code set 278.  Script Teminating"
  CALL logmessage(msg)
  SET error_flag = "Y"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=278
    AND cv.cdf_meaning IN ("GUARANTOR", "FOLLOWUP", "PHARMACY", "COLAGENCY", "PRECOLAGENCY",
   "POSTACTASSLV", "POSTACTHOSPC", "POSTACTHOSPT", "POSTACTLTAC", "POSTACTREHAB",
   "POSTACTSKILL", "POSTACTSVCS")
    AND cv.active_ind=1)
  DETAIL
   IF (cv.cdf_meaning="GUARANTOR")
    guarantor_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="FOLLOWUP")
    followup_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="PHARMACY")
    pharmacy_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="COLAGENCY")
    collect_agency_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="PRECOLAGENCY")
    pre_collect_agency_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="POSTACTASSLV")
    post_acute_assist_living_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="POSTACTHOSPC")
    post_acute_hospice_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="POSTACTHOSPT")
    post_acute_hospital_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="POSTACTLTAC")
    post_acute_long_term_care_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="POSTACTREHAB")
    post_acute_rehab_hospital_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="POSTACTSKILL")
    post_acute_skilled_nursing_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="POSTACTSVCS")
    post_acute_services_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF (guarantor_cd=0.0)
  SET msg = "Error:  GUARANTOR code not defined on code set 278.  Script Teminating"
  CALL logmessage(msg)
  SET error_flag = "Y"
  GO TO exit_script
 ENDIF
 IF (followup_cd=0.0)
  SET msg = "Error:  FOLLOWUP code not defined on code set 278.  Script Teminating"
  CALL logmessage(msg)
  SET error_flag = "Y"
  GO TO exit_script
 ENDIF
 IF (pharmacy_cd=0.0)
  SET msg = "Error:  PHARMACY code not defined on code set 278.  Script Teminating"
  CALL logmessage(msg)
  SET error_flag = "Y"
  GO TO exit_script
 ENDIF
 IF (collect_agency_cd=0.0)
  SET msg = "Error: COLAGENCY code not defined on code set 278.  Script Teminating"
  CALL logmessage(msg)
  SET error_flag = "Y"
  GO TO exit_script
 ENDIF
 IF (pre_collect_agency_cd=0.0)
  SET msg = "Error:  PRECOLAGENCY code not defined on code set 278.  Script Teminating"
  CALL logmessage(msg)
  SET error_flag = "Y"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=396
    AND cv.cdf_meaning="ORG"
    AND cv.active_ind=1)
  DETAIL
   org_class_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (org_class_cd=0.0)
  SET msg = "Error:  ORG CLASS code not defined on code set 396.  Script Teminating"
  CALL logmessage(msg)
  SET error_flag = "Y"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=212
    AND cv.cdf_meaning="BUSINESS"
    AND cv.active_ind=1)
  DETAIL
   bus_addr_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (bus_addr_cd=0.0)
  SET msg = "Error:  BUSINESS ADDRESS code not defined on code set 212.  Script Teminating"
  CALL logmessage(msg)
  SET error_flag = "Y"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=43
    AND cv.cdf_meaning="BUSINESS"
    AND cv.active_ind=1)
  DETAIL
   bus_phone_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (bus_phone_cd=0.0)
  SET msg = "Error:  BUSINESS PHONE code not defined on code set 43.  Script Teminating"
  CALL logmessage(msg)
  SET error_flag = "Y"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=43
    AND cv.cdf_meaning="FAX BUS"
    AND cv.active_ind=1)
  DETAIL
   fax_phone_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (fax_phone_cd=0.0)
  SET msg = "Error:  FAX BUSINESS PHONE code not defined on code set 43.  Script Teminating"
  CALL logmessage(msg)
  SET error_flag = "Y"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=281
    AND cv.cdf_meaning="FREETEXT"
    AND cv.active_ind=1)
  DETAIL
   freetext_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (freetext_cd=0.0)
  SET msg = "Error:  FREETEXT phone type code not defined on code set 281.  Script Teminating"
  CALL logmessage(msg)
  SET error_flag = "Y"
  GO TO exit_script
 ENDIF
 SET numrows = size(requestin->list_0,5)
 IF (numrows > 0)
  SET client_col_exists = 0
  IF (validate(requestin->list_0[1].client))
   SET client_col_exists = 1
  ENDIF
  SET guarantor_col_exists = 0
  IF (validate(requestin->list_0[1].guarantor))
   SET guarantor_col_exists = 1
  ENDIF
  SET followup_col_exists = 0
  IF (validate(requestin->list_0[1].followup_facility))
   SET followup_col_exists = 1
  ENDIF
  SET pharmacy_col_exists = 0
  IF (validate(requestin->list_0[1].pharmacy))
   SET pharmacy_col_exists = 1
  ENDIF
  SET collect_agency_col_exists = 0
  IF (validate(requestin->list_0[1].collect_agency))
   SET collect_agency_col_exists = 1
  ENDIF
  SET pre_collect_agency_col_exists = 0
  IF (validate(requestin->list_0[1].pre_collect_agency))
   SET pre_collect_agency_col_exists = 1
  ENDIF
  SET post_acute_assist_living_col_exists = 0
  IF (validate(requestin->list_0[1].post_acute_assist_living))
   SET post_acute_assist_living_col_exists = 1
  ENDIF
  SET post_acute_hospice_col_exists = 0
  IF (validate(requestin->list_0[1].post_acute_hospice))
   SET post_acute_hospice_col_exists = 1
  ENDIF
  SET post_acute_hospital_col_exists = 0
  IF (validate(requestin->list_0[1].post_acute_hospital))
   SET post_acute_hospital_col_exists = 1
  ENDIF
  SET post_acute_long_term_care_col_exists = 0
  IF (validate(requestin->list_0[1].post_acute_long_term_care))
   SET post_acute_long_term_care_col_exists = 1
  ENDIF
  SET post_acute_rehab_hospital_col_exists = 0
  IF (validate(requestin->list_0[1].post_acute_rehab_hospital))
   SET post_acute_rehab_hospital_col_exists = 1
  ENDIF
  SET post_acute_skilled_nursing_col_exists = 0
  IF (validate(requestin->list_0[1].post_acute_skilled_nursing))
   SET post_acute_skilled_nursing_col_exists = 1
  ENDIF
  SET post_acute_services_col_exists = 0
  IF (validate(requestin->list_0[1].post_acute_services))
   SET post_acute_services_col_exists = 1
  ENDIF
  IF (client_col_exists=0
   AND guarantor_col_exists=0
   AND followup_col_exists=0
   AND pharmacy_col_exists=0
   AND collect_agency_col_exists=0
   AND pre_collect_agency_col_exists=0)
   SET new_format_ind = 0
  ELSEIF (client_col_exists=1
   AND guarantor_col_exists=1
   AND followup_col_exists=1
   AND pharmacy_col_exists=1
   AND collect_agency_col_exists=1
   AND pre_collect_agency_col_exists=1)
   SET new_format_ind = 1
  ELSE
   SET msg = "Error:  Not all organization type columns exist.  Script Teminating"
   CALL logmessage(msg)
   SET error_flag = "Y"
   GO TO exit_script
  ENDIF
  SET address3_col_exists = 0
  IF (validate(requestin->list_0[1].address3))
   SET address3_col_exists = 1
  ENDIF
  SET address4_col_exists = 0
  IF (validate(requestin->list_0[1].address4))
   SET address4_col_exists = 1
  ENDIF
  SET logical_domain_col_exists = 0
  IF (validate(requestin->list_0[1].logical_domain_id))
   SET logical_domain_col_exists = 1
  ENDIF
  SET data_partition_ind = 0
  RANGE OF o IS organization
  SET data_partition_ind = validate(o.logical_domain_id)
  FREE RANGE o
 ENDIF
 FOR (ii = 1 TO numrows)
   SET skip_ind = 0
   IF (new_format_ind=1)
    SET valid_org_type_chosen = 0
    IF (((cnvtupper(requestin->list_0[ii].client) IN ("YES", "Y")) OR (((cnvtupper(requestin->list_0[
     ii].guarantor) IN ("YES", "Y")) OR (((cnvtupper(requestin->list_0[ii].followup_facility) IN (
    "YES", "Y")) OR (((cnvtupper(requestin->list_0[ii].pharmacy) IN ("YES", "Y")) OR (((cnvtupper(
     requestin->list_0[ii].collect_agency) IN ("YES", "Y")) OR (((cnvtupper(requestin->list_0[ii].
     pre_collect_agency) IN ("YES", "Y")) OR (cnvtupper(requestin->list_0[ii].employer) IN ("YES",
    "Y"))) )) )) )) )) )) )
     SET valid_org_type_chosen = 1
    ELSE
     IF (post_acute_assist_living_col_exists=1)
      IF (cnvtupper(requestin->list_0[ii].post_acute_assist_living) IN ("YES", "Y"))
       SET valid_org_type_chosen = 1
      ENDIF
     ENDIF
     IF (post_acute_hospice_col_exists=1)
      IF (cnvtupper(requestin->list_0[ii].post_acute_hospice) IN ("YES", "Y"))
       SET valid_org_type_chosen = 1
      ENDIF
     ENDIF
     IF (post_acute_hospital_col_exists=1)
      IF (cnvtupper(requestin->list_0[ii].post_acute_hospital) IN ("YES", "Y"))
       SET valid_org_type_chosen = 1
      ENDIF
     ENDIF
     IF (post_acute_long_term_care_col_exists=1)
      IF (cnvtupper(requestin->list_0[ii].post_acute_long_term_care) IN ("YES", "Y"))
       SET valid_org_type_chosen = 1
      ENDIF
     ENDIF
     IF (post_acute_rehab_hospital_col_exists=1)
      IF (cnvtupper(requestin->list_0[ii].post_acute_rehab_hospital) IN ("YES", "Y"))
       SET valid_org_type_chosen = 1
      ENDIF
     ENDIF
     IF (post_acute_skilled_nursing_col_exists=1)
      IF (cnvtupper(requestin->list_0[ii].post_acute_skilled_nursing) IN ("YES", "Y"))
       SET valid_org_type_chosen = 1
      ENDIF
     ENDIF
     IF (post_acute_services_col_exists=1)
      IF (cnvtupper(requestin->list_0[ii].post_acute_services) IN ("YES", "Y"))
       SET valid_org_type_chosen = 1
      ENDIF
     ENDIF
    ENDIF
    IF (valid_org_type_chosen=0)
     SET skip_ind = 1
     SET msg = concat("Organization: ",requestin->list_0[ii].org_name,
      " has no valid org types selected."," This organization will not be added.")
     CALL logmessage(msg)
    ENDIF
   ENDIF
   SET found = "N"
   SET active = 0
   SELECT INTO "nl:"
    FROM organization o
    PLAN (o
     WHERE o.org_name_key=cnvtupper(cnvtalphanum(requestin->list_0[ii].org_name)))
    DETAIL
     found = "Y", active = o.active_ind
    WITH nocounter
   ;end select
   IF (found="Y")
    SET skip_ind = 1
    IF (active=1)
     SET msg = concat("Organization: ",requestin->list_0[ii].org_name,
      " already present in the system."," This organization will not be added.")
     CALL logmessage(msg)
    ELSE
     SET msg = concat("Organization: ",requestin->list_0[ii].org_name,
      " already present in the system.",
      " It is currently INACTIVE.  This organization will not be added.")
     CALL logmessage(msg)
    ENDIF
   ENDIF
   IF ((requestin->list_0[ii].org_name > " "))
    SET xx = 1
   ELSE
    SET skip_ind = 1
    SET msg = "Organization found without a name - row skipped"
    CALL logmessage(msg)
   ENDIF
   IF ((requestin->list_0[ii].address1 > " "))
    SET xx = 1
   ELSE
    SET skip_ind = 1
    SET msg = concat("Organization: ",requestin->list_0[ii].org_name,
     " does not have a business address."," This organization will not be added.")
    CALL logmessage(msg)
   ENDIF
   IF ((requestin->list_0[ii].phone > " "))
    SET xx = 1
   ELSE
    SET skip_ind = 1
    SET msg = concat("Organization: ",requestin->list_0[ii].org_name,
     " does not have a business phone."," This organization will not be added.")
    CALL logmessage(msg)
   ENDIF
   SET stat = isnumeric(requestin->list_0[ii].phone)
   IF (stat != 1)
    SET skip_ind = 1
    SET msg = concat("Organization: ",requestin->list_0[ii].org_name,
     " does not have a valid numeric business phone."," This organization will not be added.")
    CALL logmessage(msg)
   ENDIF
   IF (skip_ind=0)
    SELECT INTO "nl:"
     y = seq(organization_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      neworgid = cnvtreal(y)
     WITH format, nocounter
    ;end select
    SET add_logical_domain_ind = 0
    IF (data_partition_ind=1
     AND logical_domain_col_exists=1)
     IF ((requestin->list_0[ii].logical_domain_id > " "))
      SET numeric_check = isnumeric(requestin->list_0[ii].logical_domain_id)
      IF (numeric_check > 0)
       SET add_logical_domain_ind = 1
      ENDIF
     ENDIF
    ENDIF
    IF (add_logical_domain_ind=0)
     INSERT  FROM organization o
      SET o.organization_id = neworgid, o.contributor_system_cd = 0, o.org_name = requestin->list_0[
       ii].org_name,
       o.org_name_key = cnvtupper(cnvtalphanum(requestin->list_0[ii].org_name)), o.federal_tax_id_nbr
        = requestin->list_0[ii].tax_id, o.org_status_cd = 0,
       o.ft_entity_id = 0, o.ft_entity_name = "", o.org_class_cd = org_class_cd,
       o.data_status_cd = auth_cd, o.data_status_dt_tm = cnvtdatetime(curdate,curtime3), o
       .data_status_prsnl_id = reqinfo->updt_id,
       o.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), o.end_effective_dt_tm = cnvtdatetime(
        "31-DEC-2100"), o.active_ind = 1,
       o.active_status_cd = active_cd, o.active_status_prsnl_id = reqinfo->updt_id, o
       .active_status_dt_tm = cnvtdatetime(curdate,curtime),
       o.updt_cnt = 0, o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id,
       o.updt_applctx = reqinfo->updt_applctx, o.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
    ELSE
     INSERT  FROM organization o
      SET o.organization_id = neworgid, o.contributor_system_cd = 0, o.org_name = requestin->list_0[
       ii].org_name,
       o.org_name_key = cnvtupper(cnvtalphanum(requestin->list_0[ii].org_name)), o.federal_tax_id_nbr
        = requestin->list_0[ii].tax_id, o.org_status_cd = 0,
       o.ft_entity_id = 0, o.ft_entity_name = "", o.org_class_cd = org_class_cd,
       o.data_status_cd = auth_cd, o.data_status_dt_tm = cnvtdatetime(curdate,curtime3), o
       .data_status_prsnl_id = reqinfo->updt_id,
       o.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), o.end_effective_dt_tm = cnvtdatetime(
        "31-DEC-2100"), o.active_ind = 1,
       o.active_status_cd = active_cd, o.active_status_prsnl_id = reqinfo->updt_id, o
       .active_status_dt_tm = cnvtdatetime(curdate,curtime),
       o.updt_cnt = 0, o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id,
       o.updt_applctx = reqinfo->updt_applctx, o.updt_task = reqinfo->updt_task, o.logical_domain_id
        = cnvtreal(requestin->list_0[ii].logical_domain_id)
      WITH nocounter
     ;end insert
    ENDIF
    IF (curqual=0)
     SET msg = concat("Error inserting org: ",requestin->list_0[ii].org_name,".  Script terminating")
     CALL logmessage(msg)
     SET error_flag = "Y"
     GO TO exit_script
    ENDIF
    SET create_client_type = 0
    IF (new_format_ind=0)
     SET create_client_type = 1
    ELSEIF (new_format_ind=1)
     IF (cnvtupper(requestin->list_0[ii].client) IN ("YES", "Y"))
      SET create_client_type = 1
     ENDIF
    ENDIF
    IF (create_client_type=1)
     INSERT  FROM org_type_reltn otr
      SET otr.organization_id = neworgid, otr.org_type_cd = client_cd, otr.updt_cnt = 0,
       otr.updt_dt_tm = cnvtdatetime(curdate,curtime3), otr.updt_id = reqinfo->updt_id, otr.updt_task
        = reqinfo->updt_task,
       otr.updt_applctx = reqinfo->updt_applctx, otr.active_ind = 1, otr.active_status_cd = active_cd,
       otr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), otr.active_status_prsnl_id = reqinfo
       ->updt_id, otr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       otr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET msg = concat("Error inserting client org type for: ",requestin->list_0[ii].org_name,
       ".  Script terminating")
      CALL logmessage(msg)
      SET error_flag = "Y"
      GO TO exit_script
     ENDIF
    ENDIF
    IF (((cnvtupper(requestin->list_0[ii].employer)="YES") OR (cnvtupper(requestin->list_0[ii].
     employer)="Y")) )
     INSERT  FROM org_type_reltn otr
      SET otr.organization_id = neworgid, otr.org_type_cd = emp_cd, otr.updt_cnt = 0,
       otr.updt_dt_tm = cnvtdatetime(curdate,curtime3), otr.updt_id = reqinfo->updt_id, otr.updt_task
        = reqinfo->updt_task,
       otr.updt_applctx = reqinfo->updt_applctx, otr.active_ind = 1, otr.active_status_cd = active_cd,
       otr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), otr.active_status_prsnl_id = reqinfo
       ->updt_id, otr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       otr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
      WITH nocounter
     ;end insert
    ENDIF
    IF (curqual=0)
     SET msg = concat("Error inserting employer org type for: ",requestin->list_0[ii].org_name,
      ".  Script terminating")
     CALL logmessage(msg)
     SET error_flag = "Y"
     GO TO exit_script
    ENDIF
    IF (new_format_ind=1)
     IF (cnvtupper(requestin->list_0[ii].guarantor) IN ("YES", "Y"))
      INSERT  FROM org_type_reltn otr
       SET otr.organization_id = neworgid, otr.org_type_cd = guarantor_cd, otr.updt_cnt = 0,
        otr.updt_dt_tm = cnvtdatetime(curdate,curtime3), otr.updt_id = reqinfo->updt_id, otr
        .updt_task = reqinfo->updt_task,
        otr.updt_applctx = reqinfo->updt_applctx, otr.active_ind = 1, otr.active_status_cd =
        active_cd,
        otr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), otr.active_status_prsnl_id =
        reqinfo->updt_id, otr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        otr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Error inserting guarantor org type for: ",requestin->list_0[ii].org_name,
        ".  Script terminating")
       CALL logmessage(msg)
       SET error_flag = "Y"
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
    IF (new_format_ind=1)
     IF (cnvtupper(requestin->list_0[ii].followup_facility) IN ("YES", "Y"))
      INSERT  FROM org_type_reltn otr
       SET otr.organization_id = neworgid, otr.org_type_cd = followup_cd, otr.updt_cnt = 0,
        otr.updt_dt_tm = cnvtdatetime(curdate,curtime3), otr.updt_id = reqinfo->updt_id, otr
        .updt_task = reqinfo->updt_task,
        otr.updt_applctx = reqinfo->updt_applctx, otr.active_ind = 1, otr.active_status_cd =
        active_cd,
        otr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), otr.active_status_prsnl_id =
        reqinfo->updt_id, otr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        otr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Error inserting followup facility org type for: ",requestin->list_0[ii].
        org_name,".  Script terminating")
       CALL logmessage(msg)
       SET error_flag = "Y"
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
    IF (new_format_ind=1)
     IF (cnvtupper(requestin->list_0[ii].pharmacy) IN ("YES", "Y"))
      INSERT  FROM org_type_reltn otr
       SET otr.organization_id = neworgid, otr.org_type_cd = pharmacy_cd, otr.updt_cnt = 0,
        otr.updt_dt_tm = cnvtdatetime(curdate,curtime3), otr.updt_id = reqinfo->updt_id, otr
        .updt_task = reqinfo->updt_task,
        otr.updt_applctx = reqinfo->updt_applctx, otr.active_ind = 1, otr.active_status_cd =
        active_cd,
        otr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), otr.active_status_prsnl_id =
        reqinfo->updt_id, otr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        otr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Error inserting pharmacy org type for: ",requestin->list_0[ii].org_name,
        ".  Script terminating")
       CALL logmessage(msg)
       SET error_flag = "Y"
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
    IF (new_format_ind=1)
     IF (cnvtupper(requestin->list_0[ii].collect_agency) IN ("YES", "Y"))
      INSERT  FROM org_type_reltn otr
       SET otr.organization_id = neworgid, otr.org_type_cd = collect_agency_cd, otr.updt_cnt = 0,
        otr.updt_dt_tm = cnvtdatetime(curdate,curtime3), otr.updt_id = reqinfo->updt_id, otr
        .updt_task = reqinfo->updt_task,
        otr.updt_applctx = reqinfo->updt_applctx, otr.active_ind = 1, otr.active_status_cd =
        active_cd,
        otr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), otr.active_status_prsnl_id =
        reqinfo->updt_id, otr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        otr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Error inserting collection agency  org type for: ",requestin->list_0[ii].
        org_name,".  Script terminating")
       CALL logmessage(msg)
       SET error_flag = "Y"
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
    IF (new_format_ind=1)
     IF (cnvtupper(requestin->list_0[ii].pre_collect_agency) IN ("YES", "Y"))
      INSERT  FROM org_type_reltn otr
       SET otr.organization_id = neworgid, otr.org_type_cd = pre_collect_agency_cd, otr.updt_cnt = 0,
        otr.updt_dt_tm = cnvtdatetime(curdate,curtime3), otr.updt_id = reqinfo->updt_id, otr
        .updt_task = reqinfo->updt_task,
        otr.updt_applctx = reqinfo->updt_applctx, otr.active_ind = 1, otr.active_status_cd =
        active_cd,
        otr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), otr.active_status_prsnl_id =
        reqinfo->updt_id, otr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        otr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Error inserting pre collection agency org type for: ",requestin->list_0[ii].
        org_name,".  Script terminating")
       CALL logmessage(msg)
       SET error_flag = "Y"
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
    IF (post_acute_assist_living_col_exists=1)
     IF (cnvtupper(requestin->list_0[ii].post_acute_assist_living) IN ("YES", "Y"))
      INSERT  FROM org_type_reltn otr
       SET otr.organization_id = neworgid, otr.org_type_cd = post_acute_assist_living_cd, otr
        .updt_cnt = 0,
        otr.updt_dt_tm = cnvtdatetime(curdate,curtime3), otr.updt_id = reqinfo->updt_id, otr
        .updt_task = reqinfo->updt_task,
        otr.updt_applctx = reqinfo->updt_applctx, otr.active_ind = 1, otr.active_status_cd =
        active_cd,
        otr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), otr.active_status_prsnl_id =
        reqinfo->updt_id, otr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        otr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Error inserting post acute assisted living org type for: ",requestin->
        list_0[ii].org_name,".  Script terminating")
       CALL logmessage(msg)
       SET error_flag = "Y"
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
    IF (post_acute_hospice_col_exists=1)
     IF (cnvtupper(requestin->list_0[ii].post_acute_hospice) IN ("YES", "Y"))
      INSERT  FROM org_type_reltn otr
       SET otr.organization_id = neworgid, otr.org_type_cd = post_acute_hospice_cd, otr.updt_cnt = 0,
        otr.updt_dt_tm = cnvtdatetime(curdate,curtime3), otr.updt_id = reqinfo->updt_id, otr
        .updt_task = reqinfo->updt_task,
        otr.updt_applctx = reqinfo->updt_applctx, otr.active_ind = 1, otr.active_status_cd =
        active_cd,
        otr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), otr.active_status_prsnl_id =
        reqinfo->updt_id, otr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        otr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Error inserting post acute hospice org type for: ",requestin->list_0[ii].
        org_name,".  Script terminating")
       CALL logmessage(msg)
       SET error_flag = "Y"
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
    IF (post_acute_hospital_col_exists=1)
     IF (cnvtupper(requestin->list_0[ii].post_acute_hospital) IN ("YES", "Y"))
      INSERT  FROM org_type_reltn otr
       SET otr.organization_id = neworgid, otr.org_type_cd = post_acute_hospital_cd, otr.updt_cnt = 0,
        otr.updt_dt_tm = cnvtdatetime(curdate,curtime3), otr.updt_id = reqinfo->updt_id, otr
        .updt_task = reqinfo->updt_task,
        otr.updt_applctx = reqinfo->updt_applctx, otr.active_ind = 1, otr.active_status_cd =
        active_cd,
        otr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), otr.active_status_prsnl_id =
        reqinfo->updt_id, otr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        otr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Error inserting post acute hospital org type for: ",requestin->list_0[ii].
        org_name,".  Script terminating")
       CALL logmessage(msg)
       SET error_flag = "Y"
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
    IF (post_acute_long_term_care_col_exists=1)
     IF (cnvtupper(requestin->list_0[ii].post_acute_long_term_care) IN ("YES", "Y"))
      INSERT  FROM org_type_reltn otr
       SET otr.organization_id = neworgid, otr.org_type_cd = post_acute_long_term_care_cd, otr
        .updt_cnt = 0,
        otr.updt_dt_tm = cnvtdatetime(curdate,curtime3), otr.updt_id = reqinfo->updt_id, otr
        .updt_task = reqinfo->updt_task,
        otr.updt_applctx = reqinfo->updt_applctx, otr.active_ind = 1, otr.active_status_cd =
        active_cd,
        otr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), otr.active_status_prsnl_id =
        reqinfo->updt_id, otr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        otr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Error inserting post acute long term acute care org type for: ",requestin->
        list_0[ii].org_name,".  Script terminating")
       CALL logmessage(msg)
       SET error_flag = "Y"
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
    IF (post_acute_rehab_hospital_col_exists=1)
     IF (cnvtupper(requestin->list_0[ii].post_acute_rehab_hospital) IN ("YES", "Y"))
      INSERT  FROM org_type_reltn otr
       SET otr.organization_id = neworgid, otr.org_type_cd = post_acute_rehab_hospital_cd, otr
        .updt_cnt = 0,
        otr.updt_dt_tm = cnvtdatetime(curdate,curtime3), otr.updt_id = reqinfo->updt_id, otr
        .updt_task = reqinfo->updt_task,
        otr.updt_applctx = reqinfo->updt_applctx, otr.active_ind = 1, otr.active_status_cd =
        active_cd,
        otr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), otr.active_status_prsnl_id =
        reqinfo->updt_id, otr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        otr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Error inserting post acute rehabilitation hospital org type for: ",requestin
        ->list_0[ii].org_name,".  Script terminating")
       CALL logmessage(msg)
       SET error_flag = "Y"
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
    IF (post_acute_skilled_nursing_col_exists=1)
     IF (cnvtupper(requestin->list_0[ii].post_acute_skilled_nursing) IN ("YES", "Y"))
      INSERT  FROM org_type_reltn otr
       SET otr.organization_id = neworgid, otr.org_type_cd = post_acute_skilled_nursing_cd, otr
        .updt_cnt = 0,
        otr.updt_dt_tm = cnvtdatetime(curdate,curtime3), otr.updt_id = reqinfo->updt_id, otr
        .updt_task = reqinfo->updt_task,
        otr.updt_applctx = reqinfo->updt_applctx, otr.active_ind = 1, otr.active_status_cd =
        active_cd,
        otr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), otr.active_status_prsnl_id =
        reqinfo->updt_id, otr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        otr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Error inserting post acute skilled nursing org type for: ",requestin->
        list_0[ii].org_name,".  Script terminating")
       CALL logmessage(msg)
       SET error_flag = "Y"
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
    IF (post_acute_services_col_exists=1)
     IF (cnvtupper(requestin->list_0[ii].post_acute_services) IN ("YES", "Y"))
      INSERT  FROM org_type_reltn otr
       SET otr.organization_id = neworgid, otr.org_type_cd = post_acute_services_cd, otr.updt_cnt = 0,
        otr.updt_dt_tm = cnvtdatetime(curdate,curtime3), otr.updt_id = reqinfo->updt_id, otr
        .updt_task = reqinfo->updt_task,
        otr.updt_applctx = reqinfo->updt_applctx, otr.active_ind = 1, otr.active_status_cd =
        active_cd,
        otr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), otr.active_status_prsnl_id =
        reqinfo->updt_id, otr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        otr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Error inserting post acute services org type for: ",requestin->list_0[ii].
        org_name,".  Script terminating")
       CALL logmessage(msg)
       SET error_flag = "Y"
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     FROM code_value cv
     PLAN (cv
      WHERE cv.display_key=cnvtupper(cnvtalphanum(requestin->list_0[ii].state))
       AND cv.code_set=62
       AND cv.active_ind=1)
     DETAIL
      state_cd = cv.code_value
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET state_cd = 0.0
    ENDIF
    SELECT INTO "nl:"
     FROM code_value cv
     PLAN (cv
      WHERE cv.display_key=cnvtupper(cnvtalphanum(requestin->list_0[ii].county))
       AND cv.code_set=74
       AND cv.active_ind=1)
     DETAIL
      county_cd = cv.code_value
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET county_cd = 0.0
    ENDIF
    SELECT INTO "nl:"
     FROM code_value cv
     PLAN (cv
      WHERE cv.display_key=cnvtupper(cnvtalphanum(requestin->list_0[ii].country))
       AND cv.code_set=15
       AND cv.active_ind=1)
     DETAIL
      country_cd = cv.code_value
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET country_cd = 0.0
    ENDIF
    IF (address3_col_exists=1)
     SET addr3 = requestin->list_0[ii].address3
    ELSE
     SET addr3 = " "
    ENDIF
    IF (address4_col_exists=1)
     SET addr4 = requestin->list_0[ii].address4
    ELSE
     SET addr4 = " "
    ENDIF
    INSERT  FROM address a
     SET a.address_id = seq(address_seq,nextval), a.parent_entity_name = "ORGANIZATION", a
      .parent_entity_id = neworgid,
      a.address_type_cd = bus_addr_cd, a.active_ind = 1, a.residence_type_cd = 0.00,
      a.street_addr = requestin->list_0[ii].address1, a.street_addr2 = requestin->list_0[ii].address2,
      a.street_addr3 = addr3,
      a.street_addr4 = addr4, a.city = requestin->list_0[ii].city, a.state = requestin->list_0[ii].
      state,
      a.state_cd = state_cd, a.zipcode = requestin->list_0[ii].zip, a.zip_code_group_cd = 0.00,
      a.county = requestin->list_0[ii].county, a.county_cd = county_cd, a.country = requestin->
      list_0[ii].country,
      a.country_cd = country_cd, a.residence_cd = 0.00, a.long_text_id = 0.00,
      a.address_info_status_cd = 0.00, a.primary_care_cd = 0.00, a.district_health_cd = 0.00,
      a.zipcode_key = trim(cnvtupper(cnvtalphanum(requestin->list_0[ii].zip))), a.active_status_cd =
      active_cd, a.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
      a.active_status_prsnl_id = reqinfo->updt_id, a.beg_effective_dt_tm = cnvtdatetime(curdate,
       curtime3), a.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"),
      a.data_status_cd = auth_cd, a.data_status_dt_tm = cnvtdatetime(curdate,curtime3), a
      .data_status_prsnl_id = reqinfo->updt_id,
      a.contributor_system_cd = 0.00, a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id =
      reqinfo->updt_id,
      a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->updt_applctx, a.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET msg = concat("Error inserting address for: ",requestin->list_0[ii].org_name,
      ".  Script terminating")
     CALL logmessage(msg)
     SET error_flag = "Y"
     GO TO exit_script
    ENDIF
    INSERT  FROM phone p
     SET p.phone_id = seq(phone_seq,nextval), p.parent_entity_name = "ORGANIZATION", p
      .parent_entity_id = neworgid,
      p.phone_type_cd = bus_phone_cd, p.phone_format_cd = freetext_cd, p.phone_num = requestin->
      list_0[ii].phone,
      p.phone_num_key = cnvtupper(cnvtalphanum(requestin->list_0[ii].phone)), p.phone_type_seq = 1, p
      .modem_capability_cd = 0.00,
      p.extension = requestin->list_0[ii].extension, p.long_text_id = 0.00, p.active_ind = 1,
      p.active_status_cd = active_cd, p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p
      .active_status_prsnl_id = reqinfo->updt_id,
      p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.end_effective_dt_tm = cnvtdatetime(
       "31-dec-2100 00:00:00"), p.data_status_cd = auth_cd,
      p.data_status_dt_tm = cnvtdatetime(curdate,curtime3), p.data_status_prsnl_id = reqinfo->updt_id,
      p.contributor_system_cd = 0.00,
      p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_task =
      reqinfo->updt_task,
      p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET msg = concat("Error inserting phone for: ",requestin->list_0[ii].org_name,
      ".  Script terminating")
     CALL logmessage(msg)
     SET error_flag = "Y"
     GO TO exit_script
    ENDIF
    IF ((requestin->list_0[ii].fax > " "))
     INSERT  FROM phone p
      SET p.phone_id = seq(phone_seq,nextval), p.parent_entity_name = "ORGANIZATION", p
       .parent_entity_id = neworgid,
       p.phone_type_cd = fax_phone_cd, p.phone_format_cd = freetext_cd, p.phone_num = requestin->
       list_0[ii].fax,
       p.phone_num_key = cnvtupper(cnvtalphanum(requestin->list_0[ii].fax)), p.phone_type_seq = 1, p
       .modem_capability_cd = 0.00,
       p.extension = "", p.long_text_id = 0.00, p.active_ind = 1,
       p.active_status_cd = active_cd, p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p
       .active_status_prsnl_id = reqinfo->updt_id,
       p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.end_effective_dt_tm = cnvtdatetime(
        "31-dec-2100 00:00:00"), p.data_status_cd = auth_cd,
       p.data_status_dt_tm = cnvtdatetime(curdate,curtime3), p.data_status_prsnl_id = reqinfo->
       updt_id, p.contributor_system_cd = 0.00,
       p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_task =
       reqinfo->updt_task,
       p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET msg = concat("Error inserting fax phone for: ",requestin->list_0[ii].org_name,
       ".  Script terminating")
      CALL logmessage(msg)
      SET error_flag = "Y"
      GO TO exit_script
     ENDIF
    ENDIF
    SET msg = concat("Organization: ",requestin->list_0[ii].org_name," successfully added.")
    CALL logmessage(msg)
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Import program failed.  Check log file for details."
  SET reqinfo->commit_ind = 0
 ENDIF
 SUBROUTINE logmessage(msg)
   SELECT INTO "ccluserdir:bed_imp_client_org.log"
    rvar
    DETAIL
     row + 1, col 0, msg
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 132, maxrow = 1
   ;end select
 END ;Subroutine
END GO
