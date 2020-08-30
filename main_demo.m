clear all;
close all;
clc;

for escena_ind = ['3', '4', '5']
    tic
    load(sprintf('E%s_data.mat', escena_ind))
    addpath(escena)

    % ----------------------------------------------------------
    % Calculo de la Homografía
    % ----------------------------------------------------------
    Hs = repmat(eye(3),[1 1 n_imgs]);
    for img_index=2:n_imgs
        puntosMatch = cell2mat(puntosMatch_imgs(img_index));
        H = getHomografia(puntosMatch);  
        H = Hs(:,:,img_index-1) * H;
        H = H./repmat(H(3,3),1,3);
        Hs(:,:,img_index) = H;
    end

    % Remapear Hi a H de la imagen del centro
    center_img = floor((n_imgs+1)/2);
    H_center = Hs(:,:,center_img);
    for i = 1:size(Hs,3)
        Hs(:,:,i) = Hs(:,:,i)\H_center;
        Hs(:,:,i) = Hs(:,:,i)./repmat(Hs(3,3,i),1,3); % Normalizarla
    end

    % ----------------------------------------------------------
    % Construcción del mosaico o imagen panorámica
    % ----------------------------------------------------------
    img = imread(sprintf('%s_Imagen%d.jpg', escena, 1));

    % Tamano de imagen final panomara
    max_size = max(size_imgs);
    offset = 500;
    width  = round(max_size(2)+sum(abs(Hs(1,3,:))) + offset);
    height = round(max_size(1)+sum(abs(Hs(2,3,:))) + offset);

    panorama = zeros([height width 3], 'like', img);
    panoramaBlack = panorama;
    panoramaMask = zeros([height width],'like', img);

    for i = 1:n_imgs
        im_name = sprintf('%s_Imagen%d.jpg', escena, i);
        img = imread(im_name);

        % Transformar la imagen y su mascara
        [imgTransformada, mask] = transformar(img, Hs(:,:,i),panoramaBlack, Hs(1,3,1), Hs(2,3,1));

        % Hallar solapamiento
        solapeMask = panoramaMask & mask;
        solapeMaskColor = repmat(solapeMask,[1,1,3]);

        % Promediar imágenes y acumular mascara
        panorama = im2double(panorama) + im2double(imgTransformada);
        panorama(solapeMaskColor) = panorama(solapeMaskColor)/2;
        panorama = im2uint8(panorama);
        panoramaMask = panoramaMask + mask;
    end

    [rows, columns] = find(panoramaMask);
    panoramaFinal = panorama(min(rows):max(rows), min(columns):max(columns), :);
    panoramaFinal = medfilt3(panoramaFinal);
    
    fprintf('Escena %s completada en %.2f segundos.\n', escena_ind, toc);
    
    figure; 
    subplot(2,1,1); imshow(panorama)
    subplot(2,1,2); imshow(panoramaFinal)
end