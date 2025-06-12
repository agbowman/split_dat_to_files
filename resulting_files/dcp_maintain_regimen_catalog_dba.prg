CREATE PROGRAM dcp_maintain_regimen_catalog:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD maintainrelations
 RECORD maintainrelations(
   1 idx = i4
   1 size = i4
   1 list[*]
     2 regimen_cat_detail_r_id = f8
     2 regimen_cat_detail_s_id = f8
     2 regimen_cat_detail_t_id = f8
     2 type_mean = c12
     2 offset_value = f8
     2 offset_unit_cd = f8
     2 action_type = i2
 )
 DECLARE regimen_cnt = i4 WITH constant(value(size(request->regimenlist,5))), protect
 DECLARE end_date_string = c20 WITH constant("31-DEC-2100 00:00:00"), protect
 DECLARE action_create = i2 WITH constant(1), protect
 DECLARE action_update = i2 WITH constant(2), protect
 DECLARE action_remove = i2 WITH constant(3), protect
 DECLARE cfailed = c1 WITH noconstant("F"), protect
 DECLARE regidx = i4 WITH noconstant(1), protect
 DECLARE elemidx = i4 WITH noconstant(1), protect
 DECLARE elemcnt = i4 WITH noconstant(1), protect
 DECLARE synidx = i4 WITH noconstant(1), protect
 DECLARE syncnt = i4 WITH noconstant(1), protect
 DECLARE primaryind = i2 WITH noconstant(1), protect
 DECLARE facidx = i4 WITH noconstant(1), protect
 DECLARE faccnt = i4 WITH noconstant(1), protect
 DECLARE attridx = i4 WITH noconstant(1), protect
 DECLARE attrcnt = i4 WITH noconstant(1), protect
 DECLARE rltnidx = i4 WITH noconstant(1), protect
 DECLARE rltncnt = i4 WITH noconstant(1), protect
 DECLARE denddate = dq8
 DECLARE dnextseqnum = f8 WITH noconstant(0.0), protect
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 FOR (regidx = 1 TO regimen_cnt)
   IF ((request->regimenlist[regidx].active_ind=0))
    SET denddate = cnvtdatetime(curdate,curtime3)
   ELSE
    SET denddate = cnvtdatetime(end_date_string)
   ENDIF
   IF ((request->regimenlist[regidx].action_type=action_create))
    INSERT  FROM regimen_catalog rc
     SET rc.active_ind = request->regimenlist[regidx].active_ind, rc.extend_treatment_ind = request->
      regimenlist[regidx].extend_treatment_ind, rc.add_plan_ind = request->regimenlist[regidx].
      add_plan_ind,
      rc.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), rc.end_effective_dt_tm = cnvtdatetime(
       denddate), rc.group_regimen_catalog_id = request->regimenlist[regidx].catalog_id,
      rc.regimen_catalog_id = request->regimenlist[regidx].catalog_id, rc.regimen_description =
      request->regimenlist[regidx].description, rc.regimen_name = request->regimenlist[regidx].name,
      rc.regimen_name_key = cnvtupper(trim(request->regimenlist[regidx].name,3)), rc.updt_applctx =
      reqinfo->updt_applctx, rc.updt_cnt = 0,
      rc.updt_dt_tm = cnvtdatetime(curdate,curtime3), rc.updt_id = reqinfo->updt_id, rc.updt_task =
      reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL report_failure("INSERT","F","REGIMEN_CATALOG",build(
       "Unable to insert into regimen_catalog, regimen_catalog_id=",request->regimenlist[regidx].
       catalog_id))
     GO TO exit_script
    ENDIF
   ELSEIF ((request->regimenlist[regidx].action_type=action_update))
    SELECT INTO "nl:"
     FROM regimen_catalog rc
     WHERE (rc.regimen_catalog_id=request->regimenlist[regidx].catalog_id)
      AND (rc.updt_cnt=request->regimenlist[regidx].updt_cnt)
     WITH nocounter, forupdate(rc)
    ;end select
    IF (curqual=0)
     CALL report_failure("SELECT","F","REGIMEN_CATALOG",build(
       "Unable to lock row for regimen_catalog_id=",request->regimenlist[regidx].catalog_id))
     GO TO exit_script
    ENDIF
    UPDATE  FROM regimen_catalog rc
     SET rc.active_ind = request->regimenlist[regidx].active_ind, rc.extend_treatment_ind = request->
      regimenlist[regidx].extend_treatment_ind, rc.add_plan_ind = request->regimenlist[regidx].
      add_plan_ind,
      rc.end_effective_dt_tm = cnvtdatetime(denddate), rc.regimen_description = request->regimenlist[
      regidx].description, rc.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      rc.updt_applctx = reqinfo->updt_applctx, rc.updt_cnt = (rc.updt_cnt+ 1), rc.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      rc.updt_id = reqinfo->updt_id, rc.updt_task = reqinfo->updt_task
     WHERE (rc.regimen_catalog_id=request->regimenlist[regidx].catalog_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     CALL report_failure("UPDATE","F","REGIMEN_CATALOG",build(
       "Unable to update into regimen_catalog for regimen_catalog_id=",request->regimenlist[regidx].
       catalog_id))
     GO TO exit_script
    ENDIF
   ENDIF
   SET elemcnt = size(request->regimenlist[regidx].elementlist,5)
   SET maintainrelations->idx = 0
   SET maintainrelations->size = 0
   FOR (elemidx = 1 TO elemcnt)
    SET rltncnt = size(request->regimenlist[regidx].elementlist[elemidx].relationlist,5)
    FOR (rltnidx = 1 TO rltncnt)
      IF ((request->regimenlist[regidx].elementlist[elemidx].relationlist[rltnidx].action_type IN (
      action_create, action_update)))
       SET maintainrelations->idx = (maintainrelations->idx+ 1)
       IF ((maintainrelations->idx > maintainrelations->size))
        SET maintainrelations->size = (maintainrelations->size+ 10)
        SET stat = alterlist(maintainrelations->list,maintainrelations->size)
       ENDIF
       SET maintainrelations->list[maintainrelations->idx].regimen_cat_detail_r_id = request->
       regimenlist[regidx].elementlist[elemidx].relationlist[rltnidx].regimen_cat_detail_r_id
       SET maintainrelations->list[maintainrelations->idx].regimen_cat_detail_s_id = request->
       regimenlist[regidx].elementlist[elemidx].relationlist[rltnidx].source_element_cat_id
       SET maintainrelations->list[maintainrelations->idx].regimen_cat_detail_t_id = request->
       regimenlist[regidx].elementlist[elemidx].cat_detail_id
       SET maintainrelations->list[maintainrelations->idx].type_mean = request->regimenlist[regidx].
       elementlist[elemidx].relationlist[rltnidx].type_mean
       SET maintainrelations->list[maintainrelations->idx].offset_value = request->regimenlist[regidx
       ].elementlist[elemidx].relationlist[rltnidx].offset_quantity
       SET maintainrelations->list[maintainrelations->idx].offset_unit_cd = request->regimenlist[
       regidx].elementlist[elemidx].relationlist[rltnidx].offset_unit_cd
       SET maintainrelations->list[maintainrelations->idx].action_type = request->regimenlist[regidx]
       .elementlist[elemidx].relationlist[rltnidx].action_type
      ELSEIF ((request->regimenlist[regidx].elementlist[elemidx].relationlist[rltnidx].action_type=
      action_remove))
       DELETE  FROM regimen_cat_detail_r rcdr
        WHERE (rcdr.regimen_cat_detail_r_id=request->regimenlist[regidx].elementlist[elemidx].
        relationlist[rltnidx].regimen_cat_detail_r_id)
        WITH nocounter
       ;end delete
       IF (curqual=0)
        CALL report_failure("DELETE","F","REGIMEN_CAT_DETAIL_R",build(
          "Unable to delete from regimen_cat_detail_r, regimen_cat_detail_r_id=",request->
          regimenlist[regidx].elementlist[elemidx].relationlist[rltnidx].regimen_cat_detail_r_id))
        GO TO exit_script
       ENDIF
      ENDIF
    ENDFOR
   ENDFOR
   SET maintainrelations->size = maintainrelations->idx
   SET stat = alterlist(maintainrelations->list,maintainrelations->size)
   FOR (elemidx = 1 TO elemcnt)
     IF ((request->regimenlist[regidx].elementlist[elemidx].action_type=action_create))
      IF ((request->regimenlist[regidx].elementlist[elemidx].entity_name="LONG_TEXT_REFERENCE"))
       SELECT INTO "nl:"
        nextseqnum = seq(long_data_seq,nextval)
        FROM dual
        DETAIL
         dnextseqnum = cnvtreal(nextseqnum), request->regimenlist[regidx].elementlist[elemidx].
         entity_id = dnextseqnum
        WITH nocounter
       ;end select
       INSERT  FROM long_text_reference ltr
        SET ltr.long_text_id = dnextseqnum, ltr.parent_entity_name = "REGIMEN_CAT_DETAIL", ltr
         .parent_entity_id = request->regimenlist[regidx].elementlist[elemidx].cat_detail_id,
         ltr.long_text = request->regimenlist[regidx].elementlist[elemidx].note_text, ltr.updt_cnt =
         0, ltr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
         ltr.updt_id = reqinfo->updt_id, ltr.updt_task = reqinfo->updt_task, ltr.updt_applctx =
         reqinfo->updt_applctx,
         ltr.active_ind = 1, ltr.active_status_cd = reqdata->active_status_cd, ltr
         .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
         ltr.active_status_prsnl_id = reqinfo->updt_id
        WITH nocounter
       ;end insert
       IF (curqual=0)
        CALL report_failure("INSERT","F","LONG_TEXT_REFERENCE",build(
          "Unable to insert into long_text_reference, long_text_id = ",dnextseqnum))
        GO TO exit_script
       ENDIF
      ENDIF
      INSERT  FROM regimen_cat_detail rcd
       SET rcd.active_ind = 1, rcd.regimen_cat_detail_id = request->regimenlist[regidx].elementlist[
        elemidx].cat_detail_id, rcd.entity_id = request->regimenlist[regidx].elementlist[elemidx].
        entity_id,
        rcd.entity_name = request->regimenlist[regidx].elementlist[elemidx].entity_name, rcd
        .regimen_detail_sequence = request->regimenlist[regidx].elementlist[elemidx].sequence, rcd
        .regimen_catalog_id = request->regimenlist[regidx].catalog_id,
        rcd.cycle_nbr = request->regimenlist[regidx].elementlist[elemidx].cycle_nbr, rcd.updt_applctx
         = reqinfo->updt_applctx, rcd.updt_cnt = 0,
        rcd.updt_dt_tm = cnvtdatetime(curdate,curtime3), rcd.updt_id = reqinfo->updt_id, rcd
        .updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (curqual=0)
       CALL report_failure("INSERT","F","REGIMEN_CAT_DETAIL",build(
         "Unable to insert into regimen_cat_detail, regimen_cat_detail_id=",request->regimenlist[
         regidx].elementlist[elemidx].cat_detail_id))
       GO TO exit_script
      ENDIF
     ELSEIF ((request->regimenlist[regidx].elementlist[elemidx].action_type=action_update))
      IF ((request->regimenlist[regidx].elementlist[elemidx].entity_name="LONG_TEXT_REFERENCE"))
       UPDATE  FROM long_text_reference ltr
        SET ltr.long_text = request->regimenlist[regidx].elementlist[elemidx].note_text, ltr.updt_cnt
          = (ltr.updt_cnt+ 1), ltr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
         ltr.updt_id = reqinfo->updt_id, ltr.updt_task = reqinfo->updt_task, ltr.updt_applctx =
         reqinfo->updt_applctx,
         ltr.active_status_cd = reqdata->active_status_cd, ltr.active_status_dt_tm = cnvtdatetime(
          curdate,curtime3), ltr.active_status_prsnl_id = reqinfo->updt_id
        WHERE (ltr.long_text_id=request->regimenlist[regidx].elementlist[elemidx].entity_id)
        WITH nocounter
       ;end update
       IF (curqual=0)
        CALL report_failure("UPDATE","F","LONG_TEXT_REFERENCE",build(
          "Unable to update into long_text_reference, long_text_id = ",request->regimenlist[regidx].
          elementlist[elemidx].entity_id))
        GO TO exit_script
       ENDIF
      ENDIF
      UPDATE  FROM regimen_cat_detail rcd
       SET rcd.regimen_detail_sequence = request->regimenlist[regidx].elementlist[elemidx].sequence,
        rcd.cycle_nbr = request->regimenlist[regidx].elementlist[elemidx].cycle_nbr, rcd.updt_applctx
         = reqinfo->updt_applctx,
        rcd.updt_cnt = (rcd.updt_cnt+ 1), rcd.updt_dt_tm = cnvtdatetime(curdate,curtime3), rcd
        .updt_id = reqinfo->updt_id,
        rcd.updt_task = reqinfo->updt_task
       WHERE (rcd.regimen_cat_detail_id=request->regimenlist[regidx].elementlist[elemidx].
       cat_detail_id)
       WITH nocounter
      ;end update
      IF (curqual=0)
       CALL report_failure("UPDATE","F","REGIMEN_CAT_DETAIL",build(
         "Unable to update into regimen_cat_detail, regimen_cat_detail_id=",request->regimenlist[
         regidx].elementlist[elemidx].cat_detail_id))
       GO TO exit_script
      ENDIF
     ELSEIF ((request->regimenlist[regidx].elementlist[elemidx].action_type=action_remove))
      UPDATE  FROM regimen_cat_detail rcd
       SET rcd.active_ind = 0
       WHERE (rcd.regimen_cat_detail_id=request->regimenlist[regidx].elementlist[elemidx].
       cat_detail_id)
       WITH nocounter
      ;end update
      IF (curqual=0)
       CALL report_failure("DELETE","F","REGIMEN_CAT_DETAIL",build(
         "Unable to delete from regimen_cat_detail, regimen_cat_detail_id=",request->regimenlist[
         regidx].elementlist[elemidx].cat_detail_id))
       GO TO exit_script
      ENDIF
      IF ((request->regimenlist[regidx].elementlist[elemidx].entity_name="LONG_TEXT_REFERENCE"))
       UPDATE  FROM long_text_reference ltr
        SET ltr.active_ind = 0, ltr.updt_cnt = (ltr.updt_cnt+ 1), ltr.updt_dt_tm = cnvtdatetime(
          curdate,curtime3),
         ltr.updt_id = reqinfo->updt_id, ltr.updt_task = reqinfo->updt_task, ltr.updt_applctx =
         reqinfo->updt_applctx
        WHERE (ltr.long_text_id=request->regimenlist[regidx].elementlist[elemidx].entity_id)
        WITH nocounter
       ;end update
       IF (curqual=0)
        CALL report_failure("UPDATE","F","LONG_TEXT_REFERENCE",build(
          "Unable to update into long_text_reference, long_text_id = ",request->regimenlist[regidx].
          elementlist[elemidx].entity_id))
        GO TO exit_script
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   FOR (rltnidx = 1 TO maintainrelations->size)
     IF ((maintainrelations->list[rltnidx].action_type=action_create))
      INSERT  FROM regimen_cat_detail_r rcdr
       SET rcdr.regimen_cat_detail_r_id = maintainrelations->list[rltnidx].regimen_cat_detail_r_id,
        rcdr.regimen_cat_detail_s_id = maintainrelations->list[rltnidx].regimen_cat_detail_s_id, rcdr
        .regimen_cat_detail_t_id = maintainrelations->list[rltnidx].regimen_cat_detail_t_id,
        rcdr.regimen_catalog_id = request->regimenlist[regidx].catalog_id, rcdr.type_mean =
        maintainrelations->list[rltnidx].type_mean, rcdr.offset_value = maintainrelations->list[
        rltnidx].offset_value,
        rcdr.offset_unit_cd = maintainrelations->list[rltnidx].offset_unit_cd, rcdr.updt_applctx =
        reqinfo->updt_applctx, rcdr.updt_cnt = 0,
        rcdr.updt_dt_tm = cnvtdatetime(curdate,curtime3), rcdr.updt_id = reqinfo->updt_id, rcdr
        .updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (curqual=0)
       CALL report_failure("INSERT","F","REGIMEN_CAT_DETAIL_R",build(
         "Unable to insert into regimen_cat_detail_r, regimen_cat_detail_r_id=",maintainrelations->
         list[rltnidx].regimen_cat_detail_r_id))
       GO TO exit_script
      ENDIF
     ELSEIF ((maintainrelations->list[rltnidx].action_type=action_update))
      UPDATE  FROM regimen_cat_detail_r rcdr
       SET rcdr.regimen_cat_detail_s_id = maintainrelations->list[rltnidx].regimen_cat_detail_s_id,
        rcdr.offset_value = maintainrelations->list[rltnidx].offset_value, rcdr.offset_unit_cd =
        maintainrelations->list[rltnidx].offset_unit_cd,
        rcdr.updt_applctx = reqinfo->updt_applctx, rcdr.updt_cnt = (rcdr.updt_cnt+ 1), rcdr
        .updt_dt_tm = cnvtdatetime(curdate,curtime3),
        rcdr.updt_id = reqinfo->updt_id, rcdr.updt_task = reqinfo->updt_task
       WHERE (rcdr.regimen_cat_detail_r_id=maintainrelations->list[rltnidx].regimen_cat_detail_r_id)
       WITH nocounter
      ;end update
      IF (curqual=0)
       CALL report_failure("UPDATE","F","REGIMEN_CAT_DETAIL_R",build(
         "Unable to update into regimen_cat_detail_r, regimen_cat_detail_r_id=",maintainrelations->
         list[rltnidx].regimen_cat_detail_r_id))
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
   SET attrcnt = size(request->regimenlist[regidx].attributelist,5)
   FOR (attridx = 1 TO attrcnt)
    IF ((request->regimenlist[regidx].attributelist[attridx].action_type=action_create))
     INSERT  FROM regimen_cat_attribute_r rcar
      SET rcar.active_ind = 1, rcar.regimen_cat_attribute_r_id = request->regimenlist[regidx].
       attributelist[attridx].regimen_cat_attribute_r_id, rcar.regimen_cat_attribute_id = request->
       regimenlist[regidx].attributelist[attridx].regimen_cat_attribute_id,
       rcar.regimen_catalog_id = request->regimenlist[regidx].catalog_id, rcar.display_flag = request
       ->regimenlist[regidx].attributelist[attridx].display_flag, rcar.default_value_id = request->
       regimenlist[regidx].attributelist[attridx].default_value_id,
       rcar.default_value_name = request->regimenlist[regidx].attributelist[attridx].
       default_value_name, rcar.sequence = request->regimenlist[regidx].attributelist[attridx].
       sequence, rcar.updt_applctx = reqinfo->updt_applctx,
       rcar.updt_cnt = 0, rcar.updt_dt_tm = cnvtdatetime(curdate,curtime3), rcar.updt_id = reqinfo->
       updt_id,
       rcar.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      CALL report_failure("INSERT","F","REGIMEN_CAT_ATTRIBUTE_R",build(
        "Unable to insert into regimen_cat_attribute_r, regimen_cat_attribute_r_id=",request->
        regimenlist[regidx].attributelist[attridx].regimen_cat_attribute_r_id))
      GO TO exit_script
     ENDIF
    ELSEIF ((request->regimenlist[regidx].attributelist[attridx].action_type=action_update))
     UPDATE  FROM regimen_cat_attribute_r rcar
      SET rcar.display_flag = request->regimenlist[regidx].attributelist[attridx].display_flag, rcar
       .default_value_id = request->regimenlist[regidx].attributelist[attridx].default_value_id, rcar
       .default_value_name = request->regimenlist[regidx].attributelist[attridx].default_value_name,
       rcar.sequence = request->regimenlist[regidx].attributelist[attridx].sequence, rcar
       .updt_applctx = reqinfo->updt_applctx, rcar.updt_cnt = (rcar.updt_cnt+ 1),
       rcar.updt_dt_tm = cnvtdatetime(curdate,curtime3), rcar.updt_id = reqinfo->updt_id, rcar
       .updt_task = reqinfo->updt_task
      WHERE (rcar.regimen_cat_attribute_r_id=request->regimenlist[regidx].attributelist[attridx].
      regimen_cat_attribute_r_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      CALL report_failure("UPDATE","F","REGIMEN_CAT_ATTRIBUTE_R",build(
        "Unable to update into regimen_cat_attribute_r, regimen_cat_attribute_r_id=",request->
        regimenlist[regidx].attributelist[attridx].regimen_cat_attribute_r_id))
      GO TO exit_script
     ENDIF
    ELSEIF ((request->regimenlist[regidx].attributelist[attridx].action_type=action_remove))
     UPDATE  FROM regimen_cat_attribute_r rcar
      SET rcar.active_ind = 0
      WHERE (rcar.regimen_cat_attribute_r_id=request->regimenlist[regidx].attributelist[attridx].
      regimen_cat_attribute_r_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      CALL report_failure("DELETE","F","REGIMEN_CAT_ATTRIBUTE_R",build(
        "Unable to delete from regimen_cat_attribute_r, regimen_cat_attribute_r_id=",request->
        regimenlist[regidx].attributelist[attridx].regimen_cat_attribute_r_id))
      GO TO exit_script
     ENDIF
    ENDIF
    IF (curqual=0)
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
   ENDFOR
   SET syncnt = size(request->regimenlist[regidx].synonymlist,5)
   FOR (synidx = 1 TO syncnt)
     IF ((request->regimenlist[regidx].synonymlist[synidx].action_type=action_create))
      INSERT  FROM regimen_cat_synonym rcs
       SET rcs.regimen_cat_synonym_id = request->regimenlist[regidx].synonymlist[synidx].
        regimen_cat_synonym_id, rcs.regimen_catalog_id = request->regimenlist[regidx].catalog_id, rcs
        .primary_ind = request->regimenlist[regidx].synonymlist[synidx].primary_ind,
        rcs.synonym_display = request->regimenlist[regidx].synonymlist[synidx].display, rcs
        .synonym_key = cnvtupper(trim(request->regimenlist[regidx].synonymlist[synidx].display,3)),
        rcs.updt_applctx = reqinfo->updt_applctx,
        rcs.updt_cnt = 0, rcs.updt_dt_tm = cnvtdatetime(curdate,curtime3), rcs.updt_id = reqinfo->
        updt_id,
        rcs.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (curqual=0)
       CALL report_failure("INSERT","F","REGIMEN_CAT_SYNONYM",build(
         "Unable to insert into regimen_cat_synonym, synonym=",request->regimenlist[regidx].
         synonymlist[synidx].display))
       GO TO exit_script
      ENDIF
     ELSEIF ((request->regimenlist[regidx].synonymlist[synidx].action_type=action_update))
      UPDATE  FROM regimen_cat_synonym rcs
       SET rcs.synonym_display = request->regimenlist[regidx].synonymlist[synidx].display, rcs
        .synonym_key = cnvtupper(trim(request->regimenlist[regidx].synonymlist[synidx].display,3)),
        rcs.updt_applctx = reqinfo->updt_applctx,
        rcs.updt_cnt = (rcs.updt_cnt+ 1), rcs.updt_dt_tm = cnvtdatetime(curdate,curtime3), rcs
        .updt_id = reqinfo->updt_id,
        rcs.updt_task = reqinfo->updt_task
       WHERE (rcs.regimen_cat_synonym_id=request->regimenlist[regidx].synonymlist[synidx].
       regimen_cat_synonym_id)
       WITH nocounter
      ;end update
      IF (curqual=0)
       CALL report_failure("UPDATE","F","REGIMEN_CAT_SYNONYM",build(
         "Unable to update into regimen_cat_synonym, synonym=",request->regimenlist[regidx].
         synonymlist[synidx].display))
       GO TO exit_script
      ENDIF
     ELSEIF ((request->regimenlist[regidx].synonymlist[synidx].action_type=action_remove))
      DELETE  FROM regimen_cat_synonym rcs
       WHERE (rcs.regimen_cat_synonym_id=request->regimenlist[regidx].synonymlist[synidx].
       regimen_cat_synonym_id)
       WITH nocounter
      ;end delete
      IF (curqual=0)
       CALL report_failure("DELETE","F","REGIMEN_CAT_SYNONYM",build(
         "Unable to delete from regimen_cat_synonym, synonym=",request->regimenlist[regidx].
         synonymlist[synidx].display))
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
   IF ((request->regimenlist[regidx].action_type=action_update))
    DELETE  FROM regimen_cat_facility_r rcfr
     WHERE (rcfr.regimen_catalog_id=request->regimenlist[regidx].catalog_id)
     WITH nocounter
    ;end delete
   ENDIF
   SET faccnt = size(request->regimenlist[regidx].facilitylist,5)
   FOR (facidx = 1 TO faccnt)
    INSERT  FROM regimen_cat_facility_r rcfr
     SET rcfr.regimen_cat_facility_r_id = seq(reference_seq,nextval), rcfr.regimen_catalog_id =
      request->regimenlist[regidx].catalog_id, rcfr.location_cd = request->regimenlist[regidx].
      facilitylist[facidx].facility_cd,
      rcfr.updt_id = reqinfo->updt_id, rcfr.updt_dt_tm = cnvtdatetime(curdate,curtime3), rcfr
      .updt_task = reqinfo->updt_task,
      rcfr.updt_applctx = reqinfo->updt_applctx, rcfr.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL report_failure("INSERT","F","REGIMEN_CAT_FACILITY",build(
       "Unable to insert into regimen_cat_facility, facility_cd=",request->regimenlist[regidx].
       facilitylist[facidx].facility_cd))
     GO TO exit_script
    ENDIF
   ENDFOR
 ENDFOR
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET cfailed = "T"
   SET cnt = size(reply->status_data.subeventstatus,5)
   IF (((cnt != 1) OR (cnt=1
    AND (reply->status_data.subeventstatus[1].operationstatus != null))) )
    SET cnt = (cnt+ 1)
    SET stat = alter(reply->status_data.subeventstatus,value(cnt))
   ENDIF
   SET reply->status_data.subeventstatus[cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[cnt].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[cnt].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 IF (cfailed="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
