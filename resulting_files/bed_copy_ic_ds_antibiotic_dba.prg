CREATE PROGRAM bed_copy_ic_ds_antibiotic:dba
 IF ( NOT (validate(reply,0)))
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
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE ant_size = i4 WITH protect
 DECLARE updt_tot_cnt = i4 WITH protect
 DECLARE delete_tot_cnt = i4 WITH protect
 DECLARE lt_delete_id_tot_cnt = i4 WITH protect
 DECLARE new_item_tot_cnt = i4 WITH protect
 FREE SET temp_rows_to_update
 RECORD temp_rows_to_update(
   1 rows[*]
     2 lh_cnt_ic_antibgrm_org_dsc_id = f8
     2 long_text_id = f8
     2 suppress_ind = i2
 )
 FREE SET temp_rows_to_delete
 RECORD temp_rows_to_delete(
   1 rows[*]
     2 lh_cnt_ic_antibgrm_org_dsc_id = f8
 )
 FREE SET temp_long_text_to_delete
 RECORD temp_long_text_to_delete(
   1 rows[*]
     2 long_text_id = f8
 )
 FREE SET temp_req
 RECORD temp_req(
   1 req_items[*]
     2 action_flag = i2
     2 organism_cd = f8
     2 disclaimer_text = vc
     2 suppression_ind = i2
     2 specimen_group_id = f8
     2 antibiotic_cd = f8
     2 new_long_text_id = f8
     2 new_dsc_id = f8
 )
 SET ant_size = size(request->copy_ants,5)
 IF (ant_size=0)
  GO TO exit_script
 ENDIF
 SET updt_tot_cnt = 0
 SET updt_cnt = 0
 SET stat = alterlist(temp_rows_to_update->rows,10)
 SET delete_tot_cnt = 0
 SET delete_cnt = 0
 SET stat = alterlist(temp_rows_to_delete->rows,10)
 SET lt_delete_id_tot_cnt = 0
 SET lt_delete_id_cnt = 0
 SET stat = alterlist(temp_long_text_to_delete->rows,10)
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(ant_size)),
   lh_cnt_ic_antibgrm_org_dsc dsc
  PLAN (d)
   JOIN (dsc
   WHERE (dsc.facility_cd=request->facility_cd)
    AND (dsc.organism_cd=request->organism_cd)
    AND (dsc.antibiotic_cd=request->copy_ants[d.seq].antibiotic_cd))
  DETAIL
   IF ((((request->updt_mode=0)
    AND dsc.suppress_ind=1) OR ((request->updt_mode=1)
    AND dsc.long_text_id > 0)) )
    updt_tot_cnt = (updt_tot_cnt+ 1), updt_cnt = (updt_cnt+ 1)
    IF (updt_cnt=10)
     stat = alterlist(temp_rows_to_update->rows,(updt_tot_cnt+ 10)), updt_cnt = 1
    ENDIF
    temp_rows_to_update->rows[updt_tot_cnt].lh_cnt_ic_antibgrm_org_dsc_id = dsc
    .lh_cnt_ic_antibgrm_org_dsc_id
    IF ((request->updt_mode=0))
     temp_rows_to_update->rows[updt_tot_cnt].long_text_id = 0, temp_rows_to_update->rows[updt_tot_cnt
     ].suppress_ind = 1
    ELSE
     temp_rows_to_update->rows[updt_tot_cnt].long_text_id = dsc.long_text_id, temp_rows_to_update->
     rows[updt_tot_cnt].suppress_ind = 0
    ENDIF
   ELSE
    delete_tot_cnt = (delete_tot_cnt+ 1), delete_cnt = (delete_cnt+ 1)
    IF (delete_cnt=10)
     stat = alterlist(temp_rows_to_delete->rows,(delete_tot_cnt+ 10)), delete_cnt = 1
    ENDIF
    temp_rows_to_delete->rows[delete_tot_cnt].lh_cnt_ic_antibgrm_org_dsc_id = dsc
    .lh_cnt_ic_antibgrm_org_dsc_id
   ENDIF
   IF ((request->updt_mode=0)
    AND dsc.long_text_id > 0)
    lt_delete_id_tot_cnt = (lt_delete_id_tot_cnt+ 1), lt_delete_id_cnt = (lt_delete_id_cnt+ 1)
    IF (lt_delete_id_cnt=10)
     stat = alterlist(temp_long_text_to_delete->rows,(lt_delete_id_tot_cnt+ 10)), lt_delete_id_cnt =
     1
    ENDIF
    temp_long_text_to_delete->rows[lt_delete_id_tot_cnt].long_text_id = dsc.long_text_id
   ENDIF
  WITH nocounter
 ;end select
 CALL bederrorcheck("Retrieving Existing Build")
 SET stat = alterlist(temp_rows_to_update->rows,updt_tot_cnt)
 SET stat = alterlist(temp_rows_to_delete->rows,delete_tot_cnt)
 SET stat = alterlist(temp_long_text_to_delete->rows,lt_delete_id_tot_cnt)
 IF (updt_tot_cnt > 0)
  UPDATE  FROM lh_cnt_ic_antibgrm_org_dsc dsc,
    (dummyt d  WITH seq = value(updt_tot_cnt))
   SET dsc.long_text_id = temp_rows_to_update->rows[d.seq].long_text_id, dsc.suppress_ind =
    temp_rows_to_update->rows[d.seq].suppress_ind
   PLAN (d)
    JOIN (dsc
    WHERE (dsc.lh_cnt_ic_antibgrm_org_dsc_id=temp_rows_to_update->rows[d.seq].
    lh_cnt_ic_antibgrm_org_dsc_id))
   WITH nocounter
  ;end update
  CALL bederrorcheck("Disclaimer Initial Update Error")
 ENDIF
 IF (delete_tot_cnt > 0)
  DELETE  FROM lh_cnt_ic_antibgrm_org_dsc dsc,
    (dummyt d  WITH seq = value(delete_tot_cnt))
   SET dsc.seq = 1
   PLAN (d)
    JOIN (dsc
    WHERE (dsc.lh_cnt_ic_antibgrm_org_dsc_id=temp_rows_to_delete->rows[d.seq].
    lh_cnt_ic_antibgrm_org_dsc_id))
   WITH nocounter
  ;end delete
  CALL bederrorcheck("Disclaimer Initial Delete Error")
 ENDIF
 IF (lt_delete_id_cnt > 0)
  DELETE  FROM long_text_reference lt,
    (dummyt d  WITH seq = value(lt_delete_id_tot_cnt))
   SET lt.seq = 1
   PLAN (d)
    JOIN (lt
    WHERE (lt.long_text_id=temp_long_text_to_delete->rows[d.seq].long_text_id))
   WITH nocounter
  ;end delete
  CALL bederrorcheck("Long Text Delete Error")
 ENDIF
 SET new_item_tot_cnt = 0
 SET new_item_cnt = 0
 SET stat = alterlist(temp_req->req_items,20)
 SELECT INTO "NL:"
  FROM lh_cnt_ic_antibgrm_org_dsc dsc,
   long_text_reference lt
  PLAN (dsc
   WHERE (dsc.organism_cd=request->organism_cd)
    AND (dsc.facility_cd=request->facility_cd)
    AND (dsc.antibiotic_cd=request->source_antibiotic_cd)
    AND (((request->updt_mode=0)
    AND dsc.long_text_id > 0) OR ((request->updt_mode=1)
    AND dsc.suppress_ind=1)) )
   JOIN (lt
   WHERE lt.long_text_id=outerjoin(dsc.long_text_id))
  DETAIL
   FOR (x = 1 TO ant_size)
     new_item_tot_cnt = (new_item_tot_cnt+ 1), new_item_cnt = (new_item_cnt+ 1)
     IF (new_item_cnt=20)
      stat = alterlist(temp_req->req_items,(new_item_tot_cnt+ 20)), new_item_cnt = 1
     ENDIF
     IF ((request->updt_mode=0)
      AND dsc.long_text_id > 0)
      temp_req->req_items[new_item_tot_cnt].disclaimer_text = lt.long_text
     ELSEIF ((request->updt_mode=1)
      AND dsc.suppress_ind=1)
      temp_req->req_items[new_item_tot_cnt].suppression_ind = 1
     ENDIF
     temp_req->req_items[new_item_tot_cnt].specimen_group_id = dsc.lh_cnt_ic_antibgrm_group_id,
     temp_req->req_items[new_item_tot_cnt].antibiotic_cd = request->copy_ants[x].antibiotic_cd,
     temp_req->req_items[new_item_tot_cnt].organism_cd = request->organism_cd,
     temp_req->req_items[new_item_tot_cnt].action_flag = 1
   ENDFOR
  WITH nocounter
 ;end select
 CALL bederrorcheck("Retrieving copy from source organism")
 SET stat = alterlist(temp_req->req_items,new_item_tot_cnt)
 SELECT INTO "NL:"
  FROM lh_cnt_ic_antibgrm_org_dsc dsc,
   (dummyt d  WITH seq = value(new_item_tot_cnt)),
   long_text_reference lt
  PLAN (dsc)
   JOIN (d
   WHERE (dsc.organism_cd=temp_req->req_items[d.seq].organism_cd)
    AND (dsc.lh_cnt_ic_antibgrm_group_id=temp_req->req_items[d.seq].specimen_group_id)
    AND (dsc.antibiotic_cd=temp_req->req_items[d.seq].antibiotic_cd)
    AND (dsc.facility_cd=request->facility_cd))
   JOIN (lt
   WHERE lt.long_text_id=outerjoin(dsc.long_text_id))
  DETAIL
   temp_req->req_items[d.seq].new_dsc_id = dsc.lh_cnt_ic_antibgrm_org_dsc_id, temp_req->req_items[d
   .seq].action_flag = 2
   IF ((request->updt_mode=0))
    temp_req->req_items[d.seq].suppression_ind = dsc.suppress_ind
   ELSE
    temp_req->req_items[d.seq].disclaimer_text = lt.long_text
   ENDIF
  WITH nocounter
 ;end select
 CALL bederrorcheck("Retrieving existing data from copy to organisms")
 DECLARE new_id = f8 WITH protect
 DECLARE long_text_id = f8 WITH protect
 FOR (x = 1 TO new_item_tot_cnt)
   IF ((temp_req->req_items[x].action_flag=1))
    SELECT INTO "NL:"
     j = seq(reference_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_id = cnvtreal(j)
     WITH format, counter
    ;end select
    CALL bederrorcheck("Sequence Error")
    SET temp_req->req_items[x].new_dsc_id = new_id
   ENDIF
   IF ((temp_req->req_items[x].disclaimer_text > " "))
    SELECT INTO "nl:"
     j = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      long_text_id = cnvtreal(j)
     WITH format, nocounter
    ;end select
   ENDIF
   SET temp_req->req_items[x].new_long_text_id = long_text_id
 ENDFOR
 INSERT  FROM long_text_reference lt,
   (dummyt d  WITH seq = value(new_item_tot_cnt))
  SET lt.long_text_id = temp_req->req_items[d.seq].new_long_text_id, lt.parent_entity_name =
   "LH_CNT_IC_ANTIBGRM_ORG_DSC", lt.parent_entity_id = temp_req->req_items[d.seq].new_dsc_id,
   lt.long_text = temp_req->req_items[d.seq].disclaimer_text, lt.active_ind = 1, lt.updt_applctx =
   reqinfo->updt_applctx,
   lt.updt_id = reqinfo->updt_id, lt.updt_cnt = 0, lt.updt_task = reqinfo->updt_task,
   lt.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (d
   WHERE (temp_req->req_items[d.seq].disclaimer_text > " ")
    AND (temp_req->req_items[d.seq].new_long_text_id > 0.0))
   JOIN (lt)
  WITH nocounter
 ;end insert
 CALL bederrorcheck("Insert disclaimer suppresion long text table Error")
 INSERT  FROM lh_cnt_ic_antibgrm_org_dsc dsc,
   (dummyt d  WITH seq = value(new_item_tot_cnt))
  SET dsc.lh_cnt_ic_antibgrm_org_dsc_id = temp_req->req_items[d.seq].new_dsc_id, dsc.facility_cd =
   request->facility_cd, dsc.organism_cd = temp_req->req_items[d.seq].organism_cd,
   dsc.antibiotic_cd = temp_req->req_items[d.seq].antibiotic_cd, dsc.lh_cnt_ic_antibgrm_group_id =
   temp_req->req_items[d.seq].specimen_group_id, dsc.long_text_id = temp_req->req_items[d.seq].
   new_long_text_id,
   dsc.suppress_ind = temp_req->req_items[d.seq].suppression_ind, dsc.updt_applctx = reqinfo->
   updt_applctx, dsc.updt_id = reqinfo->updt_id,
   dsc.updt_cnt = 0, dsc.updt_task = reqinfo->updt_task, dsc.updt_dt_tm = cnvtdatetime(curdate,
    curtime3)
  PLAN (d
   WHERE (temp_req->req_items[d.seq].action_flag=1)
    AND (temp_req->req_items[d.seq].new_dsc_id > 0.0))
   JOIN (dsc)
  WITH nocounter
 ;end insert
 CALL bederrorcheck("Disclaimer Suppression Insert Error")
 UPDATE  FROM lh_cnt_ic_antibgrm_org_dsc dsc,
   (dummyt d  WITH seq = value(new_item_tot_cnt))
  SET dsc.long_text_id = temp_req->req_items[d.seq].new_long_text_id, dsc.suppress_ind = temp_req->
   req_items[d.seq].suppression_ind, dsc.updt_applctx = reqinfo->updt_applctx,
   dsc.updt_id = reqinfo->updt_id, dsc.updt_cnt = 0, dsc.updt_task = reqinfo->updt_task,
   dsc.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (d
   WHERE (temp_req->req_items[d.seq].action_flag=2)
    AND (temp_req->req_items[d.seq].new_dsc_id > 0.0))
   JOIN (dsc
   WHERE (dsc.lh_cnt_ic_antibgrm_org_dsc_id=temp_req->req_items[d.seq].new_dsc_id))
  WITH nocounter
 ;end update
 CALL bederrorcheck("Disclaimer Suppression Update Error")
 CALL bederrorcheck("Descriptive error message not provided.")
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
