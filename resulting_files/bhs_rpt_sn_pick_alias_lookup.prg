CREATE PROGRAM bhs_rpt_sn_pick_alias_lookup
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Pick Location" = "*",
  "Pick Location Alias" = "*"
  WITH outdev, ms_pickloc, ms_alias
 SELECT DISTINCT INTO  $OUTDEV
  surgical_area = uar_get_code_display(l.parent_loc_cd), pick_location = cv1.description,
  lawson_in_alias = cva.alias,
  lawson_out_alias = cvo.alias
  FROM code_value cv1,
   code_value_alias cva,
   code_value_outbound cvo,
   location_group l
  PLAN (cv1
   WHERE cv1.code_set=220
    AND cv1.cdf_meaning="INVLOC"
    AND cnvtupper(cv1.description)=concat(cnvtupper( $MS_PICKLOC),"*"))
   JOIN (cva
   WHERE cva.code_value=outerjoin(cv1.code_value)
    AND cnvtupper(cva.alias)=outerjoin( $MS_ALIAS))
   JOIN (cvo
   WHERE cvo.code_value=outerjoin(cv1.code_value))
   JOIN (l
   WHERE l.child_loc_cd=cv1.code_value)
  ORDER BY surgical_area, pick_location, lawson_in_alias
  WITH nocounter, separator = " ", format
 ;end select
#exit_script
END GO
