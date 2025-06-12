CREATE PROGRAM bed_ens_sn_segments:dba
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
 FREE RECORD tsegs
 RECORD tsegs(
   1 tseg[*]
     2 segcd = f8
 )
 DECLARE tsegcnt = i4
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
 SET scnt = 0
 SET scnt = size(request->surgery_areas,5)
 IF (scnt=0)
  GO TO exit_script
 ENDIF
 FOR (s = 1 TO scnt)
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
   SET pref_card_id = 0
   SELECT INTO "NL:"
    FROM preference_card pc
    WHERE (pc.catalog_cd=request->procedure_code_value)
     AND pc.prsnl_id=0.0
     AND (pc.surg_area_cd=request->surgery_areas[s].code_value)
     AND pc.doc_type_cd=ornurse_cd
    DETAIL
     pref_card_id = pc.pref_card_id
    WITH nocounter
   ;end select
   IF (pref_card_id > 0)
    SELECT INTO "NL:"
     FROM pref_card_segment pcs
     PLAN (pcs
      WHERE pcs.pref_card_id=pref_card_id
       AND pcs.active_ind=1)
     HEAD REPORT
      tsegcnt = 0
     DETAIL
      tsegcnt = (tsegcnt+ 1), stat = alterlist(tsegs->tseg,tsegcnt), tsegs->tseg[tsegcnt].segcd = pcs
      .seg_cd
     WITH nocounter
    ;end select
   ELSE
    SET tsegcnt = 0
   ENDIF
   SET tcnt = 0
   SET tcnt = size(request->surgery_areas[s].segments,5)
   FOR (t = 1 TO tcnt)
     IF ((request->surgery_areas[s].segments[t].action_flag=2))
      IF ((request->surgery_areas[s].segments[t].selected_ind=0))
       IF (pref_card_id > 0)
        DELETE  FROM pref_card_segment pcs
         WHERE pcs.pref_card_id=pref_card_id
          AND (pcs.seg_cd=request->surgery_areas[s].segments[t].code_value)
         WITH nocounter
        ;end delete
        UPDATE  FROM preference_card pc
         SET pc.updt_dt_tm = cnvtdatetime(curdate,curtime3), pc.updt_id = reqinfo->updt_id, pc
          .updt_task = reqinfo->updt_task,
          pc.updt_applctx = reqinfo->updt_applctx
         WHERE pc.pref_card_id=pref_card_id
         WITH nocounter
        ;end update
       ENDIF
      ELSEIF ((request->surgery_areas[s].segments[t].selected_ind=1))
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
         SET pc.pref_card_id = pref_card_id, pc.catalog_cd = request->procedure_code_value, pc
          .prsnl_id = 0.0,
          pc.surg_specialty_id = 0.0, pc.surg_area_cd = request->surgery_areas[s].code_value, pc
          .template_ind = 0,
          pc.template_desc_cd = 0.0, pc.pref_card_type_flag = null, pc.hist_avg_dur = 0,
          pc.tot_nbr_cases = 0, pc.override_hist_avg_dur = 0, pc.override_tot_nbr_cases = 0,
          pc.override_lookback_nbr = 0, pc.long_text_id = 0.0, pc.data_status_cd = 0.0,
          pc.active_ind = 1, pc.active_status_cd = active_cd, pc.active_status_dt_tm = cnvtdatetime(
           curdate,curtime),
          pc.active_status_prsnl_id = reqinfo->updt_id, pc.create_dt_tm = cnvtdatetime(curdate,
           curtime), pc.create_prsnl_id = reqinfo->updt_id,
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
       ELSE
        UPDATE  FROM preference_card pc
         SET pc.updt_dt_tm = cnvtdatetime(curdate,curtime3), pc.updt_id = reqinfo->updt_id, pc
          .updt_task = reqinfo->updt_task,
          pc.updt_applctx = reqinfo->updt_applctx
         WHERE pc.pref_card_id=pref_card_id
         WITH nocounter
        ;end update
       ENDIF
       SET input_form_cd = 0.0
       SELECT INTO "NL:"
        FROM segment_reference sr
        WHERE (sr.seg_cd=request->surgery_areas[s].segments[t].code_value)
         AND (sr.surg_area_cd=request->surgery_areas[s].code_value)
         AND sr.doc_type_cd=ornurse_cd
        DETAIL
         input_form_cd = sr.input_form_cd
        WITH nocounter
       ;end select
       SET pref_card_segment_id = 0.0
       SELECT INTO "nl:"
        z = seq(reference_seq,nextval)
        FROM dual
        DETAIL
         pref_card_segment_id = cnvtreal(z)
        WITH format, nocounter
       ;end select
       SET ierrcode = 0
       INSERT  FROM pref_card_segment pcs
        SET pcs.pref_card_seg_id = pref_card_segment_id, pcs.pref_card_id = pref_card_id, pcs.seg_cd
          = request->surgery_areas[s].segments[t].code_value,
         pcs.input_form_cd = input_form_cd, pcs.defaults_exist_ind = 0.0, pcs.long_text_id = 0.0,
         pcs.active_ind = 1, pcs.active_status_cd = active_cd, pcs.active_status_prsnl_id = reqinfo->
         updt_id,
         pcs.active_status_dt_tm = cnvtdatetime(curdate,curtime), pcs.create_dt_tm = cnvtdatetime(
          curdate,curtime), pcs.create_prsnl_id = 0.0,
         pcs.create_task = null, pcs.create_applctx = null, pcs.updt_cnt = 0,
         pcs.updt_dt_tm = cnvtdatetime(curdate,curtime), pcs.updt_id = reqinfo->updt_id, pcs
         .updt_task = reqinfo->updt_task,
         pcs.updt_applctx = reqinfo->updt_applctx
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = "Y"
        GO TO exit_script
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   CALL update_surgeon(pref_card_id,s)
 ENDFOR
 SUBROUTINE update_surgeon(pcid,curseg)
   DECLARE catcd = f8
   DECLARE loccd = f8
   DECLARE prsnlid = f8
   DECLARE pcnt = i4
   DECLARE sscnt = i4
   DECLARE tsze = i4
   DECLARE foundit = i2
   DECLARE foundthem = i2
   DECLARE nsegcnt = i4
   DECLARE loopcnt = i4
   FREE RECORD docs
   RECORD docs(
     1 doc[*]
       2 prsnlid = f8
       2 pcid = f8
       2 seg_ind = i2
       2 segs[*]
         3 seg_cd = f8
   )
   FREE RECORD nsegs
   RECORD nsegs(
     1 nseg[*]
       2 nseg_cd = f8
       2 ninput_form_cd = f8
       2 ndefexist = i2
       2 nlongtext = f8
   )
   SET catcd = request->procedure_code_value
   SET loccd = request->surgery_areas[s].code_value
   SET pcnt = 0
   SELECT INTO "nl:"
    FROM preference_card pc,
     pref_card_segment pcs
    PLAN (pc
     WHERE pc.catalog_cd=catcd
      AND pc.surg_area_cd=loccd
      AND pc.prsnl_id > 0)
     JOIN (pcs
     WHERE pcs.pref_card_id=outerjoin(pc.pref_card_id))
    ORDER BY pc.pref_card_id
    HEAD pc.pref_card_id
     sscnt = 0, pcnt = (pcnt+ 1), stat = alterlist(docs->doc,pcnt),
     docs->doc[pcnt].prsnlid = pc.prsnl_id, docs->doc[pcnt].pcid = pc.pref_card_id
    DETAIL
     sscnt = (sscnt+ 1), stat = alterlist(docs->doc[pcnt].segs,sscnt)
     IF (pcs.pref_card_seg_id > 0)
      docs->doc[pcnt].seg_ind = 1, docs->doc[pcnt].segs[sscnt].seg_cd = pcs.seg_cd
     ELSE
      docs->doc[pcnt].seg_ind = 0
     ENDIF
    WITH nocounter
   ;end select
   FOR (ii = 1 TO pcnt)
     IF ((docs->doc[ii].seg_ind=0))
      SET nsegcnt = 0
      SELECT INTO "nl:"
       FROM pref_card_segment pcs
       PLAN (pcs
        WHERE pcs.pref_card_id=pcid)
       DETAIL
        nsegcnt = (nsegcnt+ 1), stat = alterlist(nsegs->nseg,nsegcnt), nsegs->nseg[nsegcnt].nseg_cd
         = pcs.seg_cd,
        nsegs->nseg[nsegcnt].ninput_form_cd = pcs.input_form_cd, nsegs->nseg[nsegcnt].ndefexist = pcs
        .defaults_exist_ind, nsegs->nseg[nsegcnt].nlongtext = pcs.long_text_id
       WITH nocounter
      ;end select
      FOR (ss = 1 TO nsegcnt)
        SET pref_card_segment_id = 0.0
        SELECT INTO "nl:"
         z = seq(reference_seq,nextval)
         FROM dual
         DETAIL
          pref_card_segment_id = cnvtreal(z)
         WITH format, nocounter
        ;end select
        INSERT  FROM pref_card_segment pcs
         SET pcs.pref_card_seg_id = pref_card_segment_id, pcs.pref_card_id = docs->doc[ii].pcid, pcs
          .seg_cd = nsegs->nseg[ss].nseg_cd,
          pcs.input_form_cd = nsegs->nseg[nsegcnt].ninput_form_cd, pcs.defaults_exist_ind = nsegs->
          nseg[nsegcnt].ndefexist, pcs.long_text_id = nsegs->nseg[nsegcnt].nlongtext,
          pcs.active_ind = 1, pcs.active_status_cd = active_cd, pcs.active_status_prsnl_id = reqinfo
          ->updt_id,
          pcs.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pcs.create_dt_tm = cnvtdatetime(
           curdate,curtime3), pcs.create_prsnl_id = reqinfo->updt_id,
          pcs.create_task = null, pcs.create_applctx = null, pcs.updt_cnt = 0,
          pcs.updt_dt_tm = cnvtdatetime(curdate,curtime3), pcs.updt_id = reqinfo->updt_id, pcs
          .updt_task = reqinfo->updt_task,
          pcs.updt_applctx = reqinfo->updt_applctx
         WITH nocounter
        ;end insert
      ENDFOR
     ELSE
      SET tsze = size(docs->doc[ii].segs,5)
      IF (tsze=tsegcnt)
       SET foundthem = 1
       FOR (jj = 1 TO tsze)
         SET foundit = 0
         FOR (kk = 1 TO tsegcnt)
           IF ((docs->doc[ii].segs[jj].seg_cd=tsegs->tseg[kk].segcd))
            SET foundit = 1
           ENDIF
         ENDFOR
         IF (foundit=0)
          SET foundthem = 0
         ENDIF
       ENDFOR
      ELSE
       SET foundthem = 0
      ENDIF
      IF (foundthem=1)
       SET loopcnt = size(request->surgery_areas[curseg].segments,5)
       FOR (ss = 1 TO loopcnt)
        IF ((request->surgery_areas[curseg].segments[ss].action_flag=2)
         AND (request->surgery_areas[curseg].segments[ss].selected_ind=0))
         DELETE  FROM pref_card_segment pcs
          WHERE (pcs.pref_card_id=docs->doc[ii].pcid)
           AND (pcs.seg_cd=request->surgery_areas[curseg].segments[ss].code_value)
          WITH nocounter
         ;end delete
         IF (curqual=0)
          SET failed = "Y"
          GO TO exit_script
         ENDIF
        ELSEIF ((request->surgery_areas[curseg].segments[ss].action_flag=2)
         AND (request->surgery_areas[curseg].segments[ss].selected_ind=1))
         SET input_form_cd = 0.0
         SELECT INTO "NL:"
          FROM segment_reference sr
          WHERE (sr.seg_cd=request->surgery_areas[curseg].segments[ss].code_value)
           AND (sr.surg_area_cd=request->surgery_areas[curseg].code_value)
           AND sr.doc_type_cd=ornurse_cd
          DETAIL
           input_form_cd = sr.input_form_cd
          WITH nocounter
         ;end select
         SET pref_card_segment_id = 0.0
         SELECT INTO "nl:"
          z = seq(reference_seq,nextval)
          FROM dual
          DETAIL
           pref_card_segment_id = cnvtreal(z)
          WITH format, nocounter
         ;end select
         INSERT  FROM pref_card_segment pcs
          SET pcs.pref_card_seg_id = pref_card_segment_id, pcs.pref_card_id = docs->doc[ii].pcid, pcs
           .seg_cd = request->surgery_areas[curseg].segments[ss].code_value,
           pcs.input_form_cd = input_form_cd, pcs.defaults_exist_ind = 0.0, pcs.long_text_id = 0.0,
           pcs.active_ind = 1, pcs.active_status_cd = active_cd, pcs.active_status_prsnl_id = reqinfo
           ->updt_id,
           pcs.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pcs.create_dt_tm = cnvtdatetime(
            curdate,curtime3), pcs.create_prsnl_id = reqinfo->updt_id,
           pcs.create_task = null, pcs.create_applctx = null, pcs.updt_cnt = 0,
           pcs.updt_dt_tm = cnvtdatetime(curdate,curtime3), pcs.updt_id = reqinfo->updt_id, pcs
           .updt_task = reqinfo->updt_task,
           pcs.updt_applctx = reqinfo->updt_applctx
          WITH nocounter
         ;end insert
        ENDIF
        UPDATE  FROM preference_card pc
         SET pc.updt_dt_tm = cnvtdatetime(curdate,curtime3), pc.updt_id = reqinfo->updt_id, pc
          .updt_task = reqinfo->updt_task,
          pc.updt_applctx = reqinfo->updt_applctx
         WHERE (pc.pref_card_id=docs->doc[ii].pcid)
         WITH nocounter
        ;end update
       ENDFOR
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
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
