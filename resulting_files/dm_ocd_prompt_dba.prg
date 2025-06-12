CREATE PROGRAM dm_ocd_prompt:dba
 PROMPT
  "ENTER (in quotes) THE ADMIN USER NAME: " =  $1,
  "ENTER (in quotes) THE ADMIN PASSWORD: " =  $2
 SET u_name = cnvtlower(trim( $1))
 SET p_word = cnvtlower(trim( $2))
END GO
