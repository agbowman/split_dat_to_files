CREATE PROGRAM cv_dbimport_sts2:dba
 PROMPT
  "output device: 'mine' " = "mine",
  "If submit STS 2.35 & STS 2.41 in one file, enter 'Y' (default is 'n'):" = "n",
  "install sts02_comb_files.csv       ( 'y'/'n', default is 'n' ):" = "n",
  "Update STS 2.35 dataset/file?      ( 'y'/'n', default is 'n' ):" = "n"
 IF (cnvtupper( $2)="Y"
  AND cnvtupper( $3)="Y")
  CALL echo("installing sts24_comb_files.csv")
  EXECUTE dm_ocd_readme "sts02_comb_files.csv", "cv_import_dataset_files", 10000,
  8583
 ENDIF
 IF (cnvtupper( $2)="Y"
  AND cnvtupper( $4)="Y")
  CALL echo("installing sts_dataset_merge.csv")
  EXECUTE dm_ocd_readme "sts_dataset_merge.csv", "cv_import_dataset", 10000,
  8583
  CALL echo("installing sts_files_merge.csv")
  EXECUTE dm_ocd_readme "sts_files_merge.csv", "cv_import_dataset_files", 10000,
  8583
 ENDIF
 CALL echo(
  "*******************************************************************************************")
 CALL echo("Under ccl prompt, enter following command separately and accept default at prompt:")
 CALL echo("cv_upd_sts_long_text_data go")
 CALL echo(
  "*******************************************************************************************")
 COMMIT
 CALL echo("if the files are in ocd directory, the process is committed!")
END GO
