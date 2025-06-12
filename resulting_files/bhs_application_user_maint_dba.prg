CREATE PROGRAM bhs_application_user_maint:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Action" = "1",
  "CIS Username" = "",
  "Application" = "",
  "CIS Username" = "",
  "Application" = "",
  "Application Username" = "",
  "Current User List" = "",
  "CIS Username" = "",
  "Application" = "",
  "Current User List" = "",
  "Current User List" = ""
  WITH outdev, ml_action, ms_cis_username_remove,
  ms_application_remove, ms_cis_username_add, ms_application_add,
  ms_application_username_add, ms_username_list, ms_cis_username_view,
  ms_application_view, ms_username_list_view, ms_username_list_remove
 DECLARE ml_cis_username_size = i4 WITH protect, noconstant(0)
 DECLARE ml_application_size = i4 WITH protect, noconstant(0)
 DECLARE ml_application_username_size = i4 WITH protect, noconstant(0)
 DECLARE ms_application = vc WITH protect, noconstant("")
 DECLARE mf_person_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_err_msg = vc WITH protect, noconstant("")
 DECLARE ml_err_ind = i2 WITH protect, noconstant(0)
 IF (( $ML_ACTION="1"))
  SET ms_application =  $MS_APPLICATION_ADD
  SELECT INTO "nl:"
   FROM prsnl p
   WHERE p.username=cnvtupper(trim( $MS_CIS_USERNAME_ADD,3))
   DETAIL
    mf_person_id = p.person_id
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET ml_cis_username_size = textlen(trim( $MS_CIS_USERNAME_ADD,3))
   SET ml_application_size = textlen(trim(ms_application,3))
   SET ml_application_username_size = textlen(trim( $MS_APPLICATION_USERNAME_ADD,3))
   IF (ml_cis_username_size > 0
    AND ml_application_size > 0
    AND ml_application_username_size > 0)
    SELECT INTO "nl:"
     FROM bhs_application_user a
     WHERE a.application=cnvtupper(trim(ms_application,3))
      AND a.application_username=cnvtupper(trim( $MS_APPLICATION_USERNAME_ADD,3))
      AND a.person_id=mf_person_id
      AND a.active_ind=1
     WITH nocounter
    ;end select
    IF (curqual=0)
     INSERT  FROM bhs_application_user a
      SET a.application_user_id = seq(person_seq,nextval), a.person_id = mf_person_id, a.application
        = cnvtupper(trim(ms_application,3)),
       a.application_username = cnvtupper(trim( $MS_APPLICATION_USERNAME_ADD,3)), a.active_ind = 1, a
       .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       a.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), a.updt_cnt = 0, a.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       a.updt_id = reqinfo->updt_id
      WITH nocounter
     ;end insert
     IF (error(ms_err_msg,1) != 0)
      ROLLBACK
      SET ml_err_ind = 1
     ENDIF
     SELECT INTO  $OUTDEV
      FROM dummyt d
      DETAIL
       col 0, "*** CIS Username Added ***", row + 1,
       "CIS Username: ", col + 1,  $MS_CIS_USERNAME_ADD,
       row + 1, "Application: ", col + 1,
       ms_application, row + 1, "Application username: ",
       col + 1,  $MS_APPLICATION_USERNAME_ADD
      WITH separator = " ", format
     ;end select
    ELSE
     SELECT INTO  $OUTDEV
      FROM dummyt d
      DETAIL
       col 0, "*** CIS Username Already Exists on table ***", row + 1,
       "CIS Username: ", col + 1,  $MS_CIS_USERNAME_ADD,
       row + 1, "Application: ", col + 1,
       ms_application, row + 1, "Application username: ",
       col + 1,  $MS_APPLICATION_USERNAME_ADD
      WITH separator = " ", format
     ;end select
    ENDIF
   ELSE
    SELECT INTO  $OUTDEV
     FROM dummyt d
     DETAIL
      col 0, "*** Not all input entered ***", row + 1,
      "CIS Username: ", col + 1,  $MS_CIS_USERNAME_ADD,
      row + 1, "Application: ", col + 1,
      ms_application, row + 1, "Application username: ",
      col + 1,  $MS_APPLICATION_USERNAME_ADD
     WITH separator = " ", format
    ;end select
   ENDIF
  ELSE
   SELECT INTO  $OUTDEV
    FROM dummyt d
    DETAIL
     col 0, "*** CIS Username not found ***", row + 1,
      $MS_CIS_USERNAME_ADD
    WITH separator = " ", format
   ;end select
  ENDIF
 ELSEIF (( $ML_ACTION="2"))
  SET ms_application =  $MS_APPLICATION_REMOVE
  SET ml_cis_username_size = textlen(trim( $MS_CIS_USERNAME_REMOVE,3))
  SET ml_application_size = textlen(trim(ms_application,3))
  IF (ml_cis_username_size > 0
   AND ml_application_size > 0)
   UPDATE  FROM bhs_application_user a
    SET a.active_ind = 0, a.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_cnt = (a
     .updt_cnt+ 1),
     a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = reqinfo->updt_id
    WHERE a.application=ms_application
     AND a.person_id IN (
    (SELECT
     p.person_id
     FROM prsnl p
     WHERE p.username=cnvtupper(trim( $MS_CIS_USERNAME_REMOVE,3))))
     AND a.active_ind=1
    WITH nocounter
   ;end update
   IF (error(ms_err_msg,1) != 0)
    ROLLBACK
    SET ml_err_ind = 1
   ENDIF
   SELECT INTO  $OUTDEV
    FROM dummyt d
    DETAIL
     col 0, "*** Username Removed ***", row + 1,
     "CIS Username: ", col + 1,  $MS_CIS_USERNAME_REMOVE,
     row + 1, "Application: ", col + 1,
     ms_application
    WITH separator = " ", format
   ;end select
  ELSE
   SELECT INTO  $OUTDEV
    FROM dummyt d
    DETAIL
     col 0, "*** Not all input entered ***", row + 1,
     "CIS Username: ", col + 1,  $MS_CIS_USERNAME_REMOVE,
     row + 1, "Application: ", col + 1,
     ms_application
    WITH separator = " ", format
   ;end select
  ENDIF
 ELSEIF (( $ML_ACTION="3"))
  SET ms_application =  $MS_APPLICATION_VIEW
  SELECT INTO "nl:"
   FROM prsnl p
   WHERE p.username=cnvtupper(trim( $MS_CIS_USERNAME_VIEW,3))
   DETAIL
    mf_person_id = p.person_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM bhs_application_user a
   WHERE a.application=cnvtupper(trim(ms_application,3))
    AND a.person_id=mf_person_id
    AND a.active_ind=1
   DETAIL
    ms_application_username = a.application_username
   WITH nocounter
  ;end select
  IF (curqual=0)
   SELECT INTO  $OUTDEV
    FROM dummyt d
    DETAIL
     col 0, "*** Username Not Found ***", row + 1,
     "CIS Username: ", col + 1,  $MS_CIS_USERNAME_VIEW,
     row + 1, "Application: ", col + 1,
     ms_application
    WITH separator = " ", format
   ;end select
  ELSE
   SELECT INTO  $OUTDEV
    FROM dummyt d
    DETAIL
     col 0, "*** Username Found ***", row + 1,
     "CIS Username: ", col + 1,  $MS_CIS_USERNAME_VIEW,
     row + 1, "Application: ", col + 1,
     ms_application
    WITH separator = " ", format
   ;end select
  ENDIF
 ENDIF
#end_program
 IF (ml_err_ind=0)
  COMMIT
 ENDIF
END GO
