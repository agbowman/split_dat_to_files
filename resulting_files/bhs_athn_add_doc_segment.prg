CREATE PROGRAM bhs_athn_add_doc_segment
 FREE RECORD orequest
 RECORD orequest(
   1 uuid = vc
   1 segment_id = vc
   1 segment_text = vc
   1 segment_seq = i4
   1 custom_var1 = vc
   1 custom_var2 = vc
   1 status = i4
   1 status_errnum = i4
   1 status_errmsg = c132
 ) WITH protect
 FREE RECORD oreply
 RECORD oreply(
   1 status = c1
   1 status_errnum = i4
   1 status_errmsg = vc
 ) WITH protect
 SET orequest->uuid = trim( $2,3)
 SET orequest->segment_seq =  $3
 SET orequest->segment_text = trim( $4,3)
 SET orequest->custom_var1 = trim( $5,3)
 SET orequest->custom_var2 = trim( $6,3)
 SET orequest->segment_id = concat(trim(orequest->uuid,3),"-",cnvtstring(orequest->segment_seq))
 INSERT  FROM bhs_athn_doc_segment ds,
   (dummyt d  WITH seq = 1)
  SET ds.segment_id = orequest->segment_id, ds.segment_seq = orequest->segment_seq, ds.segment_text
    = orequest->segment_text,
   ds.uuid = orequest->uuid, ds.updt_dt_tm = systimestamp, ds.custom_var1 = orequest->custom_var1,
   ds.custom_var2 = orequest->custom_var2
  PLAN (d)
   JOIN (ds)
  WITH nocounter, status(orequest->status,orequest->status_errnum,orequest->status_errmsg), time = 10
 ;end insert
 COMMIT
 IF ((orequest->status=1))
  SET oreply->status = "S"
 ELSE
  SET oreply->status = "F"
  SET oreply->status_errnum = orequest->status_errnum
  SET oreply->status_errmsg = orequest->status_errmsg
 ENDIF
 SET _memory_reply_string = cnvtrectojson(oreply,5)
END GO
