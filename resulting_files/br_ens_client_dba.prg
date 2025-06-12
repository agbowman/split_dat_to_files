CREATE PROGRAM br_ens_client:dba
 SET table_name = fillstring(50," ")
 IF (validate(reply->status_data.status,"F")="F")
  RECORD reply(
    1 item_list[*]
      2 br_client_id = f8
      2 br_client_name = vc
      2 prsnl_list[*]
        3 br_prsnl_id = f8
        3 name_full_formatted = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 RECORD tempstep(
   1 slist[*]
     2 step_mean = vc
     2 step_disp = vc
     2 step_type = vc
     2 sequence = i2
 )
 DECLARE add_client(x=i4) = i2
 DECLARE upd_client(x=i4) = i2
 DECLARE del_client(x=i4) = i2
 DECLARE chk_prsnl_id(x=i4,y=i4) = i2
 DECLARE get_nextid(x=i2) = f8
 DECLARE get_nextcltid(x=i2) = f8
 DECLARE chk_username(x=i4,y=i4) = i2
 DECLARE chk_client_id(x=i4) = i2
 DECLARE chk_pos_cd(x=i4,y=i4) = i2
 DECLARE add_prsnl(x=i4,y=i4) = i2
 DECLARE upd_prsnl(x=i4,y=i4) = i2
 DECLARE del_prsnl(x=i4,y=i4) = i2
 DECLARE add_sol(x=i4,y=i4) = i2
 DECLARE chg_sol(x=i4,y=i4) = i2
 DECLARE del_sol(x=i4,y=i4) = i2
 DECLARE add_config_step(x=i4,y=i4) = i2
 DECLARE del_config_step(x=i4,y=i4) = i2
 DECLARE add_lic(x=i4,y=i4) = i2
 DECLARE del_lic(x=i4,y=i4) = i2
 DECLARE add_supp(x=i4,y=i4) = i2
 DECLARE del_supp(x=i4,y=i4) = i2
 DECLARE add_step(x1=i4,y1=i4,z1=i4) = i2
 DECLARE chg_step(x1=i4,y1=i4,z1=i4) = i2
 DECLARE del_step(x1=i4,y1=i4,z1=i4) = i2
 DECLARE add_user_step(x=i4,y=i4,z=i4) = i2
 DECLARE del_user_step(x=i4,y=i4,z=i4) = i2
 DECLARE chk_opsys(x=i4) = i2
 DECLARE chk_client_name(x=i4) = i2
 DECLARE chk_version_nbr(x=i4) = i2
 DECLARE chk_mnemonic(x=i4) = i2
 DECLARE err_num = i4 WITH public, noconstant(0)
 DECLARE err_msg = c132 WITH public, noconstant(fillstring(132," "))
 DECLARE ens_cnt = i4
 DECLARE ens2_cnt = i4
 DECLARE overall_status = i2
 DECLARE tmp_dcl = vc
 DECLARE len = i4
 DECLARE dcl_stat = i2
 DECLARE sol_cnt = i4
 DECLARE step_cnt = i4
 DECLARE lic_cnt = i4
 DECLARE user_step_cnt = i4
 DECLARE tscnt = i2
 DECLARE new_nbr = f8
 SET reply->status_data.status = "F"
 SET overall_status = 0
 SET ens_cnt = size(request->item_list,5)
 IF (ens_cnt < 1)
  SET overall_status = 1
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->item_list,ens_cnt)
 SET reply->status_data.subeventstatus[1].operationname = "ENS"
 SET reply->status_data.subeventstatus[1].operationstatus = "S"
 SET reply->status_data.subeventstatus[1].targetobjectname = "BR_ENS_CLIENT"
 FOR (i = 1 TO ens_cnt)
   SET ens2_cnt = size(request->item_list[i].prsnl_list,5)
   SET sol_cnt = size(request->item_list[i].sol_list,5)
   SET step_cnt = size(request->item_list[i].sc_list,5)
   SET lic_cnt = size(request->item_list[i].lic_list,5)
   SET supcnt = size(request->item_list[i].suplist,5)
   IF ((request->item_list[i].action_flag=1))
    SET sub_stat = add_client(i)
    IF (sub_stat=0)
     SET overall_status = 0
     GO TO exit_script
    ENDIF
   ELSE
    SET reply->item_list[i].br_client_id = request->item_list[i].br_client_id
    SET reply->item_list[i].br_client_name = request->item_list[i].br_client_name
   ENDIF
   IF ((request->item_list[i].action_flag=2))
    SET sub_stat = upd_client(i)
    IF (sub_stat=0)
     SET overall_status = 0
     GO TO exit_script
    ENDIF
   ENDIF
   IF ((request->item_list[i].action_flag=3))
    SET sub_stat = del_client(i)
    IF (sub_stat=0)
     SET overall_status = 0
     GO TO exit_script
    ENDIF
   ENDIF
   IF (ens2_cnt > 0)
    SET stat = alterlist(reply->item_list[i].prsnl_list,ens2_cnt)
    FOR (j = 1 TO ens2_cnt)
      IF ((request->item_list[i].prsnl_list[j].action_flag=1))
       SET sub_stat = add_prsnl(i,j)
       IF (sub_stat=0)
        SET overall_status = 0
        GO TO exit_script
       ENDIF
      ELSE
       SET reply->item_list[i].prsnl_list[j].br_prsnl_id = request->item_list[i].prsnl_list[j].
       br_prsnl_id
       SET reply->item_list[i].prsnl_list[j].name_full_formatted = request->item_list[i].prsnl_list[j
       ].name_full_formatted
      ENDIF
      IF ((request->item_list[i].prsnl_list[j].action_flag=2))
       SET sub_stat = upd_prsnl(i,j)
       IF (sub_stat=0)
        SET overall_status = 0
        GO TO exit_script
       ENDIF
      ENDIF
      IF ((request->item_list[i].prsnl_list[j].action_flag=3))
       SET sub_stat = del_prsnl(i,j)
       IF (sub_stat=0)
        SET overall_status = 0
        GO TO exit_script
       ENDIF
      ENDIF
      SET user_step_cnt = size(request->item_list[i].prsnl_list[j].userlist,5)
      FOR (z = 1 TO user_step_cnt)
        IF ((request->item_list[i].prsnl_list[j].userlist[z].action_flag=1))
         SET sub_stat = add_user_step(i,j,z)
         IF (sub_stat=0)
          SET overall_status = 0
          GO TO exit_script
         ENDIF
        ENDIF
        IF ((request->item_list[i].prsnl_list[j].userlist[z].action_flag=2))
         SET sub_stat = chg_user_step(i,j,z)
         IF (sub_stat=0)
          SET overall_status = 0
          GO TO exit_script
         ENDIF
        ENDIF
        IF ((request->item_list[i].prsnl_list[j].userlist[z].action_flag=3))
         SET sub_stat = del_user_step(i,j,z)
         IF (sub_stat=0)
          SET overall_status = 0
          GO TO exit_script
         ENDIF
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   IF (sol_cnt > 0)
    FOR (j = 1 TO sol_cnt)
      IF ((request->item_list[i].sol_list[j].action_flag=1))
       SET sub_stat = add_sol(i,j)
       IF (sub_stat=0)
        SET overall_status = 0
        GO TO exit_script
       ENDIF
      ELSEIF ((request->item_list[i].sol_list[j].action_flag=3))
       SET sub_stat = del_sol(i,j)
       IF (sub_stat=0)
        SET overall_status = 0
        GO TO exit_script
       ENDIF
      ELSE
       IF ((request->item_list[i].sol_list[j].action_flag=2))
        SET sub_stat = chg_sol(i,j)
        IF (sub_stat=0)
         SET overall_status = 0
         GO TO exit_script
        ENDIF
       ENDIF
       SET solscnt = size(request->item_list[i].sol_list[j].solslist,5)
       FOR (t = 1 TO solscnt)
         IF ((request->item_list[i].sol_list[j].solslist[t].action_flag=1))
          SET sub_stat = add_step(i,j,t)
          IF (sub_stat=0)
           SET overall_status = 0
           GO TO exit_script
          ENDIF
         ELSEIF ((request->item_list[i].sol_list[j].solslist[t].action_flag=2))
          SET sub_stat = chg_step(i,j,t)
          IF (sub_stat=0)
           SET overall_status = 0
           GO TO exit_script
          ENDIF
         ELSEIF ((request->item_list[i].sol_list[j].solslist[t].action_flag=3))
          SET sub_stat = del_step(i,j,t)
          IF (sub_stat=0)
           SET overall_status = 0
           GO TO exit_script
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
   IF (step_cnt > 0)
    FOR (j = 1 TO step_cnt)
     IF ((request->item_list[i].sc_list[j].action_flag=1))
      SET sub_stat = add_config_step(i,j)
      IF (sub_stat=0)
       SET overall_status = 0
       GO TO exit_script
      ENDIF
     ENDIF
     IF ((request->item_list[i].sc_list[j].action_flag=3))
      SET sub_stat = del_config_step(i,j)
      IF (sub_stat=0)
       SET overall_status = 0
       GO TO exit_script
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
   IF (lic_cnt > 0)
    FOR (j = 1 TO lic_cnt)
     IF ((request->item_list[i].lic_list[j].action_flag=1))
      SET sub_stat = add_lic(i,j)
      IF (sub_stat=0)
       SET overall_status = 0
       GO TO exit_script
      ENDIF
     ENDIF
     IF ((request->item_list[i].lic_list[j].action_flag=3))
      SET sub_stat = del_lic(i,j)
      IF (sub_stat=0)
       SET overall_status = 0
       GO TO exit_script
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
   IF (supcnt > 0)
    FOR (j = 1 TO supcnt)
     IF ((request->item_list[i].suplist[j].action_flag=1))
      SET sub_stat = add_supp(i,j)
      IF (sub_stat=0)
       SET overall_status = 0
       GO TO exit_script
      ENDIF
     ENDIF
     IF ((request->item_list[i].suplist[j].action_flag=3))
      SET sub_stat = del_supp(i,j)
      IF (sub_stat=0)
       SET overall_status = 0
       GO TO exit_script
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 SET overall_status = 1
 GO TO exit_script
 SUBROUTINE add_client(x)
   SET new_nbr = 0.0
   IF ((request->item_list[x].br_client_id > 0))
    SELECT INTO "nl:"
     FROM br_client b
     PLAN (b
      WHERE (b.br_client_id=request->item_list[x].br_client_id))
     WITH nocounter, skipbedrock = 1
    ;end select
    IF (curqual=0)
     SET new_nbr = request->item_list[x].br_client_id
    ENDIF
   ELSE
    SET new_nbr = get_nextcltid(1)
   ENDIF
   CALL echo(build("adding client, nbr=",new_nbr))
   IF (new_nbr < 1)
    RETURN(0)
   ENDIF
   IF (chk_client_name(x)=0)
    RETURN(0)
   ENDIF
   IF (chk_mnemonic(x)=0)
    RETURN(0)
   ENDIF
   INSERT  FROM br_client b
    SET b.br_client_id = new_nbr, b.br_client_name = request->item_list[x].br_client_name, b
     .start_version_nbr = request->item_list[x].start_version_number,
     b.operating_system = cnvtupper(request->item_list[x].operating_system), b.client_mnemonic =
     request->item_list[x].client_mnemonic, b.active_ind = 1,
     b.site_ready_ind = request->item_list[x].site_ready_ind, b.data_move_ready_ind = request->
     item_list[x].data_move_ready_ind, b.autobuild_client_id = request->item_list[x].
     autobuild_client_id,
     b.franchise_flag = request->item_list[x].franchise_flag, b.franchise_client_id = request->
     item_list[x].franchise_client_id, b.region = request->item_list[x].region,
     b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
     b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->updt_task
    WITH nocounter, skipbedrock = 1
   ;end insert
   INSERT  FROM br_name_value bnv
    SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = "SYSTEMPARAM", bnv.br_name
      = "UNKNOWNAGEIND",
     bnv.br_value =
     IF ((request->item_list[x].unknown_age_ind=1)) "1"
     ELSE "0"
     ENDIF
     , bnv.updt_cnt = 0, bnv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     bnv.updt_id = reqinfo->updt_id, bnv.updt_applctx = reqinfo->updt_applctx, bnv.updt_task =
     reqinfo->updt_task,
     bnv.br_client_id = new_nbr
    WITH nocounter, skipbedrock = 1
   ;end insert
   INSERT  FROM br_name_value bnv
    SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = "SYSTEMPARAM", bnv.br_name
      = "UNKNOWNAGESEX",
     bnv.br_value =
     IF ((request->item_list[x].unknown_sex_ind=1)) "1"
     ELSE "0"
     ENDIF
     , bnv.updt_cnt = 0, bnv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     bnv.updt_id = reqinfo->updt_id, bnv.updt_applctx = reqinfo->updt_applctx, bnv.updt_task =
     reqinfo->updt_task,
     bnv.br_client_id = new_nbr
    WITH nocounter, skipbedrock = 1
   ;end insert
   SET err_num = error(err_msg,0)
   IF (err_num > 0)
    RETURN(0)
   ENDIF
   SET reply->item_list[x].br_client_id = new_nbr
   SET request->item_list[x].br_client_id = new_nbr
   SET reply->item_list[x].br_client_name = request->item_list[x].br_client_name
   IF (cnvtupper(request->item_list[x].operating_system)=cnvtupper(cursys)
    AND cursys="AIX")
    SET tmp_dcl = concat("mkdir $CCLUSERDIR/rdds_to_process/",cnvtstring(new_nbr))
    SET len = size(tmp_dcl)
    CALL dcl(tmp_dcl,len,dcl_stat)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE upd_client(x)
   SET reply->item_list[x].br_client_id = request->item_list[x].br_client_id
   SET reply->item_list[x].br_client_name = request->item_list[x].br_client_name
   IF (chk_client_id(x)=0)
    RETURN(0)
   ENDIF
   IF (chk_opsys(x)=0)
    RETURN(0)
   ENDIF
   IF (chk_client_name(x)=0)
    RETURN(0)
   ENDIF
   IF (chk_version_nbr(x)=0)
    RETURN(0)
   ENDIF
   IF (chk_mnemonic(x)=0)
    RETURN(0)
   ENDIF
   UPDATE  FROM br_client b
    SET b.br_client_name = request->item_list[x].br_client_name, b.start_version_nbr = request->
     item_list[x].start_version_number, b.operating_system = cnvtupper(request->item_list[x].
      operating_system),
     b.client_mnemonic = request->item_list[x].client_mnemonic, b.site_ready_ind = request->
     item_list[x].site_ready_ind, b.data_move_ready_ind = request->item_list[x].data_move_ready_ind,
     b.autobuild_client_id = request->item_list[x].autobuild_client_id, b.franchise_flag = request->
     item_list[x].franchise_flag, b.franchise_client_id = request->item_list[x].franchise_client_id,
     b.region = request->item_list[x].region, b.active_ind = request->item_list[x].active_ind, b
     .updt_cnt = 0,
     b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_applctx =
     reqinfo->updt_applctx,
     b.updt_task = reqinfo->updt_task
    WHERE (b.br_client_id=request->item_list[x].br_client_id)
    WITH nocounter, skipbedrock = 1
   ;end update
   UPDATE  FROM br_name_value bnv
    SET bnv.br_value =
     IF ((request->item_list[x].unknown_age_ind=1)) "1"
     ELSE "0"
     ENDIF
     , bnv.updt_cnt = 0, bnv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     bnv.updt_id = reqinfo->updt_id, bnv.updt_applctx = reqinfo->updt_applctx, bnv.updt_task =
     reqinfo->updt_task
    WHERE bnv.br_nv_key1="SYSTEMPARAM"
     AND bnv.br_name="UNKNOWNAGEIND"
     AND (bnv.br_client_id=request->item_list[x].br_client_id)
    WITH nocounter, skipbedrock = 1
   ;end update
   IF (curqual=0)
    INSERT  FROM br_name_value bnv
     SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = "SYSTEMPARAM", bnv.br_name
       = "UNKNOWNAGEIND",
      bnv.br_value =
      IF ((request->item_list[x].unknown_age_ind=1)) "1"
      ELSE "0"
      ENDIF
      , bnv.updt_cnt = 0, bnv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      bnv.updt_id = reqinfo->updt_id, bnv.updt_applctx = reqinfo->updt_applctx, bnv.updt_task =
      reqinfo->updt_task,
      bnv.br_client_id = request->item_list[x].br_client_id
     WITH nocounter, skipbedrock = 1
    ;end insert
   ENDIF
   UPDATE  FROM br_name_value bnv
    SET bnv.br_value =
     IF ((request->item_list[x].unknown_sex_ind=1)) "1"
     ELSE "0"
     ENDIF
     , bnv.updt_cnt = 0, bnv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     bnv.updt_id = reqinfo->updt_id, bnv.updt_applctx = reqinfo->updt_applctx, bnv.updt_task =
     reqinfo->updt_task
    WHERE bnv.br_nv_key1="SYSTEMPARAM"
     AND bnv.br_name="UNKNOWNSEXIND"
     AND (bnv.br_client_id=request->item_list[x].br_client_id)
    WITH nocounter, skipbedrock = 1
   ;end update
   IF (curqual=0)
    INSERT  FROM br_name_value bnv
     SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = "SYSTEMPARAM", bnv.br_name
       = "UNKNOWNSEXIND",
      bnv.br_value =
      IF ((request->item_list[x].unknown_sex_ind=1)) "1"
      ELSE "0"
      ENDIF
      , bnv.updt_cnt = 0, bnv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      bnv.updt_id = reqinfo->updt_id, bnv.updt_applctx = reqinfo->updt_applctx, bnv.updt_task =
      reqinfo->updt_task,
      bnv.br_client_id = request->item_list[x].br_client_id
     WITH nocounter, skipbedrock = 1
    ;end insert
   ENDIF
   SET err_num = error(err_msg,0)
   IF (err_num > 0)
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE del_client(x)
   IF (chk_client_id(x)=0)
    RETURN(0)
   ENDIF
   SET reply->item_list[x].br_client_id = request->item_list[x].br_client_id
   SET reply->item_list[x].br_client_name = request->item_list[x].br_client_name
   UPDATE  FROM br_client b
    SET b.active_ind = 0, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     b.updt_id = reqinfo->updt_id, b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->
     updt_task
    WHERE (b.br_client_id=request->item_list[x].br_client_id)
    WITH nocounter, skipbedrock = 1
   ;end update
   DELETE  FROM br_client_prsnl_reltn bcpr
    WHERE (bcpr.br_client_id=request->item_list[x].br_client_id)
    WITH nocounter, skipbedrock = 1
   ;end delete
   SET err_num = error(err_msg,0)
   IF (err_num > 0)
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE chk_prsnl_id(x,y)
   SELECT INTO "nl:"
    FROM br_prsnl b
    PLAN (b
     WHERE (b.br_prsnl_id=request->item_list[x].prsnl_list[y].br_prsnl_id))
    WITH check, skipbedrock = 1
   ;end select
   IF (curqual=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE get_nextsolid(x)
   SET new_nbr = 0
   SELECT INTO "nl:"
    FROM br_client_item_reltn bcir
    ORDER BY bcir.br_client_item_reltn_id
    DETAIL
     new_nbr = bcir.br_client_item_reltn_id
    WITH nocounter, skipbedrock = 1
   ;end select
   SET new_nbr = (new_nbr+ 1)
   CALL echo(build("NEW BCIR SEQ: ",new_nbr))
   RETURN(new_nbr)
 END ;Subroutine
 SUBROUTINE get_nextuserstepid(x)
   SET new_nbr = 0
   SELECT INTO "nl:"
    FROM br_prsnl_item_reltn bpir
    ORDER BY bpir.br_prsnl_item_reltn_id
    DETAIL
     new_nbr = bpir.br_prsnl_item_reltn_id
    WITH nocounter, skipbedrock = 1
   ;end select
   SET new_nbr = (new_nbr+ 1)
   RETURN(new_nbr)
 END ;Subroutine
 SUBROUTINE get_nextid(x)
   SET new_nbr = 0
   SELECT INTO "nl:"
    FROM br_prsnl bp
    ORDER BY bp.br_prsnl_id
    DETAIL
     new_nbr = bp.br_prsnl_id
    WITH nocounter, skipbedrock = 1
   ;end select
   SET new_nbr = (new_nbr+ 1)
   RETURN(new_nbr)
 END ;Subroutine
 SUBROUTINE get_nextcltid(x)
   SET new_nbr = 0
   SELECT INTO "nl:"
    FROM br_client bc
    PLAN (bc
     WHERE bc.br_client_id != 15238)
    ORDER BY bc.br_client_id
    DETAIL
     new_nbr = bc.br_client_id
    WITH nocounter, skipbedrock = 1
   ;end select
   SET new_nbr = (new_nbr+ 1)
   IF (new_nbr=15238)
    SET new_nbr = (new_nbr+ 1)
   ENDIF
   RETURN(new_nbr)
 END ;Subroutine
 SUBROUTINE chk_sol(x,y)
  IF ((((request->item_list[x].sol_list[y].sol_mean <= " ")) OR ((request->item_list[x].sol_list[y].
  sol_display <= " "))) )
   RETURN(0)
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE chk_user_step(x,y,z)
  IF ((((request->item_list[x].prsnl_list[y].userlist[z].item_mean <= " ")) OR ((((request->
  item_list[x].prsnl_list[y].userlist[z].item_type <= " ")) OR ((request->item_list[x].prsnl_list[y].
  userlist[z].item_display <= " "))) )) )
   RETURN(0)
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE chk_username(x,y)
  IF ((request->item_list[x].prsnl_list[y].username <= " "))
   RETURN(0)
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE chk_client_id(x)
   SELECT INTO "nl:"
    FROM br_client b
    PLAN (b
     WHERE (b.br_client_id=request->item_list[x].br_client_id))
    WITH check, skipbedrock = 1
   ;end select
   IF (curqual=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE chk_pos_cd(x,y)
  IF ((request->item_list[x].prsnl_list[y].position_cd > 0))
   SELECT INTO "nl:"
    FROM code_value c
    WHERE c.code_set=88
     AND (c.code_value=request->item_list[x].prsnl_list[y].position_cd)
    WITH counter
   ;end select
   IF (curqual=0)
    RETURN(0)
   ENDIF
  ELSE
   IF ((request->item_list[x].prsnl_list[y].position_mean > " "))
    SELECT INTO "nl:"
     FROM code_value c
     WHERE c.code_set=88
      AND (c.cdf_meaning=request->item_list[x].prsnl_list[y].position_mean)
      AND c.active_ind=1
     DETAIL
      request->item_list[x].prsnl_list[y].position_cd = c.code_value
     WITH counter
    ;end select
    IF (curqual=0)
     RETURN(0)
    ENDIF
   ELSE
    IF ((request->item_list[x].prsnl_list[y].position_disp > " "))
     SELECT INTO "nl:"
      FROM code_value c
      WHERE c.code_set=88
       AND (c.display=request->item_list[x].prsnl_list[y].position_disp)
       AND c.active_ind=1
      DETAIL
       request->item_list[x].prsnl_list[y].position_cd = c.code_value
      WITH counter
     ;end select
     IF (curqual=0)
      RETURN(0)
     ENDIF
    ELSE
     RETURN(0)
    ENDIF
   ENDIF
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE add_prsnl(x,y)
   SET new_nbr = 0.0
   IF (chk_username(x,y)=0)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM br_prsnl bp
    PLAN (bp
     WHERE cnvtupper(bp.username)=cnvtupper(request->item_list[x].prsnl_list[y].username))
    DETAIL
     new_nbr = bp.br_prsnl_id
    WITH nocounter, skipbedrock = 1
   ;end select
   IF (new_nbr=0)
    IF (chk_client_id(x)=0)
     RETURN(0)
    ENDIF
    SET new_nbr = get_nextid(0)
    CALL echo(build("adding user, nbr=",new_nbr))
    IF (new_nbr < 1)
     RETURN(0)
    ENDIF
    INSERT  FROM br_prsnl b
     SET b.br_prsnl_id = new_nbr, b.create_dt_tm = cnvtdatetime(curdate,curtime3), b
      .name_full_formatted = request->item_list[x].prsnl_list[y].name_full_formatted,
      b.email = request->item_list[x].prsnl_list[y].email, b.name_last = request->item_list[x].
      prsnl_list[y].name_last, b.name_first = request->item_list[x].prsnl_list[y].name_first,
      b.username = request->item_list[x].prsnl_list[y].username, b.active_ind = 1, b.updt_cnt = 0,
      b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_applctx =
      reqinfo->updt_applctx,
      b.updt_task = reqinfo->updt_task
     WITH nocounter, skipbedrock = 1
    ;end insert
   ENDIF
   SET err_num = error(err_msg,0)
   IF (err_num > 0)
    RETURN(0)
   ENDIF
   CALL echo("adding new br_client_prsnl_reltn row")
   INSERT  FROM br_client_prsnl_reltn bcpr
    SET bcpr.br_client_id = request->item_list[x].br_client_id, bcpr.br_prsnl_id = new_nbr, bcpr
     .active_ind = 1,
     bcpr.updt_id = reqinfo->updt_id, bcpr.updt_task = reqinfo->updt_task, bcpr.updt_applctx =
     reqinfo->updt_applctx,
     bcpr.updt_cnt = 0, bcpr.updt_dt_tm = cnvtdatetime(curdate,curtime)
    WITH nocounter, skipbedrock = 1
   ;end insert
   SET err_num = error(err_msg,0)
   IF (err_num > 0)
    RETURN(0)
   ENDIF
   SET add_user = uar_sec_user(nullterm(request->item_list[x].prsnl_list[y].username),nullterm(
     request->item_list[x].prsnl_list[y].username),request->item_list[x].prsnl_list[y].
    name_full_formatted)
   SET reply->item_list[x].prsnl_list[y].br_prsnl_id = new_nbr
   SET reply->item_list[x].prsnl_list[y].name_full_formatted = request->item_list[x].prsnl_list[y].
   name_full_formatted
   RETURN(1)
 END ;Subroutine
 SUBROUTINE upd_prsnl(x,y)
   SET reply->item_list[x].prsnl_list[y].br_prsnl_id = request->item_list[x].prsnl_list[y].
   br_prsnl_id
   SET reply->item_list[x].prsnl_list[y].name_full_formatted = request->item_list[x].prsnl_list[y].
   name_full_formatted
   IF (chk_prsnl_id(x,y)=0)
    RETURN(0)
   ENDIF
   IF (chk_username(x,y)=0)
    RETURN(0)
   ENDIF
   UPDATE  FROM br_prsnl b
    SET b.name_full_formatted = request->item_list[x].prsnl_list[y].name_full_formatted, b.email =
     request->item_list[x].prsnl_list[y].email, b.name_last = request->item_list[x].prsnl_list[y].
     name_last,
     b.name_first = request->item_list[x].prsnl_list[y].name_first, b.username = request->item_list[x
     ].prsnl_list[y].username, b.active_ind = request->item_list[x].prsnl_list[y].active_ind,
     b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo
     ->updt_id,
     b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->updt_task
    PLAN (b
     WHERE (b.br_prsnl_id=request->item_list[x].prsnl_list[y].br_prsnl_id))
    WITH nocounter, skipbedrock = 1
   ;end update
   SET err_num = error(err_msg,0)
   IF (err_num > 0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE del_prsnl(x,y)
   IF (chk_prsnl_id(x,y)=0)
    RETURN(0)
   ENDIF
   SET reply->item_list[x].prsnl_list[y].br_prsnl_id = request->item_list[x].prsnl_list[y].
   br_prsnl_id
   SET reply->item_list[x].prsnl_list[y].name_full_formatted = request->item_list[x].prsnl_list[y].
   name_full_formatted
   DELETE  FROM br_client_prsnl_reltn bcpr
    PLAN (bcpr
     WHERE (bcpr.br_prsnl_id=request->item_list[x].prsnl_list[y].br_prsnl_id)
      AND (bcpr.br_client_id=request->item_list[x].br_client_id))
    WITH nocounter, skipbedrock = 1
   ;end delete
   DELETE  FROM br_prsnl_item_reltn bpir
    PLAN (bpir
     WHERE (bpir.br_prsnl_id=request->item_list[x].prsnl_list[y].br_prsnl_id)
      AND (bpir.br_client_id=request->item_list[x].br_client_id))
    WITH nocounter, skipbedrock = 1
   ;end delete
   SET err_num = error(err_msg,0)
   IF (err_num > 0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE add_sol(x,y)
   SET new_nbr = 0.0
   IF (chk_sol(x,y)=0)
    RETURN(0)
   ENDIF
   IF (chk_client_id(x)=0)
    RETURN(0)
   ENDIF
   SET new_nbr = get_nextsolid(0)
   CALL echo(build("adding client/item row, nbr=",new_nbr))
   INSERT  FROM br_client_item_reltn b
    SET b.br_client_item_reltn_id = new_nbr, b.br_client_id = request->item_list[x].br_client_id, b
     .item_type = "SOLUTION",
     b.item_mean = request->item_list[x].sol_list[y].sol_mean, b.item_display = request->item_list[x]
     .sol_list[y].sol_display, b.solution_seq = request->item_list[x].sol_list[y].sol_seq,
     b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
     b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->updt_task
    WITH nocounter, skipbedrock = 1
   ;end insert
   SET err_num = error(err_msg,0)
   IF (err_num > 0)
    RETURN(0)
   ENDIF
   SET tscnt = size(request->item_list[x].sol_list[y].solslist,5)
   FOR (t = 1 TO tscnt)
    SET stat = add_step(x,y,t)
    IF (err_num > 0)
     RETURN(0)
    ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE chg_sol(x,y)
  UPDATE  FROM br_client_item_reltn bcir
   SET bcir.solution_seq = request->item_list[x].sol_list[y].sol_seq, bcir.item_display = request->
    item_list[x].sol_list[y].sol_display
   WHERE (bcir.br_client_id=request->item_list[x].br_client_id)
    AND bcir.item_type="SOLUTION"
    AND (bcir.item_mean=request->item_list[x].sol_list[y].sol_mean)
   WITH nocounter, skipbedrock = 1
  ;end update
  RETURN(1)
 END ;Subroutine
 SUBROUTINE del_sol(x,y)
   DELETE  FROM br_client_item_reltn bcir
    PLAN (bcir
     WHERE (bcir.br_client_id=request->item_list[x].br_client_id)
      AND bcir.item_type="SOLUTION"
      AND (bcir.item_mean=request->item_list[x].sol_list[y].sol_mean))
    WITH nocounter, skipbedrock = 1
   ;end delete
   SET err_num = error(err_msg,0)
   IF (err_num > 0)
    RETURN(0)
   ENDIF
   DELETE  FROM br_client_sol_step bcss
    PLAN (bcss
     WHERE (bcss.br_client_id=request->item_list[x].br_client_id)
      AND (bcss.solution_mean=request->item_list[x].sol_list[y].sol_mean))
    WITH nocounter, skipbedrock = 1
   ;end delete
   DELETE  FROM br_client_item_reltn bcir
    PLAN (bcir
     WHERE (bcir.br_client_id=request->item_list[x].br_client_id)
      AND bcir.item_type="STEP"
      AND  NOT (bcir.item_mean IN (
     (SELECT DISTINCT
      bcss.step_mean
      FROM br_client_sol_step bcss
      WHERE (bcss.br_client_id=request->item_list[x].br_client_id)
      WITH nocounter, skipbedrock = 1))))
    WITH nocounter, skipbedrock = 1
   ;end delete
   SET err_num = error(err_msg,0)
   IF (err_num > 0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE add_step(x1,y1,z1)
   INSERT  FROM br_client_sol_step bcss
    SET bcss.br_client_id = request->item_list[x1].br_client_id, bcss.solution_mean = request->
     item_list[x1].sol_list[y1].sol_mean, bcss.step_mean = request->item_list[x1].sol_list[y1].
     solslist[z1].step_mean,
     bcss.sequence =
     IF ((request->item_list[x1].sol_list[y1].solslist[z1].sequence > 0)) request->item_list[x1].
      sol_list[y1].solslist[z1].sequence
     ELSE (z1 * 100)
     ENDIF
     , bcss.updt_cnt = 0, bcss.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     bcss.updt_id = reqinfo->updt_id, bcss.updt_applctx = reqinfo->updt_applctx, bcss.updt_task =
     reqinfo->updt_task
    WITH nocounter, skipbedrock = 1
   ;end insert
   SELECT INTO "nl:"
    FROM br_client_item_reltn bcir
    PLAN (bcir
     WHERE (bcir.br_client_id=request->item_list[x1].br_client_id)
      AND bcir.item_type="STEP"
      AND (bcir.item_mean=request->item_list[x1].sol_list[y1].solslist[z1].step_mean))
    WITH nocounter, skipbedrock = 1
   ;end select
   IF (curqual=0)
    SET new_nbr = get_nextsolid(0)
    CALL echo(build("adding client/item row, nbr=",new_nbr))
    INSERT  FROM br_client_item_reltn b
     SET b.br_client_item_reltn_id = new_nbr, b.br_client_id = request->item_list[x1].br_client_id, b
      .item_type = "STEP",
      b.item_mean = request->item_list[x1].sol_list[y1].solslist[z1].step_mean, b.item_display =
      request->item_list[x1].sol_list[y1].solslist[z1].step_disp, b.step_cat_mean = request->
      item_list[x1].sol_list[y1].solslist[z1].step_cat_mean,
      b.step_cat_disp = request->item_list[x1].sol_list[y1].solslist[z1].step_cat_disp, b.status_flag
       = 0, b.status_id = reqinfo->updt_id,
      b.status_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      b.updt_id = reqinfo->updt_id, b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->
      updt_task
     WITH nocounter, skipbedrock = 1
    ;end insert
    SET err_num = error(err_msg,0)
    IF (err_num > 0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE chg_step(x1,y1,z1)
   UPDATE  FROM br_client_sol_step bcss
    SET bcss.sequence = request->item_list[x1].sol_list[y1].solslist[z1].sequence
    WHERE (bcss.br_client_id=request->item_list[x1].br_client_id)
     AND (bcss.solution_mean=request->item_list[x1].sol_list[y1].sol_mean)
     AND (bcss.step_mean=request->item_list[x1].sol_list[y1].solslist[z1].step_mean)
    WITH nocounter, skipbedrock = 1
   ;end update
   UPDATE  FROM br_client_item_reltn bcir
    SET bcir.item_display = request->item_list[x1].sol_list[y1].solslist[z1].step_disp
    WHERE (bcir.br_client_id=request->item_list[x1].br_client_id)
     AND bcir.item_type="STEP"
     AND (bcir.item_mean=request->item_list[x1].sol_list[y1].solslist[z1].step_mean)
    WITH nocounter, skipbedrock = 1
   ;end update
   RETURN(1)
 END ;Subroutine
 SUBROUTINE del_step(x1,y1,z1)
   DELETE  FROM br_client_sol_step bcss
    WHERE (bcss.br_client_id=request->item_list[x1].br_client_id)
     AND (bcss.solution_mean=request->item_list[x1].sol_list[y1].sol_mean)
     AND (bcss.step_mean=request->item_list[x1].sol_list[y1].solslist[z1].step_mean)
    WITH nocounter, skipbedrock = 1
   ;end delete
   SELECT INTO "nl:"
    FROM br_client_sol_step bcss
    PLAN (bcss
     WHERE (bcss.br_client_id=request->item_list[x1].br_client_id)
      AND (bcss.step_mean=request->item_list[x1].sol_list[y1].solslist[z1].step_mean))
    WITH nocounter, skipbedrock = 1
   ;end select
   IF (curqual=0)
    DELETE  FROM br_client_item_reltn bcir
     WHERE (bcir.br_client_id=request->item_list[x1].br_client_id)
      AND bcir.item_type="STEP"
      AND (bcir.item_mean=request->item_list[x1].sol_list[y1].solslist[z1].step_mean)
     WITH nocounter, skipbedrock = 1
    ;end delete
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE add_user_step(x,y,z)
   SET new_nbr = 0.0
   IF (chk_user_step(x,y,z)=0)
    RETURN(0)
   ENDIF
   SET new_nbr = get_nextuserstepid(0)
   INSERT  FROM br_prsnl_item_reltn b
    SET b.br_prsnl_item_reltn_id = new_nbr, b.br_prsnl_id = reply->item_list[x].prsnl_list[y].
     br_prsnl_id, b.item_type = request->item_list[x].prsnl_list[y].userlist[z].item_type,
     b.item_mean = request->item_list[x].prsnl_list[y].userlist[z].item_mean, b.item_display =
     request->item_list[x].prsnl_list[y].userlist[z].item_display, b.item_lead_ind = request->
     item_list[x].prsnl_list[y].userlist[z].item_lead_ind,
     b.br_client_id = request->item_list[x].br_client_id, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime
     (curdate,curtime3),
     b.updt_id = reqinfo->updt_id, b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->
     updt_task
    WITH nocounter, skipbedrock = 1
   ;end insert
   SET err_num = error(err_msg,0)
   IF (err_num > 0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE chg_user_step(x,y,z)
   UPDATE  FROM br_prsnl_item_reltn bpir
    SET bpir.item_lead_ind = request->item_list[x].prsnl_list[y].userlist[z].item_lead_ind
    WHERE (bpir.br_prsnl_id=reply->item_list[x].prsnl_list[y].br_prsnl_id)
     AND (bpir.item_type=request->item_list[x].prsnl_list[y].userlist[z].item_type)
     AND (bpir.item_mean=request->item_list[x].prsnl_list[y].userlist[z].item_mean)
     AND (bpir.br_client_id=request->item_list[x].br_client_id)
    WITH nocounter, skipbedrock = 1
   ;end update
   SET err_num = error(err_msg,0)
   IF (err_num > 0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE del_user_step(x,y,z)
   DELETE  FROM br_prsnl_item_reltn bpir
    PLAN (bpir
     WHERE (bpir.br_prsnl_id=reply->item_list[x].prsnl_list[y].br_prsnl_id)
      AND (bpir.item_type=request->item_list[x].prsnl_list[y].userlist[z].item_type)
      AND (bpir.item_mean=request->item_list[x].prsnl_list[y].userlist[z].item_mean)
      AND (bpir.br_client_id=request->item_list[x].br_client_id))
    WITH nocounter, skipbedrock = 1
   ;end delete
   SET err_num = error(err_msg,0)
   IF (err_num > 0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE add_config_step(x,y)
  IF ((request->item_list[x].sc_list[y].step_cat_mean > " "))
   UPDATE  FROM br_name_value bnv
    SET bnv.default_selected_ind = 1, bnv.updt_cnt = (bnv.updt_cnt+ 1), bnv.updt_dt_tm = cnvtdatetime
     (curdate,curtime),
     bnv.updt_id = reqinfo->updt_id, bnv.updt_task = reqinfo->updt_task, bnv.updt_applctx = reqinfo->
     updt_applctx
    WHERE bnv.br_nv_key1="STEP_CAT_MEAN"
     AND (bnv.br_name=request->item_list[x].sc_list[y].step_cat_mean)
     AND (bnv.br_client_id=request->item_list[x].br_client_id)
    WITH nocounter, skipbedrock = 1
   ;end update
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE del_config_step(x,y)
  IF ((request->item_list[x].sc_list[y].step_cat_mean > " "))
   UPDATE  FROM br_name_value bnv
    SET bnv.default_selected_ind = 0, bnv.updt_cnt = (bnv.updt_cnt+ 1), bnv.updt_dt_tm = cnvtdatetime
     (curdate,curtime),
     bnv.updt_id = reqinfo->updt_id, bnv.updt_task = reqinfo->updt_task, bnv.updt_applctx = reqinfo->
     updt_applctx
    WHERE (bnv.br_client_id=request->item_list[x].br_client_id)
     AND bnv.br_nv_key1="STEP_CAT_MEAN"
     AND (bnv.br_name=request->item_list[x].sc_list[y].step_cat_mean)
    WITH nocounter, skipbedrock = 1
   ;end update
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE add_lic(x,y)
  IF ((request->item_list[x].lic_list[y].lic_mean > " "))
   UPDATE  FROM br_name_value bnv
    SET bnv.default_selected_ind = 1, bnv.updt_cnt = (bnv.updt_cnt+ 1), bnv.updt_dt_tm = cnvtdatetime
     (curdate,curtime),
     bnv.updt_id = reqinfo->updt_id, bnv.updt_task = reqinfo->updt_task, bnv.updt_applctx = reqinfo->
     updt_applctx
    WHERE bnv.br_nv_key1="LICENSE"
     AND (bnv.br_name=request->item_list[x].lic_list[y].lic_mean)
     AND (bnv.br_client_id=request->item_list[x].br_client_id)
    WITH nocounter, skipbedrock = 1
   ;end update
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE del_lic(x,y)
  IF ((request->item_list[x].lic_list[y].lic_mean > " "))
   UPDATE  FROM br_name_value bnv
    SET bnv.default_selected_ind = 0, bnv.updt_cnt = (bnv.updt_cnt+ 1), bnv.updt_dt_tm = cnvtdatetime
     (curdate,curtime),
     bnv.updt_id = reqinfo->updt_id, bnv.updt_task = reqinfo->updt_task, bnv.updt_applctx = reqinfo->
     updt_applctx
    WHERE (bnv.br_client_id=request->item_list[x].br_client_id)
     AND bnv.br_nv_key1="LICENSE"
     AND (bnv.br_name=request->item_list[x].lic_list[y].lic_mean)
    WITH nocounter, skipbedrock = 1
   ;end update
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE add_supp(x,y)
  IF ((request->item_list[x].suplist[y].supplier_flag > 0))
   UPDATE  FROM br_rli_supplier b
    SET b.default_selected_ind = 1
    WHERE (b.supplier_flag=request->item_list[x].suplist[y].supplier_flag)
     AND (b.br_client_id=request->item_list[x].br_client_id)
    WITH nocounter, skipbedrock = 1
   ;end update
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE del_supp(x,y)
  IF ((request->item_list[x].suplist[y].supplier_flag > 0))
   UPDATE  FROM br_rli_supplier brs
    SET brs.default_selected_ind = 0
    WHERE (brs.br_client_id=request->item_list[x].br_client_id)
     AND (brs.supplier_flag=request->item_list[x].suplist[y].supplier_flag)
    WITH nocounter, skipbedrock = 1
   ;end update
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE chk_opsys(x)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE chk_client_name(x)
  IF ((request->item_list[x].br_client_name <= " "))
   RETURN(0)
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE chk_version_nbr(x)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE chk_mnemonic(x)
  IF ((request->item_list[x].client_mnemonic <= " "))
   RETURN(0)
  ENDIF
  RETURN(1)
 END ;Subroutine
#exit_script
 IF (overall_status=1)
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
