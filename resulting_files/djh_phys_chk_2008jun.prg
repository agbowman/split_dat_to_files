CREATE PROGRAM djh_phys_chk_2008jun
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 IF (validate(_separator)=0)
  IF (validate(_separator)=0)
   SET _separator = " "
  ENDIF
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT INTO  $OUTDEV
  p.name_full_formatted, p.physician_ind, p.person_id,
  p.name_last_key, p.name_first_key, p_position_disp = uar_get_code_display(p.position_cd),
  pa.person_id, pa.prsnl_alias_type_cd, pa_prsnl_alias_type_disp = uar_get_code_display(pa
   .prsnl_alias_type_cd),
  pa.alias, pa.alias_pool_cd, pa_alias_pool_disp = uar_get_code_display(pa.alias_pool_cd),
  p.position_cd
  FROM prsnl p,
   prsnl_alias pa
  PLAN (p
   WHERE ((p.name_last_key="BLACKMANMD*"
    AND p.name_first_key="GREGORY*") OR (((p.name_last_key="CARROLLMD*"
    AND p.name_first_key="TIMOTHY*") OR (((p.name_last_key="COUGHLINMD*"
    AND p.name_first_key="BRET*") OR (((p.name_last_key="DANNMD*"
    AND p.name_first_key="ROBERT*") OR (((p.name_last_key="DESOUSAMD*"
    AND p.name_first_key="SHERRY*") OR (((p.name_last_key="DIANAMD*"
    AND p.name_first_key="CHARLES*") OR (((p.name_last_key="GIANTURCOMD*"
    AND p.name_first_key="LAURIE*") OR (((p.name_last_key="GILBERTIEMD*"
    AND p.name_first_key="WAYNE*") OR (((p.name_last_key="GLASSERMD*"
    AND p.name_first_key="SCOTT*") OR (((p.name_last_key="HARRMD*"
    AND p.name_first_key="DAVID*") OR (((p.name_last_key="HARTNELLMD*"
    AND p.name_first_key="GEORGE*") OR (((p.name_last_key="HICKSMD*"
    AND p.name_first_key="RICHARD*") OR (((p.name_last_key="KANGMD*"
    AND p.name_first_key="EUGENE*") OR (((p.name_last_key="KATZMD*"
    AND p.name_first_key="ADENA*") OR (((p.name_last_key="KHURANAMD*"
    AND p.name_first_key="BHARTI*") OR (((p.name_last_key="KIRKWOODMD*"
    AND p.name_first_key="J*") OR (((p.name_last_key="KLEINMD*"
    AND p.name_first_key="STEVEN*") OR (((p.name_last_key="KNORRMD*"
    AND p.name_first_key="JOHN*") OR (((p.name_last_key="KRAUSEMD*"
    AND p.name_first_key="RHETT*") OR (((p.name_last_key="LEEMD*"
    AND p.name_first_key="STEVE*") OR (((p.name_last_key="LIMD*"
    AND p.name_first_key="SHAN*") OR (((p.name_last_key="MARKARIANMD*"
    AND p.name_first_key="PAUL*") OR (((p.name_last_key="MILLERMD*"
    AND p.name_first_key="VIVIAN*") OR (((p.name_last_key="MOOREMD*"
    AND p.name_first_key="CHRISTOPHER*") OR (((p.name_last_key="NEYMANMD*"
    AND p.name_first_key="EDWARD*") OR (((p.name_last_key="OATESMD*"
    AND p.name_first_key="M*") OR (((p.name_last_key="OCONNORMD*"
    AND p.name_first_key="STEPHEN*") OR (((p.name_last_key="PARKERMD*"
    AND p.name_first_key="THOMAS*") OR (((p.name_last_key="PATELMD*"
    AND p.name_first_key="JEHANGIR*") OR (((p.name_last_key="PATELMD*"
    AND p.name_first_key="KETAN*") OR (((p.name_last_key="PECHETMD*"
    AND p.name_first_key="TIRON*") OR (((p.name_last_key="POLGAMD*"
    AND p.name_first_key="JAMES*") OR (((p.name_last_key="RHODESMD*"
    AND p.name_first_key="ERIK*") OR (((p.name_last_key="ROSENTHALMD*"
    AND p.name_first_key="CHARLES*") OR (((p.name_last_key="SIDDENMD*"
    AND p.name_first_key="CHRISTOPHER*") OR (((p.name_last_key="SIGNMD*"
    AND p.name_first_key="OFF*") OR (((p.name_last_key="SWERIDUKMD*"
    AND p.name_first_key="STEPHEN*") OR (((p.name_last_key="SWIRSKYMD*"
    AND p.name_first_key="MICHAEL*") OR (((p.name_last_key="TITELBAUMMD*"
    AND p.name_first_key="DAVID*") OR (((p.name_last_key="WHITEMD*"
    AND p.name_first_key="JULES*") OR (((p.name_last_key="WOODMD*"
    AND p.name_first_key="ROBIN*") OR (((p.name_last_key="YOONMD*"
    AND p.name_first_key="ROBERT*") OR (p.name_last_key="YUMD*"
    AND p.name_first_key="DAVID*")) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
   JOIN (pa
   WHERE p.person_id=pa.person_id)
  ORDER BY p.name_last_key
  WITH maxrec = 1000, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
