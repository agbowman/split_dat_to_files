CREATE PROGRAM dcp_add_clinical_nt:dba
 RECORD reply(
   1 template_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD blobsize(
   1 blobs[*]
     2 blob_length = i4
 )
 DECLARE note_type_template_id = f8 WITH public, noconstant(0.0)
 DECLARE reltn_cnt = i4 WITH noconstant(0)
 DECLARE cs_table = c50
 DECLARE failed = c1 WITH noconstant("F")
 SET reply->status_data.status = "F"
 DECLARE template_id = f8 WITH public, noconstant(0.0)
 DECLARE long_blob_id = f8 WITH public, noconstant(0.0)
 DECLARE segment_cnt = i4 WITH noconstant(0)
 DECLARE itr = i4 WITH noconstant(0)
 DECLARE buildtext = vc
 SELECT INTO "nl:"
  j = seq(reference_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   template_id = cnvtreal(j), reply->template_id = template_id
  WITH format, nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET cs_table = "SEQ NBR"
  GO TO exit_script
 ENDIF
 IF ((request->smart_template_ind != 1))
  SET segment_cnt = size(request->large_text_qual,5)
  SET stat = alterlist(blobsize->blobs,segment_cnt)
  IF (segment_cnt > 1)
   FOR (itr = 1 TO segment_cnt)
     SET buildtext = notrim(concat(build(itr),"<BLOCKID>",request->large_text_qual[itr].text_segment)
      )
     SET request->large_text_qual[itr].text_segment = notrim(buildtext)
     SET blobsize->blobs[itr].blob_length = size(request->large_text_qual[itr].text_segment,1)
   ENDFOR
  ELSE
   IF (segment_cnt=1)
    SET blobsize->blobs[1].blob_length = size(request->large_text_qual[1].text_segment,1)
   ENDIF
  ENDIF
  INSERT  FROM long_blob lb,
    (dummyt d  WITH seq = segment_cnt)
   SET lb.parent_entity_name = "CLINICAL_NOTE_TEMPLATE", lb.long_blob_id = cnvtreal(seq(long_data_seq,
      nextval)), lb.long_blob = request->large_text_qual[d.seq].text_segment,
    lb.blob_length = blobsize->blobs[d.seq].blob_length, lb.parent_entity_id = template_id, lb
    .active_ind = 1,
    lb.active_status_cd = reqdata->active_status_cd, lb.active_status_dt_tm = cnvtdatetime(curdate,
     curtime), lb.active_status_prsnl_id = reqinfo->updt_id,
    lb.updt_dt_tm = cnvtdatetime(curdate,curtime), lb.updt_id = reqinfo->updt_id, lb.updt_task =
    reqinfo->updt_task,
    lb.updt_applctx = reqinfo->updt_applctx, lb.updt_cnt = 0
   PLAN (d)
    JOIN (lb)
   WITH nocounter
  ;end insert
 ENDIF
 INSERT  FROM clinical_note_template nt
  SET nt.smart_template_ind = request->smart_template_ind, nt.smart_template_cd = request->
   smart_template_cd, nt.template_id = template_id,
   nt.template_name = request->template_name, nt.template_active_ind = 1, nt.long_blob_id = 0,
   nt.owner_type_flag = request->owner_type_flag, nt.prsnl_id = request->prsnl_id, nt.updt_dt_tm =
   cnvtdatetime(curdate,curtime),
   nt.updt_id = reqinfo->updt_id, nt.updt_task = reqinfo->updt_task, nt.updt_applctx = reqinfo->
   updt_applctx,
   nt.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  SET cs_table = "CLINICAL NOTE TEMPLATE"
  GO TO exit_script
 ENDIF
 SET reltn_cnt = cnvtint(size(request->note_type,5))
 FOR (i = 1 TO reltn_cnt)
   SELECT INTO "nl:"
    FROM note_type_template_reltn ntr1
    WHERE ntr1.template_id=template_id
     AND (ntr1.note_type_id=request->note_type[i].note_type_id)
    DETAIL
     note_type_template_id = ntr1.note_type_template_reltn_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT INTO "nl:"
     nextseqnum = seq(reference_seq,nextval)"#################;rp0"
     FROM dual
     DETAIL
      note_type_template_id = cnvtreal(nextseqnum)
     WITH format
    ;end select
    IF (note_type_template_id=0)
     SET failed = "T"
     SET cs_table = "REFERENCE_SEQ"
     GO TO exit_script
    ENDIF
    INSERT  FROM note_type_template_reltn ntr
     SET ntr.note_type_template_reltn_id = note_type_template_id, ntr.template_id = template_id, ntr
      .note_type_id = request->note_type[i].note_type_id,
      ntr.updt_dt_tm = cnvtdatetime(curdate,curtime), ntr.updt_id = reqinfo->updt_id, ntr.updt_task
       = reqinfo->updt_task,
      ntr.updt_applctx = reqinfo->updt_applctx, ntr.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual != 1)
     SET failed = "T"
     SET cs_table = "NOTE_TYPE_TEMPLATE_RELTN"
     GO TO exit_script
    ENDIF
   ENDIF
   SET prsnl_loc_reltn_count = size(request->note_type[i].reltn_list,5)
   IF (prsnl_loc_reltn_count > 0)
    INSERT  FROM prsnl_loc_template_reltn pltr,
      (dummyt d  WITH seq = value(prsnl_loc_reltn_count))
     SET pltr.prsnl_loc_template_reltn_id = cnvtreal(seq(prsnl_loc_temp_id_seq,nextval)), pltr
      .note_type_template_reltn_id = note_type_template_id, pltr.prsnl_id = request->note_type[i].
      reltn_list[d.seq].prsnl_id,
      pltr.location_cd = request->note_type[i].reltn_list[d.seq].location_cd, pltr.default_ind =
      request->note_type[i].reltn_list[d.seq].default_ind, pltr.updt_dt_tm = cnvtdatetime(curdate,
       curtime),
      pltr.updt_id = reqinfo->updt_id, pltr.updt_task = reqinfo->updt_task, pltr.updt_applctx =
      reqinfo->updt_applctx,
      pltr.updt_cnt = 0
     PLAN (d)
      JOIN (pltr)
     WITH nocounter
    ;end insert
    IF (curqual != prsnl_loc_reltn_count)
     SET failed = "T"
     SET cs_table = "PRSNL_LOC_TEMPLATE_RELTN"
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SET keyword_cnt = cnvtint(size(request->keyword,5))
 IF ((request->keyword[1].keyword_cd > 0))
  INSERT  FROM template_keyword_reltn kr,
    (dummyt d2  WITH seq = value(keyword_cnt))
   SET kr.template_keyword_reltn_id = cnvtreal(seq(reference_seq,nextval)), kr.template_id =
    template_id, kr.note_template_keyword_id = request->keyword[d2.seq].keyword_cd,
    kr.updt_dt_tm = cnvtdatetime(curdate,curtime), kr.updt_id = reqinfo->updt_id, kr.updt_task =
    reqinfo->updt_task,
    kr.updt_applctx = reqinfo->updt_applctx, kr.updt_cnt = 0
   PLAN (d2)
    JOIN (kr)
   WITH nocounter, outerjoin = d2
  ;end insert
  IF (curqual != keyword_cnt)
   SET failed = "T"
   SET cs_table = "TEMPLATE_KEYWORD_RELTN"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = cs_table
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
