CREATE PROGRAM cp_add_default_charting_doc:dba
 SET new_id = 0
 SELECT INTO "nl:"
  p.username
  FROM prsnl p
  WHERE p.username="CHARTING"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  x = seq(person_only_seq,nextval)
  FROM dual
  DETAIL
   new_id = cnvtint(x)
  WITH nocounter
 ;end select
 SET first = "Doctor"
 SET last = "Charting"
 SET new_username = cnvtupper("CHARTING")
 SET code_set = 309
 SET code_value = 0.0
 SET cdf_meaning = "USER"
 EXECUTE cpm_get_cd_for_cdf
 INSERT  FROM person
  SET person_id = new_id, name_last_key = cnvtupper(last), name_last = last,
   name_first_key = cnvtupper(first), name_first = first, name_full_formatted = concat(last,", ",
    first),
   name_phonetic = soundex(cnvtupper(last)), active_ind = 1, beg_effective_dt_tm = cnvtdatetime(
    sysdate),
   end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"), updt_cnt = 0, updt_task = 0,
   updt_id = 0, updt_dt_tm = cnvtdatetime(sysdate), updt_applctx = 0
  WITH nocounter
 ;end insert
 INSERT  FROM prsnl
  SET username = new_username, position_cd = 0, person_id = new_id,
   name_last_key = cnvtupper(last), name_last = last, name_first_key = cnvtupper(first),
   name_first = first, name_full_formatted = concat(last,", ",first), prsnl_type_cd = code_value,
   active_ind = 1, beg_effective_dt_tm = cnvtdatetime(sysdate), end_effective_dt_tm = cnvtdatetime(
    "31-dec-2100 00:00:00.00"),
   updt_cnt = 0, updt_task = 0, updt_id = 0,
   updt_dt_tm = cnvtdatetime(sysdate), updt_applctx = 0
  WITH nocounter
 ;end insert
 COMMIT
#exit_script
END GO
