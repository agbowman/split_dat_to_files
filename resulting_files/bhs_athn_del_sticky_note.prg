CREATE PROGRAM bhs_athn_del_sticky_note
 RECORD orequest(
   1 sticky_note_id = f8
 )
 SET orequest->sticky_note_id =  $2
 SET stat = tdbexecute(3200000,3200090,500185,"REC",orequest,
  "REC",oreply)
 CALL echojson(oreply, $1)
END GO
