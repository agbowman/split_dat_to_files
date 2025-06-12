CREATE PROGRAM bed_ens_nurse_witness_parms:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 synonyms[*]
     2 id = f8
     2 groups[*]
       3 id = f8
 )
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 DECLARE brandname_cd = f8 WITH public, noconstant(0.0)
 DECLARE dcp_cd = f8 WITH public, noconstant(0.0)
 DECLARE dispdrug_cd = f8 WITH public, noconstant(0.0)
 DECLARE generictop_cd = f8 WITH public, noconstant(0.0)
 DECLARE ivname_cd = f8 WITH public, noconstant(0.0)
 DECLARE primary_cd = f8 WITH public, noconstant(0.0)
 DECLARE tradetop_cd = f8 WITH public, noconstant(0.0)
 DECLARE rxmnem_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6011
    AND cv.cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
   "PRIMARY", "TRADETOP", "RXMNEMONIC")
    AND cv.active_ind=1)
  DETAIL
   IF (cv.cdf_meaning="BRANDNAME")
    brandname_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="DCP")
    dcp_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="DISPDRUG")
    dispdrug_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="GENERICTOP")
    generictop_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="IVNAME")
    ivname_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="PRIMARY")
    primary_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="TRADETOP")
    tradetop_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="RXMNEMONIC")
    rxmnem_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 DECLARE age_range_cd = f8 WITH public, noconstant(0.0)
 DECLARE iv_event_cd = f8 WITH public, noconstant(0.0)
 DECLARE location_cd = f8 WITH public, noconstant(0.0)
 DECLARE route_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=4000047
    AND cv.cdf_meaning IN ("AGECODE", "IVEVENT", "LOCATION", "ROUTE")
    AND cv.active_ind=1)
  DETAIL
   IF (cv.cdf_meaning="AGECODE")
    age_range_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="IVEVENT")
    iv_event_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="LOCATION")
    location_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="ROUTE")
    route_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 DECLARE witnessreq_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=4000046
   AND cv.cdf_meaning="WITNESSREQ"
   AND cv.active_ind=1
  DETAIL
   witnessreq_cd = cv.code_value
  WITH nocounter
 ;end select
 DECLARE pharm_cat_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6000
   AND cv.cdf_meaning="PHARMACY"
   AND cv.active_ind=1
  DETAIL
   pharm_cat_cd = cv.code_value
  WITH nocounter
 ;end select
 DECLARE pharm_act_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=106
   AND cv.cdf_meaning="PHARMACY"
   AND cv.active_ind=1
  DETAIL
   pharm_act_cd = cv.code_value
  WITH nocounter
 ;end select
 IF ((((request->mode_ind=1)) OR ((request->mode_ind=2))) )
  IF ((request->mode_ind=1))
   DELETE  FROM ocs_attr_xcptn oax
    WHERE oax.ocs_attr_xcptn_id > 0
    WITH nocounter
   ;end delete
   UPDATE  FROM order_catalog_synonym ocs
    SET ocs.witness_flag = request->witness_default_ind, ocs.updt_dt_tm = cnvtdatetime(curdate,
      curtime3), ocs.updt_id = reqinfo->updt_id,
     ocs.updt_task = reqinfo->updt_task, ocs.updt_cnt = (ocs.updt_cnt+ 1), ocs.updt_applctx = reqinfo
     ->updt_applctx
    WHERE ocs.catalog_type_cd=pharm_cat_cd
     AND ocs.activity_type_cd=pharm_act_cd
     AND ocs.mnemonic_type_cd IN (brandname_cd, dcp_cd, dispdrug_cd, generictop_cd, ivname_cd,
    primary_cd, tradetop_cd, rxmnem_cd)
     AND ocs.hide_flag IN (0, null)
     AND ocs.active_ind=1
    WITH nocounter
   ;end update
  ELSE
   SET scnt = size(request->synonyms,5)
   IF (scnt > 0)
    DELETE  FROM (dummyt d  WITH seq = scnt),
      ocs_attr_xcptn oax
     SET oax.seq = 1
     PLAN (d)
      JOIN (oax
      WHERE (oax.synonym_id=request->synonyms[d.seq].id))
     WITH nocounter
    ;end delete
    UPDATE  FROM (dummyt d  WITH seq = scnt),
      order_catalog_synonym ocs
     SET ocs.witness_flag = request->witness_default_ind, ocs.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), ocs.updt_id = reqinfo->updt_id,
      ocs.updt_task = reqinfo->updt_task, ocs.updt_cnt = (ocs.updt_cnt+ 1), ocs.updt_applctx =
      reqinfo->updt_applctx
     PLAN (d)
      JOIN (ocs
      WHERE (ocs.synonym_id=request->synonyms[d.seq].id))
     WITH nocounter
    ;end update
   ENDIF
  ENDIF
  SET gcnt = size(request->groups,5)
  IF (gcnt > 0)
   IF ((request->mode_ind=1))
    SET scnt = 0
    SELECT INTO "NL:"
     FROM order_catalog_synonym ocs
     WHERE ocs.catalog_type_cd=pharm_cat_cd
      AND ocs.activity_type_cd=pharm_act_cd
      AND ocs.mnemonic_type_cd IN (brandname_cd, dcp_cd, dispdrug_cd, generictop_cd, ivname_cd,
     primary_cd, tradetop_cd, rxmnem_cd)
      AND ocs.hide_flag IN (0, null)
      AND ocs.active_ind=1
     DETAIL
      scnt = (scnt+ 1), stat = alterlist(temp->synonyms,scnt), temp->synonyms[scnt].id = ocs
      .synonym_id,
      stat = alterlist(temp->synonyms[scnt].groups,gcnt)
     WITH nocounter
    ;end select
   ELSE
    SET stat = alterlist(temp->synonyms,scnt)
    FOR (s = 1 TO scnt)
     SET temp->synonyms[s].id = request->synonyms[s].id
     SET stat = alterlist(temp->synonyms[s].groups,gcnt)
    ENDFOR
   ENDIF
   IF (scnt > 0)
    FOR (g = 1 TO gcnt)
      SELECT INTO "NL:"
       new_seq = seq(reference_seq,nextval)
       FROM (dummyt d  WITH seq = scnt),
        dual dl
       PLAN (d)
        JOIN (dl)
       DETAIL
        temp->synonyms[d.seq].groups[g].id = new_seq
       WITH nocounter
      ;end select
    ENDFOR
    FOR (g = 1 TO gcnt)
      IF ((request->groups[g].location_code_value=0)
       AND (request->groups[g].route_code_value=0)
       AND (request->groups[g].iv_event_code_value=0)
       AND (request->groups[g].age_range_code_value=0))
       INSERT  FROM (dummyt d  WITH seq = scnt),
         ocs_attr_xcptn oax
        SET oax.ocs_attr_xcptn_id = temp->synonyms[d.seq].groups[g].id, oax.ocs_attr_xcptn_group_id
          = temp->synonyms[d.seq].groups[g].id, oax.synonym_id = temp->synonyms[d.seq].id,
         oax.ocs_col_name_cd = witnessreq_cd, oax.flex_obj_type_cd = 0, oax.flex_obj_cd = 0,
         oax.flex_nbr_value =
         IF ((request->witness_default_ind=1)) 0
         ELSE 1
         ENDIF
         , oax.flex_str_value_txt = trim(cnvtstring(request->groups[g].facility_code_value)), oax
         .facility_cd = request->groups[g].facility_code_value,
         oax.updt_dt_tm = cnvtdatetime(curdate,curtime3), oax.updt_id = reqinfo->updt_id, oax
         .updt_task = reqinfo->updt_task,
         oax.updt_cnt = 0, oax.updt_applctx = reqinfo->updt_applctx
        PLAN (d)
         JOIN (oax)
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET error_flag = "Y"
        SET error_text = concat("Error adding ocs_attr_xcptn for synonym: ",cnvtstring(temp->
          synonyms[s].id))
       ENDIF
      ELSE
       SET first_row = 1
       IF ((request->groups[g].location_code_value > 0))
        INSERT  FROM (dummyt d  WITH seq = scnt),
          ocs_attr_xcptn oax
         SET oax.ocs_attr_xcptn_id =
          IF (first_row=1) temp->synonyms[d.seq].groups[g].id
          ELSE seq(reference_seq,nextval)
          ENDIF
          , oax.ocs_attr_xcptn_group_id = temp->synonyms[d.seq].groups[g].id, oax.synonym_id = temp->
          synonyms[d.seq].id,
          oax.ocs_col_name_cd = witnessreq_cd, oax.flex_obj_type_cd = location_cd, oax.flex_obj_cd =
          request->groups[g].location_code_value,
          oax.flex_nbr_value =
          IF ((request->witness_default_ind=1)) 0
          ELSE 1
          ENDIF
          , oax.flex_str_value_txt = trim(cnvtstring(request->groups[g].facility_code_value)), oax
          .facility_cd = request->groups[g].facility_code_value,
          oax.updt_dt_tm = cnvtdatetime(curdate,curtime3), oax.updt_id = reqinfo->updt_id, oax
          .updt_task = reqinfo->updt_task,
          oax.updt_cnt = 0, oax.updt_applctx = reqinfo->updt_applctx
         PLAN (d)
          JOIN (oax)
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET error_flag = "Y"
         SET error_text = concat("Error adding ocs_attr_xcptn for synonym: ",cnvtstring(temp->
           synonyms[s].id))
        ENDIF
        IF (first_row=1)
         SET first_row = 0
        ENDIF
       ENDIF
       IF ((request->groups[g].route_code_value > 0))
        INSERT  FROM (dummyt d  WITH seq = scnt),
          ocs_attr_xcptn oax
         SET oax.ocs_attr_xcptn_id =
          IF (first_row=1) temp->synonyms[d.seq].groups[g].id
          ELSE seq(reference_seq,nextval)
          ENDIF
          , oax.ocs_attr_xcptn_group_id = temp->synonyms[d.seq].groups[g].id, oax.synonym_id = temp->
          synonyms[d.seq].id,
          oax.ocs_col_name_cd = witnessreq_cd, oax.flex_obj_type_cd = route_cd, oax.flex_obj_cd =
          request->groups[g].route_code_value,
          oax.flex_nbr_value =
          IF ((request->witness_default_ind=1)) 0
          ELSE 1
          ENDIF
          , oax.flex_str_value_txt = trim(cnvtstring(request->groups[g].facility_code_value)), oax
          .facility_cd = request->groups[g].facility_code_value,
          oax.updt_dt_tm = cnvtdatetime(curdate,curtime3), oax.updt_id = reqinfo->updt_id, oax
          .updt_task = reqinfo->updt_task,
          oax.updt_cnt = 0, oax.updt_applctx = reqinfo->updt_applctx
         PLAN (d)
          JOIN (oax)
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET error_flag = "Y"
         SET error_text = concat("Error adding ocs_attr_xcptn for synonym: ",cnvtstring(temp->
           synonyms[s].id))
        ENDIF
        IF (first_row=1)
         SET first_row = 0
        ENDIF
       ENDIF
       IF ((request->groups[g].iv_event_code_value > 0))
        INSERT  FROM (dummyt d  WITH seq = scnt),
          ocs_attr_xcptn oax
         SET oax.ocs_attr_xcptn_id =
          IF (first_row=1) temp->synonyms[d.seq].groups[g].id
          ELSE seq(reference_seq,nextval)
          ENDIF
          , oax.ocs_attr_xcptn_group_id = temp->synonyms[d.seq].groups[g].id, oax.synonym_id = temp->
          synonyms[d.seq].id,
          oax.ocs_col_name_cd = witnessreq_cd, oax.flex_obj_type_cd = iv_event_cd, oax.flex_obj_cd =
          request->groups[g].iv_event_code_value,
          oax.flex_nbr_value =
          IF ((request->witness_default_ind=1)) 0
          ELSE 1
          ENDIF
          , oax.flex_str_value_txt = trim(cnvtstring(request->groups[g].facility_code_value)), oax
          .facility_cd = request->groups[g].facility_code_value,
          oax.updt_dt_tm = cnvtdatetime(curdate,curtime3), oax.updt_id = reqinfo->updt_id, oax
          .updt_task = reqinfo->updt_task,
          oax.updt_cnt = 0, oax.updt_applctx = reqinfo->updt_applctx
         PLAN (d)
          JOIN (oax)
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET error_flag = "Y"
         SET error_text = concat("Error adding ocs_attr_xcptn for synonym: ",cnvtstring(temp->
           synonyms[s].id))
        ENDIF
        IF (first_row=1)
         SET first_row = 0
        ENDIF
       ENDIF
       IF ((request->groups[g].age_range_code_value > 0))
        INSERT  FROM (dummyt d  WITH seq = scnt),
          ocs_attr_xcptn oax
         SET oax.ocs_attr_xcptn_id =
          IF (first_row=1) temp->synonyms[d.seq].groups[g].id
          ELSE seq(reference_seq,nextval)
          ENDIF
          , oax.ocs_attr_xcptn_group_id = temp->synonyms[d.seq].groups[g].id, oax.synonym_id = temp->
          synonyms[d.seq].id,
          oax.ocs_col_name_cd = witnessreq_cd, oax.flex_obj_type_cd = age_range_cd, oax.flex_obj_cd
           = request->groups[g].age_range_code_value,
          oax.flex_nbr_value =
          IF ((request->witness_default_ind=1)) 0
          ELSE 1
          ENDIF
          , oax.flex_str_value_txt = trim(cnvtstring(request->groups[g].facility_code_value)), oax
          .facility_cd = request->groups[g].facility_code_value,
          oax.updt_dt_tm = cnvtdatetime(curdate,curtime3), oax.updt_id = reqinfo->updt_id, oax
          .updt_task = reqinfo->updt_task,
          oax.updt_cnt = 0, oax.updt_applctx = reqinfo->updt_applctx
         PLAN (d)
          JOIN (oax)
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET error_flag = "Y"
         SET error_text = concat("Error adding ocs_attr_xcptn for synonym: ",cnvtstring(temp->
           synonyms[s].id))
        ENDIF
        IF (first_row=1)
         SET first_row = 0
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
  ENDIF
 ELSEIF ((request->mode_ind=3))
  SET scnt = size(request->synonyms,5)
  FOR (s = 1 TO scnt)
    IF ((request->synonyms[s].witness_default_action_flag=2))
     UPDATE  FROM order_catalog_synonym ocs
      SET ocs.witness_flag = request->synonyms[s].witness_default_ind, ocs.updt_dt_tm = cnvtdatetime(
        curdate,curtime3), ocs.updt_id = reqinfo->updt_id,
       ocs.updt_task = reqinfo->updt_task, ocs.updt_cnt = (ocs.updt_cnt+ 1), ocs.updt_applctx =
       reqinfo->updt_applctx
      WHERE (ocs.synonym_id=request->synonyms[s].id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_text = concat("Error updating order_catalog_synonym for synonym: ",cnvtstring(request
        ->synonyms[s].id))
     ENDIF
     UPDATE  FROM ocs_attr_xcptn oax
      SET oax.flex_nbr_value =
       IF ((request->synonyms[s].witness_default_ind=1)) 0
       ELSE 1
       ENDIF
      WHERE (oax.synonym_id=request->synonyms[s].id)
      WITH nocounter
     ;end update
    ENDIF
    SET group_id = 0.0
    SET gcnt = size(request->synonyms[s].groups,5)
    FOR (g = 1 TO gcnt)
      IF ((request->synonyms[s].groups[g].action_flag=1))
       SELECT INTO "NL:"
        new_seq = seq(reference_seq,nextval)
        FROM dual
        DETAIL
         group_id = new_seq
        WITH nocounter
       ;end select
       IF ((request->synonyms[s].groups[g].location_code_value=0)
        AND (request->synonyms[s].groups[g].route_code_value=0)
        AND (request->synonyms[s].groups[g].iv_event_code_value=0)
        AND (request->synonyms[s].groups[g].age_range_code_value=0))
        INSERT  FROM ocs_attr_xcptn oax
         SET oax.ocs_attr_xcptn_id = group_id, oax.ocs_attr_xcptn_group_id = group_id, oax.synonym_id
           = request->synonyms[s].id,
          oax.ocs_col_name_cd = witnessreq_cd, oax.flex_obj_type_cd = 0, oax.flex_obj_cd = 0,
          oax.flex_nbr_value =
          IF ((request->synonyms[s].witness_default_ind=1)) 0
          ELSE 1
          ENDIF
          , oax.flex_str_value_txt = trim(cnvtstring(request->synonyms[s].groups[g].
            facility_code_value)), oax.facility_cd = request->synonyms[s].groups[g].
          facility_code_value,
          oax.updt_dt_tm = cnvtdatetime(curdate,curtime3), oax.updt_id = reqinfo->updt_id, oax
          .updt_task = reqinfo->updt_task,
          oax.updt_cnt = 0, oax.updt_applctx = reqinfo->updt_applctx
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET error_flag = "Y"
         SET error_text = concat("Error adding ocs_attr_xcptn for synonym: ",cnvtstring(request->
           synonyms[s].id))
        ENDIF
       ELSE
        SET first_row = 1
        IF ((request->synonyms[s].groups[g].location_code_value > 0))
         INSERT  FROM ocs_attr_xcptn oax
          SET oax.ocs_attr_xcptn_id =
           IF (first_row=1) group_id
           ELSE seq(reference_seq,nextval)
           ENDIF
           , oax.ocs_attr_xcptn_group_id = group_id, oax.synonym_id = request->synonyms[s].id,
           oax.ocs_col_name_cd = witnessreq_cd, oax.flex_obj_type_cd = location_cd, oax.flex_obj_cd
            = request->synonyms[s].groups[g].location_code_value,
           oax.flex_nbr_value =
           IF ((request->synonyms[s].witness_default_ind=1)) 0
           ELSE 1
           ENDIF
           , oax.flex_str_value_txt = trim(cnvtstring(request->synonyms[s].groups[g].
             facility_code_value)), oax.facility_cd = request->synonyms[s].groups[g].
           facility_code_value,
           oax.updt_dt_tm = cnvtdatetime(curdate,curtime3), oax.updt_id = reqinfo->updt_id, oax
           .updt_task = reqinfo->updt_task,
           oax.updt_cnt = 0, oax.updt_applctx = reqinfo->updt_applctx
          WITH nocounter
         ;end insert
         IF (curqual=0)
          SET error_flag = "Y"
          SET error_text = concat("Error adding ocs_attr_xcptn for synonym: ",cnvtstring(request->
            synonyms[s].id))
         ENDIF
         IF (first_row=1)
          SET first_row = 0
         ENDIF
        ENDIF
        IF ((request->synonyms[s].groups[g].route_code_value > 0))
         INSERT  FROM ocs_attr_xcptn oax
          SET oax.ocs_attr_xcptn_id =
           IF (first_row=1) group_id
           ELSE seq(reference_seq,nextval)
           ENDIF
           , oax.ocs_attr_xcptn_group_id = group_id, oax.synonym_id = request->synonyms[s].id,
           oax.ocs_col_name_cd = witnessreq_cd, oax.flex_obj_type_cd = route_cd, oax.flex_obj_cd =
           request->synonyms[s].groups[g].route_code_value,
           oax.flex_nbr_value =
           IF ((request->synonyms[s].witness_default_ind=1)) 0
           ELSE 1
           ENDIF
           , oax.flex_str_value_txt = trim(cnvtstring(request->synonyms[s].groups[g].
             facility_code_value)), oax.facility_cd = request->synonyms[s].groups[g].
           facility_code_value,
           oax.updt_dt_tm = cnvtdatetime(curdate,curtime3), oax.updt_id = reqinfo->updt_id, oax
           .updt_task = reqinfo->updt_task,
           oax.updt_cnt = 0, oax.updt_applctx = reqinfo->updt_applctx
          WITH nocounter
         ;end insert
         IF (curqual=0)
          SET error_flag = "Y"
          SET error_text = concat("Error adding ocs_attr_xcptn for synonym: ",cnvtstring(request->
            synonyms[s].id))
         ENDIF
         IF (first_row=1)
          SET first_row = 0
         ENDIF
        ENDIF
        IF ((request->synonyms[s].groups[g].iv_event_code_value > 0))
         INSERT  FROM ocs_attr_xcptn oax
          SET oax.ocs_attr_xcptn_id =
           IF (first_row=1) group_id
           ELSE seq(reference_seq,nextval)
           ENDIF
           , oax.ocs_attr_xcptn_group_id = group_id, oax.synonym_id = request->synonyms[s].id,
           oax.ocs_col_name_cd = witnessreq_cd, oax.flex_obj_type_cd = iv_event_cd, oax.flex_obj_cd
            = request->synonyms[s].groups[g].iv_event_code_value,
           oax.flex_nbr_value =
           IF ((request->synonyms[s].witness_default_ind=1)) 0
           ELSE 1
           ENDIF
           , oax.flex_str_value_txt = trim(cnvtstring(request->synonyms[s].groups[g].
             facility_code_value)), oax.facility_cd = request->synonyms[s].groups[g].
           facility_code_value,
           oax.updt_dt_tm = cnvtdatetime(curdate,curtime3), oax.updt_id = reqinfo->updt_id, oax
           .updt_task = reqinfo->updt_task,
           oax.updt_cnt = 0, oax.updt_applctx = reqinfo->updt_applctx
          WITH nocounter
         ;end insert
         IF (curqual=0)
          SET error_flag = "Y"
          SET error_text = concat("Error adding ocs_attr_xcptn for synonym: ",cnvtstring(request->
            synonyms[s].id))
         ENDIF
         IF (first_row=1)
          SET first_row = 0
         ENDIF
        ENDIF
        IF ((request->synonyms[s].groups[g].age_range_code_value > 0))
         INSERT  FROM ocs_attr_xcptn oax
          SET oax.ocs_attr_xcptn_id =
           IF (first_row=1) group_id
           ELSE seq(reference_seq,nextval)
           ENDIF
           , oax.ocs_attr_xcptn_group_id = group_id, oax.synonym_id = request->synonyms[s].id,
           oax.ocs_col_name_cd = witnessreq_cd, oax.flex_obj_type_cd = age_range_cd, oax.flex_obj_cd
            = request->synonyms[s].groups[g].age_range_code_value,
           oax.flex_nbr_value =
           IF ((request->synonyms[s].witness_default_ind=1)) 0
           ELSE 1
           ENDIF
           , oax.flex_str_value_txt = trim(cnvtstring(request->synonyms[s].groups[g].
             facility_code_value)), oax.facility_cd = request->synonyms[s].groups[g].
           facility_code_value,
           oax.updt_dt_tm = cnvtdatetime(curdate,curtime3), oax.updt_id = reqinfo->updt_id, oax
           .updt_task = reqinfo->updt_task,
           oax.updt_cnt = 0, oax.updt_applctx = reqinfo->updt_applctx
          WITH nocounter
         ;end insert
         IF (curqual=0)
          SET error_flag = "Y"
          SET error_text = concat("Error adding ocs_attr_xcptn for synonym: ",cnvtstring(request->
            synonyms[s].id))
         ENDIF
         IF (first_row=1)
          SET first_row = 0
         ENDIF
        ENDIF
       ENDIF
      ELSEIF ((request->synonyms[s].groups[g].action_flag=2))
       SET attr_exists_ind = 0
       SELECT INTO "NL:"
        FROM ocs_attr_xcptn oax
        WHERE (oax.ocs_attr_xcptn_group_id=request->synonyms[s].groups[g].id)
         AND (oax.synonym_id=request->synonyms[s].id)
         AND oax.flex_obj_type_cd=location_cd
        DETAIL
         attr_exists_ind = 1
        WITH nocounter
       ;end select
       IF ((request->synonyms[s].groups[g].location_code_value > 0))
        IF (attr_exists_ind=1)
         UPDATE  FROM ocs_attr_xcptn oax
          SET oax.flex_obj_cd = request->synonyms[s].groups[g].location_code_value, oax.facility_cd
            = request->synonyms[s].groups[g].facility_code_value, oax.flex_str_value_txt = trim(
            cnvtstring(request->synonyms[s].groups[g].facility_code_value)),
           oax.updt_dt_tm = cnvtdatetime(curdate,curtime3), oax.updt_id = reqinfo->updt_id, oax
           .updt_task = reqinfo->updt_task,
           oax.updt_cnt = (oax.updt_cnt+ 1), oax.updt_applctx = reqinfo->updt_applctx
          WHERE (oax.ocs_attr_xcptn_group_id=request->synonyms[s].groups[g].id)
           AND (oax.synonym_id=request->synonyms[s].id)
           AND oax.flex_obj_type_cd=location_cd
          WITH nocounter
         ;end update
         IF (curqual=0)
          SET error_flag = "Y"
          SET error_text = concat("Error updating ocs_attr_xcptn for synonym: ",cnvtstring(request->
            synonyms[s].id))
         ENDIF
        ELSE
         INSERT  FROM ocs_attr_xcptn oax
          SET oax.ocs_attr_xcptn_id = seq(reference_seq,nextval), oax.ocs_attr_xcptn_group_id =
           request->synonyms[s].groups[g].id, oax.synonym_id = request->synonyms[s].id,
           oax.ocs_col_name_cd = witnessreq_cd, oax.flex_obj_type_cd = location_cd, oax.flex_obj_cd
            = request->synonyms[s].groups[g].location_code_value,
           oax.flex_nbr_value =
           IF ((request->synonyms[s].witness_default_ind=1)) 0
           ELSE 1
           ENDIF
           , oax.flex_str_value_txt = trim(cnvtstring(request->synonyms[s].groups[g].
             facility_code_value)), oax.facility_cd = request->synonyms[s].groups[g].
           facility_code_value,
           oax.updt_dt_tm = cnvtdatetime(curdate,curtime3), oax.updt_id = reqinfo->updt_id, oax
           .updt_task = reqinfo->updt_task,
           oax.updt_cnt = 0, oax.updt_applctx = reqinfo->updt_applctx
          WITH nocounter
         ;end insert
         IF (curqual=0)
          SET error_flag = "Y"
          SET error_text = concat("Error adding ocs_attr_xcptn for synonym: ",cnvtstring(request->
            synonyms[s].id))
         ENDIF
        ENDIF
       ELSE
        IF (attr_exists_ind=1)
         DELETE  FROM ocs_attr_xcptn oax
          WHERE (oax.ocs_attr_xcptn_group_id=request->synonyms[s].groups[g].id)
           AND (oax.synonym_id=request->synonyms[s].id)
           AND oax.flex_obj_type_cd=location_cd
          WITH nocounter
         ;end delete
         IF (curqual=0)
          SET error_flag = "Y"
          SET error_text = concat("Error deleting ocs_attr_xcptn for synonym: ",cnvtstring(request->
            synonyms[s].id))
         ENDIF
        ENDIF
       ENDIF
       SET attr_exists_ind = 0
       SELECT INTO "NL:"
        FROM ocs_attr_xcptn oax
        WHERE (oax.ocs_attr_xcptn_group_id=request->synonyms[s].groups[g].id)
         AND (oax.synonym_id=request->synonyms[s].id)
         AND oax.flex_obj_type_cd=route_cd
        DETAIL
         attr_exists_ind = 1
        WITH nocounter
       ;end select
       IF ((request->synonyms[s].groups[g].route_code_value > 0))
        IF (attr_exists_ind=1)
         UPDATE  FROM ocs_attr_xcptn oax
          SET oax.flex_obj_cd = request->synonyms[s].groups[g].route_code_value, oax.facility_cd =
           request->synonyms[s].groups[g].facility_code_value, oax.flex_str_value_txt = trim(
            cnvtstring(request->synonyms[s].groups[g].facility_code_value)),
           oax.updt_dt_tm = cnvtdatetime(curdate,curtime3), oax.updt_id = reqinfo->updt_id, oax
           .updt_task = reqinfo->updt_task,
           oax.updt_cnt = (oax.updt_cnt+ 1), oax.updt_applctx = reqinfo->updt_applctx
          WHERE (oax.ocs_attr_xcptn_group_id=request->synonyms[s].groups[g].id)
           AND (oax.synonym_id=request->synonyms[s].id)
           AND oax.flex_obj_type_cd=route_cd
          WITH nocounter
         ;end update
         IF (curqual=0)
          SET error_flag = "Y"
          SET error_text = concat("Error updating ocs_attr_xcptn for synonym: ",cnvtstring(request->
            synonyms[s].id))
         ENDIF
        ELSE
         INSERT  FROM ocs_attr_xcptn oax
          SET oax.ocs_attr_xcptn_id = seq(reference_seq,nextval), oax.ocs_attr_xcptn_group_id =
           request->synonyms[s].groups[g].id, oax.synonym_id = request->synonyms[s].id,
           oax.ocs_col_name_cd = witnessreq_cd, oax.flex_obj_type_cd = route_cd, oax.flex_obj_cd =
           request->synonyms[s].groups[g].route_code_value,
           oax.flex_nbr_value =
           IF ((request->synonyms[s].witness_default_ind=1)) 0
           ELSE 1
           ENDIF
           , oax.flex_str_value_txt = trim(cnvtstring(request->synonyms[s].groups[g].
             facility_code_value)), oax.facility_cd = request->synonyms[s].groups[g].
           facility_code_value,
           oax.updt_dt_tm = cnvtdatetime(curdate,curtime3), oax.updt_id = reqinfo->updt_id, oax
           .updt_task = reqinfo->updt_task,
           oax.updt_cnt = 0, oax.updt_applctx = reqinfo->updt_applctx
          WITH nocounter
         ;end insert
         IF (curqual=0)
          SET error_flag = "Y"
          SET error_text = concat("Error adding ocs_attr_xcptn for synonym: ",cnvtstring(request->
            synonyms[s].id))
         ENDIF
        ENDIF
       ELSE
        IF (attr_exists_ind=1)
         DELETE  FROM ocs_attr_xcptn oax
          WHERE (oax.ocs_attr_xcptn_group_id=request->synonyms[s].groups[g].id)
           AND (oax.synonym_id=request->synonyms[s].id)
           AND oax.flex_obj_type_cd=route_cd
          WITH nocounter
         ;end delete
         IF (curqual=0)
          SET error_flag = "Y"
          SET error_text = concat("Error deleting ocs_attr_xcptn for synonym: ",cnvtstring(request->
            synonyms[s].id))
         ENDIF
        ENDIF
       ENDIF
       SET attr_exists_ind = 0
       SELECT INTO "NL:"
        FROM ocs_attr_xcptn oax
        WHERE (oax.ocs_attr_xcptn_group_id=request->synonyms[s].groups[g].id)
         AND (oax.synonym_id=request->synonyms[s].id)
         AND oax.flex_obj_type_cd=iv_event_cd
        DETAIL
         attr_exists_ind = 1
        WITH nocounter
       ;end select
       IF ((request->synonyms[s].groups[g].iv_event_code_value > 0))
        IF (attr_exists_ind=1)
         UPDATE  FROM ocs_attr_xcptn oax
          SET oax.flex_obj_cd = request->synonyms[s].groups[g].iv_event_code_value, oax.facility_cd
            = request->synonyms[s].groups[g].facility_code_value, oax.flex_str_value_txt = trim(
            cnvtstring(request->synonyms[s].groups[g].facility_code_value)),
           oax.updt_dt_tm = cnvtdatetime(curdate,curtime3), oax.updt_id = reqinfo->updt_id, oax
           .updt_task = reqinfo->updt_task,
           oax.updt_cnt = (oax.updt_cnt+ 1), oax.updt_applctx = reqinfo->updt_applctx
          WHERE (oax.ocs_attr_xcptn_group_id=request->synonyms[s].groups[g].id)
           AND (oax.synonym_id=request->synonyms[s].id)
           AND oax.flex_obj_type_cd=iv_event_cd
          WITH nocounter
         ;end update
         IF (curqual=0)
          SET error_flag = "Y"
          SET error_text = concat("Error updating ocs_attr_xcptn for synonym: ",cnvtstring(request->
            synonyms[s].id))
         ENDIF
        ELSE
         INSERT  FROM ocs_attr_xcptn oax
          SET oax.ocs_attr_xcptn_id = seq(reference_seq,nextval), oax.ocs_attr_xcptn_group_id =
           request->synonyms[s].groups[g].id, oax.synonym_id = request->synonyms[s].id,
           oax.ocs_col_name_cd = witnessreq_cd, oax.flex_obj_type_cd = iv_event_cd, oax.flex_obj_cd
            = request->synonyms[s].groups[g].iv_event_code_value,
           oax.flex_nbr_value =
           IF ((request->synonyms[s].witness_default_ind=1)) 0
           ELSE 1
           ENDIF
           , oax.flex_str_value_txt = trim(cnvtstring(request->synonyms[s].groups[g].
             facility_code_value)), oax.facility_cd = request->synonyms[s].groups[g].
           facility_code_value,
           oax.updt_dt_tm = cnvtdatetime(curdate,curtime3), oax.updt_id = reqinfo->updt_id, oax
           .updt_task = reqinfo->updt_task,
           oax.updt_cnt = 0, oax.updt_applctx = reqinfo->updt_applctx
          WITH nocounter
         ;end insert
         IF (curqual=0)
          SET error_flag = "Y"
          SET error_text = concat("Error adding ocs_attr_xcptn for synonym: ",cnvtstring(request->
            synonyms[s].id))
         ENDIF
        ENDIF
       ELSE
        IF (attr_exists_ind=1)
         DELETE  FROM ocs_attr_xcptn oax
          WHERE (oax.ocs_attr_xcptn_group_id=request->synonyms[s].groups[g].id)
           AND (oax.synonym_id=request->synonyms[s].id)
           AND oax.flex_obj_type_cd=iv_event_cd
          WITH nocounter
         ;end delete
         IF (curqual=0)
          SET error_flag = "Y"
          SET error_text = concat("Error deleting ocs_attr_xcptn for synonym: ",cnvtstring(request->
            synonyms[s].id))
         ENDIF
        ENDIF
       ENDIF
       SET attr_exists_ind = 0
       SELECT INTO "NL:"
        FROM ocs_attr_xcptn oax
        WHERE (oax.ocs_attr_xcptn_group_id=request->synonyms[s].groups[g].id)
         AND (oax.synonym_id=request->synonyms[s].id)
         AND oax.flex_obj_type_cd=age_range_cd
        DETAIL
         attr_exists_ind = 1
        WITH nocounter
       ;end select
       IF ((request->synonyms[s].groups[g].age_range_code_value > 0))
        IF (attr_exists_ind=1)
         UPDATE  FROM ocs_attr_xcptn oax
          SET oax.flex_obj_cd = request->synonyms[s].groups[g].age_range_code_value, oax.facility_cd
            = request->synonyms[s].groups[g].facility_code_value, oax.flex_str_value_txt = trim(
            cnvtstring(request->synonyms[s].groups[g].facility_code_value)),
           oax.updt_dt_tm = cnvtdatetime(curdate,curtime3), oax.updt_id = reqinfo->updt_id, oax
           .updt_task = reqinfo->updt_task,
           oax.updt_cnt = (oax.updt_cnt+ 1), oax.updt_applctx = reqinfo->updt_applctx
          WHERE (oax.ocs_attr_xcptn_group_id=request->synonyms[s].groups[g].id)
           AND (oax.synonym_id=request->synonyms[s].id)
           AND oax.flex_obj_type_cd=age_range_cd
          WITH nocounter
         ;end update
         IF (curqual=0)
          SET error_flag = "Y"
          SET error_text = concat("Error updating ocs_attr_xcptn for synonym: ",cnvtstring(request->
            synonyms[s].id))
         ENDIF
        ELSE
         INSERT  FROM ocs_attr_xcptn oax
          SET oax.ocs_attr_xcptn_id = seq(reference_seq,nextval), oax.ocs_attr_xcptn_group_id =
           request->synonyms[s].groups[g].id, oax.synonym_id = request->synonyms[s].id,
           oax.ocs_col_name_cd = witnessreq_cd, oax.flex_obj_type_cd = age_range_cd, oax.flex_obj_cd
            = request->synonyms[s].groups[g].age_range_code_value,
           oax.flex_nbr_value =
           IF ((request->synonyms[s].witness_default_ind=1)) 0
           ELSE 1
           ENDIF
           , oax.flex_str_value_txt = trim(cnvtstring(request->synonyms[s].groups[g].
             facility_code_value)), oax.facility_cd = request->synonyms[s].groups[g].
           facility_code_value,
           oax.updt_dt_tm = cnvtdatetime(curdate,curtime3), oax.updt_id = reqinfo->updt_id, oax
           .updt_task = reqinfo->updt_task,
           oax.updt_cnt = 0, oax.updt_applctx = reqinfo->updt_applctx
          WITH nocounter
         ;end insert
         IF (curqual=0)
          SET error_flag = "Y"
          SET error_text = concat("Error adding ocs_attr_xcptn for synonym: ",cnvtstring(request->
            synonyms[s].id))
         ENDIF
        ENDIF
       ELSE
        IF (attr_exists_ind=1)
         DELETE  FROM ocs_attr_xcptn oax
          WHERE (oax.ocs_attr_xcptn_group_id=request->synonyms[s].groups[g].id)
           AND (oax.synonym_id=request->synonyms[s].id)
           AND oax.flex_obj_type_cd=age_range_cd
          WITH nocounter
         ;end delete
         IF (curqual=0)
          SET error_flag = "Y"
          SET error_text = concat("Error deleting ocs_attr_xcptn for synonym: ",cnvtstring(request->
            synonyms[s].id))
         ENDIF
        ENDIF
       ENDIF
       SET attr_exists_ind = 0
       SELECT INTO "NL:"
        FROM ocs_attr_xcptn oax
        WHERE (oax.ocs_attr_xcptn_group_id=request->synonyms[s].groups[g].id)
         AND (oax.synonym_id=request->synonyms[s].id)
         AND oax.flex_obj_type_cd=0
         AND oax.flex_obj_cd=0
        DETAIL
         attr_exists_ind = 1
        WITH nocounter
       ;end select
       IF (attr_exists_ind=1)
        IF ((((request->synonyms[s].groups[g].location_code_value > 0)) OR ((((request->synonyms[s].
        groups[g].route_code_value > 0)) OR ((((request->synonyms[s].groups[g].iv_event_code_value >
        0)) OR ((request->synonyms[s].groups[g].age_range_code_value > 0))) )) )) )
         DELETE  FROM ocs_attr_xcptn oax
          WHERE (oax.ocs_attr_xcptn_group_id=request->synonyms[s].groups[g].id)
           AND (oax.synonym_id=request->synonyms[s].id)
           AND oax.flex_obj_type_cd=0
           AND oax.flex_obj_cd=0
          WITH nocounter
         ;end delete
         IF (curqual=0)
          SET error_flag = "Y"
          SET error_text = concat("Error deleting ocs_attr_xcptn for synonym: ",cnvtstring(request->
            synonyms[s].id))
         ENDIF
        ENDIF
       ENDIF
       IF ((request->synonyms[s].groups[g].location_code_value=0)
        AND (request->synonyms[s].groups[g].route_code_value=0)
        AND (request->synonyms[s].groups[g].iv_event_code_value=0)
        AND (request->synonyms[s].groups[g].age_range_code_value=0))
        IF (attr_exists_ind=1)
         UPDATE  FROM ocs_attr_xcptn oax
          SET oax.facility_cd = request->synonyms[s].groups[g].facility_code_value, oax
           .flex_str_value_txt = trim(cnvtstring(request->synonyms[s].groups[g].facility_code_value)),
           oax.updt_dt_tm = cnvtdatetime(curdate,curtime3),
           oax.updt_id = reqinfo->updt_id, oax.updt_task = reqinfo->updt_task, oax.updt_cnt = (oax
           .updt_cnt+ 1),
           oax.updt_applctx = reqinfo->updt_applctx
          WHERE (oax.ocs_attr_xcptn_group_id=request->synonyms[s].groups[g].id)
           AND (oax.synonym_id=request->synonyms[s].id)
           AND oax.flex_obj_type_cd=0
           AND oax.flex_obj_cd=0
          WITH nocounter
         ;end update
         IF (curqual=0)
          SET error_flag = "Y"
          SET error_text = concat("Error updating ocs_attr_xcptn for synonym: ",cnvtstring(request->
            synonyms[s].id))
         ENDIF
        ELSE
         INSERT  FROM ocs_attr_xcptn oax
          SET oax.ocs_attr_xcptn_id = seq(reference_seq,nextval), oax.ocs_attr_xcptn_group_id =
           request->synonyms[s].groups[g].id, oax.synonym_id = request->synonyms[s].id,
           oax.ocs_col_name_cd = witnessreq_cd, oax.flex_obj_type_cd = 0, oax.flex_obj_cd = 0,
           oax.flex_nbr_value =
           IF ((request->synonyms[s].witness_default_ind=1)) 0
           ELSE 1
           ENDIF
           , oax.flex_str_value_txt = trim(cnvtstring(request->synonyms[s].groups[g].
             facility_code_value)), oax.facility_cd = request->synonyms[s].groups[g].
           facility_code_value,
           oax.updt_dt_tm = cnvtdatetime(curdate,curtime3), oax.updt_id = reqinfo->updt_id, oax
           .updt_task = reqinfo->updt_task,
           oax.updt_cnt = 0, oax.updt_applctx = reqinfo->updt_applctx
          WITH nocounter
         ;end insert
         IF (curqual=0)
          SET error_flag = "Y"
          SET error_text = concat("Error adding ocs_attr_xcptn for synonym: ",cnvtstring(request->
            synonyms[s].id))
         ENDIF
        ENDIF
       ENDIF
      ELSEIF ((request->synonyms[s].groups[g].action_flag=3))
       DELETE  FROM ocs_attr_xcptn oax
        WHERE (oax.ocs_attr_xcptn_group_id=request->synonyms[s].groups[g].id)
         AND (oax.synonym_id=request->synonyms[s].id)
        WITH nocounter
       ;end delete
       IF (curqual=0)
        SET error_flag = "Y"
        SET error_text = concat("Error deleting ocs_attr_xcptn for synonym: ",cnvtstring(request->
          synonyms[s].id))
       ENDIF
      ENDIF
    ENDFOR
  ENDFOR
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
