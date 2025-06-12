CREATE PROGRAM br_other_names_config:dba
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
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting <br_other_names_config.prg> script"
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 SET alias_cnt = size(requestin->list_0,5)
 SET skip_ind = 0
 SET dcp_code_value = 0.0
 SET ancillary_code_value = 0.0
 SET primary_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6011
   AND cv.active_ind=1
   AND cv.cdf_meaning IN ("DCP", "ANCILLARY")
  DETAIL
   CASE (cv.cdf_meaning)
    OF "DCP":
     dcp_code_value = cv.code_value
    OF "ANCILLARY":
     ancillary_code_value = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 FOR (x = 1 TO alias_cnt)
   SET parent_entity_id = 0.0
   SET parent_entity_name = fillstring(32," ")
   SET skip_ind = 0
   IF ((requestin->list_0[x].alias_name="      *"))
    SET errmsg = concat("The alias field must be defined for ",trim(requestin->list_0[x].primary_name
      ),".")
   ENDIF
   IF (trim(requestin->list_0[x].alias_name)=trim(requestin->list_0[x].primary_name))
    SET skip_ind = 1
   ENDIF
   SELECT INTO "NL:"
    FROM br_auto_order_catalog b
    WHERE (b.concept_cki=requestin->list_0[x].concept_cki)
    DETAIL
     parent_entity_id = b.catalog_cd, parent_entity_name = "BR_AUTO_ORDER_CATALOG"
    WITH nocounter
   ;end select
   IF (parent_entity_id > 0)
    SELECT INTO "NL:"
     FROM br_auto_oc_synonym ocs
     WHERE ocs.catalog_cd=parent_entity_id
      AND ocs.mnemonic_key_cap=cnvtupper(requestin->list_0[x].alias_name)
      AND ((ocs.mnemonic_type_cd=dcp_code_value) OR (((ocs.mnemonic_type_cd=primary_code_value) OR (
     ocs.mnemonic_type_cd=ancillary_code_value)) ))
     DETAIL
      skip_ind = 1
     WITH nocounter
    ;end select
    IF (skip_ind=0)
     SELECT INTO "NL:"
      FROM br_other_names b
      WHERE ((b.parent_entity_name="BR_AUTO_ORDER_CATALOG") OR (b.parent_entity_name="CODE_VALUE"))
       AND b.parent_entity_id=parent_entity_id
       AND b.alias_name_key_cap=cnvtupper(requestin->list_0[x].alias_name)
      DETAIL
       skip_ind = 1
      WITH nocounter
     ;end select
    ENDIF
   ELSE
    SET skip_ind = 1
   ENDIF
   IF (skip_ind > 0)
    SET skip_ind = 0
   ELSE
    INSERT  FROM br_other_names b
     SET b.parent_entity_name = "CODE_VALUE", b.parent_entity_id = parent_entity_id, b.alias_name =
      trim(requestin->list_0[x].alias_name),
      b.alias_name_key_cap = cnvtupper(requestin->list_0[x].alias_name), b.updt_dt_tm = cnvtdatetime(
       curdate,curtime3)
     WITH nocounter
    ;end insert
    SET errcode = error(errmsg,0)
    IF (errcode > 0)
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat("Readme Failed: Inserting into br_other_names: ",errmsg)
     GO TO exit_script
    ELSE
     COMMIT
    ENDIF
   ENDIF
 ENDFOR
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_other_names_config.prg> script"
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
