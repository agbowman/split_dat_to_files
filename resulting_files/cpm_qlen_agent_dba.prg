CREATE PROGRAM cpm_qlen_agent:dba
 SET searchstring = fillstring(10,"*")
 SET qlen_max = cnvtint(logical("cpm_agent_qlen_limit"))
 IF (qlen_max=0)
  SET qlen_max = 5
 ENDIF
 SET reqdate = format(curdate,"mm/dd/yyyy;;d")
 SET reqtime = format(curtime,"hh:mm;;m")
 DECLARE node = c20
 SET node = cnvtupper(logical("JOU_INSTANCE"))
 SET output = concat("cpmqlen_",trim(node),"_",format(curdate,"mmmdd;;d"),".csv")
 SELECT INTO value(output)
  servicename = concat(request->servicelist[d.seq].servicename,searchstring)
  FROM (dummyt d  WITH seq = value(size(request->servicelist,5)))
  HEAD servicename
   x = 1
  DETAIL
   qlength = request->servicelist[d.seq].currentmessages, x = 1
  FOOT  servicename
   IF (qlength > qlen_max)
    sname = substring(1,(findstring(searchstring,servicename,1) - 1),servicename), length = format(
     request->servicelist[d.seq].currentmessages,"###;rp0"), sid = format(request->servicelist[d.seq]
     .serviceid,"####;rp0"),
    dline = trim(concat(reqdate,",",reqtime,",",length,
      ",",trim(sname),",",sid)), col 0, dline
    IF (d.seq < size(request->servicelist,5))
     row + 1
    ENDIF
   ENDIF
  WITH append, maxcol = 132
 ;end select
END GO
