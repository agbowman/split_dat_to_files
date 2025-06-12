CREATE PROGRAM dta:dba
 PROMPT
  "DTA Mnemonic:  [0]  " = 0
 SELECT INTO mine
  dta.task_assay_cd, dta.active_ind, mnemonic = substring(1,40,dta.mnemonic),
  description = substring(1,50,dta.description), actvy_typ = uar_get_code_display(dta
   .activity_type_cd)
  FROM discrete_task_assay dta
  WHERE cnvtupper( $1)=dta.mnemonic_key_cap
  ORDER BY dta.active_ind, dta.mnemonic
 ;end select
END GO
