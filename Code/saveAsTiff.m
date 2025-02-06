function [] = saveAsTiff(gray_scale_image, savePath)
    t = Tiff(savePath, 'w');

    % Set TIFF tags for 32-bit integer storage
    tagstruct.ImageLength = size(gray_scale_image, 1);
    tagstruct.ImageWidth = size(gray_scale_image, 2);
    tagstruct.BitsPerSample = 32;  % 32-bit
    tagstruct.SamplesPerPixel = 1;
    tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    
    if isa(gray_scale_image, 'single')
        tagstruct.SampleFormat = Tiff.SampleFormat.IEEEFP; % Floating-point storage
    elseif isa(gray_scale_image, 'double')
        % Convert double to single for 32-bit floating-point storage
        gray_scale_image = single(gray_scale_image);
        tagstruct.SampleFormat = Tiff.SampleFormat.IEEEFP; % Floating-point storage
    elseif isinteger(gray_scale_image)
        tagstruct.SampleFormat = Tiff.SampleFormat.Int; % Integer storage
    else
        error('Input image must be either double or an integer type.');
    end

    % Apply tags
    t.setTag(tagstruct);
    
    % Write data
    t.write(gray_scale_image);
    t.close();
end