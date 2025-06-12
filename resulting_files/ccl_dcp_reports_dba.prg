CREATE PROGRAM ccl_dcp_reports:dba
 PROMPT
  "Send To:" = "MINE",
  "DCP Reports" = "",
  "Person Search:" = 0,
  "From:" = "SYSDATE",
  "To:" = "SYSDATE",
  "Visit" = 0,
  "Personnel" = 0,
  "Doc Type:" = 1
  WITH outdev, dcpreports, persons,
  encntrfromdt, encntrtodt, enctr,
  prsnl, doctype
 RECORD scannerrequest(
   1 source = gvc
 )
 RECORD scannerreply(
   1 token[*]
     2 value = vc
     2 isliteral = i4
     2 iscomment = i4
 )
 RECORD mainrequest(
   1 output_device = vc
   1 script_name = vc
   1 person_cnt = i4
   1 person[*]
     2 person_id = f8
   1 visit_cnt = i4
   1 visit[*]
     2 encntr_id = f8
   1 prsnl_cnt = i4
   1 prsnl[*]
     2 prsnl_id = f8
   1 nv_cnt = i4
   1 nv[*]
     2 pvc_name = vc
     2 pvc_value = vc
   1 batch_selection = vc
 )
 DECLARE _pagebreak(dummy) = null WITH public
 DECLARE _initializereport(dummy) = null WITH public
 DECLARE _hreport = i4 WITH noconstant(0), public
 DECLARE hrtf = i4 WITH noconstant(0), protect
 DECLARE stat = i4 WITH noconstant(0), protect
 DECLARE pg = i4 WITH noconstant(0), protect
 DECLARE cont = i4 WITH noconstant(0), protect
 DECLARE nstop = i4 WITH noconstant(0), protect
 DECLARE par = f8 WITH noconstant(1.0), protect
 DECLARE parnum = i4 WITH noconstant(0), protect
 DECLARE reportname = vc WITH protect
 DECLARE reporttype = vc WITH protect
 DECLARE ctype = c20 WITH protect
 DECLARE tokenlistsize = i4 WITH private
 DECLARE index = i4 WITH private
 DECLARE findindex = i4 WITH protect
 DECLARE executereportind = i4 WITH noconstant(false), protect
 DECLARE foundatind = i4 WITH noconstant(false), protect
 SET stat = alterlist(mainrequest->nv,2)
 SET mainrequest->nv[1].pvc_name = "BEG_DT_TM"
 SET mainrequest->nv[1].pvc_value = format(cnvtdatetime( $ENCNTRFROMDT),"YYYYMMDDHHMMSS00;;Q")
 SET mainrequest->nv[2].pvc_name = "END_DT_TM"
 SET mainrequest->nv[2].pvc_value = format(cnvtdatetime( $ENCNTRTODT),"YYYYMMDDHHMMSS00;;Q")
 SET mainrequest->nv_cnt = 2
 SET ctype = reflect(parameter(3,0))
 IF (substring(1,1,ctype)="L")
  SET nstop = cnvtint(substring(2,19,ctype))
 ELSE
  SET nstop = 1
 ENDIF
 WHILE (parnum < nstop)
   SET parnum += 1
   SET par = parameter(3,parnum)
   CALL echo(par)
   IF (par > 0.0)
    SET stat = alterlist(mainrequest->person,parnum)
    SET mainrequest->person[parnum].person_id = par
    SET mainrequest->person_cnt = parnum
   ENDIF
   CALL echo(reflect( $3))
 ENDWHILE
 SET parnum = 0
 SET ctype = reflect(parameter(6,0))
 IF (substring(1,1,ctype)="L")
  SET nstop = cnvtint(substring(2,19,ctype))
 ELSE
  SET nstop = 1
 ENDIF
 WHILE (parnum < nstop)
   SET parnum += 1
   SET par = parameter(6,parnum)
   CALL echo(par)
   IF (par > 0.0)
    SET stat = alterlist(mainrequest->visit,parnum)
    SET mainrequest->visit[parnum].encntr_id = par
    SET mainrequest->visit_cnt = parnum
   ENDIF
   CALL echo(reflect( $6))
 ENDWHILE
 SET parnum = 0
 SET ctype = reflect(parameter(7,0))
 IF (substring(1,1,ctype)="L")
  SET nstop = cnvtint(substring(2,19,ctype))
 ELSE
  SET nstop = 1
 ENDIF
 WHILE (parnum < nstop)
   SET parnum += 1
   SET par = parameter(7,parnum)
   CALL echo(par)
   IF (par > 0.0)
    SET stat = alterlist(mainrequest->prsnl,parnum)
    SET mainrequest->prsnl[parnum].prsnl_id = par
    SET mainrequest->prsnl_cnt = parnum
   ENDIF
   CALL echo(reflect( $7))
 ENDWHILE
 SET mainrequest->output_device =  $OUTDEV
 SET reportname = ""
 SET reporttype = ""
 SET scannerrequest->source =  $DCPREPORTS
 EXECUTE ccl_tokenscanner  WITH replace("REQUEST","SCANNERREQUEST"), replace("REPLY","SCANNERREPLY")
 SET tokenlistsize = size(scannerreply->token,5)
 FOR (index = 1 TO tokenlistsize)
  IF (tokenlistsize=1)
   SET reportname = scannerreply->token[index].value
   SET executereportind = true
  ELSEIF ((scannerreply->token[index].value=","))
   SET executereportind = true
  ELSEIF ((scannerreply->token[index].value != '"')
   AND (scannerreply->token[index].value != "'")
   AND (scannerreply->token[index].value != "^")
   AND (scannerreply->token[index].value != "~"))
   IF ((scannerreply->token[index].value="@"))
    SET foundatind = true
   ELSE
    IF (foundatind=false)
     SET reportname = scannerreply->token[index].value
    ELSE
     SET reporttype = trim(cnvtupper(scannerreply->token[index].value))
     SET foundatind = false
    ENDIF
    IF (index=tokenlistsize)
     SET executereportind = true
    ENDIF
   ENDIF
  ENDIF
  IF (executereportind)
   SET executereportind = 0
   FREE RECORD request
   RECORD request(
     1 output_device = vc
     1 script_name = vc
     1 person_cnt = i4
     1 person[*]
       2 person_id = f8
     1 visit_cnt = i4
     1 visit[*]
       2 encntr_id = f8
     1 prsnl_cnt = i4
     1 prsnl[*]
       2 prsnl_id = f8
     1 nv_cnt = i4
     1 nv[*]
       2 pvc_name = vc
       2 pvc_value = vc
     1 batch_selection = vc
   )
   FREE RECORD reply
   RECORD reply(
     1 text = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c15
         3 operationstatus = c1
         3 targetobjectname = c15
         3 targetobjectvalue = c100
     1 large_text_qual[*]
       2 text_segment = vc
   )
   SET request->script_name = reportname
   SET request->output_device = mainrequest->output_device
   SET stat = alterlist(request->nv,mainrequest->nv_cnt)
   SET request->nv[1].pvc_name = mainrequest->nv[1].pvc_name
   SET request->nv[1].pvc_value = mainrequest->nv[1].pvc_value
   SET request->nv[2].pvc_name = mainrequest->nv[2].pvc_name
   SET request->nv[2].pvc_value = mainrequest->nv[2].pvc_value
   SET request->nv_cnt = mainrequest->nv_cnt
   IF (((reporttype="PERSON") OR (reporttype="")) )
    SET request->person_cnt = mainrequest->person_cnt
    SET stat = alterlist(request->person,mainrequest->person_cnt)
    FOR (i = 1 TO mainrequest->person_cnt)
     SET request->person[i].person_id = mainrequest->person[i].person_id
     CALL echo(request->person[i].person_id)
    ENDFOR
   ENDIF
   IF (((reporttype="VISIT") OR (reporttype="")) )
    SET request->visit_cnt = mainrequest->visit_cnt
    SET stat = alterlist(request->visit,mainrequest->visit_cnt)
    FOR (i = 1 TO mainrequest->visit_cnt)
     SET request->visit[i].encntr_id = mainrequest->visit[i].encntr_id
     CALL echo(request->visit[i].encntr_id)
    ENDFOR
   ENDIF
   IF (((reporttype="PRSNL") OR (reporttype="")) )
    SET request->prsnl_cnt = mainrequest->prsnl_cnt
    SET stat = alterlist(request->prsnl,mainrequest->prsnl_cnt)
    FOR (i = 1 TO mainrequest->prsnl_cnt)
     SET request->prsnl[i].prsnl_id = mainrequest->prsnl[i].prsnl_id
     CALL echo(request->prsnl[i].prsnl_id)
    ENDFOR
   ENDIF
   CALL parser(concat("execute ",value(request->script_name)," go"))
   SET modify = nopredeclare
   IF (textlen(reply->text) > 0)
    IF (findstring("{\rtf1",reply->text) > 0
     AND  $DOCTYPE)
     CALL _initializereport( $DOCTYPE)
     SET hrtf = uar_rptcreatertf(_hreport,nullterm(reply->text),8.0)
     SET cont = 6
     SET pg = 0
     WHILE (cont=6)
       SET pg += 1
       SET cont = uar_rptrtfdraw(_hreport,hrtf,0.250,0.250,10.5)
       CALL echo(cont)
       IF (cont=6)
        SET stat = uar_rptendpage(_hreport)
        SET stat = uar_rptstartpage(_hreport)
       ENDIF
     ENDWHILE
     SET stat = uar_rptdestroyrtf(_hreport,hrtf)
     EXECUTE cpm_create_file_name "CCL", "RTF"
     CALL _finalizereport(value(cpm_cfn_info->file_name_full_path))
     SET spool value(cpm_cfn_info->file_name_full_path) value(request->output_device) WITH deleted
    ELSE
     CALL echo(reply->text)
     FREE RECORD putreq
     RECORD putreq(
       1 source_dir = vc
       1 source_filename = vc
       1 nbrlines = i4
       1 line[*]
         2 linedata = vc
       1 overflowpage[*]
         2 ofr_qual[*]
           3 ofr_line = vc
       1 isblob = c1
       1 document_size = i4
       1 document = gvc
     )
     SET putreq->document = reply->text
     IF (size(putreq->document) > 0)
      SET putreq->source_filename = request->output_device
      SET putreq->isblob = "1"
      SET putreq->document_size = size(putreq->document)
      FREE RECORD putreply
      EXECUTE eks_put_source  WITH replace("REQUEST","PUTREQ"), replace("REPLY","PUTREPLY")
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDFOR
 SUBROUTINE _pagebreak(dummy)
  SET _rptpage = uar_rptendpage(_hreport)
  SET _rptpage = uar_rptstartpage(_hreport)
 END ;Subroutine
 SUBROUTINE (_finalizereport(fileout=vc) =null WITH public)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptstat = uar_rptendreport(_hreport)
   SET _rptstat = uar_rptprinttofile(_hreport,nullterm(value(fileout)))
   SET _rptstat = uar_rptdestroyreport(_hreport)
 END ;Subroutine
 SUBROUTINE _initializereport(devid)
   SET rptreport->m_recsize = 84
   SET rptreport->m_pagewidth = 8.500000
   SET rptreport->m_pageheight = 11.000000
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.000000
   SET rptreport->m_marginright = 0.000000
   SET rptreport->m_margintop = 0.000000
   SET rptreport->m_marginbottom = 0.000000
   SET rptreport->m_reportname = "ccl_dcp_reports"
   SET _hreport = uar_rptcreatereport(rptreport,devid,rpt_inches)
   SET _rptstat = uar_rptstartreport(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
 END ;Subroutine
END GO
