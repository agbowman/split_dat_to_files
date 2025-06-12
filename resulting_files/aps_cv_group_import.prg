CREATE PROGRAM aps_cv_group_import
 RECORD request(
   1 parent_qual[*]
     2 parent_code_set = i4
     2 parent_cdf_mean = c12
     2 parent_code_value = f8
     2 child_qual[*]
       3 child_code_set = i4
       3 child_cdf_mean = c12
       3 child_code_value = f8
 )
 SET cdf_mean = fillstring(12," ")
 SET code_set = 0
 SET list_cnt = 0
 SET p_cnt = 0
 SET c_cnt = 0
 SET x = 0
 SET list_cnt = size(requestin->list_0,5)
 SET stat = alterlist(request->parent_qual,10)
 FOR (x = 1 TO list_cnt)
   IF ((((cdf_mean != requestin->list_0[x].parent_cdf_mean)) OR (code_set != cnvtint(requestin->
    list_0[x].parent_code_set))) )
    SET p_cnt = (p_cnt+ 1)
    IF (mod(p_cnt,10)=1)
     SET stat = alterlist(request->parent_qual,(p_cnt+ 10))
    ENDIF
    SET request->parent_qual[p_cnt].parent_code_set = cnvtint(requestin->list_0[x].parent_code_set)
    SET request->parent_qual[p_cnt].parent_cdf_mean = requestin->list_0[x].parent_cdf_mean
    SET cdf_mean = requestin->list_0[x].parent_cdf_mean
    SET code_set = cnvtint(requestin->list_0[x].parent_code_set)
    SET c_cnt = 0
   ENDIF
   SET c_cnt = (c_cnt+ 1)
   SET stat = alterlist(request->parent_qual[p_cnt].child_qual,c_cnt)
   SET request->parent_qual[p_cnt].child_qual[c_cnt].child_code_set = cnvtint(requestin->list_0[x].
    child_code_set)
   SET request->parent_qual[p_cnt].child_qual[c_cnt].child_cdf_mean = requestin->list_0[x].
   child_cdf_mean
 ENDFOR
 SET stat = alterlist(request->parent_qual,p_cnt)
 EXECUTE aps_insert_cv_group
END GO
