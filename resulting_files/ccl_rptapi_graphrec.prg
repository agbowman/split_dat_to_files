CREATE PROGRAM ccl_rptapi_graphrec
 IF (validate(_nrptgraphrecversion)=0)
  DECLARE _nrptgraphrecversion = i4 WITH persistscript, constant(3), public
 ENDIF
 FREE RECORD rptgraphrec
 RECORD rptgraphrec(
   1 m_ntype = i2
   1 m_fleft = f8
   1 m_ftop = f8
   1 m_fwidth = f8
   1 m_fheight = f8
   1 m_stitle = vc
   1 m_lsttitle
     2 m_sfontname = vc
     2 m_nfontsize = i4
     2 m_rgbfontcolor = i4
     2 m_bold = c1
     2 m_italic = c1
     2 m_underline = c1
     2 m_strikethrough = c1
     2 m_nbackmode = i2
     2 m_rgbbackcolor = i4
   1 m_ssubtitle = vc
   1 m_lstsubtitle
     2 m_sfontname = vc
     2 m_nfontsize = i4
     2 m_rgbfontcolor = i4
     2 m_bold = c1
     2 m_italic = c1
     2 m_underline = c1
     2 m_strikethrough = c1
     2 m_nbackmode = i2
     2 m_rgbbackcolor = i4
   1 m_sxtitle = vc
   1 m_lstxtitle
     2 m_sfontname = vc
     2 m_nfontsize = i4
     2 m_rgbfontcolor = i4
     2 m_bold = c1
     2 m_italic = c1
     2 m_underline = c1
     2 m_strikethrough = c1
     2 m_nbackmode = i2
     2 m_rgbbackcolor = i4
   1 m_sytitle = vc
   1 m_lstytitle
     2 m_sfontname = vc
     2 m_nfontsize = i4
     2 m_rgbfontcolor = i4
     2 m_bold = c1
     2 m_italic = c1
     2 m_underline = c1
     2 m_strikethrough = c1
     2 m_nbackmode = i2
     2 m_rgbbackcolor = i4
   1 m_sytitle2 = vc
   1 m_lstytitle2
     2 m_sfontname = vc
     2 m_nfontsize = i4
     2 m_rgbfontcolor = i4
     2 m_bold = c1
     2 m_italic = c1
     2 m_underline = c1
     2 m_strikethrough = c1
     2 m_nbackmode = i2
     2 m_rgbbackcolor = i4
   1 m_nxtype = i2
   1 m_nytype = i2
   1 m_sxformat = vc
   1 m_syformat = vc
   1 m_series[*]
     2 name = vc
     2 color = i4
     2 symbol = vc
     2 type = i1
     2 x_values[*]
       3 x_i4 = i4
       3 x_f8 = f8
       3 x_dq8 = dq8
     2 y_values[*]
       3 y_i4 = i4
       3 y_f8 = f8
       3 y_dq8 = dq8
   1 m_labels[*]
     2 label = vc
   1 m_nmaxseries = i4
   1 m_nmaxfields = i4
   1 m_fxindex = f8
   1 m_fyindex = f8
   1 m_fxmin = f8
   1 m_fxmax = f8
   1 m_fymin = f8
   1 m_fymax = f8
   1 m_bxmin = i1
   1 m_bxmax = i1
   1 m_bymin = i1
   1 m_bymax = i1
   1 m_bxgrid = i1
   1 m_lstxgrid
     2 m_sfontname = vc
     2 m_nfontsize = i4
     2 m_rgbfontcolor = i4
     2 m_bold = c1
     2 m_italic = c1
     2 m_underline = c1
     2 m_strikethrough = c1
     2 m_nbackmode = i2
     2 m_rgbbackcolor = i4
   1 m_bygrid = i1
   1 m_lstygrid
     2 m_sfontname = vc
     2 m_nfontsize = i4
     2 m_rgbfontcolor = i4
     2 m_bold = c1
     2 m_italic = c1
     2 m_underline = c1
     2 m_strikethrough = c1
     2 m_nbackmode = i2
     2 m_rgbbackcolor = i4
   1 m_blegend = i1
   1 m_nlegendpos = i2
   1 m_lstlegend
     2 m_sfontname = vc
     2 m_nfontsize = i4
     2 m_rgbfontcolor = i4
     2 m_bold = c1
     2 m_italic = c1
     2 m_underline = c1
     2 m_strikethrough = c1
     2 m_nbackmode = i2
     2 m_rgbbackcolor = i4
   1 m_rgblegendbkcolor = i4
   1 m_nlegendbkmode = i2
   1 m_rgbbkcolor = i4
   1 m_nbkmode = i2
   1 m_rgbbordercolor = i4
   1 m_fbordersize = f8
   1 m_nborderstyle = i2
   1 m_bshadow = i1
   1 m_rgbgridbkcolor = i4
   1 m_ngridbkmode = i2
   1 m_rgbgridcolor = i4
   1 m_fgridsize = f8
   1 m_ngridstyle = i2
   1 m_ncontrollimits = i2
   1 m_fcontrollimituppersize = f8
   1 m_ncontrollimitupperstyle = i2
   1 m_rgbcontrollimituppercolor = i4
   1 m_fcontrollimitlowersize = f8
   1 m_ncontrollimitlowerstyle = i2
   1 m_rgbcontrollimitlowercolor = i4
   1 m_fcontrollimitmeansize = f8
   1 m_ncontrollimitmeanstyle = i2
   1 m_rgbcontrollimitmeancolor = i4
   1 m_ncontrollimitlabels = i2
 ) WITH persistscript
END GO
