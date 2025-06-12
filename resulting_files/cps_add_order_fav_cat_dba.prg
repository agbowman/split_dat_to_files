CREATE PROGRAM cps_add_order_fav_cat:dba
 SET false = 0
 SET true = 1
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SET username = trim(cnvtupper( $1))
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  CALL echo("***")
  CALL echo("***")
  CALL echo("***   The username must be surrounded by quotes.")
  CALL echo("***")
  CALL echo("***")
  GO TO exit_script
 ENDIF
 SET owner_id = 0.0
 SET dvar = 0
 SELECT INTO "nl:"
  p.person_id, p.updt_dt_tm
  FROM prsnl p
  PLAN (p
   WHERE p.username=username
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY p.updt_dt_tm DESC
  HEAD REPORT
   owner_id = p.person_id
  DETAIL
   dvar = dvar
  WITH nocounter
 ;end select
 CALL echo("***")
 IF (curqual > 0)
  CALL echo("*** ")
  CALL echo(concat("***   Building an Orders favorite category for ",username," with a person_id of ",
    trim(cnvtstring(owner_id))))
  CALL echo("*** ")
  CALL echo("***")
 ELSE
  CALL echo("*** ")
  CALL echo(concat("***   An active and effective user with a username of ",username,
    " was not found on the PRSNL table."))
  CALL echo("*** ")
  CALL echo("***")
  GO TO exit_script
 ENDIF
 SET towner_id = 0.0
 SET tsecurity_flag = 0
 SET alt_sel_cat_id = 0.0
 SELECT INTO "nl:"
  FROM alt_sel_cat ac
  PLAN (ac
   WHERE ac.long_description_key_cap=concat(username,"_ORD"))
  HEAD REPORT
   towner_id = ac.owner_id, tsecurity_flag = ac.security_flag, alt_sel_cat_id = ac
   .alt_sel_category_id
  DETAIL
   dvar = dvar
  WITH nocounter
 ;end select
 IF (curqual > 0)
  IF (((towner_id != owner_id) OR (tsecurity_flag != 1)) )
   CALL echo("***")
   CALL echo("***")
   CALL echo(concat("***   User ",username," has an invalid Orders favorite category."))
   CALL echo("***   I Will now fix the Orders favorite category for the user.")
   CALL echo("***")
   CALL echo("***")
   UPDATE  FROM alt_sel_cat ac
    SET ac.owner_id = owner_id, ac.security_flag = 1
    WHERE ac.alt_sel_category_id=alt_sel_cat_id
     AND ac.long_description_key_cap=concat(username,"_ORD")
    WITH nocounter
   ;end update
   IF (curqual != 1)
    CALL echo("***")
    CALL echo("***")
    CALL echo(concat("***   An ERROR occurred fixing the Orders favorite category for user ",username
      ))
    CALL echo("***")
    CALL echo("***")
    ROLLBACK
   ELSE
    CALL echo("***")
    CALL echo("***")
    CALL echo(concat("***   The Orders favorite category for user ",username," has been fixed."))
    CALL echo("***")
    CALL echo("***")
    COMMIT
   ENDIF
   GO TO exit_script
  ELSE
   CALL echo("***")
   CALL echo("***")
   CALL echo(concat("***   User ",username,
     " has a valid Orders favorite category.  No action required."))
   CALL echo("***")
   CALL echo("***")
   GO TO exit_script
  ENDIF
 ENDIF
 CALL echo("***")
 CALL echo("***")
 CALL echo(concat("***   Creating the Orders favorite category for user ",username,"."))
 CALL echo("***")
 CALL echo("***")
 FREE SET request
 RECORD request(
   1 short_description = vc
   1 long_description = vc
   1 child_cat_ind = i2
   1 owner_id = f8
   1 security_flag = i2
   1 aoslist_cnt = i4
   1 aoslist_qual[*]
     2 sequence = i4
     2 list_type = i4
     2 synonym_id = f8
     2 child_alt_sel_cat_id = f8
 )
 SET request->short_description = "Favorites"
 SET request->long_description = concat(username,"_ORD")
 SET request->child_cat_ind = 0
 SET request->owner_id = owner_id
 SET request->security_flag = 1
 SET request->aoslist_cnt = 0
 EXECUTE orm_add_aos_cat_info
 SELECT INTO "nl:"
  FROM alt_sel_cat ac
  PLAN (ac
   WHERE ac.long_description_key_cap=concat(username,"_ORD"))
  WITH nocounter
 ;end select
 IF (curqual != 1)
  CALL echo("***")
  CALL echo("***")
  CALL echo(concat("***   An ERROR occurred adding the Orders favorite category for user ",username))
  CALL echo("***")
  CALL echo("***")
  ROLLBACK
 ELSE
  CALL echo("***")
  CALL echo("***")
  CALL echo(concat("***   The Orders favorite category for user ",username," has been added."))
  CALL echo("***")
  CALL echo("***")
  COMMIT
 ENDIF
#exit_script
END GO
