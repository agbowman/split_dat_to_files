CREATE PROGRAM cpm_serv_agent:dba
 DECLARE desc = c40
 DECLARE pid = c20
 DECLARE uar_oen_get_nodename() = c32
 SET nodename = trim(uar_oen_get_nodename())
 FREE RECORD hrtmp
 RECORD hrtmp(
   1 qual[*]
     2 dttm = dq8
     2 cnt = i4
 )
 SET hrcnt = 0
 SET stat = 0
 SET tmstamp = 0
 SET hrhold = 0
 SET rqsthour = 0
 SET output = concat("cpm_serv_agent_",trim(nodename),".csv")
 SET dm_output = cnvtlower(concat("cpmserv_",trim(nodename),"_",format(curdate,"mmmdd;;d"),".csv"))
 SELECT INTO value(output)
  FROM (dummyt d  WITH seq = value(size(request->serverlist,5)))
  DETAIL
   sdate = format(request->serverlist[d.seq].startdate,"mm/dd/yyyy;;d"), stime = format(request->
    serverlist[d.seq].startdate,"hh:mm;;m"), desc = request->serverlist[d.seq].serverdescrip,
   sid = cnvtstring(request->serverlist[d.seq].serverid), pid = request->serverlist[d.seq].processid,
   state = cnvtstring(request->serverlist[d.seq].state),
   dline = concat(sdate,",",stime,",",trim(desc),
    ",",trim(sid),",",trim(pid),",",
    trim(cnvtstring(state))), col 0, curdate"mm/dd/yyyy;;d",
   ",", curtime"hh:mm;;m", ",",
   dline
   IF (d.seq < size(request->serverlist,5))
    row + 1
   ENDIF
   rqsthour = hour(request->serverlist[d.seq].startdate), tmstamp = cnvtint(trim(concat(format(
       rqsthour,"##"),"0000")))
   IF (hrcnt=0)
    hrcnt = (hrcnt+ 1), stat = alterlist(hrtmp->qual,hrcnt), hrtmp->qual[hrcnt].dttm = cnvtdatetime(
     cnvtdate(request->serverlist[d.seq].startdate),tmstamp),
    hrhold = rqsthour
   ELSE
    IF (rqsthour != hrhold)
     hrcnt = (hrcnt+ 1), stat = alterlist(hrtmp->qual,hrcnt), hrtmp->qual[hrcnt].dttm = cnvtdatetime(
      cnvtdate(request->serverlist[d.seq].startdate),tmstamp),
     hrhold = rqsthour
    ENDIF
   ENDIF
   hrtmp->qual[hrcnt].cnt = (hrtmp->qual[hrcnt].cnt+ 1)
  WITH maxcol = 132, append
 ;end select
 IF (hrcnt > 0)
  SELECT INTO value(dm_output)
   FROM (dummyt d  WITH seq = value(size(hrtmp->qual,5)))
   DETAIL
    sdate = format(hrtmp->qual[d.seq].dttm,"mm/dd/yyyy;;d"), stime = format(hrtmp->qual[d.seq].dttm,
     "hh:mm;;m"), cnt = format(hrtmp->qual[d.seq].cnt,"######"),
    dline = concat(sdate,",",stime,",",trim(cnt)), col 0, dline
    IF (d.seq < size(hrtmp->qual,5))
     row + 1
    ENDIF
   WITH maxcol = 132, append
  ;end select
 ENDIF
END GO
