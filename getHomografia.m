function H = getHomografia(puntosMatch)
n_puntos = size(puntosMatch,1);
 
D=zeros(n_puntos*2,8);
b=zeros(n_puntos*2,1);
for i=1:n_puntos
    x_w = puntosMatch(i,1); y_w = puntosMatch(i,2);
    x_f = puntosMatch(i,3); y_f = puntosMatch(i,4);
    
    D(2*i-1,1:3) = [x_w, y_w, 1];
    D(2*i-1,7:8) = [-x_w*x_f, -y_w*x_f];
    
    D(2*i,4:6) = [x_w, y_w, 1];
    D(2*i,7:8) = [-x_w*y_f, -y_w*y_f];
    
    b(2*i-1:2*i) = [x_f; y_f];
end
 
%Resuelve el sistema
h=D\b;
 
h(9)=1.0;
H = reshape(h, [3,3])';
end
