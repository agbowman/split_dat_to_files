CREATE PROGRAM bed_ens_sn_comments:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET ornurse_cd = 0.0
 SET active_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
   AND cv.active_ind=1
  DETAIL
   active_cd = cv.code_value
  WITH nocounter
 ;end select
 SET prsnl_comm_type_cd = 0.0
 SET prefcard_comm_type_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=16289
   AND cv.cdf_meaning="PRSNL"
   AND cv.active_ind=1
  DETAIL
   prsnl_comm_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=16289
   AND cv.cdf_meaning="PREFCARD"
   AND cv.display_key="PREFERENCECARDCOMMENTS"
   AND cv.active_ind=1
  DETAIL
   prefcard_comm_type_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (prefcard_comm_type_cd=0.0)
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=16289
    AND cv.cdf_meaning="PREFCARD"
    AND cv.display="*Preference*"
    AND cv.active_ind=1
   DETAIL
    prefcard_comm_type_cd = cv.code_value
   WITH nocounter
  ;end select
  IF (prefcard_comm_type_cd=0.0)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=16289
     AND cv.cdf_meaning="PREFCARD"
     AND cv.active_ind=1
    DETAIL
     prefcard_comm_type_cd = 0.0
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET rtf_ind = 0
 IF (validate(request->rtf_comments))
  SET rtf_ind = 1
 ENDIF
 SET scnt = 0
 SET scnt = size(request->surgery_areas,5)
 IF (scnt=0)
  DECLARE sn_comment_id = f8 WITH protect, noconstant(0)
  DECLARE long_text_id = f8 WITH protect, noconstant(0)
  DECLARE long_blob_id = f8 WITH protect, noconstant(0)
  SET ltr_row_exists = 0
  SET lbr_row_exists = 0
  SELECT INTO "NL:"
   FROM sn_comment_text sct
   WHERE (sct.root_id=request->surgeon_id)
    AND sct.root_name="PRSNL"
    AND sct.comment_type_cd=prsnl_comm_type_cd
    AND sct.active_ind=1
   DETAIL
    sn_comment_id = sct.sn_comment_id, long_text_id = sct.long_text_id, long_blob_id = sct
    .long_blob_id
   WITH nocounter
  ;end select
  IF ((request->comments=" "))
   IF (sn_comment_id > 0)
    DELETE  FROM sn_comment_text sct
     WHERE sct.sn_comment_id=sn_comment_id
     WITH nocounter
    ;end delete
   ENDIF
   IF (long_text_id > 0)
    DELETE  FROM long_text_reference ltr
     WHERE ltr.long_text_id=long_text_id
     WITH nocounter
    ;end delete
   ENDIF
   IF (long_blob_id > 0)
    DELETE  FROM long_blob_reference lbr
     WHERE lbr.long_blob_id=long_blob_id
     WITH nocounter
    ;end delete
   ENDIF
  ELSE
   IF (sn_comment_id=0)
    SELECT INTO "nl:"
     z = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      long_text_id = cnvtreal(z)
     WITH format, nocounter
    ;end select
    SELECT INTO "nl:"
     z = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      sn_comment_id = cnvtreal(z)
     WITH format, nocounter
    ;end select
    SET ierrcode = 0
    INSERT  FROM sn_comment_text sct
     SET sct.sn_comment_id = sn_comment_id, sct.root_id = request->surgeon_id, sct.root_name =
      "PRSNL",
      sct.header = " ", sct.long_text_id = long_text_id, sct.long_blob_id = long_text_id,
      sct.surg_area_cd = 0.0, sct.comment_type_cd = prsnl_comm_type_cd, sct.reference_ind = 1,
      sct.seg_cd = 0, sct.active_ind = 1, sct.active_status_cd = active_cd,
      sct.active_status_dt_tm = cnvtdatetime(curdate,curtime3), sct.active_status_prsnl_id = reqinfo
      ->updt_id, sct.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      sct.end_effective_dt_tm = null, sct.create_applctx = reqinfo->updt_applctx, sct.create_prsnl_id
       = reqinfo->updt_id,
      sct.create_dt_tm = cnvtdatetime(curdate,curtime3), sct.create_task = reqinfo->updt_task, sct
      .updt_applctx = reqinfo->updt_applctx,
      sct.updt_id = reqinfo->updt_id, sct.updt_dt_tm = cnvtdatetime(curdate,curtime3), sct.updt_task
       = reqinfo->updt_task,
      sct.updt_cnt = 0, sct.seq_num = 0
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     GO TO exit_script
    ENDIF
   ENDIF
   IF (long_text_id > 0)
    SELECT INTO "NL:"
     FROM long_text_reference ltr
     WHERE ltr.long_text_id=long_text_id
     DETAIL
      ltr_row_exists = 1
     WITH nocounter
    ;end select
    SELECT INTO "NL:"
     FROM long_blob_reference lbr
     WHERE lbr.long_blob_id=long_text_id
     DETAIL
      lbr_row_exists = 1
     WITH nocounter
    ;end select
   ENDIF
   IF (((long_text_id=0) OR (((ltr_row_exists=0) OR (((long_blob_id=0) OR (lbr_row_exists=0)) )) )) )
    IF (long_text_id=0)
     SELECT INTO "nl:"
      z = seq(long_data_seq,nextval)
      FROM dual
      DETAIL
       long_text_id = cnvtreal(z)
      WITH format, nocounter
     ;end select
    ENDIF
    SET ierrcode = 0
    INSERT  FROM long_text_reference ltr
     SET ltr.long_text_id = long_text_id, ltr.updt_applctx = reqinfo->updt_applctx, ltr.updt_id =
      reqinfo->updt_id,
      ltr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ltr.updt_task = reqinfo->updt_task, ltr
      .updt_cnt = 0,
      ltr.active_ind = 1, ltr.active_status_cd = active_cd, ltr.active_status_dt_tm = cnvtdatetime(
       curdate,curtime3),
      ltr.active_status_prsnl_id = reqinfo->updt_id, ltr.parent_entity_name = "SN_COMMENT_TEXT", ltr
      .parent_entity_id = sn_comment_id,
      ltr.long_text = request->comments
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     GO TO exit_script
    ENDIF
    IF (rtf_ind=1)
     SET ierrcode = 0
     INSERT  FROM long_blob_reference lbr
      SET lbr.long_blob_id = long_text_id, lbr.updt_applctx = reqinfo->updt_applctx, lbr.updt_id =
       reqinfo->updt_id,
       lbr.updt_dt_tm = cnvtdatetime(curdate,curtime3), lbr.updt_task = reqinfo->updt_task, lbr
       .updt_cnt = 0,
       lbr.active_ind = 1, lbr.active_status_cd = active_cd, lbr.active_status_dt_tm = cnvtdatetime(
        curdate,curtime3),
       lbr.active_status_prsnl_id = reqinfo->updt_id, lbr.parent_entity_name = "SN_COMMENT_TEXT", lbr
       .parent_entity_id = sn_comment_id,
       lbr.long_blob = request->rtf_comments
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = "Y"
      GO TO exit_script
     ENDIF
    ENDIF
    UPDATE  FROM sn_comment_text sct
     SET sct.long_text_id = long_text_id, sct.long_blob_id = long_text_id, sct.updt_applctx = reqinfo
      ->updt_applctx,
      sct.updt_id = reqinfo->updt_id, sct.updt_dt_tm = cnvtdatetime(curdate,curtime3), sct.updt_task
       = reqinfo->updt_task,
      sct.updt_cnt = (sct.updt_cnt+ 1)
     WHERE (sct.root_id=request->surgeon_id)
      AND sct.root_name="PRSNL"
      AND sct.comment_type_cd=prsnl_comm_type_cd
      AND sct.active_ind=1
     WITH nocounter
    ;end update
   ELSE
    UPDATE  FROM sn_comment_text sct
     SET sct.updt_applctx = reqinfo->updt_applctx, sct.updt_id = reqinfo->updt_id, sct.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      sct.updt_task = reqinfo->updt_task, sct.updt_cnt = (sct.updt_cnt+ 1)
     WHERE (sct.root_id=request->surgeon_id)
      AND sct.root_name="PRSNL"
      AND sct.comment_type_cd=prsnl_comm_type_cd
      AND sct.active_ind=1
      AND sct.long_text_id=long_text_id
      AND sct.long_blob_id=long_text_id
     WITH nocounter
    ;end update
    UPDATE  FROM long_text_reference ltr
     SET ltr.long_text = request->comments, ltr.updt_applctx = reqinfo->updt_applctx, ltr.updt_id =
      reqinfo->updt_id,
      ltr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ltr.updt_task = reqinfo->updt_task, ltr
      .updt_cnt = (ltr.updt_cnt+ 1)
     WHERE ltr.long_text_id=long_text_id
     WITH nocounter
    ;end update
    IF (rtf_ind=1)
     UPDATE  FROM long_blob_reference lbr
      SET lbr.long_blob = request->rtf_comments, lbr.updt_applctx = reqinfo->updt_applctx, lbr
       .updt_id = reqinfo->updt_id,
       lbr.updt_dt_tm = cnvtdatetime(curdate,curtime3), lbr.updt_task = reqinfo->updt_task, lbr
       .updt_cnt = (lbr.updt_cnt+ 1)
      WHERE lbr.long_blob_id=long_text_id
      WITH nocounter
     ;end update
    ENDIF
   ENDIF
  ENDIF
 ELSE
  FOR (s = 1 TO scnt)
    SET pcnt = 0
    SET pcnt = size(request->surgery_areas[s].procedures,5)
    FOR (p = 1 TO pcnt)
      DECLARE sn_comment_id = f8 WITH protect, noconstant(0)
      DECLARE long_text_id = f8 WITH protect, noconstant(0)
      DECLARE long_blob_id = f8 WITH protect, noconstant(0)
      DECLARE pref_card_id = f8 WITH protect, noconstant(0)
      SET ltr_row_exists = 0
      SET lbr_row_exists = 0
      SET ornurse_cd = 0.0
      SELECT INTO "nl:"
       FROM sn_doc_ref sdr,
        code_value cv
       PLAN (sdr
        WHERE (sdr.area_cd=request->surgery_areas[s].code_value))
        JOIN (cv
        WHERE cv.code_set=14258
         AND cv.code_value=sdr.doc_type_cd
         AND cv.cdf_meaning="ORNURSE"
         AND cv.active_ind=1)
       DETAIL
        ornurse_cd = cv.code_value
       WITH nocounter
      ;end select
      SELECT INTO "NL:"
       FROM preference_card pc
       WHERE (pc.catalog_cd=request->surgery_areas[s].procedures[p].code_value)
        AND (pc.prsnl_id=request->surgeon_id)
        AND (pc.surg_area_cd=request->surgery_areas[s].code_value)
        AND pc.doc_type_cd=ornurse_cd
       DETAIL
        pref_card_id = pc.pref_card_id
       WITH nocounter
      ;end select
      IF (pref_card_id=0)
       SELECT INTO "nl:"
        z = seq(reference_seq,nextval)
        FROM dual
        DETAIL
         pref_card_id = cnvtreal(z)
        WITH format, nocounter
       ;end select
       SET ierrcode = 0
       INSERT  FROM preference_card pc
        SET pc.pref_card_id = pref_card_id, pc.catalog_cd = request->surgery_areas[s].procedures[p].
         code_value, pc.prsnl_id = request->surgeon_id,
         pc.surg_specialty_id = 0.0, pc.surg_area_cd = request->surgery_areas[s].code_value, pc
         .template_ind = 0,
         pc.template_desc_cd = 0.0, pc.pref_card_type_flag = null, pc.hist_avg_dur = 0,
         pc.tot_nbr_cases = 0, pc.override_hist_avg_dur = 0, pc.override_tot_nbr_cases = 0,
         pc.override_lookback_nbr = 0, pc.long_text_id = 0.0, pc.data_status_cd = 0.0,
         pc.active_ind = 1, pc.active_status_cd = active_cd, pc.active_status_dt_tm = cnvtdatetime(
          curdate,curtime),
         pc.active_status_prsnl_id = reqinfo->updt_id, pc.create_dt_tm = cnvtdatetime(curdate,curtime
          ), pc.create_prsnl_id = reqinfo->updt_id,
         pc.create_task = reqinfo->updt_task, pc.create_applctx = reqinfo->updt_applctx, pc.updt_cnt
          = 0,
         pc.updt_dt_tm = cnvtdatetime(curdate,curtime), pc.updt_id = reqinfo->updt_id, pc.updt_task
          = reqinfo->updt_task,
         pc.updt_applctx = reqinfo->updt_applctx, pc.locked_applctx = reqinfo->updt_applctx, pc
         .num_cases_rec_avg = 0,
         pc.rec_avg_dur = 0, pc.doc_type_cd = ornurse_cd, pc.last_used_dt_tm = null
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = "Y"
        GO TO exit_script
       ENDIF
      ENDIF
      SELECT INTO "NL:"
       FROM sn_comment_text sct
       WHERE sct.root_id=pref_card_id
        AND sct.root_name="PREFERENCE_CARD"
        AND (sct.surg_area_cd=request->surgery_areas[s].code_value)
        AND sct.comment_type_cd=prefcard_comm_type_cd
        AND sct.active_ind=1
       DETAIL
        sn_comment_id = sct.sn_comment_id, long_text_id = sct.long_text_id, long_blob_id = sct
        .long_blob_id
       WITH nocounter
      ;end select
      IF ((((request->comments=" ")) OR ((request->rtf_comments=" "))) )
       IF (sn_comment_id > 0)
        DELETE  FROM sn_comment_text sct
         WHERE sct.sn_comment_id=sn_comment_id
         WITH nocounter
        ;end delete
       ENDIF
       IF (long_text_id > 0
        AND (request->comments=" "))
        DELETE  FROM long_text_reference ltr
         WHERE ltr.long_text_id=long_text_id
         WITH nocounter
        ;end delete
       ENDIF
       IF (long_blob_id > 0
        AND (request->rtf_comments=" "))
        DELETE  FROM long_blob_reference lbr
         WHERE lbr.long_blob_id=long_blob_id
         WITH nocounter
        ;end delete
       ENDIF
      ELSE
       IF (sn_comment_id=0)
        SELECT INTO "nl:"
         z = seq(long_data_seq,nextval)
         FROM dual
         DETAIL
          long_text_id = cnvtreal(z)
         WITH format, nocounter
        ;end select
        SELECT INTO "nl:"
         z = seq(reference_seq,nextval)
         FROM dual
         DETAIL
          sn_comment_id = cnvtreal(z)
         WITH format, nocounter
        ;end select
        SET ierrcode = 0
        INSERT  FROM sn_comment_text sct
         SET sct.sn_comment_id = sn_comment_id, sct.root_id = pref_card_id, sct.root_name =
          "PREFERENCE_CARD",
          sct.header = " ", sct.long_text_id = long_text_id, sct.long_blob_id = long_text_id,
          sct.surg_area_cd = request->surgery_areas[s].code_value, sct.comment_type_cd =
          prefcard_comm_type_cd, sct.reference_ind = 1,
          sct.seg_cd = 0, sct.active_ind = 1, sct.active_status_cd = active_cd,
          sct.active_status_dt_tm = cnvtdatetime(curdate,curtime3), sct.active_status_prsnl_id =
          reqinfo->updt_id, sct.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
          sct.end_effective_dt_tm = null, sct.create_applctx = reqinfo->updt_applctx, sct
          .create_prsnl_id = reqinfo->updt_id,
          sct.create_dt_tm = cnvtdatetime(curdate,curtime3), sct.create_task = reqinfo->updt_task,
          sct.updt_applctx = reqinfo->updt_applctx,
          sct.updt_id = reqinfo->updt_id, sct.updt_dt_tm = cnvtdatetime(curdate,curtime3), sct
          .updt_task = reqinfo->updt_task,
          sct.updt_cnt = 0, sct.seq_num = 0
         WITH nocounter
        ;end insert
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET failed = "Y"
         GO TO exit_script
        ENDIF
       ENDIF
       IF (long_text_id > 0)
        SELECT INTO "NL:"
         FROM long_text_reference ltr
         WHERE ltr.long_text_id=long_text_id
         DETAIL
          ltr_row_exists = 1
         WITH nocounter
        ;end select
        SELECT INTO "NL:"
         FROM long_blob_reference lbr
         WHERE lbr.long_blob_id=long_text_id
         DETAIL
          lbr_row_exists = 1
         WITH nocounter
        ;end select
       ENDIF
       IF (((long_text_id=0) OR (((ltr_row_exists=0) OR (((long_blob_id=0) OR (lbr_row_exists=0)) ))
       )) )
        IF (long_text_id=0)
         SELECT INTO "nl:"
          z = seq(long_data_seq,nextval)
          FROM dual
          DETAIL
           long_text_id = cnvtreal(z)
          WITH format, nocounter
         ;end select
        ENDIF
        SET ierrcode = 0
        INSERT  FROM long_text_reference ltr
         SET ltr.long_text_id = long_text_id, ltr.updt_applctx = reqinfo->updt_applctx, ltr.updt_id
           = reqinfo->updt_id,
          ltr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ltr.updt_task = reqinfo->updt_task, ltr
          .updt_cnt = 0,
          ltr.active_ind = 1, ltr.active_status_cd = active_cd, ltr.active_status_dt_tm =
          cnvtdatetime(curdate,curtime3),
          ltr.active_status_prsnl_id = reqinfo->updt_id, ltr.parent_entity_name = "SN_COMMENT_TEXT",
          ltr.parent_entity_id = sn_comment_id,
          ltr.long_text = request->comments
         WITH nocounter
        ;end insert
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET failed = "Y"
         GO TO exit_script
        ENDIF
        IF (rtf_ind=1)
         SET ierrcode = 0
         INSERT  FROM long_blob_reference lbr
          SET lbr.long_blob_id = long_text_id, lbr.updt_applctx = reqinfo->updt_applctx, lbr.updt_id
            = reqinfo->updt_id,
           lbr.updt_dt_tm = cnvtdatetime(curdate,curtime3), lbr.updt_task = reqinfo->updt_task, lbr
           .updt_cnt = 0,
           lbr.active_ind = 1, lbr.active_status_cd = active_cd, lbr.active_status_dt_tm =
           cnvtdatetime(curdate,curtime3),
           lbr.active_status_prsnl_id = reqinfo->updt_id, lbr.parent_entity_name = "SN_COMMENT_TEXT",
           lbr.parent_entity_id = sn_comment_id,
           lbr.long_blob = request->rtf_comments
          WITH nocounter
         ;end insert
         SET ierrcode = error(serrmsg,1)
         IF (ierrcode > 0)
          SET failed = "Y"
          GO TO exit_script
         ENDIF
        ENDIF
        UPDATE  FROM sn_comment_text sct
         SET sct.long_text_id = long_text_id, sct.long_blob_id = long_text_id, sct.updt_applctx =
          reqinfo->updt_applctx,
          sct.updt_id = reqinfo->updt_id, sct.updt_dt_tm = cnvtdatetime(curdate,curtime3), sct
          .updt_task = reqinfo->updt_task,
          sct.updt_cnt = (sct.updt_cnt+ 1)
         WHERE sct.root_id=pref_card_id
          AND sct.root_name="PREFERENCE_CARD"
          AND (sct.surg_area_cd=request->surgery_areas[s].code_value)
          AND sct.comment_type_cd=prefcard_comm_type_cd
          AND sct.active_ind=1
         WITH nocounter
        ;end update
       ELSE
        UPDATE  FROM sn_comment_text sct
         SET sct.updt_applctx = reqinfo->updt_applctx, sct.updt_id = reqinfo->updt_id, sct.updt_dt_tm
           = cnvtdatetime(curdate,curtime3),
          sct.updt_task = reqinfo->updt_task, sct.updt_cnt = (sct.updt_cnt+ 1)
         WHERE sct.root_id=pref_card_id
          AND sct.root_name="PREFERENCE_CARD"
          AND (sct.surg_area_cd=request->surgery_areas[s].code_value)
          AND sct.comment_type_cd=prefcard_comm_type_cd
          AND sct.active_ind=1
          AND sct.long_text_id=long_text_id
          AND sct.long_blob_id=long_text_id
         WITH nocounter
        ;end update
        UPDATE  FROM long_text_reference ltr
         SET ltr.long_text = request->comments, ltr.updt_applctx = reqinfo->updt_applctx, ltr.updt_id
           = reqinfo->updt_id,
          ltr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ltr.updt_task = reqinfo->updt_task, ltr
          .updt_cnt = (ltr.updt_cnt+ 1)
         WHERE ltr.long_text_id=long_text_id
         WITH nocounter
        ;end update
        IF (rtf_ind=1)
         UPDATE  FROM long_blob_reference lbr
          SET lbr.long_blob = request->rtf_comments, lbr.updt_applctx = reqinfo->updt_applctx, lbr
           .updt_id = reqinfo->updt_id,
           lbr.updt_dt_tm = cnvtdatetime(curdate,curtime3), lbr.updt_task = reqinfo->updt_task, lbr
           .updt_cnt = (lbr.updt_cnt+ 1)
          WHERE lbr.long_blob_id=long_text_id
         ;end update
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
  ENDFOR
 ENDIF
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
