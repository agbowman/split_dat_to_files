CREATE PROGRAM bhs_ma_psych_disch_rpt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SUBROUTINE inserttabfromrtf(textin)
   SET pos1 = 0
   SET starttext = 0
   SET tablevel = 0
   SET tabval = 0
   SET containedtablevel = 0
   SET containedtabval = 0
   SET containedparagraph = 0
   SET exitcnt = 0
   SET endpos = 0
   SET textin = trim(textin)
   SET pos1 = (findstring("\par",textin,1) - 3)
   SET starttext = findstring(" ",textin,(pos1+ 4))
   CALL echo(build("pre loop pos1: ",pos1))
   WHILE (pos1 > 0
    AND pos1 < size(textin)
    AND exitcnt < 1000)
     SET exitcnt = (exitcnt+ 1)
     SET starttext = findstring(" ",textin,(pos1+ 4))
     SET endpos = findstring("\par",textin,starttext)
     CALL echo(substring(pos1,(endpos - pos1),textin))
     CALL echo(build("containedParagraph Prior to set/reset: ",containedparagraph))
     IF (containedparagraph=1)
      IF (findstring("}",substring(pos1,(endpos - pos1),textin),1) > 0)
       SET containedparagraph = 0
       SET containedtabval = 0
       SET containedtablevel = 0
      ENDIF
     ELSEIF (findstring("{",substring(pos1,5,textin),1) > 0)
      SET containedparagraph = 1
     ENDIF
     CALL echo(build("containedParagraph post: ",containedparagraph))
     SET openbracketpos = 0
     SET closebracketpos = 0
     CALL echo(build("startBeforeRTFBracketSearch",starttext))
     SET openbracketpos = findstring("{",substring((pos1+ 6),(starttext - pos1),textin),1)
     CALL echo(build("openBracketPos:",openbracketpos))
     CALL echo(substring(((pos1+ openbracketpos)+ 2),7,textin))
     IF (openbracketpos > 0
      AND findstring("par",substring(((pos1+ openbracketpos)+ 2),7,textin),1)=0)
      SET openbracketpos = ((openbracketpos+ pos1)+ 6)
      CALL echo(substring((openbracketpos - 5),10,textin))
      SET closebracketpos = findstring("}",substring(openbracketpos,(endpos - pos1),textin),1)
      IF (closebracketpos > 0)
       SET closebracketpos = (closebracketpos+ openbracketpos)
       CALL echo("Found RTFcode that contains inner paragraph {} setting startText pos after }")
       CALL echo(substring(((pos1+ 6)+ openbracketpos),(endpos - pos1),textin))
       CALL echo(build("closeBracketPos:",closebracketpos))
       SET starttext = findstring(" ",textin,closebracketpos)
      ENDIF
     ELSE
      SET starttext = findstring(" ",textin,(pos1+ 4))
     ENDIF
     CALL echo(build("startAfterRTFBracketSearch",starttext))
     IF (containedparagraph < 1)
      CALL adjusttabs(tabval,tablevel)
      SET tabval = tabvalout
      SET tablevel = tablevelout
     ELSE
      CALL adjusttabs(containedtabval,containedtablevel)
      SET containedtabval = tabvalout
      SET containedtablevel = tablevelout
     ENDIF
     IF (endpos > 0)
      SET txtspc = fillstring(50," ")
      CALL echo(build("tabLevel:",tablevel,":",containedtablevel))
      IF (((tablevel+ containedtablevel) > 8))
       SET temptablevel1 = 8
       SET tempcontainedtablevel1 = 0
      ELSE
       SET temptablevel1 = tablevel
       SET tempcontainedtablevel1 = containedtablevel
      ENDIF
      FOR (x = 1 TO (temptablevel1+ tempcontainedtablevel1))
        CALL echo(build("Tabbing over: ",x))
        SET txtspc = concat(char(185),txtspc)
        CALL echo(txtspc)
      ENDFOR
      SET q = 0
      SET truestarttext = starttext
      FOR (q = 1 TO (endpos - starttext))
       SET tempchar = ichar(substring((starttext+ q),1,textin))
       IF (((tempchar BETWEEN 33 AND 126) OR (q > 40)) )
        SET truestarttext = (starttext+ q)
        SET q = (endpos - starttext)
       ENDIF
      ENDFOR
      CALL echo(build("trueStart:",truestarttext))
      SET textin = concat(substring(1,starttext,textin),trim(txtspc),substring(truestarttext,size(
         textin),textin))
      IF (tabpos > 0)
       CALL echo("\tab found adding tab")
       SET textin = concat(substring(1,starttext,textin),char(185),substring(starttext,size(textin),
         textin))
      ENDIF
     ENDIF
     SET endpos = findstring("\par",textin,starttext)
     CALL echo(substring(pos1,(endpos - pos1),textin))
     SET pos1 = findstring("\par",textin,starttext)
     CALL echo(build("new Pos1:",pos1))
     IF (((pos1 < 1) OR (exitcnt=1000)) )
      SET pos1 = size(textin)
     ENDIF
     CALL echo(build("***************************ExitCnt",exitcnt))
   ENDWHILE
   SET inserttabfromrtfout = textin
 END ;Subroutine
 SUBROUTINE adjusttabs(tabvalin,tablevelin)
   SET temptabvalin = 0
   SET tabvalout = 0
   SET tablevelout = 0
   SET lipos = 0
   SET tabpos = 0
   SET loseprepargformat = 0
   SET temptabval = 0
   SET truestart = 0
   CALL echo("adjustTabs subroutine")
   CALL echo(build("tabValIn: ",tabvalin))
   CALL echo(build("tabLevelIn: ",tablevelin))
   SET loseprepargformat = findstring("\pard",substring(pos1,(starttext - (pos1+ 4)),textin),1)
   CALL echo(build("New Paragraph(0 = no):",loseprepargformat))
   SET lipos = findstring("\li",substring(pos1,((starttext - pos1)+ 5),textin),1)
   SET tabpos = findstring("\tab",substring(pos1,(starttext - pos1),textin),1)
   CALL echo(build("LiPos:",lipos))
   CALL echo(build("tabPos: ",tabpos))
   IF (lipos > 0)
    SET lipos = ((lipos+ pos1)+ 2)
    SET spcstart = findstring(" ",textin,lipos)
    CALL echo(build("STARTSPACECNT:",truestart,"tabLevelIn:",tablevelin))
    IF (loseprepargformat < 1)
     SET tabvalin = ((tablevelin+ 1) * (tabvalin/ tablevelin))
     SET tablevelin = (tablevelin+ 1)
    ELSE
     CALL echo(build("True li Pos:",lipos))
     IF (isnumeric(trim(substring(lipos,(findstring(" ",textin,lipos) - lipos),textin))))
      SET temptabvalin = cnvtint(substring(lipos,(findstring(" ",textin,lipos) - lipos),textin))
     ELSE
      SET temptabvalin = cnvtint(substring(lipos,(findstring("\",textin,lipos) - lipos),textin))
     ENDIF
     CALL echo(build("Found LI Tab:",temptabvalin))
     IF (temptabvalin > tabvalin)
      SET tablevelin = (tablevelin+ 1)
     ELSEIF (tabvalin > 0
      AND tablevelin > 1)
      SET tablevelin = (tablevelin - 1)
     ELSE
      IF (tabvalin=0)
       SET tablevelin = 0
      ENDIF
     ENDIF
     SET tabvalin = temptabvalin
    ENDIF
   ELSEIF (tabpos > 0)
    SET spcstart = findstring(" ",textin,tabpos)
    CALL echo("tabPos > 0  - ignore paragraph formats")
   ELSEIF (loseprepargformat > 1)
    SET truestart = 0
    SET spcstart = findstring(" ",textin,starttext)
    CALL echo("No Paragraph format found - reseting tabs")
    SET tabvalin = 0
    SET tablevelin = 0
   ENDIF
   SET spccnt = 0
   WHILE (ichar(substring((spcstart+ spccnt),1,textin))=32
    AND spccnt <= 8
    AND endpos > 0)
    SET spccnt = (spccnt+ 1)
    IF (spccnt=8)
     CALL echo("adding space tab")
     SET tabvalin = ((tablevelin+ 1) * (tabvalin/ tablevelin))
     SET tablevelin = (tablevelin+ 1)
    ENDIF
   ENDWHILE
   SET tabvalout = tabvalin
   SET tablevelout = tablevelin
   CALL echo(build("tabValOut: ",tabvalout))
   CALL echo(build("tabLevelOut: ",tablevelout))
 END ;Subroutine
 SUBROUTINE convertrtftopostscript(blob_uncompressed,blob_return_len,blob_rtf,blobsize,
  blob_return_len2,int)
   CALL inserttabfromrtf(blob_uncompressed)
   SET blobtemp = inserttabfromrtfout
   CALL echo("@*********************************************@")
   SET blobtemp = replace(blobtemp,"\b0",concat(char(222)))
   SET blobtemp = replace(blobtemp,"\b",concat(" ",char(225)))
   SET blobsize = size(blobtemp)
   CALL echo(blobtemp)
   CALL echo("!*********************************************!")
   CALL uar_rtf2(blobtemp,blobsize,blob_rtf,blobsize,blob_return_len2,
    int)
   CALL echo(blob_rtf)
   SET blob_out_detail = blob_rtf
   CALL echo("$$*****************************************************$$")
 END ;Subroutine
 FREE RECORD blob
 RECORD blob(
   1 line = vc
   1 cnt = i2
   1 qual[*]
     2 line = vc
     2 sze = i4
 )
 FREE RECORD pt
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 FREE RECORD pat
 RECORD pat(
   1 person_id = f8
   1 event_qual = i4
   1 list[*]
     2 parent_event_id = f8
 )
 DECLARE signed_cd = f8 WITH public, constant(uar_get_code_by("MEANING",15750,"SIGNED"))
 DECLARE sign_cd = f8 WITH public, constant(uar_get_code_by("MEANING",21,"SIGN"))
 DECLARE admitdoc = f8 WITH public, constant(uar_get_code_by("MEANING",333,"ADMITDOC"))
 DECLARE mrn_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE fin_cd = f8 WITH public, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE blob_size = i4
 DECLARE blob_out_detail = c64000
 DECLARE blob_compressed_trimmed = c64000
 DECLARE blob_uncompressed = c64000
 DECLARE blob_rtf = c64000
 DECLARE blob_out_detail = c64000
 DECLARE print_disp = vc
 DECLARE beg_ind = i2 WITH noconstant(0)
 DECLARE end_ind = i2 WITH noconstant(0)
 DECLARE beg_dt_tm = q8 WITH noconstant(cnvtdatetime(curdate,curtime))
 DECLARE end_dt_tm = q8 WITH noconstant(cnvtdatetime(curdate,curtime))
 DECLARE x2 = c2 WITH noconstant("  ")
 DECLARE x3 = c3 WITH noconstant("   ")
 DECLARE abc = vc WITH noconstant(fillstring(25," "))
 DECLARE xyz = c21 WITH noconstant("  -   -       :  :  ")
 DECLARE tab = vc
 DECLARE printstring = vc
 DECLARE tempstring = vc
 DECLARE i = i4
 IF (validate(request->visit,"Z") != "Z")
  SET printer_name = request->output_device
  SET patient_cnt = size(request->visit,5)
  FOR (x = 1 TO request->nv_cnt)
    IF ((request->nv[x].pvc_name="BEG_DT_TM"))
     SET beg_ind = 1
     SET abc = trim(request->nv[x].pvc_value)
     SET stat = movestring(abc,7,xyz,1,2)
     SET x2 = substring(5,2,abc)
     IF (x2="01")
      SET x3 = "JAN"
     ELSEIF (x2="02")
      SET x3 = "FEB"
     ELSEIF (x2="03")
      SET x3 = "MAR"
     ELSEIF (x2="04")
      SET x3 = "APR"
     ELSEIF (x2="05")
      SET x3 = "MAY"
     ELSEIF (x2="06")
      SET x3 = "JUN"
     ELSEIF (x2="07")
      SET x3 = "JUL"
     ELSEIF (x2="08")
      SET x3 = "AUG"
     ELSEIF (x2="09")
      SET x3 = "SEP"
     ELSEIF (x2="10")
      SET x3 = "OCT"
     ELSEIF (x2="11")
      SET x3 = "NOV"
     ELSEIF (x2="12")
      SET x3 = "DEC"
     ENDIF
     SET stat = movestring(x3,1,xyz,4,3)
     SET stat = movestring(abc,1,xyz,8,4)
     SET stat = movestring(abc,9,xyz,13,2)
     SET stat = movestring(abc,11,xyz,16,2)
     SET stat = movestring(abc,13,xyz,19,2)
     SET beg_dt_tm = cnvtdatetime(xyz)
    ELSEIF ((request->nv[x].pvc_name="END_DT_TM"))
     SET end_ind = 1
     SET abc = trim(request->nv[x].pvc_value)
     SET stat = movestring(abc,7,xyz,1,2)
     SET x2 = substring(5,2,abc)
     IF (x2="01")
      SET x3 = "JAN"
     ELSEIF (x2="02")
      SET x3 = "FEB"
     ELSEIF (x2="03")
      SET x3 = "MAR"
     ELSEIF (x2="04")
      SET x3 = "APR"
     ELSEIF (x2="05")
      SET x3 = "MAY"
     ELSEIF (x2="06")
      SET x3 = "JUN"
     ELSEIF (x2="07")
      SET x3 = "JUL"
     ELSEIF (x2="08")
      SET x3 = "AUG"
     ELSEIF (x2="09")
      SET x3 = "SEP"
     ELSEIF (x2="10")
      SET x3 = "OCT"
     ELSEIF (x2="11")
      SET x3 = "NOV"
     ELSEIF (x2="12")
      SET x3 = "DEC"
     ENDIF
     SET stat = movestring(x3,1,xyz,4,3)
     SET stat = movestring(abc,1,xyz,8,4)
     SET stat = movestring(abc,9,xyz,13,2)
     SET stat = movestring(abc,11,xyz,16,2)
     SET stat = movestring(abc,13,xyz,19,2)
     SET end_dt_tm = cnvtdatetime(xyz)
    ENDIF
  ENDFOR
 ELSE
  SET encntr_to_search = 29975978.00
  SET patient_cnt = 1
  SET end_dt_tm = cnvtdatetime(curdate,curtime3)
  SET beg_dt_tm = cnvtdatetime((curdate - 5),0)
 ENDIF
 FOR (pds = 1 TO patient_cnt)
   IF (validate(request->visit,"Z") != "Z")
    SET encntr_to_search = request->visit[patient_cnt].encntr_id
   ENDIF
   SELECT INTO "nl:"
    FROM clinical_event ce,
     scd_story s,
     scd_story_pattern ssp,
     scr_pattern sp,
     ce_blob ceb
    PLAN (ce
     WHERE ce.encntr_id=encntr_to_search
      AND ce.event_end_dt_tm BETWEEN cnvtdatetime(beg_dt_tm) AND cnvtdatetime(end_dt_tm)
      AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
      AND ce.event_tag != "In Error")
     JOIN (s
     WHERE s.encounter_id=ce.encntr_id
      AND s.event_id=ce.parent_event_id
      AND s.story_completion_status_cd=signed_cd)
     JOIN (ssp
     WHERE ssp.scd_story_id=s.scd_story_id)
     JOIN (sp
     WHERE sp.scr_pattern_id=ssp.scr_pattern_id
      AND sp.display_key="PSYCHIATRICDISCHARGEPLAN")
     JOIN (ceb
     WHERE ceb.event_id=ce.event_id)
    ORDER BY ce.parent_event_id, ce.event_id
    HEAD REPORT
     event_cnt = 0
    HEAD ce.parent_event_id
     event_cnt = (event_cnt+ 1), stat = alterlist(pat->list,event_cnt), pat->list[event_cnt].
     parent_event_id = ce.parent_event_id
    FOOT REPORT
     pat->event_qual = event_cnt
    WITH nocounter, nullreport
   ;end select
   FOR (agc = 1 TO pat->event_qual)
     SET file_name = concat("psychdischrpt",cnvtstring(encntr_to_search),cnvtstring(agc))
     SET i = 0
     SELECT INTO value(file_name)
      name = substring(1,50,p.name_full_formatted), dob = format(p.birth_dt_tm,"mm/dd/yyyy;;d"),
      admitdoc = substring(1,30,pl.name_full_formatted),
      admit_dt = format(e.reg_dt_tm,"mm/dd/yy;;d"), location = substring(1,20,uar_get_code_display(e
        .location_cd)), facility = uar_get_code_description(e.loc_facility_cd),
      room = substring(1,30,uar_get_code_display(e.loc_room_cd)), unit = substring(1,30,
       uar_get_code_display(e.loc_nurse_unit_cd)), bed = substring(1,30,uar_get_code_display(e
        .loc_bed_cd)),
      finnbr = decode(ea.seq,substring(1,20,cnvtalias(ea.alias,ea.alias_pool_cd))), mrn = cnvtalias(
       pa.alias,pa.alias_pool_cd), mrn_pool = uar_get_code_display(pa.alias_pool_cd),
      age = build(trim(cnvtage(cnvtdate(p.birth_dt_tm),curdate))), sex = build(trim(
        uar_get_code_display(p.sex_cd))), event_cd_disp = substring(1,40,uar_get_code_display(ce
        .event_cd)),
      event_title_text = substring(1,110,ce.event_title_text), event_tag = substring(1,50,ce
       .event_tag), event_id = ce.event_id,
      parent_event_id = ce.parent_event_id, event_date = substring(1,20,format(ce.event_end_dt_tm,
        "mm/dd/yyyy hh:mm;;d")), author = substring(1,40,pl2.name_full_formatted),
      author_dt = format(cep.action_dt_tm,"@LONGDATE;L"), author_wk = format(cep.action_dt_tm,
       "WWWWWWWWW;;d"), author_tm = format(cep.action_dt_tm,"hh:mm;;d")
      FROM clinical_event ce,
       ce_blob ceb,
       ce_event_prsnl cep,
       encounter e,
       person p,
       encntr_alias ea,
       person_alias pa,
       encntr_prsnl_reltn epr,
       prsnl pl,
       prsnl pl2
      PLAN (ce
       WHERE (ce.parent_event_id=pat->list[agc].parent_event_id)
        AND ce.event_end_dt_tm BETWEEN cnvtdatetime(beg_dt_tm) AND cnvtdatetime(end_dt_tm)
        AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
       JOIN (ceb
       WHERE ceb.event_id=ce.event_id
        AND ceb.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
       JOIN (cep
       WHERE outerjoin(ce.event_id)=cep.event_id
        AND cep.valid_until_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00"))
        AND cep.action_type_cd=outerjoin(sign_cd))
       JOIN (pl2
       WHERE outerjoin(cep.action_prsnl_id)=pl2.person_id
        AND pl2.active_ind=outerjoin(1))
       JOIN (e
       WHERE e.encntr_id=ce.encntr_id)
       JOIN (p
       WHERE p.person_id=e.person_id
        AND p.active_ind=1)
       JOIN (pa
       WHERE pa.person_id=outerjoin(p.person_id)
        AND pa.person_alias_type_cd=outerjoin(mrn_cd)
        AND pa.active_ind=outerjoin(1))
       JOIN (ea
       WHERE ea.encntr_id=outerjoin(e.encntr_id)
        AND ea.encntr_alias_type_cd=outerjoin(fin_cd)
        AND ea.active_ind=outerjoin(1))
       JOIN (epr
       WHERE epr.encntr_id=outerjoin(e.encntr_id)
        AND epr.encntr_prsnl_r_cd=outerjoin(admitdoc)
        AND epr.active_ind=outerjoin(1))
       JOIN (pl
       WHERE pl.person_id=outerjoin(epr.prsnl_person_id))
      ORDER BY ce.event_end_dt_tm, ceb.event_id
      HEAD REPORT
       MACRO (dcp_parse_text)
        lf = concat(char(13),char(10)), l = 0, h = 0,
        cr = 0, length = 0, check_blob = fillstring(32000," "),
        check_blob = blob_test2, max_length = max_length, check_blob = concat(trim(check_blob),lf),
        blob->cnt = 0, cr = findstring(lf,check_blob), length = textlen(check_blob)
        WHILE (cr > 0)
          blob->line = substring(1,(cr - 1),check_blob), check_blob = substring((cr+ 2),(length - (cr
           + 2)),check_blob), blob->cnt = (blob->cnt+ 1),
          stat = alterlist(blob->qual,blob->cnt), blob->qual[blob->cnt].line = trim(blob->line), blob
          ->qual[blob->cnt].sze = textlen(trim(blob->line)),
          cr = findstring(lf,check_blob)
        ENDWHILE
        FOR (j = 1 TO blob->cnt)
          WHILE ((blob->qual[j].sze > max_length))
            h = l, c = max_length
            WHILE (c > 0)
             IF (substring(c,1,blob->qual[j].line) IN (" ", "-"))
              l = (l+ 1), stat = alterlist(pt->lns,l), pt->lns[l].line = substring(1,c,blob->qual[j].
               line),
              blob->qual[j].line = substring((c+ 1),(blob->qual[j].sze - c),blob->qual[j].line), c =
              1
             ENDIF
             ,c = (c - 1)
            ENDWHILE
            IF (h=l)
             l = (l+ 1), stat = alterlist(pt->lns,l), pt->lns[l].line = substring(1,max_length,blob->
              qual[j].line),
             blob->qual[j].line = substring((max_length+ 1),(blob->qual[j].sze - max_length),blob->
              qual[j].line)
            ENDIF
            blob->qual[j].sze = size(trim(blob->qual[j].line))
          ENDWHILE
          l = (l+ 1), stat = alterlist(pt->lns,l), pt->lns[l].line = substring(1,blob->qual[j].sze,
           blob->qual[j].line),
          pt->line_cnt = l
        ENDFOR
       ENDMACRO
       , xcol = 25, ycol = 75,
       name_disp = fillstring(10," "), name_disp = build(trim(name)), auth_disp_line = fillstring(110,
        " "),
       mrn_disp = concat(trim(mrn_pool),char(58),char(32),trim(mrn)), age_disp = concat("Age:",char(
         32),trim(age)), sex_disp = concat("Sex:",char(32),trim(sex)),
       fac_disp = build(trim(facility)), line1 = fillstring(84,"_"), line2 = fillstring(31,"_"),
       line3 = fillstring(100,"_"), instr_data = fillstring(300," "),
       MACRO (line_wrap)
        limit = 0, cr = char(13), lf = char(10)
        WHILE (tempstring > " "
         AND limit < 1000)
          ii = 0, limit = (limit+ 1), pos = 0
          WHILE (pos=0)
           ii = (ii+ 1),
           IF (substring((maxlen - ii),1,tempstring) IN (" ", ","))
            pos = (maxlen - ii)
           ELSEIF (ii=maxlen)
            pos = maxlen
           ENDIF
          ENDWHILE
          printstring = substring(1,pos,tempstring)
          IF (limit > 1)
           printstring = concat("   ",printstring)
          ENDIF
          lfloc = findstring(lf,printstring), crloc = findstring(cr,printstring)
          IF (lfloc=0
           AND crloc=0)
           CALL print(calcpos(xcol,ycol)), printstring, row + 1,
           ycol = (ycol+ 12), tempstring = substring((pos+ 1),9999,tempstring)
          ELSE
           IF (((crloc < lfloc
            AND crloc > 0) OR (lfloc=0)) )
            printstring = substring(1,(crloc - 1),printstring),
            CALL print(calcpos(xcol,ycol)), printstring,
            row + 1, ycol = (ycol+ 12), tempstring = substring((crloc+ 2),9999,tempstring)
           ELSEIF (((lfloc < crloc
            AND lfloc > 0) OR (crloc=0)) )
            printstring = substring(1,(lfloc - 1),printstring),
            CALL print(calcpos(xcol,ycol)), printstring,
            row + 1, ycol = (ycol+ 12), tempstring = substring((lfloc+ 2),9999,tempstring)
           ENDIF
           WHILE (substring(1,1,tempstring) IN (" ", cr, lf))
             tempstring = substring(2,9999,tempstring)
           ENDWHILE
          ENDIF
        ENDWHILE
       ENDMACRO
      HEAD PAGE
       "{f/8}{CPI/8}{pos/55/60}{color/20/120}", row + 1, "{f/8}{CPI/8}{pos/55/65}{color/20/120}",
       row + 1, "{f/8}{CPI/8}{pos/55/70}{color/20/120}", row + 1,
       "{f/8}{CPI/8}{pos/55/75}{color/20/120}", row + 1, "{f/8}{CPI/8}{pos/55/80}{color/20/120}",
       row + 1, "{f/8}{CPI/8}{pos/55/85}{color/20/120}", row + 1,
       "{f/8}{CPI/8}{pos/55/90}{color/20/120}", row + 1, "{f/8}{CPI/8}{pos/55/95}{color/20/120}",
       row + 1, ycol = 80, xcol = 55,
       "{pos/58/80}{f/8}{cpi/10}{b}PATIENT NAME: ", xcol = 155,
       CALL print(calcpos(xcol,ycol)),
       name, "{endb}", row + 1,
       xcol = 400,
       CALL print(calcpos(xcol,ycol)), "{b}Acct # ",
       finnbr, "{endb}", row + 1,
       ycol = (ycol+ 30), xcol = 55
       IF (curpage != 1)
        CALL print(calcpos(xcol,ycol)), "{f/4}{cpi/10}", ycol = (ycol+ 12)
       ENDIF
      HEAD ce.event_id
       xcol = 55, ycol = (ycol+ 12)
       IF (cep.action_type_cd=sign_cd)
        auth_disp_line = concat(trim(event_tag),char(32),"by",char(32),trim(author),
         char(32),"on",char(32),trim(author_wk,3),char(44),
         char(32),trim(author_dt,3),char(32),trim(author_tm,3))
       ELSE
        auth_disp_line = event_title_text
       ENDIF
       IF (size(auth_disp_line) < 120)
        CALL print(calcpos(xcol,ycol)), "{f/8}{cpi/11}{b}", auth_disp_line,
        "{ENDB}", row + 1, ycol = (ycol+ 12),
        CALL print(calcpos(xcol,ycol)), "{f/4}{cpi/10}", ycol = (ycol+ 12)
       ELSE
        auth_disp_line_a = substring(1,findstring(" on ",auth_disp_line),auth_disp_line),
        auth_disp_line_b = substring(findstring(" on ",auth_disp_line),size(auth_disp_line),
         auth_disp_line),
        CALL print(calcpos(xcol,ycol)),
        "{f/8}{cpi/11}{b}", auth_disp_line_a, "{ENDB}",
        row + 1, ycol = (ycol+ 12),
        CALL print(calcpos(xcol,ycol)),
        "{f/8}{cpi/11}{b}", auth_disp_line_b, "{ENDB}",
        row + 1, ycol = (ycol+ 12),
        CALL print(calcpos(xcol,ycol)),
        "{f/4}{cpi/10}", ycol = (ycol+ 12)
       ENDIF
       CALL uncompress_blob(ceb.blob_contents,ceb.blob_length), blob_test1 = replace(blob_out_detail,
        char(10),"|",0), blob_test1 = replace(blob_test1,"PRN","as needed",0),
       blob_test1 = replace(blob_test1,"Discharge Nursing Homes/Rehab Facilities",concat(char(225),
         "Discharge Nursing Homes/Rehab Facilities",char(222)),0), blob_test1 = replace(blob_test1,
        "Discharge Adult Day Health Care",concat(char(225),"Discharge Adult Day Health Care",char(222
          )),0), blob_test1 = replace(blob_test1,"Discharge Rest Homes/Residences/Shelters",concat(
         char(225),"Discharge Rest Homes/Residences/Shelters",char(222)),0),
       blob_test1 = replace(blob_test1,"Discharge VNA/Hospice/Home Care",concat(char(225),
         "Discharge VNA/Hospice/Home Care",char(222)),0), blob_test1 = replace(blob_test1,
        "Discharge Early Intervention Programs",concat(char(225),
         "Discharge Early Intervention Programs",char(222)),0), blob_test1 = replace(blob_test1,
        "Discharge Medical Equipment Companies",concat(char(225),
         "Discharge Medical Equipment Companies",char(222)),0),
       blob_test1 = replace(blob_test1,"Discharge Chronic Hospital",concat(char(225),
         "Discharge Chronic Hospital",char(222)),0), blob_test1 = replace(blob_test1,"Name of Agency",
        concat(char(225),"Name of Agency",char(222)),0), blob_test1 = replace(blob_test1,
        "Agency Contact Person",concat(char(225),"Agency Contact Person",char(222)),0),
       blob_test1 = replace(blob_test1,"Additional agency referral info",concat(char(225),
         "Additional agency referral info",char(222)),0), blob_test1 = replace(blob_test1,
        "Additional instructions to patient",concat(char(225),"Additional instructions to patient",
         char(222)),0), blob_test1 = replace(blob_test1,"Service Start Date and Time",concat(char(225
          ),"Service Start Date and Time",char(222)),0),
       blob_test1 = replace(blob_test1,"Service Categories",concat(char(225),"Service Categories",
         char(222)),0), eol = size(trim(blob_test1,1),1), delimiter = findstring(char(124),blob_test1
        )
       WHILE (delimiter > 0)
         IF (blob_test1="*TX_RTF32 9.0.310.500*")
          blob_test2 = concat(trim(substring(25,(delimiter - 1),blob_test1)))
         ELSE
          blob_test2 = concat(trim(substring(1,(delimiter - 1),blob_test1)))
         ENDIF
         stat = alterlist(blob->qual,1), blob->line = "", blob->cnt = 0,
         stat = alterlist(pt->lns,1), pt->line_cnt = 0, max_length = 90,
         tab = "", i = 1, xcnt = 0,
         space = " "
         WHILE (i <= size(trim(blob_test2)))
          IF (ichar(substring(i,1,trim(blob_test2)))=185)
           tab = concat(char(0),tab,"    ",char(0))
          ELSEIF (substring(i,1,trim(blob_test2))=char(225)
           AND i=1)
           xcnt = i
           WHILE (substring((xcnt+ 4),1,trim(blob_test2))=space
            AND xcnt < size(trim(blob_test2)))
             xcnt = (xcnt+ 1)
           ENDWHILE
           IF (xcnt > i)
            blob_test2 = concat(substring(1,i,trim(blob_test2)),substring((xcnt+ 3),size(trim(
                blob_test2)),blob_test2)),
            CALL echo(build("parseing spaces on bold",blob_test2))
           ENDIF
          ELSEIF (ichar(substring(i,1,trim(blob_test2))) BETWEEN 33 AND 126)
           i = size(trim(blob_test2))
          ENDIF
          ,i = (i+ 1)
         ENDWHILE
         max_length = (max_length - size(tab)), dcp_parse_text, line_cnt = 0,
         prevlinebold = 0
         FOR (line_cnt = 1 TO pt->line_cnt)
           xcol = 55,
           CALL echo(build("!!@@",concat(trim(pt->lns[line_cnt].line)),"!!@")), print_disp = concat(
            tab,trim(pt->lns[line_cnt].line)),
           print_disp = replace(print_disp,char(185),""), print_disp = replace(print_disp,char(222),
            "{ENDB}",0), print_disp = replace(print_disp,char(225),"{b}",0),
           print_disp = trim(print_disp)
           IF (line_cnt > 1)
            print_disp = concat("  ",print_disp)
           ENDIF
           IF (prevlinebold=1)
            print_disp = concat("{b}",print_disp)
           ENDIF
           CALL echo(build("JAD",concat(trim(pt->lns[line_cnt].line)),"!!@")),
           CALL print(calcpos(xcol,ycol)), "{f/8}{cpi/10}{lpi/12}",
           print_disp, row + 3, bfound = findstring("{b}",print_disp,1,1),
           endbfound = findstring("{ENDB}",print_disp,1,1)
           IF (((endbfound < bfound) OR (prevlinebold
            AND endbfound=0)) )
            prevlinebold = 1
           ELSE
            prevlinebold = 0
           ENDIF
           CALL echo(build("--",print_disp)), ycol = (ycol+ 12)
           IF (ycol > 650)
            BREAK
           ENDIF
         ENDFOR
         blob_test1 = substring((delimiter+ 1),eol,blob_test1), eol = size(trim(blob_test1),1),
         delimiter = findstring("|",blob_test1),
         end_col = ycol
       ENDWHILE
      FOOT PAGE
       IF (curpage != 1)
        ycol = 664, xcol = 218,
        CALL print(calcpos(xcol,ycol)),
        "{f/4}{cpi/12}{lpi/8}",
        CALL print(calcpos(xcol,ycol)), "{b}",
        "****  Continued From Previous Page  ****", "{endb}", "{pos/55/660}",
        line2, row + 1, "{pos/410/660}",
        line2, row + 1
       ELSE
        "{pos/55/660}", line1, row + 1
       ENDIF
       "{f/4}{cpi/12}{lpi/8}{pos/260/687}", "{b/7}Patient: ", "{pos/297/687}",
       name, xxx = concat(trim(unit)," / ",trim(room)," / ",trim(bed)), "{pos/440/687}",
       "{b/8}Location: ", xxx, row + 1,
       "{pos/260/698}", "{b/6}Acct #: ", finnbr,
       row + 1, "{pos/440/698}", "{b/3}ADM: ",
       admit_dt, row + 1, "{pos/260/709}",
       "{b/7}", mrn_disp, row + 1,
       "{pos/370/709}", "{b/3}", age_disp,
       "{pos/440/709}", "{b/3}", sex_disp,
       row + 1
       IF (facility="BAYSTATE MEDICAL CENTER INPATIENT PSYCHIATRY")
        facility_out = "BAYSTATE MEDICAL CENTER"
       ELSEIF (facility="FRANKLIN MEDICAL CENTER INPATIENT PSYCHIATRY")
        facility_out = "FRANKLIN MEDICAL CENTER"
       ELSE
        facility_out = facility
       ENDIF
       "{pos/260/720}", "{b/12}Admitting MD: ", admitdoc,
       row + 1, "{pos/440/731}", "{b/6}Page # ",
       curpage, row + 1, "{cpi/10}{pos/55/693}{b}",
       facility_out, row + 1, "{cpi/10}{pos/55/708}{b}",
       "Psychiatric Discharge Plan", "{f/8}{cpi/15}{lpi/10}{pos/55/720}", "BHS_MA_PSYCH_DISCH_PT",
       "{f/4}{cpi/12}{pos/55/732}{b/8}Printed: ", curdate, "  ",
       curtime, "{endb}", row + 1
      FOOT REPORT
       BREAK, ycol = (ycol+ 15), xcol = 55,
       row 15, col 0, "{f/8}{cpi/10}",
       row 16, col 0, instr_data =
       "Medication Instructions and follow-up appointments will be reviewed with you prior to discharge.",
       CALL print(calcpos(xcol,ycol)), instr_data, row + 1,
       ycol = (ycol+ 24), "{b}", instr_data =
       "If you do not agree with your discharge plan, your doctor and the hospital discharge",
       CALL print(calcpos(xcol,ycol)), instr_data, row + 1,
       ycol = (ycol+ 12), "{b}", instr_data =
       "planning coordinator must meet with you to develop a satisfactory plan.  If after the",
       CALL print(calcpos(xcol,ycol)), instr_data, row + 1,
       ycol = (ycol+ 12), "{b}", instr_data =
       "meeting you still do not agree with your discharge plan, you may request the",
       CALL print(calcpos(xcol,ycol)), instr_data, row + 1,
       ycol = (ycol+ 12), "{b}", instr_data =
       "Massachusetts Department of Public  Health's Advocacy Office to review the plan and ",
       CALL print(calcpos(xcol,ycol)), instr_data, row + 1,
       ycol = (ycol+ 12), "{b}", instr_data =
       "decide if it is adequate, by calling the Office's 24 hour number at 1-800-462-5540.",
       CALL print(calcpos(xcol,ycol)), instr_data, row + 1,
       ycol = (ycol+ 24), "{b}", instr_data =
       "In the event you have questions about your discharge plan once you leave, please call:",
       CALL print(calcpos(xcol,ycol)), instr_data, row + 1,
       ycol = (ycol+ 24), instr_data = "{u/55}",
       CALL print(calcpos(xcol,ycol)),
       instr_data, row + 1, xcol = 440,
       instr_data = "{u/30}",
       CALL print(calcpos(xcol,ycol)), instr_data,
       row + 1, ycol = (ycol+ 15), xcol = 55,
       "{b}", instr_data = "Name/Title",
       CALL print(calcpos(xcol,ycol)),
       instr_data, row + 1, xcol = 440,
       "{b}", instr_data = "Phone Number",
       CALL print(calcpos(xcol,ycol)),
       instr_data, row + 1, xcol = 55,
       ycol = (ycol+ 24), instr_data =
       "Your signature does not necessarily indicate approval of the plan and does not prevent the right",
       CALL print(calcpos(xcol,ycol)),
       instr_data, row + 1, ycol = (ycol+ 12),
       instr_data = "to a meeting or a request to the Advocacy Office.",
       CALL print(calcpos(xcol,ycol)), instr_data,
       row + 1, ycol = (ycol+ 24), instr_data =
       "Once you have received your discharge plan, we ask that you sign your name below to indicate",
       CALL print(calcpos(xcol,ycol)), instr_data, row + 1,
       ycol = (ycol+ 12), instr_data =
       "that you have participated in its development and have received a copy for your reference after",
       CALL print(calcpos(xcol,ycol)),
       instr_data, row + 1, ycol = (ycol+ 12),
       instr_data = "discharge.",
       CALL print(calcpos(xcol,ycol)), instr_data,
       row + 1, ycol = (ycol+ 24), ycol = (ycol+ 12),
       xcol = 55,
       CALL print(calcpos(xcol,ycol)), "{f/8}{cpi/11}",
       instr_data = "I HAVE EXPLAINED THE INSTRUCTIONS TO THE PATIENT/REPRESENTATIVE.", ycol = (ycol
       + 15),
       CALL print(calcpos(xcol,ycol)),
       instr_data, row + 1, ycol = (ycol+ 24),
       instr_data = "{u/85}",
       CALL print(calcpos(xcol,ycol)), instr_data,
       row + 1, xcol = 440, instr_data = "{u/40}",
       CALL print(calcpos(xcol,ycol)), instr_data, row + 1,
       ycol = (ycol+ 15), xcol = 55, instr_data = "Psychiatric Signature/Interpreter",
       CALL print(calcpos(xcol,ycol)), instr_data, row + 1,
       xcol = 440, instr_data = "DATE",
       CALL print(calcpos(xcol,ycol)),
       instr_data, row + 1, xcol = 55,
       instr_data = "I WAS GIVEN A COPY OF THIS FORM AND I UNDERSTAND AND ACCEPT THIS INFORMATION.",
       ycol = (ycol+ 24),
       CALL print(calcpos(xcol,ycol)),
       instr_data, row + 1, ycol = (ycol+ 24),
       instr_data = "{u/85}",
       CALL print(calcpos(xcol,ycol)), instr_data,
       row + 1, xcol = 440, instr_data = "{u/40}",
       CALL print(calcpos(xcol,ycol)), instr_data, row + 1,
       ycol = (ycol+ 15), xcol = 55, instr_data = "Signature of patient/Representative",
       CALL print(calcpos(xcol,ycol)), instr_data, row + 1,
       xcol = 440, instr_data = "DATE",
       CALL print(calcpos(xcol,ycol)),
       instr_data, row + 1, ycol = (ycol+ 24),
       xcol = 55,
       CALL print(calcpos(xcol,ycol)), "{f/8}{cpi/10}",
       "{f/4}{cpi/12}{lpi/8}",
       CALL print(calcpos(55,660)), line3,
       row + 1, "{f/4}{cpi/12}{lpi/8}",
       CALL print(calcpos(239,674)),
       "{b}", "****  END OF REPORT  ****", "{endb}",
       "{cpi/12}{pos/260/687}", "{b/7}Patient: ", "{pos/297/687}",
       name, xxx = concat(trim(unit)," / ",trim(room)," / ",trim(bed)), "{pos/440/687}",
       "{b/8}Location: ", xxx, row + 1,
       "{pos/260/698}", "{b/6}Acct #: ", finnbr,
       row + 1, "{pos/440/698}", "{b/3}ADM: ",
       admit_dt, row + 1, "{pos/260/709}",
       "{b/7}", mrn_disp, row + 1,
       "{pos/370/709}", "{b/3}", age_disp,
       "{pos/440/709}", "{b/3}", sex_disp,
       row + 1, "{pos/260/720}", "{b/12}Admitting MD: ",
       admitdoc, row + 1
       IF (facility="BAYSTATE MEDICAL CENTER INPATIENT PSYCHIATRY")
        facility_out = "BAYSTATE MEDICAL CENTER"
       ELSEIF (facility="FRANKLIN MEDICAL CENTER INPATIENT PSYCHIATRY")
        facility_out = "FRANKLIN MEDICAL CENTER"
       ELSE
        facility_out = facility
       ENDIF
       "{pos/440/731}", "{b/6}Page # ", curpage,
       row + 1, "{cpi/10}{pos/55/693}{b}", facility_out,
       row + 1, "{cpi/10}{pos/55/708}{b}", "Psychiatric Discharge Report",
       "{f/8}{cpi/15}{lpi/10}{pos/55/720}", "bhs_ma_pysch_disch_rpt",
       "{f/4}{cpi/12}{pos/55/732}{b/8}Printed: ",
       curdate, "  ", curtime,
       "{endb}", row + 1
      WITH maxrow = 750, maxcol = 3200, dio = postscript,
       nullreport
     ;end select
     SET spool patstring(file_name) patstring(printer_name) WITH copy = 1
     SET spool patstring(file_name) patstring(printer_name) WITH copy = 1, deleted
   ENDFOR
 ENDFOR
 SUBROUTINE uncompress_blob(blob_compressed,blob_length)
   SET blob_size = cnvtint(blob_length)
   SET blob_out_detail = fillstring(64000," ")
   SET blob_compressed_trimmed = fillstring(64000," ")
   SET blob_uncompressed = fillstring(64000," ")
   SET blob_rtf = fillstring(64000," ")
   SET blob_out_detail = fillstring(64000," ")
   SET blob_compressed_trimmed = trim(blob_compressed)
   SET blob_return_len = 0
   SET blob_return_len2 = 0
   CALL uar_ocf_uncompress(blob_compressed_trimmed,size(blob_compressed_trimmed),blob_uncompressed,
    size(blob_uncompressed),blob_return_len)
   SET i = 1
   WHILE (i <= blob_return_len)
    IF (ichar(substring(i,1,blob_uncompressed))=10)
     SET stat = movestring(" ",1,blob_uncompressed,i,1)
    ELSEIF (ichar(substring(i,1,blob_uncompressed))=13)
     SET stat = movestring(" ",1,blob_uncompressed,i,1)
    ELSEIF (((ichar(substring(i,1,blob_uncompressed)) < 32) OR (((ichar(substring(i,1,
      blob_uncompressed)) > 127) OR (ichar(substring(i,1,blob_uncompressed))=64)) )) )
     SET stat = movestring(" ",1,blob_uncompressed,i,1)
    ENDIF
    SET i = (i+ 1)
   ENDWHILE
   SET blob_out_detail = blob_uncompressed
   CALL convertrtftopostscript(blob_uncompressed,blob_return_len,blob_rtf,size(blob_rtf),
    blob_return_len2,
    1)
   SET blob_compressed = fillstring(64000," ")
   SET blob_compressed_trimmed = fillstring(64000," ")
 END ;Subroutine
END GO
