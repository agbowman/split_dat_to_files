CREATE PROGRAM dcp_arpt_19_prompt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Report Start Date:" = curdate,
  "Enter Report End Date:" = curdate,
  "Select  the Date Type:",
  "Select the organization:",
  "Select the nursing station" = value()
  WITH prompt1, prompt2, prompt3,
  prompt4, prompt5, prompt6
 EXECUTE dcp_arpt_19_icu_death_rev  $PROMPT1,  $PROMPT2,  $PROMPT3,
 cnvtint( $PROMPT4), cnvtreal( $PROMPT5),  $PROMPT6,
 "", - (1), - (1),
 ""
END GO
