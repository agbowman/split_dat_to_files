CREATE PROGRAM dm2_grant_privileges_c:dba
 DECLARE dm2_mod = vc WITH private, constant("001")
 IF (dm2_prg_maint("BEGIN")=0)
  GO TO exit_program
 ENDIF
 IF (dm2_push_cmd(concat("rdb grant select on ",gp_tlist->qual[gp_cnt].gp_tname,
   " to user v500read go"),1)=0)
  ROLLBACK
  GO TO exit_program
 ELSE
  COMMIT
 ENDIF
#exit_program
 CALL dm2_prg_maint("END")
END GO
