CREATE PROGRAM bb_lbl_isbt:dba
 RECORD reply(
   1 rpt_list[*]
     2 rpt_filename = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD reclabel(
   1 sproductnbrbarcode = vc
   1 sproductnbrsitecode = c5
   1 sproductnbryear = c2
   1 sproductnbrseq = c6
   1 sproductnbrflagchar = c2
   1 sproductnbrcheckdigit = c1
   1 saborhbarcode = vc
   1 saborhcode = c2
   1 saborhphenotype = c1
   1 saborhextension = c1
   1 sintendeduse = vc
   1 sproductbarcode = vc
   1 sproductcode = c5
   1 sproductdonationtype = c1
   1 sproductdivision = c2
   1 modifier[*]
     2 stext = vc
   1 spropername = vc
   1 sattribute1 = vc
   1 sattribute2 = vc
   1 sattribute3 = vc
   1 sattribute4 = vc
   1 saddinfo1 = vc
   1 saddinfo2 = vc
   1 saddinfo3 = vc
   1 saddinfo4 = vc
   1 sexpirationbarcode = vc
   1 sexpirationjulian = c3
   1 sexpirationcenturyyear = c3
   1 sexpirationhour = c2
   1 sexpirationminute = c2
   1 sexpirationformatted = vc
   1 sorigbloodcenter = vc
   1 sorigaddress1 = vc
   1 sorigreglicnbr = vc
   1 smodbloodcenter = vc
   1 smodaddress1 = vc
   1 smodreglicnbr = vc
   1 nspecialtestingind = i2
   1 string4_1 = vc
   1 string2_4 = vc
   1 string2_5 = vc
   1 string2_6 = vc
   1 string2_7 = vc
   1 string2_8 = vc
 )
 RECORD recspecialtests(
   1 specialtests[*]
     2 special_testing_cd = f8
 )
 DECLARE product_nbr = c20
 DECLARE product_cd = f8 WITH noconstant(0.0)
 DECLARE abo_cd = f8 WITH noconstant(0.0)
 DECLARE rh_cd = f8 WITH noconstant(0.0)
 DECLARE alias_found = i2 WITH noconstant(0)
 DECLARE special_cnt = i2 WITH noconstant(0)
 DECLARE std_aborh_cs = i4 WITH constant(1640)
 DECLARE division_ind = i2 WITH noconstant(0)
 DECLARE serrormsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE nerrorcheck = i2 WITH noconstant(error(serrormsg,1))
 DECLARE sscriptname = c25 WITH constant("BB_LBL_ISBT")
 DECLARE nxpos = i2
 DECLARE nypos = i2
 SET nxpos = 0
 SET nypos = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  p.product_nbr, p.flag_chars, p.product_sub_nbr,
  p.cur_expire_dt_tm, bp.cur_abo_cd, bp.cur_rh_cd
  FROM product p,
   blood_product bp
  PLAN (p
   WHERE (p.product_id=request->product_id))
   JOIN (bp
   WHERE bp.product_id=p.product_id)
  DETAIL
   product_nbr = p.product_nbr, product_cd = p.product_cd
   IF (textlen(trim(p.product_sub_nbr))=0)
    reclabel->sproductdivision = "00", division_ind = 0
   ELSE
    reclabel->sproductdivision = p.product_sub_nbr, division_ind = 1
   ENDIF
   IF (textlen(trim(p.flag_chars))=0)
    reclabel->sproductnbrflagchar = "00"
   ELSE
    reclabel->sproductnbrflagchar = p.flag_chars
   ENDIF
   abo_cd = bp.cur_abo_cd, rh_cd = bp.cur_rh_cd, reclabel->sexpirationjulian = format(cnvtstring(
     julian(p.cur_expire_dt_tm)),"###;P0;"),
   reclabel->sexpirationcenturyyear = substring(2,3,cnvtstring(year(p.cur_expire_dt_tm))), reclabel->
   sexpirationhour = format(cnvtstring(hour(p.cur_expire_dt_tm)),"##;P0;"), reclabel->
   sexpirationminute = format(cnvtstring(minute(p.cur_expire_dt_tm)),"##;P0;")
   IF ((reclabel->sexpirationhour="23")
    AND (reclabel->sexpirationminute="59"))
    reclabel->sexpirationformatted = format(p.cur_expire_dt_tm,"DD MMM YYYY;;D")
   ELSE
    reclabel->sexpirationformatted = format(p.cur_expire_dt_tm,"DD MMM YYYY hh:mm;;Q")
   ENDIF
  WITH nocounter
 ;end select
 SET nerrorcheck = error(serrormsg,0)
 IF (nerrorcheck=0)
  IF (curqual=0)
   CALL errorhandler(sscriptname,"F","PRODUCT select",
    "Unable to find the proper information on the product table to print an ISBT label.")
  ENDIF
 ELSE
  CALL errorhandler(sscriptname,"F","PRODUCT select",serrormsg)
 ENDIF
 SELECT INTO "nl:"
  s.special_testing_cd
  FROM special_testing s
  PLAN (s
   WHERE (s.product_id=request->product_id)
    AND s.active_ind=1)
  DETAIL
   special_cnt = (special_cnt+ 1)
   IF (mod(special_cnt,5)=1)
    stat = alterlist(recspecialtests->specialtests,(special_cnt+ 4))
   ENDIF
   recspecialtests->specialtests[special_cnt].special_testing_cd = s.special_testing_cd
  WITH nocounter
 ;end select
 SET stat = alterlist(recspecialtests->specialtests,special_cnt)
 SET nerrorcheck = error(serrormsg,0)
 IF (nerrorcheck != 0)
  CALL errorhandler(sscriptname,"F","SPECIAL_TESTING select",serrormsg)
 ENDIF
 SET reclabel->sproductnbrsitecode = substring(1,5,product_nbr)
 SET reclabel->sproductnbryear = substring(6,2,product_nbr)
 SET reclabel->sproductnbrseq = substring(8,6,product_nbr)
 SET reclabel->sproductnbrcheckdigit = scalculatecheckdigit(substring(1,13,product_nbr))
 SET reclabel->sproductnbrbarcode = build("*>:=",substring(1,1,product_nbr),">5",substring(2,12,
   product_nbr),reclabel->sproductnbrflagchar,
  "*{f/99/1}")
 SET reclabel->sorigbloodcenter = "Cerner Blood Center"
 SET reclabel->sorigaddress1 = "Kansas City, MO 64117"
 SET reclabel->sorigreglicnbr = "Registration No 1234567 US License No 1234"
 SELECT INTO "nl:"
  cve.code_value
  FROM code_value_extension cve,
   code_value_extension cve2,
   code_value cv
  PLAN (cve
   WHERE cve.code_set=std_aborh_cs
    AND trim(cve.field_name)="ABOOnly_cd"
    AND cnvtreal(cve.field_value)=abo_cd)
   JOIN (cve2
   WHERE cve.code_value=cve2.code_value
    AND trim(cve2.field_name)="RhOnly_cd"
    AND cnvtreal(cve2.field_value)=rh_cd)
   JOIN (cv
   WHERE cv.code_value=cve2.code_value)
  DETAIL
   CASE (cv.cdf_meaning)
    OF "ONEG":
     reclabel->saborhcode = "95"
    OF "OPOS":
     reclabel->saborhcode = "51"
    OF "ANEG":
     reclabel->saborhcode = "06"
    OF "APOS":
     reclabel->saborhcode = "62"
    OF "BNEG":
     reclabel->saborhcode = "17"
    OF "BPOS":
     reclabel->saborhcode = "73"
    OF "ABNEG":
     reclabel->saborhcode = "28"
    OF "ABPOS":
     reclabel->saborhcode = "84"
    OF "O":
     reclabel->saborhcode = "55"
    OF "A":
     reclabel->saborhcode = "66"
    OF "B":
     reclabel->saborhcode = "77"
    OF "AB":
     reclabel->saborhcode = "88"
    OF "BOMBAYNEG":
     reclabel->saborhcode = "G6"
    OF "BOMBAYPOS":
     reclabel->saborhcode = "H6"
    OF "PARABOMBNEG":
     reclabel->saborhcode = "D6"
    OF "PARABOMBPOS":
     reclabel->saborhcode = "E6"
   ENDCASE
  WITH nocounter
 ;end select
 SET nerrorcheck = error(serrormsg,0)
 IF (nerrorcheck=0)
  IF (curqual=0)
   CALL errorhandler(sscriptname,"F","CV, CVE select",
    "Unable to find the proper information on the ABO/Rh table to print an ISBT label.")
  ENDIF
 ELSE
  CALL errorhandler(sscriptname,"F","CV, CVE select",serrormsg)
 ENDIF
 SET reclabel->saborhphenotype = "0"
 SET reclabel->saborhextension = "0"
 SET reclabel->saborhbarcode = build("*>:=%",reclabel->saborhcode,reclabel->saborhphenotype,reclabel
  ->saborhextension,"*{f/99/1}")
 IF (special_cnt > 0)
  SELECT INTO "nl:"
   ipt.isbt_barcode
   FROM bb_isbt_product_type ipt,
    bb_isbt_add_info iai,
    (dummyt d  WITH seq = value(size(recspecialtests->specialtests,5)))
   PLAN (ipt
    WHERE ipt.product_cd=product_cd
     AND ipt.active_ind=1)
    JOIN (d)
    JOIN (iai
    WHERE iai.bb_isbt_product_type_id=ipt.bb_isbt_product_type_id
     AND (iai.attribute_cd=recspecialtests->specialtests[d.seq].special_testing_cd)
     AND iai.bb_isbt_add_info_id > 0.0
     AND iai.active_ind=1)
   DETAIL
    IF (alias_found=0)
     CASE (ipt.isbt_barcode)
      OF "E0013":
       reclabel->spropername = "WHOLE BLOOD",reclabel->sattribute1 = "OPEN",reclabel->saddinfo1 =
       "Approx. 450mL Whole Blood",
       reclabel->saddinfo2 = "plus 63 mL CPD",reclabel->saddinfo3 = "Store at 1 to 6 C",alias_found
        = 1
      OF "E0295":
       reclabel->spropername = "RED BLOOD CELLS",reclabel->sattribute1 = "OPEN",reclabel->sattribute2
        = "ADENINE-SALINE (AS-1) ADDED",
       reclabel->saddinfo1 = "From 450 mL CPD Whole Blood",reclabel->saddinfo2 = "Store at 1 to 6 C",
       alias_found = 1
      OF "E0311":
       reclabel->spropername = "RED BLOOD CELLS",reclabel->sattribute1 =
       "ADENINE-SALINE (AS-1) ADDED",reclabel->sattribute2 = "LEUKOCYTES REDUCED",
       reclabel->saddinfo1 = "From 450 mL CPD Whole Blood",reclabel->saddinfo2 = "Store at 1 to 6 C",
       reclabel->saddinfo3 =
       "Residual Leukocyte Content <5 x 10{lpi/10}{cpi/16}{pos/96/267}{font/99/1}6",
       alias_found = 1
     ENDCASE
     IF (alias_found=1)
      reclabel->sproductcode = ipt.isbt_barcode
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SET nerrorcheck = error(serrormsg,0)
  IF (nerrorcheck != 0)
   CALL errorhandler(sscriptname,"F","BB_ISBT_PRODUCT_TYPE select",serrormsg)
  ENDIF
 ELSE
  SELECT INTO "nl:"
   ipt.isbt_barcode
   FROM bb_isbt_product_type ipt
   PLAN (ipt
    WHERE ipt.product_cd=product_cd
     AND ipt.active_ind=1
     AND  NOT ( EXISTS (
    (SELECT
     iai.bb_isbt_add_info_id
     FROM bb_isbt_add_info iai
     WHERE iai.bb_isbt_product_type_id=ipt.bb_isbt_product_type_id
      AND iai.bb_isbt_add_info_id > 0.0
      AND iai.active_ind=1))))
   DETAIL
    IF (alias_found=0)
     CASE (ipt.isbt_barcode)
      OF "E0001":
       reclabel->spropername = "WHOLE BLOOD",reclabel->saddinfo1 = "Approx. 450 mL plus 63 mL ACD-A",
       reclabel->saddinfo2 = build("Store at 1 to 6",char(176),"C"),
       alias_found = 1
      OF "E0150":
       reclabel->spropername = "RED BLOOD CELLS",reclabel->saddinfo1 = "From 450 mL CPD Whole Blood",
       reclabel->saddinfo2 = "Store at 1 to 6 C",
       alias_found = 1
      OF "E0767":
       reclabel->spropername = "FRESH FROZEN PLASMA",reclabel->saddinfo1 =
       "___mL From ACD-A Whole Blood",reclabel->saddinfo2 = "Store at -18 C or colder",
       alias_found = 1
      OF "E2807":
       reclabel->spropername = "PLATELETS",reclabel->saddinfo1 = "Approx. 45-65 mL",reclabel->
       saddinfo2 = "From 450 mL CPD Whole Blood",
       reclabel->saddinfo3 = "Store at 20 to 24 C",alias_found = 1
      OF "E2940":
       reclabel->spropername = "APHERESIS PLATELETS",reclabel->saddinfo1 =
       "___mL containing approx. ___ mL ACD-A",reclabel->saddinfo2 = "Store at 20 to 24 C",
       alias_found = 1
      OF "E3575":
       reclabel->spropername = "CRYOPRECIPITATED AHF",reclabel->saddinfo1 = build(
        "Store at less than -30",char(176),"C"),alias_found = 1
     ENDCASE
     IF (alias_found=1)
      reclabel->sproductcode = ipt.isbt_barcode
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SET nerrorcheck = error(serrormsg,0)
  IF (nerrorcheck != 0)
   CALL errorhandler(sscriptname,"F","BB_ISBT_PRODUCT_TYPE select",serrormsg)
  ENDIF
 ENDIF
 IF (division_ind=1)
  IF (textlen(trim(reclabel->sattribute1))=0)
   SET reclabel->sattribute1 = "DIVIDED"
  ELSEIF (textlen(trim(reclabel->sattribute2))=0)
   SET reclabel->sattribute2 = "DIVIDED"
  ELSEIF (textlen(trim(reclabel->sattribute3))=0)
   SET reclabel->sattribute3 = "DIVIDED"
  ELSEIF (textlen(trim(reclabel->sattribute4))=0)
   SET reclabel->sattribute4 = "DIVIDED"
  ENDIF
 ENDIF
 IF (alias_found=0)
  CALL errorhandler(sscriptname,"F","BB_ISBT_PRODUCT_TYPE select",
   "Unable to find the a matching product alias to print an ISBT label.")
 ENDIF
 SET reclabel->sproductdonationtype = "0"
 SET reclabel->sproductbarcode = build("*>:=<",reclabel->sproductcode,reclabel->sproductdonationtype,
  reclabel->sproductdivision,"*{f/99/1}")
 SET stat = alterlist(reclabel->modifier,1)
 IF ((reclabel->sproductdonationtype IN ("0", "1", "X", "V", "D",
 "2", "L", "3", "4", "5",
 "R", "S", "T")))
  SET reclabel->sintendeduse = "VOLUNTEER DONOR"
 ELSE
  SET reclabel->sintendeduse = "PAID DONOR"
 ENDIF
 SET reclabel->sexpirationbarcode = build("*>:&>0>5",reclabel->sexpirationcenturyyear,reclabel->
  sexpirationjulian,reclabel->sexpirationhour,reclabel->sexpirationminute,
  "*{f/99/1}")
 SET reclabel->smodbloodcenter = ""
 SET reclabel->smodaddress1 = ""
 SET reclabel->smodreglicnbr = ""
 SET reclabel->nspecialtestingind = 0
 EXECUTE cpm_create_file_name_logical "bb_isbt", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  d1.seq
  FROM (dummyt d1  WITH seq = 1)
  DETAIL
   "{lpi/7}{cpi/9}{pos/34/4}{font/31/3}",
   CALL print(reclabel->sproductnbrbarcode), row + 1,
   "{lpi/7}{cpi/9}{pos/27/41}{font/99/1}",
   CALL print(reclabel->sproductnbrsitecode), row + 1,
   "{lpi/7}{cpi/9}{pos/52/41}{font/99/1}",
   CALL print(reclabel->sproductnbryear), row + 1,
   "{lpi/5}{cpi/6}{pos/65/37}{font/99/1}",
   CALL print(reclabel->sproductnbrseq), row + 1,
   "{lpi/7}{cpi/9}{pos/105/39}{font/99/1}{fr/1}",
   CALL print(reclabel->sproductnbrflagchar), row + 1,
   "{lpi/8}{cpi/9}{pos/129/40}{font/99/1}{fr/0}",
   CALL print(reclabel->sproductnbrcheckdigit), "{lpi/6}{cpi/18}{pos/125/37}{font/9/1}",
   "{box/2/0}", row + 1, reclabel->string2_4 = "PROPERLY IDENTIFY INTENDED RECIPIENT",
   reclabel->string2_5 = "See Circular of Information for Indications,", reclabel->string2_6 =
   "contraindications, cautions and methods of infusion.", reclabel->string2_7 =
   "This product may transmit infectious agents.",
   reclabel->string2_8 = "Rx only", nxpos = ncentertext(reclabel->sorigbloodcenter,"2","9","9"),
   nypos = 58,
   CALL print(calcpos(nxpos,nypos)), "{LPI/9}{CPI/9}{FONT/99/1}", reclabel->sorigbloodcenter,
   row + 1, nxpos = ncentertext(reclabel->sorigaddress1,"2","9","9"), nypos = 66,
   CALL print(calcpos(nxpos,nypos)), "{LPI/9}{CPI/9}{FONT/99/1}", reclabel->sorigaddress1,
   row + 1, nxpos = ncentertext(reclabel->sorigreglicnbr,"2","10","10"), nypos = 75,
   CALL print(calcpos(nxpos,nypos)), "{LPI/10}{CPI/10}{FONT/99/1}", reclabel->sorigreglicnbr,
   row + 1, nxpos = ncentertext(reclabel->string2_4,"2","10","10"), nypos = 86,
   CALL print(calcpos(nxpos,nypos)), "{LPI/10}{CPI/10}{FONT/99/1}", reclabel->string2_4,
   row + 1, nxpos = ncentertext(reclabel->string2_5,"2","12","12"), nypos = 93,
   CALL print(calcpos(nxpos,nypos)), "{LPI/12}{CPI/12}{FONT/99/1}", reclabel->string2_5,
   row + 1, nxpos = ncentertext(reclabel->string2_6,"2","12","12"), nypos = 99,
   CALL print(calcpos(nxpos,nypos)), "{LPI/12}{CPI/12}{FONT/99/1}", reclabel->string2_6,
   row + 1, nxpos = ncentertext(reclabel->string2_7,"2","12","12"), nypos = 105,
   CALL print(calcpos(nxpos,nypos)), "{LPI/12}{CPI/12}{FONT/99/1}", reclabel->string2_7,
   row + 1, nxpos = ncentertext(reclabel->string2_8,"2","10","10"), nypos = 116,
   CALL print(calcpos(nxpos,nypos)), "{LPI/10}{CPI/10}{FONT/99/1}", reclabel->string2_8,
   row + 1, nxpos = ncentertext(reclabel->sintendeduse,"2","5","6"), nypos = 130,
   CALL print(calcpos(nxpos,nypos)), "{LPI/5}{CPI/6}{FONT/99/1}", reclabel->sintendeduse,
   row + 1, "{lpi/7}{cpi/12}{pos/168/4}{font/31/3}",
   CALL print(reclabel->saborhbarcode),
   row + 1, "{lpi/7}{cpi/9}{pos/168/36}{font/99/1}",
   CALL print(build(reclabel->saborhcode,reclabel->saborhphenotype,reclabel->saborhextension)),
   row + 1
   CASE (reclabel->saborhcode)
    OF "51":
     "{lpi/1}{cpi/1}{pos/168/50}{font/99/1}^XGR:OPOS.GRF,1,1"
    OF "95":
     "{lpi/1}{cpi/1}{pos/168/50}{font/99/1}^XGR:ONEG.GRF,1,1"
    OF "06":
     "{lpi/1}{cpi/1}{pos/168/50}{font/99/1}^XGR:ANEG.GRF,1,1"
    OF "62":
     "{lpi/1}{cpi/1}{pos/168/50}{font/99/1}^XGR:APOS.GRF,1,1"
    OF "17":
     "{lpi/1}{cpi/1}{pos/168/50}{font/99/1}^XGR:BNEG.GRF,1,1"
    OF "73":
     "{lpi/1}{cpi/1}{pos/168/50}{font/99/1}^XGR:BPOS.GRF,1,1"
    OF "28":
     "{lpi/1}{cpi/1}{pos/168/50}{font/99/1}^XGR:ABNEG.GRF,1,1"
    OF "84":
     "{lpi/1}{cpi/1}{pos/168/50}{font/99/1}^XGR:ABPOS.GRF,1,1"
   ENDCASE
   row + 1, "{LPI/7}{CPI/12}{POS/34/149}{font/31/3}",
   CALL print(reclabel->sproductbarcode),
   row + 1, "{LPI/7}{CPI/9}{POS/34/181}{FONT/99/1}",
   CALL print(build(reclabel->sproductcode,reclabel->sproductdonationtype,reclabel->sproductdivision)
   ),
   row + 1, "{lpi/8}{cpi/10}{pos/16/196}{font/99/1}",
   CALL print(reclabel->modifier[1].stext),
   row + 1, "{lpi/5}{cpi/7}{pos/16/205}{font/99/1}",
   CALL print(reclabel->spropername),
   row + 1, "{lpi/8}{cpi/10}{pos/16/220}{font/99/1}",
   CALL print(reclabel->sattribute1),
   row + 1, "{lpi/8}{cpi/10}{pos/16/229}{font/99/1}",
   CALL print(reclabel->sattribute2),
   row + 1, "{lpi/8}{cpi/10}{pos/16/238}{font/99/1}",
   CALL print(reclabel->sattribute3),
   row + 1, "{lpi/8}{cpi/10}{pos/16/247}{font/99/1}",
   CALL print(reclabel->sattribute4),
   row + 1, "{lpi/10}{cpi/13}{pos/16/255}{font/99/1}",
   CALL print(reclabel->saddinfo1),
   row + 1, "{lpi/10}{cpi/13}{pos/16/263}{font/99/1}",
   CALL print(reclabel->saddinfo2),
   row + 1, "{lpi/10}{cpi/13}{pos/16/271}{font/99/1}",
   CALL print(reclabel->saddinfo3),
   row + 1, "{lpi/10}{cpi/13}{pos/16/279}{font/99/1}",
   CALL print(reclabel->saddinfo4),
   row + 1, "{LPI/7}{CPI/12}{POS/168/149}{font/31/3}",
   CALL print(reclabel->sexpirationbarcode),
   row + 1, "{LPI/7}{CPI/9}{POS/168/181}{FONT/99/1}",
   CALL print(build(reclabel->sexpirationcenturyyear,reclabel->sexpirationjulian,reclabel->
    sexpirationhour,reclabel->sexpirationminute)),
   row + 1, "{LPI/11}{CPI/11}{POS/259/161}{FONT/99/1}Expiration", row + 1,
   "{LPI/11}{CPI/11}{POS/264/169}{FONT/99/1}Date", row + 1, "{LPI/5}{CPI/6}{POS/168/192}{FONT/99/1}",
   CALL print(reclabel->sexpirationformatted), row + 1, nxpos = ncentertext(reclabel->smodbloodcenter,
    "4","10","10"),
   nypos = 273,
   CALL print(calcpos(nxpos,nypos)), "{LPI/10}{CPI/10}{FONT/99/1}",
   reclabel->smodbloodcenter, row + 1, nxpos = ncentertext(reclabel->smodaddress1,"4","10","10"),
   nypos = 281,
   CALL print(calcpos(nxpos,nypos)), "{LPI/10}{CPI/10}{FONT/99/1}",
   reclabel->smodaddress1, row + 1
  WITH dio = 16, noformfeed, maxcol = 132,
   maxrow = 40
 ;end select
 IF (nerrorcheck=0)
  IF (curqual=0)
   CALL errorhandler(sscriptname,"F","Filename select","Unable to print an ISBT label.")
  ENDIF
 ELSE
  CALL errorhandler(sscriptname,"F","PRODUCT select",serrormsg)
 ENDIF
 SET stat = alterlist(reply->rpt_list,1)
 SET reply->rpt_list[1].rpt_filename = cpm_cfn_info->file_name
 DECLARE ncentertext(p_stext,p_squadrant,p_slpi,p_scpi) = i4
 SUBROUTINE ncentertext(p_stext,p_squadrant,p_slpi,p_scpi)
   DECLARE l_dstringlen = f8
   DECLARE l_dunitlen = f8
   DECLARE l_xpos = i4
   SET l_dstringlen = 0.0
   SET l_dunitlen = 0.0
   SET l_xpos = 0
   SET l_dstringlen = size(p_stext,1)
   IF (p_slpi="9"
    AND p_scpi="9")
    SET l_dunitlen = ((l_dstringlen/ 20.0) * 72.0)
   ELSEIF (p_slpi="5"
    AND p_scpi="6")
    SET l_dunitlen = ((l_dstringlen/ 14.0) * 72.0)
   ELSEIF (p_slpi="7"
    AND p_scpi="9")
    SET l_dunitlen = ((l_dstringlen/ 20.0) * 72.0)
   ELSEIF (p_slpi="10"
    AND p_scpi="10")
    SET l_dunitlen = ((l_dstringlen/ 22.0) * 72.0)
   ELSEIF (p_slpi="12"
    AND p_scpi="12")
    SET l_dunitlen = ((l_dstringlen/ 33.0) * 72.0)
   ENDIF
   IF (((p_squadrant="1") OR (p_squadrant="4")) )
    SET l_xpos = cnvtint(round(((144+ 72) - (l_dunitlen/ 2.0)),0))
   ELSE
    SET l_xpos = cnvtint(round((72 - (l_dunitlen/ 2.0)),0))
   ENDIF
   IF (p_slpi != "5"
    AND p_scpi != "6")
    SET l_xpos = (l_xpos+ 10)
   ENDIF
   RETURN(l_xpos)
 END ;Subroutine
 DECLARE scalculatecheckdigit(p_sproductnumber) = c1
 SUBROUTINE scalculatecheckdigit(p_sproductnumber)
   DECLARE arrchartable[37] = c1
   DECLARE l_nproductnbrlen = i2
   DECLARE l_navgoffset = i2
   DECLARE l_nidx = i2
   DECLARE l_sdigit = c1
   DECLARE l_noffset = i2
   SET l_nproductnbrlen = 0
   SET l_navgoffset = 0
   SET l_nidx = 0
   SET l_sdigit = " "
   SET l_noffset = 0
   SET arrchartable[1] = "0"
   SET arrchartable[2] = "1"
   SET arrchartable[3] = "2"
   SET arrchartable[4] = "3"
   SET arrchartable[5] = "4"
   SET arrchartable[6] = "5"
   SET arrchartable[7] = "6"
   SET arrchartable[8] = "7"
   SET arrchartable[9] = "8"
   SET arrchartable[10] = "9"
   SET arrchartable[11] = "A"
   SET arrchartable[12] = "B"
   SET arrchartable[13] = "C"
   SET arrchartable[14] = "D"
   SET arrchartable[15] = "E"
   SET arrchartable[16] = "F"
   SET arrchartable[17] = "G"
   SET arrchartable[18] = "H"
   SET arrchartable[19] = "I"
   SET arrchartable[20] = "J"
   SET arrchartable[21] = "K"
   SET arrchartable[22] = "L"
   SET arrchartable[23] = "M"
   SET arrchartable[24] = "N"
   SET arrchartable[25] = "O"
   SET arrchartable[26] = "P"
   SET arrchartable[27] = "Q"
   SET arrchartable[28] = "R"
   SET arrchartable[29] = "S"
   SET arrchartable[30] = "T"
   SET arrchartable[31] = "U"
   SET arrchartable[32] = "V"
   SET arrchartable[33] = "W"
   SET arrchartable[34] = "X"
   SET arrchartable[35] = "Y"
   SET arrchartable[36] = "Z"
   SET arrchartable[37] = "*"
   SET l_nproductnbrlen = size(p_sproductnumber,1)
   FOR (l_nidx = 1 TO l_nproductnbrlen)
     SET l_sdigit = substring(l_nidx,1,p_sproductnumber)
     IF (isnumeric(l_sdigit)=1)
      SET l_noffset = (ichar(l_sdigit) - ichar("0"))
     ELSE
      SET l_noffset = ((ichar(l_sdigit) - ichar("A"))+ 10)
     ENDIF
     SET l_navgoffset = mod(((l_navgoffset+ l_noffset) * 2),37)
   ENDFOR
   SET l_noffset = (mod((38 - l_navgoffset),37)+ 1)
   RETURN(arrchartable[l_noffset])
 END ;Subroutine
 DECLARE errorhandler(operationname=c25,operationstatus=c1,targetobjectname=c25,targetobjectvalue=vc)
  = null
 SUBROUTINE errorhandler(operationname,operationstatus,targetobjectname,targetobjectvalue)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = operationname
   SET reply->status_data.subeventstatus[1].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[1].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[1].targetobjectvalue = targetobjectvalue
   GO TO exit_script
 END ;Subroutine
 SET reply->status_data.status = "S"
#exit_script
END GO
