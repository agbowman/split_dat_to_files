CREATE PROGRAM dm_add_sizing_stat:dba
 FREE SET values_list
 RECORD values_list(
   1 values[*]
     2 segment_name = c30
     2 segment_type = c17
     2 calc_bpr = f8
     2 max_bpr = f8
     2 min_bpr = f8
     2 mean_bpr = f8
     2 stdev_bpr = f8
   1 nbr_segments = i4
 )
 SET stat = alterlist(values_list->values,10)
 SET values_list->nbr_segments = 0
 SELECT INTO "nl:"
  a.table_name, a.bytes_per_row, a.bpr_max,
  a.bpr_min, a.bpr_mean, a.bpr_std_dev
  FROM dm_tables_doc a
  ORDER BY a.table_name
  DETAIL
   values_list->nbr_segments = (values_list->nbr_segments+ 1)
   IF (mod(values_list->nbr_segments,10)=1
    AND (values_list->nbr_segments != 1))
    stat = alterlist(values_list->values,(values_list->nbr_segments+ 9))
   ENDIF
   values_list->values[values_list->nbr_segments].segment_name = a.table_name, values_list->values[
   values_list->nbr_segments].segment_type = "TABLE", values_list->values[values_list->nbr_segments].
   calc_bpr = a.bytes_per_row,
   values_list->values[values_list->nbr_segments].max_bpr = a.bpr_max, values_list->values[
   values_list->nbr_segments].min_bpr = a.bpr_min, values_list->values[values_list->nbr_segments].
   mean_bpr = a.bpr_mean,
   values_list->values[values_list->nbr_segments].stdev_bpr = a.bpr_std_dev
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  a.index_name, a.bpr_max, a.bpr_min,
  a.bpr_mean, a.bpr_std_dev
  FROM dm_indexes_doc a
  ORDER BY a.index_name
  DETAIL
   values_list->nbr_segments = (values_list->nbr_segments+ 1)
   IF (mod(values_list->nbr_segments,10)=1
    AND (values_list->nbr_segments != 1))
    stat = alterlist(values_list->values,(values_list->nbr_segments+ 9))
   ENDIF
   values_list->values[values_list->nbr_segments].segment_name = a.index_name, values_list->values[
   values_list->nbr_segments].segment_type = "INDEX", values_list->values[values_list->nbr_segments].
   calc_bpr = a.bytes_per_row,
   values_list->values[values_list->nbr_segments].max_bpr = a.bpr_max, values_list->values[
   values_list->nbr_segments].min_bpr = a.bpr_min, values_list->values[values_list->nbr_segments].
   mean_bpr = a.bpr_mean,
   values_list->values[values_list->nbr_segments].stdev_bpr = a.bpr_std_dev
  WITH nocounter
 ;end select
 FOR (cnt = 1 TO values_list->nbr_segments)
   UPDATE  FROM dm_sizing_stat st
    SET st.calc_bytes_per_row = values_list->values[cnt].calc_bpr, st.max_bytes_per_row = values_list
     ->values[cnt].max_bpr, st.min_bytes_per_row = values_list->values[cnt].min_bpr,
     st.mean_bytes_per_row = values_list->values[cnt].mean_bpr, st.stdev_bytes_per_row = values_list
     ->values[cnt].stdev_bpr
    WHERE (st.segment_name=values_list->values[cnt].segment_name)
     AND (st.segment_type=values_list->values[cnt].segment_type)
   ;end update
 ENDFOR
 COMMIT
END GO
