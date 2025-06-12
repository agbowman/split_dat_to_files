CREATE PROGRAM bhs_athn_generate_order_id
 RECORD orequest(
   1 x = vc
 )
 RECORD out_rec(
   1 status = vc
   1 order_id = vc
 )
 SET stat = tdbexecute(3200000,3200081,380027,"REC",orequest,
  "REC",oreply,4)
 IF ((oreply->status_data.status="S"))
  SET out_rec->status = "Success"
 ELSE
  SET out_rec->status = "Failed"
 ENDIF
 SET out_rec->order_id = cnvtstring(oreply->order_id)
 CALL echojson(out_rec, $1)
END GO
