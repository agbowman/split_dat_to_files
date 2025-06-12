CREATE PROGRAM cpm_timer_agent:dba
 DECLARE dline = c160
 SELECT INTO "cpm_timer_agent.dat"
  FROM (dummyt d  WITH seq = value(size(request->timerdata,5)))
  DETAIL
   reqdate = format(request->timerdata[d.seq].date,"mm/dd/yyyy;;d"), reqtime = format(request->
    timerdata[d.seq].date,"hh:mm;;m"), dline = concat(reqdate,",",reqtime,",",trim(request->
     timerdata[d.seq].user),
    ",",trim(request->timerdata[d.seq].event),",",trim(request->timerdata[d.seq].data)),
   col 0, dline, row + 1
  WITH noheading, append, format,
   maxcol = 161
 ;end select
END GO
