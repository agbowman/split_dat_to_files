CREATE PROGRAM bhs_athn_add_chart_access
 RECORD orequest(
   1 person_id = f8
   1 prsnl_id = f8
   1 ppa_type_cd = f8
   1 last_dt_tm = dq8
   1 last_tz = i4
   1 ppr_cd = f8
   1 view_caption = vc
   1 comp_caption = vc
   1 computer_name = vc
   1 ppa_comment = vc
   1 cancel_logging = i2
 )
 SET orequest->person_id =  $2
 SET orequest->prsnl_id =  $3
 SET date_line = substring(1,10, $4)
 SET time_line = substring(12,8, $4)
 SET orequest->last_dt_tm = cnvtdatetimeutc2(date_line,"YYYY-MM-DD",time_line,"HH;mm;ss",4)
 SET orequest->computer_name =  $5
 SET orequest->ppa_type_cd = 659
 SET orequest->ppr_cd =  $6
 SET orequest->view_caption =  $7
 SET stat = tdbexecute(3200000,3200002,961023,"REC",orequest,
  "REC",oreply)
 SET _memory_reply_string = cnvtrectojson(oreply)
END GO
