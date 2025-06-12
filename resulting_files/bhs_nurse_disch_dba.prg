CREATE PROGRAM bhs_nurse_disch:dba
 DECLARE beg_ind = i2 WITH noconstant(0)
 DECLARE end_ind = i2 WITH noconstant(0)
 DECLARE beg_dt_tm = q8 WITH noconstant(cnvtdatetime(curdate,curtime))
 DECLARE end_dt_tm = q8 WITH noconstant(cnvtdatetime(curdate,curtime))
 DECLARE x2 = c2 WITH noconstant("  ")
 DECLARE x3 = c3 WITH noconstant("   ")
 DECLARE abc = vc WITH noconstant(fillstring(25," "))
 DECLARE xyz = c21 WITH noconstant("  -   -       :  :  ")
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
  SET printer_name =  $1
  SET encntr_to_search = 2415258
  SET patient_cnt = 1
  SET end_dt_tm = cnvtdatetime(curdate,curtime3)
  SET beg_dt_tm = cnvtdatetime((curdate - 5),0)
 ENDIF
 FOR (pds = 1 TO patient_cnt)
   IF (validate(request->visit,"Z") != "Z")
    SET encntr_to_search = request->visit[patient_cnt].encntr_id
   ENDIF
   FREE RECORD disch
   RECORD disch(
     1 qual = i4
     1 list[*]
       2 cd = f8
   )
   SET signed_cd = uar_get_code_by("MEANING",15750,"SIGNED")
   SET sign_cd = uar_get_code_by("MEANING",21,"SIGN")
   SET admitdoc = uar_get_code_by("MEANING",333,"ADMITDOC")
   SET mrn_cd = uar_get_code_by("MEANING",4,"MRN")
   SET ssn_cd = uar_get_code_by("MEANING",4,"SSN")
   SET fin_cd = uar_get_code_by("MEANING",319,"FIN NBR")
   SELECT INTO "NL:"
    FROM code_value cv
    WHERE cv.code_set=72
     AND cv.display_key="NURSINGDISCHARGESTATUSREPORT"
     AND cv.active_ind=1
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(disch->list,cnt), disch->list[cnt].cd = cv.code_value
    FOOT REPORT
     disch->qual = cnt
    WITH nocounter
   ;end select
   FREE RECORD pat
   RECORD pat(
     1 person_id = f8
     1 event_qual = i4
     1 list[*]
       2 parent_event_id = f8
   )
   DECLARE blob_size = i4
   DECLARE blob_out_detail = c64000
   DECLARE blob_compressed_trimmed = c64000
   DECLARE blob_uncompressed = c64000
   DECLARE blob_rtf = c64000
   DECLARE blob_out_detail = c64000
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
     CALL uar_rtf2(blob_uncompressed,blob_return_len,blob_rtf,size(blob_rtf),blob_return_len2,
      1)
     SET blob_out_detail = blob_rtf
     SET blob_compressed = fillstring(64000," ")
     SET blob_compressed_trimmed = fillstring(64000," ")
   END ;Subroutine
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(disch->qual)),
     clinical_event ce,
     scd_story s
    PLAN (ce
     WHERE ce.encntr_id=encntr_to_search
      AND ce.event_end_dt_tm BETWEEN cnvtdatetime(beg_dt_tm) AND cnvtdatetime(end_dt_tm)
      AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (d
     WHERE (disch->list[d.seq].cd=ce.event_cd))
     JOIN (s
     WHERE s.encounter_id=ce.encntr_id
      AND s.event_id=ce.parent_event_id
      AND s.story_completion_status_cd=signed_cd)
    ORDER BY ce.parent_event_id, ce.event_id
    HEAD REPORT
     event_cnt = 0
    HEAD ce.parent_event_id
     event_cnt = (event_cnt+ 1), stat = alterlist(pat->list,event_cnt), pat->list[event_cnt].
     parent_event_id = ce.parent_event_id
    DETAIL
     x = 0
    FOOT REPORT
     pat->event_qual = event_cnt
    WITH nocounter
   ;end select
   FOR (agc = 1 TO pat->event_qual)
     SELECT INTO value(printer_name)
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
      event_tag = substring(1,50,ce.event_tag), event_title_text = substring(1,110,ce
       .event_title_text), event_id = ce.event_id,
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
       WHERE outerjoin(p.person_id)=pa.person_id
        AND pa.person_alias_type_cd=outerjoin(mrn_cd)
        AND pa.active_ind=outerjoin(1))
       JOIN (ea
       WHERE outerjoin(e.encntr_id)=ea.encntr_id
        AND ea.encntr_alias_type_cd=outerjoin(fin_cd)
        AND ea.active_ind=outerjoin(1))
       JOIN (epr
       WHERE outerjoin(e.encntr_id)=epr.encntr_id
        AND epr.encntr_prsnl_r_cd=outerjoin(admitdoc)
        AND epr.active_ind=outerjoin(1))
       JOIN (pl
       WHERE outerjoin(epr.prsnl_person_id)=pl.person_id)
      ORDER BY ce.event_end_dt_tm, ceb.event_id
      HEAD REPORT
       xcol = 25, ycol = 75, name_disp = fillstring(10," "),
       name_disp = build(trim(name)), auth_disp_line = fillstring(110," "), mrn_disp = concat(trim(
         mrn_pool),char(58),char(32),trim(mrn)),
       age_disp = concat("Age:",char(32),trim(age)), sex_disp = concat("Sex:",char(32),trim(sex)),
       fac_disp = build(trim(facility)),
       line1 = fillstring(84,"_"), line2 = fillstring(31,"_"), instr_data = fillstring(300," ")
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
        ycol = 120,
        CALL print(calcpos(xcol,ycol)), "{f/4}{cpi/10}",
        ycol = (ycol+ 12)
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
       print_disp = fillstring(95," "),
       CALL uncompress_blob(ceb.blob_contents,ceb.blob_length), blob_test1 = replace(blob_out_detail,
        char(10),"|",0),
       eol = size(trim(blob_test1,1),1), delimiter = findstring(char(124),blob_test1)
       WHILE (delimiter > 0)
         IF (blob_test1="*TX_RTF32 9.0.310.500*")
          blob_test2 = concat(trim(substring(25,(delimiter - 1),blob_test1)))
         ELSE
          blob_test2 = concat(trim(substring(1,(delimiter - 1),blob_test1)))
         ENDIF
         print_size = size(trim(blob_test2),1)
         IF (print_size > 95)
          bseg = 1, eseg = 1
          WHILE (eseg <= print_size)
            bseg = eseg, eseg = (eseg+ 95)
            IF (findstring(" ",substring(bseg,(eseg - bseg),blob_test2)) > 0)
             WHILE (substring((eseg - 1),1,blob_test2) != " "
              AND eseg != bseg)
               eseg = (eseg - 1)
             ENDWHILE
             print_disp = concat(trim(substring(1,eseg,substring(bseg,(eseg - bseg),blob_test2))))
            ELSE
             print_disp = concat(trim(substring(1,eseg,substring(bseg,(eseg - bseg),blob_test2))))
            ENDIF
            xcol = 55,
            CALL print(calcpos(xcol,ycol)), print_disp,
            row + 1, ycol = (ycol+ 12)
            IF (ycol > 650)
             BREAK
            ENDIF
          ENDWHILE
         ELSE
          print_disp = concat(trim(blob_test2)), xcol = 55,
          CALL print(calcpos(xcol,ycol)),
          print_disp, row + 1, ycol = (ycol+ 12)
          IF (ycol > 650)
           BREAK
          ENDIF
         ENDIF
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
       "{cpi/12}{pos/260/687}", "{b/8}Patient: ", "{pos/295/687}",
       name, xxx = concat(trim(unit)," / ",trim(room)," / ",trim(bed)), "{pos/440/687}",
       "{b/10}Location: ", xxx, row + 1,
       "{pos/260/698}", "{b/5}Acct #: ", finnbr,
       row + 1, "{pos/440/698}", "{b/3}ADM: ",
       admit_dt, row + 1, "{pos/260/709}",
       "{b/7}", mrn_disp, row + 1,
       "{pos/370/709}", "{b/3}", age_disp,
       "{pos/440/709}", "{b/3}", sex_disp,
       row + 1, "{pos/260/720}", "{b/11}Admitting MD: ",
       admitdoc, row + 1, "{pos/440/731}",
       "{b/6}Page # ", curpage, row + 1,
       "{cpi/10}{pos/55/693}{b}", facility, row + 1,
       "{cpi/10}{pos/55/708}{b}", "Nursing Discharge Status Report",
       "{f/8}{cpi/15}{lpi/10}{pos/55/720}",
       "BHS_NURSE_DISCH", "{f/4}{cpi/12}{pos/55/732}{b/8}Printed: ", curdate,
       "  ", curtime, "{endb}",
       row + 1
      FOOT REPORT
       CALL print(calcpos(239,674)), "{b}", "****  END OF REPORT  ****",
       "{endb}"
      WITH maxrow = 750, maxcol = 800, dio = postscript,
       nullreport
     ;end select
   ENDFOR
 ENDFOR
END GO
