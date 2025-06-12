CREATE PROGRAM ec_profiler_test:dba
 PROMPT
  "Measurement Nbr: " = "",
  "Days Back: " = "1"
  WITH measurementnbr, daysback
 FREE RECORD request
 RECORD request(
   1 start_dt_tm = dq8
   1 stop_dt_tm = dq8
 )
 FREE RECORD reply
 RECORD reply(
   1 facility_cnt = i2
   1 facilities[*]
     2 facility_cd = f8
     2 position_cnt = i2
     2 positions[*]
       3 position_cd = f8
       3 capability_in_use_ind = i2
       3 detail_cnt = i2
       3 details[*]
         4 detail_name = vc
         4 detail_value_txt = vc
 )
 SET request->start_dt_tm = cnvtdatetime((curdate - cnvtint( $DAYSBACK)),000000)
 SET request->stop_dt_tm = cnvtdatetime((curdate - cnvtint( $DAYSBACK)),235959)
 CALL echorecord(request)
 DECLARE parseline = vc WITH noconstant(""), protect
 SET parseline = build2("ec_profiler_m",trim( $MEASUREMENTNBR)," go")
 CALL parser(parseline)
 CALL echorecord(reply)
END GO
