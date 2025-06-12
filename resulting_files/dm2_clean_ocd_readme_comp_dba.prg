CREATE PROGRAM dm2_clean_ocd_readme_comp:dba
 DECLARE der_cnt = i4
 DECLARE der_qual_hold = i4
 DECLARE errcode = i4
 DECLARE errmsg = vc
 SET der_cnt = 0
 SET der_qual_hold = 0
 SET errmsg = fillstring(132," ")
 SET errcode = 0
 SET errcode = error(errmsg,1)
 SET der_cnt = size(requestin->list_0,5)
 CALL echo(concat("Cleaning ",trim(cnvtstring(der_cnt))," rows in OCD_README_COMPONENT."))
 IF (der_cnt > 0)
  SELECT INTO "nl:"
   FROM ocd_readme_component o,
    (dummyt d  WITH seq = value(der_cnt))
   PLAN (d
    WHERE d.seq > 0)
    JOIN (o
    WHERE cnvtupper(o.component_type)=cnvtupper(requestin->list_0[d.seq].component_type)
     AND cnvtupper(o.end_state)=cnvtupper(requestin->list_0[d.seq].end_state))
   WITH nocounter
  ;end select
  SET errcode = error(errmsg,0)
  IF (errcode != 0)
   ROLLBACK
   SET readme_data->message = "Select failed on OCD_README_COMPONENT."
   SET readme_data->status = "F"
   CALL echo(readme_data->message)
   GO TO exit_program
  ELSE
   IF (curqual=0)
    SET readme_data->message = concat(" No rows qualified to be cleaned  in OCD_README_COMPONENT.")
    CALL echo(readme_data->message)
    SET readme_data->status = "S"
    GO TO exit_program
   ELSE
    SET der_qual_hold = curqual
    CALL echo(concat(trim(cnvtstring(der_qual_hold)),
      " rows qualified to be cleaned  in OCD_README_COMPONENT."))
   ENDIF
  ENDIF
  SET errcode = error(errmsg,1)
  DELETE  FROM ocd_readme_component o,
    (dummyt d  WITH seq = value(der_cnt))
   SET o.seq = 1
   PLAN (d)
    JOIN (o
    WHERE cnvtupper(o.component_type)=cnvtupper(requestin->list_0[d.seq].component_type)
     AND cnvtupper(o.end_state)=cnvtupper(requestin->list_0[d.seq].end_state))
   WITH nocounter
  ;end delete
  SET errcode = error(errmsg,0)
  IF (errcode != 0)
   ROLLBACK
   SET readme_data->message = "Cleanup failed on OCD_README_COMPONENT."
   SET readme_data->status = "F"
   CALL echo(readme_data->message)
   GO TO exit_program
  ENDIF
  IF (curqual != der_qual_hold)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = build("After clean count:",curqual," != Rows to be cleaned count:",
    der_qual_hold)
   CALL echo(readme_data->message)
  ELSE
   COMMIT
   SET readme_data->status = "S"
   CALL echo(concat(trim(cnvtstring(curqual))," rows cleaned  in OCD_README_COMPONENT."))
  ENDIF
 ENDIF
#exit_program
 CALL echo("Exiting Program")
END GO
