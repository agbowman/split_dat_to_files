CREATE PROGRAM ap_setup_spec_order:dba
 PROMPT
  "OE Field Display: " = "Additional Specimen Description",
  "Inactivate (Y/N): " = "N"
  WITH oefielddisplay, inactivate
 DECLARE oefieldid = f8 WITH noconstant(0.0)
 DECLARE fieldyn = c1
 DECLARE inactivate = c1
 DECLARE dm_row_present = c1
 DECLARE seq = f8
 DECLARE request_present = c1
 SELECT INTO "nl:"
  FROM order_entry_fields oef
  WHERE oef.oe_field_meaning_id=9000
   AND (oef.description= $OEFIELDDISPLAY)
  DETAIL
   oefieldid = oef.oe_field_id
   IF (oefieldid > 0)
    fieldyn = "Y", inactivate =  $INACTIVATE
   ENDIF
  WITH nocounter
 ;end select
 IF (fieldyn="Y")
  SELECT INTO "n1:"
   FROM dm_info di
   WHERE di.info_domain="ANATOMIC PATHOLOGY"
    AND di.info_name="ADDITIONAL SPECIMEN FIELD"
   DETAIL
    dm_row_present = "Y"
   WITH nocounter
  ;end select
  IF (inactivate="Y")
   IF (dm_row_present="Y")
    DELETE  FROM dm_info di
     WHERE di.info_domain="ANATOMIC PATHOLOGY"
      AND di.info_name="ADDITIONAL SPECIMEN FIELD"
    ;end delete
   ENDIF
   UPDATE  FROM request_processing
    SET active_ind = 0
    WHERE request_number=560201
     AND format_script="PFMT_AP_EXPLODE_SPEC_ORDER"
    WITH nocounter
   ;end update
  ELSE
   IF (inactivate="N")
    IF (dm_row_present=" ")
     INSERT  FROM dm_info
      SET info_number = oefieldid, info_domain = "ANATOMIC PATHOLOGY", info_name =
       "ADDITIONAL SPECIMEN FIELD"
      WHERE oefieldid > 0
     ;end insert
    ENDIF
    DECLARE nmaxstepcnt = i4 WITH noconstant(0)
    SELECT INTO "nl:"
     FROM request_processing rp
     PLAN (rp
      WHERE rp.request_number=560201)
     DETAIL
      nmaxstepcnt = maxval(nmaxstepcnt,rp.sequence)
      IF (rp.format_script="PFMT_AP_EXPLODE_SPEC_ORDER")
       request_present = "Y"
      ENDIF
     WITH nocounter
    ;end select
    IF (request_present="Y")
     UPDATE  FROM request_processing rp
      SET rp.active_ind = 1, destination_step_id = 560201, reprocess_reply_ind = 0
      WHERE rp.request_number=560201
       AND rp.format_script="PFMT_AP_EXPLODE_SPEC_ORDER"
     ;end update
    ELSE
     INSERT  FROM request_processing
      SET request_number = 560201, sequence = (nmaxstepcnt+ 1), format_script =
       "PFMT_AP_EXPLODE_SPEC_ORDER",
       destination_step_id = 560201, reprocess_reply_ind = 0, active_ind = 1
      WHERE nmaxstepcnt > 0
     ;end insert
    ENDIF
   ENDIF
  ENDIF
  COMMIT
  CALL echo(">>>Changes made to AP specimen order processing. Please cycle server entry 55.")
 ELSE
  CALL echo(">>>WARNING: OEF Field not found!")
 ENDIF
END GO
