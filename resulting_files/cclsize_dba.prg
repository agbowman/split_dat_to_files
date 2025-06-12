CREATE PROGRAM cclsize:dba
 PROMPT
  "Size of Objects of Type (P,E,V,M) : " = "P",
  "Min size to show (100): " = 100
 SET minshow =  $2
 SELECT INTO mine
  d.object, d.object_name, d.datestamp,
  d.timestamp, d.binary_cnt, ccl_version = mod(d.ccl_version,100),
  ccl_reg =
  IF (d.ccl_version > 100) "N"
  ELSE "Y"
  ENDIF
  FROM dprotect d
  WHERE d.object=patstring(cnvtupper( $1))
  ORDER BY d.binary_cnt DESC, d.object_name
  HEAD REPORT
   "CCLSIZE Report of ccl objects(",  $1, ") binary size in blocks (min show size = ",
   minshow"#####", ")", row + 1,
   "Object Name", col 32, "BinarySize",
   col 45, "CclVersion", col 57,
   "Reg", col 65, "Type",
   col 75, "Date", col 85,
   "AppVersion", row + 1,
   "============================================================================================================",
   row + 1, cnt_over_0 = 0, cnt_over_25 = 0,
   cnt_over_50 = 0, cnt_over_75 = 0, cnt_over_100 = 0,
   cnt_over_150 = 0, cnt_over_200 = 0, cnt_over_250 = 0,
   cnt_over_500 = 0, tot = 0
  DETAIL
   IF (d.binary_cnt > minshow)
    d.object_name, col 32, d.binary_cnt,
    col 45, ccl_version, col 57,
    ccl_reg, col 65, d.object,
    col 75, d.datestamp, col 85,
    CALL print(build(d.app_major_version,".",d.app_minor_version)), row + 1
   ENDIF
   tot += 1
   IF (d.binary_cnt > 500)
    cnt_over_500 += 1
   ELSEIF (d.binary_cnt > 250)
    cnt_over_250 += 1
   ELSEIF (d.binary_cnt > 200)
    cnt_over_200 += 1
   ELSEIF (d.binary_cnt > 150)
    cnt_over_150 += 1
   ELSEIF (d.binary_cnt > 100)
    cnt_over_100 += 1
   ELSEIF (d.binary_cnt > 75)
    cnt_over_75 += 1
   ELSEIF (d.binary_cnt > 50)
    cnt_over_50 += 1
   ELSEIF (d.binary_cnt > 25)
    cnt_over_25 += 1
   ELSE
    cnt_over_0 += 1
   ENDIF
  FOOT REPORT
   BREAK, "Summary Page", row + 1,
   "=============================================================================", row + 1, per =
   0.0,
   acnt = cnt_over_500, per = ((acnt * 100.0)/ tot), "500 to 999 =",
   cnt_over_500"######", "      Over 500 =", acnt"######",
   per, "%", row + 1,
   acnt += cnt_over_250, per = ((acnt * 100.0)/ tot), "250 to 500 =",
   cnt_over_250"######", "      Over 250 =", acnt"######",
   per, "%", row + 1,
   acnt += cnt_over_200, per = ((acnt * 100.0)/ tot), "200 to 250 =",
   cnt_over_200"######", "      Over 200 =", acnt"######",
   per, "%", row + 1,
   acnt += cnt_over_150, per = ((acnt * 100.0)/ tot), "150 to 200 =",
   cnt_over_150"######", "      Over 150 =", acnt"######",
   per, "%", row + 1,
   acnt += cnt_over_100, per = ((acnt * 100.0)/ tot), "100 to 150 =",
   cnt_over_100"######", "      Over 100 =", acnt"######",
   per, "%", row + 1,
   acnt += cnt_over_75, per = ((acnt * 100.0)/ tot), " 75 to 100 =",
   cnt_over_75"######", "      Over  75 =", acnt"######",
   per, "%", row + 1,
   acnt += cnt_over_50, per = ((acnt * 100.0)/ tot), " 50 to  75 =",
   cnt_over_50"######", "      Over  50 =", acnt"######",
   per, "%", row + 1,
   acnt += cnt_over_25, per = ((acnt * 100.0)/ tot), " 25 to  50 =",
   cnt_over_25"######", "      Over  25 =", acnt"######",
   per, "%", row + 1,
   acnt += cnt_over_0, per = ((acnt * 100.0)/ tot), "  0 to  25 =",
   cnt_over_0"######", "      Over   0 =", acnt"######",
   per, "%", row + 1,
   row + 1, "Total number of objects = ", acnt"######;,",
   " Total size of objects in records = ", sum(d.binary_cnt)"##########;,", row + 1
 ;end select
END GO
