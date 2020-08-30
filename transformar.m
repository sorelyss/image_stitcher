function [img_dst, mask] = transformar(img_src, H, img_dst, offset_x, offset_y)
mask = img_dst(:,:,1);
size_W = size(img_src);
size_F = size(img_dst);

% Listas de indices en img_src & formatear segun teoria
[X,Y]= meshgrid([1:size_W(2)], [1:size_W(1)]);
data_W = [reshape(X,1,[]);
          reshape(Y,1,[]);
          ones(1,length(Y(:)));];

% Aplicar homografia, normalizar y desplazar offset
data_F = H*data_W;
data_F = data_F./[data_F(3,:);data_F(3,:);data_F(3,:)];
data_F = data_F + [abs(offset_x)+100; abs(offset_y)+100; 0];

% Convertir a entero, rendondeando por encima y por debajo
data_F_floor = uint32(floor(data_F));
data_F = uint32(data_F);
% Reformatear data src a convención de Matlab
data_W = [reshape(Y,1,[]);
          reshape(X,1,[]);
          ones(1,length(Y(:)));];

% Unir los indices Y & X.
% Dado el formato de mesh usado, los indices de la coordenada X hay que
% desplazarlos hasta depues del final de los indices Y, es decir x=(X-1)*length(Y)
indices_F_floor = 1 + data_F_floor(2,:) + (data_F_floor(1,:)-1)*size_F(1);
indices_F = 1 + data_F(2,:) + (data_F(1,:)-1)*size_F(1);
indices_W = data_W(1,:) + (data_W(2,:)-1)*size_W(1);

% Reemplazar pixeles en nueva mascara e imagen
mask(indices_F) = ones(size(indices_W))*255;
mask(indices_F_floor) = ones(size(indices_W))*255;

% Imagen RGB
r=0; g=size_F(1)*size_F(2); b=size_F(1)*size_F(2)*2;
rW=0; gW=size_W(1)*size_W(2); bW=size_W(1)*size_W(2)*2;
img_dst([indices_F, indices_F + g, indices_F + b]) = [img_src(indices_W), img_src(indices_W + gW), img_src(indices_W + bW)];
img_dst([indices_F_floor, indices_F_floor + g, indices_F_floor + b]) = [img_src(indices_W), img_src(indices_W + gW), img_src(indices_W + bW)];

end