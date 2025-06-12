CREATE PROGRAM add_bedrock_report:dba
 PROMPT
  "Report Name: " = "                                               ",
  "Program Name: " = "                                              ",
  "Step Cat Mean: " = "                     ",
  "Solution Mean (if diff from step_cat_mean, i.e. COREO): " =
  "                                             ",
  "Solution Name (if diff from step_cat_disp, i.e. Core - Orders): " =
  "                                                     ",
  "XRay? " = " "
 DECLARE report_name = vc
 SET report_name =  $1
 DECLARE program_name = vc
 SET program_name =  $2
 DECLARE step_cat_mean = vc
 SET step_cat_mean =  $3
 SET step_cat_mean = cnvtupper(step_cat_mean)
 DECLARE solution_mean = vc
 SET solution_mean =  $4
 DECLARE solution_name = vc
 SET solution_name =  $5
 DECLARE xray_ind = vc
 SET xray_ind =  $6
 IF (((report_name="Q*") OR (((report_name="q*") OR (((report_name=" ") OR (((program_name="Q*") OR (
 ((program_name="q*") OR (((program_name=" ") OR (((step_cat_mean="Q*") OR (((step_cat_mean="q*") OR
 (((step_cat_mean=" ") OR (((xray_ind="Q*") OR (((xray_ind="q*") OR (xray_ind=" ")) )) )) )) )) ))
 )) )) )) )) )) )
  GO TO exit_program
  CALL echo("**** Exit Program ****")
 ENDIF
 SET report_type_flag = 0
 SET hold_seq = 0
 SET step_cat_mean_valid = 0
 SELECT INTO "NL:"
  FROM br_name_value b
  WHERE b.br_nv_key1="STEP_CAT_MEAN"
   AND b.br_name=step_cat_mean
  DETAIL
   step_cat_mean_valid = 1
  WITH nocounter
 ;end select
 IF (step_cat_mean_valid=1)
  SET hold_seq = 0
  SELECT INTO "nl"
   FROM br_report br
   PLAN (br
    WHERE br.step_cat_mean=step_cat_mean
     AND br.br_client_id=0)
   ORDER BY br.sequence
   DETAIL
    hold_seq = (br.sequence+ 1)
   WITH nocounter, skipbedrock = 1
  ;end select
 ELSE
  CALL echo("**** invalid step_cat_mean ****")
  GO TO exit_program
 ENDIF
 IF (hold_seq=0)
  SET hold_seq = 1
 ENDIF
 SET dup_ind = 0
 SELECT INTO "nl:"
  FROM br_report br
  PLAN (br
   WHERE br.br_client_id=0
    AND br.program_name=cnvtupper(program_name)
    AND br.step_cat_mean=step_cat_mean)
  DETAIL
   dup_ind = 1
  WITH nocounter, skipbedrock = 1
 ;end select
 IF (dup_ind=1)
  CALL echo("**** Duplicate Entry ****")
  GO TO exit_program
 ENDIF
 IF (((xray_ind="Y") OR (xray_ind="y")) )
  SET report_type_flag = 1
 ENDIF
 INSERT  FROM br_report br
  SET br.br_report_id = seq(bedrock_seq,nextval), br.br_client_id = 0, br.report_name = trim(
    report_name),
   br.program_name = trim(cnvtupper(program_name)), br.step_cat_mean = trim(cnvtupper(step_cat_mean)),
   br.sequence = hold_seq,
   br.report_type_flag = report_type_flag, br.solution_mean = trim(cnvtupper(solution_mean)), br
   .solution_disp = trim(solution_name)
  WITH nocounter, skipbedrock = 1
 ;end insert
#exit_program
END GO
