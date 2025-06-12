CREATE PROGRAM ams_upload_prsnl_alias:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Directory" = "",
  "Pass Input File name Here" = ""
  WITH outdev, directory, inputfile
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
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 DECLARE smessage = vc WITH protect, noconstant("")
 FREE RECORD rdata
 RECORD rdata(
   1 qual_knt = i4
   1 qual[*]
     2 object_name = vc
     2 user_name = vc
     2 compiled_dt_tm = vc
     2 source_name = vc
 )
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 FREE RECORD req_upload
 RECORD req_upload(
   1 prsnl_list[*]
     2 facility = vc
     2 person_id = vc
     2 malaffi_pos = vc
     2 username = vc
     2 full_name = vc
     2 first_name = vc
     2 middle_name = vc
     2 last_name = vc
     2 licenseid = vc
     2 oracle_id = vc
 )
 FREE RECORD users_exist
 RECORD users_exist(
   1 prsnl_list[*]
     2 facility = vc
     2 person_id = vc
     2 malaffi_pos = vc
     2 username = vc
     2 full_name = vc
     2 first_name = vc
     2 middle_name = vc
     2 last_name = vc
     2 licenseid = vc
     2 oracle_id = vc
 )
 FREE RECORD user_not_exist
 RECORD user_not_exist(
   1 prsnl_list[*]
     2 facility = vc
     2 person_id = vc
     2 malaffi_pos = vc
     2 username = vc
     2 full_name = vc
     2 first_name = vc
     2 middle_name = vc
     2 last_name = vc
     2 licenseid = vc
     2 oracle_id = vc
     2 reason = vc
 )
 FREE RECORD user_has_alias
 RECORD user_has_alias(
   1 prsnl_list[*]
     2 facility = vc
     2 person_id = vc
     2 malaffi_pos = vc
     2 username = vc
     2 full_name = vc
     2 first_name = vc
     2 middle_name = vc
     2 last_name = vc
     2 licenseid = vc
     2 oracle_id = vc
     2 reason = vc
 )
 FREE RECORD new_users
 RECORD new_users(
   1 prsnl_list[*]
     2 facility = vc
     2 person_id = vc
     2 malaffi_pos = vc
     2 username = vc
     2 full_name = vc
     2 first_name = vc
     2 middle_name = vc
     2 last_name = vc
     2 licenseid = vc
     2 oracle_id = vc
 )
 FREE RECORD insert_fails
 RECORD insert_fails(
   1 prsnl_list[*]
     2 facility = vc
     2 person_id = vc
     2 malaffi_pos = vc
     2 username = vc
     2 full_name = vc
     2 first_name = vc
     2 middle_name = vc
     2 last_name = vc
     2 licenseid = vc
     2 oracle_id = vc
     2 reason = vc
 )
 DECLARE aliascnt = i4
 DECLARE dupcnt = i4
 DECLARE cntuser = i4
 DECLARE cntnouser = i4
 DECLARE cntalias = i4
 DECLARE cntnew = i4
 DECLARE alias_id = f8
 DECLARE per_id = f8
 DECLARE prsnl_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",320,"PRSNLID"))
 SET path = value(logical( $DIRECTORY))
 SET infile =  $INPUTFILE
 SET file_path = build(path,":",infile)
 CALL echo(build(path,":",infile))
 CALL echo(file_path)
 DEFINE rtl2 value(file_path)
 SELECT INTO  $1
  r.line
  FROM rtl2t r
  HEAD REPORT
   row_count = 0
  HEAD r.line
   line1 = r.line
   IF (row_count > 0)
    stat = alterlist(req_upload->prsnl_list,row_count), req_upload->prsnl_list[row_count].facility =
    piece(r.line,",",1,"not found"), req_upload->prsnl_list[row_count].person_id = piece(r.line,",",2,
     "not found"),
    req_upload->prsnl_list[row_count].malaffi_pos = piece(r.line,",",3,"not found"), req_upload->
    prsnl_list[row_count].username = piece(r.line,",",4,"not found"), req_upload->prsnl_list[
    row_count].full_name = piece(r.line,",",5,"not found"),
    req_upload->prsnl_list[row_count].first_name = piece(r.line,",",6,"not found"), req_upload->
    prsnl_list[row_count].middle_name = piece(r.line,",",7,"not found"), req_upload->prsnl_list[
    row_count].last_name = piece(r.line,",",8,"not found"),
    req_upload->prsnl_list[row_count].licenseid = piece(r.line,",",9,"not found"), req_upload->
    prsnl_list[row_count].oracle_id = piece(r.line,",",10,"not found")
   ENDIF
   row_count = (row_count+ 1)
  WITH nocounter
 ;end select
 FOR (k = 1 TO size(req_upload->prsnl_list,5))
   SELECT INTO "nl:"
    p.person_id
    FROM prsnl p
    WHERE (p.username=req_upload->prsnl_list[k].username)
    HEAD REPORT
     row + 0
    FOOT REPORT
     aliascnt = count(p.person_id)
    WITH nocounter
   ;end select
   IF (aliascnt > 0)
    CALL echo("if condition")
    SET cntuser = (cntuser+ 1)
    SET stat = alterlist(users_exist->prsnl_list,cntuser)
    SET users_exist->prsnl_list[cntuser].facility = req_upload->prsnl_list[k].facility
    SET users_exist->prsnl_list[cntuser].person_id = req_upload->prsnl_list[k].person_id
    SET users_exist->prsnl_list[cntuser].malaffi_pos = req_upload->prsnl_list[k].malaffi_pos
    SET users_exist->prsnl_list[cntuser].username = req_upload->prsnl_list[k].username
    SET users_exist->prsnl_list[cntuser].full_name = req_upload->prsnl_list[k].full_name
    SET users_exist->prsnl_list[cntuser].first_name = req_upload->prsnl_list[k].first_name
    SET users_exist->prsnl_list[cntuser].first_name = req_upload->prsnl_list[k].middle_name
    SET users_exist->prsnl_list[cntuser].middle_name = req_upload->prsnl_list[k].last_name
    SET users_exist->prsnl_list[cntuser].licenseid = req_upload->prsnl_list[k].licenseid
    SET users_exist->prsnl_list[cntuser].oracle_id = req_upload->prsnl_list[k].oracle_id
   ELSE
    CALL echo("else condition")
    SET cntnouser = (cntnouser+ 1)
    SET stat = alterlist(user_not_exist->prsnl_list,cntnouser)
    SET user_not_exist->prsnl_list[cntnouser].facility = req_upload->prsnl_list[k].facility
    SET user_not_exist->prsnl_list[cntnouser].person_id = req_upload->prsnl_list[k].person_id
    SET user_not_exist->prsnl_list[cntnouser].malaffi_pos = req_upload->prsnl_list[k].malaffi_pos
    SET user_not_exist->prsnl_list[cntnouser].username = req_upload->prsnl_list[k].username
    SET user_not_exist->prsnl_list[cntnouser].full_name = req_upload->prsnl_list[k].full_name
    SET user_not_exist->prsnl_list[cntnouser].first_name = req_upload->prsnl_list[k].first_name
    SET user_not_exist->prsnl_list[cntnouser].first_name = req_upload->prsnl_list[k].middle_name
    SET user_not_exist->prsnl_list[cntnouser].middle_name = req_upload->prsnl_list[k].last_name
    SET user_not_exist->prsnl_list[cntnouser].licenseid = req_upload->prsnl_list[k].licenseid
    SET user_not_exist->prsnl_list[cntnouser].oracle_id = req_upload->prsnl_list[k].oracle_id
    SET user_not_exist->prsnl_list[cntnouser].reason = "User not existed in domain"
   ENDIF
   SET aliascnt = 0
 ENDFOR
 FOR (l = 1 TO size(users_exist->prsnl_list,5))
   SELECT INTO "nl:"
    p.person_id
    FROM prsnl p,
     prsnl_alias pa
    PLAN (p
     WHERE (p.username=users_exist->prsnl_list[l].username))
     JOIN (pa
     WHERE p.person_id=pa.person_id
      AND pa.prsnl_alias_type_cd=prsnl_cd)
    HEAD REPORT
     row + 0
    FOOT REPORT
     dupcnt = count(p.person_id)
    WITH nocounter
   ;end select
   IF (dupcnt > 0)
    CALL echo("if condition")
    SET cntalias = (cntalias+ 1)
    SET stat = alterlist(user_has_alias->prsnl_list,cntalias)
    SET user_has_alias->prsnl_list[cntalias].facility = users_exist->prsnl_list[l].facility
    SET user_has_alias->prsnl_list[cntalias].person_id = users_exist->prsnl_list[l].person_id
    SET user_has_alias->prsnl_list[cntalias].malaffi_pos = users_exist->prsnl_list[l].malaffi_pos
    SET user_has_alias->prsnl_list[cntalias].username = users_exist->prsnl_list[l].username
    SET user_has_alias->prsnl_list[cntalias].full_name = users_exist->prsnl_list[l].full_name
    SET user_has_alias->prsnl_list[cntalias].first_name = users_exist->prsnl_list[l].first_name
    SET user_has_alias->prsnl_list[cntalias].first_name = users_exist->prsnl_list[l].middle_name
    SET user_has_alias->prsnl_list[cntalias].middle_name = users_exist->prsnl_list[l].last_name
    SET user_has_alias->prsnl_list[cntalias].licenseid = users_exist->prsnl_list[l].licenseid
    SET user_has_alias->prsnl_list[cntalias].oracle_id = users_exist->prsnl_list[l].oracle_id
    SET user_has_alias->prsnl_list[cntalias].reason = "user has existed alias"
   ELSE
    CALL echo("else condition")
    SET cntnew = (cntnew+ 1)
    SET stat = alterlist(new_users->prsnl_list,cntnew)
    SET new_users->prsnl_list[cntnew].facility = req_upload->prsnl_list[l].facility
    SET new_users->prsnl_list[cntnew].person_id = req_upload->prsnl_list[l].person_id
    SET new_users->prsnl_list[cntnew].malaffi_pos = req_upload->prsnl_list[l].malaffi_pos
    SET new_users->prsnl_list[cntnew].username = req_upload->prsnl_list[l].username
    SET new_users->prsnl_list[cntnew].full_name = req_upload->prsnl_list[l].full_name
    SET new_users->prsnl_list[cntnew].first_name = req_upload->prsnl_list[l].first_name
    SET new_users->prsnl_list[cntnew].first_name = req_upload->prsnl_list[l].middle_name
    SET new_users->prsnl_list[cntnew].middle_name = req_upload->prsnl_list[l].last_name
    SET new_users->prsnl_list[cntnew].licenseid = req_upload->prsnl_list[l].licenseid
    SET new_users->prsnl_list[cntnew].oracle_id = req_upload->prsnl_list[l].oracle_id
   ENDIF
   SET dupcnt = 0
 ENDFOR
 FOR (m = 0 TO size(new_users->prsnl_list,5))
   SELECT INTO "nl:"
    nextseqnum = seq(prsnl_seq,nextval)
    FROM dual
    DETAIL
     alias_id = nextseqnum
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    prsnl_id = pr.person_id
    FROM prsnl pr
    WHERE (pr.username=new_users->prsnl_list[m].username)
    DETAIL
     per_id = prsnl_id
    WITH nocounter
   ;end select
   IF (alias_id > 0)
    CALL echo(alias_id)
    CALL echo(per_id)
    INSERT  FROM prsnl_alias p
     SET p.prsnl_alias_id = alias_id, p.person_id =
      IF (per_id <= 0) 0
      ELSE per_id
      ENDIF
      , p.alias_pool_cd = 0.0,
      p.prsnl_alias_type_cd = prsnl_cd, p.alias =
      IF ((new_users->prsnl_list[m].oracle_id='""')) null
      ELSE new_users->prsnl_list[m].oracle_id
      ENDIF
      , p.prsnl_alias_sub_type_cd = 0.0,
      p.check_digit = 0, p.check_digit_method_cd = 0.0, p.contributor_system_cd = 0,
      p.data_status_cd = 25.00, p.data_status_dt_tm = cnvtdatetime(curdate,curtime3), p
      .data_status_prsnl_id = reqinfo->updt_id,
      p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100 00:00:00.00"), p.active_ind = 1,
      p.active_status_cd = 188.00, p.active_status_prsnl_id = reqinfo->updt_id, p.active_status_dt_tm
       = cnvtdatetime(curdate,curtime3),
      p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id,
      p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
   ELSE
    SET failcnt = (failcnt+ 1)
    SET stat = alterlist(insert_fails->prsnl_list,failcnt)
    SET insert_fails->prsnl_list[failcnt].facility = new_users->prsnl_list[m].facility
    SET insert_fails->prsnl_list[failcnt].person_id = new_users->prsnl_list[m].person_id
    SET insert_fails->prsnl_list[failcnt].malaffi_pos = new_users->prsnl_list[m].malaffi_pos
    SET insert_fails->prsnl_list[failcnt].username = new_users->prsnl_list[m].username
    SET insert_fails->prsnl_list[failcnt].full_name = new_users->prsnl_list[m].full_name
    SET insert_fails->prsnl_list[failcnt].first_name = new_users->prsnl_list[m].first_name
    SET insert_fails->prsnl_list[failcnt].first_name = new_users->prsnl_list[m].middle_name
    SET insert_fails->prsnl_list[failcnt].middle_name = new_users->prsnl_list[m].last_name
    SET insert_fails->prsnl_list[failcnt].licenseid = new_users->prsnl_list[m].licenseid
    SET insert_fails->prsnl_list[failcnt].oracle_id = new_users->prsnl_list[m].oracle_id
    SET insert_fails->prsnl_list[failcnt].reason = "Insert failed"
   ENDIF
   SET alias_id = 0
   SET per_id = 0
 ENDFOR
 SELECT INTO value("ccluserdir:Users_with_alias.csv")
  facility = user_has_alias->prsnl_list[d1.seq].facility, ",", personid = user_has_alias->prsnl_list[
  d1.seq].person_id,
  ",", mal_pos = user_has_alias->prsnl_list[d1.seq].malaffi_pos, ",",
  username = user_has_alias->prsnl_list[d1.seq].username, ",", fullname = user_has_alias->prsnl_list[
  d1.seq].full_name,
  ",", firstname = user_has_alias->prsnl_list[d1.seq].first_name, ",",
  middlename = user_has_alias->prsnl_list[d1.seq].middle_name, ",", lastname = user_has_alias->
  prsnl_list[d1.seq].last_name,
  ",", licenseid = user_has_alias->prsnl_list[d1.seq].licenseid, ",",
  oracleid = user_has_alias->prsnl_list[d1.seq].oracle_id, ",", reason = user_has_alias->prsnl_list[
  d1.seq].reason
  FROM (dummyt d1  WITH seq = value(size(user_has_alias->prsnl_list,5)))
  WITH nocounter
 ;end select
 SELECT INTO value("ccluserdir:Users_not_exists.csv")
  facility = user_not_exist->prsnl_list[d1.seq].facility, ",", personid = user_not_exist->prsnl_list[
  d1.seq].person_id,
  ",", mal_pos = user_not_exist->prsnl_list[d1.seq].malaffi_pos, ",",
  username = user_not_exist->prsnl_list[d1.seq].username, ",", fullname = user_not_exist->prsnl_list[
  d1.seq].full_name,
  ",", firstname = user_not_exist->prsnl_list[d1.seq].first_name, ",",
  middlename = user_not_exist->prsnl_list[d1.seq].middle_name, ",", lastname = user_not_exist->
  prsnl_list[d1.seq].last_name,
  ",", licenseid = user_not_exist->prsnl_list[d1.seq].licenseid, ",",
  oracleid = user_not_exist->prsnl_list[d1.seq].oracle_id, ",", reason = user_not_exist->prsnl_list[
  d1.seq].reason
  FROM (dummyt d1  WITH seq = value(size(user_not_exist->prsnl_list,5)))
  WITH nocounter
 ;end select
 SELECT INTO value("ccluserdir:new_users_for_insert.csv")
  facility = new_users->prsnl_list[d1.seq].facility, ",", personid = new_users->prsnl_list[d1.seq].
  person_id,
  ",", mal_pos = new_users->prsnl_list[d1.seq].malaffi_pos, ",",
  username = new_users->prsnl_list[d1.seq].username, ",", fullname = new_users->prsnl_list[d1.seq].
  full_name,
  ",", firstname = new_users->prsnl_list[d1.seq].first_name, ",",
  middlename = new_users->prsnl_list[d1.seq].middle_name, ",", lastname = new_users->prsnl_list[d1
  .seq].last_name,
  ",", licenseid = new_users->prsnl_list[d1.seq].licenseid, ",",
  oracleid = new_users->prsnl_list[d1.seq].oracle_id
  FROM (dummyt d1  WITH seq = value(size(new_users->prsnl_list,5)))
  WITH nocounter
 ;end select
 SELECT INTO value("ccluserdir:insert_failed_users.csv")
  facility = insert_fails->prsnl_list[d1.seq].facility, ",", personid = insert_fails->prsnl_list[d1
  .seq].person_id,
  ",", mal_pos = insert_fails->prsnl_list[d1.seq].malaffi_pos, ",",
  username = insert_fails->prsnl_list[d1.seq].username, ",", fullname = insert_fails->prsnl_list[d1
  .seq].full_name,
  ",", firstname = insert_fails->prsnl_list[d1.seq].first_name, ",",
  middlename = insert_fails->prsnl_list[d1.seq].middle_name, ",", lastname = insert_fails->
  prsnl_list[d1.seq].last_name,
  ",", licenseid = insert_fails->prsnl_list[d1.seq].licenseid, ",",
  oracleid = insert_fails->prsnl_list[d1.seq].oracle_id, ",", reason = insert_fails->prsnl_list[d1
  .seq].reason
  FROM (dummyt d1  WITH seq = value(size(insert_fails->prsnl_list,5)))
  WITH nocounter
 ;end select
#exit_script
 IF (failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
END GO
