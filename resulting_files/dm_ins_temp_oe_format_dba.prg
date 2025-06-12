CREATE PROGRAM dm_ins_temp_oe_format:dba
 SET c_mod = "DM_INS_TEMP_OE_FORMAT 000"
 DELETE  FROM temp_oe_format
  WHERE oe_format_id > 0
  WITH nocounter
 ;end delete
 COMMIT
 FREE RECORD rec_oe_format
 RECORD rec_oe_format(
   1 qual[*]
     2 oe_format_id = f8
     2 oe_format_name = vc
 )
 DECLARE cnt = i4
 SET cnt = 0
 SELECT DISTINCT INTO "nl:"
  oef.oe_format_id, oef.oe_format_name
  FROM order_entry_format oef
  ORDER BY oef.oe_format_id
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(rec_oe_format->qual,(cnt+ 9))
   ENDIF
   rec_oe_format->qual[cnt].oe_format_id = oef.oe_format_id, rec_oe_format->qual[cnt].oe_format_name
    = oef.oe_format_name
  FOOT REPORT
   stat = alterlist(rec_oe_format->qual,cnt)
  WITH nocounter
 ;end select
 IF (cnt > 0)
  INSERT  FROM temp_oe_format t,
    (dummyt d  WITH seq = value(cnt))
   SET t.oe_format_id = rec_oe_format->qual[d.seq].oe_format_id, t.oe_format_name = trim(
     rec_oe_format->qual[d.seq].oe_format_name)
   PLAN (d
    WHERE (rec_oe_format->qual[d.seq].oe_format_id > 0))
    JOIN (t)
   WITH nocounter, outerjoin = d
  ;end insert
  COMMIT
 ENDIF
 IF (curenv=0)
  SELECT INTO "nl:"
   d.oe_format_name
   FROM temp_oe_format d
   WITH maxqual(d,10), nocounter
  ;end select
  CALL echo("**************************************************************",1,0)
  IF (curqual)
   CALL echo("Rows were successfully inserted on the table temp_oe_format.",1,0)
  ELSE
   CALL echo("No rows found on the table temp_oe_format.",1,0)
  ENDIF
  CALL echo("**************************************************************",1,0)
 ENDIF
#end_of_program
END GO
