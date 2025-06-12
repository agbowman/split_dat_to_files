CREATE PROGRAM cdi_rpt_batch_details:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Layout Program" = "cdi_rpt_batch_detail_lyt",
  "Batch Name" = ""
  WITH output_dest, layout_program, batch_name
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE strexecutestring = vc WITH noconstant("")
 DECLARE strlayoutprogram = vc WITH noconstant("cdi_rpt_batch_detail_lyt")
 DECLARE strbatchname = vc WITH noconstant("")
 SET strbatchname =  $BATCH_NAME
 IF (cnvtupper( $LAYOUT_PROGRAM) != "DEFAULT"
  AND size(trim( $LAYOUT_PROGRAM)) > 0)
  SET strlayoutprogram =  $LAYOUT_PROGRAM
 ENDIF
 IF (size(trim(strbatchname)) > 0)
  SET strexecutestring = build2("execute ",strlayoutprogram," '", $OUTPUT_DEST,"', '",
   strbatchname,"' go")
 ELSE
  SET strexecutestring = build2("execute ",strlayoutprogram," '", $OUTPUT_DEST,"', '' go")
 ENDIF
 CALL parser(strexecutestring)
END GO
