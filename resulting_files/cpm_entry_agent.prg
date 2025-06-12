CREATE PROGRAM cpm_entry_agent
 SET out_file = "cpm_entry_agent.dat"
 IF (cursys="AIX")
  SET stat = remove(out_file)
 ELSE
  SET file_name = trim(concat(out_file,";1"))
  SET stat = remove(file_name)
 ENDIF
 DECLARE desc = c40
 SELECT INTO value(out_file)
  FROM (dummyt d  WITH seq = value(size(request->entrylist,5)))
  DETAIL
   eid = cnvtstring(request->entrylist[d.seq].entryid), desc = request->entrylist[d.seq].
   serverdescrip, numi = cnvtstring(request->entrylist[d.seq].numinstances),
   dline = concat(trim(eid,3),",",trim(desc,3),",",trim(numi,3)), col 0, dline
   IF (d.seq < size(request->entrylist,5))
    row + 1
   ENDIF
  WITH maxcol = 80, noheading, noformat,
   formfeed = none, maxrow = 1
 ;end select
END GO
