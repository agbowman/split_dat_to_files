CREATE PROGRAM bhs_athn_get_messages_v2
 RECORD orequest(
   1 task_id = f8
   1 prsnl_id = f8
 )
 RECORD out_rec(
   1 status = vc
   1 message = vc
 )
 SET orequest->prsnl_id =  $2
 SET orequest->task_id =  $3
 SET out_rec->status = "F"
 SET stat = tdbexecute(600005,967100,3200128,"REC",orequest,
  "REC",oreply,1)
 SET out_rec->status = oreply->status_data.status
 SET out_rec->message = oreply->text
 SET _memory_reply_string = cnvtrectojson(out_rec)
 FREE RECORD out_rec
END GO
