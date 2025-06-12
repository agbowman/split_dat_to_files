CREATE PROGRAM ccl_cnvt_rtf2ps
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter RTF file to convert:" = "<back-end directory><file.rtf>"
  WITH outdev, filein
 SET stat = uar_rtf2ps(nullterm( $FILEIN),nullterm( $OUTDEV))
END GO
