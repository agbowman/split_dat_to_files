CREATE PROGRAM ceutil_set_ce_prefs:dba
 PAINT
#menu
 CALL clear(1,1)
 CALL video(nw)
 CALL box(1,2,23,79)
 CALL text(2,17,"C L I N I C A L  E V E N T   P R E F E R E N C E S")
 CALL text(6,20,"1)  Set New or Change Existing Preferences")
 CALL text(8,20,"2)  View Current Settings")
 CALL text(10,20,"3)  Preference Descriptions")
 CALL text(12,20,"4)  Initialize Table to Default Values")
 CALL text(14,20,"5)  Exit")
 CALL text(24,2,"Select an Option(1,2,3,4,5)")
 CALL accept(24,30,"9;",5
  WHERE curaccept IN (1, 2, 3, 4, 5))
 CALL clear(24,1)
 CASE (curaccept)
  OF 1:
   GO TO set_prefs
  OF 2:
   GO TO view_prefs
  OF 3:
   GO TO prefs_description
  OF 4:
   GO TO set_defaults
  OF 5:
   GO TO skip_commit
  ELSE
   GO TO skip_commit
 ENDCASE
 GO TO menu
#view_prefs
 CALL clear(1,1)
 SELECT
  *
  FROM ce_prefs
 ;end select
 GO TO menu
#prefs_description
 CALL clear(1,1)
 CALL text(1,2,
  "                 *** An incorrect setting for a server will result in errors ***                               "
  )
 CALL text(2,2,
  "-------------------------------------------------------------------------------------------------------------- "
  )
 CALL text(3,2,
  "   Preference name     Value   Meaning                                                                         "
  )
 CALL text(4,2,
  "--------------------   -----   ------------------------------------------------------------------------------- "
  )
 CALL text(5,2,
  "USE_DYNAMIC_POSITION     1     Call the security access control to determine the position_cd for a user if     "
  )
 CALL text(6,2,
  "                                   Millennium is being used to determine positions dynamically.                "
  )
 CALL text(7,2,
  "                         0     Check privileges based on the position_cd of the user                           "
  )
 CALL text(8,2,
  "ENABLERTEPRSNLRELTN      Y     Enable Functionality for Relational Providers to Receive			       "
  )
 CALL text(9,2,
  "                               Results to Endorse Notifications.                    			       ")
 CALL text(10,2,
  "                         N     Disable Functionality for Relational Providers to Receive                       "
  )
 CALL text(11,2,
  "                               Results to Endorse Notifications.                    			       ")
 CALL text(22,2,
  "Press Enter to go back to the Main Menu                                                                        "
  )
 CALL accept(22,41,"P"," ")
 GO TO menu
#set_defaults
 CALL clear(1,1)
 CALL box(1,2,23,79)
 SET cpid = 0.0
 SET name = "                                      "
 SET value = "                         "
 SET cvalue = "                        "
 SET changes = "N"
 SET ind = false
#0
 SET name = "USE_DYNAMIC_POSITION"
 SET value = "0"
 GO TO check_defaults
#1
 SET name = "ENABLERTEPRSNLRELTN"
 SET value = "N"
 IF (ind=false)
  SET ind = true
  GO TO check_defaults
 ELSE
  GO TO 2
 ENDIF
#2
 CALL text(12,15,"Default Values Set")
 IF (changes="Y")
  CALL text(20,15,"Commit changes?                        ")
  CALL accept(20,31,"X;CU","N")
  IF (curaccept="Y")
   COMMIT
  ELSE
   ROLLBACK
  ENDIF
 ELSE
  CALL text(20,4,"Press Enter to go back to the Main Menu")
  CALL accept(20,43,"P"," ")
 ENDIF
 GO TO menu
#check_defaults
 SELECT INTO "nl:"
  cp.ce_prefs_id
  FROM ce_prefs cp
  WHERE cp.pref_name=name
  DETAIL
   cvalue = cp.pref_value
  WITH nocounter
 ;end select
 IF (curqual > 0
  AND value=cvalue)
  GO TO 1
 ENDIF
 IF (curqual > 0
  AND value != cvalue)
  SET nsize = textlen(trim(name))
  SET vsize = textlen(trim(value))
  CALL text(20,15,"                                       ")
  CALL text(15,5,"Clinical Event preference for ")
  CALL text(15,35,name)
  CALL text(15,(36+ nsize),"value=")
  CALL text(15,(43+ nsize),cvalue)
  CALL text(16,5,"already exists, overwrite with value=")
  CALL text(16,42,value)
  CALL text(16,(43+ vsize)," (Y/N)?")
  CALL accept(16,(50+ vsize),"X;CU","N")
  IF (curaccept != "Y")
   CALL text(15,5,"                                                                ")
   CALL text(16,5,"                                                                ")
   GO TO 1
  ENDIF
  CALL text(15,5,"                                                                ")
  CALL text(16,5,"                                                                ")
  GO TO update_defaults
 ENDIF
#insert_default
 SET changes = "Y"
 CALL text(20,15,"Inserting in database...                   ")
 SELECT INTO "nl:"
  w = seq(ocf_seq,nextval)
  FROM dual
  DETAIL
   cpid = w
  WITH format, nocounter
 ;end select
 INSERT  FROM ce_prefs
  SET ce_prefs_id = cpid, pref_name = name, pref_value = value,
   updt_dt_tm = cnvtdatetime(curdate,curtime), updt_id = 0, updt_task = 0,
   updt_cnt = 0, updt_applctx = 0
 ;end insert
 GO TO 1
#update_defaults
 SET changes = "Y"
 CALL text(20,15,"Updating database...                   ")
 UPDATE  FROM ce_prefs
  SET pref_value = value, updt_dt_tm = cnvtdatetime(curdate,curtime), updt_id = 0,
   updt_task = 0, updt_cnt = (updt_cnt+ 1), updt_applctx = 0
  WHERE pref_name=name
 ;end update
 GO TO 1
 GO TO menu
#set_prefs
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(3,26,"** CLINICAL EVENT PREFERENCES **")
 CALL text(8,3,"Pref name:")
 CALL text(9,3,"Pref value:")
#restart
 SET name = "                                "
 SET value = "                                                                       "
 SET cvalue = "                                "
 SET cpid = 0.0
 SET all_fields = "Y"
 CALL text(20,15,"                                       ")
#pref_name
 CALL accept(8,23,"PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP;CU",name)
 IF (curaccept != " ")
  SET name = curaccept
 ELSE
  SET all_fields = "N"
 ENDIF
#pref_value
 CALL accept(9,23,"PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP;CU",value)
 IF (curaccept != " ")
  SET value = curaccept
 ELSE
  SET all_fields = "N"
  GO TO check_all_fields
 ENDIF
#check_all_fields
 IF (all_fields="N")
  CALL text(15,10,"Pref name/value fields need to be valued.  Exit screen? (Y/N)")
  CALL accept(15,73,"X;CU","Y")
  IF (curaccept="Y")
   GO TO exit_program
  ELSE
   CALL text(15,10,"                                                                  ")
   GO TO restart
  ENDIF
 ENDIF
#duplicates
 CALL text(20,15,"Checking for duplicate record...       ")
#check_existing
 SELECT INTO "nl:"
  cp.ce_prefs_id
  FROM ce_prefs cp
  WHERE cp.pref_name=name
  DETAIL
   cvalue = cp.pref_value
  WITH nocounter
 ;end select
 IF (curqual > 0
  AND value=cvalue)
  GO TO check_for_more
 ENDIF
 IF (curqual > 0
  AND value != cvalue)
  CALL text(20,15,"                                       ")
  CALL text(15,10,"Clinical Event preference already exists, overwrite? (Y/N)")
  CALL accept(15,69,"X;CU","N")
  IF (curaccept != "Y")
   GO TO check_for_more
  ENDIF
  CALL text(15,10,"                                                                          ")
  GO TO update_prefs
 ENDIF
#insert_prefs
 CALL text(20,15,"Updating database...                   ")
 SELECT INTO "nl:"
  w = seq(ocf_seq,nextval)
  FROM dual
  DETAIL
   cpid = w
  WITH format, nocounter
 ;end select
 INSERT  FROM ce_prefs
  SET ce_prefs_id = cpid, pref_name = name, pref_value = value,
   updt_dt_tm = cnvtdatetime(curdate,curtime), updt_id = 0, updt_task = 0,
   updt_cnt = 0, updt_applctx = 0
 ;end insert
 GO TO check_for_more
#update_prefs
 CALL text(20,15,"Updating database...                   ")
 UPDATE  FROM ce_prefs
  SET pref_value = value, updt_dt_tm = cnvtdatetime(curdate,curtime), updt_id = 0,
   updt_task = 0, updt_cnt = (updt_cnt+ 1), updt_applctx = 0
  WHERE pref_name=name
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
 GO TO menu
#skip_commit
END GO
