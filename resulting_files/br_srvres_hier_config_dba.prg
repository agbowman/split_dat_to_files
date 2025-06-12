CREATE PROGRAM br_srvres_hier_config:dba
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
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting <br_srvres_hier_config.prg> script"
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE error_msg = vc
 DECLARE curr_option = i2
 DECLARE save_option = i2
 DECLARE curr_level = i2
 DECLARE save_level = i2
 DECLARE curr_disp = vc
 DECLARE curr_desc = vc
 DECLARE curr_mean = vc
 DECLARE curr_cat_type = vc
 DECLARE curr_act_type = vc
 DECLARE curr_act_subtype = vc
 DECLARE curr_proposed_ind = i2
 DECLARE curr_auto_ind = i2
 SET error_flag = "N"
 SET sect_grp_cnt = 0
 SET no_level1_cnt = 0
 SET no_subsect_cnt = 0
 SET no_follow3_cnt = 0
 SET write_subsect_cnt = 0
 SET no_follow2_cnt = 0
 SET write_sect_cnt = 0
 SET no_follow1_cnt = 0
 SET write_sectgrp_cnt = 0
 SET catalog_type_ok = 1
 SET activity_type_ok = 1
 SET subactivity_type_ok = 1
 SET nbr_value = size(requestin->list_0,5)
 SET sectiongrp_id = 0
 SET section_id = 0
 SET subsection_id = 0
 SET current_id = 0
 SET curr_cat_type_cd = 0.0
 SET curr_act_type_cd = 0.0
 SET curr_act_subtype_cd = 0.0
 FOR (x = 1 TO nbr_value)
   SET curr_option = 0
   SET curr_level = 0
   SET curr_displ = ""
   SET curr_desc = ""
   SET curr_mean = ""
   SET curr_cat_type = ""
   SET curr_act_type = ""
   SET curr_act_subtype = ""
   SET curr_proposed_ind = 0
   SET curr_auto_ind = 0
   SET curr_option = cnvtint(requestin->list_0[x].option)
   SET curr_level = cnvtint(requestin->list_0[x].level)
   SET curr_disp = trim(requestin->list_0[x].display)
   SET curr_mean = trim(requestin->list_0[x].meaning)
   SET curr_desc = trim(requestin->list_0[x].description)
   SET catalog_type_ok = 1
   SET activity_type_ok = 1
   SET subactivity_type_ok = 1
   IF (((curr_cat_type_cd=0) OR (curr_cat_type != cnvtupper(cnvtalphanum(requestin->list_0[x].
     catalog_type)))) )
    SET catalog_type_ok = 1
    SET curr_cat_type_cd = 0
    SET curr_cat_type = trim(requestin->list_0[x].catalog_type)
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE cv.code_set=6000
      AND cv.cdf_meaning=curr_cat_type
     DETAIL
      curr_cat_type_cd = cv.code_value
     WITH nocounter
    ;end select
    IF (curr_cat_type_cd=0)
     SET curr_cat_type = cnvtupper(cnvtalphanum(requestin->list_0[x].catalog_type))
     SELECT INTO "NL:"
      FROM code_value cv
      WHERE cv.code_set=6000
       AND cv.display_key=curr_cat_type
       AND cv.active_ind=1
      ORDER BY cv.code_value
      DETAIL
       curr_cat_type_cd = cv.code_value
      WITH nocounter
     ;end select
    ENDIF
    IF ((requestin->list_0[x].catalog_type > " "))
     IF (curr_cat_type_cd=0)
      SET catalog_type_ok = 0
      CALL echo(build("catalog_type:",requestin->list_0[x].catalog_type))
     ENDIF
    ENDIF
   ENDIF
   IF (((curr_act_type_cd=0) OR (curr_act_type != cnvtupper(cnvtalphanum(requestin->list_0[x].
     activity_type)))) )
    SET activity_type_ok = 1
    SET curr_act_type_cd = 0
    SET curr_act_type = trim(requestin->list_0[x].activity_type)
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE cv.code_set=106
      AND cv.cdf_meaning=curr_act_type
     ORDER BY cv.code_value
     DETAIL
      curr_act_type_cd = cv.code_value
     WITH nocounter
    ;end select
    IF (curr_act_type_cd=0)
     SET curr_act_type = cnvtupper(cnvtalphanum(requestin->list_0[x].activity_type))
     SELECT INTO "NL:"
      FROM code_value cv
      WHERE cv.code_set=106
       AND cv.display_key=curr_act_type
       AND cv.active_ind=1
      ORDER BY cv.code_value
      DETAIL
       curr_act_type_cd = cv.code_value
      WITH nocounter
     ;end select
    ENDIF
    IF ((requestin->list_0[x].activity_type > " "))
     IF (curr_act_type_cd=0)
      SET activity_type_ok = 0
      CALL echo(build("activity_type:",requestin->list_0[x].activity_type))
     ENDIF
    ENDIF
   ENDIF
   IF (((curr_act_subtype_cd=0) OR (curr_act_subtype != cnvtupper(cnvtalphanum(requestin->list_0[x].
     activity_subtype)))) )
    SET curr_act_subtype_cd = 0.0
    SET subactivity_type_ok = 1
    SET curr_act_subtype = trim(requestin->list_0[x].activity_subtype)
    IF (curr_act_subtype > "    ")
     SELECT INTO "NL:"
      FROM code_value cv
      WHERE cv.code_set=5801
       AND cv.cdf_meaning=curr_act_subtype
      ORDER BY cv.code_value
      DETAIL
       curr_act_subtype_cd = cv.code_value
      WITH nocounter
     ;end select
     IF (curr_act_subtype_cd=0)
      SET curr_act_subtype = cnvtupper(cnvtalphanum(requestin->list_0[x].activity_subtype))
      SELECT INTO "NL:"
       FROM code_value cv
       WHERE cv.code_set=5801
        AND cv.display_key=curr_act_subtype
        AND cv.active_ind=1
       ORDER BY cv.code_value
       DETAIL
        curr_act_subtype_cd = cv.code_value
       WITH nocounter
      ;end select
     ENDIF
     IF (curr_act_subtype_cd=0)
      SET subactivity_type_ok = 0
      CALL echo(build("subactivity_type:",requestin->list_0[x].activity_subtype))
     ENDIF
    ENDIF
   ENDIF
   IF (((trim(requestin->list_0[x].proposed_ind)="Y") OR (trim(requestin->list_0[x].proposed_ind)="y"
   )) )
    SET curr_proposed_ind = 1
   ENDIF
   IF (((trim(requestin->list_0[x].auto_manual_ind)="Automated") OR (((trim(requestin->list_0[x].
    auto_manual_ind)="AUTOMATED") OR (trim(requestin->list_0[x].auto_manual_ind)="automated")) )) )
    SET curr_auto_ind = 1
   ENDIF
   IF (curr_option > 0)
    IF (curr_option != save_option)
     IF (curr_level=1)
      DELETE  FROM br_proposed_srvres bps
       PLAN (bps
        WHERE bps.srvres_option_nbr=curr_option)
       WITH nocounter
      ;end delete
      SET current_id = (current_id+ 1)
      INSERT  FROM br_proposed_srvres bps
       SET bps.br_proposed_srvres_id = current_id, bps.srvres_option_nbr = curr_option, bps
        .srvres_level = 1,
        bps.parent_id = 0, bps.display = curr_disp, bps.description = curr_desc,
        bps.meaning = curr_mean, bps.catalog_type_cd = curr_cat_type_cd, bps.proposed_ind =
        curr_proposed_ind,
        bps.automated_ind = curr_auto_ind, bps.updt_id = reqinfo->updt_id, bps.updt_dt_tm =
        cnvtdatetime(curdate,curtime),
        bps.updt_task = reqinfo->updt_task, bps.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "T"
       SET sect_grp_cnt = (sect_grp_cnt+ 1)
      ELSE
       SET sectiongrp_id = current_id
       SET save_option = curr_option
       SET save_level = curr_level
       SET section_id = 0
       SET subsection_id = 0
      ENDIF
     ELSE
      SET error_flag = "T"
      SET no_level1_cnt = (no_level1_cnt+ 1)
     ENDIF
    ELSE
     IF (curr_level=4)
      IF (subsection_id > 0
       AND catalog_type_ok=1
       AND activity_type_ok=1
       AND subactivity_type_ok=1)
       SET current_id = (current_id+ 1)
       INSERT  FROM br_proposed_srvres bps
        SET bps.br_proposed_srvres_id = current_id, bps.srvres_option_nbr = curr_option, bps
         .srvres_level = 4,
         bps.parent_id = subsection_id, bps.display = curr_disp, bps.description = curr_desc,
         bps.meaning = curr_mean, bps.catalog_type_cd = curr_cat_type_cd, bps.activity_type_cd =
         curr_act_type_cd,
         bps.activity_subtype_cd = curr_act_subtype_cd, bps.proposed_ind = curr_proposed_ind, bps
         .automated_ind = curr_auto_ind,
         bps.updt_id = reqinfo->updt_id, bps.updt_dt_tm = cnvtdatetime(curdate,curtime), bps
         .updt_task = reqinfo->updt_task,
         bps.updt_applctx = reqinfo->updt_applctx
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET error_flag = "T"
        SET no_subsect_cnt = (no_subsect_cnt+ 1)
       ELSE
        SET save_level = curr_level
       ENDIF
      ELSE
       SET error_flag = "T"
       SET no_follow3_cnt = (no_follow3_cnt+ 1)
      ENDIF
     ELSEIF (curr_level=3)
      IF (section_id > 0
       AND catalog_type_ok=1
       AND activity_type_ok=1
       AND subactivity_type_ok=1)
       SET current_id = (current_id+ 1)
       INSERT  FROM br_proposed_srvres bps
        SET bps.br_proposed_srvres_id = current_id, bps.srvres_option_nbr = curr_option, bps
         .srvres_level = 3,
         bps.parent_id = section_id, bps.display = curr_disp, bps.description = curr_desc,
         bps.meaning = curr_mean, bps.catalog_type_cd = curr_cat_type_cd, bps.activity_type_cd =
         curr_act_type_cd,
         bps.activity_subtype_cd = curr_act_subtype_cd, bps.proposed_ind = curr_proposed_ind, bps
         .automated_ind = curr_auto_ind,
         bps.updt_id = reqinfo->updt_id, bps.updt_dt_tm = cnvtdatetime(curdate,curtime), bps
         .updt_task = reqinfo->updt_task,
         bps.updt_applctx = reqinfo->updt_applctx
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET error_flag = "T"
        SET write_subsect_cnt = (write_subsect_cnt+ 1)
       ELSE
        SET save_level = curr_level
        SET subsection_id = current_id
       ENDIF
      ELSE
       SET error_flag = "T"
       SET no_follow2_cnt = (no_follow2_cnt+ 1)
      ENDIF
     ELSEIF (curr_level=2)
      IF (sectiongrp_id > 0
       AND catalog_type_ok=1
       AND activity_type_ok=1
       AND subactivity_type_ok=1)
       SET current_id = (current_id+ 1)
       INSERT  FROM br_proposed_srvres bps
        SET bps.br_proposed_srvres_id = current_id, bps.srvres_option_nbr = curr_option, bps
         .srvres_level = 2,
         bps.parent_id = sectiongrp_id, bps.display = curr_disp, bps.meaning = curr_mean,
         bps.description = curr_desc, bps.catalog_type_cd = curr_cat_type_cd, bps.activity_type_cd =
         curr_act_type_cd,
         bps.activity_subtype_cd = curr_act_subtype_cd, bps.proposed_ind = curr_proposed_ind, bps
         .automated_ind = curr_auto_ind,
         bps.updt_id = reqinfo->updt_id, bps.updt_dt_tm = cnvtdatetime(curdate,curtime), bps
         .updt_task = reqinfo->updt_task,
         bps.updt_applctx = reqinfo->updt_applctx
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET error_flag = "T"
        SET write_sect_cnt = (write_sect_cnt+ 1)
       ELSE
        SET save_level = curr_level
        SET section_id = current_id
        SET subsection_id = 0
       ENDIF
      ELSE
       SET error_flag = "T"
       SET no_follow1_cnt = (no_follow1_cnt+ 1)
      ENDIF
     ELSEIF (curr_level=1
      AND catalog_type_ok=1)
      SET current_id = (current_id+ 1)
      INSERT  FROM br_proposed_srvres bps
       SET bps.br_proposed_srvres_id = current_id, bps.srvres_option_nbr = curr_option, bps
        .srvres_level = 1,
        bps.parent_id = 0, bps.display = curr_disp, bps.description = curr_desc,
        bps.meaning = curr_mean, bps.catalog_type_cd = curr_cat_type_cd, bps.proposed_ind =
        curr_proposed_ind,
        bps.automated_ind = curr_auto_ind, bps.updt_id = reqinfo->updt_id, bps.updt_dt_tm =
        cnvtdatetime(curdate,curtime),
        bps.updt_task = reqinfo->updt_task, bps.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "T"
       SET write_sectgrp_cnt = (write_sectgrp_cnt+ 1)
      ELSE
       SET sectiongrp_id = current_id
       SET save_option = curr_option
       SET save_level = curr_level
       SET section_id = 0
       SET subsection_id = 0
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 GO TO exit_script
#exit_script
 IF (error_flag="T")
  SET error_msg = concat("No write sect grp: ",cnvtstring(sect_grp_cnt)," No level 1 row: ",
   cnvtstring(no_level1_cnt)," No write subsect: ",
   cnvtstring(no_subsect_cnt)," No follow row 3: ",cnvtstring(no_follow3_cnt)," No write subsect: ",
   cnvtstring(write_subsect_cnt),
   " No follow row 2: ",cnvtstring(no_follow2_cnt)," No write section: ",cnvtstring(write_sect_cnt),
   " No follow row 1: ",
   cnvtstring(no_follow1_cnt)," No write sectgrp: ",cnvtstring(write_sectgrp_cnt))
  CALL echo(error_msg)
 ENDIF
 IF (((error_flag="N") OR (error_flag="T")) )
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Succeeded: <br_srvres_hier_config.prg> script"
  COMMIT
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = "Readme Failed: <br_srvres_hier_config.prg> script"
  ROLLBACK
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
