CREATE PROGRAM cdi_rpt_doc_hist:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Layout Program" = "cdi_rpt_doc_hist_lyt",
  "Blob Handle" = ""
  WITH output_dest, layout_program, blob_handle
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
 DECLARE strlayoutprogram = vc WITH noconstant("cdi_rpt_doc_hist_lyt")
 DECLARE strblobhandle = vc WITH noconstant("")
 SET strblobhandle =  $BLOB_HANDLE
 IF (cnvtupper( $LAYOUT_PROGRAM) != "DEFAULT"
  AND size(trim( $LAYOUT_PROGRAM)) > 0)
  SET strlayoutprogram =  $LAYOUT_PROGRAM
 ENDIF
 IF (size(trim(strblobhandle)) > 0)
  SET strexecutestring = build2("execute ",strlayoutprogram," '", $OUTPUT_DEST,"', '",
   strblobhandle,"' go")
 ELSE
  SET strexecutestring = build2("execute ",strlayoutprogram," '", $OUTPUT_DEST,"', '' go")
 ENDIF
 CALL parser(strexecutestring)
END GO
