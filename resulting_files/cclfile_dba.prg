CREATE PROGRAM cclfile:dba
 PROMPT
  "Output name   :" = "MINE",
  "Database Name :" = "*"
 SELECT INTO  $1
  d.file_name, date = concat(format(d.datestamp,"ddmmmyyyy;;d"),"-",format(d.timestamp,"hh:mm;;m")),
  dir_type =
  IF (d.file_dir_type="C") "Ccldir    "
  ELSEIF (d.file_dir_type="S") "System    "
  ELSEIF (d.file_dir_type="W") "Work      "
  ELSEIF (d.file_dir_type="U") "Ccluserdir"
  ELSE "Unknown   "
  ENDIF
  ,
  file_format =
  IF (d.file_format="F") "Fixed     "
  ELSEIF (d.file_format="V") "Variable  "
  ELSEIF (d.file_format="S") "Stream    "
  ELSEIF (d.file_format="U") "Undefined "
  ELSEIF (d.file_format="C") "Crstream  "
  ELSEIF (d.file_format="L") "Lfstream  "
  ELSEIF (d.file_format="X") "Xundefined"
  ELSE "Unknown   "
  ENDIF
  , file_org =
  IF (d.file_org="R") "Relative  "
  ELSEIF (d.file_org="I") "Indexed   "
  ELSEIF (d.file_org="S") "Sequential"
  ELSEIF (d.file_org="W") "Work      "
  ELSEIF (d.file_org="T") "Tape      "
  ELSEIF (d.file_org="O") "Rdbms     "
  ELSE "Unknown   "
  ENDIF
  , reclen = cnvtreal(d.max_reclen)"######",
  key_num = k.seq"#", k.*
  FROM dfile d,
   dfilekey k
  PLAN (d
   WHERE d.file_name=patstring(cnvtupper( $2)))
   JOIN (k)
  WITH outerjoin = d
 ;end select
END GO
