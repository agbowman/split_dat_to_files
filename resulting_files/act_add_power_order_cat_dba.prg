CREATE PROGRAM act_add_power_order_cat:dba
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
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 RECORD temp(
   1 cnt = i4
   1 qual[*]
     2 fav_exist = i4
     2 owner_id = f8
     2 cnt = i4
     2 qual[*]
       3 alt_sel_category_id = f8
       3 synonym_id = f8
       3 order_sentence_id = f8
       3 sequence = i4
 )
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM alt_sel_cat a,
   alt_sel_list l
  PLAN (a
   WHERE a.owner_id > 0
    AND a.source_component_flag=1)
   JOIN (l
   WHERE l.alt_sel_category_id=a.alt_sel_category_id
    AND l.synonym_id > 0)
  ORDER BY a.owner_id, a.alt_sel_category_id
  HEAD REPORT
   temp->cnt = 0, cnt = 0
  HEAD a.owner_id
   cnt = 0, temp->cnt = (temp->cnt+ 1), stat = alterlist(temp->qual,temp->cnt),
   temp->qual[temp->cnt].owner_id = a.owner_id, temp->qual[temp->cnt].fav_exist = 0
  DETAIL
   IF (a.short_description="Favorites"
    AND a.long_description="Favorites"
    AND a.long_description_key_cap="FAVORITES")
    temp->qual[temp->cnt].fav_exist = 1
   ENDIF
   cnt = (cnt+ 1), temp->qual[temp->cnt].cnt = cnt, stat = alterlist(temp->qual[temp->cnt].qual,cnt),
   temp->qual[temp->cnt].qual[cnt].alt_sel_category_id = l.alt_sel_category_id, temp->qual[temp->cnt]
   .qual[cnt].synonym_id = l.synonym_id, temp->qual[temp->cnt].qual[cnt].order_sentence_id = l
   .order_sentence_id,
   temp->qual[temp->cnt].qual[cnt].sequence = cnt
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO temp->cnt)
   IF ((temp->qual[x].fav_exist=0))
    SET newnbr = 0
    SET ierrcode = 0
    SELECT INTO "nl:"
     y = seq(reference_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      newnbr = cnvtint(y)
     WITH format, nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    INSERT  FROM alt_sel_cat a
     SET a.alt_sel_category_id = newnbr, a.short_description = "Favorites", a.long_description =
      "Favorites",
      a.long_description_key_cap = "FAVORITES", a.owner_id = temp->qual[x].owner_id, a
      .source_component_flag = 1,
      a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = 0, a.updt_task = 0,
      a.updt_cnt = 0, a.updt_applctx = 0
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    INSERT  FROM (dummyt d  WITH seq = value(temp->qual[x].cnt)),
      alt_sel_list l
     SET l.alt_sel_category_id = newnbr, l.sequence = temp->qual[x].qual[d.seq].sequence, l
      .synonym_id = temp->qual[x].qual[d.seq].synonym_id,
      l.list_type = 2, l.order_sentence_id = temp->qual[x].qual[d.seq].order_sentence_id, l
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
      l.updt_id = 0, l.updt_task = 0, l.updt_applctx = 0,
      l.updt_cnt = 0
     PLAN (d)
      JOIN (l)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (failed="Y")
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = serrmsg
 ELSE
  COMMIT
  SET readme_data->status = "S"
 ENDIF
 EXECUTE dm_readme_status
END GO
