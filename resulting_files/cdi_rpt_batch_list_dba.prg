CREATE PROGRAM cdi_rpt_batch_list:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Layout Program" = "cdi_rpt_batch_list_lyt",
  "Begin Date" = "CURDATE",
  "End Date" = "CURDATE",
  "Begin Time" = "CURTIME",
  "End Time" = "CURTIME",
  "All Batch Classes" = "0",
  "Batch Class" = ""
  WITH output_dest, layout_program, begin_date,
  end_date, begin_time, end_time,
  all_batch_classes, batch_class
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE strlayoutprogram = vc WITH noconstant("cdi_rpt_batch_list_lyt")
 IF (cnvtupper( $LAYOUT_PROGRAM) != "DEFAULT"
  AND size(trim( $LAYOUT_PROGRAM)) > 0)
  SET strlayoutprogram =  $LAYOUT_PROGRAM
 ENDIF
 EXECUTE value(cnvtupper(strlayoutprogram))  $OUTPUT_DEST,  $BEGIN_DATE,  $END_DATE,
  $BEGIN_TIME,  $END_TIME,  $BATCH_CLASS,
  $ALL_BATCH_CLASSES
END GO
