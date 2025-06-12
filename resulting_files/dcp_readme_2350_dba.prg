CREATE PROGRAM dcp_readme_2350:dba
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
 RECORD blob(
   1 qual[*]
     2 old_refr_text_id = f8
     2 new_refr_text_id = f8
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 text_type_cd = f8
     2 old_ref_text_reltn_id = f8
     2 new_ref_text_reltn_id = f8
     2 long_text_id = f8
     2 long_text = vc
     2 long_blob_id = f8
     2 add_ind = i2
 )
 DECLARE blobcnt = i4 WITH noconstant(0)
 DECLARE dupaddcnt = i4 WITH noconstant(0)
 DECLARE multdupcnt = i4 WITH noconstant(0)
 DECLARE existcnt = i4 WITH noconstant(0)
 DECLARE total_count = i4 WITH noconstant(0)
 DECLARE loop = i4 WITH noconstant(0)
 DECLARE lowcnt = i4 WITH noconstant(0)
 DECLARE highcnt = i4 WITH noconstant(100)
 DECLARE iteration_count = i4 WITH noconstant(0)
 DECLARE exitwhile = i2 WITH noconstant(false)
 DECLARE founddup = i2 WITH noconstant(false)
 DECLARE rdm_errcode = i4 WITH noconstant(0)
 DECLARE rdm_errmsg = c132
 DECLARE errmsg = c132
 DECLARE readme_status = c1
 SET rdm_errmsg = fillstring(132," ")
 SET errmsg = fillstring(132," ")
 SET readme_status = "S"
 SET rdm_errcode = error(rdm_errmsg,1)
 CALL echo("Starting dcp_readme_2350")
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_name="Reference Text Readme"
 ;end select
 IF (curqual > 0)
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_name="Reference Text Readme"
   WITH nocounter, forupdate(di)
  ;end select
  IF (curqual=0)
   SET readme_status = "F"
   SET rdm_errmsg = "Could not lock row on DM_INFO table"
   GO TO exit_readme
  ELSE
   CALL echo("Row locked on DM_INFO table")
  ENDIF
  UPDATE  FROM dm_info di
   SET di.info_char = " ", di.info_date = cnvtdatetime(curdate,curtime3), di.info_domain = " ",
    di.info_long_id = 0, di.info_number = 0, di.updt_applctx = 0,
    di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = 2350,
    di.updt_task = 0
   WHERE di.info_name="Reference Text Readme"
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET readme_status = "F"
   SET rdm_errmsg = "Could not update rows on DM_INFO table"
   GO TO exit_readme
  ELSE
   CALL echo("Row updated on DM_INFO table")
   COMMIT
  ENDIF
 ELSE
  INSERT  FROM dm_info di
   SET di.info_name = "Reference Text Readme", di.info_date = cnvtdatetime(curdate,curtime3), di
    .updt_applctx = 0,
    di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = 2350,
    di.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET readme_status = "F"
   SET rdm_errmsg = "Could not set readme run date on DM_INFO table"
   GO TO exit_readme
  ELSE
   CALL echo("Stamped ReadMe start date time on DM_INFO table")
   COMMIT
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM ref_text_reltn rtr
  WHERE rtr.ref_text_reltn_id > 0.0
  HEAD REPORT
   existcnt = 0
  DETAIL
   existcnt = (existcnt+ 1)
  WITH nocounter
 ;end select
 IF (existcnt=0)
  SET readme_status = "S"
  SET rdm_errmsg = "No rows on ref_text_reltn table"
  GO TO exit_readme
 ENDIF
 SELECT INTO "nl:"
  FROM ref_text_reltn rtr
  WHERE rtr.ref_text_reltn_id > 0
  WITH nocounter, forupdate(rtr)
 ;end select
 IF (curqual=0)
  SET readme_status = "F"
  SET rdm_errmsg = "Could not lock row on REF_TEXT_RELTN table"
  GO TO exit_readme
 ELSE
  CALL echo("Rows locked on REF_TEXT_RELTN table")
 ENDIF
 UPDATE  FROM ref_text_reltn rtr
  SET rtr.active_ind = 1, rtr.beg_effective_dt_tm = rtr.updt_dt_tm, rtr.end_effective_dt_tm =
   cnvtdatetime("31-DEC-2100 00:00:00.00")
  WHERE rtr.ref_text_reltn_id > 0
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET readme_status = "F"
  SET rdm_errmsg = "ref_text_reltn table could not be updated"
  GO TO exit_readme
 ELSE
  CALL echo("Updated new fields on REF_TEXT_RELTN table")
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  FROM ref_text_reltn rtr,
   ref_text rt,
   long_text lt
  PLAN (rtr
   WHERE rtr.active_ind=1)
   JOIN (rt
   WHERE rt.text_entity_name="LONG_TEXT"
    AND rt.refr_text_id=rtr.refr_text_id
    AND rt.active_ind=1)
   JOIN (lt
   WHERE lt.long_text_id=rt.text_entity_id
    AND lt.active_ind=1)
  ORDER BY rtr.refr_text_id
  HEAD REPORT
   blobcnt = 0
  DETAIL
   blobcnt = (blobcnt+ 1)
   IF (mod(blobcnt,10)=1)
    stat = alterlist(blob->qual,(blobcnt+ 9))
   ENDIF
   blob->qual[blobcnt].parent_entity_id = rtr.parent_entity_id, blob->qual[blobcnt].
   parent_entity_name = rtr.parent_entity_name, blob->qual[blobcnt].text_type_cd = rtr.text_type_cd,
   blob->qual[blobcnt].old_refr_text_id = rt.refr_text_id, blob->qual[blobcnt].new_refr_text_id = 0,
   blob->qual[blobcnt].old_ref_text_reltn_id = rtr.ref_text_reltn_id,
   blob->qual[blobcnt].new_ref_text_reltn_id = 0, blob->qual[blobcnt].long_text = trim(lt.long_text),
   blob->qual[blobcnt].long_text_id = lt.long_text_id,
   blob->qual[blobcnt].add_ind = 1
  FOOT REPORT
   stat = alterlist(blob->qual,blobcnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET readme_status = "Q"
  CALL echo("No rows returned with ref_text.text_entity_name = LONG_TEXT")
  GO TO exit_readme
 ELSE
  CALL echo("Blob record populated where ref_text.text_entity_name = LONG_TEXT")
  CALL echo(build("BlobCnt: ",blobcnt))
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(blobcnt)),
   ref_text_reltn rtr
  PLAN (d)
   JOIN (rtr
   WHERE (rtr.parent_entity_name=blob->qual[d.seq].parent_entity_name)
    AND (rtr.parent_entity_id=blob->qual[d.seq].parent_entity_id)
    AND (rtr.text_type_cd=blob->qual[d.seq].text_type_cd)
    AND rtr.active_ind=1)
  ORDER BY d.seq, rtr.updt_dt_tm DESC
  HEAD REPORT
   dupaddcnt = 0
  HEAD d.seq
   founddup = false
  DETAIL
   IF (founddup=false)
    dupaddcnt = (dupaddcnt+ 1), blob->qual[d.seq].parent_entity_id = rtr.parent_entity_id, blob->
    qual[d.seq].parent_entity_name = rtr.parent_entity_name,
    blob->qual[d.seq].text_type_cd = rtr.text_type_cd, founddup = true
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET readme_status = "Q"
  CALL echo("No duplicate rows returned")
 ELSE
  CALL echo(build("Number of duplicates added: ",dupaddcnt))
 ENDIF
 CALL echorecord(blob)
 FOR (loop = 1 TO blobcnt)
   IF ((blob->qual[loop].add_ind=1))
    SELECT INTO "nl:"
     j = seq(reference_seq,nextval)"######################;RP0"
     FROM dual
     DETAIL
      blob->qual[loop].new_refr_text_id = cnvtreal(j)
     WITH format, nocounter
    ;end select
    SELECT INTO "nl:"
     j = seq(reference_seq,nextval)"######################;RP0"
     FROM dual
     DETAIL
      blob->qual[loop].new_ref_text_reltn_id = cnvtreal(j)
     WITH format, nocounter
    ;end select
    SELECT INTO "nl:"
     j = seq(long_data_seq,nextval)"######################;RP0"
     FROM dual
     DETAIL
      blob->qual[loop].long_blob_id = cnvtreal(j)
     WITH format, nocounter
    ;end select
   ENDIF
 ENDFOR
 IF (blobcnt < highcnt)
  SET highcnt = blobcnt
 ENDIF
 WHILE (highcnt <= blobcnt
  AND exitwhile=false)
   SET iteration_count = (iteration_count+ 1)
   INSERT  FROM long_blob lb,
     (dummyt d  WITH seq = value(blobcnt))
    SET lb.parent_entity_id = blob->qual[d.seq].new_refr_text_id, lb.long_blob = blob->qual[d.seq].
     long_text, lb.long_blob_id = blob->qual[d.seq].long_blob_id,
     lb.parent_entity_name = "REF_TEXT", lb.active_ind = 1, lb.active_status_cd = reqdata->
     active_status_cd,
     lb.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lb.active_status_prsnl_id = 0, lb
     .updt_applctx = 0,
     lb.updt_cnt = 0, lb.updt_dt_tm = cnvtdatetime(curdate,curtime3), lb.updt_id = 2350,
     lb.updt_task = 0
    PLAN (d
     WHERE (blob->qual[d.seq].add_ind=1)
      AND d.seq > lowcnt
      AND d.seq <= highcnt)
     JOIN (lb)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET readme_status = "F"
    SET rdm_errmsg = "Error inserting reference text into long_blob table"
    GO TO exit_readme
   ELSE
    CALL echo("Inserted reference text rows on LONG_BLOB table")
   ENDIF
   INSERT  FROM ref_text rt,
     (dummyt d  WITH seq = value(blobcnt))
    SET rt.refr_text_id = blob->qual[d.seq].new_refr_text_id, rt.text_type_cd = blob->qual[d.seq].
     text_type_cd, rt.text_entity_name = "LONG_BLOB",
     rt.text_entity_id = blob->qual[d.seq].long_blob_id, rt.text_type_flag = 0, rt.active_ind = 1,
     rt.updt_dt_tm = cnvtdatetime(curdate,curtime3), rt.updt_id = 2350, rt.updt_task = 0,
     rt.updt_applctx = 0, rt.updt_cnt = 0
    PLAN (d
     WHERE (blob->qual[d.seq].add_ind=1)
      AND d.seq > lowcnt
      AND d.seq <= highcnt)
     JOIN (rt)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET readme_status = "F"
    SET rdm_errmsg = "Error inserting to ref_text table"
    GO TO exit_readme
   ELSE
    CALL echo("Inserted identical rows on REF_TEXT table")
   ENDIF
   INSERT  FROM ref_text_reltn rtr,
     (dummyt d  WITH seq = value(blobcnt))
    SET rtr.ref_text_reltn_id = blob->qual[d.seq].new_ref_text_reltn_id, rtr.parent_entity_name =
     blob->qual[d.seq].parent_entity_name, rtr.parent_entity_id = blob->qual[d.seq].parent_entity_id,
     rtr.refr_text_id = blob->qual[d.seq].new_refr_text_id, rtr.text_type_cd = blob->qual[d.seq].
     text_type_cd, rtr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     rtr.updt_id = 2350, rtr.updt_task = 0, rtr.updt_applctx = 0,
     rtr.updt_cnt = 0, rtr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), rtr
     .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
     rtr.active_ind = 1
    PLAN (d
     WHERE (blob->qual[d.seq].add_ind=1)
      AND d.seq > lowcnt
      AND d.seq <= highcnt)
     JOIN (rtr)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET readme_status = "F"
    SET rdm_errmsg = "Error inserting to ref_text_reltn table"
    GO TO exit_readme
   ELSE
    CALL echo("Inserted identical rows on REF_TEXT_RELTN table")
   ENDIF
   IF (highcnt != blobcnt)
    SET lowcnt = (lowcnt+ 100)
    SET highcnt = (highcnt+ 100)
    IF (highcnt > blobcnt)
     SET highcnt = blobcnt
    ENDIF
   ELSE
    SET exitwhile = true
   ENDIF
   CALL echo(build("Iteration_count: ",iteration_count))
   CALL echo(build("lowCnt: ",lowcnt))
   CALL echo(build("highCnt: ",highcnt))
   COMMIT
 ENDWHILE
#exit_readme
 FREE RECORD blob
 CALL echo("Updating readme status.......")
 IF (readme_status="F")
  SET readme_data->status = "F"
  SET readme_data->message = rdm_errmsg
  ROLLBACK
 ELSEIF (readme_status="S")
  SET readme_data->status = "S"
  SET readme_data->message =
  "Successfully copied reference text from long_text table to long_blob table."
 ELSEIF (readme_status="Q")
  SET readme_data->status = "S"
  SET readme_data->message = "Reference text already moved to long_blob table. Nothing altered."
  ROLLBACK
 ENDIF
 CALL echo(build("readme_data->status:",readme_data->status))
 CALL echo(build("readme_data->message:",readme_data->message))
 EXECUTE dm_readme_status
 SET script_version = "003 02/23/04 RR4690"
END GO
