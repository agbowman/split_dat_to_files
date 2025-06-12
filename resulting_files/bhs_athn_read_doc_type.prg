CREATE PROGRAM bhs_athn_read_doc_type
 FREE RECORD orequest
 RECORD orequest(
   1 event_id = f8
 )
 SET orequest->event_id =  $2
 SET stat = tdbexecute(600005,3200200,600160,"REC",orequest,
  "REC",oreply)
 SET _memory_reply_string = cnvtrectojson(oreply,5)
END GO
