CREATE PROGRAM add_bedrock_wizard:dba
 PROMPT
  "Wizard Name: " = "                                                    ",
  "Wizard Mean: " = "                                              ",
  "Step Cat Mean (valid entries on br_name_value): " = "                            ",
  "Solution Mean (if diff from step_cat_mean, i.e. COREO): " = "                            ",
  "Solution Name (if diff from step_cat_disp, i.e. Core - Orders): " =
  "                                                ",
  "Solution Type Flag: " = " "
 DECLARE wizard_name = vc
 SET wizard_name =  $1
 DECLARE wizard_mean = vc
 SET wizard_mean =  $2
 DECLARE step_cat_mean = vc
 SET step_cat_mean =  $3
 SET step_cat_mean = cnvtupper(step_cat_mean)
 DECLARE solution_mean = vc
 SET solution_mean =  $4
 DECLARE solution_name = vc
 SET solution_name =  $5
 DECLARE solution_type = vc
 SET solution_type =  $6
 DECLARE step_cat_disp = vc
 SELECT INTO "nl:"
  FROM br_name_value bnv
  PLAN (bnv
   WHERE bnv.br_nv_key1="STEP_CAT_MEAN"
    AND bnv.br_name=step_cat_mean
    AND bnv.br_client_id IN (0, 1))
  DETAIL
   step_cat_disp = bnv.br_value
  WITH nocounter, skipbedrock = 1
 ;end select
 IF (curqual=0)
  CALL echo("**** step_cat_mean not on br_name_value table ****")
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM br_step bs
  PLAN (bs
   WHERE bs.step_mean=wizard_mean)
  WITH nocounter
 ;end select
 IF (curqual=0)
  INSERT  FROM br_step bs
   SET bs.step_mean = wizard_mean, bs.step_disp = wizard_name, bs.step_type = "IMPMAINT",
    bs.step_cat_mean = step_cat_mean, bs.step_cat_disp = step_cat_disp, bs.default_seq = 5000
   WITH nocounter
  ;end insert
 ENDIF
 SET sol_found = "N"
 SET last_seq = 0
 IF (solution_mean > " ")
  SELECT INTO "nl:"
   FROM br_client_item_reltn bcir
   PLAN (bcir
    WHERE bcir.item_type="SOLUTION"
     AND bcir.br_client_id=1)
   ORDER BY bcir.solution_seq
   DETAIL
    last_seq = bcir.solution_seq
    IF (bcir.item_mean=solution_mean)
     sol_found = "Y"
    ENDIF
   WITH nocounter, skipbedrock = 1
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM br_client_item_reltn bcir
   PLAN (bcir
    WHERE bcir.item_type="SOLUTION")
   ORDER BY bcir.solution_seq
   DETAIL
    last_seq = bcir.solution_seq
    IF (bcir.item_mean=step_cat_mean)
     sol_found = "Y"
    ENDIF
   WITH nocounter
  ;end select
  SET solution_mean = step_cat_mean
  SET solution_name = step_cat_disp
 ENDIF
 IF (sol_found="N")
  INSERT  FROM br_client_item_reltn bcir
   SET bcir.br_client_item_reltn_id = seq(bedrock_seq,nextval), bcir.br_client_id = 1, bcir.item_type
     = "SOLUTION",
    bcir.item_mean = solution_mean, bcir.item_display = solution_name, bcir.solution_seq = (last_seq
    + 10),
    bcir.solution_type_flag =
    IF (solution_type="1") 1
    ELSE 0
    ENDIF
   WITH nocounter, skipbedrock = 1
  ;end insert
 ENDIF
 INSERT  FROM br_client_item_reltn bcir
  SET bcir.br_client_item_reltn_id = seq(bedrock_seq,nextval), bcir.br_client_id = 1, bcir.item_type
    = "STEP",
   bcir.item_mean = wizard_mean, bcir.item_display = wizard_name, bcir.step_cat_mean = step_cat_mean,
   bcir.step_cat_disp = step_cat_disp, bcir.solution_type_flag =
   IF (solution_type="1") 1
   ELSE 0
   ENDIF
  WITH nocounter, skipbedrock = 1
 ;end insert
 SET last_step_seq = 0
 SELECT INTO "nl:"
  FROM br_client_sol_step bcss
  PLAN (bcss
   WHERE bcss.br_client_id=1
    AND bcss.solution_mean=solution_mean)
  ORDER BY bcss.sequence
  DETAIL
   last_step_seq = bcss.sequence
  WITH nocounter
 ;end select
 INSERT  FROM br_client_sol_step bcss
  SET bcss.br_client_id = 1, bcss.solution_mean = solution_mean, bcss.step_mean = wizard_mean,
   bcss.sequence = (last_step_seq+ 10)
  WITH nocounter, skipbedrock = 1
 ;end insert
#exit_program
 CALL echo("Changes have not been committed...")
END GO
