CREATE PROGRAM cpm_smon_agent:dba
 DECLARE servicename = c40
 DECLARE node = c20
 SET node = cnvtupper(logical("JOU_INSTANCE"))
 SET dout = format(curdate,"mm/dd/yyyy;;d")
 SET tout = format(curtime,"hh:mm;;m")
 IF (tout=" ")
  SET tout = cnvtstring(curtime)
 ENDIF
 SET output = concat("cpmsmon_",trim(node),"_",format(curdate,"mmmdd;;d"),".csv")
 SELECT INTO value(output)
  FROM (dummyt d  WITH seq = value(size(request->servicelist,5)))
  DETAIL
   servicename = request->servicelist[d.seq].servicename, totalmessages = cnvtstring(request->
    servicelist[d.seq].totalmessages), dline = concat(dout,",",tout,",",trim(servicename),
    ",",trim(totalmessages)),
   col 0, dline, row + 1
  WITH maxcol = 80, append
 ;end select
END GO
