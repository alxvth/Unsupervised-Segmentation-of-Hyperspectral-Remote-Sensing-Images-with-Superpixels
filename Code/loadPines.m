function [dataset_images, dataset_gt, bg_value, name] = loadPines()
    
    bg_value = 0;
    dataset_images = cell(0);
    dataset_gt = cell(0);
    name = "Pines";

    path_dataset = "..\Datasets\Pines\";
    
    image = load(path_dataset + "Indian_pines_corrected.mat");
    image = image.indian_pines_corrected;

    % Normalization
    image = normalization(image,95);
    image = double(image)/max(double(image), [], 'all');
    dataset_images{1} = image;

    gt = load(path_dataset + "Indian_pines_gt.mat");
    gt = gt.indian_pines_gt;
    dataset_gt{1} = gt;
end