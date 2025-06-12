CREATE PROGRAM ccl_rptapi_graph
 DECLARE getdefaultcolor(nindex=i4) = i4
 DECLARE getformattednumber(fnumber=f8,sformat=vc) = vc
 DECLARE drawlegendcolorbox(ngraphtype=i2,boxleft=f8,boxtop=f8,boxwidth=f8,boxheight=f8,
  nscnt=i4) = null
 DECLARE calcstepsize(datarange=f8,targetsteps=f8) = f8
 DECLARE mymod(x=f8,y=f8) = f8
 DECLARE ngraphtype = i4 WITH noconstant(2), private
 DECLARE fleft = f8 WITH noconstant(0.0), private
 DECLARE ftop = f8 WITH noconstant(0.0), private
 DECLARE fright = f8 WITH noconstant(0.0), private
 DECLARE fbottom = f8 WITH noconstant(0.0), private
 DECLARE fwidth = f8 WITH noconstant(0.0), private
 DECLARE fheight = f8 WITH noconstant(0.0), private
 DECLARE _fntrestore = i4 WITH noconstant(0), private
 DECLARE _fntdefault = i4 WITH noconstant(0), private
 DECLARE _fnttitle = i4 WITH noconstant(0), private
 DECLARE _fntsubtitle = i4 WITH noconstant(0), private
 DECLARE _fntxtitle = i4 WITH noconstant(0), private
 DECLARE _fntytitle = i4 WITH noconstant(0), private
 DECLARE _fntytitle2 = i4 WITH noconstant(0), private
 DECLARE _fntlegend = i4 WITH noconstant(0), private
 DECLARE _fntxgrid = i4 WITH noconstant(0), private
 DECLARE _fntygrid = i4 WITH noconstant(0), private
 DECLARE _penrestore = i4 WITH noconstant(0), private
 DECLARE ftitleheight = f8 WITH noconstant(0.0), private
 DECLARE fsubtitleheight = f8 WITH noconstant(0.0), private
 DECLARE fxtitleheight = f8 WITH noconstant(0.0), private
 DECLARE fytitleheight = f8 WITH noconstant(0.0), private
 DECLARE fytitleheight2 = f8 WITH noconstant(0.0), private
 DECLARE sxformat = vc WITH noconstant(""), private
 DECLARE syformat = vc WITH noconstant(""), private
 DECLARE fxindex = f8 WITH noconstant(0.0), private
 DECLARE fyindex = f8 WITH noconstant(0.0), private
 DECLARE fyindex2 = f8 WITH noconstant(0.0), private
 DECLARE nxnum = i4 WITH noconstant(0), private
 DECLARE nynum = i4 WITH noconstant(0), private
 DECLARE nynum2 = i4 WITH noconstant(0), private
 DECLARE fxmin = f8 WITH noconstant(0.0), private
 DECLARE fymin = f8 WITH noconstant(0.0), private
 DECLARE fxmax = f8 WITH noconstant(0.0), private
 DECLARE fymax = f8 WITH noconstant(0.0), private
 DECLARE fxincr = f8 WITH noconstant(0.0), private
 DECLARE fyincr = f8 WITH noconstant(0.0), private
 DECLARE fyincr2 = f8 WITH noconstant(0.0), private
 DECLARE fxpos = f8 WITH noconstant(0.0), private
 DECLARE fypos = f8 WITH noconstant(0.0), private
 DECLARE nfcnt = i4 WITH noconstant(0), private
 DECLARE nscnt = i4 WITH noconstant(0), private
 DECLARE nmaxfields = i4 WITH noconstant(0), private
 DECLARE nmaxseries = i4 WITH noconstant(0), private
 DECLARE xb = f8 WITH noconstant(0.0), private
 DECLARE yb = f8 WITH noconstant(0.0), private
 DECLARE xm = f8 WITH noconstant(0.0), private
 DECLARE ym = f8 WITH noconstant(0.0), private
 DECLARE flgrid = f8 WITH noconstant(0.0), private
 DECLARE ftgrid = f8 WITH noconstant(0.0), private
 DECLARE frgrid = f8 WITH noconstant(0.0), private
 DECLARE fbgrid = f8 WITH noconstant(0.0), private
 DECLARE fwgrid = f8 WITH noconstant(0.0), private
 DECLARE yhgrid = f8 WITH noconstant(0.0), private
 DECLARE nhold = i4 WITH noconstant(0), private
 DECLARE nsize = i4 WITH noconstant(0), private
 DECLARE flmargin = f8 WITH noconstant(0.0), private
 DECLARE ftmargin = f8 WITH noconstant(0.0), private
 DECLARE frmargin = f8 WITH noconstant(0.0), private
 DECLARE fbmargin = f8 WITH noconstant(0.0), private
 DECLARE fllegend = f8 WITH noconstant(0.0), private
 DECLARE ftlegend = f8 WITH noconstant(0.0), private
 DECLARE fwlegend = f8 WITH noconstant(0.0), private
 DECLARE fhlegend = f8 WITH noconstant(0.0), private
 DECLARE fwlgndbox = f8 WITH noconstant(0.0), private
 DECLARE fhlgndbox = f8 WITH noconstant(0.0), private
 DECLARE fllgndboxarea = f8 WITH noconstant(0.0), private
 DECLARE fwlgndboxarea = f8 WITH noconstant(0.0), private
 DECLARE fpietotal = f8 WITH noconstant(0.0), private
 DECLARE fpiepct = f8 WITH noconstant(0.0), private
 DECLARE fpierad = f8 WITH noconstant(0.0), private
 DECLARE fxrad = f8 WITH noconstant(0.0), private
 DECLARE fyrad = f8 WITH noconstant(0.0), private
 DECLARE fxcenter = f8 WITH noconstant(0.0), private
 DECLARE fycenter = f8 WITH noconstant(0.0), private
 DECLARE fangle = f8 WITH noconstant(0.0), private
 DECLARE fylabelwidth = f8 WITH noconstant(0.0), private
 DECLARE fylabelwidth2 = f8 WITH noconstant(0.0), private
 DECLARE fylabelheight = f8 WITH noconstant(0.0), private
 DECLARE fxlabelwidth = f8 WITH noconstant(0.0), private
 DECLARE fxlabelheight = f8 WITH noconstant(0.0), private
 DECLARE fholdwidth = f8 WITH noconstant(0.0), private
 DECLARE fholdheight = f8 WITH noconstant(0.0), private
 DECLARE fholdleft = f8 WITH noconstant(0.0), private
 DECLARE fholdtop = f8 WITH noconstant(0.0), private
 DECLARE brotatexlabels = i1 WITH noconstant(0), private
 DECLARE fclsum = f8 WITH noconstant(0.0), private
 DECLARE fclmean = f8 WITH noconstant(0.0), private
 DECLARE fclupper = f8 WITH noconstant(0.0), private
 DECLARE fcllower = f8 WITH noconstant(0.0), private
 DECLARE fclwlabels = f8 WITH noconstant(0.0), private
 DECLARE fclhlabels = f8 WITH noconstant(0.0), private
 DECLARE fxorigin = f8 WITH noconstant(0.0), private
 DECLARE fyorigin = f8 WITH noconstant(0.0), private
 DECLARE fxrange = f8 WITH noconstant(0.0), private
 DECLARE fyrange = f8 WITH noconstant(0.0), private
 DECLARE fmingrace = f8 WITH noconstant(0.1), private
 DECLARE fmaxgrace = f8 WITH noconstant(0.1), private
 DECLARE fzerolever = f8 WITH noconstant(0.25), private
 SET ngraphtype = rptgraphrec->m_ntype
 SET fleft = rptgraphrec->m_fleft
 SET ftop = rptgraphrec->m_ftop
 SET fwidth = rptgraphrec->m_fwidth
 SET fheight = rptgraphrec->m_fheight
 IF ((rptgraphrec->m_bshadow=1))
  SET fwidth = (fwidth - 0.02)
  SET fheight = (fheight - 0.02)
 ENDIF
 SET fright = (fleft+ fwidth)
 SET fbottom = (ftop+ fheight)
 SET rptfont->m_recsize = 50
 SET rptfont->m_fontname = rpt_times
 SET rptfont->m_pointsize = 10
 SET rptfont->m_bold = rpt_off
 SET rptfont->m_italic = rpt_off
 SET rptfont->m_underline = rpt_off
 SET rptfont->m_strikethrough = rpt_off
 SET rptfont->m_rgbcolor = uar_rptencodecolor(0,0,0)
 SET _fntdefault = uar_rptcreatefont(_hreport,rptfont)
 SET _fntrestore = uar_rptsetfont(_hreport,_fntdefault)
 IF ((rptgraphrec->m_stitle != ""))
  IF (_nrptgraphrecversion >= 3)
   SET rptfont->m_fontname = rptgraphrec->m_lsttitle.m_sfontname
   SET rptfont->m_pointsize = rptgraphrec->m_lsttitle.m_nfontsize
   SET rptfont->m_bold = rptgraphrec->m_lsttitle.m_bold
   SET rptfont->m_italic = rptgraphrec->m_lsttitle.m_italic
   SET rptfont->m_underline = rptgraphrec->m_lsttitle.m_underline
   SET rptfont->m_strikethrough = rptgraphrec->m_lsttitle.m_strikethrough
   SET rptfont->m_rgbcolor = rptgraphrec->m_lsttitle.m_rgbfontcolor
   SET _fnttitle = uar_rptcreatefont(_hreport,rptfont)
  ELSE
   SET _fnttitle = _fntdefault
  ENDIF
 ENDIF
 IF ((rptgraphrec->m_ssubtitle != ""))
  IF (_nrptgraphrecversion >= 3)
   SET rptfont->m_fontname = rptgraphrec->m_lstsubtitle.m_sfontname
   SET rptfont->m_pointsize = rptgraphrec->m_lstsubtitle.m_nfontsize
   SET rptfont->m_bold = rptgraphrec->m_lstsubtitle.m_bold
   SET rptfont->m_italic = rptgraphrec->m_lstsubtitle.m_italic
   SET rptfont->m_underline = rptgraphrec->m_lstsubtitle.m_underline
   SET rptfont->m_strikethrough = rptgraphrec->m_lstsubtitle.m_strikethrough
   SET rptfont->m_rgbcolor = rptgraphrec->m_lstsubtitle.m_rgbfontcolor
   SET _fntsubtitle = uar_rptcreatefont(_hreport,rptfont)
  ELSE
   SET _fntsubtitle = _fntdefault
  ENDIF
 ENDIF
 IF ((rptgraphrec->m_sxtitle != ""))
  IF (_nrptgraphrecversion >= 3)
   SET rptfont->m_fontname = rptgraphrec->m_lstxtitle.m_sfontname
   SET rptfont->m_pointsize = rptgraphrec->m_lstxtitle.m_nfontsize
   SET rptfont->m_bold = rptgraphrec->m_lstxtitle.m_bold
   SET rptfont->m_italic = rptgraphrec->m_lstxtitle.m_italic
   SET rptfont->m_underline = rptgraphrec->m_lstxtitle.m_underline
   SET rptfont->m_strikethrough = rptgraphrec->m_lstxtitle.m_strikethrough
   SET rptfont->m_rgbcolor = rptgraphrec->m_lstxtitle.m_rgbfontcolor
   SET _fntxtitle = uar_rptcreatefont(_hreport,rptfont)
  ELSE
   SET _fntxtitle = _fntdefault
  ENDIF
 ENDIF
 IF ((rptgraphrec->m_sytitle != ""))
  IF (_nrptgraphrecversion >= 3)
   SET rptfont->m_fontname = rptgraphrec->m_lstytitle.m_sfontname
   SET rptfont->m_pointsize = rptgraphrec->m_lstytitle.m_nfontsize
   SET rptfont->m_bold = rptgraphrec->m_lstytitle.m_bold
   SET rptfont->m_italic = rptgraphrec->m_lstytitle.m_italic
   SET rptfont->m_underline = rptgraphrec->m_lstytitle.m_underline
   SET rptfont->m_strikethrough = rptgraphrec->m_lstytitle.m_strikethrough
   SET rptfont->m_rgbcolor = rptgraphrec->m_lstytitle.m_rgbfontcolor
   SET _fntytitle = uar_rptcreatefont(_hreport,rptfont)
  ELSE
   SET _fntytitle = _fntdefault
  ENDIF
 ENDIF
 IF ((rptgraphrec->m_sytitle != ""))
  IF (_nrptgraphrecversion >= 3)
   SET rptfont->m_fontname = rptgraphrec->m_lstytitle2.m_sfontname
   SET rptfont->m_pointsize = rptgraphrec->m_lstytitle2.m_nfontsize
   SET rptfont->m_bold = rptgraphrec->m_lstytitle2.m_bold
   SET rptfont->m_italic = rptgraphrec->m_lstytitle2.m_italic
   SET rptfont->m_underline = rptgraphrec->m_lstytitle2.m_underline
   SET rptfont->m_strikethrough = rptgraphrec->m_lstytitle2.m_strikethrough
   SET rptfont->m_rgbcolor = rptgraphrec->m_lstytitle2.m_rgbfontcolor
   SET _fntytitle2 = uar_rptcreatefont(_hreport,rptfont)
  ELSE
   SET _fntytitle2 = _fntdefault
  ENDIF
 ENDIF
 IF (_nrptgraphrecversion >= 3)
  SET rptfont->m_fontname = rptgraphrec->m_lstlegend.m_sfontname
  SET rptfont->m_pointsize = rptgraphrec->m_lstlegend.m_nfontsize
  SET rptfont->m_bold = rptgraphrec->m_lstlegend.m_bold
  SET rptfont->m_italic = rptgraphrec->m_lstlegend.m_italic
  SET rptfont->m_underline = rptgraphrec->m_lstlegend.m_underline
  SET rptfont->m_strikethrough = rptgraphrec->m_lstlegend.m_strikethrough
  SET rptfont->m_rgbcolor = rptgraphrec->m_lstlegend.m_rgbfontcolor
  SET _fntlegend = uar_rptcreatefont(_hreport,rptfont)
 ELSE
  SET _fntlegend = _fntdefault
 ENDIF
 IF (_nrptgraphrecversion >= 3)
  SET rptfont->m_fontname = rptgraphrec->m_lstxgrid.m_sfontname
  SET rptfont->m_pointsize = rptgraphrec->m_lstxgrid.m_nfontsize
  SET rptfont->m_bold = rptgraphrec->m_lstxgrid.m_bold
  SET rptfont->m_italic = rptgraphrec->m_lstxgrid.m_italic
  SET rptfont->m_underline = rptgraphrec->m_lstxgrid.m_underline
  SET rptfont->m_strikethrough = rptgraphrec->m_lstxgrid.m_strikethrough
  SET rptfont->m_rgbcolor = rptgraphrec->m_lstxgrid.m_rgbfontcolor
  SET _fntxgrid = uar_rptcreatefont(_hreport,rptfont)
 ELSE
  SET _fntxgrid = _fntdefault
 ENDIF
 IF (_nrptgraphrecversion >= 3)
  SET rptfont->m_fontname = rptgraphrec->m_lstygrid.m_sfontname
  SET rptfont->m_pointsize = rptgraphrec->m_lstygrid.m_nfontsize
  SET rptfont->m_bold = rptgraphrec->m_lstygrid.m_bold
  SET rptfont->m_italic = rptgraphrec->m_lstygrid.m_italic
  SET rptfont->m_underline = rptgraphrec->m_lstygrid.m_underline
  SET rptfont->m_strikethrough = rptgraphrec->m_lstygrid.m_strikethrough
  SET rptfont->m_rgbcolor = rptgraphrec->m_lstygrid.m_rgbfontcolor
  SET _fntygrid = uar_rptcreatefont(_hreport,rptfont)
 ELSE
  SET _fntygrid = _fntdefault
 ENDIF
 SET rptpen->m_recsize = 16
 SET rptpen->m_penwidth = 0.013889
 SET rptpen->m_penstyle = 0
 SET rptpen->m_rgbcolor = uar_rptencodecolor(0,0,0)
 SET pen13s0c0 = uar_rptcreatepen(_hreport,rptpen)
 SET rptpen->m_penwidth = 0.010000
 SET pen10s0c0 = uar_rptcreatepen(_hreport,rptpen)
 SET rptpen->m_rgbcolor = rptgraphrec->m_rgbbordercolor
 SET rptpen->m_penwidth = rptgraphrec->m_fbordersize
 SET rptpen->m_penstyle = rptgraphrec->m_nborderstyle
 SET penborder = uar_rptcreatepen(_hreport,rptpen)
 SET rptpen->m_rgbcolor = rptgraphrec->m_rgbgridcolor
 SET rptpen->m_penwidth = rptgraphrec->m_fgridsize
 SET rptpen->m_penstyle = rptgraphrec->m_ngridstyle
 SET pengrid = uar_rptcreatepen(_hreport,rptpen)
 IF ((rptgraphrec->m_nbkmode=1))
  SET oldbackcolor = uar_rptsetbackcolor(_hreport,rptgraphrec->m_rgbbkcolor)
 ENDIF
 SET _penrestore = uar_rptsetpen(_hreport,penborder)
 SET _rptstat = uar_rptrect(_hreport,fleft,ftop,fwidth,fheight,
  0,0)
 SET oldbackcolor = uar_rptresetbackcolor(_hreport)
 IF ((rptgraphrec->m_bshadow=1))
  SET _dummypen = uar_rptsetpen(_hreport,pen10s0c0)
  SET _rptstat = uar_rptrect(_hreport,((fleft+ fwidth)+ 0.01),(ftop+ 0.02),0.01,fheight,
   0,0)
  SET _rptstat = uar_rptrect(_hreport,(fleft+ 0.02),((ftop+ fheight)+ 0.01),fwidth,0.01,
   0,0)
 ENDIF
 IF ((rptgraphrec->m_stitle != ""))
  SET rptsd->m_flags = (rpt_sdcalcrect+ rpt_sdhcenter)
  SET rptsd->m_borders = rpt_sdnoborders
  SET rptsd->m_padding = rpt_sdnoborders
  SET rptsd->m_x = (fleft+ (fwidth/ 8.0))
  SET rptsd->m_width = ((fright - (fwidth/ 8.0)) - rptsd->m_x)
  SET rptsd->m_y = (ftop+ 0.10)
  SET rptsd->m_height = (fheight/ 4.0)
  SET _oldfont = uar_rptsetfont(_hreport,_fnttitle)
  SET rptsd->m_flags = (rptsd->m_flags+ rpt_sdwrap)
  SET ftitleheight = uar_rptstringdraw(_hreport,rptsd,nullterm(rptgraphrec->m_stitle))
  SET rptsd->m_flags = ((rpt_sdhcenter+ rpt_sdwrap)+ rpt_sdellipsis)
  SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(rptgraphrec->m_stitle))
 ENDIF
 IF ((rptgraphrec->m_ssubtitle != ""))
  SET rptsd->m_flags = (((rpt_sdcalcrect+ rpt_sdhcenter)+ rpt_sdwrap)+ rpt_sdellipsis)
  SET rptsd->m_borders = rpt_sdnoborders
  SET rptsd->m_padding = rpt_sdnoborders
  SET rptsd->m_x = (fleft+ (fwidth/ 8.0))
  SET rptsd->m_width = ((fright - (fwidth/ 8.0)) - rptsd->m_x)
  SET rptsd->m_y = (((ftop+ 0.10)+ ftitleheight)+ 0.01)
  SET rptsd->m_height = (((ftop+ (fheight/ 4.0)) - rptsd->m_y)+ 0.01)
  SET _oldfont = uar_rptsetfont(_hreport,_fntsubtitle)
  SET fsubtitleheight = uar_rptstringdraw(_hreport,rptsd,nullterm(rptgraphrec->m_ssubtitle))
  SET rptsd->m_flags = ((rpt_sdhcenter+ rpt_sdwrap)+ rpt_sdellipsis)
  SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(rptgraphrec->m_ssubtitle))
 ENDIF
 IF (ngraphtype != 4)
  IF ((rptgraphrec->m_sxtitle != ""))
   SET rptsd->m_flags = ((rpt_sdcalcrect+ rpt_sdhcenter)+ rpt_sdellipsis)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_x = fleft
   SET rptsd->m_width = fwidth
   SET rptsd->m_y = ftop
   SET rptsd->m_height = fheight
   SET _oldfont = uar_rptsetfont(_hreport,_fntxtitle)
   SET fxtitleheight = uar_rptstringdraw(_hreport,rptsd,nullterm(rptgraphrec->m_sxtitle))
  ENDIF
  IF ((rptgraphrec->m_sytitle != ""))
   SET rptsd->m_flags = ((rpt_sdcalcrect+ rpt_sdhcenter)+ rpt_sdellipsis)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_x = fleft
   SET rptsd->m_width = (fwidth/ 6.0)
   SET rptsd->m_y = fbottom
   SET rptsd->m_height = fheight
   SET _oldfont = uar_rptsetfont(_hreport,_fntytitle)
   SET fytitleheight = uar_rptstringdraw(_hreport,rptsd,nullterm(rptgraphrec->m_sytitle))
  ENDIF
  IF ((rptgraphrec->m_sytitle2 != ""))
   SET rptsd->m_flags = ((rpt_sdcalcrect+ rpt_sdhcenter)+ rpt_sdellipsis)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_x = fleft
   SET rptsd->m_width = (fwidth/ 6.0)
   SET rptsd->m_y = fbottom
   SET rptsd->m_height = fheight
   SET _oldfont = uar_rptsetfont(_hreport,_fntytitle2)
   SET fytitleheight2 = uar_rptstringdraw(_hreport,rptsd,nullterm(rptgraphrec->m_sytitle2))
  ENDIF
 ENDIF
 SET _oldfont = uar_rptsetfont(_hreport,_fntdefault)
 SET nscnt = size(rptgraphrec->m_series,5)
 IF ((nscnt < rptgraphrec->m_nmaxseries))
  SET rptgraphrec->m_nmaxseries = nscnt
 ENDIF
 IF ((rptgraphrec->m_nmaxseries < 1))
  SET rptgraphrec->m_nmaxseries = nscnt
 ENDIF
 SET nmaxseries = rptgraphrec->m_nmaxseries
 SET nfcnt = size(rptgraphrec->m_series[1].y_values,5)
 IF (ngraphtype=3)
  SET nfcnt = size(rptgraphrec->m_series[1].x_values,5)
 ENDIF
 IF ((nfcnt < rptgraphrec->m_nmaxfields))
  SET rptgraphrec->m_nmaxfields = nfcnt
 ENDIF
 IF ((rptgraphrec->m_nmaxfields < 1))
  SET rptgraphrec->m_nmaxfields = nfcnt
 ENDIF
 SET nmaxfields = rptgraphrec->m_nmaxfields
 IF (((ngraphtype=0) OR (((ngraphtype=1) OR (((ngraphtype=2) OR (((ngraphtype=5) OR (ngraphtype=6))
 )) )) )) )
  IF ((((rptgraphrec->m_bymax=0)) OR ((((rptgraphrec->m_bymin=0)) OR (((ngraphtype=6
   AND (((rptgraphrec->m_bxmax=0)) OR ((rptgraphrec->m_bxmin=0))) ) OR (_nrptgraphrecversion >= 3
   AND validate(rptgraphrec->m_ncontrollimits,0)=1)) )) )) )
   SET nfcnt = 0
   WHILE (nfcnt < nmaxfields)
     SET nscnt = 0
     WHILE (nscnt < nmaxseries)
       IF (((ngraphtype != 6) OR ((rptgraphrec->m_series[(nscnt+ 1)].type=0))) )
        IF (nfcnt=0
         AND nscnt=0)
         IF ((rptgraphrec->m_nytype=0))
          SET fymax = rptgraphrec->m_series[(nscnt+ 1)].y_values[(nfcnt+ 1)].y_i4
         ELSE
          SET fymax = rptgraphrec->m_series[(nscnt+ 1)].y_values[(nfcnt+ 1)].y_f8
         ENDIF
        ENDIF
        IF ((rptgraphrec->m_nytype=0))
         IF ((fymax < rptgraphrec->m_series[(nscnt+ 1)].y_values[(nfcnt+ 1)].y_i4))
          SET fymax = rptgraphrec->m_series[(nscnt+ 1)].y_values[(nfcnt+ 1)].y_i4
         ENDIF
        ELSE
         IF ((fymax < rptgraphrec->m_series[(nscnt+ 1)].y_values[(nfcnt+ 1)].y_f8))
          SET fymax = rptgraphrec->m_series[(nscnt+ 1)].y_values[(nfcnt+ 1)].y_f8
         ENDIF
        ENDIF
        IF (nfcnt=0
         AND nscnt=0)
         IF ((rptgraphrec->m_nytype=0))
          SET fymin = rptgraphrec->m_series[(nscnt+ 1)].y_values[(nfcnt+ 1)].y_i4
         ELSE
          SET fymin = rptgraphrec->m_series[(nscnt+ 1)].y_values[(nfcnt+ 1)].y_f8
         ENDIF
        ENDIF
        IF ((rptgraphrec->m_nytype=0))
         IF ((fymin > rptgraphrec->m_series[(nscnt+ 1)].y_values[(nfcnt+ 1)].y_i4))
          SET fymin = rptgraphrec->m_series[(nscnt+ 1)].y_values[(nfcnt+ 1)].y_i4
         ENDIF
        ELSE
         IF ((fymin > rptgraphrec->m_series[(nscnt+ 1)].y_values[(nfcnt+ 1)].y_f8))
          SET fymin = rptgraphrec->m_series[(nscnt+ 1)].y_values[(nfcnt+ 1)].y_f8
         ENDIF
        ENDIF
       ELSE
        IF (nfcnt=0
         AND nscnt=0)
         IF ((rptgraphrec->m_nytype=0))
          SET fxmax = rptgraphrec->m_series[(nscnt+ 1)].y_values[(nfcnt+ 1)].y_i4
         ELSE
          SET fxmax = rptgraphrec->m_series[(nscnt+ 1)].y_values[(nfcnt+ 1)].y_f8
         ENDIF
        ENDIF
        IF ((rptgraphrec->m_nytype=0))
         IF ((fxmax < rptgraphrec->m_series[(nscnt+ 1)].y_values[(nfcnt+ 1)].y_i4))
          SET fxmax = rptgraphrec->m_series[(nscnt+ 1)].y_values[(nfcnt+ 1)].y_i4
         ENDIF
        ELSE
         IF ((fxmax < rptgraphrec->m_series[(nscnt+ 1)].y_values[(nfcnt+ 1)].y_f8))
          SET fxmax = rptgraphrec->m_series[(nscnt+ 1)].y_values[(nfcnt+ 1)].y_f8
         ENDIF
        ENDIF
        IF (nfcnt=0
         AND nscnt=0)
         IF ((rptgraphrec->m_nytype=0))
          SET fxmin = rptgraphrec->m_series[(nscnt+ 1)].y_values[(nfcnt+ 1)].y_i4
         ELSE
          SET fxmin = rptgraphrec->m_series[(nscnt+ 1)].y_values[(nfcnt+ 1)].y_f8
         ENDIF
        ENDIF
        IF ((rptgraphrec->m_nytype=0))
         IF ((fxmin > rptgraphrec->m_series[(nscnt+ 1)].y_values[(nfcnt+ 1)].y_i4))
          SET fxmin = rptgraphrec->m_series[(nscnt+ 1)].y_values[(nfcnt+ 1)].y_i4
         ENDIF
        ELSE
         IF ((fxmin > rptgraphrec->m_series[(nscnt+ 1)].y_values[(nfcnt+ 1)].y_f8))
          SET fxmin = rptgraphrec->m_series[(nscnt+ 1)].y_values[(nfcnt+ 1)].y_f8
         ENDIF
        ENDIF
       ENDIF
       IF (nscnt=0)
        SET fclsum = (fclsum+ rptgraphrec->m_series[(nscnt+ 1)].y_values[(nfcnt+ 1)].y_f8)
       ENDIF
       SET nscnt = (nscnt+ 1)
     ENDWHILE
     SET nfcnt = (nfcnt+ 1)
   ENDWHILE
  ENDIF
  IF ((rptgraphrec->m_bymax=1))
   SET fymax = rptgraphrec->m_fymax
  ENDIF
  IF ((rptgraphrec->m_bymin=1))
   SET fymin = rptgraphrec->m_fymin
  ENDIF
  IF ((rptgraphrec->m_nytype=0))
   SET fymax = floor(fymax)
   SET fymin = ceil(fymin)
  ENDIF
  IF (ngraphtype=6)
   IF ((rptgraphrec->m_bxmax=1))
    SET fxmax = rptgraphrec->m_fxmax
   ENDIF
   IF ((rptgraphrec->m_bxmin=1))
    SET fxmin = rptgraphrec->m_fxmin
   ENDIF
   IF ((rptgraphrec->m_nytype=0))
    SET fxmax = floor(fxmax)
    SET fxmin = ceil(fxmin)
   ENDIF
  ENDIF
 ENDIF
 IF (((ngraphtype=0) OR (ngraphtype=3)) )
  IF ((rptgraphrec->m_bxmax=0))
   SET nfcnt = 0
   WHILE (nfcnt < nmaxfields)
     SET nscnt = 0
     WHILE (nscnt < nmaxseries)
       IF (nfcnt=0
        AND nscnt=0)
        IF ((rptgraphrec->m_nxtype=0))
         SET fxmax = rptgraphrec->m_series[(nscnt+ 1)].x_values[(nfcnt+ 1)].x_i4
        ELSE
         SET fxmax = rptgraphrec->m_series[(nscnt+ 1)].x_values[(nfcnt+ 1)].x_f8
        ENDIF
       ENDIF
       IF ((rptgraphrec->m_nxtype=0))
        IF ((fxmax < rptgraphrec->m_series[(nscnt+ 1)].x_values[(nfcnt+ 1)].x_i4))
         SET fxmax = rptgraphrec->m_series[(nscnt+ 1)].x_values[(nfcnt+ 1)].x_i4
        ENDIF
       ELSE
        IF ((fxmax < rptgraphrec->m_series[(nscnt+ 1)].x_values[(nfcnt+ 1)].x_f8))
         SET fxmax = rptgraphrec->m_series[(nscnt+ 1)].x_values[(nfcnt+ 1)].x_f8
        ENDIF
       ENDIF
       SET nscnt = (nscnt+ 1)
     ENDWHILE
     SET nfcnt = (nfcnt+ 1)
   ENDWHILE
   SET rptgraphrec->m_fxmax = fxmax
  ENDIF
  SET fxmax = rptgraphrec->m_fxmax
  IF ((rptgraphrec->m_bxmin=0))
   SET nfcnt = 0
   WHILE (nfcnt < nmaxfields)
     SET nscnt = 0
     WHILE (nscnt < nmaxseries)
       IF (nfcnt=0
        AND nscnt=0)
        SET fxmin = rptgraphrec->m_series[(nscnt+ 1)].x_values[(nfcnt+ 1)].x_f8
       ENDIF
       IF ((fxmin > rptgraphrec->m_series[(nscnt+ 1)].x_values[(nfcnt+ 1)].x_f8))
        SET fxmin = rptgraphrec->m_series[(nscnt+ 1)].x_values[(nfcnt+ 1)].x_f8
       ENDIF
       SET nscnt = (nscnt+ 1)
     ENDWHILE
     SET nfcnt = (nfcnt+ 1)
   ENDWHILE
   SET rptgraphrec->m_fxmin = fxmin
  ENDIF
  SET fxmin = rptgraphrec->m_fxmin
  IF ((rptgraphrec->m_nxtype=0))
   SET fxmax = floor(fxmax)
   SET fxmin = ceil(fxmin)
  ENDIF
 ENDIF
 SET fclmean = (fclsum/ nmaxfields)
 SET fclupper = (fclmean+ (3 * (fclmean** 0.5)))
 SET fcllower = (fclmean - (3 * (fclmean** 0.5)))
 IF (fcllower < 0)
  SET fcllower = 0.0
 ENDIF
 IF ((rptgraphrec->m_bymax=0)
  AND fclupper > fymax)
  SET fymax = fclupper
 ENDIF
 IF ((rptgraphrec->m_bymin=0)
  AND fcllower < fymin)
  SET fymin = fcllower
 ENDIF
 IF (((ngraphtype=0) OR (((ngraphtype=1) OR (((ngraphtype=2) OR (((ngraphtype=5) OR (ngraphtype=6))
 )) )) )) )
  SET fyrange = (fymax - fymin)
  IF ((rptgraphrec->m_bymin=0))
   IF (((fymin < 0) OR (((fymin - (fmingrace * fyrange)) >= 0.0))) )
    SET fymin = (fymin - (fmingrace * fyrange))
   ENDIF
  ENDIF
  IF ((rptgraphrec->m_bymax=0))
   IF (((fymax > 0) OR (((fymax+ (fmaxgrace * fyrange)) <= 0.0))) )
    SET fymax = (fymax+ (fmaxgrace * fyrange))
   ENDIF
  ENDIF
  IF (((fymax - fymin) < 1.0e-20))
   IF ((rptgraphrec->m_bymax=0))
    IF (fymax=0)
     SET fymax = (fymax+ 0.2)
    ELSE
     SET fymax = (fymax+ (0.2 * abs(fymax)))
    ENDIF
   ENDIF
   IF ((rptgraphrec->m_bymin=0))
    IF (fymin=0)
     SET fymin = (fymin - 0.2)
    ELSE
     SET fymin = (fymin - (0.2 * abs(fymin)))
    ENDIF
   ENDIF
  ENDIF
  IF ((rptgraphrec->m_bymin=0))
   IF (fymin > 0
    AND ((fymin/ (fymax - fymin)) < fzerolever))
    SET fymin = 0
   ENDIF
  ENDIF
  IF ((rptgraphrec->m_bymax=0))
   IF (fymax < 0
    AND abs((fymax/ (fymax - fymin))) < fzerolever)
    SET fymax = 0
   ENDIF
  ENDIF
  IF ((rptgraphrec->m_fyindex=0.0))
   SET nynum = 7
   SET fyincr = calcstepsize((fymax - fymin),(nynum * 1.0))
  ELSE
   SET nynum = cnvtint(((fymax - fymin)/ rptgraphrec->m_fyindex))
   SET fyincr = rptgraphrec->m_fyindex
  ENDIF
  SET fyincr = abs(fyincr)
  IF ((rptgraphrec->m_bymin=0))
   SET fymin = (fymin - mymod(fymin,fyincr))
  ENDIF
  IF ((rptgraphrec->m_bymax=0))
   IF (mymod(fymax,fyincr) != 0)
    SET fymax = ((fymax+ fyincr) - mymod(fymin,fyincr))
   ENDIF
  ENDIF
  SET fypos = fymin
  SET nynum = 0
  IF (fyincr > 0)
   WHILE (fypos < fymax)
    SET fypos = (fypos+ fyincr)
    SET nynum = (nynum+ 1)
   ENDWHILE
   SET fymax = fypos
  ENDIF
 ENDIF
 IF (((ngraphtype=0) OR (((ngraphtype=3) OR (ngraphtype=6)) )) )
  SET fxrange = (fxmax - fxmin)
  IF ((rptgraphrec->m_bxmin=0))
   IF (((fxmin < 0) OR (((fxmin - (fmingrace * fxrange)) >= 0.0))) )
    SET fxmin = (fxmin - (fmingrace * fxrange))
   ENDIF
  ENDIF
  IF ((rptgraphrec->m_bxmax=0))
   IF (((fxmax > 0) OR (((fxmax+ (fmaxgrace * fxrange)) <= 0.0))) )
    SET fxmax = (fxmax+ (fmaxgrace * fxrange))
   ENDIF
  ENDIF
  IF (((fxmax - fxmin) < 1.0e-20))
   IF ((rptgraphrec->m_bxmax=0))
    IF (fxmax=0)
     SET fxmax = (fxmax+ 0.2)
    ELSE
     SET fxmax = (fxmax+ (0.2 * abs(fxmax)))
    ENDIF
   ENDIF
   IF ((rptgraphrec->m_bxmin=0))
    IF (fxmin=0)
     SET fxmin = (fxmin - 0.2)
    ELSE
     SET fxmin = (fxmin - (0.2 * abs(fxmin)))
    ENDIF
   ENDIF
  ENDIF
  IF ((rptgraphrec->m_bxmin=0))
   IF (fxmin > 0
    AND ((fxmin/ (fxmax - fxmin)) < fzerolever))
    SET fxmin = 0
   ENDIF
  ENDIF
  IF ((rptgraphrec->m_bxmax=0))
   IF (fxmax < 0
    AND abs((fxmax/ (fxmax - fxmin))) < fzerolever)
    SET fxmax = 0
   ENDIF
  ENDIF
  IF ((rptgraphrec->m_fxindex=0.0))
   SET nxnum = 7
   SET fxincr = calcstepsize((fxmax - fxmin),(nxnum * 1.0))
  ELSE
   SET nxnum = cnvtint(((fxmax - fxmin)/ rptgraphrec->m_fxindex))
   SET fxincr = rptgraphrec->m_fxindex
  ENDIF
  SET fxincr = abs(fxincr)
  IF ((rptgraphrec->m_bxmin=0))
   SET fxmin = (fxmin - mymod(fxmin,fxincr))
  ENDIF
  IF ((rptgraphrec->m_bxmax=0))
   IF (mymod(fxmax,fxincr) != 0)
    SET fxmax = ((fxmax+ fxincr) - mymod(fxmin,fxincr))
   ENDIF
  ENDIF
  SET fxpos = fxmin
  SET nxnum = 0
  IF (fxincr > 0)
   WHILE (fxpos < fxmax)
    SET fxpos = (fxpos+ fxincr)
    SET nxnum = (nxnum+ 1)
   ENDWHILE
   SET fxmax = fxpos
  ENDIF
 ENDIF
 IF (ngraphtype=3)
  SET nynum = nmaxfields
 ELSEIF (((ngraphtype=1) OR (((ngraphtype=2) OR (((ngraphtype=5) OR (ngraphtype=6)) )) )) )
  SET nynum2 = nxnum
  SET nxnum = nmaxfields
 ENDIF
 IF (trim(rptgraphrec->m_syformat,3)="")
  SET rptgraphrec->m_syformat = ""
 ENDIF
 SET syformat = rptgraphrec->m_syformat
 IF (trim(rptgraphrec->m_sxformat,3)="")
  SET rptgraphrec->m_sxformat = ""
 ENDIF
 SET sxformat = rptgraphrec->m_sxformat
 SET flmargin = 0.20
 SET rptsd->m_flags = ((rpt_sdcalcrect+ rpt_sdalignleft)+ rpt_sdtop)
 IF (ngraphtype != 4)
  SET _oldfont = uar_rptsetfont(_hreport,_fntygrid)
  IF (((ngraphtype=0) OR (((ngraphtype=1) OR (((ngraphtype=2) OR (((ngraphtype=5) OR (ngraphtype=6))
  )) )) )) )
   SET fyincr = ((fymax - fymin)/ nynum)
   SET fypos = fymax
   SET nycnt = 0
   WHILE ((nycnt < (nynum+ 1)))
     SET rptsd->m_width = 0
     SET rptsd->m_height = 0
     SET fylabelheight = uar_rptstringdraw(_hreport,rptsd,nullterm(getformattednumber(fypos,syformat)
       ))
     IF ((rptsd->m_width > fylabelwidth))
      SET fylabelwidth = rptsd->m_width
     ENDIF
     SET fypos = (fypos - fyincr)
     SET nycnt = (nycnt+ 1)
   ENDWHILE
  ELSEIF (ngraphtype=3)
   SET nycnt = 0
   WHILE (nycnt < nmaxfields
    AND nycnt < size(rptgraphrec->m_labels,5))
     SET rptsd->m_width = 0
     SET rptsd->m_height = 0
     SET fylabelheight = uar_rptstringdraw(_hreport,rptsd,nullterm(rptgraphrec->m_labels[(nycnt+ 1)].
       label))
     IF ((rptsd->m_width > fylabelwidth))
      SET fylabelwidth = rptsd->m_width
     ENDIF
     SET nycnt = (nycnt+ 1)
   ENDWHILE
  ENDIF
  SET _oldfont = uar_rptsetfont(_hreport,_fntdefault)
 ENDIF
 SET flmargin = (flmargin+ fylabelwidth)
 IF ((rptgraphrec->m_sytitle != ""))
  SET flmargin = (((flmargin+ 0.10)+ fytitleheight)+ 0.05)
 ENDIF
 SET flgrid = (fleft+ flmargin)
 SET ftmargin = ((ftitleheight+ fsubtitleheight)+ 0.30)
 SET ftgrid = (ftop+ ftmargin)
 SET frmargin = 0.10
 SET flgndtextwidth = 0.0
 SET flgndtextheight = 0.0
 IF (ngraphtype=6)
  SET _oldfont = uar_rptsetfont(_hreport,_fntygrid)
  SET rptsd->m_flags = ((rpt_sdcalcrect+ rpt_sdalignleft)+ rpt_sdtop)
  SET fyincr2 = ((fxmax - fxmin)/ nynum2)
  SET fypos = fxmax
  SET nycnt = 0
  WHILE ((nycnt < (nynum2+ 1)))
    SET rptsd->m_width = 0
    SET rptsd->m_height = 0
    SET fylabelheight = uar_rptstringdraw(_hreport,rptsd,nullterm(getformattednumber(fypos,sxformat))
     )
    IF ((rptsd->m_width > fylabelwidth2))
     SET fylabelwidth2 = rptsd->m_width
    ENDIF
    SET fypos = (fypos - fyincr2)
    SET nycnt = (nycnt+ 1)
  ENDWHILE
  SET frmargin = ((frmargin+ fylabelwidth2)+ 0.10)
  SET _oldfont = uar_rptsetfont(_hreport,_fntdefault)
  IF (_nrptgraphrecversion >= 2
   AND validate(rptgraphrec->m_sytitle2,"") != "")
   SET frmargin = ((frmargin+ fytitleheight2)+ 0.05)
  ENDIF
 ENDIF
 IF ((rptgraphrec->m_blegend=1)
  AND (rptgraphrec->m_nlegendpos=0))
  SET _oldfont = uar_rptsetfont(_hreport,_fntlegend)
  SET nscnt = 0
  WHILE (nscnt < nmaxseries)
    SET rptsd->m_flags = ((rpt_sdcalcrect+ rpt_sdalignleft)+ rpt_sdtop)
    SET rptsd->m_width = 0
    SET rptsd->m_height = 0
    SET flgndtextheight = uar_rptstringdraw(_hreport,rptsd,nullterm(rptgraphrec->m_series[(nscnt+ 1)]
      .name))
    IF ((rptsd->m_width > flgndtextwidth))
     SET flgndtextwidth = rptsd->m_width
    ENDIF
    SET nscnt = (nscnt+ 1)
  ENDWHILE
  SET _oldfont = uar_rptsetfont(_hreport,_fntdefault)
  SET fwlgndbox = flgndtextheight
  SET fhlgndbox = (flgndtextheight/ 2.0)
  SET fwlgndboxarea = (fwlgndbox+ 0.10)
 ENDIF
 IF ((rptgraphrec->m_blegend=1)
  AND (rptgraphrec->m_nlegendpos=0))
  SET frmargin = (((frmargin+ flgndtextwidth)+ fwlgndboxarea)+ 0.10)
 ELSE
  SET frmargin = (frmargin+ 0.10)
 ENDIF
 SET frgrid = ((fleft+ fwidth) - frmargin)
 SET fbmargin = 0.10
 SET fholdwidth = 0.0
 IF ((rptgraphrec->m_blegend=1)
  AND (rptgraphrec->m_nlegendpos=1))
  SET fwlegend = 0.05
  SET fhlegend = 0.05
  SET _oldfont = uar_rptsetfont(_hreport,_fntlegend)
  SET nscnt = 0
  WHILE (nscnt < nmaxseries)
    SET rptsd->m_flags = ((rpt_sdcalcrect+ rpt_sdalignleft)+ rpt_sdtop)
    SET rptsd->m_width = 0
    SET rptsd->m_height = 0
    SET flgndtextheight = uar_rptstringdraw(_hreport,rptsd,nullterm(rptgraphrec->m_series[(nscnt+ 1)]
      .name))
    IF (nscnt=0)
     SET fwlgndbox = flgndtextheight
     SET fhlgndbox = (flgndtextheight/ 2.0)
     SET fwlgndboxarea = (fwlgndbox+ 0.10)
    ENDIF
    IF (((((fwlegend+ fwlgndboxarea)+ rptsd->m_width)+ 0.05) > (fwidth - 0.10))
     AND nscnt > 0)
     SET fhlegend = ((fhlegend+ flgndtextheight)+ 0.05)
     IF (fwlegend > fholdwidth)
      SET fholdwidth = fwlegend
     ENDIF
     SET fwlegend = (((0.05+ fwlgndboxarea)+ rptsd->m_width)+ 0.05)
    ELSE
     SET fwlegend = (((fwlegend+ fwlgndboxarea)+ rptsd->m_width)+ 0.05)
    ENDIF
    SET nscnt = (nscnt+ 1)
  ENDWHILE
  SET _oldfont = uar_rptsetfont(_hreport,_fntdefault)
  SET fhlegend = ((fhlegend+ flgndtextheight)+ 0.05)
  IF (fholdwidth > fwlegend)
   SET fwlegend = fholdwidth
  ENDIF
  IF ((fwlegend > (fwidth - 0.10)))
   SET fwlegend = (fwidth - 0.10)
  ENDIF
  SET fllegend = (fleft+ ((fwidth - fwlegend)/ 2.0))
  SET fllegend = round(fllegend,6)
  SET ftlegend = (((ftop+ fheight) - fhlegend) - 0.05)
  SET fbmargin = (fbmargin+ fhlegend)
 ENDIF
 IF (((ngraphtype=1) OR (((ngraphtype=2) OR (((ngraphtype=5) OR (ngraphtype=6)) )) ))
  AND _nrptgraphrecversion >= 3
  AND validate(rptgraphrec->m_ncontrollimits,0)=1
  AND validate(rptgraphrec->m_ncontrollimitlabels,0)=1)
  SET rptsd->m_flags = ((rpt_sdcalcrect+ rpt_sdalignleft)+ rpt_sdtop)
  SET rptsd->m_width = 0
  SET rptsd->m_height = 0
  SET fcllabelheight = uar_rptstringdraw(_hreport,rptsd,nullterm(concat("UCL = ",getformattednumber(
      fclupper,""))))
  SET fclhlabels = ((0.05+ fcllabelheight)+ 0.05)
  SET fclwlabels = rptsd->m_width
  SET rptsd->m_width = 0
  SET rptsd->m_height = 0
  SET fcllabelheight = uar_rptstringdraw(_hreport,rptsd,nullterm(concat("LCL = ",getformattednumber(
      fcllower,""))))
  SET fclhlabels = ((fclhlabels+ fcllabelheight)+ 0.05)
  IF ((rptsd->m_width > fclwlabels))
   SET fclwlabels = rptsd->m_width
  ENDIF
  SET rptsd->m_width = 0
  SET rptsd->m_height = 0
  SET fcllabelheight = uar_rptstringdraw(_hreport,rptsd,nullterm(concat("Mean = ",getformattednumber(
      fclmean,""))))
  SET fclhlabels = ((fclhlabels+ fcllabelheight)+ 0.05)
  IF ((rptsd->m_width > fclwlabels))
   SET fclwlabels = rptsd->m_width
  ENDIF
  IF ((rptgraphrec->m_blegend=1)
   AND (rptgraphrec->m_nlegendpos=1))
   IF (fclhlabels > fhlegend)
    SET fbmargin = ((fbmargin+ fclhlabels) - fhlegend)
   ENDIF
  ELSE
   SET fbmargin = (fbmargin+ fclhlabels)
  ENDIF
  SET rptsd->m_flags = (rpt_sdalignleft+ rpt_sdtop)
  SET rptsd->m_x = (fleft+ 0.05)
  SET rptsd->m_y = ((fbottom - fclhlabels)+ 0.05)
  SET rptsd->m_width = fclwlabels
  SET rptsd->m_height = fcllabelheight
  SET fcllabelheight = uar_rptstringdraw(_hreport,rptsd,nullterm(concat("UCL = ",getformattednumber(
      fclupper,""))))
  SET rptsd->m_y = ((rptsd->m_y+ fcllabelheight)+ 0.05)
  SET fcllabelheight = uar_rptstringdraw(_hreport,rptsd,nullterm(concat("LCL = ",getformattednumber(
      fcllower,""))))
  SET rptsd->m_y = ((rptsd->m_y+ fcllabelheight)+ 0.05)
  SET fcllabelheight = uar_rptstringdraw(_hreport,rptsd,nullterm(concat("Mean = ",getformattednumber(
      fclmean,""))))
 ENDIF
 IF (((ngraphtype=1) OR (((ngraphtype=2) OR (((ngraphtype=5) OR (((ngraphtype=6) OR (ngraphtype=0))
 )) )) )) )
  IF (size(rptgraphrec->m_labels,5) >= 1)
   SET _oldfont = uar_rptsetfont(_hreport,_fntxgrid)
   SET fxindex = ((frgrid - flgrid)/ nxnum)
   SET rptsd->m_flags = (rpt_sdcalcrect+ rpt_sdhcenter)
   SET nfcnt = 0
   WHILE (nfcnt < nmaxfields)
     SET rptsd->m_width = 0
     SET rptsd->m_height = 0
     SET fxlabelheight = uar_rptstringdraw(_hreport,rptsd,nullterm(rptgraphrec->m_labels[(nfcnt+ 1)].
       label))
     IF ((rptsd->m_width > fxlabelwidth))
      SET fxlabelwidth = rptsd->m_width
     ENDIF
     SET nfcnt = (nfcnt+ 1)
   ENDWHILE
   IF ((fxlabelwidth > (fxindex - 0.05)))
    SET brotatexlabels = 1
   ELSE
    SET fxlabelwidth = fxindex
    SET fbmargin = (fbmargin+ 0.20)
    IF ((rptgraphrec->m_sxtitle != ""))
     SET fbmargin = ((fbmargin+ fxtitleheight)+ 0.05)
    ENDIF
   ENDIF
   IF (brotatexlabels=1)
    SET fbmargin = ((fbmargin+ (fxlabelwidth/ (2** 0.5)))+ 0.10)
    IF ((rptgraphrec->m_sxtitle != ""))
     SET fbmargin = ((fbmargin+ fxtitleheight)+ 0.05)
    ENDIF
    IF ((fbmargin > (fheight/ 2.0)))
     SET fbmargin = (fheight/ 2.0)
     SET fxlabelwidth = (fbmargin - 0.10)
     IF ((rptgraphrec->m_blegend=1)
      AND (rptgraphrec->m_nlegendpos=1))
      SET fxlabelwidth = ((fxlabelwidth - fhlegend) - 0.10)
     ENDIF
     IF ((rptgraphrec->m_sxtitle != ""))
      SET fxlabelwidth = ((fxlabelwidth - ftitleheight) - 0.05)
     ENDIF
     SET fxlabelwidth = (fxlabelwidth * (2** 0.5))
    ENDIF
    SET nfcnt = 0
    WHILE (nfcnt < nmaxfields)
      SET rptsd->m_width = 0
      SET rptsd->m_height = 0
      SET fxlabelheight = uar_rptstringdraw(_hreport,rptsd,nullterm(rptgraphrec->m_labels[(nfcnt+ 1)]
        .label))
      SET fholdwidth = rptsd->m_width
      IF (fholdwidth > fxlabelwidth)
       SET fholdwidth = fxlabelwidth
      ENDIF
      SET fholdwidth = ((fholdwidth/ (2** 0.5))+ 0.10)
      IF ((fholdwidth > ((flmargin+ (fxindex/ 2.0))+ (fxindex * nfcnt))))
       SET flmargin = ((fholdwidth - (fxindex/ 2.0)) - (fxindex * nfcnt))
       SET flgrid = (fleft+ flmargin)
      ELSEIF (fxlabelwidth > fylabelwidth)
       IF ((nfcnt=(nmaxfields - 1)))
        SET flmargin = ((flmargin+ fxlabelwidth) - fylabelwidth)
        SET flgrid = (fleft+ flmargin)
       ENDIF
      ENDIF
      SET nfcnt = (nfcnt+ 1)
    ENDWHILE
    SET rptsd->m_rotationangle = 0
   ENDIF
   SET _oldfont = uar_rptsetfont(_hreport,_fntdefault)
  ENDIF
 ELSE
  SET fbmargin = (fbmargin+ 0.20)
  IF ((rptgraphrec->m_sxtitle != ""))
   SET fbmargin = ((fbmargin+ ftitleheight)+ 0.05)
  ENDIF
 ENDIF
 SET fbgrid = ((ftop+ fheight) - fbmargin)
 SET fwgrid = (frgrid - flgrid)
 SET fhgrid = (fbgrid - ftgrid)
 FOR (nscnt = 1 TO nmaxseries)
   IF ((rptgraphrec->m_series[nscnt].color < 0))
    SET rptgraphrec->m_series[nscnt].color = getdefaultcolor(nscnt)
   ENDIF
 ENDFOR
 IF ((rptgraphrec->m_blegend=1))
  IF ((rptgraphrec->m_nlegendpos=0))
   SET fllegend = (frgrid+ 0.05)
   IF (ngraphtype=6)
    SET fllegend = ((fllegend+ 0.10)+ fylabelwidth2)
    IF (_nrptgraphrecversion >= 2
     AND validate(rptgraphrec->m_sytitle2,"") != "")
     SET fllegend = ((fllegend+ 0.05)+ fytitleheight2)
    ENDIF
   ENDIF
   SET ftlegend = (((fbgrid+ ftgrid)/ 2) - ((flgndtextheight * nmaxseries)/ 2))
   SET fwlegend = (((fleft+ fwidth) - fllegend) - 0.10)
   SET fhlegend = ((flgndtextheight * nmaxseries)+ 0.05)
   IF ((fhlegend > (fheight - 0.10)))
    SET ftlegend = (ftop+ 0.05)
    SET fhlegend = (fheight - 0.10)
   ENDIF
  ENDIF
  SET _oldfont = uar_rptsetfont(_hreport,_fntlegend)
  IF (_nrptgraphrecversion >= 3)
   IF ((rptgraphrec->m_nlegendbkmode=1))
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,rptgraphrec->m_rgblegendbkcolor)
   ENDIF
  ENDIF
  SET _dummypen = uar_rptsetpen(_hreport,pen10s0c0)
  SET _rptstat = uar_rptrect(_hreport,fllegend,ftlegend,fwlegend,fhlegend,
   0,0)
  IF (_nrptgraphrecversion >= 3)
   IF ((rptgraphrec->m_nlegendbkmode=1))
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   ENDIF
  ENDIF
  IF ((rptgraphrec->m_nlegendpos=0))
   SET fllgndboxarea = (fllegend+ 0.05)
   SET rptsd->m_flags = (rpt_sdalignleft+ rpt_sdtop)
   SET rptsd->m_x = ((fllegend+ fwlgndboxarea)+ 0.01)
   SET rptsd->m_y = (ftlegend+ 0.01)
   SET rptsd->m_width = flgndtextwidth
   SET rptsd->m_height = (flgndtextheight+ 0.05)
   SET nscnt = 0
   WHILE (nscnt < nmaxseries)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(rptgraphrec->m_series[(nscnt+ 1)].
       name))
     SET rptsd->m_y = (rptsd->m_y+ flgndtextheight)
     SET nscnt = (nscnt+ 1)
     IF (((rptsd->m_y+ flgndtextheight) > (fbottom - 0.05)))
      SET nscnt = nmaxseries
     ENDIF
   ENDWHILE
   SET nscnt = 0
   SET rptsd->m_y = (ftlegend+ 0.01)
   WHILE (nscnt < nmaxseries)
     SET dummy_val = drawlegendcolorbox(ngraphtype,fllgndboxarea,(rptsd->m_y+ (fhlgndbox/ 2)),
      fwlgndbox,fhlgndbox,
      nscnt)
     SET rptsd->m_y = (rptsd->m_y+ flgndtextheight)
     SET nscnt = (nscnt+ 1)
     IF (((rptsd->m_y+ flgndtextheight) > (fbottom - 0.05)))
      SET nscnt = nmaxseries
     ENDIF
   ENDWHILE
  ELSEIF ((rptgraphrec->m_nlegendpos=1))
   SET fholdleft = (fllegend+ 0.05)
   SET fholdtop = (ftlegend+ 0.05)
   SET nscnt = 0
   WHILE (nscnt < nmaxseries)
     SET rptsd->m_flags = ((rpt_sdcalcrect+ rpt_sdalignleft)+ rpt_sdtop)
     SET rptsd->m_width = 0
     SET rptsd->m_height = 0
     SET flgndtextheight = uar_rptstringdraw(_hreport,rptsd,nullterm(rptgraphrec->m_series[(nscnt+ 1)
       ].name))
     IF (nscnt > 0)
      IF (round((((fholdleft+ fwlgndboxarea)+ rptsd->m_width)+ 0.05),6) > round((fllegend+ fwlegend),
       6))
       SET fholdtop = ((fholdtop+ flgndtextheight)+ 0.05)
       SET fholdleft = (fllegend+ 0.05)
      ENDIF
     ENDIF
     SET dummy_val = drawlegendcolorbox(ngraphtype,fholdleft,(fholdtop+ (fhlgndbox/ 2)),fwlgndbox,
      fhlgndbox,
      nscnt)
     SET fholdleft = (fholdleft+ fwlgndboxarea)
     SET rptsd->m_flags = ((rpt_sdalignleft+ rpt_sdtop)+ rpt_sdellipsis)
     SET rptsd->m_x = fholdleft
     SET rptsd->m_y = fholdtop
     SET rptsd->m_height = flgndtextheight
     SET flgndtextheight = uar_rptstringdraw(_hreport,rptsd,nullterm(rptgraphrec->m_series[(nscnt+ 1)
       ].name))
     SET fholdleft = ((fholdleft+ rptsd->m_width)+ 0.05)
     SET nscnt = (nscnt+ 1)
   ENDWHILE
  ENDIF
  SET _oldfont = uar_rptsetfont(_hreport,_fntdefault)
 ENDIF
 IF (ngraphtype != 4)
  SET rptsd->m_x = fleft
  SET rptsd->m_width = fwidth
  SET rptsd->m_height = fxtitleheight
  SET rptsd->m_flags = (rpt_sdhcenter+ rpt_sdellipsis)
  IF ((rptgraphrec->m_sxtitle != ""))
   SET rptsd->m_y = (((ftop+ fheight) - rptsd->m_height) - 0.05)
   IF (rptgraphrec->m_blegend
    AND (rptgraphrec->m_nlegendpos=1))
    SET rptsd->m_y = ((rptsd->m_y - fhlegend) - 0.05)
   ENDIF
   SET _oldfont = uar_rptsetfont(_hreport,_fntxtitle)
   SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(rptgraphrec->m_sxtitle))
  ENDIF
  IF ((rptgraphrec->m_sytitle != ""))
   SET rptsd->m_x = (fleft+ 0.10)
   SET rptsd->m_y = fbgrid
   SET rptsd->m_width = fhgrid
   SET rptsd->m_height = fytitleheight
   SET rptsd->m_rotationangle = 90
   SET _oldfont = uar_rptsetfont(_hreport,_fntytitle)
   SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(rptgraphrec->m_sytitle))
   SET rptsd->m_rotationangle = 0
  ENDIF
  IF (ngraphtype=6)
   IF (_nrptgraphrecversion >= 2
    AND validate(rptgraphrec->m_sytitle2,"") != "")
    SET rptsd->m_flags = (rpt_sdhcenter+ rpt_sdellipsis)
    SET rptsd->m_x = (((frgrid+ 0.10)+ fylabelwidth2)+ 0.05)
    SET rptsd->m_y = fbgrid
    SET rptsd->m_width = fhgrid
    SET rptsd->m_height = fytitleheight2
    SET rptsd->m_rotationangle = 90
    SET _oldfont = uar_rptsetfont(_hreport,_fntytitle2)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(rptgraphrec->m_sytitle2))
    SET rptsd->m_rotationangle = 0
   ENDIF
  ENDIF
  SET _oldfont = uar_rptsetfont(_hreport,_fntdefault)
 ENDIF
 IF (ngraphtype != 4)
  IF (rptgraphrec->m_ngridbkmode)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,rptgraphrec->m_rgbgridbkcolor)
  ENDIF
  SET _dummypen = uar_rptsetpen(_hreport,pengrid)
  SET _rptstat = uar_rptrect(_hreport,flgrid,ftgrid,fwgrid,fhgrid,
   0,0)
  SET oldbackcolor = uar_rptresetbackcolor(_hreport)
 ENDIF
 IF (ngraphtype != 4)
  SET nycnt = 0
  SET fyindex = ((fbgrid - ftgrid)/ nynum)
  SET fypos = ftgrid
  WHILE ((nycnt < (nynum+ 1)))
    IF ((rptgraphrec->m_bygrid > 0))
     SET _rptstat = uar_rptline(_hreport,(flgrid - 0.05),fypos,frgrid,fypos)
    ELSE
     SET _rptstat = uar_rptline(_hreport,(flgrid - 0.05),fypos,flgrid,fypos)
    ENDIF
    SET nycnt = (nycnt+ 1)
    SET fypos = (fypos+ fyindex)
  ENDWHILE
  IF (ngraphtype=6)
   SET nycnt = 0
   SET fyindex2 = ((fbgrid - ftgrid)/ nynum2)
   SET fypos = ftgrid
   WHILE ((nycnt < (nynum2+ 1)))
     SET _rptstat = uar_rptline(_hreport,frgrid,fypos,(frgrid+ 0.05),fypos)
     SET nycnt = (nycnt+ 1)
     SET fypos = (fypos+ fyindex2)
   ENDWHILE
  ENDIF
 ENDIF
 IF (ngraphtype != 4)
  SET nxcnt = 0
  SET fxindex = ((frgrid - flgrid)/ nxnum)
  SET fxpos = flgrid
  WHILE ((nxcnt < (nxnum+ 1)))
    IF ((rptgraphrec->m_bxgrid > 0))
     SET _rptstat = uar_rptline(_hreport,fxpos,ftgrid,fxpos,(fbgrid+ 0.05))
    ELSE
     SET _rptstat = uar_rptline(_hreport,fxpos,fbgrid,fxpos,(fbgrid+ 0.05))
    ENDIF
    SET nxcnt = (nxcnt+ 1)
    SET fxpos = (fxpos+ fxindex)
  ENDWHILE
 ENDIF
 SET rptsd->m_flags = (rpt_sdalignright+ rpt_sdtop)
 SET rptsd->m_x = fleft
 SET rptsd->m_y = (ftgrid - (fylabelheight/ 2.0))
 SET rptsd->m_width = (flmargin - 0.10)
 SET rptsd->m_height = (fylabelheight+ 0.05)
 SET nycnt = 0
 IF (ngraphtype != 4)
  SET _oldfont = uar_rptsetfont(_hreport,_fntygrid)
  IF (((ngraphtype=0) OR (((ngraphtype=1) OR (((ngraphtype=2) OR (((ngraphtype=5) OR (ngraphtype=6))
  )) )) )) )
   SET fypos = fymax
   WHILE ((nycnt < (nynum+ 1)))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(getformattednumber(fypos,syformat))
      )
     SET nycnt = (nycnt+ 1)
     SET rptsd->m_y = (rptsd->m_y+ fyindex)
     SET fypos = (fypos - fyincr)
   ENDWHILE
  ELSEIF (ngraphtype=3)
   SET rptsd->m_y = (rptsd->m_y+ (fyindex/ 2))
   WHILE (nycnt < nmaxfields)
     IF ((((nmaxfields - nycnt) - 1) < size(rptgraphrec->m_labels,5)))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(trim(rptgraphrec->m_labels[(
         nmaxfields - nycnt)].label,3)))
     ENDIF
     SET nycnt = (nycnt+ 1)
     SET rptsd->m_y = (rptsd->m_y+ fyindex)
   ENDWHILE
  ENDIF
  IF (ngraphtype=6)
   SET rptsd->m_flags = (rpt_sdalignleft+ rpt_sdtop)
   SET rptsd->m_x = (frgrid+ 0.10)
   SET rptsd->m_y = (ftgrid - (fylabelheight/ 2.0))
   SET rptsd->m_width = fylabelwidth2
   SET rptsd->m_height = (fylabelheight+ 0.05)
   SET fypos = fxmax
   FOR (nycnt = 0 TO nynum2)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(getformattednumber(fypos,sxformat))
      )
     SET rptsd->m_y = (rptsd->m_y+ fyindex2)
     SET fypos = (fypos - fyincr2)
   ENDFOR
  ENDIF
  SET _oldfont = uar_rptsetfont(_hreport,_fntdefault)
 ENDIF
 IF (ngraphtype != 4)
  SET _oldfont = uar_rptsetfont(_hreport,_fntxgrid)
  SET nxcnt = - (1)
  IF (ngraphtype=3)
   SET rptsd->m_flags = 272
   SET rptsd->m_x = (flgrid - (fxindex/ 2.0))
   SET rptsd->m_y = fbgrid
   SET rptsd->m_height = (fylabelheight+ 0.05)
   SET rptsd->m_width = fxindex
  ELSE
   SET rptsd->m_height = (fxlabelheight+ 0.5)
   SET rptsd->m_width = fxlabelwidth
   IF (brotatexlabels=1)
    SET rptsd->m_flags = ((rpt_sdalignright+ rpt_sdtop)+ rpt_sdellipsis)
    IF (ngraphtype != 0)
     SET rptsd->m_x = ((flgrid+ (fxindex/ 2.0)) - (fxlabelwidth/ (2** 0.5)))
    ELSE
     SET rptsd->m_x = (flgrid - (fxlabelwidth/ (2** 0.5)))
    ENDIF
    SET rptsd->m_y = (fbgrid+ (fxlabelwidth/ (2** 0.5)))
    SET rptsd->m_rotationangle = 45
   ELSE
    SET rptsd->m_flags = rpt_sdhcenter
    IF (ngraphtype != 0)
     SET rptsd->m_x = flgrid
    ELSE
     SET rptsd->m_x = (flgrid - (fxindex/ 2.0))
    ENDIF
    SET rptsd->m_y = (fbgrid+ 0.05)
   ENDIF
  ENDIF
  SET nsize = size(rptgraphrec->m_labels,5)
  SET fxincr = ((fxmax - fxmin)/ nxnum)
  SET fxpos = fxmin
  WHILE (nxcnt < nxnum)
    IF (((ngraphtype=0) OR (ngraphtype=3)) )
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(getformattednumber(fxpos,sxformat))
      )
     SET rptsd->m_x = (rptsd->m_x+ fxindex)
    ELSEIF (((ngraphtype=1) OR (((ngraphtype=2) OR (((ngraphtype=5) OR (ngraphtype=6)) )) )) )
     IF (nxcnt >= 0
      AND nxcnt < nsize)
      IF (mod(nxcnt,ceil((fxlabelheight/ fxindex)))=0)
       SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(trim(rptgraphrec->m_labels[(nxcnt
          + 1)].label,3)))
      ENDIF
      SET rptsd->m_x = (rptsd->m_x+ fxindex)
     ENDIF
    ENDIF
    SET nxcnt = (nxcnt+ 1)
    SET fxpos = (fxpos+ fxincr)
  ENDWHILE
  SET rptsd->m_rotationangle = 0
  SET _oldfont = uar_rptsetfont(_hreport,_fntdefault)
 ENDIF
 SET ym = ((fbgrid - ftgrid)/ (fymin - fymax))
 SET yb = (fbgrid - (fymin * ym))
 SET ym2 = ((fbgrid - ftgrid)/ (fxmin - fxmax))
 SET yb2 = (fbgrid - (fxmin * ym2))
 SET xm = ((frgrid - flgrid)/ (fxmax - fxmin))
 SET xb = (frgrid - (fxmax * xm))
 SET _dummypen = uar_rptsetpen(_hreport,pen10s0c0)
 IF (ngraphtype=0)
  SET nscnt = 0
  SET nfcnt = 0
  SET rptsd->m_flags = 32
  WHILE (nfcnt < nmaxfields)
    WHILE (nscnt < nmaxseries)
      SET fypos = ((ym * rptgraphrec->m_series[(nscnt+ 1)].y_values[(nfcnt+ 1)].y_f8)+ yb)
      SET rptfont->m_rgbcolor = rptgraphrec->m_series[(nscnt+ 1)].color
      SET _oldfont = uar_rptsetfont(_hreport,uar_rptcreatefont(_hreport,rptfont))
      SET fxpos = ((xm * rptgraphrec->m_series[(nscnt+ 1)].x_values[(nfcnt+ 1)].x_f8)+ xb)
      IF ((rptgraphrec->m_series[(nscnt+ 1)].x_values[(nfcnt+ 1)].x_f8 <= fxmax)
       AND (rptgraphrec->m_series[(nscnt+ 1)].x_values[(nfcnt+ 1)].x_f8 >= fxmin)
       AND (rptgraphrec->m_series[(nscnt+ 1)].y_values[(nfcnt+ 1)].y_f8 <= fymax)
       AND (rptgraphrec->m_series[(nscnt+ 1)].y_values[(nfcnt+ 1)].y_f8 >= fymin))
       SET rptpen->m_penwidth = 0.020000
       SET rptpen->m_rgbcolor = rptgraphrec->m_series[(nscnt+ 1)].color
       SET _dummypen = uar_rptsetpen(_hreport,uar_rptcreatepen(_hreport,rptpen))
       SET oldbackcolor = uar_rptsetbackcolor(_hreport,rptgraphrec->m_series[(nscnt+ 1)].color)
       IF (mod(nscnt,2)=0)
        SET _rptstat = uar_rptrect(_hreport,(fxpos - 0.02),(fypos - 0.02),0.04,0.04,
         0,0)
       ELSE
        SET _rptstat = uar_rptoval(_hreport,fxpos,fypos,0.02,0.02,
         0,0)
       ENDIF
       SET oldbackcolor = uar_rptresetbackcolor(_hreport)
      ENDIF
      SET nscnt = (nscnt+ 1)
    ENDWHILE
    SET fxpos = (fxpos+ fxindex)
    SET nscnt = 0
    SET nfcnt = (nfcnt+ 1)
  ENDWHILE
 ENDIF
 IF (((ngraphtype=2) OR (((ngraphtype=5) OR (ngraphtype=6)) )) )
  IF (((ngraphtype=5) OR (ngraphtype=6)) )
   SET nholdseries = 0
   FOR (nscnt = 1 TO nmaxseries)
     IF ((rptgraphrec->m_series[nscnt].type=0))
      SET nholdseries = (nholdseries+ 1)
     ENDIF
   ENDFOR
   SET fbarwidth = (fxindex/ (nholdseries+ 2))
  ELSE
   SET fbarwidth = (fxindex/ (nmaxseries+ 2))
  ENDIF
  IF (fymax > 0
   AND fymin < 0)
   SET fyorigin = yb
   SET _rptstat = uar_rptline(_hreport,flgrid,fyorigin,frgrid,fyorigin)
  ELSEIF (fymax <= 0)
   SET fyorigin = ftgrid
  ELSE
   SET fyorigin = fbgrid
  ENDIF
  SET nscnt = 0
  SET nfcnt = 0
  SET fxpos = flgrid
  WHILE (nfcnt < nmaxfields)
    SET nhold = 0
    WHILE (nscnt < nmaxseries)
     IF (((ngraphtype=2) OR ((rptgraphrec->m_series[(nscnt+ 1)].type=0))) )
      SET fypos = ((ym * rptgraphrec->m_series[(nscnt+ 1)].y_values[(nfcnt+ 1)].y_f8)+ yb)
      IF (fypos < ftgrid)
       SET fypos = ftgrid
      ELSEIF (fypos > fbgrid)
       SET fypos = fbgrid
      ENDIF
      SET oldbackcolor = uar_rptsetbackcolor(_hreport,rptgraphrec->m_series[(nscnt+ 1)].color)
      SET _rptstat = uar_rptrect(_hreport,(fxpos+ (fbarwidth * (1+ nhold))),fypos,fbarwidth,(fyorigin
        - fypos),
       0,0)
      SET oldbackcolor = uar_rptresetbackcolor(_hreport)
      SET nhold = (nhold+ 1)
     ENDIF
     SET nscnt = (nscnt+ 1)
    ENDWHILE
    SET fxpos = (fxpos+ fxindex)
    SET nscnt = 0
    SET nfcnt = (nfcnt+ 1)
  ENDWHILE
 ENDIF
 IF (((ngraphtype=1) OR (((ngraphtype=5) OR (ngraphtype=6)) )) )
  SET nscnt = 0
  SET nfcnt = 0
  SET fxpos = (flgrid+ (fxindex/ 2))
  WHILE (nfcnt < nmaxfields)
    WHILE (nscnt < nmaxseries)
     IF (((ngraphtype=1) OR ((rptgraphrec->m_series[(nscnt+ 1)].type=1))) )
      IF (ngraphtype=6)
       SET fypos = ((ym2 * rptgraphrec->m_series[(nscnt+ 1)].y_values[(nfcnt+ 1)].y_f8)+ yb2)
      ELSE
       SET fypos = ((ym * rptgraphrec->m_series[(nscnt+ 1)].y_values[(nfcnt+ 1)].y_f8)+ yb)
      ENDIF
      IF (fypos < ftgrid)
       SET fypos = ftgrid
      ELSEIF (fypos > fbgrid)
       SET fypos = fbgrid
      ENDIF
      SET rptpen->m_penwidth = 0.020000
      SET rptpen->m_rgbcolor = rptgraphrec->m_series[(nscnt+ 1)].color
      SET _dummypen = uar_rptsetpen(_hreport,uar_rptcreatepen(_hreport,rptpen))
      IF (nfcnt > 0)
       IF (ngraphtype=6)
        SET fyold = ((ym2 * rptgraphrec->m_series[(nscnt+ 1)].y_values[nfcnt].y_f8)+ yb2)
       ELSE
        SET fyold = ((ym * rptgraphrec->m_series[(nscnt+ 1)].y_values[nfcnt].y_f8)+ yb)
       ENDIF
       IF (fyold < ftgrid)
        SET fyold = ftgrid
       ELSEIF (fyold > fbgrid)
        SET fyold = fbgrid
       ENDIF
       SET _rptstat = uar_rptline(_hreport,(fxpos - fxindex),fyold,fxpos,fypos)
      ENDIF
      SET oldbackcolor = uar_rptsetbackcolor(_hreport,rptgraphrec->m_series[(nscnt+ 1)].color)
      IF (mod(nscnt,2)=0)
       SET _rptstat = uar_rptrect(_hreport,(fxpos - 0.02),(fypos - 0.02),0.04,0.04,
        0,0)
      ELSE
       SET _rptstat = uar_rptoval(_hreport,fxpos,fypos,0.02,0.02,
        0,0)
      ENDIF
      SET oldbackcolor = uar_rptresetbackcolor(_hreport)
     ENDIF
     SET nscnt = (nscnt+ 1)
    ENDWHILE
    SET fxpos = (fxpos+ fxindex)
    SET nscnt = 0
    SET nfcnt = (nfcnt+ 1)
  ENDWHILE
 ENDIF
 IF (ngraphtype=3)
  IF (fxmax > 0
   AND fxmin < 0)
   SET fxorigin = xb
   SET _rptstat = uar_rptline(_hreport,fxorigin,ftgrid,fxorigin,fbgrid)
  ELSEIF (fxmax <= 0)
   SET fxorigin = frgrid
  ELSE
   SET fxorigin = flgrid
  ENDIF
  SET nscnt = 0
  SET nfcnt = 0
  SET fypos = ftgrid
  SET fbarwidth = (fyindex/ (nmaxseries+ 2))
  WHILE (nfcnt < nmaxfields)
    WHILE (nscnt < nmaxseries)
      SET fxpos = ((xm * rptgraphrec->m_series[(nscnt+ 1)].x_values[(nmaxfields - nfcnt)].x_f8)+ xb)
      IF (fxpos < flgrid)
       SET fxpos = flgrid
      ELSEIF (fxpos > frgrid)
       SET fxpos = frgrid
      ENDIF
      SET oldbackcolor = uar_rptsetbackcolor(_hreport,rptgraphrec->m_series[(nscnt+ 1)].color)
      SET _rptstat = uar_rptrect(_hreport,fxorigin,(fypos+ (fbarwidth * (1+ nscnt))),(fxpos -
       fxorigin),fbarwidth,
       0,0)
      SET oldbackcolor = uar_rptresetbackcolor(_hreport)
      SET nscnt = (nscnt+ 1)
    ENDWHILE
    SET fypos = (fypos+ fyindex)
    SET nscnt = 0
    SET nfcnt = (nfcnt+ 1)
  ENDWHILE
 ENDIF
 IF (ngraphtype=4)
  SET nscnt = 0
  WHILE (nscnt < nmaxseries)
   SET fpietotal = (fpietotal+ rptgraphrec->m_series[(nscnt+ 1)].y_values[1].y_f8)
   SET nscnt = (nscnt+ 1)
  ENDWHILE
  SET fxcenter = ((flgrid+ frgrid)/ 2)
  SET fycenter = ((ftgrid+ fbgrid)/ 2)
  SET fyrad = (fycenter - ftgrid)
  SET fxrad = (fxcenter - flgrid)
  SET fpierad = fxrad
  IF (fyrad < fxrad)
   SET fpierad = fyrad
  ENDIF
  SET fangle = 0.0
  SET nscnt = 0
  WHILE (nscnt < nmaxseries)
    SET fpiepct = (360.0 * (rptgraphrec->m_series[(nscnt+ 1)].y_values[1].y_f8/ fpietotal))
    SET _rptstat = uar_rptarc(_hreport,fxcenter,fycenter,fpierad,floor(round(fangle,0)),
     floor(round((fangle+ fpiepct),0)),1,rptgraphrec->m_series[(nscnt+ 1)].color)
    SET fangle = (fangle+ fpiepct)
    SET nscnt = (nscnt+ 1)
  ENDWHILE
 ENDIF
 IF (_nrptgraphrecversion >= 3
  AND validate(rptgraphrec->m_ncontrollimits,0)=1
  AND ((ngraphtype=1) OR (((ngraphtype=2) OR (((ngraphtype=5) OR (ngraphtype=6)) )) )) )
  SET fypos = ((ym * fclupper)+ yb)
  IF (fypos >= ftgrid
   AND fypos <= fbgrid)
   SET rptpen->m_penwidth = rptgraphrec->m_fcontrollimituppersize
   SET rptpen->m_penstyle = rptgraphrec->m_ncontrollimitupperstyle
   SET rptpen->m_rgbcolor = rptgraphrec->m_rgbcontrollimituppercolor
   SET _dummypen = uar_rptsetpen(_hreport,uar_rptcreatepen(_hreport,rptpen))
   SET _rptstat = uar_rptline(_hreport,flgrid,fypos,frgrid,fypos)
  ENDIF
  SET fypos = ((ym * fcllower)+ yb)
  IF (fypos >= ftgrid
   AND fypos <= fbgrid)
   SET rptpen->m_penwidth = rptgraphrec->m_fcontrollimitlowersize
   SET rptpen->m_penstyle = rptgraphrec->m_ncontrollimitlowerstyle
   SET rptpen->m_rgbcolor = rptgraphrec->m_rgbcontrollimitlowercolor
   SET _dummypen = uar_rptsetpen(_hreport,uar_rptcreatepen(_hreport,rptpen))
   SET _rptstat = uar_rptline(_hreport,flgrid,fypos,frgrid,fypos)
  ENDIF
  SET fypos = ((ym * fclmean)+ yb)
  IF (fypos >= ftgrid
   AND fypos <= fbgrid)
   SET rptpen->m_penwidth = rptgraphrec->m_fcontrollimitmeansize
   SET rptpen->m_penstyle = rptgraphrec->m_ncontrollimitmeanstyle
   SET rptpen->m_rgbcolor = rptgraphrec->m_rgbcontrollimitmeancolor
   SET _dummypen = uar_rptsetpen(_hreport,uar_rptcreatepen(_hreport,rptpen))
   SET _rptstat = uar_rptline(_hreport,flgrid,fypos,frgrid,fypos)
  ENDIF
 ENDIF
 SET _dummyfont = uar_rptsetfont(_hreport,_fntrestore)
 SET _dummypen = uar_rptsetpen(_hreport,_penrestore)
 SUBROUTINE getdefaultcolor(nindex)
   DECLARE ncolor = i4
   SET nindex = mod(nindex,18)
   CASE (nindex)
    OF 1:
     SET ncolor = uar_rptencodecolor(0,0,255)
    OF 2:
     SET ncolor = uar_rptencodecolor(0,255,0)
    OF 3:
     SET ncolor = uar_rptencodecolor(255,0,0)
    OF 4:
     SET ncolor = uar_rptencodecolor(0,255,255)
    OF 5:
     SET ncolor = uar_rptencodecolor(255,0,255)
    OF 6:
     SET ncolor = uar_rptencodecolor(255,255,0)
    OF 7:
     SET ncolor = uar_rptencodecolor(128,128,255)
    OF 8:
     SET ncolor = uar_rptencodecolor(128,255,128)
    OF 9:
     SET ncolor = uar_rptencodecolor(255,128,128)
    OF 10:
     SET ncolor = uar_rptencodecolor(128,255,255)
    OF 11:
     SET ncolor = uar_rptencodecolor(255,128,255)
    OF 12:
     SET ncolor = uar_rptencodecolor(255,255,128)
    OF 13:
     SET ncolor = uar_rptencodecolor(0,0,128)
    OF 14:
     SET ncolor = uar_rptencodecolor(0,128,0)
    OF 15:
     SET ncolor = uar_rptencodecolor(128,0,0)
    OF 16:
     SET ncolor = uar_rptencodecolor(0,128,128)
    OF 17:
     SET ncolor = uar_rptencodecolor(128,0,128)
    OF 18:
     SET ncolor = uar_rptencodecolor(128,128,0)
    ELSE
     SET ncolor = uar_rptencodecolor(0,0,0)
   ENDCASE
   RETURN(ncolor)
 END ;Subroutine
 SUBROUTINE getformattednumber(fnumber,sformat)
   DECLARE snumber = vc
   IF (sformat="")
    SET snumber = substring(1,size(build(replace(build(fnumber),"0"," "))),build(fnumber))
    IF (substring(size(snumber),1,snumber)=".")
     SET snumber = substring(1,(size(snumber) - 1),snumber)
    ENDIF
   ELSE
    SET snumber = trim(format(fnumber,nullterm(sformat)),3)
   ENDIF
   RETURN(snumber)
 END ;Subroutine
 SUBROUTINE drawlegendcolorbox(ngraphtype,boxleft,boxtop,boxwidth,boxheight,nscnt)
   IF (ngraphtype=0)
    SET rptpen->m_penwidth = 0.020000
    SET rptpen->m_rgbcolor = rptgraphrec->m_series[(nscnt+ 1)].color
    SET _oldpen = uar_rptsetpen(_hreport,uar_rptcreatepen(_hreport,rptpen))
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,rptgraphrec->m_series[(nscnt+ 1)].color)
    IF (mod(nscnt,2)=0)
     SET _rptstat = uar_rptrect(_hreport,((((boxleft * 2)+ boxwidth)/ 2) - 0.02),((((boxtop * 2)+
      boxheight)/ 2) - 0.02),0.04,0.04,
      0,0)
    ELSE
     SET _rptstat = uar_rptoval(_hreport,(((boxleft * 2)+ boxwidth)/ 2),(((boxtop * 2)+ boxheight)/ 2
      ),0.02,0.02,
      0,0)
    ENDIF
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   ELSEIF (((ngraphtype=1) OR (((ngraphtype=5) OR (ngraphtype=6))
    AND (rptgraphrec->m_series[(nscnt+ 1)].type=1))) )
    SET rptpen->m_penwidth = 0.020000
    SET rptpen->m_rgbcolor = rptgraphrec->m_series[(nscnt+ 1)].color
    SET _oldpen = uar_rptsetpen(_hreport,uar_rptcreatepen(_hreport,rptpen))
    SET _rptstat = uar_rptline(_hreport,boxleft,(((boxtop * 2)+ boxheight)/ 2),(boxleft+ boxwidth),((
     (boxtop * 2)+ boxheight)/ 2))
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,rptgraphrec->m_series[(nscnt+ 1)].color)
    IF (mod(nscnt,2)=0)
     SET _rptstat = uar_rptrect(_hreport,((((boxleft * 2)+ boxwidth)/ 2) - 0.02),((((boxtop * 2)+
      boxheight)/ 2) - 0.02),0.04,0.04,
      0,0)
    ELSE
     SET _rptstat = uar_rptoval(_hreport,(((boxleft * 2)+ boxwidth)/ 2),(((boxtop * 2)+ boxheight)/ 2
      ),0.02,0.02,
      0,0)
    ENDIF
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   ELSE
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,rptgraphrec->m_series[(nscnt+ 1)].color)
    SET _rptstat = uar_rptrect(_hreport,boxleft,boxtop,boxwidth,boxheight,
     0,0)
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   ENDIF
 END ;Subroutine
 SUBROUTINE calcstepsize(datarange,targetsteps)
   DECLARE tempstep = f8
   DECLARE mag = f8
   DECLARE magpow = f8
   DECLARE magmsd = f8
   IF (datarange=0)
    RETURN(0)
   ENDIF
   SET tempstep = (datarange/ targetsteps)
   SET mag = floor(log10(tempstep))
   SET magpow = (10.0** mag)
   SET magmsd = cnvtint(((tempstep/ magpow)+ 0.5))
   IF (magmsd > 5.0)
    SET magmsd = 10.0
   ELSEIF (magmsd > 2.0)
    SET magmsd = 5.0
   ELSEIF (magmsd > 1.0)
    SET magmsd = 2.0
   ENDIF
   RETURN((magmsd * magpow))
 END ;Subroutine
 SUBROUTINE mymod(x,y)
   DECLARE temp = f8
   IF (y=0)
    RETURN(0)
   ENDIF
   SET temp = (x/ y)
   RETURN((y * (temp - floor(temp))))
 END ;Subroutine
END GO
