CREATE PROGRAM cclcost:dba
 PAINT
 CALL clear(1,1)
 CALL box(1,1,9,80)
 CALL line(3,1,80,xhor)
 CALL text(2,5,concat("CCL Cost HNAM Server Report for ",cursys))
 CALL text(4,5,"Server")
 CALL text(5,5,"Sort: (T)ime (P)rog (C)pu (E)la (N)one?")
 CALL text(6,5,"Option: (C)ost (E)rror (A)ll")
 CALL text(7,5,"Program name")
 CALL text(8,5,"Number of Instances")
 DECLARE instance_digit = i4 WITH noconstant(cclcost_getserver(0))
 SET p_server = curaccept
 CALL accept(5,45,"p;cu","N"
  WHERE curaccept IN ("T", "P", "N", "C", "E"))
 SET p_sort = curaccept
 CALL accept(6,45,"p;cu","A"
  WHERE curaccept IN ("A", "E", "C"))
 SET p_option = curaccept
 CALL accept(7,45,"p(30);cu","*")
 SET p_program = curaccept
 CALL accept(8,45,"99",1
  WHERE curaccept > 0)
 SET p_instance = curaccept
 SET stat = 0
 DECLARE cost_fname = c50
 DECLARE temp_fname = c50
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
     IF (p_option="A"
      AND append_mode=0)
      WHERE r.line IN ("* Cpu *", "CCL LOG*", "CCL CACHE*", "%CCL-*", "%SYS-*",
      "* Prcname=*", "DISCERN EXPLORER*")
      WITH counter, noheading
     ELSEIF (p_option="A"
      AND append_mode=1)
      WHERE r.line IN ("* Cpu *", "CCL LOG*", "CCL CACHE*", "%CCL-*", "%SYS-*",
      "* Prcname=*", "DISCERN EXPLORER*")
      WITH counter, append, noheading
     ELSEIF (p_option="E"
      AND append_mode=0)
      WHERE r.line IN ("%CCL-*", "%SYS-*", "* Prcname=*")
      WITH counter, noheading
     ELSEIF (p_option="E"
      AND append_mode=1)
      WHERE r.line IN ("%CCL-*", "%SYS-*", "* Prcname=*")
      WITH counter, append, noheading
     ELSEIF (p_option="C"
      AND append_mode=0)
      WHERE r.line IN ("* Cpu *", "* Prcname=*")
      WITH counter, noheading
     ELSEIF (p_option="C"
      AND append_mode=1)
      WHERE r.line IN ("* Cpu *", "* Prcname=*")
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
  IF (p_sort="T")
   ORDER BY substring(1,12,r.line)
  ELSEIF (p_sort="P")
   ORDER BY substring(14,40,r.line), substring(1,12,r.line)
  ELSEIF (p_sort="C")
   ORDER BY substring(57,5,r.line) DESC, substring(1,12,r.line)
  ELSEIF (p_sort="E")
   ORDER BY substring(66,5,r.line) DESC, substring(1,12,r.line)
  ELSE
  ENDIF
  r.line, costdesc = substring(44,4,r.line), cpu = cnvtreal(substring(57,5,r.line)),
  cst = cnvtreal(substring(48,5,r.line)), ela = cnvtreal(substring(66,6,r.line))
  FROM rtlt r
  WHERE r.line=patstring(concat("*",trim(p_program),"*"))
   AND r.line != " "
  DETAIL
   r.line, row + 1
  FOOT REPORT
   "==========================================================================================================================",
   row + 1, " Total Number of Primary Scripts= ",
   count(cst
   WHERE costdesc="Cost")"############", row + 1, " Cost    Sum= ",
   sum(cst
   WHERE costdesc="Cost")"#########.###", " Avg= ", avg(cst
   WHERE costdesc="Cost")"#########.###",
   " Min= ", min(cst
   WHERE costdesc="Cost")"#########.###", " Max= ",
   max(cst
   WHERE costdesc="Cost")"#########.###", row + 1, " Cpu Sec Sum= ",
   sum(cpu
   WHERE costdesc="Cost")"#########.###", " Avg= ", avg(cpu
   WHERE costdesc="Cost")"#########.###",
   " Min= ", min(cpu
   WHERE costdesc="Cost")"#########.###", " Max= ",
   max(cpu
   WHERE costdesc="Cost")"#########.###", row + 1, " Ela Sec Sum= ",
   sum(ela
   WHERE costdesc="Cost")"#########.###", " Avg= ", avg(ela
   WHERE costdesc="Cost")"#########.###",
   " Min= ", min(ela
   WHERE costdesc="Cost")"#########.###", " Max= ",
   max(ela
   WHERE costdesc="Cost")"#########.###", row + 1
  WITH counter, maxcol = 140, noformfeed,
   maxrow = 1
 ;end select
 FREE DEFINE rtl
 SET stat = remove(cost_fname)
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
