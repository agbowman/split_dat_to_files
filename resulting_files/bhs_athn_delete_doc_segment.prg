CREATE PROGRAM bhs_athn_delete_doc_segment
 DECLARE where_param = vc WITH protect, noconstant(" ds.updt_dt_tm < SYSDATE-30")
 FREE RECORD oreply
 RECORD oreply(
   1 status = c1
 )
 IF (textlen(trim( $2,3)) > 0)
  SET where_param = build(" ds.uuid = '", $2,"'")
 ENDIF
 IF (textlen(trim( $3,3)) > 0)
  SET where_param = build(" ds.updt_dt_tm < cnvtdatetime('", $3,"')")
 ENDIF
 DELETE  FROM bhs_athn_doc_segment ds
  PLAN (ds
   WHERE parser(where_param))
  WITH nocounter, time = 10
 ;end delete
 COMMIT
 SET oreply->status = "S"
 CALL echo(oreply)
 SET _memory_reply_string = cnvtrectojson(oreply,5)
END GO
