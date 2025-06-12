CREATE PROGRAM bed_imp_other_names:dba
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
 DECLARE error_msg = vc
 SET error_flag = "N"
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
    SET error_flag = "Y"
    SET error_msg = concat("The alias field must be defined for ",trim(requestin->list_0[x].
      primary_name),".")
    GO TO exit_script
   ENDIF
   IF (trim(requestin->list_0[x].alias_name)=trim(requestin->list_0[x].primary_name))
    SET error_flag = "Y"
    SET error_msg = concat("The alias field must not equal the primary name field for ",trim(
      requestin->list_0[x].primary_name),".")
    GO TO exit_script
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
      WHERE b.parent_entity_name="BR_AUTO_ORDER_CATALOG"
       AND b.alias_name_key_cap=cnvtupper(requestin->list_0[x].alias_name)
      DETAIL
       skip_ind = 1
      WITH nocounter
     ;end select
    ENDIF
   ELSE
    SET error_flag = "Y"
    SET error_msg = concat("Unable to find the Millennium ",trim(requestin->list_0[x].primary_name),
     " therefore unable to alias.")
    GO TO exit_script
   ENDIF
   IF (skip_ind > 0)
    CALL echo(build("skipping orderable = ",trim(requestin->list_0[x].alias_name)))
   ELSE
    INSERT  FROM br_other_names b
     SET b.parent_entity_name = "CODE_VALUE", b.parent_entity_id = parent_entity_id, b.alias_name =
      trim(requestin->list_0[x].alias_name),
      b.alias_name_key_cap = cnvtupper(requestin->list_0[x].alias_name), b.updt_dt_tm = cnvtdatetime(
       curdate,curtime3)
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to insert ",trim(requestin->list_0[x].alias_name),
      " into the br_other_names table.")
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  CALL echo(error_msg)
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_IMP_OTHER_NAMES","  >> ERROR MSG: ",error_msg
   )
  SET reqinfo->commit_ind = 0
  CALL echo(error_msg)
 ENDIF
 CALL echorecord(reply)
END GO
