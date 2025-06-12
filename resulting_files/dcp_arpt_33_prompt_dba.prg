CREATE PROGRAM dcp_arpt_33_prompt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select the organization:",
  "Patient's Last Name:" = "*",
  "Select the nursing station:",
  "Patients:" = value()
  WITH prompt1, prompt5, lastname,
  icuunit, prompt8
 EXECUTE dcp_arpt_33_ap2_phys_trend  $PROMPT1, - (1), - (1),
 - (1),  $PROMPT5, - (1),
 "",  $PROMPT8, - (1),
 ""
END GO
