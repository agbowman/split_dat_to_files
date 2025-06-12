CREATE PROGRAM bed_ext_assay:dba
 SELECT INTO "CER_INSTALL:ps_assay.csv"
  FROM br_auto_dta b,
   code_value cv289,
   code_value cv106
  PLAN (b)
   JOIN (cv106
   WHERE cv106.active_ind=1
    AND cv106.code_value=b.activity_type_cd)
   JOIN (cv289
   WHERE cv289.active_ind=outerjoin(1)
    AND cv289.code_value=outerjoin(b.result_type_cd))
  ORDER BY b.activity_type_cd, b.description
  HEAD REPORT
   "source,result_type,activity_type,description,mnemonic,result_type_mean,activity_type_mean"
  DETAIL
   mnemonic = concat('"',trim(b.mnemonic),'"'), description = concat('"',trim(b.description),'"'),
   result_type = concat('"',trim(cv289.display),'"'),
   activity_type = concat('"',trim(cv106.display),'"'), result_type_mean = concat('"',trim(cv289
     .cdf_meaning),'"'), activity_type_mean = concat('"',trim(cv106.cdf_meaning),'"'),
   row + 1, line = concat("AUTOBUILD,",trim(result_type),",",trim(activity_type),",",
    trim(description),",",trim(mnemonic),",",trim(result_type_mean),
    ",",trim(activity_type_mean)), line
  WITH maxcol = 500, maxrow = 1, noformfeed,
   format = variable, nocounter
 ;end select
END GO
