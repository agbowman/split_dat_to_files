CREATE PROGRAM bhs_rpt_sn_locator_lookup:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Pick location" = "*",
  "Pick locator" = "*"
  WITH outdev, ms_loc, ms_locator
 DECLARE mf_invloc_cd = f8 WITH constant(uar_get_code_by("MEANING",222,"INVLOC")), protect
 SELECT DISTINCT INTO  $OUTDEV
  pick_location = uar_get_code_display(l.parent_loc_cd), locator = uar_get_code_display(l
   .child_loc_cd), sequence = l.sequence
  FROM location_group l
  WHERE l.location_group_type_cd=mf_invloc_cd
   AND (l.parent_loc_cd=
  (SELECT
   code_value
   FROM code_value
   WHERE code_set=220
    AND (cnvtupper(description)= $MS_LOC)))
   AND (l.child_loc_cd=
  (SELECT
   code_value
   FROM code_value
   WHERE code_set=220
    AND (cnvtupper(description)= $MS_LOCATOR)))
  ORDER BY pick_location, locator, sequence
  WITH nocounter, separator = " ", format
 ;end select
#exit_script
END GO
