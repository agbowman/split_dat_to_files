CREATE PROGRAM dcp_parse_text:dba
 IF (validate(blob)=0)
  RECORD blob(
    1 line = vc
    1 cnt = i2
    1 qual[*]
      2 line = vc
      2 sze = i4
  )
 ENDIF
 DECLARE l = i4 WITH private, noconstant(0)
 DECLARE h = i4 WITH private, noconstant(0)
 DECLARE cr = i4 WITH private, noconstant(0)
 DECLARE length = i4 WITH private, noconstant(0)
 DECLARE maxlength = i4 WITH private, noconstant(0)
 DECLARE check_blob = vc WITH private, noconstant(fillstring(65535," "))
 DECLARE lf = vc WITH private, noconstant(concat(char(13),char(10)))
 DECLARE c = i4 WITH private, noconstant(0)
 SET check_blob = ""
 SET check_blob =  $1
 SET maxlength =  $2
 SET check_blob = concat(trim(check_blob),lf)
 SET blob->cnt = 0
 SET cr = findstring(lf,check_blob)
 SET length = textlen(check_blob)
 WHILE (cr > 0)
   SET blob->line = substring(1,(cr - 1),check_blob)
   SET check_blob = substring((cr+ 2),length,check_blob)
   SET blob->cnt = (blob->cnt+ 1)
   SET stat = alterlist(blob->qual,blob->cnt)
   SET blob->qual[blob->cnt].line = trim(blob->line)
   SET blob->qual[blob->cnt].sze = textlen(trim(blob->line))
   SET cr = findstring(lf,check_blob)
 ENDWHILE
 FOR (j = 1 TO blob->cnt)
   WHILE ((blob->qual[j].sze > maxlength))
     SET h = l
     SET c = maxlength
     WHILE (c > 0)
      IF (substring(c,1,blob->qual[j].line) IN (" ", "-"))
       SET l = (l+ 1)
       SET stat = alterlist(pt->lns,l)
       SET pt->lns[l].line = substring(1,c,blob->qual[j].line)
       SET blob->qual[j].line = substring((c+ 1),(blob->qual[j].sze - c),blob->qual[j].line)
       SET c = 1
      ENDIF
      SET c = (c - 1)
     ENDWHILE
     IF (h=l)
      SET l = (l+ 1)
      SET stat = alterlist(pt->lns,l)
      SET pt->lns[l].line = substring(1,maxlength,blob->qual[j].line)
      SET blob->qual[j].line = substring((maxlength+ 1),(blob->qual[j].sze - maxlength),blob->qual[j]
       .line)
     ENDIF
     SET blob->qual[j].sze = size(trim(blob->qual[j].line))
   ENDWHILE
   SET l = (l+ 1)
   SET stat = alterlist(pt->lns,l)
   SET pt->lns[l].line = substring(1,blob->qual[j].sze,blob->qual[j].line)
   SET pt->line_cnt = l
 ENDFOR
END GO
