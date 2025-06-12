CREATE PROGRAM bed_imp_srvres_hier:dba
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
 SET reply->status_data.status = "F"
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
   IF (((curr_cat_type_cd=0) OR (curr_cat_type != cnvtupper(cnvtalphanum(requestin->list_0[x].
     catalog_type)))) )
    SET curr_cat_type_cd = 0
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
   IF (((curr_act_type_cd=0) OR (curr_act_type != cnvtupper(cnvtalphanum(requestin->list_0[x].
     activity_type)))) )
    SET curr_act_type_cd = 0
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
   IF (((curr_act_subtype_cd=0) OR (curr_act_subtype != cnvtupper(cnvtalphanum(requestin->list_0[x].
     activity_subtype)))) )
    SET curr_act_subtype_cd = 0.0
    SET curr_act_subtype = cnvtupper(cnvtalphanum(requestin->list_0[x].activity_subtype))
    IF (curr_act_subtype > "    ")
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
       SET error_flag = "Y"
       SET error_msg = "unable to write section group row"
       GO TO exit_script
      ELSE
       SET sectiongrp_id = current_id
       SET save_option = curr_option
       SET save_level = curr_level
       SET section_id = 0
       SET subsection_id = 0
      ENDIF
     ELSE
      SET error_flag = "Y"
      SET error_msg = "new option doesn't begin with level 1 row"
      GO TO exit_script
     ENDIF
    ELSE
     IF (curr_level=4)
      IF (subsection_id > 0)
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
        SET error_flag = "Y"
        SET error_msg = "unable to write subsection row"
        GO TO exit_script
       ELSE
        SET save_level = curr_level
       ENDIF
      ELSE
       SET error_msg = "level 4 row doesn't follow level 3 row"
       SET error_flag = "Y"
       GO TO exit_script
      ENDIF
     ELSEIF (curr_level=3)
      IF (section_id > 0)
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
        SET error_flag = "Y"
        SET error_msg = "unable to write subsection row"
        GO TO exit_script
       ELSE
        SET save_level = curr_level
        SET subsection_id = current_id
       ENDIF
      ELSE
       SET error_msg = "level 3 row doesn't follow level 2 row"
       SET error_flag = "Y"
       GO TO exit_script
      ENDIF
     ELSEIF (curr_level=2)
      IF (sectiongrp_id > 0)
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
        SET error_flag = "Y"
        SET error_msg = "unable to write section row"
        GO TO exit_script
       ELSE
        SET save_level = curr_level
        SET section_id = current_id
        SET subsection_id = 0
       ENDIF
      ELSE
       SET error_msg = "level 2 row doesn't follow level 1 row"
       SET error_flag = "Y"
       GO TO exit_script
      ENDIF
     ELSEIF (curr_level=1)
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
       SET error_flag = "Y"
       SET error_msg = "unable to write section group row"
       GO TO exit_script
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
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_IMP_NAME_VALUE","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
