CREATE PROGRAM bhs_sys_copd_medlist:dba
 DECLARE str = vc WITH noconstant(" ")
 DECLARE notfnd = vc WITH constant("<not_found>")
 DECLARE num = i4 WITH noconstant(1)
 DECLARE data1 = vc
 FREE DEFINE rtl
 DEFINE rtl "bhscust:query2.txt"
 FREE RECORD temp
 RECORD temp(
   1 cnt = i4
   1 qual[*]
     2 ostr = vc
     2 pid = vc
     2 eid = vc
     2 date = f8
     2 sex = c1
     2 etype = vc
 )
 FREE RECORD temp2
 RECORD temp2(
   1 cnt = i4
   1 qual[*]
     2 ostr = vc
     2 pid = f8
     2 eid = f8
     2 date = f8
     2 sex = c1
     2 etype = vc
     2 age = f8
 )
 SELECT INTO "nl:"
  data1 = replace(trim(r.line,3),'"&"',",",0)
  FROM rtlt r
  WHERE r.line > " "
  DETAIL
   temp->cnt = (temp->cnt+ 1), stat = alterlist(temp->qual,temp->cnt), temp->qual[temp->cnt].ostr =
   replace(trim(r.line,3),'"&"',",",0),
   CALL echo(data1)
  WITH nocounter
 ;end select
 FOR (x = 1 TO temp->cnt)
   SET data1 = temp->qual[x].ostr
   SET num = 1
   WHILE (str != notfnd
    AND num < 3)
     SET str = piece(data1,",",num,notfnd)
     SET num = (num+ 1)
     IF (str != "<not_found>")
      IF (num=2)
       SET temp->qual[x].pid = trim(str,4)
      ENDIF
      IF (num=3)
       SET temp->qual[x].eid = trim(str,4)
      ENDIF
     ENDIF
   ENDWHILE
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(temp->cnt)),
   encounter e,
   person p
  PLAN (d)
   JOIN (e
   WHERE e.encntr_id=cnvtreal(temp->qual[d.seq].eid)
    AND e.reg_dt_tm BETWEEN cnvtdatetime(cnvtdate(0101006),0) AND cnvtdatetime(cnvtdate(12312008),
    235959))
   JOIN (p
   WHERE p.person_id=e.person_id)
  DETAIL
   temp2->cnt = (temp2->cnt+ 1), stat = alterlist(temp2->qual,temp2->cnt), temp2->qual[temp2->cnt].
   eid = e.encntr_id,
   temp2->qual[temp2->cnt].pid = p.person_id, temp2->qual[temp2->cnt].date = e.reg_dt_tm, temp2->
   qual[temp2->cnt].etype = uar_get_code_display(e.encntr_type_class_cd),
   temp2->qual[temp2->cnt].sex = substring(1,1,uar_get_code_display(p.sex_cd)), temp2->qual[temp2->
   cnt].age = (datetimecmp(e.reg_dt_tm,p.birth_dt_tm)/ 365.25)
  WITH nocounter
 ;end select
 SELECT INTO "copdmedlist.csv"
  pid = temp2->qual[d.seq].pid, eid = temp2->qual[d.seq].eid, class = temp2->qual[d.seq].etype,
  date = format(temp2->qual[d.seq].date,"mm/dd/yyyy;;d"), sex = temp2->qual[d.seq].sex, age = temp2->
  qual[d.seq].age
  FROM (dummyt d  WITH seq = value(temp2->cnt))
  PLAN (d
   WHERE d.seq > 0)
  WITH nocounter, format, peparator = ","
 ;end select
END GO
