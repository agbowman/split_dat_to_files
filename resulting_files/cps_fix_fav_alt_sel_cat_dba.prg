CREATE PROGRAM cps_fix_fav_alt_sel_cat:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
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
 FREE SET temp
 RECORD temp(
   1 qual_knt = i4
   1 qual[*]
     2 username = vc
     2 alt_sel_cat_id = f8
 )
 FREE SET fav_cat
 RECORD fav_cat(
   1 qual_knt = i4
   1 qual[*]
     2 person_id = f8
     2 username = vc
     2 cat_name = vc
     2 alt_sel_cat_id = f8
     2 dup_cat_ind = i2
     2 dup_cat_id = f8
 )
 SET error_level = 0
 SET readme_data->message = concat("CPS_FIX_ALT_SEL_CAT  BEG : ",format(cnvtdatetime(curdate,curtime3
    ),"dd-mmm-yyyy hh:mm:ss;;d"))
 EXECUTE dm_readme_status
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 UPDATE  FROM alt_sel_cat
  SET owner_id = 0
  WHERE security_flag=2
  WITH check
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET readme_data->message = "ERROR :: Setting the owner_id equal to zero for public folders"
  EXECUTE dm_readme_status
  SET readme_data->message = trim(serrmsg)
  EXECUTE dm_readme_status
  SET error_level = 1
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM alt_sel_cat ac
  PLAN (ac
   WHERE ac.long_description_key_cap="*_MED")
  HEAD REPORT
   knt = 0, stat = alterlist(temp->qual,10)
  DETAIL
   pos = 0, pos = (findstring("_MED",ac.long_description_key_cap) - 1)
   IF (pos > 0)
    knt = (knt+ 1)
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(temp->qual,(knt+ 9))
    ENDIF
    temp->qual[knt].username = substring(1,pos,ac.long_description), temp->qual[knt].alt_sel_cat_id
     = ac.alt_sel_category_id
   ENDIF
  FOOT REPORT
   temp->qual_knt = knt, stat = alterlist(temp->qual,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET readme_data->message = "ERROR :: A script error occurred finding old Medication favorites"
  EXECUTE dm_readme_status
  SET readme_data->message = trim(serrmsg)
  EXECUTE dm_readme_status
  SET error_level = 1
  GO TO exit_script
 ENDIF
 IF ((temp->qual_knt > 0))
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   d.seq, p.updt_dt_tm
   FROM (dummyt d  WITH seq = value(temp->qual_knt)),
    prsnl p
   PLAN (d
    WHERE d.seq > 0)
    JOIN (p
    WHERE (p.username=temp->qual[d.seq].username)
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY d.seq, cnvtdatetime(p.updt_dt_tm) DESC
   HEAD REPORT
    knt = 0, stat = alterlist(fav_cat->qual,10)
   HEAD d.seq
    knt = (knt+ 1)
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(fav_cat->qual,(knt+ 9))
    ENDIF
    fav_cat->qual[knt].person_id = p.person_id, fav_cat->qual[knt].username = temp->qual[d.seq].
    username, fav_cat->qual[knt].cat_name = trim(concat(trim(p.username),"_MEDICATIONS")),
    fav_cat->qual[knt].alt_sel_cat_id = temp->qual[d.seq].alt_sel_cat_id
   DETAIL
    dvar = 0
   FOOT REPORT
    fav_cat->qual_knt = knt, stat = alterlist(fav_cat->qual,knt)
   WITH nocounter, outerjoin = d
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET readme_data->message = "ERROR :: A script error occurred finding old Medication favorites"
   EXECUTE dm_readme_status
   SET readme_data->message = trim(serrmsg)
   EXECUTE dm_readme_status
   SET error_level = 1
   GO TO exit_script
  ENDIF
 ELSE
  SET readme_data->message = "INFO :: No user Medication favorites found"
  EXECUTE dm_readme_status
  GO TO order_favorites
 ENDIF
 SET found_dups = false
 SELECT INTO "nl:"
  a.alt_sel_category_id, d.seq
  FROM alt_sel_cat a,
   (dummyt d  WITH seq = value(fav_cat->qual_knt))
  PLAN (d
   WHERE d.seq > 0)
   JOIN (a
   WHERE a.long_description_key_cap=cnvtupper(fav_cat->qual[d.seq].cat_name)
    AND (a.alt_sel_category_id != fav_cat->qual[d.seq].alt_sel_cat_id))
  DETAIL
   found_dups = true, fav_cat->qual[d.seq].dup_cat_ind = true, fav_cat->qual[d.seq].dup_cat_id = a
   .alt_sel_category_id
  WITH nocounter
 ;end select
 IF (found_dups=true)
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  UPDATE  FROM alt_sel_list asl,
    (dummyt d  WITH seq = value(fav_cat->qual_knt))
   SET asl.alt_sel_category_id = fav_cat->qual[d.seq].dup_cat_id, asl.updt_cnt = (asl.updt_cnt+ 1),
    asl.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    asl.updt_id = reqinfo->updt_id, asl.updt_applctx = reqinfo->updt_applctx, asl.updt_task = reqinfo
    ->updt_task
   PLAN (d
    WHERE d.seq > 0
     AND (fav_cat->qual[d.seq].dup_cat_ind=true))
    JOIN (asl
    WHERE (asl.alt_sel_category_id=fav_cat->qual[d.seq].alt_sel_cat_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET readme_data->message = "ERROR :: Fixing duplicate Medication favorites"
   EXECUTE dm_readme_status
   SET readme_data->message = trim(serrmsg)
   EXECUTE dm_readme_status
   SET error_level = 1
   ROLLBACK
   GO TO exit_script
  ENDIF
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  UPDATE  FROM alt_sel_list asl,
    (dummyt d  WITH seq = value(fav_cat->qual_knt))
   SET asl.child_alt_sel_cat_id = fav_cat->qual[d.seq].dup_cat_id, asl.updt_cnt = (asl.updt_cnt+ 1),
    asl.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    asl.updt_id = reqinfo->updt_id, asl.updt_applctx = reqinfo->updt_applctx, asl.updt_task = reqinfo
    ->updt_task
   PLAN (d
    WHERE d.seq > 0
     AND (fav_cat->qual[d.seq].dup_cat_ind=true))
    JOIN (asl
    WHERE (asl.child_alt_sel_cat_id=fav_cat->qual[d.seq].alt_sel_cat_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET readme_data->message = "ERROR :: Fixing duplicate Medication favorites"
   EXECUTE dm_readme_status
   SET readme_data->message = trim(serrmsg)
   EXECUTE dm_readme_status
   SET error_level = 1
   ROLLBACK
   GO TO exit_script
  ENDIF
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  UPDATE  FROM alt_sel_cat ac,
    (dummyt d  WITH seq = value(fav_cat->qual_knt))
   SET ac.short_description = "Favorites", ac.long_description = fav_cat->qual[d.seq].cat_name, ac
    .long_description_key_cap = cnvtupper(fav_cat->qual[d.seq].cat_name),
    ac.owner_id = fav_cat->qual[d.seq].person_id, ac.security_flag = 1, ac.updt_cnt = 0,
    ac.updt_dt_tm = cnvtdatetime(curdate,curtime3), ac.updt_id = 12.14
   PLAN (d
    WHERE d.seq > 0
     AND (fav_cat->qual[d.seq].person_id > 0)
     AND (fav_cat->qual[d.seq].dup_cat_ind=true))
    JOIN (ac
    WHERE (ac.alt_sel_category_id=fav_cat->qual[d.seq].dup_cat_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET readme_data->message = "ERROR :: Fixing duplicate Medication favorites"
   EXECUTE dm_readme_status
   SET readme_data->message = trim(serrmsg)
   EXECUTE dm_readme_status
   SET error_level = 1
   ROLLBACK
   GO TO exit_script
  ENDIF
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  DELETE  FROM alt_sel_cat ac,
    (dummyt d  WITH seq = value(fav_cat->qual_knt))
   SET ac.seq = 1
   PLAN (d
    WHERE d.seq > 0
     AND (fav_cat->qual[d.seq].dup_cat_ind=true))
    JOIN (ac
    WHERE (ac.alt_sel_category_id=fav_cat->qual[d.seq].alt_sel_cat_id))
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET readme_data->message = "ERROR :: Fixing duplicate Medication favorites"
   EXECUTE dm_readme_status
   SET readme_data->message = trim(serrmsg)
   EXECUTE dm_readme_status
   SET error_level = 1
   ROLLBACK
   GO TO exit_script
  ENDIF
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 UPDATE  FROM alt_sel_cat ac,
   (dummyt d  WITH seq = value(fav_cat->qual_knt))
  SET ac.short_description = "Favorites", ac.long_description = fav_cat->qual[d.seq].cat_name, ac
   .long_description_key_cap = cnvtupper(fav_cat->qual[d.seq].cat_name),
   ac.owner_id = fav_cat->qual[d.seq].person_id, ac.security_flag = 1, ac.updt_cnt = 0,
   ac.updt_dt_tm = cnvtdatetime(curdate,curtime3), ac.updt_id = 12.34
  PLAN (d
   WHERE d.seq > 0
    AND (fav_cat->qual[d.seq].person_id > 0)
    AND (fav_cat->qual[d.seq].dup_cat_ind=0))
   JOIN (ac
   WHERE (ac.alt_sel_category_id=fav_cat->qual[d.seq].alt_sel_cat_id))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET readme_data->message = "ERROR :: Updating Medication favorites"
  EXECUTE dm_readme_status
  SET readme_data->message = trim(serrmsg)
  EXECUTE dm_readme_status
  SET error_level = 1
  ROLLBACK
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
#order_favorites
 FREE SET temp
 RECORD temp(
   1 qual_knt = i4
   1 qual[*]
     2 username = vc
     2 alt_sel_cat_id = f8
 )
 FREE SET fav_cat
 RECORD fav_cat(
   1 qual_knt = i4
   1 qual[*]
     2 person_id = f8
     2 username = vc
     2 cat_name = vc
     2 alt_sel_cat_id = f8
     2 dup_cat_ind = i2
     2 dup_cat_id = f8
 )
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM alt_sel_cat ac
  PLAN (ac
   WHERE ac.long_description_key_cap="*_ORD")
  HEAD REPORT
   knt = 0, stat = alterlist(temp->qual,10)
  DETAIL
   pos = 0, pos = (findstring("_ORD",ac.long_description_key_cap) - 1)
   IF (pos > 0)
    knt = (knt+ 1)
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(temp->qual,(knt+ 9))
    ENDIF
    temp->qual[knt].username = substring(1,pos,ac.long_description), temp->qual[knt].alt_sel_cat_id
     = ac.alt_sel_category_id
   ENDIF
  FOOT REPORT
   temp->qual_knt = knt, stat = alterlist(temp->qual,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET readme_data->message = "ERROR :: A script error occurred finding old Order favorites"
  EXECUTE dm_readme_status
  SET readme_data->message = trim(serrmsg)
  EXECUTE dm_readme_status
  SET error_level = 1
  GO TO exit_script
 ENDIF
 IF ((temp->qual_knt > 0))
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   d.seq, p.updt_dt_tm
   FROM (dummyt d  WITH seq = value(temp->qual_knt)),
    prsnl p
   PLAN (d
    WHERE d.seq > 0)
    JOIN (p
    WHERE (p.username=temp->qual[d.seq].username)
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY d.seq, cnvtdatetime(p.updt_dt_tm) DESC
   HEAD REPORT
    knt = 0, stat = alterlist(fav_cat->qual,10)
   HEAD d.seq
    knt = (knt+ 1)
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(fav_cat->qual,(knt+ 9))
    ENDIF
    fav_cat->qual[knt].person_id = p.person_id, fav_cat->qual[knt].username = temp->qual[d.seq].
    username, fav_cat->qual[knt].cat_name = trim(concat(trim(p.username),"_ORD")),
    fav_cat->qual[knt].alt_sel_cat_id = temp->qual[d.seq].alt_sel_cat_id
   DETAIL
    dvar = 0
   FOOT REPORT
    fav_cat->qual_knt = knt, stat = alterlist(fav_cat->qual,knt)
   WITH nocounter, outerjoin = d
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET readme_data->message = "ERROR :: A script error occurred finding old Order favorites"
   EXECUTE dm_readme_status
   SET readme_data->message = trim(serrmsg)
   EXECUTE dm_readme_status
   SET error_level = 1
   GO TO exit_script
  ENDIF
 ELSE
  SET readme_data->message = "INFO :: No user Order favorites found"
  EXECUTE dm_readme_status
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 UPDATE  FROM alt_sel_cat ac,
   (dummyt d  WITH seq = value(fav_cat->qual_knt))
  SET ac.short_description = "Favorites", ac.long_description = fav_cat->qual[d.seq].cat_name, ac
   .long_description_key_cap = cnvtupper(fav_cat->qual[d.seq].cat_name),
   ac.owner_id = fav_cat->qual[d.seq].person_id, ac.security_flag = 1, ac.updt_cnt = (ac.updt_cnt+ 1),
   ac.updt_dt_tm = cnvtdatetime(curdate,curtime3), ac.updt_id = 12.34
  PLAN (d
   WHERE d.seq > 0
    AND (fav_cat->qual[d.seq].person_id > 0))
   JOIN (ac
   WHERE (ac.alt_sel_category_id=fav_cat->qual[d.seq].alt_sel_cat_id))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET readme_data->message = "ERROR :: Updating Order favorites"
  EXECUTE dm_readme_status
  SET readme_data->message = trim(serrmsg)
  EXECUTE dm_readme_status
  SET error_level = 1
  ROLLBACK
  GO TO exit_script
 ELSE
  SET readme_data->message = "SUCCESS :: Updating Order favorites"
  EXECUTE dm_readme_status
  COMMIT
 ENDIF
#exit_script
 IF (error_level != 1)
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  UPDATE  FROM alt_sel_cat ac
   SET ac.updt_cnt = 0
   PLAN (ac
    WHERE ac.long_description_key_cap="*_MEDICATIONS")
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET readme_data->message = "ERROR :: Updating Medication favorites"
   EXECUTE dm_readme_status
   SET readme_data->message = trim(serrmsg)
   EXECUTE dm_readme_status
   SET error_level = 1
   ROLLBACK
  ELSE
   SET readme_data->message = "SUCCESS  : Updating Medication favorites"
   EXECUTE dm_readme_status
   COMMIT
  ENDIF
  UPDATE  FROM alt_sel_cat
   SET updt_cnt = 0
   WHERE long_description_key_cap="*_ORD"
   WITH nocounter
  ;end update
 ENDIF
 IF (error_level=1)
  SET status_msg = "FAILURE"
  SET readme_data->status = "F"
 ELSE
  SET status_msg = "SUCCESS"
  SET readme_data->status = "S"
 ENDIF
 SET readme_data->message = concat("CPS_FIX_ALT_SEL_CAT  END : ",trim(status_msg),"  ",format(
   cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 EXECUTE dm_readme_status
 COMMIT
 SET script_version = "002 10/26/04 SF3151"
END GO
