CREATE PROGRAM act_add_drug_class_cat:dba
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
 SET category_found = 0
 RECORD temp(
   1 cnt = i4
   1 qual[*]
     2 alt_sel_category_id = f8
     2 sequence = i4
 )
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM alt_sel_cat a
  PLAN (a
   WHERE a.long_description_key_cap="DRUGCLASSES")
  DETAIL
   category_found = 1
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  GO TO exit_script
 ENDIF
 IF (category_found=1)
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM alt_sel_cat a
  PLAN (a
   WHERE a.ahfs_ind=1
    AND  NOT ( EXISTS (
   (SELECT
    l.alt_sel_category_id
    FROM alt_sel_list l
    WHERE l.child_alt_sel_cat_id=a.alt_sel_category_id))))
  ORDER BY a.alt_sel_category_id
  HEAD REPORT
   temp->cnt = 0
  HEAD a.alt_sel_category_id
   temp->cnt = (temp->cnt+ 1), stat = alterlist(temp->qual,temp->cnt), temp->qual[temp->cnt].
   alt_sel_category_id = a.alt_sel_category_id,
   temp->qual[temp->cnt].sequence = temp->cnt
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 SET newnbr = 0
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
  SET a.alt_sel_category_id = newnbr, a.short_description = "Drug Classes", a.long_description =
   "DRUGCLASSES",
   a.long_description_key_cap = "DRUGCLASSES", a.child_cat_ind = 1, a.owner_id = 0,
   a.ahfs_ind = 0, a.source_component_flag = 0, a.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   a.updt_id = 0, a.updt_task = 0, a.updt_cnt = 0,
   a.updt_applctx = 0
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  GO TO exit_script
 ENDIF
 IF ((temp->cnt > 0))
  SET ierrcode = 0
  INSERT  FROM (dummyt d  WITH seq = value(temp->cnt)),
    alt_sel_list l
   SET l.alt_sel_category_id = newnbr, l.sequence = temp->qual[d.seq].sequence, l.list_type = 1,
    l.child_alt_sel_cat_id = temp->qual[d.seq].alt_sel_category_id, l.updt_dt_tm = cnvtdatetime(
     curdate,curtime3), l.updt_id = 0,
    l.updt_task = 0, l.updt_applctx = 0, l.updt_cnt = 0
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
#exit_script
 IF (failed="Y")
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = serrmsg
 ELSE
  COMMIT
  SET readme_data->status = "S"
  IF (category_found=1)
   SET readme_data->message = "DRUGCLASSES category exists"
  ENDIF
 ENDIF
 EXECUTE dm_readme_status
END GO
