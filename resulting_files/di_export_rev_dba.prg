CREATE PROGRAM di_export_rev:dba
 FREE SET input
 SET input =  $1
 SET wantlog = "Y"
 EXECUTE eks_export
END GO
