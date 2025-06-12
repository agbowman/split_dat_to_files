CREATE PROGRAM cpmdecoder_loadcodes:dba
 RECORD reply(
   1 qual[*]
     2 value_cd = f8
     2 code_disp = vc
     2 code_descr = vc
     2 meaning = vc
     2 code_set = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET actind = 0
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET maxaltersize = 1
 SET maxcount = 65535
 SET lastcodeset = 0
 IF ((request->start_value=0))
  CALL echo("Loading all code sets")
  SET maxaltersize = maxcount
 ELSE
  CALL echo(build("Load code value:",request->start_value))
 ENDIF
 CALL echo(build("alterlist to: ",maxaltersize))
 SET stat = alterlist(reply->qual,maxaltersize)
 SELECT
  IF ((request->start_value=0))
   PLAN (cs
    WHERE cs.cache_ind=1
     AND cs.code_set > 0)
    JOIN (c
    WHERE c.code_set=cs.code_set
     AND c.active_ind=1
     AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY cs.code_set_hits, cs.code_set, c.collation_seq,
    c.display_key
   WITH nocounter, maxqual(cs,value(maxcount))
  ELSE
   PLAN (c
    WHERE (c.code_value=request->start_value))
    JOIN (cs
    WHERE cs.code_set=c.code_set)
   ORDER BY cs.code_set_hits, cs.code_set, c.collation_seq,
    c.display_key
   WITH nocounter, maxqual(cs,maxcount)
  ENDIF
  INTO "nl:"
  cs.code_set_hits, cs.code_set, c.collation_seq,
  c.display, c.active_ind
  FROM code_value c,
   code_value_set cs
  HEAD REPORT
   count1 = 0
  HEAD cs.code_set
   IF (count1 < maxcount)
    lastcodeset = count1
   ENDIF
  DETAIL
   count1 = (count1+ 1)
   IF (count1 <= maxaltersize)
    reply->qual[count1].value_cd = c.code_value, reply->qual[count1].code_disp = c.display, reply->
    qual[count1].code_descr = c.description,
    reply->qual[count1].meaning = c.cdf_meaning, reply->qual[count1].code_set = c.code_set
   ENDIF
   actind = c.active_ind
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
  CALL echo(build("codes loaded: ",count1," /65535-MAX"))
 ELSE
  CALL echo("no code value found!!!!!!")
 ENDIF
 IF (count1 >= maxcount)
  CALL echo("Cache exceeds max value of 65535, cache will be trimed")
  SET count1 = lastcodeset
 ENDIF
 CALL echo(build("AlterList reply->qual[",count1,"]"))
 SET stat = alterlist(reply->qual,count1)
 IF (actind != 1)
  CALL echo("code not active")
  CALL echo(build("code set: ",reply->qual[1].code_set))
 ENDIF
END GO
