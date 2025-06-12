CREATE PROGRAM cpm_jou_agent:dba
 SET joulimit = cnvtint(logical("cpm_agent_jou_limit"))
 IF (joulimit=0)
  SET joulimit = 10
 ENDIF
 SET count = size(request->dirlist,5)
 SET searchstring = fillstring(10,"*")
 DECLARE node = c20
 SET node = cnvtupper(logical("JOU_INSTANCE"))
 SET output = concat("cpmjou_",trim(node),"_",format(curdate,"mmmdd;;d"),".csv")
 SELECT INTO value(output)
  servname = concat(request->dirlist[d.seq].servname,searchstring)
  FROM (dummyt d  WITH seq = value(size(request->dirlist,5)))
  ORDER BY servname, d.seq
  HEAD servname
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
  FOOT  servname
   IF (cnt > joulimit)
    joudate = format(request->dirlist[d.seq].datestamp,"mm/dd/yyyy;;d"), joutime = format(request->
     dirlist[d.seq].datestamp,"hh:mm.ss;;m"), date = format(curdate,"mm/dd/yyyy;;d"),
    time = format(curtime3,"hh:mm;;m"), sname = substring(1,(findstring(searchstring,servname,1) - 1),
     servname), count1 = format(cnt,"####;rp0"),
    dline = trim(concat(date,",",time,",",joudate,
      ",",joutime,",",trim(sname),",",
      count1)), col 0, dline,
    row + 1
   ENDIF
  WITH noheading, append, format
 ;end select
END GO
