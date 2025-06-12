CREATE PROGRAM dcp_arpt_6_prompt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Report Start Date:" = curdate,
  "Select the organization:",
  "Select the nursing station" = value()
  WITH prompt1, prompt2, prompt5,
  prompt6
 EXECUTE dcp_arpt_6_mon_unit_util  $PROMPT1,  $PROMPT2,  $PROMPT2,
 - (1), cnvtreal( $PROMPT5),  $PROMPT6,
 "", - (1), - (1),
 ""
END GO
