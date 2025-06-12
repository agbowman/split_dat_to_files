CREATE PROGRAM aps_oe_fmtflds_getdetail:dba
 SET oe_x = 0
 SET oe_format_info->fldqual_idx = 0
 IF ((oe_format_info->qual_idx > 0)
  AND (oe_format_info->qual_idx <= size(oe_format_info->qual,5)))
  FOR (oe_x = 1 TO oe_format_info->qual[oe_format_info->qual_idx].fldqual_cnt)
    IF ((oe_format_info->qual[oe_format_info->qual_idx].fldqual[oe_x].oe_field_meaning_id=
    oe_format_info->oe_field_meaning_id))
     SET oe_format_info->fldqual_idx = oe_x
     SET oe_x = oe_format_info->qual[oe_format_info->qual_idx].fldqual_cnt
    ENDIF
  ENDFOR
 ENDIF
END GO
