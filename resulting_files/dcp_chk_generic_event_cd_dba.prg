CREATE PROGRAM dcp_chk_generic_event_cd:dba
 SET nbr_records = 0
 SET nbr_records1 = 0
 SET code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value_alias cva
  WHERE cva.code_set=72
   AND cva.alias="DCPGENERIC"
  DETAIL
   nbr_records1 = (nbr_records1+ 1), code_value = cva.code_value,
   CALL echo(build("code_value:",code_value))
  WITH nocounter
 ;end select
 IF (nbr_records1 != 0)
  SELECT INTO "nl:"
   cv.code_set, cv.cdf_meaning
   FROM code_value cv
   WHERE cv.code_set=72
    AND cv.code_value=code_value
   DETAIL
    nbr_records = (nbr_records+ 1),
    CALL echo(build("code_value1:",code_value))
   WITH nocounter
  ;end select
  IF (nbr_records=0)
   SELECT INTO "nl:"
    v.event_cd
    FROM v500_event_code v
    WHERE v.event_cd=code_value
    DETAIL
     nbr_records = (nbr_records+ 1)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET request->setup_proc[1].process_id = 718
 IF (nbr_records1=0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "The Code_value_alias for the event_cd was not built."
 ELSE
  IF (nbr_records=0)
   SET request->setup_proc[1].success_ind = 0
   SET request->setup_proc[1].error_msg =
   "The Code_value for the DCPGENERIC alias is not valid code value"
  ELSE
   SET request->setup_proc[1].success_ind = 1
   SET request->setup_proc[1].error_msg = "The code_value_alias and EventCd was built successfully."
  ENDIF
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
