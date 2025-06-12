CREATE PROGRAM dcp_arpt_1_prompt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select the organization:" = 0,
  "Patient's Last Name:" = "*",
  "Select the nursing station:" = 0,
  "Patients:" = 0
  WITH prompt1, prompt5, lastname,
  icuunit, prompt8
 EXECUTE dcp_arpt_1_phys_trend  $PROMPT1, - (1), - (1),
 - (1),  $PROMPT5, - (1),
 "",  $PROMPT8, - (1),
 ""
END GO
