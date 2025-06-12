CREATE PROGRAM cv_dbimport_sts:dba
 PROMPT
  "output device: 'mine' " = "mine",
  "install sts_nomenclature.csv?   ( 'y'/'n', default is 'n' ):" = "n",
  "install sts_dta.csv?            ( 'y'/'n', default is 'n' ):" = "n",
  "install sts_powerform?          (if no form built yet, enter 'y', otherwise 'n', default is 'n' ):"
   = "n",
  "update  sts_cdf_meaning?        ( 'y'/'n', default is 'n' ):" = "n",
  "install sts_dataset.csv?        ( 'y'/'n', default is 'n' ):" = "n",
  "install sts_files.csv?          ( 'y'/'n', default is 'n' ):" = "n",
  "install sts_validation.csv?     ( 'y'/'n', default is 'n' ):" = "n"
 IF (cnvtupper( $2)="Y")
  CALL echo("installing sts_nomenclature.csv")
  EXECUTE dm_ocd_readme "sts_nomenclature.csv", "cps_import_nomenclature", 10000,
  7351
 ENDIF
 IF (cnvtupper( $3)="Y")
  CALL echo("installing sts_dta.csv")
  EXECUTE dm_ocd_readme "sts_dta.csv", "orm_import_dta", 10000,
  7351
 ENDIF
 IF (cnvtupper( $4)="Y")
  CALL echo("installing sts_powerform")
  EXECUTE dm_ocd_readme "dcp_51834_pf.csv", "dcp_import_powerforms", 10000,
  7351
 ENDIF
 IF (cnvtupper( $5)="Y")
  CALL echo("updating sts cdf_meaning")
  EXECUTE dm_ocd_readme "sts_dta.csv", "cv_updt_cdf_meaning_by_dta", 10000,
  7351
 ENDIF
 IF (cnvtupper( $6)="Y")
  CALL echo("installing sts_dataset.csv")
  EXECUTE dm_ocd_readme "sts_dataset.csv", "cv_import_dataset", 10000,
  7351
 ENDIF
 IF (cnvtupper( $7)="Y")
  CALL echo("installing sts_files.csv")
  EXECUTE dm_ocd_readme "sts_files.csv", "cv_import_dataset_files", 10000,
  7351
 ENDIF
 IF (cnvtupper( $8)="Y")
  CALL echo("installing sts_validation.csv")
  EXECUTE dm_ocd_readme "sts_validation.csv", "cv_import_xref_validation", 10000,
  7351
 ENDIF
 COMMIT
 CALL echo("if the files are in ocd directory, the process is committed!")
END GO
