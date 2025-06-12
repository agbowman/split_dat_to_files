CREATE PROGRAM amb_rln_quest_lyt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE reportrtl
 DECLARE test_display_name = vc WITH protect
 DECLARE order_counter = i4 WITH protect
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE query1(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headreportsection(ncalc=i2) = f8 WITH protect
 DECLARE headreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE patientinfofirst(ncalc=i2) = f8 WITH protect
 DECLARE tablerow(ncalc=i2) = f8 WITH protect
 DECLARE tablerowabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow2(ncalc=i2) = f8 WITH protect
 DECLARE tablerow2abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow3(ncalc=i2) = f8 WITH protect
 DECLARE tablerow3abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow4(ncalc=i2) = f8 WITH protect
 DECLARE tablerow4abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow1(ncalc=i2) = f8 WITH protect
 DECLARE tablerow1abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE patientinfofirstabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE patientinforemaining(ncalc=i2) = f8 WITH protect
 DECLARE patientinforemainingabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE insuranceinformation(ncalc=i2) = f8 WITH protect
 DECLARE tablerow5(ncalc=i2) = f8 WITH protect
 DECLARE tablerow5abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow7(ncalc=i2) = f8 WITH protect
 DECLARE tablerow7abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow8(ncalc=i2) = f8 WITH protect
 DECLARE tablerow8abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow9(ncalc=i2) = f8 WITH protect
 DECLARE tablerow9abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow27(ncalc=i2) = f8 WITH protect
 DECLARE tablerow27abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow29(ncalc=i2) = f8 WITH protect
 DECLARE tablerow29abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow10(ncalc=i2) = f8 WITH protect
 DECLARE tablerow10abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow11(ncalc=i2) = f8 WITH protect
 DECLARE tablerow11abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow12(ncalc=i2) = f8 WITH protect
 DECLARE tablerow12abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow14(ncalc=i2) = f8 WITH protect
 DECLARE tablerow14abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow13(ncalc=i2) = f8 WITH protect
 DECLARE tablerow13abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow15(ncalc=i2) = f8 WITH protect
 DECLARE tablerow15abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow16(ncalc=i2) = f8 WITH protect
 DECLARE tablerow16abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow17(ncalc=i2) = f8 WITH protect
 DECLARE tablerow17abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow18(ncalc=i2) = f8 WITH protect
 DECLARE tablerow18abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow20(ncalc=i2) = f8 WITH protect
 DECLARE tablerow20abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow19(ncalc=i2) = f8 WITH protect
 DECLARE tablerow19abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow6(ncalc=i2) = f8 WITH protect
 DECLARE tablerow6abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE insuranceinformationabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE profilestests(ncalc=i2) = f8 WITH protect
 DECLARE tablerow22(ncalc=i2) = f8 WITH protect
 DECLARE tablerow22abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE profilestestsabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE future_ord_msg(ncalc=i2) = f8 WITH protect
 DECLARE future_ord_msgabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE testnamebold(ncalc=i2) = f8 WITH protect
 DECLARE tablerow26(ncalc=i2) = f8 WITH protect
 DECLARE tablerow26abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE testnameboldabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE testname(ncalc=i2) = f8 WITH protect
 DECLARE tablerow21(ncalc=i2) = f8 WITH protect
 DECLARE tablerow21abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE testnameabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE specimen_details(ncalc=i2) = f8 WITH protect
 DECLARE tablerow28(ncalc=i2) = f8 WITH protect
 DECLARE tablerow28abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE specimen_detailsabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE orderdetails(ncalc=i2) = f8 WITH protect
 DECLARE tablerow23(ncalc=i2) = f8 WITH protect
 DECLARE tablerow23abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE orderdetailsabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE orderdetailmulti(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE tablerow61(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE tablerow61abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE orderdetailmultiabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE diagnosiscodes(ncalc=i2) = f8 WITH protect
 DECLARE tablerow24(ncalc=i2) = f8 WITH protect
 DECLARE tablerow24abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE diagnosiscodesabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE specialinstructions(ncalc=i2) = f8 WITH protect
 DECLARE tablerow39(ncalc=i2) = f8 WITH protect
 DECLARE tablerow39abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE specialinstructionsabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE ordercomment(ncalc=i2) = f8 WITH protect
 DECLARE tablerow25(ncalc=i2) = f8 WITH protect
 DECLARE tablerow25abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE ordercommentabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footpagesectionspecimenlabel(ncalc=i2) = f8 WITH protect
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
 DECLARE footpagesectionspecimenlabelabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footpagesection(ncalc=i2) = f8 WITH protect
 DECLARE footpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE futureorderwatermark(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE futureorderwatermarkabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
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
 DECLARE _bcontorderdetailmulti = i2 WITH noconstant(0), protect
 DECLARE _bconttablerow61 = i2 WITH noconstant(0), protect
 DECLARE _remmultiaoeval = i4 WITH noconstant(1), protect
 DECLARE _remwater_mark = i4 WITH noconstant(1), protect
 DECLARE _bcontfutureorderwatermark = i2 WITH noconstant(0), protect
 DECLARE _helvetica90 = i4 WITH noconstant(0), protect
 DECLARE _helvetica10b0 = i4 WITH noconstant(0), protect
 DECLARE _helvetica48b0 = i4 WITH noconstant(0), protect
 DECLARE _helvetica20 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _helvetica60 = i4 WITH noconstant(0), protect
 DECLARE _helvetica100 = i4 WITH noconstant(0), protect
 DECLARE _helvetica9b0 = i4 WITH noconstant(0), protect
 DECLARE _times7215395562 = i4 WITH noconstant(0), protect
 DECLARE _helvetica1016777215 = i4 WITH noconstant(0), protect
 DECLARE _helvetica80 = i4 WITH noconstant(0), protect
 DECLARE _pen1s0c16777215 = i4 WITH noconstant(0), protect
 DECLARE _pen0s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen13s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 SUBROUTINE query1(dummy)
   SELECT INTO "NL:"
    FROM (dummyt d1  WITH seq = value(req_data->req_qual[loopvar].ord_cnt))
    PLAN (d1
     WHERE d1.seq > 0)
    ORDER BY d1.seq
    HEAD REPORT
     _d0 = d1.seq, _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom), _fdrawheight
      = headreportsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pageheight - rptreport->m_marginbottom)))
      CALL pagebreak(0)
     ENDIF
     dummy_val = headreportsection(rpt_render)
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
     _bcontfutureorderwatermark = 0, dummy_val = futureorderwatermarkabs(rpt_render,_xoffset,5.000,((
      rptreport->m_pageheight - rptreport->m_marginbottom) - 5.000),_bcontfutureorderwatermark),
     dummy_val = patientinfofirst(rpt_render),
     dummy_val = patientinforemaining(rpt_render), dummy_val = insuranceinformation(rpt_render),
     dummy_val = profilestests(rpt_render),
     dummy_val = future_ord_msg(rpt_render)
    HEAD d1.seq
     order_counter = (order_counter+ 1)
     IF ((req_data->print_quest_labels_ind=1))
      IF (((curpage=1
       AND order_counter > 2) OR (curpage > 1
       AND order_counter > 7)) )
       order_counter = 0, BREAK
      ENDIF
     ENDIF
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
     CALL echo(build("bharad_outbound_alias: ",req_data->req_qual[loopvar].ord_qual[d1.seq].
      outbound_alias)),
     CALL echo(build("bharad_test_display_name:",test_display_name)), _fdrawheight = testnamebold(
      rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ testname(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specimen_details(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ orderdetails(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ orderdetailmulti(rpt_calcheight,((
        _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ diagnosiscodes(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specialinstructions(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ ordercomment(rpt_calcheight))
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = testnamebold(rpt_render), _fdrawheight = testname(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specimen_details(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ orderdetails(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ orderdetailmulti(rpt_calcheight,((
        _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ diagnosiscodes(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specialinstructions(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ ordercomment(rpt_calcheight))
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = testname(rpt_render), _fdrawheight = specimen_details(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ orderdetails(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ orderdetailmulti(rpt_calcheight,((
        _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ diagnosiscodes(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specialinstructions(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ ordercomment(rpt_calcheight))
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = specimen_details(rpt_render), number_of_rows = ceil((cnvtreal(req_data->req_qual[
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
       _fdrawheight = orderdetails(rpt_calcheight)
       IF (_fdrawheight > 0)
        IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
         _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ orderdetailmulti(rpt_calcheight,((
          _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
         IF (_bholdcontinue=1)
          _fdrawheight = (_fenddetail+ 1)
         ENDIF
        ENDIF
        IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
         _fdrawheight = (_fdrawheight+ diagnosiscodes(rpt_calcheight))
        ENDIF
        IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
         _fdrawheight = (_fdrawheight+ specialinstructions(rpt_calcheight))
        ENDIF
        IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
         _fdrawheight = (_fdrawheight+ ordercomment(rpt_calcheight))
        ENDIF
       ENDIF
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ENDIF
       dummy_val = orderdetails(rpt_render)
     ENDFOR
     ord_row = 0
     FOR (mulord_row = 1 TO req_data->req_qual[loopvar].ord_qual[d1.seq].detail_cnt)
       IF ((req_data->req_qual[loopvar].ord_qual[d1.seq].details[mulord_row].multi_select=1))
        _bcontorderdetailmulti = 0, bfirsttime = 1
        WHILE (((_bcontorderdetailmulti=1) OR (bfirsttime=1)) )
          _bholdcontinue = _bcontorderdetailmulti, _fdrawheight = orderdetailmulti(rpt_calcheight,(
           _fenddetail - _yoffset),_bholdcontinue)
          IF (((_bholdcontinue=1) OR (_fdrawheight > 0)) )
           IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
            _fdrawheight = (_fdrawheight+ diagnosiscodes(rpt_calcheight))
           ENDIF
           IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
            _fdrawheight = (_fdrawheight+ specialinstructions(rpt_calcheight))
           ENDIF
           IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
            _fdrawheight = (_fdrawheight+ ordercomment(rpt_calcheight))
           ENDIF
          ENDIF
          IF (((_yoffset+ _fdrawheight) > _fenddetail))
           BREAK
          ENDIF
          dummy_val = orderdetailmulti(rpt_render,(_fenddetail - _yoffset),_bcontorderdetailmulti),
          bfirsttime = 0
        ENDWHILE
       ENDIF
     ENDFOR
     mulord_row = 0, _fdrawheight = diagnosiscodes(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specialinstructions(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ ordercomment(rpt_calcheight))
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = diagnosiscodes(rpt_render), _fdrawheight = specialinstructions(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ ordercomment(rpt_calcheight))
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = specialinstructions(rpt_render), _fdrawheight = ordercomment(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = ordercomment(rpt_render)
    DETAIL
     row + 0
    FOOT  d1.seq
     row + 0
    FOOT PAGE
     _yhold = _yoffset, _yoffset = _fenddetail, dummy_val = footpagesectionspecimenlabelabs(
      rpt_render,_xoffset,9.606),
     dummy_val = footpagesectionabs(rpt_render,_xoffset,10.300), _yoffset = _yhold
    WITH nocounter, append
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
   DECLARE sectionheight = f8 WITH noconstant(0.792000), private
   DECLARE __barcodeacc = vc WITH noconstant(build2(concat(req_data->req_qual[loopvar].
      loc_nurse_unit_alias,"-",req_data->req_qual[loopvar].req_control_nbr),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 5.925)
    SET rptsd->m_width = 2.126
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Quest Diagnostics Incorporated",char(
       0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen13s0c0)
    SET _rptdummy = uar_rptbarcodeinit(rptbce,rpt_code39,(offsetx+ 1.300),(offsety+ 0.000))
    SET rptbce->m_barcodetype = rpt_code39
    SET rptbce->m_ecc = 1
    SET rptbce->m_recsize = 90
    SET rptbce->m_width = 4.50
    SET rptbce->m_height = 0.55
    SET rptbce->m_rotation = 0
    SET rptbce->m_ratio = 300
    SET rptbce->m_barwidth = 1
    SET rptbce->m_bscale = 1
    SET rptbce->m_bprintinterp = 0
    SET rptbce->m_startchar = "*"
    SET rptbce->m_endchar = "*"
    SET _rptstat = uar_rptbarcodeex(_hreport,rptbce,build2(concat("*",req_data->req_qual[loopvar].
       loc_nurse_unit_alias,"-",req_data->req_qual[loopvar].req_control_nbr,"*"),char(0)))
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 1.425)
    SET rptsd->m_width = 4.250
    SET rptsd->m_height = 0.209
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__barcodeacc)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE patientinfofirst(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = patientinfofirstabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerowabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerowabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   SET rptsd->m_flags = 16
   SET rptsd->m_borders = rpt_sdallborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.863)
   SET rptsd->m_width = 4.188
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Patient Information",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.862),offsety,(offsetx+ 3.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.050),offsety,(offsetx+ 8.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.863),(offsety+ 0.000),(offsetx+ 8.051),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.863),(offsety+ sectionheight),(offsetx+ 8.051),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow2(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow2abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow2abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.374999), private
   DECLARE __patientname = vc WITH noconstant(build(req_data->name_full_formatted,char(0))), protect
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = bor(rpt_sdleftborder,rpt_sdrightborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.863)
   SET rptsd->m_width = 4.188
   SET rptsd->m_height = 0.375
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientname)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.862),offsety,(offsetx+ 3.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.050),offsety,(offsetx+ 8.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.863),(offsety+ 0.000),(offsetx+ 8.051),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.863),(offsety+ sectionheight),(offsetx+ 8.051),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow3(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow3abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow3abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   DECLARE __patientstreetaddr = vc WITH noconstant(build(concat(trim(req_data->address.street_addr),
      " ",trim(req_data->address.street_addr2)),char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = bor(rpt_sdleftborder,rpt_sdrightborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.863)
   SET rptsd->m_width = 4.188
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientstreetaddr)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.862),offsety,(offsetx+ 3.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.050),offsety,(offsetx+ 8.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.863),(offsety+ 0.000),(offsetx+ 8.051),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.863),(offsety+ sectionheight),(offsetx+ 8.051),(
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
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   DECLARE __patientcitystatezip = vc WITH noconstant(build(concat(req_data->address.city,", ",
      req_data->address.state," ",req_data->address.zipcode),char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = bor(rpt_sdleftborder,rpt_sdrightborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.863)
   SET rptsd->m_width = 4.188
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientcitystatezip)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.862),offsety,(offsetx+ 3.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.050),offsety,(offsetx+ 8.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.863),(offsety+ 0.000),(offsetx+ 8.051),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.863),(offsety+ sectionheight),(offsetx+ 8.051),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow1(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow1abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow1abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   DECLARE __patientphone = vc WITH noconstant(build(cnvtphone(req_data->phone.number,req_data->phone
      .format_cd,2),char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = bor(bor(rpt_sdbottomborder,rpt_sdleftborder),rpt_sdrightborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.863)
   SET rptsd->m_width = 4.188
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientphone)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.862),offsety,(offsetx+ 3.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.050),offsety,(offsetx+ 8.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.863),(offsety+ 0.000),(offsetx+ 8.051),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.863),(offsety+ sectionheight),(offsetx+ 8.051),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE patientinfofirstabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(2.042000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   DECLARE __clientnbrvalue = vc WITH noconstant(build2(req_data->req_qual[loopvar].
     loc_nurse_unit_alias,char(0))), protect
   DECLARE __clientname = vc WITH noconstant(build2(req_data->organization.org_name,char(0))),
   protect
   DECLARE __clientstreetaddr1 = vc WITH noconstant(build2(req_data->organization.street_addr,char(0)
     )), protect
   DECLARE __clientstreetaddr2 = vc WITH noconstant(build2(req_data->organization.street_addr2,char(0
      ))), protect
   DECLARE __clientcitystatezip = vc WITH noconstant(build2(concat(req_data->organization.city,", ",
      req_data->organization.state," ",req_data->organization.zipcode),char(0))), protect
   DECLARE __clientphone = vc WITH noconstant(build2(concat("Phone: ",cnvtphone(req_data->
       organization.phone_num,req_data->organization.phone_format_cd,2)," Fax: ",cnvtphone(req_data->
       organization.fax_num,req_data->organization.fax_format_cd,2)),char(0))), protect
   DECLARE __billtovalue = vc WITH noconstant(build2(req_data->bill_to,char(0))), protect
   IF ( NOT (curpage=1))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.813)
    SET rptsd->m_x = (offsetx+ - (0.012))
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Client #:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.813)
    SET rptsd->m_x = (offsetx+ 0.550)
    SET rptsd->m_width = 2.001
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__clientnbrvalue)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.063)
    SET rptsd->m_x = (offsetx+ - (0.012))
    SET rptsd->m_width = 2.563
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__clientname)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.313)
    SET rptsd->m_x = (offsetx+ - (0.012))
    SET rptsd->m_width = 2.313
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__clientstreetaddr1)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ - (0.012))
    SET rptsd->m_width = 2.313
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__clientstreetaddr2)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.688)
    SET rptsd->m_x = (offsetx+ - (0.012))
    SET rptsd->m_width = 2.313
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__clientcitystatezip)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.875)
    SET rptsd->m_x = (offsetx+ - (0.012))
    SET rptsd->m_width = 3.771
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__clientphone)
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _yoffset = (offsety+ 0.875)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.875)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow(rpt_render))
     SET holdheight = (holdheight+ tablerow2(rpt_render))
     SET holdheight = (holdheight+ tablerow3(rpt_render))
     SET holdheight = (holdheight+ tablerow4(rpt_render))
     SET holdheight = (holdheight+ tablerow1(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.376)
    SET rptsd->m_x = (offsetx+ 6.988)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10b0)
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    IF ((req_data->req_qual[loopvar].collected_ind=false))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("PSC HOLD",char(0)))
    ENDIF
    SET rptsd->m_flags = 516
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 6.613)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.875
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica48b0)
    IF ((req_data->req_qual[loopvar].collected_ind=true))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("e",char(0)))
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.688)
    SET rptsd->m_x = (offsetx+ 5.238)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Bill to:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.688)
    SET rptsd->m_x = (offsetx+ 5.675)
    SET rptsd->m_width = 2.188
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__billtovalue)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE patientinforemaining(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = patientinforemainingabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE patientinforemainingabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.375000), private
   DECLARE __clientnbrvalue = vc WITH noconstant(build2(req_data->req_qual[loopvar].
     loc_nurse_unit_alias,char(0))), protect
   DECLARE __labrefidvalue = vc WITH noconstant(build2(req_data->req_qual[loopvar].req_control_nbr,
     char(0))), protect
   DECLARE __patidvalue = vc WITH noconstant(build2(req_data->mrn,char(0))), protect
   DECLARE __patientname = vc WITH noconstant(build2(req_data->name_full_formatted,char(0))), protect
   DECLARE __finvalue = vc WITH noconstant(build2(req_data->fin,char(0))), protect
   IF ( NOT (curpage > 1))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ - (0.012))
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Client #:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 0.550)
    SET rptsd->m_width = 2.626
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__clientnbrvalue)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ - (0.012))
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Lab Reference ID:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 3.863)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Pat ID #:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 1.113)
    SET rptsd->m_width = 2.376
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__labrefidvalue)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 4.425)
    SET rptsd->m_width = 1.625
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patidvalue)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 3.863)
    SET rptsd->m_width = 4.188
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientname)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 6.050)
    SET rptsd->m_width = 0.313
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("FIN:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 6.363)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__finvalue)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE insuranceinformation(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = insuranceinformationabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow5(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow5abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow5abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.186926), private
   DECLARE __collectiondt = vc WITH noconstant(build(
     IF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=0.00)) "Req. Coll. Dt/Tm:"
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm != null)) "Collect. Dt/Tm:"
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm=null)) "Collect. Dt/Tm:"
     ENDIF
     ,char(0))), protect
   DECLARE __collectiondtval = vc WITH noconstant(build(
     IF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=0.00)) format(req_data->
       req_qual[loopvar].ord_qual[d1.seq].collected_dt_tm,"MM/DD/YYYY ;;d")
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm != null)) format(req_data->
       req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm,"MM/DD/YYYY ;;d")
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm=null)) format(req_data->req_qual[
       loopvar].ord_qual[d1.seq].collected_dt_tm,"MM/DD/YYYY ;;d")
     ENDIF
     ,char(0))), protect
   DECLARE __collectiontm = vc WITH noconstant(build(
     IF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=0.00)) concat("Time: ",format(
        req_data->req_qual[loopvar].ord_qual[d1.seq].collected_dt_tm,"HH:MM;;q"))
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm != null)) concat("Time: ",format(
        req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm,"HH:MM;;q"))
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm=null)) concat("Time: ",format(
        req_data->req_qual[loopvar].ord_qual[d1.seq].collected_dt_tm,"HH:MM;;q"))
     ENDIF
     ,char(0))), protect
   DECLARE __patidvalue = vc WITH noconstant(build(req_data->mrn,char(0))), protect
   DECLARE __patientsexvalue = vc WITH noconstant(build(uar_get_code_display(req_data->sex_cd),char(0
      ))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = bor(rpt_sdtopborder,rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ - (0.012))
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__collectiondt)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdtopborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.176)
   SET rptsd->m_width = 1.313
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__collectiondtval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdtopborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 2.488)
   SET rptsd->m_width = 1.313
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__collectiontm)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = bor(rpt_sdtopborder,rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.801)
   SET rptsd->m_width = 0.563
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Pat ID #:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdtopborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.363)
   SET rptsd->m_width = 1.688
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patidvalue)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdtopborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.051)
   SET rptsd->m_width = 0.313
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Sex:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = bor(rpt_sdtopborder,rpt_sdrightborder)
   SET rptsd->m_padding = rpt_sdrightborder
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.363)
   SET rptsd->m_width = 1.688
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientsexvalue)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 8.051)
   SET rptsd->m_width = 0.125
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.013)),offsety,(offsetx+ - (0.013)),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.175),offsety,(offsetx+ 1.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.488),offsety,(offsetx+ 2.488),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.800),offsety,(offsetx+ 3.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.362),offsety,(offsetx+ 4.362),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.050),offsety,(offsetx+ 6.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.363),offsety,(offsetx+ 6.363),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.050),offsety,(offsetx+ 8.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.175),offsety,(offsetx+ 8.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ 0.000),(offsetx+ 8.176),(
     offsety+ 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ sectionheight),(offsetx+ 8.176
     ),(offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow7(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow7abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow7abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.186926), private
   DECLARE __reflabvalue = vc WITH noconstant(build(req_data->req_qual[loopvar].req_control_nbr,char(
      0))), protect
   DECLARE __patientdobvalue = vc WITH noconstant(build(format(cnvtdatetimeutc(datetimezone(req_data
        ->birth_dt_tm,req_data->birth_tz),1),"MM/DD/YYYY;;d"),char(0))), protect
   DECLARE __finval = vc WITH noconstant(build(req_data->fin,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ - (0.012))
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Lab Reference ID:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.176)
   SET rptsd->m_width = 2.625
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__reflabvalue)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.801)
   SET rptsd->m_width = 0.438
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("DOB:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdrightborder
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.238)
   SET rptsd->m_width = 1.813
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientdobvalue)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdrightborder
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.050)
   SET rptsd->m_width = 0.313
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("FIN:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdrightborder)
   SET rptsd->m_padding = rpt_sdrightborder
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.363)
   SET rptsd->m_width = 1.688
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__finval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 8.051)
   SET rptsd->m_width = 0.125
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.013)),offsety,(offsetx+ - (0.013)),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.175),offsety,(offsetx+ 1.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.800),offsety,(offsetx+ 3.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.238),offsety,(offsetx+ 4.238),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.050),offsety,(offsetx+ 6.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.363),offsety,(offsetx+ 6.363),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.050),offsety,(offsetx+ 8.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.175),offsety,(offsetx+ 8.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ 0.000),(offsetx+ 8.176),(
     offsety+ 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ sectionheight),(offsetx+ 8.176
     ),(offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow8(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow8abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow8abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.186926), private
   DECLARE __ordphysnamevalue = vc WITH noconstant(build(req_data->req_qual[loopvar].order_provider.
     name_full,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ - (0.012))
   SET rptsd->m_width = 1.938
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Ord Phys (Electronically Signed):",
      char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.925)
   SET rptsd->m_width = 1.876
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ordphysnamevalue)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.801)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.801)
   SET rptsd->m_width = 3.251
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 8.051)
   SET rptsd->m_width = 0.125
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.013)),offsety,(offsetx+ - (0.013)),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.925),offsety,(offsetx+ 1.925),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.800),offsety,(offsetx+ 3.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.800),offsety,(offsetx+ 4.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.050),offsety,(offsetx+ 8.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.175),offsety,(offsetx+ 8.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ 0.000),(offsetx+ 8.176),(
     offsety+ 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ sectionheight),(offsetx+ 8.176
     ),(offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow9(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow9abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow9abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.186913), private
   DECLARE __ordphysnpivalue = vc WITH noconstant(build(req_data->req_qual[loopvar].order_provider.
     npi,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ - (0.012))
   SET rptsd->m_width = 0.438
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("NPI:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.425)
   SET rptsd->m_width = 3.376
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ordphysnpivalue)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.801)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.800)
   SET rptsd->m_width = 3.251
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 8.051)
   SET rptsd->m_width = 0.125
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.013)),offsety,(offsetx+ - (0.013)),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),offsety,(offsetx+ 0.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.800),offsety,(offsetx+ 3.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.800),offsety,(offsetx+ 4.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.050),offsety,(offsetx+ 8.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.175),offsety,(offsetx+ 8.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ 0.000),(offsetx+ 8.176),(
     offsety+ 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ sectionheight),(offsetx+ 8.176
     ),(offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow27(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow27abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow27abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.186919), private
   DECLARE __supphys = vc WITH noconstant(build(req_data->req_qual[loopvar].sup_physician.name_full,
     char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ - (0.012))
   SET rptsd->m_width = 0.813
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Sup Phys:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.801)
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__supphys)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.801)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.800)
   SET rptsd->m_width = 1.951
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.751)
   SET rptsd->m_width = 1.300
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 8.051)
   SET rptsd->m_width = 0.125
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.013)),offsety,(offsetx+ - (0.013)),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.800),offsety,(offsetx+ 0.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.800),offsety,(offsetx+ 3.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.800),offsety,(offsetx+ 4.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.750),offsety,(offsetx+ 6.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.050),offsety,(offsetx+ 8.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.175),offsety,(offsetx+ 8.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ 0.000),(offsetx+ 8.176),(
     offsety+ 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ sectionheight),(offsetx+ 8.176
     ),(offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow29(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow29abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow29abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.186919), private
   DECLARE __supphysnpi = vc WITH noconstant(build(req_data->req_qual[loopvar].sup_physician.npi,char
     (0))), protect
   DECLARE __primcarriervalue = vc WITH noconstant(build(insurance_data->carrier_1,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ - (0.012))
   SET rptsd->m_width = 0.438
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("NPI:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.425)
   SET rptsd->m_width = 3.376
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__supphysnpi)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.801)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Primary Carrier:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.800)
   SET rptsd->m_width = 1.951
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__primcarriervalue)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.751)
   SET rptsd->m_width = 1.300
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 8.051)
   SET rptsd->m_width = 0.125
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.013)),offsety,(offsetx+ - (0.013)),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),offsety,(offsetx+ 0.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.800),offsety,(offsetx+ 3.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.800),offsety,(offsetx+ 4.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.750),offsety,(offsetx+ 6.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.050),offsety,(offsetx+ 8.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.175),offsety,(offsetx+ 8.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ 0.000),(offsetx+ 8.176),(
     offsety+ 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ sectionheight),(offsetx+ 8.176
     ),(offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow10(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow10abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow10abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.186919), private
   DECLARE __refphysnamevalue = vc WITH noconstant(build(req_data->refer_physician_name,char(0))),
   protect
   DECLARE __primarystreetaddr1 = vc WITH noconstant(build(insurance_data->carrier_street_addr_1,char
     (0))), protect
   DECLARE __groupnbrvalue1 = vc WITH noconstant(build(insurance_data->ins_grp_nbr_1,char(0))),
   protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ - (0.012))
   SET rptsd->m_width = 1.675
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Ref Physician Provider ID:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.663)
   SET rptsd->m_width = 2.138
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__refphysnamevalue)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.801)
   SET rptsd->m_width = 2.371
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__primarystreetaddr1)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.171)
   SET rptsd->m_width = 0.580
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Group #:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.751)
   SET rptsd->m_width = 1.300
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__groupnbrvalue1)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 8.051)
   SET rptsd->m_width = 0.125
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.013)),offsety,(offsetx+ - (0.013)),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.662),offsety,(offsetx+ 1.662),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.800),offsety,(offsetx+ 3.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.171),offsety,(offsetx+ 6.171),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.750),offsety,(offsetx+ 6.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.050),offsety,(offsetx+ 8.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.175),offsety,(offsetx+ 8.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ 0.000),(offsetx+ 8.176),(
     offsety+ 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ sectionheight),(offsetx+ 8.176
     ),(offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow11(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow11abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow11abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.186919), private
   DECLARE __billtypevalue1 = vc WITH noconstant(build(insurance_data->bill_type_1,char(0))), protect
   DECLARE __primarycarriercitystatezip = vc WITH noconstant(build(insurance_data->
     carrier_citystatezip_1,char(0))), protect
   DECLARE __insnbrvalue1 = vc WITH noconstant(build(
     IF (textlen(trim(insurance_data->sub_nbr_1,3)) > 0) insurance_data->sub_nbr_1
     ELSE insurance_data->ins_nbr_1
     ENDIF
     ,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ - (0.012))
   SET rptsd->m_width = 1.868
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Responsible Party (1):",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.856)
   SET rptsd->m_width = 0.580
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Bill Type:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 2.436)
   SET rptsd->m_width = 1.365
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__billtypevalue1)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.801)
   SET rptsd->m_width = 2.371
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__primarycarriercitystatezip)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.171)
   SET rptsd->m_width = 0.773
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Insurance #:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.944)
   SET rptsd->m_width = 1.107
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__insnbrvalue1)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 8.051)
   SET rptsd->m_width = 0.125
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.013)),offsety,(offsetx+ - (0.013)),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.855),offsety,(offsetx+ 1.855),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.435),offsety,(offsetx+ 2.435),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.800),offsety,(offsetx+ 3.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.171),offsety,(offsetx+ 6.171),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.944),offsety,(offsetx+ 6.944),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.050),offsety,(offsetx+ 8.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.175),offsety,(offsetx+ 8.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ 0.000),(offsetx+ 8.176),(
     offsety+ 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ sectionheight),(offsetx+ 8.176
     ),(offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow12(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow12abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow12abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.186923), private
   DECLARE __respparty1 = vc WITH noconstant(build(insurance_data->resp_party_1,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ - (0.012))
   SET rptsd->m_width = 3.813
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__respparty1)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.801)
   SET rptsd->m_width = 1.063
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.863)
   SET rptsd->m_width = 3.188
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 8.051)
   SET rptsd->m_width = 0.125
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.013)),offsety,(offsetx+ - (0.013)),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.800),offsety,(offsetx+ 3.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.863),offsety,(offsetx+ 4.863),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.050),offsety,(offsetx+ 8.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.175),offsety,(offsetx+ 8.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ 0.000),(offsetx+ 8.176),(
     offsety+ 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ sectionheight),(offsetx+ 8.176
     ),(offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow14(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow14abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow14abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.186923), private
   DECLARE __respstreetaddr1 = vc WITH noconstant(build(insurance_data->resp_street_addr_1,char(0))),
   protect
   DECLARE __seccarriervalue = vc WITH noconstant(build(insurance_data->carrier_2,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ - (0.012))
   SET rptsd->m_width = 3.813
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__respstreetaddr1)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.801)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Secondary Carrier:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.988)
   SET rptsd->m_width = 3.063
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__seccarriervalue)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 8.051)
   SET rptsd->m_width = 0.125
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.013)),offsety,(offsetx+ - (0.013)),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.800),offsety,(offsetx+ 3.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.988),offsety,(offsetx+ 4.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.050),offsety,(offsetx+ 8.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.175),offsety,(offsetx+ 8.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ 0.000),(offsetx+ 8.176),(
     offsety+ 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ sectionheight),(offsetx+ 8.176
     ),(offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow13(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow13abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow13abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.186923), private
   DECLARE __respcitystatezip = vc WITH noconstant(build(insurance_data->resp_citystatezip_1,char(0))
    ), protect
   DECLARE __seconcarystreetaddr = vc WITH noconstant(build(insurance_data->carrier_street_addr_2,
     char(0))), protect
   DECLARE __groupnbrvalue2 = vc WITH noconstant(build(insurance_data->ins_grp_nbr_2,char(0))),
   protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ - (0.012))
   SET rptsd->m_width = 3.813
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__respcitystatezip)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.801)
   SET rptsd->m_width = 2.371
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__seconcarystreetaddr)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.171)
   SET rptsd->m_width = 0.580
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Group #:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.751)
   SET rptsd->m_width = 1.300
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__groupnbrvalue2)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 8.051)
   SET rptsd->m_width = 0.125
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.013)),offsety,(offsetx+ - (0.013)),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.800),offsety,(offsetx+ 3.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.171),offsety,(offsetx+ 6.171),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.750),offsety,(offsetx+ 6.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.050),offsety,(offsetx+ 8.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.175),offsety,(offsetx+ 8.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ 0.000),(offsetx+ 8.176),(
     offsety+ 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ sectionheight),(offsetx+ 8.176
     ),(offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow15(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow15abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow15abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.249228), private
   DECLARE __reltn1 = vc WITH noconstant(build(insurance_data->reltn_1,char(0))), protect
   DECLARE __secondarycarriercitystatezip = vc WITH noconstant(build(insurance_data->
     carrier_citystatezip_2,char(0))), protect
   DECLARE __insnbrvalue2 = vc WITH noconstant(build(
     IF (textlen(trim(insurance_data->sub_nbr_2,3)) > 0) insurance_data->sub_nbr_2
     ELSE insurance_data->ins_nbr_2
     ENDIF
     ,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ - (0.012))
   SET rptsd->m_width = 0.876
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Relationship:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.863)
   SET rptsd->m_width = 2.938
   SET rptsd->m_height = 0.250
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__reltn1)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.801)
   SET rptsd->m_width = 2.371
   SET rptsd->m_height = 0.250
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__secondarycarriercitystatezip)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.171)
   SET rptsd->m_width = 0.773
   SET rptsd->m_height = 0.250
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Insurance #:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.944)
   SET rptsd->m_width = 1.107
   SET rptsd->m_height = 0.250
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__insnbrvalue2)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 8.051)
   SET rptsd->m_width = 0.125
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.013)),offsety,(offsetx+ - (0.013)),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.863),offsety,(offsetx+ 0.863),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.800),offsety,(offsetx+ 3.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.171),offsety,(offsetx+ 6.171),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.944),offsety,(offsetx+ 6.944),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.050),offsety,(offsetx+ 8.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.175),offsety,(offsetx+ 8.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ 0.000),(offsetx+ 8.176),(
     offsety+ 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ sectionheight),(offsetx+ 8.176
     ),(offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow16(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow16abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow16abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.186923), private
   DECLARE __billtypevalue2 = vc WITH noconstant(build(insurance_data->bill_type_2,char(0))), protect
   DECLARE __guarantorname = vc WITH noconstant(build(req_data->guarantor.name_full_formatted,char(0)
     )), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ - (0.012))
   SET rptsd->m_width = 1.875
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Responsible Party (2):",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.863)
   SET rptsd->m_width = 0.563
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Bill Type:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 2.425)
   SET rptsd->m_width = 1.376
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__billtypevalue2)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = bor(rpt_sdtopborder,rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.801)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Guarantor:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = bor(rpt_sdtopborder,rpt_sdrightborder)
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.551)
   SET rptsd->m_width = 3.501
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->bill_to_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__guarantorname)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 8.051)
   SET rptsd->m_width = 0.125
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.013)),offsety,(offsetx+ - (0.013)),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.862),offsety,(offsetx+ 1.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.425),offsety,(offsetx+ 2.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.800),offsety,(offsetx+ 3.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.550),offsety,(offsetx+ 4.550),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.050),offsety,(offsetx+ 8.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.175),offsety,(offsetx+ 8.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ 0.000),(offsetx+ 8.176),(
     offsety+ 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ sectionheight),(offsetx+ 8.176
     ),(offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow17(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow17abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow17abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.186923), private
   DECLARE __respparty2 = vc WITH noconstant(build(insurance_data->resp_party_2,char(0))), protect
   DECLARE __guarstreetaddr = vc WITH noconstant(build(req_data->guarantor.address.street_addr,char(0
      ))), protect
   DECLARE __guarphonevalue = vc WITH noconstant(build(cnvtphone(req_data->guarantor.phone.number,
      req_data->guarantor.phone.format_cd,2),char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ - (0.012))
   SET rptsd->m_width = 3.813
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__respparty2)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.801)
   SET rptsd->m_width = 2.626
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->bill_to_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__guarstreetaddr)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.426)
   SET rptsd->m_width = 0.501
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Phone:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.926)
   SET rptsd->m_width = 1.126
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->bill_to_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__guarphonevalue)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 8.051)
   SET rptsd->m_width = 0.125
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.013)),offsety,(offsetx+ - (0.013)),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.800),offsety,(offsetx+ 3.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.425),offsety,(offsetx+ 6.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.925),offsety,(offsetx+ 6.925),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.050),offsety,(offsetx+ 8.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.175),offsety,(offsetx+ 8.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ 0.000),(offsetx+ 8.176),(
     offsety+ 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ sectionheight),(offsetx+ 8.176
     ),(offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow18(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow18abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow18abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.186923), private
   DECLARE __respstreetaddr2 = vc WITH noconstant(build(insurance_data->resp_street_addr_2,char(0))),
   protect
   DECLARE __guarcitystatezip = vc WITH noconstant(build(concat(req_data->guarantor.address.city,", ",
      req_data->guarantor.address.state," ",req_data->guarantor.address.zipcode),char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ - (0.012))
   SET rptsd->m_width = 3.813
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__respstreetaddr2)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = bor(rpt_sdleftborder,rpt_sdrightborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.801)
   SET rptsd->m_width = 4.251
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->bill_to_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__guarcitystatezip)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 8.051)
   SET rptsd->m_width = 0.125
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.013)),offsety,(offsetx+ - (0.013)),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.800),offsety,(offsetx+ 3.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.050),offsety,(offsetx+ 8.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.175),offsety,(offsetx+ 8.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ 0.000),(offsetx+ 8.176),(
     offsety+ 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ sectionheight),(offsetx+ 8.176
     ),(offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow20(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow20abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow20abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.186923), private
   DECLARE __respcitystatezip2 = vc WITH noconstant(build(insurance_data->resp_citystatezip_2,char(0)
     )), protect
   DECLARE __guarreltnvalue = vc WITH noconstant(build(trim(uar_get_code_display(req_data->guarantor.
       reltn_cd),3),char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ - (0.012))
   SET rptsd->m_width = 3.813
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__respcitystatezip2)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.801)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Relationship:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.675)
   SET rptsd->m_width = 3.376
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->bill_to_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__guarreltnvalue)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 8.051)
   SET rptsd->m_width = 0.125
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.013)),offsety,(offsetx+ - (0.013)),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.800),offsety,(offsetx+ 3.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.675),offsety,(offsetx+ 4.675),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.050),offsety,(offsetx+ 8.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.175),offsety,(offsetx+ 8.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ 0.000),(offsetx+ 8.176),(
     offsety+ 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ sectionheight),(offsetx+ 8.176
     ),(offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow19(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow19abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow19abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.186923), private
   DECLARE __reltn2 = vc WITH noconstant(build(insurance_data->reltn_2,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ - (0.012))
   SET rptsd->m_width = 0.876
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Relationship:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 32
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.863)
   SET rptsd->m_width = 2.938
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__reltn2)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.801)
   SET rptsd->m_width = 2.501
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdrightborder)
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.301)
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 8.051)
   SET rptsd->m_width = 0.125
   SET rptsd->m_height = 0.187
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.013)),offsety,(offsetx+ - (0.013)),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.863),offsety,(offsetx+ 0.863),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.800),offsety,(offsetx+ 3.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.300),offsety,(offsetx+ 6.300),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.050),offsety,(offsetx+ 8.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.175),offsety,(offsetx+ 8.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ 0.000),(offsetx+ 8.176),(
     offsety+ 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ sectionheight),(offsetx+ 8.176
     ),(offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow6(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow6abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow6abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.124604), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ - (0.012))
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.125
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.176)
   SET rptsd->m_width = 2.500
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.676)
   SET rptsd->m_width = 0.126
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.801)
   SET rptsd->m_width = 0.438
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.238)
   SET rptsd->m_width = 3.813
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 8.051)
   SET rptsd->m_width = 0.125
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.013)),offsety,(offsetx+ - (0.013)),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.175),offsety,(offsetx+ 1.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.675),offsety,(offsetx+ 3.675),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.800),offsety,(offsetx+ 3.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.238),offsety,(offsetx+ 4.238),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.050),offsety,(offsetx+ 8.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.175),offsety,(offsetx+ 8.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ 0.000),(offsetx+ 8.176),(
     offsety+ 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ sectionheight),(offsetx+ 8.176
     ),(offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE insuranceinformationabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(3.840000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   DECLARE __concat__ord_phys_____req_data__req_qual_loopvar__o = vc WITH noconstant(build2(req_data
     ->req_qual[loopvar].order_provider.name_full,char(0))), protect
   IF ( NOT (curpage=1))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _yoffset = (offsety+ 0.000)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.000)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow5(rpt_render))
     SET holdheight = (holdheight+ tablerow7(rpt_render))
     SET holdheight = (holdheight+ tablerow8(rpt_render))
     SET holdheight = (holdheight+ tablerow9(rpt_render))
     SET holdheight = (holdheight+ tablerow27(rpt_render))
     SET holdheight = (holdheight+ tablerow29(rpt_render))
     SET holdheight = (holdheight+ tablerow10(rpt_render))
     SET holdheight = (holdheight+ tablerow11(rpt_render))
     SET holdheight = (holdheight+ tablerow12(rpt_render))
     SET holdheight = (holdheight+ tablerow14(rpt_render))
     SET holdheight = (holdheight+ tablerow13(rpt_render))
     SET holdheight = (holdheight+ tablerow15(rpt_render))
     SET holdheight = (holdheight+ tablerow16(rpt_render))
     SET holdheight = (holdheight+ tablerow17(rpt_render))
     SET holdheight = (holdheight+ tablerow18(rpt_render))
     SET holdheight = (holdheight+ tablerow20(rpt_render))
     SET holdheight = (holdheight+ tablerow19(rpt_render))
     SET holdheight = (holdheight+ tablerow6(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 3.376)
    SET rptsd->m_x = (offsetx+ - (0.012))
    SET rptsd->m_width = 2.626
    SET rptsd->m_height = 0.261
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica90)
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,
     __concat__ord_phys_____req_data__req_qual_loopvar__o)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.002)),(offsety+ 3.568),(offsetx+ 3.863),(
     offsety+ 3.568))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.584)
    SET rptsd->m_x = (offsetx+ - (0.012))
    SET rptsd->m_width = 2.626
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Ordering Physician Electronic Signature",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.563)
    SET rptsd->m_x = (offsetx+ 3.050)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.376)
    SET rptsd->m_x = (offsetx+ 3.050)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.261
    IF (curpage=1)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(curdate,char(0)))
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE profilestests(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = profilestestsabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow22(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow22abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow22abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.197917), private
   SET rptsd->m_flags = 16
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ - (0.005))
   SET rptsd->m_width = 8.056
   SET rptsd->m_height = 0.191
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica1016777215)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Profiles/Tests",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.013)),offsety,(offsetx+ - (0.013)),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.050),offsety,(offsetx+ 8.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ 0.000),(offsetx+ 8.051),(
     offsety+ 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.012)),(offsety+ sectionheight),(offsetx+ 8.051
     ),(offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE profilestestsabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _yoffset = (offsety+ 0.000)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.000)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow22(rpt_render))
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
   IF ( NOT ((req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=1)))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 132
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ - (0.012))
    SET rptsd->m_width = 8.063
    SET rptsd->m_height = 0.625
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
 SUBROUTINE testnamebold(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = testnameboldabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow26(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow26abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow26abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   DECLARE __orderstatusval = vc WITH noconstant(build(req_data->req_qual[loopvar].ord_qual[d1.seq].
     order_status,char(0))), protect
   DECLARE __priorityval = vc WITH noconstant(build(uar_get_code_description(req_data->req_qual[
      loopvar].ord_qual[d1.seq].priority_cd),char(0))), protect
   SET rptsd->m_flags = 512
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.363)
   SET rptsd->m_width = 2.563
   SET rptsd->m_height = 0.188
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
   SET rptsd->m_x = (offsetx+ 2.926)
   SET rptsd->m_width = 0.501
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((((req_data->quest_ind=1)) OR ((req_data->all_ind=1))) )
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Priority:",char(0)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.426)
   SET rptsd->m_width = 4.500
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((((req_data->quest_ind=1)) OR ((req_data->all_ind=1))) )
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
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.362),offsety,(offsetx+ 0.362),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.925),offsety,(offsetx+ 2.925),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.425),offsety,(offsetx+ 3.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.925),offsety,(offsetx+ 7.925),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.363),(offsety+ 0.000),(offsetx+ 7.926),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.363),(offsety+ sectionheight),(offsetx+ 7.926),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE testnameboldabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.380000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT ((req_data->req_qual[loopvar].ord_qual[d1.seq].order_status_cd != 6004_ordered)
    AND (req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=0)))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ - (0.012))
    SET rptsd->m_width = 8.063
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica80)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(test_display_name,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _yoffset = (offsety+ 0.188)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.188)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow26(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE testname(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = testnameabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow21(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow21abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow21abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   DECLARE __orderstatusval = vc WITH noconstant(build(req_data->req_qual[loopvar].ord_qual[d1.seq].
     order_status,char(0))), protect
   DECLARE __priorityval = vc WITH noconstant(build(uar_get_code_description(req_data->req_qual[
      loopvar].ord_qual[d1.seq].priority_cd),char(0))), protect
   SET rptsd->m_flags = 512
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.363)
   SET rptsd->m_width = 2.573
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
   SET rptsd->m_x = (offsetx+ 2.936)
   SET rptsd->m_width = 0.490
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((((req_data->quest_ind=1)) OR ((req_data->all_ind=1))) )
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Priority:",char(0)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.425)
   SET rptsd->m_width = 4.501
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((((req_data->quest_ind=1)) OR ((req_data->all_ind=1))) )
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
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.362),offsety,(offsetx+ 0.362),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.935),offsety,(offsetx+ 2.935),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.425),offsety,(offsetx+ 3.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.925),offsety,(offsetx+ 7.925),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.363),(offsety+ 0.000),(offsetx+ 7.926),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.363),(offsety+ sectionheight),(offsetx+ 7.926),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE testnameabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.380000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT ((req_data->req_qual[loopvar].ord_qual[d1.seq].order_status_cd=6004_ordered)
    AND (req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=0)))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ - (0.012))
    SET rptsd->m_width = 8.063
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica80)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(test_display_name,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _yoffset = (offsety+ 0.188)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.188)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow21(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE specimen_details(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = specimen_detailsabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow28(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow28abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow28abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   DECLARE __spectypeval = vc WITH noconstant(build(uar_get_code_display(req_data->req_qual[loopvar].
      ord_qual[d1.seq].specimen_cd),char(0))), protect
   DECLARE __specdescval = vc WITH noconstant(build(req_data->req_qual[loopvar].ord_qual[d1.seq].
     specimen_description,char(0))), protect
   SET rptsd->m_flags = 512
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.363)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Specimen Source:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.488)
   SET rptsd->m_width = 1.938
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__spectypeval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.425)
   SET rptsd->m_width = 1.375
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
   SET rptsd->m_x = (offsetx+ 4.800)
   SET rptsd->m_width = 2.990
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__specdescval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 7.790)
   SET rptsd->m_width = 0.136
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((((req_data->std_ind=1)) OR ((req_data->all_ind=1))) )
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.362),offsety,(offsetx+ 0.362),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.487),offsety,(offsetx+ 1.487),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.425),offsety,(offsetx+ 3.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.800),offsety,(offsetx+ 4.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.790),offsety,(offsetx+ 7.790),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.925),offsety,(offsetx+ 7.925),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.363),(offsety+ 0.000),(offsetx+ 7.926),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.363),(offsety+ sectionheight),(offsetx+ 7.926),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE specimen_detailsabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.310000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT ((req_data->req_qual[loopvar].collected_ind=1)
    AND (req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=0)))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _yoffset = (offsety+ 0.063)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.063)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow28(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE orderdetails(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = orderdetailsabs(ncalc,_xoffset,_yoffset)
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
   SET rptsd->m_x = (offsetx+ 0.363)
   SET rptsd->m_width = 2.563
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
   SET rptsd->m_x = (offsetx+ 2.925)
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
   SET rptsd->m_x = (offsetx+ 5.488)
   SET rptsd->m_width = 2.626
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
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.362),offsety,(offsetx+ 0.362),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.925),offsety,(offsetx+ 2.925),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.487),offsety,(offsetx+ 5.487),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.113),offsety,(offsetx+ 8.113),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.363),(offsety+ 0.000),(offsetx+ 8.114),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.363),(offsety+ sectionheight),(offsetx+ 8.114),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE orderdetailsabs(ncalc,offsetx,offsety)
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
 SUBROUTINE orderdetailmulti(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = orderdetailmultiabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow61(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow61abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow61abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE __multiaoeval = vc WITH noconstant(build(concat(req_data->req_qual[loopvar].ord_qual[d1
      .seq].details[mulord_row].label_text,": ",req_data->req_qual[loopvar].ord_qual[d1.seq].details[
      mulord_row].value),char(0))), protect
   IF (bcontinue=0)
    SET _remmultiaoeval = 1
   ENDIF
   SET rptsd->m_flags = 517
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.353)
   SET rptsd->m_width = 7.719
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremmultiaoeval = _remmultiaoeval
   IF (_remmultiaoeval > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmultiaoeval,((size(
        __multiaoeval) - _remmultiaoeval)+ 1),__multiaoeval)))
    SET drawheight_multiaoeval = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmultiaoeval = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmultiaoeval,((size(__multiaoeval) -
       _remmultiaoeval)+ 1),__multiaoeval)))))
     SET _remmultiaoeval = (_remmultiaoeval+ rptsd->m_drawlength)
    ELSE
     SET _remmultiaoeval = 0
    ENDIF
    SET growsum = (growsum+ _remmultiaoeval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 516
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.353)
   SET rptsd->m_width = 7.719
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (_holdremmultiaoeval > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmultiaoeval,((
        size(__multiaoeval) - _holdremmultiaoeval)+ 1),__multiaoeval)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remmultiaoeval = _holdremmultiaoeval
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
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.352),offsety,(offsetx+ 0.352),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.071),offsety,(offsetx+ 8.071),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.353),(offsety+ 0.000),(offsetx+ 8.072),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.353),(offsety+ sectionheight),(offsetx+ 8.072),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE orderdetailmultiabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF ( NOT ((req_data->req_qual[loopvar].ord_qual[d1.seq].multi_cnt > 0)
    AND (req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=0)))
    RETURN(0.0)
   ENDIF
   SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET _yoffset = (offsety+ 0.000)
   SET _fholdoffsety = (_yoffset - offsety)
   IF (ncalc=rpt_calcheight
    AND bcontinue=0)
    SET _yoffset = (offsety+ 0.000)
    SET holdheight = 0
    IF (growsum=0)
     SET maxheight_tablerow61 = (maxheight - (0.000+ holdheight))
     SET _bholdcontinue = 0
     SET holdheight = (holdheight+ tablerow61(rpt_calcheight,maxheight_tablerow61,_bholdcontinue))
     IF (((_bholdcontinue=1) OR (holdheight > maxheight_tablerow61)) )
      SET growsum = 1
     ENDIF
    ENDIF
    SET _yoffset = offsety
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _yoffset = (offsety+ 0.000)
    SET holdheight = 0
    SET maxheight_tablerow61 = (maxheight - (0.000+ holdheight))
    SET _bholdcontinue = 0
    SET holdheight = (holdheight+ tablerow61(rpt_render,maxheight_tablerow61,_bholdcontinue))
    IF (((0.000+ holdheight) > sectionheight))
     SET sectionheight = (0.000+ holdheight)
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
 SUBROUTINE diagnosiscodes(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = diagnosiscodesabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow24(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow24abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow24abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   DECLARE __diagnosiscodes = vc WITH noconstant(build(concat("ICD Diagnosis Code(s): ",req_data->
      req_qual[loopvar].ord_qual[d1.seq].dx_list),char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.363)
   SET rptsd->m_width = 7.688
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__diagnosiscodes)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.362),offsety,(offsetx+ 0.362),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.050),offsety,(offsetx+ 8.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.363),(offsety+ 0.000),(offsetx+ 8.051),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.363),(offsety+ sectionheight),(offsetx+ 8.051),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE diagnosiscodesabs(ncalc,offsetx,offsety)
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
     SET holdheight = (holdheight+ tablerow24(rpt_render))
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
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.363)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Special Instructions:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.488)
   SET rptsd->m_width = 6.563
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__specialinstructval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.362),offsety,(offsetx+ 0.362),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.487),offsety,(offsetx+ 1.487),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.050),offsety,(offsetx+ 8.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.363),(offsety+ 0.000),(offsetx+ 8.051),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.363),(offsety+ sectionheight),(offsetx+ 8.051),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE specialinstructionsabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.167000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT (size(trim(req_data->req_qual[loopvar].ord_qual[d1.seq].special_instruct)) > 0
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
 SUBROUTINE tablerow25(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow25abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow25abs(ncalc,offsetx,offsety)
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
   SET rptsd->m_x = (offsetx+ 0.363)
   SET rptsd->m_width = 1.063
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
   SET rptsd->m_x = (offsetx+ 1.425)
   SET rptsd->m_width = 6.626
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
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.362),offsety,(offsetx+ 0.362),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.425),offsety,(offsetx+ 1.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.050),offsety,(offsetx+ 8.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.363),(offsety+ 0.000),(offsetx+ 8.051),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.363),(offsety+ sectionheight),(offsetx+ 8.051),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE ordercommentabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.167000), private
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
     SET holdheight = (holdheight+ tablerow25(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footpagesectionspecimenlabel(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footpagesectionspecimenlabelabs(ncalc,_xoffset,_yoffset)
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
   DECLARE sectionheight = f8 WITH noconstant(0.124999), private
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
 SUBROUTINE footpagesectionspecimenlabelabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.770000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT ((req_data->print_quest_labels_ind=1)))
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
 SUBROUTINE footpagesection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footpagesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footpagesectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.540000), private
   DECLARE __transfertemperature = vc WITH noconstant(build2(trim(uar_get_code_display(req_data->
       req_qual[loopvar].transfer_temp_cd)),char(0))), protect
   DECLARE __orderdttm = vc WITH noconstant(build2(concat("Order Date: ",format(order_dt_tm,
       "MM/DD/YYYY HH:MM;;D")),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 2.363)
    SET rptsd->m_width = 2.751
    SET rptsd->m_height = 0.146
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica80)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.032)
    SET rptsd->m_x = (offsetx+ 2.363)
    SET rptsd->m_width = 2.751
    SET rptsd->m_height = 0.146
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__transfertemperature)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 2.425)
    SET rptsd->m_width = 2.688
    SET rptsd->m_height = 0.146
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__orderdttm)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE futureorderwatermark(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = futureorderwatermarkabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE futureorderwatermarkabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(2.000000), private
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
   SET _oldfont = uar_rptsetfont(_hreport,_times7215395562)
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
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "AMB_RLN_QUEST_LYT"
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
   SET rptfont->m_bold = rpt_on
   SET _helvetica10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_off
   SET _helvetica100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 48
   SET rptfont->m_bold = rpt_on
   SET _helvetica48b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 9
   SET rptfont->m_bold = rpt_off
   SET _helvetica90 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET rptfont->m_rgbcolor = rpt_white
   SET _helvetica1016777215 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 8
   SET rptfont->m_rgbcolor = rpt_black
   SET _helvetica80 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 9
   SET rptfont->m_bold = rpt_on
   SET _helvetica9b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 2
   SET rptfont->m_bold = rpt_off
   SET _helvetica20 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 6
   SET _helvetica60 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 72
   SET rptfont->m_rgbcolor = uar_rptencodecolor(234,234,234)
   SET _times7215395562 = uar_rptcreatefont(_hreport,rptfont)
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
   SET rptpen->m_penwidth = 0.001
   SET rptpen->m_rgbcolor = rpt_white
   SET _pen1s0c16777215 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET stat = initrec(order_detail)
 CALL initializereport(0)
 CALL query1(0)
 CALL finalizereport(_sendto)
END GO
