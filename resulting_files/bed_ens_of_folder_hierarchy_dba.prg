CREATE PROGRAM bed_ens_of_folder_hierarchy:dba
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
 DECLARE serrmsg = vc WITH protect, noconstant(fillstring(132," "))
 DECLARE ierrcode = i2 WITH rpotect, noconstant(error(serrmsg,1))
 DECLARE failed = vc WITH protect, noconstant("N")
 DECLARE cindex = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(request->flist,5))),
   alt_sel_list l
  PLAN (d)
   JOIN (l
   WHERE (l.alt_sel_category_id=request->flist[d.seq].folder_id)
    AND l.regimen_cat_synonym_id > 0)
  DETAIL
   cindex = (size(request->flist[d.seq].clist,5)+ 1), stat = alterlist(request->flist[d.seq].clist,
    cindex), request->flist[d.seq].clist[cindex].sequence = l.sequence,
   request->flist[d.seq].clist[cindex].list_type = l.list_type, request->flist[d.seq].clist[cindex].
   child_id = l.regimen_cat_synonym_id, request->flist[d.seq].clist[cindex].order_sentence_id = l
   .order_sentence_id,
   request->flist[d.seq].clist[cindex].pw_cat_synonym_id = l.pw_cat_synonym_id
  WITH nocounter
 ;end select
 SET ierrcode = 0
 DELETE  FROM alt_sel_list l,
   (dummyt d  WITH seq = value(size(request->flist,5)))
  SET l.seq = 1
  PLAN (d)
   JOIN (l
   WHERE (l.alt_sel_category_id=request->flist[d.seq].folder_id))
  WITH nocounter
 ;end delete
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO size(request->flist,5))
   IF (size(request->flist[x].clist,5) > 0)
    SET ierrcode = 0
    INSERT  FROM alt_sel_list l,
      (dummyt d  WITH seq = value(size(request->flist[x].clist,5)))
     SET l.seq = 1, l.alt_sel_category_id = request->flist[x].folder_id, l.sequence = request->flist[
      x].clist[d.seq].sequence,
      l.synonym_id =
      IF ((request->flist[x].clist[d.seq].list_type=2)) request->flist[x].clist[d.seq].child_id
      ELSE 0
      ENDIF
      , l.pathway_catalog_id =
      IF ((request->flist[x].clist[d.seq].list_type=6)) request->flist[x].clist[d.seq].child_id
      ELSE 0
      ENDIF
      , l.pw_cat_synonym_id =
      IF ((request->flist[x].clist[d.seq].list_type=6)
       AND validate(request->flist[x].clist[d.seq].pw_cat_synonym_id)) request->flist[x].clist[d.seq]
       .pw_cat_synonym_id
      ELSE 0
      ENDIF
      ,
      l.list_type = request->flist[x].clist[d.seq].list_type, l.child_alt_sel_cat_id =
      IF ((request->flist[x].clist[d.seq].list_type=1)) request->flist[x].clist[d.seq].child_id
      ELSE 0
      ENDIF
      , l.regimen_cat_synonym_id =
      IF ((request->flist[x].clist[d.seq].list_type=7)) request->flist[x].clist[d.seq].child_id
      ELSE 0
      ENDIF
      ,
      l.order_sentence_id = request->flist[x].clist[d.seq].order_sentence_id, l.reference_task_id = 0,
      l.updt_cnt = 0,
      l.updt_dt_tm = cnvtdatetime(curdate,curtime), l.updt_id = reqinfo->updt_id, l.updt_task =
      reqinfo->updt_task,
      l.updt_applctx = reqinfo->updt_applctx
     PLAN (d)
      JOIN (l)
     WITH nocounter
    ;end insert
   ENDIF
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = "Y"
    GO TO exit_script
   ENDIF
 ENDFOR
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
