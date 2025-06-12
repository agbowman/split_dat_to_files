CREATE PROGRAM cv_utl_cl_template:dba
 PROMPT
  "Output=" = mine,
  "Template Name(Wild cards allowed)" = "*",
  "Turn on Smarter Template(Y/N)" = "N"
 DECLARE template_name = vc
 DECLARE temp_template_id = f8
 SET template_name = cnvtupper( $2)
 IF (cnvtupper( $3)="Y")
  SET smarter_template = 1
 ELSE
  SET smarter_template = 0
 ENDIF
 CALL echo(template_name)
 SELECT INTO "NL:"
  *
  FROM clinical_note_template cnt
  WHERE cnvtupper(cnt.template_name)=patstring(template_name)
  DETAIL
   temp_template_id = cnt.template_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT INTO  $1
   FROM dual d
   DETAIL
    "No Templates found with the string|", template_name, "|",
    row + 1
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 IF (curqual > 1)
  SELECT INTO  $1
   FROM dual d
   DETAIL
    "Multiple Templates found with the string|", template_name, "|",
    row + 1
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 UPDATE  FROM clinical_note_template cnt
  SET cnt.smart_template_ind = smarter_template
  WHERE cnt.template_id=temp_template_id
  WITH nocounter
 ;end update
 IF (curqual=1)
  SELECT INTO  $1
   FROM dual d
   DETAIL
    "Template with the string|", template_name, "| has smart template set to ",
    smarter_template, row + 1
   WITH nocounter
  ;end select
  COMMIT
 ELSE
  SELECT INTO  $1
   FROM dual d
   DETAIL
    "Template with the string|", template_name, "| could not be set to smart template.",
    row + 1
   WITH nocounter
  ;end select
 ENDIF
#exit_script
END GO
