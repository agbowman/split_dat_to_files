CREATE PROGRAM da_find_tree:dba
 FREE SET paths
 FREE RECORD paths
 FREE DEFINE paths
 RECORD paths(
   1 qual[*]
     2 path[*]
       3 vertex_id = f8
 ) WITH protect
 SET stat = alterlist(paths->qual,0)
 DECLARE findtermvertex(cur_path=i4,terminating_vertex=f8) = i1 WITH public
 DECLARE num = i2 WITH noconstant(0), protect
 DECLARE idx = i2 WITH noconstant(0), protect
 DECLARE vertex_1 = f8
 DECLARE vertex_2 = f8
 DECLARE reqvertcnt = i2
 DECLARE reqedgecnt = i2
 SET reqvertcnt = size(vertices->qual,5)
 DECLARE found = i1 WITH noconstant(0)
 DECLARE num_of_paths = i4 WITH noconstant(0)
 DECLARE path_idx = i4 WITH noconstant(0)
 DECLARE start_vertex_id = f8 WITH noconstant(0.0)
 DECLARE end_vertex_id = f8 WITH noconstant(0.0)
 DECLARE vertex_cnt = i2 WITH noconstant(0)
 DECLARE edge_cnt = i2 WITH noconstant(0)
 DECLARE vertex_1_idx = i2 WITH noconstant(0)
 DECLARE edge_id = f8 WITH noconstant(0.0)
 DECLARE edge_idx = i2 WITH noconstant(0)
 IF (size(edges->qual,5) > 0)
  FOR (i = 1 TO size(graph->vertex_list,5))
    FOR (x = 1 TO size(edges->qual,5))
     SET idx = locateval(num,1,size(graph->vertex_list[i].edge_list,5),edges->qual[x].edge_id,graph->
      vertex_list[i].edge_list[num].edge_id)
     IF (idx > 0)
      SET vertex_1 = graph->vertex_list[i].vertex_id
      SET vertex_2 = graph->vertex_list[i].edge_list[idx].adjacent_vertex_id
      IF (locateval(num,1,reqvertcnt,vertex_1,vertices->qual[num].vertex_id)=0)
       SET reqvertcnt = (reqvertcnt+ 1)
       SET stat = alterlist(vertices->qual,reqvertcnt)
       SET vertices->qual[reqvertcnt].vertex_id = vertex_1
      ENDIF
      IF (locateval(num,1,reqvertcnt,vertex_2,vertices->qual[num].vertex_id)=0
       AND vertex_2 > 0)
       SET reqvertcnt = (reqvertcnt+ 1)
       SET stat = alterlist(vertices->qual,reqvertcnt)
       SET vertices->qual[reqvertcnt].vertex_id = vertex_2
      ENDIF
     ENDIF
    ENDFOR
  ENDFOR
 ENDIF
 SET start_vertex_id = vertices->qual[1].vertex_id
 FOR (i = 2 TO size(vertices->qual,5))
   SET end_vertex_id = vertices->qual[i].vertex_id
   SET stat = alterlist(paths->qual,1)
   SET stat = alterlist(paths->qual[1].path,1)
   SET paths->qual[1].path[1].vertex_id = start_vertex_id
   SET found = 0
   WHILE (found=0)
     SET num_of_paths = size(paths->qual,5)
     SET path_idx = 0
     WHILE (path_idx < num_of_paths
      AND found=0)
      SET path_idx = (path_idx+ 1)
      SET found = findtermvertex(path_idx,end_vertex_id)
     ENDWHILE
     IF (num_of_paths > 10000)
      SET found = 1
      CALL echo("ERROR:  Terminating the Shortest Path logic.  More than 10,000 created")
     ENDIF
   ENDWHILE
   FOR (j = 1 TO (size(paths->qual[path_idx].path,5) - 1))
     SET vertex_1 = paths->qual[path_idx].path[j].vertex_id
     SET vertex_2 = paths->qual[path_idx].path[(j+ 1)].vertex_id
     IF (locateval(num,1,size(vertices->qual,5),vertex_1,vertices->qual[num].vertex_id)=0)
      SET vertex_cnt = (size(vertices->qual,5)+ 1)
      SET stat = alterlist(vertices->qual,vertex_cnt)
      SET vertices->qual[vertex_cnt].vertex_id = vertex_1
     ENDIF
     IF (locateval(num,1,size(vertices->qual,5),vertex_2,vertices->qual[num].vertex_id)=0)
      SET vertex_cnt = (size(vertices->qual,5)+ 1)
      SET stat = alterlist(vertices->qual,vertex_cnt)
      SET vertices->qual[vertex_cnt].vertex_id = vertex_2
     ENDIF
     SET vertex_1_idx = locateval(num,1,size(graph->vertex_list,5),vertex_1,graph->vertex_list[num].
      vertex_id)
     SET edge_idx = locateval(num,1,size(graph->vertex_list[vertex_1_idx].edge_list,5),vertex_2,graph
      ->vertex_list[vertex_1_idx].edge_list[num].adjacent_vertex_id)
     WHILE (edge_idx > 0)
       SET edge_id = graph->vertex_list[vertex_1_idx].edge_list[edge_idx].edge_id
       IF (locateval(num,1,size(edges->qual,5),edge_id,edges->qual[num].edge_id)=0)
        SET edge_cnt = (size(edges->qual,5)+ 1)
        SET stat = alterlist(edges->qual,edge_cnt)
        SET edges->qual[edge_cnt].edge_id = edge_id
       ENDIF
       SET edge_idx = locateval(num,(edge_idx+ 1),size(graph->vertex_list[vertex_1_idx].edge_list,5),
        vertex_2,graph->vertex_list[vertex_1_idx].edge_list[num].adjacent_vertex_id)
     ENDWHILE
   ENDFOR
 ENDFOR
 FOR (i = 1 TO size(vertices->qual,5))
   SET vertex_1_idx = locateval(num,1,size(graph->vertex_list,5),vertices->qual[i].vertex_id,graph->
    vertex_list[num].vertex_id)
   SET edge_idx = locateval(num,1,size(graph->vertex_list[vertex_1_idx].edge_list,5),0.0,graph->
    vertex_list[vertex_1_idx].edge_list[num].adjacent_vertex_id)
   WHILE (edge_idx > 0)
     SET edge_id = graph->vertex_list[vertex_1_idx].edge_list[edge_idx].edge_id
     IF (locateval(num,1,size(edges->qual,5),edge_id,edges->qual[num].edge_id)=0)
      SET edge_cnt = (size(edges->qual,5)+ 1)
      SET stat = alterlist(edges->qual,edge_cnt)
      SET edges->qual[edge_cnt].edge_id = edge_id
     ENDIF
     SET edge_idx = locateval(num,(edge_idx+ 1),size(graph->vertex_list[vertex_1_idx].edge_list,5),
      0.0,graph->vertex_list[vertex_1_idx].edge_list[num].adjacent_vertex_id)
   ENDWHILE
 ENDFOR
 SUBROUTINE findtermvertex(cur_path,terminating_vertex)
   DECLARE num = i4 WITH noconstant(0), protect
   DECLARE num_adj_vertices = i2 WITH noconstant(0)
   DECLARE v_idx = i4 WITH noconstant(0)
   DECLARE return_val = i1 WITH noconstant(0)
   SET path_size = size(paths->qual[cur_path].path,5)
   SET v_idx = locateval(num,1,size(graph->vertex_list,5),paths->qual[cur_path].path[path_size].
    vertex_id,graph->vertex_list[num].vertex_id)
   SET num_adj_vertices = 0
   FOR (k = 1 TO size(graph->vertex_list[v_idx].edge_list,5))
     IF ((graph->vertex_list[v_idx].edge_list[k].adjacent_vertex_id != 0))
      SET num_adj_vertices = (num_adj_vertices+ 1)
      IF ((graph->vertex_list[v_idx].edge_list[k].adjacent_vertex_id=terminating_vertex))
       SET stat = alterlist(paths->qual[cur_path].path,(path_size+ 1))
       SET paths->qual[cur_path].path[(path_size+ 1)].vertex_id = terminating_vertex
       SET return_val = 1
       SET k = (size(graph->vertex_list[v_idx].edge_list,5)+ 1)
      ELSE
       IF (num_adj_vertices=1)
        SET stat = alterlist(paths->qual[cur_path].path,(path_size+ 1))
        SET paths->qual[cur_path].path[(path_size+ 1)].vertex_id = graph->vertex_list[v_idx].
        edge_list[k].adjacent_vertex_id
       ELSE
        SET new_path = (size(paths->qual,5)+ 1)
        SET stat = alterlist(paths->qual,new_path)
        SET stat = alterlist(paths->qual[new_path].path,(path_size+ 1))
        FOR (p = 1 TO path_size)
          SET paths->qual[new_path].path[p].vertex_id = paths->qual[cur_path].path[p].vertex_id
        ENDFOR
        SET paths->qual[new_path].path[(path_size+ 1)].vertex_id = graph->vertex_list[v_idx].
        edge_list[k].adjacent_vertex_id
       ENDIF
       SET return_val = 0
      ENDIF
     ENDIF
   ENDFOR
   RETURN(return_val)
 END ;Subroutine
 FREE SET paths
 FREE RECORD paths
END GO
