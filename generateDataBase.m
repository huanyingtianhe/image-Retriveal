%输入参数说明
%dirName:训练集路径
function result = generatDataBase(dirName)
    D = dir(dirName);
    pictureNum = length(D);
    hsvLength = 32;
    aucoLength = 64;
    comoLength = 6;
    meanAmpLength = 24;
    msEnergyLength = 24;
    wavelength = 40;
    feature = zeros(pictureNum-2,hsvLength + aucoLength + comoLength +meanAmpLength + msEnergyLength+ wavelength);
    file = cell(pictureNum-2,1);
    fprintf('当前文件夹下图片数目：%d\n',pictureNum -2);
    for i=3:pictureNum %前两个文件夹保留
        if mod(i,10000) == 0
            fprintf('%d\n',i -2);
        end
        tempRGB = imread(fullfile(dirName,D(i).name));
        image = imresize(tempRGB, [120 120]);
       %% 特征提取
        hsvHist = hsvHistogram(image);%1x32维特征向量
        autoCorrelogram = colorAutoCorrelogram(image);%1x64
        color_moments = colorMoments(image);%1x6
        % for gabor filters we need gary scale image
        img = double(rgb2gray(image))/255;
        [meanAmplitude, msEnergy] = gaborWavelet(img, 4, 6); % 4 = number of scales, 6 = number of orientations
        wavelet_moments = waveletTransform(image);%1x40维特征向量
        
       %% construct the dataset
        set = [hsvHist autoCorrelogram color_moments meanAmplitude msEnergy wavelet_moments];
        file{i-2} = fullfile(dirName,D(i).name);
        %set = [hsvHist autoCorrelogram color_moments meanAmplitude msEnergy wavelet_moments];
        %newSet = [set,str2double(fullfile(dirName,D(i).name))];
        feature(i-2,:)=set;
    end
   save data5.mat feature file;
   
end