CREATE PROGRAM djh_phys_faxnbrs:dba
 PROMPT
  "Last Name" = "*",
  "Output to Screen/Printer" = "MINE"
  WITH prompt2, outdev
 EXECUTE bhs_check_domain:dba
 DECLARE ms_domain = vc WITH protect, noconstant("")
 DECLARE localflg = c5
 SET lncnt = 0
 SELECT INTO  $OUTDEV
  d.description, d.name, d.device_type_cd,
  d_device_type_disp = uar_get_code_display(d.device_type_cd), rd.area_code, rd.exchange,
  rd.phone_suffix, rd.device_address_type_cd, rd.device_cd,
  rd.phone_mask_id, rd.remote_dev_type_id, dxr.parent_entity_name
  FROM remote_device rd,
   device d,
   device_xref dxr
  PLAN (d
   WHERE (cnvtupper(d.name)= $PROMPT2))
   JOIN (rd
   WHERE d.device_cd=rd.device_cd
    AND rd.exchange > " ")
   JOIN (dxr
   WHERE d.device_cd=dxr.device_cd
    AND dxr.parent_entity_name="PRSNL")
  ORDER BY d.description
  HEAD PAGE
   "{cpi/12}", xcol = 76, ycol = 30,
   CALL print(calcpos(xcol,ycol)), "ln", row + 1,
   ycol = (ycol+ 10),
   CALL print(calcpos(xcol,ycol)), "nbr",
   row + 1, xcol = (xcol+ 50),
   CALL print(calcpos(xcol,ycol)),
   "Name", xcol = (xcol+ 115),
   CALL print(calcpos(xcol,ycol)),
   "FAX Number", xcol = (xcol+ 85),
   CALL print(calcpos(xcol,ycol)),
   "Local", row + 1, xcol = 72,
   ycol = (ycol+ 10), line = fillstring(50,"-"),
   CALL print(calcpos(xcol,ycol)),
   line, row + 1
  DETAIL
   lncnt = (lncnt+ 1), xcol = 72, ycol = (ycol+ 10),
   CALL print(calcpos(xcol,ycol)), lncnt"####", xcol = 72,
   xcol = (xcol+ 30),
   CALL print(calcpos(xcol,ycol)), d.name"#########################",
   xcol = (xcol+ 140),
   CALL print(calcpos(xcol,ycol)), rd.area_code"###",
   xcol = (xcol+ 25),
   CALL print(calcpos(xcol,ycol)), rd.exchange"###",
   xcol = (xcol+ 25),
   CALL print(calcpos(xcol,ycol)), rd.phone_suffix"####",
   localflg =
   IF (rd.local_flag=1) "Yes"
   ELSE "No"
   ENDIF
   , xcol = (xcol+ 40),
   CALL print(calcpos(xcol,ycol)),
   localflg, row + 1
   IF (row >= 64)
    BREAK
   ENDIF
  FOOT PAGE
   "{cpi/15}", row + 1, xcol = 72,
   ycol = 700,
   CALL print(calcpos((xcol+ 10),ycol)), curprog,
   CALL print(calcpos((xcol+ 134),ycol)), curdate,
   CALL print(calcpos((xcol+ 190),ycol)),
   curnode
   IF (gl_bhs_prod_flag=1)
    ms_domain = "PROD"
   ELSEIF (curnode="casdtest")
    ms_domain = "BUILD"
   ELSEIF (curnode="casbtest")
    ms_domain = "CERT"
   ELSEIF (curnode="casetest")
    ms_domain = "TEST"
   ELSE
    ms_domain = "domain?"
   ENDIF
   CALL print(calcpos((xcol+ 250),ycol)), ms_domain,
   CALL print(calcpos((xcol+ 320),ycol)),
   "Page:", curpage"{cpi/12}"
  WITH dio = postscript, maxrow = 66
 ;end select
END GO
