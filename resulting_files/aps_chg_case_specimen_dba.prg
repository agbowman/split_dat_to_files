CREATE PROGRAM aps_chg_case_specimen:dba
 RECORD reply(
   1 case_id = f8
   1 qual[1]
     2 case_specimen_id = f8
   1 task_qual[*]
     2 id = f8
     2 order_id = f8
     2 cancel_cd = f8
     2 request_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD req200423(
   1 spec_qual[*]
     2 case_specimen_id = f8
     2 delete_flag = i2
 )
 RECORD rep200423(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 specimen[*]
     2 case_specimen_id = f8
     2 slide_cnt = i2
     2 slide_qual[*]
       3 slide_id = f8
       3 pt_exists = c1
     2 cassette_cnt = i2
     2 cassette_qual[*]
       3 cassette_id = f8
       3 pt_exists = c1
       3 slide_cnt = i2
       3 slide_qual[*]
         4 slide_id = f8
         4 pt_exists = c1
 )
 RECORD temp_digital_slide(
   1 qual[*]
     2 digital_slide_id = f8
 )
 RECORD inventory(
   1 list[*]
     2 content_table_name = vc
     2 content_table_id = f8
   1 del_qual_cnt = i4
 )
#script
 SET failure = 0
 SET cur_updt_cnt = 0
 SET spec_lt_cur_updt_cnt = 0
 SET task_lt_cur_updt_cnt = 0
 SET new_task_comments_long_text_id = 0.00
 SET new_special_comments_long_text_id = 0.00
 SET pt_processing_task_id = 0.00
 SET order_id = 0.0
 SET service_resource_cd = 0.0
 SET failed = "F"
 SET failures = 0
 SET thetable = " "
 SET err = " "
 SET reply->status_data.status = "F"
 SET nbr_to_chg = cnvtint(size(request->qual,5))
 SET x = 1
 DECLARE nspecchangeind = i4 WITH protect, noconstant(0)
 DECLARE nspeccancelind = i4 WITH protect, noconstant(0)
 DECLARE max_spec_cnt = i2 WITH protect, noconstant(0)
 DECLARE max_cass_cnt = i2 WITH protect, noconstant(0)
 DECLARE max_slide_cnt = i2 WITH protect, noconstant(0)
 DECLARE max_spec_slide_cnt = i2 WITH protect, noconstant(0)
 DECLARE spec_task_cnt = i2 WITH protect, noconstant(0)
 DECLARE task_cnt = i2 WITH protect, noconstant(0)
 DECLARE cancel_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE verified_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE specimen_tag_chg_ind = i2 WITH protect, noconstant(0)
 SET stat = uar_get_meaning_by_codeset(1305,"CANCEL",1,cancel_status_cd)
 SET stat = uar_get_meaning_by_codeset(1305,"VERIFIED",1,verified_status_cd)
 IF (((cancel_status_cd=0) OR (verified_status_cd=0)) )
  SET thetable = "V"
  SET err = "S"
  GO TO check_err
 ENDIF
#start_loop
 SET s_active_cd = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
   AND cv.active_ind=1
  HEAD REPORT
   s_active_cd = 0.0
  DETAIL
   s_active_cd = cv.code_value
  WITH nocounter
 ;end select
 FOR (x = x TO nbr_to_chg)
   IF (textlen(trim(request->qual[x].special_comments)) > 0
    AND (request->qual[x].spec_comments_long_text_id=0))
    SELECT INTO "nl:"
     seq_nbr = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      new_special_comments_long_text_id = seq_nbr
     WITH format, counter
    ;end select
    IF (curqual=0)
     SET thetable = "S"
     SET err = "L"
     GO TO check_err
    ENDIF
    INSERT  FROM long_text lt
     SET lt.long_text_id = new_special_comments_long_text_id, lt.updt_cnt = 0, lt.updt_dt_tm =
      cnvtdatetime(sysdate),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
      updt_applctx,
      lt.active_ind = 1, lt.active_status_cd = s_active_cd, lt.active_status_dt_tm = cnvtdatetime(
       sysdate),
      lt.active_status_prsnl_id = reqinfo->updt_id, lt.parent_entity_name = "CASE_SPECIMEN", lt
      .parent_entity_id = request->qual[x].case_specimen_id,
      lt.long_text = request->qual[x].special_comments
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET thetable = "L"
     SET err = "U"
     GO TO check_err
    ENDIF
   ENDIF
   IF (textlen(trim(request->qual[x].task_comments)) > 0
    AND (request->qual[x].task_comments_long_text_id=0))
    SELECT INTO "nl:"
     pt.*
     FROM processing_task pt
     WHERE (request->qual[x].case_specimen_id=pt.case_specimen_id)
      AND 4=pt.create_inventory_flag
     DETAIL
      pt_processing_task_id = pt.processing_task_id
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     seq_nbr = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      new_task_comments_long_text_id = seq_nbr
     WITH format, counter
    ;end select
    IF (curqual=0)
     SET thetable = "S"
     SET err = "L"
     GO TO check_err
    ENDIF
    INSERT  FROM long_text lt
     SET lt.long_text_id = new_task_comments_long_text_id, lt.updt_cnt = 0, lt.updt_dt_tm =
      cnvtdatetime(sysdate),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
      updt_applctx,
      lt.active_ind = 1, lt.active_status_cd = s_active_cd, lt.active_status_dt_tm = cnvtdatetime(
       sysdate),
      lt.active_status_prsnl_id = reqinfo->updt_id, lt.parent_entity_name = "PROCESSING_TASK", lt
      .parent_entity_id = pt_processing_task_id,
      lt.long_text = request->qual[x].task_comments
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET thetable = "L"
     SET err = "U"
     GO TO check_err
    ENDIF
   ENDIF
   SET nspecchangeind = 0
   SET nspeccancelind = 0
   SELECT INTO "nl:"
    c.*
    FROM case_specimen c
    WHERE (c.case_specimen_id=request->qual[x].case_specimen_id)
    DETAIL
     IF ((((c.specimen_cd != request->qual[x].specimen_type_cd)) OR ((c.specimen_tag_id != request->
     qual[x].specimen_tag_cd))) )
      nspecchangeind = 1
     ENDIF
     IF (c.cancel_cd=0
      AND (request->qual[x].cancel_cd > 0))
      nspeccancelind = 1
     ENDIF
     IF (c.cancel_cd > 0
      AND (request->qual[x].cancel_cd=0))
      nspecchangeind = 1
     ENDIF
    WITH nocounter
   ;end select
   SET thetable = "C"
   SELECT INTO "nl:"
    c.*
    FROM case_specimen c
    WHERE (request->qual[x].case_specimen_id=c.case_specimen_id)
    DETAIL
     cur_updt_cnt = c.updt_cnt
     IF ((request->qual[x].specimen_tag_cd != c.specimen_tag_id))
      specimen_tag_chg_ind = 1
     ENDIF
    WITH forupdate(c)
   ;end select
   IF (curqual=0)
    SET err = "L"
    GO TO check_err
   ENDIF
   IF ((request->qual[x].case_spec_updt_cnt != cur_updt_cnt))
    SET err = "U"
    GO TO check_err
   ENDIF
   SET cur_updt_cnt += 1
   UPDATE  FROM case_specimen c
    SET c.case_specimen_id = request->qual[x].case_specimen_id, c.specimen_tag_id = request->qual[x].
     specimen_tag_cd, c.collect_dt_tm = cnvtdatetime(request->qual[x].collect_dt_tm),
     c.cancel_cd = request->qual[x].cancel_cd, c.specimen_cd = request->qual[x].specimen_type_cd, c
     .specimen_description =
     IF (textlen(request->qual[x].specimen_description) > 0) request->qual[x].specimen_description
     ELSE c.specimen_description
     ENDIF
     ,
     c.spec_comments_long_text_id =
     IF ((request->qual[x].spec_comments_long_text_id > 0)) request->qual[x].
      spec_comments_long_text_id
     ELSE new_special_comments_long_text_id
     ENDIF
     , c.received_dt_tm = cnvtdatetime(request->qual[x].received_dt_tm), c.received_fixative_cd =
     request->qual[x].received_fixative_cd,
     c.inadequacy_reason_cd = request->qual[x].adequacy_reason_cd, c.updt_dt_tm = cnvtdatetime(
      curdate,curtime), c.updt_id = reqinfo->updt_id,
     c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt =
     cur_updt_cnt
    WHERE (request->qual[x].case_specimen_id=c.case_specimen_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET err = "U"
    GO TO check_err
   ENDIF
   IF ((request->qual[x].cancel_cd != 0.0))
    INSERT  FROM ap_ops_exception aoe
     SET aoe.parent_id = request->qual[x].case_specimen_id, aoe.action_flag = 5, aoe.active_ind = 1,
      aoe.updt_dt_tm = cnvtdatetime(curdate,curtime), aoe.updt_id = reqinfo->updt_id, aoe.updt_task
       = reqinfo->updt_task,
      aoe.updt_applctx = reqinfo->updt_applctx, aoe.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET err = "I"
     SET thetable = "A"
     GO TO check_err
    ENDIF
    IF (curutc=1)
     INSERT  FROM ap_ops_exception_detail aoed
      SET aoed.action_flag = 5, aoed.field_meaning = "TIME_ZONE", aoed.field_nbr = curtimezoneapp,
       aoed.parent_id = request->qual[x].case_specimen_id, aoed.sequence = 1, aoed.updt_applctx =
       reqinfo->updt_applctx,
       aoed.updt_cnt = 0, aoed.updt_dt_tm = cnvtdatetime(curdate,curtime), aoed.updt_id = reqinfo->
       updt_id,
       aoed.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET err = "I"
      SET thetable = "D"
      GO TO check_err
     ENDIF
    ENDIF
    SET max_spec_cnt = 0
    SET max_cass_cnt = 0
    SET max_slide_cnt = 0
    SET max_spec_slide_cnt = 0
    SET stat = alterlist(temp->specimen,max_spec_cnt)
    SELECT INTO "nl:"
     cs.case_specimen_id, cassette_id = decode(c.seq,c.cassette_id,0.0), join_path = decode(s.seq,"S",
      s1.seq,"S1"," ")
     FROM case_specimen cs,
      (dummyt d1  WITH seq = 1),
      (dummyt d2  WITH seq = 1),
      (dummyt d3  WITH seq = 1),
      cassette c,
      slide s,
      slide s1
     PLAN (cs
      WHERE (request->qual[x].case_specimen_id=cs.case_specimen_id))
      JOIN (((d1
      WHERE 1=d1.seq)
      JOIN (c
      WHERE cs.case_specimen_id=c.case_specimen_id)
      JOIN (d2
      WHERE 1=d2.seq)
      JOIN (s
      WHERE c.cassette_id=s.cassette_id)
      ) ORJOIN ((d3
      WHERE 1=d3.seq)
      JOIN (s1
      WHERE cs.case_specimen_id=s1.case_specimen_id)
      ))
     ORDER BY cs.case_specimen_id, cassette_id
     HEAD REPORT
      spec_slid_cnt = 0, cass_cnt = 0, slid_cnt = 0,
      inv_cnt = 0
     HEAD cs.case_specimen_id
      spec_slide_cnt = 0, cass_cnt = 0, max_spec_cnt += 1,
      stat = alterlist(temp->specimen,max_spec_cnt), temp->specimen[max_spec_cnt].case_specimen_id =
      cs.case_specimen_id, temp->specimen[max_spec_cnt].cassette_cnt = 0,
      temp->specimen[max_spec_cnt].slide_cnt = 0
      IF ((request->qual[max_spec_cnt].cancel_cd != 0))
       inv_cnt += 1, stat = alterlist(inventory->list,inv_cnt), inventory->list[inv_cnt].
       content_table_name = "CASE_SPECIMEN",
       inventory->list[inv_cnt].content_table_id = cs.case_specimen_id
      ENDIF
     HEAD cassette_id
      slid_cnt = 0
      IF (cassette_id > 0.0)
       cass_cnt += 1, stat = alterlist(temp->specimen[max_spec_cnt].cassette_qual,cass_cnt), temp->
       specimen[max_spec_cnt].cassette_qual[cass_cnt].cassette_id = cassette_id,
       temp->specimen[max_spec_cnt].cassette_cnt = cass_cnt, temp->specimen[max_spec_cnt].
       cassette_qual[cass_cnt].slide_cnt = 0
       IF (cass_cnt > max_cass_cnt)
        max_cass_cnt = cass_cnt
       ENDIF
       IF ((request->qual[max_spec_cnt].cancel_cd != 0))
        inv_cnt += 1, stat = alterlist(inventory->list,inv_cnt), inventory->list[inv_cnt].
        content_table_name = "CASSETTE",
        inventory->list[inv_cnt].content_table_id = cassette_id
       ENDIF
      ENDIF
     DETAIL
      CASE (join_path)
       OF "S":
        slid_cnt += 1,stat = alterlist(temp->specimen[max_spec_cnt].cassette_qual[cass_cnt].
         slide_qual,slid_cnt),
        IF (slid_cnt > max_slide_cnt)
         max_slide_cnt = slid_cnt
        ENDIF
        ,temp->specimen[max_spec_cnt].cassette_qual[cass_cnt].slide_qual[slid_cnt].slide_id = s
        .slide_id,temp->specimen[max_spec_cnt].cassette_qual[cass_cnt].slide_cnt = slid_cnt,
        IF ((request->qual[max_spec_cnt].cancel_cd != 0))
         inv_cnt += 1, stat = alterlist(inventory->list,inv_cnt), inventory->list[inv_cnt].
         content_table_name = "SLIDE",
         inventory->list[inv_cnt].content_table_id = s.slide_id
        ENDIF
       OF "S1":
        spec_slid_cnt += 1,stat = alterlist(temp->specimen[max_spec_cnt].slide_qual,spec_slid_cnt),
        IF (spec_slid_cnt > max_spec_slide_cnt)
         max_spec_slide_cnt = spec_slid_cnt
        ENDIF
        ,temp->specimen[max_spec_cnt].slide_qual[spec_slid_cnt].slide_id = s1.slide_id,temp->
        specimen[max_spec_cnt].slide_cnt = spec_slid_cnt,
        IF ((request->qual[max_spec_cnt].cancel_cd != 0))
         inv_cnt += 1, stat = alterlist(inventory->list,inv_cnt), inventory->list[inv_cnt].
         content_table_name = "SLIDE",
         inventory->list[inv_cnt].content_table_id = s1.slide_id
        ENDIF
      ENDCASE
     FOOT  cassette_id
      IF (cass_cnt > 0)
       stat = alterlist(temp->specimen[max_spec_cnt].cassette_qual[cass_cnt].slide_qual,slid_cnt)
      ENDIF
     FOOT  cs.case_specimen_id
      stat = alterlist(temp->specimen[max_spec_cnt].cassette_qual,cass_cnt), stat = alterlist(temp->
       specimen[max_spec_cnt].slide_qual,spec_slid_cnt)
     FOOT REPORT
      inventory->del_qual_cnt = inv_cnt
     WITH nocounter, outerjoin = d1, outerjoin = d2
    ;end select
    SET stat = alterlist(temp->specimen,max_spec_cnt)
    IF ((inventory->del_qual_cnt > 0))
     EXECUTE scs_del_storage_content  WITH replace("REQUEST","INVENTORY"), replace("REPLY","REPLY")
     IF ((reply->status_data.status="F"))
      SET failed = "T"
      GO TO exit_script
     ENDIF
    ENDIF
    FREE RECORD inventory
    SET reply->status_data.status = "F"
    SET thetable = "P"
    SELECT INTO "nl:"
     pt.case_id
     FROM processing_task pt
     WHERE (pt.case_specimen_id=request->qual[x].case_specimen_id)
      AND  NOT (pt.status_cd IN (cancel_status_cd, verified_status_cd))
      AND pt.create_inventory_flag != 4
     HEAD REPORT
      spec_task_cnt = 0
     DETAIL
      spec_task_cnt += 1, task_cnt += 1, stat = alterlist(reply->task_qual,task_cnt),
      reply->task_qual[task_cnt].id = pt.processing_task_id, reply->task_qual[task_cnt].order_id = pt
      .order_id, reply->task_qual[task_cnt].cancel_cd = request->qual[x].cancel_cd,
      reply->task_qual[task_cnt].request_dt_tm = cnvtdatetime(pt.request_dt_tm)
     WITH nocounter, forupdate(pt)
    ;end select
    IF (curqual != 0)
     UPDATE  FROM processing_task pt
      SET pt.status_cd = request->qual[x].status_cd, pt.status_prsnl_id = reqinfo->updt_id, pt
       .status_dt_tm = cnvtdatetime(curdate,curtime),
       pt.cancel_cd = request->qual[x].cancel_cd, pt.cancel_prsnl_id = reqinfo->updt_id, pt
       .cancel_dt_tm = cnvtdatetime(curdate,curtime),
       pt.updt_dt_tm = cnvtdatetime(curdate,curtime), pt.updt_id = reqinfo->updt_id, pt.updt_task =
       reqinfo->updt_task,
       pt.updt_applctx = reqinfo->updt_applctx, pt.updt_cnt = (pt.updt_cnt+ 1)
      WHERE (pt.case_specimen_id=request->qual[x].case_specimen_id)
       AND  NOT (pt.status_cd IN (cancel_status_cd, verified_status_cd))
       AND pt.create_inventory_flag != 4
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET err = "U"
      GO TO check_err
     ENDIF
    ENDIF
    IF (spec_task_cnt > 0)
     INSERT  FROM ap_ops_exception aoe,
       (dummyt d  WITH seq = value(task_cnt))
      SET aoe.parent_id = reply->task_qual[d.seq].id, aoe.action_flag = 7, aoe.active_ind = 1,
       aoe.updt_dt_tm = cnvtdatetime(curdate,curtime), aoe.updt_id = reqinfo->updt_id, aoe.updt_task
        = reqinfo->updt_task,
       aoe.updt_applctx = reqinfo->updt_applctx, aoe.updt_cnt = 0
      PLAN (d
       WHERE (d.seq > (task_cnt - spec_task_cnt)))
       JOIN (aoe
       WHERE (aoe.parent_id=reply->task_qual[d.seq].id)
        AND aoe.action_flag=7)
      WITH nocounter, outerjoin = d, dontexist
     ;end insert
     IF (curqual != spec_task_cnt)
      SET err = "I"
      SET thetable = "A"
      GO TO check_err
     ENDIF
     IF (curutc=1)
      INSERT  FROM ap_ops_exception_detail aoed,
        (dummyt d  WITH seq = value(task_cnt))
       SET aoed.action_flag = 7, aoed.field_meaning = "TIME_ZONE", aoed.field_nbr = curtimezoneapp,
        aoed.parent_id = reply->task_qual[d.seq].id, aoed.sequence = 1, aoed.updt_applctx = reqinfo->
        updt_applctx,
        aoed.updt_cnt = 0, aoed.updt_dt_tm = cnvtdatetime(curdate,curtime), aoed.updt_id = reqinfo->
        updt_id,
        aoed.updt_task = reqinfo->updt_task
       PLAN (d
        WHERE (d.seq > (task_cnt - spec_task_cnt)))
        JOIN (aoed
        WHERE (aoed.parent_id=reply->task_qual[d.seq].id)
         AND aoed.action_flag=7)
       WITH nocounter, outerjoin = d, dontexist
      ;end insert
      IF (curqual != spec_task_cnt)
       SET err = "I"
       SET thetable = "D"
       GO TO check_err
      ENDIF
     ENDIF
    ENDIF
    IF (max_spec_cnt > 0
     AND ((max_spec_slide_cnt > 0) OR (((max_cass_cnt > 0) OR (((max_slide_cnt > 0) OR (max_cass_cnt
     > 0)) )) )) )
     SELECT INTO "nl:"
      join_path = decode(pt1.seq,"S",pt2.seq,"C",pt3.seq,
       "S1"," ")
      FROM processing_task pt1,
       processing_task pt2,
       processing_task pt3,
       (dummyt d1  WITH seq = value(max_spec_cnt)),
       (dummyt d2  WITH seq = value(max_spec_slide_cnt)),
       (dummyt d3  WITH seq = value(max_cass_cnt)),
       (dummyt d4  WITH seq = value(max_slide_cnt)),
       (dummyt d5  WITH seq = value(max_cass_cnt))
      PLAN (d1)
       JOIN (((d2
       WHERE (d2.seq <= temp->specimen[d1.seq].slide_cnt))
       JOIN (pt1
       WHERE (temp->specimen[d1.seq].case_specimen_id=pt1.case_specimen_id)
        AND (temp->specimen[d1.seq].slide_qual[d2.seq].slide_id=pt1.slide_id)
        AND pt1.cassette_id IN (null, 0)
        AND pt1.status_cd != cancel_status_cd)
       ) ORJOIN ((((d3
       WHERE (d3.seq <= temp->specimen[d1.seq].cassette_cnt))
       JOIN (pt2
       WHERE (temp->specimen[d1.seq].case_specimen_id=pt2.case_specimen_id)
        AND (temp->specimen[d1.seq].cassette_qual[d3.seq].cassette_id=pt2.cassette_id)
        AND pt2.slide_id IN (null, 0)
        AND pt2.status_cd != cancel_status_cd)
       ) ORJOIN ((d5
       WHERE (d5.seq <= temp->specimen[d1.seq].cassette_cnt))
       JOIN (d4
       WHERE (d4.seq <= temp->specimen[d1.seq].cassette_qual[d5.seq].slide_cnt))
       JOIN (pt3
       WHERE (temp->specimen[d1.seq].case_specimen_id=pt3.case_specimen_id)
        AND (temp->specimen[d1.seq].cassette_qual[d5.seq].cassette_id=pt3.cassette_id)
        AND (temp->specimen[d1.seq].cassette_qual[d5.seq].slide_qual[d4.seq].slide_id=pt3.slide_id)
        AND pt3.status_cd != cancel_status_cd)
       )) ))
      DETAIL
       CASE (join_path)
        OF "S":
         temp->specimen[d1.seq].slide_qual[d2.seq].pt_exists = "Y"
        OF "C":
         temp->specimen[d1.seq].cassette_qual[d3.seq].pt_exists = "Y"
        OF "S1":
         temp->specimen[d1.seq].cassette_qual[d5.seq].pt_exists = "Y",temp->specimen[d1.seq].
         cassette_qual[d5.seq].slide_qual[d4.seq].pt_exists = "Y"
       ENDCASE
      WITH nocounter
     ;end select
     IF (max_cass_cnt > 0)
      IF (max_slide_cnt > 0)
       SELECT INTO "nl:"
        pt.case_id
        FROM processing_task pt,
         (dummyt d1  WITH seq = value(max_spec_cnt)),
         (dummyt d2  WITH seq = value(max_cass_cnt)),
         (dummyt d3  WITH seq = value(max_slide_cnt))
        PLAN (d1)
         JOIN (d2
         WHERE (d2.seq <= temp->specimen[d1.seq].cassette_cnt))
         JOIN (d3
         WHERE (d3.seq <= temp->specimen[d1.seq].cassette_qual[d2.seq].slide_cnt))
         JOIN (pt
         WHERE (temp->specimen[d1.seq].cassette_qual[d2.seq].slide_qual[d3.seq].slide_id=pt.slide_id)
          AND (temp->specimen[d1.seq].cassette_qual[d2.seq].slide_qual[d3.seq].pt_exists != "Y"))
        WITH nocounter, forupdate(pt)
       ;end select
       IF (curqual != 0)
        UPDATE  FROM processing_task pt,
          (dummyt d1  WITH seq = value(max_spec_cnt)),
          (dummyt d2  WITH seq = value(max_cass_cnt)),
          (dummyt d3  WITH seq = value(max_slide_cnt))
         SET pt.slide_id = 0.0, pt.updt_dt_tm = cnvtdatetime(curdate,curtime), pt.updt_id = reqinfo->
          updt_id,
          pt.updt_task = reqinfo->updt_task, pt.updt_applctx = reqinfo->updt_applctx, pt.updt_cnt = (
          pt.updt_cnt+ 1)
         PLAN (d1)
          JOIN (d2
          WHERE (d2.seq <= temp->specimen[d1.seq].cassette_cnt))
          JOIN (d3
          WHERE (d3.seq <= temp->specimen[d1.seq].cassette_qual[d2.seq].slide_cnt))
          JOIN (pt
          WHERE (temp->specimen[d1.seq].cassette_qual[d2.seq].slide_qual[d3.seq].slide_id=pt.slide_id
          )
           AND (temp->specimen[d1.seq].cassette_qual[d2.seq].slide_qual[d3.seq].pt_exists != "Y"))
         WITH nocounter
        ;end update
        IF (curqual=0)
         SET err = "U"
         GO TO check_err
        ENDIF
        SET stat = initrec(temp_digital_slide)
        SELECT INTO "nl:"
         ads.ap_digital_slide_id
         FROM ap_digital_slide ads,
          (dummyt d1  WITH seq = value(max_spec_cnt)),
          (dummyt d2  WITH seq = value(max_cass_cnt)),
          (dummyt d3  WITH seq = value(max_slide_cnt))
         PLAN (d1)
          JOIN (d2
          WHERE (d2.seq <= temp->specimen[d1.seq].cassette_cnt))
          JOIN (d3
          WHERE (d3.seq <= temp->specimen[d1.seq].cassette_qual[d2.seq].slide_cnt))
          JOIN (ads
          WHERE (ads.slide_id=temp->specimen[d1.seq].cassette_qual[d2.seq].slide_qual[d3.seq].
          slide_id)
           AND  NOT (ads.slide_id IN (0, null))
           AND (temp->specimen[d1.seq].cassette_qual[d2.seq].slide_qual[d3.seq].pt_exists != "Y"))
         HEAD REPORT
          stat = alterlist(temp_digital_slide->qual,10), cnt = 0
         DETAIL
          cnt += 1
          IF (cnt > size(temp_digital_slide->qual,5))
           stat = alterlist(temp_digital_slide->qual,(cnt+ 9))
          ENDIF
          temp_digital_slide->qual[cnt].digital_slide_id = ads.ap_digital_slide_id
         FOOT REPORT
          stat = alterlist(temp_digital_slide->qual,cnt)
         WITH nocounter
        ;end select
        IF (size(temp_digital_slide->qual,5) > 0)
         DELETE  FROM ap_digital_slide_info adsi,
           (dummyt d  WITH seq = size(temp_digital_slide->qual,5))
          SET adsi.ap_digital_slide_id = temp_digital_slide->qual[d.seq].digital_slide_id
          PLAN (d)
           JOIN (adsi
           WHERE (adsi.ap_digital_slide_id=temp_digital_slide->qual[d.seq].digital_slide_id))
          WITH nocounter
         ;end delete
         DELETE  FROM ap_digital_slide ads,
           (dummyt d  WITH seq = size(temp_digital_slide->qual,5))
          SET ads.ap_digital_slide_id = temp_digital_slide->qual[d.seq].digital_slide_id
          PLAN (d)
           JOIN (ads
           WHERE (ads.ap_digital_slide_id=temp_digital_slide->qual[d.seq].digital_slide_id))
          WITH nocounter
         ;end delete
        ENDIF
        DELETE  FROM slide s,
          (dummyt d1  WITH seq = value(max_spec_cnt)),
          (dummyt d2  WITH seq = value(max_cass_cnt)),
          (dummyt d3  WITH seq = value(max_slide_cnt))
         SET s.seq = 1
         PLAN (d1)
          JOIN (d2
          WHERE (d2.seq <= temp->specimen[d1.seq].cassette_cnt))
          JOIN (d3
          WHERE (d3.seq <= temp->specimen[d1.seq].cassette_qual[d2.seq].slide_cnt))
          JOIN (s
          WHERE (temp->specimen[d1.seq].cassette_qual[d2.seq].slide_qual[d3.seq].slide_id=s.slide_id)
           AND  NOT (s.slide_id IN (0, null))
           AND (temp->specimen[d1.seq].cassette_qual[d2.seq].slide_qual[d3.seq].pt_exists != "Y"))
         WITH nocounter
        ;end delete
       ENDIF
      ENDIF
      SELECT INTO "nl:"
       pt.case_id
       FROM processing_task pt,
        (dummyt d1  WITH seq = value(max_spec_cnt)),
        (dummyt d2  WITH seq = value(max_cass_cnt))
       PLAN (d1)
        JOIN (d2
        WHERE (d2.seq <= temp->specimen[d1.seq].cassette_cnt))
        JOIN (pt
        WHERE (temp->specimen[d1.seq].cassette_qual[d2.seq].cassette_id=pt.cassette_id)
         AND (temp->specimen[d1.seq].cassette_qual[d2.seq].pt_exists != "Y"))
       WITH nocounter, forupdate(pt)
      ;end select
      IF (curqual != 0)
       UPDATE  FROM processing_task pt,
         (dummyt d1  WITH seq = value(max_spec_cnt)),
         (dummyt d2  WITH seq = value(max_cass_cnt))
        SET pt.cassette_id = 0.0, pt.updt_dt_tm = cnvtdatetime(curdate,curtime), pt.updt_id = reqinfo
         ->updt_id,
         pt.updt_task = reqinfo->updt_task, pt.updt_applctx = reqinfo->updt_applctx, pt.updt_cnt = (
         pt.updt_cnt+ 1)
        PLAN (d1)
         JOIN (d2
         WHERE (d2.seq <= temp->specimen[d1.seq].cassette_cnt))
         JOIN (pt
         WHERE (temp->specimen[d1.seq].cassette_qual[d2.seq].cassette_id=pt.cassette_id)
          AND (temp->specimen[d1.seq].cassette_qual[d2.seq].pt_exists != "Y"))
        WITH nocounter
       ;end update
       IF (curqual=0)
        SET err = "U"
        GO TO check_err
       ENDIF
       DELETE  FROM cassette c,
         (dummyt d1  WITH seq = value(max_spec_cnt)),
         (dummyt d2  WITH seq = value(max_cass_cnt))
        SET c.seq = 1
        PLAN (d1)
         JOIN (d2
         WHERE (d2.seq <= temp->specimen[d1.seq].cassette_cnt))
         JOIN (c
         WHERE (temp->specimen[d1.seq].cassette_qual[d2.seq].cassette_id=c.cassette_id)
          AND  NOT (c.cassette_id IN (0, null))
          AND (temp->specimen[d1.seq].cassette_qual[d2.seq].pt_exists != "Y"))
        WITH nocounter
       ;end delete
      ENDIF
     ENDIF
     IF (max_spec_slide_cnt > 0)
      SELECT INTO "nl:"
       pt.case_id
       FROM processing_task pt,
        (dummyt d1  WITH seq = value(max_spec_cnt)),
        (dummyt d2  WITH seq = value(max_spec_slide_cnt))
       PLAN (d1)
        JOIN (d2
        WHERE (d2.seq <= temp->specimen[d1.seq].slide_cnt))
        JOIN (pt
        WHERE (temp->specimen[d1.seq].slide_qual[d2.seq].slide_id=pt.slide_id)
         AND (temp->specimen[d1.seq].slide_qual[d2.seq].pt_exists != "Y"))
       WITH nocounter, forupdate(pt)
      ;end select
      IF (curqual != 0)
       UPDATE  FROM processing_task pt,
         (dummyt d1  WITH seq = value(max_spec_cnt)),
         (dummyt d2  WITH seq = value(max_spec_slide_cnt))
        SET pt.slide_id = 0.0, pt.updt_dt_tm = cnvtdatetime(curdate,curtime), pt.updt_id = reqinfo->
         updt_id,
         pt.updt_task = reqinfo->updt_task, pt.updt_applctx = reqinfo->updt_applctx, pt.updt_cnt = (
         pt.updt_cnt+ 1)
        PLAN (d1)
         JOIN (d2
         WHERE (d2.seq <= temp->specimen[d1.seq].slide_cnt))
         JOIN (pt
         WHERE (temp->specimen[d1.seq].slide_qual[d2.seq].slide_id=pt.slide_id)
          AND (temp->specimen[d1.seq].slide_qual[d2.seq].pt_exists != "Y"))
        WITH nocounter
       ;end update
       IF (curqual=0)
        SET err = "U"
        GO TO check_err
       ENDIF
       SET stat = initrec(temp_digital_slide)
       SELECT INTO "nl:"
        ads.ap_digital_slide_id
        FROM ap_digital_slide ads,
         (dummyt d1  WITH seq = value(max_spec_cnt)),
         (dummyt d2  WITH seq = value(max_spec_slide_cnt))
        PLAN (d1)
         JOIN (d2
         WHERE (d2.seq <= temp->specimen[d1.seq].slide_cnt))
         JOIN (ads
         WHERE (ads.slide_id=temp->specimen[d1.seq].slide_qual[d2.seq].slide_id)
          AND  NOT (ads.slide_id IN (0, null))
          AND (temp->specimen[d1.seq].slide_qual[d2.seq].pt_exists != "Y"))
        HEAD REPORT
         stat = alterlist(temp_digital_slide->qual,10), cnt = 0
        DETAIL
         cnt += 1
         IF (cnt > size(temp_digital_slide->qual,5))
          stat = alterlist(temp_digital_slide->qual,(cnt+ 9))
         ENDIF
         temp_digital_slide->qual[cnt].digital_slide_id = ads.ap_digital_slide_id
        FOOT REPORT
         stat = alterlist(temp_digital_slide->qual,cnt)
        WITH nocounter
       ;end select
       IF (size(temp_digital_slide->qual,5) > 0)
        DELETE  FROM ap_digital_slide_info adsi,
          (dummyt d  WITH seq = size(temp_digital_slide->qual,5))
         SET adsi.ap_digital_slide_id = temp_digital_slide->qual[d.seq].digital_slide_id
         PLAN (d)
          JOIN (adsi
          WHERE (adsi.ap_digital_slide_id=temp_digital_slide->qual[d.seq].digital_slide_id))
         WITH nocounter
        ;end delete
        DELETE  FROM ap_digital_slide ads,
          (dummyt d  WITH seq = size(temp_digital_slide->qual,5))
         SET ads.ap_digital_slide_id = temp_digital_slide->qual[d.seq].digital_slide_id
         PLAN (d)
          JOIN (ads
          WHERE (ads.ap_digital_slide_id=temp_digital_slide->qual[d.seq].digital_slide_id))
         WITH nocounter
        ;end delete
       ENDIF
       DELETE  FROM slide s,
         (dummyt d1  WITH seq = value(max_spec_cnt)),
         (dummyt d2  WITH seq = value(max_spec_slide_cnt))
        SET s.seq = 1
        PLAN (d1)
         JOIN (d2
         WHERE (d2.seq <= temp->specimen[d1.seq].slide_cnt))
         JOIN (s
         WHERE (temp->specimen[d1.seq].slide_qual[d2.seq].slide_id=s.slide_id)
          AND  NOT (s.slide_id IN (0, null))
          AND (temp->specimen[d1.seq].slide_qual[d2.seq].pt_exists != "Y"))
        WITH nocounter
       ;end delete
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (specimen_tag_chg_ind=1)
    SELECT INTO "nl:"
     pt.case_id
     FROM processing_task pt
     WHERE (pt.case_specimen_id=request->qual[x].case_specimen_id)
      AND pt.create_inventory_flag != 4
     WITH nocounter, forupdate(pt)
    ;end select
    IF (curqual != 0)
     UPDATE  FROM processing_task pt
      SET pt.case_specimen_tag_id = request->qual[x].specimen_tag_cd, pt.updt_dt_tm = cnvtdatetime(
        curdate,curtime), pt.updt_id = reqinfo->updt_id,
       pt.updt_task = reqinfo->updt_task, pt.updt_applctx = reqinfo->updt_applctx, pt.updt_cnt = (pt
       .updt_cnt+ 1)
      WHERE (pt.case_specimen_id=request->qual[x].case_specimen_id)
       AND pt.create_inventory_flag != 4
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET err = "U"
      GO TO check_err
     ENDIF
    ENDIF
   ENDIF
   SET thetable = "L"
   SELECT INTO "nl:"
    FROM long_text lt
    WHERE (request->qual[x].spec_comments_long_text_id > 0)
     AND (lt.long_text_id=request->qual[x].spec_comments_long_text_id)
    DETAIL
     spec_lt_cur_updt_cnt = lt.updt_cnt
    WITH forupdate(lt)
   ;end select
   IF ((request->qual[x].spec_comments_long_text_id > 0))
    IF (curqual=0)
     SET err = "L"
     GO TO check_err
    ENDIF
    IF ((request->qual[x].spec_lt_updt_cnt != spec_lt_cur_updt_cnt))
     SET err = "U"
     GO TO check_err
    ENDIF
    SET spec_lt_cur_updt_cnt += 1
   ENDIF
   UPDATE  FROM long_text lt
    SET lt.updt_cnt = spec_lt_cur_updt_cnt, lt.updt_dt_tm = cnvtdatetime(curdate,curtime), lt.updt_id
      = reqinfo->updt_id,
     lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx, lt.long_text =
     request->qual[x].special_comments
    WHERE (request->qual[x].spec_comments_long_text_id=lt.long_text_id)
     AND (request->qual[x].spec_comments_long_text_id > 0)
    WITH nocounter
   ;end update
   IF ((request->qual[x].spec_comments_long_text_id > 0))
    IF (curqual=0)
     SET err = "U"
     GO TO check_err
    ENDIF
   ENDIF
   SET thetable = "P"
   SELECT INTO "nl:"
    pt.*
    FROM processing_task pt
    WHERE (request->qual[x].case_specimen_id=pt.case_specimen_id)
     AND 4=pt.create_inventory_flag
    DETAIL
     cur_updt_cnt = pt.updt_cnt, order_id = pt.order_id, service_resource_cd = pt.service_resource_cd,
     reply->case_id = pt.case_id
    WITH forupdate(pt)
   ;end select
   IF (curqual=0)
    SET err = "L"
    GO TO check_err
   ENDIF
   IF ((request->qual[x].pt_updt_cnt != cur_updt_cnt))
    IF ((request->qual[x].order_id=0)
     AND order_id != 0)
     IF ((service_resource_cd != request->qual[x].processing_location_cd)
      AND (request->qual[x].processing_location_cd=0))
      SET request->qual[x].processing_location_cd = service_resource_cd
     ENDIF
    ELSE
     SET err = "U"
     GO TO check_err
    ENDIF
   ENDIF
   SET cur_updt_cnt += 1
   UPDATE  FROM processing_task pt
    SET pt.case_specimen_id = request->qual[x].case_specimen_id, pt.case_specimen_tag_id = request->
     qual[x].specimen_tag_cd, pt.service_resource_cd = request->qual[x].processing_location_cd,
     pt.priority_cd = request->qual[x].request_priority_cd, pt.status_cd = request->qual[x].status_cd,
     pt.status_prsnl_id = reqinfo->updt_id,
     pt.status_dt_tm = cnvtdatetime(curdate,curtime), pt.cancel_cd = request->qual[x].cancel_cd, pt
     .cancel_prsnl_id =
     IF ((request->qual[x].cancel_cd > 0.0)) reqinfo->updt_id
     ELSE 0.0
     ENDIF
     ,
     pt.cancel_dt_tm =
     IF ((request->qual[x].cancel_cd > 0.0)) cnvtdatetime(curdate,curtime)
     ENDIF
     , pt.updt_dt_tm = cnvtdatetime(curdate,curtime), pt.updt_id = reqinfo->updt_id,
     pt.updt_task = reqinfo->updt_task, pt.updt_applctx = reqinfo->updt_applctx, pt
     .comments_long_text_id =
     IF ((request->qual[x].task_comments_long_text_id > 0)) request->qual[x].
      task_comments_long_text_id
     ELSE new_task_comments_long_text_id
     ENDIF
     ,
     pt.updt_cnt = cur_updt_cnt
    WHERE (request->qual[x].case_specimen_id=pt.case_specimen_id)
     AND 4=pt.create_inventory_flag
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET err = "U"
    GO TO check_err
   ENDIF
   SET thetable = "L"
   SELECT INTO "nl:"
    FROM long_text lt
    WHERE (request->qual[x].task_comments_long_text_id > 0)
     AND (lt.long_text_id=request->qual[x].task_comments_long_text_id)
    DETAIL
     task_lt_cur_updt_cnt = lt.updt_cnt
    WITH forupdate(lt)
   ;end select
   IF ((request->qual[x].task_comments_long_text_id > 0))
    IF (curqual=0)
     SET err = "L"
     GO TO check_err
    ENDIF
    IF ((request->qual[x].task_lt_updt_cnt != task_lt_cur_updt_cnt))
     SET err = "U"
     GO TO check_err
    ENDIF
    SET task_lt_cur_updt_cnt += 1
   ENDIF
   UPDATE  FROM long_text lt
    SET lt.updt_cnt = task_lt_cur_updt_cnt, lt.updt_dt_tm = cnvtdatetime(curdate,curtime), lt.updt_id
      = reqinfo->updt_id,
     lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx, lt.long_text =
     request->qual[x].task_comments
    WHERE (request->qual[x].task_comments_long_text_id=lt.long_text_id)
     AND (request->qual[x].task_comments_long_text_id > 0)
    WITH nocounter
   ;end update
   IF ((request->qual[x].task_comments_long_text_id > 0))
    IF (curqual=0)
     SET err = "U"
     GO TO check_err
    ENDIF
   ENDIF
   IF (((nspecchangeind=1) OR (nspeccancelind=1)) )
    IF (size(req200423->spec_qual,5)=0)
     SET stat = alterlist(req200423->spec_qual,1)
    ENDIF
    SET req200423->spec_qual[1].case_specimen_id = request->qual[x].case_specimen_id
    SET req200423->spec_qual[1].delete_flag = 0
    IF (nspeccancelind=1)
     SET req200423->spec_qual[1].delete_flag = 1
    ENDIF
    EXECUTE aps_chk_case_synoptic_ws  WITH replace("REQUEST","REQ200423"), replace("REPLY",
     "REP200423")
    IF ((rep200423->status_data.status != "S"))
     SET thetable = "W"
     SET err = "U"
     GO TO check_err
    ENDIF
   ENDIF
   COMMIT
 ENDFOR
 GO TO exit_script
#check_err
 SET failures += 1
 IF (failures > 1)
  SET stat = alter(reply->status_data.subeventstatus,failures)
  SET stat = alter(reply->qual,failures)
 ENDIF
 SET reply->qual[failures].case_specimen_id = request->qual[x].case_specimen_id
 SET reply->status_data.subeventstatus[failures].operationstatus = "F"
 SET reply->status_data.subeventstatus[failures].targetobjectname = "TABLE"
 IF (thetable="C")
  SET reply->status_data.subeventstatus[failures].targetobjectvalue = "CASE_SPECIMEN"
 ELSEIF (thetable="T")
  SET reply->status_data.subeventstatus[failures].targetobjectvalue = "LONG_TEXT"
 ELSEIF (thetable="S")
  SET reply->status_data.subeventstatus[failures].targetobjectvalue = "LT SEQ SELECT"
 ELSEIF (thetable="A")
  SET reply->status_data.subeventstatus[failures].targetobjectvalue = "AP_OPS_EXCEPTION"
 ELSEIF (thetable="D")
  SET reply->status_data.subeventstatus[failures].targetobjectvalue = "AP_OPS_EXCEPTION_DETAIL"
 ELSEIF (thetable="W")
  SET reply->status_data.subeventstatus[failures].targetobjectvalue = "AP_CASE_SYNOPTIC_WS"
 ELSEIF (thetable="V")
  SET reply->status_data.subeventstatus[failures].targetobjectvalue = "CODE_VALUE"
 ELSE
  SET reply->status_data.subeventstatus[failures].targetobjectvalue = "PROCESSING_TASK"
 ENDIF
 IF (err="L")
  SET reply->status_data.subeventstatus[failures].operationname = "LOCK"
 ELSEIF (err="I")
  SET reply->status_data.subeventstatus[failures].operationname = "INSERT"
 ELSEIF (err="S")
  SET reply->status_data.subeventstatus[failures].operationname = "SELECT"
 ELSE
  SET reply->status_data.subeventstatus[failures].operationname = "UPDATE"
 ENDIF
 SET failed = "T"
 ROLLBACK
 SET x += 1
 GO TO start_loop
#exit_script
 FREE RECORD req200423
 FREE RECORD rep200423
 IF (failed="F")
  SET reply->status_data.status = "S"
 ELSE
  IF (failures < nbr_to_chg)
   SET reply->status_data.status = "P"
  ENDIF
 ENDIF
END GO
