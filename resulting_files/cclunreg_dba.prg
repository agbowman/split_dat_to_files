CREATE PROGRAM cclunreg:dba
 PROMPT
  "Enter program to unregister " = " "
 SET uname =  $1
 UPDATE  FROM dcompile d
  SET substring(42,1,d.datarec) = char(bxor(ichar(substring(42,1,d.datarec)),8))
  WHERE d.object="P"
   AND d.object_name=uname
   AND btest(ichar(substring(42,1,d.datarec)),3)=1
 ;end update
END GO
