CREATE PROGRAM bhs_eks_attnd_doctor2:dba
 SET retval = 0
 IF ((request->n_attend_doc_id IN (18145281, 748890, 20079463, 19563422, 749952,
 929010, 751187)))
  SET retval = 100
 ENDIF
END GO
