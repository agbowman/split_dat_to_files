CREATE PROGRAM ccl_uar_test:dba
 PROMPT
  "Enter output device: " = mine,
  "Enter uar name: " = "ALL"
  WITH outdev, uarname
 IF (validate(uar_debug,0))
  SET trace = showuar
  SET trace = showuarpar
  SET trace = showuarpar2
 ENDIF
 DECLARE _line = vc
 DECLARE _uarname = vc
 DECLARE inbuffer = vc
 SET _line = fillstring(100,"=")
 SET _uarname = cnvtupper( $UARNAME)
 IF (_uarname="ALL")
  CALL echo(uar_get_version(0))
  CALL test_uar_get_code_by(0)
  CALL echo(_line)
  CALL test_uar_get_meaning_by_codeset(1)
  CALL echo(_line)
  CALL test_uar_get_code_list_by(0)
  CALL echo(_line)
  CALL echo("i18n_test_uar begin... locale and date formats for current day.")
  EXECUTE i18n_test_uar
  CALL test_uar_i18nalphabet(0)
  CALL echo(_line)
  CALL echo("uar_sort* begin... output file= uar_sorttest.dat")
  SELECT INTO "uar_sorttest.dat"
   l.long_text_id, x = fillstring(1000,"x"), l.*
   FROM long_text l
   ORDER BY l.long_text_id, 0
   WITH nocounter, maxqual(l,10), memsort
  ;end select
  CALL echo(_line)
  CALL echo("uar_sys* begin...")
  CALL test_uar_sys(0)
  CALL test_uar_rtf("noforms")
  CALL test_uar_rtf2(1)
  CALL test_uar_rtf2_strike(1)
  GO TO exit_script
 ENDIF
 IF (_uarname="UAR_GET_CODE_BY")
  CALL test_uar_get_code_by(0)
 ELSEIF (_uarname="UAR_GET_CODE_LIST_BY")
  CALL test_uar_get_code_list_by(0)
 ELSEIF (_uarname="UAR_GET_CODE")
  EXECUTE ccl_uar_codetest  $1, 48, 0,
  "UAR"
 ELSEIF (_uarname="UAR_GET_MEANING_BY_CODESET")
  CALL test_uar_get_meaning_by_codeset(1)
 ELSEIF (_uarname="UAR_OCI")
  EXECUTE ccl_uar_codetest  $1, 0, 0,
  "UAR_OCI"
 ELSEIF (_uarname="UAR_I18N")
  CALL echo(_line)
  CALL echo("i18n_test_uar begin... locale and date formats for current day.")
  EXECUTE i18n_test_uar
  CALL echo(_line)
  DECLARE hi18n = i4 WITH protect, noconstant(0)
  SET stat = uar_i18nlocalizationinit(hi18n,curprog,"",curcclrev)
  CALL echo(build("hI18n= ",hi18n))
  CALL echo("Test uar_i18nbuildmessage() with 4 params..")
  SET i18n_msg = uar_i18nbuildmessage(hi18n,"Enc_1","encounter","")
  CALL echo(build("i18n_msg= ",i18n_msg))
  CALL echo("Test uar_i18nbuildmessage() with 10 params..")
  DECLARE encounternumber = vc WITH constant("12345678")
  DECLARE sourceaccountnumber = vc WITH constant("11115555")
  DECLARE sourceaccountdescription = vc WITH constant("Source Account Desc")
  DECLARE targetaccountnumber = vc WITH constant("55559999")
  DECLARE targetaccountdescription = vc WITH constant("Target Account Desc")
  DECLARE i18ndesc = vc
  SET i18ndesc = uar_i18nbuildmessage(hi18n,curprog,
   "Account %1 (%2) combined into Account %3 (%4). (%5,%6)","ssssss",nullterm(
    sourceaccountnumber),
   nullterm(sourceaccountdescription),nullterm(targetaccountnumber),nullterm(targetaccountdescription
    ),"test9","test10")
  CALL echo(build("i18nDesc= ",i18ndesc))
 ELSEIF (_uarname="UAR_I18NALPHABET")
  CALL test_uar_i18nalphabet(0)
 ELSEIF (_uarname="UAR_REF_TASK")
  CALL test_uar_ref_task(1)
 ELSEIF (_uarname="UAR_RTF")
  CALL test_uar_rtf("uar_rtftest.dat")
 ELSEIF (_uarname="UAR_RTF2")
  CALL test_uar_rtf2(1)
  CALL test_uar_rtf2_strike(1)
 ELSEIF (_uarname="UAR_RTF2PS")
  CALL test_uar_rtf2ps(0)
 ELSEIF (_uarname="UAR_RTFCNVT")
  CALL echo("UAR_RTFCNVT not yet supported..")
 ELSEIF (_uarname="UAR_SYS")
  CALL test_uar_sys(0)
 ELSEIF (_uarname="UAR_SEND_MAIL")
  CALL echo(_line)
  CALL echo("uar_send_mail begin...")
  DECLARE msgpriority = i4
  DECLARE _qual = vc
  DECLARE sendto = vc
  DECLARE sender = vc
  DECLARE subject = vc
  DECLARE messagetext = vc
  SET msgpriority = 5
  SET sender = "Discern_Expert@cerner.com"
  SET subject = "Test uar_send_mail"
  SET messagetext = concat("Email sent at: ",format(cnvtdatetime(curdate,curtime3),";;q"))
  SET msgclass = "IPM.NOTE"
  IF ((reqinfo->updt_id > 0))
   SET _qual = " p.person_id = reqinfo->updt_id"
  ELSE
   SET _qual = " p.username = CURUSER"
  ENDIF
  SELECT INTO "NL:"
   p.email
   FROM prsnl p
   WHERE parser(_qual)
   DETAIL
    sendto = trim(p.email)
   WITH nocounter
  ;end select
  IF (textlen(sendto) > 1)
   CALL uar_send_mail(nullterm(sendto),nullterm(subject),nullterm(messagetext),nullterm(sender),
    msgpriority,
    nullterm(msgclass))
  ELSE
   CALL echo("A valid e-mail address is required for uar_send_mail")
  ENDIF
 ELSEIF (_uarname="UAR_SORT")
  CALL echo("Test memsort with uar_sort calls... ")
  SELECT INTO  $1
   l.long_text_id, x = fillstring(1000,"x"), l.*
   FROM long_text l
   ORDER BY l.long_text_id, 0
   WITH nocounter, maxqual(l,10), memsort
  ;end select
 ENDIF
 SUBROUTINE test_uar_i18nalphabet(x)
   CALL echo(_line)
   CALL echo("uar_i18n_alphabet...")
   DECLARE next_str = c1 WITH noconstant("")
   DECLARE low_str = c1 WITH noconstant("")
   DECLARE high_str = c1 WITH noconstant("")
   DECLARE sizeof_str = i4
   DECLARE salphachars = vc WITH noconstant(" ")
   DECLARE i18nhandle = i4
   SET i18nhandle = uar_i18nalphabet_init()
   CALL echo(build("i18nHandle= ",i18nhandle," (",reflect(i18nhandle),").."))
   CALL uar_i18nalphabet_lowchar(i18nhandle,low_str,size(low_str))
   CALL uar_i18nalphabet_highchar(i18nhandle,high_str,size(high_str))
   CALL echo(build("uar_i18nalphabet_lowchar: ",low_str))
   CALL echo(build("uar_i18nalphabet_highchar: ",high_str))
   CALL echo("")
   SET next_str = low_str
   WHILE (next_str != high_str)
    CALL uar_i18nalphabet_nextchar(i18nhandle,next_str,size(next_str),next_str,size(next_str))
    SET salphachars = build(salphachars,next_str)
   ENDWHILE
   CALL echo("uar_i18nalphabet_nextchar results:")
   CALL echo(salphachars)
   SET salphachars = " "
   SET next_str = high_str
   WHILE (next_str != low_str)
    CALL uar_i18nalphabet_prevchar(i18nhandle,next_str,size(next_str),next_str,size(next_str))
    SET salphachars = build(salphachars,next_str)
   ENDWHILE
   CALL echo("uar_i18nalphabet_prevtchar results:")
   CALL echo(salphachars)
   DECLARE low_text = c5 WITH noconstant("     ")
   DECLARE high_text = c5 WITH noconstant("     ")
   CALL uar_i18nalphabet_lowletter(i18nhandle,low_text,size(low_text))
   CALL uar_i18nalphabet_highletter(i18nhandle,high_text,size(high_text))
   CALL echo(build("uar_i18nAlphabet_LowLetter: ",low_text))
   CALL echo(build("uar_i18nalphabet_HighLetter: ",high_text))
   CALL echo("")
   SET low_text = "     "
   SET high_text = "     "
   CALL uar_i18nalphabet_lowalnum(i18nhandle,low_text,size(low_text))
   CALL uar_i18nalphabet_highalnum(i18nhandle,high_text,size(high_text))
   CALL echo(build("uar_i18nAlphabet_LowAlNum: ",low_text))
   CALL echo(build("uar_i18nalphabet_HighAlNum: ",high_text))
   CALL echo("")
   CALL uar_i18nalphabet_end(i18nhandle)
 END ;Subroutine
 SUBROUTINE test_uar_get_code_by(x)
   CALL echo(_line)
   CALL echo("uar_get_code* begin...")
   DECLARE code_set = i4
   DECLARE code_value = f8
   DECLARE cdf_meaning = c12
   DECLARE uniquedisplaykey = vc WITH noconstant("BLOODPRESSURE")
   SET _crlf = concat(char(13),char(10))
   CALL echo("Test uar_get_code_by for CS 72,200 using OCI queries..")
   SET code_value = uar_get_code_by("DISPLAYKEY",72,"HEIGHT")
   CALL echo(build("CS 72: HEIGHT= ",code_value))
   SET code_value = uar_get_code_by("DISPLAYKEY",200,"VITALSIGNS")
   CALL echo(build("CS 200: VITALSIGNS= ",code_value))
   SET codevalue = uar_get_code_by("DISPLAYKEY",200,"BADEVENTSET")
   CALL echo(build("  Test with INVALID DisplayKey= BADEVENTSET, code= ",build(codevalue)))
   SET codevalue = uar_get_code_by("DISPLAYKEY",200,nullterm(uniquedisplaykey))
   IF (codevalue < 0)
    SELECT INTO "nl:"
     c.display, c.display_key
     FROM code_value c
     WHERE c.code_set=200
      AND c.display_key="BLOODPRESSURE*"
      AND c.active_ind=1
     DETAIL
      uniquedisplay = c.display, uniquedisplaykey = c.display_key
     WITH nocounter, maxqual(c,1)
    ;end select
    SET codevalue = uar_get_code_by("DISPLAYKEY",200,nullterm(uniquedisplaykey))
   ENDIF
   IF (codevalue > 0)
    CALL echo(build("  Test with VALID DisplayKey= ",uniquedisplaykey,", code= ",build(codevalue)))
   ENDIF
   CALL echo(_line)
   CALL echo(concat("Code set: 200",", Code value: ",build(code_value)))
   CALL echo(concat("   CDF_MEANING= ",build(uar_get_code_meaning(code_value))))
   CALL echo(concat("   DISPLAY= ",build(uar_get_code_display(code_value))))
   CALL echo(concat("   DISPLAYKEY= ",build(uar_get_displaykey(code_value))))
   CALL echo(concat("   DEFINITION= ",build(uar_get_definition(code_value))))
   CALL echo(concat("   CKI=  ",build(uar_get_code_cki(code_value))))
   CALL echo(concat("   CONCEPT_CKI=  ",build(uar_get_conceptcki(code_value))))
   SET code_value = uar_get_code_by("DISPLAYKEY",4000601,"CPMSCRIPTREPORT")
   CALL echo(concat("Code set: 4000601",", Code value: ",build(code_value)))
   CALL echo(concat("   CDF_MEANING= ",build(uar_get_code_meaning(code_value))))
   CALL echo(concat("   DISPLAY= ",build(uar_get_code_display(code_value))))
   CALL echo(concat("   DISPLAYKEY= ",build(uar_get_displaykey(code_value))))
   CALL echo(concat("   DEFINITION= ",build(uar_get_definition(code_value))))
   CALL echo(concat("   CKI=  ",build(uar_get_code_cki(code_value))))
   CALL echo(concat("   CONCEPT_CKI=  ",build(uar_get_conceptcki(code_value))))
   SET code_value = uar_get_code_by("meaning",48,"ACTIVE")
   CALL echo(build("uar_get_code_by for lowercase 'meaning'. Code= ",code_value))
   CALL echo(concat("Uar_get_collation_seq.. code value: ",build(code_value),", collation_seq: ",
     build(uar_get_collation_seq(code_value))))
   SET code_value = uar_get_code_by("CONCEPTCKI",4003,"CERNER!ABfQJgD4st77Y4o6n4waeg")
   CALL echo(concat("Code from CONCEPTCKI= ",build(code_value)))
   SET code_value = uar_get_code_by("CONCEPTCKI",4003,"CERNER!ABfQJgD4st77Y4bQn4waeg")
   CALL echo(concat("Code from CONCEPTCKI= ",build(code_value)))
 END ;Subroutine
 SUBROUTINE test_uar_get_code_list_by(x)
   DECLARE occuridx = i4
   DECLARE strcdfconcept1 = vc
   DECLARE strcdfconcept2 = vc
   SET startidx = 1
   SET occuridx = 1
   SET remaingidx = 0
   SET tmpcd = 0.0
   SET strcdfconcept1 = "CERNER!AfxL7AEMY9rGt4AACr0MCQ"
   SET intcodeset = 48
   CALL echo(build("uar_get_code_list_by_conceptcki(), CS= 48, conceptCKI= ",strcdfconcept1))
   SET iret = uar_get_code_list_by_conceptcki(intcodeset,nullterm(strcdfconcept1),startidx,occuridx,
    remaingidx,
    tmpcd)
   CALL echo(build("iRet:  ",iret,"   tmpCD:  ",tmpcd))
   SET strcdfconcept2 = "CERNER!C2C1D38C-A171-4FC7-AAA3-A312DB32E32E"
   SET intcodeset = 200
   CALL echo(build("uar_get_code_list_by_conceptcki(), CS= 200, conceptCKI= ",strcdfconcept2))
   SET iret = uar_get_code_list_by_conceptcki(intcodeset,nullterm(strcdfconcept2),startidx,occuridx,
    remaingidx,
    tmpcd)
   CALL echo(build("iRet:  ",iret,"   tmpCD:  ",tmpcd))
   CALL echo(fillstring(50,"="))
   FREE RECORD cv
   RECORD cv(
     1 cvlist[*]
       2 cv = f8
   ) WITH protect
   FREE RECORD temp_code
   RECORD temp_code(
     1 codes[*]
       2 cv = f8
   ) WITH protect
   DECLARE iremaining = i4 WITH protect, noconstant(0)
   DECLARE dcodevalue = f8 WITH protect, noconstant(0.0)
   DECLARE icv_cnt = i4 WITH protect, noconstant(1)
   DECLARE mlcounter = i4 WITH protect, noconstant(0)
   DECLARE mltotalremaining = i4 WITH protect, noconstant(0)
   DECLARE mlstartindex = i4 WITH protect, noconstant(1)
   DECLARE mloccurrences = i4 WITH protect, noconstant(2)
   DECLARE mlstructsize = i4 WITH protect, noconstant(0)
   DECLARE cs14002 = i4 WITH constant(14002)
   CALL uar_get_meaning_by_codeset(14002,"REVENUE",icv_cnt,dcodevalue)
   SET stat = memalloc(mdcodelist,icv_cnt,"f8")
   CALL echo("uar_get_code_list_by_meaning() with code array, CS= 14002, Meaning= REVENUE")
   CALL uar_get_code_list_by_meaning(14002,"REVENUE",mlstartindex,mloccurrences,mltotalremaining,
    mdcodelist)
   SET mlstructsize = (mloccurrences+ mltotalremaining)
   CALL echo(concat("mlStructSize=",build(mlstructsize),", mlOccurrences= ",build(mloccurrences),
     ", mlTotalRemaining= ",
     build(mltotalremaining)))
   SET stat = alterlist(temp_code->codes,mlstructsize)
   FOR (mlcounter = 1 TO mloccurrences)
     SET temp_code->codes[mlcounter].cv = mdcodelist[mlcounter]
   ENDFOR
   IF (mltotalremaining > 0)
    SET mlstartindex = (mloccurrences+ 1)
    SET mloccurrences = mltotalremaining
    SET stat = memrealloc(mdcodelist,mloccurrences,"f8")
    CALL uar_get_code_list_by_meaning(14002,"REVENUE",mlstartindex,mloccurrences,mltotalremaining,
     mdcodelist)
    FOR (mlcounter = mlstartindex TO mlstructsize)
      SET temp_code->codes[mlcounter].cv = mdcodelist[(mlcounter - (mlstartindex - 1))]
    ENDFOR
   ENDIF
   CALL echo(concat("Size temp_code->codes= ",build(size(temp_code->codes,5))))
   CALL echorecord(temp_code)
   SET stat = memfree(mdcodelist)
 END ;Subroutine
 SUBROUTINE test_uar_get_meaning_by_codeset(x)
   CALL echo("uar_get_meaning_by_codeset begin...")
   DECLARE code_value2 = f8
   DECLARE cdf_meaning = c12
   SET cdf_meaning = "ACTIVE"
   SET stat = uar_get_meaning_by_codeset(48,nullterm(cdf_meaning),1,code_value2)
   CALL echo(concat("Code set=48, cdf_meaning= ",cdf_meaning,", code= ",build(code_value2)))
   DECLARE cdf_meaning2 = c12
   SET cdf_meaning2 = fillstring(12," ")
   SET code_set = 14002
   DECLARE iret = i4
   DECLARE cvct2 = i4
   DECLARE cvidx = i4
   SET cdf_meaning2 = "REVENUE"
   SET code_value = 0.0
   SET cvct = 1
   CALL echo(build("uar_get_meaning_by_codeset: code_set= ",code_set,", meaning= ",cdf_meaning2))
   SET iret = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning2),cvct,code_value)
   IF (iret=0)
    CALL echo(build("   uar_get_meaning_by_codeset success, cvCt= ",cvct,", code value #1= ",build(
       code_value)))
   ELSE
    CALL echo("ERROR! uar_get_meaning_by_codeset failed!")
   ENDIF
   IF (cvct > 1)
    FOR (cvct2 = 2 TO cvct)
      SET cvidx = cvct2
      SET iret = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning2),cvidx,code_value)
      IF (iret=0)
       CALL echo(concat("   uar success, code value= ",build(code_value)))
      ELSE
       CALL echo("ERROR! uar_get_meaning_by_codeset failed!")
      ENDIF
    ENDFOR
    CALL echo(build("   code count= ",cvct))
   ENDIF
 END ;Subroutine
 SUBROUTINE test_uar_ref_task(x)
   CALL echo("uar_get_ref_task_by_ctf..")
   DECLARE ref_task_id1 = f8 WITH constant(uar_get_ref_task_by_ctf(1)), protect
   DECLARE ref_task_id2 = f8 WITH constant(uar_get_ref_task_by_ctf(2)), protect
   SET ref_task_id3 = uar_get_ref_task_by_ctf(3)
   CALL echo(build("ref_task_id1= ",ref_task_id1))
   CALL echo(build("ref_task_id2= ",ref_task_id2))
   CALL echo(build("ref_task_id3= ",ref_task_id3))
   CALL echo("Query ORDER_TASK table..")
   SELECT INTO "noforms"
    ot.reference_task_id, ot.active_ind, desc = substring(1,20,ot.task_description)
    FROM order_task ot
    WHERE ot.reference_task_id IN (ref_task_id1, ref_task_id2, ref_task_id3)
    WITH format, separator = " "
   ;end select
   CALL echo("uar_get_default_ref_task..")
   DECLARE task_activity_cd = f8
   DECLARE task_type_cd = f8
   CALL uar_get_meaning_by_codeset(6026,nullterm("LAB"),1,task_type_cd)
   CALL uar_get_meaning_by_codeset(6027,nullterm("REVIEW RESUL"),1,task_activity_cd)
   CALL echo(build("CS 6026 task_type_cd (LAB)= ",task_type_cd))
   CALL echo(build("CS 6027 activity_type_cd (REVIEW RESUL)= ",task_activity_cd))
   SET reference_task_id = uar_get_default_ref_task(task_type_cd,task_activity_cd)
   CALL echo(build("reference_task_id= ",reference_task_id))
 END ;Subroutine
 SUBROUTINE test_uar_rtf(outdev)
   CALL echo(_line)
   CALL echo(build("uar_rtf* begin... output to: ",outdev))
   SELECT INTO value(outdev)
    longtext = trim(l.long_text)
    FROM long_text l
    WHERE l.parent_entity_name="REF_TEXT"
    HEAD REPORT
     col 0,
     CALL print("Query= select l.long_text from long_text l"), row + 1,
     col 0,
     CALL print('where l.parent_entity_name="REF_TEXT" with maxrec=10'), row + 2,
     SUBROUTINE cclrtf_print(par_flag,par_startcol,par_numcol,par_blob,par_bloblen,par_check)
       m_output_buffer_len = 0, blob_out = fillstring(32768," "), blob_buf = fillstring(200," "),
       blob_len = 0, m_linefeed = concat(char(10)), textindex = 0,
       numcol = par_numcol, whiteflag = 0,
       CALL uar_rtf(par_blob,par_bloblen,blob_out,size(blob_out),m_output_buffer_len,par_flag),
       m_output_buffer_len = minval(m_output_buffer_len,size(trim(blob_out)))
       IF (m_output_buffer_len > 0)
        m_cc = 1
        WHILE (m_cc > 0)
         m_cc2 = findstring(m_linefeed,blob_out,m_cc),
         IF (m_cc2)
          blob_len = (m_cc2 - m_cc)
          IF (blob_len <= par_numcol)
           m_blob_buf = substring(m_cc,blob_len,blob_out), col par_startcol
           IF (par_check)
            CALL print(trim(check(m_blob_buf)))
           ELSE
            CALL print(trim(m_blob_buf))
           ENDIF
           row + 1
          ELSE
           m_blobbuf = substring(m_cc,blob_len,blob_out),
           CALL cclrtf_printline(par_startcol,par_numcol,m_blobbuf,blob_len,par_check), row + 1
          ENDIF
          IF (m_cc2 >= m_output_buffer_len)
           m_cc = 0
          ELSE
           m_cc = (m_cc2+ 1)
          ENDIF
         ELSE
          blob_len = ((m_output_buffer_len - m_cc)+ 1), m_blobbuf = substring(m_cc,blob_len,blob_out),
          CALL cclrtf_printline(par_startcol,par_numcol,m_blobbuf,blob_len,par_check),
          m_cc = 0
         ENDIF
        ENDWHILE
       ENDIF
     END ;Subroutine report
     ,
     SUBROUTINE cclrtf_printline(par_startcol,par_numcol,blob_out,blob_len,par_check)
       textindex = 0, numcol = par_numcol, whiteflag = 0,
       lastline = 0, m_linefeed = concat(char(10)), m_maxchar = concat(char(128)),
       m_find = 0
       WHILE (blob_len > 0)
         IF (blob_len <= par_numcol)
          numcol = blob_len, lastline = 1
         ENDIF
         textindex = (m_cc+ par_numcol)
         IF (lastline=0)
          whiteflag = 0
          WHILE (whiteflag=0)
           IF (((substring(textindex,1,blob_out)=" ") OR (substring(textindex,1,blob_out)=m_linefeed
           )) )
            whiteflag = 1
           ELSE
            textindex = (textindex - 1)
           ENDIF
           ,
           IF (((textindex=m_cc) OR (textindex=0)) )
            textindex = (m_cc+ par_numcol), whiteflag = 1
           ENDIF
          ENDWHILE
          numcol = ((textindex - m_cc)+ 1)
         ENDIF
         m_blob_buf = substring(m_cc,numcol,blob_out)
         IF (m_blob_buf > " ")
          col par_startcol
          IF (par_check)
           CALL print(trim(check(m_blob_buf)))
          ELSE
           CALL print(trim(m_blob_buf))
          ENDIF
          row + 1
         ELSE
          blob_len = 0
         ENDIF
         m_cc = (m_cc+ numcol)
         IF (blob_len > numcol)
          blob_len = (blob_len - numcol)
         ELSE
          blob_len = 0
         ENDIF
       ENDWHILE
     END ;Subroutine report
    DETAIL
     col 0,
     CALL cclrtf_print(0,1,100,longtext,500,1), row + 1
    WITH maxqual(l,10), format = variable
   ;end select
 END ;Subroutine
 SUBROUTINE test_uar_rtf2(parsemode)
   CALL echo(_line)
   DECLARE outbuf = c32768
   DECLARE outbuflen = i4
   IF (((parsemode < 0) OR (parsemode > 1)) )
    CALL echoec(build("test_rtf2 invalid parse mode: ",parsemode))
    RETURN
   ENDIF
   CALL echo(build("test uar_rtf2() parseMode= ",parsemode))
   SELECT INTO  $1
    l.long_text_id, l.long_text, l.parent_entity_name
    FROM long_text l
    WHERE l.parent_entity_name="WP_TEMPLATE_TEXT"
    HEAD REPORT
     col 0,
     CALL print('Querying LONG_TEXT table parent_entity_name="WP_TEMPLATE_TEXT"'), row + 2
    DETAIL
     prt_line = fillstring(100," "), outbuf = " ", stat = uar_rtf2(l.long_text,size(trim(l.long_text)
       ),outbuf,size(outbuf),outbuflen,
      parsemode),
     col 0, l.long_text_id, row + 1,
     col 15, "OutBufLen= ", col 30,
     outbuflen, row + 1, prt_line = substring(1,120,outbuf),
     col 5, prt_line, row + 1
    WITH maxrec = 10
   ;end select
 END ;Subroutine
 SUBROUTINE test_uar_rtf2_strike(parsemode)
   CALL echo(_line)
   CALL echo(build("test uar_rtf2() for strikethrough text: parseMode= ",parsemode))
   DECLARE sline = vc WITH constant(fillstring(100,"-"))
   DECLARE inbuffer = vc
   DECLARE inbuffer2 = vc
   DECLARE inbuflen = i4
   DECLARE outbufsize = i4 WITH constant(10000)
   DECLARE outbuffer = c10000 WITH noconstant("")
   DECLARE outbuflen = i4
   SET outbuflen = outbufsize
   DECLARE retbuflen = i4 WITH noconstant(0)
   SET inbuffer = concat(
    "{\rtf1\ansi\ansicpg1252\uc1\deff0{\fonttbl {\f1\fswiss\fcharset0\fprq2 Arial;}}  ",
    " {\colortbl;\red255\green0\blue0;\red0\green0\blue0;} {\*\generator TX_RTF32 18.0.541.501;} ",
    " {\*\background{\shp{\*\shpinst\shpleft0\shptop0\shpright0\shpbottom0\shpfhdr0\shpbxmargin\shpbxignore",
    "\shpbymargin\shpbyignore\shpwr0\shpwrk0\shpfblwtxt1\shplid1025{\sp{\sn shapeType}{\sv 1}}{\sp{\sn fFlipH}{\sv 0}}",
    "{\sp{\sn \fFlipV}{\sv 0}}{\sp{\sn fillColor}{\sv 16777215}}{\sp{\sn fFilled}{\sv 1}}{\sp{\sn lineWidth}{\sv 0}}",
    "{\sp{\sn fLine}{\sv 0}}{\sp{\sn fBackground}{\sv 1}}{\sp{\sn fLayoutInCell}{\sv 1}}}}}",
    "\sectd  \headery720\footery720\pgwsxn15000\pghsxn15840\marglsxn1440\margtsxn1440\margrsxn1440\margbsxn1440\pgbrdropt32\pard",
    "\itap0\nowidctlpar\plain\f1\fs20\strike\cf1{\txfielddef{\*\txfieldstart\txfieldtype0\txfieldflags131\txfielddata d469a1f3}",
    "{\*\txfieldtext Additional appt Made by CHN","\par\par Cerner Test: 4/11/16 @ 3:15 PM",
    "\par\plain\f1\fs20\b\strike\cf1 WHQ Clinic\plain\f1\fs20\strike\cf1\par 2800 Rockcreek Pkwy\parKC, MO",
    "\par\par\plain\f1\fs20\b\strike\cf1 PH-415-355-7500\plain\f1\fs20\b\cf2\par {\*\txfieldend}}Additional appt Made by CHN",
    "\par\par Cerner Test: 4/11/16 @ 3:15 PM\par\plain\f1\fs20\b\strike\cf1 WHQ Clinic",
    "\plain\f1\fs20\strike\cf1\par 2800 Rockcreek Pkwy\parKC, MO",
    "\par\par\plain\f1\fs20\b\strike\cf1 PH-415-355-7500\plain\f1\fs20\b\cf2\par }\pard\itap0\nowidctlpar\par }"
    )
   CALL echo("RTF to parse..")
   CALL echo(inbuffer)
   SET inbuflen = size(inbuffer)
   CALL echo("invoke uar_rtf2..")
   CALL echo(uar_rtf2(inbuffer,inbuflen,outbuffer,outbuflen,retbuflen,
     parsemode))
   CALL echo(build("uar_rtf output: retbuflen= ",retbuflen,", output..."))
   CALL echo(trim(outbuffer))
   IF (retbuflen=0
    AND textlen(trim(outbuffer))=0)
    CALL echo("...RTF strikeout text removed.")
   ENDIF
   CALL echo(sline)
 END ;Subroutine
 SUBROUTINE test_uar_rtfcnvt(rtfrecipient)
   CALL echo(_line)
   DECLARE hc = i4
   DECLARE status = i4
   DECLARE pgwidth = i4
   DECLARE cnvtto = i4
   IF ((content->recipients[rtfrecipient].type != "PRINTER"))
    CALL errormessage(e_unk_device,concat(cnvtstring(rtfrecipient),"^",content->recipients[
      rtfrecipient].type))
    SET content->status = "F"
    SET content->recipients[rtfrecipient].status = "F"
   ELSE
    IF ((content->recipients[rtfrecipient].address > " "))
     CALL writemessage(nop,concat("Sending message to ",content->recipients[rtfrecipient].address))
     SELECT INTO value(content->recipients[rtfrecipient].address)
      d.*
      FROM (dummyt d  WITH seq = 1)
      HEAD REPORT
       hc = 0, pgwidth = 8, status = 0,
       cnvtto = 0
      DETAIL
       IF (findstring(char(0),content->message))
        content->message = replace(content->message,char(0),char(1),0)
       ENDIF
       CALL uar_rtfcnvt_init(hc,pgwidth,status)
       IF (status=0
        AND hc != 0)
        CALL echo("status = 0 and hc!= 0",1,0),
        CALL echo(content->message,1,0),
        CALL uar_rtfcnvt_put(hc,nullterm(content->message),status)
        IF (status=0)
         CALL echo("put status = 0",1,0),
         CALL uar_rtfcnvt_convert(hc,cnvtto,status)
         IF (status=0)
          CALL echo("convert status = 0",1,0)
          WHILE (status=0)
            os = fillstring(3000," "),
            CALL uar_rtfcnvt_get(hc,os,status),
            CALL print(trim(os)),
            row + 1
          ENDWHILE
          CALL echo(concat("row = ",build(row)),1,0)
         ELSE
          CALL errormessage(e_rtf_status,concat("uar_RtfCnvt_Convert^",cnvtstring(status)))
         ENDIF
        ELSE
         CALL errormessage(e_rtf_status,concat("uar_RtfCnvt_Put^",cnvtstring(status)))
        ENDIF
       ELSE
        CALL errormessage(e_inv_handle,concat("uar_RtfCnvt_Int^",cnvtstring(status)))
       ENDIF
       CALL uar_rtfcnvt_term(hc,status)
      WITH nocounter, dio = "POSTSCRIPT", maxcol = 3000
     ;end select
     SET content->recipients[rtfrecipient].status = "S"
    ELSE
     CALL errormessage(e_no_printer,content->recipients[rtfrecipient].name)
     SET content->recipients[rtfrecipient].status = "F"
     SET content->recipients[rtfrecipient].address = "Unknown printer"
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE test_uar_rtf2ps(p1)
   CALL echo(_line)
   DECLARE srtffile = vc
   DECLARE spsfile = vc
   DECLARE srtftext = vc
   SET srtftext = concat(
    "{\rtf1\ansi\ansicpg1252\deff0\deflang1033\deflangfe1033{\fonttbl{\f0\fswiss\fprq2\fcharset0 Arial;}}",
    "{\*\generator Msftedit 5.41.21.2510;}\viewkind4\uc1\pard\nowidctlpar\b\f0\fs20 Line1\b0 : Test uar_rtf2 \par\b",
    "Line2\b0 : support backslash and \{brackets\}, [Begin backslash]\\\\[End backslash]\par\b Line3\b0 ",
    ': use uar_rtf3 to strip image data and other limitations of uar_rtf2\par\par Test rtf with "embedded quotes"',
    " and \ldblquote tagged quotes\rdblquote  and \{begin backslash\}\\\\\{end backslash\}\par\par\par}"
    )
   SET srtffile = "uar_rtf2ps.dat"
   SET spsfile = "uar_rtf2ps.ps"
   SELECT INTO value(srtffile)
    FROM dummyt d
    DETAIL
     srtftext
    WITH nocounter, maxcol = 32000
   ;end select
   SET hstat = uar_rtf2ps(nullterm(srtffile),nullterm(spsfile))
   CALL echo(build("uar_rtf2ps stat= ",hstat,", PS file= ",spsfile))
 END ;Subroutine
 SUBROUTINE test_uar_sys(p1)
   DECLARE log_handle = i4
   SET log_handle = 0
   SET log_status = 0
   SET log_event = "CCLUAR"
   SET log_level = 2
   SET log_message = "ccl_uar_test: Testing uar_sys message logging"
   CALL uar_syscreatehandle(log_handle,log_status)
   CALL uar_sysevent(log_handle,log_level,nullterm(log_event),nullterm(log_message))
   CALL uar_sysdestroyhandle(log_handle)
   CALL echo(concat("  msgview event logged: ",log_message))
 END ;Subroutine
#exit_script
END GO
