%在图片库中查询指定图片
%输入参数：queryImagePath：查询文件路径
%queryNum：返回相似的个数
%dirName:训练集路径
%queryMode:查询模式
%distanceMode:相似度距离比较
%rows,cloumns最后输出图片的行数和列数

function fileName = queryDataBase(queryImagePath,queryNum,queryMode,distanceMode,rows,cloumns)
    hsvLength = 32;
    aucoLength = 64 +hsvLength;
    comoLength = 6 + aucoLength;
    meanAmpLength = 24 + comoLength;
    msEnergyLength = 24 + meanAmpLength;
    wavelength = 40 + msEnergyLength;
   %pictureNum = folderCount(dirName,0);
   %filenameVector = cell(pictureNum,1);
   %fprintf('%d',pictureNum);
   %加载数据库
   load ('data4.mat','feature','file');
   if queryMode == 1    
        featureData = double(feature(:,1:hsvLength));
   elseif queryMode == 2
       featureData = double(feature(:, hsvLength+1:aucoLength));
   elseif queryMode == 3
        featureData = double(feature(:,aucoLength + 1:comoLength));
   elseif queryMode == 4
       featureData = double(feature(:,comoLength + 1:meanAmpLength));
   elseif queryMode == 5
       featureData = double(feature(:,meanAmpLength + 1:msEnergyLength));
   elseif queryMode == 6
       featureData = double(feature(:,msEnergyLength + 1:wavelength));
   else
       featureData = double(feature);
   end
   %生成查询图片特征向量
   queryImageRGB = imread(queryImagePath);
   queryFeature =  queryFeatureVector(queryImageRGB,queryMode); 
   %featureKDTree = KDTreeSearcher(featureData);
   %采用knn查询
   [n,d] = knnsearch(featureData,queryFeature,'k',queryNum,'nsmethod','exhaustive','distance',distanceMode);
   %显示返回得到的图片
   nLength = length(n);
   subplot(rows,cloumns,1);
   imshow(queryImageRGB);
   for i = 1:nLength
       n(i)
       len = n(i);
       fileName = file{n(i)}
       %[x,y] = size(fileName);
       %newFileName = strcat('C:\\Users\\tom\\Desktop\\clotheCut2\\finalResult\\',fileName(y-25:y))
       %fileName = newFileName;
       img = imread(fileName);
       subplot(rows,cloumns,i+1);
       imshow(img);
       [path,name,ext] =fileparts(fileName);
       title(name);
       
   end
   %交互修改图片库
end


function fea = queryFeatureVector(img,mode)
    image = imresize(img, [120 120]);
    %autoCorrelogram = colorAutoCorrelogram(image);
    %color_moments = colorMoments(image);
    % for gabor filters we need gary scale image
    %img = double(rgb2gray(image))/255;
    %[meanAmplitude, msEnergy] = gaborWavelet(img, 4, 6); % 4 = number of scales, 6 = number of orientations
    if mode == 1
        hsvHist = hsvHistogram(image);
        fea = [hsvHist];
    elseif mode == 2
        autoCorrelogram = colorAutoCorrelogram(image);
        fea =[autoCorrelogram];
	elseif mode == 3
        color_moments = colorMoments(image);
		fea = [color_moments];
    elseif mode == 4
        % for gabor filters we need gary scale image
        img = double(rgb2gray(image))/255;
        [meanAmplitude, msEnergy] = gaborWavelet(img, 4, 6)
        fea =[meanAmplitude];
	elseif mode == 5
        % for gabor filters we need gary scale image
        img = double(rgb2gray(image))/255;
        [meanAmplitude, msEnergy] = gaborWavelet(img, 4, 6)
		fea = [msEnergy];
	elseif mode == 6
        wavelet_moments = waveletTransform(image);
        fea =[wavelet_moments];
    else
        hsvHist = hsvHistogram(image);
        autoCorrelogram = colorAutoCorrelogram(image);
        color_moments = colorMoments(image);
        %for gabor filters we need gary scale image
        img = double(rgb2gray(image))/255;
        [meanAmplitude, msEnergy] = gaborWavelet
        wavelet_moments = waveletTransform(image);
        fea = [hsvHist autoCorrelogram color_moments meanAmplitude msEnergy wavelet_moments];
    end
end