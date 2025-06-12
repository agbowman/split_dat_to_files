CREATE PROGRAM amb_rln_labcorp_lyt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE reportrtl
 DECLARE test_display_name = vc WITH protect
 DECLARE page_order_counter = i4 WITH protect
 DECLARE all_order_counter = i4 WITH protect
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE query1(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headreportsection(ncalc=i2) = f8 WITH protect
 DECLARE headreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE labcorpacchead(ncalc=i2) = f8 WITH protect
 DECLARE tablerow16(ncalc=i2) = f8 WITH protect
 DECLARE tablerow16abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow17(ncalc=i2) = f8 WITH protect
 DECLARE tablerow17abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow18(ncalc=i2) = f8 WITH protect
 DECLARE tablerow18abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow19(ncalc=i2) = f8 WITH protect
 DECLARE tablerow19abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE labcorpaccheadabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE patclientinfofirst(ncalc=i2) = f8 WITH protect
 DECLARE tablerow5(ncalc=i2) = f8 WITH protect
 DECLARE tablerow5abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow6(ncalc=i2) = f8 WITH protect
 DECLARE tablerow6abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow7(ncalc=i2) = f8 WITH protect
 DECLARE tablerow7abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow8(ncalc=i2) = f8 WITH protect
 DECLARE tablerow8abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow9(ncalc=i2) = f8 WITH protect
 DECLARE tablerow9abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow10(ncalc=i2) = f8 WITH protect
 DECLARE tablerow10abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow11(ncalc=i2) = f8 WITH protect
 DECLARE tablerow11abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow12(ncalc=i2) = f8 WITH protect
 DECLARE tablerow12abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow13(ncalc=i2) = f8 WITH protect
 DECLARE tablerow13abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow14(ncalc=i2) = f8 WITH protect
 DECLARE tablerow14abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow15(ncalc=i2) = f8 WITH protect
 DECLARE tablerow15abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow20(ncalc=i2) = f8 WITH protect
 DECLARE tablerow20abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow24(ncalc=i2) = f8 WITH protect
 DECLARE tablerow24abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE patclientinfofirstabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE patientinforemaining(ncalc=i2) = f8 WITH protect
 DECLARE tablerow3(ncalc=i2) = f8 WITH protect
 DECLARE tablerow3abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow46(ncalc=i2) = f8 WITH protect
 DECLARE tablerow46abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow47(ncalc=i2) = f8 WITH protect
 DECLARE tablerow47abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE patientinforemainingabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE dxcodesreq(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE tablerow21(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE tablerow21abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE tablerow58(ncalc=i2) = f8 WITH protect
 DECLARE tablerow58abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE dxcodesreqabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE orders(ncalc=i2) = f8 WITH protect
 DECLARE tablerow40(ncalc=i2) = f8 WITH protect
 DECLARE tablerow40abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE ordersabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE orderscontd(ncalc=i2) = f8 WITH protect
 DECLARE tablerow56(ncalc=i2) = f8 WITH protect
 DECLARE tablerow56abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE orderscontdabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE future_ord_msg(ncalc=i2) = f8 WITH protect
 DECLARE future_ord_msgabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE testname(ncalc=i2) = f8 WITH protect
 DECLARE tablerow2(ncalc=i2) = f8 WITH protect
 DECLARE tablerow2abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE testnameabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE specimendetailsbold(ncalc=i2) = f8 WITH protect
 DECLARE tablerow48(ncalc=i2) = f8 WITH protect
 DECLARE tablerow48abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE specimendetailsboldabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE specimendetails(ncalc=i2) = f8 WITH protect
 DECLARE tablerow60(ncalc=i2) = f8 WITH protect
 DECLARE tablerow60abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE specimendetailsabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE specimentypeanddesc(ncalc=i2) = f8 WITH protect
 DECLARE tablerow55(ncalc=i2) = f8 WITH protect
 DECLARE tablerow55abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE specimentypeanddescabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE orderdetailssingle(ncalc=i2) = f8 WITH protect
 DECLARE tablerow23(ncalc=i2) = f8 WITH protect
 DECLARE tablerow23abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE orderdetailssingleabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE orderdetailmulti(ncalc=i2) = f8 WITH protect
 DECLARE tablerow61(ncalc=i2) = f8 WITH protect
 DECLARE tablerow61abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE orderdetailmultiabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE specialinstructions(ncalc=i2) = f8 WITH protect
 DECLARE tablerow39(ncalc=i2) = f8 WITH protect
 DECLARE tablerow39abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE specialinstructionsabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE ordercomment(ncalc=i2) = f8 WITH protect
 DECLARE tablerow27(ncalc=i2) = f8 WITH protect
 DECLARE tablerow27abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE ordercommentabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE orderseperator(ncalc=i2) = f8 WITH protect
 DECLARE orderseperatorabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE insertbreaksectionifspeclabelspresent(ncalc=i2) = f8 WITH protect
 DECLARE insertbreaksectionifspeclabelspresentabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE guarantor(ncalc=i2) = f8 WITH protect
 DECLARE tablerow1(ncalc=i2) = f8 WITH protect
 DECLARE tablerow1abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow4(ncalc=i2) = f8 WITH protect
 DECLARE tablerow4abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow29(ncalc=i2) = f8 WITH protect
 DECLARE tablerow29abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow30(ncalc=i2) = f8 WITH protect
 DECLARE tablerow30abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow31(ncalc=i2) = f8 WITH protect
 DECLARE tablerow31abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow45(ncalc=i2) = f8 WITH protect
 DECLARE tablerow45abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow62(ncalc=i2) = f8 WITH protect
 DECLARE tablerow62abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE guarantorabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE insuranceinformation(ncalc=i2) = f8 WITH protect
 DECLARE tablerow(ncalc=i2) = f8 WITH protect
 DECLARE tablerowabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow28(ncalc=i2) = f8 WITH protect
 DECLARE tablerow28abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow25(ncalc=i2) = f8 WITH protect
 DECLARE tablerow25abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow26(ncalc=i2) = f8 WITH protect
 DECLARE tablerow26abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow33(ncalc=i2) = f8 WITH protect
 DECLARE tablerow33abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow22(ncalc=i2) = f8 WITH protect
 DECLARE tablerow22abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow34(ncalc=i2) = f8 WITH protect
 DECLARE tablerow34abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow35(ncalc=i2) = f8 WITH protect
 DECLARE tablerow35abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow32(ncalc=i2) = f8 WITH protect
 DECLARE tablerow32abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow36(ncalc=i2) = f8 WITH protect
 DECLARE tablerow36abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow37(ncalc=i2) = f8 WITH protect
 DECLARE tablerow37abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow38(ncalc=i2) = f8 WITH protect
 DECLARE tablerow38abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow54(ncalc=i2) = f8 WITH protect
 DECLARE tablerow54abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow44(ncalc=i2) = f8 WITH protect
 DECLARE tablerow44abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow43(ncalc=i2) = f8 WITH protect
 DECLARE tablerow43abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE insuranceinformationabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE authorization(ncalc=i2) = f8 WITH protect
 DECLARE tablerow41(ncalc=i2) = f8 WITH protect
 DECLARE tablerow41abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow42(ncalc=i2) = f8 WITH protect
 DECLARE tablerow42abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE authorizationabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE futureorderwatermark(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE futureorderwatermarkabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE specimenlabels(ncalc=i2) = f8 WITH protect
 DECLARE tablerow51(ncalc=i2) = f8 WITH protect
 DECLARE tablerow51abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow52(ncalc=i2) = f8 WITH protect
 DECLARE tablerow52abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow53(ncalc=i2) = f8 WITH protect
 DECLARE tablerow53abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow63(ncalc=i2) = f8 WITH protect
 DECLARE tablerow63abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow59(ncalc=i2) = f8 WITH protect
 DECLARE tablerow59abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow57(ncalc=i2) = f8 WITH protect
 DECLARE tablerow57abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE specimenlabelsabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE order_dt_tm(ncalc=i2) = f8 WITH protect
 DECLARE order_dt_tmabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _hreport = h WITH noconstant(0), protect
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 DECLARE rpt_render = i2 WITH constant(0), protect
 DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
 DECLARE rpt_calcheight = i2 WITH constant(1), protect
 DECLARE _yshift = f8 WITH noconstant(0.0), protect
 DECLARE _xshift = f8 WITH noconstant(0.0), protect
 DECLARE _sendto = vc WITH noconstant( $OUTDEV), protect
 DECLARE _rpterr = i2 WITH noconstant(0), protect
 DECLARE _rptstat = i2 WITH noconstant(0), protect
 DECLARE _oldfont = i4 WITH noconstant(0), protect
 DECLARE _oldpen = i4 WITH noconstant(0), protect
 DECLARE _dummyfont = i4 WITH noconstant(0), protect
 DECLARE _dummypen = i4 WITH noconstant(0), protect
 DECLARE _fdrawheight = f8 WITH noconstant(0.0), protect
 DECLARE _rptpage = h WITH noconstant(0), protect
 DECLARE _diotype = i2 WITH noconstant(8), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontdxcodesreq = i2 WITH noconstant(0), protect
 DECLARE _bconttablerow21 = i2 WITH noconstant(0), protect
 DECLARE _remdxcodeslistval = i4 WITH noconstant(1), protect
 DECLARE _remwater_mark = i4 WITH noconstant(1), protect
 DECLARE _bcontfutureorderwatermark = i2 WITH noconstant(0), protect
 DECLARE _helvetica90 = i4 WITH noconstant(0), protect
 DECLARE _helvetica12b0 = i4 WITH noconstant(0), protect
 DECLARE _helvetica10b0 = i4 WITH noconstant(0), protect
 DECLARE _helvetica14b0 = i4 WITH noconstant(0), protect
 DECLARE _times90 = i4 WITH noconstant(0), protect
 DECLARE _helvetica14b16777215 = i4 WITH noconstant(0), protect
 DECLARE _helvetica20 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _helvetica6b0 = i4 WITH noconstant(0), protect
 DECLARE _helvetica60 = i4 WITH noconstant(0), protect
 DECLARE _helvetica100 = i4 WITH noconstant(0), protect
 DECLARE _helvetica9b0 = i4 WITH noconstant(0), protect
 DECLARE _times7015395562 = i4 WITH noconstant(0), protect
 DECLARE _helvetica80 = i4 WITH noconstant(0), protect
 DECLARE _pen1s0c16777215 = i4 WITH noconstant(0), protect
 DECLARE _pen14s1c0 = i4 WITH noconstant(0), protect
 DECLARE _pen0s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen13s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 SUBROUTINE query1(dummy)
   SELECT INTO "nl:"
    d.dummy
    FROM (dummyt d1  WITH seq = value(req_data->req_qual[loopvar].ord_cnt)),
     dual d
    PLAN (d1
     WHERE d1.seq > 0)
     JOIN (d)
    ORDER BY d.dummy, d1.seq
    HEAD REPORT
     _d0 = d1.seq, _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom), _fdrawheight
      = headreportsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pageheight - rptreport->m_marginbottom)))
      CALL pagebreak(0)
     ENDIF
     dummy_val = headreportsection(rpt_render), cnt = 0
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
     _bcontfutureorderwatermark = 0, dummy_val = futureorderwatermarkabs(rpt_render,_xoffset,5.000,((
      rptreport->m_pageheight - rptreport->m_marginbottom) - 5.000),_bcontfutureorderwatermark),
     dummy_val = labcorpacchead(rpt_render),
     dummy_val = patclientinfofirst(rpt_render), dummy_val = patientinforemaining(rpt_render),
     _bcontdxcodesreq = 0,
     dummy_val = dxcodesreq(rpt_render,((rptreport->m_pageheight - rptreport->m_marginbottom) -
      _yoffset),_bcontdxcodesreq), dummy_val = orders(rpt_render), dummy_val = orderscontd(rpt_render
      ),
     dummy_val = future_ord_msg(rpt_render)
    HEAD d.dummy
     row + 0
    HEAD d1.seq
     IF ((((req_data->req_qual[loopvar].ord_qual[d1.seq].hna_order_mnemonic=req_data->req_qual[
     loopvar].ord_qual[d1.seq].ordered_as_mnemonic)) OR (size(trim(req_data->req_qual[loopvar].
       ord_qual[d1.seq].ordered_as_mnemonic))=0)) )
      test_display_name = concat(req_data->req_qual[loopvar].ord_qual[d1.seq].outbound_alias,"    ",
       req_data->req_qual[loopvar].ord_qual[d1.seq].hna_order_mnemonic)
     ELSE
      test_display_name = concat(req_data->req_qual[loopvar].ord_qual[d1.seq].outbound_alias,"    ",
       req_data->req_qual[loopvar].ord_qual[d1.seq].hna_order_mnemonic," (",req_data->req_qual[
       loopvar].ord_qual[d1.seq].ordered_as_mnemonic,
       ")")
     ENDIF
     _fdrawheight = testname(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specimendetailsbold(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specimendetails(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specimentypeanddesc(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ orderdetailssingle(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ orderdetailmulti(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specialinstructions(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ ordercomment(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ orderseperator(rpt_calcheight))
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = testname(rpt_render), _fdrawheight = specimendetailsbold(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specimendetails(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specimentypeanddesc(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ orderdetailssingle(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ orderdetailmulti(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specialinstructions(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ ordercomment(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ orderseperator(rpt_calcheight))
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = specimendetailsbold(rpt_render), _fdrawheight = specimendetails(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specimentypeanddesc(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ orderdetailssingle(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ orderdetailmulti(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specialinstructions(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ ordercomment(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ orderseperator(rpt_calcheight))
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = specimendetails(rpt_render), _fdrawheight = specimentypeanddesc(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ orderdetailssingle(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ orderdetailmulti(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specialinstructions(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ ordercomment(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ orderseperator(rpt_calcheight))
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = specimentypeanddesc(rpt_render), number_of_rows = ceil((cnvtreal(req_data->req_qual[
       loopvar].ord_qual[d1.seq].single_cnt)/ 3))
     FOR (ord_row = 1 TO number_of_rows)
       cell_num = (ord_row * 3)
       IF (((cell_num - 2) <= req_data->req_qual[loopvar].ord_qual[d1.seq].single_cnt))
        order_detail->cell1 = concat(req_data->req_qual[loopvar].ord_qual[d1.seq].single_details[(
         cell_num - 2)].label_text,": ",req_data->req_qual[loopvar].ord_qual[d1.seq].single_details[(
         cell_num - 2)].value)
       ELSE
        order_detail->cell1 = ""
       ENDIF
       IF (((cell_num - 1) <= req_data->req_qual[loopvar].ord_qual[d1.seq].single_cnt))
        order_detail->cell2 = concat(req_data->req_qual[loopvar].ord_qual[d1.seq].single_details[(
         cell_num - 1)].label_text,": ",req_data->req_qual[loopvar].ord_qual[d1.seq].single_details[(
         cell_num - 1)].value)
       ELSE
        order_detail->cell2 = ""
       ENDIF
       IF ((cell_num <= req_data->req_qual[loopvar].ord_qual[d1.seq].single_cnt))
        order_detail->cell3 = concat(req_data->req_qual[loopvar].ord_qual[d1.seq].single_details[
         cell_num].label_text,": ",req_data->req_qual[loopvar].ord_qual[d1.seq].single_details[
         cell_num].value)
       ELSE
        order_detail->cell3 = ""
       ENDIF
       _fdrawheight = orderdetailssingle(rpt_calcheight)
       IF (_fdrawheight > 0)
        IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
         _fdrawheight = (_fdrawheight+ orderdetailmulti(rpt_calcheight))
        ENDIF
        IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
         _fdrawheight = (_fdrawheight+ specialinstructions(rpt_calcheight))
        ENDIF
        IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
         _fdrawheight = (_fdrawheight+ ordercomment(rpt_calcheight))
        ENDIF
        IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
         _fdrawheight = (_fdrawheight+ orderseperator(rpt_calcheight))
        ENDIF
       ENDIF
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ENDIF
       dummy_val = orderdetailssingle(rpt_render)
     ENDFOR
     ord_row = 0
     FOR (mulord_row = 1 TO req_data->req_qual[loopvar].ord_qual[d1.seq].detail_cnt)
       IF ((req_data->req_qual[loopvar].ord_qual[d1.seq].details[mulord_row].multi_select=1))
        _fdrawheight = orderdetailmulti(rpt_calcheight)
        IF (_fdrawheight > 0)
         IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
          _fdrawheight = (_fdrawheight+ specialinstructions(rpt_calcheight))
         ENDIF
         IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
          _fdrawheight = (_fdrawheight+ ordercomment(rpt_calcheight))
         ENDIF
         IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
          _fdrawheight = (_fdrawheight+ orderseperator(rpt_calcheight))
         ENDIF
        ENDIF
        IF (((_yoffset+ _fdrawheight) > _fenddetail))
         BREAK
        ENDIF
        dummy_val = orderdetailmulti(rpt_render)
       ENDIF
     ENDFOR
     mulord_row = 0, _fdrawheight = specialinstructions(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ ordercomment(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ orderseperator(rpt_calcheight))
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = specialinstructions(rpt_render), _fdrawheight = ordercomment(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ orderseperator(rpt_calcheight))
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = ordercomment(rpt_render), _fdrawheight = orderseperator(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = orderseperator(rpt_render)
    DETAIL
     row + 0
    FOOT  d1.seq
     page_order_counter = (page_order_counter+ 1), all_order_counter = (all_order_counter+ 1)
     IF ((req_data->print_labcorp_labels_ind=1))
      IF (((curpage=1
       AND page_order_counter=2) OR (((curpage > 1
       AND page_order_counter=9) OR (curpage > 1
       AND page_order_counter > 1
       AND (all_order_counter=req_data->req_qual[loopvar].ord_cnt))) )) )
       page_order_counter = 0, BREAK
      ENDIF
     ENDIF
    FOOT  d.dummy
     _fdrawheight = guarantor(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ insuranceinformation(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ authorization(rpt_calcheight))
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = guarantor(rpt_render), _fdrawheight = insuranceinformation(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ authorization(rpt_calcheight))
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = insuranceinformation(rpt_render), _fdrawheight = authorization(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = authorization(rpt_render)
    FOOT PAGE
     _yhold = _yoffset, _yoffset = _fenddetail, dummy_val = specimenlabelsabs(rpt_render,_xoffset,
      9.606),
     dummy_val = order_dt_tmabs(rpt_render,_xoffset,10.300), _yoffset = _yhold
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE finalizereport(ssendreport)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptstat = uar_rptendreport(_hreport)
   DECLARE sfilename = vc WITH noconstant(trim(ssendreport)), private
   DECLARE bprint = i2 WITH noconstant(0), private
   IF (textlen(sfilename) > 0)
    SET bprint = checkqueue(sfilename)
    IF (bprint)
     EXECUTE cpm_create_file_name "RPT", "PS"
     SET sfilename = cpm_cfn_info->file_name_path
    ENDIF
   ENDIF
   SET _rptstat = uar_rptprinttofile(_hreport,nullterm(sfilename))
   IF (bprint)
    SET spool value(sfilename) value(ssendreport) WITH dio = value(_diotype)
   ENDIF
   DECLARE _errorfound = i2 WITH noconstant(0), protect
   DECLARE _errcnt = i2 WITH noconstant(0), protect
   SET _errorfound = uar_rptfirsterror(_hreport,rpterror)
   WHILE (_errorfound=rpt_errorfound
    AND _errcnt < 512)
     SET _errcnt = (_errcnt+ 1)
     SET stat = alterlist(rpterrors->errors,_errcnt)
     SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
     SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
     SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
     SET _errorfound = uar_rptnexterror(_hreport,rpterror)
   ENDWHILE
   SET _rptstat = uar_rptdestroyreport(_hreport)
 END ;Subroutine
 SUBROUTINE headreportsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headreportsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headreportsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(2.000000), private
   DECLARE __collected = vc WITH noconstant(build2(
     IF ((req_data->req_qual[loopvar].collected_ind=1)) "EREQ"
     ELSE "COR EDI"
     ENDIF
     ,char(0))), protect
   DECLARE __header_alias = vc WITH noconstant(build2(build2(header_alias),char(0))), protect
   DECLARE __barcodetxt = vc WITH noconstant(build2(req_data->req_qual[loopvar].req_control_nbr,char(
      0))), protect
   IF (ncalc=rpt_render)
    SET _rptdummy = uar_rptbarcodeinit(rptbce,rpt_code128,(offsetx+ 2.425),(offsety+ 1.063))
    SET rptbce->m_recsize = 88
    SET rptbce->m_width = 3.25
    SET rptbce->m_height = 0.49
    SET rptbce->m_rotation = 0
    SET rptbce->m_ratio = 300
    SET rptbce->m_barwidth = 1
    SET rptbce->m_bscale = 1
    SET rptbce->m_bprintinterp = 0
    SET rptbce->m_bcheckdigit = 1
    SET rptbce->m_startchar = "*"
    SET rptbce->m_endchar = "*"
    SET _rptstat = uar_rptbarcodeex(_hreport,rptbce,build2(concat("*",req_data->req_qual[loopvar].
       req_control_nbr,"*"),char(0)))
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ - (0.012))
    SET rptsd->m_width = 8.126
    SET rptsd->m_height = 0.251
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica14b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("LabCorp",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.688)
    SET rptsd->m_x = (offsetx+ - (0.012))
    SET rptsd->m_width = 8.126
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Cerner Corporation",char(0)))
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ - (0.012))
    SET rptsd->m_width = 8.126
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__collected)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.750)
    SET rptsd->m_x = (offsetx+ 1.926)
    SET rptsd->m_width = 4.250
    SET rptsd->m_height = 0.209
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__header_alias)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.563)
    SET rptsd->m_x = (offsetx+ 1.926)
    SET rptsd->m_width = 4.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__barcodetxt)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE labcorpacchead(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = labcorpaccheadabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow16(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow16abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow16abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __acctnbrvalue = vc WITH noconstant(build(req_data->req_qual[loopvar].loc_nurse_unit_alias,
     char(0))), protect
   DECLARE __collectiondatelbl = vc WITH noconstant(build(
     IF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=0.00)) "Req Collection Date:"
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm != null)) "Collection Date:"
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm=null)) "Collection Date:"
     ENDIF
     ,char(0))), protect
   DECLARE __collectiondateval = vc WITH noconstant(build(
     IF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=0.00)) concat(format(req_data->
        req_qual[loopvar].ord_qual[d1.seq].collected_dt_tm,"MM/DD/YYYY ;;q")," (estimated)")
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm != null)) format(req_data->
       req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm,"MM/DD/YYYY ;;q")
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm=null)) format(req_data->req_qual[
       loopvar].ord_qual[d1.seq].collected_dt_tm,"MM/DD/YYYY ;;q")
     ENDIF
     ,char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = bor(rpt_sdtopborder,rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdrightborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.355
   SET rptsd->m_height = 0.251
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica12b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Account #:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdtopborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.530)
   SET rptsd->m_width = 3.021
   SET rptsd->m_height = 0.251
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__acctnbrvalue)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdtopborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.550)
   SET rptsd->m_width = 1.376
   SET rptsd->m_height = 0.251
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__collectiondatelbl)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = bor(rpt_sdtopborder,rpt_sdrightborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.925)
   SET rptsd->m_width = 1.917
   SET rptsd->m_height = 0.251
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__collectiondateval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.529),offsety,(offsetx+ 1.529),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.550),offsety,(offsetx+ 4.550),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.925),offsety,(offsetx+ 5.925),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.842),offsety,(offsetx+ 7.842),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.843),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.843),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow17(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow17abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow17abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __collectiontimelbl = vc WITH noconstant(build(
     IF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=0.00)) "Req Collection Time:"
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm != null)) "Collection Time:"
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm=null)) "Collection Time:"
     ENDIF
     ,char(0))), protect
   DECLARE __collectiontimeval = vc WITH noconstant(build(
     IF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=0.00)) concat(format(req_data->
        req_qual[loopvar].ord_qual[d1.seq].collected_dt_tm,"HH:MM;;q")," (estimated)")
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm != null)) format(req_data->
       req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm,"HH:MM;;q")
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm=null)) format(req_data->req_qual[
       loopvar].ord_qual[d1.seq].collected_dt_tm,"HH:MM;;q")
     ENDIF
     ,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.355
   SET rptsd->m_height = 0.251
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.530)
   SET rptsd->m_width = 3.021
   SET rptsd->m_height = 0.251
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.550)
   SET rptsd->m_width = 1.376
   SET rptsd->m_height = 0.251
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__collectiontimelbl)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.925)
   SET rptsd->m_width = 1.917
   SET rptsd->m_height = 0.251
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__collectiontimeval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.529),offsety,(offsetx+ 1.529),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.550),offsety,(offsetx+ 4.550),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.925),offsety,(offsetx+ 5.925),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.842),offsety,(offsetx+ 7.842),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.843),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.843),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow18(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow18abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow18abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __reqctrlidvalue = vc WITH noconstant(build(req_data->req_qual[loopvar].req_control_nbr,
     char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdrightborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.355
   SET rptsd->m_height = 0.251
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica12b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Req/Control #:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.530)
   SET rptsd->m_width = 3.021
   SET rptsd->m_height = 0.251
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__reqctrlidvalue)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.550)
   SET rptsd->m_width = 1.376
   SET rptsd->m_height = 0.251
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.925)
   SET rptsd->m_width = 1.917
   SET rptsd->m_height = 0.251
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.529),offsety,(offsetx+ 1.529),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.550),offsety,(offsetx+ 4.550),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.925),offsety,(offsetx+ 5.925),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.842),offsety,(offsetx+ 7.842),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.843),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.843),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow19(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow19abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow19abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.355
   SET rptsd->m_height = 0.251
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.530)
   SET rptsd->m_width = 3.021
   SET rptsd->m_height = 0.251
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.550)
   SET rptsd->m_width = 1.376
   SET rptsd->m_height = 0.251
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdrightborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.925)
   SET rptsd->m_width = 1.917
   SET rptsd->m_height = 0.251
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.529),offsety,(offsetx+ 1.529),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.550),offsety,(offsetx+ 4.550),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.925),offsety,(offsetx+ 5.925),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.842),offsety,(offsetx+ 7.842),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.843),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.843),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE labcorpaccheadabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.380000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   DECLARE __collected = vc WITH noconstant(build2(
     IF ((req_data->req_qual[loopvar].collected_ind=1)) "EREQ Cerner Corporation"
     ELSE "COR EDI Cerner Corporation"
     ENDIF
     ,char(0))), protect
   IF ( NOT (curpage=1))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.126)
    SET rptsd->m_x = (offsetx+ 6.863)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.238)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica14b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("LabCorp",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.115)
    SET rptsd->m_x = (offsetx+ 1.050)
    SET rptsd->m_width = 0.313
    SET rptsd->m_height = 0.126
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica6b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("TM",char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _yoffset = (offsety+ 0.313)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.313)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow16(rpt_render))
     SET holdheight = (holdheight+ tablerow17(rpt_render))
     SET holdheight = (holdheight+ tablerow18(rpt_render))
     SET holdheight = (holdheight+ tablerow19(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 1.801)
    SET rptsd->m_width = 4.500
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica14b0)
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__collected)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE patclientinfofirst(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = patclientinfofirstabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow5(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow5abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow5abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   SET rptsd->m_flags = 512
   SET rptsd->m_borders = rpt_sdallborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 7.688
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Patient Information:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow6(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow6abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow6abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.192226), private
   DECLARE __patientnameval = vc WITH noconstant(build(req_data->name_full_formatted,char(0))),
   protect
   DECLARE __patientraceval = vc WITH noconstant(build(uar_get_code_display(req_data->race_cd),char(0
      ))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.193
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Patient Name:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.175)
   SET rptsd->m_width = 2.855
   SET rptsd->m_height = 0.193
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientnameval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.030)
   SET rptsd->m_width = 0.834
   SET rptsd->m_height = 0.193
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Race:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.863)
   SET rptsd->m_width = 3.001
   SET rptsd->m_height = 0.193
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientraceval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.175),offsety,(offsetx+ 1.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.029),offsety,(offsetx+ 4.029),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.862),offsety,(offsetx+ 4.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow7(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow7abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow7abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.192226), private
   DECLARE __patientgenderval = vc WITH noconstant(build(uar_get_code_display(req_data->sex_cd),char(
      0))), protect
   DECLARE __patientssnval = vc WITH noconstant(build(req_data->ssn,char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.193
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Patient Gender:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.175)
   SET rptsd->m_width = 2.855
   SET rptsd->m_height = 0.193
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientgenderval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.030)
   SET rptsd->m_width = 0.834
   SET rptsd->m_height = 0.193
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Patient SSN:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.863)
   SET rptsd->m_width = 3.001
   SET rptsd->m_height = 0.193
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientssnval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.175),offsety,(offsetx+ 1.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.029),offsety,(offsetx+ 4.029),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.862),offsety,(offsetx+ 4.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow8(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow8abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow8abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.178047), private
   DECLARE __patientdobval = vc WITH noconstant(build(format(cnvtdatetimeutc(datetimezone(req_data->
        birth_dt_tm,req_data->birth_tz),1),"MM/DD/YYYY;;d"),char(0))), protect
   DECLARE __patientidval = vc WITH noconstant(build(req_data->mrn,char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.179
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Date of Birth:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.175)
   SET rptsd->m_width = 2.855
   SET rptsd->m_height = 0.179
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientdobval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.030)
   SET rptsd->m_width = 0.834
   SET rptsd->m_height = 0.179
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Patient ID:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.863)
   SET rptsd->m_width = 3.001
   SET rptsd->m_height = 0.179
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientidval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.175),offsety,(offsetx+ 1.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.029),offsety,(offsetx+ 4.029),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.862),offsety,(offsetx+ 4.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow9(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow9abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow9abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187501), private
   DECLARE __patientaddrval = vc WITH noconstant(build(req_data->address.street_addr,char(0))),
   protect
   DECLARE __patientphoneval = vc WITH noconstant(build(cnvtphone(req_data->phone.number,req_data->
      phone.format_cd,2),char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Patient Address:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.175)
   SET rptsd->m_width = 2.855
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientaddrval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.030)
   SET rptsd->m_width = 0.834
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Phone:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.863)
   SET rptsd->m_width = 3.001
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientphoneval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.175),offsety,(offsetx+ 1.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.029),offsety,(offsetx+ 4.029),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.862),offsety,(offsetx+ 4.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow10(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow10abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow10abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187501), private
   DECLARE __patientaddrval2 = vc WITH noconstant(build(req_data->address.street_addr2,char(0))),
   protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.175)
   SET rptsd->m_width = 2.855
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientaddrval2)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.030)
   SET rptsd->m_width = 0.834
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.863)
   SET rptsd->m_width = 3.001
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.175),offsety,(offsetx+ 1.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.029),offsety,(offsetx+ 4.029),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.862),offsety,(offsetx+ 4.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow11(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow11abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow11abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187499), private
   DECLARE __patientcitystatezipval = vc WITH noconstant(build(concat(req_data->address.city,", ",
      req_data->address.state," ",req_data->address.zipcode),char(0))), protect
   DECLARE __patientaltidval = vc WITH noconstant(build(req_data->fin,char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("City, State Zip:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdrightborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.175)
   SET rptsd->m_width = 2.855
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientcitystatezipval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.030)
   SET rptsd->m_width = 0.834
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Alt Patient ID:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdrightborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.863)
   SET rptsd->m_width = 3.001
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientaltidval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.175),offsety,(offsetx+ 1.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.029),offsety,(offsetx+ 4.029),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.862),offsety,(offsetx+ 4.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow12(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow12abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow12abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = bor(bor(rpt_sdtopborder,rpt_sdbottomborder),rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 3.823
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Client / Ordering Site Information:",
      char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdallborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.998)
   SET rptsd->m_width = 3.865
   SET rptsd->m_height = 0.250
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Physician Information:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.998),offsety,(offsetx+ 3.998),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow13(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow13abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow13abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   DECLARE __clientnameval = vc WITH noconstant(build(req_data->organization.org_name,char(0))),
   protect
   DECLARE __ordphysnameval = vc WITH noconstant(build(concat(trim(req_data->req_qual[loopvar].
       order_provider.name_last),", ",trim(req_data->req_qual[loopvar].order_provider.name_first)),
     char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 0.938
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Account Name:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.113)
   SET rptsd->m_width = 2.886
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__clientnameval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.998)
   SET rptsd->m_width = 1.928
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Ord Phys (Electronically Signed):",
      char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.925)
   SET rptsd->m_width = 1.938
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ordphysnameval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.112),offsety,(offsetx+ 1.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.998),offsety,(offsetx+ 3.998),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.925),offsety,(offsetx+ 5.925),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow14(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow14abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow14abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   DECLARE __clientstreetaddr1val = vc WITH noconstant(build(req_data->organization.street_addr,char(
      0))), protect
   DECLARE __ordphysnpival = vc WITH noconstant(build(req_data->req_qual[loopvar].order_provider.npi,
     char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 0.938
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Address 1:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.113)
   SET rptsd->m_width = 2.886
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__clientstreetaddr1val)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.998)
   SET rptsd->m_width = 1.928
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("NPI:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.925)
   SET rptsd->m_width = 1.938
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ordphysnpival)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.112),offsety,(offsetx+ 1.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.998),offsety,(offsetx+ 3.998),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.925),offsety,(offsetx+ 5.925),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow15(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow15abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow15abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   DECLARE __clientstreetaddr2val = vc WITH noconstant(build(req_data->organization.street_addr2,char
     (0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 0.938
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Address 2:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.113)
   SET rptsd->m_width = 2.886
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__clientstreetaddr2val)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.998)
   SET rptsd->m_width = 1.928
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.925)
   SET rptsd->m_width = 1.938
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.112),offsety,(offsetx+ 1.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.998),offsety,(offsetx+ 3.998),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.925),offsety,(offsetx+ 5.925),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow20(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow20abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow20abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   DECLARE __clientcitystatezipval = vc WITH noconstant(build(concat(req_data->organization.city,", ",
      req_data->organization.state," ",req_data->organization.zipcode),char(0))), protect
   DECLARE __supphys = vc WITH noconstant(build(req_data->req_qual[loopvar].sup_physician.name_full,
     char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 0.938
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("City, State Zip:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.113)
   SET rptsd->m_width = 2.886
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__clientcitystatezipval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.998)
   SET rptsd->m_width = 1.928
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Sup Phys:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.925)
   SET rptsd->m_width = 1.938
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__supphys)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.112),offsety,(offsetx+ 1.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.998),offsety,(offsetx+ 3.998),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.925),offsety,(offsetx+ 5.925),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow24(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow24abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow24abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187499), private
   DECLARE __clientphoneval = vc WITH noconstant(build(concat("Phone: ",cnvtphone(req_data->
       organization.phone_num,req_data->organization.phone_format_cd,2)," Fax: ",cnvtphone(req_data->
       organization.fax_num,req_data->organization.fax_format_cd,2)),char(0))), protect
   DECLARE __supphysnpi = vc WITH noconstant(build(req_data->req_qual[loopvar].sup_physician.npi,char
     (0))), protect
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 3.823
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__clientphoneval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.998)
   SET rptsd->m_width = 1.928
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("NPI:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdrightborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.925)
   SET rptsd->m_width = 1.938
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__supphysnpi)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.998),offsety,(offsetx+ 3.998),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.925),offsety,(offsetx+ 5.925),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE patclientinfofirstabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(2.790000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT (curpage=1))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _yoffset = (offsety+ 1.375)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 1.375)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow5(rpt_render))
     SET holdheight = (holdheight+ tablerow6(rpt_render))
     SET holdheight = (holdheight+ tablerow7(rpt_render))
     SET holdheight = (holdheight+ tablerow8(rpt_render))
     SET holdheight = (holdheight+ tablerow9(rpt_render))
     SET holdheight = (holdheight+ tablerow10(rpt_render))
     SET holdheight = (holdheight+ tablerow11(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ 0.063)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.063)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow12(rpt_render))
     SET holdheight = (holdheight+ tablerow13(rpt_render))
     SET holdheight = (holdheight+ tablerow14(rpt_render))
     SET holdheight = (holdheight+ tablerow15(rpt_render))
     SET holdheight = (holdheight+ tablerow20(rpt_render))
     SET holdheight = (holdheight+ tablerow24(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE patientinforemaining(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = patientinforemainingabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow3(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow3abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow3abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   DECLARE __accountnumberval = vc WITH noconstant(build(req_data->req_qual[loopvar].
     loc_nurse_unit_alias,char(0))), protect
   DECLARE __patientnameval = vc WITH noconstant(build(req_data->name_full_formatted,char(0))),
   protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Account Number:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.363)
   SET rptsd->m_width = 2.636
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__accountnumberval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.998)
   SET rptsd->m_width = 1.178
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Patient Name:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.175)
   SET rptsd->m_width = 2.698
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientnameval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.363),offsety,(offsetx+ 1.363),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.998),offsety,(offsetx+ 3.998),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.175),offsety,(offsetx+ 5.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.873),offsety,(offsetx+ 7.873),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.874),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.874),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow46(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow46abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow46abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   DECLARE __reqcontrolnumval = vc WITH noconstant(build(req_data->req_qual[loopvar].req_control_nbr,
     char(0))), protect
   DECLARE __patientidval = vc WITH noconstant(build(req_data->mrn,char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Req/Control #:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.363)
   SET rptsd->m_width = 2.636
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__reqcontrolnumval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.998)
   SET rptsd->m_width = 1.178
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Patient ID:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.175)
   SET rptsd->m_width = 2.698
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientidval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.363),offsety,(offsetx+ 1.363),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.998),offsety,(offsetx+ 3.998),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.175),offsety,(offsetx+ 5.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.873),offsety,(offsetx+ 7.873),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.874),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.874),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow47(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow47abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow47abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   DECLARE __specimendateheaderlbl = vc WITH noconstant(build(
     IF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=0.00)) "Req Collection Dt/Tm:"
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm != null)) "Collection Date/Tm:"
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm=null)) "Collection Date/Tm:"
     ENDIF
     ,char(0))), protect
   DECLARE __specimendateval = vc WITH noconstant(build(
     IF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=0.00)) concat(format(req_data->
        req_qual[loopvar].ord_qual[d1.seq].collected_dt_tm,"MM/DD/YYYY HH:MM;;q")," (estimated)")
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm != null)) format(req_data->
       req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm,"MM/DD/YYYY HH:MM;;q")
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm=null)) format(req_data->req_qual[
       loopvar].ord_qual[d1.seq].collected_dt_tm,"MM/DD/YYYY HH:MM;;q")
     ENDIF
     ,char(0))), protect
   DECLARE __altpatientidval = vc WITH noconstant(build(req_data->fin,char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__specimendateheaderlbl)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.363)
   SET rptsd->m_width = 2.636
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__specimendateval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.998)
   SET rptsd->m_width = 1.178
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Alt Patient ID:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.175)
   SET rptsd->m_width = 2.698
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__altpatientidval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.363),offsety,(offsetx+ 1.363),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.998),offsety,(offsetx+ 3.998),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.175),offsety,(offsetx+ 5.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.873),offsety,(offsetx+ 7.873),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.874),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.874),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE patientinforemainingabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.290000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT (curpage > 1))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 6.925)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _yoffset = (offsety+ 0.625)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.625)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow3(rpt_render))
     SET holdheight = (holdheight+ tablerow46(rpt_render))
     SET holdheight = (holdheight+ tablerow47(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE dxcodesreq(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = dxcodesreqabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow21(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow21abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow21abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.208333), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE __dxcodeslistval = vc WITH noconstant(build(concat("Diagnosis Code(s): ",req_data->
      dx_lc_list),char(0))), protect
   IF (bcontinue=0)
    SET _remdxcodeslistval = 1
   ENDIF
   SET rptsd->m_flags = 261
   SET rptsd->m_borders = rpt_sdallborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 7.688
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremdxcodeslistval = _remdxcodeslistval
   IF (_remdxcodeslistval > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdxcodeslistval,((size(
        __dxcodeslistval) - _remdxcodeslistval)+ 1),__dxcodeslistval)))
    SET drawheight_dxcodeslistval = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdxcodeslistval = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdxcodeslistval,((size(__dxcodeslistval
        ) - _remdxcodeslistval)+ 1),__dxcodeslistval)))))
     SET _remdxcodeslistval = (_remdxcodeslistval+ rptsd->m_drawlength)
    ELSE
     SET _remdxcodeslistval = 0
    ENDIF
    SET growsum = (growsum+ _remdxcodeslistval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 260
   SET rptsd->m_borders = rpt_sdallborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 7.688
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (_holdremdxcodeslistval > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdxcodeslistval,((
        size(__dxcodeslistval) - _holdremdxcodeslistval)+ 1),__dxcodeslistval)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remdxcodeslistval = _holdremdxcodeslistval
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow58(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow58abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow58abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.229167), private
   DECLARE __billtoval = vc WITH noconstant(build(req_data->bill_to,char(0))), protect
   DECLARE __lcains1codevalrepeat = vc WITH noconstant(build(insurance_data->ins_lc_alias_1,char(0))),
   protect
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 0.688
   SET rptsd->m_height = 0.230
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Bill Type:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdrightborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.863)
   SET rptsd->m_width = 3.188
   SET rptsd->m_height = 0.230
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__billtoval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.050)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.230
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("LCA Ins Code:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdrightborder)
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.050)
   SET rptsd->m_width = 2.813
   SET rptsd->m_height = 0.230
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__lcains1codevalrepeat)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.863),offsety,(offsetx+ 0.863),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.050),offsety,(offsetx+ 4.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.050),offsety,(offsetx+ 5.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE dxcodesreqabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.540000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF ( NOT (curpage=1))
    RETURN(0.0)
   ENDIF
   SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET _yoffset = (offsety+ 0.063)
   SET _fholdoffsety = (_yoffset - offsety)
   IF (ncalc=rpt_calcheight
    AND bcontinue=0)
    SET _yoffset = (offsety+ 0.063)
    SET holdheight = 0
    IF (growsum=0)
     SET maxheight_tablerow21 = (maxheight - (0.063+ holdheight))
     SET _bholdcontinue = 0
     SET holdheight = (holdheight+ tablerow21(rpt_calcheight,maxheight_tablerow21,_bholdcontinue))
     IF (((_bholdcontinue=1) OR (holdheight > maxheight_tablerow21)) )
      SET growsum = 1
     ENDIF
    ENDIF
    IF (growsum=0)
     SET maxheight_tablerow58 = (maxheight - (0.063+ holdheight))
     SET holdheight = (holdheight+ tablerow58(rpt_calcheight))
     IF (holdheight > maxheight_tablerow58)
      SET growsum = 1
     ENDIF
    ENDIF
    SET _yoffset = offsety
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _yoffset = (offsety+ 0.063)
    SET holdheight = 0
    SET maxheight_tablerow21 = (maxheight - (0.063+ holdheight))
    SET _bholdcontinue = 0
    SET holdheight = (holdheight+ tablerow21(rpt_render,maxheight_tablerow21,_bholdcontinue))
    IF (((0.063+ holdheight) > sectionheight))
     SET sectionheight = (0.063+ holdheight)
    ENDIF
    SET holdheight = (holdheight+ tablerow58(rpt_render))
    IF (((0.063+ holdheight) > sectionheight))
     SET sectionheight = (0.063+ holdheight)
    ENDIF
    SET _yoffset = offsety
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE orders(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = ordersabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow40(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow40abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow40abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.182)
   SET rptsd->m_width = 7.681
   SET rptsd->m_height = 0.243
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica14b16777215)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,rpt_black)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Orders",char(0)))
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE ordersabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.310000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT (curpage=1))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _yoffset = (offsety+ 0.063)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.063)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow40(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE orderscontd(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = orderscontdabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow56(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow56abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow56abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.182)
   SET rptsd->m_width = 7.681
   SET rptsd->m_height = 0.243
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica14b16777215)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,rpt_black)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Orders (Continued...)",char(0)))
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE orderscontdabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.310000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT (curpage > 1
    AND (all_order_counter != req_data->req_qual[loopvar].ord_cnt)))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _yoffset = (offsety+ 0.063)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.063)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow56(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE future_ord_msg(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = future_ord_msgabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE future_ord_msgabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.690000), private
   IF ( NOT ((req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=1)
    AND curpage=1))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.207)
    SET rptsd->m_width = 7.657
    SET rptsd->m_height = 0.688
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat(
       "You have attempted to print a requisition for a 3rd party lab while orders are still in a Future Order state. I",
       "n this order status, orders are not literally associated to an encounter and therefore do not have the critical ",
       "identifiers in place, namely MRN or FIN. Given the increase potential for data matching errors, the ability to p",
       "rint requisitions for these orders is disabled. Please return to PowerChart and insure orders are activated for ",
       "reference labs prior to requisition printing."),char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE testname(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = testnameabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow2(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow2abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow2abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.208333), private
   DECLARE __testname = vc WITH noconstant(build(trim(test_display_name),char(0))), protect
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 7.125
   SET rptsd->m_height = 0.209
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__testname)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.300),offsety,(offsetx+ 7.300),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.301),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.301),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE testnameabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT ((req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=0)))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _yoffset = (offsety+ 0.000)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.000)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow2(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE specimendetailsbold(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = specimendetailsboldabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow48(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow48abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow48abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.166667), private
   DECLARE __orderstatusval = vc WITH noconstant(build(req_data->req_qual[loopvar].ord_qual[d1.seq].
     order_status,char(0))), protect
   DECLARE __reqdatelbl = vc WITH noconstant(build(
     IF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=0.00)) "Req. Coll. Dt/Tm:"
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm != null)) "Collect. Dt/Tm:"
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm=null)) "Collect. Dt/Tm:"
     ENDIF
     ,char(0))), protect
   DECLARE __requestdateval = vc WITH noconstant(build(
     IF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=0.00)) concat(format(req_data->
        req_qual[loopvar].ord_qual[d1.seq].collected_dt_tm,"MM/DD/YYYY HH:MM;;q")," (est.)")
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm != null)) format(req_data->
       req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm,"MM/DD/YYYY HH:MM;;q")
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm=null)) format(req_data->req_qual[
       loopvar].ord_qual[d1.seq].collected_dt_tm,"MM/DD/YYYY HH:MM;;q")
     ENDIF
     ,char(0))), protect
   DECLARE __priorityval = vc WITH noconstant(build(uar_get_code_description(req_data->req_qual[
      loopvar].ord_qual[d1.seq].priority_cd),char(0))), protect
   SET rptsd->m_flags = 512
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.300)
   SET rptsd->m_width = 2.501
   SET rptsd->m_height = 0.167
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__orderstatusval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 2.801)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = 0.167
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=0))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__reqdatelbl)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.051)
   SET rptsd->m_width = 1.313
   SET rptsd->m_height = 0.167
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=0))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__requestdateval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.363)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.167
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Priority: ",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.488)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = 0.167
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((((req_data->labcorp_ind=1)) OR ((req_data->all_ind=1))) )
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__priorityval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.300),offsety,(offsetx+ 0.300),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.800),offsety,(offsetx+ 2.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.050),offsety,(offsetx+ 4.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.363),offsety,(offsetx+ 5.363),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.488),offsety,(offsetx+ 6.488),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.300),(offsety+ 0.000),(offsetx+ 7.863),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.300),(offsety+ sectionheight),(offsetx+ 7.863),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE specimendetailsboldabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT ((req_data->req_qual[loopvar].ord_qual[d1.seq].order_status_cd != 6004_ordered)
    AND (req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=0)))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _yoffset = (offsety+ 0.000)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.000)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow48(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE specimendetails(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = specimendetailsabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow60(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow60abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow60abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   DECLARE __orderstatusval = vc WITH noconstant(build(req_data->req_qual[loopvar].ord_qual[d1.seq].
     order_status,char(0))), protect
   DECLARE __reqdatelbl = vc WITH noconstant(build(
     IF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=0.00)) "Req. Coll. Dt/Tm:"
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm != null)) "Collect. Dt/Tm:"
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm=null)) "Collect. Dt/Tm:"
     ENDIF
     ,char(0))), protect
   DECLARE __requestdateval = vc WITH noconstant(build(
     IF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=0.00)) concat(format(req_data->
        req_qual[loopvar].ord_qual[d1.seq].collected_dt_tm,"MM/DD/YYYY HH:MM;;q")," (est.)")
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm != null)) format(req_data->
       req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm,"MM/DD/YYYY HH:MM;;q")
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm=null)) format(req_data->req_qual[
       loopvar].ord_qual[d1.seq].collected_dt_tm,"MM/DD/YYYY HH:MM;;q")
     ENDIF
     ,char(0))), protect
   DECLARE __priorityval = vc WITH noconstant(build(uar_get_code_description(req_data->req_qual[
      loopvar].ord_qual[d1.seq].priority_cd),char(0))), protect
   SET rptsd->m_flags = 512
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.300)
   SET rptsd->m_width = 2.501
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__orderstatusval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 2.801)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=0))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__reqdatelbl)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.051)
   SET rptsd->m_width = 1.313
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=0))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__requestdateval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.363)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Priority: ",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.488)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((((req_data->labcorp_ind=1)) OR ((req_data->all_ind=1))) )
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__priorityval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.300),offsety,(offsetx+ 0.300),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.800),offsety,(offsetx+ 2.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.050),offsety,(offsetx+ 4.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.363),offsety,(offsetx+ 5.363),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.488),offsety,(offsetx+ 6.488),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.300),(offsety+ 0.000),(offsetx+ 7.863),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.300),(offsety+ sectionheight),(offsetx+ 7.863),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE specimendetailsabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT ((req_data->req_qual[loopvar].ord_qual[d1.seq].order_status_cd=6004_ordered)
    AND (req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=0)))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _yoffset = (offsety+ 0.000)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.000)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow60(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE specimentypeanddesc(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = specimentypeanddescabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow55(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow55abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow55abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   DECLARE __spectypeval = vc WITH noconstant(build(uar_get_code_display(req_data->req_qual[loopvar].
      ord_qual[d1.seq].specimen_cd),char(0))), protect
   DECLARE __specdescval = vc WITH noconstant(build(req_data->req_qual[loopvar].ord_qual[d1.seq].
     specimen_description,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.300)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->req_qual[loopvar].collected_ind=1))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Specimen Source:",char(0)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.488)
   SET rptsd->m_width = 2.063
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->req_qual[loopvar].collected_ind=1))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__spectypeval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.550)
   SET rptsd->m_width = 1.438
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Specimen Description:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.988)
   SET rptsd->m_width = 2.875
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__specdescval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.300),offsety,(offsetx+ 0.300),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.488),offsety,(offsetx+ 1.488),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.550),offsety,(offsetx+ 3.550),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.988),offsety,(offsetx+ 4.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.300),(offsety+ 0.000),(offsetx+ 7.863),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.300),(offsety+ sectionheight),(offsetx+ 7.863),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE specimentypeanddescabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT ((req_data->req_qual[loopvar].ord_qual[d1.seq].order_status_cd=6004_ordered)
    AND (req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=0)))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _yoffset = (offsety+ 0.000)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.000)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow55(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE orderdetailssingle(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = orderdetailssingleabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow23(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow23abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow23abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   DECLARE __cellname1 = vc WITH noconstant(build(order_detail->cell1,char(0))), protect
   DECLARE __cellname2 = vc WITH noconstant(build(order_detail->cell2,char(0))), protect
   DECLARE __cellname3 = vc WITH noconstant(build(order_detail->cell3,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.300)
   SET rptsd->m_width = 2.501
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname1)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 2.801)
   SET rptsd->m_width = 2.563
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname2)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.363)
   SET rptsd->m_width = 2.500
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname3)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.300),offsety,(offsetx+ 0.300),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.800),offsety,(offsetx+ 2.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.363),offsety,(offsetx+ 5.363),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.300),(offsety+ 0.000),(offsetx+ 7.863),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.300),(offsety+ sectionheight),(offsetx+ 7.863),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE orderdetailssingleabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT ((req_data->req_qual[loopvar].ord_qual[d1.seq].single_cnt > 0)
    AND (req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=0)))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _yoffset = (offsety+ 0.000)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.000)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow23(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE orderdetailmulti(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = orderdetailmultiabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow61(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow61abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow61abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   DECLARE __multiaoeval = vc WITH noconstant(build(concat(req_data->req_qual[loopvar].ord_qual[d1
      .seq].details[mulord_row].label_text,": ",req_data->req_qual[loopvar].ord_qual[d1.seq].details[
      mulord_row].value),char(0))), protect
   SET rptsd->m_flags = 512
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.300)
   SET rptsd->m_width = 7.563
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__multiaoeval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.300),offsety,(offsetx+ 0.300),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.300),(offsety+ 0.000),(offsetx+ 7.863),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.300),(offsety+ sectionheight),(offsetx+ 7.863),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE orderdetailmultiabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT ((req_data->req_qual[loopvar].ord_qual[d1.seq].multi_cnt > 0)
    AND (req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=0)))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _yoffset = (offsety+ 0.000)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.000)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow61(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE specialinstructions(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = specialinstructionsabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow39(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow39abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow39abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   DECLARE __specialinstructval = vc WITH noconstant(build(req_data->req_qual[loopvar].ord_qual[d1
     .seq].special_instruct,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.307)
   SET rptsd->m_width = 1.118
   SET rptsd->m_height = 0.181
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Special Instructions:",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.432)
   SET rptsd->m_width = 6.431
   SET rptsd->m_height = 0.181
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__specialinstructval)
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.300),offsety,(offsetx+ 0.300),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.425),offsety,(offsetx+ 1.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.300),(offsety+ 0.000),(offsetx+ 7.863),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.300),(offsety+ sectionheight),(offsetx+ 7.863),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE specialinstructionsabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT (size(trim(req_data->req_qual[loopvar].ord_qual[d1.seq].special_instruct)) > 0
    AND (req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=0)))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _yoffset = (offsety+ 0.000)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.000)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow39(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE ordercomment(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = ordercommentabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow27(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow27abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow27abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   DECLARE __ordcommentval = vc WITH noconstant(build(req_data->req_qual[loopvar].ord_qual[d1.seq].
     comment_line,char(0))), protect
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.300)
   SET rptsd->m_width = 0.938
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Order Comment:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.238)
   SET rptsd->m_width = 6.625
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ordcommentval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.300),offsety,(offsetx+ 0.300),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.238),offsety,(offsetx+ 1.238),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.300),(offsety+ 0.000),(offsetx+ 7.863),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.300),(offsety+ sectionheight),(offsetx+ 7.863),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE ordercommentabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT (size(trim(req_data->req_qual[loopvar].ord_qual[d1.seq].comment_line)) > 0
    AND (req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=0)))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _yoffset = (offsety+ 0.000)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.000)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow27(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE orderseperator(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = orderseperatorabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE orderseperatorabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   IF ( NOT ((d1.seq != req_data->req_qual[loopvar].ord_cnt)
    AND (req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=0)))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s1c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.063),(offsetx+ 7.864),(offsety+
     0.063))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE insertbreaksectionifspeclabelspresent(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = insertbreaksectionifspeclabelspresentabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE insertbreaksectionifspeclabelspresentabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.040000), private
   IF ( NOT ((req_data->print_labcorp_labels_ind=1)))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE guarantor(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = guarantorabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow1(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow1abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow1abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.249909), private
   SET rptsd->m_flags = 512
   SET rptsd->m_borders = rpt_sdallborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 7.688
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(
      "Responsible Party / Guarantor Information:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow4(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow4abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow4abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.192156), private
   DECLARE __rpguarname = vc WITH noconstant(build(req_data->guarantor.name_full_formatted,char(0))),
   protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.193
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("RP Name:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.300)
   SET rptsd->m_width = 6.563
   SET rptsd->m_height = 0.193
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->bill_to_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__rpguarname)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.300),offsety,(offsetx+ 1.300),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow29(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow29abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow29abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.192156), private
   DECLARE __rpguaraddr = vc WITH noconstant(build(req_data->guarantor.address.street_addr,char(0))),
   protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.193
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("RP Address:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.300)
   SET rptsd->m_width = 6.563
   SET rptsd->m_height = 0.193
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->bill_to_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__rpguaraddr)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.300),offsety,(offsetx+ 1.300),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow30(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow30abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow30abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.177983), private
   DECLARE __rpguarcitystatezip = vc WITH noconstant(build(concat(req_data->guarantor.address.city,
      ", ",req_data->guarantor.address.state," ",req_data->guarantor.address.zipcode),char(0))),
   protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.178
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("RP City, State Zip:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.300)
   SET rptsd->m_width = 6.563
   SET rptsd->m_height = 0.178
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->bill_to_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__rpguarcitystatezip)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.300),offsety,(offsetx+ 1.300),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow31(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow31abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow31abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187432), private
   DECLARE __rpguarphone = vc WITH noconstant(build(cnvtphone(req_data->guarantor.phone.number,
      req_data->guarantor.phone.format_cd,2),char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("RP Phone:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.300)
   SET rptsd->m_width = 6.563
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->bill_to_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__rpguarphone)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.300),offsety,(offsetx+ 1.300),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow45(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow45abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow45abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187932), private
   DECLARE __rpguarreltn = vc WITH noconstant(build(uar_get_code_display(req_data->guarantor.reltn_cd
      ),char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("RP Relation to:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdrightborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.300)
   SET rptsd->m_width = 6.563
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->bill_to_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__rpguarreltn)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.300),offsety,(offsetx+ 1.300),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow62(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow62abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow62abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187432), private
   DECLARE __workerscompval = vc WITH noconstant(build(req_data->workers_comp,char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = bor(bor(rpt_sdbottomborder,rpt_sdleftborder),rpt_sdrightborder)
   SET rptsd->m_padding = rpt_sdrightborder
   SET rptsd->m_paddingwidth = 0.020
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Worker's Comp:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdrightborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.300)
   SET rptsd->m_width = 6.563
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->bill_to_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__workerscompval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.300),offsety,(offsetx+ 1.300),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE guarantorabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.380000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _yoffset = (offsety+ 0.000)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.000)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow1(rpt_render))
     SET holdheight = (holdheight+ tablerow4(rpt_render))
     SET holdheight = (holdheight+ tablerow29(rpt_render))
     SET holdheight = (holdheight+ tablerow30(rpt_render))
     SET holdheight = (holdheight+ tablerow31(rpt_render))
     SET holdheight = (holdheight+ tablerow45(rpt_render))
     SET holdheight = (holdheight+ tablerow62(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE insuranceinformation(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = insuranceinformationabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerowabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerowabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.249762), private
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = bor(bor(rpt_sdtopborder,rpt_sdbottomborder),rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.625
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Insurance Information:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = bor(bor(rpt_sdtopborder,rpt_sdbottomborder),rpt_sdrightborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.800)
   SET rptsd->m_width = 6.063
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.800),offsety,(offsetx+ 1.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow28(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow28abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow28abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.248344), private
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.251
   SET rptsd->m_height = 0.249
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Primary Insurance:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.426)
   SET rptsd->m_width = 2.625
   SET rptsd->m_height = 0.249
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.050)
   SET rptsd->m_width = 1.438
   SET rptsd->m_height = 0.249
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Secondary Insurance:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdrightborder)
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.488)
   SET rptsd->m_width = 2.375
   SET rptsd->m_height = 0.249
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.425),offsety,(offsetx+ 1.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.050),offsety,(offsetx+ 4.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.488),offsety,(offsetx+ 5.488),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow25(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow25abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow25abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.186465), private
   DECLARE __lcains1codeval = vc WITH noconstant(build(insurance_data->ins_lc_alias_1,char(0))),
   protect
   DECLARE __lcains2codeval = vc WITH noconstant(build(insurance_data->ins_lc_alias_2,char(0))),
   protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("LCA Ins Code:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.363)
   SET rptsd->m_width = 2.688
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__lcains1codeval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.050)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("LCA Ins Code:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.238)
   SET rptsd->m_width = 2.625
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__lcains2codeval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.363),offsety,(offsetx+ 1.363),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.050),offsety,(offsetx+ 4.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.238),offsety,(offsetx+ 5.238),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow26(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow26abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow26abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.186465), private
   DECLARE __ins1conameval = vc WITH noconstant(build(insurance_data->carrier_1,char(0))), protect
   DECLARE __ins2conameval = vc WITH noconstant(build(insurance_data->carrier_2,char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Ins Co Name:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.363)
   SET rptsd->m_width = 2.688
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins1conameval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.050)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Ins Co Name:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.238)
   SET rptsd->m_width = 2.625
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins2conameval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.363),offsety,(offsetx+ 1.363),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.050),offsety,(offsetx+ 4.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.238),offsety,(offsetx+ 5.238),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow33(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow33abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow33abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.186465), private
   DECLARE __ins1addrval = vc WITH noconstant(build(insurance_data->carrier_street_addr_1,char(0))),
   protect
   DECLARE __ins2addrval = vc WITH noconstant(build(insurance_data->carrier_street_addr_2,char(0))),
   protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Ins Address:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.363)
   SET rptsd->m_width = 2.688
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins1addrval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.050)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Ins Address:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.238)
   SET rptsd->m_width = 2.625
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins2addrval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.363),offsety,(offsetx+ 1.363),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.050),offsety,(offsetx+ 4.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.238),offsety,(offsetx+ 5.238),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow22(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow22abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow22abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.186465), private
   DECLARE __ins1addr2val = vc WITH noconstant(build(insurance_data->carrier_street_addr2_1,char(0))),
   protect
   DECLARE __ins2addr2val = vc WITH noconstant(build(insurance_data->carrier_street_addr2_2,char(0))),
   protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("2nd Ins Address:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.363)
   SET rptsd->m_width = 2.688
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins1addr2val)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.050)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("2nd Ins Address:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.238)
   SET rptsd->m_width = 2.625
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins2addr2val)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.363),offsety,(offsetx+ 1.363),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.050),offsety,(offsetx+ 4.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.238),offsety,(offsetx+ 5.238),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow34(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow34abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow34abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.186465), private
   DECLARE __ins1citystatezipval1 = vc WITH noconstant(build(insurance_data->carrier_citystatezip_1,
     char(0))), protect
   DECLARE __ins2citystatezipval3 = vc WITH noconstant(build(insurance_data->carrier_citystatezip_2,
     char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Ins City, State Zip:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.363)
   SET rptsd->m_width = 2.688
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins1citystatezipval1)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.050)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("City, State Zip:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.238)
   SET rptsd->m_width = 2.625
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins2citystatezipval3)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.363),offsety,(offsetx+ 1.363),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.050),offsety,(offsetx+ 4.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.238),offsety,(offsetx+ 5.238),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow35(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow35abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow35abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.186465), private
   DECLARE __ins1policynbrval5 = vc WITH noconstant(build(
     IF (textlen(trim(insurance_data->sub_nbr_1,3)) > 0) insurance_data->sub_nbr_1
     ELSE insurance_data->ins_nbr_1
     ENDIF
     ,char(0))), protect
   DECLARE __ins2policynbrval7 = vc WITH noconstant(build(
     IF (textlen(trim(insurance_data->sub_nbr_2,3)) > 0) insurance_data->sub_nbr_2
     ELSE insurance_data->ins_nbr_2
     ENDIF
     ,char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Policy Number:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.363)
   SET rptsd->m_width = 2.688
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins1policynbrval5)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.050)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Policy Number:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.238)
   SET rptsd->m_width = 2.625
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins2policynbrval7)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.363),offsety,(offsetx+ 1.363),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.050),offsety,(offsetx+ 4.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.238),offsety,(offsetx+ 5.238),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow32(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow32abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow32abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.186450), private
   DECLARE __ins1groupnbrval9 = vc WITH noconstant(build(insurance_data->ins_grp_nbr_1,char(0))),
   protect
   DECLARE __ins2groupnbrval11 = vc WITH noconstant(build(insurance_data->ins_grp_nbr_2,char(0))),
   protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Group Number:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.363)
   SET rptsd->m_width = 2.688
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins1groupnbrval9)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.050)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Group Number:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.238)
   SET rptsd->m_width = 2.625
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins2groupnbrval11)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.363),offsety,(offsetx+ 1.363),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.050),offsety,(offsetx+ 4.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.238),offsety,(offsetx+ 5.238),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow36(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow36abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow36abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.186465), private
   DECLARE __ins1subemp = vc WITH noconstant(build(insurance_data->sub_empl_1,char(0))), protect
   DECLARE __ins2subemp = vc WITH noconstant(build(insurance_data->sub_empl_2,char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Emp/Group Name:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.363)
   SET rptsd->m_width = 2.688
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins1subemp)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.050)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Emp/Group Name:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.238)
   SET rptsd->m_width = 2.625
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins2subemp)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.363),offsety,(offsetx+ 1.363),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.050),offsety,(offsetx+ 4.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.238),offsety,(offsetx+ 5.238),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow37(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow37abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow37abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.254133), private
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = bor(bor(rpt_sdtopborder,rpt_sdbottomborder),rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 3.875
   SET rptsd->m_height = 0.255
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Primary Policy Holder/Insured:",char(0
       )))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdallborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.050)
   SET rptsd->m_width = 3.813
   SET rptsd->m_height = 0.255
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Secondary Policy Holder/Insured:",char
      (0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.050),offsety,(offsetx+ 4.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow38(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow38abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow38abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.186465), private
   DECLARE __ins1subval = vc WITH noconstant(build(insurance_data->resp_party_1,char(0))), protect
   DECLARE __ins2subval = vc WITH noconstant(build(insurance_data->resp_party_2,char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Insured Name:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.363)
   SET rptsd->m_width = 2.688
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins1subval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.050)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Insured Name:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.238)
   SET rptsd->m_width = 2.625
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins2subval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.363),offsety,(offsetx+ 1.363),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.050),offsety,(offsetx+ 4.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.238),offsety,(offsetx+ 5.238),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow54(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow54abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow54abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.196592), private
   DECLARE __ins1subaddrval = vc WITH noconstant(build(insurance_data->resp_street_addr_1,char(0))),
   protect
   DECLARE __ins2subaddrval = vc WITH noconstant(build(insurance_data->resp_street_addr_2,char(0))),
   protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.197
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Address:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.363)
   SET rptsd->m_width = 2.688
   SET rptsd->m_height = 0.197
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins1subaddrval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.050)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.197
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Address:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.238)
   SET rptsd->m_width = 2.625
   SET rptsd->m_height = 0.197
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins2subaddrval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.363),offsety,(offsetx+ 1.363),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.050),offsety,(offsetx+ 4.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.238),offsety,(offsetx+ 5.238),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow44(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow44abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow44abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.196710), private
   DECLARE __ins1subcitystatezipval = vc WITH noconstant(build(insurance_data->resp_citystatezip_1,
     char(0))), protect
   DECLARE __ins2subcitystatezipval = vc WITH noconstant(build(insurance_data->resp_citystatezip_2,
     char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.197
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("City, State Zip:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.363)
   SET rptsd->m_width = 2.688
   SET rptsd->m_height = 0.197
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins1subcitystatezipval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.050)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.197
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("City, State Zip:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.238)
   SET rptsd->m_width = 2.625
   SET rptsd->m_height = 0.197
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins2subcitystatezipval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.363),offsety,(offsetx+ 1.363),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.050),offsety,(offsetx+ 4.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.238),offsety,(offsetx+ 5.238),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow43(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow43abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow43abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.186703), private
   DECLARE __ins1reltnval = vc WITH noconstant(build(insurance_data->reltn_1,char(0))), protect
   DECLARE __ins2reltnval = vc WITH noconstant(build(insurance_data->reltn_2,char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Relationship:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.363)
   SET rptsd->m_width = 2.688
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins1reltnval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.050)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Relationship:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdrightborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.238)
   SET rptsd->m_width = 2.625
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins2reltnval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.363),offsety,(offsetx+ 1.363),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.050),offsety,(offsetx+ 4.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.238),offsety,(offsetx+ 5.238),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE insuranceinformationabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(3.320000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _yoffset = (offsety+ 0.063)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.063)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow(rpt_render))
     SET holdheight = (holdheight+ tablerow28(rpt_render))
     SET holdheight = (holdheight+ tablerow25(rpt_render))
     SET holdheight = (holdheight+ tablerow26(rpt_render))
     SET holdheight = (holdheight+ tablerow33(rpt_render))
     SET holdheight = (holdheight+ tablerow22(rpt_render))
     SET holdheight = (holdheight+ tablerow34(rpt_render))
     SET holdheight = (holdheight+ tablerow35(rpt_render))
     SET holdheight = (holdheight+ tablerow32(rpt_render))
     SET holdheight = (holdheight+ tablerow36(rpt_render))
     SET holdheight = (holdheight+ tablerow37(rpt_render))
     SET holdheight = (holdheight+ tablerow38(rpt_render))
     SET holdheight = (holdheight+ tablerow54(rpt_render))
     SET holdheight = (holdheight+ tablerow44(rpt_render))
     SET holdheight = (holdheight+ tablerow43(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE authorization(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = authorizationabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow41(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow41abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow41abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   SET rptsd->m_flags = 260
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 7.688
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Authorization - Please Sign and Date",
      char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow42(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow42abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow42abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.500000), private
   SET rptsd->m_flags = 260
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 7.688
   SET rptsd->m_height = 0.501
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(concat(
       "I hereby authorize the release of medical information related to the services described hereon and authorize pa",
       "yment directly to",_crlf,
       "Laboratory Corporation of America. I agree to assume responsibility for payment of charges for laboratory servic",
       "es that",
       _crlf,"are not covered by my healthcare insurer."),char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),offsety,(offsetx+ 0.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.862),offsety,(offsetx+ 7.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 0.000),(offsetx+ 7.864),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ sectionheight),(offsetx+ 7.864),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE authorizationabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(2.130000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 1.219),(offsetx+ 3.780),(offsety+
     1.219))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.175),(offsety+ 1.844),(offsetx+ 3.780),(offsety+
     1.844))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 0.175)
    SET rptsd->m_width = 1.813
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica80)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Signature",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.875)
    SET rptsd->m_x = (offsetx+ 0.175)
    SET rptsd->m_width = 1.438
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Physician Signature",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.800),(offsety+ 1.219),(offsetx+ 6.791),(offsety+
     1.219))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.800),(offsety+ 1.844),(offsetx+ 6.791),(offsety+
     1.844))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.875)
    SET rptsd->m_x = (offsetx+ 4.800)
    SET rptsd->m_width = 1.021
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 4.800)
    SET rptsd->m_width = 1.209
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date",char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _yoffset = (offsety+ 0.125)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.125)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow41(rpt_render))
     SET holdheight = (holdheight+ tablerow42(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE futureorderwatermark(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = futureorderwatermarkabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE futureorderwatermarkabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(1.970000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_water_mark = f8 WITH noconstant(0.0), private
   DECLARE __water_mark = vc WITH noconstant(build2(
     IF ((req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=1)) "Future Order"
     ELSEIF ((req_data->reprint_ind=1)) "Requisition Reproduction"
     ENDIF
     ,char(0))), protect
   IF ( NOT ((((req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=1)) OR ((req_data->
   reprint_ind=1))) ))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET _remwater_mark = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 45
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.300)
   SET rptsd->m_width = 6.740
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times7015395562)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremwater_mark = _remwater_mark
   IF (_remwater_mark > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remwater_mark,((size(
        __water_mark) - _remwater_mark)+ 1),__water_mark)))
    SET drawheight_water_mark = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remwater_mark = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remwater_mark,((size(__water_mark) -
       _remwater_mark)+ 1),__water_mark)))))
     SET _remwater_mark = (_remwater_mark+ rptsd->m_drawlength)
    ELSE
     SET _remwater_mark = 0
    ENDIF
    SET growsum = (growsum+ _remwater_mark)
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.300)
   SET rptsd->m_width = 6.740
   SET rptsd->m_height = drawheight_water_mark
   IF (ncalc=rpt_render
    AND _holdremwater_mark > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremwater_mark,((size(
        __water_mark) - _holdremwater_mark)+ 1),__water_mark)))
   ELSE
    SET _remwater_mark = _holdremwater_mark
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE specimenlabels(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = specimenlabelsabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow51(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow51abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow51abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.125000), private
   SET rptsd->m_flags = 1024
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.426)
   SET rptsd->m_width = 1.063
   SET rptsd->m_height = 0.125
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica20)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.489)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 2.239)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.363)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.113)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.238)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.988)
   SET rptsd->m_width = 0.938
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.926)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),offsety,(offsetx+ 0.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.488),offsety,(offsetx+ 1.488),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.237),offsety,(offsetx+ 2.237),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.362),offsety,(offsetx+ 3.362),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.112),offsety,(offsetx+ 4.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.237),offsety,(offsetx+ 5.237),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.987),offsety,(offsetx+ 5.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.925),offsety,(offsetx+ 6.925),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.675),offsety,(offsetx+ 7.675),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),(offsety+ 0.000),(offsetx+ 7.676),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),(offsety+ sectionheight),(offsetx+ 7.676),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow52(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow52abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow52abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.125000), private
   DECLARE __label1patientname = vc WITH noconstant(build(req_data->name_full_formatted,char(0))),
   protect
   DECLARE __label1dob = vc WITH noconstant(build(format(cnvtdatetimeutc(datetimezone(req_data->
        birth_dt_tm,req_data->birth_tz),1),"MM/DD/YYYY;;d"),char(0))), protect
   DECLARE __label2patientname = vc WITH noconstant(build(req_data->name_full_formatted,char(0))),
   protect
   DECLARE __label2dob = vc WITH noconstant(build(format(cnvtdatetimeutc(datetimezone(req_data->
        birth_dt_tm,req_data->birth_tz),1),"MM/DD/YYYY;;d"),char(0))), protect
   DECLARE __label3patientname = vc WITH noconstant(build(req_data->name_full_formatted,char(0))),
   protect
   DECLARE __label3dob = vc WITH noconstant(build(format(cnvtdatetimeutc(datetimezone(req_data->
        birth_dt_tm,req_data->birth_tz),1),"MM/DD/YYYY;;d"),char(0))), protect
   DECLARE __label4patientname = vc WITH noconstant(build(req_data->name_full_formatted,char(0))),
   protect
   DECLARE __label4dob = vc WITH noconstant(build(format(cnvtdatetimeutc(datetimezone(req_data->
        birth_dt_tm,req_data->birth_tz),1),"MM/DD/YYYY;;d"),char(0))), protect
   SET rptsd->m_flags = 1024
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.426)
   SET rptsd->m_width = 1.063
   SET rptsd->m_height = 0.125
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica60)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label1patientname)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.489)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label1dob)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 2.239)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label2patientname)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.363)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label2dob)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.113)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label3patientname)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.238)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label3dob)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.988)
   SET rptsd->m_width = 0.938
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label4patientname)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.926)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label4dob)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),offsety,(offsetx+ 0.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.488),offsety,(offsetx+ 1.488),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.237),offsety,(offsetx+ 2.237),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.362),offsety,(offsetx+ 3.362),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.112),offsety,(offsetx+ 4.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.237),offsety,(offsetx+ 5.237),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.987),offsety,(offsetx+ 5.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.925),offsety,(offsetx+ 6.925),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.675),offsety,(offsetx+ 7.675),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),(offsety+ 0.000),(offsetx+ 7.676),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),(offsety+ sectionheight),(offsetx+ 7.676),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow53(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow53abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow53abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.125000), private
   DECLARE __label1reqcntrlnbr = vc WITH noconstant(build(req_data->req_qual[loopvar].req_control_nbr,
     char(0))), protect
   DECLARE __label1patientmrn = vc WITH noconstant(build(req_data->mrn,char(0))), protect
   DECLARE __label2reqcntrlnbr = vc WITH noconstant(build(req_data->req_qual[loopvar].req_control_nbr,
     char(0))), protect
   DECLARE __label2patientmrn = vc WITH noconstant(build(req_data->mrn,char(0))), protect
   DECLARE __label3reqcntrlnbr = vc WITH noconstant(build(req_data->req_qual[loopvar].req_control_nbr,
     char(0))), protect
   DECLARE __label3patientmrn = vc WITH noconstant(build(req_data->mrn,char(0))), protect
   DECLARE __label4reqcntrlnbr = vc WITH noconstant(build(req_data->req_qual[loopvar].req_control_nbr,
     char(0))), protect
   DECLARE __label4patientmrn = vc WITH noconstant(build(req_data->mrn,char(0))), protect
   SET rptsd->m_flags = 1024
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.426)
   SET rptsd->m_width = 1.063
   SET rptsd->m_height = 0.125
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica60)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label1reqcntrlnbr)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.489)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->req_qual[loopvar].req_control_nbr="FUTUREORDER"))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label1patientmrn)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 2.239)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label2reqcntrlnbr)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.363)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->req_qual[loopvar].req_control_nbr="FUTUREORDER"))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label2patientmrn)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.113)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label3reqcntrlnbr)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.238)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->req_qual[loopvar].req_control_nbr="FUTUREORDER"))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label3patientmrn)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.988)
   SET rptsd->m_width = 0.938
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label4reqcntrlnbr)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.926)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->req_qual[loopvar].req_control_nbr="FUTUREORDER"))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label4patientmrn)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),offsety,(offsetx+ 0.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.488),offsety,(offsetx+ 1.488),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.237),offsety,(offsetx+ 2.237),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.362),offsety,(offsetx+ 3.362),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.112),offsety,(offsetx+ 4.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.237),offsety,(offsetx+ 5.237),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.987),offsety,(offsetx+ 5.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.925),offsety,(offsetx+ 6.925),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.675),offsety,(offsetx+ 7.675),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),(offsety+ 0.000),(offsetx+ 7.676),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),(offsety+ sectionheight),(offsetx+ 7.676),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow63(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow63abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow63abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.114583), private
   SET rptsd->m_flags = 1024
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.426)
   SET rptsd->m_width = 1.063
   SET rptsd->m_height = 0.115
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica20)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.489)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.115
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 2.239)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.115
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.363)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.115
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.113)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.115
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.238)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.115
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.988)
   SET rptsd->m_width = 0.938
   SET rptsd->m_height = 0.115
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.926)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.115
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),offsety,(offsetx+ 0.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.488),offsety,(offsetx+ 1.488),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.237),offsety,(offsetx+ 2.237),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.362),offsety,(offsetx+ 3.362),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.112),offsety,(offsetx+ 4.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.237),offsety,(offsetx+ 5.237),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.987),offsety,(offsetx+ 5.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.925),offsety,(offsetx+ 6.925),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.675),offsety,(offsetx+ 7.675),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),(offsety+ 0.000),(offsetx+ 7.676),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),(offsety+ sectionheight),(offsetx+ 7.676),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow59(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow59abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow59abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.125000), private
   DECLARE __label5patientname = vc WITH noconstant(build(req_data->name_full_formatted,char(0))),
   protect
   DECLARE __label5dob = vc WITH noconstant(build(format(cnvtdatetimeutc(datetimezone(req_data->
        birth_dt_tm,req_data->birth_tz),1),"MM/DD/YYYY;;d"),char(0))), protect
   DECLARE __label6patientname = vc WITH noconstant(build(req_data->name_full_formatted,char(0))),
   protect
   DECLARE __label6dob = vc WITH noconstant(build(format(cnvtdatetimeutc(datetimezone(req_data->
        birth_dt_tm,req_data->birth_tz),1),"MM/DD/YYYY;;d"),char(0))), protect
   DECLARE __label7patientname = vc WITH noconstant(build(req_data->name_full_formatted,char(0))),
   protect
   DECLARE __label7dob = vc WITH noconstant(build(format(cnvtdatetimeutc(datetimezone(req_data->
        birth_dt_tm,req_data->birth_tz),1),"MM/DD/YYYY;;d"),char(0))), protect
   DECLARE __label8patientname = vc WITH noconstant(build(req_data->name_full_formatted,char(0))),
   protect
   DECLARE __label8dob = vc WITH noconstant(build(format(cnvtdatetimeutc(datetimezone(req_data->
        birth_dt_tm,req_data->birth_tz),1),"MM/DD/YYYY;;d"),char(0))), protect
   SET rptsd->m_flags = 1024
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.426)
   SET rptsd->m_width = 1.063
   SET rptsd->m_height = 0.125
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica60)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label5patientname)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.489)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label5dob)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 2.239)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label6patientname)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.363)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label6dob)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.113)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label7patientname)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.238)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label7dob)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.988)
   SET rptsd->m_width = 0.938
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label8patientname)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.926)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label8dob)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),offsety,(offsetx+ 0.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.488),offsety,(offsetx+ 1.488),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.237),offsety,(offsetx+ 2.237),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.362),offsety,(offsetx+ 3.362),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.112),offsety,(offsetx+ 4.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.237),offsety,(offsetx+ 5.237),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.987),offsety,(offsetx+ 5.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.925),offsety,(offsetx+ 6.925),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.675),offsety,(offsetx+ 7.675),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),(offsety+ 0.000),(offsetx+ 7.676),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),(offsety+ sectionheight),(offsetx+ 7.676),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow57(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow57abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow57abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.125001), private
   DECLARE __label5reqcntrlnbr = vc WITH noconstant(build(req_data->req_qual[loopvar].req_control_nbr,
     char(0))), protect
   DECLARE __label5patientmrn = vc WITH noconstant(build(req_data->mrn,char(0))), protect
   DECLARE __label6reqcntrlnbr = vc WITH noconstant(build(req_data->req_qual[loopvar].req_control_nbr,
     char(0))), protect
   DECLARE __label6patientmrn = vc WITH noconstant(build(req_data->mrn,char(0))), protect
   DECLARE __label7reqcntrlnbr = vc WITH noconstant(build(req_data->req_qual[loopvar].req_control_nbr,
     char(0))), protect
   DECLARE __label7patientmrn = vc WITH noconstant(build(req_data->mrn,char(0))), protect
   DECLARE __label8reqcntrlnbr = vc WITH noconstant(build(req_data->req_qual[loopvar].req_control_nbr,
     char(0))), protect
   DECLARE __label8patientmrn = vc WITH noconstant(build(req_data->mrn,char(0))), protect
   SET rptsd->m_flags = 1024
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.426)
   SET rptsd->m_width = 1.063
   SET rptsd->m_height = 0.125
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica60)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label5reqcntrlnbr)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.489)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->req_qual[loopvar].req_control_nbr="FUTUREORDER"))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label5patientmrn)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 2.239)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label6reqcntrlnbr)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.363)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->req_qual[loopvar].req_control_nbr="FUTUREORDER"))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label6patientmrn)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.113)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label7reqcntrlnbr)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.238)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->req_qual[loopvar].req_control_nbr="FUTUREORDER"))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label7patientmrn)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.988)
   SET rptsd->m_width = 0.938
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label8reqcntrlnbr)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.926)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->req_qual[loopvar].req_control_nbr="FUTUREORDER"))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label8patientmrn)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),offsety,(offsetx+ 0.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.488),offsety,(offsetx+ 1.488),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.237),offsety,(offsetx+ 2.237),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.362),offsety,(offsetx+ 3.362),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.112),offsety,(offsetx+ 4.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.237),offsety,(offsetx+ 5.237),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.987),offsety,(offsetx+ 5.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.925),offsety,(offsetx+ 6.925),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.675),offsety,(offsetx+ 7.675),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),(offsety+ 0.000),(offsetx+ 7.676),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),(offsety+ sectionheight),(offsetx+ 7.676),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE specimenlabelsabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.750000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT ((req_data->print_labcorp_labels_ind=1)))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen1s0c16777215)
    SET _yoffset = (offsety+ 0.000)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.000)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow51(rpt_render))
     SET holdheight = (holdheight+ tablerow52(rpt_render))
     SET holdheight = (holdheight+ tablerow53(rpt_render))
     SET holdheight = (holdheight+ tablerow63(rpt_render))
     SET holdheight = (holdheight+ tablerow59(rpt_render))
     SET holdheight = (holdheight+ tablerow57(rpt_render))
     SET _yoffset = offsety
    ENDIF
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE order_dt_tm(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = order_dt_tmabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE order_dt_tmabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.340000), private
   DECLARE __orderdttm = vc WITH noconstant(build2(concat("Order Date: ",format(order_dt_tm,
       "MM/DD/YYYY HH:MM;;D")),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.157)
    SET rptsd->m_x = (offsetx+ 0.050)
    SET rptsd->m_width = 8.105
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times90)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__orderdttm)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "AMB_RLN_LABCORP_LYT"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.20
   SET rptreport->m_marginright = 0.20
   SET rptreport->m_margintop = 0.20
   SET rptreport->m_marginbottom = 0.20
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SET rptreport->m_dioflag = 0
   SET rptreport->m_needsnotonaskharabic = 0
   SET _yoffset = rptreport->m_margintop
   SET _xoffset = rptreport->m_marginleft
   SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
   SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
   SET _rptstat = uar_rptstartreport(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   CALL _createfonts(0)
   CALL _createpens(0)
 END ;Subroutine
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 62
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_helvetica
   SET rptfont->m_pointsize = 14
   SET rptfont->m_bold = rpt_on
   SET _helvetica14b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET _helvetica100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_on
   SET _helvetica10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 6
   SET _helvetica6b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET _helvetica12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 9
   SET rptfont->m_bold = rpt_off
   SET _helvetica90 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_on
   SET _helvetica9b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 14
   SET rptfont->m_rgbcolor = rpt_white
   SET _helvetica14b16777215 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 8
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _helvetica80 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 70
   SET rptfont->m_rgbcolor = uar_rptencodecolor(234,234,234)
   SET _times7015395562 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_helvetica
   SET rptfont->m_pointsize = 2
   SET rptfont->m_rgbcolor = rpt_black
   SET _helvetica20 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 6
   SET _helvetica60 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 9
   SET _times90 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.014
   SET _pen13s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.000
   SET _pen0s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 1
   SET _pen14s1c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.001
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_white
   SET _pen1s0c16777215 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET stat = initrec(order_detail)
 DECLARE header_alias = vc WITH noconstant("")
 DECLARE 73_ambrln = f8 WITH constant(uar_get_code_by("DISPLAYKEY",73,"AMBULATORYRLN")), protect
 SELECT INTO "nl:"
  FROM code_value_set cvs,
   code_value cv,
   code_value_outbound cvo
  PLAN (cvs
   WHERE trim(cvs.display_key,3)="AMBULATORYRLNPREFERENCES")
   JOIN (cvo
   WHERE cvo.code_set=cvs.code_set
    AND cvo.contributor_source_cd=outerjoin(73_ambrln))
   JOIN (cv
   WHERE cv.code_value=cvo.code_value
    AND trim(cv.display_key,3)="CLIENTORGNAME")
  HEAD cv.code_value
   header_alias = trim(cvo.alias,3)
  WITH nocounter
 ;end select
 CALL initializereport(0)
 CALL query1(0)
 CALL finalizereport(_sendto)
END GO
