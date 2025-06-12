CREATE PROGRAM ccl_prompt_removeprg:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Program Name:" = "",
  "Group NO:" = 0,
  "Control Class ID" = ""
  WITH outdev, cclprg, groupno,
  ctrlclsid
 DELETE  FROM ccl_prompt_programs
  WHERE program_name=cnvtupper(trim( $CCLPRG))
   AND group_no=cnvtint( $GROUPNO)
   AND control_class_id=cnvtint( $CTRLCLSID)
  WITH nocounter
 ;end delete
 COMMIT
 SELECT INTO  $OUTDEV
  *
  FROM ccl_prompt_programs ccp
  WHERE ccp.control_class_id=cnvtint( $CTRLCLSID)
  ORDER BY program_name
  WITH nocounter, check
 ;end select
 COMMIT
END GO
