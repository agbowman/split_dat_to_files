CREATE PROGRAM cps_upd_nomen_cat:dba
 FREE SET hold
 RECORD hold(
   1 person_knt = i4
   1 person[*]
     2 person_id = f8
     2 nomen_id = f8
     2 cat_name = vc
     2 cat_type_cd = f8
 )
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
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET error_level = 0
 SET readme_data->message = concat("CPS_UPD_NOMEN_CAT BEG : ",format(cnvtdatetime(curdate,curtime3),
   "dd-mmm-yyyy hh:mm:ss;;d"))
 EXECUTE dm_readme_status
 SET code_value = 0.0
 SET code_set = 25321
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "DIAGNOSIS"
 EXECUTE cpm_get_cd_for_cdf
 SET category_type_cd = code_value
 IF (code_value < 1)
  SET readme_data->message = concat("   ERROR  : Could not find cdf_meaning ",trim(cdf_meaning),
   " in code_set ",trim(cnvtstring(code_set)))
  EXECUTE dm_readme_status
  SET error_level = 1
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM nomen_category n
  PLAN (n
   WHERE n.category_name="*_DIAG*"
    AND n.parent_entity_id < 1)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  IF (ierrcode > 0)
   SET readme_data->message = "ERROR :: A script error occurred searching for cat name"
   EXECUTE dm_readme_status
   SET readme_data->message = trim(serrmsg)
   EXECUTE dm_readme_status
   SET error_level = 1
   GO TO exit_script
  ELSE
   GO TO others
  ENDIF
 ENDIF
 SET cat_name = fillstring(30," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM nomen_category n,
   prsnl p
  PLAN (n
   WHERE n.category_name="*_DIAG"
    AND n.parent_entity_id < 1
    AND n.category_type_cd < 1)
   JOIN (p
   WHERE p.username=substring(1,(findstring("_",n.category_name) - 1),n.category_name)
    AND p.active_ind=1)
  ORDER BY n.category_name
  HEAD REPORT
   knt = 0
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1)
    stat = alterlist(hold->person,(knt+ 10))
   ENDIF
   x = findstring("_DIAG",n.category_name), user_name = substring(1,(x - 1),n.category_name), hold->
   person[knt].nomen_id = n.nomen_category_id,
   hold->person[knt].cat_name = concat(trim(user_name),"_DIAGNOSIS"), hold->person[knt].cat_type_cd
    = category_type_cd, hold->person[knt].person_id = p.person_id
  FOOT REPORT
   hold->person_knt = knt, stat = alterlist(hold->person,knt)
  WITH nocounter
 ;end select
 IF ((hold->person_knt < 1))
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET readme_data->message = "ERROR :: A script error occurred getting the user name"
   EXECUTE dm_readme_status
   SET readme_data->message = trim(serrmsg)
   EXECUTE dm_readme_status
   SET error_level = 1
   GO TO exit_script
  ELSE
   SET readme_data->message = "Info  : There is no data to update in Nomen_Category table"
   EXECUTE dm_readme_status
   GO TO exit_script
  ENDIF
 ELSE
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  UPDATE  FROM nomen_category n,
    (dummyt d  WITH seq = value(hold->person_knt))
   SET n.category_type_cd = hold->person[d.seq].cat_type_cd, n.category_name = hold->person[d.seq].
    cat_name, n.parent_entity_name = "PRSNL",
    n.updt_cnt = (n.updt_cnt+ 1), n.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (d
    WHERE d.seq > 0)
    JOIN (n
    WHERE (n.nomen_category_id=hold->person[d.seq].nomen_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET readme_data->message = "ERROR :: A script error occurred getting the user name"
   EXECUTE dm_readme_status
   SET readme_data->message = trim(serrmsg)
   EXECUTE dm_readme_status
   SET error_level = 1
   GO TO exit_script
  ENDIF
 ENDIF
#others
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM nomen_category n
  PLAN (n
   WHERE n.category_name != "*_DIAG*"
    AND n.parent_entity_id < 1
    AND n.category_type_cd < 1)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET readme_data->message =
   "ERROR :: A script error occurred searching for cat name other than DIAG"
   EXECUTE dm_readme_status
   SET readme_data->message = trim(serrmsg)
   EXECUTE dm_readme_status
   SET error_level = 1
   GO TO exit_script
  ELSE
   GO TO exit_script
  ENDIF
 ENDIF
 SET cat_name = fillstring(30," ")
 FREE SET hold1
 RECORD hold1(
   1 person_knt = i4
   1 person[*]
     2 nomen_id = f8
     2 cat_name = vc
     2 cat_type_cd = f8
 )
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM nomen_category n
  PLAN (n
   WHERE n.category_name != "*_DIAG*"
    AND n.category_type_cd < 1
    AND n.parent_entity_id < 1
    AND n.category_type_cd < 1)
  ORDER BY n.category_name
  HEAD REPORT
   knt = 0
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1)
    stat = alterlist(hold1->person,(knt+ 10))
   ENDIF
   hold1->person[knt].nomen_id = n.nomen_category_id, hold1->person[knt].cat_name = n.category_name,
   hold1->person[knt].cat_type_cd = category_type_cd
  FOOT REPORT
   hold1->person_knt = knt, stat = alterlist(hold1->person,knt)
  WITH nocounter
 ;end select
 IF ((hold1->person_knt < 1))
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET readme_data->message = "ERROR :: A script error occurred getting the cat name other than diag"
   EXECUTE dm_readme_status
   SET readme_data->message = trim(serrmsg)
   EXECUTE dm_readme_status
   SET error_level = 1
   GO TO exit_script
  ELSE
   GO TO exit_script
  ENDIF
 ELSE
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  UPDATE  FROM nomen_category n,
    (dummyt d  WITH seq = value(hold1->person_knt))
   SET n.category_type_cd = hold1->person[d.seq].cat_type_cd, n.updt_cnt = (n.updt_cnt+ 1), n
    .updt_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (d)
    JOIN (n
    WHERE (n.nomen_category_id=hold1->person[d.seq].nomen_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET readme_data->message = "ERROR :: A script error occurred when update"
   EXECUTE dm_readme_status
   SET readme_data->message = trim(serrmsg)
   EXECUTE dm_readme_status
   SET error_level = 1
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (error_level=1)
  ROLLBACK
  SET status_msg = "FAILURE"
  SET readme_data->status = "F"
 ELSE
  COMMIT
  SET status_msg = "SUCCESS"
  SET readme_data->status = "S"
 ENDIF
 SET readme_data->message = concat("CPS_UPD_NOMEN_CAT  END : ",trim(status_msg),"  ",format(
   cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 EXECUTE dm_readme_status
 COMMIT
END GO
