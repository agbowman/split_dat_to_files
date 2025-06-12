CREATE PROGRAM cn_updt_invld_evnt_cd:dba
 PROMPT
  "Enter the input file name (ident_invld_evnt_cd_log_<dttm>.csv):" = ""
  WITH logfile
 DECLARE notfnd = vc WITH constant("<not_found>")
 DECLARE logfilename = vc WITH noconstant(build("cer_temp:",build( $LOGFILE)))
 IF (findfile(trim(logfilename,3))=1)
  FREE DEFINE rtl2
  DEFINE rtl2 logfilename
  DECLARE stat_cnt = i4 WITH noconstant(0)
  DECLARE stat = i4 WITH noconstant(0)
  DECLARE batch = i4 WITH constant(200)
  DECLARE curend = i4 WITH noconstant(0)
  DECLARE num = i4 WITH noconstant(0)
  DECLARE mdoccount = i4 WITH noconstant(0)
  DECLARE doccount = i4 WITH noconstant(0)
  RECORD cn_event(
    1 cn_event[*]
      2 clinical_event_id = f8
      2 event_id = f8
  )
  SELECT INTO "nl:"
   FROM rtl2t r
   DETAIL
    IF (mod(stat_cnt,100)=0)
     stat = alterlist(cn_event->cn_event,(stat_cnt+ 100))
    ENDIF
    stat_cnt = (stat_cnt+ 1), cn_event->cn_event[stat_cnt].clinical_event_id = cnvtreal(piece(r.line,
      ",",1,"notfnd",0)), cn_event->cn_event[stat_cnt].event_id = cnvtreal(piece(r.line,",",2,
      "notfnd",0))
   FOOT REPORT
    stat = alterlist(cn_event->cn_event,stat_cnt)
   WITH nocounter
  ;end select
  FOR (curstart = 2 TO stat_cnt)
    SET curend = (curstart+ batch)
    IF (curend > stat_cnt)
     SET curend = stat_cnt
    ENDIF
    UPDATE  FROM clinical_event c
     SET c.event_cd =
      (SELECT
       n.event_cd
       FROM note_type n
       WHERE n.note_type_id=c.event_cd), c.updt_task = 128, c.updt_dt_tm = cnvtdatetime(curdate,
       curtime3)
     WHERE expand(num,curstart,curend,c.clinical_event_id,cn_event->cn_event[num].clinical_event_id)
      AND (c.event_cd=
     (SELECT
      n.note_type_id
      FROM note_type n
      WHERE n.note_type_id=c.event_cd))
    ;end update
    SET mdoccount = (mdoccount+ curqual) WITH nocounter
    UPDATE  FROM clinical_event c
     SET c.event_cd =
      (SELECT
       n.event_cd
       FROM note_type n
       WHERE n.note_type_id=c.event_cd), c.updt_task = 128, c.updt_dt_tm = cnvtdatetime(curdate,
       curtime3)
     WHERE expand(num,curstart,curend,c.parent_event_id,cn_event->cn_event[num].event_id)
      AND (c.event_cd=
     (SELECT
      n.note_type_id
      FROM note_type n
      WHERE n.note_type_id=c.event_cd))
    ;end update
    SET doccount = (doccount+ curqual) WITH nocounter
    SET curstart = (curend+ 1)
  ENDFOR
  COMMIT
 ENDIF
 CALL echo(build("Total number of affected  MDoc rows recovered :",mdoccount))
 CALL echo(build("Total number of affected  Doc rows recovered: ",doccount))
END GO
