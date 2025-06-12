CREATE PROGRAM bed_get_nomen_cat_list:dba
 FREE SET reply
 RECORD reply(
   1 nlist[*]
     2 nomen_cat_id = f8
     2 nomen_cat_name = vc
     2 category_type_code_value = f8
     2 category_type_mean = vc
     2 category_type_display = vc
     2 parent_entity_id = f8
     2 parent_entity_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "Z"
 SET tot_count = 0
 SET nomen_count = 0
 SET stat = alterlist(reply->nlist,50)
 DECLARE nomen_parse = vc
 SET clistcnt = size(request->clist,5)
 SET i = 0
 IF (clistcnt > 0)
  FOR (i = 1 TO clistcnt)
    IF (i=1)
     SET nomen_parse = build(nomen_parse," ((n.category_type_cd = ",request->clist[i].
      category_type_code_value,")")
    ELSE
     SET nomen_parse = build(nomen_parse," or (n.category_type_cd  = ",request->clist[i].
      category_type_code_value,")")
    ENDIF
  ENDFOR
  SET nomen_parse = concat(nomen_parse,")")
 ENDIF
 SET plistcnt = size(request->plist,5)
 IF (plistcnt > 0)
  FOR (x = 1 TO plistcnt)
    IF (x=1)
     IF (i=0)
      SET nomen_parse = build(nomen_parse," ((n.parent_entity_name = ","'",request->plist[x].name,"'",
       " and n.parent_entity_id = ",request->plist[x].entity_id,")")
     ELSE
      SET nomen_parse = build(nomen_parse," and ((n.parent_entity_name = ","'",request->plist[x].name,
       "'",
       " and n.parent_entity_id = ",request->plist[x].entity_id,")")
     ENDIF
    ELSE
     SET nomen_parse = build(nomen_parse," or (n.parent_entity_name = ","'",request->plist[x].name,
      "'",
      " and n.parent_entity_id = ",request->plist[x].entity_id,")")
    ENDIF
  ENDFOR
  SET nomen_parse = concat(nomen_parse," or n.parent_entity_id = 0)")
 ENDIF
 CALL echo(nomen_parse)
 SELECT INTO "NL:"
  FROM nomen_category n,
   code_value cv
  PLAN (n
   WHERE parser(nomen_parse))
   JOIN (cv
   WHERE cv.active_ind=1
    AND cv.code_set=25321
    AND cv.code_value=n.category_type_cd)
  DETAIL
   tot_count = (tot_count+ 1), nomen_count = (nomen_count+ 1)
   IF (nomen_count > 50)
    stat = alterlist(reply->nlist,(tot_count+ 50)), nomen_cnt = 0
   ENDIF
   reply->nlist[tot_count].nomen_cat_id = n.nomen_category_id, reply->nlist[tot_count].nomen_cat_name
    = n.category_name, reply->nlist[tot_count].category_type_code_value = n.category_type_cd,
   reply->nlist[tot_count].category_type_mean = cv.cdf_meaning, reply->nlist[tot_count].
   category_type_display = cv.display, reply->nlist[tot_count].parent_entity_id = n.parent_entity_id,
   reply->nlist[tot_count].parent_entity_name = n.parent_entity_name
  WITH nocounter
 ;end select
 SET catcnt = size(request->catlist,5)
 FOR (i = 1 TO catcnt)
   SELECT INTO "NL:"
    FROM nomen_category n,
     code_value cv
    PLAN (n
     WHERE (n.nomen_category_id=request->catlist[i].nomen_cat_id))
     JOIN (cv
     WHERE cv.active_ind=1
      AND cv.code_set=25321
      AND cv.code_value=n.category_type_cd)
    DETAIL
     tot_count = (tot_count+ 1), nomen_count = (nomen_count+ 1)
     IF (nomen_count > 50)
      stat = alterlist(reply->nlist,(tot_count+ 50)), nomen_cnt = 0
     ENDIF
     reply->nlist[tot_count].nomen_cat_id = n.nomen_category_id, reply->nlist[tot_count].
     nomen_cat_name = n.category_name, reply->nlist[tot_count].category_type_code_value = n
     .category_type_cd,
     reply->nlist[tot_count].category_type_mean = cv.cdf_meaning, reply->nlist[tot_count].
     category_type_display = cv.display, reply->nlist[tot_count].parent_entity_id = n
     .parent_entity_id,
     reply->nlist[tot_count].parent_entity_name = n.parent_entity_name
    WITH nocounter
   ;end select
 ENDFOR
 SET stat = alterlist(reply->nlist,tot_count)
 IF (tot_count > 0)
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
