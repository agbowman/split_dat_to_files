CREATE PROGRAM dcp_prsnl_group_updt
 RECORD prsnl_group_info(
   1 prsnl_group_list[*]
     2 prsnl_group_id = f8
     2 prsnl_group_type_cd = f8
     2 prsnl_group_name = c100
     2 group_type_name = c12
     2 display = c40
 )
 SET prsnl_group_cnt = 0
 SET new_code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET code_set = 19189
 SET cdf_meaning = "DCPTEAM"
 EXECUTE cpm_get_cd_for_cdf
 SET dcpteam_class_cd = code_value
 SET code_set = 19189
 SET cdf_meaning = "CARETEAM"
 EXECUTE cpm_get_cd_for_cdf
 SET careteam_class_cd = code_value
 SELECT INTO "nl:"
  pg.prsnl_group_id
  FROM prsnl_group pg,
   code_value cv
  PLAN (pg
   WHERE pg.active_ind=1)
   JOIN (cv
   WHERE cv.code_set=357
    AND pg.prsnl_group_type_cd=cv.code_value
    AND pg.prsnl_group_name != cv.display
    AND cv.cdf_meaning IN ("DCPTEAM", "CARETEAM"))
  HEAD pg.prsnl_group_id
   prsnl_group_cnt = (prsnl_group_cnt+ 1)
   IF (prsnl_group_cnt > size(prsnl_group_info->prsnl_group_list,5))
    stat = alterlist(prsnl_group_info->prsnl_group_list,(prsnl_group_cnt+ 20))
   ENDIF
  DETAIL
   prsnl_group_info->prsnl_group_list[prsnl_group_cnt].prsnl_group_id = pg.prsnl_group_id,
   prsnl_group_info->prsnl_group_list[prsnl_group_cnt].prsnl_group_type_cd = pg.prsnl_group_type_cd,
   prsnl_group_info->prsnl_group_list[prsnl_group_cnt].prsnl_group_name = pg.prsnl_group_name,
   prsnl_group_info->prsnl_group_list[prsnl_group_cnt].group_type_name = cv.cdf_meaning,
   prsnl_group_info->prsnl_group_list[prsnl_group_cnt].display = cv.display
  WITH nocounter
 ;end select
 IF (prsnl_group_cnt=0)
  CALL echo("No groups need to be added! Check to see if you need to update missing class codes")
  SELECT INTO "nl:"
   pg.prsnl_group_id
   FROM prsnl_group pg,
    code_value cv
   PLAN (pg
    WHERE pg.active_ind=1
     AND pg.prsnl_group_class_cd=0)
    JOIN (cv
    WHERE cv.code_set=357
     AND pg.prsnl_group_type_cd=cv.code_value
     AND cv.cdf_meaning IN ("DCPTEAM", "CARETEAM"))
   HEAD pg.prsnl_group_id
    prsnl_group_cnt = (prsnl_group_cnt+ 1),
    CALL echo(build("count = ",prsnl_group_cnt))
    IF (prsnl_group_cnt > size(prsnl_group_info->prsnl_group_list,5))
     stat = alterlist(prsnl_group_info->prsnl_group_list,(prsnl_group_cnt+ 20))
    ENDIF
   DETAIL
    prsnl_group_info->prsnl_group_list[prsnl_group_cnt].prsnl_group_id = pg.prsnl_group_id,
    prsnl_group_info->prsnl_group_list[prsnl_group_cnt].prsnl_group_type_cd = pg.prsnl_group_type_cd,
    prsnl_group_info->prsnl_group_list[prsnl_group_cnt].prsnl_group_name = pg.prsnl_group_name,
    prsnl_group_info->prsnl_group_list[prsnl_group_cnt].group_type_name = cv.cdf_meaning,
    prsnl_group_info->prsnl_group_list[prsnl_group_cnt].display = cv.display
   WITH nocounter
  ;end select
  IF (prsnl_group_cnt=0)
   GO TO exit_script
  ELSE
   FOR (x = 1 TO prsnl_group_cnt)
     UPDATE  FROM prsnl_group pg
      SET pg.prsnl_group_class_cd =
       IF ((prsnl_group_info->prsnl_group_list[x].group_type_name="DCPTEAM")) dcpteam_class_cd
       ELSEIF ((prsnl_group_info->prsnl_group_list[x].group_type_name="CARETEAM")) careteam_class_cd
       ENDIF
      WHERE (pg.prsnl_group_id=prsnl_group_info->prsnl_group_list[x].prsnl_group_id)
      WITH nocounter
     ;end update
   ENDFOR
  ENDIF
 ELSE
  FOR (x = 1 TO prsnl_group_cnt)
    SELECT INTO "nl:"
     xyz = seq(reference_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_code_value = cnvtreal(xyz)
     WITH format, nocounter
    ;end select
    INSERT  FROM code_value cv
     SET cv.code_value = new_code_value, cv.code_set = 357, cv.cdf_meaning = prsnl_group_info->
      prsnl_group_list[x].group_type_name,
      cv.display = prsnl_group_info->prsnl_group_list[x].prsnl_group_name, cv.display_key = trim(
       cnvtupper(cnvtalphanum(prsnl_group_info->prsnl_group_list[x].prsnl_group_name))), cv
      .description = prsnl_group_info->prsnl_group_list[x].prsnl_group_name,
      cv.definition = prsnl_group_info->prsnl_group_list[x].prsnl_group_name, cv.collation_seq = 0,
      cv.active_ind = 1,
      cv.active_type_cd = reqdata->active_status_cd, cv.data_status_cd = 9, cv.updt_id = 0,
      cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = 0, cv.updt_task = reqinfo->updt_task,
      cv.active_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_dt_tm = cnvtdatetime(curdate,curtime3
       ), cv.begin_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      cv.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00")
     WITH nocounter
    ;end insert
    UPDATE  FROM prsnl_group pg
     SET pg.prsnl_group_type_cd = new_code_value, pg.prsnl_group_class_cd =
      IF ((prsnl_group_info->prsnl_group_list[x].group_type_name="DCPTEAM")) dcpteam_class_cd
      ELSEIF ((prsnl_group_info->prsnl_group_list[x].group_type_name="CARETEAM")) careteam_class_cd
      ENDIF
     WHERE (pg.prsnl_group_id=prsnl_group_info->prsnl_group_list[x].prsnl_group_id)
     WITH nocounter
    ;end update
  ENDFOR
  COMMIT
  CALL echo(build(prsnl_group_cnt," groups have been updated!"))
 ENDIF
#exit_script
END GO
