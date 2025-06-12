CREATE PROGRAM bhs_athn_get_doc_segment
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE where_params = vc WITH noconstant(" 1=1")
 FREE RECORD oreply
 RECORD oreply(
   1 qual[*]
     2 uuid = vc
     2 rowid = vc
     2 segment_id = vc
     2 segment_text = vc
     2 segment_seq = i4
     2 custom_var1 = vc
     2 custom_var2 = vc
     2 updt_dt_tm = vc
 )
 IF (textlen(trim( $2,3)) > 0)
  SET where_params = build(" ds.uuid = '",trim( $2,3),"'")
 ELSEIF (textlen(trim( $3,3)) > 0)
  SET where_params = build(" ds.custom_var1 = '",trim( $3,3),"'")
 ENDIF
 SELECT INTO "nl:"
  FROM bhs_athn_doc_segment ds
  PLAN (ds
   WHERE parser(where_params))
  ORDER BY ds.segment_id
  DETAIL
   cnt += 1, stat = alterlist(oreply->qual,cnt), oreply->qual[cnt].segment_id = ds.segment_id,
   oreply->qual[cnt].segment_seq = ds.segment_seq, oreply->qual[cnt].segment_text = ds.segment_text,
   oreply->qual[cnt].rowid = ds.rowid,
   oreply->qual[cnt].uuid = ds.uuid, oreply->qual[cnt].updt_dt_tm = format(ds.updt_dt_tm,
    "yyyy-MM-dd HH:mm:ss"), oreply->qual[cnt].custom_var1 = ds.custom_var1,
   oreply->qual[cnt].custom_var2 = ds.custom_var2
  WITH nocounter, separator = " ", format,
   time = 30, maxrec = 100
 ;end select
 SET _memory_reply_string = cnvtrectojson(oreply,5)
END GO
