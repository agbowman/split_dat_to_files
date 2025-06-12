CREATE PROGRAM cclprotopt2:dba
 PROMPT
  "Output name (MINE) : " = "MINE",
  "Object type (P) : " = "P",
  "Object Name (*) : " = "*",
  "RdbOptimizer begin (0) : " = 0,
  "RdbOptimizer end (15) : " = 15
 IF (validate(cclprotopt2_rec)=0)
  RECORD cclprotopt2_rec(
    1 scripts[*]
      2 script_name = vc
      2 group = i1
      2 script_optimizer = i1
      2 query_optimizer[50] = i1
  )
 ENDIF
 SELECT INTO  $1
  object = substring(1,1,g.rest), object_name = substring(2,30,g.rest), group = ichar(substring(32,1,
    g.rest)),
  rdboptval = evaluate(substring(274,6,g.data),"<sec1>",ichar(substring(248,1,g.data)),0), rdboptqry
   = evaluate(substring(274,6,g.data),"<sec1>",substring(249,25,g.data),fillstring(25,char(0)))
  FROM (dgeneric g  WITH access_code = "5", user_code = none)
  WHERE g.platform="H0000"
   AND g.rcode="5"
   AND g.rest=patstring(concat( $2,trim( $3),"*"))
   AND evaluate(substring(274,6,g.data),"<sec1>",band(ichar(substring(248,1,g.data)),15),0) BETWEEN
   $4 AND  $5
  HEAD REPORT
   pcnt = 0, stat = 0, num1 = 0,
   num2 = 0, val1 = 0, val2 = 0,
   num = 0, val = 0, stat = 0,
   col 0,
   CALL print(concat("ObjectName,RdbOptDefault,",
    "Q0,Q1,Q2,Q3,Q4,Q5,Q6,Q7,Q8,Q9,Q10,Q11,Q12,Q13,Q14,Q15,Q16,Q17,Q18,Q19,Q20,Q21,Q22,Q23,Q24,Q25,Q26,Q27,Q28,Q29,",
    "Q30,Q31,Q32,Q33,Q34,Q35,Q36,Q37,Q38,Q39,Q40,Q41,Q42,Q43,Q44,Q45,Q46,Q47,Q48,Q49,Q50")), row + 1
  DETAIL
   IF (mod(pcnt,100)=0)
    stat = alterlist(cclprotopt2_rec->scripts,(pcnt+ 100))
   ENDIF
   pcnt += 1, cclprotopt2_rec->scripts[pcnt].script_name = object_name, cclprotopt2_rec->scripts[pcnt
   ].group = group,
   cclprotopt2_rec->scripts[pcnt].script_optimizer = rdboptval, val1 = (band(rdboptval,240)/ 16),
   val2 = band(rdboptval,15),
   col 0,
   CALL print(concat(trim(object_name),",",format(val2,"#"),",")),
   CALL print(format(val1,"#")),
   ","
   FOR (num = 1 TO 25)
     val = ichar(substring(num,1,rdboptqry)), num2 = (num * 2), num1 = (num2 - 1),
     val1 = (band(val,240)/ 16), val2 = band(val,15), cclprotopt2_rec->scripts[pcnt].query_optimizer[
     num1] = val1,
     cclprotopt2_rec->scripts[pcnt].query_optimizer[num2] = val2,
     CALL print(format(val1,"#")), ",",
     CALL print(format(val2,"#"))
     IF (num != 25)
      CALL print(",")
     ENDIF
   ENDFOR
   row + 1
  FOOT REPORT
   stat = alterlist(cclprotopt2_rec->scripts,pcnt)
  WITH maxcol = 220, maxrow = 1, noformfeed
 ;end select
END GO
