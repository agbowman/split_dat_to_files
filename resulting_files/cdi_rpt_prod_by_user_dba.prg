CREATE PROGRAM cdi_rpt_prod_by_user:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Layout Program" = "cdi_rpt_prod_by_user_lyt",
  "Begin Date" = "CURDATE",
  "End Date" = "CURDATE",
  "User Name" = ""
  WITH output_dest, layout_program, begin_date,
  end_date, user_name
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
 DECLARE strlayoutprogram = vc WITH noconstant("cdi_rpt_prod_by_user_lyt")
 DECLARE strusername = vc WITH noconstant("")
 SET strusername =  $USER_NAME
 IF (cnvtupper( $LAYOUT_PROGRAM) != "DEFAULT"
  AND size(trim( $LAYOUT_PROGRAM)) > 0)
  SET strlayoutprogram =  $LAYOUT_PROGRAM
 ENDIF
 IF (size(trim(strusername)) > 0)
  SET strexecutestring = build2("execute ",strlayoutprogram," '", $OUTPUT_DEST,"', '",
    $BEGIN_DATE,"', '", $END_DATE,"', '",strusername,
   "' go")
 ELSE
  SET strexecutestring = build2("execute ",strlayoutprogram," '", $OUTPUT_DEST,"', '",
    $BEGIN_DATE,"', '", $END_DATE,"', '' go")
 ENDIF
 CALL parser(strexecutestring)
END GO
