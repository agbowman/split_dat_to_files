CREATE PROGRAM cv_dbimport_acc:dba
 PROMPT
  "Output Device: 'mine' " = "mine",
  "Install ACCv2_NOMENCLATURE.CSV?   ( 'Y'/'N', default is 'N' ):" = "N",
  "Install ACCv2_DTA.CSV?            ( 'Y'/'N', default is 'N' ):" = "N",
  "Install ACCv2_PowerForm?          (if no form built yet, enter 'Y', otherwise 'N', default is 'N' ):"
   = "N",
  "Update  ACCv2_CDF_MEANING?        ( 'Y'/'N', default is 'N' ):" = "N",
  "Install ACCv2_DATASET.CSV?        ( 'Y'/'N', default is 'N' ):" = "N",
  "Install ACCv2_FILES.CSV?          ( 'Y'/'N', default is 'N' ):" = "N",
  "Install ACCv2_VALIDATION.CSV?     ( 'Y'/'N', default is 'N' ):" = "N"
 IF (cnvtupper( $2)="Y")
  CALL echo("Installing ACCv2_NOMENCLATURE.CSV")
  EXECUTE dm_ocd_readme "dcp_217532_nomen.csv", "Cps_import_nomenclature", 10000,
  7351
 ENDIF
 IF (cnvtupper( $3)="Y")
  CALL echo("Installing ACCv2_DTA.CSV")
  EXECUTE dm_ocd_readme "dcp_217532_dta.csv", "orm_import_dta", 10000,
  7351
 ENDIF
 IF (cnvtupper( $4)="Y")
  CALL echo("Installing ACCv2_PowerForm")
  EXECUTE dm_ocd_readme "dcp_217532_pf.csv", "dcp_import_powerforms", 10000,
  7351
 ENDIF
 IF (cnvtupper( $5)="Y")
  CALL echo("Updating ACCv2_CDF_MEANING")
  EXECUTE dm_ocd_readme "dcp_217532_dta.csv", "cv_updt_cdf_meaning_by_dta", 10000,
  7351
 ENDIF
 IF (cnvtupper( $6)="Y")
  CALL echo("Installing ACCv2_DATASET.CSV")
  EXECUTE dm_ocd_readme "accv2_dataset.csv", "cv_import_dataset", 10000,
  7351
 ENDIF
 IF (cnvtupper( $7)="Y")
  CALL echo("Installing ACCv2_FILES.CSV")
  EXECUTE dm_ocd_readme "accv2_files.csv", "cv_import_dataset_files", 10000,
  7351
 ENDIF
 IF (cnvtupper( $8)="Y")
  CALL echo("Installing ACCv2_VALIDATION.CSV")
  EXECUTE dm_ocd_readme "accv2_validation.csv", "cv_import_xref_validation", 10000,
  7351
 ENDIF
 COMMIT
 CALL echo("If the files are in OCD directory, the process is committed!")
END GO
