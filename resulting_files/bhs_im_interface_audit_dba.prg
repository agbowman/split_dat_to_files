CREATE PROGRAM bhs_im_interface_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "CURDATE",
  "Stop Date" = "CURDATE",
  "Action Flag" = 0
  WITH outdev, ms_start_date, ms_stop_date,
  mi_list_value
 DECLARE ms_updt_clause = vc WITH protect, noconstant("")
 IF (( $MI_LIST_VALUE=1))
  SET ms_updt_clause = " moim.updt_cnt in (0,1)"
 ELSEIF (( $MI_LIST_VALUE=2))
  SET ms_updt_clause = " moim.updt_cnt > 1"
 ELSE
  SET ms_updt_clause = " 1=1"
 ENDIF
 SELECT DISTINCT INTO  $OUTDEV
  mm.transaction_id, date = mm.updt_dt_tm, time = mm.updt_dt_tm"@TIMENOSECONDS",
  status = evaluate(moim.updt_cnt,0,"NEW","UPDATE"), updt_count = moim.updt_cnt, orig_date = moim
  .create_dt_tm,
  item_number = mm.item_nbr, item_description = mm.item_desc, manufacturer = mm.mfr,
  mfg_cat_nbr = mm.mfr_item_nbr, mm.charge_number_txt, mm.upn,
  location = uar_get_code_display(mi.location_cd), locator = uar_get_code_display(ml.locator_cd),
  item_cost = mc.cost
  FROM mm_xfi_item mm,
   mm_xfi_cost mc,
   mm_xfi_locator ml,
   mm_xfi_itemloc mi,
   mm_omf_item_master moim
  PLAN (mm
   WHERE mm.updt_dt_tm BETWEEN cnvtdatetime(cnvtdate2( $MS_START_DATE,"mm/dd/yyyy"),0) AND
   cnvtdatetime(cnvtdate2( $MS_STOP_DATE,"mm/dd/yyyy"),235959))
   JOIN (mc
   WHERE mc.item_identifier=outerjoin(mm.item_identifier))
   JOIN (ml
   WHERE ml.item_identifier=outerjoin(mm.item_identifier))
   JOIN (mi
   WHERE mi.item_identifier=outerjoin(mm.item_identifier))
   JOIN (moim
   WHERE moim.item_master_id=mm.item_master_id
    AND parser(ms_updt_clause))
  ORDER BY date, status, moim.updt_cnt
  WITH nocounter, separator = " ", format
 ;end select
#exit_program
END GO
