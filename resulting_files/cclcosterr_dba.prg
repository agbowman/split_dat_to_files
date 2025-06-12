CREATE PROGRAM cclcosterr:dba
 PAINT
 CALL clear(1,1)
 CALL box(1,1,9,80)
 CALL line(3,1,80,xhor)
 CALL text(2,5,concat("CCLCOSTERR HNAM Server Report for ",cursys))
 CALL text(4,5,"Server")
 CALL text(5,5,"Sort: (1) (2) (3) (4)?")
 CALL text(6,5,"(1:typ,err) (2:nonunique typ,err,prg) (3:typ,err,prg) (4:prg,typ,err)")
 CALL text(7,5,"Program name")
 CALL text(8,5,"Number of Instances")
 DECLARE instance_digit = i4 WITH noconstant(cclcost_getserver(0))
 SET p_server = curaccept
 CALL accept(5,45,"9",1
  WHERE curaccept IN (1, 2, 3, 4))
 SET p_sort = curaccept
 CALL accept(7,45,"p(30);cu","*")
 SET p_program = curaccept
 CALL accept(8,45,"99",1
  WHERE curaccept > 0)
 SET p_instance = curaccept
 SET stat = 0
 DECLARE cost_fname = c50
 DECLARE temp_fname = c50
 FREE DEFINE rtl
 SET cost_fname = concat("cclcost",format(curtime2,"hhmmss;2;m"),".log")
 SET append_mode = 0
 FOR (num = 1 TO p_instance)
   CASE (instance_digit)
    OF 2:
     SET temp_fname = concat(substring(1,11,p_server),format(num,"##;rp0"),substring(14,7,p_server))
    OF 4:
     SET temp_fname = concat(substring(1,11,p_server),format(num,"####;rp0"),substring(16,7,p_server)
      )
   ENDCASE
   CALL text(20,1,temp_fname)
   IF (findfile(trim(temp_fname)))
    DEFINE rtl trim(temp_fname)
    SELECT
     IF (append_mode=0)
      WHERE r.line="%*"
       AND r.line=patstring(concat("*",trim(p_program),"*"))
      WITH counter, noheading
     ELSEIF (append_mode=1)
      WHERE r.line="%*"
       AND r.line=patstring(concat("*",trim(p_program),"*"))
      WITH counter, append, noheading
     ELSE
     ENDIF
     INTO trim(cost_fname)
     r.line
     FROM rtlt r
     WITH counter, noheading
    ;end select
    FREE DEFINE rtl
    SET append_mode = 1
   ENDIF
 ENDFOR
 FREE DEFINE rtl
 DEFINE rtl trim(cost_fname)
 SELECT
  IF (p_sort=1)DISTINCT
   ORDER BY typ, err
  ELSEIF (p_sort=2)
   ORDER BY typ, err, prg
  ELSEIF (p_sort=3)DISTINCT
   ORDER BY typ, err, prg
  ELSEIF (p_sort=4)DISTINCT
   ORDER BY prg, typ, err
  ELSE
  ENDIF
  typ = substring(2,3,r.line), sev = substring(6,1,r.line), err = cnvtint(substring(8,(findstring("-",
     substring(8,5,r.line)) - 1),r.line))"###;rp0",
  prg = substring(1,31,substring((findstring("-",substring(8,10,r.line))+ 8),((findstring("(",
     substring(8,50,r.line)) - findstring("-",substring(8,10,r.line))) - 1),r.line)), msg = substring
  ((findstring("}",r.line)+ 1),100,r.line)
  FROM rtlt r
  WHERE r.line="%*"
  ORDER BY typ, err, prg
  WITH nocounter
 ;end select
 FREE DEFINE rtl
 SUBROUTINE (cclcost_getserver(p1=i4) =i4)
   DECLARE p_com = c80
   DECLARE numdigit = i4 WITH noconstant(2)
   SET help = pos(9,10,14,60)
   IF (cursys="AIX")
    SET p_com = concat("rm ",trim(cnvtlower(curuser)),"rtl.out")
    CALL dcl(p_com,size(trim(p_com)),0)
    SET p_com = concat("ls rtlsrv*.log >> ",trim(cnvtlower(curuser)),"rtl.out")
   ELSE
    SET p_com = concat("$dir ccluserdir:rtlsrv*.log/output=",trim(curuser),"rtl.out/col=1")
   ENDIF
   CALL dcl(p_com,size(trim(p_com)),0)
   FREE DEFINE rtl
   DEFINE rtl concat(trim(curuser),"rtl.out")
   SET help =
   SELECT DISTINCT INTO "nl:"
    log = substring(1,30,r.line), id = substring(7,4,r.line), server =
    IF (cnvtint(substring(7,4,r.line)) < 1024) cnvtint(substring(7,4,r.line))
    ELSEIF (cnvtint(substring(7,4,r.line)) < 2048) (cnvtint(substring(7,4,r.line)) - 1024)
    ELSE (cnvtint(substring(7,4,r.line)) - 2048)
    ENDIF
    "####",
    instance = substring(12,2,r.line)
    FROM rtlt r
    WHERE ((r.line="RTLSRV*") OR (r.line="rtlsrv*"))
    ORDER BY substring(1,20,r.line)
    WITH nocounter
   ;end select
   WITH nocounter
   CALL accept(4,45,"p(30);fcu"," ")
   SET p_file = curaccept
   FREE DEFINE rtl
   SET help = off
   SET numdigit = 4
   RETURN(numdigit)
 END ;Subroutine
END GO
