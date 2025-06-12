CREATE PROGRAM bhs_sys_fix_encounters:dba
 SET filepath = "bhscust:no_discharge_date2.csv"
 IF (findfile(filepath) > 0)
  CALL echo("find file")
 ENDIF
 FREE RECORD temp
 RECORD temp(
   1 cnt = i4
   1 qual[*]
     2 line = vc
     2 fin = vc
     2 date = vc
     2 encntrid = f8
     2 enddate = dq8
 )
 FREE DEFINE rtl
 DEFINE rtl filepath
 SELECT DISTINCT INTO "nl:"
  FROM rtlt r
  WHERE r.line > " "
  ORDER BY r.line
  DETAIL
   temp->cnt = (temp->cnt+ 1), stat = alterlist(temp->qual,temp->cnt), temp->qual[temp->cnt].line =
   build(trim(r.line,3),char(13)),
   temp->qual[temp->cnt].fin = piece(temp->qual[temp->cnt].line,",",1,"1",0), temp->qual[temp->cnt].
   date = piece(temp->qual[temp->cnt].line,",",2,"1",0)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encntr_alias ea,
   encounter e,
   (dummyt d  WITH seq = value(temp->cnt))
  PLAN (d)
   JOIN (ea
   WHERE (ea.alias=temp->qual[d.seq].fin)
    AND ea.encntr_alias_type_cd=1077
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate)
   JOIN (e
   WHERE e.encntr_id=ea.encntr_id)
  DETAIL
   temp->qual[d.seq].encntrid = ea.encntr_id, temp->qual[d.seq].enddate = e.reg_dt_tm
  WITH nocounter
 ;end select
 DECLARE year = c4
 DECLARE month = c2
 DECLARE day = c2
 FOR (x = 1 TO temp->cnt)
  IF ((temp->qual[x].encntrid > 0))
   UPDATE  FROM encntr_domain ed
    SET ed.end_effective_dt_tm = cnvtdatetime(temp->qual[x].enddate), ed.beg_effective_dt_tm =
     cnvtdatetime(temp->qual[x].enddate)
    WHERE (ed.encntr_id=temp->qual[x].encntrid)
   ;end update
   UPDATE  FROM encounter e
    SET e.disch_dt_tm = cnvtdatetime(temp->qual[x].enddate)
    WHERE (e.encntr_id=temp->qual[x].encntrid)
   ;end update
  ENDIF
  COMMIT
 ENDFOR
 CALL echo(build("currrqual:",curqual))
 CALL echorecord(temp)
END GO
