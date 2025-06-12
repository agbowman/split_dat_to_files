CREATE PROGRAM dm_purge_get_columns:dba
 FREE SET reply
 RECORD reply(
   1 parent[*]
     2 column_name = vc
     2 position = i2
   1 child[*]
     2 column_name = vc
     2 position = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE v_par_cons_name = vc
 DECLARE v_child_cons_name = vc
 SET reply->status_data.status = "F"
 SET v_col_cnt = 0
 SELECT INTO "nl:"
  utc.column_name
  FROM user_tab_columns utc
  WHERE utc.table_name=cnvtupper(request->parent_table)
  ORDER BY utc.column_name
  DETAIL
   v_col_cnt = (v_col_cnt+ 1)
   IF (mod(v_col_cnt,10)=1)
    stat = alterlist(reply->parent,(v_col_cnt+ 9))
   ENDIF
   reply->parent[v_col_cnt].column_name = utc.column_name
  FOOT REPORT
   stat = alterlist(reply->parent,v_col_cnt)
  WITH nocounter
 ;end select
 IF ((request->mode=1))
  SELECT INTO "nl:"
   ucc.column_name, ucc.position, ucc.constraint_name
   FROM user_constraints uc,
    user_cons_columns ucc
   WHERE uc.table_name=cnvtupper(request->parent_table)
    AND uc.constraint_type="P"
    AND ucc.constraint_name=uc.constraint_name
   DETAIL
    v_par_cons_name = ucc.constraint_name
    FOR (col_ndx = 1 TO v_col_cnt)
      IF ((ucc.column_name=reply->parent[col_ndx].column_name))
       reply->parent[col_ndx].position = ucc.position, col_ndx = (v_col_cnt+ 1)
      ENDIF
    ENDFOR
   WITH nocounter
  ;end select
 ENDIF
 SET v_col_cnt = 0
 SELECT INTO "nl:"
  utc.column_name
  FROM user_tab_columns utc
  WHERE utc.table_name=cnvtupper(request->child_table)
  ORDER BY utc.column_name
  DETAIL
   v_col_cnt = (v_col_cnt+ 1)
   IF (mod(v_col_cnt,10)=1)
    stat = alterlist(reply->child,(v_col_cnt+ 9))
   ENDIF
   reply->child[v_col_cnt].column_name = utc.column_name
  FOOT REPORT
   stat = alterlist(reply->child,v_col_cnt)
  WITH nocounter
 ;end select
 IF ((request->mode=1)
  AND size(v_par_cons_name) > 0)
  SELECT INTO "nl:"
   uc.constraint_name
   FROM user_constraints uc
   WHERE uc.table_name=cnvtupper(request->child_table)
    AND uc.r_constraint_name=v_par_cons_name
   ORDER BY uc.constraint_name
   DETAIL
    v_child_cons_name = uc.constraint_name
   WITH nocounter, maxqual(uc,1)
  ;end select
  IF (curqual > 0)
   SELECT INTO "nl:"
    ucc.column_name, ucc.position
    FROM user_cons_columns ucc,
     user_constraints uc
    WHERE uc.table_name=cnvtupper(request->child_table)
     AND uc.r_constraint_name=v_par_cons_name
     AND uc.constraint_name=v_child_cons_name
     AND ucc.constraint_name=uc.constraint_name
    DETAIL
     FOR (col_ndx = 1 TO v_col_cnt)
       IF ((ucc.column_name=reply->child[col_ndx].column_name))
        reply->child[col_ndx].position = ucc.position, col_ndx = (v_col_cnt+ 1)
       ENDIF
     ENDFOR
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
END GO
