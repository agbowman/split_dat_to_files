CREATE PROGRAM dm_merge_upd_action_values
 RECORD t(
   1 tcnt = i4
   1 qual[*]
     2 table_name = vc
     2 from_rowid = vc
     2 to_rowid = vc
     2 column_name = vc
     2 merge_id = i4
     2 from_value = f8
     2 to_value = f8
 )
 SET t->tcnt = 0
 SELECT INTO "nl:"
  dma.from_rowid, dma.to_rowid
  FROM dm_temp_constraints dtc,
   dm_merge_action dma
  WHERE ((dma.from_value=null) OR (dma.from_value=0))
   AND dma.table_name=dtc.table_name
  DETAIL
   t->tcnt = (t->tcnt+ 1), stat = alterlist(t->qual,t->tcnt), t->qual[t->tcnt].table_name = dma
   .table_name,
   t->qual[t->tcnt].from_rowid = dma.from_rowid, t->qual[t->tcnt].to_rowid = dma.to_rowid, t->qual[t
   ->tcnt].column_name = dtc.column_name,
   t->qual[t->tcnt].merge_id = dma.merge_id
  WITH nocounter
 ;end select
 FOR (i = 1 TO t->tcnt)
   CALL parser('select into "nl:" from ')
   CALL parser(concat(t->qual[i].table_name,"@loc_mrg_link t1"))
   CALL parser(build(' where t1.rowid = "',t->qual[i].from_rowid,'"'))
   CALL parser(build(" detail t->qual[",i,"].from_value = t1.",t->qual[i].column_name))
   CALL parser(" with nocounter go")
   IF ((t->qual[i].to_rowid != ""))
    CALL parser('select into "nl:" from ')
    CALL parser(concat(t->qual[i].table_name," t1"))
    CALL parser(build(' where t1.rowid = "',t->qual[i].to_rowid,'"'))
    CALL parser(build(" detail t->qual[",i,"].to_value = t1.",t->qual[i].column_name))
    CALL parser(" with nocounter go")
   ENDIF
 ENDFOR
 UPDATE  FROM dm_merge_action dma,
   (dummyt d  WITH seq = value(t->tcnt))
  SET dma.from_value = t->qual[d.seq].from_value, dma.to_value = t->qual[d.seq].to_value
  PLAN (d)
   JOIN (dma
   WHERE (dma.merge_id=t->qual[d.seq].merge_id))
  WITH nocounter
 ;end update
 COMMIT
END GO
