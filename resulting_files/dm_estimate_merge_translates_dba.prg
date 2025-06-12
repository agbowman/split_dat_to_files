CREATE PROGRAM dm_estimate_merge_translates:dba
 DECLARE dcm_cnt = i4 WITH protect
 DECLARE dcm_count = i4 WITH protect
 DECLARE dcm_value_cnt = i4 WITH protect
 DECLARE dcm_insert_cnt = i4 WITH protect
 DECLARE errmsg = c132 WITH protect
 DECLARE dcm_finished = i4 WITH protect
 DECLARE dcm_more_del = i4 WITH protect
 SET dcm_cnt = 0
 SET dcm_count = 0
 SET dcm_value_cnt = 0
 SET dcm_insert_cnt = 0
 SET dcm_more_del = 1
 SET dcm_finished = 0
 CALL echo("Start dm_estimate_merge_translates")
 DECLARE count_spec(tbl_name=vc) = null
 FREE RECORD dcm_trans_table
 RECORD dcm_trans_table(
   1 list[*]
     2 column_name = vc
     2 table_name = vc
     2 distinct_ind = i2
 )
 CALL echo("Select qualified reference tables....")
 SELECT INTO "nl:"
  utc.table_name, utc.column_name
  FROM user_tab_columns utc,
   dm_tables_doc dtd,
   dm_columns_doc dcd
  PLAN (dtd
   WHERE dtd.reference_ind=1)
   JOIN (utc
   WHERE utc.data_type IN ("NUMBER", "FLOAT", "BIGINT")
    AND dtd.table_name=utc.table_name
    AND  EXISTS (
   (SELECT
    ucc.column_name
    FROM user_cons_columns ucc,
     user_constraints uc
    WHERE uc.table_name=utc.table_name
     AND uc.constraint_name=ucc.constraint_name
     AND uc.table_name=ucc.table_name
     AND uc.constraint_type="P"
     AND ucc.column_name=utc.column_name
     AND ucc.position=1
     AND  NOT ( EXISTS (
    (SELECT
     ucc2.column_name
     FROM user_cons_columns ucc2
     WHERE ucc2.constraint_name=ucc.constraint_name
      AND ucc2.table_name=ucc.table_name
      AND ucc2.position=2))))))
   JOIN (dcd
   WHERE dcd.table_name=dtd.table_name
    AND dcd.column_name=utc.column_name
    AND dcd.root_entity_name=dcd.table_name)
  HEAD REPORT
   stat = alterlist(dcm_trans_table->list,100)
  DETAIL
   dcm_cnt = (dcm_cnt+ 1)
   IF (mod(dcm_cnt,100)=1
    AND dcm_cnt != 1)
    stat = alterlist(dcm_trans_table->list,(dcm_cnt+ 100))
   ENDIF
   dcm_trans_table->list[dcm_cnt].table_name = utc.table_name, dcm_trans_table->list[dcm_cnt].
   column_name = utc.column_name, dcm_trans_table->list[dcm_cnt].distinct_ind = 0
  FOOT REPORT
   stat = alterlist(dcm_trans_table->list,dcm_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM user_tab_columns utc
  WHERE utc.table_name IN ("DCP_SECTION_REF", "DCP_FORMS_REF")
  DETAIL
   IF (utc.column_name="DCP_SECTION_INSTANCE_ID")
    stat = alterlist(dcm_trans_table->list,(dcm_cnt+ 1)), dcm_trans_table->list[(dcm_cnt+ 1)].
    table_name = "DCP_SECTION_REF", dcm_trans_table->list[(dcm_cnt+ 1)].column_name =
    "DCP_SECTION_REF_ID",
    dcm_trans_table->list[(dcm_cnt+ 1)].distinct_ind = 1, dcm_cnt = (dcm_cnt+ 1)
   ENDIF
   IF (utc.column_name="DCP_FORM_INSTANCE_ID")
    stat = alterlist(dcm_trans_table->list,(dcm_cnt+ 1)), dcm_trans_table->list[(dcm_cnt+ 1)].
    table_name = "DCP_FORMS_REF", dcm_trans_table->list[(dcm_cnt+ 1)].column_name =
    "DCP_FORMS_REF_ID",
    dcm_trans_table->list[(dcm_cnt+ 1)].distinct_ind = 1, dcm_cnt = (dcm_cnt+ 1)
   ENDIF
  WITH nocounter
 ;end select
 SET err_code = error(errmsg,1)
 SET dem_row_count = 0
 WHILE (dcm_count < dcm_cnt)
  SET dcm_count = (dcm_count+ 1)
  SELECT
   IF ((dcm_trans_table->list[dcm_count].distinct_ind=1))
    dem_count = parser(concat("count(distinct ",dcm_trans_table->list[dcm_count].column_name,")"))
   ELSE
    dem_count = count(*)
   ENDIF
   INTO "nl:"
   FROM (value(dcm_trans_table->list[dcm_count].table_name))
   DETAIL
    dem_row_count = (dem_row_count+ dem_count)
   WITH nocounter
  ;end select
 ENDWHILE
 CALL count_spec("PERSON")
 CALL count_spec("PERSON_ALIAS")
 CALL count_spec("PERSON_NAME")
 CALL count_spec("ADDRESS")
 CALL count_spec("PHONE")
 SUBROUTINE count_spec(tbl_name)
   IF (tbl_name IN ("PERSON", "PERSON_ALIAS", "PERSON_NAME"))
    SELECT INTO "nl:"
     vt = count(*)
     FROM (value(tbl_name) p),
      prsnl pl
     WHERE p.person_id=pl.person_id
     DETAIL
      dem_row_count = (dem_row_count+ vt)
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     pr = count(*)
     FROM (value(tbl_name) a),
      prsnl pr
     WHERE a.parent_entity_name IN ("PERSON", "PRSNL")
      AND a.parent_entity_id=pr.person_id
     DETAIL
      dem_row_count = (dem_row_count+ pr)
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 FREE RECORD mrg_obj
 RECORD mrg_obj(
   1 obj_cnt = i4
   1 obj[*]
     2 obj_name = vc
     2 obj_type = vc
     2 tspace_name = vc
     2 max_extents = f8
     2 cur_extents = i4
     2 need_extent = i2
     2 next_extent = f8
     2 size = f8
   1 tsp_cnt = i4
   1 tsp[*]
     2 tsp_name = vc
     2 free_space = f8
     2 need_space = f8
 )
 SET mrg_obj->obj_cnt = 0
 SET stat = alterlist(mrg_obj->obj,0)
 SET mrg_obj->tsp_cnt = 0
 SET stat = alterlist(mrg_obj->tsp,0)
 SET dem_d_tspace = fillstring(30," ")
 SET dem_i_tspace = fillstring(30," ")
 SET dem_d_next_ext = 0.0
 SET dem_i_next_ext = 0.0
 SELECT INTO "nl:"
  FROM user_indexes ui,
   user_tables ut
  WHERE ut.table_name="DM_MERGE_TRANSLATE"
   AND ui.table_name=ut.table_name
  ORDER BY ut.table_name, ui.index_name
  HEAD REPORT
   SUBROUTINE add_tsp(tspname)
     fnd_ti = 0
     FOR (ti = 1 TO mrg_obj->tsp_cnt)
       IF ((ui.tablespace_name=mrg_obj->tsp[ti].tsp_name))
        fnd_ti = ti
       ENDIF
     ENDFOR
     IF (fnd_ti=0)
      mrg_obj->tsp_cnt = (mrg_obj->tsp_cnt+ 1), stat = alterlist(mrg_obj->tsp,mrg_obj->tsp_cnt),
      mrg_obj->tsp[mrg_obj->tsp_cnt].tsp_name = tspname,
      mrg_obj->tsp[mrg_obj->tsp_cnt].free_space = 0.0, mrg_obj->tsp[mrg_obj->tsp_cnt].need_space =
      0.0
     ENDIF
   END ;Subroutine report
   ,
   SUBROUTINE add_obj(oname,otype,tspname,nextext,maxext)
     mrg_obj->obj_cnt = (mrg_obj->obj_cnt+ 1), stat = alterlist(mrg_obj->obj,mrg_obj->obj_cnt),
     mrg_obj->obj[mrg_obj->obj_cnt].obj_name = oname,
     mrg_obj->obj[mrg_obj->obj_cnt].obj_type = otype, mrg_obj->obj[mrg_obj->obj_cnt].tspace_name =
     tspname, mrg_obj->obj[mrg_obj->obj_cnt].next_extent = nextext,
     mrg_obj->obj[mrg_obj->obj_cnt].max_extents = maxext, mrg_obj->obj[mrg_obj->obj_cnt].cur_extents
      = 0, mrg_obj->obj[mrg_obj->obj_cnt].need_extent = 0,
     mrg_obj->obj[mrg_obj->obj_cnt].size = 0.0
   END ;Subroutine report
  HEAD ut.table_name
   CALL add_obj(ut.table_name,"TABLE",ut.tablespace_name,ut.next_extent,ut.max_extents),
   CALL add_tsp(ut.tablespace_name)
  HEAD ui.index_name
   CALL add_obj(ui.index_name,"INDEX",ui.tablespace_name,ui.next_extent,ui.max_extents),
   CALL add_tsp(ui.tablespace_name)
  DETAIL
   dem_d_tspace = ut.tablespace_name
   IF (ut.next_extent > dem_d_next_ext)
    dem_d_next_ext = ut.next_extent
   ENDIF
   dem_i_tspace = ui.tablespace_name
   IF (ui.next_extent > dem_i_next_ext)
    dem_i_next_ext = ui.next_extent
   ENDIF
  WITH nocounter
 ;end select
 IF ((mrg_obj->obj_cnt=0))
  CALL echo("***")
  CALL echo("*** ERROR! The desired objects were not found.")
  CALL echo("*** The table DM_MERGE_TRANSLATE or its indexes do not exist.")
  CALL echo("***")
  GO TO exit_program
 ENDIF
 IF ((mrg_obj->tsp_cnt=0))
  CALL echo("***")
  CALL echo("*** ERROR! The tablespaces for desired objects were not found.")
  CALL echo("*** Unable to determine tablespace for DM_MERGE_TRANSLATE and its indexes.")
  CALL echo("***")
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(mrg_obj->obj_cnt))
  PLAN (d)
  DETAIL
   IF (findstring("DM_MERGE",mrg_obj->obj[d.seq].obj_name)=1)
    mrg_obj->obj[d.seq].size = (((7 * 22.0) * dem_row_count)+ ((1 * 30.0) * dem_row_count))
   ELSEIF (findstring("XPK",mrg_obj->obj[d.seq].obj_name)=1)
    mrg_obj->obj[d.seq].size = (((4 * 22.0) * dem_row_count)+ ((1 * 30.0) * dem_row_count))
   ELSEIF (findstring("XIE1",mrg_obj->obj[d.seq].obj_name)=1)
    mrg_obj->obj[d.seq].size = ((1 * 22.0) * dem_row_count)
   ELSEIF (findstring("XIE2",mrg_obj->obj[d.seq].obj_name)=1)
    mrg_obj->obj[d.seq].size = ((1 * 22.0) * dem_row_count)
   ELSEIF (findstring("XIE3",mrg_obj->obj[d.seq].obj_name)=1)
    mrg_obj->obj[d.seq].size = ((1 * 30.0) * dem_row_count)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dba_free_space d,
   (dummyt t  WITH seq = value(mrg_obj->tsp_cnt))
  PLAN (t)
   JOIN (d
   WHERE (d.tablespace_name=mrg_obj->tsp[t.seq].tsp_name))
  DETAIL
   IF (findstring("D_",d.tablespace_name)=1)
    IF (d.bytes > dem_d_next_ext)
     mrg_obj->tsp[t.seq].free_space = (mrg_obj->tsp[t.seq].free_space+ d.bytes)
    ENDIF
   ELSEIF (findstring("I_",d.tablespace_name)=1)
    IF (d.bytes > dem_i_next_ext)
     mrg_obj->tsp[t.seq].free_space = (mrg_obj->tsp[t.seq].free_space+ d.bytes)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(mrg_obj->obj_cnt)),
   (dummyt t  WITH seq = value(mrg_obj->tsp_cnt))
  PLAN (d)
   JOIN (t
   WHERE (mrg_obj->tsp[t.seq].tsp_name=mrg_obj->obj[d.seq].tspace_name))
  DETAIL
   IF ((mrg_obj->obj[d.seq].size > mrg_obj->tsp[t.seq].free_space))
    mrg_obj->tsp[t.seq].need_space = (mrg_obj->tsp[t.seq].need_space+ mrg_obj->obj[d.seq].size)
   ELSE
    mrg_obj->tsp[t.seq].free_space = (mrg_obj->tsp[t.seq].free_space - mrg_obj->obj[d.seq].size)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dba_extents e,
   (dummyt d  WITH seq = value(mrg_obj->obj_cnt))
  PLAN (d
   WHERE (mrg_obj->obj[d.seq].next_extent > 0))
   JOIN (e
   WHERE (e.segment_name=mrg_obj->obj[d.seq].obj_name))
  DETAIL
   mrg_obj->obj[d.seq].cur_extents = (mrg_obj->obj[d.seq].cur_extents+ 1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(mrg_obj->obj_cnt))
  PLAN (d
   WHERE (mrg_obj->obj[d.seq].next_extent > 0))
  DETAIL
   IF (((ceil((mrg_obj->obj[d.seq].size/ mrg_obj->obj[d.seq].next_extent))+ mrg_obj->obj[d.seq].
   cur_extents) > mrg_obj->obj[d.seq].max_extents))
    mrg_obj->obj[d.seq].need_extent = (ceil((mrg_obj->obj[d.seq].size/ mrg_obj->obj[d.seq].
     next_extent))+ mrg_obj->obj[d.seq].cur_extents)
   ENDIF
  WITH nocounter
 ;end select
 SET tsp_header = 1
 FOR (ti = 1 TO mrg_obj->tsp_cnt)
   IF ((mrg_obj->tsp[ti].need_space > 0))
    IF (tsp_header=1)
     CALL echo("***")
     CALL echo("*** The following tablespace(s) need more space: ")
     SET tsp_header = 0
    ENDIF
    CALL echo(concat("*** Tablespace ",trim(mrg_obj->tsp[ti].tsp_name)," may need an additional ",
      trim(cnvtstring(mrg_obj->tsp[ti].need_space))," bytes"))
   ENDIF
 ENDFOR
 SET ext_header = 1
 FOR (ti = 1 TO mrg_obj->obj_cnt)
   IF ((mrg_obj->obj[ti].need_extent > 0))
    IF (ext_header=1)
     CALL echo("***")
     CALL echo("*** The following object(s) may run out of extents.")
     CALL echo("*** Please modify the max extents or next extent size for these objects.")
     SET ext_header = 0
    ENDIF
    CALL echo(concat("*** Object ",trim(mrg_obj->obj[ti].obj_name)," (",trim(mrg_obj->obj[ti].
       obj_type),") may need max_extents = ",
      trim(cnvtstring(mrg_obj->obj[ti].need_extent))))
   ENDIF
 ENDFOR
 IF (tsp_header=1
  AND ext_header=1)
  CALL echo("***")
  CALL echo("*** Sufficient tablespace found.")
 ENDIF
 CALL echo("***")
#exit_program
END GO
