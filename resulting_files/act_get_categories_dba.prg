CREATE PROGRAM act_get_categories:dba
 RECORD reply(
   1 qual[*]
     2 alt_sel_category_id = f8
     2 long_description = vc
     2 short_description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE cnt = i4 WITH public, noconstant(0)
 DECLARE desc_cnt = i4 WITH public, noconstant(0)
 DECLARE category_cnt = i4 WITH public, noconstant(0)
 DECLARE filter_line = vc WITH public, noconstant(fillstring(1000," "))
 SET category_cnt = size(request->categories,5)
 IF (category_cnt=1
  AND (request->categories[1].alt_sel_category_id=0))
  SET category_cnt = 0
 ENDIF
 SET desc_cnt = size(request->category_desc,5)
 IF (desc_cnt=1
  AND (request->category_desc[1].long_description=""))
  SET desc_cnt = 0
 ENDIF
 FOR (x = 1 TO desc_cnt)
   SET request->category_desc[x].long_description = cnvtupper(request->category_desc[x].
    long_description)
 ENDFOR
 IF (desc_cnt > 0
  AND category_cnt > 0)
  FOR (x = 1 TO category_cnt)
   IF (x=1)
    SET filter_line = concat(" (a.alt_sel_category_id in (",cnvtstring(request->categories[1].
      alt_sel_category_id))
   ELSE
    SET filter_line = concat(trim(filter_line),",",cnvtstring(request->categories[x].
      alt_sel_category_id))
   ENDIF
   IF (x=category_cnt)
    SET filter_line = concat(trim(filter_line),") or a.long_description_key_cap in (")
   ENDIF
  ENDFOR
  FOR (x = 1 TO desc_cnt)
   IF (x=1)
    SET filter_line = concat(trim(filter_line),'"',request->category_desc[1].long_description,'"')
   ELSE
    SET filter_line = concat(trim(filter_line),',"',request->category_desc[x].long_description,'"')
   ENDIF
   IF (x=desc_cnt)
    SET filter_line = concat(trim(filter_line),"))")
   ENDIF
  ENDFOR
  SELECT INTO "nl:"
   FROM alt_sel_cat a
   PLAN (a
    WHERE parser(trim(filter_line)))
   HEAD a.alt_sel_category_id
    cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].alt_sel_category_id = a
    .alt_sel_category_id,
    reply->qual[cnt].long_description = a.long_description, reply->qual[cnt].short_description = a
    .short_description
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 IF (category_cnt=0
  AND desc_cnt=0)
  GO TO exit_script
 ENDIF
 SELECT
  IF (desc_cnt > 0)INTO "nl:"
   FROM (dummyt d  WITH seq = value(desc_cnt)),
    alt_sel_cat a
   PLAN (d)
    JOIN (a
    WHERE (a.long_description_key_cap=request->category_desc[d.seq].long_description))
  ELSEIF (category_cnt > 0)INTO "nl:"
   FROM (dummyt d  WITH seq = value(category_cnt)),
    alt_sel_cat a
   PLAN (d)
    JOIN (a
    WHERE (a.alt_sel_category_id=request->categories[d.seq].alt_sel_category_id))
  ELSE
  ENDIF
  HEAD a.alt_sel_category_id
   cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].alt_sel_category_id = a
   .alt_sel_category_id,
   reply->qual[cnt].long_description = a.long_description, reply->qual[cnt].short_description = a
   .short_description
  WITH nocounter
 ;end select
#exit_script
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
