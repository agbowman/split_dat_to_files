CREATE PROGRAM bhs_inact_end_dt_fix
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 UPDATE  FROM prsnl p
  SET p.active_ind = 1, p.active_status_cd = 194, p.end_effective_dt_tm = p.updt_dt_tm,
   p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = 99999999
  WHERE p.physician_ind=1
   AND p.active_ind=0
   AND ((p.username="Z99999999") OR (((p.username="STU0076MD") OR (((p.username="STU0077MD") OR (((p
  .username="STU0078MD") OR (((p.username="STU0079MD") OR (((p.username="STU0080MD") OR (((p.username
  ="STU0081MD") OR (((p.username="STU0082MD") OR (((p.username="STU0083MD") OR (((p.username=
  "STU0084MD") OR (((p.username="STU0085MD") OR (((p.username="STU0086MD") OR (((p.username=
  "STU0087MD") OR (((p.username="STU0088MD") OR (((p.username="STU0089MD") OR (((p.username=
  "STU0090MD") OR (((p.username="STU0091MD") OR (((p.username="STU0092MD") OR (((p.username=
  "STU0093MD") OR (((p.username="STU0094MD") OR (((p.username="STU0095MD") OR (((p.username=
  "STU0096MD") OR (((p.username="STU0097MD") OR (((p.username="STU0098MD") OR (((p.username=
  "STU0099MD") OR (((p.username="STU0100MD") OR (((p.username="STU0101MD") OR (((p.username=
  "STU0102MD") OR (((p.username="STU0103MD") OR (((p.username="STU0104MD") OR (((p.username=
  "STU0105MD") OR (((p.username="STU0106MD") OR (((p.username="STU0107MD") OR (((p.username=
  "STU0108MD") OR (((p.username="STU0109MD") OR (((p.username="STU0110MD") OR (((p.username=
  "STU0111MD") OR (((p.username="STU0112MD") OR (((p.username="STU0113MD") OR (((p.username=
  "STU0114MD") OR (((p.username="STU0115MD") OR (((p.username="STU0116MD") OR (((p.username=
  "STU0117MD") OR (((p.username="STU0118MD") OR (((p.username="STU0119MD") OR (((p.username=
  "STU0120MD") OR (((p.username="STU0121MD") OR (((p.username="STU0122MD") OR (((p.username=
  "STU0123MD") OR (((p.username="STU0124MD") OR (((p.username="STU0125MD") OR (((p.username=
  "STU0126MD") OR (((p.username="STU0127MD") OR (((p.username="STU0128MD") OR (((p.username=
  "STU0129MD") OR (((p.username="STU0130MD") OR (((p.username="STU0131MD") OR (((p.username=
  "STU0132MD") OR (((p.username="STU0133MD") OR (((p.username="STU0134MD") OR (((p.username=
  "STU0135MD") OR (((p.username="STU0136MD") OR (((p.username="STU0137MD") OR (((p.username=
  "STU0138MD") OR (((p.username="STU0139MD") OR (((p.username="STU0140MD") OR (((p.username=
  "STU0141MD") OR (((p.username="STU0142MD") OR (((p.username="SURGERY") OR (((p.username="TEN") OR (
  ((p.username="TEST2") OR (((p.username="TESTKIM") OR (((p.username="THORACIC") OR (((p.username=
  "TRAUMA") OR (((p.username="UROLOGY") OR (p.username="YELLOW")) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
 ;end update
 COMMIT
END GO
