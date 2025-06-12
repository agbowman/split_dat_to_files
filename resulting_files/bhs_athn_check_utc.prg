CREATE PROGRAM bhs_athn_check_utc
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v1 = vc WITH protect, noconstant("")
  DECLARE v2 = vc WITH protect, noconstant("")
  DECLARE v3 = vc WITH protect, noconstant("")
  DECLARE v4 = vc WITH protect, noconstant("")
  DECLARE v5 = vc WITH protect, noconstant("")
  SELECT INTO value(moutputdevice)
   FROM dummyt d
   PLAN (d
    WHERE d.seq > 0)
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1, v1 = build("<CURTIMEZONE>",curtimezone,"</CURTIMEZONE>"), col + 1,
    v1, row + 1, v2 = build("<CURTIMEZONEAPP>",curtimezoneapp,"</CURTIMEZONEAPP>"),
    col + 1, v2, row + 1,
    v3 = build("<CURTIMEZONEDEF>",curtimezonedef,"</CURTIMEZONEDEF>"), col + 1, v3,
    row + 1, v4 = build("<CURTIMEZONESYS>",curtimezonesys,"</CURTIMEZONESYS>"), col + 1,
    v4, row + 1, v5 = build("<CURUTC>",curutc,"</CURUTC>"),
    col + 1, v5, row + 1,
    col + 1, "</ReplyMessage>", row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
END GO
