CREATE PROGRAM dm_rmc_get_md_data:dba
 FREE RECORD master
 RECORD master(
   1 qual[*]
     2 table_name = vc
     2 top_level_ind = i2
     2 child_cnt = i4
 )
 FREE RECORD pe_data
 RECORD pe_data(
   1 qual[*]
     2 table_name = vc
     2 col_name = vc
 )
 DECLARE cnt = i4
 DECLARE loop = i4
 DECLARE pcnt = i4
 DECLARE ploop = i4
 DECLARE ccnt = i4
 DECLARE lp = i4
 DECLARE in_str = vc
 SELECT INTO "NL:"
  FROM user_tables u
  WHERE  EXISTS (
  (SELECT
   "x"
   FROM dm_tables_doc d
   WHERE d.table_name=d.full_table_name
    AND d.merge_delete_ind=1
    AND  NOT (d.table_name IN ("LONG_TEXT", "LONG_BLOB", "LONG_TEXT_REFERENCE", "LONG_BLOB_REFERENCE"
   ))
    AND u.table_name=d.table_name))
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(master->qual,cnt), master->qual[cnt].table_name = u.table_name
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM user_tab_columns u,
   dm_columns_doc d
  WHERE d.table_name IN (
  (SELECT
   table_name
   FROM dm_tables_doc
   WHERE full_table_name=table_name
    AND ((reference_ind=1) OR (table_name IN (
   (SELECT
    rt.table_name
    FROM dm_rdds_refmrg_tables rt)))) ))
   AND  NOT (d.table_name IN ("LONG_TEXT", "LONG_BLOB", "LONG_TEXT_REFERENCE", "LONG_BLOB_REFERENCE")
  )
   AND d.parent_entity_col > " "
   AND d.parent_entity_col IS NOT null
   AND u.column_name=d.column_name
   AND u.table_name=d.table_name
  DETAIL
   pcnt = (pcnt+ 1), stat = alterlist(pe_data->qual,pcnt), pe_data->qual[pcnt].table_name = d
   .table_name,
   pe_data->qual[pcnt].col_name = d.parent_entity_col
  WITH nocounter
 ;end select
 FOR (loop = 1 TO cnt)
  SELECT INTO "NL:"
   FROM user_tab_columns u
   WHERE (u.table_name=master->qual[loop].table_name)
    AND  EXISTS (
   (SELECT
    "x"
    FROM dm_columns_doc d
    WHERE d.table_name=d.root_entity_name
     AND d.column_name=d.root_entity_attr
     AND u.table_name=d.table_name
     AND u.column_name=d.column_name))
   DETAIL
    master->qual[loop].top_level_ind = 1
   WITH nocounter
  ;end select
  IF ((master->qual[loop].top_level_ind=1))
   SET ccnt = 0
   SELECT DISTINCT INTO "NL:"
    d.table_name
    FROM dm_columns_doc d
    WHERE (d.root_entity_name=master->qual[loop].table_name)
     AND (d.table_name != master->qual[loop].table_name)
     AND d.table_name IN (
    (SELECT
     table_name
     FROM dm_tables_doc
     WHERE reference_ind=1
      AND full_table_name=table_name))
     AND  EXISTS (
    (SELECT
     "x"
     FROM user_tab_columns u
     WHERE u.table_name=d.table_name
      AND u.column_name=d.column_name))
    DETAIL
     ccnt = (ccnt+ 1), master->qual[loop].child_cnt = ccnt
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
 SET in_str = " in ("
 FOR (loop = 1 TO cnt)
   IF ((master->qual[loop].child_cnt=0)
    AND (master->qual[loop].top_level_ind=1))
    IF (in_str=" in (")
     SET in_str = concat(in_str,"'",master->qual[loop].table_name,"'")
    ELSE
     SET in_str = concat(in_str,",'",master->qual[loop].table_name,"'")
    ENDIF
   ENDIF
 ENDFOR
 SET in_str = concat(in_str,")")
 FOR (ploop = 1 TO pcnt)
   CALL parser(concat('select distinct into "NL:" d.',pe_data->qual[ploop].col_name),0)
   CALL parser(concat("from ",pe_data->qual[ploop].table_name," d"),0)
   CALL parser(concat("where ",pe_data->qual[ploop].col_name,in_str),0)
   CALL parser(concat("detail idx = locateval(lp,1,cnt,d.",pe_data->qual[ploop].col_name,
     ",master->qual[lp].table_name)"),0)
   CALL parser(" if (lp > 0) master->qual[lp].child_cnt = master->qual[lp].child_cnt + 1 endif",0)
   CALL parser(" with nocounter go",1)
 ENDFOR
 CALL echo("top level w/ children")
 FOR (loop = 1 TO cnt)
   IF ((master->qual[loop].child_cnt > 0))
    CALL echo(master->qual[loop].table_name)
   ENDIF
 ENDFOR
 CALL echo("top level but not RE or PE references")
 FOR (loop = 1 TO cnt)
   IF ((master->qual[loop].child_cnt=0)
    AND (master->qual[loop].top_level_ind=1))
    CALL echo(master->qual[loop].table_name)
   ENDIF
 ENDFOR
END GO
