CREATE PROGRAM cps_mak_drug_categories:dba
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
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
 FREE SET category
 RECORD category(
   1 qual_knt = i4
   1 qual[*]
     2 category_id = f8
     2 exist_ind = i2
     2 multum_category_id = i4
     2 short_description = vc
     2 long_description = vc
     2 long_description_key_cap = vc
     2 long_name_key_cap = vc
     2 child_cat_ind = i2
     2 owner_id = f8
     2 security_flag = i2
     2 ahfs_ind = i2
     2 adhoc_ind = i2
 )
 SET error_level = 0
 SET dvar = 0
 SET readme_data->message = concat("CPS_MAK_DRUG_CATEGORIES  BEG : ",format(cnvtdatetime(curdate,
    curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 EXECUTE dm_readme_status
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DECLARE bcb_exist = i2 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM dtable d
  WHERE d.table_name="MLTM_BCB_DRUG_CATEGORIES"
  DETAIL
   bcb_exist = true
  WITH check
 ;end select
 SELECT DISTINCT INTO "nl:"
  mdc.category_name
  FROM mltm_drug_categories mdc
  PLAN (mdc
   WHERE mdc.multum_category_id > 0)
  HEAD REPORT
   knt = 0, stat = alterlist(category->qual,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(category->qual,(knt+ 9))
   ENDIF
   category->qual[knt].multum_category_id = mdc.multum_category_id
   IF (mdc.category_atc_code > " ")
    category->qual[knt].short_description = mdc.category_atc_code
   ELSE
    category->qual[knt].short_description = trim(cnvtstring(mdc.multum_category_id))
   ENDIF
   category->qual[knt].long_description = mdc.category_name, category->qual[knt].
   long_description_key_cap = trim(cnvtupper(mdc.category_name)), category->qual[knt].security_flag
    = 2,
   category->qual[knt].ahfs_ind = 1, category->qual[knt].exist_ind = false
  FOOT REPORT
   category->qual_knt = knt, stat = alterlist(category->qual,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET readme_data->message = "ERROR :: A script error occurred finding Multum Drug Categories"
  EXECUTE dm_readme_status
  SET readme_data->message = trim(serrmsg)
  EXECUTE dm_readme_status
  SET error_level = 1
  GO TO exit_script
 ELSEIF ((category->qual_knt < 1))
  SET readme_data->message = "WARNING :: No Multum Drug Categories were found"
  EXECUTE dm_readme_status
  SET error_level = 2
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM mltm_category_sub_xref mcsx,
   (dummyt d  WITH seq = value(category->qual_knt))
  PLAN (d
   WHERE d.seq > 0)
   JOIN (mcsx
   WHERE (mcsx.multum_category_id=category->qual[d.seq].multum_category_id)
    AND mcsx.sub_category_id > 0)
  HEAD d.seq
   category->qual[d.seq].child_cat_ind = 1
  DETAIL
   dvar = dvar
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET readme_data->message = "ERROR :: A script error occurred finding child Multum Drug Categories"
  EXECUTE dm_readme_status
  SET readme_data->message = trim(serrmsg)
  EXECUTE dm_readme_status
  SET error_level = 1
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  d.seq
  FROM alt_sel_cat ac,
   (dummyt d  WITH seq = value(category->qual_knt))
  PLAN (d
   WHERE d.seq > 0)
   JOIN (ac
   WHERE ((ac.short_description=trim(cnvtstring(category->qual[d.seq].multum_category_id))) OR (ac
   .short_description=trim(category->qual[d.seq].short_description)))
    AND ac.ahfs_ind=1)
  HEAD d.seq
   IF (ac.alt_sel_category_id > 0
    AND ac.ahfs_ind=1)
    category->qual[d.seq].category_id = ac.alt_sel_category_id, category->qual[d.seq].exist_ind =
    true
   ELSE
    dvar = dvar
   ENDIF
  DETAIL
   dvar = dvar
  WITH nocounter, outerjoin = d
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET readme_data->message =
  "ERROR :: A script error occurred checking for existence of Multum Drug Categories"
  EXECUTE dm_readme_status
  SET readme_data->message = trim(serrmsg)
  EXECUTE dm_readme_status
  SET error_level = 1
  GO TO exit_script
 ENDIF
 CALL echorecord(category)
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 INSERT  FROM alt_sel_cat ac,
   (dummyt d  WITH seq = value(category->qual_knt))
  SET ac.alt_sel_category_id = cnvtreal(seq(reference_seq,nextval)), ac.short_description = category
   ->qual[d.seq].short_description, ac.long_description = category->qual[d.seq].long_description,
   ac.long_description_key_cap = category->qual[d.seq].long_description_key_cap, ac.child_cat_ind =
   category->qual[d.seq].child_cat_ind, ac.ahfs_ind = category->qual[d.seq].ahfs_ind,
   ac.security_flag = category->qual[d.seq].security_flag, ac.owner_id = 0.0, ac.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   ac.updt_cnt = 0, ac.updt_task = reqinfo->updt_task, ac.updt_id = 0.1
  PLAN (d
   WHERE d.seq > 0
    AND (category->qual[d.seq].exist_ind=false))
   JOIN (ac
   WHERE 0=0)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET readme_data->message = "ERROR :: An error occurred inserting Multum Drug Categories"
  EXECUTE dm_readme_status
  SET readme_data->message = trim(serrmsg)
  EXECUTE dm_readme_status
  SET error_level = 1
  GO TO exit_script
 ENDIF
 COMMIT
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  d.seq
  FROM alt_sel_cat ac,
   (dummyt d  WITH seq = value(category->qual_knt))
  PLAN (d
   WHERE d.seq > 0)
   JOIN (ac
   WHERE (ac.long_description_key_cap=category->qual[d.seq].long_description_key_cap)
    AND ((ac.ahfs_ind+ 0)=1))
  ORDER BY d.seq
  DETAIL
   IF ((ac.alt_sel_category_id != category->qual[d.seq].category_id))
    CALL echo(concat(trim(category->qual[d.seq].long_description_key_cap)," | ",trim(category->qual[d
      .seq].short_description)," | ",trim(cnvtstring(category->qual[d.seq].category_id)),
     " already exist on the table")),
    CALL echo(concat("as ",trim(ac.long_description_key_cap)," | ",trim(ac.short_description)," | ",
     trim(cnvtstring(ac.alt_sel_category_id))))
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET readme_data->message = "ERROR :: An error occurred ensuring no dups Multum Drug Categories"
  EXECUTE dm_readme_status
  SET readme_data->message = trim(serrmsg)
  EXECUTE dm_readme_status
  SET error_level = 1
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 UPDATE  FROM alt_sel_cat ac,
   (dummyt d  WITH seq = value(category->qual_knt))
  SET ac.short_description = category->qual[d.seq].short_description, ac.long_description = category
   ->qual[d.seq].long_description, ac.long_description_key_cap = category->qual[d.seq].
   long_description_key_cap,
   ac.child_cat_ind =
   IF ((category->qual[d.seq].child_cat_ind > 0)) category->qual[d.seq].child_cat_ind
   ELSE ac.child_cat_ind
   ENDIF
   , ac.ahfs_ind = category->qual[d.seq].ahfs_ind, ac.security_flag = category->qual[d.seq].
   security_flag,
   ac.owner_id = 0.0, ac.updt_dt_tm = cnvtdatetime(curdate,curtime3), ac.updt_cnt = (ac.updt_cnt+ 1),
   ac.updt_task = reqinfo->updt_task, ac.updt_id = 0.1
  PLAN (d
   WHERE d.seq > 0
    AND (category->qual[d.seq].exist_ind=true))
   JOIN (ac
   WHERE (ac.alt_sel_category_id=category->qual[d.seq].category_id))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET readme_data->message = "ERROR :: An error occurred updating Multum Drug Categories"
  EXECUTE dm_readme_status
  SET readme_data->message = trim(serrmsg)
  EXECUTE dm_readme_status
  SET error_level = 1
  GO TO exit_script
 ENDIF
 COMMIT
 DECLARE cs6011_rxmnemonic = f8
 SET cs6011_rxmnemonic = uar_get_code_by("MEANING",6011,"RXMNEMONIC")
 CALL echo("*** DELETING from ALT_SEL_LIST ***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DELETE  FROM alt_sel_list asl
  WHERE  NOT ( EXISTS (
  (SELECT
   1
   FROM order_catalog_synonym ocs
   WHERE asl.synonym_id=ocs.synonym_id
    AND (ocs.mnemonic_type_cd=
   (SELECT
    code_value
    FROM code_value
    WHERE cdf_meaning="RXMNEMONIC"
     AND code_set=6011))
    AND ocs.active_ind=1)))
   AND asl.alt_sel_category_id IN (
  (SELECT
   al.alt_sel_category_id
   FROM alt_sel_cat al
   WHERE al.ahfs_ind=1))
  WITH nocounter
 ;end delete
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET readme_data->message = "ERROR :: An error occurred deleting Multum relationships"
  EXECUTE dm_readme_status
  SET readme_data->message = trim(serrmsg)
  EXECUTE dm_readme_status
  SET error_level = 1
  GO TO exit_script
 ENDIF
 FREE SET cat_reltn
 RECORD cat_reltn(
   1 qual_knt = i4
   1 qual[*]
     2 parent_cat_id = f8
     2 last_sequence = i4
     2 child_knt = i4
     2 child[*]
       3 child_cat_id = f8
 )
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT DISTINCT INTO "nl:"
  ac1.alt_sel_category_id, ac2.alt_sel_category_id
  FROM mltm_category_sub_xref mcsx,
   mltm_drug_categories mdc1,
   mltm_drug_categories mdc2,
   alt_sel_cat ac1,
   alt_sel_cat ac2,
   (dummyt d  WITH seq = 1),
   alt_sel_list al
  PLAN (mcsx
   WHERE mcsx.multum_category_id > 0)
   JOIN (mdc1
   WHERE mdc1.multum_category_id=mcsx.multum_category_id)
   JOIN (mdc2
   WHERE mdc2.multum_category_id=mcsx.sub_category_id)
   JOIN (ac1
   WHERE ac1.long_description_key_cap=trim(cnvtupper(mdc1.category_name))
    AND ((ac1.short_description=cnvtstring(mdc1.multum_category_id)) OR (ac1.short_description=mdc1
   .category_atc_code))
    AND ((ac1.ahfs_ind+ 0)=1))
   JOIN (ac2
   WHERE ac2.long_description_key_cap=trim(cnvtupper(mdc2.category_name))
    AND ((ac2.short_description=cnvtstring(mdc2.multum_category_id)) OR (ac2.short_description=mdc2
   .category_atc_code))
    AND ((ac2.ahfs_ind+ 0)=1))
   JOIN (d)
   JOIN (al
   WHERE al.alt_sel_category_id=ac1.alt_sel_category_id
    AND al.child_alt_sel_cat_id=ac2.alt_sel_category_id)
  ORDER BY ac1.alt_sel_category_id, ac2.alt_sel_category_id
  HEAD REPORT
   knt = 0, stat = alterlist(cat_reltn->qual,10)
  HEAD ac1.alt_sel_category_id
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(cat_reltn->qual,(knt+ 9))
   ENDIF
   cat_reltn->qual[knt].parent_cat_id = ac1.alt_sel_category_id, cknt = 0, stat = alterlist(cat_reltn
    ->qual[knt].child,10)
  DETAIL
   cknt = (cknt+ 1)
   IF (mod(cknt,10)=1
    AND cknt != 1)
    stat = alterlist(cat_reltn->qual[knt].child,(cknt+ 9))
   ENDIF
   cat_reltn->qual[knt].child[cknt].child_cat_id = ac2.alt_sel_category_id
  FOOT  ac1.alt_sel_category_id
   cat_reltn->qual[knt].child_knt = cknt, stat = alterlist(cat_reltn->qual[knt].child,cknt)
  FOOT REPORT
   cat_reltn->qual_knt = knt, stat = alterlist(cat_reltn->qual,knt)
  WITH nocounter, outerjoin = d, dontexist
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET readme_data->message = "ERROR :: An error finding Multum category relationships"
  EXECUTE dm_readme_status
  SET readme_data->message = trim(serrmsg)
  EXECUTE dm_readme_status
  SET error_level = 1
  GO TO exit_script
 ENDIF
 IF ((cat_reltn->qual_knt > 0))
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   d.seq, al.alt_sel_category_id, al.sequence
   FROM alt_sel_list al,
    (dummyt d  WITH seq = value(cat_reltn->qual_knt))
   PLAN (d
    WHERE d.seq > 0)
    JOIN (al
    WHERE (al.alt_sel_category_id=cat_reltn->qual[d.seq].parent_cat_id))
   ORDER BY d.seq, al.alt_sel_category_id, al.sequence DESC
   HEAD al.alt_sel_category_id
    cat_reltn->qual[d.seq].last_sequence = al.sequence
   DETAIL
    dvar = dvar
   WITH nocounter, outerjoin = d
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET readme_data->message =
   "ERROR :: An error finding Multum category relationships last sequences"
   EXECUTE dm_readme_status
   SET readme_data->message = trim(serrmsg)
   EXECUTE dm_readme_status
   SET error_level = 1
   GO TO exit_script
  ENDIF
  FOR (i = 1 TO cat_reltn->qual_knt)
    IF ((cat_reltn->qual[i].child_knt > 0))
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     INSERT  FROM alt_sel_list al,
       (dummyt d  WITH seq = value(cat_reltn->qual[i].child_knt))
      SET al.alt_sel_category_id = cat_reltn->qual[i].parent_cat_id, al.child_alt_sel_cat_id =
       cat_reltn->qual[i].child[d.seq].child_cat_id, al.sequence = (cat_reltn->qual[i].last_sequence
       + d.seq),
       al.list_type = 1, al.updt_cnt = 0, al.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       al.updt_task = reqinfo->updt_task, al.updt_id = 0.1
      PLAN (d
       WHERE d.seq > 0)
       JOIN (al
       WHERE 0=0)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET readme_data->message = "ERROR :: An error inserting Multum category relationships"
      EXECUTE dm_readme_status
      SET readme_data->message = trim(serrmsg)
      EXECUTE dm_readme_status
      SET error_level = 1
      GO TO exit_script
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 FREE SET item_reltn
 RECORD item_reltn(
   1 qual_knt = i4
   1 qual[*]
     2 parent_cat_id = f8
     2 last_sequence = i4
     2 child_knt = i4
     2 child[*]
       3 synonym_id = f8
 )
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT DISTINCT INTO "nl:"
  al.alt_sel_category_id, ocs.synonym_id
  FROM mltm_drug_categories mdc,
   alt_sel_cat ac,
   mlld_category_drug_xref mc,
   mltm_drug_id md,
   code_value cv,
   order_catalog_synonym ocs,
   (dummyt d  WITH seq = 1),
   alt_sel_list al
  PLAN (mdc
   WHERE mdc.multum_category_id > 0)
   JOIN (ac
   WHERE ac.long_description_key_cap=cnvtupper(trim(mdc.category_name))
    AND ((ac.short_description=cnvtstring(mdc.multum_category_id)) OR (ac.short_description=mdc
   .category_atc_code))
    AND ((ac.ahfs_ind+ 0)=1))
   JOIN (mc
   WHERE mc.multum_category_id=mdc.multum_category_id)
   JOIN (md
   WHERE md.drug_identifier=mc.drug_identifier)
   JOIN (cv
   WHERE cv.cki=concat("MUL.ORD!",trim(md.drug_identifier))
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > sysdate)
   JOIN (ocs
   WHERE ocs.catalog_cd=cv.code_value
    AND ocs.active_ind=1
    AND (ocs.mnemonic_type_cd !=
   (SELECT
    x.code_value
    FROM code_value x
    WHERE x.code_set=6011
     AND x.cdf_meaning="RXMNEMONIC")))
   JOIN (d)
   JOIN (al
   WHERE al.alt_sel_category_id=ac.alt_sel_category_id
    AND al.synonym_id=ocs.synonym_id)
  ORDER BY ac.alt_sel_category_id, ocs.synonym_id
  HEAD REPORT
   knt = 0, stat = alterlist(item_reltn->qual,10)
  HEAD ac.alt_sel_category_id
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(item_reltn->qual,(knt+ 9))
   ENDIF
   item_reltn->qual[knt].parent_cat_id = ac.alt_sel_category_id, sknt = 0, stat = alterlist(
    item_reltn->qual[knt].child,10)
  HEAD ocs.synonym_id
   sknt = (sknt+ 1)
   IF (mod(sknt,10)=1
    AND sknt != 1)
    stat = alterlist(item_reltn->qual[knt].child,(sknt+ 9))
   ENDIF
   item_reltn->qual[knt].child[sknt].synonym_id = ocs.synonym_id
  FOOT  ac.alt_sel_category_id
   item_reltn->qual[knt].child_knt = sknt, stat = alterlist(item_reltn->qual[knt].child,sknt)
  FOOT REPORT
   item_reltn->qual_knt = knt, stat = alterlist(item_reltn->qual,knt)
  WITH nocounter, outerjoin = d, dontexist
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET readme_data->message = "ERROR :: An error finding Multum item relationships"
  EXECUTE dm_readme_status
  SET readme_data->message = trim(serrmsg)
  EXECUTE dm_readme_status
  SET error_level = 1
  GO TO exit_script
 ENDIF
 IF ((item_reltn->qual_knt > 0))
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   d.seq, al.alt_sel_category_id, al.sequence
   FROM alt_sel_list al,
    (dummyt d  WITH seq = value(item_reltn->qual_knt))
   PLAN (d
    WHERE d.seq > 0)
    JOIN (al
    WHERE (al.alt_sel_category_id=item_reltn->qual[d.seq].parent_cat_id))
   ORDER BY d.seq, al.alt_sel_category_id, al.sequence DESC
   HEAD al.alt_sel_category_id
    item_reltn->qual[d.seq].last_sequence = al.sequence
   DETAIL
    dvar = dvar
   WITH nocounter, outerjoin = d
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET readme_data->message = "ERROR :: An error finding Multum item relationships last sequence"
   EXECUTE dm_readme_status
   SET readme_data->message = trim(serrmsg)
   EXECUTE dm_readme_status
   SET error_level = 1
   GO TO exit_script
  ENDIF
  CALL echo("*** ROWS TO INSERT ***")
  CALL echorecord(item_reltn)
  CALL echo("*** END OF ROWS TO INSERT ***")
  FOR (i = 1 TO item_reltn->qual_knt)
    IF ((item_reltn->qual[i].child_knt > 0))
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     INSERT  FROM alt_sel_list al,
       (dummyt d  WITH seq = value(item_reltn->qual[i].child_knt))
      SET al.alt_sel_category_id = item_reltn->qual[i].parent_cat_id, al.synonym_id = item_reltn->
       qual[i].child[d.seq].synonym_id, al.sequence = (item_reltn->qual[i].last_sequence+ d.seq),
       al.list_type = 2, al.updt_cnt = 0, al.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       al.updt_task = reqinfo->updt_task, al.updt_id = 0.1
      PLAN (d
       WHERE d.seq > 0)
       JOIN (al
       WHERE 0=0)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET readme_data->message = "ERROR :: An error inserting Multum item relationships"
      EXECUTE dm_readme_status
      SET readme_data->message = trim(serrmsg)
      EXECUTE dm_readme_status
      SET error_level = 1
      GO TO exit_script
     ENDIF
     COMMIT
    ENDIF
  ENDFOR
 ENDIF
#exit_script
 IF (error_level=1)
  SET status_msg = "FAILURE"
  SET readme_data->status = "F"
 ELSEIF (error_level=2)
  SET status_msg = "WARNING"
  SET readme_data->status = "S"
 ELSE
  SET status_msg = "SUCCESS"
  SET readme_data->status = "S"
 ENDIF
 SET readme_data->message = concat("CPS_MAK_DRUG_CATEGORIES  END : ",trim(status_msg),"  ",format(
   cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 EXECUTE dm_readme_status
 COMMIT
 SET cps_script_version = "12/09/2008"
END GO
