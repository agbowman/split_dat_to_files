CREATE PROGRAM ayb_oef_extract:dba
 PROMPT
  "File/Printer/MINE: " = "MINE"
 DECLARE accept_type(ival=i2) = c20
 DECLARE field_type(ival=i2) = c20
 DECLARE flex_type(ival=i2) = c20
 DECLARE pharmcd = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 SELECT INTO  $1
  format_name = trim(oef.oe_format_name), action_type = trim(uar_get_code_display(oef.action_type_cd)
   ), field_label = trim(off.label_text),
  field_description = trim(fld.description), accept_type = accept_type(off.accept_flag), field_type
   = field_type(fld.field_type_flag),
  field_meaning = trim(om.description), fld.codeset, default_value =
  IF (fld.codeset > 0
   AND off.default_parent_entity_id > 0) uar_get_code_display(off.default_parent_entity_id)
  ELSEIF (fld.field_type_flag=7) evaluate(off.default_value,"1","Yes","0","No")
  ELSE off.default_value
  ENDIF
  ,
  lock_on_modify = evaluate(off.lock_on_modify_flag,1,"Yes",0,"No"), carry_forward_plan = evaluate(
   off.carry_fwd_plan_ind,1,"Yes",0,"No"), off.value_required_ind,
  off.require_review_ind, off.require_cosign_ind, off.require_verify_ind,
  off.clin_line_ind, clin_line_label = trim(off.clin_line_label), off.clin_suffix_ind,
  off.group_seq, off.field_seq, catalog_type = trim(uar_get_code_display(oef.catalog_type_cd)),
  ref_oe_format_id = off.oe_format_id, ref_oe_field_id = off.oe_field_id, ref_oe_field_meaning_id =
  om.oe_field_meaning_id,
  ref_oe_action_type_cd = off.action_type_cd, core_ind = off.core_ind, flex_type = flex_type(aff
   .flex_type_flag),
  flex_type_value = uar_get_code_display(aff.flex_cd), flex_accept_type = accept_type(aff.accept_flag
   ), flex_default =
  IF (fld.codeset > 0
   AND aff.default_parent_entity_id > 0) uar_get_code_display(aff.default_parent_entity_id)
  ELSEIF (fld.field_type_flag=7)
   IF (aff.default_value="1") "Yes"
   ELSE "No"
   ENDIF
  ELSE aff.default_value
  ENDIF
  FROM order_entry_format oef,
   order_entry_fields fld,
   oe_field_meaning om,
   oe_format_fields off,
   accept_format_flexing aff,
   dummyt d1,
   dummyt d2
  PLAN (oef
   WHERE oef.catalog_type_cd=pharmcd)
   JOIN (d1)
   JOIN (off
   WHERE off.oe_format_id=oef.oe_format_id
    AND off.action_type_cd=oef.action_type_cd)
   JOIN (fld
   WHERE fld.oe_field_id=off.oe_field_id)
   JOIN (om
   WHERE om.oe_field_meaning_id=fld.oe_field_meaning_id)
   JOIN (d2)
   JOIN (aff
   WHERE aff.oe_format_id=off.oe_format_id
    AND aff.oe_field_id=off.oe_field_id)
  ORDER BY catalog_type, format_name, action_type,
   off.group_seq, off.field_seq
  WITH dontcare = off, outerjoin = d2, separator = " ",
   format
 ;end select
 SUBROUTINE field_type(ival)
  CASE (ival)
   OF 0:
    SET field_type = "Alphanumeric"
   OF 1:
    SET field_type = "Integer"
   OF 2:
    SET field_type = "Decimal"
   OF 3:
    SET field_type = "Date"
   OF 5:
    SET field_type = "Date/Time"
   OF 6:
    SET field_type = "Code Set"
   OF 7:
    SET field_type = "Yes/No"
   OF 8:
    SET field_type = "Provider"
   OF 9:
    SET field_type = "Location"
   OF 10:
    SET field_type = "ICD9"
   OF 11:
    SET field_type = "Printer"
   OF 12:
    SET field_type = "List"
   OF 13:
    SET field_type = "Personnel"
   OF 14:
    SET field_type = "Accession"
   OF 15:
    SET field_type = "Surgical Duration"
  ENDCASE
  RETURN(field_type)
 END ;Subroutine
 SUBROUTINE accept_type(ival)
  CASE (ival)
   OF 0:
    SET accept_type = "Required"
   OF 1:
    SET accept_type = "Optional"
   OF 2:
    SET accept_type = "Do Not Display"
   OF 3:
    SET accept_type = "Display Only"
  ENDCASE
  RETURN(accept_type)
 END ;Subroutine
 SUBROUTINE flex_type(ival)
  CASE (ival)
   OF 0:
    SET flex_type = "Ordering Location"
   OF 1:
    SET flex_type = "Patient Location"
   OF 2:
    SET flex_type = "Application"
   OF 3:
    SET flex_type = "Position"
   OF 4:
    SET flex_type = "Encounter Type"
  ENDCASE
  RETURN(flex_type)
 END ;Subroutine
END GO
