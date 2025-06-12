CREATE PROGRAM csm_eks_import_rev:dba
 FREE SET input
 SET input = "CSMREV"
 SET wantlog = "N"
 EXECUTE eks_import
 IF (cursys != "AIX")
  SET message = window
 ENDIF
END GO
