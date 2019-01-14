function Area = FindArea(Img, P, Invert)
%% FINDAREA returns number of white pixels in 'Img'.
%
%   Input
%       Img	- Input Image
%       P       - Area Threshold
%       Invert  - Invert Region
%
%   Output
%       Area - Area after Binarization

%% Function starts here

% Convert the Image to Grayscale
I = Img(:,:,3);

% Filtering
str1 = strel('diamond', 5);
I1 = imopen(I, str1);

% Binarization
level = 0.35;
I2 = imbinarize(I1,level);

% Remove Noise
F1 = bwareaopen(I2, P);
F2 =~ F1;
F3 = bwareaopen(F2, 1);
switch Invert
    case 'Y'
        % Find the Area
        Data = regionprops(F3,'Area'); % Measure the White Area
        Area = Data.Area; % Pixel area
    case 'N'
        % Find the Area
        Data = regionprops(F1,'Area'); % Measure the White Area
        Area = Data.Area; % Pixel area
end

end

