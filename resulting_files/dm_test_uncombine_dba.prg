CREATE PROGRAM dm_test_uncombine:dba
 DECLARE dm_t_xxx_combine_id = f8
 SET dm_t_cmb_parent1 = cnvtupper( $1)
 SET dm_t_cmb_from_id =  $2
 SET dm_t_cmb_to_id =  $3
 IF (currev >= 8)
  IF (((dm_t_cmb_from_id <= 0.0
   AND reflect(dm_t_cmb_from_id)="I4") OR (dm_t_cmb_to_id <= 0.0
   AND reflect(dm_t_cmb_to_id)="I4")) )
   CALL echo(".")
   CALL echo(concat("From id =  ",build(dm_t_cmb_from_id)))
   CALL echo(concat("To id   =  ",build(dm_t_cmb_to_id)))
   CALL echo(".")
   CALL echo("Input ID values greater than 2^31 must end in '.0'")
   CALL echo(".")
   GO TO end_script
  ENDIF
 ENDIF
 SET dm_t_cmb_parent = fillstring(30," ")
 CASE (dm_t_cmb_parent1)
  OF "P":
   SET dm_t_cmb_parent = "PERSON"
  OF "E":
   SET dm_t_cmb_parent = "ENCOUNTER"
  OF "L":
   SET dm_t_cmb_parent = "LOCATION"
  OF "H":
   SET dm_t_cmb_parent = "HEALTH_PLAN"
  OF "O":
   SET dm_t_cmb_parent = "ORGANIZATION"
  ELSE
   SET dm_t_cmb_parent = dm_t_cmb_parent1
 ENDCASE
 SET dm_t_xxx_combine_id = 0
 SET error_cnt = 0
 SET reply_cnt = 0
 SELECT INTO "nl:"
  p.person_id
  FROM prsnl p
  WHERE p.username=curuser
  DETAIL
   reqinfo->updt_id = p.person_id
  WITH nocounter
 ;end select
 SET reqdata->data_status_cd = 44444
 SET reqdata->contributor_system_cd = 44444
 SET reqinfo->updt_applctx = 44444
 SET reqinfo->updt_task = 44444
 FREE SET request
 RECORD request(
   1 parent_table = c50
   1 cmb_mode = c20
   1 error_message = c132
   1 transaction_type = c8
   1 xxx_uncombine[*]
     2 xxx_combine_id = f8
     2 from_xxx_id = f8
     2 to_xxx_id = f8
     2 encntr_id = f8
     2 application_flag = i2
   1 xxx_combine[*]
     2 xxx_combine_id = f8
     2 from_xxx_id = f8
     2 from_mrn = c200
     2 from_alias_pool_cd = f8
     2 from_alias_type_cd = f8
     2 to_xxx_id = f8
     2 to_mrn = c200
     2 to_alias_pool_cd = f8
     2 to_alias_type_cd = f8
     2 encntr_id = f8
     2 application_flag = i2
     2 combine_weight = f8
   1 xxx_combine_det[*]
     2 xxx_combine_det_id = f8
     2 xxx_combine_id = f8
     2 entity_name = c32
     2 entity_id = f8
     2 entity_pk[*]
       3 col_name = c30
       3 data_type = c30
       3 data_char = c100
       3 data_number = f8
       3 data_date = dq8
     2 combine_action_cd = f8
     2 attribute_name = c32
     2 prev_active_ind = i2
     2 prev_active_status_cd = f8
     2 prev_end_eff_dt_tm = dq8
     2 combine_desc_cd = f8
     2 to_record_ind = i2
 )
 FREE SET reply
 RECORD reply(
   1 xxx_combine_id[*]
     2 combine_id = f8
     2 parent_table = c50
     2 from_xxx_id = f8
     2 to_xxx_id = f8
     2 encntr_id = f8
   1 error[*]
     2 create_dt_tm = dq8
     2 parent_table = c50
     2 from_id = f8
     2 to_id = f8
     2 encntr_id = f8
     2 error_table = c32
     2 error_type = vc
     2 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 IF (dm_t_cmb_parent="PERSON")
  SELECT INTO "nl:"
   pc.person_combine_id
   FROM person_combine pc
   WHERE pc.active_ind=1
    AND pc.from_person_id=dm_t_cmb_from_id
    AND pc.to_person_id=dm_t_cmb_to_id
    AND pc.encntr_id=0
   DETAIL
    dm_t_xxx_combine_id = pc.person_combine_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL echo(".")
   CALL echo(concat("From_person_id =  ",build(dm_t_cmb_from_id)))
   CALL echo(concat("To_person_id   =  ",build(dm_t_cmb_to_id)))
   CALL echo(".")
   CALL echo("There's no active person combine with this person_id pair.")
   CALL echo(".")
   GO TO end_script
  ENDIF
 ELSEIF (dm_t_cmb_parent="ENCOUNTER")
  SELECT INTO "nl:"
   ec.encntr_combine_id
   FROM encntr_combine ec
   WHERE ec.active_ind=1
    AND ec.from_encntr_id=dm_t_cmb_from_id
    AND ec.to_encntr_id=dm_t_cmb_to_id
   DETAIL
    dm_t_xxx_combine_id = ec.encntr_combine_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL echo(".")
   CALL echo(concat("From_encntr_id =  ",build(dm_t_cmb_from_id)))
   CALL echo(concat("To_encntr_id   =  ",build(dm_t_cmb_to_id)))
   CALL echo(".")
   CALL echo("There's no active encounter combine with this encntr_id pair.")
   CALL echo(".")
   GO TO end_script
  ENDIF
 ELSE
  SELECT INTO "nl:"
   c.combine_id
   FROM combine c
   WHERE c.active_ind=1
    AND c.from_id=dm_t_cmb_from_id
    AND c.to_id=dm_t_cmb_to_id
   DETAIL
    dm_t_xxx_combine_id = c.combine_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL echo(".")
   CALL echo(concat("From_id =  ",build(dm_t_cmb_from_id)))
   CALL echo(concat("To_id   =  ",build(dm_t_cmb_to_id)))
   CALL echo(".")
   CALL echo(concat("There's no active ",trim(dm_t_cmb_parent)," combine with this pair of ids."))
   CALL echo(".")
   GO TO end_script
  ENDIF
 ENDIF
 SET stat = alterlist(request->xxx_uncombine,1)
 SET request->cmb_mode = "TESTING"
 SET request->parent_table = dm_t_cmb_parent
 SET request->transaction_type = curuser
 SET request->xxx_uncombine[1].xxx_combine_id = dm_t_xxx_combine_id
 SET request->xxx_uncombine[1].from_xxx_id = dm_t_cmb_from_id
 SET request->xxx_uncombine[1].to_xxx_id = dm_t_cmb_to_id
 SET request->xxx_uncombine[1].application_flag = 5
 EXECUTE dm_call_uncombine
 FOR (dm_t_a = 1 TO error_cnt)
   CALL echo(".")
   CALL echo(concat("Uncombining ",trim(reply->error[dm_t_a].parent_table)))
   CALL echo(concat("Error from_id   =  ",build(format(reply->error[dm_t_a].from_id,"##########;l")))
    )
   CALL echo(concat("Error to_id     =  ",build(format(reply->error[dm_t_a].to_id,"##########;l"))))
   CALL echo(concat("Error encntr_id =  ",build(format(reply->error[dm_t_a].encntr_id,"##########;l")
      )))
   CALL echo(concat("Error msg       =  ",trim(reply->error[dm_t_a].error_msg)))
   CALL echo(concat("Error table     =  ",reply->error[dm_t_a].error_table))
   CALL echo(concat("Error type      =  ",reply->error[dm_t_a].error_type))
   CALL echo(".")
   CALL echo(concat("Status          =  ",reply->status_data.status))
   CALL echo(".")
 ENDFOR
 IF (error_cnt=0)
  CALL echo(".")
  CALL echo(" ROLLBACK executed !!!")
  CALL echo(".")
  ROLLBACK
 ENDIF
#end_script
END GO
