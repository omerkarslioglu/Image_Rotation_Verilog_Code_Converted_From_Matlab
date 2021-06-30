fileID = fopen('C:\Users\solid\Desktop\VerilogProjesi\rgb2grey\rgb2grey.sim\sim_1\behav\xsim\kaplumGrey.bin','r');

data=fread(fileID);

imageWidth = 64;
imageHeight = 64;
numColor = 3;

newData = uint8(zeros(imageWidth*imageHeight*numColor,1));
l=1;
for i = 1:imageWidth %for i 0 to maxColumn
    for j = 1:imageHeight %for j 0 to maxRow
        for k = 1:numColor
            newData(l+(k-1)*(imageWidth*imageHeight)) = data(imageWidth*(j-1)*numColor+(i-1)*numColor+k);  %newData[k] = imageData[maxColumn*j+i]
        end
        l=l+1;
    end
end

fclose(fileID);

finalData = reshape(newData,[imageHeight,imageWidth,numColor]);
imshow(finalData)
