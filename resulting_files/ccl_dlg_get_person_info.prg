CREATE PROGRAM ccl_dlg_get_person_info
 PROMPT
  "Output to File/Printer/MIN" = "MINE",
  "Name" = "",
  "Persons" = 0,
  "Encounter" = 0,
  "Report Type" = "",
  "Start Date" = "SYSDATE",
  "End Date" = "SYSDATE"
  WITH outdev, prsname, prsn,
  enc, info, startdt,
  enddt, rptdetails
 DECLARE printlabresults(prtto) = i2 WITH public
 DECLARE printorders(prtto) = i2 WITH public
 CASE ( $INFO)
  OF "GetEncOrderList":
   CALL printorders( $OUTDEV)
  OF "GetEventSet":
   CALL printlabresults( $OUTDEV)
 ENDCASE
 RETURN
 SUBROUTINE printlabresults(prtto)
   SELECT INTO  $OUTDEV
    c.encntr_id, c_event_disp = uar_get_code_display(c.event_cd), c_task_assay_disp =
    uar_get_code_display(c.task_assay_cd),
    c_normalcy_disp = uar_get_code_display(c.normalcy_cd), c.result_val, c_result_units_disp =
    uar_get_code_display(c.result_units_cd),
    c_result_status_disp = uar_get_code_display(c.result_status_cd), c.normal_low, c.normal_high,
    c.critical_high, c.critical_low, c_result_time_units_disp = uar_get_code_display(c
     .result_time_units_cd)
    FROM clinical_event c
    WHERE c.encntr_id=cnvtreal( $ENC)
    ORDER BY c_task_assay_disp, c_result_time_units_disp
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE printorders(prtto)
  SELECT INTO  $OUTDEV
   o.order_id, o_dept_status_disp = uar_get_code_display(o.dept_status_cd), o_catalog_disp =
   uar_get_code_display(o.catalog_cd),
   o_catalog_type_disp = uar_get_code_display(o.catalog_type_cd), o.order_mnemonic, o
   .orig_order_dt_tm
   FROM orders o
   WHERE o.encntr_id=cnvtreal( $ENC)
   ORDER BY o.order_mnemonic, o.orig_order_dt_tm
   HEAD REPORT
    col 0, "Orders From ",  $STARTDT,
    " TO ",  $ENDDT, row + 4
   HEAD o.order_mnemonic
    col 0, o.order_mnemonic"###################################"
   DETAIL
    col 40, o.orig_order_dt_tm"mm/dd/yyyy hh:mm;;q", col 60,
    o_dept_status_disp, row + 1
   WITH nocounter
  ;end select
  RETURN
 END ;Subroutine
END GO
