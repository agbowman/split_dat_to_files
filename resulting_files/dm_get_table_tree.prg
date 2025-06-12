CREATE PROGRAM dm_get_table_tree
 RECORD reply(
   1 dms_count = i4
   1 qual[*]
     2 dms_name = vc
     2 tcount = i4
     2 qual[*]
       3 tname = vc
       3 tree_level = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->dms_count = 0
 SET reply->status_data.status = "F"
 IF (validate(dm_get_table_tree_reply->dms_count,- (1)))
  CALL parser('RDB ASIS(" begin dm_get_table_tree; end;") go',1)
  SET trace = recpersist
  RECORD dm_get_table_tree_reply(
    1 dms_count = i4
    1 qual[*]
      2 dms_name = vc
      2 tcount = i4
      2 qual[*]
        3 tname = vc
        3 tree_level = i4
  )
  SET trace = norecpersist
  SET dms_cnt = 0
  SET t_cnt = 0
  SET dm_get_table_tree_reply->dms_count = 0
  SELECT INTO "nl:"
   FROM dm_table_tree2 dtt
   ORDER BY dtt.data_model_section, dtt.seq
   HEAD dtt.data_model_section
    dm_get_table_tree_reply->dms_count = (dm_get_table_tree_reply->dms_count+ 1), stat = alterlist(
     dm_get_table_tree_reply->qual,dm_get_table_tree_reply->dms_count), dms_cnt =
    dm_get_table_tree_reply->dms_count,
    dm_get_table_tree_reply->qual[dms_cnt].dms_name = dtt.data_model_section, dm_get_table_tree_reply
    ->qual[dms_cnt].tcount = 0
   DETAIL
    dm_get_table_tree_reply->qual[dms_cnt].tcount = (dm_get_table_tree_reply->qual[dms_cnt].tcount+ 1
    ), stat = alterlist(dm_get_table_tree_reply->qual[dms_cnt].qual,dm_get_table_tree_reply->qual[
     dms_cnt].tcount), t_cnt = dm_get_table_tree_reply->qual[dms_cnt].tcount,
    dm_get_table_tree_reply->qual[dms_cnt].qual[t_cnt].tname = dtt.table_name,
    dm_get_table_tree_reply->qual[dms_cnt].qual[t_cnt].tree_level = dtt.tree_level
   WITH nocounter
  ;end select
 ENDIF
 SET reply->dms_count = dm_get_table_tree_reply->dms_count
 SET stat = alterlist(reply->qual,reply->dms_count)
 FOR (i = 1 TO reply->dms_count)
   SET reply->qual[i].dms_name = dm_get_table_tree_reply->qual[i].dms_name
   SET reply->qual[i].tcount = dm_get_table_tree_reply->qual[i].tcount
   SET stat = alterlist(reply->qual[i].qual,reply->qual[i].tcount)
   FOR (j = 1 TO reply->qual[i].tcount)
    SET reply->qual[i].qual[j].tname = dm_get_table_tree_reply->qual[i].qual[j].tname
    SET reply->qual[i].qual[j].tree_level = dm_get_table_tree_reply->qual[i].qual[j].tree_level
   ENDFOR
 ENDFOR
 SET reply->status_data.status = "S"
END GO
