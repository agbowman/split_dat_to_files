CREATE PROGRAM bhs_copd_icd9_list:dba
 FREE DEFINE rtl
 DEFINE rtl "bhscust:copd_list.txt"
 SET 2006_cnt = 0
 SET 2007_cnt = 0
 SET 2008_cnt = 0
 SET 2005_cnt = 0
 SET 2009_cnt = 0
 DECLARE str = vc WITH noconstant(" ")
 DECLARE notfnd = vc WITH constant("<not_found>")
 DECLARE num = i4 WITH noconstant(1)
 DECLARE data = vc
 FREE RECORD temp
 RECORD temp(
   1 cnt = i2
   1 qual[*]
     2 line = vc
     2 lastname = vc
     2 firstname = vc
     2 dob = vc
     2 acct = vc
     2 mrn = vc
     2 reg_date = vc
     2 disch_date = cv
     2 encounterid = f8
     2 personid = f8
 )
 SELECT INTO "nl:"
  FROM rtlt r
  WHERE r.line > " "
  DETAIL
   temp->cnt = (temp->cnt+ 1), stat = alterlist(temp->qual,temp->cnt), temp->qual[temp->cnt].line =
   trim(r.line,3),
   temp->qual[temp->cnt].acct = cnvtstring(cnvtint(r.line))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(temp->cnt)),
   encntr_alias ea,
   encounter e
  PLAN (d)
   JOIN (ea
   WHERE (ea.alias=temp->qual[d.seq].acct)
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=1077)
   JOIN (e
   WHERE e.encntr_id=ea.encntr_id)
  ORDER BY d.seq
  HEAD d.seq
   temp->qual[d.seq].encounterid = ea.encntr_id, temp->qual[d.seq].personid = e.person_id, temp->
   qual[d.seq].disch_date = format(e.disch_dt_tm,"mm/dd/yyyy hh:mm ;;d"),
   temp->qual[d.seq].reg_date =
   IF (e.reg_dt_tm BETWEEN cnvtdatetime(cnvtdate(01012006),0) AND cnvtdatetime(cnvtdate(12312008),
    235959)) format(e.reg_dt_tm,"mm/dd/yyyy hh:mm ;;d")
   ELSE format(e.disch_dt_tm,"mm/dd/yyyy hh:mm ;;d")
   ENDIF
  FOOT REPORT
   2006_cnt = count(e.encntr_id
    WHERE e.reg_dt_tm BETWEEN cnvtdatetime(cnvtdate(01012006),0) AND cnvtdatetime(cnvtdate(12312006),
     235959)), 2007_cnt = count(e.encntr_id
    WHERE e.reg_dt_tm BETWEEN cnvtdatetime(cnvtdate(01012007),0) AND cnvtdatetime(cnvtdate(12312007),
     235959)), 2008_cnt = count(e.encntr_id
    WHERE e.reg_dt_tm BETWEEN cnvtdatetime(cnvtdate(01012008),0) AND cnvtdatetime(cnvtdate(12312008),
     235959)),
   2005_cnt = count(e.encntr_id
    WHERE e.disch_dt_tm < cnvtdatetime(cnvtdate(01012006),0)), 2009_cnt = count(e.encntr_id
    WHERE e.disch_dt_tm < cnvtdatetime(cnvtdate(01012006),0))
  WITH nocounter
 ;end select
 CALL echo(build("2005:",2005_cnt))
 CALL echo(build("2006:",2006_cnt))
 CALL echo(build("2007:",2007_cnt))
 CALL echo(build("2008:",2008_cnt))
 CALL echo(build("2009:",2009_cnt))
 SELECT INTO "new_copd.csv"
  pid = substring(1,20,cnvtstring(temp->qual[d.seq].personid)), eid = substring(1,20,cnvtstring(temp
    ->qual[d.seq].encounterid)), acct = substring(1,20,temp->qual[d.seq].acct),
  start_date = substring(1,20,temp->qual[d.seq].reg_date), disch_date = substring(1,20,temp->qual[d
   .seq].disch_date)
  FROM (dummyt d  WITH seq = value(temp->cnt))
  PLAN (d
   WHERE d.seq > 0)
  WITH nocounter
 ;end select
END GO
