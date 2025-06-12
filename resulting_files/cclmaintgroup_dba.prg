CREATE PROGRAM cclmaintgroup:dba
 PROMPT
  "(D)elete or (S)elect all group programs : " = "S",
  "Begin Group number to select (99): " = 99,
  "End Group number to select (99): " = 99
 CASE (cnvtupper( $1))
  OF "S":
   SELECT
    d.object, d.object_name, d.group
    FROM dprotect d
    WHERE d.object IN ("E", "M", "P", "V")
     AND d.group BETWEEN  $2 AND  $3
    WITH counter
   ;end select
   SELECT
    d.object, d.object_name, d.group
    FROM dcompile d
    WHERE d.object="P"
     AND d.group BETWEEN  $2 AND  $3
    WITH counter
   ;end select
  OF "D":
   IF (( $2 > 1)
    AND (3 >=  $2))
    DELETE  FROM dprotect d
     WHERE d.object IN ("E", "M", "P", "V")
      AND d.group BETWEEN  $2 AND  $3
     WITH counter
    ;end delete
    DELETE  FROM dcompile d
     WHERE d.object="P"
      AND d.group BETWEEN  $2 AND  $3
     WITH counter
    ;end delete
   ENDIF
 ENDCASE
END GO
