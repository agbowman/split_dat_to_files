CREATE PROGRAM bhs_oef_flexing_audit:dba
 PROMPT
  "Output to File/Printer/MINE/Email" = "MINE",
  "Select Order Entry Format" = 0
  WITH outdev, f_oe_format_id
 DECLARE mn_email_ind = i2 WITH protect, noconstant(0)
 DECLARE ms_output_dest = vc WITH protect, noconstant(" ")
 DECLARE md_filename_out = vc WITH protect, noconstant(" ")
 IF (findstring("@", $OUTDEV) > 0)
  SET mn_email_ind = 1
  SET ms_output_dest = trim(concat(trim(cnvtlower(curprog)),format(cnvtdatetime(sysdate),
     "MMDDYYYYHHMMSS;;D"),".csv"))
 ELSE
  SET mn_email_ind = 0
  SET ms_output_dest =  $OUTDEV
 ENDIF
 SELECT
  IF (mn_email_ind=1)
   WITH format, format = stream, pcformat('"',",",1),
    nocounter
  ELSE
  ENDIF
  INTO value(ms_output_dest)
  oef.oe_format_id, format_name = trim(oef.oe_format_name,3), action_type = trim(uar_get_code_display
   (oef.action_type_cd),3),
  field.oe_field_id, field_description = trim(field.description,3), flex_type =
  IF (aff.flex_type_flag=0) "Ordering Location"
  ELSEIF (aff.flex_type_flag=1) "Patient Location"
  ELSEIF (aff.flex_type_flag=2) "Application"
  ELSEIF (aff.flex_type_flag=3) "Position"
  ELSEIF (aff.flex_type_flag=4) "Encounter Type"
  ENDIF
  ,
  flex_value = trim(uar_get_code_display(aff.flex_cd),3), accept_flag =
  IF (aff.accept_flag=0) "Required"
  ELSEIF (aff.accept_flag=1) "Optional"
  ELSEIF (aff.accept_flag=2) "No Display"
  ELSEIF (aff.accept_flag=3) "Display Only"
  ELSE "Unknown"
  ENDIF
  , default_value =
  IF (aff.default_value > " ") trim(aff.default_value,3)
  ELSE trim(cnvtstring(aff.default_parent_entity_id),3)
  ENDIF
  ,
  default_value_display = trim(uar_get_code_display(aff.default_parent_entity_id),3)
  FROM order_entry_format oef,
   dummyt d1,
   accept_format_flexing aff,
   order_entry_fields field
  PLAN (oef
   WHERE (oef.oe_format_id= $F_OE_FORMAT_ID))
   JOIN (d1)
   JOIN (aff
   WHERE aff.oe_format_id=oef.oe_format_id
    AND aff.action_type_cd=oef.action_type_cd)
   JOIN (field
   WHERE field.oe_field_id=aff.oe_field_id)
  ORDER BY oef.oe_format_name, oef.action_type_cd, flex_type,
   flex_value
  WITH outerjoin = d1, format, separator = " ",
   nocounter
 ;end select
 IF (mn_email_ind=1)
  SET ms_filename_out = concat("OEF_Flexing_Audit_",format(curdate,"YYYYMMDD;;D"),".csv")
  EXECUTE bhs_ma_email_file
  CALL emailfile(ms_output_dest,ms_filename_out, $OUTDEV,"Baystate Medical Center OEF Flexing Audit",
   1)
 ENDIF
#exit_script
END GO
