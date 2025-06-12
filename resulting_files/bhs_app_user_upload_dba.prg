CREATE PROGRAM bhs_app_user_upload:dba
 DECLARE ml_user_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_for_cnt = i4 WITH protect, noconstant(0)
 DECLARE mf_person_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_errmsg = vc WITH protect, noconstant("")
 DECLARE ml_username_len = i4 WITH protect, noconstant(0)
 SET ml_user_cnt = size(requestin->list_0,5)
 FOR (ml_for_cnt = 1 TO ml_user_cnt)
   SET mf_person_id = 0.0
   SET ml_username_len = textlen(requestin->list_0[ml_for_cnt].app_username)
   SET mf_person_id = cnvtreal(requestin->list_0[ml_for_cnt].person_id)
   IF (mf_person_id > 0
    AND ml_username_len > 0)
    SELECT INTO "nl:"
     FROM bhs_application_user bau
     WHERE bau.application=cnvtupper(requestin->list_0[ml_for_cnt].application)
      AND bau.person_id=mf_person_id
     WITH nocounter
    ;end select
    IF (curqual > 0)
     UPDATE  FROM bhs_application_user b
      SET b.application_username = cnvtupper(trim(requestin->list_0[ml_for_cnt].app_username,3)), b
       .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), b.active_ind = 1,
       b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id =
       reqinfo->updt_id
      WHERE b.application=cnvtupper(requestin->list_0[ml_for_cnt].application)
       AND b.person_id=mf_person_id
      WITH nocounter
     ;end update
    ELSE
     INSERT  FROM bhs_application_user a
      SET a.application_user_id = seq(person_seq,nextval), a.person_id = mf_person_id, a.application
        = cnvtupper(trim(requestin->list_0[ml_for_cnt].application,3)),
       a.application_username = cnvtupper(trim(requestin->list_0[ml_for_cnt].app_username,3)), a
       .active_ind = 1, a.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       a.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), a.updt_cnt = 0, a.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       a.updt_id = reqinfo->updt_id
      WITH nocounter
     ;end insert
    ENDIF
    IF (error(ms_errmsg,1)=0)
     COMMIT
    ELSE
     ROLLBACK
    ENDIF
   ENDIF
 ENDFOR
 CALL echo("***")
 CALL echo(ml_user_cnt)
 CALL echo("---")
END GO
