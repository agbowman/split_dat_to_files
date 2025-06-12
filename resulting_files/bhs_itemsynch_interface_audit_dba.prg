CREATE PROGRAM bhs_itemsynch_interface_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "CURDATE",
  "Stop Date" = "CURDATE"
  WITH outdev, ms_beg_dt, ms_end_dt
 SELECT DISTINCT INTO  $OUTDEV
  mlog.updt_dt_tm, updt_tm = mlog.updt_dt_tm"@TIMENOSECONDS", m_interface_type_disp =
  uar_get_code_display(mlog.interface_type_cd),
  error_id = mlog.error_id, m_error_disp = uar_get_code_display(mlog.error_cd), interf_type = mlog
  .field_name,
  error_msg = mlog.msg, xi_item_id = mxi.item_nbr, xi_item_desc = mxi.item_desc,
  mxi.charge_number_txt, mxi.upn, xiloc_item_id = mxiloc.item_identifier,
  xiloc_item_location = mxiloc.location, xibin_item_id = mxibin.item_identifier, xibin_item_location
   = mxibin.location,
  xibin_item_locator = mxibin.locator, xic_item_id = mxic.item_identifier, xic_item_cost = mxic.cost
  FROM mm_xf_error_log mlog,
   mm_xfi_item mxi,
   mm_xfi_itemloc mxiloc,
   mm_xfi_locator mxibin,
   mm_xfi_cost mxic
  PLAN (mlog
   WHERE mlog.updt_dt_tm BETWEEN cnvtdatetime(cnvtdate2( $MS_BEG_DT,"mm/dd/yyyy"),0) AND cnvtdatetime
   (cnvtdate2( $MS_END_DT,"mm/dd/yyyy"),235959))
   JOIN (mxi
   WHERE mxi.transaction_id=outerjoin(mlog.parent_entity_id))
   JOIN (mxiloc
   WHERE mxiloc.transaction_id=outerjoin(mlog.parent_entity_id))
   JOIN (mxibin
   WHERE mxibin.transaction_id=outerjoin(mlog.parent_entity_id))
   JOIN (mxic
   WHERE mxic.transaction_id=outerjoin(mlog.parent_entity_id))
  ORDER BY mlog.updt_dt_tm
  WITH nocounter, separator = " ", format
 ;end select
#exit_program
END GO
