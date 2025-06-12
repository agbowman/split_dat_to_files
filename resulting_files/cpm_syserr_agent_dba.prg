CREATE PROGRAM cpm_syserr_agent:dba
 DECLARE dline = c160
 SELECT INTO "cpm_syserr_agent.dat"
  DETAIL
   reqdate = format(request->date,"mm/dd/yyyy;;d"), reqtime = format(request->date,"hh:mm;;m"), dline
    = concat(reqdate,",",reqtime,",",trim(request->user),
    ",",trim(request->event),",",trim(request->data)),
   col 0, dline, row + 1
  WITH noheading, append, format,
   maxcol = 161
 ;end select
END GO
