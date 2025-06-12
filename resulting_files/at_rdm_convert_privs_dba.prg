CREATE PROGRAM at_rdm_convert_privs:dba
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
 FREE RECORD users
 RECORD users(
   1 cnt = i4
   1 qual[*]
     2 user_id = f8
 )
 DECLARE i = i4 WITH noconstant(0)
 DECLARE priv_type_id = f8 WITH protect, noconstant(0.0)
 DECLARE admin_priv_id = f8 WITH protect, noconstant(0.0)
 DECLARE maintatdomain_priv_id = f8 WITH protect, noconstant(0.0)
 DECLARE next_seq = f8 WITH protect, noconstant(0.0)
 DECLARE rdm_errcode = i4
 DECLARE rdm_errmsg = c132
 DECLARE errmsg = c132
 SET readme_data->status = "F"
 SELECT INTO "nl:"
  sf.sf_field_id
  FROM at_systemfield sf
  WHERE sf.sf_meaning="UserPrivilegeId"
  WITH nocounter
 ;end select
 CALL echo(concat("curqual:",cnvtstring(curqual)))
 SET rdm_errmsg = fillstring(132," ")
 SET rdm_errcode = error(rdm_errmsg,0)
 IF (rdm_errcode != 0)
  SET errmsg = rdm_errmsg
  GO TO exit_program
 ENDIF
 IF (curqual=0)
  CALL echo("No privs exist")
  SELECT INTO "nl:"
   y = seq(at_seq,nextval)
   FROM dual
   DETAIL
    priv_type_id = y
   WITH nocounter
  ;end select
  CALL echo(concat("Admin Priv Id: ",cnvtstring(admin_priv_id)))
  INSERT  FROM at_systemfield sf
   SET sf.sf_field_id = priv_type_id, sf.sf_field_type_id = 0, sf.sf_display = "UserPrivilegeId",
    sf.sf_meaning = "UserPrivilegeId", sf.sf_seq = 24, sf.sf_state_flag = 1,
    sf.updt_cnt = 0, sf.updt_id = 0.0, sf.updt_applctx = 0,
    sf.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  SELECT INTO "nl:"
   y = seq(at_seq,nextval)
   FROM dual
   DETAIL
    admin_priv_id = y
   WITH nocounter
  ;end select
  CALL echo(concat("Admin Priv Id: ",cnvtstring(admin_priv_id)))
  INSERT  FROM at_systemfield sf
   SET sf.sf_field_id = admin_priv_id, sf.sf_field_type_id = priv_type_id, sf.sf_display =
    "AutoTester Administration Access",
    sf.sf_meaning = "ADMIN", sf.sf_seq = 1, sf.sf_state_flag = 1,
    sf.updt_cnt = 0, sf.updt_id = 0.0, sf.updt_applctx = 0,
    sf.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  SET rdm_errmsg = fillstring(132," ")
  SET rdm_errcode = error(rdm_errmsg,0)
  IF (rdm_errcode != 0)
   SET errmsg = rdm_errmsg
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
  SELECT INTO "nl:"
   y = seq(at_seq,nextval)
   FROM dual
   DETAIL
    maintatdomain_priv_id = y
   WITH nocounter
  ;end select
  CALL echo(concat("Admin Priv Id: ",cnvtstring(maintatdomain_priv_id)))
  INSERT  FROM at_systemfield sf
   SET sf.sf_field_id = maintatdomain_priv_id, sf.sf_field_type_id = priv_type_id, sf.sf_display =
    "AutoTester Administration Access",
    sf.sf_meaning = "MAINTATDOMAIN", sf.sf_seq = 2, sf.sf_state_flag = 1,
    sf.updt_cnt = 0, sf.updt_id = 0.0, sf.updt_applctx = 0,
    sf.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  SET rdm_errmsg = fillstring(132," ")
  SET rdm_errcode = error(rdm_errmsg,0)
  IF (rdm_errcode != 0)
   SET errmsg = rdm_errmsg
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
  SELECT INTO "nl:"
   FROM at_user us
   WHERE (us.us_maint_user_ind=- (1))
   HEAD REPORT
    stat = alterlist(users->qual,25)
   DETAIL
    users->cnt = (users->cnt+ 1)
    IF (mod(users->cnt,25)=1
     AND (users->cnt != 1))
     stat = alterlist(users->qual,(users->cnt+ 25))
    ENDIF
    users->qual[users->cnt].user_id = us.us_user_id
   FOOT REPORT
    stat = alterlist(users->qual,users->cnt)
   WITH nocounter
  ;end select
  SET rdm_errmsg = fillstring(132," ")
  SET rdm_errcode = error(rdm_errmsg,0)
  IF (rdm_errcode != 0)
   SET errmsg = rdm_errmsg
   GO TO exit_program
  ENDIF
  IF ((users->cnt > 0))
   SELECT INTO "nl:"
    y = seq(at_seq,nextval)
    FROM dual
    DETAIL
     next_seq = y
    WITH nocounter
   ;end select
  ENDIF
  FOR (i = 1 TO users->cnt)
    SET next_seq = (next_seq+ 1)
    INSERT  FROM at_userprivilege pr
     SET pr.up_userprivilege_id = next_seq, pr.up_user_id = users->qual[i].user_id, pr
      .up_privilege_id = admin_priv_id,
      pr.updt_cnt = 0, pr.updt_id = 0.0, pr.updt_applctx = 0,
      pr.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    SET rdm_errmsg = fillstring(132," ")
    SET rdm_errcode = error(rdm_errmsg,0)
    IF (rdm_errcode != 0)
     SET errmsg = rdm_errmsg
     GO TO exit_program
    ELSE
     COMMIT
    ENDIF
    SET next_seq = (next_seq+ 1)
    INSERT  FROM at_userprivilege pr
     SET pr.up_userprivilege_id = next_seq, pr.up_user_id = users->qual[i].user_id, pr
      .up_privilege_id = maintatdomain_priv_id,
      pr.updt_cnt = 0, pr.updt_id = 0.0, pr.updt_applctx = 0,
      pr.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    SET rdm_errmsg = fillstring(132," ")
    SET rdm_errcode = error(rdm_errmsg,0)
    IF (rdm_errcode != 0)
     SET errmsg = rdm_errmsg
     GO TO exit_program
    ELSE
     COMMIT
    ENDIF
  ENDFOR
 ENDIF
 SET readme_data->status = "S"
#exit_program
 FREE RECORD users
 IF ((readme_data->status="F"))
  SET readme_data->message = errmsg
  ROLLBACK
 ELSEIF ((readme_data->status="S"))
  SET readme_data->message = "Successfully updated AutoTester privileges to allow import."
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
