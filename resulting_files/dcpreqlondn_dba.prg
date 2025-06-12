CREATE PROGRAM dcpreqlondn:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH noconstant(" "), private
 ENDIF
 SET last_mod = "015"
 SET last_mod = "206737"
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
 DECLARE chars_per_inch = i2 WITH constant(12)
 DECLARE field_size_in_inch = f8 WITH noconstant(0.0)
 RECORD orders(
   1 name = vc
   1 organization = vc
   1 age = vc
   1 dob = vc
   1 sex = vc
   1 race = vc
   1 admitting_dr = vc
   1 attending_dr = vc
   1 attending_dr_name_last = vc
   1 attending_dr_name_first = vc
   1 mrn = vc
   1 mrnbc = vc
   1 ssn = vc
   1 fnbr = vc
   1 admit_diagnosis = vc
   1 type = vc
   1 financial_num = vc
   1 financial_class = vc
   1 admit_dt_tm = vc
   1 location = vc
   1 facility = vc
   1 nurse_unit = vc
   1 room = vc
   1 bed = vc
   1 isolation = vc
   1 hphone = vc
   1 wphone = vc
   1 med_service = vc
   1 street = vc
   1 city_state_zip = vc
   1 pri_insur = vc
   1 pri_pol_nbr = vc
   1 pri_grp_nbr = vc
   1 sec_insur = vc
   1 sec_pol_nbr = vc
   1 sec_grp_nbr = vc
   1 allergy_cnt = i2
   1 aqual[*]
     2 allergy_display = vc
   1 diag_cnt = i2
   1 dqual[*]
     2 diag_display = vc
   1 order_location = vc
   1 spoolout_ind = i2
   1 qual[*]
     2 display_ind = i2
     2 template_order_flag = i4
     2 special_action_ind = i2
     2 stat_ind = i2
     2 order_id = f8
     2 event_cds = vc
     2 order_mnemonic = vc
     2 order_mnemonic_alias = vc
     2 oe_format_id = f8
     2 action_type_cd = f8
     2 action_type = vc
     2 action_meaning = vc
     2 catalog_cd = f8
     2 catalog_type = vc
     2 catalog_type_cd = f8
     2 activity_type_cd = f8
     2 activity_type = vc
     2 activity_subtype = vc
     2 action = vc
     2 action_prsnl_name = vc
     2 action_prsnl_name_last = vc
     2 action_prsnl_name_first = vc
     2 action_dt_tm = dq8
     2 action_sequence = i4
     2 order_provider_name = vc
     2 order_provider_id = f8
     2 current_start_dt_tm = dq8
     2 accession = vc
     2 accession1 = vc
     2 details_retrieved = i2
     2 detail_cnt = i2
     2 detail_qual[*]
       3 field_id = f8
       3 field_description = vc
       3 label_text = vc
       3 display_value = vc
       3 field_value = f8
       3 oe_field_meaning_id = f8
       3 group_seq = i4
       3 print_ind = i2
       3 detail_ln_cnt = i2
       3 detail_ln_qual[*]
         4 detail_line = vc
       3 label_detail_ln_cnt = i2
       3 label_detail_ln_qual[*]
         4 label_detail_line = vc
     2 comment_cnt = i2
     2 comments_ind = c1
     2 comment_line = vc
     2 comment_qual[*]
       3 comment_text = vc
     2 prompt_cnt = i2
     2 prompt_qual[*]
       3 prompt_test = vc
       3 prompt_result = vc
 )
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 SET retrieve_allergy_info = 1
 SET retrieve_accession_info = 1
 SET retrieve_diag_info = 1
 SET retrieve_phone_addr_info = 1
 SET retrieve_ocf_results = 1
 SET retrieve_insurance_info = 1
 SET num_of_orders = 0
 SET num_of_orders = size(request->order_qual,5)
 SET stat = alterlist(orders->qual,num_of_orders)
 SET orders->allergy_cnt = 0
 SET orders->diag_cnt = 0
 SET orders->spoolout_ind = 0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 4
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_cd = code_value
 SET code_set = 43
 SET cdf_meaning = "PAGER BUS"
 EXECUTE cpm_get_cd_for_cdf
 SET pager_cd = code_value
 SET code_set = 4
 SET cdf_meaning = "SSN"
 EXECUTE cpm_get_cd_for_cdf
 SET ssn_alias_cd = code_value
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 EXECUTE cpm_get_cd_for_cdf
 SET finnbr_cd = code_value
 SET code_set = 333
 SET cdf_meaning = "  ADMITDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET admit_doc_cd = code_value
 SET attending = fillstring(25," ")
 SET code_set = 333
 SET cdf_meaning = "ATTENDDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET attend_doc_cd = code_value
 SET referring = fillstring(25," ")
 SET code_set = 333
 SET cdf_meaning = "REFERDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET referring_doc_cd = code_value
 SET code_set = 14
 SET cdf_meaning = "ORD COMMENT"
 EXECUTE cpm_get_cd_for_cdf
 SET comment_type_cd = code_value
 SET future_code = 0.0
 SET code_set = 6004
 SET cdf_meaning = "FUTURE"
 EXECUTE cpm_get_cd_for_cdf
 SET future_code = code_value
 SET complete_code = 0.0
 SET code_set = 6003
 SET cdf_meaning = "COMPLETE"
 EXECUTE cpm_get_cd_for_cdf
 SET complete_code = code_value
 SET cancel_code = 0.0
 SET code_set = 6003
 SET cdf_meaning = "CANCEL"
 EXECUTE cpm_get_cd_for_cdf
 SET cancel_code = code_value
 SET modify_code = 0.0
 SET code_set = 6003
 SET cdf_meaning = "MODIFY"
 EXECUTE cpm_get_cd_for_cdf
 SET modify_code = code_value
 SET activate_code = 0.0
 SET code_set = 6003
 SET cdf_meaning = "ACTIVATE"
 EXECUTE cpm_get_cd_for_cdf
 SET activate_code = code_value
 SET order_code = 0.0
 SET code_set = 6003
 SET cdf_meaning = "ORDER"
 EXECUTE cpm_get_cd_for_cdf
 SET order_code = code_value
 SET ics_cs_code = 0.0
 SET code_set = 73
 SET cdf_meaning = "ICS"
 EXECUTE cpm_get_cd_for_cdf
 SET ics_cs_code = code_value
 SET lang = fillstring(10," ")
 SELECT INTO "nl:"
  p.person_id, e.encntr_id, ea.enctnr_id,
  epr.encntr_id, pl.person_id, o.org_name_key,
  pa.person_id
  FROM person p,
   encounter e,
   person_alias pa,
   encntr_alias ea,
   encntr_prsnl_reltn epr,
   prsnl pl,
   organization o,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   (dummyt d4  WITH seq = 1)
  PLAN (p
   WHERE (p.person_id=request->person_id))
   JOIN (e
   WHERE (e.encntr_id=request->order_qual[1].encntr_id))
   JOIN (d1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=ssn_alias_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (d2)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=finnbr_cd
    AND ea.active_ind=1)
   JOIN (d3)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd=attend_doc_cd
    AND epr.active_ind=1
    AND epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (pl
   WHERE pl.person_id=epr.prsnl_person_id)
   JOIN (d4)
   JOIN (o
   WHERE e.organization_id=o.organization_id)
  HEAD REPORT
   orders->organization = o.org_name_key, orders->dob = format(p.birth_dt_tm,"dd/mm/yyyy;;D"), orders
   ->name = trim(p.name_full_formatted),
   lang = trim(uar_get_code_display(p.language_cd)), orders->sex = trim(uar_get_code_display(p.sex_cd
     )), orders->admit_diagnosis = trim(e.reason_for_visit),
   orders->race = trim(uar_get_code_display(p.race_cd)), orders->admit_dt_tm = format(e.reg_dt_tm,
    "dd/mm/yyyy hh:mm;;d"), orders->facility = trim(uar_get_code_display(e.loc_facility_cd)),
   orders->nurse_unit = trim(uar_get_code_display(e.loc_nurse_unit_cd)), orders->room = trim(
    uar_get_code_display(e.loc_room_cd)), orders->bed = trim(uar_get_code_display(e.loc_bed_cd)),
   orders->location = orders->nurse_unit, orders->age = trim(cnvtage(cnvtdate(p.birth_dt_tm),curdate),
    3), orders->type = trim(uar_get_code_display(e.encntr_type_cd)),
   orders->isolation = trim(uar_get_code_display(e.isolation_cd)), orders->med_service = trim(
    uar_get_code_display(e.med_service_cd)), orders->financial_class = trim(uar_get_code_display(e
     .financial_class_cd))
  HEAD epr.encntr_prsnl_r_cd
   IF (epr.encntr_prsnl_r_cd=attend_doc_cd)
    orders->attending_dr_name_last = pl.name_last, orders->attending_dr_name_first = pl.name_first
   ELSE
    referring = trim(pl.name_full_formatted)
   ENDIF
  DETAIL
   IF (pa.person_alias_type_cd=ssn_alias_cd)
    IF (pa.alias_pool_cd > 0)
     orders->ssn = cnvtalias(pa.alias,pa.alias_pool_cd)
    ELSE
     orders->ssn = pa.alias
    ENDIF
   ENDIF
   IF (ea.encntr_alias_type_cd=finnbr_cd)
    IF (ea.alias_pool_cd > 0)
     orders->fnbr = cnvtalias(ea.alias,ea.alias_pool_cd)
    ELSE
     orders->fnbr = ea.alias
    ENDIF
   ENDIF
  WITH outerjoin = d1, dontcare = pa, outerjoin = d2,
   dontcare = ea, outerjoin = d3, nocounter,
   outerjoin = d4
 ;end select
 SELECT INTO "nl:"
  mrn_disp = cnvtalias(pa.alias,pa.alias_pool_cd)
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
   WHERE pa.person_id=outerjoin(request->person_id)
    AND pa.alias_pool_cd=outerjoin(oapr.alias_pool_cd)
    AND pa.person_alias_type_cd=outerjoin(mrn_alias_cd)
    AND pa.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND pa.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
    AND pa.active_ind=outerjoin(1))
  DETAIL
   orders->mrn = mrn_disp, orders->mrnbc = concat("*",orders->mrn,"*")
  WITH ncounter, skipreport = 0
 ;end select
 IF (retrieve_allergy_info=1)
  SET code_set = 12025
  SET cdf_meaning = "ACTIVE"
  EXECUTE cpm_get_cd_for_cdf
  SET active_status_cd = code_value
  SELECT INTO "NL:"
   a.allergy_id, a.allergy_instance_id, n.nomenclature_id
   FROM allergy a,
    nomenclature n
   PLAN (a
    WHERE (a.person_id=request->person_id)
     AND a.active_ind=1
     AND a.reaction_status_cd=active_status_cd)
    JOIN (n
    WHERE n.nomenclature_id=a.substance_nom_id)
   ORDER BY a.allergy_instance_id
   HEAD a.allergy_instance_id
    orders->allergy_cnt = (orders->allergy_cnt+ 1)
    IF ((orders->allergy_cnt > size(orders->aqual,5)))
     stat = alterlist(orders->aqual,(orders->allergy_cnt+ 5))
    ENDIF
    orders->aqual[orders->allergy_cnt].allergy_display = a.substance_ftdesc
    IF (n.source_string > " ")
     orders->aqual[orders->allergy_cnt].allergy_display = n.source_string
    ENDIF
   FOOT REPORT
    stat = alterlist(orders->aqual[orders->allergy_cnt],orders->allergy_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (retrieve_diag_info=1)
  SELECT INTO "NL:"
   d.diagnosis_id, n.nomenclature_id
   FROM diagnosis d,
    nomenclature n
   PLAN (d
    WHERE (d.encntr_id=request->order_qual[1].encntr_id))
    JOIN (n
    WHERE n.nomenclature_id=d.nomenclature_id)
   DETAIL
    orders->diag_cnt = (orders->diag_cnt+ 1)
    IF ((orders->diag_cnt > size(orders->dqual,5)))
     stat = alterlist(orders->dqual,(orders->diag_cnt+ 5))
    ENDIF
    orders->dqual[orders->diag_cnt].diag_display = d.diag_ftdesc
    IF (n.source_string > " ")
     orders->dqual[orders->diag_cnt].diag_display = n.source_string
    ENDIF
   FOOT REPORT
    stat = alterlist(orders->dqual[orders->diag_cnt],orders->diag_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (retrieve_phone_addr_info=1)
  SET code_set = 212
  SET cdf_meaning = "HOME"
  EXECUTE cpm_get_cd_for_cdf
  SET home_address_cd = code_value
  SELECT INTO "nl:"
   p.person_id, a.address_id
   FROM person p,
    (dummyt d1  WITH seq = 1),
    address a
   PLAN (p
    WHERE (p.person_id=request->person_id))
    JOIN (d1)
    JOIN (a
    WHERE a.parent_entity_id=p.person_id
     AND a.parent_entity_name="PERSON"
     AND a.address_type_cd=home_address_cd
     AND a.active_ind=1
     AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   DETAIL
    orders->street = trim(a.street_addr), orders->city_state_zip = concat(trim(a.city)," ",trim(a
      .state),"  ",trim(a.zipcode))
   WITH nocounter, outerjoin = d1, dontcare = a
  ;end select
 ENDIF
 IF (retrieve_ocf_results=1)
  SET pt_weight = fillstring(25," ")
  SET pt_height = fillstring(25," ")
  SET pt_transport_mode = fillstring(25," ")
  SET pt_precautions = fillstring(100," ")
  SET pt_allergies = fillstring(100," ")
  FREE SET clinattr
  RECORD clinattr(
    1 allergy_cnt = i2
    1 aqual[*]
      2 allergy_display = vc
    1 prec_cnt = i2
    1 pqual[*]
      2 prec_display = vc
  )
  SET clinattr->allergy_cnt = 0
  SET clinattr->prec_cnt = 0
  SELECT INTO "nl"
   c.clinical_event_id, c.event_cd, c.event_end_dt_tm
   FROM clinical_event c
   PLAN (c
    WHERE (c.person_id=request->person_id)
     AND (c.encntr_id=request->order_qual[1].encntr_id)
     AND c.view_level=1
     AND c.publish_flag=1
     AND c.event_cd IN (26821, 28735)
     AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
   ORDER BY c.event_cd, c.event_end_dt_tm DESC
   HEAD REPORT
    hght_ind = 0, wght_ind = 0, trm_ind = 0
   HEAD c.event_cd
    all_ind = 0, all_last_ind = 0, prec_ind = 0,
    prec_last_ind = 0
    IF (c.event_cd=26821
     AND hght_ind=0)
     pt_height = concat(trim(c.event_tag)," in"), hght_ind = 1
    ELSEIF (c.event_cd=28735
     AND wght_ind=0)
     pt_weight = concat(trim(c.event_tag)," lb"), wght_ind = 1
    ENDIF
   HEAD c.event_end_dt_tm
    IF (all_ind=1)
     all_last_ind = 1
    ENDIF
    IF (prec_ind=1)
     prec_last_ind = 1
    ENDIF
   DETAIL
    IF (c.event_cd IN (62610, 62611, 62589, 62612))
     IF (all_last_ind=0)
      clinattr->allergy_cnt = (clinattr->allergy_cnt+ 1), stat = alterlist(clinattr->aqual,clinattr->
       allergy_cnt), clinattr->aqual[clinattr->allergy_cnt].allergy_display = trim(c.event_tag),
      all_ind = 1
     ENDIF
    ELSEIF (c.event_cd IN (34503, 34506))
     IF (prec_last_ind=0)
      clinattr->prec_cnt = (clinattr->prec_cnt+ 1), stat = alterlist(clinattr->pqual,clinattr->
       prec_cnt), clinattr->pqual[clinattr->prec_cnt].prec_display = trim(c.event_tag),
      prec_ind = 1
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (retrieve_insurance_info=1)
  SELECT INTO "nl:"
   epr.encntr_id, hp.health_plan_id, o.organization_id
   FROM encntr_plan_reltn epr,
    health_plan hp,
    organization o
   PLAN (epr
    WHERE (epr.encntr_id=request->order_qual[1].encntr_id)
     AND epr.priority_seq IN (1, 2, 99))
    JOIN (hp
    WHERE hp.health_plan_id=epr.health_plan_id
     AND hp.active_ind=1)
    JOIN (o
    WHERE o.organization_id=epr.organization_id)
   DETAIL
    IF (((epr.priority_seq=1) OR (epr.priority_seq=99)) )
     orders->pri_insur = trim(o.org_name), orders->pri_pol_nbr = trim(epr.member_nbr), orders->
     pri_grp_nbr = trim(hp.group_nbr)
    ENDIF
    IF (epr.priority_seq=2)
     orders->sec_insur = trim(o.org_name), orders->sec_pol_nbr = trim(epr.member_nbr), orders->
     sec_grp_nbr = trim(hp.group_nbr)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET dept = fillstring(15," ")
 SET last_atc = fillstring(20," ")
 SET signed = fillstring(20," ")
 SET ord_pager = fillstring(15," ")
 SET temp = fillstring(100," ")
 SET num_cs = 0
 SET parent_idx = 0
 SET space = fillstring(2," ")
 SET accession_number = fillstring(20," ")
 SELECT INTO "nl:"
  o.order_id, oa.order_id, p.person_id,
  p2.person_id, o.current_start_dt_tm, ocs.catalog_cd,
  cva.alias, oc.activity_subtype_cd
  FROM orders o,
   order_action oa,
   prsnl p,
   prsnl p2,
   order_catalog_synonym ocs,
   (dummyt d1  WITH seq = value(num_of_orders)),
   dummyt d4,
   code_value_alias cva,
   dummyt d5,
   order_catalog oc,
   dummyt d6
  PLAN (d1)
   JOIN (o
   WHERE (o.order_id=request->order_qual[d1.seq].order_id))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=o.last_action_sequence)
   JOIN (p
   WHERE oa.action_personnel_id=p.person_id)
   JOIN (p2
   WHERE oa.order_provider_id=p2.person_id)
   JOIN (d4)
   JOIN (ocs
   WHERE ocs.catalog_cd=o.catalog_cd
    AND ocs.hide_flag=1
    AND o.cs_flag IN (8, 0))
   JOIN (d5)
   JOIN (oc
   WHERE o.catalog_cd=oc.catalog_cd)
   JOIN (d6)
   JOIN (cva
   WHERE oc.catalog_cd=cva.code_value
    AND cva.code_set=200
    AND cva.contributor_source_cd=ics_cs_code)
  ORDER BY o.activity_type_cd, oc.activity_subtype_cd, o.current_start_dt_tm
  HEAD REPORT
   orders->order_location = trim(uar_get_code_display(oa.order_locn_cd))
  HEAD o.order_id
   orders->qual[d1.seq].event_cds = fillstring(50," ")
   IF (o.cs_flag != 8)
    parent_idx = d1.seq, temp = fillstring(100," ")
   ENDIF
   signed = format(o.orig_order_dt_tm,"mm/dd/yyyy  hh:mm;;d"), dept = uar_get_code_display(o
    .catalog_type_cd), orders->qual[d1.seq].order_id = o.order_id,
   orders->qual[d1.seq].order_mnemonic = o.hna_order_mnemonic, orders->qual[d1.seq].
   order_mnemonic_alias = cva.alias, orders->qual[d1.seq].oe_format_id = o.oe_format_id,
   orders->qual[d1.seq].template_order_flag = o.template_order_flag, orders->qual[d1.seq].
   current_start_dt_tm = o.current_start_dt_tm, orders->qual[d1.seq].action_type_cd = oa
   .action_type_cd,
   orders->qual[d1.seq].activity_type_cd = o.activity_type_cd, orders->qual[d1.seq].activity_type =
   uar_get_code_display(o.activity_type_cd), orders->qual[d1.seq].activity_subtype =
   uar_get_code_display(oc.activity_subtype_cd),
   orders->qual[d1.seq].action_meaning = trim(uar_get_code_meaning(oa.action_type_cd)), temp_action
    = trim(uar_get_code_meaning(oa.action_type_cd))
   IF (temp_action="ORDER")
    orders->qual[d1.seq].special_action_ind = 0
   ELSE
    orders->qual[d1.seq].special_action_ind = 1
   ENDIF
   orders->qual[d1.seq].action = trim(uar_get_code_display(oa.action_type_cd)), orders->qual[d1.seq].
   catalog_type = trim(uar_get_code_display(o.catalog_type_cd)), orders->qual[d1.seq].catalog_cd = o
   .catalog_cd,
   orders->qual[d1.seq].catalog_type_cd = o.catalog_type_cd, orders->qual[d1.seq].
   action_prsnl_name_last = trim(p.name_last), orders->qual[d1.seq].action_prsnl_name_first = trim(p
    .name_first),
   orders->qual[d1.seq].action_dt_tm = oa.action_dt_tm, orders->qual[d1.seq].action_sequence = oa
   .action_sequence, orders->qual[d1.seq].order_provider_name = trim(p2.name_full_formatted),
   orders->qual[d1.seq].order_provider_id = oa.order_provider_id, comment_cnt = 0
   IF (o.order_comment_ind=1)
    orders->qual[d1.seq].comments_ind = "T"
   ELSE
    orders->qual[d1.seq].comments_ind = "F"
   ENDIF
   IF (oa.action_type_cd IN (order_code, activate_code, modify_code)
    AND o.order_status_cd != future_code)
    orders->qual[d1.seq].display_ind = 1, orders->spoolout_ind = 1
   ELSE
    orders->qual[d1.seq].display_ind = 0
   ENDIF
  HEAD ocs.synonym_id
   orders->qual[parent_idx].event_cds = concat(trim(temp)," ",trim(ocs.mnemonic)), temp = orders->
   qual[parent_idx].event_cds
  WITH nocounter, outerjoin = d4, dontcare = d4,
   dontcare = cc, dontcare = ocs
 ;end select
 SET cd = 0
 SET start = fillstring(15," ")
 SET specstart = fillstring(15," ")
 SET source = fillstring(15," ")
 SET coll_pri = fillstring(15," ")
 SET label_comm = fillstring(70," ")
 SELECT INTO "nl:"
  od.order_id, oef.oe_field_id, od.action_sequence,
  oefs.description
  FROM order_detail od,
   oe_format_fields oef,
   (dummyt d1  WITH seq = value(num_of_orders)),
   order_entry_fields oefs
  PLAN (d1)
   JOIN (od
   WHERE (orders->qual[d1.seq].order_id=od.order_id))
   JOIN (oef
   WHERE (oef.oe_format_id=orders->qual[d1.seq].oe_format_id)
    AND oef.oe_field_id=od.oe_field_id
    AND oef.action_type_cd=order_code
    AND oef.accept_flag IN (0, 1))
   JOIN (oefs
   WHERE oefs.oe_field_id=od.oe_field_id)
  ORDER BY od.order_id, oef.group_seq, od.action_sequence DESC
  HEAD REPORT
   orders->qual[d1.seq].detail_cnt = 0
  HEAD od.order_id
   stat = alterlist(orders->qual[d1.seq].detail_qual,5), orders->qual[d1.seq].stat_ind = 0
  HEAD od.oe_field_id
   act_seq = od.action_sequence, odflag = 1
   IF (((od.oe_field_meaning="COLLPRI                 ") OR (od.oe_field_meaning=
   "PRIORITY                ")) )
    coll_pri = substring(1,12,od.oe_field_display_value)
   ENDIF
   IF (od.oe_field_meaning="REQSTARTDTTM            ")
    start = format(od.oe_field_dt_tm_value,"DD/MM/YY  HH:MM;;D")
   ENDIF
   IF (od.oe_field_meaning="SPECRECDDATETIME        ")
    specstart = format(od.oe_field_dt_tm_value,"DD/MM/YY  HH:MM;;D")
   ENDIF
   IF (od.oe_field_meaning="LBLCMNT                 ")
    label_comm = substring(1,70,od.oe_field_display_value)
   ENDIF
   IF (od.oe_field_meaning="SOURCE                  ")
    source = substring(1,70,od.oe_field_display_value)
   ENDIF
  HEAD od.action_sequence
   IF (act_seq != od.action_sequence)
    odflag = 0
   ENDIF
  DETAIL
   IF (odflag=1)
    orders->qual[d1.seq].detail_cnt = (orders->qual[d1.seq].detail_cnt+ 1), dc = orders->qual[d1.seq]
    .detail_cnt
    IF (dc > size(orders->qual[d1.seq].detail_qual,5))
     stat = alterlist(orders->qual[d1.seq].detail_qual,(dc+ 5))
    ENDIF
    orders->qual[d1.seq].detail_qual[dc].field_description = trim(oefs.description), orders->qual[d1
    .seq].detail_qual[dc].label_text = trim(oef.label_text), orders->qual[d1.seq].detail_qual[dc].
    field_value = od.oe_field_value,
    orders->qual[d1.seq].detail_qual[dc].field_id = od.oe_field_id, orders->qual[d1.seq].detail_qual[
    dc].print_ind = 0, orders->qual[d1.seq].detail_qual[dc].group_seq = oef.group_seq,
    orders->qual[d1.seq].detail_qual[dc].oe_field_meaning_id = od.oe_field_meaning_id
    IF (od.oe_field_meaning="REQSTARTDTTM            ")
     orders->qual[d1.seq].detail_qual[dc].display_value = start
    ELSEIF (od.oe_field_meaning="SPECRECDDATETIME        ")
     orders->qual[d1.seq].detail_qual[dc].display_value = specstart
    ELSE
     orders->qual[d1.seq].detail_qual[dc].display_value = trim(od.oe_field_display_value)
    ENDIF
    IF (((od.oe_field_meaning_id=1100) OR (((od.oe_field_meaning_id=8) OR (((od.oe_field_meaning_id=
    127) OR (od.oe_field_meaning_id=43)) )) ))
     AND trim(cnvtupper(od.oe_field_display_value))="STAT")
     orders->qual[d1.seq].stat_ind = 1
    ENDIF
   ENDIF
  FOOT  od.order_id
   stat = alterlist(orders->qual[d1.seq].detail_qual,dc)
  WITH nocounter
 ;end select
 IF (textlen(orders->attending_dr_name_last) > 0)
  SET field_size_in_inch = 2.25
  SET stat = simlabformatname(nullterm(orders->attending_dr_name_last),nullterm(orders->
    attending_dr_name_first),"",3,0,
   ", ","",chars_per_inch,field_size_in_inch)
  SET orders->attending_dr = concat(stemplastname,stempfirstmidname)
 ENDIF
 FOR (x = 1 TO num_of_orders)
  IF (textlen(orders->qual[x].action_prsnl_name_last) > 0)
   SET field_size_in_inch = 2.25
   SET stat = simlabformatname(nullterm(orders->qual[x].action_prsnl_name_last),nullterm(orders->
     qual[x].action_prsnl_name_first),"",3,0,
    ", ","",chars_per_inch,field_size_in_inch)
   SET orders->qual[x].action_prsnl_name = concat(stemplastname,stempfirstmidname)
  ENDIF
  FOR (xx = 1 TO orders->qual[x].detail_cnt)
   IF (textlen(orders->qual[x].detail_qual[xx].label_text) > 0)
    SET field_size_in_inch = 2.0
    SET stat = wordwrapbyfont(nullterm(orders->qual[x].detail_qual[xx].label_text),chars_per_inch,
     field_size_in_inch,0,"times")
    SET orders->qual[x].detail_qual[xx].label_detail_ln_cnt = simlabwrappedtext->output_string_cnt
    SET stat = alterlist(orders->qual[x].detail_qual[xx].label_detail_ln_qual,simlabwrappedtext->
     output_string_cnt)
    FOR (y = 1 TO simlabwrappedtext->output_string_cnt)
      SET orders->qual[x].detail_qual[xx].label_detail_ln_qual[y].label_detail_line =
      simlabwrappedtext->output_string[y].string
    ENDFOR
   ENDIF
   IF (textlen(orders->qual[x].detail_qual[xx].display_value) > 0)
    SET field_size_in_inch = 4.0
    SET stat = wordwrapbyfont(nullterm(orders->qual[x].detail_qual[xx].display_value),chars_per_inch,
     field_size_in_inch,0,"times")
    SET orders->qual[x].detail_qual[xx].detail_ln_cnt = simlabwrappedtext->output_string_cnt
    SET stat = alterlist(orders->qual[x].detail_qual[xx].detail_ln_qual,simlabwrappedtext->
     output_string_cnt)
    FOR (y = 1 TO simlabwrappedtext->output_string_cnt)
      SET orders->qual[x].detail_qual[xx].detail_ln_qual[y].detail_line = simlabwrappedtext->
      output_string[y].string
    ENDFOR
   ENDIF
  ENDFOR
 ENDFOR
 SET num_of_orders = size(orders->qual,5)
 IF (retrieve_accession_info=1)
  FOR (hold_pause = 1 TO 4)
   FOR (acc = 1 TO value(num_of_orders))
     IF ((orders->qual[acc].accession > " "))
      SET abcd = " "
     ELSE
      SET pause_ind = 1
      SET acc = 99
     ENDIF
   ENDFOR
   IF (pause_ind=1)
    CALL pause(5)
    SELECT INTO "NL:"
     aor.order_id, aor.accession
     FROM accession_order_r aor,
      (dummyt d1  WITH seq = value(num_of_orders))
     PLAN (d1)
      JOIN (aor
      WHERE (aor.order_id=request->order_qual[d1.seq].order_id))
     ORDER BY aor.accession
     DETAIL
      IF (substring(6,1,aor.accession) != "2")
       orders->qual[d1.seq].accession = concat("*",substring(4,2,aor.accession),substring(6,2,aor
         .accession),substring(10,2,aor.accession),substring(13,6,aor.accession),
        "*")
      ELSE
       orders->qual[d1.seq].accession = concat("*",substring(4,2,aor.accession),substring(8,5,aor
         .accession),substring(13,6,aor.accession),"*")
      ENDIF
      orders->qual[d1.seq].accession1 = uar_fmt_accession(aor.accession,size(aor.accession,1))
     WITH nocounter
    ;end select
    SET pause_ind = 0
   ELSE
    SET hold_pause = 99
   ENDIF
  ENDFOR
 ENDIF
 SELECT INTO "nl:"
  pr.order_id
  FROM prop_result pr,
   (dummyt d1  WITH seq = value(num_of_orders))
  PLAN (d1)
   JOIN (pr
   WHERE (pr.order_id=request->order_qual[d1.seq].order_id))
  ORDER BY pr.order_id, pr.task_assay_cd
  HEAD REPORT
   orders->qual[d1.seq].prompt_cnt = 0
  HEAD pr.order_id
   stat = alterlist(orders->qual[d1.seq].prompt_qual,5)
  DETAIL
   orders->qual[d1.seq].prompt_cnt = (orders->qual[d1.seq].prompt_cnt+ 1), pc = orders->qual[d1.seq].
   prompt_cnt, orders->qual[d1.seq].prompt_qual[pc].prompt_test = uar_get_code_display(pr
    .task_assay_cd),
   orders->qual[d1.seq].prompt_qual[pc].prompt_result = pr.result_display_value
  FOOT  pr.order_id
   stat = alterlist(orders->qual[d1.seq].prompt_qual,pc)
  WITH nocounter
 ;end select
 SET b_linefeed = concat(char(10))
 SET row_cnt = 0
 FOR (cqual = 1 TO value(num_of_orders))
   IF ((orders->qual[cqual].comments_ind="T"))
    SELECT INTO "nl:"
     lt.long_text
     FROM long_text lt,
      order_comment oc
     PLAN (oc
      WHERE (oc.order_id=orders->qual[cqual].order_id))
      JOIN (lt
      WHERE lt.long_text_id=oc.long_text_id)
     DETAIL
      orders->qual[cqual].comment_line = lt.long_text
     WITH nocounter
    ;end select
    IF (textlen(orders->qual[cqual].comment_line) > 0)
     SET field_size_in_inch = 6.5
     SET stat = wordwrapbyfont(nullterm(orders->qual[cqual].comment_line),chars_per_inch,
      field_size_in_inch,0,"times")
     SET orders->qual[cqual].comment_cnt = simlabwrappedtext->output_string_cnt
     SET stat = alterlist(orders->qual[cqual].comment_qual,simlabwrappedtext->output_string_cnt)
     FOR (y = 1 TO simlabwrappedtext->output_string_cnt)
       SET orders->qual[cqual].comment_qual[y].comment_text = simlabwrappedtext->output_string[y].
       string
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
 IF ((orders->spoolout_ind=1))
  SET new_timedisp = cnvtstring(curtime3)
  SET tempfile1a = build(concat("dcpreq","_",new_timedisp),".dat")
  SET ord_dr = fillstring(50," ")
  SET spaces = fillstring(50," ")
  SET temp = fillstring(50," ")
  SET transport = fillstring(25," ")
  SET beeper = fillstring(10," ")
  SET pri = fillstring(15," ")
  SET reason = fillstring(50," ")
  SET sec_reason = fillstring(50," ")
  SET req_dt_tm = fillstring(20," ")
  SET spaces = fillstring(80," ")
  SET temp = fillstring(50," ")
  SET cnt = 0
  SET first_details = "Y"
  SET first = "Y"
  SELECT INTO value(tempfile1a)
   d1.seq, act = orders->qual[d1.seq].activity_type, subact = orders->qual[d1.seq].activity_subtype,
   ordid = orders->qual[d1.seq].order_id
   FROM (dummyt d1  WITH seq = value(num_of_orders))
   PLAN (d1)
   ORDER BY act, subact, ordid
   HEAD REPORT
    bc_dio = "{LPI/24}{CPI/8}{BCR/250}{FONT/28/7}", reg_dio = "{LPI/8}{CPI/12}{FONT/8}", reg2_dio =
    "{LPI/6}{CPI/12}{COLOR/0}{FONT/0}",
    reg3_dio = "{LPI/8}{CPI/12}{FONT/4}", first_page = "Y", line1 = fillstring(20,"_"),
    line2 = fillstring(9,"_"), line3 = fillstring(12,"_"), line4 = fillstring(50,"_"),
    line5 = fillstring(40,"_"), line6 = fillstring(88,"_"), line7 = fillstring(30,"_"),
    line8 = fillstring(22,"_"), line9 = fillstring(15,"_"), line10 = fillstring(45,"_")
   HEAD PAGE
    row + 1, reg3_dio, row + 1,
    "{pos/90/20}{cpi/12}", "Page ", curpage"###;L",
    row + 1, "{pos/385/20}{cpi/12}", "Lab Number:  ",
    orders->qual[d1.seq].accession1, row + 1, "{pos/385/35}{cpi/8}{f/9}",
    orders->facility, row + 1, "{pos/250/70}{cpi/8}{f/9}",
    "{BOLD}", "Requisition Form", "{ENDB}{cpi/12}{f/4}",
    row + 1, "{pos/450/90}{cpi/14}{f/7}", "Printed: ",
    curdate"dd/mm/yyyy;;dd", space, curtime"hh:mm;;m",
    row + 1, reg3_dio, row + 1,
    "{pos/90/140}{f/4}Patient Name: ", "{B}",
    CALL print(trim(orders->name,3)),
    "{ENDB}", row + 1, "{pos/450/140}",
    "{lpi/6}{cpi/6}{bcr/250}{font/28/2}", orders->mrnbc, row + 1,
    reg3_dio, row + 1, "{pos/450/170}MRN: ",
    orders->mrn, row + 1, "{pos/90/170}{cpi/12}{f/4}DOB: ",
    orders->dob, row + 1, "{pos/90/190}Sex: ",
    orders->sex, row + 1, "{lpi/8}{cpi/12}{f/4}",
    "{pos/90/210}NHS Number: ", "{B}", orders->ssn"###-###-####",
    "{ENDB}{cpi/12}{f/4}", row + 1, "{pos/90/230}Patient type: ",
    "{B}", orders->type, "{ENDB}",
    row + 1, "{pos/90/240}Address: ", orders->street,
    row + 1, "{pos/90/250}", orders->city_state_zip,
    row + 1, "{lpi/8}{cpi/12}{f/4}", row + 1,
    "{pos/375/210}Location: ", "{B}", orders->location,
    "{ENDB}", "{cpi/12}{f/4}", row + 1,
    "{pos/375/230}Consultant: ", orders->attending_dr, row + 1,
    "{pos/90/275}Phone Number: ", orders->hphone, row + 1,
    "{cpi/3}{pos/90/280}", line4, line1,
    line3, "_", row + 1,
    reg3_dio, xcol = 90, ycol = 300
   DETAIL
    IF ((orders->qual[d1.seq].display_ind=1))
     ord_dr = orders->qual[d1.seq].order_provider_name
     IF (first="Y")
      first = "N", accession_number = orders->qual[d1.seq].accession
     ENDIF
     IF ((accession_number != orders->qual[d1.seq].accession))
      BREAK, first_details = "Y"
     ENDIF
     accession_number = orders->qual[d1.seq].accession, row + 1, "{cpi/12}{f/4}",
     row + 1, "{pos/375/220}", "Ordered by: ",
     orders->qual[d1.seq].action_prsnl_name, row + 1, "{pos/1/120}{cpi/8}{f/5}",
     row + 1, reg3_dio, xcol = 90,
     row + 1,
     CALL print(calcpos(xcol,ycol)), "{B}",
     "Requested test/s: ", orders->qual[d1.seq].order_mnemonic, "{ENDB}",
     "{cpi/12}{f/4}", ycol = (ycol+ 10), row + 1,
     CALL print(calcpos(xcol,ycol)), "{B}", "Order Comments: ",
     "{ENDB}", "{cpi/12}{f/4}", "{lpi/8}{cpi/12}{f/4}",
     row + 1, "{pos/415/610}", "{lpi/4}{cpi/8}{bcr/250}{font/28/2}",
     orders->qual[d1.seq].accession, row + 1, "{lpi/8}{cpi/12}{f/4}",
     row + 1, "{pos/415/645}", "Lab Number:  ",
     orders->qual[d1.seq].accession1
     FOR (zz = 1 TO orders->qual[d1.seq].comment_cnt)
       xcol = 90, ycol = (ycol+ 10),
       CALL print(calcpos(xcol,ycol)),
       CALL print(orders->qual[d1.seq].comment_qual[zz].comment_text), row + 1
     ENDFOR
     ycol = (ycol+ 20)
     FOR (pp = 1 TO orders->qual[d1.seq].prompt_cnt)
       xcol = 90,
       CALL print(calcpos(xcol,ycol)),
       CALL print(orders->qual[d1.seq].prompt_qual[pp].prompt_test),
       ": ",
       CALL print(orders->qual[d1.seq].prompt_qual[pp].prompt_result), ycol = (ycol+ 10)
     ENDFOR
     xcol = 90, ymove = 10
     FOR (ww = 1 TO orders->qual[d1.seq].detail_cnt)
       IF ( NOT ((orders->qual[d1.seq].detail_qual[ww].label_text IN ("Print Label",
       "Specimen Received*"))))
        IF ((orders->qual[d1.seq].detail_qual[ww].label_detail_ln_cnt > orders->qual[d1.seq].
        detail_qual[ww].detail_ln_cnt))
         ycol1 = (ycol+ (ymove * orders->qual[d1.seq].detail_qual[ww].label_detail_ln_cnt))
        ELSE
         ycol1 = (ycol+ (ymove * orders->qual[d1.seq].detail_qual[ww].detail_ln_cnt))
        ENDIF
        IF (ycol1 > 630)
         BREAK, row + 1, "{pos/375/220}",
         "Ordered by: ", orders->qual[d1.seq].action_prsnl_name, row + 1,
         reg3_dio
        ENDIF
        xcol = 90
        FOR (z = 1 TO orders->qual[d1.seq].detail_qual[ww].label_detail_ln_cnt)
          ycol1 = (ycol+ (ymove * z)),
          CALL print(calcpos(xcol,ycol1)),
          CALL print(orders->qual[d1.seq].detail_qual[ww].label_detail_ln_qual[z].label_detail_line)
          IF ((z=orders->qual[d1.seq].detail_qual[ww].label_detail_ln_cnt))
           CALL print(":")
          ENDIF
          row + 1
        ENDFOR
        xcol = 245
        FOR (z = 1 TO orders->qual[d1.seq].detail_qual[ww].detail_ln_cnt)
          ycol1 = (ycol+ (ymove * z)),
          CALL print(calcpos(xcol,ycol1)),
          CALL print(orders->qual[d1.seq].detail_qual[ww].detail_ln_qual[z].detail_line),
          row + 1
        ENDFOR
        IF ((orders->qual[d1.seq].detail_qual[ww].label_detail_ln_cnt > orders->qual[d1.seq].
        detail_qual[ww].detail_ln_cnt))
         ycol = (ycol+ (ymove * orders->qual[d1.seq].detail_qual[ww].label_detail_ln_cnt))
        ELSE
         ycol = (ycol+ (ymove * orders->qual[d1.seq].detail_qual[ww].detail_ln_cnt))
        ENDIF
        ycol = (ycol+ ymove), row + 1
       ENDIF
     ENDFOR
     xcol = 210, ycol = (ycol+ 8)
     IF (ycol > 630)
      BREAK, row + 1, "{pos/375/220}",
      "Ordered by: ", orders->qual[d1.seq].action_prsnl_name, row + 1,
      reg3_dio
     ENDIF
    ENDIF
   FOOT PAGE
    row + 1, "{cpi/3}{pos/90/650}", line4,
    line1, line3, "_",
    row + 1, reg3_dio, row + 1,
    "{pos/415/680}", "Print Name: ", "{pos/465/680}",
    line1, row + 1, "{pos/90/680}",
    "Blood Transfusion Specific Section ", row + 1, "{pos/250/680}",
    "Patient identified and Bled by ", row + 1, "{pos/422/700}",
    "Signature: ", "{pos/465/700}", line1,
    row + 1, "{pos/397/720}", "Collection Date: ",
    "{pos/465/720}", line1, row + 1,
    "{pos/397/740}", "Collection Time: ", "{pos/465/740}",
    line1
   WITH nocounter, dio = 08, maxcol = 800,
    maxrow = 750
  ;end select
  SET spool value(trim(tempfile1a)) value(request->printer_name) WITH deleted
 ENDIF
END GO
