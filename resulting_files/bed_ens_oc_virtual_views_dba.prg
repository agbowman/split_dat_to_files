CREATE PROGRAM bed_ens_oc_virtual_views:dba
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
 FREE SET temp
 RECORD temp(
   1 vv_relations[*]
     2 synonym_id = f8
     2 facility_cd = f8
     2 updt_count = i4
     2 updt_dt_tm = dq8
 )
 SET reply->status_data.status = "F"
 DECLARE scnt = i4 WITH constant(size(request->slist,5))
 DECLARE fcnt = i4 WITH noconstant(size(request->flist,5))
 DECLARE counter = i4 WITH noconstant(1)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE num = i4 WITH noconstant(0)
 DECLARE s = i4
 DECLARE row_cnt = i4 WITH protect
 IF ((request->ensure_mode=1))
  IF ((request->flist[1].facility_cd=0))
   FOR (s = 1 TO scnt)
     SET row_cnt = 0
     SELECT INTO "NL:"
      FROM ocs_facility_r ofr
      WHERE (ofr.synonym_id=request->slist[s].synonym_id)
      DETAIL
       row_cnt = (row_cnt+ 1)
      WITH nocounter
     ;end select
     IF (row_cnt=0)
      INSERT  FROM ocs_facility_r ofr
       SET ofr.synonym_id = request->slist[s].synonym_id, ofr.facility_cd = 0.0, ofr.updt_applctx =
        reqinfo->updt_applctx,
        ofr.updt_cnt = 0, ofr.updt_dt_tm = cnvtdatetime(curdate,curtime), ofr.updt_id = reqinfo->
        updt_id,
        ofr.updt_task = reqinfo->updt_task
      ;end insert
     ENDIF
   ENDFOR
  ELSE
   IF (scnt > 0)
    DELETE  FROM ocs_facility_r ofr,
      (dummyt d  WITH seq = scnt)
     SET ofr.synonym_id = ofr.synonym_id
     PLAN (d)
      JOIN (ofr
      WHERE (ofr.synonym_id=request->slist[d.seq].synonym_id)
       AND ofr.facility_cd=0.0)
     WITH nocounter
    ;end delete
   ENDIF
   IF (scnt > fcnt
    AND scnt > 0)
    FOR (f = 1 TO fcnt)
      DELETE  FROM ocs_facility_r ofr,
        (dummyt d  WITH seq = scnt)
       SET ofr.synonym_id = ofr.synonym_id
       PLAN (d)
        JOIN (ofr
        WHERE (ofr.synonym_id=request->slist[d.seq].synonym_id)
         AND (ofr.facility_cd=request->flist[f].facility_cd))
       WITH nocounter
      ;end delete
    ENDFOR
    FOR (f = 1 TO fcnt)
      INSERT  FROM ocs_facility_r ofr,
        (dummyt d  WITH seq = scnt)
       SET ofr.synonym_id = request->slist[d.seq].synonym_id, ofr.facility_cd = request->flist[f].
        facility_cd, ofr.updt_applctx = reqinfo->updt_applctx,
        ofr.updt_cnt = 0, ofr.updt_dt_tm = cnvtdatetime(curdate,curtime), ofr.updt_id = reqinfo->
        updt_id,
        ofr.updt_task = reqinfo->updt_task
       PLAN (d)
        JOIN (ofr)
      ;end insert
    ENDFOR
   ELSEIF (fcnt > 0)
    FOR (s = 1 TO scnt)
      DELETE  FROM ocs_facility_r ofr,
        (dummyt d  WITH seq = fcnt)
       SET ofr.synonym_id = ofr.synonym_id
       PLAN (d)
        JOIN (ofr
        WHERE (ofr.synonym_id=request->slist[s].synonym_id)
         AND (ofr.facility_cd=request->flist[d.seq].facility_cd))
       WITH nocounter
      ;end delete
    ENDFOR
    FOR (s = 1 TO scnt)
      INSERT  FROM ocs_facility_r ofr,
        (dummyt d  WITH seq = fcnt)
       SET ofr.synonym_id = request->slist[s].synonym_id, ofr.facility_cd = request->flist[d.seq].
        facility_cd, ofr.updt_applctx = reqinfo->updt_applctx,
        ofr.updt_cnt = 0, ofr.updt_dt_tm = cnvtdatetime(curdate,curtime), ofr.updt_id = reqinfo->
        updt_id,
        ofr.updt_task = reqinfo->updt_task
       PLAN (d)
        JOIN (ofr)
      ;end insert
    ENDFOR
   ENDIF
  ENDIF
 ELSEIF ((request->ensure_mode=2))
  IF (scnt > 0)
   SET stat = copyrec(request,temp_request,1)
   SELECT INTO "nl:"
    FROM ocs_facility_r ofr,
     (dummyt ds  WITH seq = value(scnt)),
     (dummyt df  WITH seq = value(fcnt))
    PLAN (ds)
     JOIN (df)
     JOIN (ofr
     WHERE (ofr.synonym_id=temp_request->slist[ds.seq].synonym_id)
      AND (ofr.facility_cd=temp_request->flist[df.seq].facility_cd))
    HEAD ofr.facility_cd
     stat = alterlist(temp->vv_relations,counter), temp->vv_relations[counter].synonym_id = ofr
     .synonym_id, temp->vv_relations[counter].facility_cd = ofr.facility_cd,
     temp->vv_relations[counter].updt_count = ofr.updt_cnt, temp->vv_relations[counter].updt_dt_tm =
     ofr.updt_dt_tm, counter = (counter+ 1),
     idx = locateval(num,1,size(request->flist,5),ofr.facility_cd,request->flist[num].facility_cd)
     IF (idx > 0)
      fcnt = (fcnt - 1), stat = alterlist(request->flist,fcnt,(idx - 1))
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  IF (scnt > 0)
   DELETE  FROM ocs_facility_r ofr,
     (dummyt d  WITH seq = scnt)
    SET ofr.synonym_id = ofr.synonym_id
    PLAN (d)
     JOIN (ofr
     WHERE (ofr.synonym_id=request->slist[d.seq].synonym_id))
    WITH nocounter
   ;end delete
  ENDIF
  IF (scnt > fcnt
   AND scnt > 0)
   FOR (f = 1 TO fcnt)
     INSERT  FROM ocs_facility_r ofr,
       (dummyt d  WITH seq = scnt)
      SET ofr.synonym_id = request->slist[d.seq].synonym_id, ofr.facility_cd = request->flist[f].
       facility_cd, ofr.updt_applctx = reqinfo->updt_applctx,
       ofr.updt_cnt = 0, ofr.updt_dt_tm = cnvtdatetime(curdate,curtime), ofr.updt_id = reqinfo->
       updt_id,
       ofr.updt_task = reqinfo->updt_task
      PLAN (d)
       JOIN (ofr)
     ;end insert
   ENDFOR
  ELSEIF (fcnt > 0)
   FOR (s = 1 TO scnt)
     INSERT  FROM ocs_facility_r ofr,
       (dummyt d  WITH seq = fcnt)
      SET ofr.synonym_id = request->slist[s].synonym_id, ofr.facility_cd = request->flist[d.seq].
       facility_cd, ofr.updt_applctx = reqinfo->updt_applctx,
       ofr.updt_cnt = 0, ofr.updt_dt_tm = cnvtdatetime(curdate,curtime), ofr.updt_id = reqinfo->
       updt_id,
       ofr.updt_task = reqinfo->updt_task
      PLAN (d)
       JOIN (ofr)
     ;end insert
   ENDFOR
  ENDIF
  INSERT  FROM ocs_facility_r ofr,
    (dummyt d  WITH seq = size(temp->vv_relations,5))
   SET ofr.synonym_id = temp->vv_relations[d.seq].synonym_id, ofr.facility_cd = temp->vv_relations[d
    .seq].facility_cd, ofr.updt_applctx = reqinfo->updt_applctx,
    ofr.updt_cnt = temp->vv_relations[d.seq].updt_count, ofr.updt_dt_tm = cnvtdatetime(temp->
     vv_relations[d.seq].updt_dt_tm), ofr.updt_id = reqinfo->updt_id,
    ofr.updt_task = reqinfo->updt_task
   PLAN (d)
    JOIN (ofr)
  ;end insert
 ELSEIF ((request->ensure_mode=3))
  IF (scnt > fcnt
   AND scnt > 0)
   FOR (f = 1 TO fcnt)
     DELETE  FROM ocs_facility_r ofr,
       (dummyt d  WITH seq = scnt)
      SET ofr.synonym_id = ofr.synonym_id
      PLAN (d)
       JOIN (ofr
       WHERE (ofr.synonym_id=request->slist[d.seq].synonym_id)
        AND (ofr.facility_cd=request->flist[f].facility_cd))
      WITH nocounter
     ;end delete
   ENDFOR
  ELSEIF (fcnt > 0)
   FOR (s = 1 TO scnt)
     DELETE  FROM ocs_facility_r ofr,
       (dummyt d  WITH seq = fcnt)
      SET ofr.synonym_id = ofr.synonym_id
      PLAN (d)
       JOIN (ofr
       WHERE (ofr.synonym_id=request->slist[s].synonym_id)
        AND (ofr.facility_cd=request->flist[d.seq].facility_cd))
      WITH nocounter
     ;end delete
   ENDFOR
  ENDIF
 ENDIF
 IF ((request->ensure_mode IN (1, 2)))
  FOR (s = 1 TO scnt)
    SET catalog_cd = 0
    SELECT INTO "NL:"
     FROM order_catalog_synonym ocs
     WHERE (ocs.synonym_id=request->slist[s].synonym_id)
     DETAIL
      catalog_cd = ocs.catalog_cd
     WITH nocounter
    ;end select
    UPDATE  FROM order_catalog_synonym ocs
     SET ocs.orderable_type_flag = 0, ocs.updt_cnt = (ocs.updt_cnt+ 1), ocs.updt_id = reqinfo->
      updt_id,
      ocs.updt_dt_tm = cnvtdatetime(curdate,curtime), ocs.updt_task = reqinfo->updt_task, ocs
      .updt_applctx = reqinfo->updt_applctx
     WHERE (ocs.synonym_id=request->slist[s].synonym_id)
      AND ocs.orderable_type_flag IN (0, 1)
     WITH nocounter
    ;end update
    UPDATE  FROM order_catalog oc
     SET oc.orderable_type_flag = 0, oc.updt_cnt = (oc.updt_cnt+ 1), oc.updt_id = reqinfo->updt_id,
      oc.updt_dt_tm = cnvtdatetime(curdate,curtime), oc.updt_task = reqinfo->updt_task, oc
      .updt_applctx = reqinfo->updt_applctx
     WHERE oc.catalog_cd=catalog_cd
      AND oc.orderable_type_flag=1
     WITH nocounter
    ;end update
  ENDFOR
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 CALL echorecord(reply)
END GO
