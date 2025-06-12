CREATE PROGRAM dm_create_com_files:dba
 SET env_id =  $1
 SET before_after_flag =  $2
 SET mode =  $3
 SET feature_rev_flag =  $4
 SET com_file_flag =  $5
 RECORD rprocess(
   1 proc[*]
     2 process_id = f8
     2 run_after_process_id = f8
     2 from_rev = f8
     2 effective_feature = f8
     2 process_type = f8
     2 program_name = vc
     2 script_name = vc
     2 data_file_name = vc
     2 error_routine_name = vc
     2 blocks_to_process = i4
     2 com_file_name = vc
     2 success_ind = i2
     2 owner_email = vc
     2 description = vc
     2 pre_schema_downtime_ind = i2
     2 post_schema_downtime_ind = i2
     2 precedence_level = vc
     2 group_nbr = i4
     2 file_prefix = vc
     2 prefix2 = vc
     2 pref2_pos = i4
     2 is_a_run_after = i2
     2 in_ord_proc = i2
     2 com_file_name2 = vc
     2 instance_nbr = i4
   1 ord_proc[*]
     2 process_id = f8
     2 com_file_name = vc
   1 pref[*]
     2 prefix2 = vc
     2 tmp_grp_nbr = i2
   1 file[*]
     2 com_file_name = vc
     2 cnt = i2
   1 temp[*]
     2 process_id = f8
     2 file_prefix = vc
     2 precedence_level = vc
     2 group_nbr = i4
     2 com_file_name = vc
     2 run_after_process_id = f8
 )
 SET proc_cnt = 0
 SET file_cnt = 0
 SET pref_cnt = 0
 RECORD rproclist(
   1 qual[*]
     2 process_id = f8
     2 max_instance = i4
 )
 SET plist_cnt = 0
 SET target_op_sys = fillstring(3," ")
 SET env_from_rev = 0.0
 SET env_to_rev = 0.0
 SET install_ind = 0
 SET v5_connect = fillstring(60," ")
 SET v5ref_connect = fillstring(60," ")
 SET db_name = fillstring(6," ")
 SET env_name = fillstring(20," ")
 SET estring = fillstring(20," ")
 SELECT INTO "nl:"
  e.schema_version
  FROM dm_environment e
  WHERE e.environment_id=env_id
  DETAIL
   target_op_sys = e.target_operating_system, env_from_rev = e.from_schema_version, env_to_rev = e
   .schema_version,
   v5_connect = e.v500_connect_string, v5ref_connect = e.v500ref_connect_string, db_name = e
   .database_name,
   env_name = cnvtlower(e.environment_name), estring = cnvtlower(e.envset_string)
  WITH nocounter
 ;end select
 SET v5_connect_quotes = build("'",v5_connect,"'")
 IF (env_from_rev=0.0)
  SET install_ind = 1
 ENDIF
 IF (feature_rev_flag=2)
  SELECT INTO "nl:"
   p.process_id
   FROM dm_pkt_setup_process p,
    dm_features df1
   PLAN (p)
    JOIN (df1
    WHERE p.effective_feature=df1.feature_number)
   DETAIL
    run_ind = 0
    IF (df1.schema_version <= env_to_rev
     AND df1.schema_version > 0.0
     AND ((p.from_rev=0.0) OR (p.from_rev=env_from_rev)) )
     run_ind = 1
    ENDIF
    IF (run_ind=1)
     dm_found = 0, dm_z = 1
     WHILE (dm_z <= plist_cnt
      AND dm_found != 1)
       IF ((rproclist->qual[dm_z].process_id=p.process_id))
        dm_found = 1
        IF ((p.instance_nbr > rproclist->qual[dm_z].max_instance))
         rproclist->qual[dm_z].max_instance = p.instance_nbr
        ENDIF
       ELSE
        dm_z = (dm_z+ 1)
       ENDIF
     ENDWHILE
     IF (dm_found=0)
      plist_cnt = (plist_cnt+ 1), stat = alterlist(rproclist->qual,plist_cnt), rproclist->qual[
      plist_cnt].process_id = p.process_id,
      rproclist->qual[plist_cnt].max_instance = p.instance_nbr
     ENDIF
    ENDIF
   WITH nocounter, outerjoin = d
  ;end select
  SET pre_install_ind = 0
  SET pre_refresh_ind = 0
  SET post_install_ind = 0
  SET post_refresh_ind = 0
  IF (before_after_flag=1
   AND install_ind=1)
   SET pre_install_ind = 1
  ELSEIF (before_after_flag=1
   AND install_ind=0)
   SET pre_refresh_ind = 1
  ELSEIF (before_after_flag=2
   AND install_ind=1)
   SET post_install_ind = 1
  ELSEIF (before_after_flag=2
   AND install_ind=0)
   SET post_refresh_ind = 1
  ENDIF
  SELECT
   IF (before_after_flag=1
    AND install_ind=1)
    PLAN (dt)
     JOIN (p
     WHERE p.before_install_ind=1
      AND p.active_ind=1
      AND (p.process_id=rproclist->qual[dt.seq].process_id)
      AND (p.instance_nbr=rproclist->qual[dt.seq].max_instance))
     JOIN (f
     WHERE f.environment_id=env_id
      AND f.function_id=p.function_id)
     JOIN (d)
     JOIN (dsph
     WHERE dsph.environment_id=env_id
      AND dsph.process_id=p.process_id)
   ELSEIF (before_after_flag=1
    AND install_ind=0)
    PLAN (dt)
     JOIN (p
     WHERE p.before_refresh_ind=1
      AND p.active_ind=1
      AND (p.process_id=rproclist->qual[dt.seq].process_id)
      AND (p.instance_nbr=rproclist->qual[dt.seq].max_instance))
     JOIN (f
     WHERE f.environment_id=env_id
      AND f.function_id=p.function_id)
     JOIN (d)
     JOIN (dsph
     WHERE dsph.environment_id=env_id
      AND dsph.process_id=p.process_id)
   ELSEIF (before_after_flag=2
    AND install_ind=1)
    PLAN (dt)
     JOIN (p
     WHERE p.after_install_ind=1
      AND p.active_ind=1
      AND (p.process_id=rproclist->qual[dt.seq].process_id)
      AND (p.instance_nbr=rproclist->qual[dt.seq].max_instance))
     JOIN (f
     WHERE f.environment_id=env_id
      AND f.function_id=p.function_id)
     JOIN (d)
     JOIN (dsph
     WHERE dsph.environment_id=env_id
      AND dsph.process_id=p.process_id)
   ELSEIF (before_after_flag=2
    AND install_ind=0)
    PLAN (dt)
     JOIN (p
     WHERE p.after_refresh_ind=1
      AND p.active_ind=1
      AND (p.process_id=rproclist->qual[dt.seq].process_id)
      AND (p.instance_nbr=rproclist->qual[dt.seq].max_instance))
     JOIN (f
     WHERE f.environment_id=env_id
      AND f.function_id=p.function_id)
     JOIN (d)
     JOIN (dsph
     WHERE dsph.environment_id=env_id
      AND dsph.process_id=p.process_id)
   ELSE
   ENDIF
   INTO "nl:"
   dt.seq
   FROM (dummyt dt  WITH seq = value(plist_cnt)),
    dm_env_functions f,
    dm_pkt_setup_process p,
    (dummyt d  WITH seq = 1),
    dm_pkt_setup_proc_hist dsph
   ORDER BY rproclist->qual[dt.seq].process_id DESC
   DETAIL
    run_ind = 0
    IF (p.run_once_ind=1)
     IF (dsph.success_ind=0)
      run_ind = 1
     ENDIF
    ELSE
     run_ind = 1
    ENDIF
    IF (run_ind=1)
     proc_cnt = (proc_cnt+ 1), stat = alterlist(rprocess->proc,proc_cnt), rprocess->proc[proc_cnt].
     process_id = p.process_id,
     rprocess->proc[proc_cnt].run_after_process_id = p.run_after_process_id, rprocess->proc[proc_cnt]
     .effective_feature = p.effective_feature, rprocess->proc[proc_cnt].process_type = p.process_type,
     rprocess->proc[proc_cnt].program_name = cnvtlower(p.program_name), rprocess->proc[proc_cnt].
     script_name = cnvtlower(p.script_name), rprocess->proc[proc_cnt].data_file_name = cnvtlower(p
      .data_file_name),
     rprocess->proc[proc_cnt].error_routine_name = trim(cnvtlower(p.error_routine_name)), rprocess->
     proc[proc_cnt].owner_email = cnvtlower(p.owner_email), rprocess->proc[proc_cnt].description =
     cnvtlower(p.description)
     IF (p.blocks_to_process > 0)
      rprocess->proc[proc_cnt].blocks_to_process = p.blocks_to_process
     ELSE
      rprocess->proc[proc_cnt].blocks_to_process = 1
     ENDIF
     rprocess->proc[proc_cnt].com_file_name = " ", rprocess->proc[proc_cnt].success_ind = 0, rprocess
     ->proc[proc_cnt].instance_nbr = p.instance_nbr
     IF (com_file_flag=2)
      rprocess->proc[proc_cnt].pre_schema_downtime_ind = p.pre_schema_downtime_ind, rprocess->proc[
      proc_cnt].post_schema_downtime_ind = p.post_schema_downtime_ind, rprocess->proc[proc_cnt].
      precedence_level = cnvtlower(p.precedence_level),
      rprocess->proc[proc_cnt].group_nbr = p.group_nbr
      IF (pre_install_ind=1)
       IF (p.pre_schema_downtime_ind=1)
        rprocess->proc[proc_cnt].file_prefix = "dm_pre_inst_down_"
       ELSEIF (p.pre_schema_downtime_ind=0)
        rprocess->proc[proc_cnt].file_prefix = "dm_pre_inst_up_"
       ENDIF
      ELSEIF (pre_refresh_ind=1)
       IF (p.pre_schema_downtime_ind=1)
        rprocess->proc[proc_cnt].file_prefix = "dm_pre_ref_down_"
       ELSEIF (p.pre_schema_downtime_ind=0)
        rprocess->proc[proc_cnt].file_prefix = "dm_pre_ref_up_"
       ENDIF
      ELSEIF (post_install_ind=1)
       IF (p.post_schema_downtime_ind=1)
        rprocess->proc[proc_cnt].file_prefix = "dm_post_inst_down_"
       ELSEIF (p.post_schema_downtime_ind=0)
        rprocess->proc[proc_cnt].file_prefix = "dm_post_inst_up_"
       ENDIF
      ELSEIF (post_refresh_ind=1)
       IF (p.post_schema_downtime_ind=1)
        rprocess->proc[proc_cnt].file_prefix = "dm_post_ref_down_"
       ELSEIF (p.post_schema_downtime_ind=0)
        rprocess->proc[proc_cnt].file_prefix = "dm_post_ref_up_"
       ENDIF
      ENDIF
      rprocess->proc[proc_cnt].prefix2 = build(rprocess->proc[proc_cnt].file_prefix,rprocess->proc[
       proc_cnt].precedence_level), found = 0, count = 0
      WHILE (found != 1
       AND count <= pref_cnt)
        count = (count+ 1)
        IF (count <= pref_cnt)
         IF ((rprocess->proc[proc_cnt].prefix2=rprocess->pref[count].prefix2))
          found = 1
         ENDIF
        ENDIF
        rprocess->proc[proc_cnt].pref2_pos = count
      ENDWHILE
      IF (found=1)
       IF ((rprocess->proc[proc_cnt].group_nbr > rprocess->pref[count].tmp_grp_nbr))
        rprocess->pref[count].tmp_grp_nbr = rprocess->proc[proc_cnt].group_nbr
       ENDIF
      ELSE
       pref_cnt = (pref_cnt+ 1), stat = alterlist(rprocess->pref,pref_cnt), rprocess->pref[count].
       prefix2 = rprocess->proc[proc_cnt].prefix2
       IF ((rprocess->proc[proc_cnt].group_nbr > 0))
        rprocess->pref[count].tmp_grp_nbr = rprocess->proc[proc_cnt].group_nbr
       ELSE
        rprocess->pref[count].tmp_grp_nbr = 0
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter, outerjoin = d
  ;end select
  SELECT INTO "nl:"
   d.seq
   FROM (dummyt d  WITH seq = value(proc_cnt))
   DETAIL
    IF ((rprocess->proc[d.seq].run_after_process_id > 0))
     count1 = 0, found = 0
     WHILE (found != 1
      AND count1 < proc_cnt)
      count1 = (count1+ 1),
      IF ((rprocess->proc[count1].process_id=rprocess->proc[d.seq].run_after_process_id))
       found = 1
      ENDIF
     ENDWHILE
     IF (found=1)
      rprocess->proc[count1].is_a_run_after = 1
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF (feature_rev_flag=1)
  SELECT INTO "nl:"
   p.process_id
   FROM dm_pkt_setup_process p
   WHERE p.active_ind=1
    AND p.from_rev=0
    AND sqlpassthru(concat("(p.process_id, p.instance_nbr) in ",
     "(select p2.process_id, max(p2.instance_nbr) ","from dm_pkt_setup_process p2 ",
     "group by p2.process_id)"))
   DETAIL
    proc_cnt = (proc_cnt+ 1), stat = alterlist(rprocess->proc,proc_cnt), rprocess->proc[proc_cnt].
    process_id = p.process_id,
    rprocess->proc[proc_cnt].run_after_process_id = p.run_after_process_id, rprocess->proc[proc_cnt].
    effective_feature = p.effective_feature, rprocess->proc[proc_cnt].process_type = p.process_type,
    rprocess->proc[proc_cnt].program_name = cnvtlower(p.program_name), rprocess->proc[proc_cnt].
    script_name = cnvtlower(p.script_name), rprocess->proc[proc_cnt].data_file_name = cnvtlower(p
     .data_file_name),
    rprocess->proc[proc_cnt].error_routine_name = trim(cnvtlower(p.error_routine_name)), rprocess->
    proc[proc_cnt].owner_email = cnvtlower(p.owner_email), rprocess->proc[proc_cnt].description =
    cnvtlower(p.description)
    IF (p.blocks_to_process > 0)
     rprocess->proc[proc_cnt].blocks_to_process = p.blocks_to_process
    ELSE
     rprocess->proc[proc_cnt].blocks_to_process = 1
    ENDIF
    rprocess->proc[proc_cnt].success_ind = 0
   WITH nocounter
  ;end select
 ELSE
  GO TO exit_script
 ENDIF
 IF (proc_cnt > 0)
  IF (com_file_flag=1)
   SET fname = fillstring(30," ")
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(proc_cnt))
    DETAIL
     fname = build("f",cnvtint(rprocess->proc[d.seq].effective_feature),"_p",cnvtint(rprocess->proc[d
       .seq].process_id))
     IF ((rprocess->proc[d.seq].run_after_process_id > 0))
      rprocess->proc[d.seq].com_file_name2 = build(fname,"_a",cnvtint(rprocess->proc[d.seq].
        run_after_process_id))
     ELSE
      rprocess->proc[d.seq].com_file_name2 = fname
     ENDIF
     rprocess->proc[d.seq].com_file_name = cnvtlower(rprocess->proc[d.seq].owner_email), found = 0,
     count1 = 0
     WHILE (found != 1
      AND count1 <= file_cnt)
      count1 = (count1+ 1),
      IF (count1 <= file_cnt)
       IF ((rprocess->file[count1].com_file_name=rprocess->proc[d.seq].com_file_name))
        found = 1
       ENDIF
      ENDIF
     ENDWHILE
     IF (found=0)
      file_cnt = (file_cnt+ 1), stat = alterlist(rprocess->file,file_cnt), rprocess->file[file_cnt].
      com_file_name = rprocess->proc[d.seq].com_file_name
     ENDIF
    WITH nocounter
   ;end select
  ELSE
   IF (mode=1)
    SELECT INTO "nl:"
     d.seq
     FROM (dummyt d  WITH seq = value(pref_cnt))
     DETAIL
      rprocess->pref[d.seq].tmp_grp_nbr = (rprocess->pref[d.seq].tmp_grp_nbr+ 1)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     d.seq
     FROM (dummyt d  WITH seq = value(proc_cnt))
     WHERE (rprocess->proc[d.seq].process_id > 0)
     ORDER BY rprocess->proc[d.seq].is_a_run_after DESC
     DETAIL
      IF (trim(rprocess->proc[d.seq].com_file_name)="")
       IF ((rprocess->proc[d.seq].group_nbr > 0))
        rprocess->proc[d.seq].com_file_name = build(rprocess->proc[d.seq].prefix2,rprocess->proc[d
         .seq].group_nbr)
       ELSE
        rprocess->proc[d.seq].com_file_name = build(rprocess->proc[d.seq].prefix2,rprocess->pref[
         rprocess->proc[d.seq].pref2_pos].tmp_grp_nbr)
       ENDIF
       count1 = 0, found = 0
       WHILE (found != 1
        AND count1 <= file_cnt)
        count1 = (count1+ 1),
        IF (count1 <= file_cnt)
         IF ((rprocess->file[count1].com_file_name=rprocess->proc[d.seq].com_file_name))
          found = 1
         ENDIF
        ENDIF
       ENDWHILE
       IF (found=1)
        IF ((rprocess->proc[d.seq].group_nbr > 0))
         rprocess->file[count1].cnt = (rprocess->file[count1].cnt+ 1)
        ELSE
         IF ((rprocess->file[count1].cnt < 5))
          rprocess->file[count1].cnt = (rprocess->file[count1].cnt+ 1)
          IF ((rprocess->file[count1].cnt=5))
           rprocess->pref[rprocess->proc[d.seq].pref2_pos].tmp_grp_nbr = (rprocess->pref[rprocess->
           proc[d.seq].pref2_pos].tmp_grp_nbr+ 1)
          ENDIF
         ENDIF
        ENDIF
       ELSEIF (found=0)
        file_cnt = count1, stat = alterlist(rprocess->file,file_cnt), rprocess->file[file_cnt].
        com_file_name = rprocess->proc[d.seq].com_file_name,
        rprocess->file[file_cnt].cnt = 1
       ENDIF
      ENDIF
      IF ((((rprocess->proc[d.seq].is_a_run_after=1)) OR ((rprocess->proc[d.seq].run_after_process_id
       > 0))) )
       stat = alterlist(rprocess->temp,0), stat = alterlist(rprocess->temp,1), rprocess->temp[1].
       process_id = rprocess->proc[d.seq].process_id,
       rprocess->temp[1].run_after_process_id = rprocess->proc[d.seq].run_after_process_id, temp_size
        = 1, temp_cnt = 0
       WHILE (temp_cnt < temp_size)
         temp_cnt = (temp_cnt+ 1)
         IF ((rprocess->temp[temp_cnt].run_after_process_id > 0))
          found = 0, cnt3 = 0
          WHILE (found != 1
           AND cnt3 < proc_cnt)
           cnt3 = (cnt3+ 1),
           IF ((rprocess->proc[cnt3].process_id=rprocess->temp[temp_cnt].run_after_process_id))
            found = 1
           ENDIF
          ENDWHILE
          IF (found=1)
           IF ((rprocess->proc[cnt3].file_prefix=rprocess->proc[d.seq].file_prefix)
            AND (rprocess->proc[cnt3].precedence_level=rprocess->proc[d.seq].precedence_level)
            AND (rprocess->proc[cnt3].group_nbr=rprocess->proc[d.seq].group_nbr)
            AND trim(rprocess->proc[cnt3].com_file_name)="")
            temp_size = (temp_size+ 1), stat = alterlist(rprocess->temp,temp_size), rprocess->temp[
            temp_size].process_id = rprocess->proc[cnt3].process_id,
            rprocess->temp[temp_size].run_after_process_id = rprocess->proc[cnt3].
            run_after_process_id, rprocess->proc[cnt3].com_file_name = rprocess->proc[d.seq].
            com_file_name, rprocess->file[count1].cnt = (rprocess->file[count1].cnt+ 1)
            IF ((rprocess->proc[cnt3].group_nbr=0))
             IF ((rprocess->file[count1].cnt=5))
              rprocess->pref[rprocess->proc[cnt3].pref2_pos].tmp_grp_nbr = (rprocess->pref[rprocess->
              proc[cnt3].pref2_pos].tmp_grp_nbr+ 1)
             ENDIF
            ENDIF
           ENDIF
          ENDIF
         ENDIF
         cnt2 = 0
         WHILE (cnt2 < proc_cnt)
          cnt2 = (cnt2+ 1),
          IF ((rprocess->proc[cnt2].run_after_process_id=rprocess->temp[temp_cnt].process_id))
           IF ((rprocess->proc[cnt2].file_prefix=rprocess->proc[d.seq].file_prefix)
            AND (rprocess->proc[cnt2].precedence_level=rprocess->proc[d.seq].precedence_level)
            AND (rprocess->proc[cnt2].group_nbr=rprocess->proc[d.seq].group_nbr)
            AND trim(rprocess->proc[cnt2].com_file_name)="")
            rprocess->proc[cnt2].com_file_name = rprocess->proc[d.seq].com_file_name, rprocess->file[
            count1].cnt = (rprocess->file[count1].cnt+ 1)
            IF ((rprocess->proc[cnt2].group_nbr=0))
             IF ((rprocess->file[count1].cnt=5))
              rprocess->pref[rprocess->proc[cnt2].pref2_pos].tmp_grp_nbr = (rprocess->pref[rprocess->
              proc[cnt2].pref2_pos].tmp_grp_nbr+ 1)
             ENDIF
            ENDIF
            IF ((rprocess->proc[cnt2].is_a_run_after=1))
             temp_size = (temp_size+ 1), stat = alterlist(rprocess->temp,temp_size), rprocess->temp[
             temp_size].process_id = rprocess->proc[cnt2].process_id,
             rprocess->temp[temp_size].run_after_process_id = rprocess->proc[cnt2].
             run_after_process_id
            ENDIF
           ENDIF
          ENDIF
         ENDWHILE
       ENDWHILE
      ENDIF
     WITH nocounter
    ;end select
    IF (before_after_flag=1)
     DELETE  FROM dm_pkt_com_file_env dsp
      WHERE dsp.environment_id=env_id
     ;end delete
    ENDIF
    FOR (n = 1 TO proc_cnt)
     UPDATE  FROM dm_pkt_com_file_env dsp
      SET dsp.com_file_name = rprocess->proc[n].com_file_name, dsp.environment_id = env_id, dsp
       .before_after_flag = before_after_flag,
       dsp.instance_nbr = rprocess->proc[n].instance_nbr
      WHERE (dsp.process_id=rprocess->proc[n].process_id)
       AND dsp.environment_id=env_id
      WITH nocounter
     ;end update
     IF (curqual=0)
      INSERT  FROM dm_pkt_com_file_env dsp
       SET dsp.com_file_name = rprocess->proc[n].com_file_name, dsp.environment_id = env_id, dsp
        .before_after_flag = before_after_flag,
        dsp.process_id = rprocess->proc[n].process_id, dsp.instance_nbr = rprocess->proc[n].
        instance_nbr
       WITH nocounter
      ;end insert
     ENDIF
    ENDFOR
    COMMIT
   ELSEIF (mode=2)
    SELECT INTO "nl:"
     c.com_file_name
     FROM dm_pkt_com_file_env c,
      (dummyt d  WITH seq = value(proc_cnt))
     PLAN (d)
      JOIN (c
      WHERE c.environment_id=env_id
       AND c.before_after_flag=before_after_flag
       AND (rprocess->proc[d.seq].process_id=c.process_id))
     DETAIL
      rprocess->proc[d.seq].com_file_name = c.com_file_name, found = 0, cnt3 = 0
      WHILE (found != 1
       AND cnt3 < file_cnt)
       cnt3 = (cnt3+ 1),
       IF ((rprocess->file[cnt3].com_file_name=c.com_file_name))
        found = 1
       ENDIF
      ENDWHILE
      IF (found=0)
       file_cnt = (file_cnt+ 1), stat = alterlist(rprocess->file,file_cnt), rprocess->file[file_cnt].
       com_file_name = c.com_file_name
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
  IF (mode=2)
   SELECT INTO "nl:"
    l.success_ind
    FROM dm_pkt_setup_proc_log l,
     (dummyt d  WITH seq = value(proc_cnt))
    PLAN (d)
     JOIN (l
     WHERE (l.process_id=rprocess->proc[d.seq].process_id)
      AND l.environment_id=env_id)
    DETAIL
     rprocess->proc[d.seq].success_ind = l.success_ind
    WITH nocounter
   ;end select
  ENDIF
  SET ord_cnt = 0
  SELECT
   IF (mode=1)
    WHERE (rprocess->proc[d.seq].run_after_process_id=0)
   ELSEIF (mode=2)
    WHERE (rprocess->proc[d.seq].run_after_process_id=0)
     AND (rprocess->proc[d.seq].success_ind=0)
   ELSE
   ENDIF
   INTO "nl:"
   d.seq
   FROM (dummyt d  WITH seq = value(proc_cnt))
   DETAIL
    ord_cnt = (ord_cnt+ 1), stat = alterlist(rprocess->ord_proc,ord_cnt), rprocess->ord_proc[ord_cnt]
    .process_id = rprocess->proc[d.seq].process_id,
    rprocess->ord_proc[ord_cnt].com_file_name = rprocess->proc[d.seq].com_file_name, rprocess->proc[d
    .seq].in_ord_proc = 1
   WITH nocounter
  ;end select
  SELECT
   IF (mode=1)
    WHERE (rprocess->proc[d.seq].run_after_process_id > 0)
   ELSEIF (mode=2)
    WHERE (rprocess->proc[d.seq].run_after_process_id > 0)
     AND (rprocess->proc[d.seq].success_ind=0)
   ELSE
   ENDIF
   INTO "nl:"
   d.seq
   FROM (dummyt d  WITH seq = value(proc_cnt))
   DETAIL
    found_in_com_file = 0, cnt1 = 0
    WHILE (found_in_com_file != 1
     AND cnt1 < proc_cnt)
     cnt1 = (cnt1+ 1),
     IF ((rprocess->proc[d.seq].run_after_process_id=rprocess->proc[cnt1].process_id)
      AND (rprocess->proc[d.seq].com_file_name=rprocess->proc[cnt1].com_file_name))
      found_in_com_file = 1
     ENDIF
    ENDWHILE
    IF (found_in_com_file=0)
     ord_cnt = (ord_cnt+ 1), stat = alterlist(rprocess->ord_proc,ord_cnt), rprocess->ord_proc[ord_cnt
     ].process_id = rprocess->proc[d.seq].process_id,
     rprocess->ord_proc[ord_cnt].com_file_name = rprocess->proc[d.seq].com_file_name, rprocess->proc[
     d.seq].in_ord_proc = 1
    ELSEIF (found_in_com_file=1)
     IF (mode=2)
      IF ((rprocess->proc[cnt1].success_ind=1))
       ord_cnt = (ord_cnt+ 1), stat = alterlist(rprocess->ord_proc,ord_cnt), rprocess->ord_proc[
       ord_cnt].process_id = rprocess->proc[d.seq].process_id,
       rprocess->ord_proc[ord_cnt].com_file_name = rprocess->proc[d.seq].com_file_name, rprocess->
       proc[d.seq].in_ord_proc = 1
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SET done = 0
  SET prev_ord_cnt = ord_cnt
  WHILE (done=0)
   SELECT
    IF (mode=1)
     WHERE (rprocess->proc[d.seq].run_after_process_id > 0)
      AND (rprocess->proc[d.seq].in_ord_proc != 1)
    ELSEIF (mode=2)
     WHERE (rprocess->proc[d.seq].run_after_process_id > 0)
      AND (rprocess->proc[d.seq].in_ord_proc != 1)
      AND (rprocess->proc[d.seq].success_ind=0)
    ELSE
    ENDIF
    INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(proc_cnt))
    DETAIL
     found = 0, cnt1 = 0
     WHILE (found != 1
      AND cnt1 < ord_cnt)
      cnt1 = (cnt1+ 1),
      IF ((rprocess->proc[d.seq].run_after_process_id=rprocess->ord_proc[cnt1].process_id))
       ord_cnt = (ord_cnt+ 1), stat = alterlist(rprocess->ord_proc,ord_cnt), rprocess->ord_proc[
       ord_cnt].process_id = rprocess->proc[d.seq].process_id,
       rprocess->ord_proc[ord_cnt].com_file_name = rprocess->proc[d.seq].com_file_name, rprocess->
       proc[d.seq].in_ord_proc = 1, found = 1
      ENDIF
     ENDWHILE
    WITH nocounter
   ;end select
   IF (prev_ord_cnt=ord_cnt)
    SET done = 1
   ELSE
    SET prev_ord_cnt = ord_cnt
   ENDIF
  ENDWHILE
  IF (com_file_flag=1)
   SET nbr_of_loops = 2
  ELSEIF (com_file_flag=2)
   SET nbr_of_loops = 1
  ENDIF
  FOR (loopcnt = 1 TO nbr_of_loops)
   FOR (count1 = 1 TO file_cnt)
     SET out_file_name = fillstring(54," ")
     IF (target_op_sys="VMS")
      SET out_file_name = concat(rprocess->file[count1].com_file_name,".com")
     ELSE
      SET out_file_name = concat(rprocess->file[count1].com_file_name,".ksh")
     ENDIF
     SELECT
      IF (target_op_sys="AIX")
       WITH nocounter, formfeed = none, maxrow = 1,
        maxcol = 512, format = variable
      ELSE
       WITH nocounter, formfeed = none, format = variable,
        maxrow = 1, maxcol = 200
      ENDIF
      INTO value(out_file_name)
      d.seq
      FROM (dummyt d  WITH seq = value(proc_cnt)),
       (dummyt d2  WITH seq = value(ord_cnt))
      PLAN (d2
       WHERE (rprocess->ord_proc[d2.seq].com_file_name=rprocess->file[count1].com_file_name))
       JOIN (d
       WHERE (rprocess->proc[d.seq].process_id=rprocess->ord_proc[d2.seq].process_id)
        AND (rprocess->proc[d.seq].success_ind=0))
      HEAD REPORT
       file_proc_cnt = 0, step_name = fillstring(10," "), step_label = fillstring(12," "),
       next_step_name = fillstring(10," "), step_function = fillstring(14," "), error_file_name =
       fillstring(75," "),
       del_error_file_name = fillstring(75," "), file_string = fillstring(100," "), file_string1 =
       fillstring(100," "),
       ccl_error_file_name = fillstring(75," ")
       IF (target_op_sys="AIX")
        col 0, "#!/usr/bin/ksh", row + 1,
        col 0, ". $cer_mgr/.user_setup ", estring,
        prn_string1 = fillstring(125," "), prn_string2 = fillstring(125," "), prn_string3 =
        fillstring(125," "),
        prn_string4 = fillstring(125," "), ttl_prn_string = fillstring(500," ")
       ELSE
        col 0, "$!", row + 1,
        col 0, "$set verify", row + 1,
        col 0, '$define sys$output "ccluserdir:', rprocess->file[count1].com_file_name,
        '.log"'
       ENDIF
      DETAIL
       file_proc_cnt = (file_proc_cnt+ 1), step_name = build("STEP",file_proc_cnt), next_step_name =
       build("STEP",(file_proc_cnt+ 1)),
       step_function = build(step_name,"() {"), ccl_error_file_name = build('"',rprocess->file[count1
        ].com_file_name,'"')
       IF (target_op_sys="VMS")
        row + 1, col 0, "$!",
        del_error_file_name = build("ccluserdir:",rprocess->file[count1].com_file_name,".dat;*"),
        error_file_name = build("ccluserdir:",rprocess->file[count1].com_file_name,".dat"),
        step_label = build("$",step_name,":"),
        row + 1, col 0, step_label,
        row + 1, col 0, "$!",
        row + 1, col 0, "$! process owner = ",
        rprocess->proc[d.seq].owner_email, row + 1, col 0,
        "$! ", rprocess->proc[d.seq].description
        IF (com_file_flag=1
         AND loopcnt=1)
         row + 1, col 0, "$! individual file name = ",
         rprocess->proc[d.seq].com_file_name2
        ENDIF
        row + 1, col 0, "$!",
        row + 1, col 0, "$! delete previous instances of the error file",
        file_string1 = build('$FILE = F$SEARCH("',cnvtupper(error_file_name),'")'), row + 1, col 0,
        file_string1, row + 1, col 0,
        '$IF FILE .NES. "" THEN DELETE ', del_error_file_name, row + 1,
        col 0, '$CCL :== "$CER_EXE:CCLORA.EXE"', row + 1,
        col 0, "$CCL"
       ELSE
        row + 1, col 0, "#",
        error_file_name = build("$CCLUSERDIR/",rprocess->file[count1].com_file_name,".dat"), row + 1,
        col 0,
        "# process owner = ", rprocess->proc[d.seq].owner_email, row + 1,
        col 0, "# ", rprocess->proc[d.seq].description
        IF (com_file_flag=1
         AND loopcnt=1)
         row + 1, col 0, "# individual file name = ",
         rprocess->proc[d.seq].com_file_name2
        ENDIF
        row + 1, col 0, "#",
        row + 1, col 0, "rm -f ",
        error_file_name, row + 1, col 0,
        "ccl <<!"
       ENDIF
       row + 1, col 0, "FREE DEFINE ORACLESYSTEM GO",
       row + 1, col 0, "DEFINE ORACLESYSTEM ",
       v5_connect_quotes, " GO", row + 1,
       col 0, "RECORD REQUEST (", row + 1,
       col 0, "1 SETUP_PROC[1]", row + 1,
       col 0, "2 ERROR_FILE_NAME = VC", row + 1,
       col 0, "2 ENV_ID = F8", row + 1,
       col 0, "2 PROCESS_ID = F8", row + 1,
       col 0, "2 SUCCESS_IND = I2", row + 1,
       col 0, "2 ERROR_MSG = C200) GO", row + 1,
       col 0, "SET REQUEST->SETUP_PROC[1]->ERROR_FILE_NAME = ", row + 1,
       col 0, ccl_error_file_name, " GO",
       row + 1, col 0, "SET REQUEST->SETUP_PROC[1]->PROCESS_ID = ",
       row + 1, col 0, rprocess->proc[d.seq].run_after_process_id,
       " GO", row + 1, col 0,
       "SET REQUEST->SETUP_PROC[1]->ENV_ID = ", env_id, " GO",
       row + 1, col 0, "dm_make_readme_error_file go",
       row + 1, col 0, "dm_add_start_time ",
       rprocess->proc[d.seq].process_id, ",", env_id,
       " GO", row + 1, col 0,
       "EXIT"
       IF (target_op_sys="VMS")
        file_string = build('$FILE = F$SEARCH("',cnvtupper(error_file_name),'")'), row + 1, col 0,
        file_string, row + 1, col 0,
        '$IF FILE .NES. "" THEN SET SEC ', error_file_name, " /PROT=W:RWED",
        row + 1, col 0, '$IF FILE .NES. "" THEN GOTO ',
        next_step_name
       ELSE
        row + 1, col 0, "!",
        row + 1, col 0, step_function
       ENDIF
       IF ((rprocess->proc[d.seq].process_type=1))
        IF (target_op_sys="VMS")
         file_string = build('$FILE = F$SEARCH("CER_INSTALL:',cnvtupper(rprocess->proc[d.seq].
           data_file_name),'")'), row + 1, col 0,
         file_string, row + 1, col 0,
         '$IF FILE .EQS. "" THEN GOTO ', next_step_name, row + 1,
         col 0, "$DIMP :== $CER_EXE:DBIMPORT.EXE", row + 1,
         col 0, "$DIMP CER_INSTALL:", rprocess->proc[d.seq].data_file_name,
         " 1 ", rprocess->proc[d.seq].blocks_to_process, " 0 -",
         row + 1, col 0, "ORACLE:",
         v5_connect, " -", row + 1,
         col 0, rprocess->proc[d.seq].program_name, " -",
         row + 1, col 0, rprocess->proc[d.seq].program_name,
         " 2", row + 1, col 0,
         '$CCL :== "$CER_EXE:CCLORA.EXE"', row + 1, col 0,
         "$CCL"
        ELSE
         prn_string1 = concat(rprocess->proc[d.seq].data_file_name," 1"), prn_string2 = concat(" ",
          trim(cnvtstring(rprocess->proc[d.seq].blocks_to_process))," 0"," ORACLE:",v5_connect),
         prn_string3 = concat(" ",rprocess->proc[d.seq].program_name),
         prn_string4 = concat(" ",rprocess->proc[d.seq].program_name," 2"), ttl_prn_string = build(
          "$cer_exe/dbimport $cer_install/",prn_string1,prn_string2,prn_string3,prn_string4), row + 1,
         col 0, ttl_prn_string, row + 1,
         col 0, "ccl <<!"
        ENDIF
        row + 1, col 0, "%d on",
        row + 1, col 0, "FREE DEFINE ORACLESYSTEM GO",
        row + 1, col 0, "DEFINE ORACLESYSTEM ",
        v5_connect_quotes, " GO", row + 1,
        col 0, "RECORD REQUEST (", row + 1,
        col 0, "1 SETUP_PROC[1]", row + 1,
        col 0, "2 ENV_ID = F8", row + 1,
        col 0, "2 PROCESS_ID = F8", row + 1,
        col 0, "2 SUCCESS_IND = I2", row + 1,
        col 0, "2 ERROR_MSG = C200) GO", row + 1,
        col 0, "SET REQUEST->SETUP_PROC[1]->PROCESS_ID = ", row + 1,
        col 0, rprocess->proc[d.seq].process_id, " GO",
        row + 1, col 0, "SET REQUEST->SETUP_PROC[1]->ENV_ID = ",
        env_id, " GO", row + 1,
        col 0, rprocess->proc[d.seq].error_routine_name, " GO",
        row + 1, col 0, "EXIT"
       ELSEIF ((rprocess->proc[d.seq].process_type=2))
        IF (target_op_sys="VMS")
         row + 1, col 0, '$CCL :== "$CER_EXE:CCLORA.EXE"',
         row + 1, col 0, "$CCL"
        ELSE
         row + 1, col 0, "ccl <<!"
        ENDIF
        row + 1, col 0, "%d on",
        row + 1, col 0, "FREE DEFINE ORACLESYSTEM GO",
        row + 1, col 0, "DEFINE ORACLESYSTEM ",
        v5_connect_quotes, " GO", row + 1,
        col 0, "RECORD REQUEST (", row + 1,
        col 0, "1 SETUP_PROC[1]", row + 1,
        col 0, "2 ENV_ID = F8", row + 1,
        col 0, "2 PROCESS_ID = F8", row + 1,
        col 0, "2 SUCCESS_IND = I2", row + 1,
        col 0, "2 ERROR_MSG = C200) GO", row + 1,
        col 0, "SET REQUEST->SETUP_PROC[1]->PROCESS_ID = ", row + 1,
        col 0, rprocess->proc[d.seq].process_id, " GO",
        row + 1, col 0, "SET REQUEST->SETUP_PROC[1]->ENV_ID = ",
        env_id, " GO", row + 1,
        col 0, "%I CER_INSTALL:", rprocess->proc[d.seq].script_name
        IF ((rprocess->proc[d.seq].error_routine_name != "none"))
         row + 1, col 0, rprocess->proc[d.seq].error_routine_name,
         " GO"
        ENDIF
        row + 1, col 0, "EXIT"
       ELSEIF ((rprocess->proc[d.seq].process_type=3))
        IF (target_op_sys="VMS")
         row + 1, col 0, '$CCL :== "$CER_EXE:CCLORA.EXE"',
         row + 1, col 0, "$CCL"
        ELSE
         row + 1, col 0, "ccl <<!"
        ENDIF
        row + 1, col 0, "%d on",
        row + 1, col 0, "FREE DEFINE ORACLESYSTEM GO",
        row + 1, col 0, "DEFINE ORACLESYSTEM ",
        v5_connect_quotes, " GO", row + 1,
        col 0, "RECORD REQUEST (", row + 1,
        col 0, "1 SETUP_PROC[1]", row + 1,
        col 0, "2 ENV_ID = F8", row + 1,
        col 0, "2 PROCESS_ID = F8", row + 1,
        col 0, "2 SUCCESS_IND = I2", row + 1,
        col 0, "2 ERROR_MSG = C200) GO", row + 1,
        col 0, "SET REQUEST->SETUP_PROC[1]->PROCESS_ID = ", row + 1,
        col 0, rprocess->proc[d.seq].process_id, " GO",
        row + 1, col 0, "SET REQUEST->SETUP_PROC[1]->ENV_ID = ",
        env_id, " GO", row + 1,
        col 0, rprocess->proc[d.seq].program_name, " GO"
        IF ((rprocess->proc[d.seq].error_routine_name != "none"))
         row + 1, col 0, rprocess->proc[d.seq].error_routine_name,
         " GO"
        ENDIF
        row + 1, col 0, "EXIT"
       ELSEIF ((rprocess->proc[d.seq].process_type=4))
        IF (target_op_sys="VMS")
         row + 1, col 0, "$@ORA_UTIL:ORAUSER",
         row + 1, col 0, "$SQLPLUS ",
         v5_connect, row + 1, col 0,
         "@cer_install:", rprocess->proc[d.seq].script_name, row + 1,
         col 0, "EXIT;", row + 1,
         col 0, '$CCL :== "$CER_EXE:CCLORA.EXE"', row + 1,
         col 0, "$CCL"
        ELSE
         prn_string1 = concat("$ORACLE_HOME/bin/sqlplus ",v5_connect," <<!"), row + 1, col 0,
         prn_string1, row + 1, col 0,
         "@$cer_install/", rprocess->proc[d.seq].script_name, row + 1,
         col 0, "EXIT;", row + 1,
         col 0, "!", row + 1,
         col 0, "ccl <<!"
        ENDIF
        row + 1, col 0, "%d on",
        row + 1, col 0, "FREE DEFINE ORACLESYSTEM GO",
        row + 1, col 0, "DEFINE ORACLESYSTEM ",
        v5_connect_quotes, " GO", row + 1,
        col 0, "RECORD REQUEST (", row + 1,
        col 0, "1 SETUP_PROC[1]", row + 1,
        col 0, "2 ENV_ID = F8", row + 1,
        col 0, "2 PROCESS_ID = F8", row + 1,
        col 0, "2 SUCCESS_IND = I2", row + 1,
        col 0, "2 ERROR_MSG = C200) GO", row + 1,
        col 0, "SET REQUEST->SETUP_PROC[1]->PROCESS_ID = ", row + 1,
        col 0, rprocess->proc[d.seq].process_id, " GO",
        row + 1, col 0, "SET REQUEST->SETUP_PROC[1]->ENV_ID = ",
        env_id, " GO", row + 1,
        col 0, rprocess->proc[d.seq].error_routine_name, " GO",
        row + 1, col 0, "EXIT"
       ELSEIF ((rprocess->proc[d.seq].process_type=5))
        log_file = fillstring(100," "), name_length = size(rprocess->proc[d.seq].data_file_name),
        new_length = (name_length - 4),
        log_file = concat(substring(1,new_length,rprocess->proc[d.seq].data_file_name),".log")
        IF (target_op_sys="VMS")
         row + 1, col 0, "$@ORA_UTIL:ORAUSER",
         row + 1, col 0, "$IMP ",
         v5_connect, " -", row + 1,
         col 0, " FILE=CER_INSTALL:", rprocess->proc[d.seq].data_file_name,
         " -"
         IF (trim(rprocess->proc[d.seq].script_name) != "")
          row + 1, col 0, " PARFILE=CER_INSTALL:",
          rprocess->proc[d.seq].script_name, " -"
         ELSE
          row + 1, col 0, " IGNORE=Y COMMIT=Y FULL=Y -"
         ENDIF
         row + 1, col 0, " LOG=CCLUSERDIR:",
         log_file
        ELSE
         IF (trim(rprocess->proc[d.seq].script_name) != "")
          prn_string1 = "$ORACLE_HOME/bin/imp", prn_string2 = concat(" ",trim(v5_connect),
           " FILE=$cer_install/",rprocess->proc[d.seq].data_file_name," PARFILE=$cer_install/",
           rprocess->proc[d.seq].script_name," LOG=$CCLUSERDIR/",trim(log_file)), ttl_prn_string =
          build(prn_string1,prn_string2),
          row + 1, col 0, ttl_prn_string
         ELSE
          prn_string1 = "$ORACLE_HOME/bin/imp", prn_string2 = concat(" ",trim(v5_connect),
           " FILE=$cer_install/",rprocess->proc[d.seq].data_file_name," IGNORE=Y COMMIT=Y FULL=Y",
           " LOG=$CCLUSERDIR/",trim(log_file)), ttl_prn_string = build(prn_string1,prn_string2),
          row + 1, col 0, ttl_prn_string
         ENDIF
        ENDIF
        IF (target_op_sys="VMS")
         row + 1, col 0, '$CCL :== "$CER_EXE:CCLORA.EXE"',
         row + 1, col 0, "$CCL"
        ELSE
         row + 1, col 0, "ccl <<!"
        ENDIF
        row + 1, col 0, "%d on",
        row + 1, col 0, "FREE DEFINE ORACLESYSTEM GO",
        row + 1, col 0, "DEFINE ORACLESYSTEM ",
        v5_connect_quotes, " GO", row + 1,
        col 0, "RECORD REQUEST (", row + 1,
        col 0, "1 SETUP_PROC[1]", row + 1,
        col 0, "2 ENV_ID = F8", row + 1,
        col 0, "2 PROCESS_ID = F8", row + 1,
        col 0, "2 SUCCESS_IND = I2", row + 1,
        col 0, "2 ERROR_MSG = C200) GO", row + 1,
        col 0, "SET REQUEST->SETUP_PROC[1]->PROCESS_ID = ", row + 1,
        col 0, rprocess->proc[d.seq].process_id, " GO",
        row + 1, col 0, "SET REQUEST->SETUP_PROC[1]->ENV_ID = ",
        env_id, " GO", row + 1,
        col 0, rprocess->proc[d.seq].error_routine_name, " GO",
        row + 1, col 0, "EXIT"
       ELSEIF ((rprocess->proc[d.seq].process_type=6))
        log_file = fillstring(100," "), name_length = size(rprocess->proc[d.seq].data_file_name),
        new_length = (name_length - 4),
        log_file = concat(substring(1,new_length,rprocess->proc[d.seq].data_file_name),".log")
        IF (target_op_sys="VMS")
         row + 1, col 0, "$@ORA_UTIL:ORAUSER",
         row + 1, col 0, "$IMP ",
         v5ref_connect, " -", row + 1,
         col 0, " FILE=CER_INSTALL:", rprocess->proc[d.seq].data_file_name,
         " -"
         IF (trim(rprocess->proc[d.seq].script_name) != "")
          row + 1, col 0, " PARFILE=CER_INSTALL:",
          rprocess->proc[d.seq].script_name, " -"
         ELSE
          row + 1, col 0, " IGNORE=Y COMMIT=Y FULL=Y-"
         ENDIF
         row + 1, col 0, " LOG=CCLUSERDIR:",
         log_file
        ELSE
         IF (trim(rprocess->proc[d.seq].script_name) != "")
          prn_string1 = "$ORACLE_HOME/bin/imp", prn_string2 = concat(" ",trim(v5ref_connect),
           " FILE=$cer_install/",rprocess->proc[d.seq].data_file_name," PARFILE=$cer_install/",
           rprocess->proc[d.seq].script_name," LOG=$CCLUSERDIR/",trim(log_file)), ttl_prn_string =
          build(prn_string1,prn_string2),
          row + 1, col 0, ttl_prn_string
         ELSE
          prn_string1 = "$ORACLE_HOME/bin/imp", prn_string2 = concat(" ",trim(v5ref_connect),
           " FILE=$cer_install/",rprocess->proc[d.seq].data_file_name," IGNORE=Y COMMIT=Y FULL=Y",
           " LOG=$CCLUSERDIR/",trim(log_file)), ttl_prn_string = build(prn_string1,prn_string2),
          row + 1, col 0, ttl_prn_string
         ENDIF
        ENDIF
        IF (target_op_sys="VMS")
         row + 1, col 0, '$CCL :== "$CER_EXE:CCLORA.EXE"',
         row + 1, col 0, "$CCL"
        ELSE
         row + 1, col 0, "ccl <<!"
        ENDIF
        row + 1, col 0, "%d on",
        row + 1, col 0, "FREE DEFINE ORACLESYSTEM GO",
        row + 1, col 0, "DEFINE ORACLESYSTEM ",
        v5_connect_quotes, " GO", row + 1,
        col 0, "RECORD REQUEST (", row + 1,
        col 0, "1 SETUP_PROC[1]", row + 1,
        col 0, "2 ENV_ID = F8", row + 1,
        col 0, "2 PROCESS_ID = F8", row + 1,
        col 0, "2 SUCCESS_IND = I2", row + 1,
        col 0, "2 ERROR_MSG = C200) GO", row + 1,
        col 0, "SET REQUEST->SETUP_PROC[1]->PROCESS_ID = ", row + 1,
        col 0, rprocess->proc[d.seq].process_id, " GO",
        row + 1, col 0, "SET REQUEST->SETUP_PROC[1]->ENV_ID = ",
        env_id, " GO", row + 1,
        col 0, rprocess->proc[d.seq].error_routine_name, " GO",
        row + 1, col 0, "EXIT"
       ENDIF
       IF (target_op_sys="AIX")
        row + 1, col 0, "!",
        row + 1, col 0, "}",
        file_string = concat("if [[ ! -a ",trim(error_file_name)," ]]"), row + 1, col 0,
        file_string, row + 1, col 0,
        "then", row + 1, col 0,
        step_name, row + 1, col 0,
        "fi"
       ENDIF
      FOOT REPORT
       IF (target_op_sys="VMS")
        file_proc_cnt = (file_proc_cnt+ 1), step_name = build("STEP",file_proc_cnt), next_step_name
         = build("STEP",(file_proc_cnt+ 1)),
        row + 1, col 0, "$!",
        step_label = build("$",step_name,":"), row + 1, col 0,
        step_label, row + 1, col 0,
        "$!", row + 1, col 0,
        "$set nover", row + 1, col 0,
        "$deassign sys$output"
       ENDIF
     ;end select
   ENDFOR
   IF (com_file_flag=1)
    SET stat = alterlist(rprocess->file,0)
    SET file_cnt = 0
    SET stat = alterlist(rprocess->ord_proc,0)
    SET ord_cnt = 0
    SELECT INTO "nl:"
     d.seq
     FROM (dummyt d  WITH seq = value(proc_cnt))
     DETAIL
      rprocess->proc[d.seq].com_file_name = rprocess->proc[d.seq].com_file_name2, file_cnt = (
      file_cnt+ 1), stat = alterlist(rprocess->file,file_cnt),
      rprocess->file[file_cnt].com_file_name = rprocess->proc[d.seq].com_file_name, ord_cnt = (
      ord_cnt+ 1), stat = alterlist(rprocess->ord_proc,ord_cnt),
      rprocess->ord_proc[ord_cnt].com_file_name = rprocess->proc[d.seq].com_file_name, rprocess->
      ord_proc[ord_cnt].process_id = rprocess->proc[d.seq].process_id
     WITH nocounter
    ;end select
   ENDIF
  ENDFOR
 ENDIF
#exit_script
END GO
