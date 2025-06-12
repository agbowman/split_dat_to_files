CREATE PROGRAM cclquery3:dba
 PROMPT
  "Enter output name for report  (MINE): " = "MINE",
  "Enter program name                (): " = "X",
  "Show index columns for plan(Y/N) (N): " = "N",
  "Timeout value in seconds        (10): " = 10
 EXECUTE cclquery  $1,  $2,  $3 WITH time =  $4
END GO
