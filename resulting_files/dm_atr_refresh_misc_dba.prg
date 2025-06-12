CREATE PROGRAM dm_atr_refresh_misc:dba
 DECLARE username = c50
 DECLARE u_name = c50
 SET count1 = 0
 SET def_appgrp_cd = 0
 SET position_cd = 0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=500
   AND c.display_key="DBA"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm < cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  DETAIL
   def_appgrp_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=88
   AND c.display_key="DBA"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm < cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  DETAIL
   position_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  a.position_cd
  FROM application_group a
  WHERE a.position_cd=position_cd
   AND a.app_group_cd=def_appgrp_cd
 ;end select
 IF (curqual=0)
  INSERT  FROM application_group a
   SET a.application_group_id = cnvtint(seq(cpm_seq,nextval)), a.position_cd = position_cd, a
    .app_group_cd = def_appgrp_cd,
    a.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), a.end_effective_dt_tm = cnvtdatetime(
     "01-JAN-2099"), a.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    a.updt_id = 0, a.updt_task = 0, a.updt_applctx = 0,
    a.updt_cnt = 0
   WITH nocounter
  ;end insert
 ENDIF
 FREE RECORD tasks
 RECORD tasks(
   1 count = i4
   1 qual[*]
     2 number = i4
     2 exist = i2
 )
 SET stat = alterlist(tasks->qual,0)
 SET tasks->count = 0
 SELECT INTO "nl:"
  t.task_number
  FROM application_task t
  DETAIL
   tasks->count = (tasks->count+ 1), stat = alterlist(tasks->qual,tasks->count), tasks->qual[tasks->
   count].number = t.task_number,
   tasks->qual[tasks->count].exist = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ta.task_number
  FROM task_access ta,
   (dummyt d  WITH seq = value(tasks->count))
  PLAN (d)
   JOIN (ta
   WHERE (ta.task_number=tasks->qual[d.seq].number)
    AND ta.app_group_cd=def_appgrp_cd)
  DETAIL
   tasks->qual[d.seq].exist = 1
  WITH nocounter
 ;end select
 INSERT  FROM task_access ta,
   (dummyt d  WITH seq = value(tasks->count))
  SET ta.seq = 1, ta.task_number = tasks->qual[d.seq].number, ta.app_group_cd = def_appgrp_cd,
   ta.updt_dt_tm = cnvtdatetime(curdate,curtime3), ta.updt_id = 0, ta.updt_task = 0,
   ta.updt_applctx = 0, ta.updt_cnt = 0
  PLAN (d
   WHERE (tasks->qual[d.seq].exist=0))
   JOIN (ta)
  WITH nocounter
 ;end insert
 SET username = "SYSTEM"
 EXECUTE FROM add_acts TO add_acts_exit
 SET username = "CERNER"
 EXECUTE FROM add_acts TO add_acts_exit
 SET username = "SYSTEMOE"
 EXECUTE FROM add_acts TO add_acts_exit
 COMMIT
 GO TO exit_script
#add_acts
 CALL echo(build("creating default account:",username))
 SET p_id1 = 0.0
 SET p_id2 = 0.0
 SET u_name = fillstring(50," ")
 SET prsnl_type_cd = 0.0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SELECT INTO "nl:"
  p.person_id
  FROM person p
  WHERE p.name_last_key=username
   AND p.active_ind=1
  ORDER BY p.person_id DESC
  HEAD REPORT
   x = 0
  DETAIL
   x = (x+ 1)
   IF (x=1)
    p_id1 = p.person_id
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  UPDATE  FROM prsnl p2
   SET p2.active_ind = 0, p2.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WHERE p2.name_last_key=username
   WITH nocounter
  ;end update
  COMMIT
  SELECT INTO "nl:"
   x = seq(person_only_seq,nextval)"#################;rp0"
   FROM dual
   DETAIL
    p_id1 = cnvtint(x)
   WITH format, nocounter
  ;end select
  INSERT  FROM person p
   SET p.person_id = p_id1, p.name_last_key = username, p.name_first_key = username,
    p.name_last = username, p.name_first = username, p.name_full_formatted = username,
    p.name_phonetic = soundex(cnvtupper(username)), p.beg_effective_dt_tm = cnvtdatetime(curdate,
     curtime3), p.end_effective_dt_tm = cnvtdatetime("01-dec-2100"),
    p.active_ind = 1, p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p.create_prsnl_id = 1,
    p.create_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p
    .updt_cnt = 0,
    p.updt_id = 0, p.updt_applctx = 0, p.updt_task = 0
   WITH nocounter
  ;end insert
  COMMIT
  SET code_set = 309
  SET cdf_meaning = "USER"
  EXECUTE cpm_get_cd_for_cdf
  SET prsnl_type_cd = code_value
  INSERT  FROM prsnl p2
   SET p2.person_id = p_id1, p2.prsnl_type_cd = prsnl_type_cd, p2.name_last_key = username,
    p2.name_first_key = username, p2.name_last = username, p2.name_first = username,
    p2.name_full_formatted = username, p2.position_cd = position_cd, p2.username = trim(cnvtupper(
      username)),
    p2.active_ind = 1, p2.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p2.create_dt_tm =
    cnvtdatetime(curdate,curtime3),
    p2.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p2.end_effective_dt_tm = cnvtdatetime(
     "01-dec-2100"), p2.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    p2.updt_cnt = 0, p2.updt_id = 0, p2.updt_applctx = 0,
    p2.updt_task = 0
   WITH nocounter
  ;end insert
  COMMIT
 ELSE
  UPDATE  FROM person p
   SET p.active_ind = 0, p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WHERE p.name_last_key=username
    AND p.active_ind=1
    AND p.person_id != p_id1
   WITH nocounter
  ;end update
  COMMIT
  SELECT INTO "nl:"
   FROM prsnl p2
   WHERE p2.person_id=p_id1
    AND p2.active_ind=1
   DETAIL
    u_name = p2.username
   WITH nocounter
  ;end select
  IF (curqual=0)
   UPDATE  FROM prsnl p2
    SET p2.active_ind = 0, p2.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE p2.name_last_key=username
    WITH nocounter
   ;end update
   COMMIT
   SET code_set = 309
   SET cdf_meaning = "USER"
   EXECUTE cpm_get_cd_for_cdf
   SET prsnl_type_cd = code_value
   INSERT  FROM prsnl p2
    SET p2.person_id = p_id1, p2.prsnl_type_cd = prsnl_type_cd, p2.name_last_key = username,
     p2.name_first_key = username, p2.name_last = username, p2.name_first = username,
     p2.name_full_formatted = username, p2.position_cd = position_cd, p2.username = trim(cnvtupper(
       username)),
     p2.active_ind = 1, p2.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p2.create_dt_tm =
     cnvtdatetime(curdate,curtime3),
     p2.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p2.end_effective_dt_tm = cnvtdatetime(
      "01-dec-2100"), p2.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     p2.updt_cnt = 0, p2.updt_id = 0, p2.updt_applctx = 0,
     p2.updt_task = 0
    WITH nocounter
   ;end insert
   COMMIT
  ELSE
   UPDATE  FROM prsnl p2
    SET p2.active_ind = 0, p2.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE p2.name_last_key=username
     AND p2.active_ind=1
     AND p2.person_id != p_id1
    WITH nocounter
   ;end update
   COMMIT
  ENDIF
 ENDIF
#add_acts_exit
#exit_script
END GO
