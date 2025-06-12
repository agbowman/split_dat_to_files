CREATE PROGRAM dm_ins_temp_charting_operation:dba
 SET c_mod = "DM_INS_TEMP_CHARTING_OPERATION 000"
 SET debug_ind = 0
 IF ( NOT (validate(i_debug_ind,0)=0
  AND validate(i_debug_ind,1)=1))
  SET debug_ind = i_debug_ind
 ENDIF
 DELETE  FROM temp_charting_operations
  WHERE charting_operations_id > 0
  WITH nocounter
 ;end delete
 COMMIT
 FREE RECORD rec_chart
 RECORD rec_chart(
   1 qual[*]
     2 charting_operations_id = f8
     2 batch_name = vc
 )
 DECLARE cnt = i4
 SET cnt = 0
 SELECT DISTINCT INTO "nl:"
  co.charting_operations_id, co.batch_name
  FROM charting_operations co
  ORDER BY co.charting_operations_id
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(rec_chart->qual,(cnt+ 9))
   ENDIF
   rec_chart->qual[cnt].charting_operations_id = co.charting_operations_id, rec_chart->qual[cnt].
   batch_name = co.batch_name
  FOOT REPORT
   stat = alterlist(rec_chart->qual,cnt)
  WITH nocounter
 ;end select
 IF (cnt > 0)
  INSERT  FROM temp_charting_operations t,
    (dummyt d  WITH seq = value(cnt))
   SET t.charting_operations_id = rec_chart->qual[d.seq].charting_operations_id, t.batch_name = trim(
     rec_chart->qual[d.seq].batch_name)
   PLAN (d
    WHERE (rec_chart->qual[d.seq].charting_operations_id > 0))
    JOIN (t)
   WITH nocounter
  ;end insert
  COMMIT
 ENDIF
 IF (curenv=0)
  SELECT INTO "nl:"
   d.batch_name
   FROM temp_charting_operations d
   WITH maxqual(d,10), nocounter
  ;end select
  CALL echo("**************************************************************",1,0)
  IF (curqual)
   CALL echo("Rows were successfully inserted on the table temp_charting_operations.",1,0)
  ELSE
   CALL echo("No rows found on the table temp_charting_operations.",1,0)
  ENDIF
  CALL echo("**************************************************************",1,0)
 ENDIF
#end_of_program
END GO
