CREATE PROGRAM bhs_sys_rte_add_entry
 PROMPT
  "contributor_system_cd" = 0,
  "account number" = " ",
  "parent_entity_id" = " ",
  "parent_entity_name" = " "
  WITH cont_sys, acct_nbr, entity_id,
  entity_name
 DECLARE var_acct_nbr = vc
 DECLARE var_encntr_id = f8
 DECLARE cs48_active_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE cs319_fin_nbr_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE write_error_msg(message=vc,msg_level=i4) = null
 SUBROUTINE write_error_msg(message,msg_level)
   IF (msg_level < 0)
    SET msg_level = 0
   ENDIF
   EXECUTE bhs_sys_msgview "CCL_ERROR", build2(trim(curprog,3),": ",substring(1,255,message)),
   msg_level
   CALL echo(build2("CCL_ERROR | ",trim(curprog,3),": ",message," | log_level: ",
     trim(build2(msg_level))))
 END ;Subroutine
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_value=cnvtreal( $CONT_SYS)
    AND cv.code_value > 0.00
    AND cv.code_set=89
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  CALL write_error_msg(trim(build2("Invalid contributor_system_cd (",trim(build2( $CONT_SYS),3),
     ") passed in. Exiting Script"),3),0)
  GO TO exit_script
 ENDIF
 IF (trim( $ENTITY_ID,3) <= " ")
  CALL write_error_msg("No parent_entity_id ($3) passed in. Exiting Script",0)
  GO TO exit_script
 ENDIF
 IF (trim( $ENTITY_NAME,3) <= " ")
  CALL write_error_msg("No parent_entity_name ($4) passed in. Exiting Script",0)
  GO TO exit_script
 ENDIF
 SET var_acct_nbr = trim(build2( $ACCT_NBR),3)
 SELECT INTO "nl:"
  FROM encntr_alias ea
  PLAN (ea
   WHERE ea.alias=var_acct_nbr
    AND ea.encntr_alias_type_cd=cs319_fin_nbr_cd
    AND ea.active_ind=1
    AND ea.active_status_cd=cs48_active_cd
    AND ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  DETAIL
   var_encntr_id = ea.encntr_id
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  CALL write_error_msg(build2("Account number (",var_acct_nbr,") not found in system. Exiting Script"
    ),0)
  GO TO exit_script
 ELSEIF (curqual > 1)
  CALL write_error_msg(build2("Multiple encounters found for account number (",var_acct_nbr,
    "). Exiting Script"),0)
  GO TO exit_script
 ENDIF
 INSERT  FROM bhs_rte_hold brh
  SET brh.rec_id = seq(bhs_rte_seq,nextval), brh.cont_sys = cnvtreal( $CONT_SYS), brh.encntr_id =
   var_encntr_id,
   brh.parent_entity_id = trim( $ENTITY_ID,3), brh.parent_entity_name = trim( $ENTITY_NAME,3), brh
   .insert_dt_tm = cnvtdatetime(curdate,curtime3),
   brh.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  WITH nocounter
 ;end insert
 IF (curqual != 1)
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
#exit_script
END GO
