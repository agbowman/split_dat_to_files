CREATE PROGRAM dcp_check_apache_prompt_load:dba
 SET prompts_loaded = 0
 SELECT INTO "nl:"
  FROM ccl_prompt_definitions c
  WHERE c.program_name IN ("DCP_APACHE_DM_INFO", "DCP_ARPT_1_PROMPT", "DCP_ARPT_6_PROMPT",
  "DCP_ARPT_7_PROMPT", "DCP_ARPT_9_PROMPT",
  "DCP_ARPT_10_PROMPT", "DCP_ARPT_15_PROMPT", "DCP_ARPT_16_PROMPT", "DCP_ARPT_17_PROMPT",
  "DCP_ARPT_19_PROMPT",
  "DCP_ARPT_23_PROMPT", "DCP_ARPT_24_PROMPT", "DCP_ARPT_31_PROMPT", "DCP_ARPT_33_PROMPT")
   AND c.position=0
  HEAD REPORT
   prompts_loaded = 0
  DETAIL
   prompts_loaded = (prompts_loaded+ 1)
  WITH nocounter
 ;end select
 IF (prompts_loaded=14)
  CALL echo("APACHE Prompts loaded successfully")
 ELSE
  CALL echo(build("not all APACHE Prompts loaded, count (14) =",prompts_loaded))
 ENDIF
END GO
