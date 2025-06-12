CREATE PROGRAM dm_afd_fix_constraints:dba
 SET filename2 = "dm_afd_fix_schema2"
 SET filename3 = "dm_afd_fix_schema3"
 SET tbl_name =  $1
 SET created_flg =  $2
 FREE SET constraint_list
 RECORD constraint_list(
   1 constraint_name[*]
     2 cname = c32
     2 dm_tname = c32
     2 dm_constraint_type = c1
     2 dm_col_cnt = i4
     2 dm_status = c32
     2 dm_rcname = c32
     2 u_tname = c32
     2 u_constraint_type = c1
     2 u_col_cnt = i4
     2 u_status = c32
     2 u_rcname = c32
     2 identical_col_cnt = i4
     2 dropped = i2
   1 constraint_count = i4
 )
 SET stat = alterlist(constraint_list->constraint_name,10)
 SET constraint_list->constraint_count = 0
 SELECT INTO "nl:"
  ui.constraint_name, ui.table_name, ui.r_constraint_name,
  ui.status, ui.constraint_type, y = count(*)
  FROM dm_user_cons_columns uic,
   dm_user_constraints ui
  WHERE ui.constraint_name=uic.constraint_name
   AND ui.table_name=uic.table_name
   AND ui.table_name=tbl_name
   AND ui.constraint_type IN ("P")
  GROUP BY ui.constraint_name, ui.table_name, ui.r_constraint_name,
   ui.status, ui.constraint_type
  DETAIL
   constraint_list->constraint_count = (constraint_list->constraint_count+ 1)
   IF (mod(constraint_list->constraint_count,10)=1
    AND (constraint_list->constraint_count != 1))
    stat = alterlist(constraint_list->constraint_name,(constraint_list->constraint_count+ 9))
   ENDIF
   constraint_list->constraint_name[constraint_list->constraint_count].cname = ui.constraint_name,
   constraint_list->constraint_name[constraint_list->constraint_count].u_tname = ui.table_name,
   constraint_list->constraint_name[constraint_list->constraint_count].u_constraint_type = ui
   .constraint_type,
   constraint_list->constraint_name[constraint_list->constraint_count].u_status = ui.status,
   constraint_list->constraint_name[constraint_list->constraint_count].u_rcname = ui
   .r_constraint_name, constraint_list->constraint_name[constraint_list->constraint_count].u_col_cnt
    = y,
   constraint_list->constraint_name[constraint_list->constraint_count].dm_tname = "", constraint_list
   ->constraint_name[constraint_list->constraint_count].dm_constraint_type = "", constraint_list->
   constraint_name[constraint_list->constraint_count].dm_status = "",
   constraint_list->constraint_name[constraint_list->constraint_count].dm_rcname = "",
   constraint_list->constraint_name[constraint_list->constraint_count].dm_col_cnt = 0,
   constraint_list->constraint_name[constraint_list->constraint_count].dropped = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  di.constraint_name, di.table_name, di.r_constraint_name,
  di.status_ind, di.constraint_type, y = count(*)
  FROM dm_afd_cons_columns dic,
   dm_afd_constraints di
  WHERE di.constraint_name=dic.constraint_name
   AND di.table_name=tbl_name
   AND di.table_name=dic.table_name
   AND di.constraint_type IN ("P")
  GROUP BY di.constraint_name, di.table_name, di.r_constraint_name,
   di.status_ind, di.constraint_type
  DETAIL
   found_it = 0
   FOR (loop_cnt = 1 TO constraint_list->constraint_count)
     IF ((constraint_list->constraint_name[loop_cnt].cname=di.constraint_name))
      found_it = loop_cnt
     ENDIF
   ENDFOR
   IF (found_it=0
    AND created_flg != 1)
    constraint_list->constraint_count = (constraint_list->constraint_count+ 1)
    IF (mod(constraint_list->constraint_count,10)=1
     AND (constraint_list->constraint_count != 1))
     stat = alterlist(constraint_list->constraint_name,(constraint_list->constraint_count+ 9))
    ENDIF
    found_it = constraint_list->constraint_count, constraint_list->constraint_name[found_it].u_tname
     = "", constraint_list->constraint_name[found_it].u_status = "",
    constraint_list->constraint_name[found_it].u_rcname = "", constraint_list->constraint_name[
    found_it].u_col_cnt = 0
   ENDIF
   constraint_list->constraint_name[found_it].cname = di.constraint_name, constraint_list->
   constraint_name[found_it].dm_tname = di.table_name
   IF (di.status_ind=1)
    constraint_list->constraint_name[found_it].dm_status = "ENABLED"
   ELSE
    constraint_list->constraint_name[found_it].dm_status = "DISABLED"
   ENDIF
   constraint_list->constraint_name[found_it].dm_rcname = di.r_constraint_name, constraint_list->
   constraint_name[found_it].dm_col_cnt = y, constraint_list->constraint_name[found_it].dropped = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  dcc.constraint_name, dcc.table_name, y = count(*)
  FROM dm_user_cons_columns ucc,
   dm_afd_cons_columns dcc
  WHERE ucc.constraint_name=dcc.constraint_name
   AND ucc.table_name=dcc.table_name
   AND ucc.column_name=dcc.column_name
   AND ucc.position=dcc.position
   AND tbl_name=dcc.table_name
   AND ucc.constraint_type IN ("P")
  GROUP BY dcc.constraint_name, dcc.table_name
  DETAIL
   found_it = 0
   FOR (loop_cnt = 1 TO constraint_list->constraint_count)
     IF ((constraint_list->constraint_name[loop_cnt].cname=dcc.constraint_name))
      found_it = loop_cnt
     ENDIF
   ENDFOR
   constraint_list->constraint_name[found_it].identical_col_cnt = y
  WITH nocounter
 ;end select
 FOR (loop_count = 1 TO constraint_list->constraint_count)
  FOR (cons_count = 1 TO dropped_cons_list->cons_count)
    IF ((constraint_list->constraint_name[loop_count].cname=dropped_cons_list->cons_name[cons_count].
    cname))
     SELECT INTO "nl:"
      *
      FROM dual
      DETAIL
       constraint_list->constraint_name[loop_count].dropped = 1
      WITH nocounter
     ;end select
    ENDIF
  ENDFOR
  IF ((((constraint_list->constraint_name[loop_count].dm_tname != constraint_list->constraint_name[
  loop_count].u_tname)) OR ((((constraint_list->constraint_name[loop_count].dm_status !=
  constraint_list->constraint_name[loop_count].u_status)) OR ((((constraint_list->constraint_name[
  loop_count].dm_rcname != constraint_list->constraint_name[loop_count].u_rcname)) OR ((((
  constraint_list->constraint_name[loop_count].dm_col_cnt != constraint_list->constraint_name[
  loop_count].u_col_cnt)) OR ((((constraint_list->constraint_name[loop_count].dm_col_cnt !=
  constraint_list->constraint_name[loop_count].identical_col_cnt)) OR ((constraint_list->
  constraint_name[loop_count].dropped=1))) )) )) )) )) )
   IF ((constraint_list->constraint_name[loop_count].u_col_cnt > 0)
    AND (constraint_list->constraint_name[loop_count].dropped=0))
    SELECT INTO value(filename2)
     *
     FROM dual
     DETAIL
      "rdb ALTER TABLE ", constraint_list->constraint_name[loop_count].u_tname, " drop constraint ",
      row + 1, constraint_list->constraint_name[loop_count].cname, " go",
      row + 1
     WITH format = stream, noheading, formfeed = none,
      maxcol = 512, maxrow = 1, append
    ;end select
   ENDIF
   EXECUTE dm_afd_create_constraint constraint_list->constraint_name[loop_count].cname, 1
   EXECUTE dm_afd_create_constraint constraint_list->constraint_name[loop_count].cname, 0
  ENDIF
 ENDFOR
 FREE SET constraint_list
 RECORD constraint_list(
   1 constraint_name[*]
     2 cname = c32
     2 dm_tname = c32
     2 dm_constraint_type = c1
     2 dm_col_cnt = i4
     2 dm_status = c32
     2 dm_rcname = c32
     2 u_tname = c32
     2 u_constraint_type = c1
     2 u_col_cnt = i4
     2 u_status = c32
     2 u_rcname = c32
     2 identical_col_cnt = i4
     2 dropped = i2
   1 constraint_count = i4
 )
 SET stat = alterlist(constraint_list->constraint_name,10)
 SET constraint_list->constraint_count = 0
 SET tbl_name =  $1
 SELECT INTO "nl:"
  ui.constraint_name, ui.table_name, ui.r_constraint_name,
  ui.status, ui.constraint_type, y = count(*)
  FROM dm_user_cons_columns uic,
   dm_user_constraints ui
  WHERE ui.constraint_name=uic.constraint_name
   AND ui.table_name=uic.table_name
   AND ui.table_name=tbl_name
   AND ui.constraint_type IN ("U", "R")
  GROUP BY ui.constraint_name, ui.table_name, ui.r_constraint_name,
   ui.status, ui.constraint_type
  DETAIL
   constraint_list->constraint_count = (constraint_list->constraint_count+ 1)
   IF (mod(constraint_list->constraint_count,10)=1
    AND (constraint_list->constraint_count != 1))
    stat = alterlist(constraint_list->constraint_name,(constraint_list->constraint_count+ 9))
   ENDIF
   constraint_list->constraint_name[constraint_list->constraint_count].cname = ui.constraint_name,
   constraint_list->constraint_name[constraint_list->constraint_count].u_tname = ui.table_name,
   constraint_list->constraint_name[constraint_list->constraint_count].u_constraint_type = ui
   .constraint_type,
   constraint_list->constraint_name[constraint_list->constraint_count].u_status = ui.status,
   constraint_list->constraint_name[constraint_list->constraint_count].u_rcname = ui
   .r_constraint_name, constraint_list->constraint_name[constraint_list->constraint_count].u_col_cnt
    = y,
   constraint_list->constraint_name[constraint_list->constraint_count].dm_tname = "", constraint_list
   ->constraint_name[constraint_list->constraint_count].dm_constraint_type = "", constraint_list->
   constraint_name[constraint_list->constraint_count].dm_status = "",
   constraint_list->constraint_name[constraint_list->constraint_count].dm_rcname = "",
   constraint_list->constraint_name[constraint_list->constraint_count].dm_col_cnt = 0,
   constraint_list->constraint_name[constraint_list->constraint_count].dropped = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  di.constraint_name, di.table_name, di.r_constraint_name,
  di.status_ind, di.constraint_type, y = count(*)
  FROM dm_afd_cons_columns dic,
   dm_afd_constraints di
  WHERE di.constraint_name=dic.constraint_name
   AND di.table_name=tbl_name
   AND di.table_name=dic.table_name
   AND di.constraint_type IN ("U", "R")
  GROUP BY di.constraint_name, di.table_name, di.r_constraint_name,
   di.status_ind, di.constraint_type
  DETAIL
   found_it = 0
   FOR (loop_cnt = 1 TO constraint_list->constraint_count)
     IF ((constraint_list->constraint_name[loop_cnt].cname=di.constraint_name))
      found_it = loop_cnt
     ENDIF
   ENDFOR
   IF (found_it=0
    AND ((di.constraint_type != "U") OR (created_flg != 1)) )
    constraint_list->constraint_count = (constraint_list->constraint_count+ 1)
    IF (mod(constraint_list->constraint_count,10)=1
     AND (constraint_list->constraint_count != 1))
     stat = alterlist(constraint_list->constraint_name,(constraint_list->constraint_count+ 9))
    ENDIF
    found_it = constraint_list->constraint_count, constraint_list->constraint_name[found_it].u_tname
     = "", constraint_list->constraint_name[found_it].u_status = "",
    constraint_list->constraint_name[found_it].u_rcname = "", constraint_list->constraint_name[
    found_it].u_col_cnt = 0
   ENDIF
   constraint_list->constraint_name[found_it].cname = di.constraint_name, constraint_list->
   constraint_name[found_it].dm_tname = di.table_name
   IF (di.status_ind=1)
    constraint_list->constraint_name[found_it].dm_status = "ENABLED"
   ELSE
    constraint_list->constraint_name[found_it].dm_status = "DISABLED"
   ENDIF
   constraint_list->constraint_name[found_it].dm_rcname = di.r_constraint_name, constraint_list->
   constraint_name[found_it].dm_col_cnt = y, constraint_list->constraint_name[found_it].dropped = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  dcc.constraint_name, dcc.table_name, y = count(*)
  FROM dm_user_cons_columns ucc,
   dm_afd_cons_columns dcc
  WHERE ucc.constraint_name=dcc.constraint_name
   AND ucc.table_name=dcc.table_name
   AND ucc.column_name=dcc.column_name
   AND ucc.position=dcc.position
   AND tbl_name=dcc.table_name
   AND ucc.constraint_type IN ("U", "R")
  GROUP BY dcc.constraint_name, dcc.table_name
  DETAIL
   found_it = 0
   FOR (loop_cnt = 1 TO constraint_list->constraint_count)
     IF ((constraint_list->constraint_name[loop_cnt].cname=dcc.constraint_name))
      found_it = loop_cnt
     ENDIF
   ENDFOR
   constraint_list->constraint_name[found_it].identical_col_cnt = y
  WITH nocounter
 ;end select
 FOR (loop_count = 1 TO constraint_list->constraint_count)
  FOR (cons_count = 1 TO dropped_cons_list->cons_count)
    IF ((constraint_list->constraint_name[loop_count].cname=dropped_cons_list->cons_name[cons_count].
    cname))
     SELECT INTO "nl:"
      *
      FROM dual
      DETAIL
       constraint_list->constraint_name[loop_count].dropped = 1
      WITH nocounter
     ;end select
    ENDIF
  ENDFOR
  IF ((((constraint_list->constraint_name[loop_count].dm_tname != constraint_list->constraint_name[
  loop_count].u_tname)) OR ((((constraint_list->constraint_name[loop_count].dm_status !=
  constraint_list->constraint_name[loop_count].u_status)) OR ((((constraint_list->constraint_name[
  loop_count].dm_rcname != constraint_list->constraint_name[loop_count].u_rcname)) OR ((((
  constraint_list->constraint_name[loop_count].dm_col_cnt != constraint_list->constraint_name[
  loop_count].u_col_cnt)) OR ((((constraint_list->constraint_name[loop_count].dm_col_cnt !=
  constraint_list->constraint_name[loop_count].identical_col_cnt)) OR ((constraint_list->
  constraint_name[loop_count].dropped=1))) )) )) )) )) )
   IF ((constraint_list->constraint_name[loop_count].u_col_cnt > 0)
    AND (constraint_list->constraint_name[loop_count].dropped=0))
    SELECT INTO value(filename2)
     *
     FROM dual
     DETAIL
      "rdb ALTER TABLE ", constraint_list->constraint_name[loop_count].u_tname, " drop constraint ",
      row + 1, constraint_list->constraint_name[loop_count].cname, " go",
      row + 1
     WITH format = stream, noheading, formfeed = none,
      maxcol = 512, maxrow = 1, append
    ;end select
   ENDIF
   EXECUTE dm_afd_create_constraint constraint_list->constraint_name[loop_count].cname, 1
  ENDIF
 ENDFOR
END GO
