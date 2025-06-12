CREATE PROGRAM bhs_dcp_arpt_6_prompt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Report Start Date:" = curdate,
  "Select the organization:" = 0,
  "Select the nursing station" = 0
  WITH prompt1, prompt2, prompt5,
  prompt6
 EXECUTE bhs_dcp_arpt_6_mon_unit_util  $PROMPT1,  $PROMPT2,  $PROMPT2,
 - (1), cnvtreal( $PROMPT5),  $PROMPT6,
 "", - (1), - (1),
 ""
END GO
