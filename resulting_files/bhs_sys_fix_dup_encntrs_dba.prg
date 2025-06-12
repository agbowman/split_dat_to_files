CREATE PROGRAM bhs_sys_fix_dup_encntrs:dba
 PROMPT
  "Enter File name" = "<<File Name without extension>>",
  "Mode" = "TEST"
  WITH outdev, mode
 SET filepath = build("bhscust:", $1,".dat")
 CALL echo(build("Reading File:",filepath))
 IF (findfile(filepath) > 0)
  CALL echo("Found File")
 ELSE
  CALL echo("Did not find the file, will exit")
  GO TO exit_code
 ENDIF
 FREE RECORD duplist
 RECORD duplist(
   1 dupcnt = i4
   1 qual[*]
     2 fin = vc
     2 mrn = vc
     2 eid = f8
     2 pid = f8
     2 name = vc
     2 dupind = i2
     2 line = vc
     2 pname = vc
     2 dupname = vc
     2 dupeid = f8
       3 duppid = f8
     2 ordind = i2
     2 ceind = i2
 )
 DECLARE finnbr = vc
 DECLARE name = vc
 FREE DEFINE rtl
 DEFINE rtl filepath
 SELECT INTO "nl:"
  FROM rtlt r
  HEAD REPORT
   cnt = 0, c1 = 0, c2 = 0
  DETAIL
   finnbr = " ", name = " ", c1 = 0,
   c2 = 0
   IF (trim(r.line,3) > " ")
    cnt = (cnt+ 1), stat = alterlist(duplist->qual,cnt), duplist->qual[cnt].line = trim(r.line,3),
    c1 = findstring("&",duplist->qual[cnt].line,1,0), finnbr = cnvtstring(cnvtint(trim(substring(1,(
        c1 - 1),duplist->qual[cnt].line),3))), duplist->qual[cnt].fin = trim(finnbr,3),
    c2 = findstring("&",duplist->qual[cnt].line,(c1+ 1),1), name = trim(substring((c1+ 1),((c2 - 1)
       - (c1+ 1)),duplist->qual[cnt].line),3), duplist->qual[cnt].name = trim(name,3),
    duplist->dupcnt = (duplist->dupcnt+ 1)
   ENDIF
  WITH nocounter
 ;end select
 DECLARE indx = i4
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(duplist->dupcnt)),
   encntr_alias ea,
   encounter e,
   person p
  PLAN (d)
   JOIN (ea
   WHERE (ea.alias=duplist->qual[d.seq].fin)
    AND ea.encntr_alias_type_cd=1077
    AND ea.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ea.encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
  HEAD REPORT
   indx = 0, pname1 = fillstring(50," ")
  DETAIL
   CALL echo(build("name:",p.name_full_formatted," duplistname:",duplist->qual[d.seq].name)), pname1
    = substring(1,(findstring(",",duplist->qual[d.seq].name,1) - 1),duplist->qual[d.seq].name),
   CALL echo(pname1)
   IF (p.name_last_key=trim(pname1,3))
    CALL echo("name the same"), duplist->qual[d.seq].pname = p.name_full_formatted, duplist->qual[d
    .seq].eid = ea.encntr_id,
    duplist->qual[d.seq].pid = p.person_id, duplist->qual[d.seq].dupind = (duplist->qual[d.seq].
    dupind+ 1)
   ENDIF
   IF (p.name_last_key != trim(pname1,3))
    CALL echo("names not the same"), duplist->qual[d.seq].dupind = (duplist->qual[d.seq].dupind+ 1),
    duplist->qual[d.seq].dupname = trim(p.name_full_formatted)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(duplist->dupcnt)),
   orders o
  PLAN (d
   WHERE (duplist->qual[d.seq].dupind > 1))
   JOIN (o
   WHERE (o.encntr_id=duplist->qual[d.seq].eid))
  DETAIL
   duplist->qual[d.seq].ordind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(duplist->dupcnt)),
   clinical_event ce
  PLAN (d
   WHERE (duplist->qual[d.seq].dupind > 1))
   JOIN (ce
   WHERE (ce.encntr_id=duplist->qual[d.seq].eid))
  DETAIL
   duplist->qual[d.seq].ceind = 1
  WITH nocounter
 ;end select
 DECLARE acc = vc
 DECLARE encntrid = vc
 DECLARE personid = vc
 DECLARE idx_name = vc
 DECLARE dup_name = c50
 DECLARE dup_ind = c50
 DECLARE order_ind = vc
 DECLARE result_ind = vc
 SET stat = remove("idx_dups.dat")
 SELECT INTO "idx_dups"
  acc = duplist->qual[d.seq].fin, encntrid = cnvtstring(duplist->qual[d.seq].eid), personid =
  cnvtstring(duplist->qual[d.seq].pid),
  idx_name = duplist->qual[d.seq].pname, dup_name = duplist->qual[d.seq].dupname, dup_ind =
  cnvtstring(duplist->qual[d.seq].dupind),
  order_ind = cnvtstring(duplist->qual[d.seq].ordind), result_ind = cnvtstring(duplist->qual[d.seq].
   ceind)
  FROM (dummyt d  WITH seq = value(duplist->dupcnt))
  WITH nocounter, pcformat, separator = ";"
 ;end select
END GO
