CREATE PROGRAM cdi_rpt_prod_by_date:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Layout Program" = "cdi_rpt_prod_by_date_lyt",
  "Date" = "CURDATE"
  WITH output_dest, layout_program, begin_date
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
 DECLARE strlayoutprogram = vc WITH noconstant("cdi_rpt_prod_by_date_lyt")
 IF (cnvtupper( $LAYOUT_PROGRAM) != "DEFAULT"
  AND size(trim( $LAYOUT_PROGRAM)) > 0)
  SET strlayoutprogram =  $LAYOUT_PROGRAM
 ENDIF
 SET strexecutestring = build2("execute ",strlayoutprogram," '", $OUTPUT_DEST,"', '",
   $BEGIN_DATE,"' go")
 CALL parser(strexecutestring)
END GO
