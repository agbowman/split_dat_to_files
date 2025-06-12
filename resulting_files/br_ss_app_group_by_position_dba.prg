CREATE PROGRAM br_ss_app_group_by_position:dba
 FREE RECORD temp
 RECORD temp(
   1 pcnt = i2
   1 pqual[*]
     2 position_cd = f8
     2 position = vc
     2 acnt = i2
     2 aqual[*]
       3 app_group_cd = f8
       3 app_group = vc
 )
 SELECT INTO "nl:"
  FROM code_value c,
   application_group a,
   code_value c2
  PLAN (c
   WHERE c.active_ind=1)
   JOIN (a
   WHERE a.position_cd=c.code_value)
   JOIN (c2
   WHERE c2.code_value=a.app_group_cd
    AND c2.active_ind=1)
  ORDER BY cnvtupper(c.display), cnvtupper(c2.display)
  HEAD REPORT
   pcnt = 0, acnt = 0
  HEAD c.code_value
   acnt = 0, pcnt = (pcnt+ 1), temp->pcnt = pcnt,
   stat = alterlist(temp->pqual,pcnt), temp->pqual[pcnt].position_cd = c.code_value, temp->pqual[pcnt
   ].position = c.display,
   temp->pqual[pcnt].position = replace(temp->pqual[pcnt].position,",",";")
  HEAD a.app_group_cd
   acnt = (acnt+ 1), temp->pqual[pcnt].acnt = acnt, stat = alterlist(temp->pqual[pcnt].aqual,acnt),
   temp->pqual[pcnt].aqual[acnt].app_group_cd = a.app_group_cd, temp->pqual[pcnt].aqual[acnt].
   app_group = c2.display, temp->pqual[pcnt].aqual[acnt].app_group = replace(temp->pqual[pcnt].aqual[
    acnt].app_group,",",";")
  WITH nocounter
 ;end select
 DECLARE app_string = vc
 DECLARE header_string = vc
 SELECT INTO "cer_temp:pos_app_group.csv"
  FROM dummyt d
  PLAN (d)
  HEAD REPORT
   header_string = "Position,Application Group"
  DETAIL
   col 0, header_string, row + 1
   FOR (x = 1 TO temp->pcnt)
    FOR (y = 1 TO temp->pqual[x].acnt)
      IF (y=1)
       app_string = build(temp->pqual[x].position,",",temp->pqual[x].aqual[y].app_group)
      ELSE
       app_string = build(",",temp->pqual[x].aqual[y].app_group)
      ENDIF
      col 0, app_string, row + 1
    ENDFOR
    ,row + 1
   ENDFOR
  WITH nocounter, format = pcformat, maxrow = 400,
   maxcol = 400
 ;end select
END GO
