CREATE PROGRAM cps_hm_qual_prefetch
 CALL echo(concat(format(curdate,"dd-mmm-yyyy;;d")," ",format(curtime3,"hh:mm:ss.cc;3;m"),
   "  *******  Beginning of program cps_hm_qual_prefetch  *******"),1,0)
 IF (validate(reply,0)=0)
  CALL echo("reply did not exist")
  CALL echorecord(request)
  RECORD reply(
    1 person_id = f8
    1 expectation_series[*]
      2 expect_series_mean = vc
      2 expect_sched_mean = vc
      2 status_flag = i2
      2 qualify_explanation = vc
      2 qualify_until_dt_tm = dq8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  SET reply->person_id = request->person_id
  RECORD event(
    1 qual[*]
      2 accession_id = f8
      2 order_id = f8
      2 encntr_id = f8
      2 person_id = f8
      2 logging = c100
      2 cnt = i4
      2 data[*]
        3 misc = vc
  )
  SET stat = alterlist(event->qual,1)
  SET event->qual[1].person_id = request->person_id
 ENDIF
END GO
