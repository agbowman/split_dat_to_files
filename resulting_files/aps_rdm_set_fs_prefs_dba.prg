CREATE PROGRAM aps_rdm_set_fs_prefs:dba
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
 SET readme_data->message = "Readme failed: starting script aps_rdm_set_fs_prefs..."
 DECLARE serrormessage = vc WITH protect, noconstant("")
 DECLARE snormal_high_disp = vc WITH protect, noconstant("")
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=1902
   AND cv.cdf_meaning="NORMAL_HIGH"
   AND cv.active_ind=1
  DETAIL
   snormal_high_disp = cv.display
  WITH nocounter
 ;end select
 IF (error(serrormessage,0) > 0)
  SET readme_data->message = concat("Error selecting NORMAL_HIGH from code_value table: ",
   serrormessage)
  GO TO exit_program
 ENDIF
 DECLARE snormal_low_disp = vc WITH protect, noconstant("")
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=1902
   AND cv.cdf_meaning="NORMAL_LOW"
   AND cv.active_ind=1
  DETAIL
   snormal_low_disp = cv.display
  WITH nocounter
 ;end select
 IF (error(serrormessage,0) > 0)
  SET readme_data->message = concat("Error selecting NORMAL_LOW from code_value table: ",
   serrormessage)
  GO TO exit_program
 ENDIF
 DECLARE scritical_disp = vc WITH protect, noconstant("")
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=1902
   AND cv.cdf_meaning="CRITICAL"
   AND cv.active_ind=1
  DETAIL
   scritical_disp = cv.display
  WITH nocounter
 ;end select
 IF (error(serrormessage,0) > 0)
  SET readme_data->message = concat("Error selecting CRITICAL from code_value table: ",serrormessage)
  GO TO exit_program
 ENDIF
 DECLARE salp_abnormal_disp = vc WITH protect, noconstant("")
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=1902
   AND cv.cdf_meaning="ALP_ABNORMAL"
   AND cv.active_ind=1
  DETAIL
   salp_abnormal_disp = cv.display
  WITH nocounter
 ;end select
 IF (error(serrormessage,0) > 0)
  SET readme_data->message = concat("Error selecting ALP_ABNORMAL from code_value table: ",
   serrormessage)
  GO TO exit_program
 ENDIF
 DECLARE insertdefaultprefs(application_nbr=i4) = i2
 FREE RECORD app_num
 RECORD app_num(
   1 qual[5]
     2 application_num = i4
 )
 SET app_num->qual[1].application_num = 200012
 SET app_num->qual[2].application_num = 200020
 SET app_num->qual[3].application_num = 200022
 SET app_num->qual[4].application_num = 200035
 SET app_num->qual[5].application_num = 200062
 DECLARE loopval = i4 WITH protect, noconstant(0)
 FOR (loopval = 1 TO 5)
   CALL echo(build("Readme for Application Number: ",app_num->qual[loopval].application_num))
   SET retval = insertdefaultprefs(app_num->qual[loopval].application_num)
   IF (retval=0)
    ROLLBACK
    GO TO exit_program
   ENDIF
 ENDFOR
 SET readme_data->status = "S"
 SET readme_data->message = "Readme completed all work successfully"
 COMMIT
#exit_program
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
 SUBROUTINE insertdefaultprefs(application_nbr)
   SET readme_data->status = "F"
   SET readme_data->message = "Readme failed: starting InsertDefaultPrefs with application_nbr..."
   SET serrormessage = ""
   DECLARE update_pref_cnt = i4 WITH protect, noconstant(26)
   DECLARE new_name_value_prefs_id = f8 WITH protect, noconstant(0.0)
   DECLARE app_prefs_id = f8 WITH protect, noconstant(0.0)
   DECLARE dp_parent_entity_id = f8 WITH protect, noconstant(0.0)
   DECLARE parent_entity_name = vc WITH protect, noconstant("")
   DECLARE vp_id = f8 WITH protect, noconstant(0.0)
   DECLARE orderview_frame_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM view_prefs vp
    WHERE vp.application_number=application_nbr
     AND vp.position_cd=0.0
     AND vp.prsnl_id=0.0
     AND vp.frame_type="ORDERVIEW"
     AND vp.view_name="FLOWSHEET"
     AND vp.active_ind=1
    DETAIL
     orderview_frame_id = vp.view_prefs_id
    WITH nocounter
   ;end select
   IF (error(serrormessage,0) > 0)
    SET readme_data->message = concat("Error selecting from view_prefs table: ",serrormessage)
    RETURN(0)
   ENDIF
   IF (orderview_frame_id=0.0)
    SELECT INTO "nl:"
     j = seq(carenet_seq,nextval)
     FROM dual
     DETAIL
      orderview_frame_id = cnvtreal(j)
     WITH format, counter
    ;end select
    IF (error(serrormessage,0) > 0)
     SET readme_data->message = concat("Error selecting from dual table: ",serrormessage)
     RETURN(0)
    ENDIF
    INSERT  FROM view_prefs vp
     SET vp.view_prefs_id = orderview_frame_id, vp.application_number = application_nbr, vp
      .position_cd = 0.0,
      vp.prsnl_id = 0.0, vp.frame_type = "ORDERVIEW", vp.view_name = "FLOWSHEET",
      vp.view_seq = 1, vp.active_ind = 1, vp.updt_cnt = 0,
      vp.updt_id = reqinfo->updt_id, vp.updt_dt_tm = cnvtdatetime(curdate,curtime3), vp.updt_task =
      reqinfo->updt_task,
      vp.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (error(serrormessage,0) > 0)
     SET readme_data->message = concat("Error inserting into view_prefs table: ",serrormessage)
     RETURN(0)
    ENDIF
    FREE RECORD insert_view_prefs
    RECORD insert_view_prefs(
      1 qual[*]
        2 parent_entity_name = vc
        2 parent_entity_id = f8
        2 pvc_name = vc
        2 pvc_value = vc
    )
    SET stat = alterlist(insert_view_prefs->qual,4)
    SET insert_view_prefs->qual[1].parent_entity_name = "VIEW_PREFS"
    SET insert_view_prefs->qual[1].parent_entity_id = orderview_frame_id
    SET insert_view_prefs->qual[1].pvc_name = "DLL_NAME"
    SET insert_view_prefs->qual[1].pvc_value = ""
    SET insert_view_prefs->qual[2].parent_entity_name = "VIEW_PREFS"
    SET insert_view_prefs->qual[2].parent_entity_id = orderview_frame_id
    SET insert_view_prefs->qual[2].pvc_name = "VIEW_CAPTION"
    SET insert_view_prefs->qual[2].pvc_value = ""
    SET insert_view_prefs->qual[3].parent_entity_name = "VIEW_PREFS"
    SET insert_view_prefs->qual[3].parent_entity_id = orderview_frame_id
    SET insert_view_prefs->qual[3].pvc_name = "VIEW_IND"
    SET insert_view_prefs->qual[3].pvc_value = "0"
    SET insert_view_prefs->qual[4].parent_entity_name = "VIEW_PREFS"
    SET insert_view_prefs->qual[4].parent_entity_id = orderview_frame_id
    SET insert_view_prefs->qual[4].pvc_name = "DISPLAY_SEQ"
    SET insert_view_prefs->qual[4].pvc_value = "1"
    FOR (i = 1 TO size(insert_view_prefs->qual,5))
      SET new_name_value_prefs_id = 0.0
      SELECT INTO "nl:"
       j = seq(carenet_seq,nextval)
       FROM dual
       DETAIL
        new_name_value_prefs_id = cnvtreal(j)
       WITH format, counter
      ;end select
      IF (error(serrormessage,0) > 0)
       SET readme_data->message = concat("Error selecting from dual table: ",serrormessage)
       RETURN(0)
      ENDIF
      INSERT  FROM name_value_prefs nvp
       SET nvp.name_value_prefs_id = new_name_value_prefs_id, nvp.parent_entity_name =
        insert_view_prefs->qual[i].parent_entity_name, nvp.parent_entity_id = insert_view_prefs->
        qual[i].parent_entity_id,
        nvp.pvc_name = insert_view_prefs->qual[i].pvc_name, nvp.pvc_value = insert_view_prefs->qual[i
        ].pvc_value, nvp.active_ind = 1,
        nvp.merge_name = null, nvp.merge_id = 0.0, nvp.sequence = null,
        nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp
        .updt_task = reqinfo->updt_task,
        nvp.updt_cnt = 0, nvp.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      IF (error(serrormessage,0) > 0)
       SET readme_data->message = concat("Error inserting into name_value_prefs table: ",
        serrormessage)
       RETURN(0)
      ENDIF
    ENDFOR
    SET vp_id = 0.0
    SELECT INTO "nl:"
     FROM view_comp_prefs vp
     WHERE vp.application_number=application_nbr
      AND vp.position_cd=0.0
      AND vp.prsnl_id=0.0
      AND vp.view_name="FLOWSHEET"
      AND vp.view_seq=1
      AND vp.comp_name="FLOWSHEET"
      AND vp.comp_seq=1
      AND vp.active_ind=1
     DETAIL
      vp_id = vp.view_comp_prefs_id
     WITH nocounter
    ;end select
    IF (error(serrormessage,0) > 0)
     SET readme_data->message = concat("Error selecting from view_comp_prefs table: ",serrormessage)
     RETURN(0)
    ENDIF
    IF (vp_id=0.0)
     SELECT INTO "nl:"
      j = seq(carenet_seq,nextval)
      FROM dual
      DETAIL
       vp_id = cnvtreal(j)
      WITH format, counter
     ;end select
     IF (error(serrormessage,0) > 0)
      SET readme_data->message = concat("Error selecting from dual table: ",serrormessage)
      RETURN(0)
     ENDIF
     INSERT  FROM view_comp_prefs vp
      SET vp.view_comp_prefs_id = vp_id, vp.application_number = application_nbr, vp.position_cd =
       0.0,
       vp.prsnl_id = 0.0, vp.view_name = "FLOWSHEET", vp.view_seq = 1,
       vp.comp_name = "FLOWSHEET", vp.comp_seq = 1, vp.active_ind = 1,
       vp.updt_dt_tm = cnvtdatetime(curdate,curtime3), vp.updt_id = reqinfo->updt_id, vp.updt_task =
       reqinfo->updt_task,
       vp.updt_applctx = reqinfo->updt_applctx, vp.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (error(serrormessage,0) > 0)
      SET readme_data->message = concat("Error inserting into view_comp_prefs table: ",serrormessage)
      RETURN(0)
     ENDIF
     FREE RECORD insert_view_comp_prefs
     RECORD insert_view_comp_prefs(
       1 qual[*]
         2 parent_entity_name = vc
         2 parent_entity_id = f8
         2 pvc_name = vc
         2 pvc_value = vc
     )
     SET stat = alterlist(insert_view_comp_prefs->qual,3)
     SET insert_view_comp_prefs->qual[1].parent_entity_name = "VIEW_COMP_PREFS"
     SET insert_view_comp_prefs->qual[1].parent_entity_id = vp_id
     SET insert_view_comp_prefs->qual[1].pvc_name = "PROGID"
     SET insert_view_comp_prefs->qual[1].pvc_value = "FLOWSHEET.FLOWSHEET"
     SET insert_view_comp_prefs->qual[2].parent_entity_name = "VIEW_COMP_PREFS"
     SET insert_view_comp_prefs->qual[2].parent_entity_id = vp_id
     SET insert_view_comp_prefs->qual[2].pvc_name = "COMP_DLLNAME"
     SET insert_view_comp_prefs->qual[2].pvc_value = "PVFLOWSHEET"
     SET insert_view_comp_prefs->qual[3].parent_entity_name = "VIEW_COMP_PREFS"
     SET insert_view_comp_prefs->qual[3].parent_entity_id = vp_id
     SET insert_view_comp_prefs->qual[3].pvc_name = "COMP_POSITION"
     SET insert_view_comp_prefs->qual[3].pvc_value = "0,0,3,4"
     FOR (i = 1 TO size(insert_view_comp_prefs->qual,5))
       SET new_name_value_prefs_id = 0.0
       SELECT INTO "nl:"
        j = seq(carenet_seq,nextval)
        FROM dual
        DETAIL
         new_name_value_prefs_id = cnvtreal(j)
        WITH format, counter
       ;end select
       IF (error(serrormessage,0) > 0)
        SET readme_data->message = concat("Error selecting from dual table: ",serrormessage)
        RETURN(0)
       ENDIF
       INSERT  FROM name_value_prefs nvp
        SET nvp.name_value_prefs_id = new_name_value_prefs_id, nvp.parent_entity_name =
         insert_view_comp_prefs->qual[i].parent_entity_name, nvp.parent_entity_id =
         insert_view_comp_prefs->qual[i].parent_entity_id,
         nvp.pvc_name = insert_view_comp_prefs->qual[i].pvc_name, nvp.pvc_value =
         insert_view_comp_prefs->qual[i].pvc_value, nvp.active_ind = 1,
         nvp.merge_name = null, nvp.merge_id = 0.0, nvp.sequence = null,
         nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp
         .updt_task = reqinfo->updt_task,
         nvp.updt_cnt = 0, nvp.updt_applctx = reqinfo->updt_applctx
        WITH nocounter
       ;end insert
       IF (error(serrormessage,0) > 0)
        SET readme_data->message = concat("Error inserting into name_value_prefs table: ",
         serrormessage)
        RETURN(0)
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   DECLARE fscndlg_frame_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM view_prefs vp
    WHERE vp.application_number=application_nbr
     AND vp.position_cd=0.0
     AND vp.prsnl_id=0.0
     AND vp.frame_type="FSCNDLG"
     AND vp.view_name="FSCLINNOTES"
     AND vp.active_ind=1
    DETAIL
     fscndlg_frame_id = vp.view_prefs_id
    WITH nocounter
   ;end select
   IF (error(serrormessage,0) > 0)
    SET readme_data->message = concat("Error selecting from view_prefs table: ",serrormessage)
    RETURN(0)
   ENDIF
   IF (fscndlg_frame_id=0.0)
    SELECT INTO "nl:"
     j = seq(carenet_seq,nextval)
     FROM dual
     DETAIL
      fscndlg_frame_id = cnvtreal(j)
     WITH format, counter
    ;end select
    IF (error(serrormessage,0) > 0)
     SET readme_data->message = concat("Error selecting from dual table: ",serrormessage)
     RETURN(0)
    ENDIF
    INSERT  FROM view_prefs vp
     SET vp.view_prefs_id = fscndlg_frame_id, vp.application_number = application_nbr, vp.position_cd
       = 0.0,
      vp.prsnl_id = 0.0, vp.frame_type = "FSCNDLG", vp.view_name = "FSCLINNOTES",
      vp.view_seq = 1, vp.active_ind = 1, vp.updt_cnt = 0,
      vp.updt_id = reqinfo->updt_id, vp.updt_dt_tm = cnvtdatetime(curdate,curtime3), vp.updt_task =
      reqinfo->updt_task,
      vp.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (error(serrormessage,0) > 0)
     SET readme_data->message = concat("Error inserting into view_prefs table: ",serrormessage)
     RETURN(0)
    ENDIF
    FREE RECORD insert_view_prefs
    RECORD insert_view_prefs(
      1 qual[*]
        2 parent_entity_name = vc
        2 parent_entity_id = f8
        2 pvc_name = vc
        2 pvc_value = vc
    )
    SET stat = alterlist(insert_view_prefs->qual,3)
    SET insert_view_prefs->qual[1].parent_entity_name = "VIEW_PREFS"
    SET insert_view_prefs->qual[1].parent_entity_id = fscndlg_frame_id
    SET insert_view_prefs->qual[1].pvc_name = "VIEW_CAPTION"
    SET insert_view_prefs->qual[1].pvc_value = "Document Viewer"
    SET insert_view_prefs->qual[2].parent_entity_name = "VIEW_PREFS"
    SET insert_view_prefs->qual[2].parent_entity_id = fscndlg_frame_id
    SET insert_view_prefs->qual[2].pvc_name = "VIEW_IND"
    SET insert_view_prefs->qual[2].pvc_value = "0"
    SET insert_view_prefs->qual[3].parent_entity_name = "VIEW_PREFS"
    SET insert_view_prefs->qual[3].parent_entity_id = fscndlg_frame_id
    SET insert_view_prefs->qual[3].pvc_name = "DISPLAY_SEQ"
    SET insert_view_prefs->qual[3].pvc_value = "1"
    FOR (i = 1 TO size(insert_view_prefs->qual,5))
      SET new_name_value_prefs_id = 0.0
      SELECT INTO "nl:"
       j = seq(carenet_seq,nextval)
       FROM dual
       DETAIL
        new_name_value_prefs_id = cnvtreal(j)
       WITH format, counter
      ;end select
      IF (error(serrormessage,0) > 0)
       SET readme_data->message = concat("Error selecting from dual table: ",serrormessage)
       RETURN(0)
      ENDIF
      INSERT  FROM name_value_prefs nvp
       SET nvp.name_value_prefs_id = new_name_value_prefs_id, nvp.parent_entity_name =
        insert_view_prefs->qual[i].parent_entity_name, nvp.parent_entity_id = insert_view_prefs->
        qual[i].parent_entity_id,
        nvp.pvc_name = insert_view_prefs->qual[i].pvc_name, nvp.pvc_value = insert_view_prefs->qual[i
        ].pvc_value, nvp.active_ind = 1,
        nvp.merge_name = null, nvp.merge_id = 0.0, nvp.sequence = null,
        nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp
        .updt_task = reqinfo->updt_task,
        nvp.updt_cnt = 0, nvp.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      IF (error(serrormessage,0) > 0)
       SET readme_data->message = concat("Error inserting into name_value_prefs table: ",
        serrormessage)
       RETURN(0)
      ENDIF
    ENDFOR
    SET vp_id = 0.0
    SELECT INTO "nl:"
     FROM view_comp_prefs vp
     WHERE vp.application_number=application_nbr
      AND vp.position_cd=0.0
      AND vp.prsnl_id=0.0
      AND vp.view_name="FSCLINNOTES"
      AND vp.view_seq=1
      AND vp.comp_name="CLINNOTES"
      AND vp.comp_seq=1
      AND vp.active_ind=1
     DETAIL
      vp_id = vp.view_comp_prefs_id
     WITH nocounter
    ;end select
    IF (error(serrormessage,0) > 0)
     SET readme_data->message = concat("Error selecting from view_comp_prefs table: ",serrormessage)
     RETURN(0)
    ENDIF
    IF (vp_id=0.0)
     SELECT INTO "nl:"
      j = seq(carenet_seq,nextval)
      FROM dual
      DETAIL
       vp_id = cnvtreal(j)
      WITH format, counter
     ;end select
     IF (error(serrormessage,0) > 0)
      SET readme_data->message = concat("Error selecting from dual table: ",serrormessage)
      RETURN(0)
     ENDIF
     INSERT  FROM view_comp_prefs vp
      SET vp.view_comp_prefs_id = vp_id, vp.application_number = application_nbr, vp.position_cd =
       0.0,
       vp.prsnl_id = 0.0, vp.view_name = "FSCLINNOTES", vp.view_seq = 1,
       vp.comp_name = "CLINNOTES", vp.comp_seq = 1, vp.active_ind = 1,
       vp.updt_dt_tm = cnvtdatetime(curdate,curtime3), vp.updt_id = reqinfo->updt_id, vp.updt_task =
       reqinfo->updt_task,
       vp.updt_applctx = reqinfo->updt_applctx, vp.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (error(serrormessage,0) > 0)
      SET readme_data->message = concat("Error inserting into view_comp_prefs table: ",serrormessage)
      RETURN(0)
     ENDIF
     FREE RECORD insert_view_comp_prefs
     RECORD insert_view_comp_prefs(
       1 qual[*]
         2 parent_entity_name = vc
         2 parent_entity_id = f8
         2 pvc_name = vc
         2 pvc_value = vc
     )
     SET stat = alterlist(insert_view_comp_prefs->qual,3)
     SET insert_view_comp_prefs->qual[1].parent_entity_name = "VIEW_COMP_PREFS"
     SET insert_view_comp_prefs->qual[1].parent_entity_id = vp_id
     SET insert_view_comp_prefs->qual[1].pvc_name = "PROGID"
     SET insert_view_comp_prefs->qual[1].pvc_value = "PVNOTES.PVNOTES"
     SET insert_view_comp_prefs->qual[2].parent_entity_name = "VIEW_COMP_PREFS"
     SET insert_view_comp_prefs->qual[2].parent_entity_id = vp_id
     SET insert_view_comp_prefs->qual[2].pvc_name = "COMP_DLLNAME"
     SET insert_view_comp_prefs->qual[2].pvc_value = "PVNOTES"
     SET insert_view_comp_prefs->qual[3].parent_entity_name = "VIEW_COMP_PREFS"
     SET insert_view_comp_prefs->qual[3].parent_entity_id = vp_id
     SET insert_view_comp_prefs->qual[3].pvc_name = "COMP_POSITION"
     SET insert_view_comp_prefs->qual[3].pvc_value = "0,0,3,4"
     FOR (i = 1 TO size(insert_view_comp_prefs->qual,5))
       SET new_name_value_prefs_id = 0.0
       SELECT INTO "nl:"
        j = seq(carenet_seq,nextval)
        FROM dual
        DETAIL
         new_name_value_prefs_id = cnvtreal(j)
        WITH format, counter
       ;end select
       IF (error(serrormessage,0) > 0)
        SET readme_data->message = concat("Error selecting from dual table: ",serrormessage)
        RETURN(0)
       ENDIF
       INSERT  FROM name_value_prefs nvp
        SET nvp.name_value_prefs_id = new_name_value_prefs_id, nvp.parent_entity_name =
         insert_view_comp_prefs->qual[i].parent_entity_name, nvp.parent_entity_id =
         insert_view_comp_prefs->qual[i].parent_entity_id,
         nvp.pvc_name = insert_view_comp_prefs->qual[i].pvc_name, nvp.pvc_value =
         insert_view_comp_prefs->qual[i].pvc_value, nvp.active_ind = 1,
         nvp.merge_name = null, nvp.merge_id = 0.0, nvp.sequence = null,
         nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp
         .updt_task = reqinfo->updt_task,
         nvp.updt_cnt = 0, nvp.updt_applctx = reqinfo->updt_applctx
        WITH nocounter
       ;end insert
       IF (error(serrormessage,0) > 0)
        SET readme_data->message = concat("Error inserting into name_value_prefs table: ",
         serrormessage)
        RETURN(0)
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM app_prefs ap
    WHERE ap.position_cd=0.0
     AND ap.prsnl_id=0.0
     AND ap.application_number=application_nbr
     AND ap.active_ind=1
    DETAIL
     app_prefs_id = ap.app_prefs_id
    WITH nocounter
   ;end select
   IF (error(serrormessage,0) > 0)
    SET readme_data->message = concat("Error selecting from app_prefs table: ",serrormessage)
    RETURN(0)
   ENDIF
   IF (app_prefs_id=0)
    SET app_prefs_id = 0.0
    SELECT INTO "nl:"
     j = seq(carenet_seq,nextval)
     FROM dual
     DETAIL
      app_prefs_id = cnvtreal(j)
     WITH format, counter
    ;end select
    IF (error(serrormessage,0) > 0)
     SET readme_data->message = concat("Error selecting from dual table: ",serrormessage)
     RETURN(0)
    ENDIF
    INSERT  FROM app_prefs ap
     SET ap.app_prefs_id = app_prefs_id, ap.application_number = application_nbr, ap.position_cd =
      0.0,
      ap.prsnl_id = 0.0, ap.active_ind = 1, ap.updt_cnt = 0,
      ap.updt_id = reqinfo->updt_id, ap.updt_dt_tm = cnvtdatetime(curdate,curtime), ap.updt_task =
      reqinfo->updt_task,
      ap.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (error(serrormessage,0) > 0)
     SET readme_data->message = concat("Error inserting into app_prefs table: ",serrormessage)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET readme_data->message = "Cannot perform inserts or updates with app_prefs_id of 0.0"
     RETURN(0)
    ENDIF
   ENDIF
   DECLARE nflowsheet_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM app_prefs ap,
     detail_prefs dp
    PLAN (ap
     WHERE ap.position_cd=0.0
      AND ap.prsnl_id=0.0
      AND ap.application_number=application_nbr
      AND ap.active_ind=1)
     JOIN (dp
     WHERE dp.position_cd=ap.position_cd
      AND dp.prsnl_id=ap.prsnl_id
      AND dp.application_number=ap.application_number
      AND dp.view_name="FLOWSHEET"
      AND dp.comp_name="FLOWSHEET"
      AND dp.active_ind=1)
    DETAIL
     nflowsheet_id = dp.detail_prefs_id
    WITH nocounter
   ;end select
   IF (error(serrormessage,0) > 0)
    SET readme_data->message = concat("Error selecting from app_prefs, detail_prefs table: ",
     serrormessage)
    RETURN(0)
   ENDIF
   IF (nflowsheet_id=0.0)
    SET nflowsheet_id = 0.0
    SELECT INTO "nl:"
     j = seq(carenet_seq,nextval)
     FROM dual
     DETAIL
      nflowsheet_id = cnvtreal(j)
     WITH format, counter
    ;end select
    IF (error(serrormessage,0) > 0)
     SET readme_data->message = concat("Error selecting from dual table: ",serrormessage)
     RETURN(0)
    ENDIF
    INSERT  FROM detail_prefs dp
     SET dp.detail_prefs_id = nflowsheet_id, dp.application_number = application_nbr, dp.position_cd
       = 0.0,
      dp.prsnl_id = 0.0, dp.person_id = 0.0, dp.view_name = "FLOWSHEET",
      dp.view_seq = 1, dp.comp_name = "FLOWSHEET", dp.comp_seq = 1,
      dp.active_ind = 1, dp.updt_id = reqinfo->updt_id, dp.updt_cnt = 0,
      dp.updt_task = reqinfo->updt_task, dp.updt_applctx = reqinfo->updt_applctx, dp.updt_dt_tm =
      cnvtdatetime(curdate,curtime)
     WITH nocounter
    ;end insert
    IF (error(serrormessage,0) > 0)
     SET readme_data->message = concat("Error inserting into detail_prefs table: ",serrormessage)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET readme_data->message = "Cannot perform inserts or updates with detail_prefs_id of 0.0"
     RETURN(0)
    ENDIF
   ENDIF
   DECLARE nclin_notes_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM app_prefs ap,
     detail_prefs dp
    PLAN (ap
     WHERE ap.position_cd=0.0
      AND ap.prsnl_id=0.0
      AND ap.application_number=application_nbr
      AND ap.active_ind=1)
     JOIN (dp
     WHERE dp.position_cd=ap.position_cd
      AND dp.prsnl_id=ap.prsnl_id
      AND dp.application_number=ap.application_number
      AND dp.view_name="FSCLINNOTES"
      AND dp.comp_name="CLINNOTES"
      AND dp.active_ind=1)
    DETAIL
     nclin_notes_id = dp.detail_prefs_id
    WITH nocounter
   ;end select
   IF (error(serrormessage,0) > 0)
    SET readme_data->message = concat("Error selecting from app_prefs, detail_prefs table: ",
     serrormessage)
    RETURN(0)
   ENDIF
   IF (nclin_notes_id=0.0)
    SET nclin_notes_id = 0.0
    SELECT INTO "nl:"
     j = seq(carenet_seq,nextval)
     FROM dual
     DETAIL
      nclin_notes_id = cnvtreal(j)
     WITH format, counter
    ;end select
    IF (error(serrormessage,0) > 0)
     SET readme_data->message = concat("Error selecting from dual table: ",serrormessage)
     RETURN(0)
    ENDIF
    INSERT  FROM detail_prefs dp
     SET dp.detail_prefs_id = nclin_notes_id, dp.application_number = application_nbr, dp.position_cd
       = 0.0,
      dp.prsnl_id = 0.0, dp.person_id = 0.0, dp.view_name = "FSCLINNOTES",
      dp.view_seq = 1, dp.comp_name = "CLINNOTES", dp.comp_seq = 1,
      dp.active_ind = 1, dp.updt_id = reqinfo->updt_id, dp.updt_cnt = 0,
      dp.updt_task = reqinfo->updt_task, dp.updt_applctx = reqinfo->updt_applctx, dp.updt_dt_tm =
      cnvtdatetime(curdate,curtime)
     WITH nocounter
    ;end insert
    IF (error(serrormessage,0) > 0)
     SET readme_data->message = concat("Error inserting into detail_prefs table: ",serrormessage)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET readme_data->message = "Cannot perform inserts or updates with detail_prefs_id of 0.0"
     RETURN(0)
    ENDIF
   ENDIF
   FREE RECORD update_prefs
   RECORD update_prefs(
     1 qual[*]
       2 name_value_prefs_id = f8
       2 pvc_name = vc
       2 pvc_value = vc
       2 view_name = vc
       2 comp_name = vc
   )
   SET stat = alterlist(update_prefs->qual,update_pref_cnt)
   SET update_prefs->qual[1].name_value_prefs_id = 0.0
   SET update_prefs->qual[1].pvc_name = "DASHBOARD"
   SET update_prefs->qual[1].pvc_value = "1"
   SET update_prefs->qual[1].view_name = "FLOWSHEET"
   SET update_prefs->qual[1].comp_name = "FLOWSHEET"
   SET update_prefs->qual[2].name_value_prefs_id = 0.0
   SET update_prefs->qual[2].pvc_name = "R_EVENT_SET_NAME"
   SET update_prefs->qual[2].pvc_value = "ALL RESULT SECTIONS"
   SET update_prefs->qual[2].view_name = "FLOWSHEET"
   SET update_prefs->qual[2].comp_name = "FLOWSHEET"
   SET update_prefs->qual[3].name_value_prefs_id = 0.0
   SET update_prefs->qual[3].pvc_name = "RANGE_LABEL"
   SET update_prefs->qual[3].pvc_value = "1"
   SET update_prefs->qual[3].view_name = "FLOWSHEET"
   SET update_prefs->qual[3].comp_name = "FLOWSHEET"
   SET update_prefs->qual[4].name_value_prefs_id = 0.0
   SET update_prefs->qual[4].pvc_name = "R_RESULT_STAT_IND"
   SET update_prefs->qual[4].pvc_value = "0"
   SET update_prefs->qual[4].view_name = "FLOWSHEET"
   SET update_prefs->qual[4].comp_name = "FLOWSHEET"
   SET update_prefs->qual[5].name_value_prefs_id = 0.0
   SET update_prefs->qual[5].pvc_name = "MODIFY_CHARTING"
   SET update_prefs->qual[5].pvc_value = "0"
   SET update_prefs->qual[5].view_name = "FLOWSHEET"
   SET update_prefs->qual[5].comp_name = "FLOWSHEET"
   SET update_prefs->qual[6].name_value_prefs_id = 0.0
   SET update_prefs->qual[6].pvc_name = "R_CRIT_CHAR_IND"
   SET update_prefs->qual[6].pvc_value = "1"
   SET update_prefs->qual[6].view_name = "FLOWSHEET"
   SET update_prefs->qual[6].comp_name = "FLOWSHEET"
   SET update_prefs->qual[7].name_value_prefs_id = 0.0
   SET update_prefs->qual[7].pvc_name = "HIGH_STR"
   SET update_prefs->qual[7].pvc_value = snormal_high_disp
   SET update_prefs->qual[7].view_name = "FLOWSHEET"
   SET update_prefs->qual[7].comp_name = "FLOWSHEET"
   SET update_prefs->qual[8].name_value_prefs_id = 0.0
   SET update_prefs->qual[8].pvc_name = "LOW_STR"
   SET update_prefs->qual[8].pvc_value = snormal_low_disp
   SET update_prefs->qual[8].view_name = "FLOWSHEET"
   SET update_prefs->qual[8].comp_name = "FLOWSHEET"
   SET update_prefs->qual[9].name_value_prefs_id = 0.0
   SET update_prefs->qual[9].pvc_name = "NORMALCY_COLORS"
   SET update_prefs->qual[9].pvc_value = "0"
   SET update_prefs->qual[9].view_name = "FLOWSHEET"
   SET update_prefs->qual[9].comp_name = "FLOWSHEET"
   SET update_prefs->qual[10].name_value_prefs_id = 0.0
   SET update_prefs->qual[10].pvc_name = "R_CRIT_IND"
   SET update_prefs->qual[10].pvc_value = "1"
   SET update_prefs->qual[10].view_name = "FLOWSHEET"
   SET update_prefs->qual[10].comp_name = "FLOWSHEET"
   SET update_prefs->qual[11].name_value_prefs_id = 0.0
   SET update_prefs->qual[11].pvc_name = "CRIT_VAL_CLR"
   SET update_prefs->qual[11].pvc_value = "255"
   SET update_prefs->qual[11].view_name = "FLOWSHEET"
   SET update_prefs->qual[11].comp_name = "FLOWSHEET"
   SET update_prefs->qual[12].name_value_prefs_id = 0.0
   SET update_prefs->qual[12].pvc_name = "CRIT_STR"
   SET update_prefs->qual[12].pvc_value = scritical_disp
   SET update_prefs->qual[12].view_name = "FLOWSHEET"
   SET update_prefs->qual[12].comp_name = "FLOWSHEET"
   SET update_prefs->qual[13].name_value_prefs_id = 0.0
   SET update_prefs->qual[13].pvc_name = "NOTE_STR"
   SET update_prefs->qual[13].pvc_value = "f"
   SET update_prefs->qual[13].view_name = "FLOWSHEET"
   SET update_prefs->qual[13].comp_name = "FLOWSHEET"
   SET update_prefs->qual[14].name_value_prefs_id = 0.0
   SET update_prefs->qual[14].pvc_name = "ABNORMAL_STR"
   SET update_prefs->qual[14].pvc_value = salp_abnormal_disp
   SET update_prefs->qual[14].view_name = "FLOWSHEET"
   SET update_prefs->qual[14].comp_name = "FLOWSHEET"
   SET update_prefs->qual[15].name_value_prefs_id = 0.0
   SET update_prefs->qual[15].pvc_name = "CORR_STR"
   SET update_prefs->qual[15].pvc_value = "c"
   SET update_prefs->qual[15].view_name = "FLOWSHEET"
   SET update_prefs->qual[15].comp_name = "FLOWSHEET"
   SET update_prefs->qual[16].name_value_prefs_id = 0.0
   SET update_prefs->qual[16].pvc_name = "R_APPEND_AFTER_IND"
   SET update_prefs->qual[16].pvc_value = "1"
   SET update_prefs->qual[16].view_name = "FLOWSHEET"
   SET update_prefs->qual[16].comp_name = "FLOWSHEET"
   SET update_prefs->qual[17].name_value_prefs_id = 0.0
   SET update_prefs->qual[17].pvc_name = "NEW_DOC_VIEWER"
   SET update_prefs->qual[17].pvc_value = "1"
   SET update_prefs->qual[17].view_name = "FSCLINNOTES"
   SET update_prefs->qual[17].comp_name = "CLINNOTES"
   SET update_prefs->qual[18].name_value_prefs_id = 0.0
   SET update_prefs->qual[18].pvc_name = "pvNotes.ReadOnly"
   SET update_prefs->qual[18].pvc_value = "1"
   SET update_prefs->qual[18].view_name = "FSCLINNOTES"
   SET update_prefs->qual[18].comp_name = "CLINNOTES"
   SET update_prefs->qual[19].name_value_prefs_id = 0.0
   SET update_prefs->qual[19].pvc_name = "pvNotes.InErrorDocument"
   SET update_prefs->qual[19].pvc_value = "0"
   SET update_prefs->qual[19].view_name = "FSCLINNOTES"
   SET update_prefs->qual[19].comp_name = "CLINNOTES"
   SET update_prefs->qual[20].name_value_prefs_id = 0.0
   SET update_prefs->qual[20].pvc_name = "pvNotes.ShowForwardBtn"
   SET update_prefs->qual[20].pvc_value = "0"
   SET update_prefs->qual[20].view_name = "FSCLINNOTES"
   SET update_prefs->qual[20].comp_name = "CLINNOTES"
   SET update_prefs->qual[21].name_value_prefs_id = 0.0
   SET update_prefs->qual[21].pvc_name = "pvNotes.ShowReviewBtn"
   SET update_prefs->qual[21].pvc_value = "0"
   SET update_prefs->qual[21].view_name = "FSCLINNOTES"
   SET update_prefs->qual[21].comp_name = "CLINNOTES"
   SET update_prefs->qual[22].name_value_prefs_id = 0.0
   SET update_prefs->qual[22].pvc_name = "pvNotes.ShowSignBtn"
   SET update_prefs->qual[22].pvc_value = "0"
   SET update_prefs->qual[22].view_name = "FSCLINNOTES"
   SET update_prefs->qual[22].comp_name = "CLINNOTES"
   SET update_prefs->qual[23].name_value_prefs_id = 0.0
   SET update_prefs->qual[23].pvc_name = "pvNotes.ShowSubmitBtn"
   SET update_prefs->qual[23].pvc_value = "0"
   SET update_prefs->qual[23].view_name = "FSCLINNOTES"
   SET update_prefs->qual[23].comp_name = "CLINNOTES"
   SET update_prefs->qual[24].name_value_prefs_id = 0.0
   SET update_prefs->qual[24].pvc_name = "PRINT_DOCUMENTS"
   SET update_prefs->qual[24].pvc_value = "1;1;0;0;0;0"
   SET update_prefs->qual[24].view_name = ""
   SET update_prefs->qual[24].comp_name = ""
   SET update_prefs->qual[25].name_value_prefs_id = 0.0
   SET update_prefs->qual[25].pvc_name = "R_ORIENTATION"
   SET update_prefs->qual[25].pvc_value = "1"
   SET update_prefs->qual[25].view_name = "FLOWSHEET"
   SET update_prefs->qual[25].comp_name = "FLOWSHEET"
   SET update_prefs->qual[26].name_value_prefs_id = 0.0
   SET update_prefs->qual[26].pvc_name = "AUTOIMAGELAUNCH"
   SET update_prefs->qual[26].pvc_value = "0"
   SET update_prefs->qual[26].view_name = ""
   SET update_prefs->qual[26].comp_name = ""
   FOR (i = 1 TO update_pref_cnt)
     IF ((update_prefs->qual[i].view_name="FLOWSHEET"))
      SET dp_parent_entity_id = nflowsheet_id
      SET parent_entity_name = "DETAIL_PREFS"
     ELSEIF ((update_prefs->qual[i].view_name="FSCLINNOTES"))
      SET dp_parent_entity_id = nclin_notes_id
      SET parent_entity_name = "DETAIL_PREFS"
     ELSE
      SET dp_parent_entity_id = app_prefs_id
      SET parent_entity_name = "APP_PREFS"
     ENDIF
     IF (dp_parent_entity_id=0.0)
      SET readme_data->message = "Cannot perform insert or update with parent_entity_id of 0.0"
      RETURN(0)
     ENDIF
     SELECT INTO "nl:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_id IN (app_prefs_id, dp_parent_entity_id)
       AND nvp.parent_entity_name IN ("APP_PREFS", "DETAIL_PREFS")
       AND (nvp.pvc_name=update_prefs->qual[i].pvc_name)
      DETAIL
       update_prefs->qual[i].name_value_prefs_id = nvp.name_value_prefs_id
      WITH nocounter
     ;end select
     IF (error(serrormessage,0) > 0)
      SET readme_data->message = concat("Error selecting from name_value_prefs table: ",serrormessage
       )
      RETURN(0)
     ENDIF
     IF ((update_prefs->qual[i].name_value_prefs_id > 0.0))
      SELECT INTO "nl:"
       FROM name_value_prefs nvp
       WHERE (nvp.name_value_prefs_id=update_prefs->qual[i].name_value_prefs_id)
       WITH nocounter, forupdate(nvp)
      ;end select
      IF (error(serrormessage,0) > 0)
       SET readme_data->message = concat("Error locking name_value_prefs table: ",serrormessage)
       RETURN(0)
      ENDIF
      IF (curqual > 0)
       UPDATE  FROM name_value_prefs nvp
        SET nvp.pvc_value = update_prefs->qual[i].pvc_value, nvp.updt_applctx = reqinfo->updt_applctx,
         nvp.updt_task = reqinfo->updt_task,
         nvp.updt_id = reqinfo->updt_id, nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_dt_tm =
         cnvtdatetime(curdate,curtime3)
        WHERE (nvp.name_value_prefs_id=update_prefs->qual[i].name_value_prefs_id)
        WITH nocounter
       ;end update
       IF (error(serrormessage,0) > 0)
        SET readme_data->message = concat("Error updating name_value_prefs table: ",serrormessage)
        RETURN(0)
       ENDIF
       IF (curqual=0)
        SET readme_data->message = build("Update failed for row with name_value_prefs_id = ",
         update_prefs->qual[i].name_value_prefs_id)
        RETURN(0)
       ENDIF
      ENDIF
     ELSE
      SET new_name_value_prefs_id = 0.0
      SELECT INTO "nl:"
       j = seq(carenet_seq,nextval)
       FROM dual
       DETAIL
        new_name_value_prefs_id = cnvtreal(j)
       WITH format, counter
      ;end select
      IF (error(serrormessage,0) > 0)
       SET readme_data->message = concat("Error selecting from dual table: ",serrormessage)
       RETURN(0)
      ENDIF
      INSERT  FROM name_value_prefs nvp
       SET nvp.name_value_prefs_id = new_name_value_prefs_id, nvp.parent_entity_name =
        parent_entity_name, nvp.parent_entity_id = dp_parent_entity_id,
        nvp.pvc_name = update_prefs->qual[i].pvc_name, nvp.pvc_value = update_prefs->qual[i].
        pvc_value, nvp.active_ind = 1,
        nvp.merge_name = null, nvp.merge_id = 0.0, nvp.sequence = null,
        nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp
        .updt_task = reqinfo->updt_task,
        nvp.updt_cnt = 0, nvp.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      IF (error(serrormessage,0) > 0)
       SET readme_data->message = concat("Error inserting into name_value_prefs table: ",
        serrormessage)
       RETURN(0)
      ENDIF
      IF (curqual=0)
       SET readme_data->message = build("Insert failed for row with pvc_name = ",update_prefs->qual[i
        ].pvc_name)
       RETURN(0)
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 FREE RECORD app_num
END GO
