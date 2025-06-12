CREATE PROGRAM ccltimezone:dba
 PROMPT
  "Timezone start index:        " = 1,
  "Tiemzone end index:          " = 999,
  "Timezone mode start 1-8 (8): " = 8,
  "Timezone mode end 1-8 (8):   " = 8
 CALL echo("<mode> = 1, return short display name")
 CALL echo("<mode> = 2, return long standard name")
 CALL echo("<mode> = 3, return short standard name")
 CALL echo("<mode> = 4, return long daylight name")
 CALL echo("<mode> = 5, return short daylight name")
 CALL echo("<mode> = 6, return long daylight name if daylight on else long standard name ")
 CALL echo("<mode> = 7, return short daylight name if daylight on else short standard name")
 CALL echo("<mode> = 8, return default timezone name (this is default if not specified)")
 RECORD rec(
   1 zone = c64
   1 index = i4
   1 offset = i4
   1 daylight = i4
   1 date1 = dq8
   1 date2 = dq8
 )
 FOR (index =  $1 TO  $2)
  SET rec->index = index
  FOR (mode =  $3 TO  $4)
   SET rec->zone = datetimezonebyindex(rec->index,rec->offset,rec->daylight,mode,rec->date1)
   IF ((rec->zone != " "))
    CALL echo(build("app index=",rec->index,", mode=",mode,", zone=",
      rec->zone,", offset=",rec->offset,", daylight=",rec->daylight))
   ENDIF
  ENDFOR
 ENDFOR
END GO
