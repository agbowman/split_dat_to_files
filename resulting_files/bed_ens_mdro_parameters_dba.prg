CREATE PROGRAM bed_ens_mdro_parameters:dba
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 DECLARE e_parse = vc
 DECLARE o_parse = vc
 SET e_parse = build2("cat_e.event_cd = ",request->mdro_code_value)
 SET o_parse = build2("cat_o.organism_cd = ",request->mdro_code_value)
 IF (validate(request->facility_code_value))
  SET e_parse = build2(e_parse," and cat_e.location_cd = ")
  SET e_parse = build2(e_parse,request->facility_code_value)
  SET o_parse = build2(o_parse," and cat_o.location_cd = ")
  SET o_parse = build2(o_parse,request->facility_code_value)
 ENDIF
 IF ((request->action_flag=3))
  IF ((request->mdro_type_ind=1))
   SET mdro_exists = 0.0
   SELECT INTO "nl:"
    FROM br_mdro_cat_event cat_e,
     br_mdro_cat cat
    PLAN (cat_e
     WHERE parser(e_parse))
     JOIN (cat
     WHERE cat.br_mdro_cat_id=cat_e.br_mdro_cat_id
      AND (cat.cat_type_flag=request->category_type_ind))
    DETAIL
     mdro_exists = cat_e.br_mdro_cat_event_id
    WITH nocounter
   ;end select
   IF (mdro_exists > 0.0)
    SET ierrcode = 0
    DELETE  FROM br_cat_event_normalcy cen
     PLAN (cen
      WHERE cen.br_mdro_cat_event_id=mdro_exists)
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat(
      "Error on Deleting Event code normalcy information")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    DELETE  FROM br_mdro_cat_event cat_e
     PLAN (cat_e
      WHERE cat_e.br_mdro_cat_event_id=mdro_exists)
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat(
      "Error on Delete Event Code - Category information")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
  ELSEIF ((request->mdro_type_ind=2))
   SET mdro_exists = 0.0
   SET br_mdro_cat_organism_id = 0.0
   SET grp_nbr = 0
   SELECT INTO "nl:"
    FROM br_mdro_cat_organism cat_o,
     br_mdro_cat cat
    PLAN (cat_o
     WHERE parser(o_parse))
     JOIN (cat
     WHERE cat.br_mdro_cat_id=cat_o.br_mdro_cat_id
      AND (cat.cat_type_flag=request->category_type_ind))
    DETAIL
     mdro_exists = cat_o.br_mdro_cat_organism_id, grp_nbr = cat_o.group_resistant_cnt
    WITH nocounter
   ;end select
   IF (mdro_exists > 0.0)
    IF (grp_nbr > 0)
     CALL echo(build("mdro_exists",mdro_exists))
     SET ierrcode = 0
     DELETE  FROM br_drug_group_organism dgo
      PLAN (dgo
       WHERE dgo.br_drug_group_organism_id=mdro_exists)
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname = concat(
       "Error on Deleting Organism Drug Groups")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
     SET ierrcode = 0
     DELETE  FROM br_cat_organism_interp int
      PLAN (int
       WHERE int.br_mdro_cat_organism_id=mdro_exists)
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname = concat(
       "Error on Deleting Organism Interpretation Results")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
    ENDIF
    SET ierrcode = 0
    DELETE  FROM br_mdro_cat_organism cat_o
     PLAN (cat_o
      WHERE cat_o.br_mdro_cat_organism_id=mdro_exists)
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat(
      "Error on Deleting Organism - Category information",trim(cnvtstring(request->details[ii].
        alias_pool_code_value)),".")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 IF ((request->category_name > " "))
  SET cat_id = 0.0
  SELECT INTO "nl:"
   FROM br_mdro_cat cat
   PLAN (cat
    WHERE (cat.cat_type_flag=request->category_type_ind)
     AND (cat.mdro_cat_name=request->category_name))
   DETAIL
    cat_id = cat.br_mdro_cat_id
   WITH nocounter
  ;end select
  IF (cat_id=0.0)
   SELECT INTO "nl:"
    temp = seq(bedrock_seq,nextval)
    FROM dual
    DETAIL
     cat_id = cnvtreal(temp)
    WITH nocounter
   ;end select
   SET ierrcode = 0
   INSERT  FROM br_mdro_cat cat
    SET cat.br_mdro_cat_id = cat_id, cat.mdro_cat_name = request->category_name, cat.cat_type_flag =
     request->category_type_ind,
     cat.updt_cnt = 0, cat.updt_id = reqinfo->updt_id, cat.updt_dt_tm = cnvtdatetime(curdate,curtime),
     cat.updt_task = reqinfo->updt_task, cat.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].targetobjectname = concat(
     "Error on Inserting New Category:",trim(request->category_name),".")
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    GO TO exit_script
   ENDIF
  ENDIF
  IF ((request->mdro_type_ind=1))
   SET mdro_exists = 0.0
   SELECT INTO "nl:"
    FROM br_mdro_cat_event cat_e,
     br_mdro_cat cat
    PLAN (cat_e
     WHERE parser(e_parse))
     JOIN (cat
     WHERE cat.br_mdro_cat_id=cat_e.br_mdro_cat_id
      AND (cat.cat_type_flag=request->category_type_ind))
    DETAIL
     mdro_exists = cat_e.br_mdro_cat_event_id
    WITH nocounter
   ;end select
   IF (mdro_exists > 0.0)
    SET ierrcode = 0
    DELETE  FROM br_cat_event_normalcy cen
     PLAN (cen
      WHERE cen.br_mdro_cat_event_id=mdro_exists)
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = "Error on Inserting New Category"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    DELETE  FROM br_mdro_cat_event cat_e
     PLAN (cat_e
      WHERE cat_e.br_mdro_cat_event_id=mdro_exists)
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = "Error on Inserting New Category"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
   SET cat_e_id = 0.0
   SELECT INTO "nl:"
    temp = seq(bedrock_seq,nextval)
    FROM dual
    DETAIL
     cat_e_id = cnvtreal(temp)
    WITH nocounter
   ;end select
   SET ierrcode = 0
   IF (validate(request->facility_code_value))
    INSERT  FROM br_mdro_cat_event cat_e
     SET cat_e.br_mdro_cat_event_id = cat_e_id, cat_e.event_cd = request->mdro_code_value, cat_e
      .location_cd = request->facility_code_value,
      cat_e.br_mdro_cat_id = cat_id, cat_e.updt_cnt = 0, cat_e.updt_id = reqinfo->updt_id,
      cat_e.updt_dt_tm = cnvtdatetime(curdate,curtime), cat_e.updt_task = reqinfo->updt_task, cat_e
      .updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat(
      "Error on Inserting Category for the Serology Results/Event code:",trim(cnvtstring(request->
        mdro_code_value)),".")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ELSE
    INSERT  FROM br_mdro_cat_event cat_e
     SET cat_e.br_mdro_cat_event_id = cat_e_id, cat_e.event_cd = request->mdro_code_value, cat_e
      .br_mdro_cat_id = cat_id,
      cat_e.updt_cnt = 0, cat_e.updt_id = reqinfo->updt_id, cat_e.updt_dt_tm = cnvtdatetime(curdate,
       curtime),
      cat_e.updt_task = reqinfo->updt_task, cat_e.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat(
      "Error on Inserting Category for the Serology Results/Event code:",trim(cnvtstring(request->
        mdro_code_value)),".")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
   SET ecnt = size(request->normalcy_codes,5)
   FOR (a = 1 TO ecnt)
     SET cen_id = 0.0
     SELECT INTO "nl:"
      temp = seq(bedrock_seq,nextval)
      FROM dual
      DETAIL
       cen_id = cnvtreal(temp)
      WITH nocounter
     ;end select
     SET ierrcode = 0
     INSERT  FROM br_cat_event_normalcy cen
      SET cen.br_cat_event_normalcy_id = cen_id, cen.br_mdro_cat_event_id = cat_e_id, cen.normalcy_cd
        = request->normalcy_codes[a].normalcy_code_value,
       cen.updt_cnt = 0, cen.updt_id = reqinfo->updt_id, cen.updt_dt_tm = cnvtdatetime(curdate,
        curtime),
       cen.updt_task = reqinfo->updt_task, cen.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname = concat(
       "Error on Inserting normalcy codes for the Serology Results/Event code:",trim(cnvtstring(
         request->mdro_code_value)),".")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
   ENDFOR
  ELSEIF ((request->mdro_type_ind=2))
   SET mdro_exists = 0.0
   SET br_mdro_cat_organism_id = 0.0
   SET grp_nbr = 0
   SELECT INTO "nl:"
    FROM br_mdro_cat_organism cat_o,
     br_mdro_cat cat
    PLAN (cat_o
     WHERE parser(o_parse))
     JOIN (cat
     WHERE cat.br_mdro_cat_id=cat_o.br_mdro_cat_id
      AND (cat.cat_type_flag=request->category_type_ind))
    DETAIL
     mdro_exists = cat_o.br_mdro_cat_organism_id, grp_nbr = cat_o.group_resistant_cnt
    WITH nocounter
   ;end select
   IF (mdro_exists > 0.0)
    IF (grp_nbr > 0)
     SET ierrcode = 0
     DELETE  FROM br_cat_organism_interp int
      PLAN (int
       WHERE int.br_mdro_cat_organism_id=mdro_exists)
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname =
      "Error on Deleting Organism Interpretation Results"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
     SET ierrcode = 0
     DELETE  FROM br_drug_group_organism dgo
      PLAN (dgo
       WHERE dgo.br_mdro_cat_organism_id=mdro_exists)
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname = "Error on Inserting New Category"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
    ENDIF
    SET ierrcode = 0
    DELETE  FROM br_mdro_cat_organism cat_o
     PLAN (cat_o
      WHERE cat_o.br_mdro_cat_organism_id=mdro_exists
       AND parser(o_parse))
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname =
     "Error on Deleting Organism - Category Relation"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
   SET cat_o_id = 0.0
   SELECT INTO "nl:"
    temp = seq(bedrock_seq,nextval)
    FROM dual
    DETAIL
     cat_o_id = cnvtreal(temp)
    WITH nocounter
   ;end select
   SET ierrcode = 0
   IF (validate(request->facility_code_value))
    INSERT  FROM br_mdro_cat_organism cat_o
     SET cat_o.br_mdro_cat_organism_id = cat_o_id, cat_o.organism_cd = request->mdro_code_value,
      cat_o.location_cd = request->facility_code_value,
      cat_o.br_mdro_cat_id = cat_id, cat_o.group_resistant_cnt = request->group_resistant_nbr, cat_o
      .updt_cnt = 0,
      cat_o.updt_id = reqinfo->updt_id, cat_o.updt_dt_tm = cnvtdatetime(curdate,curtime), cat_o
      .updt_task = reqinfo->updt_task,
      cat_o.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat(
      "Error on Inserting Cat for the organism:",trim(cnvtstring(request->mdro_code_value)),".")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ELSE
    INSERT  FROM br_mdro_cat_organism cat_o
     SET cat_o.br_mdro_cat_organism_id = cat_o_id, cat_o.organism_cd = request->mdro_code_value,
      cat_o.br_mdro_cat_id = cat_id,
      cat_o.group_resistant_cnt = request->group_resistant_nbr, cat_o.updt_cnt = 0, cat_o.updt_id =
      reqinfo->updt_id,
      cat_o.updt_dt_tm = cnvtdatetime(curdate,curtime), cat_o.updt_task = reqinfo->updt_task, cat_o
      .updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat(
      "Error on Inserting Cat for the organism:",trim(cnvtstring(request->mdro_code_value)),".")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
   IF ((request->group_resistant_nbr > 0))
    SET dgcnt = size(request->drug_groups,5)
    FOR (x = 1 TO dgcnt)
      SET dgo_id = 0.0
      SELECT INTO "nl:"
       temp = seq(bedrock_seq,nextval)
       FROM dual
       DETAIL
        dgo_id = cnvtreal(temp)
       WITH nocounter
      ;end select
      SET ierrcode = 0
      INSERT  FROM br_drug_group_organism dgo
       SET dgo.br_drug_group_organism_id = dgo_id, dgo.br_mdro_cat_organism_id = cat_o_id, dgo
        .br_drug_group_id = request->drug_groups[x].drg_grp_id,
        dgo.drug_resistant_cnt = request->drug_groups[x].drug_resistant_nbr, dgo.updt_cnt = 0, dgo
        .updt_id = reqinfo->updt_id,
        dgo.updt_dt_tm = cnvtdatetime(curdate,curtime), dgo.updt_task = reqinfo->updt_task, dgo
        .updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET reply->status_data.subeventstatus[1].targetobjectname = concat(
        "Error on Inserting Drug groups for the Organism:",trim(cnvtstring(request->mdro_code_value)),
        ".")
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
       GO TO exit_script
      ENDIF
      SET dcnt = size(request->drug_groups[x].drugs,5)
      FOR (y = 1 TO dcnt)
       SET icnt = size(request->drug_groups[x].drugs[y].interp_results,5)
       FOR (z = 1 TO icnt)
         SET int_id = 0.0
         SELECT INTO "nl:"
          temp = seq(bedrock_seq,nextval)
          FROM dual
          DETAIL
           int_id = cnvtreal(temp)
          WITH nocounter
         ;end select
         SET ierrcode = 0
         INSERT  FROM br_cat_organism_interp int
          SET int.br_cat_organism_interp_id = int_id, int.br_mdro_cat_organism_id = cat_o_id, int
           .antibiotic_cd = request->drug_groups[x].drugs[y].drug_code_value,
           int.interp_result_cd = request->drug_groups[x].drugs[y].interp_results[z].
           interp_code_value, int.updt_cnt = 0, int.updt_id = reqinfo->updt_id,
           int.updt_dt_tm = cnvtdatetime(curdate,curtime), int.updt_task = reqinfo->updt_task, int
           .updt_applctx = reqinfo->updt_applctx
          WITH nocounter
         ;end insert
         SET ierrcode = error(serrmsg,1)
         IF (ierrcode > 0)
          SET error_flag = "Y"
          SET reply->status_data.subeventstatus[1].targetobjectname = concat(
           "Error on Inserting Interpretation Results for the Organism:",trim(cnvtstring(request->
             mdro_code_value)),".")
          SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
          GO TO exit_script
         ENDIF
       ENDFOR
      ENDFOR
    ENDFOR
   ENDIF
  ENDIF
 ENDIF
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
