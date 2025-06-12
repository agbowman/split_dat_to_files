CREATE PROGRAM ccl_uarx_test:dba
 PROMPT
  "Enter output device: " = "MINE",
  "Enter uar name: (ALL) " = "ALL",
  "Enter # iterations " = 1
 IF (validate(uar_debug))
  SET trace = showuar
  SET trace = showuarpar
  SET trace = showuarpar2
 ENDIF
 SET crlf = concat(char(13),char(10))
 SET _separator = fillstring(100,"=")
 SET _uarname = cnvtupper( $2)
 SET _iterations =  $3
 IF (_uarname="PERF")
  DECLARE uar_is_in_eventset(p1=vc(ref),p2=f8(ref),p3=i4(ref),p4=i4(ref)) = i4 WITH persist
  CALL test_uar_is_in_eventset(_iterations)
 ENDIF
 IF (_uarname="ALL")
  CALL echo(_separator)
  CALL echo("cnvtage2 begin with default policy...")
  CALL echo(cnvtage2(cnvtdatetime((curdate - 1),curtime2)))
  CALL echo(cnvtage2(cnvtdatetime((curdate - 7),curtime2)))
  CALL echo(cnvtage2(cnvtdatetime((curdate - 10),curtime2)))
  CALL echo(cnvtage2(cnvtdatetime((curdate - 30),curtime2)))
  CALL echo(cnvtage2(cnvtdatetime((curdate - 365),curtime2)))
  CALL echo("cnvtage2 begin for GESTAGE policy...")
  CALL echo(cnvtage2(cnvtdatetime((curdate - 1),curtime2),"gestage"))
  CALL echo(cnvtage2(cnvtdatetime((curdate - 7),curtime2),"gestage"))
  CALL echo(cnvtage2(cnvtdatetime((curdate - 10),curtime2),"gestage"))
  CALL echo(cnvtage2(cnvtdatetime((curdate - 30),curtime2),"gestage"))
  CALL echo(cnvtage2(cnvtdatetime((curdate - 365),curtime2),"gestage"))
  CALL echo(_separator)
  CALL echo("uar_crm_* begin...")
  DECLARE app = i4
  DECLARE task = i4
  DECLARE happ = i4
  DECLARE htask = i4
  DECLARE hreq = i4
  SET app = 4800
  SET task = 4800
  SET crmstatus = uar_crmbeginapp(app,happ)
  CALL echo(concat("UarCrmBegin_App success, app: ",build(app)))
  SET crmstatus = uar_crmbegintask(happ,task,htask)
  CALL echo(concat("Uar_CrmBeginTask success, task: ",build(task)))
  CALL uar_crmendtask(htask)
  CALL echo(concat("Uar_CrmEnd_Task success"))
  CALL uar_crmendapp(happ)
  CALL echo(concat("Uar_Crm_End_App success"))
  CALL echo(_separator)
  CALL test_uar_fmt(0)
  CALL echo(_separator)
  CALL echo("uar_get_tdbname begin...")
  CALL echo(concat("  Req: 3050002= ",uar_get_tdbname(3050001)))
  CALL echo(concat("  Req: 3051000= ",uar_get_tdbname(3051000)))
  CALL echo(concat("  Req: 3072006= ",uar_get_tdbname(3072006)))
  CALL echo("uar_get_tdb begin...")
  DECLARE progname = c41
  SET progname = "CCL*"
  DECLARE servername = c41
  CALL uar_get_tdb(3050002,progname,servername)
  CALL echo(concat("  Req: 3050002, Program= ",progname,", Server= ",servername))
  CALL uar_get_tdb(3051000,progname,servername)
  CALL echo(concat("  Req: 3051000, Program= ",progname,", Server= ",servername))
  CALL uar_get_tdb(3072006,progname,servername)
  CALL echo(concat("  Req: 3072006, Program= ",progname,", Server= ",servername))
  CALL echo(_separator)
  CALL test_uar_is_in_eventset(1)
  CALL test_uar_ocf(1)
  CALL test_uar_xml(1)
  CALL echo("uar_uuidtest begin...")
  EXECUTE ccl_uuidtest 1
 ENDIF
 IF (_uarname="UAR_GET_TDB")
  DECLARE progname = c41
  SET progname = "CCL*"
  DECLARE servername = c41
  SELECT INTO  $1
   tdb = uar_get_tdb(r.request_number,progname,servername)"#", cclsize = d.binary_cnt, prog_name =
   cnvtupper(substring(1,30,progname)),
   server_name = substring(1,30,servername), r.request_number, t.task_number,
   cclver = d.ccl_version"###"
   FROM request r,
    task_request_r t,
    dprotect d
   PLAN (r
    WHERE r.request_number BETWEEN 3000000 AND 3100000
     AND r.active_ind=1)
    JOIN (t
    WHERE r.request_number=t.request_number)
    JOIN (d
    WHERE 0=d.group
     AND "P"=d.object
     AND cnvtupper(progname)=d.object_name)
   ORDER BY prog_name
   WITH nocounter
  ;end select
 ELSEIF (_uarname="UAR_NORMALIZE_STRING")
  DECLARE outstr = vc
  DECLARE trimstr = vc
  SET buflen = 1000
  SET outstr = fillstring(1000," ")
  SET wcard = " "
  SET wcard2 = ""
  SET wcount = 0
  SET tempstr = fillstring(1000," ")
  SELECT INTO  $1
   n.nomenclature_id, n.source_string, n.string_identifier
   FROM nomenclature n
   PLAN (n
    WHERE n.source_string_keycap="WARFARIN*")
   HEAD REPORT
    _outstr = ""
   DETAIL
    tempstr = trim(n.source_string),
    CALL uar_normalize_string(nullterm(tempstr),outstr,nullterm(wcard2),buflen,wcount), trimstr =
    trim(outstr,3),
    col 0, "Count= ", col 10,
    trimstr, row + 1
   WITH nocounter, maxrec = 10
  ;end select
 ELSEIF (_uarname="UAR_OCF_UNCOMPRESS")
  CALL test_uar_ocf_uncompress(0)
 ELSEIF (_uarname="UAR_XML")
  CALL test_uar_xml(1)
 ELSEIF (_uarname="UAR_FMT")
  CALL test_uar_fmt(0)
 ELSEIF (_uarname="UAR_OCF")
  CALL test_uar_ocf(1)
 ENDIF
 SUBROUTINE test_uar_ocf(x)
   CALL echo("uar_ocf_compress/uncompress/compare...")
   SET datatocompress = concat("Uar_ocf_compress/uar_ocf_uncompress have been moved ",
    "to shrccluarx/libshrccluarx image")
   CALL echo(concat("  Text len: ",build(textlen(datatocompress))))
   CALL echo(concat("  Text to compress: ",datatocompress))
   SET outbuffer = fillstring(255," ")
   DECLARE inlen = h
   SET inlen = size(datatocompress)
   DECLARE outlen = h
   SET outlen = 0
   DECLARE bufferlen = h
   SET bufferlen = size(outbuffer)
   DECLARE iret = h
   SET iret = uar_ocf_compress(datatocompress,inlen,outbuffer,bufferlen,outlen)
   CALL echo(concat("  uar_ocf_compress status= ",build(iret),", Compressed size= ",build(outlen)))
   SET iret = uar_ocf_compare(outbuffer,bufferlen,datatocompress,inlen)
   CALL echo(concat("  uar_ocf_compare (match) return - Expected: 0 Actual: ",build(iret)))
   SET wrongdatatocompare = concat(datatocompress," EXTRA TEXT")
   CALL echo(concat("  Mismatched text to compare: ",wrongdatatocompare))
   DECLARE wrongdatalen = h
   SET wrongdatalen = size(wrongdatatocompare)
   SET iret = uar_ocf_compare(outbuffer,bufferlen,wrongdatatocompare,wrongdatalen)
   CALL echo(concat("  uar_ocf_compare (mismatch) return - Expected: ",build(inlen)," Actual: ",build
     (iret)))
   SET uncompressed = fillstring(255," ")
   SET inlen = outlen
   SET iret = uar_ocf_uncompress(outbuffer,inlen,uncompressed,bufferlen,outlen)
   CALL echo(concat("  uar_ocf_uncompress status= ",build(iret),", Original text len= ",build(outlen)
     ))
   CALL echo(concat("  Original text: ",substring(1,outlen,uncompressed)))
   CALL echo(_separator)
 END ;Subroutine
 SUBROUTINE (test_uar_ocf_uncompress(p1=i4) =null)
   CALL echo(_separator)
   CALL echo("_uar_ocf_uncompress test...")
   SET blobout = fillstring(32768," ")
   SET blobnortf = fillstring(32768," ")
   SET bsize = 0
   DECLARE compress_cd = f8
   SET compress_cd = uar_get_code_by("MEANING",120,"OCFCOMP")
   CALL echo(build("compress_cd= ",compress_cd))
   SELECT INTO "noforms"
    c.compression_cd, c_compression_disp = uar_get_code_display(c.compression_cd), c.blob_seq_num,
    c.blob_length, c.blob_contents, c.valid_from_dt_tm,
    c.valid_until_dt_tm, bloblen = textlen(c.blob_contents), ce_event_disp = uar_get_code_display(ce
     .event_cd),
    ce_event_class_disp = uar_get_code_display(ce.event_class_cd), ce.person_id, ce.event_start_dt_tm,
    ce_catalog_disp = uar_get_code_display(ce.catalog_cd), ce.clinsig_updt_dt_tm
    FROM ce_blob c,
     dummyt d1,
     clinical_event ce
    PLAN (c
     WHERE c.compression_cd=compress_cd)
     JOIN (ce
     WHERE ce.event_id=c.event_id)
     JOIN (d1
     WHERE assign(blobout,fillstring(32768," "))
      AND uar_ocf_uncompress(c.blob_contents,size(c.blob_contents),blobout,size(blobout),32768) >= 0)
    HEAD REPORT
     row 1, col 2, "OCF compress test",
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
            textindex -= 1
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
         m_cc += numcol
         IF (blob_len > numcol)
          blob_len -= numcol
         ELSE
          blob_len = 0
         ENDIF
       ENDWHILE
     END ;Subroutine report
     , row + 2
    HEAD PAGE
     col 2, "Blob length:", col 17,
     "Blob data:", row + 2
    DETAIL
     IF (((row+ 2) >= maxrow))
      BREAK
     ENDIF
     col 2, c.blob_length, stat = uar_rtf2(blobout,size(blobout),blobnortf,size(blobnortf),bsize,
      0),
     CALL cclrtf_print(0,17,100,blobnortf,500,1), row + 1, line1 = fillstring(126,"-"),
     col 3, line1, row + 1
    WITH maxqual(c,10), noheading, format = variable
   ;end select
 END ;Subroutine
 SUBROUTINE (test_uar_is_in_eventset(nloops=i4) =null)
   CALL echo(_separator)
   CALL echo("uar_is_in_eventset begin...")
   SET event_set1 = "CLINICALHEIGHT"
   SET event_set2 = "VITAL SIGNS"
   SET event_code1 = "HEIGHT"
   SET event_code2 = "WEIGHT"
   SET event_code3 = "BADEVENTCODE"
   SET event_set_cd = uar_get_code_by("DISPLAY_KEY",93,nullterm(event_set1))
   SET event_set_cd2 = uar_get_code_by("DISPLAY_KEY",93,nullterm(event_set1))
   CALL echo(concat("Event set#1: ",event_set1,", event_set_cd: ",build(event_set_cd)))
   CALL echo(concat("Event set#2: ",event_set2,", event_set_cd2: ",build(event_set_cd2)))
   SET event_cd1 = uar_get_code_by("DISPLAY_KEY",72,nullterm(event_code1))
   SET event_cd2 = uar_get_code_by("DISPLAY_KEY",72,nullterm(event_code2))
   SET event_cd3 = 9999999.0
   CALL echo(concat("Event code#1: ",event_code1,", event_cd1: ",build(event_cd1)))
   CALL echo(concat("Event code#2: ",event_code1,", event_cd2: ",build(event_cd2)))
   FOR (i = 1 TO nloops)
     CALL echo(build("Loop#",i))
     SET mem_ind = 0
     SET stat = uar_is_in_eventset(nullterm(event_set1),event_cd1,mem_ind,1)
     CALL echo(concat("  Stat= ",build(stat),", mem_ind=",build(mem_ind)," uar_is_in_eventset(",
       event_set1,",",build(event_cd1),", 0,1)"))
     SET mem_ind = 0
     SET _event_name = build(char(6),event_set_cd)
     SET stat = uar_is_in_eventset(nullterm(_event_name),event_cd1,mem_ind,1)
     CALL echo(concat("  Stat= ",build(stat),", mem_ind=",build(mem_ind)," uar_is_in_eventset(",
       _event_name,",",build(event_cd1),", 0,1)"))
     SET mem_ind = 0
     SET stat = uar_is_in_eventset(nullterm(event_set2),event_cd2,mem_ind,1)
     CALL echo(concat("  Stat= ",build(stat),", mem_ind=",build(mem_ind)," uar_is_in_eventset(",
       event_set2,",",build(event_cd2),", 0,1)"))
     SET mem_ind = 0
     SET stat = uar_is_in_eventset(nullterm(event_set2),event_cd3,mem_ind,1)
     CALL echo(concat("  Stat= ",build(stat),", mem_ind=",build(mem_ind)," uar_is_in_eventset(",
       event_set2,",",build(event_cd3),", 0,1)"))
   ENDFOR
   CALL echo(_separator)
 END ;Subroutine
 SUBROUTINE (test_uar_xml(x=i4) =null)
   CALL echo(_separator)
   DECLARE sc_unkstat = i1 WITH constant(0)
   DECLARE sc_ok = i1 WITH constant(1)
   DECLARE sc_parserror = i1 WITH constant(2)
   DECLARE sc_nofile = i1 WITH constant(3)
   DECLARE sc_nonode = i1 WITH constant(4)
   DECLARE sc_noattr = i1 WITH constant(5)
   DECLARE sc_badobjref = i1 WITH constant(6)
   DECLARE sc_invindex = i1 WITH constant(7)
   DECLARE sc_notfound = i1 WITH constant(8)
   DECLARE uar_xml_getroot(filehandle=i4(ref),nodehandle=i4(ref)) = i4
   DECLARE uar_xml_parsestring(xmlstring=vc,filehandle=i4(ref)) = i4
   DECLARE uar_xml_findchildnode(nodehandle=i4(ref),nodename=vc,childhandle=i4(ref)) = i4
   DECLARE hxmlresourcefile = h WITH noconstant(0)
   DECLARE __hservicehealthdata = h
   DECLARE __hservicehealthdata2 = h
   DECLARE __hchild = h
   DECLARE pxmlbuffer = vc WITH noconstant(" ")
   SET pxmlbuffer = concat(
    '<?xml version="1.0" encoding="UTF-8"?><servlet-health><health-item key="domain-validation">',
    "<response-code>1</response-code></health-item></s<person_id>12345.0</person_id>ervlet-health>")
   CALL echo(concat("UAR_XML* testing. XML String= ",pxmlbuffer))
   SET stat = uar_xml_parsestring(nullterm(pxmlbuffer),hxmlresourcefile)
   CALL echo(concat("uar_xml_parsestring stat= ",cnvtstring(stat)))
   DECLARE __hxmlroot = h WITH noconstant(0)
   IF (stat=sc_ok)
    SET stat = uar_xml_getroot(hxmlresourcefile,__hxmlroot)
    IF (stat=sc_ok)
     SET stat2 = uar_xml_findchildnode(__hxmlroot,"servlet-health",__hservicehealthdata)
     CALL echo(build("uar_xml_findchildnode succcss, __hServiceHealthData= ",__hservicehealthdata))
     IF (stat2=sc_ok)
      SET stat2 = uar_xml_findchildnode(__hservicehealthdata,"health-item",__hservicehealthdata2)
      IF (stat2=sc_ok)
       SET childcount = uar_xml_getchildcount(__hservicehealthdata2)
       CALL echo(build("uar_xml_getchildcount count= ",childcount))
       SET attrcount = uar_xml_getattrcount(__hservicehealthdata2)
       CALL echo(build("uar_xml_getattrcount count= ",attrcount))
       FOR (child = 0 TO childcount)
         IF (uar_xml_getchildnode(__hservicehealthdata,child,__hchild)=sc_ok)
          SET snodename = uar_xml_getnodename(__hchild)
          CALL echo(build("uar_xml_getnodename name= ",snodename))
         ENDIF
       ENDFOR
      ENDIF
     ENDIF
    ENDIF
   ELSE
    CALL echo(build("uar_xml_parsestring failed: Status= ",stat))
   ENDIF
 END ;Subroutine
 SUBROUTINE (test_uar_fmt(p1=i4) =null)
   CALL echo(_separator)
   CALL echo("uar_fmt_accession begin... NOTE: DATA VARIES PER DOMAIN")
   SELECT INTO noforms
    pc.accession_nbr, pc_accession_nbr = uar_fmt_accession(pc.accession_nbr,size(pc.accession_nbr,1))
    FROM pathology_case pc
    HEAD REPORT
     row + 1
    DETAIL
     col 0,
     CALL print(pc.accession_nbr), col 25,
     CALL print(pc_accession_nbr), row + 1
    WITH nocounter, maxqual(pc,10)
   ;end select
   CALL echo("uar_fmt_result..")
   RECORD formatted(
     1 result_value = vc
     1 result_value2 = vc
     1 result_value3 = vc
   )
   DECLARE n0 = h WITH constant(0)
   DECLARE n1 = h WITH constant(1)
   DECLARE n2 = h WITH constant(2)
   DECLARE n5 = h WITH constant(5)
   DECLARE n8 = h WITH constant(8)
   SET formatted->result_value = uar_fmt_result(n1,n8,n0,n0,12345678.0)
   SET formatted->result_value2 = uar_fmt_result(n1,n5,n1,n0,12345678.15)
   SET formatted->result_value3 = uar_fmt_result(n1,n5,n2,n0,12345678.155)
   CALL echorecord(formatted)
 END ;Subroutine
END GO
