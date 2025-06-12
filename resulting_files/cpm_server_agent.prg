CREATE PROGRAM cpm_server_agent
 SET out_file = "cpm_server_agent.dat"
 IF (cursys="AIX")
  SET stat = remove(out_file)
 ELSE
  SET file_name = trim(concat(out_file,";1"))
  SET stat = remove(file_name)
 ENDIF
 DECLARE desc = c40
 DECLARE pid = c10
 SELECT INTO value(out_file)
  FROM (dummyt d  WITH seq = value(size(request->serverlist,5)))
  DETAIL
   eid = cnvtstring(request->serverlist[d.seq].entryid), sid = cnvtstring(request->serverlist[d.seq].
    serverid), desc = request->serverlist[d.seq].serverdescrip,
   state = cnvtstring(request->serverlist[d.seq].state), pid = request->serverlist[d.seq].processid,
   sdate = format(request->serverlist[d.seq].startdate,"mm/dd/yyyy;;d"),
   stime = format(request->serverlist[d.seq].startdate,"hh:mm:ss;;m"), dline = concat(trim(eid,3),",",
    trim(sid,3),",",trim(desc,3),
    ",",trim(state,3),",",trim(pid,3),",",
    sdate," ",stime), col 0,
   dline
   IF (d.seq < size(request->serverlist,5))
    row + 1
   ENDIF
  WITH maxcol = 110, noheading, noformat,
   formfeed = none, maxrow = 1
 ;end select
END GO
