v = VideoReader('C:\Users\daned\Desktop\walk_qcif.avi');

i = 1;
comparisons = 0;
add = 0;
subtract = 0;


while hasFrame(v)
    frame(i).cdata = readFrame(v); %read frame value
    ycbcr = rgb2ycbcr(frame(i).cdata(:,:,:)); %convert to ycbcr
    y(:,:,i) = ycbcr(:,:,1); %y component
    cb(:,:,i) = ycbcr(1:2:end,1:2:end,2); %cb component
    cr(:,:,i) = ycbcr(1:2:end,1:2:end,3); %cr component
    
    i = i+1; %increment 
    
end


frame_ref = im2double(y(:,:,6)); %ref frame is frame 5 


r_block = zeros(16,16);
for j=6:10
    frame_target = im2double(y(:,:,j+1)); %target frame
    frame_ref = im2double(y(:,:,j)); % reference frame
    macroblock = 16; %macroblock size
    [row,col] = size(frame_target);
   
    
    
    c = 1;
    for k = 1:macroblock:row  
        for t = 1:macroblock:col  
            SAD_min =  1*16^2; % value to compare SAD to
            for m = -8:8
                for n = -8:8
                    refBlkHor = t+n;
                    refBlkVer = k+m;
                    add = add+1;
                    if((refBlkVer < 1 || refBlkVer + macroblock-1 > row  || refBlkHor <1 || refBlkHor+macroblock-1> col))
                         
                        continue;
                    end
                    SAD=sum(abs(frame_target(k:k+16-1,t:t+16-1)- frame_ref(k+m:k+m+16-1,t+n:t+n+16-1)),'all');
                    
                    add = add+1;
                    subtract = subtract +1;
                    if(SAD<SAD_min) % if SAD is lower
                        SAD_min = SAD; %Update SAD
                        frame_est(k:k+16-1,t:t+16-1) = frame_ref(k+m:k+m+16-1,t+n:t+n+16-1); %store estimate with lowest SAD
                       disp_vect = [m,n];
                       comparisons = comparisons+1;
                    end
                end
            end
            search_window(c,:,1) = [k+16,t+16];
            search_window(c,:,2) = disp_vect;
            c = c+1;
            

        end
    end
    figure()
    quiver(search_window(:,2,1), search_window(:,1,1), search_window(:,2,2), search_window(:,1,2));
    title(['Motion Vectors Frame from Frame ',num2str(j),' to Frame ', num2str(j+1)]);
    
    error = frame_target - frame_est;
    figure()
    imshow(error);
    title(['Error between frame' num2str(j) 'and' num2str(j+1)]);

    figure()
    subplot(1,2,1)
    imshow(frame_target)
    title(['Target frame' num2str(j)]);
    
    subplot(1,2,2)
    imshow(frame_est);
    title(['Estimated frame' num2str(j+1)]);
    
    
    
end
