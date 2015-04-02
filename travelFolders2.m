%遍历文件夹下的内容
%输入参数：queryImagePath：查询文件路径
%queryNum：返回相似的个数
%dirName:训练集路径
%mode:查询模式
%rows,cloumns最后输出图片的行数和列数
%isFirst
function RGBlist = travelFolders2(queryImagePath,queryNum,dirName,mode,rows,cloumns,isFirst)
   pictureNum = folderCount(dirName,0);
   filenameVector = cell(pictureNum,1);
   fprintf('%d',pictureNum);
   if isFirst 
       [count,feature,file] = travelChild(dirName,1,filenameVector,mode);
       save data2.mat feature file;
   else
       load ('data2.mat','feature','file');
   end
   featureData = double(feature);
   queryImageRGB = imread(queryImagePath);
   queryFeature =  queryFeatureVector(queryImagePath,queryImageRGB,mode); 
%  featureKDTree = KDTreeSearcher(featureData);
   [n,d] = knnsearch(featureData,queryFeature,'k',queryNum,'nsmethod','exhaustive','distance','correlation');
   nLength = length(n);
   subplot(rows,cloumns,1);
   imshow(queryImageRGB);
   for i = 1:nLength
       len = n(i);
       fileName = file{n(i)}
       img = imread(fileName);
       subplot(rows,cloumns,i+1);
       imshow(img);
   end
end
function [count,data,returnFilenameVector] = travelChild(dirName,count,fileNameVector,mode)
%fprintf('count:%d\n',count);
D = dir(dirName);
num = length(D);
data = [];
for i=3:num %前两个文件夹保留
    if ~D(i).isdir
        tempRGB = imread(fullfile(dirName,D(i).name));
        image = imresize(tempRGB, [100 100]);
        hsvHist = hsvHistogram(image);
        %autoCorrelogram = colorAutoCorrelogram(image);
        %color_moments = colorMoments(image);
        % for gabor filters we need gary scale image
        img = double(rgb2gray(image))/255;
        %[meanAmplitude, msEnergy] = gaborWavelet(img, 4, 6); % 4 = number of scales, 6 = number of orientations
        wavelet_moments = waveletTransform(image);
        % construct the dataset
        if mode == 1
            set = [hsvHist];
        %elseif mode == 2
        %    set = [meanAmplitude];
        %elseif mode == 3
        %    set = [msEnergy];
        elseif mode == 2
            set =[wavelet_moments];
        elseif mode == 3
            set = [hsvHist wavelet_moments];
        end
        %set = [hsvHist autoCorrelogram color_moments meanAmplitude msEnergy wavelet_moments];
        %newSet = [set,str2double(fullfile(dirName,D(i).name))];
        data = [data;set];
        fileNameVector{count} = fullfile(dirName,D(i).name);
        count = count + 1;
        %fprintf('count:%d\n',count);
    else
        [count,temp,fileNameVector] = travelChild(fullfile(dirName,D(i).name),count,fileNameVector,mode);
        data = [data;temp];
    end
end
returnFilenameVector = fileNameVector;
end
function num = folderCount(dirName,count)
    D = dir(dirName);
    num = length(D);
    for i=3:num %前两个文件夹保留
        if ~D(i).isdir
            count = count + 1;
        else
            count = folderCount(fullfile(dirName,D(i).name),count);
%           count = count + num2;
        end
    end
    num = count;
end

function fea = queryFeatureVector(dirName,img,mode)
    image = imresize(img, [100 100]);
    hsvHist = hsvHistogram(image);
    %autoCorrelogram = colorAutoCorrelogram(image);
    %color_moments = colorMoments(image);
    % for gabor filters we need gary scale image
    img = double(rgb2gray(image))/255;
    %[meanAmplitude, msEnergy] = gaborWavelet(img, 4, 6); % 4 = number of scales, 6 = number of orientations
    wavelet_moments = waveletTransform(image);
    % construct the dataset
    %fea = [hsvHist];
    if mode == 1
            fea = [hsvHist];
    %elseif mode == 2
        fea =[meanAmplitude];
	%elseif mode == 3
	%	fea = [msEnergy];
	elseif mode == 2
        fea =[wavelet_moments];
    elseif mode == 3
        fea = [hsvHist wavelet_moments];
    end
%    fea = [hsvHist autoCorrelogram color_moments meanAmplitude msEnergy wavelet_moments];
end