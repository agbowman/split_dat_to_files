CREATE PROGRAM dm_env_merge_translates:dba
 DECLARE dcmt_target_id = f8 WITH protect
 DECLARE dcmt_source_id = f8 WITH protect
 DECLARE dcmt_target_name = vc WITH protect
 DECLARE dcmt_source_name = vc WITH protect
 SET dcmt_target_id = 0.0
 SET dcmt_source_id = 0.0
 DECLARE input_envid(dcmt_envname=vc,row_num=i4) = null
 CALL echo("Start dm_env_merge_translates")
 SET message = window
 CALL clear(1,1)
 SET width = 132
 CALL box(1,1,5,80)
 CALL text(3,30,"SELECT ENVIRONMENT ID")
 CALL input_envid("TARGET",0)
 CALL input_envid("SOURCE",1)
 CALL clear(23,1)
 SELECT INTO "nl:"
  FROM dm_environment d
  WHERE d.environment_id=dcmt_target_id
  DETAIL
   dcmt_target_name = d.environment_name
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dm_environment d
  WHERE d.environment_id=dcmt_source_id
  DETAIL
   dcmt_source_name = d.environment_name
  WITH nocounter
 ;end select
 CALL text(10,3,"The target environment id is :")
 CALL text(10,35,concat(cnvtstring(dcmt_target_id),"   ",dcmt_target_name))
 CALL text(11,3,"The source environment id is :")
 CALL text(11,35,concat(cnvtstring(dcmt_source_id),"   ",dcmt_source_name))
 CALL text(14,3,"Continue to build translation between the two domains now?(Y/N)")
 CALL accept(14,80,"P;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 SET message = nowindow
 IF (curaccept="Y")
  EXECUTE dm_ins_merge_translates dcmt_source_id, dcmt_target_id
 ENDIF
 SUBROUTINE input_envid(dcmt_envname,row_num)
   CALL text((7+ row_num),3,concat("Choose ",dcmt_envname," environment id: "))
   CALL text(23,05,"HELP: Press <SHIFT><F5>   0 to exit ")
   SET help =
   SELECT INTO "nl:"
    de.environment_id, de.environment_name
    FROM dm_environment de
    WITH nocounter
   ;end select
   CALL accept((7+ row_num),45,"P(15);CU","0")
   IF (curaccept="0")
    SET help = off
    SET message = nowindow
    GO TO exit_program
   ENDIF
   IF (dcmt_envname="TARGET")
    SET dcmt_target_id = cnvtreal(curaccept)
   ELSEIF (dcmt_envname="SOURCE")
    SET dcmt_source_id = cnvtreal(curaccept)
   ENDIF
   SET help = off
 END ;Subroutine
#exit_program
END GO
