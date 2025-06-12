CREATE PROGRAM dm_test_combine:dba
 SET dm_cmb_parent1 = cnvtupper( $1)
 SET dm_cmb_from_id =  $2
 SET dm_cmb_to_id =  $3
 SET dm_cmb_encntr_id =  $4
 IF (currev >= 8)
  IF (((dm_cmb_from_id <= 0.0
   AND reflect(dm_cmb_from_id)="I4") OR (((dm_cmb_to_id <= 0.0
   AND reflect(dm_cmb_to_id)="I4") OR (dm_cmb_encntr_id <= 0.0
   AND reflect(dm_cmb_encntr_id)="I4")) )) )
   CALL echo(".")
   CALL echo(concat("From id =  ",build(dm_cmb_from_id)))
   CALL echo(concat("To id   =  ",build(dm_cmb_to_id)))
   CALL echo(concat("Encntr id = ",build(dm_cmb_encntr_id)))
   CALL echo(".")
   CALL echo("Input ID values greater than 2^31 must end in '.0'")
   CALL echo("If not performing an encounter move, the encntr_id must be passed in as '0.0'")
   CALL echo(".")
   GO TO end_script
  ENDIF
 ENDIF
 CASE (dm_cmb_parent1)
  OF "P":
   SET dm_cmb_parent = "PERSON"
  OF "E":
   SET dm_cmb_parent = "ENCOUNTER"
  OF "L":
   SET dm_cmb_parent = "LOCATION"
  OF "H":
   SET dm_cmb_parent = "HEALTH_PLAN"
  OF "O":
   SET dm_cmb_parent = "ORGANIZATION"
  ELSE
   SET dm_cmb_parent = dm_cmb_parent1
 ENDCASE
 SELECT INTO "nl:"
  p.person_id
  FROM prsnl p
  WHERE p.username=curuser
  DETAIL
   reqinfo->updt_id = p.person_id
  WITH nocounter
 ;end select
 IF ((validate(cmb_test_updt_task,- (1)) != - (1)))
  SET reqinfo->updt_task = cmb_test_updt_task
 ELSE
  SET reqinfo->updt_task = 555555
 ENDIF
 SET reqdata->data_status_cd = 55555
 SET reqdata->contributor_system_cd = 55555
 SET reqinfo->updt_applctx = 55555
 SET error_cnt = 0
 SET error_cnt2 = 0
 SET reply_cnt = 0
 SET reply2_cnt = 0
 FREE SET request
 RECORD request(
   1 parent_table = c50
   1 cmb_mode = c20
   1 error_message = c132
   1 transaction_type = c8
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
     2 comment_txt = c250
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
   1 reverse_cmb_ind = i2
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
     2 combine_error_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 IF ((validate(dm_test_revcmb_ind,- (1)) != - (1)))
  SET request->reverse_cmb_ind = dm_test_revcmb_ind
 ENDIF
 SET stat = alterlist(request->xxx_combine,1)
 SET request->parent_table = dm_cmb_parent
 SET request->cmb_mode = "TESTING"
 SET request->transaction_type = curuser
 SET request->xxx_combine[1].from_xxx_id = dm_cmb_from_id
 SET request->xxx_combine[1].to_xxx_id = dm_cmb_to_id
 SET request->xxx_combine[1].encntr_id = dm_cmb_encntr_id
 SET request->xxx_combine[1].application_flag = 5
 EXECUTE dm_call_combine
 FOR (dm_t_a = 1 TO reply_cnt)
   CALL echo(".")
   CALL echo(concat("Combine_id    =  ",build(format(reply->xxx_combine_id[dm_t_a].combine_id,
       "##########;l"))))
   CALL echo(concat("Parent table  =  ",reply->xxx_combine_id[dm_t_a].parent_table))
   CALL echo(concat("From id       =  ",build(format(reply->xxx_combine_id[dm_t_a].from_xxx_id,
       "##########;l"))))
   CALL echo(concat("To id         =  ",build(format(reply->xxx_combine_id[dm_t_a].to_xxx_id,
       "##########;l"))))
   CALL echo(concat("Encntr id     =  ",build(format(reply->xxx_combine_id[dm_t_a].encntr_id,
       "##########;l"))))
 ENDFOR
 IF (reply_cnt > 0)
  CALL echo(".")
  CALL echo(concat("Status        =  ",reply->status_data.status))
  CALL echo(".")
 ENDIF
 FOR (dm_t_b = 1 TO error_cnt)
   CALL echo(".")
   CALL echo(concat("Error ID      =  ",build(format(reply->error[dm_t_b].combine_error_id,
       "##########;l"))))
   CALL echo(concat("Error from_id =  ",build(format(reply->error[dm_t_b].from_id,"##########;l"))))
   CALL echo(concat("Error to_id   =  ",build(format(reply->error[dm_t_b].to_id,"##########;l"))))
   CALL echo(concat("Error msg     =  ",reply->error[dm_t_b].error_msg))
   CALL echo(concat("Error table   =  ",reply->error[dm_t_b].error_table))
   CALL echo(concat("Error type    =  ",reply->error[dm_t_b].error_type))
   CALL echo(".")
   CALL echo(concat("Status        =  ",reply->status_data.status))
   CALL echo(".")
 ENDFOR
 IF (error_cnt=0)
  CALL echo("*****************************************************")
  CALL echo("THIS IS JUST TESTING !!! ROLLBACK executed !!!")
  CALL echo("*****************************************************")
  ROLLBACK
 ENDIF
#end_script
END GO
