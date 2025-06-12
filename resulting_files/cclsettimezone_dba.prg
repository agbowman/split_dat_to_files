CREATE PROGRAM cclsettimezone:dba
 PROMPT
  "Enter timezone to set (SYSTEM,EST,CST): " = "SYSTEM"
 SET time_zone = cnvtupper( $1)
 RECORD tz(
   1 m_id = c64
   1 m_offset = i4
   1 m_daylight = i4
   1 m_tz[64] = c64
 )
 IF (curutc)
  DECLARE uar_datesettimezone(p1=vc(ref)) = null WITH image_axp = "datertl", image_aix =
  "libdate.a(libdate.o)", uar = "DateSetTimeZone"
  DECLARE uar_dategettimezone(p1=vc(ref)) = null WITH image_axp = "datertl", image_aix =
  "libdate.a(libdate.o)", uar = "DateGetTimeZone"
  DECLARE uar_dategetsystemtimezone(p1=vc(ref)) = null WITH image_axp = "datertl", image_aix =
  "libdate.a(libdate.o)", uar = "DateGetSystemTimeZone"
  SET tz->m_id = concat(trim(time_zone),char(0))
  IF (time_zone="SYSTEM")
   CALL uar_dategetsystemtimezone(tz)
  ENDIF
  CALL uar_datesettimezone(tz)
  CALL uar_dategettimezone(tz)
  CALL echo(build("timezone=",trim(tz->m_id),",offset=",tz->m_offset,",curtimezone=",
    curtimezone))
 ENDIF
END GO
