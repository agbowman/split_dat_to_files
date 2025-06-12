CREATE PROGRAM djh_prsnl_std
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE test_vc = vc WITH noconstant(""), protect
 DECLARE prfx_yymm = vc
 SET prfx_yymm = concat("Y",format(curdate,"YYMM;;D"))
 SELECT INTO  $OUTDEV
  p.active_ind, p.username, p.active_status_cd,
  p_active_status_disp = uar_get_code_display(p.active_status_cd), p.updt_dt_tm, p.updt_id,
  p.test_vc
  FROM prsnl p
  WHERE ((p.username="*09757") OR (p.position_cd=457))
  DETAIL
   IF (p.updt_id=99999999)
    test_vc = "Changed Active Access Codes"
   ELSE
    test_vc = "Not Changed"
   ENDIF
   ousername15 = format(p.username,"###############"), nusername20 = concat(prfx_yymm,ousername15),
   namefull35 = format(p.name_full_formatted,"###################################"),
   fupdtm = format(p.updt_dt_tm,"@SHORTDATETIME"), col 1, p.active_ind,
   col + 1, p.active_status_cd, col + 1,
   ousername15, col + 1, namefull35,
   col + 1, fupdtm, col + 1,
   p.updt_id, col + 1, test_vc,
   row + 1
  WITH maxrec = 1000, maxcol = 300, maxrow = 500,
   seperator = " ", format
 ;end select
END GO
