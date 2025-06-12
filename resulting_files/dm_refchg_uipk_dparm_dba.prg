CREATE PROGRAM dm_refchg_uipk_dparm:dba
 DECLARE drud_table_name = vc
 DECLARE drud_rcq_size = i4
 DECLARE drud_dc_loop = i4
 DECLARE drud_rcq_size2 = i4
 DECLARE drud_final_size = i4
 SET drud_table_name = trim(cnvtupper( $1),3)
 FREE RECORD drud_collist
 RECORD drud_collist(
   1 err_ind = i2
   1 err_msg = vc
   1 qual[*]
     2 column_name = vc
     2 column_datatype = vc
     2 parent_entity_col = vc
     2 trans_ind = i2
     2 exist_ind = i2
     2 precision_ind = i2
     2 base62_re_name = vc
 )
 EXECUTE dm_refchg_pk_dparm drud_table_name
 IF ((refchg_collist_query->err_ind=1))
  GO TO end_program
 ENDIF
 SET drud_rcq_size = size(refchg_collist_query->qual,5)
 SET stat = moverec(refchg_collist_query->qual,drud_collist->qual)
 SET stat = alterlist(refchg_collist_query->qual,0)
 EXECUTE dm_refchg_ui_dparm drud_table_name
 IF ((refchg_collist_query->err_ind=1))
  GO TO end_program
 ENDIF
 SET drud_rcq_size2 = size(refchg_collist_query->qual,5)
 SET drud_final_size = (drud_rcq_size2+ drud_rcq_size)
 SET stat = alterlist(refchg_collist_query->qual,drud_final_size)
 FOR (drud_dc_loop = (drud_rcq_size2+ 1) TO drud_final_size)
   SET refchg_collist_query->qual[drud_dc_loop].column_datatype = drud_collist->qual[(drud_dc_loop -
   drud_rcq_size2)].column_datatype
   SET refchg_collist_query->qual[drud_dc_loop].column_name = drud_collist->qual[(drud_dc_loop -
   drud_rcq_size2)].column_name
   SET refchg_collist_query->qual[drud_dc_loop].exist_ind = drud_collist->qual[(drud_dc_loop -
   drud_rcq_size2)].exist_ind
   SET refchg_collist_query->qual[drud_dc_loop].parent_entity_col = drud_collist->qual[(drud_dc_loop
    - drud_rcq_size2)].parent_entity_col
   SET refchg_collist_query->qual[drud_dc_loop].trans_ind = drud_collist->qual[(drud_dc_loop -
   drud_rcq_size2)].trans_ind
   SET refchg_collist_query->qual[drud_dc_loop].precision_ind = drud_collist->qual[(drud_dc_loop -
   drud_rcq_size2)].precision_ind
   SET refchg_collist_query->qual[drud_dc_loop].base62_re_name = drud_collist->qual[(drud_dc_loop -
   drud_rcq_size2)].base62_re_name
 ENDFOR
#end_program
END GO
