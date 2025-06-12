CREATE PROGRAM aps_oe_fmtflds_getcatalog:dba
 SET nbr_of_items = cnvtint(size(oe_format_info->qual,5))
 SET oe_x = 0
 SET oe_format_info->qual_idx = 0
 SET oe_format_info->fldqual_idx = 0
 FOR (oe_x = 1 TO nbr_of_items)
   IF ((oe_format_info->qual[oe_x].catalog_cd=oe_format_info->catalog_cd)
    AND (oe_format_info->qual[oe_x].action_type_cd=oe_format_info->action_type_cd))
    SET oe_format_info->qual_idx = oe_x
    SET oe_x = nbr_of_items
   ENDIF
 ENDFOR
END GO
