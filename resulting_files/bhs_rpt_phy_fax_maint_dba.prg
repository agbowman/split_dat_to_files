CREATE PROGRAM bhs_rpt_phy_fax_maint:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Type" = "",
  "Physician Name" = "",
  "Long Distance" = "0",
  "Area" = "",
  "Exchange" = "",
  "Number" = ""
  WITH outdev, type, phyname,
  longdistanceflag, area, exchange,
  number
 DECLARE s_physicianname = vc
 DECLARE s_fax = vc WITH protect, noconstant(" ")
 DECLARE s_fax1 = vc WITH protect, noconstant(" ")
 IF (( $TYPE="1"))
  SELECT INTO  $OUTDEV
   p.name_full_formatted
   FROM prsnl p
   WHERE p.person_id=cnvtreal( $PHYNAME)
   DETAIL
    s_physicianname = p.name_full_formatted
   WITH nocounter
  ;end select
  SET s_fax = trim(concat(trim( $AREA)," ",trim( $EXCHANGE),"-",trim( $NUMBER)))
  IF (( $LONGDISTANCEFLAG="1"))
   SET s_fax = concat("1 ",s_fax)
  ENDIF
  INSERT  FROM bhs_physician_fax_list b
   SET b.active_ind = 1, b.fax = trim(replace(s_fax,"  "," ")), b.name = s_physicianname,
    b.person_id = cnvtreal( $PHYNAME), b.practice = " ", b.update_dt_tm = cnvtdatetime(curdate,
     curtime),
    b.updt_id = reqinfo->updt_id
   WITH nocounter
  ;end insert
 ELSEIF (( $TYPE="2"))
  UPDATE  FROM bhs_physician_fax_list b
   SET b.active_ind = 0
   WHERE b.person_id=cnvtreal( $PHYNAME)
   WITH nocounter
  ;end update
 ENDIF
 COMMIT
END GO
