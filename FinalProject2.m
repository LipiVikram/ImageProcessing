%% BRAIN TUMOR SEGMENTATION

clear


%% LOAD DATA

load('braintumor2ddata.mat');

%% CHANGE DATA TYPE TO TYPE DOUBLE

flair_all = im2double(flair_all);
t1_all = im2double(t1_all);
t1c_all = im2double(t1c_all);
t2_all = im2double(t2_all);
truth_all = im2double(truth_all);


%% SEPARATE DATA INTO PATIENT BY PATIENT SCANSET STRUCTURE

for i = 1:20
    flair = flair_all(:,:,i);
    t1 = t1_all(:,:,i);
    t1c = t1c_all(:,:,i);
    t2 = t2_all(:,:,i);
    truth = truth_all(:,:,i);
    
    scanset(i) = struct('flair', flair, 't1', t1, 't1c',t1c,'t2',t2,'truth', truth, 'combined', cat(3,flair,t2,t1c));
    
end

clearvars flair t1 t1c t2 truth i

%% WRITE ALL TRUTH IMAGES

for i = 1:20
   fig = imshow(scanset(i).truth, []);
   saveas(fig,sprintf('scanset%d_truth',i),'png')
end

%% TEST FOR EDEMA REGIONS
% 
% testFlair = scanset(18).flair;
% 
% A = imgaussfilt(testFlair, 5);
% rng(1)
% Edema = reshape(kmeans(A(:), 4), size(A));
% 
% C = regionprops(Edema);
% 
% 
% fig = imshow(Edema,[]);
% 
% 
% % calculate and store areas of all bounding boxes in segmentation
% areas = zeros(1,4);
% 
% for j = 1:4
%         w = C(j).BoundingBox;
%         jth_area = w(3)*w(4);
%         areas(j) = jth_area;
% end
% 
% % Find colors corresponding to min area, correlate it to color of EDEMA
% % region
% clearvars min min_inx
% [min, min_inx] = min(areas);
% 
% edema_color = min_inx;
% 
% % change color of other regions to black
% 
% for j = 1:176
%     for k = 1:216
%         if Edema(j,k) ~= edema_color
%             Edema(j,k) = 1;
%         else
%             Edema(j,k) = 3;
%         end
%     end
% end
% 
% imshow(Edema, [1 4])




%% METHOD 1: OLD IMAGE SEGMENTING METHODS

% ATTEMPT TO INDIVIDUALLY SEGMENT THE EDEMA AND TUMOR REGIONS FROM THE 
% BACKGROUND. IN GENERAL THE EDEMA REGIONS ARE MORE VISIBLE ON THE FLAIR
% IMAGES, WHEREAS THE TUMOR REGIONS ARE MORE VISIBLE IN THE T2 IMAGES.
% NOTING THIS, WE WILL FOCUS OUR OPERATIONS ON THESE TWO IMAGES!!!

% Attempt at Finding Edema Regions for Each patient Set by working on flair
% images

for i = 1:20
    switch i
        case 7
            sig = 5.1;
        case 10
            sig = 9;
        case 16
            sig = 5.1;
        case 19
            sig = 3;
        case 20
            sig = 3;
        otherwise
            sig = 5; 
    end
    
    rng(1)
    equalizedFlair = imgaussfilt(scanset(i).flair, sig);
    
    % Edema Region
    Edema = reshape(kmeans(equalizedFlair(:), 4), size(scanset(i).flair));
        
    % Now that we have estimated Edema Region, we can find this region
    % by finding the region with the smallest regionprops() bounding box
   
    regions = regionprops(Edema);
    
    % Find and store area of each bounding box
    areas = zeros(1,4);
    for j = 1:4
        w = regions(j).BoundingBox;
        jth_area = w(3)*w(4);
        areas(j) = jth_area;
    end
    
    clearvars min min_inx
    
    % find minimum box and the color surrounded by the minimum box
    [min, min_inx] = min(areas);
    edema_color = min_inx;

    for j = 1:176
        for k = 1:216
            if Edema(j,k) ~= edema_color
                Edema(j,k) = 1;
            else
                Edema(j,k) = 3;
            end
        end
    end

    fig = imshow(Edema, [1 4]);
    saveas(fig, sprintf('scanset%d_Estimated_Edema_Region', i), 'png')
end

%% METHOD 2: U-NETWORK METHOD


   




