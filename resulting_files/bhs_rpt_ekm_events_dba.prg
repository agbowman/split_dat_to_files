CREATE PROGRAM bhs_rpt_ekm_events:dba
 PROMPT
  "OUTPUT TO FILE/PRINTER/MINE (MINE): " = "MINE",
  "DISPLAY BY (E)VENT, (M)ODULE, OR (B)OTH (E):" = "E",
  "ENTER MODULE NAME:" = "*",
  "VALIDATION TYPE (PRODUCTION), TESTING, EXAMPLE, RESEARCH, ALL:" = "PRODUCTION"
  WITH outputtype, displaytype, modulename,
  valtype
 SET char_temp = char(3)
 SET char_event = char(4)
 SET char_actgroup = char(5)
 SET slot_evoke = 7
 SET slot_logic = 2
 SET slot_logic_free = 81
 SET slot_action = 9
 SET slot_info = 1
 SET slot_action_free = 91
 DECLARE servernumber = vc
 SET loop1cnt = 1
 SET loop2cnt = 1
 DECLARE inbuffer = vc
 DECLARE inbuflen = i4
 DECLARE outbuffer = c1000 WITH noconstant("")
 DECLARE outbuflen = i4 WITH noconstant(1000)
 DECLARE retbuflen = i4 WITH noconstant(0)
 DECLARE bflag = i4 WITH noconstant(0)
 RECORD rec(
   1 qual[*]
     2 module_name = c30
     2 module_validation = c12
     2 module_author = vc
     2 module_dur_begin_dt_tm = dq8
     2 module_dur_end_dt_tm = dq8
     2 module_purpose = vc
     2 module_evoke = vc
     2 module_logic = vc
     2 module_action = vc
     2 qual2[*]
       3 event_name = vc
       3 server_class = vc
     2 rqual[*]
       3 request_number = f8
   1 qual3[*]
     2 event_name = vc
   1 qual4[*]
     2 unused_request_number = f8
 )
 SET max_events = 0
 SET rmode = cnvtupper(substring(1,1, $2))
 IF ( NOT (rmode IN ("E", "M", "B")))
  CALL echo("ENTER  (E)VENT, (M)ODULE, OR (B)OTH FOR DISPLAY TYPE")
  GO TO exit_report
 ENDIF
 IF ( NOT (( $3 IN ("", " "))))
  SET mname = cnvtupper( $3)
 ELSE
  SET mname = "*"
 ENDIF
 IF (findstring("ALL",cnvtupper( $4)))
  SET vtype = "*"
 ELSE
  SET vtype = cnvtupper( $4)
 ENDIF
 SELECT INTO "NL:"
  m.module_name, s.data_type, s.data_seq,
  s.ekm_info, tlen = textlen(s.ekm_info), m.maint_validation,
  m.maint_author, m.maint_dur_begin_dt_tm, m.maint_dur_end_dt_tm
  FROM eks_module m,
   eks_modulestorage s,
   eks_modulestorage s2,
   eks_modulestorage s3,
   eks_modulestorage s4,
   dprotect d
  PLAN (d
   WHERE d.object="E"
    AND d.group=0
    AND ((d.object_name=patstring(mname)) OR (mname="\*")) )
   JOIN (m
   WHERE m.maint_validation=patstring(vtype)
    AND m.active_flag="A"
    AND m.maint_dur_begin_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cnvtdatetime(curdate,curtime3) <= m.maint_dur_end_dt_tm
    AND d.object_name=m.module_name)
   JOIN (s
   WHERE m.module_name=s.module_name
    AND m.version=s.version
    AND s.data_type=slot_evoke)
   JOIN (s2
   WHERE outerjoin(m.module_name)=s2.module_name
    AND outerjoin(m.version)=s2.version
    AND s2.data_type=outerjoin(slot_info))
   JOIN (s3
   WHERE outerjoin(m.module_name)=s3.module_name
    AND outerjoin(m.version)=s3.version
    AND s3.data_type=outerjoin(slot_logic))
   JOIN (s4
   WHERE outerjoin(m.module_name)=s4.module_name
    AND outerjoin(m.version)=s4.version
    AND s4.data_type=outerjoin(slot_action))
  ORDER BY m.module_name, s.data_type, s.data_seq
  HEAD REPORT
   name = fillstring(31," "), cnt = 0, cnt3 = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(rec->qual,cnt), rec->qual[cnt].module_name = m.module_name,
   rec->qual[cnt].module_validation = m.maint_validation, rec->qual[cnt].module_author = m
   .maint_author, rec->qual[cnt].module_dur_begin_dt_tm = m.maint_dur_begin_dt_tm,
   rec->qual[cnt].module_dur_end_dt_tm = m.maint_dur_end_dt_tm, inbuffer = "", outbuffer = "",
   inbuffer = trim(s2.ekm_info,1), inbuflen = size(inbuffer),
   CALL uar_rtf(inbuffer,inbuflen,outbuffer,outbuflen,retbuflen,0),
   rec->qual[cnt].module_purpose = trim(outbuffer,1), rec->qual[cnt].module_evoke = build(s.ekm_info),
   inbuffer = "",
   outbuffer = "", inbuffer = trim(s3.ekm_info,1), inbuflen = size(inbuffer),
   CALL uar_rtf(inbuffer,inbuflen,outbuffer,outbuflen,retbuflen,0), rec->qual[cnt].module_logic =
   trim(outbuffer,1), rec->qual[cnt].module_action = build(s4.ekm_info),
   cnt2 = 0, pos1 = 1, pos2 = 1
   WHILE (pos2)
    pos2 = findstring(char_event,s.ekm_info,pos1),
    IF (pos2)
     event_name = substring(pos1,(pos2 - pos1),s.ekm_info), cnt2 = (cnt2+ 1), stat = alterlist(rec->
      qual[cnt].qual2,cnt2),
     rec->qual[cnt].qual2[cnt2].event_name = event_name, pos2 = findstring(char_event,s.ekm_info,(
      pos2+ 1)), pos1 = (pos2+ 1),
     fnd = 0, num = 1
     WHILE (num <= cnt3
      AND fnd=0)
      IF ((rec->qual3[num].event_name=event_name))
       fnd = 1
      ENDIF
      ,num = (num+ 1)
     ENDWHILE
     IF (fnd=0)
      cnt3 = (cnt3+ 1), stat = alterlist(rec->qual3,cnt3), rec->qual3[cnt3].event_name = event_name
     ENDIF
    ENDIF
   ENDWHILE
   max_events = maxval(cnt2,max_events)
  WITH counter, memsort
 ;end select
 SELECT
  ee.event_name, es.server_class
  FROM eks_event ee,
   eks_server es,
   eks_request er
  PLAN (ee
   WHERE ee.event_name > " "
    AND ee.event_number > 0)
   JOIN (es
   WHERE ee.event_priority >= es.priority_begin
    AND ee.event_priority <= es.priority_end)
   JOIN (er
   WHERE ee.event_number=er.event_number
    AND es.server_type=er.server_type)
  ORDER BY ee.event_name
  DETAIL
   loop1cnt = 1, loop2cnt = 1, fnd = 0
   WHILE (loop1cnt <= value(size(rec->qual,5)))
     WHILE (loop2cnt <= value(size(rec->qual[loop1cnt].qual2,5)))
      IF (fnd=0)
       IF (cnvtupper(trim(ee.event_name))=cnvtupper(trim(rec->qual[loop1cnt].qual2[loop2cnt].
         event_name)))
        IF (trim(es.server_class)="EKS_ASYNCH_01")
         servernumber = "150"
        ELSEIF (trim(es.server_class)="EKS_ASYNCH_02")
         servernumber = "151"
        ELSEIF (trim(es.server_class)="EKS_ASYNCH_03")
         servernumber = "152"
        ELSEIF (trim(es.server_class)="CPM.EKS")
         servernumber = "175"
        ELSE
         servernumber = " "
        ENDIF
        rec->qual[loop1cnt].qual2[loop2cnt].server_class = concat("(SERVER ",servernumber,": ",trim(
          es.server_class),")"), fnd = 1
       ENDIF
      ENDIF
      ,loop2cnt = (loop2cnt+ 1)
     ENDWHILE
     fnd = 0, loop1cnt = (loop1cnt+ 1), loop2cnt = 1
   ENDWHILE
  WITH counter
 ;end select
 SELECT INTO  $1
  event_name = substring(1,25,rec->qual[d.seq].qual2[d2.seq].event_name), module_name = rec->qual[d
  .seq].module_name, module_validation = rec->qual[d.seq].module_validation,
  module_author = substring(1,30,rec->qual[d.seq].module_author), module_dur_begin_dt_tm = format(rec
   ->qual[d.seq].module_dur_begin_dt_tm,"MM/DD/YYYY;;D"), module_dur_end_dt_tm = format(rec->qual[d
   .seq].module_dur_end_dt_tm,"MM/DD/YYYY;;D"),
  server_class = substring(1,30,rec->qual[d.seq].qual2[d2.seq].server_class), purpose = rec->qual[d
  .seq].module_purpose, logic = rec->qual[d.seq].module_logic
  FROM (dummyt d  WITH seq = value(size(rec->qual,5))),
   (dummyt d2  WITH seq = value(max_events))
  PLAN (d)
   JOIN (d2
   WHERE d2.seq <= size(rec->qual[d.seq].qual2,5))
  ORDER BY event_name, module_name
  WITH nocounter, outerjoin = d, format,
   separator = " "
 ;end select
#exit_report
END GO
