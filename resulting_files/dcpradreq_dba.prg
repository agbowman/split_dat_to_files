CREATE PROGRAM dcpradreq:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c6 WITH noconstant(" "), private
 ENDIF
 SET last_mod = "278609"
 RECORD request(
   1 person_id = f8
   1 print_prsnl_id = f8
   1 order_qual[*]
     2 order_id = f8
     2 encntr_id = f8
     2 conversation_id = f8
   1 printer_name = c50
 )
 IF ((validate(simlab_font_metrics_,- (99))=- (99)))
  DECLARE simlab_font_metrics__ = i2 WITH public, constant(1)
  DECLARE inputstrlen = i4 WITH public, noconstant(0)
  DECLARE fontpoints = i4 WITH public, noconstant(0)
  DECLARE widthtotal = i4 WITH public, noconstant(0)
  DECLARE asciinum = i2 WITH public, noconstant(0)
  DECLARE bold = i2 WITH public, noconstant(0)
  DECLARE tempindx = i4 WITH public, noconstant(0)
  DECLARE retstr = vc WITH public, noconstant(" ")
  DECLARE iretstr = i2 WITH public, noconstant(0)
  DECLARE widthline = i4 WITH public, noconstant(0)
  DECLARE widthstring = i4 WITH public, noconstant(0)
  DECLARE widthword = i4 WITH public, noconstant(0)
  DECLARE widthchar = i2 WITH public, noconstant(0)
  DECLARE widthspace = i4 WITH public, noconstant(0)
  DECLARE spacecnt = i2 WITH public, noconstant(0)
  DECLARE endword = i4 WITH public, noconstant(1)
  DECLARE startsubstr = i4 WITH public, noconstant(1)
  DECLARE endlastline = i2 WITH public, noconstant(0)
  DECLARE endlastlinepts = i4 WITH public, noconstant(0)
  DECLARE state = i2 WITH public, noconstant(0)
  DECLARE cnt = i4 WITH public, noconstant(1)
  DECLARE boldstart = i4 WITH public, noconstant(0)
  DECLARE nonboldstart = i4 WITH public, noconstant(0)
  FREE SET simlabwrappedtext
  RECORD simlabwrappedtext(
    1 output_string_cnt = i2
    1 output_string[*]
      2 string = vc
      2 x_offset = i4
      2 bold = i2
  )
  IF ((validate(simlab_font_metrics_helvetica_,- (99))=- (99)))
   DECLARE simlab_font_metrics_helvetica_ = i2 WITH public, constant(1)
   DECLARE stringwidthhelvetica(inputstring=vc,cpi=i2,bold=i2) = i4
   DECLARE truncatestringhelvetica(inputstring=vc,cpi=i2,bold=i2,slength=i2) = vc
   DECLARE wordwraphelvetica(input_string=vc,cpi=i2,line_width=i2,bold_start=i2) = i2
   DECLARE characterwraphelvetica(input_string=vc,cpi=i2,line_width=i2,bold_start=i2) = i2
   IF ((validate(simlab_font_metrics_helvetica_rec_,- (99))=- (99)))
    DECLARE simlab_font_metrics_helvetica_rec_ = i2 WITH public, constant(1)
    FREE SET metrics_h
    RECORD metrics_h(
      1 helvetica_cnt = i2
      1 helvetica[*]
        2 size = i2
      1 helvetica_bold_cnt = i2
      1 helvetica_bold[*]
        2 size = i2
    )
   ENDIF
   SET simlabwrappedtext->output_string_cnt = 0
   SET metrics_h->helvetica_cnt = 253
   SET stat = alterlist(metrics_h->helvetica,metrics_h->helvetica_cnt)
   FOR (tempindx = 1 TO 31)
     SET metrics_h->helvetica[tempindx].size = 0
   ENDFOR
   SET metrics_h->helvetica[32].size = 278
   SET metrics_h->helvetica[33].size = 278
   SET metrics_h->helvetica[34].size = 355
   SET metrics_h->helvetica[35].size = 556
   SET metrics_h->helvetica[36].size = 556
   SET metrics_h->helvetica[37].size = 889
   SET metrics_h->helvetica[38].size = 667
   SET metrics_h->helvetica[39].size = 222
   SET metrics_h->helvetica[40].size = 333
   SET metrics_h->helvetica[41].size = 333
   SET metrics_h->helvetica[42].size = 389
   SET metrics_h->helvetica[43].size = 584
   SET metrics_h->helvetica[44].size = 278
   SET metrics_h->helvetica[45].size = 333
   SET metrics_h->helvetica[46].size = 278
   SET metrics_h->helvetica[47].size = 278
   SET metrics_h->helvetica[48].size = 556
   SET metrics_h->helvetica[49].size = 556
   SET metrics_h->helvetica[50].size = 556
   SET metrics_h->helvetica[51].size = 556
   SET metrics_h->helvetica[52].size = 556
   SET metrics_h->helvetica[53].size = 556
   SET metrics_h->helvetica[54].size = 556
   SET metrics_h->helvetica[55].size = 556
   SET metrics_h->helvetica[56].size = 556
   SET metrics_h->helvetica[57].size = 556
   SET metrics_h->helvetica[58].size = 278
   SET metrics_h->helvetica[59].size = 278
   SET metrics_h->helvetica[60].size = 584
   SET metrics_h->helvetica[61].size = 584
   SET metrics_h->helvetica[62].size = 584
   SET metrics_h->helvetica[63].size = 556
   SET metrics_h->helvetica[64].size = 1015
   SET metrics_h->helvetica[65].size = 667
   SET metrics_h->helvetica[66].size = 667
   SET metrics_h->helvetica[67].size = 722
   SET metrics_h->helvetica[68].size = 722
   SET metrics_h->helvetica[69].size = 667
   SET metrics_h->helvetica[70].size = 611
   SET metrics_h->helvetica[71].size = 778
   SET metrics_h->helvetica[72].size = 722
   SET metrics_h->helvetica[73].size = 278
   SET metrics_h->helvetica[74].size = 500
   SET metrics_h->helvetica[75].size = 667
   SET metrics_h->helvetica[76].size = 556
   SET metrics_h->helvetica[77].size = 833
   SET metrics_h->helvetica[78].size = 722
   SET metrics_h->helvetica[79].size = 778
   SET metrics_h->helvetica[80].size = 667
   SET metrics_h->helvetica[81].size = 778
   SET metrics_h->helvetica[82].size = 722
   SET metrics_h->helvetica[83].size = 667
   SET metrics_h->helvetica[84].size = 611
   SET metrics_h->helvetica[85].size = 722
   SET metrics_h->helvetica[86].size = 667
   SET metrics_h->helvetica[87].size = 944
   SET metrics_h->helvetica[88].size = 667
   SET metrics_h->helvetica[89].size = 667
   SET metrics_h->helvetica[90].size = 611
   SET metrics_h->helvetica[91].size = 278
   SET metrics_h->helvetica[92].size = 278
   SET metrics_h->helvetica[93].size = 278
   SET metrics_h->helvetica[94].size = 469
   SET metrics_h->helvetica[95].size = 556
   SET metrics_h->helvetica[96].size = 222
   SET metrics_h->helvetica[97].size = 556
   SET metrics_h->helvetica[98].size = 556
   SET metrics_h->helvetica[99].size = 500
   SET metrics_h->helvetica[100].size = 556
   SET metrics_h->helvetica[101].size = 556
   SET metrics_h->helvetica[102].size = 278
   SET metrics_h->helvetica[103].size = 556
   SET metrics_h->helvetica[104].size = 556
   SET metrics_h->helvetica[105].size = 222
   SET metrics_h->helvetica[106].size = 222
   SET metrics_h->helvetica[107].size = 500
   SET metrics_h->helvetica[108].size = 222
   SET metrics_h->helvetica[109].size = 833
   SET metrics_h->helvetica[110].size = 556
   SET metrics_h->helvetica[111].size = 556
   SET metrics_h->helvetica[112].size = 556
   SET metrics_h->helvetica[113].size = 556
   SET metrics_h->helvetica[114].size = 333
   SET metrics_h->helvetica[115].size = 500
   SET metrics_h->helvetica[116].size = 278
   SET metrics_h->helvetica[117].size = 556
   SET metrics_h->helvetica[118].size = 500
   SET metrics_h->helvetica[119].size = 722
   SET metrics_h->helvetica[120].size = 500
   SET metrics_h->helvetica[121].size = 500
   SET metrics_h->helvetica[122].size = 500
   SET metrics_h->helvetica[123].size = 334
   SET metrics_h->helvetica[124].size = 260
   SET metrics_h->helvetica[125].size = 334
   SET metrics_h->helvetica[126].size = 584
   FOR (tempindx = 127 TO 160)
     SET metrics_h->helvetica[tempindx].size = 0
   ENDFOR
   SET metrics_h->helvetica[161].size = 333
   SET metrics_h->helvetica[162].size = 556
   SET metrics_h->helvetica[163].size = 556
   SET metrics_h->helvetica[164].size = 0
   SET metrics_h->helvetica[165].size = 556
   SET metrics_h->helvetica[166].size = 0
   SET metrics_h->helvetica[167].size = 556
   SET metrics_h->helvetica[168].size = 556
   SET metrics_h->helvetica[169].size = 611
   SET metrics_h->helvetica[170].size = 333
   SET metrics_h->helvetica[171].size = 556
   SET metrics_h->helvetica[172].size = 0
   SET metrics_h->helvetica[173].size = 0
   SET metrics_h->helvetica[174].size = 0
   SET metrics_h->helvetica[175].size = 0
   SET metrics_h->helvetica[176].size = 0
   SET metrics_h->helvetica[177].size = 556
   SET metrics_h->helvetica[178].size = 556
   SET metrics_h->helvetica[179].size = 556
   SET metrics_h->helvetica[180].size = 278
   SET metrics_h->helvetica[181].size = 0
   SET metrics_h->helvetica[182].size = 537
   SET metrics_h->helvetica[183].size = 350
   SET metrics_h->helvetica[184].size = 222
   SET metrics_h->helvetica[185].size = 333
   SET metrics_h->helvetica[186].size = 333
   SET metrics_h->helvetica[187].size = 556
   SET metrics_h->helvetica[188].size = 1000
   SET metrics_h->helvetica[189].size = 1000
   SET metrics_h->helvetica[190].size = 0
   SET metrics_h->helvetica[191].size = 611
   SET metrics_h->helvetica[192].size = 667
   SET metrics_h->helvetica[193].size = 667
   SET metrics_h->helvetica[194].size = 667
   SET metrics_h->helvetica[195].size = 667
   SET metrics_h->helvetica[196].size = 667
   SET metrics_h->helvetica[197].size = 667
   SET metrics_h->helvetica[198].size = 1000
   SET metrics_h->helvetica[199].size = 722
   SET metrics_h->helvetica[200].size = 667
   SET metrics_h->helvetica[201].size = 667
   SET metrics_h->helvetica[202].size = 667
   SET metrics_h->helvetica[203].size = 667
   SET metrics_h->helvetica[204].size = 278
   SET metrics_h->helvetica[205].size = 278
   SET metrics_h->helvetica[206].size = 278
   SET metrics_h->helvetica[207].size = 278
   SET metrics_h->helvetica[208].size = 0
   SET metrics_h->helvetica[209].size = 722
   SET metrics_h->helvetica[210].size = 778
   SET metrics_h->helvetica[211].size = 778
   SET metrics_h->helvetica[212].size = 778
   SET metrics_h->helvetica[213].size = 778
   SET metrics_h->helvetica[214].size = 778
   SET metrics_h->helvetica[215].size = 0
   SET metrics_h->helvetica[216].size = 0
   SET metrics_h->helvetica[217].size = 722
   SET metrics_h->helvetica[218].size = 722
   SET metrics_h->helvetica[219].size = 722
   SET metrics_h->helvetica[220].size = 722
   SET metrics_h->helvetica[221].size = 0
   SET metrics_h->helvetica[222].size = 0
   SET metrics_h->helvetica[223].size = 0
   SET metrics_h->helvetica[224].size = 556
   SET metrics_h->helvetica[225].size = 556
   SET metrics_h->helvetica[226].size = 556
   SET metrics_h->helvetica[227].size = 556
   SET metrics_h->helvetica[228].size = 556
   SET metrics_h->helvetica[229].size = 556
   SET metrics_h->helvetica[230].size = 0
   SET metrics_h->helvetica[231].size = 0
   SET metrics_h->helvetica[232].size = 556
   SET metrics_h->helvetica[233].size = 556
   SET metrics_h->helvetica[234].size = 556
   SET metrics_h->helvetica[235].size = 556
   SET metrics_h->helvetica[236].size = 222
   SET metrics_h->helvetica[237].size = 222
   SET metrics_h->helvetica[238].size = 222
   SET metrics_h->helvetica[239].size = 222
   SET metrics_h->helvetica[240].size = 0
   SET metrics_h->helvetica[241].size = 556
   SET metrics_h->helvetica[242].size = 556
   SET metrics_h->helvetica[243].size = 556
   SET metrics_h->helvetica[244].size = 556
   SET metrics_h->helvetica[245].size = 556
   SET metrics_h->helvetica[246].size = 556
   SET metrics_h->helvetica[247].size = 0
   SET metrics_h->helvetica[248].size = 556
   SET metrics_h->helvetica[249].size = 556
   SET metrics_h->helvetica[250].size = 556
   SET metrics_h->helvetica[251].size = 556
   SET metrics_h->helvetica[252].size = 556
   SET metrics_h->helvetica[253].size = 500
   SET metrics_h->helvetica_bold_cnt = 253
   SET stat = alterlist(metrics_h->helvetica_bold,metrics_h->helvetica_bold_cnt)
   FOR (tempindx = 1 TO 31)
     SET metrics_h->helvetica_bold[tempindx].size = 0
   ENDFOR
   SET metrics_h->helvetica_bold[32].size = 278
   SET metrics_h->helvetica_bold[33].size = 333
   SET metrics_h->helvetica_bold[34].size = 474
   SET metrics_h->helvetica_bold[35].size = 556
   SET metrics_h->helvetica_bold[36].size = 556
   SET metrics_h->helvetica_bold[37].size = 889
   SET metrics_h->helvetica_bold[38].size = 722
   SET metrics_h->helvetica_bold[39].size = 278
   SET metrics_h->helvetica_bold[40].size = 333
   SET metrics_h->helvetica_bold[41].size = 333
   SET metrics_h->helvetica_bold[42].size = 389
   SET metrics_h->helvetica_bold[43].size = 584
   SET metrics_h->helvetica_bold[44].size = 278
   SET metrics_h->helvetica_bold[45].size = 333
   SET metrics_h->helvetica_bold[46].size = 278
   SET metrics_h->helvetica_bold[47].size = 278
   SET metrics_h->helvetica_bold[48].size = 556
   SET metrics_h->helvetica_bold[49].size = 556
   SET metrics_h->helvetica_bold[50].size = 556
   SET metrics_h->helvetica_bold[51].size = 556
   SET metrics_h->helvetica_bold[52].size = 556
   SET metrics_h->helvetica_bold[53].size = 556
   SET metrics_h->helvetica_bold[54].size = 556
   SET metrics_h->helvetica_bold[55].size = 556
   SET metrics_h->helvetica_bold[56].size = 556
   SET metrics_h->helvetica_bold[57].size = 556
   SET metrics_h->helvetica_bold[58].size = 333
   SET metrics_h->helvetica_bold[59].size = 333
   SET metrics_h->helvetica_bold[60].size = 584
   SET metrics_h->helvetica_bold[61].size = 584
   SET metrics_h->helvetica_bold[62].size = 584
   SET metrics_h->helvetica_bold[63].size = 611
   SET metrics_h->helvetica_bold[64].size = 975
   SET metrics_h->helvetica_bold[65].size = 722
   SET metrics_h->helvetica_bold[66].size = 722
   SET metrics_h->helvetica_bold[67].size = 722
   SET metrics_h->helvetica_bold[68].size = 722
   SET metrics_h->helvetica_bold[69].size = 667
   SET metrics_h->helvetica_bold[70].size = 611
   SET metrics_h->helvetica_bold[71].size = 778
   SET metrics_h->helvetica_bold[72].size = 722
   SET metrics_h->helvetica_bold[73].size = 278
   SET metrics_h->helvetica_bold[74].size = 556
   SET metrics_h->helvetica_bold[75].size = 722
   SET metrics_h->helvetica_bold[76].size = 611
   SET metrics_h->helvetica_bold[77].size = 833
   SET metrics_h->helvetica_bold[78].size = 722
   SET metrics_h->helvetica_bold[79].size = 778
   SET metrics_h->helvetica_bold[80].size = 667
   SET metrics_h->helvetica_bold[81].size = 778
   SET metrics_h->helvetica_bold[82].size = 722
   SET metrics_h->helvetica_bold[83].size = 667
   SET metrics_h->helvetica_bold[84].size = 611
   SET metrics_h->helvetica_bold[85].size = 722
   SET metrics_h->helvetica_bold[86].size = 667
   SET metrics_h->helvetica_bold[87].size = 944
   SET metrics_h->helvetica_bold[88].size = 667
   SET metrics_h->helvetica_bold[89].size = 667
   SET metrics_h->helvetica_bold[90].size = 611
   SET metrics_h->helvetica_bold[91].size = 333
   SET metrics_h->helvetica_bold[92].size = 278
   SET metrics_h->helvetica_bold[93].size = 333
   SET metrics_h->helvetica_bold[94].size = 584
   SET metrics_h->helvetica_bold[95].size = 556
   SET metrics_h->helvetica_bold[96].size = 278
   SET metrics_h->helvetica_bold[97].size = 556
   SET metrics_h->helvetica_bold[98].size = 611
   SET metrics_h->helvetica_bold[99].size = 556
   SET metrics_h->helvetica_bold[100].size = 611
   SET metrics_h->helvetica_bold[101].size = 556
   SET metrics_h->helvetica_bold[102].size = 333
   SET metrics_h->helvetica_bold[103].size = 611
   SET metrics_h->helvetica_bold[104].size = 611
   SET metrics_h->helvetica_bold[105].size = 278
   SET metrics_h->helvetica_bold[106].size = 278
   SET metrics_h->helvetica_bold[107].size = 556
   SET metrics_h->helvetica_bold[108].size = 278
   SET metrics_h->helvetica_bold[109].size = 889
   SET metrics_h->helvetica_bold[110].size = 611
   SET metrics_h->helvetica_bold[111].size = 611
   SET metrics_h->helvetica_bold[112].size = 611
   SET metrics_h->helvetica_bold[113].size = 611
   SET metrics_h->helvetica_bold[114].size = 389
   SET metrics_h->helvetica_bold[115].size = 556
   SET metrics_h->helvetica_bold[116].size = 333
   SET metrics_h->helvetica_bold[117].size = 611
   SET metrics_h->helvetica_bold[118].size = 556
   SET metrics_h->helvetica_bold[119].size = 778
   SET metrics_h->helvetica_bold[120].size = 556
   SET metrics_h->helvetica_bold[121].size = 556
   SET metrics_h->helvetica_bold[122].size = 500
   SET metrics_h->helvetica_bold[123].size = 389
   SET metrics_h->helvetica_bold[124].size = 280
   SET metrics_h->helvetica_bold[125].size = 389
   SET metrics_h->helvetica_bold[126].size = 584
   FOR (tempindx = 127 TO 160)
     SET metrics_h->helvetica_bold[tempindx].size = 0
   ENDFOR
   SET metrics_h->helvetica_bold[161].size = 333
   SET metrics_h->helvetica_bold[162].size = 556
   SET metrics_h->helvetica_bold[163].size = 556
   SET metrics_h->helvetica_bold[164].size = 0
   SET metrics_h->helvetica_bold[165].size = 556
   SET metrics_h->helvetica_bold[166].size = 0
   SET metrics_h->helvetica_bold[167].size = 556
   SET metrics_h->helvetica_bold[168].size = 556
   SET metrics_h->helvetica_bold[169].size = 238
   SET metrics_h->helvetica_bold[170].size = 500
   SET metrics_h->helvetica_bold[171].size = 556
   SET metrics_h->helvetica_bold[172].size = 0
   SET metrics_h->helvetica_bold[173].size = 0
   SET metrics_h->helvetica_bold[174].size = 0
   SET metrics_h->helvetica_bold[175].size = 0
   SET metrics_h->helvetica_bold[176].size = 0
   SET metrics_h->helvetica_bold[177].size = 556
   SET metrics_h->helvetica_bold[178].size = 556
   SET metrics_h->helvetica_bold[179].size = 556
   SET metrics_h->helvetica_bold[180].size = 278
   SET metrics_h->helvetica_bold[181].size = 0
   SET metrics_h->helvetica_bold[182].size = 556
   SET metrics_h->helvetica_bold[183].size = 350
   SET metrics_h->helvetica_bold[184].size = 0
   SET metrics_h->helvetica_bold[185].size = 500
   SET metrics_h->helvetica_bold[186].size = 500
   SET metrics_h->helvetica_bold[187].size = 556
   SET metrics_h->helvetica_bold[188].size = 1000
   SET metrics_h->helvetica_bold[189].size = 1000
   SET metrics_h->helvetica_bold[190].size = 0
   SET metrics_h->helvetica_bold[191].size = 611
   SET metrics_h->helvetica_bold[192].size = 722
   SET metrics_h->helvetica_bold[193].size = 722
   SET metrics_h->helvetica_bold[194].size = 722
   SET metrics_h->helvetica_bold[195].size = 722
   SET metrics_h->helvetica_bold[196].size = 722
   SET metrics_h->helvetica_bold[197].size = 722
   SET metrics_h->helvetica_bold[198].size = 1000
   SET metrics_h->helvetica_bold[199].size = 722
   SET metrics_h->helvetica_bold[200].size = 667
   SET metrics_h->helvetica_bold[201].size = 667
   SET metrics_h->helvetica_bold[202].size = 667
   SET metrics_h->helvetica_bold[203].size = 667
   SET metrics_h->helvetica_bold[204].size = 278
   SET metrics_h->helvetica_bold[205].size = 278
   SET metrics_h->helvetica_bold[206].size = 278
   SET metrics_h->helvetica_bold[207].size = 278
   SET metrics_h->helvetica_bold[208].size = 0
   SET metrics_h->helvetica_bold[209].size = 722
   SET metrics_h->helvetica_bold[210].size = 778
   SET metrics_h->helvetica_bold[211].size = 778
   SET metrics_h->helvetica_bold[212].size = 778
   SET metrics_h->helvetica_bold[213].size = 778
   SET metrics_h->helvetica_bold[214].size = 778
   SET metrics_h->helvetica_bold[215].size = 0
   SET metrics_h->helvetica_bold[216].size = 0
   SET metrics_h->helvetica_bold[217].size = 722
   SET metrics_h->helvetica_bold[218].size = 722
   SET metrics_h->helvetica_bold[219].size = 722
   SET metrics_h->helvetica_bold[220].size = 722
   SET metrics_h->helvetica_bold[221].size = 0
   SET metrics_h->helvetica_bold[222].size = 0
   SET metrics_h->helvetica_bold[223].size = 0
   SET metrics_h->helvetica_bold[224].size = 556
   SET metrics_h->helvetica_bold[225].size = 556
   SET metrics_h->helvetica_bold[226].size = 556
   SET metrics_h->helvetica_bold[227].size = 556
   SET metrics_h->helvetica_bold[228].size = 556
   SET metrics_h->helvetica_bold[229].size = 556
   SET metrics_h->helvetica_bold[230].size = 0
   SET metrics_h->helvetica_bold[231].size = 0
   SET metrics_h->helvetica_bold[232].size = 556
   SET metrics_h->helvetica_bold[233].size = 556
   SET metrics_h->helvetica_bold[234].size = 556
   SET metrics_h->helvetica_bold[235].size = 556
   SET metrics_h->helvetica_bold[236].size = 278
   SET metrics_h->helvetica_bold[237].size = 278
   SET metrics_h->helvetica_bold[238].size = 278
   SET metrics_h->helvetica_bold[239].size = 278
   SET metrics_h->helvetica_bold[240].size = 0
   SET metrics_h->helvetica_bold[241].size = 611
   SET metrics_h->helvetica_bold[242].size = 611
   SET metrics_h->helvetica_bold[243].size = 611
   SET metrics_h->helvetica_bold[244].size = 611
   SET metrics_h->helvetica_bold[245].size = 611
   SET metrics_h->helvetica_bold[246].size = 611
   SET metrics_h->helvetica_bold[247].size = 0
   SET metrics_h->helvetica_bold[248].size = 611
   SET metrics_h->helvetica_bold[249].size = 611
   SET metrics_h->helvetica_bold[250].size = 611
   SET metrics_h->helvetica_bold[251].size = 611
   SET metrics_h->helvetica_bold[252].size = 611
   SET metrics_h->helvetica_bold[253].size = 556
   SUBROUTINE stringwidthhelvetica(inputstring,cpi,bold)
     IF (cpi > 0)
      SET fontpoints = floor(((120.0/ cpi)+ 0.5))
     ELSE
      SET fontpoints = 0
     ENDIF
     SET inputstrlen = textlen(inputstring)
     SET widthtotal = 0
     FOR (tempindx = 1 TO inputstrlen)
      SET asciinum = ichar(substring(tempindx,1,inputstring))
      IF (asciinum <= 253)
       IF (bold=0)
        SET widthtotal = (widthtotal+ (fontpoints * metrics_h->helvetica[asciinum].size))
       ELSE
        SET widthtotal = (widthtotal+ (fontpoints * metrics_h->helvetica_bold[asciinum].size))
       ENDIF
      ENDIF
     ENDFOR
     RETURN(widthtotal)
   END ;Subroutine
   SUBROUTINE truncatestringhelvetica(inputstring,cpi,bold,slength)
     IF (cpi > 0)
      SET fontpoints = floor(((120.0/ cpi)+ 0.5))
     ELSE
      SET fontpoints = 0
     ENDIF
     SET inputstrlen = textlen(inputstring)
     SET widthtotal = 0
     SET tempindx = 0
     WHILE (widthtotal < slength)
       SET tempindx = (tempindx+ 1)
       SET asciinum = ichar(substring(tempindx,1,inputstring))
       IF (asciinum <= 253)
        IF (bold=0)
         SET widthtotal = (widthtotal+ (fontpoints * metrics_h->helvetica[asciinum].size))
        ELSE
         SET widthtotal = (widthtotal+ (fontpoints * metrics_h->helvetica_bold[asciinum].size))
        ENDIF
       ENDIF
     ENDWHILE
     SET tempindx = (tempindx - 1)
     IF (tempindx > 0)
      SET retstr = trim(substring(1,tempindx,inputstring))
     ENDIF
     RETURN(retstr)
   END ;Subroutine
   SUBROUTINE wordwraphelvetica(input_string,cpi,line_width,bold_start)
     IF (cpi > 0)
      SET fontpoints = floor(((120.0/ cpi)+ 0.5))
     ELSE
      SET fontpoints = 0
     ENDIF
     SET inputstrlen = textlen(input_string)
     SET widthline = line_width
     SET widthtotal = 0
     SET widthword = 0
     SET widthspace = 0
     SET spacecnt = 0
     SET endword = 1
     SET startsubstr = 1
     SET endlastline = 1
     SET endlastlinepts = 0
     SET state = 0
     SET bold = bold_start
     SET boldstart = 0
     SET nonboldstart = 0
     SET simlabwrappedtext->output_string_cnt = 0
     IF ((widthline > (1015 * fontpoints))
      AND fontpoints <= 120)
      SET cnt = 1
      WHILE (cnt <= inputstrlen)
        SET asciinum = ichar(substring(cnt,1,input_string))
        IF (((asciinum < 32) OR (asciinum > 253)) )
         SET input_string = concat(substring(1,(cnt - 1),input_string),substring((cnt+ 1),(
           inputstrlen - cnt),input_string))
         SET inputstrlen = (inputstrlen - 1)
         SET cnt = (cnt - 1)
        ELSEIF (asciinum=187)
         SET input_string = concat(substring(1,(cnt - 1),input_string),substring((cnt+ 1),(
           inputstrlen - cnt),input_string))
         SET inputstrlen = (inputstrlen - 1)
         IF (bold=0)
          SET boldstart = cnt
          IF (((widthword+ widthspace) > 0))
           SET simlabwrappedtext->output_string_cnt = (simlabwrappedtext->output_string_cnt+ 1)
           IF (mod(simlabwrappedtext->output_string_cnt,10)=1)
            SET stat = alterlist(simlabwrappedtext->output_string,(simlabwrappedtext->
             output_string_cnt+ 9))
           ENDIF
           SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].string = notrim
           (substring(startsubstr,(cnt - startsubstr),input_string))
           SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].bold = bold
           SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].x_offset =
           floor((endlastlinepts+ 0.5))
           IF (state=0)
            SET endlastlinepts = (widthtotal+ widthspace)
           ELSE
            SET endlastlinepts = ((widthtotal+ widthspace)+ widthword)
           ENDIF
           SET startsubstr = cnt
          ENDIF
          SET bold = 1
         ENDIF
         SET cnt = (cnt - 1)
        ELSEIF (asciinum=171)
         SET input_string = concat(substring(1,(cnt - 1),input_string),substring((cnt+ 1),(
           inputstrlen - cnt),input_string))
         SET inputstrlen = (inputstrlen - 1)
         IF (bold=1)
          SET nonboldstart = cnt
          IF (((widthword+ widthspace) > 0))
           SET simlabwrappedtext->output_string_cnt = (simlabwrappedtext->output_string_cnt+ 1)
           IF (mod(simlabwrappedtext->output_string_cnt,10)=1)
            SET stat = alterlist(simlabwrappedtext->output_string,(simlabwrappedtext->
             output_string_cnt+ 9))
           ENDIF
           SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].string = notrim
           (substring(startsubstr,(cnt - startsubstr),input_string))
           SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].bold = bold
           SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].x_offset =
           floor((endlastlinepts+ 0.5))
           IF (state=0)
            SET endlastlinepts = (widthtotal+ widthspace)
           ELSE
            SET endlastlinepts = ((widthtotal+ widthspace)+ widthword)
           ENDIF
           SET startsubstr = cnt
          ENDIF
          SET bold = 0
         ENDIF
         SET cnt = (cnt - 1)
        ELSEIF (asciinum=32)
         IF (state=1)
          SET state = 0
          SET spacecnt = 0
          SET widthtotal = ((widthtotal+ widthspace)+ widthword)
          SET widthspace = 0
          SET endword = cnt
         ENDIF
         SET spacecnt = (spacecnt+ 1)
         IF (bold=1)
          SET widthspace = (widthspace+ (fontpoints * metrics_h->helvetica_bold[asciinum].size))
         ELSE
          SET widthspace = (widthspace+ (fontpoints * metrics_h->helvetica[asciinum].size))
         ENDIF
        ELSE
         IF (state=0)
          SET state = 1
          SET widthword = 0
         ENDIF
         IF (bold=1)
          SET widthchar = (fontpoints * metrics_h->helvetica_bold[asciinum].size)
         ELSE
          SET widthchar = (fontpoints * metrics_h->helvetica[asciinum].size)
         ENDIF
         IF (widthchar=0)
          SET input_string = concat(substring(1,(cnt - 1),input_string),substring((cnt+ 1),(
            inputstrlen - cnt),input_string))
          SET inputstrlen = (inputstrlen - 1)
          SET cnt = (cnt - 1)
         ELSE
          SET widthword = (widthword+ widthchar)
          IF ((((widthtotal+ widthspace)+ widthword) >= widthline))
           IF (endlastline=endword)
            SET endword = cnt
           ENDIF
           IF (((endword - startsubstr) > 0))
            SET simlabwrappedtext->output_string_cnt = (simlabwrappedtext->output_string_cnt+ 1)
            IF (mod(simlabwrappedtext->output_string_cnt,10)=1)
             SET stat = alterlist(simlabwrappedtext->output_string,(simlabwrappedtext->
              output_string_cnt+ 9))
            ENDIF
            IF (endlastlinepts=0)
             SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].string = trim
             (substring(startsubstr,(endword - startsubstr),input_string),3)
            ELSE
             SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].string =
             substring(startsubstr,(endword - startsubstr),input_string)
            ENDIF
            IF (endword=cnt)
             SET startsubstr = cnt
             SET widthword = widthchar
            ELSE
             SET startsubstr = (endword+ spacecnt)
            ENDIF
            SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].x_offset =
            floor((endlastlinepts+ 0.5))
            SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].bold = bold
           ENDIF
           SET endlastline = endword
           SET endlastlinepts = 0
           SET widthtotal = 0
           SET widthspace = 0
          ENDIF
         ENDIF
        ENDIF
        SET cnt = (cnt+ 1)
      ENDWHILE
      SET simlabwrappedtext->output_string_cnt = (simlabwrappedtext->output_string_cnt+ 1)
      SET stat = alterlist(simlabwrappedtext->output_string,simlabwrappedtext->output_string_cnt)
      SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].string = substring(
       startsubstr,((inputstrlen - startsubstr)+ 1),input_string)
      SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].x_offset = floor((
       endlastlinepts+ 0.5))
      SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].bold = bold
     ENDIF
   END ;Subroutine
   SUBROUTINE characterwraphelvetica(input_string,cpi,line_width,bold_start)
     IF (cpi > 0)
      SET fontpoints = floor(((120.0/ cpi)+ 0.5))
     ELSE
      SET fontpoints = 0
     ENDIF
     SET inputstrlen = textlen(input_string)
     SET widthline = line_width
     SET widthtotal = 0
     SET widthword = 0
     SET widthspace = 0
     SET spacecnt = 0
     SET endword = 1
     SET startsubstr = 1
     SET endlastline = 1
     SET endlastlinepts = 0
     SET state = 0
     SET bold = bold_start
     SET boldstart = 0
     SET nonboldstart = 0
     SET simlabwrappedtext->output_string_cnt = 0
     IF ((widthline > (1015 * fontpoints))
      AND fontpoints <= 120)
      SET cnt = 1
      WHILE (cnt <= inputstrlen)
        SET asciinum = ichar(substring(cnt,1,input_string))
        IF (((asciinum < 32) OR (asciinum > 253)) )
         SET input_string = concat(substring(1,(cnt - 1),input_string),substring((cnt+ 1),(
           inputstrlen - cnt),input_string))
         SET inputstrlen = (inputstrlen - 1)
         SET cnt = (cnt - 1)
        ELSEIF (asciinum=187)
         SET input_string = concat(substring(1,(cnt - 1),input_string),substring((cnt+ 1),(
           inputstrlen - cnt),input_string))
         SET inputstrlen = (inputstrlen - 1)
         IF (bold=0)
          SET boldstart = cnt
          IF (widthtotal > 0)
           SET endword = cnt
           SET simlabwrappedtext->output_string_cnt = (simlabwrappedtext->output_string_cnt+ 1)
           IF (mod(simlabwrappedtext->output_string_cnt,10)=1)
            SET stat = alterlist(simlabwrappedtext->output_string,(simlabwrappedtext->
             output_string_cnt+ 9))
           ENDIF
           SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].string = notrim
           (substring(startsubstr,(endword - startsubstr),input_string))
           SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].bold = bold
           SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].x_offset =
           floor((endlastlinepts+ 0.5))
           SET endlastlinepts = widthtotal
           SET startsubstr = cnt
          ENDIF
          SET bold = 1
         ENDIF
         SET cnt = (cnt - 1)
        ELSEIF (asciinum=171)
         SET input_string = concat(substring(1,(cnt - 1),input_string),substring((cnt+ 1),(
           inputstrlen - cnt),input_string))
         SET inputstrlen = (inputstrlen - 1)
         IF (bold=1)
          SET nonboldstart = cnt
          IF (widthtotal > 0)
           SET endword = cnt
           SET simlabwrappedtext->output_string_cnt = (simlabwrappedtext->output_string_cnt+ 1)
           IF (mod(simlabwrappedtext->output_string_cnt,10)=1)
            SET stat = alterlist(simlabwrappedtext->output_string,(simlabwrappedtext->
             output_string_cnt+ 9))
           ENDIF
           SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].string = notrim
           (substring(startsubstr,(endword - startsubstr),input_string))
           SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].bold = bold
           SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].x_offset =
           floor((endlastlinepts+ 0.5))
           SET endlastlinepts = widthtotal
           SET startsubstr = cnt
          ENDIF
          SET bold = 0
         ENDIF
         SET cnt = (cnt - 1)
        ELSE
         IF (bold=1)
          SET widthchar = (fontpoints * metrics_h->helvetica_bold[asciinum].size)
         ELSE
          SET widthchar = (fontpoints * metrics_h->helvetica[asciinum].size)
         ENDIF
         IF (widthchar=0)
          SET input_string = concat(substring(1,(cnt - 1),input_string),substring((cnt+ 1),(
            inputstrlen - cnt),input_string))
          SET inputstrlen = (inputstrlen - 1)
          SET cnt = (cnt - 1)
         ELSE
          IF (((widthtotal+ widthchar) >= widthline))
           SET endword = cnt
           IF (((endword - startsubstr) > 0))
            SET simlabwrappedtext->output_string_cnt = (simlabwrappedtext->output_string_cnt+ 1)
            IF (mod(simlabwrappedtext->output_string_cnt,10)=1)
             SET stat = alterlist(simlabwrappedtext->output_string,(simlabwrappedtext->
              output_string_cnt+ 9))
            ENDIF
            IF (endlastlinepts=0)
             SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].string = trim
             (substring(startsubstr,(endword - startsubstr),input_string),3)
            ELSE
             SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].string =
             substring(startsubstr,(endword - startsubstr),input_string)
            ENDIF
            SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].x_offset =
            floor((endlastlinepts+ 0.5))
            SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].bold = bold
           ENDIF
           SET startsubstr = cnt
           SET endlastlinepts = 0
           SET widthtotal = widthchar
          ELSE
           SET widthtotal = (widthtotal+ widthchar)
          ENDIF
         ENDIF
        ENDIF
        SET cnt = (cnt+ 1)
      ENDWHILE
      SET simlabwrappedtext->output_string_cnt = (simlabwrappedtext->output_string_cnt+ 1)
      SET stat = alterlist(simlabwrappedtext->output_string,simlabwrappedtext->output_string_cnt)
      SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].string = substring(
       startsubstr,((inputstrlen - startsubstr)+ 1),input_string)
      SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].x_offset = floor((
       endlastlinepts+ 0.5))
      SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].bold = bold
     ENDIF
   END ;Subroutine
  ENDIF
  IF ((validate(simlab_font_metrics_courier_,- (99))=- (99)))
   DECLARE simlab_font_metrics_courier_ = i2 WITH public, constant(1)
   DECLARE stringwidthcourier(inputstring=vc,cpi=i2,bold=i2) = i4
   DECLARE truncatestringcourier(inputstring=vc,cpi=i2,bold=i2,slength=i2) = vc
   DECLARE courierfont = i4 WITH public, noconstant(627)
   SUBROUTINE stringwidthcourier(inputstring,cpi,bold)
     SET widthtotal = 0
     IF (cpi > 0)
      SET fontpoints = floor((120.0/ cpi))
     ELSE
      SET fontpoints = 0
     ENDIF
     SET inputstrlen = textlen(inputstring)
     SET widthtotal = ((fontpoints * courierfont) * inputstrlen)
     RETURN(widthtotal)
   END ;Subroutine
   SUBROUTINE truncatestringcourier(inputstring,cpi,bold,slength)
     IF (cpi > 0)
      SET fontpoints = floor((120.0/ cpi))
      SET tempindx = ((slength/ (fontpoints * courierfont))+ 1)
     ELSE
      SET fontpoints = (textlen(inputstring)+ 1)
     ENDIF
     SET tempindx = (tempindx - 1)
     IF (tempindx > 0)
      SET retstr = trim(substring(1,tempindx,inputstring))
     ENDIF
     RETURN(retstr)
   END ;Subroutine
  ENDIF
  IF ((validate(sch_font_metrics_times_,- (99))=- (99)))
   DECLARE sch_font_metrics_times_ = i2 WITH public, constant(1)
   DECLARE wordwraptimes(input_string=vc,cpi=i2,line_width=i2,bold_start=i2) = i2
   DECLARE characterwraptimes(input_string=vc,cpi=i2,line_width=i2,bold_start=i2) = i2
   IF ((validate(sch_font_metrics_times_rec_,- (99))=- (99)))
    DECLARE sch_font_metrics_times_rec_ = i2 WITH public, constant(1)
    FREE SET metrics_t
    RECORD metrics_t(
      1 times_cnt = i2
      1 times[*]
        2 size = i2
      1 times_bold_cnt = i2
      1 times_bold[*]
        2 size = i2
    )
   ENDIF
   SET simlabwrappedtext->output_string_cnt = 0
   SET metrics_t->times_cnt = 253
   SET stat = alterlist(metrics_t->times,metrics_t->times_cnt)
   FOR (tempindx = 1 TO 31)
     SET metrics_t->times[tempindx].size = 0
   ENDFOR
   SET metrics_t->times[32].size = 250
   SET metrics_t->times[33].size = 333
   SET metrics_t->times[34].size = 408
   SET metrics_t->times[35].size = 500
   SET metrics_t->times[36].size = 500
   SET metrics_t->times[37].size = 833
   SET metrics_t->times[38].size = 778
   SET metrics_t->times[39].size = 333
   SET metrics_t->times[40].size = 333
   SET metrics_t->times[41].size = 333
   SET metrics_t->times[42].size = 500
   SET metrics_t->times[43].size = 564
   SET metrics_t->times[44].size = 250
   SET metrics_t->times[45].size = 333
   SET metrics_t->times[46].size = 250
   SET metrics_t->times[47].size = 278
   SET metrics_t->times[48].size = 500
   SET metrics_t->times[49].size = 550
   SET metrics_t->times[50].size = 550
   SET metrics_t->times[51].size = 550
   SET metrics_t->times[52].size = 550
   SET metrics_t->times[53].size = 550
   SET metrics_t->times[54].size = 550
   SET metrics_t->times[55].size = 550
   SET metrics_t->times[56].size = 550
   SET metrics_t->times[57].size = 550
   SET metrics_t->times[58].size = 278
   SET metrics_t->times[59].size = 278
   SET metrics_t->times[60].size = 564
   SET metrics_t->times[61].size = 564
   SET metrics_t->times[62].size = 564
   SET metrics_t->times[63].size = 444
   SET metrics_t->times[64].size = 921
   SET metrics_t->times[65].size = 722
   SET metrics_t->times[66].size = 667
   SET metrics_t->times[67].size = 667
   SET metrics_t->times[68].size = 722
   SET metrics_t->times[69].size = 611
   SET metrics_t->times[70].size = 556
   SET metrics_t->times[71].size = 722
   SET metrics_t->times[72].size = 722
   SET metrics_t->times[73].size = 333
   SET metrics_t->times[74].size = 389
   SET metrics_t->times[75].size = 722
   SET metrics_t->times[76].size = 611
   SET metrics_t->times[77].size = 889
   SET metrics_t->times[78].size = 722
   SET metrics_t->times[79].size = 722
   SET metrics_t->times[80].size = 556
   SET metrics_t->times[81].size = 722
   SET metrics_t->times[82].size = 667
   SET metrics_t->times[83].size = 556
   SET metrics_t->times[84].size = 611
   SET metrics_t->times[85].size = 722
   SET metrics_t->times[86].size = 722
   SET metrics_t->times[87].size = 944
   SET metrics_t->times[88].size = 722
   SET metrics_t->times[89].size = 722
   SET metrics_t->times[90].size = 611
   SET metrics_t->times[91].size = 333
   SET metrics_t->times[92].size = 278
   SET metrics_t->times[93].size = 333
   SET metrics_t->times[94].size = 469
   SET metrics_t->times[95].size = 500
   SET metrics_t->times[96].size = 333
   SET metrics_t->times[97].size = 444
   SET metrics_t->times[98].size = 500
   SET metrics_t->times[99].size = 444
   SET metrics_t->times[100].size = 500
   SET metrics_t->times[101].size = 444
   SET metrics_t->times[102].size = 333
   SET metrics_t->times[103].size = 500
   SET metrics_t->times[104].size = 500
   SET metrics_t->times[105].size = 278
   SET metrics_t->times[106].size = 278
   SET metrics_t->times[107].size = 500
   SET metrics_t->times[108].size = 278
   SET metrics_t->times[109].size = 778
   SET metrics_t->times[110].size = 500
   SET metrics_t->times[111].size = 500
   SET metrics_t->times[112].size = 500
   SET metrics_t->times[113].size = 500
   SET metrics_t->times[114].size = 333
   SET metrics_t->times[115].size = 389
   SET metrics_t->times[116].size = 278
   SET metrics_t->times[117].size = 500
   SET metrics_t->times[118].size = 500
   SET metrics_t->times[119].size = 722
   SET metrics_t->times[120].size = 500
   SET metrics_t->times[121].size = 500
   SET metrics_t->times[122].size = 444
   SET metrics_t->times[123].size = 480
   SET metrics_t->times[124].size = 200
   SET metrics_t->times[125].size = 480
   SET metrics_t->times[126].size = 541
   FOR (tempindx = 127 TO 160)
     SET metrics_t->times[tempindx].size = 0
   ENDFOR
   SET metrics_t->times[161].size = 333
   SET metrics_t->times[162].size = 500
   SET metrics_t->times[163].size = 500
   SET metrics_t->times[164].size = 167
   SET metrics_t->times[165].size = 500
   SET metrics_t->times[166].size = 500
   SET metrics_t->times[167].size = 500
   SET metrics_t->times[168].size = 500
   SET metrics_t->times[169].size = 180
   SET metrics_t->times[170].size = 444
   SET metrics_t->times[171].size = 500
   SET metrics_t->times[172].size = 333
   SET metrics_t->times[173].size = 333
   SET metrics_t->times[174].size = 556
   SET metrics_t->times[175].size = 556
   SET metrics_t->times[176].size = 0
   SET metrics_t->times[177].size = 500
   SET metrics_t->times[178].size = 500
   SET metrics_t->times[179].size = 500
   SET metrics_t->times[180].size = 250
   SET metrics_t->times[181].size = 0
   SET metrics_t->times[182].size = 453
   SET metrics_t->times[183].size = 350
   SET metrics_t->times[184].size = 333
   SET metrics_t->times[185].size = 444
   SET metrics_t->times[186].size = 444
   SET metrics_t->times[187].size = 500
   SET metrics_t->times[188].size = 1000
   SET metrics_t->times[189].size = 1000
   SET metrics_t->times[190].size = 0
   SET metrics_t->times[191].size = 444
   SET metrics_t->times[192].size = 333
   SET metrics_t->times[193].size = 333
   SET metrics_t->times[194].size = 333
   SET metrics_t->times[195].size = 333
   SET metrics_t->times[196].size = 333
   SET metrics_t->times[197].size = 333
   SET metrics_t->times[198].size = 333
   SET metrics_t->times[199].size = 333
   SET metrics_t->times[200].size = 333
   SET metrics_t->times[201].size = 333
   SET metrics_t->times[202].size = 333
   SET metrics_t->times[203].size = 333
   SET metrics_t->times[204].size = 278
   SET metrics_t->times[205].size = 278
   SET metrics_t->times[206].size = 278
   SET metrics_t->times[207].size = 278
   SET metrics_t->times[208].size = 1000
   FOR (tempindx = 209 TO 224)
     SET metrics_t->times[tempindx].size = 0
   ENDFOR
   SET metrics_t->times[225].size = 889
   SET metrics_t->times[226].size = 0
   SET metrics_t->times[227].size = 276
   SET metrics_t->times[228].size = 0
   SET metrics_t->times[229].size = 0
   SET metrics_t->times[230].size = 0
   SET metrics_t->times[231].size = 0
   SET metrics_t->times[232].size = 611
   SET metrics_t->times[233].size = 722
   SET metrics_t->times[234].size = 889
   SET metrics_t->times[235].size = 310
   SET metrics_t->times[236].size = 0
   SET metrics_t->times[237].size = 0
   SET metrics_t->times[238].size = 0
   SET metrics_t->times[239].size = 0
   SET metrics_t->times[240].size = 0
   SET metrics_t->times[241].size = 667
   SET metrics_t->times[242].size = 0
   SET metrics_t->times[243].size = 0
   SET metrics_t->times[244].size = 0
   SET metrics_t->times[245].size = 278
   SET metrics_t->times[246].size = 0
   SET metrics_t->times[247].size = 0
   SET metrics_t->times[248].size = 278
   SET metrics_t->times[249].size = 500
   SET metrics_t->times[250].size = 722
   SET metrics_t->times[251].size = 500
   SET metrics_t->times[252].size = 0
   SET metrics_t->times[253].size = 0
   SET metrics_t->times_bold_cnt = 253
   SET stat = alterlist(metrics_t->times_bold,metrics_t->times_bold_cnt)
   FOR (tempindx = 1 TO 31)
     SET metrics_t->times_bold[tempindx].size = 0
   ENDFOR
   SET metrics_t->times_bold[32].size = 250
   SET metrics_t->times_bold[33].size = 333
   SET metrics_t->times_bold[34].size = 555
   SET metrics_t->times_bold[35].size = 500
   SET metrics_t->times_bold[36].size = 500
   SET metrics_t->times_bold[37].size = 1000
   SET metrics_t->times_bold[38].size = 833
   SET metrics_t->times_bold[39].size = 333
   SET metrics_t->times_bold[40].size = 333
   SET metrics_t->times_bold[41].size = 333
   SET metrics_t->times_bold[42].size = 500
   SET metrics_t->times_bold[43].size = 570
   SET metrics_t->times_bold[44].size = 250
   SET metrics_t->times_bold[45].size = 333
   SET metrics_t->times_bold[46].size = 250
   SET metrics_t->times_bold[47].size = 278
   SET metrics_t->times_bold[48].size = 500
   SET metrics_t->times_bold[49].size = 500
   SET metrics_t->times_bold[50].size = 500
   SET metrics_t->times_bold[51].size = 500
   SET metrics_t->times_bold[52].size = 500
   SET metrics_t->times_bold[53].size = 500
   SET metrics_t->times_bold[54].size = 500
   SET metrics_t->times_bold[55].size = 500
   SET metrics_t->times_bold[56].size = 500
   SET metrics_t->times_bold[57].size = 500
   SET metrics_t->times_bold[58].size = 333
   SET metrics_t->times_bold[59].size = 333
   SET metrics_t->times_bold[60].size = 570
   SET metrics_t->times_bold[61].size = 570
   SET metrics_t->times_bold[62].size = 570
   SET metrics_t->times_bold[63].size = 500
   SET metrics_t->times_bold[64].size = 930
   SET metrics_t->times_bold[65].size = 722
   SET metrics_t->times_bold[66].size = 667
   SET metrics_t->times_bold[67].size = 722
   SET metrics_t->times_bold[68].size = 722
   SET metrics_t->times_bold[69].size = 667
   SET metrics_t->times_bold[70].size = 611
   SET metrics_t->times_bold[71].size = 778
   SET metrics_t->times_bold[72].size = 778
   SET metrics_t->times_bold[73].size = 389
   SET metrics_t->times_bold[74].size = 500
   SET metrics_t->times_bold[75].size = 778
   SET metrics_t->times_bold[76].size = 667
   SET metrics_t->times_bold[77].size = 944
   SET metrics_t->times_bold[78].size = 722
   SET metrics_t->times_bold[79].size = 778
   SET metrics_t->times_bold[80].size = 556
   SET metrics_t->times_bold[81].size = 667
   SET metrics_t->times_bold[82].size = 722
   SET metrics_t->times_bold[83].size = 556
   SET metrics_t->times_bold[84].size = 667
   SET metrics_t->times_bold[85].size = 722
   SET metrics_t->times_bold[86].size = 722
   SET metrics_t->times_bold[87].size = 1000
   SET metrics_t->times_bold[88].size = 772
   SET metrics_t->times_bold[89].size = 772
   SET metrics_t->times_bold[90].size = 667
   SET metrics_t->times_bold[91].size = 333
   SET metrics_t->times_bold[92].size = 278
   SET metrics_t->times_bold[93].size = 333
   SET metrics_t->times_bold[94].size = 581
   SET metrics_t->times_bold[95].size = 500
   SET metrics_t->times_bold[96].size = 333
   SET metrics_t->times_bold[97].size = 500
   SET metrics_t->times_bold[98].size = 556
   SET metrics_t->times_bold[99].size = 444
   SET metrics_t->times_bold[100].size = 556
   SET metrics_t->times_bold[101].size = 444
   SET metrics_t->times_bold[102].size = 333
   SET metrics_t->times_bold[103].size = 500
   SET metrics_t->times_bold[104].size = 556
   SET metrics_t->times_bold[105].size = 278
   SET metrics_t->times_bold[106].size = 333
   SET metrics_t->times_bold[107].size = 556
   SET metrics_t->times_bold[108].size = 278
   SET metrics_t->times_bold[109].size = 833
   SET metrics_t->times_bold[110].size = 556
   SET metrics_t->times_bold[111].size = 500
   SET metrics_t->times_bold[112].size = 556
   SET metrics_t->times_bold[113].size = 556
   SET metrics_t->times_bold[114].size = 444
   SET metrics_t->times_bold[115].size = 389
   SET metrics_t->times_bold[116].size = 333
   SET metrics_t->times_bold[117].size = 556
   SET metrics_t->times_bold[118].size = 550
   SET metrics_t->times_bold[119].size = 722
   SET metrics_t->times_bold[120].size = 500
   SET metrics_t->times_bold[121].size = 500
   SET metrics_t->times_bold[122].size = 444
   SET metrics_t->times_bold[123].size = 394
   SET metrics_t->times_bold[124].size = 220
   SET metrics_t->times_bold[125].size = 394
   SET metrics_t->times_bold[126].size = 520
   FOR (tempindx = 127 TO 160)
     SET metrics_t->times_bold[tempindx].size = 0
   ENDFOR
   SET metrics_t->times_bold[161].size = 333
   SET metrics_t->times_bold[162].size = 500
   SET metrics_t->times_bold[163].size = 500
   SET metrics_t->times_bold[164].size = 167
   SET metrics_t->times_bold[165].size = 500
   SET metrics_t->times_bold[166].size = 500
   SET metrics_t->times_bold[167].size = 500
   SET metrics_t->times_bold[168].size = 500
   SET metrics_t->times_bold[169].size = 278
   SET metrics_t->times_bold[170].size = 500
   SET metrics_t->times_bold[171].size = 500
   SET metrics_t->times_bold[172].size = 333
   SET metrics_t->times_bold[173].size = 333
   SET metrics_t->times_bold[174].size = 556
   SET metrics_t->times_bold[175].size = 556
   SET metrics_t->times_bold[176].size = 0
   SET metrics_t->times_bold[177].size = 500
   SET metrics_t->times_bold[178].size = 500
   SET metrics_t->times_bold[179].size = 500
   SET metrics_t->times_bold[180].size = 250
   SET metrics_t->times_bold[181].size = 0
   SET metrics_t->times_bold[182].size = 540
   SET metrics_t->times_bold[183].size = 350
   SET metrics_t->times_bold[184].size = 333
   SET metrics_t->times_bold[185].size = 500
   SET metrics_t->times_bold[186].size = 500
   SET metrics_t->times_bold[187].size = 500
   SET metrics_t->times_bold[188].size = 1000
   SET metrics_t->times_bold[189].size = 1000
   SET metrics_t->times_bold[190].size = 0
   SET metrics_t->times_bold[191].size = 500
   SET metrics_t->times_bold[193].size = 333
   SET metrics_t->times_bold[194].size = 333
   SET metrics_t->times_bold[195].size = 333
   SET metrics_t->times_bold[196].size = 333
   SET metrics_t->times_bold[197].size = 333
   SET metrics_t->times_bold[198].size = 333
   SET metrics_t->times_bold[199].size = 333
   SET metrics_t->times_bold[200].size = 333
   SET metrics_t->times_bold[202].size = 333
   SET metrics_t->times_bold[203].size = 333
   SET metrics_t->times_bold[205].size = 333
   SET metrics_t->times_bold[206].size = 333
   SET metrics_t->times_bold[207].size = 333
   SET metrics_t->times_bold[208].size = 1000
   FOR (tempindx = 209 TO 224)
     SET metrics_t->times_bold[tempindx].size = 0
   ENDFOR
   SET metrics_t->times_bold[225].size = 1000
   SET metrics_t->times_bold[226].size = 0
   SET metrics_t->times_bold[227].size = 300
   SET metrics_t->times_bold[228].size = 0
   SET metrics_t->times_bold[229].size = 0
   SET metrics_t->times_bold[230].size = 0
   SET metrics_t->times_bold[231].size = 0
   SET metrics_t->times_bold[232].size = 667
   SET metrics_t->times_bold[233].size = 778
   SET metrics_t->times_bold[234].size = 1000
   SET metrics_t->times_bold[235].size = 330
   SET metrics_t->times_bold[236].size = 0
   SET metrics_t->times_bold[237].size = 0
   SET metrics_t->times_bold[238].size = 0
   SET metrics_t->times_bold[239].size = 0
   SET metrics_t->times_bold[240].size = 0
   SET metrics_t->times_bold[241].size = 722
   SET metrics_t->times_bold[242].size = 0
   SET metrics_t->times_bold[243].size = 0
   SET metrics_t->times_bold[244].size = 0
   SET metrics_t->times_bold[245].size = 278
   SET metrics_t->times_bold[246].size = 0
   SET metrics_t->times_bold[247].size = 0
   SET metrics_t->times_bold[248].size = 278
   SET metrics_t->times_bold[249].size = 500
   SET metrics_t->times_bold[250].size = 722
   SET metrics_t->times_bold[251].size = 556
   SET metrics_t->times_bold[252].size = 0
   SET metrics_t->times_bold[253].size = 0
   SUBROUTINE stringwidthtimes(input_string,cpi,bold)
     IF (cpi > 0)
      SET fontpoints = floor(((120.0/ cpi)+ 0.5))
     ELSE
      SET fontpoints = 0
     ENDIF
     SET inputstrlen = textlen(input_string)
     SET widthtotal = 0
     FOR (temp_indx = 1 TO inputstrlen)
      SET asciinum = ichar(substring(temp_indx,1,input_string))
      IF (asciinum <= 253)
       IF (bold=0)
        SET widthtotal = (widthtotal+ (fontpoints * metrics_t->times[asciinum].size))
       ELSE
        SET widthtotal = (widthtotal+ (fontpoints * metrics_t->times_bold[asciinum].size))
       ENDIF
      ENDIF
     ENDFOR
     RETURN(widthtotal)
   END ;Subroutine
   SUBROUTINE wordwraptimes(input_string,cpi,line_width,bold_start)
     IF (cpi > 0)
      SET fontpoints = floor(((120.0/ cpi)+ 0.5))
     ELSE
      SET fontpoints = 0
     ENDIF
     SET inputstrlen = textlen(input_string)
     SET widthline = line_width
     SET widthtotal = 0
     SET widthword = 0
     SET widthspace = 0
     SET spacecnt = 0
     SET endword = 1
     SET startsubstr = 1
     SET endlastline = 1
     SET endlastlinepts = 0
     SET state = 0
     SET bold = bold_start
     SET boldstart = 0
     SET nonboldstart = 0
     SET simlabwrappedtext->output_string_cnt = 0
     IF ((widthline > (1015 * fontpoints))
      AND fontpoints <= 120)
      SET cnt = 1
      WHILE (cnt <= inputstrlen)
        SET asciinum = ichar(substring(cnt,1,input_string))
        IF (((asciinum < 32) OR (asciinum > 253)) )
         SET input_string = concat(substring(1,(cnt - 1),input_string),substring((cnt+ 1),(
           inputstrlen - cnt),input_string))
         SET inputstrlen = (inputstrlen - 1)
         SET cnt = (cnt - 1)
        ELSEIF (asciinum=187)
         SET input_string = concat(substring(1,(cnt - 1),input_string),substring((cnt+ 1),(
           inputstrlen - cnt),input_string))
         SET inputstrlen = (inputstrlen - 1)
         IF (bold=0)
          SET boldstart = cnt
          IF (((widthword+ widthspace) > 0))
           SET simlabwrappedtext->output_string_cnt = (simlabwrappedtext->output_string_cnt+ 1)
           IF (mod(simlabwrappedtext->output_string_cnt,10)=1)
            SET stat = alterlist(simlabwrappedtext->output_string,(simlabwrappedtext->
             output_string_cnt+ 9))
           ENDIF
           SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].string = notrim
           (substring(startsubstr,(cnt - startsubstr),input_string))
           SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].bold = bold
           SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].x_offset =
           floor(((endlastlinepts/ 1000.0)+ 0.5))
           IF (state=0)
            SET endlastlinepts = (widthtotal+ widthspace)
           ELSE
            SET endlastlinepts = ((widthtotal+ widthspace)+ widthword)
           ENDIF
           SET startsubstr = cnt
          ENDIF
          SET bold = 1
         ENDIF
         SET cnt = (cnt - 1)
        ELSEIF (asciinum=171)
         SET input_string = concat(substring(1,(cnt - 1),input_string),substring((cnt+ 1),(
           inputstrlen - cnt),input_string))
         SET inputstrlen = (inputstrlen - 1)
         IF (bold=1)
          SET nonboldstart = cnt
          IF (((widthword+ widthspace) > 0))
           SET simlabwrappedtext->output_string_cnt = (simlabwrappedtext->output_string_cnt+ 1)
           IF (mod(simlabwrappedtext->output_string_cnt,10)=1)
            SET stat = alterlist(simlabwrappedtext->output_string,(simlabwrappedtext->
             output_string_cnt+ 9))
           ENDIF
           SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].string = notrim
           (substring(startsubstr,(cnt - startsubstr),input_string))
           SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].bold = bold
           SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].x_offset =
           floor(((endlastlinepts/ 1000.0)+ 0.5))
           IF (state=0)
            SET endlastlinepts = (widthtotal+ widthspace)
           ELSE
            SET endlastlinepts = ((widthtotal+ widthspace)+ widthword)
           ENDIF
           SET startsubstr = cnt
          ENDIF
          SET bold = 0
         ENDIF
         SET cnt = (cnt - 1)
        ELSEIF (asciinum=32)
         IF (state=1)
          SET state = 0
          SET spacecnt = 0
          SET widthtotal = ((widthtotal+ widthspace)+ widthword)
          SET widthspace = 0
          SET endword = cnt
         ENDIF
         SET spacecnt = (spacecnt+ 1)
         IF (bold=1)
          SET widthspace = (widthspace+ (fontpoints * metrics_t->times_bold[asciinum].size))
         ELSE
          SET widthspace = (widthspace+ (fontpoints * metrics_t->times[asciinum].size))
         ENDIF
        ELSE
         IF (state=0)
          SET state = 1
          SET widthword = 0
         ENDIF
         IF (bold=1)
          SET widthchar = (fontpoints * metrics_t->times_bold[asciinum].size)
         ELSE
          SET widthchar = (fontpoints * metrics_t->times[asciinum].size)
         ENDIF
         IF (widthchar=0)
          SET input_string = concat(substring(1,(cnt - 1),input_string),substring((cnt+ 1),(
            inputstrlen - cnt),input_string))
          SET inputstrlen = (inputstrlen - 1)
          SET cnt = (cnt - 1)
         ELSE
          SET widthword = (widthword+ widthchar)
          IF ((((widthtotal+ widthspace)+ widthword) >= widthline))
           IF (endlastline=endword)
            SET endword = cnt
           ENDIF
           IF (((endword - startsubstr) > 0))
            SET simlabwrappedtext->output_string_cnt = (simlabwrappedtext->output_string_cnt+ 1)
            IF (mod(simlabwrappedtext->output_string_cnt,10)=1)
             SET stat = alterlist(simlabwrappedtext->output_string,(simlabwrappedtext->
              output_string_cnt+ 9))
            ENDIF
            IF (endlastlinepts=0)
             SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].string = trim
             (substring(startsubstr,(endword - startsubstr),input_string),3)
            ELSE
             SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].string =
             substring(startsubstr,(endword - startsubstr),input_string)
            ENDIF
            IF (endword=cnt)
             SET startsubstr = cnt
             SET widthword = widthchar
            ELSE
             SET startsubstr = (endword+ spacecnt)
            ENDIF
            SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].x_offset =
            floor(((endlastlinepts/ 1000.0)+ 0.5))
            SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].bold = bold
           ENDIF
           SET endlastline = endword
           SET endlastlinepts = 0
           SET widthtotal = 0
           SET widthspace = 0
          ENDIF
         ENDIF
        ENDIF
        SET cnt = (cnt+ 1)
      ENDWHILE
      SET simlabwrappedtext->output_string_cnt = (simlabwrappedtext->output_string_cnt+ 1)
      SET stat = alterlist(simlabwrappedtext->output_string,simlabwrappedtext->output_string_cnt)
      SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].string = substring(
       startsubstr,((inputstrlen - startsubstr)+ 1),input_string)
      SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].x_offset = floor(((
       endlastlinepts/ 1000.0)+ 0.5))
      SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].bold = bold
     ENDIF
   END ;Subroutine
   SUBROUTINE characterwraptimes(input_string,cpi,line_width,bold_start)
     IF (cpi > 0)
      SET fontpoints = floor(((120.0/ cpi)+ 0.5))
     ELSE
      SET fontpoints = 0
     ENDIF
     SET inputstrlen = textlen(input_string)
     SET widthline = line_width
     SET widthtotal = 0
     SET widthword = 0
     SET widthspace = 0
     SET spacecnt = 0
     SET endword = 1
     SET startsubstr = 1
     SET endlastline = 1
     SET endlastlinepts = 0
     SET state = 0
     SET bold = bold_start
     SET boldstart = 0
     SET nonboldstart = 0
     SET simlabwrappedtext->output_string_cnt = 0
     IF ((widthline > (1015 * fontpoints))
      AND fontpoints <= 120)
      SET cnt = 1
      WHILE (cnt <= inputstrlen)
        SET asciinum = ichar(substring(cnt,1,input_string))
        IF (((asciinum < 32) OR (asciinum > 253)) )
         SET input_string = concat(substring(1,(cnt - 1),input_string),substring((cnt+ 1),(
           inputstrlen - cnt),input_string))
         SET inputstrlen = (inputstrlen - 1)
         SET cnt = (cnt - 1)
        ELSEIF (asciinum=187)
         SET input_string = concat(substring(1,(cnt - 1),input_string),substring((cnt+ 1),(
           inputstrlen - cnt),input_string))
         SET inputstrlen = (inputstrlen - 1)
         IF (bold=0)
          SET boldstart = cnt
          IF (widthtotal > 0)
           SET endword = cnt
           SET simlabwrappedtext->output_string_cnt = (simlabwrappedtext->output_string_cnt+ 1)
           IF (mod(simlabwrappedtext->output_string_cnt,10)=1)
            SET stat = alterlist(simlabwrappedtext->output_string,(simlabwrappedtext->
             output_string_cnt+ 9))
           ENDIF
           SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].string = notrim
           (substring(startsubstr,(endword - startsubstr),input_string))
           SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].bold = bold
           SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].x_offset =
           floor(((endlastlinepts/ 1000.0)+ 0.5))
           SET endlastlinepts = widthtotal
           SET startsubstr = cnt
          ENDIF
          SET bold = 1
         ENDIF
         SET cnt = (cnt - 1)
        ELSEIF (asciinum=171)
         SET input_string = concat(substring(1,(cnt - 1),input_string),substring((cnt+ 1),(
           inputstrlen - cnt),input_string))
         SET inputstrlen = (inputstrlen - 1)
         IF (bold=1)
          SET nonboldstart = cnt
          IF (widthtotal > 0)
           SET endword = cnt
           SET simlabwrappedtext->output_string_cnt = (simlabwrappedtext->output_string_cnt+ 1)
           IF (mod(simlabwrappedtext->output_string_cnt,10)=1)
            SET stat = alterlist(simlabwrappedtext->output_string,(simlabwrappedtext->
             output_string_cnt+ 9))
           ENDIF
           SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].string = notrim
           (substring(startsubstr,(endword - startsubstr),input_string))
           SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].bold = bold
           SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].x_offset =
           floor(((endlastlinepts/ 1000.0)+ 0.5))
           SET endlastlinepts = widthtotal
           SET startsubstr = cnt
          ENDIF
          SET bold = 0
         ENDIF
         SET cnt = (cnt - 1)
        ELSE
         IF (bold=1)
          SET widthchar = (fontpoints * metrics_t->times_bold[asciinum].size)
         ELSE
          SET widthchar = (fontpoints * metrics_t->times[asciinum].size)
         ENDIF
         IF (widthchar=0)
          SET input_string = concat(substring(1,(cnt - 1),input_string),substring((cnt+ 1),(
            inputstrlen - cnt),input_string))
          SET inputstrlen = (inputstrlen - 1)
          SET cnt = (cnt - 1)
         ELSE
          IF (((widthtotal+ widthchar) >= widthline))
           SET endword = cnt
           IF (((endword - startsubstr) > 0))
            SET simlabwrappedtext->output_string_cnt = (simlabwrappedtext->output_string_cnt+ 1)
            IF (mod(simlabwrappedtext->output_string_cnt,10)=1)
             SET stat = alterlist(simlabwrappedtext->output_string,(simlabwrappedtext->
              output_string_cnt+ 9))
            ENDIF
            IF (endlastlinepts=0)
             SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].string = trim
             (substring(startsubstr,(endword - startsubstr),input_string),3)
            ELSE
             SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].string =
             substring(startsubstr,(endword - startsubstr),input_string)
            ENDIF
            SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].x_offset =
            floor(((endlastlinepts/ 1000.0)+ 0.5))
            SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].bold = bold
           ENDIF
           SET startsubstr = cnt
           SET endlastlinepts = 0
           SET widthtotal = widthchar
          ELSE
           SET widthtotal = (widthtotal+ widthchar)
          ENDIF
         ENDIF
        ENDIF
        SET cnt = (cnt+ 1)
      ENDWHILE
      SET simlabwrappedtext->output_string_cnt = (simlabwrappedtext->output_string_cnt+ 1)
      SET stat = alterlist(simlabwrappedtext->output_string,simlabwrappedtext->output_string_cnt)
      SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].string = substring(
       startsubstr,((inputstrlen - startsubstr)+ 1),input_string)
      SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].x_offset = floor(((
       endlastlinepts/ 1000.0)+ 0.5))
      SET simlabwrappedtext->output_string[simlabwrappedtext->output_string_cnt].bold = bold
     ENDIF
   END ;Subroutine
  ENDIF
  DECLARE cpitopoints(cpisize=i2) = i2
  SUBROUTINE cpitopoints(cpisize)
    DECLARE pointsize = i2
    SET pointsize = floor(((120.0/ cpisize)+ 0.5))
    RETURN(pointsize)
  END ;Subroutine
  DECLARE distancetopoints(distance=f8) = i4
  SUBROUTINE distancetopoints(distance)
    DECLARE totalpoints = i4
    SET totalpoints = floor((((72 * 1000) * distance)+ 0.5))
    RETURN(totalpoints)
  END ;Subroutine
  DECLARE pointstodistance(points=i4) = f8
  SUBROUTINE pointstodistance(points)
    DECLARE distance = f8
    SET distance = (cnvtreal(points)/ 72000.0)
    RETURN(distance)
  END ;Subroutine
  DECLARE stringwidthbyfonttype(inputstring=vc,cpi=i2,bold=i2,sfonttype=vc) = i4
  SUBROUTINE stringwidthbyfonttype(inputstring,cpi,bold,sfonttype)
    SET widthtotal = 0
    SET widthtotal = parser(concat("StringWidth",sfonttype,"(inputString, cpi, bold)"))
    RETURN(widthtotal)
  END ;Subroutine
  DECLARE truncatestringbypoints(inputstring=vc,cpi=i2,bold=i2,slength=i2,sfonttype=vc) = vc
  SUBROUTINE truncatestringbypoints(inputstring,cpi,bold,slength,sfonttype)
    SET retstr = " "
    SET retstr = parser(concat("TruncateString",sfonttype,"(inputString, cpi, bold, sLength)"))
    RETURN(retstr)
  END ;Subroutine
  DECLARE wordwrapbypoints(inputstring=vc,cpi=i2,line_width=i2,bold_start=i2,sfonttype=vc) = i2
  SUBROUTINE wordwrapbypoints(inputstring,cpi,line_width,bold_start,sfonttype)
    SET iretstr = 0
    SET iretstr = parser(concat("wordWrap",sfonttype,"(inputString, cpi, line_width, bold_start)"))
    RETURN(iretstr)
  END ;Subroutine
  DECLARE characterwrapbypoints(inputstring=vc,cpi=i2,line_width=i2,bold_start=i2,sfonttype=vc) = i2
  SUBROUTINE characterwrapbypoints(inputstring,cpi,line_width,bold_start,sfonttype)
    SET iretstr = 0
    SET iretstr = parser(concat("CharacterWrap",sfonttype,
      "(inputString, cpi, line_width, bold_start)"))
    RETURN(iretstr)
  END ;Subroutine
 ENDIF
 DECLARE stemplastname = vc WITH noconstant(" ")
 DECLARE stempfirstmidname = vc WITH noconstant(" ")
 DECLARE simlabformatname(namelast=vc,namefirst=vc,namemid=vc,mincharsfirstname=i2,bolding=i2,
  lastfirstspacer=vc,firstmiddlespacer=vc,charsperinch=i2,fieldsizeininch=f8) = null
 DECLARE simlabformatnamebyfont(namelast=vc,namefirst=vc,namemid=vc,mincharsfirstname=i2,bolding=i2,
  lastfirstspacer=vc,firstmiddlespacer=vc,charsperinch=i2,fieldsizeininch=f8,sfonttype=vc) = null
 SUBROUTINE simlabformatname(namelast,namefirst,namemid,mincharsfirstname,bolding,lastfirstspacer,
  firstmiddlespacer,charsperinch,fieldsizeininch)
  SET stat = simlabformatnamebyfont(namelast,namefirst,namemid,mincharsfirstname,bolding,
   lastfirstspacer,firstmiddlespacer,charsperinch,fieldsizeininch,"HELVETICA")
  RETURN(null)
 END ;Subroutine
 SUBROUTINE simlabformatnamebyfont(namelast,namefirst,namemid,mincharsfirstname,bolding,
  lastfirstspacer,firstmiddlespacer,charsperinch,fieldsizeininch,sfonttype)
   DECLARE truncationseq = c3 WITH constant("..."), private
   DECLARE lfslen = i2 WITH constant(textlen(lastfirstspacer)), private
   DECLARE fmslen = i2 WITH constant(textlen(firstmiddlespacer)), private
   DECLARE lastbold = i2 WITH constant(btest(bolding,1)), private
   DECLARE firstmiddlebold = i2 WITH constant(btest(bolding,2)), private
   DECLARE truncationseqlenfm = i2 WITH constant(stringwidthbyfonttype(truncationseq,charsperinch,
     firstmiddlebold,sfonttype)), private
   DECLARE truncationseqlenlast = i2 WITH constant(stringwidthbyfonttype(truncationseq,charsperinch,
     lastbold,sfonttype)), private
   DECLARE totalfieldpoints = i4 WITH noconstant(0), private
   DECLARE namelastpoints = i4 WITH noconstant(0), private
   DECLARE namefirstmidpoints = i4 WITH noconstant(0), private
   DECLARE nametemppoints = i4 WITH noconstant(0), private
   DECLARE snametemp = vc WITH noconstant(" "), private
   SET totalfieldpoints = distancetopoints(fieldsizeininch)
   IF (mincharsfirstname > 0)
    IF (textlen(trim(namemid)) < 1)
     IF ((textlen(trim(namefirst)) <= (mincharsfirstname+ 1)))
      SET stempfirstmidname = concat(lastfirstspacer,trim(namefirst))
     ELSE
      SET stempfirstmidname = concat(lastfirstspacer,substring(1,mincharsfirstname,trim(namefirst)),
       truncationseq)
     ENDIF
    ELSE
     SET stempfirstmidname = concat(lastfirstspacer,trim(namefirst),firstmiddlespacer,trim(namemid))
     IF (textlen(trim(namefirst)) > mincharsfirstname)
      SET stempfirstmidname = concat(substring(1,(textlen(lastfirstspacer)+ mincharsfirstname),
        stempfirstmidname),truncationseq)
     ENDIF
    ENDIF
   ENDIF
   SET namefirstmidpoints = stringwidthbyfonttype(trim(stempfirstmidname),charsperinch,
    firstmiddlebold,sfonttype)
   SET namelastpoints = stringwidthbyfonttype(namelast,charsperinch,lastbold,sfonttype)
   IF (((namelastpoints+ namefirstmidpoints) > totalfieldpoints))
    SET nametemppoints = ((totalfieldpoints - namefirstmidpoints) - truncationseqlenlast)
    SET stemplastname = concat(trim(truncatestringbypoints(namelast,charsperinch,lastbold,
       nametemppoints,sfonttype)),truncationseq)
   ELSE
    SET stemplastname = namelast
    IF (textlen(trim(namemid)) < 1)
     SET stempfirstmidname = concat(lastfirstspacer,trim(namefirst))
    ELSE
     SET stempfirstmidname = concat(lastfirstspacer,trim(namefirst),firstmiddlespacer,trim(namemid))
    ENDIF
    SET namefirstmidpoints = stringwidthbyfonttype(stempfirstmidname,charsperinch,firstmiddlebold,
     sfonttype)
    IF ((totalfieldpoints < (namelastpoints+ namefirstmidpoints)))
     SET nametemppoints = ((totalfieldpoints - namelastpoints) - truncationseqlenfm)
     SET snametemp = trim(truncatestringbypoints(stempfirstmidname,charsperinch,firstmiddlebold,
       nametemppoints,sfonttype))
     IF (textlen(trim(namemid)) < 1)
      IF ((textlen(trim(snametemp)) < (textlen(trim(stempfirstmidname)) - 1)))
       SET stempfirstmidname = concat(trim(truncatestringbypoints(stempfirstmidname,charsperinch,
          firstmiddlebold,nametemppoints,sfonttype)),truncationseq)
      ENDIF
     ELSE
      IF ((textlen(trim(snametemp)) < ((textlen(trim(stempfirstmidname)) - fmslen) - 1)))
       SET stempfirstmidname = concat(trim(truncatestringbypoints(stempfirstmidname,charsperinch,
          firstmiddlebold,nametemppoints,sfonttype)),truncationseq)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL echo(build("sTempFirstMidName->",stempfirstmidname))
   CALL echo(build("sTempLastName->",stemplastname))
   RETURN(null)
 END ;Subroutine
 DECLARE fmttruncate(flength=f8,charsperinch=i2,stext=vc,bcapsind=i2) = vc
 DECLARE fmttruncatebyfonttype(flength=f8,charsperinch=i2,stext=vc,bcapsind=i2,sfonttype=vc) = vc
 SUBROUTINE fmttruncate(flength,charsperinch,stext,bcapsind)
   DECLARE srettext = vc WITH protect, noconstant("")
   SET srettext = fmttruncatebyfonttype(flength,charsperinch,stext,bcapsind,"HELVETICA")
   RETURN(srettext)
 END ;Subroutine
 SUBROUTINE fmttruncatebyfonttype(flength,charsperinch,stext,bcapsind,sfonttype)
   DECLARE srettext = vc WITH protect, noconstant("")
   DECLARE sstrpart = vc WITH private
   DECLARE ipos = i4 WITH private
   DECLARE ispos = i4 WITH private
   DECLARE totalfieldpoints = i4 WITH noconstant(0), private
   IF (bcapsind)
    SET ipos = findstring(" ",trim(stext,3),1,0)
    IF (ipos > 0)
     SET ispos = 1
     WHILE (ipos > 0)
       SET sstrpart = cnvtcap(trim(substring(ispos,((ipos+ 1) - ispos),trim(stext,3))))
       SET srettext = trim(concat(srettext," ",sstrpart),3)
       SET ispos = (ipos+ 1)
       SET ipos = findstring(" ",trim(stext,3),ispos,0)
       IF (ipos=0)
        SET srettext = trim(concat(srettext," ",cnvtcap(substring(ispos,((size(stext)+ 1) - ispos),
            trim(stext,3)))))
       ENDIF
     ENDWHILE
    ELSE
     SET srettext = cnvtcap(stext)
    ENDIF
   ELSE
    SET srettext = stext
   ENDIF
   SET totalfieldpoints = distancetopoints(flength)
   IF (stringwidthbyfonttype(srettext,charsperinch,0,sfonttype) > totalfieldpoints)
    SET srettext = concat(trim(truncatestringbypoints(srettext,charsperinch,0,totalfieldpoints,
       sfonttype)),"...")
   ENDIF
   RETURN(srettext)
 END ;Subroutine
 DECLARE wordwrapbyfont(stext=vc,charsperinch=i2,flength=f8,iboldstart=i2,sfonttype=vc) = i2
 SUBROUTINE wordwrapbyfont(stext,charsperinch,flength,iboldstart,sfonttype)
   DECLARE irettext = i2 WITH protect, noconstant(0)
   DECLARE totalfieldpoints = i4 WITH noconstant(0), private
   SET totalfieldpoints = distancetopoints(flength)
   SET irettext = wordwrapbypoints(stext,charsperinch,totalfieldpoints,iboldstart,sfonttype)
   RETURN(irettext)
 END ;Subroutine
 DECLARE characterwrapbyfont(stext=vc,charsperinch=i2,flength=f8,iboldstart=i2,sfonttype=vc) = i2
 SUBROUTINE characterwrapbyfont(stext,charsperinch,flength,iboldstart,sfonttype)
   DECLARE irettext = i2 WITH protect, noconstant(0)
   DECLARE totalfieldpoints = i4 WITH noconstant(0), private
   SET totalfieldpoints = distancetopoints(flength)
   SET irettext = characterwrapbypoints(stext,charsperinch,totalfieldpoints,iboldstart,sfonttype)
   RETURN(irettext)
 END ;Subroutine
 DECLARE charsperinch = i2 WITH constant(12)
 DECLARE flengthinch = f8 WITH noconstant(0.0)
 RECORD orders(
   1 name = vc
   1 pat_type = vc
   1 age = vc
   1 dob = vc
   1 mrn = vc
   1 mrn_bcr = vc
   1 nhs_num = vc
   1 location = vc
   1 facility = vc
   1 nurse_unit = vc
   1 room = vc
   1 bed = vc
   1 isolation = vc
   1 sex = vc
   1 fnbr = vc
   1 med_service = vc
   1 admit_diagnosis = vc
   1 admit_dt = vc
   1 dischg_dt = vc
   1 los = i4
   1 attending = vc
   1 admitting = vc
   1 order_location = vc
   1 spoolout_ind = i2
   1 addr_cnt = i2
   1 addr[4]
     2 addr_line = vc
   1 cnt = i2
   1 qual[*]
     2 order_id = f8
     2 display_ind = i2
     2 template_order_flag = i2
     2 cs_flag = i2
     2 iv_ind = i2
     2 mnemonic = vc
     2 mnem_ln_cnt = i2
     2 mnem_ln_qual[*]
       3 mnem_line = vc
     2 display_line = vc
     2 disp_ln_cnt = i2
     2 disp_ln_qual[*]
       3 disp_line = vc
     2 order_dt = vc
     2 signed_dt = vc
     2 status = vc
     2 accession = vc
     2 catalog = vc
     2 catalog_type_cd = f8
     2 activity = vc
     2 activity_type_cd = f8
     2 last_action_seq = i4
     2 enter_by = vc
     2 order_dr = vc
     2 type = vc
     2 action = vc
     2 action_type_cd = f8
     2 comment_ind = i2
     2 comment = vc
     2 com_ln_cnt = i2
     2 com_ln_qual[*]
       3 com_line = vc
     2 oe_format_id = f8
     2 clin_line_ind = i2
     2 stat_ind = i2
     2 d_cnt = i2
     2 d_qual[*]
       3 field_description = vc
       3 label_text = vc
       3 value = vc
       3 field_value = f8
       3 oe_field_meaning_id = f8
       3 group_seq = i4
       3 print_ind = i2
       3 clin_line_ind = i2
       3 label = vc
       3 suffix = i2
       3 detail_ln_cnt = i2
       3 detail_ln_qual[*]
         4 detail_line = vc
       3 label_detail_ln_cnt = i2
       3 label_detail_ln_qual[*]
         4 label_detail_line = vc
     2 priority = vc
     2 req_st_dt = vc
     2 frequency = vc
     2 rate = vc
     2 duration = vc
     2 duration_unit = vc
     2 nurse_collect = vc
 )
 RECORD allergy(
   1 cnt = i2
   1 qual[*]
     2 list = vc
   1 line = vc
   1 line_cnt = i2
   1 line_qual[*]
     2 line = vc
 )
 RECORD diagnosis(
   1 cnt = i2
   1 qual[*]
     2 diag = vc
   1 dline = vc
   1 dline_cnt = i2
   1 dline_qual[*]
     2 dline = vc
 )
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 SET order_cnt = 0
 SET order_cnt = size(request->order_qual,5)
 SET stat = alterlist(orders->qual,order_cnt)
 SET person_id = 0
 SET encntr_id = 0
 SET orders->spoolout_ind = 0
 SET pharm_flag = 0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 DECLARE continue_yn = i2 WITH public, noconstant(0)
 SET code_set = 4
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_cd = code_value
 SET code_set = 4
 SET cdf_meaning = "SSN"
 EXECUTE cpm_get_cd_for_cdf
 SET ssn_alias_cd = code_value
 SET code_set = 14
 SET cdf_meaning = "ORD COMMENT"
 EXECUTE cpm_get_cd_for_cdf
 SET comment_cd = code_value
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 EXECUTE cpm_get_cd_for_cdf
 SET fnbr_cd = code_value
 SET code_set = 333
 SET cdf_meaning = "ADMITDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET admit_doc_cd = code_value
 SET code_set = 333
 SET cdf_meaning = "ATTENDDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET attend_doc_cd = code_value
 SET code_set = 12025
 SET cdf_meaning = "CANCELED"
 EXECUTE cpm_get_cd_for_cdf
 SET canceled_cd = code_value
 SET code_set = 8
 SET cdf_meaning = "INERROR"
 EXECUTE cpm_get_cd_for_cdf
 SET inerror_cd = code_value
 SET code_set = 6000
 SET cdf_meaning = "PHARMACY"
 EXECUTE cpm_get_cd_for_cdf
 SET pharmacy_cd = code_value
 SET code_set = 16389
 SET cdf_meaning = "IVSOLUTIONS"
 EXECUTE cpm_get_cd_for_cdf
 SET iv_cd = code_value
 SET code_set = 6003
 SET cdf_meaning = "COMPLETE"
 EXECUTE cpm_get_cd_for_cdf
 SET complete_cd = code_value
 SET code_set = 6003
 SET cdf_meaning = "MODIFY"
 EXECUTE cpm_get_cd_for_cdf
 SET modify_cd = code_value
 SET code_set = 6003
 SET cdf_meaning = "ORDER"
 EXECUTE cpm_get_cd_for_cdf
 SET order_cd = code_value
 SET code_set = 6003
 SET cdf_meaning = "CANCEL"
 EXECUTE cpm_get_cd_for_cdf
 SET cancel_cd = code_value
 SET code_set = 6003
 SET cdf_meaning = "DISCONTINUE"
 EXECUTE cpm_get_cd_for_cdf
 SET discont_cd = code_value
 SET code_set = 212
 SET cdf_meaning = "HOME"
 EXECUTE cpm_get_cd_for_cdf
 SET home_addr_cd = code_value
 DECLARE offset = i2 WITH protect, noconstant(0)
 DECLARE daylight = i2 WITH protect, noconstant(0)
 DECLARE tz_index = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM person p,
   encounter e,
   encntr_alias ea,
   encntr_prsnl_reltn epr,
   prsnl pl,
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   encntr_loc_hist elh,
   time_zone_r t
  PLAN (p
   WHERE (p.person_id=request->person_id))
   JOIN (e
   WHERE (e.encntr_id=request->order_qual[1].encntr_id))
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id)
   JOIN (t
   WHERE t.parent_entity_id=outerjoin(elh.loc_facility_cd)
    AND t.parent_entity_name=outerjoin("LOCATION"))
   JOIN (d2)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=fnbr_cd
    AND ea.active_ind=1)
   JOIN (d3)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND ((epr.encntr_prsnl_r_cd=admit_doc_cd) OR (epr.encntr_prsnl_r_cd=attend_doc_cd))
    AND epr.active_ind=1)
   JOIN (pl
   WHERE pl.person_id=epr.prsnl_person_id)
  HEAD REPORT
   person_id = p.person_id, encntr_id = e.encntr_id, orders->name = p.name_full_formatted,
   orders->pat_type = trim(uar_get_code_display(e.encntr_type_cd)), orders->sex =
   uar_get_code_display(p.sex_cd), orders->age = cnvtage(cnvtdate(p.birth_dt_tm),curdate),
   tz_index = datetimezonebyname(trim(t.time_zone)), orders->dob = concat(format(datetimezone(p
      .birth_dt_tm,p.birth_tz),"@SHORTDATE;4;Q")," ",datetimezonebyindex(p.birth_tz,offset,daylight,7,
     p.birth_dt_tm)), orders->admit_dt = concat(format(datetimezone(e.reg_dt_tm,tz_index),
     "@SHORTDATE;4;Q")," ",datetimezonebyindex(tz_index,offset,daylight,7,e.reg_dt_tm)),
   orders->dischg_dt = concat(format(datetimezone(e.disch_dt_tm,tz_index),"@SHORTDATETIME;4;Q")," ",
    datetimezonebyindex(tz_index,offset,daylight,7,e.disch_dt_tm))
   IF (((e.reg_dt_tm=null) OR (e.reg_dt_tm=0)) )
    orders->los = null
   ELSE
    IF (((e.disch_dt_tm=null) OR (e.disch_dt_tm=0)) )
     orders->los = (datetimecmp(cnvtdatetime(curdate,curtime3),e.reg_dt_tm)+ 1)
    ELSE
     orders->los = (datetimecmp(e.disch_dt_tm,e.reg_dt_tm)+ 1)
    ENDIF
   ENDIF
   orders->facility = uar_get_code_description(e.loc_facility_cd), orders->nurse_unit =
   uar_get_code_display(e.loc_nurse_unit_cd), orders->room = uar_get_code_display(e.loc_room_cd),
   orders->bed = uar_get_code_display(e.loc_bed_cd), orders->isolation = uar_get_code_display(e
    .isolation_cd), orders->location = concat(trim(orders->nurse_unit),"/",trim(orders->room),"/",
    trim(orders->bed)),
   orders->admit_diagnosis = e.reason_for_visit, orders->med_service = uar_get_code_display(e
    .med_service_cd)
  HEAD epr.encntr_prsnl_r_cd
   IF (epr.encntr_prsnl_r_cd=admit_doc_cd)
    orders->admitting = pl.name_full_formatted
   ENDIF
  DETAIL
   IF (ea.encntr_alias_type_cd=fnbr_cd)
    IF (ea.alias_pool_cd > 0)
     orders->fnbr = cnvtalias(ea.alias,ea.alias_pool_cd)
    ELSE
     orders->fnbr = ea.alias
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d2, dontcare = ea,
   outerjoin = d3, dontcare = epr
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   org_alias_pool_reltn oapr,
   person_alias pa
  PLAN (e
   WHERE (e.encntr_id=request->order_qual[1].encntr_id))
   JOIN (oapr
   WHERE oapr.organization_id=e.organization_id
    AND oapr.active_ind=1
    AND oapr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND oapr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND oapr.alias_entity_alias_type_cd=mrn_alias_cd)
   JOIN (pa
   WHERE (pa.person_id=request->person_id)
    AND pa.alias_pool_cd=oapr.alias_pool_cd
    AND pa.person_alias_type_cd=mrn_alias_cd
    AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND pa.active_ind=1)
  DETAIL
   IF (pa.alias_pool_cd > 0)
    orders->mrn = cnvtalias(pa.alias,pa.alias_pool_cd)
   ELSE
    orders->mrn = pa.alias
   ENDIF
  WITH nocounter, skipreport = 0
 ;end select
 SELECT INTO "nl:"
  FROM person_alias pa2
  PLAN (pa2
   WHERE (pa2.person_id=request->person_id)
    AND pa2.person_alias_type_cd=ssn_alias_cd
    AND pa2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pa2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND pa2.active_ind=1)
  DETAIL
   IF (pa2.alias_pool_cd > 0)
    orders->nhs_num = cnvtalias(pa2.alias,pa2.alias_pool_cd)
   ELSE
    orders->nhs_num = pa2.alias
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encntr_prsnl_reltn epr,
   prsnl pl
  PLAN (epr
   WHERE epr.encntr_prsnl_r_cd=attend_doc_cd
    AND (epr.encntr_id=request->order_qual[1].encntr_id)
    AND ((epr.expiration_ind+ 0)=0)
    AND epr.active_ind=1
    AND epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (pl
   WHERE pl.person_id=epr.prsnl_person_id)
  ORDER BY epr.active_status_dt_tm
  HEAD REPORT
   orders->attending = pl.name_full_formatted
  DETAIL
   IF ((epr.prsnl_person_id=request->print_prsnl_id))
    orders->attending = pl.name_full_formatted
   ENDIF
 ;end select
 SELECT INTO "nl:"
  FROM address a
  WHERE (a.parent_entity_id=request->person_id)
   AND a.parent_entity_name="PERSON"
   AND a.address_type_cd=home_addr_cd
   AND a.active_ind=1
   AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  HEAD REPORT
   orders->addr_cnt = 0
   IF (textlen(trim(a.street_addr)) > 0)
    orders->addr_cnt = (orders->addr_cnt+ 1), flengthinch = 1.5, orders->addr[orders->addr_cnt].
    addr_line = fmttruncatebyfonttype(flengthinch,charsperinch,trim(a.street_addr),1,"HELVETICA")
   ENDIF
   IF (textlen(trim(a.street_addr2)) > 0)
    orders->addr_cnt = (orders->addr_cnt+ 1), flengthinch = 1.5, orders->addr[orders->addr_cnt].
    addr_line = fmttruncatebyfonttype(flengthinch,charsperinch,trim(a.street_addr2),1,"HELVETICA")
   ENDIF
   IF (textlen(trim(a.street_addr3)) > 0)
    orders->addr_cnt = (orders->addr_cnt+ 1), flengthinch = 1.5, orders->addr[orders->addr_cnt].
    addr_line = fmttruncatebyfonttype(flengthinch,charsperinch,trim(a.street_addr3),1,"HELVETICA")
   ENDIF
   IF (((textlen(trim(a.city)) > 0) OR (textlen(trim(a.zipcode)) > 0)) )
    orders->addr_cnt = (orders->addr_cnt+ 1), flengthinch = 1.5, totalpoints = distancetopoints(
     flengthinch)
    IF (textlen(trim(a.zipcode)) > 0)
     zippoints = stringwidthbyfonttype(trim(a.zipcode),charsperinch,0,"HELVETICA"), totalpoints = (
     totalpoints - zippoints), flengthinch = pointstodistance(totalpoints)
    ENDIF
    IF (textlen(trim(a.city)) > 0)
     orders->addr[orders->addr_cnt].addr_line = fmttruncatebyfonttype(flengthinch,charsperinch,trim(a
       .city),1,"HELVETICA")
    ENDIF
    IF (textlen(trim(a.zipcode)) > 0)
     orders->addr[orders->addr_cnt].addr_line = concat(trim(orders->addr[orders->addr_cnt].addr_line),
      "  ",trim(a.zipcode))
    ENDIF
   ENDIF
 ;end select
 SELECT INTO "nl:"
  FROM allergy a,
   (dummyt d  WITH seq = 1),
   nomenclature n
  PLAN (a
   WHERE (a.person_id=request->person_id)
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (a.end_effective_dt_tm=null))
    AND a.reaction_status_cd != canceled_cd)
   JOIN (d)
   JOIN (n
   WHERE n.nomenclature_id=a.substance_nom_id)
  ORDER BY cnvtdatetime(a.onset_dt_tm)
  HEAD REPORT
   allergy->cnt = 0
  DETAIL
   IF (((n.source_string > " ") OR (a.substance_ftdesc > " ")) )
    allergy->cnt = (allergy->cnt+ 1), stat = alterlist(allergy->qual,allergy->cnt), allergy->qual[
    allergy->cnt].list = a.substance_ftdesc
    IF (n.source_string > " ")
     allergy->qual[allergy->cnt].list = n.source_string
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d, dontcare = n
 ;end select
 FOR (x = 1 TO allergy->cnt)
   IF (x=1)
    SET allergy->line = allergy->qual[x].list
   ELSE
    SET allergy->line = concat(trim(allergy->line),", ",trim(allergy->qual[x].list))
   ENDIF
 ENDFOR
 IF ((allergy->cnt > 0))
  SET flengthinch = 5.5
  SET stat = wordwrapbyfont(nullterm(allergy->line),charsperinch,flengthinch,0,"HELVETICA")
  SET allergy->line_cnt = simlabwrappedtext->output_string_cnt
  SET stat = alterlist(allergy->line_qual,simlabwrappedtext->output_string_cnt)
  FOR (z = 1 TO simlabwrappedtext->output_string_cnt)
    SET allergy->line_qual[z].line = simlabwrappedtext->output_string[z].string
  ENDFOR
 ENDIF
 SET mnem_disp_level = "1"
 SET iv_disp_level = "0"
 IF (pharm_flag=1)
  SELECT INTO "nl:"
   FROM name_value_prefs n,
    app_prefs a
   PLAN (n
    WHERE n.pvc_name IN ("MNEM_DISP_LEVEL", "IV_DISP_LEVEL"))
    JOIN (a
    WHERE a.app_prefs_id=n.parent_entity_id
     AND a.prsnl_id=0
     AND a.position_cd=0)
   DETAIL
    IF (n.pvc_name="MNEM_DISP_LEVEL"
     AND n.pvc_value IN ("0", "1", "2"))
     mnem_disp_level = n.pvc_value
    ELSEIF (n.pvc_name="IV_DISP_LEVEL"
     AND n.pvc_value IN ("0", "1"))
     iv_disp_level = n.pvc_value
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET ord_cnt = 0
 SELECT INTO "nl:"
  FROM orders o,
   order_action oa,
   prsnl pl,
   prsnl pl2,
   (dummyt d1  WITH seq = value(order_cnt))
  PLAN (d1)
   JOIN (o
   WHERE (o.order_id=request->order_qual[d1.seq].order_id))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=o.last_action_sequence)
   JOIN (pl
   WHERE pl.person_id=oa.action_personnel_id)
   JOIN (pl2
   WHERE pl2.person_id=oa.order_provider_id)
  ORDER BY o.oe_format_id, o.activity_type_cd, o.current_start_dt_tm
  HEAD REPORT
   orders->order_location = trim(uar_get_code_display(oa.order_locn_cd))
  HEAD o.order_id
   ord_cnt = (ord_cnt+ 1), orders->qual[ord_cnt].status = uar_get_code_display(o.order_status_cd),
   orders->qual[ord_cnt].catalog = uar_get_code_display(o.catalog_type_cd),
   orders->qual[ord_cnt].catalog_type_cd = o.catalog_type_cd, orders->qual[ord_cnt].activity =
   uar_get_code_display(o.activity_type_cd), orders->qual[ord_cnt].activity_type_cd = o
   .activity_type_cd,
   orders->qual[ord_cnt].display_line = o.clinical_display_line, orders->qual[ord_cnt].order_id = o
   .order_id, orders->qual[ord_cnt].display_ind = 1,
   orders->qual[ord_cnt].template_order_flag = o.template_order_flag, orders->qual[ord_cnt].cs_flag
    = o.cs_flag, orders->qual[ord_cnt].oe_format_id = o.oe_format_id
   IF (substring(245,10,o.clinical_display_line) > "  ")
    orders->qual[ord_cnt].clin_line_ind = 1
   ELSE
    orders->qual[ord_cnt].clin_line_ind = 0
   ENDIF
   orders->qual[ord_cnt].mnemonic = o.hna_order_mnemonic, orders->qual[ord_cnt].order_dt = concat(
    format(datetimezone(oa.order_dt_tm,oa.order_tz),"@SHORTDATETIME;4;Q")," ",datetimezonebyindex(oa
     .order_tz,offset,daylight,7,oa.order_dt_tm)), orders->qual[ord_cnt].signed_dt = concat(format(
     datetimezone(o.orig_order_dt_tm,o.orig_order_tz),"@SHORTDATETIME;4;Q")," ",datetimezonebyindex(o
     .orig_order_tz,offset,daylight,7,o.orig_order_dt_tm)),
   orders->qual[ord_cnt].comment_ind = o.order_comment_ind, orders->qual[ord_cnt].last_action_seq = o
   .last_action_sequence, orders->qual[ord_cnt].enter_by = pl.name_full_formatted,
   orders->qual[ord_cnt].order_dr = pl2.name_full_formatted, orders->qual[ord_cnt].type =
   uar_get_code_display(oa.communication_type_cd), orders->qual[ord_cnt].action_type_cd = oa
   .action_type_cd,
   orders->qual[ord_cnt].action = uar_get_code_display(oa.action_type_cd), orders->qual[ord_cnt].
   iv_ind = o.iv_ind
   IF (o.dcp_clin_cat_cd=iv_cd)
    orders->qual[ord_cnt].iv_ind = 1
   ENDIF
   IF (o.catalog_type_cd=pharmacy_cd)
    IF (mnem_disp_level="0")
     orders->qual[ord_cnt].mnemonic = trim(o.hna_order_mnemonic)
    ENDIF
    IF (mnem_disp_level="1")
     IF (((o.hna_order_mnemonic=o.ordered_as_mnemonic) OR (o.ordered_as_mnemonic=" ")) )
      orders->qual[ord_cnt].mnemonic = trim(o.hna_order_mnemonic)
     ELSE
      orders->qual[ord_cnt].mnemonic = concat(trim(o.hna_order_mnemonic),"(",trim(o
        .ordered_as_mnemonic),")")
     ENDIF
    ENDIF
    IF (mnem_disp_level="2"
     AND o.iv_ind != 1)
     IF (((o.hna_order_mnemonic=o.ordered_as_mnemonic) OR (o.ordered_as_mnemonic=" ")) )
      orders->qual[ord_cnt].mnemonic = trim(o.hna_order_mnemonic)
     ELSE
      orders->qual[ord_cnt].mnemonic = concat(trim(o.hna_order_mnemonic),"(",trim(o
        .ordered_as_mnemonic),")")
     ENDIF
     IF (o.order_mnemonic != o.ordered_as_mnemonic
      AND o.order_mnemonic > " ")
      orders->qual[ord_cnt].mnemonic = concat(trim(orders->qual[ord_cnt].mnemonic),"(",trim(o
        .order_mnemonic),")")
     ENDIF
    ENDIF
   ENDIF
   IF (oa.action_type_cd IN (order_cd, modify_cd))
    orders->qual[ord_cnt].display_ind = 1, orders->spoolout_ind = 1
   ELSE
    orders->qual[ord_cnt].display_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_detail od,
   oe_format_fields oef,
   order_entry_fields of1,
   (dummyt d1  WITH seq = value(order_cnt))
  PLAN (d1)
   JOIN (od
   WHERE (orders->qual[d1.seq].order_id=od.order_id))
   JOIN (oef
   WHERE (oef.oe_format_id=orders->qual[d1.seq].oe_format_id)
    AND (oef.action_type_cd=orders->qual[d1.seq].action_type_cd)
    AND oef.oe_field_id=od.oe_field_id
    AND oef.accept_flag IN (0, 1))
   JOIN (of1
   WHERE of1.oe_field_id=oef.oe_field_id)
  ORDER BY od.order_id, oef.group_seq, od.action_sequence DESC
  HEAD REPORT
   orders->qual[d1.seq].d_cnt = 0
  HEAD od.order_id
   stat = alterlist(orders->qual[d1.seq].d_qual,5), orders->qual[d1.seq].stat_ind = 0
  HEAD od.oe_field_id
   act_seq = od.action_sequence, odflag = 1
   IF (((od.oe_field_meaning="COLLPRI") OR (od.oe_field_meaning="PRIORITY")) )
    orders->qual[d1.seq].priority = od.oe_field_display_value
   ENDIF
   IF (od.oe_field_meaning="REQSTARTDTTM")
    orders->qual[d1.seq].req_st_dt = od.oe_field_display_value
   ENDIF
   IF (od.oe_field_meaning="FREQ")
    orders->qual[d1.seq].frequency = od.oe_field_display_value
   ENDIF
   IF (od.oe_field_meaning="RATE")
    orders->qual[d1.seq].rate = od.oe_field_display_value
   ENDIF
   IF (od.oe_field_meaning="DURATION")
    orders->qual[d1.seq].duration = od.oe_field_display_value
   ENDIF
   IF (od.oe_field_meaning="DURATIONUNIT")
    orders->qual[d1.seq].duration_unit = od.oe_field_display_value
   ENDIF
   IF (od.oe_field_meaning="NURSECOLLECT")
    orders->qual[d1.seq].nurse_collect = od.oe_field_display_value
   ENDIF
  HEAD od.action_sequence
   IF (act_seq != od.action_sequence)
    odflag = 0
   ENDIF
  DETAIL
   IF (odflag=1)
    orders->qual[d1.seq].d_cnt = (orders->qual[d1.seq].d_cnt+ 1), dc = orders->qual[d1.seq].d_cnt
    IF (dc > size(orders->qual[d1.seq].d_qual,5))
     stat = alterlist(orders->qual[d1.seq].d_qual,(dc+ 5))
    ENDIF
    orders->qual[d1.seq].d_qual[dc].label_text = trim(oef.label_text), orders->qual[d1.seq].d_qual[dc
    ].field_value = od.oe_field_value, orders->qual[d1.seq].d_qual[dc].group_seq = oef.group_seq,
    orders->qual[d1.seq].d_qual[dc].oe_field_meaning_id = od.oe_field_meaning_id, orders->qual[d1.seq
    ].d_qual[dc].value = trim(od.oe_field_display_value), orders->qual[d1.seq].d_qual[dc].
    clin_line_ind = oef.clin_line_ind,
    orders->qual[d1.seq].d_qual[dc].label = trim(oef.clin_line_label), orders->qual[d1.seq].d_qual[dc
    ].suffix = oef.clin_suffix_ind
    IF (od.oe_field_display_value > " ")
     orders->qual[d1.seq].d_qual[dc].print_ind = 0
    ELSE
     orders->qual[d1.seq].d_qual[dc].print_ind = 1
    ENDIF
    IF (((od.oe_field_meaning_id=1100) OR (((od.oe_field_meaning_id=8) OR (((od.oe_field_meaning_id=
    127) OR (od.oe_field_meaning_id=43)) )) ))
     AND trim(cnvtupper(od.oe_field_display_value))="STAT")
     orders->qual[d1.seq].stat_ind = 1
    ENDIF
    IF (of1.field_type_flag=7)
     IF (od.oe_field_value=1)
      IF (((oef.disp_yes_no_flag=0) OR (oef.disp_yes_no_flag=1)) )
       orders->qual[d1.seq].d_qual[dc].value = trim(oef.label_text)
      ELSE
       orders->qual[d1.seq].d_qual[dc].clin_line_ind = 0
      ENDIF
     ELSE
      IF (((oef.disp_yes_no_flag=0) OR (oef.disp_yes_no_flag=2)) )
       orders->qual[d1.seq].d_qual[dc].value = trim(oef.clin_line_label)
      ELSE
       orders->qual[d1.seq].d_qual[dc].clin_line_ind = 0
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT  od.order_id
   stat = alterlist(orders->qual[d1.seq].d_qual,dc)
  WITH nocounter
 ;end select
 FOR (x = 1 TO order_cnt)
   IF ((orders->qual[x].display_line > " "))
    SET pt->line_cnt = 0
    SET max_length = 80
    EXECUTE dcp_parse_text value(orders->qual[x].display_line), value(max_length)
    SET stat = alterlist(orders->qual[x].disp_ln_qual,pt->line_cnt)
    SET orders->qual[x].disp_ln_cnt = pt->line_cnt
    FOR (y = 1 TO pt->line_cnt)
      SET orders->qual[x].disp_ln_qual[y].disp_line = pt->lns[y].line
    ENDFOR
   ENDIF
 ENDFOR
 FOR (x = 1 TO order_cnt)
   SELECT INTO "nl:"
    FROM accession_order_r aor
    PLAN (aor
     WHERE (aor.order_id=orders->qual[x].order_id))
    DETAIL
     orders->qual[x].accession = aor.accession
    WITH nocounter
   ;end select
 ENDFOR
 FOR (x = 1 TO order_cnt)
   IF ((orders->qual[x].iv_ind=1))
    SELECT INTO "nl:"
     FROM order_ingredient oi
     PLAN (oi
      WHERE (oi.order_id=orders->qual[x].order_id))
     ORDER BY oi.action_sequence, oi.comp_sequence
     HEAD oi.action_sequence
      mnemonic_line = fillstring(1000," "), first_time = "Y"
     DETAIL
      IF (first_time="Y")
       IF (oi.ordered_as_mnemonic > " ")
        mnemonic_line = concat(trim(oi.ordered_as_mnemonic),", ",trim(oi.order_detail_display_line))
       ELSE
        mnemonic_line = concat(trim(oi.order_mnemonic),", ",trim(oi.order_detail_display_line))
       ENDIF
       first_time = "N"
      ELSE
       IF (oi.ordered_as_mnemonic > " ")
        mnemonic_line = concat(trim(mnemonic_line),", ",trim(oi.ordered_as_mnemonic),", ",trim(oi
          .order_detail_display_line))
       ELSE
        mnemonic_line = concat(trim(mnemonic_line),", ",trim(oi.order_mnemonic),", ",trim(oi
          .order_detail_display_line))
       ENDIF
      ENDIF
     FOOT REPORT
      orders->qual[x].mnemonic = mnemonic_line
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 FOR (x = 1 TO order_cnt)
   IF ((orders->qual[x].mnemonic > " "))
    SET pt->line_cnt = 0
    SET max_length = 45
    EXECUTE dcp_parse_text value(orders->qual[x].mnemonic), value(max_length)
    SET stat = alterlist(orders->qual[x].mnem_ln_qual,pt->line_cnt)
    SET orders->qual[x].mnem_ln_cnt = pt->line_cnt
    FOR (y = 1 TO pt->line_cnt)
      SET orders->qual[x].mnem_ln_qual[y].mnem_line = pt->lns[y].line
    ENDFOR
   ENDIF
 ENDFOR
 FOR (x = 1 TO order_cnt)
   IF ((orders->qual[x].comment_ind=1))
    SELECT INTO "nl:"
     FROM order_comment oc,
      long_text lt
     PLAN (oc
      WHERE (oc.order_id=orders->qual[x].order_id)
       AND oc.comment_type_cd=comment_cd)
      JOIN (lt
      WHERE lt.long_text_id=oc.long_text_id)
     DETAIL
      orders->qual[x].comment = lt.long_text
     WITH nocounter
    ;end select
    SET flengthinch = 6.5
    SET stat = wordwrapbyfont(nullterm(orders->qual[x].comment),charsperinch,flengthinch,0,
     "HELVETICA")
    SET orders->qual[x].com_ln_cnt = simlabwrappedtext->output_string_cnt
    SET stat = alterlist(orders->qual[x].com_ln_qual,simlabwrappedtext->output_string_cnt)
    FOR (z = 1 TO simlabwrappedtext->output_string_cnt)
      SET orders->qual[x].com_ln_qual[z].com_line = simlabwrappedtext->output_string[z].string
    ENDFOR
   ENDIF
 ENDFOR
 FOR (x = 1 TO order_cnt)
   FOR (y = 1 TO orders->qual[x].d_cnt)
    IF ((orders->qual[x].d_qual[y].label_text > " "))
     SET flengthinch = 2.75
     SET stat = wordwrapbyfont(nullterm(orders->qual[x].d_qual[y].label_text),charsperinch,
      flengthinch,0,"HELVETICA")
     SET orders->qual[x].d_qual[y].label_detail_ln_cnt = simlabwrappedtext->output_string_cnt
     SET stat = alterlist(orders->qual[x].d_qual[y].label_detail_ln_qual,simlabwrappedtext->
      output_string_cnt)
     FOR (z = 1 TO simlabwrappedtext->output_string_cnt)
       SET orders->qual[x].d_qual[y].label_detail_ln_qual[z].label_detail_line = simlabwrappedtext->
       output_string[z].string
     ENDFOR
    ENDIF
    IF ((orders->qual[x].d_qual[y].value > " "))
     SET flengthinch = 3.5
     SET stat = wordwrapbyfont(nullterm(orders->qual[x].d_qual[y].value),charsperinch,flengthinch,0,
      "HELVETICA")
     SET orders->qual[x].d_qual[y].detail_ln_cnt = simlabwrappedtext->output_string_cnt
     SET stat = alterlist(orders->qual[x].d_qual[y].detail_ln_qual,simlabwrappedtext->
      output_string_cnt)
     FOR (z = 1 TO simlabwrappedtext->output_string_cnt)
       SET orders->qual[x].d_qual[y].detail_ln_qual[z].detail_line = simlabwrappedtext->
       output_string[z].string
     ENDFOR
    ENDIF
   ENDFOR
 ENDFOR
 IF ((orders->spoolout_ind=1))
  SET new_timedisp = cnvtstring(curtime3)
  SET tempfile1a = build(concat("cer_temp:dcpreq","_",new_timedisp),".dat")
  SET temp = fillstring(50," ")
  SELECT INTO value(tempfile1a)
   d.seq
   FROM (dummyt d  WITH seq = value(size(orders->qual,5)))
   PLAN (d)
   HEAD REPORT
    first_page = "Y", spaces = fillstring(50," ")
   HEAD PAGE
    IF (continue_yn=1)
     col 5, "{cpi/12}", xrow = 80,
     xcol = 44, row + 1, col 1,
     CALL print(calcpos(xcol,xrow)), "{b}", "Patient:",
     "{ENDB}", xcol = 110,
     CALL print(calcpos(xcol,xrow)),
     orders->name, xrow = (xrow+ 14), xcol = 44,
     row + 1,
     CALL print(calcpos(xcol,xrow)), "{b}",
     "MRN#:", "{ENDB}", xcol = 110,
     CALL print(calcpos(xcol,xrow)), orders->mrn, xrow = (xrow+ 14),
     xcol = 44, row + 1,
     CALL print(calcpos(xcol,xrow)),
     "Fin#:", xcol = 110,
     CALL print(calcpos(xcol,xrow)),
     orders->fnbr, xrow = (xrow+ 14), xcol = 44,
     row + 1,
     CALL print(calcpos(xcol,xrow)), "NHS#:",
     xcol = 110,
     CALL print(calcpos(xcol,xrow)), orders->nhs_num,
     xrow = (xrow+ 14), xcol = 44, row + 1,
     CALL print(calcpos(xcol,xrow)), "{b}", "Request: ",
     "{ENDB}", xcol = 110,
     CALL print(calcpos(xcol,xrow)),
     orders->qual[d.seq].mnemonic
    ELSE
     orders->mrn_bcr = concat("*",orders->mrn,"*"), row 0, col 5,
     "{font/9}", row + 3, col 12,
     "{cpi/8}{B}", orders->facility, row + 3,
     col 9, "{cpi/10}Order Requisition", row + 1,
     col 5, "{cpi/12}", xrow = 90,
     xcol = 44, row + 1, col 1,
     CALL print(calcpos(xcol,xrow)), "{box/85/1}", xrow = (xrow+ 10),
     xcol = 50,
     CALL print(calcpos(xcol,xrow)), "Patient Information",
     xrow = (xrow+ 25), xcol = 50, row + 1,
     col 1,
     CALL print(calcpos(xcol,xrow)), "Patient:",
     xcol = 125,
     CALL print(calcpos(xcol,xrow)), orders->name,
     xrow = (xrow+ 14), xcol = 50, row + 1,
     col 1,
     CALL print(calcpos(xcol,xrow)), "Location:",
     xcol = 125,
     CALL print(calcpos(xcol,xrow)), orders->location,
     xrow = (xrow+ 14), xcol = 50, row + 1,
     col 1,
     CALL print(calcpos(xcol,xrow)), "Consultant:",
     xcol = 125,
     CALL print(calcpos(xcol,xrow)), orders->attending,
     xcol = 430,
     CALL print(calcpos(xcol,xrow)), "{lpi/6}{cpi/6}{bcr/250}{font/28}",
     orders->mrn_bcr, "{cpi/12}{B}{font/9}", xrow = (xrow+ 20),
     xcol = 50, row + 1, col 1,
     CALL print(calcpos(xcol,xrow)), "LOS:", xcol = 80,
     CALL print(calcpos(xcol,xrow)), orders->los, " Days",
     xcol = 220,
     CALL print(calcpos(xcol,xrow)), "Admit Date:",
     xcol = 285,
     CALL print(calcpos(xcol,xrow)), orders->admit_dt,
     xcol = 380,
     CALL print(calcpos(xcol,xrow)), "MRN#:",
     xcol = 425,
     CALL print(calcpos(xcol,xrow)), orders->mrn,
     xrow = (xrow+ 20), xcol = 50, row + 1,
     col 1,
     CALL print(calcpos(xcol,xrow)), "Age:",
     xcol = 100,
     CALL print(calcpos(xcol,xrow)), orders->age,
     xcol = 220,
     CALL print(calcpos(xcol,xrow)), "DOB:",
     xcol = 250,
     CALL print(calcpos(xcol,xrow)), orders->dob,
     xcol = 380,
     CALL print(calcpos(xcol,xrow)), "Fin#:",
     xcol = 425,
     CALL print(calcpos(xcol,xrow)), orders->fnbr,
     xrow = (xrow+ 14), xcol = 50, row + 1,
     col 1,
     CALL print(calcpos(xcol,xrow)), "Sex:",
     xcol = 105,
     CALL print(calcpos(xcol,xrow)), orders->sex,
     xcol = 380,
     CALL print(calcpos(xcol,xrow)), "NHS#:",
     xcol = 425,
     CALL print(calcpos(xcol,xrow)), orders->nhs_num,
     xrow = (xrow+ 20), xcol = 50, xcol = 380,
     CALL print(calcpos(xcol,xrow)), "Visit Type:", xcol = 450,
     CALL print(calcpos(xcol,xrow)), orders->pat_type, xrow = (xrow+ 14),
     xcol = 50, row + 1, col 1,
     CALL print(calcpos(xcol,xrow)), "Allergies:"
     IF ((allergy->line_cnt > 0))
      FOR (zz = 1 TO allergy->line_cnt)
        xcol = 125
        IF (zz > 1)
         xrow = (xrow+ 12)
        ENDIF
        CALL print(calcpos(xcol,xrow)), allergy->line_qual[zz].line, row + 1
      ENDFOR
     ENDIF
     xrow = (xrow+ 14), xcol = 50,
     CALL print(calcpos(xcol,xrow)),
     "Reason for Visit:", xcol = 145,
     CALL print(calcpos(xcol,xrow)),
     orders->admit_diagnosis, xcol = 380,
     CALL print(calcpos(xcol,xrow)),
     "Address:", xcol = 432,
     CALL print(calcpos(xcol,xrow)),
     orders->addr[1].addr_line, xrow = (xrow+ 9), xcol = 432,
     CALL print(calcpos(xcol,xrow)), orders->addr[2].addr_line, xrow = (xrow+ 9),
     xcol = 432,
     CALL print(calcpos(xcol,xrow)), orders->addr[3].addr_line,
     xrow = (xrow+ 10), xcol = 44, row + 1,
     CALL print(calcpos(xcol,xrow)), "{box/85/1}", xrow = (xrow+ 10),
     xcol = 50,
     CALL print(calcpos(xcol,xrow)), "Order Details"
    ENDIF
    continue_yn = 0
   DETAIL
    IF (first_page="N")
     BREAK
    ENDIF
    first_page = "N", xrow = (xrow+ 25), xcol = 50,
    row + 1,
    CALL print(calcpos(xcol,xrow)), "Procedure: ",
    xcol = 110,
    CALL print(calcpos(xcol,xrow)), orders->qual[d.seq].mnemonic,
    xcol = 380,
    CALL print(calcpos(xcol,xrow)), "Order Status:",
    xcol = 460,
    CALL print(calcpos(xcol,xrow)), orders->qual[d.seq].status,
    xrow = (xrow+ 14), xcol = 50, row + 1,
    CALL print(calcpos(xcol,xrow)), "Accession: ", xcol = 110,
    CALL print(calcpos(xcol,xrow)), orders->qual[d.seq].accession, xcol = 50,
    xrow = (xrow+ 17), row + 1, ymove = 12
    FOR (fsub = 1 TO 31)
      FOR (ww = 1 TO orders->qual[d.seq].d_cnt)
        IF ((((orders->qual[d.seq].d_qual[ww].group_seq=fsub)) OR (fsub=31
         AND (orders->qual[d.seq].d_qual[ww].print_ind=0))) )
         orders->qual[d.seq].d_qual[ww].print_ind = 1
         IF ((orders->qual[d.seq].d_qual[ww].value > spaces))
          IF ((orders->qual[d.seq].d_qual[ww].label_detail_ln_cnt > orders->qual[d.seq].d_qual[ww].
          detail_ln_cnt))
           ycol1 = (xrow+ (ymove * orders->qual[d.seq].d_qual[ww].label_detail_ln_cnt))
          ELSE
           ycol1 = (xrow+ (ymove * orders->qual[d.seq].d_qual[ww].detail_ln_cnt))
          ENDIF
          IF (ycol1 > 600)
           continue_yn = 1,
           CALL echo("new page!"), BREAK,
           xrow = (xrow+ 20), row + 1
          ENDIF
          xcol = 50
          FOR (z = 1 TO orders->qual[d.seq].d_qual[ww].label_detail_ln_cnt)
            ycol1 = (xrow+ (ymove * z)),
            CALL print(calcpos(xcol,ycol1)),
            CALL print(orders->qual[d.seq].d_qual[ww].label_detail_ln_qual[z].label_detail_line)
            IF ((z=orders->qual[d.seq].d_qual[ww].label_detail_ln_cnt))
             CALL print(":")
            ENDIF
            row + 1
          ENDFOR
          xcol = 290
          FOR (z = 1 TO orders->qual[d.seq].d_qual[ww].detail_ln_cnt)
            ycol1 = (xrow+ (ymove * z)),
            CALL print(calcpos(xcol,ycol1)),
            CALL print(orders->qual[d.seq].d_qual[ww].detail_ln_qual[z].detail_line),
            row + 1
          ENDFOR
          IF ((orders->qual[d.seq].d_qual[ww].label_detail_ln_cnt > orders->qual[d.seq].d_qual[ww].
          detail_ln_cnt))
           xrow = (xrow+ (ymove * orders->qual[d.seq].d_qual[ww].label_detail_ln_cnt))
          ELSE
           xrow = (xrow+ (ymove * orders->qual[d.seq].d_qual[ww].detail_ln_cnt))
          ENDIF
          xrow = (xrow+ ymove), row + 1
         ENDIF
        ENDIF
      ENDFOR
    ENDFOR
    printed_dt_tm = concat(format(datetimezone(cnvtdatetime(curdate,curtime3),curtimezoneapp,1),
      "@SHORTDATETIME;4;Q")), xrow = 630, xcol = 50,
    row + 1,
    CALL print(calcpos(xcol,xrow)), "Ordering MD: ",
    xcol = 130,
    CALL print(calcpos(xcol,xrow)), orders->qual[d.seq].order_dr,
    xcol = 350,
    CALL print(calcpos(xcol,xrow)), "Ordering Date/Time:",
    xcol = 450,
    CALL print(calcpos(xcol,xrow)), orders->qual[d.seq].signed_dt,
    xrow = (xrow+ 12), xcol = 50, row + 1,
    CALL print(calcpos(xcol,xrow)), "Ordering Type: ", xcol = 130,
    CALL print(calcpos(xcol,xrow)), orders->qual[d.seq].type, xrow = (xrow+ 12),
    xcol = 50, row + 1,
    CALL print(calcpos(xcol,xrow)),
    "Ordering entered by: ", xcol = 160,
    CALL print(calcpos(xcol,xrow)),
    orders->qual[d.seq].enter_by, xcol = 350,
    CALL print(calcpos(xcol,xrow)),
    "Printed Date/Time: ", xcol = 450,
    CALL print(calcpos(xcol,xrow)),
    printed_dt_tm, xrow = (xrow+ 15), xcol = 44,
    row + 1,
    CALL print(calcpos(xcol,xrow)), "{box/85/1}",
    xrow = (xrow+ 10), xcol = 50,
    CALL print(calcpos(xcol,xrow)),
    "Ordering Comments", xrow = (xrow+ 10)
    IF ((orders->qual[d.seq].com_ln_cnt > 0))
     IF ((orders->qual[d.seq].com_ln_cnt > 8))
      orders->qual[d.seq].com_ln_cnt = 8
     ENDIF
     FOR (w = 1 TO orders->qual[d.seq].com_ln_cnt)
       xrow = (xrow+ 15), xcol = 70, row + 1,
       CALL print(calcpos(xcol,xrow)), orders->qual[d.seq].com_ln_qual[w].com_line
     ENDFOR
    ENDIF
   WITH nocounter, maxrow = 800, maxcol = 750,
    dio = postscript
  ;end select
  SET spool value(trim(tempfile1a)) value(trim(request->printer_name)) WITH deleted
 ENDIF
#exit_script
END GO
