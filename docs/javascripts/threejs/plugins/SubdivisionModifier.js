THREE.SubdivisionModifier=function(e){this.subdivisions=e===undefined?1:e},THREE.SubdivisionModifier.prototype.modify=function(e){for(var n=this.subdivisions;n-- >0;)this.smooth(e);delete e.__tmpVertices,e.computeFaceNormals(),e.computeVertexNormals()},function(){function e(e,n,o){return o[Math.min(e,n)+"_"+Math.max(e,n)]}function n(e,n,o,a,i,t){var c,s=Math.min(e,n),r=Math.max(e,n),d=s+"_"+r;if(d in a)c=a[d];else{c={a:o[s],b:o[r],newEdge:null,faces:[]},a[d]=c}c.faces.push(i),t[e].edges.push(c),t[n].edges.push(c)}function o(e,o,a,i){var t,c,s;for(t=0,c=e.length;t<c;t++)a[t]={edges:[]};for(t=0,c=o.length;t<c;t++)s=o[t],n(s.a,s.b,e,i,s,a),n(s.b,s.c,e,i,s,a),n(s.c,s.a,e,i,s,a)}function a(e,n,o,a){e.push(new THREE.Face3(n,o,a))}var i=!1,t=["a","b","c"];THREE.SubdivisionModifier.prototype.smooth=function(n){var c,s,r,d,l,f,u,g,h,b,m,m,p,E,v=new THREE.Vector3;c=n.vertices,s=n.faces,b=new Array(c.length),m={},o(c,s,b,m),p=[];var w,y,M,S,H,R,T;for(f in m){for(y=m[f],M=new THREE.Vector3,H=3/8,R=1/8,T=y.faces.length,2!=T&&(H=.5,R=0,1!=T&&i&&console.warn("Subdivision Modifier: Number of connected faces != 2, is: ",T,y)),M.addVectors(y.a,y.b).multiplyScalar(H),v.set(0,0,0),g=0;g<T;g++){for(S=y.faces[g],h=0;h<3&&((w=c[S[t[h]]])===y.a||w===y.b);h++);v.add(w)}v.multiplyScalar(R),M.add(v),y.newEdge=p.length,p.push(M)}var V,_,x,N,F,A,j;for(E=[],f=0,u=c.length;f<u;f++){for(A=c[f],F=b[f].edges,l=F.length,3==l?V=3/16:l>3&&(V=3/(8*l)),_=1-l*V,x=V,l<=2&&(2==l?(i&&console.warn("2 connecting edges",F),_=.75,x=1/8):1==l?i&&console.warn("only 1 connecting edge"):0==l&&i&&console.warn("0 connecting edges")),j=A.clone().multiplyScalar(_),v.set(0,0,0),g=0;g<l;g++)N=F[g],w=N.a!==A?N.a:N.b,v.add(w);v.multiplyScalar(x),j.add(v),E.push(j)}r=E.concat(p);var k,q,z,B=E.length;for(d=[],f=0,u=s.length;f<u;f++)S=s[f],k=e(S.a,S.b,m).newEdge+B,q=e(S.b,S.c,m).newEdge+B,z=e(S.c,S.a,m).newEdge+B,a(d,k,q,z),a(d,S.a,k,z),a(d,S.b,q,k),a(d,S.c,z,q);n.vertices=r,n.faces=d}}();