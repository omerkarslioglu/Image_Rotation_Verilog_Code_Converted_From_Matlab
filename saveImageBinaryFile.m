imageWidth = 64;
imageHeight = 64;
numColor = 3;

i=imread('kaplum.png');
fileID = fopen('C:\Users\solid\Desktop\VerilogProjesi\rgb2grey\rgb2grey.sim\sim_1\behav\xsim\kaplum_color.bin','w');
for r = 1:imageHeight
    for c = 1:imageWidth
        for m = 1:numColor
            fwrite(fileID,i(r,c,m));
        end
    end
end
fclose(fileID);