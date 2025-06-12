CREATE PROGRAM bhs_eks_monitor:dba
 PROMPT
  "Output to File/Printer/MINE (mine): " = mine,
  "Starting Date, mmddyy (today): " = curdate,
  "Starting Time, hhmm (now-30): " = curtime,
  "Ending Date, mmddyy (today): " = curdate,
  "Ending Time, hhmm (now): " = curtime,
  "Module Name, pattern match OK (all): " = "*",
  "Template Details, (y): " = "Y",
  "Server_class or another column on the audit table (*): " = "*",
  "Person_id or another column on detail table (*): " = "*"
 DECLARE eks_monitor_check_date_sub(date_param) = c6
 FREE SET date_val
 DECLARE startdate = c8
 DECLARE enddate = c8
 SET date_val =  $2
 SET startdate = eks_monitor_check_date_sub(date_val)
 IF (( $3=curtime))
  SET starttime = format(cnvttime((cnvtmin(curtime) - 30)),"####;")
 ELSE
  SET starttime =  $3
 ENDIF
 FREE SET date_val
 SET date_val =  $4
 SET enddate = eks_monitor_check_date_sub(date_val)
 IF (( $5=curtime))
  SET endtime = format(curtime,"####;")
 ELSE
  SET endtime =  $5
 ENDIF
 IF (curenv=0)
  SET message = noinformation
 ENDIF
 SET return_limit = 50
 SET template_len = 3
 SET template_failed_ind = - (1)
 SET template_false_ind = 0
 SET template_true_ind = 100
 SET template_notrun = 2
 SELECT INTO "nl:"
  l.len
  FROM dtable t,
   dtableattr a,
   dtableattrl l
  PLAN (t
   WHERE t.table_name="EKS_MODULE_AUDIT")
   JOIN (a
   WHERE t.table_name=a.table_name)
   JOIN (l
   WHERE l.structtype != "K"
    AND btest(l.stat,11)=0
    AND l.attr_name="LOGIC_RETURN")
  DETAIL
   return_limit = l.len
  WITH nocounter
 ;end select
 SET task_assay_ind = 0
 SELECT INTO "nl:"
  l.len
  FROM dtable t,
   dtableattr a,
   dtableattrl l
  PLAN (t
   WHERE t.table_name="EKS_MODULE_AUDIT_DET")
   JOIN (a
   WHERE t.table_name=a.table_name)
   JOIN (l
   WHERE l.structtype != "K"
    AND btest(l.stat,11)=0
    AND l.attr_name="TASK_ASSAY_CD")
  DETAIL
   task_assay_ind = 1
  WITH nocounter
 ;end select
 SET mnull = fillstring(30,char(0))
 IF (findstring("*", $6)=0)
  IF (cnvtupper( $6)="ALL")
   SET mod_name = cnvtupper( $6)
  ELSE
   SET mod_name = cnvtupper( $6)
   SET stat = movestring(mod_name,1,mnull,1,size(mod_name))
   FREE SET mod_name
   SET mod_name = mnull
  ENDIF
 ELSE
  SET mod_name = cnvtupper( $6)
 ENDIF
 SET show_templates = cnvtupper( $7)
 IF (show_templates != "N")
  FREE SET show_templates
  SET show_templates = "Y"
 ENDIF
 SET mname = fillstring(31," ")
 RECORD temprec(
   1 buf = vc
   1 buf1 = vc
   1 buf2 = vc
   1 buf3 = vc
 )
 RECORD trptrec(
   1 buf1 = vc
   1 qual[*]
     2 buf = vc
     2 type = c10
 )
 RECORD stemprec(
   1 buf = vc
   1 buf2 = vc
 )
 SET server_class = cnvtupper( $8)
 SET temprec->buf = "1 = 1"
 IF (cnvtint(server_class) > 0)
  FREE SET temp
  SET temp = concat("EKS_ASYNCH_",format(cnvtint(server_class),"##;LP0"))
  FREE SET server_class
  SET server_class = temp
  SET temprec->buf = concat("e.server_class = patstring(^",trim(server_class,3),"^)")
 ELSEIF (((findstring("=",server_class)) OR (findstring("IN(",server_class))) )
  SET temprec->buf = trim(server_class)
 ELSEIF (size(server_class) > 1)
  SET temprec->buf = concat("e.server_class = patstring(^",trim(server_class,3),"^)")
 ENDIF
 IF (trim(temprec->buf,3) != "1 = 1"
  AND cnvtupper(substring(1,2,trim(temprec->buf,3))) != "E.")
  SET temprec->buf = concat(" e.",trim(temprec->buf,3)," ")
 ENDIF
 SET search_version = cnvtupper( $9)
 SET search_type = "EKM"
 SET temprec->buf1 = "1 = 1"
 SET temprec->buf3 = "1 = 1"
 IF (size(cnvtalphanum(search_version)) > 1)
  IF (findstring("=",search_version))
   FREE SET search_type
   SET search_type = trim(substring(1,(findstring("=",search_version) - 1),search_version))
   SET search_value = trim(substring((findstring("=",search_version)+ 1),999,search_version))
   SET temprec->buf1 = search_version
  ELSEIF (findstring("IN(",search_version))
   SET search_type = trim(substring(1,(findstring("IN(",search_version) - 1),search_version))
   SET search_value = trim(substring(findstring("IN(",search_version),999,search_version))
   IF (size(trim(search_type))=0)
    FREE SET search_type
    SET search_type = "PERSON_ID"
   ENDIF
   SET temprec->buf1 = search_version
  ELSE
   SET search_type = "PERSON_ID"
   SET temprec->buf1 = concat("ed1.person_id = ",search_version)
  ENDIF
  IF (trim(temprec->buf1,3) != "1 = 1"
   AND cnvtupper(substring(1,4,trim(temprec->buf1,3))) != "ED1.")
   SET temprec->buf1 = concat(" ed1.",trim(temprec->buf1,3)," ")
  ENDIF
  IF (((mod_name="ALL") OR (ichar(mod_name)=42)) )
   SET temprec->buf3 = "1 = 1"
  ELSE
   SET temprec->buf3 = "E.MODULE_NAME in (patstring(mod_name),value(mod_name))"
  ENDIF
 ENDIF
 IF (trim(temprec->buf,3)="1 = 1")
  IF (trim(temprec->buf,3)="1 = 1")
   SET temprec->buf3 = ""
  ELSE
   SET temprec->buf = temprec->buf3
   SET temprec->buf3 = ""
  ENDIF
 ELSEIF (trim(temprec->buf3,3) != "1 = 1")
  SET temprec->buf = concat(trim(temprec->buf)," and ",trim(temprec->buf3,3))
  SET temprec->buf3 = ""
 ELSE
  SET temprec->buf3 = ""
 ENDIF
 SET pbuf_module = temprec->buf
 SET pbuf_module_det = temprec->buf1
 IF (curenv=0)
  SET message = information
 ENDIF
 SELECT
  IF (search_type="EKM")
   FROM dummyt d1,
    dprotect dp,
    eks_module_audit e,
    eks_module_audit_temp em,
    eks_module_audit_det ed,
    person p,
    accession a
   PLAN (e
    WHERE e.begin_dt_tm BETWEEN cnvtdatetime(cnvtdate2(startdate,"YYYYMMDD"),((cnvtmin(cnvtint(
       starttime)) * 60) * 100)) AND cnvtdatetime(cnvtdate2(enddate,"YYYYMMDD"),((cnvtmin(cnvtint(
       endtime)) * 60) * 100))
     AND ((e.module_name IN (patstring(mod_name), value(mod_name))) OR (mod_name="ALL"))
     AND parser(temprec->buf))
    JOIN (d1
    WHERE initarray(mname,check(e.module_name)))
    JOIN (dp
    WHERE "E"=dp.object
     AND e.module_name=dp.object_name)
    JOIN (em
    WHERE mname=em.module_name)
    JOIN (ed
    WHERE outerjoin(e.rec_id)=ed.module_audit_id
     AND outerjoin(em.template_num)=ed.template_number)
    JOIN (a
    WHERE outerjoin(ed.accession_id)=a.accession_id)
    JOIN (p
    WHERE outerjoin(ed.person_id)=p.person_id)
  ELSE
   FROM dummyt d1,
    dprotect dp,
    eks_module_audit e,
    eks_module_audit_temp em,
    eks_module_audit_det ed,
    eks_module_audit_det ed1,
    person p,
    accession a
   PLAN (ed1
    WHERE parser(temprec->buf1))
    JOIN (e
    WHERE e.rec_id=ed1.module_audit_id
     AND e.begin_dt_tm BETWEEN cnvtdatetime(cnvtdate2(startdate,"YYYYMMDD"),((cnvtmin(cnvtint(
       starttime)) * 60) * 100)) AND cnvtdatetime(cnvtdate2(enddate,"YYYYMMDD"),((cnvtmin(cnvtint(
       endtime)) * 60) * 100))
     AND parser(temprec->buf))
    JOIN (d1
    WHERE initarray(mname,check(e.module_name)))
    JOIN (dp
    WHERE "E"=dp.object
     AND e.module_name=dp.object_name)
    JOIN (em
    WHERE mname=em.module_name)
    JOIN (ed
    WHERE outerjoin(e.rec_id)=ed.module_audit_id
     AND outerjoin(em.template_num)=ed.template_number)
    JOIN (a
    WHERE outerjoin(ed.accession_id)=a.accession_id)
    JOIN (p
    WHERE outerjoin(ed.person_id)=p.person_id)
  ENDIF
  DISTINCT INTO  $1
  brk1 = concat(format(cnvtdatetime(e.begin_dt_tm),"YYYYMMDD HH:MM.SS;;D")," ",build(floor(e.rec_id)),
   " ",format(e.module_name,"##############################;R")), em.template_num, e.begin_dt_tm";;q",
  e.action_return, e.begin_dt_tm, e.conclude,
  e.logic_return, e.module_name, module_name_short = substring(1,30,e.module_name),
  e.rec_id, e.server_class, e.server_instance,
  e.server_number, em.module_name, tname = em.template_name,
  em.template_type, ed.*, request_number = e.request_number,
  e_begin_dt_tm = cnvtreal(e.begin_dt_tm), start_date_time = cnvtdatetime(cnvtdate2(startdate,
    "YYYYMMDD"),((cnvtmin(cnvtint(starttime)) * 60) * 100)), end_date_time = cnvtdatetime(cnvtdate2(
    enddate,"YYYYMMDD"),((cnvtmin(cnvtint(endtime)) * 60) * 100)),
  start_date_t = cnvtdatetime(cnvtdate2(startdate,"YYYYMMDD"),((cnvtmin(cnvtint(starttime)) * 60) *
   100))"mm/dd/yy hh:mm;;q", end_date_t = cnvtdatetime(cnvtdate2(enddate,"YYYYMMDD"),((cnvtmin(
    cnvtint(endtime)) * 60) * 100))"mm/dd/yy hh:mm;;q", expr3 = (datetimediff(e.end_dt_tm,e
   .begin_dt_tm) * 86400.00),
  dp_dt_tm = cnvtdatetime(concat(format(dp.datestamp,"dd-mmm-yyyy;;d")," ",format(dp.timestamp,
     "hh:mm:ss;2;m"))), dp_datestamp = dp.datestamp, dp_timestamp = dp.timestamp,
  begin_dt_tm = e.begin_dt_tm, name = decode(p.seq,substring(1,30,p.name_full_formatted),
   "                              "), person_id = decode(p.seq,p.person_id,0.0),
  accession = decode(a.seq,a.accession,fillstring(20," "))
  ORDER BY cnvtdatetime(e.begin_dt_tm) DESC, brk1 DESC, e.module_name,
   em.template_num
  WITH outerjoin = dp, outerjoin = d1, outerjoin = em,
   outerjoin = ed, outerjoin = a, outerjoin = p,
   dontcare = dp, memsort, nullreport
 ;end select
 SUBROUTINE set_ind_values(p_param)
  SET template_notrun = 2
  IF (cnvtint(tempfind) > 5)
   SET template_len = 1
   SET template_failed_ind = 7
   SET template_false_ind = 8
   SET template_true_ind = 9
  ELSE
   SET template_len = 3
   SET template_failed_ind = - (1)
   SET template_false_ind = 0
   SET template_true_ind = 100
  ENDIF
 END ;Subroutine
 SUBROUTINE setup_template_output1(xxxbogus)
   SET stat = alterlist(trptrec->qual,1)
   SET trptrec->qual[1].buf = line132
   SET curline = 1
   SET spos = 1
   SET trptrec->buf1 = format(e.begin_dt_tm,"mm/dd/yy hh:mm:ss;;q")
   SET stat = movestring(trptrec->buf1,1,trptrec->qual[curline].buf,spos,size(trim(trptrec->buf1)))
   SET spos = 21
   SET stat = movestring(module_name_short,1,trptrec->qual[curline].buf,spos,size(trim(
      module_name_short)))
   IF (show_templates="Y")
    SET spos = 46
    SET trptrec->buf1 = concat("(",format(e.conclude,"#"),")")
    SET stat = movestring(trptrec->buf1,1,trptrec->qual[curline].buf,spos,size(trim(trptrec->buf1)))
    SET spos = 84
    SET trptrec->buf1 = concat(format(e.server_class,"#############")," ",format(e.server_number,
      "#####")," ",format(e.server_instance,"####"),
     " Elapsed:")
    IF (expr3 > 9999)
     SET trptrec->buf1 = concat(trim(trptrec->buf1),">9999")
    ELSE
     SET trptrec->buf1 = concat(trim(trptrec->buf1)," ",format(expr3,"####;L"))
    ENDIF
    SET stat = movestring(trptrec->buf1,1,trptrec->qual[curline].buf,spos,size(trim(trptrec->buf1)))
   ENDIF
   SET mod_name_flag = 1
   SET stat = alterlist(trptrec->qual,2)
   SET trptrec->qual[2].buf = line132
   SET lastline = 3
 END ;Subroutine
 SUBROUTINE setup_template_output2(xxxbogus)
   IF (show_templates="Y"
    AND dud=0)
    SET first_temp = (first_temp+ 1)
    IF (first_temp=1)
     SET stat = alterlist(trptrec->qual,lastline)
     SET trptrec->qual[lastline].buf = line132
    ENDIF
    SET spos = 0
    IF (last_temp != em.template_type)
     SET tnum = 0
     SET last_temp = em.template_type
     SET lcnt = 1
    ENDIF
    IF (em.template_name > " ")
     SET stat = 1
     CALL setup_template_output4(stat)
     IF (em.template_type != "E")
      IF (validate(lastline,0)=0
       AND validate(lastline,1)=1)
       SET lastline = 3
      ELSEIF (lastline=0)
       SET lastline = 3
      ELSE
       SET lastline = (lastline+ 1)
      ENDIF
      SET curline = lastline
      SET stat = alterlist(trptrec->qual,curline)
      SET trptrec->qual[curline].buf = line132
      SET spos = templatecol
      CASE (em.template_type)
       OF "E":
        SET trptrec->buf1 = " Evoke ("
        SET stat = movestring(trptrec->buf1,1,trptrec->qual[curline].buf,spos,size(trim(trptrec->buf1
           )))
        SET res = 100
       OF "L":
        IF ((lcnt <= ((return_limit - template_len)+ 1)))
         SET trptrec->buf1 = " Logic ("
         SET stat = movestring(trptrec->buf1,1,trptrec->qual[curline].buf,spos,size(trim(trptrec->
            buf1)))
         SET res = cnvtint(substring(lcnt,template_len,e.logic_return))
        ELSE
         SET res = 999
        ENDIF
       OF "A":
        SET trptrec->buf1 = " Action ("
        SET stat = movestring(trptrec->buf1,1,trptrec->qual[curline].buf,spos,size(trim(trptrec->buf1
           )))
        SET tempfind = substring(1,1,e.action_return)
        CALL set_ind_values(tempfind)
        IF ((lcnt <= ((return_limit - template_len)+ 1)))
         SET res = cnvtint(substring(lcnt,template_len,e.action_return))
        ELSE
         SET res = 999
        ENDIF
      ENDCASE
      SET tnum = (tnum+ 1)
      SET snum = concat(trim(cnvtstring(tnum)),")")
      SET spos = (size(trptrec->buf1)+ templatecol)
      SET trptrec->buf1 = snum
      SET stat = movestring(trptrec->buf1,1,trptrec->qual[curline].buf,spos,size(trim(trptrec->buf1))
       )
      SET spos = 24
      SET trptrec->buf1 = em.template_name
      SET stat = movestring(trptrec->buf1,1,trptrec->qual[curline].buf,spos,size(trim(trptrec->buf1))
       )
      SET spos = 53
      IF (res=template_false_ind)
       SET trptrec->buf1 = "False"
      ELSEIF (res=template_true_ind)
       SET trptrec->buf1 = "True"
      ELSEIF (res=template_notrun)
       SET trptrec->buf1 = "NotRun"
      ELSEIF (res=template_failed_ind)
       SET trptrec->buf1 = "Failed"
       SET dud = 1
      ELSEIF (res=99)
       SET trptrec->buf1 = " "
      ELSEIF (res=999)
       SET trptrec->buf1 = "Unknown"
      ELSE
       SET trptrec->buf1 = format(res,"###")
      ENDIF
      SET stat = movestring(trptrec->buf1,1,trptrec->qual[curline].buf,spos,size(trim(trptrec->buf1))
       )
      SET spos = 61
      SET trptrec->buf1 = format(ed.person_id,"##########")
      SET stat = movestring(trptrec->buf1,1,trptrec->qual[curline].buf,spos,size(trim(trptrec->buf1))
       )
      SET spos = 73
      SET trptrec->buf1 = format(ed.encntr_id,"##########")
      SET stat = movestring(trptrec->buf1,1,trptrec->qual[curline].buf,spos,size(trim(trptrec->buf1))
       )
      SET spos = 85
      SET trptrec->buf1 = format(ed.order_id,"##########")
      SET stat = movestring(trptrec->buf1,1,trptrec->qual[curline].buf,spos,size(trim(trptrec->buf1))
       )
      SET spos = 97
      IF ( NOT (task_assay_ind))
       SET trptrec->buf1 = format(ed.accession_id,"##########")
      ELSE
       SET trptrec->buf1 = format(ed.task_assay_cd,"##########")
      ENDIF
      SET stat = movestring(trptrec->buf1,1,trptrec->qual[curline].buf,spos,size(trim(trptrec->buf1))
       )
      IF (trim(accession) > ""
       AND ((last_accession_id=0) OR (last_accession_id != ed.accession_id)) )
       SET lastline = (lastline+ 1)
       SET curline = lastline
       SET stat = alterlist(trptrec->qual,curline)
       SET trptrec->qual[curline].buf = line132
       SET spos = 53
       SET trptrec->buf1 = build(uar_fmt_accession(accession,size(accession,1)))
       IF (trim(trptrec->buf1)="")
        SET trptrec->buf1 = accession
       ENDIF
       SET trptrec->buf1 = concat("Accession: ",trptrec->buf1)
       IF (task_assay_ind)
        SET trptrec->buf1 = concat(trptrec->buf1," accession_id: ",trim(format(ed.accession_id,
           "##########;L")))
       ENDIF
       SET stat = movestring(trptrec->buf1,1,trptrec->qual[curline].buf,spos,size(trim(trptrec->buf1)
         ))
       SET last_accession_id = ed.accession_id
      ENDIF
      IF (ed.logging > " ")
       SET tcpos = 1
       SET tlpos = 0
       SET char_val = 0
       SET line_len = 110
       SET temprec->buf = trim(ed.logging)
       WHILE (tcpos > 0)
         SET temprec->buf2 = substring(tcpos,line_len,temprec->buf)
         SET tlpos = size(trim(temprec->buf2))
         IF (tlpos < line_len)
          SET tcpos = (tcpos+ line_len)
          SET tlpos = 0
         ELSE
          IF (findstring(substring(tlpos,1,temprec->buf2),":;,.!?-"))
           SET tcpos = (tcpos+ tlpos)
          ELSE
           SET adjval = 5
           SET adjincr = 5
           WHILE (adjval > 0)
            SET char_val = findstring(" ",temprec->buf2,(tlpos - adjval))
            IF (char_val)
             SET tlpos = char_val
             SET temprec->buf2 = substring(1,tlpos,temprec->buf2)
             SET tcpos = (tcpos+ tlpos)
             SET adjval = 0
            ELSE
             SET adjval = (adjval+ adjincr)
             IF (adjval > size(trim(temprec->buf2)))
              SET adjval = 0
              SET tcpos = (tcpos+ line_len)
             ENDIF
            ENDIF
           ENDWHILE
          ENDIF
         ENDIF
         SET temprec->buf2 = trim(temprec->buf2,3)
         SET lastline = (lastline+ 1)
         SET curline = lastline
         SET stat = alterlist(trptrec->qual,curline)
         SET trptrec->qual[curline].buf = line132
         SET spos = 9
         SET trptrec->buf1 = temprec->buf2
         SET stat = movestring(trptrec->buf1,1,trptrec->qual[curline].buf,spos,size(trim(trptrec->
            buf1)))
         IF (tcpos >= size(temprec->buf))
          SET tcpos = 0
         ENDIF
       ENDWHILE
      ENDIF
     ENDIF
    ENDIF
    SET lcnt = (lcnt+ template_len)
   ENDIF
 END ;Subroutine
 SUBROUTINE setup_template_output3(xxxbogus)
   SET curline = lastline
   SET stat = alterlist(trptrec->qual,curline)
   SET trptrec->qual[curline].buf = line132
   IF (template_len=3)
    SET ret = "   "
   ELSE
    SET ret = " "
   ENDIF
   CALL setup_template_output4(stat)
   IF (logic_action_flag=0)
    SET logic_action_flag = 1
    IF (e.conclude > 0)
     FOR (xxxi = 1 TO 2)
       IF (xxxi=1)
        SET stemprec->buf = "Logic:"
        SET stemprec->buf2 = e.logic_return
       ELSEIF (xxxi=2)
        SET stemprec->buf = "Action:"
        SET stemprec->buf2 = e.action_return
        SET curline = (curline+ 1)
        SET stat = alterlist(trptrec->qual,curline)
        SET trptrec->qual[curline].buf = line132
       ENDIF
       CALL echo(concat("Mname:",trim(e.module_name)," activity:'",stemprec->buf,"'"),1,0)
       SET trptrec->buf1 = stemprec->buf
       SET spos = name_col
       SET stat = movestring(trptrec->buf1,1,trptrec->qual[curline].buf,spos,size(trim(trptrec->buf1)
         ))
       SET strt = 1
       SET ret = substring(value(strt),value(template_len),stemprec->buf2)
       SET spos = (name_col+ 8)
       WHILE ( NOT (trim(ret)="")
        AND strt <= return_limit)
         IF (cnvtint(ret)=template_false_ind)
          SET pass_fail = "F"
         ELSEIF (cnvtint(ret)=template_true_ind)
          SET pass_fail = "T"
         ELSEIF (cnvtint(ret)=template_failed_ind)
          SET pass_fail = "!"
          SET dud = 1
         ELSEIF (cnvtint(ret)=template_notrun)
          SET pass_fail = "N"
         ELSE
          SET pass_fail = cnvtalphanum(ret)
         ENDIF
         SET spos = (spos+ 3)
         IF (spos > 120)
          SET spos = ((name_col+ 8)+ 3)
          SET curline = (curline+ 1)
          SET stat = alterlist(trptrec->qual,curline)
          SET trptrec->qual[curline].buf = line132
         ENDIF
         IF (pass_fail != "!")
          SET trptrec->buf1 = pass_fail
          IF (trim(trptrec->buf1) != "")
           SET stat = movestring(trptrec->buf1,1,trptrec->qual[curline].buf,spos,size(trim(trptrec->
              buf1)))
          ENDIF
         ELSE
          SET trptrec->buf1 = "Failed"
          SET stat = movestring(trptrec->buf1,1,trptrec->qual[curline].buf,spos,size(trim(trptrec->
             buf1)))
         ENDIF
         SET strt = (strt+ template_len)
         SET ret = substring(strt,template_len,stemprec->buf2)
         IF ((strt > (return_limit - 2)))
          SET strt = (return_limit+ 10)
          SET ret = "999"
         ENDIF
       ENDWHILE
       IF (dud)
        SET xxxi = 2
       ENDIF
     ENDFOR
    ELSE
     IF (dud=0)
      SET spos = name_col
      SET trptrec->buf1 = "Logic false"
      SET stat = movestring(trptrec->buf1,1,trptrec->qual[curline].buf,spos,size(trim(trptrec->buf1))
       )
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE setup_template_output4(xxxbogus2)
   IF (person_id > 0)
    IF (name_flag=0)
     SET curline = 1
     SET spos = name_col
     SET trptrec->buf1 = name
     SET stat = movestring(trptrec->buf1,1,trptrec->qual[curline].buf,spos,size(trim(trptrec->buf1)))
     SET name_flag = 1
     SET name_flag_personid = person_id
    ELSEIF (name_flag_personid != person_id)
     SET curline = 1
     SET spos = (name_col - 1)
     SET trptrec->buf1 = "*"
     SET stat = movestring(trptrec->buf1,1,trptrec->qual[curline].buf,spos,size(trim(trptrec->buf1)))
    ENDIF
   ENDIF
   IF (request_number_flag=0
    AND request_number > 0)
    SET curline = 2
    IF (curline > size(trptrec->qual,5))
     SET stat = alterlist(trptrec->qual,curline)
     SET trptrec->qual[curline].buf = line132
    ENDIF
    SET spos = 2
    SET trptrec->buf1 = concat("Triggering request number: ",build(floor(request_number)))
    SET stat = movestring(trptrec->buf1,1,trptrec->qual[curline].buf,spos,size(trim(trptrec->buf1)))
    SET request_number_flag = 1
   ENDIF
   IF (compile_dttm_flag=0)
    IF (dp_dt_tm > 0)
     IF (begin_dt_tm < cnvtdatetime(concat(format(dp.datestamp,"dd-mmm-yyyy;;d")," ",format(dp
        .timestamp,"hh:mm:ss;2;m"))))
      SET spos = 18
      SET stat = movestring("*",1,trptrec->qual[1].buf,spos,1)
      SET compile_dttm_flag = 1
     ELSE
      SET spos = 18
      SET stat = movestring(" ",1,trptrec->qual[1].buf,spos,1)
      SET compile_dttm_flag = 1
     ENDIF
    ELSE
     SET spos = 18
     SET stat = movestring("-",1,trptrec->qual[1].buf,spos,1)
    ENDIF
   ENDIF
 END ;Subroutine
#bottom
 SUBROUTINE eks_monitor_check_date_sub(param_date_val)
   SET temp = param_date_val
   DECLARE return_val = c8
   DECLARE day_val = i2
   DECLARE year_str = c4
   DECLARE datetype_flag = i2
   SET datetype_curdate = 1
   SET datetype_mmddyy = 0
   SET datetype_yyyymmdd = 2
   SET datetype_unknown = 3
   SET datetype_flag = datetype_unknown
   IF (cnvtint(temp) BETWEEN (curdate - 40) AND (curdate+ 40))
    SET datetype_flag = datetype_curdate
   ELSE
    IF (size(trim(cnvtstring(temp)))=8)
     SET datetype_flag = datetype_yyyymmdd
    ELSEIF (size(trim(cnvtstring(temp)))=6)
     SET datetype_flag = datetype_mmddyy
    ELSEIF (size(trim(cnvtstring(temp)))=5)
     SET datetype_flag = datetype_curdate
     SET day_val = cnvtint(substring(2,2,cnvtstring(temp)))
     SET year_val = cnvtint(substring(4,2,cnvtstring(temp)))
     IF (year_val > 50)
      SET year_str = build("19",year_val)
     ELSE
      SET year_str = build("20",format(year_val,"##;p0"))
     ENDIF
     IF (((cnvtint(substring(1,1,cnvtstring(temp))) IN (1, 3, 5, 7, 8)
      AND day_val <= 31) OR (cnvtint(substring(1,1,cnvtstring(temp))) IN (4, 6, 9)
      AND day_val <= 30)) )
      SET datetype_flag = datetype_mmddyy
     ELSEIF (cnvtint(substring(1,1,cnvtstring(temp)))=2)
      IF (((mod(cnvtint(year_str),4)=0
       AND mod(cnvtint(year_str),400)=0
       AND day_val <= 29) OR (day_val <= 28)) )
       SET datetype_flag = datetype_mmddyy
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (datetype_flag=datetype_curdate)
    SET return_val = format(temp,"yyyymmdd;;d")
   ELSEIF (datetype_flag=datetype_mmddyy)
    SET return_val = format(cnvtdate(temp),"yyyymmdd;;d")
   ELSEIF (datetype_flag=datetype_yyyymmdd)
    SET return_val = format(temp,"########;p0")
   ELSE
    CALL echo("Invalid value for startdate - defaulting to curdate",1,0)
    SET return_val = format(curdate,"yyyymmdd;;d")
   ENDIF
   RETURN(return_val)
 END ;Subroutine
END GO
