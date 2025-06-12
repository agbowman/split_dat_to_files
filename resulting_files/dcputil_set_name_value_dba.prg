CREATE PROGRAM dcputil_set_name_value:dba
 PAINT
#pref_tool
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"P O W E R C H A R T    P R E F E R E N C E S")
 CALL text(3,25,"** NAME-VALUE PREFERENCES **")
 CALL text(5,3,"Parent entity name:")
 CALL text(6,3,"Parent entity id:")
 CALL text(7,3,"Pvc name:")
 CALL text(8,3,"Pvc value:")
 SET p_e_name = "                                "
 SET p_e_id = 0.0
 SET name = "                                "
 SET value = "                                                                       "
#restart
 SET nvid = 0.0
 SET all_fields = "Y"
 CALL text(20,15,"                                       ")
 CALL text(15,10,"                                                         ")
#parent_name
 CALL accept(5,23,"PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP;CU",p_e_name)
 IF (curaccept != " ")
  SET p_e_name = curaccept
 ELSE
  SET all_fields = "N"
 ENDIF
#parent_id
 CALL accept(6,23,"NNNNNNNNNN",p_e_id)
 IF (curaccept != 0)
  SET p_e_id = curaccept
 ELSE
  SET all_fields = "N"
 ENDIF
#pvc_name
 CALL accept(7,23,"PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP;CU",name)
 IF (curaccept != "")
  SET name = curaccept
 ELSE
  SET all_fields = "N"
 ENDIF
#pvc_value
 CALL accept(8,23,"PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP;CU",value)
 IF (curaccept != "")
  SET value = curaccept
 ELSE
  SET all_fields = "N"
 ENDIF
#check_all_fields
 IF (all_fields="N")
  CALL text(15,10,"All fields need to be valued.  Exit program? (Y/N)")
  CALL accept(15,66,"X;CU","Y")
  IF (curaccept="Y")
   GO TO exit_program
  ELSE
   CALL text(15,10,"                                                        ")
   GO TO restart
  ENDIF
 ENDIF
#duplicates
 CALL text(20,15,"Checking for duplicate record...       ")
#check_existing
 SELECT INTO "nl:"
  name_value_prefs_id
  FROM name_value_prefs
  WHERE parent_entity_name=p_e_name
   AND parent_entity_id=p_e_id
   AND pvc_name=name
   AND active_ind=1
  WITH nocounter
 ;end select
 IF (curqual > 0)
  CALL text(20,15,"                                       ")
  CALL text(15,10,"Name_value preference already exists, overwrite? (Y/N)")
  CALL accept(15,66,"X;CU","N")
  IF (curaccept != "Y")
   GO TO check_for_more
  ENDIF
  CALL text(15,10,"                                                          ")
  GO TO update_name_value_prefs
 ENDIF
#insert_name_value_prefs
 CALL text(20,15,"Updating database...                   ")
 SELECT INTO "nl:"
  w = seq(carenet_seq,nextval)
  FROM dual
  DETAIL
   nvid = cnvtreal(w)
  WITH format, nocounter
 ;end select
 INSERT  FROM name_value_prefs
  SET name_value_prefs_id = nvid, parent_entity_name = p_e_name, parent_entity_id = p_e_id,
   pvc_name = name, pvc_value = value, active_ind = 1,
   updt_dt_tm = cnvtdatetime(curdate,curtime), updt_id = 0, updt_task = 0,
   updt_cnt = 0, updt_applctx = 0
 ;end insert
 GO TO check_for_more
#update_name_value_prefs
 CALL text(20,15,"Updating database...                   ")
 UPDATE  FROM name_value_prefs
  SET pvc_value = value, updt_dt_tm = cnvtdatetime(curdate,curtime), updt_id = 0,
   updt_task = 0, updt_cnt = (updt_cnt+ 1), updt_applctx = 0
  WHERE parent_entity_name=p_e_name
   AND parent_entity_id=p_e_id
   AND pvc_name=name
   AND active_ind=1
 ;end update
#check_for_more
 CALL text(20,15,"Set another name-value pair? (Y/N)     ")
 CALL accept(20,50,"X;CU","N")
 IF (curaccept="Y")
  GO TO restart
 ENDIF
#exit_program
 CALL text(20,15,"Commit changes?                        ")
 CALL accept(20,31,"X;CU","N")
 IF (curaccept="Y")
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
#skip_commit
END GO
