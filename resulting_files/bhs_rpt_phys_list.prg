CREATE PROGRAM bhs_rpt_phys_list
 PROMPT
  "output" = "MINE",
  "File name" = " "
  WITH outdev, mode
 SET filepath = build("bhscust:", $2,".txt")
 CALL echo(build("Reading File:",filepath))
 IF (findfile(filepath) > 0)
  CALL echo("Found File")
 ELSE
  CALL echo("Did not find the file, will exit")
  GO TO exit_code
 ENDIF
 FREE RECORD temp
 RECORD temp(
   1 cnt = i4
   1 qual[*]
     2 line = vc
     2 phyid = vc
     2 name = vc
     2 orgid = vc
     2 matchind = i2
 )
 DECLARE name = vc
 DECLARE fax = vc
 DECLARE id = vc
 FREE DEFINE rtl
 DEFINE rtl filepath
 SELECT INTO "nl:"
  FROM rtlt r
  HEAD REPORT
   cnt = 0
  DETAIL
   IF (trim(r.line,3) > " ")
    cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].line = trim(r.line,3),
    temp->qual[cnt].phyid = trim(r.line), temp->cnt = (temp->cnt+ 1)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = temp->cnt),
   prsnl pr,
   prsnl_alias pa
  PLAN (d)
   JOIN (pa
   WHERE pa.person_id=cnvtreal(temp->qual[d.seq].phyid)
    AND pa.prsnl_alias_type_cd=1088
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate)
   JOIN (pr
   WHERE pr.person_id=pa.person_id)
  DETAIL
   temp->qual[d.seq].name = pr.name_full_formatted, temp->qual[d.seq].orgid = pa.alias
  WITH nocounter
 ;end select
#exit_script
 DECLARE line = vc
 SELECT INTO "bhscust:physlist.csv"
  FROM dummyt d
  HEAD REPORT
   line = " ", line = concat("Name",char(9),"External ID"), col 0,
   line, row + 1
  DETAIL
   FOR (x = 1 TO temp->cnt)
     line = " ", line = concat(temp->qual[x].name,char(9),temp->qual[x].orgid), col 0,
     line, row + 1
   ENDFOR
  WITH maxcol = 10000, formfeed = none, maxrow = 1,
   format = variable
 ;end select
END GO
