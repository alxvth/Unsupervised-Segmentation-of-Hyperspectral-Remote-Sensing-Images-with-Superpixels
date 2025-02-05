%%

clear variables
close all

%% Import python utility

pyenv(Version="C:\\Users\\avieth\\AppData\\Local\\miniconda3\\envs\\MATLAB\\python.exe")
py.importlib.import_module('python_utility');
rng(123);

dataset_loaders = {@loadPines, @loadPaviaCenter, @loadPaviaUniversity, @loadSalinas, @loadSalinasA};

for i = 1:length(dataset_loaders)
    % Load dataset
    [dataset_images, dataset_gt, bg_value, datase_name] = dataset_loaders{i}();
    image = dataset_images{1};
    gt = dataset_gt{1};
    
    fprintf('Processing dataset: %s\n', datase_name);
  
    %imshow(image(:,:,100), []);
    %imshow(gt, []);
    
    % Superpixel segmetation
    
    m = 0.2;
    m_clust = 0.8;
    
    for n_cluster = [10 50 100 250 500 1000, 2500]
        
        [sp_labels, sp_centers] = augmented_h_slic(image,...
            n_cluster,...
            m,...
            m_clust,...
            bandwidth=NaN,...
            quantile=0.48,...
            perc=NaN,...
            threshold=0.01);
        
        % Evaluation of superpixel segmetation
        
        percentange = 15;
        UE = undersegmentation_error(sp_labels, gt, percentange, bg_value);
        
        % Save output
        out = consistent_random_remap(int32(sp_labels));
        
        saveName = "m" + num2str(m) + "_mc" + num2str(m_clust) + "_nc" + num2str(n_cluster);
        
        saveDir = '..\Output\' + datase_name;

        if ~exist(saveDir, 'dir')
            mkdir(saveDir);
        end

        t = Tiff(saveDir  + "\" + saveName + '.tiff', 'w');
        
        % Set TIFF tags for 32-bit integer storage
        tagstruct.ImageLength = size(out, 1);
        tagstruct.ImageWidth = size(out, 2);
        tagstruct.SampleFormat = Tiff.SampleFormat.Int;  % Store as integer
        tagstruct.BitsPerSample = 32;  % 32-bit
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        
        % Apply tags
        t.setTag(tagstruct);
        
        % Write data
        t.write(out);
        t.close();
        
        fprintf('Saved outpt image\n');
    end

end

