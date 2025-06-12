CREATE PROGRAM bed_imp_resource_lists:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF (validate(resource_rec)=0)
  RECORD resource_rec(
    1 res_list_cnt = i4
    1 res_lists[*]
      2 resource_list = vc
      2 resource_list_cd = f8
      2 consultant_list_role_id = f8
      2 patient_list_role_id = f8
      2 list_action_flag = i4
      2 resource_cnt = i4
      2 resources[*]
        3 resources_available = vc
        3 resources_available_cd = f8
        3 resource_flex_string = vc
        3 resource_flex_string_cd = f8
        3 resource_flex_string_flag = i2
        3 resource_action_flag = i4
        3 slot_cnt = i4
        3 slots[*]
          4 slot_name = vc
          4 slot_name_cd = f8
          4 procedure_duration = i4
          4 slot_action_flag = i4
  )
 ENDIF
 FREE SET temp
 RECORD temp(
   1 cnt = i4
   1 qual[*]
     2 list_role_id = f8
     2 updt_cnt = i4
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 DECLARE patient_resource_cd = f8
 DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE end_dt_tm = dq8 WITH constant(cnvtdatetime("31-dec-2100 00:00:00"))
 DECLARE count = i4
 DECLARE insert_flag = i2 WITH protect, noconstant(0)
 SET active_cd = get_code_value(48,"ACTIVE")
 SET inactive_cd = get_code_value(48,"INACTIVE")
 SET algorithm_cd = get_code_value(15109,"FIRSTAVAIL")
 SET prompt_accept_cd = get_code_value(16109,"DISABLE")
 SET role_type_cd = get_code_value(16151,"RESLIST")
 SET res_sch_cd = get_code_value(16145,"SCHEDULE")
 SET minutes_cd = get_code_value(54,"MINUTES")
 SET offset_type_cd = get_code_value(15129,"BEG")
 SET flex_type_cd = get_code_value(16162,"RLRES")
 SET title = validate(log_title_set,"Resource List Upload Log")
 SET name = validate(log_name_set,"resource_list_upload.log")
 CALL logstart(title,name)
 SET numrows = size(requestin->list_0,5)
 IF (numrows=0)
  SET error_msg = "No rows in data file, import must exit !!"
  GO TO exit_script
 ENDIF
 IF (validate(tempreq) > 0)
  IF (cnvtupper(trim(tempreq->insert_ind,3))="Y")
   SET insert_flag = 1
  ENDIF
 ENDIF
 SET patient_resource_cd = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE code_set=14250
   AND display_key="PATIENT"
  DETAIL
   patient_resource_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (patient_resource_cd=0.0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  resource_list = trim(substring(1,100,requestin->list_0[d.seq].resource_list),3),
  resources_available = trim(substring(1,100,requestin->list_0[d.seq].resources_available),3),
  slot_name = trim(substring(1,100,requestin->list_0[d.seq].slot_name),3),
  procedure_duration = cnvtint(requestin->list_0[d.seq].procedure_duration), resource_flex_string =
  trim(substring(1,100,requestin->list_0[d.seq].resource_flex_string),3)
  FROM (dummyt d  WITH seq = value(numrows))
  ORDER BY resource_list, resources_available, slot_name
  HEAD REPORT
   list_cnt = 0, res_cnt = 0, slot_cnt = 0
  HEAD resource_list
   list_cnt = (list_cnt+ 1)
   IF (mod(list_cnt,50)=1)
    stat = alterlist(resource_rec->res_lists,(list_cnt+ 49))
   ENDIF
   resource_rec->res_lists[list_cnt].resource_list = resource_list
  HEAD resources_available
   res_cnt = (res_cnt+ 1)
   IF (mod(res_cnt,10)=1)
    stat = alterlist(resource_rec->res_lists[list_cnt].resources,(res_cnt+ 9))
   ENDIF
   resource_rec->res_lists[list_cnt].resources[res_cnt].resources_available = resources_available,
   resource_rec->res_lists[list_cnt].resources[res_cnt].resource_flex_string = resource_flex_string
  HEAD slot_name
   slot_cnt = (slot_cnt+ 1)
   IF (mod(slot_cnt,10)=1)
    stat = alterlist(resource_rec->res_lists[list_cnt].resources[res_cnt].slots,(slot_cnt+ 9))
   ENDIF
   resource_rec->res_lists[list_cnt].resources[res_cnt].slots[slot_cnt].slot_name = slot_name,
   resource_rec->res_lists[list_cnt].resources[res_cnt].slots[slot_cnt].procedure_duration =
   procedure_duration
  FOOT  resources_available
   stat = alterlist(resource_rec->res_lists[list_cnt].resources[res_cnt].slots,slot_cnt),
   resource_rec->res_lists[list_cnt].resources[res_cnt].slot_cnt = slot_cnt, slot_cnt = 0
  FOOT  resource_list
   stat = alterlist(resource_rec->res_lists[list_cnt].resources,res_cnt), resource_rec->res_lists[
   list_cnt].resource_cnt = res_cnt, res_cnt = 0
  FOOT REPORT
   resource_rec->res_list_cnt = list_cnt, stat = alterlist(resource_rec->res_lists,resource_rec->
    res_list_cnt)
  WITH nocounter
 ;end select
 FOR (list_cnt = 1 TO resource_rec->res_list_cnt)
   SELECT INTO "nl:"
    srl.res_list_id
    FROM sch_resource_list srl
    PLAN (srl
     WHERE srl.mnemonic_key=cnvtupper(resource_rec->res_lists[list_cnt].resource_list)
      AND srl.active_ind=1)
    DETAIL
     resource_rec->res_lists[list_cnt].resource_list_cd = srl.res_list_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET resource_rec->res_lists[list_cnt].list_action_flag = 1
   ENDIF
   SET count = 0
   IF (curqual > 0
    AND insert_flag > 0)
    SELECT INTO "nl:"
     slr.list_role_id
     FROM sch_list_role slr
     PLAN (slr
      WHERE (resource_rec->res_lists[list_cnt].resource_list_cd=slr.res_list_id)
       AND slr.active_ind=1)
     DETAIL
      count = (count+ 1)
      IF (mod(count,10)=1)
       stat = alterlist(temp->qual,(count+ 9))
      ENDIF
      temp->qual[count].list_role_id = slr.list_role_id
     WITH nocounter, forupdate(slr)
    ;end select
    SET stat = alterlist(temp->qual,count)
    SET temp->cnt = count
    IF ((temp->cnt > 0))
     SELECT INTO "nl:"
      FROM sch_list_slot sls,
       (dummyt dt  WITH seq = value(temp->cnt))
      PLAN (dt)
       JOIN (sls
       WHERE (sls.list_role_id=temp->qual[dt.seq].list_role_id)
        AND sls.active_ind=1)
      WITH nocounter, forupdate(sls)
     ;end select
     DELETE  FROM sch_list_slot sls,
       (dummyt dt  WITH seq = value(temp->cnt))
      SET sls.seq = 1
      PLAN (dt)
       JOIN (sls
       WHERE (sls.list_role_id=temp->qual[dt.seq].list_role_id)
        AND sls.active_ind=1)
      WITH nocounter
     ;end delete
     SELECT INTO "nl:"
      FROM sch_list_res slres,
       (dummyt dt  WITH seq = value(temp->cnt))
      PLAN (dt)
       JOIN (slres
       WHERE (slres.list_role_id=temp->qual[dt.seq].list_role_id)
        AND slres.active_ind=1)
      WITH nocounter, forupdate(slres)
     ;end select
     DELETE  FROM sch_list_res slres,
       (dummyt dt  WITH seq = value(temp->cnt))
      SET slres.seq = 1
      PLAN (dt)
       JOIN (slres
       WHERE (slres.list_role_id=temp->qual[dt.seq].list_role_id)
        AND slres.active_ind=1)
      WITH nocounter
     ;end delete
     DELETE  FROM sch_list_role slr,
       (dummyt dt  WITH seq = value(temp->cnt))
      SET slr.seq = 1
      PLAN (dt)
       JOIN (slr
       WHERE (slr.list_role_id=temp->qual[dt.seq].list_role_id)
        AND slr.active_ind=1)
      WITH nocounter
     ;end delete
    ENDIF
   ENDIF
   FOR (res_cnt = 1 TO resource_rec->res_lists[list_cnt].resource_cnt)
     SELECT INTO "nl:"
      cv.code_value
      FROM code_value cv
      PLAN (cv
       WHERE cv.code_set=14231
        AND (cv.display=resource_rec->res_lists[list_cnt].resources[res_cnt].resources_available)
        AND cv.active_ind=1)
      DETAIL
       resource_rec->res_lists[list_cnt].resources[res_cnt].resources_available_cd = cv.code_value
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET resource_rec->res_lists[list_cnt].resources[res_cnt].resource_action_flag = - (1)
      SET resource_rec->res_lists[list_cnt].list_action_flag = - (1)
     ENDIF
     SELECT INTO "nl:"
      sfs.sch_flex_id
      FROM sch_flex_string sfs
      PLAN (sfs
       WHERE (resource_rec->res_lists[list_cnt].resources[res_cnt].resource_flex_string=sfs.mnemonic)
        AND sfs.active_ind=1
        AND sfs.flex_type_cd=flex_type_cd)
      DETAIL
       resource_rec->res_lists[list_cnt].resources[res_cnt].resource_flex_string_cd = sfs.sch_flex_id
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET resource_rec->res_lists[list_cnt].resources[res_cnt].resource_flex_string_flag = - (1)
      SET resource_rec->res_lists[list_cnt].resources[res_cnt].resource_flex_string_cd = 0.0
     ENDIF
     FOR (slot_count = 1 TO resource_rec->res_lists[list_cnt].resources[res_cnt].slot_cnt)
      SELECT INTO "nl:"
       sst.slot_type_id
       FROM sch_slot_type sst
       PLAN (sst
        WHERE sst.mnemonic_key=cnvtupper(resource_rec->res_lists[list_cnt].resources[res_cnt].slots[
         slot_count].slot_name)
         AND sst.active_ind=1)
       DETAIL
        resource_rec->res_lists[list_cnt].resources[res_cnt].slots[slot_count].slot_name_cd = sst
        .slot_type_id
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET resource_rec->res_lists[list_cnt].resources[res_cnt].slots[slot_count].slot_action_flag =
       - (1)
       SET resource_rec->res_lists[list_cnt].list_action_flag = - (1)
      ENDIF
     ENDFOR
   ENDFOR
 ENDFOR
 IF (insert_flag <= 0)
  GO TO gen_report
 ENDIF
 FOR (list_cnt = 1 TO resource_rec->res_list_cnt)
   IF ((resource_rec->res_lists[list_cnt].list_action_flag >= 0))
    IF ((resource_rec->res_lists[list_cnt].list_action_flag=1))
     SELECT INTO "nl:"
      nextseqnum = seq(sch_res_list_seq,nextval)
      FROM dual
      DETAIL
       resource_rec->res_lists[list_cnt].resource_list_cd = nextseqnum
      WITH nocounter, format
     ;end select
     INSERT  FROM sch_resource_list srl
      SET srl.res_list_id = resource_rec->res_lists[list_cnt].resource_list_cd, srl.version_dt_tm =
       cnvtdatetime("31-dec-2100 00:00:00"), srl.mnemonic = resource_rec->res_lists[list_cnt].
       resource_list,
       srl.mnemonic_key = cnvtupper(resource_rec->res_lists[list_cnt].resource_list), srl.description
        = resource_rec->res_lists[list_cnt].resource_list, srl.info_sch_text_id = 0.0,
       srl.appt_type_cd = 0.0, srl.location_cd = 0.0, srl.null_dt_tm = cnvtdatetime(
        "31-dec-2100 00:00:00"),
       srl.candidate_id = seq(sch_candidate_seq,nextval), srl.beg_effective_dt_tm = cnvtdatetime(
        curdate,curtime3), srl.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"),
       srl.active_ind = 1, srl.active_status_cd = active_cd, srl.active_status_dt_tm = cnvtdatetime(
        curdate,curtime3),
       srl.active_status_prsnl_id = reqinfo->updt_id, srl.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       srl.updt_applctx = reqinfo->updt_applctx,
       srl.updt_id = reqinfo->updt_id, srl.updt_cnt = 0, srl.updt_task = reqinfo->updt_task,
       srl.mnemonic_key_nls = ""
      WITH nocounter
     ;end insert
    ENDIF
    SELECT INTO "nl:"
     x = seq(sch_res_list_seq,nextval)
     FROM dual
     DETAIL
      resource_rec->res_lists[list_cnt].consultant_list_role_id = x
     WITH nocounter, format
    ;end select
    INSERT  FROM sch_list_role slr
     SET slr.list_role_id = resource_rec->res_lists[list_cnt].consultant_list_role_id, slr
      .version_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), slr.sch_role_cd = 0.0,
      slr.role_meaning = "", slr.res_list_id = resource_rec->res_lists[list_cnt].resource_list_cd,
      slr.role_seq = 0,
      slr.description = "Consultant", slr.primary_ind = 1, slr.optional_ind = 0,
      slr.defining_ind = 0, slr.algorithm_cd = algorithm_cd, slr.algorithm_meaning = "FIRSTAVAIL",
      slr.dep_list_role_id = 0.0, slr.dep_resource_cd = 0.0, slr.null_dt_tm = cnvtdatetime(
       "31-dec-2100 00:00:00"),
      slr.candidate_id = seq(sch_candidate_seq,nextval), slr.beg_effective_dt_tm = cnvtdatetime(
       curdate,curtime3), slr.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"),
      slr.active_ind = 1, slr.active_status_cd = active_cd, slr.active_status_dt_tm = cnvtdatetime(
       curdate,curtime3),
      slr.active_status_prsnl_id = reqinfo->updt_id, slr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      slr.updt_applctx = reqinfo->updt_applctx,
      slr.updt_id = reqinfo->updt_id, slr.updt_cnt = 0, slr.updt_task = reqinfo->updt_task,
      slr.info_sch_text_id = 0.0, slr.mnemonic = "", slr.mnemonic_key = "",
      slr.mnemonic_key_nls = "", slr.prompt_accept_cd = prompt_accept_cd, slr.prompt_accept_meaning
       = "DISABLE",
      slr.role_type_cd = role_type_cd, slr.role_type_meaning = "RESLIST", slr.sch_flex_id = 0.0,
      slr.selected_ind = 1
     WITH nocounter
    ;end insert
    SELECT INTO "nl:"
     x = seq(sch_res_list_seq,nextval)
     FROM dual
     DETAIL
      resource_rec->res_lists[list_cnt].patient_list_role_id = x
     WITH nocounter
    ;end select
    INSERT  FROM sch_list_role slr
     SET slr.list_role_id = resource_rec->res_lists[list_cnt].patient_list_role_id, slr.version_dt_tm
       = cnvtdatetime("31-dec-2100 00:00:00"), slr.sch_role_cd = patient_resource_cd,
      slr.role_meaning = "PATIENT", slr.res_list_id = resource_rec->res_lists[list_cnt].
      resource_list_cd, slr.role_seq = 1,
      slr.description = "Patient", slr.primary_ind = 0, slr.optional_ind = 0,
      slr.defining_ind = 0, slr.algorithm_cd = algorithm_cd, slr.algorithm_meaning = "FIRSTAVAIL",
      slr.dep_list_role_id = 0.0, slr.dep_resource_cd = 0.0, slr.null_dt_tm = cnvtdatetime(
       "31-dec-2100 00:00:00"),
      slr.candidate_id = seq(sch_candidate_seq,nextval), slr.beg_effective_dt_tm = cnvtdatetime(
       curdate,curtime3), slr.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"),
      slr.active_ind = 1, slr.active_status_cd = active_cd, slr.active_status_dt_tm = cnvtdatetime(
       curdate,curtime3),
      slr.active_status_prsnl_id = reqinfo->updt_id, slr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      slr.updt_applctx = reqinfo->updt_applctx,
      slr.updt_id = reqinfo->updt_id, slr.updt_cnt = 0, slr.updt_task = reqinfo->updt_task,
      slr.info_sch_text_id = 0.0, slr.mnemonic = "", slr.mnemonic_key = "",
      slr.mnemonic_key_nls = "", slr.prompt_accept_cd = prompt_accept_cd, slr.prompt_accept_meaning
       = "DISABLE",
      slr.role_type_cd = role_type_cd, slr.role_type_meaning = "RESLIST", slr.sch_flex_id = 0.0,
      slr.selected_ind = 1
     WITH nocounter
    ;end insert
    FOR (res_cnt = 1 TO value(resource_rec->res_lists[list_cnt].resource_cnt))
      CALL echo("INSERTING RESOURCE")
      INSERT  FROM sch_list_res slres
       SET slres.list_role_id = resource_rec->res_lists[list_cnt].consultant_list_role_id, slres
        .resource_cd = resource_rec->res_lists[list_cnt].resources[res_cnt].resources_available_cd,
        slres.version_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"),
        slres.pref_ind = 0, slres.search_seq = 0, slres.display_seq = (res_cnt - 1),
        slres.null_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), slres.candidate_id = seq(
         sch_candidate_seq,nextval), slres.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        slres.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), slres.active_ind = 1, slres
        .active_status_cd = active_cd,
        slres.active_status_dt_tm = cnvtdatetime(curdate,curtime3), slres.active_status_prsnl_id =
        reqinfo->updt_id, slres.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        slres.updt_applctx = reqinfo->updt_applctx, slres.updt_id = reqinfo->updt_id, slres.updt_cnt
         = 0,
        slres.updt_task = reqinfo->updt_task, slres.selected_ind = 1, slres.res_sch_cd = res_sch_cd,
        slres.res_sch_meaning = "SCHEDULE", slres.sch_flex_id = resource_rec->res_lists[list_cnt].
        resources[res_cnt].resource_flex_string_cd
       WITH nocounter
      ;end insert
      FOR (slot_count = 1 TO value(resource_rec->res_lists[list_cnt].resources[res_cnt].slot_cnt))
       IF ((resource_rec->res_lists[list_cnt].resources[res_cnt].slots[slot_count].procedure_duration
       =0))
        SELECT INTO "nl:"
         FROM sch_slot_type sst
         PLAN (sst
          WHERE (sst.slot_type_id=resource_rec->res_lists[list_cnt].resources[res_cnt].slots[
          slot_count].slot_name_cd)
           AND sst.active_ind=1)
         DETAIL
          resource_rec->res_lists[list_cnt].resources[res_cnt].slots[slot_count].procedure_duration
           = sst.def_duration
         WITH nocounter
        ;end select
       ENDIF
       INSERT  FROM sch_list_slot sls
        SET sls.list_role_id = resource_rec->res_lists[list_cnt].consultant_list_role_id, sls
         .resource_cd = resource_rec->res_lists[list_cnt].resources[res_cnt].resources_available_cd,
         sls.slot_type_id = resource_rec->res_lists[list_cnt].resources[res_cnt].slots[slot_count].
         slot_name_cd,
         sls.version_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), sls.setup_units = 0, sls
         .setup_units_cd = minutes_cd,
         sls.setup_units_meaning = "MINUTES", sls.setup_role_id = 0.0, sls.duration_units =
         resource_rec->res_lists[list_cnt].resources[res_cnt].slots[slot_count].procedure_duration,
         sls.duration_role_id = 0.0, sls.duration_units_cd = minutes_cd, sls.duration_units_meaning
          = "MINUTES",
         sls.cleanup_units = 0, sls.cleanup_units_cd = minutes_cd, sls.cleanup_units_meaning =
         "MINUTES",
         sls.cleanup_role_id = 0.0, sls.offset_type_cd = offset_type_cd, sls.offset_type_meaning =
         "BEG",
         sls.offset_role_id = 0.0, sls.offset_beg_units = 0, sls.offset_beg_units_cd = minutes_cd,
         sls.offset_beg_units_meaning = "MINUTES", sls.offset_end_units = 0, sls.offset_end_units_cd
          = minutes_cd,
         sls.offset_end_units_meaning = "MINUTES", sls.display_seq = (slot_count - 1), sls.search_seq
          = 0,
         sls.null_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), sls.candidate_id = seq(
          sch_candidate_seq,nextval), sls.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
         sls.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), sls.active_ind = 1, sls
         .active_status_cd = active_cd,
         sls.active_status_dt_tm = cnvtdatetime(curdate,curtime3), sls.active_status_prsnl_id =
         reqinfo->updt_id, sls.updt_dt_tm = cnvtdatetime(curdate,curtime3),
         sls.updt_applctx = reqinfo->updt_applctx, sls.updt_id = reqinfo->updt_id, sls.updt_cnt = 0,
         sls.updt_task = reqinfo->updt_task, sls.sch_flex_id = 0.0, sls.selected_ind = 1
        WITH nocounter
       ;end insert
      ENDFOR
    ENDFOR
    INSERT  FROM sch_list_res slres
     SET slres.list_role_id = resource_rec->res_lists[list_cnt].patient_list_role_id, slres
      .resource_cd = 0.0, slres.version_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"),
      slres.pref_ind = 0, slres.search_seq = 0, slres.display_seq = resource_rec->res_lists[list_cnt]
      .resource_cnt,
      slres.null_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), slres.candidate_id = seq(
       sch_candidate_seq,nextval), slres.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      slres.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), slres.active_ind = 1, slres
      .active_status_cd = active_cd,
      slres.active_status_dt_tm = cnvtdatetime(curdate,curtime3), slres.active_status_prsnl_id =
      reqinfo->updt_id, slres.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      slres.updt_applctx = reqinfo->updt_applctx, slres.updt_id = reqinfo->updt_id, slres.updt_cnt =
      0,
      slres.updt_task = reqinfo->updt_task, slres.selected_ind = 1, slres.res_sch_cd = res_sch_cd,
      slres.res_sch_meaning = "SCHEDULE", slres.sch_flex_id = 0.0
     WITH nocounter
    ;end insert
    INSERT  FROM sch_list_slot sls
     SET sls.list_role_id = resource_rec->res_lists[list_cnt].patient_list_role_id, sls.resource_cd
       = 0.0, sls.slot_type_id = 0.0,
      sls.version_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), sls.setup_units = 0, sls
      .setup_units_cd = minutes_cd,
      sls.setup_units_meaning = "MINUTES", sls.setup_role_id = 0.0, sls.duration_role_id =
      resource_rec->res_lists[list_cnt].consultant_list_role_id,
      sls.duration_units = 0, sls.duration_units_cd = minutes_cd, sls.duration_units_meaning =
      "MINUTES",
      sls.cleanup_units = 0, sls.cleanup_units_cd = minutes_cd, sls.cleanup_units_meaning = "MINUTES",
      sls.cleanup_role_id = 0.0, sls.offset_type_cd = offset_type_cd, sls.offset_type_meaning = "BEG",
      sls.offset_role_id = resource_rec->res_lists[list_cnt].consultant_list_role_id, sls
      .offset_beg_units = 0, sls.offset_beg_units_cd = minutes_cd,
      sls.offset_beg_units_meaning = "MINUTES", sls.offset_end_units = 0, sls.offset_end_units_cd =
      minutes_cd,
      sls.offset_end_units_meaning = "MINUTES", sls.display_seq = 0, sls.search_seq = 0,
      sls.null_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), sls.candidate_id = seq(sch_candidate_seq,
       nextval), sls.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      sls.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), sls.active_ind = 1, sls
      .active_status_cd = active_cd,
      sls.active_status_dt_tm = cnvtdatetime(curdate,curtime3), sls.active_status_prsnl_id = reqinfo
      ->updt_id, sls.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      sls.updt_applctx = reqinfo->updt_applctx, sls.updt_id = reqinfo->updt_id, sls.updt_cnt = 0,
      sls.updt_task = reqinfo->updt_task, sls.sch_flex_id = 0.0, sls.selected_ind = 1
     WITH nocounter
    ;end insert
   ENDIF
 ENDFOR
#gen_report
 SELECT INTO value(name)
  resource_list = trim(substring(1,50,resource_rec->res_lists[dt1.seq].resource_list)),
  list_action_flag = resource_rec->res_lists[dt1.seq].list_action_flag, resources_available = trim(
   substring(1,70,resource_rec->res_lists[dt1.seq].resources[dt2.seq].resources_available)),
  resource_action_flag = resource_rec->res_lists[dt1.seq].resources[dt2.seq].resource_action_flag,
  resource_flex_string = trim(substring(1,40,resource_rec->res_lists[dt1.seq].resources[dt2.seq].
    resource_flex_string)), resource_flex_string_flag = resource_rec->res_lists[dt1.seq].resources[
  dt2.seq].resource_flex_string_flag,
  resource_flex_string_size = size(resource_rec->res_lists[dt1.seq].resources[dt2.seq].
   resource_flex_string,1), slot_name = trim(substring(1,44,resource_rec->res_lists[dt1.seq].
    resources[dt2.seq].slots[dt3.seq].slot_name)), slot_action_flag = resource_rec->res_lists[dt1.seq
  ].resources[dt2.seq].slots[dt3.seq].slot_action_flag
  FROM (dummyt dt1  WITH seq = value(resource_rec->res_list_cnt)),
   (dummyt dt2  WITH seq = value(1)),
   (dummyt dt3  WITH seq = value(1))
  PLAN (dt1
   WHERE dt1.seq > 0
    AND maxrec(dt2,resource_rec->res_lists[dt1.seq].resource_cnt))
   JOIN (dt2
   WHERE dt2.seq > 0
    AND maxrec(dt3,resource_rec->res_lists[dt1.seq].resources[dt2.seq].slot_cnt))
   JOIN (dt3
   WHERE dt3.seq > 0)
  ORDER BY resource_list, resources_available, slot_name
  HEAD resource_list
   row + 1, col 1, "--------------------------------------------------------------",
   col 63, "--------------------------------------------------------------------", row + 1,
   col 2, resource_list
   IF ((list_action_flag=- (1)))
    col 97, "Error", col 107,
    "Resource List NOT Built"
   ELSE
    IF (insert_flag > 0)
     col 97, "Added"
    ELSE
     col 97, "Validated"
    ENDIF
   ENDIF
  HEAD resources_available
   row + 1, col 22, resources_available
   IF ((resource_action_flag=- (1)))
    col 97, "Error", col 107,
    "Resource NOT Found"
   ELSE
    IF ((list_action_flag=- (1)))
     col 97, "Validated"
    ENDIF
   ENDIF
   row + 1, col 22, "Resource Flex String: ",
   col 44, resource_flex_string
   IF ((resource_flex_string_flag=- (1))
    AND resource_flex_string_size > 0)
    col 81, "Flex String Not Found"
   ENDIF
  HEAD slot_name
   row + 1, col 51, slot_name
   IF ((slot_action_flag=- (1)))
    col 97, "Error", col 107,
    "Slot NOT Found"
   ELSE
    IF ((list_action_flag=- (1)))
     col 97, "Validated"
    ENDIF
   ENDIF
  WITH nocounter, append, format = variable,
   noformfeed, maxcol = 132, maxrow = 1
 ;end select
 SUBROUTINE logstart(xtitle,xname)
   DECLARE dir_name = vc
   SET dir_name = "ccluserdir:"
   SET log_name = concat(trim(dir_name),xname)
   SET logvar = 0
   SELECT INTO value(log_name)
    logvar
    HEAD REPORT
     begin_dt_tm"dd-mmm-yyyy;;d", "-", begin_dt_tm"hh:mm:ss;;m",
     col + 1, xtitle, row + 1
    DETAIL
     row + 2, col 2, "Resource List",
     col 22, "Resource", col 51,
     "Slot Name", col 97, "Status",
     col 107, "Error"
    WITH nocounter, format = variable, noformfeed,
     maxcol = 132, maxrow = 1
   ;end select
   RETURN
 END ;Subroutine
 SUBROUTINE get_code_value(xcodeset,xcdf)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND c.cdf_meaning=xcdf)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
 CALL echo(".......................................................................... ")
 CALL echo(">> The log file is named resource_list_upload.log and is in ccluserdir. <<")
 CALL echo(".......................................................................... ")
#exit_script
END GO
