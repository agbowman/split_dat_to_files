CREATE PROGRAM cp_updt_delete_old_distr_flag:dba
 SET nbr_selected = 0
 SET nbr_updated = 0
 SELECT INTO "nl:"
  cd.delete_old_distr_flag
  FROM chart_distribution cd
  WHERE cd.delete_old_distr_flag=null
   AND cd.distribution_id != 0
  WITH nocounter
 ;end select
 SET nbr_selected = curqual
 IF (nbr_selected > 0)
  UPDATE  FROM chart_distribution cd
   SET cd.delete_old_distr_flag = 0
   WHERE cd.distribution_id != 0
  ;end update
  IF (curqual > 0)
   SET nbr_updated = curqual
  ENDIF
 ENDIF
 IF (nbr_selected=nbr_updated)
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
END GO
